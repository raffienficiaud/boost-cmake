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

To integrate a library:

* create a folder `libs/<lib>`
* a file in `libs/<lib>/build/boost-decl.cmake` should indicate the components and their dependencies wrt. other
  package and components
* a `CMakeLists.txt` should be included in each of the `libs/<lib>/<component>`, where the components are taken from the
  `boost-decl.cmake` file above

The current superproject `CMakeLists.txt` copies those `CMakeLists.txt` and `boost-decl.cmake` to their corresponding folders in the target libraries of Boost.

## Ported libraries

Those are meant to show some functional examples of real-case porting to cmake.

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
