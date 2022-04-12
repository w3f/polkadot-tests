final: prev:

with final; { 
  # Not in stable
  soralog = callPackage ./deps/soralog {};
  fmt_6   = callPackage ./deps/fmt.nix {};

  cpp-libp2p        = callPackage ./deps/cpp-libp2p {};
  sqlite-modern-cpp = callPackage ./deps/sqlite-modern-cpp {};

  jsonrpc-lean = callPackage ./deps/jsonrpc-lean.nix {};

  schnorrkel-crust = callPackage ./deps/schnorrkel-crust {};

  boost-di     = callPackage ./deps/boost-di.nix {};
  tsl-hat-trie = callPackage ./deps/tsl-hat-trie.nix {};

  prometheus-cpp = callPackage ./deps/prometheus-cpp.nix {};

  wavm = callPackage ./deps/wavm.nix {
    # Needed for Zen 3 support
    inherit (llvmPackages_12) libllvm;
  };

  scale-codec-cpp = callPackage ./deps/scale-codec-cpp.nix {};

  # Newer then stable, often forks with additional cmake support
  binaryen_cmake      = callPackage ./deps/binaryen.nix {};
  gtest_cmake         = callPackage ./deps/googletest.nix {};
  leveldb_cmake       = callPackage ./deps/leveldb.nix {};
  microsoft-gsl_cmake = callPackage ./deps/microsoft-gsl.nix {};
  rapidjson_cmake     = callPackage ./deps/rapidjson.nix {};
  xxHash_cmake        = callPackage ./deps/xxhash.nix {};
  libsecp256k1_cmake  = callPackage ./deps/libsecp256k1.nix {};
  backward-cpp_cmake  = callPackage ./deps/backward-cpp.nix {};
}
