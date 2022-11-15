{ system ? builtins.currentSystem }:

(builtins.getFlake "git+file:./../..").packages.${system}.gossamer-adapter.go-modules
