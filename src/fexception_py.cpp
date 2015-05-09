#include <Python.h>
#include <cstdio>
#include <exception>


#include "fexception_c.hpp"

// https://docs.python.org/2/c-api/function.html
// http://stackoverflow.com/questions/24492327/python-embedding-in-c-importerror-no-module-named-pyfunction
// https://docs.python.org/2/extending/extending.html


void my_call_obj(void *api)
{
	PyObject *lambda = (PyObject *)api;
	PyObject_CallObject(lambda, (PyObject *)0);
}

PyObject *FException_py;

extern"C"
PyObject *fexception_py_try(PyObject *self, PyObject *args)
{
	PyObject *lambda;

	if (!PyArg_ParseTuple(args, "O", &lambda)) return NULL;
	FException const *exp = fexception_try(my_call_obj, (void *)lambda);
	if (!exp) return self;

	// We had an exception.  Now throw it Python-style
	PyErr_SetString(FException_py, exp->msg);
	return NULL;
}

extern "C"
PyObject *fexception_py_throw(PyObject *self, PyObject *args)
{
	char *msg;
	int code;

	if (!PyArg_ParseTuple(args, "si", &msg, &code)) return NULL;

	printf("BEGIN throw()\n");
	fexception_throw(msg, -1, code);
	printf("END throw()\n");
	return self;
}

extern "C"
PyObject *fexception_py_rethrow(PyObject *self, PyObject *args)
{
	if (!PyArg_ParseTuple(args, "")) return NULL;

	printf("BEGIN rethrow()\n");
	fexception_rethrow();
	printf("END rethrow()\n");
	return self;
}


static PyMethodDef fexceptionMethods[] = {
	{"fexec", fexception_py_try, METH_VARARGS, "Execute a lambda and catch exceptions."},
	{"fthrow", fexception_py_throw, METH_VARARGS, ""},
	{"frethrow", fexception_py_rethrow, METH_VARARGS, ""},
	{NULL, NULL, 0, NULL}
};

extern "C"
PyObject *initfexception(void)
{
	PyObject* mod;
	mod = Py_InitModule3("fexception", fexceptionMethods, "Fortran Exceptions Module");
	FException_py = PyErr_NewException((char *)"fexception.FException", NULL, NULL);
	return mod;
}

