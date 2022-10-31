{ stdenv, fetchFromGitHub, cmake, boost172, microsoft-gsl_cmake }:

stdenv.mkDerivation rec {
  pname = "scale-codec-cpp";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = pname;
    rev = "v${version}";
    sha256 = "UotIC2m78Ma5Ep3kLgeUWbPVLNREmX/TncCFfkkDlJ8=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost172 microsoft-gsl_cmake ];

  cmakeFlags = [ "-DHUNTER_ENABLED=NO" ];
}
