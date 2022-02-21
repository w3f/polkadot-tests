{ self }:

final: prev:

let
  # Shared source inputs
  sources = {
    # Add polkadot-tests source
    polkadot-tests = {
      src = self;
      version = if self ? rev 
                then (builtins.substring 0 7 self.rev)
                else self.lastModifiedDate;
    };

    # Provide submodules seperately
    gossamer-submodule = builtins.fetchTree self.modules."hosts/gossamer";
    kagome-submodule = builtins.fetchTree self.modules."hosts/kagome";
    substrate-submodule = builtins.fetchTree self.modules."hosts/substrate";
  };

  # Support derivations and environments used during build
  support = with final; {
    # Default rust to use for all build
    rustWasm = fenix.fromToolchainFile {
      file = ../rust-toolchain.toml;
      sha256 = "9+zeT1DZM0WEs3FoHnzVh7XRHiT4Xc7IWZnYOJFGYF8=";
    };

    # Platform with nightly wasm rust
    rustWasmPlatform = makeRustPlatform {
      rustc = rustWasm;
      cargo = rustWasm;
    };

    # Naersk with nightly and wasm rust
    naerskWasm = naersk.override {
      rustc = rustWasm;
      cargo = rustWasm;
    };
  };

  # Implementation dependency derivations (buildable)
  dependencies = import ./kagome/deps.nix final prev;

  # Implementation derivations (buildable)
  implementations = with final; {
    # Go implementations
    gossamer-host = callPackage ./gossamer {};

    # C++ implementations
    kagome-host = callPackage ./kagome {};

    # Rust implementations
    substrate-host = callPackage ./substrate {};
  };

  # Specification Testsuite binaries (buildable)
  testsuite = with final; {
    # Adapters
    substrate-adapter = callPackage ../adapters/substrate {};
    kagome-adapter    = callPackage ../adapters/kagome {};
    gossamer-adapter  = callPackage ../adapters/gossamer {};

    # Runtimes
    hostapi-runtime = callPackage ../runtimes/hostapi {};
    tester-runtime  = callPackage ../runtimes/tester {};

    # Testsuite incl. fixtures
    polkadot-testsuite = callPackage ./testsuite.nix {};
  };

  # Export some of the package sets as subset.
  virtual = {
    inherit implementations dependencies testsuite;
  };
in
  sources // support // dependencies // implementations // testsuite // virtual
