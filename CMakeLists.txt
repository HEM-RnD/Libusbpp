
cmake_minimum_required(VERSION 3.19.0)

project (libusbpp LANGUAGES CXX VERSION 1.0.0)

set (PACKAGE_NAME "${PROJECT_NAME}")
set (PACKAGE_DESCRIPTION "C++ wrapper API of C API for USB device access (libusb-1.0)")
set (PACKAGE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
set (PACKAGE "${PACKAGE_NAME}-${PACKAGE_VERSION}")

# The API version (SOVERSION) of the USBPP libraries.
# Increment this when more or fewer functions are included in the
# library, the function prototype changes, or data type changes.
#
# The SOVERSION is not necessarily the same as the major version.
# The rule is that any breakage of the ABI must be indicated by
# incrementing the SOVERSION. So, adding e.g. functions is no
# problem, modifying argument lists or removing functions would
# required the SOVERSION to be incremented. Similar rules hold of
# course for non-opaque data-structures. For C++ the whole issue
# is infinitely more complicated, as determining whether the ABI
# was changed in an incompatible way is AFAIK nearly impossible.
#
# Refer to:
# cmake --help-command set_target_properties
# cmake --help-property SOVERSION
# https://community.kde.org/Policies/Binary_Compatibility_Issues_With_C++
#
set (LIBUSBPP_LIB_SOVERSION 0)
set (LIBUSBPP_LIB_VERSION "${LIBUSBPP_LIB_SOVERSION}.${PACKAGE_VERSION}")
set (LIBUSBPP_LIB_NAME "usbpp-${PACKAGE_VERSION}")

include(cmake/disallow_insource_build.cmake)

# Make it possible to locate CMake modules for finding libraries
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Use GNUInstallDirst to get canonical paths
include(GNUInstallDirs)
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


# This makes the project importable from the install directory
# Put config file in per-project dir (name MUST match), can also
# just go into <prefix>/cmake.
install(EXPORT ${PACKAGE_NAME}Config DESTINATION ${CMAKE_INSTALL_DATADIR}/${PACKAGE}/cmake)

# Exporting dependencies towards external packages
set (PKG_CONFIG_REQUIRES libusb-1.0)
set (PKG_CONFIG_LIBDIR
    "\${prefix}/lib"
)
set (PKG_CONFIG_INCLUDEDIR
    "\${prefix}/include/${PACKAGE}"
)
set (PKG_CONFIG_LIBS
    "-L\${libdir} -l${LIBUSBPP_LIB_NAME}"
)
set (PKG_CONFIG_CFLAGS
    "-I\${includedir}"
)

configure_file (
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/pkg-config.pc.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}.pc
)

# Install package configuration file
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE}.pc
         DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)



## Add subdirectories
add_subdirectory (headers)
add_subdirectory (src)
add_subdirectory (examples)
