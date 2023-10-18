'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of drawing 'spirographic' drawings
' by using parametric equations and plotting
' points with SetPixelV().
'
PROGRAM	"spiro"
VERSION	"0.0004"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"msvcrt"		' ms VC runtime library
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  DrawEpitrochoid (hdc, x, y, a, b, h, color)
DECLARE FUNCTION  ClearWindow (hWnd)
DECLARE FUNCTION  DrawHypotrochoid (hdc, x, y, a, b, h, color)
DECLARE FUNCTION  CreateXBColorIndex ()

$$DEGTORAD	= 0d3F91DF46A2529D39
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

		CASE $$WM_SIZE:
			cxClient = LOWORD (lParam)
 			cyClient = HIWORD (lParam)

		CASE $$WM_DESTROY:
			ReleaseDC (hWnd, hdc)
			PostQuitMessage(0)

		CASE $$WM_LBUTTONDOWN:
			IF paused THEN
				paused = $$FALSE
			ELSE
				paused = $$TRUE
			END IF

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
	wc.hbrBackground   = GetStockObject ($$BLACK_BRUSH)
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
	className$  = "SpiroDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Spirographics Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 560
	h 					= 580
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

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

	MSG msg
	SHARED paused
	SHARED hdc
	SHARED cyClient, cxClient
	SHARED colorPixel[]

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
				GOSUB GetEpiParams
				DrawEpitrochoid (hdc, x, y, a, b, h, color)
				GOSUB GetHypoParams
				DrawHypotrochoid (hdc, x, y, a, b, h, color)
				Sleep (1000)
			ELSE
				Sleep (0)
			END IF
		END IF
	LOOP


' ***** GetEpiParams *****
SUB GetEpiParams

	x = cxClient / 2.0
	y = cyClient / 2.0

doagain:
	a = (rand() MOD y) + 1
	t = (y - a)/2 
	IF t <= 0 THEN GOTO doagain
	b = (rand() MOD t) + 1
	h = rand() MOD b 
	
' create a random color
	GOSUB GetColor

END SUB

' ***** GetHypoParams *****
SUB GetHypoParams

	x = cxClient / 2.0
	y = cyClient / 2.0
start:
	a = (rand() MOD y) + 1
	t = a/2 - 1
	IF t <= 0 THEN GOTO start
	b = ( rand() MOD t ) + 1
	h = rand() MOD b

' create a random color
	GOSUB GetColor

END SUB

' ***** GetColor *****
SUB GetColor
' create a random color
	index = (rand() MOD 124) + 1
	color = colorPixel[index]
END SUB

END FUNCTION
'
'
' ########################
' #####  CleanUp ()  #####
' ########################
'
FUNCTION  CleanUp ()

	SHARED hInst, className$
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' ################################
' #####  DrawEpitrochoid ()  #####
' ################################
'
' PURPOSE	: Plot an epitrochoid shape
'						A point at distance h from the center of
'						an outside circle of radius b is rotated
'						around a circle of radius a.
'	IN			: hdc - handle device context
' 				: x - x center position
'					: y - y center position
'					: a - radius of main circle
'					: b - radius of outside circle
'					: h - distance from center of outside circle
'					: color - color of shape
'
FUNCTION  DrawEpitrochoid (hdc, x, y, a, b, h, color)

' draw epitrochoid spirogram by plotting
' points from parametric equations

'  dtr# = $$DEGTORAD
  increment# = 0.25   'increment for degrees, smaller for more detailed drawings

 	t#    = 0       		'theta degrees
  m#    = a + b
  rm#   = m#/b
  tdtr# = t#*$$DEGTORAD
  mbt#  = rm#*tdtr#

'Parametric equations for epitrochoid
	x0# = (m# * cos(tdtr#)) - (h * cos(mbt#)) + x
	y0# = (m# * sin(tdtr#)) - (h * sin(mbt#)) + y

'draw first point at x0, y0 and t=0
	xset0 = INT(x0#)
	yset0 = INT(y0#)

' set pixel
	SetPixelV (hdc, xset0, yset0, color)
	x# = 0.       'reset x
	y# = 0.       'reset y position

'	draw the rest of the points until the pattern starts over
	DO WHILE (x# <> x0#)
		t#    = t# + increment#    'increment by .25 degrees
		tdtr# = t#*$$DEGTORAD						'dtr#
		mbt#  = rm#*tdtr#
		x#    = (m# * cos(tdtr#)) - (h * cos(mbt#)) + x
		y#    = (m# * sin(tdtr#)) - (h * sin(mbt#)) + y
		xset  = INT(x#)
		yset  = INT(y#)
		SetPixelV (hdc, xset, yset, color)
	LOOP


	RETURN

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
' #################################
' #####  DrawHypotrochoid ()  #####
' #################################
'
' PURPOSE	: Plot an hypotrochoid shape
'						A point at distance h from the center of
'						an inner circle of radius b is rotated
'						around the inside surface of circle of radius a.
'	IN			: hdc - handle device context
' 				: x - x center position
'					: y - y center position
'					: a - radius of main circle
'					: b - radius of inside circle
'					: h - distance from center of inside circle
'					: color - color of shape
'
FUNCTION  DrawHypotrochoid (hdc, x, y, a, b, h, color)

	increment# = 0.25   'increment for degrees, smaller for more detailed drawings

'draw a hypotrochoid type spirograph
	t# = 0       'theta degrees
	n# = a - b
	rn# = n#/b
	tdtr# = t#*$$DEGTORAD
	nbt# = rn#*tdtr#

	x0# = n# * cos(tdtr#) + (h * cos(nbt#)) + x
	y0# = n# * sin(tdtr#) - (h * sin(nbt#)) + y
	xset0 = INT(x0#)             'draw first point at x0 y0 and t=0
	yset0 = INT(y0#)
	SetPixelV (hdc, xset0, yset0, color)

	x# = 0.       'reset x
	y# = 0.       'reset y position

	DO 	WHILE (x# <> x0#)
		t# = t# + increment#    'increment by .25 degrees
		tdtr# = t#*$$DEGTORAD
		nbt# = rn#*tdtr#
		x# = n# * cos(tdtr#) + (h * cos(nbt#)) + x
		y# = n# * sin(tdtr#) - (h * sin(nbt#)) + y
		xset = INT(x#)
		yset = INT(y#)
		SetPixelV (hdc, xset, yset, color)
	LOOP

	RETURN

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
END PROGRAM
