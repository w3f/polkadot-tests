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

#include <string>
#include <vector>

#include "helpers.hpp"

namespace storage {

  // executes ext_storage_init test
  void test_init(helpers::RuntimeEnvironment &environment,
                 const std::vector<std::string> &inputs);

  // executes ext_storage_set_version_1/ext_storage_get_version_1 test
  void set_get_version_1(helpers::RuntimeEnvironment &environment,
                         const std::vector<std::string> &inputs);

  // executes ext_storage_read_version_1 test
  void read_version_1(helpers::RuntimeEnvironment &environment,
                      const std::vector<std::string> &inputs);

  // executes ext_storage_clear_version_1 test
  void clear_version_1(helpers::RuntimeEnvironment &environment,
                       const std::vector<std::string> &inputs);

  // executes ext_storage_exists_version_1 test
  void exists_version_1(helpers::RuntimeEnvironment &environment,
                        const std::vector<std::string> &inputs);

  // executes ext_storage_clear_prefix_version_1 test
  void clear_prefix_version_1(helpers::RuntimeEnvironment &environment,
                              const std::vector<std::string> &inputs);

  // executes ext_storage_append_version_1 test
  void append_version_1(helpers::RuntimeEnvironment &environment,
                        const std::vector<std::string> &inputs);

  // executes ext_storage_root_version_1 test
  void root_version_1(helpers::RuntimeEnvironment &environment,
                      const std::vector<std::string> &inputs);

  // executes ext_storage_next_key_version_1 test
  void next_key_version_1(helpers::RuntimeEnvironment &environment,
                          const std::vector<std::string> &inputs);

}  // namespace storage
