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
// along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

///This file is an interface to run Parity implementation of state trie used in Polkadot Host.

use std::path::PathBuf;

use std::collections::BTreeMap;


use clap::{Arg, ArgMatches, Command, value_parser};
use clap::builder::PossibleValuesParser;

use memory_db::{HashKey, MemoryDB};

use reference_trie::GenericNoExtensionLayout;
use reference_trie::ReferenceTrieStreamNoExt as ReferenceTrieStream;

use sp_core::Blake2Hasher;

use trie_db::TrieMut;
use trie_root::trie_root_no_extension;


pub fn get_subcommand() -> Command<'static> {
    return Command::new("state-trie")
        .about("State Trie related tests")
        .arg(Arg::new("function")
             .index(1)
             .required(true)
             .value_parser(PossibleValuesParser::new(["trie-root", "insert-and-delete"])))
        .arg(Arg::new("state-file")
             .long("state-file")
             .required(true)
             .short('i')
             .takes_value(true)
             .value_name("INPUT_FILE")
             .value_parser(value_parser!(PathBuf)))
        .arg(Arg::new("keys-in-hex")
             .action(clap::ArgAction::SetTrue)
             .help("interpret all keys in the state file as hex encoded")
             .long("keys-in-hex"))
        .arg(Arg::new("values-in-hex")
             .action(clap::ArgAction::SetTrue)
             .help("interpret all values in the state file as hex encoded")
             .long("values-in-hex"));
}

/// Create TrieTester and read its data according to the command line arg
pub fn process_subcommand(matches: &ArgMatches) {

    let state_file = matches.get_one::<PathBuf>("state-file").unwrap();

    let keys_in_hex = matches.get_one::<bool>("keys-in-hex").unwrap();
    let values_in_hex = matches.get_one::<bool>("values-in-hex").unwrap();

    let mut tester = TrieTester::new(state_file, keys_in_hex, values_in_hex);


    let function = matches.get_one::<String>("function").unwrap();

    match function.as_str() {
        "trie-root" => tester.compute_state_root(),
        "insert-and-delete" => tester.insert_and_delete_test(),
        _ => unimplemented!("Unknown function"),
    }
}

///An object to perform various tests on a trie
pub struct TrieTester {
    keys: Vec<Vec<u8>>,
    values: Vec<Vec<u8>>,
}

impl TrieTester {

    /// Read a yaml state file containig key value pairs and return a list of entries
    pub fn new(state_file_path: &PathBuf, hex_keys: &bool, hex_values: &bool) -> Self {
        // Attempt to open state file
        let state_file = std::fs::File::open(state_file_path).unwrap();

        // We are deserializing the state data in a BTree
        let key_value_map: BTreeMap<String, Vec<String>> = serde_yaml::from_reader(state_file).unwrap();

        TrieTester {
            keys: key_value_map["keys"]
                .iter()
                .map(|k| {
                    if *hex_keys {
                        hex::decode(k).expect("Decoding failed")
                    } else {
                        k.clone().into_bytes()
                    }
                })
                .collect(),
            values: key_value_map["values"]
                .iter()
                .map(|v| {
                    if *hex_values {
                        hex::decode(v).expect("Decoding failed")
                    } else {
                        v.clone().into_bytes()
                    }
                })
                .collect(),
        }
    }

    /// Create a trie from the key value yaml file and compute its hash and print it out.
    ///
    /// # Arguments
    ///
    /// * `Argmatches` - the resulting command line argument matches from clap processor related to state-trie command
    ///
    fn compute_state_root(&self) {
        let trie_vec: Vec<_> = self.keys.iter().zip(self.values.iter()).collect();
        let state_trie_root =
            trie_root_no_extension::<Blake2Hasher, ReferenceTrieStream, _, _, _>(trie_vec, None);
        println!("state root: {:x}", &state_trie_root);
    }

    /// Perform a sequentials insert and delete test: it insert the key value pairs from the yaml file
    /// One by one and compute the hash at each stages then it takes
    /// random steps in the key list equal to the first byte of the last hash it has computed and delete
    /// the key it lands on and print the hash of the the new trie. It continue this process till all
    /// keys are deleted.
    fn insert_and_delete_test(&mut self) {
        let mut memdb = MemoryDB::<_, HashKey<_>, _>::default();
        let mut root = Default::default();

        //let mut memtrie = RefTrieDBMutNoExt::new(&mut memdb, &mut root);
        pub type RefPolkadotTrieDBMutNoExt<'a> =
            trie_db::TrieDBMut<'a, GenericNoExtensionLayout<Blake2Hasher>>;
        let mut memtrie = RefPolkadotTrieDBMutNoExt::new(&mut memdb, &mut root);

        for i in 0..self.keys.len() {
            let key: &[u8] = &self.keys[i];
            let val: &[u8] = &self.values[i];
            memtrie.insert(key, val).unwrap();
            memtrie.commit();
            println!("state root: {:x}", memtrie.root());
        }

        //now we randomly drop nodes
        while self.keys.len() > 0 {
            let key_index_to_drop = memtrie.root()[0] as usize % self.keys.len();
            let key_to_drop = &self.keys[key_index_to_drop];
            memtrie.remove(key_to_drop).unwrap();
            memtrie.commit();
            println!("state root: {:x}", memtrie.root());
            self.keys.remove(key_index_to_drop);
        }
    }
}
