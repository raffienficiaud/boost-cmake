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
    find_library(${_library}_file ${_library}) # currently restricted at standard locations
    add_library(${_library} UNKNOWN IMPORTED)
    set_target_properties(${_library} PROPERTIES IMPORTED_LOCATION ${_library}_file)
  endforeach()

  ## "icudt", same rules as before, but we do not have the debug postfix??
  if(${MSVC_OR_INTEL_WINDOWS})
    set(icudt_library_basename "icudt")

    # prepends icuuc_library_basename with an "s" for static and postfix it with a "d" for debug
    set(icudt_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icudt_library_basename}
        )
    set(icudt_generator_list_all
        ${icudt_library_basename}
        s${icudt_library_basename})
  else()
    # preprends an "s" for static
    set(icudt_library_basename "icudata")
    set(icudt_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icudt_library_basename} #
        )
    set(icudt_generator_list_all
        ${icudt_library_basename}
        s${icudt_library_basename})
  endif()

  foreach(_library IN LISTS icudt_generator_list_all)
    find_library(${_library} ${_library}) # currently restricted at standard locations
  endforeach()


  ## icuin,  same rules as before
  if(${MSVC_OR_INTEL_WINDOWS})
    set(icuin_library_basename "icuin")

    # prepends icuuc_library_basename with an "s" for static and postfix it with a "d" for debug
    set(icuin_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuin_library_basename}$<$<CONFIG:Debug>:"d"> #
        )
    set(icuin_generator_list_all
        "${icuin_library_basename}"
        "s${icuin_library_basename}"
        "${icuin_library_basename}d"
        "s${icuin_library_basename}d")

  else()
    # preprends an "s" for static
    set(icuin_library_basename "icudata")
    set(icuin_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuin_library_basename} #
        )
    set(icuin_generator_list_all
        "${icuin_library_basename}"
        "s${icuin_library_basename}")
  endif()

  foreach(_library IN LISTS icuin_generator_list_all)
    find_library(${_library} ${_library}) # currently restricted at standard locations
  endforeach()

endif()


set(regex_target_link_opts
    PUBLIC
      ${icuuc_generator}
      ${icudt_generator}
      ${icuin_generator})
set(regex_target_compile_def_opts
    PUBLIC
      BOOST_HAS_ICU=1
      $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:U_STATIC_IMPLEMENTATION=1>)


# given a detected ICU, we need to check that a small program is actually running
# correctly
if(NOT DEFINED BOOST_REGEX_ICU_CHECKS OR "${BOOST_REGEX_ICU_CHECKS}" STREQUAL "")

  include(CheckCXXSourceCompiles)

  
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/has_icu_test.cpp" source_code)
  set(icudt_generator_list_all_to_check ${icudt_generator_list_all})
  if(${MSVC_OR_INTEL_WINDOWS})
    # we double this one
    set(icudt_generator_list_all_to_check
        ${icudt_generator_list_all}
        ${icudt_generator_list_all})
  endif()

  list(LENGTH icudt_generator_list_all_to_check var_length)
  foreach(element RANGE ${var_length})

    set(CMAKE_REQUIRED_INCLUDES "")
    set(CMAKE_REQUIRED_LIBRARIES ${regex_target_link_opts})
    CHECK_CXX_SOURCE_COMPILES("${source_code}" icu_check_run_var)

    message(FATAL_ERROR "icu_check_run_var/${_link}: ${icu_check_run_var}")
    #try_run(
    #        COMPILE_DEFINITIONS
    #        LINK_LIBRARIES ${regex_target_link_opts})
  endforeach()

  #set(BOOST_REGEX_ICU_CHECKS "0" CACHE INTERNAL "indicates if the regex/icu checks have already been performed")
endif()


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

target_include_directories(
  boost_regex
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../include>
    $<INSTALL_INTERFACE:include>
  )
target_link_libraries(boost_regex
  PUBLIC
    boost::config
    boost::predef
    boost::assert
    boost::throw_exception
    boost::smart_ptr
    boost::mpl
    boost::type_traits
    boost::integer
    boost::functional
  )

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
