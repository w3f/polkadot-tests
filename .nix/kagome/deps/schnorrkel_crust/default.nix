{ rustPlatform, fetchFromGitHub, cmake }:

rustPlatform.buildRustPackage rec {
  pname = "schnorrkel_crust";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Soramitsu";
    repo = "soramitsu-sr25519-crust";
    rev = "5921a34980af6bbfb965dc5b2499a37e316a391c";
    sha256 = "0s2xlbgjl25cmhzg8q1z3wjibm0zg6s6kdg10pxa8h3rf58bi2bn";
  };

  cargoSha256 = "13alf4yh2bmbksimky076ajsxs0ps1kbznaxsdvbr48bqc16w7vk";

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
