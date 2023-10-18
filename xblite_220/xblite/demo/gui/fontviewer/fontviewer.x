'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo which enumerates fonts and
' displays them in a dialog window.
'
PROGRAM	"fontviewer"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)
DECLARE FUNCTION  GetComboboxTextSelection (hWnd, @selection$)
DECLARE FUNCTION  AddPointSizeToComboBox (hWnd, pt)
DECLARE FUNCTION  EnumFontSize (LOGFONT lf, TEXTMETRIC tm, fontType, hWndAddr)
DECLARE FUNCTION  FillSizeCombo (font$, hWnd)
DECLARE FUNCTION  EnumFontName (LOGFONT lf, TEXTMETRIC tm, fontType, hWndAddr)
DECLARE FUNCTION  FillFontCombo (hWnd)
DECLARE FUNCTION  FontProc (hDlg, msg, wParam, lParam)
DECLARE FUNCTION  FontShowProc (hWnd, msg, wParam, lParam)
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
	CleanUp ()										' unregister all window classes
'	XioFreeConsole ()							' free console

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

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	SHARED className$, hInst
	WNDCLASS wc
	SHARED cyPixels

' register FONTVIEW window class
	className$  = "FONTVIEW"

	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &FontShowProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 8						' extra bytes required for dialog windows
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"scrabble")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$WHITE_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

' Get font pixel size for desktop fonts
  hDC = GetDC (0)
  cyPixels  = GetDeviceCaps (hDC, $$LOGPIXELSY)
  ReleaseDC (0, hDC)

' Display the dialog
  DialogBoxParamA (hInst, 200, GetDesktopWindow (), &FontProc(), 0)

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
' ########################
' #####  NewFont ()  #####
' ########################
'
FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline, angle#)

	LOGFONT lf
	hDC = GetDC ($$HWND_DESKTOP)
	hFont = GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes = GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName = fontName$											' set font name
	lf.italic = italic													' set italic
	lf.weight = weight													' set weight
	lf.underline = underline										' set underline
	lf.escapement = angle# * 10									' set text rotation
	lf.height = -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)						' create a new font and get handle

END FUNCTION
'
'
' #########################################
' #####  GetComboboxTextSelection ()  #####
' #########################################
'
FUNCTION  GetComboboxTextSelection (hWnd, @selection$)

	sel = SendMessageA (hWnd, $$CB_GETCURSEL, 0, 0)
	selection$ = NULL$ (256)
  SendMessageA (hWnd, $$CB_GETLBTEXT, sel, &selection$)
	selection$ = TRIM$ (selection$)

END FUNCTION
'
'
' #######################################
' #####  AddPointSizeToComboBox ()  #####
' #######################################
'
FUNCTION  AddPointSizeToComboBox (hWnd, pt)

  text$ = FORMAT$ ("##", pt)
  IF SendMessageA (hWnd, $$CB_FINDSTRINGEXACT, -1, &text$) = $$CB_ERR THEN
    SendMessageA (hWnd, $$CB_ADDSTRING, 0, &text$)
  END IF

END FUNCTION
'
'
' #############################
' #####  EnumFontSize ()  #####
' #############################
'
FUNCTION  EnumFontSize (LOGFONT lf, TEXTMETRIC tm, fontType, hWndAddr)

	SHARED cyPixels

	hWnd = XLONGAT (hWndAddr)

	IF fontType = $$RASTER_FONTTYPE THEN
		x = MulDiv (tm.height - tm.internalLeading, 72, cyPixels)
		AddPointSizeToComboBox (hWnd, x)
	ELSE
		AddPointSizeToComboBox (hWnd, 8)
		AddPointSizeToComboBox (hWnd, 9)
		AddPointSizeToComboBox (hWnd, 10)
		AddPointSizeToComboBox (hWnd, 11)
		AddPointSizeToComboBox (hWnd, 12)
		AddPointSizeToComboBox (hWnd, 14)
		AddPointSizeToComboBox (hWnd, 16)
		AddPointSizeToComboBox (hWnd, 18)
    AddPointSizeToComboBox (hWnd, 20)
		AddPointSizeToComboBox (hWnd, 22)
    AddPointSizeToComboBox (hWnd, 24)
    AddPointSizeToComboBox (hWnd, 26)
    AddPointSizeToComboBox (hWnd, 28)
    AddPointSizeToComboBox (hWnd, 32)
    AddPointSizeToComboBox (hWnd, 36)
  END IF

	RETURN (1)

END FUNCTION
'
'
' ##############################
' #####  FillSizeCombo ()  #####
' ##############################
'
FUNCTION  FillSizeCombo (font$, hWnd)

	STATIC hCtl

	hCtl = hWnd

	SendMessageA (hWnd, $$CB_RESETCONTENT, 0, 0)
  hDC = GetDC (0)
	EnumFontsA (hDC, &font$, &EnumFontSize(), &hCtl)
  ReleaseDC (0, hDC)

  SendMessageA (hWnd, $$CB_SETCURSEL, 0, 0)

END FUNCTION
'
'
' #############################
' #####  EnumFontName ()  #####
' #############################
'
FUNCTION  EnumFontName (LOGFONT lf, TEXTMETRIC tm, fontType, hWndAddr)

	hWnd = XLONGAT (hWndAddr)

  SendMessageA (hWnd, $$CB_ADDSTRING, 0, &lf.faceName)

  RETURN (1)

END FUNCTION
'
'
' ##############################
' #####  FillFontCombo ()  #####
' ##############################
'
FUNCTION  FillFontCombo (hWnd)

	SendMessageA (hWnd, $$CB_RESETCONTENT, 0, 0)

	hDC = GetDC (0)
	EnumFontsA (hDC, NULL, &EnumFontName(), &hWnd)
	ReleaseDC (0, hDC)

	SendMessageA (hWnd, $$CB_SETCURSEL, 0, 0)

END FUNCTION
'
'
' #########################
' #####  FontProc ()  #####
' #########################
'
FUNCTION  FontProc (hDlg, msg, wParam, lParam)

	STATIC hCbFont
	STATIC hCbSize
	STATIC hShowFont
	STATIC hBold, hUnderline, hItalic
	SHARED hFontTest

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			hBold      = GetDlgItem (hDlg, 98)
			hUnderline = GetDlgItem (hDlg, 99)
			hItalic    = GetDlgItem (hDlg, 100)
			hCbFont    = GetDlgItem (hDlg, 101)
			hCbSize    = GetDlgItem (hDlg, 102)
			hShowFont  = GetDlgItem (hDlg, 103)

' Init font combobox
			FillFontCombo (hCbFont)
			SendMessageA (hCbFont, $$CB_SETCURSEL, indx, 0)

' Init font size combobox
			GetComboboxTextSelection (hCbFont, @font$)
			FillSizeCombo (font$, hCbSize)
      SendMessageA (hCbSize, $$CB_SETCURSEL, 10, 0)

			GOSUB SetFontSelection
			XstCenterWindow (hDlg)

		CASE $$WM_COMMAND :
			id = LOWORD (wParam)
			code = HIWORD (wParam)
			hCtl = lParam

			SELECT CASE id

				CASE 101 :
					IF code = $$CBN_SELCHANGE THEN

						GetComboboxTextSelection (hCbSize, @pt$)

						GetComboboxTextSelection (hCbFont, @font$)
            FillSizeCombo (font$, hCbSize)

						x = SendMessageA (hCbSize, $$CB_FINDSTRINGEXACT, -1, &pt$)

						IF x = $$CB_ERR THEN
							SendMessageA (hCbSize, $$CB_SETCURSEL, 0, 0)
						ELSE
							SendMessageA (hCbSize, $$CB_SETCURSEL, x, 0)
						END IF

						GOSUB SetFontSelection
          END IF

        CASE 102 :
          IF code = $$CBN_SELCHANGE THEN
						GOSUB SetFontSelection
          END IF

				CASE 98, 99, 100 :
					IF code = $$BN_CLICKED : THEN
						GOSUB SetFontSelection
					END IF

				CASE $$IDOK :
					IF hFontTest THEN DeleteObject (hFontTest)
					EndDialog (hDlg, 1)

				CASE $$IDCANCEL :
					IF hFontTest THEN DeleteObject (hFontTest)
					EndDialog (hDlg, 0)

			END SELECT

		CASE ELSE : RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

' ***** SetFontSelection *****
SUB SetFontSelection

	GetComboboxTextSelection (hCbFont, @font$)
	GetComboboxTextSelection (hCbSize, @pt$)
	pointSize = XLONG (pt$)

	IF SendMessageA (hBold, $$BM_GETCHECK, 0, 0) = $$BST_CHECKED THEN
		weight = 600
	ELSE
		weight = 400
	END IF

	IF SendMessageA (hUnderline, $$BM_GETCHECK, 0, 0) = $$BST_CHECKED THEN
		underline = $$TRUE
	ELSE
		underline = $$FALSE
	END IF

	IF SendMessageA (hItalic, $$BM_GETCHECK, 0, 0) = $$BST_CHECKED THEN
		italic = $$TRUE
	ELSE
		italic = $$FALSE
	END IF

	IF hFontTest THEN DeleteObject (hFontTest)
	hFontTest = NewFont (font$, pointSize, weight, italic, underline, angle#)
	InvalidateRect (hShowFont, NULL, $$TRUE)
END SUB

END FUNCTION
'
'
' #############################
' #####  FontShowProc ()  #####
' #############################
'
FUNCTION  FontShowProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT rc
	SHARED hFontTest

	SELECT CASE msg

		CASE $$WM_PAINT :
			hDC = BeginPaint (hWnd, &ps)
			old = SelectObject (hDC, hFontTest)
			GetClientRect (hWnd, &rc)
			DrawTextA (hDC, &"AaBbCcXxYyZz", -1, &rc, $$DT_SINGLELINE OR $$DT_CENTER OR $$DT_VCENTER)
			SelectObject (hDC, old)
      EndPaint (hDC, &ps)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT
END FUNCTION
END PROGRAM
