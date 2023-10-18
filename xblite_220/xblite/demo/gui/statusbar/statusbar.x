'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of the statusbar control.
'
PROGRAM	"statusbar"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewStatusBar (hwndParent, statusID, parts)

'Control IDs

$$Statusbar = 101

$$Menu_File_Exit = 110
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

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			SendMessageA(#statusBar, $$WM_SIZE, wParam, lParam)		' send resize msg to statusbar

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$Menu_File_Exit :
					PostQuitMessage(0)

			END SELECT

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

	SHARED className$

' register window class
	className$  = "StatusBarControl"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "StatusBar Control."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 150
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' build a main menu
	#mainMenu = CreateMenu()				' create main menu

' build dropdown submenus
	#fileMenu = CreateMenu()				' create dropdown file menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

	SetMenu (#winMain, #mainMenu)						' activate the menu

' create statusbar window with one part
'	#statusBar = NewChild ($$STATUSCLASSNAME, @"Statusbar text", $$SBARS_SIZEGRIP, 0, 0, 0, 0, #winMain, $$Statusbar, 0)

' create a statusbar window with 3 parts
	#statusBar = NewStatusBar (#winMain, $$Statusbar, 3)

' set text in status bar parts, center text in each part using \t
	SendMessageA (#statusBar, $$SB_SETTEXT, 0, &"\tPart 1 Text")									' normal border
	SendMessageA (#statusBar, $$SB_SETTEXT, 1 | $$SBT_NOBORDERS, &"\tPart 2 Text")' no border
	SendMessageA (#statusBar, $$SB_SETTEXT, 2 | $$SBT_POPOUT, &"\tPart 3 Text")		' raised border

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
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

	RETURN hwnd

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
		ret = GetMessageA (&msg, NULL, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
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
' #############################
' #####  NewStatusBar ()  #####
' #############################
'
FUNCTION  NewStatusBar (hwndParent, statusID, parts)

	SHARED hInst
	RECT rcClient

' create the status window
	hwndStatus = CreateStatusWindow ($$SBARS_SIZEGRIP | $$WS_CHILD | $$WS_VISIBLE, 0, hwndParent, statusID)

' get the coordinates of the parent window's client area
	GetClientRect(hwndParent, &rcClient)

' create an array for holding the right edge cooordinates
	REDIM position[parts-1]

' calculate the right edge coordinate for each part, and
' copy the coordinates to the array
	width = rcClient.right / parts
	FOR i = 0 TO parts-1
		position[i] = width + (i * width)
		IF i = parts-1 THEN position[i] = $$TRUE
	NEXT i

' create the statusbar parts
	SendMessageA (hwndStatus, $$SB_SETPARTS, parts, &position[])

	DIM position[]

	RETURN hwndStatus

END FUNCTION
END PROGRAM
