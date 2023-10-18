'
'
' ####################
' #####  PROLOG  #####
' ####################

' A demo which draws a random 'truchet' pattern.
' See http://mathworld.wolfram.com/TruchetTiling.html
' Image can be saved to disk as BMP file.
'
PROGRAM	"truchet"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT  "xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll
	IMPORT  "comdlg32"	' comdlg32.dll
	IMPORT	"msvcrt"
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
DECLARE FUNCTION  CreateScreenBuffer (hWnd, w, h)
DECLARE FUNCTION  DeleteScreenBuffer (hdcMem)
DECLARE FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)
DECLARE FUNCTION  SaveMemAsBMP (file$, hdcMem)
DECLARE FUNCTION  get_random (x)
DECLARE FUNCTION  ClearScreenBuffer (hdcMem, bgc)
DECLARE FUNCTION  draw_arc (hdc, x, y, r, startAngle#, endAngle#, color, penWidth, mode)
DECLARE FUNCTION  draw_truchet (hdc, fgc, gridSize, penWidth)
DECLARE FUNCTION  draw_tri_truchet (hdc, fgc, gridSize, @order[])

' Menubar control IDs
$$ID_DRAW_TRUCHET 		= 101
$$ID_SAVE_AS_BMP			= 102
$$ID_FILE_EXIT				= 103

$$ID_SIZE_256					= 130
$$ID_SIZE_512					= 131

$$ID_PEN_RANDOM       = 140

$$ID_STYLE_ARC				= 160
$$ID_STYLE_TRIANGLE   = 161

$$WHITE = 16777215
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

	PAINTSTRUCT ps
	RECT rect
	STATIC hMenuI, hMenuPen, hMenuStyle
	STATIC hdcMem
	SHARED w, h
	STATIC imageSize
	STATIC penSize, style
	STATIC fgc, bgc
	STATIC order[]
	STATIC pick

	SELECT CASE msg

		CASE $$WM_CREATE:
			hMenu = GetMenu (hWnd)
			hMenuI = GetSubMenu (hMenu, 1)												' menu index is 0 based
			CheckMenuRadioItem (hMenuI, 0, 2, 1, $$MF_BYPOSITION)	' item index is 0 based
			imageSize = 512

			hMenuPen = GetSubMenu (hMenu, 2)
			CheckMenuRadioItem (hMenuPen, 0, 10, 0, $$MF_BYPOSITION)	' item index is 0 based
			penSize = 0

			hMenuStyle = GetSubMenu (hMenu, 3)
			CheckMenuRadioItem (hMenuStyle, 0, 1, 0, $$MF_BYPOSITION)	' item index is 0 based
			style = 0

			fgc = RGB (255, 255, 255)
			bgc = 0

			text$ = "Truchet Pattern Demo."
			SetWindowTextA (hWnd, &text$)

			DIM order[3]

	    #screenWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	    #screenHeight = GetSystemMetrics ($$SM_CYSCREEN)

		CASE $$WM_PAINT :
			hdc = BeginPaint (hWnd, &ps)
			BitBlt (hdc, ps.left, ps.top, ps.right-ps.left, ps.bottom-ps.top, hdcMem, ps.left, ps.top, $$SRCCOPY)
			EndPaint (hWnd, &ps)

		CASE $$WM_SIZE:
			sizeType = wParam
			IF (sizeType = $$SIZE_MAXIMIZED) || (sizeType = $$SIZE_RESTORED) THEN
				w = LOWORD (lParam)
				h = HIWORD (lParam)

				DeleteScreenBuffer (hdcMem)
				hdcMem = CreateScreenBuffer (hWnd, w, h)
				ClearScreenBuffer (hdcMem, bgc)
				IFZ style THEN
					size = (get_random (6) + 1) * 16
					draw_truchet (hdcMem, fgc, size, penSize)
				ELSE
					pick = get_random (256)
					GOSUB SelectOrderArray
					draw_tri_truchet (hdcMem, fgc, 32, @order[])
				END IF
				InvalidateRect (hWnd, NULL, $$TRUE)
			END IF

		CASE $$WM_DESTROY:
			DeleteScreenBuffer (hdcMem)
			PostQuitMessage(0)

		CASE $$WM_COMMAND:
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)
			SELECT CASE id

				CASE $$ID_DRAW_TRUCHET :
					ClearScreenBuffer (hdcMem, bgc)
					IFZ style THEN
						size = (get_random (6) + 1) * 16
						draw_truchet (hdcMem, fgc, size, penSize)
					ELSE
'						pick = get_random (256)
						INC pick
						IF pick > 255 THEN pick = 0
						GOSUB SelectOrderArray
						draw_tri_truchet (hdcMem, fgc, 32, @order[])
					END IF
					InvalidateRect (hWnd, NULL, $$TRUE)

				CASE $$ID_SAVE_AS_BMP :
					filter$ = "BMP Files (*.bmp)" + CHR$(0) + "*.bmp" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0)
					title$ = "Save BMP image as"
					ShowSaveFileDialog (hWnd, @file$, filter$, initDir$, title$)
					ret = SaveMemAsBMP (file$, hdcMem)

				CASE $$ID_FILE_EXIT :		DestroyWindow (hWnd)

				CASE $$ID_SIZE_256 :
					imageSize = 256
					CheckMenuRadioItem (hMenuI, 0, 1, 0, $$MF_BYPOSITION)
					x = (#screenWidth - (imageSize+8))/2
					y = (#screenHeight - (imageSize+46))/2
					SetWindowPos (hWnd, 0, x, y, imageSize+8, imageSize+46, $$SWP_NOZORDER)

				CASE $$ID_SIZE_512 :
					imageSize = 512
					CheckMenuRadioItem (hMenuI, 0, 1, 1, $$MF_BYPOSITION)
					x = (#screenWidth - (imageSize+8))/2
					y = (#screenHeight - (imageSize+46))/2
					SetWindowPos (hWnd, 0, x, y, imageSize+8, imageSize+46, $$SWP_NOZORDER)

				CASE 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150 :
					item = id - $$ID_PEN_RANDOM
					penSize = item
					CheckMenuRadioItem (hMenuPen, 0, 10, item, $$MF_BYPOSITION)	' item index is 0 based

				CASE 160, 161 :
					item = id - $$ID_STYLE_ARC
					style = item
					CheckMenuRadioItem (hMenuStyle, 0, 1, item, $$MF_BYPOSITION)	' item index is 0 based

			END SELECT

    CASE ELSE :
      RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** SelectOrderArray *****
SUB SelectOrderArray

	order[0] = pick{2,0}
	order[1] = pick{2,2}
	order[2] = pick{2,4}
	order[3] = pick{2,6}

END SUB

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
'	InitCommonControls()					' initialize comctl32.dll library

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
	wc.hbrBackground   = GetStockObject ($$BLACK_BRUSH)
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

	SHARED className$, hInst

' register window class
	className$  = "TruchetDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	titleBar$  	= "Truchet pattern demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 520
	h 					= 558
	#winMain = NewWindow (className$, titleBar$, style, x, y, w, h, 0)
	IFZ #winMain THEN RETURN ($$TRUE)

	XstCenterWindow (#winMain)							' center window position
	UpdateWindow (#winMain)
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

	style = style | $$WS_CHILD
	hwnd = CreateWindowExA (0, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)
	ShowWindow (hwnd, $$SW_SHOWNORMAL)
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

	IF LIBRARY(0) THEN RETURN								' main program executes message loop

	DO																			' the message loop
		ret = GetMessageA (&msg, NULL, 0, 0)	' retrieve next message from queue

		SELECT CASE ret
			CASE  0 : RETURN msg.wParam					' WM_QUIT message
			CASE -1 : RETURN $$TRUE							' error
			CASE ELSE:
  			TranslateMessage (&msg)						' translate virtual-key messages into character messages
  			DispatchMessageA (&msg)						' send message to window callback function WndProc()
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
' ###################################
' #####  CreateScreenBuffer ()  #####
' ###################################
'
FUNCTION  CreateScreenBuffer (hWnd, w, h)

	hDC 		= GetDC (hWnd)
	memDC 	= CreateCompatibleDC (hDC)
	hBit 		= CreateCompatibleBitmap (hDC, w, h)
	SelectObject (memDC, hBit)
	hBrush 	= GetStockObject ($$BLACK_BRUSH)
	SelectObject (memDC, hBrush)
	PatBlt (memDC, 0, 0, w, h, $$PATCOPY)
	ReleaseDC (hWnd, hDC)
	RETURN memDC

END FUNCTION
'
'
' ###################################
' #####  DeleteScreenBuffer ()  #####
' ###################################
'
FUNCTION  DeleteScreenBuffer (hMemDC)

	hBmp = GetCurrentObject (hMemDC, $$OBJ_BITMAP)
	DeleteObject (hBmp)
	DeleteDC (hMemDC)

END FUNCTION
'
'
' ###################################
' #####  ShowSaveFileDialog ()  #####
' ###################################
'
FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)

	OPENFILENAME ofn
	SHARED hInst

	ofn.lStructSize = LEN(ofn)			'set length of struct
	ofn.hwndOwner 	= hWndOwner			'set parent window handle
	ofn.hInstance 	= hInst					'set the application's instance

'select a filter
'pstrFilter points to a buffer containing pairs of null-terminated
'filter strings. The first string in each pair describes a filter
'(for example, "Text Files"), and the second specifies the
'filter pattern (for example, "*.TXT"). Multiple filters can be
'specified for a single item by separating the filter pattern strings
'with a semicolon (for example, "*.TXT;*.DOC;*.BAK"). The last string
'in the buffer must be terminated by two NULL characters. If this member
'is NULL, the dialog box will not display any filters.
'The filter strings are assumed to be in the proper order - the
'operating system does not change the order.

'	filter$ = "XB Files (*.x, *.dec)" + CHR$(0) + "*.x;*.dec" + CHR$(0) + "Text Files (*.txt)" + CHR$(0) + "*.txt" + CHR$(0) + "All Files (*.*)" + CHR$(0) + "*.*" + CHR$(0) + CHR$(0)
	ofn.lpstrFilter = &filter$

'create a buffer for the returned file
	IF fileName$ = "" THEN
		fileName$ = SPACE$(254)
	ELSE
		fileName$ = fileName$ + SPACE$(254 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$

	ofn.nMaxFile 				= 255					'set the maximum length of a returned file
	buffer2$ = SPACE$(254)
	ofn.lpstrFileTitle 	= &buffer2$		'Create a buffer for the file title
	ofn.nMaxFileTitle 	= 255					'Set the maximum length of a returned file title
	ofn.lpstrInitialDir = &initDir$		'Set the initial directory
  ofn.lpstrTitle 			= &title$			'Set the title
  ofn.flags = $$OFN_PATHMUSTEXIST OR $$OFN_EXPLORER	'flags

'call dialog
	IFZ GetSaveFileNameA (&ofn) THEN
		fileName$ = ""
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF


END FUNCTION
'
'
' #############################
' #####  SaveMemAsBMP ()  #####
' #############################
'
' PURPOSE : Save memory bitmap object as a BMP image.
'
FUNCTION  SaveMemAsBMP (file$, hdcMem)

	BITMAP bm
	UBYTE image[]

	$BI_RGB       = 0														' 24-bit RGB

	IFZ hdcMem THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	IFZ file$ THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidName
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	hImage = GetCurrentObject (hdcMem, $$OBJ_BITMAP)
	GetObjectA (hImage, SIZE(bm), &bm)
	width       = bm.width
	height      = bm.height

	dataOffset = 54

' alignment on multiple of 32 bits or 4 bytes

	size = dataOffset + (height * ((width * 3) + 3 AND -4))
	upper = size - 1
	DIM image[upper]

'	fill BITMAPFILEHEADER

	iAddr = &image[0]

	image[0] = 'B'															' DIB aka BMP signature
	image[1] = 'M'
	image[2] = size AND 0x00FF									' file size
	image[3] = (size >> 8) AND 0x00FF
	image[4] = (size >> 16) AND 0x00FF
	image[5] = (size >> 24) AND 0x00FF
	image[6] = 0
	image[7] = 0
	image[8] = 0
	image[9] = 0
	image[10] = dataOffset AND 0x00FF						' file offset of bitmap data
	image[11] = (dataOffset >> 8) AND 0x00FF
	image[12] = (dataOffset >> 16) AND 0x00FF
	image[13] = (dataOffset >> 24) AND 0x00FF

'	fill BITMAPINFOHEADER (first 6 members)

	info = 14
	image[info+0] = 40													' XLONG : BITMAPINFOHEADER size
	image[info+1] = 0
	image[info+2] = 0
	image[info+3] = 0
	image[info+4] = width AND 0x00FF						' XLONG : width in pixels
	image[info+5] = (width >> 8) AND 0x00FF
	image[info+6] = (width >> 16) AND 0x00FF
	image[info+7] = (width >> 24) AND 0x00FF
	image[info+8] = height AND 0x00FF						' XLONG : height in pixels
	image[info+9] = (height >> 8) AND 0x00FF
	image[info+10] = (height >> 16) AND 0x00FF
	image[info+11] = (height >> 24) AND 0x00FF
	image[info+12] = 1													' USHORT : # of planes
	image[info+13] = 0													'
	image[info+14] = 24													' USHORT : bits per pixel
	image[info+15] = 0													'
	image[info+16] = $BI_RGB										' XLONG : 24-bit RGB
	image[info+17] = 0													'
	image[info+18] = 0													'
	image[info+19] = 0													'
	image[info+20] = 0													' XLONG : sizeImage
	image[info+21] = 0													'
	image[info+22] = 0													'
	image[info+23] = 0													'
	image[info+24] = 0													' XLONG : xPPM
	image[info+25] = 0													'
	image[info+26] = 0													'
	image[info+27] = 0													'
	image[info+28] = 0													' XLONG : yPPM
	image[info+29] = 0													'
	image[info+30] = 0													'
	image[info+31] = 0													'
	image[info+32] = 0													' XLONG : clrUsed
	image[info+33] = 0													'
	image[info+34] = 0													'
	image[info+35] = 0													'
	image[info+36] = 0													' XLONG : clrImportant
	image[info+37] = 0													'
	image[info+38] = 0													'
	image[info+39] = 0													'

	dataAddr = iAddr + dataOffset
	infoAddr = iAddr + 14

	x = 0
	y = 0

	ok = GetDIBits (hdcMem, hImage, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)

	IFZ ok THEN RETURN ($$FALSE)

	size = SIZE (image[])

	ofile = OPEN (file$, $$WRNEW)

	IF (ofile < 3) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	bytesWritten = 0
	error = XxxWriteFile (ofile, &image[], size, &bytesWritten, 0)
	IF error THEN RETURN ($$FALSE)

	CLOSE (ofile)
	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  get_random ()  #####
' ###########################
'
FUNCTION  get_random (x)

	STATIC entry

	IFZ x THEN RETURN ($$TRUE)

	IFZ entry THEN
		entry = $$TRUE
		seed = (GetTickCount () MOD 32767) + 1
		srand (seed)
	END IF

	RETURN rand() MOD x


END FUNCTION
'
'
' ##################################
' #####  ClearScreenBuffer ()  #####
' ##################################
'
FUNCTION  ClearScreenBuffer (hdcMem, bgc)

	BITMAP bm

	IFZ hdcMem THEN RETURN ($$TRUE)
	hImage = GetCurrentObject (hdcMem, $$OBJ_BITMAP)
	IFZ hImage THEN RETURN ($$TRUE)

	GetObjectA (hImage, SIZE(bm), &bm)
	w = bm.width
	h = bm.height

	IF bgc = -1 THEN
		hBrush 	= GetStockObject ($$BLACK_BRUSH)
	ELSE
		hBrush = CreateSolidBrush (bgc)
	END IF

	lastBrush = SelectObject (hdcMem, hBrush)
	PatBlt (hdcMem, 0, 0, w, h, $$PATCOPY)
	SelectObject (hdcMem, lastBrush)

	DeleteObject (hBrush)

END FUNCTION
'
'
' #########################
' #####  draw_arc ()  #####
' #########################
'
FUNCTION  draw_arc (hdc, x, y, r, startAngle#, endAngle#, color, penWidth, mode)

	POINT pt

	$ARC_UNITS_PER_TWOPI = 0d40ACA5DC1A63C1F8			' 360 * 64 / $$TWOPI
	$DEGTORAD	= 0d3F91DF46A2529D39

	IFZ r THEN RETURN
	IFZ hdc THEN RETURN

	type = GetObjectType (hdc)
	SELECT CASE type
		CASE $$OBJ_DC, $$OBJ_MEMDC 	:
		CASE ELSE 									: RETURN
	END SELECT

	MoveToEx (hdc, x, y, 0)											' set current draw point
	GetCurrentPositionEx (hdc, &pt)

	x				= pt.x
	y				= pt.y
	left		= x - r
	top			= y - r
	right		= x + r + 1													' include last pixel
	bottom	= y + r + 1
	start# 	= startAngle# * $DEGTORAD
	end# 		= endAngle# * $DEGTORAD
	x1			= x + 1024# * cos(start#)
	y1			= y - 1024# * sin(start#)
	x2			= x + 1024# * cos(end#)
	y2			= y - 1024# * sin(end#)

	IF mode > 0 THEN
		lastRop2 = SetROP2 (hdc, mode)
	END IF

	IFZ penWidth THEN penWidth = 1
	hPen = CreatePen ($$PS_SOLID, penWidth, color)
	hOld = SelectObject (hdc, hPen)

	Arc (hdc, left, top, right, bottom, x1, y1, x2, y2)

	SelectObject (hdc, hOld)
	DeleteObject (hPen)

	IF mode > 0 THEN
		SetROP2 (hdc, lastRop2)
	END IF

	RETURN ($$TRUE)


END FUNCTION
'
'
' #############################
' #####  draw_truchet ()  #####
' #############################
'
FUNCTION  draw_truchet (hdc, fgc, gridSize, penWidth)

	SHARED w, h

	IFZ gridSize THEN
		gridSize = get_random (w/4) + 10
	END IF

	gs = gridSize
	gs2 = gridSize/2

	IFZ penWidth THEN
		penWidth = get_random (gs2/2) + 1
	END IF

	FOR i = 0 TO w STEP gridSize
		FOR j = 0 TO h STEP gridSize

			IF get_random (2) THEN

				draw_arc (hdc, i+gs, j, gs2, 180, 270, fgc, penWidth, mode)
				draw_arc (hdc, i, j+gs, gs2, 0, 90, fgc, penWidth, mode)

			ELSE

				draw_arc (hdc, i, j, gs2, 270, 360, fgc, penWidth, mode)
				draw_arc (hdc, i+gs, j+gs, gs2, 90, 180, fgc, penWidth, mode)

			END IF

		NEXT j
	NEXT i

END FUNCTION
'
'
' #################################
' #####  draw_tri_truchet ()  #####
' #################################
'
FUNCTION  draw_tri_truchet (hdc, fgc, gridSize, @order[])

	SHARED w, h
	POINT winPts[]

	IFZ gridSize THEN
		gridSize = get_random (w/4) + 10
	END IF

	gs = gridSize-1

	DIM winPts[2]

'	pc = RGB (255, 0, 0)
'	hPen = CreatePen ($$PS_SOLID, 1, pc)
	hPen = CreatePen ($$PS_SOLID, 1, fgc)
	hOldPen = SelectObject (hdc, hPen)

	hBrush = CreateSolidBrush (fgc)
	hOldBrush = SelectObject (hdc, hBrush)

	upper = UBOUND (order[])

	FOR i = 0 TO w STEP gridSize
		FOR j = 0 TO h STEP gridSize

			IF order[] THEN
				IF count > upper THEN count = 0
				pick = order[count]
				INC count
			ELSE
				pick = get_random (4)
			END IF

			SELECT CASE pick
				CASE 0 :
					winPts[0].x = i 			: winPts[0].y = j
					winPts[1].x = i 			: winPts[1].y = j + gs
					winPts[2].x = i + gs 	: winPts[2].y = j + gs

				CASE 1 :
					winPts[0].x = i 			: winPts[0].y = j
					winPts[1].x = i 			: winPts[1].y = j + gs
					winPts[2].x = i + gs 	: winPts[2].y = j

				CASE 2 :
					winPts[0].x = i 			: winPts[0].y = j
					winPts[1].x = i + gs 	: winPts[1].y = j + gs
					winPts[2].x = i + gs 	: winPts[2].y = j

				CASE 3 :
					winPts[0].x = i 			: winPts[0].y = j + gs
					winPts[1].x = i + gs 	: winPts[1].y = j + gs
					winPts[2].x = i + gs 	: winPts[2].y = j
			END SELECT

			Polygon (hdc, &winPts[], 3)

		NEXT j
	NEXT i

	SelectObject (hdc, hOldPen)
	DeleteObject (hPen)
	SelectObject (hdc, hOldBrush)
	DeleteObject (hBrush)


END FUNCTION
END PROGRAM
