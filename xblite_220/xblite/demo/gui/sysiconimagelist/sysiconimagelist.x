'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This demo creates an imagelist using system icons.
'
PROGRAM	"sysiconimagelist"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "shell32"   ' shell32.dll

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  GetSysFolderIcon (file$, @hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)
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

	RECT rc
	SHARED POINT ptIcon[]							' array of bmp positions
	SHARED iWidth, iHeight
	PAINTSTRUCT ps
	POINT mouse												' location of mouse
	STATIC fDrag											' drag flag
	STATIC count											' number of bmp images
	STATIC ID													' id of currently selected image
	STATIC cx, cy											' offset of mouse from image edge

	SELECT CASE msg

		CASE $$WM_DESTROY :
			PostQuitMessage(0)

		CASE $$WM_PAINT :
			hdc = BeginPaint (hWnd, &ps) 											' draw the image list
			count = ImageList_GetImageCount(#himageList)			' get number of images
			REDIM ptIcon[count-1]
			FOR i = 0 TO count-1
				IF i <> ID THEN
					ImageList_Draw (#himageList, i, hdc, ptIcon[i].x, ptIcon[i].y, $$ILD_NORMAL)	' draw all images at current location
				END IF
			NEXT i
				ImageList_Draw (#himageList, ID, hdc, ptIcon[ID].x, ptIcon[ID].y, $$ILD_NORMAL)		' draw selected image last (on top)
			EndPaint (hWnd, &ps)

		CASE $$WM_LBUTTONDOWN :
			mouse.x = LOWORD(lParam)								' get the current mouse position
			mouse.y = HIWORD(lParam)

			finside = $$FALSE
			FOR i = 0 TO count											' is mouse inside an image
				rc.left   = ptIcon[i].x								' determine bmp rectangle
				rc.top    = ptIcon[i].y
				rc.right  = ptIcon[i].x + iWidth
				rc.bottom = ptIcon[i].y + iHeight
				IF PtInRect(&rc, mouse.x, mouse.y) THEN	' if mouse is inside image rect
					fInside = $$TRUE
					ID = i															' get ID of image
					EXIT FOR
				END IF
			NEXT i

			IF fInside THEN																		' we clicked on a BMP
				cx = mouse.x - ptIcon[ID].x               			' calculate the offset from
				cy = mouse.y - ptIcon[ID].y               			' the upper left corner
				ClientToScreen (hWnd, &mouse)         					' convert cursor position -> screen coords
				ImageList_BeginDrag (#himageList, ID, cx, cy)  	' begin dragging an image
				ImageList_DragEnter (0, mouse.x, mouse.y)				' display drag image
				fDrag = $$TRUE                       						' set the drag flag to TRUE
				SetCapture (hWnd)       												' capture the mouse output for this window
			END IF

		CASE $$WM_MOUSEMOVE :
			IFT fDrag THEN																		'skip if we are not dragging the image
				mouse.x = LOWORD(lParam)
				mouse.y = HIWORD(lParam)
				ClientToScreen (hWnd, &mouse)          					'convert BMP position > screen coords
				ImageList_DragMove (mouse.x, mouse.y)						'drag the BMP
			END IF

		CASE $$WM_LBUTTONUP :
			IFT fDrag THEN
				fDrag = $$FALSE								' reset drag flag
				ReleaseCapture()							' release the mouse capture on this window
				ImageList_DragLeave (0)				' unlock the window and hide drag image
				ImageList_EndDrag ()					' end the drag operation
				mouse.x = LOWORD(lParam)			' define the new BMP position
				mouse.y = HIWORD(lParam)
				GetClientRect (hWnd, &rc)			' get the client area size

				IF PtInRect(&rc, mouse.x, mouse.y) THEN 	' check if the destination point lays inside the client area
					ptIcon[ID].x = mouse.x - cx	' update current position of image
					ptIcon[ID].y = mouse.y - cy
					InvalidateRect (hWnd, 0, 1)	' invalidate the entire client area
				END IF
			END IF

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
	SHARED hInst
	SHARED iWidth, iHeight
	SHARED POINT ptIcon[]				' array of bmp positions

' register window class
	className$  = "SysIconImageList"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "System Icons"
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 544
	h 					= 550
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

' find out how many small system icon images are available
	hsiml = GetSysFolderIcon ("c:\\", @hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)

	iCount = ImageList_GetImageCount (hsiml)

' create a new masked image list, 16 x 16 each, 64 color
'	#himageList = ImageList_Create (16, 16, $$ILC_COLOR8 | $$ILC_MASK, iCount, 0)
	#himageList = ImageList_Create (32, 32, $$ILC_COLOR8 | $$ILC_MASK, iCount, 0)

' add icons to image list
	FOR i = 0 TO iCount-1
		hIcon = ImageList_GetIcon (hsiml, i, $$ILD_TRANSPARENT)		' create new icons from system image list
		ret = ImageList_ReplaceIcon (#himageList, -1, hIcon)			' add icons to image list
	NEXT i

' set initial positions for images
	DIM ptIcon[iCount-1]
'	space   = 4
	space   = 8
'	iWidth  = 16
'	iHeight = 16
	iWidth  = 32
	iHeight = 32
	FOR i = 0 TO iCount-1
		ptIcon[i].x = 10 + (col * (iWidth +space))
		ptIcon[i].y = 10 + (row * (iHeight+space))
		INC col
		IF col > 25 THEN
			INC row
			col = 0
		END IF
	NEXT i

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
		ret = GetMessageA (&msg, NULL, 0, 0)

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam
			CASE -1 : RETURN $$TRUE
			CASE ELSE:
  			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
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
' #################################
' #####  GetSysFolderIcon ()  #####
' #################################
'
FUNCTION  GetSysFolderIcon (file$, @hIconFolder, @iIconFolder, @hIconFolderOpen, @iIconFolderOpen)

	SHFILEINFO sfi

'	file$ = "c:\\"						' this will give you the hard-disk icon
'	file$ = "c:\\windows\\"		' this gives the standard folder icons

'	hSysImageList = SHGetFileInfoA (&file$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)
	hSysImageList = SHGetFileInfoA (&file$, 0, &sfi, SIZE(sfi), $$SHGFI_LARGEICON | $$SHGFI_ICON | $$SHGFI_SYSICONINDEX)
	hIconFolder = sfi.hIcon
	iIconFolder = sfi.iIcon

'	il = SHGetFileInfoA (&file$, 0, &sfi, SIZE(sfi), $$SHGFI_SMALLICON | $$SHGFI_ICON | $$SHGFI_OPENICON | $$SHGFI_SYSICONINDEX)
	il = SHGetFileInfoA (&file$, 0, &sfi, SIZE(sfi), $$SHGFI_LARGEICON | $$SHGFI_ICON | $$SHGFI_OPENICON | $$SHGFI_SYSICONINDEX)
	hIconFolderOpen = sfi.hIcon
	iIconFolderOpen = sfi.iIcon

	RETURN hSysImageList

END FUNCTION
END PROGRAM
