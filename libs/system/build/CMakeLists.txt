# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.system)


file(GLOB_RECURSE boost_system_HEADERS ../include/*.*)
set(boost_system_SRC ../src/error_code.cpp)

add_library(boost_system
  ${boost_system_HEADERS}
  ${boost_system_SRC})
target_compile_definitions(
  boost_system
  PUBLIC
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,STATIC_LIBRARY>:BOOST_SYSTEM_STATIC_LINK=1>
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_SYSTEM_DYN_LINK=1>
  )
target_include_directories(
  boost_system
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(boost_system
  PUBLIC boost::config boost::predef boost::assert boost::core)

install(
  TARGETS boost_system
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)


if(DEFINED BOOST_CURRENT_PACKAGE)
  add_library(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_system)
  set_target_properties(boost_system PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()
