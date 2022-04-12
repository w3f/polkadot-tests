{ polkadot-tests, naerskWasm }:

naerskWasm.buildPackage rec {
  name = "hostapi-runtime";
  inherit (polkadot-tests) version;

  src = "${polkadot-tests.src}/runtimes/hostapi";

  overrideMain = _: {
    name = "hostapi-runtime-${version}.default.wasm";

    installPhase = ''
      cp target/release/wbuild/hostapi-runtime/hostapi_runtime.compact.wasm $out
    '';
  };
}
