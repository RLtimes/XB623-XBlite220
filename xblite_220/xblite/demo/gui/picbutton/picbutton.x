'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demonstration of a custom control. In
' this case, a push button control which
' displays bmp images (nothing new here but good
' to show as an example). The demo also shows
' all of the built-in OEM bitmaps (type 'OBM_').
'
PROGRAM	"picbutton"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
'
TYPE OBM
	XLONG	.number
	STRING*128 .name
END TYPE

TYPE PICTUREBUTTON
	XLONG	.disabled			' 0
	XLONG	.focus				' 4
	XLONG	.depressed		' 8
	XLONG	.captured			' 12
	XLONG	.tabstop			' 16
	XLONG	.unused				' 20
	XLONG	.height				' 24
	XLONG	.width				' 28
	XLONG	.picture			' 32
	XLONG	.disabled_picture			' 36
	XLONG	.status_bar		' 40
	XLONG	.mouse_enter	' 44
	STRING*256	.status_message
END TYPE
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  Register_Picture_Button ()
DECLARE FUNCTION  PictureButtonProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  PostClickedMessage (hWnd)
DECLARE FUNCTION  MoveTo (hdc, x, y)

'Control IDs
$$Button1  = 101
$$Button2  = 102
$$Button3  = 103
$$Button4  = 104
$$Button5  = 105

$$OEMRESOURCE = 1

$$MAX_NAME_LENGTH = 31
$$FOCUS_BORDER_WIDTH = 2
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	STATIC	entry

	IF entry THEN RETURN							' enter once
	entry =  $$TRUE										' enter occured

'	XioCreateConsole (title$, 150)			' create console, if console is not wanted, comment out this line
	IF InitGui () THEN QUIT (0)				' initialize program and libraries
	IF CreateWindows () THEN QUIT (0)	' create windows and other child controls
	MessageLoop ()										' the main message loop
	CleanUp ()												' unregister all window classes
'	XioFreeConsole ()									' free console

END FUNCTION
'
'
' ########################
' #####  WndProc ()  #####
' ########################
'
FUNCTION  WndProc (hWnd, msg, wParam, lParam)

	SHARED OBM obm[]
	SHARED hInst
	STATIC i, enabled
  BITMAP bm
	STATIC hBitmap

	SELECT CASE msg

		CASE $$WM_INITDIALOG :

			DIM obm[25]
			obm[0].number  = $$OBM_BTNCORNERS 	: obm[0].name  = "OBM_BTNCORNERS"
			obm[1].number  = $$OBM_BTSIZE 			: obm[1].name  = "OBM_BTSIZE"
			obm[2].number  = $$OBM_CHECK 				: obm[2].name  = "OBM_CHECK"
			obm[3].number  = $$OBM_CHECKBOXES 	: obm[3].name  = "OBM_CHECKBOXES"
			obm[4].number  = $$OBM_CLOSE 				: obm[4].name  = "OBM_CLOSE"
			obm[5].number  = $$OBM_COMBO 				: obm[5].name  = "OBM_COMBO"
			obm[6].number  = $$OBM_DNARROW 			: obm[6].name  = "OBM_DNARROW"
			obm[7].number  = $$OBM_DNARROWD 		: obm[7].name  = "OBM_DNARROWD"
			obm[8].number  = $$OBM_DNARROWI 		: obm[8].name  = "OBM_DNARROWI"
			obm[9].number  = $$OBM_LFARROW 			: obm[9].name  = "OBM_LFARROW"
			obm[10].number = $$OBM_LFARROWD 		: obm[10].name = "OBM_LFARROWD"
			obm[11].number = $$OBM_LFARROWI 		: obm[11].name = "OBM_LFARROWI"
			obm[12].number = $$OBM_MNARROW 			: obm[12].name = "OBM_MNARROW"
			obm[13].number = $$OBM_REDUCE 			: obm[13].name = "OBM_REDUCE"
			obm[14].number = $$OBM_REDUCED 			: obm[14].name = "OBM_REDUCED"
			obm[15].number = $$OBM_RESTORE 			: obm[15].name = "OBM_RESTORE"
			obm[16].number = $$OBM_RESTORED 		: obm[16].name = "OBM_RESTORED"
			obm[17].number = $$OBM_RGARROW 			: obm[17].name = "OBM_RGARROW"
			obm[18].number = $$OBM_RGARROWD 		: obm[18].name = "OBM_RGARROWD"
			obm[19].number = $$OBM_RGARROWI 		: obm[19].name = "OBM_RGARROWI"
			obm[20].number = $$OBM_SIZE 				: obm[20].name = "OBM_SIZE"
			obm[21].number = $$OBM_UPARROW 			: obm[21].name = "OBM_UPARROW"
			obm[22].number = $$OBM_UPARROWD 		: obm[22].name = "OBM_UPARROWD"
			obm[23].number = $$OBM_UPARROWI 		: obm[23].name = "OBM_UPARROWI"
			obm[24].number = $$OBM_ZOOM 				: obm[24].name = "OBM_ZOOM"
			obm[25].number = $$OBM_ZOOMD 				: obm[25].name = "OBM_ZOOMD"
			
			enabled = $$TRUE

' set status text for each button
  		SendDlgItemMessageA (hWnd, 101, $$BM_SETSTATE, GetDlgItem (hWnd, 107), &"Terminate test")
  		SendDlgItemMessageA (hWnd, 102, $$BM_SETSTATE, GetDlgItem (hWnd, 107), &"Show OBM bitmaps in button 1")
  		SendDlgItemMessageA (hWnd, 103, $$BM_SETSTATE, GetDlgItem (hWnd, 107), &"Has no tabstop")
  		SendDlgItemMessageA (hWnd, 104, $$BM_SETSTATE, GetDlgItem (hWnd, 107), &"Enabled or disabled by button 5")
  		SendDlgItemMessageA (hWnd, 105, $$BM_SETSTATE, GetDlgItem (hWnd, 107), &"Enable or disable button 4")

		CASE $$WM_CLOSE :
			IF hBitmap THEN DeleteObject (hBitmap)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :										' monitor notification messages from buttons
			ID         = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl    = lParam
			SELECT CASE notifyCode
				CASE $$BN_CLICKED :
					SELECT CASE ID
						CASE 101 :
							PostQuitMessage(0)

						CASE 102 :
							IF hBitmap THEN DeleteObject (hBitmap)
							hBitmap = LoadBitmapA (0, obm[i].number)
							IF hBitmap THEN
								GetObjectA (hBitmap, SIZE (BITMAP), &bm)
								SendDlgItemMessageA (hWnd, 101, $$BM_SETSTYLE, hBitmap, hBitmap)
								text$ = obm[i].name + " :" + STRING$(bm.width) + " x " + STRING$(bm.height)
								SetDlgItemTextA (hWnd, 106, &text$)
							END IF
							INC i
							upp = UBOUND (obm[])
							IF i > upp THEN i = 0

						CASE 105 :
							enabled = !enabled
							EnableWindow (GetDlgItem (hWnd, 104), enabled)

					END SELECT
			END SELECT

		CASE ELSE :
			RETURN ($$FALSE)

	END SELECT

	RETURN ($$TRUE)

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
	IFZ hInst THEN RETURN ($$TRUE)

' register picture button control
	IF Register_Picture_Button () THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  CreateWindows ()  #####
' ##############################
'
FUNCTION  CreateWindows ()

	SHARED hInst

' create main dialog

	#winMain = CreateDialogParamA (hInst, 100, 0, &WndProc(), 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
  UpdateWindow (#winMain)
	ShowWindow (#winMain, $$SW_SHOWNORMAL)	' show window

	SetFocus (GetDlgItem (#winMain, 102))

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
	UnregisterClassA (&className$, hInst)

END FUNCTION
'
'
' ########################################
' #####  Register_Picture_Button ()  #####
' ########################################
'
FUNCTION  Register_Picture_Button ()

	SHARED hInst
	WNDCLASS wc

	wc.style           = 0	' $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &PictureButtonProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 4
	wc.hInstance       = hInst
	wc.hIcon           = NULL
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = $$COLOR_BTNFACE + 1 ' GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &"PICTUREBUTTON"
	IFZ RegisterClassA (&wc) THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##################################
' #####  PictureButtonProc ()  #####
' ##################################
'
FUNCTION  PictureButtonProc (hWnd, msg, wParam, lParam)

	PICTUREBUTTON pb
	CREATESTRUCT cs
	PAINTSTRUCT paint
  BITMAP bm
	RECT r
	TRACKMOUSEEVENT tme
	LOGBRUSH lb

	hp = GetWindowLongA (hWnd, 0)
  IF (hp != NULL) THEN
		p = GlobalLock (hp)
		RtlMoveMemory (&pb, p, SIZE (PICTUREBUTTON))
	END IF

	SELECT CASE msg

		CASE $$WM_CREATE :

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE (CREATESTRUCT))

			width = cs.cx
			height = cs.cy

' allocate memory for picturebutton struct
			hp = GlobalAlloc ($$GMEM_MOVEABLE | $$GMEM_ZEROINIT, SIZE (PICTUREBUTTON))
			IF (hp == NULL) THEN RETURN ($$TRUE)

' get address to memory
      p = GlobalLock (hp)

      XLONGAT (p+24) = height			' set height
      XLONGAT (p+28) = width			' set width

			IF (cs.style & $$WS_DISABLED) THEN
				XLONGAT (p+0) = $$TRUE		' set disabled flag
			END IF

			IF (cs.style & $$WS_TABSTOP) THEN
				XLONGAT (p+16) = $$TRUE 	' set tabstop flag
			END IF

			name$ = CSTRING$ (cs.lpszName)
      XLONGAT (p+32) = LoadBitmapA (GetWindowLongA (hWnd, $$GWL_HINSTANCE), &name$) ' set picture handle

			namex$ = name$ + "X"
      XLONGAT (p+36) = LoadBitmapA (GetWindowLongA (hWnd, $$GWL_HINSTANCE), &namex$) ' set disabled_picture handle

' save allocated memory handle to window proc extra data
			SetWindowLongA (hWnd, 0, hp)
			GlobalUnlock (hp)

		CASE $$BM_SETSTYLE :
			IF (pb.picture != NULL) THEN DeleteObject (pb.picture)
			IF ((pb.disabled_picture != NULL) && (pb.disabled_picture != pb.picture)) THEN
				DeleteObject (pb.disabled_picture)
			END IF

			pb.picture = wParam
			pb.disabled_picture = lParam
			RtlMoveMemory (p, &pb, SIZE(PICTUREBUTTON))
      InvalidateRect (hWnd, NULL, $$TRUE)
      GlobalUnlock (hp)

		CASE $$BM_SETSTATE :
      pb.status_bar 		= wParam
			pb.status_message = CSTRING$ (lParam)
			RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
      GlobalUnlock (hp)

		CASE $$WM_PAINT :
			hdc       = BeginPaint (hWnd, &paint)
      height    = pb.height
      width     = pb.width
      old_pen   = SelectObject (hdc, GetStockObject ($$BLACK_PEN))
			
			lb.style = $$BS_SOLID	 
			lb.color = GetSysColor ($$COLOR_BTNFACE)
			hBrush = CreateBrushIndirect (&lb) 
			old_brush = SelectObject (hdc, hBrush)

'      old_brush = SelectObject (hdc, GetStockObject ($$LTGRAY_BRUSH))

      Rectangle (hdc, 0, 0, width, height)
			IF pb.depressed THEN
				color = $$BLACK_PEN
			ELSE
				color = $$WHITE_PEN
			END IF
      SelectObject(hdc, GetStockObject (color))

      MoveTo (hdc, 1, 1)
      LineTo (hdc, width - 3, 1)
      LineTo (hdc, width - 4, 2)
      LineTo (hdc, 2, 2)
      LineTo (hdc, 2, height - 4)
      LineTo (hdc, 1, height - 3)
      LineTo (hdc, 1, 1)
			IF pb.depressed THEN
				color = $$WHITE_PEN
			ELSE
				color = $$BLACK_PEN
			END IF
      SelectObject(hdc, GetStockObject (color))

      MoveTo (hdc, width - 3, height - 3)
      LineTo (hdc, width - 3, 3)
      LineTo (hdc, width - 2, 2)
      LineTo (hdc, width - 2, height - 2)
      LineTo (hdc, 2, height - 2)
      LineTo (hdc, 3, height - 3)
      LineTo (hdc, width - 3, height - 3)

			SetBkColor   (hdc, RGB (192, 192, 192))
			SetTextColor (hdc, RGB (0, 0, 0))

			IF pb.disabled THEN
				picture = pb.disabled_picture
			ELSE
				picture = pb.picture
			END IF

			IF (picture != NULL) THEN
				memory = CreateCompatibleDC (hdc)
				GetObjectA (picture, SIZE (BITMAP), &bm)
				old_bitmap = SelectObject (memory, picture)
				x = (width - bm.width) / 2
				IF (x < 5) THEN x = 5
				y = (height - bm.height) / 2
				IF (y < 5) THEN y = 5
				IF (pb.depressed) THEN
					INC x
					INC y
				END IF
				BitBlt (hdc, x, y, bm.width, bm.height, memory, 0, 0, $$SRCCOPY)
				SelectObject (memory, old_bitmap)
				DeleteDC (memory)
			END IF

' draw focus rect
			hFocus = GetFocus ()
'			IF (pb.tabstop && pb.focus) THEN
			IF (hFocus = hWnd) THEN
				x = 5 + $$FOCUS_BORDER_WIDTH
				y = x
				bm.width  = width -  2*x
				bm.height = height - 2*y

				r.left   = x - $$FOCUS_BORDER_WIDTH
				r.right  = x + bm.width + $$FOCUS_BORDER_WIDTH
				r.top    = y - $$FOCUS_BORDER_WIDTH
				r.bottom = y + bm.height + $$FOCUS_BORDER_WIDTH
				DrawFocusRect (hdc, &r)
			END IF

      SelectObject (hdc, old_pen)
      SelectObject (hdc, old_brush)
			DeleteObject (hBrush)
      EndPaint (hWnd, &paint)
      GlobalUnlock(hp)

		CASE $$WM_ENABLE :
			IF ((pb.disabled && wParam) || (!pb.disabled && !wParam)) THEN
        pb.disabled = !pb.disabled
        InvalidateRect (hWnd, NULL, $$TRUE)
				RtlMoveMemory (p, &pb, SIZE(PICTUREBUTTON))
			END IF
      GlobalUnlock (hp)

		CASE $$WM_LBUTTONDOWN :
      pb.captured = $$TRUE
      pb.depressed = $$TRUE
      SetCapture (hWnd)
      InvalidateRect (hWnd, NULL, $$TRUE)
			IF (pb.tabstop) THEN SetFocus (hWnd)
			RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
      GlobalUnlock (hp)

		CASE $$WM_LBUTTONUP :
			notify = !pb.captured || (LOWORD (lParam) < pb.width) && (HIWORD(lParam) < pb.height)
			pb.depressed = $$FALSE
			pb.captured  = $$FALSE
			InvalidateRect (hWnd, NULL, $$TRUE)
			ReleaseCapture ()
			IF (notify) THEN PostClickedMessage (hWnd)
			RtlMoveMemory (p, &pb, SIZE(PICTUREBUTTON))
      GlobalUnlock (hp)

		CASE $$WM_MOUSEMOVE :
			IFZ pb.mouse_enter THEN
				pb.mouse_enter = $$TRUE			' mouse has entered button
' track mouse event to get WM_MOUSELEAVE event
				tme.cbSize    = SIZE (tme)
				tme.dwFlags   = $$TME_LEAVE
				tme.hwndTrack = hWnd
				TrackMouseEvent (&tme)

' set status bar window text
				IF ((pb.status_bar != NULL) && (pb.status_message != "")) THEN
					SetWindowTextA (pb.status_bar, &pb.status_message)
				END IF
			END IF

			IF (pb.captured) THEN
				old_depressed = pb.depressed
				pb.depressed = (LOWORD (lParam) < pb.width) && (HIWORD (lParam) < pb.height)
				IF (pb.depressed != old_depressed) THEN
					InvalidateRect (hWnd, NULL, $$TRUE)
					RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
          GlobalUnlock (hp)
					RETURN
				END IF
			END IF
			RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
      GlobalUnlock (hp)

		CASE $$WM_MOUSELEAVE :
			pb.mouse_enter = $$FALSE			' mouse has exited button

' set status window text to NULL
			IF ((pb.status_bar != NULL) && (pb.status_message != "")) THEN
				text$ = ""
				SetWindowTextA (pb.status_bar, &text$)
			END IF
			RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
      GlobalUnlock(hp)

		CASE $$WM_SETFOCUS :
'     pb.focus = $$TRUE
'			RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
      GlobalUnlock(hp)
			InvalidateRect (hWnd, NULL, $$TRUE)

		CASE $$WM_KILLFOCUS :
'			pb.focus = $$FALSE
'			RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
      GlobalUnlock (hp)
			InvalidateRect (hWnd, NULL, $$TRUE)

		CASE $$WM_GETDLGCODE :
      GlobalUnlock (hp)
			RETURN $$DLGC_BUTTON

		CASE $$WM_KEYDOWN :
			IF (wParam == ' ' && !pb.captured && !pb.depressed) THEN
        pb.depressed = $$TRUE
        InvalidateRect (hWnd, NULL, $$TRUE)
				RtlMoveMemory (p, &pb, SIZE (PICTUREBUTTON))
        GlobalUnlock (hp)
				RETURN
			END IF
			GlobalUnlock (hp)

		CASE $$WM_KEYUP :
			IF (wParam == ' ' && !pb.captured) THEN
				pb.depressed = $$FALSE
				InvalidateRect (hWnd, NULL, $$TRUE)
        PostClickedMessage (hWnd)
        GlobalUnlock(hp)
				RETURN
			END IF
			GlobalUnlock (hp)

		CASE $$WM_DESTROY :
			IF (pb.picture != NULL) THEN DeleteObject (pb.picture)
			IF (pb.disabled_picture != NULL && pb.disabled_picture != pb.picture) THEN
				DeleteObject (pb.disabled_picture)
			END IF
			GlobalUnlock (hp)
			GlobalFree (hp)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
'
'
' ###################################
' #####  PostClickedMessage ()  #####
' ###################################
'
FUNCTION  PostClickedMessage (hWnd)

	PostMessageA (GetParent (hWnd), $$WM_COMMAND, MAKELONG (GetMenu (hWnd), $$BN_CLICKED), hWnd)

END FUNCTION
'
'
' #######################
' #####  MoveTo ()  #####
' #######################
'
FUNCTION  MoveTo (hdc, x, y)

	RETURN MoveToEx (hdc, x, y, NULL)

END FUNCTION
END PROGRAM
