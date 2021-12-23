#![cfg_attr(not(feature = "std"), no_std)]

// `construct_runtime!` does a lot of recursion and requires us to increase the limit to 256.
#![recursion_limit="256"]

// Make the WASM binary available.
#[cfg(feature = "std")]
include!(concat!(env!("OUT_DIR"), "/wasm_binary.rs"));

use sp_std::prelude::*;
use sp_core::{Decode, OpaqueMetadata};
use sp_runtime::{
	generic, create_runtime_str, print, impl_opaque_keys,
	ApplyExtrinsicResult, MultiSignature, KeyTypeId,
	transaction_validity::{TransactionValidity, TransactionSource},
};
use sp_runtime::traits::{
	BlakeTwo256, Block as BlockT, IdentityLookup,
	Verify, IdentifyAccount, NumberFor
};
use sp_api::impl_runtime_apis;
use babe::{AuthorityId as BabeId};
use grandpa::{AuthorityId as GrandpaId, AuthorityList as GrandpaAuthorityList};
use sp_version::RuntimeVersion;

// A few exports that help ease life for downstream crates.
#[cfg(any(feature = "std", test))]
pub use sp_runtime::BuildStorage;
pub use balances::Call as BalancesCall;
pub use sp_runtime::{Permill, Perbill};
pub use frame_support::{
	construct_runtime, parameter_types, storage_root, runtime_print,
	traits::{KeyOwnerProofSystem, Randomness},
	weights::{Weight, RuntimeDbWeight, constants::WEIGHT_PER_SECOND},
};

/// An index to a block.
pub type BlockNumber = u32;

/// A timestamp or duration.
pub type Moment = u64;

/// Alias to 512-bit hash when used in the context of a transaction signature on the chain.
pub type Signature = MultiSignature;

/// Some way of identifying an account on the chain. We intentionally make it equivalent
/// to the public key of our transaction signing scheme.
pub type AccountId = <<Signature as Verify>::Signer as IdentifyAccount>::AccountId;

/// Balance of an account.
pub type Balance = u128;

/// Index of a transaction in the chain.
pub type Index = u32;

/// A hash of some data used by the chain.
pub type Hash = sp_core::H256;

/// Opaque types. These are used by the CLI to instantiate machinery that don't need to know
/// the specifics of the runtime. They can then be made to be agnostic over specific formats
/// of data like extrinsics, allowing for them to continue syncing the network through upgrades
/// to even the core data structures.
pub mod opaque {
	use super::*;

	pub use sp_runtime::OpaqueExtrinsic as UncheckedExtrinsic;

	/// Opaque block header type.
	pub type Header = generic::Header<BlockNumber, BlakeTwo256>;
	/// Opaque block type.
	pub type Block = generic::Block<Header, UncheckedExtrinsic>;
	/// Opaque block identifier type.
	pub type BlockId = generic::BlockId<Block>;

	impl_opaque_keys! {
		pub struct SessionKeys {
			pub babe: Babe,
			pub grandpa: Grandpa,
		}
	}
}

/// This runtime version.
pub const VERSION: RuntimeVersion = RuntimeVersion {
	spec_name: create_runtime_str!("polkadot"),
	impl_name: create_runtime_str!("host-tester"),
	authoring_version: 2,
	spec_version: 1,
	impl_version: 1,
	apis: RUNTIME_API_VERSIONS,
	transaction_version: 1,
};

/// The BABE epoch configuration at genesis.
pub const BABE_GENESIS_EPOCH_CONFIG: sp_babe::BabeEpochConfiguration =
	sp_babe::BabeEpochConfiguration {
		c: PRIMARY_PROBABILITY,
		allowed_slots: sp_babe::AllowedSlots::PrimarySlots,
	};

/// Targeted block time.
pub const MILLISECS_PER_BLOCK: Moment = 6000;

/// Babe slot duration.
pub const SLOT_DURATION: Moment = MILLISECS_PER_BLOCK;

// These time units are defined in number of blocks.
pub const MINUTES: BlockNumber = 60_000 / (MILLISECS_PER_BLOCK as BlockNumber);
pub const HOURS: BlockNumber = MINUTES * 60;
pub const DAYS: BlockNumber = HOURS * 24;

/// Babe epoch duration.
pub const EPOCH_DURATION_IN_BLOCKS: BlockNumber = 4 * HOURS;

/// 1 in 4 blocks (on average, not counting collisions) will be primary babe blocks.
pub const PRIMARY_PROBABILITY: (u64, u64) = (1, 4);

const NORMAL_DISPATCH_RATIO: Perbill = Perbill::from_percent(75);

parameter_types! {
	pub const Version: RuntimeVersion = VERSION;

	pub const BlockHashCount: BlockNumber = 2400;

	/// We allow for 2 seconds of compute with a 6 second average block time.
	pub BlockWeights: system::limits::BlockWeights = system::limits::BlockWeights
		::with_sensible_defaults(2 * WEIGHT_PER_SECOND, NORMAL_DISPATCH_RATIO);

	pub BlockLength: system::limits::BlockLength = system::limits::BlockLength
		::max_with_normal_ratio(5 * 1024 * 1024, NORMAL_DISPATCH_RATIO);

	pub const DbWeight: RuntimeDbWeight = RuntimeDbWeight {
		read: 60_000_000,
		write: 200_000_000,
	};

	pub const SS58Prefix: u8 = 42;

	pub const MaxAuthorities: u32 = 100_000;
}

// Configure FRAME pallets to include in runtime.
impl system::Config for Runtime {
	/// The basic call filter to use in dispatchable.
	type BaseCallFilter = frame_support::traits::Everything;
	/// Block & extrinsics weights: base values and limits.
	type BlockWeights = BlockWeights;
	/// The maximum length of a block (in bytes).
	type BlockLength = BlockLength;
	/// The identifier used to distinguish between accounts.
	type AccountId = AccountId;
	/// The aggregated dispatch type that is available for extrinsics.
	type Call = Call;
	/// The lookup mechanism to get account ID from whatever is passed in dispatchers.
	type Lookup = IdentityLookup<AccountId>;
	/// The index type for storing how many extrinsics an account has signed.
	type Index = Index;
	/// The index type for blocks.
	type BlockNumber = BlockNumber;
	/// The type for hashing blocks and tries.
	type Hash = Hash;
	/// The hashing algorithm used.
	type Hashing = BlakeTwo256;
	/// The header type.
	type Header = generic::Header<BlockNumber, BlakeTwo256>;
	/// The ubiquitous event type.
	type Event = Event;
	/// The ubiquitous origin type.
	type Origin = Origin;
	/// Maximum number of block number to block hash mappings to keep (oldest pruned first).
	type BlockHashCount = BlockHashCount;
	/// The weight of database operations that the runtime can invoke.
	type DbWeight = DbWeight;
	/// Version of the runtime.
	type Version = Version;
	/// Converts a module to the index of the module in `construct_runtime!`.
	///
	/// This type is being generated by `construct_runtime!`.
	type PalletInfo = PalletInfo;
	/// What to do if a new account is created.
	type OnNewAccount = ();
	/// What to do if an account is fully reaped from the system.
	type OnKilledAccount = ();
	/// The data to be stored in an account.
	type AccountData = balances::AccountData<Balance>;
	/// Weight information for the extrinsics of this pallet.
	type SystemWeightInfo = ();
	/// This is used as an identifier of the chain. 42 is the generic substrate prefix.
	type SS58Prefix = SS58Prefix;
	/// What to do on code update 
	type OnSetCode = ();
    /// Maximum number of consumers per account
    type MaxConsumers = frame_support::traits::ConstU32<16>;
}

impl collective_flip::Config for Runtime {}

parameter_types! {
	pub const MinimumPeriod: Moment = SLOT_DURATION / 2;
}

impl timestamp::Config for Runtime {
	type Moment = Moment;
	type OnTimestampSet = Babe;
	type MinimumPeriod = MinimumPeriod;
	type WeightInfo = ();
}

parameter_types! {
	pub const EpochDuration: u64 = EPOCH_DURATION_IN_BLOCKS as u64;
	pub const ExpectedBlockTime: Moment = MILLISECS_PER_BLOCK;
}

impl babe::Config for Runtime {
	type EpochDuration = EpochDuration;
	type ExpectedBlockTime = ExpectedBlockTime;
	type EpochChangeTrigger = babe::SameAuthoritiesForever; // TODO: Check authority change
	type DisabledValidators = ();

	type KeyOwnerProofSystem = (); // Disabled

	type KeyOwnerProof =
		<Self::KeyOwnerProofSystem as KeyOwnerProofSystem<(KeyTypeId, BabeId)>>::Proof;

	type KeyOwnerIdentification = <Self::KeyOwnerProofSystem as KeyOwnerProofSystem<(
		KeyTypeId,
		BabeId,
	)>>::IdentificationTuple;

	type HandleEquivocation = (); // Disabled

	type WeightInfo = ();
	type MaxAuthorities = MaxAuthorities;
}

impl grandpa::Config for Runtime {
	type Event = Event;

	type Call = Call;

	type KeyOwnerProofSystem = (); // Disabled

	type KeyOwnerProof =
		<Self::KeyOwnerProofSystem as KeyOwnerProofSystem<(KeyTypeId, GrandpaId)>>::Proof;

	type KeyOwnerIdentification = <Self::KeyOwnerProofSystem as KeyOwnerProofSystem<(
		KeyTypeId,
		GrandpaId,
	)>>::IdentificationTuple;

	type HandleEquivocation = (); // Disabled

	type WeightInfo = ();
	type MaxAuthorities = MaxAuthorities;
}

parameter_types! {
	pub const ExistentialDeposit: u128 = 500;
	pub const MaxLocks: u32 = 50;
}

impl balances::Config for Runtime {
	type MaxLocks = MaxLocks;
	type MaxReserves = ();
	type ReserveIdentifier = [u8; 8];
	/// The type for recording an account's balance.
	type Balance = Balance;
	/// The ubiquitous event type.
	type Event = Event;
	type DustRemoval = ();
	type ExistentialDeposit = ExistentialDeposit;
	type AccountStore = System;
	type WeightInfo = ();
}

construct_runtime!(
	pub enum Runtime where
		Block = Block,
		NodeBlock = opaque::Block,
		UncheckedExtrinsic = UncheckedExtrinsic
	{
		System: system::{Pallet, Call, Config, Storage, Event<T>},
		CollectiveFlip: collective_flip::{Pallet, Storage},
		Babe: babe::{Pallet, Call, Storage, Config},
		Grandpa: grandpa::{Pallet, Call, Storage, Config, Event},
		Timestamp: timestamp::{Pallet, Call, Storage, Inherent},
		Balances: balances::{Pallet, Call, Storage, Config<T>, Event<T>},
	}
);

/// The address format for describing accounts.
pub type Address = AccountId;
/// Block header type as expected by this runtime.
pub type Header = generic::Header<BlockNumber, BlakeTwo256>;
/// Block type as expected by this runtime.
pub type Block = generic::Block<Header, UncheckedExtrinsic>;
/// The SignedExtension to the basic transaction logic.
pub type SignedExtra = (
	system::CheckSpecVersion<Runtime>,
	system::CheckTxVersion<Runtime>,
	system::CheckGenesis<Runtime>,
	system::CheckEra<Runtime>,
	system::CheckNonce<Runtime>,
	system::CheckWeight<Runtime>,
);
/// Unchecked extrinsic type as expected by this runtime.
pub type UncheckedExtrinsic = generic::UncheckedExtrinsic<Address, Call, Signature, SignedExtra>;
/// Executive: handles dispatch to the various modules.
pub type Executive = frame_executive::Executive<Runtime, Block, system::ChainContext<Runtime>, Runtime, AllPalletsWithSystem>;


/// Print current storage root
fn print_storage_root() {
	let storage_root = Hash::decode(&mut &storage_root()[..])
		.expect("`storage_root` is a valid hash");
	runtime_print!("##{:x}##", storage_root);
}


impl_runtime_apis! {
	impl sp_api::Core<Block> for Runtime {
		fn version() -> RuntimeVersion {
			print("@@version()@@");
			print_storage_root();
			VERSION
		}

		fn execute_block(block: Block) {
			print("@@execute_block()@@");
			Executive::execute_block(block)
		}

		fn initialize_block(header: &<Block as BlockT>::Header) {
			print("@@initialize_block()@@");
			Executive::initialize_block(header)
		}
	} // core api

	impl sp_api::Metadata<Block> for Runtime {
		fn metadata() -> OpaqueMetadata {
			print("@@metadata()@@");
			OpaqueMetadata::new(Runtime::metadata().into())
		}
	} // metadata api

	impl sp_block_builder::BlockBuilder<Block> for Runtime {
		fn apply_extrinsic(extrinsic: <Block as BlockT>::Extrinsic) -> ApplyExtrinsicResult {
			print("@@apply_extrinsics()@@");
			Executive::apply_extrinsic(extrinsic)
		}

		fn finalize_block() -> <Block as BlockT>::Header {
			print("@@finalize_block()@@");
			Executive::finalize_block()
		}

		fn inherent_extrinsics(data: sp_inherents::InherentData) -> Vec<<Block as BlockT>::Extrinsic> {
			print("@@inherent_extrinsics()@@");
			data.create_extrinsics()
		}

		fn check_inherents(
			block: Block,
			data: sp_inherents::InherentData,
		) -> sp_inherents::CheckInherentsResult {
			print("@@check_inherents()@@");
			data.check_extrinsics(&block)
		}

	} // block builder

	impl sp_transaction_pool::runtime_api::TaggedTransactionQueue<Block> for Runtime {
		fn validate_transaction(
			source: TransactionSource,
			tx: <Block as BlockT>::Extrinsic,
			block_hash: <Block as BlockT>::Hash,
		) -> TransactionValidity {
			print("@@validate_transaction()@@");
			Executive::validate_transaction(source, tx, block_hash)
		}
	} // transaction pool

	impl sp_session::SessionKeys<Block> for Runtime {
		fn generate_session_keys(seed: Option<Vec<u8>>) -> Vec<u8> {
			print("@@generate_session_keys()@@");
			opaque::SessionKeys::generate(seed)
		}

		fn decode_session_keys(
			encoded: Vec<u8>,
		) -> Option<Vec<(Vec<u8>, sp_core::crypto::KeyTypeId)>> {
			print("@@decode_session_keys()@@");
			opaque::SessionKeys::decode_into_raw_public_keys(&encoded)
		}
	} // session

	impl sp_babe::BabeApi<Block> for Runtime {
		fn configuration() -> sp_babe::BabeGenesisConfiguration {
			print("@@configuration()@@");
			print_storage_root();
			sp_babe::BabeGenesisConfiguration {
				slot_duration: Babe::slot_duration(),
				epoch_length: EpochDuration::get(),
				c: BABE_GENESIS_EPOCH_CONFIG.c,
				genesis_authorities: Babe::authorities().to_vec(),
				randomness: Babe::randomness(),
				allowed_slots: BABE_GENESIS_EPOCH_CONFIG.allowed_slots,
			}
		}

		fn current_epoch_start() -> sp_babe::Slot {
			print("@@current_epoch_start()@@");
			Babe::current_epoch_start()
		}

		fn current_epoch() -> sp_babe::Epoch {
			print("@@current_epoch()@@");
			Babe::current_epoch()
		}

		fn next_epoch() -> sp_babe::Epoch {
			print("@@next_epoch()@@");
			Babe::next_epoch()
		}

		fn generate_key_ownership_proof(
			_slot_number: sp_babe::Slot,
			_authority_id: sp_babe::AuthorityId,
		) -> Option<sp_babe::OpaqueKeyOwnershipProof> {
			None
		}

		fn submit_report_equivocation_unsigned_extrinsic(
			_equivocation_proof: sp_babe::EquivocationProof<<Block as BlockT>::Header>,
			_key_owner_proof: sp_babe::OpaqueKeyOwnershipProof,
		) -> Option<()> {
			None
		}
	} // babe

	impl sp_grandpa::GrandpaApi<Block> for Runtime {
		fn grandpa_authorities() -> GrandpaAuthorityList {
			print("@@grandpa_authorities()@@");
			Grandpa::grandpa_authorities()
		}

		fn generate_key_ownership_proof(
			_set_id: sp_grandpa::SetId,
			_authority_id: GrandpaId,
		) -> Option<sp_grandpa::OpaqueKeyOwnershipProof> {
			None
		}

		fn current_set_id() -> sp_grandpa::SetId {
			Grandpa::current_set_id()
		}

		fn submit_report_equivocation_unsigned_extrinsic(
			_equivocation_proof: sp_grandpa::EquivocationProof<
				<Block as BlockT>::Hash,
				NumberFor<Block>,
			>,
			_key_owner_proof: sp_grandpa::OpaqueKeyOwnershipProof,
		) -> Option<()> {
			None
		}
	} // grandpa
}
