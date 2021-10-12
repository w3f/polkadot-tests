{ stdenv, fetchFromGitHub, cmake, libllvm }:

stdenv.mkDerivation rec {
  pname = "WAVM";
  version = "2021-09-13";

  src = fetchFromGitHub {
    owner = "WAVM";
    repo = "WAVM";
    rev = "nightly/${version}";
    sha256 = "+ZJy2adg/150T6MZmm+KL0l/C6AnD64G87ksuvqQFyI=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libllvm ];
}
