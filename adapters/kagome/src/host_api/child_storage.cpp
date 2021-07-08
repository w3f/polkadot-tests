/*
 * Copyright (c) 2019 Web3 Technologies Foundation
 *
 * This file is part of Polkadot Host Test Suite
 *
 * Polkadot Host Test Suite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
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

#include "child_storage.hpp"

#include "helpers.hpp"

#include <iostream>

namespace child_storage {

  void set_get_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string>& inputs
  ) {
    // FIXME Child storage not implemented upstream
    throw NotImplemented();

    // Parse inputs
    BOOST_ASSERT(inputs.size() == 4);

    const std::string_view child1 = inputs[0];
    const std::string_view child2 = inputs[1];

    const std::string_view key = inputs[2];
    const std::string_view value = inputs[3];

    // Check that key has not been set
    auto result = environment.execute<helpers::MaybeBuffer>(
      "rtm_ext_default_child_storage_get_version_1", child1, key
    );

    BOOST_ASSERT_MSG(!result, "Child1 data exists");

    // Add data to storage
    environment.execute<void>(
      "rtm_ext_default_child_storage_set_version_1", child1, key, value
    );

    // Check that key has not been set
    result = environment.execute<helpers::MaybeBuffer>(
      "rtm_ext_default_child_storage_get_version_1", child2, key
    );

    BOOST_ASSERT_MSG(!result, "Child2 data exists");

    // Retrieve data from storage
    result = environment.execute<helpers::MaybeBuffer>(
      "rtm_ext_default_child_storage_get_version_1", child1, key
    );

    // Check returned data
    BOOST_ASSERT_MSG(result.has_value(), "No value");
    BOOST_ASSERT_MSG(result.value().toString() == value, "Values are different");

    // Print result
    std::cout << result.value().toString() << std::endl;
  }


  void read_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

  // Input: child1, child2, key, value
  void clear_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

  // Input: child1, child2, key, value
  void storage_kill_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

  // Input: child1, child2, key, value
  void exists_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

  // Input: prefix, child1, child2, key1, value1, key2, value2
  void clear_prefix_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

  void root_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

  void next_key_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string> &args
  ) {
    throw NotImplemented(); // TODO not implemented
  }

}
