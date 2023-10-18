'
'
' ####################
' #####  PROLOG  #####
' ####################

' A Win32 SDK OpenGL example.
'
PROGRAM	"auxdemo"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "opengl32"
	IMPORT  "glu32"
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
DECLARE FUNCTION  DeleteRC (hRC)
DECLARE FUNCTION  InitializeGL (DOUBLE width, DOUBLE height)
DECLARE FUNCTION  CreateObjects ()
DECLARE FUNCTION  Resize (DOUBLE width, DOUBLE height)
DECLARE FUNCTION  PolarView (DOUBLE radius, DOUBLE twist, DOUBLE latitude, DOUBLE longitude)
DECLARE FUNCTION  DrawScene ()

$$BLACK_INDEX     = 0
$$RED_INDEX       = 13
$$GREEN_INDEX     = 14
$$BLUE_INDEX      = 16
$$WIDTH           = 300
$$HEIGHT          = 340

$$GLOBE    = 1
$$CYLINDER = 2
$$CONE     = 3
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

'	XioCreateConsole (title$, 50) ' create console, if console is not wanted, comment out this line
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

	PAINTSTRUCT ps
	RECT rect
	SHARED hRC, hDC
	SHARED SINGLE latinc, longinc

	SELECT CASE msg

		CASE $$WM_CREATE:
			hDC = GetDC (hWnd)
			IFZ SetWindowPixelFormat (hWnd) THEN PostQuitMessage (0)
			IFZ CreateRenderingContext (hWnd, @hRC) THEN
				DeleteRC (hRC)
				ReleaseDC (hWnd, hDC)
 				PostQuitMessage (0)
			END IF
			GetClientRect (hWnd, &rect)
			InitializeGL (rect.right, rect.bottom)

'		CASE $$WM_PAINT:
'			hdc = BeginPaint (hWnd, &ps)
'			EndPaint (hWnd, &ps)

		CASE $$WM_SIZE:
			GetClientRect (hWnd, &rect)
			Resize (rect.right, rect.bottom)

		CASE $$WM_CLOSE:
			DeleteRC (hRC)
			ReleaseDC (hWnd, hDC)
			DestroyWindow (hWnd)

		CASE $$WM_DESTROY:
			DeleteRC (hRC)
			ReleaseDC (hWnd, hDC)
			PostQuitMessage(0)

		CASE $$WM_KEYDOWN:
			SELECT CASE wParam
				CASE $$VK_LEFT:
					longinc = longinc + 0.5

				CASE $$VK_RIGHT:
					longinc = longinc - 0.5

				CASE $$VK_UP:
					latinc = latinc + 0.5

				CASE $$VK_DOWN:
 					latinc = latinc - 0.5
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
	className$  = "OpenGLExample"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Generic OpenGL Example."
' OpenGL requires the window to have styles WS_CLIPCHILDREN and WS_CLIPSIBLINGS set
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS
	w 					= $$WIDTH
	h 					= $$HEIGHT
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
	UpdateWindow (#winMain)

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

	IF LIBRARY(0) THEN RETURN							' main program executes message loop

	DO																				' the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			IF msg.message = $$WM_QUIT THEN EXIT DO
			TranslateMessage (&msg)						' translate virtual-key messages into character messages
			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		ELSE
			DrawScene ()											' draw stuff
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
	pixelDesc.dwFlags = $$PFD_DRAW_TO_WINDOW | $$PFD_DOUBLEBUFFER | $$PFD_SUPPORT_OPENGL
	pixelDesc.dwLayerMask = $$PFD_MAIN_PLANE
'	pixelDesc.iLayerType = $$PFD_MAIN_PLANE
	pixelDesc.iPixelType = $$PFD_TYPE_COLORINDEX
	pixelDesc.cColorBits = 8
	pixelDesc.cDepthBits = 16
	pixelDesc.cAccumBits = 0
	pixelDesc.cStencilBits = 0

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
' #########################
' #####  DeleteRC ()  #####
' #########################
'
' Make the OpenGL rendering context not current
' and then delete it.
'
FUNCTION  DeleteRC (hRC)

	IF (wglGetCurrentContext () != NULL) THEN
		wglMakeCurrent (NULL, NULL)   ' make the rendering context not current
	END IF

	IFZ hRC THEN RETURN

	wglDeleteContext (hRC)					' delete current rendering context

END FUNCTION
'
'
' #############################
' #####  InitializeGL ()  #####
' #############################
'
FUNCTION  InitializeGL (DOUBLE width, DOUBLE height)

	SHARED SINGLE maxObjectSize, aspect
	SHARED DOUBLE near_plane, far_plane

	SHARED SINGLE latitude, longitude, latinc, longinc
	SHARED DOUBLE radius

	glClearIndex ($$BLACK_INDEX)
	glClearDepth (1.0)

	glEnable ($$GL_DEPTH_TEST)

	glMatrixMode ($$GL_PROJECTION)
	aspect = width / height
	gluPerspective (45.0, aspect, 3.0, 7.0)
	glMatrixMode ($$GL_MODELVIEW)

	near_plane = 3.0
	far_plane = 7.0
	maxObjectSize = 3.0
	radius = near_plane + maxObjectSize/2.0

	latitude = 0.0
	longitude = 0.0
	
	latinc = 0.5
	longinc = 0.5

	CreateObjects ()

END FUNCTION
'
'
' ##############################
' #####  CreateObjects ()  #####
' ##############################
'
FUNCTION  CreateObjects ()

	glNewList ($$GLOBE, $$GL_COMPILE)
		quadObj = gluNewQuadric ()
		gluQuadricDrawStyle (quadObj, $$GLU_LINE)
		gluSphere (quadObj, 1.5, 16, 16)
	glEndList ()

	glNewList ($$CONE, $$GL_COMPILE)
		quadObj = gluNewQuadric ()
		gluQuadricDrawStyle (quadObj, $$GLU_FILL)
		gluQuadricNormals (quadObj, $$GLU_SMOOTH)
		gluCylinder (quadObj, 0.3, 0.0, 0.6, 15, 10)
	glEndList()

	glNewList ($$CYLINDER, $$GL_COMPILE)
 		glPushMatrix ()
		glRotatef (90.0, 1.0, 0.0, 0.0)
		glTranslatef (0.0, 0.0, -1.0)
		quadObj = gluNewQuadric ()
		gluQuadricDrawStyle (quadObj, $$GLU_FILL)
		gluQuadricNormals (quadObj, $$GLU_SMOOTH)
		gluCylinder (quadObj, 0.3, 0.3, 0.6, 12, 2)
		glPopMatrix ()
	glEndList ()

END FUNCTION
'
'
' #######################
' #####  Resize ()  #####
' #######################
'
FUNCTION  Resize (DOUBLE width, DOUBLE height)

	SINGLE aspect

	glViewport (0, 0, width, height)
	aspect = width / height

	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()
	gluPerspective (45.0, aspect, 3.0, 7.0)
	glMatrixMode ($$GL_MODELVIEW)

END FUNCTION
'
'
' ##########################
' #####  PolarView ()  #####
' ##########################
'
FUNCTION  PolarView (DOUBLE radius, DOUBLE twist, DOUBLE latitude, DOUBLE longitude)

	glTranslated (0.0, 0.0, -radius)
	glRotated (-twist, 0.0, 0.0, 1.0)
	glRotated (-latitude, 1.0, 0.0, 0.0)
	glRotated (longitude, 0.0, 0.0, 1.0)

END FUNCTION
'
'
' ##########################
' #####  DrawScene ()  #####
' ##########################
'
FUNCTION  DrawScene ()

	SHARED SINGLE latitude, longitude, latinc, longinc
	SHARED DOUBLE radius
	SHARED hDC

	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)

	glPushMatrix ()

		latitude = latitude + latinc
		longitude = longitude + longinc

		PolarView (radius, 0, latitude, longitude)

		glIndexi ($$RED_INDEX)
		glCallList ($$CONE)

		glIndexi ($$BLUE_INDEX)
		glCallList ($$GLOBE)

		glIndexi ($$GREEN_INDEX)
		glPushMatrix ()
			glTranslatef (0.8, -0.65, 0.0)
			glRotatef (30.0, 1.0, 0.5, 1.0)
			glCallList ($$CYLINDER)
		glPopMatrix ()

	glPopMatrix ()

	wglSwapBuffers (hDC)


END FUNCTION
END PROGRAM
