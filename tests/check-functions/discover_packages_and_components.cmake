
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

# 3 folders, one has 2 components
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

#message(FATAL_ERROR "Components of Unit: ${components_unit} / ${components_var}")
#message(STATUS "${output_var} / ${folder_var} / ${components_var} / ${dependency_var}")
