'
' #################### David Szafranski
' #####  PROLOG  ##### copyright 2002
' #################### XBLite printer library
'
' Xpr is a printer library for XBLite for Windows.
'
PROGRAM	"xpr"
VERSION	"1.03"
CONSOLE
'
' This group of functions aids XBLite programmers in printing text as lines,
' paragraphs or pages. It can also be used to print BMP images,
' any window or any portion of the screen. Also included are various
' graphic printing functions for printing lines, boxes, circles, ellipses
' or pies. Boxes, circles, ellipses, and pies can be filled using a solid or
' hatch style.

' The library can be compiled as a dll or the various functions can be
' pasted directly into your program.
'
' It currently only works under Win9x platforms. There may be some problems
' with some of the graphic printing functions under WinNT.
'
' It is necessary to call XprStartDocument() before using certain graphics
' and text printing Xpr functions. These functions then also require that
' the last function to be called must be XprEndDocument().

' Please review/run the test functions to see how various files, text, and
' graphics can be printed. The test functions are all commented out in the
' main Entry() function. Just uncomment the functions that you wish to see
' a test example printed.

' See each function for details on their operation.  In order to use these
' functions, make sure to import kernel32, gdi32, and user32.  It will be
' necessary to have the most current versions of the corresponding .dec files.
'
' Also, if you choose to copy and use any of these functions into your program,
' then remember to add the constants shown below to your PROLOG.
'
' Note: I have arbitrarily chosen coordinate 0, 0 to be the upper-left
' corner of the paper (not the upperleft corner of the printable area)
' so that it is as much like a grid as possible.  Of course most printers
' cannot print right next to the edge of the paper so there is a offset
' on all edges of the paper which varies from printer to printer.
' XprGetPrintingOffset() helps determine this boundary.
'
' Xpr library (c) GPL David SZAFRANSKI
' February 2001
'
' Current issues:
'  * Tab characters not supported.  Tab characters are replaced by spaces.
'
IMPORT	"xst"
IMPORT	"xio"			' not needed if compiled as a DLL
IMPORT  "xsx"
IMPORT  "gdi32"
IMPORT  "user32"
IMPORT  "kernel32"
IMPORT  "shell32"
IMPORT  "msvcrt"
IMPORT  "winspool"
'
EXPORT
'
' ###############################
' #####  declare functions  #####
' ###############################
'
DECLARE FUNCTION  Xpr ()
'
'StartDocument/EndDocument/NewPage Functions
'
DECLARE FUNCTION  XprEndDocument ()
DECLARE FUNCTION  XprNewPage ()
DECLARE FUNCTION  XprStartDocument (prtName$, jobName$)
'
'Text line/paragraph/file printing functions
'
DECLARE FUNCTION  XprTextArray (@text$[], textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
DECLARE FUNCTION  XprTextFile (fileName$, textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
DECLARE FUNCTION  XprTextLine (text$, textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
DECLARE FUNCTION  XprTextParagraph (text$, textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
'
'bmp/grid printing functions
'
DECLARE FUNCTION  XprPrintBmpFile (fileName$, style, pxPos, DOUBLE pyPos, scaleFactor)
DECLARE FUNCTION  XprPrintScreen (x1Disp, y1Disp, x2Disp, y2Disp, style, pxPos, DOUBLE pyPos, scaleFactor)
DECLARE FUNCTION  XprPrintWindow (window, style, pxPos, DOUBLE pyPos, scaleFactor)
'
'drawing graphics functions
'
DECLARE FUNCTION  XprDrawBox (color, x1, y1, x2, y2, lineStyle, lineWidth)
DECLARE FUNCTION  XprDrawCircle (color, r, x, y, lineStyle, lineWidth)
DECLARE FUNCTION  XprDrawEllipse (color, x1, y1, x2, y2, lineStyle, lineWidth)
DECLARE FUNCTION  XprDrawLine (color, x1, y1, x2, y2, lineStyle, lineWidth)
DECLARE FUNCTION  XprDrawPie (color, r, x, y, angleStart#, angleEnd#, lineStyle, lineWidth)
DECLARE FUNCTION  XprDrawText (text$, textFlags, xpos, @ypos, fontName$, fontHeight)
'
'misc print/printer settings and conversion functions
'
DECLARE FUNCTION  XprGetDefaultPrinter (@defPrinter$, @driver$, @port$)
DECLARE FUNCTION  XprGetLinesPerPage (fontHeight, @lpp)
DECLARE FUNCTION  XprGetPrintingOffset (prtName$, @right, @left, @top, @bottom)
DECLARE FUNCTION  XprGetPrinterYpos (DOUBLE pyPos)
DECLARE FUNCTION  XprGetTabValue (@tabV)
DECLARE FUNCTION  XprSetFillStyle (fillStyle, color)
DECLARE FUNCTION  XprSetTabValue (tabV)
DECLARE FUNCTION  XprSetTextColors (textColor, backColor)
'
'simple text string LPRINT to LPT1
'
DECLARE FUNCTION  XprLPrint (text$)
DECLARE FUNCTION  XprRawTextToPrinter (printerName$, @text$)
'
'shell file printing functions
'
DECLARE FUNCTION  XprPrintFileToLPT1 (fileName$, linesPerPage, escSequence$)
DECLARE FUNCTION  XprPrintFileToMsHtml (fileName$)
DECLARE FUNCTION  XprPrintFileToNetscape (fileName$)
DECLARE FUNCTION  XprPrintFileToNotePad (fileName$)
DECLARE FUNCTION  XprPrintFileToShellExecute (fileName$)
DECLARE FUNCTION  XprPrintFileToWordPad (fileName$)
'
END EXPORT
'
'test functions
'
INTERNAL FUNCTION  XprTestLPrint ()
INTERNAL FUNCTION  XprTestTextFunctions ()
INTERNAL FUNCTION  XprTestGraphicsFunctions ()
INTERNAL FUNCTION  XprTestImageFunctions ()
INTERNAL FUNCTION  XprTestRawTextToPrinter ()
'
'misc text parsing functions
'
INTERNAL FUNCTION  ReplaceAllArray (mode, @myTextArray$[], find$, replace$)
INTERNAL FUNCTION  ParseTextStringToStringArray (text$, @text$[])
'
EXPORT
'
' #########################
' ##### Xpr constants #####
' #########################
'
' text weight
'
$$TEXT_DEFAULT       = 0x0000
$$TEXT_THIN          = 0x0001
$$TEXT_EXTRALIGHT    = 0x0002
$$TEXT_LIGHT         = 0x0004
$$TEXT_NORMAL        = 0x0008
$$TEXT_MEDIUM        = 0x0010
$$TEXT_SEMIBOLD      = 0x0020
$$TEXT_BOLD          = 0x0040
$$TEXT_EXTRABOLD     = 0x0080
$$TEXT_HEAVY         = 0x0100
'
' text styles
'
$$TEXT_ITALIC        = 0x0200
$$TEXT_UNDERLINED    = 0x0400
'
' text mode
'
$$TEXT_WORDWRAPOFF   = 0x0800
$$TEXT_WORDWRAPON    = 0x1000

' text justify
'
$$TEXT_JUSTIFYCENTER	=0x2000
$$TEXT_JUSTIFYRIGHT		=0x4000
'
' XprPrintBmpFile() flags
'
$$BMP_TOPLEFT            = 1
$$BMP_MIDDLECENTER       = 2
$$BMP_MANUALPOSITION     = 4
$$BMP_SCALEFACTORON      = 8
'
' Fill styles
$$FillStyleNone  = 0x0
$$FillStyleSolid = 0x10
$$FillStyleHatch = 0x20

' Line styles
$$LineStyleSolid      = 0
$$LineStyleDash       = 1
$$LineStyleDot        = 2
$$LineStyleDashDot    = 3
$$LineStyleDashDotDot = 4

' EPSON Printer mode control ESC sequences
' Can be used when sending raw text to printer
$$RN = "\r\n"
$$NEWLINE = "\n"
$$FF = "\f"
$$10CPI = "\e\x50"
$$12CPI = "\e\x4d"
$$BOLD_ON  = "\e\x45"
$$BOLD_OFF = "\e\x46"
$$ITALIC_ON = "\e\x34"
$$ITALIC_OFF = "\e\x35"
$$UNDERLINE_ON = "\e\x2d\x31"
$$UNDERLINE_OFF = "\e\x2d\x30"
$$PROPORTIONAL_ON = "\e\x70\x31"
$$PROPORTIONAL_OFF = "\e\x70\x30"
$$WIDE_ON = "\e\x57\x31"
$$WIDE_OFF = "\e\x57\x30"
$$CONDENSED_ON = "\x0f"
$$CONDENSED_OFF = "\x12"

$$FONT_ROMAN = "\e\x6b\x00"
$$FONT_SANSERIF = "\e\x6b\x01"
$$FONT_COURIER = "\e\x6b\x02"
$$FONT_PRESTIGE = "\e\x6b\x03"
$$FONT_SCRIPT = "\e\x6b\x04"

$$SELECT_PICA = "\e\x21\x00"
$$SELECT_ELITE = "\e\x21\x01"
$$SELECT_PROPORTIONAL = "\e\x21\x02"
$$SELECT_CONDENSED = "\e\x21\x04"
$$SELECT_EMPHASIZED = "\e\x21\x08"
$$SELECT_DOUBLESTRIKE = "\e\x21\x10"
$$SELECT_DOUBLEWIDE = "\e\x21\x20"
$$SELECT_ITALIC = "\e\x21\x40"
$$SELECT_UNDERLINE = "\e\x21\x80"

$$STYLE_NORMAL = "\e\x71\x00"
$$STYLE_OUTLINE = "\e\x71\x01"
$$STYLE_SHADOW = "\e\x71\x02"
$$STYLE_OUTLINE_SHADOW = "\e\x71\x03"

$$RESET = "\e\x40"

' XBLite uses just Win32 color values
' and ignores XB color numbers
' These constants are now included in 
' user32.dec
' ColorConstant           Hexadecimal
'
'                           BBGGRR
'  $$Black               = 0x000000
'  $$DarkBlue            = 0x3F0000
'  $$MediumBlue          = 0x7F0000
'  $$Blue                = 0x7F0000
'  $$BrightBlue          = 0xBF0000
'  $$LightBlue           = 0xFF0000
'  $$DarkGreen           = 0x003F00
'  $$MediumGreen         = 0x007F00
'  $$Green               = 0x007F00
'  $$BrightGreen         = 0x00BF00
'  $$LightGreen          = 0x00FF00
'  $$DarkCyan            = 0x3F3F00
'  $$MediumCyan          = 0x7F7F00
'  $$Cyan                = 0x7F7F00
'  $$BrightCyan          = 0xBFBF00
'  $$LightCyan           = 0xFFFF00
'  $$DarkRed             = 0x00003F
'  $$MediumRed           = 0x00007F
'  $$Red                 = 0x00007F
'  $$BrightRed           = 0x0000BF
'  $$LightRed            = 0x0000FF
'  $$DarkMagenta         = 0x3F003F
'  $$MediumMagenta       = 0x7F007F
'  $$Magenta             = 0x7F007F
'  $$BrightMagenta       = 0xBF00BF
'  $$LightMagenta        = 0xFF00FF
'  $$DarkBrown           = 0x003F3F
'  $$MediumBrown         = 0x007F7F
'  $$Brown               = 0x007F7F
'  $$Yellow              = 0x00BFBF
'  $$BrightYellow        = 0x00FFFF
'  $$LightYellow         = 0x00FFFF
'  $$DarkGrey            = 0x3F3F3F
'  $$MediumGrey          = 0x7F7F7F
'  $$Grey                = 0x7F7F7F
'  $$LightGrey           = 0xBFBFBF
'  $$BrightGrey          = 0xBFBFBF
'  $$DarkSteel           = 0x3F3F7F
'  $$MediumSteel         = 0x7F7FBF
'  $$Steel               = 0x7F7FBF
'  $$BrightSteel         = 0xBFBFFF
'  $$MediumOrange        = 0x3F3FBF
'  $$Orange              = 0x3F3FBF
'  $$BrightOrange        = 0x7F7FFF
'  $$LightOrange         = 0x7F7FFF
'  $$MediumAqua          = 0x7FBF3F
'  $$Aqua                = 0x7FBF3F
'  $$BrightAqua          = 0xBFFF7F
'  $$DarkViolet          = 0x7F3F7F
'  $$MediumViolet        = 0xBF7FBF
'  $$Violet              = 0xBF7FBF
'  $$BrightViolet        = 0xFFBFFF
'  $$White               = 0xFFFFFF
'
END EXPORT
'
'
' ####################
' #####  Xpr ()  #####
' ####################
'
FUNCTION  Xpr ()
'
' Return if compiled as dll
	IF LIBRARY(0) THEN RETURN
'
	XioCreateConsole (title$, 100)
	hStdOut = XioGetStdOut ()

' Note: Test files expect XBLite directory structure
' so remember to modify the path of the sample text/html files below
' if you have XBLite installed in a different directory.

' fileName$ must include full path
	fileName$ = "/xblite/readme.txt"
'	fileName$ = "c:\\xblite\\readme.txt"
	docName$ = "/xblite/readme.doc"
'	docName$ = "c:\\xblite\\readme.doc"
' htmName$ = "c:\\xblite\\xblite.htm"
'
entry:
	XioClearConsole (hStdOut)
	XioSetConsoleCursorPos (hStdOut, 0, 0)

	a$ = INLINE$ ("Press any key to display menu >")
	GOSUB Test
	GOTO entry

' ***** Test *****
SUB Test
  PRINT "***** Xpr Test Functions *****"
	PRINT "Make a Selection:"
	PRINT "1  = Test Text Functions"
	PRINT "2  = Test Image Functions"
	PRINT "3  = Test Graphic Functions"
	PRINT "4  = Test XprLPrint Function (Win95/98 only!)"
	PRINT "5  = Print File to LPT1 Win95/98 only!)"
	PRINT "6  = Print File to Wordpad"
	PRINT "7  = Print File to Notepad"
	PRINT "8  = Print Html File to MSHTML"
	PRINT "9  = Print Html File to Netscape"
	PRINT "10 = Print File to ShellExecute"
	PRINT "11 = Print Raw Text to Default Printer"
	PRINT "X or 0 to QUIT"

	a$ = INLINE$ ("Make a Selection or Press X to Exit >")

	prompt$ = TRIM$(a$)

	SELECT CASE prompt$
		CASE "1"	:	XprTestTextFunctions ()
		CASE "2"	:	XprTestImageFunctions ()
		CASE "3"	:	XprTestGraphicsFunctions ()
		CASE "4"	: XprTestLPrint()
		CASE "5"	:	XprPrintFileToLPT1 (fileName$, 63, CHR$(27) + CHR$(77))
		CASE "6"	:	XprPrintFileToWordPad (fileName$)
		CASE "7"	:	XprPrintFileToNotePad (fileName$)
		CASE "8"	:	XprPrintFileToMsHtml (htmName$)
		CASE "9"	:	XprPrintFileToNetscape (htmName$)
		CASE "10"	:	XprPrintFileToShellExecute (fileName$)
		CASE "11" : 
      XprGetDefaultPrinter (@pr$, @driver$, @port$)
      text$ = text$ + "THE PIAZZA RUSTICUCCI was not one of Rome's most prestious" + $$RN
      text$ = text$ + "addresses. Though only a short walk from the Vatican, the" + $$RN
      text$ = text$ + "square was humble and nondescript, part of a maze of narrow" + $$RN
      text$ = text$ + "streets and densely packed shops and houses that ran west" + $$RN
      text$ = text$ + "from where the Ponte Sant'Angelo crossed the Tiber River." + $$RN
      text$ = text$ + $$FF
      XprRawTextToPrinter (pr$, @text$)
      text$ = ""

		CASE "x", "X", "0" :
			XioFreeConsole ()
			QUIT (0)
		CASE ELSE : GOTO entry
	END SELECT
END SUB

END FUNCTION
'
'
' ############################
' ####  XprEndDocument ()  ###
' ############################
'
'	/*
'	[XprEndDocument]
' Description = The XprEndDocument function ends a print job and deletes the current printer device context.
' Function    = error = XprEndDocument ()
' ArgCount    = 0
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = XprEndDocument must be called at the end of print job which was started using XprStartDocument.
'	See Also    = See XprStartDocument.
'	Examples    = XprEndDocument ()
'	*/
'
FUNCTION  XprEndDocument ()
	SHARED  pDC
	SHARED  initStartDoc
	SSHORT  ret
'
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
 		RETURN 0
	END IF
'
'inform the spooler that the page is complete
	IF EndPage (pDC) <= 0 THEN GOSUB Error

'inform the driver that document has ended.
	IF EndDoc (pDC) <= 0 THEN GOSUB Error
'
'delete printer DC
	DeleteDC (pDC)
'
'reset pDC
	pDC = 0
'
'reset flag initStartDoc
	initStartDoc = $$FALSE
'
	RETURN ($$TRUE)
'
' ***** Error *****
SUB Error
	IF pDC THEN
		DeleteDC (pDC)
		pDC = 0
	END IF
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ###########################
' #####  XprNewPage ()  #####
' ###########################
'
'	/*
'	[XprNewPage]
' Description = The XprNewPage function starts a new page to be printed.
' Function    = error = XprNewPage ()
' ArgCount    = 0
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = Use XprNewPage after calling XprStartDocument to cause a form feed and begin new page.
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XprNewPage ()
'
	SHARED pDC
	SHARED DOUBLE pyposition
'
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
 		RETURN 0
	END IF
'
	IF EndPage (pDC) <= 0 THEN GOSUB Error
	IF StartPage (pDC) <= 0 THEN GOSUB Error

	RETURN ($$TRUE)
'
' *****  Error  *****
'
SUB Error
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ##############################
' ###  XprStartDocument ()  ####
' ##############################
'
'	/*
'	[XprStartDocument]
' Description = The XprStartDocument function initializes a print job and creates a printer device context. It then begins the print job by calling StartDocA. Finally, it informs the driver that the application is about to begin sending data by calling StartPage.
' Function    = error = XprStartDocument (prtName$, jobName$)
' ArgCount    = 2
' Arg1        = prtName$ : The printer to send a print job. If prtName$ is empty, then the default printer is used.
' Arg2        = jobName$ : A print job name or description. If jobName$ is empty, then a default job name is used.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = XprStartDocument must be called at the start of any print job using the Xpr drawing or text functions. XprStartDocument should not be called again after the job has started and before calling XprEndDocument. XprStartDocument must be matched with XprEndDocument. It is not required with the XprPrintFileXXX functions.
'	See Also    = See XprEndDocument.
'	Examples    = XprStartDocument ("BJC-4200", "My XBLite Document")
'	*/
'
FUNCTION  XprStartDocument (prtName$, jobName$)
'
	SHARED  DOCINFO  docinfo
	SSHORT  ret
	SHARED  pDC
	SHARED  initStartDoc
	SHARED  pHorzPPI,  pVertPPI,  pMaxWidth,  pMaxHeight
	SHARED  offsetRight,  offsetLeft,  offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	POINT  gpps,  gpo   'point
'
' check be sure XprStartDocument() is only used once before XprEndDocument()
	IF (initStartDoc == $$TRUE) THEN
		error = ERROR ($$ErrorObjectFunction << 8 OR $$ErrorNatureAlreadyInitialized)
		RETURN 0
	END IF

'Get default printer name if prtName$ = ""
	IFZ prtName$ THEN
		IFZ XprGetDefaultPrinter (@prtName$, @driver$, @port$) THEN RETURN 0
	END IF

'create a printer device context pDC
	pDC = CreateDCA (0, &prtName$, 0, 0)
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectFunction << 8 OR $$ErrorNatureFailed)
 		RETURN 0
	END IF

' retrieve the number of pixels-per-logical-inch in the
' horizontal and vertical directions for the printer upon which
' the bitmap will be printed.
	pHorzPPI = GetDeviceCaps (pDC, $$LOGPIXELSX)
	pVertPPI = GetDeviceCaps (pDC, $$LOGPIXELSY)

' retrieve currently selected printable paper width/height in printer pixels
	pMaxWidth =  GetDeviceCaps(pDC, $$HORZRES)  '2880 for A4 paper on a Canon BJC-4200
	pMaxHeight = GetDeviceCaps(pDC, $$VERTRES)		'3092?
'
' get physical paper size
	psWidth = GetDeviceCaps (pDC, $$PHYSICALWIDTH)
	psHeight  = GetDeviceCaps (pDC, $$PHYSICALHEIGHT)
'
' get the non-printing offset edge around paper.
	offsetRight  = GetDeviceCaps (pDC, $$PHYSICALOFFSETX)
	offsetLeft = offsetRight
	offsetTop   = GetDeviceCaps (pDC, $$PHYSICALOFFSETY)
	offsetBottom = psHeight - offsetTop - pMaxHeight

' initialize the necessary members of a DOCINFO structure.
	IFZ jobName$ THEN
  	lpszDocName$ = "Printing XBLite Job"
		docinfo.docName = &lpszDocName$
	ELSE
  	lpszDocName$ = jobName$
		docinfo.docName = &lpszDocName$
	END IF

	docinfo.size = SIZE (docinfo)
'
' begin a print job by calling the StartDoc function.
	IF StartDocA (pDC, &docinfo) <= 0 THEN GOSUB Error

' inform the driver that the application is about to begin sending data.
	IF StartPage (pDC) <= 0 THEN GOSUB Error

' set init Flag to make sure XprStartDocument is only called once
	initStartDoc = $$TRUE

	RETURN ($$TRUE)

' ***** Error *****
SUB Error
	initStartDoc = $$FALSE
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
	RETURN 0
END SUB
END FUNCTION
'
'
' #############################
' #####  XprTextArray ()  #####
' #############################
'
'	/*
'	[XprTextArray]
' Description = The XprTextArray function prints an text array within specified margins.
' Function    = error = XprTextArray (@text$[], textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
' ArgCount    = 8
'	Arg1        = text$[] : Text array to print.
'	Arg2        = textFlags : Text style flags to indicate font properties and text justification on page. One font weight textFlag can be OR'd with one or both text style flags
' Arg3        = marLeft : x-position of left margin. All margin positions are given in 1/100" or 100 = 1". Margins begin measurements going inwards from each exterior edge of paper.
'	Arg4        = marTop : y-position of top margin (a DOUBLE value). The current y position of the next line is returned in marTop.
' Arg5        = marRight : x-position of right margin.
'	Arg6        = marBottom : y-position of bottom margin.
' Arg7        = fontName$ : Font name; eg, "arial", "fixedsys". The default font is "times new roman".
'	Arg8        = fontHeight : Height of font in points, 1 pt = 1/72".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = There is no word wrapping with this function.
'	See Also    = See xpr.dec for text flag constants.
'	Examples    = marTop = 100<br>XprTextArray (text$[], 0, 100, @marTop, 100, 100, "FixedSys", 10)
'	*/
'
FUNCTION  XprTextArray (@text$[], textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)

	SHARED pHorzPPI,  pVertPPI,  pMaxWidth,  pMaxHeight,  pDC
	SHARED offsetRight,  offsetLeft,  offsetTop, offsetBottom
	SHARED psHeight,  psWidth
	SHARED tabValue
	STATIC maxMarBottom
	SSHORT ret
	DOUBLE mTop
	SHARED DOUBLE pyposition
'
' make sure a pDC has been created by XprStartDocument
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF
'
' verify margins are not too big
	mt = marTop/100.0 * pVertPPI
	mb = marBottom/100.0 * pVertPPI
	ml = marLeft/100.0 * pHorzPPI
	mr = marRight/100.0 * pHorzPPI

	IF  mt > pMaxHeight THEN GOSUB MarginError
	IF  mb > pMaxHeight THEN GOSUB MarginError
	IF  ml > pMaxWidth THEN GOSUB MarginError
	IF  mr > pMaxWidth THEN GOSUB MarginError

	IF mt + mb > pMaxHeight THEN GOSUB MarginError
	IF ml + mr > pMaxWidth THEN GOSUB MarginError

' verify that margins are not too close together, > 1.5"
' this determines the minimum column size that can be printed
' watch out for large fonts in narrow columns!!!
	proxDistx = 1.5 * pHorzPPI
	IF psWidth - ml - mr < proxDistx THEN GOSUB MarginError

	proxDisty = 1.5 * pVertPPI
	IF psHeight - mt - mb < proxDisty THEN GOSUB MarginError
'
' verify margins are not inside non-printable offset around edge of paper
	IF mt < offsetTop THEN marTop = offsetTop/DOUBLE(pVertPPI) * 100
	IF mb < offsetBottom THEN marBottom = offsetBottom/DOUBLE(pVertPPI) * 100
	IF ml < offsetTop THEN marLeft = offsetLeft/DOUBLE(pHorzPPI) * 100
	IF mr < offsetRight THEN marRight = offsetRight/DOUBLE(pHorzPPI) * 100
'
' keep a copy of marTop for a new pagefeed
	mTop = marTop
'
' calc position of bottom margin in 1/100" units from top of page
' to compare to marTop for a new page feed
	maxMarBottom = (psHeight/ DOUBLE(pVertPPI) * 100) - marBottom

' get current tabValue
	XprGetTabValue(@tv)
'
' make a temp copy of text$[]
	XstCopyArray (@text$[], @temp$[])
'
' replace tab CHR$(9) with spaces based on tabValue
	ReplaceAllArray ($$FindForward, @temp$[], CHR$(9), SPACE$(tv))
'
' print textlines using XprTextLine with temp$[]
	upper = UBOUND(temp$[])
	FOR i = 0 TO upper
		text$ = temp$[i]
		IF marTop > maxMarBottom THEN GOSUB NewPageFeed
		IFZ XprTextLine (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight) THEN GOSUB Error
	NEXT i
'
' Set current pyPos
	pyposition = marTop
'
	RETURN ($$TRUE)
'
'
' *****  NewPageFeed  *****
SUB NewPageFeed
' end current page and start a new one
	IF EndPage (pDC) <= 0 THEN GOSUB Error
	IF StartPage (pDC) <= 0 THEN GOSUB Error
	marTop = mTop					' reset marTop
	pyposition = mTop			' set current pyPos
END SUB
'
'
' *****  MarginError  *****
SUB MarginError
	error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureInvalidMargin)
 	RETURN 0
END SUB
'
'
' *****  Error  *****
SUB Error
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ############################
' #####  XprTextFile ()  #####
' ############################
'
'	/*
'	[XprTextFile]
' Description = The XprTextFile function prints an disk text file within specified margins.
' Function    = error = XprTextFile (fileName$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
' ArgCount    = 8
'	Arg1        = fileName$ : Name of text file to print.
'	Arg2        = textFlags : Text style flags to indicate font properties and text justification on page. One font weight textFlag can be OR'd with one or both text style flags
' Arg3        = marLeft : x-position of left margin. All margin positions are given in 1/100" or 100 = 1". Margins begin measurements going inwards from each exterior edge of paper.
'	Arg4        = marTop : y-position of top margin (a DOUBLE value). The current y position of the next line is returned in marTop.
' Arg5        = marRight : x-position of right margin.
'	Arg6        = marBottom : y-position of bottom margin.
' Arg7        = fontName$ : Font name; eg, "arial", "fixedsys". The default font is "times new roman".
'	Arg8        = fontHeight : Height of font in points, 1 pt = 1/72".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = Word wrapping can be toggled on or off using the text mode flags  $$TEXT_WORDWRAPOFF or $$TEXT_WORDWRAPON.
'	See Also    = See xpr.dec for text flag constants.
'	Examples    = marTop = 100<br>XprTextFile ("c:/xblite/readme.txt", $$TEXT_WORDWRAPON, 100, @marTop, 100, 100, "MS Sans Serif", 10)
'	*/
'
FUNCTION  XprTextFile (fileName$, textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
	SHARED  pHorzPPI,  pVertPPI,  pMaxWidth, pMaxHeight,  pDC
	SHARED  offsetRight,  offsetLeft,	 offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	SSHORT  ret
'	POINT  textSize
	STATIC  maxMarBottom
	SHARED  tabValue
	SHARED  verMargins
	DOUBLE  mTop
	SHARED DOUBLE pyposition

' make sure fileName$ exists
	IFZ fileName$ THEN
		error = ERROR ($$ErrorObjectArgument << 8 OR $$ErrorNatureEmpty)
		RETURN 0
	END IF

' make sure file exists
	fn = OPEN (fileName$, $$RD)
	IF fn <= 0 THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
	CLOSE (fn)
'
' make sure a pDC has been created by XprStartDocument
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF
'
' set verMargins flag to 1 for calling XprTextParagraph
	verMargins = 1
'
' verify margins are not too big
	mt = marTop/100.0 * pVertPPI
	mb = marBottom/100.0 * pVertPPI
	ml = marLeft/100.0 * pHorzPPI
	mr = marRight/100.0 * pHorzPPI

	IF  mt > pMaxHeight THEN GOSUB MarginError
	IF  mb > pMaxHeight THEN GOSUB MarginError
	IF  ml > pMaxWidth THEN GOSUB MarginError
	IF  mr > pMaxWidth THEN GOSUB MarginError

	IF mt + mb > pMaxHeight THEN GOSUB MarginError
	IF ml + mr > pMaxWidth THEN GOSUB MarginError
'
' verify that margins are not too close together, > 1.5"
' this determines the minimum column size that can be printed
' watch out for large fonts in narrow columns!!!
	proxDistx = 1.5 * pHorzPPI
	IF psWidth - ml - mr < proxDistx THEN GOSUB MarginError

	proxDisty = 1.5 * pVertPPI
	IF psHeight - mt - mb < proxDisty THEN GOSUB MarginError
'
' verify margins are not inside non-printable offset around edge of paper
	IF mt < offsetTop THEN marTop = offsetTop/DOUBLE(pVertPPI) * 100
	IF mb < offsetBottom THEN marBottom = offsetBottom/DOUBLE(pVertPPI) * 100
	IF ml < offsetTop THEN marLeft = offsetLeft/DOUBLE(pHorzPPI) * 100
	IF mr < offsetRight THEN marRight = offsetRight/DOUBLE(pHorzPPI) * 100
'
' keep a copy of marTop for a new pagefeed
	mTop = marTop
'
' Calc position of bottom margin in 1/100" units from top of page
' to compare to marTop for a new page feed
	maxMarBottom = (psHeight/ DOUBLE(pVertPPI) * 100) - marBottom
'
' convert file to string array
	XstLoadStringArray (fileName$, @text$[])
'
' get current tabValue
	XprGetTabValue(@tv)
'
' replace tab CHR$(9) with spaces based on tabValue
	ReplaceAllArray ($$FindForward, @text$[], CHR$(9), SPACE$(tv))
'
' print each line of text from text$[]
	upper = UBOUND(text$[])
	FOR i = 0 TO upper
		text$ = text$[i]
'
' if word wrap is on then print a textline using XprTextParagraph
		IF textFlags AND $$TEXT_WORDWRAPON THEN
'
' check to see if a new page is needed
			IF marTop > maxMarBottom THEN GOSUB NewPageFeed
			IFZ XprTextParagraph (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight) THEN GOSUB Error
		ELSE
'
' if word wrap is off then print a textline using XprTextLine
			IF marTop > maxMarBottom THEN GOSUB NewPageFeed
			IFZ XprTextLine (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight) THEN GOSUB Error
		END IF
	NEXT i
'
' ReSet verMargins flag to 0 for calling XprTextParagraph
	verMargins = 0
'
' Set current pyPos
	pyposition = marTop
'
	RETURN ($$TRUE)
'
'
' *****  NewPageFeed  *****
SUB NewPageFeed
' end current page and start a new one
	IF EndPage (pDC) <= 0 THEN GOSUB Error
	IF StartPage (pDC) <= 0 THEN GOSUB Error
	marTop = mTop						' reset marTop
	pyposition = mTop				' set current pyPos
END SUB
'
'
' *****  MarginError  *****
SUB MarginError
	error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureInvalidMargin)
 	RETURN 0
END SUB
'
'
' *****  Error  *****
SUB Error
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ############################
' #####  XprTextLine ()  #####
' ############################
'
'	/*
'	[XprTextLine]
' Description = The XprTextLine function prints a text string within specified margins. A blank line is printed if text$ = ""
' Function    = error = XprTextLine (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
' ArgCount    = 8
'	Arg1        = text$ : Text string to print.
'	Arg2        = textFlags : Text style flags to indicate font properties and text justification on page. One font weight textFlag can be OR'd with one or both text style flags
' Arg3        = marLeft : x-position of left margin. All margin positions are given in 1/100" or 100 = 1". Margins begin measurements going inwards from each exterior edge of paper.
'	Arg4        = marTop : y-position of top margin (a DOUBLE value). The current y position of the next line is returned in marTop.
' Arg5        = marRight : x-position of right margin.
'	Arg6        = marBottom : y-position of bottom margin.
' Arg7        = fontName$ : Font name; eg, "arial", "fixedsys". The default font is "times new roman".
'	Arg8        = fontHeight : Height of font in points, 1 pt = 1/72".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = There is no word wrapping with this function.
'	See Also    = See xpr.dec for text flag constants.
'	Examples    = marTop = 150 		'= 1.5"<br>text$ = "Protect your privacy. Clean up your tracks."<br>XprTextLine (text$, $$TEXT_NORMAL, 100, @marTop, 100, 150, "arial", 10)
'	*/
'
FUNCTION  XprTextLine (text$, textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
	SHARED  pHorzPPI,	 pVertPPI,	 pMaxWidth,  pMaxHeight,  pDC
	SHARED  offsetRight,  offsetLeft,  offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	SSHORT  ret
	SHARED  tabValue
	POINT  textSize
	SHARED DOUBLE pyposition
'
' make sure a pDC has been created by XprStartDocument
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF
'
' create a font
	IFZ fontName$ THEN fontName$ = "times new roman"
	IF (fontHeight < 6) THEN fontHeight = 6
'
' font heights are in points where 1 point = 1/72"
	fontH# = fontHeight/72.0 * pVertPPI
'
' scale fonts based on any differences between horz and vert PPI
'	hfactor# = pVertPPI/ DOUBLE(pHorzPPI)
'	fontH# = fontH# * hfactor#
'
' calc fontWidth
	wfactor# = pHorzPPI/ DOUBLE(pVertPPI)
	fontWidth=INT(fontH#/2.5*wfactor#)
'
	weight = 0
	IF textFlags AND $$TEXT_THIN				THEN weight = 100
	IF textFlags AND $$TEXT_EXTRALIGHT	THEN weight = 200
	IF textFlags AND $$TEXT_LIGHT				THEN weight = 300
	IF textFlags AND $$TEXT_NORMAL			THEN weight = 400
	IF textFlags AND $$TEXT_MEDIUM			THEN weight = 500
	IF textFlags AND $$TEXT_SEMIBOLD		THEN weight = 600
	IF textFlags AND $$TEXT_BOLD				THEN weight = 700
	IF textFlags AND $$TEXT_EXTRABOLD		THEN weight = 800
	IF textFlags AND $$TEXT_HEAVY				THEN weight = 900
'
' set italic
	italic = 0
	IF (textFlags AND $$TEXT_ITALIC) THEN italic = 1
'
' set underline
	underline = 0
	IF (textFlags AND $$TEXT_UNDERLINED) THEN underline = 1

	strikeout = 0
	charset = $$ANSI_CHARSET
	outputPrecision = $$OUT_STROKE_PRECIS
	clipPrecision = $$CLIP_STROKE_PRECIS
	quality = $$DRAFT_QUALITY
	pitchAndFamily =	0
'
	fntH = INT(fontH#)
	hFont = CreateFontA (fntH, fontWidth, 0, 0, weight, italic, underline, strikeout, charSet, outputPrecision, clipPrecision, quality, pitchAndFamily, &fontName$)
	IFZ hFont THEN GOSUB Error
	hOldFont = SelectObject (pDC, hFont)
'
' calc x and y positions, margin values are in 1/100", 100 = 1"
	x = marLeft * pHorzPPI / 100.0
	y = marTop	* pVertPPI / 100.0
'
' adjust for the printing page offset.
	x = x - offsetLeft
	IF (x < 0) THEN x = 0
'
	y = y - offsetTop
	IF (y < 0) THEN y = 0
'
	maxX = pMaxWidth - INT(marRight	* pHorzPPI)
	maxY = pMaxHeight - INT(marBottom * pVertPPI)

' justify text if necessary
	IF textFlags AND $$TEXT_JUSTIFYCENTER = $$TEXT_JUSTIFYCENTER || textFlags AND $$TEXT_JUSTIFYRIGHT = $$TEXT_JUSTIFYRIGHT THEN

' calc width of line in printer pixels
		lineWidth = psWidth - ((marLeft + marRight)*pHorzPPI/100.0)

' get width of current text string
		IFZ GetTextExtentPoint32A (pDC, &text$, LEN(text$), &textSize) THEN GOSUB Error
		twidth = textSize.x

		IF twidth < lineWidth THEN
			IF textFlags AND $$TEXT_JUSTIFYCENTER = $$TEXT_JUSTIFYCENTER THEN
				x = x + lineWidth/2.0 - twidth/2.0
			END IF

			IF textFlags AND $$TEXT_JUSTIFYRIGHT = $$TEXT_JUSTIFYRIGHT THEN
				x = x + lineWidth - twidth
			END IF
		END IF
	END IF

'	print the text using TextOutA
	IFZ TextOutA (pDC, x, y, &text$, SIZE(text$)) THEN GOSUB Error
'
' calc new marTop return value
' change linespace if font is courier new due to underscore printing issue
	IF LCASE$(fontName$) = "courier new" + CHR$(0) THEN
		lineSpace# = INT(fontH# / DOUBLE(pVertPPI) * 100) + 1
	ELSE
		lineSpace# = fontH# / DOUBLE(pVertPPI) * 100
	END IF
'
	marTop = marTop + lineSpace#
	pyposition = marTop
'
' select default font back into printer DC, then delete new font
'
	SelectObject (pDC, hOldFont)
	DeleteObject (hFont)
	RETURN ($$TRUE)
'
' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hFont THEN
		SelectObject (pDC, hOldFont)
		DeleteObject (hFont)
	END IF
'
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB

END FUNCTION
'
'
' #################################
' #####  XprTextParagraph ()  #####
' #################################
'
'	/*
'	[XprTextParagraph]
' Description = The XprTextParagraph function prints a text string as a word wrapped paragraph within specififed margins.
' Function    = error = XprTextParagraph (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
' ArgCount    = 8
'	Arg1        = text$ : Text string to print.
'	Arg2        = textFlags : Text style flags to indicate font properties and text justification on page. One font weight textFlag can be OR'd with one or both text style flags
' Arg3        = marLeft : x-position of left margin. All margin positions are given in 1/100" or 100 = 1". Margins begin measurements going inwards from each exterior edge of paper.
'	Arg4        = marTop : y-position of top margin (a DOUBLE value). The current y position of the next line is returned in marTop.
' Arg5        = marRight : x-position of right margin.
'	Arg6        = marBottom : y-position of bottom margin.
' Arg7        = fontName$ : Font name; eg, "arial", "fixedsys". The default font is "times new roman".
'	Arg8        = fontHeight : Height of font in points, 1 pt = 1/72".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = The text justification flags do not apply to word wrapping in paragraphs.
'	See Also    = See xpr.dec for text flag constants.
'	Examples    = marTop = 100"<br>XprTextParagraph (text$, $$TEXT_NORMAL | $$TEXT_ITALIC, 300, @marTop, 300, 150, "arial", 10)
'	*/
'
FUNCTION  XprTextParagraph (text$, textFlags, marLeft, DOUBLE marTop, marRight, marBottom, fontName$, fontHeight)
	SHARED  pHorzPPI,  pVertPPI, pMaxWidth,  pMaxHeight,  pDC
	SHARED  offsetRight, offsetLeft,  offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	SSHORT  ret
	POINT  textSize
	STATIC  maxMarBottom
	SHARED  tabValue
	SHARED  verMargins
	DOUBLE mTop
'
' make sure a pDC has been created by XprStartDocument
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF
'
' if this is called by XprTextFile then ignore verifying margins
	IFZ verMargins THEN
'
' verify margins are not too big
		mt = marTop/100.0 * pVertPPI
		mb = marBottom/100.0 * pVertPPI
		ml = marLeft/100.0 * pHorzPPI
		mr = marRight/100.0 * pHorzPPI

		IF  mt > pMaxHeight THEN GOSUB MarginError
		IF  mb > pMaxHeight THEN GOSUB MarginError
		IF  ml > pMaxWidth THEN GOSUB MarginError
		IF  mr > pMaxWidth THEN GOSUB MarginError

		IF mt + mb > pMaxHeight THEN GOSUB MarginError
		IF ml + mr > pMaxWidth THEN GOSUB MarginError
'
' verify that margins are not too close together, > 1.5"
' this determines the minimum column size that can be printed
' watch out for large fonts in narrow columns!!!
		proxDistx = 1.5 * pHorzPPI
		IF psWidth - ml - mr < proxDistx THEN GOSUB MarginError

		proxDisty = 1.5 * pVertPPI
		IF psHeight - mt - mb < proxDisty THEN GOSUB MarginError
'
' verify margins are not inside non-printable offset around edge of paper
		IF mt < offsetTop THEN marTop = offsetTop/DOUBLE(pVertPPI) * 100
		IF mb < offsetBottom THEN marBottom = offsetBottom/DOUBLE(pVertPPI) * 100
		IF ml < offsetTop THEN marLeft = offsetLeft/DOUBLE(pHorzPPI) * 100
		IF mr < offsetRight THEN marRight = offsetRight/DOUBLE(pHorzPPI) * 100
	END IF
'
' keep a copy of marTop for a new pagefeed
	 mTop = marTop
'
' create a font for measuring width textLine$
	IF fontName$ = "" THEN fontName$ = "courier new"
	fontName$ = fontName$ + CHR$(0)
	IF fontHeight	< 6 THEN fontHeight = 6
'
' font heights are in points where 1 point = 1/72"
	fontH# = fontHeight/72.0 * pVertPPI
'
' scale font based on any differences between horz and vert PPI
'	 hfactor# = pVertPPI/ DOUBLE(pHorzPPI)
'	 fontH# = fontH# * hfactor#
'
' calc fontWidth
  wfactor# = pHorzPPI/ DOUBLE(pVertPPI)
  fontWidth=INT(fontH/2.5*wfactor#)

	weight = 0
	IF textFlags AND $$TEXT_THIN       THEN weight = 100
	IF textFlags AND $$TEXT_EXTRALIGHT THEN weight = 200
	IF textFlags AND $$TEXT_LIGHT      THEN weight = 300
	IF textFlags AND $$TEXT_NORMAL     THEN weight = 400
	IF textFlags AND $$TEXT_MEDIUM     THEN weight = 500
	IF textFlags AND $$TEXT_SEMIBOLD   THEN weight = 600
	IF textFlags AND $$TEXT_BOLD       THEN weight = 700
	IF textFlags AND $$TEXT_EXTRABOLD  THEN weight = 800
	IF textFlags AND $$TEXT_HEAVY      THEN weight = 900
'
' set italic
	italic = 0
	IF textFlags AND $$TEXT_ITALIC THEN italic = 1
'
' set underline
	underline = 0
	IF textFlags AND $$TEXT_UNDERLINED THEN underline = 1

	strikeout = 0
	charset = $$ANSI_CHARSET
	outputPrecision = $$OUT_STROKE_PRECIS
	clipPrecision = $$CLIP_STROKE_PRECIS
	quality = $$DRAFT_QUALITY
	pitchAndFamily =	0
'
' create the font
	fntH = INT(fontH#)
	hFont = CreateFontA (fntH, fontWidth, 0, 0, weight, italic, underline, strikeout, charSet, outputPrecision, clipPrecision, quality, pitchAndFamily, &fontName$)
	IFZ hFont THEN GOSUB Error
	hOldFont = SelectObject (pDC, hFont)
'
' calc width of line in printer pixels
	lineWidth = psWidth - ((marLeft + marRight)*pHorzPPI/100.0)
'
' calc position of bottom margin in 1/100" units from top of page
' to compare to marTop for a new page feed
	maxMarBottom = (psHeight/ DOUBLE(pVertPPI) * 100) - marBottom
'
' parse text$ into words
	ParseTextStringToStringArray (text$, @word$[])
'
' create lines of text until all words are used
	i = UBOUND(word$[])
	lastWord = i
	count = 0

	DO
		textLine$ = ""
		DO
			temp$ = textLine$
			textLine$ = textLine$ + word$[count] + " "
'
' get width of current text string
			IFZ GetTextExtentPoint32A (pDC, &textLine$, LEN(textLine$), &textSize) THEN GOSUB Error
			twidth = textSize.x
'
' print a line of text when text string exceeds area between margins
			IF twidth > lineWidth THEN
'
' check to see if a new page is needed
				IF marTop > maxMarBottom THEN GOSUB NewPageFeed
				textLine$ = temp$
				IFZ XprTextLine (textLine$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight) THEN GOSUB Error
'
'print last word of single line on next line
				IF twidth > 0 && i = 0 THEN
					textLine$ = word$[lastWord]
					IF marTop > maxMarBottom THEN GOSUB NewPageFeed
					IFZ XprTextLine (textLine$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight) THEN GOSUB Error
				END IF
				EXIT DO
			END IF
'
' print the last line of text
			IF twidth > 0 && i = 0 THEN
				IF marTop > maxMarBottom THEN GOSUB NewPageFeed
				IFZ XprTextLine (textLine$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight) THEN GOSUB Error
				EXIT DO
			END IF

			DEC i
			INC count
		LOOP
	LOOP UNTIL i = 0
'
' select default font back into printer DC, then delete new font
	hNewFont = SelectObject (pDC, hOldFont)
	ret = DeleteObject (hNewFont)
'
	RETURN ($$TRUE)
'
'
' *****  NewPageFeed  *****
SUB NewPageFeed
' end current page and start a new one
	IF EndPage (pDC) <= 0 THEN GOSUB Error
	IF StartPage (pDC) <= 0 THEN GOSUB Error
	marTop = mTop					' reset marTop
END SUB
'
' *****  MarginError  *****
SUB MarginError
	error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureInvalidMargin)
 	RETURN 0
END SUB
'
' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hFont THEN
		SelectObject (pDC, hOldFont)
		DeleteObject (hFont)
	END IF
'
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ################################
' #####  XprPrintBmpFile ()  #####
' ################################
'
'	/*
'	[XprPrintBmpFile]
' Description = The XprPrintBmpFile function prints a bitmap image from a *.bmp disk file.
' Function    = error = XprPrintBmpFile (fileName$, style, pxPos, @pyPos, scaleFactor)
' ArgCount    = 5
'	Arg1        = fileName$ : File name of bitmap.
'	Arg2        = style : Style flags to indicate scaling and justification printing styles. $$BMP_SCALEFACTORON can be OR'd with one justification style flag ($$BMP_TOPLEFT, $$BMP_MIDDLECENTER, $$BMP_MANUALPOSITION).
' Arg3        = pxPos : Page x-position of bitmap (a DOUBLE type). The x and y positions are given in 1/100" or 100 = 1".
'	Arg4        = pyPos : Page y-position of bitmap. The y position of the bottom of the bitmap is returned.
' Arg5        = scaleFactor : Percent factor to reduce or enlarge the bitmap. The scaleFactor must be > 0. For example, 100 = 100% or a 1:1 ratio with no change in scale, while 50 = 50% or a reduction of image size by half.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XprPrintBmpFile (fileName$, style, pxPos, DOUBLE pyPos, scaleFactor)
'	DOCINFO  docinfo
	BITMAP  bitMapInfo
	XLONG   size
	SINGLE  fScaleX,  fScaleY,  hbitsx1,  hbitsx2,  vbitsy1,  vbitsy2,  ff
	SSHORT  ret
	SHARED  pDC
	SHARED  initStartDoc
	SHARED  pHorzPPI,  pVertPPI, pMaxWidth,  pMaxHeight
	SHARED  offsetRight,  offsetLeft,	 offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	POINT  gpps,  gpo  'point
	SHARED DOUBLE pyposition
'
	IFZ fileName$ THEN
		error = ERROR ($$ErrorObjectArgument << 8 OR $$ErrorNatureEmpty)
		RETURN 0
	END IF
'
' make sure file exists
	XstGetFileAttributes (fileName$, @attributes)
	IF attributes = $$FileNonexistent THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
'
' make sure StartDocument() has been called
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
 		RETURN 0
	END IF
'
	pyPosInit = pyPos		' save initial pyPos
'
' load the bitmap into memory using LoadImageA in user32.dll(it may also load .dib .ico .wmf .cur files)
	hBitmap = LoadImageA (0, &fileName$, $$IMAGE_BITMAP, 0, 0, $$LR_LOADFROMFILE OR $$LR_CREATEDIBSECTION)
'
' make sure the call succeeded
  IFZ hBitmap THEN
		error = ERROR ($$ErrorObjectFunction << 8 OR $$ErrorNatureFailed)
		RETURN 0
	END IF
'
' create a device context for the loaded memory bitmap
	memDC = CreateCompatibleDC (0)
'
' make sure our call succeeded
	IFZ memDC THEN GOSUB Error
'
' attach the bitmap to the device context just created
	hOldBitmap = SelectObject (memDC, hBitmap)
'
' get the information about this image as bitMapInfo struct
	IFZ GetObjectA (hBitmap, SIZE (bitMapInfo), &bitMapInfo) THEN GOSUB Error
'
' retrieve the number of pixels-per-logical-inch in the
' horizontal and vertical directions memory bitmap
	hbitsx1 = GetDeviceCaps (memDC, $$LOGPIXELSX)
	vbitsy1 = GetDeviceCaps (memDC, $$LOGPIXELSY)

' determine the scaling factors required to print the bitmap and
' retain its original proportions.
	IF (hbitsx1 > pHorzPPI) THEN
		fScaleX = (hbitsx1 / pHorzPPI)
	ELSE
		fScaleX = (pHorzPPI / hbitsx1)
	END IF

	IF (vbitsy1 > pVertPPI) THEN
		fScaleY = (vbitsy1 / pVertPPI)
	 ELSE
		fScaleY = (pVertPPI / vbitsy1)
	END IF

' calc printed image height and width to get 1:1 scaling
' A separate fudge factor ff may be used to adjust the printed output to the
' same 1:1 size between screen/monitor based on the printer and monitor types
' Overall scaleFactor percent is used to shrink or enlarge image
' change as needed to get 1:1 between printed output & image size on monitor
' A value for ff between 0.8 and 0.9 seems to work
'
	ff = 0.85
	w = bitMapInfo.width
	h = bitMapInfo.height
'
	scaleX=INT((w * fScaleX)/ ff)
	scaleY=INT((h * fScaleY)/ ff)
'
' I found that I cound not print anthing wider than 2537 pels
' I have no idea why it is not the same as the value for $$HORZRES
' for the printer. If someone can solve this problem, let me know.
	maxWidth =  GetDeviceCaps(pDC, $$HORZRES)  'or 2880 for A4 paper on a Canon BJC-4200
	maxHeight = GetDeviceCaps(pDC, $$VERTRES)		'3092?
'
' use $$BMP_SCALEFACTORON to shrink or enlarge image
	IF (style AND $$BMP_SCALEFACTORON) THEN
		IF scaleFactor <= 0 THEN scaleFactor = 100
		scaleX = INT(scaleX * scaleFactor / 100.0)
		scaleY = INT(scaleY * scaleFactor / 100.0)

		IF scaleX > maxWidth THEN
			newScaleX! = maxWidth
			ratio! = newScaleX! / scaleX
			scaleX = INT(newScaleX!)
	    scaleY = INT(ratio! * scaleY)
		END IF
	END IF

' destination print coordinates pxPos, pyPos can be changed
' to locate image anywhere on paper (within printing area).
'
' $$BMP_TOPLEFT
	IF (style AND $$BMP_TOPLEFT) THEN
		pxPos = 0
		pyPos = 0
	END IF
'
' $$BMP_MIDDLECENTER
	IF (style AND $$BMP_MIDDLECENTER) THEN
		widthPels = GetDeviceCaps(pDC, $$HORZRES)
		pxPos = (widthPels / 2) - (scaleX / 2)
		heightPels = GetDeviceCaps(pDC, $$VERTRES)
		pyPos = (heightPels / 2) - (scaleY / 2)
	END IF
'
' $$BMP_MANUALPOSITION
	IF (style AND $$BMP_MANUALPOSITION) THEN
		pxPos = pxPos * pHorzPPI /100
	  pyPos = pyPos * pVertPPI	/100
	END IF
'
' adjust xy positions for printing page offset
	pxPos = pxPos - offsetLeft
	pyPos = pyPos - offsetTop

	IF pxPos < 0 THEN pxPos = 0
	IF pyPos < 0 THEN pyPos = 0

'PRINT pxPos, pyPos, scaleX, scaleY

' use the StretchBlt function to scale the bitmap and maintain
' its original proportions (that is, if the bitmap was square
' when it appeared in the application's client area, it should
' also appear square on the page).

	IFZ StretchBlt (pDC, pxPos, pyPos, scaleX, scaleY, memDC, 0, 0, bitMapInfo.width, bitMapInfo.height, $$SRCCOPY) THEN GOSUB Error
'
' calc new return pyPos at bottom of image
	pyPos = pyPosInit + INT((scaleY) / DOUBLE(pVertPPI) * 100) + 1
	pyposition = pyPos
'
' release Memory and delete DC
	DeleteObject (hBitmap)
	DeleteDC (memDC)
	RETURN ($$TRUE)
'
' *****  Error  *****
SUB Error
	IF hBitmap THEN
		DeleteObject (hBitmap)
		DeleteDC (memDC)
	END IF
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ###############################
' #####  XprPrintScreen ()  #####
' ###############################
'
'	/*
'	[XprPrintScreen]
' Description = The XprPrintScreen function prints the current desktop screen.
' Function    = error = XprPrintScreen (x1Disp, y1Disp, x2Disp, y2Disp, style, pxPos, @pyPos, scaleFactor)
' ArgCount    = 8
'	Arg1        = x1Disp : Screen x-position of upper-left corner of bounding rectangle.
'	Arg2        = y1Disp : Screen y-position of upper-left corner of bounding rectangle.
'	Arg3        = x2Disp : Screen x-position of lower-right corner of bounding rectangle.
'	Arg4        = y2Disp : Screen y-position of lower-right corner of bounding rectangle.
'	Arg5        = style : Style flags to indicate scaling and justification printing styles. $$BMP_SCALEFACTORON can be OR'd with one justification style flag ($$BMP_TOPLEFT, $$BMP_MIDDLECENTER, $$BMP_MANUALPOSITION).
' Arg6        = pxPos : Page x-position of bitmap. The x and y positions are given in 1/100" or 100 = 1".
'	Arg7        = pyPos : Page y-position of bitmap (a DOUBLE value). The y position of the bottom of the bitmap is returned.
' Arg8        = scaleFactor : Percent factor to reduce or enlarge the bitmap. The scaleFactor must be > 0. For example, 100 = 100% or a 1:1 ratio with no change in scale, while 50 = 50% or a reduction of image size by half.
'               eg, 50 = 50% or reduction of image in half
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = If all screen bounding coordinates are zero, then the entire screen is printed.
'	See Also    =
'	Examples    = pyPos = 200<br>XprPrintScreen (0, 0, 400, 400, $$BMP_SCALEFACTORON, 0, @pyPos, 150)
'	*/
'
FUNCTION  XprPrintScreen (x1Disp, y1Disp, x2Disp, y2Disp, style, pxPos, DOUBLE pyPos, scaleFactor)
'
	SINGLE  fScaleX,  fScaleY,  hbitsx1,  hbitsx2,  vbitsy1,  vbitsy2,  ff
	SSHORT  ret
	SHARED  pDC
	SHARED  pHorzPPI,  pVertPPI, pMaxWidth,  pMaxHeight
	SHARED  offsetRight,  offsetLeft,	 offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	POINT  gpps,  gpo  'point
	SHARED DOUBLE pyposition
'
' make sure StartDocument() has been called
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
 		RETURN 0
	END IF
'
	pyPosInit = pyPos		' save initial pyPos

' calc size of window to print
	winWidth = ABS(x2Disp - x1Disp)
	winHeight = ABS(y2Disp - y1Disp)

' set xDisp, yDisp
	IF winWidth THEN
		xDisp = x1Disp
	ELSE
		xDisp = 0
	END IF
	IF winHeight THEN
		yDisp = y1Disp
	ELSE
		yDisp = 0
	END IF

	dispWidth  = GetSystemMetrics ($$SM_CXSCREEN)
	dispHeight = GetSystemMetrics ($$SM_CYSCREEN)

	IF (winWidth = 0) || (winHeight = 0)  || (winWidth > dispWidth) || (winHeight > dispHeight) THEN
		winWidth = dispWidth
		winHeight = dispHeight
	END IF

' get hDC for screen
	hDC = GetDC (0)
	IFZ hDC THEN GOSUB Error

' create a memory DC that is compatible with the printer and
' select the bitmap (which the user requested) into this DC.
	newDC = CreateCompatibleDC (hDC)
	IFZ newDC THEN GOSUB Error

	hDDB = CreateCompatibleBitmap (hDC, winWidth, winHeight)
	IFZ hDDB THEN GOSUB Error

' select image from memory newDC
	ret = SelectObject (newDC, hDDB)

' transfer image from screen to memory bitmap
	IFZ BitBlt (newDC, 0, 0, winWidth, winHeight, hDC, xDisp, yDisp, $$SRCCOPY) THEN GOSUB Error

' select image from memory newDC
'	ret = SelectObject (newDC, hDDB)
'
' retrieve the number of pixels-per-logical-inch in the
' horizontal and vertical directions memory bitmap
	hbitsx1 = GetDeviceCaps (newDC, $$LOGPIXELSX)
	vbitsy1 = GetDeviceCaps (newDC, $$LOGPIXELSY)

' determine the scaling factors required to print the bitmap and
' retain its original proportions.
	IF (hbitsx1 > pHorzPPI) THEN
		fScaleX = (hbitsx1 / pHorzPPI)
	ELSE
		fScaleX = (pHorzPPI / hbitsx1)
	END IF

	IF (vbitsy1 > pVertPPI) THEN
		fScaleY = (vbitsy1 / pVertPPI)
	 ELSE
		fScaleY = (pVertPPI / vbitsy1)
	END IF

' calc printed image height and width to get 1:1 scaling
' A separate fudge factor ff may be used to adjust the printed output to the
' same 1:1 size between screen/monitor based on the printer and monitor types
' Overall scaleFactor percent is used to shrink or enlarge image
' change as needed to get 1:1 between printed output & image size on monitor
' A value for ff between 0.8 and 0.9 seems to work

	ff = 0.85
	w = winWidth
	h = winHeight

	scaleX=INT((w * fScaleX)/ ff)
	scaleY=INT((h * fScaleY)/ ff)

' I found that I cound not print anthing wider than 2537 pels
' I have no idea why it is not the same as the value for $$HORZRES
' for the printer. If someone can solve this problem, let me know.

	maxWidth =  GetDeviceCaps(pDC, $$HORZRES)  'or 2880 for A4 paper on a Canon BJC-4200
	maxHeight = GetDeviceCaps(pDC, $$VERTRES)		'3092?

' style constants for XprPrintWindow() can be OR'd together:
' $$BMP_TOPLEFT = 1
' $$BMP_MIDDLECENTER = 2
' $$BMP_MANUALPOSITION = 4
' $$BMP_SCALEFACTORON = 8
'
' use $$BMP_SCALEFACTORON to shrink or enlarge image
'
	IF style AND $$BMP_SCALEFACTORON THEN
		IF scaleFactor <= 0 THEN scaleFactor = 100
		scaleX = INT(scaleX * scaleFactor / 100.0)
		scaleY = INT(scaleY * scaleFactor / 100.0)

		IF scaleX > maxWidth THEN
			newScaleX! = maxWidth
			ratio! = newScaleX! / scaleX
			scaleX = INT(newScaleX!)
	    scaleY = INT(ratio! * scaleY)
		END IF
	END IF

' destination print coordinates pxPos, pyPos can be changed
' to locate image anywhere on paper (within printing area).
'
' $$BMP_TOPLEFT
	IF (style AND $$BMP_TOPLEFT) THEN
		pxPos = 0
		pyPos = 0
	END IF
'
' $$BMP_MIDDLECENTER
	IF (style AND $$BMP_MIDDLECENTER) THEN
		widthPels = GetDeviceCaps(pDC, $$HORZRES)
		pxPos = (widthPels / 2) - (scaleX / 2)
		heightPels = GetDeviceCaps(pDC, $$VERTRES)
		pyPos = (heightPels / 2) - (scaleY / 2)
	END IF
'
' $$BMP_MANUALPOSITION
	IF (style AND $$BMP_MANUALPOSITION) THEN
		pxPos = pxPos * pHorzPPI /100
	   pyPos = pyPos * pVertPPI	/100
	END IF
'
' adjust xy positions for printing page offset
	pxPos = pxPos - offsetLeft
	pyPos = pyPos - offsetTop

	IF pxPos < 0 THEN pxPos = 0
	IF pyPos < 0 THEN pyPos = 0

'PRINT pxPos, pyPos, scaleX, scaleY

' use the StretchBlt function to scale the bitmap and maintain
' its original proportions (that is, if the bitmap was square
' when it appeared in the application's client area, it should
' also appear square on the page).

	IFZ StretchBlt (pDC, pxPos, pyPos, scaleX, scaleY, newDC, 0, 0, winWidth, winHeight, $$SRCCOPY) THEN GOSUB Error
'
' calc new return pyPos at bottom of image
	pyPos = pyPosInit + INT((scaleY) / DOUBLE(pVertPPI) * 100) + 1
	pyposition = pyPos
'
' release Memory and delete DC
	ReleaseDC (0, hDC)
	DeleteObject (hDDB)
	DeleteDC (newDC)
	RETURN ($$TRUE)
'
' *****  Error  *****
'
SUB Error
	IF newDC THEN
		ReleaseDC (h, hDC)
		DeleteObject (hDDB)
		DeleteDC (newDC)
	END IF
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB

END FUNCTION
'
'
' ###############################
' #####  XprPrintWindow ()  #####
' ###############################
'
'	/*
'	[XprPrintWindow]
' Description = The XprPrintWindow function prints a displayed window or control.
' Function    = error = XprPrintWindow (hWnd, style, pxPos, @pyPos, scaleFactor)
' ArgCount    = 5
'	Arg1        = hWnd : Window or control handle.
'	Arg2        = style : Style flags to indicate scaling and justification printing styles. $$BMP_SCALEFACTORON can be OR'd with one justification style flag ($$BMP_TOPLEFT, $$BMP_MIDDLECENTER, $$BMP_MANUALPOSITION).
' Arg3        = pxPos : Page x-position of bitmap. The x and y positions are given in 1/100" or 100 = 1".
'	Arg4        = pyPos : Page y-position of bitmap (a DOUBLE value). The y position of the bottom of the bitmap is returned.
' Arg5        = scaleFactor : Percent factor to reduce or enlarge the bitmap. The scaleFactor must be > 0. For example, 100 = 100% or a 1:1 ratio with no change in scale, while 50 = 50% or a reduction of image size by half.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
FUNCTION  XprPrintWindow (hWnd, style, pxPos, DOUBLE pyPos, scaleFactor)
'
	SINGLE  fScaleX,  fScaleY,  hbitsx1,  hbitsx2,  vbitsy1,  vbitsy2,  ff
	SSHORT  ret
	SHARED  pDC
	SHARED  pHorzPPI,  pVertPPI, pMaxWidth,  pMaxHeight
	SHARED  offsetRight,  offsetLeft,	 offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	POINT  gpps,  gpo  'point
	SHARED DOUBLE pyposition
	RECT rect

'	WINDOWPLACEMENT wndpl
'	RECT normalPos
'	POINT minPos
'	POINT maxPos
'
' make sure StartDocument() has been called
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF

	pyPosInit = pyPos		' save initial pyPos

	GetWindowRect (hWnd, &rect)

	winWidth 	= rect.right - rect.left
	winHeight = rect.bottom - rect.top
	xDisp 		= rect.left
	yDisp 		= rect.top

' get hDC for screen
	hDC = GetDC (0)
	IFZ hDC THEN GOSUB Error

' create a memory DC that is compatible with the printer and
' select the bitmap (which the user requested) into this DC.
	newDC = CreateCompatibleDC (hDC)
	IFZ newDC THEN GOSUB Error

	hDDB = CreateCompatibleBitmap (hDC, winWidth, winHeight)
	IFZ hDDB THEN GOSUB Error

'select image from memory newDC
	ret = SelectObject (newDC, hDDB)

'transfer image from screen to memory bitmap:
	IFZ BitBlt (newDC, 0, 0, winWidth, winHeight, hDC, xDisp, yDisp, $$SRCCOPY) THEN GOSUB Error

'select image from memory newDC
'	re = SelectObject (newDC, hDDB)
'
' retrieve the number of pixels-per-logical-inch in the
' horizontal and vertical directions memory bitmap
'
	hbitsx1 = GetDeviceCaps (newDC, $$LOGPIXELSX)
	vbitsy1 = GetDeviceCaps (newDC, $$LOGPIXELSY)

' determine the scaling factors required to print the bitmap and
' retain its original proportions.
'
	IF (hbitsx1 > pHorzPPI) THEN
		fScaleX = (hbitsx1 / pHorzPPI)
	ELSE
		fScaleX = (pHorzPPI / hbitsx1)
	END IF

	IF (vbitsy1 > pVertPPI) THEN
	  fScaleY = (vbitsy1 / pVertPPI)
	ELSE
		fScaleY = (pVertPPI / vbitsy1)
	END IF

' calc printed image height and width to get 1:1 scaling
' A separate fudge factor ff may be used to adjust the printed output to the
' same 1:1 size between screen/monitor based on the printer and monitor types
' Overall scaleFactor percent is used to shrink or enlarge image
' change as needed to get 1:1 between printed output & image size on monitor
' A value for ff between 0.8 and 0.9 seems to work

	ff = 0.85
	w = winWidth
	h = winHeight

	scaleX=INT((w * fScaleX)/ ff)
	scaleY=INT((h * fScaleY)/ ff)

' I found that I cound not print anthing wider than 2537 pels
' I have no idea why it is not the same as the value for $$HORZRES
' for the printer. If someone can solve this problem, let me know.

	maxWidth =  GetDeviceCaps(pDC, $$HORZRES)  'or 2880 for A4 paper on a Canon BJC-4200
	maxHeight = GetDeviceCaps(pDC, $$VERTRES)		'3092?

' style constants for XprPrintWindow() can be OR'd together:
' $$BMP_TOPLEFT = 1
' $$BMP_MIDDLECENTER = 2
' $$BMP_MANUALPOSITION = 4
' $$BMP_SCALEFACTORON = 8
'
' use $$BMP_SCALEFACTORON to shrink or enlarge image
'
	IF (style AND $$BMP_SCALEFACTORON) THEN
		IF scaleFactor <= 0 THEN scaleFactor = 100
		scaleX = INT(scaleX * scaleFactor / 100.0)
		scaleY = INT(scaleY * scaleFactor / 100.0)

		IF (scaleX > maxWidth) THEN
			newScaleX! = maxWidth
			ratio! = newScaleX! / scaleX
			scaleX = INT(newScaleX!)
	  scaleY = INT(ratio! * scaleY)
		END IF
	END IF

' destination print coordinates pxPos, pyPos can be changed
' to locate image anywhere on paper (within printing area).
'
' $$BMP_TOPLEFT
	IF (style AND $$BMP_TOPLEFT) THEN
		pxPos = 0
		pyPos = 0
	END IF
'
' $$BMP_MIDDLECENTER
	IF (style AND $$BMP_MIDDLECENTER) THEN
		widthPels = GetDeviceCaps(pDC, $$HORZRES)
		pxPos = (widthPels / 2) - (scaleX / 2)
		heightPels = GetDeviceCaps(pDC, $$VERTRES)
		pyPos = (heightPels / 2) - (scaleY / 2)
	END IF
'
' $$BMP_MANUALPOSITION
	IF (style AND $$BMP_MANUALPOSITION) THEN
		pxPos = pxPos * pHorzPPI /100
		pyPos = pyPos * pVertPPI	/100
	END IF
'
' adjust xy positions for printing page offset
	pxPos = pxPos - offsetLeft
	pyPos = pyPos - offsetTop

	IF pxPos < 0 THEN pxPos = 0
	IF pyPos < 0 THEN pyPos = 0

' use the StretchBlt function to scale the bitmap and maintain
' its original proportions (that is, if the bitmap was square
' when it appeared in the application's client area, it should
' also appear square on the page).

	IFZ StretchBlt (pDC, pxPos, pyPos, scaleX, scaleY, newDC, 0, 0, winWidth, winHeight, $$SRCCOPY) THEN GOSUB Error

' calc new return pyPos at bottom of image
	pyPos = pyPosInit + INT((scaleY) / DOUBLE(pVertPPI) * 100) + 1
	pyposition = pyPos
'
' release Memory and delete DC
	ReleaseDC (0, hDC)
	DeleteObject (hDDB)
	DeleteDC (newDC)
	RETURN ($$TRUE)

' *****  Error  *****
'
SUB Error
	IF newDC THEN
		ReleaseDC (h, hDC)
		DeleteObject (hDDB)
		DeleteDC (newDC)
	END IF
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB

END FUNCTION
'
'
' ###########################
' #####  XprDrawBox ()  #####
' ###########################
'
'	/*
'	[XprDrawBox]
' Description = The XprDrawBox function prints a rectangle on the page using bounding rectangle coordinates.
' Function    = error = XprDrawBox (color, x1, y1, x2, y2, lineStyle, lineWidth)
' ArgCount    = 7
'	Arg1        = color : Line color.
' Arg2        = x1 : x-position of upper-left corner of box.
'	Arg3        = y1 : y-position of upper-left corner of box.
' Arg4        = x2 : x-position of lower-right corner of box.
'	Arg5        = y2 : y-position of lower-right corner of box.
' Arg6        = lineStyle : Line style. The lineStyle uses XBasic linestyle constants or Win32 Pen Style constants. The lineStyle will only function if lineWidth = 0 (default), a width of 1 unit.  LineStyles: $$LineStyleSolid = 0 $$LineStyleDash = 1 $$LineStyleDot = 2 $$LineStyleDashDot = 3 $$LineStyleDashDotDot = 4
' Arg7        = lineWidth : Line width. The line width is given is 1/100" units or 25 = 1/4".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    = XprDrawBox ($$LightRed, 100, 100, 450, 300, $$LineStyleDashDot, 0)<br>XprDrawBox ($$Black, 100, 100, 200, 300, 0, 10)
'	*/
'
FUNCTION  XprDrawBox (color, x1, y1, x2, y2, lineStyle, lineWidth)
'
	SHARED pHorzPPI, pVertPPI,	pMaxWidth, pMaxHeight, pDC
	SHARED offsetRight, offsetLeft,	offsetTop, offsetBottom
	SHARED psHeight, 	psWidth
	SHARED fillStyle, fillColor
	SSHORT ret

	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF
'
'calc penWidth in printer measurments
	pLineWidth = INT (lineWidth * pHorzPPI / 100.0)

'Create and Select a new Pen
	hPen = CreatePen (lineStyle, pLineWidth, color)
	IF hPen <= 0 THEN GOSUB Error
	hOldPen = SelectObject (pDC, hPen)

'Create and Select a new Brush
	IF fillStyle THEN
		IF fillStyle = $$FillStyleSolid THEN
			hBrush = CreateSolidBrush (fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		ELSE
			hatchStyle = fillStyle{4,0}
			hBrush = CreateHatchBrush (hatchStyle, fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		END IF
	END IF

'calc px and py printer positions, given xy values are in 1/100", 100 = 1"
	px1 = INT(x1 * pHorzPPI / 100.0)
	py1  = INT(y1	* pVertPPI / 100.0)
	px2 = INT(x2 * pHorzPPI / 100.0)
	py2  = INT(y2	* pVertPPI / 100.0)

'Adjust for the printing page offset.
	px1 = px1 - offsetLeft
	px2 = px2 - offsetLeft
	py1 = py1 - offsetTop
	py2 = py2 - offsetTop

'Draw rectangle
	ret = Rectangle (pDC, px1, py1, px2, py2)
	IF ret <= 0 THEN GOSUB Error

'select default pen back into printer DC, then delete pen
    SelectObject (pDC, hOldPen)
    DeleteObject (hPen)

'select default brush back into printer DC, then delete brush
    SelectObject (pDC, hOldBrush)
    DeleteObject (hBrush)
'
	RETURN ($$TRUE)
'
' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hPen THEN
	   SelectObject (pDC, hOldPen)
	   DeleteObject (hPen)
	END IF

'select default brush back into printer DC, then delete brush
	IF hBrush THEN
    SelectObject (pDC, hOldBrush)
    DeleteObject (hBrush)
	END IF

	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ##############################
' #####  XprDrawCircle ()  #####
' ##############################
'
'	/*
'	[XprDrawCircle]
' Description = The XprDrawCircle function prints a circle on the page centered at x y and radius r.
' Function    = error = XprDrawCircle (color, r, x, y, lineStyle, lineWidth)
' ArgCount    = 6
'	Arg1        = color : Line color.
' Arg2        = r : Radius of circle.
'	Arg3        = x : x-position of center of circle.
' Arg4        = y : y-position of center of circle.
' Arg5        = lineStyle : Line style. The lineStyle uses XBasic linestyle constants or Win32 Pen Style constants. The lineStyle will only function if lineWidth = 0 (default), a width of 1 unit.  LineStyles: $$LineStyleSolid = 0 $$LineStyleDash = 1 $$LineStyleDot = 2 $$LineStyleDashDot = 3 $$LineStyleDashDotDot = 4
' Arg6        = lineWidth : Line width. The line width is given is 1/100" units or 25 = 1/4".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    = XprDrawCircle ($$LightRed, 50, 100, 100, $$LineStyleDashDot, 0)<br>XprDrawCircle ($$Cyan, 200, 300, 300, 0, 3)
'	*/
'
FUNCTION  XprDrawCircle (color, r, x, y, lineStyle, lineWidth)
'
	SHARED pHorzPPI, pVertPPI,	pMaxWidth, pMaxHeight, pDC
	SHARED offsetRight, offsetLeft,	offsetTop, offsetBottom
	SHARED psHeight, 	psWidth
	SHARED fillStyle, fillColor
	SSHORT ret

	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF

'calc penWidth in printer measurments
	pLineWidth = INT (lineWidth * pHorzPPI / 100.0)

'Create and Select a new Pen
	hPen = CreatePen( lineStyle, pLineWidth, color)
	IF hPen <= 0 THEN GOSUB Error
	hOldPen = SelectObject (pDC, hPen)

'Create and Select a new Brush
	IF fillStyle THEN
		IF fillStyle = $$FillStyleSolid THEN
			hBrush = CreateSolidBrush (fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		ELSE
			hatchStyle = fillStyle{4,0}
			hBrush = CreateHatchBrush (hatchStyle, fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		END IF
	END IF

'calc px and py printer positions, given xy values are in 1/100", 100 = 1"
	px = INT(x * pHorzPPI / 100.0)
	py  = INT(y	* pVertPPI / 100.0)
	pr = INT(r * pHorzPPI / 100.0)

'calc bounding rect for ellipse
	px1 = px - pr
	px2 = px + pr
	py1 = py - pr
	py2 = py + pr

'Adjust for the printing page offset.
	px1 = px1 - offsetLeft
	px2 = px2 - offsetLeft
	py1 = py1 - offsetTop
	py2 = py2 - offsetTop

'Draw circle using Ellipse
	IF Ellipse (pDC, px1, py1, px2, py2) <= 0 THEN GOSUB Error

'select default pen back into printer DC, then delete pen
  SelectObject (pDC, hOldPen)
  DeleteObject (hPen)

'select default brush back into printer DC, then delete brush
  SelectObject (pDC, hOldBrush)
  DeleteObject (hBrush)

	RETURN ($$TRUE)

' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hPen THEN
    SelectObject (pDC, hOldPen)
    DeleteObject (hPen)
	END IF

'select default brush back into printer DC, then delete brush
	IF hBrush THEN
    SelectObject (pDC, hOldBrush)
    DeleteObject (hBrush)
	END IF

	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ###############################
' #####  XprDrawEllipse ()  #####
' ###############################
'
'	/*
'	[XprDrawEllipse]
' Description = The XprDrawEllipse function prints an ellipse on the page using the bounding rectangle coordinates.
' Function    = error = XprDrawEllipse (color, x1, y1, x2, y2, lineStyle, lineWidth)
' ArgCount    = 7
'	Arg1        = color : Line color.
' Arg2        = x1 : x-position of upper-left corner of bounding rectangle.
'	Arg3        = y1 : y-position of upper-left corner of bounding rectangle.
' Arg4        = x2 : x-position of lower-right corner of bounding rectangle.
'	Arg5        = y2 : y-position of lower-right corner of bounding rectangle.
' Arg6        = lineStyle : Line style. The lineStyle uses XBasic linestyle constants or Win32 Pen Style constants. The lineStyle will only function if lineWidth = 0 (default), a width of 1 unit.  LineStyles: $$LineStyleSolid = 0 $$LineStyleDash = 1 $$LineStyleDot = 2 $$LineStyleDashDot = 3 $$LineStyleDashDotDot = 4
' Arg7        = lineWidth : Line width. The line width is given is 1/100" units or 25 = 1/4".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    = XprDrawEllipse ($$LightRed, 10, 10, 50, 90, $$LineStyleDashDot, 0)<br>XprDrawEllipse ($$Green, 100, 100, 200, 300, 0, 4)
'	*/
'
FUNCTION  XprDrawEllipse (color, x1, y1, x2, y2, lineStyle, lineWidth)

	SHARED pHorzPPI, pVertPPI,	pMaxWidth, pMaxHeight, pDC
	SHARED offsetRight, offsetLeft,	offsetTop, offsetBottom
	SHARED psHeight, 	psWidth
	SHARED fillStyle, fillColor
	SSHORT ret

	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF

'calc penWidth in printer measurments
	pLineWidth = INT (lineWidth * pHorzPPI / 100.0)

'Create and Select a new Pen
	hPen = CreatePen( lineStyle, pLineWidth,	color)
	IF hPen <= 0 THEN GOSUB Error
	hOldPen = SelectObject (pDC, hPen)

'Create and Select a new Brush
	IF fillStyle THEN
		IF fillStyle = $$FillStyleSolid THEN
			hBrush = CreateSolidBrush (fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		ELSE
			hatchStyle = fillStyle{4,0}
			hBrush = CreateHatchBrush (hatchStyle, fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		END IF
	END IF

'calc px and py printer positions, given xy values are in 1/100", 100 = 1"
	px1 = INT(x1 * pHorzPPI / 100.0)
	py1  = INT(y1	* pVertPPI / 100.0)
	px2 = INT(x2 * pHorzPPI / 100.0)
	py2  = INT(y2	* pVertPPI / 100.0)

'Adjust for the printing page offset.
	px1 = px1 - offsetLeft
	px2 = px2 - offsetLeft
	py1 = py1 - offsetTop
	py2 = py2 - offsetTop

'Draw ellipse
	ret = Ellipse (pDC, px1, py1, px2, py2)
	IF ret <= 0 THEN GOSUB Error

'select default pen back into printer DC, then delete pen
  SelectObject (pDC, hOldPen)
  DeleteObject (hPen)

'select default brush back into printer DC, then delete brush
  SelectObject (pDC, hOldBrush)
  DeleteObject (hBrush)

	RETURN ($$TRUE)

' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hPen THEN
	   SelectObject (pDC, hOldPen)
	   DeleteObject (hPen)
	END IF

'select default brush back into printer DC, then delete brush
	IF hBrush THEN
    SelectObject (pDC, hOldBrush)
    DeleteObject (hBrush)
	END IF

	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION


'
' ############################
' #####  XprDrawLine ()  #####
' ############################
'
'	/*
'	[XprDrawLine]
' Description = The XprDrawLine function prints a line on the page at the given coordinates.
' Function    = error = XprDrawLine (color, x1, y1, x2, y2, lineStyle, lineWidth)
' ArgCount    = 7
'	Arg1        = color : Line color.
' Arg2        = x1 : x-position of line starting point.
'	Arg3        = y1 : y-position of line starting point.
' Arg4        = x2 : x-position of line ending point.
'	Arg5        = y2 : y-position of line ending point.
' Arg6        = lineStyle : Line style. The lineStyle uses XBasic linestyle constants or Win32 Pen Style constants. The lineStyle will only function if lineWidth = 0 (default), a width of 1 unit.  LineStyles: $$LineStyleSolid = 0 $$LineStyleDash = 1 $$LineStyleDot = 2 $$LineStyleDashDot = 3 $$LineStyleDashDotDot = 4
' Arg7        = lineWidth : Line width. The line width is given is 1/100" units or 25 = 1/4".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    = XprDrawLine ($$LightRed, 100, 100, 450, 300, $$LineStyleDashDot, 0)<br>XprDrawLine ($$Black, 100, 100, 200, 300, 0, 10)
'	*/
'
FUNCTION  XprDrawLine (color, x1, y1, x2, y2, lineStyle, lineWidth)

	SHARED pHorzPPI, pVertPPI,	pMaxWidth, pMaxHeight, pDC
	SHARED offsetRight, offsetLeft,	offsetTop, offsetBottom
	SHARED psHeight, 	psWidth
	SSHORT ret

	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF

'calc penWidth in printer measurments
	pLineWidth = INT (lineWidth * pHorzPPI / 100.0)

'Create and Select a new Pen
	hPen = CreatePen (lineStyle, pLineWidth, color)
	hOldPen = SelectObject (pDC, hPen)

'calc px and py printer positions, given xy values are in 1/100", 100 = 1"
	px1 = INT(x1 * pHorzPPI / 100.0)
	py1  = INT(y1	* pVertPPI / 100.0)
	px2 = INT(x2 * pHorzPPI / 100.0)
	py2  = INT(y2	* pVertPPI / 100.0)

'Adjust for the printing page offset.
	px1 = px1 - offsetLeft
	px2 = px2 - offsetLeft
	py1 = py1 - offsetTop
	py2 = py2 - offsetTop

'Set starting point of line
	ret = MoveToEx (pDC, px1, py1, point)
	IF ret <= 0 THEN GOSUB Error

'Draw line to end point
	ret = LineTo (pDC, px2, py2)
	IF ret <= 0 THEN GOSUB Error

'select default pen back into printer DC, then delete new pen
	SelectObject (pDC, hOldPen)
	DeleteObject (hPen)

	RETURN ($$TRUE)

' ***** Error *****
SUB Error
	IF hPen THEN
		SelectObject (pDC, hOldPen)
		DeleteObject (hPen)
	END IF
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ###########################
' #####  XprDrawPie ()  #####
' ###########################
'
'	/*
'	[XprDrawPie]
' Description = The XprDrawPie function prints a pie shaped wedge on the page centered at x y and radius r beginning at angleStart degrees and ending at angleEnd degrees moving in a counterclockwise direction.
' Function    = error = XprDrawPie (color, r, x, y, angleStart#, angleEnd#, lineStyle, lineWidth)
' ArgCount    = 8
'	Arg1        = color : Line color.
'	Arg2        = r : Circle radius.
' Arg3        = x : x-position of center of circle.
'	Arg4        = y : y-position of center of circle.
' Arg5        = angleStart# : Beginning angle in degrees.
'	Arg6        = angleEnd# : Ending angle in degrees.
' Arg7        = lineStyle : Line style. The lineStyle uses XBasic linestyle constants or Win32 Pen Style constants. The lineStyle will only function if lineWidth = 0 (default), a width of 1 unit.  LineStyles: $$LineStyleSolid = 0 $$LineStyleDash = 1 $$LineStyleDot = 2 $$LineStyleDashDot = 3 $$LineStyleDashDotDot = 4
' Arg8        = lineWidth : Line width. The line width is given is 1/100" units or 25 = 1/4".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    = XprDrawPie ($$LightRed, 50, 100, 100, 0, 45, $$LineStyleDashDot, 0)<br>XprDrawPie (RGB(50, 100, 150), 200, 300, 300, 45, 225, $$LineStyleSolid, 3)
'	*/
'
FUNCTION  XprDrawPie (color, r, x, y, angleStart#, angleEnd#, lineStyle, lineWidth)
'
	SHARED pHorzPPI, pVertPPI,	pMaxWidth, pMaxHeight, pDC
	SHARED offsetRight, offsetLeft,	offsetTop, offsetBottom
	SHARED psHeight, 	psWidth
	SHARED fillStyle, fillColor
	SSHORT ret

	$DEGTORAD	= 0d3F91DF46A2529D39

	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF

'calc penWidth in printer measurments
	pLineWidth = INT (lineWidth * pHorzPPI / 100.0)

'Create and Select a new Pen
	hPen = CreatePen( lineStyle,	pLineWidth,	color)
	IF hPen <= 0 THEN GOSUB Error
	hOldPen = SelectObject (pDC, hPen)

'Create and Select a new Brush
	IF fillStyle THEN
		IF fillStyle = $$FillStyleSolid THEN
			hBrush = CreateSolidBrush (fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		ELSE
			hatchStyle = fillStyle{4,0}
			hBrush = CreateHatchBrush (hatchStyle, fillColor)
			IF hBrush <= 0 THEN GOSUB Error
			hOldBrush = SelectObject (pDC, hBrush)
		END IF
	END IF

'calc px and py printer positions, given xy values are in 1/100", 100 = 1"
	px = INT(x * pHorzPPI / 100.0)
	py  = INT(y	* pVertPPI / 100.0)
	pr = INT(r * pHorzPPI / 100.0)

'calc bounding rect for circle
	px1 = px - pr
	px2 = px + pr
	py1 = py - pr
	py2 = py + pr

'Adjust for the printing page offset.
	px1 = px1 - offsetLeft
	px2 = px2 - offsetLeft
	py1 = py1 - offsetTop
	py2 = py2 - offsetTop

'calc endpoints of two radials
	rx1 = px + pr * cos(angleStart# * $DEGTORAD)
	ry1 = py + pr * sin(angleStart# * $DEGTORAD)
	rx2 = px + pr * cos(angleEnd# * $DEGTORAD)
	ry2 = py + pr * sin(angleEnd# * $DEGTORAD)

'Adjust for the printing page offset.
	rx1 = rx1 - offsetLeft
	ry1 = ry1 - offsetTop
	rx2 = rx2 - offsetLeft
	ry2 = ry2 - offsetTop

'Draw pie using Pie () API call
	ret = Pie (pDC, px1, py1, px2, py2, rx1, ry1, rx2, ry2)
	IF ret <= 0 THEN GOSUB Error

'select default pen back into printer DC, then delete pen
    SelectObject (pDC, hOldPen)
    DeleteObject (hPen)

'select default brush back into printer DC, then delete brush
    SelectObject (pDC, hOldBrush)
    DeleteObject (hBrush)

	RETURN ($$TRUE)

' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hPen THEN
    SelectObject (pDC, hOldPen)
    DeleteObject (hPen)
	END IF

'select default brush back into printer DC, then delete brush
	IF hBrush THEN
    SelectObject (pDC, hOldBrush)
    DeleteObject (hBrush)
	END IF

	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ############################
' #####  XprDrawText ()  #####
' ############################
'
'	/*
'	[XprDrawText]
' Description = The XprDrawText function prints a text string.
' Function    = error = XprDrawText (text$, textFlags, xpos, @ypos, fontName$, fontHeight)
' ArgCount    = 6
'	Arg1        = text$ : Text string to print.
'	Arg2        = textFlags : Text style flags to indicate font properties and text justification on page. One font weight textFlag can be OR'd with one or both text style flags
' Arg3        = xPos : x-position of text. The x and y positions are given in 1/100" or 100 = 1".
'	Arg4        = yPos : y-position of text. The y position of the next line is returned which is useful for printing rows of text.
' Arg5        = fontName$ : Font name; eg, "arial", "fixedsys". The default font is "times new roman".
'	Arg6        = fontHeight : Height of font in points, 1 pt = 1/72".
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    = See xpr.dec for text flag constants.
'	Examples    = text$ = "Protect your privacy. Clean up your tracks."<br>ypos = 150<br>XprDrawText (text$, $$TEXT_NORMAL, 100, @ypos, "arial", 24)
'	*/
'
FUNCTION  XprDrawText (text$, textFlags, xpos, @ypos, fontName$, fontHeight)
	SHARED  pHorzPPI,	 pVertPPI,	 pMaxWidth,  pMaxHeight,  pDC
	SHARED  offsetRight,  offsetLeft,  offsetTop,  offsetBottom
	SHARED  psHeight,  psWidth
	SSHORT  ret
	SHARED  tabValue
	POINT  textSize
'
' make sure a pDC has been created by XprStartDocument()
'
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
		RETURN 0
	END IF
'
'make sure that we have something to print
	IFZ text$ THEN
		error = ERROR ($$ErrorObjectArgument << 8 OR $$ErrorNatureEmpty)
		RETURN 0
	END IF

' create a font
		IFZ fontName$ THEN fontName$ = "times new roman"
		IF (fontHeight < 6) THEN fontHeight = 6
'
' font heights are in points where 1 point = 1/72"
		fontH# = fontHeight
		fontH# = fontH#/72.0 * pVertPPI
'
' scale font based on any differences between horz and vert PPI
'		hfactor# = pVertPPI/ DOUBLE(pHorzPPI)
'		fontH = INT(fontH# * hfactor#)
'
' calc fontWidth
		wfactor# = pHorzPPI/ DOUBLE(pVertPPI)
		fontWidth=INT(fontH#/2.5*wfactor#)
'
		weight = 0
		IF textFlags AND $$TEXT_THIN				THEN weight = 100
		IF textFlags AND $$TEXT_EXTRALIGHT	THEN weight = 200
		IF textFlags AND $$TEXT_LIGHT				THEN weight = 300
		IF textFlags AND $$TEXT_NORMAL			THEN weight = 400
		IF textFlags AND $$TEXT_MEDIUM			THEN weight = 500
		IF textFlags AND $$TEXT_SEMIBOLD		THEN weight = 600
		IF textFlags AND $$TEXT_BOLD				THEN weight = 700
		IF textFlags AND $$TEXT_EXTRABOLD		THEN weight = 800
		IF textFlags AND $$TEXT_HEAVY				THEN weight = 900
'
' set italic
		italic = 0
		IF (textFlags AND $$TEXT_ITALIC) THEN italic = 1
'
' set underline
		underline 			= 0
		IF (textFlags AND $$TEXT_UNDERLINED) THEN underline = 1
		strikeout 			= 0
		charset 				= $$ANSI_CHARSET
		outputPrecision = $$OUT_STROKE_PRECIS
		clipPrecision 	= $$CLIP_STROKE_PRECIS
		quality 				= $$DRAFT_QUALITY
		pitchAndFamily 	=	0
'
		fontH = INT(fontH#)
		hFont = CreateFontA (fontH, fontWidth, 0, 0, weight, italic, underline, strikeout, charSet, outputPrecision, clipPrecision, quality, pitchAndFamily, &fontName$)
		IFZ hFont THEN GOSUB Error
		hOldFont = SelectObject (pDC, hFont)
'
' calc new printer x and y positions, x and y values are in 1/100", 100 = 1"
		x = INT(xpos * pHorzPPI / 100.0)
		y = INT(ypos * pVertPPI / 100.0)
'
' adjust for the printing page offset.
		x = x - offsetLeft
		IF (x < 0) THEN x = 0
'
		y = y - offsetTop
		IF (y < 0) THEN y = 0
'
		maxX = pMaxWidth - INT(marRight	* pHorzPPI)
		maxY = pMaxHeight - INT(marBottom * pVertPPI)

' justify text if necessary
		IF ((textFlags AND $$TEXT_JUSTIFYCENTER) = $$TEXT_JUSTIFYCENTER) || ((textFlags AND $$TEXT_JUSTIFYRIGHT) = $$TEXT_JUSTIFYRIGHT) THEN

' calc width of line in printer pixels
			lineWidth = psWidth - ((marLeft + marRight)*pHorzPPI/100.0)

' get width of current text string
			IFZ GetTextExtentPoint32A (pDC, &text$, LEN(text$), &textSize) THEN GOSUB Error
			twidth = textSize.x

			IF twidth < lineWidth THEN
				IF (textFlags AND $$TEXT_JUSTIFYCENTER) = $$TEXT_JUSTIFYCENTER THEN
					x = x + lineWidth/2.0 - twidth/2.0
				END IF
				IF (textFlags AND $$TEXT_JUSTIFYRIGHT) = $$TEXT_JUSTIFYRIGHT THEN
					x = x + lineWidth - twidth
				END IF
			END IF
		END IF

'	print the text using TextOutA
		IFZ TextOutA (pDC, x, y, &text$, SIZE(text$)) THEN GOSUB Error
'
' calc new ypos return value
' change linespace if font is courier new due to underscore printing issue
		IF LCASE$(fontName$) = "courier new" + CHR$(0) THEN
			lineSpace! = INT(fontH / DOUBLE(pVertPPI) * 100) + 1
		ELSE
			lineSpace! = fontH / DOUBLE(pVertPPI) * 100
		END IF
'
		ypos = ypos + lineSpace!
'
' select default font back into printer DC, then delete new font
		SelectObject (pDC, hOldFont)
		DeleteObject (hFont)

		RETURN ($$TRUE)

' ***** Error *****
SUB Error
'select default pen back into printer DC, then delete pen
	IF hFont THEN
		SelectObject (pDC, hOldFont)
		DeleteObject (hFont)
	END IF

	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB

END FUNCTION
'
'
' #####################################
' #####  XprGetDefaultPrinter ()  #####
' #####################################
'
'	/*
'	[XprGetDefaultPrinter]
' Description = The XprGetDefaultPrinter function returns the default printer name from the windows initialization file win.ini.
' Function    = error = XprGetDefaultPrinter (@defPrinter$, @driver$, @port$)
' ArgCount    = 3
' Arg1        = defPrinter$ : The returned default printer name.
' Arg2        = driver$ : The returned default printer driver name.
' Arg3        = port$ : The returned default printer port name.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     =
'	See Also    =
'	Examples    = XprGetDefaultPrinter (@defPrinter$, @driver$, @port$)<br>' defPrinter$ = "BJC-4200"<br>' driver$= "CBJ95"<br>' port$ = "LPT1:"
'	*/
'
FUNCTION  XprGetDefaultPrinter (@defPrinter$, @driver$, @port$)

' get Printer Profile String
' GetProfileStringA searches the WIN.INI section specified in the first argument for the key specified in
'   the second argument. It will then return the value for the key specified in the fourth argument unless
'   the specified key in the specifed section was not located. In this event, the value returned in the
'   fouth argument will be equal to that in the third default argument. The fifth argument provides the
'   length of the string passed as the fourth argument.
'
	appName$ = "windows"
	keyName$ = "device"
	default$ = ""
	result$  = NULL$(1024)
	size     = LEN(result$)
'
	bytes = GetProfileStringA (&appName$, &keyName$, &default$, &result$, size)
'
	IF (bytes <= 0) THEN
		error = ERROR ($$ErrorObjectFunction << 8 OR $$ErrorNatureFailed )
		RETURN 0
	END IF

	profile$ = CSIZE$ (result$)

'Parse default printer name
	j = INSTR(profile$, ",", 1)
	defPrinter$ = LEFT$(profile$, j-1)

'Parse driver
	j = j + 1
	k = INSTR(profile$, ",", j)
	driver$ = MID$(profile$, j, k-j)

'Parse port
	port$ = RIGHT$(profile$, LEN(profile$)-k)

 	RETURN ($$TRUE)

END FUNCTION
'
'
' ###################################
' #####  XprGetLinesPerPage ()  #####
' ###################################
'
'	/*
'	[XprGetLinesPerPage]
' Description = The XprGetLinesPerPage function returns the maximum lines of text per page based on a specified font height.
' Function    = error = XprGetLinesPerPage (fontHeight, @lpp)
' ArgCount    = 2
' Arg1        = fontHeight : Font height.
' Arg2        = lpp : The returned lines per page. This value will depend on the current default paper size.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = Call XprGetLinesPerPage after calling XprStartDocument.
'	See Also    =
'	Examples    = XprGetLinesPerPage (10, @lpp)<br>' lpp = 78 (paper size = A4)
'	*/
'
FUNCTION  XprGetLinesPerPage (fontHeight, @lpp)

SHARED pMaxHeight, pVertPPI, pDC

	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
 		RETURN 0
	END IF

	IFZ fontHeight THEN
		error = ERROR ($$ErrorObjectArgument << 8 OR $$ErrorNatureEmpty)
 		RETURN 0
	END IF

	lpp = INT((pMaxHeight/DOUBLE(pVertPPI))/DOUBLE((fontHeight/72.0)))
	RETURN ($$TRUE)

END FUNCTION
'
'
' #####################################
' #####  XprGetPrintingOffset ()  #####
' #####################################
'
'	/*
'	[XprGetPrintingOffset]
' Description = The XprGetPrintingOffset function returns a printer's offset margins. These are the non-printable margins on all sides of the paper.
' Function    = error = XprGetPrintingOffset (prtName$, @right, @left, @top, @bottom)
' ArgCount    = 5
' Arg1        = prtName$ : Printer name. If argument is empty, then the default printer is used.
' Arg2        = right : The returned minimum right margin.
' Arg3        = left : The returned minimum left margin.
' Arg4        = top : The returned minimum top margin.
' Arg5        = bottom : The returned minimum bottom margin.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0. To get extended error information, call ERROR().
' Remarks     = Return values are in 1/100" units or 100 = 1".
'	See Also    =
'	Examples    = XprGetPrintingOffset ("", @right, @left, @top, @bottom)<br>' right = 14<br>' left = 14<br>' top = 12<br>' bottom = 66
'	*/
'
FUNCTION  XprGetPrintingOffset (prtName$, @right, @left, @top, @bottom)
	POINT gpps, gpo
'
	IFZ prtName$ THEN
' get printer profile string
		appName$ = "windows"
		keyName$ = "device"
		default$ = ""
		result$  = SPACE$(1024)
		size     = LEN(result$)
'
		bytes = GetProfileStringA (&appName$, &keyName$, &default$, &result$, SIZE(result$))
		IF (bytes <= 0) THEN
			error = ERROR ($$ErrorObjectFunction << 8 OR $$ErrorNatureFailed )
			RETURN 0
		END IF

		profile$ = CSIZE$ (result$)

		j = INSTR(profile$, ",", 1)
		prtName$ = LEFT$(profile$, j-1)
	END IF

' create a printer device context pDC
	prDC = CreateDCA (0, &prtName$, 0, 0)
	IFZ prDC THEN
		error = ERROR ($$ErrorObjectFunction << 8 OR $$ErrorNatureFailed)
 		RETURN 0
	END IF

' retrieve the number of pixels-per-logical-inch in the
' horizontal and vertical directions for the printer upon which
' the bitmap will be printed.
	pHorzPPI = GetDeviceCaps (prDC, $$LOGPIXELSX)
	pVertPPI = GetDeviceCaps (prDC, $$LOGPIXELSY)
'
' retrieve currently selected printable paper width/height in printer pixels
'	pMaxWidth =  GetDeviceCaps (prDC, $$HORZRES)  '2880 for A4 paper on a Canon BJC-4200
	pMaxHeight = GetDeviceCaps (prDC, $$VERTRES)		'3092?
'
' get physical paper size
	IF Escape (prDC, $$GETPHYSPAGESIZE, 0, 0, &gpps) <= 0 THEN GOSUB Error
	psHeight = gpps.y
'	psWidth = gpps.x
'
' get the non-printing offset edge around paper.
	IF Escape (prDC, $$GETPRINTINGOFFSET, 0, 0, &gpo) <= 0 THEN GOSUB Error
	right 		= INT(gpo.x / DOUBLE(pHorzPPI) * 100) + 1
	left  		= INT(gpo.x	/ DOUBLE(pHorzPPI) * 100) + 1
	top  			= INT(gpo.y / DOUBLE(pVertPPI) * 100) + 1
	topOffset = gpo.y
	bottom 		= INT((psHeight - topOffset - pMaxHeight)/ DOUBLE(pVertPPI) * 100) + 1
'
' delete printer DC
	DeleteDC (prDC)
'
	RETURN ($$TRUE)
'
' ***** Error *****
SUB Error
	IF prDC THEN
		DeleteDC (prDC)
	END IF
	XstGetSystemError (@sysError)
	XstSystemErrorToError (sysError, @error)
	lastErr = ERROR (error)
 	RETURN 0
END SUB
END FUNCTION
'
'
' ##################################
' #####  XprGetPrinterYpos ()  #####
' ##################################
'
'	/*
'	[XprGetPrinterYpos]
' Description = The XprGetPrinterYpos function returns the current y-position on the page in 1/100" units.
' Function    = error = XprGetPrinterYpos (@pyPos)
' ArgCount    = 1
' Arg1        = pyPos : The returned current y page position (as DOUBLE).
'	Return      =
' Remarks     = Call XprGetPrinterYpos after calling XprStartDocument.
'	See Also    =
'	Examples    = XprGetPrinterYpos (@y)
'	*/
'
FUNCTION  XprGetPrinterYpos (DOUBLE pyPos)

	SHARED DOUBLE pyposition
	pyPos = pyposition

END FUNCTION
'
'
' ###############################
' #####  XprGetTabValue ()  #####
' ###############################
'
'	/*
'	[XprGetTabValue]
' Description = The XprGetTabValue function returns the current number of space characters used to replace a tab CHR$(9).
' Function    = XprGetTabValue (@tabV)
' ArgCount    = 1
' Arg1        = tabV : Returned current tab spacing.
'	Return      =
' Remarks     =
'	See Also    = See XprSetTabValue.
'	Examples    =
'	*/
'
FUNCTION  XprGetTabValue (@tabV)
	SHARED tabValue
	tabV = tabValue
END FUNCTION
'
'
' ################################
' #####  XprSetFillStyle ()  #####
' ################################
'
'	/*
'	[XprSetFillStyle]
' Description = The XprSetFillStyle function sets a fillstyle and a fillcolor for graphic objects that can be filled: boxes, ellipses, circles, and pies.
' Function    = XprSetFillStyle (style, color)
' ArgCount    = 2
' Arg1        = style : Fill style flag. $$FillStylehatch can be OR'd with the hatchstyles.
' Arg2        = color : Fill color.
'	Return      =
' Remarks     =
'	See Also    =
'	Examples    =
'	*/
'
' fillstyles
'		$$FillStyleNone  = 0x0
'		$$FillStyleSolid = 0x10
'		$$FillStyleHatch = 0x20
'
' Hatch Styles
'		$$HS_HORIZONTAL = 0              '  -----		Horizontal hatch
'		$$HS_VERTICAL = 1                '  |||||		Vertical hatch
'		$$HS_FDIAGONAL = 2               '  \\\\\		A 45-degree downward, left-to-right hatch
'		$$HS_BDIAGONAL = 3               '  /////		A 45-degree upward, left-to-right hatch
'		$$HS_CROSS = 4                   '  +++++		Horizontal and vertical cross-hatch
'		$$HS_DIAGCROSS = 5               '  xxxxx		45-degree crosshatch
'
FUNCTION  XprSetFillStyle (style, color)
	SHARED fillStyle, fillColor
	fillStyle = style
	fillColor = color
END FUNCTION
'
'
' ###############################
' #####  XprSetTabValue ()  #####
' ###############################
'
'	/*
'	[XprSetTabValue]
' Description = The XprSetTabValue function sets the current number of space characters used to replace a tab CHR$(9).
' Function    = XprSetTabValue (tabV)
' ArgCount    = 1
' Arg1        = tabV : Tab spacing.
'	Return      =
' Remarks     =
'	See Also    = See XprGetTabValue.
'	Examples    = XprSetTabValue (5)
'	*/
'
FUNCTION  XprSetTabValue (tabV)
	SHARED tabValue
	tabValue = tabV
END FUNCTION
'
'
' ################################
' #####  XprSetTextColors () #####
' ################################
'
'	/*
'	[XprSetTextColors]
' Description = The XprSetTextColors function sets the printed text color and background color. This function must be called before calling an XprText function but after XprStartDocument.
' Function    = error = XprSetTextColors (textColor, backColor)
' ArgCount    = 2
' Arg1        = textColor : Text color.
' Arg2        = backColor : Background color.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = Use -1 to keep current text color or background color.
'	See Also    =
'	Examples    = XprSetTextColors ($$LightRed, -1)<br>XprSetTextColors (RGB(255, 255, 0), 0x00FF00)
'	*/
'
FUNCTION  XprSetTextColors (textColor, backColor)
	SHARED  pDC
'
	IFZ pDC THEN
		error = ERROR ($$ErrorObjectData << 8 OR $$ErrorNatureNotInitialized)
 		RETURN
	END IF
'
	IF textColor >= 0 THEN
		IF SetTextColor (pDC, textColor) = $$CLR_INVALID THEN RETURN
	END IF
'
	IF backColor >= 0 THEN
		IF SetBkColor(pDC, backColor) = $$CLR_INVALID THEN RETURN
	END IF
'
	RETURN ($$TRUE)
'
END FUNCTION
'
' ##########################
' #####  XprLPrint ()  #####
' ##########################
'
'	/*
'	[XprLPrint]
' Description = The XprLPrint function prints a text string to the default printer on LPT1.
' Function    = error = XprLPrint (text$)
' ArgCount    = 1
' Arg1        = text$ : Text string to print.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function. This function only works under win95/win98.
'	See Also    =
'	Examples    = XprLPrint ("What a day for a daydream.")
'	*/
'
FUNCTION  XprLPrint (text$)
	IFZ text$ THEN RETURN
	prt$ = "LPT1"
	pfile = OPEN (prt$, $$WR)
	IF pfile <= 0 THEN RETURN
	PRINT[pfile], text$
	CLOSE (pfile)
	RETURN ($$TRUE)
END FUNCTION
'
' ###################################
' #####  XprPrintFileToLPT1 ()  #####
' ###################################
'
'	/*
'	[XprPrintFileToLPT1]
' Description = The XprPrintFileToLPT1 function prints a text file to the default printer on LPT1.
' Function    = error = XprPrintFileToLPT1 (fileName$, linesPerPage, EscSequence$)
' ArgCount    = 3
' Arg1        = fileName$ : File name of text file to send to printer.
' Arg2        = linesPerPage : Number of lines to print per page. Default is 62.
' Arg3        = EscSequence$ : An initialization escape code sequence string.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function.
'	See Also    = See XprLPrint.
'	Examples    = XprPrintFileToLPT1 ("c:/xblite/readme.txt", 64, CHR$(27) + CHR$(77)) ' 12 cpi
'	*/
'
' Some commonly used escape codes include:
' Reset (27, 64)
' Set page length in lines (27, 67, n - where n is a number from 1 to 127)
' Carriage return (13)
' Line feed (10)
' Form feed (12)
' Select 1/8-inch line spacing (27, 48)
' 10 cpi (27, 80)
' 12 cpi (27, 77)
' Select bold font (27, 69)
' Cancel bold font (27, 70)
' Select italic font (27, 52)
' Cancel italic font (27, 53)
' Turn underline on/off (27, 45, n - where n equals 49=ON or 48=OFF)
' Select condensed print (15)
' Cancel condensed print (18)
' USE : PRINT[pfile], CHR$(27) + CHR$(80) ' print at 10 cpi
'
FUNCTION  XprPrintFileToLPT1 (fileName$, linesPerPage, EscSequence$)

	IFZ linesPerPage THEN linesPerPage = 62
	IFZ fileName$ THEN RETURN 0
	XstLoadStringArray (fileName$, @text$[])
	IFZ text$[] THEN RETURN 0

	prt$ = "LPT1"
	pfile = OPEN (prt$, $$WR)
	IF pfile <= 0 THEN RETURN 0

'set lines per page
	PRINT[pfile], CHR$(27) + CHR$(67) + CHR$(linesPerPage);

'set an intialization escape sequence
	IF EscSequence$ THEN
		PRINT[pfile], EscSequence$;
	END IF

'print to LPT1
	upper = UBOUND(text$[])
	FOR i = 0 TO upper
		text$ = text$[i]
		PRINT[pfile], text$
'		INC count
'		IF count > linesPerPage THEN
'			PRINT[pfile], CHR$(12)
'			count = 0
'		END IF
	NEXT i

'reset printer
	PRINT[pfile], CHR$(27) + CHR$(64)

'print form feed to eject last page
	PRINT[pfile], CHR$(12)

'close lpt1
	CLOSE (pfile)

	RETURN ($$TRUE)
END FUNCTION
'
' #####################################
' #####  XprPrintFileToMsHtml ()  #####
' #####################################
'
'	/*
'	[XprPrintFileToMsHtml]
' Description = The XprPrintFileToMsHtml function prints an html file to the default printer. This function will work if IE4.0+ (mshtml.dll) is installed.
' Function    = error = XprPrintFileToMsHtml (fileName$)
' ArgCount    = 1
' Arg1        = fileName$ : File name of html file to send to printer.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function.
'	See Also    =
'	Examples    = XprPrintFileToMsHtml ("c:\\xblite\\myfile.html")
'	*/
'
FUNCTION  XprPrintFileToMsHtml (fileName$)
	IFZ fileName$ THEN RETURN 0
	XstGetFileAttributes (fileName$, @attributes)
	IF attributes = $$FileNonexistent THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
	IF (RIGHT$(fileName$,3) = "htm") || (RIGHT$(fileName$,4) = "html") THEN
		basePath$ = "/windows"											'make sure mshtml.dll exists
		filter$ = "mshtml.dll"
		XstFindFiles (@basePath$, @filter$, $$TRUE, @file$[])
		IF file$[] THEN
			str$ = ":rundll32.exe " + file$[0] + ",PrintHTML \"" + fileName$ +"\""
			SHELL (str$)
			RETURN ($$TRUE)
		END IF
	END IF
	RETURN 0
END FUNCTION
'
'
' #######################################
' #####  XprPrintFileToNetscape ()  #####
' #######################################
'
'	/*
'	[XprPrintFileToNetscape]
' Description = The XprPrintFileToNetscape function prints an html file to the default printer. This function will work if Netscape3.0+ (netscape.exe) is installed.
' Function    = error = XprPrintFileToNetscape (fileName$)
' ArgCount    = 1
' Arg1        = fileName$ : File name of html file to send to printer.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function.
'	See Also    =
'	Examples    = XprPrintFileToNetscape ("c:/xblite/myfile.html")
'	*/
'
FUNCTION  XprPrintFileToNetscape (fileName$)
	IFZ fileName$ THEN RETURN 0
	XstGetFileAttributes (fileName$, @attributes)
	IF attributes = $$FileNonexistent THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
	IF RIGHT$(fileName$,3) = "htm" || RIGHT$(fileName$,4) = "html" THEN
		basePath$ = "/"											'make sure netscape.exe exists
		filter$ = "netscape.exe"
		XstFindFiles (@basePath$, @filter$, $$TRUE, @file$[])
		IF file$[] THEN
			str$ = ":" + file$[0] + " /print(\"" + fileName$ +"\")"
			SHELL (str$)
			RETURN ($$TRUE)
		END IF
	END IF
	RETURN 0
END FUNCTION
'
'
' ######################################
' #####  XprPrintFileToNotePad ()  #####
' ######################################
'
'	/*
'	[XprPrintFileToNotePad]
' Description = The XprPrintFileToNotePad function prints a text file to the default printer using notepad.exe.
' Function    = error = XprPrintFileToNotePad (fileName$)
' ArgCount    = 1
' Arg1        = fileName$ : File name of text file to send to printer.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function.
'	See Also    =
'	Examples    = XprPrintFileToNotePad ("c:/xblite/myfile.html")
'	*/
'
FUNCTION  XprPrintFileToNotePad (fileName$)
	IFZ fileName$ THEN RETURN 0
	XstGetFileAttributes (fileName$, @attributes)
	IF attributes = $$FileNonexistent THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
	str$ = ":c:\\windows\\notepad.exe /p " + fileName$
	SHELL(str$)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ###########################################
' #####  XprPrintFileToShellExecute ()  #####
' ###########################################
'
'	/*
'	[XprPrintFileToShellExecute]
' Description = The XprPrintFileToShellExecute function prints a text file to the default printer using ShellExecute. ShellExecute will try to print the selected text file using whichever	application is associated with the file's extension. *.txt >>> notepad, *.htm/html >>> web browser, IE or NS or ?, *.doc >>> winword.exe.
' Function    = error = XprPrintFileToShellExecute (fileName$)
' ArgCount    = 1
' Arg1        = fileName$ : File name of text file to send to printer.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function. The line	IMPORT "shell32" must be in the PROLOG.
'	See Also    =
'	Examples    = IMPORT "shell32"<br>'<br>FUNCTION Entry ()<br>XprPrintFileToShellExecute ("c:/xblite/myfile.doc")<br>END FUNCTION
'	*/
'
FUNCTION  XprPrintFileToShellExecute (fileName$)
	IFZ fileName$ THEN RETURN 0
	XstGetFileAttributes (fileName$, @attributes)
	IF attributes = $$FileNonexistent THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
  directory$ = "/"
	ret = ShellExecuteA (hwnd, &"print", &fileName$, 0, &directory$, $$SW_HIDE)
	IF ret <= 32 THEN RETURN 0
	RETURN ($$TRUE)
END FUNCTION
'
'
' ######################################
' #####  XprPrintFileToWordPad ()  #####
' ######################################
'
'	/*
'	[XprPrintFileToWordPad]
' Description = The XprPrintFileToWordPad function prints a text file to the default printer using wordpad.exe. This prints text using WordPad's default margins.
' Function    = error = XprPrintFileToWordPad (fileName$)
' ArgCount    = 1
' Arg1        = fileName$ : File name of text file to send to printer.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function.
'	See Also    =
'	Examples    = XprPrintFileToWordPad ("c:/xblite/myfile.html")
'	*/
'
FUNCTION  XprPrintFileToWordPad (fileName$)
	IFZ fileName$ THEN RETURN 0
	IF attributes = $$FileNonexistent THEN
		error = ERROR ($$ErrorObjectFile << 8 OR $$ErrorNatureNonexistent)
		RETURN 0
	END IF
	str$ = ":C:\\Program Files\\Accessories\\WORDPAD.EXE /p " + fileName$
	SHELL(str$)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ##############################
' #####  XprTestLPrint ()  #####
' ##############################
'
FUNCTION  XprTestLPrint ()

PRINT "XprTestLPrint"

'each use of XprLPrint automatically ends with a linefeed.
'test escape sequences

	text$ = "This is your lucky day."

	XprLPrint (text$)																		' normal text is 10 cpi
	XprLPrint (CHR$(27) + CHR$(80) + text$) 						' 10 cpi
	XprLPrint (CHR$(27) + CHR$(77) + text$) 						' 12 cpi
	XprLPrint (CHR$(27) + CHR$(69) + text$) 						' bold print on
	XprLPrint (CHR$(27) + CHR$(70)) 										' bold print off
	XprLPrint (CHR$(27) + CHR$(52) + text$) 						' italic print on
	XprLPrint (CHR$(27) + CHR$(53)) 										' italic print off
	XprLPrint (CHR$(27) + CHR$(45) + CHR$(49) + text$) 	' underline print on
	XprLPrint (CHR$(27) + CHR$(45) + CHR$(48)) 					' underline print off
	XprLPrint (CHR$(27) + CHR$(112) + CHR$(49) + text$) ' proportional print on
	XprLPrint (CHR$(27) + CHR$(112) + CHR$(48)) 				' proportional print off
	XprLPrint (CHR$(27) + CHR$(87) + CHR$(49) + text$) 	' wide print on
	XprLPrint (CHR$(27) + CHR$(87) + CHR$(48)) 					' wide print off
	XprLPrint (CHR$(15) + text$)												' condensed text on
	XprLPrint (CHR$(18))																' condensed text off

'select font
	XprLPrint (CHR$(27) + CHR$(107) + CHR$(0) + text$) 	' roman font
	XprLPrint (CHR$(27) + CHR$(107) + CHR$(1) + text$) 	' san serif font
	XprLPrint (CHR$(27) + CHR$(107) + CHR$(2) + text$) 	' courier font
	XprLPrint (CHR$(27) + CHR$(107) + CHR$(3) + text$) 	' prestige font
	XprLPrint (CHR$(27) + CHR$(107) + CHR$(4) + text$) 	' script font

	XprLPrint (CHR$(27) + CHR$(107) + CHR$(0)) 					' roman font

'master select
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(0) + text$) 	' pica
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(1) + text$) 	' elite
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(2) + text$) 	' proportional
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(4) + text$) 	' condensed
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(8) + text$) 	' emphasized
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(16) + text$) 	' double strike
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(32) + text$) 	' double wide
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(64) + text$) 	' italic
	XprLPrint (CHR$(27) + CHR$(33) + CHR$(128) + text$) ' underline

	XprLPrint (CHR$(27) + CHR$(33) + CHR$(0)) 					' pica

'select character style
	XprLPrint (CHR$(27) + CHR$(113) + CHR$(0) + text$) 	' normal character style
	XprLPrint (CHR$(27) + CHR$(113) + CHR$(1) + text$) 	' outline character style
	XprLPrint (CHR$(27) + CHR$(113) + CHR$(2) + text$) 	' shadow character style
	XprLPrint (CHR$(27) + CHR$(113) + CHR$(3) + text$) 	' outline & shadow character style
	XprLPrint (CHR$(27) + CHR$(113) + CHR$(0)) 					' normal character style

'print special characters
	text$ = ""
	FOR i = 33 TO 254
		text$ = text$ + CHR$(i) + CHR$(32)
		INC count
		IF count > 34 THEN
			XprLPrint (text$)
			text$ = ""
			count = 0
		END IF
	NEXT i
	XprLPrint (text$)
	XprLPrint (CHR$(27) + CHR$(64)) 										' reset printer
	XprLPrint (CHR$(12))																' form feed

END FUNCTION
'
'
' #####################################
' #####  XprTestTextFunctions ()  #####
' #####################################
'
' PURPOSE : To demonstrate text printing functions.
'
' textFlags constants (do not uncomment, for example purposes)
'
' $$TEXT_DEFAULT
' $$TEXT_THIN
' $$TEXT_EXTRALIGHT
' $$TEXT_LIGHT
' $$TEXT_NORMAL
' $$TEXT_MEDIUM
' $$TEXT_SEMIBOLD
' $$TEXT_BOLD
' $$TEXT_EXTRABOLD
' $$TEXT_HEAVY
'
' $$TEXT_ITALIC
' $$TEXT_UNDERLINED

' $$TEXT_JUSTIFYCENTER
' $$TEXT_JUSTIFYRIGHT
'
' text mode constants only use with XprTextFile()
'
' $$TEXT_WORDWRAPOFF
' $$TEXT_WORDWRAPON
'
FUNCTION  XprTestTextFunctions ()

	DOUBLE marTop

' *****  XprStartDocument() *****
' this is used with XprTextArray(), XprTextFile(), XprTextLine() and
' drawing functions.
' this function must be called first and only once before calling
' XprEndDocument().
'
	JobName$ = "XprTestTextFunctions"
	PrtName$ = ""
	ret = XprStartDocument(PrtName$, JobName$)
	PRINT "XprStartDocument() return = "; ret

' *****  XprSetTextColors()  *****
'
'	XprSetTextColors (textColor, backColor)
' Note: backColor should be set to $$White for colored text on white background.
' 			you can use -1 to keep current text color or background color
'
' *****  XprTextLine()  *****
'
	text$ = "Change is rarely more than glacial in sumo."

	fontHeight = 12
	marTop = 50
	marLeft = 100
	marRight = 100
	marBottom = 100
	fontName$ = "Times New Roman"
	textFlags = $$TEXT_NORMAL OR $$TEXT_ITALIC
'
	ret = XprSetTextColors ($$LightRed, $$LightYellow)
	PRINT "XprSetTextColors() return = "; ret
	ret = XprTextLine (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
	PRINT "XprTextLine () return = "; ret

	ret = XprSetTextColors (RGB(0, OxFF, 0), $$White)
	textFlags = $$TEXT_NORMAL OR $$TEXT_JUSTIFYCENTER
	ret = XprTextLine (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
	PRINT "XprTextLine () return = "; ret

	ret = XprSetTextColors ($$BrightViolet, -1)
	textFlags = $$TEXT_HEAVY OR $$TEXT_JUSTIFYRIGHT
	ret = XprTextLine (text$, textFlags, marLeft, @marTop, 150, marBottom, fontName$, fontHeight)
	PRINT "XprTextLine () return = "; ret
'
'
' a blank line is printed if text$ = ""
'
	XprTextLine ("", textFlags, marLeft, @marTop, marRight, marBottom, fontName$, fontHeight)
'
	ret = XprSetTextColors ($$Black, -1)
	textFlags = $$TEXT_BOLD OR $$TEXT_UNDERLINED
	XprTextLine (text$, textFlags, 150, @marTop, marRight, marBottom, "Arial", 20)
'
' *****  XprTextParagraph()  *****
'
	text$ = "This printer library is specifically tailored for XBasic, allowing printing of text in various fonts, fontheights, and styles. Features include: The ability to print lines, paragraphs or entire files with or without wordwrapping. It also includes functions for printing graphics and for printing BMP images, windows, or the screen."
	XprSetTextColors ($$Black, $$White)
	marRight = 100
	ret = XprTextParagraph (text$, $$TEXT_NORMAL, marLeft, @marTop, marRight, marBottom, "arial", 14)
'
	PRINT "XprTextParagraph () return = "; ret

	ret = XprTextParagraph (text$, $$TEXT_BOLD, 150, @marTop, 450, marBottom, "arial", 10)
'
	PRINT "XprTextParagraph () return = "; ret
'
'
' *****  XprSetTabValue()  *****
'
	XprSetTabValue (5)
'
' ***** XprGetTabValue ()  *****
'
	XprGetTabValue (@tVal)
	PRINT "XprGetTabValue () return = "; tVal
'
' *****  XprGetPrintingOffset()  *****
'
	XprGetPrintingOffset (prtName$, @right, @left, @top, @bottom)
	PRINT "right offset = "; right
	PRINT "left offset = "; left
	PRINT "top offset = "; top
	PRINT "bottom offset = "; bottom
'
'
' *****  XprTextArray()  *****
'
	REDIM text$[9]
'
	text$[0] = "All work and no play make jack a dull boy."
	text$[1] = "	All work and no play make jack a dull boy."
	text$[2] = "		All work and no play make jack a dull boy."
	text$[3] = "			All work and no play make jack a dull boy."
	text$[4] = "				All work and no play make jack a dull boy."
	text$[5] = "				All work and no play make jack a dull boy."
	text$[6] = "			All work and no play make jack a dull boy."
	text$[7] = "		All work and no play make jack a dull boy."
	text$[8] = "	All work and no play make jack a dull boy."
	text$[9] = "All work and no play make jack a dull boy."
'

	marLeft = 100
	marRight = 100
	ret = XprTextArray (@text$[], $$TEXT_NORMAL, marLeft, @marTop, marRight, marBottom, "Comic Sans MS", 10)
	PRINT "XprTextArray () return = "; ret

' *****  XprTextFile()  *****
'
' Text Mode constants
' $$TEXT_WORDWRAPOFF
' $$TEXT_WORDWRAPON
'
	fileName$ = "/xblite/xpr/sample.txt"
	ret = XprTextFile (fileName$, $$TEXT_BOLD OR $$TEXT_WORDWRAPON, marLeft, @marTop, marRight, marBottom, "Courier New", 10)
	PRINT "XprTextFile () return = "; ret
'
' *****  XprGetLinesPerPage()  *****
	ret= XprGetLinesPerPage (10, @lpp)
	PRINT "XprGetLinesPerPage ret = "; ret, " lpp (at 10pt) = "; lpp

' *****  XprEndDocument()  *****
' You need to use XprEndDocument to end a printing session
'
	ret = XprEndDocument ()
	PRINT "XprEndDocument () return = "; ret


END FUNCTION
'
'
' #########################################
' #####  XprTestGraphicsFunctions ()  #####
' #########################################
'
' PURPOSE : To demonstrate graphics printing functions:
'           XprDrawLine(), XprDrawBox, XprDrawCircle(),
'           XprDrawEllipse, and XprDrawPie().
'
FUNCTION  XprTestGraphicsFunctions ()
'
' *****  XprStartDocument() *****
' this is used with XprTextArray(), XprTextFile(), XprTextLine() and
' drawing functions.
' this function must be called first and only once before calling
' XprEndDocument().
'
	JobName$ = "XprTestGraphicsFunctions"
	PrtName$ = ""
	ret = XprStartDocument(PrtName$, JobName$)
	PRINT "XprStartDocument() return = "; ret
'
' ***** XprDrawLine Test *****

' LineStyles
'  $$LineStyleSolid      = 0
'  $$LineStyleDash       = 1
'  $$LineStyleDot        = 2
'  $$LineStyleDashDot    = 3
'  $$LineStyleDashDotDot = 4

'test line styles
'for line styles to work, lineWidth must be set to zero
	y = 100
	FOR i = 0 TO 4
		ret = XprDrawLine ($$Black, 100, y, 550, y, i, 0)
		y = y + 15
		PRINT "XprDrawLine ret="; ret
	NEXT i

'test line width
	x = 100
	y1 = y + 25
	y2 = y + 75
	FOR i = 0 TO 30 STEP 3
		ret = XprDrawLine ($$LightRed, x, y1, x, y2, $$LineStyleSolid, i)
		x = x + 50
		PRINT "XprDrawLine ret="; ret
	NEXT i

' ***** Test XprDrawBox *****
	x1 = 100
	y1 = y2 + 50
	x2 = x1 + 50
	y2 = y1 + 50
	ret = XprDrawBox ($$LightGreen, x1, y1, x2, y2, $$LineStyleDash, 0)
	PRINT "XprDrawBox ret="; ret

	x1 = x2 + 25
	x2 = x1 + 50
	ret = XprDrawBox ($$LightGreen, x1, y1, x2, y2, $$LineStyleSolid, 3)
	PRINT "XprDrawBox ret="; ret

' FillStyles
'$$FillStyleNone  = 0x0
'$$FillStyleSolid = 0x10
'$$FillStyleHatch = 0x20

'Hatch Styles to be used with $$FillStyleHatch
'$$HS_HORIZONTAL = 0              '  -----		Horizontal hatch
'$$HS_VERTICAL = 1                '  |||||		Vertical hatch
'$$HS_FDIAGONAL = 2               '  \\\\\		A 45-degree downward, left-to-right hatch
'$$HS_BDIAGONAL = 3               '  /////		A 45-degree upward, left-to-right hatch
'$$HS_CROSS = 4                   '  +++++		Horizontal and vertical cross-hatch
'$$HS_DIAGCROSS = 5               '  xxxxx		45-degree crosshatch

	XprSetFillStyle ($$FillStyleSolid, $$LightGreen)
	x1 = x2 + 25
	x2 = x1 + 50
	ret = XprDrawBox ($$LightRed, x1, y1, x2, y2, 0, 6)
	PRINT "XprDrawBox ret="; ret

	XprSetFillStyle ($$FillStyleHatch OR $$HS_VERTICAL, $$LightRed)
	x1 = x2 + 25
	x2 = x1 + 50
	ret = XprDrawBox ($$LightCyan, x1, y1, x2, y2, 0, 12)
	PRINT "XprDrawBox ret="; ret

	XprSetFillStyle ($$FillStyleNone, $$Black)
	x1 = x2 + 25
	x2 = x1 + 50
	ret = XprDrawBox ($$LightMagenta, x1, y1, x2, y2, 0, 18)
	PRINT "XprDrawBox ret="; ret

'test hatch styles
	y1 = y2 + 25
	y2 = y1 + 50
	FOR i = 0 TO 5
		XprSetFillStyle ($$FillStyleHatch OR i, $$Black)
		ret = XprDrawBox ($$Black, i*50+i*10+100, y1, i*50+i*10+50+100, y2, $$LineStyleSolid, 2)
		PRINT "XprDrawBox ret="; ret
	NEXT i

' ***** Test XprDrawCircle *****
	XprSetFillStyle ($$FillStyleNone, $$Black)
	r = 100
	y = y2 + 150
	x = 200
	ret = XprDrawCircle ($$Cyan, r, x, y, $$LineStyleDash, 0)
	PRINT "XprDrawCircle ret="; ret

	r = 50
	x = 400
	XprSetFillStyle ($$FillStyleHatch OR $$HS_HORIZONTAL, $$Black)
	ret = XprDrawCircle ($$Black, r, x, y, $$LineStyleSolid, 2)
	PRINT "XprDrawCircle ret="; ret

	r = 25
	x = 550
	XprSetFillStyle ($$FillStyleSolid, $$LightGrey)
	ret = XprDrawCircle ($$LightGreen, r, x, y, $$LineStyleSolid, 4)
	PRINT "XprDrawCircle ret="; ret

' ***** Test XprDrawEllipse *****
	XprSetFillStyle ($$FillStyleNone, $$Black)
	x1 = 100
	x2 = 300
	y1 = y + 150
	y2 = y1 + 75
	ret = XprDrawEllipse ($$Cyan, x1, y1, x2, y2, $$LineStyleSolid, 2)
	PRINT "XprDrawEllipse ret="; ret

	XprSetFillStyle ($$FillStyleHatch OR $$HS_BDIAGONAL, $$LightMagenta)
	x1 = 350
	x2 = 550
	ret = XprDrawEllipse ($$Black, x1, y1, x2, y2, $$LineStyleSolid, 2)
	PRINT "XprDrawEllipse ret="; ret

	XprSetFillStyle ($$FillStyleSolid, $$LightGrey)
	x1 = 600
	x2 = 675
	y1 = y1 - 100
	ret = XprDrawEllipse ($$LightRed, x1, y1, x2, y2, $$LineStyleSolid, 4)
	PRINT "XprDrawEllipse ret="; ret


' ***** Test XprDrawPie *****
	XprSetFillStyle ($$FillStyleNone, $$Black)
	x = 150
	y = y2 + 75
 	ret = XprDrawPie ($$LightRed, 50, x, y, 360, 270, 0, 2)
	PRINT "XprDraw Pie return="; ret

	XprSetFillStyle ($$FillStyleHatch OR $$HS_HORIZONTAL, $$Black)
 	ret = XprDrawPie ($$LightRed, 50, x, y, 270, 180, 0, 2)
	PRINT "XprDraw Pie return="; ret

	XprSetFillStyle ($$FillStyleSolid, $$LightGrey)
 	ret = XprDrawPie ($$Black, 50, x, y, 180, 90, 0, 2)
	PRINT "XprDraw Pie return="; ret

	XprSetFillStyle ($$FillStyleHatch OR $$HS_FDIAGONAL, $$LightGreen)
 	ret = XprDrawPie ($$LightRed, 50, x, y, 90, 0, 0, 2)
	PRINT "XprDraw Pie return="; ret

' *****  XprEndDocument()  *****
' You need to use XprEndDocument to end a printing session
'
	ret = XprEndDocument()
	PRINT "XprEndDocument() return = "; ret

END FUNCTION
'
'
' ######################################
' #####  XprTestImageFunctions ()  #####
' ######################################
'
' PURPOSE : To demonstrate the image printing functions.
'
' styles constants only for use with XprPrintBmpFile()
' $$BMP_TOPLEFT
' $$BMP_MIDDLECENTER
' $$BMP_MANUALPOSITION
' $$BMP_SCALEFACTORON
'
FUNCTION  XprTestImageFunctions ()
'
	DOUBLE pyPos, marTop, y
'
' *****  XprStartDocument() *****
' XprStartDocument() is used with XprTextArray(), XprTextFile(),
' XprTextLine(), drawing, and image functions. XprStartDocument()
' must be called first and only once before calling XprEndDocument().

	JobName$ = "XprTestImageFunctions"
	PrtName$ = ""
	ret = XprStartDocument(PrtName$, JobName$)
	PRINT "XprStartDocument() return = "; ret


' ***** XprPrintBmpFile()  *****
'
' put your bmp filename here
'
	pyPos = pyPos + 25
	fileName$ = "/xblite/images/lama.bmp"
	ret = XprPrintBmpFile (fileName$, $$BMP_MANUALPOSITION OR $$BMP_SCALEFACTORON, 50, @pyPos, 100)
	PRINT "XprPrintBmpFile() return = "; ret
	PRINT "new pyPos = "; pyPos
	XprGetPrinterYpos(@y)
	PRINT "New Printer Y pos = "; y
'
	pyPos = pyPos + 25
	fileName$ = "/xblite/images/queen_pope.bmp"
	ret = XprPrintBmpFile (fileName$, $$BMP_MANUALPOSITION OR $$BMP_SCALEFACTORON, 50, @pyPos, 150)
	PRINT "XprPrintBmpFile() return = "; ret
	PRINT "new pyPos = "; pyPos
	XprGetPrinterYpos(@y)
	PRINT "New Printer Y pos = "; y
'
'	print a title under the picture
'
	text$ = "Pencil me in."
	fontHeight = 12
	marLeft = 100
	marRight = 100
	marTop = pyPos
	marBottom = 100
	fontName$ = "Times New Roman"
	textFlags = $$TEXT_NORMAL OR $$TEXT_ITALIC
'
	ret = XprTextLine (text$, textFlags, marLeft, @marTop, marRight, marBottom, fontName$, 12)
	PRINT "XprTextLine() return = "; ret
	XprGetPrinterYpos(@y)
	PRINT "New Printer Y pos = "; y
'
' ***** XprPrintScreen()  *****
'
	pyPos = pyPos + 25
  ret = XprPrintScreen (0, 0, 0, 0, $$BMP_MANUALPOSITION OR $$BMP_SCALEFACTORON, 50, @pyPos, 40)
	PRINT "XprPrintScreen() return = "; ret
	XprGetPrinterYpos(@y)
	PRINT "New Printer Y pos = "; y
'
' ***** XprPrintWindow()  *****
'
' Print console window
'
	hWnd = FindWindowA (0, &#console$)
	PRINT "hWnd console = "; hWnd
	Sleep (1000)
'
	IF hWnd THEN
		pyPos = pyPos + 25
		ret = XprPrintWindow (hWnd, $$BMP_MANUALPOSITION OR $$BMP_SCALEFACTORON, 50, @pyPos, 40)
		PRINT "XprPrintWindow() return = "; ret
		XprGetPrinterYpos(@y)
		PRINT "New Printer Y pos = "; y
	END IF
'
'
' *****  XprEndDocument()  *****
' You need to use XprEndDocument to end a printing session
'
	ret = XprEndDocument()
	PRINT "XprEndDocument() return = "; ret
'

END FUNCTION
'
'
' ################################
' #####  ReplaceAllArray ()  #####
' ################################
'
'
'PURPOSE:	Function to replace all occurances of find$ within a
'					string array myTextArray$[]	and replace it with replace$
' 				If mode = 0 then default mode is $$FindForward OR $$FindCaseSensitive
'MODES:		modes for ReplaceAllArray
'					$$FindForward
'					$$FindReverse
'					$$FindDirection
'					$$FindCaseSensitive
'					$$FindCaseInsensitive
'					$$FindCaseSensitivity
' USE: 		ReplaceAllArray ($$FindForward, @myTextArray$[], "http://, "url= http://")
'
FUNCTION  ReplaceAllArray (mode, @myTextArray$[], find$, replace$)
'
	match = -1
	lineNum = 0
	position = 0
	length = MAX(LEN(replace$),1)
	IFZ mode THEN mode = $$FindForward OR $$FindCaseSensitive

	DO WHILE match == -1
		XstReplaceArray (mode, @myTextArray$[], @find$, @replace$, @lineNum, @position, @match)
		IF match = 0 THEN RETURN
		position = position + length
	LOOP
END FUNCTION
'
'
' #############################################
' #####  ParseTextStringToStringArray ()  #####
' #############################################
'
FUNCTION  ParseTextStringToStringArray (text$, @text$[])

	count = -1
	DIM text$[256]
	DO
		next$ = XstNextField$ (text$, @index, @done)
		IF next$ THEN
			INC count
			top = UBOUND (text$[])
			IF count > top THEN REDIM text$[count << 1]
			text$[count] = next$
		END IF
	LOOP UNTIL next$ = ""
	REDIM text$[count]

END FUNCTION
'
'
' ####################################
' #####  XprRawTextToPrinter ()  #####
' ####################################
'
'	/*
'	[XprRawTextToPrinter]
' Description = The XprRawTextToPrinter function prints a text string (as is) directly to the specified printer.
' Function    = error = XprRawTextToPrinter (printerName$, @text$)
' ArgCount    = 2
' Arg1        = printerName$ : The name of printer to send data.
' Arg2        = text$ : The raw text string to send to the printer.
'	Return      = If the function succeeds, the return value is -1. If the function fails, the return value is 0.
' Remarks     = It is not necessary to use XprStartDocument/XprEndDocument with this function.
'	See Also    =
'	Examples    = XprGetDefaultPrinter (@defPrinter$, @driver$, @port$)<br>text$ = "Some raw text\r\nprinted on more\r\nthan one line.\f"<br>XprRawTextToPrinter (defPrinter$, text$)
'	*/
FUNCTION XprRawTextToPrinter (printerName$, @text$)

  DOC_INFO_1 DocInfo

  IFZ text$ THEN RETURN $$FALSE

' Need a handle to the printer.
  IF (!OpenPrinterA (&printerName$, &hPrinter, NULL)) THEN RETURN $$FALSE

' Fill in the structure with info about this "document."
  DocInfo.pDocName = &"XBLite Document"
  DocInfo.pOutputFile = NULL
  DocInfo.pDataType = &"RAW"

' Inform the spooler the document is beginning.
  dwJob = StartDocPrinterA (hPrinter, 1, &DocInfo)
  IF dwJob == 0 THEN
    ClosePrinter (hPrinter)
    RETURN $$FALSE
  END IF

' Start a page.
  IF (!StartPagePrinter (hPrinter)) THEN
    EndDocPrinter (hPrinter)
    ClosePrinter (hPrinter)
    RETURN $$FALSE
  END IF

' Send the data to the printer.
  length = LEN(text$)
  IF (!WritePrinter (hPrinter, &text$, length, &dwBytesWritten)) THEN
    EndPagePrinter (hPrinter)
    EndDocPrinter (hPrinter)
    ClosePrinter (hPrinter)
    RETURN $$FALSE
  END IF

' End the page.
  IF (!EndPagePrinter (hPrinter)) THEN
    EndDocPrinter (hPrinter)
    ClosePrinter (hPrinter)
    RETURN $$FALSE
  END IF

' Inform the spooler that the document is ending.
  IF (!EndDocPrinter (hPrinter)) THEN
    ClosePrinter (hPrinter)
    RETURN $$FALSE
  END IF

' Tidy up the printer handle.
  ClosePrinter (hPrinter)

' Check to see if correct number of bytes were written.
  IF (dwBytesWritten != length) THEN RETURN $$FALSE
  RETURN ($$TRUE)
END FUNCTION
'
' ########################################
' #####  XprTestRawTextToPrinter ()  #####
' ########################################
'
FUNCTION  XprTestRawTextToPrinter ()

' get default printer
  XprGetDefaultPrinter (@pr$, @driver$, @port$)

'test escape sequences

  XprRawTextToPrinter (pr$, "\e\r\x45")                 ' set to Epson FX-850 mode

	text$ = "This is your lucky day." + $$RN

	XprRawTextToPrinter (pr$, text$)						          ' normal text is 10 cpi
	XprRawTextToPrinter (pr$, $$10CPI + text$) 						' 10 cpi
	XprRawTextToPrinter (pr$, $$12CPI + text$) 						' 12 cpi
	XprRawTextToPrinter (pr$, $$BOLD_ON + text$) 					' bold print on
	XprRawTextToPrinter (pr$, $$BOLD_OFF)									' bold print off
	XprRawTextToPrinter (pr$, $$ITALIC_ON + text$) 				' italic print on
	XprRawTextToPrinter (pr$, $$ITALIC_OFF)  							' italic print off
	XprRawTextToPrinter (pr$, $$UNDERLINE_ON + text$) 	  ' underline print on
	XprRawTextToPrinter (pr$, $$UNDERLINE_OFF) 					  ' underline print off
	XprRawTextToPrinter (pr$, $$PROPORTIONAL_ON + text$)  ' proportional print on
	XprRawTextToPrinter (pr$, $$PROPORTIONAL_OFF) 				' proportional print off
	XprRawTextToPrinter (pr$, $$WIDE_ON + text$) 	        ' wide print on
	XprRawTextToPrinter (pr$, $$WIDE_OFF)  					      ' wide print off
	XprRawTextToPrinter (pr$, $$CONDENSED_ON + text$)			' condensed text on
	XprRawTextToPrinter (pr$, $$CONDENSED_OFF)						' condensed text off
	
'select font
	XprRawTextToPrinter (pr$, $$FONT_ROMAN + text$) 	    ' roman font
	XprRawTextToPrinter (pr$, $$FONT_SANSERIF + text$) 	  ' san serif font
	XprRawTextToPrinter (pr$, $$FONT_COURIER + text$) 	  ' courier font
	XprRawTextToPrinter (pr$, $$FONT_PRESTIGE + text$) 	  ' prestige font
	XprRawTextToPrinter (pr$, $$FONT_SCRIPT + text$) 	    ' script font

	XprRawTextToPrinter (pr$, $$FONT_ROMAN) 					    ' roman font

'master select
	XprRawTextToPrinter (pr$, $$SELECT_PICA + text$) 	        ' pica
	XprRawTextToPrinter (pr$, $$SELECT_ELITE + text$) 	      ' elite
	XprRawTextToPrinter (pr$, $$SELECT_PROPORTIONAL + text$) 	' proportional
	XprRawTextToPrinter (pr$, $$SELECT_CONDENSED + text$) 	  ' condensed
	XprRawTextToPrinter (pr$, $$SELECT_EMPHASIZED + text$) 	  ' emphasized
	XprRawTextToPrinter (pr$, $$SELECT_DOUBLESTRIKE + text$) 	' double strike
	XprRawTextToPrinter (pr$, $$SELECT_DOUBLEWIDE + text$) 	  ' double wide
	XprRawTextToPrinter (pr$, $$SELECT_ITALIC + text$) 	      ' italic
	XprRawTextToPrinter (pr$, $$SELECT_UNDERLINE + text$)     ' underline

	XprRawTextToPrinter (pr$, $$SELECT_PICA) 					        ' pica

'select character style
	XprRawTextToPrinter (pr$, $$STYLE_NORMAL + text$) 	      ' normal character style
	XprRawTextToPrinter (pr$, $$STYLE_OUTLINE + text$) 	      ' outline character style
	XprRawTextToPrinter (pr$, $$STYLE_SHADOW + text$) 	      ' shadow character style
	XprRawTextToPrinter (pr$, $$STYLE_OUTLINE_SHADOW + text$) ' outline & shadow character style
	XprRawTextToPrinter (pr$, $$STYLE_NORMAL) 					      ' normal character style

'print special characters
	text$ = ""
	FOR i = 33 TO 254
		text$ = text$ + CHR$(i) + CHR$(32)
		INC count
		IF count > 34 THEN
			XprRawTextToPrinter (pr$, text$ + $$RN)
			text$ = ""
			count = 0
		END IF
	NEXT i
	XprRawTextToPrinter (pr$, text$ + $$RN)
	XprRawTextToPrinter (pr$, $$RESET) 							' reset printer
	XprRawTextToPrinter (pr$, $$FF)									' form feed
END FUNCTION

END PROGRAM
