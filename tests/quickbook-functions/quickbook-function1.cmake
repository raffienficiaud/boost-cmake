# checking the quickbook function

message(STATUS "BOOST_CMAKE_LOCATION='${BOOST_CMAKE_LOCATION}'")
message(STATUS "BOOST_ROOT_FOLDER='${BOOST_ROOT_FOLDER}'")
include("${BOOST_CMAKE_LOCATION}/boost-cmake/quickbook.cmake")

enable_language(CXX)
add_executable(quickbook phony-quickbook.cpp)

set(BOOST_ROOT_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}")
quickbook(COMPONENT "boost.non-existing"
          DOCUMENTATION_ENTRY "test-non-existing.qbk")
