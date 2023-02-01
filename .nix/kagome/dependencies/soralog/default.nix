{ stdenv
, fetchFromGitHub
, cmake
, gtest_cmake
, libyamlcpp
, fmt_6
}:

stdenv.mkDerivation rec {
  pname = "soralog";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner  = "soramitsu";
    repo   = "soralog";
    rev    = "v${version}";
    sha256 = "zjoBQLknPNlNhEIbu60nIYsEZefqmMDfg9myVsAyMq0=";
  };

  patches = [ ./yaml-cpp.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gtest_cmake ];

  propagatedBuildInputs = [ libyamlcpp fmt_6 ];

  cmakeFlags = [ "-DHUNTER_ENABLED=OFF" "-DTESTING=OFF" "-DEXAMPLES=OFF" ];
}
