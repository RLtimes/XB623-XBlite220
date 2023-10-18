'
' ####################
' #####  PROLOG  #####
' ####################
'
' A console progress bar.
'
PROGRAM "progbar"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
	IMPORT  "xio"				' Console input/ouput library
'	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION ProgressBar (row, column, length, min, max, value, emptyChar, filledChar)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	FOR i = 0 TO 100
		ProgressBar (5, 5, 70, 0, 100, i, 176, 219)
		Sleep (75)
	NEXT i
	PRINT 
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION ProgressBar (row, column, length, min, max, value, emptyChar, filledChar)

	DOUBLE interval

  IF max = 0 && min = 0 THEN RETURN
	IFZ length THEN RETURN
	
	interval = length / DOUBLE(max - min)
	currentSize = (value - min) * interval
	
	hStdOut = XioGetStdOut ()
	XioSetConsoleCursorPos (hStdOut, row, column)
	XioCloseStdHandle (hStdOut)

	IF currentSize > 0 THEN
		IF currentSize < max THEN
			empty$ = ""
			dif = length - currentSize
			IF dif > 0 THEN empty$ = CHR$(emptyChar, dif)
			PRINT CHR$(filledChar, currentSize) + empty$
		ELSE
			PRINT CHR$(filledChar, length)
		END IF
	ELSE
		PRINT CHR$(emptyChar, length)
	END IF

END FUNCTION
END PROGRAM