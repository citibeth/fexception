example_fexception : fexception_f.o fexception_c.o
	gfortran -o example_fexception fexception_f.o fexception_c.o -L$(HOME)/macports/lib -lboost_thread-mt -lstdc++

fexception_c.o : fexception_c.cpp
	g++ -c fexception_c.cpp

fexception_f.o : fexception_f.F90
	gfortran -c fexception_f.F90


fexception_py.o : fexception_py.cpp
	g++ -fno-strict-aliasing -fno-common -dynamic -pipe -Os -fwrapv -DNDEBUG -g -fwrapv -O3 -Wall -Wstrict-prototypes -I/Users/rpfische/macports/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7 -c fexception_py.cpp

fexception.so : fexception_py.o
	g++ -bundle -undefined dynamic_lookup -L/Users/rpfische/macports/lib -Wl,-headerpad_max_install_names -L/Users/rpfische/macports/lib/db48 fexception_py.o fexception_c.o /Users/rpfische/git/modelE/build/model/libmodele.dylib -o fexception.so
