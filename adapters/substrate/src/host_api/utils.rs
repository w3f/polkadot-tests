use clap::Values;

use std::path::Path;
use std::fs::File;
use std::io::Read;
use std::sync::Arc;
use parity_scale_codec::Decode;
use sc_executor::{
    WasmExecutor,
    WasmExecutionMethod,
};
use sc_executor_common::runtime_blob::RuntimeBlob;
use sp_io::SubstrateHostFunctions;
use sp_core::{
    offchain::testing::TestOffchainExt,
    offchain::OffchainWorkerExt,
    Blake2Hasher,
};
use sp_keystore::{KeystoreExt, testing::KeyStore};
use sp_state_machine::TestExternalities;


pub fn str<'a>(input: &'a [u8]) -> &'a str {
    std::str::from_utf8(input).unwrap()
}

// Helper to pass and parse function inputs
pub struct ParsedInput<'a>(Vec<&'a str>);

impl<'a> ParsedInput<'a> {
    pub fn get(&self, index: usize) -> &[u8] {
        if let Some(ret) = self.0.get(index) {
            ret.as_bytes()
        } else {
            panic!("failed to get index, wrong input data provided for the test function");
        }
    }
    pub fn get_u32(&self, index: usize) -> u32 {
        if let Some(ret) = self.0.get(index) {
            ret.parse().expect("failed to parse parameter as u32")
        } else {
            panic!("failed to get index, wrong input data provided for the test function");
        }
    }
}

impl<'a> From<Values<'a>> for ParsedInput<'a> {
    fn from(input: Values<'a>) -> Self {
        ParsedInput(input.collect())
    }
}

impl<'a> From<Option<Values<'a>>> for ParsedInput<'a> {
    fn from(input: Option<Values<'a>>) -> Self {
        match input {
            Some(v) => ParsedInput(v.collect()),
            None => ParsedInput(Vec::new()),
        }
    }
}

// Helpers to configure and call into runtime environment
pub struct Runtime {
    blob: Vec<u8>,
    ext: TestExternalities<Blake2Hasher>,
    method: WasmExecutionMethod,
}

impl Runtime {
    pub fn new(path: &Path) -> Self {
        let mut wasm_binary = Vec::new();

        let _ = File::open(path).unwrap()
            .read_to_end(&mut wasm_binary).unwrap();

        Runtime {
            blob: wasm_binary,
            ext: TestExternalities::default(),
            method: WasmExecutionMethod::Interpreted,
        }
    }

    pub fn using_wasmi(mut self) -> Self {
        self.method = WasmExecutionMethod::Interpreted;
        self
    }
    pub fn using_wasmtime(mut self) -> Self {
        self.method = WasmExecutionMethod::Compiled;
        self
    }

    pub fn with_keystore(mut self) -> Self {
        let key_store = KeystoreExt(Arc::new(KeyStore::new()));
        self.ext.register_extension(key_store);
        self
    }
    #[allow(dead_code)]
    pub fn with_offchain(mut self) -> Self {
        let (offchain, _) = TestOffchainExt::new();
        self.ext.register_extension(OffchainWorkerExt::new(offchain));
        self
    }

    pub fn call(&mut self, func: &str, args: &[u8]) -> Vec<u8> {
        let mut extext = self.ext.ext();

        WasmExecutor::<SubstrateHostFunctions>::new(
            self.method,
            Some(8), // heap_pages
            8, // max_runtime_instances
            None, // cache_path
            2, // runtime_cache_size
        ).uncached_call(
            RuntimeBlob::uncompress_if_needed(&self.blob[..]).unwrap(),
            &mut extext,
            false, // allow_missing_host_functions
            func,
            args
        ).unwrap()
    }
    pub fn call_and_decode<T: Decode>(&mut self, func: &str, args: &[u8]) -> T {
        Decode::decode(&mut self.call(func, args).as_slice())
            .expect("Failed to decode returned SCALE data")
    }
}
