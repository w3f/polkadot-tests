{ polkadot-tests, buildGo117Module, patchelf, glibc }:

buildGo117Module rec {
  pname = "gossamer-host";
  inherit (polkadot-tests) src version;

  sourceRoot = "source/hosts/gossamer";

  patches = [ ./config_path.patch ];

  postPatch = ''
    substituteAllInPlace chain/dev/defaults.go
    substituteAllInPlace chain/gssmr/defaults.go
    substituteAllInPlace chain/kusama/defaults.go
    substituteAllInPlace chain/polkadot/defaults.go
  '';

  runVend = true;

  vendorSha256 = "fIEHruO1UTyy68n661E2GrHa3U+WWcI83+SXjGbOQ30=";

  subPackages = [ "cmd/gossamer" ];

  nativeBuildInputs = [ patchelf ];

  doCheck = false; # Patching default.go breaks some tests

  postInstall = ''
    mkdir $out/lib

    cp vendor/github.com/wasmerio/go-ext-wasm/wasmer/libwasmer.so $out/lib
    patchelf --set-rpath "$out/lib:${glibc}/lib" $out/bin/gossamer

    mkdir $out/share
    cp -r chain/* $out/share
    rm $out/share/*/*.go
  '';
}
