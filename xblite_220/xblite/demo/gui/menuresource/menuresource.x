'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo program which creates a menu from a
' resource file and displays info about each
' menu item in the statusbar. Menu help text
' strings are stored in the resource file as
' string resources. The text is retrieved
' using LoadString().
'
PROGRAM	"menuresource"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
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

' Menubar control IDs
$$ID_FILE_NEW					= 100
$$ID_FILE_OPEN				= 101
$$ID_FILE_CLOSE				= 102
$$ID_FILE_SAVE				= 103
$$ID_FILE_SAVE_AS			= 104
$$ID_FILE_EXIT				= 105
$$ID_FILE_MRU_FILE1		= 106
$$ID_FILE_MRU_FILE2		= 107
$$ID_FILE_MRU_FILE3		= 108
$$ID_FILE_MRU_FILE4		= 109
$$ID_FILE_MRU_FILE5		= 110
$$ID_FILE_MRU_FILE6		= 111
$$ID_FILE_MRU_FILE7		= 112
$$ID_FILE_MRU_FILE8		= 113
$$ID_FILE_MRU_FILE9		= 114
$$ID_FILE_MRU_FILE10	= 115

$$ID_EDIT_UNDO				= 120
$$ID_EDIT_REDO				= 121
$$ID_EDIT_CUT					= 122
$$ID_EDIT_COPY 				= 123
$$ID_EDIT_PASTE				= 124
$$ID_EDIT_CLEAR				= 125
$$ID_EDIT_CLEAR_ALL		= 126
$$ID_EDIT_SELECT_ALL	= 127
$$ID_EDIT_FIND				= 128
$$ID_EDIT_FIND_NEXT		= 129
$$ID_EDIT_REPLACE			= 130

$$ID_APP_ABOUT				= 200

$$STATUSBAR						= 300
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

		CASE $$WM_CREATE:
' 		create statusbar window with one part
			#statusBar = NewChild ($$STATUSCLASSNAME, "Menubar item descriptions", $$SBARS_SIZEGRIP, 0, 0, 0, 0, hWnd, $$STATUSBAR, 0)

		CASE $$WM_MENUSELECT:
			item = LOWORD(wParam)
			IF (HIWORD(wParam) == 0xFFFF && !lParam) THEN				' menu has closed
				text$ = ""
			ELSE
				text$ = NULL$(256)
				LoadStringA (hInst, item, &text$, LEN(text$))			' load resource string
			END IF
			SendMessageA (#statusBar, $$WM_SETTEXT, 0, &text$)	' set text in statusbar

		CASE $$WM_SIZE:
			SendMessageA(#statusBar, $$WM_SIZE, wParam, lParam)		' send resize msg to statusbar

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE $$WM_COMMAND:
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$ID_FILE_EXIT:
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

	SHARED hInst, className$

' register window class
	className$  = "MenuDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menubar"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Menu & Statusbar demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 350
	h 					= 350
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	UpdateWindow (#winMain)
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

	style = style | $$WS_CHILD
	hwnd = CreateWindowExA (0, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)
	ShowWindow (hwnd, $$SW_SHOWNORMAL)
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

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
  			TranslateMessage (&msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
END PROGRAM
