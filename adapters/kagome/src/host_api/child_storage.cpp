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

#include "child_storage.hpp"

#include "helpers.hpp"

#include <iostream>

namespace child_storage {

  void set_get_version_1(helpers::RuntimeEnvironment environment,
                         const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 4);

    const std::string_view child1 = inputs[0];
    const std::string_view child2 = inputs[1];

    const std::string_view key = inputs[2];
    const std::string_view value = inputs[3];

    // Check that key has not been set
    auto result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child1, key);

    BOOST_ASSERT_MSG(!result, "Child1 data exists");

    // Add data to storage
    environment.execute<void>(
        "rtm_ext_default_child_storage_set_version_1", child1, key, value);

    // Check that key has not been set
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child2, key);

    BOOST_ASSERT_MSG(!result, "Child2 data exists");

    // Retrieve data from storage
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child1, key);

    // Check returned data
    BOOST_ASSERT_MSG(result.has_value(), "No value");
    BOOST_ASSERT_MSG(result.value().toString() == value,
                     "Values are different");

    // Print result
    std::cout << result.value().toString() << std::endl;
  }

  void read_version_1(helpers::RuntimeEnvironment environment,
                      const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 6);

    const std::string_view child1 = inputs[0];
    const std::string_view child2 = inputs[1];
    const std::string_view key = inputs[2];
    const std::string_view value = inputs[3];
    const uint32_t offset = std::stoul(inputs[4]);
    const uint32_t length = std::stoul(inputs[5]);

    // Check that key has not been set
    auto result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_read_version_1",
        child1,
        key,
        offset,
        length);

    BOOST_ASSERT_MSG(!result, "Child1 data exists");

    // Add data to storage
    environment.execute<void>(
        "rtm_ext_default_child_storage_set_version_1", child1, key, value);

    // Get invalid key (different child storage)
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_read_version_1",
        child2,
        key,
        offset,
        length);

    BOOST_ASSERT_MSG(!result, "Child2 data exists");

    // Get valid key
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_read_version_1",
        child1,
        key,
        offset,
        length);
    BOOST_ASSERT_MSG(result.has_value(), "Child1 data missing");

    if (offset < value.length()) {
      auto expected_length =
          std::min(uint32_t(value.length() - offset), length);
      auto expected_value = value.substr(offset, expected_length);

      BOOST_ASSERT_MSG(result.value().toString() == expected_value,
                       "Values are different");
    } else {
      BOOST_ASSERT_MSG(result.value().empty(), "Values are different");
    }

    std::cout << result.value().toString() << std::endl;
  }

  // Input: child1, child2, key, value
  void clear_version_1(helpers::RuntimeEnvironment environment,
                       const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 4);

    const std::string_view child_key1 = inputs[0];
    const std::string_view child_key2 = inputs[1];

    const std::string_view key = inputs[2];
    const std::string_view value = inputs[3];

    // Set key/value
    environment.execute<void>(
        "rtm_ext_default_child_storage_set_version_1", child_key1, key, value);

    // Clear value (other child key)
    environment.execute<void>(
        "rtm_ext_default_child_storage_clear_version_1", child_key2, key);

    // Get valid key
    auto result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key);
    BOOST_ASSERT_MSG(result.has_value(), "Value not found");
    BOOST_ASSERT_MSG(result.value().toString() == value,
                     "Read value is incorrect");

    // Clear value
    environment.execute<void>(
        "rtm_ext_default_child_storage_clear_version_1", child_key1, key);

    // Get cleared value
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key);
    BOOST_ASSERT_MSG(!result, "Value was not deleted");
  }

  // Input: child1, child2, key, value
  void storage_kill_version_1(helpers::RuntimeEnvironment environment,
                              const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 6);

    const std::string_view child_key1 = inputs[0];
    const std::string_view child_key2 = inputs[1];

    const std::string_view key1 = inputs[2];
    const std::string_view value1 = inputs[3];

    const std::string_view key2 = inputs[4];
    const std::string_view value2 = inputs[5];

    // Set keys to values
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key1,
                              value1);
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key2,
                              value2);

    // Kill other child storage
    environment.execute<void>(
        "rtm_ext_default_child_storage_storage_kill_version_1", child_key2);

    // Check for valid values
    auto result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key1);
    BOOST_ASSERT_MSG(result.has_value(), "Value not found");
    BOOST_ASSERT_MSG(result.value().toString() == value1,
                     "Value is incorrect");

    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key2);
    BOOST_ASSERT_MSG(result.has_value(), "Value not found");
    BOOST_ASSERT_MSG(result.value().toString() == value2,
                     "Value is incorrect");

    // Kill child storage
    environment.execute<void>(
        "rtm_ext_default_child_storage_storage_kill_version_1", child_key1);

    // Check for killed values
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key1);
    BOOST_ASSERT_MSG(!result.has_value(), "Value not killed");

    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key2);
    BOOST_ASSERT_MSG(!result.has_value(), "Value not killed");
 }

  // Input: child1, child2, key, value
  void exists_version_1(helpers::RuntimeEnvironment environment,
                        const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 4);

    const std::string_view child_key1 = inputs[0];
    const std::string_view child_key2 = inputs[1];
    const std::string_view key = inputs[2];
    const std::string_view value = inputs[3];

    // Check for no data
    auto exists = environment.execute<bool>(
        "rtm_ext_default_child_storage_exists_version_1", child_key1, key);

    BOOST_ASSERT_MSG(!exists, "Storage exists");

    // Insert data
    environment.execute<void>(
        "rtm_ext_default_child_storage_set_version_1", child_key1, key, value);

    // Check for data
    exists = environment.execute<bool>(
        "rtm_ext_default_child_storage_exists_version_1", child_key1, key);

    BOOST_ASSERT_MSG(exists, "Storage does not exists");

    // Print result
    std::cout << "true" << std::endl;
  }

  // Input: prefix, child1, child2, key1, value1, key2, value2
  void clear_prefix_version_1(helpers::RuntimeEnvironment environment,
                              const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 7);

    const std::string_view child_key1 = inputs[0];
    const std::string_view child_key2 = inputs[1];
    const std::string_view prefix = inputs[2];
    const std::string_view key1 = inputs[3];
    const std::string_view value1 = inputs[4];
    const std::string_view key2 = inputs[5];
    const std::string_view value2 = inputs[6];

    // Insert both key value pair
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key1,
                              value1);
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key2,
                              value2);

    // Clear prefix (other storage)
    environment.execute<void>(
        "rtm_ext_default_child_storage_clear_prefix_version_1",
        child_key2,
        prefix);

    // Clear prefix
    environment.execute<void>(
        "rtm_ext_default_child_storage_clear_prefix_version_1",
        child_key1,
        prefix);

    // Retrieve first key
    auto result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key1);

    // Check if first key was handled correctly
    if (prefix == key1.substr(0, prefix.size())) {
      BOOST_ASSERT_MSG(!result, "Value1 wasn't deleted");
    } else {
      BOOST_ASSERT_MSG(result.has_value(), "Value1 was deleted");
      BOOST_ASSERT_MSG(result.value().toString() == value1,
                       "Value1 was changed");
      std::cout << result.value().toString() << "\n";
    }

    // Retrieve second key
    result = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_get_version_1", child_key1, key2);

    // Check if first key was handled correctly
    if (prefix == key2.substr(0, prefix.size())) {
      BOOST_ASSERT_MSG(!result, "Value2 wasn't deleted");
    } else {
      BOOST_ASSERT_MSG(result.has_value(), "Value2 was deleted");
      BOOST_ASSERT_MSG(result.value().toString() == value2,
                       "Value2 was changed");
      std::cout << result.value().toString() << "\n";
    }
  }

  void root_version_1(helpers::RuntimeEnvironment environment,
                      const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 6);

    const std::string_view child_key1 = inputs[0];
    const std::string_view child_key2 = inputs[1];
    const std::string_view key1 = inputs[2];
    const std::string_view value1 = inputs[3];
    const std::string_view key2 = inputs[4];
    const std::string_view value2 = inputs[5];

    // Set key1 to value1
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key1,
                              value1);

    // Set key2 to value2
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key2,
                              value2);

    // Set key1 to value2 (different child key)
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key2,
                              key1,
                              value2);

    // Set key2 to value1 (different child key)
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key2,
                              key2,
                              value1);

    // Compute and print storage root hash
    auto hash = environment.execute<helpers::Buffer>(
        "rtm_ext_default_child_storage_root_version_1", child_key1);
    std::cout << hash.toHex() << std::endl;
  }

  void next_key_version_1(helpers::RuntimeEnvironment environment,
                          const std::vector<std::string> &inputs) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 6);

    const std::string_view child_key1 = inputs[0];
    const std::string_view child_key2 = inputs[1];

    const std::string_view key1 = inputs[2];
    const std::string_view value1 = inputs[3];

    const std::string_view key2 = inputs[4];
    const std::string_view value2 = inputs[5];

    // No next key available
    auto next = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_next_key_version_1", child_key1, key1);
    BOOST_ASSERT_MSG(!next, "Next is not empty");

    // Set key/value
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key1,
                              value1);
    environment.execute<void>("rtm_ext_default_child_storage_set_version_1",
                              child_key1,
                              key2,
                              value2);

    // Try to read next key
    next = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_next_key_version_1", child_key1, key1);
    if (key1.compare(key2) < 0) {
      BOOST_ASSERT_MSG(next, "Next is empty");

      auto result = next.value().toString();

      BOOST_ASSERT_MSG(result == key2, "Next is not Key2");

      std::cout << result << std::endl;
    } else {
      BOOST_ASSERT_MSG(!next, "Next is not empty");
    }

    // Try to read next key
    next = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_next_key_version_1", child_key1, key2);
    if (key2.compare(key1) < 0) {
      BOOST_ASSERT_MSG(next, "Next is empty");

      auto result = next.value().toString();

      BOOST_ASSERT_MSG(result == key1, "Next is not Key1");

      std::cout << result << std::endl;
    } else {
      BOOST_ASSERT_MSG(!next, "Next is not empty");
    }

    // Get invalid next key (different child key)
    next = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_next_key_version_1", child_key2, key1);
    BOOST_ASSERT_MSG(!next, "Next is not empty");
    next = environment.execute<helpers::MaybeBuffer>(
        "rtm_ext_default_child_storage_next_key_version_1", child_key2, key2);
    BOOST_ASSERT_MSG(!next, "Next is not empty");
  }

}  // namespace child_storage
