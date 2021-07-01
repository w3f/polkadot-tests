{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "boost_di";
  version = "1.1.0+cmake";

  src = fetchFromGitHub {
    owner = "masterjedy";
    repo = "di";
    rev = "c5287ee710ad90f5286d0cc2b9e49b72d89267a6";
    sha256 = "1s5zywaab5pzg84lgnw0i8qls86lwirkjnxy3pygvqkxgvji9d41";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    # TODO: Flags just copied from hunter. Fix and run testsuite
    "-DBOOST_DI_OPT_BUILD_TESTS=OFF"
    "-DBOOST_DI_OPT_BUILD_EXAMPLES=OFF"
  ];
}
