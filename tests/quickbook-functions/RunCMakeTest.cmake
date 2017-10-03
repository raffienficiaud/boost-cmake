
include(RunCMake)

set(boostcmake_TEST_OPTIONS "-DBOOST_CMAKE_LOCATION=${boostcmake_LOCATION}")

# quickbook related functions
run_cmake(quickbook-catalog)
