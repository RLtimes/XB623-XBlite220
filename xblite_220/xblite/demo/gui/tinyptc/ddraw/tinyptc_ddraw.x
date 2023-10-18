'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' TinyPTC by Gaffer - A tiny framebuffer library
' http://www.gaffer.org/tinyptc
' DirectDraw Port to XBLite
'
'
VERSION	"0.0001"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT  "xio"
	IMPORT	"gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
	IMPORT	"ddraw.dec"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  ptc_paint_primary ()
DECLARE FUNCTION  IDirectDrawSurface_Blt (lpDDSurface, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx)
DECLARE FUNCTION  wndproc_ddraw (hWnd, msg, wParam, lParam)
DECLARE FUNCTION  ptc_open_ddraw (title$, width, height)
DECLARE FUNCTION  IDirectDraw_SetCooperativeLevel (lpDD, hWnd, dwFlags)
DECLARE FUNCTION  IDirectDraw_SetDisplayMode (lpDD, dwWidth, dwHeight, dwBpp, dwRefreshRate, dwFlags)
DECLARE FUNCTION  IDirectDraw_CreateSurface (lpDD, lpDDSurfaceDesc, lpDDSurface, flag)
DECLARE FUNCTION  IDirectDrawSurface_GetAttachedSurface (lpDDSurface, lpDDSCaps, lpDDAttachedSurface)
DECLARE FUNCTION  IDirectDraw_CreateClipper (lpDD, dwFlags, lpDDClipper, pUnkOuter)
DECLARE FUNCTION  IDirectDrawClipper_SetHWnd (lpDDClipper, dwFlags, hWnd)
DECLARE FUNCTION  IDirectDrawSurface_GetPixelFormat (lpDDSurface, lpDDPixelFormat)
DECLARE FUNCTION  ptc_request_converter (bits, r, g, b)
DECLARE FUNCTION  ptc_convert_32_to_32_rgb888 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_32_bgr888 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_24_rgb888 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_24_bgr888 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_16_rgb565 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_16_bgr565 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_16_rgb555 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_convert_32_to_16_bgr555 (srcAddr, dstAddr, pixels)
DECLARE FUNCTION  ptc_update_ddraw (bufferAddr)
DECLARE FUNCTION  IDirectDrawSurface_Restore (lpDDSurface)
DECLARE FUNCTION  IDirectDrawSurface_Unlock (lpDDSurface, lpSurfaceData)
DECLARE FUNCTION  IDirectDrawSurface_Flip (lpDDSurface, lpDDSurfaceTargetOverride, dwFlags)
DECLARE FUNCTION  ptc_close_ddraw ()
DECLARE FUNCTION  IDirectDraw_Release (lpIUnknown)
DECLARE FUNCTION  IDirectDraw_RestoreDisplayMode (lpDD)
DECLARE FUNCTION  IDirectDrawSurface_SetClipper (lpDDSurface, lpDDClipper)
DECLARE FUNCTION  IDirectDrawSurface_Lock (lpDDSurface, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent)

' menu option identifier
$$SC_ZOOM_MSK = 0x400
$$SC_ZOOM_1x1 = 0x401
$$SC_ZOOM_2x2 = 0x402
$$SC_ZOOM_4x4 = 0x404
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	SHARED PTC_RESIZE_WINDOW
	SHARED PTC_WINDOWED
	SHARED PTC_SYSTEM_MENU
	SHARED PTC_CENTER_WINDOW
	SHARED PTC_CLOSE_ON_ESCAPE
	SHARED PTC_ALLOW_CLOSE
	SHARED PTC_DISABLE_SCREENSAVER
	SHARED PTC_ICON$

	STATIC noise
	STATIC seed
	STATIC pixel[]

' configuration
	PTC_WINDOWED            = $$TRUE		' set to $$FALSE for full-screen
	PTC_CENTER_WINDOW       = $$TRUE
	PTC_RESIZE_WINDOW       = $$TRUE
	PTC_SYSTEM_MENU         = $$TRUE
	PTC_ICON$               = "tinyptc"
	PTC_ALLOW_CLOSE         = $$TRUE
	PTC_CLOSE_ON_ESCAPE     = $$TRUE
	PTC_DISABLE_SCREENSAVER = $$TRUE

'	XioCreateConsole (title$, 100)

' set window size
	width  = 320
	height = 200
	size   = width*height

' set initial seed
	seed   = 0x12345

	DIM pixel[size-1]

	IF (!ptc_open_ddraw ("tinyptc_ddraw_test", width, height)) THEN RETURN

	upper = UBOUND (pixel[])

	DO
		FOR i = 0 TO upper
			noise = ((seed >> 3) ^ seed) >> 1
			seed  = (seed >> 1) | ((((seed >> 3) ^ seed) & 1) << 30)
			noise = noise & 0xFF
			pixel[i] = (noise<<16) | (noise<<8) | noise
		NEXT i

	LOOP WHILE (ptc_update_ddraw (&pixel[]))

'	a$ = INLINE$ ("press any key to quit >")
'	XioFreeConsole()


END FUNCTION
'
'
' ##################################
' #####  ptc_paint_primary ()  #####
' ##################################
'
FUNCTION  ptc_paint_primary ()

	RECT source
	RECT destination
	POINT point
	SHARED lpDDS, lpDDS_secondary, dx, dy, wnd

STATIC deltaAvg

' check
	IFZ (lpDDS) THEN RETURN

' setup source rectangle
	source.left   = 0
	source.top    = 0
	source.right  = dx
	source.bottom = dy

' get origin of client area
	point.x = 0
	point.y = 0
	ClientToScreen (wnd, &point)

' get window client area
	GetClientRect (wnd, &destination)

' offset destination rectangle
	destination.left   = destination.left + point.x
	destination.top    = destination.top + point.y
	destination.right  = destination.right + point.x
	destination.bottom = destination.bottom + point.y

' blt secondary to primary surface
'start = GetTickCount ()
	IDirectDrawSurface_Blt (lpDDS, &destination, lpDDS_secondary, &source, $$DDBLT_WAIT, 0)
'delta = GetTickCount() - start
'deltaAvg = (delta+deltaAvg)/2.0
'PRINT "ptc_paint_primary time="; delta, deltaAvg

END FUNCTION
'
'
' #######################################
' #####  IDirectDrawSurface_Blt ()  #####
' #######################################
'
FUNCTION  IDirectDrawSurface_Blt (lpDDSurface, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx)

	FUNCADDR Blt (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	Blt	= XLONGAT (vtblAddr + 0x14)
	IFZ Blt THEN RETURN ($$TRUE)

	RETURN @Blt (lpDDSurface, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx)

END FUNCTION
'
'
' ##############################
' #####  wndproc_ddraw ()  #####
' ##############################
'
FUNCTION  wndproc_ddraw (hWnd, msg, wParam, lParam)

	SHARED PTC_RESIZE_WINDOW
	SHARED PTC_WINDOWED
	SHARED PTC_SYSTEM_MENU
	SHARED PTC_CENTER_WINDOW
	SHARED PTC_CLOSE_ON_ESCAPE
	SHARED PTC_ALLOW_CLOSE

	SHARED original_window_width, original_window_height
	SHARED active

	IF PTC_WINDOWED THEN

	SELECT CASE msg

		CASE $$WM_PAINT :
			ptc_paint_primary ()   					' paint primary surface

		CASE $$WM_SYSCOMMAND :						' check for message from our system menu entry
			IF PTC_WINDOWED THEN
				IF PTC_RESIZE_WINDOW THEN
					IF PTC_SYSTEM_MENU THEN
						IF ((wParam & 0xFFFFFFF0) == $$SC_ZOOM_MSK) THEN
							IF PTC_CENTER_WINDOW THEN
								zoom = wParam & 0x7
								dx = GetSystemMetrics ($$SM_CXSCREEN) - original_window_width*zoom
								IF dx > 0 THEN
									x =  dx >> 1
								ELSE
									x = 0
								END IF

								dy = GetSystemMetrics ($$SM_CYSCREEN) - original_window_height*zoom
								IF dy > 0 THEN
									y =  dy >> 1
								ELSE
									y = 0
								END IF

								SetWindowPos (hWnd, NULL, x, y, original_window_width*zoom, original_window_height*zoom, $$SWP_NOZORDER)
							ELSE
								zoom = wParam & 0x7
								SetWindowPos (hWnd, NULL, 0, 0, original_window_width*zoom, original_window_height*zoom, $$SWP_NOMOVE | $$SWP_NOZORDER)
							END IF

							RETURN
'						ELSE
' pass everything else to the default (this is rather important)
'							RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
						END IF
					END IF
				END IF
			END IF

		CASE $$WM_KEYDOWN :
			IF PTC_CLOSE_ON_ESCAPE THEN
				IF ((wParam & 0xFF) = 27) THEN			' close on escape key
					ptc_close_ddraw ()								' close ptc
					QUIT (0)													' exit process
				END IF
			END IF
			RETURN

		CASE $$WM_CLOSE:
			IF PTC_ALLOW_CLOSE THEN
				ptc_close_ddraw ()									' close ptc
				QUIT (0)														' exit process
			END IF
			RETURN

		CASE $$WM_DESTROY:
			PostQuitMessage (0)
			RETURN
	END SELECT

	ELSE

	SELECT CASE msg

		CASE $$WM_ACTIVATEAPP :
			active = wParam										' update active flag
			RETURN

		CASE $$WM_SETCURSOR :
			IFZ PTC_WINDOWED THEN
				SetCursor (0)										' hide cursor
				RETURN
			END IF

		CASE $$WM_KEYDOWN :
			IF PTC_CLOSE_ON_ESCAPE THEN
				IF ((wParam & 0xFF) = 27) THEN			' close on escape key
					ptc_close_ddraw ()								' close ptc
					QUIT (0)													' exit process
				END IF
			END IF
			RETURN

		CASE $$WM_CLOSE:
			IF PTC_ALLOW_CLOSE THEN
				ptc_close_ddraw ()									' close ptc
				QUIT (0)														' exit process
			END IF
			RETURN

		CASE $$WM_DESTROY:
			PostQuitMessage (0)
			RETURN
	END SELECT


	END IF

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION
'
'
' ###############################
' #####  ptc_open_ddraw ()  #####
' ###############################
'
FUNCTION  ptc_open_ddraw (title$, width, height)

	SHARED PTC_RESIZE_WINDOW
	SHARED PTC_WINDOWED
	SHARED PTC_SYSTEM_MENU
	SHARED PTC_CENTER_WINDOW
	SHARED PTC_CLOSE_ON_ESCAPE
	SHARED PTC_ALLOW_CLOSE
	SHARED PTC_ICON$
	SHARED PTC_DISABLE_SCREENSAVER

	SHARED original_window_width, original_window_height
	SHARED wnd
	SHARED classname$

	SHARED FUNCADDR DDrawCreate (XLONG, XLONG, XLONG)

	SHARED lpDDS, lpDDS_back, lpDDS_secondary, dx, dy
	SHARED library
	DDSCAPS capabilities
	DDPIXELFORMAT format
	DDSURFACEDESC descriptor

	RECT rect
	WNDCLASS wc

	SHARED FUNCADDR convert (XLONG, XLONG, XLONG)

' setup data
	dx = width
	dy = height

' load direct draw library
	library = LoadLibraryA (&"ddraw.dll")
	IF (!library) THEN RETURN

' get directdraw create function address
	DDrawCreate = GetProcAddress (library, &"DirectDrawCreate")
	IFZ DDrawCreate THEN RETURN

' create directdraw interface
	hr = @DDrawCreate (0, &lpDD, 0)
	IF hr < 0 THEN RETURN

	classname$ 				= title$

' register window class
	IFZ PTC_WINDOWED THEN

		wc.style = $$CS_OWNDC | $$CS_VREDRAW | $$CS_HREDRAW
		wc.lpfnWndProc 		= &wndproc_ddraw()
		wc.cbClsExtra 		= 0
		wc.cbWndExtra 		= 0
		IF PTC_ICON$ THEN
			wc.hInstance 		= GetModuleHandleA (0)
			wc.hIcon 				= LoadIconA (wc.hInstance, &PTC_ICON$)
		ELSE
			wc.hInstance 		= 0
			wc.hIcon 				= NULL
		END IF
		wc.hCursor 				= LoadCursorA (0, $$IDC_ARROW)
		wc.hbrBackground 	= NULL
		wc.lpszMenuName 	= NULL
		wc.lpszClassName 	= &classname$
		IFZ RegisterClassA (&wc) THEN RETURN

' create window
		IF PTC_ICON$ THEN
    	wnd = CreateWindowExA (0, &title$, &title$, $$WS_POPUP | $$WS_SYSMENU, 0, 0, 0, 0, 0, 0, 0, 0)
		ELSE
    	wnd = CreateWindowExA (0, &title$, &title$, $$WS_POPUP, 0, 0, 0, 0, 0, 0, 0, 0)
		END IF
		IFZ wnd THEN RETURN

' enter exclusive mode
		hr = IDirectDraw_SetCooperativeLevel (lpDD, wnd, $$DDSCL_EXCLUSIVE | $$DDSCL_FULLSCREEN)
		IF hr < 0 THEN RETURN

' enter display mode
		hr = IDirectDraw_SetDisplayMode (lpDD, width, height, 32, 0, 0)
		IF hr < 0 THEN
			hr = IDirectDraw_SetDisplayMode (lpDD, width, height, 24, 0, 0)
			IF hr < 0 THEN
				hr = IDirectDraw_SetDisplayMode (lpDD, width, height, 16, 0, 0)
				IF hr < 0 THEN RETURN
			END IF
		END IF

' primary with two back buffers
		descriptor.dwSize  = SIZE (descriptor)
		descriptor.dwFlags = $$DDSD_CAPS | $$DDSD_BACKBUFFERCOUNT
		descriptor.dwBackBufferCount = 2
		descriptor.ddsCaps.dwCaps = $$DDSCAPS_PRIMARYSURFACE | $$DDSCAPS_VIDEOMEMORY | $$DDSCAPS_COMPLEX | $$DDSCAPS_FLIP
		hr = IDirectDraw_CreateSurface (lpDD, &descriptor, &lpDDS,0)
		IF hr < 0 THEN
' try primary with one back buffer
			descriptor.dwBackBufferCount = 1
			hr = IDirectDraw_CreateSurface (lpDD, &descriptor, &lpDDS, 0)
			IF hr < 0 THEN
' try primary with no back buffers
				descriptor.dwFlags = $$DDSD_CAPS
				descriptor.ddsCaps.dwCaps = $$DDSCAPS_PRIMARYSURFACE | $$DDSCAPS_VIDEOMEMORY
				hr = IDirectDraw_CreateSurface (lpDD, &descriptor, &lpDDS, 0)
				IF hr < 0 THEN RETURN
			END IF
		END IF

' get back buffer surface
		capabilities.dwCaps = $$DDSCAPS_BACKBUFFER
		hr = IDirectDrawSurface_GetAttachedSurface (lpDDS, &capabilities, &lpDDS_back)
		IF hr < 0 THEN RETURN

	ELSE

' register window class
		wc.style = $$CS_VREDRAW | $$CS_HREDRAW
		wc.lpfnWndProc = &wndproc_ddraw()
		wc.cbClsExtra = 0
		wc.cbWndExtra = 0
		IF PTC_ICON$ THEN
			wc.hInstance = GetModuleHandleA (0)
			wc.hIcon = LoadIconA (wc.hInstance, &PTC_ICON$)
		ELSE
			wc.hInstance = 0
			wc.hIcon = 0
		END IF
		wc.hCursor = LoadCursorA (0, $$IDC_ARROW)
		wc.hbrBackground = 0
		wc.lpszMenuName = 0
		wc.lpszClassName = &title$
		IFZ RegisterClassA (&wc) THEN RETURN

' calculate window size
		rect.left = 0
		rect.top = 0
		rect.right = width
		rect.bottom = height
		AdjustWindowRectEx (&rect, $$WS_OVERLAPPEDWINDOW, 0, 0)
		rect.right = rect.right - rect.left
		rect.bottom = rect.bottom - rect.top

		IF PTC_CENTER_WINDOW THEN
' center window
			x = (GetSystemMetrics ($$SM_CXSCREEN) - rect.right) >> 1
			y = (GetSystemMetrics ($$SM_CYSCREEN) - rect.bottom) >> 1
		ELSE
' let windows decide
			x = $$CW_USEDEFAULT
			y = $$CW_USEDEFAULT
		END IF

		IF PTC_RESIZE_WINDOW THEN
' create resizable window
			wnd = CreateWindowExA (0, &title$, &title$, $$WS_OVERLAPPEDWINDOW, x, y, rect.right, rect.bottom, 0, 0, 0, 0)
		ELSE
' create fixed window
			wnd = CreateWindowExA (0, &title$, &title$, $$WS_OVERLAPPEDWINDOW & ~$$WS_MAXIMIZEBOX & ~$$WS_THICKFRAME, x, y, rect.right, rect.bottom, 0, 0, 0, 0)
		END IF

' show window
		ShowWindow (wnd, $$SW_NORMAL)

		IF PTC_RESIZE_WINDOW THEN
			IF PTC_SYSTEM_MENU THEN

' add entry to system menu to restore original window size
				system_menu = GetSystemMenu (wnd, $$FALSE)
				AppendMenuA (system_menu, $$MF_STRING, $$SC_ZOOM_1x1, &"Zoom 1 x 1")
				AppendMenuA (system_menu, $$MF_STRING, $$SC_ZOOM_2x2, &"Zoom 2 x 2")
				AppendMenuA (system_menu, $$MF_STRING, $$SC_ZOOM_4x4, &"Zoom 4 x 4")

' save original window size
				original_window_width = rect.right
				original_window_height = rect.bottom
			END IF
		END IF

' enter cooperative mode
		hr = IDirectDraw_SetCooperativeLevel (lpDD, wnd, $$DDSCL_NORMAL)
		IF hr < 0 THEN RETURN

' primary with no back buffers
		descriptor.dwSize  = SIZE (descriptor)
		descriptor.dwFlags = $$DDSD_CAPS
		descriptor.ddsCaps.dwCaps = $$DDSCAPS_PRIMARYSURFACE | $$DDSCAPS_VIDEOMEMORY
		hr = IDirectDraw_CreateSurface (lpDD, &descriptor, &lpDDS, 0)
		IF hr < 0 THEN RETURN

' create secondary surface
		descriptor.dwFlags = $$DDSD_CAPS | $$DDSD_HEIGHT | $$DDSD_WIDTH
		descriptor.ddsCaps.dwCaps = $$DDSCAPS_OFFSCREENPLAIN
		descriptor.dwWidth = width
		descriptor.dwHeight = height
		hr = IDirectDraw_CreateSurface (lpDD, &descriptor, &lpDDS_secondary, 0)
		IF hr < 0 THEN RETURN

' create clipper
		hr = IDirectDraw_CreateClipper (lpDD, 0, &lpDDC, 0)
		IF hr < 0 THEN RETURN

' set clipper to window
		hr = IDirectDrawClipper_SetHWnd (lpDDC, 0, wnd)
		IF hr < 0 THEN RETURN

' attach clipper object to primary surface
		hr = IDirectDrawSurface_SetClipper (lpDDS, lpDDC)
		IF hr < 0 THEN RETURN

' set back to secondary
		lpDDS_back = lpDDS_secondary

	END IF

' get pixel format
	format.dwSize = SIZE (format)
	hr = IDirectDrawSurface_GetPixelFormat (lpDDS, &format)
	IF hr < 0 THEN RETURN

' check that format is direct color
	IF (!(format.dwFlags & $$DDPF_RGB)) THEN RETURN

' request converter function
PRINT "bitCount="; format.dwRGBBitCount
PRINT "RBitMask="; HEXX$(format.dwRBitMask)
PRINT "GBitMask="; HEXX$(format.dwGBitMask)
PRINT "BBitMask="; HEXX$(format.dwBBitMask)
	converterFunc = ptc_request_converter (format.dwRGBBitCount, format.dwRBitMask, format.dwGBitMask, format.dwBBitMask)
PRINT "converterFunc="; converterFunc
	IF (!converterFunc) THEN RETURN
	convert = FUNCADDR (converterFunc)

	IF PTC_DISABLE_SCREENSAVER THEN
' disable screensaver while ptc is open
		SystemParametersInfoA ($$SPI_SETSCREENSAVEACTIVE, 0, 0, 0)
	END IF

' success
	RETURN 1

END FUNCTION
'
'
' ################################################
' #####  IDirectDraw_SetCooperativeLevel ()  #####
' ################################################
'
FUNCTION  IDirectDraw_SetCooperativeLevel (lpDD, hWnd, dwFlags)

	FUNCADDR SetCooperativeLevel (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	SetCooperativeLevel	= XLONGAT (vtblAddr + 0x50)
	IFZ SetCooperativeLevel THEN RETURN ($$TRUE)

	RETURN @SetCooperativeLevel (lpDD, hWnd, dwFlags)

END FUNCTION
'
'
' ###########################################
' #####  IDirectDraw_SetDisplayMode ()  #####
' ###########################################
'
FUNCTION  IDirectDraw_SetDisplayMode (lpDD, dwWidth, dwHeight, dwBpp, dwRefreshRate, dwFlags)

	FUNCADDR SetDisplayMode (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	SetDisplayMode	= XLONGAT (vtblAddr + 0x54)
	IFZ SetDisplayMode THEN RETURN ($$TRUE)

	RETURN @SetDisplayMode (lpDD, dwWidth, dwHeight, dwBpp, dwRefreshRate, dwFlags)

END FUNCTION
'
'
' ##########################################
' #####  IDirectDraw_CreateSurface ()  #####
' ##########################################
'
FUNCTION  IDirectDraw_CreateSurface (lpDD, lpDDSurfaceDesc, lpDDSurface, flag)

	FUNCADDR CreateSurface (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	CreateSurface	= XLONGAT (vtblAddr + 0x18)
	IFZ CreateSurface THEN RETURN ($$TRUE)

	RETURN @CreateSurface (lpDD, lpDDSurfaceDesc, lpDDSurface, flag)

END FUNCTION
'
'
' ######################################################
' #####  IDirectDrawSurface_GetAttachedSurface ()  #####
' ######################################################
'
FUNCTION  IDirectDrawSurface_GetAttachedSurface (lpDDSurface, lpDDSCaps, lpDDAttachedSurface)

	FUNCADDR GetAttachedSurface (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetAttachedSurface	= XLONGAT (vtblAddr + 0x30)
	IFZ GetAttachedSurface THEN RETURN ($$TRUE)

	RETURN @GetAttachedSurface (lpDDSurface, lpDDSCaps, lpDDAttachedSurface)


END FUNCTION
'
'
' ##########################################
' #####  IDirectDraw_CreateClipper ()  #####
' ##########################################
'
FUNCTION  IDirectDraw_CreateClipper (lpDD, dwFlags, lpDDClipper, pUnkOuter)

	FUNCADDR CreateClipper (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	CreateClipper	= XLONGAT (vtblAddr + 0x10)
	IFZ CreateClipper THEN RETURN ($$TRUE)

	RETURN @CreateClipper (lpDD, dwFlags, lpDDClipper, pUnkOuter)


END FUNCTION
'
'
' ###########################################
' #####  IDirectDrawClipper_SetHWnd ()  #####
' ###########################################
'
FUNCTION  IDirectDrawClipper_SetHWnd (lpDDClipper, dwFlags, hWnd)

	FUNCADDR SetHWnd (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDClipper)
	SetHWnd	= XLONGAT (vtblAddr + 0x20)
	IFZ SetHWnd THEN RETURN ($$TRUE)

	RETURN @SetHWnd (lpDDClipper, dwFlags, hWnd)

END FUNCTION
'
'
' ##################################################
' #####  IDirectDrawSurface_GetPixelFormat ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_GetPixelFormat (lpDDSurface, lpDDPixelFormat)

	FUNCADDR GetPixelFormat (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetPixelFormat	= XLONGAT (vtblAddr + 0x54)
	IFZ GetPixelFormat THEN RETURN ($$TRUE)

	RETURN @GetPixelFormat (lpDDSurface, lpDDPixelFormat)


END FUNCTION
'
'
' ######################################
' #####  ptc_request_converter ()  #####
' ######################################
'
FUNCTION  ptc_request_converter (bits, r, g, b)

	SELECT CASE TRUE
' 32bit RGB888 -> 32bit RGB888
		CASE (bits==32 && r==0x00FF0000 && g==0x0000FF00 && b==0x000000FF) :
			RETURN &ptc_convert_32_to_32_rgb888()

' 32bit RGB888 -> 32bit BGR888
		CASE (bits==32 && r==0x000000FF && g==0x0000FF00 && b==0x00FF0000) :
			RETURN &ptc_convert_32_to_32_bgr888()

' 32bit RGB888 -> 24bit RGB888
		CASE (bits==24 && r==0x00FF0000 && g==0x0000FF00 && b==0x000000FF) :
			RETURN &ptc_convert_32_to_24_rgb888()

' 32bit RGB888 -> 24bit BGR888
		CASE (bits==24 && r==0x000000FF && g==0x0000FF00 && b==0x00FF0000) :
			RETURN &ptc_convert_32_to_24_bgr888()

' 32bit RGB888 -> 16bit RGB565
		CASE (bits==16 && r==0xF800 && g==0x07E0 && b==0x001F) :
			RETURN &ptc_convert_32_to_16_rgb565()

' 32bit RGB888 -> 16bit BGR565
		CASE (bits==16 && r==0x001F && g==0x07E0 && b==0xF800) :
			RETURN &ptc_convert_32_to_16_bgr565()

' 32bit RGB888 -> 16bit RGB555
		CASE (bits==16 && r==0x7C00 && g==0x03E0 && b==0x001F) :
			RETURN &ptc_convert_32_to_16_rgb555()

' 32bit RGB888 -> 16bit BGR555
		CASE (bits==16 && r==0x001F && g==0x03E0 && b==0x7C00) :
			RETURN &ptc_convert_32_to_16_bgr555()

	END SELECT

' failure
	RETURN ($$FALSE)

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_32_rgb888 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_32_rgb888 (srcAddr, dstAddr, pixels)

	RtlMoveMemory (dstAddr, srcAddr, pixels*4)

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_32_bgr888 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_32_bgr888 (srcAddr, dstAddr, pixels)

	p = srcAddr
	q = dstAddr

	DO
		r = (XLONGAT(p) & 0x00FF0000) >> 16
		g = (XLONGAT(p) & 0x0000FF00)
		b = (XLONGAT(p) & 0x000000FF) << 16
		XLONGAT(q) = r | g | b
		p = p + 4
		q = q + 4
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_24_rgb888 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_24_rgb888 (srcAddr, dstAddr, pixels)

	p = srcAddr
	q = dstAddr

	DO
		XLONGAT(q) = XLONGAT(p)
'		UBYTEAT(q) = UBYTEAT(p)
'		UBYTEAT(q+1) = UBYTEAT(p+1)
'		UBYTEAT(q+2) = UBYTEAT(p+2)
		p = p + 4
		q = q + 3
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_24_bgr888 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_24_bgr888 (srcAddr, dstAddr, pixels)

	p = srcAddr
	q = dstAddr

	DO
		UBYTEAT(q+2) = UBYTEAT(p)
		UBYTEAT(q+1) = UBYTEAT(p+1)
		UBYTEAT(q) = UBYTEAT(p+2)
		p = p + 4
		q = q + 3
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_16_rgb565 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_16_rgb565 (srcAddr, dstAddr, pixels)

	p = srcAddr
	q = dstAddr

	DO
 		r = (XLONGAT(p) & 0x00F80000) >> 8
		g = (XLONGAT(p) & 0x0000FC00) >> 5
		b = (XLONGAT(p) & 0x000000F8) >> 3
		USHORTAT(q) = USHORT (r | g | b)
		p = p + 4
		q = q + 2
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_16_bgr565 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_16_bgr565 (srcAddr, dstAddr, pixels)

	p = srcAddr
	q = dstAddr

	DO
		r = (XLONGAT(p) & 0x00F80000) >> 19
		g = (XLONGAT(p) & 0x0000FC00) >> 5
		b = (XLONGAT(p) & 0x000000F8) << 8
		USHORTAT(q) = USHORT (r | g | b)
		p = p + 4
		q = q + 2
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_16_rgb555 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_16_rgb555 (srcAddr, dstAddr, pixels)

'    int32 *p = (int32*) src;
'    short16 *q = (short16*) dst;
'        while (pixels--)
'        {
'            short16 r = (short16) ( (*p & 0x00F80000) >> 9 );
'            short16 g = (short16) ( (*p & 0x0000F800) >> 6 );
'            short16 b = (short16) ( (*p & 0x000000F8) >> 3 );
'            *q = r | g | b;
'            p++;
'            q++;
'        }

	p = srcAddr
	q = dstAddr

	DO
		r = (XLONGAT(p) & 0x00F80000) >> 9
		g = (XLONGAT(p) & 0x0000F800) >> 6
		b = (XLONGAT(p) & 0x000000F8) >> 3
    USHORTAT(q) = USHORT (r | g | b)
    p = p + 4
		q = q + 2
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' ############################################
' #####  ptc_convert_32_to_16_bgr555 ()  #####
' ############################################
'
FUNCTION  ptc_convert_32_to_16_bgr555 (srcAddr, dstAddr, pixels)

	p = srcAddr
	q = dstAddr

	DO
		r = (XLONGAT(p) & 0x00F80000) >> 20
		g = (XLONGAT(p) & 0x0000F800) >> 6
		b = (XLONGAT(p) & 0x000000F8) << 8
		USHORTAT(q) = USHORT (r | g | b)
		p = p + 4
		q = q + 2
		DEC pixels
	LOOP WHILE pixels

END FUNCTION
'
'
' #################################
' #####  ptc_update_ddraw ()  #####
' #################################
'
FUNCTION  ptc_update_ddraw (bufferAddr)

	SHARED PTC_WINDOWED
	MSG message
	SHARED wnd
	SHARED lpDDS, lpDDS_back, lpDDS_secondary, dx, dy
	SHARED active
	DDSURFACEDESC descriptor
	SHARED FUNCADDR convert (XLONG, XLONG, XLONG)

' process messages
	DO WHILE (PeekMessageA (&message, wnd, 0, 0, $$PM_REMOVE))
'	 translate and dispatch
		TranslateMessage (&message)
		DispatchMessageA (&message)
	LOOP

	IFZ PTC_WINDOWED THEN
		IF (active) THEN
' restore surfaces
			IDirectDrawSurface_Restore (lpDDS)

' lock back surface
			descriptor.dwSize = SIZE (descriptor)
			hr = IDirectDrawSurface_Lock (lpDDS_back, 0, &descriptor, $$DDLOCK_WAIT,0)
			IF hr < 0 THEN RETURN

' calculate pitches
			src_pitch = dx * 4
			dst_pitch = descriptor.lPitch

' copy pixels to back surface
			src = bufferAddr
			dst = descriptor.lpSurface

			upp = dy - 1
			FOR y = 0 TO upp
' convert line
				@convert (src, dst, dx)
				src = src + src_pitch
				dst = dst + dst_pitch
			NEXT y

' unlock back surface
			hr = IDirectDrawSurface_Unlock (lpDDS_back, descriptor.lpSurface)

' flip primary surface
			hr = IDirectDrawSurface_Flip (lpDDS, 0, $$DDFLIP_WAIT)

' sleep
			Sleep(0)
		ELSE
' sleep
			Sleep(1)
		END IF

	ELSE

' restore surfaces
		IDirectDrawSurface_Restore (lpDDS)
		IDirectDrawSurface_Restore(lpDDS_secondary)

' lock back surface
		descriptor.dwSize = SIZE (descriptor)
		hr = IDirectDrawSurface_Lock (lpDDS_back, 0, &descriptor, $$DDLOCK_WAIT,0)
		IF hr < 0 THEN RETURN

' calculate pitches
		src_pitch = dx * 4
		dst_pitch = descriptor.lPitch

' copy pixels to back surface
		src = bufferAddr
		dst = descriptor.lpSurface

		upp = dy - 1
		FOR y = 0 TO upp
' convert line
			@convert (src, dst, dx)
			src = src + src_pitch
			dst = dst + dst_pitch
		NEXT y

' unlock back surface
		IDirectDrawSurface_Unlock (lpDDS_back, descriptor.lpSurface)

' paint primary
		ptc_paint_primary()

' sleep
		Sleep(0)

	END IF

' success
	RETURN 1

END FUNCTION
'
'
' ###########################################
' #####  IDirectDrawSurface_Restore ()  #####
' ###########################################
'
FUNCTION  IDirectDrawSurface_Restore (lpDDSurface)

	FUNCADDR Restore (XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	Restore	= XLONGAT (vtblAddr + 0x6C)
	IFZ Restore THEN RETURN ($$TRUE)

	RETURN @Restore (lpDDSurface)


END FUNCTION
'
'
' ##########################################
' #####  IDirectDrawSurface_Unlock ()  #####
' ##########################################
'
FUNCTION  IDirectDrawSurface_Unlock (lpDDSurface, lpSurfaceData)

	FUNCADDR Unlock (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	Unlock	= XLONGAT (vtblAddr + 0x80)
	IFZ Unlock THEN RETURN ($$TRUE)

	RETURN @Unlock (lpDDSurface, lpSurfaceData)


END FUNCTION
'
'
' ########################################
' #####  IDirectDrawSurface_Flip ()  #####
' ########################################
'
FUNCTION  IDirectDrawSurface_Flip (lpDDSurface, lpDDSurfaceTargetOverride, dwFlags)

	FUNCADDR Flip (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	Flip	= XLONGAT (vtblAddr + 0x2C)
	IFZ Flip THEN RETURN ($$TRUE)

	RETURN @Flip (lpDDSurface, lpDDSurfaceTargetOverride, dwFlags)

END FUNCTION
'
'
' ################################
' #####  ptc_close_ddraw ()  #####
' ################################
'
FUNCTION  ptc_close_ddraw ()

	SHARED PTC_DISABLE_SCREENSAVER
	SHARED PTC_WINDOWED
	SHARED wnd
	SHARED library
	SHARED lpDD, lpDDS, lpDDS_secondary

	SHARED classname$

	IF PTC_WINDOWED THEN
' check secondary
		IF (lpDDS_secondary) THEN
' release secondary
			IDirectDraw_Release (lpDDS_secondary)
			lpDDS_secondary = 0
		END IF
	END IF

' check
	IF (lpDDS) THEN
' release primary
		IDirectDraw_Release (lpDDS)
		lpDDS = 0
	END IF

' check
	IF (lpDD) THEN
' leave display mode
		IDirectDraw_RestoreDisplayMode (lpDD)

' leave exclusive mode
		IDirectDraw_SetCooperativeLevel (lpDD, wnd, $$DDSCL_NORMAL)

' free direct draw
		IDirectDraw_Release (lpDD)
		lpDD = 0
	END IF

' destroy window
	DestroyWindow (wnd)

' check
	IF (library) THEN
' free library
		FreeLibrary (library)
		library = 0
	END IF

	IF PTC_DISABLE_SCREENSAVER THEN
' enable screensaver now that ptc is closed
		SystemParametersInfoA ($$SPI_SETSCREENSAVEACTIVE, 1, 0, 0)
	END IF

' unregister window
	hInst = GetModuleHandleA (0)
	UnregisterClassA (&classname$, hInst)

END FUNCTION
'
'
' ####################################
' #####  IDirectDraw_Release ()  #####
' ####################################
'
FUNCTION  IDirectDraw_Release (lpIUnknown)

	FUNCADDR Release (XLONG)

	vtblAddr = XLONGAT (lpIUnknown)
	Release	= XLONGAT (vtblAddr + 0x08)
	IFZ Release THEN RETURN ($$TRUE)

	RETURN @Release (lpIUnknown)


END FUNCTION
'
'
' ###############################################
' #####  IDirectDraw_RestoreDisplayMode ()  #####
' ###############################################
'
FUNCTION  IDirectDraw_RestoreDisplayMode (lpDD)

	FUNCADDR RestoreDisplayMode (XLONG)

	vtblAddr = XLONGAT (lpDD)
	RestoreDisplayMode	= XLONGAT (vtblAddr + 0x4C)
	IFZ RestoreDisplayMode THEN RETURN ($$TRUE)

	RETURN @RestoreDisplayMode (lpDD)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawSurface_SetClipper ()  #####
' ##############################################
'
FUNCTION  IDirectDrawSurface_SetClipper (lpDDSurface, lpDDClipper)

	FUNCADDR SetClipper (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetClipper	= XLONGAT (vtblAddr + 0x70)
	IFZ SetClipper THEN RETURN ($$TRUE)

	RETURN @SetClipper (lpDDSurface, lpDDClipper)

END FUNCTION
'
'
' ########################################
' #####  IDirectDrawSurface_Lock ()  #####
' ########################################
'
FUNCTION  IDirectDrawSurface_Lock (lpDDSurface, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent)

	FUNCADDR Lock (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	Lock	= XLONGAT (vtblAddr + 0x64)
	IFZ Lock THEN RETURN ($$TRUE)

	RETURN @Lock (lpDDSurface, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent)



END FUNCTION
END PROGRAM
