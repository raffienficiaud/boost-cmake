# boost-cmake
An attempt to move on with boost+cmake

This repository should be checked out in `<boost-root>/tools/boost-cmake`, and the `CMakeLists.txt` contained there be copied to the `<boost-root>` folder.
Summary of actions for getting started:

    cd <boost_root>/tools
    git clone https://github.com/raffienficiaud/boost-cmake.git
    cd -
    cp <boost_root>/tools/boost-cmake/CMakeLists.txt .
    mkdir build
    cd build
    cmake ..

## How it works

* each library or tool of Boost is called a **package**
* each package describes its **components** and, for each component, their dependencies
* those descriptions are read by the super project `CMakeLists.txt`
* the libraries and components are then included in the main project, in the *topological* order of their dependencies

### Declaring components and dependencies

The description of the package, components and their dependencies is made via a tiny text file, `boost-decl.cmake`
that is in a CMake format.

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
* ``boost.system``
* ``boost.test``
* ``boost.filesystem``
* ``boost.program_options``
* ``boost.quickbook``

## Features

(in random order)

* handles order of declaration of targets, inter dependencies
* there is **never direct inclusion** from one `CMakeLists.txt` to another one
* the libraries, their documentation and the corresponding tests are decoupled, as
  the current `b2` system is doing. This should allow for easier redistribution (discarding the packaging
  of doc and tests, the main `build/CMakeLists.txt` staying standalone)
* each `CMakeLists.txt` makes no assumption of an existing super project: they are
  written without the help of any external function or CMake package. This is again to ease
  modularity and redistribution
* only the two variables `${BOOST_CURRENT_PACKAGE}` and `${BOOST_CURRENT_COMPONENT}`
  are defined when a `CMakeLists.txt` is included. This is mostly for creating
  a convenient `ALIAS` target (for eg. naming convention) or to render things
  nicely in an IDE
* libraries not having a `boost-decl.cmake` / `CMakeLists.txt` are considered as
  header only and automatically added to the super project, which lowers the development/porting
* libraries *having* a `boost-decl.cmake` but not having a `CMakeLists.txt` are considered header only, and their dependencies are properly declared such that their dependencies are propagated properly to their dependant/child projects.
* the dependencies between the libraries are explicit, which is a **good** thing
* there is no need for copying header files around: the files stay in their original library/submodule/location
  and their location is propagated to dependent project
*

## CMake options
Those are high level options passed to cmake. For example, to have all files for header only libraries, directly in your IDE:

```
# same prelude as above
cmake -G <your generator> -DBOOST_CREATE_VISIBLE_HEADER_ONLY=ON
```

### Available options

* `BOOST_WITH_COMPONENT`: restricts the global project to this set of coma separated components, and the union of all their
  parent dependencies. Example

      # same prelude as above
      cmake -DBOOST_WITH_COMPONENT=test:build ..

* `BOOST_BUILD_DOC` if set to `ON`, will build the documentation as part of the default build (defaults to `OFF`)
* `BOOST_BUILD_TEST` if set to `ON`, will build the test as part of the default build (defaults to `OFF`)
* `BOOST_CREATE_VISIBLE_HEADER_ONLY` if set to `ON`, will create a target for header only libraries that are
  visible on the IDE (as custom commands)

## Naming conventions
Some naming conventions are under development. Currently 3 possible components:

* `build`: contains the main build targets
* `doc`: contains the documentation targets
* `test`: contains the test targets

Alias are used to map any target to a ``boost::library`` (where library is a known library or tool of boost).

### Build

* `boost::<package>` is an alias to the default build artifact of package `<package>`
* `boost::<package>::<variant>` is an alias to a specific variant of package `<package>`, if defined
  `<variant>` can be

  * `header`

### Tests

* the tests binary file can take any name
* the declared test name should allow for easy subset filtering from `ctest`
* a possible convention would be `boost_<package>__<name-of-test>`
* `boost::<package>__build_test` is an alias for building the tests, in case those are not part of the default build

# Unit testing boost-cmake

``boost-cmake`` contains unit tests on its components/functions. You may run those by adding the option ``-DBUILD_BOOST_CMAKE_TESTS=ON`` and directly from the ``boost-cmake`` folder, like this:

    # cloning the repo in a clean boost superproject
    cd <boost_root>/tools
    git clone https://github.com/raffienficiaud/boost-cmake.git
    cd boost-cmake

    # creating the binary folder
    mkdir build
    cd build

    # configuring for tests
    cmake -DDBUILD_BOOST_CMAKE_TESTS=ON ..

    # running the tests
    ctest

In case of tests, no other action is performed by the tool.

### Documentation

## Todos (random order)

* port filesystem and system tests
* port regex
* unit testing quickbook functions
