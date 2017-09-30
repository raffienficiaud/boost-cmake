# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

# This cmake file defines the tests of the boost.test library
# It is not meant to be included independently of the boost superproject cmake.

####
# Documentation files (files only, no target)
file(GLOB_RECURSE
     BOOST_TEST_DOC_FILES
     ${CMAKE_CURRENT_LIST_DIR}/*.qbk)
add_custom_target(
  quickbook
  SOURCES ${BOOST_TEST_DOC_FILES})
set_property(TARGET quickbook PROPERTY FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")




Commands for quickbook
produced by
../../../b2 -n -d+2 -sDOCBOOK_XSL_DIR=/Users/raffi/Downloads/docbook-xsl-1.78.1/ -sDOCBOOK_DTD_DIR=/Users/raffi/Downloads/docbook-xml-4.2/


set(_quickbook_source_dir "${CMAKE_CURRENT_SOURCE_DIR}")

#.rst:
#
# Writes a catalog file for running the XSLT commands with user defined catalogs
#
# * ``boostbook_catalog_file`` the catalog file
function(quickbook_write_catalog boostbook_catalog_file)

  if("${BOOST_ROOT_FOLDER}" STREQUAL "")
    message(FATAL_ERROR "BOOST_ROOT_FOLDER should be defined")
  endif()


  if(NOT EXISTS "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/quickbook")
    file(MAKE_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/quickbook")
  endif()

  set(output_file "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/quickbook/boostbook_catalog.xml")


  set(preamble
"<?xml version=\"1.0\"?>
<!DOCTYPE catalog
  PUBLIC \"-//OASIS/DTD Entity Resolution XML Catalog V1.0//EN\"
  \"http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd\">
<catalog xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">")

  file(WRITE "${output_file}" "${preamble}")
  file(APPEND "${output_file}"
       "  <rewriteURI uriStartString=\"http://www.boost.org/tools/boostbook/dtd/\" rewritePrefix=\"file://${BOOST_ROOT_FOLDER}/tools/boostbook/dtd/\"/>\n")

  if(NOT ("${DOCBOOK_XSL_DIR}" STREQUAL ""))
    if(NOT EXISTS "${DOCBOOK_XSL_DIR}")
      message(WARNING "DOCBOOK_XSL_DIR is not accessible (${DOCBOOK_XSL_DIR})")
    else()
      file(APPEND "${output_file}"
           "  <rewriteURI uriStartString=\"http://docbook.sourceforge.net/release/xsl/current/\" rewritePrefix=\"file://${DOCBOOK_XSL_DIR}\"/>\n")
    endif()
  endif()

  if(NOT ("${DOCBOOK_DTD_DIR}" STREQUAL ""))
    if(NOT EXISTS "${DOCBOOK_DTD_DIR}")
      message(WARNING "DOCBOOK_DTD_DIR is not accessible (${DOCBOOK_DTD_DIR})")
    else()
      file(APPEND "${output_file}"
           "  <rewriteURI uriStartString=\"http://www.oasis-open.org/docbook/xml/4.2/\" rewritePrefix=\"file://${DOCBOOK_DTD_DIR}\"/>\n")
    endif()
  endif()

  file(APPEND "${output_file}"
    "</catalog>\n"

  set(${boostbook_catalog_file} "${output_file}" PARENT_SCOPE)

endfunction()



#.rst:
#
# Defines a target that runs a quickbook command
#
#  .. quickbook(
#       COMPONENT "component"
#)
# * ``COMPONENT`` the component for which the documentation is currently being generated (mandatory)
# * ``DOXYGEN_CONFIGURATION_FILE`` indicates that the quickbook has a reference to a reference section extracted from
#   Doxygen. This variable is either empty (no Doxygen) or points to the configuration file
# * ``DOXYGEN_SOURCE_FILES`` the source files (the Doxygen documentation will be regenerated when any of those files has been changed)
function(quickbook)

  # check for what cases this is needed
  if("${BOOST_ROOT_FOLDER}" STREQUAL "")
    message(FATAL_ERROR "BOOST_ROOT_FOLDER should be defined")
  endif()

  # xsltproc is required
  find_program(xsltproc_prg NAMES "xsltproc")
  if("${xsltproc_prg}" STREQUAL "")
    message(FATAL_ERROR "Cannot find the 'xsltproc' program")
  endif()


  set(options )
  set(oneValueArgs COMPONENT DOXYGEN_CONFIGURATION_FILE)
  set(multiValueArgs DOXYGEN_SOURCE_FILES)

  set(prefix _quickbook_target)
  cmake_parse_arguments(PARSE_ARGV 0 ${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" )

  if("${${prefix}_COMPONENT}" STREQUAL "")
    message(FATAL_ERROR "Missing mandatory 'COMPONENT'")
  endif()

  set(output_folder "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/quickbook/${${prefix}_COMPONENT}")

  if(NOT EXISTS "${output_folder}")
    file(MAKE_DIRECTORY "${output_folder}")
  endif()

  set(all_dependencies)

  if(NOT "${${prefix}_DOXYGEN_CONFIGURATION_FILE}" STREQUAL "")

    if(NOT EXISTS "${${prefix}_DOXYGEN_CONFIGURATION_FILE}")
      message(FATAL_ERROR "Doxygen configuration file for component '${${prefix}_COMPONENT}' does not exist ('${${prefix}_DOXYGEN_CONFIGURATION_FILE}')")
    endif()

    # configure the file
    set(doxygen_configured_file "${output_folder}/doxygen_generated")
    set(DOXYGEN_OUTPUT_XML_FOLDER "doxygen_reference_generated_doc-xml")
    set(DOXYGEN_OUTPUT_FOLDER "${output_folder}")
    configure_file("${${prefix}_DOXYGEN_CONFIGURATION_FILE}" "${doxygen_configured_file}")

    find_package(Doxygen REQUIRED)
    add_custom_command(
      OUTPUT
        #"${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}/doxygen_cmd.cmake"
        "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}/index.xml"
      COMMAND ${CMAKE_COMMAND} -E remove_directory "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}"
      COMMAND "${DOXYGEN_EXECUTABLE}" "${doxygen_configured_file}"
      COMMAND ${CMAKE_COMMAND} -E touch "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}/doxygen_cmd.cmake"
      DEPENDS
        "${${prefix}_DOXYGEN_SOURCE_FILES}" # check if filled properly
        "${doxygen_configured_file}" # check on how to generate this only if needed
    )

    quickbook_write_catalog(catalog_file)
    # doxygen processing
    # ""${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.doxygen"" is not a folder, but the output file
    add_custom_command(
      OUTPUT
        "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.doxygen"
      COMMAND
        ${CMAKE_COMMAND} \
          -E env XML_CATALOG_FILES="${catalog_file}" \
        ${xsltproc_prg} \
          --stringparam doxygen.xml.path "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}" \
          --xinclude -o "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.doxygen" \
          "${BOOST_ROOT_FOLDER}/tools/boostbook/xsl/doxygen/collect.xsl" \
          "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}/index.xml"
      DEPENDS
        "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}/index.xml"
        "${catalog_file}"
    )

    # here as before, we generate "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.boostbook"
    add_custom_command(
      OUTPUT
        "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.boostbook"
      COMMAND
        ${CMAKE_COMMAND} \
          -E env XML_CATALOG_FILES="${catalog_file}" \
        ${xsltproc_prg} \
          --stringparam boost.defaults "Boost" \
          --xinclude -o "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.boostbook" \
          "${BOOST_ROOT_FOLDER}/tools/boostbook/xsl/doxygen/doxygen2boostbook.xsl" \
          "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.doxygen"
      DEPENDS
        "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.doxygen"
        "${catalog_file}"
    )

    # now we need to do this
    cp "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.boostbook"  "doxygen_reference_generated_doc.xml"

    list(APPEND all_dependencies
      "${catalog_file}"
      "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}/index.xml")
  endif()

  # quickbook
  add_custom_command(
    OUTPUT "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}"
    COMMAND "${DOXYGEN_EXECUTABLE}" "${doxygen_configured_file}"
    DEPENDS "${${prefix}_DOXYGEN_SOURCE_FILES}" # check if filled properly
  )

  add_custom_command(
    OUTPUT
      XXXXXXX "${output_folder}/${${prefix}_COMPONENT}_doc.docbook"
    COMMAND
      ${CMAKE_COMMAND} \
        -E env XML_CATALOG_FILES="${catalog_file}" \
      ${xsltproc_prg} \
        --stringparam boost.defaults "Boost" \
        --stringparam boost.root "../../../.." \
        --stringparam chapter.autolabel "0" \
        --stringparam chunk.first.sections "1" \
        --stringparam chunk.section.depth "4" \
        --stringparam generate.section.toc.level "3" \
        --stringparam html.stylesheet "boostbook.css" \
        --stringparam toc.max.depth "3" \
        --stringparam toc.section.depth "10" \
        --xinclude -o "${output_folder}/${${prefix}_COMPONENT}_doc.docbook"
        "${BOOST_ROOT_FOLDER}/tools/boostbook/xsl/docbook.xsl"
        "../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.xml"

  )
xslt-xsltproc-dir html/standalone_HTML.manifest

  add_custom_command(
    OUTPUT
      XXXXXXX "${output_folder}/${DOXYGEN_OUTPUT_XML_FOLDER}.boostbook"
    COMMAND
      ${CMAKE_COMMAND} \
        -E env XML_CATALOG_FILES="${catalog_file}" \
      ${xsltproc_prg} \
        --stringparam boost.defaults "Boost"
        --stringparam boost.root "../../../.."
        --stringparam chapter.autolabel "0"
        --stringparam chunk.first.sections "1"
        --stringparam chunk.section.depth "4"
        --stringparam generate.section.toc.level "3"
        --stringparam html.stylesheet "boostbook.css"
        --stringparam manifest "standalone_HTML.manifest"
        --stringparam toc.max.depth "3"
        --stringparam toc.section.depth "10"
        --xinclude -o "html/"
        "${BOOST_ROOT_FOLDER}/tools/boostbook/xsl/html.xsl"
        "${output_folder}/${${prefix}_COMPONENT}_doc.docbook"
   )

endfunction()





text-action ../../../bin.v2/boostbook_catalog.xml

    cat "/var/folders/dx/_77h3khd2456_68z_ygfn6pc0000gp/T//jam2515a269.000" > "../../../bin.v2/boostbook_catalog.xml"




quickbook.quickbook-to-boostbook ../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.xml

    "../../../bin.v2/tools/quickbook/src/darwin-4.2.1/release/link-static/quickbook" -I"../../.."     --output-file="../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.xml" "test.qbk"

common.mkdir ../../../bin.v2/libs/test/doc/none

        mkdir -p "../../../bin.v2/libs/test/doc/none"

common.mkdir ../../../bin.v2/libs/test/doc/none/darwin-4.2.1

        mkdir -p "../../../bin.v2/libs/test/doc/none/darwin-4.2.1"

common.mkdir ../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug

        mkdir -p "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug"



###############################################
###############################################
###############################################


text-action ../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.doxyfile

    cat "/var/folders/dx/_77h3khd2456_68z_ygfn6pc0000gp/T//jam2515a26a.000" > "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.doxyfile"

doxygen-action ../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.xml-dir

    rm -f "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml/*.xml" & "doxygen" "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.doxyfile" && echo "Stamp
ed" > "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.xml-dir"

xslt-xsltproc ../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.doxygen

    XML_CATALOG_FILES="../../../bin.v2/boostbook_catalog.xml"
export XML_CATALOG_FILES
 "xsltproc" --stringparam doxygen.xml.path "/Users/raffi/Personnel/boost_github/bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml" --xinclude -o "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxy
gen_reference_generated_doc-xml.doxygen" "/Users/raffi/Personnel/boost_github/tools/boostbook/xsl/doxygen/collect.xsl" "/Users/raffi/Personnel/boost_github/bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xm
l/index.xml"

xslt-xsltproc ../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.boostbook

    XML_CATALOG_FILES="../../../bin.v2/boostbook_catalog.xml"
export XML_CATALOG_FILES
 "xsltproc" --stringparam boost.defaults "Boost" --xinclude -o "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.boostbook" "/Users/raffi/Personnel/boost_github/tools/boostbook/xsl/doxygen/doxyg
en2boostbook.xsl" "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.doxygen"

common.copy doxygen_reference_generated_doc.xml

    cp "../../../bin.v2/libs/test/doc/none/darwin-4.2.1/debug/doxygen_reference_generated_doc-xml.boostbook"  "doxygen_reference_generated_doc.xml"

xslt-xsltproc ../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.docbook

    XML_CATALOG_FILES="../../../bin.v2/boostbook_catalog.xml"
export XML_CATALOG_FILES
 "xsltproc" --stringparam boost.defaults "Boost" --stringparam boost.root "../../../.." --stringparam chapter.autolabel "0" --stringparam chunk.first.sections "1" --stringparam chunk.section.depth "4" --stringparam generate.section.toc
.level "3" --stringparam html.stylesheet "boostbook.css" --stringparam toc.max.depth "3" --stringparam toc.section.depth "10" --xinclude -o "../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.docbook" "/Users/raffi/Personnel/boo
st_github/tools/boostbook/xsl/docbook.xsl" "../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.xml"

xslt-xsltproc-dir html/standalone_HTML.manifest

    XML_CATALOG_FILES="../../../bin.v2/boostbook_catalog.xml"
export XML_CATALOG_FILES
 "xsltproc" --stringparam boost.defaults "Boost" --stringparam boost.root "../../../.." --stringparam chapter.autolabel "0" --stringparam chunk.first.sections "1" --stringparam chunk.section.depth "4" --stringparam generate.section.toc
.level "3" --stringparam html.stylesheet "boostbook.css" --stringparam manifest "standalone_HTML.manifest" --stringparam toc.max.depth "3" --stringparam toc.section.depth "10" --xinclude -o "html/" "/Users/raffi/Personnel/boost_github/
tools/boostbook/xsl/html.xsl" "../../../bin.v2/libs/test/doc/darwin-4.2.1/debug/test_doc.docbook"
