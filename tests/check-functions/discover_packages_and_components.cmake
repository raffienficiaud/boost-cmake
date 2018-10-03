
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

message(FATAL_ERROR "${output_var} / ${folder_var}")
