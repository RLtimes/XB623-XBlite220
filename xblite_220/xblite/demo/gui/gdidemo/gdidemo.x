'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demonstration of using various win32 API
' drawing functions in gdi32.dll.
'
PROGRAM	"gdidemo"
VERSION	"0.0002"
'
	IMPORT	"xst_s.lib"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll
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

' buffer functions
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hMemDC)

' test functions
DECLARE FUNCTION  DrawEdgeTest ()
DECLARE FUNCTION  DrawFrameControlTest ()
DECLARE FUNCTION  DrawBorderTest ()
DECLARE FUNCTION  LineToTest ()
DECLARE FUNCTION  ExtCreatePenTest ()
DECLARE FUNCTION  TriangleTest ()
DECLARE FUNCTION  TriangleFilledTest ()
DECLARE FUNCTION  PolyBezierTest ()
DECLARE FUNCTION  DrawArcTest ()
DECLARE FUNCTION  EllipseToBezierTest ()
DECLARE FUNCTION  SetPixelTest ()
DECLARE FUNCTION  DrawFocusRectTest ()
DECLARE FUNCTION  RectangleTest ()
DECLARE FUNCTION  CreatePatternBrushTest ()
DECLARE FUNCTION  DrawPieTest ()
DECLARE FUNCTION  HLSGradientRectTest ()
DECLARE FUNCTION  PolygonTest ()
DECLARE FUNCTION  SelectClipRgnTest ()
DECLARE FUNCTION  ExtFloodFillTest ()
DECLARE FUNCTION  LineDDATest ()
DECLARE FUNCTION  LineDDAProc (x, y, lpData)

' drawing functions
DECLARE FUNCTION  CircleBresenham (hDC, x, y, r, color)
DECLARE FUNCTION  DotFillRect (hDC, x1, y1, x2, y2, color)
DECLARE FUNCTION  DottedRectangle (hDC, x1, y1, x2, y2)
DECLARE FUNCTION  DrawArc (hDC, r, startAngle#, endAngle#)
DECLARE FUNCTION  DrawBorder (hDC, fBorder, back, lo, hi, x1, y1, x2, y2)
DECLARE FUNCTION  DrawControls (hDC, type, @state[])
DECLARE FUNCTION  DrawGradientRect (hDC, x1, y1, x2, y2, color1, color2, mode)
DECLARE FUNCTION  DrawPie (hDC, r, startAngle#, endAngle#)
DECLARE FUNCTION  DrawPieChart (hDC, x, y, r, color, DOUBLE data[], fcolor[])
DECLARE FUNCTION  DrawRegularPolygon (hDC, x, y, r, DOUBLE angle, sides)
DECLARE FUNCTION  EllipseToBezier (hDC, x1, y1, x2, y2)
DECLARE FUNCTION  HexFillRect (hDC, x1, y1, x2, y2, r, mode)
DECLARE FUNCTION  HLSGradientRect (hDC, x1, y1, x2, y2, color1, color2, mode)
DECLARE FUNCTION  Line (hDC, x1, y1, x2, y2)
DECLARE FUNCTION  Triangle (hDC, x0, y0, x1, y1, x2, y2, extra)
DECLARE FUNCTION  TriangleFilled (hDC, color, fDirection, x1, y1, x2, y2)

' support functions
DECLARE FUNCTION  RGBCube (hDC)
DECLARE FUNCTION  RGBtoHLS (color, DOUBLE hue, DOUBLE lightness, DOUBLE saturation)
DECLARE FUNCTION  Value (DOUBLE m1, DOUBLE m2, DOUBLE h)
DECLARE FUNCTION  HLStoRGB (DOUBLE hue, DOUBLE lightness, DOUBLE saturation, red, green, blue)

' *****  border styles  *****
'
  $$BorderNone          =  0
  $$BorderFlat          =  1 : $$BorderFlat1  =  1
  $$BorderFlat2         =  2
  $$BorderFlat4         =  3
  $$BorderHiLine1       =  4 : $$BorderLine1  =  4
  $$BorderHiLine2       =  5 : $$BorderLine2  =  5
  $$BorderHiLine4       =  6 : $$BorderLine4  =  6
  $$BorderLoLine1       =  7
  $$BorderLoLine2       =  8
  $$BorderLoLine4       =  9
  $$BorderRaise1        = 10 : $$BorderRaise  = 10
  $$BorderRaise2        = 11
  $$BorderRaise4        = 12
  $$BorderLower1        = 13 : $$BorderLower  = 13
  $$BorderLower2        = 14
  $$BorderLower4        = 15
  $$BorderFrame         = 16
  $$BorderDrain         = 17
  $$BorderRidge         = 18
  $$BorderValley        = 19
  $$BorderWide          = 20  ' wide window frame border w/o resize marks
  $$BorderWideResize    = 21  ' wide window frame border with resize marks
  $$BorderWindow        = 22  ' window frame border w/o resize marks
  $$BorderWindowResize  = 23  ' window frame border with resize marks
  $$BorderRise2         = 24
  $$BorderSink2         = 25
  $$BorderUpper         = 31  ' highest valid border number

  $$TriangleUp          = 0x0010
  $$TriangleRight       = 0x0014
  $$TriangleDown        = 0x0018
  $$TriangleLeft        = 0x001C


'Control IDs

$$Button1 = 100
$$Button2 = 101
$$Button3 = 102
$$Button4 = 103
$$Button5 = 104
$$Button6 = 105
$$Button7 = 106
$$Button8 = 107
$$Button9 = 108
$$Button10 = 109
$$Button11 = 110
$$Button12 = 111
$$Button13 = 112
$$Button14 = 113
$$Button15 = 114
$$Button16 = 115
$$Button17 = 116
$$Button18 = 117
$$Button19 = 118
$$Button20 = 119

$$Canvas1 = 200
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
	PAINTSTRUCT ps
	RECT rect
	DRAWITEMSTRUCT dis

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DeleteScreenBuffer (#hMemDC)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode

				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 : GOSUB ClearCanvas : DrawEdgeTest ()
						CASE $$Button2 : GOSUB ClearCanvas : DrawFrameControlTest ()
						CASE $$Button3 : GOSUB ClearCanvas : DrawBorderTest ()
						CASE $$Button4 : GOSUB ClearCanvas : LineToTest ()
						CASE $$Button5 : GOSUB ClearCanvas : ExtCreatePenTest ()
						CASE $$Button6 : GOSUB ClearCanvas : TriangleTest ()
						CASE $$Button7 : GOSUB ClearCanvas : TriangleFilledTest ()
						CASE $$Button8 : GOSUB ClearCanvas : PolyBezierTest ()
						CASE $$Button9 : GOSUB ClearCanvas : DrawArcTest ()
						CASE $$Button10 : GOSUB ClearCanvas : EllipseToBezierTest ()
						CASE $$Button11 : GOSUB ClearCanvas : SetPixelTest ()
						CASE $$Button12 : GOSUB ClearCanvas : DrawFocusRectTest ()
						CASE $$Button13 : GOSUB ClearCanvas : RectangleTest ()
						CASE $$Button14 : GOSUB ClearCanvas : CreatePatternBrushTest ()
						CASE $$Button15 : GOSUB ClearCanvas : DrawPieTest ()
						CASE $$Button16 : GOSUB ClearCanvas : HLSGradientRectTest ()
						CASE $$Button17 : GOSUB ClearCanvas : PolygonTest ()
						CASE $$Button18 : GOSUB ClearCanvas : SelectClipRgnTest ()
						CASE $$Button19 : GOSUB ClearCanvas : ExtFloodFillTest ()
						CASE $$Button20 : GOSUB ClearCanvas : LineDDATest ()
					END SELECT
			END SELECT

		CASE $$WM_DRAWITEM :												' paint ownerdrawn static control #hCanvas
			disAddr = lParam
			RtlMoveMemory (&dis, disAddr, SIZE(dis))	' copy DRAWITEMSTRUCT pointer to dis
			hDC = dis.hDC															' get hDC for window
			BitBlt (hDC, 0, 0, dis.rcItem.right, dis.rcItem.bottom, #hMemDC, 0, 0, $$SRCCOPY)	' copy image in screen buffer #hMemDC to #hCanvas hDC

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** ClearCanvas *****
SUB ClearCanvas
	GetClientRect (#hCanvas, &rect)
	FillRect (#hMemDC, &rect, GetSysColorBrush ($$COLOR_BTNFACE))
	InvalidateRect (#hCanvas, 0, 1)					' update rect region and erase background
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
	RECT rc

' register window class
	className$  = "GdiDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "GDI32 Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 740
	h 					= 508
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	#hButton1 = NewChild ("button", "DrawEdge",         		$$BS_PUSHBUTTON, 0,  0, 140, 24, #winMain, $$Button1, 0)
	#hButton2 = NewChild ("button", "DrawFrameControl", 		$$BS_PUSHBUTTON, 0, 24, 140, 24, #winMain, $$Button2, 0)
	#hButton3 = NewChild ("button", "DrawBorder",       		$$BS_PUSHBUTTON, 0, 48, 140, 24, #winMain, $$Button3, 0)
	#hButton4 = NewChild ("button", "LineTo",           		$$BS_PUSHBUTTON, 0, 72, 140, 24, #winMain, $$Button4, 0)
	#hButton5 = NewChild ("button", "ExtCreatePen",     		$$BS_PUSHBUTTON, 0, 96, 140, 24, #winMain, $$Button5, 0)
	#hButton6 = NewChild ("button", "Triangle",         		$$BS_PUSHBUTTON, 0, 120, 140, 24, #winMain, $$Button6, 0)
	#hButton7 = NewChild ("button", "TriangleFilled",   		$$BS_PUSHBUTTON, 0, 144, 140, 24, #winMain, $$Button7, 0)
	#hButton8 = NewChild ("button", "PolyBezier",       		$$BS_PUSHBUTTON, 0, 168, 140, 24, #winMain, $$Button8, 0)
	#hButton9 = NewChild ("button", "DrawArc",       				$$BS_PUSHBUTTON, 0, 192, 140, 24, #winMain, $$Button9, 0)
	#hButton10 = NewChild ("button", "EllipseToBezier", 		$$BS_PUSHBUTTON, 0, 216, 140, 24, #winMain, $$Button10, 0)
	#hButton11 = NewChild ("button", "SetPixel",        		$$BS_PUSHBUTTON, 0, 240, 140, 24, #winMain, $$Button11, 0)
	#hButton12 = NewChild ("button", "DrawFocusRect",   		$$BS_PUSHBUTTON, 0, 264, 140, 24, #winMain, $$Button12, 0)
	#hButton13 = NewChild ("button", "Rectangle",       		$$BS_PUSHBUTTON, 0, 288, 140, 24, #winMain, $$Button13, 0)
	#hButton14 = NewChild ("button", "CreatePatternBrush", 	$$BS_PUSHBUTTON, 0, 312, 140, 24, #winMain, $$Button14, 0)
	#hButton15 = NewChild ("button", "DrawPie", 						$$BS_PUSHBUTTON, 0, 336, 140, 24, #winMain, $$Button15, 0)
	#hButton16 = NewChild ("button", "HLSGradientRect", 		$$BS_PUSHBUTTON, 0, 360, 140, 24, #winMain, $$Button16, 0)
	#hButton17 = NewChild ("button", "Polygon", 						$$BS_PUSHBUTTON, 0, 384, 140, 24, #winMain, $$Button17, 0)
	#hButton18 = NewChild ("button", "SelectClipRgn", 			$$BS_PUSHBUTTON, 0, 408, 140, 24, #winMain, $$Button18, 0)
	#hButton19 = NewChild ("button", "ExtFloodFill", 				$$BS_PUSHBUTTON, 0, 432, 140, 24, #winMain, $$Button19, 0)
	#hButton20 = NewChild ("button", "LineDDA", 						$$BS_PUSHBUTTON, 0, 456, 140, 24, #winMain, $$Button20, 0)

	GetClientRect (#winMain, &rc)
	#hCanvas = NewChild ("static", "", $$SS_OWNERDRAW, 141, 0, rc.right-140, rc.bottom, #winMain, $$Canvas1, $$WS_EX_CLIENTEDGE)

	GetClientRect (#hCanvas, &rc)
	#hMemDC = CreateScreenBuffer (#hCanvas, rc.right, rc.bottom)

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
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' ###################################
' #####  CreateScreenBuffer ()  #####
' ###################################
'
'	make a compatible memory image buffer
' IN 			: hWnd			window handle
'						w					buffer width
'						h					buffer height
' RETURN 	: hMemDC		handle to a memory device context
'
FUNCTION  CreateScreenBuffer (hWnd, w, h)

	hDC 		= GetDC (hWnd)
	memDC 	= CreateCompatibleDC (hDC)
	hBit 		= CreateCompatibleBitmap (hDC, w, h)
	SelectObject (memDC, hBit)
	hBrush 	= GetStockObject ($$LTGRAY_BRUSH)
	SelectObject (memDC, hBrush)
	PatBlt (memDC, 0, 0, w, h, $$PATCOPY)
	ReleaseDC (hWnd, hDC)
	RETURN memDC

END FUNCTION
'
'
' ###################################
' #####  DeleteScreenBuffer ()  #####
' ###################################
'
FUNCTION  DeleteScreenBuffer (hMemDC)

	hBmp = GetCurrentObject (hMemDC, $$OBJ_BITMAP)
	DeleteObject (hBmp)
	DeleteDC (hMemDC)

END FUNCTION
'
'
' #############################
' #####  DrawEdgeTest ()  #####
' #############################
'
FUNCTION  DrawEdgeTest ()

	RECT rect

	DIM edge[3]
	DIM flag[8]

	edge[0] = $$EDGE_RAISED
	edge[1] = $$EDGE_SUNKEN
	edge[2] = $$EDGE_ETCHED
	edge[3] = $$EDGE_BUMP

	flag[0] = $$BF_MIDDLE | $$BF_BOTTOM
	flag[1] = $$BF_MIDDLE | $$BF_BOTTOMLEFT
	flag[2] = $$BF_MIDDLE | $$BF_BOTTOMLEFT | $$BF_TOP
	flag[3] = $$BF_MIDDLE | $$BF_RECT
	flag[4] = $$BF_MIDDLE | $$BF_RECT | $$BF_FLAT
	flag[5] = $$BF_MIDDLE | $$BF_RECT | $$BF_MONO
	flag[6] = $$BF_MIDDLE | $$BF_RECT | $$BF_SOFT
	flag[7] = $$BF_MIDDLE | $$BF_RECT | $$BF_DIAGONAL
	flag[8] = $$BF_MIDDLE | $$BF_RECT | $$BF_ADJUST

	size = 40
	gap = 10
	FOR e = 0 TO 3
		rect.top = (e*size) + (e*gap) + gap
		rect.bottom = rect.top + size
		FOR f = 0 TO 8
			rect.left 	= (f*size) + (f*gap) + gap
			rect.right 	= rect.left + size
			DrawEdge (#hMemDC, &rect, edge[e], flag[f])
		NEXT f
	NEXT e

END FUNCTION
'
'
' #####################################
' #####  DrawFrameControlTest ()  #####
' #####################################
'
FUNCTION  DrawFrameControlTest ()

	DIM type[4]

	type[0] = $$DFC_CAPTION
	type[1] = $$DFC_MENU
	type[2] = $$DFC_SCROLL
	type[3] = $$DFC_BUTTON
	type[4] = $$DFC_POPUPMENU

	DIM captionState[6]
	captionState[0] = $$DFCS_CAPTIONCLOSE
	captionState[1] = $$DFCS_CAPTIONMIN
	captionState[2] = $$DFCS_CAPTIONMAX
	captionState[3] = $$DFCS_CAPTIONRESTORE
	captionState[4] = $$DFCS_CAPTIONHELP
	captionState[5] = $$DFCS_CAPTIONHELP | $$DFCS_FLAT
	captionState[6] = $$DFCS_CAPTIONHELP | $$DFCS_INACTIVE

	DrawControls (#hMemDC, type[0], @captionState[])

	DIM menuState[6]
	menuState[0] = $$DFCS_MENUARROW
	menuState[1] = $$DFCS_MENUCHECK
	menuState[2] = $$DFCS_MENUBULLET
	menuState[3] = $$DFCS_MENUARROWRIGHT
	menuState[4] = $$DFCS_MENUARROWRIGHT | $$DFCS_FLAT
	menuState[5] = $$DFCS_MENUARROWRIGHT | $$DFCS_INACTIVE
	menuState[6] = $$DFCS_MENUARROWRIGHT | $$DFCS_PUSHED

	DrawControls (#hMemDC, type[1], @menuState[])

	DIM scrollState[8]
	scrollState[0] = $$DFCS_SCROLLUP
	scrollState[1] = $$DFCS_SCROLLDOWN
	scrollState[2] = $$DFCS_SCROLLLEFT
	scrollState[3] = $$DFCS_SCROLLRIGHT
	scrollState[4] = $$DFCS_SCROLLCOMBOBOX
	scrollState[5] = $$DFCS_SCROLLSIZEGRIP
	scrollState[6] = $$DFCS_SCROLLSIZEGRIPRIGHT
	scrollState[7] = $$DFCS_SCROLLSIZEGRIPRIGHT | $$DFCS_FLAT
	scrollState[8] = $$DFCS_SCROLLSIZEGRIPRIGHT | $$DFCS_INACTIVE

	DrawControls (#hMemDC, type[2], @scrollState[])

	DIM buttonState[10]
	buttonState[0] = $$DFCS_BUTTONCHECK
	buttonState[1] = $$DFCS_BUTTONCHECK | $$DFCS_CHECKED
	buttonState[2] = $$DFCS_BUTTONRADIOIMAGE
	buttonState[3] = $$DFCS_BUTTONRADIOMASK
	buttonState[4] = $$DFCS_BUTTONRADIO
	buttonState[5] = $$DFCS_BUTTONRADIO | $$DFCS_CHECKED
	buttonState[6] = $$DFCS_BUTTON3STATE
	buttonState[7] = $$DFCS_BUTTONPUSH
	buttonState[8] = $$DFCS_BUTTONPUSH | $$DFCS_FLAT
	buttonState[9] = $$DFCS_BUTTONPUSH | $$DFCS_INACTIVE
	buttonState[10] = $$DFCS_BUTTONPUSH | $$DFCS_PUSHED

	DrawControls (#hMemDC, type[3], @buttonState[])

	DIM popupMenuState[5]
	popupMenuState[0] = 0
	popupMenuState[1] = 1
	popupMenuState[2] = 2
	popupMenuState[3] = 3
	popupMenuState[4] = 3 | $$DFCS_FLAT
	popupMenuState[4] = 3 | $$DFCS_INACTIVE

	DrawControls (#hMemDC, type[4], @popupMenuState[])

END FUNCTION
'
'
' ###############################
' #####  DrawBorderTest ()  #####
' ###############################
'
FUNCTION  DrawBorderTest ()

	gap = 20
	boxSize = 60
	border = 4			' border style flag

	FOR i = 0 TO 3		'no of rows
		y1 =(i*boxSize) + (i*gap) + gap
		y2 = y1 + boxSize
		FOR j = 0 TO 5		'no of columns
			x1 = (j*boxSize) + (j*gap) + gap
			x2 = x1 + boxSize
			DrawBorder (#hMemDC, border, -1, -1, -1, x1, y1, x2, y2)
			INC border
		NEXT j
	NEXT i

END FUNCTION
'
'
' ###########################
' #####  LineToTest ()  #####
' ###########################
'
FUNCTION  LineToTest ()

	n = 19						' number of vertices
	r = 200						' radius
	theta# = 3.1415926 * 2 / DOUBLE(n)

	DIM color[9]
	color[0] = RGB(0, 0, 0)
	color[1] = RGB(255, 0, 0)
	color[2] = RGB(0, 255, 0)
	color[3] = RGB(0, 0, 255)
	color[4] = RGB(255, 255, 0)
	color[5] = RGB(0, 255, 255)
	color[6] = RGB(255, 0, 255)
	color[7] = RGB(127, 255, 0)
	color[8] = RGB(0, 127, 255)
	color[9] = RGB(255, 0, 127)

	FOR p = 0 TO n-1
		FOR q = 0 TO p-1
			penColor = color[MIN(p-q, n-p+q)]								' set pen color
			hPen   = CreatePen ($$PS_SOLID, 1, penColor)		' create pen object
			oldPen = SelectObject (#hMemDC, hPen)						' select pen into memory dc

			x1 = 250 + r * sin(p*theta#)										' set line start and end points
			y1 = 220 + r * cos(p*theta#)
			x2 = 250 + r * sin(q*theta#)
			y2 = 220 + r * cos(q*theta#)

			MoveToEx (#hMemDC, x1, y1, 0)										' move current draw point to start point
			LineTo   (#hMemDC, x2, y2)											' draw line from current draw point to given end point

			SelectObject (#hMemDC, oldPen)									' select last pen into memory dc
			DeleteObject (hPen)															' delete pen
		NEXT q
	NEXT p

END FUNCTION
'
'
' #################################
' #####  ExtCreatePenTest ()  #####
' #################################
'
FUNCTION  ExtCreatePenTest ()

	LOGBRUSH logbrush

	DIM penstyle[4]
	penstyle[0] = $$PS_SOLID
	penstyle[1] = $$PS_DASH
	penstyle[2] = $$PS_DOT
	penstyle[3] = $$PS_DASHDOT
	penstyle[4] = $$PS_DASHDOTDOT

' draw various COSMETIC styles of lines (width must = 1)

' initialize LOGBRUSH struct
	logbrush.style = $$BS_SOLID
	logbrush.color = 0
	logbrush.hatch = 0

	width = 1
	x1 = 20
	x2 = 350
	y1 = 20
	y2 = y1

	FOR i = 0 TO 4
		pStyle = $$PS_COSMETIC | penstyle[i]
		hPen = ExtCreatePen (pStyle, width, &logbrush, 0, 0)
		oldPen = SelectObject (#hMemDC, hPen)						' select pen into memory dc
		MoveToEx (#hMemDC, x1, y1, 0)										' move current draw point to start point
		LineTo   (#hMemDC, x2, y2)											' draw line from current draw point to given end point
		y1 = y1 + 20
		y2 = y1
		SelectObject (#hMemDC, oldPen)									' select last pen into memory dc
		DeleteObject (hPen)															' delete pen
	NEXT i

	DIM endcap[2]
	endcap[0] = $$PS_ENDCAP_FLAT
	endcap[1] = $$PS_ENDCAP_SQUARE
	endcap[2] = $$PS_ENDCAP_ROUND

' draw some solid GEOMETRIC lines (using paths) with different widths and endcaps
	length = 70
	gap = 20

	FOR j = 0 TO 3
		width = 3 + 4*j
		x1 = (j*length) + (j*gap) + gap
		x2 = x1 + length
		y1 = 100
		y2 = 100
		FOR i = 0 TO 2
			SELECT CASE i
				CASE 0 : logbrush.color = RGB(255, 0, 0)
				CASE 1 : logbrush.color = RGB(0, 255, 0)
				CASE 2 : logbrush.color = RGB(0, 0, 255)
			END SELECT

			pStyle = $$PS_GEOMETRIC | endcap[i]
			hPen = ExtCreatePen (pStyle, width, &logbrush, 0, 0)

			IFZ hPen THEN
				error = GetLastError ()
				msgBuf$ = NULL$(256)
				FormatMessageA ($$FORMAT_MESSAGE_FROM_SYSTEM, 0, error, 0, &msgBuf$, LEN(msgBuf$), 0)
				msgBuf$ = CSIZE$(msgBuf$)
				PRINT error, msgBuf$
			END IF

			oldPen = SelectObject (#hMemDC, hPen)						' select pen into memory dc

			y1 = y1 + 25
			y2 = y1

' note: endcap styles only work with paths!!!!

			BeginPath (#hMemDC)															' start a path
			MoveToEx (#hMemDC, x1, y1, 0)										' move current draw point to start point
			LineTo   (#hMemDC, x2, y2)											' draw line from current draw point to given end point
			EndPath (#hMemDC)																' end path
			StrokePath (#hMemDC)														' draw path with current pen
			SelectObject (#hMemDC, oldPen)									' select last pen into memory dc
			DeleteObject (hPen)															' delete pen
		NEXT i
	NEXT j

END FUNCTION
'
'
' #############################
' #####  TriangleTest ()  #####
' #############################
'
FUNCTION  TriangleTest ()

	LOGBRUSH logbrush

	logbrush.style = $$BS_SOLID
	logbrush.color = RGB(0, 0, 0xFF)
	logbrush.hatch = 0

	hPen = ExtCreatePen ($$PS_GEOMETRIC | $$PS_SOLID | $$PS_ENDCAP_FLAT | $$PS_JOIN_MITER, 15, &logbrush, 0, 0)
	hOld = SelectObject (#hMemDC, hPen)

' draw triangle using polyline function in Triangle()
' using extra segment

	BeginPath (#hMemDC)
	Triangle (#hMemDC, 100, 50, 150, 136, 50, 136, $$TRUE)
	EndPath (#hMemDC)
	StrokePath (#hMemDC)

	SelectObject (#hMemDC, hOld)
	DeleteObject (hPen)


' draw dot triangle, 1 pix wide
	logbrush.color = RGB(0xFF, 0, 0xFF)
	hPen = ExtCreatePen ($$PS_COSMETIC | $$PS_DOT, 1, &logbrush, 0, 0)
	hOld = SelectObject (#hMemDC, hPen)

	Triangle (#hMemDC, 50, 150, 250, 150, 250, 350, $$FALSE)

	SelectObject(#hMemDC, hOld)
	DeleteObject(hPen)


END FUNCTION
'
'
' ###################################
' #####  TriangleFilledTest ()  #####
' ###################################
'
FUNCTION  TriangleFilledTest ()

' fill entire area with black triangle
	TriangleFilled (#hMemDC, 0, $$TriangleRight, 0, 0, 0, 0)

' draw various colored triangles
	TriangleFilled (#hMemDC, RGB(255, 0, 0),   $$TriangleRight,   50,  50, 100, 100)
	TriangleFilled (#hMemDC, RGB(0, 255, 0),   $$TriangleLeft,   110, 110, 150, 150)
	TriangleFilled (#hMemDC, RGB(0, 0, 255),   $$TriangleUp,     160, 160, 190, 190)
	TriangleFilled (#hMemDC, RGB(255, 0, 255), $$TriangleDown,   200, 200, 220, 220)

END FUNCTION
'
'
' ###############################
' #####  PolyBezierTest ()  #####
' ###############################
'
FUNCTION  PolyBezierTest ()

	POINT p[3], q[3], r[3], t[3]

	hPenRed  = CreatePen ($$PS_DOT, 0, RGB(0xFF, 0, 0))
	hPenBlue = CreatePen ($$PS_SOLID, 2, RGB(0, 0, 0xFF))

  FOR z = 0 TO 200 STEP 40
		x = 10
		y = 210

		p[0].x = x 			: p[0].y = y 		: p[1].x = x+50 	: p[1].y = y-z
		p[2].x = x+100 	: p[2].y = y-z 	: p[3].x = x+150 	: p[3].y = y
		x = x + 160

		q[0].x = x 			: q[0].y = y 		: q[1].x = x+50 	: q[1].y = y-z
		q[2].x = x+100 	: q[2].y = y+z 	: q[3].x = x+150 	: q[3].y = y
		x = x + 180

		r[0].x = x 			: r[0].y = y 		: r[1].x = x+170 	: r[1].y = y-z
		r[2].x = x-20 	: r[2].y = y-z 	: r[3].x = x+150 	: r[3].y = y
		x = 10
		y = 450

		t[0].x = x+75 	: t[0].y = y 		: t[1].x = x 			: t[1].y = y-z
		t[2].x = x+150 	: t[2].y = y-z 	: t[3].x = x+75 	: t[3].y = y

		hOld = SelectObject (#hMemDC, hPenRed)
    Polyline(#hMemDC, &p[0], 4)
    Polyline(#hMemDC, &q[0], 4)
    Polyline(#hMemDC, &r[0], 4)
    Polyline(#hMemDC, &t[0], 4)
    SelectObject (#hMemDC, hOld)

 		hOld = SelectObject (#hMemDC, hPenBlue)
    PolyBezier(#hMemDC, &p[0], 4)
    PolyBezier(#hMemDC, &q[0], 4)
    PolyBezier(#hMemDC, &r[0], 4)
    PolyBezier(#hMemDC, &t[0], 4)
    SelectObject (#hMemDC, hOld)
	NEXT z

	DeleteObject (hPenRed)
	DeleteObject (hPenBlue)
END FUNCTION
'
'
' ############################
' #####  DrawArcTest ()  #####
' ############################
'
FUNCTION  DrawArcTest ()

	hPenRed  = CreatePen ($$PS_SOLID, 1, RGB(0xFF, 0, 0))
	hPenBlue = CreatePen ($$PS_SOLID, 3, RGB(0, 0, 0xFF))

	hOld = SelectObject (#hMemDC, hPenRed)

	r = 30
	x = 20
	y = 50

	FOR theta = 0 TO 315 STEP 45								' draw 45 degree arc segments
		thetaStart# = theta												' starting angle in degrees
		thetaEnd# = thetaStart# + 45.0						' ending angle in degrees
		MoveToEx (#hMemDC, x, y, 0)								' set current draw point
		DrawArc (#hMemDC, r, thetaStart#, thetaEnd#)	' draw arc
		x = x + 50
	NEXT

	SelectObject (#hMemDC, hOld)
	hOld = SelectObject (#hMemDC, hPenBlue)

	r = 45
	y = 150
	x = 20

	FOR theta = 0 TO 270 STEP 90								' draw 90 degree arc segments
		thetaStart# = theta												' starting angle in degrees
		thetaEnd# = thetaStart# + 90.0						' ending angle in degrees
		MoveToEx (#hMemDC, x, y, 0)								' set current draw point
		DrawArc (#hMemDC, r, thetaStart#, thetaEnd#)	' draw arc
		x = x + 100
	NEXT

	SelectObject (#hMemDC, hOld)

' draw some circles

	x = 10
	y = 260
	FOR r = 1 TO 16
		MoveToEx (#hMemDC, x, y, 0)								' set current draw point
		DrawArc (#hMemDC, r, 0, 360)							' draw circle
		x = x + 34
	NEXT r

' compare arc circle to bresenham circle (which is drawn using SetPixel)
	x = 10
	y = 300
	FOR r = 1 TO 16
		CircleBresenham (#hMemDC, x, y, r, color)			' draw bresenham circle
		x = x + 34
	NEXT r

	DeleteObject (hPenRed)
	DeleteObject (hPenBlue)

END FUNCTION
'
'
' ####################################
' #####  EllipseToBezierTest ()  #####
' ####################################
'
FUNCTION  EllipseToBezierTest ()

	hPenGreen	= CreatePen ($$PS_SOLID, 3, RGB(0, 0xFF, 0))
	hPenBlue	= CreatePen ($$PS_SOLID, 1, RGB(0, 0, 0xFF))

	hOld = SelectObject (#hMemDC, hPenGreen)

	x1 = 10
	y1 = 60
	y2 = y1 + 120

	FOR i = 0 TO 120 STEP 30
		x2 = x1	+ 30 + i
		EllipseToBezier (#hMemDC, x1, y1, x2, y2)
		x1 = x1 + 90
	NEXT i

	SelectObject (#hMemDC, hOld)
	hOld = SelectObject (#hMemDC, hPenBlue)

	x1 = 10
	y1 = 220
	x2 = x1 + 50

	FOR i = 0 TO 80 STEP 20
		y2 = y1 + 50 + i
		EllipseToBezier (#hMemDC, x1, y1, x2, y2)
		x1 = x1 + 100
		x2 = x1	+ 50
	NEXT i

	SelectObject (#hMemDC, hOld)
	DeleteObject (hPenGreen)
	DeleteObject (hPenBlue)

END FUNCTION
'
'
' #############################
' #####  SetPixelTest ()  #####
' #############################


'
FUNCTION  SetPixelTest ()

' Draw a RGB Color Cube
	RGBCube (#hMemDC)

END FUNCTION
'
'
' ##################################
' #####  DrawFocusRectTest ()  #####
' ##################################
'
FUNCTION  DrawFocusRectTest ()

' draw a dotted rectangle using DrawFocusRect
	RECT rect
	rect.top = 20
	rect.bottom = 150
	rect.left = 20
	rect.right = 200
	DrawFocusRect (#hMemDC, &rect)

' Draw a dotted rectangle using a pattern brush
	DottedRectangle (#hMemDC, 20, 170, 200, 300)


END FUNCTION
'
'
' ##############################
' #####  RectangleTest ()  #####
' ##############################
'
FUNCTION  RectangleTest ()

' use stock brushes to fill rectangle
	DIM hBrush[5]
	hBrush[0] = GetStockObject ($$BLACK_BRUSH)
	hBrush[1] = GetStockObject ($$DKGRAY_BRUSH)
	hBrush[2] = GetStockObject ($$GRAY_BRUSH)
	hBrush[3] = GetStockObject ($$HOLLOW_BRUSH)
	hBrush[4] = GetStockObject ($$LTGRAY_BRUSH)
	hBrush[5] = GetStockObject ($$WHITE_BRUSH)

	FOR i = 0 TO 5
		hOld = SelectObject (#hMemDC, hBrush[i])
		Rectangle (#hMemDC, 20+i*40, 20, 20+i*40+30, 50)
		SelectObject (#hMemDC, hOld)
	NEXT i

' use hatch brushes to fill rectangle
	DIM hBrush[5]
	hBrush[0] = CreateHatchBrush ($$HS_HORIZONTAL, 	RGB(0, 0, 0))
	hBrush[1] = CreateHatchBrush ($$HS_VERTICAL,   	RGB(0xFF, 0, 0))
	hBrush[2] = CreateHatchBrush ($$HS_FDIAGONAL,  	RGB(0, 0xFF, 0))
	hBrush[3] = CreateHatchBrush ($$HS_BDIAGONAL, 	RGB(0, 0, 0xFF))
	hBrush[4] = CreateHatchBrush ($$HS_CROSS, 			RGB(0xFF, 0xFF, 0))
	hBrush[5] = CreateHatchBrush ($$HS_DIAGCROSS, 	RGB(0, 0xFF, 0xFF))

	FOR i = 0 TO 5
		hOld = SelectObject (#hMemDC, hBrush[i])
		Rectangle (#hMemDC, 300+i*40, 20, 300+i*40+30, 50)
		SelectObject (#hMemDC, hOld)
		DeleteObject (hBrush[i])
	NEXT i



' fill rectangle using custom color brushes
' no outline for rectangle by using NULL_PEN

	SelectObject (#hMemDC, GetStockObject ($$NULL_PEN))

	FOR y = 0 TO 15
		FOR x = 0 TO 15
			hBrush = CreateSolidBrush (RGB(y*16+x, y*16+x, 0xFF))
			hOld = SelectObject (#hMemDC, hBrush)
			Rectangle (#hMemDC, 20+x*20, 70+y*20, 20+x*20+18, 70+y*20+18)
			SelectObject (#hMemDC, hOld)
			DeleteObject (hBrush)
		NEXT x
	NEXT y

	SelectObject (#hMemDC, GetStockObject ($$BLACK_PEN))

' draw rectangles with various pen widths

	x1 = 20
	x2 = x1 + 30
	FOR i = 1 TO 15 STEP 2
		hPen = CreatePen ($$PS_SOLID, i, RGB(0xFF, 0, 0))
		hOld = SelectObject (#hMemDC, hPen)
		Rectangle (#hMemDC, x1, 410, x2, 440)
		x1 = x1 + 50
		x2 = x1 + 30
		SelectObject (#hMemDC, hOld)
	NEXT i

' draw a dotted filled rectangle
	DotFillRect (#hMemDC, 400, 70, 500, 270, RGB(0xFF, 0xFF, 0xFF))

END FUNCTION
'
'
' #######################################
' #####  CreatePatternBrushTest ()  #####
' #######################################
'
FUNCTION  CreatePatternBrushTest ()

	USHORT pattern[]

' note:
' If the bitmap is monochrome, zeros represent the
' foreground color (def = black) and ones represent
' the background color (def = white) for the
' destination device context.

	DIM pattern[7]
	pattern[0] = 0x80
	pattern[1] = 0x40
	pattern[2] = 0x20
	pattern[3] = 0x20
	pattern[4] = 0x20
	pattern[5] = 0x3C
	pattern[6] = 0x42
	pattern[7] = 0x81

	hBitmap = CreateBitmap (8, 8, 1, 1, &pattern[0])
	hBrush 	= CreatePatternBrush (hBitmap)
	hOld 		= SelectObject (#hMemDC, hBrush)

	Rectangle (#hMemDC, 20, 20, 300, 300)

	DeleteObject (hBitmap)
	SelectObject (#hMemDC, hOld)
	DeleteObject (hBrush)

END FUNCTION
'
'
' ############################
' #####  DrawPieTest ()  #####
' ############################
'
FUNCTION  DrawPieTest ()

	DOUBLE data[]

' draw a pie centered at 1,1 with radius of 120
	MoveToEx (#hMemDC, 1, 1, 0)												' set drawpoint
	hBrush = GetStockObject ($$WHITE_BRUSH)						' create a white brush
	hOldBrush = SelectObject (#hMemDC, hBrush)				' select white brush
	DrawPie (#hMemDC, 120, 270, 0)										' draw filled pie
	SelectObject (#hMemDC, hOldBrush)

' draw several filled pie shapes
	hPen = CreatePen ($$PS_SOLID, 1, RGB(0xFF, 0, 0))	' create a red pen
	hOldPen = SelectObject (#hMemDC, hPen)
	hBrush1 = CreateSolidBrush (RGB(0xFF, 0xFF, 0))
	hBrush2 = CreateSolidBrush (RGB(0, 0xFF, 0xFF))

	MoveToEx (#hMemDC, 350, 80, 0)

	hOldBrush = SelectObject (#hMemDC, hBrush1)
	DrawPie (#hMemDC, 75, 0, 45)

	SelectObject (#hMemDC, hBrush2)
	DrawPie (#hMemDC, 75,  90, 135)

	SelectObject (#hMemDC, hBrush1)
	DrawPie (#hMemDC, 75, 180, 225)

	SelectObject (#hMemDC, hBrush2)
	DrawPie (#hMemDC, 75, 270, 315)

	SelectObject (#hMemDC, hOldPen)
	SelectObject (#hMemDC, hOldBrush)
	DeleteObject (hPen)
	DeleteObject (hBrush1)
	DeleteObject (hBrush2)

' draw a pie chart

	DIM data[5]
	DIM fcolor[5]
	data[0] =  30		: fcolor[0] = 0
	data[1] =  45		: fcolor[1] = RGB(0, 0xFF, 0)
	data[2] =  120	: fcolor[2] = RGB(0, 0xFF, 0xFF)
	data[3] =  60		: fcolor[3] = RGB(0xFF, 0xFF, 0)
	data[4] =  15		: fcolor[4] = RGB(0xFF, 0xFF, 0xFF)
	data[5] =  90		: fcolor[5] = RGB(0, 0, 0xFF)

	DrawPieChart (#hMemDC, 200, 300, 130, RGB(0xFF, 0, 0), @data[], @fcolor[])




END FUNCTION
'
'
' ####################################
' #####  HLSGradientRectTest ()  #####
' ####################################
'
FUNCTION  HLSGradientRectTest ()

	RECT rect
	BITMAP bmp

	hBmp = GetCurrentObject (#hMemDC, $$OBJ_BITMAP)
	GetObjectA (hBmp, SIZE(bmp), &bmp)

	x1 = 0
	y1 = 0
	x2 = bmp.width
	y2 = bmp.height
	color1 = RGB(0xFF, 0xFF, 0xFF)
	color2 = RGB(0, 0, 0)
	HLSGradientRect (#hMemDC, x1, y1, x2, y2, color1, color2, 0)

	x1 = x2/4
	x2 = x1 + x2/2
	y1 = y2/4
	y2 = y1 + y2/2
	color1 = RGB(0xFF, 0xFF, 0)
	color2 = RGB(0xFF, 0, 0)
	HLSGradientRect (#hMemDC, x1, y1, x2, y2, color1, color2, 1)

END FUNCTION
'
'
' ############################
' #####  PolygonTest ()  #####
' ############################
'
FUNCTION  PolygonTest ()

	POINT points5[], points4[], points3[]
	LOGBRUSH logbrush

'initialize polygon points
	DIM points5[4]
	points5[0].x = 20
	points5[1].x = 20
	points5[2].x = 70
	points5[3].x = 120
	points5[4].x = 120

	points5[0].y = 170
	points5[1].y = 70
	points5[2].y = 20
	points5[3].y = 70
	points5[4].y = 170

	hPen = CreatePen ($$PS_SOLID, 3, 0)
	hOldPen = SelectObject (#hMemDC, hPen)

	Polygon (#hMemDC, &points5[0], 5)

	SelectObject (#hMemDC, hOldPen)
	DeleteObject (hPen)

	DIM points4[3]
	points4[0].x = 150
	points4[1].x = 200
	points4[2].x = 250
	points4[3].x = 200

	points4[0].y = 120
	points4[1].y = 20
	points4[2].y = 120
	points4[3].y = 220

	hPen = CreatePen ($$PS_SOLID, 3, 0)
	hBrush = CreateSolidBrush (RGB(0xFF, 0, 0xFF))
	hOldPen = SelectObject (#hMemDC, hPen)
	hOldBrush = SelectObject (#hMemDC, hBrush)

	Polygon (#hMemDC, &points4[0], 4)

	SelectObject (#hMemDC, hOldPen)
	DeleteObject (hPen)
	SelectObject (#hMemDC, hOldBrush)
	DeleteObject (hBrush)

	DIM points3[2]
	points3[0].x = 275
	points3[1].x = 375
	points3[2].x = 450

	points3[0].y = 50
	points3[1].y = 10
	points3[2].y = 250

	logbrush.style = $$BS_SOLID
	logbrush.color = RGB(0, 0xFF, 0xFF)
	logbrush.hatch = 0

	hPen = ExtCreatePen ($$PS_GEOMETRIC | $$PS_SOLID | $$PS_JOIN_MITER, 5, &logbrush, 0, 0)
	hBrush = CreateSolidBrush (RGB(0xFF, 0xFF, 0))
	hOldPen = SelectObject (#hMemDC, hPen)
	hOldBrush = SelectObject (#hMemDC, hBrush)

	Polygon (#hMemDC, &points3[0], 3)

	SelectObject (#hMemDC, hOldPen)
	DeleteObject (hPen)
	SelectObject (#hMemDC, hOldBrush)
	DeleteObject (hBrush)

' draw a series of regular polygons
	FOR i = 3 TO 8
		hPen = CreatePen ($$PS_SOLID, 2, 0)
		hBrush = CreateSolidBrush (RGB(0xFF, 25*i, 0xFF-25*i))
		hOldPen = SelectObject (#hMemDC, hPen)
		hOldBrush = SelectObject (#hMemDC, hBrush)

		DrawRegularPolygon (#hMemDC, 90*(i-3)+50, 320, 40, 0, i)

		SelectObject (#hMemDC, hOldPen)
		DeleteObject (hPen)
		SelectObject (#hMemDC, hOldBrush)
		DeleteObject (hBrush)
	NEXT i




END FUNCTION
'
'
' ##################################
' #####  SelectClipRgnTest ()  #####
' ##################################
'
FUNCTION  SelectClipRgnTest ()

	hBrush = CreateSolidBrush (RGB(0xFF, 0xFF, 0xFF))
	hOldBrush = SelectObject (#hMemDC, hBrush)

	HexFillRect (#hMemDC, 20, 20, 280, 280, 10, 0)	' fill a rectangle with hexagons

	HexFillRect (#hMemDC, 300, 20, 560, 280, 15, 1)	' fill a rectangle with hexagons

	SelectObject (#hMemDC, hOldBrush)
	DeleteObject (hBrush)


END FUNCTION
'
'
' #################################
' #####  ExtFloodFillTest ()  #####
' #################################
'
FUNCTION  ExtFloodFillTest ()

' draw four filled circles using Ellipse()

	hPenRed		= CreatePen ($$PS_SOLID, 5, RGB(0xFF, 0, 0))
	hPenBlue	= CreatePen ($$PS_SOLID, 3, RGB(0, 0, 0xFF))
	hBrush 		= CreateSolidBrush (RGB(0xFF, 0xFF, 0))
	hOldPen 	= SelectObject (#hMemDC, hPenRed)
	hOldBrush = SelectObject (#hMemDC, hBrush)

	Ellipse (#hMemDC, 20, 20, 170, 170)
	Ellipse (#hMemDC, 20, 200, 170, 350)

	SelectObject (#hMemDC, hPenBlue)

	Ellipse (#hMemDC, 200, 20, 350, 170)
	Ellipse (#hMemDC, 200, 200, 350, 350)

	SelectObject (#hMemDC, hOldBrush)
	DeleteObject (hBrush)

	hBrush 		= CreateSolidBrush (RGB(0, 0xFF, 0xFF))		' set flood fill brush
	hOldBrush = SelectObject (#hMemDC, hBrush)

' flood fill top circles using different types of fill operations

	ExtFloodFill (#hMemDC, 95, 95, RGB(0xFF, 0, 0), $$FLOODFILLBORDER)
	ExtFloodFill (#hMemDC, 275, 95, RGB(0xFF, 0xFF, 0), $$FLOODFILLSURFACE)

	SelectObject (#hMemDC, hOldPen)
	DeleteObject (hPenRed)
	DeleteObject (hPenBlue)
	SelectObject (#hMemDC, hOldBrush)
	DeleteObject (hBrush)

END FUNCTION
'
'
' ############################
' #####  LineDDATest ()  #####
' ############################
'
FUNCTION  LineDDATest ()

' draw a series of circles along path of 4 lines
' described by LineDDA. See LineDDAProc().

	hPen = CreatePen ($$PS_SOLID, 1, RGB(0xFF, 0xFF, 0xFF))
	hOldPen = SelectObject (#hMemDC, hPen)

	x0 = 50 : x1 = 350 : x2 = 350 : x3 = 50
	y0 = 50 : y1 = 50  : y2 = 350 : y3 = 350
	LineDDA (x0, y0, x1, y1, &LineDDAProc(), #hMemDC)
	LineDDA (x1, y1, x2, y2, &LineDDAProc(), #hMemDC)
	LineDDA (x2, y2, x3, y3, &LineDDAProc(), #hMemDC)
	LineDDA (x3, y3, x0, y0, &LineDDAProc(), #hMemDC)

	SelectObject (#hMemDC, hOldPen)
	DeleteObject (hPen)


END FUNCTION
'
'
' ############################
' #####  LineDDAProc ()  #####
' ############################
'
FUNCTION  LineDDAProc (x, y, lpData)

	STATIC count, init, c
	POINT cur
	hDC = lpData

	r = 15

' draw first circle
	IFZ init THEN
		init = $$TRUE
		GOSUB NewBrush
'		MoveToEx (hDC, x, y, &cur)							' set current draw point
'		DrawArc (hDC, 15, 0, 360)								' draw circle radius of 15
'		MoveToEx (hDC, cur.x, cur.y, 0)
		Ellipse (hDC, x-r, y-r, x+r, y+r)
		INC count
		GOSUB DeleteBrush
	ELSE
' draw a circle after every 31 calls
		IF count = 30 THEN 											' every 31st call
			GOSUB NewBrush
'			MoveToEx (hDC, x, y, &cur)						' set current draw point
'			DrawArc (hDC, 15, 0, 360)							' draw circle radius of 15
'			MoveToEx (hDC, cur.x, cur.y, 0)
			Ellipse (hDC, x-r, y-r, x+r, y+r)
			count = 0
			GOSUB DeleteBrush
		END IF
		INC count
	END IF

' ***** NewBrush *****
SUB NewBrush
	hBrush = CreateSolidBrush (RGB(c, 0, 0))
	hOldBrush = SelectObject (hDC, hBrush)
	c = c + 6
	IF c > 255 THEN c = 0
END SUB

' ***** DeleteBrush *****
SUB DeleteBrush
	SelectObject (hDC, hOldBrush)
	DeleteObject (hBrush)
END SUB



END FUNCTION
'
'
' ################################
' #####  CircleBresenham ()  #####
' ################################
'
FUNCTION  CircleBresenham (hDC, x, y, r, color)

	IFZ r THEN RETURN
	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	xi = 0
	yi = r
	di = (1-r) * 2

	DO WHILE (yi > -1)

		SetPixel (hDC, x+xi, y+yi, color)
		SetPixel (hDC, x-xi, y-yi, color)
		SetPixel (hDC, x-xi, y+yi, color)
		SetPixel (hDC, x+xi, y-yi, color)

  	IF (di < 0) THEN
			INC xi
   		IF ((2 * (di+yi) -1) <= 0) THEN
    		di = di + 2*xi + 1
			ELSE
				DEC yi
				di = di + (xi-yi+1) * 2
			END IF
		ELSE
			DEC yi
   		IF ((2 * (di-xi) - 1) <= 0) THEN
				INC xi
				di = di + (xi-yi+1) * 2
			ELSE
				di= di - (2*yi+1)
			END IF
		END IF
	LOOP
	RETURN $$TRUE

END FUNCTION
'
'
' ############################
' #####  DotFillRect ()  #####
' ############################
'
FUNCTION  DotFillRect (hDC, x1, y1, x2, y2, color)

	USHORT pattern[]

	DIM pattern[7]
	pattern[0] = 0xAA
	pattern[1] = 0x55
	pattern[2] = 0xAA
	pattern[3] = 0x55
	pattern[4] = 0xAA
	pattern[5] = 0x55
	pattern[6] = 0xAA
	pattern[7] = 0x55

	nSave 		= SaveDC (hDC)
	hBitmap 	= CreateBitmap (8, 8, 1, 1, &pattern[0])
	hBrush 		= CreatePatternBrush (hBitmap)
	DeleteObject(hBitmap)
	hOldBrush = SelectObject(hDC, hBrush)
	hOldPen   = SelectObject(hDC, GetStockObject ($$NULL_PEN))

	SetROP2 (hDC, $$R2_MASKPEN)
	SetBkColor (hDC, RGB(0xFF, 0xFF, 0xFF))
	SetTextColor (hDC, RGB(0, 0, 0))
	Rectangle (hDC, x1, y1, x2, y2)

	SetROP2 (hDC, $$R2_MERGEPEN)
	SetBkColor (hDC, RGB(0x0, 0x0, 0x0))
	SetTextColor (hDC, color)
	Rectangle (hDC, x1, y1, x2, y2)

	SelectObject (hDC, hOldBrush)
	SelectObject (hDC, hOldPen)
	DeleteObject (hBrush)

	RestoreDC (hDC, nSave)
	RETURN $$TRUE


END FUNCTION
'
'
' ################################
' #####  DottedRectangle ()  #####
' ################################
'
FUNCTION  DottedRectangle (hDC, x1, y1, x2, y2)

	USHORT pattern[]

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	IF x2 < x1 THEN SWAP x1, x2
	IF y2 < y1 THEN SWAP y1, y2

	DIM pattern[7]
	pattern[0] = 0xAA
	pattern[1] = 0x55
	pattern[2] = 0xAA
	pattern[3] = 0x55
	pattern[4] = 0xAA
	pattern[5] = 0x55
	pattern[6] = 0xAA
	pattern[7] = 0x55

	hBitmap = CreateBitmap (8, 8, 1, 1, &pattern[0])
	hBrush = CreatePatternBrush (hBitmap)
	DeleteObject (hBitmap)
	hOld = SelectObject (hDC, hBrush)

	PatBlt (hDC, x1, y1, x2-x1, 1, $$PATCOPY)
	PatBlt (hDC, x1, y2, x2-x1, 1, $$PATCOPY)
	PatBlt (hDC, x1, y1, 1, y2-y1, $$PATCOPY)
	PatBlt (hDC, x2, y1, 1, y2-y1, $$PATCOPY)

	SelectObject (hDC, hOld)
	DeleteObject (hBrush)
	RETURN ($$TRUE)

END FUNCTION
'
'
' ########################
' #####  DrawArc ()  #####
' ########################
'
' DrawArc() draws a arc of radius r with center of curvature at
'	current drawpoint.
' It begins at startAngle# and ends at endAngle# expressed in degrees.
'	Angles increase counterclockwise, and a circle is 360 degrees.
' Angles are folded into the range 0 to 360 before drawing.
' Note: this function uses trig functions from msvcrt.dll

FUNCTION  DrawArc (hDC, r, startAngle#, endAngle#)

	POINT pt

	$ARC_UNITS_PER_TWOPI = 0d40ACA5DC1A63C1F8			' 360 * 64 / $$TWOPI
	$DEGTORAD	= 0d3F91DF46A2529D39

	IFZ r THEN RETURN
	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	GetCurrentPositionEx (hDC, &pt)

	x				= pt.x
	y				= pt.y
	left		= x - r
	top			= y - r
	right		= x + r + 1													' include last pixel
	bottom	= y + r + 1
	start# 	= startAngle# * $DEGTORAD
	end# 		= endAngle# * $DEGTORAD
	x1			= x + 1024# * cos(start#)
	y1			= y - 1024# * sin(start#)
	x2			= x + 1024# * cos(end#)
	y2			= y - 1024# * sin(end#)

	Arc (hDC, left, top, right, bottom, x1, y1, x2, y2)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ###########################
' #####  DrawBorder ()  #####
' ###########################
'
' Draw various border styles using PolyPolyline ().
' This function is converted from XgrDrawBorder ().

FUNCTION  DrawBorder (hDC, fBorder, back, lo, hi, x1, y1, x2, y2)

	POINT pt
	STATIC  points[], pp[]
	LOGPEN logpen

	IFZ points[] THEN GOSUB Initialize
	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	IF ((border < 0) OR (border > $$BorderUpper)) THEN border = $$BorderRaise1

	IF (back 	= -1) THEN back = GetSysColor ($$COLOR_BTNFACE)
	IF (lo 		= -1) THEN lo   = 0					' black
	IF (hi 		= -1) THEN hi   = 16777215	' white
	lot   = GetSysColor ($$COLOR_BTNSHADOW)
	hit   = GetSysColor ($$COLOR_3DLIGHT)

	SELECT CASE fBorder
		CASE $$BorderNone																				: RETURN
		CASE $$BorderFlat																				: GOSUB Flat1
		CASE $$BorderFlat1																			: GOSUB Flat1
		CASE $$BorderFlat2																			: GOSUB Flat2
		CASE $$BorderFlat4																			: GOSUB Flat4
		CASE $$BorderHiLine1	: lo = hi													: GOSUB Raise1
		CASE $$BorderHiLine2	: lo = hi													: GOSUB Raise2
		CASE $$BorderHiLine4	: lo = hi													: GOSUB Raise4
		CASE $$BorderLine1		: lo = hi													: GOSUB Raise1
		CASE $$BorderLine2		: lo = hi													: GOSUB Raise2
		CASE $$BorderLine4		: lo = hi													: GOSUB Raise4
		CASE $$BorderLoLine1	: hi = lo													: GOSUB Raise1
		CASE $$BorderLoLine2	: hi = lo													: GOSUB Raise2
		CASE $$BorderLoLine4	: hi = lo													: GOSUB Raise4
		CASE $$BorderLower		: SWAP hi, lo											: GOSUB Raise1
		CASE $$BorderLower1		: SWAP hi, lo											: GOSUB Raise1
		CASE $$BorderLower2		: SWAP hi, lo											: GOSUB Raise2
		CASE $$BorderLower4		: SWAP hi, lo											: GOSUB Raise4
		CASE $$BorderRaise																			: GOSUB Raise1
		CASE $$BorderRaise1																			: GOSUB Raise1
		CASE $$BorderRaise2																			: GOSUB Raise2
		CASE $$BorderRaise4																			: GOSUB Raise4
		CASE $$BorderFrame																			: GOSUB Frame
		CASE $$BorderDrain		: SWAP hi, lo											: GOSUB Frame
		CASE $$BorderRidge																			: GOSUB Ridge
		CASE $$BorderValley																			: GOSUB Valley
		CASE $$BorderWide																				: GOSUB Wide
		CASE $$BorderWideResize																	: GOSUB WideResize
		CASE $$BorderWindow																			: GOSUB Window
		CASE $$BorderWindowResize																: GOSUB WindowResize
		CASE $$BorderRise2																			: GOSUB DrawBorderRise2
		CASE $$BorderSink2		: SWAP hi, lo		: SWAP hit, lot		: GOSUB DrawBorderRise2
	END SELECT
'
	IF oldPen THEN SelectObject (hDC, oldPen)
	IF hPen THEN DeleteObject (hPen)
	RETURN ($$TRUE)

' *****  Flat1  *****  Flat

SUB Flat1
	hi	= back
	lo	= back
	GOSUB DrawBorder1
END SUB

' *****  Flat2  *****  Flat2

SUB Flat2
	hi	= back
	lo	= back
	n		= 2
	GOSUB DrawBorderN
END SUB
'
'
' *****  Flat4  *****  Flat4
'
SUB Flat4
	hi	= back
	lo	= back
	n		= 4
	GOSUB DrawBorderN
END SUB
'
'
' *****  Raise1  *****  Up = 1
'
SUB Raise1
	GOSUB DrawBorder1
END SUB
'
'
' *****  Raise2  *****  Up = 2
'
SUB Raise2
	n		= 2
	GOSUB DrawBorderN
END SUB
'
'
' *****  Raise4  *****  Up = 4
'
SUB Raise4
	n		= 4
	GOSUB DrawBorderN
END SUB
'
'
' *****  Frame  *****  Up = 1, Flat = width-2, Down = 1  *****
'
SUB Frame
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 2																	' flat is 2 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	GOSUB DrawBorder1												' draw down-slope inside
END SUB
'
'
' *****  Ridge  *****  Looks simple, to draw is complex
'
SUB Ridge
	points[0] = x1 + 1	: points[1] = y2				' Line 0
	points[2] = x1 + 1	: points[3] = y1 + 1
	points[4] = x1 + 1	: points[5] = y1 + 1		' Line 1
	points[6] = x2			: points[7] = y1 + 1
	points[8] = x2			: points[9] = y1 + 1		' Line 2
	points[10] = x2			: points[11] = y2
	points[12] = x2			: points[13] = y2				' Line 3
	points[14] = x1 + 1	: points[15] = y2
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 4)

	points[0] = x1			: points[1] = y2 - 1		' Line 0
	points[2] = x1			: points[3] = y1
	points[4] = x1			: points[5] = y1				' Line 1
	points[6] = x2 - 1	: points[7] = y1
	points[8] = x2 - 1	: points[9] = y1				' Line 2
	points[10] = x2 - 1	: points[11] = y2 - 1
	points[12] = x2 - 1	: points[13] = y2 - 1		' Line 3
	points[14] = x1			: points[15] = y2 - 1
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 4)
END SUB
'
'
' *****  Valley  *****  Looks simple, to draw is complex
'
SUB Valley
	points[0] = x1			: points[1] = y2				' Line 0
	points[2] = x1			: points[3] = y1
	points[4] = x1			: points[5] = y1				' Line 1
	points[6] = x2			: points[7] = y1
	points[8] = x2 - 1	: points[9] = y1 + 2		' Line 2
	points[10] = x2 - 1	: points[11] = y2 - 1
	points[12] = x2 - 1	: points[13] = y2 - 1		' Line 3
	points[14] = x1 + 1	: points[15] = y2 - 1
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 4)

	points[0] = x1 + 1	: points[1] = y2				' Line 0
	points[2] = x1 + 1	: points[3] = y1 + 1
	points[4] = x1 + 1	: points[5] = y1 + 1		' Line 1
	points[6] = x2			: points[7] = y1 + 1
	points[8] = x2			: points[9] = y1 + 1		' Line 2
	points[10] = x2			: points[11] = y2
	points[12] = x2			: points[13] = y2				' Line 3
	points[14] = x1 + 1	: points[15] = y2
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 4)
END SUB
'
'
' *****  Wide  *****  Up = 1, Flat = 2, Down = 1  *****
'
SUB Wide
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 2																	' flat is 2 pixels wide
	n		= 4																	' flat is 4 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	GOSUB DrawBorder1												' draw down-slope inside
END SUB
'
'
' *****  WideResize  *****  Up = 1, Flat = 4, Down = 1, Resize marks  *****
'
SUB WideResize
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB Wide
'
' draw resize corner marks - 8 dark marks, then 8 light marks
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+25		: points[1] = y1+1
	points[2] = x1+25		: points[3] = y1+5
	points[4] = x2-26		: points[5] = y1+1
	points[6] = x2-26		: points[7] = y1+5
	points[8] = x2-4		: points[9] = y1+25
	points[10] = x2			: points[11] = y1+25
	points[12] = x2-4		: points[13] = y2-26
	points[14] = x2			: points[15] = y2-26
	points[16] = x2-26	: points[17] = y2-1
	points[18] = x2-26	: points[19] = y2-5
	points[20] = x1+25	: points[21] = y2-1
	points[22] = x1+25	: points[23] = y2-5
	points[24] = x1+1		: points[25] = y2-26
	points[26] = x1+5		: points[27] = y2-26
	points[28] = x1+1		: points[29] = y1+25
	points[30] = x1+5		: points[31] = y1+25
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 8)

	points[0] = x1+26		: points[1] = y1+1
	points[2] = x1+26		: points[3] = y1+5
	points[4] = x2-25		: points[5] = y1+1
	points[6] = x2-25		: points[7] = y1+5
	points[8] = x2-4		: points[9] = y1+26
	points[10] = x2			: points[11] = y1+26
	points[12] = x2-4		: points[13] = y2-25
	points[14] = x2			: points[15] = y2-25
	points[16] = x2-25	: points[17] = y2-4
	points[18] = x2-25	: points[19] = y2
	points[20] = x1+26	: points[21] = y2-4
	points[22] = x1+26	: points[23] = y2
	points[24] = x1+1		: points[25] = y2-25
	points[26] = x1+5		: points[27] = y2-25
	points[28] = x1+1		: points[29] = y1+26
	points[30] = x1+5		: points[31] = y1+26
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 8)
END SUB
'
'
' *****  WindowFrame  *****
'
SUB WindowFrame
	GOSUB DrawBorder1												' draw up-slope outside
	xhi	= hi
	xlo	= lo
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= back															' flat
	lo	= back															' flat
	n		= 2																	' flat is 2 pixels wide
	GOSUB DrawBorderN												' draw flat
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	INC x1 : INC y1 : DEC x2 : DEC y2				' move in 1 pixel
	hi	= xlo																' reverse hi : lo
	lo	= xhi																' reverse hi : lo
	GOSUB DrawBorder1												' draw down-slope inside
END SUB
'
'
' *****  WindowFrameResize  *****
'
SUB WindowFrameResize
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB WindowFrame
'
' draw resize corner marks - 8 dark marks, then 8 light marks
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+23		: points[1] = y1+0
	points[2] = x1+23		: points[3] = y1+3
	points[4] = x2-24		: points[5] = y1+0
	points[6] = x2-24		: points[7] = y1+3
	points[8] = x2-3		: points[9] = y1+23
	points[10] = x2-0		: points[11] = y1+23
	points[12] = x2-3		: points[13] = y2-24
	points[14] = x2-0		: points[15] = y2-24
	points[16] = x2-24	: points[17] = y2-0
	points[18] = x2-24	: points[19] = y2-3
	points[20] = x1+23	: points[21] = y2-0
	points[22] = x1+23	: points[23] = y2-3
	points[24] = x1+0		: points[25] = y2-24
	points[26] = x1+3		: points[27] = y2-24
	points[28] = x1+0		: points[29] = y1+23
	points[30] = x1+3		: points[31] = y1+23
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 8)

	points[0] = x1+24		: points[1] = y1+1
	points[2] = x1+24		: points[3] = y1+2
	points[4] = x2-23		: points[5] = y1+1
	points[6] = x2-23		: points[7] = y1+2
	points[8] = x2-3		: points[9] = y1+24
	points[10] = x2-0		: points[11] = y1+24
	points[12] = x2-3		: points[13] = y2-23
	points[14] = x2-0		: points[15] = y2-23
	points[16] = x2-23	: points[17] = y2-3
	points[18] = x2-23	: points[19] = y2-0
	points[20] = x1+24	: points[21] = y2-3
	points[22] = x1+24	: points[23] = y2-0
	points[24] = x1+0		: points[25] = y2-23
	points[26] = x1+3		: points[27] = y2-23
	points[28] = x1+0		: points[29] = y1+24
	points[30] = x1+3		: points[31] = y1+24
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 8)
END SUB
'
' *****  Window  *****
'
SUB Window
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB WindowFrame
'
' draw title bar - bright lines then dark lines
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+4		: points[1] = y1+23
	points[2] = x2-4		: points[3] = y1+23
	points[4] = x2-4		: points[5] = y1+23
	points[6] = x2-4		: points[7] = y1+4
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)

	points[0] = x1+4		: points[1] = y1+4
	points[2] = x2-4		: points[3] = y1+4
	points[4] = x1+4		: points[5] = y1+4
	points[6] = x1+4		: points[7] = y1+23
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
END SUB
'
'
' *****  WindowResize  *****
'
SUB WindowResize
	xx1 = x1 : yy1 = y1
	xx2 = x2 : yy2 = y2
	GOSUB WindowFrameResize
'
' draw title bar - bright lines then dark lines
'
	lo = xlo : hi = xhi
	x1 = xx1 : y1 = yy1
	x2 = xx2 : y2 = yy2
'
	points[0] = x1+4		: points[1] = y1+23
	points[2] = x2-4		: points[3] = y1+23
	points[4] = x2-4		: points[5] = y1+23
	points[6] = x2-4		: points[7] = y1+4
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)

	points[0] = x1+4		: points[1] = y1+4
	points[2] = x2-4		: points[3] = y1+4
	points[4] = x1+4		: points[5] = y1+4
	points[6] = x1+4		: points[7] = y1+23
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
END SUB
'
'
' *****  DrawBorder1  *****  1 pixel wide border
'
SUB DrawBorder1
	points[0] = x1	: points[1] = y1		' left-edge
	points[2] = x1	: points[3] = y2
	points[4] = x1	: points[5] = y1		' top-edge
	points[6] = x2	: points[7] = y1
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)

	points[0] = x2	: points[1] = y1		' right-edge
	points[2] = x2	: points[3] = y2+1
	points[4] = x1	: points[5] = y2		' bottom-edge
	points[6] = x2	: points[7] = y2
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
END SUB
'
' *****  DrawBorderN  *****  n pixel wide border - max 4 pixels wide
'
SUB DrawBorderN
	j = 0
	FOR i = 0 TO n - 1
		points[j    ] = x1 + i	: points[j + 1] = y2 - i			' left
		points[j + 2] = x1 + i	: points[j + 3] = y1 + i
		points[j + 4] = x1 + i	: points[j + 5] = y1 + i			' upper
		points[j + 6] = x2 - i + 1	: points[j + 7] = y1 + i
		j = j + 8
	NEXT i
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], (n << 1))

	j = 0
	FOR i = 0 TO n - 1
		points[j    ] = x1 + i	: points[j + 1] = y2 - i			' lower
		points[j + 2] = x2 - i	: points[j + 3] = y2 - i
		points[j + 4] = x2 - i	: points[j + 5] = y2 - i			' right
		points[j + 6] = x2 - i	: points[j + 7] = y1 + i
		j = j + 8
	NEXT i
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], (n << 1))
END SUB
'
'
' *****  DrawBorderRise2  *****  2 pixel wide border with 2 dark and 2 bright colors
'
SUB DrawBorderRise2
	points[0] = x1		: points[1] = y1		' left-edge
	points[2] = x1		: points[3] = y2
	points[4] = x1		: points[5] = y1		' top-edge
	points[6] = x2		: points[7] = y1
	penColor = hi
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
	points[0] = x1+1	: points[1] = y1+1	' left-edge
	points[2] = x1+1	: points[3] = y2-1
	points[4] = x1+1	: points[5] = y1+1	' top-edge
	points[6] = x2-1	: points[7] = y1+1
	penColor = hit
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
'
	points[0] = x2		: points[1] = y1			' right-edge
	points[2] = x2		: points[3] = y2 + 1
	points[4] = x1		: points[5] = y2			' bottom-edge
	points[6] = x2		: points[7] = y2
	penColor = lo
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
	points[0] = x2-1	: points[1] = y1+1		' right-edge
	points[2] = x2-1	: points[3] = y2
	points[4] = x1+1	: points[5] = y2-1		' bottom-edge
	points[6] = x2-1	: points[7] = y2-1
	penColor = lot
	GOSUB NewPen
	PolyPolyline (hDC, &points[0], &pp[0], 2)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM points[31]
	DIM pp[31]
	FOR i = 0 TO 31
		pp[i] = 2
	NEXT i
END SUB

' ***** NewPen *****
SUB NewPen
	IF oldPen THEN SelectObject (hDC, oldPen)
	IF hPen THEN DeleteObject (hPen)
	hCurPen = GetCurrentObject (hDC, $$OBJ_PEN)
	GetObjectA (hCurPen, SIZE(logpen), &logpen)
	hPen   = CreatePen (logpen.style, 1, penColor)
	oldPen = SelectObject (hDC, hPen)
END SUB

END FUNCTION
'
'
' #############################
' #####  DrawControls ()  #####
' #############################
'
FUNCTION  DrawControls (hDC, type, @state[])

	STATIC y
	RECT rect

	upper = UBOUND(state[])
	size = 30
	gap = 10
	IF type = $$DFC_CAPTION THEN y = gap

	rect.top = y
	rect.bottom = y + size

	FOR s = 0 TO upper
		rect.left 	= (s*size) + (s*gap) + gap
		rect.right 	= rect.left + size
		DrawFrameControl (#hMemDC, &rect, type, state[s])
	NEXT s
	y = y + size + gap

END FUNCTION
'
'
' #################################
' #####  DrawGradientRect ()  #####
' #################################

'PURPOSE : Draw a gradient rectangle from color1 to color2
'IN      : hDC, x1, y1, x2, y2, color1, color2, mode (0 = vertical, 1 = horizontal)
'
FUNCTION  DrawGradientRect (hDC, x1, y1, x2, y2, color1, color2, mode)

	DOUBLE sRedHor, sGreenHor, sBlueHor
	DOUBLE sRedVert, sGreenVert, sBlueVert
	DOUBLE width, height
	DOUBLE deltaRed, deltaGreen, deltaBlue

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	red1 = color1{8,0}
	red2 = color2{8,0}
	green1 = color1{8,8}
	green2 = color2{8,8}
	blue1 = color1{8,16}
	blue2 = color2{8,16}

	deltaRed 		= red2 - red1
	deltaGreen 	= green2 - green1
	deltaBlue 	= blue2 - blue1

	IF x2 < x1 THEN SWAP x1, x2
	IF y2 < y1 THEN SWAP y1, y2

	width = x2 - x1
	height = y2 - y1

	IFZ width THEN RETURN
	IFZ height THEN RETURN

	sRedHor 		=	deltaRed/width
	sGreenHor 	= deltaGreen/width
	sBlueHor 		= deltaBlue/width

	sRedVert 		= deltaRed/height
	sGreenVert 	= deltaGreen/height
	sBlueVert 	=	deltaBlue/height

	IFZ mode THEN
		FOR i = 0 TO height
			red 	= red1 		+ i * sRedVert
			green = green1 	+ i * sGreenVert
			blue 	= blue1 	+ i * sBlueVert
			hPen 	= CreatePen ($$PS_SOLID, 1, RGB(red, green, blue))
			hOld 	= SelectObject (hDC, hPen)
			MoveToEx (hDC, x1, y1+i, 0)
			LineTo (hDC, x2, y1+i)
			SelectObject (hDC, hOld)
			DeleteObject (hPen)
		NEXT i
	ELSE
		FOR i = 0 TO width
			red 	= red1 		+ i * sRedHor
			green = green1 	+ i * sGreenHor
			blue 	= blue1 	+ i * sBlueHor
			hPen 	= CreatePen ($$PS_SOLID, 1, RGB(red, green, blue))
			hOld 	= SelectObject (hDC, hPen)
			MoveToEx (hDC, x1+i, y1, 0)
			LineTo (hDC, x1+i, y2)
			SelectObject (hDC, hOld)
			DeleteObject (hPen)
		NEXT i
	END IF
	RETURN ($$TRUE)

END FUNCTION
'
'
' ########################
' #####  DrawPie ()  #####
' ########################
'
' DrawPie() draws a pie of radius r with center of curvature at
'	current drawpoint.
' It begins at startAngle# and ends at endAngle# expressed in degrees.
'	Angles increase counterclockwise, and a circle is 360 degrees.
' Angles are folded into the range 0 to 360 before drawing.
' Note: this function uses trig functions from msvcrt.dll

FUNCTION  DrawPie (hDC, r, startAngle#, endAngle#)

	POINT pt

	$ARC_UNITS_PER_TWOPI = 0d40ACA5DC1A63C1F8			' 360 * 64 / $$TWOPI
	$DEGTORAD	= 0d3F91DF46A2529D39

	IFZ r THEN RETURN
	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	GetCurrentPositionEx (hDC, &pt)

	x				= pt.x
	y				= pt.y
	left		= x - r
	top			= y - r
	right		= x + r + 1													' include last pixel
	bottom	= y + r + 1
	start# 	= startAngle# * $DEGTORAD
	end# 		= endAngle# * $DEGTORAD
	x1			= x + 1024# * cos(start#)
	y1			= y - 1024# * sin(start#)
	x2			= x + 1024# * cos(end#)
	y2			= y - 1024# * sin(end#)

	Pie (hDC, left, top, right, bottom, x1, y1, x2, y2)
	RETURN ($$TRUE)
END FUNCTION
'
'
' #############################
' #####  DrawPieChart ()  #####
' #############################
'
' Draw a simple pie chart centered at x,y with radius r
' IN:
' color 		- border color
' fcolor[] 	- fill color for each pie
' data[] 		- data values for each pie
'
FUNCTION  DrawPieChart (hDC, x, y, r, color, DOUBLE data[], fcolor[])

	DOUBLE sum, angle, a

	IFZ r THEN RETURN
	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	IFZ data[] THEN RETURN
	upper = UBOUND(data[])

	IFZ fcolor[] THEN
		REDIM fcolor[upper]
		c = RGB(0xFF, 0xFF, 0xFF)						' set default color to white
		FOR i = 0 TO upper
			fcolor[i] = c
		NEXT i
	END IF

	upperColor = UBOUND(fcolor[])
	IF upperColor < upper THEN REDIM fcolor[upper]

	MoveToEx (#hMemDC, x, y, 0)

	hPen = CreatePen ($$PS_SOLID, 1, color)
	hOldPen = SelectObject (hDC, hPen)

	FOR i = 0 TO upper
		sum = sum + data[i]
	NEXT i


	FOR i = 0 TO upper
		a = data[i] / sum * 360.0
		hBrush = CreateSolidBrush (fcolor[i])
		hBrushOld = SelectObject (hDC, hBrush)
		DrawPie (hDC, r, angle, angle+a)
		angle = angle + a
		SelectObject (hDC, hBrushOld)
		DeleteObject (hBrush)
	NEXT i

	SelectObject (hDC, hOldPen)
	DeleteObject (hPen)
	RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  DrawRegularPolygon ()  #####
' ###################################
'
' PURPOSE	: draw a regular polygon
' IN			: x - x coordinate of polygon center
'           y - y coordinate of polygon center
'           radius - radius of polygon
'           angle - starting rotation angle of polygon (>=0)
'           sides - number of sides (>2)
'
FUNCTION  DrawRegularPolygon (hDC, x, y, r, DOUBLE angle, sides)

	POINT winPts[]
	DOUBLE delta, degree, xTemp, yTemp

	$DEGTORAD	= 0d3F91DF46A2529D39

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	IFZ r THEN RETURN
	IF sides < 3 THEN RETURN
	IF angle < 0 THEN angle = 0

	DIM winPts[sides-1]

'calc polygon vertices
	upper = UBOUND (winPts[])

	delta  = 360.0 / DOUBLE(sides)
	degree = angle

	FOR i = 0 TO upper
		xTemp = x + r * cos(degree*$DEGTORAD)
		yTemp = y + r * sin(degree*$DEGTORAD)
		winPts[i].x = XLONG(xTemp)
		winPts[i].y = XLONG(yTemp)
		degree = degree + delta
	NEXT i

'Draw polygon
	Polygon (hDC, &winPts[], upper+1)

	RETURN ($$TRUE)


END FUNCTION
'
'
' ################################
' #####  EllipseToBezier ()  #####
' ################################
'
' Note: EllipseToBezier taken from Windows Graphics Programming - Yuan
' draw an ellipse as approximated by four bezier curves
'
FUNCTION  EllipseToBezier (hDC, x1, y1, x2, y2)

	POINT pt[12]

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	M# = 0.55228474983
	c# = (1.0 - M#)/2.0
	dx = (x2-x1) * c#
	dy = (y2-y1) * c#

	tb = (y1+y2)/2
	lr = (x1+x2)/2

	pt[0].x = x2
	pt[0].y = tb
	pt[1].x = x2
	pt[1].y = y1+dy
	pt[2].x = x2-dx
	pt[2].y = y1
	pt[3].x = lr
	pt[3].y = y1

	pt[4].x = x1+dx
	pt[4].y = y1
	pt[5].x = x1
	pt[5].y = y1+dy
	pt[6].x = x1
	pt[6].y = tb

	pt[7].x = x1
	pt[7].y = y2-dx
	pt[8].x = x1+dx
	pt[8].y = y2
	pt[9].x = lr
	pt[9].y = y2

	pt[10].x = x2-dx
	pt[10].y = y2
	pt[11].x = x2
	pt[11].y = y2-dy
	pt[12].x = x2
	pt[12].y = tb

	PolyBezier (hDC, &pt[0], 13)
	RETURN ($$TRUE)


END FUNCTION
'
'
' ############################
' #####  HexFillRect ()  #####
' ############################
'
' Fill a rect area with hexagons
' IN	: x1, y1, x2, y2	- rect area
'				r								- hexagon radius
'				mode						- direction (0 or 1)
'
FUNCTION  HexFillRect (hDC, x1, y1, x2, y2, r, mode)

	POINT hex[5], pts[5]
	DOUBLE delta, degree, xTemp, yTemp, offsetx, offsety

	$DEGTORAD	= 0d3F91DF46A2529D39
	cos30# = 0.866025403
	sqrt3# = 1.732050808

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	IFZ r THEN RETURN

'	DIM hex[5]
'	DIM pts[5]

	delta  = 60.0
	IFZ mode THEN
		degree = 0.0
	ELSE
		degree = 90.0
	END IF

	IF x2 < x1 THEN SWAP x1, x2
	IF y2 < y1 THEN SWAP y1, y2

	FOR i = 0 TO 5
		xTemp = r * cos(degree*$DEGTORAD)
		yTemp = r * sin(degree*$DEGTORAD)
		hex[i].x = XLONG(xTemp)
		hex[i].y = XLONG(yTemp)
		degree = degree + delta
	NEXT i

	hRgn = CreateRectRgn (x1, y1, x2+1, y2+1)			' create a region object
	SelectClipRgn (hDC, hRgn)											' select region into hDC
	DeleteObject (hRgn)														' delete region object
	w# = r * cos30#

	IFZ mode THEN
		offsetx = w# * 2.0 * sqrt3#
		offsety = w#
		stepx = XLONG(offsetx)
		stepx2 = stepx/2
		stepy = XLONG(offsety)
	ELSE
		offsetx = 2.0 * w#
		offsety = w# * sqrt3#
		stepx = XLONG(offsetx)
		stepx2 = stepx/2
		stepy = XLONG(offsety)
	END IF

	FOR y = y1 TO y2+stepy STEP stepy
		FOR x = x1 TO x2+stepx STEP stepx
			FOR i = 0 TO 5
				IF (count & 1) THEN
					pts[i].x = hex[i].x + x + stepx2
				ELSE
					pts[i].x = hex[i].x + x
				END IF
				pts[i].y = hex[i].y + y
			NEXT i
			Polygon (hDC, &pts[], 6)
		NEXT x
		INC count
	NEXT y

' reset clip region
	SelectClipRgn (hDC, 0)

	RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  HLSGradientRect ()  #####
' ################################

'PURPOSE : Draw a gradient rectangle from color1 to color2
'IN      : hDC, x1, y1, x2, y2, color1, color2, mode (0 = vertical, 1 = horizontal)
'
FUNCTION  HLSGradientRect (hDC, x1, y1, x2, y2, color1, color2, mode)

	DOUBLE sHHor, sLHor, sSHor
	DOUBLE sHVert, sLVert, sSVert
	DOUBLE width, height
	DOUBLE deltaH, deltaL, deltaS
	DOUBLE h, l, s

	IFZ hDC THEN RETURN
	type = GetObjectType (hDC)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	RGBtoHLS (color1, @hue1#, @lightness1#, @saturation1#)
	RGBtoHLS (color2, @hue2#, @lightness2#, @saturation2#)

	deltaH 	= hue2# - hue1#
	deltaL 	= lightness2# - lightness1#
	deltaS 	= saturation2# - saturation1#

	IF x2 < x1 THEN SWAP x1, x2
	IF y2 < y1 THEN SWAP y1, y2

	width  = x2 - x1
	height = y2 - y1

	IFZ width THEN RETURN
	IFZ height THEN RETURN

	IFZ mode THEN
		sHVert 	= deltaH/height
		sLVert 	= deltaL/height
		sSVert 	=	deltaS/height
		FOR i = 0 TO height
			h = hue1# 				+ i * sHVert
			l = lightness1# 	+ i * sLVert
			s = saturation1# 	+ i * sSVert
			HLStoRGB (h, l, s, @red, @green, @blue)
			hPen 	= CreatePen ($$PS_SOLID, 1, RGB(red, green, blue))
			hOld 	= SelectObject (hDC, hPen)
			MoveToEx (hDC, x1, y1+i, 0)
			LineTo (hDC, x2, y1+i)
			SelectObject (hDC, hOld)
			DeleteObject (hPen)
		NEXT i
	ELSE
		sHHor =	deltaH/width
		sLHor = deltaL/width
		sSHor = deltaS/width
		FOR i = 0 TO width
			h = hue1# 				+ i * sHHor
			l = lightness1# 	+ i * sLHor
			s = saturation1# 	+ i * sSHor
			HLStoRGB (h, l, s, @red, @green, @blue)
			hPen 	= CreatePen ($$PS_SOLID, 1, RGB(red, green, blue))
			hOld 	= SelectObject (hDC, hPen)
			MoveToEx (hDC, x1+i, y1, 0)
			LineTo (hDC, x1+i, y2)
			SelectObject (hDC, hOld)
			DeleteObject (hPen)
		NEXT i
	END IF

	RETURN ($$TRUE)

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
' #########################
' #####  Triangle ()  #####
' #########################
'
FUNCTION  Triangle (hDC, x0, y0, x1, y1, x2, y2, extra)

	POINT corner[]
	DIM corner[4]
	corner[0].x = x0
	corner[0].y = y0
	corner[1].x = x1
	corner[1].y = y1
	corner[2].x = x2
	corner[2].y = y2
	corner[3].x = x0
	corner[3].y = y0
	corner[4].x = x1
	corner[4].y = y1

	IF extra THEN
		Polyline (hDC, &corner[0], 5)						' extra segment to make nicer closing join
	ELSE
		Polyline (hDC, &corner[0], 4)
	END IF
	RETURN ($$TRUE)

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
	RETURN $$TRUE
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
' ########################
' #####  RGBCube ()  #####
' ########################
'
FUNCTION  RGBCube (hDC)

	RECT rect
	BITMAP bmp
	POINT pt
	SIZEAPI sizeWin, sizeView

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

	oldMapMode = GetMapMode (hDC)
	SetMapMode (hDC, $$MM_ANISOTROPIC)
	SetWindowExtEx (hDC, 1, 1, &sizeWin)
	SetViewportExtEx (hDC, 1, -1, &sizeView)
	SetViewportOrgEx (hDC, 40, h-40, &pt)

	MoveToEx (hDC, -20, -20, 0)
	LineTo (hDC, 128, 128)
	LineTo (hDC, 128+256+30, 128)
	MoveToEx (hDC, 128, 128, 0)
	LineTo (hDC, 128, 128+256+30)

	TextOutA (hDC, -20, -20, &"Red RGB(255,0,0)", 3+13)
	TextOutA (hDC, 128+256+30, 128, &"Green RGB(0,255,0)", 5+13)
	TextOutA (hDC, 128, 128+256+30, &"Blue RGB(0,0,255)", 4+13)

' Red = 255
	FOR g = 0 TO 255
		FOR b = 0 TO 255
			SetPixel (hDC, g, b, RGB(0xFF, g, b))
		NEXT b
	NEXT g

' Blue = 255
	FOR g = 0 TO 255
		FOR r = 0 TO 255 STEP 2
			SetPixel (hDC, g+128-r/2, 255+128-r/2, RGB(r, g, 0xFF))
		NEXT r
	NEXT g

' Green = 255
	FOR b = 0 TO 255
		FOR r = 0 TO 255 STEP 2
			SetPixel (hDC, 255+128-r/2, b+128-r/2, RGB(r, 0xFF, b))
		NEXT r
	NEXT b

	SetMapMode (hDC, oldMapMode)
	SetWindowExtEx (hDC, sizeWin.cx, sizeWin.cy, 0)
	SetViewportExtEx (hDC, sizeView.cx, sizeView.cy, 0)
	SetViewportOrgEx (hDC, pt.x, pt.y, 0)

	RETURN ($$TRUE)

END FUNCTION
'
'
' #########################
' #####  RGBtoHLS ()  #####
' #########################
'
FUNCTION  RGBtoHLS (color, DOUBLE hue, DOUBLE lightness, DOUBLE saturation)

	DOUBLE mn, mx

	$Red 		= 0
	$Green 	= 1
	$Blue 	= 2

	red 	= color{8,0}
	green = color{8,8}
	blue 	= color{8,16}

	IF red < green THEN
		mn = red
		mx = green
		major = $Green
	ELSE
		mn = green
		mx = red
		major = $Red
	END IF

	IF blue < mn THEN
		mn = blue
	ELSE
		IF blue > mx THEN
			mx = blue
			major = $Blue
		END IF
	END IF

	IF mn == mx THEN
		lightness 	= mn/255.0
		saturation 	= 0
		hue 				= 0
	ELSE
		lightness = (mn+mx)/510.0
		IF lightness <= 0.5 THEN
			saturation = (mx-mn)/(mn+mx)
		ELSE
			saturation = (mx-mn)/(510.0-mn-mx)
		END IF

		SELECT CASE major
			CASE $Red 	:	hue = (green-blue)*60/(mx-mn)+360
			CASE $Green :	hue = (blue-red)	*60/(mx-mn)+120
			CASE $Blue	:	hue = (red-green)	*60/(mx-mn)+240
		END SELECT

		IF hue > 360 THEN hue = hue - 360
	END IF

END FUNCTION
'
'
' ######################
' #####  Value ()  #####
' ######################
'
FUNCTION  Value (DOUBLE m1, DOUBLE m2, DOUBLE h)

	IF h > 360 THEN
		h = h - 360
	ELSE
		IF h < 0 THEN
			h = h + 360
		END IF
	END IF

	IF h < 60 THEN
		m1 = m1 + (m2-m1) * h/60.0
	ELSE
		IF h < 180 THEN
			m1 = m2
		ELSE
			IF h < 240 THEN
				m1 = m1 + (m2-m1) * (240-h)/60.0
			END IF
		END IF
	END IF
	RETURN m1 * 255

END FUNCTION
'
'
' #########################
' #####  HLStoRGB ()  #####
' #########################
'
FUNCTION  HLStoRGB (DOUBLE hue, DOUBLE lightness, DOUBLE saturation, red, green, blue)

	DOUBLE m1, m2

	IFZ saturation THEN
		red 	= lightness * 255
		green = red
		blue 	= red
	ELSE
		IF lightness <= 0.5 THEN
			m2 = lightness + lightness * saturation
		ELSE
			m2 = lightness + saturation - lightness * saturation
		END IF
		m1 = 2 * lightness - m2
		red 	= Value (m1, m2, hue+120)
		green = Value (m1, m2, hue)
		blue 	= Value (m1, m2, hue-120)
	END IF


END FUNCTION
END PROGRAM
