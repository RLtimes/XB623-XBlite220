'
'
' ####################
' #####  PROLOG  #####
' ####################

' A color mixer example which uses
' scrollbars to mix RGB colors.
'
PROGRAM	"colormixer"
VERSION	"0.0003"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xst_s.lib"
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
EXPORT
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
DECLARE FUNCTION  ComboBoxSelChange (hWnd)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  UpdateHexDisplay ()
DECLARE FUNCTION  UpdateScrollbars (hWnd, code, pos)
DECLARE FUNCTION  EditBoxChange (hwndCtl)
END EXPORT

'Control IDs
$$ComboboxColors  = 101
$$StaticHexText = 103
$$StaticColorMix = 104
$$StaticColorBlue = 105
$$StaticColorGreen = 106
$$StaticColorRed = 107
$$TextBoxBlue = 108
$$TextBoxGreen = 109
$$TextBoxRed = 110
$$SBarBlue = 111
$$SBarGreen = 112
$$SBarRed = 113
$$Label1 = 114
$$Label2 = 115
$$Label3 = 116
$$Label4 = 117
$$Label5 = 118
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

	SCROLLINFO si
	STATIC STRING arr[]
	SHARED cdata[]
	SHARED hNewBrush

	SELECT CASE msg

		CASE $$WM_CREATE :

' create controls
			#hScrollBar1 = NewChild ("scrollbar", "", $$SBS_HORZ | $$WS_TABSTOP, 42,  6, 223, 21, hWnd, $$SBarRed, 0)
			#hEdit1      = NewChild ("edit", "0", $$ES_NUMBER | $$WS_TABSTOP, 272,  6, 31, 21, hWnd, $$TextBoxRed, $$WS_EX_CLIENTEDGE)

			#hScrollBar2 = NewChild ("scrollbar", "", $$SBS_HORZ | $$WS_TABSTOP, 42, 30, 223, 21, hWnd, $$SBarGreen, 0)
			#hEdit2      = NewChild ("edit", "0", $$ES_NUMBER | $$WS_TABSTOP, 272, 30, 31, 21, hWnd, $$TextBoxGreen, $$WS_EX_CLIENTEDGE)

			#hScrollBar3 = NewChild ("scrollbar", "", $$SBS_HORZ | $$WS_TABSTOP, 42, 54, 223, 21, hWnd, $$SBarBlue, 0)
			#hEdit3      = NewChild ("edit", "0", $$ES_NUMBER | $$WS_TABSTOP, 272, 54, 31, 21, hWnd, $$TextBoxBlue, $$WS_EX_CLIENTEDGE)


			#hEdit4      = NewChild ("edit", "0x000000", $$ES_READONLY | $$ES_CENTER | $$WS_TABSTOP, 148, 84, 82, 21, hWnd, $$StaticHexText, $$WS_EX_CLIENTEDGE)
			#hCombobox1  = NewChild ("combobox", "", $$CBS_DROPDOWNLIST | $$WS_VSCROLL | $$WS_TABSTOP, 272, 84, 113, 100, hWnd, $$ComboboxColors, $$WS_EX_CLIENTEDGE)

			#hStatic2    = NewChild ("static", "", $$SS_CENTER, 350,  6, 35, 69, hWnd, $$StaticColorMix, $$WS_EX_CLIENTEDGE)
			#hStatic5    = NewChild ("static", "", $$SS_CENTER, 312, 54, 35, 21, hWnd, $$StaticColorBlue, $$WS_EX_CLIENTEDGE)
			#hStatic4    = NewChild ("static", "", $$SS_CENTER, 312, 30, 35, 21, hWnd, $$StaticColorGreen, $$WS_EX_CLIENTEDGE)
			#hStatic3    = NewChild ("static", "", $$SS_CENTER, 312,  6, 35, 21, hWnd, $$StaticColorRed, $$WS_EX_CLIENTEDGE)

			#hStatic6    = NewChild ("static", "Colors:", $$SS_RIGHT, 230, 87, 40, 13, hWnd, $$Label1, 0)
			#hStatic7    = NewChild ("static", "Hex:",    $$SS_RIGHT, 122, 87, 22, 13, hWnd, $$Label2, 0)
			#hStatic8    = NewChild ("static", "Blue:",   $$SS_RIGHT,   3, 58, 35, 13, hWnd, $$Label3, 0)
			#hStatic9    = NewChild ("static", "Green:",  $$SS_RIGHT,   3, 34, 35, 13, hWnd, $$Label4, 0)
			#hStatic10   = NewChild ("static", "Red:",   $$SS_RIGHT,   3, 10, 35, 13, hWnd, $$Label5, 0)

' create fonts
			#hFontMS9   = NewFont ("MS Sans Serif", 9, 400, 0, 0)
			#hFontMS10B = NewFont ("MS Sans Serif", 10, 600, 0, 0)

' set fonts
			SendMessageA (#hEdit1, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hEdit2, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hEdit3, $$WM_SETFONT, #hFontMS9, $$TRUE)

			SendMessageA (#hCheck1, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hCombobox1, $$WM_SETFONT, #hFontMS9, $$TRUE)

			SendMessageA (#hEdit4, $$WM_SETFONT, #hFontMS10B, $$TRUE)

			SendMessageA (#hStatic2, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic3, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic4, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic5, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic6, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic7, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic8, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic9, $$WM_SETFONT, #hFontMS9, $$TRUE)
			SendMessageA (#hStatic10, $$WM_SETFONT, #hFontMS9, $$TRUE)

' init scrollbars
			si.cbSize = SIZE (si)
			si.fMask  = $$SIF_ALL
			si.nMin   = 0										' set min scroll value
			si.nPage  = 18									' set thumb size
			si.nMax   = 255 + (si.nPage-1)	' set max scroll value
			si.nPos   = 0										' set init position
			SetScrollInfo (#hScrollBar1, $$SB_CTL, &si, $$TRUE)
			SetScrollInfo (#hScrollBar2, $$SB_CTL, &si, $$TRUE)
			SetScrollInfo (#hScrollBar3, $$SB_CTL, &si, $$TRUE)

' init combobox
' create items for combo list
			DIM arr[23]
  		arr[0]  = "Black"         : arr[1]  = "White"
  		arr[2]  = "Red"           : arr[3]  = "Green"
  		arr[4]  = "Blue"          : arr[5]  = "Red (Dark)"
  		arr[6]  = "Green (Dark)"  : arr[7]  = "Blue (Dark)"
  		arr[8]  = "Cyan"    			: arr[9]  = "Yellow"
  		arr[10] = "Pink"    			: arr[11] = "Pink (Dark)"
  		arr[12] = "Purple"    		: arr[13] = "Orange"
  		arr[14] = "Brown" 				: arr[15] = "Teal"
  		arr[16] = "Violet"  			: arr[17] = "Gray"
  		arr[18] = "Gray (Dark)"  	: arr[19] = "Tan"
  		arr[20] = "Peach"  				: arr[21] = "Sand"
  		arr[22] = "Lime"					: arr[23] = "Magenta"

			DIM cdata[23]
			cdata[0]  = RGB (0, 0, 0)				: cdata[1]  = RGB (255, 255, 255)
			cdata[2]  = RGB (255, 0, 0)			: cdata[3]  = RGB (0, 255, 0)
			cdata[4]  = RGB (0, 0, 255)			: cdata[5]  = RGB (153, 0, 0)
			cdata[6]  = RGB (0, 153, 0)			: cdata[7]  = RGB (0, 0, 153)
			cdata[8]  = RGB (0, 255, 255)		: cdata[9]  = RGB (255, 255, 0)
			cdata[10] = RGB (255, 204, 255)	: cdata[11] = RGB (255, 0, 153)
			cdata[12] = RGB (153, 0, 255)		: cdata[13] = RGB (255, 153, 51)
			cdata[14] = RGB (204, 153, 0)		: cdata[15] = RGB (0, 153, 153)
			cdata[16] = RGB (153, 0, 153)		: cdata[17] = RGB (204, 204, 204)
			cdata[18] = RGB (153, 153, 153)	: cdata[19] = RGB (255, 204, 153)
			cdata[20] = RGB (255, 204, 204) : cdata[21] = RGB (204, 204, 153)
			cdata[22] = RGB (204, 255, 51) 	: cdata[23] = RGB (255, 0, 255)

' set combobox text items
			IF #hCombobox1 THEN
				FOR i = 0 TO UBOUND (arr[])
					SendMessageA (#hCombobox1, $$CB_ADDSTRING, 0, &arr[i])
				NEXT i
			END IF

' set current selection
			SendMessageA (#hCombobox1, $$CB_SETCURSEL, 0, 0)

' limit text in edit boxes to 3 chars
			SendMessageA (#hEdit1, $$EM_LIMITTEXT, 3, 0)
			SendMessageA (#hEdit2, $$EM_LIMITTEXT, 3, 0)
			SendMessageA (#hEdit3, $$EM_LIMITTEXT, 3, 0)

		CASE $$WM_DESTROY:
			DeleteObject (#hFontMS9)
			DeleteObject (#hFontMS10B)
			DeleteObject (hNewBrush)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD (wParam)
			cntlID = LOWORD (wParam)
			hwndCtl = lParam

			SELECT CASE notifyCode
				CASE $$CBN_SELCHANGE : ComboBoxSelChange (hwndCtl)
				CASE $$EN_SETFOCUS   : PostMessageA (hwndCtl, $$EM_SETSEL, 0, -1)
				CASE $$EN_CHANGE     : EditBoxChange (hwndCtl)
				CASE $$EN_KILLFOCUS  :
          ' validate editbox entry for NULL
					IF hwndCtl = #hEdit4 THEN RETURN
					value$ = NULL$ (8)
					GetWindowTextA (hwndCtl, &value$, LEN (value$))
					value$ = TRIM$ (value$)
					IFZ value$ THEN
						SetWindowTextA (hwndCtl, &"0")
					END IF
			END SELECT

		CASE $$WM_HSCROLL :
			code = LOWORD (wParam)
			pos = HIWORD (wParam)
			hwndScrollBar = lParam
			UpdateScrollbars (hwndScrollBar, code, pos)
			SELECT CASE hwndScrollBar
				CASE #hScrollBar1 :
					pos = GetScrollPos (hwndScrollBar, $$SB_CTL)
					r$ = STRING (pos)
					SetWindowTextA (#hEdit1, &r$)
					InvalidateRect (#hStatic3, NULL, $$TRUE)

				CASE #hScrollBar2 :
					pos = GetScrollPos (hwndScrollBar, $$SB_CTL)
					b$ = STRING (pos)
					SetWindowTextA (#hEdit2, &b$)
					InvalidateRect (#hStatic4, NULL, $$TRUE)

				CASE #hScrollBar3 :
					pos = GetScrollPos (hwndScrollBar, $$SB_CTL)
					g$ = STRING (pos)
					SetWindowTextA (#hEdit3, &g$)
					InvalidateRect (#hStatic5, NULL, $$TRUE)
			END SELECT
			InvalidateRect (#hStatic2, NULL, $$TRUE)

		CASE $$WM_CTLCOLORSTATIC :
' set background colors in static controls
' to display RGB colors

			hCtl = lParam

			r$ = NULL$ (8)
			GetWindowTextA (#hEdit1, &r$, LEN(r$))
			r = XLONG (TRIM$ (r$))

			g$ = NULL$ (8)
			GetWindowTextA (#hEdit2, &g$, LEN(g$))
			g = XLONG (TRIM$ (g$))

			b$ = NULL$ (8)
			GetWindowTextA (#hEdit3, &b$, LEN(b$))
			b = XLONG (TRIM$ (b$))

			c = r + (256*g) + (65536*b)

			SELECT CASE hCtl
				CASE #hStatic2 : RETURN SetColor (0, c, wParam, lParam)
				CASE #hStatic3 : RETURN SetColor (0, RGB (r, 0, 0), wParam, lParam)
				CASE #hStatic4 : RETURN SetColor (0, RGB (0, g, 0), wParam, lParam)
				CASE #hStatic5 : RETURN SetColor (0, RGB (0, 0, b), wParam, lParam)
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

	hInst = GetModuleHandleA (0) 	' get current instance handle
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

	SHARED hInst, className$

' register window class
	className$  = "ColorMixer"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Color Mixer."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 389 + 8
	h 					= 113 + 24
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, $$WS_EX_TOOLWINDOW	)

	XstCenterWindow (#winMain)							' center window position
	UpdateWindow (#winMain)
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

	SetFocus (#hScrollBar1)

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

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, 0, 0, 0)			' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
        hwnd = GetActiveWindow ()
        IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN
  				TranslateMessage (&msg)						' translate virtual-key messages into character messages
  				DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
	UnregisterClassA (&className$, hInst)

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
' ##################################
' #####  ComboBoxSelChange ()  #####
' ##################################
'
FUNCTION  ComboBoxSelChange (hWnd)

	SHARED cdata[]

' get current item selected
	item = SendMessageA (hWnd, $$CB_GETCURSEL, 0, 0)
	IF item = $$CB_ERR THEN RETURN

	c = cdata[item]

' set edit boxes text
	txtRed$ = STRING (c MOD 256)
	SetWindowTextA (#hEdit1, &txtRed$)

	txtGreen$ = STRING ((c\256) MOD 256)
	SetWindowTextA (#hEdit2, &txtGreen$)

	txtBlue$ = STRING ((c\65536) MOD 256)
	SetWindowTextA (#hEdit3, &txtBlue$)

' set scrollbar positions
	red = XLONG (txtRed$)
	blue = XLONG (txtBlue$)
	green = XLONG (txtGreen$)

	SetScrollPos (#hScrollBar1, $$SB_CTL, red, $$TRUE)
	SetScrollPos (#hScrollBar2, $$SB_CTL, green, $$TRUE)
	SetScrollPos (#hScrollBar3, $$SB_CTL, blue, $$TRUE)

' set colors of static color display boxes
' by sending WM_CTLCOLORSTATIC msg to control
	InvalidateRect (#hStatic2, NULL, $$TRUE)
	InvalidateRect (#hStatic3, NULL, $$TRUE)
	InvalidateRect (#hStatic4, NULL, $$TRUE)
	InvalidateRect (#hStatic5, NULL, $$TRUE)

' update color hex value in edit box
	UpdateHexDisplay ()

END FUNCTION
'
'
' #########################
' #####  SetColor ()  #####
' #########################
'
FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)

	SHARED hNewBrush

	SetTextColor (wParam, txtColor)
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetBkColor (wParam, bkColor)
	RETURN hNewBrush


END FUNCTION
'
'
' #################################
' #####  UpdateHexDisplay ()  #####
' #################################
'
FUNCTION  UpdateHexDisplay ()

	STATIC hex$

	txt$ = NULL$ (8)
	GetWindowTextA (#hEdit1, &txt$, LEN(txt$))
	txt$ = TRIM$ (txt$)
	r$ = HEX$ (XLONG(txt$))
	IF LEN (r$) = 1 THEN r$ = "0" + r$

	txt$ = NULL$ (8)
	GetWindowTextA (#hEdit2, &txt$, LEN(txt$))
	txt$ = TRIM$ (txt$)
	g$ = HEX$ (XLONG(txt$))
	IF LEN (g$) = 1 THEN g$ = "0" + g$

	txt$ = NULL$ (8)
	GetWindowTextA (#hEdit3, &txt$, LEN(txt$))
	txt$ = TRIM$ (txt$)
	b$ = HEX$ (XLONG(txt$))
	IF LEN (b$) = 1 THEN b$ = "0" + b$

	hex$ = "0x" + b$ + g$ + r$
	SendMessageA (#hEdit4, $$WM_SETTEXT, 0, &hex$)

END FUNCTION
'
'
' #################################
' #####  UpdateScrollbars ()  #####
' #################################
'
FUNCTION  UpdateScrollbars (hWnd, code, pos)

  SELECT CASE code

		CASE $$SB_LINEDOWN:       ' Scrolls one line down
			SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) + 1, $$TRUE)
			RETURN

		CASE $$SB_LINEUP:         ' Scrolls one line up
			SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) - 1, $$TRUE)
			RETURN

		CASE $$SB_PAGEDOWN:       ' Scrolls one page down
      SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) + 10, $$TRUE)
			RETURN

		CASE $$SB_PAGEUP:         	' Scrolls one page up
      SetScrollPos (hWnd, $$SB_CTL, GetScrollPos (hWnd, $$SB_CTL) - 10, $$TRUE)
			RETURN

		CASE $$SB_THUMBPOSITION:  ' The user has dragged the scroll box (thumb) and released the mouse button. The nPos parameter indicates the position of the scroll box at the end of the drag operation.
			RETURN

		CASE $$SB_THUMBTRACK:     	' The user is dragging the scroll box. This message is sent repeatedly until the user releases the mouse button. The nPos parameter indicates the position that the scroll box has been dragged to.
			SetScrollPos (hWnd, $$SB_CTL, pos, $$TRUE)
			RETURN

	END SELECT

END FUNCTION
'
'
' ##############################
' #####  EditBoxChange ()  #####
' ##############################
'
FUNCTION  EditBoxChange (hwndCtl)

  STATIC lastRed, lastGreen, lastBlue

  SELECT CASE hwndCtl
    CASE #hEdit1, #hEdit2, #hEdit3:
    CASE ELSE : RETURN
  END SELECT

' get editbox value and validate it
	value$ = NULL$ (8)
	GetWindowTextA (hwndCtl, &value$, LEN (value$))
	value$ = TRIM$ (value$)
	IF value$ THEN
		value = XLONG (TRIM$ (value$))
		IF value > 255 THEN
			value = 255
			SetWindowTextA (hwndCtl, &"255")
		END IF
	END IF

' update scrollbars and colors in static controls

	SELECT CASE GetDlgCtrlID (hwndCtl)
		CASE $$TextBoxRed   : 
      IF value <> lastRed THEN
        InvalidateRect (#hStatic3, NULL, $$TRUE)
				SetScrollPos (#hScrollBar1, $$SB_CTL, value, $$TRUE)
				InvalidateRect (#hStatic2, NULL, $$TRUE)
				lastRed = value
			END IF
		CASE $$TextBoxGreen :
      IF value <> lastGreen THEN
        InvalidateRect (#hStatic4, NULL, $$TRUE)
				SetScrollPos (#hScrollBar2, $$SB_CTL, value, $$TRUE)
				InvalidateRect (#hStatic2, NULL, $$TRUE)
				lastGreen = value
			END IF
		CASE $$TextBoxBlue  :
      IF value <> lastBlue THEN
        InvalidateRect (#hStatic5, NULL, $$TRUE)
			  SetScrollPos (#hScrollBar3, $$SB_CTL, value, $$TRUE)
			  InvalidateRect (#hStatic2, NULL, $$TRUE)
			  lastBlue = value
			END IF
	END SELECT

	UpdateHexDisplay ()

END FUNCTION
END PROGRAM
