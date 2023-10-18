'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' TinyPTC by Gaffer - A tiny framebuffer library
' http://www.gaffer.org/tinyptc
' Port to XBLite by David Szafranski
'
'
VERSION	"0.0001"
'
'	IMPORT	"xst"   		' Standard library : required by most programs
'	IMPORT 	"xio"
	IMPORT	"gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  ptc_open_gdi (title$, width, height)
DECLARE FUNCTION  ptc_close_gdi ()
DECLARE FUNCTION  ptc_update_gdi (bufferAddr)
DECLARE FUNCTION  wndproc_gdi (hWnd, msg, wParam, lParam)

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
	STATIC carry
	STATIC index
	STATIC seed
	STATIC pixel[]
	STATIC upper

' configuration
	PTC_WINDOWED            = $$TRUE
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

' random number seed
	seed   = 0x12345

	DIM pixel[size-1]

	IF (!ptc_open_gdi ("tinyptc_gdi_test", width, height)) THEN RETURN

	upper = UBOUND (pixel[])

	DO
		FOR i = 0 TO upper

'			noise = seed
'			noise = noise >> 3
'			noise = noise ^ seed
'			carry = noise & 1
'			noise = noise >> 1
'			seed  = seed >> 1
'			seed  = seed | (carry << 30)
'			noise = noise & 0xFF

			noise = ((seed >> 3) ^ seed) >> 1
			seed  = (seed >> 1) | ((((seed >> 3) ^ seed) & 1) << 30)
			noise = noise & 0xFF

			pixel[i] = (noise<<16) | (noise<<8) | noise
		NEXT i

	LOOP WHILE (ptc_update_gdi (&pixel[]))

'	a$ = INLINE$ ("press any key to quit >")
'	XioFreeConsole ()							' free console

END FUNCTION
'
'
' #############################
' #####  ptc_open_gdi ()  #####
' #############################
'
FUNCTION  ptc_open_gdi (title$, width, height)

	SHARED cached_buffer
	SHARED PTC_RESIZE_WINDOW
	SHARED PTC_WINDOWED
	SHARED PTC_SYSTEM_MENU
	SHARED PTC_CENTER_WINDOW
	SHARED PTC_CLOSE_ON_ESCAPE
	SHARED PTC_ALLOW_CLOSE
	SHARED PTC_ICON$
	SHARED PTC_DISABLE_SCREENSAVER

	SHARED surface_width, surface_height
	SHARED original_window_width, original_window_height
	SHARED bitmap_header
	SHARED window_hdc
	SHARED wnd
	SHARED classname$

	RECT rect
	WNDCLASS wc

	STATIC BITMAPINFOEX bitmapbuffer

	classname$ 				= title$

' register window class
	wc.style = $$CS_OWNDC | $$CS_VREDRAW | $$CS_HREDRAW
	wc.lpfnWndProc 		= &wndproc_gdi()
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

' calculate window size
	rect.left   = 0
	rect.top    = 0
	rect.right  = width
	rect.bottom = height

	IF PTC_RESIZE_WINDOW THEN
		AdjustWindowRectEx (&rect, $$WS_OVERLAPPEDWINDOW, 0, 0)
	ELSE
    AdjustWindowRectEx (&rect, $$WS_POPUP | $$WS_SYSMENU | $$WS_CAPTION, 0, 0)
	END IF

	rect.right  = rect.right - rect.left
	rect.bottom = rect.bottom - rect.top

' save surface size and original window size
	surface_width          = width
	surface_height         = height
	original_window_width  = rect.right
	original_window_height = rect.bottom

	IF PTC_CENTER_WINDOW THEN
' center window
    original_window_x = (GetSystemMetrics ($$SM_CXSCREEN) - rect.right) >> 1
    original_window_y = (GetSystemMetrics ($$SM_CYSCREEN) - rect.bottom) >> 1
	ELSE
' let windows decide
    original_window_x = $$CW_USEDEFAULT
    original_window_y = $$CW_USEDEFAULT
	END IF

' create window and show it
	IF PTC_RESIZE_WINDOW THEN
		wnd = CreateWindowExA (0, &title$, &title$, $$WS_OVERLAPPEDWINDOW, original_window_x, original_window_y, rect.right, rect.bottom, 0, 0, 0, 0)
	ELSE
    wnd = CreateWindowExA (0, &title$, &title$, $$WS_OVERLAPPEDWINDOW & ~$$WS_MAXIMIZEBOX & ~$$WS_THICKFRAME, original_window_x, original_window_y, rect.right, rect.bottom, 0, 0, 0, 0)
	END IF
	IFZ wnd THEN RETURN
	ShowWindow (wnd, $$SW_NORMAL)

' set bitmapinfo data

	bitmapbuffer.bmiHeader.biSize          = SIZE (BITMAPINFOHEADER)
	bitmapbuffer.bmiHeader.biWidth         = surface_width
	bitmapbuffer.bmiHeader.biHeight        = -surface_height							' note well
	bitmapbuffer.bmiHeader.biPlanes        = 1
	bitmapbuffer.bmiHeader.biBitCount      = 32
	bitmapbuffer.bmiHeader.biCompression   = $$BI_BITFIELDS
	bitmapbuffer.bmiHeader.biSizeImage     = 0
	bitmapbuffer.bmiHeader.biXPelsPerMeter = 0
	bitmapbuffer.bmiHeader.biYPelsPerMeter = 0
	bitmapbuffer.bmiHeader.biClrUsed       = 0
	bitmapbuffer.bmiHeader.biClrImportant  = 0
	bitmapbuffer.bmiColors[0]              = 0x00FF0000		' red mask
	bitmapbuffer.bmiColors[1]              = 0x0000FF00		' green mask
	bitmapbuffer.bmiColors[2]              = 0x000000FF		' blue mask

' get header address
	bitmap_header = &bitmapbuffer

' get window dc
	window_hdc = GetDC (wnd)

	IF PTC_RESIZE_WINDOW THEN
		IF PTC_SYSTEM_MENU THEN
' add entry to system menu to restore original window size
			menu = GetSystemMenu (wnd, $$FALSE)
			AppendMenuA (menu, $$MF_STRING, $$SC_ZOOM_1x1, &"Zoom 1 x 1")
			AppendMenuA (menu, $$MF_STRING, $$SC_ZOOM_2x2, &"Zoom 2 x 2")
			AppendMenuA (menu, $$MF_STRING, $$SC_ZOOM_4x4, &"Zoom 4 x 4")
		END IF
	END IF

	IF PTC_DISABLE_SCREENSAVER THEN
' disable screensaver while ptc is open
		SystemParametersInfoA ($$SPI_SETSCREENSAVEACTIVE, 0, 0, 0)
	END IF

' success
	RETURN 1

END FUNCTION
'
'
' ##############################
' #####  ptc_close_gdi ()  #####
' ##############################
'
FUNCTION  ptc_close_gdi ()

	SHARED PTC_DISABLE_SCREENSAVER
	SHARED window_hdc
	SHARED wnd
	SHARED cached_buffer
	SHARED classname$

' clear cached buffer
	cached_buffer = 0

' release DC
	ReleaseDC (wnd, window_hdc)

' destroy window
	DestroyWindow (wnd)

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
' ###############################
' #####  ptc_update_gdi ()  #####
' ###############################
'
FUNCTION  ptc_update_gdi (bufferAddr)

	MSG message
	SHARED wnd
	SHARED cached_buffer

' update buffer ptr cache
	cached_buffer = bufferAddr

' invalidate window
	InvalidateRect (wnd, NULL, $$TRUE)

' send paint window message
	SendMessageA (wnd, $$WM_PAINT, 0, 0)

' process messages
	DO WHILE (PeekMessageA (&message, wnd, 0, 0, $$PM_REMOVE))
'	 translate and dispatch
		TranslateMessage (&message)
		DispatchMessageA (&message)
	LOOP

' sleep
	Sleep(0)

' success
	RETURN 1

END FUNCTION
'
'
' ############################
' #####  wndproc_gdi ()  #####
' ############################
'
FUNCTION  wndproc_gdi (hWnd, msg, wParam, lParam)

	PAINTSTRUCT ps
	RECT windowsize

	SHARED PTC_RESIZE_WINDOW
	SHARED PTC_WINDOWED
	SHARED PTC_SYSTEM_MENU
	SHARED PTC_CENTER_WINDOW
	SHARED PTC_CLOSE_ON_ESCAPE
	SHARED PTC_ALLOW_CLOSE

	SHARED surface_width, surface_height
	SHARED original_window_width, original_window_height
	SHARED bitmap_header
	SHARED window_hdc
	SHARED cached_buffer

BITMAPINFOEX bitmapbuffer

	SELECT CASE msg

		CASE $$WM_PAINT :

			IF cached_buffer !=0 THEN							' check cached buffer
				IF PTC_RESIZE_WINDOW THEN						' grab current window size
					GetClientRect (hWnd, &windowsize)
					ret = StretchDIBits (window_hdc, 0, 0, windowsize.right, windowsize.bottom, 0, 0, surface_width, surface_height, cached_buffer, bitmap_header, $$DIB_RGB_COLORS, $$SRCCOPY)
				ELSE
					ret = StretchDIBits (window_hdc, 0, 0, surface_width, surface_height, 0, 0, surface_width, surface_height, cached_buffer, bitmap_header, $$DIB_RGB_COLORS, $$SRCCOPY)
				END IF

'				IF ret = $$GDI_ERROR THEN
'					err = GetLastError ()
'					XstSystemErrorNumberToName (err, @sysError$)
'				END IF

				ValidateRect (hWnd, NULL)						' validate window
			END IF

		CASE $$WM_SYSCOMMAND :									' check for message from our system menu entry
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
						ELSE
' pass everything else to the default (this is rather important)
							RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
						END IF
					END IF
				END IF
			END IF

		CASE $$WM_KEYDOWN :
			IF PTC_CLOSE_ON_ESCAPE THEN
				IF ((wParam & 0xFF) = 27) THEN			' close on escape key
					ptc_close_gdi ()									' close ptc
					QUIT (0)													' exit process
				END IF
			END IF

		CASE $$WM_CLOSE:
			IF PTC_ALLOW_CLOSE THEN
				ptc_close_gdi ()					' close ptc
				QUIT (0)									' exit process
			END IF

		CASE $$WM_DESTROY:
			PostQuitMessage (0)

		CASE ELSE :
			RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

	END SELECT

END FUNCTION
END PROGRAM
