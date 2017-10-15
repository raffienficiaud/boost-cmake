# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

message(STATUS "Declaring package '${CURRENT_PACKAGE}'")
set(_current_package "TYPE_TRAITS")
set(BOOST_LIB_${_current_package}_COMPONENTS "build" "doc" "test")

# checking no aliasing
foreach(_component IN LISTS BOOST_LIB_${_current_package}_COMPONENTS)
  string(TOUPPER ${_component} _current_component_upper)
  if(DEFINED BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY)
    message(FATAL_ERROR "The variable 'BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY' is already defined")
  endif()
endforeach()

set(BOOST_LIB_${_current_package}_COMPONENTS_BUILD_DEPENDENCY
  "static_assert:build"
)
set(BOOST_LIB_${_current_package}_COMPONENTS_DOC_DEPENDENCY )
set(BOOST_LIB_${_current_package}_COMPONENTS_TEST_DEPENDENCY )
