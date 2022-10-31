{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "tsl_hat_trie";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "masterjedy";
    repo = "hat-trie";
    rev = "4fdfc75e75276185eed4b748ea09671601101b8e";
    sha256 = "4oeTE5cREJdyUdFDc+q/KmOc6CyB+sBL99dZFpRtAlY=";
  };

  nativeBuildInputs = [ cmake ];
}
