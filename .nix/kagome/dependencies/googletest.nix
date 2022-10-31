{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  name = "googletest-${version}";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "release-${version}";
    sha256 = "SjlJxushfry13RGA7BCjYC9oZqV4z6x8dOiHfl/wpF0="; 
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ 
    "-DBUILD_SHARED_LIBS=ON"
    "-Dgtest_force_shared_crt=TRUE"
    "-DCMAKE_CXX_FLAGS=-Wno-deprecated-copy -Wno-unknown-warning-option" 
  ];
}
