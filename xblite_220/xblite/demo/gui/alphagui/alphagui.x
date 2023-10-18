'
'	sets the transperancy of any gui window.
'	(windows 2000 or later only)
'	written to show how mouse hooks can be used.
'
'	Michael McElligott
'	03/12/03
'
' Instructions:
'	With the alphagui window in focus, point the cursor to the title of another window.
'	Then press S to set window transperant or R to remove transperancy.
'
PROGRAM	"alphagui"
VERSION	"0.0001"
'MAKEFILE "xexe.xxx"


	IMPORT	"xst"
	IMPORT  "xio"
	IMPORT	"gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
	IMPORT  "comctl32"
	IMPORT  "mhook"

'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  CenterWindow (hwnd)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, titleBar$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  InitConsole ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  GetTrackbarSelection (hTrackbar, @selMin, @selMax)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  MonitorTrackbarSelRange (hTrackbar, wParam, selMin, selMax)
DECLARE FUNCTION  Shutdown()

$$WM_MOUSEHOOK = 1030
$$WS_EX_LAYERED = 0x80000	' user32.dec
$$LWA_ALPHA = 0x00000002	' user32.dec


$$Trackbar2  = 111

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

'	InitConsole ()								' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	CreateWindows ()							' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)
	STATIC FUNCADDR SLWA (ULONG, XLONG, UBYTE, XLONG)
	PAINTSTRUCT ps
	RECT rect
	STATIC LastWnd
	SHARED hlib
	STATIC alpha
	STATIC own
	STATIC STRING title,ltitle


	SELECT CASE msg

		CASE $$WM_CREATE:
		
      hlib = LoadLibraryA (&"user32.dll")
			IFZ hlib THEN Shutdown()
		
			SLWA = GetProcAddress (hlib, &"SetLayeredWindowAttributes")
			IFZ SLWA THEN
				IF hlib THEN FreeLibrary (hlib) 
				PRINT "Windows 2000 or later required"
				Shutdown()
			END IF
			InstallHook (hWnd)

			alpha = 80
			LastWnd = hWnd
			own = hWnd
			RETURN

		CASE $$WM_MOUSEHOOK
			LastWnd = wParam
			
			IF LastWnd == own THEN
				SetWindowTextA (own,&"Alpha - ")
				RETURN
			END IF
			
			len = GetWindowTextLengthA (LastWnd) + 1
			title = SPACE$(len)
			GetWindowTextA (LastWnd, &title,len)
 			title = "Alpha - " + CSTRING$(&title)
 			IF title == ltitle THEN RETURN
			SetWindowTextA (own,&title)
			ltitle = title
			
			RETURN
			
		CASE $$WM_LBUTTONUP:
			SetForegroundWindow (own)
			SetFocus (own)

		CASE $$WM_KEYDOWN	:
			IF wParam == 'S' THEN
				IFZ alpha THEN RETURN

				SetWindowLongA (LastWnd, $$GWL_EXSTYLE, GetWindowLongA (LastWnd, $$GWL_EXSTYLE) | $$WS_EX_LAYERED)
				@SLWA (LastWnd, 0, (255 * alpha) / 100 , $$LWA_ALPHA)
				RedrawWindow(LastWnd, NULL, NULL, $$RDW_ERASE | $$RDW_INVALIDATE | $$RDW_FRAME | $$RDW_ALLCHILDREN)
				RETURN
			END IF
			
			IF wParam == 'R' THEN
				SetWindowLongA (LastWnd, $$GWL_EXSTYLE, GetWindowLongA (LastWnd, $$GWL_EXSTYLE) & ~$$WS_EX_LAYERED)
				RedrawWindow(LastWnd, NULL, NULL, $$RDW_ERASE | $$RDW_INVALIDATE | $$RDW_FRAME | $$RDW_ALLCHILDREN)
				RETURN
			END IF
			
		CASE $$WM_CTLCOLORSTATIC :
			hStatic = lParam
			IF hStatic = #hTrackbar2 THEN
				bkColor = RGB (0xc0, 0xc0, 0xc0)
				RETURN SetColor (0, bkColor, wParam, lParam)
			END IF
			
		CASE $$WM_HSCROLL :
			hTrackbar = lParam
			code      = LOWORD(wParam)
			position  = HIWORD(wParam)

			SELECT CASE hTrackbar
				CASE #hTrackbar2 :
					GetTrackbarSelection (hTrackbar, @selMin, @selMax)
					MonitorTrackbarSelRange (hTrackbar, wParam, selMin, selMax)
					SetForegroundWindow (own)
					SetFocus (own)
					alpha = SendMessageA (hTrackbar, $$TBM_GETPOS, 0, 0)
			END SELECT
			RETURN

		CASE $$WM_CLOSE:	Shutdown()
		CASE $$WM_QUIT:		Shutdown()
		CASE $$WM_DESTROY:	Shutdown()
	END SELECT

RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION

FUNCTION Shutdown()
	SHARED hlib

	
	UninstallHook ()
	IF hlib THEN FreeLibrary (hlib)
	PostQuitMessage(0)
	QUIT (0)

END FUNCTION
'
FUNCTION  CenterWindow (hWnd)

	RECT wRect

	GetWindowRect (hWnd, &wRect)
	#screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	#screenHeight = GetSystemMetrics ($$SM_CYSCREEN)
	x = (#screenWidth - (wRect.right - wRect.left))/2
	y = (#screenHeight - (wRect.bottom - wRect.top + GetSystemMetrics($$SM_CYCAPTION)))/2
	SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER)

END FUNCTION

FUNCTION  InitGui ()

	SHARED hInst
	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT (0)
	InitCommonControls ()					' initialize comctl32.dll library

END FUNCTION

FUNCTION  RegisterWinClass (className$, titleBar$)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &WndProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"scrabble")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &className$

	RETURN RegisterClassA (&wc)

END FUNCTION

FUNCTION  CreateWindows ()

' create main window

	className$  = "Alpha"
	titleBar$  	= "AlphaGui"
	style 		= $$WS_OVERLAPPEDWINDOW & ~$$WS_MAXIMIZEBOX & ~$$WS_MINIMIZEBOX & ~$$WS_THICKFRAME
	w 			= 266
	h 			= 66
	exStyle		= 0
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)


' create a trackbar with an enabled selection range, tooltips on bottom, ticks on bottom
	style = $$TBS_HORZ | $$TBS_AUTOTICKS | $$TBS_TOOLTIPS | $$TBS_ENABLESELRANGE
	#hTrackbar2 = NewChild ($$TRACKBAR_CLASS, "", style, 2, 2, 250, 32, #winMain, $$Trackbar2, 0)
	SendMessageA (#hTrackbar2, $$TBM_SETRANGE, $$TRUE, MAKELONG(0, 100))
	SendMessageA (#hTrackbar2, $$TBM_SETTICFREQ, 10, 0)
	SendMessageA (#hTrackbar2, $$TBM_SETPAGESIZE, 0, 10)

' set tool tip position
	SendMessageA (#hTrackbar2, $$TBM_SETTIPSIDE, $$TBTS_BOTTOM, 0)

' set selection range
	selMin = 2 : selMax = 98
	SendMessageA (#hTrackbar2, $$TBM_SETSEL, $$TRUE, MAKELONG(selMin, selMax))

' set initial thumb position
	SendMessageA (#hTrackbar2, $$TBM_SETPOS, $$TRUE, 80)

	CenterWindow (#winMain)									' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

END FUNCTION

FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	IFZ	RegisterWinClass (className$, titleBar$) THEN QUIT(0)
	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION

FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION

FUNCTION  MessageLoop ()

	STATIC USER32_MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
				hwnd = GetActiveWindow ()
				IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN		' send only non-dialog messages
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
				END IF
		END SELECT
	LOOP

END FUNCTION

FUNCTION  InitConsole ()

	SHARED fConsole
	STATIC entry
	IFT entry THEN RETURN
	entry = $$TRUE
	XioCreateConsole (consoleTitle$, 100) '(consoleTitle$, 100, @#hStdOut, @#hStdIn, @#hConWnd)
	fConsole = $$TRUE

END FUNCTION

FUNCTION  CleanUp ()

	SHARED hInst, className$
	SHARED fConsole

	UnregisterClassA (&className$, hInst)
	IF fConsole THEN XioFreeConsole ()

END FUNCTION

'
FUNCTION  MonitorTrackbarSelRange (hTrackbar, wParam, selMin, selMax)

	IFZ hTrackbar THEN RETURN
	IFZ selMax THEN RETURN

	code      = LOWORD(wParam)

	SELECT CASE code
		CASE $$TB_ENDTRACK, $$TB_THUMBPOSITION :
			position  = SendMessageA (hTrackbar, $$TBM_GETPOS, 0, 0)
			IF (position > selMax) THEN
				SendMessageA (hTrackbar, $$TBM_SETPOS, $$TRUE, selMax)
			ELSE
				IF (position < selMin) THEN
					SendMessageA (hTrackbar, $$TBM_SETPOS, $$TRUE, selMin)
				END IF
			END IF
	END SELECT

END FUNCTION

FUNCTION  GetTrackbarSelection (hTrackbar, @selMin, @selMax)

	selMin = SendMessageA (hTrackbar, $$TBM_GETSELSTART, 0, 0)
	selMax = SendMessageA (hTrackbar, $$TBM_GETSELEND, 0, 0)

END FUNCTION

FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION

END PROGRAM
