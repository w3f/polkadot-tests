{ rustPlatform, fetchFromGitHub, cmake }:

rustPlatform.buildRustPackage rec {
  pname = "schnorrkel_crust";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "Soramitsu";
    repo = "soramitsu-sr25519-crust";
    rev = "62795502ac50b82f3d5a1b084513f6defea002ba";
    sha256 = "qModF/eSqOsuYCjBZk/ikmI8Gov9BKNzjqdPgMwa6dE=";
  };

  cargoSha256 = "4Gx/EoKsQftrwtI9pXj1N/2/pqkwG7s+OImdGKEnmNY=";

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
