'
'
' ####################
' #####  PROLOG  #####
' ####################

' The following example uses CreateIcon to
' create a custom icon at run-time,
' based on bitmap bitmasks. It illustrates
' how the system interprets icon bitmap bitmasks.
' To create the icon, CreateIcon applies the
' following truth table to the AND and XOR bitmasks.
' ===
' AND bitmask	 XOR bitmask	Display
'  0	          0	           Black
'  0	          1	           White
'  1	          0	           Screen
'  1	          1	           Reverse screen
'
' === refer to the following URL ===
' http://msdn.microsoft.com/library/default.asp?
' url=/library/en-us/winui/WinUI/WindowsUserInterface
' /Resources/Icons/UsingIcons.asp
'
PROGRAM	"createicon"
VERSION	"0.0002"
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
$$TextBox1 = 102
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
	STATIC UBYTE ANDMaskIcon[127]
	STATIC UBYTE XORMaskIcon[127]
	SHARED hInst
	STATIC hIcon


	SELECT CASE msg

		CASE $$WM_CREATE:
' create new icon at run-time
			GOSUB CreateNewIcon

' change the icon for hWnd's window class

			SetClassLongA (hWnd, $$GCL_HICON, hIcon)

		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)
  		DrawIcon (hdc, 50, 50, hIcon)
			text$ = "Voila! The Icon."
  		TextOutA (hdc, 10, 10, &text$, LEN (text$))
			EndPaint (hWnd, &ps)


		CASE $$WM_DESTROY:
			PostQuitMessage(0)

		CASE ELSE:
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** CreateNewIcon *****
SUB CreateNewIcon

' Yang icon AND bitmask

  abm$ = "\xFF\xFF\xFF\xFF"						' line 1
  abm$ = abm$ + "\xFF\xFF\xC3\xFF"		' line 2
  abm$ = abm$ + "\xFF\xFF\x00\xFF"
  abm$ = abm$ + "\xFF\xFE\x00\x7F"
  abm$ = abm$ + "\xFF\xFC\x00\x1F"
  abm$ = abm$ + "\xFF\xF8\x00\x0F"
  abm$ = abm$ + "\xFF\xF8\x00\x0F"
  abm$ = abm$ + "\xFF\xF0\x00\x07"
  abm$ = abm$ + "\xFF\xF0\x00\x03"
  abm$ = abm$ + "\xFF\xE0\x00\x03"
  abm$ = abm$ + "\xFF\xE0\x00\x01"
  abm$ = abm$ + "\xFF\xE0\x00\x01"
  abm$ = abm$ + "\xFF\xF0\x00\x01"
  abm$ = abm$ + "\xFF\xF0\x00\x00"
  abm$ = abm$ + "\xFF\xF8\x00\x00"
  abm$ = abm$ + "\xFF\xFC\x00\x00"
  abm$ = abm$ + "\xFF\xFF\x00\x00"
  abm$ = abm$ + "\xFF\xFF\x80\x00"
  abm$ = abm$ + "\xFF\xFF\xE0\x00"
  abm$ = abm$ + "\xFF\xFF\xE0\x01"
  abm$ = abm$ + "\xFF\xFF\xF0\x01"
  abm$ = abm$ + "\xFF\xFF\xF0\x01"
  abm$ = abm$ + "\xFF\xFF\xF0\x03"
  abm$ = abm$ + "\xFF\xFF\xE0\x03"
  abm$ = abm$ + "\xFF\xFF\xE0\x07"
  abm$ = abm$ + "\xFF\xFF\xC0\x0F"
  abm$ = abm$ + "\xFF\xFF\xC0\x0F"
  abm$ = abm$ + "\xFF\xFF\x80\x1F"
  abm$ = abm$ + "\xFF\xFF\x00\x7F"
  abm$ = abm$ + "\xFF\xFC\x00\xFF"
  abm$ = abm$ + "\xFF\xF8\x03\xFF"
  abm$ = abm$ + "\xFF\xFC\x3F\xFF"		' line 32

'	Yang icon XOR bitmask

	xbm$ = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x38\x00\x00\x00\x7C\x00\x00\x00\x7C\x00\x00\x00\x7C\x00\x00\x00\x38\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

	FOR i = 0 TO 127
		ANDMaskIcon[i] = abm${i}
		XORMaskIcon[i] = xbm${i}
	NEXT

  hIcon = CreateIcon (hInst, 32, 32, 1, 1, &ANDMaskIcon[], &XORMaskIcon[])
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
	wc.hbrBackground   = GetStockObject ($$WHITE_BRUSH)
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

	SHARED hInst, className$

' register window class
	className$  = "UsingIconsDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Creating an Icon Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 240
	h 					= 160
	#winMain 		= NewWindow (className$, titleBar$, style, x, y, w, h, 0)

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

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

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

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
	UnregisterClassA (&className$, hInst)

END FUNCTION
END PROGRAM
