use crate::host_api::utils::{str, ParsedInput, Runtime};
use parity_scale_codec::Encode;

/// The Wasm function tests both the allocation and freeing of the buffer
pub fn ext_allocator_malloc_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let value = input.get(0);

    // Get invalid key
    let res = rtm.call_and_decode::<Vec<u8>>("rtm_ext_allocator_malloc_version_1", &value.encode());
    assert_eq!(res, value);

    println!("{}", str(&res));
}

pub fn ext_allocator_free_version_1(rtm: Runtime, input: ParsedInput) {
    ext_allocator_malloc_version_1(rtm, input)
}
