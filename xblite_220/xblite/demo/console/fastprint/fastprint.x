'
' ####################
' #####  PROLOG  #####
' ####################
'
' Print text to the console.
'
PROGRAM "fastprint"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
'	IMPORT  "xio"				' Console input/ouput library
	IMPORT	"gdi32"			' gdi32.dll
	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION FastPrint (row, col, fgc, bgc, text$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

 a$ = " The FastPrint routine is very -QUICK- at displaying text on the screen "

	FOR i = 0 TO 15
		FastPrint (i+4, 2, i, 0 , a$)
	NEXT

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION FastPrint (row, col, fgc, bgc, text$)

	coord = MAKELONG (col-1, row-1) ' zero based indexing
	hOut = GetStdHandle ($$STD_OUTPUT_HANDLE)
	junk = 0
	WriteConsoleOutputCharacterA (hOut, &text$, LEN(text$), coord, &junk)
	FillConsoleOutputAttribute (hOut, fgc+bgc*16, LEN(text$), coord, &junk)

END FUNCTION
END PROGRAM