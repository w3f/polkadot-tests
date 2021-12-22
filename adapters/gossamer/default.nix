{ polkadot-tests, buildGo117Module, patchelf, glibc }:

buildGo117Module rec {
  pname = "gossamer-adapter";
  inherit (polkadot-tests) src version;

  modRoot = "adapters/gossamer";

  runVend = true;

  vendorSha256 = "rQeWNfLKtykhSu1yuXq2T4LNhx59lVu7kp5Jmw5cN40=";

  nativeBuildInputs = [ patchelf ];

  postInstall = ''
    mkdir $out/lib
    cp vendor/github.com/wasmerio/go-ext-wasm/wasmer/libwasmer.so $out/lib
    patchelf --set-rpath "$out/lib:${glibc}/lib" $out/bin/${pname}
  '';
}
