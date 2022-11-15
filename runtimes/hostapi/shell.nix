{ system ? builtins.currentSystem }:

(builtins.getFlake "git+file:./../..").devShells.${system}.substrate
