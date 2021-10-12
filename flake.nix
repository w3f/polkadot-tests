{
  description = "Polkadot Testsuite";

  inputs = {
    # Nix base libraries
    utils.url = "github:numtide/flake-utils";

    # Overlay used for nightly rust support
    mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };

    # Rust build tool
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, utils, nixpkgs, mozilla, naersk } :
    utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        rust-overlay = import "${mozilla}/rust-overlay.nix";

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlay
            naersk.overlay
            rust-overlay
          ];
        };

     in {

        # WIP: Currently useless
        apps = {
          testsuite = utils.lib.mkApp {
            drv = pkgs.polkadot-testsuite;
          };
        };

        # Shell including all required dependecies
        devShell = pkgs.mkShell {
          pname = "polkadot-tests-env";
          inherit (pkgs.polkadot-tests) version;

          inputsFrom = builtins.attrValues self.packages."${system}";
          buildInputs = [ pkgs.gnumake ];
        };

        packages = pkgs.implementations // pkgs.testsuite;

        legacyPackages = pkgs;
      }
    ) // {
      checks.x86_64-linux = self.packages.x86_64-linux;

      overlay = import ./.nix/overlay.nix { inherit self; };
    };
}
