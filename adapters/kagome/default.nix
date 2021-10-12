{ polkadot-tests, stdenv, cmake, kagome-host, libyamlcpp }:

stdenv.mkDerivation {
  pname = "kagome-adapter";
  inherit (polkadot-tests) src version;

  sourceRoot = "source/adapters/kagome";

  nativeBuildInputs = [ cmake ];

  buildInputs = [ kagome-host libyamlcpp ];

  cmakeFlags = [ "-DHUNTER_ENABLED=FALSE" ];
}
