'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo creates a richedit control using either
' the riched32.dll or riched20.dll control library.
' ---
' The richedit library v2.0 is preferred and should
' be installed on most Win98+ systems.
' ---
' If riched20.dll is not installed, then the default
' riched32.dll is loaded. Note that it is not
' necessary to use IMPORT "riched20". All of the
' required declaration constants for the richedit
' controls have been added to comctl32.dec.
' ---
' Thus, it IS necessary to IMPORT "comctl32".
' The function CreateRichEdit() loads the richedit
' library dll.
'
PROGRAM	"richedit"
VERSION	"0.0002"
'
	IMPORT  "xsx"   		' Standard Extended library
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  CreateRichEdit (x, y, w, h, hParent, id, kbTextMax)
DECLARE FUNCTION  SetRichEditText (hWndRichEdit, text$, format)
DECLARE FUNCTION  EditStreamCallback (dwCookie, pbBuff, cb, pcb)

'Control IDs

$$RichEdit  = 110
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes
'	XioFreeConsole ()							' free console

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	SHARED hInst

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
FUNCTION  InitGui ()

	SHARED hInst
	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

END FUNCTION
'
'
' #################################
' #####  RegisterWinClass ()  #####
' #################################
'
FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc     = addrWndProc
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &icon$)
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = &menu$
	wc.lpszClassName   = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	RECT rc
	SHARED className$, hInst

' register window class
	className$  = "RichEditDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "RichEdit Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 300
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create richedit control
	GetClientRect (#winMain, &rc)
	w = rc.right
	h = rc.bottom
	#hRichEdit = CreateRichEdit (0, 0, w, h, #winMain, $$RichEdit, 64)

' set background color
	SendMessageA (#hRichEdit, $$EM_SETBKGNDCOLOR, 0, RGB(252, 255, 117))

' set URL autodetect - richedit 2.0+
	SendMessageA (#hRichEdit, $$EM_AUTOURLDETECT, 1, 0)

' display .rtf file in either riched32.dll or riched20.dll controls
	dir$ = "c:/xblite/demo/gui/richedit/"
	file$ = dir$ + "richedit.rtf"
	SetRichEditText (#hRichEdit, file$, $$SF_RTF)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN			' main program executes message loop

	DO
		ret = GetMessageA (&msg, 0, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
				IFZ IsDialogMessageA (#winMain, &msg) THEN
  				TranslateMessage (&msg)
  				DispatchMessageA (&msg)
				END IF
		END SELECT
	LOOP

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA(&className$, hInst)

END FUNCTION
'
'
' ###############################
' #####  CreateRichEdit ()  #####
' ###############################
'
FUNCTION  CreateRichEdit (x, y, w, h, hParent, id, kbTextMax)

	SHARED hInst

' load riched20.dll or riched32.dll if available

	class$ = "richedit20A"
	hRichEditDll = LoadLibraryA (&"riched20.dll")
	IFZ hRichEditDll THEN
		class$ = "richedit"
		hRichEditDll = LoadLibraryA (&"riched32.dll")
	END IF
	IFZ hRichEditDll THEN RETURN 0

' create rich edit child window
	style = $$WS_VISIBLE | $$WS_CHILD
	style = style | $$ES_SUNKEN | $$ES_MULTILINE
	style = style | $$WS_VSCROLL | $$WS_HSCROLL
	style = style | $$ES_AUTOHSCROLL | $$ES_AUTOVSCROLL
	style = style | $$ES_NOHIDESEL | $$ES_SAVESEL
	style = style | $$ES_WANTRETURN
'	class$ = "richedit"										' riched32.dll
'	class$ = "richedit20A"								' riched20.dll
	hRichEd =  CreateWindowExA (0, &class$, 0, style, x, y, w, h, hParent, id, hInst, 0)

' set upper limit to amount of text in rich edit control
' default upper limit is 32k, max upper is 2GB
	SendMessageA (hRichEd, $$EM_EXLIMITTEXT, 0, 1024*kbTextMax)

	RETURN hRichEd
END FUNCTION
'
'
' ################################
' #####  SetRichEditText ()  #####
' ################################

' PURPOSE : Set the text or richtext in a RichEdit control.
'           format can be $$SF_TEXT (text) or $$SF_RTF (rich text format)
'           The $$SFF_SELECTION flag is used to replace the contents of
'           the current selection.
'
FUNCTION  SetRichEditText (hWndRichEdit, fileName$, format)

	EDITSTREAM stream
	IFZ fileName$ THEN RETURN
	IFZ hWndRichEdit THEN RETURN
	IFZ format THEN format = $$SF_RTF

	hFile = CreateFileA (&fileName$, $$GENERIC_READ, $$FILE_SHARE_READ | $$FILE_SHARE_WRITE, 0, $$OPEN_EXISTING, $$FILE_ATTRIBUTE_NORMAL, 0)
	IF hFile = $$INVALID_HANDLE_VALUE THEN RETURN

	stream.dwCookie    = hFile
	stream.pfnCallback = &EditStreamCallback()
	SendMessageA (hWndRichEdit, $$EM_STREAMIN, format, &stream)
	CloseHandle (hFile)

END FUNCTION
'
'
' ###################################
' #####  EditStreamCallback ()  #####
' ###################################
'
FUNCTION  EditStreamCallback (dwCookie, pbBuff, cb, pcb)

	bytesRead = 0
	error = ReadFile (dwCookie, pbBuff, cb, &bytesRead, 0)
	XstCopyMemory (&bytesRead, pcb, 4)
	IFZ bytesRead THEN RETURN error
	RETURN $$FALSE

END FUNCTION
END PROGRAM
