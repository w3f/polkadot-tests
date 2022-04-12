{ polkadot-tests, naerskWasm, protobuf }:

naerskWasm.buildPackage {
  pname = "tester-runtime";
  inherit (polkadot-tests) version;

  src = "${polkadot-tests.src}/runtimes/tester";

  # Needed to build rust-libp2p
  PROTOC         = "${protobuf}/bin/protoc";
}
