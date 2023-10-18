'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"maytest"
VERSION	"0.0002"
CONSOLE

	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"xio"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  RunMayTest ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, w, 50)
	XioCloseStdHandle (hStdOut)

	PRINT "53-bit precision"
	XstSetFPUPrecision ($$53_BITS)
	RunMayTest ()

	PRINT

	PRINT "64-bit precision"
	XstSetFPUPrecision ($$64_BITS)
	RunMayTest ()
	PRINT

	a$ = INLINE$ ("Press Enter key to quit >")

END FUNCTION
'
'
' ###########################
' #####  RunMayTest ()  #####
' ###########################
'
FUNCTION  RunMayTest ()

	SINGLE f
	DOUBLE d
	LONGDOUBLE ld

  f = 0.5!
  d = 0.5#
	ld = 0.5##
	
	PRINT " k        single       double          longdouble"
	PRINT "===================================================="

	FOR i = 1 TO 100

		f = 3.8! * f * (1.0! - f)
    d = 3.8# * d * (1.0# - d)
		ld = 3.8## * ld * (1.0## - ld)

		width = 14
		f$  = FORMAT$("." + CHR$('#',6), f)
		d$  = FORMAT$("." + CHR$('#',width), d)
		ld$ = FORMAT$("." + CHR$('#',width), DOUBLE(ld)) 

		IF (i MOD 10 == 0) THEN
			PRINT i, TAB(7), f$,, d$,, ld$ 
'			PRINT i, TAB(7), f, d, DOUBLE(ld)
'			PRINT i, TAB(7), f, d, ld
		END IF

	NEXT i

END FUNCTION
END PROGRAM
