'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo displays a clock in the titlebar and
' uses the system timer to update the clock each second.
'
PROGRAM	"clock"
VERSION	"0.0003"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
IMPORT "xst_s.lib"
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  SetCurrentTime (hWnd)
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

		CASE $$WM_CREATE :
			SetCurrentTime (hWnd)
			SetTimer (hWnd, 1, 1000, 0)						' set timer id 1, 1000 ms time-out

		CASE $$WM_DESTROY :
			KillTimer (hWnd, 1)
			PostQuitMessage(0)

		CASE $$WM_TIMER :
			SetCurrentTime (hWnd)

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
	hInst = GetModuleHandleA(0)		' get current instance handle
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
	className$  = "ClockDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Clock & Timer Demo."
	style 			= $$DS_MODALFRAME | $$WS_POPUP | $$WS_VISIBLE | $$WS_CAPTION | $$WS_SYSMENU
	w 					= 150
	h 					= 24
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)								' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)		' show window

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
' ###############################
' #####  SetCurrentTime ()  #####
' ###############################
'
FUNCTION  SetCurrentTime (hWnd)

	SYSTEMTIME systime											' in kernel32.dec
	TIME_ZONE_INFORMATION tzi

'	GetSystemTime (&systime)

' get time zone info to calculate local time (hour)
'	timeZone = GetTimeZoneInformation (&tzi)

' local time = UTC - bias - daylight savings bias
' bias values are usually in minutes (eg, -60)

'	SELECT CASE timeZone
'		CASE -1, $$TIME_ZONE_ID_UNKNOWN :
'		CASE $$TIME_ZONE_ID_STANDARD		: systime.hour = systime.hour - tzi.Bias/60 - tzi.StandardBias/60
'		CASE $$TIME_ZONE_ID_DAYLIGHT		: systime.hour = systime.hour - tzi.Bias/60 - tzi.DaylightBias/60
'	END SELECT

'	IF systime.hour > 24 THEN systime.hour = systime.hour MOD 24

' format time$
	time$ = NULL$(24)

'	ret = GetTimeFormatA (0, $$TIME_FORCE24HOURFORMAT, &systime, &"HH':'mm':'ss tt", &time$, LEN(time$))

' use the current local system time
  format$ = "hh\':\'mm\':\'ss tt"
	ret = GetTimeFormatA (0, $$TIME_FORCE24HOURFORMAT, 0, &format$, &time$, LEN(time$))

	time$ = CSIZE$(time$)

' set time$ in window titlebar
	SetWindowTextA (hWnd, &time$)

END FUNCTION
END PROGRAM
