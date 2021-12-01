/*
 * Copyright (c) 2019-2021 Web 3.0 Technologies Foundation
 *
 * This file is part of the Polkadot Test Suite.
 *
 * The Polkadot Test Suite is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Polkadot Test Suite is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Polkadot Test Suite. If not, see
 * <https://www.gnu.org/licenses/>.
 */

#include "helpers.hpp"

#include <fstream>

#include <kagome/blockchain/impl/key_value_block_header_repository.hpp>

#include <kagome/crypto/bip39/impl/bip39_provider_impl.hpp>
#include <kagome/crypto/crypto_store/crypto_store_impl.hpp>
#include <kagome/crypto/ed25519/ed25519_provider_impl.hpp>
#include <kagome/crypto/hasher/hasher_impl.hpp>
#include <kagome/crypto/pbkdf2/impl/pbkdf2_provider_impl.hpp>
#include <kagome/crypto/random_generator/boost_generator.hpp>
#include <kagome/crypto/secp256k1/secp256k1_provider_impl.hpp>
#include <kagome/crypto/sr25519/sr25519_provider_impl.hpp>

#include <kagome/host_api/impl/host_api_factory_impl.hpp>

#include <kagome/offchain/impl/offchain_persistent_storage.hpp>

#include <kagome/runtime/module.hpp>
#include <kagome/runtime/runtime_code_provider.hpp>
#include <kagome/runtime/trie_storage_provider.hpp>

#include <kagome/runtime/binaryen/instance_environment_factory.hpp>
#include <kagome/runtime/binaryen/module/module_factory_impl.hpp>

#include <kagome/runtime/wavm/compartment_wrapper.hpp>
#include <kagome/runtime/wavm/instance_environment_factory.hpp>
#include <kagome/runtime/wavm/intrinsics/intrinsic_functions.hpp>
#include <kagome/runtime/wavm/intrinsics/intrinsic_module.hpp>
#include <kagome/runtime/wavm/module_factory_impl.hpp>

#include <kagome/storage/changes_trie/impl/storage_changes_tracker_impl.hpp>

#include <kagome/storage/in_memory/in_memory_storage.hpp>

#include <kagome/storage/trie/impl/trie_storage_backend_impl.hpp>
#include <kagome/storage/trie/impl/trie_storage_impl.hpp>
#include <kagome/storage/trie/polkadot_trie/polkadot_trie_factory_impl.hpp>
#include <kagome/storage/trie/serialization/polkadot_codec.hpp>
#include <kagome/storage/trie/serialization/trie_serializer_impl.hpp>

namespace helpers {

  // Various namespace includes to improve code readability
  using kagome::blockchain::KeyValueBlockHeaderRepository;

  using kagome::crypto::Bip39ProviderImpl;
  using kagome::crypto::BoostRandomGenerator;
  using kagome::crypto::CryptoStoreImpl;
  using kagome::crypto::Ed25519ProviderImpl;
  using kagome::crypto::Ed25519Suite;
  using kagome::crypto::HasherImpl;
  using kagome::crypto::KeyFileStorage;
  using kagome::crypto::Pbkdf2ProviderImpl;
  using kagome::crypto::Secp256k1ProviderImpl;
  using kagome::crypto::Sr25519ProviderImpl;
  using kagome::crypto::Sr25519Suite;

  using kagome::host_api::HostApiFactoryImpl;
  using kagome::host_api::OffchainExtensionConfig;

  using kagome::offchain::OffchainPersistentStorageImpl;

  using kagome::primitives::events::ChainSubscriptionEngine;
  using kagome::primitives::events::StorageSubscriptionEngine;

  using kagome::runtime::ModuleFactory;
  using kagome::runtime::RuntimeCodeProvider;

  namespace binaryen = kagome::runtime::binaryen;
  namespace wavm = kagome::runtime::wavm;

  using kagome::storage::InMemoryStorage;
  using kagome::storage::changes_trie::StorageChangesTrackerImpl;
  using kagome::storage::trie::PolkadotCodec;
  using kagome::storage::trie::PolkadotTrieFactoryImpl;
  using kagome::storage::trie::RootHash;
  using kagome::storage::trie::TrieSerializerImpl;
  using kagome::storage::trie::TrieStorageBackendImpl;
  using kagome::storage::trie::TrieStorageImpl;

  // Default runtime location
  const char *DEFAULT_RUNTIME_PATH = "bin/hostapi-runtime.default.wasm";

  // Simple wasm provider to provide wasm adapter runtime shim to kagome
  class FileCodeProvider : public RuntimeCodeProvider {
   public:
    FileCodeProvider(const std::string path) {
      // Open file and determine size (ios::ate jumps to end on open)
      std::ifstream file(path, std::ios::binary | std::ios::ate);
      if (!file) {
        throw std::invalid_argument("Wasm adapter runtime not found!");
      }
      int size = file.tellg();
      file.seekg(0, std::ios::beg);

      // Load code into buffer
      code_.resize(size);
      file.read(reinterpret_cast<char *>(code_.data()), size);
    }

    ~FileCodeProvider() override = default;

    using ByteSpan = gsl::span<const uint8_t>;

    ByteSpan getCode() const {
      return code_;
    }

    outcome::result<ByteSpan> getCodeAt(const RootHash &state) const override {
      return code_;
    }

   private:
    Buffer code_;
  };

  // Default backend to use
  const RuntimeEnvironment::Backend RuntimeEnvironment::DEFAULT_BACKEND =
      RuntimeEnvironment::Backend::Binaryen;

  RuntimeEnvironment::RuntimeEnvironment(const std::string path,
                                         Backend backend) {
    // Load wasm runtime from file
    auto code_provider = std::make_shared<FileCodeProvider>(path);

    // Initialize storage and trie factory
    auto storage = std::make_shared<InMemoryStorage>();

    auto storage_backend =
        std::make_shared<TrieStorageBackendImpl>(storage, Buffer{});

    auto trie_factory = std::make_shared<PolkadotTrieFactoryImpl>();
    auto codec = std::make_shared<PolkadotCodec>();
    auto serializer = std::make_shared<TrieSerializerImpl>(
        trie_factory, codec, storage_backend);

    std::shared_ptr<TrieStorageImpl> trie_db =
        TrieStorageImpl::createEmpty(
            trie_factory, codec, serializer, std::nullopt)
            .value();

    // Build change tracker
    auto storage_sub_engine = std::make_shared<StorageSubscriptionEngine>();
    auto chain_sub_engine = std::make_shared<ChainSubscriptionEngine>();

    auto changes_tracker = std::make_shared<StorageChangesTrackerImpl>(
        trie_factory, codec, storage_sub_engine, chain_sub_engine);

    // Initialize crypto providers
    auto pbkdf2_provider = std::make_shared<Pbkdf2ProviderImpl>();
    auto random_generator = std::make_shared<BoostRandomGenerator>();
    auto ed25519_provider =
        std::make_shared<Ed25519ProviderImpl>(random_generator);
    auto sr25519_provider =
        std::make_shared<Sr25519ProviderImpl>(random_generator);
    auto secp256k1_provider = std::make_shared<Secp256k1ProviderImpl>();
    auto hasher = std::make_shared<HasherImpl>();
    auto bip39_provider = std::make_shared<Bip39ProviderImpl>(pbkdf2_provider);

    auto keystore_path =
        boost::filesystem::temp_directory_path() / "kagome-adapter-host-api";
    auto crypto_store = std::make_shared<CryptoStoreImpl>(
        std::make_shared<Ed25519Suite>(ed25519_provider),
        std::make_shared<Sr25519Suite>(sr25519_provider),
        bip39_provider,
        KeyFileStorage::createAt(keystore_path).value());

    // Initialize offchain storage
    auto offchain_storage =
        std::make_shared<OffchainPersistentStorageImpl>(storage);

    // Initialize host api factory
    auto host_api_factory =
        std::make_shared<HostApiFactoryImpl>(OffchainExtensionConfig{},
                                             changes_tracker,
                                             sr25519_provider,
                                             ed25519_provider,
                                             secp256k1_provider,
                                             hasher,
                                             crypto_store,
                                             bip39_provider,
                                             offchain_storage);

    // Initialize header repo
    auto header_repo =
        std::make_shared<KeyValueBlockHeaderRepository>(storage, hasher);

    // Initialize module factory (backend dependent)
    std::shared_ptr<ModuleFactory> module_factory;

    switch (backend) {
      case Backend::Binaryen: {
        // Initialize module factory
        auto instance_env_factory =
            std::make_shared<binaryen::InstanceEnvironmentFactory>(
                trie_db, host_api_factory, header_repo, changes_tracker);

        module_factory = std::make_shared<binaryen::ModuleFactoryImpl>(
            instance_env_factory, trie_db);
      } break;

      case Backend::WAVM: {
        // Prepare wavm environment
        auto compartment =
            std::make_shared<wavm::CompartmentWrapper>("host-api");

        auto intrinsic_module =
            std::make_shared<wavm::IntrinsicModule>(compartment);
        wavm::registerHostApiMethods(*intrinsic_module);

        // Initialize module factory
        auto instance_env_factory =
            std::make_shared<wavm::InstanceEnvironmentFactory>(trie_db,
                                                               compartment,
                                                               intrinsic_module,
                                                               host_api_factory,
                                                               header_repo,
                                                               changes_tracker);

        module_factory = std::make_shared<wavm::ModuleFactoryImpl>(
            compartment, instance_env_factory, intrinsic_module);
      } break;
    };

    // Instantiate wasm module instance from code
    auto module = module_factory->make(code_provider->getCode());
    BOOST_ASSERT_MSG(module.has_value(), module.error().message().data());

    auto module_instance = module.value()->instantiate();
    BOOST_ASSERT_MSG(module_instance.has_value(),
                     module_instance.error().message().data());

    module_instance_ = module_instance.value();

    // Get memory provider
    memory_provider_ = module_instance_->getEnvironment().memory_provider;

    // Intialize storage batch
    auto batch =
        module_instance_->getEnvironment().storage_provider->setToPersistent();
    BOOST_ASSERT_MSG(batch, batch.error().message().data());

    // Set up heap base
    auto opt_heap_base = module_instance_->getGlobal("__heap_base");
    BOOST_ASSERT_MSG(opt_heap_base.has_value() && opt_heap_base.value(),
                     "Failed to obtain __heap_base from a runtime module");

    int32_t heap_base = boost::get<int32_t>(opt_heap_base.value().value());

    auto reset = memory_provider_->resetMemory(heap_base);
    BOOST_ASSERT_MSG(reset.has_value(), reset.error().message().data());

    // Set expected defaults in storage
    execute<void>("rtm_ext_storage_set_version_1", ":code", "");
  }

}  // namespace helpers
