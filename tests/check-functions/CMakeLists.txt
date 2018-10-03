# This is the project definition used for all the tests defined in this folder
# 
# The variable `boostcmake_TEST` is automatically set by the testing function.
# Additional parameters are set via the variable `boostcmake_TEST_OPTIONS` in the 
# `RunCMakeTest.cmake`, and passed directly to this CMakeLists.txt as variables 
# set on the command line.

cmake_minimum_required(VERSION 3.5)
project(${boostcmake_TEST} NONE)


# This file is needed by any of the utility functions
include("${BOOST_CMAKE_LOCATION}/boost-cmake/boost_cmake_utilities.cmake")

include(${boostcmake_TEST}.cmake)
