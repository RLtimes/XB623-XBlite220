'
'
' ####################
' #####  PROLOG  #####
' ####################

' An OpenGL demo program which draws
' a 3D pryamid shape recursively.
'
PROGRAM	"snowflake"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "opengl32"
	IMPORT	"msvcrt"
	IMPORT  "glu32"

TYPE DTRIANGLE
	SINGLE	.x1
	SINGLE	.y1
	SINGLE	.z1
	SINGLE	.x2
	SINGLE	.y2
	SINGLE	.z2
	SINGLE	.x3
	SINGLE	.y3
	SINGLE	.z3
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  SetWindowPixelFormat (hWnd)
DECLARE FUNCTION  CreateRenderingContext (hWnd, @hRC)
DECLARE FUNCTION  KeyboardHandler ()
DECLARE FUNCTION  DrawGLScene ()
DECLARE FUNCTION  ShutDown (hWnd)
DECLARE FUNCTION  Error (hWnd, title$, text$)
DECLARE FUNCTION  InitGL ()
DECLARE FUNCTION  Draw3DSnowFlake ()
DECLARE FUNCTION  DrawTriangle (DTRIANGLE tri, SINGLE height, token)
DECLARE FUNCTION  CalcNormal (DTRIANGLE tri, SINGLE x, SINGLE y, SINGLE z)
DECLARE FUNCTION  ReSizeGLScene (width, height)
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

	RECT rect
	SHARED hrc
	SHARED hdc
	SHARED hasfocus
	SHARED fullscreen
	SHARED keys[]

	SELECT CASE msg

		CASE $$WM_CREATE:
			hdc = GetDC (hWnd)
			IFZ SetWindowPixelFormat (hWnd) THEN Error (hWnd, "Error", "Can't Set PixelFormat.")
			IFZ CreateRenderingContext (hWnd, @hrc) THEN Error (hWnd, "Error", "Can't Create A GL Rendering Context.")
			InitGL ()
			wglMakeCurrent (hdc, hrc)
			hasfocus = $$TRUE

		CASE $$WM_SIZE:
			GetClientRect (hWnd, &rect)
			ReSizeGLScene (rect.right, rect.bottom)

		CASE $$WM_KEYDOWN:
			keys [wParam] = $$TRUE

		CASE $$WM_KEYUP:
			keys [wParam] = $$FALSE

		CASE $$WM_KILLFOCUS:
			hasfocus  = $$FALSE

		CASE $$WM_SETFOCUS:
			hasfocus = $$TRUE

		CASE $$WM_SETCURSOR:
			IF fullscreen THEN
				SetCursor (NULL)
				RETURN
			END IF

		CASE $$WM_DESTROY:
			ShutDown (hWnd)
			PostQuitMessage (0)

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

	SHARED fullscreen
	DEVMODE dmScreenSettings
	SHARED className$

	text$ = text$ + "Up/Down		: Rotate around Y axis.\n"
	text$ = text$ + "Left/Right	: Rotate around X axis.\n"
	text$ = text$ + "Space		: Stop rotation.\n"
	text$ = text$ + "1/2		: Alter recursion depth.\n"
	text$ = text$ + "A/Z		: Alter Z position.\n"
	text$ = text$ + "X/C		: Alter X position.\n"
	text$ = text$ + "S/D		: Alter Y position.\n"

	MessageBoxA (NULL, &text$, &"Interesting keys to try", $$MB_OK | $$MB_ICONINFORMATION)
'	MessageBoxA (NULL, &"Up, Down, Left, Right, Space, 1, 2, A, Z, X, C, S, D", &"Interesting keys to try", $$MB_OK | $$MB_ICONINFORMATION)

' register window class
	className$  = "OpenGLSnowFlake"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "OpenGL Snowflake demo."
'	fullscreen = $$TRUE

	IF (!fullscreen) THEN
' OpenGL requires the window to have styles WS_CLIPCHILDREN and WS_CLIPSIBLINGS set
		style 			= $$WS_OVERLAPPEDWINDOW | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS
		w 					= 640
		h 					= 480
		#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
		XstCenterWindow (#winMain)

	ELSE

		style 			= $$WS_POPUP | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS
		w 					= 640
		h 					= 480
		#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)

		dmScreenSettings.dmSize = SIZE(DEVMODE)
		dmScreenSettings.dmPelsWidth = w
		dmScreenSettings.dmPelsHeight = h
		dmScreenSettings.dmFields = $$DM_PELSWIDTH | $$DM_PELSHEIGHT
		ChangeDisplaySettingsA (&dmScreenSettings, $$CDS_FULLSCREEN)

	END IF

	IFZ #winMain THEN RETURN ($$TRUE)

	ShowWindow (#winMain, $$SW_SHOWNORMAL)
	UpdateWindow (#winMain)
	SetFocus (#winMain)

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
	SHARED hasfocus, hdc
	STATIC entry

	IF LIBRARY(0) THEN RETURN											' main program executes message loop

	DO																						' the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			IF msg.message = $$WM_QUIT THEN EXIT DO		' exit
			TranslateMessage (&msg)										' translate virtual-key messages into character messages
			DispatchMessageA (&msg)										' send message to window callback function WndProc()
		ELSE
			IF (hasfocus) THEN
				KeyboardHandler()
				DrawGLScene ()
				wglSwapBuffers (hdc)
			ELSE
'				Sleep (0)
			END IF
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
	UnregisterClassA(&className$, hInst)

END FUNCTION
'
'
' #####################################
' #####  SetWindowPixelFormat ()  #####
' #####################################
'
' The first set to creating an OpenGL rendering context is to
' define the window's pixel format. The pixel format describes
' how the graphics that the window displays are represented
' in memory. Parameters controlled by the pixel format include
' color depth, buffering method, and supported drawing interfaces.
'
FUNCTION  SetWindowPixelFormat (hWnd)

	PIXELFORMATDESCRIPTOR pixelDesc

	pixelDesc.nSize = SIZE(PIXELFORMATDESCRIPTOR)
	pixelDesc.nVersion = 1
	pixelDesc.dwFlags = $$PFD_DRAW_TO_WINDOW | $$PFD_SUPPORT_OPENGL | $$PFD_DOUBLEBUFFER | $$PFD_STEREO_DONTCARE
	pixelDesc.iPixelType = $$PFD_TYPE_RGBA
	pixelDesc.cColorBits = 32
	pixelDesc.cRedBits = 8
	pixelDesc.cRedShift = 16
	pixelDesc.cGreenBits = 8
	pixelDesc.cGreenShift = 8
	pixelDesc.cBlueBits = 8
	pixelDesc.cBlueShift = 0
	pixelDesc.cAlphaBits = 0
	pixelDesc.cAlphaShift = 0
	pixelDesc.cAccumBits = 64
	pixelDesc.cAccumRedBits = 16
	pixelDesc.cAccumGreenBits = 16
	pixelDesc.cAccumBlueBits = 16
	pixelDesc.cAccumAlphaBits = 0
	pixelDesc.cDepthBits = 32
	pixelDesc.cStencilBits = 8
	pixelDesc.cAuxBuffers = 0
	pixelDesc.iLayerType = $$PFD_MAIN_PLANE
	pixelDesc.bReserved = 0
	pixelDesc.dwLayerMask = 0
	pixelDesc.dwVisibleMask = 0
	pixelDesc.dwDamageMask = 0

	hDC = GetDC (hWnd)
	pixelFormat = ChoosePixelFormat (hDC, &pixelDesc)

	IFZ pixelFormat THEN 					' choose a default index.
		pixelFormat = 1
		IFZ DescribePixelFormat (hDC, pixelFormat, SIZE(PIXELFORMATDESCRIPTOR), &pixelDesc) THEN
			ReleaseDC (hWnd, hDC)
			RETURN $$FALSE
		END IF
	END IF

	IFZ SetPixelFormat (hDC, pixelFormat, &pixelDesc) THEN
		ReleaseDC (hWnd, hDC)
		RETURN $$FALSE
	END IF

	ReleaseDC (hWnd, hDC)
	RETURN $$TRUE

END FUNCTION
'
'
' #######################################
' #####  CreateRenderingContext ()  #####
' #######################################
'
' Create the OpenGL rendering context and make it current
'
FUNCTION  CreateRenderingContext (hWnd, @hRC)

	hDC = GetDC (hWnd)
	hRC = wglCreateContext (hDC)
	IF hRC == NULL THEN
		ReleaseDC (hWnd, hDC)
		RETURN $$FALSE
	END IF

	IFZ wglMakeCurrent (hDC, hRC) THEN
		ReleaseDC (hWnd, hDC)
		RETURN $$FALSE
	END IF

	ReleaseDC (hWnd, hDC)
	RETURN $$TRUE

END FUNCTION
'
'
' ################################
' #####  KeyboardHandler ()  #####
' ################################
'
FUNCTION  KeyboardHandler ()

	SHARED keys[]
	SHARED DEPTH_TOKENS
	SHARED world_list
	SHARED SINGLE xrot, yrot, zrot
	SHARED SINGLE xpos, ypos, zpos
	SHARED zrotting

	SELECT CASE TRUE

		CASE keys[$$VK_ESCAPE] :
			DestroyWindow (#winMain)

		CASE keys['1'] :
			keys[$$VK_ADD] = $$FALSE
			IF (DEPTH_TOKENS < 10) THEN
				INC DEPTH_TOKENS
			END IF
			glDeleteLists (world_list, 1)
			glNewList (world_list, $$GL_COMPILE)
			Draw3DSnowFlake ()
			glEndList ()

		CASE keys['2'] :
			keys[$$VK_SUBTRACT] = $$FALSE
			IF (DEPTH_TOKENS > 0) THEN
				DEC DEPTH_TOKENS
			END IF
			glDeleteLists (world_list, 1)
			glNewList (world_list, $$GL_COMPILE)
			Draw3DSnowFlake()
			glEndList()

		CASE keys[$$VK_UP] :
			yrot = yrot + 1.0

		CASE keys[$$VK_DOWN] :
			yrot = yrot - 1.0

		CASE keys[$$VK_RIGHT] :
			xrot = xrot + 1.0

		CASE keys[$$VK_LEFT] :
			xrot = xrot - 1.0

		CASE keys[$$VK_SPACE] :
			keys[$$VK_SPACE] = $$FALSE
			IF zrotting THEN
				zrotting = $$FALSE
			ELSE
				zrotting = $$TRUE
			END IF

		CASE keys['A'] :
			zpos = zpos + 0.1

		CASE keys['Z'] :
			zpos = zpos - 0.1

		CASE keys['X'] :
			xpos = xpos + 0.1

		CASE keys['C'] :
			xpos = xpos - 0.1

		CASE keys['S'] :
			ypos = ypos + 0.1

		CASE keys['D'] :
			ypos = ypos - 0.1

	END SELECT


END FUNCTION
'
'
' ############################
' #####  DrawGLScene ()  #####
' ############################
'
FUNCTION  DrawGLScene ()

	SHARED SINGLE xpos, ypos, zpos
	SHARED SINGLE xrot, yrot, zrot
	SHARED zrotting
	SHARED world_list

	SINGLE LightPosition[3]

	LightPosition[0] = 5.0
	LightPosition[1] = 5.0
	LightPosition[2] = 15.0
	LightPosition[3] = 0.0

	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)
	glLoadIdentity ()

	glLightfv ($$GL_LIGHT1, $$GL_POSITION, &LightPosition[])

	glTranslatef (xpos, ypos, zpos)
	glRotatef (yrot, 1, 0, 0)
	glRotatef (zrot, 0, 0, 1)
	glRotatef (xrot, 0, 1, 0)

	IF (zrotting) THEN zrot = zrot + 1.0

	glCallList (world_list)


END FUNCTION
'
'
' #########################
' #####  ShutDown ()  #####
' #########################
'
FUNCTION  ShutDown (hWnd)

	SHARED hdc, hrc

	ChangeDisplaySettingsA (NULL, 0)
	wglMakeCurrent (hdc, NULL)
	wglDeleteContext (hrc)
	ReleaseDC (hWnd, hdc)

END FUNCTION
'
'
' ######################
' #####  Error ()  #####
' ######################
'
FUNCTION  Error (hWnd, title$, text$)

	MessageBoxA (hWnd, &text$, &title$, $$MB_ICONEXCLAMATION)
	DestroyWindow (hWnd)

END FUNCTION
'
'
' #######################
' #####  InitGL ()  #####
' #######################
'
FUNCTION  InitGL ()

	SHARED SINGLE LightAmbient [3]
	SHARED SINGLE LightDiffuse [3]
	SHARED world_list
	SHARED keys[]
	SHARED DEPTH_TOKENS
	SHARED SINGLE SCALE_FACTOR
	SHARED SINGLE xpos, ypos, zpos
	SHARED zrotting
	SHARED hdc

	DIM keys[255]
	DEPTH_TOKENS = 5
	SCALE_FACTOR = (1.0 - (1.6/SINGLE(DEPTH_TOKENS)))

	xpos = 0.0
	ypos = 0.0
	zpos = -2.6

	zrotting = $$TRUE

	LightAmbient[0] =	0.1
	LightAmbient[1] =	0.1
	LightAmbient[2] =	0.1
	LightAmbient[3] =	0.1

	LightDiffuse[0] = 0.7
	LightDiffuse[1] = 0.7
	LightDiffuse[2] = 0.7
	LightDiffuse[3] = 0.7

	glClearColor (0.0, 0.0, 0.0, 0.0)
	glClearDepth (1.0)
	glDepthFunc ($$GL_LESS)
	glEnable ($$GL_DEPTH_TEST)
	glShadeModel ($$GL_SMOOTH)
	glEnable ($$GL_TEXTURE_2D)

	glEnable ($$GL_LIGHTING)
	glLightfv ($$GL_LIGHT1, $$GL_AMBIENT, &LightAmbient[])
	glLightfv ($$GL_LIGHT1, $$GL_DIFFUSE, &LightDiffuse[])
	glEnable ($$GL_LIGHT1)

	glColorMaterial ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE)
	glEnable ($$GL_COLOR_MATERIAL)

	world_list = glGenLists (1)
	glNewList (world_list, $$GL_COMPILE)
	Draw3DSnowFlake ()
	glEndList ()

END FUNCTION
'
'
' ################################
' #####  Draw3DSnowFlake ()  #####
' ################################
'
FUNCTION  Draw3DSnowFlake ()

	SHARED SINGLE SCALE_FACTOR
	DTRIANGLE tri1, tri2, tri3, tri4

	glBegin ($$GL_TRIANGLES)
	tri1.x1 = -0.5
	tri1.y1 = -0.5
	tri1.z1 = -0.5
	tri1.x2 = -0.5
	tri1.y2 = -0.5
	tri1.z2 = 0.5
	tri1.x3 = 0.0
	tri1.y3 = 0.5
	tri1.z3 = 0.0
	DrawTriangle (tri1, SCALE_FACTOR, 0)

	tri2.x1 = -0.5
	tri2.y1 = -0.5
	tri2.z1 = 0.5
	tri2.x2 = 0.5
	tri2.y2 = -0.5
	tri2.z2 = 0.0
	tri2.x3 = 0.0
	tri2.y3 = 0.5
	tri2.z3 = 0.0
	DrawTriangle (tri2, SCALE_FACTOR, 0)

	tri3.x1 = 0.5
	tri3.y1 = -0.5
	tri3.z1 = 0.0
	tri3.x2 = -0.5
	tri3.y2 = -0.5
	tri3.z2 = -0.5
	tri3.x3 = 0.0
	tri3.y3 = 0.5
	tri3.z3 = 0.0
	DrawTriangle (tri3, SCALE_FACTOR, 0)

	tri4.x1 = 0.5
	tri4.y1 = -0.5
	tri4.z1 = 0.0
	tri4.x2 = -0.5
	tri4.y2 = -0.5
	tri4.z2 = 0.5
	tri4.x3 = -0.5
	tri4.y3 = -0.5
	tri4.z3 = -0.5
	DrawTriangle (tri4, SCALE_FACTOR, 0)
	glEnd()

END FUNCTION
'
'
' #############################
' #####  DrawTriangle ()  #####
' #############################
'
FUNCTION  DrawTriangle (DTRIANGLE tri, SINGLE height, token)

	SINGLE cx, cy, cz
	SINGLE tx, ty, tz
	SINGLE u, v, n
	SINGLE a, b, c
	SHARED SINGLE SCALE_FACTOR
	SHARED DEPTH_TOKENS
	DTRIANGLE tri1, tri2, tri3
	STATIC ULONG count

	IF (token > DEPTH_TOKENS) THEN RETURN

	cx = (tri.x1 + tri.x2 + tri.x3) / 3.0
	cy = (tri.y1 + tri.y2 + tri.y3) / 3.0
	cz = (tri.z1 + tri.z2 + tri.z3) / 3.0

	CalcNormal (tri, @tx, @ty, @tz)

	tx = tx * height + cx
	ty = ty * height + cy
	tz = tz * height + cz

	glNormal3f (tx, ty, tz)
	glColor4f (0.3, 0.1, .9, 1.0)
	glVertex3f (tri.x1, tri.y1, tri.z1)
	glColor4f (0.3, 0.1, .9, 1.0)
	glVertex3f (tri.x2, tri.y2, tri.z2)
	glColor4f (1.0, 1.0, 1.0, 1.0)
	glVertex3f (tri.x3, tri.y3, tri.z3)

	tri1.x1 = ((tri.x1 - cx) * SCALE_FACTOR) + cx
	tri1.y1 = ((tri.y1 - cy) * SCALE_FACTOR) + cy
	tri1.z1 = ((tri.z1 - cz) * SCALE_FACTOR) + cz
	tri1.x2 = ((tri.x2 - cx) * SCALE_FACTOR) + cx
	tri1.y2 = ((tri.y2 - cy) * SCALE_FACTOR) + cy
	tri1.z2 = ((tri.z2 - cz) * SCALE_FACTOR) + cz
	tri1.x3 = tx
	tri1.y3 = ty
	tri1.z3 = tz
	DrawTriangle (tri1, height * SCALE_FACTOR, token+1)

	tri2.x1 = ((tri.x2 - cx) * SCALE_FACTOR) + cx
	tri2.y1 = ((tri.y2 - cy) * SCALE_FACTOR) + cy
	tri2.z1 = ((tri.z2 - cz) * SCALE_FACTOR) + cz
	tri2.x2 = ((tri.x3 - cx) * SCALE_FACTOR) + cx
	tri2.y2 = ((tri.y3 - cy) * SCALE_FACTOR) + cy
	tri2.z2 = ((tri.z3 - cz) * SCALE_FACTOR) + cz
	tri2.x3 = tx
	tri2.y3 = ty
	tri2.z3 = tz
	DrawTriangle (tri2, height * SCALE_FACTOR, token+1)

	tri3.x1 = ((tri.x3 - cx) * SCALE_FACTOR) + cx
	tri3.y1 = ((tri.y3 - cy) * SCALE_FACTOR) + cy
	tri3.z1 = ((tri.z3 - cz) * SCALE_FACTOR) + cz
	tri3.x2 = ((tri.x1 - cx) * SCALE_FACTOR) + cx
	tri3.y2 = ((tri.y1 - cy) * SCALE_FACTOR) + cy
	tri3.z2 = ((tri.z1 - cz) * SCALE_FACTOR) + cz
	tri3.x3 = tx
	tri3.y3 = ty
	tri3.z3 = tz
	DrawTriangle (tri3, height * SCALE_FACTOR, token+1)

END FUNCTION
'
'
' ###########################
' #####  CalcNormal ()  #####
' ###########################
'
FUNCTION  CalcNormal (DTRIANGLE tri, SINGLE x, SINGLE y, SINGLE z)

	SINGLE a, b, c
	SINGLE u, v, w

	a = (tri.x2 - tri.x1) :	u = (tri.x3 - tri.x1)
	b = (tri.y2 - tri.y1) : v = (tri.y3 - tri.y1)
	c = (tri.z2 - tri.z1) : w = (tri.z3 - tri.z1)

	x = b*w - c*v
	y = c*u - a*w
	z = a*v - b*u

	a = 1.0 / sqrt( (x * x) + (y * y) + (z * z) )
	x = x * a
	y = y * a
	z = z * a

END FUNCTION
'
'
' ##############################
' #####  ReSizeGLScene ()  #####
' ##############################
'
FUNCTION  ReSizeGLScene (width, height)

	IF (height==0) THEN height = 1

	glViewport (0, 0, width, height)
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity()

	gluPerspective (45.0, SINGLE(width)/SINGLE(height), 1.0, 20.0)
'	gluPerspective (64.0, SINGLE(width)/SINGLE(height), 0.0001, 20.0)
	glMatrixMode ($$GL_MODELVIEW)

END FUNCTION
END PROGRAM
