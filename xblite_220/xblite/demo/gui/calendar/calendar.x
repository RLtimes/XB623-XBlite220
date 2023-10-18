'
'
' ####################
' #####  PROLOG  #####
' ####################

' A simple demo to display the calendar control.
'
PROGRAM	"calendar"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT "xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "msvcrt"    ' msvcrt.dll
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
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)

'Control IDs
$$Calendar  = 100
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
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

	INITCOMMONCONTROLSEX iccex
	RECT rect
	SYSTEMTIME st
	TM tm

	SELECT CASE msg

		CASE $$WM_CREATE:

			iccex.dwSize = SIZE(iccex)
			iccex.dwICC = $$ICC_DATE_CLASSES		' initialize month control
			InitCommonControlsEx (&iccex)				' initialize common controls extended
			GetClientRect (hWnd, &rect)

			#hCalendar = NewChild ($$MONTHCAL_CLASS, "", style, 0, 0, rect.right, rect.bottom, hWnd, $$Calendar, $$WS_EX_TOOLWINDOW)
			SendMessageA (#hCalendar, $$MCM_SETCOLOR, $$MCSC_TITLETEXT    , RGB(0, 0, 0))
			SendMessageA (#hCalendar, $$MCM_SETCOLOR, $$MCSC_TITLEBK      , RGB(245, 175, 0))
			SendMessageA (#hCalendar, $$MCM_SETCOLOR, $$MCSC_BACKGROUND   , RGB(175, 175, 175))
			SendMessageA (#hCalendar, $$MCM_SETCOLOR, $$MCSC_MONTHBK      , RGB(248, 245, 225))
			SendMessageA (#hCalendar, $$MCM_SETCOLOR, $$MCSC_TEXT         , RGB(0, 0, 225))
			SendMessageA (#hCalendar, $$MCM_SETCOLOR, $$MCSC_TRAILINGTEXT , RGB(0, 225, 0))

'		CASE $$WM_SIZE:
'			width = LOWORD (lParam)
'			height = LOWORD (lParam)
'			SetWindowPos (#hCalendar, 0, 0, 0, width, height, $$SWP_NOZORDER | $$SWP_NOMOVE)

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE $$WM_NOTIFY:
			GetNotifyMsg (lParam, @hWndCtl, @id, @code)

			SELECT CASE code

				CASE $$MCN_SELECT: 							' date selection has occurred
					day = SendMessageA (hWndCtl, $$MCM_GETCURSEL, SIZE(st), &st)
'					PRINT st.year, st.month, st.weekDay, st.day

					tm.tm_mday = st.day
					tm.tm_mon  = st.month - 1			' tm_mon index starts at 0
					tm.tm_year = st.year - 1900   ' tm_year is in years since 1900
					tm.tm_wday = st.weekDay
					date$ = NULL$(256)
					strftime (&date$, LEN(date$), &"Selected date: %A, %B %d, %Y", &tm)
					date$ = CSIZE$(date$)
					MessageBoxA (hWnd, &date$, &"Date Selection", $$MB_OK)
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
	hInst = GetModuleHandleA (0) 	' get current instance handle
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

' register window class
	className$  = "CalendarDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Calendar Control Demo."
	style 			= $$WS_CAPTION | $$WS_SYSMENU
	w 					= 200
	h 					= 180
	exStyle			= $$WS_EX_DLGMODALFRAME
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

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
END PROGRAM
