# boost-cmake
An attempt to move on with boost+cmake

This repository should be checked out in `<boost-root>/tools/boost-cmake`, and the `CMakeLists.txt` contained there be copied to the <boost-root> folder.

Then:

    mkdir build
    cd build
    cmake ..

To integrate a library:

* a file in `<boost-root>/libs/<lib>/build/boost-decl.cmake` should indicate the components and their dependencies regarding other
  package and components
* a CMakeLists.txt should be included in each of the `<boost-root>/libs/<lib>/<component>`, where the components are taken from the
  `boost-decl.cmake` file above

The boost.test library contains such an example (branch `topic/cmake-integration` [here](https://github.com/boostorg/test/tree/topic/cmake-integration))

## Todos (random order)

* components that are not "build" should not be built by default
* come up with a default for the libraries that do not have a cmake: could be for instance
  header only assumption
* filter the package/component that is required by the developer
