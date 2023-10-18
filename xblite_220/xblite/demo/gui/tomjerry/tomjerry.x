'
'
' ####################
' #####  PROLOG  #####
' ####################

' Tom and Jerry demo
' Tom's eyes will follow your mouse cursor
' as you move it around the desktop.
' Demonstrates how to draw a masked image
' and also move it (sprite demo).
'	based on BCX version by Alessio Ribeca
' or see http://www.cwinapp.com/tutorials/045.asp
'
PROGRAM	"tomjerry"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"

TYPE EYEBALL
	XLONG	.x
	XLONG	.y
	XLONG	.rx
	XLONG	.ry
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  MoveEye (EYEBALL eb)

$$WIN_WIDTH    = 225
$$WIN_HEIGHT   = 225
$$PUPIL_WIDTH  = 14
$$PUPIL_HEIGHT = 22
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
	SHARED hbmSource, hdcSource
	SHARED hbmOffSrceen, hdcOffScreen
	SHARED POINT ptCursor
	SHARED EYEBALL ebLeft, ebRight
	PAINTSTRUCT ps
	POINT ptCurrentCursor

	SELECT CASE msg

		CASE $$WM_CREATE :

			hbmSource = LoadBitmapA (hInst, &"taj")
			hdc = GetDC (hWnd)
			hdcSource = CreateCompatibleDC (hdc)
			ReleaseDC (hWnd, hdc)
			SelectObject (hdcSource, hbmSource)

			hbmOffScreen = CreateCompatibleBitmap (hdcSource, $$WIN_WIDTH, $$WIN_HEIGHT)
			hdcOffScreen = CreateCompatibleDC (hdcSource)
			SelectObject (hdcOffScreen, hbmOffScreen)

			ptCursor.x = -1
			ptCursor.y = -1
			ebLeft.x = 139
			ebLeft.y = 114
			ebLeft.rx = 13 - ($$PUPIL_WIDTH / 2.0)
			ebLeft.ry = 29 - ($$PUPIL_HEIGHT / 2.0)
			ebRight.x = 175
			ebRight.y = 117
			ebRight.rx = 11 - ($$PUPIL_WIDTH / 2.0)
			ebRight.ry = 27 - ($$PUPIL_HEIGHT / 2.0)

			SetTimer (hWnd, 1, 1, NULL)

		CASE $$WM_PAINT :
			hdc = BeginPaint (hWnd, &ps)
			BitBlt (hdc, 0, 0, $$WIN_WIDTH, $$WIN_HEIGHT, hdcOffScreen, 0, 0, $$SRCCOPY)
			EndPaint (hWnd, &ps)

		CASE $$WM_TIMER :
			GetCursorPos (&ptCurrentCursor)
			ScreenToClient (hWnd, &ptCurrentCursor)

			IF (ptCurrentCursor.x <> ptCursor.x) || (ptCurrentCursor.y <> ptCursor.y) THEN
				ptCursor = ptCurrentCursor
				StretchBlt (hdcOffScreen, 0, 0, $$WIN_WIDTH, $$WIN_HEIGHT, hdcSource, 0, 0, $$WIN_WIDTH, $$WIN_HEIGHT, $$SRCCOPY)
				MoveEye (ebLeft)
				MoveEye (ebRight)
				RedrawWindow (hWnd, NULL, NULL, $$RDW_INVALIDATE)
			END IF

		CASE $$WM_NCHITTEST :
			rc = DefWindowProcA (hWnd, msg, wParam, lParam)
			IF rc = $$HTCLIENT THEN rc = $$HTCAPTION
			RETURN rc

		CASE $$WM_CLOSE :
			DestroyWindow (hWnd)

		CASE $$WM_DESTROY :
			KillTimer (hWnd, 1)
			DeleteDC (hdcSource)
			DeleteObject (hbmSource)
			DeleteDC (hdcOffScreen)
			DeleteObject (hbmOffScreen)
			PostQuitMessage (0)

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

	hInst = GetModuleHandleA (0)		' get current instance handle
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
	className$  = "TomJerry"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Tom & Jerry."
	style 			= $$WS_POPUPWINDOW | $$WS_CAPTION
	w 					= $$WIN_WIDTH + 6
	h 					= $$WIN_HEIGHT + 25
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

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

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
'
'
' ########################
' #####  MoveEye ()  #####
' ########################
'
FUNCTION  MoveEye (EYEBALL eb)

	SHARED POINT ptCursor
	SHARED hdcOffScreen, hdcSource

  lx = eb.x
  ly = eb.y
  ldx = ptCursor.x - eb.x
  ldy = ptCursor.y - eb.y

  ldxy = sqrt((ldx*ldx) + (ldy*ldy))

  IF ldxy <> 0 THEN
    lx = lx + (eb.rx * ldx / DOUBLE(ldxy))
    ly = ly + (eb.ry * ldy / DOUBLE(ldxy))
  END IF

  lx = lx - $$PUPIL_WIDTH / 2.0
  ly = ly - $$PUPIL_HEIGHT / 2.0

' draw mask to memory bitmap using AND
  StretchBlt (hdcOffScreen, lx, ly, $$PUPIL_WIDTH, $$PUPIL_HEIGHT, hdcSource, $$WIN_WIDTH, $$PUPIL_HEIGHT, $$PUPIL_WIDTH, $$PUPIL_HEIGHT, $$SRCAND)

' draw pupil to memory bitmap using XOR
  StretchBlt (hdcOffScreen, lx, ly, $$PUPIL_WIDTH, $$PUPIL_HEIGHT, hdcSource, $$WIN_WIDTH, 0, $$PUPIL_WIDTH, $$PUPIL_HEIGHT, $$SRCINVERT)

END FUNCTION
END PROGRAM
