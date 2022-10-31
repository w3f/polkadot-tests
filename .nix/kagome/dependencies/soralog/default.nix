{ stdenv
, fetchFromGitHub
, cmake
, gtest_cmake
, libyamlcpp
, fmt_6
}:

stdenv.mkDerivation rec {
  pname = "soralog";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner  = "soramitsu";
    repo   = "soralog";
    rev    = "v${version}";
    sha256 = "6HU1Zz401e6eD0JRr3nLxDG4MGrqHb9+qWV8T6aIPAI=";
  };

  patches = [ ./yaml-cpp.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gtest_cmake ];

  propagatedBuildInputs = [ libyamlcpp fmt_6 ];

  cmakeFlags = [ "-DHUNTER_ENABLED=OFF" "-DTESTING=OFF" "-DEXAMPLES=OFF" ];
}
