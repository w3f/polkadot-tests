use std::env;

use tester_runtime::{
	AccountId, BabeConfig, BalancesConfig, GenesisConfig,
	GrandpaConfig, SudoConfig, SystemConfig, BuildStorage, Header,
	Signature, BABE_GENESIS_EPOCH_CONFIG, STATE_VERSION, WASM_BINARY,
};

use sp_core::{H256, Pair, Public, sr25519};
use sc_service::{GenericChainSpec, ChainType};
use sp_runtime::traits::{
	Hash as HashT, Header as HeaderT,
	Verify, IdentifyAccount
};

use sp_babe::AuthorityId as BabeId;
use sp_grandpa::AuthorityId as GrandpaId;

/// Specialized `ChainSpec` of the general Substrate ChainSpec type.
type ChainSpec = GenericChainSpec<GenesisConfig>;

/// Helper function to generate a crypto pair from seed
fn get_from_seed<TPublic: Public>(seed: &str) -> <TPublic::Pair as Pair>::Public {
	TPublic::Pair::from_string(&format!("//{}", seed), None)
		.expect("static values are valid; qed")
		.public()
}

type AccountPublic = <Signature as Verify>::Signer;

/// Helper function to generate an account ID from seed
fn get_account_id_from_seed<TPublic: Public>(seed: &str) -> AccountId where
	AccountPublic: From<<TPublic::Pair as Pair>::Public>
{
	AccountPublic::from(get_from_seed::<TPublic>(seed)).into_account()
}


/// Create default genesis config
fn default_genesis_config() -> GenesisConfig {
	GenesisConfig {
		system: SystemConfig {
			code: WASM_BINARY.unwrap().to_vec(),
		},
		balances: BalancesConfig {
			balances: vec![
				get_account_id_from_seed::<sr25519::Public>("Alice"),
				get_account_id_from_seed::<sr25519::Public>("Bob"),
				get_account_id_from_seed::<sr25519::Public>("Alice//stash"),
				get_account_id_from_seed::<sr25519::Public>("Bob//stash"),
			].iter().cloned().map(|k|(k, 1 << 60)).collect(),
		},
		babe: BabeConfig {
			authorities: vec![
				(get_from_seed::<BabeId>("Alice"), 1),
				(get_from_seed::<BabeId>("Bob"), 1),
			],
			epoch_config: Some(BABE_GENESIS_EPOCH_CONFIG),
		},
		grandpa: GrandpaConfig {
			authorities: vec![
				(get_from_seed::<GrandpaId>("Alice"), 1),
				(get_from_seed::<GrandpaId>("Bob"), 1),
			],
		},
		sudo: SudoConfig {
			key: Some(get_account_id_from_seed::<sr25519::Public>("Alice")),
		},
	}
}

/// Compute genesis hash
fn default_genesis_hash() -> H256 {
	<Header as HeaderT>::Hashing::trie_root(
		default_genesis_config().build_storage().unwrap().top.into_iter().collect(),
		STATE_VERSION
	)
}

/// Create default chain specification
fn default_chain_spec() -> ChainSpec {
	ChainSpec::from_genesis(
		"Specification Conformance Test",
		"spectest",
		ChainType::Development,
		default_genesis_config,
		vec![], // Bootnodes
		None,   // Telemetry
		None,   // Protocol Id
		None,   // Fork Id
		None,   // Properties
		None,   // Extensions
	)
}


/// Print storage root hash of genesis
fn print_genesis_hash() {
	print!("{:x}", default_genesis_hash());
}

/// Print chain spec of tester chain
fn print_chain_spec() {
	match default_chain_spec().as_json(true) {
		Ok(json) => println!("{}", json),
		Err(err) => eprintln!("Error: {}", err),
	}
}


/// Print command line help
fn print_usage() {
		println!("usage: host-tester {{hash|json}}");
}

/// Entry point, parses command line arguments
fn main() {
	let args: Vec<String> = env::args().collect();

	if args.len() == 2 {
		match &args[1][..] {
			"hash" => print_genesis_hash(),
			"json" => print_chain_spec(),
			_ => print_usage(),
		}
	} else {
		print_usage();
	}
}
