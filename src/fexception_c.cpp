#include <exception>
#include <stdexcept>
#include <cstdio>
#include <iostream>
#include <csetjmp>
#include <string>
#include <vector>
#include <memory>
#include <boost/thread/tss.hpp>

#include "fexception_c.hpp"

// Why my first attempte was not working...
// http://stackoverflow.com/questions/1762535/terminate-called-after-throwing-an-instance-of-pocosystemexception

// TODO: Make this thread-safe using thread-local storage
// http://stackoverflow.com/questions/6021273/how-to-allocate-thread-local-storage


// Make this all thread-safe
struct FExceptionThread {
	/** Throw this when no jmps have been set. */
	FException exception;

	std::vector<jmp_buf *> jmp_bufs;
};

#ifdef THREAD_SAFE
	static boost::thread_specific_ptr<FExceptionThread> thread;
#else
	static FExceptionThread _thread;
	static FExceptionThread *thread = &_thread;
#endif

/** Executes the fn while trapping for exceptions */
extern "C"
FException const *fexception_try(void (*fn)(void *), void *arg)
{
#ifdef THREAD_SAFE
	if (!thread.get()) thread.reset(new FExceptionThread());
#endif

	jmp_buf buf;
	thread->jmp_bufs.push_back(&buf);
//printf("push jmp_bufs = %ld\n", thread->jmp_bufs.size());
	int code = setjmp(buf);
	if (!code) {
		// First time through
		fn(arg);
		thread->jmp_bufs.pop_back();
//printf("pop1 jmp_bufs = %ld\n", thread->jmp_bufs.size());
		return NULL;
	} else {
		// A longjmp() was called
		thread->jmp_bufs.pop_back();
//printf("pop2 jmp_bufs = %ld\n", thread->jmp_bufs.size());
		return &thread->exception;		// Function ran with exceptions
	}
}

extern "C"
void fexception_throw(char const *msg, int msg_len, int code) throw(FException *)
{
#ifdef THREAD_SAFE
	if (!thread.get()) thread.reset(new FExceptionThread());
#endif
	printf("fexception_throw called\n");

	thread->exception.assign(msg, msg_len, code);

	if (thread->jmp_bufs.size() > 0) {
		// longjmp() back to our setjmp()
		jmp_buf *top_buf(thread->jmp_bufs.back());
		longjmp(*top_buf, 1);
	} else {
		// No setjmp() called, just throw a C++ exception
		// and hope for the best.
		throw &thread->exception;
	}
}

void fexception_throw(std::string const &msg, int code) throw(FException *)
	{ fexception_throw(msg.c_str(), -1, code); }

extern "C"
void fexception_rethrow()
{
#ifdef THREAD_SAFE
	if (!thread.get()) thread.reset(new FExceptionThread());
#endif

	if (thread->jmp_bufs.size() > 0) {
		// longjmp() back to our setjmp()
		jmp_buf *top_buf(thread->jmp_bufs.back());
		longjmp(*top_buf, 1);
	} else {
		throw std::exception();		// We have a problem
	}

}


// ====================================================
#if 0
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
#endif
