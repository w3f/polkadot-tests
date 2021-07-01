{ polkadot-tests, stdenv }:

stdenv.mkDerivation {
  pname = "polkadot-testsuite";
  inherit (polkadot-tests) src version;

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r runtests.jl fixtures helpers $out/bin
  '';

  passthru.exePath = "/bin/runtests.jl";
}
