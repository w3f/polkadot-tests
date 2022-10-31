{ polkadot-tests, buildGo118Module, patchelf, glibc }:

buildGo118Module rec {
  pname = "gossamer-adapter";
  inherit (polkadot-tests) src version;

  modRoot = "adapters/gossamer";

  proxyVendor = true;

  vendorSha256 = "nExywPbVXEsEsTJBPfzCYpxub21ZgIl23BxfIkrEpZ0=";

  nativeBuildInputs = [ patchelf ];

  postInstall = ''
    mkdir $out/lib
    cp /build/go/pkg/mod/github.com/wasmerio/go-ext-wasm@*/wasmer/libwasmer.so $out/lib
    patchelf --set-rpath "$out/lib:${glibc}/lib" $out/bin/${pname}
  '';
}
