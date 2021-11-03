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

#include "allocator.hpp"

#include "helpers.hpp"

#include <iostream>

namespace allocator {

  void malloc_free_version_1(helpers::RuntimeEnvironment environment,
                             const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 1);

    const std::string_view value = inputs[0];

    // The Wasm function tests both the allocation and freeing of the buffer
    auto result = environment.execute<helpers::Buffer>(
        "rtm_ext_allocator_malloc_version_1", value);

    BOOST_ASSERT_MSG(result.toString() == value, "Values are different");

    std::cout << result.toString() << std::endl;
  }

}  // namespace allocator
