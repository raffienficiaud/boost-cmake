
include(RunCMake)

# those functions should be able to source the boost-cmake project content
set(boostcmake_TEST_OPTIONS "-DBOOST_CMAKE_LOCATION=${boostcmake_LOCATION}")

# utility functions
run_cmake(name_to_package_components)
run_cmake(parse_all_libraries)
run_cmake(parse_all_libraries_wrong_parameters_no_path)
run_cmake(parse_all_libraries_wrong_parameters_no_output)


# passing wrong arguments to the function
set(boostcmake_TEST_OPTIONS_INIT ${boostcmake_TEST_OPTIONS})

# no option, should raise an error
set(RunCMake-stderr-file "discover_package_missing_relative_path.txt")
set(boostcmake_TEST_OPTIONS ${boostcmake_TEST_OPTIONS_INIT})
run_cmake(discover_packages_and_components_wrong_arguments)
unset(RunCMake-stderr-file)

# non existing path, raises an error
set(RunCMake-stderr-file "discover_package_non_existing_relative_path.txt")
set(boostcmake_TEST_OPTIONS "-DRELATIVE_PATH_OPTION=NON-EXISTING" ${boostcmake_TEST_OPTIONS_INIT})
run_cmake(discover_packages_and_components_wrong_arguments)
unset(RunCMake-stderr-file)

if(FALSE)
# PACKAGES_OUTPUT_VAR
# PACKAGES_FOLDER_VAR
# COMPONENTS_OUTPUT_VAR
# DEPENDENCY_VAR

set(boostcmake_TEST_OPTIONS "-DRELATIVE_PATH=NON-EXISTING" ${boostcmake_TEST_OPTIONS_INIT})
run_cmake(discover_packages_and_components_wrong_arguments)
unset(RunCMake-stderr-file)
endif()



# core package function
set(boostcmake_TEST_OPTIONS ${boostcmake_TEST_OPTIONS_INIT})
run_cmake(discover_packages_and_components)
