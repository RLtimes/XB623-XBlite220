
' test m4 macro program

PROGRAM "m4test"
VERSION "0.0001"
CONSOLE

	IMPORT  "xst"				' Standard library : required by most programs
	IMPORT  "msvcrt"		' msvcrt.dll

DECLARE FUNCTION Entry ()

m4_include(`include.inc')
m4_include(`include2.inc')
m4_define(`cuberoot',`(sqrt($1*$1 + $2*$2 + $3*$3))')

' ######################
' #####  Entry ()  #####
' ######################

FUNCTION Entry ()
	DOUBLE x
	NEWTYPE nt

	x = cuberoot(7, 8, 9)
	
	PRINT "x="; x
	
	TestFunc ()
	
	Foo ()
	
	PRINT "$$MYCONSTANT="; $$MYCONSTANT
	
	nt.ok = 1
	nt.okdokey = 100
	PRINT "nt.ok="; nt.ok, " nt.okdokey="; nt.okdokey
	
	FooFoo ()
	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM