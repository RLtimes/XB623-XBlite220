

' Demo of playing avi/divx videos using MCI commands.
' Ported from the original XBasic 'xvideo.x' program.
' Example by Michael McElligott

PROGRAM	"avi"
VERSION	"0.0001"

	IMPORT	"xst"
	IMPORT	"gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
	IMPORT	"comctl32.dec"
	IMPORT  "comdlg32"
	IMPORT  "winmm"

$$play = 201
$$stop = 202
$$open = 203

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  ShowOpenFileDialog (hWndOwnder, @fileName$, filter$, initDir$, title$)

DECLARE FUNCTION  mci_open (STRING sFname)
DECLARE FUNCTION  mci_close ()
DECLARE FUNCTION  mci_play ()
DECLARE FUNCTION  mci_stop ()
DECLARE FUNCTION  mp3_open (sFilename$)
DECLARE FUNCTION  STRING get_shortname (STRING sFilename)

FUNCTION  Entry ()
	STATIC	entry

	IF entry THEN RETURN
	entry =  $$TRUE

	InitGui ()
	IF CreateWindows () THEN RETURN
	MessageLoop ()
	CleanUp ()

END FUNCTION


FUNCTION ShowOpenFileDialog (hWndOwner, fileName$, filter$, initDir$, title$)
	OPENFILENAME ofn
	SHARED hInst


	ofn.lStructSize = SIZE(ofn)				'set length of struct
	ofn.hwndOwner 	= hWndOwner				'set parent window handle
	ofn.hInstance 	= hInst						'set the application's instance
	ofn.lpstrFilter = &filter$

'create a buffer for the returned file
	IFZ fileName$ THEN
		fileName$ = SPACE$(254)
	ELSE
		fileName$ = fileName$ + SPACE$(254 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$
	ofn.nMaxFile 			= 255					'set the maximum length of a returned file

	buffer2$ = SPACE$(254)
	ofn.lpstrFileTitle 	= &buffer2$		'Create a buffer for the file title
	ofn.nMaxFileTitle 	= 255					'Set the maximum length of a returned file title
	ofn.lpstrInitialDir = &initDir$		'Set the initial directory
  	ofn.lpstrTitle 		= &title$			'Set the title
  	ofn.flags = $$OFN_FILEMUSTEXIST OR $$OFN_PATHMUSTEXIST OR $$OFN_EXPLORER	'flags

'call dialog
	IFZ GetOpenFileNameA (&ofn) THEN
		fileName$ = ""
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF
END FUNCTION

FUNCTION  WndProc (hWnd, msg, wParam, lParam)
	STATIC STRING filename


	SELECT CASE msg
		CASE $$WM_CREATE : filename = ""
		CASE $$WM_COMMAND :	
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			IF (notifyCode == $$BN_CLICKED) THEN
				SELECT CASE controlID
					CASE $$play		:mci_play()
					CASE $$stop		:mci_stop()
					CASE $$open		:
						filter$ = "Video for Windows (*.avi)\0*.avi\0All Files (*.*)\0*.*\0\0"
						initDir$ = NULL$(255)
						GetCurrentDirectoryA (255, &initDir$)
						initDir$ = CSIZE$(initDir$)
						title$ = "Select AVI file.."
					 	ShowOpenFileDialog (#winMain, @filename, filter$, initDir$, title$)
					 	IF filename THEN
							ShowWindow (#stop, $$SW_SHOWNORMAL)
							ShowWindow (#play, $$SW_SHOWNORMAL)
					 		mci_stop()
					 		mp3_open (filename)
					 	END IF
				END SELECT
			END IF

		CASE $$WM_DESTROY :
			mci_stop()
			mci_close()
			PostQuitMessage(0)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
	END SELECT

END FUNCTION

FUNCTION  mci_open ( STRING sFname)

	' Initialize buffer (has to be passed over but is not needed)
	buffer$ = NULL$(256)
	buffer5$ = NULL$(256)

	' Send Open Command to MCI
	mcicom$ = "open " + sFname + " type avivideo alias xbmpeg"
	result = mciSendStringA(&mcicom$, &buffer$, 256, 0)

	' pass 0 for hwnd to create a new window,
	' #winMain to display in main window frame
	mcicom5$ = "window xbmpeg handle 0"' + STRING$(#winMain)
	RETURN mciSendStringA(&mcicom5$, &buffer5$, 256, 0)
END FUNCTION

FUNCTION  mci_close ()

' Initialize buffer
   buffer$ = NULL$(256)

' Send close command
   mcicom$ = "close xbmpeg"
   result = mciSendStringA(&mcicom$, &buffer$, 256, 0)
END FUNCTION

FUNCTION  mci_play ()

' Initialize buffer
   buffer$ = NULL$(256)

' Send play command
   mcicom$ = "play xbmpeg from 0"
   result = mciSendStringA(&mcicom$, &buffer$, 256, 0)
END FUNCTION

FUNCTION  mci_stop ()

   buffer$ = NULL$(256)
	mcicom$ = "stop xbmpeg"
	result = mciSendStringA(&mcicom$, &buffer$, 256, 0)
END FUNCTION

FUNCTION  mp3_open (STRING sFilename)

	IF sFilename = "" THEN
' Show File Dialog
       gridType$ = "XuiFile"
       title$ = "Select File"
       message$ = ""
       string$ = ""
       reply$ = ""
'       XuiGetResponse(@gridType$, @title$, @message$, @string$, @v0, @v1, 0, @reply$)

' If file was selected: start open procedure
       IF reply$ = "" THEN
        '  XuiMessage(@"Could not open file!")
          RETURN
       END IF

	ELSE
       	reply$ = sFilename
	END IF
' Get Short Name
	mp3short$ = get_shortname(reply$)

' Check Short Name
    IF mp3short$ = "" ^^ UCASE$(RIGHT$(mp3short$,4)) != ".AVI" THEN
          'XuiMessage(@"Could not open file!")
    	RETURN
	END IF

	mci_close()


' Open File
    #mp3loaded = 0
    success = mci_open(mp3short$)
    IF success > 0 THEN
          'XuiMessage(@"MCI Device could not be opened")
		RETURN
    END IF
END FUNCTION

FUNCTION  STRING get_shortname (STRING Filename)

	buffer$ = NULL$(256)
	ulen = GetShortPathNameA (&Filename, &buffer$, 256)
	RETURN LEFT$(buffer$, ulen)
END FUNCTION

FUNCTION  InitGui ()
	SHARED hInst

	hInst = GetModuleHandleA (0) 	' get current instance handle
	IFZ hInst THEN QUIT (0)
END FUNCTION

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

FUNCTION  CreateWindows ()

' register window class
	className$  = "Video"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$ = "Video"
	style 		= $$WS_OVERLAPPEDWINDOW
	w 				= 190
	h 				= 60
	exStyle		= 0
	#winMain = NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	#open = NewChild ("button", "Open", $$BS_PUSHBUTTON , 5, 5, 50, 25, #winMain, $$open, 0)
	#play = NewChild ("button", "Play", $$BS_PUSHBUTTON , 65, 5, 50, 25, #winMain, $$play, 0)
	#stop = NewChild ("button", "Stop", $$BS_PUSHBUTTON , 125, 5, 50, 25, #winMain, $$stop, 0)

	ShowWindow (#stop, $$SW_HIDE)
	ShowWindow (#play, $$SW_HIDE)
	ShowWindow (#open, $$SW_SHOWNORMAL)

	XstCenterWindow (#winMain)							' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window
END FUNCTION

FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION

FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

	SHARED hInst

	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION

FUNCTION  MessageLoop ()
	USER32_MSG msg

	DO
		ret = GetMessageA (&msg, NULL, 0, 0)

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


FUNCTION  CleanUp ()
	SHARED hInst, className$

	UnregisterClassA (&className$, hInst)
END FUNCTION

END PROGRAM
