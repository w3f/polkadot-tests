{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "boost_di";
  version = "1.1.0+cmake";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "soramitsu-boost-di";
    rev = "a20eebb6decfba55867a6920e00443a9485f50cd";
    sha256 = "eRtB/XSGTDU1n6kw4FAUr4fB6Q9xCrNF2OQE8aHEXDs=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    # TODO: Flags just copied from hunter. Fix and run testsuite
    "-DBOOST_DI_OPT_BUILD_TESTS=OFF"
    "-DBOOST_DI_OPT_BUILD_EXAMPLES=OFF"
  ];
}
