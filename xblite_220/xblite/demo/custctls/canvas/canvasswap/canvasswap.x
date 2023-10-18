'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates the use of the canvas.dll
' custom image/graphics scrolling control. It swaps two
' images in the control.
'
PROGRAM	"canvasswap"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "canvas"		' canvas.dll 	Canvas control
	IMPORT	"xbm"				' xbm.dll 	Bitmap library
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
'
' Control IDs
'
$$Canvas1 = 100
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
	UBYTE pinky[], buckaroo[]
	STATIC fPinky

	SELECT CASE msg

		CASE $$WM_CREATE :
' create canvas control
' NOTE: do NOT use any window border styles like WS_BORDER or exStyles like WS_EX_CLIENTEDGE
			GetClientRect (hWnd, &rect)
			#hCanvas1 = NewChild ($$CANVASCLASSNAME, "", style, 0, 0, rect.right, rect.bottom, hWnd, $$Canvas1, 0)

			XbmLoadImage ("/xblite/images/pinky.bmp", @pinky[])										' load bmp image from file into an image array
			XbmGetImageArrayInfo (@pinky[], @bpp, @w, @h)						' get w, h
			XbmCreateMemBitmap (hWnd, w, h, @#hPinky)								' create memory bitmap
			XbmSetImage (#hPinky, @pinky[])													' set image array into memory bitmap

			XbmLoadImage ("/xblite/images/buckaroo.bmp", @buckaroo[])									' load 2nd bmp image from file into an image array
			XbmGetImageArrayInfo (@buckaroo[], @bpp, @w, @h)						' get w, h
			XbmCreateMemBitmap (hWnd, w, h, @#hBuckaroo)								' create 2nd memory bitmap
			XbmSetImage (#hBuckaroo, @buckaroo[])												' set image array into memory bitmap

			SendMessageA (#hCanvas1, $$WM_SET_CANVAS_IMAGE, 0, #hPinky)	' display pinky
			fPinky = $$TRUE																							' pinky is on

			SetTimer (hWnd, 1, 3000, NULL)		' create a timer event to swap images

		CASE $$WM_DESTROY :
			XbmDeleteMemBitmap (#hPinky)
			XbmDeleteMemBitmap (#hBuckaroo)
			KillTimer (hWnd, 1)
			PostQuitMessage(0)

		CASE $$WM_TIMER :
			IF fPinky THEN
				fPinky = $$FALSE
				SendMessageA (#hCanvas1, $$WM_SET_CANVAS_IMAGE, 0, #hBuckaroo)
			ELSE
				fPinky = $$TRUE
				SendMessageA (#hCanvas1, $$WM_SET_CANVAS_IMAGE, 0, #hPinky)
			END IF

		CASE $$WM_SIZE :
			width = LOWORD(lParam)
			height = HIWORD (lParam)
			SetWindowPos (#hCanvas1, 0, 0, 0, width, height, $$SWP_NOZORDER)

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

	SHARED className$

' register window class
	className$  = "CanvasSwapDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Canvas Control - Swapping Images Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 300
	h 					= 200
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
END PROGRAM
