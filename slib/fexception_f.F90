MODULE c_f_string_ptr
  IMPLICIT NONE
  PRIVATE
  PUBLIC :: C_F_STRING
CONTAINS
  FUNCTION C_F_STRING(c_str) RESULT(f_str)
    USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_F_POINTER, C_CHAR
    TYPE(C_PTR), INTENT(IN) :: c_str
    CHARACTER(:,KIND=C_CHAR), POINTER :: f_str
    CHARACTER(KIND=C_CHAR), POINTER :: arr(:)
    INTERFACE
      ! Steal std C library function rather than writing our own.
      FUNCTION strlen(s) BIND(C, NAME='strlen')
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_SIZE_T
        IMPLICIT NONE
        !----
        TYPE(C_PTR), INTENT(IN), VALUE :: s
        INTEGER(C_SIZE_T) :: strlen
      END FUNCTION strlen
    END INTERFACE
    !****
    CALL C_F_POINTER(c_str, arr, [strlen(c_str)])
    CALL get_scalar_pointer(SIZE(arr), arr, f_str)
  END FUNCTION C_F_STRING
  SUBROUTINE get_scalar_pointer(scalar_len, scalar, ptr)
    USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_CHAR
    INTEGER, INTENT(IN) :: scalar_len
    CHARACTER(KIND=C_CHAR,LEN=scalar_len), INTENT(IN), TARGET :: scalar(1)
    CHARACTER(:,KIND=C_CHAR), INTENT(OUT), POINTER :: ptr
    !***
    ptr => scalar(1)
  END SUBROUTINE get_scalar_pointer
END MODULE c_f_string_ptr





module fexception_mod

use iso_c_binding

type, bind(C) :: FException
	type(c_ptr) :: c_msg
	integer(c_int) :: msg_len
	integer(c_int) :: code
end type FException



abstract interface
	! Callback used to communicate a constant out of ModelE
	subroutine void_cb(api) bind(c)
		use iso_c_binding
		type(c_ptr), value :: api
	end subroutine
end interface


interface
	function fexception_try(fn, api) bind(c)
		use iso_c_binding
		type(c_funptr), value :: fn
		type(c_ptr), value :: api
		type(c_ptr) :: fexception_try
	end function fexception_try

	subroutine fexception_throw(msg, msg_len, code) bind(c)
		use iso_c_binding
		type(c_ptr), value :: msg
		integer(c_int), value :: msg_len
		integer(c_int), value :: code
	end subroutine fexception_throw

	subroutine rethrow() bind(c, name='fexception_rethrow')
	end subroutine rethrow

end interface

contains

function try(fn, api, exception)
	type(c_funptr), value :: fn
	type(c_ptr), value :: api
	logical :: try
	type(FException), pointer :: exception

	type(c_ptr) :: cexp

	cexp = fexception_try(fn, api)
	call c_f_pointer(cexp, exception)
	try = associated(exception)
end function try


subroutine throw(msg, code)
	character(kind=c_char,len=*), target, intent(in) :: msg
	integer, intent(in) :: code

	integer(c_int) :: c_code

	c_code = code
	call fexception_throw(c_loc(msg), len(msg), c_code)
end subroutine throw


end module fexception_mod


