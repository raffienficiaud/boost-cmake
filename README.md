# boost-cmake
An attempt to move on with boost+cmake

This repository should be checked out in `<boost-root>/tools/boost-cmake`, and the `CMakeLists.txt` contained there be copied to the <boost-root> folder.
Summary of actions for getting started:

    cd <boost_root>/tools
    git clone https://github.com/raffienficiaud/boost-cmake.git
    cd -
    cp <boost_root>/tools/boost-cmake/CMakeLists.txt .
    mkdir build
    cd build
    cmake ..

## How it works

* each library or tool of Boost is a package
* each package describes its components and, for each component, their dependencies
* those descriptions are read by the super project `CMakeLists.txt`
* the libraries and components are then included in the main project, in the right order

The description of the components and their dependencies is made via a tiny text file, `boost-decl.cmake`
that in a CMake format.

To integrate a library:

* in this repository, create a folder `libs/<lib>`
* a file in `libs/<lib>/build/boost-decl.cmake` that indicates the components and their dependencies wrt. other
  package and components. Take a look at the existing `boost-decl.cmake` in this repo for the expected format.
* add a `CMakeLists.txt` in each of the `libs/<lib>/<component>`, where the `<components>` are taken from the
  `boost-decl.cmake` file above

The current superproject `CMakeLists.txt` copies those `CMakeLists.txt` and `boost-decl.cmake` to their corresponding folders in the target libraries of Boost, prior to running anything else.

## Ported libraries

Those are meant to show some functional and real-case examples for porting to cmake:

* all header only libraries of boost
* boost.system
* boost.test
* boost.filesystem

## Features

(in random order)

* handles order of declaration of targets, inter dependencies
* there is never direct inclusion from one `CMakeLists.txt` to another one
* the libraries, their documentation and the corresponding tests are decoupled, as
  the current `b2` system is doing
* each `CMakeLists.txt` makes no assumption of an existing super project: they are
  written without the help of any external function or CMake package
* only the two variables `${BOOST_CURRENT_PACKAGE}` and `${BOOST_CURRENT_COMPONENT}`
  are defined when a `CMakeLists.txt` is included. This is mostly for creating
  a convenient `ALIAS` target (for eg. naming convention) or to render things
  nicely in an IDE
* libraries not having a `boost-decl.cmake` / `CMakeLists.txt` are considered as
  header only and automatically added to the super project
* the dependencies between the libraries are explicit, and there is no need for copying header files around.

## Todos (random order)

* components that are not "build" should not be built by default
* filter the package/component that is required by the developer
