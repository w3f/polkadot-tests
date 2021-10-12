{ stdenv, fetchFromGitHub, cmake, sqlite }:

stdenv.mkDerivation rec {
  pname = "sqlite-modern-cpp";
  version = "3.2+cmake";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "libp2p-sqlite-modern-cpp";
    rev = "fc3b700064cb57ab6b598c9bc7a12b2842f78da2";
    sha256 = "0r5b3w0lawbyd5pa31jhj0jyz52viqabijdyykw5p9n4gninrw21";
  };

  patches = [ ./package_name.patch ];

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ sqlite ];

  cmakeFlags = [ "-DHUNTER_ENABLED=OFF" ];

  doCheck = true;
}
