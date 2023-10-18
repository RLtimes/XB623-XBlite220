' 
' 
' ####################
' #####  PROLOG  #####
' ####################
' 
' Test the wm2name library.
' {------------------------------------------------------------------------------------------}
' {- To use WM2Name on a project:                                                           -}
' {- (1) IMPORT "wm2name"                                                                   -}
' {- (2) Add "ShowWM2Name ()" in CreateWindows                                              -}
' {- (3) Add "Msg2Name (hwnd, msg, wParam, lParam)" to window procedure to examine messages -}
' {- (4) Add "DestroyWM2Name ()" to CleanUp                                                 -}
' {-                                                                                        -}
' {- Note: Make sure the parameters for "Msg2Name" are identical to the window procedure.   -}
' {- Also requires cmcs21.dll - CodeMax                                                     -}
' {------------------------------------------------------------------------------------------}
' 
PROGRAM "testwm"
VERSION "0.0001"
' 
IMPORT "xst"		' standard library	: required by most programs
' IMPORT  "xsx"				' extended std library
' IMPORT	"xio"				' console io library
IMPORT "gdi32"		' gdi32.dll
IMPORT "user32"		' user32.dll
IMPORT "kernel32"		' kernel32.dll
IMPORT "comctl32"		' comctl32.dll			: common controls library
' IMPORT	"comdlg32"  ' comdlg32.dll	    : common dialog library
' IMPORT	"xma"   		' math library			: Sin/Asin/Sinh/Asinh/Log/Exp/Sqrt...
' IMPORT	"xcm"				' complex math library
' IMPORT  "msvcrt"		' msvcrt.dll				: C function library
' IMPORT  "shell32"   ' shell32.dll
IMPORT "wm2name"
' 
' 
DECLARE FUNCTION Entry ()
DECLARE FUNCTION WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION InitGui ()
DECLARE FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION CreateWindows ()
DECLARE FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION MessageLoop ()
DECLARE FUNCTION CleanUp ()
' 
' 
' 
' ######################
' #####  Entry ()  #####
' ######################
' 
FUNCTION Entry ()

	STATIC entry
	' 
	IF entry THEN RETURN		' enter once
	entry = $$TRUE		' enter occured

	' XioCreateConsole (title$, 50)			' create console, if console is not wanted, comment out this line
	InitGui ()		' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)		' create windows and other child controls
	MessageLoop ()		' the main message loop
	CleanUp ()		' unregister all window classes
	' XioFreeConsole ()									' free console

END FUNCTION
' 
' 
' ########################
' #####  WndProc ()  #####
' ########################
' 
FUNCTION WndProc (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT rect

	$Menu_File_Exit = 100
	$Menu_Item1_1 = 150
	$Menu_Item1_2 = 151
	$Menu_Item1_3 = 152
	$Menu_Item1_4 = 153
	$Menu_Item1_5 = 154
	$Menu_Item1_6 = 155
	$Menu_Item1_7 = 156
	$Menu_Item1_8 = 157
	$Menu_Item1_9 = 158
	$Menu_Item1_10 = 159
	$Menu_Item1_11 = 165
	$Menu_Item1_12 = 166
	$Menu_Item1_13 = 167
	$Menu_Item1_14 = 168
	$Menu_Item1_15 = 169
	$Menu_Item2_1 = 200
	$Menu_Item2_2 = 201
	$Menu_Item2_3 = 202
	$Menu_Item2_4 = 203
	$Menu_Item2_5 = 204
	$Menu_Item2_6 = 205
	$Menu_Item2_7 = 206
	$Menu_Item2_8 = 207
	$Menu_Item2_9 = 208
	$Menu_Item2_10 = 209
	$Menu_Item2_11 = 210
	$Menu_Help_Help = 250
	$CmbBx_CmbBx1 = 300
	$CmbBx_CmbBx2 = 301
	$GrpBx_CmbBx1 = 330
	$GrpBx_CmbBx2 = 331
	$GrpBx_LstBx1 = 332
	$GrpBx_Edit1 = 333
	$GrpBx_Edit2 = 334
	$GrpBx_Btn = 335
	$LstBx_LstBx1 = 350
	$Edit_Edit1 = 370
	$Edit_Edit2 = 371
	$RdoBtn_RdoBtn1 = 400
	$RdoBtn_RdoBtn2 = 401
	$RdoBtn_RdoBtn3 = 402
	$AtoChkBx_AtoChkBx1 = 410
	$AtoChkBx_AtoChkBx2 = 411
	$AtoChkBx_AtoChkBx3 = 412
	$AtoRdoBtn_AtoRdoBtn1 = 420
	$AtoRdoBtn_AtoRdoBtn2 = 421
	$AtoRdoBtn_AtoRdoBtn3 = 422
	$PshBtn_PshBtn1 = 430
	$PshBtn_PshBtn2 = 431
	$ClassName = "TestThisDll"

	Msg2Name (hWnd, msg, wParam, lParam)

	SELECT CASE msg

		CASE $$WM_CREATE :

			hMenu = CreateMenu ()
			hMenu_File = CreateMenu ()
			InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_File, &"&File")
			AppendMenuA (hMenu_File, $$MF_STRING, $Menu_File_Exit, &"&Exit")
			hMenu_Item1 = CreateMenu ()
			InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_Item1, &"&Item1")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_1, &"Item1")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_2, &"Item2")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_3, &"Item3")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_4, &"Item4")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_5, &"Item5")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_6, &"Item6")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_7, &"Item7")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_8, &"Item8")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_9, &"Item9")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_10, &"Item10")
			AppendMenuA (hMenu_Item1, $$MF_SEPARATOR, 0, 0)
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_11, &"Item11")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_12, &"Item12")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_13, &"Item13")
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_14, &"Item14")
			AppendMenuA (hMenu_Item1, $$MF_SEPARATOR, 0, 0)
			AppendMenuA (hMenu_Item1, $$MF_STRING, $Menu_Item1_15, &"Item15")
			hMenu_Item2 = CreateMenu ()
			InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_Item2, &"&Item2")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_1, &"Item1")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_2, &"Item2")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_3, &"Item3")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_4, &"Item4")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_5, &"Item5")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_6, &"Item6")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_7, &"Item7")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_8, &"Item8")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_9, &"Item9")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_10, &"Item10")
			AppendMenuA (hMenu_Item2, $$MF_STRING, $Menu_Item2_11, &"Item11")
			hMenu_Help = CreateMenu ()
			InsertMenuA (hMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, hMenu_Help, &"&Help")
			AppendMenuA (hMenu_Help, $$MF_STRING, $Menu_Help_Help, &"&Help")
			SetMenu (hWnd, hMenu)

			NewChild ("button", "ComboBox1", $$BS_GROUPBOX, 5, 10, 150, 45, hWnd, $GrpBx_CmbBx1, 0)
			NewChild ("combobox", "", $$WS_BORDER | $$CBS_HASSTRINGS | $$CBS_DROPDOWNLIST | $$WS_VSCROLL, 10, 25, 140, 150, hWnd, $CmbBx_CmbBx1, 0)
			NewChild ("button", "ComboBox2", $$BS_GROUPBOX, 5, 55, 150, 45, hWnd, $GrpBx_CmbBx2, 0)
			NewChild ("combobox", "", $$CBS_DROPDOWN | $$WS_VSCROLL | $$WS_TABSTOP, 10, 70, 140, 150, hWnd, $CmbBx_CmbBx2, 0)
			NewChild ("button", "ListBox1", $$BS_GROUPBOX, 5, 110, 150, 105, hWnd, $GrpBx_LstBx1, 0)
			NewChild ("listbox", "", $$LBS_NOTIFY | $$WS_VSCROLL, 10, 125, 140, 85, hWnd, $LstBx_LstBx1, $$WS_EX_CLIENTEDGE)
			NewChild ("button", "Edit1", $$BS_GROUPBOX, 5, 225, 200, 150, hWnd, $GrpBx_Edit1, 0)
			NewChild ("edit", "", $$ES_MULTILINE | $$ES_WANTRETURN | $$WS_VSCROLL | $$WS_HSCROLL, 10, 240, 190, 130, hWnd, $Edit_Edit1, $$WS_EX_CLIENTEDGE)
			NewChild ("button", "Edit2 (Read only)", $$BS_GROUPBOX, 215, 225, 200, 150, hWnd, $GrpBx_Edit2, 0)
			NewChild ("edit", "", $$ES_MULTILINE | $$ES_WANTRETURN | $$WS_VSCROLL | $$WS_HSCROLL | $$ES_READONLY, 220, 240, 190, 130, hWnd, $Edit_Edit2, $$WS_EX_CLIENTEDGE)
			NewChild ("button", "Button", $$BS_GROUPBOX, 160, 10, 250, 205, hWnd, $GrpBx_Btn, 0)
			NewChild ("button", "Radiobutton1", $$BS_AUTORADIOBUTTON | $$WS_GROUP | $$WS_TABSTOP, 170, 25, 110, 20, hWnd, $RdoBtn_RdoBtn1, 0)
			NewChild ("button", "Radiobutton2", $$BS_AUTORADIOBUTTON, 170, 45, 110, 20, hWnd, $RdoBtn_RdoBtn2, 0)
			NewChild ("button", "Radiobutton3", $$BS_AUTORADIOBUTTON, 170, 65, 110, 20, hWnd, $RdoBtn_RdoBtn3, 0)
			NewChild ("button", "AutoCheckbox1", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 290, 25, 110, 20, hWnd, $AtoChkBx_AtoChkBx1, 0)
			NewChild ("button", "AutoCheckbox2", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 290, 45, 110, 20, hWnd, $AtoChkBx_AtoChkBx2, 0)
			NewChild ("button", "AutoCheckbox3", $$BS_AUTOCHECKBOX | $$WS_TABSTOP, 290, 65, 110, 20, hWnd, $AtoChkBx_AtoChkBx3, 0)
			NewChild ("button", "Togglebutton1", $$BS_AUTORADIOBUTTON | $$BS_PUSHLIKE | $$WS_GROUP | $$WS_TABSTOP, 170, 130, 100, 25, hWnd, $AtoRdoBtn_AtoRdoBtn1, 0)
			NewChild ("button", "Togglebutton2", $$BS_AUTORADIOBUTTON | $$BS_PUSHLIKE, 170, 157, 100, 25, hWnd, $AtoRdoBtn_AtoRdoBtn2, 0)
			NewChild ("button", "Togglebutton3", $$BS_AUTORADIOBUTTON | $$BS_PUSHLIKE, 170, 184, 100, 25, hWnd, $AtoRdoBtn_AtoRdoBtn3, 0)
			NewChild ("button", "Pushbutton1", $$BS_PUSHBUTTON | $$WS_TABSTOP, 300, 130, 85, 25, hWnd, $PshBtn_PshBtn1, 0)
			NewChild ("button", "Pushbutton2", $$BS_PUSHBUTTON | $$WS_TABSTOP, 300, 157, 85, 25, hWnd, $PshBtn_PshBtn2, 0)

			hCmbBx = GetDlgItem (hWnd, $CmbBx_CmbBx1)
			FOR setData = 0 TO 25
				data$ = "Item " + STRING$ (setData)
				SendMessageA (hCmbBx, $$CB_ADDSTRING, 0, &data$)
			NEXT setData

			hCmbBx = GetDlgItem (hWnd, $CmbBx_CmbBx2)
			FOR setData = 0 TO 25
				data$ = "Item " + STRING$ (setData)
				SendMessageA (hCmbBx, $$CB_ADDSTRING, 0, &data$)
			NEXT setData

			hLstBx = GetDlgItem (hWnd, $LstBx_LstBx1)
			FOR setData = 0 TO 25
				data$ = "Item " + STRING$ (setData)
				SendMessageA (hLstBx, $$LB_ADDSTRING, 0, &data$)
			NEXT setData

			hEdit = GetDlgItem (hWnd, $Edit_Edit2)
			text$ = "I gotta get home, he thought once again. . .and suddenly he was flying, the\r\n"
			text$ = text$ + "air whipping past him as he rose up over the skyline on leathery wings.\r\n"
			text$ = text$ + "And though he had never seen the city from this angle, through these\r\n"
			text$ = text$ + "blind eyes, he knew where he was going. He knew how to get there. Some\r\n"
			text$ = text$ + "inner system of guidance, indigenous to the form he had taken, zeroed\r\n"
			text$ = text$ + "in on the target unerringly. While his tiny lungs and sharp-fanged mouth\r\n"
			text$ = text$ + "pierced the night with a chittering song."

			SendMessageA (hEdit, $$WM_SETTEXT, 0, &text$)

		CASE $$WM_COMMAND :
			id = LOWORD (wParam)
			hwndCtl = lParam
			notifyCode = HIWORD (wParam)
			SELECT CASE id
				CASE $Menu_File_Exit : DestroyWindow (hWnd)
			END SELECT

		CASE $$WM_DESTROY :
			PostQuitMessage (0)

		CASE $$WM_CLOSE :
			DestroyWindow (hWnd)
			DestroyWM2Name ()		' close messaging window

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
FUNCTION InitGui ()

	SHARED hInst
	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT (0)
	InitCommonControls ()		' initialize comctl32.dll library

END FUNCTION
' 
' 
' #################################
' #####  RegisterWinClass ()  #####
' #################################
' 
FUNCTION RegisterWinClass (className$, addrWndProc, icon$, menu$)

	SHARED hInst
	WNDCLASS wc

	wc.style = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc = addrWndProc
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = hInst
	wc.hIcon = LoadIconA (hInst, &icon$)
	wc.hCursor = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground = $$COLOR_BTNFACE + 1
	wc.lpszMenuName = &menu$
	wc.lpszClassName = &className$

	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
' 
' 
' ##############################
' #####  CreateWindows ()  #####
' ##############################
' 
FUNCTION CreateWindows ()

	' register window class
	className$ = "TestWmClass"
	addrWndProc = &WndProc ()
	icon$ = "scrabble"
	menu$ = ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

	' create main window
	titleBar$ = "Testing WM2N DLL"
	style = $$WS_OVERLAPPEDWINDOW
	w = 430
	h = 430
	exStyle = 0
	#winMain = NewWindow (@className$, @titleBar$, style, x, y, w, h, exStyle)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)		' center window position
	ShowWindow (#winMain, $$SW_SHOWNORMAL)		' show window
	ShowWM2Name ()		' show messaging window

END FUNCTION
' 
' 
' ##########################
' #####  NewWindow ()  #####
' ##########################
' 
FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)

	SHARED hInst

	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION
' 
' 
' #########################
' #####  NewChild ()  #####
' #########################
' 
FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)

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
FUNCTION MessageLoop ()

	MSG msg

	' main message loop

	IF LIBRARY (0) THEN RETURN		' main program executes message loop

	DO		' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)		' retrieve next message from queue

		SELECT CASE ret
			CASE 0 : RETURN msg.wParam		' WM_QUIT message
			CASE - 1 : RETURN $$TRUE		' error
			CASE ELSE:
				hwnd = GetActiveWindow ()
				IF (!IsWindow (hwnd)) || (!IsDialogMessageA (hwnd, &msg)) THEN		' send only non-dialog messages
					TranslateMessage (&msg)		' translate virtual-key messages into character messages
					DispatchMessageA (&msg)		' send message to window callback function WndProc()
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
FUNCTION CleanUp ()

	SHARED hInst, className$

	UnregisterClassA (&className$, hInst)

END FUNCTION

END PROGRAM