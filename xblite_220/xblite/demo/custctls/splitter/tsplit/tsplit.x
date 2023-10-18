'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Let's see if the splitter.dll can be used
' to create a T splitter. In this case, you
' want to control the sizing of three control
' panels. We would use two splitter controls.
' ---
' The first main horizontal splitter control
' would contain two child controls (or panels).
' One panel will be a child control, the second
' will be a vertical splitter control.
' ---
' Then two more child controls are contained in
' the second splitter control. Simple...
'
PROGRAM	"tsplit"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "shell32"		' shell32.dll
	IMPORT  "splitter"	' splitter.dll		: splitter custom control
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

$$Splitter1 = 140
$$Splitter2 = 141
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

	SHARED hInst

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			w = LOWORD (lParam)
			h = HIWORD (lParam)
			sizeType = wParam
			SELECT CASE sizeType
				CASE $$SIZE_MAXIMIZED, $$SIZE_RESTORED :
					MoveWindow (#hSplitter1, 0, 0, w, h, $$TRUE)
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
	RECT rect

' register window class
	className$  = "TSplitterDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Custom T-Splitter Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 550
	h 					= 300
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create splitter control (default style is horizontal)
	GetClientRect (#winMain, &rect)
	w = rect.right - rect.left
	h = rect.bottom - rect.top
	#hSplitter1 = NewChild ($$SPLITTERCLASSNAME, "", 0, 0, 0, w, h, #winMain, $$Splitter1, 0)

' create two child controls to be contained in the main splitter control
' note that the x, y, w, h args can be set to 0
' the splitter control will resize them to fit within the splitter
' also note that the child controls set the splitter control as the parent window

' create edit control and vertical splitter control
	style = $$ES_MULTILINE | $$ES_AUTOVSCROLL | $$WS_VSCROLL | $$ES_LEFT
	#hEdit1 = NewChild ($$EDIT, "Child Control 1", style, 0, 0, 0, 0, #hSplitter1, $$Edit1, $$WS_EX_CLIENTEDGE)
	#hSplitter2 = NewChild ($$SPLITTERCLASSNAME, "", 0, 0, 0, 0, 0, #hSplitter1, $$Splitter2, 0)

' set splitter panel window handles
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_PANEL_HWND, #hEdit1, #hSplitter2)

' create two more child controls for 2nd splitter
	#hEdit2 = NewChild ($$EDIT, "Child Control 2", style, 0, 0, 0, 0, #hSplitter2, $$Edit2, $$WS_EX_CLIENTEDGE)
	#hEdit3 = NewChild ($$EDIT, "Child Control 3", style, 0, 0, 0, 0, #hSplitter2, $$Edit3, $$WS_EX_CLIENTEDGE)

' set splitter panel window handles
	SendMessageA (#hSplitter2, $$WM_SET_SPLITTER_PANEL_HWND, #hEdit2, #hEdit3)

' set vertical splitter control style
	SendMessageA (#hSplitter2, $$WM_SET_SPLITTER_STYLE, 0, $$SS_VERT)


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
