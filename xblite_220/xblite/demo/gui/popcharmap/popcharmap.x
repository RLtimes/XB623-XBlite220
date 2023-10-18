'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A character map dialog box. Double-click to
' select a character. Left click to display 
' zoomed character.
'
PROGRAM	"popcharmap"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll

TYPE TDLGDATA
	DLGTEMPLATE	.dltt
	USHORT	.menu
	USHORT	.class
	USHORT	.title
END TYPE

TYPE CHARMAPINFO
	STRING * 64 .font
	XLONG .fontsize
	XLONG .zoomfontsize
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewDialogBox (hWndParent, x, y, width, height, dlgProcAddr, initParam)
DECLARE FUNCTION  CharMapProc (hwndDlg, uMsg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
'DECLARE FUNCTION StaticProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION KBHookProc (code, wParam, lParam)
DECLARE FUNCTION DrawLineStatic (hWnd, x1, y1, x2, y2, color)

'Control IDs

$$Menu_File_Exit = 500
$$Menu_File_Dialog = 501

' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured

'	XioCreateConsole (title$, 250)	' create console, if console is not wanted, comment out this line
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

	CHARMAPINFO cmi

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND : 
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			
			SELECT CASE TRUE
				
				CASE id = $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE id = $$Menu_File_Dialog :
					cmi.font = "Courier New"
					cmi.fontsize = 10
					cmi.zoomfontsize = 48
					ID = NewDialogBox (hWnd, 100, 100, 0, 0, &CharMapProc(), &cmi)
					SELECT CASE ID :
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

	SHARED className$

' register window class
	className$  = "CharMapDialogBox"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Character Map Dialog Box."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 200
	h 					= 100
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

' build a main menu
	#mainMenu = CreateMenu()				' create main menu

' build dropdown submenus
	#fileMenu = CreateMenu()				' create dropdown file menu
	InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Dialog, &"&Show CharacterMap Dialog")

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
	style = style | $$WS_CHILD
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
' #############################
' #####  NewDialogBox ()  #####
' #############################
'
FUNCTION  NewDialogBox (hWndParent, x, y, width, height, dlgProcAddr, initParam)

	SHARED hInst
	TDLGDATA tdd				' user defined in this program
	DLGTEMPLATE dltt

' fill in DLGTEMPLATE struct
	dltt.style 	= $$DS_MODALFRAME | $$DS_3DLOOK | $$WS_POPUP | $$WS_CAPTION | $$WS_SYSMENU | $$WS_VISIBLE | $$DS_ABSALIGN  | $$DS_SETFONT
	dltt.dwExtendedStyle 	= 0
	dltt.cdit 						= 0					' number of control items in dialog box, this creates an empty dialog box

	bu = GetDialogBaseUnits ()				' get dialog base units
	screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	screenHeight = GetSystemMetrics ($$SM_CYSCREEN)

	dialogUnitX = (x*4)/LOWORD(bu)
	dialogUnitY = (y*8)/HIWORD(bu)

	dltt.x = dialogUnitX
	dltt.y = dialogUnitY

	dialogUnitWidth = (width*4)/LOWORD(bu)		' convert width in pixels to dialog units
	dialogUnitHeight = (height*8)/HIWORD(bu)	' convert height in pixels to dialog units

	dltt.cx = dialogUnitWidth
	dltt.cy = dialogUnitHeight

' fill in TDLGDATA struct
	tdd.dltt 	= dltt
	tdd.menu 	= 0
	tdd.class = 0
	tdd.title = 0

' create dialog box
	RETURN DialogBoxIndirectParamA (hInst, &tdd, hWndParent, dlgProcAddr, initParam)

END FUNCTION
'
'
' ###########################
' #####  CharMapProc ()  ####
' ###########################
'
FUNCTION  CharMapProc (hwndDlg, msg, wParam, lParam)

	POINT pt
	CHARMAPINFO cmi
	STATIC hFont, hFontPop
	RECT rc, rd
	STATIC x0, y0, s, b
	SHARED selection
	STATIC lastSelection, hStatus
	SHARED hKeyHook, hWndDialog
	
	$OFFSET = 1024
	$POPOFFSET = 1280
	$STATUSBAR = 2000
	
	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			RtlMoveMemory (&cmi, lParam, SIZE(cmi))
			IF cmi.fontsize < 8 THEN cmi.fontsize = 8
'			SetWindowPos (hwndDlg, 0, 0, 0, 310, 328, $$SWP_NOZORDER | $$SWP_NOMOVE)
			width = 340
			height = 380
			SetWindowPos (hwndDlg, 0, 0, 0, width, height, $$SWP_NOZORDER | $$SWP_NOMOVE)
			hFont = NewFont (cmi.font, cmi.fontsize, $$FW_NORMAL, 0, 0)
			hFontPop = NewFont (cmi.font, cmi.zoomfontsize, $$FW_NORMAL, 0, 0)
	
			index = 0			' character index (0 - 255)
			id = $OFFSET	' control id start
			s = 19				' grid size
			b = 1					' gap size
			x0 = 8
			y0 = 8
			
			FOR i = 0 TO 15
				y = i * (s + b) + y0
				FOR j = 0 TO 15
					x = j * (s + b) + x0 
					hStatic = NewChild ("static", CHR$(index), $$SS_CENTER | $$WS_VISIBLE, x, y, s, s, hwndDlg, id, 0)
					IF hFont THEN SetNewFont (hStatic, hFont)
					INC index
					INC id
				NEXT j
			NEXT i

			spop = 72			' popup size
			index = 0	
			idpop = $POPOFFSET		
			FOR i = 0 TO 15
				y = i * (s + b) + y0
				FOR j = 0 TO 15
					x = j * (s + b) + x0
					hPopStatic = NewChild ("static", CHR$(index), $$SS_CENTER | $$SS_CENTERIMAGE, x+20, y+20, spop, spop, hwndDlg, idpop, $$WS_EX_CLIENTEDGE)
					IF hFontPop THEN SetNewFont (hPopStatic, hFontPop)
					ShowWindow (hPopStatic, $$SW_HIDE)
					INC index
					INC idpop
				NEXT j
			NEXT i
			
			' draw some border lines using static controls
			DrawLineStatic (hwndDlg, x0-1, y0-1, x0-1, 16 * (s + b) + y0 - 1, $$Grey)
			DrawLineStatic (hwndDlg, x0-1, y0-1, 16 * (s + b) + x0 - 1, y0-1, $$Grey)
			DrawLineStatic (hwndDlg, 16 * (s + b) + x0 - 1, y0-1, 16 * (s + b) + x0 - 1, 16 * (s + b) + y0 - 1, $$Grey)
			DrawLineStatic (hwndDlg, x0, 16 * (s + b) + y0 - 1, 16 * (s + b) + x0 - 2, 16 * (s + b) + y0 - 1, $$Grey)

			DrawLineStatic (hwndDlg, 16 * (s + b) + x0, y0-1, 16 * (s + b) + x0, 16 * (s + b) + y0, $$White)
			DrawLineStatic (hwndDlg, x0-1, 16 * (s + b) + y0, 16 * (s + b) + x0 - 1, 16 * (s + b) + y0, $$White)	
			
			' create a status bar
			text$ = " " + cmi.font 
			hStatus = CreateStatusWindowA ($$WS_VISIBLE | $$WS_CHILD, &text$, hwndDlg, $STATUSBAR)
			DIM widths[2]
			widths[0] = 160
			widths[1] = 240
			widths[2] = -1
			SendMessageA (hStatus, $$SB_SETPARTS, 3, &widths[])  
			
			' set text in title bar
			text$ = " ANSI Character Map for " 
			IF cmi.font THEN text$ = text$ + cmi.font
			SetWindowTextA (hwndDlg, &text$)
			
			selection = $OFFSET + 65   ' set selected character
			lastSelection = 0
			hWndDialog = hwndDlg
			
			' install a keyboard hook
			threadId = GetCurrentThreadId()
			hKeyHook = SetWindowsHookExA ($$WH_KEYBOARD, &KBHookProc(), GetModuleHandleA (0), threadId)
			
			'	redraw window
			InvalidateRect (hwndDlg, NULL, 0)
			
			RETURN 
			
		CASE $$WM_RBUTTONDOWN :
      pt.x = LOWORD(lParam)
      pt.y = HIWORD(lParam)
      ClientToScreen (hwndDlg, &pt)
      hWndPoint = WindowFromPoint (pt.x, pt.y)
      IFZ hWndPoint THEN RETURN
      ScreenToClient (hWndPoint, &pt)
      hWndChild = ChildWindowFromPoint (hWndPoint, pt.x, pt.y)
			id = GetDlgCtrlID (hWndChild)
			hPop = GetDlgItem (hwndDlg, id+256)
			GetClientRect (hPop, &rc)
			GetClientRect (hwndDlg, &rd)
			x = pt.x
			IF x + rc.right + 4 > rd.right THEN
				x = rd.right - rc.right - 12
			END IF
			y = pt.y - rc.bottom - 4
			IF y < 10 THEN y = 10
			SetWindowPos (hPop, 0, x, y, 0, 0, $$SWP_NOZORDER | $$SWP_NOSIZE)
			ShowWindow (hPop, $$SW_SHOW) 
			
			lastSelection = selection
			selection = id
			InvalidateRect (hWndChild, NULL, 1)					' set char selection color
			hLastSelection = GetDlgItem (hwndDlg, lastSelection) 
			InvalidateRect (hLastSelection, NULL, 1)		' set last selection back to white
			RETURN
			
		CASE $$WM_RBUTTONUP :
			FOR id = $POPOFFSET TO $POPOFFSET + 256
				hPop = GetDlgItem (hwndDlg, id)
				ShowWindow (hPop, $$SW_HIDE) 
			NEXT id 
			RETURN
			
		CASE $$WM_LBUTTONDBLCLK :
      pt.x = LOWORD(lParam)
      pt.y = HIWORD(lParam)
      ClientToScreen (hwndDlg, &pt)
      hWndPoint = WindowFromPoint (pt.x, pt.y)
      IFZ hWndPoint THEN RETURN
      ScreenToClient (hWndPoint, &pt)
      hWndChild = ChildWindowFromPoint (hWndPoint, pt.x, pt.y)
			id = GetDlgCtrlID (hWndChild)
			msg$ = "Selection: " + STRING$(id-$OFFSET) + ": " + CHR$(id-$OFFSET) '+ "   "
			MessageBoxA (hWnd, &msg$, &"Character Map Selection", 0)
			RETURN
			
		CASE $$WM_LBUTTONDOWN:
      pt.x = LOWORD(lParam)
      pt.y = HIWORD(lParam)
      ClientToScreen (hwndDlg, &pt)
      hWndPoint = WindowFromPoint (pt.x, pt.y)
      IFZ hWndPoint THEN RETURN
      ScreenToClient (hWndPoint, &pt)
      hWndChild = ChildWindowFromPoint (hWndPoint, pt.x, pt.y)
			id = GetDlgCtrlID (hWndChild)
			lastSelection = selection
			selection = id
			InvalidateRect (hWndChild, NULL, 1)					' set char selection color
			hLastSelection = GetDlgItem (hwndDlg, lastSelection) 
			InvalidateRect (hLastSelection, NULL, 1)		' set last selection back to white
			RETURN
			
		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE TRUE :
						CASE id = $$IDCANCEL :									' window close button pressed
							DeleteObject (hFont)
							DeleteObject (hFontPop)
							UnhookWindowsHookEx (hKeyHook)
							EndDialog (hwndDlg, ID)
					END SELECT
			END SELECT
			
		CASE $$WM_CTLCOLORSTATIC :
'			hdcStatic = wParam
'			hStatic = lParam

			ID = GetDlgCtrlID (lParam)
			
			' set statusbar text
			IF ID = selection THEN
				chr = ID - $OFFSET
				c$ = STRING$(chr)
				SELECT CASE LEN(c$)
					CASE 1 : alt$ = " Alt + 000" + c$
					CASE 2 : alt$ = " Alt + 00"  + c$
					CASE 3 : alt$ = " Alt + 0"   + c$
				END SELECT
				SendMessageA (hStatus, $$SB_SETTEXT, 1, &alt$)
				ch$ = " Char: " + CHR$(chr)
				SendMessageA (hStatus, $$SB_SETTEXT, 2, &ch$)
			END IF
			
			' set color of controls
			IF ID = selection THEN 
				RETURN SetColor (RGB(255, 255, 255), RGB(0, 0, 160), wParam, lParam)	' white text, blue background
			ELSE
				RETURN SetColor (RGB(0, 0, 0), RGB(255, 255, 255), wParam, lParam)  	' black text, white background
			END IF

		CASE ELSE :	RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

END FUNCTION

' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush (bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush

END FUNCTION
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
	lf.underline = underline										' set underline (0 or 1)
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION

'
' ###########################
' #####  SetNewFont ()  #####
' ###########################
'
FUNCTION  SetNewFont (hwndCtl, hFont)

	SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)

END FUNCTION
'
' ###########################
' #####  KBHookProc ()  #####
' ###########################
'
FUNCTION KBHookProc (code, wParam, lParam)

	SHARED hKeyHook, hWndDialog
	SHARED selection
	USHORT state
	
	$OFFSET = 1024
	
	IF nCode < 0 THEN RETURN CallNextHookEx (hKeyHook, code, wParam, lParam)

	SELECT CASE code
		CASE $$HC_ACTION :						' message from keyboard
			virtKey = wParam						' wParam specifies virtual-key code
			state = HIWORD (lParam)
			IF  !(state & $$KF_UP) && !(state & $$KF_REPEAT) THEN
				prevSelection = selection
				SELECT CASE virtKey
					CASE $$VK_LEFT		: DEC selection 
					CASE $$VK_RIGHT		: INC selection
					CASE $$VK_UP			: selection = selection - 16
					CASE $$VK_DOWN		: selection = selection + 16
					CASE $$VK_HOME		: selection = (((selection - $OFFSET) \ 16) * 16) + $OFFSET 
					CASE $$VK_END			: selection = (((selection - $OFFSET) \ 16) * 16 + 15) + $OFFSET
					CASE $$VK_PRIOR		: selection = ((selection - $OFFSET) MOD 16) + $OFFSET
					CASE $$VK_NEXT		: selection = ((selection - $OFFSET) MOD 16 + 240) + $OFFSET
				END SELECT
				IF selection > $OFFSET + 255 || selection < $OFFSET THEN
					selection = prevSelection
				ELSE
					hs = GetDlgItem (hWndDialog, selection)
					hp = GetDlgItem (hWndDialog, prevSelection)
					InvalidateRect (hs, NULL, 1)
					InvalidateRect (hp, NULL, 1)
				END IF
			END IF
	END SELECT

	RETURN CallNextHookEx (hKeyHook, code, wParam, lParam)

END FUNCTION

FUNCTION DrawLineStatic (hWnd, x1, y1, x2, y2, color)

	' for color use $$Black, $$White, or $$Gray
	SELECT CASE color
		CASE $$Black: style = $$SS_BLACKRECT
		CASE $$White: style = $$SS_WHITERECT
		CASE $$Grey:	style = $$SS_GRAYRECT
		CASE ELSE:		style = $$SS_BLACKRECT
	END SELECT
	NewChild ("static", "", style | $$WS_VISIBLE, x1, y1, x2-x1+1, y2-y1+1, hWnd, -1, 0)

END FUNCTION

END PROGRAM
