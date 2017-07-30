# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.filesystem)


file(GLOB_RECURSE boost_filesystem_HEADERS ../include/*.*)
set(boost_filesystem_SRC
  ../src/codecvt_error_category.cpp
  ../src/operations.cpp
  ../src/path.cpp
  ../src/path_traits.cpp
  ../src/portability.cpp
  ../src/unique_path.cpp
  ../src/utf8_codecvt_facet.cpp
  ../src/windows_file_codecvt.cpp
)

add_library(boost_filesystem
  ${boost_filesystem_HEADERS}
  ${boost_filesystem_SRC})
target_compile_definitions(
  boost_filesystem
  PUBLIC
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,STATIC_LIBRARY>:BOOST_FILESYSTEM_STATIC_LINK=1>
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_FILESYSTEM_DYN_LINK=1>
  )
target_include_directories(
  boost_filesystem
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(boost_filesystem
  PUBLIC
    boost::system
    boost::type_traits
    boost::smart_ptr
    boost::iterator
    boost::mpl # indirect from iterator
    boost::preprocessor # indirect from mpl
    boost::static_assert # indirect from mpl
    boost::detail # indirect from iterator
    boost::exception # iterator
    boost::throw_exception # shared_ptr
    boost::io
    boost::functional
    boost::assert
    boost::range
)

install(
  TARGETS boost_filesystem
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)


if(DEFINED BOOST_CURRENT_PACKAGE)
  add_library(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_filesystem)
  set_target_properties(boost_filesystem PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()
