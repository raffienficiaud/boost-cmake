
include(RunCMake)

set(boostcmake_TEST_OPTIONS "-DBOOST_CMAKE_LOCATION=${boostcmake_LOCATION}")

# utility functions
run_cmake(name_to_package_components)
