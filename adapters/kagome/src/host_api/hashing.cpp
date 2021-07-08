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

#include "hashing.hpp"

#include "helpers.hpp"

#include <iostream>
#include <sstream>

namespace hashing {

  // execute hash function test by calling the select hash function
  // and target hash size with provided input.
  //
  // @param environment is the runtime environment to use
  // @param name is the name of the hash (e.g. blake2, keccak, sha2 or twox)
  // @param size is the expected size of the hash output
  // @param inputs to pass to the function
  void version_1(
    helpers::RuntimeEnvironment& environment,
    const std::string_view name,
    uint32_t size,
    const std::vector<std::string>& inputs
  ) {
    // Parse inputs
    BOOST_ASSERT(inputs.size() == 1);

    const std::string_view data = inputs[0];

    // Call hash function
    std::stringstream function;
    function << "rtm_ext_hashing_" << name << "_" << size * 8 << "_version_1";

    auto hash = environment.execute<helpers::Buffer>(function.str(), data);

    BOOST_ASSERT_MSG(hash.size() == size, "Incorrect hash size.");

    // Print result
    std::cout << hash.toHex() << std::endl;
  }


  void blake2_128_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "blake2", 16, inputs);
  }

  void blake2_256_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "blake2", 32, inputs);
  }


  void keccak_256_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "keccak", 32, inputs);
  }


  void sha2_256_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "sha2", 32, inputs);
  }


  void twox_64_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "twox", 8, inputs);
  }

  void twox_128_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "twox", 16, inputs);
  }

  void twox_256_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    version_1(environment, "twox", 32, inputs);
  }

}
