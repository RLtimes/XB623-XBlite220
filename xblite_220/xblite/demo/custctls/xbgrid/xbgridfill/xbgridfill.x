'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Test filling grid speed with 20k cells
' using PutCell or InitCell functions.
' InitCell can only be used on an initially
' empty grid.
'
' An XBGrid is limited in size to 32000 rows
' and to 256 columns. But filling large numbers
' of cells can take some time. Using InitCell
' can cut this time in half.
'
'
PROGRAM	"xbgridfill"
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

$$MENU_FILE_EXIT = 100
$$MENU_FILE_FILL_INIT = 101
$$MENU_FILE_FILL_PUT = 102
$$BABYGRID1 = 110
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

' create one babygrid control
			#hGrid = NewChild ($$XBGRIDCLASSNAME, "Fill Grid Test", style, 0, 0, 0, 0, hWnd, $$BABYGRID1, $$WS_EX_CLIENTEDGE)

' make grid header row to initial height of 21 pixels
			SendMessageA (#hGrid, $$BGM_SETHEADERROWHEIGHT, 21, 0)

' load system wait cursor
			#hWait = LoadCursorA (0, $$IDC_WAIT)

		CASE $$WM_SIZE :
			GetClientRect (hWnd, &rc)
			MoveWindow (#hGrid, 0, 0, rc.right, rc.bottom, $$TRUE)

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			controlID = LOWORD (wParam)
			wmEvent   = HIWORD (wParam)

			SELECT CASE controlID
				CASE $$MENU_FILE_EXIT      : DestroyWindow (hWnd)
				CASE $$MENU_FILE_FILL_INIT : rows = 200 : GOSUB InitGrid
				CASE $$MENU_FILE_FILL_PUT  : rows = 200 : GOSUB FillGrid
				CASE ELSE :
					RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
			END SELECT

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

' ***** InitGrid *****
SUB InitGrid

  lastCursor = SetCursor (#hWait)  

' set grid dimensions
  cols = 256
	SendMessageA (#hGrid, $$BGM_SETGRIDDIM, rows, cols)

' disable redraw for listbox
'	SendMessageA (#hGrid, $$BGM_SETLISTBOXREDRAW, 0, 0)

' put some data in the cells in grid and time it
  start = GetTickCount ()
  count = 1
  FOR j = 1 TO rows
    FOR i = 1 TO cols
      data$ = STRING$ (count)
      InitCell (#hGrid, j, i, data$)
      INC count
    NEXT i
  NEXT j
  time = GetTickCount () - start

' enable redraw for listbox
'  SendMessageA (#hGrid, $$BGM_SETLISTBOXREDRAW, 1, 0)

' put time to load in cell 1, 1
  data$ = STRING$ (time)
  PutCell (#hGrid, 1, 1, data$)
  
  SetCursor (lastCursor)
END SUB

END FUNCTION

	
' ***** FillGrid *****
SUB FillGrid

  lastCursor = SetCursor (#hWait)  

' set grid dimensions
  cols = 256
	SendMessageA (#hGrid, $$BGM_SETGRIDDIM, rows, cols)

' disable redraw for listbox
'	SendMessageA (#hGrid, $$BGM_SETLISTBOXREDRAW, 0, 0)

' put some data in the cells in grid and time it
  start = GetTickCount ()
  count = 1
  FOR j = 1 TO rows
    FOR i = 1 TO cols
      data$ = STRING$ (count)
      PutCell (#hGrid, j, i, data$)
      INC count
    NEXT i
  NEXT j
  time = GetTickCount () - start

' enable listbox redraw
'  SendMessageA (#hGrid, $$BGM_SETLISTBOXREDRAW, 1, 0)

' put time to load in cell 1, 1
  data$ = STRING$ (time)
  PutCell (#hGrid, 1, 1, data$)
  
  SetCursor (lastCursor)
END SUB

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
	className$  = "GridFillTest"
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
END PROGRAM
