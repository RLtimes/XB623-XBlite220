'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"shelltest"
VERSION	"0.0001"
CONSOLE
IMPORT "xst"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	PRINT "shelltest.exe is now printing some stuff"
	PRINT "to test if Shell() function can capture"
	PRINT "data sent to stdOut. If so, then this text"
	PRINT "is now being read by Shell() and copied to"
	PRINT "the output$. If this works, prepare the"
	PRINT "champagne!"
'  a$ = INLINE$ ("Press Enter to exit >")
END FUNCTION
END PROGRAM
