# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

# checking the quickbook function

message(STATUS "BOOST_CMAKE_LOCATION='${BOOST_CMAKE_LOCATION}'")
message(STATUS "BOOST_ROOT_FOLDER='${BOOST_ROOT_FOLDER}'")
include("${BOOST_CMAKE_LOCATION}/boost-cmake/quickbook.cmake")

enable_language(CXX)
add_executable(quickbook phony-quickbook.cpp)

set(BOOST_ROOT_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}")
quickbook(COMPONENT "boost.non-existing"
          DOCUMENTATION_ENTRY "test-non-existing.qbk")
