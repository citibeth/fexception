# - Find python executable and libraries.
#
#  PYTHON_EXECUTABLE   - name of the python executable.
#  PYTHON_INCLUDES     - where to find Python.h, etc.
#  PYTHON_FOUND        - True if python is found
#
# http://stackoverflow.com/questions/13298504/using-cmake-with-setup-py

#if(PYTHON_EXECUTABLE AND PYTHON_INCLUDES AND PYTHON_LIBRARY )
#    set(PYTHON_FIND_QUIETLY TRUE)
#endif()

message(PYTHON_EXECUTABLE ${PYTHON_EXECUTABLE})
find_program(PYTHON_EXECUTABLE python DOC "python interpreter")

if(PYTHON_EXECUTABLE)
    execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('include'))"
                     OUTPUT_VARIABLE PYTHON_INCLUDES
                     RESULT_VARIABLE PYTHON_INCLUDES_NOT_FOUND
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_config_var('LIBPL'))"
                     OUTPUT_VARIABLE PYTHON_LIBDIR
                     RESULT_VARIABLE PYTHON_LIBDIR_NOT_FOUND
                     OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_python_version())"
                     OUTPUT_VARIABLE PYTHON_VERSION
                     RESULT_VARIABLE PYTHON_VERSION_NOT_FOUND
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_python_version())"
                     OUTPUT_VARIABLE PYTHON_VERSION
                     RESULT_VARIABLE PYTHON_VERSION_NOT_FOUND
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

    execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sys; print (sys.version_info[0])"
                     OUTPUT_VARIABLE PYTHON_MAJOR_VERSION
                     RESULT_VARIABLE PYTHON_MAJOR_VERSION_NOT_FOUND
                     OUTPUT_STRIP_TRAILING_WHITESPACE)

endif()

if(PYTHON_LIBDIR)
    find_library( PYTHON_LIBRARY "python${PYTHON_VERSION}" HINTS ${PYTHON_LIBDIR} NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_DEFAULT_PATH)
	message("python${PYTHON_VERSION}")
endif()

message("-- Found PYTHON_EXECUTABLE " ${PYTHON_EXECUTABLE})
message("-- Found PYTHON_VERSION " ${PYTHON_VERSION})
message("-- Found PYTHON_MAJOR_VERSION " ${PYTHON_MAJOR_VERSION})
message("-- Found PYTHON_INCLUDES " ${PYTHON_INCLUDES})
message("-- Found PYTHON_LIBDIR " ${PYTHON_LIBDIR})
message("-- Found PYTHON_LIBRARY " ${PYTHON_LIBRARY})


# if(PYTHON_EXECUTABLE)
#   if(NOT PYTHON_FIND_QUIETLY)
#     message( STATUS "Found Python executable: ${PYTHON_EXECUTABLE}")
#   endif()
# else()
#   if(FIND_PYTHON_REQUIRED)
#     message( FATAL_ERROR "Python executable missing")
#   endif()
# endif()
# 
# if(PYTHON_INCLUDES)
#   if(NOT PYTHON_FIND_QUIETLY)
#     message( STATUS "Found Python includes: ${PYTHON_INCLUDES}")
#   endif()
# else()
#   if(FIND_PYTHON_REQUIRED)
#     message( FATAL_ERROR "Python include directory missing")
#   endif()
# endif()
# 
# if(PYTHON_LIBRARY)
#   if(NOT PYTHON_FIND_QUIETLY)
#     message( STATUS "Found Python library: ${PYTHON_LIBRARY}")
#   endif()
# else()
#   if(FIND_PYTHON_REQUIRED)
#     message( FATAL_ERROR "Python library missing")
#   endif()
# endif()

MARK_AS_ADVANCED(PYTHON_EXECUTABLE PYTHON_INCLUDES PYTHON_LIBRARY)

# --------------------------------------------
# Grab paths out of Python's sysconfig module
# https://docs.python.org/2/library/sysconfig.html#module-sysconfig

set(GET_PATH_ARGS "")
if(DEFINED PY_SYSCONFIG_SCHEME)
	set(GET_PATH_ARGS ${GET_PATH_ARGS} ", scheme='${PY_SYSCONFIG_SCHEME}'")
endif()

set(GET_PATH_VARS "'__dummy__' : 17")
if (DEFINED PY_SYSCONFIG_BASE)
	set(GET_PATH_VARS "${GET_PATH_VARS}, 'base' : '${PY_SYSCONFIG_BASE}'")
endif()
if (DEFINED PY_SYSCONFIG_USERBASE)
	set(GET_PATH_VARS "${GET_PATH_VARS}, 'userbase' : '${PY_SYSCONFIG_USERBASE}'")
endif()
set(GET_PATH_ARGS "${GET_PATH_ARGS}, vars={${GET_PATH_VARS}}")


#set(GET_PATH_ARGS "${GET_PATH_ARGS}, expand=False")

message("-- Constructed GET_PATH_ARGS " ${GET_PATH_ARGS})

if(NOT DEFINED PY_SYSCONFIG_STDLIB)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('stdlib' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_STDLIB
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_STDLIB " ${PY_SYSCONFIG_STDLIB})

if(NOT DEFINED PY_SYSCONFIG_PLATSTDLIB)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('platstdlib' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_PLATSTDLIB
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_PLATSTDLIB " ${PY_SYSCONFIG_PLATSTDLIB})

if(NOT DEFINED PY_SYSCONFIG_PLATLIB)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('platlib' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_PLATLIB
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_PLATLIB " ${PY_SYSCONFIG_PLATLIB})

if(NOT DEFINED PY_SYSCONFIG_PURELIB)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('purelib' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_PURELIB
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_PURELIB " ${PY_SYSCONFIG_PURELIB})

if(NOT DEFINED PY_SYSCONFIG_INCLUDE)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('include' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_INCLUDE
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_INCLUDE " ${PY_SYSCONFIG_INCLUDE})

# Docs say this should work but it doesn't
#execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('platinclude' ${GET_PATH_ARGS}))"
#	OUTPUT_VARIABLE PY_SYSCONFIG_PLATINCLUDE
#	RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
#	OUTPUT_STRIP_TRAILING_WHITESPACE)
#endif()
#message("-- Found PY_SYSCONFIG_PLATINCLUDE " ${PY_SYSCONFIG_PLATINCLUDE})

if(NOT DEFINED PY_SYSCONFIG_SCRIPTS)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('scripts' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_SCRIPTS
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_SCRIPTS " ${PY_SYSCONFIG_SCRIPTS})

if(NOT DEFINED PY_SYSCONFIG_DATA)
	execute_process( COMMAND ${PYTHON_EXECUTABLE} -c "import sysconfig; print (sysconfig.get_path('data' ${GET_PATH_ARGS}))"
		OUTPUT_VARIABLE PY_SYSCONFIG_DATA
		RESULT_VARIABLE PY_SYSCONFIG_STLIB_NOT_FOUND
		OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
message("-- Found PY_SYSCONFIG_DATA " ${PY_SYSCONFIG_DATA})



