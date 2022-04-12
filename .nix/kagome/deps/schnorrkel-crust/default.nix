{ rustPlatform, fetchFromGitHub, cmake }:

rustPlatform.buildRustPackage rec {
  pname = "schnorrkel_crust";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "Soramitsu";
    repo = "soramitsu-sr25519-crust";
    rev = version;
    sha256 = "EiuqKkU0BhWF7LaQIMiDH1POK0yz8YN3Lk1IsjVoFKc=";
  };

  cargoSha256 = "G1LI9Ibx/3t2E2wzMmYTQrK8hrV9+4zYR2sm8iX2G84=";

  postInstall = ''
    cp -r include $out

    mkdir -p $out/lib/cmake/${pname}
    cat > $out/lib/cmake/schnorrkel_crust/schnorrkel_crustConfig.cmake << EOF
      add_library(schnorrkel_crust::schnorrkel_crust STATIC IMPORTED)
      set_target_properties(schnorrkel_crust::schnorrkel_crust PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "$out/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "$out/lib/libschnorrkel_crust.a"
      )
      set_property(TARGET schnorrkel_crust::schnorrkel_crust APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE
      )
      target_link_libraries(schnorrkel_crust::schnorrkel_crust INTERFACE
        pthread
        -Wl,--no-as-needed
        dl
      )
    EOF
  '';
}
