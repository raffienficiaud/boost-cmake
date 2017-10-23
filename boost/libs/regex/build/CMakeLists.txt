# Copyright 2017, Raffi Enficiaud

# Use, modification, and distribution are subject to the
# Boost Software License, Version 1.0. (See accompanying file
# LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# See http://www.boost.org/libs/test for the library home page.

project(boost.regex)


# Looking for ICUs. All this would preferably go to another cmake file
# but in the current state of the superproject, this is more convenient for developments.

if(NOT DEFINED BOOST_REGEX_DISABLE_ICU OR NOT "${BOOST_REGEX_DISABLE_ICU}")

  # if ICU is given, we indicate this in the path for the find_library commands
  set(ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS)
  if(DEFINED BOOST_REGEX_ICU_LIB AND NOT ("${BOOST_REGEX_ICU_LIB}" STREQUAL ""))

    # IF ICU FOUND!!!!
    #add_definitions(-DBOOST_HAS_ICU=1)
    set(ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS 
        ${ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS}
        NO_DEFAULT_PATH
        PATHS ${BOOST_REGEX_ICU_LIB})

    # this is for findICU
    set(ICU_ROOT ${BOOST_REGEX_ICU_LIB}/..)

  endif()

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
    find_library(${_library}_file 
      ${_library}
      ${ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS})
    add_library(${_library} UNKNOWN IMPORTED)
    set_target_properties(${_library} PROPERTIES IMPORTED_LOCATION ${_library}_file)
    message(STATUS "ICU library ${_library}: ${${_library}_file}")
  endforeach()

  ## 
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
    find_library(${_library}_file 
      ${_library}
      ${ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS})
    add_library(${_library} UNKNOWN IMPORTED)
    set_target_properties(${_library} PROPERTIES IMPORTED_LOCATION ${_library}_file)
    message(STATUS "ICU library ${_library}: ${${_library}_file}")
  endforeach()

  ## 
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
    set(icuin_library_basename "icui18n")
    set(icuin_generator
        $<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,"STATIC_LIBRARY">:"s">${icuin_library_basename} #
        )
    set(icuin_generator_list_all
        "${icuin_library_basename}"
        "s${icuin_library_basename}")
    set(${icuin_library_basename}_name 
        ${CMAKE_SHARED_LIBRARY_PREFIX}${icuin_library_basename}.${CMAKE_SHARED_LIBRARY_SUFFIX})
    set(s${icuin_library_basename}_name 
        ${CMAKE_STATIC_LIBRARY_PREFIX}${icuin_library_basename}.${CMAKE_STATIC_LIBRARY_SUFFIX})
  endif()

  foreach(_library IN LISTS icuin_generator_list_all)
    find_library(
      ${_library}_file # name of the variable holding the library
      NAMES ${${_library}_name} # name of the library
      ${ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS})
    add_library(${_library} UNKNOWN IMPORTED)
    set_target_properties(${_library} PROPERTIES IMPORTED_LOCATION ${_library}_file)
    message(STATUS "ICU library ${_library}: ${${_library}_file}")
  endforeach()

  # default ICU
  # set(ICU_DEBUG TRUE) # activate this to have better error messages
  find_package(ICU OPTIONAL_COMPONENTS data i18n uc)
  message(STATUS "ICU: ${ICU_LIBRARIES} ${ICU_FIND_LIBRARY_ADDITIONAL_OPTIONS}")



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
    if(${MSVC_OR_INTEL_WINDOWS})
      # we double this one
      set(icudt_generator_list_all_to_check
          ${icudt_generator_list_all}
          ${icudt_generator_list_all})
    endif()

    list(LENGTH icudt_generator_list_all_to_check var_length)
    foreach(element RANGE ${var_length})

      list(GET icuuc_generator_list_all ${element} current_icuuc)
      list(GET icudt_generator_list_all_to_check ${element} current_icudt)
      list(GET icuin_generator_list_all ${element} current_icuin)
      set(CMAKE_REQUIRED_INCLUDES "")
      set(CMAKE_REQUIRED_LIBRARIES "${current_icuuc}" "${current_icudt}" "${current_icuin}")
      CHECK_CXX_SOURCE_COMPILES("${source_code}" icu_check_run_var)

      message(FATAL_ERROR "icu_check_run_var/${_link}: ${icu_check_run_var}"
          "${current_icuuc}_file" "${current_icudt}_file" "${current_icuin}_file")
      #try_run(
      #        COMPILE_DEFINITIONS
      #        LINK_LIBRARIES ${regex_target_link_opts})
    endforeach()

    #set(BOOST_REGEX_ICU_CHECKS "0" CACHE INTERNAL "indicates if the regex/icu checks have already been performed")
  endif()


endif() # if BOOST_REGEX_DISABLE_ICU


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
