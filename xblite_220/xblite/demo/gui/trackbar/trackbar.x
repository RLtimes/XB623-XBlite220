'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo creates various styles of trackbar controls.
'
PROGRAM	"trackbar"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
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
DECLARE FUNCTION  GetTickFreq (hTrackbar)
DECLARE FUNCTION  SetTrackbarPositionOnTick (hTrackbar, wParam, @lastPos)
DECLARE FUNCTION  MonitorTrackbarSelRange (hTrackbar, wParam, selMin, selMax)
DECLARE FUNCTION  GetTrackbarSelection (hTrackbar, @selMin, @selMax)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

'Control IDs

$$Trackbar1  = 110
$$Trackbar2  = 111
$$Trackbar3  = 112
$$Trackbar4  = 113

$$Edit1      = 120
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
	STATIC lastPos
	SHARED hNewBrush

	SELECT CASE msg

		CASE $$WM_DESTROY :
	    DeleteObject (hNewBrush)
			PostQuitMessage(0)
			RETURN

		CASE $$WM_HSCROLL :
			hTrackbar = lParam
			code      = LOWORD(wParam)
			position  = HIWORD(wParam)

			SELECT CASE hTrackbar
				CASE #hTrackbar1 :
					SetTrackbarPositionOnTick (hTrackbar, wParam, @lastPos)

				CASE #hTrackbar2 :
					GetTrackbarSelection (hTrackbar, @selMin, @selMax)
					MonitorTrackbarSelRange (hTrackbar, wParam, selMin, selMax)

				CASE #hTrackbar3 :
					position = SendMessageA (hTrackbar, $$TBM_GETPOS, 0, 0)
					pos$ = STRING$(position)
					SetWindowTextA (#hEdit1, &pos$)
			END SELECT
			RETURN

		CASE $$WM_CTLCOLORSTATIC :
			hStatic = lParam
			IF hStatic = #hTrackbar2 THEN
				bkColor = GetSysColor ($$COLOR_BTNFACE)
				RETURN SetColor (0, bkColor, wParam, lParam)
			END IF

	END SELECT

  RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

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

	SHARED className$, hInst

' register window class
	className$  = "TrackbarDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Trackbar Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	#winMain = NewWindow (className$, title$, style, x, y, 225, 225, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' *************************************************************************

' create a trackbar control, autoticks, horizontal, ticks on top
	style = $$TBS_HORZ | $$TBS_AUTOTICKS | $$TBS_TOP
	#hTrackbar1 = NewChild ($$TRACKBAR_CLASS, "", style, 20, 20, 150, 40, #winMain, $$Trackbar1, $$WS_EX_CLIENTEDGE)

' set range of trackbar
	min = 0 : max = 100
	SendMessageA (#hTrackbar1, $$TBM_SETRANGE, $$TRUE, MAKELONG(min, max))

' set tick frequency
	freq = 25
	SendMessageA (#hTrackbar1, $$TBM_SETTICFREQ, freq, 0)

' set page size (how much slider moves for TB_PAGEUP/TB_PAGEDOWN messages)
	SendMessageA (#hTrackbar1, $$TBM_SETPAGESIZE, 0, 25)

' set line size (how much slider moves for TB_LINEUP/TB_LINEDOWN messages)
	SendMessageA (#hTrackbar1, $$TBM_SETLINESIZE, 0, 25)

' ************************************************************************

' create a trackbar with an enabled selection range, tooltips on bottom, ticks on bottom
	style = $$TBS_HORZ | $$TBS_AUTOTICKS | $$TBS_TOOLTIPS | $$TBS_ENABLESELRANGE
	#hTrackbar2 = NewChild ($$TRACKBAR_CLASS, "", style, 20, 80, 150, 32, #winMain, $$Trackbar2, 0)
	SendMessageA (#hTrackbar2, $$TBM_SETRANGE, $$TRUE, MAKELONG(0, 100))
	SendMessageA (#hTrackbar2, $$TBM_SETTICFREQ, 10, 0)
	SendMessageA (#hTrackbar2, $$TBM_SETPAGESIZE, 0, 10)

' set tool tip position
	SendMessageA (#hTrackbar2, $$TBM_SETTIPSIDE, $$TBTS_BOTTOM, 0)

' set selection range
	selMin = 20 : selMax = 80
	SendMessageA (#hTrackbar2, $$TBM_SETSEL, $$TRUE, MAKELONG(selMin, selMax))

' set initial thumb position
	SendMessageA (#hTrackbar2, $$TBM_SETPOS, $$TRUE, selMin)

' *************************************************************************

' create a trackbar control, autoticks, horizontal, ticks on bottom
	style = $$TBS_HORZ | $$TBS_AUTOTICKS
	#hTrackbar3 = NewChild ($$TRACKBAR_CLASS, "", style, 20, 140, 150, 32, #winMain, $$Trackbar3, $$WS_EX_CLIENTEDGE)
	SendMessageA (#hTrackbar3, $$TBM_SETRANGE, $$TRUE, MAKELONG(0, 50))
	SendMessageA (#hTrackbar3, $$TBM_SETTICFREQ, 10, 0)

' create a "buddy" edit control to work with #Trackbar3
	#hEdit1 = NewChild ($$EDIT, "", $$ES_LEFT, 0, 0, 26, 20, #winMain, $$Edit1, $$WS_EX_CLIENTEDGE)

' add buddy edit window to trackbar
' this positions the edit control directly to the right side of trackbar
	SendMessageA (#hTrackbar3, $$TBM_SETBUDDY, 0, #hEdit1)

' *****************************************************************

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
'
'
' ############################
' #####  GetTickFreq ()  #####
' ############################
'
FUNCTION  GetTickFreq (hTrackbar)

	max = SendMessageA (hTrackbar, $$TBM_GETRANGEMAX, 0, 0)
	min = SendMessageA (hTrackbar, $$TBM_GETRANGEMIN, 0, 0)
	ticks = SendMessageA (hTrackbar, $$TBM_GETNUMTICS, 0, 0)
	RETURN (max - min) / (ticks - 1)

END FUNCTION
'
'
' ##########################################
' #####  SetTrackbarPositionOnTick ()  #####
' ##########################################
'
' PURPOSE : Set trackbar position on the closest tick mark
'           after receiving WM_HSCROLL/WM_VSCROLL message.

FUNCTION  SetTrackbarPositionOnTick (hTrackbar, wParam, @lastPos)

	code      = LOWORD(wParam)
	position  = HIWORD(wParam)

' only allow position to be set on a tick mark
	IF code <> $$TB_THUMBPOSITION THEN RETURN

	freq = GetTickFreq (hTrackbar)
	IF position < lastPos THEN
		position = (position\freq) * freq
	ELSE
		position = ((position\freq) * freq) + freq
	END IF
	SendMessageA (hTrackbar, $$TBM_SETPOS, $$TRUE, position)
	lastPos = position

END FUNCTION
'
'
' ########################################
' #####  MonitorTrackbarSelRange ()  #####
' ########################################
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
'
'
' #####################################
' #####  GetTrackbarSelection ()  #####
' #####################################
'
FUNCTION  GetTrackbarSelection (hTrackbar, @selMin, @selMax)
	selMin = SendMessageA (hTrackbar, $$TBM_GETSELSTART, 0, 0)
	selMax = SendMessageA (hTrackbar, $$TBM_GETSELEND, 0, 0)

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION
END PROGRAM
