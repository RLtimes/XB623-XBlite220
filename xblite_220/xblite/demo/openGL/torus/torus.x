'
'
' ####################
' #####  PROLOG  #####
' ####################

' A fullscreen Win32 OpenGL example which draws
' two rotating objects. Use the up-down and 
' left-right arrow keys to change the rotation
' speed. Use the Enter, Space, or Esc key to exit.
'
PROGRAM	"torus"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xsx"
	IMPORT  "xma"
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "opengl32"
	IMPORT  "glu32"
	
TYPE POINT3D
  SINGLE .x
  SINGLE .y       
  SINGLE .z       
  SINGLE .col     
END TYPE

TYPE POLYTYPE
	XLONG .p1 
	XLONG .p2 
	XLONG .p3 
  SINGLE .u1
  SINGLE .v1
  SINGLE .u2
  SINGLE .v2
  SINGLE .u3
  SINGLE .v3
  SINGLE .col
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
DECLARE FUNCTION  DeleteRC (hRC)
DECLARE FUNCTION  InitializeGL (DOUBLE width, DOUBLE height)
DECLARE FUNCTION  DrawScene ()
DECLARE FUNCTION  LoadTorus (Rings, Bands, SINGLE RingRadius, SINGLE BandRadius, Tsize)
DECLARE FUNCTION  InitVertexes ()

$$glX = 0.525731112119133606
$$glZ = 0.850650808352039932

$$TOR_NUM_RINGS = 30
$$TOR_NUM_BANDS = 15
$$TOR_RING_RAD  = 1.20
$$TOR_BAND_RAD  = 0.30

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
	SHARED SINGLE thetaInc, torThetaInc

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
					thetaInc = thetaInc + 0.5

				CASE $$VK_RIGHT:
					thetaInc = thetaInc - 0.5

				CASE $$VK_UP:
					torThetaInc = torThetaInc + 0.5

				CASE $$VK_DOWN:
 					torThetaInc = torThetaInc - 0.5
					 
				CASE $$VK_RETURN, $$VK_ESCAPE, $$VK_SPACE : SendMessageA (hWnd, $$WM_DESTROY, 0, 0)
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
	className$  = "OpenGLTorus"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "OpenGL Torus Example."
' OpenGL requires the window to have styles WS_CLIPCHILDREN and WS_CLIPSIBLINGS set
' Try a full screen style using WS_POPUP
	style = $$WS_POPUP | $$WS_CLIPCHILDREN | $$WS_CLIPSIBLINGS
	w 		= GetSystemMetrics ($$SM_CXSCREEN)
	h 		= GetSystemMetrics (SM_CYSCREEN)
	#winMain = NewWindow (className$, titleBar$, style, 0, 0, w, h, 0)
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

	DO																		' the message loop
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
	pixelDesc.iPixelType = $$PFD_TYPE_RGBA
	pixelDesc.cColorBits = 24
	pixelDesc.cDepthBits = 24

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

	DOUBLE FOVy, aspect, znear, zfar
	SHARED SINGLE thetaInc, torThetaInc
	
	thetaInc = 1.0
	torThetaInc = 1.0

	glViewport (0, 0, width, height)
	glMatrixMode ($$GL_PROJECTION)
	glLoadIdentity ()

  FOVy = 40
  aspect = width / height
  znear = 5
  zfar = 1000
	gluPerspective (FOVy, aspect, znear, zfar)

	glMatrixMode ($$GL_MODELVIEW)

	glLoadIdentity ()

	glShadeModel ($$GL_SMOOTH)
	glClearColor (0.0, 0.0, 0.0, 0.5)
	glClearDepth (1.0)
	glEnable ($$GL_DEPTH_TEST)
	glDepthFunc ($$GL_LEQUAL)
	glEnable ($$GL_COLOR_MATERIAL)
	glHint ($$GL_PERSPECTIVE_CORRECTION_HINT, $$GL_NICEST)

	InitVertexes ()
	LoadTorus ($$TOR_NUM_RINGS, $$TOR_NUM_BANDS, $$TOR_RING_RAD, $$TOR_BAND_RAD, 128)
	

END FUNCTION
'
' ##########################
' #####  DrawScene ()  #####
' ##########################
'
FUNCTION  DrawScene ()

	SHARED hDC
	SHARED SINGLE vertexdat[]	
  SHARED SINGLE vertexcol[]
  SHARED vertexidx[]
  SHARED POINT3D Model[]
  SHARED POLYTYPE ModelTri[]
	STATIC SINGLE theta, tortheta
	SHARED SINGLE thetaInc, torThetaInc
 
  glClear ($$GL_COLOR_BUFFER_BIT | $$GL_DEPTH_BUFFER_BIT)
  glPushMatrix ()
  glLoadIdentity ()
	glTranslatef (0.0, 0.8, -13.0)
  glScalef (1.5, 1.5, 1.5)
  glRotatef (theta, 1.0, 0.0, 0.0)
  glRotatef (theta, 0.0, 1.0, 0.0)
  glRotatef (theta, 0.0, 0.0, 1.0)

  FOR i = 0 TO 19
    glBegin ($$GL_TRIANGLES)
			glColor3f   (vertexcol[i, 0], vertexcol[i, 1], vertexcol[i, 2])
			glVertex3fv (&vertexdat[vertexidx[i,0], 0])
			glColor3f   (vertexcol[i, 2], vertexcol[i, 1], vertexcol[i, 0])
			glVertex3fv (&vertexdat[vertexidx[i,1], 0])
			glColor3f   (vertexcol[i, 2], vertexcol[i, 0], vertexcol[i, 1])
			glVertex3fv (&vertexdat[vertexidx[i,2], 0])
    glEnd ()
  NEXT i

  glPopMatrix ()

  ' draw torus
  glPushMatrix ()
  glLoadIdentity ()
  glTranslatef (0.0, 0.8, -13.0)
  glScalef (2.5, 2.5, 2.5)
  glRotatef (tortheta, 1.0, 0.0, 0.0)
  glRotatef (tortheta, 0.0, 0.0, 1.0)
  glRotatef (tortheta, 0.0, 1.0, 0.0)

	upp = UBOUND(ModelTri[])
  FOR i = 0 TO upp 
    glBegin ($$GL_TRIANGLES)
			glColor3f   (Model[ModelTri[i].p1].col, Model[ModelTri[i].p2].col, Model[ModelTri[i].p3].col)
			glVertex3fv (&Model[ModelTri[i].p1].x)
			glColor3f   (Model[ModelTri[i].p3].col, Model[ModelTri[i].p3].col, Model[ModelTri[i].p1].col)
			glVertex3fv (&Model[ModelTri[i].p2].x)
			glColor3f   (Model[ModelTri[i].p2].col, Model[ModelTri[i].p1].col, Model[ModelTri[i].p3].col)
			glVertex3fv (&Model[ModelTri[i].p3].x)
    glEnd ()
  NEXT i

  glPopMatrix()

  theta = theta + thetaInc  ' 1.0
  tortheta = tortheta + torThetaInc  '1.0
	
	wglSwapBuffers (hDC)

END FUNCTION
'
' #######################
' #####  LoadTorus  #####
' #######################
'
'
'
FUNCTION LoadTorus (Rings, Bands, SINGLE RingRadius, SINGLE BandRadius, Tsize)

  SHARED POINT3D Model[]
  SHARED POLYTYPE ModelTri[]
	
	SINGLE x1, y1, z1
  SINGLE a1, a2
'  SINGLE p, q, r
	
  MaxPoint = Rings * Bands
  REDIM Model[MaxPoint - 1]
	
'  p = 3
'  q = 2
  a1 = 2.0 * $$PI / SINGLE(Rings) 
	a2 = 2.0 * $$PI / SINGLE(Bands)
  i = 0
  FOR s2 = 0 TO Bands - 1
    FOR s1 = 0 TO Rings - 1
      x1 = Cos(s1 * a1) * RingRadius
      y1 = Sin(s1 * a1) * RingRadius
      Model[i].x = x1 + Cos(s1 * a1) * Cos(s2 * a2) * BandRadius
      Model[i].y = y1 + Sin(s1 * a1) * Cos(s2 * a2) * BandRadius
      Model[i].z = Sin(s2 * a2) * BandRadius
      Model[i].col = XstRandomUniform ()
      INC i
    NEXT s1
  NEXT s2

  i = 0
  maxtri = 0
  FOR s1 = Bands - 1 TO 0 STEP -1
    FOR s2 = Rings - 1 TO 0 STEP -1
      INC i
      INC maxtri
      INC i
      INC maxtri
    NEXT s2
  NEXT s1

  REDIM ModelTri[maxtri]

  i = 0
  FOR s2 = Rings - 1 TO 0 STEP -1
    FOR s1 = Bands - 1 TO 0 STEP -1
      ModelTri[i].p3 = (s1 * Rings + s2 + Rings) MOD MaxPoint
      ModelTri[i].p2 = s1 * Rings + (s2 + 1) MOD Rings
      ModelTri[i].p1 = s1 * Rings + s2
      ModelTri[i].u1 = Tsize
      ModelTri[i].v1 = 0
      ModelTri[i].u2 = 0
      ModelTri[i].v2 = 0
      ModelTri[i].u3 = Tsize
      ModelTri[i].v3 = Tsize
      ModelTri[i].col = XstRandomUniform () 
      INC i
      ModelTri[i].p3 = (s1 * Rings + s2 + Rings) MOD MaxPoint
      ModelTri[i].p2 = (s1 * Rings + (s2 + 1) MOD Rings + Rings) MOD MaxPoint
      ModelTri[i].p1 = s1 * Rings + (s2 + 1) MOD Rings
      ModelTri[i].u1 = 0
      ModelTri[i].v1 = 0
      ModelTri[i].u2 = 0
      ModelTri[i].v2 = Tsize
      ModelTri[i].u3 = Tsize
      ModelTri[i].v3 = Tsize
      ModelTri[i].col = XstRandomUniform ()
      INC i
    NEXT s1
  NEXT s2

END FUNCTION
'
' ##########################
' #####  InitVertexes  #####
' ##########################
'
'
'
FUNCTION InitVertexes ()

	SHARED SINGLE vertexdat[]	
  SHARED SINGLE vertexcol[]
  SHARED vertexidx[]
	SINGLE Vertex[]
	
	DIM vertexdat[11, 2]
	DIM vertexcol[19, 2]
	DIM vertexidx[19, 2]
	
	DIM Vertex[35] 
	Vertex[0]= -$$glX  : Vertex[1]= 0.0     : Vertex[2]= $$glZ
	Vertex[3]= $$glX   : Vertex[4]= 0.0     : Vertex[5]= $$glZ
	Vertex[6]= -$$glX  : Vertex[7]= 0.0     : Vertex[8]= -$$glZ
	Vertex[9]= $$glX   : Vertex[10]= 0.0    : Vertex[11]= -$$glZ
	Vertex[12]= 0.0    : Vertex[13]= $$glZ  : Vertex[14]= $$glX
	Vertex[15]= 0.0    : Vertex[16]= $$glZ  : Vertex[17]= -$$glX
	Vertex[18]= 0.0    : Vertex[19]= -$$glZ : Vertex[20]= $$glX
	Vertex[21]= 0.0    : Vertex[22]= -$$glZ : Vertex[23]= -$$glX
	Vertex[24]= $$glZ  : Vertex[25]= $$glX  : Vertex[26]= 0.0
	Vertex[27]= -$$glZ : Vertex[28]= $$glX  : Vertex[29]= 0.0
	Vertex[30]= $$glZ  : Vertex[31]= -$$glX : Vertex[32]= 0.0
	Vertex[33]= -$$glZ : Vertex[34]= -$$glX : Vertex[35]= 0.0
	
	Indices$ = "0,4,1,0,9,4,9,5,4,4,5,8,4,8,1,8,10,1,8,3,10,5,3,8,5,2,3,2,7,3,7,10,3,7,6,10,7,11,6,11,0,6,0,1,6,6,1,10,9,0,11,9,11,2,9,2,5,7,2,11"

	FOR i = 0 TO 11
		FOR j = 0 TO 2
			vertexdat[i, j] = Vertex[index]
			INC index
		NEXT j
	NEXT i

	index = 0 : term = 0 : done = 0
	FOR i = 0 TO 19
		FOR j = 0 TO 2
			val$ = XstNextItem$ (Indices$, @index, @term, @done)
			vertexidx[i, j] = XLONG (val$)
			vertexcol[i, j] = XstRandomUniform ()
		NEXT j
	NEXT i

END FUNCTION

END PROGRAM
