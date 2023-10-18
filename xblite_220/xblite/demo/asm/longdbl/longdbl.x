'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This example uses the fpu instruction fldpi
' to return the value of pi from a function.
'
PROGRAM	"longdbl"
VERSION	"0.0002"	' modified 16 Oct 05 for goasm
CONSOLE

	IMPORT	"xst"   ' Standard library : required by most programs

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  LONGDOUBLE PiL ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	LONGDOUBLE pi

	type = TYPE (pi)
	PRINT "pi:  type ="; type

	size = SIZE (pi)
	PRINT "pi:  size ="; size

' get long double value for pi
	pi = PiL ()
	PRINT "pi: value ="; pi

	PRINT
	a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
'
'
' ####################
' #####  PiL ()  #####
' ####################
'
FUNCTION  LONGDOUBLE PiL ()

' example of loading a 80-bit extended precision real
' and returning it as a LONGDOUBLE

ASM		fldpi												; load pi into st(0)
ASM		jmp			end.PiL.longdbl		  ; return with pi in st(0)

END FUNCTION

END PROGRAM
