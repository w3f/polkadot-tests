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

#include "assert.hpp"

#include <boost/optional.hpp>
#include <boost/program_options.hpp>

#include "subcommand.hpp"

#include "host_api.hpp"
#include "host_api/allocator.hpp"
#include "host_api/child_storage.hpp"
#include "host_api/crypto.hpp"
#include "host_api/hashing.hpp"
#include "host_api/storage.hpp"
#include "host_api/trie.hpp"

namespace po = boost::program_options;

namespace host_api {

  CommandArgs extractArgs(int argc, char **argv) {
    po::options_description desc("HostApi environment tests\nAllowed options:");

    boost::optional<std::string> runtime;
    boost::optional<std::string> function;
    boost::optional<std::string> input;
    boost::optional<std::string> environment;

    desc.add_options()
      ("help", "produce help message")
      ("runtime", po::value(&runtime), "specify runtime file to use")
      ("function", po::value(&function), "specify function to run")
      ("input", po::value(&input), "specify a input to function")
      ("environment", po::value(&environment), "specify environment to run");

    po::variables_map varmap;
    po::store(
      po::command_line_parser(argc, argv).options(desc).run(),
      varmap
    );
    po::notify(varmap);

    // Parse command args:
    CommandArgs args;

    // - runtime flag
    if (runtime) {
      args.runtime = *runtime;
    } else {
      args.runtime = helpers::DEFAULT_RUNTIME_PATH;
    }

    // - function flag
    BOOST_ASSERT_MSG(function, "Function is not stated");
    args.function = *function;

    // - input flag
    if (input) {
      std::stringstream inputStream(*input);
      std::string inputElement;
      while (std::getline(inputStream, inputElement, ',')) {
        args.inputs.push_back(inputElement);
      }
    }

    // - environment flag
    if (environment) {
      if (*environment == "binaryen") {
        args.environment = helpers::RuntimeEnvironment::Backend::Binaryen;
      } else if (*environment == "wavm") {
        args.environment = helpers::RuntimeEnvironment::Backend::WAVM;
      } else {
        std::cout << "Unknown environment: " << *environment << std::endl;
        exit(1);
      }
    } else {
      args.environment = helpers::RuntimeEnvironment::DEFAULT_BACKEND;
    }

    return std::move(args);
  }

  void processCommand(const CommandArgs &args) {
    SubcommandRouter<helpers::RuntimeEnvironment&, const std::vector<std::string>&> router({
        // test storage
        {"test_storage_init", storage::test_init},
        {"ext_storage_set_version_1", storage::set_get_version_1},
        {"ext_storage_get_version_1", storage::set_get_version_1},
        {"ext_storage_read_version_1", storage::read_version_1},
        {"ext_storage_clear_version_1", storage::clear_version_1},
        {"ext_storage_exists_version_1", storage::exists_version_1},
        {"ext_storage_clear_prefix_version_1", storage::clear_prefix_version_1},
        {"ext_storage_append_version_1", storage::append_version_1},
        {"ext_storage_root_version_1", storage::root_version_1},
        {"ext_storage_next_key_version_1", storage::next_key_version_1},
        // test child storage
        {"ext_default_child_storage_set_version_1", child_storage::set_get_version_1},
        {"ext_default_child_storage_get_version_1", child_storage::set_get_version_1},
        {"ext_default_child_storage_read_version_1", child_storage::read_version_1},
        {"ext_default_child_storage_clear_version_1", child_storage::clear_version_1},
        {"ext_default_child_storage_storage_kill_version_1", child_storage::storage_kill_version_1},
        {"ext_default_child_storage_exists_version_1", child_storage::exists_version_1},
        {"ext_default_child_storage_clear_prefix_version_1", child_storage::clear_prefix_version_1},
        {"ext_default_child_storage_root_version_1", child_storage::root_version_1},
        {"ext_default_child_storage_next_key_version_1", child_storage::next_key_version_1},
        // test crypto ed25519 api
        {"ext_crypto_ed25519_public_keys_version_1", crypto::ed25519_public_keys_version_1},
        {"ext_crypto_ed25519_generate_version_1", crypto::ed25519_generate_version_1},
        {"ext_crypto_ed25519_sign_version_1", crypto::ed25519_sign_version_1},
        {"ext_crypto_ed25519_verify_version_1", crypto::ed25519_verify_version_1},
        // test crypto sr25519 api
        {"ext_crypto_sr25519_public_keys_version_1", crypto::sr25519_public_keys_version_1},
        {"ext_crypto_sr25519_generate_version_1", crypto::sr25519_generate_version_1},
        {"ext_crypto_sr25519_sign_version_1", crypto::sr25519_sign_version_1},
        {"ext_crypto_sr25519_verify_version_1", crypto::sr25519_verify_version_1},
        // test hashing api
        {"ext_hashing_blake2_128_version_1", hashing::blake2_128_version_1},
        {"ext_hashing_blake2_256_version_1", hashing::blake2_256_version_1},
        {"ext_hashing_keccak_256_version_1", hashing::keccak_256_version_1},
        {"ext_hashing_sha2_256_version_1", hashing::sha2_256_version_1},
        {"ext_hashing_twox_64_version_1", hashing::twox_64_version_1},
        {"ext_hashing_twox_128_version_1", hashing::twox_128_version_1},
        {"ext_hashing_twox_256_version_1", hashing::twox_256_version_1},
        // test allocator api
        {"ext_allocator_malloc_version_1", allocator::malloc_free_version_1},
        {"ext_allocator_free_version_1", allocator::malloc_free_version_1},
        // test trie api
        {"ext_trie_blake2_256_root_version_1", trie::blake2_256_root_version_1},
        {"ext_trie_blake2_256_ordered_root_version_1", trie::blake2_256_ordered_root_version_1},
    });

    helpers::RuntimeEnvironment environment(args.runtime, args.environment);

    std::string commands_list = "Valid function are: ";
    for (auto &&name : router.collectSubcommandNames()) {
      commands_list += name;
      commands_list += " ";
    }
    auto e1 = "function is not provided\n" + commands_list;
    auto e2 = "Invalid function\n" + commands_list;
    BOOST_VERIFY_MSG(router.executeSubcommand(args.function, environment, args.inputs),
                     "Invalid function");
  }
}
