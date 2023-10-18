'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates the use of the splitter.dll
' custom control.
'
PROGRAM	"splittest"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"
	IMPORT  "splitter"	' splitter.dll	: splitter custom control

'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

'Control IDs

$$Edit1    = 120
$$Edit2    = 121
$$Edit3    = 122
$$Edit4    = 123

$$Static1  = 130
$$Static2  = 131

$$Splitter1 = 140
$$Splitter2 = 141
$$Splitter3 = 142
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

'	XioCreateConsole (title$, 250)	' create console, if console is not wanted, comment out this line
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

'		CASE $$WM_SPITTER_BAR_MOVED :
'			PRINT "WM_SPITTER_BAR_MOVED"

		CASE $$WM_DESTROY :
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
	className$  = "SplitterDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Custom Splitter Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 530
	h 					= 350
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create splitter control (default style is horizontal)
	#hSplitter1 = NewChild ($$SPLITTERCLASSNAME, "", 0, 5, 5, 240, 150, #winMain, $$Splitter1, 0)

' create two child controls for the splitter control
' note that the x, y, w, h args can be set to 0
' the splitter control will resize them to fit within the splitter
' also note that the controls set the splitter control as the parent window

' create edit control
	#hEdit1 = NewChild ($$EDIT, "Move the splitter bar and see what happens...", $$ES_MULTILINE | $$ES_AUTOVSCROLL | $$WS_VSCROLL | $$ES_LEFT, 0, 0, 0, 0, #hSplitter1, $$Edit1, $$WS_EX_CLIENTEDGE)

' create static control
	#hStatic1 = NewChild ("static", "Horz Splitter Demo 1", $$SS_CENTER, 0, 0, 0, 0, #hSplitter1, $$Static1, $$WS_EX_CLIENTEDGE)

' set splitter panel window handles
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_PANEL_HWND, #hEdit1, #hStatic1)

' *****************************************

' create 2nd splitter control
	#hSplitter2 = NewChild ($$SPLITTERCLASSNAME, "", 0, 5, 165, 240, 150, #winMain, $$Splitter2, 0)

' create edit control
	text$ = "Now there are two instances of this splitter control... AND, the splitter bar size is set to 12."
	#hEdit2 = NewChild ($$EDIT, text$, $$ES_MULTILINE | $$ES_AUTOVSCROLL | $$WS_VSCROLL | $$ES_LEFT, 0, 0, 0, 0, #hSplitter2, $$Edit2, $$WS_EX_CLIENTEDGE)

' create static control
	#hStatic2 = NewChild ("static", "Horz Splitter Demo 2", $$SS_CENTER, 0, 0, 0, 0, #hSplitter2, $$Static2, $$WS_EX_CLIENTEDGE)

' set splitter panel window handles
	SendMessageA (#hSplitter2, $$WM_SET_SPLITTER_PANEL_HWND, #hStatic2, #hEdit2)

' change the splitter bar size
	SendMessageA (#hSplitter2, $$WM_SET_SPLITTER_SIZE, 0, 12)

' set initial position of splitter panel
	SendMessageA (#hSplitter2, $$WM_SET_SPLITTER_POSITION, 160, 0)

' set minimum panel sizes (default is 20)
	SendMessageA (#hSplitter2, $$WM_SET_SPLITTER_MIN_PANEL_SIZE, 100, 0)

' ***********************************************

' create vertical splitter control

	#hSplitter3 = NewChild ($$SPLITTERCLASSNAME, "", 0, 275, 5, 240, 310, #winMain, $$Splitter3, 0)

' create edit control
	text$ = "This is a vertical splitter with two child edit controls"
	#hEdit3 = NewChild ($$EDIT, text$, $$ES_MULTILINE | $$ES_AUTOVSCROLL | $$WS_VSCROLL | $$ES_LEFT, 0, 0, 0, 0, #hSplitter3, $$Edit3, $$WS_EX_CLIENTEDGE)

	text$ = "The splitter bar size is set to 10, the initial y splitter panel position is set to 120, and both edit controls have their minimum size set to 100."
	#hEdit4 = NewChild ($$EDIT, text$, $$ES_MULTILINE | $$ES_AUTOVSCROLL | $$WS_VSCROLL | $$ES_LEFT, 0, 0, 0, 0, #hSplitter3, $$Edit4, $$WS_EX_CLIENTEDGE)

' set splitter panel window handles
	SendMessageA (#hSplitter3, $$WM_SET_SPLITTER_PANEL_HWND, #hEdit3, #hEdit4)

' set splitter control style (default is $$SS_HORZ - horizontal)
	SendMessageA (#hSplitter3, $$WM_SET_SPLITTER_STYLE, 0, $$SS_VERT)

' change the splitter bar size
	SendMessageA (#hSplitter3, $$WM_SET_SPLITTER_SIZE, 0, 10)

' set initial position of splitter panel
	SendMessageA (#hSplitter3, $$WM_SET_SPLITTER_POSITION, 0, 120)

' set minimum panel sizes (default is 20)
	SendMessageA (#hSplitter3, $$WM_SET_SPLITTER_MIN_PANEL_SIZE, 100, 100)

' get current splitter panel positions
	pos1 = SendMessageA (#hSplitter1, $$WM_GET_SPLITTER_POSITION, 0, 0)
	pos2 = SendMessageA (#hSplitter2, $$WM_GET_SPLITTER_POSITION, 0, 0)
	pos3 = SendMessageA (#hSplitter3, $$WM_GET_SPLITTER_POSITION, 0, 0)

' get minimum splitter control size
	min1 = SendMessageA (#hSplitter1, $$WM_GET_SPLITTER_MIN_SIZE, 0, 0)
	min2 = SendMessageA (#hSplitter2, $$WM_GET_SPLITTER_MIN_SIZE, 0, 0)
	min3 = SendMessageA (#hSplitter3, $$WM_GET_SPLITTER_MIN_SIZE, 0, 0)

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
END PROGRAM
