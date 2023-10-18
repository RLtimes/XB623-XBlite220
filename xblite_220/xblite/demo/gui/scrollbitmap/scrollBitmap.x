'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This example program captures the screen
' into a bitmap and then allows the user to
' scroll the bitmap in the resizable client area.
'
'
PROGRAM	"scrollBitmap"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "msvcrt"    ' msvcrt.dll
  IMPORT  "comdlg32"	' comdlg32.dll
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
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry

	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	IF CreateWindows ()	THEN QUIT (0)	' create windows and other child controls
	MessageLoop ()								' the main message loop
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

	STATIC PAINTSTRUCT ps
	STATIC SCROLLINFO si

' These variables are required by BitBlt.

	STATIC hdcWin           ' window DC
	STATIC hdcScreen        ' DC for entire screen
	STATIC hdcScreenCompat  ' memory DC for screen
	STATIC hbmpCompat       ' bitmap handle for old DC
	STATIC BITMAP bmp       ' bitmap data structure
	STATIC fBlt             ' TRUE if BitBlt occurred

	STATIC fScroll          ' TRUE if scrolling occurred
	STATIC fSize            ' TRUE if fBlt & WM_SIZE

' These variables are required for horizontal scrolling.

	STATIC xMinScroll       ' minimum horizontal scroll value
	STATIC xCurrentScroll   ' current horizontal scroll value
	STATIC xMaxScroll       ' maximum horizontal scroll value
	STATIC xNewSize         ' current size of client window

' These variables are required for vertical scrolling.

	STATIC yMinScroll       ' minimum vertical scroll value
	STATIC yCurrentScroll   ' current vertical scroll value
	STATIC yMaxScroll       ' maximum vertical scroll value
	STATIC yNewSize         ' current size of client window

	SELECT CASE msg

		CASE $$WM_CREATE :

' Create a normal DC and a memory DC for the entire
' screen. The normal DC provides a snapshot of the
' screen contents. The memory DC keeps a copy of this
' snapshot in the associated bitmap.

			hdcScreen = CreateDCA(&"DISPLAY", 0, 0, 0)
			hdcScreenCompat = CreateCompatibleDC(hdcScreen)

' Retrieve the metrics for the bitmap associated with the
' regular device context.

			bmp.bitsPixel = GetDeviceCaps(hdcScreen, $$BITSPIXEL)
			bmp.planes    = GetDeviceCaps(hdcScreen, $$PLANES)
			bmp.width     = GetDeviceCaps(hdcScreen, $$HORZRES)
			bmp.height    = GetDeviceCaps(hdcScreen, $$VERTRES)

' The width must be byte-aligned.
			bmp.widthBytes = ((bmp.width + 15) &~15)/8

' Create a bitmap for the compatible DC.
			hbmpCompat = CreateBitmap(bmp.width, bmp.height, bmp.planes, bmp.bitsPixel, 0)

' Select the bitmap for the compatible DC.
			SelectObject(hdcScreenCompat, hbmpCompat)

' Copy the contents of the current screen
' into the compatible DC.
			BitBlt(hdcScreenCompat, 0, 0, bmp.width, bmp.height, hdcScreen, 0, 0, $$SRCCOPY)

' Copy the compatible DC to the client area.
			hdcWin = GetDC(#winMain)
			BitBlt(hdcWin, 0, 0, bmp.width, bmp.height, hdcScreenCompat, 0, 0, $$SRCCOPY)
			ReleaseDC(#winMain, hdcWin)

			fBlt = $$TRUE

		CASE $$WM_DESTROY :
			DeleteDC(hdcScreen)
			DeleteDC(hdcScreenCompat)
			DeleteObject(hbmpCompat)
			PostQuitMessage(0)

		CASE $$WM_PAINT :
			hdc = BeginPaint(hWnd, &ps)

' If the window has been resized and the user has
' captured the screen, use the following call to
' BitBlt to paint the window's client area.

			IF (fSize) THEN
				BitBlt(ps.hdc, 0, 0, bmp.width, bmp.height, hdcScreenCompat, xCurrentScroll, yCurrentScroll, $$SRCCOPY)
				fSize = $$FALSE
			END IF

' If scrolling has occurred, use the following call to
' BitBlt to paint the invalid rectangle.
'
' The coordinates of this rectangle are specified in the
' RECT structure elements to which ps points.
'
' Note that it is necessary to increment the seventh
' argument (ps->left) by xCurrentScroll and the
' eighth argument (ps->top) by yCurrentScroll in
' order to map the correct pixels from the source bitmap.

			IF (fScroll) THEN
				BitBlt(ps.hdc, ps.left, ps.top, (ps.right - ps.left), (ps.bottom - ps.top), hdcScreenCompat, ps.left + xCurrentScroll, ps.top + yCurrentScroll, $$SRCCOPY)
				fScroll = $$FALSE
			END IF

			EndPaint(hWnd, &ps)


'		CASE $$WM_COMMAND :
'			controlID = LOWORD(wParam)
'			notifyCode = HIWORD(wParam)
'			hwndCtl = lParam
'			SELECT CASE notifyCode
'			END SELECT

		CASE $$WM_SIZE :

			xNewSize = LOWORD(lParam)
			yNewSize = HIWORD(lParam)

			IF (fBlt) THEN fSize = $$TRUE

			xMaxScroll = bmp.width-1
			xMinScroll = 0
			xCurrentScroll = 0  									' reset xCurrentScroll to 0 after resize event
			si.cbSize = SIZE(si)
			si.fMask  = $$SIF_RANGE | $$SIF_PAGE | $$SIF_POS
			si.nMin   = xMinScroll
			si.nMax   = xMaxScroll
			si.nPage  = xNewSize
			si.nPos   = xCurrentScroll
			SetScrollInfo(hWnd, $$SB_HORZ, &si, $$TRUE)

			yMaxScroll = bmp.height-1
			yMinScroll = 0
			yCurrentScroll = 0										' reset yCurrentScroll to 0 after resize event
			si.cbSize = SIZE(si)
			si.fMask  = $$SIF_RANGE | $$SIF_PAGE | $$SIF_POS
			si.nMin   = yMinScroll
			si.nMax   = yMaxScroll
			si.nPage  = yNewSize
			si.nPos   = yCurrentScroll
			SetScrollInfo(hWnd, $$SB_VERT, &si, $$TRUE)

		CASE $$WM_HSCROLL :
			yDelta = 0
			SELECT CASE (LOWORD(wParam))				' scroll bar notify value
				CASE $$SB_PAGEUP:									' User clicked left of the scroll bar.
					xNewPos = xCurrentScroll - 50

				CASE $$SB_PAGEDOWN:								' User clicked right of the scroll bar.
					xNewPos = xCurrentScroll + 50

				CASE $$SB_LINEUP:									' User clicked the left arrow.
					xNewPos = xCurrentScroll - 5

				CASE $$SB_LINEDOWN:								' User clicked the right arrow.
					xNewPos = xCurrentScroll + 5

				CASE $$SB_THUMBPOSITION:					' User dragged the scroll box.
					xNewPos = HIWORD(wParam)

				CASE ELSE:
					xNewPos = xCurrentScroll
 			END SELECT

			xNewPos = MAX(0, xNewPos)						' Max new position must be between 0 and the client screen width.
			xNewPos = MIN(xMaxScroll-xNewSize+1, xNewPos)

			IF (xNewPos == xCurrentScroll) THEN RETURN		' If the current position does not change, do not scroll.
			fScroll = $$TRUE										' Set the scroll flag to TRUE.
			xDelta = xNewPos - xCurrentScroll		' Determine the amount scrolled (in pixels).
			xCurrentScroll = xNewPos						' Reset the current scroll position.

' Scroll the window. (The system repaints most of the
' client area when ScrollWindowEx is called; however, it is
' necessary to call UpdateWindow in order to repaint the
' rectangle of pixels that were invalidated.)

			ScrollWindowEx(hWnd, -xDelta, -yDelta, 0, 0, 0, 0, $$SW_INVALIDATE)
			UpdateWindow(hWnd)

			si.cbSize = SIZE(si)					' Reset the scroll bar.
			si.fMask  = $$SIF_POS
			si.nPos   = xCurrentScroll
			SetScrollInfo(hWnd, $$SB_HORZ, &si, $$TRUE)

		CASE $$WM_VSCROLL :
			xDelta = 0
			SELECT CASE (LOWORD(wParam))				' scroll bar notify value
				CASE $$SB_PAGEUP:									' User clicked above the scroll bar.
					yNewPos = yCurrentScroll - 50

				CASE $$SB_PAGEDOWN:								' User clicked below the scroll bar.
					yNewPos = yCurrentScroll + 50

				CASE $$SB_LINEUP:									' User clicked the top arrow.
					yNewPos = yCurrentScroll - 5

				CASE $$SB_LINEDOWN:								' User clicked the bottom arrow.
					yNewPos = yCurrentScroll + 5

				CASE $$SB_THUMBPOSITION:					' User dragged the scroll box.
					yNewPos = HIWORD(wParam)

				CASE ELSE:
					yNewPos = yCurrentScroll
 			END SELECT

			yNewPos = MAX(0, yNewPos)
			yNewPos = MIN(yMaxScroll-yNewSize+1, yNewPos)

			IF (yNewPos == yCurrentScroll) THEN RETURN		' If the current position does not change, do not scroll.
			fScroll = $$TRUE										' Set the scroll flag to TRUE.
			yDelta = yNewPos - yCurrentScroll		' Determine the amount scrolled (in pixels).
			yCurrentScroll = yNewPos						' Reset the current scroll position.

' Scroll the window. (The system repaints most of the
' client area when ScrollWindowEx is called; however, it is
' necessary to call UpdateWindow in order to repaint the
' rectangle of pixels that were invalidated.)

			ScrollWindowEx(hWnd, -xDelta, -yDelta, 0, 0, 0, 0, $$SW_INVALIDATE)
			UpdateWindow(hWnd)

			si.cbSize = SIZE(si)					' Reset the scroll bar.
			si.fMask  = $$SIF_POS
			si.nPos   = yCurrentScroll
			SetScrollInfo(hWnd, $$SB_VERT, &si, $$TRUE)

		CASE $$WM_ERASEBKGND :						' window has been covered and needs to be redrawn
			fSize = $$TRUE									' set resize flag to TRUE so window can be repainted
			RETURN ($$TRUE)									' no more erasing of background is necessary

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
	className$  = "ScrollBitmap"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window w/ scrollbars
	titleBar$  	= "Scrolling Bitmap Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 500
	h 					= 400
	#winMain = NewWindow (className$, titleBar$, style | $$WS_HSCROLL | $$WS_VSCROLL, x, y, w, h, 0)
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
END PROGRAM
