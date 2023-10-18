'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Loadimage.x is a demo that shows how
' to load graphics files like
' GIF, JPG, BMP and displays them.
' The function OleLoadPicture() is used
' to convert these different image formats
' to an IPicture* interface. One can then
' use IPicture_Render() to display the
' image, or in this case, use
' IPicture_GetHandle() to return a handle
' to a bitmap object.
' For more info on using the IPicture*
' interface, see the MS KB file Q218972
' "How To Load and Display Graphics Files"
' and loadpic.exe:
' http://support.microsoft.com/support/kb/articles/Q218/9/72.asp
'
PROGRAM	"loadimage"
VERSION	"0.0002"
'
	IMPORT	"xst"   		' Standard library 	: required by most programs
'	IMPORT	"xio"				' Console IO library
	IMPORT	"gdi32"     ' gdi32.dll
	IMPORT  "user32"    ' user32.dll
	IMPORT	"kernel32"	' kernel32.dll
	IMPORT	"ole32"
	IMPORT  "canvas"		' canvas.dll 				: Canvas control
	IMPORT  "comctl32"
  IMPORT  "comdlg32"  ' common dialog library
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
DECLARE FUNCTION  LoadOleImage (fileName$, @hBitmap, @w, @h, @gpPicture)
DECLARE FUNCTION  IPicture_Release (lpPicture)
DECLARE FUNCTION  IPicture_Get_Handle (lpPicture, lpHandle)
DECLARE FUNCTION  IPicture_Get_hPal (lpPicture, lphPal)
DECLARE FUNCTION  IPicture_Get_Type (lpPicture, lpType)
DECLARE FUNCTION  IPicture_Get_Width (lpPicture, lpWidth)
DECLARE FUNCTION  IPicture_Get_Height (lpPicture, lpHeight)
DECLARE FUNCTION  IPicture_Render (lpPicture, hdc, x, y, cx, cy, xSrc, ySrc, cxSrc, cySrc, lprcWBounds)
DECLARE FUNCTION  IPicture_Set_hPal (lpPicture, hPal)
DECLARE FUNCTION  IPicture_Get_CurDC (lpPicture, lphdcOut)
DECLARE FUNCTION  IPicture_SelectPicture (lpPicture, hdcIn, lphcOut, lphbmpOut)
'
' Control IDs
'
$$File_Open  = 101
$$File_Exit  = 102
$$Canvas1    = 200

' IPicture* Interface GUID
'DEFINE_GUID(IID_IPicture, 0x7BF80980,0xBF32,0x101A,0x8B,0xBB,0x00,0xAA,0x00,0x30,0x0C,0xAB);
$$IID_IPicture = "\x80\x09\xF8\x7B\x32\xBF\x1A\x10\x8B\xBB\x00\xAA\x00\x30\x0C\xAB"

$$HIMETRIC_INCH  = 2540

' IPicture* types
$$PICTYPE_UNINITIALIZED    = -1
$$PICTYPE_NONE             = 0
$$PICTYPE_BITMAP           = 1
$$PICTYPE_METAFILE         = 2
$$PICTYPE_ICON             = 3
$$PICTYPE_ENHMETAFILE      = 4
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
	STATIC hBitmap
	STATIC pPicture
	OPENFILENAME ofn

	SELECT CASE msg

		CASE $$WM_CREATE :
			GetClientRect (hWnd, &rect)

' create canvas control (default style is displaying both scrollbars)
' NOTE: do NOT use any window border styles like WS_BORDER or exStyles like WS_EX_CLIENTEDGE

			#hCanvas1 = NewChild ($$CANVASCLASSNAME, "", 0, 0, 0, rect.right, rect.bottom, hWnd, $$Canvas1, 0)

    CASE $$WM_COMMAND :
			ctlId = LOWORD (wParam)
			code = HIWORD (wParam)

			SELECT CASE ctlId
				CASE $$File_Open :

          file$ = NULL$ (256)
					ofn.lStructSize	= SIZE (OPENFILENAME)
					ofn.flags		    = $$OFN_FILEMUSTEXIST | $$OFN_PATHMUSTEXIST | $$OFN_HIDEREADONLY
					ofn.hwndOwner	  = hWnd
					ofn.lpstrFilter	= &"Supported Files Types(*.bmp;*.gif;*.jpg)\0*.bmp;*.gif;*.jpg\0Bitmaps (*.bmp)\0*.bmp\0GIF Files (*.gif)\0*.gif\0JPEG Files (*.jpg)\0*.jpg\0\0"
					ofn.lpstrTitle	= &"Open Image File"
					ofn.lpstrFile	  = &file$
					ofn.nMaxFile	  = LEN (file$)

' get file name to open
					IF GetOpenFileNameA (&ofn) THEN
            file$ = CSTRING$ (ofn.lpstrFile)

' load the new file
            IF LoadOleImage (file$, @hNewBitmap, @w, @h, @pNewPicture) THEN RETURN

' set new bitmap in canvas control
			      SendMessageA (#hCanvas1, $$WM_SET_CANVAS_IMAGE, 0, hNewBitmap)

' release previous IPicture* interface
			      IF hBitmap THEN
              DeleteObject (hBitmap)
              hBitmap = 0
            END IF

            IF pPicture THEN
              IPicture_Release (pPicture)
              pPicture = 0
            END IF

' save last values
						pPicture = pNewPicture
						hBitmap = hNewBitmap
					END IF

				CASE $$File_Exit :
				  DestroyWindow (hWnd)

      END SELECT

    CASE $$WM_CLOSE :
      DestroyWindow (hWnd)

		CASE $$WM_DESTROY :
			IF hBitmap THEN DeleteObject (hBitmap)
			IF pPicture THEN IPicture_Release (pPicture)
			PostQuitMessage (0)

		CASE $$WM_SIZE :
			width = LOWORD (lParam)
			height = HIWORD (lParam)
			SetWindowPos (#hCanvas1, 0, 0, 0, width, height, $$SWP_NOZORDER)

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
	SHARED hMemBitmap

' register window class
	className$  = "IPicture"
	addrWndProc = &WndProc()
	icon$ 			= "scrabble"
	menu$ 			= "menubar"
	IF RegisterWinClass (@className$, addrWndProc, @icon$, @menu$) THEN RETURN ($$TRUE)

' create main window
	title$  		= "OleLoadPicture Demo."
	style 			= $$WS_OVERLAPPEDWINDOW
	w 					= 380
	h 					= 350
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
' #############################
' #####  LoadOleImage ()  #####
' #############################
'
' PURPOSE : This function loads an image file into an
' IPicture* interface object.
' Image types that can be rendered by the
' IPicture* interface : BMP, GIF, JPG, WMF, EMF, & ICO.
' But in this function, only bitmap objects will
' be handled, eg, BMP, GIF and JPG. The calling program
' is responsible for releasing the IPicture* interface
' object (gpPicture).
'
' IN			: fileName$ - full path and filename
' OUT			: hBitmap - handle to a bitmap object
'					: w - width of image
'     		: h - height of image
'					: gpPicture - pointer to IPicture* interface object
' RETURN 	: $$FALSE on success, $$TRUE on failure
'
FUNCTION  LoadOleImage (fileName$, @hBitmap, @w, @h, @gpPicture)

	GUID iid
	BITMAP bm
	FUNCADDR OleLoadPic (XLONG, XLONG, XLONG, XLONG, XLONG)

	IFZ fileName$ THEN RETURN ($$TRUE)
  hBitmap = 0
  w = 0
  h = 0
  gpPicture = 0

' attempt to get OleLoadPicture() proc address from olepro32.dll
	hLib = LoadLibraryA (&"olepro32.dll")
	IFZ hLib THEN RETURN ($$TRUE)

' get proc address
	OleLoadPic = GetProcAddress (hLib, &"OleLoadPicture")
	IFZ OleLoadPic THEN
		FreeLibrary (hLib)
		RETURN ($$TRUE)
	END IF

' open file
	hFile = CreateFileA (&fileName$, $$GENERIC_READ, 0, NULL, $$OPEN_EXISTING, 0, NULL)
	IF hFile = $$INVALID_HANDLE_VALUE THEN RETURN ($$TRUE)

' get file size
	fileSize = GetFileSize (hFile, NULL)

' allocate memory block based on file size
	pvData = NULL
	hGlobal = GlobalAlloc ($$GMEM_MOVEABLE, fileSize)
	IFZ hGlobal THEN RETURN ($$TRUE)

' get pointer to first byte of memory block
	pvData = GlobalLock (hGlobal)

' read file and store in global memory
	bytesRead = 0
	IFZ ReadFile (hFile, pvData, fileSize, &bytesRead, NULL) THEN RETURN ($$TRUE)

	GlobalUnlock (hGlobal)
	CloseHandle (hFile)

' create IStream* from global memory
	pstm = NULL
	hr = CreateStreamOnHGlobal (hGlobal, $$TRUE, &pstm)

' create IPicture from image file

' Use OleLoadPicture() to create an IPicture object
'	hr = OleLoadPicture (lpstream, lSize, fRunmode,	riid, lplpvObj)

	XLONGAT(&&iid) = &$$IID_IPicture
	hr = @OleLoadPic (pstm, fileSize, $$FALSE, &iid, &gpPicture)

	IF hr < 0 THEN
'		PRINT "Error : LoadOleImage : OleLoadPic"
		FreeLibrary (hLib)
		gpPicture = 0
		RETURN ($$TRUE)
	END IF

' release IStream* interface
	IPicture_Release (pstm)

' obtain size of picture
	IF gpPicture THEN

' get width and height of picture in himetric units
'		IPicture_Get_Width (gpPicture, &hmWidth)
'		IPicture_Get_Height (gpPicture, &hmHeight)

' convert himetric to pixels
'		hdc = GetDC (0)
'		w = MulDiv (hmWidth, GetDeviceCaps (hdc, $$LOGPIXELSX), $$HIMETRIC_INCH)
'		h = MulDiv (hmHeight, GetDeviceCaps (hdc, $$LOGPIXELSY), $$HIMETRIC_INCH)
'		ReleaseDC (0, hdc)

' get image type
		IPicture_Get_Type (gpPicture, &type)

		IF type <> $$PICTYPE_BITMAP THEN
			error = $$TRUE
			GOTO quit
		END IF

' get handle to image
		IPicture_Get_Handle (gpPicture, &hBitmap)

    IFZ hBitmap THEN
      error = $$TRUE
      GOTO quit
    END IF

		GetObjectA (hBitmap, SIZE(bm), &bm)
		w = bm.width
    h = bm.height

' render an image to hdc (not needed here)
'		gpPicture->lpVtbl->Render(gpPicture, hdc, x, y, nWidth, nHeight, 0, hmHeight, hmWidth, -hmHeight, &rc)
'		hr = IPicture_Render (gpPicture, hdcCanvas, 0, 0, w, h, 0, hmHeight, hmWidth, -hmHeight, &rc)
	END IF

quit:

' release interface object
	IF error THEN
    IF gpPicture THEN IPicture_Release (gpPicture)
    gpPicture = 0
  END IF

' free memory block
	GlobalFree (hGlobal)

' free library
	FreeLibrary (hLib)

	IF error THEN RETURN ($$TRUE)

END FUNCTION
'
'
' ##################################
' #####  IPicture_Release ()  #####
' ##################################
'
FUNCTION  IPicture_Release (lpPicture)

	FUNCADDR Release (XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Release	= XLONGAT (vtblAddr + 0x08)
	IFZ Release THEN RETURN ($$TRUE)

	RETURN @Release (lpPicture)

END FUNCTION
'
'
' ####################################
' #####  IPicture_Get_Handle ()  #####
' ####################################
'
FUNCTION  IPicture_Get_Handle (lpPicture, lpHandle)

	FUNCADDR Get_Handle (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Get_Handle	= XLONGAT (vtblAddr + 0x0C)
	IFZ Get_Handle THEN RETURN ($$TRUE)

	RETURN @Get_Handle (lpPicture, lpHandle)

END FUNCTION
'
'
' ##################################
' #####  IPicture_Get_hPal ()  #####
' ##################################
'
FUNCTION  IPicture_Get_hPal (lpPicture, lphPal)

	FUNCADDR Get_hPal (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Get_hPal = XLONGAT (vtblAddr + 0x10)
	IFZ Get_hPal THEN RETURN ($$TRUE)

	RETURN @Get_hPal (lpPicture, lphPal)

END FUNCTION
'
'
' ##################################
' #####  IPicture_Get_Type ()  #####
' ##################################
'
FUNCTION  IPicture_Get_Type (lpPicture, lpType)

	FUNCADDR Get_Type (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Get_Type = XLONGAT (vtblAddr + 0x14)
	IFZ Get_Type THEN RETURN ($$TRUE)

	RETURN @Get_Type (lpPicture, lpType)

END FUNCTION
'
'
' ###################################
' #####  IPicture_Get_Width ()  #####
' ###################################
'
FUNCTION  IPicture_Get_Width (lpPicture, lpWidth)

	FUNCADDR Get_Width (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Get_Width = XLONGAT (vtblAddr + 0x18)
	IFZ Get_Width THEN RETURN ($$TRUE)

	RETURN @Get_Width (lpPicture, lpWidth)

END FUNCTION
'
'
' ####################################
' #####  IPicture_Get_Height ()  #####
' ####################################
'
FUNCTION  IPicture_Get_Height (lpPicture, lpHeight)

	FUNCADDR Get_Height (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Get_Height = XLONGAT (vtblAddr + 0x1C)
	IFZ Get_Height THEN RETURN ($$TRUE)

	RETURN @Get_Height (lpPicture, lpHeight)

END FUNCTION
'
'
' ################################
' #####  IPicture_Render ()  #####
' ################################
'
FUNCTION  IPicture_Render (lpPicture, hdc, x, y, cx, cy, xSrc, ySrc, cxSrc, cySrc, lprcWBounds)

	FUNCADDR Render (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Render = XLONGAT (vtblAddr + 0x20)
	IFZ Render THEN RETURN ($$TRUE)

	RETURN @Render (lpPicture, hdc, x, y, cx, cy, xSrc, ySrc, cxSrc, cySrc, lprcWBounds)

END FUNCTION
'
'
' ##################################
' #####  IPicture_Set_hPal ()  #####
' ##################################
'
FUNCTION  IPicture_Set_hPal (lpPicture, hPal)

	FUNCADDR Set_hPal (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Set_hPal = XLONGAT (vtblAddr + 0x24)
	IFZ Set_hPal THEN RETURN ($$TRUE)

	RETURN @Set_hPal (lpPicture, hPal)

END FUNCTION
'
'
' ###################################
' #####  IPicture_Get_CurDC ()  #####
' ###################################
'
FUNCTION  IPicture_Get_CurDC (lpPicture, lphdcOut)

	FUNCADDR Get_CurDC (XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	Get_CurDC = XLONGAT (vtblAddr + 0x28)
	IFZ Get_CurDC THEN RETURN ($$TRUE)

	RETURN @Get_CurDC (lpPicture, lphdcOut)

END FUNCTION
'
'
' ###################################
' #####  IPicture_SelectPicture ()  #####
' ###################################
'
FUNCTION  IPicture_SelectPicture (lpPicture, hdcIn, lphcOut, lphbmpOut)

	FUNCADDR SelectPicture (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpPicture)
	SelectPicture = XLONGAT (vtblAddr + 0x2C)
	IFZ SelectPicture THEN RETURN ($$TRUE)

	RETURN @SelectPicture (lpPicture, hdcIn, lphcOut, lphbmpOut)

END FUNCTION
END PROGRAM
