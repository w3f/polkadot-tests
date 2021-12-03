{ stdenv, fetchFromGitHub, cmake, boost17x, microsoft-gsl_cmake }:

stdenv.mkDerivation rec {
  pname = "scale-codec-cpp";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = pname;
    rev = "v${version}";
    sha256 = "nBYBUZD7rFLsNC7h6crkfx5g9NbbTgTNXoMjTAAS1UM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost17x microsoft-gsl_cmake ];

  cmakeFlags = [ "-DHUNTER_ENABLED=NO" ];
}
