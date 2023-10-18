'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo uses ShowHTMLDialog() in mshtml.dll
' to display html in a dialog window.
' See http://www.dcjournal.com/com/htmldlg.html
'
PROGRAM	"showhtml"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
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
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  ShowHTMLDlg (hwndParent, url$, x, y, w, h, resize, status, center)

'Control IDs

$$Button1  = 130
$$Button2  = 131
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

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE id

						CASE $$Button1 :
'							ShowHTMLDlg (hwndParent, url$, x, y, w, h, resize, status, center)
							dir$ = "c:/xblite/demo/gui/showhtml/"
							file$ = "showhtmldialog.html"
							url$ = "file://" + dir$ + file$
							ShowHTMLDlg (hWnd, url$, 50, 50, 600, 400, 1, 1, 0)

						CASE $$Button2 :
							url$ = "http://www.wired.com/"
							ShowHTMLDlg (hWnd, url$, 0, 0, #screenWidth-40, #screenHeight-40, 0, 0, 1)
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

' register window class
	className$  = "ShowHTMLDialog"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "ShowHTMLDialog Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 200
	h 					= 160
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' create button controls
	#hButton1 = NewChild ($$BUTTON, "HTML Dialog from file", $$BS_PUSHBUTTON, 20, 20, 160, 24, #winMain, $$Button1, 0)
	#hButton2 = NewChild ($$BUTTON, "HTML Dialog from url", $$BS_PUSHBUTTON, 20, 64, 160, 24, #winMain, $$Button2, 0)

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
'
'
' ############################
' #####  ShowHTMLDlg ()  #####
' ############################
'
' PURPOSE : Display a html file or url in a dialog box.
'           This utilizes the IE4.0+ mshtml.dll library
'           function ShowHTMLDialog (). The bool flags
'           resize, status, center allow one to resize
'           the dialog window, to show a statusbar, and
'           to center the dialog window. url$ can be any
'           valid displayable html file or url address.

FUNCTION  ShowHTMLDlg (hwndParent, url$, x, y, w, h, resize, status, center)

	USHORT wideUrl[255]
	USHORT wideOptions[255]

	FUNCADDR ShowHTMLDialog (ULONG, ULONG, ULONG, ULONG, ULONG)
	FUNCADDR CreateURLMoniker (ULONG, ULONG, ULONG)

' initialize unicode arrays
	wideUrl[0] = 0
	wideOptions[0] = 0

' convert url$ to unicode
  ret = MultiByteToWideChar ($$CP_ACP, 0, &url$, -1, &wideUrl[0], 256)
	IFZ ret THEN RETURN

' load the mshtml.dll library
  hInstMSHTML = LoadLibraryA (&"mshtml.dll")
	IFZ hInstMSHTML THEN RETURN

' load urlmon.dll library
	hInstUrlmon = LoadLibraryA (&"urlmon.dll")
	IFZ hInstUrlmon THEN GOTO end

' get function address for the ShowHTMLDialog ()
	ShowHTMLDialog = GetProcAddress (hInstMSHTML, &"ShowHTMLDialog")
	IFZ ShowHTMLDialog THEN GOTO end

' get function address for CreateURLMoniker ()
	CreateURLMoniker = GetProcAddress (hInstUrlmon, &"CreateURLMoniker")
	IFZ CreateURLMoniker THEN GOTO end

' create URL Moniker (urlmon.dll)
' ret = CreateURLMoniker (pmkContext, lpszURL, ppmk)
' pmkContext - [in] Address of the IMoniker interface for the
'              URL moniker to use as the base context when the
'              szURL parameter is a partial URL string.
'              The pmkContext parameter can be NULL.
' lpszURL    - [in] Address of a string value that contains the
'              display name to be parsed.
' ppmk       - [out] Address of a pointer to an IMoniker interface
'              for the new URL moniker.
' return     - S_OK (=0) success

	ppmk = 0
  moniker = @CreateURLMoniker (0, &wideUrl[0], &ppmk)
	IF moniker THEN GOTO end

' show the html dialog window
'	hResult = ShowHTMLDialog (hwndParent, pMk, pvarArgIn, pchOptions, pvarArgOut)
' hwndParent - Handle to the parent of the dialog box.
' pMk        - Address of an IMoniker interface from which the HTML for
'              the dialog box is loaded.
' pvarArgIn  - Address of a VARIANT structure that contains the
'              input data for the dialog box. The data passed in
'              this VARIANT is placed in the window object's
'              IHTMLDialog::dialogArguments property. This parameter
'              can be NULL.
' pchOptions - Window ornaments for the dialog box. This parameter
'              can be NULL or the address of a string that contains
'              a combination of values, each separated by a semicolon (;).
'              See the description of the features parameter of the
'              IHTMLWindow2::showModalDialog method of the window object
'              for detailed information.
' pvarArgOut - Address of a VARIANT structure that contains the output
'              data for the dialog box. This VARIANT receives the data
'              that was placed in the window object's IHTMLDialog::returnValue
'              property. This parameter can be NULL.
' Return Value - Returns S_OK if successful, or an error value otherwise.

' set dialog display options
	options$ = ""
	IFZ center THEN
		options$ = options$ + "center:0"      + ";"
		options$ = options$ + "dialogLeft:"   + STRING$(x) + "px" + ";"
		options$ = options$ + "dialogTop:"    + STRING$(y) + "px" + ";"
	END IF
	IF w       THEN options$ = options$ + "dialogWidth:"  + STRING$(w) + "px" + ";"
	IF h       THEN options$ = options$ + "dialogHeight:" + STRING$(h) + "px" + ";"
	IF resize  THEN options$ = options$ + "resizable:1"   + ";"
	IF status  THEN options$ = options$ + "status:1"      + ";"

	options$ = options$ + "help:0"        									' turn off help icon

' convert options$ to unicode
  ret = MultiByteToWideChar ($$CP_ACP, 0, &options$, -1, &wideOptions[0], 256)
	IFZ ret THEN GOTO end

' show html dialog
  dlgRet = @ShowHTMLDialog (hwndParent, ppmk, 0, &wideOptions[0], 0)

' free the dll libraries
end:
  IF hInstMSHTML THEN FreeLibrary (hInstMSHTML)
  IF hInstUrlmon THEN FreeLibrary (hInstUrlmon)

END FUNCTION
END PROGRAM
