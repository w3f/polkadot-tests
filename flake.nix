{
  description = "W3F Polkadot Testsuite";

  inputs = {
    # Nix base libraries
    utils.url = "github:numtide/flake-utils";

    # Rust nightly, wasm target and toolchain parsing.
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust build tool
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, utils, nixpkgs, fenix, naersk } :
    utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlay
            fenix.overlay
            naersk.overlay
          ];
        };
     in {
        # Shell including all required dependecies
        devShell = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages."${system}";
          buildInputs = with pkgs; [ gnumake jq yq ];
        };

	# All testsuite related binaries and testsuite itself
        packages = pkgs.implementations // pkgs.testsuite;

	# Complete overlay as used internally
        legacyPackages = pkgs;
      }
    ) // {
      # We currently only check on amd64
      checks.x86_64-linux = self.packages.x86_64-linux;

      # Export nixpkgs overlay
      overlay = import ./.nix/overlay.nix { inherit self; };
    };
}
