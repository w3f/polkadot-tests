final: prev:

with final; { 
  # Not in stable
  soralog = callPackage ./deps/soralog {};
  fmt_6   = callPackage ./deps/fmt.nix {};

  cpp-libp2p        = callPackage ./deps/cpp-libp2p {};
  sqlite-modern-cpp = callPackage ./deps/sqlite-modern-cpp {};

  jsonrpc-lean = callPackage ./deps/jsonrpc-lean.nix {};

  schnorrkel_crust = callPackage ./deps/schnorrkel_crust {};

  boost_di     = callPackage ./deps/boost_di.nix {};
  tsl_hat_trie = callPackage ./deps/tsl_hat_trie.nix {};

  prometheus-cpp = callPackage ./deps/prometheus-cpp.nix {};

  wavm = callPackage ./deps/wavm.nix {};

  # Newer then stable, often forks with additional cmake support
  binaryen_cmake      = callPackage ./deps/binaryen.nix {};
  gtest_cmake         = callPackage ./deps/googletest.nix {};
  leveldb_cmake       = callPackage ./deps/leveldb.nix {};
  microsoft_gsl_cmake = callPackage ./deps/microsoft_gsl.nix {};
  rapidjson_cmake     = callPackage ./deps/rapidjson.nix {};
  xxHash_cmake        = callPackage ./deps/xxhash.nix {};
  libsecp256k1_cmake  = callPackage ./deps/libsecp256k1.nix {};
}
