'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' The function HtmlHelp() is used to start 
' an instance of a Html Help file, *.chm.
'
PROGRAM "htmlhelp"
VERSION "0.001"
CONSOLE

IMPORT "gdi32"
IMPORT "user32"
IMPORT "kernel32"
'
'
DECLARE FUNCTION  Entry ()
EXPORT
DECLARE FUNCTION  HtmlHelp (hwndCaller, file$, command, dwData)

' HTML Help Constants
$$HH_DISPLAY_TOPIC = 0x0            ' WinHelp equivalent
$$HH_DISPLAY_TOC = 0x1              ' WinHelp equivalent
$$HH_DISPLAY_INDEX = 0x2            ' WinHelp equivalent
$$HH_DISPLAY_SEARCH = 0x3           ' WinHelp equivalent
$$HH_SET_WIN_TYPE = 0x4
$$HH_GET_WIN_TYPE = 0x5
$$HH_GET_WIN_HANDLE = 0x6
$$HH_SYNC = 0x9
$$HH_ADD_NAV_UI = 0xA               ' not currently implemented
$$HH_ADD_BUTTON = 0xB               ' not currently implemented
$$HH_GETBROWSER_APP = 0xC           ' not currently implemented
$$HH_KEYWORD_LOOKUP = 0xD           ' WinHelp equivalent
$$HH_DISPLAY_TEXT_POPUP = 0xE       ' display string resource id
                                    ' or text in a popup window
                                    ' value in dwData
$$HH_HELP_CONTEXT = 0xF             ' display mapped numeric
$$HH_CLOSE_ALL = 0x12               ' WinHelp equivalent
$$HH_ALINK_LOOKUP = 0x13            ' ALink version of
                                    ' HH_KEYWORD_LOOKUP
$$HH_SET_GUID = 0x1A                ' For Microsoft Installer -- dwData is a pointer to the GUID string
END EXPORT
' 
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

  IF LIBRARY(0) THEN RETURN

  file$ = "C:\\xblite\\manual\\xblite_manual.chm"
  keyword$ = "EXPORT"
  HtmlHelp (0, file$, $$HH_DISPLAY_INDEX, &keyword$)

	a$ = INLINE$ ("Press any key to quit >")
END FUNCTION
' 
'
' #########################
' #####  HtmlHelp ()  #####
' #########################
'
FUNCTION HtmlHelp (hwndCaller, file$, command, dwData)

FUNCADDR HHelp (XLONG, XLONG, XLONG, XLONG)

	hhctrl = LoadLibraryA (&"hhctrl.ocx")
	IFZ hhctrl THEN
		error$ = "Error : LoadLibraryA : hhctrl.ocx"
		GOSUB ErrorFound
	END IF
	
' get function addresses

	HHelp = GetProcAddress (hhctrl, &"HtmlHelpA")
	IFZ HHelp THEN
		error$ = "Error : GetProcAddress : HtmlHelpA"
		GOSUB ErrorFound
	END IF

' call the function
  ret = @HHelp (hwndCaller, &file$, command, dwData)
  
' free ocx library
	FreeLibrary (hhctrl)
	
  RETURN ret
	
' ***** ErrorFound *****
SUB ErrorFound
	MessageBoxA (NULL, &error$, &"HtmlHelp() Error", 0)
'	PRINT error$
 	RETURN ($$TRUE)
END SUB

END FUNCTION
END PROGRAM
