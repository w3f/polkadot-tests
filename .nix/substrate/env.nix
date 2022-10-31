{ lib, mkShell, rustToolchain, cmake, openssl, pkgconfig, protobuf, llvmPackages, rocksdb }:

let
  version = lib.getVersion rustToolchain;
in
  mkShell {
    name = "substrate-env-${version}";

    nativeBuildInputs = [
      rustToolchain
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
