{ pkgs }:

# Last updated based on v0.23.257-soramitsu35

let
  # Use nixpkgs as basis
  inherit (pkgs) callPackage;

  # Dependencies of dependencies
  boost-di = callPackage ./boost-di.nix {};

  fmt_6 = callPackage ./fmt.nix {};

  gtest_cmake = callPackage ./googletest.nix {};

  microsoft-gsl_cmake = callPackage ./microsoft-gsl.nix {};

  rapidjson_cmake = callPackage ./rapidjson.nix {};

  soralog = callPackage ./soralog { inherit fmt_6 gtest_cmake; };

  # Dependencies of libp2p
  sqlite-modern-cpp = callPackage ./sqlite-modern-cpp {};

  tsl-hat-trie = callPackage ./tsl-hat-trie.nix {};
in {
  # Shared dependecies of kagome
  inherit boost-di gtest_cmake microsoft-gsl_cmake rapidjson_cmake soralog;

  # Unique dependecies of kagome
  backward-cpp_cmake = callPackage ./backward-cpp.nix {};

  binaryen_cmake = callPackage ./binaryen.nix {};

  cpp-libp2p = callPackage ./cpp-libp2p {
    inherit boost-di gtest_cmake microsoft-gsl_cmake soralog sqlite-modern-cpp tsl-hat-trie;
  };

  erasure-coding-crust = callPackage ./erasure-coding-crust.nix {}; 

  jsonrpc-lean = callPackage ./jsonrpc-lean.nix {
    inherit rapidjson_cmake;
  };

  libsecp256k1_cmake = callPackage ./libsecp256k1.nix {};

  prometheus-cpp = callPackage ./prometheus-cpp.nix {};

  rocksdb_cmake = callPackage ./rocksdb.nix {};

  scale-codec-cpp = callPackage ./scale-codec-cpp.nix {
    inherit microsoft-gsl_cmake;
  };

  schnorrkel-crust = callPackage ./schnorrkel-crust.nix {};

  wavm = callPackage ./wavm.nix {
    # Override for Zen 3 support
    inherit (pkgs.llvmPackages_12) libllvm;
  };

  xxHash_cmake  = callPackage ./xxhash.nix {};
}
