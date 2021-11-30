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

#include "trie.hpp"

#include "helpers.hpp"

#include <kagome/common/buffer.hpp>

#include <iostream>

namespace trie {

  void blake2_256_ordered_root_version_1(
      helpers::RuntimeEnvironment &environment,
      const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 3);

    const std::string_view value1 = inputs[0];
    const std::string_view value2 = inputs[1];
    const std::string_view value3 = inputs[2];

    // Compute ordered trie root
    auto hash = environment.execute<helpers::Buffer>(
        "rtm_ext_trie_blake2_256_ordered_root_version_1",
        std::vector{value1, value2, value3});

    // Print result
    std::cout << hash.toHex() << std::endl;
  }

  void blake2_256_root_version_1(helpers::RuntimeEnvironment &environment,
                                 const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 6);

    const std::string_view key1 = inputs[0];
    const std::string_view value1 = inputs[1];

    const std::string_view key2 = inputs[2];
    const std::string_view value2 = inputs[3];

    const std::string_view key3 = inputs[4];
    const std::string_view value3 = inputs[5];

    // Compute trie root
    auto hash = environment.execute<helpers::Buffer>(
        "rtm_ext_trie_blake2_256_root_version_1",
        std::vector{
            std::pair{key1, value1},
            std::pair{key2, value2},
            std::pair{key3, value3},
        });

    // Print result
    std::cout << hash.toHex() << std::endl;
  }
}  // namespace trie
