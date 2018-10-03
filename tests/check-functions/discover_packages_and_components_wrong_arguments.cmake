
# getting the list of all candidates
boost_get_all_libs(
    PATH "${CMAKE_CURRENT_SOURCE_DIR}/fake_boost1"
    OUTPUT_VAR var_all_libraries)

message(STATUS "PASSED RELATIVE_PATH: '${RELATIVE_PATH_OPTION}'")

set(all_options)
if(RELATIVE_PATH_OPTION)
    set(all_options ${all_options} RELATIVE_PATH ${RELATIVE_PATH_OPTION})
endif()

boost_discover_packages_and_components(
    LIST_FOLDERS ${var_all_libraries}
    ${all_options}
)
