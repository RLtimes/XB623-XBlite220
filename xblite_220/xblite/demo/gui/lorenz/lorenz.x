'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of drawing two Lorenz Attractors.
' They start with almost identical initial
' parameters but quickly diverge.
' Original Win32 "C" version by Ged Toon
' Modified from BCX version by Kevin Diggins
'
PROGRAM	"lorenz"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
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
DECLARE FUNCTION  DrawRectangle (hWnd)
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
	SHARED hbrushes[]
	SHARED cyClient, cxClient

	SELECT CASE msg

		CASE $$WM_CREATE:
			DIM hbrushes[1,9]

' create two brush arrays
 			hbrushes[0,0] = CreateSolidBrush (RGB (250, 0, 0))
 			hbrushes[0,1] = CreateSolidBrush (RGB (240, 0, 0))
 			hbrushes[0,2] = CreateSolidBrush (RGB (230, 0, 0))
 			hbrushes[0,3] = CreateSolidBrush (RGB (190, 0, 0))
 			hbrushes[0,4] = CreateSolidBrush (RGB (170, 0, 0))
 			hbrushes[0,5] = CreateSolidBrush (RGB (140, 0, 0))
 			hbrushes[0,6] = CreateSolidBrush (RGB (110, 0, 0))
 			hbrushes[0,7] = CreateSolidBrush (RGB (80,  0, 0))
 			hbrushes[0,8] = CreateSolidBrush (RGB (50,  0, 0))
 			hbrushes[0,9] = CreateSolidBrush (RGB (20,  0, 0))

 			hbrushes[1,0] = CreateSolidBrush (RGB (0, 250, 0))
 			hbrushes[1,1] = CreateSolidBrush (RGB (0, 240, 0))
 			hbrushes[1,2] = CreateSolidBrush (RGB (0, 230, 0))
 			hbrushes[1,3] = CreateSolidBrush (RGB (0, 190, 0))
 			hbrushes[1,4] = CreateSolidBrush (RGB (0, 170, 0))
 			hbrushes[1,5] = CreateSolidBrush (RGB (0, 140, 0))
 			hbrushes[1,6] = CreateSolidBrush (RGB (0, 110, 0))
 			hbrushes[1,7] = CreateSolidBrush (RGB (0, 80,  0))
 			hbrushes[1,8] = CreateSolidBrush (RGB (0, 50,  0))
 			hbrushes[1,9] = CreateSolidBrush (RGB (0, 20,  0))

			hdc = GetDC (hWnd)

		CASE $$WM_SIZE:
			cxClient = LOWORD (lParam)
 			cyClient = HIWORD (lParam)

		CASE $$WM_DESTROY:
			FOR i = 0 TO 9
				DeleteObject (hbrushes[0, i])
				DeleteObject (hbrushes[1, i])
			NEXT i
			ReleaseDC (hWnd, hdc)
			PostQuitMessage(0)

		CASE ELSE
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

	SHARED className$

' register window class
	className$  = "LorenzDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Lorenz Attractors."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 640
	h 					= 540
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

	IF LIBRARY(0) THEN RETURN									' main program executes message loop

	DO																				' the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			IF msg.message = $$WM_QUIT THEN EXIT DO
			TranslateMessage (&msg)						' translate virtual-key messages into character messages
			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		ELSE
			DrawRectangle (#winMain)					' draw the two lorenz attractors
		END IF
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
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' ##############################
' #####  DrawRectangle ()  #####
' ##############################
'
FUNCTION  DrawRectangle (hWnd)

STATIC DOUBLE xa[], ya[], za[]
SHARED cxClient, cyClient
STATIC entry
STATIC DOUBLE dt, dx, dy, dz
DOUBLE x, y, z
STATIC DOUBLE c, b, a
SHARED hbrushes[]
SHARED hdc
STATIC hInvisible

	IFZ entry THEN GOSUB Initialize
	IF (cxClient = 0) || (cyClient = 0) THEN RETURN

	FOR loop = 0 TO 1

 		x = xa[loop]
 		y = ya[loop]
		z = za[loop]

		dx = a * (y-x) * dt
		dy = (b * x - y - z * x) * dt
		dz = (-c * z + x * y) * dt

		x = x + dx
		y = y + dy
		z = z + dz

		i1 = 10.0 * x + (cxClient/2.0)			' 20.0 *
		l1 = -8.0 * z + (cyClient)					' -15 *

		SelectObject (hdc, hInvisible)

		FOR ball = 9 TO 0 STEP -1
			SelectObject (hdc, hbrushes[loop, ball])
			Ellipse (hdc, i1-ball, l1-ball, i1+ball, l1+ball)
		NEXT ball

		xa[loop] = x
		ya[loop] = y
		za[loop] = z

	NEXT loop
	RETURN

' ***** Initialize *****
SUB Initialize
	entry = $$TRUE
	DIM xa[1]
	DIM ya[1]
	DIM za[1]

' set initial conditions
	xa[0] =  3.051522 : xa[1] =  3.05152200001
	ya[0] =  1.592542 : ya[1] =  1.59254200001
	za[0] = 15.623880 : za[1] =  15.6238800001

' set constant values
	dt = 0.02
	a  = 10				' 5
	b  = 28				' 15
	c  = 8/3.0		' 1

	hInvisible = GetStockObject ($$NULL_PEN)
END SUB


END FUNCTION
END PROGRAM
