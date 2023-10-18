'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates the use of the graph.dll
' custom control.
'
PROGRAM	"graphtest"
VERSION	"0.0002"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xst_s.lib"
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"
	IMPORT  "msvcrt"		' msvcrt.dll
'	IMPORT  "graph"
	IMPORT  "graph_s.lib"
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
DECLARE FUNCTION  RandomRange (min, max)
DECLARE FUNCTION  DOUBLE RandomUni ()

'Control IDs

$$Graph1 = 140
$$Graph2 = 141
$$Graph3 = 142
$$Graph4 = 143

$$Button1 = 100
$$Button2 = 101
$$Button3 = 102
$$Button4 = 103
$$Button5 = 104
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
	
	Graph ()											' initialize graph library

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
	STATIC timerID

	SELECT CASE msg

		CASE $$WM_DESTROY :
			KillTimer (hWnd, 1)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam
			IFZ timerID THEN timerID = SetTimer (hWnd, 1, 250, 0)		' start a timer
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 : hGraph = #hGraph1 : GOSUB Freeze
						CASE $$Button2 : hGraph = #hGraph2 : GOSUB Freeze
						CASE $$Button3 : hGraph = #hGraph3 : GOSUB Freeze
						CASE $$Button4 : hGraph = #hGraph4 : GOSUB Freeze
						CASE $$Button5 :
							text$ = NULL$(128)
							GetWindowTextA (hwndCtl, &text$, LEN(text$))
							text$ = LCASE$(CSIZE$(text$))
							IF text$ = "stop all" THEN
								SendMessageA (#hGraph1, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)
								SendMessageA (#hGraph2, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)
								SendMessageA (#hGraph3, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)
								SendMessageA (#hGraph4, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)
								SetWindowTextA (#hButton5, &"Start All")
								SetWindowTextA (#hButton1, &"Start")
								SetWindowTextA (#hButton2, &"Start")
								SetWindowTextA (#hButton3, &"Start")
								SetWindowTextA (#hButton4, &"Start")
							ELSE
								SendMessageA (#hGraph1, $$WM_SET_GRAPH_FREEZE, 0, $$FALSE)
								SendMessageA (#hGraph2, $$WM_SET_GRAPH_FREEZE, 0, $$FALSE)
								SendMessageA (#hGraph3, $$WM_SET_GRAPH_FREEZE, 0, $$FALSE)
								SendMessageA (#hGraph4, $$WM_SET_GRAPH_FREEZE, 0, $$FALSE)
								SetWindowTextA (#hButton5, &"Stop All")
								SetWindowTextA (#hButton1, &"Stop")
								SetWindowTextA (#hButton2, &"Stop")
								SetWindowTextA (#hButton3, &"Stop")
								SetWindowTextA (#hButton4, &"Stop")
							END IF
					END SELECT
			END SELECT

		CASE $$WM_TIMER :
			SendMessageA (#hGraph1, $$WM_GRAPH_UPDATE, 0, RandomRange(0, 100))
			SendMessageA (#hGraph2, $$WM_GRAPH_UPDATE, 0, RandomRange(0, 100))
			SendMessageA (#hGraph3, $$WM_GRAPH_UPDATE, 0, RandomRange(0, 100))
			SendMessageA (#hGraph4, $$WM_GRAPH_UPDATE, 0, RandomRange(0, 100))

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

' ***** Freeze *****
SUB Freeze
	IFZ SendMessageA (hGraph, $$WM_GET_GRAPH_FREEZE, 0, 0) THEN
		SendMessageA (hGraph, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)
		SetWindowTextA (hwndCtl, &"Start")
	ELSE
		SendMessageA (hGraph, $$WM_SET_GRAPH_FREEZE, 0, $$FALSE)
		SetWindowTextA (hwndCtl, &"Stop")
	END IF
END SUB

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
	className$  = "GraphDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Custom Graph Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 540
	h 					= 450
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create line graph control (default direction is $$GRAPH_LEFT)
	#hGraph1 = NewChild ($$GRAPHCLASSNAME, "", 0, 10, 10, 241, 181, #winMain, $$Graph1, 0)

' freeze graph1
	SendMessageA (#hGraph1, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)

' create 2nd line graph control
	#hGraph2 = NewChild ($$GRAPHCLASSNAME, "", 0, 280, 10, 241, 181, #winMain, $$Graph2, 0)

	SendMessageA (#hGraph2, $$WM_SET_GRAPH_DIRECTION, 0, $$GRAPH_RIGHT)
	SendMessageA (#hGraph2, $$WM_SET_GRAPH_BACKCOLOR, 0, RGB(0,0,0))
	SendMessageA (#hGraph2, $$WM_SET_GRAPH_LINE_COLORS, RGB(0,128,0), RGB(255,255,0))
	SendMessageA (#hGraph2, $$WM_SET_GRAPH_LINE_WIDTHS, -1, 2)
	SendMessageA (#hGraph2, $$WM_SET_GRAPH_GRID_UNITS, 0, 20)
	SendMessageA (#hGraph2, $$WM_SET_GRAPH_STEPSIZE, 0, 20)
	SendMessageA (#hGraph2, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)

' create a bar (histogram) graph control
	#hGraph3 = NewChild ($$GRAPHCLASSNAME, "", 0, 10, 240, 241, 101, #winMain, $$Graph3, 0)

	SendMessageA (#hGraph3, $$WM_SET_GRAPH_STYLE, 0, $$GS_BAR)
	SendMessageA (#hGraph3, $$WM_SET_GRAPH_LINE_WIDTHS, -1, 4)
	SendMessageA (#hGraph3, $$WM_SET_GRAPH_STEPSIZE, 0, 8)
	SendMessageA (#hGraph3, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)

' create a 2nd bar (histogram) graph control
	#hGraph4 = NewChild ($$GRAPHCLASSNAME, "", 0, 280, 240, 241, 101, #winMain, $$Graph4, 0)

	SendMessageA (#hGraph4, $$WM_SET_GRAPH_STYLE, 0, $$GS_BAR)
	SendMessageA (#hGraph4, $$WM_SET_GRAPH_LINE_WIDTHS, -1, 5)
	SendMessageA (#hGraph4, $$WM_SET_GRAPH_DIRECTION, 0, $$GRAPH_RIGHT)
	SendMessageA (#hGraph4, $$WM_SET_GRAPH_BACKCOLOR, 0, RGB(0,0,0))
	SendMessageA (#hGraph4, $$WM_SET_GRAPH_LINE_COLORS, RGB(0,128,0), RGB(0,255,0))
	SendMessageA (#hGraph4, $$WM_SET_GRAPH_FREEZE, 0, $$TRUE)

' create some pushbuttons
	#hButton1 = NewChild ("button", "Start", $$BS_PUSHBUTTON | $$BS_FLAT | $$WS_TABSTOP, 65, 200, 120, 22, #winMain, $$Button1, 0)
	#hButton2 = NewChild ("button", "Start", $$BS_PUSHBUTTON | $$BS_FLAT | $$WS_TABSTOP, 340, 200, 120, 22, #winMain, $$Button2, 0)
	#hButton3 = NewChild ("button", "Start", $$BS_PUSHBUTTON | $$BS_FLAT | $$WS_TABSTOP, 65, 350, 120, 22, #winMain, $$Button3, 0)
	#hButton4 = NewChild ("button", "Start", $$BS_PUSHBUTTON | $$BS_FLAT | $$WS_TABSTOP, 340, 350, 120, 22, #winMain, $$Button4, 0)

	#hButton5 = NewChild ("button", "Start All", $$BS_PUSHBUTTON | $$BS_FLAT | $$WS_TABSTOP, 205, 385, 120, 22, #winMain, $$Button5, 0)

	XstCenterWindow (#winMain)									' center window position
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
				IFZ IsDialogMessageA (#winMain, &msg) THEN
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
'
'
' ############################
' #####  RandomRange ()  #####
' ############################
'
FUNCTION  RandomRange (min, max)
	RETURN min + RandomUni () * (max-min)
END FUNCTION
'
'
' ##########################
' #####  RandomUni ()  #####
' ##########################
'
FUNCTION  DOUBLE RandomUni ()

	RETURN rand () / 32767.0

END FUNCTION
END PROGRAM
