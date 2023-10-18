'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Import a dll function library as an object file.
'
PROGRAM	"testdll"
VERSION	"0.0002"
CONSOLE
'
'	IMPORT	"xst"   			' Standard library  : required by most programs
	IMPORT  "mydll.obj"
'	IMPORT  "mydll"
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' call functions in mydll.dll

	PRINT "Calling PrintSomething ()"
	PrintSomething ()

	PRINT
	PRINT "Calling DoNothing ()"
	DoNothing ()

	PRINT
	a$ = INLINE$ ("Press ENTER to exit >")

END FUNCTION
END PROGRAM
