'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' XBLite executable program. This program just
' calls XxxXBasic () in xcowlite.dll to start the
' compiler.
'
PROGRAM	"xblite"
VERSION	"0.0004"    		' XBLite 2004/06/23
CONSOLE
'
	IMPORT  "xcowlite"   	' XBLite compiler for windows
	IMPORT  "xio"
  IMPORT  "gdi32"
  IMPORT  "user32"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()
'
RECT rc

' set console buffer size to 80 x 200
  hStdOut = XioGetStdOut ()
  XioSetConsoleBufferSize (hStdOut, 80, 200)
  hWnd = XioGetConsoleWindow ()
  GetWindowRect (hWnd, &rc)

' if necessary, resize the console window
  IF rc.bottom - rc.top > 400 THEN
    MoveWindow (hWnd, rc.left, 20, rc.right-rc.left, 360, 1)
  END IF
  XioCloseStdHandle (hStdOut)

' compile the program or start console mode compiler
	XxxXBasic ()
'
END FUNCTION
END PROGRAM
