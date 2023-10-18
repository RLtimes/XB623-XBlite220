'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Linux XBasic standard function library
'
' subject to LGPL license - see COPYING_LIB
'
' maxreason@maxreason.com
'
' for Linux XBasic
'
'
PROGRAM "xst"
VERSION "0.0228"
'
IMPORT  "xma"
IMPORT  "xgr"
IMPORT  "xui"
IMPORT  "clib"
IMPORT  "xlib"
IMPORT  "kernel32"
IMPORT	"xut"
'
EXPORT
'
' **********************************************
' *****  Standard Library Composite Types  *****
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
TYPE MEMORYMAP
  XLONG        .code0
  XLONG        .code
  XLONG        .codex
  XLONG        .codez
  XLONG        .data0
  XLONG        .data
  XLONG        .datax
  XLONG        .dataz
  XLONG        .bss0
  XLONG        .bss
  XLONG        .bssx
  XLONG        .bssz
  XLONG        .dyno0
  XLONG        .dyno
  XLONG        .dynox
  XLONG        .dynoz
  XLONG        .ucode0
  XLONG        .ucode
  XLONG        .ucodex
  XLONG        .ucodez
  XLONG        .stack0
  XLONG        .stack
  XLONG        .stackx
  XLONG        .stackz
END TYPE
END EXPORT
'
TYPE TIMER
  XLONG        .timer      ' timer #
  XLONG        .count      ' desired number of timeouts
  XLONG        .func       ' function to call whenever this timer expires
  XLONG        .msec       ' millisecond interval of this timer
  XLONG        .sec        ' expected expire time seconds (from ftime())
  XLONG        .usec       ' expected expire time microseconds (ditto)
  XLONG        .active     ' system interval timer is currently counting this timer
  XLONG        .whomask    ' whomask of timer owner
END TYPE
'
TYPE FILE
  STRING*112   .fileName
  XLONG        .fileHandle
  XLONG        .whomask
  XLONG        .consoleGrid
  XLONG        .entries
END TYPE
'
TYPE LOCK
  XLONG        .file
  XLONG        .sfile
  GIANT        .offset
  GIANT        .length
  GIANT        .end
END TYPE
'
EXPORT
'
'
'  ****************************************
'  *****  Standard Library Functions  *****
'  ****************************************
'
'  system functions
'
DECLARE FUNCTION  Xst                            ()
DECLARE FUNCTION  XstVersion$                    ()
DECLARE FUNCTION  XstCauseException              (exception)
DECLARE FUNCTION  XstCloseLibrary                (handle)
DECLARE FUNCTION  XstDateAndTimeToFileTime       (year, month, day, weekDay, hour, minute, second, nanos, @filetime$$)
DECLARE FUNCTION  XstErrorNameToNumber           (error$, @error)
DECLARE FUNCTION  XstErrorNumberToName           (error, @error$)
DECLARE FUNCTION  XstExceptionNumberToName       (exception, @exception$)
DECLARE FUNCTION  XstExceptionToSystemException  (exception, @sysException)
DECLARE FUNCTION  XstFileTimeToDateAndTime       (filetime$$, @year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
DECLARE FUNCTION  XstFileToSystemFile            (fileNumber, @systemFileNumber)
DECLARE FUNCTION  XstGetApplicationEnvironment   (@standalone, @reserved)
DECLARE FUNCTION  XstGetCommandLine              (@commandline$)
DECLARE FUNCTION  XstGetCommandLineArguments     (@argc, @argv$[])
DECLARE FUNCTION  XstGetConsoleGrid              (@grid)
DECLARE FUNCTION  XstGetCPUName                  (@cpu$)
DECLARE FUNCTION  XstGetDateAndTime              (@year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
DECLARE FUNCTION  XstGetLocalDateAndTime         (@year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
DECLARE FUNCTION  XstGetEndian                   (@endian$$)
DECLARE FUNCTION  XstGetEndianName               (@endian$)
DECLARE FUNCTION  XstGetEnvironmentVariable      (@name$, @value$)
DECLARE FUNCTION  XstGetEnvironmentVariables     (@count, @envp$[])
DECLARE FUNCTION  XstGetException                (@exception)
DECLARE FUNCTION  XstGetExceptionFunction        (@function)
DECLARE FUNCTION  XstGetImplementation           (@name$)
DECLARE FUNCTION  XstGetLibraryAddress           (handle, funcname$)
DECLARE FUNCTION  XstGetMemoryMap                (MEMORYMAP @memorymap)
DECLARE FUNCTION  XstGetNewline                  (@save, @paste)
DECLARE FUNCTION  XstGetOSName                   (@name$)
DECLARE FUNCTION  XstGetOSVersion                (@major, @minor)
DECLARE FUNCTION  XstGetOSVersionName            (@name$)
DECLARE FUNCTION  XstGetPrintTab                 (@pixels)
DECLARE FUNCTION  XstGetProgramName              (@program$)
DECLARE FUNCTION  XstGetSystemError              (@sysError)
DECLARE FUNCTION  XstGetSystemTime               (@msec)
DECLARE FUNCTION  XstKillTimer                   (timer)
DECLARE FUNCTION  XstLog                         (text$)
DECLARE FUNCTION  XstOpenLibrary                 (name$)
DECLARE FUNCTION  XstSetCommandLineArguments     (argc, @argv$[])
DECLARE FUNCTION  XstSetDateAndTime              (year, month, day, weekDay, hour, minute, second, nanos)
DECLARE FUNCTION  XstSetEnvironmentVariable      (@name$, @value$)
DECLARE FUNCTION  XstSetException                (exception)
DECLARE FUNCTION  XstSetExceptionFunction        (function)
DECLARE FUNCTION  XstSetNewline                  (save, paste)
DECLARE FUNCTION  XstSetPrintTab                 (pixels)
DECLARE FUNCTION  XstSetProgramName              (@program$)
DECLARE FUNCTION  XstSetSystemError              (sysError)
DECLARE FUNCTION  XstSleep                       (milliSec)
DECLARE FUNCTION  XstStartTimer                  (timer, count, msec, func)
DECLARE FUNCTION  XstSystemErrorToError          (sysError, @error)
DECLARE FUNCTION  XstSystemErrorNumberToName     (sysError, @sysError$)
DECLARE FUNCTION  XstSystemExceptionNumberToName (sysException, @sysException$)
DECLARE FUNCTION  XstSystemExceptionToException  (sysException, @exception)
'
' console functions
'
DECLARE FUNCTION  XstClearConsole                ()
DECLARE FUNCTION  XstDisplayConsole              ()
DECLARE FUNCTION  XstHideConsole                 ()
DECLARE FUNCTION  XstShowConsole                 ()
'
'  file functions
'
DECLARE FUNCTION  XstBinRead                     (fileNumber, bufferAddr, maxBytes)
DECLARE FUNCTION  XstBinWrite                    (fileNumber, bufferAddr, numBytes)
DECLARE FUNCTION  XstChangeDirectory             (directory$)
DECLARE FUNCTION  XstCopyDirectory               (source$, dest$)
DECLARE FUNCTION  XstCopyFile                    (source$, dest$)
DECLARE FUNCTION  XstDecomposePathname           (pathname$, path$, parent$, filename$, file$, extent$)
DECLARE FUNCTION  XstDeleteFile                  (file$)
DECLARE FUNCTION  XstFindFile                    (file$, @path$[], @path$, @attr)
DECLARE FUNCTION  XstFindFiles                   (basepath$, filter$, recurse, @file$[])
DECLARE FUNCTION  XstGetCurrentDirectory         (@directory$)
DECLARE FUNCTION  XstGetDrives                   (@count, @drive$[], @driveType[], @driveType$[])
DECLARE FUNCTION  XstGetExecutionPathArray       (@path$[])
DECLARE FUNCTION  XstGetFileAttributes           (file$, @attributes)
DECLARE FUNCTION  XstGetFiles                    (filter$, @file$[])
DECLARE FUNCTION  XstGetFilesAndAttributes       (filter$, attributeFilter, @file$[], FILEINFO @fileInfo[])
DECLARE FUNCTION  XstGetPathComponents           (file$, @path$, @drive$, @dir$, @filename$, @attributes)
DECLARE FUNCTION  XstGuessFilename               (old$, new$, @guess$, @attributes)
DECLARE FUNCTION  XstLoadString                  (file$, @text$)
DECLARE FUNCTION  XstLoadStringArray             (file$, @text$[])
DECLARE FUNCTION  XstLockFileSection             (fileNumber, mode, offset$$, length$$)
DECLARE FUNCTION  XstMakeDirectory               (directory$)
DECLARE FUNCTION  XstPathString$                 (path$)
DECLARE FUNCTION  XstPathToAbsolutePath          (ipath$, @opath$)
DECLARE FUNCTION  XstReadString                  (ifile, @string$)
DECLARE FUNCTION  XstRenameFile                  (old$, new$)
DECLARE FUNCTION  XstSaveString                  (file$, text$)
DECLARE FUNCTION  XstSaveStringArray             (file$, text$[])
DECLARE FUNCTION  XstSaveStringArrayCRLF         (file$, text$[])
DECLARE FUNCTION  XstSetCurrentDirectory         (directory$)
DECLARE FUNCTION  XstUnlockFileSection           (fileNumber, mode, offset$$, length$$)
DECLARE FUNCTION  XstWriteString                 (ofile, @string$)
'
'  string and string array functions
'
DECLARE FUNCTION  XstBackArrayToBinArray         (backArray$[], @binArray$[])
DECLARE FUNCTION  XstBackStringToBinString$      (backString$)
DECLARE FUNCTION  XstBinArrayToBackArray         (binArray$[], @backArray$[])
DECLARE FUNCTION  XstBinStringToBackString$      (binString$)
DECLARE FUNCTION  XstBinStringToBackStringNL$    (binString$)
DECLARE FUNCTION  XstBinStringToBackStringThese$ (binString$, these[])
DECLARE FUNCTION  XstCopyArray                   (ANY[], ANY[])
DECLARE FUNCTION  XstCopyMemory                  (sourceAddr, destAddr, bytes)
DECLARE FUNCTION  XstDeleteLines                 (array$[], start, count)
DECLARE FUNCTION  XstFindArray                   (mode, text$[], find$, line, pos, match)
DECLARE FUNCTION  XstIsDataDimension             (ANY[])
DECLARE FUNCTION  XstMergeStrings$               (string$, add$, start, replace)
DECLARE FUNCTION  XstMultiStringToStringArray    (s$, @s$[])
DECLARE FUNCTION  XstNextCField$                 (sourceAddr, @index, @done)
DECLARE FUNCTION  XstNextCLine$                  (sourceAddr, @index, @done)
DECLARE FUNCTION  XstNextField$                  (source$, @index, @done)
DECLARE FUNCTION  XstNextItem$                   (source$, @index, @term, @done)
DECLARE FUNCTION  XstNextLine$                   (source$, @index, @done)
DECLARE FUNCTION  XstReplaceArray                (mode, text$[], find$, replace$, line, pos, match)
DECLARE FUNCTION  XstReplaceLines                (d$[], s$[], firstD, countD, firstS, countS)
DECLARE FUNCTION  XstStringArraySectionToString  (text$[], @copy$, x1, y1, x2, y2, term)
DECLARE FUNCTION  XstStringArraySectionToStringArray (text$[], @copy$[], x1, y1, x2, y2)
DECLARE FUNCTION  XstStringArrayToString         (s$[], @s$)
DECLARE FUNCTION  XstStringArrayToStringCRLF     (s$[], @s$)
DECLARE FUNCTION  XstStringToStringArray         (s$, @s$[])
DECLARE FUNCTION  XstLTRIM                       (@string$, array[])
DECLARE FUNCTION  XstRTRIM                       (@string$, array[])
DECLARE FUNCTION  XstTRIM                        (@string$, array[])
'
EXTERNAL FUNCTION  XstFindMemoryMatch            (addrBufferStart, addrBufferPast, addrMatchString, minMatchLength, maxMatchLength)
EXTERNAL FUNCTION  XstStringToNumber             (s$, startOff, @afterOff, @rtype, @value$$)
'
'  sorting functions
'
DECLARE FUNCTION  XstCompareStrings              (addrString1, op, addrString2, flags)
DECLARE FUNCTION  XstQuickSort                   (ANY x[], n[], low, high, flags)
'
DECLARE FUNCTION	XstAbend											 (errorMessage$)
DECLARE FUNCTION  XstAlert                       (message$)
DECLARE FUNCTION  XstGetProgramFileName$         ()
'
END EXPORT
'
' functions the PDE calls
'
DECLARE FUNCTION  XxxXstBlowback                 ()
DECLARE FUNCTION  XxxXstFreeLibrary              (libname$, handle)
DECLARE FUNCTION  XxxXstLoadLibrary              (libname$)
DECLARE FUNCTION  XxxXstTimer                    (command, timer, count, msec, func)
DECLARE FUNCTION  XxxXstLog                      (text$)
'
' internal functions
'
INTERNAL FUNCTION  InitProgram                   ()
INTERNAL FUNCTION  WakeupNobody                  (timer, count, msec, time)
INTERNAL FUNCTION  WakeupSystem                  (timer, count, msec, time)
INTERNAL FUNCTION  WakeupUser                    (timer, count, msec, time)
INTERNAL FUNCTION  XstQuickSort_XLONG            (x[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_GIANT            (x$$[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_DOUBLE           (x#[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_STRING           (x$[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_STRING_nocase    (x$[], n[], low, high, flags)
INTERNAL FUNCTION  XstQuickSort_NumericSTRING    (x$[], n[], low, high, flags)
'
DECLARE  FUNCTION  Xio                ()
DECLARE  FUNCTION  XxxClose           (fileNumber)
DECLARE  FUNCTION  XxxCloseAllUser    ()
DECLARE  FUNCTION  XxxEof             (fileNumber)
DECLARE  FUNCTION  XxxInfile$         (fileNumber)
DECLARE  FUNCTION  XxxInline$         (prompt$)
DECLARE  FUNCTION  XxxLof             (fileNumber)
DECLARE  FUNCTION  XxxOpen            (fileName$, openMode)
DECLARE  FUNCTION  XxxPof             (fileNumber)
DECLARE  FUNCTION  XxxQuit            (status)
DECLARE  FUNCTION  XxxReadFile        (fileNumber, buffer, bytes, bytesRead, overlapped)
DECLARE  FUNCTION  XxxSeek            (fileNumber, position)
DECLARE  FUNCTION  XxxShell           (command$)
DECLARE  FUNCTION  XxxStdio           (stdin, stdout, stderr)
DECLARE  FUNCTION  XxxWriteFile       (fileNumber, buffer, bytes, bytesWritten, overlapped)
DECLARE  FUNCTION  XxxFormat$         (format$, argType, arg$$)
DECLARE  FUNCTION  CreateConsole      ()
'
INTERNAL FUNCTION  DeltaTimeZone      (@delta)
INTERNAL FUNCTION  InitGui            ()
INTERNAL FUNCTION  InvalidFileNumber  (fileNumber)
INTERNAL FUNCTION  ValidFormat        (format$, offset)
INTERNAL FUNCTION  ValidFmt           (format$, offset)
'
' xlib function in Windows version
'
INTERNAL FUNCTION  XxxTerminate          ()
INTERNAL FUNCTION  XxxGuessFilename      (old$, new$, @guess$, @attributes)
INTERNAL FUNCTION  XxxPathString$        (path$)
'
' GraphicsDesigner functions
'
EXTERNAL FUNCTION  XxxCheckMessages      ()
EXTERNAL FUNCTION  XxxXgrQuit            ()
'
' Xit functions
'
EXTERNAL FUNCTION  XxxSetBlowback        ()
EXTERNAL FUNCTION  XxxXitExit            (status)
'
' compiler functions
'
EXTERNAL FUNCTION  XxxGetImplementation  (name$)
'
EXPORT
'
'
' ****************************************
' *****  Standard Library Constants  *****
' ****************************************
'
' Line Separator argument in XstStringArraySectionToString()
'
  $$NOTERM              =  0        ' no line terminator
  $$LF                  =  1        ' \n
  $$NL                  =  1        ' \n
  $$CRLF                =  2        ' \r\n
'
' for XstGetNewline() and XstSetNewline()
'
  $$NewlineLF           =  1
  $$NewlineNL           =  1
  $$NewlineCRLF         =  2
  $$NewlineDefault      =  1
  $$Newline$            = "\n"
'
' path slash characters (different for DOS/Windows vs UNIX)
'
' $$PathSlash$          = "\\"          ' Windows
' $$PathSlash           = '\\'          ' Windows
  $$PathSlash$          = "/"           ' UNIX
  $$PathSlash           = '/'           ' UNIX
'
' Drive types returned by XstGetDrives (@count, @drive$[], @driveType[], @driveType$[])
'
  $$DriveTypeUnknown    =  0            ' "Unknown"
  $$DriveTypeDamaged    =  1            ' "Damaged"
  $$DriveTypeRemovable  =  2            ' "Removable"
  $$DriveTypeFixed      =  3            ' "Fixed"
  $$DriveTypeRemote     =  4            ' "Remote"
  $$DriveTypeCDROM      =  5            ' "CDROM"
  $$DriveTypeRamDisk    =  6            ' "RamDisk"
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
  $$FileNormal          = 0x0080        ' no other bits should be set
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
' *****  Sort Constants  *****  OR these flags together
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
' ********************************
' *****  File I/O Constants  *****  (see OPEN() intrinsic)
' ********************************
'
  $$RD                  = 0x0000    '
  $$WR                  = 0x0001    '
  $$RW                  = 0x0002    '
  $$WRNEW               = 0x0003    '
  $$RWNEW               = 0x0004    '
  $$NOSHARE             = 0x0000    ' share file for none
  $$RDSHARE             = 0x0010    ' share file for read
  $$WRSHARE             = 0x0020    ' share file for write
  $$RWSHARE             = 0x0030    ' share file for read & write
  $$ALL                 = -1        ' CLOSE ($$ALL)
'
' ********************************
' *****  Language Constants  *****  I/O, Kinds, DataTypes, Scope, etc...
' ********************************
'
  $$ZERO                =  0
  $$ONE                 =  1
  $$ENDIAN              =  0
  $$STDIN               =  0
  $$STDOUT              =  1
  $$STDERR              =  2
  $$VOID                =  1
  $$SBYTE               =  2
  $$UBYTE               =  3
  $$SSHORT              =  4
  $$USHORT              =  5
  $$SLONG               =  6
  $$ULONG               =  7
  $$XLONG               =  8
  $$GOADDR              =  9
  $$SUBADDR             = 10
  $$FUNCADDR            = 11
  $$GIANT               = 12
  $$SINGLE              = 13
  $$DOUBLE              = 14
  $$ARRAY               = 16
  $$ANY                 = 16
  $$ETC                 = 17
  $$VARARG              = 18
  $$STRING              = 19
  $$COMPOSITE           = 31
  $$SCOMPLEX            = 32
  $$DCOMPLEX            = 33
  $$AUTO                =  0
  $$AUTOX               =  1
  $$STATIC              =  2
  $$SHARED              =  3
  $$EXTERNAL            =  4
  $$ARGUMENT            =  7
'
'
' **********************************
' *****  Native Error Numbers  *****
' **********************************
'
' "Native Error Numbers" are USHORT values composed of two parts:
'    1. ErrorObject in upper byte - object associated with error
'    2. ErrorNature in lower byte - nature of action or error
'
  $$ErrorObjectNone                =  0    ' or unknown
  $$ErrorObjectData                =  1
  $$ErrorObjectDisk                =  2
  $$ErrorObjectFile                =  3
  $$ErrorObjectFont                =  4
  $$ErrorObjectGrid                =  5
  $$ErrorObjectIcon                =  6
  $$ErrorObjectName                =  7
  $$ErrorObjectNode                =  8
  $$ErrorObjectPipe                =  9
  $$ErrorObjectUser                = 10
  $$ErrorObjectArray               = 11
  $$ErrorObjectImage               = 12
  $$ErrorObjectMedia               = 13
  $$ErrorObjectQueue               = 14
  $$ErrorObjectStack               = 15
  $$ErrorObjectTimer               = 16
  $$ErrorObjectBuffer              = 17
  $$ErrorObjectCursor              = 18
  $$ErrorObjectDevice              = 19
  $$ErrorObjectDriver              = 20
  $$ErrorObjectMemory              = 21
  $$ErrorObjectSocket              = 22
  $$ErrorObjectString              = 23
  $$ErrorObjectSystem              = 24
  $$ErrorObjectThread              = 25
  $$ErrorObjectWindow              = 26
  $$ErrorObjectCommand             = 27
  $$ErrorObjectDisplay             = 28
  $$ErrorObjectLibrary             = 29
  $$ErrorObjectMessage             = 30
  $$ErrorObjectNetwork             = 31
  $$ErrorObjectPrinter             = 32
  $$ErrorObjectProcess             = 33
  $$ErrorObjectProgram             = 34
  $$ErrorObjectArgument            = 35
  $$ErrorObjectComputer            = 36
  $$ErrorObjectFunction            = 37
  $$ErrorObjectIdentity            = 38
  $$ErrorObjectPassword            = 39
  $$ErrorObjectClipboard           = 40
  $$ErrorObjectDirectory           = 41
  $$ErrorObjectSemaphore           = 42
  $$ErrorObjectStatement           = 43
  $$ErrorObjectSystemRoutine       = 44
  $$ErrorObjectSystemFunction      = 45
  $$ErrorObjectSystemResource      = 46
  $$ErrorObjectOperatingSystem     = 47
  $$ErrorObjectIntegerLogicUnit    = 48
  $$ErrorObjectFloatingPointUnit   = 49
'
  $$ErrorNatureNone                =  0
  $$ErrorNatureBusy                =  1
  $$ErrorNatureFull                =  2
  $$ErrorNatureError               =  3
  $$ErrorNatureEmpty               =  4
  $$ErrorNatureReset               =  5
  $$ErrorNatureExists              =  6
  $$ErrorNatureFailed              =  7
  $$ErrorNatureHalted              =  8
  $$ErrorNatureExpired             =  9
  $$ErrorNatureInvalid             = 10
  $$ErrorNatureMissing             = 11
  $$ErrorNatureTimeout             = 12
  $$ErrorNatureTooMany             = 13
  $$ErrorNatureUnknown             = 14
  $$ErrorNatureBreakKey            = 15
  $$ErrorNatureDeadlock            = 16
  $$ErrorNatureDisabled            = 17
  $$ErrorNatureNotEmpty            = 18
  $$ErrorNatureObsolete            = 19
  $$ErrorNatureOverflow            = 20
  $$ErrorNatureTooLarge            = 21
  $$ErrorNatureTooSmall            = 22
  $$ErrorNatureAbandoned           = 23
  $$ErrorNatureAvailable           = 24
  $$ErrorNatureDuplicate           = 25
  $$ErrorNatureExhausted           = 26
  $$ErrorNaturePrivilege           = 27
  $$ErrorNatureUndefined           = 28
  $$ErrorNatureUnderflow           = 29
  $$ErrorNatureAllocation          = 30
  $$ErrorNatureBreakpoint          = 31
  $$ErrorNatureContention          = 32
  $$ErrorNaturePermission          = 33
  $$ErrorNatureTerminated          = 34
  $$ErrorNatureUndeclared          = 35
  $$ErrorNatureUnexpected          = 36
  $$ErrorNatureWouldBlock          = 37
  $$ErrorNatureInterrupted         = 38
  $$ErrorNatureMalfunction         = 39
  $$ErrorNatureNonexistent         = 40
  $$ErrorNatureUnavailable         = 41
  $$ErrorNatureUnspecified         = 42
  $$ErrorNatureDisconnected        = 43
  $$ErrorNatureDivideByZero        = 44
  $$ErrorNatureIncompatible        = 45
  $$ErrorNatureNotConnected        = 46
  $$ErrorNatureLimitExceeded       = 47
  $$ErrorNatureNotInitialized      = 48
  $$ErrorNatureHigherDimension     = 49
  $$ErrorNatureLowestDimension     = 50
  $$ErrorNatureCannotInitialize    = 51
  $$ErrorNatureInitializeFailed    = 52
  $$ErrorNatureAlreadyInitialized  = 53
  $$ErrorNatureInvalidAccess       = 54
  $$ErrorNatureInvalidAddress      = 55
  $$ErrorNatureInvalidAlignment    = 56
  $$ErrorNatureInvalidArgument     = 57
  $$ErrorNatureInvalidCheck        = 58
  $$ErrorNatureInvalidCoordinates  = 59
  $$ErrorNatureInvalidCommand      = 60
  $$ErrorNatureInvalidData         = 61
  $$ErrorNatureInvalidDimension    = 62
  $$ErrorNatureInvalidEntry        = 63
  $$ErrorNatureInvalidFormat       = 64
  $$ErrorNatureInvalidKind         = 65
  $$ErrorNatureInvalidIdentity     = 66
  $$ErrorNatureInvalidInstruction  = 67
  $$ErrorNatureInvalidLocation     = 68
	$$ErrorNatureInvalidMessage      = 69
  $$ErrorNatureInvalidName         = 70
  $$ErrorNatureInvalidNode         = 71
  $$ErrorNatureInvalidNumber       = 72
  $$ErrorNatureInvalidOperand      = 73
  $$ErrorNatureInvalidOperation    = 74
  $$ErrorNatureInvalidReply        = 75
  $$ErrorNatureInvalidRequest      = 76
  $$ErrorNatureInvalidResult       = 77
  $$ErrorNatureInvalidSelection    = 78
  $$ErrorNatureInvalidSignature    = 79
  $$ErrorNatureInvalidSize         = 80
  $$ErrorNatureInvalidType         = 81
  $$ErrorNatureInvalidValue        = 82
  $$ErrorNatureInvalidVersion      = 83
	$$ErrorNatureInvalidDistribution = 84
'
' ****************************************
' *****  Native Exception Constants  *****
' ****************************************
'
  $$ExceptionNone                 =  0
  $$ExceptionSegmentViolation     =  1
  $$ExceptionOutOfBounds          =  2
  $$ExceptionBreakpoint           =  3
  $$ExceptionBreakKey             =  4
  $$ExceptionAlignment            =  5
  $$ExceptionDenormal             =  6
  $$ExceptionDivideByZero         =  7
  $$ExceptionInvalidOperation     =  8
  $$ExceptionOverflow             =  9
  $$ExceptionStackCheck           = 10
  $$ExceptionUnderflow            = 11
  $$ExceptionInvalidInstruction   = 12
  $$ExceptionPrivilege            = 13
  $$ExceptionStackOverflow        = 14
  $$ExceptionReserved             = 15
  $$ExceptionTimer                = 16
  $$ExceptionUnknown              = 17
  $$ExceptionUpper                = 31
'
  $$ExceptionTerminate            =  0    ' native
  $$ExceptionContinue             = -1    ' native
'
' to log or print debug information OR these bits into ##DEBUG
'
  $$DebugNone                     = 0x00000000
  $$DebugToConsole                = 0x00000001
  $$DebugToWindow                 = 0x00000002
  $$DebugToFile                   = 0x00000004
  $$DebugTimer                    = 0x00000008
  $$DebugSignal                   = 0x00000010
  $$DebugXstSleep                 = 0x00000020
  $$DebugDispatchEvents           = 0x00000040
  $$DebugXgrProcessMessages       = 0x00000080
END EXPORT
'
' timer command argument to XxxXstTimer()
'
  $$TimerStart                    = 1
  $$TimerExpire                   = 2
  $$TimerKill                     = 3
'
'
' ####################
' #####  Xst ()  #####
' ####################
'
FUNCTION  Xst ()
	STATIC  entry
	FILEINFO  attr[]
'
' include sockets functions
'
	a = &accept()
	a = &bind()
	a = &close()
	a = &connect()
	a = &getpeername()
	a = &getsockname()
	a = &getsockopt()
	a = &htonl()
	a = &htons()
	a = &inet_addr()
	a = &inet_ntoa()
	a = &ioctl()
	a = &listen()
	a = &ntohl()
	a = &ntohs()
	a = &recv()
	a = &recvfrom()
	a = &send()
	a = &sendto()
	a = &setsockopt()
	a = &shutdown()
	a = &socket()
'
	a = &gethostbyaddr()
	a = &gethostbyname()
	a = &gethostname()
	a = &getservbyname()
	a = &getservbyport()
	a = &getprotobyname()
	a = &getprotobynumber()
'
' include miscellaneous functions
'
	a = &time()
	a = &ftime()
	a = &gmtime()
	a = &mktime()
	a = &localtime()
	a = &gettimeofday()
'
	XxxGetImplementation (@name$)
	name$ = LCASE$ (name$)
'
	IF INSTR (name$, "linux") THEN
		#O_ACCMODE  = $$LIN_O_ACCMODE
		#O_RDONLY   = $$LIN_O_RDONLY
		#O_WRONLY   = $$LIN_O_WRONLY
		#O_RDWR     = $$LIN_O_RDWR
		#O_CREAT    = $$LIN_O_CREAT
		#O_EXCL     = $$LIN_O_EXCL
		#O_NOCTTY   = $$LIN_O_NOCTTY
		#O_TRUNC    = $$LIN_O_TRUNC
		#O_APPEND   = $$LIN_O_APPEND
		#O_NONBLOCK = $$LIN_O_NONBLOCK
		#O_NDELAY   = $$LIN_O_NDELAY
		#O_SYNC     = $$LIN_O_SYNC
	ELSE
		#O_ACCMODE  = $$SCO_O_ACCMODE
		#O_RDONLY   = $$SCO_O_RDONLY
		#O_WRONLY   = $$SCO_O_WRONLY
		#O_RDWR     = $$SCO_O_RDWR
		#O_CREAT    = $$SCO_O_CREAT
		#O_EXCL     = $$SCO_O_EXCL
		#O_NOCTTY   = $$SCO_O_NOCTTY
		#O_TRUNC    = $$SCO_O_TRUNC
		#O_APPEND   = $$SCO_O_APPEND
		#O_NONBLOCK = $$SCO_O_NONBLOCK
		#O_NDELAY   = $$SCO_O_NDELAY
		#O_SYNC     = $$SCO_O_SYNC
	END IF
'
	IF entry THEN RETURN
	entry = $$TRUE
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Linux XBasic standard function library"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
' initialize key variables and arrays
'
	InitProgram ()
'
'	XstLog ("Xio().A")
' Xio removed becuase the GUI shouldn't be initialized yet!
'	Xio ()
'	XstLog ("Xio().Z")
	XstGetFiles (@xbdir$, @file$[])
'	XstLog ("Xst().Z")
END FUNCTION
'
'
' ############################
' #####  XstVersion$ ()  #####
' ############################
'
FUNCTION  XstVersion$ ()
'
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' ##################################
' #####  XstCauseException ()  #####
' ##################################
'
FUNCTION  XstCauseException (exception)
'
	pid = getpid ()
	XstExceptionToSystemException (exception, @sysException)
	kill (pid, sysException)
END FUNCTION
'
'
' ################################
' #####  XstCloseLibrary ()  #####
' ################################
'
FUNCTION  XstCloseLibrary (handle)
	return = FreeLibrary (handle)
	RETURN (return)
END FUNCTION
'
'
' #########################################
' #####  XstDateAndTimeToFileTime ()  #####
' #########################################
'
FUNCTION  XstDateAndTimeToFileTime (year, month, day, weekDay, hour, minute, second, nanos, @filetime$$)
	UTM  tm
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	tm.tm_year = year - 1900
	tm.tm_mon = month - 1
	tm.tm_mday = day
	tm.tm_hour = hour
	tm.tm_min = minute
	tm.tm_sec = second
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	time = mktime (&tm)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	DeltaTimeZone (@delta)													' GMT vs local time
'
	filetime$$ = time + delta												' time relative to 1970 Jan 1 at 00:00:00
	filetime$$ = filetime$$ * 10000000$$						' convert to 100ns units
	filetime$$ = filetime$$ + (nanos \ 100$$)				' add nanoseconds converted to 100ns units
	filetime$$ = filetime$$ + 116444736000000000$$	' time relative to 1601 Jan 1 at 00:00:00.000
	filetime$$ = filetime$$ + delta$$								' corre
END FUNCTION
'
'
' #####################################
' #####  XstErrorNameToNumber ()  #####
' #####################################
'
FUNCTION  XstErrorNameToNumber (err$, error)
	SHARED	errorObject$[]
	SHARED	errorNature$[]
'
	error = 0
	error$ = TRIM$ (err$)
	return = $$TRUE															' error name not found
'
	DO WHILE error$
		space = INCHR (error$, " \t")
		IFZ space THEN
			e$ = error$
		ELSE
			e$ = TRIM$(LEFT$(error$, space))
			error$ = TRIM$(MID$(error$, space+1))
		END IF
		upper = UBOUND (errorObject$[])
		FOR i = 1 TO upper
			IF (e$ = errorObject$[i]) THEN
				error = error OR (i << 8)							' error object name found
				return = $$FALSE
				EXIT FOR															' only one error object
			END IF
		NEXT i
		upper = UBOUND (errorNature$[])
		FOR i = 1 TO upper
			IF (e$ = errorNature$[i]) THEN
				error = error OR i										' error nature name found
				return = $$FALSE
				EXIT FOR															' only one error nature
			END IF
		NEXT i
	LOOP
END FUNCTION
'
'
' #####################################
' #####  XstErrorNumberToName ()  #####
' #####################################
'
FUNCTION  XstErrorNumberToName (error, error$)
	SHARED	errorObject$[]
	SHARED	errorNature$[]
'
	nature = error AND 0x00FF
	object = (error >> 8) AND 0x00FF
	upperObject = UBOUND (errorObject$[])
	upperNature = UBOUND (errorNature$[])
'
	error$ = ""
	SELECT CASE TRUE
		CASE (object < 0) 					: error$ = "Unknown Negative Object Number"
		CASE (nature < 0)						: error$ = "Unknown Negative Nature Number"
		CASE (object > upperObject)	: error$ = "$$ErrorObject too large"
		CASE (nature > upperNature)	: error$ = "$$ErrorNature too large"
	END SELECT
'
	IF error$ THEN RETURN
	object$ = errorObject$[object]
	nature$ = errorNature$[nature]
	IFZ (object OR nature) THEN error$ = "NoError" : RETURN
'
	IF object$ THEN
		IF nature$ THEN
			error$ = object$ + " " + nature$
		ELSE
			error$ = object$
		END IF
	ELSE
		IF nature THEN
			error$ = nature$
		ELSE
			error$ = "UnknownError"
		END IF
	END IF
END FUNCTION
'
'
' #########################################
' #####  XstExceptionNumberToName ()  #####
' #########################################
'
FUNCTION  XstExceptionNumberToName (exception, exception$)
	SHARED	exception$[]
'
	exception$ = ""
	upper = UBOUND (exception$[])
	IF (exception < 0) THEN RETURN ($$TRUE)
	IF (exception > upper) THEN RETURN ($$TRUE)
	exception$ = exception$[exception]
END FUNCTION
'
'
' ##############################################
' #####  XstExceptionToSystemException ()  #####
' ##############################################
'
FUNCTION  XstExceptionToSystemException (exception, sysException)
'
	SELECT CASE exception
		CASE $$ExceptionSegmentViolation					: sysException = $$SIGSEGV
		CASE $$ExceptionOutOfBounds								: sysException = $$SIGBUS
		CASE $$ExceptionBreakpoint								: sysException = $$SIGTRAP
		CASE $$ExceptionBreakKey									: sysException = $$SIGINT
		CASE $$ExceptionAlignment									: sysException = $$SIGBUS
		CASE $$ExceptionDenormal									: sysException = $$SIGFPE
		CASE $$ExceptionDivideByZero							: sysException = $$SIGFPE
		CASE $$ExceptionInvalidOperation					: sysException = $$SIGFPE
		CASE $$ExceptionOverflow									: sysException = $$SIGFPE
		CASE $$ExceptionStackCheck								: sysException = $$SIGSEGV
		CASE $$ExceptionUnderflow									: sysException = $$SIGFPE
		CASE $$ExceptionInvalidInstruction				: sysException = $$SIGILL
		CASE $$ExceptionDivideByZero							: sysException = $$SIGFPE
		CASE $$ExceptionOverflow									: sysException = $$SIGFPE
		CASE $$ExceptionPrivilege									: sysException = $$SIGSEGV
		CASE $$ExceptionStackOverflow							: sysException = $$SIGSEGV
		CASE ELSE																	: sysException = $$SIGSEGV
	END SELECT
END FUNCTION
'
'
' #########################################
' #####  XstFileTimeToDateAndTime ()  #####
' #########################################
'
FUNCTION  XstFileTimeToDateAndTime (filetime$$, year, month, day, weekDay, hour, minute, second, nanos)
	UTM  time
	AUTOX  secs
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	year = 0
	month = 0
	day = 0
	weekDay = 0
	hour = 0
	minute = 0
	second = 0
	nanos = 0
'
	time$$ = filetime$$ - 116444736000000000$$		' from 1601 relative to 1970 relative
	IF (time$$ < 0) THEN time$$ = filetime$$			' filetime$$ must have been 1970 relative
	secs$$ = time$$ \ 10000000$$									' seconds since 1970 Jan 1 at 00:00:00.0000000
	temp$$ = secs$$ * 10000000$$									'
	frac$$ = time$$ - temp$$											' fractions of seconds in 100ns units
	secs = secs$$																	' seconds since 1970 Jan 1 at 00:00:00.000
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	time = gmtime (&secs)													' convert seconds to year/month/day/hour/min/sec
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	year = time.tm_year + 1900
	month = time.tm_mon + 1
	day = time.tm_mday
	weekDay = time.tm_wday
	hour = time.tm_hour
	minute = time.tm_min
	second = time.tm_sec
	nanos = frac$$ * 100$$												' nanoseconds remainder
END FUNCTION
'
'
' ####################################
' #####  XstFileToSystemFile ()  #####
' ####################################
'
FUNCTION  XstFileToSystemFile (fileNumber, systemFileNumber)
	SHARED  FILE  fileInfo[]
'
	systemFileNumber = 0
	IF fileInfo[] THEN
		upper = UBOUND (fileInfo[])
		IF (fileNumber <= upper) THEN
			fileHandle = fileInfo[fileNumber].fileHandle
			IF fileHandle THEN systemFileNumber = fileHandle
		END IF
	END IF
END FUNCTION
'
'
' #############################################
' #####  XstGetApplicationEnvironment ()  #####
' #############################################
'
FUNCTION  XstGetApplicationEnvironment (@standalone, @reserved)
'
	standalone = ##STANDALONE
	reserved = $$FALSE
END FUNCTION
'
'
' ##################################
' #####  XstGetCommandLine ()  #####
' ##################################
'
FUNCTION  XstGetCommandLine (@line$)
'
	line$ = ""
	XstGetCommandLineArguments (@argc, @argv$[])
'
	IF (argc <= 0) THEN RETURN
	FOR i = 0 TO argc-1
		line$ = line$ + argv$[i]
	NEXT i
	line$ = TRIM$(line$)
END FUNCTION
'
'
' ###########################################
' #####  XstGetCommandLineArguments ()  #####
' ###########################################
'
FUNCTION  XstGetCommandLineArguments (argc, argv$[])
	SHARED  setargv$[]
	SHARED  setargc
	SHARED  setarg
	STATIC  entry
'
	whomask = ##WHOMASK
'
	IFZ entry THEN GOSUB Initialize
	entry = $$TRUE
	DIM argv$[]
	inc = argc
	argc = 0
'
	IF (inc < 0) THEN												' return original command line arguments
		upper = UBOUND (##ARGV$[])
		argc = upper + 1
		IF argc THEN
			DIM argv$[upper]
			FOR i = 0 TO upper
				argv$[i] = ##ARGV$[i]
			NEXT i
		END IF
	ELSE
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
	END IF
	RETURN ($$FALSE)
'
'
' *****  Initialize  *****
'
SUB Initialize
	DIM setargv$[]
	setarg = $$TRUE
	setargc = ##ARGC
	upper = UBOUND (##ARGV$[])
	ucount = upper + 1
	IF (setargc > ucount) THEN setargc = ucount
	IF (setargc <= 0) THEN EXIT SUB
'
'	upper$ = STRING$(upper) + " : " + STRING$(setargc) + "\n"
'	write (1, &upper$, LEN(upper$))
'
	##WHOMASK = 0
	DIM setargv$[upper]
	FOR i = 0 TO upper
		setargv$[i] = ##ARGV$[i]
	NEXT i
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ##################################
' #####  XstGetConsoleGrid ()  #####
' ##################################
'
FUNCTION  XstGetConsoleGrid (grid)
	grid = ##CONGRID
END FUNCTION
'
'
' ##############################
' #####  XstGetCPUName ()  #####
' ##############################
'
FUNCTION  XstGetCPUName (name$)
	name$ = "80386"
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
FUNCTION  XstGetDateAndTime (year, month, day, weekDay, hour, minute, second, nanos)
	UTIMEZONE  tz
	UTIMEVAL  tv
	UTM  time
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	gettimeofday (&tv, &tz)
	time = gmtime (&tv.tv_sec)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	year		= time.tm_year + 1900
	month		= time.tm_mon + 1
	day			= time.tm_mday
	weekDay	= time.tm_wday
	hour		= time.tm_hour
	minute	= time.tm_min
	second	= time.tm_sec
	nanos		= tv.tv_usec * 1000
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
	UTIMEZONE  tz
	UTIMEVAL  tv
	UTM  time
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	gettimeofday (&tv, &tz)
	time = localtime (&tv.tv_sec)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	year		= time.tm_year + 1900
	month		= time.tm_mon + 1
	day			= time.tm_mday
	weekDay	= time.tm_wday
	hour		= time.tm_hour
	minute	= time.tm_min
	second	= time.tm_sec
	nanos		= tv.tv_usec * 1000
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
	endian$$ = temp$$
END FUNCTION
'
'
' #################################
' #####  XstGetEndianName ()  #####
' #################################
'
FUNCTION  XstGetEndianName (name$)
	name$ = "LittleEndian"
END FUNCTION
'
'
' ##########################################
' #####  XstGetEnvironmentVariable ()  #####
' ##########################################
'
FUNCTION  XstGetEnvironmentVariable (name$, value$)
	SHARED  envp,  envp$[]
	STATIC  entry
'
	whomask = ##WHOMASK
'
	IFZ entry THEN
		IFZ envp$[] THEN XstGetEnvironmentVariables (@count, @var$[])
		entry = $$TRUE
		DIM var$[]
	END IF
'
	value$ = ""
	found = $$FALSE
	ename$ = TRIM$ (name$)
	upper = UBOUND (envp$[])
	FOR i = 0 TO upper
		envp$ = envp$[i]
		equal = INSTR (envp$, "=")
		IF equal THEN
			vname$ = TRIM$(LEFT$(envp$,equal-1))
			IF (ename$ = vname$) THEN
				value$ = MID$(envp$,equal+1)
				found = $$TRUE
				EXIT FOR
			END IF
		END IF
	NEXT i
'
	IFZ found THEN
		##WHOMASK = $$FALSE
		addr = getenv (&ename$)
		##WHOMASK = whomask
		IF addr THEN value$ = CSTRING$ (addr)
	END IF
END FUNCTION
'
'
' ###########################################
' #####  XstGetEnvironmentVariables ()  #####
' ###########################################
'
FUNCTION  XstGetEnvironmentVariables (count, var$[])
	SHARED  envp,  envp$[]
	STATIC  entry
'
	IFZ entry THEN GOSUB Initialize
	entry = $$TRUE
'
	upper = UBOUND (envp$[])
	count = upper + 1
	DIM var$[upper]
'
	FOR i = 0 TO upper
		var$[i] = envp$[i]
	NEXT i
	RETURN
'
'
' *****  Initialize  *****
'
SUB Initialize
	whomask = ##WHOMASK
	DIM envp$[]
	envp = 0
'
	IFZ ##ENVP$[] THEN RETURN
	upper = UBOUND (##ENVP$[])
	IF (upper < 0) THEN RETURN
	envp = upper + 1
'
	##WHOMASK = 0
	DIM envp$[upper]
	FOR i = 0 TO upper
		envp$[i] = ##ENVP$[i]
	NEXT i
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ################################
' #####  XstGetException ()  #####
' ################################
'
FUNCTION  XstGetException (exception)
	exception = ##EXCEPTION
END FUNCTION
'
'
' ########################################
' #####  XstGetExceptionFunction ()  #####
' ########################################
'
FUNCTION  XstGetExceptionFunction (function)
	SHARED	exceptionFunction
'
	function = exceptionFunction
END FUNCTION
'
'
' #####################################
' #####  XstGetImplementation ()  #####
' #####################################
'
FUNCTION  XstGetImplementation (name$)
'
	XxxGetImplementation (@name$)
'
END FUNCTION
'
'
' #####################################
' #####  XstGetLibraryAddress ()  #####
' #####################################
'
FUNCTION  XstGetLibraryAddress (handle, funcname$)
	addr = GetProcAddress (handle, &funcname$)
	RETURN (addr)
END FUNCTION
'
'
' ################################
' #####  XstGetMemoryMap ()  #####
' ################################
'
FUNCTION  XstGetMemoryMap (MEMORYMAP memorymap)
'
	memorymap.code0 = ##CODE0
	memorymap.code = ##CODE
	memorymap.codex = ##CODEX
	memorymap.codez = ##CODEZ
	memorymap.data0 = ##DATA0
	memorymap.data = ##DATA
	memorymap.datax = ##DATAX
	memorymap.dataz = ##DATAZ
	memorymap.bss0 = ##BSS0
	memorymap.bss = ##BSS
	memorymap.bssx = ##BSSX
	memorymap.bssz = ##BSSZ
	memorymap.dyno0 = ##DYNO0
	memorymap.dyno = ##DYNO
	memorymap.dynox = ##DYNOX
	memorymap.dynoz = ##DYNOZ
	memorymap.ucode0 = ##UCODE0
	memorymap.ucode = ##UCODE
	memorymap.ucodex = ##UCODEX
	memorymap.ucodez = ##UCODEZ
	memorymap.stack0 = ##STACK0
	memorymap.stack = ##STACK
	memorymap.stackx = ##STACKX
	memorymap.stackz = ##STACKZ
END FUNCTION
'
'
' ##############################
' #####  XstGetNewline ()  #####
' ##############################
'
FUNCTION  XstGetNewline (save, paste)
	SHARED	sysSaveNewline,  sysPasteNewline
	SHARED	userSaveNewline,  userPasteNewline
'
	IF ##WHOMASK THEN
		save = userSaveNewline
		paste = userPasteNewline
	ELSE
		save = sysSaveNewline
		paste = sysSaveNewline
	END IF
'
	IFZ save THEN save = $$NewlineDefault
	IFZ paste THEN paste = $$NewlineDefault
END FUNCTION
'
'
' #############################
' #####  XstGetOSName ()  #####
' #############################
'
FUNCTION  XstGetOSName (name$)
'
	SELECT CASE ##XBSystem
		CASE $$XBSysLinux:
			name$ = "linux unix"
		CASE ELSE:
			name$ = "unix"
	END SELECT
'
END FUNCTION
'
'
' ################################
' #####  XstGetOSVersion ()  #####
' ################################
'
FUNCTION  XstGetOSVersion (major, minor)
'
	version = 0x0400
	major = version{8,8}
	minor = version{8,0}
END FUNCTION
'
'
' ####################################
' #####  XstGetOSVersionName ()  #####
' ####################################
'
FUNCTION  XstGetOSVersionName (name$)
'
	version = 0x0400
	majorVersion = version{8,8}
	minorVersion = version{8,0}
	name$ = STRING$ (majorVersion) + "." + STRING$ (minorVersion)
END FUNCTION
'
'
' ###############################
' #####  XstGetPrintTab ()  #####
' ###############################
'
FUNCTION  XstGetPrintTab (pixels)
'
	pixels = ##TABSAT
END FUNCTION
'
'
' ##################################
' #####  XstGetProgramName ()  #####
' ##################################
'
FUNCTION  XstGetProgramName (@prog$)
	SHARED  userProgram$
	SHARED  sysProgram$
'
	prog$ = ""
	whomask = ##WHOMASK
'
	IF whomask THEN
		prog$ = userProgram$
	ELSE
		prog$ = sysProgram$
	END IF
END FUNCTION
'
'
' ##################################
' #####  XstGetSystemError ()  #####
' ##################################
'
FUNCTION  XstGetSystemError (error)
	EXTERNAL  errno
'
	error = errno
END FUNCTION
'
'
' ##############################
' #####  XstGetSystemTime  #####  msec = free-running millisecond time
' ##############################
'
FUNCTION  XstGetSystemTime (msec)
	SHARED  UTIMEB  startTime
	AUTOX  UTIMEB  nowTime
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
' get zero reference time for free-running millisecond time
'
	IFZ startTime.time THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		ftime (&startTime)
		##WHOMASK = whomask
		##LOCKOUT = lockout
	END IF
'
' get current time
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	ftime (&nowTime)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
' msec = system time = nowTime - startTime
'
	ssec = startTime.time						' start time - seconds
	smsec = startTime.millitm				' start time - milliseconds
'
	nsec = nowTime.time							' current time - seconds
	nmsec = nowTime.millitm					' current time - milliseconds
'
	sec = nsec - ssec								' delta = current - start (sec)
	msec = nmsec - smsec						' delta = current - start (msec)
'
	IF (sec < 0) THEN sec = 0 : msec = 0
	IF (msec < 0) THEN msec = msec + 1000 : sec = sec - 1
	IF (msec < 0) THEN msec = msec + 1000 : sec = sec - 1
	msec = (sec * 1000) + msec
END FUNCTION
'
'
' #############################
' #####  XstKillTimer ()  #####
' #############################
'
FUNCTION  XstKillTimer (timer)
'
	return = XxxXstTimer ($$TimerKill, timer, 0, 0, 0)
	RETURN (return)
END FUNCTION
'
'
' #######################
' #####  XstLog ()  #####
' #######################
'
FUNCTION  XstLog (text$)
	STATIC  name$
'
	pid = getpid ()
	pid$ = " p" + RIGHT$("000"+STRING$(pid),4)
	XstGetDateAndTime (@year, @month, @day, 0, @hour, @min, @sec, @nanos)
	stamp$ = RIGHT$("000" + STRING$(year),4) + RIGHT$("0" + STRING$(month),2) + RIGHT$("0" + STRING$(day),2) + ":" + RIGHT$("0" + STRING$(hour),2) + RIGHT$("0" + STRING$(min),2) + RIGHT$("0" + STRING$(sec),2) + "." + RIGHT$("000" + STRING$(nanos\1000000),3) + pid$ + " : "
'
	IFZ name$ THEN
		XstGetCurrentDirectory (@name$)
		name$ = name$ + $$PathSlash$ + "x.log"
		ofile = OPEN ("x.log", $$WRNEW)
	ELSE
		ofile = OPEN (name$, $$WR)
	END IF
'
	IF (ofile >= 3) THEN
		length = LOF (ofile)
		SEEK (ofile, length)
		PRINT [ofile], stamp$ + text$
		CLOSE (ofile)
	END IF
END FUNCTION
'
'
' ###############################
' #####  XstOpenLibrary ()  #####
' ###############################
'
FUNCTION  XstOpenLibrary (name$)
	handle = LoadLibraryA (&name$)
	RETURN (handle)
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
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
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
		##WHOMASK = $$FALSE
		DIM setargv$[upper]
		FOR i = 0 TO upper
			setargv$[i] = argv$[i]
		NEXT i
		##WHOMASK = whomask
	END IF
END FUNCTION
'
'
' ##################################
' #####  XstSetDateAndTime ()  #####
' ##################################
'
FUNCTION  XstSetDateAndTime (year, month, day, weekDay, hour, minute, second, nanos)
	EXTERNAL  errno
	STATIC	UTM  time
	AUTOX  unixtime
'
	time.tm_year	= year
	time.tm_mon		= month - 1
	time.tm_mday	= day
	time.tm_wday	= weekDay
	time.tm_hour	= hour
	time.tm_min		= minute
	time.tm_sec		= second
'
	DeltaTimeZone (@delta)
'
	unixtime = mktime (&time) + delta
'
	IF (unixtime < 0) THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN (error)
	END IF
'
	error = stime (&unixtime)
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
	END IF
	RETURN (error)
END FUNCTION
'
'
' ##########################################
' #####  XstSetEnvironmentVariable ()  #####
' ##########################################
'
FUNCTION  XstSetEnvironmentVariable (name$, value$)
	SHARED  envp,  envp$[]
'
	whomask = ##WHOMASK
'
	IFZ entry THEN
		IFZ envp$[] THEN XstGetEnvironmentVariables (@count, @var$[])
		entry = $$TRUE
		DIM var$[]
	END IF
'
	slot = -1
	found = $$FALSE
	##WHOMASK = $$FALSE
	ename$ = TRIM$ (name$)						' environment variable name
	envp$ = ename$ + "=" + value$			' environment variable name=value
	upper = UBOUND (envp$[])					' upper environment variable
	##WHOMASK = whomask
'
	FOR i = 0 TO upper
		slot$ = envp$[i]
		IF (slot < 0) THEN
			IFZ slot$ THEN slot = i
		END IF
		equal = INSTR (slot$, "=")
		IF equal THEN
			vname$ = TRIM$(LEFT$(slot$,equal-1))
			IF (ename$ = vname$) THEN
				##WHOMASK = $$FALSE
				envp$[i] = envp$
				##WHOMASK = whomask
				addr = &envp$[i]
				found = $$TRUE
				EXIT FOR
			END IF
		END IF
	NEXT i
'
	IFZ found THEN
		IF (slot < 0) THEN
			upper = upper + 1
			##WHOMASK = $$FALSE
			REDIM envp$[upper]
			##WHOMASK = whomask
			slot = upper
		END IF
		envp$[slot] = ""
		##WHOMASK = $$FALSE
		envp$[slot] = envp$
		addr = &envp$[slot]
		##WHOMASK = whomask
	END IF
'
	##WHOMASK = $$FALSE
	error = putenv (addr)
	##WHOMASK = whomask
END FUNCTION
'
'
' ################################
' #####  XstSetException ()  #####
' ################################
'
FUNCTION  XstSetException (exception)
'
	##EXCEPTION = exception
END FUNCTION
'
'
' ########################################
' #####  XstSetExceptionFunction ()  #####
' ########################################
'
FUNCTION  XstSetExceptionFunction (function)
	SHARED	exceptionFunction
'
	exceptionFunction = function
END FUNCTION
'
'
' ##############################
' #####  XstSetNewline ()  #####
' ##############################
'
FUNCTION  XstSetNewline (save, paste)
	SHARED	sysSaveNewline,  sysPasteNewline
	SHARED	userSaveNewline,  userPasteNewline
'
	IF ##WHOMASK THEN
		SELECT CASE save
			CASE 0		: userSaveNewline = $$NewlineDefault
			CASE 1, 2	: userSaveNewline = save
		END SELECT
		SELECT CASE paste
			CASE 0		: userPasteNewline = $$NewlineDefault
			CASE 1, 2	: userPasteNewline = paste
		END SELECT
	ELSE
		SELECT CASE save
			CASE 0		: sysSaveNewline = $$NewlineDefault
			CASE 1, 2	: sysSaveNewline = save
		END SELECT
		SELECT CASE paste
			CASE 0		: sysPasteNewline = $$NewlineDefault
			CASE 1, 2	: sysPasteNewline = paste
		END SELECT
	END IF
END FUNCTION
'
'
' ###############################
' #####  XstSetPrintTab ()  #####
' ###############################
'
FUNCTION  XstSetPrintTab (pixels)
	IF (pixels < 0) THEN pixels = 0
	##TABSAT = pixels
END FUNCTION
'
'
' ##################################
' #####  XstSetProgramName ()  #####
' ##################################
'
FUNCTION  XstSetProgramName (@prog$)
	SHARED  userProgram$
	SHARED  sysProgram$
'
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
'
	IF whomask THEN
		userProgram$ = prog$
	ELSE
		sysProgram$ = prog$
	END IF
	##WHOMASK = whomask
END FUNCTION
'
'
' ##################################
' #####  XstSetSystemError ()  #####
' ##################################
'
FUNCTION  XstSetSystemError (sysError)
	EXTERNAL  errno
	errno = sysError
END FUNCTION
'
'
' #########################
' #####  XstSleep ()  #####
' #########################
'
' !!!!!!!!  This function contains flakey timing  !!!!!!!!
'
' "IF sleepUser THEN sleep ((delta+999)\1000)" doesn't work because
' it replaces the existing interval in milliseconds with a sleep()
' interval in seconds, thereby destroying the millisecond accuracy
' of this routine.  The SCO UNIX documentation implies this won't
' happen anymore, that only "old" sleep() does that, but it does.
'
' Before "pause()" was changed to "IF sleepUser THEN pause()", it
' was usual for processes to lock up indefinitely when a short nap
' like 10ms was requested.  The timer started by XstStartTimer()
' would expire and clear sleepUser before pause() was called, and
' therefore there was no interval timer to expire and terminate the
' pause().
'
' This function still has that problem, but the window of potential
' lockup disaster is reduced to a minimum.  But if the timer signal
' occurs between "IF sleepUser THEN" and "pause()", this routine will
' also go into lockjaw.  Two ugly "solutions" come to mind:
'
' 1. Start two timers, the real timer with the requested interval,
' and a "nop timer" with a longer interval.  If the real timer signal
' occurs before pause() is called, at least the "nop timer" should
' expire later and terminates pause().  This works because any signal
' terminates pause() according to the SCO documentation.
'
' Later note:  tried #1 and it doesn't work right.
'
' 2. Have the timer routine make sure there's always at least one
' active interval timer.  If ever there are none, the timer routine
' would install a short (50ms) nop interval timer, and reinstall it
' whenever it expired and no others were active.
'
FUNCTION  XstSleep (ms)
	EXTERNAL  errno
	SHARED  UTIMEB  startTime
	SHARED  sleepSystem
	SHARED  sleepUser
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	delta = ms
	XstGetSystemTime (@start)
	IF (delta <= 0) THEN RETURN ($$FALSE)
	IF (delta <= 10) THEN delta = 10
'
	SELECT CASE whomask
		CASE 0		: GOSUB SleepSystem
		CASE ELSE	: GOSUB SleepUser
	END SELECT
	RETURN
'
' *****  SleepSystem  *****
'
SUB SleepSystem
'	PRINT "XstSleep() : SleepSystem"; ms;; start;; sleepSystem;; sleepUser;; HEX$(whomask,8)
	IFZ sleepSystem THEN
		DO WHILE (delta > 0)
			sleepSystem = $$TRUE
			XstStartTimer (@st, 1, delta, &WakeupSystem())
'			write (1, &"[", 1)
			IF sleepSystem THEN pause ()
'			write (1, &"]", 1)
			errno = $$FALSE									' set to EINTR by signal
			XstGetSystemTime (@time)
			delta = ms - (time - start)
		LOOP WHILE sleepSystem
	END IF
	sleepSystem = $$FALSE
END SUB
'
' sleep user, process system events/messages every .200 seconds
'
' *****  SleepUser  *****
'
SUB SleepUser
'	PRINT "XstSleep() : SleepUser"; ms;; start;; sleepSystem;; sleepUser;; HEX$(whomask,8)
	IFZ sleepUser THEN
		DO
			SELECT CASE TRUE
				CASE (delta <= 0)		: EXIT DO					' no more sleep
				CASE (delta <= 20)	: delta = 20			' sleep time slice
				CASE (delta <= 200)	: delta = delta		' sleep <= 200 ms
				CASE ELSE						: delta = 200			' sleep 200 ms then loop
			END SELECT
'
			XxxCheckMessages ()
			IF ##SOFTBREAK THEN EXIT DO			' process break keystrokes
'
			sleepUser = $$TRUE
			XstStartTimer (@st, 1, delta, &WakeupUser())
'			write (1, &"(", 1)
			IF sleepUser THEN pause ()			' flaky timing
'			write (1, &")", 1)
			errno = $$FALSE									' set to EINTR by signal
			XstGetSystemTime (@time)
			delta = ms - (time - start)
		LOOP WHILE (delta > 0)
	END IF
	sleepUser = $$FALSE
END SUB
END FUNCTION
'
'
' ##############################
' #####  XstStartTimer ()  #####
' ##############################
'
' returns timer number in "timer"
' timer numbers <= 0 are not valid
' valid timer numbers start at 1
'
FUNCTION  XstStartTimer (timer, count, msec, func)
'
	return = XxxXstTimer ($$TimerStart, @timer, count, msec, func)
	RETURN (return)
END FUNCTION
'
'
' ######################################
' #####  XstSystemErrorToError ()  #####
' ######################################
'
FUNCTION  XstSystemErrorToError (sysError, error)
'
	upper = UBOUND (#OSTOXERROR[])
	error = ($$ErrorObjectSystem << 8) OR $$ErrorNatureError
	IF ((sysError < 0) OR (sysError > upper)) THEN RETURN
	error = #OSTOXERROR[sysError]
END FUNCTION
'
'
' ###########################################
' #####  XstSystemErrorNumberToName ()  #####
' ###########################################
'
FUNCTION  XstSystemErrorNumberToName (sysError, sysError$)
'
	upper = UBOUND (#OSERROR$[])
	IF ((sysError < 0) OR (sysError > upper)) THEN sysError$ = "Unknown System Error Number" : RETURN
	sysError$ = #OSERROR$[sysError]
END FUNCTION
'
'
' ###############################################
' #####  XstSystemExceptionNumberToName ()  #####
' ###############################################
'
FUNCTION  XstSystemExceptionNumberToName (exception, exception$)
	SHARED	sysException$[]
'
	upper = UBOUND (sysException$[])
	IF ((exception < 0) OR (exception > upper)) THEN
		exception$ = "Unknown System Exception Number"
		RETURN
	END IF
	exception$ = sysException$[exception]
END FUNCTION
'
'
' ##############################################
' #####  XstSystemExceptionToException ()  #####
' ##############################################
'
FUNCTION  XstSystemExceptionToException (signal, exception)
'
	SELECT CASE signal
		CASE $$SIGNONE			: exception = $$ExceptionNone								' no problem
		CASE $$SIGHUP				: exception = $$ExceptionUnknown						' hangup or death of controlling process
		CASE $$SIGINT				: exception = $$ExceptionBreakKey						' interrupt keystroke  (^backspace or ^delete)
		CASE $$SIGQUIT			: exception = $$ExceptionBreakKey						' quit keystroke (if defined and enabled)
		CASE $$SIGILL				: exception = $$ExceptionInvalidInstruction	' invalid instruction
		CASE $$SIGTRAP			: exception = $$ExceptionBreakpoint					' trap / breakpoint
		CASE $$SIGABRT			: exception = $$ExceptionBreakKey						' abort keystroke
		CASE $$SIGIOT				: exception = $$ExceptionBreakKey						' IOT instruction
		CASE $$SIGBUS				: exception = $$ExceptionAlignment					' bus error  (Misaligned or Protection Error)
		CASE $$SIGFPE				: exception = $$ExceptionInvalidOperation		' floating point trap
		CASE $$SIGKILL			: exception = $$ExceptionUnknown						' kill this process
		CASE $$SIGUSR1			: exception = $$ExceptionUnknown						' unknown #1
		CASE $$SIGSEGV			: exception = $$ExceptionSegmentViolation		' segment violation
		CASE $$SIGUSR2			: exception = $$ExceptionUnknown						' unknown #2
		CASE $$SIGPIPE			: exception = $$ExceptionInvalidOperation		' write on pipe with noone on other end
		CASE $$SIGALRM			: exception = $$ExceptionTimer							' alarm clock interrupt
		CASE $$SIGTERM			: exception = $$ExceptionUnknown						' termination of process by software
		CASE $$SIGSTKFLT		: exception = $$ExceptionUnknown						' new
		CASE $$SIGCHLD			: exception = $$ExceptionUnknown						' child process terminated or stopped
		CASE $$SIGCONT			: exception = $$ExceptionUnknown						' continue stopped process
		CASE $$SIGSTOP			: exception = $$ExceptionUnknown						' sendable stop signal not from tty
		CASE $$SIGTSTP			: exception = $$ExceptionUnknown						' stop signal from tty
		CASE $$SIGTTIN			: exception = $$ExceptionUnknown						' to readers pgrp upon background tty read
		CASE $$SIGTTOU			: exception = $$ExceptionUnknown						' same for output if tp->t_local&TOSTOP
		CASE $$SIGURG				: exception = $$ExceptionUnknown						' new
		CASE $$SIGXCPU			: exception = $$ExceptionUnknown						' new
		CASE $$SIGXFSZ			: exception = $$ExceptionUnknown						' new
		CASE $$SIGVTALRM		: exception = $$ExceptionTimer							' virtual timer alarm
		CASE $$SIGPROF			: exception = $$ExceptionUnknown						' profile alarm
		CASE $$SIGWINCH			: exception = $$ExceptionUnknown						' window configuration change
		CASE $$SIGIO				: exception = $$ExceptionUnknown						' new
		CASE $$SIGPOLL			: exception = $$ExceptionUnknown						' pollable event occured
		CASE $$SIGPWR				: exception = $$ExceptionUnknown						' power failure
		CASE $$SIGUNUSED		: exception = $$ExceptionUnknown						' new
		CASE $$SIGRTMIN			: exception = $$ExceptionUnknown						' new
		CASE $$SIGMAX				: exception = $$ExceptionUnknown						' highest signal number
		CASE ELSE						: exception = $$ExceptionUnknown						' ??? who knows ???
	END SELECT
END FUNCTION
'
'
' ################################
' #####  XstClearConsole ()  #####
' ################################
'
FUNCTION  XstClearConsole ()
'
	text$ = ""
	DIM text$[]
	XstGetConsoleGrid (@grid)
	IF (grid <= 0) THEN RETURN
'
	XuiSendMessage (grid, #SetTextArray, 0, 0, 0, 0, 0, @text$[])
	XuiSendMessage (grid, #SetTextString, 0, 0, 0, 0, 0, @text$)
	XuiSendMessage (grid, #Redraw, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ##################################
' #####  XstDisplayConsole ()  #####
' ##################################
'
FUNCTION  XstDisplayConsole ()
'
	XstGetConsoleGrid (@grid)
	IF (grid <= 0) THEN RETURN
'
	XuiSendMessage (grid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ###############################
' #####  XstHideConsole ()  #####
' ###############################
'
FUNCTION  XstHideConsole ()
'
	XstGetConsoleGrid (@grid)
	IF (grid <= 0) THEN RETURN
'
	XuiSendMessage (grid, #HideWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ###############################
' #####  XstShowConsole ()  #####
' ###############################
'
FUNCTION  XstShowConsole ()
'
	XstGetConsoleGrid (@grid)
	IF (grid <= 0) THEN RETURN
'
	XuiSendMessage (grid, #ShowWindow, 0, 0, 0, 0, 0, 0)
END FUNCTION
'
'
' ###########################
' #####  XstBinRead ()  #####
' ###########################
'
FUNCTION  XstBinRead (fileNumber, bufferAddr, maxBytes)
	EXTERNAL  errno
	AUTOX bytesRead
'
	okay = XxxReadFile (fileNumber, bufferAddr, maxBytes, &bytesRead, 0)
	IF okay THEN RETURN (bytesRead)
'
	XstSystemErrorToError (errno, @error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ############################
' #####  XstBinWrite ()  #####
' ############################
'
FUNCTION  XstBinWrite (fileNumber, bufferAddr, numBytes)
	EXTERNAL errno
	AUTOX  bytesWritten
'
	okay = XxxWriteFile (fileNumber, bufferAddr, numBytes, &bytesWritten, 0)
	IF okay THEN RETURN (bytesWritten)
'
	XstSystemErrorToError (errno, @error)
	RETURN ($$TRUE)
END FUNCTION
'
'
' ###################################
' #####  XstChangeDirectory ()  #####
' ###################################
'
FUNCTION  XstChangeDirectory (newDirectory$)
	EXTERNAL  errno
'
	IFZ newDirectory$ THEN RETURN ($$FALSE)
	dir$ = XstPathString$ (@newDirectory$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = chdir (&dir$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' #################################
' #####  XstCopyDirectory ()  #####
' #################################
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
FUNCTION  XstCopyFile (source$, dest$)
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
	s$ = XstPathString$ (@source$)
	d$ = XstPathString$ (@dest$)
'
	XstLoadString (@s$, @string$)
	XstSaveString (@d$, @string$)
	error = ERROR (-1)
	RETURN (error)
END FUNCTION
'
'
' #####################################
' #####  XstDecomposePathname ()  #####
' #####################################
'
FUNCTION  XstDecomposePathname (pathname$, path$, parent$, filename$, file$, extent$)
'
	path$ = ""
	file$ = ""
	extent$ = ""
	parent$ = ""
	filename$ = ""
	name$ = TRIM$ (pathname$)
	dot = RINSTR (name$, ".")
	slash = RINSTR (name$, $$PathSlash$)
	IF slash THEN preslash = RINSTR (name$, $$PathSlash$, slash-1)
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
FUNCTION  XstDeleteFile (file$)
	EXTERNAL  errno
'
	IFZ file$ THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	f$ = XstPathString$ (@file$)
	XstGetFileAttributes (@f$, @attributes)
'
	IFZ attributes THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		RETURN ($$TRUE)
	END IF
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
'
	error = 0
	SELECT CASE TRUE
		CASE (attributes AND $$FileDirectory)
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					error = rmdir (&f$)
					##LOCKOUT = lockout
					##WHOMASK = whomask
					IF error THEN GOSUB Error
		CASE ELSE
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					error = unlink (&f$)
					##LOCKOUT = lockout
					##WHOMASK = whomask
					IF error THEN GOSUB Error
	END SELECT
	RETURN (error)
'
'	*****  Error  *****
'
SUB Error
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	return = error
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
'
' If file$ starts with a path slash, then it
' is assumed to be an absolute path and none
' of the path$[] subdirectories are checked.
'
' IF file$ starts with a .. (parent directory)
' or ./ (current directory), then the path is
' assumed to be relative to the parent directory
' or current directory.
'
' Otherwise the path is determined from the
' search path$[] array.
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
FUNCTION  XstFindFile (file$, path$[], path$, attr)
'
	a = attr
	attr = 0
	path$ = ""
	error = ERROR(0)
	IFZ file$ THEN RETURN
	upper = UBOUND (path$[])
	XstGetCurrentDirectory (@dir$)
'
	ifile$ = file$
	uno = ifile${0}
	dos = ifile${1}
	tres = ifile${2}
	udir = UBOUND (dir$)
	ufile = UBOUND (file$)
	IF (uno == '\\') THEN uno = '/'
	IF (dos == '\\') THEN dos = '/'
	IF (tres == '\\') THEN tres = '/'
	IF ((dir${udir} != '/') AND (dir${udir} != '\\')) THEN dir$ = dir$ + $$PathSlash$ : INC udir
'
	SELECT CASE TRUE
		CASE ((uno = '.') AND (dos = '.'))
					IF ((ufile < 4) OR (tres != '/')) THEN file$ = "" : path$ = "" : attr = 0 : RETURN
					file$ = MID$ (file$, 4)
					DO
						DEC udir
						dir$ = RCLIP$(dir$,1)
						IF ((dir${udir} == '/') OR (dir${udir} = '\\')) THEN EXIT DO
					LOOP UNTIL (udir < 0)
					path$ = dir$																	' path = parent directory
					IF (udir < 3) THEN
						file$ = ""																	' file = none
					ELSE
						file$ = path$ + MID$(ifile$,4)							' file = file in parent directory
					END IF
		CASE ((uno = '.') AND (dos = '/'))
					ifile$ = dir$ + MID$ (ifile$, 3)
	END SELECT
'
	IF (ifile${0} == $$PathSlash) THEN
		ifile$ = XstPathString$ (@ifile$)
'		a$ = "0.<" + file$ + "> <" + ifile$ + "> <" + path$ + ">\n"
'		write (1, &a$, LEN(a$))
		GOSUB FindAbsolute
'		a$ = "1.<" + file$ + "> <" + ifile$ + "> <" + path$ + ">\n"
'		write (1, &a$, LEN(a$))
	ELSE
		ifile$ = $$PathSlash$ + ifile$			' prevent XstPathString$() from taking ifile$ as a
		ifile$ = XstPathString$ (@ifile$)		' relative path and prepending the current directory
		ifile$ = MID$ (ifile$, 2)						' now remove the fake leading path slash
'		a$ = "2.<" + file$ + "> <" + ifile$ + "> <" + path$ + ">\n"
'		write (1, &a$, LEN(a$))
		GOSUB FindRelative
'		a$ = "3.<" + file$ + "> <" + ifile$ + "> <" + path$ + ">\n"
'		write (1, &a$, LEN(a$))
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
		IF (attr AND $$FileDirectory) THEN
			IF (a AND $$FileDirectory) THEN
				path$ = ifile$
			ELSE
				path$ = ""
			END IF
		ELSE
			path$ = ifile$
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
'
	FOR i = 0 TO upper
		path$ = path$[i]
		IFZ path$ THEN path$ = dir$
		path$ = XstPathString$ (@path$)
		IFZ path$ THEN path$ = dir$
		upath = UBOUND (path$)
'		a$ = RJUST$("<" + path$ + "> ", 24)
'		PRINT RJUST$("<" + path$ + "> ", 24);
		IF (path${upath} = $$PathSlash) THEN pslash = 1
		slash = fslash + pslash
		SELECT CASE slash
			CASE 0	:	path$ = path$ + $$PathSlash$ + ifile$
			CASE 1	: path$ = path$ + ifile$
			CASE 2	: path$ = path$ + MID$ (ifile$, 2)
		END SELECT
		XstGetFileAttributes (@path$, @attr)
'		a$ = a$ + LJUST$(" <" + path$ + ">  ", 32) + " : " + HEX$(attr,8) + "\n"
'		write (1, &a$, LEN(a$))
'		PRINT LJUST$(" <" + path$ + ">  ", 32); HEX$(attr,8)
		IF attr THEN
			IF (attr AND $$FileDirectory) THEN
				IF (a AND $$FileDirectory) THEN EXIT FOR		' found directory
			ELSE
				IFZ a THEN EXIT FOR													' found file
				IF (a AND attr) THEN EXIT FOR								' found file
				IF (a AND $$FileNormal) THEN EXIT FOR				' found file
			END IF
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
FUNCTION  XstFindFiles (basepath$, filter$, recurse, file$[])
	FILEINFO  fileinfo[]

	path$ = basepath$
	IFZ path$ THEN RETURN XstGetCurrentDirectory (@path$)
'
	XstGetFileAttributes (@path$, @attribute)
	IFZ (attribute AND $$FileDirectory) THEN RETURN
'
	DIM new$[]
	ufile = UBOUND (file$[])
	pathend$ = RIGHT$ (path$, 1)
	attributeFilter = NOT $$FileDirectory
	IF ((pathend$ != "/") AND (pathend$ != "\\")) THEN path$ = path$ + "/"
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
' #####  XstGetCurrentDirectory ()  #####  Only "/" ends with "/"
' #######################################
'
FUNCTION  XstGetCurrentDirectory (current$)
	EXTERNAL errno
	AUTOX dir$
'
	current$ = ""
	dir$ = NULL$ (511)
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = getcwd (&dir$, 512)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ okay THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	dir$ = TRIM$(CSTRING$(&dir$))
	lenDir = LEN (dir$)													' only "/" ends with "/"
'
	IF (lenDir > 1) THEN
		IF (dir${lenDir - 1} = $$PathSlash) THEN dir$ = RCLIP$ (dir$, 1)
	END IF
'
	current$ = dir$
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
	count = 0
	DIM drive$[]
	DIM driveType[]
	DIM driveType$[]
	RETURN
'
' WindowsNT code follows
'
'	whomask = ##WHOMASK
'	lockout = ##LOCKOUT
'	##LOCKOUT = $$TRUE
'	IFZ driveTypes$[] THEN GOSUB Initialize
'
'	count = 0
'	DIM drive$[63]
'	DIM driveType[63]
'	DIM driveType$[63]
'
'	buffer$ = NULL$(255)
'	##WHOMASK = 0
'	GetLogicalDriveStringsA (255, &buffer$)
'	##WHOMASK = whomask
'
'	i = 0
'	n = 0
'	DO
'		drive$ = ""
'		GOSUB GetDriveName
'		IFZ drive$ THEN EXIT DO
'		drive$[count] = drive$
'		##WHOMASK = 0
'		dt = GetDriveTypeA (&drive$)
'		##WHOMASK = whomask
'		driveType$[count] = driveTypes$[dt]
'		driveType[count] = dt
'		upper = count
'		INC count
'	LOOP WHILE (count < 63)
'
'	REDIM drive$[upper]
'	REDIM driveType[upper]
'	REDIM driveType$[upper]
'	##LOCKOUT = lockout
'	RETURN
'
'
' *****  GetDriveName  *****
'
'SUB GetDriveName
'	drive = 0
'	drive$ = NULL$(255)
'	DO WHILE (i <= 255)
'		c = buffer${i}
'		INC i
'		IFZ c THEN EXIT DO
'		drive${drive} = c
'		INC drive
'	LOOP
'	IFZ drive THEN drive$ = "" ELSE drive$ = LEFT$(drive$,drive)
'END SUB
'
'
' *****  Initialize  *****
'
'SUB Initialize
'	##WHOMASK = 0
'	DIM driveTypes$[ 15]
'	driveTypes$[ $$DriveTypeUnknown ]			= "Unknown"
'	driveTypes$[ $$DriveTypeDamaged ]			= "Rootless"
'	driveTypes$[ $$DriveTypeRemovable ]		= "RemovableMedia"
'	driveTypes$[ $$DriveTypeFixed ]				= "FixedMedia"
'	driveTypes$[ $$DriveTypeRemote ]			= "Remote"
'	driveTypes$[ $$DriveTypeCDROM ]				= "CDROM"
'	driveTypes$[ $$DriveTypeRamDisk ]			= "RamDisk"
'	##WHOMASK = whomask
'END SUB
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
		IF ((path${i} = ':') OR (path${i} = ';')) THEN
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
			k = INCHR (path$, ":;", k)
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
FUNCTION  XstGetFileAttributes (file$, attributes)
	EXTERNAL  errno
	USTAT  ustat
'
	attributes = 0
	IFZ file$ THEN RETURN
	f$ = XstPathString$ (@file$)
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = xb_stat (&f$, &ustat)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (error == -1) THEN								' file not found
		attributes = 0
		errno = 0
		RETURN
	END IF
'
	stat = ustat.st_mode
'
	SELECT CASE ALL TRUE
		CASE (stat AND $$U_MODE_DIR)			: attributes = attributes OR $$FileDirectory
		CASE (stat AND $$U_MODE_NORMAL)		: attributes = attributes OR $$FileNormal
		CASE (stat AND $$U_MODE_EXECUTE)	: attributes = attributes OR $$FileExecutable
		CASE (stat AND $$U_MODE_READ)			: attributes = attributes OR $$FileNormal
																				IFZ (stat AND $$U_MODE_WRITE) THEN attributes = attributes OR $$FileReadOnly
	END SELECT
'
'	log$ = HEX$(attributes,8) + " : " + HEX$(stat,8) + " : " + HEX$($$U_MODE_DIR,8) + " " + HEX$($$U_MODE_NORMAL,8) + " " + HEX$($$U_MODE_EXECUTE,8) + " " + HEX$($$U_MODE_READ,8) + " " + HEX$($$U_MODE_WRITE,8) + " " + f$
'	XstLog (@log$)
'
	IFZ (attributes AND $$FileDirectory) THEN
		slash = RINSTR (f$, $$PathSlash$)
		IF slash THEN
			IF (MID$(f$, slash+1, 1) = ".") THEN
				attributes = attributes OR $$FileHidden
			END IF
		END IF
	END IF
END FUNCTION
'
'
' ############################
' #####  XstGetFiles ()  #####
' ############################
'
FUNCTION  XstGetFiles (ff$, file$[])
	EXTERNAL  errno
	UDIRENT	dirent
'
	DIM file$[]
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	filter$ = XstPathString$ (@ff$)
	IFZ filter$ THEN RETURN ($$FALSE)
	IF (filter$ = "*") THEN filter$ = $$PathSlash$
'
	upper = UBOUND (filter$)
	IF (upper >= 1) THEN
		y = filter${upper-1}
		z = filter${upper}
		IF (z = '*') THEN
			IF (y = $$PathSlash) THEN filter$ = RCLIP$ (filter$, 1)
		END IF
	END IF
'
	IFZ filter$ THEN filter$ = $$PathSlash$
	XstGetFileAttributes (@filter$, @attributes)	' Is filter$ a valid directory?
'
	IF (attributes AND $$FileDirectory) THEN
		path$ = filter$
		filter$ = ""
	ELSE
		IF attributes THEN													' Is this a specific file?
			DIM file$[0]
			slash = RINSTR (filter$, $$PathSlash$)
			IFZ slash THEN file$ = filter$ ELSE file$ = MID$ (filter$, slash+1)
			file$[0] = file$
			RETURN (LEN(filter$))
		END IF
'
		path$ = ""
		slash = RINSTR (filter$, $$PathSlash$)
		IF slash THEN
			path$		= LEFT$(filter$, slash-1)
			filter$ = MID$ (filter$, slash+1)
			XstGetFileAttributes (@path$, @attributes)		' path better exist
			IFZ attributes THEN RETURN ($$TRUE)						' path doesn't exist
			IFZ (attributes AND $$FileDirectory) THEN RETURN ($$FALSE)
		ELSE
			path$ = "."
		END IF
	END IF
'
	GOSUB CleanFilter
'
'	a$ = "open() : path$ = \"" + path$ + "\"\n"
'	write (1, &a$, LEN(a$))
'
	apath = &path$
	##LOCKOUT = $$TRUE													' avoid break during FindFile
	##WHOMASK = 0
	idir = opendir (apath)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
'	a$ = "opendir() : idir.errno = " + STRING$(idir) + "." + STRING$(errno) + "\n"
'	write (1, &a$, LEN(a$))
'
	IF (idir <= 0) THEN RETURN ($$TRUE)
'
	ifile = -1
	ufiles = 255
	maxLength = 0
	DIM file$[ufiles]
	buffer$ = NULL$ (4095)
	baddr = &buffer$
'
	DO
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		ret = xb_readdir(idir, &dirent)
		##LOCKOUT = lockout
		##WHOMASK = whomask
'
		IFZ ret > 0 THEN EXIT DO
		ino = dirent.d_ino
		off = dirent.d_off
		len = dirent.d_reclen
		file$ = dirent.d_name
'
'		log$ = HEX$(&dirent,8) + " : " + HEX$(ino,8) + " " + HEX$(off,8) + " " + HEX$(len,4) + " " + HEX$(pad,2) + " <" + file$ + ">"
'		XstLog (@log$)
		IF file$ THEN
			IF ((file$ != ".") AND (file$ != "..")) THEN
				GOSUB FilterFile
'				a$ = "ffw " + file$ + ":" + path$ + " "
'				write (1, &a$, LEN(a$))
				IF file$ THEN
					upath = UBOUND (path$)
					SELECT CASE TRUE
						CASE (path$ = ".")								: statFile$ = file$
						CASE (path${upath} = $$PathSlash)	: statFile$ = path$ + file$
						CASE ELSE													: statFile$ = path$ + $$PathSlash$ + file$
					END SELECT
					XstGetFileAttributes (@statFile$, @attributes)
					IF (attributes AND $$FileDirectory) THEN
						statFile$ = statFile$ + $$PathSlash$
						file$ = file$ + $$PathSlash$
					END IF
					INC ifile
					IF (ifile > ufiles) THEN
						ufiles = ufiles + 256
						REDIM file$[ufiles]
					END IF
					file$[ifile] = file$
					lenFile = LEN (file$)
'						a$ = "ffx " + file$ + " \n"
'						write (1, &a$, LEN(a$))
'						file$[ifile] = statFile$
'						lenFile = LEN (statFile$)
					IF (lenFile > maxLength) THEN maxLength = lenFile
				END IF
			END IF
		END IF
'
		offset = offset + len
	LOOP
'
	closedir (idir)
'	a$ = "ffy " + STRING$(ifile) + ":" + STRING$(ufiles) + "\n"
'	write (1, &a$, LEN(a$))
	IF (ifile != ufiles) THEN REDIM file$[ifile]
'	IF ifile THEN XstQuickSort (@file$[], @null[], 0, ifile, $$SortIncreasing)
'	a$ = "ffz " + STRING$(UBOUND(file$[])) + "\n"
'	write (1, &a$, LEN(a$))
	RETURN (maxLength)
'
'
' *****  ClearFilter  *****  Clean up:	**	*?	\\	TO	*	*	\
'
SUB CleanFilter
	DO
		dstar = INSTR (filter$, "**")
		IF dstar THEN
			filter$ = LEFT$(filter$, dstar) + MID$(filter$, dstar + 2)
		END IF
		qstar = INSTR (filter$, "*?")
		IF qstar THEN
			filter$ = LEFT$(filter$, qstar) + MID$(filter$, qstar + 2)
		END IF
		dslash = INSTR (filter$, $$PathSlash$ + $$PathSlash$)
		IF dslash THEN
			filter$ = LEFT$(filter$, dslash) + MID$(filter$, dslash + 2)
		END IF
	LOOP UNTIL ((dstar + qstar + dslash) = 0)
END SUB
'
' *****  FilterFile  *****
'
SUB FilterFile
'	write (1, &"ff0 ", 4)
	IFZ file$ THEN EXIT SUB
'	write (1, &"ff1 ", 4)
	IFZ filter$ THEN EXIT SUB
'	write (1, &"ff2 ", 4)
	IF (filter$ = "*") THEN EXIT SUB
'	write (1, &"ff3 ", 4)
'
	lenFilter = LEN(filter$)
	lenFile = LEN(file$)
	i = 1
	j = 1
	DO UNTIL ((i > lenFilter) OR (j > lenFile))
		fchar = filter${i - 1}
		SELECT CASE fchar
			CASE '?':																			' ? matches all
			CASE '*'
						IF (i = lenFilter) THEN EXIT SUB				' Trailing * matches all
						INC i
						fchar = filter${i - 1}									' Note:  NOT *?
						match = INSTR(file$, CHR$(fchar), j)
						IFZ match THEN file$ = "" : EXIT SUB
						j = match
			CASE ELSE
						cchar = file${j - 1}
						IF (cchar != fchar) THEN file$ = "" : EXIT SUB
		END SELECT
		INC j
		INC i
	LOOP
	IF ((i <= lenFilter) OR (j <= lenFile)) THEN file$ = ""
END SUB
'
' *****  error  *****
'
error:
	##LOCKOUT = lockout
	##WHOMASK = whomask
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' #########################################
' #####  XstGetFilesAndAttributes ()  #####
' #########################################
'
FUNCTION  XstGetFilesAndAttributes (ff$, attributesFilter, file$[], FILEINFO fileInfo[])
	EXTERNAL	errno
	USTAT  ustat
'
	DIM fileInfo[]
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
'
	filter$ = XstPathString$ (@ff$)
'	a$ = "gfa0 " + ff$ + " : " + filter$ + "\n"
'	write (1, &a$, LEN(a$))
	result = XstGetFiles (filter$, @file$[])
'	a$ = "gfa1 " + STRING$(UBOUND(file$[])) + "\n"
'	write (1, &a$, LEN(a$))
	XstGetPathComponents (filter$, @path$, @drive$, @dir$, @filename$, @attr)
'	a$ = "gfa2 " + filter$ + " : " + drive$ + " : " + dir$ + " : " + filename$ + " : " + HEX$(attr,8) + "\n"
'	write (1, &a$, LEN(a$))
	IFZ file$[] THEN RETURN (result)
'
	ufile = UBOUND (file$[])
	DIM fileInfo[ufile]
'
	entry = 0
	FOR i = 0 TO ufile
		file$ = file$[i]
		IF file$ THEN
			u = UBOUND (file$)
			c = file${u}																		' last character in filename
			IF u THEN																				' don't nullify "/" root directory
				IF (c == $$PathSlash) THEN										' last character is /
					file$ = RCLIP$(file$)												' remove / suffix
					file$[i] = file$
				END IF
			END IF
		END IF
		f$ = drive$ + dir$ + file$
		XstGetFileAttributes (@f$, @attributes)
'
'		a$ = "gfa3 " + f$ + " : " + HEX$(attributes,8) + " : " + HEX$(attributesFilter,8) + "\n"
'		write (1, &a$, LEN(a$))
'
		IF (attributes AND attributesFilter) THEN
			file$[entry] = ""
			file$[entry] = file$
			fileInfo[entry].attributes = attributes
'
			##LOCKOUT = $$TRUE
			##WHOMASK = 0
			stat = xb_stat (&f$, &ustat)
			##WHOMASK = whomask
			##LOCKOUT = lockout
'
			IF (error == -1) THEN
				errno = 0
				DO NEXT
			END IF
'
			ctime$$ = ustat.st_ctime				' create time in seconds since 1970 Jan 1 at 00:00:00.000
			mtime$$ = ustat.st_mtime				' create time in seconds since 1970 Jan 1 at 00:00:00.000
			atime$$ = ustat.st_atime				' create time in seconds since 1970 Jan 1 at 00:00:00.000
'
			ctime$$ = ctime$$ * 10000000		' create time in 100 nanosecond units
			mtime$$ = mtime$$ * 10000000		' modify time in 100 nanosecond units
			atime$$ = atime$$ * 10000000		' access time in 100 nanosecond units
'
' do the following if FILEINFO time units are relative to "1601" instead of "1970"
' add difference between "1601 Jan 1" and "1970 Jan 1" in 100 nanosecond units
'
			ctime$$ = ctime$$ + 116444736000000000$$	' create time since 1601 Jan 1 at 00:00:00.000
			mtime$$ = mtime$$ + 116444736000000000$$	' modify time since 1601 Jan 1 at 00:00:00.000
			atime$$ = atime$$ + 116444736000000000$$	' access time since 1601 Jan 1 at 00:00:00.000
'
			f$ = file$
			length = LEN (f$)
			slash = RINSTR (f$, $$PathSlash$, length-1)
			IF slash THEN f$ = MID$ (f$, slash+1)
'
			fileInfo[entry].sizeHigh = 0
			fileInfo[entry].sizeLow = ustat.st_size
			fileInfo[entry].createTimeLow = GLOW (ctime$$)
			fileInfo[entry].createTimeHigh = GHIGH (ctime$$)
			fileInfo[entry].modifyTimeLow = GLOW (mtime$$)
			fileInfo[entry].modifyTimeHigh = GHIGH (mtime$$)
			fileInfo[entry].accessTimeLow = GLOW (atime$$)
			fileInfo[entry].accessTimeHigh = GHIGH (atime$$)
			fileInfo[entry].alternateName = f$
			fileInfo[entry].name = file$
'			a$ = "gfa4 " + f$ + " : " + file$ + " : " + STRING$(newerustat.st_size) + "\n"
'			write (1, &a$, LEN(a$))
			INC entry
		END IF
	NEXT i
	DEC entry
	REDIM file$[entry]
	REDIM fileInfo[entry]
'	a$ = "gfa5 " + STRING$(entry) + "\n"
'	write (1, &a$, LEN(a$))
END FUNCTION
'
'
' #####################################
' #####  XstGetPathComponents ()  #####
' #####################################
'
FUNCTION  XstGetPathComponents (file$, path$, drive$, dir$, filename$, attributes)
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
	slash = RINSTR (dir$, $$PathSlash$)
	length = LEN (dir$)
'
' get drive$ from file$ or current$
' leave work$ without drive$
' drive$ = "" on unix
'
' replace windows code with UNIX code
'
'	IF colon THEN
'		drive$ = LEFT$ (dir$, colon)
'		dir$ = MID$ (dir$, colon+1)
'		IFZ dir$ THEN dir$ = $$PathSlash$
'		IF (dir${0} != $$PathSlash) THEN dir$ = $$PathSlash$ + dir$
'	ELSE
'		colon = INSTR (current$, ":")
'		IF colon THEN drive$ = LEFT$ (current$, colon)
'		IFZ dir$ THEN dir$ = $$PathSlash$
'		IF (dir${0} != $$PathSlash) THEN dir$ = cpath$ + $$PathSlash$ + dir$
'	END IF
'
' UNIX replacement code
'
' Relative paths should not get a leading /, absolute paths already have
' a leading / so the following code must is removed:
'	IFZ dir$ THEN dir$ = $$PathSlash$
'	IF (dir${0} != $$PathSlash) THEN dir$ = cpath$ + $$PathSlash$ + dir$
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
'		CASE (n${1} = ':')					: guess$ = n$		' leading d: (Windows)
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
' ##############################
' #####  XstLoadString ()  #####
' ##############################
'
FUNCTION  XstLoadString (file$, text$)
'
	text$ = ""
	##ERROR = $$FALSE
	f$ = XstPathString$ (@file$)
'
	XstGetFileAttributes (@f$, @attributes)					' Does file exist?
	IFZ attributes THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		RETURN ($$TRUE)
	END IF
'
	IF (attributes AND $$FileDirectory) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		RETURN ($$TRUE)
	END IF
'
	ifile = OPEN (f$, $$RD)
	IF (ifile < 0) THEN RETURN ($$TRUE)									' ##ERROR set
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
FUNCTION  XstLoadStringArray (file$, text$[])
'
	DIM text$[]
	f$ = XstPathString$ (@file$)
	error = XstLoadString (@f$, @text$)
	IF error THEN RETURN (error)
	XstStringToStringArray (@text$, @text$[])
END FUNCTION
'
'
' ###################################
' #####  XstLockFileSection ()  #####
' ###################################
'
FUNCTION  XstLockFileSection (file, mode, offset$$, length$$)
	EXTERNAL  errno
	SHARED  LOCK  fileLock[]
	SHARED  FILE  fileInfo[]
	AUTOX  UFLOCK  flock
	AUTOX  LOCK  lock[]
'
	whomask = ##WHOMASK
'
	IF (file <= 2) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (fileInfo[])
	IF (file > upper) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		RETURN ($$TRUE)
	END IF
'
	IF (offset$$ < 0) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
	IF (length$$ < 0) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
' remove the following two tests when UNIX supports 64-bit file pointers
'
	IF (offset$$ > 0x7FFFFFFF) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
	IF (length$$ > 0x7FFFFFFF) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
	sfile = fileInfo[file].fileHandle
'
	IF (sfile <= 0) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		RETURN ($$TRUE)
	END IF
'
	IFZ fileLock[] THEN
		##WHOMASK = 0
		upper = (file + 16) OR 0x000F
		DIM fileLock[upper,]
		##WHOMASK = whomask
	END IF
'
	upper = UBOUND (fileLock[])
	IF (upper < file) THEN
		##WHOMASK = 0
		upper = (file + 16) OR 0x000F
		REDIM fileLock[upper,]
		##WHOMASK = whomask
	END IF
'
	IFZ fileLock[file,] THEN
		##WHOMASK = 0
		DIM lock[3]
		ATTACH lock[] TO fileLock[file,]
		##WHOMASK = whomask
	END IF
'
	slot = -1
	overlap = $$FALSE
	begin$$ = offset$$
	end$$ = offset$$ + length$$ - 1$$
	IFZ length$$ THEN end$$ = 0x7FFFFFFF					' UNIX
'	IFZ length$$ THEN end$$ = 0x7FFFFFFFFFFFFFFF	' Win32
	upper = UBOUND (fileLock[file,])
'
	FOR i = 0 TO upper
		IFZ fileLock[file,i].file THEN
			IF (slot < 0) THEN slot = i
		ELSE
			first$$ = fileLock[file,i].offset
			final$$ = first$$ + fileLock[file,i].length - 1$$
			IF (final$$ < first$$) THEN final$$ = 0x7FFFFFFF					' UNIX
'			IF (final$$ < first$$) THEN final$$ = 0x7FFFFFFFFFFFFFFF	' Win32
			IF ((begin$$ <= final$$) AND (end$$ >= first$$)) THEN INC overlap
		END IF
	NEXT i
'
' if the new section overlaps an existing section, that's an error
'
	IF overlap THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidRequest
		RETURN ($$TRUE)
	END IF
'
' lock the new section
'
	offsetLow = GLOW (begin$$)
	offsetHigh = GHIGH (begin$$)
	lengthLow = GLOW (end$$ - begin$$ + 1)
	lengthHigh = GHIGH (end$$ - begin$$ + 1)
'
' remove the following tests when UNIX supports 64-bit file pointers
'
	error = $$FALSE
	IF offsetHigh THEN error = $$TRUE
	IF lengthHigh THEN error = $$TRUE
	IF (offsetLow < 0) THEN error = $$TRUE
	IF (lengthLow < 0) THEN error = $$TRUE
	IF (offsetLow > 0x7FFFFFFF) THEN error = $$TRUE
	IF (lengthLow > 0x7FFFFFFF) THEN error = $$TRUE
'
	IF error THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidRequest
		RETURN ($$TRUE)
	END IF
'
' tell UNIX to lock the file
'
	flock.l_type = $$F_WRLCK				' request exclusive lock ???
	flock.l_whence = $$SEEK_SET			' offset from start of file
	flock.l_start = offsetLow				' first byte to lock
	flock.l_len = lengthLow					' # of bytes to lock
	flock.l_sysid = 0								' not required for F_SETLK
	flock.l_pid = 0									' not required for F_SETLK
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = fcntl (sfile, $$F_SETLK, &flock)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	IF (slot < 0) THEN
		##WHOMASK = 0
		slot = upper + 1
		upper = upper + 4
		ATTACH fileLock[file,] TO lock[]
		REDIM lock[upper]
		ATTACH lock[] TO fileLock[file,]
		##WHOMASK = whomask
	END IF
'
' log the newly locked section
'
	fileLock[file,slot].file = file
	fileLock[file,slot].sfile = sfile
	fileLock[file,slot].offset = offset$$
	fileLock[file,slot].length = length$$
	fileLock[file,slot].end = end$$
END FUNCTION
'
'
' #################################
' #####  XstMakeDirectory ()  #####
' #################################
'
FUNCTION  XstMakeDirectory (directory$)
	EXTERNAL  errno
'
	IFZ directory$ THEN
		##ERROR = ($$ErrorObjectDirectory << 8) OR $$ErrorNatureInvalidName
		RETURN ($$TRUE)
	END IF
'
	dir$ = XstPathString$ (@directory$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = mkdir (&dir$, 0x1FF)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ###############################
' #####  XstPathString$ ()  #####
' ###############################
'
FUNCTION  XstPathString$ (path$)
	SHARED  UBYTE  charsetFilename[]
	SHARED  UBYTE  charsetFilenameFirstLast[]
'
	IFZ charsetFilename[] THEN GOSUB Initialize
'
	IFZ path$ THEN RETURN ("")
'
	upper = UBOUND (path$)
	name$ = NULL$ (upper+1)
'
	first = 0
	DO UNTIL charsetFilenameFirstLast[path${first}]
		INC first
	LOOP UNTIL (first > upper)
'
	IF (first > upper) THEN RETURN ("")
'
	final = first + 1
	IF (first < upper) THEN
		DO WHILE charsetFilename[path${final}]
			INC final
		LOOP UNTIL (final > upper)
	END IF
'
	DO WHILE (final > first)
		DEC final
	LOOP UNTIL charsetFilenameFirstLast[path${final}]
'
	length = final - first + 1
	p$ = NULL$ (length)
'
	FOR i = 0 TO length-1
		p${i} = charsetFilename[path${first}]
		INC first
	NEXT i
'
	term$ = $$PathSlash$ + "$"
	total = LEN (p$)
	offset = 0
	DO
		first = INSTR (p$, "$", offset+1)								' $NAME or $(NAME) form
		IFZ first THEN EXIT DO
		IF (p${first} = '(') THEN												' $(NAME) form probably
			after = INSTR (p$, ")", first+2)							' find ) name terminator
			IFZ after THEN EXIT DO												' $( without ) - ignore
			offset = after																' move past $NAME
			variable$ = MID$ (p$, first+2, after-first-2)	' environment variable
			IFZ variable$ THEN DO LOOP										' ignore $()
		ELSE																						' $NAME form
			after = INCHR (p$, term$, first+1)						' find / or $ to terminate name
      IFZ after THEN after = LEN (p$) + 1					' $NAME past end of string
			offset = after																' move past $NAME
			variable$ = MID$ (p$, first+1, after-first-1)	' environment variable
			IFZ variable$ THEN DO LOOP										' ignore $/
			DEC after
		END IF
		XstGetEnvironmentVariable (@variable$, @value$)
		IFZ value$ THEN DO LOOP
		a$ = LEFT$ (p$, first-1)
		c$ = MID$ (p$, after+1)
		p$ = a$ + value$ + c$
		total = LEN (p$)
		offset = LEN (a$) + LEN (value$)
	LOOP WHILE (offset < total)
'
' process "/./" (nop)
'
	nop$ = $$PathSlash$ + "." + $$PathSlash$
	DO
		nop = INSTR (p$, nop$)
		IF nop THEN p$ = LEFT$(p$,nop) + MID$(p$,nop+3)		' "/./" to "/"
	LOOP WHILE nop
'
' process "/../" (parent)
'
	parent$ = $$PathSlash$ + ".." + $$PathSlash$
	DO
		parent = INSTR (p$, parent$)
		IF parent THEN
			IF (parent = 1) THEN
				p$ = MID$ (p$, 4)																	' path starts "/../"  - change to "/"
			ELSE
				slash = RINSTR (p$, $$PathSlash$, parent-1)				' find / before "/../"
				p$ = LEFT$ (p$, slash) + MID$ (p$, parent + 4)		' remove parent directory
			END IF
		END IF
	LOOP WHILE parent
'
'	a$ = "<" + path$ + "> <" + p$ + ">\n"
'	write (1, &a$, LEN(a$))
'
	RETURN (p$)
'
'
' *****  Initialize  *****
'
SUB Initialize
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
'
	DIM charsetFilename[255]
	DIM charsetFilenameFirstLast[255]
'
	FOR i = 0x21 TO 0x7F
		charsetFilename[i] = i
		charsetFilenameFirstLast[i] = i
	NEXT i
'
'	charsetFilename['/'] = charsetFilename['\\']		' windows
	charsetFilename['\\'] = charsetFilename['/']		' unix
	charsetFilename['`'] = 0
	charsetFilename['!'] = 0
	charsetFilename['"'] = 0
	charsetFilename['<'] = 0
	charsetFilename['>'] = 0
'	charsetFilename[':'] = 0
	charsetFilename['|'] = 0
'	charsetFilenameFirstLast['/'] = '\\'	' path separator character (windows)
	charsetFilenameFirstLast['\\'] = '/'	' path separator character (unix)
	charsetFilenameFirstLast[' '] = 0			' no leading/trailing spaces
	charsetFilenameFirstLast['`'] = 0			' no leading/trailing "`"
	charsetFilenameFirstLast['!'] = 0			' no leading/trailing "!"
	charsetFilenameFirstLast['"'] = 0			' no leading/trailing """
	charsetFilenameFirstLast['<'] = 0			' no leading/trailing "<"
	charsetFilenameFirstLast['>'] = 0			' no leading/trailing ">"
'	charsetFilenameFirstLast[':'] = 0			' no leading/trailing ":"
	charsetFilenameFirstLast['|'] = 0			' no leading/trailing "|"
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ######################################
' #####  XstPathToAbsolutePath ()  #####
' ######################################
'
FUNCTION  XstPathToAbsolutePath (ipath$, opath$)
'
	opath$ = ""
	opath$ = XstPathString$ (@ipath$)
'
' if relative path, prepend working directory
'
	IFZ opath$ THEN
		XstGetCurrentDirectory (@opath$)
	ELSE
		IF (opath${0} = '.') THEN
			IF (opath${1} = $$PathSlash) THEN opath$ = MID$(opath$, 3)
		END IF
		IF (opath${0} != $$PathSlash) THEN
			XstGetCurrentDirectory (@dir$)
			opath$ = dir$ + $$PathSlash$ + opath$
		END IF
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
	EXTERNAL  errno
'
	IFZ o$ THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		RETURN ($$TRUE)
	END IF
'
	IFZ n$ THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		RETURN ($$TRUE)
	END IF
'
	old$ = XstPathString$ (@o$)
	new$ = XstPathString$ (@n$)
	IF (old$ = new$) THEN RETURN ($$FALSE)
'
	XstGetFileAttributes (@old$, @attributes)			' Does file exist?
	IFZ attributes THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		RETURN ($$TRUE)
	END IF
'
	XstGetFileAttributes (@new$, @attributes)			' Does file exist?
	IF attributes THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureExists
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = rename (&old$, &new$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ##############################
' #####  XstSaveString ()  #####
' ##############################
'
FUNCTION  XstSaveString (file$, text$)
'
	##ERROR = $$FALSE
	f$ = XstPathString$ (@file$)
'
	ofile = OPEN (f$, $$WRNEW)
	IF ##ERROR THEN RETURN ($$TRUE)
	IF (ofile < 0) THEN RETURN ($$TRUE)							' ##ERROR set
	IF text$ THEN WRITE [ofile], text$
	CLOSE (ofile)
END FUNCTION
'
'
' ###################################
' #####  XstSaveStringArray ()  #####
' ###################################
'
FUNCTION  XstSaveStringArray (file$, text$[])
'
	##ERROR = $$FALSE
	f$ = XstPathString$ (@file$)
'
	ofile = OPEN (f$, $$WRNEW)
	IF ##ERROR THEN RETURN ($$TRUE)
	IF (ofile < 0) THEN RETURN ($$TRUE)
	IF text$[] THEN
		XstStringArrayToString (@text$[], @text$)
		IF text$ THEN WRITE [ofile], text$
	END IF
	CLOSE (ofile)
END FUNCTION
'
'
' #######################################
' #####  XstSaveStringArrayCRLF ()  #####
' #######################################
'
FUNCTION  XstSaveStringArrayCRLF (file$, text$[])
'
	##ERROR = $$FALSE
	f$ = XstPathString$ (@file$)
'
	ofile = OPEN (f$, $$WRNEW)
	IF ##ERROR THEN RETURN ($$TRUE)
	IF (ofile < 0) THEN RETURN ($$TRUE)
	IF text$[] THEN
		XstStringArrayToStringCRLF (@text$[], @text$)
		IF text$ THEN WRITE [ofile], text$
	END IF
	CLOSE (ofile)
END FUNCTION
'
'
' #######################################
' #####  XstSetCurrentDirectory ()  #####
' #######################################
'
FUNCTION  XstSetCurrentDirectory (newDirectory$)
	EXTERNAL  errno
'
	IFZ newDirectory$ THEN RETURN ($$FALSE)						' No change
	dir$ = XstPathString$ (@newDirectory$)
'
'	XstLog ("XstSetCurrentDirectory().A : " + dir$)
	XstGetCurrentDirectory (@pwd$)
'	XstLog ("XstSetCurrentDirectory().B : " + pwd$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = chdir (&dir$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	XstGetCurrentDirectory (@cur$)
'	XstLog ("XstSetCurrentDirectory().C : " + dir$ + " : " + STRING$(error) + " : " + STRING$(errno))
'	XstLog ("XstSetCurrentDirectory().D : " + pwd$)
'	XstLog ("XstSetCurrentDirectory().E : " + cur$)
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' #####################################
' #####  XstUnlockFileSection ()  #####
' #####################################
'
FUNCTION  XstUnlockFileSection (file, mode, offset$$, length$$)
	EXTERNAL  errno
	SHARED  LOCK  fileLock[]
	SHARED  FILE  fileInfo[]
	AUTOX  UFLOCK  flock
	AUTOX  LOCK  lock[]
'
	whomask = ##WHOMASK
'
	IF (file <= 2) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalid
		RETURN ($$TRUE)
	END IF
'
	upper = UBOUND (fileInfo[])
	IF (file > upper) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		RETURN ($$TRUE)
	END IF
'
	IF (offset$$ < 0) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
	IF (length$$ < 0) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
' remove the following two tests when UNIX supports 64-bit file pointers
'
	IF (offset$$ > 0x7FFFFFFF) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
	IF (length$$ > 0x7FFFFFFF) THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidValue
		RETURN ($$TRUE)
	END IF
'
	sfile = fileInfo[file].fileHandle
'
	IF (sfile <= 0) THEN
		##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		RETURN ($$TRUE)
	END IF
'
	IFZ fileLock[] THEN
		##WHOMASK = 0
		upper = (file + 16) OR 0x000F
		DIM fileLock[upper,]
		##WHOMASK = whomask
	END IF
'
	upper = UBOUND (fileLock[])
	IF (upper < file) THEN
		##WHOMASK = 0
		upper = (file + 16) OR 0x000F
		REDIM fileLock[upper,]
		##WHOMASK = whomask
	END IF
'
	IFZ fileLock[file,] THEN
		##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
		RETURN ($$TRUE)
	END IF
'
	slot = -1
	begin$$ = offset$$
	end$$ = offset$$ + length$$ - 1$$
	IFZ length$$ THEN end$$ = 0x7FFFFFFF						' UNIX
'	IFZ length$$ THEN end$$ = 0x7FFFFFFFFFFFFFFF		' Win32
	upper = UBOUND (fileLock[file,])
'
	found = $$FALSE
	FOR i = 0 TO upper
		IF fileLock[file,i].file THEN
			IF fileLock[file,i].sfile THEN
				IF (offset$$ = fileLock[file,i].offset) THEN
					IF (length$$ = fileLock[file,i].length) THEN
						found = $$TRUE
						EXIT FOR
					END IF
				END IF
			END IF
		END IF
	NEXT i
'
' if specified section not found in lock list
'
	IFZ found THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidRequest
		RETURN ($$TRUE)
	END IF
'
' found the specified locked section - unlock it
'
	begin$$ = offset$$
	end$$ = fileLock[file,i].end
	offsetLow = GLOW (begin$$)
	offsetHigh = GHIGH (begin$$)
	lengthLow = GLOW (end$$ - begin$$ + 1)
	lengthHigh = GHIGH (end$$ - begin$$ + 1)
'
' remove the following tests when UNIX supports 64-bit file pointers
'
	error = $$FALSE
	IF offsetHigh THEN error = $$TRUE
	IF lengthHigh THEN error = $$TRUE
	IF (offsetLow < 0) THEN error = $$TRUE
	IF (lengthLow < 0) THEN error = $$TRUE
	IF (offsetLow > 0x7FFFFFFF) THEN error = $$TRUE
	IF (lengthLow > 0x7FFFFFFF) THEN error = $$TRUE
'
	IF error THEN
		##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidRequest
		RETURN ($$TRUE)
	END IF
'
' tell UNIX to unlock the file
'
	flock.l_type = $$F_UNLCK				' unlock the file section
	flock.l_whence = $$SEEK_SET			' offset from start of file
	flock.l_start = offsetLow				' first byte to lock
	flock.l_len = lengthLow					' # of bytes to lock
	flock.l_sysid = 0								' not required for F_SETLK
	flock.l_pid = 0									' not required for F_SETLK
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = fcntl (sfile, $$F_SETLK, &flock)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	fileLock[file,i].file = 0
	fileLock[file,i].sfile = 0
	fileLock[file,i].offset = 0
	fileLock[file,i].length = 0
	fileLock[file,i].end = 0
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
' Convert string with unprintable bytes (0x00 - 0x1F and 0x80 - 0xFF)
' into a string with all unprintable bytes converted into C compatible
' backslash sequences that should be interpretable by C compilers and
' a majority of assemblers that accept C style literal strings.
'
' NOTE:  0x22 converted to \"
' NOTE:  0x5C converted to \\
' NOTE:  0x00 - 0x06 converted to \xHH form
' NOTE:  0x07 - 0x0D converted to \a  \b  \t  \n  \v  \f  \r
' NOTE:  0x0E - 0x1F converted to \xHH form
' NOTE:  0x7F - 0xFF converted to \xHH form
'
'	NOTE:  newlines are also converted
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
'	Like XstBinStringToBackString$() except do not
'	convert newlines (don't convert 10 to \n).
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
FUNCTION  XstCopyArray (sss[], ddd[])
	UBYTE  temp[]
'
	DIM ddd[]																			' empty copy = default
	IFZ sss[] THEN RETURN ($$FALSE)								' empty source and copy
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
'
	IF bytes THEN PRINT "XstCopyBytes() : Up1 : error : (final bytes != 0) : "; bytes
END SUB
END FUNCTION
'
'
' ###############################
' #####  XstDeleteLines ()  #####
' ###############################
'
FUNCTION  XstDeleteLines (array$[], start, count)
	IFZ array$[] THEN RETURN
	upper = UBOUND(array$[])
	IF (start > upper) THEN RETURN
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
' *****  OneLineForward  *****
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
' *****  MultiLineForward  *****
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
' ****  MultiLineReverse  *****
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
FUNCTION  XstMultiStringToStringArray (s$, s$[])
'
	DIM s$[]
	IFZ s$ THEN RETURN
'
	lenString = LEN (s$)
	uString = (lenString >> 5) OR 7								' guess 32 chars/line
	DIM s$[uString]
'
	line			= 0
	firstChar	= 0
	DO
		cr = INSTR (s$, "\r", firstChar + 1)		' next return char
		nl = INSTR (s$, "\n", firstChar + 1)		' next newline char
		IF cr THEN															' found \r
			IF nl THEN														' found \n
				IF (nl < cr) THEN
					cr = nl														' \n before \r
				ELSE
					IF (nl > (cr+1)) THEN nl = cr			' \n in later line
				END IF
			ELSE
				nl = cr															' \r without \n
			END IF
		ELSE
			IF nl THEN cr = nl										' \n without \r
		END IF
		IFZ (cr OR nl) THEN											' no \r or \n = last line
			cr = lenString + 1										' fake \r after string
			nl = lenString + 1										' fake \n after string
			GOSUB AddLine													' add rest of string
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
'		cr				= index (from 1) of return (CR)
'   nl				= index (from 1) of newline (NL = LF)
'
SUB AddLine
	chars = cr - firstChar - 1			' up to first newline char (\r or \n)
	IF chars THEN
		line$ = NULL$ (chars)
		FOR i = 0 TO chars - 1
			line${i} = s${firstChar + i}
		NEXT i
		ATTACH line$ TO s$[line]
	END IF
	firstChar = nl									' to \r or \n  (last char in newline)
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
	FOR i = startOffset TO offset - 1			' don't include the terminator
		nextWord${dest} = UBYTEAT(sourceAddr, i)
		INC dest
	NEXT i
	index = offset + 1										' index = INDEX of terminator
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
'
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
	INC offset															' bump offset past terminator
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
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
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
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' #############################
' #####  XstNextLine$ ()  #####
' #############################
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
' ################################
' #####  XstReplaceArray ()  #####
' ################################
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
' ****  OneLineOneLine  *****
'
SUB OneLineOneLine
	text$ = text$[line]
	lenFind = LEN(find$)
	text$[line] = LEFT$(text$,pos) + replace$ + MID$(text$, pos+1+lenFind)
END SUB
'
'
' ****  OneLineMultiLine  *****  replace part or all of one line with more than one line
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
	IFZ lastLine THEN						' Separate case for simpler logic below
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
	firstChar	= 0
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
'	Add next s$ line to array--don't include newLine (or CR)
'		firstChar	= offset (from 0) of first character on this line
'		nl				= index (from 1) of newLine (LF)
'
SUB AddLine
	chars = nl - firstChar - 1
	IF (nl > 1) THEN
		IF (s${nl - 2} = '\r') THEN DEC chars				' skip CR
	END IF
	IF chars THEN
		line$ = NULL$(chars)
		FOR i = 0 TO chars - 1
			line${i} = s${firstChar + i}
		NEXT i
		ATTACH line$ TO s$[line]
	END IF
	firstChar = nl
	INC line
	IF (line > uString) THEN
		uString = (uString + (uString >> 1)) OR 7
		REDIM s$[uString]
	END IF
END SUB
END FUNCTION
'
'
' #########################
' #####  XstLTRIM ()  #####
' #########################

FUNCTION  XstLTRIM (@string$, array[])
'
	IFZ string$ THEN RETURN
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
		CASE ELSE	: ##ERROR = ($$ErrorObjectFunction << 8) OR $$ErrorNatureInvalidArgument
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
			##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidType
			RETURN ($$TRUE)
		END IF
		IF (bt != $$STRING) THEN
			##ERROR = ($$ErrorObjectArgument << 8) OR $$ErrorNatureInvalidType
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
'		$$TRUE		= error (##ERROR set)
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
	uA = UBOUND (a[])
	IF (high > uA) THEN RETURN ($$TRUE)
'
	theType = TYPE (a[])
	SELECT CASE theType
		CASE $$SBYTE, $$UBYTE, $$SSHORT, $$USHORT, $$SLONG, $$ULONG, $$XLONG
		CASE $$GIANT, $$SINGLE, $$DOUBLE, $$STRING
		CASE ELSE
					##ERROR = ($$ErrorObjectArray << 8) OR $$ErrorNatureInvalidType
					RETURN ($$TRUE)
	END SELECT
'
	IF n[] THEN
		DIM n[uA]
		FOR i = 0 TO uA
			n[i] = i
		NEXT i
	END IF
	IF high <= low THEN RETURN
'
	SELECT CASE theType
		CASE $$SLONG, $$XLONG
					XstQuickSort_XLONG (@a[], @n[], low, high, mode)
		CASE $$STRING
'					ATTACH a[] TO a$[]
'					XstQuickSort_STRING (@a$[], @n[], low, high, mode)
'					ATTACH a$[] TO a[]
'
' #####  v6.0010 : the following is taken from Window XBasic
'
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
' ###############################
' #####  XxxXstBlowback ()  #####
' ###############################
'
FUNCTION  XxxXstBlowback ()
	SHARED  TIMER  timer[]
	SHARED  userProgram$
'
	userProgram$ = ""
'
	FOR i = 0 TO UBOUND (timer[])
		IF timer[i].timer THEN
			IF timer[i].whomask THEN XstKillTimer (i)
		END IF
	NEXT i
END FUNCTION
'
'
' ##################################
' #####  XxxXstFreeLibrary ()  #####
' ##################################
'
FUNCTION  XxxXstFreeLibrary (lib$, handle)
	SHARED  libraryName$[]
	SHARED  libraryHandle[]
'
' not yet implemented on UNIX  -  need ELF for true DLLs
'
'	IFZ libraryName$[] THEN RETURN
'	upper = UBOUND (libraryName$[])
'
'	FOR i = 0 TO upper
'		name$ = libraryName$[i]
'		hand = libraryHandle[i]
'		free = $$FALSE
'		IF name$ THEN
'			IF hand THEN
'				SELECT CASE TRUE
'					CASE (handle = -1)		:	free = $$TRUE
'					CASE (handle = hand)	:	free = $$TRUE
'					CASE (lib$ = name$)		:	free = $$TRUE
'				END SELECT
'			END IF
'		END IF
'		IF free THEN
'			FreeLibrary (hand)
'			libraryName$[i] = ""
'			libraryHandle[i] = 0
'		END IF
'	NEXT i
END FUNCTION
'
'
' ##################################
' #####  XxxXstLoadLibrary ()  #####
' ##################################
'
FUNCTION  XxxXstLoadLibrary (lib$)
	SHARED  libraryName$[]
	SHARED  libraryHandle[]
'
' not yet implemented on UNIX  -  need ELF for true DLLs
'
'	whomask = ##WHOMASK
'	IFZ lib$ THEN RETURN
'
'	upper = UBOUND (lib$)
'	IF (lib${upper} = '"') THEN lib$ = RCLIP$ (lib$,1)
'	IF (lib${0} = '"') THEN lib$ = LCLIP$ (lib$,1)
'
'	IFZ libraryName$[] THEN GOSUB Initialize
'	upper = UBOUND (libraryName$[])
'	handle = 0
'	slot = -1
'
'	FOR i = 0 TO upper
'		name$ = libraryName$[i]
'		hand = libraryHandle[i]
'		IF (slot < 0) THEN
'			IFZ name$ THEN slot = i : hand = 0
'			IFZ hand THEN slot = i : name$ = ""
'		END IF
'		IFZ handle THEN
'			IF name$ THEN
'				IF hand THEN
'					IF (lib$ = name$) THEN handle = hand
'				END IF
'			END IF
'		END IF
'	NEXT i
'
'	IF handle THEN RETURN (handle)
'
'	handle = LoadLibraryA (&lib$)		' returns 0 when fails
'
'	IF handle THEN
'		IF (slot < 0) THEN
'			##WHOMASK = 0
'			slot = upper + 1
'			upper = upper + 16
'			REDIM libraryName$[upper]
'			REDIM libraryHandle[upper]
'			##WHOMASK = whomask
'		END IF
'		##WHOMASK = 0
'		libraryName$[slot] = lib$
'		libraryHandle[slot] = handle
'		##WHOMASK = whomask
'	END IF
'
'	RETURN (handle)
'
'
' *****  Initialize  *****
'
SUB Initialize
'	##WHOMASK = 0
'	DIM libraryName$[15]
'	DIM libraryHandle[15]
'	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ############################
' #####  XxxXstTimer ()  #####
' ############################
'
' routine is complicated by the fact that two different
' ways of keeping time: UITIMERVAL is a timer interval,
' and UTIMEB is time since 00:00:00 on 1 Jan 1970.
'
' commands	:	$$TimerStart	: XstStartTimer()
'							$$TimerExpire	: PDE received alarm signal
'							$$TimerKill		: XstKillTimer()
'
FUNCTION  XxxXstTimer (command, timer, count, msec, func)
	EXTERNAL  errno
	SHARED  sleepUser
	SHARED  sleepSystem
	SHARED  UTIMEB  startTime
	STATIC  UITIMERVAL  itimer
	STATIC  UITIMERVAL  otimer
	STATIC  TIMER  timer[]
	STATIC  TIMER  ztimer
	STATIC  unique
	AUTOX  UTIMEB  nowTime
	AUTOX  FUNCADDR  call (XLONG, XLONG, XLONG, XLONG)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	log = ##DEBUG OR $$DebugTimer
'
' initialize timer array if necessary
'
	IFZ timer[] THEN
		##WHOMASK = 0
		DIM timer[15]
		##WHOMASK = whomask
	END IF
	upper = UBOUND (timer[])					' upper bound of timer[]
'
' get zero reference time for free-running millisecond system timer
'
	IFZ startTime.time THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		ftime (&startTime)
		##WHOMASK = whomask
		##LOCKOUT = lockout
	END IF
'
' get current time
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	ftime (&nowTime)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
' "nsec" and "nusec" are the current system time from ftime()
'
	nsec = nowTime.time								' current time - seconds
	nusec = nowTime.millitm * 1000		' current time - microseconds
'
	IF (nsec < 0) THEN nsec = nsec + 0x7FFFFFFF
	IF (nusec < 0) THEN nusec = 0
	IF (nusec > 999999) THEN
		nsec = nsec + 1
		nusec = 0
	END IF
'
' process the command
'
	SELECT CASE command
		CASE $$TimerExpire	: GOSUB TimerExpire
		CASE $$TimerStart		: GOSUB TimerStart
		CASE $$TimerKill		: GOSUB TimerKill
		CASE ELSE						: PRINT "XxxXstTimer() : error : unknown command : "; command
	END SELECT
	RETURN (return)
'
'
' *****  TimerStart  *****
'
SUB TimerStart
'	PRINT "XxxXstTimer() : TimerStart.A : "; timer;; count;; msec;; HEX$(func,8);; atimer;; active
	IFZ func THEN return = $$TRUE : EXIT SUB				' invalid func argument
	IFZ count THEN return = $$TRUE : EXIT SUB				' invalid count argument
	IF (msec <= 0) THEN return = $$TRUE : EXIT SUB	' invalid interval argument
'
' unix needs the interval in two pieces:
'  sec  : integer number of seconds
'  usec : additional microseconds
'
	sec = msec \ 1000									' integer seconds til expire
	isec = sec * 1000									' 1000 * integer seconds til expire
	usec = (msec - isec) * 1000				' additional microseconds til expire
'
' compute sec/usec of desired timeout and add new timer to timer[]
'
	GOSUB AddTimer										' add new timer to timer[]
	IF return THEN EXIT SUB						' error in AddTimer
	GOSUB StartSoonestTimer						' start soonest timer
'	PRINT "XxxXstTimer() : TimerStart.Z : "; timer;; count;; msec;; HEX$(func,8);; atimer;; active
END SUB
'
'
' *****  StartSoonestTimer  *****
'
SUB StartSoonestTimer
'	PRINT "XxxXstTimer() : StartSoonestTimer.A : "; timer;; count;; msec;; HEX$(func,8);; atimer;; active
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	getitimer ($$ITIMER_REAL, &otimer)		' get current timer value
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
' find out which timer is active and which has soonest requested timeout
'
	active = $$FALSE									' active timer #
	osec = otimer.it_value.tv_sec			' timout in seconds
	ousec = otimer.it_value.tv_usec		' timout in microseconds
	GOSUB GetSoonestTimer							' atimer = timer with soonest timeout
	IF return THEN EXIT SUB						' error in GetSoonestTimer
'
' atimer should never be zero since we just added a timer
'
	IFZ atimer THEN
		PRINT "XstStartTimer() : no active timers remain : atimer = 0 : "; atimer
		return = $$FALSE
		EXIT SUB
	END IF
'
' done if system interval timer is already running the soonest timer
'
	IF (atimer = active) THEN					' soonest = active
		IFZ timer[atimer].active THEN
			PRINT "XstStartTimer() : error : (atimer = active : .active = 0)"
			return = $$TRUE
			EXIT SUB
		END IF
		return = $$FALSE
		EXIT SUB
	END IF
'
' system interval timer should be running the active timer
'
	IF active THEN
		IFZ (osec OR ousec) THEN	' error : system timer should be running
			PRINT "XstStartTimer() : error ::: (active with no system timer)"
		END IF
	ELSE
		IF (osec OR ousec) THEN		' error : system timer should not be running
			PRINT "XstStartTimer() : error ::: (system timer with no active)"
		END IF
	END IF
'
' old active timer is no longer the active timer - new one is sooner
'
	timer[active].active = $$FALSE		' old active timer no longer active
'
' program system interval timer with new timeout interval
'
	xsec = asec - nsec								' new interval - seconds
	xusec = ausec - nusec							' new interval - microseconds
'
	IF (xusec < 0) THEN								' adjust for microseconds borrow
		xusec = xusec + 1000000					'   add a million microseconds
		xsec = xsec - 1									'   and subtract one second
	END IF
'
' don't program system timer with less than one millisecond
'
	SELECT CASE TRUE
		CASE (xsec < 0)		: xsec = 0 : xusec = 1000
		CASE (xsec = 0)		: IF (xusec < 1000) THEN xusec = 1000
	END SELECT
'
' xsec,xusec is now at least 1000 usec = 1ms
'
	itimer.it_interval.tv_sec = 0			' no reload - must handle manually
	itimer.it_interval.tv_usec = 0		' no reload - must handle manually
	itimer.it_value.tv_sec = xsec			' integer seconds until expire
	itimer.it_value.tv_usec = xusec		' additional microseconds
	timer[atimer].active = atimer			' new active timer
'
' start the new interval timer - don't really need old value back
'
'	write (1, &"i", 1)
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = setitimer ($$ITIMER_REAL, &itimer, &otimer)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'	write (1, &"j", 1)
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		XstErrorNumberToName (error, @error$)
		PRINT "XstStartTimer() : error : (setitimer() error) : "; errno;; error;; error$
		return = $$TRUE
	ELSE
		return = $$FALSE
	END IF
'	PRINT "XxxXstTimer() : StartSoonestTimer.Z : "; timer;; count;; msec;; HEX$(func,8);; atimer;; active;; xsec;; xusec
END SUB
'
'
' *****  TimerExpire  *****
'
SUB TimerExpire
'	PRINT "XxxXstTimer() : TimerExpire.A : "; timer;; atimer;; active
	active = $$FALSE									' active timer #
	GOSUB GetSoonestTimer							' atimer = timer with soonest timeout
	IF return THEN EXIT SUB						' error in GetSoonestTimer
'
' should never have timer alarm if no timer is active
'
	IFZ active THEN
		PRINT "XxxXstTimer() : error : ($$TimerExpire without active timer) : "; active
		return = $$TRUE
		EXIT SUB
	END IF
'
' should be no way the active timer isn't the timer to expire soonest
'
	IF (active != atimer) THEN
		PRINT "XxxXstTimer() : error : ($$TimerExpire with active != atimer) : "; active;; atimer
		return = $$TRUE
		EXIT SUB
	END IF
'
' active timer expired - update timer and call timer callback function
'
	timer = active
	GOSUB TimerExpired
'	PRINT "XxxXstTimer() : TimerExpire.Z : "; timer;; atimer;; active
END SUB
'
'
' *****  TimerExpired  *****
'
' active timer expired
' decrement timer count
' kill timer if count = 0
' start next soonest timer
' call timer callback function
'
SUB TimerExpired
'	PRINT "XxxXstTimer() : TimerExpired.A : "; timer;; atimer;; active
	tmsec = nowTime.millitm - startTime.millitm
	tsec = nowTime.time - startTime.time
'
	IF (tmsec < 0) THEN
		tmsec = tmsec + 1000
		tsec = tsec - 1
	END IF
'
	IF (tsec < 0) THEN
		tmsec = 1
		tsec = 0
	END IF
'
' set up timer callback arguments
'
	time = (tsec * 1000) + tmsec						' millisecond time
	count = timer[timer].count - 1					' one less timeout
	msec = timer[timer].msec								' programmed delay
	func = timer[timer].func								' callback function
	who = timer[timer].whomask							'
	call = func
'
' terminate any system/user XstSleep() in progress
'
	IFZ who THEN sleepSystem = $$FALSE ELSE sleepUser = $$FALSE
'
'	call the expired timer callback function - !!!!! timer whomask !!!!!
'
'	PRINT "XxxXstTimer() : TimerExpired.B : "; timer;; atimer;; active
'
'	write (1, &"A", 1)
	uuu = timer[timer].timer
	##WHOMASK = who
	##LOCKOUT = $$TRUE
	@call (timer, @count, msec, time)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'	write (1, &"B", 1)
'	PRINT "XxxXstTimer() : TimerExpired.C : "; timer;; atimer;; active
'
' (count <= 0) : kill expired timer
' (count > 0) : update expired timer with new count and next expire time
'
	IF (uuu = timer[timer].timer) THEN	' timer not killed by called func
'		write (1, &"C", 1)
		IF (count <= 0) THEN
'			write (1, &"D", 1)
			timer[timer] = ztimer						' kill timer
		ELSE
'			write (1, &"E", 1)
			sec = msec \ 1000								' integer seconds of interval
			isec = sec * 1000								' 1000 * integer seconds of interval
			usec = (msec - isec) * 1000			' additional microseconds of interval
'
			xsec = sec + nsec								' time to expire next - seconds
			xusec = usec + nusec						' time to expire next - microseconds
			IF (xusec >= 1000000) THEN			' 1 million microseconds = 1 second
				xusec = xusec - 1000000				' subtract 1 million microseconds
				xsec = xsec + 1								' and add 1 second
			END IF
'
			timer[timer].count = count			' decremented or updated count
			timer[timer].sec = xsec					' time to expire next - seconds
			timer[timer].usec = xusec				' time to expire next - microseconds
			timer[timer].active = $$FALSE		' no longer active - find another
		END IF
	END IF
'	write (1, &"F", 1)
'
' start soonest timer
'
	GOSUB GetSoonestTimer
	IF return THEN EXIT SUB
	IF atimer THEN GOSUB StartSoonestTimer
'	PRINT "XxxXstTimer() : TimerExpired.Z : "; timer;; atimer;; active
'	write (1, &"Z\n", 1)
END SUB
'
'
' *****  TimerKill  *****
'
SUB TimerKill
'	PRINT "XxxXstTimer().A : TimerKill : "; timer
	IF (timer <= 0) THEN
		PRINT "XxxXstTimer() : error : invalid timer : (timer <= 0) : "; timer
		return = $$TRUE
		EXIT SUB
	END IF
'
	IF (timer > upper) THEN
		PRINT "XxxXstTimer() : error : invalid timer : (timer > upper) : "; timer
		return = $$TRUE
		EXIT SUB
	END IF
'
	IFZ timer[timer].active THEN		' done if timer is not active timer
		timer[timer] = ztimer						' kill the timer
		return = $$FALSE
		EXIT SUB
	END IF
'
' cancel the system interval timer if timer was the active timer
'
	timer[timer] = ztimer							' kill the timer
	itimer.it_interval.tv_sec = 0			' no reload - must handle manually
	itimer.it_interval.tv_usec = 0		' no reload - must handle manually
	itimer.it_value.tv_sec = 0				' integer seconds until expire
	itimer.it_value.tv_usec = 0				' additional microseconds
'
' cancel the system interval timer
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	error = setitimer ($$ITIMER_REAL, &itimer, &otimer)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF error THEN
		XstSystemErrorToError (errno, @error)
		XstErrorNumberToName (error, @error$)
		PRINT "XstStartTimer() : error : (setitimer() error) : "; errno;; error;; error$
		return = $$TRUE
	ELSE
		return = $$FALSE
	END IF
'
' next timer to start is the soonest timer
'
	GOSUB GetSoonestTimer
'	PRINT "XxxXstTimer().Z : TimerKill : "; timer
END SUB
'
'
' *****  AddTimer  *****  enter with expire interval in "sec", "usec"
'
SUB AddTimer
'	PRINT "XxxXstTimer() : AddTimer.A : "; timer;; count;; msec;; HEX$(func,8);; sec;; usec
	FOR timer = 1 TO upper
		IFZ timer[timer].timer THEN EXIT FOR
	NEXT timer
'
	IF (timer > upper) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		upper = upper + 16
		REDIM timer[upper]
		##LOCKOUT = $$FALSE
		##WHOMASK = whomask
	END IF
'
	xusec = nusec + usec							' expire time - microseconds
	xsec = nsec + sec									' expire time - seconds
	IF (xusec > 1000000) THEN					' 1 million microseconds = 1 second
		xusec = xusec - 1000000					' remove 1 million microseconds
		xsec = xsec + 1									' add 1 second
	END IF
'
' set the new interval timer info
'
	INC unique
	timer[timer].timer = unique				' enables timer
	timer[timer].count = count				' # of timeouts desired
	timer[timer].func = func					' timer callback function
	timer[timer].msec = msec					' timer interval in milliseconds
	timer[timer].sec = xsec						' ftime() expire time seconds
	timer[timer].usec = xusec					' ftime() expire time microseconds
	timer[timer].active = $$FALSE			' not yet the running timer
	timer[timer].whomask = whomask		' whomask of timer owner
'	PRINT "XxxXstTimer() : AddTimer.Z : "; timer;; count;; msec;; HEX$(func,8);; sec;; usec
END SUB
'
'
' *****  GetSoonestTimer  *****  !!! DO NOT CHANGE VARIABLE "timer" !!!
'
SUB GetSoonestTimer
'	PRINT "XxxXstTimer() : GetSoonestTimer.A : "; timer;; atimer;; active
	asec = 0
	ausec = 0
	atimer = 0
	active = $$FALSE
	FOR qtimer = 1 TO upper
		IF timer[qtimer].timer THEN
			IF timer[qtimer].active THEN active = qtimer
			qusec = timer[qtimer].usec
			qsec = timer[qtimer].sec
			IF (qsec OR qusec) THEN
				IFZ atimer THEN													' soonest
					asec = qsec
					ausec = qusec
					atimer = qtimer
				ELSE
					SELECT CASE TRUE
						CASE (qsec < asec)									' new soonest
									asec = qsec
									ausec = qusec
									atimer = qtimer
						CASE (qsec = asec)									' maybe new soonest
									SELECT CASE TRUE
										CASE (qusec < ausec)				' new soonest
													atimer = qtimer
													ausec = qusec
													asec = qsec
										CASE (qusec = ausec)				' tie - choose active
													IF (active != atimer) THEN
														atimer = qtimer
														ausec = qusec
														asec = qsec
													END IF
									END SELECT
					END SELECT
				END IF
			END IF
		END IF
	NEXT qtimer
'	PRINT "XxxXstTimer() : GetSoonestTimer.Z : "; timer;; atimer;; active
END SUB
END FUNCTION
'
'
' ##########################
' #####  XxxXstLog ()  #####
' ##########################
'
FUNCTION  XxxXstLog (text$)
'
	IFZ text$ THEN RETURN ($$FALSE)
'
	bytes = LEN (text$)
	write (1, &text$, bytes)						' print text$ on UNIX console
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
	SHARED	exception$[]
	SHARED	sysException$[]
	SHARED	errorObject$[]
	SHARED	errorNature$[]
	SHARED  sysSaveNewline
	SHARED  sysPasteNewline
	SHARED  userSaveNewline
	SHARED  userPasteNewline
'
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
'
	DIM charsetBackslash[255]
	DIM charsetBackslashChar[255]
	DIM charsetHexLowerToUpper[255]
	DIM charsetNormalChar[255]
	DIM charsetUpperToLower[255]
	DIM exception$[31]
	DIM sysException$[63]
	DIM errorObject$[255]
	DIM errorNature$[255]
	DIM #OSERROR$[$$ERROR_LAST_OS_ERROR]
	DIM #OSTOXERROR[$$ERROR_LAST_OS_ERROR]
'
	sysSaveNewline = $$NewlineDefault
	sysPasteNewline = $$NewlineDefault
	userSaveNewline = $$NewlineDefault
	userPasteNewline = $$NewlineDefault
'
	XstGetEnvironmentVariables (@count, @var$[])	' initialize envp, envp$[]
	XstGetOSName (os$)
	linux = INSTRI (os$, "linux")
	unix = INSTRI (os$, "unix")
'
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
'
'
' ***********************************************
' *****  Initialize Native Exception Names  *****
' ***********************************************
'
	exception$ [ $$ExceptionNone                   ] = "$$ExceptionNone"
	exception$ [ $$ExceptionSegmentViolation       ] = "$$ExceptionSegmentViolation"
	exception$ [ $$ExceptionOutOfBounds            ] = "$$ExceptionOutOfBounds"
	exception$ [ $$ExceptionBreakpoint             ] = "$$ExceptionBreakpoint"
	exception$ [ $$ExceptionBreakKey               ] = "$$ExceptionBreakKey"
	exception$ [ $$ExceptionAlignment              ] = "$$ExceptionAlignment"
	exception$ [ $$ExceptionDenormal               ] = "$$ExceptionDenormal"
	exception$ [ $$ExceptionDivideByZero           ] = "$$ExceptionDivideByZero"
	exception$ [ $$ExceptionInvalidOperation       ] = "$$ExceptionInvalidOperation"
	exception$ [ $$ExceptionOverflow               ] = "$$ExceptionOverflow"
	exception$ [ $$ExceptionStackCheck             ] = "$$ExceptionStackCheck"
	exception$ [ $$ExceptionUnderflow              ] = "$$ExceptionUnderflow"
	exception$ [ $$ExceptionInvalidInstruction     ] = "$$ExceptionInvalidInstrunction"
	exception$ [ $$ExceptionPrivilege              ] = "$$ExceptionPrivilege"
	exception$ [ $$ExceptionStackOverflow          ] = "$$ExceptionStackOverflow"
	exception$ [ $$ExceptionReserved               ] = "$$ExceptionReserved"
	exception$ [ $$ExceptionTimer                  ] = "$$ExceptionTimer"
	exception$ [ $$ExceptionUnknown                ] = "$$ExceptionUnknown"
	exception$ [ $$ExceptionUpper                  ] = "$$ExceptionUpper"
'
' ***********************************************
' *****  Initialize System Exception Names  *****
' ***********************************************
'
	sysException$ [ $$SIGNONE    ] = "$$SIGNONE"
	sysException$ [ $$SIGHUP     ] = "$$SIGHUP"
	sysException$ [ $$SIGINT     ] = "$$SIGINT"
	sysException$ [ $$SIGQUIT    ] = "$$SIGQUIT"
	sysException$ [ $$SIGILL     ] = "$$SIGILL"
	sysException$ [ $$SIGTRAP    ] = "$$SIGTRAP"
	sysException$ [ $$SIGABRT    ] = "$$SIGABRT"
	sysException$ [ $$SIGIOT     ] = "$$SIGIOT"
	sysException$ [ $$SIGBUS     ] = "$$SIGBUS"
	sysException$ [ $$SIGFPE     ] = "$$SIGFPE"
	sysException$ [ $$SIGKILL    ] = "$$SIGKILL"
	sysException$ [ $$SIGUSR1    ] = "$$SIGUSR1"
	sysException$ [ $$SIGSEGV    ] = "$$SIGSEGV"
	sysException$ [ $$SIGUSR2    ] = "$$SIGUSR2"
	sysException$ [ $$SIGPIPE    ] = "$$SIGPIPE"
	sysException$ [ $$SIGALRM    ] = "$$SIGALRM"
	sysException$ [ $$SIGTERM    ] = "$$SIGTERM"
	sysException$ [ $$SIGSTKFLT  ] = "$$SIGSTKFLT"
	sysException$ [ $$SIGCHLD    ] = "$$SIGCHLD"
	sysException$ [ $$SIGCONT    ] = "$$SIGCONT"
	sysException$ [ $$SIGSTOP    ] = "$$SIGSTOP"
	sysException$ [ $$SIGTSTP    ] = "$$SIGTSTP"
	sysException$ [ $$SIGTTIN    ] = "$$SIGTTIN"
	sysException$ [ $$SIGTTOU    ] = "$$SIGTTOU"
	sysException$ [ $$SIGURG     ] = "$$SIGURG"
	sysException$ [ $$SIGXCPU    ] = "$$SIGXCPU"
	sysException$ [ $$SIGXFSZ    ] = "$$SIGXFSZ"
	sysException$ [ $$SIGVTALRM  ] = "$$SIGVTALRM"
	sysException$ [ $$SIGPROF    ] = "$$SIGPROF"
	sysException$ [ $$SIGWINCH   ] = "$$SIGWINCH"
	sysException$ [ $$SIGPOLL    ] = "$$SIGPOLL"
	sysException$ [ $$SIGPWR     ] = "$$SIGPWR"
	sysException$ [ $$SIGUNUSED  ] = "$$SIGUNUSED"
	sysException$ [ $$SIGMAX     ] = "$$SIGMAX"
	sysException$ [ $$SIGRTMIN   ] = "$$SIGRTMIN"
'
' *******************************************
' *****  Initialize Native Error Names  *****
' *******************************************
'
	errorObject$[ $$ErrorObjectNone                ] = ""
	errorObject$[ $$ErrorObjectData                ] = "Data"
	errorObject$[ $$ErrorObjectDisk                ] = "Disk"
	errorObject$[ $$ErrorObjectFile                ] = "File"
	errorObject$[ $$ErrorObjectFont                ] = "Font"
	errorObject$[ $$ErrorObjectIcon                ] = "Icon"
	errorObject$[ $$ErrorObjectName                ] = "Name"
	errorObject$[ $$ErrorObjectNode                ] = "Node"
	errorObject$[ $$ErrorObjectPipe                ] = "Pipe"
	errorObject$[ $$ErrorObjectUser                ] = "User"
	errorObject$[ $$ErrorObjectArray               ] = "Array"
	errorObject$[ $$ErrorObjectImage               ] = "Image"
	errorObject$[ $$ErrorObjectMedia               ] = "Media"
	errorObject$[ $$ErrorObjectQueue               ] = "Queue"
	errorObject$[ $$ErrorObjectStack               ] = "Stack"
	errorObject$[ $$ErrorObjectTimer               ] = "Timer"
	errorObject$[ $$ErrorObjectBuffer              ] = "Buffer"
	errorObject$[ $$ErrorObjectCursor              ] = "Cursor"
	errorObject$[ $$ErrorObjectDevice              ] = "Device"
	errorObject$[ $$ErrorObjectDriver              ] = "Driver"
	errorObject$[ $$ErrorObjectMemory              ] = "Memory"
	errorObject$[ $$ErrorObjectSocket              ] = "Socket"
	errorObject$[ $$ErrorObjectString              ] = "String"
	errorObject$[ $$ErrorObjectSystem              ] = "System"
	errorObject$[ $$ErrorObjectThread              ] = "Thread"
	errorObject$[ $$ErrorObjectCommand             ] = "Command"
	errorObject$[ $$ErrorObjectLibrary             ] = "Library"
	errorObject$[ $$ErrorObjectMessage             ] = "Message"
	errorObject$[ $$ErrorObjectNetwork             ] = "Network"
	errorObject$[ $$ErrorObjectPrinter             ] = "Printer"
	errorObject$[ $$ErrorObjectProcess             ] = "Process"
	errorObject$[ $$ErrorObjectProgram             ] = "Program"
	errorObject$[ $$ErrorObjectArgument            ] = "Argument"
	errorObject$[ $$ErrorObjectComputer            ] = "Computer"
	errorObject$[ $$ErrorObjectFunction            ] = "Function"
	errorObject$[ $$ErrorObjectIdentity            ] = "Identity"
	errorObject$[ $$ErrorObjectPassword            ] = "Password"
	errorObject$[ $$ErrorObjectClipboard           ] = "Clipboard"
	errorObject$[ $$ErrorObjectDirectory           ] = "Directory"
	errorObject$[ $$ErrorObjectSemaphore           ] = "Semaphore"
	errorObject$[ $$ErrorObjectStatement           ] = "Statement"
	errorObject$[ $$ErrorObjectSystemRoutine       ] = "SystemRoutine"
	errorObject$[ $$ErrorObjectSystemFunction      ] = "SystemFunction"
	errorObject$[ $$ErrorObjectSystemResource      ] = "SystemResource"
	errorObject$[ $$ErrorObjectOperatingSystem     ] = "OperatingSystem"
	errorObject$[ $$ErrorObjectIntegerLogicUnit    ] = "IntegerLogicUnit"
	errorObject$[ $$ErrorObjectFloatingPointUnit   ] = "FloatingPointUnit"
'
	errorNature$[ $$ErrorNatureNone                ] = ""
	errorNature$[ $$ErrorNatureBusy                ] = "Busy"
	errorNature$[ $$ErrorNatureFull                ] = "Full"
	errorNature$[ $$ErrorNatureError               ] = "Error"
	errorNature$[ $$ErrorNatureEmpty               ] = "Empty"
	errorNature$[ $$ErrorNatureReset               ] = "Reset"
	errorNature$[ $$ErrorNatureExists              ] = "Exists"
	errorNature$[ $$ErrorNatureFailed              ] = "Failed"
	errorNature$[ $$ErrorNatureHalted              ] = "Halted"
	errorNature$[ $$ErrorNatureExpired             ] = "Expired"
	errorNature$[ $$ErrorNatureInvalid             ] = "Invalid"
	errorNature$[ $$ErrorNatureMissing             ] = "Missing"
	errorNature$[ $$ErrorNatureTimeout             ] = "Timeout"
	errorNature$[ $$ErrorNatureTooMany             ] = "TooMany"
	errorNature$[ $$ErrorNatureUnknown             ] = "Unknown"
	errorNature$[ $$ErrorNatureBreakKey            ] = "BreakKey"
	errorNature$[ $$ErrorNatureDeadlock            ] = "Deadlock"
  errorNature$[ $$ErrorNatureDisabled            ] = "Disabled"
	errorNature$[ $$ErrorNatureNotEmpty            ] = "NotEmpty"
	errorNature$[ $$ErrorNatureObsolete            ] = "Obsolete"
	errorNature$[ $$ErrorNatureOverflow            ] = "Overflow"
	errorNature$[ $$ErrorNatureTooLarge            ] = "TooLarge"
	errorNature$[ $$ErrorNatureTooSmall            ] = "TooSmall"
	errorNature$[ $$ErrorNatureAbandoned           ] = "Abandoned"
	errorNature$[ $$ErrorNatureAvailable           ] = "Available"
	errorNature$[ $$ErrorNatureDuplicate           ] = "Duplicate"
	errorNature$[ $$ErrorNatureExhausted           ] = "Exhausted"
	errorNature$[ $$ErrorNaturePrivilege           ] = "Privilege"
	errorNature$[ $$ErrorNatureUndefined           ] = "Undefined"
	errorNature$[ $$ErrorNatureUnderflow           ] = "Underflow"
	errorNature$[ $$ErrorNatureAllocation          ] = "Allocation"
	errorNature$[ $$ErrorNatureBreakpoint          ] = "Breakpoint"
	errorNature$[ $$ErrorNatureContention          ] = "Contention"
	errorNature$[ $$ErrorNaturePermission          ] = "Permission"
	errorNature$[ $$ErrorNatureTerminated          ] = "Terminated"
	errorNature$[ $$ErrorNatureUndeclared          ] = "Undeclared"
	errorNature$[ $$ErrorNatureUnexpected          ] = "Unexpected"
	errorNature$[ $$ErrorNatureWouldBlock          ] = "WouldBlock"
	errorNature$[ $$ErrorNatureInterrupted         ] = "Interrupted"
	errorNature$[ $$ErrorNatureMalfunction         ] = "Malfunction"
	errorNature$[ $$ErrorNatureNonexistent         ] = "Nonexistent"
	errorNature$[ $$ErrorNatureUnavailable         ] = "Unavailable"
	errorNature$[ $$ErrorNatureUnspecified         ] = "Unspecified"
	errorNature$[ $$ErrorNatureDisconnected        ] = "Disconnected"
	errorNature$[ $$ErrorNatureDivideByZero        ] = "DivideByZero"
	errorNature$[ $$ErrorNatureIncompatible        ] = "Incompatible"
	errorNature$[ $$ErrorNatureNotConnected        ] = "NotConnected"
	errorNature$[ $$ErrorNatureLimitExceeded       ] = "LimitExceeded"
	errorNature$[ $$ErrorNatureNotInitialized      ] = "NotInitialized"
	errorNature$[ $$ErrorNatureHigherDimension     ] = "HigherDimension"
	errorNature$[ $$ErrorNatureLowestDimension     ] = "LowestDimension"
	errorNature$[ $$ErrorNatureCannotInitialize    ] = "CannotInitialize"
	errorNature$[ $$ErrorNatureInitializeFailed    ] = "InitializeFailed"
	errorNature$[ $$ErrorNatureAlreadyInitialized  ] = "AlreadyInitialized"
	errorNature$[ $$ErrorNatureInvalidAccess       ] = "InvalidAccess"
	errorNature$[ $$ErrorNatureInvalidAddress      ] = "InvalidAddress"
	errorNature$[ $$ErrorNatureInvalidAlignment    ] = "InvalidAlignment"
	errorNature$[ $$ErrorNatureInvalidArgument     ] = "InvalidArgument"
	errorNature$[ $$ErrorNatureInvalidCheck        ] = "InvalidCheck"
	errorNature$[ $$ErrorNatureInvalidCoordinates  ] = "InvalidCoordinates"
	errorNature$[ $$ErrorNatureInvalidCommand      ] = "InvalidCommand"
	errorNature$[ $$ErrorNatureInvalidData         ] = "InvalidData"
	errorNature$[ $$ErrorNatureInvalidDimension    ] = "InvalidDimension"
	errorNature$[ $$ErrorNatureInvalidEntry        ] = "InvalidEntry"
	errorNature$[ $$ErrorNatureInvalidFormat       ] = "InvalidFormat"
	errorNature$[ $$ErrorNatureInvalidKind         ] = "InvalidKind"
	errorNature$[ $$ErrorNatureInvalidIdentity     ] = "InvalidIdentity"
	errorNature$[ $$ErrorNatureInvalidInstruction  ] = "InvalidInstruction"
	errorNature$[ $$ErrorNatureInvalidLocation     ] = "InvalidLocation"
	errorNature$[ $$ErrorNatureInvalidMessage      ] = "InvalidMessage"
	errorNature$[ $$ErrorNatureInvalidName         ] = "InvalidName"
	errorNature$[ $$ErrorNatureInvalidNode         ] = "InvalidNode"
	errorNature$[ $$ErrorNatureInvalidNumber       ] = "InvalidNumber"
	errorNature$[ $$ErrorNatureInvalidOperand      ] = "InvalidOperand"
	errorNature$[ $$ErrorNatureInvalidOperation    ] = "InvalidOperation"
	errorNature$[ $$ErrorNatureInvalidReply        ] = "InvalidReply"
	errorNature$[ $$ErrorNatureInvalidRequest      ] = "InvalidRequest"
	errorNature$[ $$ErrorNatureInvalidResult       ] = "InvalidResult"
	errorNature$[ $$ErrorNatureInvalidSelection    ] = "InvalidSelection"
	errorNature$[ $$ErrorNatureInvalidSignature    ] = "InvalidSignature"
	errorNature$[ $$ErrorNatureInvalidSize         ] = "InvalidSize"
	errorNature$[ $$ErrorNatureInvalidType         ] = "InvalidType"
	errorNature$[ $$ErrorNatureInvalidValue        ] = "InvalidValue"
	errorNature$[ $$ErrorNatureInvalidVersion      ] = "InvalidVersion"
'
' *******************************************
' *****  Initialize System Error Names  *****
' *******************************************
'
'	error constant                    error string         SCO  Linux (if different)
'
	SELECT CASE TRUE
		CASE linux		: GOSUB InitializeLinuxErrorStrings
										GOSUB InitializeLinuxErrnoToErrorArray
		CASE unix			: GOSUB InitializeUnixErrorStrings
										GOSUB InitializeUnixErrnoToErrorArray
		CASE ELSE			: GOSUB InitializeUnixErrorStrings
										GOSUB InitializeUnixErrnoToErrorArray
	END SELECT
'
	##WHOMASK = whomask
	RETURN ($$FALSE)
'
'
'
'
' *****  Initialize Linux errno strings  *****
'
SUB InitializeLinuxErrorStrings
	#OSERROR$[ $$EPERM           ] = "EPERM"
	#OSERROR$[ $$ENOENT          ] = "ENOENT"
	#OSERROR$[ $$ESRCH           ] = "ESRCH"
	#OSERROR$[ $$EINTR           ] = "EINTR"
	#OSERROR$[ $$EIO             ] = "EIO"
	#OSERROR$[ $$ENXIO           ] = "ENXIO"
	#OSERROR$[ $$E2BIG           ] = "E2BIG"
	#OSERROR$[ $$ENOEXEC         ] = "ENOEXEC"
	#OSERROR$[ $$EBADF           ] = "EBADF"
	#OSERROR$[ $$ECHILD          ] = "ECHILD"
	#OSERROR$[ $$EAGAIN          ] = "EAGAIN"
	#OSERROR$[ $$ENOMEM          ] = "ENOMEM"
	#OSERROR$[ $$EACCES          ] = "EACCES"
	#OSERROR$[ $$EFAULT          ] = "EFAULT"
	#OSERROR$[ $$ENOTBLK         ] = "ENOTBLK"
	#OSERROR$[ $$EBUSY           ] = "EBUSY"
	#OSERROR$[ $$EEXIST          ] = "EEXIST"
	#OSERROR$[ $$EXDEV           ] = "EXDEV"
	#OSERROR$[ $$ENODEV          ] = "ENODEV"
	#OSERROR$[ $$ENOTDIR         ] = "ENOTDIR"
	#OSERROR$[ $$EISDIR          ] = "EISDIR"
	#OSERROR$[ $$EINVAL          ] = "EINVAL"
	#OSERROR$[ $$ENFILE          ] = "ENFILE"
	#OSERROR$[ $$EMFILE          ] = "EMFILE"
	#OSERROR$[ $$ENOTTY          ] = "ENOTTY"
	#OSERROR$[ $$ETXTBSY         ] = "ETXTBSY"
	#OSERROR$[ $$EFBIG           ] = "EFBIG"
	#OSERROR$[ $$ENOSPC          ] = "ENOSPC"
	#OSERROR$[ $$ESPIPE          ] = "ESPIPE"
	#OSERROR$[ $$EROFS           ] = "EROFS"
	#OSERROR$[ $$EMLINK          ] = "EMLINK"
	#OSERROR$[ $$EPIPE           ] = "EPIPE"
	#OSERROR$[ $$EDOM            ] = "EDOM"
	#OSERROR$[ $$ERANGE          ] = "ERANGE"
	#OSERROR$[ $$EDEADLK         ] = "EDEADLK"
	#OSERROR$[ $$ENAMETOOLONG    ] = "ENAMETOOLONG"
	#OSERROR$[ $$ENOLCK          ] = "ENOLCK"
	#OSERROR$[ $$ENOSYS          ] = "ENOSYS"
	#OSERROR$[ $$ENOTEMPTY       ] = "ENOTEMPTY"
	#OSERROR$[ $$ELOOP           ] = "ELOOP"
	#OSERROR$[ $$EWOULDBLOCK     ] = "EWOULDBLOCK"
	#OSERROR$[ $$ENOMSG          ] = "ENOMSG"
	#OSERROR$[ $$EIDRM           ] = "EIDRM"
	#OSERROR$[ $$ECHRNG          ] = "ECHRNG"
	#OSERROR$[ $$EL2NSYNC        ] = "EL2NSYNC"
	#OSERROR$[ $$EL3HLT          ] = "EL3HLT"
	#OSERROR$[ $$EL3RST          ] = "EL3RST"
	#OSERROR$[ $$ELNRNG          ] = "ELNRNG"
	#OSERROR$[ $$EUNATCH         ] = "EUNATCH"
	#OSERROR$[ $$ENOCSI          ] = "ENOCSI"
	#OSERROR$[ $$EL2HLT          ] = "EL2HLT"
	#OSERROR$[ $$EBADE           ] = "EBADE"
	#OSERROR$[ $$EBADR           ] = "EBADR"
	#OSERROR$[ $$EXFULL          ] = "EXFULL"
	#OSERROR$[ $$ENOANO          ] = "ENOANO"
	#OSERROR$[ $$EBADRQC         ] = "EBADRQC"
	#OSERROR$[ $$EBADSLT         ] = "EBADSLT"
	#OSERROR$[ $$EDEADLOCK       ] = "EDEADLOCK"
	#OSERROR$[ $$EBFONT          ] = "EBFONT"
	#OSERROR$[ $$ENOSTR          ] = "ENOSTR"
	#OSERROR$[ $$ENODATA         ] = "ENODATA"
	#OSERROR$[ $$ETIME           ] = "ETIME"
	#OSERROR$[ $$ENOSR           ] = "ENOSR"
	#OSERROR$[ $$ENONET          ] = "ENONET"
	#OSERROR$[ $$ENOPKG          ] = "ENOPKG"
	#OSERROR$[ $$EREMOTE         ] = "EREMOTE"
	#OSERROR$[ $$ENOLINK         ] = "ENOLINK"
	#OSERROR$[ $$EADV            ] = "EADV"
	#OSERROR$[ $$ESRMNT          ] = "ESRMNT"
	#OSERROR$[ $$ECOMM           ] = "ECOMM"
	#OSERROR$[ $$EPROTO          ] = "EPROTO"
	#OSERROR$[ $$EMULTIHOP       ] = "EMULTIHOP"
	#OSERROR$[ $$EDOTDOT         ] = "EDOTDOT"
	#OSERROR$[ $$EBADMSG         ] = "EBADMSG"
	#OSERROR$[ $$EOVERFLOW       ] = "EOVERFLOW"
	#OSERROR$[ $$ENOTUNIQ        ] = "ENOTUNIQ"
	#OSERROR$[ $$EBADFD          ] = "EBADFD"
	#OSERROR$[ $$EREMCHG         ] = "EREMCHG"
	#OSERROR$[ $$ELIBACC         ] = "ELIBACC"
	#OSERROR$[ $$ELIBBAD         ] = "ELIBBAD"
	#OSERROR$[ $$ELIBSCN         ] = "ELIBSCN"
	#OSERROR$[ $$ELIBMAX         ] = "ELIBMAX"
	#OSERROR$[ $$ELIBEXEC        ] = "ELIBEXEC"
	#OSERROR$[ $$EILSEQ          ] = "EILSEQ"
	#OSERROR$[ $$ERESTART        ] = "ERESTART"          ' linux only ?
	#OSERROR$[ $$ESTRPIPE        ] = "ESTRPIPE"          ' linux only ?
	#OSERROR$[ $$EUSERS          ] = "EUSERS"            ' linux only ?
	#OSERROR$[ $$ENOTSOCK        ] = "ENOTSOCK"
	#OSERROR$[ $$EDESTADDRREQ    ] = "EDESTADDRREQ"
	#OSERROR$[ $$EMSGSIZE        ] = "EMSGSIZE"
	#OSERROR$[ $$EPROTOTYPE      ] = "EPROTOTYPE"
	#OSERROR$[ $$ENOPROTOOPT     ] = "ENOPROTOOPT"
	#OSERROR$[ $$EPROTONOSUPPORT ] = "EPROTONOSUPPORT"
	#OSERROR$[ $$ESOCKTNOSUPPORT ] = "ESOCKTNOSUPPORT"
	#OSERROR$[ $$EOPNOTSUPP      ] = "EOPNOTSUPP"
	#OSERROR$[ $$EPFNOSUPPORT    ] = "EPFNOSUPPORT"
	#OSERROR$[ $$EAFNOSUPPORT    ] = "EAFNOSUPPORT"
	#OSERROR$[ $$EADDRINUSE      ] = "EADDRINUSE"
	#OSERROR$[ $$EADDRNOTAVAIL   ] = "EADDRNOTAVAIL"
	#OSERROR$[ $$ENETDOWN        ] = "ENETDOWN"
	#OSERROR$[ $$ENETUNREACH     ] = "ENETUNREACH"
	#OSERROR$[ $$ENETRESET       ] = "ENETRESET"
	#OSERROR$[ $$ECONNABORTED    ] = "ECONNABORTED"
	#OSERROR$[ $$ECONNRESET      ] = "ECONNRESET"
	#OSERROR$[ $$ENOBUFS         ] = "ENOBUFS"
	#OSERROR$[ $$EISCONN         ] = "EISCONN"
	#OSERROR$[ $$ENOTCONN        ] = "ENOTCONN"
	#OSERROR$[ $$ESHUTDOWN       ] = "ESHUTDOWN"
	#OSERROR$[ $$ETOOMANYREFS    ] = "ETOOMANYREFS"
	#OSERROR$[ $$ETIMEDOUT       ] = "ETIMEDOUT"
	#OSERROR$[ $$ECONNREFUSED    ] = "ECONNREFUSED"
	#OSERROR$[ $$EHOSTDOWN       ] = "EHOSTDOWN"
	#OSERROR$[ $$EHOSTUNREACH    ] = "EHOSTUNREACH"
	#OSERROR$[ $$EALREADY        ] = "EALREADY"
	#OSERROR$[ $$EINPROGRESS     ] = "EINPROGRESS"
	#OSERROR$[ $$ESTALE          ] = "ESTALE"
	#OSERROR$[ $$EUCLEAN         ] = "EUCLEAN"            ' linux only ?
	#OSERROR$[ $$ENOTNAM         ] = "ENOTNAM"            ' linux only ?
	#OSERROR$[ $$ENAVAIL         ] = "ENAVAIL"            ' linux only ?
	#OSERROR$[ $$EISNAM          ] = "EISNAM"             ' linux only ?
	#OSERROR$[ $$EREMOTEIO       ] = "EREMOTEIO"          ' linux only ?
	#OSERROR$[ $$EDQUOT          ] = "EDQUOT"             ' linux only ?
'
'	#OSERROR$[ $$ELBIN           ] = "ELBIN"              ' SCO unix only ?
'	#OSERROR$[ $$EIORESID        ] = "EIORESID"           ' SCO unix only ?
END SUB
'
'
' *****  Initialize SCO Unix errno strings  *****
'
SUB InitializeUnixErrorStrings
	#OSERROR$[ $$EPERM           ] = "EPERM"             '   1
	#OSERROR$[ $$ENOENT          ] = "ENOENT"            '   2
	#OSERROR$[ $$ESRCH           ] = "ESRCH"             '   3
	#OSERROR$[ $$EINTR           ] = "EINTR"             '   4
	#OSERROR$[ $$EIO             ] = "EIO"               '   5
	#OSERROR$[ $$ENXIO           ] = "ENXIO"             '   6
	#OSERROR$[ $$E2BIG           ] = "E2BIG"             '   7
	#OSERROR$[ $$ENOEXEC         ] = "ENOEXEC"           '   8
	#OSERROR$[ $$EBADF           ] = "EBADF"             '   9
	#OSERROR$[ $$ECHILD          ] = "ECHILD"            '  10
	#OSERROR$[ $$EAGAIN          ] = "EAGAIN"            '  11
	#OSERROR$[ $$ENOMEM          ] = "ENOMEM"            '  12
	#OSERROR$[ $$EACCES          ] = "EACCES"            '  13
	#OSERROR$[ $$EFAULT          ] = "EFAULT"            '  14
	#OSERROR$[ $$ENOTBLK         ] = "ENOTBLK"           '  15
	#OSERROR$[ $$EBUSY           ] = "EBUSY"             '  16
	#OSERROR$[ $$EEXIST          ] = "EEXIST"            '  17
	#OSERROR$[ $$EXDEV           ] = "EXDEV"             '  18
	#OSERROR$[ $$ENODEV          ] = "ENODEV"            '  19
	#OSERROR$[ $$ENOTDIR         ] = "ENOTDIR"           '  20
	#OSERROR$[ $$EISDIR          ] = "EISDIR"            '  21
	#OSERROR$[ $$EINVAL          ] = "EINVAL"            '  22
	#OSERROR$[ $$ENFILE          ] = "ENFILE"            '  23
	#OSERROR$[ $$EMFILE          ] = "EMFILE"            '  24
	#OSERROR$[ $$ENOTTY          ] = "ENOTTY"            '  25
	#OSERROR$[ $$ETXTBSY         ] = "ETXTBSY"           '  26
	#OSERROR$[ $$EFBIG           ] = "EFBIG"             '  27
	#OSERROR$[ $$ENOSPC          ] = "ENOSPC"            '  28
	#OSERROR$[ $$ESPIPE          ] = "ESPIPE"            '  29
	#OSERROR$[ $$EROFS           ] = "EROFS"             '  30
	#OSERROR$[ $$EMLINK          ] = "EMLINK"            '  31
	#OSERROR$[ $$EPIPE           ] = "EPIPE"             '  32
	#OSERROR$[ $$EDOM            ] = "EDOM"              '  33
	#OSERROR$[ $$ERANGE          ] = "ERANGE"            '  34
	#OSERROR$[ $$ENOMSG          ] = "ENOMSG"            '  35
	#OSERROR$[ $$EIDRM           ] = "EIDRM"             '  36
	#OSERROR$[ $$ECHRNG          ] = "ECHRNG"            '  37
	#OSERROR$[ $$EL2NSYNC        ] = "EL2NSYNC"          '  38
	#OSERROR$[ $$EL3HLT          ] = "EL3HLT"            '  39
	#OSERROR$[ $$EL3RST          ] = "EL3RST"            '  40
	#OSERROR$[ $$ELNRNG          ] = "ELNRNG"            '  41
	#OSERROR$[ $$EUNATCH         ] = "EUNATCH"           '  42
	#OSERROR$[ $$ENOCSI          ] = "ENOCSI"            '  43
	#OSERROR$[ $$EL2HLT          ] = "EL2HLT"            '  44
	#OSERROR$[ $$EDEADLK         ] = "EDEADLK"           '  45
	#OSERROR$[ $$ENOLCK          ] = "ENOLCK"            '  46
	#OSERROR$[ $$EBADE           ] = "EBADE"             '  50
	#OSERROR$[ $$EBADR           ] = "EBADR"             '  51
	#OSERROR$[ $$EXFULL          ] = "EXFULL"            '  52
	#OSERROR$[ $$ENOANO          ] = "ENOANO"            '  53
	#OSERROR$[ $$EBADRQC         ] = "EBADRQC"           '  54
	#OSERROR$[ $$EBADSLT         ] = "EBADSLT"           '  55
	#OSERROR$[ $$EDEADLOCK       ] = "EDEADLOCK"         '  56
	#OSERROR$[ $$EBFONT          ] = "EBFONT"            '  57
	#OSERROR$[ $$ENOSTR          ] = "ENOSTR"            '  60
	#OSERROR$[ $$ENODATA         ] = "ENODATA"           '  61
	#OSERROR$[ $$ETIME           ] = "ETIME"             '  62
	#OSERROR$[ $$ENOSR           ] = "ENOSR"             '  63
	#OSERROR$[ $$ENONET          ] = "ENONET"            '  64
	#OSERROR$[ $$ENOPKG          ] = "ENOPKG"            '  65
	#OSERROR$[ $$EREMOTE         ] = "EREMOTE"           '  66
	#OSERROR$[ $$ENOLINK         ] = "ENOLINK"           '  67
	#OSERROR$[ $$EADV            ] = "EADV"              '  68
	#OSERROR$[ $$ESRMNT          ] = "ESRMNT"            '  69
	#OSERROR$[ $$ECOMM           ] = "ECOMM"             '  70
	#OSERROR$[ $$EPROTO          ] = "EPROTO"            '  71
	#OSERROR$[ $$EMULTIHOP       ] = "EMULTIHOP"         '  74
	#OSERROR$[ $$ELBIN           ] = "ELBIN"             '  75
	#OSERROR$[ $$EDOTDOT         ] = "EDOTDOT"           '  76
	#OSERROR$[ $$EBADMSG         ] = "EBADMSG"           '  77
	#OSERROR$[ $$ENAMETOOLONG    ] = "ENAMETOOLONG"      '  78
	#OSERROR$[ $$EOVERFLOW       ] = "EOVERFLOW"         '  79
	#OSERROR$[ $$ENOTUNIQ        ] = "ENOTUNIQ"          '  80
	#OSERROR$[ $$EBADFD          ] = "EBADFD"            '  81
	#OSERROR$[ $$EREMCHG         ] = "EREMCHG"           '  82
	#OSERROR$[ $$ELIBACC         ] = "ELIBACC"           '  83
	#OSERROR$[ $$ELIBBAD         ] = "ELIBBAD"           '  84
	#OSERROR$[ $$ELIBSCN         ] = "ELIBSCN"           '  85
	#OSERROR$[ $$ELIBMAX         ] = "ELIBMAX"           '  86
	#OSERROR$[ $$ELIBEXEC        ] = "ELIBEXEC"          '  87
	#OSERROR$[ $$EILSEQ          ] = "EILSEQ"            '  88
	#OSERROR$[ $$ENOSYS          ] = "ENOSYS"            '  89
	#OSERROR$[ $$ETCPERR         ] = "ETCPERR"           '  90
	#OSERROR$[ $$EWOULDBLOCK     ] = "EWOULDBLOCK"       '  90
	#OSERROR$[ $$EINPROGRESS     ] = "EINPROGRESS"       '  91
	#OSERROR$[ $$EALREADY        ] = "EALREADY"          '  92
	#OSERROR$[ $$ENOTSOCK        ] = "ENOTSOCK"          '  93
	#OSERROR$[ $$EDESTADDRREQ    ] = "EDESTADDRREQ"      '  94
	#OSERROR$[ $$EMSGSIZE        ] = "EMSGSIZE"          '  95
	#OSERROR$[ $$EPROTOTYPE      ] = "EPROTOTYPE"        '  96
	#OSERROR$[ $$EPROTONOSUPPORT ] = "EPROTONOSUPPORT"   '  97
	#OSERROR$[ $$ESOCKTNOSUPPORT ] = "ESOCKTNOSUPPORT"   '  98
	#OSERROR$[ $$EOPNOTSUPP      ] = "EOPNOTSUPP"        '  99
	#OSERROR$[ $$EPFNOSUPPORT    ] = "EPFNOSUPPORT"      ' 100
	#OSERROR$[ $$EAFNOSUPPORT    ] = "EAFNOSUPPORT"      ' 101
	#OSERROR$[ $$EADDRINUSE      ] = "EADDRINUSE"        ' 102
	#OSERROR$[ $$EADDRNOTAVAIL   ] = "EADDRNOTAVAIL"     ' 103
	#OSERROR$[ $$ENETDOWN        ] = "ENETDOWN"          ' 104
	#OSERROR$[ $$ENETUNREACH     ] = "ENETUNREACH"       ' 105
	#OSERROR$[ $$ENETRESET       ] = "ENETRESET"         ' 105
	#OSERROR$[ $$ECONNABORTED    ] = "ECONNABORTED"      ' 107
	#OSERROR$[ $$ECONNRESET      ] = "ECONNRESET"        ' 108
	#OSERROR$[ $$ENOBUFS         ] = "ENOBUFS"           ' 109
	#OSERROR$[ $$EISCONN         ] = "EISCONN"           ' 110
	#OSERROR$[ $$ENOTCONN        ] = "ENOTCONN"          ' 111
	#OSERROR$[ $$ESHUTDOWN       ] = "ESHUTDOWN"         ' 112
	#OSERROR$[ $$ETOOMANYREFS    ] = "ETOOMANYREFS"      ' 113
	#OSERROR$[ $$ETIMEDOUT       ] = "ETIMEDOUT"         ' 114
	#OSERROR$[ $$ECONNREFUSED    ] = "ECONNREFUSED"      ' 115
	#OSERROR$[ $$EHOSTDOWN       ] = "EHOSTDOWN"         ' 116
	#OSERROR$[ $$EHOSTUNREACH    ] = "EHOSTUNREACH"      ' 117
	#OSERROR$[ $$ENOPROTOOPT     ] = "ENOPROTOOPT"       ' 118
	#OSERROR$[ $$ENOTEMPTY       ] = "ENOTEMPTY"         ' 145
	#OSERROR$[ $$ELOOP           ] = "ELOOP"             ' 150
	#OSERROR$[ $$ESTALE          ] = "ESTALE"            ' 151
	#OSERROR$[ $$EIORESID        ] = "EIORESID"          ' 500
END SUB
'
'
' nativeErrorNumber = #OSTOXERROR[operatingSystemErrorNumber]
'
' converts all operating system error numbers to native error numbers
' nativeErrorNumber = (($$ErrorObjectSystem << 8) OR $$ErrorNatureError)
'   means there's no native error number for this system error number,
'   so you'll have to settle for the system error number.
'
' need a separate subroutine for Linux vs SCO because their errno sets are different
'
'
' *****  InitializeLinuxErrnoToErrorArray  *****
'
SUB InitializeLinuxErrnoToErrorArray
	upper = UBOUND (#OSTOXERROR[])
	FOR i = 0 TO upper
		#OSTOXERROR[i] = ($$ErrorObjectSystem << 8) OR $$ErrorNatureError
	NEXT i
'
	#OSTOXERROR[ $$EPERM           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$ENOENT          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ESRCH           ] = ($$ErrorObjectProcess         << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$EINTR           ] = ($$ErrorObjectSystemRoutine   << 8) OR $$ErrorNatureInterrupted
	#OSTOXERROR[ $$EIO             ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENXIO           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$E2BIG           ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ENOEXEC         ] = ($$ErrorObjectCommand         << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$EBADF           ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureInvalidIdentity
	#OSTOXERROR[ $$ECHILD          ] = ($$ErrorObjectProcess         << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$EAGAIN          ] = ($$ErrorObjectProcess         << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ENOMEM          ] = ($$ErrorObjectMemory          << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$EACCES          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$EFAULT          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ENOTBLK         ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$EBUSY           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureBusy
	#OSTOXERROR[ $$EEXIST          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureExists
	#OSTOXERROR[ $$EXDEV           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureContention
	#OSTOXERROR[ $$ENODEV          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ENOTDIR         ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$EISDIR          ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureExists
	#OSTOXERROR[ $$EINVAL          ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ENFILE          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$EMFILE          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureTooMany
	#OSTOXERROR[ $$ENOTTY          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$ETXTBSY         ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureContention
	#OSTOXERROR[ $$EFBIG           ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureTooLarge
	#OSTOXERROR[ $$ENOSPC          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ESPIPE          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureInvalidOperation
	#OSTOXERROR[ $$EROFS           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureInvalidOperation
	#OSTOXERROR[ $$EMLINK          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureTooMany
	#OSTOXERROR[ $$EPIPE           ] = ($$ErrorObjectPipe            << 8) OR $$ErrorNatureTerminated
	#OSTOXERROR[ $$EDOM            ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$ERANGE          ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EDEADLK         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENAMETOOLONG    ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ENOLCK          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOSYS          ] = ($$ErrorObjectSystemRoutine   << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ENOTEMPTY       ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureNotEmpty
	#OSTOXERROR[ $$ELOOP           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EWOULDBLOCK     ] = ($$ErrorObjectFunction        << 8) OR $$ErrorNatureWouldBlock
	#OSTOXERROR[ $$ENOMSG          ] = ($$ErrorObjectMessage         << 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$EIDRM           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ECHRNG          ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EL2NSYNC        ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureMalfunction
	#OSTOXERROR[ $$EL3HLT          ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureHalted
	#OSTOXERROR[ $$EL3RST          ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureReset
	#OSTOXERROR[ $$ELNRNG          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EUNATCH         ] = ($$ErrorObjectDriver          << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOCSI          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EL2HLT          ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureHalted
	#OSTOXERROR[ $$EBADE           ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EBADR           ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EXFULL          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ENOANO          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureOverflow
	#OSTOXERROR[ $$EBADRQC         ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EBADSLT         ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EDEADLOCK       ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureDeadlock
	#OSTOXERROR[ $$EBFONT          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ENOSTR          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureInvalidType
	#OSTOXERROR[ $$ENODATA         ] = ($$ErrorObjectData            << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ETIME           ] = ($$ErrorObjectTimer           << 8) OR $$ErrorNatureTimeout
	#OSTOXERROR[ $$ENOSR           ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ENONET          ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOPKG          ] = ($$ErrorObjectProgram         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EREMOTE         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOLINK         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EADV            ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ESRMNT          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ECOMM           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPROTO          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EMULTIHOP       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EDOTDOT         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EBADMSG         ] = ($$ErrorObjectMessage         << 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$EOVERFLOW       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOTUNIQ        ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureInvalidIdentity
	#OSTOXERROR[ $$EBADFD          ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$EREMCHG         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ELIBACC         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ELIBBAD         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ELIBSCN         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ELIBMAX         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureTooMany
	#OSTOXERROR[ $$ELIBEXEC        ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureInvalidAccess
	#OSTOXERROR[ $$EILSEQ          ] = ($$ErrorObjectData            << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ERESTART        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOTSOCK        ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureUndefined
	#OSTOXERROR[ $$EDESTADDRREQ    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EMSGSIZE        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPROTOTYPE      ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOPROTOOPT     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPROTONOSUPPORT ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ESOCKTNOSUPPORT ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EOPNOTSUPP      ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPFNOSUPPORT    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EAFNOSUPPORT    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EADDRINUSE      ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureContention
	#OSTOXERROR[ $$EADDRNOTAVAIL   ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ENETDOWN        ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENETUNREACH     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENETRESET       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ECONNABORTED    ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureDisconnected
	#OSTOXERROR[ $$ECONNRESET      ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureReset
	#OSTOXERROR[ $$ENOBUFS         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EISCONN         ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ENOTCONN        ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureNotConnected
	#OSTOXERROR[ $$ESHUTDOWN       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ETOOMANYREFS    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ETIMEDOUT       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureTimeout
	#OSTOXERROR[ $$ECONNREFUSED    ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureNotConnected
	#OSTOXERROR[ $$EHOSTDOWN       ] = ($$ErrorObjectSystem          << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EHOSTUNREACH    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureUnknown
	#OSTOXERROR[ $$EALREADY        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EINPROGRESS     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ESTALE          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EUCLEAN         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOTNAM         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENAVAIL         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EISNAM          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EREMOTEIO       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EDQUOT          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
'
' SCO unix constants not defined or redefined in Linux
'
'	#OSTOXERROR[ $$ELBIN           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
'	#OSTOXERROR[ $$ETCPERR         ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureError
'	#OSTOXERROR[ $$ENOPROTOOPT     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
'	#OSTOXERROR[ $$EIORESID        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
END SUB
'
'
' *****  InitializeUnixErrnoToErrorArray  *****
'
SUB InitializeUnixErrnoToErrorArray
	upper = UBOUND (#OSTOXERROR[])
	FOR i = 0 TO upper
		#OSTOXERROR[i] = ($$ErrorObjectSystem << 8) OR $$ErrorNatureError
	NEXT i
'
	#OSTOXERROR[ $$EPERM           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$ENOENT          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ESRCH           ] = ($$ErrorObjectProcess         << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$EINTR           ] = ($$ErrorObjectSystemRoutine   << 8) OR $$ErrorNatureInterrupted
	#OSTOXERROR[ $$EIO             ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENXIO           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$E2BIG           ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ENOEXEC         ] = ($$ErrorObjectCommand         << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$EBADF           ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureInvalidIdentity
	#OSTOXERROR[ $$ECHILD          ] = ($$ErrorObjectProcess         << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$EAGAIN          ] = ($$ErrorObjectProcess         << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ENOMEM          ] = ($$ErrorObjectMemory          << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$EACCES          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$EFAULT          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ENOTBLK         ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$EBUSY           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureBusy
	#OSTOXERROR[ $$EEXIST          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureExists
	#OSTOXERROR[ $$EXDEV           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureContention
	#OSTOXERROR[ $$ENODEV          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ENOTDIR         ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$EISDIR          ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureExists
	#OSTOXERROR[ $$EINVAL          ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ENFILE          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$EMFILE          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureTooMany
	#OSTOXERROR[ $$ENOTTY          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$ETXTBSY         ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureContention
	#OSTOXERROR[ $$EFBIG           ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureTooLarge
	#OSTOXERROR[ $$ENOSPC          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ESPIPE          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureInvalidOperation
	#OSTOXERROR[ $$EROFS           ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureInvalidOperation
	#OSTOXERROR[ $$EMLINK          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureTooMany
	#OSTOXERROR[ $$EPIPE           ] = ($$ErrorObjectPipe            << 8) OR $$ErrorNatureTerminated
	#OSTOXERROR[ $$EDOM            ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$ERANGE          ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$ENOMSG          ] = ($$ErrorObjectMessage         << 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$EIDRM           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ECHRNG          ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EL2NSYNC        ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureMalfunction
	#OSTOXERROR[ $$EL3HLT          ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureHalted
	#OSTOXERROR[ $$EL3RST          ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureReset
	#OSTOXERROR[ $$ELNRNG          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EUNATCH         ] = ($$ErrorObjectDriver          << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOCSI          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EL2HLT          ] = ($$ErrorObjectOperatingSystem << 8) OR $$ErrorNatureHalted
	#OSTOXERROR[ $$EDEADLK         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOLCK          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EBADE           ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EBADR           ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EXFULL          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ENOANO          ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureOverflow
	#OSTOXERROR[ $$EBADRQC         ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EBADSLT         ] = ($$ErrorObjectArgument        << 8) OR $$ErrorNatureInvalidValue
	#OSTOXERROR[ $$EDEADLOCK       ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureDeadlock
	#OSTOXERROR[ $$EBFONT          ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ENOSTR          ] = ($$ErrorObjectDevice          << 8) OR $$ErrorNatureInvalidType
	#OSTOXERROR[ $$ENODATA         ] = ($$ErrorObjectData            << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ETIME           ] = ($$ErrorObjectTimer           << 8) OR $$ErrorNatureTimeout
	#OSTOXERROR[ $$ENOSR           ] = ($$ErrorObjectSystemResource  << 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ENONET          ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOPKG          ] = ($$ErrorObjectProgram         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EREMOTE         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENOLINK         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EADV            ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ESRMNT          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ECOMM           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPROTO          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EMULTIHOP       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
'	#OSTOXERROR[ $$ELBIN           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EDOTDOT         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EBADMSG         ] = ($$ErrorObjectMessage         << 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ENAMETOOLONG    ] = ($$ErrorObjectFile            << 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$EOVERFLOW       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOTUNIQ        ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureInvalidIdentity
	#OSTOXERROR[ $$EBADFD          ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$EREMCHG         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ELIBACC         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ELIBBAD         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ELIBSCN         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ELIBMAX         ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureTooMany
	#OSTOXERROR[ $$ELIBEXEC        ] = ($$ErrorObjectLibrary         << 8) OR $$ErrorNatureInvalidAccess
	#OSTOXERROR[ $$EILSEQ          ] = ($$ErrorObjectData            << 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ENOSYS          ] = ($$ErrorObjectSystemRoutine   << 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ETCPERR         ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EWOULDBLOCK     ] = ($$ErrorObjectFunction        << 8) OR $$ErrorNatureWouldBlock
	#OSTOXERROR[ $$EINPROGRESS     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EALREADY        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOTSOCK        ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureUndefined
	#OSTOXERROR[ $$EDESTADDRREQ    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EMSGSIZE        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPROTOTYPE      ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOPROTOOPT     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPROTONOSUPPORT ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ESOCKTNOSUPPORT ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EOPNOTSUPP      ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EPFNOSUPPORT    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EAFNOSUPPORT    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EADDRINUSE      ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureContention
	#OSTOXERROR[ $$EADDRNOTAVAIL   ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ENETDOWN        ] = ($$ErrorObjectNetwork         << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ENETUNREACH     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENETRESET       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ECONNABORTED    ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureDisconnected
	#OSTOXERROR[ $$ECONNRESET      ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureReset
	#OSTOXERROR[ $$ENOBUFS         ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EISCONN         ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ENOTCONN        ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureNotConnected
	#OSTOXERROR[ $$ESHUTDOWN       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ETOOMANYREFS    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ETIMEDOUT       ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureTimeout
	#OSTOXERROR[ $$ECONNREFUSED    ] = ($$ErrorObjectSocket          << 8) OR $$ErrorNatureNotConnected
	#OSTOXERROR[ $$EHOSTDOWN       ] = ($$ErrorObjectSystem          << 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$EHOSTUNREACH    ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureUnknown
	#OSTOXERROR[ $$ENOPROTOOPT     ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ENOTEMPTY       ] = ($$ErrorObjectDirectory       << 8) OR $$ErrorNatureNotEmpty
	#OSTOXERROR[ $$ELOOP           ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ESTALE          ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$EIORESID        ] = ($$ErrorObjectNone            << 8) OR $$ErrorNatureError
END SUB
END FUNCTION
'
'
' #############################
' #####  WakeupNobody ()  #####
' #############################
'
FUNCTION  WakeupNobody (timer, count, msec, time)
	SHARED  sleepSystem
'
'	PRINT "WakeupNobody() : "; timer;; count;; msec;; time
'	sleepSystem = $$FALSE
'	write (1, &"n", 1)
END FUNCTION
'
'
' #############################
' #####  WakeupSystem ()  #####
' #############################
'
FUNCTION  WakeupSystem (timer, count, msec, time)
	SHARED  sleepSystem
'
'	PRINT "WakeupSystem() : "; timer;; count;; msec;; time
	sleepSystem = $$FALSE
'	write (1, &"s", 1)
END FUNCTION
'
'
' ###########################
' #####  WakeupUser ()  #####
' ###########################
'
FUNCTION  WakeupUser (timer, count, msec, time)
	SHARED  sleepUser
'
'	PRINT "WakeupUser() : "; timer;; count;; msec;; time
	sleepUser = $$FALSE
'	write (1, &"u", 1)
END FUNCTION
'
'
' ###################################
' #####  XstQuickSort_XLONG ()  #####
' ###################################
'
'	XstQuickSort() has guaranteed all arguments are valid.
'
'	Input:
'		a[]		= 1D array of XLONG data to be sorted
'		n[]		= corresponding index array (optional)
'		low		= first index to sort
'		high	= last index to sort
'		order	= Increasing (0) or Decreasing (1)
'
'	Output:
'		a[]		= intermediate sorted data
'		n[]		= intermediate sorted indices (optional)
'
'	Return:
'		none
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
'	XstQuickSort() has guaranteed all arguments are valid.
'
'	Input:
'		a$$[]	= 1D array of GIANT data to be sorted
'		n[]		= corresponding index array (optional)
'		low		= first index to sort
'		high	= last index to sort
'		order	= Increasing (0) or Decreasing (1)
'
'	Output:
'		a$$[]	= intermediate sorted data
'		n[]		= intermediate sorted indices (if requested)
'
'	Return:
'		none
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
'	XstQuickSort() has guaranteed all arguments are valid.
'
'	Input:
'		a#[]	= 1D array of DOUBLE data to be sorted
'		n[]		= corresponding index array (optional)
'		low		= first index to sort
'		high	= last index to sort
'		order	= Increasing (0) or Decreasing (1)
'
'	Output:
'		a#[]	= intermediate sorted data
'		n[]		= intermediate sorted indices (if requested)
'
'	Return:
'		none
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
'	XstQuickSort() has guaranteed all arguments are valid.
'
'	Input:
'		a$[]	= 1D array of STRING data to be sorted
'		n[]		= corresponding index array (optional)
'		low		= first index to sort
'		high	= last index to sort
'		order	= Increasing (0) or Decreasing (1)
'
'	Output:
'		a$[]	= intermediate sorted data
'		n[]		= intermediate sorted indices (if requested)
'
'	Return:
'		none
'
FUNCTION  XstQuickSort_STRING (a$[], n[], low, high, order)
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
	IF i > low + 1 THEN XstQuickSort_STRING (@a$[], @n[], low, i-1, order)
	IF i < high - 1 THEN XstQuickSort_STRING (@a$[], @n[], i+1, high, order)
END FUNCTION
'
'
' ###########################################
' #####  XstQuickSort_STRING_nocase ()  #####
' ###########################################
'
'	XstQuickSort() has guaranteed all arguments are valid.
'
'	Input:
'		a$[]	= 1D array of STRING data to be sorted
'		n[]		= corresponding index array (optional)
'		low		= first index to sort
'		high	= last index to sort
'		order	= Increasing (0) or Decreasing (1)
'
'	Output:
'		a$[]	= intermediate sorted data
'		n[]		= intermediate sorted indices (if requested)
'
'	Return:
'		none
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
'	XstQuickSort() has guaranteed all arguments are valid.
'
'	Input:
'		a$[]	= 1D array of STRING data to be sorted
'		n[]		= corresponding index array (optional)
'		low		= first index to sort
'		high	= last index to sort
'		order	= Increasing (0) or Decreasing (1)
'
'	Output:
'		a$[]	= intermediate sorted data
'		n[]		= intermediate sorted indices (if requested)
'
'	Return:
'		none
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
' ####################
' #####  Xio ()  #####
' ####################
'
FUNCTION  Xio ()
	STATIC  entry
'
	IF entry THEN RETURN
	entry = $$TRUE
'
'	XstLog ("Xio().Xgr()")
	Xgr ()										' GUI version
'	XstLog ("Xio().Xui()")
	Xui ()										' GUI version
'	XstLog ("Xio().InitGui()")
	InitGui ()								' GUI version
'	XstLog ("Xio().CreateConsole()")
	CreateConsole ()					' GUI version
'	XstLog ("Xio().Z")
END FUNCTION
'
'
' #########################
' #####  XxxClose ()  #####
' #########################
'
FUNCTION  XxxClose (fileNumber)
	EXTERNAL	errno
	SHARED	FILE  fileInfo[]
	SHARED  LOCK  fileLock[]
'
	IFZ fileInfo[] THEN
		IF (fileNumber != -1) THEN GOTO eeeBadFileNumber
		RETURN ($$FALSE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	err = $$FALSE
	##ERROR = $$FALSE
	uFile = UBOUND(fileInfo[])
	IF (fileNumber = $$ALL) THEN
		firstNumber = 1
		IF ##WHOMASK THEN firstNumber = 3
		FOR fileNumber = firstNumber TO uFile
			fileHandle = fileInfo[fileNumber].fileHandle
			IFZ fileHandle THEN DO NEXT
			IF ##WHOMASK THEN
				IFZ fileInfo[fileNumber].whomask THEN DO NEXT
			END IF
			GOSUB CloseFileHandle
		NEXT fileNumber
		fileNumber = $$ALL
	ELSE
		IF InvalidFileNumber (fileNumber) THEN RETURN ($$FALSE)
		fileHandle = fileInfo[fileNumber].fileHandle
		GOSUB CloseFileHandle
	END IF
	RETURN (err)
'
SUB CloseFileHandle
	consoleGrid = fileInfo[fileNumber].consoleGrid
	IFZ consoleGrid THEN
		IF fileLock[] THEN
			IF (file <= UBOUND (fileLock[]))
				IF fileLock[file,] THEN
					FOR i = 0 TO UBOUND (fileLock[file,])
						IF fileLock[file,i].file THEN
							IF fileLock[file,i].sfile THEN
								offset$$ = fileLock[file,i].offset
								length$$ = fileLock[file,i].length
								XstUnlockFileSection (file, 0, offset$$, length$$)
							END IF
						END IF
					NEXT i
				END IF
			END IF
		END IF
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = close (fileHandle)
		##WHOMASK = whomask
		##LOCKOUT = lockout
		IF a THEN
			GOSUB CloseError
		ELSE
			fileInfo[fileNumber].fileName			= ""
			fileInfo[fileNumber].fileHandle		= 0
			fileInfo[fileNumber].whomask			= 0
			fileInfo[fileNumber].consoleGrid	= 0
			fileInfo[fileNumber].entries			= 0
		END IF
	ELSE
		DEC fileInfo[fileNumber].entries
		IF (fileInfo[fileNumber].entries > 0) THEN EXIT SUB
		XuiSendMessage (consoleGrid, #Destroy, 0, 0, 0, 0, 0, 0)
		fileInfo[fileNumber].fileName			= ""
		fileInfo[fileNumber].fileHandle		= 0
		fileInfo[fileNumber].whomask			= 0
		fileInfo[fileNumber].consoleGrid	= 0
		fileInfo[fileNumber].entries			= 0
	END IF
END SUB
'
SUB CloseError
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	err = $$TRUE
END SUB
'
eeeBadFileNumber:
	error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' ################################
' #####  XxxCloseAllUser ()  #####
' ################################
'
FUNCTION  XxxCloseAllUser ()
	EXTERNAL	errno
	SHARED	FILE	fileInfo[]
'
	IFZ fileInfo[] THEN RETURN ($$FALSE)			' No files open
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	err = $$FALSE
	uFiles = UBOUND(fileInfo[])
	FOR fileNumber = 3 TO uFiles
		fileHandle = fileInfo[fileNumber].fileHandle
		IFZ fileHandle THEN DO NEXT
		IF fileInfo[fileNumber].whomask THEN GOSUB CloseFileHandle
	NEXT fileNumber
	RETURN (err)
'
SUB CloseFileHandle
	consoleGrid = fileInfo[fileNumber].consoleGrid
	IFZ consoleGrid THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = close (fileHandle)
		##WHOMASK = whomask
		##LOCKOUT = lockout
		IF a THEN
			GOSUB CloseError
		ELSE
			fileInfo[fileNumber].fileName			= ""
			fileInfo[fileNumber].fileHandle		= 0
			fileInfo[fileNumber].whomask			= 0
			fileInfo[fileNumber].consoleGrid	= 0
			fileInfo[fileNumber].entries			= 0
		END IF
	ELSE
		DEC fileInfo[fileNumber].entries
		IF (fileInfo[fileNumber].entries > 0) THEN EXIT SUB
		XuiSendMessage (consoleGrid, #Destroy, 0, 0, 0, 0, 0, 0)
		fileInfo[fileNumber].fileName			= ""
		fileInfo[fileNumber].fileHandle		= 0
		fileInfo[fileNumber].whomask			= 0
		fileInfo[fileNumber].consoleGrid	= 0
		fileInfo[fileNumber].entries			= 0
	END IF
END SUB
'
SUB CloseError
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	err = $$TRUE
END SUB
END FUNCTION
'
'
' #######################
' #####  XxxEof ()  #####
' #######################
'
FUNCTION  XxxEof (fileNumber)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN ($$TRUE)	' invalid file
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN ($$TRUE)								' console file
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
'
	errno = $$FALSE
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	c = lseek (fileHandle, 0, $$SEEK_CUR)			' get file position
	##WHOMASK = whomask
	##LOCKOUT = lockout
	IF (c < 0) THEN GOTO SeekError
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	s = lseek (fileHandle, 0, $$SEEK_END)			' get size of file
	##WHOMASK = whomask
	##LOCKOUT = lockout
	IF (s < 0) THEN GOTO SeekError
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	a = lseek (fileHandle, c, $$SEEK_SET)			' restore file pointer
	##WHOMASK = whomask
	##LOCKOUT = lockout
	IF (a < 0) THEN GOTO SeekError
'
	IF (c >= s) THEN RETURN ($$TRUE)
	RETURN ($$FALSE)
'
'	error
'
SeekError:
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' ###########################
' #####  XxxInfile$ ()  #####
' ###########################
'
FUNCTION  XxxInfile$ (fileNumber)
	EXTERNAL	errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ("")
		IFZ fileInfo[] THEN RETURN ("")
		IFZ fileInfo[1].fileHandle THEN RETURN ("")		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN												' XuiConsole
		consoleGrid = fileInfo[fileNumber].consoleGrid
		XuiSendMessage (consoleGrid, #Inline, 0, 0, 0, 0, 0, @text$)
		XxxCheckMessages ()
		RETURN (text$)
	END IF
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	p = lseek (fileHandle, 0, $$SEEK_CUR)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF (p < 0) THEN GOTO SeekError
	a$			= NULL$ (530)
	bufAddr	= &a$
	length	= 0
	nl			= 0
'
	DO
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = read (fileHandle, bufAddr, 86)
		##LOCKOUT = lockout
		##WHOMASK = whomask
		IF (a < 0) THEN GOTO ReadError
		IFZ (a OR length) THEN GOTO ReadError
'
		nl = INSTR(a$, "\n", length + 1)	' \n in last segment?
		IF nl THEN
			length = nl - 1
			a${length} = 0									' put null terminator over <nl>
			IF length THEN
				cr = a${length-1}							' Check for <cr> before <nl>.  Why?
				IF (cr = 13) THEN							' Because WindowsNT sends <cr> + <nl>
					DEC length
					a${length} = 0							' put null terminator over <cr>
				END IF
			END IF
			EXIT DO
		END IF

		length = length + a
		bytesLeft = LEN (a$) - length
		IF (bytesLeft < 87) THEN a$ = a$ + NULL$ (530)
		bufAddr	= &a$ + length											' bufAddr = next input address
	LOOP
'
' n = number of characters including newline <nl>
'
	IFZ length THEN
		a$ = ""
	ELSE
		aAddr = &a$
		XLONGAT (aAddr, -8)			= length				' put length in header
		UBYTEAT (aAddr, length)	= 0							' put null byte over <nl>
	END IF
'
	IF nl THEN
		p = p + nl															' put file pointer after <nl>
	ELSE
		p = p + length													' put file pointer after last char
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	a = lseek (fileHandle, p, $$SEEK_SET)
	##WHOMASK = whomask
	##LOCKOUT = lockout
	IF (a < 0) THEN GOTO SeekError
	RETURN (a$)
'
'	Error
'
SeekError:
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN
'
ReadError:
	IF (a = 0) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		s = lseek (fileHandle, 0, $$SEEK_END)			' get size of file
		##LOCKOUT = lockout
		##WHOMASK = whomask
		IF (s < 0) THEN GOTO SeekError
'
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = lseek (fileHandle, p, $$SEEK_END)			' restore file pointer
		##LOCKOUT = lockout
		##WHOMASK = whomask
		IF (a < 0) THEN GOTO SeekError
'
		IF (p >= s) THEN
			##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureExhausted
		ELSE
			##ERROR = $$ErrorNatureTerminated
		END IF
	ELSE
		XstSystemErrorToError (errno, @error)
		##ERROR = error
	END IF
	RETURN
END FUNCTION
'
'
' ###########################
' #####  XxxInline$ ()  #####
' ###########################
'
FUNCTION  XxxInline$ (prompt$)
	EXTERNAL	errno
	SHARED	FILE	fileInfo[]
'
'	GOTO console									' remove this line for GUI console
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	fileHandle = fileInfo[1].fileHandle
	consoleGrid = fileInfo[1].consoleGrid
	text$ = prompt$														' !!! don't free prompt$ !!!
	XuiSendMessage (consoleGrid, #Inline, 0, 0, 0, 0, 0, @text$)
	##WHOMASK = whomask
	line$ = text$
	XxxCheckMessages ()
	RETURN (line$)
'
' *****  get input from UNIX stdin  *****
'
console:
	PRINT prompt$;
	a$ = NULL$ (260)
	bufAddr = &a$
	length = 0
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
nextRead:
	DO
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = read ($$STDIN, bufAddr, 256)
		##WHOMASK = whomask
		##LOCKOUT = lockout
'
		IF (a < 0) THEN
			XstSystemErrorToError (errno, @error)
			##ERROR = error
			RETURN
		END IF
'
		IFZ a THEN EXIT DO
		aAddr = &a$
		length = length + (a - 1)		' don't include \n
		lastChar = UBYTEAT (aAddr, length)
		IF (lastChar = '\n') THEN
			UBYTEAT (aAddr, length)	= 0					' null terminator on top of \n
			prevChar = UBYTEAT (aAddr, length-1)
			IF (prevChar = 13) THEN
				DEC length
				UBYTEAT (aAddr, length) = 0				' null terminator over \r
			END IF
			XLONGAT (aAddr, -8) = length					' length into header
			a$ = LEFT$ (a$, length)								' trim to fit
			RETURN (a$)
		ELSE
			INC length														' keep last character
			a$ = a$ + NULL$ (260)
			bufAddr	= &a$ + length
		END IF
	LOOP
'
'	error
'
	IFZ a THEN
		##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureExhausted)
		RETURN
	END IF
'
	IF errno THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
	END IF
END FUNCTION
'
'
' #######################
' #####  XxxLof ()  #####
' #######################
'
FUNCTION  XxxLof (fileNumber)
	EXTERNAL  errno
	SHARED	FILE	fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)						' console Grid
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
'
	c = lseek (fileHandle, 0, $$SEEK_CUR)					' get file pointer
	IF (c < 0) THEN GOTO SeekError
	s = lseek (fileHandle, 0, $$SEEK_END)					' get file size
	IF (s < 0) THEN GOTO SeekError
	a = lseek (fileHandle, c, $$SEEK_SET)					' restore file pointer
	IF (a < 0) THEN GOTO SeekError
	##WHOMASK = whomask
	##LOCKOUT = lockout
	RETURN (s)
'
'	Error
'
SeekError:
	##LOCKOUT = lockout
	##WHOMASK = whomask
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  XxxOpen ()  #####
' ########################
'
FUNCTION  XxxOpen (file$, mode)
	EXTERNAL  errno
	SHARED	FILE  fileInfo[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IFZ fileInfo[] THEN
		##WHOMASK = 0
		DIM fileInfo[15]
		##WHOMASK = whomask
	END IF
'
	okay = $$TRUE
	consoleGrid = 0
	hideConsole = 0
	f$ = TRIM$ (file$)
	IF (LEFT$(f$,4) = "CON:") THEN
		GOSUB OpenConsole
	 ELSE
		f$ = XstPathString$ (@f$)
		GOSUB OpenFile
	END IF
'
' okay means no error
'
	IF okay THEN
		IF (f$ = "CON:") THEN
			fileNumber = 1
			IFZ ##CONGRID THEN ##CONGRID = consoleGrid
		ELSE
			uFile = UBOUND(fileInfo[])
			FOR fileNumber = 3 TO uFile
				IFZ fileInfo[fileNumber].fileHandle THEN EXIT FOR		' Find an open slot
			NEXT fileNumber
			IF (fileNumber > uFile) THEN													' No room
				uFile = (uFile << 1) OR 3
				##WHOMASK = 0
				REDIM fileInfo[uFile]
				##WHOMASK = whomask
			END IF
		END IF
		fileInfo[fileNumber].fileName			= f$
		fileInfo[fileNumber].fileHandle		= fileHandle
		fileInfo[fileNumber].whomask			= whomask
		fileInfo[fileNumber].consoleGrid	= consoleGrid
		fileInfo[fileNumber].entries			= 1
		IF consoleGrid THEN
			IF (f$ = "CON:") THEN
				XstGetCommandLineArguments (@argc, @argv$[])
				FOR i = 1 TO argc-1
					IF (argv$[i] = "-HideConsole") THEN
						hideConsole = $$TRUE
						EXIT FOR
					END IF
				NEXT i
			END IF
			IFZ hideConsole THEN
				XuiConsole (consoleGrid, #DisplayWindow, 0, 0, 0, 0, 0, 0)
				XgrProcessMessages (-2)
			END IF
		END IF
		RETURN (fileNumber)
	END IF
'
'	error
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
'
'
' *****  OpenConsole  *****
'
SUB OpenConsole
	IF fileInfo[] THEN
		FOR fileNumber = 1 TO UBOUND(fileInfo[])
			IFZ fileInfo[fileNumber].fileHandle THEN DO NEXT
			IF (f$ = TRIM$(fileInfo[fileNumber].fileName)) THEN
				INC fileInfo[fileNumber].entries
				RETURN (fileNumber)
			END IF
		NEXT fileNumber
	END IF
	x = 0 : y = 0												' upper-left corner
	width = 512 : height = 256
	IF (f$ = "CON:") THEN								' System console is in upper left corner
		eighty$ = CHR$('W', 80)
		XgrGetTextImageSize (0, @eighty$, @w, @h, @ww, @hh, @g, @f)
		XgrGetDisplaySize ("", @displayWidth, @displayHeight, @borderWidth, @titleHeight)
		w = w + borderWidth + borderWidth + 16
		x = borderWidth
		y = titleHeight + borderWidth
		width = (displayWidth >> 1) + borderWidth + borderWidth
		height = (displayHeight >> 2) + titleHeight + borderWidth
		IF (w > width) THEN width = w
		IF (width > (displayWidth - borderWidth - borderWidth)) THEN width = displayWidth - borderWidth - borderWidth
	END IF
	XuiConsole (@consoleGrid, #CreateWindow, x, y, width, height, 0, "")
	SELECT CASE mode
		CASE $$WR, $$WRNEW				' Disable Input
					XuiSendMessage (consoleGrid, #SetValues, $$FALSE, 0, 0, 0, 0, 0)
	END SELECT
	XuiSendMessage (consoleGrid, #SetStyle, 2, 0, 0, 0, 0, 0)
	XuiSendMessage (consoleGrid, #GetSize, @x, @y, @w, @h, 0, 0)
	XuiSendMessage (consoleGrid, #Resize, x, y, w, h, 0, 0)
	XuiSendMessage (consoleGrid, #SetColor, 19, -1, -1, -1, 2, 0)
	XuiSendMessage (consoleGrid, #SetColor, 19, -1, -1, -1, 3, 0)
	XuiSendMessage (consoleGrid, #SetWindowTitle, 0, 0, 0, 0, 0, @"Console")
	XuiSendMessage (consoleGrid, #SetHelpString, -1, 0, 0, 0, -1, @"pde.hlp:Console")
'	XuiSendMessage (consoleGrid, #SetHintString, -1, 0, 0, 0, 0, @"source of program input >>>   a$ = INLINE$ (prompt$)\ndestination of program output >>>   PRINT a$")
	XuiSendMessage (consoleGrid, #SetGridProperties, -1, 0, 0, 0, 0, 0)
	fileHandle = -1
END SUB
'
'
' *****  OpenFile  *****
'
SUB OpenFile
'	dir = INSTR (f$, "\\")
'	DO WHILE dir
'		f${dir-1} = '/'								' convert \ into /
'		dir	= INSTR (f$, "\\")
'	LOOP
'
	perms = 0
	unixMode = #O_RDONLY
	SELECT CASE (mode AND 0x0007)
		CASE $$RD			: unixMode	= #O_RDONLY
		CASE $$WR			: unixMode	= #O_WRONLY
		CASE $$RW			: unixMode	= #O_RDWR
		CASE $$WRNEW	: unixMode	= #O_WRONLY | #O_CREAT | #O_TRUNC
										umask			= umask (0o666)									' get umask
										nmask			= umask (umask)									' restore umask
										xmask			= umask{9,0} AND 0o666					' ignore x bit
										perms			= 0o666 AND (NOT xmask)
		CASE $$RWNEW	: unixMode	= #O_RDWR | #O_CREAT | #O_TRUNC
										umask			= umask (0o666)									' get umask
										nmask			= umask (umask)									' restore umask
										xmask			= umask{9,0} AND 0o666					' ignore x bit
										perms			= 0o666 AND (NOT xmask)
	END SELECT
'
'	IFZ (INSTR(f$, "x.log")) THEN XstLog (@f$)
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	fileHandle = open (&f$, unixMode, perms)
	##WHOMASK = whomask
	##LOCKOUT = lockout
	IF (fileHandle = -1) THEN okay = $$FALSE
'	PRINT HEX$(mode,4), HEX$(unixMode,8), OCT$(umask,4);; OCT$(nmask,4);; OCT$(xmask,4);; OCT$(perms,4), fileHandle, errno
END SUB
END FUNCTION
'
'
' #######################
' #####  XxxPof ()  #####
' #######################
'
FUNCTION  XxxPof (fileNumber)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)					' console
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
'
	a = lseek (fileHandle, 0, $$SEEK_CUR)
	IF (a < 0) THEN GOTO SeekError
	##WHOMASK = whomask
	##LOCKOUT = lockout
	RETURN (a)
'
'	Error
'
SeekError:
	##LOCKOUT = lockout
	##WHOMASK = whomask
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  XxxQuit ()  #####
' ########################
'
FUNCTION  XxxQuit (status)
'
	IFZ ##STANDALONE THEN
		IF ##USERRUNNING THEN
			XxxSetBlowback ()
			RETURN
		END IF
	END IF
'
	XxxXgrQuit ()
	XxxTerminate ()
	XxxXitExit (status)
END FUNCTION
'
'
' ############################
' #####  XxxReadFile ()  #####
' ############################
'
FUNCTION  XxxReadFile (fileNumber, buffer, bytes, bytesRead, overlapped)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF (bytes <= 0) THEN RETURN ($$TRUE)
	IF (fileNumber < 0) THEN RETURN ($$FALSE)
	IF (fileNumber > 2) THEN
		IF InvalidFileNumber (fileNumber) THEN RETURN ($$FALSE)
		IFZ fileInfo[] THEN RETURN ($$FALSE)
		fileHandle = fileInfo[fileNumber].fileHandle
		IF (fileHandle = -1) THEN GOSUB ReadConsole ELSE GOSUB ReadFile
		RETURN (result)
	ELSE
		##WHOMASK = 0
		read$ = INLINE$ ("")
		##WHOMASK = whomask
		upper = UBOUND (read$)
		IF (upper > bytes) THEN upper = bytes
		IF (upper >= 0) THEN
			FOR i = 0 TO upper
				UBYTEAT (buffer, i) = read${i}
			NEXT i
			UBYTEAT (buffer, i) = 0
		END IF
		RETURN ($$TRUE)
	END IF
'
'
' *****  ReadConsole  *****
'
SUB ReadConsole
	IFZ fileInfo[1].fileHandle THEN RETURN ($$FALSE)	' not initialized
	FOR i = 0 TO bytes - 1
		UBYTEAT(buffer,i) = 0
	NEXT i
	consoleGrid = fileInfo[fileNumber].consoleGrid
	XuiSendMessage (consoleGrid, #GetTextString, 0, 0, 0, 0, 0, @text$)
	lenText = LEN (text$)
	IFZ lenText THEN RETURN ($$FALSE)
	lastChar = MIN(bytes, lenText)
	FOR i = 0 TO lastChar - 1
		UBYTEAT(buffer,i) = text${i}
	NEXT i
	IF (lastChar < lenText) THEN
		text$ = MID$(text$, lastChar + 1)
	ELSE
		text$ = ""
	END IF
	XuiSendMessage (consoleGrid, #SetTextString, 0, 0, 0, 0, 0, @text$)
	result = $$FALSE
END SUB
'
'
' *****  ReadFile  *****
'
SUB ReadFile
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
	result = read (fileHandle, buffer, bytes)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ########################
' #####  XxxSeek ()  #####
' ########################
'
FUNCTION  XxxSeek (fileNumber, position)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)					' console
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
'
	a = lseek (fileHandle, position, $$SEEK_SET)
	IF (a < 0) THEN GOTO SeekError
	##WHOMASK = whomask
	##LOCKOUT = lockout
	RETURN (a)
'
'	Error
'
SeekError:
	##LOCKOUT = lockout
	##WHOMASK = whomask
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' #########################
' #####  XxxShell ()  #####
' #########################
'
FUNCTION  XxxShell (command$)
	EXTERNAL	errno
'
	lockout = ##LOCKOUT
	whomask = ##WHOMASK
	##LOCKOUT = $$TRUE
	##WHOMASK = 0
'
	c$ = TRIM$(command$)
	IFZ c$ THEN RETURN
	errno = $$FALSE
'
	waitTillProcessCompleted = $$TRUE
	IF (c${0} = ':') THEN
		waitTillProcessCompleted = $$FALSE
		c$ = TRIM$(MID$(c$, 2))
		IFZ c$ THEN RETURN
	END IF
'
	system (&c$)
'	SetSignals ()								' signals must be reset after an exec
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IF errno THEN
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' #########################
' #####  XxxStdio ()  #####
' #########################
'
FUNCTION XxxStdio (in, out, err)
	in  = 0
	out = 1
	err = 2
END FUNCTION
'
'
' #############################
' #####  XxxWriteFile ()  #####
' #############################
'
FUNCTION  XxxWriteFile (fileNumber, buffer, bytes, bytesWritten, overlapped)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	IF (fileNumber < 0) THEN RETURN ($$FALSE)
	IF (fileNumber > 2) THEN
		IFZ bytes THEN RETURN ($$TRUE)
		IF InvalidFileNumber (fileNumber) THEN
			IF (fileNumber != 1) THEN RETURN ($$FALSE)
			IFZ fileInfo[] THEN RETURN ($$FALSE)
			IFZ fileInfo[1].fileHandle THEN RETURN ($$FALSE)	' not initialized
		END IF
	ELSE
		IFZ ##CONGRID THEN						' no GUI console
			write (1, buffer, bytes)		' write to unix console
			RETURN ($$TRUE)
		END IF
	END IF
'
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN GOSUB WriteConsole ELSE GOSUB WriteFile
	RETURN (result)
'
'
' *****  WriteConsole  *****  enable when GUI console is operational
'
SUB WriteConsole
	consoleGrid = fileInfo[fileNumber].consoleGrid
	IF (fileNumber = 1) THEN ##WHOMASK = 0
	text$ = NULL$(bytes)
	FOR i = 0 TO bytes - 1
		text${i} = UBYTEAT(buffer, i)
	NEXT i
	XuiSendMessage (consoleGrid, #Print, 0, 0, 0, 0, 0, @text$)
	IF (fileNumber = 1) THEN ##WHOMASK = whomask
	XxxCheckMessages ()
	result = $$FALSE
END SUB
'
'
' *****  WriteFile  *****
'
SUB WriteFile
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	result = write (fileHandle, buffer, bytes)
	##LOCKOUT = lockout
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' ###########################
' #####  XxxFormat$ ()  #####
' ###########################
'
FUNCTION  XxxFormat$ (format$, argType, arg$$)
	STATIC	UBYTE  fmtLevel[]
	STATIC	UBYTE  fmtBegin[]
'
	IFZ fmtLevel[] THEN GOSUB Initialize
	IFZ format$ THEN RETURN 										' empty format string
'
	IF (argType = $$STRING) THEN arg$ = CSTRING$(GLOW(arg$$))
'
	fmtStrPtr = 1
	lenFmtStr = LEN (format$)
	GOSUB StringString													'	top StringString call
	IFZ fmtStrPtr THEN RETURN (resultString$)
'
' initialize argument counters, flags, etc.
'
	argH	= 0
	argL	= 0
	arg&&	= 0
	lenArg = 0
	negArg = 0
	argStr$	= ""
	argDPLoc = 0
	numShift = 0
	argExpIx = 0
	argExpVal = 0
	argMSDOrder	= 0
'
' initialize format counters, flags, etc.
'
	fmtChar = 0
	lastChar = 0
	nextChar = 0
	levelNow = 0
	levelNext = 0
	nPlaces = 0
	preDec = 0
	postDec = 0
	expCtr = 0
	hasDec = 0
	commaFlag = 0
	padFlag = 0
	dollarSign$ = ""
	leadSign$ = ""
	trailSign$ = ""
	errSign$ = ""
'
' Format argument and add it to the result loop
'
	DO
		lastChar = fmtChar
		fmtChar = format${fmtStrPtr-1}
'
		IFZ ((fmtChar = '#') AND ((lastChar = ',') OR (lastChar = '.') OR (lastChar = '#'))) THEN
				levelNow  = fmtLevel[fmtChar]
		END IF
'
		IF (fmtStrPtr = lenFmtStr) THEN							' check for end of fmt string
			nextChar = 'A'														'   set bogus next char
		ELSE
			nextChar  = format${fmtStrPtr}					'   get real next char
		END IF
'
		IF ((nextChar = '#') AND ((fmtChar = ',') OR (fmtChar = '.') OR (fmtChar = '#'))) THEN
			levelNext = levelNow
		ELSE
			levelNext = fmtLevel[nextChar]
		END IF
'
' Unformatted string "format"
'
		IF (fmtChar = '&') THEN
			IF (argType != $$STRING) THEN
				PRINT "Numeric data with '&'"
				GOTO eeeQuitFormat
			END IF
			resultString$ = resultString$ + arg$
			INC fmtStrPtr
			EXIT DO
		END IF
		INC nPlaces
'
		SELECT CASE fmtChar
			CASE '$': dollarSign$ = "$"
			CASE ',':	commaFlag = $$TRUE
								INC preDec
			CASE '*': padFlag = $$TRUE
								INC preDec
			CASE '.': hasDec = 1
			CASE '#': IF hasDec THEN
									INC postDec
								ELSE
									INC preDec
								END IF
			CASE '-': INC preDec						' sign can only be leading here.
			CASE '+', '('
								IFZ leadSign$ THEN
									leadSign$ = CHR$ (fmtChar)
								ELSE
									PRINT "Leading"; leadSign$; "excludes"; CHR$ (fmtChar)
									GOTO eeeQuitFormat
								END IF
		END SELECT
'
' case < or | or >:		all we needed to do is count them
' End of char fmt:		add to resultString$, and exit loop
'
		IF (((fmtChar = '<') OR (fmtChar = '|') OR (fmtChar = '>')) AND (nextChar != fmtChar)) THEN
			IF (argType != $$STRING) THEN
				PRINT "Can't print a number with a string format."
				GOTO eeeQuitFormat
			END IF
			SELECT CASE fmtChar
				CASE '<': resultString$ = resultString$ + LJUST$(arg$, nPlaces)
				CASE '|': resultString$ = resultString$ + CJUST$(arg$, nPlaces)
				CASE '>': resultString$ = resultString$ + RJUST$(arg$, nPlaces)
			END SELECT
			INC fmtStrPtr
			EXIT DO
		END IF
'
' SPECIAL TRAILING NUMERIC FMT INFO
'
' get exponent: !! new nextChar$ if legit exponent !!
'
		IF (nextChar = '^') THEN
			DO																				' count ^s
				INC expCtr
				IF (format${fmtStrPtr + expCtr} != '^') THEN EXIT DO
			LOOP UNTIL (expCtr = 5)
'
			IF (expCtr >= 4) THEN											' legitimate exponent
				nPlaces    = nPlaces    + expCtr
				fmtStrPtr  = fmtStrPtr  + expCtr
				nextChar   = format${fmtStrPtr}					' to look for trailing +, -, )
			ELSE
				expCtr = 0															' reset if not valid exponent
			END IF
		END IF
'
' look for trailing + or - in nextChar here. add flags
'
		IF (((nextChar = '-') OR (nextChar = '+')) AND (leadSign$ = "")) THEN
			trailSign$ = CHR$ (nextChar)
'
' incr ptrs: trailing sign picked up (but don't leave loop yet).
'
			levelNext = 0
			INC nPlaces
			INC fmtStrPtr
		END IF
'
' get closing parenthesis; legit only if opening parenthesis has been set.
'
		IF ((nextChar = ')') AND (leadSign$ = "(")) THEN
			trailSign$ = CHR$ (nextChar)
			INC nPlaces
			INC fmtStrPtr
		END IF
'
' a second '.' means the beginning of a new fmt.
'
		IF (hasDec AND (nextChar = '.')) THEN levelNext = 0
'
' End of num fmt: validate fmt, add to resultString$ and exit loop.
'
		IF (levelNext < levelNow) THEN
			IFZ (preDec + postDec) THEN
				PRINT "No printable digits"
				GOTO eeeQuitFormat
			END IF
'
' missing close parenthesis: treat open paren as fixed.
'
			IF ((leadSign$ = "(") AND (trailSign$ != ")")) THEN
				resultString$ = resultString$ + "("
				leadSign$ = ""
				DEC nPlaces
			END IF
'
' Get argument
'
			IF (argType = $$STRING) THEN GOTO eeeQuitFormat
			argH  = GHIGH(arg$$)
			argL  = GLOW (arg$$)
			arg&& = GLOW (arg$$)				' type casts XLONG as ULONG
			arg		= GLOW (arg$$)
'
			SELECT CASE argType
				CASE $$DOUBLE	: argStr$ = STR$ (DMAKE(argH, argL))
				CASE $$SINGLE	: argStr$ = STR$ (SMAKE(argL))
				CASE $$GIANT	: argStr$ = STR$ (arg$$)
				CASE $$ULONG	: argStr$ = STR$ (arg&&)
				CASE ELSE			: argStr$ = STR$ (arg)
			END SELECT
'
' decompose argument string: sign, exponent, length and DP location
'
' get sign: the 1st column of argStr$ will always be '-' or ' '.
'
			negArg = argStr${0}
			argStr$ = MID$(argStr$, 2)
'
' remove any exponent from argStr$. argExpVal is its numeric value.
'
			argExpIx = INCHR(argStr$, "de")
			argExpVal = 0
			IF (argExpIx > 0) THEN
				argExpVal = XLONG (MID$(argStr$, argExpIx + 1))
				argStr$ = LEFT$ (argStr$, argExpIx - 1)
			END IF
'
' length of argument string after sign, exponent and DP are removed
'
			lenArg = LEN (argStr$)
'
' get argument decimal point location. Remove it from argStr and
'		deincrement lenArg if needed.
'
			argDPLoc = INSTR (argStr$, ".")
			IFZ argDPLoc THEN
				argDPLoc = lenArg + 1
			ELSE
				argStr$ = LEFT$(argStr$, argDPLoc -1) + MID$(argStr$, argDPLoc +1)
				DEC lenArg
			END IF
'
' Remove leading '0'.
'
			k = 0
			DO WHILE argStr${k} = '0'
				DEC argExpVal
				INC k
			LOOP
			argStr$ = MID$(argStr$, k+1)
			lenArg = lenArg - k
'
' argMSDOrder, if pos, is the exponent of the most significant digit.
'		if neg, it is one less than the exponent.
'
			argMSDOrder = argDPLoc - 1 + argExpVal
'
' numShift is the power of 10 difference between the MSD of the format
'		and the MSD of the argument
'
			numShift = preDec - argMSDOrder
'
' put numeric argument string and format together
'
			IFZ expCtr THEN											' formats without an exponent
				IF (numShift > 0) THEN
					argStr$ = CHR$ ('0', numShift) + argStr$
					lenArg = lenArg + numShift
				END IF
				GOSUB Rounder
'
' restore DP and add commas
'
				IF hasDec THEN
					IF (preDec > argMSDOrder) THEN
						argStr$ = LEFT$(argStr$, preDec) + "." + MID$(argStr$, preDec +1)
						comIx = preDec
					ELSE
						argStr$ = LEFT$(argStr$, argMSDOrder) + "." + MID$(argStr$, argMSDOrder +1)
						comIx = argMSDOrder
					END IF
				END IF
'
				IF (commaFlag AND (argMSDOrder > 3)) THEN GOSUB AddCommas
'
' strip off any leading 0s before DP
'
				IF ((argMSDOrder < preDec) AND (preDec > 0)) THEN
					IF (argMSDOrder <= 1) THEN
						argStr$ = MID$(argStr$, preDec)
					ELSE
						argStr$ = MID$(argStr$, preDec - argMSDOrder + 1)
					END IF
				END IF
'
' if not enough digits in format then set mess up formatting flag
'
				IF (LEN(argStr$) > (preDec + postDec + hasDec)) THEN errSign$ = "%"
			ELSE										' formats with exponent
				GOSUB Rounder					' round off significant digits
'
' restore DP
'
				IF hasDec THEN argStr$ = LEFT$(argStr$, preDec) + "." + MID$(argStr$, preDec +1)
'
' get exponent in usable form
'
				expString$ = STR$ (numShift * -1)
				IF (expString${0} = ' ') THEN expString${0} = '+'
				expLen = LEN (expString$)
				DEC expCtr
'
				SELECT CASE TRUE
					CASE (expLen < expCtr)
								expString$ = LEFT$ (expString$, 1) + CHR$ ('0', expCtr - expLen) + MID$ (expString$, 2)
					CASE (expLen > expCtr)
								errSign$ = "%"
				END SELECT
				argStr$ = argStr$ + "E" + expString$
			END IF
'
' take care of leading and trailing sign stuff
'
			IF (negArg = '-') THEN
				SELECT CASE TRUE
					CASE (leadSign$ = "") AND (trailSign$ = ""):	leadSign$  = "-"
					CASE (leadSign$ = "+"):												leadSign$  = "-"
					CASE (trailSign$ = "+"):											trailSign$ = "-"
				END SELECT
			ELSE
				SELECT CASE TRUE
					CASE (leadSign$ = "(") AND (trailSign$ = ")")
								leadSign$ = " "
								trailSign$ = " "
					CASE trailSign$ = "-"
								trailSign$ = " "
				END SELECT
			END IF
'
' add signs and padding as necessary
'
			argStr$ = leadSign$ + dollarSign$ + argStr$ + trailSign$
			padLen  = nPlaces - LEN(argStr$)
			IF (padLen > 0) THEN
				IF padFlag THEN
					argStr$ = CHR$ ('*', padLen) + argStr$
				ELSE
					argStr$ = CHR$ (' ', padLen) + argStr$
				END IF
			END IF
			resultString$ = resultString$ + errSign$ + argStr$
			INC fmtStrPtr
			EXIT DO
		END IF
		INC fmtStrPtr							' incremented when looping through fmt chars
	LOOP
	GOSUB StringString					' get trailing constant string, if any
'
' reset fmt string ptrs to cycle through again as necessary
'
	IF ((fmtStrPtr = 0) AND (argIx < nArg-1)) THEN
		fmtStrPtr = 1
		GOSUB StringString
	END IF
	RETURN (resultString$)
'
'
' *****  Initialize  *****
'
SUB Initialize
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
	DIM fmtLevel[255]		' initialize format character priority level arrays
	DIM fmtBegin[255]
'
' All format characters are listed in fmtLevel.
' The fmtBegin array is used to determine the legitimacy of formats
' that cannot stand alone. These formats require a sequence of characters
' to establish their legitimacy.
' The lower the format level value, the higher the priority, so the
' characters not given a priority level here default to fmtlevel[] = 0,
' and therefore the highest priority. The lowest priority = 255.
'
	fmtLevel['&'] =  20
	fmtLevel['<'] =  30
	fmtLevel['|'] =  30
	fmtLevel['>'] =  30
	fmtLevel['+'] =  40:	fmtBegin['+'] =  40
	fmtLevel['-'] =  40:	fmtBegin['-'] =  40
	fmtLevel['('] =  40:	fmtBegin['('] =  40
	fmtLevel['*'] =  50:	fmtBegin['*'] =  50
	fmtLevel['$'] =  60:	fmtBegin['$'] =  60
	fmtLevel['#'] =  70
	fmtLevel[','] =  80:	fmtBegin[','] =  80
	fmtLevel['.'] =  90:	fmtBegin['.'] =  90
'
'	fmtLevel['^'] =   0		' When these two are format characters, they will be
'	fmtLevel[')'] =   0		' picked up by checking nextChar (just like trailing
'													' signs).
	##WHOMASK = whomask
END SUB
'
' *****  StringString  *****
'
SUB StringString
	DO
		fmtThisPtr = fmtStrPtr - 1
		q = format${fmtThisPtr}
		qq = fmtBegin[q]
		qqq = fmtLevel[q]
		IFZ q THEN EXIT DO
		r = format${fmtStrPtr}
		SELECT CASE TRUE
			CASE (q = '_')	: INC fmtStrPtr: q = r
			CASE qq					: IF ValidFormat (format$, fmtThisPtr) THEN EXIT DO
			CASE qqq				: EXIT DO
		END SELECT
		resultString$ = resultString$ + CHR$ (q)
		INC fmtStrPtr
	LOOP
	IF (fmtStrPtr > lenFmtStr) THEN fmtStrPtr = 0
END SUB
'
' *****  AddCommas  *****
'
SUB AddCommas
	DO WHILE comIx > (preDec - argMSDOrder + 3)
		comIx = comIx - 3
		argStr$ = LEFT$(argStr$, comIx) + "," + MID$(argStr$, comIx+1)
		INC lenArg
	LOOP
END SUB
'
' *****  Rounder  *****
'
SUB Rounder
	IF ((expCtr = 0) AND (numShift < 0)) THEN		' no fmt exp & int(arg) > int(fmt)
		fmtDigCtr = argMSDOrder + postDec
	ELSE
		fmtDigCtr = preDec + postDec
	END IF
'
	IF (lenArg > fmtDigCtr) THEN
		rndDig  = argStr${fmtDigCtr}
		argStr$ = LEFT$(argStr$, fmtDigCtr)
'
		IF (rndDig >= '5') THEN
			stopIt = $$FALSE
			DO UNTIL stopIt OR (fmtDigCtr = 0)		' DO WHILE (fmtDigCtr) in using9.x
				DEC fmtDigCtr
				lastDig = argStr${fmtDigCtr}
				INC lastDig
				IF (lastDig = 0x3a) THEN
					lastDig = '0'											' 9 -> 0: keep rounding
				ELSE
					stopIt = $$TRUE										' no more rounding
				END IF
				argStr${fmtDigCtr} = lastDig
			LOOP																	' LOOP UNTIL (stopIt) in using9.x
'
			IF (stopIt AND (fmtDigCtr < numShift) AND (expCtr == 0)) THEN		' added significant digit
				INC argMSDOrder
				DEC numShift
			END IF
'
			IF !stopIt THEN																' ran out of format digits
				IFZ expCtr THEN
					argStr$ = "1" + argStr$
				ELSE
					argStr${0} = '1'
				END IF
				INC argMSDOrder
				DEC numShift
			END IF
		END IF																					' rndDig >= '5'
	ELSE																							' lenArg <= fmtDigCtr
		argStr$ = argStr$ + CHR$ ('0', fmtDigCtr - lenArg)
	END IF
END SUB
'
eeeQuitFormat:
	##ERROR = $$ErrorNatureInvalidArgument
	RETURN (resultString$)
END FUNCTION
'
'
' ##############################
' #####  CreateConsole ()  #####
' ##############################
'
FUNCTION  CreateConsole ()
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
'
	noConsole = $$FALSE
	XstGetCommandLineArguments (@argc, @argv$[])
'
	FOR i = 1 TO argc-1
		IF (argv$[i] = "-NoConsole") THEN
			noConsole = $$TRUE
			EXIT FOR
		END IF
	NEXT i
	DIM argv$[]

	IFZ noConsole THEN
		confile = XxxOpen ("CON:", $$RD)
		DO
			XgrMessagesPending (@count)
			XgrProcessMessages (count)
		LOOP WHILE count
	END IF
'
	##WHOMASK = whomask
END FUNCTION
'
'
' ##############################
' #####  DeltaTimeZone ()  #####
' ##############################
'
FUNCTION  DeltaTimeZone (delta)
	UTIMEB  timeb
	UTM  ltime, gtime
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	ftime (&timeb)
	gtime = gmtime (&timeb.time)
	ltime = localtime (&timeb.time)
	ggtime = mktime (&gtime)
	lltime = mktime (&ltime)
	delta = lltime - ggtime
	##WHOMASK = whomask
	##LOCKOUT = lockout
END FUNCTION
'
'
' ########################
' #####  InitGui ()  #####
' ########################
'
' InitGui() initializes cursor, icon, message, and display variables.
' Programs can reference these variables, but must never change them.
'
FUNCTION  InitGui ()
'
' ***************************************
' *****  Register Standard Cursors  *****
' ***************************************
'
	XgrRegisterCursor (@"arrow",			@#defaultCursor)
	XgrRegisterCursor (@"arrow",			@#cursorDefault)
	XgrRegisterCursor (@"arrow",			@#cursorArrow)
	XgrRegisterCursor (@"arrow",			@#cursorArrowNW)
	XgrRegisterCursor (@"n",					@#cursorArrowN)
	XgrRegisterCursor (@"ns",					@#cursorArrowsNS)
	XgrRegisterCursor (@"we",					@#cursorArrowsWE)
	XgrRegisterCursor (@"nwse",				@#cursorArrowsNWSE)
	XgrRegisterCursor (@"nesw",				@#cursorArrowsNESW)
	XgrRegisterCursor (@"all",				@#cursorArrowsAll)
	XgrRegisterCursor (@"crosshair",	@#cursorCrosshair)
	XgrRegisterCursor (@"plus",				@#cursorPlus)
	XgrRegisterCursor (@"wait",				@#cursorHourglass)
	XgrRegisterCursor (@"insert",			@#cursorInsert)
	XgrRegisterCursor (@"no",					@#cursorNo)
'
'
' ********************************************
' *****  Register Standard Window Icons  *****
' ********************************************
'
	XgrRegisterIcon (@"hand",					@#iconHand)
	XgrRegisterIcon (@"asterisk",			@#iconAsterisk)
	XgrRegisterIcon (@"question",			@#iconQuestion)
	XgrRegisterIcon (@"exclamation",	@#iconExclamation)
	XgrRegisterIcon (@"application",	@#iconApplication)
'
	XgrRegisterIcon (@"hand",					@#iconStop)						' alias
	XgrRegisterIcon (@"asterisk",			@#iconInformation)		' alias
	XgrRegisterIcon (@"application",  @#iconBlank)					' alias
'
	XgrRegisterIcon (@"window",				@#iconWindow)					' custom
'
'
' ******************************
' *****  Register Messages *****  Create message numbers for message names
' ******************************
'
	XgrRegisterMessage (@"Blowback",										@#Blowback)
	XgrRegisterMessage (@"Callback",										@#Callback)
	XgrRegisterMessage (@"Cancel",											@#Cancel)
	XgrRegisterMessage (@"Change",											@#Change)
	XgrRegisterMessage (@"CloseWindow",									@#CloseWindow)
	XgrRegisterMessage (@"ContextChange",								@#ContextChange)
	XgrRegisterMessage (@"Create",											@#Create)
	XgrRegisterMessage (@"CreateValueArray",						@#CreateValueArray)
	XgrRegisterMessage (@"CreateWindow",								@#CreateWindow)
	XgrRegisterMessage (@"CursorH",											@#CursorH)
	XgrRegisterMessage (@"CursorV",											@#CursorV)
	XgrRegisterMessage (@"Deselected",									@#Deselected)
	XgrRegisterMessage (@"Destroy",											@#Destroy)
	XgrRegisterMessage (@"Destroyed",										@#Destroyed)
	XgrRegisterMessage (@"DestroyWindow",								@#DestroyWindow)
	XgrRegisterMessage (@"Disable",											@#Disable)
	XgrRegisterMessage (@"Disabled",										@#Disabled)
	XgrRegisterMessage (@"Displayed",										@#Displayed)
	XgrRegisterMessage (@"DisplayWindow",								@#DisplayWindow)
	XgrRegisterMessage (@"Enable",											@#Enable)
	XgrRegisterMessage (@"Enabled",											@#Enabled)
	XgrRegisterMessage (@"Enter",												@#Enter)
	XgrRegisterMessage (@"ExitMessageLoop",							@#ExitMessageLoop)
	XgrRegisterMessage (@"Find",												@#Find)
	XgrRegisterMessage (@"FindForward",									@#FindForward)
	XgrRegisterMessage (@"FindReverse",									@#FindReverse)
	XgrRegisterMessage (@"Forward",											@#Forward)
	XgrRegisterMessage (@"GetAlign",										@#GetAlign)
	XgrRegisterMessage (@"GetBorder",										@#GetBorder)
	XgrRegisterMessage (@"GetBorderOffset",							@#GetBorderOffset)
	XgrRegisterMessage (@"GetCallback",									@#GetCallback)
	XgrRegisterMessage (@"GetCallbackArgs",							@#GetCallbackArgs)
	XgrRegisterMessage (@"GetCan",											@#GetCan)
	XgrRegisterMessage (@"GetCharacterMapArray",				@#GetCharacterMapArray)
	XgrRegisterMessage (@"GetCharacterMapEntry",				@#GetCharacterMapEntry)
	XgrRegisterMessage (@"GetClipGrid",									@#GetClipGrid)
	XgrRegisterMessage (@"GetColor",										@#GetColor)
	XgrRegisterMessage (@"GetColorExtra",								@#GetColorExtra)
	XgrRegisterMessage (@"GetCursor",										@#GetCursor)
	XgrRegisterMessage (@"GetCursorXY",									@#GetCursorXY)
	XgrRegisterMessage (@"GetDisplay",									@#GetDisplay)
	XgrRegisterMessage (@"GetEnclosedGrids",						@#GetEnclosedGrids)
	XgrRegisterMessage (@"GetEnclosingGrid",						@#GetEnclosingGrid)
	XgrRegisterMessage (@"GetFocusColor",								@#GetFocusColor)
	XgrRegisterMessage (@"GetFocusColorExtra",					@#GetFocusColorExtra)
	XgrRegisterMessage (@"GetFont",											@#GetFont)
	XgrRegisterMessage (@"GetFontMetrics",							@#GetFontMetrics)
	XgrRegisterMessage (@"GetFontNumber",								@#GetFontNumber)
	XgrRegisterMessage (@"GetGridFunction",							@#GetGridFunction)
	XgrRegisterMessage (@"GetGridFunctionName",					@#GetGridFunctionName)
	XgrRegisterMessage (@"GetGridName",									@#GetGridName)
	XgrRegisterMessage (@"GetGridNumber",								@#GetGridNumber)
	XgrRegisterMessage (@"GetGridProperties",						@#GetGridProperties)
	XgrRegisterMessage (@"GetGridType",									@#GetGridType)
	XgrRegisterMessage (@"GetGridTypeName",							@#GetGridTypeName)
	XgrRegisterMessage (@"GetGroup",										@#GetGroup)
	XgrRegisterMessage (@"GetHelp",											@#GetHelp)
	XgrRegisterMessage (@"GetHelpFile",									@#GetHelpFile)
	XgrRegisterMessage (@"GetHelpString",								@#GetHelpString)
	XgrRegisterMessage (@"GetHelpStrings",							@#GetHelpStrings)
	XgrRegisterMessage (@"GetHintString",								@#GetHintString)
	XgrRegisterMessage (@"GetImage",										@#GetImage)
	XgrRegisterMessage (@"GetImageCoords",							@#GetImageCoords)
	XgrRegisterMessage (@"GetIndent",										@#GetIndent)
	XgrRegisterMessage (@"GetInfo",											@#GetInfo)
	XgrRegisterMessage (@"GetJustify",									@#GetJustify)
	XgrRegisterMessage (@"GetKeyboardFocus",						@#GetKeyboardFocus)
	XgrRegisterMessage (@"GetKeyboardFocusGrid",				@#GetKeyboardFocusGrid)
	XgrRegisterMessage (@"GetKidArray",									@#GetKidArray)
	XgrRegisterMessage (@"GetKidNumber",								@#GetKidNumber)
	XgrRegisterMessage (@"GetKids",											@#GetKids)
	XgrRegisterMessage (@"GetKind",											@#GetKind)
	XgrRegisterMessage (@"GetMaxMinSize",								@#GetMaxMinSize)
	XgrRegisterMessage (@"GetMenuEntryArray",						@#GetMenuEntryArray)
	XgrRegisterMessage (@"GetMessageFunc",							@#GetMessageFunc)
	XgrRegisterMessage (@"GetMessageFuncArray",					@#GetMessageFuncArray)
	XgrRegisterMessage (@"GetMessageSub",								@#GetMessageSub)
	XgrRegisterMessage (@"GetMessageSubArray",					@#GetMessageSubArray)
	XgrRegisterMessage (@"GetModalInfo",								@#GetModalInfo)
	XgrRegisterMessage (@"GetModalWindow",							@#GetModalWindow)
	XgrRegisterMessage (@"GetParent",										@#GetParent)
	XgrRegisterMessage (@"GetPosition",									@#GetPosition)
	XgrRegisterMessage (@"GetProtoInfo",								@#GetProtoInfo)
	XgrRegisterMessage (@"GetRedrawFlags",							@#GetRedrawFlags)
	XgrRegisterMessage (@"GetSize",											@#GetSize)
	XgrRegisterMessage (@"GetSmallestSize",							@#GetSmallestSize)
	XgrRegisterMessage (@"GetState",										@#GetState)
	XgrRegisterMessage (@"GetStyle",										@#GetStyle)
	XgrRegisterMessage (@"GetTabArray",									@#GetTabArray)
	XgrRegisterMessage (@"GetTabWidth",									@#GetTabWidth)
	XgrRegisterMessage (@"GetTextArray",								@#GetTextArray)
	XgrRegisterMessage (@"GetTextArrayBounds",					@#GetTextArrayBounds)
	XgrRegisterMessage (@"GetTextArrayLine",						@#GetTextArrayLine)
	XgrRegisterMessage (@"GetTextArrayLines",						@#GetTextArrayLines)
	XgrRegisterMessage (@"GetTextCursor",								@#GetTextCursor)
	XgrRegisterMessage (@"GetTextFilename",							@#GetTextFilename)
	XgrRegisterMessage (@"GetTextPosition",							@#GetTextPosition)
	XgrRegisterMessage (@"GetTextSelection",						@#GetTextSelection)
	XgrRegisterMessage (@"GetTextSpacing",							@#GetTextSpacing)
	XgrRegisterMessage (@"GetTextString",								@#GetTextString)
	XgrRegisterMessage (@"GetTextStrings",							@#GetTextStrings)
	XgrRegisterMessage (@"GetTexture",									@#GetTexture)
	XgrRegisterMessage (@"GetTimer",										@#GetTimer)
	XgrRegisterMessage (@"GetValue",										@#GetValue)
	XgrRegisterMessage (@"GetValueArray",								@#GetValueArray)
	XgrRegisterMessage (@"GetValues",										@#GetValues)
	XgrRegisterMessage (@"GetWindow",										@#GetWindow)
	XgrRegisterMessage (@"GetWindowFunction",						@#GetWindowFunction)
	XgrRegisterMessage (@"GetWindowGrid",								@#GetWindowGrid)
	XgrRegisterMessage (@"GetWindowIcon",								@#GetWindowIcon)
	XgrRegisterMessage (@"GetWindowSize",								@#GetWindowSize)
	XgrRegisterMessage (@"GetWindowTitle",							@#GetWindowTitle)
	XgrRegisterMessage (@"GotKeyboardFocus",						@#GotKeyboardFocus)
	XgrRegisterMessage (@"GrabArray",										@#GrabArray)
	XgrRegisterMessage (@"GrabTextArray",								@#GrabTextArray)
	XgrRegisterMessage (@"GrabTextString",							@#GrabTextString)
	XgrRegisterMessage (@"GrabValueArray",							@#GrabValueArray)
	XgrRegisterMessage (@"Help",												@#Help)
	XgrRegisterMessage (@"Hidden",											@#Hidden)
	XgrRegisterMessage (@"HideTextCursor",							@#HideTextCursor)
	XgrRegisterMessage (@"HideWindow",									@#HideWindow)
	XgrRegisterMessage (@"Initialize",									@#Initialize)
	XgrRegisterMessage (@"Initialized",									@#Initialized)
	XgrRegisterMessage (@"Inline",											@#Inline)
	XgrRegisterMessage (@"InquireText",									@#InquireText)
	XgrRegisterMessage (@"KeyboardFocusBackward",				@#KeyboardFocusBackward)
	XgrRegisterMessage (@"KeyboardFocusForward",				@#KeyboardFocusForward)
	XgrRegisterMessage (@"KeyDown",											@#KeyDown)
	XgrRegisterMessage (@"KeyUp",												@#KeyUp)
	XgrRegisterMessage (@"LostKeyboardFocus",						@#LostKeyboardFocus)
	XgrRegisterMessage (@"LostTextSelection",						@#LostTextSelection)
	XgrRegisterMessage (@"Maximized",										@#Maximized)
	XgrRegisterMessage (@"MaximizeWindow",							@#MaximizeWindow)
	XgrRegisterMessage (@"Maximum",											@#Maximum)
	XgrRegisterMessage (@"Minimized",										@#Minimized)
	XgrRegisterMessage (@"MinimizeWindow",							@#MinimizeWindow)
	XgrRegisterMessage (@"Minimum",											@#Minimum)
	XgrRegisterMessage (@"MonitorContext",							@#MonitorContext)
	XgrRegisterMessage (@"MonitorHelp",									@#MonitorHelp)
	XgrRegisterMessage (@"MonitorKeyboard",							@#MonitorKeyboard)
	XgrRegisterMessage (@"MonitorMouse",								@#MonitorMouse)
	XgrRegisterMessage (@"MouseDown",										@#MouseDown)
	XgrRegisterMessage (@"MouseDrag",										@#MouseDrag)
	XgrRegisterMessage (@"MouseEnter",									@#MouseEnter)
	XgrRegisterMessage (@"MouseExit",										@#MouseExit)
	XgrRegisterMessage (@"MouseMove",										@#MouseMove)
	XgrRegisterMessage (@"MouseUp",											@#MouseUp)
	XgrRegisterMessage (@"MouseWheel",									@#MouseWheel)
	XgrRegisterMessage (@"MuchLess",										@#MuchLess)
	XgrRegisterMessage (@"MuchMore",										@#MuchMore)
	XgrRegisterMessage (@"Notify",											@#Notify)
	XgrRegisterMessage (@"OneLess",											@#OneLess)
	XgrRegisterMessage (@"OneMore",											@#OneMore)
	XgrRegisterMessage (@"PokeArray",										@#PokeArray)
	XgrRegisterMessage (@"PokeTextArray",								@#PokeTextArray)
	XgrRegisterMessage (@"PokeTextString",							@#PokeTextString)
	XgrRegisterMessage (@"PokeValueArray",							@#PokeValueArray)
	XgrRegisterMessage (@"Print",												@#Print)
	XgrRegisterMessage (@"Redraw",											@#Redraw)
	XgrRegisterMessage (@"RedrawGrid",									@#RedrawGrid)
	XgrRegisterMessage (@"RedrawLines",									@#RedrawLines)
	XgrRegisterMessage (@"Redrawn",											@#Redrawn)
	XgrRegisterMessage (@"RedrawText",									@#RedrawText)
	XgrRegisterMessage (@"RedrawWindow",								@#RedrawWindow)
	XgrRegisterMessage (@"Replace",											@#Replace)
	XgrRegisterMessage (@"ReplaceForward",							@#ReplaceForward)
	XgrRegisterMessage (@"ReplaceReverse",							@#ReplaceReverse)
	XgrRegisterMessage (@"Reset",												@#Reset)
	XgrRegisterMessage (@"Resize",											@#Resize)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"ResizeNot",										@#ResizeNot)
	XgrRegisterMessage (@"ResizeWindow",								@#ResizeWindow)
	XgrRegisterMessage (@"ResizeWindowToGrid",					@#ResizeWindowToGrid)
	XgrRegisterMessage (@"Resized",											@#Resized)
	XgrRegisterMessage (@"Reverse",											@#Reverse)
	XgrRegisterMessage (@"ScrollH",											@#ScrollH)
	XgrRegisterMessage (@"ScrollV",											@#ScrollV)
	XgrRegisterMessage (@"Select",											@#Select)
	XgrRegisterMessage (@"Selected",										@#Selected)
	XgrRegisterMessage (@"Selection",										@#Selection)
	XgrRegisterMessage (@"SelectWindow",								@#SelectWindow)
	XgrRegisterMessage (@"SetAlign",										@#SetAlign)
	XgrRegisterMessage (@"SetBorder",										@#SetBorder)
	XgrRegisterMessage (@"SetBorderOffset",							@#SetBorderOffset)
	XgrRegisterMessage (@"SetCallback",									@#SetCallback)
	XgrRegisterMessage (@"SetCan",											@#SetCan)
	XgrRegisterMessage (@"SetCharacterMapArray",				@#SetCharacterMapArray)
	XgrRegisterMessage (@"SetCharacterMapEntry",				@#SetCharacterMapEntry)
	XgrRegisterMessage (@"SetClipGrid",									@#SetClipGrid)
	XgrRegisterMessage (@"SetColor",										@#SetColor)
	XgrRegisterMessage (@"SetColorAll",									@#SetColorAll)
	XgrRegisterMessage (@"SetColorExtra",								@#SetColorExtra)
	XgrRegisterMessage (@"SetColorExtraAll",						@#SetColorExtraAll)
	XgrRegisterMessage (@"SetCursor",										@#SetCursor)
	XgrRegisterMessage (@"SetCursorXY",									@#SetCursorXY)
	XgrRegisterMessage (@"SetDisplay",									@#SetDisplay)
	XgrRegisterMessage (@"SetFocusColor",								@#SetFocusColor)
	XgrRegisterMessage (@"SetFocusColorExtra",					@#SetFocusColorExtra)
	XgrRegisterMessage (@"SetFont",											@#SetFont)
	XgrRegisterMessage (@"SetFontNumber",								@#SetFontNumber)
	XgrRegisterMessage (@"SetGridFunction",							@#SetGridFunction)
	XgrRegisterMessage (@"SetGridFunctionName",					@#SetGridFunctionName)
	XgrRegisterMessage (@"SetGridName",									@#SetGridName)
	XgrRegisterMessage (@"SetGridProperties",						@#SetGridProperties)
	XgrRegisterMessage (@"SetGridType",									@#SetGridType)
	XgrRegisterMessage (@"SetGridTypeName",							@#SetGridTypeName)
	XgrRegisterMessage (@"SetGroup",										@#SetGroup)
	XgrRegisterMessage (@"SetHelp",											@#SetHelp)
	XgrRegisterMessage (@"SetHelpFile",									@#SetHelpFile)
	XgrRegisterMessage (@"SetHelpString",								@#SetHelpString)
	XgrRegisterMessage (@"SetHelpStrings",							@#SetHelpStrings)
	XgrRegisterMessage (@"SetHintString",								@#SetHintString)
	XgrRegisterMessage (@"SetImage",										@#SetImage)
	XgrRegisterMessage (@"SetImageCoords",							@#SetImageCoords)
	XgrRegisterMessage (@"SetIndent",										@#SetIndent)
	XgrRegisterMessage (@"SetInfo",											@#SetInfo)
	XgrRegisterMessage (@"SetJustify",									@#SetJustify)
	XgrRegisterMessage (@"SetKeyboardFocus",						@#SetKeyboardFocus)
	XgrRegisterMessage (@"SetKeyboardFocusGrid",				@#SetKeyboardFocusGrid)
	XgrRegisterMessage (@"SetKidArray",									@#SetKidArray)
	XgrRegisterMessage (@"SetMaxMinSize",								@#SetMaxMinSize)
	XgrRegisterMessage (@"SetMenuEntryArray",						@#SetMenuEntryArray)
	XgrRegisterMessage (@"SetMessageFunc",							@#SetMessageFunc)
	XgrRegisterMessage (@"SetMessageFuncArray",					@#SetMessageFuncArray)
	XgrRegisterMessage (@"SetMessageSub",								@#SetMessageSub)
	XgrRegisterMessage (@"SetMessageSubArray",					@#SetMessageSubArray)
	XgrRegisterMessage (@"SetModalWindow",							@#SetModalWindow)
	XgrRegisterMessage (@"SetParent",										@#SetParent)
	XgrRegisterMessage (@"SetPosition",									@#SetPosition)
	XgrRegisterMessage (@"SetRedrawFlags",							@#SetRedrawFlags)
	XgrRegisterMessage (@"SetSize",											@#SetSize)
	XgrRegisterMessage (@"SetState",										@#SetState)
	XgrRegisterMessage (@"SetStyle",										@#SetStyle)
	XgrRegisterMessage (@"SetTabArray",									@#SetTabArray)
	XgrRegisterMessage (@"SetTabWidth",									@#SetTabWidth)
	XgrRegisterMessage (@"SetTextArray",								@#SetTextArray)
	XgrRegisterMessage (@"SetTextArrayLine",						@#SetTextArrayLine)
	XgrRegisterMessage (@"SetTextArrayLines",						@#SetTextArrayLines)
	XgrRegisterMessage (@"SetTextCursor",								@#SetTextCursor)
	XgrRegisterMessage (@"SetTextFilename",							@#SetTextFilename)
	XgrRegisterMessage (@"SetTextSelection",						@#SetTextSelection)
	XgrRegisterMessage (@"SetTextSpacing",							@#SetTextSpacing)
	XgrRegisterMessage (@"SetTextString",								@#SetTextString)
	XgrRegisterMessage (@"SetTextStrings",							@#SetTextStrings)
	XgrRegisterMessage (@"SetTexture",									@#SetTexture)
	XgrRegisterMessage (@"SetTimer",										@#SetTimer)
	XgrRegisterMessage (@"SetValue",										@#SetValue)
	XgrRegisterMessage (@"SetValues",										@#SetValues)
	XgrRegisterMessage (@"SetValueArray",								@#SetValueArray)
	XgrRegisterMessage (@"SetWindowFunction",						@#SetWindowFunction)
	XgrRegisterMessage (@"SetWindowIcon",								@#SetWindowIcon)
	XgrRegisterMessage (@"SetWindowTitle",							@#SetWindowTitle)
	XgrRegisterMessage (@"ShowTextCursor",							@#ShowTextCursor)
	XgrRegisterMessage (@"ShowWindow",									@#ShowWindow)
	XgrRegisterMessage (@"SomeLess",										@#SomeLess)
	XgrRegisterMessage (@"SomeMore",										@#SomeMore)
	XgrRegisterMessage (@"StartTimer",									@#StartTimer)
	XgrRegisterMessage (@"SystemMessage",								@#SystemMessage)
	XgrRegisterMessage (@"TextDelete",									@#TextDelete)
	XgrRegisterMessage (@"TextEvent",										@#TextEvent)
	XgrRegisterMessage (@"TextInsert",									@#TextInsert)
	XgrRegisterMessage (@"TextModified",								@#TextModified)
	XgrRegisterMessage (@"TextReplace",									@#TextReplace)
	XgrRegisterMessage (@"TimeOut",											@#TimeOut)
	XgrRegisterMessage (@"Update",											@#Update)
	XgrRegisterMessage (@"WindowClose",									@#WindowClose)
	XgrRegisterMessage (@"WindowCreate",								@#WindowCreate)
	XgrRegisterMessage (@"WindowDeselected",						@#WindowDeselected)
	XgrRegisterMessage (@"WindowDestroy",								@#WindowDestroy)
	XgrRegisterMessage (@"WindowDestroyed",							@#WindowDestroyed)
	XgrRegisterMessage (@"WindowDisplay",								@#WindowDisplay)
	XgrRegisterMessage (@"WindowDisplayed",							@#WindowDisplayed)
	XgrRegisterMessage (@"WindowGetDisplay",						@#WindowGetDisplay)
	XgrRegisterMessage (@"WindowGetFunction",						@#WindowGetFunction)
	XgrRegisterMessage (@"WindowGetIcon",								@#WindowGetIcon)
	XgrRegisterMessage (@"WindowGetKeyboardFocusGrid",	@#WindowGetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowGetSelectedWindow",			@#WindowGetSelectedWindow)
	XgrRegisterMessage (@"WindowGetSize",								@#WindowGetSize)
	XgrRegisterMessage (@"WindowGetTitle",							@#WindowGetTitle)
	XgrRegisterMessage (@"WindowHelp",									@#WindowHelp)
	XgrRegisterMessage (@"WindowHide",									@#WindowHide)
	XgrRegisterMessage (@"WindowHidden",								@#WindowHidden)
	XgrRegisterMessage (@"WindowKeyDown",								@#WindowKeyDown)
	XgrRegisterMessage (@"WindowKeyUp",									@#WindowKeyUp)
	XgrRegisterMessage (@"WindowMaximize",							@#WindowMaximize)
	XgrRegisterMessage (@"WindowMaximized",							@#WindowMaximized)
	XgrRegisterMessage (@"WindowMinimize",							@#WindowMinimize)
	XgrRegisterMessage (@"WindowMinimized",							@#WindowMinimized)
	XgrRegisterMessage (@"WindowMonitorContext",				@#WindowMonitorContext)
	XgrRegisterMessage (@"WindowMonitorHelp",						@#WindowMonitorHelp)
	XgrRegisterMessage (@"WindowMonitorKeyboard",				@#WindowMonitorKeyboard)
	XgrRegisterMessage (@"WindowMonitorMouse",					@#WindowMonitorMouse)
	XgrRegisterMessage (@"WindowMouseDown",							@#WindowMouseDown)
	XgrRegisterMessage (@"WindowMouseDrag",							@#WindowMouseDrag)
	XgrRegisterMessage (@"WindowMouseEnter",						@#WindowMouseEnter)
	XgrRegisterMessage (@"WindowMouseExit",							@#WindowMouseExit)
	XgrRegisterMessage (@"WindowMouseMove",							@#WindowMouseMove)
	XgrRegisterMessage (@"WindowMouseUp",								@#WindowMouseUp)
	XgrRegisterMessage (@"WindowMouseWheel",						@#WindowMouseWheel)
	XgrRegisterMessage (@"WindowRedraw",								@#WindowRedraw)
	XgrRegisterMessage (@"WindowRegister",							@#WindowRegister)
	XgrRegisterMessage (@"WindowResize",								@#WindowResize)
	XgrRegisterMessage (@"WindowResized",								@#WindowResized)
	XgrRegisterMessage (@"WindowResizeToGrid",					@#WindowResizeToGrid)
	XgrRegisterMessage (@"WindowSelect",								@#WindowSelect)
	XgrRegisterMessage (@"WindowSelected",							@#WindowSelected)
	XgrRegisterMessage (@"WindowSetFunction",						@#WindowSetFunction)
	XgrRegisterMessage (@"WindowSetIcon",								@#WindowSetIcon)
	XgrRegisterMessage (@"WindowSetKeyboardFocusGrid",	@#WindowSetKeyboardFocusGrid)
	XgrRegisterMessage (@"WindowSetTitle",							@#WindowSetTitle)
	XgrRegisterMessage (@"WindowShow",									@#WindowShow)
	XgrRegisterMessage (@"WindowSystemMessage",					@#WindowSystemMessage)
	XgrRegisterMessage (@"LastMessage",									@#LastMessage)
'
	XgrGetDisplaySize ("", @#displayWidth, @#displayHeight, @#windowBorderWidth, @#windowTitleHeight)
END FUNCTION
'
'
' ##################################
' #####  InvalidFileNumber ()  #####
' ##################################
'
'	Test for valid file number
'
'	In:				fileNumber		File Number
'	Out:			none--arg unchanged
'	Return:		$$TRUE				valid
'						$$FALSE				invalid  (sets ##ERROR)
'
'	Must be entry WHOMASK
'
FUNCTION  InvalidFileNumber (fileNumber)
	SHARED  FILE  fileInfo[]
'
	IFZ fileInfo[] THEN GOTO eeeBadFileNumber
	uFile = UBOUND(fileInfo[])
	IF (fileNumber > uFile) THEN GOTO eeeBadFileNumber
	IF (fileNumber < 1) THEN GOTO eeeBadFileNumber
	fileHandle = fileInfo[fileNumber].fileHandle
	IFZ fileHandle THEN GOTO eeeBadFileNumber
	IF ##WHOMASK THEN												' User can only Close her own files
		IF (fileNumber > 2) THEN
			IFZ fileInfo[fileNumber].whomask THEN GOTO eeeBadFileNumber
		END IF
	END IF
	RETURN ($$FALSE)
'
eeeBadFileNumber:
	##ERROR = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
	RETURN ($$TRUE)
END FUNCTION
'
'
' ############################
' #####  ValidFormat ()  #####
' ############################
'
FUNCTION  ValidFormat (format$, validPtr)
	STATIC	UBYTE  fmtSeq[]
'
	IFZ fmtSeq[] THEN GOSUB Initialize
	IFZ format$ THEN RETURN ($$FALSE)
	valid = $$FALSE
'
' format is invalid if not part of ascending value sequence
' (else) format is valid if the next format character can become a digit
'
	DO
		now = format${validPtr}
		nxt = format${validPtr+1}
		IF (fmtSeq[now] >= fmtSeq[nxt]) THEN valid = $$FALSE : EXIT DO
		IF ((nxt = '*') OR (nxt = '#') OR (nxt = ',')) THEN valid = $$TRUE : EXIT DO
		INC validPtr
	LOOP
	RETURN (valid)
'
' *****  Initialize  *****
'
SUB Initialize
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
	DIM fmtSeq[255]
	fmtSeq['+'] =  40
	fmtSeq['-'] =  40
	fmtSeq['('] =  40
	fmtSeq['*'] =  50
	fmtSeq['$'] =  60
	fmtSeq[','] =  80
	fmtSeq['.'] =  90
	fmtSeq['#'] = 100
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' #########################
' #####  ValidFmt ()  #####
' #########################
'
FUNCTION  ValidFmt (fmtString$, validPtr)
	STATIC UBYTE fmtSeq[]

	IFZ fmtSeq[] THEN GOSUB InitStatic
'
	DO
		now = fmtString${validPtr}
		nxt = fmtString${validPtr+1}
'
' format is invalid if not part of ascending value sequence
'
		IF (fmtSeq[now] >= fmtSeq[nxt]) THEN fmt = 0 : EXIT DO
'
' (else) format is valid if the next format character can become a digit
'
		IF ((nxt = '*') OR (nxt = '#') OR (nxt = ',')) THEN fmt = 1 : EXIT DO
		INC validPtr
	LOOP
	RETURN fmt
'
' *****************************
' *****  SUB  InitStatic  *****
' *****************************
'
SUB InitStatic
	whomask = ##WHOMASK
	##WHOMASK = $$FALSE
	DIM fmtSeq[255]
	fmtSeq['+'] =  40
	fmtSeq['-'] =  40
	fmtSeq['('] =  40
	fmtSeq['*'] =  50
	fmtSeq['$'] =  60
	fmtSeq[','] =  80
	fmtSeq['.'] =  90
	fmtSeq['#'] = 100
	##WHOMASK = whomask
END SUB
END FUNCTION
'
'
' #############################
' #####  XxxTerminate ()  #####
' #############################
'
FUNCTION  XxxTerminate ()
'
' see xlib.s in Windows version
'
END FUNCTION
'
'
' #################################
' #####  XxxGuessFilename ()  #####  prior to Aug 30, 1995
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
FUNCTION  XxxGuessFilename (old$, new$, guess$, attributes)
'
	guess$ = ""
	IFZ new$ THEN
		guess$ = old$
	ELSE
		newLength = LEN(new$)
		test$ = XstPathString$ (new$)
		SELECT CASE TRUE
			CASE (test${0} = $$PathSlash)	:	guess$ = test$		' leading \
			CASE (test${1} = ':')					: guess$ = test$		' leading d:
		END SELECT
	END IF
'
	IFZ guess$ THEN
		IFZ old$ THEN XstGetCurrentDirectory (@old$)
		XstGetFileAttributes (@old$, @attributes)
		SELECT CASE TRUE
			CASE (attributes AND $$FileDirectory)
						path$ = old$
			CASE (attributes = 0)
						XstGetCurrentDirectory (@path$)
			CASE ELSE
						XstGetPathComponents (@old$, @path$, @drive$, @dir$, @file$, @attributes)
		END SELECT
		upath = UBOUND(path$)
		IF (path${upath} != $$PathSlash) THEN path$ = path$ + $$PathSlash$
		guess$ = path$ + test$
	END IF
	XstGetFileAttributes (@guess$, @attributes)
	IFZ attributes THEN
		XstGetPathComponents (@guess$, @path$, @dr$, @di$, @fi$, @at)
		XstGetFileAttributes (@path$, @att)
		IF (att AND $$FileDirectory) THEN attributes = $$FileNormal
	END IF
END FUNCTION
'
'
' ###############################
' #####  XxxPathString$ ()  #####  prior to Aug 30, 1995
' ###############################
'
FUNCTION  XxxPathString$ (path$)
'
	o = '\\'
	n = $$PathSlash
	IF (n = '\\') THEN o = '/'
'
	IFZ path$ THEN RETURN
	upper = UBOUND (path$)
	p$ = path$
'
	FOR i = 0 TO upper
		IF (p${i} = o) THEN p${i} = n
	NEXT i
	RETURN (p$)
END FUNCTION
'
'* Stop XBasic with an error message
' Note: The runtime environment may not yet be initialized, so don't rely
' on it.
' @param errorMessage$	This message is displayed
FUNCTION XstAbend(errorMessage$)
	PRINT "Fatal Error: "; errorMessage$
	exit(0)
END FUNCTION

'* Show a message
' Note: The runtime environment may not yet be initialized, so don't rely
' on it.
' @param errorMessage$	This message is displayed
FUNCTION XstAlert(message$)
	' Sorry, no fancy popup available on linux
	PRINT message$
END FUNCTION

'* Retrieve the full path and filename of the executable
' @return	The full path and filename of the executable.
FUNCTION XstGetProgramFileName$()
	file$ = NULL$(256)
	ret = xb_getpfn(&file$, 256)
	file$ = LEFT$(file$, ret)
	RETURN (file$)
END FUNCTION

END PROGRAM
