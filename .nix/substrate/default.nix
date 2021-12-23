{ polkadot-tests
, lib
, naerskWasm
, clang
, llvmPackages
, protobuf
}:

naerskWasm.buildPackage {
  name = "substrate-host";
  inherit (polkadot-tests) version;

  src = "${polkadot-tests.src}/hosts/substrate";

  nativeBuildInputs = [ clang ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  PROTOC = "${protobuf}/bin/protoc";

  # Currently not needed
  SKIP_WASM_BUILD = 1;

  # Needs WASM runtimes.
  doCheck = false;
}
