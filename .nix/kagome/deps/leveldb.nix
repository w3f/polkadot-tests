{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "leveldb";
  version = "1.22";

  src = fetchFromGitHub {
    owner = "google";
    repo = "leveldb";
    rev = "${version}";
    sha256 = "0qrnhiyq7r4wa1a4wi82zgns35smj94mcjsc7kfs1k6ia9ys79z7";
  };

  nativeBuildInputs = [ cmake ];

  # FIXME: db_test fails on 21.05
  # doCheck = true;

  postInstall = ''
    mkdir $out/bin
    cp leveldbutil $out/bin
  '';
}
