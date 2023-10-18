'
'
' #################### David Szafranski
' #####  PROLOG  ##### copyright 2004
' #################### XBlite console IO library
'
' Console IO library for XBLite.

' Some functions based on code from
' Old Turbo-C TCCONIO.C
'
' NOTE : make sure all TYPE casts for COORD
' are removed from kernel32.dec functions
' that are used in this program:
'	ReadConsoleOutputA
'	WriteConsoleOutputA
'	ReadConsoleOutputCharacterA
'	WriteConsoleOutputCharacterA
'
PROGRAM	"xio"
VERSION	"0.0003"
CONSOLE

	IMPORT	"xst"
	IMPORT  "gdi32.dec"
	IMPORT	"user32"
	IMPORT  "kernel32"
'
EXPORT
DECLARE FUNCTION  Xio ()
DECLARE FUNCTION  XioClearEndOfLine (hStdOut)
DECLARE FUNCTION  XioDeleteLine (hStdOut)
DECLARE FUNCTION  XioGetConsoleInfo (hStdOut, @bufSizeX, @bufSizeY, @cursorX, @cursorY, @fColors)
DECLARE FUNCTION  XioGetConsoleTextRect (hStdOut, left, top, right, bottom, CHAR_INFO ci[])
DECLARE FUNCTION  XioGetStdIn ()
DECLARE FUNCTION  XioGetStdOut ()
DECLARE FUNCTION  XioGrabConsoleText (hStdOut, @text$)
DECLARE FUNCTION  XioInsertLine (hStdOut)
DECLARE FUNCTION  XioPutConsoleText (hStdOut, text$, x, y)
DECLARE FUNCTION  XioPutConsoleTextArray (hStdOut, text$[], x, y)
DECLARE FUNCTION  XioScrollBufferUp (hStdOut, count)
DECLARE FUNCTION  XioSetConsoleBufferSize (hStdOut, w, h)
DECLARE FUNCTION  XioSetConsoleCursorPos (hStdOut, x, y)
DECLARE FUNCTION  XioSetConsoleTextRect (hStdOut, left, top, right, bottom, CHAR_INFO ci[])
DECLARE FUNCTION  XioSetCursorType (hStdOut, fCursor)
DECLARE FUNCTION  XioCloseStdHandle (hStdCon)
DECLARE FUNCTION  XioClearConsole (hStdOut)
DECLARE FUNCTION  XioHideConsole ()
DECLARE FUNCTION  XioShowConsole ()
DECLARE FUNCTION  XioCreateConsole (@title$, nlines)
DECLARE FUNCTION  XioGetConsoleWindow ()
DECLARE FUNCTION  XioWriteConsole (hStdOut, text$)
DECLARE FUNCTION  XioReadConsole (hStdIn, @input$)
DECLARE FUNCTION  XioFreeConsole ()
DECLARE FUNCTION  XioSetTextAttributes (hStdOut, newAttribute)
DECLARE FUNCTION  XioSetTextBackColor (hStdOut, newColor)
DECLARE FUNCTION  XioSetTextColor (hStdOut, newColor)
DECLARE FUNCTION  XioSetDefaultColors (hStdOut)
DECLARE FUNCTION  XioInkey ()

END EXPORT

' misc helper functions
INTERNAL FUNCTION  DisplayConsole (fShow)
INTERNAL FUNCTION  GetConsoleHandle (name$)


EXPORT
' set the text foreground/background color constants
$$BLACK			  = 0
$$BLUE			  = 1
$$GREEN			  = 2
$$CYAN			  = 3
$$RED				  = 4
$$MAGENTA			= 5
$$BROWN			  = 6
$$LIGHTGRAY	  = 7
$$DARKGRAY		= 8
$$LIGHTBLUE		= 9
$$LIGHTGREEN	= 10
$$LIGHTCYAN		= 11
$$LIGHTRED		= 12
$$LIGHTMAGENTA= 13
$$YELLOW			= 14
$$WHITE			  = 15

END EXPORT
'
'
' ####################
' #####  Xio ()  #####
' ####################
'
FUNCTION  Xio ()

END FUNCTION
'
'
' ##################################
' #####  XioClearEndOfLine ()  #####
' ##################################
'
'	/*
'	[XioClearEndOfLine]
' Description = Erase text from cursor position to end of line.
' Function    = error = XioClearEndOfLine (hStdOut)
' ArgCount    = 1
'	Arg1        = hStdOut : Standard output handle.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioClearEndOfLine (hStdOut)

	CONSOLE_SCREEN_BUFFER_INFO csbi

	IFZ GetConsoleScreenBufferInfo (hStdOut, &csbi) THEN GOSUB Error
	pos = MAKELONG (csbi.dwCursorPosition.x, csbi.dwCursorPosition.y)
	IFZ FillConsoleOutputCharacterA (hStdOut, ' ', csbi.dwSize.x - csbi.dwCursorPosition.x, pos, &charsWritten) THEN GOSUB Error
	IFZ FillConsoleOutputAttribute (hStdOut, csbi.wAttributes, csbi.dwSize.x - csbi.dwCursorPosition.x, pos, &charsWritten)  THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ##############################
' #####  XioDeleteLine ()  #####
' ##############################
'
'	/*
'	[XioDeleteLine]
' Description = Delete the current cursor line.
' Function    = error = XioDeleteLine (hStdOut)
' ArgCount    = 1
'	Arg1        = hStdOut : Standard console output handle.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioDeleteLine (hStdOut)

	CONSOLE_SCREEN_BUFFER_INFO csbi
	SMALL_RECT srSource
	CHAR_INFO ciFill

	IFZ GetConsoleScreenBufferInfo (hStdOut, &csbi) THEN GOSUB Error

	srSource.Top    = csbi.dwCursorPosition.y + 1
	srSource.Left   = 0
	srSource.Bottom = csbi.dwSize.y - 1
	srSource.Right  = csbi.dwSize.x - 1
	dest = MAKELONG (0, csbi.dwCursorPosition.y)

	ciFill.AsciiChar = ' '
	ciFill.Attributes = csbi.wAttributes

	IFZ ScrollConsoleScreenBufferA (hStdOut, &srSource, NULL, dest, &ciFill) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ##################################
' #####  XioGetConsoleInfo ()  #####
' ##################################
'
'	/*
'	[XioGetConsoleInfo]
' Description = Returns information on console buffer parameters.
' Function    = error = XioGetConsoleInfo (hStdOut, @bufSizeX, @bufSizeY, @cursorX, @cursorY, @fColors)
' ArgCount    = 6
'	Arg1        = hStdOut : Standard console output handle.
'	Arg2        = bufSizeX : Number of buffer columns.
'	Arg3        = bufSizeY : Number of buffer rows.
'	Arg4        = cursorX : Location of cursor by column.
'	Arg5        = cursorY : Location of cursor by row.
'	Arg6        = fColors : Current buffer text/background color attributes.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioGetConsoleInfo (hStdOut, @bufSizeX, @bufSizeY, @cursorX, @cursorY, @fColors)

	CONSOLE_SCREEN_BUFFER_INFO coninfo

	IFZ GetConsoleScreenBufferInfo (hStdOut, &coninfo) THEN GOSUB Error
	bufSizeX = coninfo.dwSize.x
	bufSizeY = coninfo.dwSize.y
	cursorX  = coninfo.dwCursorPosition.x
	cursorY  = coninfo.dwCursorPosition.y
	fColors  = coninfo.wAttributes

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ######################################
' #####  XioGetConsoleTextRect ()  #####
' ######################################
'
'	/*
'	[XioGetConsoleTextRect]
' Description = Grab a rectangular area of text from the console screen buffer.
' Function    = error = XioGetConsoleTextRect (hStdOut, left, top, right, bottom, CHAR_INFO ci[])
' ArgCount    = 6
'	Arg1        = hStdOut : Standard console output handle.
'	Arg2        = left : Left rectangle coordinate.
'	Arg3        = top : Top rectangle coordinate.
'	Arg4        = right : Right rectangle coordinate.
'	Arg5        = bottom : Bottom rectangle coordinate.
'	Arg6        = ci[] : Array of CHAR_INFO type date containing text and attributes for each cell.
'	Return      = 0 on success, -1 on failure.
' Remarks     = Coordinates are zero-based.
'	See Also    = XioSetConsoleTextRect().
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioGetConsoleTextRect (hStdOut, left, top, right, bottom, CHAR_INFO ci[])

	SMALL_RECT srSource

	srSource.Left   = left
	srSource.Top    = top
	srSource.Right  = right						' coords are inclusive
	srSource.Bottom = bottom
	dwBufferSize    = MAKELONG (srSource.Right - srSource.Left + 1, srSource.Bottom - srSource.Top + 1)
	dwBufferOrg     = MAKELONG (0, 0)
	dwBuffLen       = (srSource.Right - srSource.Left + 1) * (srSource.Bottom - srSource.Top + 1)

	DIM ci[dwBuffLen-1]

	IFZ ReadConsoleOutputA (hStdOut, &ci[0], dwBufferSize, dwBufferOrg, &srSource) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ############################
' #####  XioGetStdIn ()  #####
' ############################
'
'	/*
'	[XioGetStdIn]
' Description = Return the console window handle.
' Function    = hStdIn = XioGetStdIn ()
' ArgCount    = 0
'	Return      = Standard console input handle on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioGetStdIn ()

	RETURN GetConsoleHandle ("CONIN$")

END FUNCTION
'
'
' #############################
' #####  XioGetStdOut ()  #####
' #############################
'
'	/*
'	[XioGetStdOut]
' Description = Return the console window handle.
' Function    = hStdOut = XioGetStdOut ()
' ArgCount    = 0
'	Return      = Standard console output handle on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioGetStdOut ()

	RETURN GetConsoleHandle ("CONOUT$")

END FUNCTION
'
'
' ###################################
' #####  XioGrabConsoleText ()  #####
' ###################################
'
'	/*
'	[XioGrabConsoleText]
' Description = Get all console screen buffer text from console origin to current cursor position.
' Function    = error = XioGrabConsoleText (hStdOut, @text$)
' ArgCount    = 2
'	Arg1        = hStdOut : Standard console ouput handle.
'	Arg2        = text$ : Returned screen buffer text.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioGrabConsoleText (hStdOut, @text$)

	CONSOLE_SCREEN_BUFFER_INFO coninfo

	text$ = ""
	GetConsoleScreenBufferInfo (hStdOut, &coninfo)

	rowsToRead = 1 + coninfo.dwCursorPosition.y

	buffer$ = NULL$ (coninfo.dwSize.x)
	y = 0
	readCoord = MAKELONG (0, y)

	DO WHILE rowsToRead
		IFZ ReadConsoleOutputCharacterA (hStdOut, &buffer$, coninfo.dwSize.x, readCoord, &bytesRead) THEN
			error = GetLastError ()
			XstSystemErrorNumberToName (error, @error$)
'			PRINT "ReadConsoleOutputCharacterA error: "; error$
			text$ = ""
			RETURN ($$TRUE)
		END IF
		text$ = text$ + LEFT$ (buffer$, bytesRead)
		INC y
		readCoord = MAKELONG (0, y)
		DEC rowsToRead
	LOOP

END FUNCTION
'
'
' ##############################
' #####  XioInsertLine ()  #####
' ##############################
'
'	/*
'	[XioInsertLine]
' Description = Insert a line above current cursor line.
' Function    = error = XioInsertLine (hStdOut)
' ArgCount    = 1
'	Arg1        = hStdOut : Standard output handle.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioInsertLine (hStdOut)

	CONSOLE_SCREEN_BUFFER_INFO csbi
	SMALL_RECT srSource
	CHAR_INFO ciFill

	IFZ GetConsoleScreenBufferInfo (hStdOut, &csbi) THEN GOSUB Error

	srSource.Top    = csbi.dwCursorPosition.y
	srSource.Left   = 0
	srSource.Bottom = csbi.dwSize.y - 1
	srSource.Right  = csbi.dwSize.x - 1
	dest = MAKELONG (0, csbi.dwCursorPosition.y + 1)

	ciFill.AsciiChar = ' '
	ciFill.Attributes = csbi.wAttributes

	IFZ ScrollConsoleScreenBufferA (hStdOut, &srSource, NULL, dest, &ciFill) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ##################################
' #####  XioPutConsoleText ()  #####
' ##################################
'
'	/*
'	[XioPutConsoleText]
' Description = Write text string to position x, y in console screen buffer. This does not change the current cursor position.
' Function    = error = XioPutConsoleText (hStdOut, text$, x, y)
' ArgCount    = 4
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = text$ : Text string to write to console.
'	Arg3        = x : x console cell position (0 based).
'	Arg4        = y : y console cell position (0 based).
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioPutConsoleText (hStdOut, text$, x, y)

	IFZ text$ THEN RETURN ($$TRUE)
	writeCoord = MAKELONG (x, y)
	IFZ WriteConsoleOutputCharacterA (hStdOut, &text$, LEN (text$), writeCoord, &charsWritten) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' #######################################
' #####  XioPutConsoleTextArray ()  #####
' #######################################
'
'	/*
'	[XioPutConsoleTextArray]
' Description = Write text array to position x, y in console screen buffer. This does not change the current cursor position.
' Function    = error = XioPutConsoleTextArray (hStdOut, text$[], x, y)
' ArgCount    = 4
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = text$[] : Text array to write to console.
'	Arg3        = x : x console cell position (0 based).
'	Arg4        = y : y console cell position (0 based).
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioPutConsoleTextArray (hStdOut, text$[], x, y)

	IFZ text$[] THEN RETURN ($$TRUE)

	upp = UBOUND (text$[])
	FOR i = 0 TO upp
		writeCoord = MAKELONG (x, y)
		err = WriteConsoleOutputCharacterA (hStdOut, &text$[i], LEN (text$[i]), writeCoord, &charsWritten)
		IFZ err THEN EXIT FOR
		INC y
	NEXT i

	IFZ err THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ##################################
' #####  XioScrollBufferUp ()  #####
' ##################################
'
'	/*
'	[XioScrollBufferUp]
' Description = Scroll entire console screen buffer up 'count' lines from bottom.
' Function    = error = XioScrollBufferUp (hStdOut, count)
' ArgCount    = 2
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = count : Number of lines to scroll.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioScrollBufferUp (hStdOut, count)

	CONSOLE_SCREEN_BUFFER_INFO csbi
	SMALL_RECT srSource
	CHAR_INFO ciFill

	IFZ GetConsoleScreenBufferInfo (hStdOut, &csbi) THEN GOSUB Error

	srSource.Top    = count
	srSource.Left   = 0
	srSource.Bottom = csbi.dwSize.y - 1
	srSource.Right  = csbi.dwSize.x - 1
	dest = MAKELONG (0, 0)

	ciFill.AsciiChar = ' '
	ciFill.Attributes = csbi.wAttributes

	IFZ ScrollConsoleScreenBufferA (hStdOut, &srSource, NULL, dest, &ciFill) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ########################################
' #####  XioSetConsoleBufferSize ()  #####
' ########################################
'
'	/*
'	[XioSetConsoleBufferSize]
' Description = Set console screen buffer size.
' Function    = error = XioSetConsoleBufferSize (hStdOut, w, h)
' ArgCount    = 3
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = w : Number of cells or columns wide (default = 80).
'	Arg3        = h : Number of lines (default = 25).
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioSetConsoleBufferSize (hStdOut, w, h)

	IF w < 80 THEN w = 80
	IF h < 25 THEN h = 25

	bsize = MAKELONG (w, h)
	IFZ SetConsoleScreenBufferSize (hStdOut, bsize) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' #######################################
' #####  XioSetConsoleCursorPos ()  #####
' #######################################
'
'	/*
'	[XioSetConsoleCursorPos]
' Description = Set console cursor position.
' Function    = error = XioSetConsoleCursorPos (hStdOut, x, y)
' ArgCount    = 3
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = x : Zero based coordinates of new x cursor position.
'	Arg3        = y : Zero based coordinates of new y cursor position.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioSetConsoleCursorPos (hStdOut, x, y)

	pos = MAKELONG (x, y)
	IFZ SetConsoleCursorPosition (hStdOut, pos) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ######################################
' #####  XioSetConsoleTextRect ()  #####
' ######################################
'
'	/*
'	[XioSetConsoleTextRect]
' Description = Write a text rect area to the console screen buffer.
' Function    = error = XioSetConsoleTextRect (hStdOut, left, top, right, bottom, CHAR_INFO ci[])
' ArgCount    = 6
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = left : Zero based coordinates of left rect position.
'	Arg3        = top : Zero based coordinates of top rect position.
'	Arg4        = right : Zero based coordinates of right rect position.
'	Arg5        = bottom : Zero based coordinates of bottom rect position.
'	Arg6        = ci[] : Array of CHAR_INFO type data of text and attributes (colors).
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    = XioGetConsoleTextRect().
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioSetConsoleTextRect (hStdOut, left, top, right, bottom, CHAR_INFO ci[])

	SMALL_RECT srDest

	srDest.Left   = left
	srDest.Top    = top
	srDest.Right  = right						' coords are inclusive
	srDest.Bottom = bottom
	dwBufferSize  = MAKELONG (srDest.Right - srDest.Left + 1, srDest.Bottom - srDest.Top + 1)
	dwBufferOrg   = MAKELONG (0, 0)
	dwBuffLen     = (srDest.Right - srDest.Left + 1) * (srDest.Bottom - srDest.Top + 1)

	IFZ (WriteConsoleOutputA (hStdOut, &ci[], dwBufferSize, dwBufferOrg, &srDest)) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' #################################
' #####  XioSetCursorType ()  #####
' #################################
'
'	/*
'	[XioSetCursorType]
' Description = Set cursor style.
' Function    = error = XioSetCursorType (hStdOut, fCursor)
' ArgCount    = 2
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = fCursor : cursor style flag: $$NOCURSOR = 0 (hide cursor), $$SOLIDCURSOR = 1, $$NORMALCURSOR = 2.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioSetCursorType (hStdOut, fCursor)

	CONSOLE_CURSOR_INFO cci

	SELECT CASE fCursor

		CASE $$NOCURSOR:
			cci.dwSize = $$NORM_CURSOR_SIZE
			cci.bVisible = $$FALSE

		CASE $$SOLIDCURSOR:
			cci.dwSize = $$SOLID_CURSOR_SIZE
			cci.bVisible = $$TRUE

		CASE $$NORMALCURSOR:
			cci.dwSize = $$NORM_CURSOR_SIZE
			cci.bVisible = $$TRUE

	END SELECT
	IFZ SetConsoleCursorInfo (hStdOut, &cci) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ##################################
' #####  XioCloseStdHandle ()  #####
' ##################################
'
'	/*
'	[XioCloseStdHandle]
' Description = Close standard input or output console handle.
' Function    = error = XioCloseStdHandle (hStdCon)
' ArgCount    = 1
'	Arg1        = hStdCon : Console handle from XioGetStdIn () or XioGetStdOut ().
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
' PURPOSE : Close standard input or output console handle.
' IN      : hStdCon - io handle from XioGetStdIn() or XioGetStdOut().
'
FUNCTION  XioCloseStdHandle (hStdCon)

	IFZ CloseHandle (hStdCon) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ################################
' #####  XioClearConsole ()  #####
' ################################
'
'	/*
'	[XioClearConsole]
' Description = Clear the console of all text, and then set cursor to position (0, 0).
' Function    = error = XioClearConsole (hStdOut)
' ArgCount    = 1
'	Arg1        = hStdOut : Standard output handle.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioClearConsole (hStdOut)

	IFZ (SetConsoleCursorPosition (hStdOut, 0)) THEN GOSUB Error
	IFZ FillConsoleOutputCharacterA (hStdOut, ' ', 0xFFFFFF, 0, &written) THEN GOSUB Error

SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ###############################
' #####  XioHideConsole ()  #####
' ###############################
'
'	/*
'	[XioHideConsole]
' Description = Hide the console window.
' Function    = error = XioHideConsole ()
' ArgCount    = 0
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    = XioShowConsole().
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioHideConsole ()

	RETURN DisplayConsole ($$SW_HIDE)

END FUNCTION
'
'
' ###############################
' #####  XioShowConsole ()  #####
' ###############################
'
'	/*
'	[XioShowConsole]
' Description = Show the console.
' Function    = error = XioShowConsole ()
' ArgCount    = 0
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    = XioHideConsole().
'	Examples    = See contest.x.
'	*/
'
FUNCTION  XioShowConsole ()

	RETURN DisplayConsole ($$SW_SHOW)

END FUNCTION
'
'
' #################################
' #####  XioCreateConsole ()  #####
' #################################
'
'	/*
'	[XioCreateConsole]
' Description = Creates a win32 console window for a GUI application.
' Function    = error = XioCreateConsole (@title$, nlines)
' ArgCount    = 2
'	Arg1        = title$ : console window title text.
'	Arg2        = nlines : initial number of console lines (or rows) in console buffer. Default is 25 lines.
'	Return      = 0 on success, -1 on failure.
' Remarks     = Call XioFreeConsole() before exiting process.
'	See Also    = See XioFreeConsole().
'	Examples    = XioCreateConsole (@"My Console", 100)
'	*/
'
FUNCTION  XioCreateConsole (@title$, nlines)

	STATIC entry
	SHARED fCreateConsole

	IF entry THEN
		lastErr = ERROR ($$ErrorNatureAlreadyInitialized)
 		RETURN ($$TRUE)
	END IF

	IFZ AllocConsole () THEN GOSUB Error 				' allocate a console ONCE

	entry = $$TRUE
	fCreateConsole = $$TRUE

' get console hStdOut
	hStdOut = XioGetStdOut ()

' set console title
' default title is name of executable
	IFZ title$ THEN
		title$ = NULL$ (256)
		ret = GetModuleFileNameA (0, &title$, 256)
		title$ = LEFT$ (title$, ret)
		slash = RINSTR (title$, "\\")
		IF slash THEN
			title$ = RIGHT$ (title$, LEN (title$) - slash)
		END IF
	END IF
	SetConsoleTitleA (&title$)										' set console window title

' Set a console buffer bigger than the console window. This provides
' scroll bars on the console window to scroll through the console buffer

	length = 80
	IF nlines < 25 THEN nlines = 25		' max nlines is limited by user memory, default is 25
	bs = MAKELONG (length, nlines)
	IFZ SetConsoleScreenBufferSize (hStdOut, bs) THEN GOSUB Error

	CloseHandle (hStdOut)

' ***** Error *****
SUB Error
	CloseHandle (hStdOut)
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ####################################
' #####  XioGetConsoleWindow ()  #####
' ####################################
'
'	/*
'	[XioGetConsoleWindow]
' Description = Return the console window handle.
' Function    = hWnd = XioGetConsoleWindow ()
' ArgCount    = 0
'	Return      = Window handle on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioGetConsoleWindow ()

	title$ = NULL$ (128)												' create title buffer
	GetConsoleTitleA (&title$, LEN(title$))			' get console title
	title$ = CSIZE$ (title$)
	hConsole = FindWindowA (0, &title$)					' get handle to console window

	IFZ hConsole THEN hConsole = GetForegroundWindow ()

	IFZ hConsole THEN RETURN ($$TRUE) ELSE RETURN hConsole

END FUNCTION
'
'
' ################################
' #####  XioWriteConsole ()  #####
' ################################
'
'	/*
'	[XioWriteConsole]
' Description = Write text to the console window. Cursor position is set to current end of line. Screen will scroll text up when last line in buffer is reached. The size of the screen buffer is not altered.
' Function    = err = XioWriteConsole (hStdOut, text$)
' ArgCount    = 2
'	Arg1        = hStdOut : standard output handle.
'	Arg2        = text$ : text string to write to console.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioWriteConsole (hStdOut, text$)

	IFZ WriteFile (hStdOut, &text$, LEN (text$), &bytesWritten, 0) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ###############################
' #####  XioReadConsole ()  #####
' ###############################
'
'	/*
'	[XioReadConsole]
' Description = Read data from console screen buffer.
' Function    = error = XioReadConsole (hStdIn, @input$)
' ArgCount    = 2
'	Arg1        = hStdIn : Standard input handle.
'	Arg2        = input$[] : Returned text string.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See contest.x.
'	*/
'
FUNCTION  XioReadConsole (hStdIn, @input$)

	FlushConsoleInputBuffer (hStdIn)
	buffer$ 	= NULL$(8192)
	IFZ ReadFile (hStdIn, &buffer$, LEN(buffer$), &bytesRead, 0) THEN GOSUB Error		' read text from console
'	input$ = LEFT$ (buffer$, bytesRead)
	input$ = MID$ (buffer$, 1, bytesRead-2)

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ###############################
' #####  XioFreeConsole ()  #####
' ###############################
'
'	/*
'	[XioFreeConsole]
' Description = Free a win32 console created by XioCreateConsole ().
' Function    = error = XioFreeConsole ()
' ArgCount    = 0
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    = XioCreateConsole ().
'	Examples    =
'	*/
'
FUNCTION  XioFreeConsole ()

	SHARED fCreateConsole

	IFZ fCreateConsole THEN
		lastErr = ERROR ($$ErrorNatureNotInitialized)
 		RETURN ($$TRUE)
	END IF

	IFZ FreeConsole () THEN						' deallocate the console
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
'
' #####################################
' #####  XioSetTextAttributes ()  #####
' #####################################
'
'	/*
'	[XioSetTextAttributes]
' Description = Set the console foreground and background text colors.
' Function    = error = XioSetTextAttributes (hStdOut, newAttribute)
' ArgCount    = 2
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = newAttribute : Color attribute flags, attributes can be ORd together.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See contest.x.
'	*/
'
' Console attributes flags (in kernel32.dec):
'
' $$FOREGROUND_BLUE      = 0x0001 ' text color contains blue.
' $$FOREGROUND_GREEN     = 0x0002 ' text color contains green.
' $$FOREGROUND_RED       = 0x0004 ' text color contains red.
' $$FOREGROUND_INTENSITY = 0x0008 ' text color is intensified.
' $$BACKGROUND_BLUE      = 0x0010 ' background color contains blue.
' $$BACKGROUND_GREEN     = 0x0020 ' background color contains green.
' $$BACKGROUND_RED       = 0x0040 ' background color contains red.
' $$BACKGROUND_INTENSITY = 0x0080 ' background color is intensified.
' $$BLACKONWHITE         = 0x00F0 ' black text on white background
' $$WHITEONBLACK         = 0x0007 ' white text on black background
'
FUNCTION  XioSetTextAttributes (hStdOut, newAttribute)

	IFZ SetConsoleTextAttribute (hStdOut, newAttribute) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ####################################
' #####  XioSetTextBackColor ()  #####
' ####################################
'
'	/*
'	[XioSetTextBackColor]
' Description = Set the console background color.
' Function    = error = XioSetTextBackColor (hStdOut, newColor)
' ArgCount    = 2
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = newColor : Console background color constant.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = XioSetTextBackColor (hStdOut, $$YELLOW)
'	*/
FUNCTION  XioSetTextBackColor (hStdOut, newColor)

	CONSOLE_SCREEN_BUFFER_INFO csbi

	IFZ GetConsoleScreenBufferInfo (hStdOut, &csbi) THEN GOSUB Error
	attr = csbi.wAttributes & 0x000F
	IFZ SetConsoleTextAttribute (hStdOut, attr | (newColor << 4)) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ################################
' #####  XioSetTextColor ()  #####
' ################################
'
'	/*
'	[XioSetTextColor]
' Description = Set the console text color.
' Function    = error = XioSetTextColor (hStdOut, newColor)
' ArgCount    = 2
'	Arg1        = hStdOut : Standard output handle.
'	Arg2        = newColor : Console text color constant.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = XioSetTextColor (hStdOut, $$RED)
'	*/
'
FUNCTION  XioSetTextColor (hStdOut, newColor)

	CONSOLE_SCREEN_BUFFER_INFO csbi

	IFZ GetConsoleScreenBufferInfo (hStdOut, &csbi) THEN GOSUB Error
	attr = csbi.wAttributes & 0x00F0
	IFZ SetConsoleTextAttribute (hStdOut, attr | newColor) THEN GOSUB Error

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB

END FUNCTION
'
'
' ####################################
' #####  XioSetDefaultColors ()  #####
' ####################################
'
'	/*
'	[XioSetDefaultColors]
' Description = Set default text attributes: lightgray text on black background.
' Function    = error = XioSetDefaultColors (hStdOut)
' ArgCount    = 1
'	Arg1        = hStdOut : Standard output handle.
'	Return      = 0 on success, -1 on failure.
' Remarks     =
'	See Also    =
'	Examples    = See conio.x.
'	*/
'
FUNCTION  XioSetDefaultColors (hStdOut)

	RETURN XioSetTextAttributes (hStdOut, $$LIGHTGRAY)

END FUNCTION
'
'
' #########################
' #####  XioInkey ()  #####
' #########################
'
'	/*
'	[XioInkey]
' Description = The XioInkey function returns a character key code when a keyboard key has been pressed. It does not wait for a keyboard event. If there is no pending key in the input buffer, then program execution continues after XioInkey() has checked for a keystroke.
' Function    = keyCode = XioInkey ()
' ArgCount    = 0
'	Return      = 0 if no keyboard event, else key code.
' Remarks     = Non ASCII chars return as negative numbers (eg; arrow keys). Alt+key - Adds 1000 to return value. Ctrl+key - Adds 2000 to return value.
'	See Also    =
'	Examples    = See inkey.x.
'	*/
'
FUNCTION  XioInkey ()

	INPUT_RECORD inputRecord

	STATIC u$, l$
	STATIC entry, hStdIn, upper

	IFZ entry THEN GOSUB Initialize

	GetConsoleMode (hStdIn, &oldConsoleMode)
	SetConsoleMode (hStdIn, oldConsoleMode & ~$$ENABLE_LINE_INPUT & ~$$ENABLE_ECHO_INPUT)
'	SetConsoleMode (hStdIn, 0)

	PeekConsoleInputA (hStdIn, &inputRecord, 1, &count)

	IF (count) THEN

		ReadConsoleInputA (hStdIn, &inputRecord, 1, &count)
  	SetConsoleMode (hStdIn, oldConsoleMode)

  	IF (count) && (inputRecord.EventType == $$KEY_EVENT) && (inputRecord.KeyEvent.bKeyDown) THEN
			vkc = inputRecord.KeyEvent.wVirtualKeyCode
			vsc = inputRecord.KeyEvent.wVirtualScanCode
			ch  = inputRecord.KeyEvent.AsciiChar
			cks = inputRecord.KeyEvent.dwControlKeyState
			IF (!ch) && (vsc > 58) THEN
				IF (cks & 3) THEN RETURN (1000 + vsc) * (-1)		' Alt key pressed
				IF (cks & 12) THEN RETURN (2000 + vsc) * (-1)		' Ctrl key pressed
				RETURN vsc * (-1)
			END IF

			IF (ch && (cks & 3)) THEN RETURN vkc + 1000				' Alt key pressed
			IF ((vsc == 15) && (cks & 16)) THEN RETURN 15
			IF (vkc == 27) THEN RETURN 27											' Esc key pressed

			IF (ch && (cks & 128)) THEN												' Caps Lock is on
				FOR i = 0 TO upper
					IF u${i} == ch THEN
						ch = l${i}
						RETURN ch
					END IF
				NEXT i
			END IF

			IF ch THEN RETURN ch
		END IF
	END IF

	SetConsoleMode (hStdIn, oldConsoleMode)

  RETURN

' ***** Initialize *****
SUB Initialize
	entry = $$TRUE
	hStdIn = GetStdHandle ($$STD_INPUT_HANDLE)
	u$ = "\x7E\x21\x40\x23\x24\x25\x5E\x26\x2A\x28\x29\x5F\x2B\x7C\x7B\x7D\x3A\x22\x3C\x3E\x3F\x60\x31\x32\x33\x34\x35\x36\x37\x38\x39\x30\x2D\x3D\x5C\x5B\x5D\x3B\x27\x2C\x2E\x2F\x00"
	l$ = "\x60\x31\x32\x33\x34\x35\x36\x37\x38\x39\x30\x2D\x3D\x5C\x5B\x5D\x3B\x27\x2C\x2E\x2F\x7E\x21\x40\x23\x24\x25\x5E\x26\x2A\x28\x29\x5F\x2B\x7C\x7B\x7D\x3A\x22\x3C\x3E\x3F\x00"
	upper = LEN (u$) - 1
END SUB

END FUNCTION
'
'
' ###############################
' #####  DisplayConsole ()  #####
' ###############################
'
' PURPOSE : Display or Hide console window
' IN			: fShow - $$SW_HIDE or $$SW_SHOW
'
FUNCTION  DisplayConsole (fShow)

	hConsole = XioGetConsoleWindow ()

	IF hConsole THEN
		ShowWindow (hConsole, fShow)							' show/hide window
	ELSE
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
'
' #################################
' #####  GetConsoleHandle ()  #####
' #################################
'
FUNCTION  GetConsoleHandle (name$)

	SECURITY_ATTRIBUTES sa

	sa.length = SIZE (sa)
	sa.securityDescriptor = NULL
	sa.inherit = $$TRUE

' Using CreateFile we get the true console handle,
' avoiding any redirection.

	hCon = CreateFileA (&name$, $$GENERIC_READ | $$GENERIC_WRITE, $$FILE_SHARE_READ | $$FILE_SHARE_WRITE, &sa, $$OPEN_EXISTING,	0, 0)
	IF (hCon = $$INVALID_HANDLE_VALUE) THEN GOSUB Error
	RETURN hCon

' ***** Error *****
SUB Error
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB
END FUNCTION
END PROGRAM
