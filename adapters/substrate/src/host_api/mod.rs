mod allocator;
mod child_storage;
mod crypto;
mod hashing;
mod storage;
mod trie;
mod utils;

use std::path::Path;

use clap::ArgMatches;
use utils::ParsedInput;

const DEFAULT_RUNTIME_PATH: &str = "bin/hostapi_runtime.compact.wasm";

pub fn process_host_api_tests(subcmd_matches: &ArgMatches) {
    if let Some(func) = subcmd_matches.value_of("function") {
        let input : ParsedInput = subcmd_matches.values_of("input").into();

        let rtm_path = subcmd_matches.value_of("runtime").unwrap_or(DEFAULT_RUNTIME_PATH);
        let mut rtm = utils::Runtime::new(Path::new(rtm_path));

        if let Some(env) = subcmd_matches.value_of("environment") {
            match env {
                "wasmi" => rtm = rtm.using_wasmi(),
                "wasmtime" => rtm = rtm.using_wasmtime(),
                _ => unreachable!(), // Clap should not allow other values
            }
        }

        match func {
            // storage api
            "test_storage_init"                  => storage::test_storage_init(rtm),
            "ext_storage_set_version_1"          => storage::ext_storage_set_version_1(rtm, input),
            "ext_storage_get_version_1"          => storage::ext_storage_get_version_1(rtm, input),
            "ext_storage_read_version_1"         => storage::ext_storage_read_version_1(rtm, input),
            "ext_storage_clear_version_1"        => storage::ext_storage_clear_version_1(rtm, input),
            "ext_storage_exists_version_1"       => storage::ext_storage_exists_version_1(rtm, input),
            "ext_storage_clear_prefix_version_1" => storage::ext_storage_clear_prefix_version_1(rtm, input),
            "ext_storage_append_version_1"       => storage::ext_storage_append_version_1(rtm, input),
            "ext_storage_root_version_1"         => storage::ext_storage_root_version_1(rtm, input),
            "ext_storage_next_key_version_1"     => storage::ext_storage_next_key_version_1(rtm, input),

            // child storage api
            "ext_default_child_storage_set_version_1" => child_storage::ext_default_child_storage_set_version_1(rtm, input),
            "ext_default_child_storage_get_version_1" => child_storage::ext_default_child_storage_get_version_1(rtm, input),
            "ext_default_child_storage_read_version_1" => child_storage::ext_default_child_storage_read_version_1(rtm, input),
            "ext_default_child_storage_clear_version_1" => child_storage::ext_default_child_storage_clear_version_1(rtm, input),
            "ext_default_child_storage_storage_kill_version_1" => child_storage::ext_default_child_storage_storage_kill_version_1(rtm, input),
            "ext_default_child_storage_exists_version_1" => child_storage::ext_default_child_storage_exists_version_1(rtm, input),
            "ext_default_child_storage_clear_prefix_version_1" => child_storage::ext_default_child_storage_clear_prefix_version_1(rtm, input),
            "ext_default_child_storage_root_version_1" => child_storage::ext_default_child_storage_root_version_1(rtm, input),
            "ext_default_child_storage_next_key_version_1" => child_storage::ext_default_child_storage_next_key_version_1(rtm, input),

            // crypto api
            "ext_crypto_ed25519_public_keys_version_1" => crypto::ext_crypto_ed25519_public_keys_version_1(rtm, input),
            "ext_crypto_ed25519_generate_version_1" => crypto::ext_crypto_ed25519_generate_version_1(rtm, input),
            "ext_crypto_ed25519_sign_version_1" => crypto::ext_crypto_ed25519_sign_version_1(rtm, input),
            "ext_crypto_ed25519_verify_version_1" => crypto::ext_crypto_ed25519_verify_version_1(rtm, input),
            "ext_crypto_sr25519_public_keys_version_1" => crypto::ext_crypto_sr25519_public_keys_version_1(rtm, input),
            "ext_crypto_sr25519_generate_version_1" => crypto::ext_crypto_sr25519_generate_version_1(rtm, input),
            "ext_crypto_sr25519_sign_version_1" => crypto::ext_crypto_sr25519_sign_version_1(rtm, input),
            "ext_crypto_sr25519_verify_version_1" => crypto::ext_crypto_sr25519_verify_version_1(rtm, input),

            // hashing api
            "ext_hashing_blake2_128_version_1" => hashing::ext_hashing_version_1(rtm, "blake2_128", input),
            "ext_hashing_blake2_256_version_1" => hashing::ext_hashing_version_1(rtm, "blake2_256", input),
            "ext_hashing_keccak_256_version_1" => hashing::ext_hashing_version_1(rtm, "keccak_256", input),
            "ext_hashing_sha2_256_version_1"   => hashing::ext_hashing_version_1(rtm, "sha2_256", input),
            "ext_hashing_twox_64_version_1"    => hashing::ext_hashing_version_1(rtm, "twox_64", input),
            "ext_hashing_twox_128_version_1"   => hashing::ext_hashing_version_1(rtm, "twox_128", input),
            "ext_hashing_twox_256_version_1"   => hashing::ext_hashing_version_1(rtm, "twox_256", input),

            // allocator api
            "ext_allocator_malloc_version_1" => allocator::ext_allocator_malloc_version_1(rtm, input),
            "ext_allocator_free_version_1" => allocator::ext_allocator_free_version_1(rtm, input),

            // trie api
            "ext_trie_blake2_256_root_version_1" => trie::ext_trie_blake2_256_root_version_1(rtm, input),
            "ext_trie_blake2_256_ordered_root_version_1" => trie::ext_trie_blake2_256_ordered_root_version_1(rtm, input),

            _ => panic!("specified function not available"),
        }
    }
}
