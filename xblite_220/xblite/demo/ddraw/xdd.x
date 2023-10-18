'
'
' ####################
' #####  PROLOG  #####
' ####################
'
PROGRAM	"xdd"
VERSION	"0.0001"
'CONSOLE

	IMPORT	"xst"   		' Standard library : required by most programs
	IMPORT	"gdi32"
	IMPORT	"user32"
	IMPORT	"kernel32"
	IMPORT	"ddraw.dec"	'direct draw library .dec file
	IMPORT	"ole32"			'ole32.dll library

EXPORT
'
DECLARE FUNCTION  Xdd ()
'
' xdd functions
'
DECLARE FUNCTION  XddInitDD       ()
DECLARE FUNCTION  XddCleanUp      ()
DECLARE FUNCTION  XddColorMatch   (pdds, rgb)
DECLARE FUNCTION  XddCopyBitmap   (pdds, hbm, x, y, dx, dy)
DECLARE FUNCTION  XddGetDxVersion (@version$)
DECLARE FUNCTION  XddLoadBitmap   (pDD, bitmap$, dx, dy)
DECLARE FUNCTION  XddSetColorKey  (pdds, rgb)
'
' direct draw functions
'
DECLARE FUNCTION  XddDirectDrawCreate (lpGUID, lpDD, pUnkOuter)
DECLARE FUNCTION  XddDirectDrawCreateClipper (dwFlags, lpDDClipper, pUnkOuter)
DECLARE FUNCTION  XddDirectDrawEnumerate (lpCallback, lpContext)
DECLARE FUNCTION  XddDirectDrawEnumerateEx (lpCallback, lpContext, dwFlags)
DECLARE FUNCTION  XddDirectDrawCreateEx (lpGuid, lpDD, iid, pUnkOuter)
'
' interface
'
DECLARE FUNCTION  IDirectDraw_QueryInterface (lpIUnknown, riid, ppvObj)
DECLARE FUNCTION  IDirectDraw_AddRef (lpIUnknown)
DECLARE FUNCTION  IDirectDraw_Release (lpIUnknown)
DECLARE FUNCTION  IDirectDraw_Compact (lpDD)
'
' interface directdraw methods
'
DECLARE FUNCTION  IDirectDraw_CreateClipper (lpDD, dwFlags, lpDDClipper, pUnkOuter)
DECLARE FUNCTION  IDirectDraw_CreatePalette (lpDD, lpColorTable, lpDDPalette, pUnkOuter, flag)
DECLARE FUNCTION  IDirectDraw_CreateSurface (lpDD, lpDDSurfaceDesc, lpDDSurface, flag)
DECLARE FUNCTION  IDirectDraw_DuplicateSurface (lpDD, lpDDSurface, lpDupDDSurface)
DECLARE FUNCTION  IDirectDraw_EnumDisplayModes (lpDD, dwFlags, lpDDSurfaceDesc, lpContext, lpEnumModesCallback)
DECLARE FUNCTION  IDirectDraw_EnumSurfaces (lpDD, dwFlags, lpDDSurfaceDesc, lpContext, lpEnumModesCallback)
DECLARE FUNCTION  IDirectDraw_FlipToGDISurface (lpDD)
DECLARE FUNCTION  IDirectDraw_GetCaps (lpDD, lpDDDriverCaps, lpDDHELCaps)
DECLARE FUNCTION  IDirectDraw_GetDisplayMode (lpDD, lpDDSurfaceDesc)
DECLARE FUNCTION  IDirectDraw_GetFourCCCodes (lpDD, lpNumCodes, lpCodes)
DECLARE FUNCTION  IDirectDraw_GetGDISurface (lpDD, lpGDIDSSurface)
DECLARE FUNCTION  IDirectDraw_MonitorFrequency (lpDD, lpdwFrequency)
DECLARE FUNCTION  IDirectDraw_GetScanLine (lpDD, lpdwScanLine)
DECLARE FUNCTION  IDirectDraw_GetVerticalBlankStatus (lpDD, lpbIsInVB)
DECLARE FUNCTION  IDirectDraw_Initialize (lpDD, lpGUID)
DECLARE FUNCTION  IDirectDraw_RestoreDisplayMode (lpDD)
DECLARE FUNCTION  IDirectDraw_SetCooperativeLevel (lpDD, hWnd, dwFlags)
DECLARE FUNCTION  IDirectDraw_SetDisplayMode (lpDD, dwWidth, dwHeight, dwBpp, dwRefreshRate, dwFlags)
DECLARE FUNCTION  IDirectDraw_WaitForVerticalBlank (lpDD, dwFlags, hEvent)
DECLARE FUNCTION  IDirectDraw_GetAvailableVidMem (lpDD, lpDDSCaps, lpdwTotal, lpdwFree)
DECLARE FUNCTION  IDirectDraw_GetSurfaceFromDC (lpDD, hdc, lpDDS)
DECLARE FUNCTION  IDirectDraw_RestoreAllSurfaces (lpDD)
DECLARE FUNCTION  IDirectDraw_TestCooperativeLevel (lpDD)
DECLARE FUNCTION  IDirectDraw_GetDeviceIdentifier (lpDD, lpdddi, dwFlags)
DECLARE FUNCTION  IDirectDraw_StartModeTest (lpDD, lpModesToTest, dwNumEntries, dwFlags)
DECLARE FUNCTION  IDirectDraw_EvaluateMode (lpDD, dwFlags, lpSecondsUntilTimeout)
'
' interface directdrawpalette methods
'
DECLARE FUNCTION  IDirectDrawPalette_GetCaps (lpDDPalette, lpdwCaps)
DECLARE FUNCTION  IDirectDrawPalette_GetEntries (lpDDPalette, dwFlags, dwBase, dwNumEntries, lpEntries)
DECLARE FUNCTION  IDirectDrawPalette_Initialize (lpDD, dwFlags, lpDDColorTable)
DECLARE FUNCTION  IDirectDrawPalette_SetEntries (lpDDPalette, dwFlags, dwStartingEntry, dwCount, lpEntries)
'
' interface directdrawclipper methods
'
DECLARE FUNCTION  IDirectDrawClipper_GetClipList (lpDDClipper, lpRect, lpClipList, lpdwSize)
DECLARE FUNCTION  IDirectDrawClipper_GetHWnd (lpDDClipper, lphWnd)
DECLARE FUNCTION  IDirectDrawClipper_Initialize (lpDD, dwFlags)
DECLARE FUNCTION  IDirectDrawClipper_IsClipChanged (lpDDClipper, dlpbChanged)
DECLARE FUNCTION  IDirectDrawClipper_SetClipList (lpDDClipper, lpClipList, dwFlags)
DECLARE FUNCTION  IDirectDrawClipper_SetHWnd (lpDDClipper, dwFlags, hWnd)
'
' interface directdrawsurface methods
'
DECLARE FUNCTION  IDirectDrawSurface_AddAttachedSurface (lpDDSurface, lpDDDestSurface)
DECLARE FUNCTION  IDirectDrawSurface_AddOverlayDirtyRect (lpDDSurface, lpRect)
DECLARE FUNCTION  IDirectDrawSurface_Blt (lpDDSurface, lpDestRect, lpDDSrcSurface, lpSrcRect, dwFlags, lpDDBltFx)
DECLARE FUNCTION  IDirectDrawSurface_BltBatch (lpDDSurface, lpDDBltBatch, dwCount, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_BltFast (lpDDSurface, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans)
DECLARE FUNCTION  IDirectDrawSurface_DeleteAttachedSurface (lpDDSurface, dwFlags, lpDDAttachedSurface)
DECLARE FUNCTION  IDirectDrawSurface_EnumAttachedSurfaces (lpDDSurface, lpContext, lpEnumSurfacesCallback)
DECLARE FUNCTION  IDirectDrawSurface_EnumOverlayZOrders (lpDDSurface, dwFlags, lpContext, lpfnCallback)
DECLARE FUNCTION  IDirectDrawSurface_Flip (lpDDSurface, lpDDSurfaceTargetOverride, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_GetAttachedSurface (lpDDSurface, lpDDSCaps, lpDDAttachedSurface)
DECLARE FUNCTION  IDirectDrawSurface_GetBltStatus (lpDDSurface, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_GetCaps (lpDDSurface, lpDDSCaps)
DECLARE FUNCTION  IDirectDrawSurface_GetClipper (lpDDSurface, lpDDClipper)
DECLARE FUNCTION  IDirectDrawSurface_GetColorKey (lpDDSurface, dwFlags, lpDDColorKey)
DECLARE FUNCTION  IDirectDrawSurface_GetDC (lpDDSurface, lphDC)
DECLARE FUNCTION  IDirectDrawSurface_GetFlipStatus (lpDDSurface, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_GetOverlayPosition (lpDDSurface, lplX, lplY)
DECLARE FUNCTION  IDirectDrawSurface_GetPalette (lpDDSurface, lpDDPalette)
DECLARE FUNCTION  IDirectDrawSurface_GetPixelFormat (lpDDSurface, lpDDPixelFormat)
DECLARE FUNCTION  IDirectDrawSurface_GetSurfaceDesc (lpDDSurface, lpDDSurfaceDesc)
DECLARE FUNCTION  IDirectDrawSurface_Initialize (lpDD, lpDDSurfaceDesc)
DECLARE FUNCTION  IDirectDrawSurface_IsLost (lpDDSurface)
DECLARE FUNCTION  IDirectDrawSurface_Lock (lpDDSurface, lpDestRect, lpDDSurfaceDesc, dwFlags, hEvent)
DECLARE FUNCTION  IDirectDrawSurface_ReleaseDC (lpDDSurface, hDC)
DECLARE FUNCTION  IDirectDrawSurface_Restore (lpDDSurface)
DECLARE FUNCTION  IDirectDrawSurface_SetClipper (lpDDSurface, lpDDClipper)
DECLARE FUNCTION  IDirectDrawSurface_SetColorKey (lpDDSurface, dwFlags, lpDDColorKey)
DECLARE FUNCTION  IDirectDrawSurface_SetOverlayPosition (lpDDSurface, lX, lY)
DECLARE FUNCTION  IDirectDrawSurface_SetPalette (lpDDSurface, lpDDPalette)
DECLARE FUNCTION  IDirectDrawSurface_Unlock (lpDDSurface, lpSurfaceData)
DECLARE FUNCTION  IDirectDrawSurface_UpdateOverlay (lpDDSurface, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx)
DECLARE FUNCTION  IDirectDrawSurface_UpdateOverlayDisplay (lpDDSurface, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_UpdateOverlayZOrder (lpDDSurface, dwFlags, lpDDSReference)
DECLARE FUNCTION  IDirectDrawSurface_GetDDInterface (lpDDSurface, lpDD)
DECLARE FUNCTION  IDirectDrawSurface_PageLock (lpDDSurface, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_PageUnlock (lpDDSurface, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_SetSurfaceDesc (lpDDSurface, lpDDSurfaceDesc, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_SetPrivateData (lpDDSurface, guidTag, lpData, cbSize, dwFlags)
DECLARE FUNCTION  IDirectDrawSurface_GetPrivateData (lpDDSurface, guidTag, lpBuffer, lpcbBufferSize)
DECLARE FUNCTION  IDirectDrawSurface_FreePrivateData (lpDDSurface, guidTag)
DECLARE FUNCTION  IDirectDrawSurface_GetUniquenessValue (lpDDSurface, lpValue)
DECLARE FUNCTION  IDirectDrawSurface_ChangeUniquenessValue (lpDDSurface)
DECLARE FUNCTION  IDirectDrawSurface_SetPriority (lpDDSurface, dwPriority)
DECLARE FUNCTION  IDirectDrawSurface_GetPriority (lpDDSurface, lpdwPriority)
DECLARE FUNCTION  IDirectDrawSurface_SetLOD (lpDDSurface, dwMaxLOD)
DECLARE FUNCTION  IDirectDrawSurface_GetLOD (lpDDSurface, lpdwMaxLOD)
'
' interface directdrawcolorcontrol methods
'
DECLARE FUNCTION  IDirectDrawColorControl_GetColorControls (lpDDColorControl, lpColorControl)
DECLARE FUNCTION  IDirectDrawColorControl_SetColorControls (lpDDColorControl, lpColorControl)
'
' interface directdrawgammacontrol methods
'
DECLARE FUNCTION  IDirectDrawGammaControl_GetGammaRamp (lpDDGammaControl, dwFlags, lpRampData)
DECLARE FUNCTION  IDirectDrawGammaControl_SetGammaRamp (lpDDGammaControl, dwFlags, lpRampData)

END EXPORT
'
'
' ####################
' #####  Xdd ()  #####
' ####################
'
'
FUNCTION  Xdd ()

	STATIC init

	IF init THEN RETURN
	init = $$TRUE

	IF XddInitDD () THEN RETURN ($$TRUE)

'	version = XddGetDxVersion (@version$)
'	PRINT "DirectX version="; version, " version$="; version$
'	a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
'
'
' ##########################
' #####  XddInitDD ()  #####
' ##########################
'
FUNCTION  XddInitDD ()

	STATIC entry
	SHARED hddraw
	SHARED initError
	SHARED initDDCreate, initDDCreateEx, initDDCreateClipper
	SHARED initDDEnumerate, initDDEnumerateEx

	SHARED FUNCADDR DDCreate (XLONG, XLONG, XLONG)
	SHARED FUNCADDR DDCreateEx (XLONG, XLONG, XLONG)
	SHARED FUNCADDR DDCreateClipper (XLONG, XLONG, XLONG)
	SHARED FUNCADDR DDEnumerate (XLONG, XLONG)
	SHARED FUNCADDR DDEnumerateEx (XLONG, XLONG, XLONG)

	IF entry THEN RETURN ($$TRUE)
	entry = $$TRUE

' load ddraw.dll library
' need to FreeLibrary (hddraw) somewhere : XddCleanUp()

	hddraw = LoadLibraryA (&"ddraw.dll")
	IFZ hddraw THEN
		error$ = "Error : LoadLibraryA : ddraw.dll"
		GOSUB ErrorFound
	END IF

' get function addresses

	DDCreate = GetProcAddress (hddraw, &"DirectDrawCreate")
	IFZ DDCreate THEN
		error$ = "Error : GetProcAddress : DirectDrawCreate"
		initDDCreate = $$TRUE
		GOSUB ErrorFound
	END IF

	DDCreateEx = GetProcAddress (hddraw, &"DirectDrawCreateEx")
	IFZ DDCreateEx THEN
		error$ = "Error : GetProcAddress : DirectDrawCreateEx"
		initDDCreateEx = $$TRUE
		GOSUB ErrorFound
	END IF

	DDCreateClipper = GetProcAddress (hddraw, &"DirectDrawCreateClipper")
	IFZ DDCreateClipper THEN
		error$ = "Error : GetProcAddress : DirectDrawCreateClipper"
		initDDCreateClipper = $$TRUE
		GOSUB ErrorFound
	END IF

	DDEnumerate = GetProcAddress (hddraw, &"DirectDrawEnumerateA")
	IFZ DDEnumerate THEN
		error$ = "Error : GetProcAddress : DirectDrawEnumerateA"
		initDDEnumerate = $$TRUE
		GOSUB ErrorFound
	END IF

	DDEnumerateEx = GetProcAddress (hddraw, &"DirectDrawEnumerateExA")
	IFZ DDEnumerateEx THEN
		error$ = "Error : GetProcAddress : DirectDrawEnumerateExA"
		initDDEnumerateEx = $$TRUE
		GOSUB ErrorFound
	END IF


' ***** ErrorFound *****
SUB ErrorFound
'	MessageBoxA (NULL, &error$, &"XddInitDD() Error", 0)
	PRINT error$
	initError = $$TRUE
 	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ###########################
' #####  XddCleanUp ()  #####
' ###########################
'
FUNCTION  XddCleanUp ()

	SHARED hddraw

	FreeLibrary (hddraw)

END FUNCTION
'
'
' ##############################
' #####  XddColorMatch ()  #####
' ##############################
'
' PURPOSE : Convert a RGB color to a pysical color.
' We do this by letting GDI SetPixel() do the color matching
' then we lock the memory and see what it got mapped to.
'
FUNCTION  XddColorMatch (pdds, rgb)

	DDSURFACEDESC2 ddsd

	dw = $$CLR_INVALID

'  Use GDI SetPixel to color match for us

	IF ((rgb != $$CLR_INVALID) && (IDirectDrawSurface_GetDC (pdds, &hdc) == $$DD_OK)) THEN
		rgbT = GetPixel (hdc, 0, 0) 				' Save first current pixel value
		SetPixel (hdc, 0, 0, rgb) 					' Set our value
		IDirectDrawSurface_ReleaseDC (pdds, hdc)
	END IF

' Now lock the surface so we can read back the converted color

	ddsd.dwSize = SIZE (ddsd)

	DO
		hres = IDirectDrawSurface_Lock (pdds, NULL, &ddsd, 0, NULL)
	LOOP WHILE hres == $$DDERR_WASSTILLDRAWING

'    while ((hres = pdds->Lock(NULL, &ddsd, 0, NULL)) == DDERR_WASSTILLDRAWING)
'       ;

	IF (hres == $$DD_OK) THEN
'		dw = *(DWORD *) ddsd.lpSurface                 								' Get DWORD
		dw = XLONGAT (ddsd.lpSurface)                 								' Get DWORD
		IF (ddsd.ddpfPixelFormat.dwRGBBitCount < 32) THEN
			dw = dw & ((1 << ddsd.ddpfPixelFormat.dwRGBBitCount) - 1)		' Mask it to bpp
		END IF
		IDirectDrawSurface_Unlock (pdds, NULL)
	END IF

'  Now put the color that was there back.

	IF ((rgb != $$CLR_INVALID) && (IDirectDrawSurface_GetDC (pdds, &hdc) == $$DD_OK)) THEN
		SetPixel (hdc, 0, 0, rgbT)
		IDirectDrawSurface_ReleaseDC (pdds, hdc)
	END IF
	RETURN dw

END FUNCTION
'
'
' ##############################
' #####  XddCopyBitmap ()  #####
' ##############################
'
' PURPOSE	: Draw a bitmap into a DirectDrawSurface
'	IN			: pdds - pointer to a direct draw surface
'					: hbm - bitmap handle
'					: x - x source origin
'					: y - y source origin
'					: dx - width
'					: dy - height
'
FUNCTION  XddCopyBitmap (pdds, hbm, x, y, dx, dy)

	BITMAP bm
	DDSURFACEDESC2 ddsd

	IF (hbm == NULL || pdds == NULL) THEN RETURN ($$TRUE)

' Make sure this surface is restored.

'	pdds->Restore();
	IDirectDrawSurface_Restore (pdds)

' Select bitmap into a memoryDC so we can use it.

	hdcImage = CreateCompatibleDC (NULL)
	IF (!hdcImage) THEN
		PRINT "Error : XddCopyBitmap : CreateCompatibleDC\n"
		RETURN ($$TRUE)
	END IF

	SelectObject (hdcImage, hbm)

' Get size of the bitmap

	GetObjectA (hbm, SIZE (bm), &bm)
	IFZ dx THEN dx = bm.width
	IFZ dy THEN dy = bm.height

' Get size of surface.

	ddsd.dwSize = SIZE (ddsd)
	ddsd.dwFlags = $$DDSD_HEIGHT | $$DDSD_WIDTH

'	pdds->GetSurfaceDesc(&ddsd);
	IDirectDrawSurface_GetSurfaceDesc (pdds, &ddsd)

	hr = IDirectDrawSurface_GetDC (pdds, &hdc)

' if ((hr = pdds->GetDC(&hdc)) == DD_OK)
	IF hr = $$DD_OK THEN
		StretchBlt (hdc, 0, 0, ddsd.dwWidth, ddsd.dwHeight, hdcImage, x, y, dx, dy, $$SRCCOPY)
'		pdds->ReleaseDC(hdc);
		IDirectDrawSurface_ReleaseDC (pdds, hdc)
	END IF

	DeleteDC (hdcImage)
	RETURN hr

END FUNCTION
'
'
' ################################
' #####  XddGetDxVersion ()  #####
' ################################
'
' PURPOSE : This function returns the DirectX version number
' OUT			: version$ - version string
' RETURN  : version number:
'           0x0000 = No DirectX installed
'           0x0100 = DirectX version 1 installed
'           0x0200 = DirectX 2 installed
'           0x0300 = DirectX 3 installed
'           0x0500 = At least DirectX 5 installed.
'           0x0600 = At least DirectX 6 installed.
'           0x0601 = At least DirectX 6.1 installed.
'           0x0700 = At least DirectX 7 installed.
'           0x0800 = At least DirectX 8 installed.
'
FUNCTION  XddGetDxVersion (@version$)

	GUID riid, riid3, riid4, riid7
	FUNCADDR DDrawCreate (XLONG, XLONG, XLONG)
	FUNCADDR DDrawCreateEx (XLONG, XLONG, XLONG, XLONG)
	FUNCADDR DirectInputCreate (XLONG, XLONG, XLONG, XLONG)
	DDSURFACEDESC ddsd
	CLSID clsid
	GUID dmiid

$CLSID_DirectMusic = "\x10\x9F\x6B\x63\x7D\x0C\xD1\x11\x95\xB2\x00\x20\xAF\xDC\x74\x21"
$IID_IDirectMusic = "\x5A\x11\x36\x65\x2D\x7B\xD2\x11\xBA\x18\x00\x00\xF8\x75\xAC\x12"
$CLSCTX_INPROC_SERVER = 1

	version$ = "0.0"

' First see if DDRAW.DLL even exists.
	hDDrawDLL = LoadLibraryA (&"ddraw.dll")
	IF (hDDrawDLL == NULL) THEN
		dwDXVersion = 0
		PRINT "Failure : LoadLibrary DDraw.dll\r\n"
		RETURN dwDXVersion
	END IF

' See if we can create the DirectDraw object.
	DDrawCreate = GetProcAddress (hDDrawDLL, &"DirectDrawCreate")
	IF (DDrawCreate == NULL) THEN
		dwDXVersion = 0
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : GetProcAddress DirectDrawCreate\r\n"
		RETURN dwDXVersion
	END IF

	hr = @DDrawCreate (NULL, &pDDraw, NULL)
	IF hr < 0 THEN
		dwDXVersion = 0
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : DirectDrawCreate\r\n"
		RETURN dwDXVersion
	END IF

' So DirectDraw exists.  We are at least DX1.
	dwDXVersion = 0x100
	version$ = "1.0"

' Let's see if IID_IDirectDraw2 exists.
'	hr = IDirectDraw_QueryInterface (lpIUnknown, riid, ppvObj)
'	hr = pDDraw->QueryInterface (IID_IDirectDraw2, (VOID**)&pDDraw2)

	XLONGAT(&&riid) = &$$IID_IDirectDraw2
	hr = IDirectDraw_QueryInterface (pDDraw, &riid, &pDDraw2)
	IF hr < 0 THEN
' No IDirectDraw2 exists... must be DX1
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : QueryInterface IID_IDirectDraw2\r\n"
		RETURN dwDXVersion
	END IF

' IDirectDraw2 exists. We must be at least DX2
		IDirectDraw_Release (pDDraw2)
		dwDXVersion = 0x200
		version$ = "2.0"

'-------------------------------------------------------------------------
' DirectX 3.0 Checks
'-------------------------------------------------------------------------

' DirectInput was added for DX3
	hDInputDLL = LoadLibraryA (&"DINPUT.DLL")
	IF (hDInputDLL == NULL) THEN
' No DInput... must not be DX3
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : LoadLibrary DInput.dll\r\n"
		RETURN dwDXVersion
	END IF

	DirectInputCreate = GetProcAddress (hDInputDLL, &"DirectInputCreateA")
	IF (DirectInputCreate == NULL) THEN
' No DInput... must be DX2
		FreeLibrary (hDInputDLL)
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : GetProcAddress DirectInputCreateA\r\n"
		RETURN dwDXVersion
	END IF

' DirectInputCreate exists. We are at least DX3
	dwDXVersion = 0x300
	version$ = "3.0"
	FreeLibrary (hDInputDLL)

' Can do checks for 3a vs 3b here

'-------------------------------------------------------------------------
' DirectX 5.0 Checks
'-------------------------------------------------------------------------

' We can tell if DX5 is present by checking for the existence of
' IDirectDrawSurface3. First, we need a surface to QI off of.

	ddsd.dwSize         = SIZE (ddsd)
	ddsd.dwFlags        = $$DDSD_CAPS
	ddsd.ddsCaps.dwCaps = $$DDSCAPS_PRIMARYSURFACE

	hr = IDirectDraw_SetCooperativeLevel (pDDraw, NULL, $$DDSCL_NORMAL)
	IF hr < 0 THEN
' Failure. This means DDraw isn't properly installed.
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		dwDXVersion = 0
		PRINT "Failure : SetCooperativeLevel\r\n"
		RETURN dwDXVersion
	END IF

'    hr = pDDraw->CreateSurface( &ddsd, &pSurf, NULL );
	hr = IDirectDraw_CreateSurface (pDDraw, &ddsd, &pSurf, NULL)
	IF hr < 0 THEN
' Failure. This means DDraw isn't properly installed.
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		dwDXVersion = 0
		PRINT "Failure : CreateSurface\r\n"
		RETURN dwDXVersion
	END IF

' Query for the IDirectDrawSurface3 interface
'	if( FAILED( pSurf->QueryInterface( IID_IDirectDrawSurface3, (VOID**)&pSurf3)))

	XLONGAT(&&riid3) = &$$IID_IDirectDrawSurface3
	hr = IDirectDraw_QueryInterface (pSurf, &riid3, &pSurf3)
	IF hr < 0 THEN
		IDirectDraw_Release (pSurf)
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : QueryInterface DirectDrawSurface3\r\n"
		RETURN dwDXVersion
	END IF

' QI for IDirectDrawSurface3 succeeded. We must be at least DX5
	dwDXVersion = 0x500
	version$ = "5.0"
	IDirectDraw_Release (pSurf3)

'-------------------------------------------------------------------------
' DirectX 6.0 Checks
'-------------------------------------------------------------------------

' The IDirectDrawSurface4 interface was introduced with DX 6.0

	XLONGAT(&&riid4) = &$$IID_IDirectDrawSurface4
	hr = IDirectDraw_QueryInterface (pSurf, &riid3, &pSurf4)
	IF hr < 0 THEN
		IDirectDraw_Release (pSurf)
		IDirectDraw_Release (pDDraw)
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : QueryInterface DirectDrawSurface4\r\n"
		RETURN dwDXVersion
	END IF

' IDirectDrawSurface4 was create successfully. We must be at least DX6
	dwDXVersion = 0x600
	version$ = "6.0"
	IDirectDraw_Release (pSurf4)
	IDirectDraw_Release (pSurf)
	IDirectDraw_Release (pDDraw)

'-------------------------------------------------------------------------
' DirectX 6.1 Checks
'-------------------------------------------------------------------------

' Check for DMusic, which was introduced with DX6.1

	CoInitialize (NULL)

	XLONGAT(&&clsid) = &$CLSID_DirectMusic
	XLONGAT(&&dmiid) = &$IID_IDirectMusic
	hr = CoCreateInstance (&clsid, NULL, $CLSCTX_INPROC_SERVER, &dmiid, &pDMusic)
	IF hr < 0 THEN
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : CoCreateInstance CLSID_DirectMusic\r\n"
		RETURN dwDXVersion
	END IF

' DirectMusic was created successfully. We must be at least DX6.1
	dwDXVersion = 0x601
	version$ = "6.1"
	IDirectDraw_Release (pDMusic)
	CoUninitialize ()

'-------------------------------------------------------------------------
' DirectX 7.0 Checks
'-------------------------------------------------------------------------

' Check for DirectX 7 by creating a DDraw7 object

	DDrawCreateEx = GetProcAddress (hDDrawDLL, &"DirectDrawCreateEx")
	IF (DDrawCreateEx == NULL) THEN
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : GetProcAddress DirectDrawCreateEx\r\n"
		RETURN dwDXVersion
	END IF

	XLONGAT(&&riid7) = &$$IID_IDirectDraw7
	hr = @DDrawCreateEx (NULL, &pDD7, &riid7, NULL)
	IF hr < 0 THEN
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : DirectDrawCreateEx\r\n"
		RETURN dwDXVersion
	END IF

' DDraw7 was created successfully. We must be at least DX7.0
	dwDXVersion = 0x700
	version$ = "7.0"
	IDirectDraw_Release (pDD7)

'-------------------------------------------------------------------------
' DirectX 8.0 Checks
'-------------------------------------------------------------------------

' Simply see if D3D8.dll exists.
	hD3D8DLL = LoadLibraryA (&"D3D8.DLL")
	IF (hD3D8DLL == NULL) THEN
		FreeLibrary (hDDrawDLL)
		PRINT "Failure : LoadLibrary d3d8.dll\r\n"
		RETURN dwDXVersion
	END IF

' D3D8.dll exists. We must be at least DX8.0
	dwDXVersion = 0x800
	version$ = "8.0"

'-------------------------------------------------------------------------
' DirectX 8.1 Checks
'-------------------------------------------------------------------------

' Simply see if dpnhpast.dll exists.
	hDPNHPASTDLL = LoadLibraryA (&"dpnhpast.dll")
	IF (hDPNHPASTDLL == NULL) THEN
		FreeLibrary (hDDrawDLL)
    FreeLibrary (hD3D8DLL)
		PRINT "Failure : LoadLibrary dpnhpast.dll\r\n"
		RETURN dwDXVersion
	END IF

' dpnhpast.dll exists. We must be at least DX8.1
	dwDXVersion = 0x801
	version$ = "8.1"

'-------------------------------------------------------------------------
' End of checking for versions of DirectX
'-------------------------------------------------------------------------

' Close open libraries and return

	FreeLibrary (hD3D8DLL)
	FreeLibrary (hDPNHPASTDLL)
	FreeLibrary (hDDrawDLL)
	RETURN dwDXVersion

END FUNCTION
'
'
' ##############################
' #####  XddLoadBitmap ()  #####
' ##############################
'
' PURPOSE : Create a DirectDrawSurface from a bitmap resource.
' IN			: pDD - direct draw pointer
'					: lpszBitmap - address to bitmap name string
'					: dx - desired width
'					: dy - desired height
' RETURN	: pointer to a surface or NULL on failure
'
FUNCTION  XddLoadBitmap (pDD, bitmap$, dx, dy)

	BITMAP	bm
	DDSURFACEDESC2 ddsd

'  Try to load the bitmap as a resource, if that fails, try it as a file

	hbm = LoadImageA (GetModuleHandleA (NULL), &bitmap$, $$IMAGE_BITMAP, dx, dy, $$LR_CREATEDIBSECTION)
	IF (hbm == NULL) THEN
		hbm = LoadImageA (NULL, &bitmap$, $$IMAGE_BITMAP, dx, dy, $$LR_LOADFROMFILE | $$LR_CREATEDIBSECTION)
		IF (hbm == NULL) THEN RETURN (NULL)
	END IF

' Get size of the bitmap

	GetObjectA (hbm, SIZE (bm), &bm)

' Create a DirectDrawSurface for this bitmap

	ddsd.dwSize = SIZE (ddsd)
	ddsd.dwFlags = $$DDSD_CAPS | $$DDSD_HEIGHT | $$DDSD_WIDTH
	ddsd.ddsCaps.dwCaps = $$DDSCAPS_OFFSCREENPLAIN
	ddsd.dwWidth = bm.width
	ddsd.dwHeight = bm.height

	IF (IDirectDraw_CreateSurface (pDD, &ddsd, &pdds, NULL)) != $$DD_OK THEN RETURN (NULL)

	XddCopyBitmap (pdds, hbm, 0, 0, 0, 0)

	DeleteObject (hbm)
	RETURN pdds


END FUNCTION
'
'
' ###############################
' #####  XddSetColorKey ()  #####
' ###############################
'
' PURPOSE	: Set a color key for a surface, given a RGB.
' If you pass CLR_INVALID as the color key, the pixel
' in the upper-left corner will be used.
'
FUNCTION  XddSetColorKey (pdds, rgb)

	DDCOLORKEY ddck

	ddck.dwColorSpaceLowValue = XddColorMatch (pdds, rgb)
	ddck.dwColorSpaceHighValue = ddck.dwColorSpaceLowValue

	RETURN IDirectDrawSurface_SetColorKey (pdds, $$DDCKEY_SRCBLT, &ddck)
'	return pdds->SetColorKey(DDCKEY_SRCBLT, &ddck);


END FUNCTION
'
'
' ####################################
' #####  XddDirectDrawCreate ()  #####
' ####################################
'
FUNCTION  XddDirectDrawCreate (lpGUID, lpDD, pUnkOuter)

	SHARED FUNCADDR DDCreate (XLONG, XLONG, XLONG)
	SHARED initError, initDDCreate

	IF initError THEN RETURN ($$TRUE)
	IF initDDCreate THEN RETURN ($$TRUE)
	RETURN @DDCreate (lpGUID, lpDD, pUnkOuter)

END FUNCTION
'
'
' ###########################################
' #####  XddDirectDrawCreateClipper ()  #####
' ###########################################
'
FUNCTION  XddDirectDrawCreateClipper (dwFlags, lpDDClipper, pUnkOuter)

	SHARED FUNCADDR DDCreateClipper (XLONG, XLONG, XLONG)
	SHARED initError, initDDCreateClipper

	IF initError THEN RETURN ($$TRUE)
	IF initDDCreateClipper THEN RETURN ($$TRUE)
	RETURN @DDCreateClipper (dwFlags, lpDDClipper, pUnkOuter)

END FUNCTION
'
'
' #######################################
' #####  XddDirectDrawEnumerate ()  #####
' #######################################
'
FUNCTION  XddDirectDrawEnumerate (lpCallback, lpContext)

	SHARED FUNCADDR DDEnumerate (XLONG, XLONG)
	SHARED initError, initDDEnumerate

	IF initError THEN RETURN ($$TRUE)
	IF initDDEnumerate THEN RETURN ($$TRUE)
	RETURN @DDEnumerate (lpCallback, lpContext)

END FUNCTION
'
'
' #########################################
' #####  XddDirectDrawEnumerateEx ()  #####
' #########################################
'
FUNCTION  XddDirectDrawEnumerateEx (lpCallback, lpContext, dwFlags)

	SHARED FUNCADDR DDEnumerateEx (XLONG, XLONG, XLONG)
	SHARED initError, initDDEnumerateEx

	IF initError THEN RETURN ($$TRUE)
	IF initDDEnumerateEx THEN RETURN ($$TRUE)
	RETURN @DDEnumerateEx (lpCallback, lpContext, dwFlags)

END FUNCTION
'
'
' ####################################
' #####  XddDirectDrawCreate ()  #####
' ####################################
'
FUNCTION  XddDirectDrawCreateEx (lpGuid, lpDD, iid, pUnkOuter)

	SHARED FUNCADDR DDCreateEx (XLONG, XLONG, XLONG, XLONG)
	SHARED initError, initDDCreateEx

	IF initError THEN RETURN ($$TRUE)
	IF initDDCreateEx THEN RETURN ($$TRUE)
	RETURN @DDCreateEx (lpGuid, lpDD, iid, pUnkOuter)

END FUNCTION
'
'
' ###########################################
' #####  IDirectDraw_QueryInterface ()  #####
' ###########################################
'
FUNCTION  IDirectDraw_QueryInterface (lpIUnknown, riid, ppvObj)

	FUNCADDR QueryInterface (XLONG, XLONG, XLONG)

	vtblAddr       = XLONGAT (lpIUnknown)
	QueryInterface = XLONGAT (vtblAddr)
	IFZ QueryInterface THEN RETURN ($$TRUE)

	RETURN @QueryInterface (lpIUnknown, riid, ppvObj)

END FUNCTION
'
'
' ###################################
' #####  IDirectDraw_AddRef ()  #####
' ###################################
'
FUNCTION  IDirectDraw_AddRef (lpIUnknown)

	FUNCADDR AddRef (XLONG)

	vtblAddr	= XLONGAT (lpIUnknown)
	AddRef		= XLONGAT (vtblAddr + 0x04)
	IFZ AddRef THEN RETURN ($$TRUE)

	RETURN @AddRef (lpIUnknown)

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
' ####################################
' #####  IDirectDraw_Release ()  #####
' ####################################
'
FUNCTION  IDirectDraw_Compact (lpDD)

	FUNCADDR Compact (XLONG)

	vtblAddr	= XLONGAT (lpDD)
	Compact		= XLONGAT (vtblAddr + 0x0C)
	IFZ Compact THEN RETURN ($$TRUE)

	RETURN @Compact (lpDD)

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
' ##########################################
' #####  IDirectDraw_CreatePalette ()  #####
' ##########################################
'
FUNCTION  IDirectDraw_CreatePalette (lpDD, lpColorTable, lpDDPalette, pUnkOuter, flag)

	FUNCADDR CreatePalette (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	CreatePalette	= XLONGAT (vtblAddr + 0x14)
	IFZ CreatePalette THEN RETURN ($$TRUE)

	RETURN @CreatePalette (lpDD, lpColorTable, lpDDPalette, pUnkOuter, flag)

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
' #############################################
' #####  IDirectDraw_DuplicateSurface ()  #####
' #############################################
'
FUNCTION  IDirectDraw_DuplicateSurface (lpDD, lpDDSurface, lpDupDDSurface)

	FUNCADDR DuplicateSurface (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	DuplicateSurface	= XLONGAT (vtblAddr + 0x1C)
	IFZ DuplicateSurface THEN RETURN ($$TRUE)

	RETURN @DuplicateSurface (lpDD, lpDDSurface, lpDupDDSurface)

END FUNCTION
'
'
' #############################################
' #####  IDirectDraw_EnumDisplayModes ()  #####
' #############################################
'
FUNCTION  IDirectDraw_EnumDisplayModes (lpDD, dwFlags, lpDDSurfaceDesc, lpContext, lpEnumModesCallback)

	FUNCADDR EnumDisplayModes (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	EnumDisplayModes	= XLONGAT (vtblAddr + 0x20)
	IFZ EnumDisplayModes THEN RETURN ($$TRUE)

	RETURN @EnumDisplayModes (lpDD, dwFlags, lpDDSurfaceDesc, lpContext, lpEnumModesCallback)

END FUNCTION
'
'
' #########################################
' #####  IDirectDraw_EnumSurfaces ()  #####
' #########################################
'
FUNCTION  IDirectDraw_EnumSurfaces (lpDD, dwFlags, lpDDSurfaceDesc, lpContext, lpEnumModesCallback)

	FUNCADDR EnumSurfaces (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	EnumSurfaces	= XLONGAT (vtblAddr + 0x24)
	IFZ EnumSurfaces THEN RETURN ($$TRUE)

	RETURN @EnumSurfaces (lpDD, dwFlags, lpDDSurfaceDesc, lpContext, lpEnumModesCallback)

END FUNCTION
'
'
' #############################################
' #####  IDirectDraw_FlipToGDISurface ()  #####
' #############################################
'
FUNCTION  IDirectDraw_FlipToGDISurface (lpDD)

	FUNCADDR FlipToGDISurface (XLONG)

	vtblAddr = XLONGAT (lpDD)
	FlipToGDISurface	= XLONGAT (vtblAddr + 0x28)
	IFZ FlipToGDISurface THEN RETURN ($$TRUE)

	RETURN @FlipToGDISurface (lpDD)

END FUNCTION
'
'
' ####################################
' #####  IDirectDraw_GetCaps ()  #####
' ####################################
'
FUNCTION  IDirectDraw_GetCaps (lpDD, lpDDDriverCaps, lpDDHELCaps)

	FUNCADDR GetCaps (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetCaps	= XLONGAT (vtblAddr + 0x2C)
	IFZ GetCaps THEN RETURN ($$TRUE)

	RETURN @GetCaps (lpDD, lpDDDriverCaps, lpDDHELCaps)

END FUNCTION
'
'
' ###########################################
' #####  IDirectDraw_GetDisplayMode ()  #####
' ###########################################
'
FUNCTION  IDirectDraw_GetDisplayMode (lpDD, lpDDSurfaceDesc)

	FUNCADDR GetDisplayMode (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetDisplayMode	= XLONGAT (vtblAddr + 0x30)
	IFZ GetDisplayMode THEN RETURN ($$TRUE)

	RETURN @GetDisplayMode (lpDD, lpDDSurfaceDesc)

END FUNCTION
'
'
' ###########################################
' #####  IDirectDraw_GetFourCCCodes ()  #####
' ###########################################
'
FUNCTION  IDirectDraw_GetFourCCCodes (lpDD, lpNumCodes, lpCodes)

	FUNCADDR GetFourCCCodes (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetFourCCCodes	= XLONGAT (vtblAddr + 0x34)
	IFZ GetFourCCCodes THEN RETURN ($$TRUE)

	RETURN @GetFourCCCodes (lpDD, lpNumCodes, lpCodes)

END FUNCTION
'
'
' ##########################################
' #####  IDirectDraw_GetGDISurface ()  #####
' ##########################################
'
FUNCTION  IDirectDraw_GetGDISurface (lpDD, lpGDIDSSurface)

	FUNCADDR GetGDISurface (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetGDISurface	= XLONGAT (vtblAddr + 0x38)
	IFZ GetGDISurface THEN RETURN ($$TRUE)

	RETURN @GetGDISurface (lpDD, lpGDIDSSurface)

END FUNCTION
'
'
' #############################################
' #####  IDirectDraw_MonitorFrequency ()  #####
' #############################################
'
FUNCTION  IDirectDraw_MonitorFrequency (lpDD, lpdwFrequency)

	FUNCADDR MonitorFrequency (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	MonitorFrequency	= XLONGAT (vtblAddr + 0x3C)
	IFZ MonitorFrequency THEN RETURN ($$TRUE)

	RETURN @MonitorFrequency (lpDD, lpdwFrequency)

END FUNCTION
'
'
' ########################################
' #####  IDirectDraw_GetScanLine ()  #####
' ########################################
'
FUNCTION  IDirectDraw_GetScanLine (lpDD, lpdwScanLine)

	FUNCADDR GetScanLine (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetScanLine	= XLONGAT (vtblAddr + 0x40)
	IFZ GetScanLine THEN RETURN ($$TRUE)

	RETURN @GetScanLine (lpDD, lpdwScanLine)

END FUNCTION
'
'
' ###################################################
' #####  IDirectDraw_GetVerticalBlankStatus ()  #####
' ###################################################
'
FUNCTION  IDirectDraw_GetVerticalBlankStatus (lpDD, lpbIsInVB)

	FUNCADDR GetVerticalBlankStatus (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetVerticalBlankStatus	= XLONGAT (vtblAddr + 0x44)
	IFZ GetVerticalBlankStatus THEN RETURN ($$TRUE)

	RETURN @GetVerticalBlankStatus (lpDD, lpbIsInVB)

END FUNCTION
'
'
' #######################################
' #####  IDirectDraw_Initialize ()  #####
' #######################################
'
FUNCTION  IDirectDraw_Initialize (lpDD, lpGUID)

	FUNCADDR Initialize (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	Initialize	= XLONGAT (vtblAddr + 0x48)
	IFZ Initialize THEN RETURN ($$TRUE)

	RETURN @Initialize (lpDD, lpGUID)

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
' #################################################
' #####  IDirectDraw_WaitForVerticalBlank ()  #####
' #################################################
'
FUNCTION  IDirectDraw_WaitForVerticalBlank (lpDD, dwFlags, hEvent)

	FUNCADDR WaitForVerticalBlank (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	WaitForVerticalBlank	= XLONGAT (vtblAddr + 0x58)
	IFZ WaitForVerticalBlank THEN RETURN ($$TRUE)

	RETURN @WaitForVerticalBlank (lpDD, dwFlags, hEvent)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDraw_GetAvailableVidMem ()  #####
' ###############################################
'
FUNCTION  IDirectDraw_GetAvailableVidMem (lpDD, lpDDSCaps, lpdwTotal, lpdwFree)

	FUNCADDR GetAvailableVidMem (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetAvailableVidMem	= XLONGAT (vtblAddr + 0x5C)
	IFZ GetAvailableVidMem THEN RETURN ($$TRUE)

	RETURN @GetAvailableVidMem (lpDD, lpDDSCaps, lpdwTotal, lpdwFree)

END FUNCTION
'
'
' #############################################
' #####  IDirectDraw_GetSurfaceFromDC ()  #####
' #############################################
'
FUNCTION  IDirectDraw_GetSurfaceFromDC (lpDD, hdc, lpDDS)

	FUNCADDR GetSurfaceFromDC (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetSurfaceFromDC	= XLONGAT (vtblAddr + 0x60)
	IFZ GetSurfaceFromDC THEN RETURN ($$TRUE)

	RETURN @GetSurfaceFromDC (lpDD, hdc, lpDDS)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDraw_RestoreAllSurfaces ()  #####
' ###############################################
'
FUNCTION  IDirectDraw_RestoreAllSurfaces (lpDD)

	FUNCADDR RestoreAllSurfaces (XLONG)

	vtblAddr = XLONGAT (lpDD)
	RestoreAllSurfaces	= XLONGAT (vtblAddr + 0x64)
	IFZ RestoreAllSurfaces THEN RETURN ($$TRUE)

	RETURN @RestoreAllSurfaces (lpDD)

END FUNCTION
'
'
' #################################################
' #####  IDirectDraw_TestCooperativeLevel ()  #####
' #################################################
'
FUNCTION  IDirectDraw_TestCooperativeLevel (lpDD)

	FUNCADDR TestCooperativeLevel (XLONG)

	vtblAddr = XLONGAT (lpDD)
	TestCooperativeLevel	= XLONGAT (vtblAddr + 0x68)
	IFZ TestCooperativeLevel THEN RETURN ($$TRUE)

	RETURN @TestCooperativeLevel (lpDD)

END FUNCTION
'
'
' ################################################
' #####  IDirectDraw_GetDeviceIdentifier ()  #####
' ################################################
'
FUNCTION  IDirectDraw_GetDeviceIdentifier (lpDD, lpdddi, dwFlags)

	FUNCADDR GetDeviceIdentifier (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	GetDeviceIdentifier	= XLONGAT (vtblAddr + 0x6C)
	IFZ GetDeviceIdentifier THEN RETURN ($$TRUE)

	RETURN @GetDeviceIdentifier (lpDD, lpdddi, dwFlags)

END FUNCTION
'
'
' ##########################################
' #####  IDirectDraw_StartModeTest ()  #####
' ##########################################
'
FUNCTION  IDirectDraw_StartModeTest (lpDD, lpModesToTest, dwNumEntries, dwFlags)

	FUNCADDR StartModeTest (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	StartModeTest	= XLONGAT (vtblAddr + 0x70)
	IFZ StartModeTest THEN RETURN ($$TRUE)

	RETURN @StartModeTest (lpDD, lpModesToTest, dwNumEntries, dwFlags)

END FUNCTION
'
'
' #########################################
' #####  IDirectDraw_EvaluateMode ()  #####
' #########################################
'
FUNCTION  IDirectDraw_EvaluateMode (lpDD, dwFlags, lpSecondsUntilTimeout)

	FUNCADDR EvaluateMode (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	EvaluateMode	= XLONGAT (vtblAddr + 0x74)
	IFZ EvaluateMode THEN RETURN ($$TRUE)

	RETURN @EvaluateMode (lpDD, dwFlags, lpSecondsUntilTimeout)

END FUNCTION
'
'
' ###########################################
' #####  IDirectDrawPalette_GetCaps ()  #####
' ###########################################
'
FUNCTION  IDirectDrawPalette_GetCaps (lpDDPalette, lpdwCaps)

	FUNCADDR GetCaps (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDPalette)
	GetCaps	= XLONGAT (vtblAddr + 0x0C)
	IFZ GetCaps THEN RETURN ($$TRUE)

	RETURN @GetCaps (lpDDPalette, lpdwCaps)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawPalette_GetEntries ()  #####
' ##############################################
'
FUNCTION  IDirectDrawPalette_GetEntries (lpDDPalette, dwFlags, dwBase, dwNumEntries, lpEntries)

	FUNCADDR GetEntries (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDPalette)
	GetEntries	= XLONGAT (vtblAddr + 0x10)
	IFZ GetEntries THEN RETURN ($$TRUE)

	RETURN @GetEntries (lpDDPalette, dwFlags, dwBase, dwNumEntries, lpEntries)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawPalette_Initialize ()  #####
' ##############################################
'
FUNCTION  IDirectDrawPalette_Initialize (lpDD, dwFlags, lpDDColorTable)

	FUNCADDR Initialize (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	Initialize	= XLONGAT (vtblAddr + 0x14)
	IFZ Initialize THEN RETURN ($$TRUE)

	RETURN @Initialize (lpDD, dwFlags, lpDDColorTable)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawPalette_SetEntries ()  #####
' ##############################################
'
FUNCTION  IDirectDrawPalette_SetEntries (lpDDPalette, dwFlags, dwStartingEntry, dwCount, lpEntries)

	FUNCADDR SetEntries (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDPalette)
	SetEntries	= XLONGAT (vtblAddr + 0x18)
	IFZ SetEntries THEN RETURN ($$TRUE)

	RETURN @SetEntries (lpDDPalette, dwFlags, dwStartingEntry, dwCount, lpEntries)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDrawClipper_GetClipList ()  #####
' ###############################################
'
FUNCTION  IDirectDrawClipper_GetClipList (lpDDClipper, lpRect, lpClipList, lpdwSize)

	FUNCADDR GetClipList (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDClipper)
	GetClipList	= XLONGAT (vtblAddr + 0x0C)
	IFZ GetClipList THEN RETURN ($$TRUE)

	RETURN @GetClipList (lpDDClipper, lpRect, lpClipList, lpdwSize)

END FUNCTION
'
'
' ###########################################
' #####  IDirectDrawClipper_GetHWnd ()  #####
' ###########################################
'
FUNCTION  IDirectDrawClipper_GetHWnd (lpDDClipper, lphWnd)

	FUNCADDR GetHWnd (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDClipper)
	GetHWnd	= XLONGAT (vtblAddr + 0x10)
	IFZ GetHWnd THEN RETURN ($$TRUE)

	RETURN @GetHWnd (lpDDClipper, lphWnd)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawClipper_Initialize ()  #####
' ##############################################
'
FUNCTION  IDirectDrawClipper_Initialize (lpDD, dwFlags)

	FUNCADDR Initialize (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	Initialize	= XLONGAT (vtblAddr + 0x14)
	IFZ Initialize THEN RETURN ($$TRUE)

	RETURN @Initialize (lpDD, dwFlags)

END FUNCTION
'
'
' #################################################
' #####  IDirectDrawClipper_IsClipChanged ()  #####
' #################################################
'
FUNCTION  IDirectDrawClipper_IsClipChanged (lpDDClipper, dlpbChanged)

	FUNCADDR IsClipChanged (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDClipper)
	IsClipChanged	= XLONGAT (vtblAddr + 0x18)
	IFZ IsClipChanged THEN RETURN ($$TRUE)

	RETURN @IsClipChanged (lpDDClipper, dlpbChanged)

END FUNCTION
'
'
' #################################################
' #####  IDirectDrawClipper_SetClipList ()  #######
' #################################################
'
FUNCTION  IDirectDrawClipper_SetClipList (lpDDClipper, lpClipList, dwFlags)

	FUNCADDR SetClipList (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDClipper)
	SetClipList	= XLONGAT (vtblAddr + 0x1C)
	IFZ SetClipList THEN RETURN ($$TRUE)

	RETURN @SetClipList (lpDDClipper, lpClipList, dwFlags)

END FUNCTION
'
'
' #############################################
' #####  IDirectDrawClipper_SetHWnd ()  #######
' #############################################
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
' ########################################################
' #####  IDirectDrawSurface_AddAttachedSurface ()  #######
' ########################################################
'
FUNCTION  IDirectDrawSurface_AddAttachedSurface (lpDDSurface, lpDDDestSurface)

	FUNCADDR AddAttachedSurface (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	AddAttachedSurface	= XLONGAT (vtblAddr + 0x0C)
	IFZ AddAttachedSurface THEN RETURN ($$TRUE)

	RETURN @AddAttachedSurface (lpDDSurface, lpDDDestSurface)

END FUNCTION
'
'
' ########################################################
' #####  IDirectDrawSurface_AddOverlayDirtyRect ()  ######
' ########################################################
'
FUNCTION  IDirectDrawSurface_AddOverlayDirtyRect (lpDDSurface, lpRect)

	FUNCADDR AddOverlayDirtyRect (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	AddOverlayDirtyRect	= XLONGAT (vtblAddr + 0x10)
	IFZ AddOverlayDirtyRect THEN RETURN ($$TRUE)

	RETURN @AddOverlayDirtyRect (lpDDSurface, lpRect)

END FUNCTION
'
'
' ########################################
' #####  IDirectDrawSurface_Blt ()  ######
' ########################################
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
' #############################################
' #####  IDirectDrawSurface_BltBatch ()  ######
' #############################################
'
FUNCTION  IDirectDrawSurface_BltBatch (lpDDSurface, lpDDBltBatch, dwCount, dwFlags)

	FUNCADDR BltBatch (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	BltBatch	= XLONGAT (vtblAddr + 0x18)
	IFZ BltBatch THEN RETURN ($$TRUE)

	RETURN @BltBatch (lpDDSurface, lpDDBltBatch, dwCount, dwFlags)

END FUNCTION
'
'
' ############################################
' #####  IDirectDrawSurface_BltFast ()  ######
' ############################################
'
FUNCTION  IDirectDrawSurface_BltFast (lpDDSurface, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans)

	FUNCADDR BltFast (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	BltFast	= XLONGAT (vtblAddr + 0x1C)
	IFZ BltFast THEN RETURN ($$TRUE)

	RETURN @BltFast (lpDDSurface, dwX, dwY, lpDDSrcSurface, lpSrcRect, dwTrans)

END FUNCTION
'
'
' ##########################################################
' #####  IDirectDrawSurface_DeleteAttachedSurface ()  ######
' ##########################################################
'
FUNCTION  IDirectDrawSurface_DeleteAttachedSurface (lpDDSurface, dwFlags, lpDDAttachedSurface)

	FUNCADDR DeleteAttachedSurface (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	DeleteAttachedSurface	= XLONGAT (vtblAddr + 0x20)
	IFZ DeleteAttachedSurface THEN RETURN ($$TRUE)

	RETURN @DeleteAttachedSurface (lpDDSurface, dwFlags, lpDDAttachedSurface)

END FUNCTION
'
'
' #########################################################
' #####  IDirectDrawSurface_EnumAttachedSurfaces ()  ######
' #########################################################
'
FUNCTION  IDirectDrawSurface_EnumAttachedSurfaces (lpDDSurface, lpContext, lpEnumSurfacesCallback)

	FUNCADDR EnumAttachedSurfaces (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	EnumAttachedSurfaces	= XLONGAT (vtblAddr + 0x24)
	IFZ EnumAttachedSurfaces THEN RETURN ($$TRUE)

	RETURN @EnumAttachedSurfaces (lpDDSurface, lpContext, lpEnumSurfacesCallback)

END FUNCTION
'
'
' #######################################################
' #####  IDirectDrawSurface_EnumOverlayZOrders ()  ######
' #######################################################
'
FUNCTION  IDirectDrawSurface_EnumOverlayZOrders (lpDDSurface, dwFlags, lpContext, lpfnCallback)

	FUNCADDR EnumOverlayZOrders (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	EnumOverlayZOrders	= XLONGAT (vtblAddr + 0x28)
	IFZ EnumOverlayZOrders THEN RETURN ($$TRUE)

	RETURN @EnumOverlayZOrders (lpDDSurface, dwFlags, lpContext, lpfnCallback)

END FUNCTION
'
'
' #########################################
' #####  IDirectDrawSurface_Flip ()  ######
' #########################################
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
' #######################################################
' #####  IDirectDrawSurface_GetAttachedSurface ()  ######
' #######################################################
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
' #################################################
' #####  IDirectDrawSurface_GetBltStatus ()  ######
' #################################################
'
FUNCTION  IDirectDrawSurface_GetBltStatus (lpDDSurface, dwFlags)

	FUNCADDR GetBltStatus (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetBltStatus	= XLONGAT (vtblAddr + 0x34)
	IFZ GetBltStatus THEN RETURN ($$TRUE)

	RETURN @GetBltStatus (lpDDSurface, dwFlags)

END FUNCTION
'
'
' ############################################
' #####  IDirectDrawSurface_GetCaps ()  ######
' ############################################
'
FUNCTION  IDirectDrawSurface_GetCaps (lpDDSurface, lpDDSCaps)

	FUNCADDR GetCaps (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetCaps	= XLONGAT (vtblAddr + 0x38)
	IFZ GetCaps THEN RETURN ($$TRUE)

	RETURN @GetCaps (lpDDSurface, lpDDSCaps)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDrawSurface_GetClipper ()  ######
' ###############################################
'
FUNCTION  IDirectDrawSurface_GetClipper (lpDDSurface, lpDDClipper)

	FUNCADDR GetClipper (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetClipper	= XLONGAT (vtblAddr + 0x3C)
	IFZ GetClipper THEN RETURN ($$TRUE)

	RETURN @GetClipper (lpDDSurface, lpDDClipper)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDrawSurface_GetColorKey ()  #####
' ###############################################
'
FUNCTION  IDirectDrawSurface_GetColorKey (lpDDSurface, dwFlags, lpDDColorKey)

	FUNCADDR GetColorKey (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetColorKey	= XLONGAT (vtblAddr + 0x40)
	IFZ GetColorKey THEN RETURN ($$TRUE)

	RETURN @GetColorKey (lpDDSurface, dwFlags, lpDDColorKey)

END FUNCTION
'
'
' #########################################
' #####  IDirectDrawSurface_GetDC ()  #####
' #########################################
'
FUNCTION  IDirectDrawSurface_GetDC (lpDDSurface, lphDC)

	FUNCADDR GetDC (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetDC	= XLONGAT (vtblAddr + 0x44)
	IFZ GetDC THEN RETURN ($$TRUE)

	RETURN @GetDC (lpDDSurface, lphDC)

END FUNCTION
'
'
' #################################################
' #####  IDirectDrawSurface_GetFlipStatus ()  #####
' #################################################
'
FUNCTION  IDirectDrawSurface_GetFlipStatus (lpDDSurface, dwFlags)

	FUNCADDR GetFlipStatus (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetFlipStatus	= XLONGAT (vtblAddr + 0x48)
	IFZ GetFlipStatus THEN RETURN ($$TRUE)

	RETURN @GetFlipStatus (lpDDSurface, dwFlags)

END FUNCTION
'
'
' ######################################################
' #####  IDirectDrawSurface_GetOverlayPosition ()  #####
' ######################################################
'
FUNCTION  IDirectDrawSurface_GetOverlayPosition (lpDDSurface, lplX, lplY)

	FUNCADDR GetOverlayPosition (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetOverlayPosition	= XLONGAT (vtblAddr + 0x4C)
	IFZ GetOverlayPosition THEN RETURN ($$TRUE)

	RETURN @GetOverlayPosition (lpDDSurface, lplX, lplY)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawSurface_GetPalette ()  #####
' ##############################################
'
FUNCTION  IDirectDrawSurface_GetPalette (lpDDSurface, lpDDPalette)

	FUNCADDR GetPalette (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetPalette	= XLONGAT (vtblAddr + 0x50)
	IFZ GetPalette THEN RETURN ($$TRUE)

	RETURN @GetPalette (lpDDSurface, lpDDPalette)

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
' ##################################################
' #####  IDirectDrawSurface_GetSurfaceDesc ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_GetSurfaceDesc (lpDDSurface, lpDDSurfaceDesc)

	FUNCADDR GetSurfaceDesc (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetSurfaceDesc	= XLONGAT (vtblAddr + 0x58)
	IFZ GetSurfaceDesc THEN RETURN ($$TRUE)

	RETURN @GetSurfaceDesc (lpDDSurface, lpDDSurfaceDesc)

END FUNCTION
'
'
' ##################################################
' #####  IDirectDrawSurface_Initialize ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_Initialize (lpDD, lpDDSurfaceDesc)

	FUNCADDR Initialize (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDD)
	Initialize	= XLONGAT (vtblAddr + 0x5C)
	IFZ Initialize THEN RETURN ($$TRUE)

	RETURN @Initialize (lpDD, lpDDSurfaceDesc)

END FUNCTION
'
'
' ##########################################
' #####  IDirectDrawSurface_IsLost ()  #####
' ##########################################
'
FUNCTION  IDirectDrawSurface_IsLost (lpDDSurface)

	FUNCADDR IsLost (XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	IsLost	= XLONGAT (vtblAddr + 0x60)
	IFZ IsLost THEN RETURN ($$TRUE)

	RETURN @IsLost (lpDDSurface)

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
'
'
' #############################################
' #####  IDirectDrawSurface_ReleaseDC ()  #####
' #############################################
'
FUNCTION  IDirectDrawSurface_ReleaseDC (lpDDSurface, hDC)

	FUNCADDR ReleaseDC (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	ReleaseDC	= XLONGAT (vtblAddr + 0x68)
	IFZ ReleaseDC THEN RETURN ($$TRUE)

	RETURN @ReleaseDC (lpDDSurface, hDC)

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
' ###############################################
' #####  IDirectDrawSurface_SetColorKey ()  #####
' ###############################################
'
FUNCTION  IDirectDrawSurface_SetColorKey (lpDDSurface, dwFlags, lpDDColorKey)

	FUNCADDR SetColorKey (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetColorKey	= XLONGAT (vtblAddr + 0x74)
	IFZ SetColorKey THEN RETURN ($$TRUE)

	RETURN @SetColorKey (lpDDSurface, dwFlags, lpDDColorKey)

END FUNCTION
'
'
' ######################################################
' #####  IDirectDrawSurface_SetOverlayPosition ()  #####
' ######################################################
'
FUNCTION  IDirectDrawSurface_SetOverlayPosition (lpDDSurface, lX, lY)

	FUNCADDR SetOverlayPosition (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetOverlayPosition	= XLONGAT (vtblAddr + 0x78)
	IFZ SetOverlayPosition THEN RETURN ($$TRUE)

	RETURN @SetOverlayPosition (lpDDSurface, lX, lY)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawSurface_SetPalette ()  #####
' ##############################################
'
FUNCTION  IDirectDrawSurface_SetPalette (lpDDSurface, lpDDPalette)

	FUNCADDR SetPalette (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetPalette	= XLONGAT (vtblAddr + 0x7C)
	IFZ SetPalette THEN RETURN ($$TRUE)

	RETURN @SetPalette (lpDDSurface, lpDDPalette)

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
' #################################################
' #####  IDirectDrawSurface_UpdateOverlay ()  #####
' #################################################
'
FUNCTION  IDirectDrawSurface_UpdateOverlay (lpDDSurface, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx)

	FUNCADDR UpdateOverlay (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	UpdateOverlay	= XLONGAT (vtblAddr + 0x84)
	IFZ UpdateOverlay THEN RETURN ($$TRUE)

	RETURN @UpdateOverlay (lpDDSurface, lpSrcRect, lpDDDestSurface, lpDestRect, dwFlags, lpDDOverlayFx)

END FUNCTION
'
'
' ########################################################
' #####  IDirectDrawSurface_UpdateOverlayDisplay ()  #####
' ########################################################
'
FUNCTION  IDirectDrawSurface_UpdateOverlayDisplay (lpDDSurface, dwFlags)

	FUNCADDR UpdateOverlayDisplay (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	UpdateOverlayDisplay	= XLONGAT (vtblAddr + 0x88)
	IFZ UpdateOverlayDisplay THEN RETURN ($$TRUE)

	RETURN @UpdateOverlayDisplay (lpDDSurface, dwFlags)

END FUNCTION
'
'
' #######################################################
' #####  IDirectDrawSurface_UpdateOverlayZOrder ()  #####
' #######################################################
'
FUNCTION  IDirectDrawSurface_UpdateOverlayZOrder (lpDDSurface, dwFlags, lpDDSReference)

	FUNCADDR UpdateOverlayZOrder (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	UpdateOverlayZOrder	= XLONGAT (vtblAddr + 0x8C)
	IFZ UpdateOverlayZOrder THEN RETURN ($$TRUE)

	RETURN @UpdateOverlayZOrder (lpDDSurface, dwFlags, lpDDSReference)

END FUNCTION
'
'
' ##################################################
' #####  IDirectDrawSurface_GetDDInterface ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_GetDDInterface (lpDDSurface, lpDD)

	FUNCADDR GetDDInterface (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetDDInterface	= XLONGAT (vtblAddr + 0x90)
	IFZ GetDDInterface THEN RETURN ($$TRUE)

	RETURN @GetDDInterface (lpDDSurface, lpDD)

END FUNCTION
'
'
' ############################################
' #####  IDirectDrawSurface_PageLock ()  #####
' ############################################
'
FUNCTION  IDirectDrawSurface_PageLock (lpDDSurface, dwFlags)

	FUNCADDR PageLock (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	PageLock	= XLONGAT (vtblAddr + 0x94)
	IFZ PageLock THEN RETURN ($$TRUE)

	RETURN @PageLock (lpDDSurface, dwFlags)

END FUNCTION
'
'
' ##############################################
' #####  IDirectDrawSurface_PageUnlock ()  #####
' ##############################################
'
FUNCTION  IDirectDrawSurface_PageUnlock (lpDDSurface, dwFlags)

	FUNCADDR PageUnlock (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	PageUnlock	= XLONGAT (vtblAddr + 0x98)
	IFZ PageUnlock THEN RETURN ($$TRUE)

	RETURN @PageUnlock (lpDDSurface, dwFlags)

END FUNCTION
'
'
' ##################################################
' #####  IDirectDrawSurface_SetSurfaceDesc ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_SetSurfaceDesc (lpDDSurface, lpDDSurfaceDesc, dwFlags)

	FUNCADDR SetSurfaceDesc (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetSurfaceDesc	= XLONGAT (vtblAddr + 0x9C)
	IFZ SetSurfaceDesc THEN RETURN ($$TRUE)

	RETURN @SetSurfaceDesc (lpDDSurface, lpDDSurfaceDesc, dwFlags)

END FUNCTION
'
'
' ##################################################
' #####  IDirectDrawSurface_SetPrivateData ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_SetPrivateData (lpDDSurface, guidTag, lpData, cbSize, dwFlags)

	FUNCADDR SetPrivateData (XLONG, XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetPrivateData	= XLONGAT (vtblAddr + 0xA0)
	IFZ SetPrivateData THEN RETURN ($$TRUE)

	RETURN @SetPrivateData (lpDDSurface, guidTag, lpData, cbSize, dwFlags)

END FUNCTION
'
'
' ##################################################
' #####  IDirectDrawSurface_GetPrivateData ()  #####
' ##################################################
'
FUNCTION  IDirectDrawSurface_GetPrivateData (lpDDSurface, guidTag, lpBuffer, lpcbBufferSize)

	FUNCADDR GetPrivateData (XLONG, XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetPrivateData	= XLONGAT (vtblAddr + 0xA4)
	IFZ GetPrivateData THEN RETURN ($$TRUE)

	RETURN @GetPrivateData (lpDDSurface, guidTag, lpBuffer, lpcbBufferSize)

END FUNCTION
'
'
' ###################################################
' #####  IDirectDrawSurface_FreePrivateData ()  #####
' ###################################################
'
FUNCTION  IDirectDrawSurface_FreePrivateData (lpDDSurface, guidTag)

	FUNCADDR FreePrivateData (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	FreePrivateData	= XLONGAT (vtblAddr + 0xA8)
	IFZ FreePrivateData THEN RETURN ($$TRUE)

	RETURN @FreePrivateData (lpDDSurface, guidTag)

END FUNCTION
'
'
' ######################################################
' #####  IDirectDrawSurface_GetUniquenessValue ()  #####
' ######################################################
'
FUNCTION  IDirectDrawSurface_GetUniquenessValue (lpDDSurface, lpValue)

	FUNCADDR GetUniquenessValue (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetUniquenessValue	= XLONGAT (vtblAddr + 0xAC)
	IFZ GetUniquenessValue THEN RETURN ($$TRUE)

	RETURN @GetUniquenessValue (lpDDSurface, lpValue)

END FUNCTION
'
'
' #########################################################
' #####  IDirectDrawSurface_ChangeUniquenessValue ()  #####
' #########################################################
'
FUNCTION  IDirectDrawSurface_ChangeUniquenessValue (lpDDSurface)

	FUNCADDR ChangeUniquenessValue (XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	ChangeUniquenessValue	= XLONGAT (vtblAddr + 0xB0)
	IFZ ChangeUniquenessValue THEN RETURN ($$TRUE)

	RETURN @ChangeUniquenessValue (lpDDSurface)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDrawSurface_SetPriority ()  #####
' ###############################################
'
FUNCTION  IDirectDrawSurface_SetPriority (lpDDSurface, dwPriority)

	FUNCADDR SetPriority (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetPriority	= XLONGAT (vtblAddr + 0xB4)
	IFZ SetPriority THEN RETURN ($$TRUE)

	RETURN @SetPriority (lpDDSurface, dwPriority)

END FUNCTION
'
'
' ###############################################
' #####  IDirectDrawSurface_GetPriority ()  #####
' ###############################################
'
FUNCTION  IDirectDrawSurface_GetPriority (lpDDSurface, lpdwPriority)

	FUNCADDR GetPriority (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetPriority	= XLONGAT (vtblAddr + 0xB8)
	IFZ GetPriority THEN RETURN ($$TRUE)

	RETURN @GetPriority (lpDDSurface, lpdwPriority)

END FUNCTION
'
'
' ##########################################
' #####  IDirectDrawSurface_SetLOD ()  #####
' ##########################################
'
FUNCTION  IDirectDrawSurface_SetLOD (lpDDSurface, dwMaxLOD)

	FUNCADDR SetLOD (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	SetLOD	= XLONGAT (vtblAddr + 0xBC)
	IFZ SetLOD THEN RETURN ($$TRUE)

	RETURN @SetLOD (lpDDSurface, dwMaxLOD)

END FUNCTION
'
'
' ##########################################
' #####  IDirectDrawSurface_GetLOD ()  #####
' ##########################################
'
FUNCTION  IDirectDrawSurface_GetLOD (lpDDSurface, lpdwMaxLOD)

	FUNCADDR GetLOD (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDSurface)
	GetLOD	= XLONGAT (vtblAddr + 0xC0)
	IFZ GetLOD THEN RETURN ($$TRUE)

	RETURN @GetLOD (lpDDSurface, lpdwMaxLOD)

END FUNCTION
'
'
' #########################################################
' #####  IDirectDrawColorControl_GetColorControls ()  #####
' #########################################################
'
FUNCTION  IDirectDrawColorControl_GetColorControls (lpDDColorControl, lpColorControl)

	FUNCADDR GetColorControls (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDColorControl)
	GetColorControls	= XLONGAT (vtblAddr + 0x0C)
	IFZ GetColorControls THEN RETURN ($$TRUE)

	RETURN @GetColorControls (lpDDColorControl, lpColorControl)

END FUNCTION
'
'
' #########################################################
' #####  IDirectDrawColorControl_SetColorControls ()  #####
' #########################################################
'
FUNCTION  IDirectDrawColorControl_SetColorControls (lpDDColorControl, lpColorControl)

	FUNCADDR SetColorControls (XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDColorControl)
	SetColorControls	= XLONGAT (vtblAddr + 0x10)
	IFZ SetColorControls THEN RETURN ($$TRUE)

	RETURN @SetColorControls (lpDDColorControl, lpColorControl)

END FUNCTION
'
'
' #####################################################
' #####  IDirectDrawGammaControl_GetGammaRamp ()  #####
' #####################################################
'
FUNCTION  IDirectDrawGammaControl_GetGammaRamp (lpDDGammaControl, dwFlags, lpRampData)

	FUNCADDR GetGammaRamp (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDGammaControl)
	GetGammaRamp	= XLONGAT (vtblAddr + 0x0C)
	IFZ GetGammaRamp THEN RETURN ($$TRUE)

	RETURN @GetGammaRamp (lpDDGammaControl, dwFlags, lpRampData)

END FUNCTION
'
'
' #####################################################
' #####  IDirectDrawGammaControl_SetGammaRamp ()  #####
' #####################################################
'
FUNCTION  IDirectDrawGammaControl_SetGammaRamp (lpDDGammaControl, dwFlags, lpRampData)

	FUNCADDR SetGammaRamp (XLONG, XLONG, XLONG)

	vtblAddr = XLONGAT (lpDDGammaControl)
	SetGammaRamp	= XLONGAT (vtblAddr + 0x10)
	IFZ SetGammaRamp THEN RETURN ($$TRUE)

	RETURN @SetGammaRamp (lpDDGammaControl, dwFlags, lpRampData)

END FUNCTION
END PROGRAM
