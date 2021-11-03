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

namespace hashing {

  void blake2_128_version_1(helpers::RuntimeEnvironment &environment,
                            const std::vector<std::string> &inputs);

  void blake2_256_version_1(helpers::RuntimeEnvironment &environment,
                            const std::vector<std::string> &inputs);

  void keccak_256_version_1(helpers::RuntimeEnvironment &environment,
                            const std::vector<std::string> &inputs);

  void sha2_256_version_1(helpers::RuntimeEnvironment &environment,
                          const std::vector<std::string> &inputs);

  void twox_64_version_1(helpers::RuntimeEnvironment &environment,
                         const std::vector<std::string> &inputs);

  void twox_128_version_1(helpers::RuntimeEnvironment &environment,
                          const std::vector<std::string> &inputs);

  void twox_256_version_1(helpers::RuntimeEnvironment &environment,
                          const std::vector<std::string> &inputs);

}  // namespace hashing
