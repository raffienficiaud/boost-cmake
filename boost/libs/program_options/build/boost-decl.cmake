message(STATUS "Declaring package '${CURRENT_PACKAGE}'")
set(_current_package "PROGRAM_OPTIONS")
set(BOOST_LIB_${_current_package}_COMPONENTS "build" "doc" "test")

# checking no aliasing
foreach(_component IN LISTS BOOST_LIB_${_current_package}_COMPONENTS)
  string(TOUPPER ${_component} _current_component_upper)
  if(DEFINED BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY)
    message(FATAL_ERROR "The variable 'BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY' is already defined")
  endif()
endforeach()

set(BOOST_LIB_${_current_package}_COMPONENTS_BUILD_DEPENDENCY
  "config:build"
  "any:build"
  "type_index:build"
  "static_assert:build"
  "throw_exception:build"
  "assert:build"
  "core:build"
  "type_traits:build"
  "function:build"
  "lexical_cast:build"
  "smart_ptr:build"
  "tokenizer:build"
)
set(BOOST_LIB_${_current_package}_COMPONENTS_DOC_DEPENDENCY "quickbook:build")
set(BOOST_LIB_${_current_package}_COMPONENTS_TEST_DEPENDENCY "program_options:build")
