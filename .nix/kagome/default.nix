{ polkadot-tests
, stdenv
, cmake
, openssl
, protobuf
, gtest_cmake
, boost17x
, microsoft-gsl_cmake
, soralog
, leveldb_cmake
, rapidjson_cmake
, jsonrpc-lean
, xxHash_cmake
, libsecp256k1_cmake
, binaryen_cmake
, backward-cpp_cmake
, wavm
, cpp-libp2p
, tsl-hat-trie
, boost-di
, prometheus-cpp
, schnorrkel-crust
, libnsl
, libllvm
, zstd
}:

stdenv.mkDerivation rec {
  pname = "kagome-host";
  inherit (polkadot-tests) src version;

  sourceRoot = "source/hosts/kagome";

  patches = [
    ./dependencies.patch
    ./zstd.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    # Working upstream dependencies 
    protobuf
    libnsl
    libllvm

    # Patched upstream dependencies
    gtest_cmake
    rapidjson_cmake
    backward-cpp_cmake

    # Custom packaged dependencies
    soralog
    jsonrpc-lean
    tsl-hat-trie
    boost-di
    prometheus-cpp
  ];

  propagatedBuildInputs = [
    boost17x
    openssl
    zstd

    microsoft-gsl_cmake
    binaryen_cmake
    leveldb_cmake
    xxHash_cmake

    cpp-libp2p
    schnorrkel-crust
    libsecp256k1_cmake
    wavm
  ];

  cmakeFlags = [ "-DHUNTER_ENABLED=false" "-DTESTING=false" ];

#  postInstall = ''
#    mkdir $out/share
#    cp -r $src/node/config $out/share
#  '';
}
