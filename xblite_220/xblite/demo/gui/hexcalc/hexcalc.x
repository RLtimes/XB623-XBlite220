'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This hex calculator program displays a
' Modal Dialog Box as the main window.
' It uses a Dialog Box Template to create
' the various controls in the Dialog Box.
' Based on hexcalc.c by Charles Petzold, 1996.
' ---
' To use the Dialog Template Resource in a program,
' you must use the DialogBoxParamA () function.
' A separate dialog box procedure is necessary to
' handle all of the callbacks associated with the
' dialog box (see DialogProc ()).

PROGRAM	"hexcalc"
VERSION	"0.0002"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xst_s.lib" 
'	IMPORT 	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "msvcrt"		' msvcrt.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  DialogProc (hWnd, uMsg, wParam, lParam)
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  ShowNumber (hWnd, dwNumber)
DECLARE FUNCTION  CalcIt (dwFirstNum, nOperation, dwNum)
DECLARE FUNCTION  PushButtonProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  ShowOp (hWnd, operation)

$$ULONG_MAX = 4294967395
'
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
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
'	XioFreeConsole ()							' free console

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	SHARED hInst

	hInst = GetModuleHandleA (0)	' get current instance handle
	IFZ hInst THEN QUIT(0)

	InitCommonControls ()					' initialize comctl32.dll library

' create main modeless dialog window.
	#hDialogBox = CreateDialogParamA (hInst, 100, 0, &DialogProc(), 0)
	IFZ #hDialogBox THEN RETURN ($$TRUE)

' display dialog box
	ShowWindow (#hDialogBox, $$SW_SHOWNORMAL)

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
' ###########################
' #####  DialogProc ()  #####
' ###########################
'
FUNCTION  DialogProc (hWnd, uMsg, wParam, lParam)

	STATIC bNewNumber
	STATIC dwNumber, dwFirstNum
	STATIC nOperation
	STATIC entry
	SHARED hNewBrush

	IFZ entry THEN
		bNewNumber = $$TRUE
		nOperation = '='
		entry = $$TRUE
	END IF

	SELECT CASE uMsg

		CASE $$WM_INITDIALOG :

			XstCenterWindow (hWnd)

' get handle of 'D' push button control, normally has focus
			hPB = GetDlgItem (hWnd, 68)

' subclass push button control with new function
			#old_proc = SetWindowLongA (hPB, $$GWL_WNDPROC, &PushButtonProc())

		CASE $$WM_CTLCOLORDLG :
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE $$WM_CTLCOLORBTN :
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE $$WM_CTLCOLORSTATIC :
			RETURN SetColor (RGB(0, 0, 0), RGB(192, 192, 192), wParam, lParam)

		CASE $$WM_CTLCOLOREDIT :
			RETURN SetColor (RGB(0, 225, 0), RGB(0, 0, 0), wParam, lParam)

		CASE $$WM_DESTROY :
			DeleteObject (hNewBrush)
			PostQuitMessage (0)

		CASE $$WM_CLOSE :
			PostQuitMessage (0)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$BN_CLICKED :

					SetFocus (hWnd)

					SELECT CASE TRUE

						CASE (ID == $$VK_BACK) : 					' backspace
							dwNumber = dwNumber / 16				' dwNumber /=16
							ShowNumber (hWnd, dwNumber)

						CASE (ID == 'x') : 								' CE
							dwNumber = 0
							ShowNumber (hWnd, dwNumber)

						CASE (isxdigit (ID)) : 						' hex digit
							IF (bNewNumber) THEN
								dwFirstNum = dwNumber
								dwNumber = 0
							END IF
							bNewNumber = $$FALSE

							IF (dwNumber <= ($$ULONG_MAX >> 4)) THEN
								IF isdigit (ID) THEN
									x = '0'
								ELSE
									x = 'A' - 10
								END IF
								dwNumber = 16 * dwNumber + ID - x
								ShowNumber (hWnd, dwNumber)
							ELSE
								MessageBeep ($$MB_ICONEXCLAMATION)
							END IF

						CASE (!bNewNumber) :							' do math operation
							dwNumber = CalcIt (dwFirstNum, nOperation, dwNumber)
							ShowNumber (hWnd, dwNumber)
							bNewNumber = $$TRUE
							nOperation = ID
							ShowOp (hWnd, nOperation)
					END SELECT
			END SELECT

		CASE ELSE : RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

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
' ###########################
' #####  ShowNumber ()  #####
' ###########################
'
FUNCTION  ShowNumber (hWnd, dwNumber)

' set decimal value in first edit box
	number$ = STRING$ (dwNumber)
	SetDlgItemTextA (hWnd, $$VK_ESCAPE, &number$)

' set hex value in second edit box
	hex$ = HEXX$ (dwNumber)
	SetDlgItemTextA (hWnd, 28, &hex$)

END FUNCTION
'
'
' #######################
' #####  CalcIt ()  #####
' #######################
'
FUNCTION  CalcIt (dwFirstNum, nOperation, dwNum)

	SELECT CASE (nOperation)
		CASE '=': RETURN dwNum
		CASE '+': RETURN dwFirstNum + dwNum
		CASE '-': RETURN dwFirstNum - dwNum
		CASE '*': RETURN dwFirstNum * dwNum
		CASE '&': RETURN dwFirstNum & dwNum
		CASE '|': RETURN dwFirstNum | dwNum
		CASE '^': RETURN dwFirstNum ^ dwNum
		CASE '<': RETURN dwFirstNum << dwNum
		CASE '>': RETURN dwFirstNum >> dwNum
		CASE '/': IF dwNum THEN
								RETURN dwFirstNum / dwNum
							ELSE
								RETURN 2147483647		' $$ULONG_MAX
							END IF
		CASE '%': IF dwNum THEN
								RETURN dwFirstNum MOD dwNum
							ELSE
								RETURN 2147483647		' $$ULONG_MAX
							END IF
		CASE ELSE : RETURN 0
	END SELECT


END FUNCTION
'
'
' ###############################
' #####  PushButtonProc ()  #####
' ###############################
'
FUNCTION  PushButtonProc (hWnd, msg, wParam, lParam)

	SELECT CASE msg

' tell default push button proc that you want to
' handle char and keyboard messages

		CASE $$WM_GETDLGCODE :
				RETURN $$DLGC_WANTCHARS | $$DLGC_WANTALLKEYS

' tranlsate left arrow key hit into a backspace hit
' then simulate push button hit and send
' VK_BACK WM_COMMAND msg to dialog box proc

		CASE $$WM_KEYDOWN :
			IF (wParam != $$VK_LEFT) THEN RETURN
			wParam = $$VK_BACK
			hButton = GetDlgItem (#hDialogBox, wParam)
			IF hButton THEN
				SendMessageA (hButton, $$BM_SETSTATE, 1, 0)
				Sleep (200)
				SendMessageA (hButton, $$BM_SETSTATE, 0, 0)
				SendMessageA (#hDialogBox, $$WM_COMMAND, wParam, 0)
			ELSE
				MessageBeep ($$MB_ICONEXCLAMATION)
			END IF

' convert all chars to upper case
' translate VK_RETURN key hit into a '=' sign hit
' then simulate push button hits and send
' WM_COMMAND msg to dialog box proc

		CASE $$WM_CHAR :
			wParam = toupper (wParam)
			IF (wParam == $$VK_RETURN) THEN
				wParam = '='
			END IF

			hButton = GetDlgItem (#hDialogBox, wParam)
			IF hButton THEN
				SendMessageA (hButton, $$BM_SETSTATE, 1, 0)
				Sleep (200)
				SendMessageA (hButton, $$BM_SETSTATE, 0, 0)
				SendMessageA (#hDialogBox, $$WM_COMMAND, wParam, 0)
			ELSE
				MessageBeep ($$MB_ICONEXCLAMATION)
			END IF

		CASE ELSE :
			RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

	END SELECT
END FUNCTION
'
'
' #######################
' #####  ShowOp ()  #####
' #######################
'
FUNCTION  ShowOp (hWnd, operation)

	IF operation = '=' THEN RETURN

' set operation in both edit boxes
	op$ = CHR$ (operation)

	IF op$ = "<" THEN
		op$ = "<<"
	ELSE
		IF op$ = "<" THEN op$ = "<<"
	END IF

	SetDlgItemTextA (hWnd, $$VK_ESCAPE, &op$)
	SetDlgItemTextA (hWnd, 28, &op$)


END FUNCTION
END PROGRAM
