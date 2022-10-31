{ self, naersk, pkgs, submodules }:

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

    # NOTE: Flake should provide submodules seperately
    #gossamer-submodule = builtins.fetchTree self.modules."hosts/gossamer";
    #kagome-submodule = builtins.fetchTree self.modules."hosts/kagome";
    #substrate-submodule = builtins.fetchTree self.modules."hosts/substrate";
  } // submodules;

  # Implementation dependency derivations (buildable)
  dependencies = import ./kagome/dependencies { inherit pkgs; };

  # Implementation derivations (buildable)
  hosts = with pkgs; {
    # Go implementations
    gossamer-host = callPackage ./gossamer {
      inherit (sources) gossamer-submodule;
    };

    # C++ implementations
    kagome-host = callPackage ./kagome (dependencies // {
      inherit (sources) kagome-submodule;
    });

    # Rust implementations
    substrate-host = callPackage ./substrate {
      inherit (sources) substrate-submodule;
      inherit naersk;
    };
  };

  # Specification Testsuite binaries (buildable)
  testsuite = with pkgs; {
    # Adapters
    substrate-adapter = callPackage ../adapters/substrate {
      inherit (sources) polkadot-tests;
      inherit naersk;
    };
    kagome-adapter    = callPackage ../adapters/kagome {
      inherit (sources) polkadot-tests;
      inherit (hosts) kagome-host;
      inherit (dependencies) scale-codec-cpp;
    };
    gossamer-adapter  = callPackage ../adapters/gossamer {
      inherit (sources) polkadot-tests;
    };

    # Runtimes
    hostapi-runtime = callPackage ../runtimes/hostapi {
      inherit (sources) polkadot-tests;
      inherit naersk;
    };
    tester-runtime  = callPackage ../runtimes/tester {
      inherit (sources) polkadot-tests;
      inherit naersk;
    };

    # Testsuite incl. fixtures
    polkadot-testsuite = callPackage ./testsuite.nix {
      inherit (sources) polkadot-tests;
    };
  };

  # Export some of the package sets as subset.
  virtual = {
    inherit hosts dependencies testsuite;
  };
in
  sources // dependencies // hosts // testsuite // virtual
