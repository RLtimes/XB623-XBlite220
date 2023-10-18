'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo of a using simple menu control.
'
PROGRAM	"menu"
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
$$Menu_File  = 101
$$Menu_Edit  = 102
$$Menu_Options  = 103
$$Menu_Help  = 104

$$Menu_File_Open = 110
$$Menu_File_SaveAs = 111
$$Menu_File_Close = 112
$$Menu_File_Delete = 113
$$Menu_File_Exit = 114

$$Menu_Edit_Cut = 120
$$Menu_Edit_Copy = 121
$$Menu_Edit_Paste = 122
$$Menu_Edit_Delete = 123

$$Menu_Options_Font = 130
$$Menu_Options_Bold = 131
$$Menu_Options_Italic = 132
$$Menu_Options_Underline = 133

$$Menu_Help_About = 140

$$Menu_Font_MSSS = 150
$$Menu_Font_TNR = 151
$$Menu_Font_Arial = 152
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
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

	SELECT CASE msg

		CASE $$WM_DESTROY :
			DeleteObject (#hFontSS)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE $$Menu_Options_Bold, $$Menu_Options_Italic, $$Menu_Options_Underline :
					state = GetMenuState (#optionsMenu, id, $$MF_BYCOMMAND)
					IF (state & $$MF_CHECKED) THEN
						CheckMenuItem (#optionsMenu, id, $$MF_BYCOMMAND | $$MF_UNCHECKED)
					ELSE
						CheckMenuItem (#optionsMenu, id, $$MF_BYCOMMAND | $$MF_CHECKED)
					END IF

				CASE $$Menu_Font_MSSS, $$Menu_Font_TNR, $$Menu_Font_Arial :
					CheckMenuRadioItem (#fontMenu, $$Menu_Font_MSSS, $$Menu_Font_Arial, id, $$MF_BYCOMMAND)

				CASE $$Menu_Help_About :
					MessageBoxA (hWnd, &"Menu Example for XBLite\nCreated by David Szafranski\n2002", &"Menu Selection", 0)

				CASE ELSE :
					menu$ = NULL$(256)
					GetMenuStringA (#mainMenu, id, &menu$, 256, $$MF_BYCOMMAND)
					text$ = "Menu Selection: " + CSIZE$(menu$) + "\n" + "Menu ID: " + STRING$(id)
					MessageBoxA (hWnd, &text$, &"Menu Selection", 0)

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

' get current instance handle
	hInst = GetModuleHandleA (0)
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
	className$  = "MenuControl"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Menu Control."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 450
	h 					= 150
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' build the main menu
	#mainMenu = CreateMenu()			' create main menu

' build dropdown submenus
	#fileMenu = CreateMenu()			' create dropdown file menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Open, &"&Open")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_SaveAs, &"&Save As")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Close, &"&Close")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Delete, &"&Delete")
	AppendMenuA (#fileMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

	#editMenu = CreateMenu()			' create dropdown edit menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #editMenu, &"&Edit")
	AppendMenuA (#editMenu, $$MF_STRING, $$Menu_Edit_Cut, &"Cu&t\tCtrl+X")
	AppendMenuA (#editMenu, $$MF_STRING, $$Menu_Edit_Copy, &"&Copy\tCtrl+C")
	AppendMenuA (#editMenu, $$MF_STRING, $$Menu_Edit_Paste, &"&Paste\tCtrl+V")
	AppendMenuA (#editMenu, $$MF_STRING, $$Menu_Edit_Delete, &"&Delete\tDel")

	#optionsMenu = CreateMenu()			' create dropdown options menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #optionsMenu, &"&Options")
'	AppendMenuA (#optionsMenu, $$MF_STRING, $$Menu_Options_Font, &"&Font")
	AppendMenuA (#optionsMenu, $$MF_STRING, $$Menu_Options_Bold, &"&Bold")
	AppendMenuA (#optionsMenu, $$MF_STRING, $$Menu_Options_Italic, &"&Italic")
	AppendMenuA (#optionsMenu, $$MF_STRING, $$Menu_Options_Underline, &"&Underline")

	#fontMenu = CreateMenu()			' create dropdown sub font menu
	InsertMenuA (#optionsMenu, 0, $$MF_BYPOSITION | $$MF_POPUP, #fontMenu, &"&Font")
	AppendMenuA (#fontMenu, $$MF_STRING, $$Menu_Font_MSSS, &"&MS Sans Serif")
	AppendMenuA (#fontMenu, $$MF_STRING, $$Menu_Font_TNR, &"&Times New Roman")
	AppendMenuA (#fontMenu, $$MF_STRING, $$Menu_Font_Arial, &"&Arial")

	#helpMenu = CreateMenu()			' create dropdown help menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #helpMenu, &"&Help")
	AppendMenuA (#helpMenu, $$MF_STRING, $$Menu_Help_About, &"&About")

' initialize menu selections, check or radio
	CheckMenuRadioItem (#fontMenu, 0, 2, 0, $$MF_BYPOSITION)
	CheckMenuItem (#optionsMenu, 1, $$MF_BYPOSITION | $$MF_CHECKED)

	SetMenu (#winMain, #mainMenu)						' activate the menu

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

	STATIC MSG Msg

' main message loop

	IF LIBRARY(0) THEN RETURN			' main program executes message loop

	DO
		ret = GetMessageA (&Msg, hwnd, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN Msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&Msg)
  			DispatchMessageA (&Msg)
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
