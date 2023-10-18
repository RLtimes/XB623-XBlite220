'
'
' #################### David Szafranski
' #####  PROLOG  ##### copyright 2002
' #################### XBLite bitmap library
'
' Xbm is a bitmap library for loading and saving
' bitmap images in XBLite.
'
' (c) 2002 GPL David SZAFRANSKI
' david.szafranski@wanadoo.fr
'
' Version 0.0005 - Added XbmLoadGif().
'
PROGRAM	"xbm"
VERSION	"0.0005"
'
	IMPORT	"xst"   	' Standard library : required by most programs
	IMPORT  "gdi32"
	IMPORT  "user32"
	IMPORT  "kernel32"

EXPORT

TYPE GIF_LOGICAL_SCREEN_DESCRIPTOR
	UBYTE    .widthLSB
	UBYTE    .widthMSB
	UBYTE    .heightLSB
	UBYTE    .heightMSB
	UBYTE    .bitfields
	UBYTE    .backgroundColorIndex
	UBYTE    .pixelAspectRatio
END TYPE
'
TYPE GifHeader												' REQUIRED
	STRING*3 .signature
	STRING*3 .version
END TYPE
'
TYPE GifLogicalScreenDescriptor				' REQUIRED
	UBYTE    .widthLSB
	UBYTE    .widthMSB
	UBYTE    .heightLSB
	UBYTE    .heightMSB
	UBYTE    .bitfields
	UBYTE    .backgroundColorIndex
	UBYTE    .pixelAspectRatio
END TYPE
'
TYPE GifColorTableEntry								' global/local color tables are optional
	UBYTE    .r													' red
	UBYTE    .g													' green
	UBYTE    .b													' blue
END TYPE
'
TYPE GifDataBlockSize									' required if image has any data blocks
	UBYTE    .blockSize									' 0x00 blockSize means end of data
END TYPE
'
TYPE GifImageDescriptor								' required for images
	UBYTE    .imageSeparator
	UBYTE    .imageLeftPositionLSB
	UBYTE    .imageLeftPositionMSB
	UBYTE    .imageTopPositionLSB
	UBYTE    .imageTopPositionMSB
	UBYTE    .imageWidthLSB
	UBYTE    .imageWidthMSB
	UBYTE    .imageHeightLSB
	UBYTE    .imageHeightMSB
	UBYTE    .bitfields
END TYPE
'
TYPE GifTableBasedImageDataHeader			' required before 1st image block
	UBYTE    .minimumCodeSize
END TYPE
'
TYPE GifGraphicControlExtension				' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .graphicControlLabel
	UBYTE    .blockSize
	UBYTE    .bitfields
	UBYTE    .delayTimeLSB
	UBYTE    .delayTimeMSB
	UBYTE    .transparentColorIndex
	UBYTE    .blockTerminator
END TYPE
'
TYPE GifCommentExtensionHeader				' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .commentLabel
END TYPE
'
TYPE GifPlainTextExtensionHeader			' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .plainTextLabel
	UBYTE    .blockSize
	UBYTE    .textGridLeftPositionLSB
	UBYTE    .textGridLeftPositionMSB
	UBYTE    .textGridWidthLSB
	UBYTE    .textGridWidthMSB
	UBYTE    .textGridHeightLSB
	UBYTE    .textGridHeightMSB
	UBYTE    .characterCellWidth
	UBYTE    .characterCellHeight
	UBYTE    .textForegroundColorIndex
	UBYTE    .textBackgroundColorIndex
END TYPE
'
TYPE GifApplicationExtensionHeader		' OPTIONAL
	UBYTE    .extensionIntroducer
	UBYTE    .extensionLabel
	UBYTE    .blockSize
	UBYTE    .applicationIdentifier0
	UBYTE    .applicationIdentifier1
	UBYTE    .applicationIdentifier2
	UBYTE    .applicationIdentifier3
	UBYTE    .applicationIdentifier4
	UBYTE    .applicationIdentifier5
	UBYTE    .applicationIdentifier6
	UBYTE    .applicationIdentifier7
	UBYTE    .applicationAuthenticationCode0
	UBYTE    .applicationAuthenticationCode1
	UBYTE    .applicationAuthenticationCode2
END TYPE
'
TYPE GifTrailer												' REQUIRED
	UBYTE    .gifTrailer
END TYPE

DECLARE FUNCTION  Xbm ()
DECLARE FUNCTION  XbmLoadImage (fileName$, UBYTE image[])
DECLARE FUNCTION  XbmSetImage (hImage, UBYTE image[])
DECLARE FUNCTION  XbmSaveImage (fileName$, UBYTE image[])
DECLARE FUNCTION  XbmDIBto24Bit (UBYTE image[])
DECLARE FUNCTION  XbmCopyImage (hDest, hSrc)
DECLARE FUNCTION  XbmGetImage (hImage, UBYTE image[])
DECLARE FUNCTION  XbmGetImageArrayInfo (UBYTE image[], @bpp, @width, @height)
DECLARE FUNCTION  XbmDrawImage (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1)
DECLARE FUNCTION  XbmDrawImageEx (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1, dx2, dy2, fRop, orient)
DECLARE FUNCTION  XbmCreateMemBitmap (hWnd, w, h, @hMemBitmap)
DECLARE FUNCTION  XbmDeleteMemBitmap (hMemBitmap)
DECLARE FUNCTION  XbmGetImageType (hImage)
DECLARE FUNCTION  XbmDrawMaskedImage (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1, hMask, mx1, mx2)
DECLARE FUNCTION  XbmLoadBitmap (name$, UBYTE image[])
DECLARE FUNCTION  XbmGetImageSize (hImage, @width, @height)
DECLARE FUNCTION  XbmLoadGif (gifFile$, UBYTE image[])
'
'
$$IMAGE_SCREEN = 1
$$IMAGE_MEMORY = 2
END EXPORT
'
'
' ####################
' #####  Xbm ()  #####
' ####################
'
'
FUNCTION  Xbm ()

	IF LIBRARY(0) THEN RETURN

END FUNCTION
'
'
' #############################
' #####  XbmLoadImage ()  #####
' #############################
'
'	/*
'	[XbmLoadImage]
' Description = The XbmLoadImage function loads a bitmap disk file into an image array.
' Function    = error = XbmLoadImage (fileName$, @image[])
' ArgCount    = 2
'	Arg1        = fileName$ : The filename of the bitmap to be loaded (*.bmp).
' Arg2        = image[] : Returned DIB UBYTE image array.
'	Return      = If the function succeeds, the return value is -1.  If the function fails, the return value is 0.
' Remarks     =
'	See Also    =
'	Examples    = See demo program xbmtest.x.
'	*/
'
FUNCTION  XbmLoadImage (fileName$, UBYTE image[])

	DIM image[]

	IFZ fileName$ THEN
		error = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	ifile = OPEN (fileName$, $$RD)

	IF (ifile < 3) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	bytes = LOF (ifile)
	upper = bytes - 1
	DIM image[upper]

	old = ERROR (0)
	bytesRead = 0
	error = XxxReadFile (ifile, &image[], bytes, &bytesRead, 0)
	CLOSE (ifile)

	IF (bytesRead != bytes) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureFailed
		old = ERROR (error)
		DIM image[]
		RETURN ($$FALSE)
	END IF

	byte0 = image[0]
	byte1 = image[1]
	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]

	SELECT CASE TRUE
		CASE ((byte0='B') & (byte1='M'))								: GOSUB BM
		CASE ELSE																				: DIM image[]
																											error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
																											RETURN ($$FALSE)
	END SELECT

	RETURN ($$TRUE)

' *****  BM  *****

SUB BM
	bs = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2

	IF (bs > bytes) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureFailed
		old = ERROR (error)
		DIM image[]
		RETURN ($$FALSE)
	END IF
END SUB

END FUNCTION
'
'
' ############################
' #####  XbmSetImage ()  #####
' ############################
'
'	/*
'	[XbmSetImage]
' Description = The XbmSetImage function copies the image data from an image array to a window or a bitmap object.
' Function    = error = XbmSetImage (hImage, @image[])
' ArgCount    = 2
'	Arg1        = hImage : Handle of window or bitmap object.
' Arg2        = image[] : DIB format UBYTE image array to set in window or bitmap object.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = If hImage is a window, then the image array is displayed in the window.
'	See Also    = See XbmGetImage. See demo program xbmtest.x.
'	Examples    = UBYTE image[]<br>XbmLoadImage ("mydog.bmp", @image[])<br>XbmSetImage (hWnd, @image[])
'	*/
'
'		Bitmap structure:
'			Bytes			Structure
'			0  - 13		BITMAPFILEHEADER
'			14 -			BITMAPINFO or BITMAPCOREINFO

FUNCTION  XbmSetImage (hImage, UBYTE image[])

	IFZ hImage THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hImage) THEN RETURN ($$FALSE)

	IFZ image[] THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	size = SIZE (image[])

	IF (size < 54) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	byte0 = image[0]
	byte1 = image[1]

	IF ((byte0 != 'B') OR (byte1 != 'M')) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]

	bytes = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2

	IF (size < bytes) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	iAddr = &image[]

	byte10 = image[10]
	byte11 = image[11]
	byte12 = image[12]
	byte13 = image[13]

	dataOffset = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10

	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]

	headerSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14

'	copy the image

	xDest = 0
	yDest = 0

	xSrc = 0
	ySrc = 0
	info = 14
	bitmapInfo = iAddr + 14
	bitmapData = iAddr + dataOffset
	usage = $$DIB_RGB_COLORS							' RGB values
'
	IF (headerSize = 12) THEN							' BITMAPCOREINFO
		w0 = image[info+4]
		w1 = image[info+5]
		h0 = image[info+6]
		h1 = image[info+7]
		b0 = image[info+10]
		b1 = image[info+11]
		width = (w1 << 8) OR w0
		height = (h1 << 8) OR h0
		bitsPerPixel = (b1 << 8) OR b0
	ELSE																	' BITMAPINFO
		w0 = image[info+4]
		w1 = image[info+5]
		w2 = image[info+6]
		w3 = image[info+7]
		h0 = image[info+8]
		h1 = image[info+9]
		h2 = image[info+10]
		h3 = image[info+11]
		b0 = image[info+14]
		b1 = image[info+15]
		width = (w3 << 24) OR (w2 << 16) OR (w1 << 8) OR w0
		height = (h3 << 24) OR (h2 << 16) OR (h1 << 8) OR h0
		bitsPerPixel = (b1 << 8) OR b0
	END IF
'
	startScan = 0
	scanLines = height

	IF XbmGetImageType (hImage) = $$IMAGE_SCREEN THEN
		hdc = GetDC (hImage)
		ok = SetDIBitsToDevice (hdc, xDest, yDest, width, height, xSrc, ySrc, startScan, scanLines, bitmapData, bitmapInfo, usage)
		ReleaseDC (hImage, hdc)
	ELSE
		hdcMem = CreateCompatibleDC (NULL)
		hBitmapLast = SelectObject (hdcMem, hImage)
		ok = SetDIBits (hdcMem, hImage, startScan, scanLines, bitmapData, bitmapInfo, usage)
		SelectObject (hdcMem, hBitmapLast)
		DeleteDC (hdcMem)
	END IF

	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XbmSaveImage ()  #####
' #############################
'
'	/*
'	[XbmSaveImage]
' Description = The XbmSaveImage function saves an image array to a bitmap disk file (*.bmp).
' Function    = error = XbmSaveImage (fileName$, @image[])
' ArgCount    = 2
'	Arg1        = fileName$ : The filename of the bitmap to be saved (*.bmp).
' Arg2        = image[] : DIB UBYTE image array to save.
'	Return      = If the function succeeds, the return value is -1.  If the function fails, the return value is 0. Call ERROR() to get further error information.
' Remarks     =
'	See Also    = See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmSaveImage (fileName$, UBYTE image[])

	IFZ image[] THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	size = SIZE (image[])

	IF (size < 54) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	IFZ fileName$ THEN
		error = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidName
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	byte0 = image[0]
	byte1 = image[1]

	IF ((byte0 != 'B') OR (byte1 != 'M')) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]

	bytes = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2

	IF (size < bytes) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF

	ofile = OPEN (fileName$, $$WRNEW)

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
' ##############################
' #####  XbmDIBto24Bit ()  #####
' ##############################
'
'	/*
'	[XbmDIBto24Bit]
' Description = The XbmDIBto24Bit function converts a 1, 4, or 8-bit DIB image[] array to a 24-bit RGB DIB format image array.
' Function    = error = XbmDIBto24Bit (@image[])
' ArgCount    = 1
'	Arg1        = image[] : A UBYTE DIB image array to convert from 1, 4, or 8-bits to 24-bits RGB.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = This function currently only works ok on 8-bit DIBs, but not on non-aligned 4-bit DIBs.
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XbmDIBto24Bit (UBYTE image[])
'
	UBYTE  image24[]
	$BI_RGB       = 0					' 24-bit RGB
'
	IFZ image[] THEN RETURN
'
	iAddr = &image[]
'
	byte10 = image[10]
	byte11 = image[11]
	byte12 = image[12]
	byte13 = image[13]
'
	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]
'
	byte18 = image[18]
	byte19 = image[19]
	byte20 = image[20]
	byte21 = image[21]
'
	byte22 = image[22]
	byte23 = image[23]
	byte24 = image[24]
	byte25 = image[25]
'
	byte26 = image[26]
	byte27 = image[27]
'
	byte28 = image[28]
	byte29 = image[29]
'
	byte30 = image[30]
	byte31 = image[31]
'
	byte46 = image[46]
	byte47 = image[47]
	byte48 = image[48]
	byte49 = image[49]
'
	offBits = (byte13 << 24) OR (byte12 << 16) OR (byte11 << 8) OR byte10
	biSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
	width = (byte21 << 24) OR (byte20 << 16) OR (byte19 << 8) OR byte18
	height = (byte25 << 24) OR (byte24 << 16) OR (byte23 << 8) OR byte22
	bitCount = (byte29 << 8) OR byte28
	clrUsed = (byte49 << 24) OR (byte48 << 16) OR (byte47 << 8) OR byte46
'
	paletteAddr = iAddr + 14 + biSize
	bitmapAddr = iAddr + offBits
'
'	get palette
'
	IFZ clrUsed THEN
		SELECT CASE bitCount
			CASE 1		: clrUsed = 2
			CASE 4		: clrUsed = 16
			CASE 8		: clrUsed = 256
			CASE ELSE	: RETURN ($$FALSE)
		END SELECT
	END IF
'
	DIM palette[clrUsed - 1]
	pAddr = &palette[0]
	offset = 0
'
	FOR i = 0 TO clrUsed - 1
		UBYTEAT (pAddr, offset) = UBYTEAT (paletteAddr, offset) : INC offset
		UBYTEAT (pAddr, offset) = UBYTEAT (paletteAddr, offset) : INC offset
		UBYTEAT (pAddr, offset) = UBYTEAT (paletteAddr, offset) : INC offset
		INC offset
	NEXT i
'
'	Create the new array:  Dimension image24[]
	dataOffset = 54
	row = ((width * 3) + 3) AND -4
	size = dataOffset + (height * row)
'
	upper = size - 1
	DIM image24[upper]
'
'	Fill header (non-assigned values are to be 0)
'
	iAddr24	= &image24[0]
'
	image24[0] = 'B'															' DIB aka BMP signature
	image24[1] = 'M'
	image24[2] = size AND 0x00FF									' file size
	image24[3] = (size >> 8) AND 0x00FF
	image24[4] = (size >> 16) AND 0x00FF
	image24[5] = (size >> 24) AND 0x00FF
	image24[6] = 0
	image24[7] = 0
	image24[8] = 0
	image24[9] = 0
	image24[10] = dataOffset AND 0x00FF						' file offset of bitmap data
	image24[11] = (dataOffset >> 8) AND 0x00FF
	image24[12] = (dataOffset >> 16) AND 0x00FF
	image24[13] = (dataOffset >> 24) AND 0x00FF
'
'	fill BITMAPINFOHEADER (first 6 members)
'
	info = 14
	image24[info+0] = 40													' XLONG : BITMAPINFOHEADER size
	image24[info+1] = 0
	image24[info+2] = 0
	image24[info+3] = 0
	image24[info+4] = width AND 0x00FF						' XLONG : width in pixels
	image24[info+5] = (width >> 8) AND 0x00FF
	image24[info+6] = (width >> 16) AND 0x00FF
	image24[info+7] = (width >> 24) AND 0x00FF
	image24[info+8] = height AND 0x00FF						' XLONG : height in pixels
	image24[info+9] = (height >> 8) AND 0x00FF
	image24[info+10] = (height >> 16) AND 0x00FF
	image24[info+11] = (height >> 24) AND 0x00FF
	image24[info+12] = 1													' USHORT : # of planes
	image24[info+13] = 0													'
	image24[info+14] = 24													' USHORT : bits per pixel
	image24[info+15] = 0													'
	image24[info+16] = $BI_RGB										' XLONG : 24-bit RGB
	image24[info+17] = 0													'
	image24[info+18] = 0													'
	image24[info+19] = 0													'
	image24[info+20] = 0													' XLONG : sizeImage
	image24[info+21] = 0													'
	image24[info+22] = 0													'
	image24[info+23] = 0													'
	image24[info+24] = 0													' XLONG : xPPM
	image24[info+25] = 0													'
	image24[info+26] = 0													'
	image24[info+27] = 0													'
	image24[info+28] = 0													' XLONG : yPPM
	image24[info+29] = 0													'
	image24[info+30] = 0													'
	image24[info+31] = 0													'
	image24[info+32] = 0													' XLONG : clrUsed
	image24[info+33] = 0													'
	image24[info+34] = 0													'
	image24[info+35] = 0													'
	image24[info+36] = 0													' XLONG : clrImportant
	image24[info+37] = 0													'
	image24[info+38] = 0													'
	image24[info+39] = 0													'
'
'	fill image
	bmOffset = bitmapAddr
	offset24 = dataOffset
'
	bitPtr = 0
'
	FOR j = 0 TO (height - 1)
		FOR i = 0 TO (width - 1)
			SELECT CASE bitCount
				CASE 1
							index = UBYTEAT(bmOffset) : INC bmOffset
							IFZ bitPtr THEN
								shortIndex = UBYTEAT(bmOffset)
								index = shortIndex{4,0}
								INC bitPtr
							ELSE
								index = shortIndex{4,bitPtr}
								INC bitPtr
								IF bitPtr{3,0} THEN								' next byte after 8 bits
									bitPtr = 0
									INC bmOffset
								END IF
							END IF
				CASE 4
							IFZ bitPtr THEN
								shortIndex = UBYTEAT(bmOffset)
								index = shortIndex{4,4}
								INC bitPtr
							ELSE
								index = shortIndex{4,0}
								bitPtr = 0												' next byte after 2 SHORTs
								INC bmOffset
							END IF
				CASE ELSE
							index = UBYTEAT(bmOffset):  INC bmOffset
			END SELECT
			color = palette[index]
'
'			UBYTEAT (iAddr, offset24) = color{8,24}	: INC offset24
'			UBYTEAT (iAddr, offset24) = color{8,16}	: INC offset24
'			UBYTEAT (iAddr, offset24) = color{8,8}	: INC offset24
' the 3 above lines replaced 2002/09/08 dts
			UBYTEAT (iAddr24, offset24) = color{8,0}	: INC offset24
			UBYTEAT (iAddr24, offset24) = color{8,8}	: INC offset24
			UBYTEAT (iAddr24, offset24) = color{8,16}	: INC offset24
		NEXT i
'
		align = (bmOffset - bitmapAddr){2,0}							' ok if align = 0
		IF align THEN bmOffset = bmOffset + (4 - align)
		align = (offset24 - 54){2,0}											' ok if align = 0
		IF align THEN offset24 = offset24 + (4 - align)		' align 4
	NEXT j
'
	SWAP image[], image24[]
	REDIM image24[]
	RETURN ($$TRUE)
'
END FUNCTION
'
'
' #############################
' #####  XbmCopyImage ()  #####
' #############################
'
'	/*
'	[XbmCopyImage]
' Description = The XbmCopyImage function uses BitBlt to copy a bitmap from hSrc to hDest. The images may be either screen or memory bitmaps.
' Function    = error = XbmCopyImage (hDest, hSrc)
' ArgCount    = 2
'	Arg1        = hDest : Handle of destination bitmap.
' Arg2        = hSrc : Handle of source bitmap.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XbmCopyImage (hDest, hSrc)

	RECT destRect
	BITMAP bm

	IFZ hDest * hSrc THEN RETURN $$FALSE
	IF hDest = hSrc THEN RETURN $$FALSE
	IFZ XbmGetImageType (hDest) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hSrc) THEN RETURN ($$FALSE)

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		hdcSrc = GetDC (hSrc)
	ELSE
		hdc     = GetDC (0)
		hdcSrc  = CreateCompatibleDC (hdc)
		sBitmapLast = SelectObject (hdcSrc, hSrc)
	END IF

	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		hdcDest = GetDC (hDest)
		GetClientRect (hDest, &destRect)
		dwidth = destRect.right
		dheight = destRect.bottom
	ELSE
		hdc     = GetDC (0)
		hdcDest  = CreateCompatibleDC (hdc)
		dBitmapLast = SelectObject (hdcDest, hDest)
		GetObjectA (hDest, SIZE(bm), &bm)
		dwidth = bm.width
		dheight = bm.height
	END IF

	ok = BitBlt (hdcDest, 0, 0, dwidth, dheight, hdcSrc, 0, 0, $$SRCCOPY)
	GOSUB CleanUp

	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

' ***** CleanUp *****
SUB CleanUp
	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		ReleaseDC (hDest, hdcDest)
	ELSE
		SelectObject (hdcDest, dBitmapLast)
		ReleaseDC (0, hdc)
		DeleteDC (hdcDest)
	END IF

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		ReleaseDC (hSrc, hdcSrc)
	ELSE
		SelectObject (hdcSrc, sBitmapLast)
		ReleaseDC (0, hdc)
		DeleteDC (hdcSrc)
	END IF
END SUB

END FUNCTION
'
'
' ############################
' #####  XbmGetImage ()  #####
' ############################
'
'	/*
'	[XbmGetImage]
' Description = The XbmGetImage function copies the image data from a window or a bitmap object to an image array.
' Function    = error = XbmGetImage (hImage, @image[])
' ArgCount    = 2
'	Arg1        = hImage : Handle of window or bitmap object.
' Arg2        = image[] : Returned DIB format UBYTE image array.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     =
'	See Also    = See XbmSetImage. See demo program xbmtest.x.
'	Examples    = UBYTE image[]<br>hDesktop = GetDesktopWindow ()<br>XbmGetImage (hDesktop, @image[])
'	*/
'
'		DIB BITMAPFILEHEADER:  Offset 0 bytes
'			USHORT	.bfType							'BM'  (for bitmap)
'			ULONG		.bfSize							Total size of the file in bytes
'			USHORT	.res1								0
'			USHORT	.res2								0
'			ULONG		.bfOffBits					Offset to bitmapData from beginning of file (66)
'
'		DIB BITMAPINFO:        Offset 14 bytes
'			DIB BITMAPINFOHEADER:  Offset 14 bytes
'				ULONG		.biSize						Size of BitmapInfoHeader in bytes (40)
'				SLONG		.biWidth					Width of bitmap in pixels
'				SLONG		.biHeight					Height of bitmap in pixels
'				USHORT	.biPlanes					1
'				USHORT	.biBitCount				Color bits per pixel (32)
'				ULONG		.biCompression		Compression scheme (BI_BITFIELDS = 3)
'				ULONG		.biSizeImage			Size of bitmap bits in bytes (0--no compression)
'				SLONG		.biXPelsPerMeter	Horizontal resolution in pixels per meter
'				SLONG		.biYPelsPerMeter	Vertical resolution
'				ULONG		.biClrUsed				Number of colors used in image (0)
'				ULONG		.biClrImportant		Number of important colors in image (0)
'
'			DIB bmiColors:			Offset 54 bytes
'				ULONG		.redBits					0xFFC00000		10 bits
'				ULONG		.greenBits				0x003FF800		11 bits
'				ULONG		.blueBits					0x000007FF		11 bits
'
'		DIB bitmapData:					Offset 66 bytes
'			biBitCount		Interpretation	  (start with BOTTOM row of pixels, at left)
'				32:					32-bits per pixel (10-11-11 = 0RGB)

'			Each ROW is padded to a multiple of 4 bytes.

'		24-bit format mods to the above:
'			BITMAPINFOHEADER
'				.biBitCount			= 24
'				.biCompression	= $BI_RGB

'			DIB bmiColors:		UNUSED (0 bytes)

'			DIB bitmapData:		offset = 54 bytes
'				24 bits per pixel (8 bits each for RGB)
'				Each ROW is padded to a multiple of 4 bytes.

FUNCTION  XbmGetImage (hImage, UBYTE image[])

	RECT rect
	BITMAP bm

	$BI_RGB       = 0					' 24-bit RGB

	DIM image[]

	IFZ hImage THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hImage) THEN RETURN ($$FALSE)

	IF XbmGetImageType (hImage) = $$IMAGE_SCREEN THEN
		GetClientRect (hImage, &rect)
		width  = rect.right
		height = rect.bottom
	ELSE
		hdcMem      = CreateCompatibleDC (NULL)
		hBitmapLast = SelectObject (hdcMem, hImage)
		GetObjectA (hImage, SIZE(bm), &bm)
		width       = bm.width
		height      = bm.height
	END IF

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

	x = 0
	y = 0

	IF XbmGetImageType (hImage) = $$IMAGE_SCREEN THEN
		hdc = GetDC (hImage)
		hdcTmp	= CreateCompatibleDC (hdc)
		hBitmap	= CreateCompatibleBitmap (hdc, width, height)
		hBitmapOld = SelectObject (hdcTmp, hBitmap)
		BitBlt (hdcTmp, 0, 0, width, height, hdc, x, y, $$SRCCOPY)
		hBitmap	= SelectObject (hdcTmp, hBitmapOld)			' bitmap not in hdc
		ok = GetDIBits (hdc, hBitmap, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
		ReleaseDC (hImage, hdc)
		DeleteDC (hdcTmp)
		DeleteObject (hBitmapOld)
		DeleteObject (hBitmap)
	ELSE
		ok = GetDIBits (hdcMem, hImage, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
		SelectObject (hdcMem, hBitmapLast)
		DeleteDC (hdcMem)
	END IF

	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XbmGetImageArrayInfo ()  #####
' #####################################
'
'	/*
'	[XbmGetImageArrayInfo]
' Description = The XbmGetImageArrayInfo function returns data from a DIB image array.
' Function    = error = XbmGetImageArrayInfo (@image[], @bpp, @width, @height)
' ArgCount    = 4
'	Arg1        = image[] : DIB format UBYTE image array.
' Arg2        = bpp : Returned bits per pixel.
' Arg3        = bpp : Returned image width.
' Arg4        = bpp : Returned image height.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XbmGetImageArrayInfo (UBYTE image[], @bpp, @width, @height)

	IFZ image[] THEN RETURN ($$FALSE)
	bytes = SIZE (image[])
	iAddr = &image[]
'
	IF (bytes < 54) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF
'
	byte0 = image[0]
	byte1 = image[1]
'
	IF ((byte0 != 'B') OR (byte1 != 'M')) THEN
		error = ($$ErrorObjectImage << 8) OR $$ErrorNatureInvalidFormat
		old = ERROR (error)
		RETURN ($$FALSE)
	END IF
'
	byte2 = image[2]
	byte3 = image[3]
	byte4 = image[4]
	byte5 = image[5]
	fileSize = (byte5 << 24) OR (byte4 << 16) OR (byte3 << 8) OR byte2
'
	byte14 = image[14]
	byte15 = image[15]
	byte16 = image[16]
	byte17 = image[17]
	headerSize = (byte17 << 24) OR (byte16 << 16) OR (byte15 << 8) OR byte14
'
	info = 14
'
	IF (headerSize = 12) THEN							' BITMAPCOREINFO
		w0 = image[info+4]
		w1 = image[info+5]
		h0 = image[info+6]
		h1 = image[info+7]
		b0 = image[info+10]
		b1 = image[info+11]
		width = (w1 << 8) OR w0
		height = (h1 << 8) OR h0
		bpp = (b1 << 8) OR b0
	ELSE																	' BITMAPINFO
		w0 = image[info+4]
		w1 = image[info+5]
		w2 = image[info+6]
		w3 = image[info+7]
		h0 = image[info+8]
		h1 = image[info+9]
		h2 = image[info+10]
		h3 = image[info+11]
		b0 = image[info+14]
		b1 = image[info+15]
		width = (w3 << 24) OR (w2 << 16) OR (w1 << 8) OR w0
		height = (h3 << 24) OR (h2 << 16) OR (h1 << 8) OR h0
		bpp = (b1 << 8) OR b0
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XbmDrawImage ()  #####
' #############################
'
'	/*
'	[XbmDrawImage]
' Description = The XbmDrawImage function transfers the color data from a source bitmap object to destination bitmap object at the destination position dx1, dy1.
' Function    = error = XbmDrawImage (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1)
' ArgCount    = 8
'	Arg1        = hDest : Handle of destination bitmap object (screen or memory).
'	Arg2        = hSrc : Handle of source bitmap object (screen or memory).
'	Arg3        = sx1 : x-coordinate of source rectangle's upper-left corner.
'	Arg4        = sy1 : y-coordinate of source rectangle's upper-left corner.
'	Arg5        = sx2 : x-coordinate of source rectangle's lower-right corner.
'	Arg6        = sy2 : y-coordinate of source rectangle's lower-right corner.
'	Arg7        = dx1 : x-coordinate of destination rectangle's upper-left corner.
'	Arg8        = dy1 : y-coordinate of destination rectangle's upper-left corner.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = If the value of sx2 or sy2 is -1, then it's value is set to the width/height of the source image. This function is a wrapper for BitBlt.
'	See Also    = See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmDrawImage (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1)

	RECT srcRect
	BITMAP bm

	IFZ (hDest * hSrc) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hDest) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hSrc) THEN RETURN ($$FALSE)

	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		hdcDest = GetDC (hDest)
	ELSE
		hdc     = GetDC (0)
		hdcDest = CreateCompatibleDC (hdc)
		dBitmapLast = SelectObject (hdcDest, hDest)
	END IF

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		hdcSrc = GetDC (hSrc)
		GetClientRect (hSrc, &srcRect)
		swidth = srcRect.right
		sheight = srcRect.bottom
	ELSE
		hdc     = GetDC (0)
		hdcSrc  = CreateCompatibleDC (hdc)
		sBitmapLast = SelectObject (hdcSrc, hSrc)
		GetObjectA (hSrc, SIZE(bm), &bm)
		swidth = bm.width
		sheight = bm.height
	END IF

	IF (sx2 = -1) || (sx2 > swidth) THEN sx2 = swidth
	IF (sy2 = -1) || (sy2 > sheight) THEN sy2 = sheight

	IF sy2 < sy1 THEN SWAP sy2, sy1
	IF sx2 < sx1 THEN SWAP sx2, sx1

	width = sx2 - sx1
	height = sy2 - sy1

	IF ((width <= 0) OR (height <= 0)) THEN
		GOSUB CleanUp
		RETURN ($$FALSE)
	END IF

	ok = BitBlt (hdcDest, dx1, dy1, width, height, hdcSrc, sx1, sy1, $$SRCCOPY)
	GOSUB CleanUp
	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

' ***** CleanUp *****
SUB CleanUp
	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		ReleaseDC (hDest, hdcDest)
	ELSE
		SelectObject (hdcDest, dBitmapLast)
		ReleaseDC (0, hdc)
		DeleteDC (hdcDest)
	END IF

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		ReleaseDC (hSrc, hdcSrc)
	ELSE
		SelectObject (hdcSrc, sBitmapLast)
		ReleaseDC (0, hdc)
		DeleteDC (hdcSrc)
	END IF

END SUB

END FUNCTION
'
'
' ###############################
' #####  XbmDrawImageEx ()  #####
' ###############################
'
'	/*
'	[XbmDrawImageEx]
' Description = The XbmDrawImageEx copies a bitmap from a source rectangle into a destination rectangle, stretching or compressing the bitmap to fit the dimensions of the destination rectangle, if necessary.
' Function    = error = XbmDrawImageEx (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1, dx2, dy2, fRop, orient)
' ArgCount    = 12
'	Arg1        = hDest : Handle of destination bitmap object (screen or memory).
'	Arg2        = hSrc : Handle of source bitmap object (screen or memory).
'	Arg3        = sx1 : x-coordinate of source rectangle's upper-left corner.
'	Arg4        = sy1 : y-coordinate of source rectangle's upper-left corner.
'	Arg5        = sx2 : x-coordinate of source rectangle's lower-right corner.
'	Arg6        = sy2 : y-coordinate of source rectangle's lower-right corner.
'	Arg7        = dx1 : x-coordinate of destination rectangle's upper-left corner.
'	Arg8        = dy1 : y-coordinate of destination rectangle's upper-left corner.
'	Arg9        = dx2 : x-coordinate of destination rectangle's lower-right corner.
'	Arg10       = dy2 : y-coordinate of destination rectangle's lower-right corner.
' Arg11       = fRop : Raster operation flag, default is $$SRCCOPY.
' Arg12       = orient : Image orientation. 0 = normal (default), 1 = mirror, 2 = flip, 3 = 180 degree rotation.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = If the value of sx2 or sy2 is -1, then it's value is set to the width/height of the source image. If the value of dx2 or dy2 is -1, then it's value is set to the width/height of the destination image. This function is a wrapper for StretchBlt.
'	See Also    = See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmDrawImageEx (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1, dx2, dy2, fRop, orient)

	RECT srcRect
	RECT destRect
	BITMAP srcBm
	BITMAP destBm

	IFZ (hDest * hSrc) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hDest) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hSrc) THEN RETURN ($$FALSE)

	IFZ fRop THEN fRop = $$SRCCOPY

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		hdcSrc = GetDC (hSrc)
		GetClientRect (hSrc, &srcRect)
		swidth = srcRect.right
		sheight = srcRect.bottom
	ELSE
		hdcSrc  = CreateCompatibleDC (NULL)
		sBitmapLast = SelectObject (hdcSrc, hSrc)
		GetObjectA (hSrc, SIZE(srcBm), &srcBm)
		swidth = srcBm.width
		sheight = srcBm.height
	END IF

	IF (sx2 = -1) || (sx2 > swidth) THEN sx2 = swidth
	IF (sy2 = -1) || (sy2 > sheight) THEN sy2 = sheight

	IF sy2 < sy1 THEN SWAP sy2, sy1
	IF sx2 < sx1 THEN SWAP sx2, sx1

	swidth = sx2 - sx1
	sheight = sy2 - sy1

	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		hdcDest = GetDC (hDest)
		GetClientRect (hDest, &destRect)
		dwidth = destRect.right
		dheight = destRect.bottom
	ELSE
		hdcDest  = CreateCompatibleDC (NULL)
		dBitmapLast = SelectObject (hdcDest, hDest)
		GetObjectA (hDest, SIZE(destBm), &destBm)
		dwidth = destBm.width
		dheight = destBm.height
	END IF

	IF (dx2 = -1) THEN dx2 = dwidth
	IF (dy2 = -1) THEN dy2 = dheight

	IF dy2 < dy1 THEN SWAP dy2, dy1
	IF dx2 < dx1 THEN SWAP dx2, dx1

	dwidth = dx2 - dx1
	dheight = dy2 - dy1

	IF ((swidth <= 0) OR (sheight <= 0)) THEN
		GOSUB CleanUp
		RETURN ($$FALSE)
	END IF

	IF ((dwidth <= 0) OR (dheight <= 0)) THEN
		GOSUB CleanUp
		RETURN ($$FALSE)
	END IF

	SELECT CASE orient
		CASE 1 : 	dx1 = dx1 + dwidth
							dwidth = -1 * dwidth			' mirror

		CASE 2 : 	dy1 = dy1 + dheight
							dheight = -1 * dheight		' flip

		CASE 3 : 	dx1 = dx1 + dwidth
							dy1 = dy1 + dheight
							dheight = -1 * dheight
							dwidth = -1 * dwidth			' 180 rotate
	END SELECT

'	PRINT dx1, dy1, dwidth, dheight, sx1, sy1, swidth, sheight

	ok = StretchBlt (hdcDest, dx1, dy1, dwidth, dheight, hdcSrc, sx1, sy1, swidth, sheight, fRop)
	GOSUB CleanUp
	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

' ***** CleanUp *****
SUB CleanUp
	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		ReleaseDC (hDest, hdcDest)
	ELSE
		SelectObject (hdcDest, dBitmapLast)
		DeleteDC (hdcDest)
	END IF

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		ReleaseDC (hSrc, hdcSrc)
	ELSE
		SelectObject (hdcSrc, sBitmapLast)
		DeleteDC (hdcSrc)
	END IF

END SUB

END FUNCTION
'
'
' ###################################
' #####  XbmCreateMemBitmap ()  #####
' ###################################
'
'	/*
'	[XbmCreateMemBitmap]
' Description = The XbmCreateMemBitmap function creates a virtual bitmap in memory using CreateCompatibleBitmap. Use XbmDeleteMemBitmap when the bitmap is no longer needed.
' Function    = error = XbmCreateMemBitmap (hWnd, w, h, @hMemBitmap)
' ArgCount    = 4
'	Arg1        = hWnd : Handle of window.
' Arg2        = w : Width of bitmap.
' Arg3        = h : Height of bitmap.
' Arg4        = hMemBitmap : Returned handle for memory bitmap object.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     =
'	See Also    = See XbmDeleteMemBitmap. See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmCreateMemBitmap (hWnd, w, h, @hMemBitmap)

	ScreenDC    = GetDC (hWnd)
	hMemBitmap	= CreateCompatibleBitmap (ScreenDC, w, h)
	ReleaseDC    (hWnd, ScreenDC)     '  GetDC requires ReleaseDC

	IFZ hMemBitmap THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  XbmDeleteMemBitmap ()  #####
' ###################################
'
'	/*
'	[XbmDeleteMemBitmap]
' Description = The XbmDeleteMemBitmap function delete a virtual bitmap object in memory.
' Function    = error = XbmDeleteMemBitmap (hMemBitmap)
' ArgCount    = 1
'	Arg1        = hMemBitmap : Handle of memory bitmap.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = Every memory bitmap created using XbmCreateMemBitmap should be deleted before exiting a program.
'	See Also    = See XbmCreateMemBitmap. See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmDeleteMemBitmap (hMemBitmap)

	IFZ DeleteObject (hMemBitmap) THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  XbmGetImageType ()  #####
' ################################
'
'	/*
'	[XbmGetImageType]
' Description = The XbmGetImageType function determines if a handle is for a screen image (window handle) or for a memory image (bitmap object handle).
' Function    = error = XbmGetImageType (hImage)
' ArgCount    = 1
'	Arg1        = hImage : Handle of window or bitmap object.
'	Return      = If the function succeeds, the return value is the image type. If return value is 1 ($$IMAGE_SCREEN) then it is a valid windows handle. IF the return value is 2 ($$IMAGE_MEMORY) then it is a valid bitmap object handle (memory bitmap). If the handle is invalid, the return value is 0.
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XbmGetImageType (hImage)

	SELECT CASE TRUE
		CASE IsWindow (hImage) 											: RETURN $$IMAGE_SCREEN
		CASE GetObjectType (hImage) = $$OBJ_BITMAP 	: RETURN $$IMAGE_MEMORY
		CASE ELSE 																	: RETURN 0
	END SELECT

END FUNCTION
'
'
' ###################################
' #####  XbmDrawMaskedImage ()  #####
' ###################################
'
'	/*
'	[XbmDrawMaskedImage]
' Description = The XbmDrawMaskedImage draws a source bitmap to a destination bitmap using a mask bitmap on the source. The mask must be a 24-bit image type. A mask is used to allow certain areas of the source image to be drawn transparently. The mask image is black and white, with the transparent parts in white and the remaining parts in black.
' Function    = error = XbmDrawMaskedImage (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1, hMask, mx1, my1)
' ArgCount    = 11
'	Arg1        = hDest : Handle of destination bitmap object (screen or memory).
'	Arg2        = hSrc : Handle of source bitmap object (screen or memory).
'	Arg3        = sx1 : x-coordinate of source rectangle's upper-left corner.
'	Arg4        = sy1 : y-coordinate of source rectangle's upper-left corner.
'	Arg5        = sx2 : x-coordinate of source rectangle's lower-right corner.
'	Arg6        = sy2 : y-coordinate of source rectangle's lower-right corner.
'	Arg7        = dx1 : x-coordinate of destination rectangle's upper-left corner.
'	Arg8        = dy1 : y-coordinate of destination rectangle's upper-left corner.
'	Arg9        = hMask : Handle of mask memory bitmap object (memory).
'	Arg10       = mx1 : x-coordinate of mask rectangle's upper-left corner.
'	Arg11       = my1 : y-coordinate of mask rectangle's upper-left corner.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = If the value of sx2 or sy2 is -1, then it's value is set to the width/height of the source image.
'	See Also    = See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmDrawMaskedImage (hDest, hSrc, sx1, sy1, sx2, sy2, dx1, dy1, hMask, mx1, my1)

	RECT srcRect
	BITMAP bm

	IFZ (hDest * hSrc * hMask) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hDest) THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hSrc) THEN RETURN ($$FALSE)
	IF XbmGetImageType (hMask) <> $$IMAGE_MEMORY THEN RETURN ($$FALSE)

	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		hdcDest = GetDC (hDest)
	ELSE
		hdc     = GetDC (0)
		hdcDest = CreateCompatibleDC (hdc)
		dBitmapLast = SelectObject (hdcDest, hDest)
		ReleaseDC (0, hdc)
	END IF

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		hdcSrc = GetDC (hSrc)
		GetClientRect (hSrc, &srcRect)
		swidth = srcRect.right
		sheight = srcRect.bottom
	ELSE
		hdc     = GetDC (0)
		hdcSrc  = CreateCompatibleDC (hdc)
		sBitmapLast = SelectObject (hdcSrc, hSrc)
		GetObjectA (hSrc, SIZE(bm), &bm)
		swidth  = bm.width
		sheight = bm.height
		ReleaseDC (0, hdc)
	END IF

	IF (sx2 = -1) || (sx2 > swidth) THEN sx2 = swidth
	IF (sy2 = -1) || (sy2 > sheight) THEN sy2 = sheight

	IF sy2 < sy1 THEN SWAP sy2, sy1
	IF sx2 < sx1 THEN SWAP sx2, sx1

	swidth = sx2 - sx1
	sheight = sy2 - sy1

	IF ((swidth <= 0) OR (sheight <= 0)) THEN
		GOSUB CleanUp
		RETURN ($$FALSE)
	END IF

	hdc     		= GetDC (0)
	hdcMask  		= CreateCompatibleDC (hdc)
	mBitmapLast = SelectObject (hdcMask, hMask)
	ReleaseDC (0, hdc)

' create temp memory bitmap
	XbmCreateMemBitmap (0, swidth, sheight, @hTmp)
	hdc     		= GetDC (0)
	hdcTmp  		= CreateCompatibleDC (hdc)
	tBitmapLast = SelectObject (hdcTmp, hTmp)
	ReleaseDC (0, hdc)

'BitBlt dest into tmp using SRCCOPY
	ok = BitBlt (hdcTmp, 0, 0, swidth, sheight, hdcDest, dx1, dy1, $$SRCCOPY)

'BitBlt tmp with the mask using AND (SRCAND)
	ok = BitBlt (hdcTmp, 0, 0, swidth, sheight, hdcMask, mx1, my1, $$SRCAND)

'BitBlt tmp with the source using XOR (SRCINVERT)
	ok = BitBlt (hdcTmp, 0, 0, swidth, sheight, hdcSrc, sx1, sy1, $$SRCINVERT)

'BitBlt dest with tmp using SRCCOPY
	ok = BitBlt (hdcDest, dx1, dy1, swidth, sheight, hdcTmp, 0, 0, $$SRCCOPY)

	GOSUB CleanUp
	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)

' ***** CleanUp *****
SUB CleanUp
	IF XbmGetImageType (hDest) = $$IMAGE_SCREEN THEN
		ReleaseDC (hDest, hdcDest)
	ELSE
		SelectObject (hdcDest, dBitmapLast)
		DeleteDC (hdcDest)
	END IF

	IF XbmGetImageType (hSrc) = $$IMAGE_SCREEN THEN
		ReleaseDC (hSrc, hdcSrc)
	ELSE
		SelectObject (hdcSrc, sBitmapLast)
		DeleteDC (hdcSrc)
	END IF

	SelectObject (hdcMask, mBitmapLast)
	SelectObject (hdcTmp, tBitmapLast)
	DeleteObject (hTmp)
	DeleteDC (hdcMask)
	DeleteDC (hdcTmp)

END SUB

END FUNCTION
'
'
' ##############################
' #####  XbmLoadBitmap ()  #####
' ##############################
'
'	/*
'	[XbmLoadBitmap]
' Description = The XbmLoadBitmap function loads a bitmap resource from the executable file into an image array.
' Function    = error = XbmLoadBitmap (name$, @image[])
' ArgCount    = 2
'	Arg1        = name$ : The name of the bitmap to be loaded or resource identifier (id is low-word, zero in high word).
' Arg2        = image[] : Returned DIB UBYTE image array.
'	Return      = If the function succeeds, the return value is -1.  If the function fails, the return value is 0.
' Remarks     = This function is a wrapper for LoadBitmapA.
'	See Also    = See demo program xbmtest.x.
'	Examples    =
'	*/
'
FUNCTION  XbmLoadBitmap (name$, UBYTE image[])

	IFZ name$ THEN RETURN

	hBitmap = LoadBitmapA (GetModuleHandleA (0), &name$)
	IFZ hBitmap THEN RETURN

	ret = XbmGetImage (hBitmap, @image[])
	DeleteObject (hBitmap)
	RETURN ret

END FUNCTION
'
'
' ################################
' #####  XbmGetImageSize ()  #####
' ################################
'
'	/*
'	[XbmGetImageSize]
' Description = The XbmGetImageSize function returns the width and height from a screen or bitmap object.
' Function    = error = XbmGetImageSize (hImage, @width, @height)
' ArgCount    = 3
'	Arg1        = hImage : Handle of window or bitmap object.
' Arg2        = bpp : Returned image width.
' Arg3        = bpp : Returned image height.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XbmGetImageSize (hImage, @width, @height)

	RECT rect
	BITMAP bm

	IFZ hImage THEN RETURN ($$FALSE)
	IFZ XbmGetImageType (hImage) THEN RETURN ($$FALSE)

	IF XbmGetImageType (hImage) = $$IMAGE_SCREEN THEN
		GetClientRect (hImage, &rect)
		width  = rect.right
		height = rect.bottom
	ELSE
		GetObjectA (hImage, SIZE(bm), &bm)
		width  = bm.width
		height = bm.height
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
' ########################
' #####  XbmLoadGif  #####
' ########################
'
'
'	/*
'	[XbmLoadGif]
' Description = The XbmLoadGif function loads a gif file into an image array. The gif image is converted to a 24-bit color image.
' Function    = error = XbmLoadImage (fileName$, @image[])
' ArgCount    = 2
'	Arg1        = gifFile$ : The filename of the gif image to be loaded (*.gif).
' Arg2        = image[] : Returned DIB UBYTE image array.
'	Return      = If the function succeeds, the return value is -1.  If the function fails, the return value is 0.
' Remarks     =
'	See Also    =
'	Examples    = See viewer.x under \xlibs\xil\viewer\
'	*/
'
FUNCTION XbmLoadGif (gifFile$, UBYTE image[])

	SHARED  GifColorTableEntry  colorTable[]
	AUTO  USHORT  bitmask[]
	AUTO  GifHeader  gifHeader
	AUTO  GifLogicalScreenDescriptor  gifLogicalScreenDescriptor
	AUTO  GifImageDescriptor  gifImageDescriptor
	AUTO  UBYTE  raw[]
	AUTO  code$[]
	GifGraphicControlExtension ggce
'
	$BI_RGB       = 0					        ' 24-bit RGB

'	print = $$TRUE										' uncomment this line to print results
	IF print THEN PRINT "LoadGIF file :", gifFile$

	ifile = OPEN (gifFile$, $$RD)			' open GIF file
	IF (ifile < 3) THEN RETURN				' did not open
	error = ERROR (0)									' reset error
	IF error THEN RETURN							' but skip this file
'
	bytes = LOF (ifile)								' size of GIF file in bytes
	upper = bytes - 1									' upper element in array of UBYTEs
	DIM gif[upper]										' create UBYTE array for GIF image
'
	READ [ifile], gif[]								' read the whole GIF file
	CLOSE (ifile)											' close the GIF file
'
	error = ERROR (0)									' error in READ ???
	IF error THEN RETURN							' READ did not work

	DIM image[]
	IFZ gif[] THEN RETURN
	
	ugif = UBOUND (gif[])
	IF (ugif < 32) THEN RETURN
	
	' check header for GIF8
	g = gif[0]
	g0 = g{8, 0} 
	g1 = g{8, 8} 
	g2 = g{8, 16} 
	g3 = g{8, 24} 
	IF g0 <> 'G' || g1 <> 'I' || g2 <> 'F' || g3 <> '8' THEN RETURN

	GOSUB Initialize

	gifaddr = &gif[]
	error = $$FALSE
'	print = $$TRUE
'
	IFZ error THEN
		GOSUB GetGifHeader
		IF print THEN GOSUB PrintGifHeader
	END IF
'
	IFZ error THEN
		GOSUB GetGifLogicalScreenDescriptor
		IF print THEN GOSUB PrintGifLogicalScreenDescriptor
	END IF
'
	IFZ error THEN
		IF colorTableFlag THEN
			IF colorsInColorTable THEN
				GOSUB GetGifColorTable
				IF print THEN GOSUB PrintGifColorTable
			END IF
		END IF
	END IF
'
	IFZ error THEN
		GOSUB GetGraphicControlExtension
		IF gcIntroducer = 0x21 THEN
			IF print THEN GOSUB PrintGraphicControlExtension
		END IF
	END IF
'
	IFZ error THEN
		GOSUB GetGifImageDescriptor
		IF print THEN GOSUB PrintGifImageDescriptor
		IF (imageSeparator != 0x2C) THEN error = $$TRUE
	END IF
'
	IFZ error THEN
		IF colorTableFlag THEN
			IF colorsInColorTable THEN
				GOSUB GetGifColorTable
				IF print THEN GOSUB PrintGifColorTable
			END IF
		END IF
	END IF
'
	dataOffset = 54                 ' 128
	bmpheight  = imageHeight
	bmpwidth   = imageWidth
	bmpline    = ((imageWidth * 3) + 3) AND -4
	bmpsize    = dataOffset + (bmpheight * bmpline)
	pixels     = imageWidth * imageHeight

	uraw = UBOUND (gif[])
	ubmp = bmpsize - 1
'
	IF error THEN RETURN
'
	raw = 0
	DIM raw[uraw]
	DIM image[ubmp]
	rawaddr = &raw[]
	DIM code$[4095]
	GOSUB FillBitmapHeader
'
	IFZ error THEN
		IF colorTableFlag THEN
			IF colorsInColorTable THEN
				GOSUB GetGifColorTable
				IF print THEN GOSUB PrintGifColorTable
			END IF
		END IF
	END IF
'
	IFZ error THEN
		GOSUB GetGifMinimumCodeSize
		IF print THEN GOSUB PrintGifMinimumCodeSize
	END IF
'
'		PRINT HEX$ (addr,8)
'		PRINT HEX$ (daddr,8); RJUST$(STRING$(daddr-addr),6)
'		PRINT HEX$ (bmpaddr,8); RJUST$(STRING$(bmpaddr-addr),6)
'		PRINT HEX$ (uaddr,8); RJUST$(STRING$(uaddr-addr),6)
'
	IFZ error THEN
		GOSUB GetGifImage
		GOSUB DrawGifImage
	END IF
'
'	PRINT HEX$ (addr,8)
'	PRINT HEX$ (daddr,8); RJUST$(STRING$(daddr-addr),6)
'	PRINT HEX$ (bmpaddr,8); RJUST$(STRING$(bmpaddr-addr),6)
'	PRINT HEX$ (uaddr,8); RJUST$(STRING$(uaddr-addr),6)
'
'	ofile = OPEN (ofile$, $$WRNEW)		' create file to hold BMP image
'	IF (ofile < 3) THEN RETURN				' open error
'	error = ERROR (0)									' error ???
'
'	WRITE [ofile], image[]							' save BMP image in file
'	CLOSE (ofile)											' close output BMP file
'
	RETURN ($$TRUE)
'
'
'
' *****  FillBitmapHeader  *****
'
SUB FillBitmapHeader
	addr = &image[]												' header
	uaddr = addr + ubmp									' upper
	daddr = addr + dataOffset						' fixed
	bmpaddr = addr + dataOffset					' moves

'	UBYTEAT (addr, 0) = 'B'							' signature
'	UBYTEAT (addr, 1) = 'M'							' signature
'	XLONGAT (addr, 2) = bmpsize					' bytes in array
'	XLONGAT (addr, 10) = dataOffset			' from beginning of array

  image[0] = 'B'
  image[1] = 'M'
  image[2] = bmpsize AND 0x00FF
  image[3] = (bmpsize >> 8)  AND 0x00FF
  image[4] = (bmpsize >> 16) AND 0x00FF
  image[5] = (bmpsize >> 24) AND 0x00FF
  image[6] = 0
  image[7] = 0
  image[8] = 8
  image[9] = 0
  image[10] = dataOffset AND 0x00FF
  image[11] = (dataOffset >> 8)  AND 0x00FF
  image[12] = (dataOffset >> 16) AND 0x00FF
  image[13] = (dataOffset >> 24) AND 0x00FF
'
'	fill BITMAPINFOHEADER (first 6 members)
	iaddr = addr + 14										' info header address
'	XLONGAT (iaddr, 0) = 40							' bytes in this sub-header
'	XLONGAT (iaddr, 4) = bmpwidth				' in pixels
'	XLONGAT (iaddr, 8) = bmpheight			' in pixels
'	USHORTAT (iaddr, 12) = 1						' 1 image plane
'	USHORTAT (iaddr, 14) = 24						' bits per pixel
'	XLONGAT (iaddr, 16) = $$BI_RGB			' 24-bit indicator
'
	info = 14
	image[info+0]  = 40													  ' XLONG : BITMAPINFOHEADER size
	image[info+1]  = 0
	image[info+2]  = 0
	image[info+3]  = 0
	image[info+4]  = bmpwidth AND 0x00FF					' XLONG : width in pixels
	image[info+5]  = (bmpwidth >> 8) AND 0x00FF
	image[info+6]  = (bmpwidth >> 16) AND 0x00FF
	image[info+7]  = (bmpwidth >> 24) AND 0x00FF
	image[info+8]  = bmpheight AND 0x00FF					' XLONG : height in pixels
	image[info+9]  = (bmpheight >> 8)  AND 0x00FF
	image[info+10] = (bmpheight >> 16) AND 0x00FF
	image[info+11] = (bmpheight >> 24) AND 0x00FF
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

'
'	caddr = iaddr + 40									' color header address
'	XLONGAT (caddr, 0) = 0xFFC00000			' 32-bit color only
'	XLONGAT (caddr, 4) = 0x003FF800			' 32-bit color only
'	XLONGAT (caddr, 8) = 0x000007FF			' 32-bit color only
END SUB
'
SUB GetGifHeader
'	XstCopyMemory (gifaddr, &gifHeader, 6)
	RtlMoveMemory (&gifHeader, gifaddr, 6)
	gifaddr = gifaddr + 6
END SUB
'
SUB PrintGifHeader
	PRINT
	PRINT "GifHeader.signature                             = "; RJUST$("\"" + gifHeader.signature + "\"", 8); " : must be \"GIF\""
	PRINT "GifHeader.version                               = "; RJUST$("\"" + gifHeader.version + "\"", 8); " : must be \"89a\""
END SUB
'
SUB GetGifLogicalScreenDescriptor
'	XstCopyMemory (gifaddr, &gifLogicalScreenDescriptor, 7)
	RtlMoveMemory (&gifLogicalScreenDescriptor, gifaddr, 7)
	gifaddr = gifaddr + 7
'
	screenWidth          = (gifLogicalScreenDescriptor.widthMSB << 8) OR gifLogicalScreenDescriptor.widthLSB
	screenHeight         = (gifLogicalScreenDescriptor.heightMSB << 8) OR gifLogicalScreenDescriptor.heightLSB
	backgroundColorIndex = gifLogicalScreenDescriptor.backgroundColorIndex
	pixelAspectRatio     = gifLogicalScreenDescriptor.pixelAspectRatio
'
	bitfields            = gifLogicalScreenDescriptor.bitfields
	colorTableFlag       = (bitfields AND 0x80) >> 7
	colorResolution      = (bitfields AND 0x70) >> 4
	sortFlag             = (bitfields AND 0x08) >> 3
	sizeOfColorTable     = bitfields AND 0x07
	colorsInColorTable   = 0x01 << (sizeOfColorTable + 1)
	bytesInColorTable    = 3 * colorsInColorTable
END SUB
'
SUB PrintGifLogicalScreenDescriptor
	PRINT
	PRINT "GifLogicalScreenDescriptor.width                = "; RJUST$(HEX$(gifLogicalScreenDescriptor.widthLSB OR (gifLogicalScreenDescriptor.widthMSB << 8),4),8); " : image width in pixels"
	PRINT "GifLogicalScreenDescriptor.height               = "; RJUST$(HEX$(gifLogicalScreenDescriptor.heightLSB OR (gifLogicalScreenDescriptor.heightMSB << 8),4),8); " : image height in pixels"
	PRINT "GifLogicalScreenDescriptor.bitfields            = "; BIN$(gifLogicalScreenDescriptor.bitfields,8); " : 1,3,1,3 bit fields ...)"
	PRINT "   .bitfields.globalColorTableFlag              = "; BIN$(colorTableFlag,1); "        = "; : IF (colorTableFlag) THEN PRINT "TRUE" ELSE PRINT "FALSE"
	PRINT "   .bitfields.colorResolution                   =  "; BIN$(colorResolution,3); "     = "; STRING$(colorResolution+1); " bits per primary color"
	PRINT "   .bitfields.sortFlag                          =     "; BIN$(sortFlag, 1); "    = "; IF sortFlag THEN PRINT "TRUE" ELSE PRINT "FALSE"
	PRINT "   .bitfields.sizeOfGlobalColorTable            =      "; BIN$(sizeOfColorTable, 3); " = "; STRING$(bytesInColorTable); " bytes in global color table"
	PRINT "              colorsInColorTable                =          : "; STRING$(colorsInColorTable)
	PRINT "              bytesInColorTable                 =          : "; STRING$(bytesInColorTable)
	PRINT "GifLogicalScreenDescriptor.backgroundColorIndex = "; RJUST$(HEX$(gifLogicalScreenDescriptor.backgroundColorIndex,2),8)
	PRINT "GifLogicalScreenDescriptor.pixelAspectRatio     = "; RJUST$(HEX$(gifLogicalScreenDescriptor.pixelAspectRatio,2),8)
END SUB
'
SUB GetGifColorTable
	upper = colorsInColorTable - 1
	DIM colorTable[upper]
'
	FOR i = 0 TO upper
'		XstCopyMemory (gifaddr, &colorTable[i], 3)
		RtlMoveMemory (&colorTable[i], gifaddr, 3)
		gifaddr = gifaddr + 3
	NEXT i
END SUB
'
SUB PrintGifColorTable
	upper = UBOUND (colorTable[])
'
	PRINT
	FOR i = 0 TO upper
		r = colorTable[i].r
		g = colorTable[i].g
		b = colorTable[i].b
'		PRINT "color "; HEX$(i,4); " : RGB = "; HEX$(r,2); "."; HEX$(g,2); "."; HEX$(b,2)
	NEXT i
END SUB
'
SUB GetGraphicControlExtension
	ext = UBYTEAT (gifaddr)
	IF ext = 0x21 THEN				' get extension
'		XstCopyMemory (gifaddr, &ggce, 8)
		RtlMoveMemory (&ggce, gifaddr, 8)
		gifaddr = gifaddr + 8

		gcIntroducer            = ggce.extensionIntroducer
		gcControlLabel          = ggce.graphicControlLabel
		gcBlockSize             = ggce.blockSize
		gcBitfields             = ggce.bitfields
		gcDisposalMethod        = (gcBitfields AND 0x1C) >> 2
		gcUserInputFlag         = (gcBitfields AND 0x2) >> 1
		gcTransparentColorFlag  = (gcBitfields AND 0x1)
		gcDelayTime             = (ggce.delayTimeMSB << 8) OR ggce.delayTimeLSB
		gcTransparentColorIndex = ggce.transparentColorIndex
		gcBlockTerminator       = ggce.blockTerminator
	END IF
END SUB
'
SUB PrintGraphicControlExtension
	PRINT "ggce.extensionIntroducer            = "; RJUST$(HEX$(gcIntroducer,4),8); " must be 0x21"
	PRINT "ggce.graphicControlLabel            = "; RJUST$(HEX$(gcControlLabel,4),8); " = "; STRING$(gcControlLabel); " fixed value 0xF9"
	PRINT "ggce.blockSize                      = "; RJUST$(HEX$(gcBlockSize,4),8); " = "; STRING$(gcBlockSize); " fixed value 4"
	PRINT "ggce.bitfields                      = "; BIN$(gcBitfields,8)
	PRINT "  .bitfields.gcDisposalMethod       =    "; BIN$(gcDisposalMethod,3)
	PRINT "  .bitfields.gcUserInputFlag        =       "; BIN$(gcUserInputFlag,1)
	PRINT "  .bitfields.gcTransparentColorFlag =        "; BIN$(gcTransparentColorFlag,1)
	PRINT "gcDelayTime                         = "; RJUST$(HEX$(gcDelayTime,4),8); " = "; STRING$(gcDelayTime)
	PRINT "ggce.transparentColorIndex          = "; RJUST$(HEX$(gcTransparentColorIndex,4),8); " = "; STRING$(gcTransparentColorIndex)
	PRINT "ggce.blockTerminator                = "; RJUST$(HEX$(gcBlockTerminator,4),8); " = "; STRING$(gcBlockTerminator)
END SUB
'
SUB GetGifImageDescriptor
'	XstCopyMemory (gifaddr, &gifImageDescriptor, 10)
	RtlMoveMemory (&gifImageDescriptor, gifaddr, 10)
	gifaddr = gifaddr + 10
'
	imageSeparator     = gifImageDescriptor.imageSeparator
	imageLeftPosition  = gifImageDescriptor.imageLeftPositionLSB OR (gifImageDescriptor.imageLeftPositionMSB << 8)
	imageTopPosition   = gifImageDescriptor.imageTopPositionLSB OR (gifImageDescriptor.imageTopPositionMSB << 8)
	imageWidth         = gifImageDescriptor.imageWidthLSB OR (gifImageDescriptor.imageWidthMSB << 8)
	imageHeight        = gifImageDescriptor.imageHeightLSB OR (gifImageDescriptor.imageHeightMSB << 8)
	bitfields          = gifImageDescriptor.bitfields
'
	colorTableFlag     = (bitfields AND 0x80) >> 7
	interlaceFlag      = (bitfields AND 0x40) >> 6
	sortFlag           = (bitfields AND 0x20) >> 5
	reserved           = (bitfields AND 0x18) >> 3
	sizeOfColorTable   = bitfields AND 0x07
	colorsInColorTable = 0x01 << (sizeOfColorTable + 1)
	bytesInColorTable  = 3 * colorsInColorTable
END SUB
'
SUB PrintGifImageDescriptor
	PRINT
	PRINT "GifImageDescriptor.imageSeparator               = "; RJUST$(HEX$(imageSeparator,2),8); " : must be 2C"
	PRINT "GifImageDescriptor.imageLeftPosition            = "; RJUST$(HEX$(imageLeftPosition,4),8); " = "; STRING$(imageLeftPosition)
	PRINT "GifImageDescriptor.imageTopPosition             = "; RJUST$(HEX$(imageTopPosition,4),8); " = "; STRING$(imageTopPosition)
	PRINT "GifImageDescriptor.imageWidth                   = "; RJUST$(HEX$(imageWidth,4),8); " = "; STRING$(imageWidth)
	PRINT "GifImageDescriptor.imageHeight                  = "; RJUST$(HEX$(imageHeight,4),8); " = "; STRING$(imageHeight)
	PRINT "GifImageDescriptor.bitfields                    = "; BIN$(bitfields,8)
	PRINT "   .bitfields.colorTableFlag                    = "; BIN$(colorTableFlag,1)
	PRINT "   .bitfields.interlaceFlag                     =  "; BIN$(interlaceFlag,1)
	PRINT "   .bitfields.sortFlag                          =   "; BIN$(sortFlag,1)
	PRINT "   .bitfields.reserved                          =    "; BIN$(reserved,2)
	PRINT "   .bitfields.sizeOfColorTable                  =      "; BIN$(sizeOfColorTable,3)
	PRINT "              colorsInColorTable                =          : "; STRING$(colorsInColorTable)
	PRINT "              bytesInColorTable                 =          : "; STRING$(bytesInColorTable)
END SUB
'
SUB GetGifMinimumCodeSize
	minimumCodeSize = UBYTEAT (gifaddr)
	gifaddr = gifaddr + 1
END SUB
'
SUB PrintGifMinimumCodeSize
	PRINT
	PRINT "GifMinimumCodeSize                              = "; RJUST$(HEX$(minimumCodeSize,2),8)
END SUB
'
SUB GetGifImage
	DO
		blockSize = UBYTEAT (gifaddr)
		gifaddr = gifaddr + 1
'
		IF blockSize THEN
'			XstCopyMemory (gifaddr, rawaddr, blockSize)
			RtlMoveMemory (rawaddr, gifaddr, blockSize)
			gifaddr = gifaddr + blockSize
			rawaddr = rawaddr + blockSize
			raw = raw + blockSize
		END IF
	LOOP WHILE blockSize
END SUB
'
SUB DrawGifImage
	pass = 0
	offbit = 0
	offbyte = 0
	bits = minimumCodeSize + 1
	clearCode = 1 << minimumCodeSize
	terminateCode = clearCode + 1
	maximumValue = clearCode - 1
	widthCode = clearCode << 1
'
	FOR i = 0 TO clearCode-1
		code$[i] = CHR$(i)
	NEXT i
'
	x = 0
	y = 0
'
	char$ = ""
	slot = 130
	done = $$FALSE
'
	GOSUB GetNewCode
	IF (new != clearCode) THEN STOP
	GOSUB ClearCode
'
	DO
		GOSUB GetNewCode
		terminate = $$FALSE
		IF ((offbyte + 3) >= uraw) THEN EXIT SUB
		SELECT CASE TRUE
			CASE (new = clearCode)			: GOSUB ClearCode
			CASE (new = terminateCode)	: IF print THEN PRINT "terminateCode"
																		EXIT DO
			CASE ELSE										:	string$ = code$[new]
																		IFZ string$ THEN string$ = code$[old] + char$
																		GOSUB DrawString
																		IFZ terminate THEN
																			char$ = CHR$(string${0})
																			IF (slot > UBOUND(code$[])) THEN EXIT SUB
																			code$[slot] = code$[old] + char$
																			old = new
																			INC slot
																			IF (slot >= widthCode) THEN
																				IF print THEN PRINT HEX$(offbyte,8); " tableFull : bits = "; RJUST$(STRING$(bits),2); " to "; RJUST$(STRING$(bits+1),2); " : slot = "; RJUST$(STRING$(slot-1),2); " to "; RJUST$(STRING$(slot),2)
																				IF (bits < 12) THEN
																					widthCode = widthCode << 1
																					INC bits
																				END IF
																			END IF
																		END IF
		END SELECT
	LOOP UNTIL terminate
END SUB
'
SUB GetNewCode
	offbyte = offbit >> 3
	bitaddr = offbit AND 0x07
	IF ((offbyte + 3) >= uraw) THEN EXIT SUB
	new = raw[offbyte] OR (raw[offbyte+1] << 8) OR (raw[offbyte+2] << 16 OR raw[offbyte+3] << 24)
	new = new >> bitaddr
	new = new AND bitmask[bits]
	offbit = offbit + bits
	IF (offbyte >= uraw) THEN STOP
END SUB
'
SUB ClearCode
	oldbits = bits
	slot = terminateCode + 1
	REDIM code$[clearCode-1]
	bits = minimumCodeSize + 1
	widthCode = clearCode << 1
	REDIM code$[4095]
	IF print THEN PRINT HEX$(offbyte,8); " clearCode : bits = "; RJUST$(STRING$(oldbits),2); " to "; RJUST$(STRING$(bits),2); " : slot = "; RJUST$(STRING$(slot),2)
	GOSUB GetNewCode
	string$ = code$[new]
	GOSUB DrawString
'	char$ = CHR$(string${0})																	' old
	IF string$ THEN	char$ = CHR$(string${0}) ELSE char$ = ""	' new
	old = new
END SUB
'
SUB DrawString
	u = UBOUND (string$)
'
	FOR n = 0 TO u
		pixel = string${n}
		r = colorTable[pixel].r
		g = colorTable[pixel].g
		b = colorTable[pixel].b
'
		color = (r << 24) OR (g << 16) OR (b << 8)
'
		IF image[] THEN
			IFZ x THEN
				bmpy = bmpheight - y - 1					' y in bitmap - inverted
				bmp0 = daddr + (bmpy * bmpline)		' address of 1st pixel on line
				bmpaddr = bmp0
'
' added to catch disasterous error - fixed in v0.0082
'
				xlasty = y
				xlastbmpline = bmpline
				IF ((bmpaddr < daddr) OR (bmpaddr > uaddr)) THEN
					IF print THEN PRINT HEX$(bmpaddr,8);; HEX$(daddr,8);; HEX$(uaddr,8);; HEX$(bmp0,8);; bmpy;; bmpheight;; bmpline;; xlastbmpline;; xlasty;; imageWidth;; imageHeight
					terminate = $$TRUE
					EXIT SUB
				END IF
			END IF
'
'
'
			UBYTEAT (bmpaddr) = b	: INC bmpaddr
			UBYTEAT (bmpaddr) = g	: INC bmpaddr
			UBYTEAT (bmpaddr) = r	: INC bmpaddr
'
		END IF
'
		INC x
		IF (x >= imageWidth) THEN
			x = 0
			IFZ interlaceFlag THEN
				y = y + 1
			ELSE
				SELECT CASE pass
					CASE 0		: y = y + 8
					CASE 1		: y = y + 8
					CASE 2		: y = y + 4
					CASE 3		: y = y + 2
					CASE ELSE	: STOP
				END SELECT
			END IF
		END IF
'
		IF (y >= imageHeight) THEN
			INC pass
			IFZ interlaceFlag THEN
				y = y + 1
			ELSE
				SELECT CASE pass
					CASE 1		: y = 4
					CASE 2		: y = 2
					CASE 3		: y = 1
					CASE ELSE	: INC y			' past end of image
				END SELECT
				IF (y >= imageHeight) THEN
					IF print THEN PRINT HEX$(bmpaddr,8);; HEX$(daddr,8);; HEX$(bmp0,8);; bmpy;; bmpheight;; bmpline;; xlastbmpline;; xlasty;; imageWidth;; imageHeight
					terminate = $$TRUE
					EXIT FOR
				END IF
			END IF
		END IF
	NEXT n

END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM bitmask[31]
	bitmask[ 0] = 0x00000000
	bitmask[ 1] = 0x00000001
	bitmask[ 2] = 0x00000003
	bitmask[ 3] = 0x00000007
	bitmask[ 4] = 0x0000000F
	bitmask[ 5] = 0x0000001F
	bitmask[ 6] = 0x0000003F
	bitmask[ 7] = 0x0000007F
	bitmask[ 8] = 0x000000FF
	bitmask[ 9] = 0x000001FF
	bitmask[10] = 0x000003FF
	bitmask[11] = 0x000007FF
	bitmask[12] = 0x00000FFF
	bitmask[13] = 0x00001FFF
	bitmask[14] = 0x00003FFF
	bitmask[15] = 0x00007FFF
	bitmask[16] = 0x0000FFFF
	bitmask[17] = 0x0001FFFF
	bitmask[18] = 0x0003FFFF
	bitmask[19] = 0x0007FFFF
	bitmask[20] = 0x000FFFFF
	bitmask[21] = 0x001FFFFF
	bitmask[22] = 0x003FFFFF
	bitmask[23] = 0x007FFFFF
	bitmask[24] = 0x00FFFFFF
	bitmask[25] = 0x01FFFFFF
	bitmask[26] = 0x03FFFFFF
	bitmask[27] = 0x07FFFFFF
	bitmask[28] = 0x0FFFFFFF
	bitmask[29] = 0x1FFFFFFF
	bitmask[30] = 0x3FFFFFFF
	bitmask[31] = 0x7FFFFFFF
END SUB

END FUNCTION
END PROGRAM
