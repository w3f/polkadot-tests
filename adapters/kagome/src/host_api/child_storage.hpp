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

// TODO update and implement module
namespace child_storage {

  // executes ext_default_child_storage_set_version_1 and
  // ext_default_child storage_get_version_1 test
  void set_get_version_1(helpers::RuntimeEnvironment environment,
                         const std::vector<std::string> &inputs);

  void read_version_1(helpers::RuntimeEnvironment environment,
                      const std::vector<std::string> &args);

  void clear_version_1(helpers::RuntimeEnvironment environment,
                       const std::vector<std::string> &args);

  void storage_kill_version_1(helpers::RuntimeEnvironment environment,
                              const std::vector<std::string> &args);

  void exists_version_1(helpers::RuntimeEnvironment environment,
                        const std::vector<std::string> &args);

  void clear_prefix_version_1(helpers::RuntimeEnvironment environment,
                              const std::vector<std::string> &args);

  void root_version_1(helpers::RuntimeEnvironment environment,
                      const std::vector<std::string> &args);

  void next_key_version_1(helpers::RuntimeEnvironment environment,
                          const std::vector<std::string> &args);

}  // namespace child_storage
