{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "prometheus-cpp";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "jupp0r";
    repo = "prometheus-cpp";
    rev = "v${version}";
    sha256 = "0lzfyphk8g8h3f9yv0zpi3jlcb391m1hxv0h0rkrgm3sykmwiaz0";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DENABLE_TESTING=OFF"
    "-DUSE_THIRDPARTY_LIBRARIES=OFF"
    "-DOVERRIDE_CXX_STANDARD_FLAGS=OFF"
    "-DENABLE_PULL=OFF"
    "-DENABLE_PUSH=OFF"
    "-DENABLE_COMPRESSION=OFF"
  ];
}
