/*
 * Copyright (c) 2019-2021 Web 3.0 Technologies Foundation
 *
 * This file is part of the Polkadot Test Suite.
 *
 * The Polkadot Test Suite is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Polkadot Test Suite is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Polkadot Test Suite. If not, see
 * <https://www.gnu.org/licenses/>.
 */

#pragma once

#include "../assert.hpp"

#include <common/buffer.hpp>

#include <scale/scale.hpp>

#include <runtime/executor.hpp>
#include <runtime/module_instance.hpp>

namespace scale = kagome::scale;

namespace helpers {

  using kagome::common::hex_lower;

  using kagome::common::Buffer;
  using MaybeBuffer = std::optional<Buffer>;

  using kagome::runtime::MemoryProvider;
  using kagome::runtime::ModuleInstance;
  using kagome::runtime::PtrSize;

  // Default path of runtime
  extern const char *DEFAULT_RUNTIME_PATH;

  class RuntimeEnvironment {
   public:
    // Available backends
    enum class Backend {
      Binaryen,
      WAVM,
    };

    // Default backend to use
    static const Backend DEFAULT_BACKEND;

    // Initialize a runtime environment
    RuntimeEnvironment(const std::string path = DEFAULT_RUNTIME_PATH,
                       Backend backend = DEFAULT_BACKEND);

    // Call function with provided arguments
    template <typename Result, typename... Args>
    Result execute(std::string_view name, Args &&...args) {
      auto &memory = memory_provider_->getCurrentMemory().value().get();

      Buffer encoded_args{};
      if constexpr (sizeof...(args) > 0) {
        auto res = scale::encode(std::forward<Args>(args)...);
        BOOST_ASSERT_MSG(res.has_value(), res.error().message().data());
        encoded_args.put(std::move(res.value()));
      }

      PtrSize args_span{memory.storeBuffer(encoded_args)};

      auto result = module_instance_->callExportFunction(name, args_span);
      BOOST_ASSERT_MSG(result.has_value(), result.error().message().data());

      auto reset = module_instance_->resetEnvironment();
      BOOST_ASSERT_MSG(reset.has_value(), reset.error().message().data());

      if constexpr (not std::is_void_v<Result>) {
        auto res = scale::decode<Result>(
            memory.loadN(result.value().ptr, result.value().size));
        BOOST_ASSERT_MSG(res.has_value(), res.error().message().data());
        return res.value();
      }
    }

   private:
    // Main objects used to execute calls
    std::shared_ptr<ModuleInstance> module_instance_;
    std::shared_ptr<MemoryProvider> memory_provider_;
  };
}  // namespace helpers
