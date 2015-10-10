# -------------------------------
# Make sure the linker can find the Glint2 library once it is built.
#link_directories (${PROJECT_BINARY_DIR}/slib)

# http://stackoverflow.com/questions/13298504/using-cmake-with-setup-py

message(PYTHON_INCLUDES ${PYTHON_INCLUDES})
message(PYTHON_LIBRARY ${PYTHON_LIBRARY})

include_directories(${PROJECT_SOURCE_DIR}/slib)
include_directories(${PYTHON_INCLUDES})

if (PYTHON_MAJOR_VERSION MATCHES 2)
	ADD_LIBRARY(_fexception MODULE
		fexception_py2.cpp
	)
else()
	ADD_LIBRARY(_fexception MODULE
		fexception_py3.cpp
	)
endif()

#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in ${CMAKE_CURRENT_BINARY_DIR}/setup.py)

set(CFLAGS ${CFLAGS} ${PYTHON_INCLUES})

set_target_properties(_fexception
	PROPERTIES
	PREFIX ""
	SUFFIX ".so"
	OUTPUT fexception.so)

target_link_libraries(_fexception fexception ${PYTHON_LIBRARY})


# Set RPATH in the installed library
# http://www.cmake.org/Wiki/CMake_RPATH_handling
# http://www.kitware.com/blog/home/post/510
set_target_properties(_fexception PROPERTIES
	INSTALL_RPATH_USE_LINK_PATH TRUE)



# NOTE: Some pythons want .../python/site-packages instead of .../python2.7/site-packages
# In this case, create a symbolic link!

message(STATUS "PY_SYSCONFIG_PLATLIB: ${PY_SYSCONFIG_PLATLIB}")
install(TARGETS _fexception DESTINATION ${PY_SYSCONFIG_PLATLIB})

install(FILES
	${CMAKE_CURRENT_SOURCE_DIR}/fexception.py
		DESTINATION ${PY_SYSCONFIG_PURELIB})
