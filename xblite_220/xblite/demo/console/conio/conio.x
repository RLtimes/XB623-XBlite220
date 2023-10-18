'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"conio"
VERSION	"0.0001"
CONSOLE
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"kernel32"
	IMPORT	"xio"
'

DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	CHAR_INFO charinfo[]

	IF LIBRARY (0) THEN RETURN

' set console window text in titlebar
	SetConsoleTitleA (&"Console I/O demo.")

' get standard console output handle
	hStdOut = XioGetStdOut ()

' set console screen buffer to 50 lines in height
	XioSetConsoleBufferSize (hStdOut, 0, 50)

	PRINT CHR$ ('x', 79)
	PRINT CHR$ ('y', 79)
	PRINT CHR$ ('z', 79)
	PRINT "0123456789qwertyuiopasfghjklzxcvbnm0123456789qwertyuiopas"

' get current console text up to cursor position
	XioGrabConsoleText (hStdOut, @text$)
	PRINT text$

' put text string at (15, 12)
	XioPutConsoleText (hStdOut, "PutConsoleText at (15,12)", 15, 12)

' grab text from rect area
	ret = XioGetConsoleTextRect (hStdOut, 0, 0, 9, 3, @charinfo[])

' change text attributes of selected text
	upp =  UBOUND (charinfo[])
	attr =  $$FOREGROUND_RED | $$FOREGROUND_INTENSITY | 0xF0		' 0xF0 = white background

	FOR i = 0 TO upp
		charinfo[i].Attributes = attr
	NEXT i

' set red text in new rect area on screen
	ret = XioSetConsoleTextRect (hStdOut, 20, 15, 29, 18, @charinfo[])

' write a text array to console screen buffer
	DIM text$[4]
	text$[0] = "tennis"
	text$[1] = "racquetball"
	text$[2] = "squash"
	text$[3] = "badminton"
	text$[4] = "ping-pong"

	XioPutConsoleTextArray (hStdOut, @text$[], 3, 18)

' get screen buffer info and print it at new cursor position
	XioGetConsoleInfo (hStdOut, @bufSizeX, @bufSizeY, @cursorX, @cursorY, @fColors)
	XioSetConsoleCursorPos (hStdOut, 50, 10)
	PRINT "buffer width         :"; bufSizeX
	XioSetConsoleCursorPos (hStdOut, 50, 11)
	PRINT "buffer height        :"; bufSizeY
	XioSetConsoleCursorPos (hStdOut, 50, 12)
	PRINT "color attribute flag :"; fColors
	XioSetConsoleCursorPos (hStdOut, 50, 13)
	XioGetConsoleInfo (hStdOut, @bufSizeX, @bufSizeY, @cursorX, @cursorY, @fColors)
	PRINT "cursor position x    :"; cursorX
	XioSetConsoleCursorPos (hStdOut, 50, 14)
	XioGetConsoleInfo (hStdOut, @bufSizeX, @bufSizeY, @cursorX, @cursorY, @fColors)
	PRINT "cursor position y    :"; cursorY

' clear text up to cursor position
	XioSetConsoleCursorPos (hStdOut, 0, 30)
	PRINT CHR$ ('0', 79)
	a$ = INLINE$ ("Press Enter key to erase line above >")
	XioSetConsoleCursorPos (hStdOut, 0, 30)
	XioClearEndOfLine (hStdOut)

' delete a line
	XioSetConsoleCursorPos (hStdOut, 0, 34)
	PRINT CHR$ ('1', 79)
	a$ = INLINE$ ("Press Enter key to delete line above >")
	XioSetConsoleCursorPos (hStdOut, 0, 34)
	XioDeleteLine (hStdOut)

' insert a line
	XioSetConsoleCursorPos (hStdOut, 0, 36)
	PRINT CHR$ ('2', 79)
	a$ = INLINE$ ("Press Enter key to insert a line above >")
	XioSetConsoleCursorPos (hStdOut, 0, 37)
	XioInsertLine (hStdOut)

' scroll console screen buffer up
	XioSetConsoleCursorPos (hStdOut, 0, 39)
	a$ = INLINE$ ("Press Enter key to scroll console up 3 lines >")
	XioScrollBufferUp (hStdOut, 3)

' hide console window
	XioSetConsoleCursorPos (hStdOut, 0, 45)
	a$ = INLINE$ ("Press Enter key to hide console for 2 secs >")
	XioHideConsole ()
	Sleep (2000)
	XioShowConsole ()

' set cursor position to bottom of screen
' change cursor type to solid
' change text colors
	XioSetCursorType (hStdOut, $$SOLIDCURSOR)
	XioSetConsoleCursorPos (hStdOut, 0, 47)
	XioSetTextColor (hStdOut, $$CYAN)
	a$ = INLINE$ ("-47- Press ENTER to continue >")
	ret = XioSetTextBackColor (hStdOut, $$YELLOW)
	a$ = INLINE$ ("-48- Press ENTER to continue >")
	ret = XioSetDefaultColors (hStdOut)
	a$ = INLINE$ ("-49- Press ENTER to continue >")


' close handle
	XioCloseStdHandle (hStdOut)


END FUNCTION
END PROGRAM
