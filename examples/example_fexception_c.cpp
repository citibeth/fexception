#include <fexception_c.hpp>

struct Context {
	int val;
};
void sample_fn(void *vapi) throw(FException *)
{
	Context *api = (Context *)vapi;
	if (api->val == 17) {
		fexception_throw((char *)"Seventeen detected", -1, 17);
	} else {
		printf("Running sample_fn %d\n", api->val);
		Context napi;
		napi.val = api->val + 1;
		if (fexception_try(sample_fn, &napi)) {
			fexception_rethrow();
		}
	}
}

void myunexpected() {
  printf("unexpected() was called, continuing...\n");
}

int main(int argc, char **argv)
{
	Context api;

#if 0
	try{
		api.val = 5;
		sample_fn(&api);
		api.val = 17;
		sample_fn(&api);
	} catch(FException *e) {
		std::cout << "Caught C++ exception: " << e->msg << std::endl;
	}
#endif

	FException const *exp;
	api.val = 5;
	if ((exp = fexception_try(sample_fn, &api))) {
		printf("fexception_try threw 1: %d, %s\n", exp->code, exp->msg);
	}
	api.val = 17;
	if ((exp = fexception_try(sample_fn, &api))) {
		printf("fexception_try threw 2: %d %s\n", exp->code, exp->msg);
	}

#if 0
	try{
		api.val = 17;
		sample_fn(&api);
	} catch(FException *e) {
		std::cout << "Caught C++ exception: " << e->msg << std::endl;
	}
#endif


}
