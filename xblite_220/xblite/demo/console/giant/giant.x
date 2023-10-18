'
' ####################
' #####  PROLOG  #####
' ####################
'
' Return a giant value from a function.
'
PROGRAM "giant"
VERSION "0.0001"
CONSOLE
'
IMPORT  "xst"	

DECLARE FUNCTION Entry ()
DECLARE FUNCTION ReturnIt$$ (num$$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	GIANT x$$, y$$

	x$$ = 100000000000000

	y$$ = ReturnIt$$ (x$$)
	? y$$

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION ReturnIt$$ (num$$)

	a$ = "testing"

	RETURN (num$$)

END FUNCTION


END PROGRAM