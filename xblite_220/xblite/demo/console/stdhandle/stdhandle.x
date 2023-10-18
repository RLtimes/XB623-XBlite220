'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo in which one xblite console program
' starts a second console program. The second
' program prints text to the first program's
' console window.
' Run the program stdhandle.exe. Do not
' run the second program printit.exe
' (it will do nothing by itself).
'
PROGRAM	"stdhandle"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	PRINT "Running program stdhandle.exe"
	PRINT "Calling program printit.exe"

  command$ = "printit.exe"
  SHELL (command$)

	a$ = INLINE$ ("Press ENTER to exit >")

END FUNCTION
END PROGRAM
