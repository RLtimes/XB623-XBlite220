'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo which returns a file's size
' and last modified attributes using
' XstGetFilesAndAttributes.
'
PROGRAM	"fileinfo"
VERSION	"0.0003"
CONSOLE
'
IMPORT	"xst"
IMPORT	"xsx"
IMPORT	"xio"
IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

'define constant
$MaxDword = 0xFFFF

'assign FILEINFOR TYPE struct to fi[]
FILEINFO fi[], tmp[]

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 300)
	XioCloseStdHandle (hStdOut)

	path$ = "c:/xblite"
	XstFindFiles (path$, "*.x", $$TRUE, @f$[])

	IFZ f$[] THEN RETURN
	upper = UBOUND (f$[])

	PRINT STRING$(upper+1); " XBLite files found in "; path$
	PRINT

	PRINT "FileName                Size(kb)   Modified"
	PRINT "======================================================"

	FOR i = 0 TO upper
		filter$ = f$[i]					' create a path$/filter$ as needed

'call XstGetFilesAndAttributes to fill fi[]
		attribFlag = -1  	'get all files and directories
		DIM files$[]
		DIM fi[]
		maxLen = XstGetFilesAndAttributes (filter$, attribFlag, @files$[], @fi[])

		upp = UBOUND(files$[])
		IF upp = -1 THEN
			PRINT "No file found"
			DO NEXT
		END IF

'get size of file in kb
'file size in bytes = sizeHigh * $MaxDword + sizeLow
		size = ((fi[0].sizeHigh * $MaxDword + fi[0].sizeLow) / 1024.0)+0.5

'create giant argument for fileTime$$ from high and low filetime values from fi[]
		fileTime$$ = GMAKE (fi[0].modifyTimeHigh, fi[0].modifyTimeLow)

'convert system filetime to local filetime
		FileTimeToLocalFileTime (&fileTime$$, &fileTimeLocal$$)

'convert fileTime$$ to system time
		XstFileTimeToDateAndTime (fileTimeLocal$$, @year, @month, @day, @hour, @minute, @second, @nanos)
		month$ = STRING$(month)
		IF LEN(month$) < 2 THEN month$ = "0" + month$
		day$ = STRING$(day)
		IF LEN(day$) < 2 THEN day$ = "0" + day$
		date$ = month$ + "/" + day$ + "/" + STRING$(year)
		IF (hour < 12) THEN ap$ = " AM" ELSE ap$ = " PM"
    IF hour > 12 THEN hour = hour - 12
		hour$ = STRING$(hour)
		IF LEN(hour$) < 2 THEN hour$ = "0" + hour$
		minute$ = STRING$(minute)
		IF LEN(minute$) < 2 THEN minute$ = "0" + minute$
		time$ = hour$ + ":" + minute$ + ap$

		GOSUB PrintInfo
	NEXT i

	PRINT
	a$ = INLINE$("Press ENTER to exit >")

	RETURN

' ***** PrintInfo *****
SUB PrintInfo
	PRINT FORMAT$("<<<<<<<<<<<<<<<<<<<<<<<<<<", fi[0].name);
	PRINT FORMAT$(">>>>>>", STRING$(size));
	PRINT "   ";
	PRINT FORMAT$(">>>>>>>>>>", date$);
	PRINT " ";
	PRINT FORMAT$(">>>>>>>>", time$)
END SUB
END FUNCTION
END PROGRAM
