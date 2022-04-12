{ stdenv, fetchFromGitHub, catch, cmake }:

stdenv.mkDerivation rec {
  pname = "microsoft_gsl";
  version = "2.1.0+cmake";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "GSL";
    rev = "0551cad46788790fa421cf1cb0575a1e3e12c131";
    sha256 = "0yzg1q3vdjr8qlaxssazqy5iwllscjh8qd2lqssy0nq0apkxkjzs";
  };

  nativeBuildInputs = [ catch cmake ];

  # https://github.com/microsoft/GSL/issues/806
  cmakeFlags = [ "-DCMAKE_CXX_FLAGS=-Wno-catch-value" ];

  doCheck = true;
}
