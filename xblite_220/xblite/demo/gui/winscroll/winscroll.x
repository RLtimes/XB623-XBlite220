'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of scrolling a window containing
' multiple static controls.
'
PROGRAM	"winscroll"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
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
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  UpdateStdScrollbars (hWnd, code, pos, bar)
'
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

	STATIC hStatic[]
	SCROLLINFO si
	RECT rect
	STATIC scrollWidth, scrollHeight

	DIM hStatic[50]

	SELECT CASE msg

		CASE $$WM_CREATE:							' create a series of static controls

			scrollWidth = 420						' size of area to be scrolled
			scrollHeight = 420

			id = 0
			FOR y = 10 TO 350 STEP 100
				FOR x = 10 TO 350 STEP 100
					hStatic[id] = NewChild ("static", "lama", $$SS_BITMAP | $$SS_NOTIFY, x, y, 0, 0, hWnd, id+100, $$WS_EX_STATICEDGE)
					INC id
			NEXT x
			NEXT y

		CASE $$WM_VSCROLL:
			code = LOWORD (wParam)
			pos  = HIWORD (wParam)
			UpdateStdScrollbars (hWnd, code, pos, $$SB_VERT)

		CASE $$WM_HSCROLL:
			code = LOWORD (wParam)
			pos  = HIWORD (wParam)
			UpdateStdScrollbars (hWnd, code, pos, $$SB_HORZ)

		CASE $$WM_SIZE:

			width = LOWORD(lParam)
			height = HIWORD(lParam)

			si.cbSize = SIZE(si)
			si.fMask 	= $$SIF_POS
			GetScrollInfo (hWnd, $$SB_VERT, &si)
			dy = si.nPos

			GetScrollInfo (hWnd, $$SB_HORZ, &si)
			dx = si.nPos

' reset scrolled window back to original position
			ScrollWindowEx (hWnd, dx, dy, 0, 0, 0, 0, $$SW_SCROLLCHILDREN | $$SW_ERASE | $$SW_INVALIDATE)

' reset vertical scrollbar settings
			si.cbSize = SIZE(si)
			si.fMask 	= $$SIF_ALL
			si.nMin 	= 0
			si.nMax 	= scrollHeight
			si.nPage 	= height
			si.nPos 	= 0
			SetScrollInfo (hWnd, $$SB_VERT, &si, $$TRUE)

' reset horizontal scrollbar settings
			si.cbSize = SIZE(si)
			si.fMask 	= $$SIF_ALL
			si.nMin 	= 0
			si.nMax 	= scrollWidth
			si.nPage 	= width
			si.nPos 	= 0
			SetScrollInfo (hWnd, $$SB_HORZ, &si, $$TRUE)

		CASE $$WM_COMMAND:
			notifyCode = HIWORD (wParam)
			id = LOWORD (wParam)
			IF notifyCode = $$STN_CLICKED THEN
				text$ = "You clicked on control " + STRING$(id)
				MessageBoxA (hWnd, &text$, &"Click Feedback", 0)
			END IF

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

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
	className$  = "ScrollWindowDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Scrolling Window Demo - Click on an image."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_VSCROLL | $$WS_HSCROLL
	w 					= 350
	h 					= 350
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

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

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
'
'
' ####################################
' #####  UpdateStdScrollbars ()  #####
' ####################################
'
' Update thumb position in a standard window scrollbar
'
' IN : 	hWnd		window handle
' 			code		scrollbar message (LOWWORD(wParam))
'				pos			scrollbar position (HIWORD(wParam))
'				bar			horizontal or vertical bar (SB_HORZ or SB_VERT)
'
FUNCTION  UpdateStdScrollbars (hWnd, code, pos, bar)

	RECT rect
	SCROLLINFO si

	si.cbSize = SIZE(si)
	si.fMask = $$SIF_ALL
	GetScrollInfo (hWnd, bar, &si)

  SELECT CASE code

		CASE $$SB_LINEDOWN:       ' Scrolls one line down
			newPos = si.nPos + 1

		CASE $$SB_LINEUP:         ' Scrolls one line up
			newPos = si.nPos - 1

		CASE $$SB_PAGEDOWN:       ' Scrolls one page down
			newPos = si.nPos + 20

		CASE $$SB_PAGEUP:         ' Scrolls one page up
			newPos = si.nPos - 20

'		CASE $$SB_THUMBPOSITION:  	' The user has dragged the scroll box (thumb) and released the mouse button. The nPos parameter indicates the position of the scroll box at the end of the drag operation.
'			newPos = pos

		CASE $$SB_THUMBTRACK:     	' The user is dragging the scroll box. This message is sent repeatedly until the user releases the mouse button. The nPos parameter indicates the position that the scroll box has been dragged to.
			newPos = si.nTrackPos

		CASE ELSE:
			newPos = si.nPos

	END SELECT

	GetClientRect (hWnd, &rect)
	IF bar = $$SB_VERT THEN
		newSize = rect.bottom
	ELSE
		newSize = rect.right
	END IF

	newPos = MAX(0, newPos)
	newPos = MIN(si.nMax-newSize+1, newPos)

	IF newPos = si.nPos THEN RETURN
	delta = newPos - si.nPos
	si.nPos = newPos

	IF bar = $$SB_VERT THEN
		dy = -delta
	ELSE
		dx = -delta
	END IF

	ScrollWindowEx (hWnd, dx, dy, 0, 0, 0, 0, $$SW_SCROLLCHILDREN | $$SW_ERASE | $$SW_INVALIDATE)

	si.fMask = $$SIF_POS
	SetScrollInfo (hWnd, bar, &si, $$TRUE)

END FUNCTION
END PROGRAM
