'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of drawing a sprite (masked bitmap)
' using Xbm function XbmDrawMaskedImage.
'
PROGRAM	"spritedemo"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "xbm"       ' Bitmap Image Library xbm.dll
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
DECLARE FUNCTION  RenderSprite (hWnd)
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
	SHARED UBYTE pinky[], lmask[], lama2[]
	RECT rc
	PAINTSTRUCT ps
	SHARED width, height

	SELECT CASE msg

		CASE $$WM_CREATE :

' load bmp images from resource
			XbmLoadBitmap ("lama2", @lama2[])
			XbmLoadBitmap ("lamamask", @lmask[])
			XbmLoadBitmap ("pinky", @pinky[])

' get bmp images width & height
			XbmGetImageArrayInfo (@lama2[], @bitsPerPixel, @width, @height)
			XbmGetImageArrayInfo (@pinky[], @bitsPerPixel, @wp, @hp)

' create memory bitmaps
			XbmCreateMemBitmap (hWnd, width, height, @#hlama2)
			XbmCreateMemBitmap (hWnd, width, height, @#hlmask)
			XbmCreateMemBitmap (hWnd, wp, hp, @#hpinky)

' set bitmaps into memory bitmap
			XbmSetImage (#hpinky, @pinky[])
			XbmSetImage (#hlama2, @lama2[])
			XbmSetImage (#hlmask, @lmask[])

		CASE $$WM_SIZE :
			w = LOWORD (lParam)
			h = HIWORD (lParam)
			IF #hscrn THEN XbmDeleteMemBitmap (#hscrn)
			XbmCreateMemBitmap (hWnd, w, h, @#hscrn)

		CASE $$WM_DESTROY :
			XbmDeleteMemBitmap (#hpinky)
			XbmDeleteMemBitmap (#hlmask)
			XbmDeleteMemBitmap (#hlama2)
			XbmDeleteMemBitmap (#hscrn)
			PostQuitMessage(0)

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
	hInst = GetModuleHandleA (0)	' get current instance handle
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

	SHARED className$, hInst

' register window class
	className$  = "SpriteDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Sprite Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 640
	h 					= 480
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

	MSG msg

	DO
		hwnd = GetActiveWindow ()
		IF PeekMessageA (&msg, NULL, 0, 0, $$PM_REMOVE) THEN
			IF msg.message = $$WM_QUIT THEN EXIT DO
			IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
				TranslateMessage (&msg)
				DispatchMessageA (&msg)
			END IF
		ELSE
			IF IsWindow (hwnd) THEN
				RenderSprite (hwnd)
			ELSE
				Sleep (0)
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
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, @text$, style, x, y, w, h, parent, id, exStyle)
	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' #############################
' #####  RenderSprite ()  #####
' #############################
'
FUNCTION  RenderSprite (hWnd)

	POINT p
	RECT rc
	SHARED width, height

' move a sprite around using the current mouse position
	GetCursorPos (&p)
	ScreenToClient (hWnd, &p)
	GetClientRect (hWnd, &rc)

' draw background image to screen buffer
	XbmDrawImageEx (#hscrn, #hpinky, 0, 0, -1, -1, 0, 0, rc.right, rc.bottom, 0, 0)

' draw sprite to screen buffer
	XbmDrawMaskedImage (#hscrn, #hlama2, 0, 0, width, height, p.x-width+18, p.y-height+14, #hlmask, 0, 0)

' repaint window
	XbmDrawImage (hWnd, #hscrn, 0, 0, rc.right, rc.bottom, 0, 0)


END FUNCTION
END PROGRAM
