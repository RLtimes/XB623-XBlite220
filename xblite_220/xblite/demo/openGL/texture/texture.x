'
'
' ####################
' #####  PROLOG  #####
' ####################

' An OpenGL texture example.
' Based on ogl32tex.c by Blaine Hodge.
' http://www.nullterminator.net/gltexture.html
'
PROGRAM	"texture"
VERSION	"0.0001"
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
DECLARE FUNCTION  DrawScene ()
DECLARE FUNCTION  LoadTextureRAW (fileName$, width, height, wrap)

$$WIDTH           = 256
$$HEIGHT          = 256
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
	SHARED hRC, hDC, texture

	SELECT CASE msg

		CASE $$WM_CREATE:
			hDC = GetDC (hWnd)
			IFZ SetWindowPixelFormat (hWnd) THEN PostQuitMessage (0)
			IFZ CreateRenderingContext (hWnd, @hRC) THEN
				DeleteRC (hRC)
				ReleaseDC (hWnd, hDC)
 				PostQuitMessage (0)
			END IF

' note: change this file location if .raw is installed in a
' different directory
			file$ = "c:\\xblite\\demo\\openGL\\texture\\texture.raw"
'			file$ = "texture.raw"
			texture = LoadTextureRAW (@file$, 256, 256, $$TRUE)

		CASE $$WM_CLOSE:
			glDeleteTextures (1, &texture)
			DeleteRC (hRC)
			ReleaseDC (hWnd, hDC)
			DestroyWindow (hWnd)

		CASE $$WM_DESTROY:
			glDeleteTextures (1, &texture)
			DeleteRC (hRC)
			ReleaseDC (hWnd, hDC)
			PostQuitMessage(0)

		CASE $$WM_KEYDOWN:
			SELECT CASE wParam
				CASE $$VK_ESCAPE : DestroyWindow (hWnd)
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
	className$  = "OpenGLTextureExample"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "OpenGL Texture Example."
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

	MSG msg

	DO
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN
			IF msg.message = $$WM_QUIT THEN EXIT DO
			TranslateMessage (&msg)
			DispatchMessageA (&msg)
		ELSE
			DrawScene ()
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
' #####################################
' #####  SetWindowPixelFormat ()  #####
' #####################################
'
' The first step to creating an OpenGL rendering context is to
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
'	pixelDesc.dwLayerMask = $$PFD_MAIN_PLANE
	pixelDesc.iLayerType = $$PFD_MAIN_PLANE
	pixelDesc.iPixelType = $$PFD_TYPE_RGBA
	pixelDesc.cColorBits = 24
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
' ##########################
' #####  DrawScene ()  #####
' ##########################
'
FUNCTION  DrawScene ()

	SHARED hDC, texture
	STATIC theta

	glClearColor (0.0, 0.0, 0.0, 0.0)
	glClear ($$GL_COLOR_BUFFER_BIT)

' setup texture mapping
	glEnable ($$GL_TEXTURE_2D)
	glBindTexture ($$GL_TEXTURE_2D, texture)

	glPushMatrix ()
	glRotatef (theta, 0.0, 0.0, 1.0)

	glBegin ($$GL_QUADS)
		glTexCoord2d (0.0, 0.0) : glVertex2d (-1.0, -1.0)
		glTexCoord2d (1.0, 0.0) : glVertex2d (+1.0, -1.0)
		glTexCoord2d (1.0, 1.0) : glVertex2d (+1.0, +1.0)
		glTexCoord2d (0.0, 1.0) : glVertex2d (-1.0, +1.0)
	glEnd ()

	glPopMatrix()

	wglSwapBuffers (hDC)

	INC theta

END FUNCTION
'
'
' ###############################
' #####  LoadTextureRAW ()  #####
' ###############################
'
FUNCTION  LoadTextureRAW (fileName$, width, height, wrap)

	IFZ width * height THEN RETURN ($$TRUE)

' open texture data
	ofile = OPEN (fileName$, $$RD)
	IF ofile < 2 THEN RETURN ($$TRUE)

' allocate buffer
'	width = 256
'	height = 256
	tdata$ = NULL$ (width * height * 3)

' read texture data
	READ [ofile], tdata$
	CLOSE (ofile)

' allocate a texture name
	glGenTextures (1, &txt1)

' select our current texture
	glBindTexture ($$GL_TEXTURE_2D, txt1)

' select modulate to mix texture with color for shading
	glTexEnvf ($$GL_TEXTURE_ENV, $$GL_TEXTURE_ENV_MODE, $$GL_MODULATE)

' when texture area is small, bilinear filter the closest MIP map
	glTexParameterf ($$GL_TEXTURE_2D, $$GL_TEXTURE_MIN_FILTER, $$GL_LINEAR_MIPMAP_NEAREST)

' when texture area is large, bilinear filter the first MIP map
	glTexParameterf ($$GL_TEXTURE_2D, $$GL_TEXTURE_MAG_FILTER, $$GL_LINEAR)

' if wrap is true, the texture wraps over at the edges (repeat)
'       ... false, the texture ends at the edges (clamp)
	IF wrap THEN
   	glTexParameterf ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_REPEAT)
   	glTexParameterf ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_REPEAT)
	ELSE
		glTexParameterf ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_S, $$GL_CLAMP)
		glTexParameterf ($$GL_TEXTURE_2D, $$GL_TEXTURE_WRAP_T, $$GL_CLAMP)
	END IF

' build our texture MIP maps
	gluBuild2DMipmaps ($$GL_TEXTURE_2D, 3, width, height, $$GL_RGB, $$GL_UNSIGNED_BYTE, &tdata$)

	RETURN (txt1)

END FUNCTION
END PROGRAM
