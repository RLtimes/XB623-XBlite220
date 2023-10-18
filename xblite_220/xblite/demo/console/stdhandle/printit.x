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
PROGRAM	"printit"
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

  PRINT ".....This text is from printit.exe."
	PRINT ".....Ok, now we try to print some text."
	PRINT ".....Another line of text."
	PRINT ".....Last line of text."
	PRINT ".....ciao..."

END FUNCTION
END PROGRAM
