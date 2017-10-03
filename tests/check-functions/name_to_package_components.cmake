

message(STATUS "BOOST_CMAKE_LOCATION='${BOOST_CMAKE_LOCATION}'")

include("${BOOST_CMAKE_LOCATION}/boost_cmake_utilities.cmake")

set(name "libs/units:doc")
boost_get_package_component_from_name("${name}" path package component)

if(NOT ("${path}" STREQUAL "libs/units"))
  message(FATAL_ERROR "Wrong path '${path}'")
endif()

if(NOT ("${package}" STREQUAL "libs/units"))
  message(FATAL_ERROR "Wrong package '${package}'")
endif()

if(NOT ("${component}" STREQUAL "doc"))
  message(FATAL_ERROR "Wrong component '${component}'")
endif()

# new settings
boost_get_package_component_from_name("${name}" path package component
  PACKAGE_STRIP_PATH "libs")

if(NOT ("${path}" STREQUAL "libs/units"))
  message(FATAL_ERROR "Wrong path '${path}'")
endif()

if(NOT ("${package}" STREQUAL "units"))
  message(FATAL_ERROR "Wrong package '${package}'")
endif()

if(NOT ("${component}" STREQUAL "doc"))
  message(FATAL_ERROR "Wrong component '${component}'")
endif()
