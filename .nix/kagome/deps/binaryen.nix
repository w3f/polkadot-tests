{ fetchFromGitHub, binaryen }:

binaryen.overrideAttrs (super: rec {
  name = "${super.pname}-${version}";
  version = "1.38.28-p1";

  src = fetchFromGitHub {
    owner = "warchant";
    repo = "binaryen";
    rev = version;
    sha256 = "1x2s76klkqc6306szzm856n3w9ga18g97ah00gvcy79yk9b3ag3y";
  };

  patches = [];
})
