{ stdenv, fetchFromGitHub, cmake, rapidjson_cmake }:

stdenv.mkDerivation {
  pname = "jsonrpc-lean";
  version = "2020-04-30";

  src = fetchFromGitHub {
    owner = "xDimon";
    repo = "jsonrpc-lean";
    rev = "6c093da8670d7bf56555f166f8b8151f33a5d741";
    sha256 = "1sxyr8xayldpfycma7hkxp8k9v427mg7a0bb7xkzgs6c4a4mvjqp";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ rapidjson_cmake ];

  cmakeFlags = [ "-DHUNTER_ENABLED=false" ];
}
