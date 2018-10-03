
include(RunCMake)

# those functions should be able to source the boost-cmake project content
set(boostcmake_TEST_OPTIONS "-DBOOST_CMAKE_LOCATION=${boostcmake_LOCATION}")

# utility functions
run_cmake(name_to_package_components)
run_cmake(parse_all_libraries)
run_cmake(parse_all_libraries_wrong_parameters_no_path)
run_cmake(parse_all_libraries_wrong_parameters_no_output)
