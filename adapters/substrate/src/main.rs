// Copyright (c) 2019 Web3 Technologies Foundation

// This file is part of Polkadot Host Test Suite

// Polkadot Host Test Suite is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// Polkadot Host Tests is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with Polkadot Host Test Suite.  If not, see <https://www.gnu.org/licenses/>.

///This file is an interface to run various Polkadot Host functions

use clap::command;

// Fixture sub-adapters
mod host_api;
mod scale_codec;
mod state_trie;

fn main() {
    let matches = command!()
        .subcommand_required(true)
        .subcommands( vec![
            host_api::get_subcommand(),
            scale_codec::get_subcommand(),
            state_trie::get_subcommand(),
        ])
        .get_matches();

    match matches.subcommand() {
        Some(("host-api",  m)) => host_api::process_subcommand(m),
        Some(("scale-codec", m)) => scale_codec::process_subcommand(m),
        Some(("state-trie", m)) => state_trie::process_subcommand(m),
        _ => unimplemented!("Unknown command"),
    }
}
