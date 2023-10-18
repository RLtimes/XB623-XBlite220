'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Test functions within ieelib.dll, the
' Cephes extended precision math library
' by Stephen L. Moshier.
'
PROGRAM	"ieelibtest"
VERSION	"0.0001"
CONSOLE

	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"ieelib"
	
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	LONGDOUBLE ld
	IEEX e, x, y, z
	
' convert ascii to long double, then display it
	s$ = "12345.12345
 	asctoe64(&s$, &ld)
 	str$ = NULL$ (32)
 	e64toasc(&ld, &str$, 16)
 	str$ = CSIZE$ (str$)
 	PRINT str$
 	
 	s$ = "-12345.12345e+500
 	asctoe64(&s$, &ld)
 	str$ = NULL$ (32)
 	e64toasc(&ld, &str$, 16)
 	str$ = CSIZE$ (str$)
 	PRINT str$
 	
 	s$ = "12345678.12345678e-10
 	asctoe64(&s$, &ld)
 	str$ = NULL$ (32)
 	e64toasc(&ld, &str$, 16)
 	str$ = CSIZE$ (str$)
 	PRINT str$

 	s$ = "12345.123456789012345"
 	asctoe(&s$, &e)
 	etoe64(&e, &ld)
 	str$ = NULL$ (32)
 	e64toasc(&ld, &str$, 20)
 	str$ = CSIZE$ (str$)
 	PRINT str$
 	
' use internal format to mulitply
 	emul (&e, &e, &e)
 	etoe64(&e, &ld)
 	str$ = NULL$ (32)
 	e64toasc(&ld, &str$, 20)
 	str$ = CSIZE$ (str$)
 	PRINT str$
 	
' use internal format power function
 	s$ = "10"
 	asctoe(&s$, &x)
 	s$ = "5.123456789"
 	asctoe(&s$, &y)
 	epow (&x, &y, &z)
 	str$ = NULL$ (32)
 	etoasc(&z, &str$, 16)
 	str$ = CSIZE$ (str$)
 	PRINT str$

' use internal format sqrt function
 	s$ = "2"
 	asctoe(&s$, &x)
 	esqrt (&x, &y)
 	str$ = NULL$ (32)
 	etoasc(&y, &str$, 16)
 	str$ = CSIZE$ (str$)
 	PRINT str$
 	
' use internal format to negate value
 	eneg (&y)
 	str$ = NULL$ (32)
 	etoasc(&y, &str$, 16)
 	str$ = CSIZE$ (str$)
 	PRINT str$

	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM
