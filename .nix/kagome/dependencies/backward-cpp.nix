{ stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "backward-cpp";
  version = "1.6";

  src = fetchFromGitHub {
    owner  = "bombela";
    repo   = pname;
    rev    = "v${version}";
    sha256 = "2k5PjwFxgA/2XPqJrPHxgSInM61FBEcieppBx+MAUKw=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DHUNTER_ENABLED=OFF" "-DBACKWARD_TESTS=OFF" ];
}
