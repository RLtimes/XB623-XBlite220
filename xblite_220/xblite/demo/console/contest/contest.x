'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo using XBLite specific console functions
' to show how console only applications can be
' developed.
'
PROGRAM	"contest"
VERSION	"0.0003"
CONSOLE								' build as a console app
'
	IMPORT	"xst"
	IMPORT  "xio"
	IMPORT	"gdi32"
	IMPORT	"user32"
	IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	COORD size, maxsize, curpos
	CONSOLE_SCREEN_BUFFER_INFO coninfo
	SMALL_RECT srect

' set console window text in titlebar
	title$ = "Console Demo for XBLite"
	SetConsoleTitleA (&title$)

	a$ = INLINE$ ("press a key to continue >")

	hStdOut = XioGetStdOut ()
	hStdIn = XioGetStdIn ()

	PRINT "Console title : "; title$
	PRINT "hStdOut       :"; hStdOut
	PRINT "hStdIn        :"; hStdIn
	PRINT "hConsole      :"; XioGetConsoleWindow ()
	PRINT

	XioWriteConsole (hStdOut, "Hello XB LITE World!" + "\n")

	a$ = INLINE$ ("What is your name? >")

	text$ = "Your name is " + a$
	XioWriteConsole (hStdOut, text$ + "\n")

	prompt$ = "Press ENTER to hide the console for 2 seconds >"
	a$ = INLINE$ (prompt$)

	XioHideConsole ()
	Sleep (2000)
	XioShowConsole ()

	prompt$ = "What is your favorite animal?"
	input$ = INLINE$ (prompt$)

	XioWriteConsole (hStdOut, "Ok - " + TRIM$(input$) + "s are nice!" + "\n")

	a$ = INLINE$ ("Press ENTER to clear the console >")
	XioClearConsole (hStdOut)

	FillConsoleOutputAttribute (hStdOut, 0xF0, 0xFFFFFF, 0, &written)
	XioSetTextAttributes (hStdOut, 0xF0)

' get console screen buffer info
	lstat 	= GetConsoleScreenBufferInfo (hStdOut, &coninfo)
	size 		= coninfo.dwSize
	curpos 	= coninfo.dwCursorPosition
	srect 	= coninfo.srWindow
	maxsize = coninfo.dwMaximumWindowSize

	nl$ = "\n"
	text$ = "Console Screen Buffer Info:" + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Length: " + STRING$(size.x) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Rows  : " + STRING$(size.y) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Cursor Position x : " + STRING$(curpos.x) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Cursor Position y : " + STRING$(curpos.y) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Buffer display width : " + STRING$(srect.Right - srect.Left) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Buffer display height : " + STRING$(srect.Bottom - srect.Top) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Max window length : " + STRING$(maxsize.x) + nl$
	XioWriteConsole (hStdOut, text$)
	text$ = "Max window rows : " + STRING$(maxsize.y) + nl$ + nl$
	XioWriteConsole (hStdOut, text$)

	XioSetConsoleCursorPos (hStdOut, 11, 14)
	XioWriteConsole (hStdOut, "12 across, 15 down. \n \n")

	XioWriteConsole (hStdOut, "Type some text and press ENTER > ")

	XioSetTextColor (hStdOut, $$RED)			' set text color to read
	XioReadConsole (hStdIn, @input$)			' get text input from console
	XioSetTextAttributes (hStdOut, 0x7)  	' change text color back to white on black

	XioWriteConsole (hStdOut, "\nYou typed this: \n")
	text$ = input$ + nl$
	XioWriteConsole (hStdOut, text$)

	XioCloseStdHandle (hStdOut)
	XioCloseStdHandle (hStdIn)

	a$ = INLINE$ ("Press ENTER to exit >")

END FUNCTION
END PROGRAM
