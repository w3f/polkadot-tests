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
  pname = "cpp-libp2p";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = "cpp-libp2p";
    rev = "v${version}";
    sha256 = "toP3VnGs2HwfhpuQC94hSdPZXNFotYTzo1eRY33xfVg=";
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
  ];

  propagatedBuildInputs = [
    boost172
    openssl
    protobuf

    c-ares.cmake-config

    soralog
    boost-di
    sqlite-modern-cpp
    tsl-hat-trie
  ];

  doCheck = withTests;

  cmakeFlags = [
    "-DHUNTER_ENABLED=false"
    "-DTESTING=${lib.boolToString withTests}"
    "-DEXAMPLES=false"
    "-DEXPOSE_MOCKS=true"
  ];
}
