'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program illustrates how to determine
' the default system browser and then start
' the browser with a URL.
'
PROGRAM	"launch"
VERSION	"0.0001"
CONSOLE
'
IMPORT	"xst"
'IMPORT	"xsx"
IMPORT	"gdi32"
IMPORT 	"kernel32"
IMPORT	"shell32"
IMPORT	"user32.dec"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  LaunchBrowser (url$, @defBrowserExe$, fStart)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	url$ = "http://perso.wanadoo.fr/xblite/"
	fStart = $$TRUE

	LaunchBrowser (url$, @defBrowserExe$, fStart)
	PRINT "Default Browser : "; defBrowserExe$

	PRINT
	a$ = INLINE$("Press ENTER to exit >")
END FUNCTION
'
'
' ##############################
' #####  LaunchBrowser ()  #####
' ##############################
'
FUNCTION  LaunchBrowser (url$, @defBrowserExe$, fStart)

' first, create a known, temporary HTML file

	defBrowserExe$ = NULL$ (256)								' create default browser path string
	file$ = "temphtm.htm"												' temp html file
	s$ = "<HTML> <\HTML>"												' html string

	of = OPEN (file$, $$RW)											' open temp html file
	WRITE [of], s$															' write string to file
	CLOSE (of)																	' close file

' find the application associated with it

	ret = FindExecutableA (&file$, NULL, &defBrowserExe$)	' find executable
	defBrowserExe$ = CSIZE$ (defBrowserExe$)
	DeleteFileA (&file$)													' delete temp file

	IFZ fStart THEN RETURN

' if a browser app is found, then launch browser using url$

	IF (ret <= 32) || (defBrowserExe$ = "") THEN
		PRINT "Error : Could not find associated Browser."
	ELSE
		ret = ShellExecuteA (NULL, &"open", &defBrowserExe$, &url$, NULL, $$SW_SHOWNORMAL)
		IF url$ THEN
			IF ret <= 32 THEN
				PRINT "Web Page not Opened."
			END IF
		END IF
	END IF

END FUNCTION
END PROGRAM
