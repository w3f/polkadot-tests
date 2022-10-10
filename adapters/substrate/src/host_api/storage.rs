use crate::host_api::utils::{str, ParsedInput, Runtime};
use parity_scale_codec::{Decode, Encode};

pub fn test_storage_init(mut rtm: Runtime) {
    // Compute and print storage root on init
    let res = rtm.call_and_decode::<Vec<u8>>("rtm_ext_storage_root_version_1", &[]);

    println!("{}", hex::encode(res));
}

pub fn ext_storage_set_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key = input.get(0);
    let value = input.get(1);

    // Get invalid key
    let res =
        rtm.call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key.encode());
    assert!(res.is_none());

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key, value).encode());

    // Get valid key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key.encode())
        .unwrap();
    assert_eq!(res, value);

    println!("{}", str(&res));
}

pub fn ext_storage_get_version_1(rtm: Runtime, input: ParsedInput) {
    ext_storage_set_version_1(rtm, input)
}

pub fn ext_storage_read_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key = input.get(0);
    let value = input.get(1);
    let offset = input.get_u32(2);
    let buffer_size = input.get_u32(3);

    // Get invalid key
    let res = rtm.call_and_decode::<Option<Vec<u8>>>(
        "rtm_ext_storage_read_version_1",
        &(key, offset, buffer_size).encode(),
    );
    assert!(res.is_none());

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key, value).encode());

    // Get valid key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>(
            "rtm_ext_storage_read_version_1",
            &(key, offset, buffer_size).encode(),
        )
        .unwrap();

    let offset = offset as usize;
    let buffer_size = buffer_size as usize;

    if offset < value.len() {
        let end = std::cmp::min(offset + buffer_size, value.len());

        assert_eq!(res, value[offset..end].to_vec());
    } else {
        assert!(res.is_empty())
    }

    println!("{}", str(&res));
}

pub fn ext_storage_clear_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key = input.get(0);
    let value = input.get(1);

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key, value).encode());
    let _ = rtm.call("rtm_ext_storage_clear_version_1", &key.encode());

    // Get cleared value
    let res =
        rtm.call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key.encode());
    assert!(res.is_none());
}

pub fn ext_storage_exists_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key = input.get(0);
    let value = input.get(1);

    // Check if key exists (invalid)
    let res = rtm.call_and_decode::<bool>("rtm_ext_storage_exists_version_1", &(key).encode());
    assert_eq!(res, false);

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key, value).encode());

    // Check if key exists
    let res = rtm.call_and_decode::<bool>("rtm_ext_storage_exists_version_1", &(key).encode());
    assert_eq!(res, true);
    println!("true");
}

pub fn ext_storage_clear_prefix_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let prefix = input.get(0);
    let key1 = input.get(1);
    let value1 = input.get(2);
    let key2 = input.get(3);
    let value2 = input.get(4);

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key1, value1).encode());
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key2, value2).encode());
    let _ = rtm.call("rtm_ext_storage_clear_prefix_version_1", &prefix.encode());

    // Check first key
    let res =
        rtm.call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key1.encode());
    if key1.starts_with(prefix) {
        assert!(res.is_none());
    } else {
        assert_eq!(res.unwrap(), value1);
    }

    // Check second key
    let res =
        rtm.call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key2.encode());
    if key2.starts_with(prefix) {
        assert!(res.is_none());
    } else {
        assert_eq!(res.unwrap(), value2);
    }
}

pub fn ext_storage_append_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key1 = input.get(0);
    let value1 = input.get(1);
    let key2 = input.get(2);
    let value2 = input.get(3);

    let value1_enc = &value1.encode();
    let value2_enc = &value2.encode();

    // Insert first key
    let res =
        rtm.call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key1.encode());
    assert!(res.is_none());

    let _ = rtm.call(
        "rtm_ext_storage_append_version_1",
        &(key1, value1_enc).encode(),
    );
    let _ = rtm.call(
        "rtm_ext_storage_append_version_1",
        &(key1, value2_enc).encode(),
    );

    // Insert second key
    let res =
        rtm.call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key2.encode());
    assert!(res.is_none());

    let _ = rtm.call(
        "rtm_ext_storage_append_version_1",
        &(key2, value2_enc).encode(),
    );
    let _ = rtm.call(
        "rtm_ext_storage_append_version_1",
        &(key2, value1_enc).encode(),
    );
    let _ = rtm.call(
        "rtm_ext_storage_append_version_1",
        &(key2, value2_enc).encode(),
    );
    let _ = rtm.call(
        "rtm_ext_storage_append_version_1",
        &(key2, value1_enc).encode(),
    );

    // Check first key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key1.encode())
        .unwrap();

    let res = Vec::<Vec<u8>>::decode(&mut res.as_slice()).unwrap();

    assert_eq!(res, vec![value1, value2]);
    println!(
        "{}",
        res.iter()
            .map(|v| String::from_utf8(v.to_vec()).unwrap())
            .collect::<Vec::<String>>()
            .join(";")
    );

    // Check second key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &key2.encode())
        .unwrap();

    let res = Vec::<Vec<u8>>::decode(&mut res.as_slice()).unwrap();

    assert_eq!(res, vec![value2, value1, value2, value1]);
    println!(
        "{}",
        res.iter()
            .map(|v| String::from_utf8(v.to_vec()).unwrap())
            .collect::<Vec::<String>>()
            .join(";")
    );
}

pub fn ext_storage_root_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key1 = input.get(0);
    let value1 = input.get(1);
    let key2 = input.get(2);
    let value2 = input.get(3);

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key1, value1).encode());
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key2, value2).encode());

    // Get root
    let res = rtm.call_and_decode::<Vec<u8>>("rtm_ext_storage_root_version_1", &[]);

    println!("{}", hex::encode(res));
}

pub fn ext_storage_next_key_version_1(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let key1 = input.get(0);
    let value1 = input.get(1);
    let key2 = input.get(2);
    let value2 = input.get(3);

    // Keep track of the ordering of the keys
    let mut track = vec![];
    track.push(key1);
    track.push(key2);
    track.sort();

    // No next key available
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_next_key_version_1", &key1.encode());
    assert!(res.is_none());

    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_next_key_version_1", &key2.encode());
    assert!(res.is_none());

    // Set key/value
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key1, value1).encode());
    let _ = rtm.call("rtm_ext_storage_set_version_1", &(key2, value2).encode());

    // Try to read next key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_next_key_version_1", &key1.encode());

    if key1 == track[0] {
        assert_eq!(res.unwrap(), key2);
        println!("{}", str(&key2));
    } else {
        assert!(res.is_none());
    }

    // Try to read next key
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_next_key_version_1", &key2.encode());

    if key2 == track[0] {
        assert_eq!(res.unwrap(), key1);
        println!("{}", str(&key1));
    } else {
        assert!(res.is_none());
    }
}

pub fn ext_storage_set_version_1_with_child_key(mut rtm: Runtime, input: ParsedInput) {
    // Parse inputs
    let child_key = input.get(0);
    // Skipping index `1`
    let key = input.get(2);
    let value = input.get(3);

    // Set key/value
    let _ = rtm.call(
        "rtm_ext_default_child_storage_set_version_1",
        &(child_key, key, value).encode(),
    );

    // Get value
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>(
            "rtm_ext_default_child_storage_get_version_1",
            &(child_key, key).encode(),
        )
        .unwrap();

    assert_eq!(res, value);

    // Try to get value of child storage key itself
    let res = rtm
        .call_and_decode::<Option<Vec<u8>>>("rtm_ext_storage_get_version_1", &child_key.encode());

    assert!(res.is_none());
}