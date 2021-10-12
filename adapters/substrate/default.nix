{ polkadot-tests, lib, naerskWasm }:

naerskWasm.buildPackage {
  name = "substrate-adapter";
  inherit (polkadot-tests) version;

  src = "${polkadot-tests.src}/adapters/substrate";
}
