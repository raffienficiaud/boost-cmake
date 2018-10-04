# Basic sanity checks on the core function for discovery of packages and dependencies


# getting the list of all candidates
boost_get_all_libs(
    PATH "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1"
    RELATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1"
    OUTPUT_VAR var_all_libraries)

boost_discover_packages_and_components(
    LIST_FOLDERS ${var_all_libraries}
    RELATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1"
    PACKAGES_OUTPUT_VAR output_var
    PACKAGES_FOLDER_VAR folder_var
    COMPONENTS_OUTPUT_VAR components_var
    DEPENDENCY_VAR dependency_var
)

# 3 folders/packages, one has 2 components
list(LENGTH components_var _var_component_length)
if(NOT _var_component_length EQUAL 4)
    message(FATAL_ERROR "All component size is incorrect: ${_var_component_length} != 4")
endif()


# discovering the components
boost_package_get_all_components(
    PACKAGE "unit"
    OUTPUT_VAR components_unit
    ALL_COMPONENTS ${components_var})

list(LENGTH components_unit _var_unit_length)
if(NOT _var_unit_length EQUAL 2)
    message(FATAL_ERROR "Unit component size is incorrect: ${_var_unit_length} != 2")
endif()

list(FIND components_unit "build" _var_index)
if(_var_index EQUAL -1)
    message(FATAL_ERROR "Unit component 'build' not found")
endif()

list(FIND components_unit "test" _var_index)
if(_var_index EQUAL -1)
    message(FATAL_ERROR "Unit component 'test' not found")
endif()

# checks the dependency discovery
boost_package_get_all_dependencies(
    COMPONENT "unit:test"
    OUTPUT_VAR unit_test_dependencies
    ALL_DEPENDENCIES ${dependency_var}
)

list(LENGTH unit_test_dependencies _var_dep_unit_test)
if(NOT _var_dep_unit_test EQUAL 1)
    message(FATAL_ERROR "Unit:build component dependency size is incorrect: ${_var_dep_unit_test} != 1")
endif()

list(FIND unit_test_dependencies "test:build" _var_index)
if(_var_index EQUAL -1)
    message(FATAL_ERROR "Unit:test component does not indicate 'test:build' as parent")
endif()

# should work with empty dependencies
boost_package_get_all_dependencies(
    COMPONENT "test:build"
    OUTPUT_VAR test_build_dependencies
    ALL_DEPENDENCIES ${dependency_var}
)

list(LENGTH test_build_dependencies _var_dep_test_build)
if(NOT _var_dep_test_build EQUAL 0)
    message(FATAL_ERROR "Test:build component dependency size is incorrect: ${_var_dep_test_build} != 0")
endif()

#message(FATAL_ERROR "Components of Unit: ${components_unit} / ${components_var}")
#message(STATUS "${output_var} / ${folder_var} / ${components_var} / ${dependency_var}")
