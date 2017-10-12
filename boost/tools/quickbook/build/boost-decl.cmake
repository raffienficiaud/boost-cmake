# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

# boost-decl.cmake
# declares the components of boost.test and their dependencies

# The following variables should be defined:
#
# * ``BOOST_LIB_<current_package>_COMPONENTS``: list indicating all the components of the current package
# * ``BOOST_LIB_<current_package>_COMPONENTS_<component>_DEPENDENCY`` list indicating all the dependencies of the ``component``

message(STATUS "Declaring package '${CURRENT_PACKAGE}'")
set(_current_package "QUICKBOOK")
set(BOOST_LIB_${_current_package}_COMPONENTS "build" "doc" "test")

# checking no aliasing
foreach(_component IN LISTS BOOST_LIB_${_current_package}_COMPONENTS)
  string(TOUPPER ${_component} _current_component_upper)
  if(DEFINED BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY)
    message(FATAL_ERROR "The variable 'BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY' is already defined")
  endif()
endforeach()

set(BOOST_LIB_${_current_package}_COMPONENTS_BUILD_DEPENDENCY
  "boostbook:build"
  "program_options:build"
  "filesystem:build"
  "spirit:build"
  "iostreams:build"
  "tuple:build"
  "foreach:build"
  "algorithm:build"
  "unordered:build"
)
set(BOOST_LIB_${_current_package}_COMPONENTS_DOC_DEPENDENCY )
set(BOOST_LIB_${_current_package}_COMPONENTS_TEST_DEPENDENCY )
