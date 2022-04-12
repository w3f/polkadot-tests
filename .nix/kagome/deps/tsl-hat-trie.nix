{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "tsl_hat_trie";
  version = "0.6.0+cmake";

  src = fetchFromGitHub {
    owner = "masterjedy";
    repo = "hat-trie";
    rev = "343e0dac54fc8491065e8a059a02db9a2b1248ab";
    sha256 = "0rkm2s0pzxpyhzfakq38dd5ydpj31jcqq8w6j507nxhndkh8mlam";
  };

  nativeBuildInputs = [ cmake ];
}
