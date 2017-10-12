# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.regex)


# looking for ICUs
# if ICU is given or not
if(DEFINED BOOST_REGEX_ICU_PATH AND NOT ("${BOOST_REGEX_ICU_PATH}" STREQUAL ""))

  # IF ICU FOUND!!!!
  add_definitions(-DBOOST_HAS_ICU=1)

else()

  # I believe this should be WIN32 instead to include intel on windows
  if(MSVC OR WIN32)
    set(MSVC_OR_INTEL_WINDOWS TRUE)
  else()
    set(MSVC_OR_INTEL_WINDOWS FALSE)
  endif()

  ## "icuuc"
  if(${MSVC_OR_INTEL_WINDOWS})
    set(icuuc_library_basename "icuuc")

    # prepends icuuc_library_basename with an "s" for static and postfix it with a "d" for debug
    set(icuuc_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuuc_library_basename}$<$<CONFIG:Debug>:"d"> #
        )

    # we need to indicate all the possible combinations because we cannot perform any find during
    # the generator expression evaluation
    set(icuuc_generator_list_all
        "${icuuc_library_basename}"
        "s${icuuc_library_basename}"
        "${icuuc_library_basename}d"
        "s${icuuc_library_basename}d")
  else()
    set(icuuc_library_basename "icuuc")
    # preprends an "s" for static
    set(icuuc_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuuc_library_basename} #
        )
    set(icuuc_generator_list_all
        ${icuuc_library_basename}
        s${icuuc_library_basename})
  endif()

  foreach(_library IN LISTS icuuc_generator_list_all)
    find_library(${_library} ${_library}) # currently restricted at standard locations
  endforeach()

  ## "icudt", same rules as before, but we do not have the debug postfix??
  if(${MSVC_OR_INTEL_WINDOWS})
    set(icudt_library_basename "icudt")

    # prepends icuuc_library_basename with an "s" for static and postfix it with a "d" for debug
    set(icudt_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icudt_library_basename}
        )
  else()
    # preprends an "s" for static
    set(icudt_library_basename "icudata")
    set(icudt_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icudt_library_basename} #
        )
  endif()


  ## icuin,  same rules as before
  if(${MSVC_OR_INTEL_WINDOWS})
    set(icuin_library_basename "icuin")

    # prepends icuuc_library_basename with an "s" for static and postfix it with a "d" for debug
    set(icuin_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuin_library_basename}$<$<CONFIG:Debug>:"d"> #
        )
  else()
    # preprends an "s" for static
    set(icuin_library_basename "icudata")
    set(icuin_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuin_library_basename} #
        )
  endif()

endif()


# given a detected ICU, we need to check that a small program is actually running
# correctly



file(GLOB_RECURSE boost_regex_HEADERS ../include/*.*)
set(boost_regex_SRC
  ../src/c_regex_traits.cpp
  ../src/cpp_regex_traits.cpp
  ../src/cregex.cpp
  ../src/fileiter.cpp
  ../src/icu.cpp
  ../src/instances.cpp
  ../src/posix_api.cpp
  ../src/regex.cpp
  ../src/regex_debug.cpp
  ../src/regex_raw_buffer.cpp
  ../src/regex_traits_defaults.cpp
  ../src/static_mutex.cpp
  ../src/w32_regex_traits.cpp
  ../src/wc_regex_traits.cpp
  ../src/wide_posix_api.cpp
  ../src/winstances.cpp
  ../src/usinstances.cpp
)

add_library(boost_regex
  ${boost_regex_HEADERS}
  ${boost_regex_SRC})

# check if this can go to the target_compile_definitions
set_target_properties(boost_regex
    PROPERTIES DEFINE_SYMBOL "BOOST_REGEX_SOURCE"
  )
target_compile_definitions(
  boost_regex
  PUBLIC
    $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:BOOST_REGEX_DYN_LINK=1>
  )

# Raffi: todo add this from the Jamfile
#  : # See https://svn.boost.org/trac/boost/ticket/5049
#    <target-os>hpux,<toolset>gcc:<define>_INCLUDE_STDC__SOURCE_199901

target_include_directories(
  boost_regex
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
  )
target_link_libraries(boost_regex
  PUBLIC
    boost::config
  )
#target_link_libraries(boost_regex
#  PUBLIC boost::config boost::predef boost::assert boost::core
#  )

install(
  TARGETS boost_regex
  RUNTIME DESTINATION lib
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  )


if(DEFINED BOOST_CURRENT_PACKAGE)
  add_library(boost::${BOOST_CURRENT_PACKAGE} ALIAS boost_regex)
  set_target_properties(boost_regex PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
endif()
