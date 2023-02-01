{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "erasure-coding-crust";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "soramitsu";
    repo = pname;
    rev = "v${version}"; 
    sha256 = "Xao43logjXYUmltGK85doj+qj3YHxdoom/6NVenQYfQ=";
  };

  cargoSha256 = "p7mmQu7iHnEu1u3nw4hKdUMlTCca6d+OTyLaYttnPeg=";

  postInstall = let
    cname = "erasure_coding_crust";
  in ''
    cp -r include $out

    mkdir -p $out/lib/cmake/${cname}
    cat > $out/lib/cmake/${cname}/${cname}Config.cmake << EOF
      add_library(${cname}::${cname} STATIC IMPORTED)
      set_target_properties(${cname}::${cname} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "$out/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "$out/lib/lib${cname}.a"
      )
      set_property(TARGET ${cname}::${cname} APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE
      )
      target_link_libraries(${cname}::${cname} INTERFACE
        pthread
        -Wl,--no-as-needed
        dl
      )
    EOF
  '';
}
