'
'
' ####################
' #####  PROLOG  #####
' ####################
'
'
PROGRAM	"triangles"
VERSION	"0.0002"
'MAKEFILE "xexe.xxx"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"		' ms VC runtime library
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, wndProcAddr)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  ClearWindow (hWnd)
DECLARE FUNCTION  CreateXBColorIndex ()
DECLARE FUNCTION  TriangleFilled (hDC, color, fDirection, x1, y1, x2, y2)
DECLARE FUNCTION  DrawTriangles (hDC)

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
FUNCTION  Entry ()

	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

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

	SHARED hdc
	SHARED cyClient, cxClient
	SHARED paused

	SELECT CASE msg

		CASE $$WM_CREATE:

			hdc = GetDC (hWnd)

' initialize random number generator
			seed = (GetTickCount () MOD 32767) + 1
			srand (seed)

' create color index of 125 XBasic colors
			CreateXBColorIndex ()

			RETURN

		CASE $$WM_SIZE:
			cxClient = LOWORD (lParam)
 			cyClient = HIWORD (lParam)
			RETURN

		CASE $$WM_DESTROY:
			ReleaseDC (hWnd, hdc)
			PostQuitMessage(0)
			RETURN

		CASE $$WM_KEYDOWN:
			DestroyWindow (hWnd)
			RETURN

		CASE $$WM_LBUTTONDOWN:
			IF paused THEN
				paused = $$FALSE
			ELSE
				paused = $$TRUE
			END IF
			RETURN

	END SELECT

RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
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
FUNCTION  RegisterWinClass (className$, wndProcAddr)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW
	wc.lpfnWndProc     = wndProcAddr
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
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

' create main window

	className$  = "Triangles"
	titleBar$  	= "Triangles."
	style 			= $$WS_POPUP
	w 					= GetSystemMetrics ($$SM_CXSCREEN)
	h 					= GetSystemMetrics ($$SM_CYSCREEN)
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)

	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

END FUNCTION
'
'
' ##########################
' #####  NewWindow ()  #####
' ##########################
'
FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)

	SHARED hInst
	SHARED winProcAddr
	IFZ winProcAddr THEN winProcAddr = &WndProc()

	IFZ	RegisterWinClass (className$, winProcAddr) THEN QUIT(0)
	RETURN CreateWindowExA (exStyle, &className$, &title$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
'
'
' ############################
' #####  MessageLoop ()  #####
' ############################
'
FUNCTION  MessageLoop ()

	USER32_MSG msg
	SHARED paused
	SHARED hdc
	SHARED cyClient, cxClient

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			IF msg.message = $$WM_QUIT THEN EXIT DO
			TranslateMessage (&msg)							' translate virtual-key messages into character messages
			DispatchMessageA (&msg)							' send message to window callback function WndProc()
		ELSE
			IF !paused THEN
				ClearWindow (#winMain)
				DrawTriangles (hdc)
				Sleep (5000)
			ELSE
				Sleep (0)
			END IF
		END IF
	LOOP

END FUNCTION
'
'
' ############################
' #####  InitConsole ()  #####
' ############################
'
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	SHARED fConsole

	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' ############################
' #####  ClearWindow ()  #####
' ############################
'
FUNCTION  ClearWindow (hWnd)

	RECT rect
	SHARED hdc

	GetClientRect (hWnd, &rect)
	FillRect (hdc, &rect, GetStockObject ($$BLACK_BRUSH))
'	InvalidateRect (hWnd, &rect, 1)

END FUNCTION
'
'
' ###################################
' #####  CreateXBColorIndex ()  #####
' ###################################
'
' PURPOSE : Create the XBasic color index of 125 colors
'
FUNCTION  CreateXBColorIndex ()

	SHARED colorPixel[]

	DIM colorPixel[255]
	colorIndex = 0
	red = 0x00
	FOR r = 0 TO 4
		green = 0x00
		FOR g = 0 TO 4
			blue = 0x00
			FOR b = 0 TO 4
				colorPixel[colorIndex] = (blue << 16) OR (green << 8) OR red
				INC colorIndex
				blue = blue + 0x40
				IF (blue > 0xFF) THEN blue = 0xFF
			NEXT b
			green = green + 0x40
			IF (green > 0xFF) THEN green = 0xFF
		NEXT g
		red = red + 0x40
		IF (red > 0xFF) THEN red = 0xFF
	NEXT r


END FUNCTION
'
'
' ###############################
' #####  TriangleFilled ()  #####
' ###############################
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
' ##############################
' #####  DrawTriangles ()  #####
' ##############################
'
FUNCTION  DrawTriangles (hDC)

	RECT rect
	SHARED cyClient, cxClient
	SHARED colorPixel[]

' vary size of triangles
	w = (rand() MOD 76) + 25			' 25 - 100
	h = w
'	w = 40
'	h = 40

' vary direction
	dir = rand() MOD 4
	SELECT CASE dir
		CASE 0 : fDirection = $$TriangleUp
		CASE 1 : fDirection = $$TriangleRight
		CASE 2 : fDirection = $$TriangleDown
		CASE 3 : fDirection = $$TriangleLeft
	END SELECT

	FOR i = 0 TO cyClient-1 STEP h
		y1 = i
		FOR j = 0 TO cxClient-1 STEP w
			x1 = j
' vary color
			index = (rand() MOD 125) + 1
			color = colorPixel[index]

			x2 = x1 + w
			y2 = y1 + h
			TriangleFilled (hDC, color, fDirection, x1, y1, x2, y2)

		NEXT j
	NEXT i

END FUNCTION
END PROGRAM
