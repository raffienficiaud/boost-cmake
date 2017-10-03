# This file contains some unit test of the boost-cmake infrastructure


# Highly inspired from the CMake testing infrastructure
function(add_boostcmake_test test)
  set(options )
  set(oneValueArgs TEST_DIR)
  set(multiValueArgs TEST_ARGS)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if("${local_cmd_TEST_DIR}" STREQUAL "")
      message(FATAL_ERROR "Invalid args")
  endif()

  add_test(NAME boostcmake.${test}
    COMMAND ${CMAKE_COMMAND}
      "-DCMAKE_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}"
      "-Dboostcmake_LOCATION=${CMAKE_CURRENT_SOURCE_DIR}/.."
      -Dboostcmake_GENERATOR=${CMAKE_GENERATOR}
      -Dboostcmake_GENERATOR_PLATFORM=${CMAKE_GENERATOR_PLATFORM}
      -Dboostcmake_GENERATOR_TOOLSET=${CMAKE_GENERATOR_TOOLSET}
      -Dboostcmake_MAKE_PROGRAM=${CMake_TEST_EXPLICIT_MAKE_PROGRAM}
      -Dboostcmake_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}/${local_cmd_TEST_DIR}
      -Dboostcmake_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}/${test}
    ${${test}_ARGS} # additional test args
    ${local_cmd_TEST_ARGS}
    -P "${CMAKE_CURRENT_SOURCE_DIR}/${local_cmd_TEST_DIR}/RunCMakeTest.cmake"
    )
endfunction()


set(CMake_TEST_EXPLICIT_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM})

add_boostcmake_test("check-functions" TEST_DIR "check-functions")
add_boostcmake_test("quickbook-functions" TEST_DIR "quickbook-functions")
