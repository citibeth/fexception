cmake_minimum_required(VERSION 3.1)
enable_language(Fortran)

list (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include (setup_rpath)

# ------- Process Configure Options
if (NOT DEFINED THREAD_SAFE)
	set(THREAD_SAFE NO)
endif()

if(${THREAD_SAFE})
	# This will require boost::thread
	add_definitions(-DTHREAD_SAFE)
#	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DTHREAD_SAFE")
endif()



# -------- Locate External Libraries
find_package(Python REQUIRED)
if(${THREAD_SAFE})
	find_package(Boost COMPONENTS thread)
endif()


# -------- Process subdirectories of the build
add_subdirectory(slib)
add_subdirectory(pyext)
add_subdirectory(examples)
