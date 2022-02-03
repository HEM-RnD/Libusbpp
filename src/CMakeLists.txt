#
# src/CMakeLists.txt
#

# Require libusb-1.0
if (WIN32)
    include(../cmake/get_cpm.cmake)
    CPMAddPackage(
            NAME LibUSB-1.0
            VERSION 1.0.25
            URL "https://github.com/libusb/libusb/releases/download/v1.0.25/libusb-1.0.25.7z")
    if (LibUSB-1.0_ADDED)
        set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${LibUSB-1.0_SOURCE_DIR}")
        set(LibUSB-1.0_FOUND TRUE)
        set(LibUSB-1.0_INCLUDE_DIR ${LibUSB-1.0_SOURCE_DIR}/include/libusb-1.0/)
        set(LibUSB-1.0_LIBRARIES libusb-1.0)
        if (CMAKE_SIZEOF_VOID_P GREATER 4)
            set(LibUSB-1.0_LIBRARIES_DIRS "${LibUSB-1.0_SOURCE_DIR}/MinGW64/dll/;${LibUSB-1.0_SOURCE_DIR}/MinGW64/static/")
            file(COPY ${LibUSB-1.0_SOURCE_DIR}/MinGW64/dll/libusb-1.0.dll
                    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
        else ()
            file(COPY ${LibUSB-1.0_SOURCE_DIR}/MinGW32/dll/libusb-1.0.dll
                    DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
            set(LibUSB-1.0_LIBRARIES_DIRS "${LibUSB-1.0_SOURCE_DIR}/MinGW32/dll/;${LibUSB-1.0_SOURCE_DIR}/MinGW32/static/")
        endif ()
    endif ()
else ()
    find_package(LibUSB-1.0 REQUIRED)
endif ()

if (LibUSB-1.0_FOUND)
    include_directories(${LibUSB-1.0_INCLUDE_DIR})
else (LibUSB-1.0_FOUND)
    message(FATAL_ERROR "LibUSB-1.0 was not found.")
endif (LibUSB-1.0_FOUND)

# On Windows do not prefix the DLLs with the 'lib' prefix
if (WIN32)
    set(LIB_PREFIX "")
else (WIN32)
    set(LIB_PREFIX "lib")
endif (WIN32)

# Create position independent code on all targets [auto]
# (needed for static build on non-x86):
#set (CMAKE_POSITION_INDEPENDENT_CODE on)

# Collect all library source files
set(libusbppsrc
        Configuration.cpp
        ConfigurationImpl.cpp
        ConfigurationImpl.hpp
        Device.cpp
        DeviceImpl.cpp
        DeviceImpl.hpp
        Endpoint.cpp
        EndpointImpl.cpp
        EndpointImpl.hpp
        Exception.cpp
        Interface.cpp
        InterfaceImpl.cpp
        InterfaceImpl.hpp
        LibusbImpl.cpp
        LibusbImpl.hpp
        libusbpp.cpp
        Transfer.cpp
        TransferImpl.cpp
        TransferImpl.hpp
        Wideconvert.cpp
        Wideconvert.hpp
        )

# Check if all sources were catched
message(STATUS "Searching for uncatched library sources...")
file(GLOB allsrc RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
        *.hpp
        *.cpp
        )
foreach (_src ${allsrc})
    list(FIND libusbppsrc ${_src} matchidx)
    if (${matchidx} EQUAL -1)
        message(AUTHOR_WARNING "  ${_src}")
    endif ()
endforeach ()

# This is the "object library" target:
# - compiles the sources only once
# - shared libraries need PIC
add_library(objlibusbpp OBJECT ${libusbppsrc})
target_link_directories(objlibusbpp PUBLIC ${LibUSB-1.0_LIBRARIES_DIRS})
set_property(TARGET objlibusbpp PROPERTY POSITION_INDEPENDENT_CODE on)
set_property(TARGET objlibusbpp PROPERTY CXX_STANDARD 14)

# Define headers for this library. PUBLIC headers are used for
# compiling the library, and will be added to consumers' build
# paths.
target_include_directories(objlibusbpp
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../headers
        PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Actual shared and static libraries built from the same object files
add_library(sharedlibusbpp SHARED $<TARGET_OBJECTS:objlibusbpp>)
target_include_directories(sharedlibusbpp
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../headers>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

target_link_libraries(sharedlibusbpp ${LibUSB-1.0_LIBRARIES})
target_link_directories(sharedlibusbpp PUBLIC ${LibUSB-1.0_LIBRARIES_DIRS})
set_target_properties(sharedlibusbpp
        PROPERTIES OUTPUT_NAME "${LIBUSBPP_LIB_NAME}"
        PREFIX "${LIB_PREFIX}"
        IMPORT_PREFIX "${LIB_PREFIX}"
        VERSION "${LIBUSBPP_LIB_VERSION}"
        SOVERSION "${LIBUSBPP_LIB_SOVERSION}")

add_library(staticlibusbpp STATIC $<TARGET_OBJECTS:objlibusbpp>)
set_target_properties(staticlibusbpp
        PROPERTIES OUTPUT_NAME "${LIBUSBPP_LIB_NAME}"
        PREFIX "${LIB_PREFIX}"
        IMPORT_PREFIX "${LIB_PREFIX}")
target_include_directories(staticlibusbpp
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../headers>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

# Install shared and static libraries
install(TARGETS sharedlibusbpp staticlibusbpp EXPORT ${PACKAGE_NAME}Config
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})  # This is for Windows

# This makes the project importable from the build directory
export(TARGETS sharedlibusbpp staticlibusbpp FILE ${PACKAGE_NAME}Config.cmake)
