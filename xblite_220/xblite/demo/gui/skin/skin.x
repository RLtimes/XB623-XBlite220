'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' skin.x is based on BmpBitBlt.x
' example program provided by Michael McE.
'
PROGRAM	"skin"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
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
DECLARE FUNCTION  SkinMe (dc)
DECLARE FUNCTION  RegionMe (hwnd)
DECLARE FUNCTION  UnRegionMe (hwnd)
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
	PAINTSTRUCT ps
	SHARED hSkinBmp, hOldBmp, dcSkin
	SHARED bRegioned

	SELECT CASE msg

		CASE $$WM_PAINT:
			BeginPaint (hWnd, &ps)
				IF bRegioned THEN SkinMe (ps.hdc)
				SetBkMode (ps.hdc, $$TRANSPARENT)
      	SetTextColor (ps.hdc, RGB(100, 50, 250))
      	IFZ bRegioned THEN TextOutA (ps.hdc, 100, 90, &"Press the Spacebar", 18)
			EndPaint (hWnd, &ps)

		CASE $$WM_DESTROY:
			SelectObject (dcSkin, hOldBmp)
			DeleteObject (hSkinBmp)
			DeleteObject (dcSkin)
			PostQuitMessage (0)

		CASE $$WM_KEYDOWN:
			SELECT CASE wParam
				CASE $$VK_SPACE :
					IFZ bRegioned THEN
						RegionMe (hWnd)
					ELSE
						UnRegionMe (hWnd)
					END IF
			END SELECT

		CASE $$WM_LBUTTONDOWN:
			IF bRegioned THEN
		  SendMessageA (hWnd, $$WM_NCLBUTTONDOWN, $$HTCAPTION, 0)
		  END IF

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
	SHARED hSkinBmp,dcSkin,hOldBmp
	SHARED hInst
	SHARED bRegioned

	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT(0)

	hSkinBmp = LoadBitmapA (hInst, &"IDB_SKIN")
	dcSkin = CreateCompatibleDC (0)
	hOldBmp = SelectObject (dcSkin, hSkinBmp)
	bRegioned = 0

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

	SHARED className$, hInst

' register window class
	className$  = "win32skin"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "win32skin"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 320
	h 					= 240
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

FUNCTION SkinMe(dc)
	SHARED dcSkin

' Now were blitting it (putting it to the screen)
	BitBlt (dc, 0, 0, 320, 240, dcSkin, 0, 0, $$SRCCOPY)

END FUNCTION


' We'll build a basic region, then set it to the window

FUNCTION RegionMe (hwnd)

	SHARED bRegioned

	hRegion1 = CreateEllipticRgn (20, -20, 190, 150)
	OffsetRgn (hRegion1, GetSystemMetrics ($$SM_CXBORDER)* 4, GetSystemMetrics ($$SM_CYCAPTION))
	hRegion2 = CreateEllipticRgn(142, 102, 290, 230)
	OffsetRgn(hRegion2, GetSystemMetrics ($$SM_CXBORDER)* 4, GetSystemMetrics ($$SM_CYCAPTION))

	CombineRgn (hRegion1, hRegion1, hRegion2, $$RGN_OR)
	SetWindowRgn (hwnd, hRegion1, $$TRUE)

	DeleteObject (hRegion1)
	DeleteObject (hRegion2)

	dwStyle = GetWindowLongA (hwnd, $$GWL_STYLE)
	dwStyle = dwStyle & ~($$WS_CAPTION | $$WS_SIZEBOX)
	SetWindowLongA (hwnd, $$GWL_STYLE, dwStyle)

	InvalidateRect (hwnd, 0, $$TRUE)
	SetWindowPos (hwnd, 0, 0, 0, 320, 242, $$SWP_NOMOVE | $$SWP_NOSIZE | $$SWP_NOZORDER | $$SWP_FRAMECHANGED)

	bRegioned = 1

END FUNCTION

FUNCTION UnRegionMe(hwnd)
	SHARED bRegioned


	SetWindowRgn (hwnd, 0, 1)

	dwStyle = GetWindowLongA (hwnd, $$GWL_STYLE)
	dwStyle = dwStyle | $$WS_CAPTION | $$WS_SIZEBOX
	SetWindowLongA (hwnd, $$GWL_STYLE, dwStyle)

	InvalidateRect (hwnd, 0, 1)
    SetWindowPos (hwnd, 0, 0, 0, 0, 0, $$SWP_NOMOVE | $$SWP_NOSIZE | $$SWP_NOZORDER | $$SWP_FRAMECHANGED)
	bRegioned = 0


END FUNCTION
END PROGRAM
