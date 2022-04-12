{ polkadot-tests, stdenv, cmake, kagome-host, scale-codec-cpp, libyamlcpp }:

stdenv.mkDerivation {
  pname = "kagome-adapter";
  inherit (polkadot-tests) src version;

  sourceRoot = "source/adapters/kagome";

  nativeBuildInputs = [ cmake ];

  buildInputs = [ kagome-host scale-codec-cpp libyamlcpp ];

  cmakeFlags = [ "-DHUNTER_ENABLED=FALSE" ];
}
