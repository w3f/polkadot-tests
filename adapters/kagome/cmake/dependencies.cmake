hunter_add_package(yaml-cpp)
find_package(yaml-cpp REQUIRED)

# Fix inconsistency between hunterized and upstream package (+ CMake oddity fix)
if(NOT TARGET yaml-cpp)
  set_target_properties(yaml-cpp::yaml-cpp PROPERTIES IMPORTED_GLOBAL true)
  add_library(yaml-cpp ALIAS yaml-cpp::yaml-cpp)
endif()

hunter_add_package(kagome)
find_package(kagome REQUIRED CONFIG)

message(STATUS "Found kagome: ${kagome_INCLUDE_DIRS}")

include(
  ${CMAKE_SOURCE_DIR}/../../hosts/kagome/cmake/dependencies.cmake
  )
