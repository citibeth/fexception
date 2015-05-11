from fexception import *


def sample_fn(val):
	if val == 17:
		fthrow('Seventeen detected', 17)
	else:
		print 'Running sample_fn {}'.format(val)

		try:
			ftry(lambda: sample_fn(val+1))
		except Exception as e:
			frethrow()


try:
	ftry(lambda: sample_fn(5))
except Exception as e:
	print e

try:
	ftry(lambda: sample_fn(17))
except Exception as e:
	print e

