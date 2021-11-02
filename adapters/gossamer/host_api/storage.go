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

package host_api

import (
	"bytes"
	"errors"
	"fmt"
	"strings"

	"github.com/ChainSafe/gossamer/lib/runtime"
	"github.com/ChainSafe/gossamer/pkg/scale"
)

// -- Helpers --

// Helper function to call rtm_ext_storage_set_version_1
func storage_set(r runtime.Instance, key, value []byte) error {
	// Encode inputs
	key_enc, err := scale.Marshal(key)
	if err != nil {
		return fmt.Errorf("Encoding key failed: %w", err)
	}

	value_enc, err := scale.Marshal(value)
	if err != nil {
		return fmt.Errorf("Encoding value failed: %w", err)
	}

	// Set key to value
	_, err = r.Exec("rtm_ext_storage_set_version_1", append(key_enc, value_enc...))
	if err != nil {
		return fmt.Errorf("Execution failed: %w", err)
	}

	return nil
}

// Helper function to call rtm_ext_storage_get_version_1
func storage_get(r runtime.Instance, key []byte) (*[]byte, error) {
	// Encode inputs
	key_enc, err := scale.Marshal(key)
	if err != nil {
		return nil, fmt.Errorf("Encoding key failed: %w", err)
	}

	// Retrieve key
	value_enc, err := r.Exec("rtm_ext_storage_get_version_1", key_enc)
	if err != nil {
		return nil, fmt.Errorf("Execution failed: %w", err)
	}

	var value_opt *[]byte
	err = scale.Unmarshal(value_enc, &value_opt)
	if err != nil {
		return nil, fmt.Errorf("Decoding value failed: %w", err)
	}

	return value_opt, nil
}

// Helper function to call rtm_ext_storage_read_version_1
func storage_read(r runtime.Instance, key []byte, offset uint32, length uint32) (*[]byte, error) {
	// Encode inputs
	key_enc, err := scale.Marshal([]byte(key))
	if err != nil {
		return nil, fmt.Errorf("Encoding key failed: %w", err)
	}

	offset_enc, err := scale.Marshal(offset)
	if err != nil {
		return nil, fmt.Errorf("Encoding offset failed: %w", err)
	}

	length_enc, err := scale.Marshal(length)
	if err != nil {
		return nil, fmt.Errorf("Encoding length failed: %w", err)
	}

	args_enc := append(append(key_enc, offset_enc...), length_enc...)

	// Check that key has not been set
	value_enc, err := r.Exec("rtm_ext_storage_read_version_1", args_enc)
	if err != nil {
		return nil, fmt.Errorf("Execution failed: %w", err)
	}

	var value_opt *[]byte
	err = scale.Unmarshal(value_enc, &value_opt)
	if err != nil {
		return nil, fmt.Errorf("Decoding value failed: %w", err)
	}
	return value_opt, nil
}

// Helper function to call rtm_ext_storage_clear_version_1
func storage_clear(r runtime.Instance, key []byte) error {
	// Encode inputs
	key_enc, err := scale.Marshal([]byte(key))
	if err != nil {
		return fmt.Errorf("Encoding key failed: %w", err)
	}

	// Clear storage key
	_, err = r.Exec("rtm_ext_storage_clear_version_1", key_enc)
	if err != nil {
		return fmt.Errorf("Execution failed: %w", err)
	}

	return nil
}

// Helper function to call rtm_ext_storage_exists_version_1
func storage_exists(r runtime.Instance, key []byte) (uint32, error) {
	// Encode inputs
	key_enc, err := scale.Marshal(key)
	if err != nil {
		return 0, fmt.Errorf("Encoding key failed: %w", err)
	}

	// Retrieve status
	exists_enc, err := r.Exec("rtm_ext_storage_exists_version_1", key_enc)
	if err != nil {
		return 0, fmt.Errorf("Execution failed: %w", err)
	}

	var exists uint32
	err = scale.Unmarshal(exists_enc, &exists)
	if err != nil {
		return 0, fmt.Errorf("Decoding value failed: %w", err)
	}
	return exists, nil
}

// Helper function to call rtm_ext_storage_append_version_1
func storage_append(r runtime.Instance, key, value []byte) error {
	// Encode inputs
	key_enc, err := scale.Marshal(key)
	if err != nil {
		return fmt.Errorf("Encoding key failed: %w", err)
	}

	value_enc, err := scale.Marshal(value)
	if err != nil {
		return fmt.Errorf("Encoding value failed: %w", err)
	}

	// Append value to key
	_, err = r.Exec("rtm_ext_storage_append_version_1", append(key_enc, value_enc...))
	if err != nil {
		return fmt.Errorf("Execution failed: %w", err)
	}

	return nil
}

// Helper function to call rtm_ext_storage_root_version_1
func storage_root(r runtime.Instance) ([]byte, error) {
	// Retrieve current root
	root_enc, err := r.Exec("rtm_ext_storage_root_version_1", []byte{})
	if err != nil {
		return nil, fmt.Errorf("Execution failed: %w", err)
	}

	var root []byte
	err = scale.Unmarshal(root_enc, &root)
	if err != nil {
		return nil, fmt.Errorf("Decoding root failed: %w", err)
	}
	return root, nil
}

// Helper function to call rtm_ext_storage_next_key_version_1
func storage_next_key(r runtime.Instance, key []byte) (*[]byte, error) {
	// Encode inputs
	key_enc, err := scale.Marshal(key)
	if err != nil {
		return nil, fmt.Errorf("Encoding key failed: %w", err)
	}

	// Retrieve key
	value_enc, err := r.Exec("rtm_ext_storage_next_key_version_1", key_enc)
	if err != nil {
		return nil, fmt.Errorf("Execution failed: %w", err)
	}


	var value_opt *[]byte
	err = scale.Unmarshal(value_enc, &value_opt)
	if err != nil {
		return nil, fmt.Errorf("Decoding next key failed: %w", err)
	}
	return value_opt, nil
}

// -- Tests --

// Test for initial state of storage
func test_storage_init(r runtime.Instance) error {
	// Retrieve and print storage root
	hash, err := storage_root(r)
	if err != nil {
		return err
	}

	fmt.Printf("%x\n", hash[:])

	return nil
}

// Test for rtm_ext_storage_set_version_1 and rtm_ext_storage_get_version_1
func test_storage_set_get(r runtime.Instance, key, value string) error {
	// Get invalid key
	none, err := storage_get(r, []byte(key))
	if err != nil {
		return err
	}

	if none != nil {
		return fmt.Errorf("Key already exists: %s", *none)
	}

	// Set key to value
	err = storage_set(r, []byte(key), []byte(value))
	if err != nil {
		return err
	}

	// Get valid key
	some, err := storage_get(r, []byte(key))
	if err != nil {
		return err
	}

	if some == nil {
		return errors.New("Key is missing")
	}

	if !bytes.Equal(*some, []byte(value)) {
		return fmt.Errorf("Value is different: %s", *some)
	}

	// Print result
	fmt.Printf("%s\n", *some)

	return nil
}

// Test for rtm_ext_storage_read_version_1
func test_storage_read(r runtime.Instance, key, value string, offset, length uint32) error {
	// Check that key has not been set
	none, err := storage_read(r, []byte(key), offset, length)
	if err != nil {
		return err
	}

	if none != nil {
		return fmt.Errorf("Key already exists: %s", *none)
	}

	// Add data to storage
	err = storage_set(r, []byte(key), []byte(value))
	if err != nil {
		return err
	}

	// Retrieve and check returned data
	some, err := storage_read(r, []byte(key), offset, length)
	if err != nil {
		return err
	}

	if some == nil {
		return errors.New("Key is missing")
	}

	if int(offset) < len(value) {
		expected_length := len(value) - int(offset)
		if expected_length > int(length) {
			expected_length = int(length)
		}
		expected_value := value[offset:int(offset)+expected_length]

		if !bytes.Equal(*some, []byte(expected_value)) {
			return fmt.Errorf("Value is different: %s", *some)
		}
	} else if len(*some) != 0 {
		return fmt.Errorf("Value is not empty: %s", *some)
	}

	fmt.Printf("%s\n", *some)

	return nil
}

// Test for rtm_ext_storage_clear_version_1
func test_storage_clear(r runtime.Instance, key, value string) error {
	// Insert data
	err := storage_set(r, []byte(key), []byte(value))
	if err != nil {
		return err
	}

	// Retrieve and check stored data
	some, err := storage_get(r, []byte(key))
	if err != nil {
		return err
	}

	if some == nil {
		return errors.New("Key is missing")
	}

	if !bytes.Equal(*some, []byte(value)) {
		return fmt.Errorf("Value is different: %s", *some)
	}

	// Clear data
	err = storage_clear(r, []byte(key))
	if err != nil {
		return err
	}

	// Retrieve and check cleared data
	none, err := storage_get(r, []byte(key))
	if err != nil {
		return err
	}

	if none != nil {
		return fmt.Errorf("Key was not cleared: %s", *none)
	}

	return nil
}

// Test for rtm_ext_storage_exists_version_1
func test_storage_exists(r runtime.Instance, key, value string) error {
	// Check for no data
	none, err := storage_exists(r, []byte(key))
	if err != nil {
		return err
	}

	if none != 0 {
		return errors.New("Key already exists")
	}

	// Insert data
	err = storage_set(r, []byte(key), []byte(value))
	if err != nil {
		return err
	}

	// Check for data
	some, err := storage_exists(r, []byte(key))
	if err != nil {
		return err
	}

	if some != 1 {
		return errors.New("Key does not exists")
	}

	// Print result
	fmt.Println("true")

	return nil
}

// Test for rtm_ext_storage_clear_prefix_version_1
func test_storage_clear_prefix(r runtime.Instance, prefix, key1, value1, key2, value2 string) error {
	// Insert data
	err := storage_set(r, []byte(key1), []byte(value1))
	if err != nil {
		return err
	}
	err = storage_set(r, []byte(key2), []byte(value2))
	if err != nil {
		return err
	}

	// Clear prefix
	prefix_enc, err := scale.Marshal([]byte(prefix))
	if err != nil {
		return fmt.Errorf("Encoding prefix failed: : %w", err)
	}

	_, err = r.Exec("rtm_ext_storage_clear_prefix_version_1", prefix_enc)
	if err != nil {
		return fmt.Errorf("Execution failed: : %w", err)
	}

	// Check if first key was handled correctly
	result1, err := storage_get(r, []byte(key1))
	if err != nil {
		return err
	}

	if strings.HasPrefix(key1, prefix) {
		if result1 != nil {
			return errors.New("Key1 was not deleted")
		}
	} else {
		if result1 == nil {
			return errors.New("Key1 was deleted")
		}

		if !bytes.Equal(*result1, []byte(value1)) {
			return fmt.Errorf("Value1 is different: %s", *result1)
		}
	}

	// Check if second key was handled correctly
	result2, err := storage_get(r, []byte(key2))
	if err != nil {
		return err
	}

	if strings.HasPrefix(key2, prefix) {
		if result2 != nil {
			return errors.New("Key2 was not deleted")
		}
	} else {
		if result2 == nil {
			return errors.New("Key2 was deleted")
		}

		if !bytes.Equal(*result2, []byte(value2)) {
			return fmt.Errorf("Value2 is different: %s", *result2)
		}
	}

	return nil
}

// Test for rtm_ext_storage_append_version_1
func test_storage_append(r runtime.Instance, key1, value1, key2, value2 string) error {
	// Encode inputs
	value1_enc, err := scale.Marshal(value1)
	if err != nil {
		return fmt.Errorf("Encoding value1 failed: %w", err)
	}

	value2_enc, err := scale.Marshal(value2)
	if err != nil {
		return fmt.Errorf("Encoding value2 failed: %w", err)
	}

	// Check that key1 is unset
	none1, err := storage_get(r, []byte(key1))
	if err != nil {
		return err
	}

	if none1 != nil {
		return fmt.Errorf("Key1 already exists: %s", *none1)
	}

	// Insert key1
	err = storage_append(r, []byte(key1), []byte(value1_enc))
	if err != nil {
		return err
	}
	err = storage_append(r, []byte(key1), []byte(value2_enc))
	if err != nil {
		return err
	}

	// Check that key2 is unset
	none2, err := storage_get(r, []byte(key2))
	if err != nil {
		return err
	}

	if none2 != nil {
		return fmt.Errorf("Key2 already exists: %s", *none2)
	}

	// Insert key2
	err = storage_append(r, []byte(key2), []byte(value2_enc))
	if err != nil {
		return err
	}
	err = storage_append(r, []byte(key2), []byte(value1_enc))
	if err != nil {
		return err
	}
	err = storage_append(r, []byte(key2), []byte(value2_enc))
	if err != nil {
		return err
	}
	err = storage_append(r, []byte(key2), []byte(value1_enc))
	if err != nil {
		return err
	}

	// Check key1
	some1_opt, err := storage_get(r, []byte(key1))
	if err != nil {
		return err
	}

	if some1_opt == nil {
		return errors.New("Key1 not set")
	}

	var some1 []string
	err = scale.Unmarshal(*some1_opt, &some1)
	if err != nil {
		return fmt.Errorf("Decoding value1 failed: %w", err)
	}

	if len(some1) != 2 || some1[0] != value1 || some1[1] != value2 {
		return fmt.Errorf("Value1 is different: %v", some1)
	}

	fmt.Println(strings.Join(some1, ";"))

	// Check key2
	some2_opt, err := storage_get(r, []byte(key2))
	if err != nil {
		return err
	}

	if some2_opt == nil {
		return errors.New("Key2 not set")
	}

	var some2 []string
	err = scale.Unmarshal(*some2_opt, &some2)
	if err != nil {
		return fmt.Errorf("Decoding value2 failed: %w", err)
	}

	if len(some2) != 4 || some2[0] != value2 || some2[1] != value1 || some2[2] != value2 || some2[3] != value1 {
		return fmt.Errorf("Value2 is different: %v", some2)
	}

	fmt.Println(strings.Join(some2, ";"))

	return nil
}

// Test for rtm_ext_storage_root_version_1
func test_storage_root(r runtime.Instance, key1, value1, key2, value2 string) error {
	// Insert data
	err := storage_set(r, []byte(key1), []byte(value1))
	if err != nil {
		return err
	}
	err = storage_set(r, []byte(key2), []byte(value2))
	if err != nil {
		return err
	}

	// Compute and print storage root hash
	hash, err := storage_root(r)
	if err != nil {
		return err
	}

	fmt.Printf("%x\n", hash[:])

	return nil
}

// Test for rtm_ext_storage_next_key_version_1
func test_storage_next_key(r runtime.Instance, key1, value1, key2, value2 string) error {

	// No next key available
	none1, err := storage_next_key(r, []byte(key1))
	if err != nil {
		return err
	}

	if none1 != nil {
		return fmt.Errorf("Next1 is not empty: %s", *none1)
	}

	none2, err := storage_next_key(r, []byte(key2))
	if err != nil {
		return err
	}

	if none2 != nil {
		return fmt.Errorf("Next2 is not empty: %s", *none2)
	}

	// Insert test data
	err = storage_set(r, []byte(key1), []byte(value1))
	if err != nil {
		return err
	}
	err = storage_set(r, []byte(key2), []byte(value2))
	if err != nil {
		return err
	}

	// Check next key after key1
	some1, err := storage_next_key(r, []byte(key1))
	if err != nil {
		return err
	}

	if strings.Compare(key1, key2) < 0 {
		if some1 == nil {
			return errors.New("Key2 is missing")
		}

		if !bytes.Equal(*some1, []byte(key2)) {
			return fmt.Errorf("Next is not key2: %s", *some1)
		}

		fmt.Printf("%s\n", *some1)
	} else {
		if some1 != nil {
			return fmt.Errorf("Next is not empty: %s", *some1)
		}
	}

	// Check next key after key2
	some2, err := storage_next_key(r, []byte(key2))
	if err != nil {
		return err
	}

	if strings.Compare(key2, key1) < 0 {
		if some2 == nil {
			return errors.New("Key1 is missing")
		}

		if !bytes.Equal(*some2, []byte(key1)) {
			return fmt.Errorf("Next is not key1: %s", *some2)
		}

		fmt.Printf("%s\n", *some2)
	} else {
		if some2 != nil {
			return fmt.Errorf("Next is not empty: %s", *some2)
		}
	}

	return nil
}
