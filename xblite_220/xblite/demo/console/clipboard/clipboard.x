'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program pastes and copies text
' to and from the windows clipboard using
' XstSetClipboard and XstGetClipboard.
'
PROGRAM	"clipboard"
VERSION	"0.0002"
CONSOLE
'
IMPORT	"xst"
IMPORT  "xsx"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	UBYTE image[]
	DIM image[]

	text$ = "On saturday the fog was as dense as cotton waste,\ncarried a coldness that ate into the bones.\nThe children like a row of hens in the backseat."

	XstSetClipboard (1, text$, @image[])		' cliptype 1 is for text
	XstGetClipboard (1, @clip$, @image[])

	PRINT "Returned clipboard text:"
	PRINT
	PRINT clip$
	PRINT

	a$ = INLINE$("Press ENTER to exit >")

END FUNCTION
END PROGRAM
