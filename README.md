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

The boost.test library contains such an example (branch `topic/cmake-integration`)
