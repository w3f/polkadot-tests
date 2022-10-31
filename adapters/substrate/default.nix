{ polkadot-tests, lib, naersk }:

naersk.buildPackage {
  name = "substrate-adapter";
  inherit (polkadot-tests) version;

  src = "${polkadot-tests.src}/adapters/substrate";
}
