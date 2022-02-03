# Make sure the user doesn't play dirty with symlinks
get_filename_component (srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
get_filename_component (bindir "${CMAKE_BINARY_DIR}" REALPATH)

# Disallow in-source builds
if (${srcdir} STREQUAL ${bindir})
    message(FATAL_ERROR "In-source builds are not allowed. "
            "Please create a directory and run cmake from there, passing the path "
            "to this source directory as the last argument. This process created "
            "the file `CMakeCache.txt' and the directory `CMakeFiles' in ${srcdir}. "
            "Please remove them.")
endif (${srcdir} STREQUAL ${bindir})