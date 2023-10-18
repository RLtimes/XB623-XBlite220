'
'
' ####################
' #####  PROLOG  #####
' ####################

' Subclass a single line edit control so that
' it will respond to a user pressing the Enter
' or Return key and accept only numbers and 
' + and - chars.
'
PROGRAM	"editsubclass"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "msvcrt"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CreateCallbacks ()
DECLARE FUNCTION  EditProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  CleanUp ()

' Edit box return message
$$EDITBOX_RETURN = 402

'Control IDs
$$Edit1  = 101
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
	CreateCallbacks ()						' if necessary, assign callback functions to child controls
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

		CASE $$WM_DESTROY :
			DeleteObject (#hFontArial)
			PostQuitMessage (0)

		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$EDITBOX_RETURN :
					SELECT CASE id :
						CASE $$Edit1 :													' demonstrate that RETURN key was
							text$ = NULL$(1024)										' pressed in one of the edit controls
							SendMessageA (hwndCtl, $$WM_GETTEXT, 1024, &text$)
							text$ = "RETURN Key Pressed. Text: " + CSIZE$(text$)
							MessageBoxA (hWnd, &text$, &"Singleline Edit", 0)
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
	className$  = "SubClassedEditControl"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Enter a number."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 300
	h 					= 100
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' single line control to be subclassed
	#edit1 = NewChild ("edit", "", $$WS_BORDER | $$ES_AUTOHSCROLL | $$WS_TABSTOP, 20, 20, 260, 20, #winMain, $$Edit1, 0)

' initialize fonts in controls
	#hFontArial = NewFont ("Arial", 8, $$FW_BOLD, $$FALSE, $$FALSE)
	SetNewFont (#edit1, #hFontArial)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
	
	SetFocus (#edit1)

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
	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue
		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
				' Note that the dialog message pump does not allow RETURN key to be
				' captured by subclassed edit control. In a normal dialog box, the
				' RETURN key is supposed to activate the default button. 
				' The same thing occurs for the TAB key, since for dialogs, the
				' TAB is used to move between controls
				
  				TranslateMessage (&msg)
  				DispatchMessageA (&msg)
									
'        hwnd = GetActiveWindow ()
'        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
'  				TranslateMessage (&msg)
'  				DispatchMessageA (&msg)
'				END IF
		END SELECT
	LOOP

END FUNCTION
'
'
' ################################
' #####  CreateCallbacks ()  #####
' ################################
'
FUNCTION  CreateCallbacks ()

'	assign a new callback function to be used by child edit controls
	#old_proc = SetWindowLongA(#edit1, $$GWL_WNDPROC, &EditProc())

END FUNCTION
'
'
' #########################
' #####  EditProc ()  #####
' #########################
'
FUNCTION  EditProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_KEYDOWN :			' WM_KEYDOWN returns virtKey constants
			virtKey = wParam
			IF virtKey = $$VK_RETURN THEN
				id = GetWindowLongA (hWnd, $$GWL_ID)
				wParam = ($$EDITBOX_RETURN << 16) OR id
				SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
			END IF

		CASE $$WM_CHAR :				' WM_CHAR can capture keyboard characters
			charCode = wParam
'			PRINT "WM_CHAR message: ASCII charCode="; charCode, "CHAR="; CHR$(charCode)	' validate text entry by character

			' allow control chars
			IF iscntrl (charCode) THEN RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)
			 
			SELECT CASE charCode
				
				CASE '0', '1','2','3','4','5','6','7','8','9','-','+'  : 		' check for acceptable chars
					s$ = NULL$(128)
					GetWindowTextA (hWnd, &s$, LEN(s$))												' get current entry in edit box
					s$ = CSIZE$(s$) + CHR$(charCode)													' add new char
					l = LEN(s$)
					IF l <> 1 THEN 
						IF charCode = '-' || charCode = '+' THEN RETURN					' except - or + as first char only
					END IF 
					RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)
					
				CASE ELSE : RETURN
			END SELECT
			
		CASE ELSE :
			RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

	END SELECT
END FUNCTION
'
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)

	LOGFONT lf
	hDC 					= GetDC ($$HWND_DESKTOP)
	hFont 				= GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes 				= GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName 	= fontName$														' set font name
	lf.italic 		= italic															' set italic
	lf.weight 		= weight															' set weight
	lf.underline 	= underline														' set underlined
	lf.height 		= -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72.0
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)										' create a new font and get handle

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
