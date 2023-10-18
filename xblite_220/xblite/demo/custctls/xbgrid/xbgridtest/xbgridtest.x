'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Demo program for using xblite "babygrid"
' xbgrid custom control library.
'
'
PROGRAM	"xbgridtest"
VERSION	"0.0001"
'
	IMPORT	"xst"   			' Standard library : required by most programs
'	IMPORT 	"xio"					' Console IO library
	IMPORT	"gdi32"     	' gdi32.dll
	IMPORT  "user32"    	' user32.dll
	IMPORT  "kernel32"  	' kernel32.dll
	IMPORT	"xbgrid"			' xblite babygrid control library
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
DECLARE FUNCTION  AboutProc (hDlg, msg, wParam, lParam)
DECLARE FUNCTION  LoadGrid1 (hGrid1)
DECLARE FUNCTION  LoadGrid2 (hGrid2)

$$MENU_FILE_EXIT = 100
$$MENU_HELP_ABOUT = 101
$$BABYGRID1 = 110
$$BABYGRID2 = 111
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

'	XioCreateConsole (title$, 1500)	' create console, if console is not wanted, comment out this line
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

	RECT rc
	BGCELL cell
	SHARED hInst
	PAINTSTRUCT ps

	SELECT CASE msg

		CASE $$WM_CREATE :

' create two babygrid controls
			#hGrid1 = NewChild ($$XBGRIDCLASSNAME, "Grid Properties", style, 0, 0, 0, 0, hWnd, $$BABYGRID1, $$WS_EX_CLIENTEDGE)
			#hGrid2 = NewChild ($$XBGRIDCLASSNAME, "BABYGRID -- A simple grid for\nWin32 API Programmers", style, 0, 0, 0, 0, hWnd, $$BABYGRID2, $$WS_EX_CLIENTEDGE)

' set grid2 (the working demonstration grid 100 rows by 5 columns
			SendMessageA (#hGrid2, $$BGM_SETGRIDDIM, 100, 5)

' set grid1 (the properties grid) to automatically size columns
' based on the length of the text entered into the cells
			SendMessageA (#hGrid1, $$BGM_SETCOLAUTOWIDTH, $$TRUE, 0)

' only want 2 columns, rows will be added as data is entered programmatically
			SendMessageA (#hGrid1, $$BGM_SETGRIDDIM, 0, 2)

' I don't want a row header, so make it 0 pixels wide
			SendMessageA (#hGrid1, $$BGM_SETCOLWIDTH, 0, 0)

' set checkmark col 2 width to 25 (default is 50)
'			SendMessageA (#hGrid1, $$BGM_SETCOLWIDTH, 2, 25)

' this grid won't use column headings, set header row height = 0
			SendMessageA (#hGrid1, $$BGM_SETHEADERROWHEIGHT, 1, 0)

' don't extend last column
			SendMessageA (#hGrid1, $$BGM_EXTENDLASTCOLUMN, $$FALSE, 0)

' populate grid1 with data
			LoadGrid1 (#hGrid1)

' set checkmark col 2 width to 23 (default is 50)
			SendMessageA (#hGrid1, $$BGM_SETCOLWIDTH, 2, 23)

' populate grid2 with initial demo data
			LoadGrid2 (#hGrid2)

' make grid2 header row to initial height of 21 pixels
			SendMessageA (#hGrid2, $$BGM_SETHEADERROWHEIGHT, 21, 0)

' set grid2 column 1 wider
			SendMessageA (#hGrid2, $$BGM_SETCOLWIDTH, 1, 100)

		CASE $$WM_SIZE :
			GetClientRect (hWnd, &rc)
			MoveWindow (#hGrid1, 0, 0, rc.right/3+6, rc.bottom, $$TRUE)
			MoveWindow (#hGrid2, rc.right/3+6, 0, rc.right-(rc.right/3+6), rc.bottom, $$TRUE)

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

'		CASE $$WM_PAINT :
'			hdc = BeginPaint (hWnd, &ps)
'			EndPaint (hWnd, &ps)

		CASE $$WM_COMMAND :
			controlID = LOWORD (wParam)
			wmEvent   = HIWORD (wParam)

			SELECT CASE controlID

				CASE $$MENU_HELP_ABOUT :
					DialogBoxParamA (hInst, 200, hWnd, &AboutProc(), 0)

				CASE $$MENU_FILE_EXIT :
					DestroyWindow (hWnd)

				CASE $$BABYGRID1 :   ' properties grid notification message
					IF wmEvent = $$BGN_CELLCLICKED THEN

 ' get the row and column of the clicked cell
						row = LOWORD (lParam)
						col = HIWORD (lParam)

 ' set the BGCELL structure variable (cell) to this row and column
						SetCell (@cell, row, col)

' get the data type that is in the cell
' in this instance, we're looking for BOOLEAN data (types 3 [TRUE] or 4 [FALSE])
' datatype 1 is alphanumeric data
' datatype 2 is numeric data
' datatype 3 is BOOLEAN TRUE data
' datatype 4 is BOOLEAN FALSE data

						dtype = SendMessageA (#hGrid1, $$BGM_GETTYPE, &cell, 0)

						IF (dtype == 3) THEN		' bool true

' if the grid cell was true (checked checkbox), toggle it false
							SendMessageA (#hGrid1, $$BGM_SETCELLDATA, &cell, &"FALSE")

'send appropriate control message to the grid based
'on the row of the cell that was toggled

							SELECT CASE row
								CASE 1 : SendMessageA (#hGrid2, $$BGM_SETALLOWCOLRESIZE, $$FALSE, 0)
 								CASE 2 : SendMessageA (#hGrid2, $$BGM_SETEDITABLE, $$FALSE, 0)
								CASE 3 : SendMessageA (#hGrid2, $$BGM_SETELLIPSIS, $$FALSE, 0)
 								CASE 4 : SendMessageA (#hGrid2, $$BGM_SETCOLAUTOWIDTH, $$FALSE, 0)
													SetDefaultColWidths (#hGrid2)
													LoadGrid2 (#hGrid2)
													SetDefaultHeaderRowHeight (#hGrid2)
    						CASE 5 : SendMessageA (#hGrid2, $$BGM_EXTENDLASTCOLUMN, $$FALSE, 0)
    						CASE 6 : SendMessageA (#hGrid2, $$BGM_SETCOLSNUMBERED, $$FALSE, 0)
    											LoadGrid2 (#hGrid2)
    						CASE 7 : SendMessageA (#hGrid2, $$BGM_SETROWSNUMBERED, $$FALSE, 0)
    						CASE 8 : SendMessageA (#hGrid2, $$BGM_SHOWHILIGHT, $$FALSE, 0)
    						CASE 9 : SendMessageA (#hGrid2, $$BGM_SHOWCURSOR, $$FALSE, 0)
    						CASE 10: SendMessageA (#hGrid2, $$BGM_SETGRIDLINECOLOR, RGB (255,255,255), 0)
    						CASE 11: SendMessageA (#hGrid2, $$BGM_SHOWINTEGRALROWS, $$FALSE, 0)
    						CASE 12: SetDefaultCursorColor (#hGrid2)
    						CASE 13: SetDefaultFonts (#hGrid2)
							END SELECT
						END IF

						IF (dtype == 4) THEN  ' bool false

' if the grid cell was false (unchecked checkbox), toggle it true
							SendMessageA (#hGrid1, $$BGM_SETCELLDATA, &cell, &"TRUE")

' send appropriate control message to the grid based
' on the row of the cell that was toggled

							SELECT CASE row
								CASE 1 : SendMessageA (#hGrid2, $$BGM_SETALLOWCOLRESIZE, $$TRUE, 0)
 								CASE 2 : SendMessageA (#hGrid2, $$BGM_SETEDITABLE, $$TRUE, 0)
								CASE 3 : SendMessageA (#hGrid2, $$BGM_SETELLIPSIS, $$TRUE, 0)
 								CASE 4 : SendMessageA (#hGrid2, $$BGM_SETCOLAUTOWIDTH, $$TRUE, 0)
													LoadGrid2 (#hGrid2)
    						CASE 5 : SendMessageA (#hGrid2, $$BGM_EXTENDLASTCOLUMN, $$TRUE, 0)
    						CASE 6 : SendMessageA (#hGrid2, $$BGM_SETCOLSNUMBERED, $$TRUE, 0)
                         SendMessageA (#hGrid2, $$BGM_SETHEADERROWHEIGHT, 21, 0)
    						CASE 7 : SendMessageA (#hGrid2, $$BGM_SETROWSNUMBERED, $$TRUE, 0)
    						CASE 8 : SendMessageA (#hGrid2, $$BGM_SHOWHILIGHT, $$TRUE, 0)
    						CASE 9 : SendMessageA (#hGrid2, $$BGM_SHOWCURSOR, $$TRUE, 0)
    						CASE 10: SendMessageA (#hGrid2, $$BGM_SETGRIDLINECOLOR, RGB (220,220,220), 0)
								CASE 11: SendMessageA (#hGrid2, $$BGM_SHOWINTEGRALROWS, $$TRUE, 0)
								CASE 12: SendMessageA (#hGrid2, $$BGM_SETCURSORCOLOR, RGB (0,255,255), 0)
								CASE 13: 	hFont = NewFont ("Arial", 9, $$FW_THIN, 0, 0)
													SendMessageA (#hGrid2, $$WM_SETFONT, hFont, $$TRUE)
													hFont = NewFont ("Arial", 10, $$FW_NORMAL, 0, 0)
													SendMessageA (#hGrid2, $$BGM_SETHEADINGFONT, hFont, 0)
													hFont = NewFont ("Arial", 12, $$FW_SEMIBOLD, $$TRUE, 0)
													SendMessageA (#hGrid2, $$BGM_SETTITLEFONT, hFont, 0)
							END SELECT
						END IF
					END IF

				CASE ELSE :
					RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

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

	SHARED className$, hInst

' register window class
	className$  = "BabyGridDemoClass"
	addrWndProc = &WndProc()
	icon$ 			= "babygrid"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "BabyGrid Control Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 640
	h 					= 450
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	UpdateWindow (#winMain)
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
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

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
	UnregisterClassA(&"BABYGRID", hInst)

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
'
'
' ##########################
' #####  AboutProc ()  #####
' ##########################
'
FUNCTION  AboutProc (hDlg, msg, wParam, lParam)

	SELECT CASE msg
		CASE $$WM_INITDIALOG :

		CASE $$WM_COMMAND :
			IF (LOWORD (wParam) == $$IDOK || LOWORD (wParam) == $$IDCANCEL) THEN
				EndDialog (hDlg, LOWORD (wParam))
			ELSE
				RETURN ($$FALSE)
			END IF

		CASE ELSE : RETURN ($$FALSE)

	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  LoadGrid1 ()  #####
' ##########################
'
FUNCTION  LoadGrid1 (hGrid1)

' load data into the properties grid

	PutCell (hGrid1, 1, 1, "User Column Resizing")
	PutCell (hGrid1, 1, 2, "FALSE")
	PutCell (hGrid1, 2, 1, "User Editable")
	PutCell (hGrid1, 2, 2, "FALSE")
	PutCell (hGrid1, 3, 1, "Show Ellipsis")
	PutCell (hGrid1, 3, 2, "TRUE")
	PutCell (hGrid1, 4, 1, "Auto Column Size")
	PutCell (hGrid1, 4, 2, "FALSE")
	PutCell (hGrid1, 5, 1, "Extend Last Column")
	PutCell (hGrid1, 5, 2, "FALSE")
	PutCell (hGrid1, 6, 1, "Numbered Columns")
	PutCell (hGrid1, 6, 2, "TRUE")
	PutCell (hGrid1, 7, 1, "Numbered Rows")
	PutCell (hGrid1, 7, 2, "TRUE")
	PutCell (hGrid1, 8, 1, "Highlight Row")
	PutCell (hGrid1, 8, 2, "TRUE")
	PutCell (hGrid1, 9, 1, "Show Cursor")
	PutCell (hGrid1, 9, 2, "TRUE")
	PutCell (hGrid1, 10,1, "Show Gridlines")
	PutCell (hGrid1, 10,2, "TRUE")
	PutCell (hGrid1, 11,1, "Show Integral Rows")
	PutCell (hGrid1, 11,2, "FALSE")
	PutCell (hGrid1, 12,1, "Set Cursor Color")
	PutCell (hGrid1, 12,2, "FALSE")
	PutCell (hGrid1, 13,1, "Set Fonts")
	PutCell (hGrid1, 13,2, "FALSE")

' make the grid notify the program that the row in the
' grid has changed.  Usually this is done by the user clicking
' a cell, or moving thru the grid with the keyboard.  But we
' want the grid to initially send this message to get things going.
' If we didn't call BGM_NOTIFYROWCHANGED, the first row would be
' highlighted, but the ACTION wouldn't be performed.

	SendMessageA (hGrid1, $$BGM_NOTIFYROWCHANGED, 0, 0)

' make the properties grid have the focus when the application starts
 	SetFocus (hGrid1)

END FUNCTION
'
'
' ##########################
' #####  LoadGrid2 ()  #####
' ##########################
'
FUNCTION  LoadGrid2 (hGrid2)

' load grid 2 with initial demo data
	PutCell (hGrid2, 0, 1, "Multi-line\nHeadings\nSupported")
	PutCell (hGrid2, 0, 2, "\n\nName")
	PutCell (hGrid2, 0, 3, "\n\nAge")

	SendMessageA (hGrid2, $$BGM_SETPROTECT, $$TRUE, 0)
' every cell entered after a BGM_SETPROTECT TRUE will set the
' protected attribute of that cell.  This keeps an editable grid
' from allowing the user to overwrite whatever is in the protected cell

	SendMessageA (hGrid2, $$BGM_SETPROTECTCOLOR, RGB (210, 210, 210), 0)
' the setprotectcolor is optional, but it gives a visual indication
' of which cells are protected.

' now put some data in the cells in grid2
	PutCell (hGrid2, 1, 2, "David")
	PutCell (hGrid2, 2, 2, "Maggie")
	PutCell (hGrid2, 3, 2, "Chester")
	PutCell (hGrid2, 4, 2, "Molly")
	PutCell (hGrid2, 5, 2, "Bailey")

	PutCell (hGrid2, 1, 3, "43")
	PutCell (hGrid2, 2, 3, "41")
	PutCell (hGrid2, 3, 3, "3")
	PutCell (hGrid2, 4, 3, "3")
	PutCell (hGrid2, 5, 3, "1")

	PutCell (hGrid2, 10, 5, "Shaded cells are write-protected.")

	SendMessageA (hGrid2, $$BGM_SETPROTECT, $$FALSE, 0)
' turn off automatic cell protection
' if you don't turn off automatic cell protection, if the
' grid is editable, the user can enter data into empty cells
' but cannot change what he entered... not good.

	PutCell (hGrid2, 1, 0, "Row Headers customizable")

	e$ = "Editable"
	PutCell (hGrid2, 1, 1, "Editable line of text")
	PutCell (hGrid2, 2, 1, e$)
	PutCell (hGrid2, 3, 1, e$)
	PutCell (hGrid2, 4, 1, e$)
	PutCell (hGrid2, 5, 1, e$)
	PutCell (hGrid2, 6, 1, e$)
	PutCell (hGrid2, 7, 1, e$)
	PutCell (hGrid2, 8, 1, e$)
	PutCell (hGrid2, 9, 1, e$)
	PutCell (hGrid2, 10, 1, e$)
	PutCell (hGrid2, 11, 1, e$)
	PutCell (hGrid2, 12, 1, e$)
	PutCell (hGrid2, 13, 1, e$)
	PutCell (hGrid2, 14, 1, e$)
	PutCell (hGrid2, 15, 1, e$)
	PutCell (hGrid2, 16, 1, e$)

END FUNCTION
END PROGRAM
