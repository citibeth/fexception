! ==============================================
program fexception_test


type Context
	integer :: val
end type Context

call main()

contains

!recursive subroutine sample_fn_c(vapi) bind(C)
!end subroutine sample_fn_c

recursive subroutine sample_fn(vapi)
	use iso_c_binding
	use fexception_mod
	type(c_ptr), value :: vapi
	type(Context), pointer :: api
	type(Context), target :: napi
	procedure(void_cb), pointer :: my_fn
	type(FException), pointer :: exception

	my_fn => sample_fn
	call c_f_pointer(vapi, api)
	
	if (api%val == 17) then
		call throw('Seventeen Detected', 17)
	else
		print *, 'Running sample_fn', api%val
		napi%val = api%val + 1
		if (try(c_funloc(sample_fn), c_loc(napi), exception)) then
			call rethrow()
		end if
	end if
end subroutine sample_fn

subroutine main()
	use fexception_mod
	use c_f_string_ptr

	type(Context), target :: api
	type(FException), pointer :: exception
	procedure(void_cb), pointer :: my_fn
    CHARACTER(:,KIND=C_CHAR), POINTER :: f_str

	my_fn => sample_fn

	api%val = 5
	if (try(c_funloc(sample_fn), c_loc(api), exception)) then
		f_str = c_f_string(exception%c_msg)
		print *, 'try threw:', exception%code
	end if

	api%val = 17
	if (try(c_funloc(sample_fn), c_loc(api), exception)) then
		f_str = c_f_string(exception%c_msg)
		print *, 'try threw:', exception%code
	end if


end subroutine main


end program

