# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

# This cmake file defines the tests of the boost.test library
# It is not meant to be included independently of the boost superproject cmake.

# sources the quickbook package of boost-cmake
include(${BOOST_CMAKE_UTILITY_DIR}/quickbook.cmake)

# listing all the quickbook files
file(GLOB_RECURSE
     BOOST_TEST_DOC_FILES
     ${CMAKE_CURRENT_LIST_DIR}/*.qbk)

# listing all the header files (doxygen)
file(GLOB_RECURSE boost_test_headers
     LIST_DIRECTORIES false 
     RELATIVE ${CMAKE_CURRENT_LIST_DIR}
     ${CMAKE_CURRENT_LIST_DIR}/../include/*.hpp)

quickbook(COMPONENT test
          DOCUMENTATION_ENTRY ${CMAKE_CURRENT_LIST_DIR}/test.qbk
          DOXYGEN_SOURCE_FILES ${boost_test_headers})

# Commands for quickbook
# produced by
# ../../../b2 -n -d+2 -sDOCBOOK_XSL_DIR=/Users/raffi/Downloads/docbook-xsl-1.78.1/ -sDOCBOOK_DTD_DIR=/Users/raffi/Downloads/docbook-xml-4.2/
