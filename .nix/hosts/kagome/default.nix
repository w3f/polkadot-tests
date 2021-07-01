{ polkadot-tests
, stdenv
, cmake
, openssl
, protobuf
, gtest_cmake
, boost172
, microsoft_gsl_cmake
, soralog
, leveldb_cmake
, rapidjson_cmake
, jsonrpc-lean
, xxHash_cmake
, libsecp256k1_cmake
, binaryen_cmake
, cpp-libp2p
, tsl_hat_trie
, boost_di
, prometheus-cpp
, schnorrkel_crust
, libnsl
}:

stdenv.mkDerivation rec {
  pname = "kagome-host";
  inherit (polkadot-tests) src version;

  sourceRoot = "source/hosts/kagome";

  patches = [
    ./dependencies.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    # Working upstream dependencies 
    protobuf
    libnsl

    # Patched upstream dependencies
    gtest_cmake
    rapidjson_cmake

    # Custom packaged dependencies
    soralog
    jsonrpc-lean
    tsl_hat_trie
    boost_di
    prometheus-cpp
  ];

  propagatedBuildInputs = [
    boost172
    openssl

    microsoft_gsl_cmake
    binaryen_cmake
    leveldb_cmake
    xxHash_cmake

    cpp-libp2p
    schnorrkel_crust
    libsecp256k1_cmake
  ];

  cmakeFlags = [ "-DHUNTER_ENABLED=false" "-DTESTING=false" ];

#  postInstall = ''
#    mkdir $out/share
#    cp -r $src/node/config $out/share
#  '';
}
