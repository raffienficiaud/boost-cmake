# Boost.CMake support
# Copyright Raffi Enficiaud 2017
#
# Distributed under the Boost Software License, Version 1.0.
#    (See accompanying file LICENSE_1_0.txt or copy at
#          http://www.boost.org/LICENSE_1_0.txt)

cmake_minimum_required(VERSION 3.4)

project(Boost)

set(BOOST_ROOT_FOLDER ${CMAKE_CURRENT_LIST_DIR})
#set(CMAKE_MODULE_PATH tools/boost-cmake/${CMAKE_MODULE_PATH})

# The utility functions
include(tools/boost-cmake/boost_cmake_utilities.cmake)

# get all tools
boost_get_all_libs(
  ROOT_PATH "${BOOST_ROOT_FOLDER}/tools"
  RELATIVE_PATH ${BOOST_ROOT_FOLDER}
  OUTPUT_VAR boost_all_tools)

# get all libs
boost_get_all_libs(
  ROOT_PATH "${BOOST_ROOT_FOLDER}/libs"
  RELATIVE_PATH "${BOOST_ROOT_FOLDER}/libs"
  OUTPUT_VAR boost_all_library)

# check which are packages and declare their dependencies
boost_discover_packages_and_components(
  ROOT_PATH "${BOOST_ROOT_FOLDER}/libs/"
  LIST_FOLDERS ${boost_all_library}
  PACKAGES_OUTPUT_VAR BOOST_ALL_PACKAGES
  COMPONENTS_OUTPUT_VAR BOOST_ALL_PACKAGES_COMPONENTS
  DEPENDENCY_VAR BOOST_COMPONENTS_DEPENDENCIES)

message(STATUS "All packages: ${BOOST_ALL_PACKAGES}")
message(STATUS "All packages and components: ${BOOST_ALL_PACKAGES_COMPONENTS}")

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

message("test components are ${all_test_components}")
message("test:build depedencies are ${all_test_build_dependencies}")

# adding subprojects
boost_add_subdirectories_in_order(
  ROOT_PATH "${BOOST_ROOT_FOLDER}/libs/"
  ALL_COMPONENTS ${BOOST_ALL_PACKAGES_COMPONENTS}
  ALL_DEPENDENCIES ${BOOST_COMPONENTS_DEPENDENCIES}
  EXCLUDE_FROM_ALL_COMPONENTS "doc" "test"
)
