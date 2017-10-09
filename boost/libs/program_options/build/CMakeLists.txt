# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.program_options)


file(GLOB_RECURSE boost_program_options_HEADERS ../include/*.*)
set(boost_program_options_SRC
  ../src/cmdline.cpp
  ../src/config_file.cpp
  ../src/options_description.cpp
  ../src/parsers.cpp
  ../src/variables_map.cpp
  ../src/value_semantic.cpp
  ../src/positional_options.cpp
  ../src/utf8_codecvt_facet.cpp
  ../src/convert.cpp
  ../src/winmain.cpp
  ../src/split.cpp
)

add_library(boost_program_options
  ${boost_program_options_HEADERS}
  ${boost_program_options_SRC})

# check if this can go to the target_compile_definitions
set_target_properties(boost_program_options
    PROPERTIES DEFINE_SYMBOL "BOOST_PROGRAM_OPTIONS_SOURCE"
  )
target_compile_definitions(
  boost_program_options
  PUBLIC
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_PROGRAM_OPTIONS_DYN_LINK=1>
  )

# Raffi: todo add this from the Jamfile
#  : # See https://svn.boost.org/trac/boost/ticket/5049
#    <target-os>hpux,<toolset>gcc:<define>_INCLUDE_STDC__SOURCE_199901

target_include_directories(
  boost_program_options
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
  )
target_link_libraries(boost_program_options
  PUBLIC
    boost::config
    boost::any
    boost::type_index
    boost::static_assert
    boost::throw_exception
    boost::assert
    boost::core
    boost::type_traits
    boost::function
    boost::lexical_cast
  )
#target_link_libraries(boost_program_options
#  PUBLIC boost::config boost::predef boost::assert boost::core
#  )

install(
  TARGETS boost_program_options
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )


if(DEFINED BOOST_CURRENT_PACKAGE)
  add_library(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_program_options)
  set_target_properties(boost_program_options PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()
