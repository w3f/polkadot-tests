{ lib
, stdenv
, fetchFromGitHub
, cmake
, gtest_cmake
, boost172
, protobuf
, openssl
, microsoft_gsl_cmake
, soralog
, boost_di
, tsl_hat_trie
, sqlite-modern-cpp
, c-ares
, withTests ? false
}:


stdenv.mkDerivation rec {
  name = "cpp-libp2p-${lib.substring 0 7 version}";
  version = "393119ee18a6a3f6b8d8deeaaa77e2ad401bd8cb";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "cpp-libp2p";
    rev = version;
    sha256 = "0xjs27xshfhqbdvhya4hj55a6k5y256hv2vrj41qmq1vdjcwmrqq";
  };

  patches = [
    ./dependencies.patch
    ./yaml-cpp.patch
  ] ++ lib.optionals withTests [
    ./test-cares.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gtest_cmake
    microsoft_gsl_cmake

    boost_di
    tsl_hat_trie
    sqlite-modern-cpp
  ];

  propagatedBuildInputs = [
    openssl
    protobuf

    boost172
    soralog

    c-ares.cmake-config
  ];

  doCheck = withTests;

  cmakeFlags = [
    "-DHUNTER_ENABLED=false"
    "-DTESTING=${lib.boolToString withTests}"
    "-DEXAMPLES=false"
    "-DEXPOSE_MOCKS=true"
  ];
}


