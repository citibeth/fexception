
include_directories(
	${Boost_INCLUDE_DIRS}
)

set(fexception_SOURCES
	fexception_c.cpp
	fexception_f.F90)

add_library(fexception SHARED ${fexception_SOURCES})

if(${THREAD_SAFE})
	target_link_libraries(fexception ${Boost_LIBRARIES})
endif()

install(TARGETS fexception DESTINATION lib)
install (FILES
	${CMAKE_CURRENT_SOURCE_DIR}/fexception_c.hpp
	${CMAKE_CURRENT_BINARY_DIR}/fexception_mod.mod
         DESTINATION include)
