'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo to test XstAnsiToUnicode$ and XstUnicodeToAnsi$.
'
PROGRAM "unicode"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"
	IMPORT  "xsx"
	IMPORT  "kernel32"	' kernel32.dll

DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	test$ = "The quick brown fox"
	unic$ = XstAnsiToUnicode$ (test$)
	test2$ = XstUnicodeToAnsi$ (&unic$)
	
	PRINT "test$  = "; test$
	PRINT "test2$ = "; test2$
	
	PRINT "Length test$  ="; LEN(test$)
	PRINT "Length test2$ ="; LEN(test2$)
	PRINT "Length unic$  ="; LEN(unic$)
	PRINT 
	PRINT "Number of chars in unic$ ="; lstrlenW (&unic$)
	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

END PROGRAM