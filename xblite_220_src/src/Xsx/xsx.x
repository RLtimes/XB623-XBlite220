'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  XBLite standard extended function library
'
' Xsx is the Windows XBasic/XBLite
' extended standard function library.
' These functions were all formerly part
' of the Xst library, and their names have
' not changed.
' ---
' subject to LGPL license - see COPYING_LIB
' maxreason@maxreason.com
' ---
' XBLite modifications by David Szafranski 2002
' xblite@yahoo.com
'
' v0.009 - 2005/07/05
' Added support for LONGDOUBLE in XstTypeSize, XstBytesToBound, XstGetTypedArray.
'
' v0.010 - 2005/07/21
' Added XstFileExists().
'
'	v0.011 20 October 2005
'	Changed the names of Error Subroutines to Errors in order to fix "Duplicat Symbol Error" 
'	when building xball.lib
'
' v0.012 4 November 2005
' XstParseStringToStringArray() function rewritten for improved performance by Alan Gent.
' Added XstStripChars() function by Alan Gent.
' Added XstTranslateChars() function by Alan Gent.
' Added XstCall() function.
'
' v0.013 12 November 2005
' Fixed error in XstGetCPUName
'
' v0.014 6 Jan 2006
' Added XstAnsiToUnicode$() by Alan Gent.
' Added XstUnicodeToAnsi$() by Alan Gent.
' Added XstRandomRange() by Alan Gent.
' Added XstRandomRangeF() by Alan Gent.
' Added XstRandomRGB() by Alan Gent.
' Added XstRandomARGB() by Alan Gent.
' Added XstLoadData() by Alan Gent.
' Added XstBuildDataArray() by Alan Gent.
' Added XstSaveDataArray() plus internal support functions by Alan Gent.
' Added XstLoadCompositeDataArray() by Alan Gent.
' Added XstSaveCompositeDataArray() plus internal support functions by Alan Gent.
'
' v0.015 21 February 2006
' Replaced ? with ASM for inline assembly

' v0.016 7 Sepember 2006
' Fixed bug in XstRandomSeed (fix reported by Alan Gent)


PROGRAM	"xsx"
VERSION	"0.016"
'
IMPORT  "xst"
IMPORT	"gdi32"
IMPORT	"user32"
IMPORT	"kernel32"

EXPORT
' **********************************************
' *****  Standard Library COMPOSITE TYPES  *****
' **********************************************
'
TYPE FILEINFO
  XLONG        .attributes
  XLONG        .createTimeLow
  XLONG        .createTimeHigh
  XLONG        .accessTimeLow
  XLONG        .accessTimeHigh
  XLONG        .modifyTimeLow
  XLONG        .modifyTimeHigh
  XLONG        .sizeHigh
  XLONG        .sizeLow
  XLONG        .res0
  XLONG        .res1
  STRING*260   .name
  STRING*14    .alternateName
END TYPE
'
TYPE TIMER
  XLONG        .timer
  XLONG        .count
  XLONG        .func
  XLONG        .msec
  XLONG        .who
  XLONG        .x5
  XLONG        .x6
  XLONG        .x7
END TYPE
'
END EXPORT
'
EXPORT
'
' ****************************************
' *****  Standard Library Functions  *****
' ****************************************
'
' system functions
'
DECLARE FUNCTION  Xsx                            ()
DECLARE FUNCTION  XsxVersion$                    ()
DECLARE FUNCTION  XstCall                        (funcName$, dllName$, @args[])
DECLARE FUNCTION  XstDateAndTimeToFileTime       (year, month, day, hour, minute, second, nanos, @filetime$$)
DECLARE FUNCTION  XstFileTimeToDateAndTime       (fileTime$$, @year, @month, @day, @hour, @minute, @second, @nanos)
DECLARE FUNCTION  XstGetCommandLine              (@commandline$)
DECLARE FUNCTION  XstGetCommandLineArguments     (@argc, @argv$[])
DECLARE FUNCTION  XstGetCPUName                  (@id$, @cpuFamily, @model, @intelBrandID)
DECLARE FUNCTION  XstGetDateAndTime              (@year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
DECLARE FUNCTION  XstGetDateAndTimeFormatted     (language, dateFormat, @date$, timeFormat, @time$)
DECLARE FUNCTION  XstGetLocalDateAndTime         (@year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
DECLARE FUNCTION  XstGetEndian                   (@endian$$)
DECLARE FUNCTION  XstGetEndianName               (@endian$)
DECLARE FUNCTION  XstGetEnvironmentVariables     (@count, @envp$[])
DECLARE FUNCTION  XstGetOSName                   (@name$)
DECLARE FUNCTION  XstGetOSVersion                (@major, @minor, @platformId, @version$, @platform$)
DECLARE FUNCTION  XstGetProgramFileName$         ()
DECLARE FUNCTION  XstGetSystemTime               (@msec)
DECLARE FUNCTION  XstLog                         (message$, style, fileName$)
DECLARE FUNCTION  XstSetCommandLineArguments     (argc, @argv$[])
DECLARE FUNCTION  XstSetDateAndTime              (year, month, day, weekDay, hour, minute, second, nanos)
DECLARE FUNCTION  XstSetEnvironmentVariable      (name$, value$)
DECLARE FUNCTION  XstSleep                       (milliSec)
'
' file functions
'
DECLARE FUNCTION  XstBinRead                     (ifile, bufferAddr, maxBytes)
DECLARE FUNCTION  XstBinWrite                    (ofile, bufferAddr, numBytes)
DECLARE FUNCTION  XstChangeDirectory             (directory$)
DECLARE FUNCTION  XstCopyDirectory               (source$, dest$)
DECLARE FUNCTION  XstCopyFile                    (source$, dest$)
DECLARE FUNCTION  XstDecomposePathname           (pathname$, @path$, @parent$, @filename$, @file$, @extent$)
DECLARE FUNCTION  XstDeleteFile                  (file$)
DECLARE FUNCTION  XstFileExists                  (file$)
DECLARE FUNCTION  XstFindFile                    (file$, @path$[], @path$, @attr)
DECLARE FUNCTION  XstFindFiles                   (basepath$, filter$, recurse, @file$[])
DECLARE FUNCTION  XstGetCurrentDirectory         (@directory$)
DECLARE FUNCTION  XstGetDrives                   (@count, @drive$[], @driveType[], @driveType$[])
DECLARE FUNCTION  XstGetExecutionPathArray       (@path$[])
DECLARE FUNCTION  XstGetFileAttributes           (file$, @attributes)
DECLARE FUNCTION  XstGetFiles                    (filter$, @files$[])
DECLARE FUNCTION  XstGetFilesAndAttributes       (filter$, attributeFilter, @files$[], FILEINFO @fileInfo[])
DECLARE FUNCTION  XstGetPathComponents           (file$, @path$, @drive$, @dir$, @filename$, @attributes)
DECLARE FUNCTION  XstGuessFilename               (old$, new$, @guess$, @attributes)
DECLARE FUNCTION  XstIsAbsolutePath              (file$)
DECLARE FUNCTION  XstLoadString                  (file$, @text$)
DECLARE FUNCTION  XstLoadStringArray             (file$, @text$[])
DECLARE FUNCTION  XstMakeDirectory               (directory$)
DECLARE FUNCTION  XstPathToAbsolutePath          (ipath$, @opath$)
DECLARE FUNCTION  XstReadString                  (ifile, @string$)
DECLARE FUNCTION  XstRenameFile                  (old$, new$)
DECLARE FUNCTION  XstSaveString                  (file$, text$)
DECLARE FUNCTION  XstSaveStringArray             (file$, text$[])
DECLARE FUNCTION  XstSaveStringArrayCRLF         (file$, text$[])
DECLARE FUNCTION  XstSetCurrentDirectory         (directory$)
DECLARE FUNCTION  XstWriteString                 (ofile, @string$)
'
' string, string array, and array functions
'
DECLARE FUNCTION  XstBackArrayToBinArray         (backArray$[], @binArray$[])
DECLARE FUNCTION  XstBackStringToBinString$      (backString$)
DECLARE FUNCTION  XstBinArrayToBackArray         (binArray$[], @backArray$[])
DECLARE FUNCTION  XstBinStringToBackString$      (binString$)
DECLARE FUNCTION  XstBinStringToBackStringNL$    (binString$)
DECLARE FUNCTION  XstBinStringToBackStringThese$ (binString$, these[])
DECLARE FUNCTION  XstCopyArray                   (ANY[], ANY[])
DECLARE FUNCTION  XstCopyMemory                  (sourceAddr, destAddr, bytes)
DECLARE FUNCTION  XstCreateDoubleImage$          (DOUBLE x)
DECLARE FUNCTION  XstDeleteLines                 (array$[], start, count)
DECLARE FUNCTION  XstFindArray                   (mode, text$[], find$, @line, @pos, @match)
DECLARE FUNCTION  XstTypeSize										 (type)
DECLARE FUNCTION  XstBytesToBound                (type, bytes)
DECLARE FUNCTION  XstGetTypedArray               (type, bytes, @ANY array[])
DECLARE FUNCTION  XstIsDataDimension             (ANY[])
DECLARE FUNCTION  XstMergeStrings$               (string$, add$, start, replace)
DECLARE FUNCTION  XstMultiStringToStringArray    (s$, @s$[])
DECLARE FUNCTION  XstNextCField$                 (sourceAddr, @index, @done)
DECLARE FUNCTION  XstNextCLine$                  (sourceAddr, index, done)
DECLARE FUNCTION  XstNextField$                  (source$, @index, @done)
DECLARE FUNCTION  XstNextItem$                   (source$, @index, @term, @done)
DECLARE FUNCTION  XstNextLine$                   (source$, @index, @done)
DECLARE FUNCTION  XstParse$                      (source$, delimiter$, n)
DECLARE FUNCTION  XstParseStringToStringArray    (source$, delimiter$, @s$[])
DECLARE FUNCTION  XstReplace                     (@source$, find$, replace$, n)
DECLARE FUNCTION  XstReplaceArray                (mode, text$[], find$, replace$, line, pos, match)
DECLARE FUNCTION  XstReplaceLines                (d$[], s$[], firstD, countD, firstS, countS)
DECLARE FUNCTION  XstStringArraySectionToString  (text$[], @copy$, x1, y1, x2, y2, term)
DECLARE FUNCTION  XstStringArraySectionToStringArray (text$[], @copy$[], x1, y1, x2, y2)
DECLARE FUNCTION  XstStringArrayToString         (s$[], @s$)
DECLARE FUNCTION  XstStringArrayToStringCRLF     (s$[], @s$)
DECLARE FUNCTION  XstStringToStringArray         (s$, @s$[])
DECLARE FUNCTION  XstStripChars                  (@source$, testchar$)
DECLARE FUNCTION  XstTally                       (source$, find$)
DECLARE FUNCTION  XstTranslateChars              (@string$, from$, to$)
DECLARE FUNCTION  XstLTRIM                       (@string$, array[])
DECLARE FUNCTION  XstRTRIM                       (@string$, array[])
DECLARE FUNCTION  XstTRIM                        (@string$, array[])
'
' sorting functions
'
DECLARE FUNCTION  XstCompareStrings              (addrString1, op, addrString2, flags)
DECLARE FUNCTION  XstQuickSort                   (ANY x[], n[], low, high, flags)
'
' clipboard functions
'
DECLARE FUNCTION  XstGetClipboard                (clipType, @text$, UBYTE image[])
DECLARE FUNCTION  XstSetClipboard                (clipType, text$, UBYTE image[])
'
' message functions
'
DECLARE FUNCTION  XstAbend                       (errorMessage$)
DECLARE FUNCTION  XstAlert                       (message$)
'
' timer functions
'
DECLARE FUNCTION  XstStartTimer                  (timer, count, msec, func)
DECLARE FUNCTION  XstKillTimer                   (timer)
'
' random number functions
'
DECLARE FUNCTION  ULONG  XstRandom               ()
DECLARE FUNCTION         XstRandomARGB           (UBYTE alpha)
DECLARE FUNCTION  ULONG  XstRandomCreateSeed     ()
DECLARE FUNCTION         XstRandomRange          (n1, n2)
DECLARE FUNCTION DOUBLE  XstRandomRangeF         (DOUBLE n1, DOUBLE n2)
DECLARE FUNCTION         XstRandomRGB            ()
DECLARE FUNCTION         XstRandomSeed           (ULONG seed)
DECLARE FUNCTION  DOUBLE XstRandomUniform        ()
'
' unicode string functions
DECLARE FUNCTION  XstUnicodeToAnsi$              (lpTextWide)
DECLARE FUNCTION  XstAnsiToUnicode$              (ansi$)
'
' csv data functions
DECLARE FUNCTION  XstLoadCompositeDataArray      (ANY a[], input$, template$, @errornum)
DECLARE FUNCTION  XstLoadData                    (ANY a[], data$, type)
DECLARE FUNCTION  XstBuildDataArray              (ANY a[], string$, type)
DECLARE FUNCTION  XstSaveCompositeDataArray      (ANY a[], @output$, template$, crlf, braces, @errornum)
DECLARE FUNCTION  XstSaveDataArray               (ANY a[], output$, formatted)
'
END EXPORT
'
' internal functions
'
INTERNAL FUNCTION  InitProgram                   ()
INTERNAL FUNCTION  XstQuickSort_XLONG            (x[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_GIANT            (x$$[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_DOUBLE           (x#[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_STRING           (x$[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_STRING_nocase    (x$[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_NumericSTRING    (x$[], n[], low, high, flags)
INTERNAL FUNCTION  XstAttributeMatch             (attr, filter)
'
INTERNAL FUNCTION  getFirstSlash(str$, stop)
INTERNAL FUNCTION  getLastSlash(str$, stop)
'
INTERNAL FUNCTION  GetClipText (@text$)
INTERNAL FUNCTION  GetClipBitmap (UBYTE image[])
INTERNAL FUNCTION  SetClipText (text$)
INTERNAL FUNCTION  SetClipBitmap (UBYTE image[])
INTERNAL FUNCTION  XstTimer (hwnd, message, timer, time)
'
INTERNAL FUNCTION  BuildNode (i[], type)
INTERNAL FUNCTION  SaveArray (address, out$, level, formatted)
INTERNAL FUNCTION  ShowNodeInfo (address)
INTERNAL FUNCTION  AlignOffset (offset, align)
'
'
'
EXPORT
'
' ****************************************
' *****  Standard Library Constants  *****
' ****************************************
'
  $$Newline$            =  "\n"
'
' Line Separator argument in XstStringArraySectionToString()
'
  $$NOTERM              =  0        ' no line terminator
  $$LF                  =  1        ' \n
  $$NL                  =  1        ' \n
  $$CRLF                =  2        ' \r\n
'
' Drive types returned by XstGetDrives (@count, @drive$[], @driveType[], @driveType$[])
'
  $$DriveTypeUnknown    =  0        ' "Unknown"
  $$DriveTypeDamaged    =  1        ' "Damaged"
  $$DriveTypeRemovable  =  2        ' "Removable"
  $$DriveTypeFixed      =  3        ' "Fixed"
  $$DriveTypeRemote     =  4        ' "Remote"
  $$DriveTypeCDROM      =  5        ' "CDROM"
  $$DriveTypeRamDisk    =  6        ' "RamDisk"
'
'  File Attributes returned by XstGetFileAttributes (filename$, @attributes)
'
  $$FileNonexistent     = 0x0000
  $$FileNotFound        = 0x0000
  $$FileReadOnly        = 0x0001
  $$FileHidden          = 0x0002
  $$FileSystem          = 0x0004
  $$FileDirectory       = 0x0010
  $$FileArchive         = 0x0020
  $$FileNormal          = 0x0080    ' no other bits should be set
  $$FileTemporary       = 0x0100
  $$FileAtomicWrite     = 0x0200
  $$FileExecutable      = 0x1000
'
' mode in XstFindArray()
'
  $$FindForward         = 0x00
  $$FindReverse         = 0x01
  $$FindDirection       = 0x01
  $$FindCaseSensitive   = 0x00
  $$FindCaseInsensitive = 0x02
  $$FindCaseSensitivity = 0x02
'
' ****************************
' *****  Sort Constants  *****  OR sort flags together
' ****************************
'
  $$SortIncreasing      = 0x00      ' "a to z"
  $$SortDecreasing      = 0x01      ' "z to a"
  $$SortCaseSensitive   = 0x00      ' "A" < "a"
  $$SortCaseInsensitive = 0x02      ' "A" = "a"
  $$SortAlphabetic      = 0x00      ' "a3b" > "a11c"
  $$SortAlphaNumeric    = 0x04      ' "a3b" < "a11c"
'
' for XstCompareStrings()
'
  $$EQ                  = 0x02
  $$NE                  = 0x03
  $$LT                  = 0x04
  $$LE                  = 0x05
  $$GE                  = 0x06
  $$GT                  = 0x07
'
END EXPORT
'
' ####################
' #####  Xst ()  #####
' ####################
'
FUNCTION  Xsx ()


END FUNCTION
'
'
' ############################
' #####  XsxVersion$ ()  #####
' ############################
'
FUNCTION  XsxVersion$ ()
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' #########################################
' #####  XstDateAndTimeToFileTime ()  #####
' #########################################
'
' PURPOSE : Create a file time from time and date arguments.
'						The FILETIME structure is a 64-bit value representing
'           the number of 100-nanosecond intervals since
'           January 1, 1601.
'	IN			: year, month, day, hour, minute, second, nanos
' OUT			: filetime$$	- file time
'
FUNCTION  XstDateAndTimeToFileTime (year, month, day, hour, minute, second, nanos, @filetime$$)
	EXTERNAL /shr_data/ errno
'
	SYSTEMTIME  st
	FILETIME  ft
'
	st.year = year
	st.month = month
	st.day = day
	st.weekDay = 0
	st.hour = hour
	st.minute = minute
	st.second = second
	st.msec = nanos \ 1000000
'
	IFZ SystemTimeToFileTime (&st, &ft) THEN GOSUB Errors
	filetime$$ = GMAKE (ft.dwHighDateTime, ft.dwLowDateTime)

' ***** Errors *****
SUB Errors
	
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB
END FUNCTION
'
'
' #########################################
' #####  XstFileTimeToDateAndTime ()  #####
' #########################################
'
' PURPOSE	: Convert a file time into date and time arguments.
' IN			: filetime$$	- file time
' OUT			: year, month, day, hour, minute, second, nanos
' RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstFileTimeToDateAndTime (filetime$$, @year, @month, @day, @hour, @minute, @second, @nanos)
	EXTERNAL /shr_data/ errno
'
	SYSTEMTIME  st
	FILETIME  ft
'
	ft.dwLowDateTime = GLOW (filetime$$)
	ft.dwHighDateTime = GHIGH (filetime$$)
	IFZ FileTimeToSystemTime (&ft, &st) THEN GOSUB Errors
'
	year = st.year
	month = st.month
	day = st.day
	weekDay = st.weekDay
	hour = st.hour
	minute = st.minute
	second = st.second
	nanos = st.msec * 1000000

' ***** Errors *****
SUB Errors

	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END SUB


END FUNCTION
'
'
' ##################################
' #####  XstGetCommandLine ()  #####
' ##################################
'
' PURPOSE	: Return a command-line string for the current process.
'	RETURN	: Return value command-line string for the current process.
'
FUNCTION  XstGetCommandLine (@line$)
'
	addr = GetCommandLineA ()
	line$ = CSTRING$ (addr)
END FUNCTION
'
'
' ###########################################
' #####  XstGetCommandLineArguments ()  #####
' ###########################################
'
FUNCTION  XstGetCommandLineArguments (@argc, @argv$[])
	SHARED  setarg
	SHARED  setargc
	SHARED  setargv$[]
'
	DIM argv$[]
	inc = argc
	argc = 0
'
' return already set argc and argv$[]
'
	IF (inc >= 0) THEN
		IF setarg THEN
			argc = setargc
			upper = UBOUND (setargv$[])
			ucount = upper + 1
			IF (argc > ucount) THEN argc = ucount
			IF argc THEN
				DIM argv$[upper]
				FOR i = 0 TO upper
					argv$[i] = setargv$[i]
				NEXT i
			END IF
			RETURN ($$FALSE)
		END IF
	END IF
'
' get original command line arguments from system
'
	argc = 0
	index = 0
	DIM argv$[]
	addr = GetCommandLineA()			' address of full command line
	line$ = CSTRING$(addr)
'
	done = 0
	IF addr THEN
		DIM argv$[1023]
		quote = $$FALSE
		argc = 0
		empty = $$FALSE
		I = 0
		DO
			char = UBYTEAT(addr, I)
			IF (char < ' ') THEN EXIT DO

			IF (char = ' ') AND NOT quote THEN
				IF NOT empty THEN
					INC argc
					argv$[argc] = ""
					empty = $$TRUE
				END IF
			ELSE
				IF (char = '"') THEN
					quote = NOT quote
				ELSE
					argv$[argc] = argv$[argc] + CHR$(char)
					empty = $$FALSE
				END IF
			END IF
			INC I
		LOOP
		IF NOT empty THEN
			argc = argc + 1
		END IF
		REDIM argv$[argc-1]

	END IF
'
' if input argc < 0 THEN don't overwrite current values
'
	IF ((setarg = $$FALSE) OR (inc >= 0)) THEN
		setarg = $$TRUE
		setargc = argc
		DIM setargv$[]
		IF (argc > 0) THEN
			DIM setargv$[argc-1]
			FOR i = 0 TO argc-1
				setargv$[i] = argv$[i]
			NEXT i
		END IF
	END IF
END FUNCTION
'
'
' ##############################
' #####  XstGetCPUName ()  #####
' ##############################
'
' for info on 32-bit CPU architecture, see
' http://www.sandpile.org/ia32/cpuid.htm

' When the input in EAX is 0, the cpuid instruction returns
' the maximum supported standard level in EAX, and the
' vendor ID string in EBX-EDX-ECX.
'==========================================
'  ID STRING        Vendor
' GenuineIntel  	Intel processor
' UMC UMC UMC  		UMC processor
' AuthenticAMD  	AMD processor
' CyrixInstead  	Cyrix processor
' NexGenDriven  	NexGen processor
' CentaurHauls  	Centaur processor
' RiseRiseRise  	Rise Technology processor
' GenuineTMx86  	Transmeta processor

' When the input to CPUID is 1, then EAX returns the
' processor type/family/stepping. EBX returns the
' brand ID.

' ***** EAX=xxxx_xxxxh *****

'  ***** the extended processor family is encoded in bits 27..20 *****
' 00h  Intel P4
' 01h  Intel McKinley (IA-64)

' ***** the extended processor model is encoded in bits 19..16 *****
' ***** the family is encoded in bits 11..8 *****
' 4		most 80486s
' 		AMD 5x86
' 		Cyrix 5x86
' 5 	Intel P5, P54C, P55C, P24T
' 		NexGen Nx586
' 		Cyrix M1
' 		AMD K5, K6
' 		Centaur C6, C2, C3
' 		Rise mP6
' 		Transmeta Crusoe TM3x00 and TM5x00
' 6 	Intel P6, P2, P3
' 		AMD K7
' 		Cyrix M2, VIA Cyrix III
' 7 	Intel Merced (IA-64) F refer to extended family

' ***** the model is encoded in bits 7..4 *****
' Intel  F
' 			refer to extended model
' Intel 80486
' 	0  i80486DX-25/33
' 	1  i80486DX-50
' 	2  i80486SX
' 	3  i80486DX2
' 	4  i80486SL
' 	5  i80486SX2
' 	7  i80486DX2WB
' 	8  i80486DX4
' 	9  i80486DX4WB
' UMC 80486
' 	1  U5D
' 	2  U5S
' AMD 80486
' 	3  80486DX2
' 	7  80486DX2WB
' 	8  80486DX4
' 	9  80486DX4WB
' 	E  5x86
' 	F  5x86WB
' Cyrix 5x86
' 	9  5x86
' Cyrix MediaGX
' 	4  GX, GXm
' Intel P5-core
' 	0  P5 A-step
' 	1  P5
' 	2  P54C
' 	3  P24T Overdrive
' 	4  P55C
' 	7  P54C
' 	8  P55C (0.25µm)
' NexGen Nx586
' 	0  Nx586 or Nx586FPU (only later ones)
' Cyrix M1
' 	2  6x86
' Cyrix M2
' 	0  6x86MX
' VIA Cyrix III
' 	5  Cyrix M2 core
' 	6  WinChip C5A core
' 	7  WinChip C5B core (if stepping = 0..7)
' 	7  WinChip C5C core (if stepping = 8..F)
' AMD K5
'		0  SSA5 (PR75, PR90, PR100)
' 	1  5k86 (PR120, PR133)
' 	2  5k86 (PR166)
' 	3  5k86 (PR200)
' AMD K6
' 	6  K6 (0.30 µm)
' 	7  K6 (0.25 µm)
' 	8  K6-2
' 	9  K6-III
' 	D  K6-2+ or K6-III+ (0.18 µm)
' Centaur
' 	4  C6
' 	8  C2
' 	9  C3
' Rise
' 	0  mP6 (0.25 µm)
' 	2  mP6 (0.18 µm)
' Transmeta
' 	4  Crusoe TM3x00 and TM5x00
' Intel P6-core
' 	0  P6 A-step
' 	1  P6
' 	3  P2 (0.28 µm)
' 	5  P2 (0.25 µm)
' 	6  P2 with on-die L2 cache
' 	7  P3 (0.25 µm)
' 	8  P3 (0.18 µm) with 256 KB on-die L2 cache
' 	A  P3 (0.18 µm) with 1 or 2 MB on-die L2 cache
' 	B  P3 (0.13 µm) with 256 or 512 KB on-die L2 cache
' AMD K7
' 	1  Athlon (0.25 µm)
' 	2  Athlon (0.18 µm)
' 	3  Duron (SF core)
' 	4  Athlon (TB core)
' 	6  Athlon (PM core)
' 	7  Duron (MG core)
' Intel P4-core
' 	0  P4 (0.18 µm)
' 	1  P4 (0.18 µm)
' 	2  P4 (0.13 µm)

' ***** the stepping is encoded in bits 3..0 *****
'
'  ***** EBX=aall_ccbbh *****

' the brand ID is encoded in bits 7..0.
' 00h  not supported
' 01h  0.18 µm Intel Celeron
' 02h  0.18 µm Intel Pentium III
' 03h  0.18 µm Intel Pentium III Xeon
' 03h  0.13 µm Intel Celeron
' 04h  0.13 µm Intel Pentium III
' 07h  0.13 µm Intel Celeron mobile
' 06h  0.13 µm Intel Pentium III mobile
' 08h  0.18 µm Intel Pentium 4
' 0Eh  0.18 µm Intel Pentium 4 Xeon
' 09h  0.13 µm Intel Pentium 4
' 0Ah  0.13 µm Intel Pentium 4
' 0Bh  0.13 µm Intel Pentium 4 Xeon

' Note: this asm code has only been tested on a Pentium 586 so I
' don't know if it works correctly on 386/486 CPUs.
' ASM code was borrowed from http://7gods.sk/coding_sysparm.html
'
FUNCTION  XstGetCPUName (@id$, @cpuFamily, @model, @intelBrandID)

' XstGetCPUName () returns one of the following values:
' RETURN	: 386- if an 80386 microprocessor
' 					486- if an 80486 or other post-386 CPU that does not have a CPUID instruction
' 					x86- CPU has CPUID instruction, could be 486, 586, 686...
' OUT			:	id$ 					- CPU String ID
' 					cpuFamily 		- CPU family name
' 					model 				- CPU model number
' 					intelBrandID 	- Intel Brand ID number
'
	ULONG a, b, c, d, e, f
	a = 0
	b = 0
	c = 0
	d = 0
	e = 0
	f = 0
	ret = 0

' i386 code
ASM		mov 	ebx,386
ASM		pushfd
ASM		pop 	eax
ASM		mov 	ecx,eax
ASM		mov 	edx,eax
ASM		xor 	eax,0x40000 	; 386 wont change EFALGS bit 34
ASM		push 	eax
ASM		popfd
ASM		pushfd
ASM		pop 	eax
ASM		xor 	eax,ecx
ASM		je 	>	CPUexit

' i486 code
ASM		add 	ebx,100
ASM		mov 	eax,edx
ASM		mov 	ecx,eax
ASM		xor 	eax,0x200000 	; most 486 wont change EFALGS bit 37
ASM		push 	eax 					; (that is, wont support CPUID)
ASM		popfd
ASM		pushfd
ASM		pop 	eax
ASM		xor 	eax,ecx
ASM		je 	>	CPUexit

' pentium 586+ specific code
ASM		mov	eax,0					; set cpuid argument to 0
ASM 	cpuid  						; CPUID instruction

ASM		mov	[ebp-24],ebx 	; save ebx in a
ASM		mov	[ebp-28],edx 	; save edx in b
ASM		mov	[ebp-32],ecx 	; save ecx in c

ASM		mov	eax, 1				; set eax to 1
ASM 	cpuid  						; CPUID instruction

ASM		mov	[ebp-40],eax 	; save eax in e
ASM		mov	[ebp-44],ebx 	; save eax in f

ASM		mov	eax, 1				; set eax to 1
ASM 	cpuid  						; CPUID instruction

ASM		xor	ebx,ebx
ASM		mov	bl,ah					; put result into ebx
ASM		mov	eax,100				; set eax to 100
ASM		mul	ebx						; mult ebx by 100
ASM		add	eax,86				; add 86
ASM		mov	ebx,eax

ASM  CPUexit:
'ASM	mov	eax,ebx
ASM		mov	[ebp-48],ebx	; move result into ret

' convert a, b, c into id$
	id$ = CHR$(a{8,0}) + CHR$(a{8,8}) + CHR$(a{8,16}) + CHR$(a{8,24})
	id$ = id$ + CHR$(b{8,0}) + CHR$(b{8,8}) + CHR$(b{8,16}) + CHR$(b{8,24})
	id$ = id$ + CHR$(c{8,0}) + CHR$(c{8,8}) + CHR$(c{8,16}) + CHR$(c{8,24})

' convert e into cpuFamily
	cpuFamily = e{4,8}

' convert e into model
	model = e{4,4}

' convert f into intelBrandID
	intelBrandID = f{8,0}

ASM		mov	eax,[ebp-48]	; move ret to EAX

'ASM		jmp	end.func7.xsx	; jump to end of function
ASM		jmp	end.XstGetCPUName.xsx	; jump to end of function
END FUNCTION
'
'
' ##################################
' #####  XstGetDateAndTime ()  #####
' ##################################
'
'* Get the UTC/GMT date and time. This date and time is equal in all
' timezones.
'
' @param year			The year (0000 .. 9999)
' @param month		The month (1 .. 12)
' @param day			The day of the month (1 .. 31)
' @param weekDay	The day of the week (sunday=0 .. saturday=6)
' @param hour			The hour (00 .. 23)
' @param minute		The minute (00 .. 59)
' @param second		The second (00 .. 59)
' @param nanos		The nanoseconds (0 .. 999999999)
'
' @see XstGetLocalDateAndTime
'
'
FUNCTION  XstGetDateAndTime (year, month, day, weekDay, hour, minute, second, nanos)
	SYSTEMTIME systemTime
'
	GetSystemTime (&systemTime)
	year		= systemTime.year
	month		= systemTime.month
	day			= systemTime.day
	weekDay	= systemTime.weekDay
	hour		= systemTime.hour
	minute	= systemTime.minute
	second	= systemTime.second
	nanos		= systemTime.msec * 1000000
END FUNCTION
'
'
' ###########################################
' #####  XstGetDateAndTimeFormatted ()  #####
' ###########################################
'
'PURPOSE	: Provide the current date and time in a formatted string
'IN				: language (see list below, 0 = English)
'						dateFormat (see list below)
'						timeFormat (see list below)
'OUT			: date$, time$
'USE			: XstGetDateAndTimeFormatted (0, 3, @date$, 6, @time$)
'
'*****  language values  *****
' English = 0
' French  = 1

'*****  date format  *****  example  *****
'	dateFormat =  0 : 2001/01/12
'	dateFormat =  1 : 01/12/2001
'	dateFormat =  2 : 01/12/01
'	dateFormat =  3 : Friday, 01/12/01
'	dateFormat =  4 : 12/01/2001
'	dateFormat =  5 : 12/01/01
'	dateFormat =  6 : Friday, 12/01/01
'	dateFormat =  7 : Friday, January 12, 2001
'	dateFormat =  8 : January 12, 2001
'	dateFormat =  9 : 12 January, 2001
'	dateFormat = 10 : 12-Jan-01
'	dateFormat = 11 : Jan-01
'	dateFormat = 12 : Fri, 12 Jan 2001
'
' *****  time format  *****  example  *****
'	timeFormat = 0 : 19:31 GMT
'	timeFormat = 1 : 19:31:31 GMT
'	timeFormat = 2 : 20:31 +0100 GMT
'	timeFormat = 3 : 20:31 +0100 GMT
'	timeFormat = 4 : 20:31
'	timeFormat = 5 : 20:31:31
'	timeFormat = 6 : 07:31 PM GMT
'	timeFormat = 7 : 07:31:31 PM GMT
'	timeFormat = 8 : 08:31 PM +0100 GMT
'	timeFormat = 9 : 08:31:31 PM +0100 GMT
'
FUNCTION  XstGetDateAndTimeFormatted (language, dateFormat, @date$, timeFormat, @time$)

	$MaxDate = 12
	$MaxTime = 9

	STATIC day$[], month$[], entry

	IF dateFormat > $MaxDate THEN dateFormat = 0
	IF timeFormat > $MaxTime THEN timeFormat = 0

	IFZ entry THEN GOSUB Initialize

	XstGetDateAndTime (@year, @month, @day, @weekday, @hour, @minute, @second, @nano)

	SELECT CASE dateFormat
		CASE 0		: date$ = STRING$(year) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2)

		CASE 1		: date$ = RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2) + "/" + STRING$(year)
		CASE 2		: date$ = RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$(STRING$(year),2)
		CASE 3		: date$ = day$[weekday] + ", " + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$(STRING$(year),2)

		CASE 4		: date$ = RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + STRING$(year)
		CASE 5		: date$ = RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$(STRING$(year),2)
		CASE 6		: date$ = day$[weekday] + ", " + RIGHT$("00" + STRING$(day), 2) + "/" + RIGHT$("00" + STRING$(month), 2) + "/" + RIGHT$(STRING$(year),2)

		CASE 7		: date$ = day$[weekday] + ", " + month$[month] + " " + STRING$(day) + ", " + STRING$(year)
		CASE 8		: date$ = month$[month] + " " + STRING$(day) + ", " + STRING$(year)
		CASE 9		: date$ = STRING$(day) + " " + month$[month] + ", " + STRING$(year)
		CASE 10		: date$ = STRING$(day) + "-" + LEFT$(month$[month], 3) + "-" + RIGHT$(STRING$(year),2)
		CASE 11		: date$ = LEFT$(month$[month], 3) + "-" + RIGHT$(STRING$(year),2)
		CASE 12		: date$ = LEFT$(day$[weekday], 3) + ", " + STRING$(day) + " " + LEFT$(month$[month],3) + " " + STRING$(year)
	END SELECT

	XstGetLocalDateAndTime (0, 0, 0, 0, @localHour, 0, 0, 0)
	IF localHour = 0 THEN
		diffGMT = 24 - hour
	ELSE
		diffGMT = localHour - hour
	END IF
	sign = SIGN(diffGMT)
	IF sign > 0 THEN sign$ = "+" ELSE sign$ = "-"

	IF timeFormat > 5 THEN
		IF (hour < 12) THEN part1$ = " AM" ELSE part1$ = " PM" : hour = hour - 12
		IF (localHour < 12) THEN part2$ = " AM" ELSE part2$ = " PM" : localHour = localHour - 12
	END IF

	SELECT CASE timeFormat
			CASE 0		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + " GMT"
			CASE 1		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + " GMT"
			CASE 2		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
			CASE 3		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
			CASE 4		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2)
			CASE 5		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2)

			CASE 6		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + part1$  + " GMT"
			CASE 7		: time$ = RIGHT$("00" + STRING$(hour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + part1$  + " GMT"
			CASE 8		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + part2$  + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
			CASE 9		: time$ = RIGHT$("00" + STRING$(localHour), 2) + ":" + RIGHT$("00" + STRING$(minute), 2) + ":" + RIGHT$("00" + STRING$(second), 2) + part2$  + " " + sign$ + RIGHT$("00" + STRING$(ABS(diffGMT)) + "00", 4) + " GMT"
	END SELECT
	RETURN

' ***** Initialize *****
SUB Initialize
	entry = $$TRUE
	DIM day$[6]
	DIM month$[12]

	SELECT CASE language
		CASE 0 :
			day$[0] = "Sunday"
			day$[1] = "Monday"
			day$[2] = "Tuesday"
			day$[3] = "Wednesday"
			day$[4] = "Thursday"
			day$[5] = "Friday"
			day$[6] = "Saturday"
			month$[1] = "January"
			month$[2] = "February"
			month$[3] = "March"
			month$[4] = "April"
			month$[5] = "May"
			month$[6] = "June"
			month$[7] = "July"
			month$[8] = "August"
			month$[9] = "September"
			month$[10]= "October"
			month$[11]= "November"
			month$[12]= "December"
		CASE 1 :
			day$[0] = "Dimanche"
			day$[1] = "Lundi"
			day$[2] = "Mardi"
			day$[3] = "Mercredi"
			day$[4] = "Jeudi"
			day$[5] = "Vendredi"
			day$[6] = "Samedi"
			month$[1] = "Janvier"
			month$[2] = "Fevrier"
			month$[3] = "Mars"
			month$[4] = "Avril"
			month$[5] = "Mai"
			month$[6] = "Juin"
			month$[7] = "Juillet"
			month$[8] = "Ao" + CHR$(0x96) + "t"
			month$[9] = "Septembre"
			month$[10]= "Octobre"
			month$[11]= "Novembre"
			month$[12]= "Decembre"
	END SELECT
END SUB

END FUNCTION
'
'
' #######################################
' #####  XstGetLocalDateAndTime ()  #####
' #######################################
'
'* Get the local date and time. This retrieves the date and time in the local
' timezone.
'
' @param year			The year (0000 .. 9999)
' @param month		The month (1 .. 12)
' @param day			The day of the month (1 .. 31)
' @param weekDay	The day of the week (sunday=0 .. saturday=6)
' @param hour			The hour (00 .. 23)
' @param minute		The minute (00 .. 59)
' @param second		The second (00 .. 59)
' @param nanos		The nanoseconds (0 .. 999999999)
'
' @see XstGetDateAndTime
'
FUNCTION  XstGetLocalDateAndTime (year, month, day, weekDay, hour, minute, second, nanos)
	SYSTEMTIME systemTime
'
	GetLocalTime (&systemTime)
	year		= systemTime.year
	month		= systemTime.month
	day			= systemTime.day
	weekDay	= systemTime.weekDay
	hour		= systemTime.hour
	minute	= systemTime.minute
	second	= systemTime.second
	nanos		= systemTime.msec * 1000000
END FUNCTION
'
'
' #############################
' #####  XstGetEndian ()  #####
' #############################
'
FUNCTION  XstGetEndian (endian$$)
	AUTOX		temp$$
'
	addr = &temp$$
	UBYTEAT (addr,0) = 0x00
	UBYTEAT (addr,1) = 0x01
	UBYTEAT (addr,2) = 0x02
	UBYTEAT (addr,3) = 0x03
	UBYTEAT (addr,4) = 0x04
	UBYTEAT (addr,5) = 0x05
	UBYTEAT (addr,6) = 0x06
	UBYTEAT (addr,7) = 0x07
'
	endian$$ = temp$$
END FUNCTION
'
'
' #################################
' #####  XstGetEndianName ()  #####
' #################################
'
FUNCTION  XstGetEndianName (name$)
'
	name$ = "LittleEndian"
END FUNCTION
'
'
' ###########################################
' #####  XstGetEnvironmentVariables ()  #####
' ###########################################
'
FUNCTION  XstGetEnvironmentVariables (@count, envp$[])
'
	count = 0
	index = 0
	DIM envp$[1023]
	addr = GetEnvironmentStrings ()
'
	IF addr THEN
		DO
			line$ = XstNextCLine$ (addr, @index, @done)
			IF line$ THEN
				envp$[count] = line$
				INC count
			END IF
		LOOP WHILE line$
	END IF
'
	IF addr THEN FreeEnvironmentStringsA (addr)

	upper = count - 1
	REDIM envp$[upper]
END FUNCTION
'
'
' #############################
' #####  XstGetOSName ()  #####
' #############################
'
' PURPOSE	: Return the operating system name.
'	OUT			:	name$	- OS name string.
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstGetOSName (@name$)
	EXTERNAL /shr_data/ errno

	OSVERSIONINFO os
'
	os.dwOSVersionInfoSize = SIZE(OSVERSIONINFO)
'
	IF GetVersionExA(&os) THEN
		csdVersion = XLONG(TRIM$(os.szCSDVersion))
  	SELECT CASE os.dwPlatformId
'
			CASE 1 :
				IF os.dwMinorVersion = 0  THEN
					IF csdVersion <> 66 && csdVersion <> 67 THEN name$ = "Windows 95"
					IF csdVersion = 66 || csdVersion = 67 THEN name$ = "Windows 95 OSR2"
				END IF
'
				IF os.dwMinorVersion = 10 THEN
					IF csdVersion = 65 THEN name$ = "Windows 98 Second Edition"
					IF csdVersion <> 65 THEN name$ = "Windows 98"
				END IF
'
				IF os.dwMinorVersion = 90 THEN name$ = "Windows Millennium"
'
			CASE 2 :   											'  Windows NT 3.51
				IF os.dwMajorVersion = 3 THEN name$ = "Windows NT 3.51"
				IF os.dwMajorVersion = 4 THEN name$ = "Windows NT 4.0"

				IF os.dwMajorVersion = 5 THEN
					IF os.dwMinorVersion = 0 THEN name$ = "Windows 2000"
					IF os.dwMinorVersion = 1 THEN name$ = "Windows XP"
				END IF
		END SELECT
		RETURN
	END IF
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ################################
' #####  XstGetOSVersion ()  #####
' ################################
'
' PURPOSE	: Return version info on operation system
'	OUT			:	major	- major version number
'						minor	- minor version number
'						platformID - platform ID
'						version$	- major+minor string
'						platform$	- string; "win32s", "Windows", or "NT"
'
FUNCTION  XstGetOSVersion (@major, @minor, @platformId, @version$, @platform$)
	EXTERNAL /shr_data/ errno

	OSVERSIONINFO os

	os.dwOSVersionInfoSize = SIZE(OSVERSIONINFO)
'
	IF GetVersionExA (&os) THEN
		major = os.dwMajorVersion
		minor = os.dwMinorVersion
		platformId = os.dwPlatformId
		version$ = STRING$(major) + "." + STRING$(minor)
		SELECT CASE platformId
			CASE 0: platform$ = "Win32s"
			CASE 1: platform$ = "Windows"
			CASE 2: platform$ = "NT"
		END SELECT
		RETURN
	END IF
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	lastErr = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION

'* Retrieve the full path and filename of the executable
' @return	The full path and filename of the executable.
FUNCTION XstGetProgramFileName$()
	file$ = NULL$(256)
	ret = GetModuleFileNameA(0, &file$, 256)
	file$ = LEFT$(file$, ret)
	RETURN (file$)
END FUNCTION
'
'
' #################################
' #####  XstGetSystemTime ()  #####
' #################################
'
' PURPOSE	: Return program free running time.
' OUT 		:	msec - 	The number of milliseconds that have elapsed
'										since this program was started.
'
FUNCTION  XstGetSystemTime (@msec)
	STATIC  start
'
' get reference time - return zero if not available
'
	IFZ start THEN
		start = GetTickCount()					' msec reference time
		IF (start > 0) THEN DEC start		' make sure min is 1ms
	END IF
'
	now = GetTickCount()							' msec time now
	msec = now - start								' msec since reference time
END FUNCTION
'
'
' #######################
' #####  XstLog ()  #####
' #######################
'
' style = 0  (default, add time/date stamp)
' style = 1  (no time/date stamp)

FUNCTION  XstLog (message$, style, fileName$)
	STATIC  enter
'
	IFZ fileName$ THEN fileName$ = "x.log"

	IFZ style THEN
		XstGetDateAndTime (@year, @month, @day, 0, @hour, @min, @sec, @nanos)
'		stamp$ = RIGHT$("000" + STRING$(year),4) + RIGHT$("0" + STRING$(month),2) + RIGHT$("0" + STRING$(day),2) + ":" + RIGHT$("0" + STRING$(hour),2) + RIGHT$("0" + STRING$(min),2) + RJUST$("0" + STRING$(sec),2) + "." + RIGHT$("000" + STRING$(nanos\1000000),3) + ": "
		stamp$ = RIGHT$("000" + STRING$(year),4) + "-" + RIGHT$("0" + STRING$(month),2) + "-" + RIGHT$("0" + STRING$(day),2) + "  " + RIGHT$("0" + STRING$(hour),2) + ":" +  RIGHT$("0" + STRING$(min),2) + ":" + RJUST$("0" + STRING$(sec),2) + "  "
		message$ = stamp$ + message$
	END IF
'
	IFZ enter THEN
		enter = $$TRUE
		ofile = OPEN (fileName$, $$WRNEW)
	ELSE
		ofile = OPEN (fileName$, $$WR)
	END IF
'
	IF (ofile >= 3) THEN
		length = LOF (ofile)
		SEEK (ofile, length)
		PRINT [ofile], message$
		CLOSE (ofile)
	END IF
END FUNCTION
'
'
' ###########################################
' #####  XstSetCommandLineArguments ()  #####
' ###########################################
'
FUNCTION  XstSetCommandLineArguments (argc, @argv$[])
	SHARED  setarg
	SHARED  setargc
	SHARED  setargv$[]
'
	upper = UBOUND (argv$[])
	ucount = upper + 1
	setarg = $$TRUE
	setargc = argc
	DIM setargv$[]
'
	IF (setargc > ucount) THEN setargc = ucount
'
	IF argv$[] THEN
		DIM setargv$[upper]
		FOR i = 0 TO upper
			setargv$[i] = argv$[i]
		NEXT i
	END IF
END FUNCTION
'
'
' ##################################
' #####  XstSetDateAndTime ()  #####
' ##################################
'
FUNCTION  XstSetDateAndTime (year, month, day, weekDay, hour, minute, second, nanos)
	EXTERNAL /shr_data/ errno
	SYSTEMTIME systemTime
'
	systemTime.year			= year
	systemTime.month		= month
	systemTime.day			= day
	systemTime.weekDay	= weekDay
	systemTime.hour			= hour
	systemTime.minute		= minute
	systemTime.second		= second
	systemTime.msec			= nanos \ 1000000
	IFZ SetSystemTime (&systemTime) THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ##########################################
' #####  XstSetEnvironmentVariable ()  #####
' ##########################################
'
FUNCTION  XstSetEnvironmentVariable (name$, value$)
	EXTERNAL /shr_data/ errno
'
	length = LEN (value)
	IFZ name$ THEN RETURN
	IF (length <= 0) THEN value$ = ""
'
	okay = SetEnvironmentVariableA (&name$, &value$)
'
	IFZ okay THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF

END FUNCTION
'
'
' #########################
' #####  XstSleep ()  #####
' #########################
'
FUNCTION  XstSleep (ms)
'
	delta = ms
	start = GetTickCount()
'
' sleep system: system should be smart enough not to sleep too long !!!
'
	DO
		Sleep (delta)
		time = GetTickCount()
		delta = ms - (time - start)
	LOOP UNTIL (delta <= 0)
	RETURN

END FUNCTION
'
'
' ###########################
' #####  XstBinRead ()  #####
' ###########################
'
FUNCTION  XstBinRead (fileNumber, bufferAddr, maxBytes)
	EXTERNAL /shr_data/ errno

	AUTOX bytesRead
'
	error = XxxReadFile (fileNumber, bufferAddr, maxBytes, &bytesRead, 0)
	IF error THEN RETURN ($$TRUE)
	RETURN (bytesRead)
END FUNCTION
'
'
' ############################
' #####  XstBinWrite ()  #####
' ############################
'
FUNCTION  XstBinWrite (fileNumber, bufferAddr, numBytes)
	EXTERNAL /shr_data/ errno
	AUTOX  bytesWritten
'
	error = XxxWriteFile (fileNumber, bufferAddr, numBytes, &bytesWritten, 0)
	IF error THEN RETURN ($$TRUE)
	RETURN (bytesWritten)
END FUNCTION
'
'
' ###################################
' #####  XstChangeDirectory ()  #####
' ###################################
'
'	newDirectory$:  may be absolute \dir1\dir2\dir3
'											or relative  dir1\dir2
'
'	return	:	$$TRUE		error (ERROR() set)
'						$$FALSE		no error
'
FUNCTION  XstChangeDirectory (d$)
	EXTERNAL /shr_data/ errno
'
	IFZ d$ THEN RETURN ($$FALSE)
	dir$ = XstPathString$ (@d$)
'
	okay = SetCurrentDirectoryA (&dir$)
'
	IF okay THEN
		RETURN ($$FALSE)
	END IF
'
'	error
'
	errno = GetLastError ()
'
	XstSystemErrorToError (errno, @error)
	errLast = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' #################################
' #####  XstCopyDirectory ()  #####
' #################################
'
' PURPOSE	: Copy all files and sub-folders in source directory path
'						to destination directory path.
'	IN			: source$	- source directory path
'						dest$		- destination directory path
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstCopyDirectory (source$, dest$)
	FILEINFO  info[]
'
	IFZ dest$ THEN
		error = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument)
		error = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IFZ source$ THEN
		error = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument)
		error = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IF (source$ = dest$) THEN
		error = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument)
		error = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	d$ = XstPathString$ (@dest$)
	s$ = XstPathString$ (@source$)
	IF (d${UBOUND(d$)} = $$PathSlash) THEN d$ = RCLIP$ (d$, 1)		' remove trailing /
	IF (s${UBOUND(s$)} = $$PathSlash) THEN s$ = RCLIP$ (s$, 1)		' remove trailing /
'
	XstGetFileAttributes (@s$, @sattr)
	IFZ (sattr AND $$FileDirectory) THEN
		error = (($$ErrorObjectDirectory << 8) OR $$ErrorNatureInvalidArgument)
		error = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	XstGetFileAttributes (@d$, @dattr)
	IFZ (dattr AND $$FileDirectory) THEN
		error = (($$ErrorObjectDirectory << 8) OR $$ErrorNatureInvalidArgument)
		error = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
' create all subdirectories
'
	error = 0
	DIM file$[]
	attr = $$TRUE
'	attr = $$FileDirectory
	ss$ = s$ + $$PathSlash$ + "*"
	XstGetFilesAndAttributes (@ss$, attr, @file$[], @info[])
'
' create destination subdirectories
'
	IF file$[] THEN
		upper = UBOUND (file$[])
		FOR i = 0 TO upper
			file$ = file$[i]
			IF file$ THEN
				IF (file$ != ".") THEN
					IF (file$ != "..") THEN
						sattr = info[i].attributes
						IF (sattr AND $$FileDirectory) THEN
							dd$ = d$ + $$PathSlash$ + file$
							XstGetFileAttributes (@dd$, @dattr)
							IFZ dattr THEN
								XstMakeDirectory (@dd$)
							ELSE
								IFZ (dattr AND $$FileDirectory) THEN
									error = (($$ErrorObjectDirectory << 8) OR $$ErrorNatureContention)
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		NEXT i
	END IF
'
' copy all files in source directory into destination directory
'
	IF file$[] THEN
		upper = UBOUND (file$[])
		FOR i = 0 TO upper
			file$ = file$[i]
			IF file$ THEN
				IF (file$ != ".") THEN
					IF (file$ != "..") THEN
						sattr = info[i].attributes
						IF sattr THEN
							IFZ (sattr AND $$FileDirectory) THEN
								dd$ = d$ + $$PathSlash$ + file$
								XstGetFileAttributes (@dd$, @dattr)
								IF (dattr AND $$FileDirectory) THEN
									error = (($$ErrorObjectDirectory << 8) OR $$ErrorNatureContention)
								ELSE
									ss$ = s$ + $$PathSlash$ + file$
									XstCopyFile (@ss$, @dd$)
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
		NEXT i
	END IF
'
' recurse into subdirectories
'
	IF file$[] THEN
		FOR i = 0 TO upper
			file$ = file$[i]
			IF file$ THEN
				IF (file$ != ".") THEN
					IF (file$ != "..") THEN
						sattr = info[i].attributes
						IF (sattr AND $$FileDirectory) THEN
							dd$ = d$ + $$PathSlash$ + file$
							XstGetFileAttributes (@dd$, @dattr)
							IF (dattr AND $$FileDirectory) THEN
								ss$ = s$ + $$PathSlash$ + file$
								dd$ = d$ + $$PathSlash$ + file$
								XstCopyDirectory (@ss$, @dd$)
							END IF
						END IF
					END IF
				END IF
			END IF
		NEXT i
	END IF
'
	IF error THEN e = ERROR (error)
	RETURN (error)
END FUNCTION
'
'
' ############################
' #####  XstCopyFile ()  #####
' ############################
'
FUNCTION  XstCopyFile (s$, d$)
	EXTERNAL /shr_data/ errno
'
	IF (s$ = d$) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IFZ s$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IFZ d$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	source$ = XstPathString$ (@s$)
	dest$ = XstPathString$ (@d$)
'
	okay = CopyFileA (&source$, &dest$, $$FALSE)		' overwrite if exists
'
	IFZ okay THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' #####################################
' #####  XstDecomposePathname ()  #####
' #####################################
'
FUNCTION  XstDecomposePathname (pathname$, @path$, @parent$, @filename$, @file$, @extent$)
'
	path$ = ""
	file$ = ""
	extent$ = ""
	parent$ = ""
	filename$ = ""
	name$ = TRIM$ (pathname$)
	dot = RINSTR (name$, ".")
	slash = getLastSlash(name$, -1)
	IF slash THEN preslash = getLastSlash(name$, slash-1)
	IF (dot < slash) THEN dot = 0
'
	filename$ = MID$ (name$, slash+1)							' filename = "name.ext"
	IFZ dot THEN
		file$ = filename$														' file = filename (filename has no extent)
	ELSE
		file$ = MID$ (name$, slash+1, dot-slash-1)	' file = "name" (without extent)
		extent$ = MID$ (name$, dot)									' extent = ".ext"
	END IF
'
	IF slash THEN
		path$ = LEFT$ (name$, slash-1)							' path = full pathname to left of "/file.ext"
		IF preslash THEN
			parent$ = MID$ (name$, preslash+1, slash-preslash-1)
		ELSE
			parent$ = LEFT$ (name$, slash-1)
		END IF
	END IF
END FUNCTION
'
'
' ##############################
' #####  XstDeleteFile ()  #####
' ##############################
'
' PURPOSE	: Delete a file or empty directory
' IN			: f$	- file or empty directory to delete
' RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstDeleteFile (f$)
	EXTERNAL /shr_data/ errno
'
	IFZ f$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	file$ = XstPathString$ (@f$)
	XstGetFileAttributes (@file$, @attributes)
'
	IFZ attributes THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		errLast = ERROR(error)
		RETURN ($$TRUE)
	END IF
'
	return = $$FALSE
	SELECT CASE TRUE
		CASE (attributes AND $$FileDirectory)
					okay = RemoveDirectoryA (&file$)
					IFZ okay THEN GOSUB Errors
		CASE ELSE
					okay = DeleteFileA (&file$)
					IFZ okay THEN GOSUB Errors
	END SELECT
	RETURN (return)
'
'
'	*****  Errors  *****
'
SUB Errors
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	errLast = ERROR (error)
	return = $$TRUE
END SUB
END FUNCTION
'
'
' ############################
' #####  XstFindFile ()  #####
' ############################
'
' XstFindFile() looks for the specified file$
' in the subdirectories specified in path$[].
' If file$ starts with a path slash, then it
' is assumed to be an absolute path and none
' of the path$[] subdirectories are checked.
'
' The purpose of this function is to find a
' file that might be in more than one place.
' This function searches for the file in the
' subdirectories in the order specified in
' path$[].
'
' If the file is found, path$ is returned
' with the complete path, including the
' filename, and attr contains the file
' attributes.  Note that this function
' does not find directories of the given
' file$ name - it looks for regular files.
'
FUNCTION  XstFindFile (file$, @path$[], @path$, @attr)
'
	a = attr
	attr = 0
	path$ = ""
	error = ERROR(0)
	IFZ file$ THEN RETURN ($$TRUE)
	IFZ path$[] THEN RETURN ($$TRUE)
	upper = UBOUND (path$[])
	IF XstIsAbsolutePath(file$) THEN
		ifile$ = XstPathString$ (@file$)
		GOSUB FindAbsolute
	ELSE
		ifile$ = $$PathSlash$ + file$				' prevent XstPathString$() from taking ifile$ as a
		ifile$ = XstPathString$ (@ifile$)		' relative path and prepending the current directory
		ifile$ = MID$ (ifile$, 2)						' now remove the fake leading path slash
		GOSUB FindRelative
	END IF
	RETURN
'
' *****  FindAbsolute  *****
'
SUB FindAbsolute
	XstGetFileAttributes (@ifile$, @attr)
	IFZ attr THEN
		path$ = ""
		attr = 0
	ELSE
		IF XstAttributeMatch(attr, a) THEN
			path$ = ifile$
		ELSE
			path$ = ""
		END IF
	END IF
END SUB
'
' *****  FindRelative  *****
'
SUB FindRelative
	fslash = 0
	XstGetCurrentDirectory (@dir$)
	IF (ifile${0} = $$PathSlash) THEN fslash = 1
	FOR i = 0 TO upper
		path$ = path$[i]
		IFZ path$ THEN path$ = dir$
		path$ = XstPathString$ (@path$)
		IFZ path$ THEN path$ = dir$
		upath = UBOUND (path$)
		IF (path${upath} = $$PathSlash) THEN pslash = 1
		IF (path${upath} = ':') THEN pslash = 1
		slash = fslash + pslash
		SELECT CASE slash
			CASE 0	:	path$ = path$ + $$PathSlash$ + ifile$
			CASE 1	: path$ = path$ + ifile$
			CASE 2	: path$ = path$ + MID$ (ifile$, 2)
		END SELECT
		XstGetFileAttributes (@path$, @attr)
		IF attr THEN
			IF XstAttributeMatch(attr, a) THEN EXIT FOR
		END IF
		path$ = ""
		attr = 0
	NEXT i
	error = ERROR(0)
	IF attr THEN
		IF path$ THEN
			IF (path${0} != $$PathSlash) THEN
				XstPathToAbsolutePath (@path$, @absolute$)
				path$ = absolute$
			END IF
		END IF
	END IF
END SUB
END FUNCTION
'
'
' #############################
' #####  XstFindFiles ()  #####
' #############################
'
' PURPOSE	: Return all files in basepath$ that match filter$ in
'						array file$[]. If recurse is $$TRUE, then recurse
'						through all sub-directories to find further matches.
'	IN			: basepath$	- path$ to begin search, default is current directory
'						filter$		- file filter, "*" and "?" wildcards allowed; *.x; tmp.00?
'						recurse		- if $$TRUE, then recursion is used
'	OUT			:	file$[]		- array of matching files
' RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstFindFiles (basepath$, filter$, recurse, @file$[])
	FILEINFO  fileinfo[]

	path$ = XstPathString$(@basepath$)
	IFZ path$ THEN XstGetCurrentDirectory (@path$)
'
	XstGetFileAttributes (@path$, @attribute)
	IFZ (attribute AND $$FileDirectory) THEN RETURN ($$TRUE)
'
	DIM new$[]
	ufile = UBOUND (file$[])
	pathend$ = RIGHT$ (path$, 1)
	attributeFilter = NOT $$FileDirectory
	IF ((pathend$ != $$PathSlash$) AND (pathend$ != "/")) THEN path$ = path$ + $$PathSlash$
'
	XstGetFilesAndAttributes (path$ + filter$, attributeFilter, @new$[], @fileinfo[])
	ifile = ufile + 1
'
' append names of matching files to end of file$[]
'
	IF new$[] THEN
		upper = UBOUND (new$[])
		DIM order[upper]
		XstQuickSort (@new$[], @order[], 0, upper, $$SortIncreasing)
		ufile = ufile + upper + 1
		REDIM file$[ufile]
		FOR i = 0 TO upper
			IFZ (fileinfo[order[i]].attributes AND $$FileDirectory) THEN
				IF new$[i] THEN file$[ifile] = path$ + new$[i] : INC ifile
			END IF
		NEXT i
		DIM new$[]
		DIM order[]
	END IF
'
	DEC ifile
	ufile = ifile
	REDIM file$[ufile]
	IFZ recurse THEN RETURN
'
' recurse down directories
'
	dirfilter$ = path$ + "*"
	attributeFilter = $$FileDirectory
	XstGetFilesAndAttributes (@dirfilter$, attributeFilter, @dir$[], @fileinfo[])
'
	IFZ dir$[] THEN RETURN									' no sub-directories to search
'
' sort array of directories to recurse
'
	upper = UBOUND (dir$[])
	DIM order[upper]
	XstQuickSort (@dir$[], @order[], 0, upper, $$SortIncreasing)
'
	FOR i = 0 TO upper
		dir$ = path$ + dir$[i]
		XstFindFiles (@dir$, @filter$, recurse, @file$[])
	NEXT i
END FUNCTION
'
'
' #######################################
' #####  XstGetCurrentDirectory ()  #####
' #######################################
'
' PURPOSE	: return current directory path
'	OUT			:	current$	- current directory path
'						on error, current$ = ""
'	RETURN	: 0 on success, -1 on failure
'
'	Note: Only "\" terminates with "\"
'
FUNCTION  XstGetCurrentDirectory (@current$)
	EXTERNAL /shr_data/ errno
	AUTOX dir$
'
	dir$ = NULL$(255)												' 256 including terminating null
'
	a = GetCurrentDirectoryA (256, &dir$)
	IFZ a THEN GOTO error
'
	IF (a >= 256) THEN
		INC a																			' add terminator
		dir$ = NULL$ (a)
'
		a = GetCurrentDirectoryA (a, &dir$)
		IFZ a THEN GOTO error
	END IF
'
	dir$ = TRIM$ (dir$)
	lenDir = LEN (dir$)													' only "\" terminates with "\"
	IF (lenDir > 1) THEN
		IF dir${lenDir - 1} = '\\' THEN
			dir$ = RCLIP$ (dir$, 1)
		END IF
	END IF
'
	current$ = dir$
	RETURN
'
'	Error
'
'	EACCES	Read or search permission denied for a component of the path
'	EINVAL	SIZE <= 0
'	ERANGE	0 < SIZE <= length of the pathname plus 1
'
error:
	errno = GetLastError ()
	current$ = ""
'
	XstSystemErrorToError (errno, @error)
	errLast = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' #############################
' #####  XstGetDrives ()  #####
' #############################
'
FUNCTION  XstGetDrives (count, drive$[], driveType[], driveType$[])
	STATIC	driveTypes$[]
'
	IFZ driveTypes$[] THEN GOSUB Initialize
'
	count = 0
	DIM drive$[63]
	DIM driveType[63]
	DIM driveType$[63]
'
	buffer$ = NULL$(255)
	length = GetLogicalDriveStringsA (255, &buffer$)
'
' if GetLogicalDriveStringsA() not implemented (as on Win32s)
'
	count = 0
	IF (length < 1) THEN
		drives = GetLogicalDrives ()
'
		FOR i = 0 TO 31
			mask = 1 << i
			IF (drives AND mask) THEN
				drive$[count] = CHR$('A'+i) + ":"
				driveType[count] = $$DriveTypeUnknown
				driveType$[count] = "Unknown"
				INC count
			END IF
		NEXT i
		upper = count - 1
		REDIM drive$[upper]
		REDIM driveType[upper]
		REDIM driveType$[upper]
		RETURN ($$FALSE)
	END IF
'
' if GetLogicalDriveStringsA() is implemented
'
	i = 0
	n = 0
	DO
		drive$ = ""
		GOSUB GetDriveName
		IFZ drive$ THEN EXIT DO
		drive$[count] = drive$
		dt = GetDriveTypeA (&drive$)
		driveType$[count] = driveTypes$[dt]
		driveType[count] = dt
		upper = count
		INC count
	LOOP WHILE (count < 63)
'
	REDIM drive$[upper]
	REDIM driveType[upper]
	REDIM driveType$[upper]
	RETURN
'
'
' *****  GetDriveName  *****
'
SUB GetDriveName
	drive = 0
	drive$ = NULL$(255)
	DO WHILE (i <= 255)
		c = buffer${i}
		INC i
		IFZ c THEN EXIT DO
		drive${drive} = c
		INC drive
	LOOP
	IFZ drive THEN drive$ = "" ELSE drive$ = LEFT$(drive$,drive)
END SUB
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM driveTypes$[ 15]
	driveTypes$[ $$DriveTypeUnknown ]			= "Unknown"
	driveTypes$[ $$DriveTypeDamaged ]			= "Rootless"
	driveTypes$[ $$DriveTypeRemovable ]		= "RemovableMedia"
	driveTypes$[ $$DriveTypeFixed ]				= "FixedMedia"
	driveTypes$[ $$DriveTypeRemote ]			= "Remote"
	driveTypes$[ $$DriveTypeCDROM ]				= "CDROM"
	driveTypes$[ $$DriveTypeRamDisk ]			= "RamDisk"
END SUB
END FUNCTION
'
'
' ######################################
' #####  XstGetExecutionPathArray  #####
' ######################################
'
FUNCTION  XstGetExecutionPathArray (@path$[])
'
	DIM path$[]
	XstGetEnvironmentVariable (@"PATH", @path$)
	IFZ path$ THEN
		XstGetEnvironmentVariable (@"path", @path$)
		IFZ path$ THEN
			XstGetEnvironmentVariable (@"Path", @path$)
		END IF
	END IF
	IFZ path$ THEN RETURN
'
' count number of elements (separated by colons)
'
	colon = 0
	upper = UBOUND (path$)
	FOR i = 0 TO upper
		IF path${i} = $$PathSeparator THEN
			INC colon
			top = i
		END IF
	NEXT i
'
	k = 1
	last = 0
	IF (top = upper) THEN DEC colon
	DIM path$[colon]
'
	FOR i = 0 TO colon
		IF path$ THEN
			k = INCHR (path$, $$PathSeparator$, k)
			IFZ k THEN
				path$[i] = MID$ (path$, last+1)
			ELSE
				path$[i] = MID$ (path$, last+1, k-last-1)
				last = k
				INC k
			END IF
		END IF
	NEXT i
END FUNCTION
'
'
' #####################################
' #####  XstGetFileAttributes ()  #####
' #####################################
'
' PURPOSE	: Return attributes of a file.
'	IN			: f$	- file name
'	OUT			: attributes	- file attributes
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstGetFileAttributes (f$, @attributes)
	EXTERNAL /shr_data/ errno
'
	$mask = 0x03B7								' Windows attributes
'
	attributes = 0
	IFZ f$ THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureEmpty)
 		RETURN ($$TRUE)
	END IF
	file$ = XstPathString$ (@f$)
'
	attributes = GetFileAttributesA (&file$)
'
	IF (attributes = -1) THEN				' no such file
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		lastErr = ERROR (error)
'		SetLastError (0)
		attributes = 0
		RETURN ($$TRUE)
	END IF
'
	attributes = attributes AND $mask
	dot = RINSTR (file$, ".")
'
	IF dot THEN
		extent$ = LCASE$(MID$(file$,dot))
		SELECT CASE extent$
			CASE ".com"	:	attributes = attributes OR $$FileExecutable
			CASE ".exe"	:	attributes = attributes OR $$FileExecutable
		END SELECT
	END IF
END FUNCTION
'
'
' ############################
' #####  XstGetFiles ()  #####
' ############################
'
'	filter$ may be a file (which may include wildcards) or a directory
'		- files retain any leading directory path from filter$
'		- wildcards match any file or directory
'
'	files$[] is a sorted list of all files and directories
'		- dirs have "\" or "/" appended ($$PathSlash$)
'
' RETURN:		max length of match names
'				  	0			no matches
'					 -1			if error
'
'	filter$ is modified
' Does NOT prefix path to each file name
'	number of matches = UBOUND(files$[]) + 1
'
FUNCTION  XstGetFiles (f$, @files$[])
	FILEINFO	findData
	AUTOX  findHandle
'
	DIM files$[]
	DIM findData[255]															' name starts at [11]
'
	filter$ = XstPathString$ (@f$)
	XstGetFileAttributes (@filter$, @attributes)	' Is filter$ a valid directory?
'
	IF (attributes AND $$FileDirectory) THEN
		path$ = filter$
	ELSE
		IF attributes THEN													' Is this a specific file?
			DIM files$[0]
			files$[0] = filter$
			RETURN (LEN(filter$))
		END IF
		path$ = ""
		slash = RINSTR (filter$, "\\")
		IF slash THEN
			path$		= LEFT$(filter$, slash - 1)
			XstGetFileAttributes (@path$, @attributes)		' path better exist
			IFZ attributes THEN RETURN (-1)
			IFZ (attributes AND $$FileDirectory) THEN RETURN (0)
		END IF
	END IF
	IF (LEN(path$) > 1) THEN
		IF (path${UBOUND(path$)} != '\\') THEN path$ = path$ + "\\"
	END IF
'
	findData.name = ""
	findHandle = FindFirstFileA (&filter$, &findData)
'
	ifile = -1
	maxLength = 0
	IF (findHandle != -1) THEN
		ufiles = 127
		DIM files$[ufiles]
		DO
			attr = findData.attributes
			file$ = TRIM$(findData.name)
			IF ((file$ != ".") AND (file$ != "..")) THEN
				IF (attr AND $$FileDirectory) THEN file$ = file$ + "\\"
				INC ifile
				IF (ifile > ufiles) THEN
					ufiles = ufiles + (ufiles >> 1)
					REDIM files$[ufiles]
				END IF
				lenFile = LEN(file$)
				IF (lenFile > maxLength) THEN maxLength = lenFile
				ATTACH file$ TO files$[ifile]
			END IF
			findData.name = ""
			found = FindNextFileA (findHandle, &findData)
		LOOP WHILE found
		FindClose (findHandle)
	END IF
'
	IF (ifile < 0) THEN
		DIM files$[]
		RETURN (0)
	END IF
'
	IF (ifile != ufiles) THEN REDIM files$[ifile]
	RETURN (maxLength)
END FUNCTION
'
'
' #########################################
' #####  XstGetFilesAndAttributes ()  #####
' #########################################
'
FUNCTION  XstGetFilesAndAttributes (f$, attributesFilter, files$[], FILEINFO fileInfo[])
	FILEINFO	fileinfo
'
	$mask = 0x03B7														' defined attribute bits
'
	IFZ f$ THEN
		DIM files$[]
		DIM fileInfo[]													' no files yet
		RETURN (-1)															' Bogus filter (empty string)
	END IF
'
	file = 0
	uFiles = 255
	DIM files$[uFiles]
	IFZ fileInfo[] THEN
		DIM fileInfo[uFiles]										' start with room for 256 files
	ELSE
		REDIM fileInfo[0]												' trash excess entries
		fileInfo[0] = fileinfo									' initialize 0th entry
		REDIM fileInfo[uFiles]									' REDIM keeps input TYPE #
	END IF
	filter$ = XstPathString$ (@f$)
'
	findHandle = FindFirstFileA (&filter$, &fileInfo[file])
'
	maxLength = 0
	IF (findHandle != -1) THEN
		DO
			file$ = TRIM$(fileInfo[file].name)
			attributes = fileInfo[file].attributes
			IFZ attributes THEN
				IF file$ THEN attributes = $$FileNormal		' bug in Windows98
			END IF
'
'			Clear out unused attribute bits; Add executable bit
'
			attributes = attributes AND $mask
			SELECT CASE UCASE$(RIGHT$(file$, 4))
				CASE ".EXE", ".COM"
							attributes = attributes OR $$FileExecutable
			END SELECT
			IF ((file$ != ".") AND (file$ != "..")) THEN
				IF (attributes AND attributesFilter) THEN
					fileInfo[file].attributes = attributes
					IF (file >= (uFiles-1)) THEN
						uFiles = uFiles + uFiles
						REDIM fileInfo[uFiles]
						REDIM files$[uFiles]
					END IF
					lenFile = LEN(file$)
					IF (lenFile > maxLength) THEN maxLength = lenFile
					ATTACH file$ TO files$[file]
					INC file
				END IF
			END IF
'
			found = FindNextFileA (findHandle, &fileInfo[file])
		LOOP WHILE found
'
		FindClose (findHandle)
	END IF
'
	IF (file <= 0) THEN
		DIM fileInfo[]
		DIM files$[]
		RETURN (0)
	END IF
'
	DEC file
	IF (file != uFiles) THEN
		REDIM fileInfo[file]
		REDIM files$[file]
	END IF
	RETURN (maxLength)
END FUNCTION
'
'
' #####################################
' #####  XstGetPathComponents ()  #####
' #####################################
'
FUNCTION  XstGetPathComponents (file$, @path$, @drive$, @dir$, @filename$, @attributes)
'
	dir$ = ""
	work$ = ""
	path$ = ""
	drive$ = ""
	filename$ = ""
	attributes = 0
	file = $$FALSE
'
	dir$ = XstPathString$ (@file$)
	XstGetCurrentDirectory (@current$)
	' TODO: Is this 'right'? Shouldn't the dir$ of "" be ""?
	IFZ dir$ THEN dir$ = current$
'
	colon = INSTR (dir$, ":")
	IF colon THEN
		drive$ = LEFT$ (dir$, colon)
		dir$ = MID$ (dir$, colon+1)
	END IF
'
	upper = UBOUND (dir$)												'
	path$ = drive$ + dir$												'
	XstGetFileAttributes (@path$, @attributes)	' valid directory?
	IF (dir${upper} != $$PathSlash) THEN				' trailing \ means directory
		IF (attributes AND $$FileDirectory) THEN
			path$ = path$ + $$PathSlash$
			dir$ = dir$ + $$PathSlash$
		ELSE
			slash = RINSTR (dir$, $$PathSlash$)			' find last \
			filename$ = MID$ (dir$, slash+1)				' get filename$
			dir$ = LEFT$ (dir$, slash)							' get dir$
			path$ = drive$ + dir$										' path$ w/o filename$
		END IF
	END IF
END FUNCTION
'
'
' #################################
' #####  XstGuessFilename ()  #####
' #################################
'
' if new name contains drive and/or root path slash,
' the new name is the full path or path\filename, so
' ignore the old name.
'
' this function will return $$FileNormal if the file
' does not exist, but the path is valid so that the
' specified file could be created, as is often the
' case for files to be saved (they don't yet exist).
'
' if the return value of attributes is zero, the
' file name is invalid for both read and write.
'
FUNCTION  XstGuessFilename (old$, new$, guess$, attributes)
'
	test$ = ""
	guess$ = ""
	o$ = XstPathString$ (@old$)
	n$ = XstPathString$ (@new$)
'
	IFZ n$ THEN n$ = o$
	IFZ n$ THEN XstGetCurrentDirectory (@n$)
'
	SELECT CASE TRUE
		CASE (n${0} = $$PathSlash)	:	guess$ = n$		' leading \
		CASE (n${1} = ':')					: guess$ = n$		' leading d:
	END SELECT
'
	IFZ guess$ THEN
		IFZ o$ THEN XstGetCurrentDirectory (@o$)
		XstGetFileAttributes (@o$, @attributes)
		SELECT CASE TRUE
			CASE (attributes AND $$FileDirectory)
						path$ = o$
			CASE (attributes = 0)
						XstGetCurrentDirectory (@path$)
			CASE ELSE
						XstGetPathComponents (@o$, @path$, @drive$, @dir$, @file$, @attributes)
		END SELECT
		upath = UBOUND (path$)
		IF (path${upath} != $$PathSlash) THEN path$ = path$ + $$PathSlash$
		guess$ = path$ + n$
	END IF
'
	XstGetFileAttributes (@guess$, @attributes)
'
	IFZ attributes THEN
		XstGetPathComponents (@guess$, @path$, @dr$, @di$, @fi$, @at)
		XstGetFileAttributes (@path$, @att)
		IF (att AND $$FileDirectory) THEN attributes = $$FileNormal
	END IF
END FUNCTION
'
'
'* Is this an absolute path?
' @param file$		The filename
' @return				true: yes, false: no.
FUNCTION XstIsAbsolutePath(file$)
	' A path is absolute if:
	' - It starts with \ or /
	' - It starts with a driveletter, : followed by \ or /
	IF LEN(file$) = 0 THEN RETURN $$FALSE
	IF (file${0} = $$PathSlash) OR (file${0} = '/') THEN RETURN $$TRUE
	' Win32 specific:
	IF LEN(file$) < 3 THEN RETURN $$FALSE
	IF file${1} <> ':' THEN RETURN $$FALSE
	IF (file${2} = $$PathSlash) OR (file${2} = '/') THEN RETURN $$TRUE
	RETURN $$FALSE
END FUNCTION
'
'
' ##############################
' #####  XstLoadString ()  #####
' ##############################
'
FUNCTION  XstLoadString (f$, text$)
'
	text$ = ""
	errLast = ERROR ($$FALSE)
	file$ = XstPathString$ (@f$)
'
	XstGetFileAttributes (@file$, @attributes)					' Does file exist?
	IFZ attributes THEN
		error = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
	IF (attributes AND $$FileDirectory) THEN
		error = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName)
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	ifile = OPEN (file$, $$RD)
	IF (ifile < 0) THEN RETURN ($$TRUE)
	fileSize = LOF(ifile)
	IF fileSize THEN
		text$ = NULL$(fileSize)
		READ [ifile], text$
	END IF
	CLOSE (ifile)
END FUNCTION
'
'
' ###################################
' #####  XstLoadStringArray ()  #####
' ###################################
'
FUNCTION  XstLoadStringArray (f$, text$[])
'
	DIM text$[]
	file$ = XstPathString$ (@f$)
	error = XstLoadString (@file$, @text$)
	IF error THEN RETURN (error)
	XstStringToStringArray (@text$, @text$[])
END FUNCTION
'
'
' #################################
' #####  XstMakeDirectory ()  #####
' #################################
'
FUNCTION  XstMakeDirectory (dir$)
	EXTERNAL /shr_data/ errno
	SECURITY_ATTRIBUTES  securityAttributes
'
	IFZ dir$ THEN
		errLast = ERROR((($$ErrorObjectDirectory << 8) OR $$ErrorNatureInvalidName))
		RETURN ($$TRUE)
	END IF
'
	directory$ = XstPathString$ (@dir$)
	securityAttributes.length = SIZE(SECURITY_ATTRIBUTES)
	securityAttributes.securityDescriptor = 0
	securityAttributes.inherit = 0
'
'	okay = CreateDirectoryA (&directory$, &securityAttributes)
	okay = CreateDirectoryA (&directory$, 0)
'
	IF okay THEN
		RETURN ($$FALSE)
	END IF
'
'	Error
'
	errno = GetLastError ()
'
	XstSystemErrorToError (errno, @error)
	errLast = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ######################################
' #####  XstPathToAbsolutePath ()  #####
' ######################################
'
FUNCTION  XstPathToAbsolutePath (ipath$, @opath$)
	EXTERNAL /shr_data/ errno
'
	opath$ = ""
	opath$ = XstPathString$ (@ipath$)
'
' if relative path, prepend working directory
'
	IFZ opath$ THEN
		XstGetCurrentDirectory (@opath$)
	ELSE
		path$ = NULL$(255)												' 256 including terminating null
		a = GetFullPathNameA(&opath$, 256, &path$, &tmp$)
		IFZ a THEN
			errno = GetLastError ()
			XstSystemErrorToError (errno, @error)
			lastErr = ERROR (error)
			opath$ = ""
			RETURN ($$TRUE)
		END IF
		opath$ = TRIM$(path$)
	END IF
END FUNCTION
'
'
' ##############################
' #####  XstReadString ()  #####
' ##############################
'
FUNCTION  XstReadString (ifile, string$)
	AUTOX ULONG  bytesRead
	AUTOX ULONG  bytes
'
	string$ = ""
	size = SIZE (bytes)
	error = XxxReadFile (ifile, &bytes, size, &bytesRead, 0)
	IF (bytesRead != size) THEN RETURN ($$TRUE)
	IF error THEN RETURN ($$TRUE)
'
	IF bytes THEN
		bytesRead = 0
		string$ = NULL$ (bytes)
		error = XxxReadFile (ifile, &string$, bytes, &bytesRead, 0)
		IF (bytesRead != bytes) THEN RETURN ($$TRUE)
		IF error THEN RETURN ($$TRUE)
	END IF
'
	RETURN ($$FALSE)
END FUNCTION
'
'
' ##############################
' #####  XstRenameFile ()  #####
' ##############################
'
FUNCTION  XstRenameFile (o$, n$)
		EXTERNAL /shr_data/ errno
'
'	PRINT HEX$(&o$,8);; "<"; o$; ">"
'	PRINT HEX$(&n$,8);; "<"; n$; ">"
'
	old$ = TRIM$ (o$)
	new$ = TRIM$ (n$)
'
	IFZ old$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IFZ new$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IF (old$ = new$) THEN RETURN ($$FALSE)
'
	old$ = XstPathString$ (@old$)
	new$ = XstPathString$ (@new$)
'
	XstGetFileAttributes (@old$, @old)			' Does old file exist?
	XstGetFileAttributes (@new$, @new)			' Does new file exist?
'
'	PRINT "attributes old : "; HEX$(old,8)
'	PRINT "attributes new : "; HEX$(new,8)
'
	IFZ old THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	IF new THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureExists
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	okay = MoveFileA (&old$, &new$)
'
	IFZ okay THEN
		errno = GetLastError ()
'
		XstSystemErrorToError (errno, @error)
		errLast = ERROR (error)
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ##############################
' #####  XstSaveString ()  #####
' ##############################
'
FUNCTION  XstSaveString (f$, text$)
'
	IFZ text$ THEN RETURN ($$TRUE)
	IFZ f$ THEN RETURN ($$TRUE)
	errLast = ERROR ($$FALSE)
	file$ = XstPathString$ (@f$)
'
	ofile = OPEN (file$, $$WRNEW)
	IF ERROR(-1) THEN RETURN ($$TRUE)
	IF (ofile < 0) THEN RETURN ($$TRUE)
	WRITE [ofile], text$
	CLOSE (ofile)
END FUNCTION
'
'
' ###################################
' #####  XstSaveStringArray ()  #####
' ###################################
'
FUNCTION  XstSaveStringArray (f$, text$[])
'
	IFZ f$ THEN RETURN ($$TRUE)
	IFZ text$[] THEN RETURN ($$TRUE)
	errLast = ERROR ($$FALSE)
	file$ = XstPathString$ (@f$)
'
	ofile = OPEN (file$, $$WRNEW)
	IF ERROR (-1) THEN RETURN ($$TRUE)
	IF (ofile < 0) THEN RETURN ($$TRUE)
'
	XstStringArrayToString (@text$[], @text$)
	IF text$ THEN WRITE [ofile], text$
'
	CLOSE (ofile)
END FUNCTION
'
'
' #######################################
' #####  XstSaveStringArrayCRLF ()  #####
' #######################################
'
FUNCTION  XstSaveStringArrayCRLF (f$, text$[])
'
	IFZ f$ THEN RETURN ($$TRUE)
	IFZ text$[] THEN RETURN ($$TRUE)
	errLast = ERROR ($$FALSE)
	file$ = XstPathString$ (@f$)
'
	ofile = OPEN (file$, $$WRNEW)
	IF ERROR (-1) THEN RETURN ($$TRUE)
	IF (ofile < 0) THEN RETURN ($$TRUE)
'
	XstStringArrayToStringCRLF (@text$[], @text$)
	IF text$ THEN WRITE [ofile], text$
'
	CLOSE (ofile)
END FUNCTION
'
'
' #######################################
' #####  XstSetCurrentDirectory ()  #####
' #######################################
'
FUNCTION  XstSetCurrentDirectory (dir$)
		EXTERNAL /shr_data/ errno
'
	newDirectory$ = TRIM$ (dir$)
	IFZ newDirectory$ THEN RETURN ($$FALSE)
	newDirectory$ = XstPathString$ (@newDirectory$)
'
	okay = SetCurrentDirectoryA (&newDirectory$)
'
	IF okay THEN
		RETURN ($$FALSE)
	END IF
'
	errno = GetLastError ()
'
	XstSystemErrorToError (errno, @error)
	errLast = ERROR (error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ###############################
' #####  XstWriteString ()  #####
' ###############################
'
FUNCTION  XstWriteString (ofile, @string$)

	AUTOX ULONG  bytesWritten
	AUTOX ULONG  bytes
'
	size = SIZE (bytes)
	bytes = LEN (string$)
	error = XxxWriteFile (ofile, &bytes, size, &bytesWritten, 0)
	IF (bytesWritten != size) THEN RETURN ($$TRUE)
	IF error THEN RETURN ($$TRUE)
'
	IF bytes THEN
		size = bytes
		error = XxxWriteFile (ofile, &string$, size, &bytesWritten, 0)
		IF (bytesWritten != size) THEN RETURN ($$TRUE)
		IF error THEN RETURN ($$TRUE)
	END IF
'
	RETURN ($$FALSE)

END FUNCTION
'
'
' #######################################
' #####  XstBackArrayToBinArray ()  #####
' #######################################
'
FUNCTION  XstBackArrayToBinArray (backArray$[], binArray$[])
'
	upper = UBOUND (backArray$[])
	DIM binArray$[upper]
	FOR i = 0 TO upper
		t$ = backArray$[i]
		t$ = XstBackStringToBinString$ (@t$)
		ATTACH t$ TO binArray$[i]
	NEXT i
END FUNCTION
'
'
' ##########################################
' #####  XstBackStringToBinString$ ()  #####
' ##########################################
'
' Convert string with XBasic backslash characters into a string with
' appropriate unprintable binary bytes (0x00 - 0x1F and 0x80 - 0xFF).
'
' NOTE:  \" becomes 0x22
' NOTE:  \\ becomes 0x5C
' NOTE:  \a \b \t \n \v \f \r become 0x07 0x08 0x09 0x0A 0x0B 0x0C 0x0D
' NOTE:  \0 - \9 become 0x00 - 0x09  (Decimal)
' NOTE:  \A - \F become 0x0A - 0x0F  (Hex extension)  (note: upper case only)
' NOTE:  \G - \V become 0x10 - 0x1F  (Vex extension)  (note: upper case only)
' NOTE:  \Z becomes 0xFF
' NOTE:  This function will process \xHH (hexidecimal) format.
' NOTE:  This function will not process \oOOO (octal) format.
'
FUNCTION  XstBackStringToBinString$ (rawString$)
	SHARED UBYTE  charsetBackslash[]
	SHARED UBYTE  charsetHexLowerToUpper[]
'
	IFZ charsetBackslash[] THEN InitProgram ()
	IFZ rawString$ THEN RETURN ("")
	IFZ (INSTR(rawString$, "\\")) THEN RETURN (rawString$)
'
	lenRawString = LEN (rawString$)
	newString$ = NULL$ (lenRawString)							' length of newString <= rawString
	lastChar = lenRawString - 1
	j = 0
	FOR i = 0 TO lastChar
		rawChar = rawString${i}
		IF (rawChar = '\\') THEN										' backslash character
			IF (i = lastChar) THEN GOTO LastCharacter	' \ is last character
			INC i
			rawChar = rawString${i}
			SELECT CASE rawChar
			CASE 'x'																	' \xHH form
				IF (i = lastChar) THEN EXIT SELECT			' \x -> x
				INC i
				rawHex1 = rawString${i}
				theHex1 = charsetHexLowerToUpper[rawHex1]
				IF theHex1 THEN													' \xHH  (1st H is valid hex)
					IF (i = lastChar) THEN
						rawChar = XLONG ("0x0" + CHR$(theHex1))
						EXIT SELECT
					END IF
					INC i
					rawHex2 = rawString${i}
					theHex2 = charsetHexLowerToUpper[rawHex2]
					IF theHex2 THEN												' \xHH  (2nd H is valid hex)
						rawChar = XLONG ("0x" + CHR$(theHex1) + CHR$(theHex2))
					ELSE																	' \xHH  (2nd H is invalid hex)
						DEC i
						rawChar = XLONG ("0x0" + CHR$(theHex1))
					END IF
				ELSE																		' \xHH  (1st H is invalid hex)
					DEC i
				END IF
			CASE ELSE																	' \something besides \xHH form
				rawChar = charsetBackslash[rawChar]			' \\   \"   \etc   handled here
			END SELECT
		END IF																			' end of \backslash forms
		newString${j} = rawChar
		INC j
	NEXT i
	RETURN (LEFT$ (newString$, j))
'
LastCharacter:
	newString${j} = rawChar
	INC j
	RETURN (LEFT$ (newString$, j))
END FUNCTION
'
'
' #######################################
' #####  XstBinArrayToBackArray ()  #####
' #######################################
'
FUNCTION  XstBinArrayToBackArray (binArray$[], backArray$[])
'
	upper = UBOUND (binArray$[])
	DIM backArray$[upper]
	FOR i = 0 TO upper
		t$ = binArray$[i]
		t$ = XstBinStringToBackString$ (@t$)
		ATTACH t$ TO backArray$[i]
	NEXT i
END FUNCTION
'
'
' ##########################################
' #####  XstBinStringToBackString$ ()  #####
' ##########################################
'
FUNCTION  XstBinStringToBackString$ (rawString$)
	SHARED UBYTE  charsetNormalChar[]
	SHARED UBYTE  charsetBackslashChar[]
'
	IFZ charsetNormalChar[] THEN InitProgram ()
	IFZ rawString$ THEN RETURN ("")
'
	lenRawString = LEN (rawString$)
	lastRawChar = lenRawString - 1
	lastNewChar = lenRawString + 256
	newString$ = NULL$ (lastNewChar)		' newString may be longer than raw
	DEC lastNewChar
	j = 0
'
	FOR i = 0 TO lastRawChar
		rawChar = rawString${i}
		rawByte = charsetNormalChar[rawChar]
		SELECT CASE TRUE
			CASE rawByte		: newByte = rawByte
												GOSUB AddNewByte
			CASE ELSE				: GOSUB Backslash
		END SELECT
	NEXT i
	RETURN (LEFT$ (newString$, j))
'
'
' *****  Backslash  *****
'
SUB Backslash
	rawByte = charsetBackslashChar[rawChar]
	IF rawByte THEN
		newByte = '\\'														' \? format
		GOSUB AddNewByte
		newByte = rawByte
		GOSUB AddNewByte
	ELSE
		newByte = '\\'														' \xHH format
		GOSUB AddNewByte
		newByte = 'x'
		GOSUB AddNewByte
		HH$ = HEX$(rawChar, 2)
		newByte = HH${0}
		GOSUB AddNewByte
		newByte = HH${1}
		GOSUB AddNewByte
	END IF
END SUB
'
'
' *****  AddNewByte  *****
'
SUB AddNewByte
	newString${j} = newByte
	INC j
	IF (j > lastNewChar) THEN
		newString$ = newString$ + NULL$ (256)
		lastNewChar = lastNewChar + 256
	END IF
END SUB
END FUNCTION
'
'
' ############################################
' #####  XstBinStringToBackStringNL$ ()  #####
' ############################################
'
FUNCTION  XstBinStringToBackStringNL$ (rawString$)
	SHARED UBYTE  charsetNormalChar[]
	SHARED UBYTE  charsetBackslashChar[]
'
	IFZ charsetNormalChar[] THEN InitProgram ()
	IFZ rawString$ THEN RETURN ("")
'
	lenRawString = LEN (rawString$)
	lastRawChar = lenRawString - 1
	lastNewChar = lenRawString + 256
	newString$ = NULL$ (lastNewChar)					' newString may be longer than raw
	DEC lastNewChar
	j = 0
'
	FOR i = 0 TO lastRawChar
		rawChar = rawString${i}
		rawByte = charsetNormalChar[rawChar]
		SELECT CASE TRUE
			CASE rawByte				: newByte = rawByte
														GOSUB AddNewByte
			CASE (rawChar = 10)	: newByte = rawChar
														GOSUB AddNewByte
			CASE ELSE						: GOSUB Backslash
		END SELECT
	NEXT i
	RETURN (LEFT$ (newString$, j))
'
'
' *****  Backslash  *****
'
SUB Backslash
	rawByte = charsetBackslashChar[rawChar]
	IF rawByte THEN
		newByte = '\\'														' \? format
		GOSUB AddNewByte
		newByte = rawByte
		GOSUB AddNewByte
	ELSE
		newByte = '\\'														' \xHH format
		GOSUB AddNewByte
		newByte = 'x'
		GOSUB AddNewByte
		HH$ = HEX$(rawChar, 2)
		newByte = HH${0}
		GOSUB AddNewByte
		newByte = HH${1}
		GOSUB AddNewByte
	END IF
END SUB
'
'
' *****  AddNewByte  *****
'
SUB AddNewByte
	newString${j} = newByte
	INC j
	IF (j > lastNewChar) THEN
		newString$ = newString$ + NULL$ (256)
		lastNewChar = lastNewChar + 256
	END IF
END SUB
END FUNCTION
'
'
' ###############################################
' #####  XstBinStringToBackStringThese$ ()  #####
' ###############################################
'
FUNCTION  XstBinStringToBackStringThese$ (rawString$, these[])
	SHARED  UBYTE  charsetNormalChar[]
	SHARED  UBYTE  charsetBackslashChar[]
'
	IFZ charsetNormalChar[] THEN InitProgram ()
	IFZ rawString$ THEN RETURN ("")
'
	uthese = UBOUND (these[])
	lenRawString = LEN (rawString$)
	lastRawChar = lenRawString - 1
	lastNewChar = lenRawString + 256
	newString$ = NULL$ (lastNewChar)		' newString may be longer than raw
	DEC lastNewChar
	j = 0
'
	FOR i = 0 TO lastRawChar
		convert = $$FALSE
		rawChar = rawString${i}
		rawByte = charsetNormalChar[rawChar]
		IF (rawByte == 0) THEN convert = $$TRUE
		IF (rawChar <= uthese) THEN convert = these[rawChar]
		SELECT CASE TRUE
			CASE convert		: GOSUB Backslash
			CASE ELSE				: newByte = rawChar
												GOSUB AddNewByte
		END SELECT
	NEXT i
	RETURN (LEFT$(newString$,j))
'
'
' *****  Backslash  *****
'
SUB Backslash
	rawByte = charsetBackslashChar[rawChar]
	IF rawByte THEN
		newByte = '\\'														' \? format
		GOSUB AddNewByte
		newByte = rawByte
		GOSUB AddNewByte
	ELSE
		newByte = '\\'														' \xHH format
		GOSUB AddNewByte
		newByte = 'x'
		GOSUB AddNewByte
		HH$ = HEX$(rawChar, 2)
		newByte = HH${0}
		GOSUB AddNewByte
		newByte = HH${1}
		GOSUB AddNewByte
	END IF
END SUB
'
'
' *****  AddNewByte  *****
'
SUB AddNewByte
	newString${j} = newByte
	INC j
	IF (j > lastNewChar) THEN
		newString$ = newString$ + NULL$ (256)
		lastNewChar = lastNewChar + 256
	END IF
END SUB
END FUNCTION
'
'
' #############################
' #####  XstCopyArray ()  #####
' #############################
'
' PURPOSE	: Copy source array into destination array.
'	IN			: sss[]	- source array
' OUT			: ddd[]	- destination array
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstCopyArray (sss[], ddd[])
	UBYTE  temp[]
'
	DIM ddd[]																			' empty copy = default
	IFZ sss[] THEN
		lastErr = ERROR ($$ErrorNatureEmpty)
 		RETURN ($$TRUE)															' empty source and copy
	END IF
'
	saddr = &sss[]																' address of source array
	header02 = XLONGAT (saddr, -8)								' source header word 2
	header03 = XLONGAT (saddr, -4)								' source header word 3
'
	IFZ (header03 AND 0x20000000) THEN						' lowest dimension
		IF (TYPE(sss[]) == $$STRING) THEN						' if string array
			ATTACH sss[] TO sss$[]										' string array
			upper = UBOUND (sss$[])										' upper bound
			DIM ddd$[upper]														' copy array
			FOR i = 0 TO upper												'
				ddd$[i] = sss$[i]												' copy data
			NEXT i																		'
			ATTACH sss$[] TO sss[]										' store copy
			ATTACH ddd$[] TO ddd[]										' replace source
		ELSE																				'
			bytes = SIZE (sss[])											' bytes in source
			DIM temp[bytes-1]													' temporary array
			daddr = &temp[]														' destination address
			XstCopyMemory (saddr-8, daddr-8, bytes+8)	' copy the data
			ATTACH temp[] TO ddd[]										' store copy
		END IF
	ELSE																					' higher dimension (not lowest)
		upper = UBOUND (sss[])											' upper bound of this dimension
		DIM ddd[upper,]															' dimension array of nodes
		FOR i = 0 TO upper													' for all nodes
			ATTACH sss[i,] TO ttt0[]									' get this node
			XstCopyArray (@ttt0[], @ttt1[])						' copy this array
			ATTACH ttt0[] TO sss[i,]									' replace source
			ATTACH ttt1[] TO ddd[i,]									' store copy
		NEXT i
	END IF
	RETURN ($$FALSE)
END FUNCTION
'
'
' ##############################
' #####  XstCopyMemory ()  #####
' ##############################
'
' PURPOSE	: Copy fixed number of bytes from source memory address
'						to destination memory address.
' IN			: saddress 	- source memory address
' 					daddress	- destination memory address
'						copybytes	- number of bytes to copy
'	RETURN	: zero on success, -1 on failure
'
FUNCTION  XstCopyMemory (saddress, daddress, copybytes)
'
	IF (copybytes <= 0) THEN RETURN ($$TRUE)
	IFZ daddress THEN RETURN ($$TRUE)
	IFZ saddress THEN RETURN ($$TRUE)
'
	daddr = daddress
	saddr = saddress
	bytes = copybytes
'
	dpast = daddr + bytes
	spast = saddr + bytes
'
' memory blocks that overlap must be copied from the proper end
'
	direction = +1
	IF (saddr < daddr) THEN
		IF (daddr < spast) THEN
			direction = -1
		END IF
	END IF
'
	align = daddr OR saddr
'
	IF (direction = -1) THEN
		SELECT CASE FALSE
			CASE (align AND 0x0007)		: size = 8 : step = -8	: GOSUB Down8
			CASE (align AND 0x0003)		: size = 4 : step = -4	: GOSUB Down4
			CASE (align AND 0x0001)		: size = 2 : step = -2	: GOSUB Down2
			CASE ELSE									: size = 1 : step = -1	: GOSUB Down1
		END SELECT
	ELSE
		SELECT CASE FALSE
			CASE (align AND 0x0007)		: size = 8 : step = +8	: GOSUB Up8
			CASE (align AND 0x0003)		: size = 4 : step = +4	: GOSUB Up4
			CASE (align AND 0x0001)		: size = 2 : step = +2	: GOSUB Up2
			CASE ELSE									: size = 1 : step = +1	: GOSUB Up1
		END SELECT
	END IF
'
	RETURN
'
'
' *****  Down8  *****
'
SUB Down8
	mod = bytes AND 0x0007
	count = bytes >> 3
'
	IF mod THEN
		daddr = dpast - 1
		saddr = spast - 1
		DO
			UBYTEAT (daddr) = UBYTEAT (saddr)
			DEC daddr
			DEC saddr
			DEC bytes
			DEC mod
		LOOP WHILE mod
	END IF
'
	IF count THEN
		FOR i = 0 TO count-1
			XLONGAT (daddr) = XLONGAT (saddr)
			XLONGAT (daddr+4) = XLONGAT (saddr+4)
			daddr = daddr - 8
			saddr = saddr - 8
			bytes = bytes - 8
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Down8 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Down4  *****
'
SUB Down4
	mod = bytes AND 0x0003
	count = bytes >> 2
'
	IF mod THEN
		daddr = dpast - 1
		saddr = spast - 1
		DO
			UBYTEAT (daddr) = UBYTEAT (saddr)
			DEC daddr
			DEC saddr
			DEC bytes
			DEC mod
		LOOP WHILE mod
	END IF
'
	IF count THEN
		FOR i = 0 TO count-1
			XLONGAT (daddr) = XLONGAT (saddr)
			daddr = daddr - 4
			saddr = saddr - 4
			bytes = bytes - 4
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Down4 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Down2  *****
'
SUB Down2
	mod = bytes AND 0x0001
	count = bytes >> 1
'
	IF mod THEN
		daddr = dpast - 1
		saddr = spast - 1
		DO
			UBYTEAT (daddr) = UBYTEAT (saddr)
			DEC daddr
			DEC saddr
			DEC bytes
			DEC mod
		LOOP WHILE mod
	END IF
'
	IF count THEN
		FOR i = 0 TO count-1
			USHORTAT (daddr) = USHORTAT (saddr)
			daddr = daddr - 2
			saddr = saddr - 2
			bytes = bytes - 2
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Down2 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Down1  *****
'
SUB Down1
	IF bytes THEN
		FOR i = 0 TO bytes-1
			UBYTEAT (daddr) = UBYTEAT (saddr)
			DEC daddr
			DEC saddr
			DEC bytes
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Down1 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Up8  *****
'
SUB Up8
	mod = bytes AND 0x0007
	count = bytes >> 3
'
	IF count THEN
		FOR i = 0 TO count-1
			XLONGAT (daddr) = XLONGAT (saddr)
			XLONGAT (daddr+4) = XLONGAT (saddr+4)
			daddr = daddr + 8
			saddr = saddr + 8
			bytes = bytes - 8
		NEXT i
	END IF
'
	IF bytes THEN
		FOR i = 0 TO bytes-1
			UBYTEAT (daddr) = UBYTEAT (saddr)
			INC daddr
			INC saddr
			DEC bytes
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Up8 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Up4  *****
'
SUB Up4
	mod = bytes AND 0x0003
	count = bytes >> 2
'
	IF count THEN
		FOR i = 0 TO count-1
			XLONGAT (daddr) = XLONGAT (saddr)
			daddr = daddr + 4
			saddr = saddr + 4
			bytes = bytes - 4
		NEXT i
	END IF
'
	IF bytes THEN
		FOR i = 0 TO bytes-1
			UBYTEAT (daddr) = UBYTEAT (saddr)
			INC daddr
			INC saddr
			DEC bytes
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Up4 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Up2  *****
'
SUB Up2
	mod = bytes AND 0x0001
	count = bytes >> 1
'
	IF count THEN
		FOR i = 0 TO count-1
			USHORTAT (daddr) = USHORTAT (saddr)
			daddr = daddr + 2
			saddr = saddr + 2
			bytes = bytes - 2
		NEXT i
	END IF
'
	IF bytes THEN
		FOR i = 0 TO bytes-1
			UBYTEAT (daddr) = UBYTEAT (saddr)
			INC daddr
			INC saddr
			DEC bytes
		NEXT i
	END IF
'
	IF bytes THEN PRINT "XstCopyBytes() : Up2 : error : (final bytes != 0) : "; bytes
END SUB
'
'
' *****  Up1  *****
'
SUB Up1
	IF bytes THEN
		FOR i = 0 TO bytes-1
			UBYTEAT (daddr) = UBYTEAT (saddr)
			INC daddr
			INC saddr
			DEC bytes
		NEXT i
	END IF
END SUB
'
	IF bytes THEN PRINT "XstCopyBytes() : Up1 : error : (final bytes != 0) : "; bytes
END FUNCTION
'
'
' ######################################
' #####  XstCreateDoubleImage$ ()  #####
' ######################################
'
' The XstCreateDoubleImage$ returns a double image literal of a double value.
' Double image literals are images of the 64-bit DOUBLE data type in 4-bit chunks.
' Double image literals begin with 0d and are followed by exactly 16 significant hexadecimal digits.
'
FUNCTION  XstCreateDoubleImage$ (DOUBLE x)
  xhigh = DHIGH (x)
  xlow  = DLOW (x)
  RETURN ("0d"+ HEX$ (xhigh, 8)+ HEX$ (xlow, 8))
END FUNCTION
'
'
' ###############################
' #####  XstDeleteLines ()  #####
' ###############################
'
'	PURPOSE	: Delete 'count' number of lines from array$[] beginning
'						on line 'start'.
' IN			: array$[]	- array to alter
'						start			- line to start deletion process
'						count			- number of lines to delete
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstDeleteLines (@array$[], start, count)
'
	IFZ array$[] THEN
		lastErr = ERROR (($$ErrorObjectArray << 8) OR $$ErrorNatureEmpty)
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND(array$[])
'
	IF (start > upper) THEN
		lastErr = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalid)
 		RETURN ($$TRUE)
	END IF
'
	delta = upper - start + 1
	IF (count > delta) THEN count = delta
	FOR i = start TO upper
		j = i + count
		IF array$[i] THEN array$[i] = ""
		IF (j <= upper) THEN ATTACH array$[j] TO array$[i]
	NEXT i
END FUNCTION
'
'
' #############################
' #####  XstFindArray ()  #####
' #############################
'
'	Find next occurance of string in array
'
'	In:				mode				bit 0:  direction  forward   (0) / reverse     (1)
'												bit 1:  case       sensitive (0) / insensitive (1)
'						text$[]			text array
'						find$				find string
'						line				start position in array
'						pos
'
'	Out:			reps				number of matches unfound
'						match				found match = TRUE - no match = FALSE
'
'	Return:		none
'
'	Discussion:
'		text$[], find$ unchanged.
'		matches do NOT overlap (so match list is suitable for replace)
'
FUNCTION  XstFindArray (mode, text$[], find$, line, pos, match)
	SHARED  UBYTE  charsetUpperToLower[]
	AUTO  firstLine$,  lenFirstLine
'
	IFZ charsetUpperToLower[] THEN InitProgram()
	IFZ text$[] THEN RETURN
	IFZ find$ THEN RETURN
'
	match = 0															' match = $$FALSE
	mode = mode AND 0x3										' isolate mode field
	uText = UBOUND(text$[])								' lines of text to check
'
	IF ((mode AND $$FindDirection) = $$FindForward) THEN
		IF (line < 0) THEN line = -1 : pos = -1 : RETURN
		IF (line > uText) THEN RETURN
		IF (pos < 0) THEN pos = 0
		findForward = $$TRUE
	ELSE
		IF ((line > uText) OR (line < 0)) THEN
			line = uText
			pos = LEN(text$[uText])
		ELSE
			IF (pos < 0) THEN pos = LEN(text$[line])
		END IF
		findForward = $$FALSE
	END IF
	lenLine = LEN(text$[line])
	IF (pos > lenLine) THEN pos = lenLine
'
	XstStringToStringArray (@find$, @find$[])
	uFind = UBOUND(find$[])
	IF (uFind > uText) THEN RETURN
'
	IF (uFind = 0) THEN
		IF findForward THEN GOSUB OneLineForward ELSE GOSUB OneLineReverse
	ELSE
		IF findForward THEN GOSUB MultiLineForward ELSE GOSUB MultiLineReverse
	END IF
	RETURN
'
'
'	*****  OneLineForward  *****
'
SUB OneLineForward
	i = pos + 1														' intrinsics count from 1
'
	FOR l = line TO uText
		IF ((mode AND $$FindCaseSensitivity) = $$FindCaseSensitive) THEN
			found = INSTR (text$[l], find$, i)
		ELSE
			found = INSTRI (text$[l], find$, i)
		END IF
		IF found THEN EXIT FOR
		i = 1
	NEXT l
'
	IF found THEN
		match = $$TRUE
		pos = found-1
		line = l
	END IF
END SUB
'
'
' *****  OneLineReverse  *****
'
SUB OneLineReverse
	i = pos + 1														' intrinsics count from 1
'
	FOR l = line TO 0 STEP -1
		IF ((mode AND $$FindCaseSensitivity) = $$FindCaseSensitive) THEN
			found = RINSTR (text$[l], find$, i)
		ELSE
			found = RINSTRI (text$[l], find$, i)
		END IF
		IF found THEN EXIT FOR
		i = -1
	NEXT l
'
	IF found THEN
		match = $$TRUE
		pos = found-1
		line = l
	END IF
END SUB
'
'
'	*****  MultiLineForward  *****
'
SUB MultiLineForward
	i = pos + 1
	fLen = LEN(find$[0])
	FOR l = line TO uText - uFind
		IF ((mode AND $$FindCaseSensitivity) = $$FindCaseSensitive) THEN
			found = INSTR (text$[l], find$[0], i)
		ELSE
			found = INSTRI (text$[l], find$[0], i)
		END IF
'
		IF found THEN
			tLen = LEN(text$[l])
			IF (tLen != (found + fLen - 1)) THEN i = found + 1 : DO FOR		' has to be at end of line
			f = 1
			FOR m = l+1 TO l+uFind
				IF (m < (l+uFind)) THEN
					multi = $$FALSE
					IF (LEN(text$[m]) != LEN(find$[f])) THEN EXIT FOR
				END IF
				IF ((mode AND $$FindCaseSensitivity) = $$FindCaseSensitive) THEN
					multi = INSTR (text$[m], find$[f])
				ELSE
					multi = INSTRI (text$[m], find$[f])
				END IF
				IF (multi != 1) THEN EXIT FOR
				INC f
			NEXT m
			IF (multi = 1) THEN					' found multi-line match
				match = $$TRUE
				pos = found-1
				line = l
				EXIT FOR
			END IF
		END IF
		i = 1
	NEXT l
END SUB
'
'
'	*****  MultiLineReverse  *****
'
SUB MultiLineReverse
	i = pos + 1
	fLen = LEN(find$[0])
	topLine = line - uFind
	FOR l = topLine TO 0 STEP -1
		IF ((mode AND $$FindCaseSensitivity) = $$FindCaseSensitive) THEN
			found = RINSTR (text$[l], find$[0], i)
		ELSE
			found = RINSTRI (text$[l], find$[0], i)
		END IF
'
		IF found THEN
			tLen = LEN(text$[l])
			IF (tLen != (found + fLen - 1)) THEN i = found - 1 : DO FOR		' has to be at end of line
			f = 1
			FOR m = l+1 TO l+uFind
				IF (m < (l+uFind)) THEN
					multi = $$FALSE
					IF (LEN(text$[m]) != LEN(find$[f])) THEN EXIT FOR
				END IF
				IF ((mode AND $$FindCaseSensitivity) = $$FindCaseSensitive) THEN
					multi = INSTR (text$[m], find$[f])
				ELSE
					multi = INSTRI (text$[m], find$[f])
				END IF
				IF (multi != 1) THEN EXIT FOR
				INC f
			NEXT m
			IF (multi = 1) THEN					' found multi-line match
				match = $$TRUE
				pos = found-1
				line = l
				EXIT FOR
			END IF
		END IF
		i = -1
	NEXT l
END SUB
END FUNCTION
'
'* Get the size (in bytes) of a type-value
' @param type		The type-value
' @return				The size (in bytes) of the type corresponding with the
'								type-value
FUNCTION XstTypeSize(type)
	SCOMPLEX	sctmp
	DCOMPLEX	dctmp
	SELECT CASE type
		CASE $$SBYTE:		RETURN (SIZE(tmp@))
		CASE $$UBYTE:		RETURN (SIZE(tmp@@))
		CASE $$SSHORT:	RETURN (SIZE(tmp%))
		CASE $$USHORT:	RETURN (SIZE(tmp%%))
		CASE $$SLONG:		RETURN (SIZE(tmp&))
		CASE $$ULONG:		RETURN (SIZE(tmp&&))
		CASE $$XLONG,$$GOADDR,$$SUBADDR,$$FUNCADDR:
										RETURN (SIZE(tmp))
		CASE $$GIANT:			RETURN (SIZE(tmp$$))
		CASE $$SINGLE:		RETURN (SIZE(tmp!))
		CASE $$DOUBLE:		RETURN (SIZE(tmp#))
		CASE $$LONGDOUBLE: RETURN (SIZE(tmp##))
		CASE $$STRING:		RETURN (SIZE(tmp$))
		CASE $$SCOMPLEX:	RETURN (SIZE(sctmp))
		CASE $$DCOMPLEX:	RETURN (SIZE(dctmp))
		CASE ELSE:				RETURN (-1)
	END SELECT
END FUNCTION
'
'* Calculate the upperbound which an array of a type 'type' must have to occupy
' at least 'bytes' bytes.
' @param type		The type-value
' @param bytes	The number of bytes
' @return				The upperbound.
'
FUNCTION XstBytesToBound(type, bytes)
	typesize = XstTypeSize(type)
	IF (type = $$STRING) THEN typesize = 1
'
	IF (typesize <= 0) THEN RETURN ($$TRUE)						' unknown type
'
	SELECT CASE typesize
		CASE 1		: num = bytes - 1
		CASE 2		: num = ((bytes+1) >> 1) - 1
		CASE 4		: num = ((bytes+3) >> 2) - 1
		CASE 8		: num = ((bytes+7) >> 3) - 1
		CASE 12		: num = ((bytes+11)/12) - 1
		CASE 16		: num = ((bytes+15) >> 4) - 1
		CASE ELSE	: bytes = 0 : RETURN ($$TRUE)
	END SELECT
	RETURN (num)
END FUNCTION
'
'
'* Create an array of type 'type' that occupies at least 'bytes' bytes.
' @param type			The type of the array.
' @param bytes		The number of bytes the array should occupy.
' @param array		(out) The array.
' @return					The upperbound of the array if succesful, -1 if not.
' @deprecated			This function has limited usefulness and can be written
'									as the (type-)safer version:
'									DIM array[XstBytesToBound(type, bytes)]
'
FUNCTION  XstGetTypedArray (type, bytes, @array[])
	SBYTE  sbyte[]
	UBYTE  ubyte[]
	SSHORT  sshort[]
	USHORT  ushort[]
	SLONG  slong[]
	ULONG  ulong[]
	XLONG  xlong[]
	GOADDR  goaddr[]
	SUBADDR  subaddr[]
	FUNCADDR  funcaddr[] ()
	GIANT  giant[]
	SINGLE  single[]
	DOUBLE  double[]
	LONGDOUBLE longdouble[]
	STRING  string[]
	SCOMPLEX  scomplex[]
	DCOMPLEX  dcomplex[]
'
	DIM array[]
'
	IF (bytes <= 0) THEN RETURN ($$TRUE)
'
	IF ((type < $$SBYTE) OR (type > $$DCOMPLEX)) THEN RETURN ($$TRUE)
'
	upper = XstBytesToBound(type, bytes)
	IF (upper <= 0) THEN RETURN ($$TRUE)
'
	SELECT CASE type
		CASE $$SBYTE		: DIM sbyte[upper]		: SWAP array[], sbyte[]
		CASE $$UBYTE		: DIM ubyte[upper]		: SWAP array[], ubyte[]
		CASE $$SSHORT		: DIM sshort[upper]		: SWAP array[], sshort[]
		CASE $$USHORT		: DIM ushort[upper]		: SWAP array[], ushort[]
		CASE $$SLONG		: DIM slong[upper]		: SWAP array[], slong[]
		CASE $$ULONG		: DIM ulong[upper]		: SWAP array[], ulong[]
		CASE $$XLONG		: DIM xlong[upper]		: SWAP array[], xlong[]
		CASE $$GOADDR		: DIM goaddr[upper]		: SWAP array[], goaddr[]
		CASE $$SUBADDR	: DIM subaddr[upper]	: SWAP array[], subaddr[]
		CASE $$FUNCADDR	: DIM funcaddr[upper]	: SWAP array[], funcaddr[]
		CASE $$GIANT		: DIM giant[upper]		: SWAP array[], giant[]
		CASE $$SINGLE		: DIM single[upper]		: SWAP array[], single[]
		CASE $$DOUBLE		: DIM double[upper]		: SWAP array[], double[]
		CASE $$LONGDOUBLE : DIM longdouble[upper] : SWAP array[], longdouble[]
		CASE $$STRING		: DIM string[upper]		: SWAP array[], string[]
		CASE $$SCOMPLEX	: DIM scomplex[upper]	: SWAP array[], scomplex[]
		CASE $$DCOMPLEX	: DIM dcomplex[upper]	: SWAP array[], dcomplex[]
		CASE ELSE				: DIM xlong[upper]		: SWAP array[], xlong[]
	END SELECT
	RETURN (upper)
END FUNCTION
'
'
' ################################
' #####  XstIsDataDimension  #####
' ################################
'
FUNCTION  XstIsDataDimension (array[])
'
	IFZ array[] THEN RETURN $$FALSE
  RETURN (!(XLONGAT(&array[], -4) AND 0x20000000))
END FUNCTION
'
'
' #################################
' #####  XstMergeStrings$ ()  #####
' #################################
'
FUNCTION  XstMergeStrings$ (string$, add$, start, replace)

	RETURN (MID$(string$,1,start-1) + add$ + MID$(string$,start+replace))
END FUNCTION
'
'
' ############################################
' #####  XstMultiStringToStringArray ()  #####
' ############################################
'
'	Convert multi-line strings to string array
'
' *****  Lines separated by "\r", not "\n"  *****
' *****  Lines returned may contain "\n"  *****
'
'	In:				s$				source string
'	Out:			s$[]			destination string array
'	Return:		none
'	Discussion:
' Removes line terminator "\r"
'
FUNCTION  XstMultiStringToStringArray (s$, s$[])
'
	DIM s$[]
	IFZ s$ THEN RETURN
'
	lenString = LEN(s$)
	uString = (lenString >> 5) OR 7								' guess 32 chars/line
	DIM s$[uString]
'
	line			= 0
	firstChar	= 0
	DO
		cr = INSTR (s$, "\r", firstChar + 1)
		IFZ cr THEN																	' last line
			cr = lenString + 1
			GOSUB AddLine
			EXIT DO
		END IF
		GOSUB AddLine
		IF (firstChar >= lenString) THEN EXIT DO
	LOOP
	IF (s${lenString - 1} != '\r') THEN DEC line
	IF (line != uString) THEN REDIM s$[line]
	RETURN ($$FALSE)
'
'
'	Add next s$ line to array--don't include "\r"
'		firstChar	= offset (from 0) of first character on this line
'		cr				= index (from 1) of newLine (LF)
'
SUB AddLine
	chars = cr - firstChar - 1
	IF chars THEN
		line$ = NULL$ (chars)
		FOR i = 0 TO chars - 1
			line${i} = s${firstChar + i}
		NEXT i
		ATTACH line$ TO s$[line]
	END IF
	firstChar = cr
	INC line
	IF (line > uString) THEN
		uString = (uString + (uString >> 1)) OR 7
		REDIM s$[uString]
	END IF
END SUB
END FUNCTION
'
'
' ###############################
' #####  XstNextCField$ ()  #####
' ###############################
'
' XstNextCField$() is for strings not having the XBasic header
'   (typically, C strings imbedded in structures, etc)
'               = BIG TROUBLE if index is beyond terminating NULL
'
'	Input:
'		sourceAddr	= text address to search (source is not altered)
'		index				= index at which to begin search (1 = first character)
'										(if index < 1, starts at 1)
'
'	Output:
'		RETURN	= next field from sourceAddr
'								terminator:  char <= 0x20 OR char >= 0x7F
'										(includes space, tab, newLine, CRLF, NULL, all non-printables)
'								"" if done
'		index		= index of terminating character
'		done		= TRUE if index points to NULL
'
'	NOTE:  index counts from 1, offset counts from 0
'
FUNCTION  XstNextCField$ (sourceAddr, index, done)
'
	done = $$FALSE
	IF (index < 1) THEN index = 1
	startOffset = index - 1
'
	char = UBYTEAT (sourceAddr, startOffset)
	IFZ char THEN done = $$TRUE : RETURN ("")
'
'	Find start of next field
'
	offset = startOffset
	DO WHILE ((char <= ' ') OR (char >= 0x7F))
		INC offset
		char = UBYTEAT (sourceAddr, offset)
		IFZ char THEN															' No fields left
			index = offset + 1
			done = $$TRUE
			RETURN ("")
		END IF
	LOOP
'
'	Find end of this field
'
	startOffset = offset
	DO
		INC offset
		char = UBYTEAT (sourceAddr, offset)
	LOOP WHILE ((char > ' ') AND (char < 0x7F))
'
'	Make the string
'
	length = offset - startOffset
	nextWord$ = NULL$ (length)
	dest = 0
	FOR i = startOffset TO offset - 1				' don't include the terminator
		nextWord${dest} = UBYTEAT(sourceAddr, i)
		INC dest
	NEXT i
	index = offset + 1											' index = INDEX of terminator
	RETURN (nextWord$)
END FUNCTION
'
'
' ##############################
' #####  XstNextCLine$ ()  #####
' ##############################
'
'	XstNextCLine$() is for strings not having the XBasic header
'		(typically, C strings imbedded in structures, etc)
'								= BIG TROUBLE if index is beyond terminating NULL
'
'	sourceAddr	= text address to search (source is not altered)
'	index				= index at which to begin search (1 = first character)
'										(if index < 1, starts at 1)
'
'	return next line from sourceAddr
'		doesn't return terminating \n or \r\n or \0
'								"" if done
'	index		= index after terminating \n \r\n or \0
'
'	done		= TRUE if 1st character = NULL
'
'	NOTE:  index counts from 1, offset counts from 0
'
FUNCTION  XstNextCLine$ (sourceAddr, index, done)

	done = $$FALSE
	IF (index < 1) THEN index = 1
	startOffset = index - 1
'
	char = UBYTEAT (sourceAddr, startOffset)
	IFZ char THEN done = $$TRUE : RETURN ("")
'
	offset = startOffset										' find the terminator
	DO WHILE (char > 0) AND (char != '\n')
		INC offset
		char = UBYTEAT (sourceAddr, offset)
	LOOP
'
	length = offset - startOffset						' make the string
	IFZ length THEN
		line$ = ""
	ELSE
		endOffset = offset - 1
		cc = UBYTEAT (sourceAddr, endOffset)
		IF (cc = '\r') THEN
			DEC length
			DEC endOffset
		END IF
		IFZ length THEN
			line$ = ""
		ELSE
			line$ = NULL$ (length)
			FOR i = startOffset TO endOffset		' don't include the terminator
				line${i - startOffset} = UBYTEAT(sourceAddr, i)
			NEXT i
		END IF
	END IF
'
'	IF char == '\n' THEN
	INC offset															' bump offset past terminator
'	END IF
	index = offset + 1
	next = UBYTEAT (sourceAddr, offset)			' byte after terminator
	IFZ next THEN done = $$TRUE							' null after terminator
	RETURN (line$)

END FUNCTION
'
'
' ##############################
' #####  XstNextField$ ()  #####
' ##############################
'
'	Input:
'		source$	= text address to search (source is not altered)
'		index		= index at which to begin search (1 = first character)
'								(if index < 1, starts at 1)
'
'	Output:
'		RETURN	= next field from source$
'								terminator:  char <= 0x20 OR char >= 0x7F
'										(includes space, tab, newLine (CRLF), NULL, all non-printables)
'								"" if done
'		index		= index of terminating character
'		done		= TRUE if index > LEN(source$)
'
'	NOTE:  index counts from 1, offset counts from 0
'
FUNCTION  XstNextField$ (source$, index, done)
'
	done = $$FALSE
	IF (index < 1) THEN index = 1
'
	length = LEN (source$)
	IF (index > length) THEN done = $$TRUE : RETURN ("")
'
'	Find start of next field
'
	offset = index - 1
	DO WHILE (offset < length)
		char = source${offset}
		IF ((char > ' ') AND (char < 0x7F)) THEN EXIT DO
		INC offset
	LOOP
'
	IF (offset >= length) THEN
		index = length + 1
		done = $$TRUE
		RETURN ("")
	END IF
'
'	Find end of this field
'
	INC offset																' bump offset past first OK char
	start = offset														' start = INDEX of first character
	DO WHILE (offset < length)
		char = source${offset}
		IF (char <= ' ')  THEN EXIT DO
		IF (char >= 0x7F) THEN EXIT DO
		INC offset
	LOOP
'
	index = offset + 1												' index = INDEX of terminator
	RETURN (MID$ (source$, start, index-start))
END FUNCTION
'
'
' #############################
' #####  XstNextItem$ ()  #####
' #############################
'
FUNCTION  XstNextItem$ (source$, index, term, done)
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
	FOR i = 0x7F TO 0xFF
		char[i] = 0					' 0x7F to 0xFF are not valid characters
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
' #############################
' #####  XstNextLine$ ()  #####
' #############################
'
'	Input:
'		source$	= text address to search (source is not altered)
'		index		= index at which to begin search (1 = first character)
'								(if index < 1, starts at 1)
'
'	Output:
'		RETURN	= next line from source$
'								doesn't include terminating \n (or CRLF or NULL)
'								"" if done
'		index		= index after terminating \n (or CRLF or NULL)
'		done		= TRUE if index > LEN(source$)
'
FUNCTION  XstNextLine$ (source$, index, done)
'
	done = $$FALSE
	IF (index < 1) THEN index = 1
'
	length = LEN(source$)
	IF (index > length) THEN done = $$TRUE : RETURN ("")
'
	newLine = INSTR (source$, "\n", index)
	IFZ newLine THEN newLine = length + 1							' no \n remaining
	chars = newLine - index
	IF (newLine > 1) THEN
		IF (source${newLine - 2} = '\r') THEN
			IF chars THEN DEC chars
		END IF
	END IF
'
	line$ = MID$ (source$, index, chars)
	index = newLine + 1
	RETURN (line$)
END FUNCTION
'
'
' ##########################
' #####  XstParse$ ()  #####
' ##########################
'
' PURPOSE	: Parse$ returns the nth string in source$ separated with delimiter$.
' 					If a string is not found, the function returns empty string "".
' 					The default delimiter is a space character.
' 					The delimiter character(s) are removed.
' IN			: source$, delimiter$, n
' OUT			: nth string in source$
' USE			: nthString$ = Parse$ (myString$, ",", 4)
'
FUNCTION  XstParse$ (source$, delimiter$, n)

  IFZ delimiter$ THEN delimiter$ = " "			' default delimiter is space " "
	IFZ n THEN n = 1

  c = XstTally (source$, delimiter$) 				' count number of delimiters

	IF c = 0 THEN RETURN ""
	IF n > c+1 THEN RETURN ""

	y = LEN (delimiter$)
	start = 0
	FOR i = 1 TO n
		x = INSTR (source$, delimiter$, start)
		start = x + y
		IF i = n-1 THEN begin = x
		IF i = n THEN end = x
	NEXT i

	IF n = 1 THEN
		s = 1
		length = end - begin - 1
	ELSE
		s = begin + y
		length = end - begin - y
	END IF

	RETURN MID$ (source$, s, length)

END FUNCTION
'
'
' ############################################
' #####  XstParseStringToStringArray ()  #####
' ############################################
'
' PURPOSE	: Parses a string and splits it into a string array
'						based on the specified delimiter. The default delimiter
'						is a space character. The delimiter string is not included
'						in s$[].
' IN			: source$, delimiter$
' OUT			: s$[]
' RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstParseStringToStringArray (source$, delimiter$, @s$[])

' code updated by Alan Gent 4 November 2005

UBYTE delimiter_first
USHORT test2bytes
ULONG  test4bytes

	DIM s$[]
	IFZ source$ THEN RETURN ($$TRUE)
  IFZ delimiter$ THEN delimiter$ = " "

	
	len_source = LEN(source$)
	len_delim  = LEN(delimiter$)
	max_index = len_source - len_delim
	skiplength = len_delim + 1
	addr_source = &source$
	addr_delim = &delimiter$
	delimiter_first = delimiter${0}
	
		
	'scan the source$ to determine the number of occurrences of delimiter$
	count = 0
		SELECT CASE len_delim
			CASE 1:
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN INC count
				NEXT index
				
			CASE 2:
				test2bytes = USHORTAT(addr_delim)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if both bytes are the same
						IF USHORTAT(addr_source + index) = test2bytes THEN INC count 
					ENDIF
				NEXT index
				
			CASE 3:
				test2bytes = USHORTAT(addr_delim + 1)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if NEXT 2 bytes are the same = 3 byte match
						IF USHORTAT(addr_source + index + 1) = test2bytes THEN INC count 
					ENDIF
				NEXT index
				
			CASE 4:
				test4bytes = ULONGAT(addr_delim)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if all 4 bytes are the same = 4 byte match
						IF ULONGAT(addr_source + index) = test4bytes THEN INC count 
					ENDIF
				NEXT index
				
			CASE 5:
				test4bytes = ULONGAT(addr_delim + 1)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if NEXT 4 bytes are the same = 5 byte match
						IF ULONGAT(addr_source + index + 1) = test4bytes THEN INC count 
					ENDIF
				NEXT index
				
			CASE ELSE:
				test4bytes = ULONGAT(addr_delim + 1)
				'delimiter string is 6 or more chracters
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if NEXT 4 bytes are the same = 5 byte match
						IF ULONGAT(addr_source + index + 1) = test4bytes THEN 
							'matched on 5 bytes - now loop through the remaining bytes
							match = $$TRUE
							FOR i = 5 TO len_delim - 1
								IF source${index + i} <> delimiter${i} THEN
									match = $$FALSE
									EXIT FOR
								ENDIF
							NEXT i
							
							IF match = $$TRUE THEN INC count
							
						ENDIF 
					ENDIF
				NEXT index
		END SELECT
		
	
	'if 0 occurrences of delimiter$ nothing to do
	IF count <= 0 THEN
		DIM s$[0]
		s$[0] = source$
		RETURN ($$TRUE)
	END IF
	
	'dimension the output array
	DIM s$[count]
	'and an array to hold the start location of each delimiter string
	DIM location[count]
	
	
	'rescan the source string and this time store the start location of each delimiter$
	SELECT CASE len_delim
			CASE 1:
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						location[loc_index] = index
						INC loc_index	
					ENDIF
				NEXT index
				
			CASE 2:
				test2bytes = USHORTAT(addr_delim)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if 2 bytes are the same
						IF USHORTAT(addr_source + index) = test2bytes THEN
							location[loc_index] = index
							INC loc_index
						ENDIF
					ENDIF
				NEXT index
				
			CASE 3:
				test2bytes = USHORTAT(addr_delim + 1)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if NEXT 2 bytes are the same = 3 byte match
						IF USHORTAT(addr_source + index + 1) = test2bytes THEN
							location[loc_index] = index
							INC loc_index
						ENDIF 
					ENDIF
				NEXT index
				
			CASE 4:
				test4bytes = ULONGAT(addr_delim)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if all 4 bytes are the same = 4 byte match
						IF ULONGAT(addr_source + index) = test4bytes THEN
							location[loc_index] = index
							INC loc_index
						ENDIF 
					ENDIF
				NEXT index
				
			CASE 5:
				test4bytes = ULONGAT(addr_delim + 1)
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						'matched on 1 byte - now see if NEXT 4 bytes are the same = 5 byte match
						IF ULONGAT(addr_source + index + 1) = test4bytes THEN
							location[loc_index] = index
							INC loc_index
						ENDIF 
					ENDIF
				NEXT index
				
			CASE ELSE:
				test4bytes = ULONGAT(addr_delim + 1)
				'delimiter string is 6 or more chracters
				FOR index = 0 TO max_index
					IF source${index} = delimiter_first THEN
						IF ULONGAT(addr_source + index + 1) = test4bytes THEN 
							'matched on 5 bytes - now loop through the remaining bytes
							match = $$TRUE
							FOR i = 5 TO len_delim - 1
								IF source${index + i} <> delimiter${i} THEN
									match = $$FALSE
									EXIT FOR
								ENDIF
							NEXT i
							
							IF match = $$TRUE THEN
								location[loc_index] = index
								INC loc_index
							ENDIF
							
						ENDIF 
					ENDIF
				NEXT index
		END SELECT
		
	'that handles all the delimiter terminated values up to loc_index = count - 1
	'the last value has no delimiter string and is terminated by end of source string
	'so add a 'dummy' delimiter string match location for the last value in the string
	
	location[count] = LEN(source$)
	
	'extract each substring in turn to populate the array index
	'note location[x] is 0 based from the previous {index} processing
	'note start, end are 1 based
	'so, location[x] is now the last character of substring before the delimiter
	
  start = 1
  FOR x = 0 TO count
		end = location[x]
		length = end - start + 1
    s$[x] = MID$(source$, start, length)
		'skip over the delimiter string to next start
		start = end + skiplength
  NEXT
	
	RETURN $$FALSE

END FUNCTION
'
'
' ###########################
' #####  XstReplace ()  #####
' ###########################
'
'PURPOSE: a function to replace n number of find$ with replace$ in string$
'					if n = 0 then all instances are replaced
'RETURN	:	returns new source$, count (count = no of find$ replaced)
'					and is case sensitive
'USE: 		c = Replace (@myString$, "nbsp;", " ", 0)
'
FUNCTION  XstReplace (@source$, find$, replace$, n)

	IFZ source$ THEN RETURN ($$TRUE)
	IFZ find$ THEN RETURN ($$TRUE)
	IFZ replace$ THEN RETURN ($$TRUE)

	x = INSTR (source$, find$)
	IFZ x THEN RETURN 0

	count = 0
	y = LEN (find$) - 1
	r = LEN (replace$)

	x = 1
	DO WHILE  x <> 0
		x = INSTR (source$, find$, x)
		IF x > 0 THEN
			source$ = LEFT$ (source$, x-1) + replace$ + RIGHT$ (source$, LEN (source$) - x - y)
			INC count
			x = x + r
			IF n THEN
				IF count = n THEN EXIT DO
			END IF
		END IF
	LOOP

RETURN count

END FUNCTION
'
'
' ################################
' #####  XstReplaceArray ()  #####
' ################################
'
'	Replace max of reps occurances of string in array
'
'	In:				mode				bit 0:  direction  forward   (0) / reverse     (1)
'												bit 1:  case       sensitive (0) / insensitive (1)
'						text$[]			text array
'						find$				find string
'						replace$		replace string
'						line				starting line in array
'						pos					0 relative position in line
'
'	Out:			text$[]			new text array
'						match				found and replaced one match
'
'	Return:		none
'
'	Discussion:
'		find$, replace$ unchanged.
'
FUNCTION  XstReplaceArray (mode, text$[], find$, replace$, line, pos, match)
	IFZ text$[] THEN RETURN
	IFZ find$ THEN RETURN
'
	match = $$FALSE
	mode = mode AND 0x03
	XstFindArray (mode, @text$[], @find$, @line, @pos, @match)
	IFZ match THEN RETURN
'
	XstStringToStringArray (@find$, @find$[])
	uFind = UBOUND (find$[])
	uText = UBOUND (text$[])
	uReplace = -1																					' empty (default)
'
	IF replace$ THEN
		XstStringToStringArray (@replace$, @replace$[])
		uReplace = UBOUND (replace$[])
	END IF
'
	IFZ uFind THEN
		IF (uReplace <= 0) THEN GOSUB OneLineOneLine ELSE GOSUB OneLineMultiLine
	ELSE
		IF (uReplace <= 0) THEN GOSUB MultiLineOneLine ELSE GOSUB MultiLineMultiLine
	END IF
	RETURN
'
'
'	*****  OneLineOneLine  *****
'
SUB OneLineOneLine
	text$ = text$[line]
	lenFind = LEN(find$)
	text$[line] = LEFT$(text$,pos) + replace$ + MID$(text$, pos+1+lenFind)
END SUB
'
'
'	*****  OneLineMultiLine  *****  replace part or all of one line with more than one line
'
SUB OneLineMultiLine
	text$ = text$[line]												' first line of text
	lenFind = LEN(find$)											' length of find string
	before$ = LEFT$(text$,pos)								' before replaced string
	after$ = MID$(text$,pos+1+lenFind)				' after replaced string
	replacea$ = replace$[0]										' first replace line
	replacez$ = replace$[uReplace]						' last replace line
	replace$[0] = before$ + replacea$					' fix first replace string
	replace$[uReplace] = replacez$ + after$		' fix last replace string
	XstReplaceLines (@text$[], @replace$[], line, 1, 0, uReplace+1)
END SUB
'
'
' *****  MultiLineOneLine  *****  replace part or all of more than one line with one line
'
SUB MultiLineOneLine
	text$ = text$[line]
	before$ = LEFT$(text$,pos)
	after = LEN(find$[uFind])
	after$ = text$[line+uFind]
	text$[line] = before$ + replace$ + MID$(after$, after+1)
	text$[line+1] = ""
	FOR i = line+1 TO uText-uFind
		SWAP text$[i], text$[i+uFind]
	NEXT i
	REDIM text$[i-uFind]
END SUB
'
'
' *****  MultiLineMultiLine  *****
'
SUB MultiLineMultiLine
	text$ = text$[line]
	before$ = LEFT$(text$,pos)
	text$[line] = before$ + replace$[0]
	text$ = text$[line+uFind]
	after = LEN(find$[uFind])
	after$ = MID$(text$[line+uFind], after+1)
	text$[line+uFind] = replace$[uReplace] + after$
	XstReplaceLines (@text$[], @replace$[], line+1, uFind-1, 1, uReplace-1)
END SUB
END FUNCTION
'
'
' ################################
' #####  XstReplaceLines ()  #####
' ################################
'
FUNCTION  XstReplaceLines (d$[], s$[], firstD, countD, firstS, countS)
	emptySource = $$FALSE
	upperS = UBOUND(s$[])
	upperD = UBOUND(d$[])
	IF (firstS > upperS) THEN countS = 0
	IF (firstD > (upperD + 3)) THEN RETURN ($$TRUE)
	IF (firstD > upperD) THEN upperD = firstD : REDIM d$[upperD]
	IF (countS < 0) THEN countS = upperS - firstS + 1
	IF (countD < 0) THEN countD = upperD - firstD + 1
	finalS = firstS + countS - 1
	finalD = firstD + countD - 1
	IF (finalS > upperS) THEN finalS = upperS
	IF (finalD > upperD) THEN finalD = upperD
	delta = countS - countD
	SELECT CASE TRUE
		CASE (delta < 0)
					oldUpperD = upperD
					upperD = upperD + delta
					FOR d = firstD + countS TO upperD
						d$[d] = d$[d-delta]
					NEXT d
					d = firstD
					FOR s = firstS TO finalS
						d$[d] = s$[s]
						INC d
					NEXT s
					REDIM d$[upperD]
		CASE (delta = 0)
					d = firstD
					FOR s = firstS TO finalS
						d$[d] = s$[s]
						INC d
					NEXT s
		CASE (delta > 0)
					oldUpperD = upperD
					upperD = upperD + delta
					REDIM d$[upperD]
					FOR d = oldUpperD TO firstD STEP -1
						d$[d+delta] = d$[d]
					NEXT d
					d = firstD
					FOR s = firstS TO finalS
						d$[d] = s$[s]
						INC d
					NEXT s
	END SELECT
END FUNCTION
'
'
' ##############################################  n = newline
' #####  XstStringArraySectionToString ()  #####  0 = none : 1 = \n : 2 = \r\n
' ##############################################
'
FUNCTION  XstStringArraySectionToString (text$[], copy$, x1, y1, x2, y2, n)
'
	copy$ = ""
	IFZ text$[] THEN RETURN
	upper = UBOUND(text$[])
'
	SELECT CASE ALL TRUE
		CASE (x1 < 0)								: x1 = 0
		CASE (y1 < 0)								: y1 = 0
		CASE (x2 < 0)								: x2 = 0
		CASE (y2 < 0)								: y2 = 0
		CASE (y2 < y1)							: SWAP x1, x2 : SWAP y1, y2					' x1,y1 comes 1st
		CASE (y2 = y1)							: IF (x2 < x1) THEN SWAP x2, x1			' x1,y1 comes 1st
		CASE (y1 > upper)						: y1 = upper : x1 = LEN(text$[y1])	' x1,y1 at end
		CASE (y2 > upper)						: y2 = upper : x2 = LEN(text$[y2])	' x2,y2 at end
		CASE (x1 > LEN(text$[y1]))	: x1 = LEN(text$[y1])								' x1 at line end
		CASE (x2 > LEN(text$[y2]))	: x2 = LEN(text$[y2])								' x2 at line end
	END SELECT
'
	IF (y2 = y1) THEN								' All on one line
			IF (x2 <= x1) THEN
			copy$ = ""
		ELSE
			copy$ = MID$(text$[y1], x1+1, x2-x1)
		END IF
		RETURN
	END IF
'
	firstLength = LEN(text$[y1])		' length of 1st string
	finalLength = LEN(text$[y2])		' length of last string
'
	bytes = firstLength - x1 + n		' segment length of first segment + newline
	bytes = bytes + x2 + n					' segment length of final segment + newline
'
	FOR i = y1+1 TO y2-1								' for all but first and final lines
		bytes = bytes + LEN(text$[i]) + n	' add string length + newline length
	NEXT i
'
	bytes = (bytes + 15) AND -16		' round up to mod 16
	copy$ = NULL$ (bytes)						' copy$ is now final result size
'
	o = 0														' offset into copy$
	addr = &text$[y1]								' address of 1st byte in 1st string
	FOR x = x1 TO firstLength-1			'
		copy${o} = UBYTEAT(addr,x)		' copy byte from first string to copy$
		INC o													' offset to next byte in copy$
	NEXT x
	IF n THEN GOSUB AppendNewline		' append newline character
'
	FOR y = y1+1 TO y2-1						' FOR second string TO next to last string
		addr = &text$[y]							' address of 1st byte in string to copy$
		FOR x = 0 TO UBOUND(text$[y])	' FOR first to last character in text$[y]
			copy${o} = UBYTEAT(addr,x)	' copy byte from text$[y]{x} to copy${o}
			INC o												' next offset in copy$
		NEXT x												' next byte to copy
		IF n THEN GOSUB AppendNewline	' append newline
	NEXT y													' next line
'
	addr = &text$[y2]								' address of final string
	FOR x = 0 TO x2-1								' FOR first byte TO last byte in final string
		copy${o} = UBYTEAT(addr,x)		' copy byte from text$[y2]{x} to copy${o}
		INC o
	NEXT x
'
	headAddr = &copy$ - 16					' address of copy$ header
	XLONGAT(headAddr,[2]) = o			' set length of copy$ exactly
	RETURN
'
' *****  AppendNewline  *****
'
SUB AppendNewline
	SELECT CASE n
		CASE 0		: ' nothing between lines - concatenate lines w/o separator
		CASE 1		: copy${o} = '\n'	: INC o
		CASE 2		: copy${o} = '\r' : INC o : copy${o} = '\n' : INC o
		CASE ELSE	: copy${o} = '\n' : INC o
	END SELECT
END SUB
END FUNCTION
'
'
' ###################################################
' #####  XstStringArraySectionToStringArray ()  #####
' ###################################################
'
FUNCTION  XstStringArraySectionToStringArray (text$[], copy$[], x1, y1, x2, y2)
'
	IF copy$[] THEN DIM copy$[]
	IFZ text$[] THEN RETURN
	upper = UBOUND(text$[])
'
	SELECT CASE ALL TRUE
		CASE (x1 < 0)								: x1 = 0
		CASE (y1 < 0)								: y1 = 0
		CASE (x2 < 0)								: x2 = 0
		CASE (y2 < 0)								: y2 = 0
		CASE (y2 < y1)							: SWAP x1, x2 : SWAP y1, y2					' x1,y1 comes 1st
		CASE (y2 = y1)							: IF (x2 < x1) THEN SWAP x2, x1			' x1,y1 comes 1st
		CASE (y1 > upper)						: y1 = upper : x1 = LEN(text$[y1])	' x1,y1 at end
		CASE (y2 > upper)						: y2 = upper : x2 = LEN(text$[y2])	' x2,y2 at end
		CASE (x1 > LEN(text$[y1]))	: x1 = LEN(text$[y1])								' x1 at line end
		CASE (x2 > LEN(text$[y2]))	: x2 = LEN(text$[y2])								' x2 at line end
	END SELECT
'
	ucopy = y2 - y1								' upper bound of copy$[]
	IFZ ucopy THEN								' only one line
		DIM copy$[0]
		IF (x2 <= x1) THEN
			copy$[0] = ""
		ELSE
			copy$[0] = MID$(text$[y1], x1+1, x2-x1)
		END IF
		RETURN
	END IF
'
	copy = 0
	DIM copy$[ucopy]											' result array
	copy$[0] = MID$(text$[y1], x1+1)			' first string is segment
	FOR y = y1+1 TO y2-1									' for all but first and final lines
		INC copy														' next copy$[] element
		copy$[copy] = text$[y]							' copy$[] line = text$[] line
	NEXT y																'
	copy$[ucopy] = LEFT$(text$[y2],x2)		' final string is segment
END FUNCTION
'
'
' #######################################
' #####  XstStringArrayToString ()  #####
' #######################################
'
FUNCTION  XstStringArrayToString (s$[], s$)
'
	s$ = ""
	IFZ s$[] THEN RETURN
'
'	Faster to precompute required s$ length than REDIM on occasion
'
	lastLine = UBOUND(s$[])
	IFZ lastLine THEN						' Separate 0 case for simpler logic below
		s$ = s$[0]
		RETURN
	END IF
'
	totalChars = 0
	FOR i = 0 TO lastLine - 1
		totalChars = totalChars + LEN(s$[i]) + 1				' chars + \n
	NEXT i
'
	IF s$[lastLine] THEN
		totalChars = totalChars + LEN(s$[lastLine])
	END IF
'
	s$ = NULL$ (totalChars)
	index = 0
'
	FOR i = 0 TO lastLine
		SWAP s$[i], a$
		chars = LEN (a$)
		IF chars THEN
			FOR j = 0 TO chars - 1
				s${index} = a${j}
				INC index
			NEXT j
		END IF
		IF (i < lastLine) THEN
			s${index} = '\n'
			INC index
		END IF
		SWAP a$, s$[i]
	NEXT i
END FUNCTION
'
'
' ###########################################
' #####  XstStringArrayToStringCRLF ()  #####
' ###########################################
'
FUNCTION  XstStringArrayToStringCRLF (s$[], s$)
'
	s$ = ""
	IFZ s$[] THEN RETURN
'
'	Faster to precompute length than REDIM on occasion
'
	lastLine = UBOUND(s$[])
	IFZ lastLine THEN						' Separate case for simpler logic below
		s$ = s$[0] + "\r\n"
		RETURN
	END IF
'
	totalChars = 0
	FOR i = 0 TO lastLine - 1
		totalChars = totalChars + LEN(s$[i]) + 2				' chars + \r\n
	NEXT i
'
	IF s$[lastLine] THEN
		totalChars = totalChars + LEN(s$[lastLine])
	END IF
'
	s$ = NULL$ (totalChars)
	index = 0
	FOR i = 0 TO lastLine
		SWAP s$[i], a$
		chars = LEN (a$)
		IF chars THEN
			FOR j = 0 TO chars - 1
				s${index} = a${j}
				INC index
			NEXT j
		END IF
		IF (i < lastLine) THEN
			s${index} = '\r'
			INC index
			s${index} = '\n'
			INC index
		END IF
		SWAP a$, s$[i]
	NEXT i
END FUNCTION
'
'
' #######################################
' #####  XstStringToStringArray ()  #####
' #######################################
'
FUNCTION  XstStringToStringArray (s$, s$[])
'
	DIM s$[]
	IFZ s$ THEN RETURN
'
	lenString = LEN(s$)
	uString = (lenString >> 5) OR 7								' guess 32 chars/line
	DIM s$[uString]
	firstChar = 0
	line = 0
'
	DO
		nl = INSTR (s$, "\n", firstChar + 1)
		IFZ nl THEN																	' last line
			nl = lenString + 1
			GOSUB AddLine
			EXIT DO
		END IF
		GOSUB AddLine
		IF (firstChar >= lenString) THEN EXIT DO
	LOOP
'
	IF (s${lenString-1} != '\n') THEN DEC line
	IF (line != uString) THEN REDIM s$[line]
	RETURN ($$FALSE)
'
'	Add next s$ line to array.  Don't include \n or \r
'		firstChar	= offset (from 0) of first character on this line
'		nl				= index (from 1) of newLine (LF)
'
SUB AddLine
	chars = nl - firstChar - 1
	IF (nl > 1) THEN
		IF (s${nl-2} = '\r') THEN DEC chars		' skip \r before \n
	END IF
	IF (s${nl} = '\r') THEN INC nl					' skip \r after \n
	IF (chars > 0) THEN
		line$ = NULL$(chars)
		FOR i = 0 TO chars - 1
			line${i} = s${firstChar+i}
		NEXT i
		ATTACH line$ TO s$[line]
	END IF
	INC line
	firstChar = nl
	IF (line > uString) THEN
		uString = (uString + (uString >> 1)) OR 63
		REDIM s$[uString]
	END IF
END SUB
END FUNCTION
'
'
' #########################
' #####  XstTally ()  #####
' #########################
'
' PURPOSE	: Tally () returns a count of all find$ in source$.
' IN			: find$, source$. Default find$ is space character.
' RETURN	: count on success, -1 on failure
'	USE			: count = Tally (astring1$, astring2$)
'
FUNCTION  XstTally (source$, find$)
'
	IFZ source$ THEN RETURN -1
	IFZ find$ THEN find$ = " "
	count = 0
	start = 0
'
	l = LEN (find$)
	x = 1
	DO WHILE x <> 0
		x = INSTR (source$, find$, start)
		IF x > 0 THEN
			start = x + l
			INC count
		ENDIF
	LOOP
	RETURN count

END FUNCTION
'
'
' #########################
' #####  XstLTRIM ()  #####
' #########################

FUNCTION  XstLTRIM (@string$, @array[])
'
	IFZ string$ THEN RETURN -1
'
	IFZ array[] THEN
		string$ = LTRIM$ (string$)		' default
	ELSE
		type = TYPE (array[])
		upper = UBOUND (array[])
		IF (upper < 255) THEN RETURN -1
		IF ((type != $$SLONG) AND (type != $$ULONG) AND (type != $$XLONG)) THEN RETURN -1
'
		upper = UBOUND (string$)
		first = -1
'
		FOR i = 0 TO upper
			IF array[string${i}] THEN first = i : EXIT FOR
		NEXT i
'
		SELECT CASE TRUE
			CASE (first < 0)	: string$ = ""
			CASE (first > 0)	: string$ = MID$ (string$, first+1)
		END SELECT
	END IF
END FUNCTION
'
'
' #########################
' #####  XstRTRIM ()  #####
' #########################

FUNCTION  XstRTRIM (@string$, array[])
'
	IFZ string$ THEN RETURN
'
	IFZ array[] THEN
		string$ = RTRIM$ (string$)							' default
	ELSE
		type = TYPE (array[])
		upper = UBOUND (array[])
		IF (upper < 255) THEN RETURN -1
		IF ((type != $$SLONG) AND (type != $$ULONG) AND (type != $$XLONG)) THEN RETURN -1
'
		upper = UBOUND (string$)
		final = -1
'
		FOR i = 0 TO upper
			n = upper - i
			IF array[string${n}] THEN final = i : EXIT FOR
		NEXT i
'
		SELECT CASE TRUE
			CASE (final < 0)	: string$ = ""
			CASE (final > 0)	: string$ = LEFT$ (string$, upper-final+1)
		END SELECT
	END IF
END FUNCTION
'
'
' ########################
' #####  XstTRIM ()  #####
' ########################

FUNCTION  XstTRIM (@string$, array[])
'
	IFZ string$ THEN RETURN
'
	IFZ array[] THEN
		string$ = TRIM$ (string$)		' default
	ELSE
		type = TYPE (array[])
		upper = UBOUND (array[])
		IF (upper < 255) THEN RETURN -1
		IF ((type != $$SLONG) AND (type != $$ULONG) AND (type != $$XLONG)) THEN RETURN -1
'
		upper = UBOUND (string$)
		first = -1
		final = -1
'
		FOR i = 0 TO upper
			IF array[string${i}] THEN first = i : EXIT FOR
		NEXT i
'
		IF (first < 0) THEN			' trim all characters
			string$ = ""
			RETURN
		END IF
'
		FOR i = 0 TO upper
			n = upper - i
			IF array[string${n}] THEN final = i : EXIT FOR
		NEXT i
'
		IF (final < 0) THEN			' trim all characters
			string$ = ""
			RETURN
		END IF
'
		IFZ first THEN
			IF final THEN
				string$ = LEFT$ (string$, upper-final+1)
			END IF
		ELSE
			IFZ final THEN
				string$ = MID$ (string$, first+1)
			ELSE
				string$ = MID$ (string$, first+1, upper-final-first+1)
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ##################################
' #####  XstCompareStrings ()  #####
' ##################################
'
' PURPOSE	: Compare two strings based on test operator op.
'						Return operator is based on result of comparison test.
'	IN			:	addrString1	- address of first string to compare
'						op					- test operator; $$EQ, $$NE, $$LT, $$LE, $$GE, $$GT
'						addrString1	- address of 2nd string to compare
'						flags				- type of comparison; $$SortCaseInsensitive, $$SortAlphaNumeric
'	RETURN	: Return is FALSE or a test operator depending on requested comparison op
'						Return is TRUE on error
'
'	Operators:
'  $$EQ                  = 0x02
'  $$NE                  = 0x03
'  $$LT                  = 0x04
'  $$LE                  = 0x05
'  $$GE                  = 0x06
'  $$GT                  = 0x07
'
FUNCTION  XstCompareStrings (addrString1, op, addrString2, flags)
	SHARED  UBYTE  caseless[]
	SHARED  UBYTE  numeric[]
	AUTOX  a$
	AUTOX  b$
'
	IFZ caseless[] THEN GOSUB Initialize
	IFZ numeric[] THEN GOSUB Initialize
'
' check for bad operation
'
	SELECT CASE op
		CASE $$EQ, $$NE, $$LT, $$LE, $$GE, $$GT
		CASE ELSE	: errLast = ERROR (($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument)
								RETURN ($$TRUE)
	END SELECT
'
	XLONGAT (&&a$) = addrString1
	XLONGAT (&&b$) = addrString2
'
' result
'   -1 means a < b
'    0 means a = b
'   +1 means a > b
'
	done = 0
	result = 0
	IFZ a$ THEN
		IFZ b$ THEN
			result = 0
			done = 1
		ELSE
			result = -1
			done = 1
		END IF
	ELSE
		IFZ b$ THEN
			result = +1
			done = 1
		END IF
	END IF
'
' if both a$ and b$ have contents then more work is required
'
	IFZ done THEN
		at = TYPE (a$)
		bt = TYPE (b$)
		IF (at != $$STRING) THEN
			errLast = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidType)
			RETURN ($$TRUE)
		END IF
		IF (bt != $$STRING) THEN
			errLast = ERROR (($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidType)
			RETURN ($$TRUE)
		END IF
'
		aa = addrString1		' address of a$
		bb = addrString2		' address of b$
		ta = UBOUND (a$)		' high offset of a$
		tb = UBOUND (b$)		' high offset of b$
		ua = aa + ta				' high address of a$
		ub = bb + tb				' high address of b$
'		la = LEN (a$)
'		lb = LEN (b$)
'		IF (la > lb) THEN max = la ELSE max = lb
'
		XLONGAT (&&a$) = 0	' don't free string1 !!!
		XLONGAT (&&b$) = 0	' don't free string2 !!!
'
		a = 0
		b = 0
		oa = 0
		ob = 0
		DEC aa
		DEC bb
		DO WHILE ((aa < ua) AND (bb < ub))
			INC aa																	' address of next byte in a$
			INC bb																	' address of next byte in b$
			a = UBYTEAT(aa)													' a = next byte from a$
			b = UBYTEAT(bb)													' b = next byte from b$
			IF (flags AND $$SortAlphaNumeric) THEN	' numeric sensitive
				IF numeric[a] THEN										' a$ byte is numeric
					IF numeric[b] THEN									' b$ byte is numeric
						asig = 0													' 1st significant digit in a$
						bsig = 0													' 1st significant digit in b$
						adig = 0													' significant digits in a$
						bdig = 0													' significant digits in b$
						DO WHILE (aa <= ua)								'
							IFZ numeric[a] THEN EXIT DO			' not a numeric digit
							IFZ adig THEN										' significant digits
								IF (a != '0') THEN						' significant digit
									asig = aa										' first significant digit in a$
									INC adig										' first significant digit
								END IF												'
							ELSE														'
								INC adig											' another significant digit
							END IF													'
							INC aa													' next address
							a = UBYTEAT(aa)									' next byte
						LOOP															'
						aaa = a														' byte after numeric digits
						DO WHILE (bb <= ub)								'
							IFZ numeric[b] THEN EXIT DO			' not a numeric digit
							IFZ bdig THEN										' significant digits
								IF (b != '0') THEN						' significant digit
									bsig = bb										' first significant digit in b$
									INC bdig										' first significant digit
								END IF												'
							ELSE														'
								INC bdig											' another significant digit
							END IF													'
							INC bb													' next address
							b = UBYTEAT(bb)									' next byte
						LOOP															'
						bbb = b														' byte after numeric digits
						IF (adig != bdig) THEN						' # of significant digits not equal
							a = adig												' a to compare (trick)
							b = bdig												' b to compare (trick)
							EXIT DO													' done loop
						END IF														' values are equal
						FOR ndig = 1 TO adig							' for all significant digits
							a = UBYTEAT(asig)								' digit in a$
							b = UBYTEAT(bsig)								' digit in b$
							IF (a != b) THEN EXIT DO				' a$ digit != b$ digit
							INC asig												' address of next digit in a$
							INC bsig												' address of next digit in b$
						NEXT ndig
						a = aaa														' numeric values ARE equal,
						b = bbb														' so compare following bytes
					END IF
				END IF
			END IF																	'
			IF (flags AND $$SortCaseInsensitive) THEN
				a = caseless[a]												' a = upper case a byte
				b = caseless[b]												' b = upper case b byte
			END IF																	'
		LOOP WHILE (a == b)												' loop until a != b
'
' a$ != b$ or checked all characters in a$ or b$
'
		IF (a == b) THEN													' shorter string is less
			a = ta
			b = tb
		END IF
'
		SELECT CASE TRUE
			CASE (a < b)	:	result = -1 : done = 1		' a < b
			CASE (a > b)	: result = +1 : done = 1		' a > b
			CASE ELSE			: result =  0 : done = 1		' a = b
		END SELECT
	END IF
'
' return TRUE/FALSE depending on requested comparison op
'
	SELECT CASE TRUE
		CASE (result < 0)
					SELECT CASE op
						CASE $$LT			: return = $$LT
						CASE $$LE			: return = $$LT
						CASE $$NE			: return = $$LT
						CASE $$EQ			: return = $$FALSE
						CASE $$GE			: return = $$FALSE
						CASE $$GT			: return = $$FALSE
					END SELECT
		CASE (result = 0)
					SELECT CASE op
						CASE $$LT			: return = $$FALSE
						CASE $$LE			: return = $$EQ
						CASE $$NE			: return = $$FALSE
						CASE $$EQ			: return = $$EQ
						CASE $$GE			: return = $$EQ
						CASE $$GT			: return = $$FALSE
					END SELECT
		CASE (result > 0)
					SELECT CASE op
						CASE $$LT			: return = $$FALSE
						CASE $$LE			: return = $$FALSE
						CASE $$NE			: return = $$GT
						CASE $$EQ			: return = $$FALSE
						CASE $$GE			: return = $$GT
						CASE $$GT			: return = $$GT
					END SELECT
	END SELECT
	RETURN (return)
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM caseless[255]
	DIM numeric[255]
	FOR i = 0 TO 255
		caseless[i] = i
	NEXT i
	FOR i = 'a' TO 'z'
		caseless[i] = i-32		' "a" to "z" become "A" to "Z"
	NEXT i
	FOR i = '0' TO '9'
		numeric[i] = 'i'			' TRUE for all ascii numbers
	NEXT i
END SUB
END FUNCTION
'
'
' #############################
' #####  XstQuickSort ()  #####
' #############################
'
'	Input:
'		a[]		= 1D array of ANY simple type to be sorted
'		n[]		= array for sort indices (optional)
'		low		= first index to sort
'		high	= last index to sort
'		flags	= see constants
'
'	Output:
'		a[]		= sorted data
'		n[]		= corresponding indices (if requested--n[0] = new index of old a[0])
'
'	Return:
'		$$TRUE		= error (ERROR() set)
'		$$FALSE		= no error
'
'	n[] is optional.  If it exists, it is redimensioned to match a[] and filled
'		with indices 0 TO UBOUND(a[]).  This array then tracks the sort of a[].
'		It is used as a secondary sort (increasing only) so that equal values of
'		a[] end up sorted by original index.
'	If n[] is NULL, the indices are not tracked = a faster sort.
'
'	To generate indices: 		DIM n[0]			(just make it non-NULL)
'																				(it returns with dimension of a[])
'	To skip indices:				DIM n[]
'
FUNCTION  XstQuickSort (a[], n[], low, high, mode)
'
	IFZ a[] THEN RETURN ($$TRUE)
	IF (low < 0) THEN RETURN ($$TRUE)
	IF (high < 0) THEN RETURN ($$TRUE)
	uA = UBOUND (a[])
	IF (low > uA) THEN RETURN ($$TRUE)
	IF (high > uA) THEN RETURN ($$TRUE)
'
	theType = TYPE (a[])
	SELECT CASE theType
		CASE $$SBYTE, $$UBYTE, $$SSHORT, $$USHORT, $$SLONG, $$ULONG, $$XLONG
		CASE $$GIANT, $$SINGLE, $$DOUBLE, $$STRING
		CASE ELSE
					errLast = ERROR (($$ErrorObjectArray << 8) OR $$ErrorNatureInvalidType)
					RETURN ($$TRUE)
	END SELECT
'
	IF n[] THEN
		DIM n[uA]
		FOR i = 0 TO uA
			n[i] = i
		NEXT i
	END IF
'
	IF high <= low THEN RETURN ($$TRUE)
'
	SELECT CASE theType
		CASE $$SLONG, $$XLONG
					XstQuickSort_XLONG (@a[], @n[], low, high, mode)
		CASE $$STRING
					ATTACH a[] TO a$[]
					IFZ (mode AND $$SortAlphaNumeric) THEN
						IFZ (mode AND $$SortCaseInsensitive) THEN
							XstQuickSort_STRING (@a$[], @n[], low, high, mode)
						ELSE
							XstQuickSort_STRING_nocase (@a$[], @n[], low, high, mode)
						END IF
					ELSE
						XstQuickSort_NumericSTRING (@a$[], @n[], low, high, mode)
					END IF
					ATTACH a$[] TO a[]
		CASE $$SBYTE
					ATTACH a[] TO a@[]
					DIM a[uA]																				' convert to XLONG array
					FOR i = low TO high
						a[i] = a@[i]
					NEXT i
					XstQuickSort_XLONG (@a[], @n[], low, high, mode)
					FOR i = low TO high
						a@[i] = a[i]
					NEXT i
					DIM a[]
					ATTACH a@[] TO a[]
		CASE $$UBYTE
					ATTACH a[] TO a@@[]
					DIM a[uA]																				' convert to XLONG array
					FOR i = low TO high
						a[i] = a@@[i]
					NEXT i
					XstQuickSort_XLONG (@a[], @n[], low, high, mode)
					FOR i = low TO high
						a@@[i] = a[i]
					NEXT i
					DIM a[]
					ATTACH a@@[] TO a[]
		CASE $$SSHORT
					ATTACH a[] TO a%[]
					DIM a[uA]																				' convert to XLONG array
					FOR i = low TO high
						a[i] = a%[i]
					NEXT i
					XstQuickSort_XLONG (@a[], @n[], low, high, mode)
					FOR i = low TO high
						a%[i] = a[i]
					NEXT i
					DIM a[]
					ATTACH a%[] TO a[]
		CASE $$USHORT
					ATTACH a[] TO a%%[]
					DIM a[uA]																				' convert to XLONG array
					FOR i = low TO high
						a[i] = a%%[i]
					NEXT i
					XstQuickSort_XLONG (@a[], @n[], low, high, mode)
					FOR i = low TO high
						a%%[i] = a[i]
					NEXT i
					DIM a[]
					ATTACH a%%[] TO a[]
		CASE $$ULONG
					ATTACH a[] TO a&&[]
					DIM a$$[uA]
					FOR i = low TO high
						a$$[i] = a&&[i]
					NEXT i
					XstQuickSort_GIANT (@a$$[], @n[], low, high, mode)
					FOR i = low TO high
						a&&[i] = a$$[i]
					NEXT i
					ATTACH a&&[] TO a[]
		CASE $$GIANT
					ATTACH a[] TO a$$[]
					XstQuickSort_GIANT (@a$$[], @n[], low, high, mode)
					ATTACH a$$[] TO a[]
		CASE $$SINGLE
					ATTACH a[] TO a![]
					DIM a#[uA]
					FOR i = low TO high
						a#[i] = a![i]
					NEXT i
					XstQuickSort_DOUBLE (@a#[], @n[], low, high, mode)
					FOR i = low TO high
						a![i] = a#[i]
					NEXT i
					ATTACH a![] TO a[]
		CASE $$DOUBLE
					ATTACH a[] TO a#[]
					XstQuickSort_DOUBLE (@a#[], @n[], low, high, mode)
					ATTACH a#[] TO a[]
	END SELECT
END FUNCTION
'
'
' ################################
' #####  XstGetClipboard ()  #####
' ################################
'
'	PURPOSE	: return a copy of windows clipboard text or bitmap image.
'	IN			: clipType - 1 = text, 2 = bitmap
'	OUT			: text$ - returned text
'						image[]	- returned bitmap
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstGetClipboard (clipType, @text$, UBYTE image[])
'
	text$ = ""
	DIM image[]
'
	IF ((clipType < 1) OR (clipType > 2)) THEN
		error = ($$ErrorObjectClipboard << 8) OR $$ErrorNatureInvalidType
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	SELECT CASE clipType
		CASE 1	:	GetClipText (@text$)
		CASE 2	: GetClipBitmap (@image[])
	END SELECT

END FUNCTION
'
'
' ################################
' #####  XstSetClipboard ()  #####
' ################################
'
'	PURPOSE	: copy text or bitmap to the windows clipboard.
'	IN			: clipType - 1 = text, 2 = bitmap
'						text$ - text string
'						image[]	- bitmap array
'	RETURN	: 0 on success, -1 on failure
'
FUNCTION  XstSetClipboard (clipType, text$, UBYTE image[])
'
	IF ((clipType < 1) OR (clipType > 2)) THEN
		error = ($$ErrorObjectClipboard << 8) OR $$ErrorNatureInvalidType
		old = ERROR (error)
		RETURN ($$TRUE)
	END IF
'
	SELECT CASE clipType
		CASE 1	: SetClipText (text$)
		CASE 2	: SetClipBitmap (@image[])
	END SELECT
'
END FUNCTION
'
'* Stop XBasic with an error message
' Note: The runtime environment may not yet be initialized, so don't rely
' on it.
' @param errorMessage$	This message is displayed
FUNCTION XstAbend(errorMessage$)
	MessageBoxA(0, &errorMessage$, &"Fatal Error", $$MB_APPLMODAL | $$MB_ICONSTOP | $$MB_OK)
	ExitProcess (0)
END FUNCTION

'* Show a message
' Note: The runtime environment may not yet be initialized, so don't rely
' on it.
' @param errorMessage$	This message is displayed
FUNCTION XstAlert(message$)
	MessageBoxA(0, &message$, &"Alert", $$MB_APPLMODAL | $$MB_ICONSTOP | $$MB_OK)
END FUNCTION
'
'
' ##############################
' #####  XstStartTimer ()  #####
' ##############################
'
FUNCTION  XstStartTimer (timer, count, msec, func)
	SHARED  TIMER  timer[]
'
	IFZ func THEN RETURN ($$TRUE)
	IFZ count THEN RETURN ($$TRUE)
	IF (msec <= 0) THEN RETURN ($$TRUE)
'
	timer = SetTimer (0, 0, msec, &XstTimer())
	IFZ timer THEN RETURN ($$TRUE)
'
' Timer Has Started
'
	IFZ timer[] THEN
		slot = 0
		utimer = 7
		DIM timer[utimer]
	ELSE
		slot = -1
		utimer = UBOUND (timer[])
		FOR i = 0 TO utimer
			IFZ timer[i].timer THEN slot = i : EXIT FOR
		NEXT i
		IF (slot < 0) THEN
			slot = utimer + 1
			utimer = utimer + 8
			REDIM timer[utimer]
		END IF
	END IF
'
	timer[slot].timer = timer
	timer[slot].count = count
	timer[slot].msec = msec
	timer[slot].func = func
	timer[slot].who = who
END FUNCTION
'
'
' #############################
' #####  XstKillTimer ()  #####
' #############################
'
FUNCTION  XstKillTimer (timer)
'
	SHARED  TIMER  timer[]
'
	IFZ timer[] THEN RETURN ($$TRUE)
	IFZ timer THEN RETURN ($$TRUE)
'
	slot = -1
	FOR i = 0 TO UBOUND (timer[])
		IF (timer = timer[i].timer) THEN slot = i : EXIT FOR
	NEXT i
'
	IF (slot < 0) THEN RETURN ($$TRUE)
	error = KillTimer (0, timer)
	timer[slot].timer = 0
	timer[slot].count = 0
	timer[slot].func = 0
	timer[slot].who = 0
	RETURN (!error)
END FUNCTION
'
'
' ##########################
' #####  XstRandom ()  #####
' ##########################
'
'   The KISS generator, (Keep It Simple Stupid), is
'   designed to combine the two multiply-with-carry
'   generators in MWC with the 3-shift register SHR3 and
'   the congruential generator CONG, using addition and
'   exclusive-or. Period about 2^123.
'   It is one of my favorite generators.
'   George Marsaglia
'
FUNCTION  ULONG XstRandom ()

	SHARED ULONG seed_kiss1, seed_kiss2, seed_kiss3, seed_kiss4
	STATIC GIANT jcong_cong
	STATIC ULONG z_mwc, w_mwc, mwc, jsr_shr3
	ULONG z_new, w_new
	SHARED initSeed	

	$M = 4294967296						 '2^32

	IFZ initSeed THEN GOSUB initialize

	GOSUB Cong
	GOSUB Mwc
	GOSUB Shr3

	RETURN ULONG(((mwc ^ jcong_cong) + jsr_shr3) MOD $M)

' ***** Cong *****
SUB Cong
	jcong_cong = (69069 * jcong_cong + 1234567) MOD $M
END SUB

' ***** Mwc *****
SUB Mwc
	z_mwc = 36969 * (z_mwc & 65535) + (z_mwc >> 16)
	z_new = z_mwc << 16
	w_mwc = 18000 * (w_mwc & 65535) + (w_mwc >> 16)
	w_new = w_mwc & 65535
	mwc =  z_new + w_new
END SUB

' ***** Shr3 *****
SUB Shr3
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 << 17)
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 >> 13)
	jsr_shr3 = jsr_shr3 ^ (jsr_shr3 << 5)
END SUB

' ***** initialize *****
SUB initialize

	initSeed = $$TRUE

	jcong_cong = seed_kiss1
	z_mwc      = seed_kiss2
	w_mwc      = seed_kiss3
	jsr_shr3   = seed_kiss4

	SELECT CASE ALL FALSE
		CASE jcong_cong : jcong_cong = XstRandomCreateSeed ()
		CASE z_mwc 			: GOSUB Cong
											z_mwc = jcong_cong
		CASE w_mwc 			: GOSUB Cong
											w_mwc = jcong_cong
		CASE jsr_shr3 	: GOSUB Cong
											jsr_shr3 = jcong_cong
	END SELECT
END SUB

END FUNCTION
'
'
' ####################################
' #####  XstRandomCreateSeed ()  #####
' ####################################
'
' XstRandomCreateSeed () is used to generate a random ULONG integer seed
' Created by Vic Drastik (source: xbrandom.x)
'
FUNCTION  ULONG XstRandomCreateSeed ()

	XLONG year, month, day, hour, minute, second, nsec
	GIANT centis

	$M         = 4294967296						 '2^32

' get the current time in centiseconds since year 0

	XstGetDateAndTime (@year, @month, @day, @weekDay, @hour, @minute, @second, @nsec)
	centis = (nsec\10000000)+100*(second+60*(minute+60*(hour+24*(day+31*(month+12*GIANT(year))))))

	RETURN ULONG(1 + ULONG(centis MOD $M-1))

END FUNCTION
'
'
' ##############################
' #####  XstRandomSeed ()  #####
' ##############################
'
' Provide seed(s) for XstRandom function. If seed is zero, then
' a seed is created using XstRandomCreateSeed and it's value
' is returned.
'
FUNCTION  XstRandomSeed (ULONG seed)

	SHARED ULONG seed_kiss1, seed_kiss2, seed_kiss3, seed_kiss4
	STATIC GIANT jcong_cong
	SHARED initSeed	

	$M         = 4294967296						 '2^32

	seed_kiss1 = seed
	jcong_cong = seed_kiss1

	SELECT CASE ALL FALSE
		CASE seed_kiss1 : seed_kiss1 = XstRandomCreateSeed ()
											seed = seed_kiss1
											jcong_cong = seed_kiss1
		CASE seed_kiss2 : GOSUB Cong
											seed_kiss2 = jcong_cong
		CASE seed_kiss3 : GOSUB Cong
											seed_kiss3 = jcong_cong
		CASE seed_kiss4 : GOSUB Cong
											seed_kiss4 = jcong_cong
	END SELECT
	initSeed = $$FALSE				' Force XstRandom() to reinitSeedialise from seed_kiss1, 2, 3, 4
	RETURN

' ***** Cong *****
SUB Cong
	jcong_cong = (69069 * jcong_cong + 1234567) MOD $M
END SUB

END FUNCTION
'
'
' #################################
' #####  XstRandomUniform ()  #####
' #################################
'
' XstRandomUniform returns a uniform random number, 0 < rn < 1.
'
FUNCTION  DOUBLE XstRandomUniform ()

	$UNIDIV = 0d3DF0000000100000				'1/(2^32-1)
	RETURN XstRandom() * $UNIDIV
END FUNCTION
'
'
' ############################
' #####  InitProgram ()  #####
' ############################
'
FUNCTION  InitProgram ()

	SHARED UBYTE  charsetBackslash[]
	SHARED UBYTE  charsetBackslashChar[]
	SHARED UBYTE  charsetHexLowerToUpper[]
	SHARED UBYTE  charsetNormalChar[]
	SHARED UBYTE  charsetUpperToLower[]
'
	DIM	charsetBackslash[255]
	DIM	charsetBackslashChar[255]
	DIM	charsetHexLowerToUpper[255]
	DIM	charsetNormalChar[255]
	DIM	charsetUpperToLower[255]

'
' ********************************  \a  \b  \d  \f  \n  \r  \v  \\  \"  \z
' *****  charsetBackslash[]  *****  \0 - \V
' ********************************  (others unchanged)
'
' Convert character following a \ into the proper binary value
' For all characters without special binary values, return the character
'
	offset = 10 - 'A'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetBackslash[i] = i - '0'
			CASE ((i >= 'A') AND (i <= 'V')):		charsetBackslash[i] = i + offset
			CASE ELSE:													charsetBackslash[i] = i
		END SELECT
	NEXT i
'
	FOR i = 0 TO 255
		SELECT CASE i
			CASE '\\':	charsetBackslash[i] = 0x5C		' backslash
			CASE '"':		charsetBackslash[i] = 0x22		' double-quote
			CASE 'a':		charsetBackslash[i] = 0x07		' alarm (bell)
			CASE 'b':		charsetBackslash[i] = 0x08		' backspace
			CASE 'd':		charsetBackslash[i] = 0x7F		' delete
			CASE 'e':		charsetBackslash[i] = 0x1B		' escape
			CASE 'f':		charsetBackslash[i] = 0x0C		' form-feed
			CASE 'n':		charsetBackslash[i] = 0x0A		' newline
			CASE 'r':		charsetBackslash[i] = 0x0D		' return
			CASE 't':		charsetBackslash[i] = 0x09		' tab
			CASE 'v':		charsetBackslash[i] = 0x0B		' vertical-tab
			CASE 'z':		charsetBackslash[i] = 0xFF		' finale  (highest UBYTE)
		END SELECT
	NEXT i
'
'
' ************************************  \a  \b  \d  \e  \f  \n  \r  \t  \v
' *****  charsetBackslashChar[]  *****  \\  \"
' ************************************
'
' Return printable character intended to follow \ backslash character
' Return bytes that are normal, printable, non-backslash characters
'
	FOR i = 0 TO 255
		SELECT CASE i
			CASE 0x5C:	charsetBackslashChar[i] = '\\'	' backslash
			CASE 0x22:	charsetBackslashChar[i] = '"'		' double-quote
			CASE 0x07:	charsetBackslashChar[i] = 'a'		' alarm (bell)
			CASE 0x08:	charsetBackslashChar[i] = 'b'		' backspace
			CASE 0x7F:	charsetBackslashChar[i] = 'd'		' delete
			CASE 0x1B:	charsetBackslashChar[i] = 'e'		' escape
			CASE 0x0C:	charsetBackslashChar[i] = 'f'		' form-feed
			CASE 0x0A:	charsetBackslashChar[i] = 'n'		' newline
			CASE 0x0D:	charsetBackslashChar[i] = 'r'		' return
			CASE 0x09:	charsetBackslashChar[i] = 't'		' tab
			CASE 0x0B:	charsetBackslashChar[i] = 'v'		' vertical-tab
			CASE ELSE:	charsetBackslashChar[i] = 0			' not a backslash char
		END SELECT
	NEXT i
'
'
' **************************************  0-9
' *****  charsetHexLowerToUpper[]  *****  a-f  ==>>  A-F  (others 0)
' **************************************  A-F
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexLowerToUpper[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexLowerToUpper[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexLowerToUpper[i] = i - 32
			CASE ELSE:													charsetHexLowerToUpper[i] = 0
		END SELECT
	NEXT i
'
'
' *********************************  0x00 - 0x1F  ===>>  0
' *****  charsetNormalChar[]  *****  0x7F - 0xFF  ===>>  0  (others unchanged)
' *********************************   \  and  "   ===>>  0
'
' Normal printable characters = the character, all others = 0
' NOTE:  tab, newline, etc... not considered normal printable characters
' NOTE:  backslash not considered normal printable character (need \\)
' NOTE:  double-quote not considered normal printable character (need \")
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE (i <= 0x1F)	:	charsetNormalChar[i] = 0		' control characters
			CASE (i == 0x22)	:	charsetNormalChar[i] = 0		' " = double-quote character
			CASE (i == 0x5C)	: charsetNormalChar[i] = 0		' \ = backslash character
			CASE (i >= 0x7F)	:	charsetNormalChar[i] = i		' non-English characters
			CASE ELSE					: charsetNormalChar[i] = i		' all English characters
		END SELECT
	NEXT i
'
'
' ***********************************
' *****  charsetUpperToLower[]  *****  A-Z  ==>>  a-z  (others unchanged)
' ***********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):   charsetUpperToLower[i] = i + 32
			CASE ELSE:                          charsetUpperToLower[i] = i
		END SELECT
	NEXT i

END FUNCTION
'
'
' ###################################
' #####  XstQuickSort_XLONG ()  #####
' ###################################
'
FUNCTION  XstQuickSort_XLONG (a[], n[], low, high, order)
	IF (low >= high) THEN RETURN								' less than two elements

	IF (order = $$SortDecreasing) THEN
		IF ((high - low) = 1) THEN								' two element left
			IF (a[low] > a[high]) THEN RETURN				' a[] correct order
			IF (a[low] < a[high]) THEN
				SWAP a[low], a[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a[low], a[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a[high], a[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition = a[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a[i] >= partition)
					INC i
				LOOP
				DO WHILE (j > i) AND (a[j] <= partition)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a[i] < partition) THEN EXIT DO
					IF (a[i] = partition) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a[j] > partition) THEN EXIT DO
					IF (a[j] = partition) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a[i], a[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)

	ELSE

		IF ((high - low) = 1) THEN								' two element left
			IF (a[low] < a[high]) THEN RETURN				' a[] correct order
			IF (a[low] > a[high]) THEN
				SWAP a[low], a[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a[low], a[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a[high], a[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition = a[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a[i] <= partition)
					INC i
				LOOP
				DO WHILE (j > i) AND (a[j] >= partition)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a[i] > partition) THEN EXIT DO
					IF (a[i] = partition) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a[j] < partition) THEN EXIT DO
					IF (a[j] = partition) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a[i], a[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF

	SWAP a[i], a[high]
	IF n[] THEN SWAP n[i], n[high]

	IF i > low + 1 THEN XstQuickSort_XLONG (@a[], @n[], low, i-1, order)
	IF i < high - 1 THEN XstQuickSort_XLONG (@a[], @n[], i+1, high, order)
END FUNCTION
'
'
' ###################################
' #####  XstQuickSort_GIANT ()  #####
' ###################################
'
FUNCTION  XstQuickSort_GIANT (a$$[], n[], low, high, order)
	IF (low >= high) THEN RETURN								' less than two elements

	IF (order = $$SortDecreasing) THEN
		IF ((high - low) = 1) THEN								' two element left
			IF (a$$[low] > a$$[high]) THEN RETURN		' a$$[] correct order
			IF (a$$[low] < a$$[high]) THEN
				SWAP a$$[low], a$$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$$[low], a$$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$$[high], a$$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition$$ = a$$[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a$$[i] >= partition$$)
					INC i
				LOOP
				DO WHILE (j > i) AND (a$$[j] <= partition$$)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a$$[i] < partition$$) THEN EXIT DO
					IF (a$$[i] = partition$$) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a$$[j] > partition$$) THEN EXIT DO
					IF (a$$[j] = partition$$) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$$[i], a$$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)

	ELSE

		IF ((high - low) = 1) THEN								' two element left
			IF (a$$[low] < a$$[high]) THEN RETURN		' a$$[] correct order
			IF (a$$[low] > a$$[high]) THEN
				SWAP a$$[low], a$$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$$[low], a$$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$$[high], a$$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition$$ = a$$[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a$$[i] <= partition$$)
					INC i
				LOOP
				DO WHILE (j > i) AND (a$$[j] >= partition$$)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a$$[i] > partition$$) THEN EXIT DO
					IF (a$$[i] = partition$$) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a$$[j] < partition$$) THEN EXIT DO
					IF (a$$[j] = partition$$) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$$[i], a$$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF

	SWAP a$$[i], a$$[high]
	IF n[] THEN SWAP n[i], n[high]

	IF i > low + 1 THEN XstQuickSort_GIANT (@a$$[], @n[], low, i-1, order)
	IF i < high - 1 THEN XstQuickSort_GIANT (@a$$[], @n[], i+1, high, order)
END FUNCTION
'
'
' ####################################
' #####  XstQuickSort_DOUBLE ()  #####
' ####################################
'
FUNCTION  XstQuickSort_DOUBLE (a#[], n[], low, high, order)
	IF (low >= high) THEN RETURN								' less than two elements

	IF (order = $$SortDecreasing) THEN
		IF ((high - low) = 1) THEN								' two element left
			IF (a#[low] > a#[high]) THEN RETURN			' a#[] correct order
			IF (a#[low] < a#[high]) THEN
				SWAP a#[low], a#[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a#[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a#[low], a#[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a#[high], a#[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition# = a#[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a#[i] >= partition#)
					INC i
				LOOP
				DO WHILE (j > i) AND (a#[j] <= partition#)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a#[i] < partition#) THEN EXIT DO
					IF (a#[i] = partition#) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a#[j] > partition#) THEN EXIT DO
					IF (a#[j] = partition#) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a#[i], a#[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)

	ELSE

		IF ((high - low) = 1) THEN								' two element left
			IF (a#[low] < a#[high]) THEN RETURN			' a#[] correct order
			IF (a#[low] > a#[high]) THEN
				SWAP a#[low], a#[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a#[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a#[low], a#[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a#[high], a#[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]

		partition# = a#[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a#[i] <= partition#)
					INC i
				LOOP
				DO WHILE (j > i) AND (a#[j] >= partition#)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a#[i] > partition#) THEN EXIT DO
					IF (a#[i] = partition#) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a#[j] < partition#) THEN EXIT DO
					IF (a#[j] = partition#) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a#[i], a#[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF

	SWAP a#[i], a#[high]
	IF n[] THEN SWAP n[i], n[high]

	IF i > low + 1 THEN XstQuickSort_DOUBLE (@a#[], @n[], low, i-1, order)
	IF i < high - 1 THEN XstQuickSort_DOUBLE (@a#[], @n[], i+1, high, order)
END FUNCTION
'
'
' ####################################
' #####  XstQuickSort_STRING ()  #####
' ####################################
'
FUNCTION  XstQuickSort_STRING (a$[], n[], low, high, order)
'
	IF (low >= high) THEN RETURN								' less than two elements
'
	IF (order AND $$SortDecreasing) THEN				' "z" to "A"
		IF ((high - low) = 1) THEN								' two element left
			IF (a$[low] > a$[high]) THEN RETURN			' a$[] correct order
'			IF XstCompareStrings (&a$[low], $$GT, &a$[high], order) THEN RETURN			' a$[] correct order
			IF (a$[low] < a$[high]) THEN
'			IF XstCompareStrings (&a$[low], $$LT, &a$[high], order) THEN
				SWAP a$[low], a$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$[low], a$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$[high], a$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]
		partition$ = a$[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE ((i < j) AND (a$[i] >= partition$))
'				DO WHILE ((i < j) AND XstCompareStrings (&a$[i], $$GE, &partition$, order))
					INC i
				LOOP
				DO WHILE ((j > i) AND (a$[j] <= partition$))
'				DO WHILE ((j > i) AND XstCompareStrings (&a$[j], $$LE, &partition$, order))
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a$[i] < partition$) THEN EXIT DO
'					IF XstCompareStrings (&a$[i], $$LT, &partition$, order) THEN EXIT DO
					IF (a$[i] = partition$) THEN
'					IF XstCompareStrings (&a$[i], $$EQ, &partition$, order) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a$[j] > partition$) THEN EXIT DO
'					IF XstCompareStrings (&a$[j], $$GT, &partition$, order) THEN EXIT DO
					IF (a$[j] = partition$) THEN
'					IF XstCompareStrings (&a$[j], $$EQ, &partition$, order) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$[i], a$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	ELSE
		IF ((high - low) = 1) THEN								' two element left
			IF (a$[low] < a$[high]) THEN RETURN			' a$[] correct order
'			IF XstCompareStrings (&a$[low], $$LT, &a$[high], order) THEN RETURN			' a$[] correct order
			IF (a$[low] > a$[high]) THEN
'			IF XstCompareStrings (&a$[low], $$GT, &a$[high], order) THEN
				SWAP a$[low], a$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$[low], a$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$[high], a$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]
		partition$ = a$[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (a$[i] <= partition$)
'				DO WHILE (i < j) AND XstCompareStrings (&a$[i], $$LE, &partition$, order)
					INC i
				LOOP
				DO WHILE (j > i) AND (a$[j] >= partition$)
'				DO WHILE (j > i) AND XstCompareStrings (&a$[j], $$GE, &partition$, order)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (a$[i] > partition$) THEN EXIT DO
'					IF XstCompareStrings (&a$[i], $$GT, &partition$, order) THEN EXIT DO
					IF (a$[i] = partition$) THEN
'					IF XstCompareStrings (&a$[i], $$EQ, &partition$, order) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (a$[j] < partition$) THEN EXIT DO
'					IF XstCompareStrings (&a$[j], $$LT, &partition$, order) THEN EXIT DO
					IF (a$[j] = partition$) THEN
'					IF XstCompareStrings (&a$[j], $$EQ, &partition$, order) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$[i], a$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF
'
	SWAP a$[i], a$[high]
	IF n[] THEN SWAP n[i], n[high]
'
	IF i > low + 1 THEN XstQuickSort_STRING (@a$[], @n[], low, i-1, order)
	IF i < high - 1 THEN XstQuickSort_STRING (@a$[], @n[], i+1, high, order)
END FUNCTION
'
'
' ###########################################
' #####  XstQuickSort_STRING_nocase ()  #####
' ###########################################
'
FUNCTION  XstQuickSort_STRING_nocase (a$[], n[], low, high, order)
'
	IF (low >= high) THEN RETURN								' less than two elements
'
	IF (order AND $$SortDecreasing) THEN				' "z" to "A"
		IF ((high - low) = 1) THEN								' two element left
			IF (UCASE$(a$[low]) > UCASE$(a$[high])) THEN RETURN			' a$[] correct order
			IF (UCASE$(a$[low]) < UCASE$(a$[high])) THEN
				SWAP a$[low], a$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$[low], a$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$[high], a$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]
		IF n[] THEN nPartition = n[high]
		partition$ = UCASE$(a$[high])
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE ((i < j) AND (UCASE$(a$[i]) >= partition$))
					INC i
				LOOP
				DO WHILE ((j > i) AND (UCASE$(a$[j]) <= partition$))
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (UCASE$(a$[i]) < partition$) THEN EXIT DO
					IF (UCASE$(a$[i]) == partition$) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (UCASE$(a$[j]) > partition$) THEN EXIT DO
					IF (UCASE$(a$[j]) == partition$) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$[i], a$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	ELSE
		IF ((high - low) = 1) THEN								' two element left
			IF (UCASE$(a$[low]) < UCASE$(a$[high])) THEN RETURN			' a$[] correct order
			IF (UCASE$(a$[low]) > UCASE$(a$[high])) THEN
				SWAP a$[low], a$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$[low], a$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$[high], a$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]
		IF n[] THEN nPartition = n[high]
		partition$ = UCASE$(a$[high])
		i = low: j = high
		DO
			IFZ n[] THEN
				DO WHILE (i < j) AND (UCASE$(a$[i]) <= partition$)
					INC i
				LOOP
				DO WHILE (j > i) AND (UCASE$(a$[j]) >= partition$)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
					IF (UCASE$(a$[i]) > partition$) THEN EXIT DO
					IF (UCASE$(a$[i]) == partition$) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
					IF (UCASE$(a$[j]) < partition$) THEN EXIT DO
					IF (UCASE$(a$[j]) == partition$) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$[i], a$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF
'
	SWAP a$[i], a$[high]
	IF n[] THEN SWAP n[i], n[high]
'
	IF i > low + 1 THEN XstQuickSort_STRING_nocase (@a$[], @n[], low, i-1, order)
	IF i < high - 1 THEN XstQuickSort_STRING_nocase (@a$[], @n[], i+1, high, order)
END FUNCTION
'
'
' ###########################################
' #####  XstQuickSort_NumericSTRING ()  #####
' ###########################################
'
FUNCTION  XstQuickSort_NumericSTRING (a$[], n[], low, high, order)
'
	IF (low >= high) THEN RETURN								' less than two elements
'
	IF (order AND $$SortDecreasing) THEN				' "z" to "A"
		IF ((high - low) = 1) THEN								' two element left
'			IF (a$[low] > a$[high]) THEN RETURN			' a$[] correct order
			IF XstCompareStrings (&a$[low], $$GT, &a$[high], order) THEN RETURN			' a$[] correct order
'			IF (a$[low] < a$[high]) THEN
			IF XstCompareStrings (&a$[low], $$LT, &a$[high], order) THEN
				SWAP a$[low], a$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$[low], a$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$[high], a$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]
		partition$ = a$[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
'				DO WHILE ((i < j) AND (a$[i] >= partition$))
				DO WHILE ((i < j) AND XstCompareStrings (&a$[i], $$GE, &partition$, order))
					INC i
				LOOP
'				DO WHILE ((j > i) AND (a$[j] <= partition$))
				DO WHILE ((j > i) AND XstCompareStrings (&a$[j], $$LE, &partition$, order))
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
'					IF (a$[i] < partition$) THEN EXIT DO
					IF XstCompareStrings (&a$[i], $$LT, &partition$, order) THEN EXIT DO
'					IF (a$[i] = partition$) THEN
					IF XstCompareStrings (&a$[i], $$EQ, &partition$, order) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
'					IF (a$[j] > partition$) THEN EXIT DO
					IF XstCompareStrings (&a$[j], $$GT, &partition$, order) THEN EXIT DO
'					IF (a$[j] = partition$) THEN
					IF XstCompareStrings (&a$[j], $$EQ, &partition$, order) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$[i], a$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	ELSE
		IF ((high - low) = 1) THEN								' two element left
'			IF (a$[low] < a$[high]) THEN RETURN			' a$[] correct order
			IF XstCompareStrings (&a$[low], $$LT, &a$[high], order) THEN RETURN			' a$[] correct order
'			IF (a$[low] > a$[high]) THEN
			IF XstCompareStrings (&a$[low], $$GT, &a$[high], order) THEN
				SWAP a$[low], a$[high]
				IF n[] THEN SWAP n[low], n[high]
			ELSE
				IFZ n[] THEN RETURN										' a$[] equal:  use n[]
				IF (n[low] > n[high]) THEN						' n[] sort $$SortIncreasing
					SWAP a$[low], a$[high]
					SWAP n[low], n[high]
				END IF
			END IF
			RETURN
		END IF
		midPoint = (high + low) >> 1
		SWAP a$[high], a$[midPoint]
		IF n[] THEN SWAP n[high], n[midPoint]
		partition$ = a$[high]
		IF n[] THEN nPartition = n[high]
		i = low: j = high
		DO
			IFZ n[] THEN
'				DO WHILE (i < j) AND (a$[i] <= partition$)
				DO WHILE (i < j) AND XstCompareStrings (&a$[i], $$LE, &partition$, order)
					INC i
				LOOP
'				DO WHILE (j > i) AND (a$[j] >= partition$)
				DO WHILE (j > i) AND XstCompareStrings (&a$[j], $$GE, &partition$, order)
					DEC j
				LOOP
			ELSE
				DO WHILE (i < j)
'					IF (a$[i] > partition$) THEN EXIT DO
					IF XstCompareStrings (&a$[i], $$GT, &partition$, order) THEN EXIT DO
'					IF (a$[i] = partition$) THEN
					IF XstCompareStrings (&a$[i], $$EQ, &partition$, order) THEN
						IF (n[i] > nPartition) THEN EXIT DO
					END IF
					INC i
				LOOP
				DO WHILE (j > i)
'					IF (a$[j] < partition$) THEN EXIT DO
					IF XstCompareStrings (&a$[j], $$LT, &partition$, order) THEN EXIT DO
'					IF (a$[j] = partition$) THEN
					IF XstCompareStrings (&a$[j], $$EQ, &partition$, order) THEN
						IF (n[j] < nPartition) THEN EXIT DO
					END IF
					DEC j
				LOOP
			END IF
			IF (i < j) THEN
				SWAP a$[i], a$[j]
				IF n[] THEN SWAP n[i], n[j]
			END IF
		LOOP WHILE (i < j)
	END IF
'
	SWAP a$[i], a$[high]
	IF n[] THEN SWAP n[i], n[high]
'
	IF i > low + 1 THEN XstQuickSort_NumericSTRING (@a$[], @n[], low, i-1, order)
	IF i < high + 1 THEN XstQuickSort_NumericSTRING (@a$[], @n[], i+1, high, order)
END FUNCTION
'
'
'* Does the attribute match the attribute-filter?
' @param attr		The attribute
' @param filter	The attribute-filter: 0 matches only normal files,
'								$$FileDirectory matches only directories. Otherwise files
'								with at least 1 matching attribute-bit are matched (i.e.
'								(attr AND filter) != 0).
' @return				true: The attribute matches the filter, false: otherwise.

FUNCTION XstAttributeMatch(attr, filter)
	IF attr = 0 THEN RETURN $$FALSE
	IF (filter AND $$FileDirectory) THEN
		RETURN ((attr AND $$FileDirectory) != 0)
	END IF
	IF (filter == 0) THEN
		RETURN ((attr AND $$FileDirectory) == 0)
	END IF
	RETURN ((attr AND filter) != 0)
END FUNCTION

'* Return the position of the first occurence of a directory separator (\ or /)
' @param str$		The string to be searched
' @param start	The start position of the search (all characters from position
'								'start' until the end of the string are searched. Use -1 to
'								search the whole string.
' @return				The position of the first occurence of a directory separator.
FUNCTION getFirstSlash(str$, stop)
	IF stop < 0 THEN
		slash1 = INSTR(str$, "/")
		slash2 = INSTR(str$, $$PathSlash$)
	ELSE
		slash1 = INSTR(str$, "/", stop)
		slash2 = INSTR(str$, $$PathSlash$, stop)
	END IF
	IFZ slash1 THEN
		RETURN slash2
	ELSE
		RETURN MIN(slash1, slash2)
	END IF
END FUNCTION

'* Return the position of the last occurence of a directory separator (\ or /)
' @param str$		The string to be searched
' @param start	The start position of the search (all characters until and
'								including position 'start' are searched. Use -1 to search the
'								whole string.
' @return				The position of the last occurence of a directory separator.
FUNCTION getLastSlash(str$, stop)
	IF stop < 0 THEN
		slash1 = RINSTR(str$, "/")
		slash2 = RINSTR(str$, $$PathSlash$)
	ELSE
		slash1 = RINSTR(str$, "/", stop)
		slash2 = RINSTR(str$, $$PathSlash$, stop)
	END IF
	IFZ slash1 THEN
		RETURN slash2
	ELSE
		RETURN MAX(slash1, slash2)
	END IF


END FUNCTION
'
'
' ############################
' #####  GetClipText ()  #####
' ############################
'
FUNCTION  GetClipText (@text$)
	$Text = 1																		' CF_TEXT clip format
'
	text$ = ""																	' default text$ is empty
	ok = OpenClipboard (0)											' open clipboard
	IFZ ok THEN RETURN													' clipboard unavailable
	handle = GetClipboardData ($Text)				    ' get clipboard data handle
	IFZ handle THEN CloseClipboard () : RETURN	' no text in clipboard
	addr = GlobalLock (handle)									' get address of text
	IFZ addr THEN CloseClipboard () : RETURN		' no text in clipboard
	upper = GlobalSize (handle)									' get upper bound of text$
	IF (upper <= 0) THEN CloseClipboard () : RETURN		' valid size ???
	text$ = NULL$ (upper)										' create return string
	d = -1																	' destination offset
	lastByte = 0														' nothing to start
	FOR s = 0 TO upper											' for whole loop
		byte = UBYTEAT (addr, s)							' get next byte
		IFZ byte THEN EXIT FOR								' done on null terminator
		IF (byte == '\n') THEN								' if this byte is a newline
			IF (lastByte == '\r') THEN DEC d		' overwrite if lastByte was a <cr>
		END IF																'
		INC d
		text${d} = byte												' byte to text string
		lastByte = byte												' lastByte = this byte
	NEXT s																	' next source byte
	text$ = LEFT$(text$,d+1)								' give text$ correct length
	GlobalUnlock (handle)
	CloseClipboard ()												' release clipboard

END FUNCTION
'
'
' ##############################
' #####  GetClipBitmap ()  #####
' ##############################
'
FUNCTION  GetClipBitmap (UBYTE image[])

	BITMAP bm

	$BI_RGB       = 0														' 24-bit RGB
	$CF_BITMAP    = 2														' clipboard format bitmap

	DIM image[] 																' default image[] is empty

	ok = OpenClipboard (0)											' open clipboard
	IFZ ok THEN RETURN ($$FALSE)								' clipboard unavailable

	hImage = GetClipboardData ($CF_BITMAP)			' get handle to a bitmap image
	IFZ hImage THEN CloseClipboard () : RETURN ($$FALSE)	' no bmp image in clipboard

	hdcMem      = CreateCompatibleDC (NULL)
	hBitmapLast = SelectObject (hdcMem, hImage)
	GetObjectA (hImage, SIZE(bm), &bm)
	width       = bm.width
	height      = bm.height

	dataOffset = 54

' alignment on multiple of 32 bits or 4 bytes

	size = dataOffset + (height * ((width * 3) + 3 AND -4))
	upper = size - 1
	DIM image[upper]

'	Fill BITMAPFILEHEADER
'	Windows version:  little ENDIAN; no alignment concerns

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

	ok = GetDIBits (hdcMem, hImage, 0, height, dataAddr, infoAddr, $$DIB_RGB_COLORS)
	SelectObject (hdcMem, hBitmapLast)
	DeleteDC (hdcMem)

	CloseClipboard ()														' release clipboard
	IFZ ok THEN RETURN ($$FALSE) ELSE RETURN ($$TRUE)
END FUNCTION
'
'
' ############################
' #####  SetClipText ()  #####
' ############################
'
FUNCTION  SetClipText (text$)
	$Text = 1
'
	length = LEN(text$) << 1 + 1
	handle = GlobalAlloc (0x2002, length)
	addr = GlobalLock (handle)
	j = 0
	preByte = 0
	IFZ text$ THEN
		UBYTEAT (addr) = 0				' if text$ is an empty string
	ELSE
		FOR i = 0 TO LEN(text$)
			byte = text${i}
			UBYTEAT (addr,j) = byte
			IF (byte = '\n') THEN
				IF (preByte != '\r') THEN
					UBYTEAT (addr,j) = '\r' : INC j
					UBYTEAT (addr,j) = '\n'
				END IF
			END IF
			preByte = byte
			INC j
		NEXT i
	END IF
	GlobalUnlock (handle)
	OpenClipboard (0)
	EmptyClipboard ()
	SetClipboardData ($Text, handle)
	CloseClipboard ()

END FUNCTION
'
'
' ##############################
' #####  SetClipBitmap ()  #####
' ##############################
'
FUNCTION  SetClipBitmap (UBYTE image[])

	$CF_BITMAP    = 2
	$CF_DIB       = 8

	IFZ image[] THEN RETURN ($$FALSE)
	error = $$TRUE

	size = SIZE (image[])
	iAddr = &image[]

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

	iAddr = &image[]

	bitmapInfo = iAddr + 14
	bitmapData = iAddr + dataOffset

	startScan = 0
	scanLines = height

	hdc    = GetDC (NULL)
	memDC  = CreateCompatibleDC (hdc)
	hImage = CreateCompatibleBitmap (hdc, width, height)	' don't delete this object, windows will take care of it

	IFZ hImage THEN
		DeleteDC (memDC)
		ReleaseDC (NULL, hdc)
		RETURN ($$FALSE)
	END IF

	hBitmapLast = SelectObject (memDC, hImage)
	ok = SetDIBits (memDC, hImage, startScan, scanLines, bitmapData, bitmapInfo, $$DIB_RGB_COLORS)

	SelectObject (memDC, hBitmapLast)

	DeleteDC (memDC)
	ReleaseDC (NULL, hdc)

	IFZ ok THEN error = $$FALSE : GOTO end

	ok = OpenClipboard (0)											' open clipboard
	IFZ ok THEN error = $$FALSE : GOTO end			' clipboard unavailable
	EmptyClipboard ()
	ok  = SetClipboardData ($CF_BITMAP, hImage)
	CloseClipboard ()
	IFZ ok THEN error = $$FALSE

end:
	RETURN error

END FUNCTION
'
'
' #########################
' #####  XstTimer ()  #####
' #########################
'
FUNCTION  XstTimer (hwnd, message, timer, time)
'
	SHARED  TIMER  timer[]
	STATIC  FUNCADDR  func (XLONG, XLONG, XLONG, XLONG)
'
	IFZ timer[] THEN PRINT "XstTimer(): Error: (timer[] is empty)" : RETURN
'
	slot = -1
	FOR i = 0 TO UBOUND (timer[])
		IF (timer = timer[i].timer) THEN slot = i : EXIT FOR
	NEXT i
'
	IF (slot < 0) THEN PRINT "XstTimer(): Error: (timer not in timer[])" : RETURN
	count = timer[slot].count - 1
	func = timer[slot].func
	msec = timer[slot].msec
	who = timer[slot].who
	kill = @func (timer, @count, msec, time)
	timer[slot].count = count
'
	SELECT CASE TRUE
		CASE (count = -1)		: XstKillTimer (timer)
		CASE (count = 0)		: XstKillTimer (timer)
		CASE (kill = -1)		: XstKillTimer (timer)
	END SELECT
'
END FUNCTION
'
'
' ##############################
' #####  XstFileExists ()  #####
' ##############################
'
' Determine if file exists. Returns 0 on success, -1 on failure.
'
FUNCTION XstFileExists (file$)

	IFZ file$ THEN RETURN ($$TRUE)
	ofile = XxxOpen (file$, $$RD)
	IF ofile = -1 THEN RETURN ($$TRUE)
	XxxClose (ofile)

END FUNCTION
'
' ###########################
' #####  XstStripChars  #####
' ###########################
'
' Remove all characters from source$ contained in testchar$.
' Returns 0 on success, -1 on error
'
FUNCTION XstStripChars (@source$, testchar$)

UBYTE inchar

	IFZ source$ THEN RETURN ($$TRUE)
	IFZ testchar$ THEN RETURN ($$TRUE)
	
	in_string_max = LEN (source$) - 1 
	test_string_max = LEN (testchar$) - 1
	
'build table of ascii codes and set = 0 if character preserved -1 if character to be stripped
	striptable$ = NULL$(256)
	FOR i = 0 TO test_string_max
		striptable${testchar${i}} = 0xFF
	NEXT i
	
	out_index = 0
	FOR in_index = 0 TO in_string_max 
		
		inchar = source${in_index}
		
		IFZ striptable${inchar} THEN
			source${out_index} = inchar
			INC out_index
		ENDIF 
		
	NEXT in_index
	
	'trim off any trailing stuff from original string and set the new length in header
	'LEFT$ will also append a NULL - length does not include the NULL
	'note - out_index is pointing to character after the end of string in ZERO based index mode
	'this is equivalent to pointing at the last character in 1 based index mode used by LEFT$
	
	source$ = LEFT$(source$, out_index)
	
	RETURN $$FALSE

END FUNCTION
'
' ###############################
' #####  XstTranslateChars  #####
' ###############################
'
' Alan Gent 5 November 2005
' Scan string$ translating all occurrences of any character in from$
' to the corresponding character in to$.
' The nth character in from$ is translated to the nth character in to$.
' from$ and to$ must have the same number of characters.
' Returns 0 on success, -1 on error.
'
FUNCTION XstTranslateChars (@string$, from$, to$)

UBYTE ubyte[]
'basic edit checks
	IFZ string$ THEN RETURN $$TRUE
	IFZ from$   THEN RETURN $$TRUE
	IFZ to$     THEN RETURN $$TRUE
	
	string_len = LEN(string$)
	from_len   = LEN(from$)
	to_len     = LEN(to$)
	
	IFZ string_len THEN RETURN $$TRUE
	IFZ from_len   THEN RETURN $$TRUE
	IFZ to_len     THEN RETURN $$TRUE
	IF  from_len <> to_len THEN RETURN $$TRUE
	
'build the translation table
	ascii$ = NULL$(256)
	FOR i = 0 TO 255
		ascii${i} = i
	NEXT i
	
	FOR i = 0 TO from_len - 1
		ascii${from${i}} = to${i}
	NEXT i
	
'scan string$ performing the translations	
	FOR i = 0 TO string_len - 1
		string${i} = ascii${string${i}}
	NEXT i
	
	RETURN $$FALSE

END FUNCTION
'
' #####################
' #####  XstCall  #####
' #####################
'
' Call any library function by using computed function.
' Return value is function's  return value.
' Example:
'	DIM args[2]
'	args[0] = 0
'	fn$ = NULL$(255)
'	args[1] = &fn$
'	args[2] = LEN(fn$)
'	ret = XstCall ("GetModuleFileName", "kernel32.dll", @args[])
'	PRINT "XstCall: 3 args: GetModuleFileName ret="; ret; " "; LEFT$(fn$, ret)
'
FUNCTION XstCall (funcName$, dllName$, @args[])

	FUNCADDR procAddr ()

	IFZ funcName$ THEN RETURN
	IFZ dllName$ THEN RETURN

	arg = 0
	return = 0

	hInst = GetModuleHandleA (&dllName$)
	IFZ hInst THEN
		hInst = LoadLibraryA (&dllName$)
	END IF
	IFZ hInst THEN RETURN

	procAddr = GetProcAddress (hInst, &funcName$)

	IFZ procAddr THEN
		fn$ = funcName$ + "A"
		procAddr = GetProcAddress (hInst, &fn$)
	END IF

	IFZ procAddr THEN
		fn$ = "_" + funcName$
		procAddr = GetProcAddress (hInst, &fn$)
	END IF

	IF procAddr THEN
		upp = UBOUND (args[])
		IF upp >= 0 THEN
			FOR i = upp TO 0 STEP -1
				arg = args[i]
ASM				push [ebp-28]
			NEXT i
		END IF
		return = @procAddr ()
	END IF
	
	RETURN return

END FUNCTION
'
'
' ###############################
' #####  XstAnsiToUnicode$  #####
' ###############################
'
' Convert xblite ansi string to unicode string.
' 
FUNCTION XstAnsiToUnicode$ (ansi$)

	len = LEN(ansi$)
	' 2 output bytes per input character plus an extra terminating NULL
	unicode$ = NULL$(2 * len + 1)					 ' xblite appends 1 more NULL
	uniptr   = &unicode$
	
	' the ascii UBYTE 0xnn becomes the USHORT 0x00nn 
	' note that USHORT 0x00nn is stored in memory as 0xnn00
	upp = len - 1
	FOR i = 0 TO upp	
		USHORTAT(uniptr, [i]) = ansi${i}
	NEXT i
	
	RETURN unicode$
END FUNCTION
'
'
' ###############################
' #####  XstUnicodeToAnsi$  #####
' ###############################
'
' Convert unicode string to ansi string.
' lpTextWide is pointer to a unicode string
' 
FUNCTION XstUnicodeToAnsi$ (lpTextWide)

	len = lstrlenW(lpTextWide)			' number of characters in unicode string
	asc$ = NULL$(len)	 							' xblite appends a NULL
	upp = len - 1
	FOR i = 0 TO upp	
		val = USHORTAT(lpTextWide, [i])
		IF val > 255 THEN							' make sure is an ansi character
			asc$ = "": RETURN asc$			' abort and return empty string if not
		ENDIF		
		asc${i} = val
	NEXT i
	
	RETURN asc$											' length and terminating null already set 
END FUNCTION
'
'
' ############################
' #####  XstRandomRange  #####
' ############################
'
' result is random XLONG number in range n1 to n2 inclusive
' note: n2 - n1 must be LESS than 4,294,967,295
'
FUNCTION XstRandomRange (n1, n2)
	IF n1 = n2 THEN RETURN n1
	IF n1 > n2 THEN SWAP n1, n2
	RETURN n1 + (XstRandom() MOD ULONG(n2 - n1 + 1))	
END FUNCTION
'
'
' #############################
' #####  XstRandomRangeF  #####
' #############################
'
' result is random DOUBLE number in range n1# to n2# non-inclusive
' never actually returns n1# or n2# since XstRandomUniform() never
' returns exactly 0.0 or 1.0
'
FUNCTION DOUBLE XstRandomRangeF (DOUBLE n1, DOUBLE n2)
	IF n1 = n2 THEN RETURN n1
	IF n1 > n2 THEN SWAP n1, n2
	RETURN n1 + (XstRandomUniform() *  (n2 - n1))
END FUNCTION
'
'
' ##########################
' #####  XstRandomRGB  #####
' ##########################
'
' result is a random RGB color with 0 in the high order byte
'
FUNCTION XstRandomRGB ()
	RETURN XstRandom() AND 0x00FFFFFF
END FUNCTION
'
'
' ###########################
' #####  XstRandomARGB  #####
' ###########################
'
' result is an ARGB color with specified alpha and random RGB
'
FUNCTION XstRandomARGB (UBYTE alpha)
	RETURN (XstRandom() AND 0x00FFFFFF) OR (alpha << 24)
END FUNCTION
'
'
' #########################
' #####  XstLoadData  #####
' #########################
'
' 1D ARRAYS
' ---------
' 1. XstLoadData() handles 1D arrays for standard numeric types only
' 2. The input can be a string or a file containing CSV data. This can be unformatted or in the formatted style
'    created by XstSaveArray() or manually.
' 3. A new array is created and populated
' 4. An existing array is redimensioned and the data is APPENDED to the existing data without loss. If REPLACEMENT
'    is required then use XstLoadArray() instead
' 5. The programmer must specify type because TYPE() within a function declared with ANY always returns the type
'    used in the definition above (XLONG) rather than the type of the array passed at runtime.
'    Type is also needed for brand new arrays

' nD ARRAYS
' ---------
' 1. XstLoadData() does not support nD arrays. Use XstLoadArray() instead
'
FUNCTION XstLoadData (a[], data$, type)

	IFZ data$ THEN RETURN $$TRUE

	SELECT CASE type
		CASE $$SBYTE, $$UBYTE, $$SSHORT, $$USHORT, $$SLONG, $$ULONG, $$XLONG, $$GIANT, $$SINGLE, $$DOUBLE, $$LONGDOUBLE:
		CASE -1 : type = $$XLONG
		CASE 0  : type = TYPE (a[]) : IFZ type THEN RETURN $$TRUE
		CASE ELSE  : RETURN $$TRUE
	END SELECT
	
	IF a[] THEN
		theType = TYPE (a[])
		IF type <> theType THEN RETURN $$TRUE
	END IF


	SELECT CASE type
		CASE $$SBYTE  		: ATTACH a[] TO t@[]
		CASE $$UBYTE  		: ATTACH a[] TO t@@[]
		CASE $$SSHORT 		: ATTACH a[] TO t%[]
		CASE $$USHORT 		: ATTACH a[] TO t%%[]
		CASE $$SLONG  		: ATTACH a[] TO t&[]
		CASE $$ULONG  		: ATTACH a[] TO t&&[]
		CASE $$XLONG			: ATTACH a[] TO t[]
		CASE $$SINGLE 		: ATTACH a[] TO t![]
		CASE $$DOUBLE 		: ATTACH a[] TO t#[]
		CASE $$LONGDOUBLE : ATTACH a[] TO t##[]
		CASE $$GIANT  		: ATTACH a[] TO t$$[]
	END SELECT
	
	IFZ INSTR(data$,",") THEN
		IF XstLoadString (data$, @xx$) THEN RETURN $$TRUE
	ELSE
		xx$ = data$
	END IF
	
	' strip out any formatting / whitespace
	XstStripChars(@xx$, "{}\r\n")
	XstParseStringToStringArray (xx$, ",", @temp$[])
	
	SELECT CASE type
		CASE $$SBYTE  		: upper = UBOUND(t@[]) 
		CASE $$UBYTE  		: upper = UBOUND(t@@[]) 
		CASE $$SSHORT 		: upper = UBOUND(t%[]) 
		CASE $$USHORT 		: upper = UBOUND(t%%[]) 
		CASE $$SLONG  		: upper = UBOUND(t&[]) 
		CASE $$ULONG  		: upper = UBOUND(t&&[]) 
		CASE $$XLONG			: upper = UBOUND(t[]) 
		CASE $$SINGLE 		: upper = UBOUND(t![]) 
		CASE $$DOUBLE 		: upper = UBOUND(t#[]) 
		CASE $$LONGDOUBLE : upper = UBOUND(t##[]) 
		CASE $$GIANT  		: upper = UBOUND(t$$[]) 	
	END SELECT

	nvals = UBOUND(temp$[]) + 1

	IF upper = -1 THEN
		SELECT CASE type
			CASE $$SBYTE  		: DIM tt@[nvals - 1]	
			CASE $$UBYTE  		: DIM tt@@[nvals - 1]	
			CASE $$SSHORT 		: DIM tt%[nvals - 1]	
			CASE $$USHORT 		: DIM tt%%[nvals - 1]	
			CASE $$SLONG  		: DIM tt&[nvals - 1]	
			CASE $$ULONG  		: DIM tt&&[nvals - 1]	
			CASE $$XLONG			: DIM tt[nvals - 1]	
			CASE $$SINGLE 		: DIM tt![nvals - 1]	
			CASE $$DOUBLE 		: DIM tt#[nvals - 1]	
			CASE $$LONGDOUBLE : DIM tt##[nvals - 1]	
			CASE $$GIANT  		: DIM tt$$[nvals - 1]	
		END SELECT
		
		FOR i = 0 TO nvals - 1
			SELECT CASE type
				CASE $$SBYTE  		: tt@[i] 	= SBYTE(temp$[i])
				CASE $$UBYTE  		: tt@@[i] = UBYTE(temp$[i])
				CASE $$SSHORT 		: tt%[i] 	= SSHORT(temp$[i])
				CASE $$USHORT 		: tt%%[i] = USHORT(temp$[i])
				CASE $$SLONG  		: tt&[i] 	= SLONG(temp$[i])
				CASE $$ULONG  		: tt&&[i] = ULONG(temp$[i])
				CASE $$XLONG  		: tt[i] 	= XLONG(temp$[i])
				CASE $$SINGLE 		: tt![i] 	= SINGLE(temp$[i])
				CASE $$DOUBLE 		: tt#[i] 	= DOUBLE(temp$[i])
				CASE $$LONGDOUBLE : tt##[i] = LONGDOUBLE(temp$[i])
				CASE $$GIANT  		: tt$$[i] = GIANT(temp$[i])
			END SELECT
		NEXT i
		
		SELECT CASE type
			CASE $$SBYTE  		: ATTACH tt@[] TO a[]
			CASE $$UBYTE  		: ATTACH tt@@[] TO a[]
			CASE $$SSHORT 		: ATTACH tt%[] TO a[]
			CASE $$USHORT 		: ATTACH tt%%[] TO a[]
			CASE $$SLONG  		: ATTACH tt&[] TO a[]
			CASE $$ULONG  		: ATTACH tt&&[] TO a[]
			CASE $$XLONG			: ATTACH tt[] TO a[]
			CASE $$SINGLE 		: ATTACH tt![] TO a[]
			CASE $$DOUBLE 		: ATTACH tt#[] TO a[]
			CASE $$LONGDOUBLE : ATTACH tt##[] TO a[]
			CASE $$GIANT  		: ATTACH tt$$[] TO a[]			
		END SELECT
	ELSE
		newupper = upper + nvals
		SELECT CASE type
			CASE $$SBYTE  		: REDIM t@[newupper]
			CASE $$UBYTE  		: REDIM t@@[newupper]
			CASE $$SSHORT 		: REDIM t%[newupper]
			CASE $$USHORT 		: REDIM t%%[newupper]
			CASE $$SLONG  		: REDIM t&[newupper]
			CASE $$ULONG  		: REDIM t&&[newupper]
			CASE $$XLONG			: REDIM t[newupper]
			CASE $$SINGLE 		: REDIM t![newupper]
			CASE $$DOUBLE 		: REDIM t#[newupper]
			CASE $$LONGDOUBLE : REDIM t##[newupper]
			CASE $$GIANT  		: REDIM t$$[newupper]	
		END SELECT
		
		tempindex = 0
		FOR i = upper + 1 TO newupper
			SELECT CASE type
				CASE $$SBYTE  		: t@[i]  = SBYTE(temp$[tempindex])
				CASE $$UBYTE  		: t@@[i] = UBYTE(temp$[tempindex])
				CASE $$SSHORT 		: t%[i]  = SSHORT(temp$[tempindex])
				CASE $$USHORT 		: t%%[i] = USHORT(temp$[tempindex])
				CASE $$SLONG  		: t&[i]  = SLONG(temp$[tempindex])
				CASE $$ULONG  		: t&&[i] = ULONG(temp$[tempindex])
				CASE $$XLONG  		: t[i]   = XLONG(temp$[tempindex])	
				CASE $$SINGLE 		: t![i]  = SINGLE(temp$[tempindex])
				CASE $$DOUBLE 		: t#[i]  = DOUBLE(temp$[tempindex])
				CASE $$LONGDOUBLE : t##[i] = LONGDOUBLE(temp$[tempindex])
				CASE $$GIANT  		: t$$[i] = GIANT(temp$[tempindex])
			END SELECT
			INC tempindex
		NEXT i 
		SELECT CASE type
			CASE $$SBYTE  		: ATTACH t@[] TO a[]
			CASE $$UBYTE  		: ATTACH t@@[] TO a[]
			CASE $$SSHORT 		: ATTACH t%[] TO a[]
			CASE $$USHORT 		: ATTACH t%%[] TO a[]
			CASE $$SLONG  		: ATTACH t&[] TO a[]
			CASE $$ULONG  		: ATTACH t&&[] TO a[]
			CASE $$XLONG			: ATTACH t[] TO a[]
			CASE $$SINGLE 		: ATTACH t![] TO a[]
			CASE $$DOUBLE 		: ATTACH t#[] TO a[]
			CASE $$LONGDOUBLE : ATTACH t##[] TO a[]
			CASE $$GIANT  		: ATTACH t$$[] TO a[]	
		END SELECT
	END IF

END FUNCTION
'
' ###############################
' #####  XstBuildDataArray  #####
' ###############################
'
' string$ is either a CSV string or name of a file containing CSV data
' a[] can be empty or existing
'	 If empty, an array of type is built and attached to a[]
'	 If existing, it must be same type as type parameter
'		 an array of type is built and swapped with a[]. Existing tree and data are replaced
' type is the datatype of the array a[] that is to be built / replaced e.g $$SINGLE

' 1d ARRAYS
' ---------
'  1. For new arrays, XstBuildArray() behaves just like XstLoadData() and creates / populates the array
'  2. For existing arrays, XstBuildArray() REPLACES the array whereas XstLoadData() APPENDS to it
'  3. Input to XstBuildArray() can be either a string or a file of data
'  3. XstSaveArray() can output either a string or a file in either formatted or unformatted style
'     The output can be reloaded with XstBuildArray(). A 1D array can also be loaded back with XstLoadData()
'     which can handle either formatted style

' nD ARRAYS
' ---------
'  1. For new arrays, XstBuildArray() creates and populates both regular and irregular nD arrays
'  2. For existing arrays, XstBuildArray() discards the existing tree and data and replaces it with the
'     new structure. Append is not a concept that works well when the new data supplied may have a very 
'     different tree structure and dimensions to that which exists so the option is not available
'  3. Arrays are auto-dimensioned at each level to accommodate the data supplied
'  4. XstSaveArray() can output either a string or a file in either formatted or unformatted style 
'     The ouptut can be reloaded with XstBuildArray()

FUNCTION XstBuildDataArray (a[], string$, type)

SHARED sindex, max_sindex
SHARED in$

 ' check type is handled by this routine
	SELECT CASE type
		CASE $$SBYTE, $$UBYTE, $$SSHORT, $$USHORT, $$SLONG, $$ULONG, $$XLONG, $$GIANT, $$SINGLE, $$DOUBLE, $$LONGDOUBLE:
		CASE ELSE:	RETURN $$TRUE
	END SELECT
	
 ' If array exists, check it is same type as input type
	IF a[] THEN
		header  = XLONGAT(&a[] - 4)
		this_type = (header & 0x00FF0000) >> 16
		IF this_type <> type THEN RETURN $$TRUE
	END IF

 ' string must be data or filename
	IFZ string$ THEN RETURN $$TRUE

 ' handle string$ being a filename
	IFZ INSTR(string$,",") THEN
		IF XstLoadString (string$, @in$) THEN RETURN $$TRUE
	ELSE
		in$ = string$
	END IF

 ' Get rid of whitespace and formatting
	XstStripChars(@in$," \n\r\t\b\v")

	max_sindex = LEN(in$) - 1

 ' If present, skip the optional first / last braces
	sindex = 0
	IF in${sindex} = '{' THEN 
		INC sindex
		DEC max_sindex
	END IF

IF in${sindex} = '{' THEN
 ' This is an n-D array -  requires nondata (XLONG) node at top level
	DIM outa[0,]
	'need to attach to temp because cannot have @outa[0,] in call to BuildNode()
	ATTACH outa[0,] TO temp[]
		BuildNode(@temp[],type)	'everything gets built recursively from this call

 ' If new array, ATTACH to a[], else SWAP with a[] replacing existing tree with new one
	IFZ a[]THEN
		ATTACH temp[] TO a[]
	ELSE
		SWAP temp[], a[]
	END IF
	
ELSE
 ' This is a 1-D array - can be built directly 
	data$ = ""
		DO WHILE in${sindex} <> '}' && sindex <= max_sindex
			data$ = data$ + CHR$(in${sindex})
			INC sindex
		LOOP
		
		XstParseStringToStringArray (data$, ",", @temp$[])
		upper = UBOUND(temp$[])
		
				' dimension a data node of relevant type
				SELECT CASE type
					CASE $$SBYTE			: DIM t@[upper]
					CASE $$UBYTE			: DIM t@@[upper]  
					CASE $$SSHORT			: DIM t%[upper] 
					CASE $$USHORT			: DIM t%%[upper] 
					CASE $$SLONG			: DIM t&[upper] 
					CASE $$ULONG			: DIM t&&[upper] 
					CASE $$XLONG			: DIM t[upper] 
					CASE $$GIANT			: DIM t$$[upper] 
					CASE $$SINGLE			: DIM t![upper] 
					CASE $$DOUBLE			: DIM t#[upper] 
					CASE $$LONGDOUBLE	: DIM t##[upper] 
				END SELECT
				
				' Convert input to type and store in data node	
				FOR i = 0 TO upper
					SELECT CASE type
						CASE $$SBYTE			: t@[i]  = SBYTE(temp$[i])
						CASE $$UBYTE			: t@@[i] = UBYTE(temp$[i])
						CASE $$SSHORT			: t%[i]  = SSHORT(temp$[i])
						CASE $$USHORT			: t%%[i] = USHORT(temp$[i])
						CASE $$SLONG			: t&[i]  = SLONG(temp$[i])
						CASE $$ULONG			: t&&[i] = ULONG(temp$[i])
						CASE $$XLONG			: t[i]   = XLONG(temp$[i])
						CASE $$GIANT			: t$$[i] = GIANT(temp$[i])
						CASE $$SINGLE			: t![i]  = SINGLE(temp$[i])
						CASE $$DOUBLE			: t#[i]  = DOUBLE(temp$[i])
						CASE $$LONGDOUBLE	: t##[i] = LONGDOUBLE(temp$[i]): PRINT temp$[i]
					END SELECT
				NEXT i
				
				IFZ a[] THEN
					' a[] is empty so ATTACH data node to the input array
					SELECT CASE type
						CASE $$SBYTE			: ATTACH t@[] 	TO a[]
						CASE $$UBYTE			: ATTACH t@@[] 	TO a[]
						CASE $$SSHORT			: ATTACH t%[] 	TO a[]
						CASE $$USHORT			: ATTACH t%%[] 	TO a[]
						CASE $$SLONG			: ATTACH t&[] 	TO a[]
						CASE $$ULONG			: ATTACH t&&[] 	TO a[]
						CASE $$XLONG			: ATTACH t[] 		TO a[]
						CASE $$GIANT			: ATTACH t$$[] 	TO a[]
						CASE $$SINGLE			: ATTACH t![] 	TO a[]
						CASE $$DOUBLE			: ATTACH t#[] 	TO a[]
						CASE $$LONGDOUBLE	: ATTACH t##[] 	TO a[]
					END SELECT
				ELSE
					' a[] has existing data so SWAP with a[] - replaces data in a[]
					SELECT CASE type
						CASE $$SBYTE			: SWAP t@[] 	, a[]
						CASE $$UBYTE			: SWAP t@@[] 	, a[]
						CASE $$SSHORT			: SWAP t%[] 	, a[]
						CASE $$USHORT			: SWAP t%%[]	, a[]
						CASE $$SLONG			: SWAP t&[] 	, a[]
						CASE $$ULONG			: SWAP t&&[] 	, a[]
						CASE $$XLONG			: SWAP t[] 		, a[]
						CASE $$GIANT			: SWAP t$$[]	, a[]
						CASE $$SINGLE			: SWAP t![] 	, a[]
						CASE $$DOUBLE			: SWAP t#[] 	, a[]
						CASE $$LONGDOUBLE	: SWAP t##[]	, a[]
					END SELECT
				END IF
END IF
'1D or nD array built and ATTACHed to a[] or SWAPped with a[] - FINISHED
RETURN $$FALSE
END FUNCTION
'
' ##############################
' #####  XstSaveDataArray  #####
' ##############################
'
' wrapper function that sets level and address for SaveArray()
' better user interface (use @a[] and ignore level) than using SaveArray() directly
' output$ can be a string in which case it would normally be empty, or a filename in which
' case it must have a file extension e.g outfile.txt
' if output$ is not empty and does not have a file extension, it will be overwritten
'
FUNCTION XstSaveDataArray (a[], output$, formatted)

	IFZ a[] THEN RETURN $$TRUE
	address = &a[]
	IFZ address THEN RETURN $$TRUE
	
'save to string first
	level = 0
	result$ = ""
	SaveArray (address, @result$, level, formatted)
	
'output string or file	
	IFZ INSTR(output$,".") THEN							' check for file extension	
		output$ = result$
	ELSE 	
		fnum = OPEN(output$, $$WRNEW)
		IF fnum < 3 THEN RETURN $$TRUE				' problem opening file
		WRITE [fnum], result$
		RETURN CLOSE(fnum)
	ENDIF	

END FUNCTION
'
'
' #######################
' #####  SaveArray  #####
' #######################
'
' Only used INTERNALLY with parameters that have already been validated (no edits here)
' Takes ANY array and saves it as a C style initialisation string
' result can be written to string or to a file
' if formatted = 0 (FALSE), outputs a linear string with no formatting
' if formatted <> 0 (TRUE), outputs an indented tree style string
' either string format can be input back in to BuildArray()
'
FUNCTION SaveArray (address, out$, level, formatted)

	header  = XLONGAT(address - 4)
	type 		= (header & 0x00FF0000) >> 16
	upper   = XLONGAT(address - 8) - 1						'num elements - 1
	
' set up the output formatting strings
	IF formatted THEN
		
		' set number of values to display per line based on type - more values for smaller types
		SELECT CASE type
			CASE $$SBYTE			:valuesperline = 30
			CASE $$UBYTE			:valuesperline = 30 
			CASE $$SSHORT			:valuesperline = 20 
			CASE $$USHORT			:valuesperline = 20 
			CASE $$XLONG			:valuesperline = 15 
			CASE $$SLONG			:valuesperline = 15 
			CASE $$ULONG			:valuesperline = 15
			CASE $$SINGLE			:valuesperline = 10 
			CASE $$DOUBLE			:valuesperline = 8 
			CASE $$GIANT			:valuesperline = 8 
			CASE $$LONGDOUBLE	:valuesperline = 8
			CASE ELSE					:RETURN $$TRUE
		END SELECT
		
		' indented tree structure with whitespace
		spaces$ = SPACE$(2 * level)
		newtreenode$  =  spaces$ + "{\r\n"
		nexttreenode$ =  ",\r\n"
		endtreenode$  =  "\r\n" + spaces$ + "}"	
		newdatanode$  =  spaces$ + "{ "
		nextelement$  =  ", " 
		splitdata$    =  "\r\n" + spaces$ + "  "
		enddata$      =  " }"
		
	ELSE
		' one line continuous string with no whitespace
		newtreenode$  =  "{"
		nexttreenode$ =  ","
		endtreenode$  =  "}"	
		newdatanode$  =  "{"
		nextelement$  =  ","
		splitdata$    =  "" 'empty
		enddata$      =  "}"
		
	END IF
	
	IFZ (header AND 0x20000000) THEN
		'lowest level data node so output comma separated data
		out$ = out$ + newdatanode$
		FOR i = 0 TO upper
			SELECT CASE type
				CASE $$SBYTE			:	out$ = out$ + STRING(SBYTEAT(address, [i]))
				CASE $$UBYTE			:	out$ = out$ + STRING(UBYTEAT(address, [i]))
				CASE $$SSHORT			:	out$ = out$ + STRING(SSHORTAT(address, [i]))
				CASE $$USHORT			:	out$ = out$ + STRING(USHORTAT(address, [i]))
				CASE $$XLONG			:	out$ = out$ + STRING(XLONGAT(address, [i]))
				CASE $$SLONG			:	out$ = out$ + STRING(SLONGAT(address, [i]))
				CASE $$ULONG			:	out$ = out$ + STRING(ULONGAT(address, [i]))
				CASE $$SINGLE			:	out$ = out$ + STRING(SINGLEAT(address, [i]))
				CASE $$DOUBLE			:	out$ = out$ + STRING(DOUBLEAT(address, [i]))
				CASE $$GIANT			:	out$ = out$ + STRING(GIANTAT(address, [i]))
				CASE $$LONGDOUBLE	:	out$ = out$ + STRING(LONGDOUBLEAT(address + i*12))
			END SELECT
			IF i <> upper THEN
				out$ = out$ + nextelement$
				IF formatted THEN
					' split long data strings to keep line length reasonable for viewing / editting
					IF ((i + 1) MOD valuesperline = 0) THEN out$ = out$ + splitdata$
				ENDIF
			ELSE
				out$ = out$ + enddata$
			END IF
		NEXT i

	ELSE
		out$ = out$  + newtreenode$	
		' intermediate non data node																					
		FOR i = 0 TO upper																							' step along the array of pointers and												
			SaveArray(ULONGAT(address, [i]),@out$, level + 1,formatted)		' descend the tree recursively until we hit data									
			IF i <> upper THEN
				out$ = out$ + nexttreenode$
			ELSE
				out$ = out$ + endtreenode$
			END IF
		NEXT i
		
	ENDIF
END FUNCTION
'
'
' #######################
' #####  BuildNode  #####
' #######################
'
' recursively builds the whole array
' only called INTERNALLY with already validated parameters
'
FUNCTION BuildNode (i[], type)
SHARED sindex, max_sindex
SHARED in$

DO WHILE sindex <= max_sindex

	SELECT CASE in${sindex}
		CASE '{':
			' make room for another entry in the node above
			nindex = UBOUND(i[]) + 1
			REDIM i[nindex,]
			
			INC sindex
			IF in${sindex} = '{' THEN
				' go down another level
				' non data nodes are always XLONG regardless of array type
				DIM newnode[0,]				
				ATTACH newnode[0,] TO temp[] 
				BuildNode(@temp[],type)
				ATTACH temp[] TO i[nindex,]
			ELSE
				' build a data node
				data$ = ""
				DO WHILE in${sindex} <> '}'
					data$ = data$ + CHR$(in${sindex})
					INC sindex
				LOOP
				' move on to the char after
				INC sindex
				
				XstParseStringToStringArray (data$, ",", @temp$[])
				upper = UBOUND(temp$[])
				
				' dimension a data node of relevant type
				SELECT CASE type
					CASE $$SBYTE			: DIM t@[upper]
					CASE $$UBYTE			: DIM t@@[upper]  
					CASE $$SSHORT			: DIM t%[upper] 
					CASE $$USHORT			: DIM t%%[upper] 
					CASE $$SLONG			: DIM t&[upper] 
					CASE $$ULONG			: DIM t&&[upper] 
					CASE $$XLONG			: DIM t[upper] 
					CASE $$GIANT			: DIM t$$[upper] 
					CASE $$SINGLE			: DIM t![upper] 
					CASE $$DOUBLE			: DIM t#[upper] 
					CASE $$LONGDOUBLE	: DIM t##[upper]
				END SELECT
				
				' Convert input to type and store	
				FOR i = 0 TO upper
					SELECT CASE type
						CASE $$SBYTE			: t@[i] 	= SBYTE(temp$[i])
						CASE $$UBYTE			: t@@[i] 	= UBYTE(temp$[i])
						CASE $$SSHORT			: t%[i] 	= SSHORT(temp$[i])
						CASE $$USHORT			: t%%[i] 	= USHORT(temp$[i])
						CASE $$SLONG			: t&[i] 	= SLONG(temp$[i])
						CASE $$ULONG			: t&&[i] 	= ULONG(temp$[i])
						CASE $$XLONG			: t[i] 		= XLONG(temp$[i])
						CASE $$GIANT			: t$$[i] 	= GIANT(temp$[i])
						CASE $$SINGLE			: t![i] 	= SINGLE(temp$[i])
						CASE $$DOUBLE			: t#[i] 	= DOUBLE(temp$[i])
						CASE $$LONGDOUBLE	: t##[i]	= LONGDOUBLE(temp$[i])
					END SELECT
				NEXT i
				
				' attach data node to non-data node above
				SELECT CASE type
					CASE $$SBYTE			: ATTACH t@[]  TO i[nindex,]
					CASE $$UBYTE			: ATTACH t@@[] TO i[nindex,]
					CASE $$SSHORT			: ATTACH t%[]  TO i[nindex,]
					CASE $$USHORT			: ATTACH t%%[] TO i[nindex,]
					CASE $$SLONG			: ATTACH t&[]  TO i[nindex,]
					CASE $$ULONG			: ATTACH t&&[] TO i[nindex,]
					CASE $$XLONG			: ATTACH t[]   TO i[nindex,]
					CASE $$GIANT			: ATTACH t$$[] TO i[nindex,]
					CASE $$SINGLE			: ATTACH t![]  TO i[nindex,]
					CASE $$DOUBLE			: ATTACH t#[]  TO i[nindex,]
					CASE $$LONGDOUBLE	: ATTACH t##[] TO i[nindex,]
				END SELECT

			END IF
			
		CASE '}':
			' go back up the tree
			INC sindex
			RETURN
		CASE ELSE:
			' skip other characters including commas not at data level
			INC sindex
	END SELECT
LOOP
END FUNCTION
'
'
' ##########################
' #####  ShowNodeInfo  #####
' ##########################
'
' for testing / diagnostics only for BuildDataArray(), SaveDataArray()
'
FUNCTION ShowNodeInfo (address)

IFZ address THEN
	PRINT "address = 0"
	RETURN
END IF
	header  = XLONGAT(address - 4)
	type 		= (header & 0x00FF0000) >> 16
	numels  = XLONGAT(address - 8)
	size    = header AND 0x0000FFFF
	array_low = EXTU(header,2,29) '2 = data level, 3 = non data node 
	PRINT "type = ";type, "numels = ";numels, "size = ";size, "low = ";array_low
END FUNCTION
'
'
' #######################################
' #####  XstSaveCompositeDataArray  #####
' #######################################
'
' ouput$ = empty if string required as output
'        = otherwise taken as filename to write
' check input parameters
'
FUNCTION XstSaveCompositeDataArray (a[], output$, template$, crlf, braces, errornum)


	IFZ template$ THEN
		errornum = 1: RETURN $$TRUE
	ENDIF
	
	IFZ a[] THEN
		errornum = 2: RETURN $$TRUE
	ENDIF
	
	IF crlf < 0 THEN crlf = 0      ' default no crlf
	
	IF braces <> 0 THEN
		braces = $$TRUE
	ELSE
		braces = $$FALSE
	ENDIF


#FIRST = $$TRUE
#PACKED = $$FALSE


 ' extract info from array header
	address = &a[]
	IFZ address THEN
		errornum = 3: RETURN $$TRUE
	ENDIF 
	infoword = XLONGAT(address -4)
	type = (infoword & 0x00FF0000) >> 16
	composite_size = infoword & 0x0000FFFF
	array_low = EXTU(infoword,2,29)
	upper = XLONGAT(address - 8) - 1 					' number of elements - 1  

 ' basic checks	
	IF array_low <> 2 THEN
		errornum = 4: RETURN $$TRUE 						' not lowest level or not an array
	ENDIF
	
	IF type < $$COMPOSITE THEN						  	' composites only
		errornum = 13: RETURN $$TRUE
	END IF 

 ' Make sure template$ is all uppercase
	template$ = UCASE$(template$)


 ' deparse the template string into temp array of strings
	XstParseStringToStringArray (template$, ",", @templ$[])
	maxindex = UBOUND(templ$[])
	num_components = maxindex 				                                 ' number of components to process per composite

 ' check for first element = "PACKED or "TYPE"
	SELECT CASE templ$[0]
		CASE "PACKED": #PACKED = $$TRUE
		CASE "TYPE": #PACKED = $$FALSE
		CASE ELSE: errornum = 5: RETURN $$TRUE
	END SELECT

'build arrays of type and offset for each item in the template string
	offset = 0:                                                        ' running offset
	#FIRST = $$TRUE
	DIM type[maxindex]                                                 ' type of this component
	DIM off[maxindex]                                                  ' offset for this component
	DIM strsize[maxindex]                                              ' size if component is a string
	max_align = 0                                                      ' keep track of most demanding align

FOR component = 1 TO maxindex
	SELECT CASE templ$[component]
		CASE "UBYTE"			:	type[component] = $$UBYTE			: size = SIZE(UBYTE)			: align = 1 
		CASE "SBYTE"			:	type[component] = $$SBYTE			: size = SIZE(SBYTE)			: align = 1			
		CASE "USHORT"			:	type[component] = $$USHORT		: size = SIZE(USHORT)			: align = 2			
		CASE "SSHORT"			:	type[component] = $$SSHORT		: size = SIZE(SSHORT)			: align = 2			
		CASE "GIANT"			:	type[component] = $$GIANT			: size = SIZE(GIANT)			: align = 8			
		CASE "DOUBLE"			:	type[component] = $$DOUBLE		: size = SIZE(DOUBLE)			: align = 8 			
		CASE "SINGLE"			:	type[component] = $$SINGLE		: size = SIZE(SINGLE)			: align = 4
		CASE "LONGDOUBLE"	:	type[component] = $$LONGDOUBLE: size = SIZE(LONGDOUBLE)	: align = 4		
		CASE "ULONG"			:	type[component] = $$ULONG			: size = SIZE(ULONG)			: align = 4
		CASE "SLONG"			:	type[component] = $$SLONG			: size = SIZE(SLONG)			: align = 4
		CASE "XLONG"			:	type[component] = $$XLONG			: size = SIZE(XLONG)			: align = 4
		CASE "SCOMPLEX","DCOMPLEX": errornum = 6: RETURN $$TRUE           ' should be two entries in template
		CASE ELSE: 
			locstr = INSTR(templ$[component],"STRING*")
			
			IF locstr = 1 THEN
				strlength = ULONG(LCLIP$(templ$[component],7))
				
				IF strlength <= 0 THEN RETURN $$TRUE                          ' invalid STRING* template
				type[component] = $$STRING :	size = strlength : align = 1
				strsize[component] = strlength                                ' save size for later use
				
			ELSE
				errornum = 7: RETURN $$TRUE                                   'unknown type
			END IF
	END SELECT
	IF align > max_align THEN max_align = align

	' calculate offset - for first element, leave offset at 0
	IF #FIRST THEN
		off[component] = 0
		#FIRST = $$FALSE
		offset = offset + size
	ELSE
		' for subsequent elements, advance the offset 
		IF NOT #PACKED THEN AlignOffset(@offset,align)		
		off[component] = offset
		offset = offset + size	
	END IF
NEXT component

  ' final alignment at end of composite
  ' align by 4 - or more if bigger component exists
	IF NOT #PACKED THEN
		AlignOffset(@offset,MAX(max_align,4))
	END IF

	' Make sure we have the same size as the compiler got when it created the array!
	IF composite_size <> offset THEN
		errornum = 8: RETURN $$TRUE
	END IF

' RETRIEVE AND OUTPUT DATA
' composite_index is index into the composite array
' component_index is 1,2...n for 1st, 2nd ...nth component within a composite
'								 used to index into the type[] and off[] arrays
' data_index is index into the data array dat$[]
' address = input address of 0th composite
' base    = address of nth composite = address + (composite_index * composite_size)
' location = address of component whose value is to be saved
'          = base + off[component_index]

out$ = ""
FOR composite_index = 0 TO upper
	IF braces THEN out$ = out$ + "{"
	
	base = address + (composite_index * composite_size)
	
	FOR component_index = 1 TO num_components
		location = base + off[component_index]
		SELECT CASE type[component_index]
			CASE $$UBYTE			: out$ = out$ + STRING(UBYTEAT(location))
			CASE $$SBYTE			: out$ = out$ + STRING(SBYTEAT(location))
			CASE $$USHORT			: out$ = out$ + STRING(USHORTAT(location))
			CASE $$SSHORT			: out$ = out$ + STRING(SSHORTAT(location))
			CASE $$GIANT			: out$ = out$ + STRING(GIANTAT(location))
			CASE $$DOUBLE			: out$ = out$ + STRING(DOUBLEAT(location))
			CASE $$SINGLE			: out$ = out$ + STRING(SINGLEAT(location))
			CASE $$LONGDOUBLE	: out$ = out$ + STRING(LONGDOUBLEAT(location))
			CASE $$ULONG			: out$ = out$ + STRING(ULONGAT(location))
			CASE $$SLONG			: out$ = out$ + STRING(SLONGAT(location))
			CASE $$XLONG			: out$ = out$ + STRING(XLONGAT(location))
			CASE $$STRING:
						FOR i = 0 TO strsize[component_index] - 1
							n =	UBYTEAT(location, i)
							SELECT CASE n
								CASE 0x2C: out$ = out$ + CHR$(0xFF) ' convert ","
								CASE 0x7B: out$ = out$ + CHR$(0xFE) ' convert "{"
								CASE 0x7D: out$ = out$ + CHR$(0xFD) ' convert "}"
								CASE 0x00: 													' drop trailing nulls
								CASE ELSE: out$ = out$ + CHR$(n)
							END SELECT	
						NEXT i
			CASE ELSE: errornum = 9: RETURN $$TRUE         ' should have been filtered out above
		END SELECT
		
		IF component_index <> num_components THEN
			out$ = out$ + ","
		ELSE
			IF composite_index <> upper THEN
				IF braces THEN
					out$ = out$ + "},"
				ELSE
					out$ = out$ + ","
				END IF
			ELSE
				IF braces THEN out$ = out$ + "}"
			END IF
		END IF
	NEXT component_index

	IF (composite_index <> upper) AND crlf <> 0 THEN
		IF ((composite_index + 1) MOD crlf = 0) THEN out$ = out$ + "\r\n"
	ENDIF
	
NEXT composite_index

  ' write output as string or file
	IFZ output$ THEN
		output$ = out$
	ELSE
		fnum = OPEN(output$, $$WRNEW)
		IF fnum < 3 THEN
			errornum = 10: RETURN $$TRUE					' problem opening file
		ENDIF
		WRITE [fnum], out$
		err = CLOSE (fnum)
		IF err THEN
			errornum = 11: RETURN $$TRUE					' problem closing file
		END IF
	END IF
	
  ' finished OK	
	errornum = 0: RETURN 0

END FUNCTION


FUNCTION XstLoadCompositeDataArray (a[], input$, template$, errornum)

IFZ input$ THEN
	errornum = 15: RETURN $$TRUE
END IF
IFZ template$ THEN
	errornum = 1: RETURN $$TRUE
END IF
IFZ a[] THEN
	errornum = 2: RETURN $$TRUE
END IF
	' check for balanced braces or no braces
	IF XstTally(input$,"{") <> XstTally(input$,"}") THEN
		errornum = 12: RETURN $$TRUE
	ENDIF

	' handle input$ being a filename
	IFZ INSTR(input$,",") THEN
		IF XstLoadString (input$, @data$) THEN
			errornum = 10: RETURN $$TRUE
		END IF
	ELSE
		data$ = input$
	END IF	

#FIRST = $$TRUE
#PACKED = $$FALSE

	' extract info from array header
	address = &a[]
	infoword = XLONGAT(address -4)
	type = (infoword & 0x00FF0000) >> 16
	composite_size = infoword & 0x0000FFFF
	array_low = EXTU(infoword,2,29)
	
	' basic checks	
	IF array_low <> 2 THEN
		errornum = 4: RETURN $$TRUE   	'lowest level and not string
	ENDIF
	
	IF type < $$COMPOSITE THEN			  'composites only
		errornum = 13: RETURN $$TRUE
	END IF 
	
  ' Make sure template$ is all uppercase
	template$ = UCASE$(template$)

  ' remove braces from data string to leave CSV
	XstStripChars(@data$, "{}")

  ' deparse the template string into temp array of strings
	XstParseStringToStringArray (template$, ",", @templ$[])
	maxindex = UBOUND(templ$[])
	num_components = maxindex 				  'number of components to process per composite

  ' check for first element in template string = "PACKED or "TYPE"
	SELECT CASE templ$[0]
		CASE "PACKED": #PACKED = $$TRUE
		CASE "TYPE": #PACKED = $$FALSE
		CASE ELSE: errornum = 5: RETURN $$TRUE
	END SELECT

  ' build arrays of type and offset for each item in the template string
	offset = 0:                                                        'running offset
	#FIRST = $$TRUE
	DIM type[maxindex]                                                 'type of this component
	DIM off[maxindex]                                                  'offset for this component
	DIM strsize[maxindex]                                              'size if component is a string
	max_align = 0                                                      'keep track of most demanding align
FOR i = 1 TO maxindex
	SELECT CASE templ$[i]
		CASE "UBYTE"			:	type[i] = $$UBYTE			: size = SIZE(UBYTE)			: align = 1 
		CASE "SBYTE"			:	type[i] = $$SBYTE			: size = SIZE(SBYTE)			: align = 1			
		CASE "USHORT"			:	type[i] = $$USHORT		: size = SIZE(USHORT)			: align = 2			
		CASE "SSHORT"			:	type[i] = $$SSHORT		: size = SIZE(SSHORT)			: align = 2			
		CASE "GIANT"			:	type[i] = $$GIANT			: size = SIZE(GIANT)			: align = 8			
		CASE "DOUBLE"			:	type[i] = $$DOUBLE		: size = SIZE(DOUBLE)			: align = 8 			
		CASE "SINGLE"			:	type[i] = $$SINGLE		: size = SIZE(SINGLE)			: align = 4
		CASE "LONGDOUBLE"	:	type[i] = $$LONGDOUBLE: size = SIZE(LONGDOUBLE)	: align = 4		
		CASE "ULONG"			:	type[i] = $$ULONG			: size = SIZE(ULONG)			: align = 4
		CASE "SLONG"			:	type[i] = $$SLONG			: size = SIZE(SLONG)			: align = 4
		CASE "XLONG"			:	type[i] = $$XLONG			: size = SIZE(XLONG)			: align = 4
		CASE "SCOMPLEX","DCOMPLEX": errornum = 6: RETURN $$TRUE   'should be two entries
		CASE ELSE: 
			locstr = INSTR(templ$[i],"STRING*")
			
			IF locstr = 1 THEN
				strlength = ULONG(LCLIP$(templ$[i],7))
				
				IF strlength <= 0 THEN
					errornum = 14: RETURN $$TRUE                        'invalid STRING* template
				ENDIF
				type[i] = $$STRING :	size = strlength : align = 1
				strsize[i] = strlength                                'save size for load phase
				
			ELSE
				errornum = 9: RETURN $$TRUE                           'unknown type'
			END IF
	END SELECT
  ' Calculate the offset
	IF align > max_align THEN max_align = align
	IF #FIRST THEN
		off[i] = 0
		#FIRST = $$FALSE
		offset = offset + size
	ELSE
		' for subsequent elements, advance the offset 
		IF NOT #PACKED THEN AlignOffset(@offset,align)		
		off[i] = offset
		offset = offset + size	
	END IF
	NEXT i

	' final alignment at end of composite
	' align by 4 - or more if bigger component exists
	IF NOT #PACKED THEN
		AlignOffset (@offset, MAX (max_align, 4))
	END IF


'Make sure we have the same size as the compiler got when it created the array!
	IF composite_size <> offset THEN
		errornum = 8: RETURN $$TRUE
	END IF

	' deparse the data string into array of data strings
	XstParseStringToStringArray (data$, ",", @dat$[])
	num_data = UBOUND(dat$[]) + 1

	' check number of data values supplied is multiple of number of components in the composite
	' and see how many composites are in the data string / array
	IF num_data MOD num_components <> 0 THEN
		errornum = 15: RETURN $$TRUE
	END IF
	composites_to_load = num_data \ num_components
	
	' Dimension the array to hold this data. This is done as late as possible so that the input array is not
	' altered before we are (fairly) sure the load will work 
	REDIM a[composites_to_load - 1]
	' redo the address in case REDIM moves the array to a new location
	address = &a[]

' POPULATE THE DATA
' composite_index is index into the composite array
' component_index is 1,2...n for 1st, 2nd ...nth component within a composite
'								 used to index into the type[] and off[] arrays
' data_index is index into the data array dat$[]
' address  = address of array to populate AFTER redimensioning
' base     = address of nth composite = address + (composite_index * composite_size)
' location = address of component where value is to be inserted
'          = base + off[component_index]

data_index = 0
FOR composite_index = 0 TO composites_to_load - 1
	base = address + (composite_index * composite_size)
	FOR component_index = 1 TO num_components
		location = base + off[component_index]
		SELECT CASE type[component_index]
			CASE $$UBYTE			: UBYTEAT(location) = UBYTE(dat$[data_index])
			CASE $$SBYTE			: SBYTEAT(location) = SBYTE(dat$[data_index])
			CASE $$USHORT			: USHORTAT(location) = USHORT(dat$[data_index])
			CASE $$SSHORT			: SSHORTAT(location) = SSHORT(dat$[data_index])
			CASE $$GIANT			: GIANTAT(location) = GIANT(dat$[data_index])
			CASE $$DOUBLE			: DOUBLEAT(location) = DOUBLE(dat$[data_index])
			CASE $$SINGLE			: SINGLEAT(location) = SINGLE(dat$[data_index])
			CASE $$LONGDOUBLE	: LONGDOUBLEAT(location) = LONGDOUBLE(dat$[data_index])
			CASE $$ULONG			: ULONGAT(location) = ULONG(dat$[data_index])
			CASE $$SLONG			: SLONGAT(location) = SLONG(dat$[data_index])
			CASE $$XLONG			: XLONGAT(location) = XLONG(dat$[data_index])
			CASE $$STRING:
					'first, fill the string with NULLS					
					FOR i = 0 TO strsize[component_index] - 1
						UBYTEAT(location, i) = 0
					NEXT i
					'then, overwrite with data string if this is not empty 
					IF LEN(dat$[data_index]) > 0 THEN
						temp$ = LEFT$(dat$[data_index],strsize[component_index]) 'clip string to fit if too big
						FOR i = 0 TO LEN(temp$) - 1
							n =	UBYTE(ASC(temp$,i + 1))
							'Change special characters back to ',' or '{' or '}'
							SELECT CASE n
								CASE 0xFF: n = 0x2C		' ","
								CASE 0xFE: n = 0x7B   ' "{" 
								CASE 0xFD: n = 0x7D   ' "}"
							END SELECT							
							UBYTEAT(location, i) = n
						NEXT i
					END IF
			CASE ELSE: errornum = 9: RETURN $$TRUE          
		END SELECT
		INC data_index
	NEXT component_index
NEXT composite_index

	' finished OK
	errornum = 0: RETURN 0 

END FUNCTION
 
FUNCTION AlignOffset (offset, align)
	IF align < 2 THEN RETURN			  'avoid negatives, divide by zero (0) and nothing to do (1)
	rem = offset MOD align
	IF rem = 0 THEN RETURN 					'already aligned
	offset = offset + align - rem 	'align offset
END FUNCTION

END PROGRAM
