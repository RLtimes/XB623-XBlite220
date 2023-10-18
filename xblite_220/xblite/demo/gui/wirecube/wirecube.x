'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This graphics demo draws 3D wire-frame cube and allows
' for its rotation and translation.
'
PROGRAM	"wirecube"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll
'
TYPE CUBE
	DOUBLE	.x[7]
	DOUBLE	.y[7]
	DOUBLE	.z[7]
END TYPE
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
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  DrawCube (hDC, CUBE cube, color, flength, camz, x0, y0)
DECLARE FUNCTION  InitCube (CUBE cube)
DECLARE FUNCTION  ConnectTo (hDC, DOUBLE x, DOUBLE y, DOUBLE z, color, flength, camz, x0, y0)
DECLARE FUNCTION  MoveTo (hDC, DOUBLE x, DOUBLE y, DOUBLE z, flength, camz, x0, y0)
DECLARE FUNCTION  RotateCube (CUBE cubeIn, CUBE cubeOut, DOUBLE angleX, DOUBLE angleY, DOUBLE angleZ)
DECLARE FUNCTION  RotateX (DOUBLE angle, DOUBLE y, DOUBLE z)
DECLARE FUNCTION  RotateY (DOUBLE angle, DOUBLE x, DOUBLE z)
DECLARE FUNCTION  RotateZ (DOUBLE angle, DOUBLE x, DOUBLE y)
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hMemDC)
'
' ***** Constants *****
'
$$DEGTORAD	= 0d3F91DF46A2529D39
'
'Control IDs
'
$$Button1  = 100
$$Button2  = 101
$$Button3  = 102
$$Button4  = 103
$$Button5  = 104
$$Button6  = 105
$$Button7  = 106
$$Button8  = 107
'
$$Static1 = 110
$$Static2 = 111
$$Static3 = 112
'
$$Edit1 = 120
$$Edit2 = 121
$$Edit3 = 122
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
	RECT rect
	PAINTSTRUCT ps
	STATIC CUBE cube, cube2
	STATIC x0, y0, flength, camz

	SELECT CASE msg

		CASE $$WM_CREATE :

			GetClientRect (hWnd, &rect)
			#hMemDC = CreateScreenBuffer (hWnd, rect.right, rect.bottom)

			InitCube (@cube)			' initialize cube coordinates
			x0 = 350							' set x origin
			y0 = 100							' set y origin
			flength =	260					' set camera focal length
			camz 		= -6					' set camera z position (must be <-1)

		CASE $$WM_DESTROY :
			DeleteScreenBuffer (#hMemDC)
			PostQuitMessage(0)

		CASE $$WM_PAINT :
			hDC = BeginPaint (hWnd, &ps)
			BitBlt (hDC, ps.left, ps.top, ps.right-ps.left, ps.bottom-ps.top, #hMemDC, ps.left, ps.top, $$SRCCOPY)
			EndPaint (hWnd, &ps)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 :	GOSUB DrawCube
						CASE $$Button2 :	anglex = 1 : angley = 0 : anglez = 0 : GOSUB RotateCube
						CASE $$Button3 :	anglex = 0 : angley = 1 : anglez = 0 : GOSUB RotateCube
						CASE $$Button4 :	anglex = 0 : angley = 0 : anglez = 1 : GOSUB RotateCube
						CASE $$Button5 :	GOSUB Clear
					END SELECT
			END SELECT

		CASE $$WM_CTLCOLORSTATIC :
			RETURN SetColor (0, RGB(192, 192, 192), wParam, lParam)	' set static control background color

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

' ***** GetInitData *****
SUB GetInitData
' get initial starting rotation angles from input text boxes

	anglex$ = NULL$(10)
	GetWindowTextA (#edit1, &anglex$, 10)
	anglex$ = CSIZE$(anglex$)
	angle_x0# = DOUBLE(anglex$)

	angley$ = NULL$(10)
	GetWindowTextA (#edit2, &angley$, 10)
	angley$ = CSIZE$(angley$)
	angle_y0# = DOUBLE(angley$)

	anglez$ = NULL$(10)
	GetWindowTextA (#edit3, &anglez$, 10)
	anglez$ = CSIZE$(anglez$)
	angle_z0# = DOUBLE(anglez$)


END SUB

' ***** DrawCube *****
SUB DrawCube
	GOSUB GetInitData
	GOSUB Clear
	RotateCube (cube, @cube2, angle_x0#, angle_y0#, angle_z0#)
	DrawCube (#hMemDC, cube2, RGB(255, 0, 0), flength, camz, x0, y0)
	InvalidateRect (hWnd, 0, 1)
END SUB


' ***** RotateCube *****
SUB RotateCube
	GOSUB GetInitData
	hDC = GetDC (hWnd)
	FOR i = 0 TO 360
		GetClientRect (hWnd, &rect)
		rect.left = 250
		PatBlt (#hMemDC, rect.left, 0, rect.right, rect.bottom, $$PATCOPY)
		SELECT CASE TRUE
			CASE anglex = 1 :
				angle_x# = angle_x0# + i
				angle_y# = angle_y0#
				angle_z# = angle_z0#
			CASE angley = 1 :
				angle_y# = angle_y0# + i
				angle_x# = angle_x0#
				angle_z# = angle_z0#
			CASE anglez = 1 :
				angle_z# = angle_z0# + i
				angle_x# = angle_x0#
				angle_y# = angle_y0#
		END SELECT

		RotateCube (cube, @cube2, angle_x#, angle_y#, angle_z#)
		DrawCube (#hMemDC, cube2, RGB(255, 0, 0), flength, camz, x0, y0)
		BitBlt (hDC, rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top, #hMemDC, rect.left, rect.top, $$SRCCOPY)
		Sleep(5)
	NEXT i
	ReleaseDC (hWnd, hDC)
END SUB

' ***** Clear *****
SUB Clear
	GetClientRect (hWnd, &rect)
	rect.left = 250
	PatBlt (#hMemDC, rect.left, 0, rect.right, rect.bottom, $$PATCOPY)
'	FillRect (#hMemDC, &rect, GetStockObject ($$LTGRAY_BRUSH))
	InvalidateRect (hWnd, 0, 1)

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
	className$  = "3d-demo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "3-D Wireframe Object Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 480
	h 					= 248
	exStyle			= 0
	#winMain		= NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create buttons
	#button1 = NewChild (@"button", @"Draw Object", 					$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  12, 220, 24, #winMain, $$Button1, 0)
	#button2 = NewChild (@"button", @"Rotate Around X-Axis",	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  36, 220, 24, #winMain, $$Button2, 0)
	#button3 = NewChild (@"button", @"Rotate Around Y-Axis", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  60, 220, 24, #winMain, $$Button3, 0)
	#button4 = NewChild (@"button", @"Rotate Around Z-Axis", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 10,  84, 220, 24, #winMain, $$Button4, 0)
	#button5 = NewChild (@"button", @"Clear Drawing Area", 		$$BS_PUSHBUTTON | $$WS_TABSTOP, 10, 108, 220, 24, #winMain, $$Button5, 0)
	#static1 = NewChild (@"static", @"  Init X Angle", 				$$SS_LEFT | $$SS_CENTERIMAGE	, 92, 132, 138, 24, #winMain, $$Static1, 0)
	#static2 = NewChild (@"static", @"  Init Y Angle", 				$$SS_LEFT | $$SS_CENTERIMAGE	, 92, 156, 138, 24, #winMain, $$Static2, 0)
	#static3 = NewChild (@"static", @"  Init Z Angle", 				$$SS_LEFT | $$SS_CENTERIMAGE	, 92, 180, 138, 24, #winMain, $$Static2, 0)
	#edit1   = NewChild (@"edit", @"0", 											$$ES_NUMBER | $$ES_AUTOHSCROLL, 10, 132,  80, 22, #winMain, $$Edit1, $$WS_EX_STATICEDGE)
	#edit2   = NewChild (@"edit", @"30", 											$$ES_NUMBER | $$ES_AUTOHSCROLL, 10, 156,  80, 22, #winMain, $$Edit2, $$WS_EX_STATICEDGE)
	#edit3   = NewChild (@"edit", @"0", 											$$ES_NUMBER | $$ES_AUTOHSCROLL, 10, 180,  80, 22, #winMain, $$Edit3, $$WS_EX_STATICEDGE)

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
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	IF hNewBrush THEN DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush (bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION
'
'
' #########################
' #####  DrawCube ()  #####
' #########################
'
FUNCTION  DrawCube (hDC, CUBE cube, color, flength, camz, x0, y0)

	MoveTo (hDC, cube.x[0], cube.y[0], cube.z[0], flength, camz, x0, y0)
	FOR i = 1 TO 7
		ConnectTo (hDC, cube.x[i], cube.y[i], cube.z[i], color, flength, camz, x0, y0)
	NEXT i

	ConnectTo (hDC, cube.x[2], cube.y[2], cube.z[2], color, flength, camz, x0, y0)

	MoveTo (hDC, cube.x[0], cube.y[0], cube.z[0], flength, camz, x0, y0)
	ConnectTo (hDC, cube.x[5], cube.y[5], cube.z[5], color, flength, camz, x0, y0)

	MoveTo (hDC, cube.x[1], cube.y[1], cube.z[1], flength, camz, x0, y0)
	ConnectTo (hDC, cube.x[6], cube.y[6], cube.z[6], color, flength, camz, x0, y0)

	MoveTo (hDC, cube.x[0], cube.y[0], cube.z[0], flength, camz, x0, y0)
	ConnectTo (hDC, cube.x[3], cube.y[3], cube.z[3], color, flength, camz, x0, y0)

	MoveTo (hDC, cube.x[4], cube.y[4], cube.z[4], flength, camz, x0, y0)
	ConnectTo (hDC, cube.x[7], cube.y[7], cube.z[7], color, flength, camz, x0, y0)


END FUNCTION
'
'
' #########################
' #####  InitCube ()  #####
' #########################
'
FUNCTION  InitCube (CUBE cube)

' initialize 8 cube vertice points
	cube.x[0] = 1
	cube.y[0] = 1
	cube.z[0] = 1

	cube.x[1] = 1
	cube.y[1] = 1
	cube.z[1] = -1

	cube.x[2] = -1
	cube.y[2] = 1
	cube.z[2] = -1

	cube.x[3] = -1
	cube.y[3] = 1
	cube.z[3] = 1

	cube.x[4] = -1
	cube.y[4] = -1
	cube.z[4] = 1

	cube.x[5] = 1
	cube.y[5] = -1
	cube.z[5] = 1

	cube.x[6] = 1
	cube.y[6] = -1
	cube.z[6] = -1

	cube.x[7] = -1
	cube.y[7] = -1
	cube.z[7] = -1


END FUNCTION
'
'
' ##########################
' #####  ConnectTo ()  #####
' ##########################
'
FUNCTION  ConnectTo (hDC, DOUBLE x, DOUBLE y, DOUBLE z, color, flength, camz, x0, y0)

	y = -y

' convert 3-d coordinates to 2-d screen coordinates
' flength is focal length
' camz is camera z distance (negative z is out of screen)
' camz should be < 0

	IFZ (z-camz) THEN RETURN

	tmp# 		= flength/(DOUBLE(z-camz))
	screenx = x*tmp#
	screeny = y*tmp#

	IF color THEN
		hPen = CreatePen ($$PS_SOLID, 1, color)
		hOldPen = SelectObject (hDC, hPen)
		LineTo (hDC, screenx+x0, screeny+y0)
		SelectObject (hDC, hOldPen)
		DeleteObject (hPen)
	ELSE
		LineTo (hDC, screenx+x0, screeny+y0)
	END IF

END FUNCTION
'
'
' #######################
' #####  MoveTo ()  #####
' #######################
'
FUNCTION  MoveTo (hDC, DOUBLE x, DOUBLE y, DOUBLE z, flength, camz, x0, y0)

	y = -y				' standard cartesion y direction is up

' convert 3-d coordinates to 2-d screen coordinates
' flength is focal length
' camz is camera z distance (negative z is out of screen)
' camz should be < 0

	IFZ (z-camz) THEN RETURN

	tmp# = flength/(DOUBLE(z-camz))
	screenx = x*tmp#
	screeny = y*tmp#

	MoveToEx (hDC, screenx+x0, screeny+y0, 0)

END FUNCTION
'
'
' ###########################
' #####  RotateCube ()  #####
' ###########################
'
FUNCTION  RotateCube (CUBE cubeIn, CUBE cubeOut, DOUBLE angleX, DOUBLE angleY, DOUBLE angleZ)

	CUBE cubeTemp

	cubeTemp = cubeIn

	FOR i = 0 TO 7

		IF angleX THEN
			y# = cubeTemp.y[i] : z# = cubeTemp.z[i]
			RotateX (angleX, @y#, @z#)
			cubeTemp.y[i] = y# : cubeTemp.z[i] = z#
		END IF

		IF angleY THEN
			x# = cubeTemp.x[i] : z# = cubeTemp.z[i]
			RotateY (angleY, @x#, @z#)
			cubeTemp.x[i] = x# : cubeTemp.z[i] = z#
		END IF

		IF angleZ THEN
			x# = cubeTemp.x[i] : y# = cubeTemp.y[i]
			RotateZ (angleZ, @x#, @y#)
			cubeTemp.x[i] = x# : cubeTemp.y[i] = y#
		END IF
	NEXT i

	cubeOut = cubeTemp


END FUNCTION
'
'
' ########################
' #####  RotateX ()  #####
' ########################
'
FUNCTION  RotateX (DOUBLE angle, DOUBLE y, DOUBLE z)

	DOUBLE ytemp
	angle = angle * $$DEGTORAD
	ytemp = y*cos(angle) - z*sin(angle)
	z 		= y*sin(angle) + z*cos(angle)
	y			= ytemp


END FUNCTION
'
'
' ########################
' #####  RotateY ()  #####
' ########################
'
FUNCTION  RotateY (DOUBLE angle, DOUBLE x, DOUBLE z)

	DOUBLE xtemp
	angle = angle * $$DEGTORAD
	xtemp	= x*cos(angle)  + z*sin(angle)
	z			= -x*sin(angle) + z*cos(angle)
	x			= xtemp


END FUNCTION
'
'
' ########################
' #####  RotateZ ()  #####
' ########################
'
FUNCTION  RotateZ (DOUBLE angle, DOUBLE x, DOUBLE y)

	DOUBLE xtemp
	angle = angle * $$DEGTORAD
	xtemp	= x*cos(angle) - y*sin(angle)
	y			= x*sin(angle) + y*cos(angle)
	x			= xtemp

END FUNCTION
'
'
' ###################################
' #####  CreateScreenBuffer ()  #####
' ###################################

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
END PROGRAM
