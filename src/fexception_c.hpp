#include <string>

struct FException {
	char const *msg;
	int msg_len;
	int code;
	std::string _msg;

	FException() : msg(0), msg_len(0), code(0) {}
	void assign(char const *msg, int msg_len, int code) {
		if (msg_len < 0) {
			this->_msg.assign(msg);
		} else {
			this->_msg.assign(msg, msg_len);
		}
		this->msg = this->_msg.c_str();
		this->msg_len = this->_msg.size();
		this->code = code;
	}
};

extern "C"
FException const *fexception_try(void (*fn)(void *), void *arg);

extern "C"
void fexception_throw(char const *msg, int msg_len, int code) throw(FException *);

extern "C"
void fexception_rethrow();
