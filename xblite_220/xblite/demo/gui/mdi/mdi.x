'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo creates and displays MDI child windows.
' Note that the MDI child windows display a different
' titlebar icon.
'
PROGRAM	"mdi"
VERSION	"0.0004"
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
DECLARE FUNCTION  WndProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  MDIChildWndProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  NewMenu (hWnd)
DECLARE FUNCTION  NewMDIChild (hParent, title$, x, y, w, h)
DECLARE FUNCTION  EnumChildProc (hwnd, lParam)

'Control IDs

$$FILE        = 100
$$WINDOW      = 101

$$FILE_EXIT   = 110
$$FILE_NEW	  = 111
$$WND_CASCADE = 112
$$WND_TILEV   = 113
$$WND_TILEH   = 114
$$WND_ARRANGE = 115
$$WND_RESTORE = 116
$$WND_MIN			= 117
$$WND_CLOSE		= 118

$$ID_FIRST_CHILD = 200
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
	RECT rc
	STATIC count
	PAINTSTRUCT ps

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)
			RETURN

'		CASE $$WM_CLOSE :
'			RETURN

		CASE $$WM_SIZE :
			GetClientRect (hWnd, &rc)
			MoveWindow (#hMDIClient, 0, 0, rc.right, rc.bottom, $$TRUE)
			RETURN

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE id
				CASE $$FILE_EXIT :
					DestroyWindow (hWnd)
					RETURN

				CASE $$FILE_NEW :

' keep count of child windows
					INC #childWndCount

' enable window menu
					state = GetMenuState (#hMenu, 1, $$MF_BYPOSITION)
					IF (state & $$MF_GRAYED) THEN
						EnableMenuItem (#hMenu, $$WINDOW, $$MF_BYCOMMAND | $$MF_ENABLED)
						DrawMenuBar (hWnd)
					END IF

' create MDI chile window
					title$ = "MDI Child Window"
					hMDIChild = NewMDIChild (#hMDIClient, title$, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT, $$CW_USEDEFAULT)

				CASE $$WND_CASCADE :
					SendMessageA (#hMDIClient, $$WM_MDICASCADE, 0, 0)

				CASE $$WND_TILEH :
					SendMessageA (#hMDIClient, $$WM_MDITILE, $$MDITILE_HORIZONTAL, 0)

				CASE $$WND_TILEV :
					SendMessageA (#hMDIClient, $$WM_MDITILE, $$MDITILE_VERTICAL, 0)

				CASE $$WND_ARRANGE :
					SendMessageA (#hMDIClient, $$WM_MDIICONARRANGE, 0, 0)

				CASE $$WND_RESTORE :
					EnumChildWindows (#hMDIClient, &EnumChildProc(), 0)

				CASE $$WND_MIN :
					EnumChildWindows (#hMDIClient, &EnumChildProc(), 1)

				CASE $$WND_CLOSE :
					EnumChildWindows (#hMDIClient, &EnumChildProc(), 2)

			END SELECT
	END SELECT

	RETURN DefFrameProcA (hWnd, #hMDIClient, msg, wParam, lParam)

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
	CLIENTCREATESTRUCT ccs

' register window class
	className$  = "MDIFrame"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' register and create frame window and menu bar with a Window menu item.
	title$  		= "Multiple Document Interface Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 600
	h 					= 400
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

'	register MDI client window class
	addrWndProc		= &MDIChildWndProc()
	icon$					= "window"
	menu$ 				= ""
	IF RegisterWinClass (@"CLIENT", addrWndProc, @icon$, @menu$) THEN
'		PRINT "RegisterMDIClass failure"
'		XstGetSystemError(@error)
'		XstSystemErrorNumberToName(error, @error$)
'		PRINT "ERROR : "; error$
 		RETURN ($$TRUE)
	END IF

' create a main menu
	#hMenu = NewMenu (#winMain)

' disable window menu
	EnableMenuItem (#hMenu, $$WINDOW, $$MF_BYCOMMAND | $$MF_GRAYED)
	DrawMenuBar (#winMain)

' create client MDI window, this requires a parent window
' which has a menu with a "Window" menu item

	exStyle 	= $$WS_EX_CLIENTEDGE
	title$ 		= ""
	style 		= $$WS_CHILD | $$WS_VISIBLE | $$WS_CLIPCHILDREN

' fill ccs struct with handle to window menu and first child ID
	ccs.hWindowMenu  = GetSubMenu (#hMenu, 1)
	ccs.idFirstChild = $$ID_FIRST_CHILD

	#hMDIClient = CreateWindowExA (exStyle, &"MDICLIENT", &title$, style, 0, 0, 0, 0, #winMain, 0, hInst, &ccs)

	XstCenterWindow (#winMain)								' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	  ' show window

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
				IF (! TranslateMDISysAccel(#hMDIClient, &msg)) && (! TranslateAcceleratorA (#winMain, #hAccel, &msg)) THEN
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
	UnregisterClassA(&"CLIENT", hInst)

END FUNCTION
'
'
' #############################
' #####  GetNotifyMsg ()  #####
' #############################
'
FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

	NMHDR nmhdr

	nmhdrAddr = lParam
'	XstCopyMemory (nmhdrAddr, &nmhdr, SIZE(nmhdr))	'Xst library function
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))	'kernel32 library function
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code

END FUNCTION
'
'
' ################################
' #####  MDIChildWndProc ()  #####
' ################################
'
FUNCTION  MDIChildWndProc (hWnd, msg, wParam, lParam)

	SHARED hInst

	SELECT CASE msg

		CASE $$WM_KEYUP :

' if key Ctl-F6 is pressed, then activate the next child window
        IF wParam = ($$VK_F6 & $$VK_CONTROL) THEN
            SendMessageA (#hMDIClient, $$WM_MDINEXT, 0, 0)
        END IF

		CASE $$WM_CLOSE :

' decrement child window count on close event
			DEC #childWndCount

' disable window menu when all child windows have been closed
			IFZ #childWndCount THEN
				EnableMenuItem (#hMenu, $$WINDOW, $$MF_BYCOMMAND | $$MF_GRAYED)
				DrawMenuBar (#winMain)
			END IF

	END SELECT

' The DefMDIChildProc function provides default processing
' for any window message that the window procedure of a multiple
' document interface (MDI) child window does not process.
' A window message not processed by the window procedure must
' be passed to the DefMDIChildProc function, not to the
' DefWindowProc function.

RETURN DefMDIChildProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' ########################
' #####  NewMenu ()  #####
' ########################
'
FUNCTION  NewMenu (hWnd)

	MENUITEMINFO mii

' create menus
	hMainMenu = CreateMenu ()
	hFileMenu = CreateMenu ()
	hWndMenu  = CreateMenu ()

' add subitems to file menu
	AppendMenuA (hFileMenu, $$MF_STRING,    $$FILE_NEW,     &"&New Child MDI Window")
	AppendMenuA (hFileMenu, $$MF_SEPARATOR, 0,             0)
	AppendMenuA (hFileMenu, $$MF_STRING,    $$FILE_EXIT,    &"E&xit")

' add subitems to window menu
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_CASCADE, &"&Cascade")
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_TILEH,   &"Tile &Horizontally")
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_TILEV,   &"&Tile Vertically")
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_ARRANGE, &"&Arrange Icons")
	AppendMenuA (hWndMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_RESTORE, &"&Restore All")
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_MIN,     &"&Minimize All")
	AppendMenuA (hWndMenu, $$MF_STRING,    $$WND_CLOSE,   &"C&lose All")

' attach submenus to main menubar
	InsertMenuA (hMainMenu, 0, $$MF_POPUP, hFileMenu, &"&File")
	InsertMenuA (hMainMenu, 1, $$MF_POPUP, hWndMenu,  &"&Window")

' set menu item IDs
	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_ID
	mii.wID = $$FILE
 	SetMenuItemInfoA (hMainMenu, 0, 1, &mii)

	mii.cbSize = SIZE (mii)
	mii.fMask = $$MIIM_ID
	mii.wID = $$WINDOW
 	SetMenuItemInfoA (hMainMenu, 1, 1, &mii)

' activate main menu
	IFZ SetMenu (hWnd, hMainMenu) THEN
		RETURN 0
	ELSE
		RETURN hMainMenu
	END IF



END FUNCTION
'
'
' ############################
' #####  NewMDIChild ()  #####
' ############################
'
FUNCTION  NewMDIChild (hParent, title$, x, y, w, h)

	SHARED hInst

	style       = $$WS_VISIBLE | $$MDIS_ALLCHILDSTYLES
	styleEx			= $$WS_EX_MDICHILD
	className$ 	= "CLIENT"
	RETURN CreateMDIWindowA (&className$, &title$, style, x, y, w, h, hParent, hInst, 0)

END FUNCTION
'
'
' ##############################
' #####  EnumChildProc ()  #####
' ##############################
'
FUNCTION  EnumChildProc (hwnd, lParam)

	SELECT CASE lParam
		CASE 0 :
			ShowWindow (hwnd, $$SW_RESTORE)

		CASE 1 :
			ShowWindow (hwnd, $$SW_MINIMIZE)

		CASE 2 :
			SendMessageA (#hMDIClient, $$WM_MDIDESTROY, hwnd, 0)

' set child window count to 0
			#childWndCount = 0

' disable window menu when all child windows have been closed
			EnableMenuItem (#hMenu, $$WINDOW, $$MF_BYCOMMAND | $$MF_GRAYED)
			DrawMenuBar (#winMain)
	END SELECT
	RETURN $$TRUE

END FUNCTION
END PROGRAM
