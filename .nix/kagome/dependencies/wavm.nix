{ stdenv, fetchFromGitHub, cmake, libllvm }:

stdenv.mkDerivation rec {
  pname = "WAVM";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "WAVM";
    rev = version;
    sha256 = "RL8iam69DO2TkcSAqJG2CW/pgidFPFKJ2jHyY1HjHnc=";
  };

  nativeBuildInputs = [ cmake ];

  propagatedBuildInputs = [ libllvm ];

  cmakeFlags = [ "-DHUNTER_ENABLED=NO" ];
}
