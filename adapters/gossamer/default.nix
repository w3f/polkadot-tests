{ polkadot-tests, buildGoModule, patchelf, glibc }:

buildGoModule rec {
  pname = "gossamer-adapter";
  inherit (polkadot-tests) src version;

  modRoot = "adapters/gossamer";

  runVend = true;

  vendorSha256 = "DwlkQbBXx6/QvpiJJr6f+LgKUpuqe979rjwWCUITcNg=";

  nativeBuildInputs = [ patchelf ];

  postInstall = ''
    mkdir $out/lib
    cp vendor/github.com/wasmerio/go-ext-wasm/wasmer/libwasmer.so $out/lib
    patchelf --set-rpath "$out/lib:${glibc}/lib" $out/bin/${pname}
  '';
}
