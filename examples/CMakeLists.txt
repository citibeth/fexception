
include_directories(
	${CMAKE_SOURCE_DIR}/slib
	${CMAKE_BINARY_DIR}/slib
)

add_executable (example_fexception_c example_fexception_c.cpp)
target_link_libraries(example_fexception_c fexception)

add_executable (example_fexception_f example_fexception_f.F90)
target_link_libraries(example_fexception_f fexception)
