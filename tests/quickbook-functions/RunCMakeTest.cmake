
include(RunCMake)

set(boostcmake_TEST_OPTIONS "-DBOOST_CMAKE_LOCATION=${boostcmake_LOCATION}")

# quickbook related functions
run_cmake(quickbook-catalog)

# same with DTD
if(NOT EXISTS "${CMAKE_BINARY_DIR}/some/random/path")
  file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/some/random/path")
endif()
set(boostcmake_TEST_OPTIONS ${boostcmake_TEST_OPTIONS}
    "-DDOCBOOK_XSL_DIR=${CMAKE_BINARY_DIR}/some/random/path")
run_cmake(quickbook-catalog)


# same with erroneous DTD
# we pass the expected regex as a variable (easier in this case)
set(boostcmake_DEFAULT_stderr ".*'/non/existant/path'.*")
set(boostcmake_TEST_OPTIONS ${boostcmake_TEST_OPTIONS}
    "-DDOCBOOK_XSL_DIR=/non/existant/path")
run_cmake(quickbook-catalog-non-existant-folders)


# rebooting the variable
unset(boostcmake_DEFAULT_stderr)
set(boostcmake_TEST_OPTIONS "-DBOOST_CMAKE_LOCATION=${boostcmake_LOCATION}")

find_program(xsltproc_prg NAMES "xsltproc")
if("${xsltproc_prg}" STREQUAL "")
  message(FATAL_ERROR "Cannot find the 'xsltproc' program")
  run_cmake(quickbook-xsltproc-notfound)
else()
  run_cmake(quickbook-function1)
endif()
