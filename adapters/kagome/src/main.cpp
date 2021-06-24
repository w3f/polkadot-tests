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

#include <log/logger.hpp>
#include <soralog/impl/fallback_configurator.hpp>

#include "subcommand.hpp"

#include "host_api.hpp"
#include "scale_codec.hpp"
#include "state_trie.hpp"

#include <cerrno>

/**
 * Implementation of Polkadot Host API, SCALE codec and Merkle-Patricia
 * Tree compatibility tests
 */
int main(int argc, char **argv) {
  // Initialize logging system
  auto loglevel = kagome::log::Level::ERROR;
  if (argc > 1 and argv[1] == std::string_view("--verbose")) {
    loglevel = kagome::log::Level::DEBUG;
    argc--;
    argv++;
  }

  auto config = std::make_shared<soralog::FallbackConfigurator>(loglevel);
  auto logger = std::make_shared<soralog::LoggingSystem>(config);

  auto result = logger->configure();
  auto e0 = "Failed to configure logger: " + result.message;
  BOOST_ASSERT_MSG(!result.has_error, e0.data());

  kagome::log::setLoggingSystem(logger);

  // Initialize subcommand router with known commands
  SubcommandRouter<int, char **> router;
  router.addSubcommand("scale-codec", [](int argc, char **argv) {
    processScaleCodecCommand(extractScaleArgs(argc, argv));
  });
  router.addSubcommand("state-trie", [](int argc, char **argv) {
    processTrieCommand(extractTrieArgs(argc, argv));
  });
  router.addSubcommand("host-api", [](int argc, char **argv) {
    processHostApiCommands(extractHostApiArgs(argc, argv));
  });

  // Check if subcommand is provided
  std::string commands_list = "Valid subcommands are: ";
  for (auto &&name : router.collectSubcommandNames()) {
    commands_list += name;
    commands_list += " ";
  }

  auto e1 = "Subcommand is not provided\n" + commands_list;
  BOOST_ASSERT_MSG(argc > 1, e1.data());

  // Try to run subcommand
  try {
    auto e2 = "Invalid subcommand\n" + commands_list;
    BOOST_VERIFY_MSG(router.executeSubcommand(argv[1], argc - 1, argv + 1),
                     e2.data());
  } catch (const NotImplemented &e) {
    return EOPNOTSUPP;
  }

  return 0;
}
