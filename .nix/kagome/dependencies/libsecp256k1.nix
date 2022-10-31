{ stdenv, fetchFromGitHub, cmake }: 

stdenv.mkDerivation rec {
  pname = "libsecp256k1";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "soramitsu-libsecp256k1";
    rev = "v${version}"; 
    sha256 = "a2ywjdgNUw1zcXjVE+Uzp19GejRYcuyYqQQFYUVyk1I=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    # TODO: Flags just copied from hunter. Fix and run testsuite
    "-DSECP256K1_BUILD_TEST=OFF"
  ];
}
