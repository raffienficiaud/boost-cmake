set(_current_package "SYSTEM")
set(BOOST_LIB_${_current_package}_COMPONENTS "build" "doc" "test")

# checking no aliasing
foreach(_component IN LISTS BOOST_LIB_${_current_package}_COMPONENTS)
  string(TOUPPER ${_component} _current_component_upper)
  if(DEFINED BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY)
    message(FATAL_ERROR "The variable 'BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY' is already defined")
  endif()
endforeach()

set(BOOST_LIB_${_current_package}_COMPONENTS_BUILD_DEPENDENCY "config:build" "core:build" "type_traits:build")
set(BOOST_LIB_${_current_package}_COMPONENTS_DOC_DEPENDENCY ) #"quickbook:core")
set(BOOST_LIB_${_current_package}_COMPONENTS_TEST_DEPENDENCY "system:build")
