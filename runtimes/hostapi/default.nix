{ polkadot-tests, naerskWasm }:

naerskWasm.buildPackage rec {
  name = "hostapi-runtime";
  inherit (polkadot-tests) version;

  src = "${polkadot-tests.src}/runtimes/hostapi";

  overrideMain = _: {
    name = "hostapi-runtime-${version}.compact.wasm";

    installPhase = ''
      cp out/release/wbuild/hostapi-runtime/hostapi_runtime.compact.wasm $out
    '';
  };
}
