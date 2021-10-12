{ mkShell, rustWasmPlatform, cmake, openssl, pkgconfig, protobuf, llvmPackages, rocksdb }:

let
  version = rustWasmPlatform.rust.rustc.name;
in
  mkShell {
    name = "substrate-env-${version}";

    nativeBuildInputs = [
      rustWasmPlatform.rust.cargo
      cmake # for wabt-sys
    ];

    buildInputs = [
      openssl #?
      pkgconfig #?
      protobuf
      llvmPackages.clang-unwrapped
      llvmPackages.libclang
    ];

    PROTOC          = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE  = "${protobuf}/include";
    LIBCLANG_PATH   = "${llvmPackages.libclang}/lib";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  }
