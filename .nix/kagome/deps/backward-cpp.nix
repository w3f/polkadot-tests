{ backward-cpp, cmake }:

backward-cpp.overrideAttrs (super: {
  # Force build with CMake to include package config
  nativeBuildInputs = (super.nativeBuildInputs or []) ++ [ cmake ]; 

  installPhase = null;
})
