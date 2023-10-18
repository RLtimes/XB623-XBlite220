'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Create a test function library to be used
' with testdll.x. 
'
PROGRAM	"mydll"
VERSION	"0.0003"
CONSOLE
IMPORT "xst"

'
DECLARE FUNCTION  MyDll ()
EXPORT
DECLARE FUNCTION  PrintSomething ()
DECLARE FUNCTION  DoNothing ()
END EXPORT
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  MyDll ()

IF LIBRARY(0) THEN RETURN

END FUNCTION
'
'
' ###############################
' #####  PrintSomething ()  #####
' ###############################
'
FUNCTION  PrintSomething ()

	PRINT "Function PrintSomething(), ok..."

END FUNCTION
'
'
' ##########################
' #####  DoNothing ()  #####
' ##########################
'
FUNCTION  DoNothing ()

	PRINT "DoNothing () : This function does nothing"

END FUNCTION
END PROGRAM
