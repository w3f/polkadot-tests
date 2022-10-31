{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "xxHash";
  version = "0.6.5-p0";

  src = fetchFromGitHub {
    owner = "hunter-packages";
    repo = "xxHash";
    rev = version;
    sha256 = "1ccppwg65wcydl2293yr1q81fz7d1bzr8iv8wq3yl28x0q9b8jbs";
  };

  nativeBuildInputs = [ cmake ];
}
