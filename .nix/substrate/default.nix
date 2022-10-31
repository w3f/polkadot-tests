{ substrate-submodule
, lib
, naersk
, clang
, llvmPackages
, protobuf
}:

naersk.buildPackage {
  name = "substrate-host";

  src = substrate-submodule;
  version = substrate-submodule.shortRev;

  nativeBuildInputs = [ clang ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  PROTOC = "${protobuf}/bin/protoc";

  # Currently not needed
  SKIP_WASM_BUILD = 1;

  # Needs WASM runtimes.
  doCheck = false;
}
