'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo shows how to load/use various cursors.
'
PROGRAM	"cursors"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

'Control IDs

$$Static1 = 100
$$Static2 = 101
$$Static3 = 102
$$Static4 = 103
$$Static5 = 104
$$Static6 = 105
$$Static7 = 106
$$Static8 = 107

$$Statusbar = 120
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
	SHARED RECT rect1, rect2, rect3, rect4
	SHARED RECT rect5, rect6, rect7, rect8

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_MOUSEMOVE :
			xPos = LOWORD (lParam)
			yPos = HIWORD (lParam)

			SELECT CASE TRUE
				CASE PtInRect (&rect1, xPos, yPos) : SetCursor (#hCross) 	: rect$ = " : Static1"
				CASE PtInRect (&rect2, xPos, yPos) : SetCursor (#hIbeam) 	: rect$ = " : Static2"
				CASE PtInRect (&rect3, xPos, yPos) : SetCursor (#hSizeAll) : rect$ = " : Static3"
				CASE PtInRect (&rect4, xPos, yPos) : SetCursor (#hWait) 	: rect$ = " : Static4"
				CASE PtInRect (&rect5, xPos, yPos) : SetCursor (#hHand0) 	: rect$ = " : Static5"
				CASE PtInRect (&rect6, xPos, yPos) : SetCursor (#hHand1) 	: rect$ = " : Static6"
				CASE PtInRect (&rect7, xPos, yPos) : SetCursor (#hHSplit) : rect$ = " : Static7"
				CASE PtInRect (&rect8, xPos, yPos) : SetCursor (#hVSplit) : rect$ = " : Static8"
			END SELECT

			xPos$ = FORMAT$("####", xPos)
			yPos$ = FORMAT$("####", yPos)
			text$ = "WM_MOUSEMOVE : x = " + xPos$ + " y = " + yPos$ + rect$
			SetWindowTextA (#hStatus, &text$)

		CASE $$WM_SIZE :
			SendMessageA (#hStatus, $$WM_SIZE, wParam, lParam)		' send resize msg to statusbar

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

	SHARED hInst, className$
	SHARED RECT rect1, rect2, rect3, rect4
	SHARED RECT rect5, rect6, rect7, rect8

' register window class
	className$  = "CursorDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Cursor Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 540
	h 					= 280
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' display system cursors in static controls
' create a few static controls
	style = $$SS_CENTER | $$SS_SUNKEN
	#hStatic1 = NewChild ("static", "IDC_CROSS", style, 10,  10, 120, 100, #winMain, $$Static1, 0)
	#hStatic2 = NewChild ("static", "IDC_IBEAM", style, 140, 10, 120, 100, #winMain, $$Static2, 0)
	#hStatic3 = NewChild ("static", "IDC_SIZEALL", style, 270, 10, 120, 100, #winMain, $$Static3, 0)
	#hStatic4 = NewChild ("static", "IDC_WAIT",  style, 400, 10, 120, 100, #winMain, $$Static4, 0)

' assign some rect structures for the static controls
	GetWindowRect (#hStatic1, &rect1)
	MapWindowPoints (0, #winMain, &rect1, 2)
	GetWindowRect (#hStatic2, &rect2)
	MapWindowPoints (0, #winMain, &rect2, 2)
	GetWindowRect (#hStatic3, &rect3)
	MapWindowPoints (0, #winMain, &rect3, 2)
	GetWindowRect (#hStatic4, &rect4)
	MapWindowPoints (0, #winMain, &rect4, 2)

' load predefined Win32 system cursors
	#hCross 	= LoadCursorA (0, $$IDC_CROSS)
	#hIbeam 	= LoadCursorA (0, $$IDC_IBEAM)
	#hSizeAll = LoadCursorA (0, $$IDC_SIZEALL)
	#hWait 		= LoadCursorA (0, $$IDC_WAIT)

' display resource cursors in static controls
' create a few more static controls
	style = $$SS_CENTER | $$SS_SUNKEN
	#hStatic5 = NewChild ("static", "HAND0", 	style, 10,  120, 120, 100, #winMain, $$Static5, 0)
	#hStatic6 = NewChild ("static", "HAND1", 	style, 140, 120, 120, 100, #winMain, $$Static6, 0)
	#hStatic7 = NewChild ("static", "HSPLIT", style, 270, 120, 120, 100, #winMain, $$Static7, 0)
	#hStatic8 = NewChild ("static", "VSPLIT", style, 400, 120, 120, 100, #winMain, $$Static8, 0)

' assign some rect structures for the static controls
	GetWindowRect (#hStatic5, &rect5)
	MapWindowPoints (0, #winMain, &rect5, 2)
	GetWindowRect (#hStatic6, &rect6)
	MapWindowPoints (0, #winMain, &rect6, 2)
	GetWindowRect (#hStatic7, &rect7)
	MapWindowPoints (0, #winMain, &rect7, 2)
	GetWindowRect (#hStatic8, &rect8)
	MapWindowPoints (0, #winMain, &rect8, 2)

' load resource cursors from executable
	#hHand0 	= LoadCursorA (hInst, &"hand0")
	#hHand1		= LoadCursorA (hInst, &"hand1")
	#hHSplit 	= LoadCursorA (hInst, &"hsplit")
	#hVSplit 	= LoadCursorA (hInst, &"vsplit")

' create statusbar window with one part
	#hStatus = NewChild ($$STATUSCLASSNAME, "WM_MOUSEMOVE :", $$SBARS_SIZEGRIP, 0, 0, 0, 0, #winMain, $$Statusbar, 0)

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
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
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
END PROGRAM
