'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates the use of Xil, the
' XBlite imaging library. The library contains
' functions for manipulating images.
'
' (c) 2002 GPL David SZAFRANSKI
' dszafranski@wanadoo.fr
'
PROGRAM	"viewer"
VERSION	"0.0003"
'
	IMPORT	"xst"   		' standard library 	: required by most programs
'	IMPORT	"xio"				' console io library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT	"kernel32"	' kernel32.dll
	IMPORT  "canvas"		' canvas.dll 				: canvas control
	IMPORT	"xbm"				' xbm.dll 					: bitmap library
	IMPORT	"xil"				' xil.dll						: imaging library
	IMPORT  "comctl32.dec"
  IMPORT  "comdlg32"	' comdlg32.dll			: common dialog library
	IMPORT  "msvcrt"
'	IMPORT  "xil_s.lib" ' import static version of library
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION  InitGui ()
DECLARE FUNCTION  RegisterWinClass (className$, addrWndProc, icon$, menu$)
DECLARE FUNCTION  CreateWindows ()
DECLARE FUNCTION  NewWindow (className$, title$, style, x, y, w, h, exStyle)
DECLARE FUNCTION  MessageLoop ()
DECLARE FUNCTION  CleanUp ()
DECLARE FUNCTION  NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION  ShowOpenFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)
DECLARE FUNCTION  ShowSaveFileDialog (hWndOwner, @fileName$, filter$, initDir$, title$)
DECLARE FUNCTION  GetFileExtension (fileName$, @file$, @ext$)
'
' Control IDs
'
$$CC_CANVAS1 = 100
'
' Menu IDs
'
$$CM_FILE_OPEN = 101
$$CM_FILE_CLOSE = 102
$$CM_FILE_SAVE = 103
$$CM_FILE_SAVEAS = 104
$$CM_FILE_LOADORIGINAL = 105
$$CM_FILE_EXIT = 106

$$CM_ACTION_ROTATE45 = 120
$$CM_ACTION_ROTATE90 = 121
$$CM_ACTION_ROTATE180 = 122
$$CM_ACTION_ROTATE270 = 123
$$CM_ACTION_MIRROR = 124
$$CM_ACTION_FLIP = 125
$$CM_ACTION_CROP = 126
$$CM_ACTION_RESIZE = 127
$$CM_ACTION_RESIZEBICUBIC = 133
$$CM_ACTION_RESIZEQUAD = 131
$$CM_ACTION_RESIZEPROPORTIONAL = 128
$$CM_ACTION_RESIZECANVAS = 129
$$CM_ACTION_THUMBNAIL = 132
$$CM_ACTION_TILE = 130
'
$$CM_FILTER_INVERT = 140
$$CM_FILTER_MASK = 141
$$CM_FILTER_ICON = 142
$$CM_FILTER_LIGHTEN = 143
$$CM_FILTER_FADE = 144
$$CM_FILTER_NOISE = 145
$$CM_FILTER_BLUR = 146
$$CM_FILTER_BLURMORE = 147
$$CM_FILTER_SOFTEN = 148
$$CM_FILTER_SOFTENMORE = 149
$$CM_FILTER_SMOOTHKUWAHARA = 182
$$CM_FILTER_SHARPEN = 150
$$CM_FILTER_SHARPENMORE = 151
$$CM_FILTER_EMBOSS = 152
$$CM_FILTER_QUICKEMBOSS = 153
$$CM_FILTER_GAUSSIANBLUR = 154
$$CM_FILTER_GAMMA = 155
$$CM_FILTER_CONTRAST = 156
$$CM_FILTER_NORMALIZE = 157
$$CM_FILTER_HISTOGRAM = 158
$$CM_FILTER_ERODE = 159
$$CM_FILTER_DILATE = 160
$$CM_FILTER_DETECTEDGESOBEL = 161
$$CM_FILTER_DETECTEDGELAPLACE = 162
$$CM_FILTER_DETECTEDGECANNY = 163
$$CM_FILTER_DETECTEDGELAPLACE3X3 = 164
$$CM_FILTER_DETECTEDGEZEROCROSSING = 165

'
$$CM_COLOR_GRAYSCALE1 = 170
$$CM_COLOR_GRAYSCALE2 = 171
$$CM_COLOR_GRAYSCALE3 = 172
$$CM_COLOR_COLORIZE = 173

$$CM_COLOR_DITHERFS = 174
$$CM_COLOR_DITHER8X8 = 175
$$CM_COLOR_DITHERBAYER8X8 = 179
$$CM_COLOR_DITHERULICHNEY = 180
$$CM_COLOR_DITHEREFFICIENT = 181

$$CM_COLOR_HALFTONEFAST = 176
$$CM_COLOR_HALFTONEBEST = 177
$$CM_COLOR_WEBSAFE = 178
'
$$CM_HELP_ABOUT = 200
'
'
'
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

'	XioCreateConsole (title$, 15550)	' create console, if console is not wanted, comment out this line
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
'
	SHARED hInst
	RECT rect
	STATIC UBYTE image[], destImage[]
	STATIC selectedFile$, currentPath$, hImage, bpp, hCanvas1
	STATIC imageWidth, imageHeight
	DOUBLE degrees
'
	SELECT CASE msg

		CASE $$WM_CREATE :
			GetClientRect (hWnd, &rect)
			hCanvas1 = NewChild ($$CANVASCLASSNAME, "", style, 0, 0, rect.right, rect.bottom, hWnd, $$CC_CANVAS1, 0)

		CASE $$WM_DESTROY :
			XbmDeleteMemBitmap (hImage)
			PostQuitMessage(0)

		CASE $$WM_SIZE :
			width = LOWORD(lParam)
			height = HIWORD (lParam)
			SetWindowPos (hCanvas1, 0, 0, 0, width, height, $$SWP_NOZORDER)

		CASE $$WM_COMMAND :
			id         = LOWORD(wParam)
			hwndCtl    = lParam
			notifyCode = HIWORD(wParam)

			SELECT CASE id
				CASE $$CM_FILE_OPEN 				:	filter$ = "Bitmap Files (*.bmp)" + CHR$(0) + "*.bmp" + CHR$(0) + "Gif Files (*.gif)" + CHR$(0) + "*.gif" + CHR$(0) + CHR$(0)
																			IFZ currentPath$ THEN currentPath$ = "c:\\xblite\\images\\"
																			IF ShowOpenFileDialog (hWnd, @file$, filter$, currentPath$, "Open a Bitmap File") THEN
																				IF file$ THEN
																					currentPath$ = LEFT$ (file$, RINSTR (file$, "\\"))
																					selectedFile$ = RIGHT$ (file$, LEN(file$) - RINSTR (file$, "\\"))
																				GOSUB LoadBmp
																				END IF
																			END IF

				CASE $$CM_FILE_CLOSE 				:	DIM image[]
																			XbmDeleteMemBitmap (hImage)
																			hImage = 0
																			SendMessageA (hCanvas1, $$WM_CLEAR_CANVAS_IMAGE, 0, 0)
																			selectedFile$ = ""
																			currentPath$ = ""

				CASE $$CM_FILE_SAVE 				: filter$ = "Bitmap Files (*.bmp)" + CHR$(0) + "*.bmp" + CHR$(0) + CHR$(0)
																			file$ = selectedFile$
																			IF ShowSaveFileDialog (hWnd, @file$, filter$, currentPath$, "Save a Bitmap File As") THEN
																				IF image[] THEN XbmSaveImage (file$, @image[])
																			END IF

				CASE $$CM_FILE_SAVEAS 			: filter$ = "Bitmap Files (*.bmp)" + CHR$(0) + "*.bmp" + CHR$(0) + CHR$(0)
																			file$ = ""
																			IF ShowSaveFileDialog (hWnd, @file$, filter$, currentPath$, "Save a Bitmap File As") THEN
																				IF image[] THEN XbmSaveImage (file$, @image[])
																			END IF

				CASE $$CM_FILE_LOADORIGINAL :	GOSUB LoadBmp
				CASE $$CM_FILE_EXIT 				:	DestroyWindow (hWnd)

				CASE $$CM_ACTION_ROTATE45 		:	XilRotate (@image[], @destImage[], -45, @imageWidth, @imageHeight)
				CASE $$CM_ACTION_ROTATE90 		:	XilRotate (@image[], @destImage[], -90, @imageWidth, @imageHeight)
				CASE $$CM_ACTION_ROTATE180 		:	XilRotate (@image[], @destImage[], 180, @imageWidth, @imageHeight)
				CASE $$CM_ACTION_ROTATE270 		:	XilRotate (@image[], @destImage[],  90, @imageWidth, @imageHeight)
				CASE $$CM_ACTION_MIRROR 			: XilMirror (@image[], @destImage[])
				CASE $$CM_ACTION_FLIP 				: XilFlip (@image[], @destImage[])
				CASE $$CM_ACTION_CROP 				: XilCrop (@image[], @destImage[], imageWidth/4, imageHeight/4, imageWidth-imageWidth/4, imageHeight-imageHeight/4)
				CASE $$CM_ACTION_RESIZE 			:	XilResize (@image[], @destImage[], imageWidth*2.0, imageHeight*2.0)
				CASE $$CM_ACTION_RESIZEBICUBIC:	XilResizeBiCubic (@image[], @destImage[], 2.0)
				CASE $$CM_ACTION_RESIZEQUAD		: XilResizeBiQuad (@image[], @destImage[], imageWidth*2.0, imageHeight*2.0)
				CASE $$CM_ACTION_RESIZEPROPORTIONAL	:	XilResizeProportional (@image[], @destImage[], 200) ' resize percent based on width
				CASE $$CM_ACTION_RESIZECANVAS	: color = RGB (255, 255, 255)
																				XilResizeCanvas (@image[], @destImage[], imageWidth+24, imageHeight+24, $$AlignMiddleCenter, color)
				CASE $$CM_ACTION_THUMBNAIL		: XilThumbnail (@image[], @destImage[], 0.33)
				CASE $$CM_ACTION_TILE 				: XilTile (@image[], @destImage[], 640, 480)

				CASE $$CM_FILTER_INVERT 			: XilXOR (@image[], @destImage[])
				CASE $$CM_FILTER_MASK 				: XilMask (@image[], @destImage[])
				CASE $$CM_FILTER_ICON 				: color = GetSysColor ($$COLOR_BTNFACE)
																				XilAsIcon (@image[], @destImage[], color)
				CASE $$CM_FILTER_LIGHTEN 			: XilLighten (@image[], @destImage[], 20) ' lighten image by percent (range 0 - 100)
				CASE $$CM_FILTER_FADE 				:	XilFade (@image[], @destImage[], 204)		' fade range 0-255, 0 = all black, 255 = no darken
				CASE $$CM_FILTER_NOISE 				:	XilNoise (@image[], @destImage[], 50)		' add noise in percent (range 0-100)
				CASE $$CM_FILTER_BLUR 				: XilBlur (@image[], @destImage[])
				CASE $$CM_FILTER_BLURMORE 		: XilBlurMore (@image[], @destImage[])
				CASE $$CM_FILTER_SOFTEN 			: XilSoften (@image[], @destImage[])
				CASE $$CM_FILTER_SOFTENMORE 	: XilSoftenMore (@image[], @destImage[])
				CASE $$CM_FILTER_SMOOTHKUWAHARA : XilSmoothKuwahara (@image[], @destImage[], 1)
				CASE $$CM_FILTER_GAUSSIANBLUR	: XilGaussianBlur (@image[], @destImage[], 1.0, 0)
				CASE $$CM_FILTER_SHARPEN 			: XilSharpen (@image[], @destImage[])
				CASE $$CM_FILTER_SHARPENMORE 	: XilSharpenMore (@image[], @destImage[])
				CASE $$CM_FILTER_EMBOSS 			: XilEmboss (@image[], @destImage[], $$AlignLowerLeft)
				CASE $$CM_FILTER_QUICKEMBOSS 	: XilEmbossQuick (@image[], @destImage[])
				CASE $$CM_FILTER_DETECTEDGESOBEL 	  : XilDetectEdgeSobel (@image[], @destImage[])			
				CASE $$CM_FILTER_DETECTEDGELAPLACE 	: XilDetectEdgeLaplace (@image[], @destImage[])			
				CASE $$CM_FILTER_DETECTEDGECANNY 		: XilDetectEdgeCanny (@image[], @destImage[], 1.4, 25)	
				CASE $$CM_FILTER_DETECTEDGEZEROCROSSING	: XilDetectEdgeZeroCrossing (@image[], @destImage[], 1.4, 0, 0)	
				CASE $$CM_FILTER_GAMMA 				: XilGamma (@image[], @destImage[], 2)					' gamma > 0
				CASE $$CM_FILTER_CONTRAST 		: XilContrast (@image[], @destImage[], 1, 50)		' (mode 0 = decrease, 1 = increase), (range 0-255)
				CASE $$CM_FILTER_NORMALIZE 		: XilNormalize (@image[], @destImage[])
				CASE $$CM_FILTER_HISTOGRAM 		: XilHistogramEqualize (@image[], @destImage[], 1.0)
				CASE $$CM_FILTER_ERODE				: XilErode (@image[], @destImage[], 1)
				CASE $$CM_FILTER_DILATE				: XilDilate (@image[], @destImage[], 3)
					
				CASE $$CM_COLOR_GRAYSCALE1 		: XilGrayScale1 (@image[], @destImage[])
				CASE $$CM_COLOR_GRAYSCALE2 		: XilGrayScale2 (@image[], @destImage[])
				CASE $$CM_COLOR_GRAYSCALE3 		: XilGrayScale3 (@image[], @destImage[])
				CASE $$CM_COLOR_COLORIZE 			: XilColorize (@image[], @destImage[], 30)
					
				CASE $$CM_COLOR_DITHERFS 		    :	XilDitherFS (@image[], @destImage[])
				CASE $$CM_COLOR_DITHER8X8 	    :	XilDither8x8 (@image[], @destImage[])
				CASE $$CM_COLOR_DITHERBAYER8X8 	:	XilDitherBayer8x8 (@image[], @destImage[])	
				CASE $$CM_COLOR_DITHERULICHNEY 	:	XilDitherUlichney (@image[], @destImage[])		
				CASE $$CM_COLOR_DITHEREFFICIENT	:	XilDitherEfficientED (@image[], @destImage[])									
										
				CASE $$CM_COLOR_HALFTONEFAST 	: XilHalfTonePaletteFast (@image[], @destImage[], $$TRUE)	' set dither to $$TRUE or $$FALSE
				CASE $$CM_COLOR_HALFTONEBEST 	: XilHalfTonePaletteBest (@image[], @destImage[], $$TRUE)	' set dither to $$TRUE or $$FALSE
				CASE $$CM_COLOR_WEBSAFE 			: XilWebSafePalette (@image[], @destImage[], $$TRUE)	' set dither to $$TRUE or $$FALSE

				CASE $$CM_HELP_ABOUT :	MessageBoxA (hWnd, &"Xil Library for XBLite\nCreated by David SZAFRANSKI\n(c) GPL 2002", &"About Xil Library", $$MB_OK | $$MB_ICONINFORMATION)

			END SELECT
			IF (id >= $$CM_ACTION_ROTATE45) AND (id < $$CM_HELP_ABOUT) THEN
				GOSUB SwapImages			' display new image
			END IF

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT


'***** LoadBmp *****
SUB LoadBmp
' load bmp or gif file
	DIM image[]
	IFZ selectedFile$ THEN EXIT SUB
	GetFileExtension (selectedFile$, "", @ext$)
	IFZ ext$ THEN EXIT SUB
	SELECT CASE UCASE$(ext$)
		CASE "BMP" :
			IFZ XbmLoadImage (selectedFile$, @image[]) THEN EXIT SUB				'	load bitmap into image array
		CASE "GIF" : PRINT "Loading Gif file"
			ret = XbmLoadGif (selectedFile$, @image[]) 
			IFZ ret THEN 
			 PRINT "XbmLoadGif error"
			 EXIT SUB					'	load bitmap into image array
			END IF
		CASE ELSE : EXIT SUB
	END SELECT
	GOSUB DisplayImage
'
END SUB
'
' ***** SUB DisplayImage *****
SUB DisplayImage
'
' display image in hCanvas1
	IF hImage THEN XbmDeleteMemBitmap (hImage)										' delete last memory bitmap
	XbmGetImageArrayInfo (@image[], @bpp, @imageWidth, @imageHeight)
	IF bpp < 8 THEN MessageBoxA (hWnd, &"Currently loaded image bitsperpixel is < 8.\nTransformations and filters not available.\nPlease load an 8-bit or 24-bit image.", &"Warning", $$MB_OK | $$MB_ICONEXCLAMATION)
	IFZ imageWidth * imageHeight THEN EXIT SUB
	IF bpp = 8 THEN XbmDIBto24Bit (@image[])											' convert to 24bpp (1-bit and 4-bit conversions not currently working in XbmDIBto24Bit)
	XbmCreateMemBitmap (hWnd, imageWidth, imageHeight, @hImage)		' create memory bitmap
	XbmSetImage (hImage, @image[])																' set image array into memory bitmap
	SendMessageA (hCanvas1, $$WM_SET_CANVAS_IMAGE, 0, hImage)			' display memory bitmap in canvas control
'
'	GOSUB SetStatusBarText
END SUB
'
' ***** SwapImages *****
SUB SwapImages
'
	upper = UBOUND (destImage[])
	IF upper = -1 THEN EXIT SUB
	DIM image[upper]							' make sure arrays are the same size
	SWAP destImage[], image[]			' swap arrays
	DIM destImage[]								'	dim destImage[]
	GOSUB DisplayImage						' display new image
'
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

	SHARED className$, hInst

' register window class
	className$  = "ImageLibraryDemo"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menu"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "XBLite Image Viewer."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 500
	h 					= 350
	#winMain = NewWindow (className$, title$, style, x, y, w, h, 0)
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
  ofn.flags = $$OFN_FILEMUSTEXIST OR $$OFN_PATHMUSTEXIST OR $$OFN_EXPLORER	'flags

'call dialog
	IFZ GetOpenFileNameA (&ofn) THEN
		fileName$ = ""
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN $$TRUE
	END IF

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
' ##############################
' #####  GetFileExtension  #####
' ##############################
'
' Get filename extension ext$ (without .) and
' the file name file$ without extension.
'
FUNCTION GetFileExtension (fileName$, @file$, @ext$)

	ext$ = ""
	file$ = ""
	IFZ fileName$ THEN RETURN ($$TRUE)

	f$ = fileName$
	f$ = TRIM$ (f$)
	fPos = RINSTR (f$, ".")

	IF fPos THEN
		ext$ = RIGHT$ (f$, LEN (f$) - fPos)
		file$ = LEFT$ (f$, fPos - 1)
		RETURN
	END IF

	RETURN ($$TRUE)
END FUNCTION

END PROGRAM
