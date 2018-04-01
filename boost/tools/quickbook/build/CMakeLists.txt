# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.quickbook)


set(boost_quickbook_HEADERS) # no headers
set(boost_quickbook_SRC
  ../src/utils.cpp
  ../src/dependency_tracker.cpp
  ../src/document_state.cpp
  ../src/boostbook_chunker.cpp
  ../src/quickbook.cpp
  ../src/post_process.cpp
  ../src/html_printer.cpp
  ../src/state.cpp
  ../src/syntax_highlight.cpp
  ../src/id_xml.cpp
  ../src/phrase_element_grammar.cpp
  ../src/tree.cpp
  ../src/template_stack.cpp
  ../src/id_generation.cpp
  ../src/files.cpp
  ../src/doc_info_actions.cpp
  ../src/collector.cpp
  ../src/markups.cpp
  ../src/stream.cpp
  ../src/main_grammar.cpp
  ../src/path.cpp
  ../src/grammar.cpp
  ../src/glob.cpp
  ../src/include_paths.cpp
  ../src/bb2html.cpp
  ../src/doc_info_grammar.cpp
  ../src/code_snippet.cpp
  ../src/block_element_grammar.cpp
  ../src/values.cpp
  ../src/actions.cpp
  ../src/xml_parse.cpp
)

add_executable(boost_quickbook
  ${boost_quickbook_HEADERS}
  ${boost_quickbook_SRC})
set_target_properties(boost_quickbook
  PROPERTIES
    CXX_STANDARD 11
    RUNTIME_OUTPUT_NAME "quickbook")

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
  )

target_include_directories(
  boost_quickbook
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
  )

target_link_libraries(boost_quickbook
  PUBLIC
    boost::program_options
    boost::filesystem
    boost::spirit
    boost::iostreams
    boost::tuple
    boost::foreach
    boost::algorithm
    boost::unordered
  )

#if(MSVC)
#  # check how to do better
#  target_link_libraries(boost_quickbook
#    PUBLIC shell32
#    )
#endif()

install(
  TARGETS boost_quickbook
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )


if(DEFINED BOOST_CURRENT_PACKAGE)
  add_executable(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_quickbook)
  set_target_properties(boost_quickbook PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()
