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

///This file is an interface to run Parity implementation of SCALE codec.

use clap::{Arg, ArgMatches, Command};
use clap::builder::PossibleValuesParser;

use parity_scale_codec::Encode;

// Command line processing

pub fn get_subcommand() -> Command<'static> {
    return Command::new("scale-codec")
        .about("Scale Codec related tests")
        .arg(Arg::new("function")
             .index(1)
             .required(true)
             .value_parser(PossibleValuesParser::new(["encode"])))
        .arg(Arg::new("input")
             .help("the input to be encoded")
             .long("input")
             .required(true)
             .short('i')
             .takes_value(true)
             .value_name("INPUT_VALUE"));
}

pub fn process_subcommand(matches: &ArgMatches) {
    let function = matches.get_one::<String>("function").unwrap();

    let input = matches.get_one::<String>("input").unwrap();

    match function.as_str() {
        "encode" => encode(input),
        _ => unimplemented!("Unknown function"),
    }
}

// Test functions

fn encode(value: &String) {
    println!("encoded {}: {:x?}", value, value.encode());
}
