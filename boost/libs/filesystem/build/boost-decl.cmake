# CURRENT_PACKAGE is an automatic variable set by the calling function
# and can be modified in this script. The modified name will be registered
# in the set of packages

message(STATUS "Declaring package '${CURRENT_PACKAGE}'")
set(_current_package "FILESYSTEM")

set(BOOST_LIB_${_current_package}_COMPONENTS "build")

# checking no aliasing
foreach(_component IN LISTS BOOST_LIB_${_current_package}_COMPONENTS)
  string(TOUPPER ${_component} _current_component_upper)
  if(DEFINED BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY)
    message(FATAL_ERROR "The variable 'BOOST_LIB_${_current_package}_COMPONENTS_${_current_component_upper}_DEPENDENCY' is already defined")
  endif()
endforeach()

set(BOOST_LIB_${_current_package}_COMPONENTS_BUILD_DEPENDENCY
  "system:build"
  "type_traits:build"
  "smart_ptr:build"
  "iterator:build"
  "mpl:build" # pulled from iterator
  "preprocessor:build" # pulled from mpl
  "static_assert:build" # pulled from mpl
  "detail:build" # pulled from iterator
  "exception:build" # smart_ptr
  "throw_exception:build" # smart_ptr
  "io:build"
  "container_hash:build"
  "functional:build"
  "assert:build"
  "range:build"
)
#set(BOOST_LIB_${_current_package}_COMPONENTS_DOC_DEPENDENCY ) #"quickbook:core")
#set(BOOST_LIB_${_current_package}_COMPONENTS_TEST_DEPENDENCY "system:build")
