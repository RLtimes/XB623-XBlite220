'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo to show how to create a popup menu.
'
PROGRAM	"popmenu"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

' user control IDs

$$Static1 = 121

$$PopUp_1      = 130
$$PopUp_2      = 131
$$PopUp_3      = 132
$$PopUp_Exit   = 134
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
	POINT pt
	RECT rc

	SELECT CASE msg

		CASE $$WM_CREATE :
' create pop-up menu
			#hPopMenu = CreatePopupMenu ()

' add menu items to pop-up menu
			AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_1,    &"&Blah")
			AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_2,    &"B&lah, Blah")
			AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_3,    &"Bla&h, Blah, Blah")
			AppendMenuA (#hPopMenu, $$MF_SEPARATOR, 0, 0)
			AppendMenuA (#hPopMenu, $$MF_STRING   , $$PopUp_Exit, &"&Exit")

' create a static text control to display some text
			text$ = "  This demo creates popup menu whenever the user "
			text$ = text$ + "presses the right mouse button inside the "
			text$ = text$ + "main window.\n\n"
			text$ = text$ + "  Note that the popup menu location is "
			text$ = text$ + "dependant upon where the mouse click "
			text$ = text$ + "occurred."
			GetClientRect (hWnd, &rc)
			#hStatic1 = NewChild ("static", text$, $$SS_LEFT, 0, 0, rc.right, rc.bottom, hWnd, $$Static1, $$WS_EX_CLIENTEDGE)

		CASE $$WM_DESTROY :
			DestroyMenu (#hPopMenu)								' delete the pop-up menu
			PostQuitMessage(0)

		CASE $$WM_RBUTTONDOWN   :
			x = LOWORD(lParam)
			y = HIWORD(lParam)
			fKeys = wParam
			pt.x = x
			pt.y = y
			ClientToScreen (hWnd, &pt)		' convert from clint coordinates to screen coordinates
   		TrackPopupMenuEx (#hPopMenu, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hWnd, 0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE id
				CASE $$PopUp_Exit :
    			DestroyWindow (hWnd)
				CASE ELSE :
					text$ = "You clicked on popup menu item " + STRING$(id)
					MessageBoxA (hWnd, &text$, &"Popup Menu Test", 0)
			END SELECT

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)
			SELECT CASE fSizeType

				CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED  :
					GetClientRect (hWnd, &rc)
					MoveWindow (#hStatic1, 0, 0, rc.right, rc.bottom, $$TRUE)

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
	className$  = "PopupMenuDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Popup Menu Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	exStyle			= 0

	#winMain = NewWindow (className$, title$, style, 0, 0, 280, 200, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

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
