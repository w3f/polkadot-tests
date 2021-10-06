{ stdenv
, fetchFromGitHub
, cmake
, gtest_cmake
, libyamlcpp
, fmt_6
}:

stdenv.mkDerivation rec {
  pname = "soralog";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner  = "soramitsu";
    repo   = "soralog";
    rev    = "v${version}";
    sha256 = "d2wufgRbEHF1Kzu8QH6RncTkRfCMZTjP9qqtbtJoNrI=";
  };

  patches = [ ./yaml-cpp.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gtest_cmake ];

  propagatedBuildInputs = [ libyamlcpp fmt_6 ];

  cmakeFlags = [ "-DHUNTER_ENABLED=OFF" "-DEXAMPLES=OFF" ];
}
