
message(STATUS "In Unit: current package = ${CURRENT_PACKAGE}")

set(_current_package "UNIT")
set(BOOST_LIB_${_current_package}_COMPONENTS "build" "test")

set(BOOST_LIB_${_current_package}_COMPONENTS_TEST_DEPENDENCY
  "test:build"
)