'
'
' ####################
' #####  PROLOG  #####
' ####################
'
'	Using a RichEdit Control to enable URL tracking and highlighting.
' Example provided by Michael McElligott.
'
'
PROGRAM	"hlink"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT "comctl32"
	IMPORT "advapi32"
	IMPORT "shell32"
	
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
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  CleanUp ()

DECLARE FUNCTION  CreateRichEdit (x, y, w, h, hParent, id, kbTextMax)

DECLARE FUNCTION  GetRegKey (key, STRING subkey, STRING retdata)
DECLARE FUNCTION LaunchBrowser (STRING url)
DECLARE FUNCTION GetNotifyMsg (lParam, hwndFrom, idFrom, code)

'Control IDs
$$Edit1  = 101

$$POPURL_Open	= 201


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
	SHARED STRING URLBuffer
	STATIC STRING buffer
	STATIC ENLINK en
	STATIC TEXTRANGE txtr
	POINTAPI pt

	
	SELECT CASE msg
		CASE $$WM_CREATE :
			#hMenuURL = CreatePopupMenu ()
			AppendMenuA (#hMenuURL, $$MF_STRING, $$POPURL_Open, &"Open URL")
			RETURN 0

		CASE $$WM_DESTROY :
			DeleteObject (#hFontArial)
			PostQuitMessage (0)

		CASE $$WM_NOTIFY			:
			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
			idCtrl = idFrom
			SELECT CASE idCtrl
				CASE $$Edit1
					SELECT CASE code
						CASE $$EN_LINK	:
							RtlMoveMemory (&en, lParam, SIZE(en))
							' en.chrg.cpMin = index to first char of url in edit control
							' en.chrg.cpMax = index to last char
							buffer = NULL$((en.chrg.cpMax - en.chrg.cpMin)+1)	' url char size
							txtr.chrg = en.chrg
							txtr.lpstrText = &buffer
							SendMessageA (en.hdr.hwndFrom, $$EM_GETTEXTRANGE  ,0, &txtr)
							' EM_GETTEXTEX can be used to obtain highlighted text.

							SELECT CASE en.msg
								CASE $$WM_LBUTTONDOWN		:
								CASE $$WM_LBUTTONDBLCLK		:
								CASE $$WM_RBUTTONDOWN		:
									IF buffer != "" THEN
										pt.x = LOWORD(en.lParam): pt.y = HIWORD(en.lParam)
										ClientToScreen (en.hdr.hwndFrom, &pt)
										URLBuffer = buffer
										TrackPopupMenuEx (#hMenuURL, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, en.hdr.hwndFrom, 0)
										RETURN 0
									END IF
							END SELECT
					END SELECT
			END SELECT	

		CASE $$WM_SIZE	:
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)
			SetWindowPos (#edit1,0, 0, 26, width-2,height-47, 0)
			RETURN 0

	END SELECT
	
	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION GetNotifyMsg (lParam, hwndFrom, idFrom, code)
	NMHDR nmhdr


	nmhdrAddr = lParam
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code

END FUNCTION

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
	STRING text
	SHARED className$

' register window class
	className$  = "EditControls"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Edit Controls."
	style 		= $$WS_OVERLAPPEDWINDOW
	w 			= 400
	h 			= 245
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	#edit1 = CreateRichEdit (x, y, w, h, #winMain, $$Edit1, 5)
	SendMessageA (#edit1, $$EM_SETBKGNDCOLOR, 0, RGB(212, 208, 200))
	SendMessageA (#edit1, $$EM_AUTOURLDETECT, 1, 0)
	SendMessageA (#edit1, $$EM_SETEVENTMASK , 0 , $$ENM_LINK )	' request EN_LINK callback messages.

	text = "\tRight click on URL to open.\n\n\twww.google.com\n\n"
	text = text + "\thttp://perso.wanadoo.fr/xblite/\n\n"
	text = text + "\thttp://groups-beta.google.com/group/xblite/\n\n"
	text = text + "\thttp://groups.yahoo.com/group/xbasic/\n"
	SendMessageA (#edit1, $$WM_SETTEXT, 0, &text)


	XstCenterWindow (#winMain) ' center window position
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

FUNCTION  CreateRichEdit (x, y, w, h, hParent, id, kbTextMax)
	SHARED hInst

' load riched20.dll or riched32.dll if available

	class$ = "richedit20A"
	hRichEditDll = LoadLibraryA (&"riched20.dll")
	IFZ hRichEditDll THEN
		class$ = "richedit"
		hRichEditDll = LoadLibraryA (&"riched32.dll")
	END IF
	IFZ hRichEditDll THEN RETURN 0

' create rich edit child window
	style = $$WS_VISIBLE | $$WS_CHILD
	style = style | $$ES_MULTILINE  | $$ES_READONLY  '  | $$ES_SUNKEN
	style = style | $$WS_VSCROLL ' | $$WS_HSCROLL 
	style = style | $$ES_AUTOVSCROLL	' | $$ES_AUTOHSCROLL 
	style = style | $$ES_NOHIDESEL | $$ES_SAVESEL
	style = style | $$ES_WANTRETURN  ' | $$WS_OVERLAPPED
	
	exstyle =  $$WS_EX_STATICEDGE 
	hRichEd =  CreateWindowExA (exstyle, &class$, 0, style, x, y, w, h, hParent, id, hInst, 0)

' set upper limit to amount of text in rich edit control
' default upper limit is 32k, max upper is 2GB
	SendMessageA (hRichEd, $$EM_EXLIMITTEXT, 0, 1024*kbTextMax)

	RETURN hRichEd
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

	STATIC USER32_MSG msg

' main message loop

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
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
	SHARED STRING URLBuffer


	SELECT CASE msg
		CASE $$WM_COMMAND :
			id = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam

			SELECT CASE id
				CASE $$POPURL_Open	:IF URLBuffer THEN LaunchBrowser (URLBuffer)
					RETURN 0
			END SELECT
	END SELECT

	RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)
END FUNCTION


FUNCTION LaunchBrowser (url$)
	IFZ url$ THEN RETURN

	key$ = NULL$ (512)

' First try ShellExecute()
	result = ShellExecuteA (NULL, &"open", &url$, NULL, NULL, showcmd)

' If it failed, get the .htm regkey and lookup the program
	IF (result <= $$HINSTANCE_ERROR) THEN
		IF (GetRegKey ($$HKEY_CLASSES_ROOT, ".htm", @key$) == $$ERROR_SUCCESS) THEN
			key$ = key$ + "\\shell\\open\\command"
			IF (GetRegKey ($$HKEY_CLASSES_ROOT, key$, @path$) == $$ERROR_SUCCESS) THEN
				pos = INSTR (path$, "\"%1\"")						' Look for "%1"
				IFZ pos THEN 										' No quotes found
					pos = INSTR (path$, "%1") 						' Check for %1, without quotes
				END IF
				IF pos THEN path$ = TRIM$ (LEFT$ (path$, pos-1))
				path$ = path$ + " " + url$
				result = WinExec (&path$, showcmd)
			END IF
		END IF
	END IF
	RETURN result

END FUNCTION

FUNCTION  GetRegKey (key, subkey$, @retdata$)

	retval = RegOpenKeyExA (key, &subkey$, 0, $$KEY_QUERY_VALUE, &hkey)

	IF (retval == $$ERROR_SUCCESS) THEN
		datasize = $$MAX_PATH
		retdata$ = NULL$ ($$MAX_PATH)
		RegQueryValueA (hkey, NULL, &retdata$, &datasize)
		retdata$ = TRIM$ (retdata$)
		RegCloseKey (hkey)
	END IF

	RETURN retval
END FUNCTION

FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
	SHARED hNewBrush
	

	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	
	RETURN hNewBrush
END FUNCTION
'
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
	
	
	IF #hMenuURL THEN DestroyMenu (#hMenuURL): #hMenuURL = 0
	
	UnregisterClassA(&className$, hInst)
END FUNCTION
END PROGRAM
