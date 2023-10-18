'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program uses a function in urlmon.dll to download
' internet files. You must have IE4.0+ installed to use
' this library function.
'
PROGRAM	"download"
VERSION	"0.0002"
CONSOLE
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"gdi32"
	IMPORT	"user32"
	IMPORT	"kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  DownloadURLToFile (url$, file$)
DECLARE FUNCTION  DownloadYahooGroupsMessage (groupName$, msg, file$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	url$ = "http://perso.wanadoo.fr/xblite/"
	file$ = "xblitesite.html"
	PRINT "Downloading :: " + url$
	ret = DownloadURLToFile (url$, file$)
	PRINT "DownloadURLToFile ret="; ret

	url$ = "http://www.xbasic.org/"
	file$ = "xbasicsite.html"
	PRINT "Downloading :: " + url$
	ret = DownloadURLToFile (url$, file$)
	PRINT "DownloadURLToFile ret="; ret

	PRINT
	PRINT "Check the current directory for downloaded files."
	PRINT

	a$ = INLINE$ ("Press RETURN to QUIT >")

	RETURN

END FUNCTION
'
'
' ##################################
' #####  DownloadURLToFile ()  #####
' ##################################
'
FUNCTION  DownloadURLToFile (url$, file$)

	FUNCADDR	Download (XLONG, XLONG, XLONG, XLONG, XLONG)

'load urlmon.dll library
	hUrlmon = LoadLibraryA (&"urlmon.dll")
	IFZ hUrlmon THEN RETURN

'get function address for URLDownloadToFileA
	Download = GetProcAddress (hUrlmon, &"URLDownloadToFileA")

'call the function
	ret = @Download (0, &url$, &file$, 0, 0)

'free the dll
	FreeLibrary (hUrlmon)

	RETURN ret

END FUNCTION
'
'
' ###########################################
' #####  DownloadYahooGroupsMessage ()  #####
' ###########################################
'
' Deprecated function. No longer works on yahoo.com.
'
FUNCTION  DownloadYahooGroupsMessage (groupName$, msg, file$)

	url$ = "http://groups.yahoo.com/group/" + groupName$ + "/message/" + STRING$(msg)
	RETURN DownloadURLToFile (url$, file$)

END FUNCTION
END PROGRAM
