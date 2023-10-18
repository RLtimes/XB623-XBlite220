'
'
' ####################
' #####  PROLOG  #####
' ####################

' This example is taken from the tutorial
' Using OpenGL in Visual C++: Part IV.

' The tutorial shows how to use basic 3-D
' graphics. It sets up a perspective view,
' defines an object and transforms that
' object in space.
'
' The program displays a lighted, multi-colored
' cube in three dimensions that uses z-buffering
' and double buffering. The cube can be rotated
' by depressing and moving the left mouse button.
'
' This demo shows how to use full-screen mode
' without a title bar or border by setting
' the window style to WS_POPUP. Pressing the
' Esc key will quit the program.
'
PROGRAM	"cube3d"
VERSION	"0.0002"
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
DECLARE FUNCTION  RenderScene ()
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

	PAINTSTRUCT ps
	STATIC hRC
	DOUBLE aspect
	STATIC lxPos, lyPos
	STATIC lButtonDown
	SHARED DOUBLE rotateX, rotateY

	SELECT CASE msg

		CASE $$WM_CREATE:
			IFZ SetWindowPixelFormat (hWnd) THEN RETURN
			IFZ CreateRenderingContext (hWnd, @hRC) THEN RETURN

		CASE $$WM_SIZE:
			width = LOWORD (lParam)
			height = HIWORD (lParam)

			IFZ height THEN
				aspect = DOUBLE(width)
			ELSE
				aspect = DOUBLE(width)/DOUBLE(height)
			END IF

			glViewport (0, 0, width, height)
			glMatrixMode ($$GL_PROJECTION)
			glLoadIdentity ()

' use perspective projection mapping
' perspective project simulates light passing through a point
' (as if you were using a pinhole camera). The result is a more
' natural picture where distant objects appear smaller.
' The gluPerspective call below sets the eye point at the origin,
' gives us a 45 angle field of view, a front clipping plane at 1,
' and a back clipping plane at 10.

			gluPerspective (45, aspect, 1, 10.0)

			glMatrixMode ($$GL_MODELVIEW)
			glLoadIdentity()
			glDrawBuffer ($$GL_BACK)				' draw only onto the back buffer
			glEnable ($$GL_LIGHTING)				' enable lighting model
			glEnable ($$GL_DEPTH_TEST)			' enable z-buffering

		CASE $$WM_PAINT:
			hDC = BeginPaint (hWnd, &ps)
			RenderScene ()
			wglSwapBuffers (hDC)						' swap the back and front buffers
			EndPaint (hWnd, &ps)

		CASE $$WM_LBUTTONDOWN:
			lxPos = LOWORD (lParam)
			lyPos = HIWORD (lParam)
			lButtonDown = $$TRUE

		CASE $$WM_LBUTTONUP:
			lButtonDown = $$FALSE

		CASE $$WM_MOUSEMOVE:
			xPos = LOWORD (lParam)
			yPos = HIWORD (lParam)

			IF lButtonDown THEN
				rotX = lxPos - xPos
				rotY = lyPos - yPos
				lxPos = xPos
				lyPos = yPos
				rotateX = rotateX - rotX/2.0
				rotateY = rotateY - rotY/2.0
				InvalidateRect (hWnd, NULL, 0)
			END IF
			
		CASE $$WM_KEYDOWN :
      vkc = wParam
      SELECT CASE vkc
        CASE $$VK_ESCAPE : DestroyWindow (hWnd)
'        CASE $$VK_UP     : PRINT "up arrow pressed"
'        CASE $$VK_DOWN   : PRINT "down arrow pressed"
'        CASE $$VK_RIGHT  : PRINT "right arrow pressed"
'        CASE $$VK_LEFT   : PRINT "left arrow pressed"
      END SELECT

		CASE $$WM_DESTROY:
			DeleteRC (hRC)
'      ChangeDisplaySettingsA (NULL, 0)
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
'  SHARED dontAskAgain
'  SHARED w, h
'  DEVMODE dmScreenSettings

' get current instance handle
  hInst = GetModuleHandleA (0)
	IFZ hInst THEN QUIT(0)

'  dontAskAgain = 0
     
' at start of app, offer two Resolutions, 1024*768 or 800*600 in fullscreen.
'  IFZ dontAskAgain THEN
'    dontAskAgain = 1
'    IF (MessageBoxA (NULL, &" Use 1024x768 Resolution instead of 800x600?", &"XBlite OpenGL 3D Engine", $$MB_YESNO | $$MB_ICONINFORMATION) == $$IDYES) THEN
'      w = 1024
'      h = 768
'    ELSE
'      w = 800
'      h = 600
'    END IF
'  END IF
  
' set display settings
' Devmode fullscreen section. Grabs video mode for fullscreen.

'  dmScreenSettings.dmSize = SIZE (dmScreenSettings)
'  dmScreenSettings.dmPelsWidth = w
'  dmScreenSettings.dmPelsHeight = h
'  dmScreenSettings.dmBitsPerPel = 16 ' demo does not display correctly on my computer in 16 bit color mode
'  dmScreenSettings.dmBitsPerPel = 24
'  dmScreenSettings.dmFields = $$DM_BITSPERPEL | $$DM_PELSWIDTH | $$DM_PELSHEIGHT
  
'  IF (ChangeDisplaySettingsA (&dmScreenSettings, $$CDS_FULLSCREEN) != $$DISP_CHANGE_SUCCESSFUL) THEN
' Pop Up A Message Box To Inform User Resolution Failed
'    MessageBoxA (NULL, &"Resolution Settings Failed. \n Using Default Resolution.", &"ERROR", $$MB_OK |$$MB_ICONSTOP)
' get default screen size
'    hDC = GetDC (0)
'    w = GetDeviceCaps (hDC, $$HORZRES)
'    h = GetDeviceCaps (hDC, $$VERTRES)
'    ReleaseDC (0, hDC)
'  END IF

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
	SHARED w, h

' register window class
	className$  = "OpenGLCube3D"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "OpenGL colored, lighted 3D cube example."
' OpenGL requires the window to have styles WS_CLIPCHILDREN and WS_CLIPSIBLINGS set
'	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS
' use WS_POPUP style for displaying window fullscreen, no titlebar
	style 			= $$WS_POPUP | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS

' get default screen size
  hDC = GetDC (0)
  w = GetDeviceCaps (hDC, $$HORZRES)
  h = GetDeviceCaps (hDC, $$VERTRES)
  ReleaseDC (0, hDC)
'	w 					= 400
'	h 					= 400
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

'	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
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

	STATIC MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, hwnd, 0, 0)	' retrieve next message from queue

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
' This example using double buffering. GDI commands will not work
' in an OpenGL window with double buffering enabled.
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
' ############################
' #####  RenderScene ()  #####
' ############################
'
FUNCTION  RenderScene ()

	SHARED DOUBLE rotateX, rotateY
	SINGLE redSurface[3], greenSurface[3], blueSurface[3]
	SINGLE lightAmbient[3], lightDiffuse[3], lightSpecular[3], lightPosition[3]

' define light property values

	lightAmbient[0] = 0.1 	: lightAmbient[1] = 0.1 	: lightAmbient[2] = 0.1 	: lightAmbient[3] = 0.1
	lightDiffuse[0] = 0.7 	: lightDiffuse[1] = 0.7 	: lightDiffuse[2] = 0.7 	: lightDiffuse[3] = 0.7
	lightSpecular[0] = 0.0 	: lightSpecular[1] = 0.0 	: lightSpecular[2] = 0.0 	: lightSpecular[3] = 0.1
	lightPosition[0] = 5.0 	: lightPosition[1] = 5.0 	: lightPosition[2] = 5.0 	: lightPosition[3] = 0.0

' define surface property values
' the numbers represent the red, green, blue and alpha
' components of the surfaces

	redSurface[0] = 1.0 	: redSurface[1] = 0.0 	: redSurface[2] = 0.0 	: redSurface[3] = 1.0
	greenSurface[0] = 0.0 : greenSurface[1] = 1.0 : greenSurface[2] = 0.0 : greenSurface[3] = 1.0
	blueSurface[0] = 0.0 	: blueSurface[1] = 0.0 	: blueSurface[2] = 1.0 	: blueSurface[3] = 1.0

	glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)  ' clear both color and z-depth buffers

' set light $$GL_LIGHT0 properties; ambient, diffuse, specular, and position
	glLightfv ($$GL_LIGHT0, $$GL_AMBIENT, &lightAmbient[])
	glLightfv ($$GL_LIGHT0, $$GL_DIFFUSE, &lightDiffuse[])
	glLightfv ($$GL_LIGHT0, $$GL_SPECULAR, &lightSpecular[])
	glLightfv ($$GL_LIGHT0, $$GL_POSITION, &lightPosition[])
	glEnable ($$GL_LIGHT0)														' turn on the light

	glPushMatrix ()
		glTranslated (0.0, 0.0, -8.0)
		glRotated (rotateX, 1.0, 0.0, 0.0)
		glRotated (rotateY, 0.0, 1.0, 0.0)

	' set color to front side only, use ambient and diffuse reflectivity
		glMaterialfv ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE, &redSurface[])
		glBegin ($$GL_POLYGON)
			glNormal3d (  1.0,  0.0,  0.0)
			glVertex3d (  1.0,  1.0,  1.0)
			glVertex3d (  1.0, -1.0,  1.0)
			glVertex3d (  1.0, -1.0, -1.0)
			glVertex3d (  1.0,  1.0, -1.0)
		glEnd ()

		glBegin ($$GL_POLYGON)
			glNormal3d ( -1.0,  0.0,  0.0)
			glVertex3d ( -1.0, -1.0,  1.0)
			glVertex3d ( -1.0,  1.0,  1.0)
			glVertex3d ( -1.0,  1.0, -1.0)
			glVertex3d ( -1.0, -1.0, -1.0)
		glEnd ()

		glMaterialfv ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE, &greenSurface[])
		glBegin ($$GL_POLYGON)
			glNormal3d (  0.0,  1.0,  0.0)
			glVertex3d (  1.0,  1.0,  1.0)
			glVertex3d ( -1.0,  1.0,  1.0)
			glVertex3d ( -1.0,  1.0, -1.0)
			glVertex3d (  1.0,  1.0, -1.0)
		glEnd ()

		glBegin ($$GL_POLYGON)
			glNormal3d (  0.0, -1.0,  0.0)
			glVertex3d ( -1.0, -1.0,  1.0)
			glVertex3d (  1.0, -1.0,  1.0)
			glVertex3d (  1.0, -1.0, -1.0)
			glVertex3d ( -1.0, -1.0, -1.0)
 		glEnd ()

		glMaterialfv ($$GL_FRONT, $$GL_AMBIENT_AND_DIFFUSE, &blueSurface[])
		glBegin ($$GL_POLYGON)
			glNormal3d (  0.0,  0.0,  1.0)
			glVertex3d (  1.0,  1.0,  1.0)
			glVertex3d ( -1.0,  1.0,  1.0)
			glVertex3d ( -1.0, -1.0,  1.0)
			glVertex3d (  1.0, -1.0,  1.0)
		glEnd ()

		glBegin($$GL_POLYGON)
			glNormal3d(  0.0,  0.0, -1.0)
			glVertex3d( -1.0,  1.0, -1.0)
			glVertex3d(  1.0,  1.0, -1.0)
			glVertex3d(  1.0, -1.0, -1.0)
			glVertex3d( -1.0, -1.0, -1.0)
		glEnd ()
	glPopMatrix ()

END FUNCTION
END PROGRAM
