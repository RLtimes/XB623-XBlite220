'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program draws the standard mandelbrot set.
' It includes two different methods to calculate
' the set, a standard scan and a faster interleave
' type method. Various size images can be drawn
' and saved as bmp's. Color maps can be used with
' various coloring algorithms. Each image can be
' zoomed and redrawn until you run out of significant
' floating point digits.
' ---
' To use program, just select various settings
' and select Draw Current Settings under the
' Draw menu. Zooming is accomplished by dragging
' the left-mouse to created a zoom selection box.
' To draw the current selection, double click
' inside the box. Click outside the box to remove
' the selection. Click the right mouse to go back
' to the previously selected zoom level.
' ---
' Images can be saved as BMP images up to
' 3600x3600 pixels.
' ---
' (c) David Szafranski 2002 GPL
' dszafranski@wanadoo.fr
'
PROGRAM	"mandelbrot"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT  "kernel32"  ' kernel32.dll
	IMPORT  "comctl32"	' comctl32.dll"
	IMPORT  "msvcrt"    ' msvcrt.dll
  IMPORT  "comdlg32"	' comdlg32.dll

TYPE RGBDATA
	UBYTE	.r
	UBYTE	.g
	UBYTE	.b
END TYPE

TYPE FRACTALPT
	XLONG	.iter
	DOUBLE	.re
	DOUBLE	.im
END TYPE

TYPE ZOOMDATA
	DOUBLE	.x1
	DOUBLE	.y1
	DOUBLE	.x2
	DOUBLE	.y2
END TYPE

'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  DrawMandelbrot (ww, wh, DOUBLE mx1, DOUBLE my1, DOUBLE mx2, DOUBLE my2, UBYTE data[])
DECLARE FUNCTION  DrawMandelbrotInterleave (ww, wh, DOUBLE mx1, DOUBLE my1, DOUBLE mx2, DOUBLE my2, UBYTE data[], scheme, maxIter, RGBDATA cmap[])
DECLARE FUNCTION  FRACTALPT IteratePoint (DOUBLE x, DOUBLE y, basin)
DECLARE FUNCTION  DrawMandelbrotScan (ww, wh, DOUBLE mx1, DOUBLE my1, DOUBLE mx2, DOUBLE my2, UBYTE data[], scheme, maxIter, RGBDATA cmap[])
DECLARE FUNCTION  RGBDATA FractColor (FRACTALPT fpt, scheme, RGBDATA cmap[])
DECLARE FUNCTION  GetColorMap (fileName$, RGBDATA cmap[])
DECLARE FUNCTION  ShowOpenFileDialog (hWndOwnder, @fileName$, filter$, initDir$, title$)
DECLARE FUNCTION  HLStoRGB (DOUBLE hue, DOUBLE lightness, DOUBLE saturation, red, green, blue)
DECLARE FUNCTION  Value (DOUBLE m1, DOUBLE m2, DOUBLE h)
DECLARE FUNCTION  ClearScreen (hWnd)
DECLARE FUNCTION  CanvasProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  SaveDIB (file$, UBYTE mdata[], mSize)
DECLARE FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)

' fractal coloring schemes
	$$COLOR_ESCAPETIME 		= 0
	$$COLOR_IMAGINARY			= 1
	$$COLOR_POTENTIAL 		= 2
	$$COLOR_DECOMPOSITION = 3
	$$COLOR_ZRATIOS       = 4
	$$COLOR_ZMAGNITUDE		= 5
	$$COLOR_ATAN					= 6
	$$COLOR_HLS						= 7

' fractal calc method
	$$METHOD_SCAN					= 0
	$$METHOD_INTERLEAVE   = 1

	$$MAX_COLORS = 256

'Control IDs

$$Menu_File_Exit 						= 101
$$Menu_File_Map  						= 102
$$Menu_File_Save						= 103

$$Menu_Draw_Init						= 110
$$Menu_Draw_Current					= 111

$$Menu_Color_EscapeTime			= 120
$$Menu_Color_Imaginary			= 121
$$Menu_Color_Potential 			= 122
$$Menu_Color_Decomposition 	= 123
$$Menu_Color_ZRatios       	= 124
$$Menu_Color_ZMagnitude			= 125
$$Menu_Color_Atan						= 126
$$Menu_Color_HLS						= 127

$$Menu_Iter_3								= 140
$$Menu_Iter_4								= 141
$$Menu_Iter_5								= 142
$$Menu_Iter_6								= 143

$$Menu_Size_300							= 150
$$Menu_Size_600							= 151
$$Menu_Size_1200						= 152
$$Menu_Size_2400						= 153
$$Menu_Size_3600						= 154

$$Menu_Method_Scan					= 160
$$Menu_Method_Interleave		= 161

$$Statusbar 								= 200
$$Canvas										= 300

' custom messages

$$WM_INITMANDELBROT					= 1024
$$WM_DRAWMANDELBROT					= 1025
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

	SHARED hInst
	RECT rect
	WNDCLASS wc

	SHARED BITMAPINFO bmpInfo
	SHARED bits, hDIB
	SHARED UBYTE mdata[]							' fractal color data array
	SHARED RGBDATA cMap[]							' currently loaded map RGB data
	SHARED mColoring									' current map type
	SHARED mIter											' max number of iterations
	SHARED mSize                      ' size in pixels of drawing
	SHARED mMethod										' method used to calc fractral

	SHARED fBlt             					' TRUE if DIB has been created
	STATIC initDir$										' current directory

	SELECT CASE msg

		CASE $$WM_CREATE :
			#mainMenu = CreateMenu()				' create main menu
			#fileMenu = CreateMenu()				' create dropdown file menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #fileMenu, &"&File")
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Map, &"Select &Color Map")
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Save, &"&Save As BMP")
			AppendMenuA (#fileMenu, $$MF_SEPARATOR, 0, 0)
			AppendMenuA (#fileMenu, $$MF_STRING, $$Menu_File_Exit, &"&Exit")

			#drawMenu = CreateMenu()				' create dropdown draw menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #drawMenu, &"&Draw")
			AppendMenuA (#drawMenu, $$MF_STRING, $$Menu_Draw_Init, &"Draw &Initialized")
			AppendMenuA (#drawMenu, $$MF_STRING, $$Menu_Draw_Current, &"Draw &Current Settings")

			#colorMenu = CreateMenu()				' create dropdown colorAlgorithm menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #colorMenu, &"&Coloring Algorithm")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_EscapeTime, &"&Escape-Time")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_Imaginary, &"&Imaginary")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_Potential, &"&Potential")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_Decomposition, &"&Decomposition")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_ZRatios, &"Z-&Ratios")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_ZMagnitude, &"Z-&Magnitude")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_Atan, &"&Atan")
			AppendMenuA (#colorMenu, $$MF_STRING, $$Menu_Color_HLS, &"&HSV")

			CheckMenuRadioItem (#colorMenu, 0, 7, 0, $$MF_BYPOSITION)

			#iterMenu = CreateMenu()				' create dropdown iteration menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #iterMenu, &"&Iterations")
			AppendMenuA (#iterMenu, $$MF_STRING, $$Menu_Iter_3, &"10^3")
			AppendMenuA (#iterMenu, $$MF_STRING, $$Menu_Iter_4, &"10^4")
			AppendMenuA (#iterMenu, $$MF_STRING, $$Menu_Iter_5, &"10^5")
			AppendMenuA (#iterMenu, $$MF_STRING, $$Menu_Iter_6, &"10^6")

			CheckMenuRadioItem (#iterMenu, 0, 3, 0, $$MF_BYPOSITION)

			#sizeMenu = CreateMenu()				' create dropdown size menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #sizeMenu, &"&Size")
			AppendMenuA (#sizeMenu, $$MF_STRING, $$Menu_Size_300,  &"300x300")
			AppendMenuA (#sizeMenu, $$MF_STRING, $$Menu_Size_600,  &"600x600")
			AppendMenuA (#sizeMenu, $$MF_STRING, $$Menu_Size_1200, &"1200x1200")
			AppendMenuA (#sizeMenu, $$MF_STRING, $$Menu_Size_2400, &"2400x2400")
			AppendMenuA (#sizeMenu, $$MF_STRING, $$Menu_Size_3600, &"3600x3600")

			CheckMenuRadioItem (#sizeMenu, 0, 4, 0, $$MF_BYPOSITION)

			#methodMenu = CreateMenu()				' create dropdown method menu
			InsertMenuA (#mainMenu, $$TRUE, $$MF_BYPOSITION | $$MF_POPUP, #methodMenu, &"&Method")
			AppendMenuA (#methodMenu, $$MF_STRING, $$Menu_Method_Scan,  &"&Scan")
			AppendMenuA (#methodMenu, $$MF_STRING, $$Menu_Method_Interleave,  &"&Interleave")

			CheckMenuRadioItem (#methodMenu, 0, 1, 0, $$MF_BYPOSITION)

			SetMenu (hWnd, #mainMenu)					' activate the menu

' create a 2 part status bar
			#statusBar = NewChild ($$STATUSCLASSNAME, "", $$SBARS_SIZEGRIP, 0, 0, 0, 0, hWnd, $$Statusbar, 0)
			GetClientRect (#statusBar, &rect)
			DIM widths[1]
			widths[0] = 360
			widths[1] = -1
			SendMessageA (#statusBar, $$SB_SETPARTS, 2, &widths[0])
			SendMessageA (#statusBar, $$SB_SETTEXT, 0, &"Drag left mouse to draw zoom box selection, then double-click selection.")
			#statusHeight = rect.bottom

' create a scrollable child window to display image

			wc.style           = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC	| $$CS_DBLCLKS
			wc.lpfnWndProc     = &CanvasProc()
			wc.cbClsExtra      = 0
			wc.cbWndExtra      = 0
			wc.hInstance       = hInst
			wc.hIcon           = 0
			wc.hCursor         = 0										' cursor set in CanvasProc()
			wc.hbrBackground   = GetStockObject ($$BLACK_BRUSH)
			wc.lpszMenuName    = 0
			wc.lpszClassName   = &"canvas"
			RegisterClassA (&wc)

			GetClientRect (hWnd, &rect)
			#canvas = NewChild ("canvas", "", $$WS_HSCROLL | $$WS_VSCROLL, 0, 0, rect.right, rect.bottom-#statusHeight, hWnd, $$Canvas, 0)

			GOSUB CreateDIB								' create DIB Section in memory to hold image

			SendMessageA (#canvas, $$WM_INITMANDELBROT, 0, 0)		' initialize first mandelbrot parameters
			SendMessageA (#canvas, $$WM_DRAWMANDELBROT, 0, 0)		' draw first image

' get current directory
			initDir$ = NULL$ (255)
			GetCurrentDirectoryA (LEN(initDir$), &initDir$)
			initDir$ = CSIZE$(initDir$)

		CASE $$WM_DESTROY :
			DeleteObject (hDIB)
			PostQuitMessage(0)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE TRUE
				CASE id = $$Menu_File_Exit :
					PostQuitMessage(0)

				CASE id = $$Menu_File_Map :
					filter$ = "Fractal MAP (*.map)" + CHR$(0) + "*.map"
					title$ = "Load Fractal Color Map"
					IFZ ShowOpenFileDialog (hWnd, @fileName$, filter$, initDir$, title$) THEN RETURN
					IFZ fileName$ THEN RETURN
					GetColorMap (fileName$, @cMap[])
					SendMessageA (#statusBar, $$SB_SETTEXT, 1, &fileName$)

				CASE id = $$Menu_File_Save :
					filter$ = "Save as BMP (*.bmp)" + CHR$(0) + "*.bmp"
					title$ = "Save Image as BMP"
					IFZ ShowSaveFileDialog (hWnd, @fileName$, filter$, initDir$, title$) THEN RETURN
					IF RIGHT$(LCASE$(fileName$), 4) != ".bmp" THEN
						fileName$ = fileName$ + ".bmp"
					END IF
					SaveDIB (fileName$, @mdata[], mSize)

				CASE id = $$Menu_Draw_Init :
					SendMessageA (#canvas, $$WM_INITMANDELBROT, 0, 0)
					SendMessageA (#canvas, $$WM_DRAWMANDELBROT, 0, 0)

				CASE id = $$Menu_Draw_Current :
					SendMessageA (#canvas, $$WM_DRAWMANDELBROT, 0, 0)

				CASE id >= $$Menu_Color_EscapeTime && id <= $$Menu_Color_HLS :
					mColoring = id - $$Menu_Color_EscapeTime
					CheckMenuRadioItem (#colorMenu, 0, 7, mColoring, $$MF_BYPOSITION)

				CASE id >= $$Menu_Iter_3 && id <= $$Menu_Iter_6 :
					mIter = 10 ** (id - $$Menu_Iter_3 + 3)
					CheckMenuRadioItem (#iterMenu, 0, 3, id - $$Menu_Iter_3, $$MF_BYPOSITION)

				CASE id >= $$Menu_Size_300 && id <= $$Menu_Size_3600 :
					pos = id - $$Menu_Size_300
					CheckMenuRadioItem (#sizeMenu, 0, 4, pos, $$MF_BYPOSITION)
					SELECT CASE id
						CASE $$Menu_Size_300  : mSize = 300
						CASE $$Menu_Size_600  : mSize = 600
						CASE $$Menu_Size_1200 : mSize = 1200
						CASE $$Menu_Size_2400 : mSize = 2400
						CASE $$Menu_Size_3600 : mSize = 3600
					END SELECT

					GOSUB CreateDIB															' resize bitmap

				CASE id >= $$Menu_Method_Scan && id <= $$Menu_Method_Interleave :
					pos = id - $$Menu_Method_Scan
					CheckMenuRadioItem (#methodMenu, 0, 1, pos, $$MF_BYPOSITION)
					mMethod = pos
			END SELECT

		CASE $$WM_SIZE :
			SELECT CASE wParam
				CASE $$SIZE_MAXIMIZED, $$SIZE_RESTORED :
					w = LOWORD(lParam)
					h = HIWORD(lParam)
					SendMessageA (#statusBar, $$WM_SIZE, wParam, lParam)
					MoveWindow (#canvas, 0, 0, w, h-#statusHeight, $$TRUE)
				END SELECT

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


' ***** CreateDIB *****
SUB CreateDIB
	IF hDIB THEN DeleteObject (hDIB)		' delete last DIB

	bmpInfo.bmiHeader.biSize 				= SIZE(BITMAPINFOHEADER)
	bmpInfo.bmiHeader.biWidth 			= mSize
	bmpInfo.bmiHeader.biHeight 			= mSize
	bmpInfo.bmiHeader.biPlanes 			= 1
	bmpInfo.bmiHeader.biBitCount 		= 24
	bmpInfo.bmiHeader.biCompression = $$BI_RGB

	hDIB = CreateDIBSection (0, &bmpInfo, $$DIB_RGB_COLORS, &bits, 0, 0)

	IF hDIB THEN
		fBlt = $$TRUE
	ELSE
		fBlt = $$FALSE
	END IF

	IFZ hDIB THEN
		ret = hDIB
		PRINT "CreateDIBSection () Error"
		GOSUB GetErrorMessage
	END IF

END SUB


' ***** GetErrorMessage *****
SUB GetErrorMessage
	IFZ ret THEN
		error$ = NULL$(255)
		FormatMessageA ($$FORMAT_MESSAGE_FROM_SYSTEM, 0, GetLastError(), 0, &error$, LEN(error$), 0)
		PRINT "Error : "; CSIZE$(error$)
	END IF
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

	SHARED className$

' register window class
	className$  = "MandelbrotDemo"
	addrWndProc = &WndProc()
	icon$ 			= "mandelbrot"
	menu$ 			= ""
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "Mandelbrot Demo."
	style 			= $$WS_OVERLAPPEDWINDOW ' | $$WS_CLIPCHILDREN
	w 					= 500
	h 					= 500
	exStyle			= 0
	#winMain = NewWindow (className$, title$, style, x, y, w, h, exStyle)
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
' #########################
' #####  NewChild ()  #####
' #########################
'
FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION
'
'
' ###############################
' #####  DrawMandelbrot ()  #####
' ###############################

' The SCAN method is the classic iterative mandelbrot algorithm
' along with period detection and cardiod checking routines.
' It is the simplest method of generating an image of M.
' As its name suggests, this algorithm simply scans the chosen
' region from top to bottom, doing a complete iteration for each
' pixel on the screen.

' IN 	: ww - window width
'			: wh - window height
'			: mx1, my1 - mandelbrot upper left coords
'			: mx2, my2 - mandelbrot lower right coords

' OUT : data[] - byte array of color values for mandelbrot set
'
FUNCTION  DrawMandelbrot (ww, wh, DOUBLE mx1, DOUBLE my1, DOUBLE mx2, DOUBLE my2, UBYTE data[])

DOUBLE x, y
SHARED DOUBLE epsilon_x, epsilon_y
SHARED MAX_ITER
FRACTALPT fpt

	IFZ ww THEN RETURN
	IFZ wh THEN RETURN

	MAX_ITER = 255

	lineBytes = (3*ww + 3) AND -4		' pad line to 4-byte boundary
	imageBytes = wh * lineBytes			' total required bytes for image
	DIM data[imageBytes]						' dim data[]
	dataAddr = &data[0]							' address of data[] array

	mw = mx2 - mx1									' mandelbrot x range
	mh = my2 - my1									' mandelbrot y range

	xstep = mw/ww										' x step
	ystep = mh/wh										' y step

	epsilon_x = xstep 							' period detection margin, 1 pixel
	epsilon_y = ystep

	upperW = ww - 1
	upperH = wh - 1

	basin = $$FALSE

	x = mx1
	FOR i = 0 TO upperW
		y = my1
		FOR j = 0 TO upperH

			fpt = IteratePoint (x, y, @basin)

'			IF fpt.iter <> MAX_ITER THEN
'				level = (iter MOD 26) + 1
'				color = (level*10) | (100 << 8) | (200 << 16)
'				SetPixelV (#hMemDC, i, j, color)							' draw point to hDC, slow
'			END IF

			IF fpt.iter <> MAX_ITER THEN										' set RGB data[] values
				byte = ((upperH-j) * lineBytes) + (i * 3)			' byte in bottom up scan line arrays
				byteAddr = dataAddr + byte										' calc address in memory
'				data[byte]   		= 200													' blue
'				data[byte + 1] 	= 100													' green
'				data[byte + 2] 	= ((iter MOD 26) + 1) * 10		' red
' setting values in memory directly is slightly faster
				UBYTEAT(byteAddr)   	= 200													' blue
				UBYTEAT(byteAddr+1) 	= 100													' green
				UBYTEAT(byteAddr+2) 	= ((fpt.iter MOD 26) + 1) * 10		' red
			END IF

			y = y + ystep
		NEXT j
		x = x + xstep
	NEXT i

	RETURN

END FUNCTION
'
'
' #########################################
' #####  DrawMandelbrotInterleave ()  #####
' #########################################

' IN 	: ww - window width
'			: wh - window height
'			: mx1, my1 - mandelbrot upper left coords
'			: mx2, my2 - mandelbrot lower right coords
'			: scheme - coloring method
'			: maxIter - maximum number of iterations to perform on a point
'			: cmap[] - array of color map values

' OUT : data[] - byte array of color values for mandelbrot set
'
FUNCTION  DrawMandelbrotInterleave (ww, wh, DOUBLE mx1, DOUBLE my1, DOUBLE mx2, DOUBLE my2, UBYTE data[], scheme, maxIter, RGBDATA cmap[])

	DOUBLE mw, mh
	DOUBLE x, y, xstep, ystep, nuystep, help
	SHARED DOUBLE epsilon_x, epsilon_y
	FRACTALPT fpt
	SHARED MAX_ITER
	SHARED DOUBLE bailout
	RGBDATA rgb

	$INTERLEAVE = 4

	IFZ (ww * wh) THEN RETURN

	MAX_ITER = maxIter

	IF scheme = $$COLOR_POTENTIAL THEN
		bailout = 500.0
	ELSE
		bailout = 4.0
	END IF

	lineBytes = (3*ww + 3) AND -4		' pad line to 4-byte boundary
	imageBytes = wh * lineBytes			' total required bytes for image
	DIM data[imageBytes]						' dim data[]
	dataAddr = &data[0]							' address of data[] array

	mw = mx2 - mx1									' mandelbrot x range
	mh = my2 - my1									' mandelbrot y range

	xstep = mw/ww										' x step
	ystep = mh/wh										' y step
	nuystep = ystep * $INTERLEAVE
	yStart = $INTERLEAVE

	epsilon_x = xstep 							' period detection margin, 1 pixel
	epsilon_y = ystep

	upperW = ww - 1
	upperH = wh - 1

	basin = $$FALSE

	x = mx1
	FOR i = 0 TO upperW
		y = my1
		fpt = IteratePoint (x, y, @basin)
		savecolor = fpt.iter
		savey = 0
		y = y + nuystep
		FOR j = $INTERLEAVE TO upperH STEP $INTERLEAVE
			fpt = IteratePoint (x, y, @basin)
			color = fpt.iter
			IF color == savecolor THEN GOTO nextj
			z = j - 1
			help = y - ystep
			fpt = IteratePoint (x, help, @basin)
			helpcolor = fpt.iter
			DO WHILE (z > savey) && (helpcolor != savecolor)
				GOSUB SetPixelColor
				DEC z
				help = help - ystep
				fpt = IteratePoint (x, help, @basin)
				helpcolor = fpt.iter
			LOOP
			GOSUB SetLineColor
			savey = j
			savecolor = color
nextj:
			y = y + nuystep

		NEXT j

		z = upperH
		help = y - ystep
		fpt = IteratePoint (x, help, @basin)
		helpcolor = fpt.iter
		DO WHILE (z > savey) && (helpcolor != savecolor)
			GOSUB SetPixelColor
			DEC z
			help = help - ystep
			fpt = IteratePoint (x, help, @basin)
			helpcolor = fpt.iter
		LOOP
		GOSUB SetLineColor
		savey = j

		x = x + xstep
	NEXT i

	RETURN

' ***** SetPixelColor *****
SUB SetPixelColor
	IF helpcolor != MAX_ITER THEN
		rgb = FractColor (fpt, scheme, @cmap[])				' get rgb color values for point (0-255)
		byte = ((upperH-z) * lineBytes) + (i * 3)			' byte in bottom up scan line arrays
		byteAddr = dataAddr + byte										' calc address in memory
																									' setting values in memory directly is slightly faster

		UBYTEAT(byteAddr)   	= rgb.b									' blue
		UBYTEAT(byteAddr+1) 	= rgb.g									' green
		UBYTEAT(byteAddr+2) 	= rgb.r									' red
	END IF
END SUB

' ***** SetLineColor *****
SUB SetLineColor
	IF savecolor <> MAX_ITER THEN
		rgb = FractColor (fpt, scheme, @cmap[])				' get rgb color values for point (0-255)
		FOR k = savey TO z
			byte = ((upperH-k) * lineBytes) + (i * 3)		' byte in bottom up scan line arrays
			byteAddr = dataAddr + byte									' calc address in memory
																									' setting values in memory directly is slightly faster
			UBYTEAT(byteAddr)   	= rgb.b								' blue
			UBYTEAT(byteAddr+1) 	= rgb.g								' green
			UBYTEAT(byteAddr+2) 	= rgb.r								' red
		NEXT k
	END IF

END SUB

END FUNCTION
'
'
' #############################
' #####  IteratePoint ()  #####
' #############################
'
FUNCTION  FRACTALPT IteratePoint (DOUBLE x, DOUBLE y, basin)

	DOUBLE zx, zy, cx, cy, zx2, zy2
	DOUBLE last_zx, last_zy
	SHARED DOUBLE epsilon_x, epsilon_y
	SHARED MAX_ITER
	FRACTALPT fpt
	SHARED DOUBLE bailout

'	MAX_ITER = 255
'	bailout = 500.0

		IF (basin) THEN										' if last point is in a 'lake' then do cardiod check and period check

			IF x <= -0.75 THEN							' check to see if point is in largest circular disk centered at (-1,0), with r = .25
				zx = x + 1.0
				IF (zx*zx + y*y) <= 0.0625 THEN
					fpt.re = x
					fpt.im = y
					fpt.iter = MAX_ITER
					RETURN fpt
				END IF
			ELSE														' check to see if point is in main cardioid
				zx = x - 0.25
				zy = zx*zx + y*y
				zx = zx + zy + zy
				IF (zx*zx <= zy) THEN
					fpt.re = x
					fpt.im = y
					fpt.iter = MAX_ITER
					RETURN fpt
				END IF
			END IF

			iter = 0
			zx = x
			zy = y
			cx = x
			cy = y

			next_compare = 1
			next_period = 1

			DO
				INC iter
				zx2 = zx * zx
				zy2 = zy * zy
				zy = (zx+zx)*zy + cy
				zx = zx2 - zy2  + cx

				DEC next_compare
				IFZ next_compare THEN
					IF fabs(zx-last_zx) < epsilon_x THEN
						IF fabs(zy-last_zy) < epsilon_y THEN
							fpt.re = zx
							fpt.im = zy
							fpt.iter = MAX_ITER
							RETURN fpt
						END IF
					END IF
					last_zx = zx
					last_zy = zy
					INC next_period
					next_compare = next_period
				END IF

			LOOP WHILE (iter < MAX_ITER && zx2 + zy2 < bailout)
			basin = (iter >= MAX_ITER)
			fpt.re = zx
			fpt.im = zy
			fpt.iter = iter
			RETURN fpt

		ELSE
			iter = 0
			zx = x
			zy = y
			cx = x
			cy = y
			DO
				INC iter
				zx2 = zx * zx
				zy2 = zy * zy
				zy = (zx+zx)*zy + cy
				zx = zx2 - zy2  + cx
			LOOP WHILE (iter < MAX_ITER && zx2 + zy2 < 4.0)
			basin = (iter >= MAX_ITER)
			fpt.re = zx
			fpt.im = zy
			fpt.iter = iter
			RETURN fpt
		END IF

END FUNCTION
'
'
' ###################################
' #####  DrawMandelbrotScan ()  #####
' ###################################

' The SCAN method is the classic iterative mandelbrot algorithm
' along with period detection and cardiod checking routines.
' It is the simplest method of generating an image of M.
' As its name suggests, this algorithm simply scans the chosen
' region from top to bottom, doing a complete iteration for each
' pixel on the screen.

' IN 	: ww - window width
'			: wh - window height
'			: mx1, my1 - mandelbrot upper left coords
'			: mx2, my2 - mandelbrot lower right coords
'			: scheme - coloring method
'			: maxIter - maximum number of iterations to perform on a point
'			: cmap[] - array of color map values

' OUT : data[] - byte array of color values for mandelbrot set
'
FUNCTION  DrawMandelbrotScan (ww, wh, DOUBLE mx1, DOUBLE my1, DOUBLE mx2, DOUBLE my2, UBYTE data[], scheme, maxIter, RGBDATA cmap[])

	DOUBLE mw, mh
	DOUBLE x, y, xstep, ystep
	SHARED DOUBLE epsilon_x, epsilon_y
	SHARED MAX_ITER
	FRACTALPT fpt
	SHARED DOUBLE bailout
	RGBDATA rgb

	IFZ (ww * wh) THEN RETURN

	MAX_ITER = maxIter

	IF scheme = $$COLOR_POTENTIAL THEN
		bailout = 500.0
	ELSE
		bailout = 4.0
	END IF

	lineBytes = (3*ww + 3) AND -4		' pad line to 4-byte boundary
	imageBytes = wh * lineBytes			' total required bytes for image
	DIM data[imageBytes]						' dim data[]
	dataAddr = &data[0]							' address of data[] array

	mw = mx2 - mx1									' mandelbrot x range
	mh = my2 - my1									' mandelbrot y range

	xstep = mw/ww										' x step
	ystep = mh/wh										' y step

	epsilon_x = xstep 							' period detection margin, 1 pixel
	epsilon_y = ystep

	upperW = ww - 1
	upperH = wh - 1

	basin = $$FALSE

	x = mx1
	FOR i = 0 TO upperW
		y = my1
		FOR j = 0 TO upperH

			fpt = IteratePoint (x, y, @basin)

'			IF fpt.iter <> MAX_ITER THEN
'				level = (iter MOD 26) + 1
'				color = (level*10) | (100 << 8) | (200 << 16)
'				SetPixelV (#hMemDC, i, j, color)							' draw point to hDC, slow
'			END IF

			IF fpt.iter <> MAX_ITER THEN										' set RGB data[] values
				rgb = FractColor (fpt, scheme, @cmap[])				' get rgb color values for point (0-255)
				byte = ((upperH-j) * lineBytes) + (i * 3)			' byte in bottom up scan line arrays
				byteAddr = dataAddr + byte										' calc address in memory

'				data[byte]   		= 200													' blue
'				data[byte + 1] 	= 100													' green
'				data[byte + 2] 	= ((iter MOD 26) + 1) * 10		' red

' setting values in memory directly is slightly faster
				UBYTEAT(byteAddr)   	= rgb.b													' blue
				UBYTEAT(byteAddr+1) 	= rgb.g													' green
				UBYTEAT(byteAddr+2) 	= rgb.r													' red
			END IF

			y = y + ystep
		NEXT j
		x = x + xstep
	NEXT i

	RETURN

END FUNCTION
'
'
' ###########################
' #####  FractColor ()  #####
' ###########################
'
FUNCTION  RGBDATA FractColor (FRACTALPT fpt, scheme, RGBDATA cmap[])

	DOUBLE pot, slope, mag, r, g, b, re2, im2, hue
	SHARED DOUBLE bailout
	RGBDATA rgb

	$MaxColors = 255
	$MaxColors1 = 254
	$ReducedColors = 26
	$MAXPOT = 3.1073040492111				' maxpot = log(bailout)/2.0, bailout = 500.0 for $$COLOR_POTENTIAL method

	SELECT CASE scheme

		CASE $$COLOR_ESCAPETIME :
			c = (fpt.iter MOD $MaxColors) + 1
			RETURN cmap[c]

		CASE $$COLOR_IMAGINARY :
			c = ABS((2.0/fpt.im) ** 0.25) * ($MaxColors1) + 1
			RETURN cmap[c]

		CASE $$COLOR_POTENTIAL :
			IF fpt.iter <= 1021 THEN
				slope = 10.0								' use slope in range = 5 - 50, with 10 being pretty good
				c = (1.0 - (((log(fpt.re*fpt.re + fpt.im*fpt.im)/ldexp(1.0, fpt.iter))/$MAXPOT) ** (1.0/slope))) * ($MaxColors1) + 1
				RETURN cmap[c]
  		ELSE
				RETURN cmap[$MaxColors]
			END IF

		CASE $$COLOR_DECOMPOSITION :
			c = (atan2(fpt.re, fpt.im)/($$M_PI) + 0.5) * ($MaxColors1) + 1
			RETURN cmap[c]

		CASE $$COLOR_ZRATIOS :
			max# = MAX(fpt.re, fpt.im)
			min# = MIN(fpt.re, fpt.im)
			IFZ max# THEN
				RETURN cmap[$MaxColors]
			ELSE
				c = ((ABS(min#/max#) * ($MaxColors)) MOD $MaxColors) + 1
				RETURN cmap[c]
			END IF

		CASE $$COLOR_ZMAGNITUDE :
			mag = fpt.re*fpt.re + fpt.im*fpt.im
			c = (mag - INT(mag)) * ($MaxColors1) + 1
			RETURN cmap[c]

		CASE $$COLOR_ATAN :
			c = atan(fabs(atan(fpt.re/fpt.im))) * ($MaxColors1) + 1
			RETURN cmap[c]

		CASE $$COLOR_HLS :
			hue = fmod (360.0 * log(fpt.iter), 360.0)
			HLStoRGB (hue, 0.5, 1.0, @r, @g, @b)
			rgb.r = r : rgb.g = g : rgb.b = b
			RETURN rgb

	END SELECT
END FUNCTION
'
'
' ############################
' #####  GetColorMap ()  #####
' ############################
'
FUNCTION  GetColorMap (fileName$, RGBDATA cmap[])

	REDIM cmap[255]

	IF strchr (&fileName$, '.') == 0 THEN fileName$ = fileName$ + ".map"
	ifile = fopen (&fileName$, &"r")
	IFZ ifile THEN RETURN ($$TRUE)

	delims$ = " "
	r$ = NULL$(4)
	g$ = NULL$(4)
	b$ = NULL$(4)
	str$ = NULL$(101)

	FOR i = 0 TO 255
		IFZ (fgets(&str$, LEN(str$)-1, ifile)) THEN	EXIT FOR
		p = strtok (&str$, &delims$)
		_snprintf (&r$, 4, &"%s", p)
		p = strtok (0, &delims$)
		_snprintf (&g$, 4, &"%s", p)
		p = strtok (0, &delims$)
		_snprintf (&b$, 4, &"%s", p)

		cmap[i].r = XLONG(CSIZE$(r$))
		cmap[i].g = XLONG(CSIZE$(g$))
		cmap[i].b = XLONG(CSIZE$(b$))

	NEXT i

	fclose (ifile)


END FUNCTION
'
'
' ###################################
' #####  ShowOpenFileDialog ()  #####
' ###################################
'
FUNCTION  ShowOpenFileDialog (hWndOwnder, @fileName$, filter$, initDir$, title$)

	OPENFILENAME ofn
	SHARED hInst

	ofn.lStructSize = LEN(ofn)				'set length of struct
	ofn.hwndOwner 	= hWndOwner				'set parent window handle
	ofn.hInstance 	= hInst						'set the application's instance

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
		fileName$ = NULL$(254)
	ELSE
		fileName$ = fileName$ + NULL$(254 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$

	ofn.nMaxFile 				= 255					'set the maximum length of a returned file

	buffer2$ = SPACE$(254)
	ofn.lpstrFileTitle 	= &buffer2$		'Create a buffer for the file title
	ofn.nMaxFileTitle 	= 255					'Set the maximum length of a returned file title
	ofn.lpstrInitialDir = &initDir$		'Set the initial directory
  ofn.lpstrTitle 			= &title$			'Set the title
  ofn.flags = $$OFN_FILEMUSTEXIST OR $$OFN_PATHMUSTEXIST OR $$OFN_EXPLORER	'flags

'call dialog
	IFZ GetOpenFileNameA (&ofn) THEN
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF


END FUNCTION
'
'
' #########################
' #####  HLStoRGB ()  #####
' #########################
'
FUNCTION  HLStoRGB (DOUBLE hue, DOUBLE lightness, DOUBLE saturation, red, green, blue)

	DOUBLE m1, m2

	IFZ saturation THEN
		red 	= lightness * 255
		green = red
		blue 	= red
	ELSE
		IF lightness <= 0.5 THEN
			m2 = lightness + lightness * saturation
		ELSE
			m2 = lightness + saturation - lightness * saturation
		END IF
		m1 = 2 * lightness - m2
		red 	= Value (m1, m2, hue+120)
		green = Value (m1, m2, hue)
		blue 	= Value (m1, m2, hue-120)
	END IF

END FUNCTION
'
'
' ######################
' #####  Value ()  #####
' ######################
'
FUNCTION  Value (DOUBLE m1, DOUBLE m2, DOUBLE h)

	IF h > 360 THEN
		h = h - 360
	ELSE
		IF h < 0 THEN
			h = h + 360
		END IF
	END IF

	IF h < 60 THEN
		m1 = m1 + (m2-m1) * h/60.0
	ELSE
		IF h < 180 THEN
			m1 = m2
		ELSE
			IF h < 240 THEN
				m1 = m1 + (m2-m1) * (240-h)/60.0
			END IF
		END IF
	END IF
	RETURN m1 * 255


END FUNCTION
'
'
' ############################
' #####  ClearScreen ()  #####
' ############################
'
FUNCTION  ClearScreen (hWnd)
	RECT rect

	GetClientRect (hWnd, &rect)
	hDC = GetDC (hWnd)
	hBrush 	= GetStockObject ($$BLACK_BRUSH)
	SelectObject (hDC, hBrush)
	PatBlt (hDC, 0, 0, rect.right, rect.bottom, $$PATCOPY)
	ReleaseDC (hWnd, hDC)
	InvalidateRect (hWnd, 0, 1)
END FUNCTION
'
'
' ###########################
' #####  CanvasProc ()  #####
' ###########################
'
FUNCTION  CanvasProc (hWnd, msg, wParam, lParam)

	SHARED hInst

	PAINTSTRUCT ps
	STATIC SCROLLINFO si

	RECT rect
	RECT prect
	POINT pt

	STATIC DOUBLE mx1, mx2, my1, my2
	STATIC mInitFlag, zLevel
	SHARED UBYTE mdata[]							' fractal color data array
	SHARED BITMAPINFO bmpInfo
	SHARED bits, hDIB
	SHARED DIBSECTION dibs

	SHARED RGBDATA cMap[]							' currently loaded map RGB data
	SHARED mColoring									' current map type
	SHARED mIter											' max number of iterations
	SHARED mSize                      ' size in pixels of drawing
	SHARED mMethod										' method used to calc fractral

	STATIC fLastZoom									' flag, if a zoom rect has been drawn
	STATIC RECT zoom, lastZoom				' coordinates of zoom rect
	LOGBRUSH logbrush									' logical brush for filling zoom rect
	STATIC fLMouseDown								' left mouse button is down
	STATIC lastWidth, lastHeight			' last resized window dimensions
	STATIC ZOOMDATA zdata[]						' keep track of all zoom levels
	STATIC fCursor										' flag to track cursor style

	SHARED fBlt             					' TRUE if DIB has been created
	SHARED fScroll          					' TRUE if scrolling occurred
	SHARED fSize            					' TRUE if fBlt & WM_SIZE

' These variables are required for horizontal scrolling.

	STATIC xMinScroll       					' minimum horizontal scroll value
	STATIC xCurrentScroll   					' current horizontal scroll value
	STATIC xMaxScroll       					' maximum horizontal scroll value
	STATIC xNewSize         					' current size of client window

' These variables are required for vertical scrolling.

	STATIC yMinScroll       					' minimum vertical scroll value
	STATIC yCurrentScroll   					' current vertical scroll value
	STATIC yMaxScroll       					' maximum vertical scroll value
	STATIC yNewSize         					' current size of client window

	SELECT CASE msg

		CASE $$WM_CREATE :
			mColoring = $$COLOR_ESCAPETIME		' init coloring algorithm
			mIter = 1000											' init max iterations
			mSize = 300												' init dimension of drawing

			fileName$ = "volcano.map"					' load init color map
			GetColorMap (fileName$, @cMap[])
			SendMessageA (#statusBar, $$SB_SETTEXT, 1, &fileName$)
			RETURN

		CASE $$WM_PAINT :
'			GetClientRect (hWnd, &rect)
			hDC = BeginPaint (hWnd, &ps)

' if window has been resized then copy image to screen
			IF (fSize) THEN
				ret = SetDIBitsToDevice (hDC, 0, 0, mSize, mSize, 0, 0, 0, mSize, bits, &bmpInfo, $$DIB_RGB_COLORS)
				IFZ ret THEN
					PRINT "SetDIBitsToDevice Error"
					GOSUB GetErrorMessage
				END IF
				fSize = $$FALSE
			END IF

			IF (fScroll) THEN
'				prect = ps.rcPaint
				w = ps.right - ps.left
				h = ps.bottom - ps.top
				ret = SetDIBitsToDevice (hDC, ps.left, ps.top, w, h, ps.left + xCurrentScroll, mSize - (ps.top + h + yCurrentScroll), 0, mSize, bits, &bmpInfo, $$DIB_RGB_COLORS)
				IFZ ret THEN GOSUB GetErrorMessage
				fScroll = $$FALSE
			END IF

			EndPaint (hWnd, &ps)
			RETURN 0

		CASE $$WM_LBUTTONDOWN :										' begin a zoom rect box or erase last zoom rect
			IFZ mInitFlag THEN RETURN
			x = LOWORD (lParam)
			y = HIWORD (lParam)
			IF fLastZoom THEN
				IFZ PtInRect (&lastZoom, x, y) THEN		' left mouse down outside of last zoom rect
					ROPMode = $$R2_XORPEN
					rect = lastZoom
					GOSUB DrawZoomRect									' erase previously drawn zoom rect
					lastZoom.left = 0
					lastZoom.top = 0
					lastZoom.right = 0
					lastZoom.bottom = 0
				ELSE
					RETURN															' left mouse click inside of last zoom rect
				END IF
			END IF
			fLMouseDown = $$TRUE
			zoom.left = x
			zoom.top = y
			fLastZoom = $$FALSE
			RETURN 0

		CASE $$WM_MOUSEMOVE :											' begin a zoom rect drag
			fButton = wParam
			IFZ (fButton & $$MK_LBUTTON) THEN RETURN
			IFZ fLMouseDown THEN RETURN
			zoom.right  = LOWORD (lParam)
			zoom.bottom = zoom.top + ABS(zoom.right - zoom.left)			' make selection square
			ROPMode = $$R2_XORPEN
			IF fLastZoom THEN
				rect = lastZoom
				GOSUB DrawZoomRect
			END IF
			rect = zoom
			GOSUB DrawZoomRect
			lastZoom = zoom
			fLastZoom = $$TRUE
			RETURN

		CASE $$WM_LBUTTONUP :											' end of drag
			fLMouseDown = $$FALSE
			RETURN

		CASE $$WM_LBUTTONDBLCLK :									' select current zoom and draw it
			x = LOWORD (lParam)
			y = HIWORD (lParam)
			IF PtInRect (&lastZoom, x, y) THEN
				fLastZoom = $$FALSE
				GOSUB MandelbrotZoomIn
				GOSUB DrawMandelbrot
			END IF
			RETURN

		CASE $$WM_RBUTTONDOWN :										' back up and draw previous rect
			IFZ mInitFlag THEN GOSUB InitMandelbrot
			GOSUB MandelbrotZoomOut
			GOSUB DrawMandelbrot
			RETURN 0


		CASE $$WM_SIZE :
			SELECT CASE wParam
				CASE $$SIZE_MAXIMIZED, $$SIZE_RESTORED :
					xNewSize = LOWORD(lParam)
					yNewSize = HIWORD(lParam)

					lastWidth = xNewSize										' save last window size
					lastHeight = yNewSize

					IF (fBlt) THEN fSize = $$TRUE

					xMaxScroll = mSize-1
					xMinScroll = 0
					xCurrentScroll = 0  										' reset xCurrentScroll to 0 after resize event
					si.cbSize = SIZE(si)
					si.fMask  = $$SIF_RANGE | $$SIF_PAGE | $$SIF_POS
					si.nMin   = xMinScroll
					si.nMax   = xMaxScroll
					si.nPage  = xNewSize
					si.nPos   = xCurrentScroll
					SetScrollInfo (hWnd, $$SB_HORZ, &si, $$TRUE)

					yMaxScroll = mSize-1
					yMinScroll = 0
					yCurrentScroll = 0											' reset yCurrentScroll to 0 after resize event
					si.cbSize = SIZE(si)
					si.fMask  = $$SIF_RANGE | $$SIF_PAGE | $$SIF_POS
					si.nMin   = yMinScroll
					si.nMax   = yMaxScroll
					si.nPage  = yNewSize
					si.nPos   = yCurrentScroll
					SetScrollInfo (hWnd, $$SB_VERT, &si, $$TRUE)
				END SELECT
				RETURN

		CASE $$WM_HSCROLL :
			yDelta = 0
			SELECT CASE (LOWORD(wParam))				' scroll bar notify value
				CASE $$SB_PAGEUP:									' User clicked left of the scroll bar.
					xNewPos = xCurrentScroll - 50

				CASE $$SB_PAGEDOWN:								' User clicked right of the scroll bar.
					xNewPos = xCurrentScroll + 50

				CASE $$SB_LINEUP:									' User clicked the left arrow.
					xNewPos = xCurrentScroll - 5

				CASE $$SB_LINEDOWN:								' User clicked the right arrow.
					xNewPos = xCurrentScroll + 5

				CASE $$SB_THUMBPOSITION:					' User dragged the scroll box.
					xNewPos = HIWORD(wParam)

				CASE ELSE:
					xNewPos = xCurrentScroll
 			END SELECT

			xNewPos = MAX(0, xNewPos)						' Max new position must be between 0 and the client screen width.
			xNewPos = MIN(xMaxScroll-xNewSize+1, xNewPos)

			IF (xNewPos == xCurrentScroll) THEN RETURN		' If the current position does not change, do not scroll.
			fScroll = $$TRUE										' Set the scroll flag to TRUE.
			xDelta = xNewPos - xCurrentScroll		' Determine the amount scrolled (in pixels).
			xCurrentScroll = xNewPos						' Reset the current scroll position.

' Scroll the window. (The system repaints most of the
' client area when ScrollWindowEx is called; however, it is
' necessary to call UpdateWindow in order to repaint the
' rectangle of pixels that were invalidated.)

			ScrollWindowEx (hWnd, -xDelta, -yDelta, 0, 0, 0, 0, $$SW_INVALIDATE)
			UpdateWindow (hWnd)

			si.cbSize = SIZE(si)					' Reset the scroll bar.
			si.fMask  = $$SIF_POS
			si.nPos   = xCurrentScroll
			SetScrollInfo (hWnd, $$SB_HORZ, &si, $$TRUE)
			RETURN

		CASE $$WM_VSCROLL :
			xDelta = 0
			SELECT CASE (LOWORD(wParam))				' scroll bar notify value
				CASE $$SB_PAGEUP:									' User clicked above the scroll bar.
					yNewPos = yCurrentScroll - 50

				CASE $$SB_PAGEDOWN:								' User clicked below the scroll bar.
					yNewPos = yCurrentScroll + 50

				CASE $$SB_LINEUP:									' User clicked the top arrow.
					yNewPos = yCurrentScroll - 5

				CASE $$SB_LINEDOWN:								' User clicked the bottom arrow.
					yNewPos = yCurrentScroll + 5

				CASE $$SB_THUMBPOSITION:					' User dragged the scroll box.
					yNewPos = HIWORD(wParam)

				CASE ELSE:
					yNewPos = yCurrentScroll
 			END SELECT

			yNewPos = MAX(0, yNewPos)
			yNewPos = MIN(yMaxScroll-yNewSize+1, yNewPos)

			IF (yNewPos == yCurrentScroll) THEN RETURN		' If the current position does not change, do not scroll.
			fScroll = $$TRUE										' Set the scroll flag to TRUE.
			yDelta = yNewPos - yCurrentScroll		' Determine the amount scrolled (in pixels).
			yCurrentScroll = yNewPos						' Reset the current scroll position.

' Scroll the window. (The system repaints most of the
' client area when ScrollWindowEx is called; however, it is
' necessary to call UpdateWindow in order to repaint the
' rectangle of pixels that were invalidated.)

			ScrollWindowEx (hWnd, -xDelta, -yDelta, 0, 0, 0, 0, $$SW_INVALIDATE)
			UpdateWindow (hWnd)

			si.cbSize = SIZE(si)						' Reset the scroll bar.
			si.fMask  = $$SIF_POS
			si.nPos   = yCurrentScroll
			SetScrollInfo (hWnd, $$SB_VERT, &si, $$TRUE)
			RETURN

		CASE $$WM_ERASEBKGND :						' window has been covered and needs to be redrawn
			GetClientRect (hWnd, &rect)
			IF rect.right > lastWidth || rect.bottom > lastHeight THEN clear = $$TRUE
			IF rect.bottom = lastHeight && rect.right = lastWidth THEN clear = $$TRUE

			IF clear THEN																	' clear window to black
				hBrush 	= GetStockObject ($$BLACK_BRUSH)
				hDC = GetDC (hWnd)
				SelectObject (hDC, hBrush)
				PatBlt (hDC, 0, 0, rect.right, rect.bottom, $$PATCOPY)
				ReleaseDC (hWnd, hDC)
			END IF

			IF (xCurrentScroll == 0) AND (yCurrentScroll == 0) THEN
				fSize = $$TRUE									' set resize flag to TRUE so entire window can be repainted
			ELSE
				fScroll = $$TRUE								' set scroll flag to TRUE so only covered portion gets repainted
			END IF
			RETURN $$TRUE											' no more erasing of background is necessary

		CASE $$WM_INITMANDELBROT :
			GOSUB InitMandelbrot
			RETURN

		CASE $$WM_DRAWMANDELBROT :
			GOSUB DrawMandelbrot
			RETURN

		CASE $$WM_SETCURSOR :
			hittest = LOWORD (lParam)						' hit-test code
			IF hittest = $$HTCLIENT THEN
				IFZ fCursor THEN
					SetCursor (LoadCursorA (0, $$IDC_CROSS))
				ELSE
					SetCursor (LoadCursorA (0, $$IDC_WAIT))
				END IF
				RETURN $$TRUE
			ELSE
				SetCursor (LoadCursorA (0, $$IDC_ARROW))
				RETURN $$TRUE
			END IF
			RETURN

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)


' ***** DrawMandelbrot *****
SUB DrawMandelbrot
	GetClientRect (hWnd, &rect)
	fCursor = $$TRUE
	SetCursor (LoadCursorA (0, $$IDC_WAIT))

'	start = GetTickCount () 		' used to time mandelbrot calculation time

	SELECT CASE mMethod
		CASE $$METHOD_SCAN :
			DrawMandelbrotScan (mSize, mSize, mx1, my1, mx2, my2, @mdata[], mColoring, mIter, @cMap[])
		CASE $$METHOD_INTERLEAVE :
			DrawMandelbrotInterleave (mSize, mSize, mx1, my1, mx2, my2, @mdata[], mColoring, mIter, @cMap[])
	END SELECT

'	PRINT "DrawMandelbrot time:"; GetTickCount () - start

' copy RGB data to DIB bits address
	RtlMoveMemory (bits, &mdata[0], SIZE(mdata[]))

' reset scrollbar settings
	size = rect.right | (rect.bottom << 16)
	SendMessageA (hWnd, $$WM_SIZE, $$SIZE_RESTORED, size)

	ClearScreen (hWnd)

	SetCursor (LoadCursorA (0, $$IDC_CROSS))
	fCursor = $$FALSE

END SUB

' ***** MandelbrotZoomIn *****
SUB MandelbrotZoomIn
	mxDelta# = mx2 - mx1
	myDelta# = my2 - my1

	zDeltaX = ABS(lastZoom.right - lastZoom.left)
	zDeltaY = ABS(lastZoom.bottom - lastZoom.top)
	size# = DOUBLE(mSize)

	mx1 = mx1 + (lastZoom.left + xCurrentScroll) * mxDelta# / size#
	my1 = my1 + (lastZoom.top  + yCurrentScroll) * myDelta# / size#
	mx2 = mx1 + zDeltaX / size# * mxDelta#
	my2 = my1 + zDeltaY / size# * myDelta#

	INC zLevel
	zdata[zLevel].x1 = mx1
	zdata[zLevel].y1 = my1
	zdata[zLevel].x2 = mx2
	zdata[zLevel].y2 = my2
END SUB

' ***** MandelbrotZoomOut *****
SUB MandelbrotZoomOut
	DEC zLevel
	IF zLevel < 0 THEN zLevel = 0
	mx1 = zdata[zLevel].x1
	my1 = zdata[zLevel].y1
	mx2 = zdata[zLevel].x2
	my2 = zdata[zLevel].y2

END SUB

' ***** InitMandelbrot *****
SUB InitMandelbrot
	mInitFlag = $$TRUE

	mx1 = -2.0						' initialize std Mandelbrot coords
	mx2 = 1.0
	my1 = -1.5
	my2 = 1.5

	DIM zdata[50]					' 50 levels of zooms should be enough...
	zLevel = 0						' initialize zoom level
	zdata[0].x1 = mx1
	zdata[0].y1 = my1
	zdata[0].x2 = mx2
	zdata[0].y2 = my2

END SUB

' ***** DrawZoomRect *****
SUB DrawZoomRect
' draw zoom selection box
	hPen = CreatePen ($$PS_SOLID, 1, RGB(255, 0, 0))	' create a red pen
	logbrush.style = $$BS_HOLLOW
	hBrush = CreateBrushIndirect (&logbrush)					' create a hollow brush
	hDC = GetDC (hWnd)
	lastPen = SelectObject (hDC, hPen)
	lastBrush = SelectObject (hDC, hBrush)
	lastMode = SetROP2 (hDC, ROPMode)
	Rectangle (hDC, rect.left, rect.top, rect.right, rect.bottom)
	SelectObject (hDC, lastPen)
	SelectObject (hDC, lastBrush)
	DeleteObject (hBrush)
	DeleteObject (hPen)
	SetROP2 (hDC, lastMode)
	ReleaseDC (hWnd, hDC)
END SUB

' ***** GetErrorMessage *****
SUB GetErrorMessage
	IFZ ret THEN
		error$ = NULL$(255)
		FormatMessageA ($$FORMAT_MESSAGE_FROM_SYSTEM, 0, GetLastError(), 0, &error$, LEN(error$), 0)
		PRINT "Error : "; CSIZE$(error$)
	END IF
END SUB

END FUNCTION
'
'
' ########################
' #####  SaveDIB ()  #####
' ########################
'
FUNCTION  SaveDIB (file$, UBYTE mdata[], mSize)

	UBYTE image[]

	$BI_RGB       = 0					' 24-bit RGB

	DIM image[]

	IFZ mdata[] THEN RETURN ($$TRUE)

	IFZ file$ THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidName
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF

	width       = mSize
	height      = mSize

	dataOffset = 54

' alignment on multiple of 32 bits or 4 bytes

	size = dataOffset + (height * ((width * 3) + 3 AND -4))
	upper = size - 1
	DIM image[upper]

'	Fill BITMAPFILEHEADER
'		Windows version:  little ENDIAN; no alignment concerns

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

' copy bits from mdata[] to image[]
	RtlMoveMemory (dataAddr, &mdata[0], SIZE(mdata[]))

	ofile = OPEN (file$, $$WRNEW)

	IF (ofile < 3) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF

	bytesWritten = 0
	error = XxxWriteFile (ofile, &image[], SIZE(image[]), &bytesWritten, 0)

	CLOSE (ofile)
	DIM image[]

	IF error THEN RETURN ($$TRUE)


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
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF

END FUNCTION
END PROGRAM
