{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "googletest-${version}";
  version = "1.8.0-hunter-p11";

  src = fetchFromGitHub {
    owner = "hunter-packages";
    repo = "googletest";
    rev = version;
    sha256 = "n+seZ60G6SWvBynmqy4bmS1WWCqi3lO1zgMOztm5+bw=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" "-DCMAKE_CXX_FLAGS=-Wno-deprecated-copy" ];
}
