'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo using random number functions in Xsx:
' XstRandomCreateSeed
' XstRandomSeed
' XstRandom
' XstRandomUniform
'
PROGRAM	"random"
VERSION	"0.0002"
CONSOLE
'
IMPORT	"xst"
IMPORT	"xsx"
IMPORT  "xio"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	ULONG seed1, seed2

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 50)
	XioCloseStdHandle (hStdOut)

	PRINT " ***** XstRandomCreateSeed *****"
	seed1 = XstRandomCreateSeed ()
	PRINT "seed1="; seed1
	PRINT

	XstSleep (100)

	PRINT " ***** XstRandomSeed *****"
	seed2 = 0
	XstRandomSeed (@seed2)
	PRINT "Returned seed2="; seed2
	PRINT

	PRINT " ***** XstRandom *****"
	FOR i = 0 TO 9
		PRINT XstRandom ()
	NEXT i
	PRINT

	PRINT " ***** XstRandomUniform *****"
	FOR i = 0 TO 9
		PRINT XstRandomUniform ()
	NEXT i
	PRINT

	a$ = INLINE$ ("Press ENTER to exit >")

END FUNCTION
END PROGRAM
