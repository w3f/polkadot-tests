{ polkadot-tests, gossamer-submodule, buildGo118Module, patchelf, glibc }:

let
  modRoot = "adapters/gossamer";

  postPatch = ''
    substituteInPlace "${modRoot}/go.mod" --replace "../../hosts/gossamer" "${gossamer-submodule}"
  '';
in buildGo118Module rec {
  pname = "gossamer-adapter";
  inherit (polkadot-tests) src version;

  inherit modRoot postPatch;
  overrideModAttrs = _: { inherit postPatch; };

  proxyVendor = true;

  vendorSha256 = "vt21F3+ziMUR0RPrH2OhqBfIjiXBp8n8WVWnE/mGqtQ=";

  nativeBuildInputs = [ patchelf ];

  postInstall = ''
    mkdir $out/lib
    cp /build/go/pkg/mod/github.com/wasmerio/go-ext-wasm@*/wasmer/libwasmer.so $out/lib
    patchelf --set-rpath "$out/lib:${glibc}/lib" $out/bin/${pname}
  '';
}
