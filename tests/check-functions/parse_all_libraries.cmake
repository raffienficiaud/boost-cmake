# Checks the correct behaviour of boost_get_all_libs

boost_get_all_libs(PATH "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1"
    OUTPUT_VAR var_all_libraries)

message(STATUS "var_all_libraries='${var_all_libraries}'")

# In this pass, the "folder_to_ignore" is not removed. See other tests on boost_discover_packages_and_components
list(LENGTH var_all_libraries length_all_libraries)
if(NOT length_all_libraries EQUAL 3)
    message(FATAL_ERROR "Erroneous size for the returned list: ${length_all_libraries} != 3")
endif()

list(FIND var_all_libraries "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1/unit" _var_unit)
if(_var_unit EQUAL -1)
    message(FATAL_ERROR "unit library not found")
endif()

list(FIND var_all_libraries "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1/test" _var_test)
if(_var_test EQUAL -1)
    message(FATAL_ERROR "test library not found")
endif()


# other configuration by enforcing the presence of an "include" folder
boost_get_all_libs(PATH "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1"
    OUTPUT_VAR var_all_libraries2
    SHOULD_HAVE_INCLUDE)

message(STATUS "var_all_libraries2='${var_all_libraries2}'")

list(LENGTH var_all_libraries2 length_all_libraries2)
if(NOT length_all_libraries2 EQUAL 1)
    message(FATAL_ERROR "Erroneous size for the returned list: ${length_all_libraries2} != 1")
endif()

list(FIND var_all_libraries "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1/test" _var_test)
if(_var_test EQUAL -1)
    message(FATAL_ERROR "test library not found (2)")
endif()
