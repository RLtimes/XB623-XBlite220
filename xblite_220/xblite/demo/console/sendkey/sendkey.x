'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo which sends keystrokes to a window running in a
' separate thread. In this case, sending keystrokes
' to the xblite html help file. You must start the xblite
' html help file before running this demo.
'
PROGRAM "sendkey"
VERSION "0.0001"
CONSOLE
'
'	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
'	IMPORT  "xio"				' Console input/ouput library
	IMPORT	"gdi32"			' gdi32.dll
	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll

'
DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	' manually start the help file for xblite
	' get handle to help window
	hWnd = FindWindowA (NULL, &"XBLite Help")
	PRINT "hWnd = "; hWnd
	
	' get thread IDs
	threadOwner = GetCurrentThreadId ()
	threadHelp = GetWindowThreadProcessId (hWnd, &processId)
	
	PRINT "threadOwner="; threadOwner
	PRINT "threadHelp="; threadHelp
	
	' attach help thread to current thread
	err = AttachThreadInput (threadHelp, threadOwner, 1)
	PRINT "AttachThreadInput err="; err
	
	' set focus to help window
	SetFocus (hWnd)

	' send keystrokes to help window
	' ALT + N to get Index
	keybd_event ($$VK_MENU, MapVirtualKeyA ($$VK_MENU, 0), 0, 0)			' key down
	keybd_event ('N', MapVirtualKeyA ('N', 0), 0, 0)							
	keybd_event ('N', MapVirtualKeyA ('N', 0), $$KEYEVENTF_KEYUP, 0)	' key up
	keybd_event ($$VK_MENU, MapVirtualKeyA ($$VK_MENU, 0), $$KEYEVENTF_KEYUP, 0)
	
	' ASM
	keybd_event ('A', MapVirtualKeyA ('A', 0), 0, 0)
	keybd_event ('A', MapVirtualKeyA ('A', 0), $$KEYEVENTF_KEYUP, 0)
	keybd_event ('S', MapVirtualKeyA ('S', 0), 0, 0)
	keybd_event ('S', MapVirtualKeyA ('S', 0), $$KEYEVENTF_KEYUP, 0)
	keybd_event ('M', MapVirtualKeyA ('M', 0), 0, 0)
	keybd_event ('M', MapVirtualKeyA ('M', 0), $$KEYEVENTF_KEYUP, 0)	
	
	' Enter
	keybd_event ($$VK_RETURN, MapVirtualKeyA ($$VK_RETURN, 0), 0, 0)
	keybd_event ($$VK_RETURN, MapVirtualKeyA ($$VK_RETURN, 0), $$KEYEVENTF_KEYUP, 0)		

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM