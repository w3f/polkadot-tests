use crate::host_api::utils::{str, ParsedInput, Runtime};
use parity_scale_codec::Encode;

pub fn ext_offchain_is_validator_version_1(mut rtm: Runtime, input: ParsedInput) {
	let res = rtm.call_and_decode::<bool>(
		"rtm_ext_offchain_is_validator_version_1", &[]
	);

	assert_eq!(res, false);
	println!("{}", res);
}
