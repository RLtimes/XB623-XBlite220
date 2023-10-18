'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of several standard common dialogs found
' the in comdlg32.dll, including the color picker,
' the font selector, the open/save file dialogs,
' and the printer setup dialog.
'
PROGRAM	"comdlg"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"
	IMPORT  "comdlg32"	' comdlg32.dll
	IMPORT  "winspool"
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
DECLARE FUNCTION  ChooseColorDialog (hWndOwner, @colorValueWin, @customColorsWin[])
DECLARE FUNCTION  ShowFontDialog (hWndOwnder, @fontName$, @height, @weight, @italic, @underline, @strikeOut, @color)
DECLARE FUNCTION  ShowOpenFileDialog (hWndOwnder, @fileName$, filter$, initDir$, title$)
DECLARE FUNCTION  ShowPageSetupDialog (hWndOwner, @width, @height, @leftMargin, @rightMargin, @topMargin, @bottomMargin, @orientation, @size, @bin)
DECLARE FUNCTION  ShowPrintDialog (hWndOwner, @flags, minPage, maxPage, @fromPage, @toPage, DEVMODE dm)
DECLARE FUNCTION  ShowSaveFileDialog (hWndOwnder, @fileName$, filter$, initDir$, title$)

'Control IDs
$$Menu_File  = 101

$$Menu_File_OpenFile 	= 110
$$Menu_File_SaveFile 	= 111
$$Menu_File_Color 		= 112
$$Menu_File_Font 			= 113
$$Menu_File_Page 			= 114
$$Menu_File_Print			= 115
$$Menu_File_Exit 			= 116
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

	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes
	XioFreeConsole ()							' free console

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	DEVMODE dm

	SELECT CASE msg
		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE $$Menu_File_OpenFile :
					PRINT " ***** ShowOpenFileDialog () *****"
'set file filters
					filter$ = "XB Files (*.x, *.dec)" + CHR$(0) + "*.x;*.dec" + CHR$(0) + "Text Files (*.txt)" + CHR$(0) + "*.txt" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0) + CHR$(0)
'set initial directory
					initDir$ = NULL$(255)
					GetCurrentDirectoryA (255, &initDir$)
					initDir$ = CSIZE$(initDir$)
'set dialog title
					title$ = "Select a file to Open"
'set an initial default fileName - this is optional
					fileName$ = ""

					IFZ ShowOpenFileDialog (#winMain, @fileName$, filter$, initDir$, title$) THEN
						PRINT "Cancel button pressed"
					ELSE
						PRINT "Selected open file: "; fileName$
					END IF

				CASE $$Menu_File_SaveFile :
					PRINT " ***** ShowSaveFileDialog () *****"
'set file filters
					filter$ = "XB Files (*.x, *.dec)" + CHR$(0) + "*.x;*.dec" + CHR$(0) + "Text Files (*.txt)" + CHR$(0) + "*.txt" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0) + CHR$(0)
'set initial directory
					initDir$ = NULL$(255)
					GetCurrentDirectoryA (255, &initDir$)
					initDir$ = CSIZE$(initDir$)
'set dialog title
					title$ = "Filename to Save"
'set an initial default fileName - this is optional - good for resaving files
					fileName$ = "myprog.x"

					IFZ ShowSaveFileDialog (#winMain, @fileName$, filter$, initDir$, title$) THEN
						PRINT "Cancel button pressed"
					ELSE
						PRINT "Selected save file: "; fileName$
					END IF

				CASE $$Menu_File_Color :
					PRINT " ***** ChooseColorDialog () *****"
					IFZ ChooseColorDialog (#winMain, @colorValueWin, @customColorsWin[]) THEN
						PRINT "Cancel button pressed"
					ELSE
						PRINT "colorValueWin = "; colorValueWin
						FOR i = 0 TO UBOUND(customColorsWin[])
							PRINT "custom color ["; i; "] = "; customColorsWin[i]
						NEXT i
					END IF

				CASE $$Menu_File_Font :
					PRINT " ***** ShowFontDialog () *****"
					IFZ ShowFontDialog (#winMain, @fontName$, @height, @weight, @italic, @underline, @strikeOut, @color) THEN
						PRINT "Cancel was pressed"
					ELSE
						PRINT "Selected Font Name  : "; fontName$		'font name
						PRINT "Selected height     :"; height				'points
						PRINT "Selected weight     :"; weight				'100-900
						PRINT "Selected italic     :"; italic				'0-1
						PRINT "Selected underline  :"; underline		'0-1
						PRINT "Selected strikeOut  :"; strikeOut		'0-1
						PRINT "Selected color      :"; color				'Windows Color value
					END IF

				CASE $$Menu_File_Page :
					PRINT " ***** ShowPageSetupDialog () *****"
					IFZ ShowPageSetupDialog (#winMain, @width, @height, @leftMargin, @rightMargin, @topMargin, @bottomMargin, @orientation, @size, @bin) THEN
						PRINT "Cancel was pressed"
					ELSE
						PRINT "Selected paper width   :"; width
						PRINT "Selected paper height  :"; height
						PRINT "Selected left margin   :"; leftMargin
						PRINT "Selected right margin  :"; rightMargin
						PRINT "Selected top margin    :"; topMargin
						PRINT "Selected bottom margin :"; bottomMargin
						PRINT "Paper Orientation      :"; orientation
						PRINT "PaperSize              :"; size
						PRINT "PaperBin               :"; bin
					END IF

				CASE $$Menu_File_Print :
					PRINT " ***** ShowPrintDialog () *****"
					IFZ ShowPrintDialog (#winMain, @flags, 1, 50, @fromPage, @toPage, @dm) THEN
						PRINT "Cancel was pressed"
					ELSE
						IF flags & $$PD_PAGENUMS THEN pages = 1
						IF flags & $$PD_SELECTION THEN select = 1
						all	= ABS(!(pages | select))
						PRINT "Print All          :"; all
						PRINT "Print Pages        :";	pages
						PRINT "Print Selection    :"; select

						IF pages THEN PRINT "Print from page"; fromPage, " to page"; toPage

						IF flags & $$PD_PRINTTOFILE THEN ptf = 1
						PRINT "Print To File      :"; ptf

						PRINT "Copies             :"; dm.dmCopies
						PRINT "Paper Orientation  :"; dm.dmOrientation
						PRINT "PaperSize          :"; dm.dmPaperSize
						PRINT "Collate            :"; dm.dmCollate
					END IF
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
	className$  = "CommonDialogs"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Common Dialogs Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 450
	h 					= 150
	#winMain = NewWindow (className$, @titleBar$, style, x, y, w, h, 0)

' build the main menu
	#mainMenu = CreateMenu()			' create main menu

' build dropdown submenus
	#fileMenu = CreateMenu()			' create dropdown file menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_OpenFile, &"&OpenFileDialog")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_SaveFile, &"&SaveFileDialog")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Color, &"&ColorDialog")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Font, &"&FontDialog")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Page, &"Pa&geSetupDialog")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Print, &"&PrintDialog")
	AppendMenuA (#fileMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

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
		ret = GetMessageA (&Msg, 0, 0, 0)

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
'
'
' ##################################
' #####  ChooseColorDialog ()  #####
' ##################################
'
'PURPOSE: Bring up Win9x ChooseColor Common Dialog
'RETURNS: $$FALSE if failure or Cancel Selection, $$TRUE if success
'					hWndOwner is handle to main window
'					colorValueWin is selected color
'					customColorsWin[] is an array of selected custom colors
'COMMENT: The return values are Windows color values
'USE:     ChooseColor (hWndOwner, @colorValueWin, @customColorsWin[])

FUNCTION  ChooseColorDialog (hWndOwner, @colorValueWin, @customColorsWin[])

	CHOOSECOLOR cc
	SHARED hInst
	ULONG ccBuffer[]

	REDIM ccBuffer[15]
	REDIM customColorsWin[15]

'fill custom color array with white color values
	FOR i = 0 TO 15
		ccBuffer[i] = 0xFFFFFF
	NEXT i

'initialize cc struct
	cc.lStructSize 		= LEN(cc)
	cc.hwndOwner 			= hWndOwner
	cc.hInstance 			= hInst
	cc.rgbResult 			= colorValueWin
	cc.lpCustColors 	= &ccBuffer[0]
	cc.flags 					= $$CC_RGBINIT | $$CC_FULLOPEN
	cc.lCustData 			= 0
	cc.lpfnHook 			= 0
	cc.lpTemplateName = 0

'open dialog
	IFZ ChooseColorA (&cc) THEN
		RETURN 0
	ELSE
		colorValueWin = cc.rgbResult

'get custom color array
		FOR i = 0 TO 15
			customColorsWin[i] = ccBuffer[i]
		NEXT i
	END IF
	RETURN $$TRUE
END FUNCTION
'
'
' ###############################
' #####  ShowFontDialog ()  #####
' ###############################
'
FUNCTION  ShowFontDialog (hWndOwner, @fontName$, @height, @weight, @italic, @underline, @strikeOut, @color)

	LOGFONT2 font
	CHOOSEFONT chooseFont
	SHARED hInst

	font.lfEscapement 	= 0   	'Set the font's escapement. Specifies the angle, in tenths of degrees, between the escapement vector and the x-axis of the device. The escapement vector is parallel to the base line of a row of text.  Units in 1/10 degree.
	font.lfOrientation 	= 0   	'set the orientation
  font.lfHeight 			= 0			'Set the default height   ' -MulDiv(12, GetDeviceCaps (hdc, $$LOGPIXELSY), 72)

  chooseFont.flags 				= $$CF_SCREENFONTS OR $$CF_EFFECTS		'to get dialog to show up, $$CF_SCREENFONTS flag must be used
  chooseFont.hInstance 		= hInst							'set the application instance
  chooseFont.hwndOwner 		= hWndOwner					'set the owner window
  chooseFont.lpLogFont 		= &font							'select the logfont struct
  chooseFont.lStructSize 	= SIZE(chooseFont)	'set the structure size

'Show the font dialog

	IFZ ChooseFontA (&chooseFont) THEN
		RETURN 0
	ELSE

'get the results from dialog

		fontName$ = font.lfFaceName
		fontName$ = CSIZE$(fontName$)
 		height 		= font.lfHeight

'change font height into points
'Get the handle of the desktop window
   	hwnd = GetDesktopWindow ()

'Get the device context for the desktop
   	hdc = GetWindowDC (hwnd)

'calc height in points
		height 		= ABS(72 * height / (GetDeviceCaps (hdc, $$LOGPIXELSY)))
		weight 		= font.lfWeight
		italic 		= font.lfItalic
		underline = font.lfUnderline
		strikeOut = font.lfStrikeOut
		color 		= chooseFont.rgbColors

		RETURN $$TRUE
	END IF
END FUNCTION
'
'
' ###################################
' #####  ShowOpenFileDialog ()  #####
' ###################################
'
FUNCTION  ShowOpenFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)

	OPENFILENAME ofn
	SHARED hInst

	ofn.lStructSize = LEN(ofn)				'set length of struct
	ofn.hwndOwner 	= hWndOwner				'set parent window handle
	ofn.hInstance 	= hInst						'set the application's instance

'select a filter
'pstrFilter points to a buffer containing pairs of null-terminated
'filter strings. The first string in each pair describes a filter
'(for example, "Text Files"), and the second specifies the
'filter pattern (for example, "*.TXT"). Multiple filters can be
'specified for a single item by separating the filter pattern strings
'with a semicolon (for example, "*.TXT;*.DOC;*.BAK"). The last string
'in the buffer must be terminated by two NULL characters. If this member
'is NULL, the dialog box will not display any filters.
'The filter strings are assumed to be in the proper order - the
'operating system does not change the order.

'	filter$ = "XB Files (*.x, *.dec)" + CHR$(0) + "*.x;*.dec" + CHR$(0) + "Text Files (*.txt)" + CHR$(0) + "*.txt" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0) + CHR$(0)
	ofn.lpstrFilter = &filter$

'create a buffer for the returned file
	IF fileName$ = "" THEN
		fileName$ = SPACE$(254)
	ELSE
		fileName$ = fileName$ + SPACE$(254 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$

	ofn.nMaxFile 				= 255					'set the maximum length of a returned file

	buffer2$ = SPACE$(254)
	ofn.lpstrFileTitle 	= &buffer2$		'Create a buffer for the file title
	ofn.nMaxFileTitle 	= 255					'Set the maximum length of a returned file title
	ofn.lpstrInitialDir = &initDir$		'Set the initial directory
  ofn.lpstrTitle 			= &title$			'Set the title
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
'
'
' ####################################
' #####  ShowPageSetupDialog ()  #####
' ####################################
'
FUNCTION  ShowPageSetupDialog (hWndOwner, @width, @height, @leftMargin, @rightMargin, @topMargin, @bottomMargin, @orientation, @size, @bin)

	PAGESETUPDLG psd
	POINT paperSize
	RECT margin
	SHARED hInst
	DEVMODE dm
	PRINTDLG pd

	RtlZeroMemory (&pd, SIZE(pd))					' initialize pd with zeros
	pd.lStructSize 	= 66									'	set pd size, NOTE: SIZE(pd) gives a byte aligned value of 68 which causes PrintDlgA() to fail 						'
	pd.hwndOwner		= hWndOwner						' set owner window handle
	pd.flags				= $$PD_RETURNDEFAULT	' return hDevNames and hDevMode handles for default printer, does not display dialog box

	ret = PrintDlgA (&pd)									'call PrintDlgA to get default printer info

'	error = CommDlgExtendedError ()
'	PRINT "error="; error

'init psd struct
	psd.lStructSize = SIZE(psd)						' set the psd structure size
	psd.hwndOwner 	= hWndOwner						' set the owner window handle
	psd.hInstance 	= hInst								' set the application instance
	psd.flags 			= 0										' set flags

	psd.hDevMode 		= pd.hDevMode					' handle to a devmode struct
	psd.hDevNames   = pd.hDevNames				' handle to a devnames struct

	IFZ PageSetupDlgA (&psd) THEN						'show dialog
		RETURN 0
	ELSE
		paperSize = psd.ptPaperSize						'get paperSize values from POINT struct
		width 		= paperSize.x								'default return measurements are in 1/1000"
		height 		= paperSize.y

		margin 				= psd.rtMargin					'get the return margins
		leftMargin 		= margin.left
		rightMargin 	= margin.right
		topMargin 		= margin.top
		bottomMargin 	= margin.bottom

		dmAddr 				= GlobalLock (psd.hDevMode)			' get devmode address

		RtlMoveMemory (&dm, dmAddr, SIZE(dm))					'copy devmode info to dm
		orientation 	= dm.dmOrientation
		size 					= dm.dmPaperSize
		bin 					= dm.dmDefaultSource

		GlobalUnlock (psd.hDevMode)
		RETURN $$TRUE
	END IF
END FUNCTION
'
'
' ################################
' #####  ShowPrintDialog ()  #####
' ################################
'
FUNCTION  ShowPrintDialog (hWndOwner, @flags, minPage, maxPage, @fromPage, @toPage, DEVMODE dm)

	PRINTDLG pd
	SHARED hInst

	RtlZeroMemory (&pd, SIZE(pd))					' initialize pd with zeros
	pd.lStructSize 	= 66									'	set pd size, NOTE: SIZE(pd) gives a byte aligned value of 68 which causes PrintDlgA() to fail 						'
	pd.hwndOwner		= hWndOwner						' set owner window handle
	pd.flags				= $$PD_RETURNDEFAULT	' return hDevNames and hDevMode handles for default printer, does not display dialog box

	ret = PrintDlgA (&pd)									' call PrintDlgA to get default printer info

	IFZ maxPage THEN maxPage = 1
	IFZ minPage THEN minPage = 1
	IFZ fromPage THEN fromPage = 1
	IFZ toPage THEN toPage = 1

  pd.flags			= flags | $$PD_RETURNDC | $$PD_PAGENUMS | $$PD_USEDEVMODECOPIESANDCOLLATE
	pd.nMinPage		= minPage
	pd.nMaxPage		= maxPage
	pd.nFromPage	= fromPage
	pd.nToPage		= toPage

	IFZ PrintDlgA (&pd) THEN
		RETURN 0
	ELSE
		fromPage 	= pd.nFromPage
		toPage 		= pd.nToPage
		flags			= pd.flags

		dmAddr 		= GlobalLock (pd.hDevMode)		' get devmode address
		RtlMoveMemory (&dm, dmAddr, SIZE(dm))		' copy devmode info to dm
		GlobalUnlock (pd.hDevMode)

		RETURN $$TRUE
	END IF

END FUNCTION
'
'
' ###################################
' #####  ShowSaveFileDialog ()  #####
' ###################################
'
FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)

	OPENFILENAME ofn
	SHARED hInst

	ofn.lStructSize = LEN(ofn)			'set length of struct
	ofn.hwndOwner 	= hWndOwner			'set parent window handle
	ofn.hInstance 	= hInst					'set the application's instance

'select a filter
'pstrFilter points to a buffer containing pairs of null-terminated
'filter strings. The first string in each pair describes a filter
'(for example, "Text Files"), and the second specifies the
'filter pattern (for example, "*.TXT"). Multiple filters can be
'specified for a single item by separating the filter pattern strings
'with a semicolon (for example, "*.TXT;*.DOC;*.BAK"). The last string
'in the buffer must be terminated by two NULL characters. If this member
'is NULL, the dialog box will not display any filters.
'The filter strings are assumed to be in the proper order - the
'operating system does not change the order.

'	filter$ = "XB Files (*.x, *.dec)" + CHR$(0) + "*.x;*.dec" + CHR$(0) + "Text Files (*.txt)" + CHR$(0) + "*.txt" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0) + CHR$(0)
	ofn.lpstrFilter = &filter$

'create a buffer for the returned file
	IF fileName$ = "" THEN
		fileName$ = NULL$(256)
	ELSE
		fileName$ = fileName$ + NULL$(256 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$

	ofn.nMaxFile 				= 256					'set the maximum length of a returned file
	buffer2$ = NULL$(256)
	ofn.lpstrFileTitle 	= &buffer2$		'Create a buffer for the file title
	ofn.nMaxFileTitle 	= 256					'Set the maximum length of a returned file title
	ofn.lpstrInitialDir = &initDir$		'Set the initial directory
  ofn.lpstrTitle 			= &title$			'Set the title
  ofn.flags = $$OFN_PATHMUSTEXIST OR $$OFN_EXPLORER	'flags

'call dialog
	IFZ GetSaveFileNameA (&ofn) THEN
		fileName$ = ""
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF
END FUNCTION
END PROGRAM
