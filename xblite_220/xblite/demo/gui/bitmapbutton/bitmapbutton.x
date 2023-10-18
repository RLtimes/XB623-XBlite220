'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo show how to display a bitmap image on
' a push-button control.

PROGRAM	"bitmapbutton"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()

'Control IDs
$$Button1  = 101
$$Button2  = 102
$$Button3  = 103
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry

	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	IF CreateWindows ()	THEN QUIT (0)	' create windows and other child controls
	MessageLoop ()								' the main message loop
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

		CASE $$WM_DESTROY :
			DeleteObject (#hImage1)
			DeleteObject (#hImage2)
			DeleteObject (#hImage3)
			PostQuitMessage (0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					text$ = "You clicked on button " + STRING$(controlID)
					MessageBoxA (hWnd, &text$, &"Button Test", 0)
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

	hInst = GetModuleHandleA (0)		' get current instance handle
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
	SHARED hInst

' register window class
	className$  = "BitmapButtons"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Bitmap Button Controls."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 300
	h 					= 84
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' create and show various button class controls

	#button1 = NewChild ("button", "", $$BS_PUSHBUTTON | $$BS_BITMAP, 10, 10, 42, 42, #winMain, $$Button1, 0)
	#button2 = NewChild ("button", "", $$BS_PUSHBUTTON | $$BS_BITMAP, 52, 10, 42, 42, #winMain, $$Button2, 0)
	#button3 = NewChild ("button", "", $$BS_PUSHBUTTON | $$BS_BITMAP, 94, 10, 42, 42, #winMain, $$Button3, 0)

' load bitmap images from executable resource
	#hImage1 = LoadImageA (hInst, &"cut", $$IMAGE_BITMAP, 0, 0, 0)
	#hImage2 = LoadImageA (hInst, &"copy", $$IMAGE_BITMAP, 0, 0, 0)
	#hImage3 = LoadImageA (hInst, &"paste", $$IMAGE_BITMAP, 0, 0, 0)

' set bitmap images in button controls
	SendMessageA (#button1, $$BM_SETIMAGE, $$IMAGE_BITMAP, #hImage1)
	SendMessageA (#button2, $$BM_SETIMAGE, $$IMAGE_BITMAP, #hImage2)
	SendMessageA (#button3, $$BM_SETIMAGE, $$IMAGE_BITMAP, #hImage3)

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
END PROGRAM
