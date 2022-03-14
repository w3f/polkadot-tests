use crate::host_api::utils::{str, ParsedInput, Runtime};
use parity_scale_codec::Encode;

pub fn ext_offchain_is_validator_version_1(mut rtm: Runtime) {
	let res = rtm.call_and_decode::<bool>(
		"rtm_ext_offchain_is_validator_version_1", &[]
	);

	println!("{}", res);
}

pub fn ext_offchain_submit_transaction_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_network_state_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_timestamp_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_sleep_until_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_random_seed_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_local_storage_set_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_local_storage_clear_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_local_storage_compare_and_set_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_local_storage_get_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_http_request_start_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_http_request_add_header_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_http_request_write_body_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_http_response_wait_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_http_response_headers_version_1(mut rtm: Runtime) {

}

pub fn ext_offchain_http_response_read_body_version_1(mut rtm: Runtime) {

}
