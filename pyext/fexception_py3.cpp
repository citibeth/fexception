#include <Python.h>
#include <cstdio>
#include <exception>
#include "fexception_c.hpp"

// https://docs.python.org/2/c-api/function.html
// http://stackoverflow.com/questions/24492327/python-embedding-in-c-importerror-no-module-named-pyfunction
// https://docs.python.org/2/extending/extending.html

// Ported to Python3
// https://docs.python.org/3/howto/cporting.html


struct module_state {
    PyObject *error;
};
#define GETSTATE(m) ((struct module_state*)PyModule_GetState(m))

void my_call_obj(void *api)
{
	PyObject *lambda = (PyObject *)api;
	PyObject_CallObject(lambda, (PyObject *)0);
}

// Python objects created alongside our module
PyObject *FException_py;
PyObject *PyTrue;
PyObject *PyFalse;

extern"C"
PyObject *fexception_py_try(PyObject *self, PyObject *args)
{
	PyObject *lambda;

	if (!PyArg_ParseTuple(args, "O", &lambda)) return NULL;
	FException const *exp = fexception_try(my_call_obj, (void *)lambda);
	if (exp) {
		// We had an exception, return it to the user.

		// Instantiate the object to return (of type FException_py)
		PyObject *arg_list = Py_BuildValue("si", exp->msg, exp->code);
		PyObject *pyexp = PyObject_CallObject(FException_py, arg_list);
		Py_DECREF(arg_list);		// Release the argument list

		return pyexp;
	} else return Py_None;

	return FException_py;
}

extern"C"
PyObject *fexception_py_exec(PyObject *self, PyObject *args)
{
	PyObject *lambda;

	if (!PyArg_ParseTuple(args, "O", &lambda)) return NULL;
	FException const *exp = fexception_try(my_call_obj, (void *)lambda);
	if (!exp) return Py_None;

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

//	printf("BEGIN throw()\n");
	fexception_throw(msg, -1, code);
//	printf("END throw()\n");
	return Py_None;
}

extern "C"
PyObject *fexception_py_rethrow(PyObject *self, PyObject *args)
{
	if (!PyArg_ParseTuple(args, "")) return NULL;

//	printf("BEGIN rethrow()\n");
	fexception_rethrow();
//	printf("END rethrow()\n");
	return Py_None;
}

// -----------------------------------------------------------
static PyMethodDef fexceptionMethods[] = {
	{"ftry", fexception_py_try, METH_VARARGS, "Execute a lambda and return any FExceptions to the user."},
	{"fexec", fexception_py_exec, METH_VARARGS, "Execute a lambda and re-throw any FExceptions."},
	{"fthrow", fexception_py_throw, METH_VARARGS, ""},
	{"frethrow", fexception_py_rethrow, METH_VARARGS, ""},
	{NULL, NULL, 0, NULL}
};

static int fexceptionTraverse(PyObject *m, visitproc visit, void *arg) {
    Py_VISIT(GETSTATE(m)->error);
    return 0;
}

static int fexceptionClear(PyObject *m) {
    Py_CLEAR(GETSTATE(m)->error);
    return 0;
}

static PyModuleDef fexceptionModuleDef = {
	PyModuleDef_HEAD_INIT,
	"_fexception",
	NULL,
	sizeof(struct module_state),
	fexceptionMethods,
	NULL,
	fexceptionTraverse,
	fexceptionClear,
	NULL
};
// -----------------------------------------------------------


extern "C"
PyObject *PyInit__fexception(void)
{
	// Py_InitModule3("_fexception", fexceptionMethods, "Fortran Exceptions Module");
	PyObject *mod = PyModule_Create(&fexceptionModuleDef);
	FException_py = PyErr_NewException((char *)"_fexception.FException", NULL, NULL);
	PyTrue = Py_BuildValue("b", true);
	PyFalse = Py_BuildValue("b", false);
	return mod;
}

