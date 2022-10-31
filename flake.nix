{
  description = "W3F Polkadot Protocol Testsuite";

  inputs = {
    # Local git submodules (needs manual update)
    gossamer-submodule = {
      url = "git+file:./hosts/gossamer";
      flake = false;
    };
    kagome-submodule = {
      url = "git+file:./hosts/kagome";
      flake = false;
    };
    substrate-submodule = {
      url = "git+file:./hosts/substrate";
      flake = false;
    };

    # Nix utils libraries
    utils.url = "github:numtide/flake-utils";

    # Rust toolchain parsing and build tools
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self,  utils, nixpkgs, fenix, naersk, ... } @ inputs:
    utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        # Provide commen shorthands
        pkgs = nixpkgs.legacyPackages.${system};

        # Intialize rust toolchain based on toolchain file
        rustToolchain = fenix.packages.${system}.fromToolchainFile {
      	  file = ./rust-toolchain.toml;
      	  sha256 = "9+zeT1DZM0WEs3FoHnzVh7XRHiT4Xc7IWZnYOJFGYF8=";
        };

        naerskToolchain = naersk.lib.${system}.override {
          rustc = rustToolchain;
          cargo = rustToolchain;
        };

        # Intialize package set
        submodules = {
          inherit (inputs) gossamer-submodule kagome-submodule substrate-submodule;
        };

        packages = import ./.nix/packages.nix {
          inherit self pkgs submodules;
          naersk = naerskToolchain;
        };

      in {
        devShells = {
          # Shell including all required dependecies
          default = pkgs.mkShell {
            inputsFrom = builtins.attrValues self.packages.${system};
            buildInputs = [ pkgs.gnumake ];
          };

          # General shell for substrate-based development
          substrate = pkgs.callPackage ./.nix/substrate/env.nix {
            inherit rustToolchain;
          };
        };

        # All testsuite related binaries and testsuite itself
        packages = packages.hosts // packages.testsuite // {
          inherit rustToolchain;
          default = packages.polkadot-testsuite;
        };
      }
    ) // {
      # We currently only check on x86_64-linux
      checks.x86_64-linux = self.packages.x86_64-linux;
    };
}
