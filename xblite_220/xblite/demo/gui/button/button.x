'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo of various standard button controls; eg, push buttons,
' check boxes, radio buttons, and push-like radio buttons.
' You can use the Tab key to navigate between the controls.
'
PROGRAM	"button"
VERSION	"0.0003"

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
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)

'Control IDs
$$Button1  = 101
$$Button2  = 102
$$Button3  = 103

$$Radio1  = 110
$$Radio2  = 111
$$Radio3  = 112
$$Radio4  = 113
$$Radio5  = 114
$$Radio6  = 114

$$Check1  = 120
$$Check2  = 121
$$Check3  = 122
$$Check4  = 123
$$Check5  = 124

$$Group1  = 130
$$Group2  = 131
$$Group3  = 132
$$Group4  = 134
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
	IF CreateWindows () THEN QUIT (0)	' create windows and other child controls
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
			DeleteObject (#hFontArial)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					text$ = "You clicked on button " + STRING$(controlID)
					IF controlID > $$Button3 THEN
						state = SendMessageA(hwndCtl, $$BM_GETCHECK, 0, 0)
							SELECT CASE state
								CASE $$BST_CHECKED				: state$ = "checked"
								CASE $$BST_INDETERMINATE	: state$ = "indeterminate"
								CASE $$BST_UNCHECKED			: state$ = "unchecked"
							END SELECT
						text$ = text$ + ". Button state is " + state$ + "."
					END IF
					MessageBoxA (hWnd, &text$, &"Button Test", 0)
			END SELECT

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
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

' register window class
	className$  = "ButtonControls"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Button Controls."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 254
	h 					= 580
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

'create and show various button class controls

	#group1 = NewChild ("button", "Pushbuttons", $$BS_GROUPBOX, 10, 10, 220, 125, #winMain, $$Group1, 0)
	#group2 = NewChild ("button", "Checkboxes", $$BS_GROUPBOX, 10, 145, 220, 165, #winMain, $$Group2, 0)
	#group3 = NewChild ("button", "Radiobuttons", $$BS_GROUPBOX, 10, 320, 220, 100, #winMain, $$Group3, 0)
	#group4 = NewChild ("button", "Pushlike Radiobuttons", $$BS_GROUPBOX, 10, 430, 220, 110, #winMain, $$Group4, 0)

	#button1 = NewChild ("button", "Default Pushbutton", $$BS_DEFPUSHBUTTON | $$WS_TABSTOP, 20, 30, 200, 25, #winMain, $$Button1, 0)
	#button2 = NewChild ("button", "Pushbutton", $$BS_PUSHBUTTON | $$WS_TABSTOP, 20, 65, 200, 25, #winMain, $$Button2, 0)
	#button3 = NewChild ("button", "Flat Pushbutton", $$BS_PUSHBUTTON | $$BS_FLAT | $$WS_TABSTOP, 20, 100, 200, 25, #winMain, $$Button3, 0)
	
	#check1 = NewChild ("button", "AutoCheckbox", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 20, 165, 200, 25, #winMain, $$Check1, 0)
	#check2 = NewChild ("button", "Rightbutton", $$BS_AUTOCHECKBOX | $$BS_RIGHTBUTTON | $$BS_RIGHT | $$WS_TABSTOP, 20, 190, 200, 25, #winMain, $$Check2, 0)
	#check3 = NewChild ("button", "Pushlike Checkbox", $$BS_AUTOCHECKBOX | $$BS_PUSHLIKE | $$WS_TABSTOP, 20, 215, 200, 25, #winMain, $$Check3, 0)
	#check4 = NewChild ("button", "Auto3state", $$BS_AUTO3STATE | $$WS_TABSTOP, 20, 240, 200, 25, #winMain, $$Check4, 0)
	#check5 = NewChild ("button", "Multiline wraps button text to multiple lines", $$BS_AUTOCHECKBOX | $$BS_MULTILINE | $$WS_TABSTOP, 20, 265, 200, 40, #winMain, $$Check5, 0)

	#radio1 = NewChild ("button", "Radiobutton1", $$BS_AUTORADIOBUTTON | $$WS_GROUP | $$WS_TABSTOP, 20, 340, 200, 25, #winMain, $$Radio1, 0)
	#radio2 = NewChild ("button", "Radiobutton2", $$BS_AUTORADIOBUTTON, 20, 365, 200, 25, #winMain, $$Radio2, 0)
	#radio3 = NewChild ("button", "Radiobutton3", $$BS_AUTORADIOBUTTON, 20, 390, 200, 25, #winMain, $$Radio3, 0)

	#radio4 = NewChild ("button", "Togglebutton1", $$BS_AUTORADIOBUTTON | $$BS_PUSHLIKE | $$WS_GROUP | $$WS_TABSTOP, 20, 450, 200, 25, #winMain, $$Radio4, 0)
	#radio5 = NewChild ("button", "Togglebutton2", $$BS_AUTORADIOBUTTON | $$BS_PUSHLIKE, 20, 480, 200, 25, #winMain, $$Radio5, 0)
	#radio6 = NewChild ("button", "Togglebutton3", $$BS_AUTORADIOBUTTON | $$BS_PUSHLIKE, 20, 510, 200, 25, #winMain, $$Radio6, 0)

' initialize radio buttons to checked state
	SendMessageA (#radio1, $$BM_SETCHECK, $$BST_CHECKED, 0)
	SendMessageA (#radio4, $$BM_SETCHECK, $$BST_CHECKED, 0)

' initialize some fonts in groupboxes
	#hFontArial = NewFont (@"Arial", 10, $$FW_BOLD, $$TRUE, $$FALSE)
	SetNewFont (#group1, #hFontArial)
	SetNewFont (#group2, #hFontArial)
	SetNewFont (#group3, #hFontArial)
	SetNewFont (#group4, #hFontArial)

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
'
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA(hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underline
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle


END FUNCTION
'
'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
END PROGRAM
