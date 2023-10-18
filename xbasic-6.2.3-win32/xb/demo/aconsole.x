'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"aconsole"
VERSION	"0.0001"
'
IMPORT	"xst"
IMPORT	"xgr"
'
' This program shows how to get the grid number of the standard console
' grid and how to hide and display the standard console.
'
' If you start the program development environment or a standalone
' executable with a "-HideConsole" command line argument, then the
' standard console will not be displayed after it is created by
' startup code.  The code in this program will still display and
' hide the standard console when suppressed with "-HideConsole",
' and any program can display a hidden console by sending it a
' "ShowWindow" or "DisplayWindow" message - see XstGetConsoleGrid().
'
' If you start the program development environment or a standalone
' executable with a "-NoConsole" command line argument, then the
' standard console will not be created or displayed.  In this case
' there is no standard console grid and therefore it is impossible
' to send messages to the standard console grid or to display the
' standard console at any time.  The standard console grid can only
' be created at startup time, so do not include "-NoConsole" in the
' command line in any program that may need the standard console at
' any time.
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()
'
	XstGetConsoleGrid (@grid)
	PRINT "console grid = "; grid
	XgrMessageNameToNumber (@"HideWindow", @#HideWindow)
	XgrMessageNameToNumber (@"DisplayWindow", @#DisplayWindow)
'
	IF grid THEN
		XgrSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
		XstSleep (500)
'
		XgrSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
		XstSleep (500)
'
		XgrSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
		XstSleep (500)
'
		XgrSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
		XstSleep (500)
'
		XgrSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
		XstSleep (500)
'
		XgrSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
		XgrProcessMessages (-2)
		XstSleep (500)
	END IF
END FUNCTION
END PROGRAM
