'
' ####################
' #####  PROLOG  #####
' ####################
'
' Test Fround function in Xma library.
'
PROGRAM "fround"
VERSION "0.0001"
CONSOLE
'
'	IMPORT  "xst"				' Standard library : required by most programs
	IMPORT  "xma"

DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	a# = 12345.6789
	b# = 123456000
	c# = 0.00012345
	FOR p = -8 TO 7
		PRINT Fround(a#, p); TAB (13); Fround(b#, p); TAB(26); Fround(c#, p)
	NEXT p
	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

END PROGRAM