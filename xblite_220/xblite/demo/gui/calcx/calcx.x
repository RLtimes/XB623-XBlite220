'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A simple calculator. Based on BCX demo program
' by Kevin Diggins.
'
PROGRAM	"calcx"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"xma"				' math library
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
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION  ProcessNumber (digit)
DECLARE FUNCTION  ProcessOperator (operator)
DECLARE FUNCTION  ScaleDialogToScreen (@scaleX, @scaleY)
DECLARE FUNCTION  GetText$ (hWnd)
DECLARE FUNCTION  SetText (hWnd, text$)

'Control IDs
$$Edit = 99

$$Button0 = 100
$$Button1 = 101
$$Button2 = 102
$$Button3 = 103
$$Button4 = 104
$$Button5 = 105
$$Button6 = 106
$$Button7 = 107
$$Button8 = 108
$$Button9 = 109
$$ButtonDOT = 110

$$ButtonCE = 111
$$ButtonSUB = 112
$$ButtonDIV = 113
$$ButtonPER = 114
$$ButtonC = 115
$$ButtonADD = 116
$$ButtonMUL = 117
$$ButtonEQ = 118

$$ButtonINV = 119
$$ButtonSQD = 120
$$ButtonSQR = 121
$$ButtonCHS = 122
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

'	XioCreateConsole (title$, 50)	' create console, if console is not wanted, comment out this line
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

	SHARED hNewBrush
	SHARED lastKey

	SELECT CASE msg

		CASE $$WM_CREATE :

			style   = $$WS_BORDER | $$ES_RIGHT
			exStyle = $$WS_EX_CLIENTEDGE
			#hEdit   = NewChild ("edit", "Ready", style, 12, 14, 352, 30, hWnd, $$Edit, exStyle)

			#hFontVerdana = NewFont (@"Verdana", 14, $$FW_NORMAL, $$FALSE, $$FALSE)
			SetNewFont (#hEdit, #hFontVerdana)

			style    = $$BS_PUSHBUTTON | $$WS_TABSTOP
			exStyle  = $$WS_EX_STATICEDGE
			#button0 = NewChild ("button", "0", style, 12, 192, 100, 40, hWnd, $$Button0, exStyle)
			#button1 = NewChild ("button", "1", style, 12, 148, 40, 40, hWnd, $$Button1, exStyle)
			#button2 = NewChild ("button", "2", style, 72, 148, 40, 40, hWnd, $$Button2, exStyle)
			#button3 = NewChild ("button", "3", style,132, 148, 40, 40, hWnd, $$Button3, exStyle)
			#button4 = NewChild ("button", "4", style, 12, 104, 40, 40, hWnd, $$Button4, exStyle)
			#button5 = NewChild ("button", "5", style, 72, 104, 40, 40, hWnd, $$Button5, exStyle)
			#button6 = NewChild ("button", "6", style,132, 104, 40, 40, hWnd, $$Button6, exStyle)
			#button7 = NewChild ("button", "7", style, 12,  58, 40, 40, hWnd, $$Button7, exStyle)
			#button8 = NewChild ("button", "8", style, 72,  58, 40, 40, hWnd, $$Button8, exStyle)
			#button9 = NewChild ("button", "9", style,132,  58, 40, 40, hWnd, $$Button9, exStyle)
			#button10 = NewChild ("button", ".",style,132, 192, 40, 40, hWnd, $$ButtonDOT, exStyle)

			#button11 = NewChild ("button", "CE",style, 264,  58, 40, 40, hWnd, $$ButtonCE, exStyle)
			#button12 = NewChild ("button", "-", style, 264, 104, 40, 40, hWnd, $$ButtonSUB, exStyle)
			#button13 = NewChild ("button", "/", style, 264, 148, 40, 40, hWnd, $$ButtonDIV, exStyle)
			#button14 = NewChild ("button", "%", style, 264, 192, 40, 40, hWnd, $$ButtonPER, exStyle)
			#button15 = NewChild ("button", "C", style, 206,  58, 40, 40, hWnd, $$ButtonC, exStyle)
			#button16 = NewChild ("button", "+", style, 206, 104, 40, 40, hWnd, $$ButtonADD, exStyle)
			#button17 = NewChild ("button", "X", style, 206, 148, 40, 40, hWnd, $$ButtonMUL, exStyle)
			#button18 = NewChild ("button", "=", style, 206, 192, 40, 40, hWnd, $$ButtonEQ, exStyle)

			#button19 = NewChild ("button", "1/X", style, 324,  58, 40, 40, hWnd, $$ButtonINV, exStyle)
			#button20 = NewChild ("button", "X^2", style, 324, 104, 40, 40, hWnd, $$ButtonSQD, exStyle)
			#button21 = NewChild ("button", "SQR", style, 324, 148, 40, 40, hWnd, $$ButtonSQR, exStyle)
			#button22 = NewChild ("button", "CHS", style, 324, 192, 40, 40, hWnd, $$ButtonCHS, exStyle)

		CASE $$WM_DESTROY :
			DeleteObject (#hFontVerdana)
			DeleteObject (hNewBrush)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			controlID = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE TRUE
						CASE (controlID > 99) && (controlID < 110) :
							ProcessNumber (controlID - 100)
						CASE controlID > 109 :
							ProcessOperator (controlID)
					END SELECT
					lastKey = controlID
			END SELECT

		CASE $$WM_CTLCOLORBTN :
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE $$WM_CTLCOLOREDIT :
			RETURN SetColor (RGB(0, 225, 0), RGB(0, 0, 0), wParam, lParam)

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

	SHARED className$

' register window class
	className$  = "Calculator"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	className$  = "Calculator"
	titleBar$  	= "Calculator."
	style 			= $$WS_OVERLAPPEDWINDOW | $$WS_TABSTOP
	w 					= 384
	h 					= 274
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

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
' #####  SetColor ()  #####
' #########################
'
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
' ##############################
' #####  ProcessNumber ()  #####
' ##############################
'
FUNCTION  ProcessNumber (digit)

	SHARED EqFlag, OpFlag

PRINT "ProcessNumber : digit="; digit

	a$ = GetText$ (#hEdit)
	IF a$ = "Ready" THEN a$ = ""

	IF EqFlag THEN
		a$ = ""
		EqFlag = $$FALSE
	END IF

	IF OpFlag THEN
		a$ = ""
		SetText (#hEdit, "")
		OpFlag = $$FALSE
	END IF

	a$ = a$ + STRING$ (digit)
	SetText (#hEdit, a$)

END FUNCTION
'
'
' ################################
' #####  ProcessOperator ()  #####
' ################################
'
FUNCTION  ProcessOperator (operator)

	SHARED EqFlag, OpFlag
	STATIC Code
	STATIC DOUBLE Op1, Op2
	SHARED lastKey

	a$ = GetText$ (#hEdit)
	IF a$ = "Ready" THEN a$ = ""

	SELECT CASE operator

		CASE $$ButtonDOT :							' ..... Decimal Point
			IF EqFlag THEN
				a$ = ""
				EqFlag = $$FALSE
			END IF
			IF OpFlag THEN
				a$ = ""
				SetText (#hEdit, "")
				OpFlag = $$FALSE
			END IF
			IFZ INSTR (a$, ".") THEN a$ = a$ + "."
			SetText (#hEdit, a$)

		CASE $$ButtonCE :								' ..... CE Clear Entry
			SetText (#hEdit, "Ready")
			EqFlag  = $$FALSE

		CASE $$ButtonSUB : 							' ..... Subtraction
			Op1    = DOUBLE (GetText$ (#hEdit))
			SetText (#hEdit, "-")
			Code   = 4
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonDIV : 							' ..... Division
			Op1    = DOUBLE (GetText$ (#hEdit))
			SetText (#hEdit, "/")
			Code   = 2
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonPER :							' ..... Percent
			Op2 = DOUBLE (GetText$ (#hEdit))/100.0
			SetText (#hEdit, STRING$ (Op2))
			EqFlag = $$FALSE

		CASE $$ButtonC : 								' ..... Clear All
			SetText (#hEdit, "Ready")
			Op1    = 0
			Op2    = 0
			Code   = 0
			EqFlag = $$FALSE

		CASE $$ButtonADD : 							' ..... Addition
			Op1    = DOUBLE (GetText$ (#hEdit))
			SetText (#hEdit, "+")
			Code   = 3
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonMUL : 							' ..... Multiply
			Op1    = DOUBLE (GetText$ (#hEdit))
			SetText (#hEdit, "*")
			Code   = 1
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonEQ :								' ..... Equals -- calc it!

			IF lastKey = $$ButtonEQ THEN EXIT SELECT

			Op2    = DOUBLE (GetText$ (#hEdit))
			OpFlag = $$FALSE
			EqFlag = $$TRUE

  		SELECT CASE Code

    		CASE 1 :
    			Op1 = Op1*Op2

				CASE 2 :
					IFZ Op2 THEN
						fDivByZero = $$TRUE
						Op1 = 0
						EXIT SELECT
					END IF
					Op1 = Op1/Op2

				CASE 3 :
					Op1 = Op1+Op2

				CASE 4 :
					Op1 = Op1-Op2
			END SELECT

			IF fDivByZero THEN
				a$ = "Error: Divison by zero"
				fDivByZero = $$FALSE
			ELSE
				a$ = STRING$ (Op1)
			END IF

			SetText (#hEdit, a$)
			Op1 = 0
			Op2 = 0

		CASE $$ButtonINV :							' ..... 1/X reciprocal
			SetText (#hEdit, STRING$ (1.0/DOUBLE(GetText$(#hEdit))))
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonSQD : 							' ..... X raised to the 2nd power
			SetText (#hEdit, STRING$ (DOUBLE (GetText$ (#hEdit)) * DOUBLE (GetText$(#hEdit))))
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonSQR : 							' ..... Square Root
			SetText (#hEdit, STRING$ (Sqrt (DOUBLE (GetText$ (#hEdit)))))
			OpFlag = $$TRUE
			EqFlag = $$FALSE

		CASE $$ButtonCHS :							' ..... CHS ( change sign )
			SetText (#hEdit, STRING$ (-1 * DOUBLE (GetText$ (#hEdit))))
			OpFlag = $$TRUE
			EqFlag = $$FALSE

	END SELECT

END FUNCTION
'
'
' ####################################
' #####  ScaleDialogToScreen ()  #####
' ####################################
'
' PURPOSE : Get scale factor between dialog units and screen units
'
FUNCTION  ScaleDialogToScreen (@scaleX, @scaleY)

	RECT rc

	rc.left   = 0
	rc.top    = 0
	rc.right  = 4
	rc.bottom = 8

	MapDialogRect (NULL, &rc)
	scaleX = rc.right/2
	scaleY = rc.bottom/4

END FUNCTION
'
'
' #########################
' #####  GetText$ ()  #####
' #########################
'
FUNCTION  GetText$ (hWnd)

	IFZ hWnd THEN RETURN ""
	a$ = NULL$ (1024)
	GetWindowTextA (hWnd, &a$, LEN(a$))
	RETURN (CSIZE$ (a$))

END FUNCTION
'
'
' ########################
' #####  SetText ()  #####
' ########################
'
FUNCTION  SetText (hWnd, text$)

	IFZ hWnd THEN RETURN ($$TRUE)
	IFZ text$ THEN RETURN ($$TRUE)
	IFZ SetWindowTextA (hWnd, &text$) THEN RETURN ($$TRUE)

END FUNCTION
END PROGRAM
