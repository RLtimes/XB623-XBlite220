'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' CONWAY'S GAME OF LIFE
' QB code by John Wantland  08-02-98

PROGRAM	"life"
VERSION	"0.0002"
CONSOLE

IMPORT	"xst_s.lib"
IMPORT	"xsx_s.lib"
IMPORT  "xio_s.lib"
IMPORT	"msvcrt"
IMPORT 	"kernel32"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  INKEY$ ()
DECLARE FUNCTION  LOCATE (row, col)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
' conway's game of life
'
FUNCTION  Entry ()

	hStdOut = XioGetStdOut ()

' standard console is 80 x 25

' turn off console curser
	XioSetCursorType (hStdOut, $$NOCURSOR)

	DIM b[25, 82]
	DIM c[25, 82]

' set all cells to space character
	FOR x = 0 TO 82
		FOR y = 0 TO 25
			b[y, x] = 32
			c[y, x] = 32
		NEXT
	NEXT

' randomly set cells to 'cell' char
	FOR x = 1 TO 80
		FOR y = 1 TO 23
			IF (XstRandom () MOD 6) + 1 = 3 THEN
				b[y, x] = 2  : c[y, x] = 2
			ELSE
				b[y, x] = 32 : c[y, x] = 32
			END IF

'			LOCATE (y, x)
'			_putch (b[y, x])
			XioPutConsoleText (hStdOut, CHR$(b[y, x]), x, y)
		NEXT y
	NEXT x

	DO
' check to see if any neighbor cells are alive (occupied)
		FOR x = 1 TO 80
			FOR y = 1 TO 23
				n = 0
				IF c[y - 1, x] = 2 THEN INC n
				IF c[y - 1, x - 1] = 2 THEN INC n
				IF c[y, x - 1] = 2 THEN INC n
				IF c[y + 1, x - 1] = 2 THEN INC n
				IF c[y + 1, x] = 2 THEN INC n
				IF c[y + 1, x + 1] = 2 THEN INC n
				IF c[y, x + 1] = 2 THEN INC n
				IF c[y - 1, x + 1] = 2 THEN INC n
				IF (n < 2) || (n > 3) THEN b[y, x] = 32
				IF n = 3 THEN b[y, x] = 2
			NEXT y
		NEXT x

' print new cell arrangements
		FOR x = 1 TO 80
			FOR y = 1 TO 23
'				LOCATE (y, x)
'				_putch (b[y, x])			' print a character to console
				XioPutConsoleText (hStdOut, CHR$(b[y, x]), x, y)
				c[y, x] = b[y, x]
			NEXT y
		NEXT x

' whoa, slow it down!
		Sleep (75)

	LOOP UNTIL INKEY$ ()

	XioCloseStdHandle (hStdOut)

END FUNCTION
'
'
' #######################
' #####  INKEY$ ()  #####
' #######################
'
' Return last console key character.
'
FUNCTION  INKEY$ ()

	IF _kbhit () THEN
		char = _getch ()
		RETURN CHR$ (char)
	END IF
	RETURN ""

END FUNCTION
'
'
' #######################
' #####  LOCATE ()  #####
' #######################
'
' Set cursor position at row, col.
'
FUNCTION  LOCATE (row, col)

	STATIC hConsole, entry

	IFZ entry THEN
		hConsole = GetStdHandle ($$STD_OUTPUT_HANDLE)
		entry = $$TRUE
	END IF

	SetConsoleCursorPosition (hConsole, MAKELONG (col-1, row-1))

END FUNCTION
END PROGRAM
