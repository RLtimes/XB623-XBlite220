'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Simple PID Loop Simulator Demo used
' to control the level of a tank.
' ---
' VB code by Max Seim, mlseim@mmm.com
' Translated to XBlite by David Szafranski
' ---
' This program makes use of static controls as
' drawing elements. They are used as filled
' rectangles that can be altered in color or
' shape and turned on or off.
' --
' The example also uses graph.dll to display
' two dynamic graphs. A generic scrollbar
' function, UpdateScrollbars(), is used to
' update three scrollbar controls. And finally,
' a vertical progress bar is used as a tank
' setpoint indicator.
'
PROGRAM	"pid"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "msvcrt"		' msvcrt.dll
	IMPORT  "graph"			' graph.dll
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
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  SetAllChildWinFonts (hWndParent, hFont)
DECLARE FUNCTION  SetChildFontsProc (hWnd, hFont)
DECLARE FUNCTION  DrawTank (hdc)
DECLARE FUNCTION  Line (hDC, x1, y1, x2, y2)
DECLARE FUNCTION  TriangleFilled (hDC, color, fDirection, x1, y1, x2, y2)
DECLARE FUNCTION  HValve (hDC, x, y)
DECLARE FUNCTION  VValve (hDC, x, y)
DECLARE FUNCTION  CreateControls (hWnd)
DECLARE FUNCTION  UpdateScrollbars (hWnd, code, pos)
DECLARE FUNCTION  InitScrollbars ()
DECLARE FUNCTION  PIDLoop ()
DECLARE FUNCTION  WaterSupply ()
DECLARE FUNCTION  UpdateTank ()

' Menubar control IDs
$$ID_FILE_EXIT				= 100
$$ID_APP_ABOUT				= 110
$$ID_APP_HELP					= 111

$$IDC_BUTTON_WATERLEVEL = 200
$$IDC_BUTTON_AUTO				= 201
$$IDC_BUTTON_MANUAL			= 202

$$IDC_STATIC_GRAPH1			= 210
$$IDC_STATIC_GRAPH2			= 211
$$IDC_STATIC_ERROR			= 212
$$IDC_STATIC_SP					= 213
$$IDC_STATIC_OUT				= 214
$$IDC_STATIC_IN					= 215
$$IDC_STATIC_PV					= 216
$$IDC_STATIC_SUPPLY			= 217

$$IDC_EDIT_RATE					= 220
$$IDC_EDIT_RESET				= 221
$$IDC_EDIT_GAIN					= 222

$$IDC_VSCROLL_SETPOINT	= 230
$$IDC_HSCROLL_VALVEOUT	= 231
$$IDC_HSCROLL_VALVEIN		= 232

$$IDC_LABEL							= 240

$$IDC_GROUP_1						= 250
$$IDC_GROUP_2						= 251

$$IDC_PROGRESS					= 260

' triangle function constants
$$TriangleUp          = 0x0010
$$TriangleRight       = 0x0014
$$TriangleDown        = 0x0018
$$TriangleLeft        = 0x001C
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

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	SHARED hNewBrush, hInst
	PAINTSTRUCT ps
	STATIC mode					' 0 = manual, 1 = auto
	STATIC stability		' 0 = stable, 1 = unstable
	SHARED supply, inValve, outValve, sp, pv, gain, reset, rate, error
	SHARED fWater, fWater5, fWater6		' flags to reset static control colors

	SELECT CASE msg

		CASE $$WM_CREATE:
			CreateControls (hWnd)		' create all child controls
			InitScrollbars ()				' initialize scrollbar init settings, ranges

' initialize parameters
			mode 			= 1							' control mode - auto/manual
			supply 		= 2000					' supply flow rate (gal/min)
			inValve 	= supply / 60.0	' % open inlet valve
			outValve 	= 0							' % open outlet valve
			pv 				= 0							' process variable (current level of tank)
			sp 				= 1500					' setpoint (tank level in gallons)
			gain 			= 30						' gain
			reset 		= 3							' reset
			rate 			= 10						' rate

' put intitial text into controls
			SetWindowTextA (#static4, &"1500")		' sp
			SetWindowTextA (#edit1, &"10")				' rate
			SetWindowTextA (#edit2, &"3")					' reset
			SetWindowTextA (#edit3, &"30")				' gain
			SetWindowTextA (#static6, &"100")			' % in valve

' disable OUT valve horizontal scrollbar control
			SendMessageA (#hscroll2, $$SBM_ENABLE_ARROWS, $$ESB_DISABLE_BOTH, 0)

' check Auto radio button
			SendMessageA (#button2, $$BM_SETCHECK, $$BST_CHECKED, 0)

' set range of vertical progress bar and set init position
			SendMessageA (#progress, $$PBM_SETRANGE, 0, MAKELONG(0, 3100))
			SendMessageA (#progress, $$PBM_SETSTEP, 1, 0)
			SendMessageA (#progress, $$PBM_SETPOS, 1500, 0)

' create/start a timer
			SetTimer (hWnd, 1, 100, 0)						' set timer id 1, 100 ms time-out

		CASE $$WM_HSCROLL :
			hwndScrollBar = lParam
			code = LOWORD (wParam)
			pos = HIWORD (wParam)
			UpdateScrollbars (hwndScrollBar, code, pos)
			SELECT CASE hwndScrollBar
				CASE #hscroll1  :										' In Valve
					pos = GetScrollPos (hwndScrollBar, $$SB_CTL)
					inValve = pos * supply / 100.0 / 60.0
					text$ = STRING(pos)
					SetWindowTextA (#static6, &text$)
				CASE #hscroll2 :										' Out Valve
					pos = GetScrollPos (hwndScrollBar, $$SB_CTL)
					outValve = pos * 30 / 60.0
					text$ = STRING(pos)
					SetWindowTextA (#static5, &text$)
			END SELECT

		CASE $$WM_VSCROLL :
			hwndScrollBar = lParam
			code = LOWORD (wParam)
			pos = HIWORD (wParam)
			UpdateScrollbars (hwndScrollBar, code, pos)
			pos = GetScrollPos (hwndScrollBar, $$SB_CTL)	' scrollbar for setting SP
			sp = 3100 - pos																' calc sp
			text$ = STRING(sp)
			SetWindowTextA (#static4, &text$)							' display sp
			SendMessageA (#progress, $$PBM_SETPOS, sp, 0)	' update setpoint in progress bar control

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)
			DrawTank (hdc)
			EndPaint (hWnd, &ps)

		CASE $$WM_DESTROY:
			GOSUB Exit

		CASE $$WM_TIMER:
' get PID parameters, rate, reset, gain, from edit boxes
			text$ = NULL$(256)
			SendMessageA (#edit1, $$WM_GETTEXT, 256, &text$)
			rate = XLONG (CSIZE$(text$))
			IF rate < 0 THEN
				rate = 0
				text$ = STRING(rate)
				SetWindowTextA (#edit1, &text$)
			ELSE
				IF rate > 120 THEN
					rate = 120
					text$ = STRING(rate)
					SetWindowTextA (#edit1, &text$)
				END IF
			END IF

			text$ = NULL$(256)
			SendMessageA (#edit2, $$WM_GETTEXT, 256, &text$)
			reset = XLONG (CSIZE$(text$))
			IF reset < 0 THEN
				reset = 0
				text$ = STRING(reset)
				SetWindowTextA (#edit2, &text$)
			ELSE
				IF reset > 120 THEN
					reset = 120
					text$ = STRING(reset)
					SetWindowTextA (#edit2, &text$)
				END IF
			END IF

			text$ = NULL$(256)
			SendMessageA (#edit3, $$WM_GETTEXT, 256, &text$)
			gain = XLONG (CSIZE$(text$))
			IF gain < 0 THEN
				gain = 0
				text$ = STRING(gain)
				SetWindowTextA (#edit3, &text$)
			ELSE
				IF gain > 100 THEN
					gain = 100
					text$ = STRING(gain)
					SetWindowTextA (#edit3, &text$)
				END IF
			END IF

' sum up present value of liquid in the tank
' ie, current sum = current sum + inflow - outflow

			IF pv < 3101 THEN
				pv = pv + inValve
			END IF

			IF pv > 3100 THEN pv = 3100

			outValve = GetScrollPos (#hscroll2, $$SB_CTL) * 30 / 60.0
			IF pv > 0 THEN
				pv = pv - outValve
			END IF

' calc error
			error = sp - pv

' update labels
			text$ = STRING(error)
			SetWindowTextA (#static3, &text$)

			text$ = STRING(supply)
			SetWindowTextA (#static8, &text$)

			text$ = STRING(pv)
			SetWindowTextA (#static7, &text$)

' draw liquid level in tank
			UpdateTank ()

' create an unstable water supply
			IF stability THEN
				WaterSupply ()
				inValve = GetScrollPos (#hscroll1, $$SB_CTL) * supply / 100.0 / 60.0
			END IF

' do the control loop under automatic control
			IF mode THEN PIDLoop ()

' update the two process graphs (value range 0-100)
			SendMessageA (#graph1, $$WM_GRAPH_UPDATE, 0, pv/3100.0*100.0)
			SendMessageA (#graph2, $$WM_GRAPH_UPDATE, 0, GetScrollPos (#hscroll2, $$SB_CTL))

		CASE $$WM_COMMAND:
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$ID_FILE_EXIT:
					GOSUB Exit

				CASE $$IDC_BUTTON_MANUAL:
					mode = 0
					SendMessageA (#hscroll2, $$SBM_ENABLE_ARROWS, $$ESB_ENABLE_BOTH, 0)

				CASE $$IDC_BUTTON_AUTO:
					mode = 1
					SendMessageA (#hscroll2, $$SBM_ENABLE_ARROWS, $$ESB_DISABLE_BOTH, 0)

				CASE $$IDC_BUTTON_WATERLEVEL:
					IFZ stability THEN			' toggle unstable water supply flag
						stability = 1
					ELSE
						stability = 0
						supply = 2000
					END IF

				CASE $$ID_APP_ABOUT:
					MessageBoxA (hWnd, &"PID Loop Simulator\nVB Code by Max Seim\nXBLite implementation by David Szafranski\nAugust 2002", &"About PID", $$MB_OK | $$MB_ICONINFORMATION)

			END SELECT

		CASE $$WM_CTLCOLORSTATIC :
			bkColor = GetSysColor ($$COLOR_BTNFACE)
			hdcStatic = wParam
			hwndStatic = lParam
			SELECT CASE hwndStatic					' change the text and background colors

				CASE #label9, #label10, #label11, #label22 :	' red text, gray bg
					RETURN SetColor (0xFF, bkColor, wParam, lParam)

				CASE #label17, #label18, #static8 :						' blue text, gray bg
					RETURN SetColor (0xFF0000, bkColor, wParam, lParam)

				CASE #static1, #static2 :											' black text, black bg
					RETURN SetColor (0, 0, wParam, lParam)

				CASE #water3, #water4 :	' black text, cyan bg
					RETURN SetColor (0, 0x00FFFF00, wParam, lParam)

				CASE #water1, #water2 :												' alternate between blue and white bg
					IF fWater THEN
						RETURN SetColor (0, 0x00FFFF00, wParam, lParam)
					ELSE
						RETURN SetColor (0, 0x00FFFFFF, wParam, lParam)
					END IF

				CASE #water5 :												' alternate between blue and white bg
					IF fWater5 THEN
						RETURN SetColor (0, 0x00FFFF00, wParam, lParam)
					ELSE
						RETURN SetColor (0, 0x00FFFFFF, wParam, lParam)
					END IF

				CASE #water6 :												' alternate between blue and white bg
					IF fWater6 THEN
						RETURN SetColor (0, 0x00FFFF00, wParam, lParam)
					ELSE
						RETURN SetColor (0, 0x00FFFFFF, wParam, lParam)
					END IF

				CASE #static3, #static4, #static5, #static6, #static7:	' do nothing

				CASE ELSE:																		' black text, gray bg
					RETURN SetColor (0, bkColor, wParam, lParam)
			END SELECT

		CASE $$WM_CTLCOLORBTN :
'			hdcStatic = wParam
'			hwndStatic = lParam
			bkColor = GetSysColor ($$COLOR_BTNFACE)
			RETURN SetColor (0, bkColor, wParam, lParam)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

' ***** Exit *****
SUB Exit
	KillTimer (hWnd, 1)
	DeleteObject (hNewBrush)
	DeleteObject (#hFontMSSS10)
	DeleteObject (#hFontMSSS10B)
	DeleteObject (#hFontMSSS14B)
	PostQuitMessage(0)
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

	SHARED className$

' register window class
	className$  = "PIDDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Simple PID Loop Simulator - Industrial Level Controller."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 640
	h 					= 548
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	UpdateWindow (#winMain)
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
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA(hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underline (0 or 1)
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle


END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	RETURN SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush

	SetTextColor (wParam, txtColor)
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION
'
'
' ####################################
' #####  SetAllChildWinFonts ()  #####
' ####################################
'
FUNCTION  SetAllChildWinFonts (hWndParent, hFont)

	EnumChildWindows (hWndParent, &SetChildFontsProc(), hFont)

END FUNCTION
'
'
' ##################################
' #####  SetChildFontsProc ()  #####
' ##################################
'
FUNCTION  SetChildFontsProc (hWnd, hFont)

	SetNewFont (hWnd, hFont)
	RETURN $$TRUE

END FUNCTION
'
'
' #########################
' #####  DrawTank ()  #####
' #########################
'
' Draw tank, pipes, and valves
'
FUNCTION  DrawTank (hdc)

' fill rectangle using custom color brushes
' no outline for rectangle by using NULL_PEN

	SelectObject (hdc, GetStockObject ($$NULL_PEN))
	hBrush = CreateSolidBrush (0x00FFFFFF)		' white
	hOld = SelectObject (hdc, hBrush)
	Rectangle (hdc, 110, 82, 247, 283)				' fill tank with white color
	SelectObject (hdc, hOld)
	DeleteObject (hBrush)
	SelectObject (hdc, GetStockObject ($$BLACK_PEN))

' draw water in pipes as filled rectangles
	SelectObject (hdc, GetStockObject ($$NULL_PEN))
	hBrush = CreateSolidBrush (0x00FFFF00)		' 0x0000FFFF = yellow
	hOld = SelectObject (hdc, hBrush)
	Rectangle (hdc, 12, 42, 50, 54)				' top valve in
'	Rectangle (hdc, 80, 42, 145, 54)			' top valve out1
'	Rectangle (hdc, 144, 42, 156, 83)			' top valve out2
'	Rectangle (hdc, 144, 82, 156, 184)		' stream into tank (variable height)
'	Rectangle (hdc, 110, 183, 247, 283)		' water in tank (variable height)
'	Rectangle (hdc, 172, 282, 184, 308)		' bottom valve in
'	Rectangle (hdc, 172, 335, 184, 386)		' bottom valve out
	SelectObject (hdc, hOld)
	DeleteObject (hBrush)
	SelectObject (hdc, GetStockObject ($$BLACK_PEN))

' draw outside border of tank
	hPen = CreatePen ($$PS_SOLID, 4, 0)			' create black pen, width 4
	hOld = SelectObject (hdc, hPen)					' select pen
	Line (hdc, 108, 80, 142, 80)
	Line (hdc, 157, 80, 248, 80)
	Line (hdc, 248, 80, 248, 284)
	Line (hdc, 108, 284, 170, 284)
	Line (hdc, 185, 284, 248, 284)
	Line (hdc, 108, 80, 108, 284)
	SelectObject (hdc, hOld)
	DeleteObject (hPen)

' draw pipes
	Line (hdc, 12, 41, 49, 41)			' valve in top
	Line (hdc, 12, 53, 49, 53)

	Line (hdc, 80, 41, 155, 41)			' valve out top
	Line (hdc, 80, 53, 143, 53)
	Line (hdc, 143, 53, 143, 80)
	Line (hdc, 155, 41, 155, 80)

	Line (hdc, 171, 282, 171, 307)	' valve in bottom
	Line (hdc, 183, 282, 183, 307)

	Line (hdc, 171, 335, 171, 374)	' valve out bottom
	Line (hdc, 183, 335, 183, 374)

' draw valves
	HValve (hdc, 49, 40)
	VValve (hdc, 169, 304)

END FUNCTION
'
'
' #####################
' #####  Line ()  #####
' #####################
'
FUNCTION  Line (hDC, x1, y1, x2, y2)

	MoveToEx (hDC, x1, y1, 0)
	LineTo (hDC, x2, y2)

END FUNCTION
'
'
' ###############################
' #####  TriangleFilled ()  #####
' ###############################
'
' Draw a filled triangle in one of these directions:
'  $$TriangleUp
'  $$TriangleRight
'  $$TriangleDown
'  $$TriangleLeft
'
FUNCTION  TriangleFilled (hDC, color, fDirection, x1, y1, x2, y2)

	BITMAP bmp
	RECT rect

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC :
			hWnd = WindowFromDC (hDC)
			IFZ hWnd THEN RETURN
			GetClientRect (hWnd, &rect)
			w = rect.right
			h = rect.bottom
			IFZ w * h THEN RETURN

		CASE $$OBJ_MEMDC 	:
			hBmp = GetCurrentObject (hDC, $$OBJ_BITMAP)
			IFZ hBmp THEN RETURN
			GetObjectA (hBmp, SIZE(bmp), &bmp)
			w = bmp.width
			h = bmp.height
			IFZ w * h THEN RETURN
		CASE ELSE 									: RETURN
	END SELECT

	way = fDirection AND 0x001E
	IFZ way THEN RETURN

	IFZ (x1 OR y1 OR x2 OR y2) THEN
		x1 = 4
		y1 = 4
		x2 = w-5
		y2 = h-5
	END IF
'
	IF (x1 > x2) THEN SWAP x1, x2
	IF (y1 > y2) THEN SWAP y1, y2
	IF (x1 < 0) THEN x1 = 0
	IF (y1 < 0) THEN y1 = 0
	IF (x2 > (w-1)) THEN x2 = w-1
	IF (y2 > (h-1)) THEN y2 = h-1
	IF (x1 > x2) THEN SWAP x1, x2
	IF (y1 > y2) THEN SWAP y1, y2
'
	xx1 = x1 << 15
	xx2 = x2 << 15
	yy1 = y1 << 15
	yy2 = y2 << 15
	ddx = xx2 - xx1
	ddy = yy2 - yy1
	dx = x2 - x1
	dy = y2 - y1
'
	xxx = x1 + (dx >> 1)			' xxx = horizontal center of arrow
	yyy = y1 + (dy >> 1)			' yyy = vertical center of arrow
'
	xx = 0
	yy = 0
	dt = 0
	dh = ddy \ dx							' potential horizontal step size
	dv = ddx \ dy							' potential vertical step size

	hPen = CreatePen ($$PS_SOLID, 1, color)
	hOld = SelectObject (hDC, hPen)
'
	SELECT CASE way
		CASE $$TriangleUp			: GOSUB TriangleUp
		CASE $$TriangleRight	: GOSUB TriangleRight
		CASE $$TriangleDown		: GOSUB TriangleDown
		CASE $$TriangleLeft		: GOSUB TriangleLeft
	END SELECT
'
	SelectObject (hDC, hOld)
	DeleteObject (hPen)
	RETURN ($$TRUE)
'
'
' *****  TriangleUp  *****
'
SUB TriangleUp
	FOR y = y1 TO y2
		xx1 = xxx - (dt >> 16)
		xx2 = xxx + (dt >> 16) + 1
		MoveToEx (hDC, xx1, y, 0)
		LineTo (hDC, xx2, y)
		dt = dt + dv
	NEXT y
END SUB
'
'
' *****  TriangleRight  *****
'
SUB TriangleRight
	FOR x = x2 TO x1 STEP -1
		yy1 = yyy - (dt >> 16)
		yy2 = yyy + (dt >> 16) + 1
		MoveToEx (hDC, x, yy1, 0)
		LineTo (hDC, x, yy2)
		dt = dt + dh
	NEXT x
END SUB
'
'
' *****  TriangleDown  *****
'
SUB TriangleDown
	FOR y = y2 TO y1 STEP -1
		xx1 = xxx - (dt >> 16)
		xx2 = xxx + (dt >> 16) + 1
		MoveToEx (hDC, xx1, y, 0)
		LineTo (hDC, xx2, y)
		dt = dt + dv
	NEXT y
END SUB
'
'
' *****  TriangleLeft  *****
'
SUB TriangleLeft
	FOR x = x1 TO x2
		yy1 = yyy - (dt >> 16)
		yy2 = yyy + (dt >> 16) + 1
		MoveToEx (hDC, x, yy1, 0)
		LineTo (hDC, x, yy2)
		dt = dt + dh
	NEXT x
END SUB


END FUNCTION
'
'
' #######################
' #####  HValve ()  #####
' #######################
'
' Draw a horizontal valve with upper left corner at x, y
'
FUNCTION  HValve (hDC, x, y)

' draw horizontal valve
	TriangleFilled (hDC, 0, $$TriangleRight, x,    y, x+16,    y+16)
	TriangleFilled (hDC, 0, $$TriangleLeft,  x+14, y, x+14+16, y+16)

END FUNCTION
'
'
' #######################
' #####  VValve ()  #####
' #######################
'
' Draw a vertical valve with upper left corner at x, y
'
FUNCTION  VValve (hDC, x, y)

' draw vertical valve
	TriangleFilled (hDC, 0, $$TriangleDown, x, y,    x+16, y+16)
	TriangleFilled (hDC, 0, $$TriangleUp,   x, y+14, x+16, y+14+16)

END FUNCTION
'
'
' ###############################
' #####  CreateControls ()  #####
' ###############################
'
FUNCTION  CreateControls (hWnd)

' create all child controls

'	#static1 = NewChild ("static", "", $$SS_LEFT, 45,  410, 275, 75, hWnd, $$IDC_STATIC_GRAPH1, $$WS_EX_CLIENTEDGE)
'	#static2 = NewChild ("static", "", $$SS_LEFT, 346, 410, 275, 75, hWnd, $$IDC_STATIC_GRAPH2, $$WS_EX_CLIENTEDGE)

	#static4 = NewChild ("static", "", $$SS_LEFT, 328, 178, 43,  19, hWnd, $$IDC_STATIC_SP, $$WS_EX_CLIENTEDGE)
	#static5 = NewChild ("static", "", $$SS_LEFT, 235, 338, 43,  19, hWnd, $$IDC_STATIC_OUT, $$WS_EX_CLIENTEDGE)
	#static6 = NewChild ("static", "", $$SS_LEFT, 80,  18,  43,  19, hWnd, $$IDC_STATIC_IN, $$WS_EX_CLIENTEDGE)
	#static7 = NewChild ("static", "", $$SS_LEFT, 44,  178, 45,  19, hWnd, $$IDC_STATIC_PV, $$WS_EX_CLIENTEDGE)
	#static8 = NewChild ("static", "", $$SS_LEFT, 8,   96,  24,  15, hWnd, $$IDC_STATIC_SUPPLY, 0)

	#group1  = NewChild ("button", "Controller Properties", $$BS_GROUPBOX, 394, 12, 226, 224, hWnd, $$IDC_GROUP_1, 0)

	#button2 = NewChild ("button", "Auto Control", 		$$BS_AUTORADIOBUTTON, 406, 60, 100, 21, hWnd, $$IDC_BUTTON_AUTO, 0)
	#button3 = NewChild ("button", "Manual Control", 	$$BS_AUTORADIOBUTTON, 406, 36, 100, 21, hWnd, $$IDC_BUTTON_MANUAL, 0)

	#label16 = NewChild ("static", "Proportional (Gain)", 		$$SS_RIGHT, 414, 94,  90, 15, hWnd, $$IDC_LABEL, 0)
	#label15 = NewChild ("static", "Integral (Reset)", 				$$SS_RIGHT, 414, 120, 90, 15, hWnd, $$IDC_LABEL, 0)
	#label14 = NewChild ("static", "Derivitave (Rate)", 			$$SS_RIGHT, 414, 146, 90, 15, hWnd, $$IDC_LABEL, 0)
	#label8 =  NewChild ("static", "e = Error (Difference)", 	$$SS_RIGHT, 405, 172, 99, 15, hWnd, $$IDC_LABEL, 0)

	#edit3   = NewChild ("edit", "", $$ES_NUMBER | $$ES_AUTOHSCROLL, 	510, 92, 43, 19, hWnd, $$IDC_EDIT_GAIN, $$WS_EX_CLIENTEDGE)
	#edit2   = NewChild ("edit", "", $$ES_NUMBER | $$ES_AUTOHSCROLL, 	510, 118, 43, 19, hWnd, $$IDC_EDIT_RESET, $$WS_EX_CLIENTEDGE)
	#edit1   = NewChild ("edit", "", $$ES_NUMBER | $$ES_AUTOHSCROLL, 	510, 144, 43, 19, hWnd, $$IDC_EDIT_RATE, $$WS_EX_CLIENTEDGE)
	#static3 = NewChild ("static", "", $$SS_LEFT, 										510, 170, 43, 19, hWnd, $$IDC_STATIC_ERROR, $$WS_EX_CLIENTEDGE)

	#label13 = NewChild ("static", "0 - 100%", $$SS_LEFT, 557, 96,  50, 15, hWnd, $$IDC_LABEL, 0)
	#label12 = NewChild ("static", "0 - 120",  $$SS_LEFT, 557, 122, 40, 15, hWnd, $$IDC_LABEL, 0)
	#label7  = NewChild ("static", "0 - 120",  $$SS_LEFT, 557, 148, 40, 15, hWnd, $$IDC_LABEL, 0)
	#label6  = NewChild ("static", "SP - PV",  $$SS_LEFT, 557, 174, 40, 15, hWnd, $$IDC_LABEL, 0)

	#button1 = NewChild ("button", "Create Unstable Water Supply", $$BS_AUTOCHECKBOX, 405, 198, 164, 21, hWnd, $$IDC_BUTTON_WATERLEVEL, 0)

	#vscroll1 = NewChild ("scrollbar", "", $$SBS_VERT, 268, 64, 17, 236, hWnd, $$IDC_VSCROLL_SETPOINT, 0)
	#hscroll2 = NewChild ("scrollbar", "", $$SBS_HORZ, 54, 310, 91, 17, hWnd, $$IDC_HSCROLL_VALVEIN, 0)
	#hscroll1 = NewChild ("scrollbar", "", $$SBS_HORZ, 12, 62, 89, 17, hWnd, $$IDC_HSCROLL_VALVEOUT, 0)

	#label1 = NewChild ("static", "Process Variable - PV", $$SS_LEFT, 125, 394, 129, 15, hWnd, $$IDC_LABEL, 0)
	#label2 = NewChild ("static", "Output Valve Position", $$SS_LEFT, 414, 394, 129, 15, hWnd, $$IDC_LABEL, 0)
	#label3 = NewChild ("static", "100%", $$SS_RIGHT, 12, 410, 29, 15, hWnd, $$IDC_LABEL, 0)
	#label4 = NewChild ("static", "0%", $$SS_RIGHT,   12, 470, 29, 15, hWnd, $$IDC_LABEL, 0)
	#label5 = NewChild ("static", "% Valve Position", $$SS_LEFT, 186, 358, 83, 15, hWnd, $$IDC_LABEL, 0)

	#label9 = NewChild ("static", "OUT", $$SS_LEFT, 186, 334, 43, 25, hWnd, $$IDC_LABEL, 0)
	#label10 = NewChild ("static", "SP", $$SS_LEFT, 294, 176, 33, 25, hWnd, $$IDC_LABEL, 0)
	#label11 = NewChild ("static", "PV", $$SS_LEFT, 10, 176, 33, 25, hWnd, $$IDC_LABEL, 0)
	#label22 = NewChild ("static", "IN", $$SS_LEFT, 54, 16, 24, 25, hWnd, $$IDC_LABEL, 0)

	#label17 = NewChild ("static", "3000 Gal/Min Max", $$SS_LEFT, 52, 342, 95, 15, hWnd, $$IDC_LABEL, 0)
	#label18 = NewChild ("static", " Gal/Min Max", $$SS_LEFT, 32, 96, 67, 15, hWnd, $$IDC_LABEL, 0)
	#label19 = NewChild ("static", "Actual Level", $$SS_LEFT, 50, 198, 35, 29, hWnd, $$IDC_LABEL, 0)
	#label21 = NewChild ("static", "3100 Gal Tank", $$SS_LEFT, 18, 160, 80, 15, hWnd, $$IDC_LABEL, 0)
	#label23 = NewChild ("static", "Setpoint Level (Gallons)", $$SS_LEFT, 294, 200, 90, 15, hWnd, $$IDC_LABEL, 0)
	#label24 = NewChild ("static", "Position 0-100%", $$SS_LEFT, 60, 328, 81, 15, hWnd, $$IDC_LABEL, 0)
	#label25 = NewChild ("static", "Control Valve", $$SS_RIGHT, 62, 292, 80, 15, hWnd, $$IDC_LABEL, 0)
	#label26 = NewChild ("static", "Position 0-100%", $$SS_LEFT, 14, 80, 79, 15, hWnd, $$IDC_LABEL, 0)
	#label27 = NewChild ("static", "% Manual Valve Position", $$SS_LEFT, 125, 20, 120, 15, hWnd, $$IDC_LABEL, 0)

' static controls used as shapes for drawing water in tank and lines
' these shapes are turned on/off or resized as necessary
	#water1 = NewChild ("static", "", $$SS_LEFT, 80,  42,  64,  11, hWnd, $$IDC_LABEL, 0)		' top valve out1
	#water2 = NewChild ("static", "", $$SS_LEFT, 144, 42,  11,  40, hWnd, $$IDC_LABEL, 0)		' top valve out2
	#water4 = NewChild ("static", "", $$SS_LEFT, 110, 183, 136, 99, hWnd, $$IDC_LABEL, 0)		' water in tank (variable height)
	#water3 = NewChild ("static", "", $$SS_LEFT, 144, 82,  11,  200, hWnd, $$IDC_LABEL, 0)	' stream into tank (variable height)
	#water5 = NewChild ("static", "", $$SS_LEFT, 172, 282, 11,  22, hWnd, $$IDC_LABEL, 0)		' bottom valve in
	#water6 = NewChild ("static", "", $$SS_LEFT, 172, 335, 11,  39, hWnd, $$IDC_LABEL, 0)		' bottom valve out

' create a vertical progress control to use as a level indicator
	#progress = NewChild ($$PROGRESS_CLASS, "", $$PBS_VERTICAL | $$PBS_SMOOTH, 250, 80, 12, 204, hWnd, $$IDC_PROGRESS, 0)

' a group box to frame bitmap
	#group2  = NewChild ("button", "Controller Schematic", $$BS_GROUPBOX, 346, 252, 275, 124, hWnd, $$IDC_GROUP_2, 0)

' create a static control to display the pid schematic bitmap
	#bitmap = NewChild ("static", "pid", $$SS_BITMAP, 358, 270, 0, 0, hWnd, $$IDC_LABEL, 0)

' create two dynamic graphs using graph.dll
	#graph1 = NewChild ($$GRAPHCLASSNAME, "", 0, 45,  410, 275, 75, hWnd, $$IDC_STATIC_GRAPH1, $$WS_EX_CLIENTEDGE)
	#graph2 = NewChild ($$GRAPHCLASSNAME, "", 0, 346, 410, 275, 75, hWnd, $$IDC_STATIC_GRAPH2, $$WS_EX_CLIENTEDGE)

' set graph properties
	SendMessageA (#graph1, $$WM_SET_GRAPH_STYLE, 0, $$GS_BAR)
	SendMessageA (#graph1, $$WM_SET_GRAPH_LINE_WIDTHS, -1, 2)
	SendMessageA (#graph1, $$WM_SET_GRAPH_STEPSIZE, 0, 2)
	SendMessageA (#graph1, $$WM_SET_GRAPH_GRID_UNITS, 0, 10)
	SendMessageA (#graph1, $$WM_SET_GRAPH_LINE_COLORS, -1, 0xFFFF00)

	SendMessageA (#graph2, $$WM_SET_GRAPH_LINE_WIDTHS, -1, 2)
	SendMessageA (#graph2, $$WM_SET_GRAPH_STEPSIZE, 0, 2)
	SendMessageA (#graph2, $$WM_SET_GRAPH_GRID_UNITS, 0, 10)


' create some new fonts
	#hFontMSSS10  = NewFont ("MS Sans Serif", 8, $$FW_NORMAL, $$FALSE, $$FALSE)
	#hFontMSSS10B  = NewFont ("MS Sans Serif", 8, $$FW_BOLD, $$FALSE, $$FALSE)
	#hFontMSSS14B = NewFont ("MS Sans Serif", 14, $$FW_BOLD, $$FALSE, $$FALSE)

' set a new font to all child controls
	SetAllChildWinFonts (hWnd, #hFontMSSS10)
	SetNewFont (#static3, #hFontMSSS10B)
	SetNewFont (#static4, #hFontMSSS10B)
	SetNewFont (#static5, #hFontMSSS10B)
	SetNewFont (#static6, #hFontMSSS10B)
	SetNewFont (#static7, #hFontMSSS10B)
	SetNewFont (#edit1, #hFontMSSS10B)
	SetNewFont (#edit2, #hFontMSSS10B)
	SetNewFont (#edit3, #hFontMSSS10B)
	SetNewFont (#label1, #hFontMSSS10B)
	SetNewFont (#label2, #hFontMSSS10B)
	SetNewFont (#label9, #hFontMSSS14B)
	SetNewFont (#label10, #hFontMSSS14B)
	SetNewFont (#label11, #hFontMSSS14B)
	SetNewFont (#label22, #hFontMSSS14B)


END FUNCTION
'
'
' #################################
' #####  UpdateScrollbars ()  #####
' #################################
'
FUNCTION  UpdateScrollbars (hWnd, code, pos)

'	SCROLLINFO scrollInfo

'  GetScrollInfo (hWnd, $$SB_CTL, &scrollInfo)		' get information about the scroll

  SELECT CASE code

		CASE $$SB_LINEDOWN:       ' Scrolls one line down
			SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) + 1, $$TRUE)
			RETURN

		CASE $$SB_LINEUP:         ' Scrolls one line up
			SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) - 1, $$TRUE)
			RETURN

		CASE $$SB_PAGEDOWN:       ' Scrolls one page down
      SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) + 10, $$TRUE)
			RETURN

		CASE $$SB_PAGEUP:         	' Scrolls one page up
      SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) - 10, $$TRUE)
			RETURN

		CASE $$SB_THUMBPOSITION:  ' The user has dragged the scroll box (thumb) and released the mouse button. The nPos parameter indicates the position of the scroll box at the end of the drag operation.
			RETURN

		CASE $$SB_THUMBTRACK:     	' The user is dragging the scroll box. This message is sent repeatedly until the user releases the mouse button. The nPos parameter indicates the position that the scroll box has been dragged to.
			SetScrollPos (hWnd, $$SB_CTL, pos, $$TRUE)
			RETURN

	END SELECT


END FUNCTION
'
'
' ###############################
' #####  InitScrollbars ()  #####
' ###############################
'
FUNCTION  InitScrollbars ()

	SCROLLINFO ScrollInfoV1, ScrollInfoH1, ScrollInfoH2

	ScrollInfoV1.cbSize = SIZE(ScrollInfoV1)				' size of this structure
	ScrollInfoV1.fMask = $$SIF_ALL                 	' parameters to set
	ScrollInfoV1.nMin = 0                        		' minimum scrolling position
	ScrollInfoV1.nMax = 3100                      	' maximum scrolling position
	ScrollInfoV1.nPage = 1                      		' the page size of the scroll box
	ScrollInfoV1.nPos = 1500                       	' initial position of the scroll box
	ScrollInfoV1.nTrackPos = 0                   		' immediate position of a scroll box that the user is dragging
	SetScrollInfo (#vscroll1, $$SB_CTL, &ScrollInfoV1, $$TRUE)

	ScrollInfoH1.cbSize = SIZE(ScrollInfoH1)				' size of this structure
	ScrollInfoH1.fMask = $$SIF_ALL                 	' parameters to set
	ScrollInfoH1.nMin = 0                        		' minimum scrolling position
	ScrollInfoH1.nMax = 100                      		' maximum scrolling position
	ScrollInfoH1.nPage = 1                      		' the page size of the scroll box
	ScrollInfoH1.nPos = 100                       	' initial position of the scroll box
	ScrollInfoH1.nTrackPos = 0                   		' immediate position of a scroll box that the user is dragging
	SetScrollInfo (#hscroll1, $$SB_CTL, &ScrollInfoH1, $$TRUE)

	ScrollInfoH2.cbSize = SIZE(ScrollInfoH2)				' size of this structure
	ScrollInfoH2.fMask = $$SIF_ALL                 	' parameters to set
	ScrollInfoH2.nMin = 0                        		' minimum scrolling position
	ScrollInfoH2.nMax = 100                      		' maximum scrolling position
	ScrollInfoH2.nPage = 1                      		' the page size of the scroll box
	ScrollInfoH2.nPos = 0                       		' initial position of the scroll box
	ScrollInfoH2.nTrackPos = 0                   		' immediate position of a scroll box that the user is dragging
	SetScrollInfo (#hscroll2, $$SB_CTL, &ScrollInfoH2, $$TRUE)

END FUNCTION
'
'
' ########################
' #####  PIDLoop ()  #####
' ########################
'
FUNCTION  PIDLoop ()

	SHARED supply, inValve, outValve, sp, pv, gain, reset, rate, error
	STATIC inputlast, inputdf, feedback

	$dfilter = 10									' filter value to scale down derivative effect.

	inputd = pv + (inputlast - pv) * (rate / 60.0)
	inputlast = pv
	inputdf = inputdf + (inputd - inputdf) * $dfilter / 60.0
	output = (sp - inputdf) * (gain / 100.0) + feedback

	IF output > 100 THEN output = 100		' clamp output valve between 0 and 100%
	IF output < 0 THEN output = 0

	pos = 100 - output 									' change slider value (AUTO MODE) for OUT valve
	SetScrollPos (#hscroll2, $$SB_CTL, pos, $$TRUE)

	text$ = STRING(pos)
	SetWindowTextA (#static5, &text$)		' OUT

	feedback = feedback - (feedback - output) * reset / 60.0

END FUNCTION
'
'
' ############################
' #####  WaterSupply ()  #####
' ############################
'
FUNCTION  WaterSupply ()

	SHARED supply
	STATIC seed

' create an unstable water supply

	IFZ seed THEN GOSUB MakeSeed

	s1 = rand () / 32767.0 * 40 + 1
	s2 = rand () / 32767.0 * 1000 + 1

	IF s2 < 50 THEN
		supply = supply + s1
	ELSE
		IF s2 > 950 THEN supply = supply - s1
	END IF

	IF supply < 500 THEN
		supply = 500
	ELSE
		IF supply > 2500 THEN supply = 2500
	END IF

' ***** MakeSeed *****
SUB MakeSeed
	seed = (GetTickCount () MOD 32767) + 1
	srand (seed)
END SUB

END FUNCTION
'
'
' ###########################
' #####  UpdateTank ()  #####
' ###########################
'
FUNCTION  UpdateTank ()

	SHARED pv
	STATIC pvLast, hPos1Last, hPos2Last
	SHARED fWater, fWater5, fWater6

' animate the water level in the tank and in pipes

	hPos1 = GetScrollPos (#hscroll1, $$SB_CTL)	' inlet valve position
	hPos2 = GetScrollPos (#hscroll2, $$SB_CTL)	' outlet valve position

' if inlet valve is open then display shapes/controls water1-2-3
' or change their backcolor from blue/white
	IF hPos1 != hPos1Last THEN
		IF hPos1 > 0 THEN
			fWater = $$TRUE									' water is on, set blue background
			ShowWindow (#water3, $$SW_SHOW)	' show water
		ELSE
			fWater = $$FALSE								' water is off, set white background
			ShowWindow (#water3, $$SW_HIDE)	' hide water
		END IF
		InvalidateRect (#water1, NULL, $$TRUE)	' redraw control, new WM_CTLCOLORSTATIC msg
		InvalidateRect (#water2, NULL, $$TRUE)
	END IF

' draw the water level in tank - water control 4
' total height = 200
' bottom of tank = 282

	IF pv != pvLast THEN
		IF pv > -1 THEN
			height 	= pv/3100.0 * 200
			width 	= 136
			x 			= 110
			y 			= 282 - height
			ShowWindow (#water4, $$SW_SHOW)
			MoveWindow (#water4, x, y, width, height, $$TRUE)
		ELSE
			ShowWindow (#water4, $$SW_HIDE)
		END IF
	END IF

' change color of water control 5 if inlet
' valve is open or there is still water in tank
	IF (pv != pvLast) OR (hPos1 != hPos1Last) THEN
		IF (pv > 0) OR (hPos1 > 0) THEN
			fWater5 = $$TRUE
		ELSE
			fWater5 = $$FALSE
  	END IF
		InvalidateRect (#water5, NULL, $$TRUE)
	END IF

' change color of water control 6 if outlet valve is
' open and there is still water in tank
	IF (pv != pvLast) OR (hPos1 != hPos1Last) OR (hPos2 != hPos2Last) THEN
		IF ((hPos2 > 0) AND (pv > 0)) OR ((hPos2 > 0) AND (hPos1 > 0)) THEN
			fWater6 = $$TRUE
		ELSE
			fWater6 = $$FALSE
  	END IF
		InvalidateRect (#water6, NULL, $$TRUE)
	END IF

	pvLast = pv
	hPos1Last = hPos1
	hPos2Last = hPos2


END FUNCTION
END PROGRAM
