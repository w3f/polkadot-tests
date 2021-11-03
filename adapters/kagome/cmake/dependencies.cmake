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

hunter_add_package(yaml-cpp)
find_package(yaml-cpp REQUIRED)

# Fix inconsistency between hunterized and upstream package (+ CMake oddity fix)
if(NOT TARGET yaml-cpp)
  set_target_properties(yaml-cpp::yaml-cpp PROPERTIES IMPORTED_GLOBAL true)
  add_library(yaml-cpp ALIAS yaml-cpp::yaml-cpp)
endif()

hunter_add_package(kagome)
find_package(kagome REQUIRED CONFIG)

message(STATUS "Found kagome: ${kagome_INCLUDE_DIRS}")

# FIXME Kagome's package config should do all this!
find_package(Boost REQUIRED COMPONENTS filesystem program_options random)
find_package(schnorrkel_crust REQUIRED)
find_package(libsecp256k1 REQUIRED)
find_package(leveldb REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(xxhash REQUIRED)
find_package(soralog REQUIRED)
find_package(fmt REQUIRED)
find_package(libp2p REQUIRED)
find_package(zstd REQUIRED)
find_package(binaryen REQUIRED)
find_package(LLVM REQUIRED)
find_package(WAVM REQUIRED)
