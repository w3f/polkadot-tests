/*
 * Copyright (c) 2019 Web3 Technologies Foundation
 *
 * This file is part of Polkadot Host Test Suite
 *
 * Polkadot Host Test Suite is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Polkadot Host Tests is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
 */

#pragma once

#include "../assert.hpp"

#include <common/buffer.hpp>

#include <scale/scale.hpp>

#include <blockchain/impl/key_value_block_header_repository.hpp>

#include <runtime/executor.hpp>

namespace scale = kagome::scale;

namespace helpers {

  using kagome::common::hex_lower;

  using kagome::common::Buffer;
  using MaybeBuffer = std::optional<Buffer>;

  using namespace kagome::runtime;

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

    // Call function with provided arguments in wasm adapter
    template <typename R, typename... Args>
    R execute(std::string_view name, Args &&...args) {
      auto result = runtime_->persistentCallAtGenesis<R>(
          name, std::forward<Args>(args)...);

      BOOST_ASSERT_MSG(result, result.error().message().data());

      if constexpr (not std::is_same_v<R, void>) {
        return result.value().result;
      }
    }

   private:
    // Main object used to execute calls
    std::shared_ptr<Executor> runtime_;
  };
}  // namespace helpers
