# Boost.CMake support
# Copyright Raffi Enficiaud 2017
#
# Distributed under the Boost Software License, Version 1.0.
#    (See accompanying file LICENSE_1_0.txt or copy at
#          http://www.boost.org/LICENSE_1_0.txt)

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

  set(options )
  set(oneValueArgs ROOT_PATH RELATIVE_PATH OUTPUT_VAR)
  set(multiValueArgs)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if("${local_cmd_ROOT_PATH}" STREQUAL "")
    message(FATAL_ERROR "empty path given to boost_get_all_libs")
  endif()

  if("${local_cmd_OUTPUT_VAR}"  STREQUAL "")
    message(FATAL_ERROR "empty output variable given to boost_get_all_libs")
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
    list(APPEND glob_discovered_trimmed ${_lib})
    message(STATUS "Library ${_lib}")
  endforeach()

  set(${local_cmd_OUTPUT_VAR} ${glob_discovered_trimmed} PARENT_SCOPE)
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

    if(EXISTS "${local_cmd_ROOT_PATH}/${_lib}/${description_file}")
      message(STATUS "Exploring dependencies of library ${_lib}")
      include("${local_cmd_ROOT_PATH}/${_lib}/${description_file}")

      string(TOLOWER ${_lib} CURRENT_PACKAGE_NAME_LOWER)
      string(TOUPPER ${_lib} CURRENT_PACKAGE_NAME)
      list(APPEND all_packages ${CURRENT_PACKAGE_NAME_LOWER})

      set(_current_package_components ${BOOST_LIB_${CURRENT_PACKAGE_NAME}_COMPONENTS})
      message(STATUS "** Package ${CURRENT_PACKAGE_NAME} defines components ${_current_package_components}")
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
    if("${_index}" EQUAL "0")
      string(LENGTH "${CURRENT_PACKAGE_NAME_LOWER}:" _length)
      string(SUBSTRING "${_comp}" ${_length} "-1" _package_component)
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
    #message("haar haar ${CURRENT_COMPONENT_NAME_LOWER} '${_comp}' ${_index}")
    if("${_index}" EQUAL "0")
      string(LENGTH "${CURRENT_COMPONENT_NAME_LOWER}:" _length)
      string(SUBSTRING "${_comp}" ${_length} "-1" _component_dependencies)
      list(APPEND all_dependencies ${_component_dependencies})
    endif()
  endforeach()
  set(${local_cmd_OUTPUT_VAR} ${all_dependencies} PARENT_SCOPE)
endfunction()

# simple function that splits package:component into appropriate variables
function(boost_get_package_component_from_name name package component)
  string(FIND ${name} ":" _index)
  math(EXPR _indexp1 "${_index} + 1")
  string(SUBSTRING "${name}" "0" "${_index}" package_lower)
  string(SUBSTRING "${name}" "${_indexp1}" "-1" component_lower)
  set(${package} ${package_lower} PARENT_SCOPE)
  set(${component} ${component_lower} PARENT_SCOPE)
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
#
# When a component is added, the variables ``BOOST_CURRENT_PACKAGE`` and ``BOOST_CURRENT_COMPONENT`` are defined
# to reflect the current package/component being added.
#
function(boost_add_subdirectories_in_order)
  set(options )
  set(oneValueArgs COMPONENT ROOT_PATH )
  set(multiValueArgs ALL_DEPENDENCIES ALL_COMPONENTS EXCLUDE_FROM_ALL_COMPONENTS)
  cmake_parse_arguments(local_cmd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # todo: check uniqueness
  list(LENGTH local_cmd_ALL_COMPONENTS length_components)

  set(already_added_components)
  set(length_added_components 0)

  # best would be to have a recursive algorithm instead
  while("${length_added_components}" LESS "${length_components}")
    # adding components in order
    foreach(_component IN LISTS local_cmd_ALL_COMPONENTS)

      if(${_component} IN_LIST already_added_components)
        continue()
      endif()

      #message(STATUS "Checking component ${_component}")

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
          message("${_dependency} not in '${already_added_components}'")
          set(component_dependencies_all_added FALSE)
          break()
        endif()
      endforeach()

      if(${component_dependencies_all_added})
        list(APPEND already_added_components ${_component})
        boost_get_package_component_from_name(${_component} current_package current_component)
        message(STATUS "Boost:component: adding ${current_package}/${current_component}")

        set(BOOST_CURRENT_PACKAGE "${current_package}")
        set(BOOST_CURRENT_COMPONENT "${current_component}")
        add_subdirectory(${local_cmd_ROOT_PATH}/${current_package}/${current_component} tmp_boost_${current_package}_${current_component})
      endif()

    endforeach()

    list(LENGTH already_added_components length_added_components)
  endwhile()
endfunction()
