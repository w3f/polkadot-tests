{ stdenv
, fetchFromGitHub
, cmake
, gtest_cmake
, libyamlcpp
, fmt_6
}:

stdenv.mkDerivation rec {
  pname = "soralog";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner  = "soramitsu";
    repo   = "soralog";
    rev    = "v${version}";
    sha256 = "15dkb9mvzcjfzr305zip2p359a9w6d6rgki93ycpmjdb39kjpab7";
  };

  patches = [ ./yaml-cpp.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gtest_cmake ];

  propagatedBuildInputs = [ libyamlcpp fmt_6 ];

  cmakeFlags = [ "-DHUNTER_ENABLED=OFF" "-DEXAMPLES=OFF" ];
}
