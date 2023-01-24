{ lib, gossamer-submodule, buildGo118Module, patchelf, glibc }:

buildGo118Module rec {
  pname = "gossamer-host";

  src = gossamer-submodule; 
  version = gossamer-submodule.shortRev;

  patches = [ ./config_path.patch ];

  postPatch = ''
    substituteAllInPlace chain/dev/defaults.go
    substituteAllInPlace chain/gssmr/defaults.go
    substituteAllInPlace chain/kusama/defaults.go
    substituteAllInPlace chain/polkadot/defaults.go
  '';

  proxyVendor = true;

  vendorSha256 = "eJTKhwA0Q0ZA0ntjJ8BQTBbnrX6e3G7n9hs3K0nF8dE=";

  subPackages = [ "cmd/gossamer" ];

  nativeBuildInputs = [ patchelf ];

  doCheck = false; # Patching default.go breaks some tests

  postInstall = ''
    mkdir $out/lib

    cp /build/go/pkg/mod/github.com/wasmerio/go-ext-wasm@*/wasmer/libwasmer.so $out/lib
    patchelf --set-rpath "$out/lib:${glibc}/lib" $out/bin/gossamer

    mv $out/bin/gossamer $out/bin/${pname}

    mkdir $out/share
    cp -r chain/* $out/share
    rm $out/share/*/*.go
  '';
}
