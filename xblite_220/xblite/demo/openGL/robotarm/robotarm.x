'
'
' ####################
' #####  PROLOG  #####
' ####################

' This example is taken from the tutorial
' Using OpenGL in Visual C++: Part III.
' ---
' This demo shows how to use OpenGL functions
' to display lists and do basic transfoms by
' manipulating the matrix stack and using
' double buffering.
' ---
' This program creates a "robot arm" that can
' be controlled with the mouse. The "arm" is
' actually two rectangles, where one rectangle
' rotates about a point on the other rectangle.
'
PROGRAM	"robotarm"
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

' constant declarations

$$ARMPART = 1		' identifier for the display list that is created to draw the parts of the arm
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
	SHARED DOUBLE transX, transY, angle1, angle2
	STATIC rxPos, ryPos, lxPos, lyPos
	STATIC lButtonDown, rButtonDown

	SELECT CASE msg

		CASE $$WM_CREATE:
			IFZ SetWindowPixelFormat (hWnd) THEN RETURN
			IFZ CreateRenderingContext (hWnd, @hRC) THEN RETURN

			transY = 100		' y offset of the arm from the world coordinate system origin
			transX = 100		' x offset of the arm from the world coordinate system origin
			angle2 = 15			' angle of the second part of the arm with respect to the first part.
			angle1 = 15			' angle of the first part of the arm with respect to the world coordinate axis.

			glNewList($$ARMPART, $$GL_COMPILE)	' create a display list to draw the parts of our arm
				glBegin ($$GL_POLYGON)
					glVertex2f (-10.0,  10.0)
      		glVertex2f (-10.0, -10.0)
					glVertex2f (100.0, -10.0)
					glVertex2f (100.0,  10.0)
				glEnd()
			glEndList()

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
			gluOrtho2D (0.0, 500.0*aspect, 0.0, 500.0)
			glMatrixMode ($$GL_MODELVIEW)
			glLoadIdentity ()
			glDrawBuffer ($$GL_BACK)				' draw only onto the back buffer

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

		CASE $$WM_RBUTTONDOWN:
			rxPos = LOWORD (lParam)
			ryPos = HIWORD (lParam)
			rButtonDown = $$TRUE

		CASE $$WM_RBUTTONUP:
			rButtonDown = $$FALSE

		CASE $$WM_MOUSEMOVE:
			xPos = LOWORD (lParam)
			yPos = HIWORD (lParam)

			IF rButtonDown THEN
				rotateX = rxPos - xPos
				rotateY = ryPos - yPos
				rxPos = xPos
				ryPos = yPos
				angle1 = angle1 + rotateX/2.0
				angle2 = angle2 + rotateY/2.0
				InvalidateRect (hWnd, NULL, 0)
 			END IF

			IF lButtonDown THEN
				translateX = lxPos - xPos
				translateY = lyPos - yPos
				lxPos = xPos
				lyPos = yPos
				transX = transX - translateX/2.0
				transY = transY + translateY/2.0
				InvalidateRect (hWnd, NULL, 0)
			END IF

		CASE $$WM_DESTROY:
			DeleteRC (hRC)
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
	className$  = "OpenGLRobotArm"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "OpenGL Transformations Example."
' OpenGL requires the window to have styles WS_CLIPCHILDREN and WS_CLIPSIBLINGS set
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS
	w 					= 400
	h 					= 400
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

	SHARED DOUBLE transX, transY, angle1, angle2

	glClear ($$GL_COLOR_BUFFER_BIT)

	glPushMatrix()
		glTranslated (transX, transY, 0)
		glRotated (angle1, 0, 0, 1)
		glPushMatrix ()
			glTranslated (90, 0, 0)
			glRotated (angle2, 0, 0, 1)
			glColor4f (0.0, 1.0, 0.0, 1.0)
			glCallList ($$ARMPART)
		glPopMatrix ()
		glColor4f(1.0, 0.0, 0.0, 1.0)
		glCallList ($$ARMPART)
	glPopMatrix()

	glFlush()

END FUNCTION
END PROGRAM
