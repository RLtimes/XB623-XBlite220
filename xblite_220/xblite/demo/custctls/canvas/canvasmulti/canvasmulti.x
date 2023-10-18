'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates the use of the
' canvas.dll custom image/graphics scrolling
' control. This example displays two controls,
' one contains a bmp image, the other displays
' graphics.
'
PROGRAM	"canvasmulti"
VERSION	"0.0002"

'	IMPORT	"xst"   		' Standard library	: required by most programs
'	IMPORT  "canvas"		' canvas.dll 				: Canvas control
'	IMPORT	"xbm"				' xbm.dll						: Bitmap library
	IMPORT  "xma.dec"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "msvcrt"

	IMPORT  "xst_s.lib"
	IMPORT  "canvas_s.lib"  ' make sure to call Canvas() from InitGui()
	IMPORT  "xbm_s.lib" '
'	IMPORT  "xst.dec"
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
DECLARE FUNCTION  GetImageType (hImage)
DECLARE FUNCTION  Line (hDC, x1, y1, x2, y2)
'
' Control IDs
'
$$Canvas1 = 100
$$Canvas2 = 101
'
'
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
	UBYTE pinky[]

	SELECT CASE msg

		CASE $$WM_CREATE :
' create 1st canvas control
' NOTE: do NOT use any window border styles like WS_BORDER or exStyles like WS_EX_CLIENTEDGE
			GetClientRect (hWnd, &rect)
			style = $$WS_TABSTOP
			#hCanvas1 = NewChild ($$CANVASCLASSNAME, "", style, 0, 0, rect.right/2, rect.bottom, hWnd, $$Canvas1, 0)

			XbmLoadImage ("/xblite/images/pinky.bmp", @pinky[])										' load bmp image from file into an image array
			XbmGetImageArrayInfo (@pinky[], @bpp, @w, @h)						' get w, h
			XbmCreateMemBitmap (hWnd, w, h, @#hImage)								' create memory bitmap
			XbmSetImage (#hImage, @pinky[])													' set image array into memory bitmap
			SendMessageA (#hCanvas1, $$WM_SET_CANVAS_IMAGE, 0, #hImage)	' display memory bitmap in canvas control

' create 2nd canvas control
			#hCanvas2 = NewChild ($$CANVASCLASSNAME, "", style, rect.right/2, 0, rect.right/2, rect.bottom, hWnd, $$Canvas2, 0)

			wndDC 		= GetDC (hWnd)
			#hdc 			= CreateCompatibleDC (wndDC)							' create memory device context
			#hGraphic = CreateCompatibleBitmap (wndDC, 400, 400)' create memory bitmap 400x400 for drawing graphics
			ReleaseDC (hWnd, wndDC)

			lastObj = SelectObject (#hdc, #hGraphic)					' select memory bitmap into memory dc
			GOSUB DrawSomething																' draw some stuff into memory dc
			SelectObject (#hdc, lastObj)											' select old memory bitmap into dc
			DeleteDC (#hdc)																		' delete the dc
			SendMessageA (#hCanvas2, $$WM_SET_CANVAS_IMAGE, 0, #hGraphic)	' display memory bitmap in canvas control

		CASE $$WM_DESTROY :
			XbmDeleteMemBitmap (#hImage)
			DeleteObject (#hGraphic)
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			width = LOWORD(lParam)
			height = HIWORD (lParam)
			SetWindowPos (#hCanvas1, 0, 0, 0, width/2, height, $$SWP_NOZORDER)
			SetWindowPos (#hCanvas2, 0, width/2, 0, width/2, height, $$SWP_NOZORDER)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** DrawSomething *****
SUB DrawSomething
' draw a "Rose" pattern by drawing lines from points chosen
' along the edge of a circle and then drawing a line from each point to
' every other point on the circle.
'
' fill bitmap with solid color
	hBrush = CreateSolidBrush (RGB(232, 240, 60))
	hOldBrush = SelectObject (#hdc, hBrush)
	PatBlt (#hdc, 0, 0, 400, 400, $$PATCOPY)
	SelectObject (#hdc, hOldBrush)
	DeleteObject (hBrush)
'
' no of points on circle
	points = 24

' radius of circle
	r = 190

	DIM pointsX [points-1]
	DIM pointsY [points-1]
	
' calculate points
	FOR i = 0 TO points-1
 		angle# = (360.0 / points) * i
'		pointsX[i] = 200 + (r * Cos((angle# - 90) * $$DEGTORAD))
'		pointsY[i] = 200 + (r * Sin((angle# - 90) * $$DEGTORAD))
		pointsX[i] = 200 + (r * cos((angle# - 90) * $$DEGTORAD))
		pointsY[i] = 200 + (r * sin((angle# - 90) * $$DEGTORAD))
	NEXT i

' create a solid colored pen
	hPen = CreatePen ($$PS_SOLID, 1, RGB(255, 0, 0))
	hOldPen = SelectObject (#hdc, hPen)

' draw some lines
	FOR i = 0 TO points-1
 		FOR j = i + 1 TO points - 2
			Line (#hdc, pointsX[i], pointsY[i], pointsX[j], pointsY[j])
 		NEXT j
	NEXT i

	SelectObject (#hdc, hOldPen)
	DeleteObject (hPen)
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
	
' For static libraries, you must initialize the first function in library
	Canvas ()
	
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
	className$  = "MultiCanvasDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Multiple Canvas Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 600
	h 					= 300
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
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
	hwnd = CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)
	RETURN hwnd

END FUNCTION
'
'
' #############################
' #####  GetImageType ()  #####
' #############################
'
' Determine if a handle is for a screen image (window handle)
' or for a memory image (bitmap object handle)
'
' In: 		hImage		handle to window or hbitmap object
' Return:						image type or zero (invalid handle)
'
' image type constants
'		$$IMAGE_SCREEN = 1		handle is a valid windows handle
'		$$IMAGE_MEMORY = 2		handle is a valid bitmap object handle (memory bitmap)
'
'
FUNCTION  GetImageType (hImage)

	SELECT CASE TRUE
		CASE IsWindow (hImage) 											: RETURN $$IMAGE_SCREEN
		CASE GetObjectType (hImage) = $$OBJ_BITMAP 	: RETURN $$IMAGE_MEMORY
		CASE ELSE 																	: RETURN 0
	END SELECT


END FUNCTION
'
'
' #####################
' #####  Line ()  #####
' #####################
'
FUNCTION  Line (hDC, x1, y1, x2, y2)

	MoveToEx (hDC, x1, y1, 0)
	LineTo (hDC, x2, y2)

END FUNCTION
END PROGRAM
