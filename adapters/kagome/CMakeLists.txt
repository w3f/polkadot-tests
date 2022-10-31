# Copyright (c) 2019-2021 Web 3.0 Technologies Foundation
#
# This file is part of the Polkadot Test Suite.
#
# The Polkadot Test Suite is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The Polkadot Test Suite is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the Polkadot Test Suite. If not, see
# <https://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.12)


# Setup toolchain (required by kagome and libp2p)
set(CMAKE_TOOLCHAIN_FILE
  "${CMAKE_SOURCE_DIR}/cmake/Toolchain.cmake"
  CACHE FILEPATH "Default toolchain"
)

# Propagate CMake build type to dependencies
set(
  HUNTER_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}"
  CACHE STRING "Hunter configuration type"
)

# Enable upload to binary cache if username and password are supplied
string(COMPARE EQUAL "$ENV{GITHUB_HUNTER_USERNAME}" "" UPLOAD_USER_EMPTY)
string(COMPARE EQUAL "$ENV{GITHUB_HUNTER_TOKEN}" "" UPLOAD_TOKEN_EMPTY)

if(UPLOAD_USER_EMPTY OR UPLOAD_TOKEN_EMPTY)
  set(HUNTER_RUN_UPLOAD NO CACHE BOOL "Upload to binary cache")
else()
  set(HUNTER_RUN_UPLOAD YES CACHE BOOL "Upload to binary cache")
endif()

set(
  HUNTER_PASSWORDS_PATH "${CMAKE_SOURCE_DIR}/cmake/HunterPasswords.cmake"
  CACHE FILEPATH "Hunter passwords files"
)

message(STATUS "Upload to binary cache: ${HUNTER_RUN_UPLOAD}")

# Setup binary cache
set(
  HUNTER_CACHE_SERVERS "https://github.com/w3f/hunter-binary-cache"
  CACHE STRING "Binary cache server"
)

message(STATUS "Download from binary cache: ${HUNTER_USE_CACHE_SERVERS}")

# Setup hunter
include(cmake/HunterGate.cmake)
HunterGate(
  URL "https://github.com/soramitsu/soramitsu-hunter/archive/refs/tags/v0.23.257-soramitsu31.zip"
  SHA1 "a13dcf6dae9e926441715e67c409838630f6f3e0"
  FILEPATH "${CMAKE_SOURCE_DIR}/cmake/HunterConfig.cmake"
)

set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ${HUNTER_ENABLED})


# General config
project(kagome-adapter LANGUAGES CXX C)

hunter_add_package(yaml-cpp)
find_package(yaml-cpp REQUIRED)

# Fix inconsistency between hunterized and upstream package (+ CMake oddity fix)
if(NOT TARGET yaml-cpp)
  set_target_properties(yaml-cpp::yaml-cpp PROPERTIES IMPORTED_GLOBAL true)
  add_library(yaml-cpp ALIAS yaml-cpp::yaml-cpp)
endif()

hunter_add_package(Boost COMPONENTS program_options)
find_package(Boost REQUIRED COMPONENTS program_options)

hunter_add_package(scale)
find_package(scale REQUIRED CONFIG)

hunter_add_package(kagome)
find_package(kagome REQUIRED CONFIG)

message(STATUS "Found kagome: ${kagome_INCLUDE_DIRS}")

# Compile and link tester
add_executable(kagome-adapter
  src/main.cpp
  src/assert.cpp
  src/scale_codec.cpp
  src/state_trie.cpp
  src/host_api.cpp
  src/host_api/helpers.cpp
  src/host_api/allocator.cpp
  src/host_api/crypto.cpp
  src/host_api/hashing.cpp
  src/host_api/trie.cpp
  src/host_api/storage.cpp
  src/host_api/child_storage.cpp
)

target_link_libraries(kagome-adapter
  Boost::program_options
  yaml-cpp
  scale::scale
  kagome::block_header_repository
  kagome::binaryen_instance_environment_factory
  kagome::binaryen_module_factory
  kagome::bip39_provider
  kagome::chain_spec
  kagome::changes_tracker
  kagome::core_api
  kagome::crypto_store
  kagome::ed25519_provider
  kagome::hasher
  kagome::host_api_factory
  kagome::in_memory_storage
  kagome::key_file_storage
  kagome::log_configurator
  kagome::offchain_persistent_storage
  kagome::offchain_worker_pool
  kagome::pbkdf2_provider
  kagome::polkadot_codec
  kagome::polkadot_trie_factory
  kagome::sr25519_provider
  kagome::storage_code_provider
  kagome::trie_serializer
  kagome::trie_storage
  kagome::trie_storage_backend
  kagome::trie_storage_provider
  kagome::runtime_wavm
)


# Install result
include(GNUInstallDirs)

install(TARGETS kagome-adapter
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
