'
'
' ####################
' #####  PROLOG  #####
' ####################

' A message box building program. Generates xblite
' code to display a custom message box.
'
PROGRAM	"mbb"
VERSION	"0.0001"
'
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xsx"
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
DECLARE FUNCTION  NewDialogBox (hWndParent, width, height, dlgProcAddr, initParam)
DECLARE FUNCTION  SetNewFont (hwndCtl, hFont)

DECLARE FUNCTION MsgBoxProc (hDlg, uMsg, wParam, lParam)
DECLARE FUNCTION MsgBoxButtonType (hDlg, ID)
DECLARE FUNCTION SetCheckBox (hButton)
DECLARE FUNCTION IsChecked (hButton)
DECLARE FUNCTION UnCheckBox (hButton)
DECLARE FUNCTION MsgBoxBuildString$ (hDlg, msg$, caption$, style)
DECLARE FUNCTION MsgBoxIcon (hDlg, ID)
DECLARE FUNCTION MsgBoxButtonDefault (hDlg, ID)
DECLARE FUNCTION MsgBoxBehavior (hDlg, ID)
DECLARE FUNCTION MsgBoxType (hDlg, ID)
DECLARE FUNCTION MsgBoxToClipBoard (hDlg)
DECLARE FUNCTION MsgBoxTry (hDlg)

' message box dialog control IDs
$$MBB_CAPTION = "Message Box Builder v1.00"
$$TABGROUP = 196608  ' $$WS_GROUP OR $$WS_TABSTOP
$$ID_ICON = 2000
 
$$MBB_START = 1001
'-- edit boxes
$$editCAPTION      = 1001
$$editMESSAGE      = 1002
  
'-- checkbox button
$$cbtnCONSTANTS    = 1003
$$cbtnClassLong    = 1004
  
'-- radio (option) buttons
$$rbtnOK           = 1005
$$rbtnOKCANCEL     = 1006
$$rbtnA_R_I        = 1007
$$rbtnYESNO        = 1008
$$rbtnYESNOCANCEL  = 1009
$$rbtnRETRYCANCEL  = 1010
  
$$rbtnINFORMATION  = 1011
$$rbtnEXCLAMATION  = 1012
$$rbtnQUESTION     = 1013
$$rbtnERROR        = 1014
$$rbtnNO_ICON      = 1015
$$rbtnUSER_ICON    = 1016
  
$$rbtnDefButton1   = 1017
$$rbtnDefButton2   = 1018
$$rbtnDefButton3   = 1019
  
$$rbtnDefStyle1    = 1020
$$rbtnDefStyle2    = 1021
$$rbtnDefStyle3    = 1022
  
$$ViewMsgBoxText   = 1023
'-- label
$$lblRESULT        = 1024
  
'-- push buttons
$$pbtnTEST         = 1025
$$pbtnSAVE         = 1026
$$pbtnEXIT         = 1027
  
'-- type
'$$rbtnMB           = 1028
$$rbtnMSB          = 1029
'$$rbtnMSBEX        = 1030
$$rbtnMSBI         = 1031
$$lblEx            = 1032

$$grpCAPTION			= 1033
$$grpICON					= 1034
$$grpMESSAGE			= 1035
$$grpBUTTONS      = 1036
$$grpDEFAULT			= 1037
$$grpBEHAVIOR			= 1038
$$grpRESULT				= 1039
$$grpTYPE					= 1040
$$grpCODE					= 1041

$$MBB_END = 1041

$$Menu_File_Exit = 110
$$Menu_File_Show_Dialog = 111

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

	SHARED selectedItem$, lastSelItem$

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

				CASE $$Menu_File_Show_Dialog :
					ID = NewDialogBox (hWnd, 400, 540, &MsgBoxProc(), initParam)	' create dialog box

					SELECT CASE ID :
						CASE $$pbtnEXIT :
							text$ = "Exit Pressed\n"
							text$ = text$ + "Control ID: " + STRING$(ID) +"\n"
							text$ = text$ + selectedItem$
							MessageBoxA (hWnd, &text$, &"Result", 0)

						CASE $$IDCANCEL :
							text$ = "Cancel Pressed\n"
							text$ = text$ + "Control ID: " + STRING$(ID) + "\n"
							text$ = text$ + lastSelItem$
							MessageBoxA (hWnd, &text$, &"Result", 0)

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
	className$  = "CustDialogBox"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Custom Dialog Box."
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
	AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Show_Dialog, &"&Show Dialog")

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
FUNCTION  NewDialogBox (hWndParent, width, height, dlgProcAddr, initParam)

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

	x = (screenWidth - width)/2				' center dialogbox on screen
	y = (screenHeight - height)/2

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
' #####  MsgBoxProc ()  #####
' ###########################
'
FUNCTION  MsgBoxProc (hDlg, msg, wParam, lParam)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

	SELECT CASE msg

		CASE $$WM_INITDIALOG :
			' set dialog caption
			SetWindowTextA (hDlg, &$$MBB_CAPTION)				

			' add child controls to dialog box
			' order of creation determines tab order
			NewChild ("button", "Caption", $$BS_GROUPBOX | $$WS_GROUP, 8, 6, 234, 42, hDlg, $$grpCAPTION, 0)
			NewChild ("edit", "text", $$ES_LEFT | $$ES_AUTOHSCROLL | $$WS_TABSTOP | $$WS_BORDER, 16, 24, 218, 18, hDlg, $$editCAPTION, 0)
			NewChild ("button", "Message {Use | for tab}", $$BS_GROUPBOX, 8, 56, 234, 86, hDlg, $$grpMESSAGE, 0)
			NewChild ("edit", "Message", $$ES_LEFT | $$ES_AUTOVSCROLL | $$WS_TABSTOP | $$ES_MULTILINE | $$ES_WANTRETURN | $$WS_VSCROLL | $$WS_BORDER, 16, 74, 218, 58, hDlg, $$editMESSAGE, 0)

			NewChild ("button", "Buttons", $$BS_GROUPBOX, 8, 148, 234, 82, hDlg, $$grpBUTTONS, 0)
			NewChild ("button", "&Ok ", $$BS_AUTORADIOBUTTON | $$WS_TABSTOP, 18, 166, 84, 18, hDlg, $$rbtnOK, 0)
			NewChild ("button", "Ok-&Cancel ", $$BS_AUTORADIOBUTTON , 18, 186, 84, 18, hDlg, $$rbtnOKCANCEL, 0)
			NewChild ("button", "Abort-Retry-I&gnore ", $$BS_AUTORADIOBUTTON , 18, 206, 120, 18, hDlg, $$rbtnA_R_I, 0)
			NewChild ("button", "Ye&s-No ", $$BS_AUTORADIOBUTTON, 142, 166, 84, 18, hDlg, $$rbtnYESNO, 0)
			NewChild ("button", "Yes-No-Cance&l ", $$BS_AUTORADIOBUTTON, 142, 186, 94, 18, hDlg, $$rbtnYESNOCANCEL, 0)
			NewChild ("button", "Retr&y-Cancel ", $$BS_AUTORADIOBUTTON, 142, 206, 94, 18, hDlg, $$rbtnRETRYCANCEL, 0)

			NewChild ("button", "Icon", $$BS_GROUPBOX, 254, 6, 138, 136, hDlg, $$grpICON, 0)
			NewChild ("static", "", $$SS_ICON, 258, 24, 32, 32, hDlg, 101, 0)
			hIcon1 = LoadIconA (NULL, $$IDI_ASTERISK)
			SendMessageA (GetDlgItem (hDlg, 101), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon1)
	
			NewChild ("static", "", $$SS_ICON, 290, 24, 32, 32, hDlg, 102, 0)
			hIcon2 = LoadIconA (NULL, $$IDI_EXCLAMATION)
			SendMessageA (GetDlgItem (hDlg, 102), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon2)
	
			NewChild ("static", "", $$SS_ICON, 322, 24, 32, 32, hDlg, 103, 0)
			hIcon3 = LoadIconA (NULL, $$IDI_QUESTION)
			SendMessageA (GetDlgItem (hDlg, 103), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon3)
	
			NewChild ("static", "", $$SS_ICON, 356, 24, 32, 32, hDlg, 104, 0)
			hIcon4 = LoadIconA (NULL, $$IDI_HAND)
			SendMessageA (GetDlgItem (hDlg, 104), $$STM_SETIMAGE, $$IMAGE_ICON, hIcon4)

			NewChild ("button", "&No icon ", $$BS_AUTORADIOBUTTON | $$TABGROUP, 262, 82, 80, 18, hDlg, $$rbtnNO_ICON, 0)  
			NewChild ("button", "&i ", $$BS_AUTORADIOBUTTON, 262, 62, 30, 18, hDlg, $$rbtnINFORMATION, 0)
			NewChild ("button", "&! ", $$BS_AUTORADIOBUTTON, 296, 62, 30, 18, hDlg, $$rbtnEXCLAMATION, 0)
			NewChild ("button", "&? ", $$BS_AUTORADIOBUTTON, 328, 62, 30, 18, hDlg, $$rbtnQUESTION, 0)
			NewChild ("button", "&x ", $$BS_AUTORADIOBUTTON, 362, 62, 28, 18, hDlg, $$rbtnERROR, 0)
			NewChild ("button", "&Resource icon ", $$BS_AUTORADIOBUTTON, 262, 102, 120, 18, hDlg, $$rbtnUSER_ICON, 0)
			EnableWindow (GetDlgItem (hDlg, $$rbtnUSER_ICON), 0) 

			NewChild ("button", "Cli&pboard", $$BS_PUSHBUTTON | $$TABGROUP, 254, 156, 138, 22, hDlg, $$pbtnSAVE, 0)
			NewChild ("button", "&Try", $$BS_PUSHBUTTON | $$TABGROUP, 254, 182, 138, 22, hDlg, $$pbtnTEST, 0)
			NewChild ("button", "Exit", $$BS_PUSHBUTTON | $$TABGROUP, 254, 208, 138, 22, hDlg, $$pbtnEXIT, 0)
	
			NewChild ("button", "Default", $$BS_GROUPBOX, 8, 242, 136, 86, hDlg, $$grpDEFAULT, 0)
			NewChild ("button", "&Button one ", $$BS_AUTORADIOBUTTON | $$TABGROUP, 18, 260, 120, 18, hDlg, $$rbtnDefButton1, 0)
			NewChild ("button", "Button t&wo ", $$BS_AUTORADIOBUTTON, 18, 280, 120, 18, hDlg, $$rbtnDefButton2, 0)
			NewChild ("button", "Button t&hree ", $$BS_AUTORADIOBUTTON, 18, 300, 120, 18, hDlg, $$rbtnDefButton3, 0)
	
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 0) 
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 0) 
  
			NewChild ("button", "Behavior", $$BS_GROUPBOX, 156, 242, 136, 86, hDlg, $$grpBEHAVIOR, 0)
			NewChild ("button", "&ApplModal ", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 174, 260, 110, 18, hDlg, $$rbtnDefStyle1, 0)
			NewChild ("button", "SystemMo&dal ", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 174, 280, 110, 18, hDlg, $$rbtnDefStyle2, 0)
			NewChild ("button", "Top&Most ", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 174, 300, 110, 18, hDlg, $$rbtnDefStyle3, 0)

			NewChild ("button", "Result", $$BS_GROUPBOX, 304, 242, 88, 86, hDlg, $$grpRESULT, 0)
			NewChild ("static", "", $$SS_CENTER, 314, 280, 68, 18, hDlg, $$lblRESULT, 0)
  
			NewChild ("button", "Type", $$BS_GROUPBOX, 8, 338, 384, 44, hDlg, $$grpTYPE, 0)
			NewChild ("button", "MessageBo&x ", $$BS_AUTORADIOBUTTON | $$TABGROUP, 18, 356, 100, 18, hDlg, $$rbtnMSB, 0)
			NewChild ("button", "MessageBo&xIndirect ", $$BS_AUTORADIOBUTTON, 120, 356, 130, 18, hDlg, $$rbtnMSBI, 0)
  
			NewChild ("button", "Code", $$BS_GROUPBOX, 8, 388, 384, 144, hDlg, $$grpCODE, 0)
			NewChild ("edit", "Output code", $$ES_MULTILINE | $$ES_WANTRETURN | $$ES_AUTOVSCROLL | $$WS_BORDER | $$WS_VSCROLL | $$WS_TABSTOP, 16, 406, 368, 116, hDlg, $$ViewMsgBoxText, 0)

			' set gui font in all controls
			hFont = GetStockObject ($$DEFAULT_GUI_FONT)
			FOR i = $$MBB_START TO $$MBB_END
				SetNewFont (GetDlgItem (hDlg, i), hFont)
			NEXT i
	
			' set default selections
			SetCheckBox (GetDlgItem(hDlg, $$rbtnOK))	
			WHICH_BUTTONS = $$rbtnOK
			SetCheckBox (GetDlgItem(hDlg, $$rbtnNO_ICON))
			WHICH_ICON = $$rbtnNO_ICON
			SetCheckBox (GetDlgItem(hDlg, $$cbtnCONSTANTS))
			SetCheckBox (GetDlgItem(hDlg, $$rbtnDefButton1))
			SetCheckBox (GetDlgItem(hDlg, $$rbtnMSB))
			WHICH_TYPE = $$rbtnMSB
  
			hInstance = GetModuleHandleA (0)
			hIconApp  = LoadIconA (hInstance, $$ID_ICON)
			SendMessageA (hDlg, $$WM_SETICON, $$ICON_SMALL, hIconApp)
			SendMessageA (hDlg, $$WM_SETICON, $$ICON_BIG, hIconApp)
  
			MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	
			SetFocus (GetDlgItem (hDlg, $$editCAPTION)) 

			RETURN ($$FALSE)

		CASE $$WM_COMMAND :
			notifyCode = HIWORD(wParam)
			ID         = LOWORD(wParam)
			hCtl    	 = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SetCheckBox (hCtl)
					SELECT CASE ID :

						CASE $$IDCANCEL, $$pbtnEXIT :			' window close/exit button pressed
							EndDialog (hDlg, ID)
							
						CASE $$rbtnOK, $$rbtnOKCANCEL, $$rbtnA_R_I, $$rbtnYESNO, $$rbtnYESNOCANCEL, $$rbtnRETRYCANCEL:
							MsgBoxButtonType (hDlg, ID)
							
						CASE $$rbtnINFORMATION, $$rbtnEXCLAMATION, $$rbtnQUESTION, $$rbtnERROR, $$rbtnNO_ICON, $$rbtnUSER_ICON :
							MsgBoxIcon (hDlg, ID)
							
						CASE $$rbtnDefButton1, $$rbtnDefButton2, $$rbtnDefButton3 : 
							MsgBoxButtonDefault (hDlg, ID)
							
						CASE $$rbtnDefStyle1, $$rbtnDefStyle2, $$rbtnDefStyle3 :
							MsgBoxBehavior (hDlg, ID)
							
						CASE $$rbtnMSB, $$rbtnMSBI :
							MsgBoxType (hDlg, ID)
							
						CASE $$pbtnSAVE :
							MsgBoxToClipBoard (hDlg)
							
						CASE $$pbtnTEST :
							MsgBoxTry (hDlg)

					END SELECT
			END SELECT

		CASE ELSE :	RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

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

FUNCTION MsgBoxButtonType (hDlg, ID)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

	WHICH_BUTTONS = ID

  SELECT CASE ID
    CASE $$rbtnOK :
			SetCheckBox (GetDlgItem(hDlg, $$rbtnDefButton1))
			UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton2))
			UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton3))
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 0)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 0)
			
    CASE $$rbtnOKCANCEL, $$rbtnYESNO, $$rbtnRETRYCANCEL 
			IF IsChecked (GetDlgItem (hDlg, $$rbtnDefButton3)) THEN
				SetCheckBox (GetDlgItem(hDlg, $$rbtnDefButton2))
				UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton1))
				UnCheckBox (GetDlgItem(hDlg, $$rbtnDefButton3))
			END IF
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 1)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 0)
			
    CASE $$rbtnA_R_I, $$rbtnYESNOCANCEL 
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton2), 1)
			EnableWindow (GetDlgItem (hDlg, $$rbtnDefButton3), 1)
  END SELECT
  
	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
	SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION

FUNCTION SetCheckBox (hButton)
  SendMessageA (hButton, $$BM_SETCHECK, 1, 0)
END FUNCTION

FUNCTION UnCheckBox (hButton)
  SendMessageA (hButton, $$BM_SETCHECK, 0, 0)
END FUNCTION

FUNCTION IsChecked (hButton)
  RETURN SendMessageA (hButton, $$BM_GETCHECK, 0, 0)
END FUNCTION

FUNCTION MsgBoxBuildString$ (hDlg, msg$, caption$, style)
' builds code & saves to the clipboard

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

	$CRLF = "\\r\\n"
	$TAB = "\\t"
	$DQ = "\""

	style$ = ""
	style = 0
  
	caption$ = NULL$(256)
	GetWindowTextA (GetDlgItem (hDlg, $$editCAPTION), &caption$, LEN(caption$))
	caption$ = CSIZE$(caption$)
	  
	msg$ = NULL$(4096)
	GetWindowTextA (GetDlgItem (hDlg, $$editMESSAGE), &msg$, LEN(msg$))
	msg$ = TRIM$(CSIZE$(msg$))

	' Handle multiline message CRLF and Tabs
	DO
	LOOP UNTIL XstReplace (@msg$, "\r\n", $CRLF, 0) <= 0  

	DO 
	LOOP UNTIL XstReplace (@msg$, "|", $TAB, 0) <= 0 

	GOSUB GetConstants

	SELECT CASE WHICH_TYPE
		CASE $$rbtnMSB :
      to_clipboard$ = "ret = MessageBoxA (hWnd, " + "&" + $DQ + msg$ + $DQ + ", " + "&" + $DQ + caption$ + $DQ + ", "
      IF style$ THEN
				to_clipboard$ = to_clipboard$ + style$ + ")"
			ELSE
				to_clipboard$ = to_clipboard$ + "0" + ")"
			END IF

    CASE $$rbtnMSBI   		' MessageBoxIndirect
      IF WHICH_ICON = $$rbtnUSER_ICON THEN 
        buffer$ = "  mbp.dwStyle            = " + style$ + "\r\n" + _
			            "  mbp.lpszIcon           = $ID_ICON"
				id$ = "  $ID_ICON = 100" 
      ELSE
        buffer$ = "  mbp.dwStyle            = " + style$ + "\r\n" + _
                  "  mbp.lpszIcon           = 0"
				id$ = ""
      END IF
  
      to_clipboard$ = _
                  "  MSGBOXPARAMS mbp"                    + "\r\n" + _
		              id$                                     + "\r\n" + _
                  "  caption$ = " + $DQ + caption$  + $DQ + "\r\n" + _
                  "  message$ = " + $DQ + msg$      + $DQ + "\r\n" + _
                  "  mbp.cbSize             = SIZE (mbp)" + "\r\n" + _
									"  mbp.hwndOwner          = hWnd"       + "\r\n" + _
                  "  mbp.hInstance          = GetModuleHandle (0)" + "\r\n" + _
                  "  mbp.lpszCaption        = &caption$"  + "\r\n" + _
                  "  mbp.lpszText           = &message$"  + "\r\n" + _
                  buffer$ + "\r\n" + _
                  "  mbp.dwContextHelpId    = 0"          + "\r\n" + _
                  "  mbp.lpfnMsgBoxCallback = 0"          + "\r\n" + _
                  "  mbp.dwLanguageId       = 0"          + "\r\n" + _
									"  ret = MessageBoxIndirect (&mbp)"

	END SELECT
  
	SetWindowTextA (GetDlgItem (hDlg, $$ViewMsgBoxText), &to_clipboard$)
  
	RETURN to_clipboard$
  
SUB GetConstants
  
	SELECT CASE WHICH_ICON
		CASE $$rbtnINFORMATION :
			style$ = "$$MB_ICONINFORMATION"
			style = $$MB_ICONINFORMATION
    CASE $$rbtnEXCLAMATION :
      style$ = "$$MB_ICONEXCLAMATION"
			style = $$MB_ICONEXCLAMATION 
    CASE $$rbtnQUESTION :
      style$ = "$$MB_ICONQUESTION"
			style = $$MB_ICONQUESTION 
    CASE $$rbtnERROR :
      style$ = "$$MB_ICONERROR"
			style = $$MB_ICONERROR
    CASE $$rbtnNO_ICON :
      style$ = ""
			style = 0
    CASE $$rbtnUSER_ICON :
      style$ = "$$MB_USERICON"
			style = $$MB_USERICON 
	END SELECT
  
	IF style$ THEN AddOr$ = " | " ELSE AddOr$ = ""
  
	SELECT CASE WHICH_BUTTONS
		CASE $$rbtnOK :
			style$ = style$ + AddOr$ + "$$MB_OK"
			style = style | $$MB_OK
		CASE $$rbtnOKCANCEL :
			style$ = style$ + AddOr$ + "$$MB_OKCANCEL"
			style = style | $$MB_OKCANCEL 
		CASE $$rbtnA_R_I :
			style$ = style$ + AddOr$ + "$$MB_ABORTRETRYIGNORE"
			style = style | $$MB_ABORTRETRYIGNORE
		CASE $$rbtnYESNO : 
			style$ = style$ + AddOr$ + "$$MB_YESNO"
			style = style | $$MB_YESNO
		CASE $$rbtnYESNOCANCEL :
			style$ = style$ + AddOr$ + "$$MB_YESNOCANCEL"
			style = style | $$MB_YESNOCANCEL
		CASE $$rbtnRETRYCANCEL :
			style$ = style$ + AddOr$ + "$$MB_RETRYCANCEL"
			style = style | $$MB_RETRYCANCEL
	END SELECT
  
  IF style$ THEN AddOr$ = " | " ELSE AddOr$ = ""

	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefButton2)) THEN
		style$ = style$ + AddOr$ + "$$MB_DEFBUTTON2"
		style = style | $$MB_DEFBUTTON2
	END IF
		 
	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefButton3)) THEN
		style$ = style$ + AddOr$ + "$$MB_DEFBUTTON3"
		style = style | $$MB_DEFBUTTON3
	END IF
	
	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefStyle1)) THEN 
		style$ = style$ + AddOr$ + "$$MB_APPLMODAL"
		style = style | $$MB_APPLMODAL
	END IF 
	
	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefStyle2)) THEN
		style$ = style$ + AddOr$ + "$$MB_SYSTEMMODAL"
		style = style | $$MB_SYSTEMMODAL
	END IF
	
	IF IsChecked (GetDlgItem (hDlg, $$rbtnDefStyle3)) THEN
		style$ = style$ + AddOr$ + "$$MB_TOPMOST"
		style = style | $$MB_TOPMOST
	END IF  
END SUB
  
END FUNCTION

FUNCTION MsgBoxIcon (hDlg, ID)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE

  WHICH_ICON = ID

	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION

FUNCTION MsgBoxButtonDefault (hDlg, ID)

	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION

FUNCTION MsgBoxBehavior (hDlg, ID)

	IF ID = $$rbtnDefStyle1 THEN UnCheckBox (GetDlgItem (hDlg, $$rbtnDefStyle2))
	IF ID = $$rbtnDefStyle2 THEN UnCheckBox (GetDlgItem (hDlg, $$rbtnDefStyle1))
	MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	text$ = ""
  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &text$)

END FUNCTION


FUNCTION MsgBoxType (hDlg, ID)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE
	
	WHICH_TYPE = ID

  IF WHICH_TYPE = $$rbtnMSBI THEN
		EnableWindow (GetDlgItem (hDlg, $$rbtnUSER_ICON), 1)
  ELSE
	  EnableWindow (GetDlgItem (hDlg, $$rbtnUSER_ICON), 0)
    IF WHICH_ICON = $$rbtnUSER_ICON THEN
      WHICH_ICON = $$rbtnNO_ICON
      UnCheckBox (GetDlgItem (hDlg, $$rbtnUSER_ICON))
      SetCheckBox (GetDlgItem (hDlg, $$rbtnNO_ICON))
    END IF
  END IF
  
 	MsgBoxBuildString$ (hDlg, msg$, caption$, style)

END FUNCTION

FUNCTION MsgBoxToClipBoard (hDlg)

	UBYTE image[]

	m$ = MsgBoxBuildString$ (hDlg, msg$, caption$, style)
	XstSetClipboard (1, @m$, @image[]) 

END FUNCTION

FUNCTION MsgBoxTry (hDlg)

	SHARED WHICH_BUTTONS, WHICH_ICON, WHICH_TYPE
	$CRLF = "\\r\\n"
	$TAB = "\\t"

 ' Displays msgbox as currently designed

	MSGBOXPARAMS mbp
	$ID_ICON = 100
	  
	MsgBoxBuildString$ (hDlg, @msg$, @caption$, @style)
 
	DO
	LOOP UNTIL XstReplace (@msg$, $CRLF, "\r\n", 0) <= 0  

	DO 
	LOOP UNTIL XstReplace (@msg$, $TAB, "\t", 0) <= 0 


	SELECT CASE WHICH_TYPE
 
		CASE $$rbtnMSB :
			ret = MessageBoxA (hDlg, &msg$, &caption$, style)

		CASE $$rbtnMSBI :  
			mbp.cbSize      				= SIZE(mbp)
			mbp.hwndOwner   				= hDlg
			mbp.hInstance   				= GetModuleHandleA (0)
			mbp.lpszCaption 				= &caption$
			mbp.lpszText    				= &msg$
			IF WHICH_ICON = $$rbtnUSER_ICON THEN 			' $$MB_USERICON
				mbp.lpszIcon 						= $ID_ICON
			ELSE
				mbp.lpszIcon 						= 0
			END IF
			mbp.dwStyle 						= style
			mbp.dwContextHelpId    	= 0 
			mbp.lpfnMsgBoxCallback 	= 0 
			mbp.dwLanguageId       	= 0
			ret = MessageBoxIndirectA (&mbp)
  
  END SELECT
  
  SELECT CASE ret
    CASE $$IDOK     :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDOK") 
    CASE $$IDCANCEL :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDCANCEL") 
    CASE $$IDABORT  :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDABORT") 
    CASE $$IDRETRY  :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDRETRY") 
    CASE $$IDIGNORE :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDIGNORE") 
    CASE $$IDYES    :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDYES") 
    CASE $$IDNO     :  SetWindowTextA (GetDlgItem (hDlg, $$lblRESULT), &"$$IDNO") 
  END SELECT
	
END FUNCTION
END PROGRAM
