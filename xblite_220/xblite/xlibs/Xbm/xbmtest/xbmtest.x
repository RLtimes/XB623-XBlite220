'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A test of using functions in Xbm, an XBLite
' bitmap library.
'
PROGRAM	"xbmtest"
VERSION	"0.0002"
'
	IMPORT	"xst"   ' Standard library : required by most programs
'	IMPORT	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll/riched32.dll/riched20.dll
	IMPORT  "shell32"		' shell32.dll
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

'Control IDs

$$Button1  = 100
$$Button2  = 101
$$Button3  = 102
$$Button4  = 103
$$Button5  = 104
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
	SHARED UBYTE lama[]
	SHARED UBYTE qp[]
	SHARED cdir$
	UBYTE screen[]

	SELECT CASE msg

		CASE $$WM_DESTROY :
			XbmDeleteMemBitmap (#hqp)
			XbmDeleteMemBitmap (#hlmask)
			XbmDeleteMemBitmap (#hlama2)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID  = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode

				CASE $$BN_CLICKED :
					SELECT CASE controlID
						CASE $$Button1 :	XbmSetImage (#winMain, @lama[])
						CASE $$Button2 :	XbmDrawImage (#winMain, #hqp, 0, 0, -1, -1, 5, 90)
						CASE $$Button3 :	XbmDrawImageEx (#winMain, #winMain, 0, 0,  78,  78,   5, 180,      45,     220, fRop, 0)
															XbmDrawImageEx (#winMain, #winMain, 0, 0,  78,  78,  55, 180,     175,     300, fRop, 1)
															XbmDrawImageEx (#winMain, #hqp,     0, 0,  -1,  -1, 190, 180,  190+78,  180+78, $$NOTSRCCOPY, 2)
															XbmDrawImageEx (#winMain, #winMain, 0, 0, 273, 300, 280,  10, 280+180, 	10+200, fRop, 3)
						CASE $$Button4 :	XbmDrawImage (#winMain, #hlama2, 0, 0, -1, -1, 290, 225)
															XbmDrawImage (#winMain, #hlmask, 0, 0, -1, -1, 375, 225)
															XbmDrawMaskedImage (#winMain, #hlama2, 0, 0, -1, -1, 460, 225, #hlmask, 0, 0)
						CASE $$Button5 :	XbmGetImage (#winMain, @screen[])
															XbmSaveImage (cdir$+"/screen.bmp", @screen[])
					END SELECT
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
	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)
	InitCommonControls()					' initialize comctl32.dll library

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
	SHARED UBYTE lama[]
	SHARED UBYTE qp[]
	SHARED UBYTE lmask[]
	SHARED UBYTE lama2[]
	SHARED cdir$

' register window class
	className$  = "BitmapDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Bitmap Library Demo."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 540
	h 					= 340
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

'	cdir$ = NULL$(255)
'	GetCurrentDirectoryA (LEN(cdir$), &cdir$)
'	cdir$ = CSIZE$(cdir$)

'	cdir$ = "c:/xblite/images/"
	cdir$ = "/xblite/images"

' load bmp image from file
	lama$ = cdir$ + "/lama.bmp"
	ret = XbmLoadImage (lama$, @lama[])

' load bmp image from file
	qp$ = cdir$ + "/queen_pope.bmp"
	ret = XbmLoadImage (qp$, @qp[])

' load bmp image from resource
	XbmLoadBitmap ("lama2",  @lama2[])

' load bmp image from resource
	XbmLoadBitmap ("lamamask",  @lmask[])

' get bmp image info
	XbmGetImageArrayInfo (@lama[], @bitsPerPixel, @width, @height)

' create a memory bitmap for queen_pope.bmp
	XbmCreateMemBitmap (#winMain, width, height, @#hqp)

' set queen_pope.bmp into memory bitmap
	ret = XbmSetImage (#hqp, @qp[])

' create a memory bitmap for lama2.bmp
	XbmCreateMemBitmap (#winMain, width, height, @#hlama2)

' set lama2.bmp into memory bitmap
	ret = XbmSetImage (#hlama2, @lama2[])

' create a memory bitmap for lamamask.bmp
	XbmCreateMemBitmap (#winMain, width, height, @#hlmask)

' set lamamask.bmp into memory bitmap
	ret = XbmSetImage (#hlmask, @lmask[])

' create buttons
	#button1 = NewChild ("button", "XbmSetImage", 				$$BS_PUSHBUTTON | $$WS_TABSTOP, 100,  10, 170, 24, #winMain, $$Button1, 0)
	#button2 = NewChild ("button", "XbmDrawImage", 				$$BS_PUSHBUTTON | $$WS_TABSTOP, 100,  45, 170, 24, #winMain, $$Button2, 0)
	#button3 = NewChild ("button", "XbmDrawImageEx", 			$$BS_PUSHBUTTON | $$WS_TABSTOP, 100,  80, 170, 24, #winMain, $$Button3, 0)
	#button4 = NewChild ("button", "XbmDrawMaskedImage", 	$$BS_PUSHBUTTON | $$WS_TABSTOP, 100, 115, 170, 24, #winMain, $$Button4, 0)
	#button5 = NewChild ("button", "XbmSaveImage", 				$$BS_PUSHBUTTON | $$WS_TABSTOP, 100, 150, 170, 24, #winMain, $$Button5, 0)

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
FUNCTION  NewChild (className$, @text$, style, x, y, w, h, parent, id, exStyle)
	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
END PROGRAM
