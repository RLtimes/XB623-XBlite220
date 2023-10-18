'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A direct draw starfield demo.
' Illustrates how to draw to hDC.
'
'
PROGRAM	"starfield"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"xio"
	IMPORT	"xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT	"xdd"				' xblite direct draw library
	IMPORT	"ole32"
	IMPORT	"ddraw.dec"	' direct draw declaration file
	IMPORT	"msvcrt"		' ms VC runtime library
'
TYPE TSTAR
	DOUBLE	.x
	DOUBLE	.y
	XLONG		.color
END TYPE

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
DECLARE FUNCTION  DOUBLE Rnd ()
DECLARE FUNCTION  DrawNextFrame ()
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
	RECT rect
	SHARED resolutionX, resolutionY, numStars
	SHARED TSTAR stars[]
	DOUBLE rn
	SHARED active

	SELECT CASE msg

		CASE $$WM_CREATE :
			InitDirectDraw (hWnd)
			resolutionX = 640
			resolutionY = 480
			numStars = 400
			DIM stars[numStars-1]
			FOR i = 0 TO numStars-1			' initialize star positions
				stars[i].x = Rnd() * resolutionX \ 2.0 - resolutionX \ 4.0
				stars[i].y = Rnd() * resolutionX \ 2.0 - resolutionX \ 4.0
				stars[i].color = Rnd() * 20 + 50
			NEXT i

		CASE $$WM_ACTIVATEAPP :
			active = wParam										' update active flag

		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE $$WM_KEYDOWN :
			IF ((wParam & 0xFF) = 27) THEN			' close on escape key
				ExitDirectDraw (hWnd)
				DestroyWindow (hWnd)
			END IF

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

	ShowWindow (#winMain, $$SW_SHOWNORMAL)

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

' main message loop

	IF LIBRARY(0) THEN RETURN							' main program executes message loop

	DO																		' the message loop
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN		' grab a message
			IF msg.message = $$WM_QUIT THEN EXIT DO		' exit
			TranslateMessage (&msg)						' translate virtual-key messages into character messages
			DispatchMessageA (&msg)						' send message to window callback function WndProc()
		ELSE
			DrawNextFrame ()									' draw starfield frame
			Sleep (50)												' slow it down
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

	SHARED pDD, lpPrimary, lpBackBuffer
	GUID iid
	DDSURFACEDESC2 ddsd

' Initialise DirectDraw and go to full screen mode.

' Create an IDirectDraw7 object.
	XLONGAT (&&iid) = &$$IID_IDirectDraw7
	hr = XddDirectDrawCreateEx (NULL, &pDD, &iid, NULL)
'	DirectDrawCreateEx(NULL, &pDD, IID_IDirectDraw7, NULL)

	IF hr < 0 THEN
		PRINT "Error : InitDirectDraw : XddDirectDrawCreateEx"
		RETURN ($$TRUE)
	END IF

	hr = IDirectDraw_SetCooperativeLevel (pDD, hWnd, $$DDSCL_FULLSCREEN | $$DDSCL_EXCLUSIVE | $$DDSCL_ALLOWREBOOT)

	IF hr < 0 THEN
		PRINT "Error : InitDirectDraw : SetCooperativeLevel"
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

' Set screen resolution, first - 640x480, 16-bit colour.

	hr = IDirectDraw_SetDisplayMode (pDD, 640, 480, 16, 0, 0)

	IF hr < 0 THEN
		PRINT "Error : InitDirectDraw : SetDisplayMode"
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

	ddsd.dwSize = SIZE (ddsd)
	ddsd.dwFlags = $$DDSD_CAPS | $$DDSD_BACKBUFFERCOUNT
	ddsd.ddsCaps.dwCaps = $$DDSCAPS_PRIMARYSURFACE | $$DDSCAPS_FLIP | $$DDSCAPS_COMPLEX
	ddsd.dwBackBufferCount = 2

	hr = IDirectDraw_CreateSurface (pDD, &ddsd, &lpPrimary, NULL)

	IF hr < 0 THEN
		PRINT "Error : InitDirectDraw : CreateSurface"
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

	ddsd.ddsCaps.dwCaps = $$DDSCAPS_BACKBUFFER
	hr = IDirectDrawSurface_GetAttachedSurface (lpPrimary, &ddsd.ddsCaps, &lpBackBuffer)

	IF hr < 0 THEN
		PRINT "Error : InitDirectDraw : GetAttachedSurface"
		IDirectDraw_Release (lpPrimary)
		IDirectDraw_Release (pDD)
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
'
' ###############################
' #####  ExitDirectDraw ()  #####
' ###############################
'
FUNCTION  ExitDirectDraw (hWnd)

	SHARED pDD, lpPrimary

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
' ####################
' #####  Rnd ()  #####
' ####################
'
FUNCTION  DOUBLE Rnd ()

	STATIC entry

	IFZ entry THEN GOSUB Initialize

	RETURN rand() / 32767.0


' ***** Initialize *****
SUB Initialize
	entry = $$TRUE

' initialize random number generator
	seed = (GetTickCount () MOD 32767) + 1
	srand (seed)

END SUB


END FUNCTION
'
'
' ##############################
' #####  DrawNextFrame ()  #####
' ##############################
'
FUNCTION  DrawNextFrame ()

	SHARED pDD, lpPrimary, lpBackBuffer
	RECT r
	DDBLTFX fx
	SHARED resolutionX, resolutionY, numStars
	SHARED TSTAR stars[]
	SHARED active

	IF (lpPrimary == NULL) THEN RETURN

	IF active THEN

' clear the back buffer
		fx.dwSize = SIZE (fx)
		fx.dwFillColor = RGB (0, 0, 0)

		r.top    = 0
		r.left   = 0
		r.bottom = resolutionY
		r.right  = resolutionX

' ddsBack.Blt t, Nothing, t, DDBLT_COLORFILL, fx
		hr = IDirectDrawSurface_Blt (lpBackBuffer, &r, NULL, &r, $$DDBLT_COLORFILL, &fx)

' plot the stars (get and release the backbuffer DC)
		hr = IDirectDrawSurface_GetDC (lpBackBuffer, &hDC)

		IF hr = 0 THEN
			FOR i = 0 TO numStars-1
				SetPixelV (hDC, resolutionX \ 2.0 + stars[i].x, resolutionY \ 2.0 + stars[i].y, RGB(stars[i].color, stars[i].color, stars[i].color))
			NEXT i
			hr = IDirectDrawSurface_ReleaseDC (lpBackBuffer, hDC)
		END IF

' restore surface
		hr = IDirectDrawSurface_Restore (lpPrimary)

' flip the buffers
		hr = IDirectDrawSurface_Flip (lpPrimary, NULL, 0)

' prepare the stars for the next frame
		FOR i = 0 TO numStars-1
			stars[i].x = stars[i].x * 1.2
			stars[i].y = stars[i].y * 1.2
			stars[i].color = stars[i].color * 1.2
			IF stars[i].color > 255 THEN stars[i].color = 255

			IF (ABS(stars[i].x) > resolutionX \ 2.0) || (ABS(stars[i].y) > resolutionY \ 2.0) THEN
				stars[i].x = Rnd() * resolutionX \ 2.0 - resolutionX \ 4.0
				stars[i].y = Rnd() * resolutionY \ 2.0 - resolutionY \ 4.0
				stars[i].color = Rnd() * 20 + 50
			END IF

		NEXT i

		Sleep (0)

	ELSE
		Sleep (1)
	END IF

' Use ALT-F4 to exit.

END FUNCTION
END PROGRAM
