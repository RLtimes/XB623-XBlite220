'
'
' ####################
' #####  PROLOG  #####
' ####################

' A direct draw demo program based on tutorial
' First Steps found at:
' http://sunlightd.virtualave.net/Windows/
' DirectX/FirstSteps.html
'
PROGRAM	"ddexample1"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"xdd"				' xblite direct draw library
	IMPORT	"ole32"
	IMPORT	"ddraw.dec"	' direct draw declaration file
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  InitDirectDraw (hWnd)
DECLARE FUNCTION  ExitDirectDraw (hWnd)
DECLARE FUNCTION  OnIdle ()
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

	SELECT CASE msg

		CASE $$WM_CREATE :
			ret = InitDirectDraw (hWnd)
			IF ret THEN XstAlert("WM_CREATE: InitDirectDraw ret=" + STRING$(ret))

		CASE $$WM_KEYDOWN :
			IF ((wParam & 0xFF) = 27) THEN			' close on escape key
				ExitDirectDraw (hWnd)
				DestroyWindow (hWnd)
			END IF

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE $$WM_CLOSE :
			ExitDirectDraw (hWnd)
			DestroyWindow (hWnd)

		CASE $$WM_SETCURSOR :
			SetCursor (NULL)					' remove cursor from screen

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
	className$  = "DDSampleWindowClass"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window as full-screen window
	titleBar$  	= "DirectDraw Sample."
	style 			= $$WS_POPUP
	w 					= GetSystemMetrics ($$SM_CXSCREEN)
	h 					= GetSystemMetrics ($$SM_CYSCREEN)
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

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

	IF LIBRARY(0) THEN RETURN							' main program executes message loop

	DO																		' the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			IF msg.message = $$WM_QUIT THEN EXIT DO		' exit
			TranslateMessage (&msg)						' translate virtual-key messages into character messages
			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		ELSE
			OnIdle ()													' do some stuff during idle time
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
' ###############################
' #####  InitDirectDraw ()  #####
' ###############################
'
FUNCTION  InitDirectDraw (hWnd)

	SHARED pDD, lpPrimary, lpA, lpBackBuffer, lpSprites
	GUID iid
	DDSURFACEDESC2 ddsd

' Initialise DirectDraw and go to full screen mode.

' Create an IDirectDraw7 object.
	XLONGAT (&&iid) = &$$IID_IDirectDraw7
	hr = XddDirectDrawCreateEx (NULL, &pDD, &iid, NULL)
'	DirectDrawCreateEx(NULL, &pDD, IID_IDirectDraw7, NULL)

	IF hr < 0 THEN
		msg$ = "Error : InitDirectDraw : XddDirectDrawCreateEx"
		XstAlert (msg$)
		RETURN ($$TRUE)
	END IF

' Set the co-operative level of the application.
' The co-operative level defines how much access
' needed to the video hardware. We want exclusive,
' full-screen access to the display.

' pDD->SetCooperativeLevel(hWndMain, DDSCL_FULLSCREEN | DDSCL_EXCLUSIVE | DDSCL_ALLOWREBOOT)
	hr = IDirectDraw_SetCooperativeLevel (pDD, hWnd, $$DDSCL_FULLSCREEN | $$DDSCL_EXCLUSIVE | $$DDSCL_ALLOWREBOOT)

	IF hr < 0 THEN
		msg$ = "Error : InitDirectDraw : SetCooperativeLevel"
		XstAlert (msg$)
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

' Set screen resolution, first - 640x480, 16-bit colour.

	hr = IDirectDraw_SetDisplayMode (pDD, 640, 480, 16, 0, 0)

	IF hr < 0 THEN
		msg$ = "Error : InitDirectDraw : SetDisplayMode"
		XstAlert (msg$)
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

' A surface simply corresponds to an area of memory
' (usually video memory). This method gives us direct
' access to things like the video memory buffer.
' Naturally enough, for such a resource, co-operation
' is important. Access to the buffer is regulated through
' the methods associated with the surface.

' The primary surface corresponds to the video memory
' that goes on the display. We could draw directly to
' the primary surface, but this tends to cause horrible
' 'tearing' as the changes we make are visible as we draw them.
' We will instead use a back buffer. This is a buffer in video
' memory which can be swapped with the primary surface.
' This allows us to prepare a frame without showing it until we're done.

' We have specified two back buffers (triple buffering) since
' this gives us a better average frame rate if the frame drawing
' time is close to the display refresh rate.

' We will first get a primary surface object:

	ddsd.dwSize = SIZE (ddsd)
	ddsd.dwFlags = $$DDSD_CAPS | $$DDSD_BACKBUFFERCOUNT
	ddsd.ddsCaps.dwCaps = $$DDSCAPS_PRIMARYSURFACE | $$DDSCAPS_FLIP | $$DDSCAPS_COMPLEX
	ddsd.dwBackBufferCount = 2

'	pDD->CreateSurface(&ddsd, &lpPrimary, NULL);
	hr = IDirectDraw_CreateSurface (pDD, &ddsd, &lpPrimary, NULL)

	IF hr < 0 THEN
		msg$ = "Error : InitDirectDraw : CreateSurface"
		XstAlert (msg$)
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

' We now want a pointer to the back buffer:

	ddsd.ddsCaps.dwCaps = $$DDSCAPS_BACKBUFFER
' lpPrimary->GetAttachedSurface(&ddsd.ddsCaps, &lpBackBuffer);
	hr = IDirectDrawSurface_GetAttachedSurface (lpPrimary, &ddsd.ddsCaps, &lpBackBuffer)

	IF hr < 0 THEN
		msg$ = "Error : InitDirectDraw : GetAttachedSurface"
		XstAlert (msg$)
		IDirectDraw_Release (lpPrimary)
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

' Note that only one pointer is retrieved, despite there
' being two back buffers. When Windows swaps the buffers,
' it also swaps the back buffer pointers so that you can
' continue to use the back buffer pointer. Thus, we will
' use the back buffer pointer lpBackBuffer for all our drawing.

' The next function loads either a bitmap file or resource
' and gives us an off-screen surface. This is a surface
' that cannot be displayed directly on the screen.

	lpA = XddLoadBitmap (pDD, "owl.bmp", 0, 0)

' We have now loaded the bitmap into a surface,
' and it is ready for drawing. See OnIdle().

' Load a sprite image
	lpSprites = XddLoadBitmap (pDD, "sprites.bmp", 0, 0)

' Set color to be used as mask for sprite
	XddSetColorKey (lpSprites, RGB(255, 0, 255))


END FUNCTION
'
'
' ###############################
' #####  ExitDirectDraw ()  #####
' ###############################
'
FUNCTION  ExitDirectDraw (hWnd)

	SHARED pDD, lpPrimary, lpA, lpSprites

	IF lpSprites THEN
		IDirectDraw_Release (lpSprites)
		lpSprites = NULL
	END IF

	IF lpA THEN
		IDirectDraw_Release (lpA)
		lpA = NULL
	END IF

	IF lpPrimary THEN
		IDirectDraw_Release (lpPrimary)
		lpPrimary = NULL
	END IF

	IF pDD THEN
' restore display mode
		IDirectDraw_RestoreDisplayMode (pDD)

' restore exclusive mode
		IDirectDraw_SetCooperativeLevel (pDD, hWnd, $$DDSCL_NORMAL)

' free direct draw
		IDirectDraw_Release (pDD)
		pDD = NULL

	END IF


END FUNCTION
'
'
' #######################
' #####  OnIdle ()  #####
' #######################
'
FUNCTION  OnIdle ()

	SHARED pDD, lpPrimary, lpA, lpBackBuffer, lpSprites
	RECT r
	STATIC x, goright, goleft, initx
	POINT p

' Now we have a surface, we can copy from it
' to the back buffer. This is done using the
' BltFast method of the back buffer:

	IF (lpPrimary == NULL) THEN RETURN

' draw background bitmap

	r.left   = 0
	r.top    = 0
	r.right  = 640
	r.bottom = 480

	IDirectDrawSurface_BltFast (lpBackBuffer, 0, 0, lpA, &r, $$DDBLTFAST_NOCOLORKEY | $$DDBLTFAST_WAIT)

' This code copies the whole of the bitmap to the screen.
' You can see that by changing the values in the rectangle,
' we can copy (blit) sections of the bitmap.
' The destination corner is given by the first two parameters
' of BltFast ((0, 0) in this case).


' draw third sprite in the middle of screen
	r.left = 128
	r.top = 0
	r.right = 192
	r.bottom = 64
'	lpBackBuffer->BltFast(288, 208, lpSprites, &r, DDBLTFAST_SRCCOLORKEY | DDBLTFAST_WAIT);
	IDirectDrawSurface_BltFast (lpBackBuffer, 288, 208, lpSprites, &r, $$DDBLTFAST_SRCCOLORKEY | $$DDBLTFAST_WAIT)

' draw a moving sprite
	IFZ initx THEN
		goright = $$TRUE
		goleft = $$FALSE
		x = 0
		initx = $$TRUE
	END IF

	IF goright THEN
		INC x
		IF (x > 100) THEN
			goright = $$FALSE
			goleft = $$TRUE
		END IF
	END IF

	IF goleft THEN
		DEC x
		IF (x < -100) THEN
			goright = $$TRUE
			goleft = $$FALSE
		END IF
	END IF

	r.left  = 0
	r.right = 64
	IDirectDrawSurface_BltFast (lpBackBuffer, 288+x, 100, lpSprites, &r, $$DDBLTFAST_SRCCOLORKEY | $$DDBLTFAST_WAIT)

' move a sprite around using the current mouse position

	GetCursorPos (&p)

	r.left = 64
	r.right = 128
	IDirectDrawSurface_BltFast (lpBackBuffer, p.x, p.y, lpSprites, &r, $$DDBLTFAST_SRCCOLORKEY | $$DDBLTFAST_WAIT)

' Now there's something on the back buffer, let's do
' a buffer swap to get things on the screen:

	IDirectDrawSurface_Flip (lpPrimary, NULL, $$DDFLIP_WAIT)

' Run the program. Your bitmap should appear in
' full 16-bit color glory. Use ALT-F4 to exit.



END FUNCTION
END PROGRAM
