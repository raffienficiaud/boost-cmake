# Boost.CMake support
# Copyright Raffi Enficiaud 2017
#
# Distributed under the Boost Software License, Version 1.0.
#    (See accompanying file LICENSE_1_0.txt or copy at
#          http://www.boost.org/LICENSE_1_0.txt)

cmake_minimum_required(VERSION 3.4)

project(Boost)
enable_testing()


option(BUILD_BOOST_CMAKE_TESTS OFF)
set(BOOST_ROOT_FOLDER ${CMAKE_CURRENT_LIST_DIR})


# if defined, we run the tests for this module
if("${BUILD_BOOST_CMAKE_TESTS}" AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/RunCMake.cmake")
  add_subdirectory(tests)
  return()
endif()


# The utility functions
include(tools/boost-cmake/boost_cmake_utilities.cmake)

option(BOOST_BUILD_DOC  "Indicates if the documentation should be generated" OFF)
option(BOOST_BUILD_TEST "Indicates if the tests should be generated" OFF)
option(BOOST_CREATE_VISIBLE_HEADER_ONLY "Makes the header only libraries visible (on eg. IDE) with an associated target" OFF)

if("${BOOST_WITH_COMPONENT}")
  set(BOOST_WITH_COMPONENT "" "A list of coma separated components to build" CACHE STRING)
endif()

# get all tools
boost_get_all_libs(
  PATH "${BOOST_ROOT_FOLDER}/tools"
  RELATIVE_PATH "${BOOST_ROOT_FOLDER}"
  OUTPUT_VAR boost_all_tools)

# get all libs
boost_get_all_libs(
  PATH "${BOOST_ROOT_FOLDER}/libs"
  RELATIVE_PATH "${BOOST_ROOT_FOLDER}"
  OUTPUT_VAR boost_all_library
  SHOULD_HAVE_INCLUDE)

# temporary -- patching all <boost>/[libs|tools]/<library> with the files in "tools/boost-cmake/libs/"
boost_get_all_libs(
  PATH
    "${BOOST_ROOT_FOLDER}/tools/boost-cmake/boost/libs"
    "${BOOST_ROOT_FOLDER}/tools/boost-cmake/boost/tools"
  RELATIVE_PATH "${BOOST_ROOT_FOLDER}/tools/boost-cmake/boost/"
  OUTPUT_VAR patch_candidate_libs)

set(relevant_folders_to_patch "build" "doc" "test")
foreach(_folder IN LISTS patch_candidate_libs)
  foreach(_subfolder IN LISTS relevant_folders_to_patch)
    if(EXISTS "${BOOST_ROOT_FOLDER}/tools/boost-cmake/boost/${_folder}/${_subfolder}")
      message(STATUS "[tmp-patch] '${_folder}/${_subfolder}'")
      file(COPY
        ${BOOST_ROOT_FOLDER}/tools/boost-cmake/boost/${_folder}/${_subfolder}/
        DESTINATION ${BOOST_ROOT_FOLDER}/${_folder}/${_subfolder}/
        FILES_MATCHING
          PATTERN "*.cmake"
          PATTERN "CMakeLists.txt"
        )
    endif()
  endforeach()
endforeach()

message(STATUS "boost_all_tools: ${boost_all_tools} /// boost_all_library: ${boost_all_library}")

# dependencies -- check which are packages and declare their dependencies
boost_discover_packages_and_components(
  ROOT_PATH "${BOOST_ROOT_FOLDER}/"
  LIST_FOLDERS ${boost_all_library} ${boost_all_tools}
  PACKAGES_OUTPUT_VAR BOOST_ALL_PACKAGES
  COMPONENTS_OUTPUT_VAR BOOST_ALL_PACKAGES_COMPONENTS
  DEPENDENCY_VAR BOOST_COMPONENTS_DEPENDENCIES
  COMPONENT_STRIP_PATH "libs" "tools")

# boost_discover_packages_and_components(
#   ROOT_PATH "${BOOST_ROOT_FOLDER}/"
#   LIST_FOLDERS ${boost_all_tools}
#   PACKAGES_OUTPUT_VAR BOOST_ALL_PACKAGES_TOOLS
#   COMPONENTS_OUTPUT_VAR BOOST_ALL_PACKAGES_COMPONENTS_TOOLS
#   DEPENDENCY_VAR BOOST_COMPONENTS_DEPENDENCIES_TOOLS)

message(STATUS "All packages: ${BOOST_ALL_PACKAGES}")
message(STATUS "All packages and components: ${BOOST_ALL_PACKAGES_COMPONENTS}")

# message(STATUS "All packages tools: ${BOOST_ALL_PACKAGES_TOOLS}")
# message(STATUS "All packages tools and components: ${BOOST_ALL_PACKAGES_COMPONENTS_TOOLS}")

# set(BOOST_ALL_PACKAGES ${BOOST_ALL_PACKAGES} ${BOOST_ALL_PACKAGES_TOOLS})
# set(BOOST_ALL_PACKAGES_COMPONENTS ${BOOST_ALL_PACKAGES_COMPONENTS} ${BOOST_ALL_PACKAGES_COMPONENTS_TOOLS})

# just for example: returns the components of the "test" package
boost_package_get_all_components(
  PACKAGE "test"
  ALL_COMPONENTS ${BOOST_ALL_PACKAGES_COMPONENTS}
  OUTPUT_VAR all_test_components
)

# just for example: returns the dependencies of the "test:build" component
boost_package_get_all_dependencies(
  COMPONENT "test:build"
  ALL_DEPENDENCIES ${BOOST_COMPONENTS_DEPENDENCIES}
  OUTPUT_VAR all_test_build_dependencies
)

# pass options:
set(additional_options)
if(NOT "${BOOST_BUILD_DOC}")
  set(additional_options ${additional_options} "doc")
endif()

if(NOT "${BOOST_BUILD_TEST}")
  set(additional_options ${additional_options} "test")
endif()

if(NOT "${additional_options}" STREQUAL "")
  set(additional_options EXCLUDE_FROM_ALL_COMPONENTS ${additional_options})
endif()

if(${BOOST_CREATE_VISIBLE_HEADER_ONLY})
  set(additional_options ${additional_options} VISIBLE_HEADER_ONLY)
endif()

if(NOT "${BOOST_WITH_COMPONENT}" STREQUAL "")
  string(REPLACE "," ";" arg_subset_to ${BOOST_WITH_COMPONENT})
  set(additional_options SUBSET_TO ${arg_subset_to})
endif()

# adding subprojects
boost_add_subdirectories_in_order(
  ROOT_PATH "${BOOST_ROOT_FOLDER}/libs/"
  ALL_COMPONENTS ${BOOST_ALL_PACKAGES_COMPONENTS}
  ALL_DEPENDENCIES ${BOOST_COMPONENTS_DEPENDENCIES}
  ${additional_options}
  #SUBSET_TO "test:build"
)
