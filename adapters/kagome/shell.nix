{ system ? builtins.currentSystem }:

(builtins.getFlake "git+file:./../..").packages.${system}.kagome-adapter
