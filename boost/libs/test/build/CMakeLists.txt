# Copyright 2014, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

cmake_minimum_required(VERSION 3.2)
project(boost.test)

add_definitions(-DBOOST_TEST_NO_LIB)

# include globs, bad
file(GLOB_RECURSE
     BOOST_UTF_HEADERS
     ../include/*.hpp
     ../include/*.ipp)

set(BOOST_TEST_DEPENDENCIES
  boost::config
  boost::system
  boost::type_traits
  boost::mpl
  boost::function
  boost::throw_exception # this one is indirect from boost::function
  boost::integer # this one is indirect from boost::function
  boost::static_assert # this one is indirect from boost::integer, but also here
  boost::type_index # this one is indirect from boost::function
  boost::preprocessor
  boost::functional # indirect from type_index
  boost::detail # indirect from functional
  boost::utility
  boost::smart_ptr
  boost::bind # indirect from boost::function
  boost::exception
  boost::iterator
  boost::move # indirect from boost::smart_ptr
  boost::timer
  boost::io
  boost::algorithm
  boost::range # indirect from boost::algorithm
  boost::numeric_conversion
  boost::optional
)

set(BOOST_UTF_SRC
    ../src/compiler_log_formatter.cpp
    ../src/debug.cpp
    ../src/decorator.cpp
    ../src/execution_monitor.cpp
    ../src/framework.cpp
    ../src/junit_log_formatter.cpp
    ../src/plain_report_formatter.cpp
    ../src/progress_monitor.cpp
    ../src/results_collector.cpp
    ../src/results_reporter.cpp
    ../src/test_framework_init_observer.cpp
    ../src/test_tools.cpp
    ../src/test_tree.cpp
    ../src/unit_test_log.cpp
    ../src/unit_test_main.cpp
    ../src/unit_test_monitor.cpp
    ../src/unit_test_parameters.cpp
    ../src/xml_log_formatter.cpp
    ../src/xml_report_formatter.cpp
    )

# defining the main target, type depends from the main super project
add_library(boost_test
            ${BOOST_UTF_HEADERS}
            ${BOOST_UTF_SRC})
target_compile_definitions(
  boost_test
  PUBLIC
    BOOST_TEST_NO_AUTO_LINK=1
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_TEST_DYN_LINK=1>
  )
target_include_directories(
  boost_test
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>)
target_link_libraries(boost_test
  PUBLIC
  ${BOOST_TEST_DEPENDENCIES}
)

# defining the header only target
add_library(boost_test_header_only INTERFACE)
target_include_directories(boost_test_header_only
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>)
target_compile_definitions(
  boost_test_header_only
  INTERFACE
    BOOST_TEST_NO_AUTO_LINK=1
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_TEST_DYN_LINK=1>
)
target_link_libraries(boost_test_header_only
  INTERFACE
  ${BOOST_TEST_DEPENDENCIES}
)

install(
  TARGETS boost_test
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(DEFINED BOOST_CURRENT_PACKAGE)
  add_library(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_test)
  add_library(boost::${BOOST_CURRENT_PACKAGE}::header ALIAS boost_test_header_only)
  set_target_properties(boost_test PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()
