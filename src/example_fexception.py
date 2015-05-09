import fexception

def fn():
	fexception.fthrow('Seventeen Reached', 17)
#fexception.execute(fexception.throw_exception)

fexception.fexec(fn)	# Converts fexceptions to Python exceptions

