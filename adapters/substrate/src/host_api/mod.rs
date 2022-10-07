mod allocator;
mod child_storage;
mod crypto;
mod hashing;
mod storage;
mod trie;
mod offchain;
mod utils;

use std::path::PathBuf;

use clap::{
    Arg,
    ArgMatches,
    Command,
    builder::PossibleValuesParser,
    value_parser,
};
use utils::ParsedInput;

const DEFAULT_RUNTIME_PATH: &str = "bin/hostapi-runtime.default.wasm";

pub fn get_subcommand() -> Command<'static> {
    return Command::new("host-api")
        .about("Host API related tests")
        .arg(Arg::new("function")
             .long("function")
             .required(true)
             .short('f')
             .takes_value(true)
             .value_name("FUNCTION_NAME"))
        .arg(Arg::new("input")
             .long("input")
             .short('i')
             .takes_value(true)
             .use_delimiter(true)
             .value_name("INPUT_VALUES"))
        .arg(Arg::new("environment")
             .long("environment")
             .short('e')
             .takes_value(true)
             .value_name("ENVIRONMENT_NAME")
             .value_parser(PossibleValuesParser::new(["wasmi", "wasmtime"])))
        .arg(Arg::new("runtime")
             .default_value(DEFAULT_RUNTIME_PATH)
             .long("runtime")
             .short('r')
             .takes_value(true)
             .value_name("RUNTIME_PATH")
             .value_parser(value_parser!(PathBuf)));
}

pub fn process_subcommand(matches: &ArgMatches) {
    if let Some(func) = matches.get_one::<String>("function") {
        let input: ParsedInput = matches.values_of("input").into();

        let rtm_path = matches.get_one::<PathBuf>("runtime").unwrap();
        let mut rtm = utils::Runtime::new(rtm_path).with_offchain();

        if let Some(env) = matches.value_of("environment") {
            match env {
                "wasmi" => rtm = rtm.using_wasmi(),
                "wasmtime" => rtm = rtm.using_wasmtime(),
                _ => unreachable!(), // Clap should not allow other values
            }
        }

        match func.as_str() {
            // storage api
            "test_storage_init" => storage::test_storage_init(rtm),
            "ext_storage_set_version_1" => storage::ext_storage_set_version_1(rtm, input),
            "ext_storage_get_version_1" => storage::ext_storage_get_version_1(rtm, input),
            "ext_storage_read_version_1" => storage::ext_storage_read_version_1(rtm, input),
            "ext_storage_clear_version_1" => storage::ext_storage_clear_version_1(rtm, input),
            "ext_storage_exists_version_1" => storage::ext_storage_exists_version_1(rtm, input),
            "ext_storage_clear_prefix_version_1" => {
                storage::ext_storage_clear_prefix_version_1(rtm, input)
            }
            "ext_storage_append_version_1" => storage::ext_storage_append_version_1(rtm, input),
            "ext_storage_root_version_1" => storage::ext_storage_root_version_1(rtm, input),
            "ext_storage_next_key_version_1" => storage::ext_storage_next_key_version_1(rtm, input),
            "ext_storage_set_version_1_with_child_key" => storage::ext_storage_set_version_1_with_child_key(rtm, input),

            // child storage api
            "ext_default_child_storage_set_version_1" => {
                child_storage::ext_default_child_storage_set_version_1(rtm, input)
            }
            "ext_default_child_storage_get_version_1" => {
                child_storage::ext_default_child_storage_get_version_1(rtm, input)
            }
            "ext_default_child_storage_read_version_1" => {
                child_storage::ext_default_child_storage_read_version_1(rtm, input)
            }
            "ext_default_child_storage_clear_version_1" => {
                child_storage::ext_default_child_storage_clear_version_1(rtm, input)
            }
            "ext_default_child_storage_storage_kill_version_1" => {
                child_storage::ext_default_child_storage_storage_kill_version_1(rtm, input)
            }
            "ext_default_child_storage_exists_version_1" => {
                child_storage::ext_default_child_storage_exists_version_1(rtm, input)
            }
            "ext_default_child_storage_clear_prefix_version_1" => {
                child_storage::ext_default_child_storage_clear_prefix_version_1(rtm, input)
            }
            "ext_default_child_storage_root_version_1" => {
                child_storage::ext_default_child_storage_root_version_1(rtm, input)
            }
            "ext_default_child_storage_next_key_version_1" => {
                child_storage::ext_default_child_storage_next_key_version_1(rtm, input)
            }

            // crypto api
            "ext_crypto_ed25519_public_keys_version_1" => {
                crypto::ext_crypto_ed25519_public_keys_version_1(rtm, input)
            }
            "ext_crypto_ed25519_generate_version_1" => {
                crypto::ext_crypto_ed25519_generate_version_1(rtm, input)
            }
            "ext_crypto_ed25519_sign_version_1" => {
                crypto::ext_crypto_ed25519_sign_version_1(rtm, input)
            }
            "ext_crypto_ed25519_verify_version_1" => {
                crypto::ext_crypto_ed25519_verify_version_1(rtm, input)
            }
            "ext_crypto_sr25519_public_keys_version_1" => {
                crypto::ext_crypto_sr25519_public_keys_version_1(rtm, input)
            }
            "ext_crypto_sr25519_generate_version_1" => {
                crypto::ext_crypto_sr25519_generate_version_1(rtm, input)
            }
            "ext_crypto_sr25519_sign_version_1" => {
                crypto::ext_crypto_sr25519_sign_version_1(rtm, input)
            }
            "ext_crypto_sr25519_verify_version_1" => {
                crypto::ext_crypto_sr25519_verify_version_1(rtm, input)
            }

            // hashing api
            "ext_hashing_blake2_128_version_1" => {
                hashing::ext_hashing_version_1(rtm, "blake2_128", input)
            }
            "ext_hashing_blake2_256_version_1" => {
                hashing::ext_hashing_version_1(rtm, "blake2_256", input)
            }
            "ext_hashing_keccak_256_version_1" => {
                hashing::ext_hashing_version_1(rtm, "keccak_256", input)
            }
            "ext_hashing_sha2_256_version_1" => {
                hashing::ext_hashing_version_1(rtm, "sha2_256", input)
            }
            "ext_hashing_twox_64_version_1" => {
                hashing::ext_hashing_version_1(rtm, "twox_64", input)
            }
            "ext_hashing_twox_128_version_1" => {
                hashing::ext_hashing_version_1(rtm, "twox_128", input)
            }
            "ext_hashing_twox_256_version_1" => {
                hashing::ext_hashing_version_1(rtm, "twox_256", input)
            }

            // allocator api
            "ext_allocator_malloc_version_1" => {
                allocator::ext_allocator_malloc_version_1(rtm, input)
            }
            "ext_allocator_free_version_1" => allocator::ext_allocator_free_version_1(rtm, input),

            // trie api
            "ext_trie_blake2_256_root_version_1" => {
                trie::ext_trie_blake2_256_root_version_1(rtm, input)
            }
            "ext_trie_blake2_256_ordered_root_version_1" => {
                trie::ext_trie_blake2_256_ordered_root_version_1(rtm, input)
            }

            // offhchain api
            "ext_offchain_is_validator_version_1" => offchain::ext_offchain_is_validator_version_1(rtm, input),
            "ext_offchain_submit_transaction_version_1" => offchain::ext_offchain_submit_transaction_version_1(rtm, input),
            "ext_offchain_network_state_version_1" => offchain::ext_offchain_network_state_version_1(rtm, input),
            "ext_offchain_timestamp_version_1" => offchain::ext_offchain_timestamp_version_1(rtm, input),
            "ext_offchain_sleep_until_version_1" => offchain::ext_offchain_sleep_until_version_1(rtm, input),
            "ext_offchain_random_seed_version_1" => offchain::ext_offchain_random_seed_version_1(rtm, input),
            "ext_offchain_local_storage_set_version_1" => offchain::ext_offchain_local_storage_set_version_1(rtm, input),
            "ext_offchain_local_storage_clear_version_1" => offchain::ext_offchain_local_storage_clear_version_1(rtm, input),
            "ext_offchain_local_storage_compare_and_set_version_1" => offchain::ext_offchain_local_storage_compare_and_set_version_1(rtm, input),
            "ext_offchain_local_storage_get_version_1" => offchain::ext_offchain_local_storage_get_version_1(rtm, input),
            /*
            "ext_offchain_http_request_start_version_1" => offchain::ext_offchain_http_request_start_version_1(rtm, input),
            "ext_offchain_http_request_add_header_version_1" => offchain::ext_offchain_http_request_add_header_version_1(rtm, input),
            "ext_offchain_http_request_write_body_version_1" => offchain::ext_offchain_http_request_write_body_version_1(rtm, input),
            "ext_offchain_http_response_wait_version_1" => offchain::ext_offchain_http_response_wait_version_1(rtm, input),
            "ext_offchain_http_response_headers_version_1" => offchain::ext_offchain_http_response_headers_version_1(rtm, input),
            "ext_offchain_http_response_read_body_version_1" => offchain::ext_offchain_http_response_read_body_version_1(rtm, input),
            */

            _ => panic!("specified function not available"),
        }
    }
}
