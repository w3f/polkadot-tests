{ polkadot-tests, buildGoModule, patchelf, glibc }:

buildGoModule rec {
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

  vendorSha256 = "1bgw7y102rn06if7y4q90hb2gfmp30jby4v0lyyzlr9xmpjnj5hp";

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
