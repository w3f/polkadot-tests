//! Contains wrappers for the calls to the Wasm blob (Runtime) APIs related to crypto functionality.
//! Those wrappers are specific to the Parity Substrate `WasmExecutor` implementation.
//!
//! Not relevant for other implementators. Look at the `tests/` directory for the acutal tests.

use super::{get_wasm_blob, wrap, copy, CallWasm};

use substrate_executor::error::Error;
use substrate_executor::WasmExecutor;
use substrate_primitives::testing::KeyStore;
use substrate_primitives::Blake2Hasher;
use substrate_state_machine::TestExternalities as CoreTestExternalities;
use wasmi::RuntimeValue::I32;

use std::cell::RefCell;
use std::rc::Rc;

type TestExternalities<H> = CoreTestExternalities<H, u64>;

pub struct CryptoApi {
    blob: Vec<u8>,
    ext: TestExternalities<Blake2Hasher>,
}

impl CryptoApi {
    pub fn new() -> Self {
        let mut ext = TestExternalities::default();
        ext.set_keystore(KeyStore::new());
        CryptoApi {
            blob: get_wasm_blob(),
            ext: ext,
        }
    }
    fn prep_wasm<'a>(&'a mut self, method: &'a str) -> CallWasm<'a> {
        CallWasm::new(&mut self.ext, &self.blob, method)
    }
    fn common_hash_fn_handler(&mut self, method: &str, data: &[u8], output: &mut [u8]) {
        let mut wasm = self.prep_wasm(method);

        let ptr = wrap(0);
        let output_scoped = wrap(vec![0;output.len()]);

        let _ = wasm.call(
            CallWasm::with_data_output_ptr(data, output, ptr.clone()),
            CallWasm::return_none_write_buffer(output_scoped.clone(), ptr)
        );

        copy(output_scoped, output);
    }
    pub fn rtm_ext_blake2_128(&mut self, data: &[u8], output: &mut [u8]) {
        self.common_hash_fn_handler("test_ext_blake2_128", data, output)
    }
    pub fn rtm_ext_blake2_256(&mut self, data: &[u8], output: &mut [u8]) {
        self.common_hash_fn_handler("test_ext_blake2_256", data, output)
    }
    pub fn rtm_ext_twox_64(&mut self, data: &[u8], output: &mut [u8]) {
        self.common_hash_fn_handler("test_ext_twox_64", data, output)
    }
    pub fn rtm_ext_twox_128(&mut self, data: &[u8], output: &mut [u8]) {
        self.common_hash_fn_handler("test_ext_twox_128", data, output)
    }
    pub fn rtm_ext_twox_256(&mut self, data: &[u8], output: &mut [u8]) {
        self.common_hash_fn_handler("test_ext_twox_256", data, output)
    }
    pub fn rtm_ext_keccak_256(&mut self, data: &[u8], output: &mut [u8]) {
        self.common_hash_fn_handler("test_ext_keccak_256", data, output)
    }
    pub fn rtm_ext_ed25519_generate(&mut self, id_data: &[u8], seed: &[u8], output: &mut [u8]) {
        let mut wasm = self.prep_wasm("test_ext_ed25519_generate");

        let ptr = wrap(0);
        let output_scoped = wrap(vec![0;output.len()]);

        let _ = wasm.call(
            CallWasm::with_2x_data_output_ptr(id_data, seed, output, ptr.clone()),
            CallWasm::return_none_write_buffer(output_scoped.clone(), ptr)
        );

        copy(output_scoped, output);
    }
    pub fn rtm_ext_ed25519_sign(
        &mut self,
        id_data: &[u8],
        pubkey_data: &[u8],
        msg_data: &[u8],
        output: &mut [u8],
    ) -> u32 {
        let mut wasm = self.prep_wasm("test_ext_ed25519_sign");

        let ptr = wrap(0);
        let output_scoped = wrap(vec![0;output.len()]);

        let res = wasm.call(
            CallWasm::gen_params(
                &[
                    id_data,
                    pubkey_data,
                    msg_data,
                    output,
                ],
                &[2],
                Some(ptr.clone())
            ),
            CallWasm::return_value_write_buffer(output_scoped.clone(), ptr)
        );

        copy(output_scoped, output);
        res.unwrap()
    }
    pub fn rtm_ext_ed25519_verify(
        &mut self,
        msg_data: &[u8],
        sig_data: &[u8],
        pubkey_data: &[u8],
    ) -> u32 {
        let mut wasm = self.prep_wasm("test_ext_ed25519_verify");

        let res = wasm.call(
            CallWasm::gen_params(
                &[
                    msg_data,
                    sig_data,
                    pubkey_data
                ],
                &[0],
                None
            ),
            CallWasm::return_value_no_buffer()
        );

        res.unwrap()
    }
    pub fn rtm_ext_ed25519_public_keys(&mut self, id_data: &[u8], result_len: &mut u32) -> Vec<u8> {
        let mut wasm = self.prep_wasm("test_ext_ed25519_public_keys");
        let result_len_scoped = wrap(0);
        let ptr = wrap(0);

        let res = wasm.call(
            CallWasm::gen_params(
                &[
                    id_data,
                    &result_len.to_le_bytes(),
                ],
                &[],
                Some(ptr.clone())
            ),
            CallWasm::return_buffer(result_len_scoped.clone(), ptr)
        );

        *result_len = *result_len_scoped.borrow();
        res.unwrap()
    }
    pub fn rtm_ext_sr25519_generate(&mut self, id_data: &[u8], seed: &[u8], output: &mut [u8]) {
        let ptr_holder: Rc<RefCell<u32>> = Rc::new(RefCell::new(0));
        WasmExecutor::new()
            .call_with_custom_signature(
                &mut self.ext,
                1,
                &self.blob,
                "test_ext_sr25519_generate",
                |alloc| {
                    let id_data_offset = alloc(id_data)?;
                    let seed_offset = alloc(seed)?;
                    let output_offset = alloc(&[0, 32])?;
                    *ptr_holder.borrow_mut() = output_offset as u32;
                    Ok(vec![
                        I32(id_data_offset as i32),
                        I32(seed_offset as i32),
                        I32(seed.len() as i32),
                        I32(output_offset as i32),
                    ])
                },
                |_, memory| {
                    output.copy_from_slice(
                        memory
                            .get(*ptr_holder.borrow(), 32)
                            .map_err(|_| Error::Runtime)?
                            .as_slice(),
                    );
                    Ok(Some(()))
                },
            )
            .unwrap()
    }
    pub fn rtm_ext_sr25519_sign(
        &mut self,
        id_data: &[u8],
        pubkey_data: &[u8],
        msg_data: &[u8],
        output: &mut [u8],
    ) -> u32 {
        let ptr_holder: Rc<RefCell<u32>> = Rc::new(RefCell::new(0));
        WasmExecutor::new()
            .call_with_custom_signature(
                &mut self.ext,
                1,
                &self.blob,
                "test_ext_sr25519_sign",
                |alloc| {
                    let id_data_offset = alloc(id_data)?;
                    let pubkey_data_offset = alloc(pubkey_data)?;
                    let msg_data_offset = alloc(msg_data)?;
                    let output_offset = alloc(&[0, 64])?;
                    *ptr_holder.borrow_mut() = output_offset as u32;
                    Ok(vec![
                        I32(id_data_offset as i32),
                        I32(pubkey_data_offset as i32),
                        I32(msg_data_offset as i32),
                        I32(msg_data.len() as i32),
                        I32(output_offset as i32),
                    ])
                },
                |res, memory| {
                    if let Some(I32(r)) = res {
                        output.copy_from_slice(
                            memory
                                .get(*ptr_holder.borrow(), 64)
                                .map_err(|_| Error::Runtime)?
                                .as_slice(),
                        );

                        Ok(Some(r as u32))
                    } else {
                        Ok(None)
                    }
                },
            )
            .unwrap()
    }
    pub fn rtm_ext_sr25519_verify(
        &mut self,
        msg_data: &[u8],
        sig_data: &[u8],
        pubkey_data: &[u8],
    ) -> u32 {
        WasmExecutor::new()
            .call_with_custom_signature(
                &mut self.ext,
                1,
                &self.blob,
                "test_ext_sr25519_verify",
                |alloc| {
                    let msg_data_offset = alloc(msg_data)?;
                    let sig_data_offset = alloc(sig_data)?;
                    let pubkey_data_offset = alloc(pubkey_data)?;
                    Ok(vec![
                        I32(msg_data_offset as i32),
                        I32(msg_data.len() as i32),
                        I32(sig_data_offset as i32),
                        I32(pubkey_data_offset as i32),
                    ])
                },
                |res, _| {
                    if let Some(I32(r)) = res {
                        Ok(Some(r as u32))
                    } else {
                        Ok(None)
                    }
                },
            )
            .unwrap()
    }
    pub fn rtm_ext_sr25519_public_keys(&mut self, id_data: &[u8], result_len: &mut u32) -> Vec<u8> {
        let ptr_holder: Rc<RefCell<u32>> = Rc::new(RefCell::new(0));
        WasmExecutor::new()
            .call_with_custom_signature(
                &mut self.ext,
                1,
                &self.blob,
                "test_ext_sr25519_public_keys",
                |alloc| {
                    let id_data_offset = alloc(id_data)?;
                    let result_len_offset = alloc(&[0, 4])?;
                    *ptr_holder.borrow_mut() = result_len_offset as u32;
                    Ok(vec![
                        I32(id_data_offset as i32),
                        I32(result_len_offset as i32),
                    ])
                },
                |res, memory| {
                    use std::convert::TryInto;
                    if let Some(I32(r)) = res {
                        *result_len = u32::from_le_bytes(
                            memory
                                .get(*ptr_holder.borrow(), 4)
                                .unwrap()
                                .as_slice()
                                .split_at(4)
                                .0
                                .try_into()
                                .unwrap(),
                        );

                        memory
                            .get(r as u32, *result_len as usize)
                            .map_err(|_| Error::Runtime)
                            .map(Some)
                    } else {
                        Ok(None)
                    }
                },
            )
            .unwrap()
    }
}
