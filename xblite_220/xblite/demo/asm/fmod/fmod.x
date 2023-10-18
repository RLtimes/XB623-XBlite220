'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Floating point modulus functions for 
' DOUBLE and LONGDOUBLE types.
'
PROGRAM	"fmod"
VERSION	"0.0002"	' modified 16 Oct 05 for goasm
CONSOLE

IMPORT "xst"   		' Standard library : required by most programs
IMPORT "xma"      ' xma now contains Fmod() function

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  LONGDOUBLE FmodL (LONGDOUBLE num1, LONGDOUBLE num2)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	DOUBLE x, y
	LONGDOUBLE xld, yld

' test DOUBLE Fmod
	PRINT " ##### Fmod #####"
	
	a# = Fmod (11#, 5#)
	PRINT "a#="; a#
	
	a# = Fmod (25.1111#, 5#)
	PRINT "a#="; a#
	
	x = 100.12345
	y = 10.0
	PRINT Fmod (x, y)
	
	x = 12345.12345
	y = 10.0
	PRINT Fmod (x, y)
	
' test LONGDOUBLE FmodL
	PRINT
	PRINT " ##### FmodL #####"
	
	a## = FmodL (11##, 5##)
	PRINT "a##="; a##
	
	a## = FmodL (25.1111##, 5##)
	PRINT "a##="; a##
	
	xld = 100.12345##
	yld = 10.0##
	PRINT FmodL (xld, yld)
	
	xld = 12345.12345##
	yld = 10.0##
	PRINT FmodL (xld, yld)
	
	PRINT
	a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
'
'
' ######################
' #####  FmodL ()  #####
' ######################
'
' Floating point modulus function.
'
FUNCTION  LONGDOUBLE FmodL (LONGDOUBLE num1, LONGDOUBLE num2)

ASM finit
ASM fld     t[ebp+20]  					; st0 = num2
ASM fld     t[ebp+8]  					; st1 = num2, st0 = num1

ASM Lfmod:
ASM	fprem												; partial remainder
ASM	fstsw 	ax 									; store status word in ax
ASM fwait
ASM	sahf  											; copy the condition bits in the CPU's flag register
ASM	jp 			Lfmod
ASM	fstp 		st1
ASM	jmp			end.FmodL.fmod			; return with modulus in st(0)

END FUNCTION
END PROGRAM
