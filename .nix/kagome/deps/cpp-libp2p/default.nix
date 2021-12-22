{ lib
, stdenv
, fetchFromGitHub
, cmake
, gtest_cmake
, boost172
, protobuf
, openssl
, microsoft-gsl_cmake
, soralog
, boost-di
, tsl-hat-trie
, sqlite-modern-cpp
, c-ares
, withTests ? false
}:


stdenv.mkDerivation rec {
  name = "cpp-libp2p-${lib.substring 0 7 version}";
  version = "69299a8182a976fbe6654ed367ba1fb5d89800e0";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "cpp-libp2p";
    rev = version;
    sha256 = "YB3Di5QEehWY0tsLp9TJUIvwdy6QXj/V0HB+aaHtubU=";
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
    microsoft-gsl_cmake

    boost-di
    tsl-hat-trie
  ];

  propagatedBuildInputs = [
    openssl
    protobuf

    boost172
    soralog

    c-ares.cmake-config
    sqlite-modern-cpp
  ];

  doCheck = withTests;

  cmakeFlags = [
    "-DHUNTER_ENABLED=false"
    "-DTESTING=${lib.boolToString withTests}"
    "-DEXAMPLES=false"
    "-DEXPOSE_MOCKS=true"
  ];
}


