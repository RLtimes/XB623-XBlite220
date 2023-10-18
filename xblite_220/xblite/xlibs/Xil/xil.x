'
' #################### David Szafranski
' #####  PROLOG  ##### copyright 2002
' #################### XBLite image processing library
'
' Xil is an image processing library for XBLite. It
' contains functions to transform and filter images,
' as well as perform masking operations.
'
' Code examples were translated from C/VB and other sources
' including VB examples by Steve McMahon.
'
' (c) GPL 2005 David SZAFRANSKI
' david.szafranski@wanadoo.fr
'
'
PROGRAM	"xil"
VERSION	"0.0015"
'
' v0.0015 5-24-2005
' Added XilResizeBiQuad, XilResizeBiCubic, XilDilate, and XilErode functions.
' Added XilGaussianBlur, CreateGaussianKernel.
' Added XilDetectEdgeSobel, XilDetectEdgeLaplace, XilDetectEdgeCanny.
' Added XilDetectEdgeZeroCrossing. 
' Added XilDitherFS, XilDither8x8, XilDitherBayer8x8, XilDitherUlichney.
' Added XilDitherEfficientED, XilSmoothKuwahara, XilThumbnail.
' Corrected bug in HistogramCalc.
' Removed XilDetectEdge, XilBinarize, XilBinarize1 
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT  "xma"
	IMPORT  "gdi32"
	IMPORT  "user32"
	IMPORT	"msvcrt"
	IMPORT	"kernel32"
'
	TYPE RGB4
		UBYTE	.red
		UBYTE .blue
		UBYTE	.green
		UBYTE	.reserved
	END TYPE
	
	TYPE T_THREE_COEFS
    DOUBLE .i_r        ' right 
    DOUBLE .i_dl       ' down-left
    DOUBLE .i_d        ' down
    DOUBLE .i_sum      ' sum
	END TYPE
	'
EXPORT
DECLARE FUNCTION  Xil         ()
END EXPORT
EXPORT
' image transformation/manipulation functions
DECLARE FUNCTION  XilAddImages (UBYTE source1[], UBYTE source2[], UBYTE dest[], s1Factor, s1OffsetR, s1OffsetG, s1OffsetB, s2Factor, s2OffsetR, s2OffsetG, s2OffsetB)
DECLARE FUNCTION  XilCombineImages (UBYTE source1[], UBYTE source2[], UBYTE dest[], dx1, dy1, DOUBLE percent)
DECLARE FUNCTION  XilCrop (UBYTE source[], UBYTE dest[], x1, y1, x2, y2)
DECLARE FUNCTION  XilFlip (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilMirror (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilResize (UBYTE source[], UBYTE dest[], destWidth, destHeight)
DECLARE FUNCTION  XilResizeBiCubic (UBYTE source[], UBYTE dest[], DOUBLE ratio)
DECLARE FUNCTION  XilResizeBiQuad (UBYTE source[], UBYTE dest[], destWidth, destHeight)
DECLARE FUNCTION  XilResizeCanvas (UBYTE source[], UBYTE dest[], destWidth, destHeight, align, backColor)
DECLARE FUNCTION  XilResizeProportional (UBYTE source[], UBYTE dest[], DOUBLE percent)
DECLARE FUNCTION  XilRotate (UBYTE source[], UBYTE dest[], DOUBLE degrees, @destWidth, @destHeight)
DECLARE FUNCTION  XilThumbnail (UBYTE source[], UBYTE dest[], DOUBLE ratio)
DECLARE FUNCTION  XilTile (UBYTE source[], UBYTE dest[], destWidth, destHeight)
'
' image filter functions
DECLARE FUNCTION  XilAND (UBYTE source[], UBYTE dest[], backColor)
DECLARE FUNCTION  XilBlur (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilBlurMore (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilContrast (UBYTE source[], UBYTE dest[], mode, DOUBLE contrast)
DECLARE FUNCTION  XilDetectEdgeCanny (UBYTE source[], UBYTE dest[], DOUBLE sigma, thresh)
DECLARE FUNCTION  XilDetectEdgeLaplace (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilDetectEdgeLaplace3x3 (UBYTE source[], UBYTE dest[], fLaplace)
DECLARE FUNCTION  XilDetectEdgeSobel (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilDetectEdgeZeroCrossing (UBYTE source[], UBYTE dest[], DOUBLE sigma, thresh, fLaplace)
DECLARE FUNCTION  XilDilate (UBYTE source[], UBYTE dest[], level)
DECLARE FUNCTION  XilEmboss (UBYTE source[], UBYTE dest[], direction)
DECLARE FUNCTION  XilEmbossQuick (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilErode (UBYTE source[], UBYTE dest[], level)
DECLARE FUNCTION  XilFade (UBYTE source[], UBYTE dest[], amount)
DECLARE FUNCTION  XilGamma (UBYTE source[], UBYTE dest[], DOUBLE gamma)
DECLARE FUNCTION  XilGaussianBlur (UBYTE source[], UBYTE dest[], DOUBLE sigma, scale)
DECLARE FUNCTION  XilHistogramEqualize (UBYTE source[], UBYTE dest[], DOUBLE exponent)
DECLARE FUNCTION  XilLighten (UBYTE source[], UBYTE dest[], percent)
DECLARE FUNCTION  XilNoise (UBYTE source[], UBYTE dest[], percent)
DECLARE FUNCTION  XilNormalize (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilSharpen (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilSharpenMore (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilSmoothKuwahara (UBYTE source[], UBYTE dest[], radius)
DECLARE FUNCTION  XilSoften (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilSoftenMore (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilXOR (UBYTE source[], UBYTE dest[])
'
' image masking functions
DECLARE FUNCTION  XilAsIcon (UBYTE source[], UBYTE dest[], backColor)
DECLARE FUNCTION  XilMask (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilMaskCombine (UBYTE source[], UBYTE mask[], UBYTE dest[])
'
' image color/palette functions
DECLARE FUNCTION  AddToPalette (red, green, blue)
DECLARE FUNCTION  CreateHalfTonePalette ()
DECLARE FUNCTION  CreateWebSafePalette ()
DECLARE FUNCTION  XilApplyPalette (UBYTE source[], UBYTE dest[], diffuseError)
DECLARE FUNCTION  XilColorize (UBYTE source[], UBYTE dest[], DOUBLE hue)
DECLARE FUNCTION  XilDither8x8 (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilDitherBayer8x8 (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilDitherEfficientED (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilDitherFS (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilDitherUlichney (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilGrayScale1 (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilGrayScale2 (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilGrayScale3 (UBYTE source[], UBYTE dest[])
DECLARE FUNCTION  XilHalfTonePaletteBest (UBYTE source[], UBYTE dest[], dither)
DECLARE FUNCTION  XilHalfTonePaletteFast (UBYTE source[], UBYTE dest[], dither)
DECLARE FUNCTION  XilWebSafePalette (UBYTE source[], UBYTE dest[], dither)

' custom filter functions
DECLARE FUNCTION  BuildFilterArray ()
DECLARE FUNCTION  GetFilterArraySize ()
DECLARE FUNCTION  GetFilterValue (x, y)
DECLARE FUNCTION  GetFilterWeight ()
DECLARE FUNCTION  SetFilterArraySize (size)
DECLARE FUNCTION  SetFilterValue (x, y, value)
DECLARE FUNCTION  SetFilterWeight (weight)
DECLARE FUNCTION  XilBuildCustomFilterArray (size, data$)
DECLARE FUNCTION  XilCustomFilter (UBYTE source[], UBYTE dest[], size, data$)
DECLARE FUNCTION  XilSetFilterType (type)
DECLARE FUNCTION  XilStandardFilter (UBYTE source[], UBYTE dest[])
'
' image info functions
DECLARE FUNCTION  XilGetImageArrayDetails (UBYTE image[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)
DECLARE FUNCTION  XilGetImageArrayInfo (UBYTE image[], @bpp, @width, @height)
'
' color conversion functions
DECLARE FUNCTION  RGBToHLS (r, g, b, DOUBLE h, DOUBLE s, DOUBLE l)
DECLARE FUNCTION  HLSToRGB (DOUBLE h, DOUBLE s, DOUBLE l, @r, @g, @b)
DECLARE FUNCTION  XilConvertColorToRGB (color, @r, @g, @b)
'
' misc helper functions
DECLARE FUNCTION  CumulativeSumArray (DOUBLE array[], DOUBLE cumSum[])
DECLARE FUNCTION  HistogramCalc (UBYTE source[], @histR[], @histG[], @histB[])
DECLARE FUNCTION  GetClosestIndex (@lIndex, r, g, b)
DECLARE FUNCTION  NextItem$ (source$, index, term, done)
DECLARE FUNCTION  DOUBLE RNUniform ()
DECLARE FUNCTION  ValidRange (@value, lower, upper)
DECLARE FUNCTION  CreateGaussianKernel (DOUBLE sigma, scale, @kernel[], @weight)
'
INTERNAL FUNCTION SetWeights (DOUBLE new_weights[], DOUBLE old_weights[])
INTERNAL FUNCTION DistributeError (x, y, DOUBLE diff, dir, input_level)
INTERNAL FUNCTION ShiftCarryBuffers ()
INTERNAL FUNCTION GetMeanAndVariance (data[], y, x, r, DOUBLE mean, DOUBLE variance)
INTERNAL FUNCTION GetBox (data[], DOUBLE x0, DOUBLE y0, DOUBLE x1, DOUBLE y1)
INTERNAL FUNCTION GetBicubic (data[], DOUBLE x, DOUBLE y)
INTERNAL FUNCTION GetCubicRow (data[], x, y, DOUBLE offset)
INTERNAL FUNCTION Cubic (DOUBLE offset, v0, v1, v2, v3)
'
$$RAND_MAX = 0x7FFF
'
' Filter Type Constants
'
$$Blur 				= 0
$$BlurMore		= 1
$$Soften			= 2
$$SoftenMore 	= 3
$$Sharpen			= 4
$$SharpenMore	= 5
$$Custom			= 6
$$MaxFilter		= 6
'
'
' Alignment/Direction Constants
'
$$AlignUpperLeft			=  1
$$AlignUpperCenter		=  2
$$AlignUpperRight			=  3
$$AlignMiddleLeft			=  5
$$AlignMiddleCenter		=  6
$$AlignMiddleRight		=  7
$$AlignLowerLeft			=  9
$$AlignLowerCenter		= 10
$$AlignLowerRight			= 11
'
' Laplacian masks for XilDetectEdgeLaplace3x3()
$$LAPLACIAN1 = 0	' "0,1,0,1,-4,1,0,1,0"
$$LAPLACIAN2 = 1 	' "1,1,1,1,-8,1,1,1,1"
$$LAPLACIAN3 = 2 	' "-1,2,-1,2,-4,2,-1,2,-1"
'
END EXPORT
'
'
' ######################
' #####  Xil ()  #####
' ######################
'
FUNCTION  Xil ()
	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE								' enter occured
'
	IF LIBRARY(0) THEN RETURN			' main program executes message loop
'
END FUNCTION
'
'
' #############################
' #####  XilAddImages ()  #####
' #############################
'
FUNCTION  XilAddImages (UBYTE source1[], UBYTE source2[], UBYTE dest[], s1Factor, s1OffsetR, s1OffsetG, s1OffsetB, s2Factor, s2OffsetR, s2OffsetG, s2OffsetB)

	IFZ source1[] THEN RETURN 0
	IFZ source2[] THEN RETURN 0

  XilGetImageArrayInfo(@source1[], @s1bpp, @s1width, @s1height)
  XilGetImageArrayInfo(@source2[], @s2bpp, @s2width, @s2height)
	XilGetImageArrayDetails (@source2[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF (s2bpp) <> 24 || (s1bpp) <> 24 THEN RETURN

	IF (s1width <> s2width) || (s1height <> s2height) THEN RETURN 0

'DIM destimation array dest[] to the same size as source2[]
	upper = UBOUND(source2[])
  DIM dest[upper]

'Copy source[] to dest[]
	RtlMoveMemory (&dest[0], &source2[0], SIZE(source2[]))

	offset = dataOffset

	FOR row = 0 TO s2height-1
		FOR column = 0 TO s2width-1

			rB = (source2[offset]   + s2OffsetB) * s2Factor + (source1[offset]   + s1OffsetB) * s1Factor
			rG = (source2[offset+1] + s2OffsetG) * s2Factor + (source1[offset+1] + s1OffsetG) * s1Factor
			rR = (source2[offset+2] + s2OffsetR) * s2Factor + (source1[offset+2] + s1OffsetR) * s1Factor

			IF (rR < 0) THEN rR = 0
			IF (rG < 0) THEN rG = 0
			IF (rB < 0) THEN rB = 0
			IF (rR > 255) THEN rR = 255
			IF (rG > 255) THEN rG = 255
			IF (rB > 255) THEN rB = 255

			dest[offset]   = rB
			dest[offset+1] = rG
			dest[offset+2] = rR
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row
	RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  XilAddImages ()  #####
' ################################
'
'PURPOSE 	:	Combine two source images
'IN				:	source1[], source2[]
'						dx1, dy1 - offset in source1 to place source2
'						percent  - percent of source2 to blend into source1
'OUT			:	dest[]

FUNCTION  XilCombineImages (UBYTE source1[], UBYTE source2[], UBYTE dest[], dx1, dy1, DOUBLE percent)

	IFZ source1[] THEN RETURN 0
	IFZ source2[] THEN RETURN 0

	upper = UBOUND(source1[])
	DIM dest[upper]

	IFZ percent THEN
		RtlMoveMemory (&dest[], &source1[], SIZE(source1[]))
		RETURN ($$TRUE)
	END IF

	IF percent > 100 THEN percent = 100

  XilGetImageArrayInfo(@source1[], @s1bpp, @s1width, @s1height)
  XilGetImageArrayInfo(@source2[], @s2bpp, @s2width, @s2height)
	XilGetImageArrayDetails (@source2[], @numColors, @s2fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)
	XilGetImageArrayDetails (@source1[], @numColors, @s1fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF (s2bpp) <> 24 || (s1bpp) <> 24 THEN RETURN

'source1[] must be larger than source2[]
	IF (s1width < s2width) || (s1height < s2height) THEN RETURN

'Copy source1[] to dest[]
	RtlMoveMemory (&dest[], &source1[], SIZE(source1[]))

'Note: A scanline must be zero-padded to end on a 32-bit boundary

'for source2[]
	s2rowLength = (s2width * 3) + 3 AND -4

'for source1[]
	s1rowLength = (s1width * 3) + 3 AND -4

	alpha = percent * 255/100.0

	IF s2height + dy1 > s1height THEN
		s1rowInit = 0
		rowInit = dy1
	ELSE
		s1rowInit = s1height - s2height - dy1
		rowInit = 0
	END IF

	s1row = s1rowInit

	FOR row = rowInit TO s2height-1
		s1column = dx1
		FOR column = 0 TO s2width-1
			s1byte 	= dataOffset + s1column*3 + (s1rowLength*s1row)
			s2byte 	= dataOffset + column*3 + (s2rowLength*row)

			dest[s1byte]   = (((source2[s2byte]   - source1[s1byte])*alpha   + (source1[s1byte] << 8)) >> 8)
			dest[s1byte+1] = (((source2[s2byte+1] - source1[s1byte+1])*alpha + (source1[s1byte+1] << 8)) >> 8)
			dest[s1byte+2] = (((source2[s2byte+2] - source1[s1byte+2])*alpha + (source1[s1byte+2] << 8)) >> 8)

			INC s1column
			IF s1column > s1width-1 THEN EXIT FOR
		NEXT column
		INC s1row
		IF s1row > s1height-1 THEN EXIT FOR
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  XilCrop ()  #####
' ###########################

' PURPOSE	: Crop source[] image
'	IN			: source[] image to crop
'					: x1, y1, x2, y2 are the coordinates in source to size cropped image
'	OUT			: dest[] image is the resulting cropped image
'
FUNCTION  XilCrop (UBYTE source[], UBYTE dest[], x1, y1, x2, y2)

	IFZ source[] THEN RETURN 0
	IF (x2 - x1 < 0) || (y2 - y1 < 0) THEN RETURN 0

	XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)

	destWidth = x2 - x1
	destHeight = y2 - y1

	IF (sWidth = destWidth) && (sHeight = destHeight) THEN RETURN 0
	IF (sWidth < destWidth) || (sHeight < destHeight) THEN RETURN 0

	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc size of dest[]
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}

	doffset = dataOffset

	FOR row = y1 TO y2-1									'copy source to dest
		FOR column = x1 TO x2-1
			sourceByte = dataOffset + column*3  + (sRowBytes*row)
			dest[doffset] 		= source[sourceByte]
			dest[doffset+1] 	= source[sourceByte+1]
			dest[doffset+2] 	= source[sourceByte+2]
			doffset = doffset + 3
		NEXT column
		align = (doffset - 54){2,0}											' ok if align = 0
		IF align THEN doffset = doffset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  XilFlip()  #####
' ##########################
'
FUNCTION  XilFlip (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bitPerPixel, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bitPerPixel <> 24 THEN RETURN

'Get source bytes per row
	rowBytes = (width * 3) + 3 AND -4

	DIM dest[fileSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'swap end for end data bytes along height
	FOR y = 0 TO height-1
		FOR x = 0 TO width-1
			ny = height-1-y
			dbyteAddr = doffsetAddr + rowBytes*ny + x*3
			UBYTEAT(dbyteAddr)	 = UBYTEAT(soffsetAddr)
			UBYTEAT(dbyteAddr+1) = UBYTEAT(soffsetAddr+1)
			UBYTEAT(dbyteAddr+2) = UBYTEAT(soffsetAddr+2)
			soffsetAddr = soffsetAddr + 3
		NEXT x
		align = (soffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN soffsetAddr = soffsetAddr + (4 - align)		' align 4
	NEXT y

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilMirror ()  #####
' #############################
'
FUNCTION  XilMirror (UBYTE source[], UBYTE dest[])

'This currently only works with 24 bit images

	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	DIM dest[fileSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

	rowBytes = ((width * 3) + 3) AND -4

	offset = dataOffset

'swap end for end data bytes along height
	FOR y=0 TO height-1
		FOR x=0 TO width-1
			nx = width-1-x
			dbyte = dataOffset + rowBytes*y + nx*3
			dest[dbyte]   = source[offset]
			dest[dbyte+1] = source[offset+1]
			dest[dbyte+2] = source[offset+2]
			offset = offset + 3
		NEXT x
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT y

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilResize ()  #####
' #############################
'
FUNCTION  XilResize (UBYTE source[], UBYTE dest[], destWidth, destHeight)

DOUBLE xScale, yScale, fX, fY, dX, dy, r1, r2, r3, r4
DOUBLE g1, g2, g3, g4, b1, b2, b3, b4
DOUBLE dx1, dy1

	IFZ source[] THEN RETURN 0
	IFZ destWidth THEN RETURN 0
	IFZ destHeight THEN RETURN 0

	XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)

	IF (sWidth = destWidth) && (sHeight = destHeight) THEN
		RtlMoveMemory (&dest[], &source[], SIZE(source[]))
		RETURN ($$TRUE)
	END IF

	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc size of dest[]
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of destination file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}

	xScale = (sWidth - 1) / DOUBLE(destWidth)
	yScale = (sHeight - 1) / DOUBLE(destHeight)

	offset = dataOffset

	FOR y = 0 TO destHeight - 1

		fY = y * yScale
		ifY = INT(fY)
		dy = fY - ifY
		dy1 = 1.0 - dy

		FOR x = 0 TO destWidth - 1

      fX = x * xScale
      ifX = INT(fX)
      dX = fX - ifX
			dx1 = 1.0 - dX

'Interpolate using the four nearest pixels in the source
			sByte1 = dataOffset + (ifX*3)  + (sRowBytes*ifY)
			b1 = source[sByte1]
			g1 = source[sByte1+1]
			r1 = source[sByte1+2]

			b2 = source[sByte1+3]
			g2 = source[sByte1+4]
			r2 = source[sByte1+5]

'			sByte2 = dataOffset + (ifX*3) + (sRowBytes*(ifY+1))
			sByte2 = sByte1 + sRowBytes
			b3 = source[sByte2]
			g3 = source[sByte2+1]
			r3 = source[sByte2+2]

			b4 = source[sByte2+3]
			g4 = source[sByte2+4]
			r4 = source[sByte2+5]

'Interpolate in x direction
      ir1 = r1 * dy1 + r3 * dy
			ig1 = g1 * dy1 + g3 * dy
			ib1 = b1 * dy1 + b3 * dy
      ir2 = r2 * dy1 + r4 * dy
			ig2 = g2 * dy1 + g4 * dy
			ib2 = b2 * dy1 + b4 * dy

'Interpolate in y:
      r = ir1 * dx1 + ir2 * dX
			g = ig1 * dx1 + ig2 * dX
			b = ib1 * dx1 + ib2 * dX
			
			SELECT CASE ALL TRUE
				CASE (r < 0)   : r = 0
				CASE (r > 255) : r = 255
				CASE (g < 0)   : g = 0
				CASE (g > 255) : g = 255
				CASE (b < 0)   : b = 0
				CASE (b > 255) : b = 255									
			END SELECT

			dest[offset] 		= b
			dest[offset+1] 	= g
			dest[offset+2] 	= r
			offset = offset + 3
		NEXT x
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT y

	RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  XilResizeCanvas ()  #####
' ################################
'
'PURPOSE	: Enlarge image canvas size by adding empty border using
'           specified backcolor.
'IN				: source[]
'					: destWidth, destHeight - destination image width and height
'					: align - image alignment, use Xui alignment constants, eg, $$AlignMiddleCenter
'					: backColor - border color
'OUT			: dest[]
'
FUNCTION  XilResizeCanvas (UBYTE source[], UBYTE dest[], destWidth, destHeight, align, backColor)

	UBYTE temp1[], temp2[]
	IFZ source[] THEN RETURN 0

	XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)

	IF (sWidth = destWidth) && (sHeight = destHeight) THEN RETURN 0
	IF (sWidth > destWidth) || (sHeight > destHeight) THEN RETURN 0

	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'calc size of dest[]
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]
	DIM temp1[destBmpSize]
	DIM temp2[destBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}

'convert color to 8-bit RGB
	XilConvertColorToRGB  (backColor, @sR, @sG, @sB)

'add background color to dest[]
	RtlMoveMemory (&temp1[], &dest[], SIZE(dest[]))
	RtlMoveMemory (&temp2[], &temp1[], SIZE(temp1[]))

'all arrays must be the same size in XilAddImages
'add rgb values to dest[]
	ret = XilAddImages (@temp1[], @temp2[], @dest[], 1, sR, sG, sB, 0, 0, 0, 0)

'calc initial starting row and column based on alignment selection
	dw = destWidth - sWidth
	dh = destHeight - sHeight
	dw2 = dw/2
	dh2 = dh/2

	IFZ align THEN align = $$AlignMiddleCenter

	SELECT CASE align
		CASE $$AlignMiddleCenter	:	destRowInit = dh2
																destColumnInit = dw2
		CASE $$AlignUpperLeft			:	destRowInit = dh
																destColumnInit = 0
		CASE $$AlignUpperCenter		:	destRowInit = dh
																destColumnInit = dw2
		CASE $$AlignUpperRight		:	destRowInit = dh
																destColumnInit = dw
		CASE $$AlignMiddleRight		:	destRowInit = dh2
																destColumnInit = dw
		CASE $$AlignLowerRight		:	destRowInit = 0
																destColumnInit = dw
		CASE $$AlignLowerCenter		:	destRowInit = 0
																destColumnInit = dw2
		CASE $$AlignLowerLeft			:	destRowInit = 0
																destColumnInit = 0
		CASE $$AlignMiddleLeft		:	destRowInit = dh2
																destColumnInit = 0
	END SELECT

	offset = dataOffset

	destRow = destRowInit
	FOR row = 0 TO sHeight-1									'copy source to dest
		destColumn = destColumnInit
		FOR column = 0 TO sWidth-1
			destByte 	= dataOffset + destColumn*3  + (destRowBytes*destRow)
			dest[destByte] 		= source[offset]
			dest[destByte+1] 	= source[offset+1]
			dest[destByte+2] 	= source[offset+2]
			offset = offset + 3
			INC destColumn
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
		INC destRow
	NEXT row

	DIM temp1[]
	DIM temp2[]

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilResize ()  #####
' #############################
'
FUNCTION  XilResizeProportional (UBYTE source[], UBYTE dest[], DOUBLE percent)

DOUBLE xScale, yScale, fX, fY, dX, dy, r1, r2, r3, r4
DOUBLE g1, g2, g3, g4, b1, b2, b3, b4
DOUBLE dy1, dx1

	IFZ source[] THEN RETURN
	IFZ percent THEN RETURN

	XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)

	destWidth = sWidth * percent/100.0
	destHeight = sHeight * percent/100.0

	IF percent == 100 THEN
		RtlMoveMemory (&dest[], &source[], SIZE(source[]))
		RETURN ($$TRUE)
	END IF

	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc size of dest[]
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}

	xScale = (sWidth - 1) / DOUBLE(destWidth)
	yScale = (sHeight - 1) / DOUBLE(destHeight)

	offset = dataOffset

	FOR y = 0 TO destHeight - 1

		fY = y * yScale
		ifY = INT(fY)
		dy = fY - ifY
		dy1 = 1.0 - dy

		FOR x = 0 TO destWidth - 1

      fX = x * xScale
      ifX = INT(fX)
      dX = fX - ifX
			dx1 = 1.0 - dX

'Interpolate using the four nearest pixels in the source
			sByte1 = dataOffset + (ifX*3)  + (sRowBytes*ifY)
			b1 = source[sByte1]
			g1 = source[sByte1+1]
			r1 = source[sByte1+2]

			b2 = source[sByte1+3]
			g2 = source[sByte1+4]
			r2 = source[sByte1+5]

'			sByte2 = dataOffset + (ifX*3)  + (sRowBytes*(ifY+1))
			sByte2 = sByte1 + sRowBytes
			b3 = source[sByte2]
			g3 = source[sByte2+1]
			r3 = source[sByte2+2]

			b4 = source[sByte2+3]
			g4 = source[sByte2+4]
			r4 = source[sByte2+5]

'Interpolate in x direction
      ir1 = r1 * dy1 + r3 * dy
			ig1 = g1 * dy1 + g3 * dy
			ib1 = b1 * dy1 + b3 * dy
      ir2 = r2 * dy1 + r4 * dy
			ig2 = g2 * dy1 + g4 * dy
			ib2 = b2 * dy1 + b4 * dy

'Interpolate in y direction
      r = ir1 * dx1 + ir2 * dX
			g = ig1 * dx1 + ig2 * dX
			b = ib1 * dx1 + ib2 * dX

'Set output
			SELECT CASE ALL TRUE
				CASE (r < 0)   : r = 0
				CASE (r > 255) : r = 255
				CASE (g < 0)   : g = 0
				CASE (g > 255) : g = 255
				CASE (b < 0)   : b = 0
				CASE (b > 255) : b = 255									
			END SELECT

			dest[offset] 		= b
			dest[offset+1] 	= g
			dest[offset+2] 	= r
			offset = offset + 3
		NEXT x
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT y

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  XilRotate ()  #####
' ##########################
'
'PURPOSE:	Rotate a 24-bit BMP image any degree counter-clockwise
' IN		: source[] - array of image to rotate
'					degrees - value in degrees (0-360) to rotate image counter-clockwise
' OUT		: dest[] - rotated image array
'					destWidth, destHeight - resultant image width and height
'
FUNCTION  XilRotate (UBYTE source[], UBYTE dest[], DOUBLE degrees, @destWidth, @destHeight)

	DOUBLE radians, cosine, sine, radians1

	$DEGTORAD	= 0d3F91DF46A2529D39

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Convert degrees to radians
	radians = $DEGTORAD * degrees

'Get source bytes per row
	rowBytes = (width * 3) + 3 AND -4

'Calc cos and sin
	cosine = cos(radians)
	sine   = sin(radians)

'Calc dimensions for the resulting bmp
'Get the coordinates fo the 3 corners other than origin
	x1 = (-height * sine)
	y1 = (height * cosine)
	x2 = (width * cosine - height * sine)
	y2 = (height * cosine + width * sine)
	x3 = (width * cosine)
	y3 = (width * sine)

	minx = MIN(0,MIN(x1, MIN(x2,x3)))
	miny = MIN(0,MIN(y1, MIN(y2,y3)))
	maxx = MAX(x1, MAX(x2,x3))
	maxy = MAX(y1, MAX(y2,y3))

	w = maxx - minx
	h = maxy - miny

	destWidth = w
	destHeight = h

'get dest row length
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of file in bytes
	bmpSize = destRowBytes * destHeight + dataOffset

	DIM dest[bmpSize]

'copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'filesize bytes 2-5
	dest[2] = bmpSize{8,0}
	dest[3] = bmpSize{8,8}
	dest[4] = bmpSize{8,16}
	dest[5] = bmpSize{8,24}

'file width bytes 18-21
	dest[18] = w{8,0}
	dest[19] = w{8,8}
	dest[20] = w{8,16}
	dest[21] = w{8,24}

'file height bytes 22-25
	dest[22] = h{8,0}
	dest[23] = h{8,8}
	dest[24] = h{8,16}
	dest[25] = h{8,24}

'Use a back color (255/0xFF) of white for unused pixels in new rotated bmp

'Now do the actual rotating - a pixel at a time
'Computing the destination point for each source point
'will leave a few pixels that do not get covered
'so we use a reverse transform - e.i. compute the source point
'for each destination point

'make sure range is correct
	IF minx < 0 THEN INC minx
	IF miny < 0 THEN INC miny

	offset = dataOffset

	FOR  y = 0 TO h-1
		FOR x = 0 TO w-1
			sourcex = (((x+minx)*cosine + (y+miny)*sine))
			sourcey = (((y+miny)*cosine - (x+minx)*sine))

      IF ( sourcex >= 0 && sourcex < width && sourcey >= 0  && sourcey < height ) THEN
				sbyte = (dataOffset + rowBytes*sourcey + sourcex*3)
'swap pixel bytes from source to pixel
				dest[offset]   = source[sbyte]
				dest[offset+1] = source[sbyte+1]
				dest[offset+2] = source[sbyte+2]
			ELSE
'if not part of source image, make background color = 0xFF
				dest[offset]   = 0xFF
				dest[offset+1] = 0xFF
				dest[offset+2] = 0xFF
			END IF
			offset = offset + 3
		NEXT x
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT y

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XgrTileImage ()  #####
' #############################
'
FUNCTION  XilTile (UBYTE source[], UBYTE dest[], destWidth, destHeight)

	IFZ source[] THEN RETURN 0

	XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)

	IF (sWidth = destWidth) && (sHeight = destHeight) THEN RETURN 0
	IF (sWidth > destWidth) || (sHeight > destHeight) THEN RETURN 0

	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc dest bytes per row
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}

	offset = dataOffset

	sRow = sHeight - (destHeight MOD sHeight)  	'bmp starts at bottom left corner
	IF sRow > sHeight-1 THEN sRow = 0
	FOR row = 0 TO destHeight-1									'copy source to dest
		sColumn = 0
		FOR column = 0 TO destWidth-1
			sourceByte = dataOffset + sColumn*3 + (sRowBytes*sRow)
			dest[offset] 		= source[sourceByte]
			dest[offset+1] 	= source[sourceByte+1]
			dest[offset+2] 	= source[sourceByte+2]
			offset = offset + 3
			INC sColumn
			IF sColumn > sWidth-1 THEN sColumn = 0
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
		INC sRow
		IF sRow > sHeight-1 THEN sRow = 0
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  XilAND ()  #####
' ##########################
'
'PURPOSE	:	Apply AND filter to a bmp image using backColor

FUNCTION  XilAND (UBYTE source[], UBYTE dest[], backColor)

	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change color value to 8-bit values
	XilConvertColorToRGB (backColor, @red, @green, @blue)

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			dest[offset] 		= source[offset] 		AND blue
			dest[offset+1] 	= source[offset+1] 	AND green
			dest[offset+2] 	= source[offset+2] 	AND red
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ########################
' #####  XilBlur ()  #####
' ########################
'
' Blur an image using convolution filter
'
FUNCTION  XilBlur (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN 0

	XilSetFilterType ($$Blur)
	XilStandardFilter (@source[], @dest[])
	RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  XilBlurMore ()  #####
' ###############################
'
FUNCTION  XilBlurMore (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN ($$TRUE)
	XilSetFilterType ($$BlurMore)
	XilStandardFilter (@source[], @dest[])
	RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  XilContrast ()  #####
' ###############################
'
'PURPOSE 	:	Modify contrast value for image
'IN				:	source[], mode (0=decrease, 1=increase), contrast (0-255)
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilContrast (UBYTE source[], UBYTE dest[], mode, DOUBLE contrast)

	DOUBLE ratio

	IFZ source[] THEN RETURN 0
	IFZ contrast THEN RETURN 0
	IF contrast > 255 THEN contrast = 255

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'copy source header to dest header
	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	IFZ mode THEN
		ratio = (255-contrast)/DOUBLE((255+contrast))
		FOR row = 0 TO height-1
			FOR column = 0 TO width-1
				b = ratio * (UBYTEAT(soffsetAddr)  +contrast)
				g = ratio * (UBYTEAT(soffsetAddr+1)+contrast)
				r = ratio * (UBYTEAT(soffsetAddr+2)+contrast)

				IF (b AND 0xFFFFFF00) THEN
					IF (b < 0) THEN b = 0 ELSE b = 255
				END IF

				IF (g AND 0xFFFFFF00) THEN
					IF (g < 0) THEN g = 0 ELSE g = 255
				END IF

				IF (r AND 0xFFFFFF00) THEN
					IF (r < 0) THEN r = 0 ELSE r = 255
				END IF

				UBYTEAT(doffsetAddr)   = b
				UBYTEAT(doffsetAddr+1) = g
				UBYTEAT(doffsetAddr+2) = r
				doffsetAddr = doffsetAddr + 3
				soffsetAddr = soffsetAddr + 3
			NEXT column
			align = (doffsetAddr - 54){2,0}							' ok if align = 0
			IF align THEN
				doffsetAddr = doffsetAddr + (4 - align)		' align 4
				soffsetAddr = soffsetAddr + (4 - align)		' align 4
			END IF
		NEXT row
	ELSE
		ratio = (255+contrast)/DOUBLE((255-contrast))
		FOR row = 0 TO height-1
			FOR column = 0 TO width-1
				b = (UBYTEAT(soffsetAddr) * ratio)   - contrast
				g = (UBYTEAT(soffsetAddr+1) * ratio) - contrast
				r = (UBYTEAT(soffsetAddr+2) * ratio) - contrast

				IF (b AND 0xFFFFFF00) THEN
					IF (b < 0) THEN b = 0 ELSE b = 255
				END IF

				IF (g AND 0xFFFFFF00) THEN
					IF (g < 0) THEN g = 0 ELSE g = 255
				END IF

				IF (r AND 0xFFFFFF00) THEN
					IF (r < 0) THEN r = 0 ELSE r = 255
				END IF

				UBYTEAT(doffsetAddr)   = b
				UBYTEAT(doffsetAddr+1) = g
				UBYTEAT(doffsetAddr+2) = r
				doffsetAddr = doffsetAddr + 3
				soffsetAddr = soffsetAddr + 3
			NEXT column
			align = (doffsetAddr - 54){2,0}							' ok if align = 0
			IF align THEN
				doffsetAddr = doffsetAddr + (4 - align)		' align 4
				soffsetAddr = soffsetAddr + (4 - align)		' align 4
			END IF
		NEXT row
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
' ##########################
' #####  XilEmboss ()  #####
' ##########################
'
'PURPOSE 	: Emboss an image, resulting image is grayscale, 24bit
'IN				:	source[], direction (use Xui Text Align constants)
'						direction constants:
'						$$AlignUpperLeft
'						$$AlignUpperCenter
'						$$AlignUpperRight
'						$$AlignMiddleLeft
'						$$AlignMiddleCenter
'						$$AlignMiddleRight
'						$$AlignLowerLeft
'						$$AlignLowerCenter
'						$$AlignLowerRight
'OUT			: dest[]

FUNCTION  XilEmboss (UBYTE source[], UBYTE dest[], direction)

	UBYTE tmpsrc[], image1[], image2[]

	IFZ source[] THEN RETURN 0

'convert to grayscale
	XilGrayScale3 (@source[], @tmpsrc[])

	IFZ direction THEN direction = $$AlignUpperRight
	IF direction = $$AlignMiddleCenter THEN direction = $$AlignUpperRight
	IF direction > $$AlignLowerRight THEN direction = $$AlignLowerRight

	DIM data$[7]
	data$[0] = "-2,-1,0,-1,0,1,0,1,2"		'NW
	data$[1] = "-1,-2,-1,0,0,0,1,2,1"		'N
	data$[2] = "0,-1,-2,1,0,-1,2,1,0"		'NE
	data$[3] = "1,0,-1,2,0,-2,1,0,-1"		'E
	data$[4] = "2,1,0,1,0,-1,0,-1,-2"		'SE
	data$[5] = "1,2,1,0,0,0,-1,-2,-1"		'S
	data$[6] = "0,1,2,-1,0,1,-2,-1,0"		'SW
	data$[7] = "-1,0,1,-2,0,2,-1,0,1"		'W

	SELECT CASE direction
		CASE $$AlignUpperLeft			:	data1$ = data$[0]
																data2$ = data$[4]
		CASE $$AlignUpperCenter		:	data1$ = data$[1]
																data2$ = data$[5]
		CASE $$AlignUpperRight		:	data1$ = data$[2]
																data2$ = data$[6]
		CASE $$AlignMiddleRight		:	data1$ = data$[3]
																data2$ = data$[7]
		CASE $$AlignLowerRight		:	data1$ = data$[4]
																data2$ = data$[0]
		CASE $$AlignLowerCenter		:	data1$ = data$[5]
																data2$ = data$[1]
		CASE $$AlignLowerLeft			:	data1$ = data$[6]
																data2$ = data$[2]
		CASE $$AlignMiddleLeft		:	data1$ = data$[7]
																data2$ = data$[3]
	END SELECT

	XilCustomFilter (@tmpsrc[], @image1[], 3, data1$)
	XilCustomFilter (@tmpsrc[], @image2[], 3, data2$)

'Add 128 to each rgb value in image1[] and then subtract image2[]
	XilAddImages (@image1[], @image2[], @dest[], 1, 128, 128, 128, -1, 0, 0, 0)

	DIM image1[]
	DIM image2[]
	DIM tmpsrc[]

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilEmboss ()  #####
' #############################
'
FUNCTION  XilEmbossQuick (UBYTE source[], UBYTE dest[])

	UBYTE tmpsrc[], image1[]

	IFZ source[] THEN RETURN 0

'convert to grayscale
	XilGrayScale3 (@source[], @tmpsrc[])

'invert image
	XilXOR (@tmpsrc[], @image1[])

'combine tmpsrc[] with image1[], offset image1[] by 1 x pixel and 1 y pixel
	ret = XilCombineImages (@tmpsrc[], @image1[], @dest[], 1, 1, 50)

	DIM image1[]
	DIM tmpsrc[]

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  XilFade ()  #####
' ###########################
'
'
'PURPOSE 	:	Fade image by amount, 255 = no darken, 0 = all black
'IN				:	source[], amount
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilFade (UBYTE source[], UBYTE dest[], amount)

	IFZ source[] THEN RETURN 0
	IF amount > 255 THEN amount = 255

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source[] to dest[]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			b =	source[offset]
			g = source[offset+1]
			r = source[offset+2]
			dest[offset]   = amount * b \ 255
			dest[offset+1] = amount * g \ 255
			dest[offset+2] = amount * r \ 255
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  XilColorise ()  #####
' ###############################
'
'PURPOSE 	:	Modify gamma value for image
'IN				:	source[], gamma (range 0-10)
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilGamma (UBYTE source[], UBYTE dest[], DOUBLE gamma)

DOUBLE table[], y

	IFZ source[] THEN RETURN 0
	IFZ gamma THEN gamma = 2.0
	IF gamma > 10 THEN gamma = 10

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source[] to dest[]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

'create table
	DIM table[255]
	y = 1/gamma
	table[0] = 0
	FOR i = 1 TO 255
		z = INT(255.0 * exp(y * log(i / 255.0)))
		IF z < 0 THEN
			z = 0
		ELSE
			IF z > 255 THEN z = 255
		END IF
		table[i] = z
	NEXT i

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			dest[offset]   = table[source[offset]]
			dest[offset+1] = table[source[offset+1]]
			dest[offset+2] = table[source[offset+2]]
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XilHistogramEqualize ()  #####
' #####################################
'
'PURPOSE 	:	Equalize Histogram by the stretching method.
'IN				:	source[]
'						exponent (if exponent < 1, contrast is increased,
'						otherwise the contrast is decreased)
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilHistogramEqualize (UBYTE source[], UBYTE dest[], DOUBLE exponent)

	DOUBLE gq1, rq1, bq1, factorr, factorg, factorb
	DOUBLE bhist[], ghist[], rhist[]
	DOUBLE bCumSum[], gCumSum[], rCumSum[]

	IFZ source[] THEN RETURN 0
	IFZ exponent THEN exponent = 1.0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(source[])
	DIM dest[upper]

	' Copy source[] to dest[]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

	HistogramCalc (@source[], @histR[], @histG[], @histB[])

	DIM rhist[255]
	DIM ghist[255]
	DIM bhist[255]

	FOR i = 0 TO 255
		bhist[i] = histB[i]**exponent
    bq1 = bq1 + bhist[i]
		ghist[i] = histG[i]**exponent
    gq1 = gq1 + ghist[i]
		rhist[i] = histR[i]**exponent
    rq1 = rq1 + rhist[i]
	NEXT i

	factorr = 255.0/rq1
	factorb = 255.0/bq1
	factorg = 255.0/gq1

	CumulativeSumArray (@bhist[], @bCumSum[])
	CumulativeSumArray (@ghist[], @gCumSum[])
	CumulativeSumArray (@rhist[], @rCumSum[])

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			dest[offset]   = factorb * bCumSum[source[offset]]
			dest[offset+1] = factorg * gCumSum[source[offset+1]]
			dest[offset+2] = factorr * rCumSum[source[offset+2]]
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN	offset = offset + (4 - align)		' align 4
	NEXT row

	DIM bhist[]
	DIM ghist[]
	DIM rhist[]
	DIM bCumSum[]
	DIM gCumSum[]
	DIM rCumSum[]

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  XilLighten ()  #####
' ##############################
'
'PURPOSE 	:	Lighten image by percent
'IN				:	source[], amount
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilLighten (UBYTE source[], UBYTE dest[], percent)

DOUBLE h, s, l

	IFZ source[] THEN RETURN 0
	IFZ amount THEN amount = 25

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source[] to dest[]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			b =	source[offset]
			g = source[offset+1]
			r = source[offset+2]
			RGBToHLS (r, g, b, @h, @s, @l)
			l = l * (1.0 + (percent / 100.0))
			IF (l > 1) THEN l = 1
			HLSToRGB (h, s, l, @R, @G, @B)
			dest[offset] 	= B
			dest[offset+1] = G
			dest[offset+2] = R
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' #########################
' #####  XilNoise ()  #####
' #########################
'
'PURPOSE 	:	Add random or uniform noise to image by percent amount
'IN				:	source[], percent
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilNoise (UBYTE source[], UBYTE dest[], percent)

	IFZ source[] THEN RETURN 0
	IFZ percent THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Copy source[] to dest[]
	upper = UBOUND(source[])
	DIM dest[upper]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	a = 128 * percent \ 100
	a2 = a \ 2

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1

			b = UBYTEAT(soffsetAddr)   - a2 + (RNUniform() * a)
			g = UBYTEAT(soffsetAddr+1) - a2 + (RNUniform() * a)
			r = UBYTEAT(soffsetAddr+2) - a2 + (RNUniform() * a)

			IF (b AND 0xFFFFFF00) THEN
				IF (b < 0) THEN b = 0 ELSE b = 255
			END IF

			IF (g AND 0xFFFFFF00) THEN
				IF (g < 0) THEN g = 0 ELSE g = 255
			END IF

			IF (r AND 0xFFFFFF00) THEN
				IF (r < 0) THEN r = 0 ELSE r = 255
			END IF

			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
			soffsetAddr = soffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}							' ok if align = 0
		IF align THEN
			soffsetAddr = soffsetAddr + (4 - align)		' align 4
			doffsetAddr = doffsetAddr + (4 - align)		' align 4
		END IF
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilNormalize ()  #####
' #############################
'
'PURPOSE 	:	Normalize image
'IN				:	source[]
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilNormalize (UBYTE source[], UBYTE dest[])

	DOUBLE mR, mG, mB

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(source[])
	DIM dest[upper]

'Copy source[] to dest[]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	minR = 255 : minG = 255 : minB = 255

	offset = soffsetAddr

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			minB = MIN(minB, UBYTEAT(offset))
			maxB = MAX(maxB, UBYTEAT(offset))
			minG = MIN(minG, UBYTEAT(offset+1))
			maxG = MAX(maxG, UBYTEAT(offset+1))
			minR = MIN(minR, UBYTEAT(offset+2))
			maxR = MAX(maxR, UBYTEAT(offset+2))
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	IF (maxR - minR) == 0 THEN
		mR = 0
	ELSE
		mR = 255/DOUBLE(maxR-minR)
	END IF

	IF (maxG - minG) == 0 THEN
		mG = 0
	ELSE
		mG = 255/DOUBLE(maxG-minG)
	END IF

	IF (maxB - minB) == 0 THEN
		mB = 0
	ELSE
		mB = 255/DOUBLE(maxB-minB)
	END IF

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			UBYTEAT(doffsetAddr)   = (UBYTEAT(soffsetAddr)   - minB) * mB
			UBYTEAT(doffsetAddr+1) = (UBYTEAT(soffsetAddr+1) - minG) * mG
			UBYTEAT(doffsetAddr+2) = (UBYTEAT(soffsetAddr+2) - minR) * mR
			soffsetAddr = soffsetAddr + 3
			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}							' ok if align = 0
		IF align THEN
			soffsetAddr = soffsetAddr + (4 - align)		' align 4
			doffsetAddr = doffsetAddr + (4 - align)		' align 4
		END IF
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  XilSharpen ()  #####
' ###########################
'
FUNCTION  XilSharpen (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN 0
	XilSetFilterType ($$Sharpen)
	XilStandardFilter (@source[], @dest[])
	RETURN ($$TRUE)

END FUNCTION
'
'
' ##################################
' #####  XilSharpenMore ()  #####
' ##################################
'
FUNCTION  XilSharpenMore (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN 0
	XilSetFilterType ($$SharpenMore)
	XilStandardFilter (@source[], @dest[])
	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilSoften ()  #####
' #############################
'
FUNCTION  XilSoften (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN 0
	XilSetFilterType ($$Soften)
	XilStandardFilter (@source[], @dest[])
	RETURN ($$TRUE)

END FUNCTION
'
'
' #################################
' #####  XilSoftenMore ()  #####
' #################################
'
FUNCTION  XilSoftenMore (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN 0
	XilSetFilterType ($$SoftenMore)
	XilStandardFilter (@source[], @dest[])
	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  XilXOR ()  #####
' ##########################
'
FUNCTION  XilXOR (UBYTE source[], UBYTE dest[])
'PURPOSE:	Apply XOR filter to a bmp image

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

	IF bpp = 24 THEN
'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'XOR each data byte by 0xFF

		FOR row = 0 TO height-1
			FOR column = 0 TO width-1
'				byte 	= dataOffset + column*3 + (rowLength*row)

				sbyteAddr = soffsetAddr + column*3 + (row*rowLength)
				dbyteAddr = doffsetAddr + column*3 + (row*rowLength)

'				dest[byte] 	 = source[byte] 	XOR 0xFF
'				dest[byte+1] = source[byte+1] XOR 0xFF
'				dest[byte+2] = source[byte+2] XOR 0xFF

'Note: addressing memory directly is 25% faster than referencing the byte array above
				UBYTEAT(dbyteAddr)	 = UBYTEAT(sbyteAddr) 	XOR 0xFF
				UBYTEAT(dbyteAddr+1) = UBYTEAT(sbyteAddr+1) XOR 0xFF
				UBYTEAT(dbyteAddr+2) = UBYTEAT(sbyteAddr+2) XOR 0xFF
			NEXT column
		NEXT row

	ELSE
		FOR i = dataOffset TO upper
			dest[i] = source[i] XOR 0xFF
		NEXT i
	END IF

	RETURN ($$TRUE)

END FUNCTION
'
'
' #############################
' #####  XilAsIcon ()  #####
' #############################

'PURPOSE	:	Create a bmp that swaps mask black value with backColor
'						much like an icon in order to have a transparent backGround
'         	This only works on solid backgrounds
'
FUNCTION  XilAsIcon (UBYTE source[], UBYTE dest[], backColor)

	UBYTE mask[]

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source[] to dest[]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

'DIM a mask array
	DIM mask[upper]

'create mask image
	XilMask (@source[], @mask[])

'change XB backColor to 3-byte color value
	XilConvertColorToRGB (backColor, @red, @green, @blue)

	offset = dataOffset

'if mask color is white == 0xFF, then swap with backColor
	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			IF mask[offset] = 0xFF THEN
				dest[offset] = blue
			END IF
			IF mask[offset+1] = 0xFF THEN
				dest[offset+1] = green
			END IF
			IF mask[offset+2] = 0xFF THEN
				dest[offset+2] = red
			END IF
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	REDIM mask[]

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  XilMask ()  ####
' ##########################

' PURPOSE	:	Make B&W mask from source[] based on 1st color found in bitmap
'
FUNCTION  XilMask (UBYTE source[], UBYTE dest[])

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'Get color of first bitmap point for mask
	mask1 = source[dataOffset]
	mask2 = source[dataOffset+1]
	mask3 = source[dataOffset+2]

'make B&W mask
	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			IF (UBYTEAT(soffsetAddr) = mask1) && (UBYTEAT(soffsetAddr+1) = mask2) && (UBYTEAT(soffsetAddr+2) = mask3) THEN
				UBYTEAT(doffsetAddr)   = 255
				UBYTEAT(doffsetAddr+1) = 255
				UBYTEAT(doffsetAddr+2) = 255
			ELSE
				UBYTEAT(doffsetAddr)   = 0
				UBYTEAT(doffsetAddr+1) = 0
				UBYTEAT(doffsetAddr+2) = 0
			END IF
			soffsetAddr = soffsetAddr + 3
			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}											' ok if align = 0
		IF align THEN
			soffsetAddr = soffsetAddr + (4 - align)		' align 4
			doffsetAddr = doffsetAddr + (4 - align)		' align 4
		END IF
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  XilMaskCombine ()  #####
' ###############################

' PURPOSE	:	Make a mask[] of source[], then do
' 					mask[] AND dest[], then source[] XOR dest[].
'						This draws the source image onto target
'						dest image giving a transparent background.
'						Same method as drawing sprites.
'						All images must be the same size!
'	IN			: dest[] is the target image, mask[] is the mask of source
' 					source[] is the image to apply to dest[]
' OUT			: dest[] is modified by source[]
'
FUNCTION  XilMaskCombine (UBYTE source[], UBYTE mask[], UBYTE dest[])

	IFZ source[] THEN RETURN 0
	IFZ dest[] THEN RETURN 0
	IFZ mask[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @sbpp, @swidth, @sheight)
	XilGetImageArrayDetails (@source[], 0, 0, @dataOffset, 0, 0, 0, 0, 0)
	IF sbpp <> 24 THEN RETURN

  XilGetImageArrayInfo(@dest[], @dbpp, @dwidth, @dheight)
	IF dbpp <> 24 THEN RETURN

  XilGetImageArrayInfo(@mask[], @mbpp, @mwidth, @mheight)
	IF mbpp <> 24 THEN RETURN

	IF (swidth <> dwidth) || (sheight <> dheight) || (swidth <> mwidth) THEN RETURN

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'calc address of first element in mask[]
	maddress = &mask[0]
	moffsetAddr = maddress + dataOffset

'combine source & dest w/ mask
	FOR row = 0 TO sheight-1
		FOR column = 0 TO swidth-1
			UBYTEAT(doffsetAddr)   = (UBYTEAT(moffsetAddr)   AND UBYTEAT(doffsetAddr))   XOR UBYTEAT(soffsetAddr)
			UBYTEAT(doffsetAddr+1) = (UBYTEAT(moffsetAddr+1) AND UBYTEAT(doffsetAddr+1)) XOR UBYTEAT(soffsetAddr+1)
			UBYTEAT(doffsetAddr+2) = (UBYTEAT(moffsetAddr+2) AND UBYTEAT(doffsetAddr+2)) XOR UBYTEAT(soffsetAddr+2)
			soffsetAddr = soffsetAddr + 3
			doffsetAddr = doffsetAddr + 3
			moffsetAddr = moffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}							' ok if align = 0
		IF align THEN
			soffsetAddr = soffsetAddr + (4 - align)		' align 4
			doffsetAddr = doffsetAddr + (4 - align)		' align 4
			moffsetAddr = moffsetAddr + (4 - align)		' align 4
		END IF
	NEXT row

	RETURN ($$TRUE)
END FUNCTION
'
'
' #############################
' #####  AddToPalette ()  #####
' #############################
'
FUNCTION  AddToPalette (red, green, blue)

	SHARED iPalette
	SHARED RGB4 tPal[]

	INC iPalette
	REDIM tPal[iPalette]
	tPal[iPalette].red 		= red
	tPal[iPalette].green 	= green
	tPal[iPalette].blue 	= blue


END FUNCTION
'
'
' ######################################
' #####  CreateHalfTonePalette ()  #####
' ######################################
'
FUNCTION  CreateHalfTonePalette ()

	SHARED RGB4 tPal[]
	SHARED iPalette

'Create Halftone color palette
'which has only 125 unique colors

	iPalette = 256
	DIM tPal[iPalette-1]

	FOR b = 0 TO 0x100 STEP 0x40
		IF b = 0x100 THEN
			bA = b - 1
		ELSE
			bA = b
		END IF
		FOR g = 0 TO 0x100 STEP 0x40
			IF g = 0x100 THEN
				gA = g - 1
			ELSE
				gA = g
			END IF
			FOR r = 0 TO 0x100 STEP 0x40
				IF r = 0x100 THEN
					rA = r - 1
				ELSE
					rA = r
				END IF

				tPal[lIndex].red = rA
				tPal[lIndex].green = gA
				tPal[lIndex].blue = bA

				INC lIndex

			NEXT r
		NEXT g
	NEXT b

	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  CreateWebSafePalette ()  #####
' #####################################
'
FUNCTION  CreateWebSafePalette ()

	SHARED RGB4 tPal[]
	SHARED iPalette

	iPalette = 256
	DIM tPal[iPalette-1]

' fill the lowest 8 colors

	tPal[1].red = 0x80	: tPal[1].green = 0			: tPal[1].blue = 0
	tPal[2].red = 0			: tPal[2].green = 0x80	: tPal[2].blue = 0
	tPal[3].red = 0x80	: tPal[3].green = 0x80	: tPal[3].blue = 0
	tPal[4].red = 0			: tPal[4].green = 0			: tPal[4].blue = 0x80
	tPal[5].red = 0x80	: tPal[5].green = 0			: tPal[5].blue = 0x80
	tPal[6].red = 0			: tPal[6].green = 0x80	: tPal[6].blue = 0x80
	tPal[7].red = 0xC0	: tPal[7].green = 0xC0	: tPal[7].blue = 0xC0

' create palette of 216 colors

	FOR b = 0 TO 0xFF STEP 0x33
		FOR g = 0 TO 0xFF STEP 0x33
			FOR r = 0 TO 0xFF STEP 0x33
				l = r + g + b            						' ignore if the output is any combination of 0 and FF
				SELECT CASE TRUE
					CASE (l = 0) || (l = 0x2FD) : 		' ignore
					CASE (l = 0x1FE) && ((r = 0) || (g = 0) || (b = 0)) :	' ignore
					CASE (l = 0xFF) && (((r = 0) && (g = 0)) || ((r = 0) && (b = 0)) || ((g = 0) && (b = 0))) :  ' ignore
					CASE ELSE :
						tPal[lIndex].red 		= r
						tPal[lIndex].green 	= g
						tPal[lIndex].blue 	= b
						INC lIndex
				END SELECT
			NEXT r
		NEXT g
	NEXT b

 ' Fill the remain entries with gray shades

   r = 8: g = 8: b = 8
	FOR i = 217 TO 247
		tPal[i].red 		= r
		tPal[i].green 	= g
		tPal[i].blue 		= b
		r = r + 8: g = g + 8: b = b + 8
	NEXT i

' do the last group

	tPal[248].red = 0x80	: tPal[248].green = 0x80	: tPal[248].blue = 0x80
	tPal[249].red = 0xFF	: tPal[249].green = 0			: tPal[249].blue = 0
	tPal[250].red = 0			: tPal[250].green = 0xFF	: tPal[250].blue = 0
	tPal[251].red = 0xFF	: tPal[251].green = 0xFF	: tPal[251].blue = 0
	tPal[252].red = 0			: tPal[252].green = 0			: tPal[252].blue = 0xFF
	tPal[253].red = 0xFF	: tPal[253].green = 0			: tPal[253].blue = 0xFF
	tPal[254].red = 0			: tPal[254].green = 0xFF	: tPal[254].blue = 0xFF
	tPal[255].red = 0xFF	: tPal[255].green = 0xFF	: tPal[255].blue = 0xFF


	RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  XilApplyPalette ()  #####
' ################################
'
FUNCTION  XilApplyPalette (UBYTE source[], UBYTE dest[], diffuseError)
	UBYTE temp[]
	SHARED RGB4 tPal[]
	SHARED iPalette

	IFZ source[] THEN RETURN 0
	IFZ tPal[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'copy source header to dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Copy source[] to temp[]
	DIM temp[upper]
	RtlMoveMemory (&temp[], &source[], SIZE(source[]))

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'calc address of first element in temp[]
	taddress = &temp[0]
	toffsetAddr = taddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			byte = column*3 + (row*rowLength)
			dbyteAddr = doffsetAddr + byte
			tbyteAddr = toffsetAddr + byte

'Get nearest color - this is the time consuming part!!!
			blue  = UBYTEAT(tbyteAddr)
			green = UBYTEAT(tbyteAddr+1)
			red   = UBYTEAT(tbyteAddr+2)
			minCD = 0x7FFFFFFF

			FOR i = 0 TO iPalette-1
				rmean = (red + tPal[i].red) >> 1
				r = red   - tPal[i].red
				g = green - tPal[i].green
				b = blue  - tPal[i].blue
				colorDistance = ((512+rmean)*r*r) + (4*g*g) + ((767-rmean)*b*b)
				IF colorDistance < minCD THEN
					minCD = colorDistance
					lIndex = i
				END IF
			NEXT i

			UBYTEAT(dbyteAddr+2) = tPal[lIndex].red
			UBYTEAT(dbyteAddr+1) = tPal[lIndex].green
			UBYTEAT(dbyteAddr)   = tPal[lIndex].blue

			IF diffuseError THEN
				lErrorRed   = -1 * (UBYTEAT(dbyteAddr+2) - UBYTEAT(tbyteAddr+2))
				lErrorGreen = -1 * (UBYTEAT(dbyteAddr+1) - UBYTEAT(tbyteAddr+1))
				lErrorBlue  = -1 * (UBYTEAT(dbyteAddr)   - UBYTEAT(tbyteAddr))

'Diffuse the error:
				IF ABS(lErrorRed) + ABS(lErrorGreen) + ABS(lErrorBlue) > 3 THEN
					IF (column < width-1) THEN
						b  = UBYTEAT(tbyteAddr+3) + (lErrorBlue * 7) \ 16
						g  = UBYTEAT(tbyteAddr+4) + (lErrorGreen * 7) \ 16
						r  = UBYTEAT(tbyteAddr+5) + (lErrorRed * 7) \ 16

						IF (b AND 0xFFFFFF00) THEN
							IF (b < 0) THEN b = 0 ELSE b = 255
						END IF

						IF (g AND 0xFFFFFF00) THEN
							IF (g < 0) THEN g = 0 ELSE g = 255
						END IF

						IF (r AND 0xFFFFFF00) THEN
							IF (r < 0) THEN r = 0 ELSE r = 255
						END IF

						UBYTEAT(tbyteAddr+3) = b
						UBYTEAT(tbyteAddr+4) = g
						UBYTEAT(tbyteAddr+5) = r
					END IF

					IF (row < height-1) THEN
						FOR i = -3 TO 3 STEP 3
							IF ((column + i) > 0) && ((column + i) < width-1) THEN

								IFZ i THEN
									iCoeff = 4
								ELSE
									iCoeff = 0
								END IF

								difBlue = 0 : difGreen = 0 : difRed = 0
								IF iCoeff THEN
									difBlue = (lErrorBlue * iCoeff) \ 16
									difGreen = (lErrorGreen * iCoeff) \ 16
									difRed = (lErrorRed * iCoeff) \ 16
								END IF

								nRowByte = (column+i)*3 + rowLength*(row+1)
								tempAddr = toffsetAddr + nRowByte
								b = UBYTEAT(tempAddr+i)   + difBlue
								g = UBYTEAT(tempAddr+i+1) + difGreen
								r = UBYTEAT(tempAddr+i+2) + difRed

								IF (b AND 0xFFFFFF00) THEN
									IF (b < 0) THEN b = 0 ELSE b = 255
								END IF

								IF (g AND 0xFFFFFF00) THEN
									IF (g < 0) THEN g = 0 ELSE g = 255
								END IF

								IF (r AND 0xFFFFFF00) THEN
									IF (r < 0) THEN r = 0 ELSE r = 255
								END IF

								UBYTEAT(tempAddr+i) 	= b
								UBYTEAT(tempAddr+i+1) = g
								UBYTEAT(tempAddr+i+2) = r
							END IF
						NEXT i
					END IF
				END IF
			END IF
		NEXT column
	NEXT row

	DIM temp[]
	RETURN ($$TRUE)

END FUNCTION
'
'
' ############################
' #####  XilColorize ()  #####
' ############################
'
'PURPOSE 	:	Colorize a grayscale image by setting value for hue, range 0-100
'IN				:	source[], hue
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilColorize (UBYTE source[], UBYTE dest[], DOUBLE hue)

DOUBLE h, s, l

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo (@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'Copy source[] to dest[]
	upper = UBOUND(source[])
	DIM dest[upper]
	RtlMoveMemory (&dest[], &source[], SIZE(source[]))

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			b =	source[offset]
			g = source[offset+1]
			r = source[offset+2]
			RGBToHLS (r, g, b, @h, @s, @l)
			IFZ h THEN
				s = 0.5
				h = (6.0/100. * hue) - 1		'hue range is -1 to 5
			ELSE
				h = (6.0/100. * hue) - 1
			END IF
			HLSToRGB (h, s, l, @R, @G, @B)
			dest[offset] 	= B
			dest[offset+1] = G
			dest[offset+2] = R
			offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' #################################
' #####  XilGrayScale1 ()  #####
'	#################################
'
'PURPOSE	:	Convert a 24 bpp color bmp image into a 24 bpp grayscale image
'						using equation grayScaleValue = 0.299 * R + 0.587 * G + 0.114 * B
'IN				: source[]
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilGrayScale1 (UBYTE source[], UBYTE dest[])

	UBYTE blue, green, red, gray

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IFZ source[] THEN RETURN 0

	IF bpp <> 24 THEN RETURN

'DIM dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source header info into dest header

	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Convert each RGB byte into a grayscale value by using equation:
'grayScaleValue = 0.299 * R + 0.587 * G + 0.114 * B
'Order of 3 color bytes is B G R

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1

			blue 	= UBYTEAT(soffsetAddr)
			green = UBYTEAT(soffsetAddr+1)
			red 	= UBYTEAT(soffsetAddr+2)
			gray 	= ((299 * red) + (587 * green) + (114 * blue))/1000.0

			UBYTEAT(doffsetAddr)   = gray
			UBYTEAT(doffsetAddr+1) = gray
			UBYTEAT(doffsetAddr+2) = gray

			doffsetAddr = doffsetAddr + 3
			soffsetAddr = soffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}							' ok if align = 0
		IF align THEN
			soffsetAddr = soffsetAddr + (4 - align)		' align 4
			doffsetAddr = doffsetAddr + (4 - align)		' align 4
		END IF
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##################################
' #####  Xil2GrayScale2 ()  #####
' ##################################
'
'PURPOSE	: Convert image to grayscale using the following equations:
'						squareSum = R**2 + G**2 + B**2
'						grayScaleValue = SQRT(DOUBLE((squareSum/3.0)))
'IN				: source[]
'OUT			: dest[]
'RETURNS	:	$$TRUE on success, $$FALSE on failure

FUNCTION  XilGrayScale2 (UBYTE source[], UBYTE dest[])

	DOUBLE squareSum

	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IF bpp <> 24 THEN RETURN

'DIM dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source header info into dest header

	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Convert each RGB byte into a grayscale value by using equation:
'squareSum = R**2 + G**2 + B**2
'grayScaleValue = SQRT(DOUBLE((squareSum/3.0)))
'Order of 3 color bytes is B G R

	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1

			blue 	= UBYTEAT(soffsetAddr)
			green = UBYTEAT(soffsetAddr+1)
			red 	= UBYTEAT(soffsetAddr+2)

			squareSum = (red*red) + (green*green) + (blue*blue)
			gray = sqrt(squareSum/3.0)

			UBYTEAT(doffsetAddr) 		= gray
			UBYTEAT(doffsetAddr+1) 	= gray
			UBYTEAT(doffsetAddr+2) 	= gray

			doffsetAddr = doffsetAddr + 3
			soffsetAddr = soffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}							' ok if align = 0
		IF align THEN
			soffsetAddr = soffsetAddr + (4 - align)		' align 4
			doffsetAddr = doffsetAddr + (4 - align)		' align 4
		END IF
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' #################################
' #####  XilGrayScale3 ()  #####
'	#################################
'
'PURPOSE	:	Convert a 24 bpp color bmp image into a 24 bpp grayscale image
'						using ITU standard equation
'						grayScaleValue = 0.222 * R + 0.707 * G + 0.071 * B
'IN				: source[]
'OUT			: dest[]
'RETURNS	: $$TRUE on success, $$FALSE on failure

FUNCTION  XilGrayScale3 (UBYTE source[], UBYTE dest[])

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	IFZ source[] THEN RETURN 0

	IF bpp <> 24 THEN RETURN

'DIM dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'Copy source header info into dest header

	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Convert each RGB byte into a grayscale value by using equation:
'grayScaleValue = 0.222 * R + 0.707 * G + 0.071 * B
'Order of 3 color bytes is B G R

	offset = dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
				blue 	= source[offset]
				green = source[offset+1]
				red 	= source[offset+2]
				gray 	= ((222 * red) + (707 * green) + (71 * blue))/1000.0
				dest[offset]   = gray
				dest[offset+1] = gray
				dest[offset+2] = gray
				offset = offset + 3
		NEXT column
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' #######################################
' #####  XilHalfTonePaletteBest ()  #####
' #######################################
'
FUNCTION  XilHalfTonePaletteBest (UBYTE source[], UBYTE dest[], dither)

	SHARED RGB4 tPal[]

	IFZ source[] THEN RETURN 0

	CreateHalfTonePalette ()
	IFZ tPal[] THEN RETURN 0

	RETURN XilApplyPalette (@source[], @dest[], dither)

END FUNCTION
'
'
' #######################################
' #####  XilHalfTonePaletteFast ()  #####
' #######################################
'
FUNCTION  XilHalfTonePaletteFast (UBYTE source[], UBYTE dest[], dither)

	PALETTEENTRY pe
	UBYTE temp[]

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'DIM destimation array dest[]
	upper = UBOUND(source[])
  DIM dest[upper]

'copy source header to dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Copy source[] to temp[]
	DIM temp[upper]
	RtlMoveMemory (&temp[], &source[], SIZE(source[]))

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
'	saddress = &source[0]
'	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'calc address of first element in temp[]
	taddress = &temp[0]
	toffsetAddr = taddress + dataOffset

	hdc = GetDC (0)
	hPal = CreateHalftonePalette (hdc)
	ReleaseDC (0, hdc)

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			byte = column*3 + (row*rowLength)
			dbyteAddr = doffsetAddr + byte
			tbyteAddr = toffsetAddr + byte

'Get nearest color
			blue  = UBYTEAT(tbyteAddr)
			green = UBYTEAT(tbyteAddr+1)
			red   = UBYTEAT(tbyteAddr+2)
			color = RGB (red, green, blue)
			index = GetNearestPaletteIndex (hPal, color)

			GetPaletteEntries (hPal, index, 1, &pe)

			UBYTEAT(dbyteAddr+2) = pe.peRed
			UBYTEAT(dbyteAddr+1) = pe.peGreen
			UBYTEAT(dbyteAddr)   = pe.peBlue

			IF dither THEN
				lErrorRed   = -1 * (UBYTEAT(dbyteAddr+2) - UBYTEAT(tbyteAddr+2))
				lErrorGreen = -1 * (UBYTEAT(dbyteAddr+1) - UBYTEAT(tbyteAddr+1))
				lErrorBlue  = -1 * (UBYTEAT(dbyteAddr)   - UBYTEAT(tbyteAddr))

'Diffuse the error:
				IF ABS(lErrorRed) + ABS(lErrorGreen) + ABS(lErrorBlue) > 3 THEN
					IF (column < width-1) THEN
						b  = UBYTEAT(tbyteAddr+3) + (lErrorBlue * 7) \ 16
						g  = UBYTEAT(tbyteAddr+4) + (lErrorGreen * 7) \ 16
						r  = UBYTEAT(tbyteAddr+5) + (lErrorRed * 7) \ 16

						IF (b AND 0xFFFFFF00) THEN
							IF (b < 0) THEN b = 0 ELSE b = 255
						END IF

						IF (g AND 0xFFFFFF00) THEN
							IF (g < 0) THEN g = 0 ELSE g = 255
						END IF

						IF (r AND 0xFFFFFF00) THEN
							IF (r < 0) THEN r = 0 ELSE r = 255
						END IF

						UBYTEAT(tbyteAddr+3) = b
						UBYTEAT(tbyteAddr+4) = g
						UBYTEAT(tbyteAddr+5) = r
					END IF

					IF (row < height-1) THEN
						FOR i = -3 TO 3 STEP 3
							IF ((column + i) > 0) && ((column + i) < width-1) THEN

								IFZ i THEN
									iCoeff = 4
								ELSE
									iCoeff = 0
								END IF

								difBlue = 0 : difGreen = 0 : difRed = 0
								IF iCoeff THEN
									difBlue = (lErrorBlue * iCoeff) \ 16
									difGreen = (lErrorGreen * iCoeff) \ 16
									difRed = (lErrorRed * iCoeff) \ 16
								END IF

								nRowByte = (column+i)*3 + rowLength*(row+1)
								tempAddr = toffsetAddr + nRowByte
								b = UBYTEAT(tempAddr+i)   + difBlue
								g = UBYTEAT(tempAddr+i+1) + difGreen
								r = UBYTEAT(tempAddr+i+2) + difRed

								IF (b AND 0xFFFFFF00) THEN
									IF (b < 0) THEN b = 0 ELSE b = 255
								END IF

								IF (g AND 0xFFFFFF00) THEN
									IF (g < 0) THEN g = 0 ELSE g = 255
								END IF

								IF (r AND 0xFFFFFF00) THEN
									IF (r < 0) THEN r = 0 ELSE r = 255
								END IF

								UBYTEAT(tempAddr+i) 	= b
								UBYTEAT(tempAddr+i+1) = g
								UBYTEAT(tempAddr+i+2) = r
							END IF
						NEXT i
					END IF
				END IF
			END IF
		NEXT column
	NEXT row

	DeleteObject (hPal)

	DIM temp[]
	RETURN ($$TRUE)

END FUNCTION
'
'
' ######################################
' #####  XilHalfTonePalette ()  #####
' ######################################
'
FUNCTION  XilWebSafePalette (UBYTE source[], UBYTE dest[], dither)

	SHARED RGB4 tPal[]
	SHARED iPalette

	IFZ source[] THEN RETURN 0

	CreateWebSafePalette ()
	IFZ tPal[] THEN RETURN 0

	XilApplyPalette (@source[], @dest[], dither)

	RETURN XilApplyPalette (@source[], @dest[], dither)

END FUNCTION
'
'
' #################################
' #####  BuildFilterArray ()  #####
' #################################
'
FUNCTION  BuildFilterArray ()

	SHARED matrixWeight, filterType, matrixKernel[], matrixOffset, matrixSize

	matrixWeight = 0

	SELECT CASE filterType
' low pass filter
		CASE $$Blur, $$BlurMore :
			IF (filterType = $$Blur) THEN
				SetFilterArraySize (3)
			ELSE
				SetFilterArraySize (5)
			END IF
			FOR i = -matrixOffset TO matrixOffset
				FOR j = -matrixOffset TO matrixOffset
					matrixKernel[i+matrixOffset, j+matrixOffset] = 1
					matrixWeight = matrixWeight + matrixKernel[i+matrixOffset, j+matrixOffset]
				NEXT j
			NEXT i

		CASE $$Soften, $$SoftenMore :
			IF (filterType = $$Soften) THEN
				SetFilterArraySize (3)
			ELSE
				SetFilterArraySize (5)
			END IF
			FOR i = -matrixOffset TO matrixOffset
				FOR j = -matrixOffset TO matrixOffset
					iX = ABS(i)
					iY = ABS(j)
					IF (iX > iY) THEN
						iLM = iX
					ELSE
						iLM = iY
					END IF
					IF (iLM = 0) THEN
						matrixKernel[i+matrixOffset, j+matrixOffset] = (matrixSize * (matrixSize / 2.0))
					ELSE
						matrixKernel[i+matrixOffset, j+matrixOffset] = matrixOffset - iLM + 1
					END IF
					matrixWeight = matrixWeight + matrixKernel[i+matrixOffset, j+matrixOffset]
				NEXT j
			NEXT i

		CASE $$Sharpen, $$SharpenMore :
			SetFilterArraySize (3)
			IF (filterType = $$Sharpen) THEN
				matrixKernel[-1+matrixOffset, -1+matrixOffset] = -1 : matrixKernel[-1+matrixOffset, 0+matrixOffset] = -1 : matrixKernel[-1+matrixOffset, 1+matrixOffset] = -1
				matrixKernel[0+matrixOffset, -1+matrixOffset]  = -1 : matrixKernel[0+matrixOffset, 0+matrixOffset]  = 15 : matrixKernel[0+matrixOffset, 1+matrixOffset]  = -1
				matrixKernel[1+matrixOffset, -1+matrixOffset]  = -1 : matrixKernel[1+matrixOffset, 0+matrixOffset]  = -1 : matrixKernel[1+matrixOffset, 1+matrixOffset]  = -1
			ELSE
				matrixKernel[-1+matrixOffset, -1+matrixOffset] = 0  : matrixKernel[-1+matrixOffset, 0+matrixOffset] = -1 : matrixKernel[-1+matrixOffset, 1+matrixOffset] = 0
				matrixKernel[0+matrixOffset, -1+matrixOffset]  = -1 : matrixKernel[0+matrixOffset, 0+matrixOffset]  = 5  : matrixKernel[0+matrixOffset, 1+matrixOffset]  = -1
				matrixKernel[1+matrixOffset, -1+matrixOffset]  = 0  : matrixKernel[1+matrixOffset, 0+matrixOffset]  = -1 : matrixKernel[1+matrixOffset, 1+matrixOffset]  = 0
			END IF
			FOR i = -matrixOffset TO matrixOffset
				FOR j = -matrixOffset TO matrixOffset
					matrixWeight = matrixWeight + matrixKernel[i+matrixOffset, j+matrixOffset]
				NEXT j
			NEXT i

		CASE ELSE : RETURN

	END SELECT

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  GetFilterArraySize ()  #####
' ###################################
'
FUNCTION  GetFilterArraySize ()

	SHARED matrixSize

	RETURN matrixSize

END FUNCTION
'
'
' ###############################
' #####  GetFilterValue ()  #####
' ###############################
'
FUNCTION  GetFilterValue (x, y)

	SHARED matrixKernel[]

	RETURN matrixKernel[x, y]

END FUNCTION
'
'
' ################################
' #####  GetFilterWeight ()  #####
' ################################
'
FUNCTION  GetFilterWeight ()

	SHARED matrixWeight
	RETURN matrixWeight

END FUNCTION
'
'
' ###################################
' #####  SetFilterArraySize ()  #####
' ###################################
'
FUNCTION  SetFilterArraySize (size)

	SHARED matrixSize, matrixOffset, matrixKernel[]

    IF (size MOD 2) = 0 THEN
'       PRINT "Size must be an odd number"
				RETURN 0
    ELSE
        IF (size < 3) || (size > 9) THEN
'           PRINT "Invalid size.  Size should be an odd number from 3 to 9"
						RETURN 0
        ELSE
            matrixSize = size
            matrixOffset = matrixSize \ 2
            REDIM matrixKernel[matrixSize-1, matrixSize-1]
        END IF
    END IF

		RETURN ($$TRUE)

END FUNCTION
'
'
' ###############################
' #####  SetFilterValue ()  #####
' ###############################
'
FUNCTION  SetFilterValue (x, y, value)

	SHARED matrixKernel[]
	matrixKernel[x, y] = value

END FUNCTION
'
'
' ################################
' #####  SetFilterWeight ()  #####
' ################################
'
FUNCTION  SetFilterWeight (weight)

	SHARED matrixWeight
	matrixWeight = weight

END FUNCTION
'
'
' ##########################################
' #####  XilBuildCustomFilterArray ()  #####
' ##########################################
'
FUNCTION  XilBuildCustomFilterArray (size, data$)

	SHARED matrixWeight, filterType, matrixKernel[], matrixOffset, matrixSize

	IFZ size THEN RETURN 0
	IFZ data$ THEN RETURN 0

	ret = SetFilterArraySize (size)
	IFZ ret THEN RETURN 0

	XilSetFilterType ($$Custom)
	SetFilterWeight (1)

	FOR i = 0 TO matrixSize-1
		FOR j = 0 TO matrixSize-1
			a$ = NextItem$ (data$, @index, @term, @done)
			value = XLONG(a$)
			SetFilterValue (i, j, value)
		NEXT j
	NEXT i

	RETURN ($$TRUE)

END FUNCTION
'
'
' ###########################
' #####  XilBlur ()  #####
' ###########################
'
FUNCTION  XilCustomFilter (UBYTE source[], UBYTE dest[], size, data$)

	IFZ source[] THEN RETURN 0

	ret = XilBuildCustomFilterArray (size, data$)
	IFZ ret THEN RETURN 0

	RETURN XilStandardFilter (@source[], @dest[])

END FUNCTION
'
'
' #################################
' #####  XilSetfilterType ()  #####
' #################################
'
' Validate and set a standard filter
'
FUNCTION  XilSetFilterType (type)

	SHARED filterType

	IF (type >= 0) && (type <= $$MaxFilter) THEN
		filterType = type
		IF (filterType <> $$Custom) THEN
			BuildFilterArray ()
			RETURN ($$TRUE)
		END IF
	ELSE
'		PRINT "Invalid filter type"
		RETURN 0
	END IF

END FUNCTION
'
'
' ##################################
' #####  XilStandardFilter ()  #####
' ##################################
'
FUNCTION  XilStandardFilter (UBYTE source[], UBYTE dest[])

	SHARED matrixWeight, filterType, matrixKernel[], matrixOffset, matrixSize
	DOUBLE mw

	IFZ source[] THEN RETURN
	
	mw = matrixWeight

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			r = 0: g = 0: b = 0

      FOR i = -matrixOffset TO matrixOffset
      	FOR j = -matrixOffset TO matrixOffset
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					newbyteAddr = soffsetAddr + ((x*3) + (rowLength*y))

     			b = b + matrixKernel[i+matrixOffset, j+matrixOffset] * UBYTEAT(newbyteAddr)
      		g = g + matrixKernel[i+matrixOffset, j+matrixOffset] * UBYTEAT(newbyteAddr+1)
      		r = r + matrixKernel[i+matrixOffset, j+matrixOffset] * UBYTEAT(newbyteAddr+2)

      	NEXT j
      NEXT i

'      r = r \ matrixWeight : g = g \ matrixWeight : b = b \ matrixWeight
			r = r/mw : g = g/mw : b = b/mw
			
			SELECT CASE TRUE
				IF b < 0 THEN b = 0
				IF b > 255 THEN b = 255
			END SELECT

			SELECT CASE TRUE
				IF g < 0 THEN g = 0
				IF g > 255 THEN g = 255
			END SELECT

			SELECT CASE TRUE
				IF r < 0 THEN r = 0
				IF r > 255 THEN r = 255
			END SELECT

			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ########################################
' #####  XilGetImageArrayDetails ()  #####
' ########################################
'
FUNCTION  XilGetImageArrayDetails (UBYTE image[], @numColors, @fileSize, @dataOffset, @headerSize, @planes, @compression, @dataSize, @colors)

	XilGetImageArrayInfo (@image[], @bpp, @width, @height)

	IFZ image[] THEN RETURN 0

'Number of possible colors
	IF bpp <= 24 THEN numColors = 2 ** bpp

'file size bytes 2-5
'Complete file size in bytes.
  fileSize = (image[5] << 24) OR (image[4] << 16) OR (image[3] << 8) OR (image[2])

'bmp data offset bytes 10-13
'Offset from beginning of file to the beginning of the bitmap data.
  dataOffset = (image[13] << 24) OR (image[12] << 16) OR (image[11] << 8) OR (image[10])

'bmp header size bytes 14-17
'Length of the Bitmap Info Header used to describe the bitmap colors, compression
'0x28 or 40 - Windows 3.1x, 95, NT
  headerSize = (image[17] << 24) OR (image[16] << 16) OR (image[15] << 8) OR (image[14])

'planes  bytes 26-27
  planes = (image[27] << 8) OR (image[26])

'compression bytes 30-33
'Compression specifications. The following values are possible:
'0 - none (Also identified by BI_RGB)
'1 - RLE 8-bit / pixel (Also identified by BI_RLE4)
'2 - RLE 4-bit / pixel (Also identified by BI_RLE8)
'3 - Bitfields  (Also identified by BI_BITFIELDS)
  compression = (image[33] << 24) OR (image[32] << 16) OR (image[31] << 8) OR (image[30])

'bmp data size bytes 34-37
'Size of the bitmap data in bytes. This number must be rounded
' to the next 4 byte boundary.
  dataSize = (image[37] << 24) OR (image[36] << 16) OR (image[35] << 8) OR (image[34])

'Horizontal Resolution bytes 38-41
'Horizontal resolution expressed in pixel per meter.
'  horzRes = (image[41] << 24) OR (image[40] << 16) OR (image[39] << 8) OR (image[38])

'Vertical Resolution bytes 42-45
'Vertical resolution expressed in pixels per meter.
'  vertRes = (image[45] << 24) OR (image[44] << 16) OR (image[43] << 8) OR (image[42])

'Number of colors bytes 46-49
'Number of colors used by this bitmap.
'For a 8-bit / pixel bitmap this will be 0x100 or 256.
  colors = (image[49] << 24) OR (image[48] << 16) OR (image[47] << 8) OR (image[46])

'Number of important colors bytes 50-53
'Number of important colors.
'This number will be equal to the number of colors
'when every color is important.
'  colorsImp = (image[53] << 24) OR (image[52] << 16) OR (image[51] << 8) OR (image[50])

	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XilGetImageArrayInfo ()  #####
' #####################################
'
FUNCTION  XilGetImageArrayInfo (UBYTE image[], @bpp, @width, @height)

	IFZ image[] THEN RETURN ($$FALSE)
	bytes = SIZE (image[])
	iAddr = &image[]
'
	IF (bytes < 32) THEN
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
' #########################
' #####  RGBToHLS ()  #####
' #########################
'
'PURPOSE :	Convert 24bpp RGB color to HLS values (hue, lightness, saturation)
'
FUNCTION  RGBToHLS (r, g, b, DOUBLE h, DOUBLE s, DOUBLE l)

DOUBLE Max, Min, delta, rR, rG, rB

	rR = r / 255.0 : rG = g / 255.0 : rB = b / 255.0

'IN		: rgb each in range (0-1)
'OUT	: h in range (0-360) and s in range (0-1), except if s=0, then h=UNDEFINED

	Max = MAX(rR, MAX(rG,rB))
	Min = MIN(rR, MIN(rG,rB))
	l = (Max + Min) / 2.0    			' this is the lightness(luminosity)

	IF Max = Min THEN							' its greyscale
		s = 0.
		h = 0.											' actually undefined its color
	ELSE													' calculate the saturation
		delta = Max - Min
		IF l <= 0.5 THEN
			s = delta / (Max + Min)
		ELSE
			s = delta / (2.0 - Max - Min)
		END IF

		SELECT CASE TRUE						' calculate the hue
			CASE rR = Max : h = (rG - rB) / delta    		' resulting color is between yellow and magenta
			CASE rG = Max	: h = 2.0 + (rB - rR) / delta ' resulting color is between cyan and yellow
			CASE rB = Max	: h = 4.0 + (rR - rG) / delta ' resulting color is between magenta and cyan
		END SELECT

'	h = h / 6.0
'	IF h < 0 THEN h = h + 1.0
	END IF

	RETURN ($$TRUE)
END FUNCTION
'
'
' #########################
' #####  HLSToRGB ()  #####
' #########################
'
'PURPOSE : Convert HLS (hue, lightness, saturation) values to 24bpp RGB values

FUNCTION  HLSToRGB (DOUBLE h, DOUBLE s, DOUBLE l, @r, @g, @b)

DOUBLE rR, rG, rB, Min, Max

	IF s = 0 THEN											'greyscale
		rR = l : rG = l : rB = l
	ELSE																'color
		IF l <= 0.5 THEN
			Min = l * (1 - s)						'Get Min value
		ELSE
			Min = l - s * (1 - l)				'Get Min value
		END IF

		Max = 2 * l - Min								'Get the Max value

		SELECT CASE TRUE								'Now depending on sector we can evaluate the h,l,s
			CASE h < 1 :
				rR = Max
				IF (h < 0) THEN
					rG = Min
					rB = rG - h * (Max - Min)
				ELSE
					rB = Min
					rG = h * (Max - Min) + rB
				END IF

			CASE (h >= 1) && (h < 3) :
				rG = Max
				IF (h < 2) THEN
					rB = Min
					rR = rB - (h - 2) * (Max - Min)
				ELSE
					rR = Min
					rB = (h - 2) * (Max - Min) + rR
				END IF

			CASE h >= 3 :
				rB = Max
				IF (h < 4) THEN
					rR = Min
					rG = rR - (h - 4) * (Max - Min)
				ELSE
					rG = Min
					rR = (h - 4) * (Max - Min) + rG
				END IF
		END SELECT
	END IF
	r = rR * 255.0 : g = rG * 255.0 : b = rB * 255.0

	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XilConvertColorToRGB ()  #####
' #####################################
'
FUNCTION  XilConvertColorToRGB (color, @r, @g, @b)

	r = color{8,0}
	g = color{8,8}
	b = color{8,16}

END FUNCTION
'
'
' ###################################
' #####  CumulativeSumArray ()  #####
' ###################################
'
FUNCTION  CumulativeSumArray (DOUBLE array[], DOUBLE cumSum[])

	DOUBLE temp[]

	IFZ array[] THEN RETURN 0

	upper = UBOUND(array[])
	DIM temp[upper]
	DIM cumSum[upper]

	temp[0] = array[0]
	FOR i = 1 TO upper
		temp[i] = temp[i-1] + array[i]
	NEXT i

	RtlMoveMemory (&cumSum[], &temp[], SIZE(temp[]))

	DIM temp[]

	RETURN ($$TRUE)

END FUNCTION
'
'
' ##############################
' #####  HistogramCalc ()  #####
' ##############################
'
FUNCTION  HistogramCalc (UBYTE source[], @histR[], @histG[], @histB[])

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, 0, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

	DIM histR[255]
	DIM histG[255]
	DIM histB[255]

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			INC histB[UBYTEAT(soffsetAddr)]
			INC histG[UBYTEAT(soffsetAddr+1)]
			INC histR[UBYTEAT(soffsetAddr+2)]
			soffsetAddr = soffsetAddr + 3
		NEXT column
		align = (soffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN soffsetAddr = soffsetAddr + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
'
' ################################
' #####  GetClosestIndex ()  #####
' ################################
'
FUNCTION  GetClosestIndex (@lIndex, red, green, blue)

'ColorDistance algorithm by Thiadmeer Tiemersma

	SHARED RGB4 tPal[]
	SHARED iPalette

	IFZ tPal[] THEN RETURN

'	lMinER = 255: lMinEB = 255: lMinEG = 255

	minCD = 0x7FFFFFFF

	FOR i = 0 TO iPalette-1

'		IF (red == tPal[i].red) && (green == tPal[i].green) && (blue == tPal[i].blue) THEN
'			lIndex = i
'			RETURN
'		ELSE

			rmean = (red + tPal[i].red) /2
			r = red   - tPal[i].red
			g = green - tPal[i].green
			b = blue  - tPal[i].blue

			colorDistance = ((512+rmean)*r*r) + (4*g*g) + ((767-rmean)*b*b)

			IF colorDistance < minCD THEN
				minCD = colorDistance
				lIndex = i
			END IF

'alternate method to get closest index
'			lER = ABS(red - tPal[i].red)
'			lEB = ABS(blue - tPal[i].blue)
'			lEG = ABS(green - tPal[i].green)
'			IF (lER + lEB + lEG < lMinER + lMinEB + lMinEG) THEN
'				lMinER = lER
'				lMinEB = lEB
'				lMinEG = lEG
'				lIndex = i
'			END IF

'		END IF
	NEXT i
	RETURN ($$TRUE)

END FUNCTION
'
'
' ##########################
' #####  NextItem$ ()  #####
' ##########################
'
FUNCTION  NextItem$ (source$, index, term, done)

	STATIC  UBYTE  char[]
	STATIC  UBYTE  term[]
'
	IFZ char[] THEN GOSUB Initialize
'
	done = $$FALSE
	IF (index < 1) THEN index = 1
'
	length = LEN (source$)
	IF (index > length) THEN done = $$TRUE : RETURN ("")
'
' find next separator / terminator
'
	final = 0							' index of last valid character
	first = 0							' index of first valid character
	offset = index - 1		' ditto
'
	DO WHILE (offset < length)
		char = source${offset}
		INC offset
		IF char[char] THEN
			final = offset
			IFZ first THEN first = offset
		END IF
	LOOP UNTIL term[char]
'
	term = char
	IF (offset >= length) THEN
		offset = length + 1
		term = $$FALSE
		done = $$TRUE
	END IF
'
	index = offset + 1
	IFZ first THEN RETURN ("")
	RETURN (MID$(source$, first, final-first+1))
'
'
' *****  Initialize  *****
'
SUB Initialize
'
	DIM char[255]					' array of valid characters
	DIM term[255]					' array of terminator characters
'
	FOR i = 0 TO 255
		char[i] = i					' start with all bytes valid characters
	NEXT i
'
	FOR i = 0x00 TO 0x1F
		char[i] = 0					' 0x00 to 0x1F are not valid characters
	NEXT i
'
	FOR i = 0x80 TO 0xFF
		char[i] = 0					' 0x80 to 0xFF are not valid characters
	NEXT i
'
	char[','] = 0					' comma is a separator
	char['\n'] = 0				' newline is a separator
	char['\t'] = 0				' tab is a separator
'
	term[','] = ','				' comma is a separator
	term['\n'] = '\n'			' newline is a separator
	term['\t'] = '\t'			' tab is a separator
'
END SUB
END FUNCTION
'
'
' ##########################
' #####  RNUniform ()  #####
' ##########################
'
' This is a basic uniform RNG based on srand() and rand()
' in msvcrt.dll. rand() is NOT a very good RNG.
'
FUNCTION  DOUBLE RNUniform ()

	STATIC seed

	IFZ seed THEN GOSUB MakeSeed
	RETURN  rand () / 32767.0

' ***** MakeSeed *****
SUB MakeSeed
	seed = (GetTickCount () MOD 32767) + 1
	srand (seed)
END SUB

END FUNCTION
'
'
' ###########################
' #####  ValidRange ()  #####
' ###########################
'
' A CLAMP function
'
FUNCTION  ValidRange (@value, lower, upper)

	SELECT CASE TRUE
		CASE value < lower : value = lower
		CASE value > upper : value = upper
	END SELECT

END FUNCTION
'
' #############################
' #####  XilResizeBiQuad  #####
' #############################
'
' Biquadratic Interpolation for rescaling
'
FUNCTION  XilResizeBiQuad (UBYTE source[], UBYTE dest[], destWidth, destHeight)

DOUBLE xScale, yScale
DOUBLE dx1, dy1
DOUBLE dx, dy
DOUBLE x0, y0
DOUBLE qx, qy
DOUBLE ra, rb, rc, ga, gb, gc, ba, bb, bc

	IFZ source[] THEN RETURN 0
	IFZ destWidth THEN RETURN 0
	IFZ destHeight THEN RETURN 0

	XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)

	IF (sWidth = destWidth) && (sHeight = destHeight) THEN
		RtlMoveMemory (&dest[], &source[], SIZE(source[]))
		RETURN ($$TRUE)
	END IF

	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc size of dest[]
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of destination file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}

	xScale = (sWidth) / DOUBLE(destWidth)
	yScale = (sHeight) / DOUBLE(destHeight)
	
	offset = dataOffset

	FOR y = 0 TO destHeight - 1
		y0 = yScale * (y)		
		y1 = INT (y0)	

		FOR x = 0 TO destWidth - 1

			x0 = xScale * (x) ' scaling
			x1 = INT (x0)			' reference in source
			
			sByte1 = dataOffset + (x1*3) + (sRowBytes*y1)
			b11 = source[sByte1]
			g11 = source[sByte1+1]
			r11 = source[sByte1+2]
			
			IFZ x1 THEN 
				b01 = b11
				g01 = g11
				r01 = r11
			ELSE
				b01 = source[sByte1-3]
				g01 = source[sByte1-2]
				r01 = source[sByte1-1]	
			END IF

			IF x1 = sWidth - 1 THEN
				b21 = b11
				g21 = g11
				r21 = r11
			ELSE
				b21 = source[sByte1+3]
				g21 = source[sByte1+4]
				r21 = source[sByte1+5]
			END IF
			
									
			sByte0 = sByte1 - sRowBytes
			IFZ y1 THEN sByte0 = sByte1
			b10 = source[sByte0]
			g10 = source[sByte0+1]
			r10 = source[sByte0+2]
			IFZ x1 THEN
				b00 = b10
				g00 = g10
				r00 = r10		
			ELSE
				b00 = source[sByte0-3]
				g00 = source[sByte0-2]
				r00 = source[sByte0-1]
			END IF			

			IF x1 = sWidth - 1 THEN
				b20 = b10
				g20 = g10
				r20 = r10
			ELSE
				b20 = source[sByte0+3]
				g20 = source[sByte0+4]
				r20 = source[sByte0+5]	
			END IF		

			sByte2 = sByte1 + sRowBytes
			IF y1 = sHeight - 1 THEN sByte2 = sByte1
			b12 = source[sByte2]
			g12 = source[sByte2+1]
			r12 = source[sByte2+2]
			
			IFZ x1 THEN
				b02 = b12
				g02 = g12
				r02 = r12
			ELSE
				b02 = source[sByte2-3]
				g02 = source[sByte2-2]
				r02 = source[sByte2-1]
			END IF			

			IF x1 = sWidth - 1 THEN
				b22 = b12
				g22 = g12
				r22 = r12
			ELSE
				b22 = source[sByte2+3]
				g22 = source[sByte2+4]
				r22 = source[sByte2+5]
			END IF

			dx=x0-x1
			dy=y0-y1
			qx=0.5*dx*dx
			qy=0.5*dy*dy
			dx=0.5*dx
			dy=0.5*dy

			ra=r10+(r20-r00)*dx+(r00-2*r10+r20)*qx
			rb=r11+(r21-r01)*dx+(r01-2*r11+r21)*qx
			rc=r12+(r22-r02)*dx+(r02-2*r12+r22)*qx
			ga=g10+(g20-g00)*dx+(g00-2*g10+g20)*qx
			gb=g11+(g21-g01)*dx+(g01-2*g11+g21)*qx
			gc=g12+(g22-g02)*dx+(g02-2*g12+g22)*qx
			ba=b10+(b20-b00)*dx+(b00-2*b10+b20)*qx
			bb=b11+(b21-b01)*dx+(b01-2*b11+b21)*qx
			bc=b12+(b22-b02)*dx+(b02-2*b12+b22)*qx
				
			r11=INT(rb+(rc-ra)*dy+(ra-2*rb+rc)*qy)
			g11=INT(gb+(gc-ga)*dy+(ga-2*gb+gc)*qy)
			b11=INT(bb+(bc-ba)*dy+(ba-2*bb+bc)*qy)

			SELECT CASE ALL TRUE
				CASE (r11 < 0)   : r11 = 0
				CASE (r11 > 255) : r11 = 255
				CASE (g11 < 0)   : g11 = 0
				CASE (g11 > 255) : g11 = 255
				CASE (b11 < 0)   : b11 = 0
				CASE (b11 > 255) : b11 = 255									
			END SELECT

			dest[offset] 		= b11
			dest[offset+1] 	= g11
			dest[offset+2] 	= r11
			offset = offset + 3
		NEXT x
		align = (offset - 54){2,0}										' ok if align = 0
		IF align THEN offset = offset + (4 - align)		' align 4
	NEXT y

	RETURN ($$TRUE)

END FUNCTION
'
' ######################
' #####  XilErode  #####
' ######################
'
' For each pixel, take the minimum of the NxN kernel. 
' This will grow the dark areas.
' The level parameter sets the kernel size, level = 1 = 3x3; level = 2 = 5x5 etc.
'
FUNCTION  XilErode (UBYTE source[], UBYTE dest[], level)

	IFZ source[] THEN RETURN 0
	IFZ level THEN level = 1

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			r = 255 : g = 255 : b = 255
      FOR i = -level TO level
      	FOR j = -level TO level
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					newbyteAddr = soffsetAddr + ((x*3) + (rowLength*y))

     			b = MIN (b, UBYTEAT(newbyteAddr))
					g = MIN (g, UBYTEAT(newbyteAddr+1))
					r = MIN (r, UBYTEAT(newbyteAddr+2))

      	NEXT j
      NEXT i
			
			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
' #######################
' #####  XilDilate  #####
' #######################
'
' For each pixel, take the maximum of the NxN kernel. 
' This will grow the light areas.
' The level parameter sets the kernel size, level = 1 = 3x3; level = 2 = 5x5 etc.
'
FUNCTION  XilDilate (UBYTE source[], UBYTE dest[], level)

	IFZ source[] THEN RETURN 0
	IFZ level THEN level = 1

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			r = 0 : g = 0 : b = 0 
      FOR i = -level TO level
      	FOR j = -level TO level
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					newbyteAddr = soffsetAddr + ((x*3) + (rowLength*y))

     			b = MAX (b, UBYTEAT(newbyteAddr))
					g = MAX (g, UBYTEAT(newbyteAddr+1))
					r = MAX (r, UBYTEAT(newbyteAddr+2))

      	NEXT j
      NEXT i
			
			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
' #################################
' #####  XilDectectEdgeSobel  #####
' #################################
'
' 3x3 Sobel masks for edge detection
'
FUNCTION  XilDetectEdgeSobel (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	STATIC initialize
	STATIC kernelVert[], kernelHorz[]
	
	IFZ source[] THEN RETURN
	IFZ initialize THEN GOSUB InitKernel
	
	' convert source image to grayscale
	XilGrayScale1 (@source[], @temp[])	

  XilGetImageArrayInfo(@temp[], @bpp, @width, @height)
	XilGetImageArrayDetails (@temp[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(temp[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = temp[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			xSum = 0 : ySum = 0
      FOR i = -1 TO 1
      	FOR j = -1 TO 1
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					value = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
					
     			xSum = xSum + kernelHorz[i+1, j+1] * value
     			ySum = ySum + kernelVert[i+1, j+1] * value

      	NEXT j
      NEXT i
			
			sum = ABS(xSum) + ABS(ySum)

			SELECT CASE TRUE
				CASE sum < 0   : sum = 0
				CASE sum > 255 : sum = 255
			END SELECT
			
			UBYTEAT(doffsetAddr)   = sum
			UBYTEAT(doffsetAddr+1) = sum
			UBYTEAT(doffsetAddr+2) = sum

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row
	
	DIM temp[]

	RETURN ($$TRUE)
	
SUB InitKernel
	initialize = $$TRUE
	DIM kernelHorz[2,2]
	kernelHorz[0, 0] = -1 : kernelHorz[0, 1] = 0 : kernelHorz[0, 2] = 1
	kernelHorz[1, 0] = -2 : kernelHorz[1, 1] = 0 : kernelHorz[1, 2] = 2
	kernelHorz[2, 0] = -1 : kernelHorz[2, 1] = 0 : kernelHorz[2, 2] = 1
	DIM kernelVert[2,2]
	kernelVert[0, 0] =  1 : kernelVert[0, 1] =  2 : kernelVert[0, 2] =  1
	kernelVert[1, 0] =  0 : kernelVert[1, 1] =  0 : kernelVert[1, 2] =  0
	kernelVert[2, 0] = -1 : kernelVert[2, 1] = -2 : kernelVert[2, 2] = -1
END SUB

END FUNCTION
'
' ##################################
' #####  XilDetectEdgeLaplace  #####
' ##################################
'
' 5x5 Laplace mask for edge detection
'
FUNCTION  XilDetectEdgeLaplace (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	STATIC initialize
	STATIC kernelL[]
	
	IFZ source[] THEN RETURN
	IFZ initialize THEN GOSUB InitKernel
	
	' convert source image to grayscale
	XilGrayScale1 (@source[], @temp[])	

  XilGetImageArrayInfo(@temp[], @bpp, @width, @height)
	XilGetImageArrayDetails (@temp[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(temp[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = temp[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
	weight = 24

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			sum = 0
      FOR i = -2 TO 2
      	FOR j = -2 TO 2
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					value = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
     			sum = sum + kernelL[i+2, j+2] * value

      	NEXT j
      NEXT i
			
'			sum = sum/DOUBLE(weight) + 128

			
			SELECT CASE TRUE
				CASE sum < 0   : sum = 0
				CASE sum > 255 : sum = 255
			END SELECT
			
			UBYTEAT(doffsetAddr)   = sum
			UBYTEAT(doffsetAddr+1) = sum
			UBYTEAT(doffsetAddr+2) = sum

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row
	
	DIM temp[]

	RETURN ($$TRUE)
	
SUB InitKernel
	initialize = $$TRUE
	DIM kernelL[4,4]
	kernelL[0, 0] = -1 : kernelL[0, 1] = -1 : kernelL[0, 2] = -1 : kernelL[0, 3] = -1 : kernelL[0, 4] = -1
	kernelL[1, 0] = -1 : kernelL[1, 1] = -1 : kernelL[1, 2] = -1 : kernelL[1, 3] = -1 : kernelL[1, 4] = -1
	kernelL[2, 0] = -1 : kernelL[2, 1] = -1 : kernelL[2, 2] = 24 : kernelL[2, 3] = -1 : kernelL[2, 4] = -1
	kernelL[3, 0] = -1 : kernelL[3, 1] = -1 : kernelL[3, 2] = -1 : kernelL[3, 3] = -1 : kernelL[3, 4] = -1
	kernelL[4, 0] = -1 : kernelL[4, 1] = -1 : kernelL[4, 2] = -1 : kernelL[4, 3] = -1 : kernelL[4, 4] = -1
END SUB

END FUNCTION
'
' ##################################
' #####  CreateGaussianKernel  #####
' ##################################
'
' Create gaussian kernel mask array. Default sigma is 1.0.
' Scale sets midpoint value of array (as max value of array).
' Returns kernel array kernel[] and weight of kernel (sum of elements).
'
FUNCTION CreateGaussianKernel (DOUBLE sigma, scale, @kernel[], @weight)

	IFZ sigma THEN sigma = 1.0

  width = (sigma*8)-1
	IFZ (width MOD 2) THEN DEC width

	IFZ scale THEN scale = 2**(width+1)

	radius = width/2
	weight = 0

	DIM kernel[width-1, width-1]

	FOR i = -radius TO radius
		FOR j = -radius TO radius
			res = scale * exp(-(i*i+j*j)/(2.0*sigma*sigma))
			kernel[i+radius, j+radius] = res
			weight = weight + res
		NEXT j
	NEXT i
END FUNCTION
'
' #############################
' #####  XilGaussianBlur  #####
' #############################
'
' Use gaussian mask to blur(smooth) image
' See CreateGaussianKernel() function.
'
FUNCTION  XilGaussianBlur (UBYTE source[], UBYTE dest[], DOUBLE sigma, scale)

	DOUBLE mw

	IFZ source[] THEN RETURN
	
	CreateGaussianKernel (sigma, scale, @matrixKernel[], @weight)
	
	matrixOffset = UBOUND(matrixKernel[])/2
	
	mw = weight

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN

	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			r = 0: g = 0: b = 0

      FOR i = -matrixOffset TO matrixOffset
      	FOR j = -matrixOffset TO matrixOffset
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					newbyteAddr = soffsetAddr + ((x*3) + (rowLength*y))

     			b = b + matrixKernel[i+matrixOffset, j+matrixOffset] * UBYTEAT(newbyteAddr)
      		g = g + matrixKernel[i+matrixOffset, j+matrixOffset] * UBYTEAT(newbyteAddr+1)
      		r = r + matrixKernel[i+matrixOffset, j+matrixOffset] * UBYTEAT(newbyteAddr+2)

      	NEXT j
      NEXT i

			r = r/mw : g = g/mw : b = b/mw
			
			SELECT CASE TRUE
				IF b < 0 THEN b = 0
				IF b > 255 THEN b = 255
			END SELECT

			SELECT CASE TRUE
				IF g < 0 THEN g = 0
				IF g > 255 THEN g = 255
			END SELECT

			SELECT CASE TRUE
				IF r < 0 THEN r = 0
				IF r > 255 THEN r = 255
			END SELECT

			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)

END FUNCTION
'
' ################################
' #####  XilDetectEdgeCanny  #####
' ################################
'
' The Canny edge detection algorithm. Use sigma between 0.6 and 3.0. Default sigma is 1.0.
' Larger threshold values will reduce image detail. Default thresh is 5.
'
FUNCTION XilDetectEdgeCanny (UBYTE source[], UBYTE dest[], DOUBLE sigma, thresh)

	UBYTE g[], temp[]
	DOUBLE Dx, Dy, Dxx, Dxy, Dyy
	DOUBLE Data2[]

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN
	
	XilGrayScale1 (@source[], @temp[])
	XilGaussianBlur (@temp[], @g[], sigma, 0)
	
	IF thresh <= 0 THEN thresh = 5

	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in g[]
	saddress = &g[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
	DIM Data2[height-1, width-1]
	DIM Data3[height-1, width-1]

	FOR y = 1 TO height-2
		FOR x = 1 TO width-2
 
			addr = soffsetAddr + ((x*3) + (rowLength*y))
			yx = UBYTEAT(addr)
			yx0 = UBYTEAT(addr - 3)
			yx1 = UBYTEAT(addr + 3)
			
			y0x = UBYTEAT(addr - rowLength)
			y0x0 = UBYTEAT(addr - rowLength - 3)
			y0x1 = UBYTEAT(addr - rowLength + 3)
			
			y1x = UBYTEAT(addr + rowLength)
			y1x0 = UBYTEAT(addr + rowLength - 3)
			y1x1 = UBYTEAT(addr + rowLength + 3)
	
   ' Calculate second directional derivative 
       ' Estimate derivatives
      Dx = (y1x1 + 2*yx1 + y0x1 - y1x0 - 2*yx0 - y0x0)/8.0
      Dy = (y1x1 + 2*y1x + y1x0 - y0x1 - 2*y0x - y0x0)/8.0			
      Dxx = (y1x1 + 2*yx1 + y0x1 - 2*y1x - 4*yx - 2*y0x + y1x0 + 2*yx0 + y0x0)/4.0
      Dyy = (y1x1 - 2*yx1 + y0x1 + 2*y1x - 4*yx + 2*y0x + y1x0 - 2*yx0 + y0x0)/4.0
      Dxy = (y1x1 - y0x1 - y1x0 + y0x0)/4.0
      ' Calculate second directional derivative
      Data2[y, x] = Dx*Dx*Dxx + 2*Dx*Dy*Dxy + Dy*Dy*Dyy

		NEXT x
	NEXT y
	
  ' Handle boundary rows and columns 
  FOR x = 0 TO width-1
      Data2[0, x] = Data2[1, x]
      Data2[height-1, x] = Data2[height-2, x]
	NEXT x
	
  FOR y = 0 TO height-1 
    Data2[y, 0] = Data2[y, 1]
		Data2[y, width-1] = Data2[y, width-2]
	NEXT y
	
  ' Loop through rows looking for zero crossings
  FOR y = 0 TO height-1
		FOR x = 1 TO width-1
			' Mark pixel location closest to zero 
			IF ((Data2[y, x-1] < 0.0) && (Data2[y, x] >= 0.0)) THEN
				IF (-Data2[y, x-1] < Data2[y, x]) THEN
					Data3[y, x-1] = 1
				ELSE
					Data3[y, x] = 1
				END IF
			END IF
			' Mark pixel location closest to zero
			IF ((Data2[y, x] < 0.0) && (Data2[y, x-1] >= 0.0)) THEN
				IF (-Data2[y, x] < Data2[y, x-1]) THEN
					Data3[y, x] = 1
				ELSE
					Data3[y, x-1] = 1
				END IF
			END IF
		NEXT x
	NEXT y
	
  ' Loop through columns looking for zero crossings
  FOR y = 1 TO height-1 
		FOR x = 0 TO width-1
      ' Mark pixel location closest to zero
      IF ((Data2[y-1, x] < 0.0) && (Data2[y, x] >= 0.0)) THEN
        IF (-Data2[y-1, x] < Data2[y, x]) THEN
          Data3[y-1, x] = 1
        ELSE
          Data3[y, x] = 1
				END IF
			END IF
      ' Mark pixel location closest to zero
      IF ((Data2[y, x] < 0.0) && (Data2[y-1, x] >= 0.0)) THEN
        IF (-Data2[y, x] < Data2[y-1, x]) THEN
          Data3[y, x] = 1
        ELSE
          Data3[y-1, x] = 1
				END IF
			END IF
		NEXT x
	NEXT y
	
  ' Process first and last row
  FOR x = 0 TO width-1
    IF (Data2[0, x] < 0.0) THEN
      Data3[0, x] = 1
		END IF
    IF (Data2[height-1, x] < 0.0) THEN
      Data3[height-1,x] = 1
		END IF
	NEXT x

  ' Process first and last column
  FOR y = 0 TO height-1
    IF (Data2[y, 0] < 0.0) THEN
      Data3[y, 0] = 1
		END IF
    IF (Data2[y, width-1] < 0.0) THEN
      Data3[y, width-1] = 1
		END IF
	NEXT y
	
  ' Calculate gradient magnitude 
  FOR y = 1 TO height-2
		FOR x = 1 TO width-2
			
			addr = soffsetAddr + ((x*3) + (rowLength*y))
			yx = UBYTEAT(addr)
			yx0 = UBYTEAT(addr - 3)
			yx1 = UBYTEAT(addr + 3)
			
			y0x = UBYTEAT(addr - rowLength)
			y0x0 = UBYTEAT(addr - rowLength - 3)
			y0x1 = UBYTEAT(addr - rowLength + 3)
			
			y1x = UBYTEAT(addr + rowLength)
			y1x0 = UBYTEAT(addr + rowLength - 3)
			y1x1 = UBYTEAT(addr + rowLength + 3)

      'Estimate derivatives
      Dx = (y1x1 + 2*yx1 + y0x1 - y1x0 - 2*yx0 - y0x0)/8.0
      Dy = (y1x1 + 2*y1x + y1x0 - y0x1 - 2*y0x - y0x0)/8.0
      ' Perform thresholding based on gradient magnitude
      IF ((Dx*Dx + Dy*Dy) < thresh) THEN Data3[y, x] = 0
		NEXT x
	NEXT y
	
	' write information to output array
	FOR y = 0 TO height-1
		FOR x = 0 TO width - 1
			value = Data3[y, x] * 255
			UBYTEAT(doffsetAddr)   = value
			UBYTEAT(doffsetAddr+1) = value
			UBYTEAT(doffsetAddr+2) = value

			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT y
	
	RETURN ($$TRUE)

END FUNCTION
'
' #######################################
' #####  XilDetectEdgeZeroCrossing  #####
' #######################################
'
'
FUNCTION XilDetectEdgeZeroCrossing (UBYTE source[], UBYTE dest[], DOUBLE sigma, thresh, fLaplace)

	UBYTE g[], temp[]
	DOUBLE data0[]

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)

	IF bpp <> 24 THEN RETURN
	IF thresh < 0 THEN thresh = 0
		
	XilGrayScale1 (@source[], @temp[])
	XilGaussianBlur (@temp[], @g[], sigma, 0)
	
	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in g[]
	saddress = &g[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
' Convolve the laplacian kernel with the image
' Save calculations in data0[] array

	DIM data0[height-1, width-1]
	GOSUB InitKernel
	
	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			sum = 0
      FOR i = -1 TO 1
      	FOR j = -1 TO 1
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					value = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
     			sum = sum + kernel[i+1, j+1] * value

      	NEXT j
      NEXT i
			
			data0[row, column] = sum/DOUBLE(weight)

		NEXT column
	NEXT row

' To find the zero crossings in the image you must check each point 
' in the array to see if it lies on a zero crossing. This is done by
' checking the neighbours around the pixel.

	DIM data[height-1, width-1]
	
	FOR y = 1 TO height-2
		FOR x = 1 TO width-2
			yx   = data0[y, x]
			IF yx < 0 THEN DO NEXT
			yx0  = data0[y, x-1]
			yx1  = data0[y, x+1]
			
			y0x  = data0[y-1, x]
			y0x0 = data0[y-1, x-1]
			y0x1 = data0[y-1, x+1]
			
			y1x  = data0[y+1, x]
			y1x0 = data0[y+1, x-1]
			y1x1 = data0[y+1, x+1]
			
			SELECT CASE TRUE
			
				CASE yx0*yx1 < 0 : 
					IF ABS(yx0) + ABS(yx1) > thresh THEN data[y, x] = 255
    
				CASE y1x0*y0x1 < 0 :
					IF ABS(y1x0) + ABS(y0x1) > thresh THEN data[y, x] = 255

				CASE y1x1*y0x0 < 0 :
					IF ABS(y1x1) + ABS(y0x0) > thresh THEN	data[y, x] = 255

				CASE y0x*y1x < 0 :
					IF ABS(y0x) + ABS(y1x) > thresh THEN data[y, x] = 255

			END SELECT

		NEXT x
	NEXT y

' **********************************************************	

'  FOR y = 0 TO height - 1
'    ym1 = MAX(0, y - 1)
'    yp1 = MIN(height - 1, y + 1)
	
'		FOR x = 0 TO width - 1
'      xm1 = MAX(0, x - 1)
'      xp1 = MIN(width - 1, x + 1)

'      ' A zero crossing occurs whenever there is a + pixel with a - neighbour

'      IF ((data0[y, x] >= 0) && ((data0[ym1, xm1] <= 0) || (data0[y, xm1] <= 0) || (data0[yp1, xm1] <= 0) || (data0[ym1, x] <= 0) || (data0[yp1, x] <= 0) || (data0[ym1, xp1] <= 0) || (data0[y, xp1] <= 0) || (data0[yp1, xp1] <= 0))) THEN
'        data[y, x] = 255
'      ELSE 
'				data[y, x] = 0
'			END IF
'		NEXT x
'	NEXT y
	
' ************************************************************	

'  FOR j = 1 TO height-2 
'		FOR i = 1 TO width-2 
'			' test in x direction 
'			SELECT CASE TRUE
'				CASE (data0[j, i-1] > 0) && (data0[j, i+1] < 0) : 
'          data[j, i] = 255
'        CASE (data0[j, i-1] < 0) && (data0[j, i+1] > 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] < 0) && (data0[j, i+1] > 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] > 0) && (data0[j, i+1] < 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] > 0) && (data0[j, i-1] < 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] < 0) && (data0[j, i-1] > 0) :
'          data[j, i] = 255

'        ' test in y direction 
'        CASE (data0[j-1, i] < 0) && (data0[j+1, i] > 0) :
'          data[j, i] = 255
'        CASE (data0[j-1, i] > 0) && (data0[j+1, i] < 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] > 0) && (data0[j+1, i] < 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] < 0) && (data0[j+1, i] > 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] < 0) && (data0[j-1, i] > 0) :
'          data[j, i] = 255
'        CASE (data0[j, i] > 0) && (data0[j-1, i] < 0) :
'          data[j, i] = 255
'			END SELECT
'		NEXT i
'	NEXT j
	
	
	' write information to output array
	FOR y = 0 TO height-1
		FOR x = 0 TO width - 1
			UBYTEAT(doffsetAddr)   = data[y, x]
			UBYTEAT(doffsetAddr+1) = data[y, x]
			UBYTEAT(doffsetAddr+2) = data[y, x]
			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT y
	
	RETURN ($$TRUE)
	
	
SUB InitKernel
	DIM kernel[2,2]
	SELECT CASE fLaplace
		CASE $$LAPLACIAN1 : kernel$ = "0,1,0,1,-4,1,0,1,0" : weight = 4  
		CASE $$LAPLACIAN2 : kernel$ = "1,1,1,1,-8,1,1,1,1" : weight = 8
		CASE $$LAPLACIAN3 : kernel$ = "1,2,1,2,-12,2,1,2,1": weight = 12
		CASE ELSE : 				kernel$ = "0,1,0,1,-4,1,0,1,0" : weight = 4  
	END SELECT
	
	FOR i = 0 TO 2
		FOR j = 0 TO 2
			a$ = NextItem$ (kernel$, @index, @term, @done)
			value = XLONG(a$)
			kernel[i, j] = value
		NEXT j
	NEXT i
END SUB

END FUNCTION
'
' #####################################
' #####  XilDetectEdgeLaplace3x3  #####
' #####################################
'
'
'
FUNCTION XilDetectEdgeLaplace3x3 (UBYTE source[], UBYTE dest[], fLaplace)

	UBYTE temp[]
	DOUBLE w

	IFZ source[] THEN RETURN
  XilGetImageArrayInfo (@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)
	IF bpp <> 24 THEN RETURN
	
	XilGrayScale1 (@source[], @temp[])
	
	SELECT CASE fLaplace
		CASE $$LAPLACIAN1 : kernel$ = "0,1,0,1,-4,1,0,1,0"  : weight = 4  
		CASE $$LAPLACIAN2 : kernel$ = "1,1,1,1,-8,1,1,1,1"  : weight = 8
		CASE $$LAPLACIAN3 : kernel$ = "1,2,1,2,-12,2,1,2,1" : weight = 12
		CASE ELSE : 				kernel$ = "0,1,0,1,-4,1,0,1,0"  : weight = 4  
	END SELECT
	
	w = weight

	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

	FOR row = 0 TO height-1
		FOR column = 0 TO width-1
			sum = 0

      FOR i = -1 TO 1
      	FOR j = -1 TO 1
					x = column + j
					IF x < 0 THEN
						x = 0
					ELSE
						IF x > width-1 THEN x = width-1
					END IF
					y = row + i
					IF y < 0 THEN
						y = 0
					ELSE
						IF y > height-1 THEN y = height-1
					END IF

					value = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
     			sum = sum + value
      	NEXT j
      NEXT i

'			c = sum/w
			c = sum
			
			SELECT CASE TRUE
				IF c < 0 THEN c = 0
				IF c > 255 THEN c = 255
			END SELECT

			UBYTEAT(doffsetAddr)   = c
			UBYTEAT(doffsetAddr+1) = c
			UBYTEAT(doffsetAddr+2) = c

			doffsetAddr = doffsetAddr + 3
		NEXT column
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT row

	RETURN ($$TRUE)
	
	DIM temp[]

END FUNCTION
'
' ##########################
' #####  XilDither8x8  #####
' ##########################
'
' Dither with 8x8 halftone screen. Output image is scaled 4x.
'
FUNCTION XilDither8x8 (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	STATIC h8[], initialize
	
	IFZ source[] THEN RETURN
  XilGetImageArrayInfo (@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)
	IF bpp <> 24 THEN RETURN
	
	XilGrayScale1 (@source[], @temp[])

' initialize halftone array
	IFZ intialize THEN 
		initialize = $$TRUE
		DIM h8[7, 7]
		data$ = "52,44,36,124,132,140,148,156,60,4,28,116,200,228,236,164,68,12,20,108,212,252,244,172,76,84,92,100,76,84,92,100,132,140,148,156,52,44,36,124,200,228,236,164,60,4,28,116,212,252,244,172,68,12,20,108,204,196,188,180,76,84,92,100"
		FOR i = 0 TO 7
			FOR j = 0 TO 7
				a$ = NextItem$ (data$, @index, @term, @done)
				h8[i, j] = XLONG(a$)
			NEXT j
		NEXT i
	END IF
	
' output image is scaled * 4
	destWidth = width * 4
	destHeight = height * 4
	
'calc size of dest[]
	destRowBytes = (destWidth * 3) + 3 AND -4

'calc size of file in bytes
	destBmpSize = (destRowBytes * destHeight) + dataOffset

	DIM dest[destBmpSize]
	
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i
	
'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = destBmpSize{8,0}
	dest[3] = destBmpSize{8,8}
	dest[4] = destBmpSize{8,16}
	dest[5] = destBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = destWidth{8,0}
	dest[19] = destWidth{8,8}
	dest[20] = destWidth{8,16}
	dest[21] = destWidth{8,24}

'set file height bytes 22-25
	dest[22] = destHeight{8,0}
	dest[23] = destHeight{8,8}
	dest[24] = destHeight{8,16}
	dest[25] = destHeight{8,24}
	
'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
 ' fill the 8 times expanded matrix 
	DIM inx8[width*8-1, height*8-1]
 
	FOR i = 0 TO width-1	
		FOR j = 0 TO height-1 
			value = UBYTEAT(soffsetAddr + ((i*3) + (rowLength*j)))
			FOR m = 0 TO 7
				FOR n = 0 TO 7 
					inx8[(i*8)+m, (j*8)+n] = value + h8[m, n]
				NEXT n
			NEXT m
		NEXT j
	NEXT i
	
	DIM freq[511]
	DIM inx4[width*4-1, height*4-1]

	' fill up the 4 times expanded matrix and also find frequencies of colors 
	upi = width*4-1
	upj = height*4-1
	FOR i = 0 TO upi 
		FOR j = 0 TO upj 
			tmp = ( inx8[i*2, j*2] + inx8[i*2, j*2 + 1] + inx8[i*2 + 1, j*2 + 1] + inx8[i*2 + 1, j*2] )/4.0
			inx4[i, j] = tmp
			INC freq[tmp]
		NEXT j
	NEXT i
	
	' find color occuring most no. of times
	maxfreqcolor = 0
	FOR i = 1 TO 511 
		IF ( freq[i] > freq[maxfreqcolor] ) THEN maxfreqcolor = i
	NEXT i
'	PRINT "maxfreqcolor="; maxfreqcolor

	' quantize
	FOR i = 0 TO upi  
		FOR j = 0 TO upj 
			IF inx4[i, j] < maxfreqcolor THEN
				inx4[i, j] = 0
			ELSE
				inx4[i, j] = 255
			END IF
		NEXT j
	NEXT i
	
	' write information to output array
	FOR j = 0 TO upj
		FOR i = 0 TO upi
			UBYTEAT(doffsetAddr)   = inx4[i, j]
			UBYTEAT(doffsetAddr+1) = inx4[i, j]
			UBYTEAT(doffsetAddr+2) = inx4[i, j]
			doffsetAddr = doffsetAddr + 3
		NEXT i
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT j
		
	RETURN ($$TRUE)
	
	DIM temp[]

END FUNCTION
'
' ##########################
' #####  XilDitherFS1  #####
' ##########################
'
' Floyd-Steinberg dithering algorithm.
'
FUNCTION  XilDitherFS (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	
	$RANGE  = 255
	$LEVELS = 2

	IFZ source[] THEN RETURN 0

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	IF bpp <> 24 THEN RETURN
	
'make buffer[] grayscale
	XilGrayScale1 (@source[], @temp[])
	XilGetImageArrayDetails (@temp[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

'DIM destimation array dest[]
	upper = UBOUND(temp[])
  DIM dest[upper]

'Copy temp[] to dest[]
	RtlMoveMemory (&dest[], &temp[], SIZE(temp[]))

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4
	
	DIM yslop[width-1]									' error diffusion array
	
	t = (($RANGE + 1) * 2) / $LEVELS		' threshold factor 
	q = $RANGE / ($LEVELS - 1)					' quantization factor 
	j = (9 * $RANGE) / 32
	
	FOR x = 0 TO width-1  
		yslop[x] = j
	NEXT x

	FOR y = 0 TO height-1
		
		xslop = (7 * $RANGE) / 32
		dslop = $RANGE / 32

		FOR x = 0 TO width-1
			
			i = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
			i = i + xslop + yslop[x]
			j = (i / t) * q
			IF (j > $RANGE) THEN	j = $RANGE
			
			UBYTEAT(doffsetAddr)   = j
			UBYTEAT(doffsetAddr+1) = j
			UBYTEAT(doffsetAddr+2) = j
			
			i = i - j
			k = (i >> 4)							' (i / 16)
			xslop = 7 * k
			yslop[x] = (5 * k) + dslop
			IF (x > 0) THEN yslop[x-1] = yslop[x-1] + (3 * k)
			dslop = i - (15 * k)	

			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT y

	DIM temp[]
	RETURN ($$TRUE)

END FUNCTION
'
' ###############################
' #####  XilDitherBayer8x8  #####
' ###############################
'
' Dither using Bayer 8x8 mask.
'
FUNCTION  XilDitherBayer8x8 (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	STATIC DOUBLE bayer_mask[]
	STATIC initialize
	
	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	IF bpp <> 24 THEN RETURN
	
' initialize bayer mask array
	IFZ intialize THEN 
		initialize = $$TRUE
		DIM bayer_mask[63]
		data$ = "0.0234,0.5234,0.1484,0.6484,0.0547,0.5547,0.1797,0.6797,0.9297,0.2734,0.7734,0.3984,0.8984,0.3047,0.8047,0.4297,0.2422,0.7422,0.0859,0.5859,0.2109,0.7109,0.1172,0.6172,0.8672,0.4922,0.9922,0.3359,0.8359,0.4609,0.9609,0.3672,0.0391,0.5391,0.1641,0.6641,0.0078,0.5078,0.1328,0.6328,0.8828,0.2891,0.7891,0.4141,0.9141,0.2578,0.7578,0.3828,0.1953,0.6953,0.1016,0.6016,0.2266,0.7266,0.0703,0.5703,0.8203,0.4453,0.9453,0.3516,0.8516,0.4766,0.9766,0.3203"
		FOR i = 0 TO 63
			a$ = NextItem$ (data$, @index, @term, @done)
			bayer_mask[i] = DOUBLE(a$)
		NEXT i
	END IF
	
'make buffer[] grayscale
	XilGrayScale1 (@source[], @temp[])
	XilGetImageArrayDetails (@temp[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)

'DIM destimation array dest[]
	upper = UBOUND(temp[])
  DIM dest[upper]

'Copy temp[] to dest[]
	RtlMoveMemory (&dest[], &temp[], SIZE(temp[]))

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4
	
	FOR y = 0 TO height-1
		FOR x = 0 TO width-1
			
			i = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
			IF i > bayer_mask[(y MOD 8)+(x MOD 8) * 8] * 255.0 THEN
				i = 255
			ELSE
				i = 0
			END IF
			
			UBYTEAT(doffsetAddr)   = i
			UBYTEAT(doffsetAddr+1) = i
			UBYTEAT(doffsetAddr+2) = i
			
			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4
	NEXT y

	DIM temp[]
	RETURN ($$TRUE)

END FUNCTION
'
' ###############################
' #####  XilDitherUlichney  #####
' ###############################
'
'	XilDitherUlichney calculates the error diffusion algorithm with perturbed filter 
' weights described by Ulichney.
'
FUNCTION  XilDitherUlichney (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	DOUBLE weight_matrix[8], fs_matrix[8]
	STATIC initialize
	DOUBLE input_image[], output_image[], error_image[]
	
	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	IF bpp <> 24 THEN RETURN
	
	weight_matrix[0] = 0.0
	weight_matrix[1] = 0.0
	weight_matrix[2] = 3.0/16.0 
	weight_matrix[3] = 0.0 
	weight_matrix[4] = 0.0 
	weight_matrix[5] = 5.0/16.0 
	weight_matrix[6] = 0.0 
	weight_matrix[7] = 7.0/16.0 
	weight_matrix[8] = 1.0/16.0
	
	fs_matrix[0] = 0.0 
	fs_matrix[1] = 0.0 
	fs_matrix[2] = 3.0/16.0 
	fs_matrix[3] = 0.0 
	fs_matrix[4] = 0.0 
	fs_matrix[5] = 5.0/16.0 
	fs_matrix[6] = 0.0 
	fs_matrix[7] = 7.0/16.0 
	fs_matrix[8] = 1.0/16.0
	
	srand (1.0)
	
'make buffer[] grayscale
	XilGrayScale1 (@source[], @temp[])
	XilGetImageArrayDetails (@temp[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)
	
'DIM destimation array dest[]
	upper = UBOUND(temp[])
  DIM dest[upper]

'Copy temp[] to dest[]
	RtlMoveMemory (&dest[], &temp[], SIZE(temp[]))

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4
	
	direction = -1
	Threshold = 0
	weight_row_radius = 1
	weight_col_radius = 1
	weight_row = 3
	weight_col = 3
	image_row = height
	image_col = width
	White_Value = 1.0
	
	DIM input_image[width * height]
	DIM error_image[width * height]
	DIM output_image[width * height]

' fill input_image[] array with indexed and scaled data	
	FOR m = 0 TO image_row-1
		FOR n = 0 TO image_col-1
			input_image[m+n*image_row] = UBYTEAT(soffsetAddr + ((n*3) + (rowLength*m)))/255.0 
		NEXT n
	NEXT m

' perform error diffusion algorithm with perturbed filter weights	
	FOR m = 0 TO image_row-1
		d = pow (DOUBLE(direction), DOUBLE(m))
		IF (d==1) THEN n = 0 ELSE n = image_col-1

		DO WHILE n >= 0 && n < image_col
			SetWeights (@weight_matrix[], @fs_matrix[])
			output_image[m+n*image_row] = input_image[m+n*image_row] + error_image[m+n*image_row]
			
			IF (output_image[m+n*image_row] >= Threshold) THEN
				output_image[m+n*image_row] = 1.0
			ELSE
				output_image[m+n*image_row] = 0.0
			END IF
			
			error_image[m+n*image_row] = error_image[m+n*image_row] + input_image[m+n*image_row] - output_image[m+n*image_row] * White_Value
			
			FOR r = 0 TO weight_row_radius 
				FOR t = -1 * weight_col_radius TO weight_col_radius 
					IF (r == 0 && t <= 0) THEN DO NEXT
					m_p = m + r
					IF (m_p < 0 || m_p >= image_row) THEN DO NEXT
					n_p = n + d*t
					IF (n_p < 0 || n_p >= image_col) THEN DO NEXT
					error_image[m_p+n_p*image_row] = error_image[m_p+n_p*image_row] + error_image[m+n*image_row] * weight_matrix[r+weight_row_radius+(t+weight_col_radius)*weight_row]
				NEXT t
			NEXT r
			n = n + d
		LOOP
	NEXT m

' fill destination array with results	
	FOR m = 0 TO image_row-1
		FOR n = 0 TO image_col-1
			i = output_image[m+n*image_row] * 255
			UBYTEAT(doffsetAddr)   = i
			UBYTEAT(doffsetAddr+1) = i
			UBYTEAT(doffsetAddr+2) = i
			doffsetAddr = doffsetAddr + 3			
		NEXT n
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4		
	NEXT m	
	
	DIM temp[]
	DIM error_image[]
	DIM input_image[]
	DIM output_image[]
	RETURN ($$TRUE)

END FUNCTION

FUNCTION SetWeights (DOUBLE new_weights[], DOUBLE old_weights[])

	DOUBLE frand

	frand = (DOUBLE(rand())/DOUBLE($$RAND_MAX)-0.5) * old_weights[2]
	new_weights[2] = old_weights[2] + frand
	new_weights[8] = old_weights[8] - frand
	frand = (DOUBLE(rand())/DOUBLE($$RAND_MAX)-0.5) * old_weights[5]
	new_weights[5] = old_weights[5] + frand
	new_weights[7] = old_weights[7] - frand
	
END FUNCTION
'
' ##################################
' #####  XilDitherEfficientED  #####
' ##################################
'
' A dithering algorithm as described in the article
'	"A Simple and Efficient Error-Diffusion Algorithm"
' by Victor Ostromoukhov
'
FUNCTION  XilDitherEfficientED (UBYTE source[], UBYTE dest[])

	UBYTE temp[]
	STATIC initialize
	DOUBLE threshold, corrected_level, diff
	DOUBLE x_scale_factor, y_scale_factor
	SHARED DOUBLE carry_line_0[]
	SHARED DOUBLE carry_line_1[]
	SHARED T_THREE_COEFS var_coefs_tab[]
	
	$BLACK = 0
	$WHITE = 255
	$TO_RIGHT = 1 
	$TO_LEFT = -1
	
	IFZ source[] THEN RETURN

  XilGetImageArrayInfo(@source[], @bpp, @width, @height)
	IF bpp <> 24 THEN RETURN
	
	IFZ initialize THEN GOSUB Initialize
	
'make buffer[] grayscale
	XilGrayScale1 (@source[], @temp[])
	XilGetImageArrayDetails (@temp[], 0, @fileSize, @dataOffset, 0, 0, 0, 0, 0)
	
'DIM destimation array dest[]
	upper = UBOUND(temp[])
  DIM dest[upper]

'Copy temp[] to dest[]
	RtlMoveMemory (&dest[], &temp[], SIZE(temp[]))

'calc address of first element in temp[]
	saddress = &temp[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4
	
	threshold = 127.5
	
	DIM data[height-1, width-1]
	DIM dataout[height-1, width-1]
	
	FOR y = 0 TO height-1
		FOR x = 0 TO width-1
			data[y, x] = UBYTEAT(soffsetAddr + ((x*3) + (rowLength*y)))
		NEXT x
	NEXT y
	
	DIM carry_line_0[width+1]
	DIM carry_line_1[width+1]
	
  FOR y = 0 TO height-1   
    IF (((y) & 1) == 0) THEN 	' odd lines 
      dir = $TO_RIGHT
      xstart = 0
			xstop = width-1
			xstep = 1
    ELSE  										' even lines 
      dir = $TO_LEFT
      xstart = width-1
			xstop = 0
			xstep = -1
    END IF

    FOR x = xstart TO xstop STEP xstep
			input = data[y, x]
      corrected_level = input + carry_line_0[x+1]  ' offset x by 1 to prevent underflow in carry_line_x[] arrays
      IF (corrected_level <= threshold) THEN 
				intensity = $BLACK    		' put black 
      ELSE
				intensity = $WHITE				' put white 
			END IF
			diff = corrected_level - intensity
			DistributeError (x+1, y, diff, dir, input)

      IF (input == $BLACK || intensity == $BLACK) THEN
				dataout[y, x] = $BLACK
      ELSE
				dataout[y, x] = $WHITE
			END IF
		NEXT x
    ShiftCarryBuffers ()
  NEXT y

	
' fill destination array with results	
	FOR y = 0 TO height-1
		FOR x = 0 TO width-1
			i = dataout[y, x]
			UBYTEAT(doffsetAddr)   = i
			UBYTEAT(doffsetAddr+1) = i
			UBYTEAT(doffsetAddr+2) = i
			doffsetAddr = doffsetAddr + 3			
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4		
	NEXT y	
	
	DIM temp[]
	DIM data[]
	DIM dataout[]
	RETURN ($$TRUE)
	
SUB Initialize
	initialize = $$TRUE
	DIM var_coefs_tab[255]
	data$ = data$ + "13,0,5,18,13,0,5,18,21,0,10,31,7,0,4,11,8,0,5,13,47,3,28,78,23,3,13,39,15,3,8,26,22,6,11,39,43,15,20,78,7,3,3,13,501,224,211,936,249,116,103,468,165,80,67,312,123,62,49,234,489,256,191,936,81,44,31,156,483,272,181,936,60,35,22,117,53,32,19,104,"
	data$ = data$ + "237,148,83,468,471,304,161,936,3,2,1,6,459,304,161,924,38,25,14,77,453,296,175,924,225,146,91,462,149,96,63,308,111,71,49,231,63,40,29,132,73,46,35,154,435,272,217,924,108,67,56,231,13,8,7,28,213,130,119,462,423,256,245,924,5,3,3,11,281,173,162,616,"
	data$ = data$ + "141,89,78,308,283,183,150,616,71,47,36,154,285,193,138,616,13,9,6,28,41,29,18,88,36,26,15,77,289,213,114,616,145,109,54,308,291,223,102,616,73,57,24,154,293,233,90,616,21,17,6,44,295,243,78,616,37,31,9,77,27,23,6,56,149,129,30,308,299,263,54,616,"
	data$ = data$ + "75,67,12,154,43,39,6,88,151,139,18,308,303,283,30,616,38,36,3,77,305,293,18,616,153,149,6,308,307,303,6,616,1,1,0,2,101,105,2,208,49,53,2,104,95,107,6,208,23,27,2,52,89,109,10,208,43,55,6,104,83,111,14,208,5,7,1,13,172,181,37,390,97,76,22,195,"
	data$ = data$ + "72,41,17,130,119,47,29,195,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,65,18,17,100,95,29,26,150,185,62,53,300,30,11,9,50,35,14,11,60,85,37,28,150,55,26,19,100,80,41,29,150,155,86,59,300,5,3,2,10,5,3,2,10,5,3,2,10,"
	data$ = data$ + "5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,305,176,119,600,155,86,59,300,105,56,39,200,80,41,29,150,65,32,23,120,55,26,19,100,335,152,113,600,85,37,28,150,115,48,37,200,35,14,11,60,355,136,109,600,"
	data$ = data$ + "30,11,9,50,365,128,107,600,185,62,53,300,25,8,7,40,95,29,26,150,385,112,103,600,65,18,17,100,395,104,101,600,4,1,1,6,4,1,1,6,395,104,101,600,65,18,17,100,385,112,103,600,95,29,26,150,25,8,7,40,185,62,53,300,365,128,107,600,30,11,9,50,355,136,109,600,"
	data$ = data$ + "35,14,11,60,115,48,37,200,85,37,28,150,335,152,113,600,55,26,19,100,65,32,23,120,80,41,29,150,105,56,39,200,155,86,59,300,305,176,119,600,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,5,3,2,10,"
	data$ = data$ + "5,3,2,10,155,86,59,300,80,41,29,150,55,26,19,100,85,37,28,150,35,14,11,60,30,11,9,50,185,62,53,300,95,29,26,150,65,18,17,100,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,4,1,1,6,119,47,29,195,72,41,17,130,97,76,22,195,172,181,37,390,"
	data$ = data$ + "5,7,1,13,83,111,14,208,43,55,6,104,89,109,10,208,23,27,2,52,95,107,6,208,49,53,2,104,101,105,2,208,1,1,0,2,307,303,6,616,153,149,6,308,305,293,18,616,38,36,3,77,303,283,30,616,151,139,18,308,43,39,6,88,75,67,12,154,299,263,54,616,149,129,30,308,"
	data$ = data$ + "27,23,6,56,37,31,9,77,295,243,78,616,21,17,6,44,293,233,90,616,73,57,24,154,291,223,102,616,145,109,54,308,289,213,114,616,36,26,15,77,41,29,18,88,13,9,6,28,285,193,138,616,71,47,36,154,283,183,150,616,141,89,78,308,281,173,162,616,5,3,3,11,"
	data$ = data$ + "423,256,245,924,213,130,119,462,13,8,7,28,108,67,56,231,435,272,217,924,73,46,35,154,63,40,29,132,111,71,49,231,149,96,63,308,225,146,91,462,453,296,175,924,38,25,14,77,459,304,161,924,3,2,1,6,471,304,161,936,237,148,83,468,53,32,19,104,60,35,22,117,"
	data$ = data$ + "483,272,181,936,81,44,31,156,489,256,191,936,123,62,49,234,165,80,67,312,249,116,103,468,501,224,211,936,7,3,3,13,43,15,20,78,22,6,11,39,15,3,8,26,23,3,13,39,47,3,28,78,8,0,5,13,7,0,4,11,21,0,10,31,13,0,5,18,13,0,5,18"
	
	FOR i = 0 TO 255
			a$ = NextItem$ (data$, @index, @term, @done)
			var_coefs_tab[i].i_r = DOUBLE(a$)			
			a$ = NextItem$ (data$, @index, @term, @done)
			var_coefs_tab[i].i_dl = DOUBLE(a$)	
			a$ = NextItem$ (data$, @index, @term, @done)
			var_coefs_tab[i].i_d = DOUBLE(a$)	
			a$ = NextItem$ (data$, @index, @term, @done)
			var_coefs_tab[i].i_sum = DOUBLE(a$)	
	NEXT i
END SUB

END FUNCTION
'
' #############################
' #####  DistributeError  #####
' #############################
'
'
'
FUNCTION DistributeError (x, y, DOUBLE diff, dir, input_level)

	DOUBLE term_r, term_dl, term_d
	SHARED DOUBLE carry_line_0[]
	SHARED DOUBLE carry_line_1[]
	SHARED T_THREE_COEFS var_coefs_tab[]
	T_THREE_COEFS coefs

  coefs = var_coefs_tab[input_level]

  term_r = coefs.i_r*diff/coefs.i_sum
  term_dl = coefs.i_dl*diff/coefs.i_sum
  term_d = diff - (term_r+term_dl)
	
	carry_line_0[x+dir] = carry_line_0[x+dir] + term_r
	carry_line_1[x-dir] = carry_line_1[x-dir] + term_dl
	carry_line_1[x]     = carry_line_1[x]     + term_d

END FUNCTION
'
' ###############################
' #####  ShiftCarryBuffers  #####
' ###############################
'
'
'
FUNCTION ShiftCarryBuffers ()

	SHARED DOUBLE carry_line_0[]
	SHARED DOUBLE carry_line_1[]
	
	upp = UBOUND(carry_line_1[])
	SWAP carry_line_0[], carry_line_1[]
	DIM carry_line_1[upp]

END FUNCTION
'
' ###############################
' #####  XilSmoothKuwahara  #####
' ###############################
'
' Performs the Kuwahara Filter. This filter is an edge-preserving 
' smoothing filter.
' ( a  a  ab   b  b)
' ( a  a  ab   b  b)
' (ac ac abcd bd bd)
' ( c  c  cd   d  d)
' ( c  c  cd   d  d)
'
' In each of the four regions (a, b, c, d), the mean brightness
' and the variance are calculated. The output value of the center
' pixel (abcd) in the window is the mean value of that region that
' has the smallest variance. The size of each region window is
' radius*2+1.
'
FUNCTION XilSmoothKuwahara (UBYTE source[], UBYTE dest[], radius)

	DOUBLE mB1, vB1, mG1, vG1, mR1, vR1
	DOUBLE mB2, vB2, mG2, vG2, mR2, vR2
	DOUBLE mB3, vB3, mG3, vG3, mR3, vR3
	DOUBLE mB4, vB4, mG4, vG4, mR4, vR4	
	DOUBLE mB, mG, mR, vB, vG, vR
	
	IFZ source[] THEN RETURN
  XilGetImageArrayInfo (@source[], @bpp, @width, @height)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)
	IF bpp <> 24 THEN RETURN
	
	IF radius <= 0 THEN radius = 1
	
	upper = UBOUND(source[])
	DIM dest[upper]
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
	DIM dataR[height-1, width-1]
	DIM dataB[height-1, width-1]
	DIM dataG[height-1, width-1]	
	
	FOR y = 0 TO height-1
		FOR x = 0 TO width-1
			addr = soffsetAddr + ((x*3) + (rowLength*y))
			dataB[y, x] = UBYTEAT(addr)
			dataG[y, x] = UBYTEAT(addr+1)
			dataR[y, x] = UBYTEAT(addr+2)
		NEXT x
	NEXT y
	
	r = radius

	FOR y = 0 TO height-1
		FOR x = 0 TO width-1
			
			vB = 65025 : vG = 65025 : vR = 65025
			mB = 0   : mG = 0   : mR = 0
			
			' get mean and variance for each of four quadrant regions
			' at centroid positions:
			' first  is y-r, x-r
			' second is y-r, x+r
			' third  is y+r, x+r
			' fourth is y+r, x-r
			FOR i = 1 TO 4
				SELECT CASE i
					CASE 1 : 
						m = y-r : n = x-r 
						IF m < 0 || n < 0 || m > height-1 || n > width-1 THEN EXIT SELECT
						GetMeanAndVariance (@dataB[], m, n, r, @mB1, @vB1)
						GetMeanAndVariance (@dataG[], m, n, r, @mG1, @vG1)
						GetMeanAndVariance (@dataR[], m, n, r, @mR1, @vR1)
						IF vB1 < vB THEN vB = vB1 : mB = mB1 
						IF vG1 < vG THEN vG = vG1 : mG = mG1
						IF vR1 < vR THEN vR = vR1 : mR = mR1
					CASE 2 :
						m = y-r : n = x+r
						IF m < 0 || n < 0 || m > height-1 || n > width-1 THEN EXIT SELECT
						GetMeanAndVariance (@dataB[], m, n, r, @mB2, @vB2)
						GetMeanAndVariance (@dataG[], m, n, r, @mG2, @vG2)
						GetMeanAndVariance (@dataR[], m, n, r, @mR2, @vR2)
						IF vB2 < vB THEN vB = vB2 : mB = mB2 
						IF vG2 < vG THEN vG = vG2 : mG = mG2
						IF vR2 < vR THEN vR = vR2 : mR = mR2
					CASE 3 :
						m = y+r : n = x+r
						IF m < 0 || n < 0 || m > height-1 || n > width-1 THEN EXIT SELECT	
						GetMeanAndVariance (@dataB[], m, n, r, @mB3, @vB3)
						GetMeanAndVariance (@dataG[], m, n, r, @mG3, @vG3)
						GetMeanAndVariance (@dataR[], m, n, r, @mR3, @vR3)
						IF vB3 < vB THEN vB = vB3 : mB = mB3 
						IF vG3 < vG THEN vG = vG3 : mG = mG3
						IF vR3 < vR THEN vR = vR3 : mR = mR3
					CASE 4 :
						m = y+r : n = x-r
						IF m < 0 || n < 0 || m > height-1 || n > width-1 THEN EXIT SELECT
						GetMeanAndVariance (@dataB[], m, n, r, @mB4, @vB4)
						GetMeanAndVariance (@dataG[], m, n, r, @mG4, @vG4)
						GetMeanAndVariance (@dataR[], m, n, r, @mR4, @vR4)
						IF vB4 < vB THEN mB = mB4 
						IF vG4 < vG THEN mG = mG4
						IF vR4 < vR THEN mR = mR4
				END SELECT
			NEXT i
	
			UBYTEAT(doffsetAddr)   = UBYTE(mB)
			UBYTEAT(doffsetAddr+1) = UBYTE(mG)
			UBYTEAT(doffsetAddr+2) = UBYTE(mR)

			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4			
			
	NEXT y

	RETURN ($$TRUE)
END FUNCTION
'
' ################################
' #####  GetMeanAndVariance  #####
' ################################
'
' Calculate mean and variance of square region defined
' with center at x,y and radius of r. Size of region
' is r*2+1.
'
FUNCTION GetMeanAndVariance (data[], y, x, r, DOUBLE mean, DOUBLE variance)

	DOUBLE pt

	IF r <= 0 THEN r = 1
	IFZ data[] THEN RETURN
	
	mean = 0
	variance = 0
	
	upH = UBOUND(data[])
	upW = UBOUND(data[0,]) 

	FOR i = y-r TO y+r
		FOR j = x-r TO x+r
			IF j < 0 || i < 0 || i > upH || j > upW THEN DO NEXT
			INC n
			sum = sum + data[i, j]
		NEXT j
	NEXT i

	IFZ n THEN RETURN
	
	mean = sum/DOUBLE(n)

	FOR i = y-r TO y+r
		FOR j = x-r TO x+r
			IF j < 0 || i < 0 || i > upH || j > upW THEN DO NEXT
			pt = data[i,j]
			variance = variance + ((pt-mean)*(pt-mean))
		NEXT j
	NEXT i
	
	variance = variance/DOUBLE(n)

END FUNCTION
'
' ##########################
' #####  XilThumbnail  #####
' ##########################
'
' Reduce scale of image by ratio.
' 0 < ratio < 1.
'
FUNCTION XilThumbnail (UBYTE source[], UBYTE dest[], DOUBLE ratio)

	DOUBLE u0, v0, u1, v1

	IFZ source[] THEN RETURN
  XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)
	IF bpp <> 24 THEN RETURN
	
	IF ratio <= 0 THEN RETURN
	IF ratio >= 1 THEN RETURN
	
	dWidth = sWidth * ratio
	dHeight = sHeight * ratio

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc size of dest[]
	dRowBytes = (dWidth * 3) + 3 AND -4

'calc size of file in bytes
	dBmpSize = (dRowBytes * dHeight) + dataOffset

	DIM dest[dBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = dBmpSize{8,0}
	dest[3] = dBmpSize{8,8}
	dest[4] = dBmpSize{8,16}
	dest[5] = dBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = dWidth{8,0}
	dest[19] = dWidth{8,8}
	dest[20] = dWidth{8,16}
	dest[21] = dWidth{8,24}

'set file height bytes 22-25
	dest[22] = dHeight{8,0}
	dest[23] = dHeight{8,8}
	dest[24] = dHeight{8,16}
	dest[25] = dHeight{8,24}

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
	DIM dataR[sHeight-1, sWidth-1]
	DIM dataB[sHeight-1, sWidth-1]
	DIM dataG[sHeight-1, sWidth-1]	
	
	FOR y = 0 TO sHeight-1
		FOR x = 0 TO sWidth-1
			addr = soffsetAddr + ((x*3) + (sRowBytes*y))
			dataB[y, x] = UBYTEAT(addr)
			dataG[y, x] = UBYTEAT(addr+1)
			dataR[y, x] = UBYTEAT(addr+2)
		NEXT x
	NEXT y
	
	FOR y = 0 TO dHeight-1
		FOR x = 0 TO dWidth-1
		  u0 = x * (1.0/ratio)
      v0 = y * (1.0/ratio)
      u1 = (x+1) * (1.0/ratio)
      v1 = (y+1) * (1.0/ratio)
			
			r = GetBox (@dataR[], u0, v0, u1, v1)
			g = GetBox (@dataG[], u0, v0, u1, v1)
			b = GetBox (@dataB[], u0, v0, u1, v1)
	
			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4			
			
	NEXT y

	RETURN ($$TRUE)
END FUNCTION
'
' ####################
' #####  GetBox  #####
' ####################
'
' Box filter for XilThumbnail.
'
FUNCTION GetBox (data[], DOUBLE x0, DOUBLE y0, DOUBLE x1, DOUBLE y1)

  DOUBLE area				' total area accumulated in pixels 
  DOUBLE sum 
  DOUBLE xsize, ysize
	
	uppY = UBOUND(data[])
	uppX = UBOUND(data[0,])
	
	y0f = floor (y0)
	y1c = ceil (y1)
	IF y1c > uppY THEN y1c = uppY ': PRINT "Y overflow"
	x0f = floor (x0)
	x1c = ceil (x1)
	IF x1c > uppX THEN x1c = uppX ': PRINT "X overflow"

  FOR y = y0f TO y1c
    ysize = 1.0
    IF y < y0 THEN 
      size = size * (1.0-(y0-y))
    END IF
    IF y > y1 THEN
      size = size * (1.0-(y-y1))
    END IF
    FOR x = x0f TO x1c 
      size = ysize
      value = data[y,x]
      IF x < x0 THEN
        size = size * (1.0-(x0-x))
      END IF
      IF x>x1 THEN
        size = size * (1.0-(x-x1))
      END IF
      sum = sum + value * size
      area = area + size
    NEXT x
  NEXT y
  
  RETURN (sum/area)

END FUNCTION
'
' ##############################
' #####  XilResizeBiCubic  #####
' ##############################
'
' Scale image by factor of ratio (ratio > 1).
'
FUNCTION XilResizeBiCubic (UBYTE source[], UBYTE dest[], DOUBLE ratio)

	DOUBLE u, v

	IFZ source[] THEN RETURN
  XilGetImageArrayInfo (@source[], @bpp, @sWidth, @sHeight)
	XilGetImageArrayDetails (@source[], 0, @fileSize, @dataOffset,0, 0, 0, 0, 0)
	IF bpp <> 24 THEN RETURN
	
	IF ratio <= 0 THEN RETURN
	
	dWidth = sWidth * ratio
	dHeight = sHeight * ratio

'Get source bytes per row
	sRowBytes = (sWidth * 3) + 3 AND -4

'calc size of dest[]
	dRowBytes = (dWidth * 3) + 3 AND -4

'calc size of file in bytes
	dBmpSize = (dRowBytes * dHeight) + dataOffset

	DIM dest[dBmpSize]

'Copy source header info into dest header
	FOR i = 0 TO dataOffset-1
		dest[i] = source[i]
	NEXT i

'change values in dest[] header for filesize, width, and height
'set filesize bytes 2-5
	dest[2] = dBmpSize{8,0}
	dest[3] = dBmpSize{8,8}
	dest[4] = dBmpSize{8,16}
	dest[5] = dBmpSize{8,24}

'set file width bytes 18-21
	dest[18] = dWidth{8,0}
	dest[19] = dWidth{8,8}
	dest[20] = dWidth{8,16}
	dest[21] = dWidth{8,24}

'set file height bytes 22-25
	dest[22] = dHeight{8,0}
	dest[23] = dHeight{8,8}
	dest[24] = dHeight{8,16}
	dest[25] = dHeight{8,24}

'Note: A scanline must be zero-padded to end on a 32-bit boundary
'calc bytes per row
	rowLength = (width * 3) + 3 AND -4

'calc address of first element in source[]
	saddress = &source[0]
	soffsetAddr = saddress + dataOffset

'calc address of first element in dest[]
	daddress = &dest[0]
	doffsetAddr = daddress + dataOffset
	
	DIM dataR[sHeight-1, sWidth-1]
	DIM dataB[sHeight-1, sWidth-1]
	DIM dataG[sHeight-1, sWidth-1]	
	
	FOR y = 0 TO sHeight-1
		FOR x = 0 TO sWidth-1
			addr = soffsetAddr + ((x*3) + (sRowBytes*y))
			dataB[y, x] = UBYTEAT(addr)
			dataG[y, x] = UBYTEAT(addr+1)
			dataR[y, x] = UBYTEAT(addr+2)
		NEXT x
	NEXT y
	
	FOR y = 0 TO dHeight-1
		FOR x = 0 TO dWidth-1
			u = x * (1.0/ratio)
      v = y * (1.0/ratio)
			
			r = GetBicubic (@dataR[], u, v)
			g = GetBicubic (@dataG[], u, v)
			b = GetBicubic (@dataB[], u, v)
			
			SELECT CASE ALL TRUE
				CASE (r < 0)   : r = 0
				CASE (r > 255) : r = 255
				CASE (g < 0)   : g = 0
				CASE (g > 255) : g = 255
				CASE (b < 0)   : b = 0
				CASE (b > 255) : b = 255									
			END SELECT
	
			UBYTEAT(doffsetAddr)   = b
			UBYTEAT(doffsetAddr+1) = g
			UBYTEAT(doffsetAddr+2) = r

			doffsetAddr = doffsetAddr + 3
		NEXT x
		align = (doffsetAddr - 54){2,0}													' ok if align = 0
		IF align THEN doffsetAddr = doffsetAddr + (4 - align)		' align 4			
			
	NEXT y

	RETURN ($$TRUE)
END FUNCTION
'
' ########################
' #####  GetBicubic  #####
' ########################
'
'
'
FUNCTION GetBicubic (data[], DOUBLE x, DOUBLE y)

	DOUBLE dx, dy
	
  xi = INT(x)
  yi = INT(y)
  dx = x-xi
  dy = y-yi
	
	xi1 = xi - 1
	IF xi1 < 0 THEN xi1 = 0

  v0 = GetCubicRow (@data[], xi1, yi-1, dx)
  v1 = GetCubicRow (@data[], xi1, yi,   dx)
  v2 = GetCubicRow (@data[], xi1, yi+1, dx)
  v3 = GetCubicRow (@data[], xi1, yi+2, dx)

  RETURN Cubic (dy, v0, v1, v2, v3)

END FUNCTION
'
' #########################
' #####  GetCubicRow  #####
' #########################
'
'
'
FUNCTION GetCubicRow (data[], x, y, DOUBLE offset)

	uppY = UBOUND(data[])
	uppX = UBOUND(data[0,])
	
	IF y > uppY THEN y = uppY
	IF y < 0 THEN y = 0

  v0 = data[y, x]
	x1 = x+1
	IF x1 > uppX THEN x1 = uppX
  v1 = data[y, x1]
	x2 = x+2
	IF x2 > uppX THEN x2 = uppX
  v2 = data[y, x2]
	x3 = x+3
	IF x3 > uppX THEN x3 = uppX
  v3 = data[y, x3]
	
  RETURN Cubic (offset, v0, v1, v2, v3)
END FUNCTION
'
' ###################
' #####  Cubic  #####
' ###################
'
'
'
FUNCTION Cubic (DOUBLE offset, v0, v1, v2, v3)

' offset is the offset of the sampled value between v1 and v2
  RETURN  (((( -7 * v0 + 21 * v1 - 21 * v2 + 7 * v3 ) * offset + ( 15 * v0 - 36 * v1 + 27 * v2 - 6 * v3 ) ) * offset + ( -9 * v0 + 9 * v2 ) ) * offset + (v0 + 16 * v1 + v2) ) / 18.0
END FUNCTION


END PROGRAM
