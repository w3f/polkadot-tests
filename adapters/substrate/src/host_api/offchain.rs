use crate::host_api::utils::{str, ParsedInput, Runtime};
use parity_scale_codec::{Encode, Decode};

#[derive(Debug, Decode)]
struct OpaqueNetworkState {
	_peer_id: Vec<u8>,
	_addresses: Vec<Vec<u8>>,
}

pub fn ext_offchain_is_validator_version_1(mut rtm: Runtime, _input: ParsedInput) {
	let res = rtm.call_and_decode::<bool>(
		"rtm_ext_offchain_is_validator_version_1", &[]
	);

	// Always returns `true`.
	println!("{}", res);
}

pub fn ext_offchain_submit_transaction_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}

pub fn ext_offchain_network_state_version_1(mut rtm: Runtime, _input: ParsedInput) {
	let res = rtm.call_and_decode::<Result<OpaqueNetworkState, ()>>(
		"rtm_ext_offchain_is_validator_version_1", &[]
	);

	// Always returns `Err(())`.
	println!("{:?}", res);
}

pub fn ext_offchain_timestamp_version_1(mut rtm: Runtime, _input: ParsedInput) {
	let res = rtm.call_and_decode::<u64>(
		"rtm_ext_offchain_timestamp_version_1", &[]
	);

	// Always returns `0`.
	println!("{:?}", res);
}

pub fn ext_offchain_sleep_until_version_1(mut rtm: Runtime, _input: ParsedInput) {
	use std::time::{SystemTime, UNIX_EPOCH};

	// Sleep for 5 seconds.
    let deadline = SystemTime::now()
        .duration_since(UNIX_EPOCH)
		.unwrap()
		.as_millis()
		+ 5_000;

	let _res = rtm.call_and_decode::<()>(
		"rtm_ext_offchain_sleep_until_version_1", &(deadline).encode()
	);
}

pub fn ext_offchain_random_seed_version_1(mut rtm: Runtime, _input: ParsedInput) {
	let res = rtm.call_and_decode::<Vec<u8>>(
		"rtm_ext_offchain_random_seed_version_1", &[]
	);

	// Always returns a zero value.
	assert_eq!(res, [0; 32]);
	println!("{:?}", res);
}

pub fn ext_offchain_local_storage_set_version_1(mut rtm: Runtime, input: ParsedInput) {
	// Parse input
    let kind = input.get_u32(0);
    let key = input.get(1);
    let value = input.get(2);

    // Get invalid key
    let res = rtm.call_and_decode::<Option<Vec<u8>>>(
        "rtm_ext_offchain_local_storage_get_version_1",
        &(kind, key).encode(),
    );
    assert!(res.is_none());

    // Set key/value
    let _ = rtm.call_and_decode::<()>(
        "rtm_ext_offchain_local_storage_set_version_1",
        &(kind, key, value).encode(),
    );

    // Get invalid key (different storage kind)
    let res = rtm.call_and_decode::<Option<Vec<u8>>>(
        "rtm_ext_offchain_local_storage_get_version_1",
        &(
            {
                if kind == 0 {
                    1
                } else if kind == 1 {
                    0
                } else {
                    panic!("Invalid storage kind")
                }
            },
            key,
        )
            .encode(),
    );
    assert!(res.is_none());

    // Get valid key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>(
            "rtm_ext_offchain_local_storage_get_version_1",
            &(kind, key).encode(),
        )
        .unwrap();
    assert_eq!(res, value);

	println!("{}", str(&res));
}

pub fn ext_offchain_local_storage_get_version_1(rtm: Runtime, input: ParsedInput) {
	ext_offchain_local_storage_set_version_1(rtm, input)
}

pub fn ext_offchain_local_storage_clear_version_1(mut rtm: Runtime, input: ParsedInput) {
	// Parse input
    let kind = input.get_u32(0);
    let key = input.get(1);
    let value = input.get(2);

    // Set key/value
    let _ = rtm.call_and_decode::<()>(
        "rtm_ext_offchain_local_storage_set_version_1",
        &(kind, key, value).encode(),
    );

	// Clear invalid storage
    let _ = rtm
        .call_and_decode::<()>(
            "rtm_ext_offchain_local_storage_clear_version_1",
            &(
				{
					if kind == 0 {
						1
					} else if kind == 1 {
						0
					} else {
						panic!("Invalid storage kind")
					}
				},
				key
			).encode(),
        );

    // Get valid key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>(
            "rtm_ext_offchain_local_storage_get_version_1",
            &(kind, key).encode(),
        ).unwrap();
    assert_eq!(res, value);

	// Clear valid storage
    let _ = rtm
        .call_and_decode::<()>(
            "rtm_ext_offchain_local_storage_clear_version_1",
            &(kind, key).encode(),
        );

    // Get invalid (cleared) key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>(
            "rtm_ext_offchain_local_storage_get_version_1",
            &(kind, key).encode(),
        );
    assert!(res.is_none());
}

pub fn ext_offchain_local_storage_compare_and_set_version_1(mut rtm: Runtime, input: ParsedInput) {
	// Parse input
    let kind = input.get_u32(0);
    let key = input.get(1);
    let old_value = input.get(2);
    let new_value = input.get(3);

    // Set key/value
    let _ = rtm.call_and_decode::<u32>(
        "rtm_ext_offchain_local_storage_compare_and_set_version_1",
        &(kind, key, Option::<Vec<u8>>::None, old_value).encode(),
    );

	// Compare and set (old value does not match current value)
    let res = rtm.call_and_decode::<u32>(
        "rtm_ext_offchain_local_storage_compare_and_set_version_1",
        &(kind, key, Some(new_value), old_value).encode(),
    );
	assert_eq!(res, 0); // value was not replaced

    // Get current/old value
    let res = rtm.call_and_decode::<Option<Vec<u8>>>(
        "rtm_ext_offchain_local_storage_get_version_1",
        &(kind, key).encode(),
    ).unwrap();
	assert_eq!(res, old_value);

	// Compare and set of invalid storage kind
    let res = rtm.call_and_decode::<u32>(
        "rtm_ext_offchain_local_storage_compare_and_set_version_1",
        &(
			{
                if kind == 0 {
                    1
                } else if kind == 1 {
                    0
                } else {
                    panic!("Invalid storage kind")
                }
			},
			key, Some(old_value), new_value).encode(),
    );
	assert_eq!(res, 0); // value was not replaced;

	// Compare and set (old value DOES match current value)
    let res = rtm.call_and_decode::<u32>(
        "rtm_ext_offchain_local_storage_compare_and_set_version_1",
        &(kind, key, Some(old_value), new_value).encode(),
    );
	assert_eq!(res, 1); //value WAS replaced

    // Get new value
    let res = rtm.call_and_decode::<Option<Vec<u8>>>(
        "rtm_ext_offchain_local_storage_get_version_1",
        &(kind, key).encode(),
    ).unwrap();
	assert_eq!(res, new_value);

	println!("{}", str(&res));
}

#[allow(dead_code)]
pub fn ext_offchain_http_request_start_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}

#[allow(dead_code)]
pub fn ext_offchain_http_request_add_header_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}

#[allow(dead_code)]
pub fn ext_offchain_http_request_write_body_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}

#[allow(dead_code)]
pub fn ext_offchain_http_response_wait_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}

#[allow(dead_code)]
pub fn ext_offchain_http_response_headers_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}

#[allow(dead_code)]
pub fn ext_offchain_http_response_read_body_version_1(_rtm: Runtime, _input: ParsedInput) {
	unimplemented!()
}
