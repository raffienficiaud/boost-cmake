# Boost.CMake support
# Copyright Raffi Enficiaud 2017
#
# Distributed under the Boost Software License, Version 1.0.
#    (See accompanying file LICENSE_1_0.txt or copy at
#          http://www.boost.org/LICENSE_1_0.txt)

include(CMakeParseArguments)

#.rst:
# .. command:: boost_get_all_libs
#
#   Returns all subfolders of a path. Only directories are kept
#
#   ::
#
#     boost_get_all_libs(
#         ROOT_PATH root_path
#         OUTPUT_VAR output_variable
#         [RELATIVE_PATH relative_to]
#         )
#
#   ``ROOT_PATH``
#     the root folder under which the subfolders will be discovered
#   ``OUTPUT_VAR``
#     the output variable that will be filled with the list of folders
#   ``RELATIVE_PATH``
#     (optional) if set, the returned path will be relative to this path
function(boost_get_all_libs)

  set(options SHOULD_HAVE_INCLUDE)
  set(oneValueArgs ROOT_PATH RELATIVE_PATH OUTPUT_VAR)
  set(multiValueArgs)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if("${local_cmd_ROOT_PATH}" STREQUAL "")
    message(FATAL_ERROR "empty path given to boost_get_all_libs")
  endif()

  if("${local_cmd_OUTPUT_VAR}"  STREQUAL "")
    message(FATAL_ERROR "empty output variable given to boost_get_all_libs")
  endif()

  if("${local_cmd_SHOULD_HAVE_INCLUDE}"  STREQUAL "")
    set(local_cmd_SHOULD_HAVE_INCLUDE FALSE)
  endif()

  set(glob_additional_options)
  if(NOT "${local_cmd_RELATIVE_PATH}" STREQUAL "")
    set(glob_additional_options RELATIVE "${local_cmd_RELATIVE_PATH}")
  endif()

  file(GLOB glob_discovered
       LIST_DIRECTORIES true
       ${glob_additional_options}
       "${local_cmd_ROOT_PATH}/*"
       )

  set(glob_discovered_trimmed)
  foreach(_lib IN LISTS glob_discovered)
    if(NOT IS_DIRECTORY "${local_cmd_RELATIVE_PATH}/${_lib}")
      continue()
    endif()

    if("${CMAKE_CURRENT_LIST_DIR}" STREQUAL "${local_cmd_RELATIVE_PATH}/${_lib}")
      continue()
    endif()

    if(NOT (EXISTS "${local_cmd_RELATIVE_PATH}/${_lib}/include") AND "${local_cmd_SHOULD_HAVE_INCLUDE}")
      # message(STATUS "Parsing subfolders of '${local_cmd_RELATIVE_PATH}/${_lib}'")
      file(GLOB glob_discovered_secondary
           LIST_DIRECTORIES true
           ${glob_additional_options}
           "${local_cmd_RELATIVE_PATH}/${_lib}/*"
           )
      #message(STATUS "${local_cmd_RELATIVE_PATH}/${_lib}/ : ${glob_discovered_secondary}")
      foreach(_lib_secondary IN LISTS glob_discovered_secondary)
        if(NOT IS_DIRECTORY "${local_cmd_RELATIVE_PATH}/${_lib_secondary}")
          continue()
        endif()
        if(NOT EXISTS "${local_cmd_RELATIVE_PATH}/${_lib_secondary}/include")
          continue()
        endif()
        list(APPEND glob_discovered_trimmed ${_lib_secondary})
        #message(STATUS "Library ${_lib_secondary}")
      endforeach()
    else()
      list(APPEND glob_discovered_trimmed ${_lib})
      #message(STATUS "Library ${_lib}")
    endif()

  endforeach()

  set(${local_cmd_OUTPUT_VAR} ${glob_discovered_trimmed} PARENT_SCOPE)
endfunction()


# simple function that splits path/package:component into appropriate variables
function(boost_get_package_component_from_name name path package component)
  string(FIND "${name}" ":" _index REVERSE)
  math(EXPR _indexp1 "${_index} + 1")
  string(SUBSTRING "${name}" "0" "${_index}" _package_path)
  string(SUBSTRING "${name}" "${_indexp1}" "-1" _component)

  string(FIND "${_package_path}" "/" _index REVERSE)
  if("${_index}" STREQUAL "-1")
    set(_path "${_package_path}")
    set(_package "${_package_path}")
  else()
    string(SUBSTRING "${_package_path}" "0" "${_index}" _path)
    math(EXPR _indexp1 "${_index} + 1")
    string(SUBSTRING "${_package_path}" "${_indexp1}" "-1" _package)
    string(REPLACE "/" ":" _path_colons "${_path}")

    set(_path "${_path}/${_package}")
    set(_package "${_path}")
    #set(_package "${_path_colons}:${_package}")
  endif()

  set(${path} ${_path} PARENT_SCOPE)
  set(${package} ${_package} PARENT_SCOPE)
  set(${component} ${_component} PARENT_SCOPE)
endfunction()

#.rst:
# .. command:: boost_discover_packages_and_components
#
#   Returns all packages and components from a list of parsed folders
#   (see :command:`boost_get_all_libs`)
#
#   ::
#
#     boost_discover_packages_and_components(
#         LIST_FOLDERS list_of_folders
#         ROOT_PATH root_path
#         PACKAGES_OUTPUT_VAR variable_of_packages
#         COMPONENTS_OUTPUT_VAR variable_of_components
#         )
#
#   ``LIST_FOLDERS``
#     the list of folders previously discovered with :command:`boost_get_all_libs`
#   ``ROOT_PATH``
#     the root folder base of the element of the list
#   ``PACKAGES_OUTPUT_VAR``
#     the variable that receives the packages
#   ``COMPONENTS_OUTPUT_VAR``
#     the variable that receives the components
#
# The packages and components are all in lower case. The components are in the form
# `package_name:component_name`.
function(boost_discover_packages_and_components)

  set(options )
  set(oneValueArgs ROOT_PATH PACKAGES_OUTPUT_VAR COMPONENTS_OUTPUT_VAR DEPENDENCY_VAR)
  set(multiValueArgs LIST_FOLDERS)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # discovering all components
  set(standard_components "DOC" "TEST" "BUILD")
  set(description_file "build/boost-decl.cmake")

  set(all_packages )
  set(all_packages_and_components )
  set(all_components_dependency)
  foreach(_lib IN LISTS local_cmd_LIST_FOLDERS)

    # _lib can potentially contain a '/' and be "path": eg "numeric/ublas"
    boost_get_package_component_from_name("${_lib}:" path package _component_dummy)
    string(TOLOWER "${package}" CURRENT_PACKAGE_NAME_LOWER)
    string(TOUPPER "${package}" CURRENT_PACKAGE_NAME)

    # if there is no description of the component, then we do this implictely
    # by adding the :build component and making doc/test appear as dependencies (if those exist)
    list(APPEND all_packages ${CURRENT_PACKAGE_NAME_LOWER})

    if(EXISTS "${local_cmd_ROOT_PATH}/${_lib}/${description_file}")
      message(STATUS "Exploring dependencies of library ${_lib}")
      include("${local_cmd_ROOT_PATH}/${_lib}/${description_file}")

      #list(APPEND all_packages ${CURRENT_PACKAGE_NAME_LOWER})

      set(_current_package_components ${BOOST_LIB_${CURRENT_PACKAGE_NAME}_COMPONENTS})
      message(STATUS "** Package ${CURRENT_PACKAGE_NAME} defines components '${_current_package_components}'")
      # todo: check that package has not been defined yet

      # integrity check and discovery
      foreach(_component IN LISTS _current_package_components)
        string(TOLOWER ${_component} CURRENT_COMPONENT_NAME_LOWER)
        string(TOUPPER ${_component} CURRENT_COMPONENT_NAME)
        if(NOT ("${CURRENT_COMPONENT_NAME}" IN_LIST standard_components))
          message(WARNING "Non standard component '${_component}'")
        endif()
        set(_current_component_dependencies ${BOOST_LIB_${CURRENT_PACKAGE_NAME}_COMPONENTS_${CURRENT_COMPONENT_NAME}_DEPENDENCY})
        message(STATUS "*** Component '${_component}' dependent of '${_current_component_dependencies}'")
        list(APPEND all_packages_and_components "${CURRENT_PACKAGE_NAME_LOWER}:${CURRENT_COMPONENT_NAME_LOWER}")
        foreach(_dependency IN LISTS _current_component_dependencies)
          list(APPEND all_components_dependency "${CURRENT_PACKAGE_NAME_LOWER}:${CURRENT_COMPONENT_NAME_LOWER}:${_dependency}")
        endforeach()
        # todo: check that component has not been defined yet

        # advertising the components dependencies to the parent
        #set(BOOST_LIB_${CURRENT_PACKAGE_NAME}_COMPONENTS_${CURRENT_COMPONENT_NAME}_DEPENDENCY
        #    ${BOOST_LIB_${CURRENT_PACKAGE_NAME}_COMPONENTS_${CURRENT_COMPONENT_NAME}_DEPENDENCY}
        #    PARENT_SCOPE)
      endforeach()
    else()
      message(STATUS "** Package [implicit] ${CURRENT_PACKAGE_NAME_LOWER} with component 'build'")
      list(APPEND all_packages_and_components "${CURRENT_PACKAGE_NAME_LOWER}:build")
      if(FALSE)
        # for the moment: disabling as there are some libs containing a CMakeLists.txt that is breaking the full project
        foreach(_current_component doc test)
          if(EXISTS "${local_cmd_ROOT_PATH}/${_lib}/${_current_component}/CMakeLists.txt")
            list(APPEND all_packages_and_components "${CURRENT_PACKAGE_NAME_LOWER}:${_current_component}")
            list(APPEND all_components_dependency "${CURRENT_PACKAGE_NAME_LOWER}:${_current_component}:${CURRENT_PACKAGE_NAME_LOWER}:build")
          endif()
        endforeach()
      endif()
    endif()
  endforeach()

  # advertising all package:components to the parent scope
  set(${local_cmd_PACKAGES_OUTPUT_VAR} ${all_packages} PARENT_SCOPE)
  set(${local_cmd_COMPONENTS_OUTPUT_VAR} ${all_packages_and_components} PARENT_SCOPE)
  set(${local_cmd_DEPENDENCY_VAR} ${all_components_dependency} PARENT_SCOPE)
endfunction()


#.rst:
# .. command:: boost_get_all_components
#
#  Returns all the components of a given package
function(boost_package_get_all_components )
  set(options )
  set(oneValueArgs PACKAGE OUTPUT_VAR )
  set(multiValueArgs ALL_COMPONENTS)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(all_components )
  string(TOLOWER ${local_cmd_PACKAGE} CURRENT_PACKAGE_NAME_LOWER)
  foreach(_comp IN LISTS local_cmd_ALL_COMPONENTS)
    string(FIND "${_comp}" "${CURRENT_PACKAGE_NAME_LOWER}:" _index)
    if(NOT "${_index}" EQUAL "0")
      string(LENGTH "${CURRENT_PACKAGE_NAME_LOWER}:" _length)
      string(SUBSTRING "${_comp}" "${_length}" "-1" _package_component)
      list(APPEND all_components ${_package_component})
    endif()
  endforeach()
  set(${local_cmd_OUTPUT_VAR} ${all_components} PARENT_SCOPE)
endfunction()

#.rst:
# .. command:: boost_get_all_components
#
#  Returns all the components of a given package
#
#  ``COMPONENT``
#    name of the component
#  ``OUTPUT_VAR``
#    variable that will receive the list of dependencies
#  ``ALL_DEPENDENCIES``
#    variable containing all the dependencies (discovered by :command:`boost_discover_packages_and_components`)
function(boost_package_get_all_dependencies )
  set(options )
  set(oneValueArgs COMPONENT OUTPUT_VAR )
  set(multiValueArgs ALL_DEPENDENCIES)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(all_dependencies )
  string(TOLOWER ${local_cmd_COMPONENT} CURRENT_COMPONENT_NAME_LOWER)
  foreach(_comp IN LISTS local_cmd_ALL_DEPENDENCIES)
    string(FIND "${_comp}" "${CURRENT_COMPONENT_NAME_LOWER}:" _index)
    if("${_index}" EQUAL "0")
      string(LENGTH "${CURRENT_COMPONENT_NAME_LOWER}:" _length)
      string(SUBSTRING "${_comp}" "${_length}" "-1" _component_dependencies)
      list(APPEND all_dependencies ${_component_dependencies})
    endif()
  endforeach()
  set(${local_cmd_OUTPUT_VAR} ${all_dependencies} PARENT_SCOPE)
endfunction()



#.rst:
# .. command:: boost_add_subdirectories_in_order
#
#  Adds the components by honoring the dependencies.
#
#  ``COMPONENT``
#    if specified: narrows the inclusion to this component and its dependencies (not implemented yet)
#  ``ROOT_PATH``
#    the root folder base of the element of the list
#  ``ALL_DEPENDENCIES``
#    variable containing all the dependencies (discovered by :command:`boost_discover_packages_and_components`)
#  ``ALL_COMPONENTS``
#    variable containing all the components (discovered by :command:`boost_discover_packages_and_components`)
#  ``VISIBLE_HEADER_ONLY``
#    an option that, if set, will create a custom target for header only libraries such that their sources
#    are available in an IDE
#  ``EXCLUDE_FROM_ALL_COMPONENTS``
#    indicates the components to be excluded (eg. doc, test) by the default build
#  ``SUBSET_TO``
#    if defined, will restrict the set of all component to the provided list and all their dependecies (transitive to their parent)
#
# When a component is added, the variables ``BOOST_CURRENT_PACKAGE`` and ``BOOST_CURRENT_COMPONENT`` are defined
# to reflect the current package/component being added.
#
function(boost_add_subdirectories_in_order)
  set(options VISIBLE_HEADER_ONLY)
  set(oneValueArgs COMPONENT ROOT_PATH )
  set(multiValueArgs ALL_DEPENDENCIES ALL_COMPONENTS EXCLUDE_FROM_ALL_COMPONENTS SUBSET_TO)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(lower_case_component_to_exclude)
  foreach(_element IN LISTS local_cmd_EXCLUDE_FROM_ALL_COMPONENTS)
    string(TOLOWER ${_element} _lower)
    list(APPEND lower_case_component_to_exclude "${_lower}")
  endforeach()

  set(subset_component_to_add)
  if("${local_cmd_SUBSET_TO}" STREQUAL "")
    set(subset_component_to_add ${local_cmd_ALL_COMPONENTS})
  else()
    list(REMOVE_DUPLICATES local_cmd_SUBSET_TO)
    message(STATUS "Subset of components: '${local_cmd_SUBSET_TO}'")
    while(NOT "${local_cmd_SUBSET_TO}" STREQUAL "")
      #message(STATUS "local_cmd_SUBSET_TO: ${local_cmd_SUBSET_TO}")
      list(GET local_cmd_SUBSET_TO 0 current_component)
      list(REMOVE_AT local_cmd_SUBSET_TO 0)
      list(APPEND subset_component_to_add ${current_component})
      boost_package_get_all_dependencies(
        COMPONENT ${current_component}
        ALL_DEPENDENCIES ${local_cmd_ALL_DEPENDENCIES}
        OUTPUT_VAR current_component_dependencies
      )
      foreach(_component IN LISTS current_component_dependencies)
        if(${_component} IN_LIST subset_component_to_add)
          continue()
        endif()
        list(APPEND local_cmd_SUBSET_TO ${_component})
      endforeach()
    endwhile()
  endif()
  message(STATUS "Components to build: '${subset_component_to_add}'")

  list(REMOVE_DUPLICATES subset_component_to_add)
  list(LENGTH subset_component_to_add length_components)

  set(already_added_components)
  set(length_added_components 0)

  # best would be to have a recursive algorithm instead
  while("${length_added_components}" LESS "${length_components}")
    # adding components in order
    foreach(_component IN LISTS subset_component_to_add)

      if(${_component} IN_LIST already_added_components)
        continue()
      endif()

      #message("Checking component ${_component}")
      boost_package_get_all_dependencies(
        COMPONENT ${_component}
        ALL_DEPENDENCIES ${local_cmd_ALL_DEPENDENCIES}
        OUTPUT_VAR current_component_dependencies
      )

      set(component_dependencies_all_added TRUE)
      foreach(_dependency IN LISTS current_component_dependencies)
        # checking
        if(NOT (${_dependency} IN_LIST local_cmd_ALL_COMPONENTS))
          message(FATAL_ERROR "The dependency '${_dependency}' for component '${_component}' does not exist (${local_cmd_ALL_COMPONENTS})")
        endif()

        if(NOT (${_dependency} IN_LIST already_added_components))
          #message("'${_dependency}' not yet added")
          set(component_dependencies_all_added FALSE)
          break()
        endif()
      endforeach()

      if(${component_dependencies_all_added})
        list(APPEND already_added_components ${_component})
        boost_get_package_component_from_name("${_component}" path current_package current_component)
        message(STATUS "Boost:component: adding ${current_package}:${current_component} from ${path}")

        set(BOOST_CURRENT_PACKAGE "${current_package}")
        set(BOOST_CURRENT_COMPONENT "${current_component}")
        string(REPLACE "/" "_" current_package_no_slash "${current_package}")

        if(EXISTS "${local_cmd_ROOT_PATH}/${path}/${current_component}/CMakeLists.txt")
          # in case we have a proper CMakeLists.txt, we include it
          set(add_subdirectory_options)
          if("${current_component}" IN_LIST lower_case_component_to_exclude)
            set(add_subdirectory_options EXCLUDE_FROM_ALL)
          endif()
          add_subdirectory(${local_cmd_ROOT_PATH}/${path}/${current_component}
                           tmp_boost_${current_package}_${current_component}
                           ${add_subdirectory_options})
        else()
          # in case we do not have a cmakelists.txt, we simulate a header only
          message(STATUS "-- [header only]")
          add_library(boost_${current_package_no_slash}_header_only INTERFACE)
          target_include_directories(boost_${current_package_no_slash}_header_only
            INTERFACE
              $<BUILD_INTERFACE:${local_cmd_ROOT_PATH}/${path}/include>
              $<INSTALL_INTERFACE:${path}/include>)
          add_library(boost::${current_package_no_slash} ALIAS boost_${current_package_no_slash}_header_only)
          add_library(boost::${current_package_no_slash}::header ALIAS boost_${current_package_no_slash}_header_only)

          if(${local_cmd_VISIBLE_HEADER_ONLY})
            file(GLOB_RECURSE
                 _current_library_headers
                 ${local_cmd_ROOT_PATH}/${path}/include/*)
            add_custom_target(
              boost_${current_package_no_slash}
              SOURCES ${_current_library_headers})
            set_target_properties(boost_${current_package_no_slash}
              PROPERTIES FOLDER "boost.${BOOST_CURRENT_PACKAGE}/${BOOST_CURRENT_COMPONENT}")
          endif()
        endif()
      endif()

    endforeach()

    list(LENGTH already_added_components length_added_components)
  endwhile()
endfunction()
