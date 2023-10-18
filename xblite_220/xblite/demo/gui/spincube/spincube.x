'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This graphics demo draws a solid moving cube.
' If the cube moves too fast, then adjust the timer
' value of $SpinInterval in function WndProc().
'
PROGRAM	"spincube"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
	IMPORT  "msvcrt"		' msvcrt.dll

TYPE FACET
	POINT	.v[3]		' vertice x, y in screen coords
	XLONG			.i[3]		' index number of 4-corners of vertices (0-7)
	XLONG			.color	' facet color
END TYPE

TYPE CUBE
	DOUBLE	.x[7]
	DOUBLE	.y[7]
	DOUBLE	.z[7]
	FACET		.f[5]
END TYPE

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  DrawCube (hDC, CUBE cube)
DECLARE FUNCTION  InitCube (CUBE cube)
DECLARE FUNCTION  RotateCube (CUBE cubeIn, CUBE cubeOut, DOUBLE angleX, DOUBLE angleY, DOUBLE angleZ)
DECLARE FUNCTION  RotateX (DOUBLE angle, DOUBLE y, DOUBLE z)
DECLARE FUNCTION  RotateY (DOUBLE angle, DOUBLE x, DOUBLE z)
DECLARE FUNCTION  RotateZ (DOUBLE angle, DOUBLE x, DOUBLE y)
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hMemDC)
DECLARE FUNCTION  TranslateCube (CUBE cube, flength, camz, x0, y0, RECT boundary)

' ***** Constants *****

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

	SHARED hInst
	RECT rect
	PAINTSTRUCT ps
	STATIC CUBE cube, cube2
	STATIC x0, y0, flength, camz
	STATIC fMoving
	STATIC RECT bounds
	STATIC angle_x0#, angle_y0#, angle_z0#
	STATIC XRotationInc, YRotationInc, ZRotationInc
	STATIC XTranslationInc, YTranslationInc, ZTranslationInc
	STATIC hdc

	$SpinInterval = 15

	SELECT CASE msg

		CASE $$WM_CREATE :

			GetClientRect (hWnd, &rect)
			#hMemDC = CreateScreenBuffer (hWnd, rect.right, rect.bottom)

			InitCube (@cube)								' initialize cube coordinates
			GOSUB InitCubeMotionData				' initialize cube motion data

			flength =	300										' set camera focal length
			camz 		= -10										' set camera z position (must be <-1)

			SetTimer (hWnd, 1, $SpinInterval, 0)	' start timer
			fMoving = $$TRUE											'	set cube motion flag on

			GOSUB InitBounds								' initialize validation bounds RECT
			hdc = GetDC (hWnd)

		CASE $$WM_DESTROY :
			IF fMoving THEN KillTimer (hWnd, 1)
			DeleteScreenBuffer (#hMemDC)
			ReleaseDC (hWnd, hdc)
			PostQuitMessage(0)

		CASE $$WM_LBUTTONDOWN :
			IF fMoving THEN							' toggle cube motion on/off with left mouse button
				fMoving = $$FALSE
				KillTimer (hWnd, 1)
			ELSE
				SetTimer (hWnd, 1, $SpinInterval, 0)
				fMoving = $$TRUE
			END IF

		CASE $$WM_PAINT :
			hDC = BeginPaint (hWnd, &ps)
			BitBlt (hDC, ps.left, ps.top, ps.right-ps.left, ps.bottom-ps.top, #hMemDC, ps.left, ps.top, $$SRCCOPY)
			EndPaint (hWnd, &ps)

		CASE $$WM_TIMER:
' clear last drawn object
	    FillRect (#hMemDC, &bounds, GetStockObject ($$BLACK_BRUSH))
	    InvalidateRect (hWnd, &bounds, 0)

' increment x/y positions
			x0 = x0 + XTranslationInc
			y0 = y0 + YTranslationInc

' increment rotation angles
			angle_x0# = angle_x0# + XRotationInc
			angle_y0# = angle_y0# + YRotationInc
			angle_z0# = angle_z0# + ZRotationInc

			RotateCube (cube, @cube2, angle_x0#, angle_y0#, angle_z0#)	' rotate cube
			TranslateCube (@cube2, flength, camz, x0, y0, @bounds)			' compute new 2-d coords
			GOSUB CheckBounds																						' check to see if cube has hit a window border
			DrawCube (#hMemDC, cube2)																		' draw cube
			BitBlt (hdc, bounds.left, bounds.top, bounds.right-bounds.left, bounds.bottom-bounds.top, #hMemDC, bounds.left, bounds.top, $$SRCCOPY)		' paint memory image onto screen

		CASE $$WM_SIZE :
			sizeType 	= wParam
			width 		= LOWORD(lParam)
			height 		= HIWORD(lParam)

			IF (sizeType = $$SIZE_MAXIMIZED) || (sizeType = $$SIZE_RESTORED) THEN
' delete old memory bitmap and create a new one with the size of current window
				DeleteScreenBuffer (#hMemDC)
				#hMemDC = CreateScreenBuffer (hWnd, width, height)

' reset initial position, parameters of cube
				GOSUB InitCubeMotionData

' reset validation bounds
				IF sizeType = $$SIZE_RESTORED THEN
					GOSUB InitBounds
				END IF

' redraw window
				InvalidateRect (hWnd, 0, 0)
			END IF

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** InitCubeMotionData *****
SUB InitCubeMotionData

	GetClientRect (hWnd, &rect)
	x0 = rect.right >> 1						' set x origin
	y0 = rect.bottom >> 1						' set y origin

	angle_x0# = 30									' set initial rotation angles
	angle_y0# = 60
	angle_z0# = 0

	seed = (GetTickCount () MOD 32767) + 1
	srand (seed)

	XRotationInc		= (rand() MOD 4) + 1
	YRotationInc		= (rand() MOD 4) + 1
	ZRotationInc		= (rand() MOD 4) + 1

	XTranslationInc = (rand() MOD 6) + 2
	IF XTranslationInc > 5 THEN
		XTranslationInc = -XTranslationInc
	END IF
	YTranslationInc = (rand() MOD 6) + 2
	IF YTranslationInc > 5 THEN
		YTranslationInc = -YTranslationInc
	END IF

END SUB

' ***** CheckBounds *****
SUB CheckBounds
' change direction of cube when it hits a boundary wall

	GetClientRect (hWnd, &rect)

	SELECT CASE TRUE
' bounce cube in new direction with new speed, rotation
		CASE bounds.left < rect.left :
			XTranslationInc = (rand() MOD 6) + 2
			ZRotationInc 		= (rand() MOD 4) + 1
			YRotationInc 		= (rand() MOD 4) + 1
			bounds.left 		= rect.left
		CASE bounds.right > rect.right :
			XTranslationInc = -((rand() MOD 6) + 2)
			ZRotationInc 		= -((rand() MOD 4) + 1)
			YRotationInc 		= (rand() MOD 4) + 1
			bounds.right 		= rect.right
		CASE bounds.top < rect.top :
			YTranslationInc = (rand() MOD 6) + 2
			XRotationInc 		= (rand() MOD 4) + 1
			YRotationInc 		= (rand() MOD 4) + 1
			bounds.top 			= rect.top
		CASE bounds.bottom > rect.bottom :
			YTranslationInc = -((rand() MOD 6) + 2)
			XRotationInc 		= -((rand() MOD 4) + 1)
			YRotationInc 		= (rand() MOD 4) + 1
			bounds.bottom 	= rect.bottom

	END SELECT
END SUB

' ***** InitBounds *****
SUB InitBounds
	GetClientRect (hWnd, &rect)
	bounds.left 	= 0
	bounds.right 	= rect.right
	bounds.top 		= 0
	bounds.bottom = rect.bottom
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
	className$  = "SolidCubeDemo"
	addrWndProc = &WndProc()
	icon$ 			= "spincube"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Solid Cube Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 360
	h 					= 360
	exStyle			= 0
	#winMain		= NewWindow (className$, title$, style, x, y, w, h, exStyle)
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
' #####  DrawCube ()  #####
' #########################
'
FUNCTION  DrawCube (hDC, CUBE cube)

	POINT poly[]

	DIM poly[3]

' set up various faces of cube and then draw exposed faces

	FOR f = 0 TO 5

		index1 = cube.f[f].i[0]
		index2 = cube.f[f].i[1]
		index3 = cube.f[f].i[2]

		vector1x = cube.f[f].v[1].x - cube.f[f].v[0].x
		vector1y = cube.f[f].v[1].y - cube.f[f].v[0].y

		vector2x = cube.f[f].v[2].x - cube.f[f].v[1].x
		vector2y = cube.f[f].v[2].y - cube.f[f].v[1].y

' calc z normal vector of each face
' N = U X V where U = vector1, V = vector2

		normalz = vector1x * vector2y - vector1y * vector2x

' only draw faces whose z normal is < 0

		IF normalz < 0 THEN
			FOR j = 0 TO 3
				poly[j] = cube.f[f].v[j]
			NEXT j
			hBrush = CreateSolidBrush (cube.f[f].color)
			hOldBrush = SelectObject (hDC, hBrush)
			Polygon (hDC, &poly[0], 4)
			SelectObject (hDC, hOldBrush)
			DeleteObject (hBrush)
		END IF
	NEXT f


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

'	DIM facets[5]

' order of vertices is based on right hand rule

' side 1
	cube.f[0].i[0] = 0
	cube.f[0].i[1] = 3
	cube.f[0].i[2] = 2
	cube.f[0].i[3] = 1

' side 2
	cube.f[1].i[0] = 4
	cube.f[1].i[1] = 5
	cube.f[1].i[2] = 6
	cube.f[1].i[3] = 7

' side 3
	cube.f[2].i[0] = 1
	cube.f[2].i[1] = 2
	cube.f[2].i[2] = 7
	cube.f[2].i[3] = 6

' side 4
	cube.f[3].i[0] = 2
	cube.f[3].i[1] = 3
	cube.f[3].i[2] = 4
	cube.f[3].i[3] = 7

' side 5
	cube.f[4].i[0] = 0
	cube.f[4].i[1] = 5
	cube.f[4].i[2] = 4
	cube.f[4].i[3] = 3

' side 6
	cube.f[5].i[0] = 0
	cube.f[5].i[1] = 1
	cube.f[5].i[2] = 6
	cube.f[5].i[3] = 5

' initialize facet colors
	cube.f[0].color = RGB(0xFF, 0, 0)
	cube.f[1].color = RGB(0, 0xFF, 0)
	cube.f[2].color = RGB(0, 0, 0xFF)
	cube.f[3].color = RGB(0xFF, 0xFF, 0)
	cube.f[4].color = RGB(0xFF, 0, 0xFF)
	cube.f[5].color = RGB(0, 0xFF, 0xFF)


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

	RECT rect

	hDC 		= GetDC (hWnd)
	memDC 	= CreateCompatibleDC (hDC)
	hBit 		= CreateCompatibleBitmap (hDC, w, h)
	SelectObject (memDC, hBit)
	hBrush 	= GetStockObject ($$BLACK_BRUSH)
	SelectObject (memDC, hBrush)
	GetClientRect (hWnd, &rect)
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
' ##############################
' #####  TranslateCube ()  #####
' ##############################
'
FUNCTION  TranslateCube (CUBE cube, flength, camz, x0, y0, RECT boundary)

	POINT screen[7], poly[]
	DOUBLE x, y, z

	DIM poly[3]

	boundary.right 	= 0
	boundary.bottom = 0
	boundary.top 		= 2048
	boundary.left 	= 2048

' convert 3-d cube vertices to 2-d screen vertices

	FOR i = 0 TO 7
		x = cube.x[i]
		y = -cube.y[i]
		z = cube.z[i]

' convert 3-d coordinates to 2-d screen coordinates
' flength is focal length
' camz is camera z distance (negative z is out of screen)
' camz should be < 0

		IFZ (z-camz) THEN RETURN ($$TRUE)

		tmp# 		= flength/(DOUBLE(z-camz))
		screen[i].x = x0 + x*tmp#
		screen[i].y = y0 + y*tmp#
		boundary.right 	= MAX (boundary.right, 	screen[i].x)
		boundary.bottom = MAX (boundary.bottom, screen[i].y)
		boundary.left 	= MIN (boundary.left, 	screen[i].x)
		boundary.top 		= MIN (boundary.top, 		screen[i].y)
	NEXT i

' set up various faces of cube
	FOR f = 0 TO 5
		FOR i = 0 TO 3
			index = cube.f[f].i[i]
			cube.f[f].v[i] = screen[index]
		NEXT i
	NEXT f

END FUNCTION
END PROGRAM
