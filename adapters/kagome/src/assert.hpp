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

#include <iostream>

#define BOOST_ENABLE_ASSERT_HANDLER
#include <boost/assert.hpp>

#include <exception>

//! Custom exception to signal missing implementation
struct NotImplemented : public std::runtime_error {
  NotImplemented() : std::runtime_error("Not implemented!") {}
};

//! Helpers to print asserts and associated messages
namespace boost {
  void assertion_failed(char const *expr,
                        char const *function,
                        char const *file,
                        long line);

  void assertion_failed_msg(char const *expr,
                            char const *msg,
                            char const *function,
                            char const *file,
                            long line);
}  // namespace boost
