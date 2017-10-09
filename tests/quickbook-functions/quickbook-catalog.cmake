# checking the write catalog function

message(STATUS "BOOST_CMAKE_LOCATION='${BOOST_CMAKE_LOCATION}'")
message(STATUS "BOOST_ROOT_FOLDER='${BOOST_ROOT_FOLDER}'")
message(STATUS "DOCBOOK_XSL_DIR='${DOCBOOK_XSL_DIR}'")
message(STATUS "DOCBOOK_DTD_DIR='${DOCBOOK_DTD_DIR}'")
include("${BOOST_CMAKE_LOCATION}/boost-cmake/quickbook.cmake")

set(BOOST_ROOT_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}")
quickbook_write_catalog(boost_catalog_file)

# basic checks
if("${boost_catalog_file}" STREQUAL "")
  message(FATAL_ERROR "Empty catalog file string")
endif()

if(NOT EXISTS "${boost_catalog_file}")
  message(FATAL_ERROR "File pointed by the catalog does not exist: '${boost_catalog_file}'")
endif()

# checks the file content
file(READ "${boost_catalog_file}" var_file_content)

string(FIND "${var_file_content}" "file://${BOOST_ROOT_FOLDER}" var_find_1)
if("${var_find_1}" STREQUAL "-1")
  message(FATAL_ERROR "'${BOOST_ROOT_FOLDER}' not found in the catalog file")
endif()



if((DEFINED DOCBOOK_XSL_DIR) AND NOT ("${DOCBOOK_XSL_DIR}" STREQUAL ""))
  string(FIND "${var_file_content}" "file://${DOCBOOK_XSL_DIR}" var_find_1)
  # in case a XSL has been given
  if("${var_find_1}" STREQUAL "-1")
    message(FATAL_ERROR "'${DOCBOOK_XSL_DIR}' not found in the catalog file")
  endif()

else()
  # in case no XSL has been given the rewrite of oasis should not occur
  string(FIND
    "${var_file_content}"
    "rewriteURI uriStartString=\"http://www.oasis-open.org/docbook/xml/4.2/\""
    var_find_1)

  if(NOT ("${var_find_1}" STREQUAL "-1"))
    message(FATAL_ERROR
      "'${DOCBOOK_XSL_DIR}' found in the catalog file (while the XSL option has not been given)")
  endif()

endif()


message(STATUS "All tests passed")
