'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo program which uses paths and regions to
' display a shaped, borderless, transparent window.
' This program is based on a BCX program by Kevin Diggins.
'
PROGRAM	"region"
VERSION	"0.0002"
'
	IMPORT	"xst"       ' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  OnEraseBkgnd (hWnd, color)
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

	RECT rc
	LOGFONT lf

	SELECT CASE msg

		CASE $$WM_CREATE:			' initialize program or create child controls here

			hDC = GetDC (hWnd)
			hFont = CreateFontA (150, 0, 0, 0, 1000, $$FALSE, $$FALSE, $$FALSE, $$ANSI_CHARSET, $$OUT_CHARACTER_PRECIS, $$CLIP_DEFAULT_PRECIS, $$PROOF_QUALITY, $$FIXED_PITCH, &"MS Sans Serif" )
  		hOldFont = SelectObject (hDC, hFont)

  		text$ = "XBLite"

			BeginPath (hDC)															' define a path object
				TextOutA (hDC, 0, 0, &text$, LEN(text$))	' path object will be outline of text
			EndPath (hDC)																' finish path construction and select it into dc

  		hRgn1 = PathToRegion (hDC)									' create a region from currently selected path
			GetRgnBox (hRgn1, &rc)											' retrieve rectangle of region
  		hRgn2 = CreateRectRgnIndirect (&rc)					' create a region from rect bounding text
			CombineRgn (hRgn2, hRgn2, hRgn1, $$RGN_XOR)	' combine text region with bounding rect using XOR
																									' try using RGN_OR or RGN_AND
			SetWindowRgn (hWnd, hRgn2, $$TRUE)					' set region of window that can be drawn

			SelectObject (hDC, hOldFont)
			DeleteObject (hRgn1)
			DeleteObject (hRgn2)
			DeleteObject (hFont)
			ReleaseDC (hWnd, hDC)

		CASE $$WM_LBUTTONDOWN:
			SendMessageA (hWnd, $$WM_DESTROY, 0, 0)

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE $$WM_ERASEBKGND:
' set window background color to red
			OnEraseBkgnd (hWnd, RGB (255, 0, 0))
			RETURN ($$TRUE)

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

	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT(0)

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
	className$  = "WindowRegionDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Region Demo"
	style 			= $$WS_CAPTION OR $$WS_SYSMENU
	w 					= 475
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
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	STATIC MSG Msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&Msg, hwnd, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN Msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
  			TranslateMessage (&Msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&Msg)						' send message to window callback function WndProc()
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
' PURPOSE : Set background color of window on WM_ERASEBKGND msg
'
' #############################
' #####  OnEraseBkgnd ()  #####
' #############################
'
FUNCTION  OnEraseBkgnd (hWnd, color)

	RECT rect
	GetClientRect (hWnd, &rect)
	hBrush = CreateSolidBrush (color)
	hdc = GetDC (hWnd)
	hOldBrush = SelectObject (hdc, hBrush)
	PatBlt (hdc, rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top, $$PATCOPY)
	SelectObject (hdc, hOldBrush)
	DeleteObject (hBrush)
	ReleaseDC (hWnd, hdc)

END FUNCTION
END PROGRAM
