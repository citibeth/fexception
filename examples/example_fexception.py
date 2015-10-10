from fexception import *


def sample_fn(val):
	if val == 17:
		fthrow('Seventeen detected', 17)
	else:
		print('Running sample_fn {}'.format(val))

		try:
			fexec(lambda: sample_fn(val+1))
		except Exception as e:
			frethrow()


try:
	fexec(lambda: sample_fn(5))
except Exception as e:
	print(e)

e = ftry(lambda: sample_fn(17))
if e:
	print(e)

if ftry(lambda: sample_fn(17)):
	print('FException caught')
