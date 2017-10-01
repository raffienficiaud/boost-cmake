# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.quickbook)


set(boost_quickbook_HEADERS) # no headers
set(boost_quickbook_SRC
    ../src/quickbook.cpp
    ../src/actions.cpp
    ../src/doc_info_actions.cpp
    ../src/state.cpp
    ../src/dependency_tracker.cpp
    ../src/utils.cpp
    ../src/files.cpp
    ../src/native_text.cpp
    ../src/glob.cpp
    ../src/include_paths.cpp
    ../src/values.cpp
    ../src/document_state.cpp
    ../src/id_generation.cpp
    ../src/id_xml.cpp
    ../src/post_process.cpp
    ../src/collector.cpp
    ../src/template_stack.cpp
    ../src/code_snippet.cpp
    ../src/markups.cpp
    ../src/syntax_highlight.cpp
    ../src/grammar.cpp
    ../src/main_grammar.cpp
    ../src/block_element_grammar.cpp
    ../src/phrase_element_grammar.cpp
    ../src/doc_info_grammar.cpp
)

add_library(boost_quickbook
  ${boost_quickbook_HEADERS}
  ${boost_quickbook_SRC})

set(additional_compilation_flags)
set(additional_compilation_defines)
if(MSVC)
  set(additional_compilation_flags
    /wd4355 /wd4511
    /wd4512 /wd4701
    /wd4702 /wd4244
    /wd4267 /wd4800)
  set(additional_compilation_defines
    _CRT_SECURE_NO_DEPRECATE
    _SCL_SECURE_NO_DEPRECATE)
endif()

target_compile_definitions(
  boost_quickbook
  PUBLIC
    BOOST_FILESYSTEM_NO_DEPRECATED
    ${additional_compilation_defines}
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_PROGRAM_OPTIONS_DYN_LINK=1>
    <target-os>windows:<library>shell32

  )

target_include_directories(
  boost_quickbook
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
  )

target_link_libraries(boost_quickbook
  PUBLIC boost::program_options boost:filesystem
  )

if(MSVC)
  # check how to do better
  target_link_libraries(boost_quickbook
    PUBLIC shell32
    )
endif()

install(
  TARGETS boost_quickbook
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )


if(DEFINED BOOST_CURRENT_PACKAGE)
  add_library(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_quickbook)
  set_target_properties(boost_quickbook PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()






project quickbook
    : requirements
        <toolset>gcc:<c++-template-depth>300
        <toolset>darwin:<c++-template-depth>300
        <toolset>gcc:<cflags>-g0
        <toolset>darwin:<cflags>-g0
        <toolset>msvc:<cflags>/wd4709
    ;

lib shell32 ;

exe quickbook
    :

    /boost//program_options
    /boost//filesystem
    : #<define>QUICKBOOK_NO_DATES
      <define>BOOST_FILESYSTEM_NO_DEPRECATED
      <toolset>msvc:<cxxflags>/wd4355
      <toolset>msvc:<cxxflags>/wd4511
      <toolset>msvc:<cxxflags>/wd4512
      <toolset>msvc:<cxxflags>/wd4701
      <toolset>msvc:<cxxflags>/wd4702
      <toolset>msvc:<cxxflags>/wd4244
      <toolset>msvc:<cxxflags>/wd4267
      <toolset>msvc:<cxxflags>/wd4800
      <toolset>msvc:<define>_CRT_SECURE_NO_DEPRECATE
      <toolset>msvc:<define>_SCL_SECURE_NO_DEPRECATE
      <target-os>windows:<library>shell32
    ;
