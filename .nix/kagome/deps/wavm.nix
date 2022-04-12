{ stdenv, fetchFromGitHub, cmake, libllvm }:

stdenv.mkDerivation rec {
  pname = "WAVM";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "WAVM";
    rev = version;
    sha256 = "Rds1wa1JwwgoEuAdi6tNz80Bi+bF7bKk+aDGRpdAZ7w=";
  };

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [ libllvm ];

  cmakeFlags = [ "-DHUNTER_ENABLED=NO" ];
}
