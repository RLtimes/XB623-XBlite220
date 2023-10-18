'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"fact"
VERSION	"0.0001"
CONSOLE

	IMPORT	"xst"   ' Standard library : required by most programs

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  LONGDOUBLE Fact (n)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' Demo to test LONGDOUBLE values using
' a recursive factorial function.
'
FUNCTION  Entry ()

	LONGDOUBLE xld
	
ASM finit

	n = 2
	xld = 0

	DO
    xld = Fact (n)
    IF IsInfL (xld) THEN
			DEC n
			xld = Fact (n)
			EXIT DO
    END IF
    INC n
	LOOP

	PRINT "Max Factorial: Fact ("; STRING$(n); ")="; xld
	
	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
'
' #####################
' #####  Fact ()  #####
' #####################
'
FUNCTION  LONGDOUBLE Fact (n)
	LONGDOUBLE fact
	SELECT CASE TRUE
		CASE n < 0 : fact = 0
		CASE n = 0 : fact = 1
		CASE ELSE  : fact = Fact(n-1) * n
	END SELECT
	RETURN (fact)

END FUNCTION
END PROGRAM
