'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A test program to compare Xma math functions
' with their counterparts in msvcrt.dll.
'
PROGRAM	"xmatest"
VERSION	"0.0001"
CONSOLE
'
'	IMPORT	"xma"   	' Math library     : SIN/ASIN/SINH/ASINH/LOG/EXP/SQRT...
'	IMPORT	"xst"   	' Standard library : required by most programs
'	IMPORT  "msvcrt"
'	IMPORT	"xio"
	
IMPORT "xma_s.lib"
IMPORT "xst_s.lib"
IMPORT "xio_s.lib"
IMPORT "msvcrt"

DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 300)
	XioCloseStdHandle (hStdOut)

	PRINT "***** Compare Xma vs msvcrt Math Functions *****"
	PRINT

	tests = 9

	FOR i = 1 TO tests
		FOR v# = 0.01# TO 2# STEP 0.125#
			SELECT CASE i
				CASE 1 : test$ = "Sin Test"		:	GOSUB TestSin
				CASE 2 : test$ = "Sinh Test"	:	GOSUB TestSinh
				CASE 3 : test$ = "Cos Test"		:	GOSUB TestCos
				CASE 4 : test$ = "Cosh Test"	:	GOSUB TestCosh
				CASE 5 : test$ = "Tan Test"		:	GOSUB TestTan
				CASE 6 : test$ = "Tanh Test"	:	GOSUB TestTanh
				CASE 7 : test$ = "Asin Test"	:	GOSUB TestAsin
				CASE 8 : test$ = "Acos Test"	:	GOSUB TestAcos
				CASE 9 : test$ = "Atan Test"	:	GOSUB TestAtan
			END SELECT
			IFZ flag THEN
				PRINT " ***** " + test$ + " *****"
				flag = $$TRUE
			END IF
			GOSUB Print
		NEXT v#
		PRINT
		flag = $$FALSE
	NEXT i

	PRINT
	tests = 5

	FOR i = 1 TO tests
		FOR v# = 40.0# TO 400.0# STEP 40.0#
			SELECT CASE i
				CASE 1 : test$ = "Exp Test"		:	GOSUB TestExp
				CASE 2 : test$ = "Log Test"		:	GOSUB TestLog
				CASE 3 : test$ = "Log10 Test"	:	GOSUB TestLog10
				CASE 4 : test$ = "Power Test"	:	GOSUB TestPower
				CASE 5 : test$ = "Sqrt Test"	:	GOSUB TestSqrt
			END SELECT
			IFZ flag THEN
				PRINT " ***** " + test$ + " *****"
				flag = $$TRUE
			END IF
			GOSUB Print
		NEXT v#
		PRINT
		flag = $$FALSE
	NEXT i

	a$ = INLINE$ ("Press ENTER to quit >")
	RETURN


' ***** Print *****
SUB Print
	PRINT FORMAT$ ("###.##############", x#);;; FORMAT$ ("###.##############", c#)
END SUB

' ***** TestSin *****
SUB TestSin
	x# = Sin (v#)
	c# = sin (v#)
END SUB

' ***** TestSinh *****
SUB TestSinh
	x# = Sinh (v#)
	c# = sinh (v#)
END SUB

' ***** TestCos *****
SUB TestCos
	x# = Cos (v#)
	c# = cos (v#)
END SUB

' ***** TestCosh *****
SUB TestCosh
	x# = Cosh (v#)
	c# = cosh (v#)
END SUB

' ***** TestTan *****
SUB TestTan
	x# = Tan (v#)
	c# = tan (v#)
END SUB

' ***** TestTanh *****
SUB TestTanh
	x# = Tanh (v#)
	c# = tanh (v#)
END SUB

' ***** TestAsin *****
SUB TestAsin
	x# = Asin (v#)
	c# = asin (v#)
END SUB

' ***** TestAcos *****
SUB TestAcos
	x# = Acos (v#)
	c# = acos (v#)
END SUB

' ***** TestAtan *****
SUB TestAtan
	x# = Atan (v#)
	c# = atan (v#)
END SUB

' ***** TestExp *****
SUB TestExp
	e# = v#/100.0#
	x# = Exp (e#)
	c# = exp (e#)
END SUB

' ***** TestLog *****
SUB TestLog
	x# = Log (v#)
	c# = log (v#)
END SUB

' ***** TestLog10 *****
SUB TestLog10
	x# = Log10 (v#)
	c# = log10 (v#)
END SUB

' ***** TestSqrt *****
SUB TestSqrt
	x# = Sqrt (v#)
	c# = sqrt (v#)
END SUB

' ***** TestPower *****
SUB TestPower
	x# = Power (v#, 0.5)
	c# = pow (v#, 0.5)
END SUB

END FUNCTION
END PROGRAM
