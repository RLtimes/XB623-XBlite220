'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Example of extending Find/Replace common dialog boxes.
' The edit control is replaced with a combobox control
' from with a resource template.
'
PROGRAM	"finddlgex"
VERSION	"0.0001"
'
'	IMPORT  "xio"
	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "comdlg32"	' comdlg32.dll
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  FindReplaceDialog (hWnd, wParam)
DECLARE FUNCTION  FindReplaceMsg (hWnd, hFind, lParam)
DECLARE FUNCTION  FRHookProc (hDlg, msg, wParam, lParam)

'Control IDs
$$IDM_EXIT = 207
$$IDM_FIND = 214	            ' Find
$$IDM_REPLACE = 215		        ' Replace
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
'	XioCreateConsole (@title$, 200)
	InitGui ()										' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create main windows and other child controls
	MessageLoop ()								' the message loop
	CleanUp ()										' unregister all window classes
'	XioFreeConsole ()

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	SHARED hInst
	SHARED dwFindMsg				' Registered message handle

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$IDM_EXIT :
					PostQuitMessage(0)

				CASE $$IDM_FIND, $$IDM_REPLACE : 
					hFind = FindReplaceDialog (hWnd, wParam)
			END SELECT
			
		' Message sent by the Find/FindReplace dialog
		CASE dwFindMsg : FindReplaceMsg (hWnd, @hFind, lParam)

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
	className$  = "DialogBox"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Find Dialog Extend."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 250
	h 					= 100
	exStyle			= 0
	#winMain = NewWindow (className$, @title$, style, x, y, w, h, exStyle)

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
' ############################
' #####  FindReplace ()  #####
' ############################
' 
' Open Find/Replace dialog box
' 
FUNCTION FindReplaceDialog (hWnd, wParam)

	SHARED hInst
	STATIC FINDREPLACE fr		' FINDREPLACE structure
	SHARED dwFindMsg
	STATIC find$, replace$
	
	IF hWnd THEN
		
		find$ = "FindThis"

		IFZ find$ THEN find$ = NULL$ (255)
		IFZ replace$ THEN replace$ = NULL$ (255)

		' Register a Windows message to communicate with the dialog
		' Sends messages identified by dwFindMsg.
		dwFindMsg = RegisterWindowMessageA (&"commdlg_FindReplace")
		fr.lStructSize = SIZE (fr)
		fr.hwndOwner = hWnd
		fr.hInstance = hInst
		fr.flags = $$FR_DOWN | $$FR_ENABLETEMPLATE | $$FR_ENABLEHOOK
		fr.lCustData = LOWORD (wParam)
		fr.lpfnHook = &FRHookProc()  'NULL

		IF LOWORD (wParam) = $$IDM_FIND THEN
			fr.lpstrFindWhat = &find$
			fr.lpstrReplaceWith = NULL
			fr.wFindWhatLen = 255
			fr.wReplaceWithLen = 0
			fr.lpTemplateName = &"custfind"
			hFind = FindTextA (&fr)				' Find Dialog
		ELSE
			fr.lpstrFindWhat = &find$
			fr.lpstrReplaceWith = &replace$
			fr.wFindWhatLen = 255
			fr.wReplaceWithLen = 255
			fr.lpTemplateName = &"custreplace"
			hFind = ReplaceTextA (&fr)		' Find and Replace Dialog
		END IF
		IFZ hFind THEN fr.lCustData = 0
	END IF
	RETURN (hFind)
END FUNCTION
' 
' ###############################
' #####  FindReplaceMsg ()  #####
' ###############################
' 
' Respond to FindReplace Dialog box
' user request/search.
' 
FUNCTION FindReplaceMsg (hWnd, hFind, lParam)

	SHARED hInst
	STATIC FINDREPLACE fr		' FINDREPLACE structure
	STATIC find$						' Text to search
	STATIC replace$					' Replace text
	SHARED dwFindMsg				' Registered message handle
	SHARED find$[]
	STATIC findCount

	RtlMoveMemory (&fr, lParam, SIZE (fr))
	
	IF (fr.flags AND $$FR_DIALOGTERM) = $$FR_DIALOGTERM THEN
		hFind = 0
		RETURN
	END IF
	
	find$ = CSTRING$(fr.lpstrFindWhat)
	replace$ =  CSTRING$(fr.lpstrReplaceWith)
	
	fUnique = $$TRUE
	IF find$ THEN
		upp = UBOUND(find$[])
		FOR i = 0 TO upp
			IF find$ = find$[i] THEN 
				fUnique = $$FALSE
				EXIT FOR
			END IF
		NEXT i
		
		IF fUnique THEN
			REDIM find$[findCount]
			find$[findCount] = find$
			INC findCount
		END IF
	END IF
	
	text$ = "FindWhat   : " + find$ + "\n"
	text$ = text$ + "ReplaceWith: " + replace$ + "\n"
	
		SELECT CASE TRUE

			CASE (fr.flags AND $$FR_FINDNEXT) = $$FR_FINDNEXT : text$ = text$ + "FindNext: \n"
				' Find next
				' Get the options checked in the dialog box
				IF (fr.flags AND $$FR_MATCHCASE) = $$FR_MATCHCASE THEN text$ = text$ + "MatchCase "
				IF (fr.flags AND $$FR_WHOLEWORD) = $$FR_WHOLEWORD THEN text$ = text$ + "WholeWord "
				IF (fr.flags AND $$FR_DOWN)      = $$FR_DOWN      THEN text$ = text$ + "Down "

			CASE (fr.flags AND $$FR_REPLACE) = $$FR_REPLACE : text$ = text$ + "Replace: \n"
				' Get the options checked in the dialog box
				IF (fr.flags AND $$FR_MATCHCASE) = $$FR_MATCHCASE THEN text$ = text$ + "MatchCase "
				IF (fr.flags AND $$FR_WHOLEWORD) = $$FR_WHOLEWORD THEN text$ = text$ + "WholeWord "

				' Send a message to search for the next occurrence
				fr.flags = fr.flags OR $$FR_FINDNEXT
				ret = SendMessageA (hWnd, dwFindMsg, 0, &fr)

			CASE (fr.flags AND $$FR_REPLACEALL) = $$FR_REPLACEALL : text$ = text$ + "ReplaceAll: \n"
				' Replace all
				IF (fr.flags AND $$FR_MATCHCASE) = $$FR_MATCHCASE THEN text$ = text$ + "MatchCase "
				IF (fr.flags AND $$FR_WHOLEWORD) = $$FR_WHOLEWORD THEN text$ = text$ + "WholeWord "
		END SELECT
		
		MessageBoxA (hWnd, &text$, &"FindReplace Dialog Response", $$MB_OK	) 

END FUNCTION

FUNCTION FRHookProc (hDlg, msg, wParam, lParam)

	SHARED find$[]
	SHARED replace$[]

	SELECT CASE msg
		
		CASE $$WM_INITDIALOG :
			#hComboboxFind = GetDlgItem (hDlg, 0x0480)
			#hComboboxReplace = GetDlgItem (hDlg, 0x0481)
			' fill up combobox with find$[] array
			IF #hComboboxFind THEN  
				upper = UBOUND(find$[]) 
				FOR i = 0 TO upper
					ret = SendMessageA (#hComboboxFind, $$CB_ADDSTRING, 0, &find$[i])
				NEXT i
			END IF
			ShowWindow (hDlg, $$SW_SHOW) 			
			UpdateWindow (hDlg)

		CASE ELSE : RETURN 
			
	END SELECT

END FUNCTION
END PROGRAM
