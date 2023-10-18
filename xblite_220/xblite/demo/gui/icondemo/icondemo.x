'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo illustrates drawing system and
' resource icons. Resource icons are added
' to the program resource file icondemo.rc.

' Note that the icon associated with your
' program .exe is going to be the resource icon
' which is the lowest in alphanumeric order,
' and NOT the first listed icon.

' The demo also creates static and button control
' icons, and it shows how to extract and draw icons
' from .exe or .dll files.
'
PROGRAM	"icondemo"
VERSION	"0.0004"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
  IMPORT  "xsx"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"		' shell32.dll"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  DisplayIcon (hWnd, iconName$, iconID, x, y)
DECLARE FUNCTION  CreateStaticIcon (hWnd, iconName$, x, y)
DECLARE FUNCTION  DisplayExtractedIcon (hWnd, fileName$, iconIndex, x, y)
DECLARE FUNCTION  CreateButtonIcon (hWnd, iconName$, iconID, x, y, w, h, controlID)
DECLARE FUNCTION  CreateLabel (hWnd, label$, x, y, id)
DECLARE FUNCTION  SetCtlColor (hDC, txtColor, bkColor)

'Control IDs

$$Button1 = 110
$$Button2 = 111
$$Button3 = 112
$$Button4 = 113

$$Label1 = 120
$$Label2 = 121
$$Label3 = 122
$$Label4 = 123
$$Label5 = 124
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
	RECT wRect
	SHARED hInst

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_CTLCOLORSTATIC :				' change the background color of control
			hDCStatic = wParam
			hWndStatic = lParam
			bkColor = GetSysColor ($$COLOR_BTNFACE)
			SELECT CASE hWndStatic
				CASE #hLabel1, #hLabel2, #hLabel3, #hLabel4, #hLabel5 :
					RETURN SetCtlColor (hDCStatic, -1, bkColor)
			END SELECT

			CASE $$WM_PAINT:
				hDC = BeginPaint (hWnd, &ps)

' display system icons
				hIcon1 = DisplayIcon (#winMain, "", $$IDI_APPLICATION, 	20,  100)
				hIcon2 = DisplayIcon (#winMain, "", $$IDI_ASTERISK,  		60,  100)
				hIcon3 = DisplayIcon (#winMain, "", $$IDI_EXCLAMATION, 	100, 100)
				hIcon4 = DisplayIcon (#winMain, "", $$IDI_HAND, 				140, 100)
				hIcon5 = DisplayIcon (#winMain, "", $$IDI_QUESTION, 		180, 100)
				hIcon6 = DisplayIcon (#winMain, "", $$IDI_WINLOGO, 			220, 100)

' display resource icons
				hIcon7  = DisplayIcon (#winMain, "scrabble", 0, 20,  160)
				hIcon8  = DisplayIcon (#winMain, "window",   0, 60,  160)
				hIcon9  = DisplayIcon (#winMain, "launch",   0, 100, 160)
				hIcon10 = DisplayIcon (#winMain, "science",  0, 140, 160)

' extract icons from an .exe file and display them
'				fileName$ = "c:/program files/accessories/wordpad.exe"
        fileName$ = "c:/program files/accessories/mspaint.exe"
        XstGetFileAttributes (filename$, @attributes)
        IFZ attributes THEN
				  fileName$ = "c:/winnt/system32/mspaint.exe"
				END IF

				x = 20
				FOR i = 0 TO 5
					DisplayExtractedIcon (#winMain, fileName$, i, x,  220)
					x = x + 40
				NEXT i

				EndPaint (hWnd, &ps)


		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					text$ = "You clicked on button " + STRING$(id)
					MessageBoxA (hWnd, &text$, &"Icon Button Test", 0)

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

	SHARED className$

' register window class
	className$  = "IconDemo"
	addrWndProc = &WndProc()
	icon$ 			= ""
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Icon Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 280
	h 					= 375
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create static icon controls
	#hStatic1 = CreateStaticIcon (#winMain, "scrabble", 20,  40)
	#hStatic2 = CreateStaticIcon (#winMain, "window"  , 60,  40)
	#hStatic3 = CreateStaticIcon (#winMain, "launch"  , 100, 40)
	#hStatic4 = CreateStaticIcon (#winMain, "science" , 140, 40)

' create button icon controls from resource or from system icons
' get size of default icon, but the button can be any size desired
	w = GetSystemMetrics ($$SM_CXICON)
	h = GetSystemMetrics ($$SM_CYICON)
	#hButton1 = CreateButtonIcon (#winMain, "scrabble", 0,              20,  280, w, h, $$Button1)
	#hButton2 = CreateButtonIcon (#winMain, "science",  0,              60,  280, w, h, $$Button2)
	#hButton3 = CreateButtonIcon (#winMain, "",         $$IDI_HAND,     100, 280, w, h, $$Button3)
	#hButton4 = CreateButtonIcon (#winMain, "",         $$IDI_QUESTION, 140, 280, w, h, $$Button4)

' create some text labels
	#hLabel1 = CreateLabel (#winMain, "Create static control icons",	20, 20,  $$Label1)
	#hLabel2 = CreateLabel (#winMain, "Draw system icons", 						20, 80,  $$Label2)
	#hLabel3 = CreateLabel (#winMain, "Draw resource icons",					20, 140, $$Label3)
	#hLabel4 = CreateLabel (#winMain, "Draw extracted icons",					20, 200, $$Label4)
	#hLabel5 = CreateLabel (#winMain, "Create button control icons",	20, 260, $$Label5)

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
' ############################
' #####  DisplayIcon ()  #####
' ############################
'
FUNCTION  DisplayIcon (hWnd, iconName$, iconID, x, y)

	SHARED hInst
	IFZ hWnd THEN RETURN
	hDC = GetDC (hWnd)
	IFZ hDC THEN RETURN
	IFZ iconName$ THEN
		hIcon = LoadIconA (0, iconID)						' load system icon
	ELSE
		id = XLONG(iconName$)
		IF id THEN
			hIcon = LoadIconA (hInst, id)					' load icon resource using numeric id
		ELSE
			hIcon = LoadIconA (hInst, &iconName$)	' load icon resource using string id
		END IF
	END IF
	IFT hIcon THEN
		ret = DrawIcon (hDC, x, y, hIcon)
	END IF
	ReleaseDC (hWnd, hDC)
	IFT ret THEN RETURN hIcon
	RETURN

END FUNCTION
'
'
' #################################
' #####  CreateStaticIcon ()  #####
' #################################

' PURPOSE : CreateStaticIcon() creates a "static" child window control
'           which displays a resource iconat location x, y in parent
'           window hWnd.
'           iconName$ is the resource icon name
'						example resource line:
'						window    ICON   "awindow.ico"
'           thus, iconName$ = "window"
' RETURN  : handle to static control
'
FUNCTION  CreateStaticIcon (hWnd, iconName$, x, y)

	SHARED hInst

' create child static icon control
	style = $$SS_ICON | $$WS_CHILD | $$WS_VISIBLE
	hStatic = CreateWindowExA (0, &"static", &iconName$, style, x, y, 0, 0, hWnd, 0, hInst, 0)
	RETURN hStatic
END FUNCTION
'
'
' #####################################
' #####  DisplayExtractedIcon ()  #####
' #####################################
'
FUNCTION  DisplayExtractedIcon (hWnd, fileName$, iconIndex, x, y)

	SHARED hInst
	IFZ hWnd THEN RETURN
	IFZ fileName$ THEN RETURN
	hDC = GetDC (hWnd)
	IFZ hDC THEN RETURN
	iconCount = ExtractIconA (hInst, &fileName$, -1)
	IFZ iconCount THEN RETURN
	IF iconIndex > iconCount THEN RETURN
	hIcon = ExtractIconA (hInst, &fileName$, iconIndex)
	IFT hIcon THEN
		ret = DrawIcon (hDC, x, y, hIcon)
	END IF
	ReleaseDC (hWnd, hDC)
	IFT ret THEN RETURN hIcon
	RETURN


END FUNCTION
'
'
' #################################
' #####  CreateButtonIcon ()  #####
' #################################

' PURPOSE : CreateButtonIcon() creates a "button" child window control
'           which displays a resource or system icon at location x, y
'           in parent window hWnd. ID is the control ID number.
'           iconName$ is the resource icon name. Button size is w x h.
'						example resource line:
'						window    ICON   "awindow.ico"
'           thus, iconName$ = "window"
' RETURN  : handle to button control
'
FUNCTION  CreateButtonIcon (hWnd, iconName$, iconID, x, y, w, h, controlID)

	SHARED hInst

	IFZ iconName$ THEN								' load system icon
		hIcon = LoadIconA (0, iconID)
	ELSE															' load resource icon
		hIcon = LoadIconA (hInst, &iconName$)
	END IF
	IFZ hIcon THEN RETURN

' create child button icon control
	style = $$BS_PUSHBUTTON | $$BS_ICON | $$WS_CHILD | $$WS_VISIBLE
	text$ = ""			' note: don't directly pass a null address like this &""
	hButton = CreateWindowExA (0, &"button", &text$, style, x, y, w, h, hWnd, controlID, hInst, 0)
	IFZ hButton THEN RETURN

	IFT hIcon THEN
		SendMessageA (hButton, $$BM_SETIMAGE, $$IMAGE_ICON, hIcon)
		RETURN hButton
	ELSE
		DestroyWindow (hButton)
		RETURN
	END IF

END FUNCTION
'
'
' ############################
' #####  CreateLabel ()  #####
' ############################
'
FUNCTION  CreateLabel (hWnd, label$, x, y, id)
	SIZEAPI size
	SHARED hInst
	IFZ hWnd THEN RETURN
	hDC = GetDC (hWnd)
	IFZ hDC THEN RETURN
	GetTextExtentPoint32A (hDC, &label$, LEN(label$), &size)
	w = size.cx
	h = size.cy
' create child static icon control
	style = $$SS_LEFT | $$WS_CHILD | $$WS_VISIBLE
	hStatic = CreateWindowExA (0, &"static", &label$, style, x, y, w, h, hWnd, id, hInst, 0)
	ReleaseDC (hWnd, hDC)
	RETURN hStatic
END FUNCTION
'
'
' ############################
' #####  SetCtlColor ()  #####
' ############################
'
'PURPOSE : Set a control text or back color.
'          A value of -1 for txtColor or bkColor retains current color
'          The colors must be MS color values. USE RGB() to create cv.
'
FUNCTION  SetCtlColor (hDC, txtColor, bkColor)
	STATIC hNewBrush

	IF txtColor != -1 THEN								' set text color
		ret = SetTextColor (hDC, txtColor)
	END IF

	IF bkColor = -1 THEN									' set background color and brush
		bkColor = GetBkColor (hDC)
		hNewBrush = CreateSolidBrush(bkColor)
	ELSE
		DeleteObject (hNewBrush)
		hNewBrush = CreateSolidBrush(bkColor)
		ret = SetBkColor (hDC, bkColor)
	END IF

	RETURN hNewBrush

END FUNCTION
END PROGRAM
