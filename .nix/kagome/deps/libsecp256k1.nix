{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "libsecp256k1";
  version = "0.0.0+cmake";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "soramitsu-libsecp256k1-copy";
    rev = "c7630e1bac638c0f16ee66d4dce7b5c49eecbaa5";
    sha256 = "a2ywjdgNUw1zcXjVE+Uzp19GejRYcuyYqQQFYUVyk1I=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    # TODO: Flags just copied from hunter. Fix and run testsuite
    "-DSECP256K1_BUILD_TEST=OFF"
  ];
}
