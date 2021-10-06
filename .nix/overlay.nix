{ self }:

final: prev:

let
  # Shared source inputs
  sources = {
    # Add polkadot-tests source
    polkadot-tests = {
      src = self;

      version = if self ? rev then (builtins.substring 0 7 self.rev)
                else if self ? lastModifiedDate then self.lastModifiedDate
                else "dirty";
    };
  };

  # Support derivations and environments used during build
  support = with final; {
    # Nigthly rust with rust-std for wasm target
    rustWasm = callPackage ./support/rustWasm.nix {};

    # Platform with nightly wasm rust
    rustWasmPlatform = makeRustPlatform {
      rustc = rustWasm;
      cargo = rustWasm;
    };

    # Naersk with nightly and rust
    naerskWasm = naersk.override {
      rustc = rustWasm;
      cargo = rustWasm;
    };
  };

  # Dependency derivations (buildable)
  dependencies = with final; {
    # C++ dependencies
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
  };

  # Implementation derivations (buildable)
  implementations = with final; {
    # Go implementations
    gossamer-host = callPackage ./hosts/gossamer {};

    # C++ implementations
    kagome-host = callPackage ./hosts/kagome {};

    # Rust implementations
    substrate-host = callPackage ./hosts/substrate {};
  };

  # Specification Testsuite binaries (buildable)
  testsuite = with final; {
    # Adapters
    substrate-adapter = callPackage ./adapters/substrate.nix {};
    kagome-adapter    = callPackage ./adapters/kagome.nix {};
    gossamer-adapter  = callPackage ./adapters/gossamer.nix {};

    # Runtimes
    hostapi-runtime = callPackage ./runtimes/hostapi.nix {};
    tester-runtime  = callPackage ./runtimes/tester.nix {};

    # Testsuite incl. fixtures
    polkadot-testsuite = callPackage ./testsuite {};
  };

  # Environment definitions used for development
  environments = with final; {
    # Polkadot specification
    polkadot-spec = callPackage ./envs/polkadot-spec.nix {};

    # Substrate development environment
    substrate = callPackage ./envs/substrate.nix {};
  };

  # Export some of the package sets as subset.
  virtual = {
    inherit implementations dependencies testsuite environments;
  };
in
  sources // support // dependencies // implementations // testsuite // virtual
