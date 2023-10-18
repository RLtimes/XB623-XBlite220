'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of calling XstGetFileAttributes().
'
PROGRAM	"fileattr"
VERSION	"0.0001"
CONSOLE
'
	IMPORT  "xsx"
	IMPORT	"xio"
	IMPORT	"xst"   ' Standard library : required by most programs
'
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC attribNames$[]

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 200)
	XioCloseStdHandle (hStdOut)

	IFZ attribNames$[] THEN GOSUB Initialize

	XstFindFiles("c:/", "*.*", 0, @fn$[])

	upper = UBOUND(fn$[])
	IF upper < 0 THEN RETURN

	FOR i = 0 TO upper
		XstGetFileAttributes (fn$[i], @attributes)
		PRINT fn$[i]; " : ";
		SELECT CASE ALL TRUE
			CASE attributes AND 0x0000	: PRINT attribNames$[0]; " ";
			CASE attributes AND 0x0001	: PRINT attribNames$[1]; " ";
			CASE attributes AND 0x0002	: PRINT attribNames$[2]; " ";
			CASE attributes AND 0x0004	: PRINT attribNames$[3]; " ";
			CASE attributes AND 0x0010	: PRINT attribNames$[4]; " ";
			CASE attributes AND 0x0020	: PRINT attribNames$[5]; " ";
			CASE attributes AND 0x0080	: PRINT attribNames$[6]; " ";
			CASE attributes AND 0x0100	: PRINT attribNames$[7]; " ";
			CASE attributes AND 0x0200	: PRINT attribNames$[8]; " ";
			CASE attributes AND 0x1000	: PRINT attribNames$[9]; " ";
		END SELECT
		PRINT
	NEXT i

	a$ = INLINE$ ("Press RETURN to QUIT >")

' ***** Initialize *****
SUB Initialize
	DIM attribNames$[9]
	attribNames$[0] = "File Not Found"
	attribNames$[1] = "Read Only File"
	attribNames$[2] = "Hidden File"
	attribNames$[3] = "System File"
	attribNames$[4] = "Directory File"
	attribNames$[5] = "Archive File"
	attribNames$[6] = "Normal File"
	attribNames$[7] = "Temporary File"
	attribNames$[8] = "AtomicWrite File"
	attribNames$[9] = "Executable File"
END SUB

END FUNCTION
END PROGRAM
