{ kagome-submodule
, stdenv
, cmake
, openssl
, protobuf
, gtest_cmake
, boost172
, microsoft-gsl_cmake
, soralog
, rocksdb_cmake
, rapidjson_cmake
, jsonrpc-lean
, xxHash_cmake
, libsecp256k1_cmake
, binaryen_cmake
, backward-cpp_cmake
, wavm
, cpp-libp2p
, boost-di
, erasure-coding-crust
, prometheus-cpp
, schnorrkel-crust
, libnsl
, zstd
, scale-codec-cpp
}:

stdenv.mkDerivation rec {
  pname = "kagome-host";

  src = kagome-submodule;
  version = kagome-submodule.shortRev;

  #sourceRoot = "source/hosts/kagome";

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

    # Patched upstream dependencies
    backward-cpp_cmake
    gtest_cmake

    # Custom packaged dependencies
    boost-di
    jsonrpc-lean
  ];

  propagatedBuildInputs = [
    boost172
    libnsl
    openssl
    zstd

    binaryen_cmake
    libsecp256k1_cmake
    microsoft-gsl_cmake
    rapidjson_cmake
    rocksdb_cmake
    xxHash_cmake

    cpp-libp2p
    erasure-coding-crust
    prometheus-cpp
    scale-codec-cpp
    schnorrkel-crust
    soralog
    wavm
  ];

  cmakeFlags = [ "-DHUNTER_ENABLED=false" "-DTESTING=false" ];

  postInstall = ''
    ln -s $out/bin/kagome/kagome $out/bin/${pname}
  '';
}
