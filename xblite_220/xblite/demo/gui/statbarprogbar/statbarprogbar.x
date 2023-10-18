'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of the statusbar control with
' two progress bars.
'
PROGRAM	"statbarprogbar"
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
DECLARE FUNCTION  ResizeProgressBar (hProgBar, hStatusBar, partID)

'Control IDs

$$Statusbar = 101
$$ProgBar1  = 102
$$ProgBar2  = 103

$$Menu_File_PB1 = 110
$$Menu_File_PB2 = 111
$$Menu_File_Exit = 112
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

		CASE $$WM_CREATE :

' build a main menu
			#mainMenu = CreateMenu()				' create main menu

' build dropdown submenus
			#fileMenu = CreateMenu()				' create dropdown file menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_PB1,  &"Start Progressbar 1")
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_PB2,  &"Start Progressbar 2")
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

			SetMenu (hWnd, #mainMenu)						' activate the menu

' create a statusbar window with 2 parts
			#statusBar = NewStatusBar (hWnd, $$Statusbar, 2)

' create 2 progress bars with statusbar as parent
' don't display them yet

			style = $$WS_CHILD
			text$ = ""
			#hProgressBar1 = CreateWindowExA (0, &$$PROGRESS_CLASS, &text$, style, x, y, w, h, #statusBar, $$ProgBar1, hInst, 0)
			#hProgressBar2 = CreateWindowExA (0, &$$PROGRESS_CLASS, &text$, style | $$PBS_SMOOTH, x, y, w, h, #statusBar, $$ProgBar2, hInst, 0)

			SendMessageA (#hProgressBar1, $$PBM_SETSTEP, 1, 0)		' set step increment
			SendMessageA (#hProgressBar2, $$PBM_SETSTEP, 1, 0)		' set step increment

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			SendMessageA(#statusBar, $$WM_SIZE, wParam, lParam)		' send resize msg to statusbar
			ResizeProgressBar (#hProgressBar1, #statusBar, 0)
			ResizeProgressBar (#hProgressBar2, #statusBar, 1)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$Menu_File_PB1 :
					FOR i = 0 TO 100
						SendMessageA (#hProgressBar1, $$PBM_STEPIT, 0, 0)	' advance current position by step increment
						Sleep (40)
					NEXT i
					SendMessageA (#hProgressBar1, $$PBM_SETPOS, 0, 0)		' reset current position to 0

				CASE $$Menu_File_PB2 :
					FOR i = 0 TO 100
						SendMessageA (#hProgressBar2, $$PBM_STEPIT, 0, 0)	' advance current position by step increment
						Sleep (40)
					NEXT i
					SendMessageA (#hProgressBar2, $$PBM_SETPOS, 0, 0)		' reset current position to 0

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
	className$  = "StatusBarProgBar"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "StatusBar w/ Progress Bars."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 400
	h 					= 150
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
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

	STATIC MSG Msg

' main message loop

	IF LIBRARY(0) THEN RETURN			' main program executes message loop

	DO
		ret = GetMessageA (&Msg, hwnd, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN Msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&Msg)
  			DispatchMessageA (&Msg)
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
'
'
' ##################################
' #####  ResizeProgressBar ()  #####
' ##################################
'
' Resize and reposition progress bar within status bar part
' Status bar parts are zero-based
'
FUNCTION  ResizeProgressBar (hProgBar, hStatusBar, partID)

	RECT rect

	SendMessageA (hStatusBar, $$SB_GETRECT, partID, &rect)
'	InflateRect (&rect, -1, -1)
	MoveWindow (hProgBar, rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top, $$TRUE)
	ShowWindow (hProgBar, $$SW_SHOW)

END FUNCTION
END PROGRAM
