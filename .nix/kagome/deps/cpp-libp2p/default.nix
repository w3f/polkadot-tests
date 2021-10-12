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
  version = "c904db6c5fd4925082b9139776b3a87914393fa7";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "cpp-libp2p";
    rev = version;
    sha256 = "SGrYrW7JSYuPi81ohRDgRJNoJKCQCNq+ka/+GUoTmVE=";
  };

  patches = [
    ./dependencies.patch
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


