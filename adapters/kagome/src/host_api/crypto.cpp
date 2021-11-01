/*
 * Copyright (c) 2019 Web3 Technologies Foundation
 *
 * This file is part of Polkadot Host Test Suite
 *
 * Polkadot Host Test Suite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Polkadot Host Tests is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "crypto.hpp"

#include "helpers.hpp"

#include <memory>
#include <vector>

#include <crypto/ed25519_types.hpp>
#include <crypto/sr25519_types.hpp>

using std::string_literals::operator""s;

using namespace kagome::crypto;

namespace crypto {

  template <
    const char *CName,
    typename TPublicKey,
    typename TSignature
    > struct CryptoSuite {
    static constexpr const char *Name = CName;
    using PublicKey = TPublicKey;
    using Signature = TSignature;
  };

  const char Ed25519Name[] = "ed25519";
  const char Sr25519Name[] = "sr25519";

  using Ed25519Suite = CryptoSuite<Ed25519Name, Ed25519PublicKey, Ed25519Signature>;
  using Sr25519Suite = CryptoSuite<Sr25519Name, Sr25519PublicKey, Sr25519Signature>;

  const kagome::runtime::WasmSize TEST_KEY_TYPE = 0xDEADBEEF;

  template <typename Suite>
  void public_keys(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    BOOST_ASSERT(inputs.size() == 2);

    const std::string_view seed1 = inputs[0];
    const std::string_view seed2 = inputs[1];

    auto pk1 = environment.execute<typename Suite::PublicKey>(
      "rtm_ext_crypto_"s + Suite::Name + "_generate_version_1",
      TEST_KEY_TYPE, std::make_optional(seed1)
    );

    auto pk2 = environment.execute<typename Suite::PublicKey>(
      "rtm_ext_crypto_"s + Suite::Name + "_generate_version_1",
      TEST_KEY_TYPE, std::make_optional(seed2)
    );

    auto keys = environment.execute<std::vector<typename Suite::PublicKey>>(
      "rtm_ext_crypto_"s + Suite::Name + "_public_keys_version_1",
      TEST_KEY_TYPE
    );

    BOOST_ASSERT(keys.size() == 2);

    BOOST_ASSERT(pk1 == keys.at(0) or pk1 == keys.at(1));
    BOOST_ASSERT(pk2 == keys.at(0) or pk2 == keys.at(1));

    std::cout << "1. Public key: " << keys.at(0).toHex() << std::endl;
    std::cout << "2. Public key: " << keys.at(1).toHex() << std::endl;
  }

  template <typename Suite>
  void generate(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    BOOST_ASSERT(inputs.size() == 1);

    std::string_view seed = inputs[0];

    auto key = environment.execute<typename Suite::PublicKey>(
      "rtm_ext_crypto_"s + Suite::Name + "_generate_version_1",
      TEST_KEY_TYPE, std::make_optional(seed));

    std::cout << key.toHex() << std::endl;
  }

  template <typename Suite>
  void sign(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    BOOST_ASSERT(inputs.size() == 2);

    std::string_view seed = inputs[0];
    std::string_view message = inputs[1];

    auto pk = environment.execute<typename Suite::PublicKey>(
      "rtm_ext_crypto_"s + Suite::Name + "_generate_version_1",
      TEST_KEY_TYPE, std::make_optional(seed)
    );

    auto sig = environment.execute<std::optional<typename Suite::Signature>>(
      "rtm_ext_crypto_"s + Suite::Name + "_sign_version_1",
      TEST_KEY_TYPE, pk, message
    ).value();

    std::cout << "Message: " << message << std::endl;
    std::cout << "Public key: " << pk.toHex() << std::endl;
    std::cout << "Signature: " << sig.toHex() << std::endl;
  }

  template <typename Suite>
  void verify(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    BOOST_ASSERT(inputs.size() == 2);

    std::string_view seed = inputs[0];
    std::string_view message = inputs[1];

    auto pk = environment.execute<typename Suite::PublicKey>(
      "rtm_ext_crypto_"s + Suite::Name + "_generate_version_1",
      TEST_KEY_TYPE, std::make_optional(seed)
    );
    auto sig = environment.execute<std::optional<typename Suite::Signature>>(
      "rtm_ext_crypto_"s + Suite::Name + "_sign_version_1",
      TEST_KEY_TYPE, pk, message
    ).value();

    auto verified = environment.execute<bool>(
      "rtm_ext_crypto_"s + Suite::Name + "_verify_version_1",
      sig, message, pk
    );

    std::cout << "Message: " << message << std::endl;
    std::cout << "Public key: " << pk.toHex() << std::endl;
    std::cout << "Signature: " << sig.toHex() << std::endl;

    if (verified) {
      std::cout << "GOOD SIGNATURE" << std::endl;
    } else {
      std::cout << "BAD SIGNATURE" << std::endl;
    }
  }


  void ed25519_public_keys_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    public_keys<Ed25519Suite>(environment, inputs);
  }

  void ed25519_generate_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    generate<Ed25519Suite>(environment, inputs);
  }

  void ed25519_sign_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    sign<Ed25519Suite>(environment, inputs);
  }

  void ed25519_verify_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string>& inputs
  ) {
    verify<Ed25519Suite>(environment, inputs);
  }


  void sr25519_public_keys_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    public_keys<Sr25519Suite>(environment, inputs);
  }

  void sr25519_generate_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    generate<Sr25519Suite>(environment, inputs);
  }

  void sr25519_sign_version_1(
    helpers::RuntimeEnvironment& environment,
    const std::vector<std::string>& inputs
  ) {
    sign<Sr25519Suite>(environment, inputs);
  }

  void sr25519_verify_version_1(
    helpers::RuntimeEnvironment environment,
    const std::vector<std::string>& inputs
  ) {
    verify<Sr25519Suite>(environment, inputs);
  }

}
