{ polkadot-tests
, stdenv
, cmake
, openssl
, protobuf
, gtest_cmake
, boost172
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
, boost-di
, prometheus-cpp
, schnorrkel-crust
, libnsl
, zstd
, scale-codec-cpp
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
    libnsl
    protobuf

    # Patched upstream dependencies
    backward-cpp_cmake
    gtest_cmake
    rapidjson_cmake

    # Custom packaged dependencies
    boost-di
    jsonrpc-lean
    prometheus-cpp
  ];

  propagatedBuildInputs = [
    boost172
    openssl
    zstd

    binaryen_cmake
    leveldb_cmake
    libsecp256k1_cmake
    microsoft-gsl_cmake
    xxHash_cmake

    cpp-libp2p
    scale-codec-cpp
    schnorrkel-crust
    soralog
    wavm
  ];

  cmakeFlags = [ "-DHUNTER_ENABLED=false" "-DTESTING=false" ];

#  postInstall = ''
#    mkdir $out/share
#    cp -r $src/node/config $out/share
#  '';
}
