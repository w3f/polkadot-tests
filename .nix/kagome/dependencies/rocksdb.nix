{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "rocksdb";
  version = "7.2.2";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = pname;
    rev = "v${version}";
    sha256 = "DoCG/fonq5QjM5RBkhd6mprPFPlvsR4rd7oV7/s8PdE=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DWITH_TESTS=OFF" "-DPORTABLE=ON" "-DWITH_GFLAGS=OFF" ];
}
