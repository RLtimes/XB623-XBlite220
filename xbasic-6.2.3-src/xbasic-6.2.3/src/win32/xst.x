'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Windows XBasic standard function library
'
' subject to LGPL license - see COPYING_LIB
'
' maxreason@maxreason.com
'
' for Windows XBasic
'
'
PROGRAM	"xst"
VERSION	"0.0333"
'
IMPORT	"xma"
IMPORT	"xgr"
IMPORT	"xui"
IMPORT	"xlib"
IMPORT	"user32"
IMPORT	"kernel32"
'
EXPORT
'
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
' ***********************************
' *****  Win32 COMPOSITE TYPES  *****
' ***********************************
'
TYPE STARTUPINFO                ' CreateProcess() in XxxShell()
  XLONG        .cb
  XLONG        .lpReserved
  XLONG        .lpDesktop
  XLONG        .lpTitle
  XLONG        .dwX
  XLONG        .dwY
  XLONG        .dwXSize
  XLONG        .dwYSize
  XLONG        .dwXCountChars
  XLONG        .dwYCountChars
  XLONG        .dwFillAttribUte
  XLONG        .dwFlags
  USHORT       .wShowWindow
  USHORT       .cbReserved2
  XLONG        .lpReserved2
  XLONG        .hStdInput
  XLONG        .hStdOutput
  XLONG        .hStdError
END TYPE
'
TYPE PROCESS_INFORMATION        ' CreateProcess() in XxxShell()
  XLONG        .hProcess
  XLONG        .hThread
  XLONG        .dwProcessId
  XLONG        .dwThreadId
END TYPE
'
TYPE SECURITY_ATTRIBUTES
  XLONG        .length
  XLONG        .securityDescriptor
  XLONG        .inherit
END TYPE
EXPORT
'
'
' ****************************************
' *****  Standard Library Functions  *****
' ****************************************
'
' system functions
'
DECLARE FUNCTION  Xst                            ()
DECLARE FUNCTION  XstVersion$                    ()
DECLARE FUNCTION  XstCauseException              (exception)
DECLARE FUNCTION  XstDateAndTimeToFileTime       (year, month, day, weekDay, hour, minute, second, nanos, @filetime$$)
DECLARE FUNCTION  XstErrorNameToNumber           (error$, @error)
DECLARE FUNCTION  XstErrorNumberToName           (error, @error$)
DECLARE FUNCTION  XstExceptionNumberToName       (exception, @exception$)
DECLARE FUNCTION  XstExceptionToSystemException  (exception, @sysException)
DECLARE FUNCTION  XstFileTimeToDateAndTime       (fileTime$$, @year, @month, @day, @weekDay, @hour, @minute, @second, @nanos)
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
DECLARE FUNCTION  XstLog                         (message$)
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
DECLARE FUNCTION  XstStartTimer                  (timer, count, msec, callFunc)
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
' file functions
'
DECLARE FUNCTION  XstBinRead                     (ifile, bufferAddr, maxBytes)
DECLARE FUNCTION  XstBinWrite                    (ofile, bufferAddr, numBytes)
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
DECLARE FUNCTION  XstGetFiles                    (filter$, @files$[])
DECLARE FUNCTION  XstGetFilesAndAttributes       (filter$, attributeFilter, @files$[], FILEINFO @fileInfo[])
DECLARE FUNCTION  XstGetPathComponents           (file$, @path$, @drive$, @dir$, @filename$, @attributes)
DECLARE FUNCTION  XstGuessFilename               (old$, new$, @guess$, @attributes)
DECLARE FUNCTION  XstIsAbsolutePath              (file$)
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
DECLARE FUNCTION  XstWriteString                  (ofile, @string$)
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
DECLARE FUNCTION  XstDeleteLines                 (array$[], start, count)
DECLARE FUNCTION  XstFindArray                   (mode, text$[], find$, @line, @pos, @match)
DECLARE FUNCTION  XstTypeSize										 (type)
DECLARE FUNCTION  XstBytesToBound                (type, bytes)
DECLARE FUNCTION  XstGetTypedArray               (type, bytes, @ANY array[])
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
EXTERNAL FUNCTION  XstStringToNumber              (s$, startOff, afterOff, rtype, value$$)
EXTERNAL FUNCTION  XstFindMemoryMatch             (addrStart, addrAfter, addrMatch, minLength, maxLength)
DECLARE FUNCTION  XstLTRIM                       (@string$, array[])
DECLARE FUNCTION  XstRTRIM                       (@string$, array[])
DECLARE FUNCTION  XstTRIM                        (@string$, array[])
'
' sorting functions
'
DECLARE FUNCTION  XstCompareStrings              (addrString1, op, addrString2, flags)
DECLARE FUNCTION  XstQuickSort                   (ANY x[], n[], low, high, flags)
DECLARE FUNCTION  XxxFormat$                     (format$, argType, arg$$)
'
DECLARE FUNCTION  XstAbend                       (errorMessage$)
DECLARE FUNCTION  XstAlert                       (message$)
DECLARE FUNCTION  XstGetProgramFileName$         ()
'
END EXPORT
'
' functions the PDE calls
'
DECLARE  FUNCTION  XxxXstBlowback                ()
DECLARE  FUNCTION  XxxXstFreeLibrary             (libname$, handle)
DECLARE  FUNCTION  XxxXstLoadLibrary             (libname$)
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
INTERNAL FUNCTION  XstTimer                      (hwnd, message, timer, msec)
INTERNAL FUNCTION  XstAttributeMatch             (attr, filter)
'
INTERNAL FUNCTION getFirstSlash(str$, stop)
INTERNAL FUNCTION getLastSlash(str$, stop)
'
' functions formerly in xio.x
'
DECLARE FUNCTION  Xio             ()
DECLARE FUNCTION  XxxClose        (fileNumber)
DECLARE FUNCTION  XxxCloseAllUser ()
DECLARE FUNCTION  XxxEof          (fileNumber)
DECLARE FUNCTION  XxxGetVersion   ()
DECLARE FUNCTION  XxxInfile$      (fileNumber)
DECLARE FUNCTION  XxxInline$      (prompt$)
DECLARE FUNCTION  XxxLof          (fileNumber)
DECLARE FUNCTION  XxxOpen         (fileName$, openMode)
DECLARE FUNCTION  XxxPof          (fileNumber)
DECLARE FUNCTION  XxxQuit         (status)
DECLARE FUNCTION  XxxReadFile     (fileNumber, addr, bytes, bytesRead, overlapped)
DECLARE FUNCTION  XxxSeek         (fileNumber, position)
DECLARE FUNCTION  XxxShell        (command$)
DECLARE FUNCTION  XxxStdio        (stdin, stdout, stderr)
DECLARE FUNCTION  XxxWriteFile    (fileNumber, addr, bytes, bytesWritten, overlapped)
'
INTERNAL FUNCTION  InitGui            ()
INTERNAL FUNCTION  CreateConsole      ()
INTERNAL FUNCTION  InvalidFileNumber  (fileNumber)
INTERNAL FUNCTION  ValidFormat        (format$, offset)
INTERNAL FUNCTION  ValidFmt           (format$, offset)
'
' GraphicsDesigner functions
'
EXTERNAL FUNCTION  XxxDispatchEvents  (wait, processSystem)
EXTERNAL FUNCTION  XxxXgrQuit         ()
'
' xit functions
'
EXTERNAL FUNCTION  XxxSetBlowback     ()
'
' xlib functions
'
EXTERNAL FUNCTION  XxxTerminate       ()
EXTERNAL FUNCTION  XxxGetEbpEsp       (ebp, esp)
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
  $$Newline$            =  "\n"
'
' path slash characters (different for DOS/Windows vs UNIX)
'
  $$PathSlash$          = "\\"      ' Windows
  $$PathSlash           = '\\'      ' Windows
' This is the character that separates directories in environment-variables
' (e.g. PATH).
	$$PathSeparator				= ';'				' Windows
	$$PathSeparator$			= ";"				' Windows
' $$PathSlash$          = "/"       ' UNIX
' $$PathSlash           = '/'       ' UNIX
'	$$PathSeparator				= ':'				' Unix
'	$$PathSeparator$			= ":"				' Unix
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
'
' ********************************
' *****  File I/O Constants  *****  for OPEN()
' ********************************
'
  $$RD                  = 0x0000    ' read file
  $$WR                  = 0x0001    ' write file
  $$RW                  = 0x0002    ' read/write file
  $$WRNEW               = 0x0003    ' write new file
  $$RWNEW               = 0x0004    ' read/write new file
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
'
' ****************************************
' *****  Native Exception Constants  *****
' ****************************************
'
  $$ExceptionNone                  =  0
  $$ExceptionSegmentViolation      =  1
  $$ExceptionOutOfBounds           =  2
  $$ExceptionBreakpoint            =  3
  $$ExceptionBreakKey              =  4
  $$ExceptionAlignment             =  5
  $$ExceptionDenormal              =  6
  $$ExceptionDivideByZero          =  7
  $$ExceptionInvalidOperation      =  8
  $$ExceptionOverflow              =  9
  $$ExceptionStackCheck            = 10
  $$ExceptionUnderflow             = 11
  $$ExceptionInvalidInstruction    = 12
  $$ExceptionPrivilege             = 13
  $$ExceptionStackOverflow         = 14
  $$ExceptionReserved              = 15
  $$ExceptionTimer                 = 16
  $$ExceptionUnknown               = 17
  $$ExceptionUpper                 = 31
'
  $$ExceptionTerminate             =  0    ' native
  $$ExceptionContinue              = -1    ' native
'
'
' **********************************************  from \mstools\h\winerror.h
' *****  Operating System Error Constants  *****  XstGetSystemError() : XstSetSystemError()
' **********************************************  XstSystemErrorNumberToName (@systemError$)
'
  $$ERROR_SUCCESS                           =    0
  $$ERROR_INVALID_FUNCTION                  =    1
  $$ERROR_FILE_NOT_FOUND                    =    2
  $$ERROR_PATH_NOT_FOUND                    =    3
  $$ERROR_TOO_MANY_OPEN_FILES               =    4
  $$ERROR_ACCESS_DENIED                     =    5
  $$ERROR_INVALID_HANDLE                    =    6
  $$ERROR_ARENA_TRASHED                     =    7
  $$ERROR_NOT_ENOUGH_MEMORY                 =    8
  $$ERROR_INVALID_BLOCK                     =    9
  $$ERROR_BAD_ENVIRONMENT                   =   10
  $$ERROR_BAD_FORMAT                        =   11
  $$ERROR_INVALID_ACCESS                    =   12
  $$ERROR_INVALID_DATA                      =   13
  $$ERROR_OUTOFMEMORY                       =   14
  $$ERROR_INVALID_DRIVE                     =   15
  $$ERROR_CURRENT_DIRECTORY                 =   16
  $$ERROR_NOT_SAME_DEVICE                   =   17
  $$ERROR_NO_MORE_FILES                     =   18
  $$ERROR_WRITE_PROTECT                     =   19
  $$ERROR_BAD_UNIT                          =   20
  $$ERROR_NOT_READY                         =   21
  $$ERROR_BAD_COMMAND                       =   22
  $$ERROR_CRC                               =   23
  $$ERROR_BAD_LENGTH                        =   24
  $$ERROR_SEEK                              =   25
  $$ERROR_NOT_DOS_DISK                      =   26
  $$ERROR_SECTOR_NOT_FOUND                  =   27
  $$ERROR_OUT_OF_PAPER                      =   28
  $$ERROR_WRITE_FAULT                       =   29
  $$ERROR_READ_FAULT                        =   30
  $$ERROR_GEN_FAILURE                       =   31
  $$ERROR_SHARING_VIOLATION                 =   32
  $$ERROR_LOCK_VIOLATION                    =   33
  $$ERROR_WRONG_DISK                        =   34
  $$ERROR_SHARING_BUFFER_EXCEEDED           =   36
  $$ERROR_HANDLE_EOF                        =   38
  $$ERROR_HANDLE_DISK_FULL                  =   39
  $$ERROR_NOT_SUPPORTED                     =   50
  $$ERROR_REM_NOT_LIST                      =   51
  $$ERROR_DUP_NAME                          =   52
  $$ERROR_BAD_NETPATH                       =   53
  $$ERROR_NETWORK_BUSY                      =   54
  $$ERROR_DEV_NOT_EXIST                     =   55
  $$ERROR_TOO_MANY_CMDS                     =   56
  $$ERROR_ADAP_HDW_ERR                      =   57
  $$ERROR_BAD_NET_RESP                      =   58
  $$ERROR_UNEXP_NET_ERR                     =   59
  $$ERROR_BAD_REM_ADAP                      =   60
  $$ERROR_PRINTQ_FULL                       =   61
  $$ERROR_NO_SPOOL_SPACE                    =   62
  $$ERROR_PRINT_CANCELLED                   =   63
  $$ERROR_NETNAME_DELETED                   =   64
  $$ERROR_NETWORK_ACCESS_DENIED             =   65
  $$ERROR_BAD_DEV_TYPE                      =   66
  $$ERROR_BAD_NET_NAME                      =   67
  $$ERROR_TOO_MANY_NAMES                    =   68
  $$ERROR_TOO_MANY_SESS                     =   69
  $$ERROR_SHARING_PAUSED                    =   70
  $$ERROR_REQ_NOT_ACCEP                     =   71
  $$ERROR_REDIR_PAUSED                      =   72
  $$ERROR_FILE_EXISTS                       =   80
  $$ERROR_CANNOT_MAKE                       =   82
  $$ERROR_FAIL_I24                          =   83
  $$ERROR_OUT_OF_STRUCTURES                 =   84
  $$ERROR_ALREADY_ASSIGNED                  =   85
  $$ERROR_INVALID_PASSWORD                  =   86
  $$ERROR_INVALID_PARAMETER                 =   87
  $$ERROR_NET_WRITE_FAULT                   =   88
  $$ERROR_NO_PROC_SLOTS                     =   89
  $$ERROR_TOO_MANY_SEMAPHORES               =  100
  $$ERROR_EXCL_SEM_ALREADY_OWNED            =  101
  $$ERROR_SEM_IS_SET                        =  102
  $$ERROR_TOO_MANY_SEM_REQUESTS             =  103
  $$ERROR_INVALID_AT_INTERRUPT_TIME         =  104
  $$ERROR_SEM_OWNER_DIED                    =  105
  $$ERROR_SEM_USER_LIMIT                    =  106
  $$ERROR_DISK_CHANGE                       =  107
  $$ERROR_DRIVE_LOCKED                      =  108
  $$ERROR_BROKEN_PIPE                       =  109
  $$ERROR_OPEN_FAILED                       =  110
  $$ERROR_BUFFER_OVERFLOW                   =  111
  $$ERROR_DISK_FULL                         =  112
  $$ERROR_NO_MORE_SEARCH_HANDLES            =  113
  $$ERROR_INVALID_TARGET_HANDLE             =  114
  $$ERROR_INVALID_CATEGORY                  =  117
  $$ERROR_INVALID_VERIFY_SWITCH             =  118
  $$ERROR_BAD_DRIVER_LEVEL                  =  119
  $$ERROR_CALL_NOT_IMPLEMENTED              =  120
  $$ERROR_SEM_TIMEOUT                       =  121
  $$ERROR_INSUFFICIENT_BUFFER               =  122
  $$ERROR_INVALID_NAME                      =  123
  $$ERROR_INVALID_LEVEL                     =  124
  $$ERROR_NO_VOLUME_LABEL                   =  125
  $$ERROR_MOD_NOT_FOUND                     =  126
  $$ERROR_PROC_NOT_FOUND                    =  127
  $$ERROR_WAIT_NO_CHILDREN                  =  128
  $$ERROR_CHILD_NOT_COMPLETE                =  129
  $$ERROR_DIRECT_ACCESS_HANDLE              =  130
  $$ERROR_NEGATIVE_SEEK                     =  131
  $$ERROR_SEEK_ON_DEVICE                    =  132
  $$ERROR_IS_JOIN_TARGET                    =  133
  $$ERROR_IS_JOINED                         =  134
  $$ERROR_IS_SUBSTED                        =  135
  $$ERROR_NOT_JOINED                        =  136
  $$ERROR_NOT_SUBSTED                       =  137
  $$ERROR_JOIN_TO_JOIN                      =  138
  $$ERROR_SUBST_TO_SUBST                    =  139
  $$ERROR_JOIN_TO_SUBST                     =  140
  $$ERROR_SUBST_TO_JOIN                     =  141
  $$ERROR_BUSY_DRIVE                        =  142
  $$ERROR_SAME_DRIVE                        =  143
  $$ERROR_DIR_NOT_ROOT                      =  144
  $$ERROR_DIR_NOT_EMPTY                     =  145
  $$ERROR_IS_SUBST_PATH                     =  146
  $$ERROR_IS_JOIN_PATH                      =  147
  $$ERROR_PATH_BUSY                         =  148
  $$ERROR_IS_SUBST_TARGET                   =  149
  $$ERROR_SYSTEM_TRACE                      =  150
  $$ERROR_INVALID_EVENT_COUNT               =  151
  $$ERROR_TOO_MANY_MUXWAITERS               =  152
  $$ERROR_INVALID_LIST_FORMAT               =  153
  $$ERROR_LABEL_TOO_LONG                    =  154
  $$ERROR_TOO_MANY_TCBS                     =  155
  $$ERROR_SIGNAL_REFUSED                    =  156
  $$ERROR_DISCARDED                         =  157
  $$ERROR_NOT_LOCKED                        =  158
  $$ERROR_BAD_THREADID_ADDR                 =  159
  $$ERROR_BAD_ARGUMENTS                     =  160
  $$ERROR_BAD_PATHNAME                      =  161
  $$ERROR_SIGNAL_PENDING                    =  162
  $$ERROR_MAX_THRDS_REACHED                 =  164
  $$ERROR_LOCK_FAILED                       =  167
  $$ERROR_BUSY                              =  170
  $$ERROR_CANCEL_VIOLATION                  =  173
  $$ERROR_ATOMIC_LOCKS_NOT_SUPPORTED        =  174
  $$ERROR_INVALID_SEGMENT_NUMBER            =  180
  $$ERROR_INVALID_ORDINAL                   =  182
  $$ERROR_ALREADY_EXISTS                    =  183
  $$ERROR_INVALID_FLAG_NUMBER               =  186
  $$ERROR_SEM_NOT_FOUND                     =  187
  $$ERROR_INVALID_STARTING_CODESEG          =  188
  $$ERROR_INVALID_STACKSEG                  =  189
  $$ERROR_INVALID_MODULETYPE                =  190
  $$ERROR_INVALID_EXE_SIGNATURE             =  191
  $$ERROR_EXE_MARKED_INVALID                =  192
  $$ERROR_BAD_EXE_FORMAT                    =  193
  $$ERROR_ITERATED_DATA_EXCEEDS_64k         =  194
  $$ERROR_INVALID_MINALLOCSIZE              =  195
  $$ERROR_DYNLINK_FROM_INVALID_RING         =  196
  $$ERROR_IOPL_NOT_ENABLED                  =  197
  $$ERROR_INVALID_SEGDPL                    =  198
  $$ERROR_AUTODATASEG_EXCEEDS_64k           =  199
  $$ERROR_RING2SEG_MUST_BE_MOVABLE          =  200
  $$ERROR_RELOC_CHAIN_XEEDS_SEGLIM          =  201
  $$ERROR_INFLOOP_IN_RELOC_CHAIN            =  202
  $$ERROR_ENVVAR_NOT_FOUND                  =  203
  $$ERROR_NO_SIGNAL_SENT                    =  205
  $$ERROR_FILENAME_EXCED_RANGE              =  206
  $$ERROR_RING2_STACK_IN_USE                =  207
  $$ERROR_META_EXPANSION_TOO_LONG           =  208
  $$ERROR_INVALID_SIGNAL_NUMBER             =  209
  $$ERROR_THREAD_1_INACTIVE                 =  210
  $$ERROR_LOCKED                            =  212
  $$ERROR_TOO_MANY_MODULES                  =  214
  $$ERROR_NESTING_NOT_ALLOWED               =  215
  $$ERROR_BAD_PIPE                          =  230
  $$ERROR_PIPE_BUSY                         =  231
  $$ERROR_NO_DATA                           =  232
  $$ERROR_PIPE_NOT_CONNECTED                =  233
  $$ERROR_MORE_DATA                         =  234
  $$ERROR_VC_DISCONNECTED                   =  240
  $$ERROR_INVALID_EA_NAME                   =  254
  $$ERROR_EA_LIST_INCONSISTENT              =  255
  $$ERROR_NO_MORE_ITEMS                     =  259
  $$ERROR_CANNOT_COPY                       =  266
  $$ERROR_DIRECTORY                         =  267
  $$ERROR_EAS_DIDNT_FIT                     =  275
  $$ERROR_EA_FILE_CORRUPT                   =  276
  $$ERROR_EA_TABLE_FULL                     =  277
  $$ERROR_INVALID_EA_HANDLE                 =  278
  $$ERROR_EAS_NOT_SUPPORTED                 =  282
  $$ERROR_NOT_OWNER                         =  288
  $$ERROR_TOO_MANY_POSTS                    =  298
  $$ERROR_MR_MID_NOT_FOUND                  =  317
  $$ERROR_INVALID_ADDRESS                   =  487
  $$ERROR_ARITHMETIC_OVERFLOW               =  534
  $$ERROR_PIPE_CONNECTED                    =  535
  $$ERROR_PIPE_LISTENING                    =  536
  $$ERROR_EA_ACCESS_DENIED                  =  994
  $$ERROR_OPERATION_ABORTED                 =  995
  $$ERROR_IO_INCOMPLETE                     =  996
  $$ERROR_IO_PENDING                        =  997
  $$ERROR_NOACCESS                          =  998
  $$ERROR_SWAPERROR                         =  999
  $$ERROR_STACK_OVERFLOW                    = 1001
  $$ERROR_INVALID_MESSAGE                   = 1002
  $$ERROR_CAN_NOT_COMPLETE                  = 1003
  $$ERROR_INVALID_FLAGS                     = 1004
  $$ERROR_UNRECOGNIZED_VOLUME               = 1005
  $$ERROR_FILE_INVALID                      = 1006
  $$ERROR_FULLSCREEN_MODE                   = 1007
  $$ERROR_NO_TOKEN                          = 1008
  $$ERROR_BADDB                             = 1009
  $$ERROR_BADKEY                            = 1010
  $$ERROR_CANTOPEN                          = 1011
  $$ERROR_CANTREAD                          = 1012
  $$ERROR_CANTWRITE                         = 1013
  $$ERROR_REGISTRY_RECOVERED                = 1014
  $$ERROR_REGISTRY_CORRUPT                  = 1015
  $$ERROR_REGISTRY_IO_FAILED                = 1016
  $$ERROR_NOT_REGISTRY_FILE                 = 1017
  $$ERROR_KEY_DELETED                       = 1018
  $$ERROR_NO_LOG_SPACE                      = 1019
  $$ERROR_KEY_HAS_CHILDREN                  = 1020
  $$ERROR_CHILD_MUST_BE_VOLATILE            = 1021
  $$ERROR_NOTIFY_ENUM_DIR                   = 1022
  $$ERROR_DEPENDENT_SERVICES_RUNNING        = 1051
  $$ERROR_INVALID_SERVICE_CONTROL           = 1052
  $$ERROR_SERVICE_REQUEST_TIMEOUT           = 1053
  $$ERROR_SERVICE_NO_THREAD                 = 1054
  $$ERROR_SERVICE_DATABASE_LOCKED           = 1055
  $$ERROR_SERVICE_ALREADY_RUNNING           = 1056
  $$ERROR_INVALID_SERVICE_ACCOUNT           = 1057
  $$ERROR_SERVICE_DISABLED                  = 1058
  $$ERROR_CIRCULAR_DEPENDENCY               = 1059
  $$ERROR_SERVICE_DOES_NOT_EXIST            = 1060
  $$ERROR_SERVICE_CANNOT_ACCEPT_CTRL        = 1061
  $$ERROR_SERVICE_NOT_ACTIVE                = 1062
  $$ERROR_FAILED_SERVICE_CONTROLLER_CONNECT = 1063
  $$ERROR_EXCEPTION_IN_SERVICE              = 1064
  $$ERROR_DATABASE_DOES_NOT_EXIST           = 1065
  $$ERROR_SERVICE_SPECIFIC_ERROR            = 1066
  $$ERROR_PROCESS_ABORTED                   = 1067
  $$ERROR_SERVICE_DEPENDENCY_FAIL           = 1068
  $$ERROR_SERVICE_LOGON_FAILED              = 1069
  $$ERROR_SERVICE_START_HANG                = 1070
  $$ERROR_INVALID_SERVICE_LOCK              = 1071
  $$ERROR_SERVICE_MARKED_FOR_DELETE         = 1072
  $$ERROR_SERVICE_EXISTS                    = 1073
  $$ERROR_ALREADY_RUNNING_LKG               = 1074
  $$ERROR_SERVICE_DEPENDENCY_DELETED        = 1075
  $$ERROR_BOOT_ALREADY_ACCEPTED             = 1076
  $$ERROR_SERVICE_NEVER_STARTED             = 1077
  $$ERROR_DUPLICATE_SERVICE_NAME            = 1078
  $$ERROR_END_OF_MEDIA                      = 1100
  $$ERROR_FILEMARK_DETECTED                 = 1101
  $$ERROR_BEGINNING_OF_MEDIA                = 1102
  $$ERROR_SETMARK_DETECTED                  = 1103
  $$ERROR_NO_DATA_DETECTED                  = 1104
  $$ERROR_PARTITION_FAILURE                 = 1105
  $$ERROR_INVALID_BLOCK_LENGTH              = 1106
  $$ERROR_DEVICE_NOT_PARTITIONED            = 1107
  $$ERROR_UNABLE_TO_LOCK_MEDIA              = 1108
  $$ERROR_UNABLE_TO_UNLOAD_MEDIA            = 1109
  $$ERROR_MEDIA_CHANGED                     = 1110
  $$ERROR_BUS_RESET                         = 1111
  $$ERROR_NO_MEDIA_IN_DRIVE                 = 1112
  $$ERROR_NO_UNICODE_TRANSLATION            = 1113
  $$ERROR_DLL_INIT_FAILED                   = 1114
  $$ERROR_SHUTDOWN_IN_PROGRESS              = 1115
  $$ERROR_NO_SHUTDOWN_IN_PROGRESS           = 1116
  $$ERROR_IO_DEVICE                         = 1117
  $$ERROR_SERIAL_NO_DEVICE                  = 1118
  $$ERROR_IRQ_BUSY                          = 1119
  $$ERROR_MORE_WRITES                       = 1120
  $$ERROR_COUNTER_TIMEOUT                   = 1121
  $$ERROR_FLOPPY_ID_MARK_NOT_FOUND          = 1122
  $$ERROR_FLOPPY_WRONG_CYLINDER             = 1123
  $$ERROR_FLOPPY_UNKNOWN_ERROR              = 1124
  $$ERROR_FLOPPY_BAD_REGISTERS              = 1125
  $$ERROR_DISK_RECALIBRATE_FAILED           = 1126
  $$ERROR_DISK_OPERATION_FAILED             = 1127
  $$ERROR_DISK_RESET_FAILED                 = 1128
  $$ERROR_EOM_OVERFLOW                      = 1129
  $$ERROR_NOT_ENOUGH_SERVER_MEMORY          = 1130
  $$ERROR_POSSIBLE_DEADLOCK                 = 1131
  $$ERROR_MAPPED_ALIGNMENT                  = 1132
  $$ERROR_BAD_USERNAME                      = 2202
  $$ERROR_NOT_CONNECTED                     = 2250
  $$ERROR_OPEN_FILES                        = 2401
  $$ERROR_DEVICE_IN_USE                     = 2404
  $$ERROR_BAD_DEVICE                        = 1200
  $$ERROR_CONNECTION_UNAVAIL                = 1201
  $$ERROR_DEVICE_ALREADY_REMEMBERED         = 1202
  $$ERROR_NO_NET_OR_BAD_PATH                = 1203
  $$ERROR_BAD_PROVIDER                      = 1204
  $$ERROR_CANNOT_OPEN_PROFILE               = 1205
  $$ERROR_BAD_PROFILE                       = 1206
  $$ERROR_NOT_CONTAINER                     = 1207
  $$ERROR_EXTENDED_ERROR                    = 1208
  $$ERROR_INVALID_GROUPNAME                 = 1209
  $$ERROR_INVALID_COMPUTERNAME              = 1210
  $$ERROR_INVALID_EVENTNAME                 = 1211
  $$ERROR_INVALID_DOMAINNAME                = 1212
  $$ERROR_INVALID_SERVICENAME               = 1213
  $$ERROR_INVALID_NETNAME                   = 1214
  $$ERROR_INVALID_SHARENAME                 = 1215
  $$ERROR_INVALID_PASSWORDNAME              = 1216
  $$ERROR_INVALID_MESSAGENAME               = 1217
  $$ERROR_INVALID_MESSAGEDEST               = 1218
  $$ERROR_SESSION_CREDENTIAL_CONFLICT       = 1219
  $$ERROR_REMOTE_SESSION_LIMIT_EXCEEDED     = 1220
  $$ERROR_DUP_DOMAINNAME                    = 1221
  $$ERROR_NO_NETWORK                        = 1222
  $$ERROR_NOT_ALL_ASSIGNED                  = 1300
  $$ERROR_SOME_NOT_MAPPED                   = 1301
  $$ERROR_NO_QUOTAS_FOR_ACCOUNT             = 1302
  $$ERROR_LOCAL_USER_SESSION_KEY            = 1303
  $$ERROR_NULL_LM_PASSWORD                  = 1304
  $$ERROR_UNKNOWN_REVISION                  = 1305
  $$ERROR_REVISION_MISMATCH                 = 1306
  $$ERROR_INVALID_OWNER                     = 1307
  $$ERROR_INVALID_PRIMARY_GROUP             = 1308
  $$ERROR_NO_IMPERSONATION_TOKEN            = 1309
  $$ERROR_CANT_DISABLE_MANDATORY            = 1310
  $$ERROR_NO_LOGON_SERVERS                  = 1311
  $$ERROR_NO_SUCH_LOGON_SESSION             = 1312
  $$ERROR_NO_SUCH_PRIVILEGE                 = 1313
  $$ERROR_PRIVILEGE_NOT_HELD                = 1314
  $$ERROR_INVALID_ACCOUNT_NAME              = 1315
  $$ERROR_USER_EXISTS                       = 1316
  $$ERROR_NO_SUCH_USER                      = 1317
  $$ERROR_GROUP_EXISTS                      = 1318
  $$ERROR_NO_SUCH_GROUP                     = 1319
  $$ERROR_MEMBER_IN_GROUP                   = 1320
  $$ERROR_MEMBER_NOT_IN_GROUP               = 1321
  $$ERROR_LAST_ADMIN                        = 1322
  $$ERROR_WRONG_PASSWORD                    = 1323
  $$ERROR_ILL_FORMED_PASSWORD               = 1324
  $$ERROR_PASSWORD_RESTRICTION              = 1325
  $$ERROR_LOGON_FAILURE                     = 1326
  $$ERROR_ACCOUNT_RESTRICTION               = 1327
  $$ERROR_INVALID_LOGON_HOURS               = 1328
  $$ERROR_INVALID_WORKSTATION               = 1329
  $$ERROR_PASSWORD_EXPIRED                  = 1330
  $$ERROR_ACCOUNT_DISABLED                  = 1331
  $$ERROR_NONE_MAPPED                       = 1332
  $$ERROR_TOO_MANY_LUIDS_REQUESTED          = 1333
  $$ERROR_LUIDS_EXHAUSTED                   = 1334
  $$ERROR_INVALID_SUB_AUTHORITY             = 1335
  $$ERROR_INVALID_ACL                       = 1336
  $$ERROR_INVALID_SID                       = 1337
  $$ERROR_INVALID_SECURITY_DESCR            = 1338
  $$ERROR_BAD_INHERITANCE_ACL               = 1340
  $$ERROR_SERVER_DISABLED                   = 1341
  $$ERROR_SERVER_NOT_DISABLED               = 1342
  $$ERROR_INVALID_ID_AUTHORITY              = 1343
  $$ERROR_ALLOTTED_SPACE_EXCEEDED           = 1344
  $$ERROR_INVALID_GROUP_ATTRIBUTES          = 1345
  $$ERROR_BAD_IMPERSONATION_LEVEL           = 1346
  $$ERROR_CANT_OPEN_ANONYMOUS               = 1347
  $$ERROR_BAD_VALIDATION_CLASS              = 1348
  $$ERROR_BAD_TOKEN_TYPE                    = 1349
  $$ERROR_NO_SECURITY_ON_OBJECT             = 1350
  $$ERROR_CANT_ACCESS_DOMAIN_INFO           = 1351
  $$ERROR_INVALID_SERVER_STATE              = 1352
  $$ERROR_INVALID_DOMAIN_STATE              = 1353
  $$ERROR_INVALID_DOMAIN_ROLE               = 1354
  $$ERROR_NO_SUCH_DOMAIN                    = 1355
  $$ERROR_DOMAIN_EXISTS                     = 1356
  $$ERROR_DOMAIN_LIMIT_EXCEEDED             = 1357
  $$ERROR_INTERNAL_DB_CORRUPTION            = 1358
  $$ERROR_INTERNAL_ERROR                    = 1359
  $$ERROR_GENERIC_NOT_MAPPED                = 1360
  $$ERROR_BAD_DESCRIPTOR_FORMAT             = 1361
  $$ERROR_NOT_LOGON_PROCESS                 = 1362
  $$ERROR_LOGON_SESSION_EXISTS              = 1363
  $$ERROR_NO_SUCH_PACKAGE                   = 1364
  $$ERROR_BAD_LOGON_SESSION_STATE           = 1365
  $$ERROR_LOGON_SESSION_COLLISION           = 1366
  $$ERROR_INVALID_LOGON_TYPE                = 1367
  $$ERROR_CANNOT_IMPERSONATE                = 1368
  $$ERROR_RXACT_INVALID_STATE               = 1369
  $$ERROR_RXACT_COMMIT_FAILURE              = 1370
  $$ERROR_SPECIAL_ACCOUNT                   = 1371
  $$ERROR_SPECIAL_GROUP                     = 1372
  $$ERROR_SPECIAL_USER                      = 1373
  $$ERROR_MEMBERS_PRIMARY_GROUP             = 1374
  $$ERROR_TOKEN_ALREADY_IN_USE              = 1375
  $$ERROR_NO_SUCH_ALIAS                     = 1376
  $$ERROR_MEMBER_NOT_IN_ALIAS               = 1377
  $$ERROR_MEMBER_IN_ALIAS                   = 1378
  $$ERROR_ALIAS_EXISTS                      = 1379
  $$ERROR_LOGON_NOT_GRANTED                 = 1380
  $$ERROR_TOO_MANY_SECRETS                  = 1381
  $$ERROR_SECRET_TOO_LONG                   = 1382
  $$ERROR_INTERNAL_DB_ERROR                 = 1383
  $$ERROR_TOO_MANY_CONTEXT_IDS              = 1384
  $$ERROR_LOGON_TYPE_NOT_GRANTED            = 1385
  $$ERROR_NT_CROSS_ENCRYPTION_REQUIRED      = 1386
  $$ERROR_NO_SUCH_MEMBER                    = 1387
  $$ERROR_INVALID_MEMBER                    = 1388
  $$ERROR_TOO_MANY_SIDS                     = 1389
  $$ERROR_LM_CROSS_ENCRYPTION_REQUIRED      = 1390
  $$ERROR_NO_INHERITANCE                    = 1391
  $$ERROR_FILE_CORRUPT                      = 1392
  $$ERROR_DISK_CORRUPT                      = 1393
  $$ERROR_NO_USER_SESSION_KEY               = 1394
  $$ERROR_INVALID_WINDOW_HANDLE             = 1400
  $$ERROR_INVALID_MENU_HANDLE               = 1401
  $$ERROR_INVALID_CURSOR_HANDLE             = 1402
  $$ERROR_INVALID_ACCEL_HANDLE              = 1403
  $$ERROR_INVALID_HOOK_HANDLE               = 1404
  $$ERROR_INVALID_DWP_HANDLE                = 1405
  $$ERROR_TLW_WITH_WSCHILD                  = 1406
  $$ERROR_CANNOT_FIND_WND_CLASS             = 1407
  $$ERROR_WINDOW_OF_OTHER_THREAD            = 1408
  $$ERROR_HOTKEY_ALREADY_REGISTERED         = 1409
  $$ERROR_CLASS_ALREADY_EXISTS              = 1410
  $$ERROR_CLASS_DOES_NOT_EXIST              = 1411
  $$ERROR_CLASS_HAS_WINDOWS                 = 1412
  $$ERROR_INVALID_INDEX                     = 1413
  $$ERROR_INVALID_ICON_HANDLE               = 1414
  $$ERROR_PRIVATE_DIALOG_INDEX              = 1415
  $$ERROR_LISTBOX_ID_NOT_FOUND              = 1416
  $$ERROR_NO_WILDCARD_CHARACTERS            = 1417
  $$ERROR_CLIPBOARD_NOT_OPEN                = 1418
  $$ERROR_HOTKEY_NOT_REGISTERED             = 1419
  $$ERROR_WINDOW_NOT_DIALOG                 = 1420
  $$ERROR_CONTROL_ID_NOT_FOUND              = 1421
  $$ERROR_INVALID_COMBOBOX_MESSAGE          = 1422
  $$ERROR_WINDOW_NOT_COMBOBOX               = 1423
  $$ERROR_INVALID_EDIT_HEIGHT               = 1424
  $$ERROR_DC_NOT_FOUND                      = 1425
  $$ERROR_INVALID_HOOK_FILTER               = 1426
  $$ERROR_INVALID_FILTER_PROC               = 1427
  $$ERROR_HOOK_NEEDS_HMOD                   = 1428
  $$ERROR_GLOBAL_ONLY_HOOK                  = 1429
  $$ERROR_JOURNAL_HOOK_SET                  = 1430
  $$ERROR_HOOK_NOT_INSTALLED                = 1431
  $$ERROR_INVALID_LB_MESSAGE                = 1432
  $$ERROR_SETCOUNT_ON_BAD_LB                = 1433
  $$ERROR_LB_WITHOUT_TABSTOPS               = 1434
  $$ERROR_DESTROY_OBJECT_OF_OTHER_THREAD    = 1435
  $$ERROR_CHILD_WINDOW_MENU                 = 1436
  $$ERROR_NO_SYSTEM_MENU                    = 1437
  $$ERROR_INVALID_MSGBOX_STYLE              = 1438
  $$ERROR_INVALID_SPI_VALUE                 = 1439
  $$ERROR_SCREEN_ALREADY_LOCKED             = 1440
  $$ERROR_HWNDS_HAVE_DIFF_PARENT            = 1441
  $$ERROR_NOT_CHILD_WINDOW                  = 1442
  $$ERROR_INVALID_GW_COMMAND                = 1443
  $$ERROR_INVALID_THREAD_ID                 = 1444
  $$ERROR_NON_MDICHILD_WINDOW               = 1445
  $$ERROR_POPUP_ALREADY_ACTIVE              = 1446
  $$ERROR_NO_SCROLLBARS                     = 1447
  $$ERROR_INVALID_SCROLLBAR_RANGE           = 1448
  $$ERROR_INVALID_SHOWWIN_COMMAND           = 1449
  $$ERROR_EVENTLOG_FILE_CORRUPT             = 1500
  $$ERROR_EVENTLOG_CANT_START               = 1501
  $$ERROR_LOG_FILE_FULL                     = 1502
  $$ERROR_EVENTLOG_FILE_CHANGED             = 1503
  $$ERROR_INVALID_USER_BUFFER               = 1784
  $$ERROR_UNRECOGNIZED_MEDIA                = 1785
  $$ERROR_NO_TRUST_LSA_SECRET               = 1786
  $$ERROR_NO_TRUST_SAM_ACCOUNT              = 1787
  $$ERROR_TRUSTED_DOMAIN_FAILURE            = 1788
  $$ERROR_TRUSTED_RELATIONSHIP_FAILURE      = 1789
  $$ERROR_TRUST_FAILURE                     = 1790
  $$ERROR_NETLOGON_NOT_STARTED              = 1792
  $$ERROR_ACCOUNT_EXPIRED                   = 1793
  $$ERROR_REDIRECTOR_HAS_OPEN_HANDLES       = 1794
  $$ERROR_PRINTER_DRIVER_ALREADY_INSTALLED  = 1795
  $$ERROR_UNKNOWN_PORT                      = 1796
  $$ERROR_UNKNOWN_PRINTER_DRIVER            = 1797
  $$ERROR_UNKNOWN_PRINTPROCESSOR            = 1798
  $$ERROR_INVALID_SEPARATOR_FILE            = 1799
  $$ERROR_INVALID_PRIORITY                  = 1800
  $$ERROR_INVALID_PRINTER_NAME              = 1801
  $$ERROR_PRINTER_ALREADY_EXISTS            = 1802
  $$ERROR_INVALID_PRINTER_COMMAND           = 1803
  $$ERROR_INVALID_DATATYPE                  = 1804
  $$ERROR_INVALID_ENVIRONMENT               = 1805
  $$ERROR_NOLOGON_INTERDOMAIN_TRUST_ACCOUNT = 1807
  $$ERROR_NOLOGON_WORKSTATION_TRUST_ACCOUNT = 1808
  $$ERROR_NOLOGON_SERVER_TRUST_ACCOUNT      = 1809
  $$ERROR_DOMAIN_TRUST_INCONSISTENT         = 1810
  $$ERROR_SERVER_HAS_OPEN_HANDLES           = 1811
  $$ERROR_RESOURCE_DATA_NOT_FOUND           = 1812
  $$ERROR_RESOURCE_TYPE_NOT_FOUND           = 1813
  $$ERROR_RESOURCE_NAME_NOT_FOUND           = 1814
  $$ERROR_RESOURCE_LANG_NOT_FOUND           = 1815
  $$ERROR_NOT_ENOUGH_QUOTA                  = 1816
  $$ERROR_INVALID_TIME                      = 1901
  $$ERROR_INVALID_FORM_NAME                 = 1902
  $$ERROR_INVALID_FORM_SIZE                 = 1903
  $$ERROR_ALREADY_WAITING                   = 1904
  $$ERROR_PRINTER_DELETED                   = 1905
  $$ERROR_INVALID_PRINTER_STATE             = 1906
  $$ERROR_NO_BROWSER_SERVERS_FOUND          = 6118
  $$ERROR_LAST_OS_ERROR                     = 8191
'
'
' ***************************************
' *****  Win32 Exception Constants  *****
' ***************************************
'
  $$EXCEPTION_ACCESS_VIOLATION          = 0xC0000005
  $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED     = 0xC000008C
  $$EXCEPTION_BREAKPOINT                = 0x80000003
  $$EXCEPTION_CONTROL_C_EXIT            = 0xC000013A
  $$EXCEPTION_DATATYPE_MISALIGNMENT     = 0x80000002
  $$EXCEPTION_FLOAT_DENORMAL_OPERAND    = 0xC000008D
  $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO      = 0xC000008E
  $$EXCEPTION_FLOAT_INVALID_OPERATION   = 0xC0000090
  $$EXCEPTION_FLOAT_OVERFLOW            = 0xC0000091
  $$EXCEPTION_FLOAT_STACK_CHECK         = 0xC0000092
  $$EXCEPTION_FLOAT_UNDERFLOW           = 0xC0000093
  $$EXCEPTION_ILLEGAL_INSTRUCTION       = 0xC000001D
  $$EXCEPTION_INT_DIVIDE_BY_ZERO        = 0xC0000094
  $$EXCEPTION_INT_OVERFLOW              = 0xC0000095
  $$EXCEPTION_INVALID_DISPOSITION       = 0xC0000026
  $$EXCEPTION_NONCONTINUABLE_EXCEPTION  = 0xC0000025
  $$EXCEPTION_PRIV_INSTRUCTION          = 0xC0000096
  $$EXCEPTION_STACK_OVERFLOW            = 0xC00000FD
'
  $$EXCEPTION_CONTINUE_SEARCH           =  0
  $$EXCEPTION_EXECUTE_HANDLER           =  1
  $$EXCEPTION_CONTINUE_EXECUTION        = -1
END EXPORT
'
'
' *******************************************
' *****  Miscellaneous Win32 Constants  *****
' *******************************************
'
  $$NTIN                           = -10          ' to get STDIN
  $$NTOUT                          = -11          ' to get STDOUT
  $$NTERR                          = -12          ' to get STDERR
  $$GENERIC_READ                   = 0x80000000   ' most of these
  $$GENERIC_WRITE                  = 0x40000000   ' are for Win32
  $$CREATE_NEW                     = 0x00000001   ' CreateFile()
  $$CREATE_ALWAYS                  = 0x00000002
  $$OPEN_EXISTING                  = 0x00000003
  $$OPEN_ALWAYS                    = 0x00000004
  $$TRUNCATE_EXISTING              = 0x00000005
  $$FILE_ATTRIBUTE_READONLY        = 0x00000001
  $$FILE_ATTRIBUTE_HIDDEN          = 0x00000002
  $$FILE_ATTRIBUTE_SYSTEM          = 0x00000004
  $$FILE_ATTRIBUTE_DIRECTORY       = 0x00000010
  $$FILE_ATTRIBUTE_ARCHIVE         = 0x00000020
  $$FILE_ATTRIBUTE_NORMAL          = 0x00000080
  $$FILE_ATTRIBUTE_TEMPORARY       = 0x00000100
  $$FILE_ATTRIBUTE_ATOMIC_WRITE    = 0x00000200
  $$FILE_ATTRIBUTE_XACTION_WRITE   = 0x00000400
  $$FILE_FLAG_WRITE_THROUGH        = 0x80000000
  $$FILE_FLAG_OVERLAPPED           = 0x40000000
  $$FILE_FLAG_NO_BUFFERING         = 0x20000000
  $$FILE_FLAG_RANDOM_ACCESS        = 0x10000000
  $$FILE_FLAG_SEQUENTIAL_SCAN      = 0x08000000
  $$FILE_FLAG_DELETE_ON_CLOSE      = 0x04000000
  $$FILE_FLAG_BACKUP_SEMANTICS     = 0x02000000
  $$FILE_SHARE_NONE                = 0x00000000
  $$FILE_SHARE_READ                = 0x00000001
  $$FILE_SHARE_WRITE               = 0x00000002
  $$SECURITY_ANONYMOUS             = 0x00000000
  $$SECURITY_IDENTIFICATION        = 0x00010000
  $$SECURITY_IMPERSONATION         = 0x00020000
  $$SECURITY_DELEGATION            = 0x00030000
  $$SECURITY_CONTEXT_TRACKING      = 0x00040000
  $$SECURITY_EFFECTIVE             = 0x00080000
  $$FILE_BEGIN                     = 0x00000000  ' for SetFilePointer
  $$FILE_CURRENT                   = 0x00000001  ' for SetFilePointer
  $$FILE_END                       = 0x00000002  ' for SetFilePointer
'
'
' ####################
' #####  Xst ()  #####
' ####################
'
FUNCTION  Xst ()
	STATIC  entry
'
	IF entry THEN RETURN
	entry = $$TRUE
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Windows XBasic standard function library"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
	InitProgram ()		' !!! must call InitProgram() before Xio() !!!
'
' establish working directory as /usr/xb or $HOME/xb - or /xb if /xb is the current directory
'
'	home$ = ""
'	XstGetCurrentDirectory (@dir$)
'	IFZ home$ THEN XstGetEnvironmentVariable (@"HOME", @home$)
'	IFZ home$ THEN XstGetEnvironmentVariable (@"home", @home$)
'	IFZ home$ THEN XstGetEnvironmentVariable (@"Home", @home$)
'	IF (dir$ = $$PathSlash$) THEN dir$ = home$
'	dirxb$ = dir$ + $$PathSlash$ + "xb"
'	dirxbxxx$ = dirxb$ + $$PathSlash$ + "xxx"
'	dirxbxxxcopx$ = dirxbxxx$ + $$PathSlash$ + "copx.xxx"
'	homexb$ = home$ + $$PathSlash$ + "xb"
'	homexbxxx$ = homexb$ + $$PathSlash$ + "xxx"
'	homexbxxxcopx$ = homexbxxx$ + $$PathSlash$ + "copx.xxx"
'
'	XstGetFileAttributes (@"/xb", @xb0)
'	XstGetFileAttributes (@"/xb/xxx", @xb1)
'	XstGetFileAttributes (@"/xb/xxx/copx.xxx", @xb2)
'	XstGetFileAttributes (@"/usr/xb", @usr0)
'	XstGetFileAttributes (@"/usr/xb/xxx", @usr1)
'	XstGetFileAttributes (@"/usr/xb/xxx/copx.xxx", @usr2)
'	XstGetFileAttributes (@dirxb$, @dir0)
'	XstGetFileAttributes (@dirxbxxx$, @dir1)
'	XstGetFileAttributes (@dirxbxxxcopx$, @dir2)
'	XstGetFileAttributes (@homexb$, @home0)
'	XstGetFileAttributes (@homexbxxx$, @home1)
'	XstGetFileAttributes (@homexbxxxcopx$, @home2)
'
'	IFZ dir$ THEN dir$ = $$PathSlash$
'
'	xbdir$ = dir$
'	xbnew$ = homexb$
'	xb = xb0 && xb1 && xb2
'	usr = usr0 && usr1 && usr2
'	dir = dir0 && dir1 && dir2
'	home = home0 && home1 && home2
'
'	XstLog ("     PASS 1     : ")
'	XstLog ("           dir$ : " + dir$)
'	XstLog ("          home$ : " + home$)
'	XstLog ("         xbdir$ : " + xbdir$)
'	XstLog ("         xbnew$ : " + xbnew$)
'	XstLog ("         dirxb$ : " + dirxb$)
'	XstLog ("      dirxbxxx$ : " + dirxbxxx$)
'	XstLog ("  dirxbxxxcopx$ : " + dirxbxxxcopx$)
'	XstLog ("        homexb$ : " + homexb$)
'	XstLog ("     homexbxxx$ : " + homexbxxx$)
'	XstLog (" homexbxxxcopx$ : " + homexbxxxcopx$)
'	XstLog (STRING$(xb) + " " + STRING$(xb0) + " " + STRING$(xb1) + " " + STRING$(xb2))
'	XstLog (STRING$(usr) + " " + STRING$(usr0) + " " + STRING$(usr1) + " " + STRING$(usr2))
'	XstLog (STRING$(dir) + " " + STRING$(dir0) + " " + STRING$(dir1) + " " + STRING$(dir2))
'	XstLog (STRING$(home) + " " + STRING$(home0) + " " + STRING$(home1) + " " + STRING$(home2))
'
' XBDIR must be set to a directory that contains valid XBasic files
' so file access during initialization gets valid XBasic files.
' If XBasic is started from "/usr/xb" or "/xb", XBDIR, XBNEW,
' and current directory are all set to "/usr/xb" or "/xb".
'
'	IF dir THEN							' startup directory has valid XBasic directory tree
'		xbdir$ = dirxb$
'		xbnew$ = dirxb$
'	ELSE
'		SELECT CASE dir$
'			CASE "/usr/xb"
'				SELECT CASE TRUE
'					CASE usr 			: xbdir$ = "/usr/xb"	: xbnew$ = "/usr/xb"
'					CASE xb				: xbdir$ = "/xb"			: xbnew$ = "/xb"
'					CASE home			: xbdir$ = homexb$		: xbnew$ = homexb$
'					CASE ELSE			: xbdir$ = dir$				: xbnew$ = homexb$
'				END SELECT
'			CASE "/xb"
'				SELECT CASE TRUE
'					CASE xb				: xbdir$ = "/xb"			: xbnew$ = "/xb"
'					CASE usr			: xbdir$ = "/usr/xb"	: xbnew$ = "/usr/xb"
'					CASE home			: xbdir$ = homexb$		: xbnew$ = homexb$
'					CASE ELSE			: xbdir$ = dir$				: xbnew$ = homexb$
'				END SELECT
'			CASE ELSE
'				SELECT CASE TRUE
'					CASE home			: xbdir$ = homexb$		: xbnew$ = homexb$
'					CASE usr			: xbdir$ = "/usr/xb"	: xbnew$ = homexb$
'					CASE xb				: xbdir$ = "/xb"			: xbnew$ = homexb$
'					CASE ELSE			: xbdir$ = homexb$		: xbnew$ = homexb$
'				END SELECT
'		END SELECT
'	END IF
'
'	XstLog ("     PASS 2     : ")
'	XstLog ("          home$ : " + home$)
'	XstLog ("         xbdir$ : " + xbdir$)
'	XstLog ("         xbnew$ : " + xbnew$)
'	XstLog ("         dirxb$ : " + dirxb$)
'	XstLog ("      dirxbxxx$ : " + dirxbxxx$)
'	XstLog ("  dirxbxxxcopx$ : " + dirxbxxxcopx$)
'	XstLog ("        homexb$ : " + homexb$)
'	XstLog ("     homexbxxx$ : " + homexbxxx$)
'	XstLog (" homexbxxxcopx$ : " + homexbxxxcopx$)
'
'	xbdir$ = $$PathSlash$ + "xb"
'	xbnew$ = $$PathSlash$ + "xb"
'	XstSetEnvironmentVariable (@"XBDIR", @xbdir$)
'	XstSetEnvironmentVariable (@"XBNEW", @xbnew$)
'
'	XstGetEnvironmentVariable (@"XBDIR", @xbdir$)
'	XstGetEnvironmentVariable (@"XBNEW", @xbnew$)
'	XstLog ("     PASS 3     : ")
'	XstLog ("          home$ : " + home$)
'	XstLog ("         xbdir$ : " + xbdir$)
'	XstLog ("         xbnew$ : " + xbnew$)
'	XstLog ("         dirxb$ : " + dirxb$)
'	XstLog ("      dirxbxxx$ : " + dirxbxxx$)
'	XstLog ("  dirxbxxxcopx$ : " + dirxbxxxcopx$)
'	XstLog ("        homexb$ : " + homexb$)
'	XstLog ("     homexbxxx$ : " + homexbxxx$)
'	XstLog (" homexbxxxcopx$ : " + homexbxxxcopx$)
'
'	Xio ()
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
	XstExceptionToSystemException (exception, @sysException)
	RaiseException (sysException, 0, 0, 0)
END FUNCTION
'
'
' #########################################
' #####  XstDateAndTimeToFileTime ()  #####
' #########################################
'
FUNCTION  XstDateAndTimeToFileTime (year, month, day, weekDay, hour, minute, second, nanos, @filetime$$)
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
	SystemTimeToFileTime (&st, &ft)
	filetime$$ = GMAKE (ft.high, ft.low)
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
	return = $$TRUE																' error name not found
	object = $$FALSE															' object not yet found
	nature = $$FALSE															' nature not yet found
	error$ = TRIM$ (err$)
	uobject = UBOUND (errorObject$[])
	unature = UBOUND (errorNature$[])
'
	space = INCHR (error$, " \t")								' space or tab separator
	IFZ space THEN
		e$ = error$
		error$ = ""
	ELSE
		e$ = TRIM$(LEFT$(error$, space))
		error$ = TRIM$(MID$(error$, space+1))
	END IF
'
	FOR i = 1 TO uobject
		IF (e$ = errorObject$[i]) THEN
			error = error OR (i << 8)							' error object found
			EXIT FOR
		END IF
		IF (error$ = errorObject$[i]) THEN
			error = error OR (i << 8)
			EXIT FOR
		END IF
	NEXT i
'
	FOR i = 1 TO unature
		IF (error$ = errorNature$[i]) THEN
			error = error OR i										' error nature found
			EXIT FOR															' only one error nature
		END IF
		IF (e$ = errorNature$[i]) THEN
			error = error OR i
			EXIT FOR
		END IF
	NEXT i
	RETURN (error)
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
		CASE $$ExceptionSegmentViolation					: sysException = $$EXCEPTION_ACCESS_VIOLATION
		CASE $$ExceptionOutOfBounds								: sysException = $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED
		CASE $$ExceptionBreakpoint								: sysException = $$EXCEPTION_BREAKPOINT
		CASE $$ExceptionBreakKey									: sysException = $$EXCEPTION_CONTROL_C_EXIT
		CASE $$ExceptionAlignment									: sysException = $$EXCEPTION_DATATYPE_MISALIGNMENT
		CASE $$ExceptionDenormal									: sysException = $$EXCEPTION_FLOAT_DENORMAL_OPERAND
		CASE $$ExceptionDivideByZero							: sysException = $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO
		CASE $$ExceptionInvalidOperation					: sysException = $$EXCEPTION_FLOAT_INVALID_OPERATION
		CASE $$ExceptionOverflow									: sysException = $$EXCEPTION_FLOAT_OVERFLOW
		CASE $$ExceptionStackCheck								: sysException = $$EXCEPTION_FLOAT_STACK_CHECK
		CASE $$ExceptionUnderflow									: sysException = $$EXCEPTION_FLOAT_UNDERFLOW
		CASE $$ExceptionInvalidInstruction				: sysException = $$EXCEPTION_ILLEGAL_INSTRUCTION
		CASE $$ExceptionDivideByZero							: sysException = $$EXCEPTION_INT_DIVIDE_BY_ZERO
		CASE $$ExceptionOverflow									: sysException = $$EXCEPTION_INT_OVERFLOW
		CASE $$ExceptionPrivilege									: sysException = $$EXCEPTION_PRIV_INSTRUCTION
		CASE $$ExceptionStackOverflow							: sysException = $$EXCEPTION_STACK_OVERFLOW
		CASE ELSE																	: sysException = $$EXCEPTION_NONCONTINUABLE_EXCEPTION
	END SELECT
END FUNCTION
'
'
' #########################################
' #####  XstFileTimeToDateAndTime ()  #####
' #########################################
'
FUNCTION  XstFileTimeToDateAndTime (filetime$$, year, month, day, weekDay, hour, minute, second, nanos)
	SYSTEMTIME  st
	FILETIME  ft
'
	ft.low = GLOW (filetime$$)
	ft.high = GHIGH (filetime$$)
	FileTimeToSystemTime (&ft, &st)
'
	year = st.year
	month = st.month
	day = st.day
	weekDay = st.weekDay
	hour = st.hour
	minute = st.minute
	second = st.second
	nanos = st.msec * 1000000
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
	addr = GetCommandLineA()
	line$ = CSTRING$(addr)
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
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
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
		##WHOMASK = $$FALSE
		setarg = $$TRUE
		setargc = argc
		DIM setargv$[]
		IF (argc > 0) THEN
			DIM setargv$[argc-1]
			FOR i = 0 TO argc-1
				setargv$[i] = argv$[i]
			NEXT i
		END IF
		##WHOMASK = whomask
	END IF
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
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = 0
'
	DIM systemInfo[8]
	##LOCKOUT = $$TRUE
	GetSystemInfo (&systemInfo[])
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	processorType = systemInfo[6]
	IFZ processorType THEN processorType = 80386
	name$ = STRING$(processorType)
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
	STATIC	SYSTEMTIME	systemTime
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
	STATIC	SYSTEMTIME	systemTime
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
' ##########################################
' #####  XstGetEnvironmentVariable ()  #####
' ##########################################
'
FUNCTION  XstGetEnvironmentVariable (name$, value$)
'
	value$ = ""
	IFZ name$ THEN RETURN
'
	value$ = NULL$ (4095)
	length = GetEnvironmentVariableA (&name$, &value$, 4095)
	IF (length < 0) THEN
		value$ = ""
	ELSE
		value$ = LEFT$ (value$, length)
	END IF
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
	addr = GetEnvironmentStrings()
'
	IF addr THEN
		DO UNTIL done
			line$ = XstNextCLine$ (addr, @index, @done)
			IF line$ THEN
				envp$[count] = line$
				INC count
			END IF
		LOOP WHILE line$
	END IF
'
	upper = count - 1
	REDIM envp$[upper]
END FUNCTION
'
'
'
' ################################
' #####  XstGetException ()  #####
' ################################
'
FUNCTION  XstGetException (exception)
'
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
	name$ = "windows win32 coff microsoft"
'
END FUNCTION
'
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
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	version = XxxGetVersion ()
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	platform = (version >> 16) AND 0x00FF
	IF (platform == $$VER_PLATFORM_WIN32_NT) THEN name$ = "WindowsNT" ELSE name$ = "Windows"
END FUNCTION
'
'
' ################################
' #####  XstGetOSVersion ()  #####
' ################################
'
FUNCTION  XstGetOSVersion (major, minor)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	version = XxxGetVersion ()
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	major = version{8,0}
	minor = version{8,8}
END FUNCTION
'
'
' ####################################
' #####  XstGetOSVersionName ()  #####
' ####################################
'
FUNCTION  XstGetOSVersionName (name$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	version = XxxGetVersion ()
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	majorVersion = version{8,0}
	minorVersion = version{8,8}
	name$ = STRING$ (majorVersion) + "." + STRING$ (minorVersion)
END FUNCTION
'
'
' ###############################
' #####  XstGetPrintTab ()  #####
' ###############################
'
FUNCTION  XstGetPrintTab (pixels)
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
FUNCTION  XstGetSystemError (sysError)
	sysError = GetLastError ()
END FUNCTION
'
'
' #################################
' #####  XstGetSystemTime ()  #####
' #################################
'
FUNCTION  XstGetSystemTime (msec)
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
' #############################
' #####  XstKillTimer ()  #####
' #############################
'
FUNCTION  XstKillTimer (timer)
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
' #######################
' #####  XstLog ()  #####
' #######################
'
FUNCTION  XstLog (message$)
	STATIC  enter
'
	whomask = ##WHOMASK
	IF whomask THEN w$ = "u" ELSE w$ = "s"
	XstGetDateAndTime (@year, @month, @day, 0, @hour, @min, @sec, @nanos)
	stamp$ = w$ + RIGHT$("000" + STRING$(year),4) + RIGHT$("0" + STRING$(month),2) + RIGHT$("0" + STRING$(day),2) + ":" + RIGHT$("0" + STRING$(hour),2) + RIGHT$("0" + STRING$(min),2) + RJUST$("0" + STRING$(sec),2) + "." + RIGHT$("000" + STRING$(nanos\1000000),3) + ": "
'
	IFZ enter THEN
		enter = $$TRUE
		ofile = OPEN ("x.log", $$WRNEW)
	ELSE
		ofile = OPEN ("x.log", $$WR)
	END IF
'
	IF (ofile >= 3) THEN
		length = LOF (ofile)
		SEEK (ofile, length)
		PRINT [ofile], stamp$ + message$
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
	STATIC	SYSTEMTIME	systemTime
'
	systemTime.year			= year
	systemTime.month		= month
	systemTime.day			= day
	systemTime.weekDay	= weekDay
	systemTime.hour			= hour
	systemTime.minute		= minute
	systemTime.second		= second
	systemTime.msec			= nanos \ 1000000
	error = SetSystemTime (&systemTime)
	error = NOT error
	RETURN (error)
END FUNCTION
'
'
' ##########################################
' #####  XstSetEnvironmentVariable ()  #####
' ##########################################
'
FUNCTION  XstSetEnvironmentVariable (name$, value$)
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
		##ERROR = error
		RETURN ($$TRUE)
	END IF
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
	SetLastError (sysError)
END FUNCTION
'
'
' #########################
' #####  XstSleep ()  #####
' #########################
'
FUNCTION  XstSleep (ms)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	delta = ms
	start = GetTickCount()
'
' sleep system: system should be smart enough not to sleep too long !!!
'
	IFZ whomask THEN
		DO
			##WHOMASK = 0
			##LOCKOUT = $$TRUE
			Sleep (delta)
			time = GetTickCount()
			##LOCKOUT = lockout
			##WHOMASK = whomask
			delta = ms - (time - start)
		LOOP UNTIL (delta <= 0)
		RETURN
	END IF
'
' sleep user, process system events/messages every .200 seconds
'
	DO
		SELECT CASE TRUE
			CASE (delta < 0)		: EXIT DO					' no more sleep
			CASE (delta = 0)		: delta = 0				' sleep time slice
			CASE (delta <= 200)	: delta = delta		' sleep <= 200 ms
			CASE ELSE						: delta = 200			' sleep 200 ms then loop
		END SELECT
'
		XxxDispatchEvents ($$FALSE, 0)					' process system events
		IF ##SOFTBREAK THEN EXIT DO							' process break keystrokes
'
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		Sleep (delta)
		time = GetTickCount()
		##LOCKOUT = lockout
		##WHOMASK = whomask
'
		delta = ms - (time - start)
	LOOP UNTIL (delta <= 0)
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
	who = ##WHOMASK
	##WHOMASK = 0
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
	##WHOMASK = who
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
FUNCTION  XstSystemExceptionNumberToName (sysException, sysException$)
'
	SELECT CASE exception
		CASE $$EXCEPTION_ACCESS_VIOLATION					: sysException$ = "Access Violation"
		CASE $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED		: sysException$ = "Bounds Error"
		CASE $$EXCEPTION_BREAKPOINT								: sysException$ = "Breakpoint"
		CASE $$EXCEPTION_CONTROL_C_EXIT						: sysException$ = "Control C Break"
		CASE $$EXCEPTION_DATATYPE_MISALIGNMENT		: sysException$ = "Data Misaligned"
		CASE $$EXCEPTION_FLOAT_DENORMAL_OPERAND		: sysException$ = "Denormal Operand"
		CASE $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO			: sysException$ = "Divide by Zero"
		CASE $$EXCEPTION_FLOAT_INVALID_OPERATION	: sysException$ = "Invalid Operation"
		CASE $$EXCEPTION_FLOAT_OVERFLOW						: sysException$ = "Overflow"
		CASE $$EXCEPTION_FLOAT_STACK_CHECK				: sysException$ = "Stack Check"
		CASE $$EXCEPTION_FLOAT_UNDERFLOW					: sysException$ = "Underflow"
		CASE $$EXCEPTION_ILLEGAL_INSTRUCTION			: sysException$ = "Invalid Instruction"
		CASE $$EXCEPTION_INT_DIVIDE_BY_ZERO				: sysException$ = "Integer Divide by Zero"
		CASE $$EXCEPTION_INT_OVERFLOW							: sysException$ = "Integer Overflow"
		CASE $$EXCEPTION_INVALID_DISPOSITION			: sysException$ = "Invalid Disposition"
		CASE $$EXCEPTION_NONCONTINUABLE_EXCEPTION	: sysException$ = "Fatal Exception"
		CASE $$EXCEPTION_PRIV_INSTRUCTION					: sysException$ = "Privilege Violation"
		CASE $$EXCEPTION_STACK_OVERFLOW						: sysException$ = "Stack Overflow"
		CASE $$EXCEPTION_CONTINUE_SEARCH					: sysException$ = "Continue Search"
		CASE $$EXCEPTION_EXECUTE_HANDLER					: sysException$ = "Execute Handler"
		CASE $$EXCEPTION_CONTINUE_EXECUTION				: sysException$ = "Continue Execution"
		CASE ELSE																	: sysException$ = "Unknown System Exception Number"
	END SELECT
END FUNCTION
'
'
' ##############################################
' #####  XstSystemExceptionToException ()  #####
' ##############################################
'
FUNCTION  XstSystemExceptionToException (sysException, exception)
'
	SELECT CASE sysException
		CASE $$EXCEPTION_ACCESS_VIOLATION					: exception = $$ExceptionSegmentViolation
		CASE $$EXCEPTION_ARRAY_BOUNDS_EXCEEDED		: exception = $$ExceptionOutOfBounds
		CASE $$EXCEPTION_BREAKPOINT								: exception = $$ExceptionBreakpoint
		CASE $$EXCEPTION_CONTROL_C_EXIT						: exception = $$ExceptionBreakKey
		CASE $$EXCEPTION_DATATYPE_MISALIGNMENT		: exception = $$ExceptionAlignment
		CASE $$EXCEPTION_FLOAT_DENORMAL_OPERAND		: exception = $$ExceptionDenormal
		CASE $$EXCEPTION_FLOAT_DIVIDE_BY_ZERO			: exception = $$ExceptionDivideByZero
		CASE $$EXCEPTION_FLOAT_INVALID_OPERATION	: exception = $$ExceptionInvalidOperation
		CASE $$EXCEPTION_FLOAT_OVERFLOW						: exception = $$ExceptionOverflow
		CASE $$EXCEPTION_FLOAT_STACK_CHECK				: exception = $$ExceptionStackCheck
		CASE $$EXCEPTION_FLOAT_UNDERFLOW					: exception = $$ExceptionUnderflow
		CASE $$EXCEPTION_ILLEGAL_INSTRUCTION			: exception = $$ExceptionInvalidInstruction
		CASE $$EXCEPTION_INT_DIVIDE_BY_ZERO				: exception = $$ExceptionDivideByZero
		CASE $$EXCEPTION_INT_OVERFLOW							: exception = $$ExceptionOverflow
		CASE $$EXCEPTION_PRIV_INSTRUCTION					: exception = $$ExceptionPrivilege
		CASE $$EXCEPTION_STACK_OVERFLOW						: exception = $$ExceptionStackOverflow
		CASE ELSE																	: exception = $$ExceptionUnknown
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
'
' ###########################
' #####  XstBinRead ()  #####
' ###########################
'
FUNCTION  XstBinRead (fileNumber, bufferAddr, maxBytes)
	EXTERNAL  errno
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
	EXTERNAL errno
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
'	return	:	$$TRUE		error (##ERROR set)
'						$$FALSE		no error
'
FUNCTION  XstChangeDirectory (d$)
	EXTERNAL  errno
'
	IFZ d$ THEN RETURN ($$FALSE)
	dir$ = XstPathString$ (@d$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = SetCurrentDirectoryA (&dir$)
	##LOCKOUT = lockout
'
	IF okay THEN
		##WHOMASK = whomask
		RETURN ($$FALSE)
	END IF
'
'	error
'
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
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
FUNCTION  XstCopyFile (s$, d$)
	EXTERNAL errno
'
	IF (s$ = d$) THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	IFZ s$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	IFZ d$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	source$ = XstPathString$ (@s$)
	dest$ = XstPathString$ (@d$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = CopyFileA (&source$, &dest$, $$FALSE)		' overwrite if exists
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ okay THEN
		##LOCKOUT = $$TRUE
		errno = GetLastError ()
		##LOCKOUT = lockout
'
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
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
FUNCTION  XstDeleteFile (f$)
	EXTERNAL  errno
'
	IFZ f$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	file$ = XstPathString$ (@f$)
	XstGetFileAttributes (@file$, @attributes)
'
	IFZ attributes THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	return = $$FALSE
	SELECT CASE TRUE
		CASE (attributes AND $$FileDirectory)
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					okay = RemoveDirectoryA (&file$)
					##LOCKOUT = lockout
					##WHOMASK = whomask
					IFZ okay THEN GOSUB Error
		CASE ELSE
					##WHOMASK = 0
					##LOCKOUT = $$TRUE
					okay = DeleteFileA (&file$)
					##LOCKOUT = lockout
					##WHOMASK = whomask
					IFZ okay THEN GOSUB Error
	END SELECT
	RETURN (return)
'
'
'	*****  Error  *****
'
SUB Error
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##LOCKOUT = lockout
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	return = $$TRUE
END SUB
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
FUNCTION  XstFindFile (file$, path$[], path$, attr)
'
	a = attr
	attr = 0
	path$ = ""
	error = ERROR(0)
	IFZ file$ THEN RETURN
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
FUNCTION  XstFindFiles (basepath$, filter$, recurse, file$[])
	FILEINFO  fileinfo[]

	path$ = XstPathString$(basepath$)
	IFZ path$ THEN RETURN XstGetCurrentDirectory (@path$)
'
	XstGetFileAttributes (@path$, @attribute)
	IFZ (attribute AND $$FileDirectory) THEN RETURN
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
'	RETURN	current directory path
'					""		error (##ERROR set)
'
'	Only "\" terminates with "\"
'
FUNCTION  XstGetCurrentDirectory (current$)
	EXTERNAL errno
	AUTOX dir$
'
	dir$ = NULL$(255)												' 256 including terminating null
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	##LOCKOUT = $$TRUE
	a = GetCurrentDirectoryA (256, &dir$)
	##LOCKOUT = entryLOCKOUT
	IFZ a THEN GOTO error
'
	IF (a >= 256) THEN
		INC a																			' add terminator
		##WHOMASK = entryWHOMASK
		dir$ = NULL$ (a)
		##WHOMASK = 0
'
		##LOCKOUT = $$TRUE
		a = GetCurrentDirectoryA (a, &dir$)
		##LOCKOUT = entryLOCKOUT
		IFZ a THEN GOTO error
	END IF
'
	dir$ = TRIM$ (dir$)
	lenDir = LEN (dir$)													' only "\" terminates with "\"
	IF (lenDir > 1) THEN
		IF (dir${lenDir - 1} = '\') THEN
			dir$ = RCLIP$ (dir$, 1)
		END IF
	END IF
'
	##WHOMASK = entryWHOMASK
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
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	current$ = ""
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
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
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	IFZ driveTypes$[] THEN GOSUB Initialize
'
	count = 0
	DIM drive$[63]
	DIM driveType[63]
	DIM driveType$[63]
'
	buffer$ = NULL$(255)
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	length = GetLogicalDriveStringsA (255, &buffer$)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
' if GetLogicalDriveStringsA() not implemented (as on Win32s)
'
	count = 0
	IF (length < 1) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		drives = GetLogicalDrives ()
		##LOCKOUT = entryLOCKOUT
		##WHOMASK = entryWHOMASK
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
		##LOCKOUT = entryLOCKOUT
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
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		dt = GetDriveTypeA (&drive$)
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
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
	##WHOMASK = 0
	DIM driveTypes$[ 15]
	driveTypes$[ $$DriveTypeUnknown ]			= "Unknown"
	driveTypes$[ $$DriveTypeDamaged ]			= "Rootless"
	driveTypes$[ $$DriveTypeRemovable ]		= "RemovableMedia"
	driveTypes$[ $$DriveTypeFixed ]				= "FixedMedia"
	driveTypes$[ $$DriveTypeRemote ]			= "Remote"
	driveTypes$[ $$DriveTypeCDROM ]				= "CDROM"
	driveTypes$[ $$DriveTypeRamDisk ]			= "RamDisk"
	##WHOMASK = entryWHOMASK
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
FUNCTION  XstGetFileAttributes (f$, attributes)
'
	$mask = 0x03B7								' Windows attributes
'
	attributes = 0
	IFZ f$ THEN RETURN
	file$ = XstPathString$ (@f$)
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	attributes = GetFileAttributesA (&file$)
	##WHOMASK = whomask
	##LOCKOUT = lockout
'
	IF (attributes = -1) THEN				' no such file
		SetLastError (0)
		attributes = 0
		RETURN ($$FALSE)
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
FUNCTION  XstGetFiles (f$, files$[])
	EXTERNAL  errno
	STATIC	FILEINFO	findData
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
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##LOCKOUT = $$TRUE													' avoid break during FindFile
'
	findData.name = ""
	##WHOMASK = 0
	findHandle = FindFirstFileA (&filter$, &findData)
	##WHOMASK = entryWHOMASK
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
			##WHOMASK = 0
			found = FindNextFileA (findHandle, &findData)
			##WHOMASK = entryWHOMASK
		LOOP WHILE found
		##WHOMASK = 0
		FindClose (findHandle)
		##WHOMASK = entryWHOMASK
	END IF
	##LOCKOUT = entryLOCKOUT
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
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##LOCKOUT = $$TRUE												' avoid break during FindFile
'
	##WHOMASK = 0
	findHandle = FindFirstFileA (&filter$, &fileInfo[file])
	##WHOMASK = entryWHOMASK
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
			##WHOMASK = 0
			found = FindNextFileA (findHandle, &fileInfo[file])
			##WHOMASK = entryWHOMASK
		LOOP WHILE found
'
		##WHOMASK = 0
		FindClose (findHandle)
		##WHOMASK = entryWHOMASK
	END IF
	##LOCKOUT = entryLOCKOUT
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
' ##############################
' #####  XstLoadString ()  #####
' ##############################
'
FUNCTION  XstLoadString (f$, text$)
'
	text$ = ""
	##ERROR = $$FALSE
	file$ = XstPathString$ (@f$)
'
	XstGetFileAttributes (@file$, @attributes)					' Does file exist?
	IFZ attributes THEN ##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent) : RETURN ($$TRUE)
	IF (attributes AND $$FileDirectory) THEN ##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName) : RETURN ($$TRUE)
'
	ifile = OPEN (file$, $$RD)
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
' ###################################
' #####  XstLockFileSection ()  #####
' ###################################
'
FUNCTION  XstLockFileSection (file, mode, offset$$, length$$)
	SHARED  LOCK  fileLock[]
	SHARED  FILE  fileInfo[]
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
	IFZ length$$ THEN end$$ = 0x7FFFFFFFFFFFFFFF
	upper = UBOUND (fileLock[file,])
'
	FOR i = 0 TO upper
		IFZ fileLock[file,i].file THEN
			IF (slot < 0) THEN slot = i
		ELSE
			first$$ = fileLock[file,i].offset
			final$$ = first$$ + fileLock[file,i].length - 1$$
			IF (final$$ < first$$) THEN final$$ = 0x7FFFFFFFFFFFFFFF
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
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = LockFile (sfile, offsetLow, offsetHigh, lengthLow, lengthHigh)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	IFZ okay THEN
		errno = GetLastError ()
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
FUNCTION  XstMakeDirectory (dir$)
	EXTERNAL  errno
	STATIC  SECURITY_ATTRIBUTES  securityAttributes
'
	IFZ dir$ THEN ##ERROR = (($$ErrorObjectDirectory << 8) OR $$ErrorNatureInvalidName) : RETURN ($$TRUE)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	directory$ = XstPathString$ (@dir$)
	securityAttributes.length = SIZE(SECURITY_ATTRIBUTES)
	securityAttributes.securityDescriptor = 0
	securityAttributes.inherit = 0
'
	##LOCKOUT = $$TRUE
'	okay = CreateDirectoryA (&directory$, &securityAttributes)
	okay = CreateDirectoryA (&directory$, 0)
	##LOCKOUT = entryLOCKOUT
'
	IF okay THEN
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
'	Error
'
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
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
	FOR i = 0x20 TO 0xFF
		charsetFilename[i] = i
		charsetFilenameFirstLast[i] = i
	NEXT i
'
	charsetFilename['/'] = charsetFilename['\\']		' windows
'	charsetFilename['\\'] = charsetFilename['/']		' unix
	charsetFilename['"'] = 0
	charsetFilename['<'] = 0
	charsetFilename['>'] = 0
'	charsetFilename[':'] = 0
	charsetFilename['|'] = 0
	charsetFilenameFirstLast['/'] = '\\'	' path separator character (windows)
'	charsetFilenameFirstLast['\\'] = '/'	' path separator character (unix)
	charsetFilenameFirstLast[' '] = 0			' no leading/trailing spaces
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
		path$ = NULL$(255)												' 256 including terminating null
		a = GetFullPathNameA(&opath$, 256, &path$, &tmp$)
		opath$ = TRIM$(path$)
	END IF
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
'	PRINT HEX$(&o$,8);; "<"; o$; ">"
'	PRINT HEX$(&n$,8);; "<"; n$; ">"
'
	old$ = TRIM$ (o$)
	new$ = TRIM$ (n$)
'
	IFZ old$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	IFZ new$ THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidName
		##ERROR = error
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
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	IF new THEN
		error = ($$ErrorObjectFile << 8) OR $$ErrorNatureExists
		##ERROR = error
		RETURN ($$TRUE)
	END IF
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = MoveFileA (&old$, &new$)
	##LOCKOUT = lockout
	##WHOMASK = whomask
'
	IFZ okay THEN
		##LOCKOUT = $$TRUE
		errno = GetLastError ()
		##LOCKOUT = $$FALSE
'
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
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
' #####  XstSaveString ()  #####
' ##############################
'
FUNCTION  XstSaveString (f$, text$)
'
	##ERROR = $$FALSE
	file$ = XstPathString$ (@f$)
'
	ofile = OPEN (file$, $$WRNEW)
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
FUNCTION  XstSaveStringArray (f$, text$[])
'
	##ERROR = $$FALSE
	file$ = XstPathString$ (@f$)
'
	ofile = OPEN (file$, $$WRNEW)
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
FUNCTION  XstSaveStringArrayCRLF (f$, text$[])
'
	##ERROR = $$FALSE
	file$ = XstPathString$ (@f$)
'
	ofile = OPEN (file$, $$WRNEW)
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
FUNCTION  XstSetCurrentDirectory (dir$)
	EXTERNAL  errno
'
	newDirectory$ = TRIM$ (dir$)
	IFZ newDirectory$ THEN RETURN ($$FALSE)
	newDirectory$ = XstPathString$ (@newDirectory$)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
'
	##LOCKOUT = $$TRUE
	okay = SetCurrentDirectoryA (&newDirectory$)
	##LOCKOUT = entryLOCKOUT
'
	IF okay THEN
		##WHOMASK = entryWHOMASK
		RETURN ($$FALSE)
	END IF
'
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' #####################################
' #####  XstUnlockFileSection ()  #####
' #####################################
'
FUNCTION  XstUnlockFileSection (file, mode, offset$$, length$$)
	SHARED  LOCK  fileLock[]
	SHARED  FILE  fileInfo[]
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
	IFZ length$$ THEN end$$ = 0x7FFFFFFFFFFFFFFF
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
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	okay = UnlockFile (sfile, offsetLow, offsetHigh, lengthLow, lengthHigh)
	##LOCKOUT = $$FALSE
	##WHOMASK = whomask
'
	IFZ okay THEN
		errno = GetLastError ()
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
END SUB
'
	IF bytes THEN PRINT "XstCopyBytes() : Up1 : error : (final bytes != 0) : "; bytes
END FUNCTION
'
'
' ###############################
' #####  XstDeleteLines ()  #####
' ###############################
'
FUNCTION  XstDeleteLines (array$[], start, count)
'
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
	quote = $$FALSE
	IF UBYTEAT(sourceAddr, offset) = '"' THEN
		quote = $$TRUE
	END IF
	startOffset = offset
	DO
		INC offset
		char = UBYTEAT (sourceAddr, offset)
		IF char = '"' THEN
			quote = NOT quote
		END IF
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
' ###########################
' #####  XxxFormat$ ()  #####
' ###########################
'
FUNCTION  XxxFormat$ (format$, argType, arg$$)
	STATIC	UBYTE  fmtLevel[]
	STATIC	UBYTE  fmtBegin[]
'
'	PRINT "FORMAT$() : <"; format$; "> <"; STRING$(argType); "> <"; STRING$(arg$$); ">"
'
	IFZ fmtLevel[] THEN GOSUB Initialize
	IFZ format$ THEN RETURN 										' empty format string
'
	IF (argType = $$STRING) THEN arg$ = CSTRING$(GLOW(arg$$))
'
	fmtStrPtr = 1
	lenFmtStr = LEN (format$)
	GOSUB StringString													'	top StringString call
'
	IFZ fmtStrPtr THEN
'		PRINT "a<" + resultString$ + "> " + STRING$(LEN(resultString$))
		RETURN (resultString$)
	END IF
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
				PRINT "FORMAT$() : error : (numeric data with '&')"
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
									PRINT "FORMAT$() : error : (leading"; leadSign$; "excludes"; CHR$ (fmtChar); ")"
									GOTO eeeQuitFormat
								END IF
		END SELECT
'
' case < or | or >:		all we needed to do is count them
' End of char fmt:		add to resultString$, and exit loop
'
		IF (((fmtChar = '<') OR (fmtChar = '|') OR (fmtChar = '>')) AND (nextChar != fmtChar)) THEN
			IF (argType != $$STRING) THEN
				PRINT "FORMAT$() : error : (can't print number with string format)"
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
				PRINT "FORMAT$() : error : (no printable digits)"
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
			IF (argType = $$STRING) THEN
				PRINT "FORMAT$() : error : (string argument)"
				GOTO eeeQuitFormat
			END IF
'
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
'	PRINT "b<" + resultString$ + "> " + STRING$(LEN(resultString$))
	RETURN (resultString$)
'
'
' *****  Initialize  *****
'
SUB Initialize
	entryWhomask = ##WHOMASK
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
	##WHOMASK = entryWhomask
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
'	PRINT "e<" + resultString$ + "> " + STRING$(LEN(resultString$))
	RETURN (resultString$)
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
		IF timer[i] THEN
			IF timer[i].who THEN XstKillTimer (timer[i].timer)
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
	IFZ libraryName$[] THEN RETURN
	upper = UBOUND (libraryName$[])
'
	FOR i = 0 TO upper
		name$ = libraryName$[i]
		hand = libraryHandle[i]
		free = $$FALSE
		IF name$ THEN
			IF hand THEN
				SELECT CASE TRUE
					CASE (handle = -1)		:	free = $$TRUE
					CASE (handle = hand)	:	free = $$TRUE
					CASE (lib$ = name$)		:	free = $$TRUE
				END SELECT
			END IF
		END IF
		IF free THEN
			FreeLibrary (hand)
			libraryName$[i] = ""
			libraryHandle[i] = 0
		END IF
	NEXT i
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
	whomask = ##WHOMASK
	IFZ lib$ THEN RETURN
'
	upper = UBOUND (lib$)
	IF (lib${upper} = '"') THEN lib$ = RCLIP$ (lib$,1)
	IF (lib${0} = '"') THEN lib$ = LCLIP$ (lib$,1)
'
	IFZ libraryName$[] THEN GOSUB Initialize
	upper = UBOUND (libraryName$[])
	handle = 0
	slot = -1
'
	FOR i = 0 TO upper
		name$ = libraryName$[i]
		hand = libraryHandle[i]
		IF (slot < 0) THEN
			IFZ name$ THEN slot = i : hand = 0
			IFZ hand THEN slot = i : name$ = ""
		END IF
		IFZ handle THEN
			IF name$ THEN
				IF hand THEN
					IF (lib$ = name$) THEN handle = hand
				END IF
			END IF
		END IF
	NEXT i
'
	IF handle THEN RETURN (handle)
'
	handle = LoadLibraryA (&lib$)		' returns 0 when fails
'
	IF handle THEN
		IF (slot < 0) THEN
			##WHOMASK = 0
			slot = upper + 1
			upper = upper + 16
			REDIM libraryName$[upper]
			REDIM libraryHandle[upper]
			##WHOMASK = whomask
		END IF
		##WHOMASK = 0
		libraryName$[slot] = lib$
		libraryHandle[slot] = handle
		##WHOMASK = whomask
	END IF
'
	RETURN (handle)
'
'
' *****  Initialize  *****
'
SUB Initialize
	##WHOMASK = 0
	DIM libraryName$[15]
	DIM libraryHandle[15]
	##WHOMASK = whomask
END SUB
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
	SHARED	errorObject$[]
	SHARED	errorNature$[]
	SHARED  sysSaveNewline
	SHARED  sysPasteNewline
	SHARED  userSaveNewline
	SHARED  userPasteNewline
'
	whomask = ##WHOMASK
	##WHOMASK = 0
'
	DIM	charsetBackslash[255]
	DIM	charsetBackslashChar[255]
	DIM	charsetHexLowerToUpper[255]
	DIM	charsetNormalChar[255]
	DIM	charsetUpperToLower[255]
	DIM exception$[31]
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
'
' The following was the WRONG way to handle backslash characters in strings.
' See documentation for v6.0018 in window displayed by "help, new".
'
'	DIM backslash[]
'	XstGetOSName (@osname$)
'	osname$ = LCASE$ (osname$)
'
'	windows = INSTR (osname$, "windows")
'	linux = INSTR (osname$, "linux")
'
'	IF windows THEN
'		XstLoadStringArray ("xb.ini", @ini$[])
'		IFZ ini$[] THEN XstLoadStringArray ("c:/windows/xb.ini", @ini$[])
'	END IF
'
'	IF linux THEN
'		XstLoadStringArray (".xbrc", @ini$[])
'		IFZ ini$[] THEN XstLoadStringArray ("xb.ini", @ini$[])
'		IFZ ini$[] THEN XstLoadStringArray ("/etc/xb.ini", @ini$[])
'	END IF
'
'	IF ini$[] THEN
'		u = UBOUND (ini$[])
'		FOR i = 0 TO u
'			ini$ = LCASE$(TRIM$(ini$[i]))
'			IF ini$ THEN																	'
'				found = INSTR (ini$, "backslash")						' look for "backslash"
'				IF (found == 1) THEN												' found "backslash"
'					found = INSTR (ini$, "=", found+1)				' look for "="
'					IF found THEN															' found "backslash" and "="
'						these$ = MID$ (ini$, found+1)						' these$ = everything after "="
'						IF these$ THEN													'
'							uthese = UBOUND (these$)							' upper byte in these$ string
'							IF (uthese < 255) THEN uthese = 255		' make room for all 8-bit chars
'							DIM backslash[uthese]									' create system backslash array
'							FOR j = 0 TO uthese										' for all bytes in these$ string
'								IF (these${j} == '1') THEN					' okay to create backslash form
'									backslash[j] = $$TRUE							' mark as backslash
'								END IF
'							NEXT j
'						END IF
'					END IF
'				END IF
'			END IF
'		NEXT i
'	END IF
'
' The XBasic IDE must create explicit backslash arrays to
' assure its own correct operation on a case-by-case basis.
' Remember, a standalone program IS the system, not the user.
' Therefore, forcing the system backslash array to work like
' the IDE wants thereby might impose that particular behavior
' on standalone applications that do not want it.
'
' Therefore the IDE needs to set its own backslash array in
' "xit.x" or in some code that is not part of applications.
'
'	XstSetBackslashArray (@backslash[])
'
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
	exception$ [ $$ExceptionUnknown                ] = "$$ExceptionUnknown"
	exception$ [ $$ExceptionUpper                  ] = "$$ExceptionUpper"
'
'
' ****************************************************
' *****  Initialize Native Error Number Strings  *****
' ****************************************************
'
  errorObject$[ $$ErrorObjectNone                ] = ""
  errorObject$[ $$ErrorObjectData                ] = "Data"
  errorObject$[ $$ErrorObjectDisk                ] = "Disk"
  errorObject$[ $$ErrorObjectFile                ] = "File"
  errorObject$[ $$ErrorObjectFont                ] = "Font"
	errorObject$[ $$ErrorObjectGrid                ] = "Grid"
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
	errorObject$[ $$ErrorObjectWindow              ] = "Window"
  errorObject$[ $$ErrorObjectCommand             ] = "Command"
	errorObject$[ $$ErrorObjectDisplay             ] = "Display"
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
	errorNature$[ $$ErrorNatureInvalidDistribution ] = "InvalidDistribution"
'
' **************************************************************
' *****  Initialize Operating System Error Number Strings  *****
' **************************************************************
'
	#OSERROR$[ $$ERROR_SUCCESS                           ] = "ERROR_SUCCESS"
	#OSERROR$[ $$ERROR_INVALID_FUNCTION                  ] = "ERROR_INVALID_FUNCTION"
	#OSERROR$[ $$ERROR_FILE_NOT_FOUND                    ] = "ERROR_FILE_NOT_FOUND"
	#OSERROR$[ $$ERROR_PATH_NOT_FOUND                    ] = "ERROR_PATH_NOT_FOUND"
	#OSERROR$[ $$ERROR_TOO_MANY_OPEN_FILES               ] = "ERROR_TOO_MANY_OPEN_FILES"
	#OSERROR$[ $$ERROR_ACCESS_DENIED                     ] = "ERROR_ACCESS_DENIED"
	#OSERROR$[ $$ERROR_INVALID_HANDLE                    ] = "ERROR_INVALID_HANDLE"
	#OSERROR$[ $$ERROR_ARENA_TRASHED                     ] = "ERROR_ARENA_TRASHED"
	#OSERROR$[ $$ERROR_NOT_ENOUGH_MEMORY                 ] = "ERROR_NOT_ENOUGH_MEMORY"
	#OSERROR$[ $$ERROR_INVALID_BLOCK                     ] = "ERROR_INVALID_BLOCK"
	#OSERROR$[ $$ERROR_BAD_ENVIRONMENT                   ] = "ERROR_BAD_ENVIRONMENT"
	#OSERROR$[ $$ERROR_BAD_FORMAT                        ] = "ERROR_BAD_FORMAT"
	#OSERROR$[ $$ERROR_INVALID_ACCESS                    ] = "ERROR_INVALID_ACCESS"
	#OSERROR$[ $$ERROR_INVALID_DATA                      ] = "ERROR_INVALID_DATA"
	#OSERROR$[ $$ERROR_OUTOFMEMORY                       ] = "ERROR_OUTOFMEMORY"
	#OSERROR$[ $$ERROR_INVALID_DRIVE                     ] = "ERROR_INVALID_DRIVE"
	#OSERROR$[ $$ERROR_CURRENT_DIRECTORY                 ] = "ERROR_CURRENT_DIRECTORY"
	#OSERROR$[ $$ERROR_NOT_SAME_DEVICE                   ] = "ERROR_NOT_SAME_DEVICE"
	#OSERROR$[ $$ERROR_NO_MORE_FILES                     ] = "ERROR_NO_MORE_FILES"
	#OSERROR$[ $$ERROR_WRITE_PROTECT                     ] = "ERROR_WRITE_PROTECT"
	#OSERROR$[ $$ERROR_BAD_UNIT                          ] = "ERROR_BAD_UNIT"
	#OSERROR$[ $$ERROR_NOT_READY                         ] = "ERROR_NOT_READY"
	#OSERROR$[ $$ERROR_BAD_COMMAND                       ] = "ERROR_BAD_COMMAND"
	#OSERROR$[ $$ERROR_CRC                               ] = "ERROR_CRC"
	#OSERROR$[ $$ERROR_BAD_LENGTH                        ] = "ERROR_BAD_LENGTH"
	#OSERROR$[ $$ERROR_SEEK                              ] = "ERROR_SEEK"
	#OSERROR$[ $$ERROR_NOT_DOS_DISK                      ] = "ERROR_NOT_DOS_DISK"
	#OSERROR$[ $$ERROR_SECTOR_NOT_FOUND                  ] = "ERROR_SECTOR_NOT_FOUND"
	#OSERROR$[ $$ERROR_OUT_OF_PAPER                      ] = "ERROR_OUT_OF_PAPER"
	#OSERROR$[ $$ERROR_WRITE_FAULT                       ] = "ERROR_WRITE_FAULT"
	#OSERROR$[ $$ERROR_READ_FAULT                        ] = "ERROR_READ_FAULT"
	#OSERROR$[ $$ERROR_GEN_FAILURE                       ] = "ERROR_GEN_FAILURE"
	#OSERROR$[ $$ERROR_SHARING_VIOLATION                 ] = "ERROR_SHARING_VIOLATION"
	#OSERROR$[ $$ERROR_LOCK_VIOLATION                    ] = "ERROR_LOCK_VIOLATION"
	#OSERROR$[ $$ERROR_WRONG_DISK                        ] = "ERROR_WRONG_DISK"
	#OSERROR$[ $$ERROR_SHARING_BUFFER_EXCEEDED           ] = "ERROR_SHARING_BUFFER_EXCEEDED"
	#OSERROR$[ $$ERROR_HANDLE_EOF                        ] = "ERROR_HANDLE_EOF"
	#OSERROR$[ $$ERROR_HANDLE_DISK_FULL                  ] = "ERROR_HANDLE_DISK_FULL"
	#OSERROR$[ $$ERROR_NOT_SUPPORTED                     ] = "ERROR_NOT_SUPPORTED"
	#OSERROR$[ $$ERROR_REM_NOT_LIST                      ] = "ERROR_REM_NOT_LIST"
	#OSERROR$[ $$ERROR_DUP_NAME                          ] = "ERROR_DUP_NAME"
	#OSERROR$[ $$ERROR_BAD_NETPATH                       ] = "ERROR_BAD_NETPATH"
	#OSERROR$[ $$ERROR_NETWORK_BUSY                      ] = "ERROR_NETWORK_BUSY"
	#OSERROR$[ $$ERROR_DEV_NOT_EXIST                     ] = "ERROR_DEV_NOT_EXIST"
	#OSERROR$[ $$ERROR_TOO_MANY_CMDS                     ] = "ERROR_TOO_MANY_CMDS"
	#OSERROR$[ $$ERROR_ADAP_HDW_ERR                      ] = "ERROR_ADAP_HDW_ERR"
	#OSERROR$[ $$ERROR_BAD_NET_RESP                      ] = "ERROR_BAD_NET_RESP"
	#OSERROR$[ $$ERROR_UNEXP_NET_ERR                     ] = "ERROR_UNEXP_NET_ERR"
	#OSERROR$[ $$ERROR_BAD_REM_ADAP                      ] = "ERROR_BAD_REM_ADAP"
	#OSERROR$[ $$ERROR_PRINTQ_FULL                       ] = "ERROR_PRINTQ_FULL"
	#OSERROR$[ $$ERROR_NO_SPOOL_SPACE                    ] = "ERROR_NO_SPOOL_SPACE"
	#OSERROR$[ $$ERROR_PRINT_CANCELLED                   ] = "ERROR_PRINT_CANCELLED"
	#OSERROR$[ $$ERROR_NETNAME_DELETED                   ] = "ERROR_NETNAME_DELETED"
	#OSERROR$[ $$ERROR_NETWORK_ACCESS_DENIED             ] = "ERROR_NETWORK_ACCESS_DENIED"
	#OSERROR$[ $$ERROR_BAD_DEV_TYPE                      ] = "ERROR_BAD_DEV_TYPE"
	#OSERROR$[ $$ERROR_BAD_NET_NAME                      ] = "ERROR_BAD_NET_NAME"
	#OSERROR$[ $$ERROR_TOO_MANY_NAMES                    ] = "ERROR_TOO_MANY_NAMES"
	#OSERROR$[ $$ERROR_TOO_MANY_SESS                     ] = "ERROR_TOO_MANY_SESS"
	#OSERROR$[ $$ERROR_SHARING_PAUSED                    ] = "ERROR_SHARING_PAUSED"
	#OSERROR$[ $$ERROR_REQ_NOT_ACCEP                     ] = "ERROR_REQ_NOT_ACCEP"
	#OSERROR$[ $$ERROR_REDIR_PAUSED                      ] = "ERROR_REDIR_PAUSED"
	#OSERROR$[ $$ERROR_FILE_EXISTS                       ] = "ERROR_FILE_EXISTS"
	#OSERROR$[ $$ERROR_CANNOT_MAKE                       ] = "ERROR_CANNOT_MAKE"
	#OSERROR$[ $$ERROR_FAIL_I24                          ] = "ERROR_FAIL_I24"
	#OSERROR$[ $$ERROR_OUT_OF_STRUCTURES                 ] = "ERROR_OUT_OF_STRUCTURES"
	#OSERROR$[ $$ERROR_ALREADY_ASSIGNED                  ] = "ERROR_ALREADY_ASSIGNED"
	#OSERROR$[ $$ERROR_INVALID_PASSWORD                  ] = "ERROR_INVALID_PASSWORD"
	#OSERROR$[ $$ERROR_INVALID_PARAMETER                 ] = "ERROR_INVALID_PARAMETER"
	#OSERROR$[ $$ERROR_NET_WRITE_FAULT                   ] = "ERROR_NET_WRITE_FAULT"
	#OSERROR$[ $$ERROR_NO_PROC_SLOTS                     ] = "ERROR_NO_PROC_SLOTS"
	#OSERROR$[ $$ERROR_TOO_MANY_SEMAPHORES               ] = "ERROR_TOO_MANY_SEMAPHORES"
	#OSERROR$[ $$ERROR_EXCL_SEM_ALREADY_OWNED            ] = "ERROR_EXCL_SEM_ALREADY_OWNED"
	#OSERROR$[ $$ERROR_SEM_IS_SET                        ] = "ERROR_SEM_IS_SET"
	#OSERROR$[ $$ERROR_TOO_MANY_SEM_REQUESTS             ] = "ERROR_TOO_MANY_SEM_REQUESTS"
	#OSERROR$[ $$ERROR_INVALID_AT_INTERRUPT_TIME         ] = "ERROR_INVALID_AT_INTERRUPT_TIME"
	#OSERROR$[ $$ERROR_SEM_OWNER_DIED                    ] = "ERROR_SEM_OWNER_DIED"
	#OSERROR$[ $$ERROR_SEM_USER_LIMIT                    ] = "ERROR_SEM_USER_LIMIT"
	#OSERROR$[ $$ERROR_DISK_CHANGE                       ] = "ERROR_DISK_CHANGE"
	#OSERROR$[ $$ERROR_DRIVE_LOCKED                      ] = "ERROR_DRIVE_LOCKED"
	#OSERROR$[ $$ERROR_BROKEN_PIPE                       ] = "ERROR_BROKEN_PIPE"
	#OSERROR$[ $$ERROR_OPEN_FAILED                       ] = "ERROR_OPEN_FAILED"
	#OSERROR$[ $$ERROR_BUFFER_OVERFLOW                   ] = "ERROR_BUFFER_OVERFLOW"
	#OSERROR$[ $$ERROR_DISK_FULL                         ] = "ERROR_DISK_FULL"
	#OSERROR$[ $$ERROR_NO_MORE_SEARCH_HANDLES            ] = "ERROR_NO_MORE_SEARCH_HANDLES"
	#OSERROR$[ $$ERROR_INVALID_TARGET_HANDLE             ] = "ERROR_INVALID_TARGET_HANDLE"
	#OSERROR$[ $$ERROR_INVALID_CATEGORY                  ] = "ERROR_INVALID_CATEGORY"
	#OSERROR$[ $$ERROR_INVALID_VERIFY_SWITCH             ] = "ERROR_INVALID_VERIFY_SWITCH"
	#OSERROR$[ $$ERROR_BAD_DRIVER_LEVEL                  ] = "ERROR_BAD_DRIVER_LEVEL"
	#OSERROR$[ $$ERROR_CALL_NOT_IMPLEMENTED              ] = "ERROR_CALL_NOT_IMPLEMENTED"
	#OSERROR$[ $$ERROR_SEM_TIMEOUT                       ] = "ERROR_SEM_TIMEOUT"
	#OSERROR$[ $$ERROR_INSUFFICIENT_BUFFER               ] = "ERROR_INSUFFICIENT_BUFFER"
	#OSERROR$[ $$ERROR_INVALID_NAME                      ] = "ERROR_INVALID_NAME"
	#OSERROR$[ $$ERROR_INVALID_LEVEL                     ] = "ERROR_INVALID_LEVEL"
	#OSERROR$[ $$ERROR_NO_VOLUME_LABEL                   ] = "ERROR_NO_VOLUME_LABEL"
	#OSERROR$[ $$ERROR_MOD_NOT_FOUND                     ] = "ERROR_MOD_NOT_FOUND"
	#OSERROR$[ $$ERROR_PROC_NOT_FOUND                    ] = "ERROR_PROC_NOT_FOUND"
	#OSERROR$[ $$ERROR_WAIT_NO_CHILDREN                  ] = "ERROR_WAIT_NO_CHILDREN"
	#OSERROR$[ $$ERROR_CHILD_NOT_COMPLETE                ] = "ERROR_CHILD_NOT_COMPLETE"
	#OSERROR$[ $$ERROR_DIRECT_ACCESS_HANDLE              ] = "ERROR_DIRECT_ACCESS_HANDLE"
	#OSERROR$[ $$ERROR_NEGATIVE_SEEK                     ] = "ERROR_NEGATIVE_SEEK"
	#OSERROR$[ $$ERROR_SEEK_ON_DEVICE                    ] = "ERROR_SEEK_ON_DEVICE"
	#OSERROR$[ $$ERROR_IS_JOIN_TARGET                    ] = "ERROR_IS_JOIN_TARGET"
	#OSERROR$[ $$ERROR_IS_JOINED                         ] = "ERROR_IS_JOINED"
	#OSERROR$[ $$ERROR_IS_SUBSTED                        ] = "ERROR_IS_SUBSTED"
	#OSERROR$[ $$ERROR_NOT_JOINED                        ] = "ERROR_NOT_JOINED"
	#OSERROR$[ $$ERROR_NOT_SUBSTED                       ] = "ERROR_NOT_SUBSTED"
	#OSERROR$[ $$ERROR_JOIN_TO_JOIN                      ] = "ERROR_JOIN_TO_JOIN"
	#OSERROR$[ $$ERROR_SUBST_TO_SUBST                    ] = "ERROR_SUBST_TO_SUBST"
	#OSERROR$[ $$ERROR_JOIN_TO_SUBST                     ] = "ERROR_JOIN_TO_SUBST"
	#OSERROR$[ $$ERROR_SUBST_TO_JOIN                     ] = "ERROR_SUBST_TO_JOIN"
	#OSERROR$[ $$ERROR_BUSY_DRIVE                        ] = "ERROR_BUSY_DRIVE"
	#OSERROR$[ $$ERROR_SAME_DRIVE                        ] = "ERROR_SAME_DRIVE"
	#OSERROR$[ $$ERROR_DIR_NOT_ROOT                      ] = "ERROR_DIR_NOT_ROOT"
	#OSERROR$[ $$ERROR_DIR_NOT_EMPTY                     ] = "ERROR_DIR_NOT_EMPTY"
	#OSERROR$[ $$ERROR_IS_SUBST_PATH                     ] = "ERROR_IS_SUBST_PATH"
	#OSERROR$[ $$ERROR_IS_JOIN_PATH                      ] = "ERROR_IS_JOIN_PATH"
	#OSERROR$[ $$ERROR_PATH_BUSY                         ] = "ERROR_PATH_BUSY"
	#OSERROR$[ $$ERROR_IS_SUBST_TARGET                   ] = "ERROR_IS_SUBST_TARGET"
	#OSERROR$[ $$ERROR_SYSTEM_TRACE                      ] = "ERROR_SYSTEM_TRACE"
	#OSERROR$[ $$ERROR_INVALID_EVENT_COUNT               ] = "ERROR_INVALID_EVENT_COUNT"
	#OSERROR$[ $$ERROR_TOO_MANY_MUXWAITERS               ] = "ERROR_TOO_MANY_MUXWAITERS"
	#OSERROR$[ $$ERROR_INVALID_LIST_FORMAT               ] = "ERROR_INVALID_LIST_FORMAT"
	#OSERROR$[ $$ERROR_LABEL_TOO_LONG                    ] = "ERROR_LABEL_TOO_LONG"
	#OSERROR$[ $$ERROR_TOO_MANY_TCBS                     ] = "ERROR_TOO_MANY_TCBS"
	#OSERROR$[ $$ERROR_SIGNAL_REFUSED                    ] = "ERROR_SIGNAL_REFUSED"
	#OSERROR$[ $$ERROR_DISCARDED                         ] = "ERROR_DISCARDED"
	#OSERROR$[ $$ERROR_NOT_LOCKED                        ] = "ERROR_NOT_LOCKED"
	#OSERROR$[ $$ERROR_BAD_THREADID_ADDR                 ] = "ERROR_BAD_THREADID_ADDR"
	#OSERROR$[ $$ERROR_BAD_ARGUMENTS                     ] = "ERROR_BAD_ARGUMENTS"
	#OSERROR$[ $$ERROR_BAD_PATHNAME                      ] = "ERROR_BAD_PATHNAME"
	#OSERROR$[ $$ERROR_SIGNAL_PENDING                    ] = "ERROR_SIGNAL_PENDING"
	#OSERROR$[ $$ERROR_MAX_THRDS_REACHED                 ] = "ERROR_MAX_THRDS_REACHED"
	#OSERROR$[ $$ERROR_LOCK_FAILED                       ] = "ERROR_LOCK_FAILED"
	#OSERROR$[ $$ERROR_BUSY                              ] = "ERROR_BUSY"
	#OSERROR$[ $$ERROR_CANCEL_VIOLATION                  ] = "ERROR_CANCEL_VIOLATION"
	#OSERROR$[ $$ERROR_ATOMIC_LOCKS_NOT_SUPPORTED        ] = "ERROR_ATOMIC_LOCKS_NOT_SUPPORTED"
	#OSERROR$[ $$ERROR_INVALID_SEGMENT_NUMBER            ] = "ERROR_INVALID_SEGMENT_NUMBER"
	#OSERROR$[ $$ERROR_INVALID_ORDINAL                   ] = "ERROR_INVALID_ORDINAL"
	#OSERROR$[ $$ERROR_ALREADY_EXISTS                    ] = "ERROR_ALREADY_EXISTS"
	#OSERROR$[ $$ERROR_INVALID_FLAG_NUMBER               ] = "ERROR_INVALID_FLAG_NUMBER"
	#OSERROR$[ $$ERROR_SEM_NOT_FOUND                     ] = "ERROR_SEM_NOT_FOUND"
	#OSERROR$[ $$ERROR_INVALID_STARTING_CODESEG          ] = "ERROR_INVALID_STARTING_CODESEG"
	#OSERROR$[ $$ERROR_INVALID_STACKSEG                  ] = "ERROR_INVALID_STACKSEG"
	#OSERROR$[ $$ERROR_INVALID_MODULETYPE                ] = "ERROR_INVALID_MODULETYPE"
	#OSERROR$[ $$ERROR_INVALID_EXE_SIGNATURE             ] = "ERROR_INVALID_EXE_SIGNATURE"
	#OSERROR$[ $$ERROR_EXE_MARKED_INVALID                ] = "ERROR_EXE_MARKED_INVALID"
	#OSERROR$[ $$ERROR_BAD_EXE_FORMAT                    ] = "ERROR_BAD_EXE_FORMAT"
	#OSERROR$[ $$ERROR_ITERATED_DATA_EXCEEDS_64k         ] = "ERROR_ITERATED_DATA_EXCEEDS_64k"
	#OSERROR$[ $$ERROR_INVALID_MINALLOCSIZE              ] = "ERROR_INVALID_MINALLOCSIZE"
	#OSERROR$[ $$ERROR_DYNLINK_FROM_INVALID_RING         ] = "ERROR_DYNLINK_FROM_INVALID_RING"
	#OSERROR$[ $$ERROR_IOPL_NOT_ENABLED                  ] = "ERROR_IOPL_NOT_ENABLED"
	#OSERROR$[ $$ERROR_INVALID_SEGDPL                    ] = "ERROR_INVALID_SEGDPL"
	#OSERROR$[ $$ERROR_AUTODATASEG_EXCEEDS_64k           ] = "ERROR_AUTODATASEG_EXCEEDS_64k"
	#OSERROR$[ $$ERROR_RING2SEG_MUST_BE_MOVABLE          ] = "ERROR_RING2SEG_MUST_BE_MOVABLE"
	#OSERROR$[ $$ERROR_RELOC_CHAIN_XEEDS_SEGLIM          ] = "ERROR_RELOC_CHAIN_XEEDS_SEGLIM"
	#OSERROR$[ $$ERROR_INFLOOP_IN_RELOC_CHAIN            ] = "ERROR_INFLOOP_IN_RELOC_CHAIN"
	#OSERROR$[ $$ERROR_ENVVAR_NOT_FOUND                  ] = "ERROR_ENVVAR_NOT_FOUND"
	#OSERROR$[ $$ERROR_NO_SIGNAL_SENT                    ] = "ERROR_NO_SIGNAL_SENT"
	#OSERROR$[ $$ERROR_FILENAME_EXCED_RANGE              ] = "ERROR_FILENAME_EXCED_RANGE"
	#OSERROR$[ $$ERROR_RING2_STACK_IN_USE                ] = "ERROR_RING2_STACK_IN_USE"
	#OSERROR$[ $$ERROR_META_EXPANSION_TOO_LONG           ] = "ERROR_META_EXPANSION_TOO_LONG"
	#OSERROR$[ $$ERROR_INVALID_SIGNAL_NUMBER             ] = "ERROR_INVALID_SIGNAL_NUMBER"
	#OSERROR$[ $$ERROR_THREAD_1_INACTIVE                 ] = "ERROR_THREAD_1_INACTIVE"
	#OSERROR$[ $$ERROR_LOCKED                            ] = "ERROR_LOCKED"
	#OSERROR$[ $$ERROR_TOO_MANY_MODULES                  ] = "ERROR_TOO_MANY_MODULES"
	#OSERROR$[ $$ERROR_NESTING_NOT_ALLOWED               ] = "ERROR_NESTING_NOT_ALLOWED"
	#OSERROR$[ $$ERROR_BAD_PIPE                          ] = "ERROR_BAD_PIPE"
	#OSERROR$[ $$ERROR_PIPE_BUSY                         ] = "ERROR_PIPE_BUSY"
	#OSERROR$[ $$ERROR_NO_DATA                           ] = "ERROR_NO_DATA"
	#OSERROR$[ $$ERROR_PIPE_NOT_CONNECTED                ] = "ERROR_PIPE_NOT_CONNECTED"
	#OSERROR$[ $$ERROR_MORE_DATA                         ] = "ERROR_MORE_DATA"
	#OSERROR$[ $$ERROR_VC_DISCONNECTED                   ] = "ERROR_VC_DISCONNECTED"
	#OSERROR$[ $$ERROR_INVALID_EA_NAME                   ] = "ERROR_INVALID_EA_NAME"
	#OSERROR$[ $$ERROR_EA_LIST_INCONSISTENT              ] = "ERROR_EA_LIST_INCONSISTENT"
	#OSERROR$[ $$ERROR_NO_MORE_ITEMS                     ] = "ERROR_NO_MORE_ITEMS"
	#OSERROR$[ $$ERROR_CANNOT_COPY                       ] = "ERROR_CANNOT_COPY"
	#OSERROR$[ $$ERROR_DIRECTORY                         ] = "ERROR_DIRECTORY"
	#OSERROR$[ $$ERROR_EAS_DIDNT_FIT                     ] = "ERROR_EAS_DIDNT_FIT"
	#OSERROR$[ $$ERROR_EA_FILE_CORRUPT                   ] = "ERROR_EA_FILE_CORRUPT"
	#OSERROR$[ $$ERROR_EA_TABLE_FULL                     ] = "ERROR_EA_TABLE_FULL"
	#OSERROR$[ $$ERROR_INVALID_EA_HANDLE                 ] = "ERROR_INVALID_EA_HANDLE"
	#OSERROR$[ $$ERROR_EAS_NOT_SUPPORTED                 ] = "ERROR_EAS_NOT_SUPPORTED"
	#OSERROR$[ $$ERROR_NOT_OWNER                         ] = "ERROR_NOT_OWNER"
	#OSERROR$[ $$ERROR_TOO_MANY_POSTS                    ] = "ERROR_TOO_MANY_POSTS"
	#OSERROR$[ $$ERROR_MR_MID_NOT_FOUND                  ] = "ERROR_MR_MID_NOT_FOUND"
	#OSERROR$[ $$ERROR_INVALID_ADDRESS                   ] = "ERROR_INVALID_ADDRESS"
	#OSERROR$[ $$ERROR_ARITHMETIC_OVERFLOW               ] = "ERROR_ARITHMETIC_OVERFLOW"
	#OSERROR$[ $$ERROR_PIPE_CONNECTED                    ] = "ERROR_PIPE_CONNECTED"
	#OSERROR$[ $$ERROR_PIPE_LISTENING                    ] = "ERROR_PIPE_LISTENING"
	#OSERROR$[ $$ERROR_EA_ACCESS_DENIED                  ] = "ERROR_EA_ACCESS_DENIED"
	#OSERROR$[ $$ERROR_OPERATION_ABORTED                 ] = "ERROR_OPERATION_ABORTED"
	#OSERROR$[ $$ERROR_IO_INCOMPLETE                     ] = "ERROR_IO_INCOMPLETE"
	#OSERROR$[ $$ERROR_IO_PENDING                        ] = "ERROR_IO_PENDING"
	#OSERROR$[ $$ERROR_NOACCESS                          ] = "ERROR_NOACCESS"
	#OSERROR$[ $$ERROR_SWAPERROR                         ] = "ERROR_SWAPERROR"
	#OSERROR$[ $$ERROR_STACK_OVERFLOW                    ] = "ERROR_STACK_OVERFLOW"
	#OSERROR$[ $$ERROR_INVALID_MESSAGE                   ] = "ERROR_INVALID_MESSAGE"
	#OSERROR$[ $$ERROR_CAN_NOT_COMPLETE                  ] = "ERROR_CAN_NOT_COMPLETE"
	#OSERROR$[ $$ERROR_INVALID_FLAGS                     ] = "ERROR_INVALID_FLAGS"
	#OSERROR$[ $$ERROR_UNRECOGNIZED_VOLUME               ] = "ERROR_UNRECOGNIZED_VOLUME"
	#OSERROR$[ $$ERROR_FILE_INVALID                      ] = "ERROR_FILE_INVALID"
	#OSERROR$[ $$ERROR_FULLSCREEN_MODE                   ] = "ERROR_FULLSCREEN_MODE"
	#OSERROR$[ $$ERROR_NO_TOKEN                          ] = "ERROR_NO_TOKEN"
	#OSERROR$[ $$ERROR_BADDB                             ] = "ERROR_BADDB"
	#OSERROR$[ $$ERROR_BADKEY                            ] = "ERROR_BADKEY"
	#OSERROR$[ $$ERROR_CANTOPEN                          ] = "ERROR_CANTOPEN"
	#OSERROR$[ $$ERROR_CANTREAD                          ] = "ERROR_CANTREAD"
	#OSERROR$[ $$ERROR_CANTWRITE                         ] = "ERROR_CANTWRITE"
	#OSERROR$[ $$ERROR_REGISTRY_RECOVERED                ] = "ERROR_REGISTRY_RECOVERED"
	#OSERROR$[ $$ERROR_REGISTRY_CORRUPT                  ] = "ERROR_REGISTRY_CORRUPT"
	#OSERROR$[ $$ERROR_REGISTRY_IO_FAILED                ] = "ERROR_REGISTRY_IO_FAILED"
	#OSERROR$[ $$ERROR_NOT_REGISTRY_FILE                 ] = "ERROR_NOT_REGISTRY_FILE"
	#OSERROR$[ $$ERROR_KEY_DELETED                       ] = "ERROR_KEY_DELETED"
	#OSERROR$[ $$ERROR_NO_LOG_SPACE                      ] = "ERROR_NO_LOG_SPACE"
	#OSERROR$[ $$ERROR_KEY_HAS_CHILDREN                  ] = "ERROR_KEY_HAS_CHILDREN"
	#OSERROR$[ $$ERROR_CHILD_MUST_BE_VOLATILE            ] = "ERROR_CHILD_MUST_BE_VOLATILE"
	#OSERROR$[ $$ERROR_NOTIFY_ENUM_DIR                   ] = "ERROR_NOTIFY_ENUM_DIR"
	#OSERROR$[ $$ERROR_DEPENDENT_SERVICES_RUNNING        ] = "ERROR_DEPENDENT_SERVICES_RUNNING"
	#OSERROR$[ $$ERROR_INVALID_SERVICE_CONTROL           ] = "ERROR_INVALID_SERVICE_CONTROL"
	#OSERROR$[ $$ERROR_SERVICE_REQUEST_TIMEOUT           ] = "ERROR_SERVICE_REQUEST_TIMEOUT"
	#OSERROR$[ $$ERROR_SERVICE_NO_THREAD                 ] = "ERROR_SERVICE_NO_THREAD"
	#OSERROR$[ $$ERROR_SERVICE_DATABASE_LOCKED           ] = "ERROR_SERVICE_DATABASE_LOCKED"
	#OSERROR$[ $$ERROR_SERVICE_ALREADY_RUNNING           ] = "ERROR_SERVICE_ALREADY_RUNNING"
	#OSERROR$[ $$ERROR_INVALID_SERVICE_ACCOUNT           ] = "ERROR_INVALID_SERVICE_ACCOUNT"
	#OSERROR$[ $$ERROR_SERVICE_DISABLED                  ] = "ERROR_SERVICE_DISABLED"
	#OSERROR$[ $$ERROR_CIRCULAR_DEPENDENCY               ] = "ERROR_CIRCULAR_DEPENDENCY"
	#OSERROR$[ $$ERROR_SERVICE_DOES_NOT_EXIST            ] = "ERROR_SERVICE_DOES_NOT_EXIST"
	#OSERROR$[ $$ERROR_SERVICE_CANNOT_ACCEPT_CTRL        ] = "ERROR_SERVICE_CANNOT_ACCEPT_CTRL"
	#OSERROR$[ $$ERROR_SERVICE_NOT_ACTIVE                ] = "ERROR_SERVICE_NOT_ACTIVE"
	#OSERROR$[ $$ERROR_FAILED_SERVICE_CONTROLLER_CONNECT ] = "ERROR_FAILED_SERVICE_CONTROLLER_CONNECT"
	#OSERROR$[ $$ERROR_EXCEPTION_IN_SERVICE              ] = "ERROR_EXCEPTION_IN_SERVICE"
	#OSERROR$[ $$ERROR_DATABASE_DOES_NOT_EXIST           ] = "ERROR_DATABASE_DOES_NOT_EXIST"
	#OSERROR$[ $$ERROR_SERVICE_SPECIFIC_ERROR            ] = "ERROR_SERVICE_SPECIFIC_ERROR"
	#OSERROR$[ $$ERROR_PROCESS_ABORTED                   ] = "ERROR_PROCESS_ABORTED"
	#OSERROR$[ $$ERROR_SERVICE_DEPENDENCY_FAIL           ] = "ERROR_SERVICE_DEPENDENCY_FAIL"
	#OSERROR$[ $$ERROR_SERVICE_LOGON_FAILED              ] = "ERROR_SERVICE_LOGON_FAILED"
	#OSERROR$[ $$ERROR_SERVICE_START_HANG                ] = "ERROR_SERVICE_START_HANG"
	#OSERROR$[ $$ERROR_INVALID_SERVICE_LOCK              ] = "ERROR_INVALID_SERVICE_LOCK"
	#OSERROR$[ $$ERROR_SERVICE_MARKED_FOR_DELETE         ] = "ERROR_SERVICE_MARKED_FOR_DELETE"
	#OSERROR$[ $$ERROR_SERVICE_EXISTS                    ] = "ERROR_SERVICE_EXISTS"
	#OSERROR$[ $$ERROR_ALREADY_RUNNING_LKG               ] = "ERROR_ALREADY_RUNNING_LKG"
	#OSERROR$[ $$ERROR_SERVICE_DEPENDENCY_DELETED        ] = "ERROR_SERVICE_DEPENDENCY_DELETED"
	#OSERROR$[ $$ERROR_BOOT_ALREADY_ACCEPTED             ] = "ERROR_BOOT_ALREADY_ACCEPTED"
	#OSERROR$[ $$ERROR_SERVICE_NEVER_STARTED             ] = "ERROR_SERVICE_NEVER_STARTED"
	#OSERROR$[ $$ERROR_DUPLICATE_SERVICE_NAME            ] = "ERROR_DUPLICATE_SERVICE_NAME"
	#OSERROR$[ $$ERROR_END_OF_MEDIA                      ] = "ERROR_END_OF_MEDIA"
	#OSERROR$[ $$ERROR_FILEMARK_DETECTED                 ] = "ERROR_FILEMARK_DETECTED"
	#OSERROR$[ $$ERROR_BEGINNING_OF_MEDIA                ] = "ERROR_BEGINNING_OF_MEDIA"
	#OSERROR$[ $$ERROR_SETMARK_DETECTED                  ] = "ERROR_SETMARK_DETECTED"
	#OSERROR$[ $$ERROR_NO_DATA_DETECTED                  ] = "ERROR_NO_DATA_DETECTED"
	#OSERROR$[ $$ERROR_PARTITION_FAILURE                 ] = "ERROR_PARTITION_FAILURE"
	#OSERROR$[ $$ERROR_INVALID_BLOCK_LENGTH              ] = "ERROR_INVALID_BLOCK_LENGTH"
	#OSERROR$[ $$ERROR_DEVICE_NOT_PARTITIONED            ] = "ERROR_DEVICE_NOT_PARTITIONED"
	#OSERROR$[ $$ERROR_UNABLE_TO_LOCK_MEDIA              ] = "ERROR_UNABLE_TO_LOCK_MEDIA"
	#OSERROR$[ $$ERROR_UNABLE_TO_UNLOAD_MEDIA            ] = "ERROR_UNABLE_TO_UNLOAD_MEDIA"
	#OSERROR$[ $$ERROR_MEDIA_CHANGED                     ] = "ERROR_MEDIA_CHANGED"
	#OSERROR$[ $$ERROR_BUS_RESET                         ] = "ERROR_BUS_RESET"
	#OSERROR$[ $$ERROR_NO_MEDIA_IN_DRIVE                 ] = "ERROR_NO_MEDIA_IN_DRIVE"
	#OSERROR$[ $$ERROR_NO_UNICODE_TRANSLATION            ] = "ERROR_NO_UNICODE_TRANSLATION"
	#OSERROR$[ $$ERROR_DLL_INIT_FAILED                   ] = "ERROR_DLL_INIT_FAILED"
	#OSERROR$[ $$ERROR_SHUTDOWN_IN_PROGRESS              ] = "ERROR_SHUTDOWN_IN_PROGRESS"
	#OSERROR$[ $$ERROR_NO_SHUTDOWN_IN_PROGRESS           ] = "ERROR_NO_SHUTDOWN_IN_PROGRESS"
	#OSERROR$[ $$ERROR_IO_DEVICE                         ] = "ERROR_IO_DEVICE"
	#OSERROR$[ $$ERROR_SERIAL_NO_DEVICE                  ] = "ERROR_SERIAL_NO_DEVICE"
	#OSERROR$[ $$ERROR_IRQ_BUSY                          ] = "ERROR_IRQ_BUSY"
	#OSERROR$[ $$ERROR_MORE_WRITES                       ] = "ERROR_MORE_WRITES"
	#OSERROR$[ $$ERROR_COUNTER_TIMEOUT                   ] = "ERROR_COUNTER_TIMEOUT"
	#OSERROR$[ $$ERROR_FLOPPY_ID_MARK_NOT_FOUND          ] = "ERROR_FLOPPY_ID_MARK_NOT_FOUND"
	#OSERROR$[ $$ERROR_FLOPPY_WRONG_CYLINDER             ] = "ERROR_FLOPPY_WRONG_CYLINDER"
	#OSERROR$[ $$ERROR_FLOPPY_UNKNOWN_ERROR              ] = "ERROR_FLOPPY_UNKNOWN_ERROR"
	#OSERROR$[ $$ERROR_FLOPPY_BAD_REGISTERS              ] = "ERROR_FLOPPY_BAD_REGISTERS"
	#OSERROR$[ $$ERROR_DISK_RECALIBRATE_FAILED           ] = "ERROR_DISK_RECALIBRATE_FAILED"
	#OSERROR$[ $$ERROR_DISK_OPERATION_FAILED             ] = "ERROR_DISK_OPERATION_FAILED"
	#OSERROR$[ $$ERROR_DISK_RESET_FAILED                 ] = "ERROR_DISK_RESET_FAILED"
	#OSERROR$[ $$ERROR_EOM_OVERFLOW                      ] = "ERROR_EOM_OVERFLOW"
	#OSERROR$[ $$ERROR_NOT_ENOUGH_SERVER_MEMORY          ] = "ERROR_NOT_ENOUGH_SERVER_MEMORY"
	#OSERROR$[ $$ERROR_POSSIBLE_DEADLOCK                 ] = "ERROR_POSSIBLE_DEADLOCK"
	#OSERROR$[ $$ERROR_MAPPED_ALIGNMENT                  ] = "ERROR_MAPPED_ALIGNMENT"
	#OSERROR$[ $$ERROR_BAD_USERNAME                      ] = "ERROR_BAD_USERNAME"
	#OSERROR$[ $$ERROR_NOT_CONNECTED                     ] = "ERROR_NOT_CONNECTED"
	#OSERROR$[ $$ERROR_OPEN_FILES                        ] = "ERROR_OPEN_FILES"
	#OSERROR$[ $$ERROR_DEVICE_IN_USE                     ] = "ERROR_DEVICE_IN_USE"
	#OSERROR$[ $$ERROR_BAD_DEVICE                        ] = "ERROR_BAD_DEVICE"
	#OSERROR$[ $$ERROR_CONNECTION_UNAVAIL                ] = "ERROR_CONNECTION_UNAVAIL"
	#OSERROR$[ $$ERROR_DEVICE_ALREADY_REMEMBERED         ] = "ERROR_DEVICE_ALREADY_REMEMBERED"
	#OSERROR$[ $$ERROR_NO_NET_OR_BAD_PATH                ] = "ERROR_NO_NET_OR_BAD_PATH"
	#OSERROR$[ $$ERROR_BAD_PROVIDER                      ] = "ERROR_BAD_PROVIDER"
	#OSERROR$[ $$ERROR_CANNOT_OPEN_PROFILE               ] = "ERROR_CANNOT_OPEN_PROFILE"
	#OSERROR$[ $$ERROR_BAD_PROFILE                       ] = "ERROR_BAD_PROFILE"
	#OSERROR$[ $$ERROR_NOT_CONTAINER                     ] = "ERROR_NOT_CONTAINER"
	#OSERROR$[ $$ERROR_EXTENDED_ERROR                    ] = "ERROR_EXTENDED_ERROR"
	#OSERROR$[ $$ERROR_INVALID_GROUPNAME                 ] = "ERROR_INVALID_GROUPNAME"
	#OSERROR$[ $$ERROR_INVALID_COMPUTERNAME              ] = "ERROR_INVALID_COMPUTERNAME"
	#OSERROR$[ $$ERROR_INVALID_EVENTNAME                 ] = "ERROR_INVALID_EVENTNAME"
	#OSERROR$[ $$ERROR_INVALID_DOMAINNAME                ] = "ERROR_INVALID_DOMAINNAME"
	#OSERROR$[ $$ERROR_INVALID_SERVICENAME               ] = "ERROR_INVALID_SERVICENAME"
	#OSERROR$[ $$ERROR_INVALID_NETNAME                   ] = "ERROR_INVALID_NETNAME"
	#OSERROR$[ $$ERROR_INVALID_SHARENAME                 ] = "ERROR_INVALID_SHARENAME"
	#OSERROR$[ $$ERROR_INVALID_PASSWORDNAME              ] = "ERROR_INVALID_PASSWORDNAME"
	#OSERROR$[ $$ERROR_INVALID_MESSAGENAME               ] = "ERROR_INVALID_MESSAGENAME"
	#OSERROR$[ $$ERROR_INVALID_MESSAGEDEST               ] = "ERROR_INVALID_MESSAGEDEST"
	#OSERROR$[ $$ERROR_SESSION_CREDENTIAL_CONFLICT       ] = "ERROR_SESSION_CREDENTIAL_CONFLICT"
	#OSERROR$[ $$ERROR_REMOTE_SESSION_LIMIT_EXCEEDED     ] = "ERROR_REMOTE_SESSION_LIMIT_EXCEEDED"
	#OSERROR$[ $$ERROR_DUP_DOMAINNAME                    ] = "ERROR_DUP_DOMAINNAME"
	#OSERROR$[ $$ERROR_NO_NETWORK                        ] = "ERROR_NO_NETWORK"
	#OSERROR$[ $$ERROR_NOT_ALL_ASSIGNED                  ] = "ERROR_NOT_ALL_ASSIGNED"
	#OSERROR$[ $$ERROR_SOME_NOT_MAPPED                   ] = "ERROR_SOME_NOT_MAPPED"
	#OSERROR$[ $$ERROR_NO_QUOTAS_FOR_ACCOUNT             ] = "ERROR_NO_QUOTAS_FOR_ACCOUNT"
	#OSERROR$[ $$ERROR_LOCAL_USER_SESSION_KEY            ] = "ERROR_LOCAL_USER_SESSION_KEY"
	#OSERROR$[ $$ERROR_NULL_LM_PASSWORD                  ] = "ERROR_NULL_LM_PASSWORD"
	#OSERROR$[ $$ERROR_UNKNOWN_REVISION                  ] = "ERROR_UNKNOWN_REVISION"
	#OSERROR$[ $$ERROR_REVISION_MISMATCH                 ] = "ERROR_REVISION_MISMATCH"
	#OSERROR$[ $$ERROR_INVALID_OWNER                     ] = "ERROR_INVALID_OWNER"
	#OSERROR$[ $$ERROR_INVALID_PRIMARY_GROUP             ] = "ERROR_INVALID_PRIMARY_GROUP"
	#OSERROR$[ $$ERROR_NO_IMPERSONATION_TOKEN            ] = "ERROR_NO_IMPERSONATION_TOKEN"
	#OSERROR$[ $$ERROR_CANT_DISABLE_MANDATORY            ] = "ERROR_CANT_DISABLE_MANDATORY"
	#OSERROR$[ $$ERROR_NO_LOGON_SERVERS                  ] = "ERROR_NO_LOGON_SERVERS"
	#OSERROR$[ $$ERROR_NO_SUCH_LOGON_SESSION             ] = "ERROR_NO_SUCH_LOGON_SESSION"
	#OSERROR$[ $$ERROR_NO_SUCH_PRIVILEGE                 ] = "ERROR_NO_SUCH_PRIVILEGE"
	#OSERROR$[ $$ERROR_PRIVILEGE_NOT_HELD                ] = "ERROR_PRIVILEGE_NOT_HELD"
	#OSERROR$[ $$ERROR_INVALID_ACCOUNT_NAME              ] = "ERROR_INVALID_ACCOUNT_NAME"
	#OSERROR$[ $$ERROR_USER_EXISTS                       ] = "ERROR_USER_EXISTS"
	#OSERROR$[ $$ERROR_NO_SUCH_USER                      ] = "ERROR_NO_SUCH_USER"
	#OSERROR$[ $$ERROR_GROUP_EXISTS                      ] = "ERROR_GROUP_EXISTS"
	#OSERROR$[ $$ERROR_NO_SUCH_GROUP                     ] = "ERROR_NO_SUCH_GROUP"
	#OSERROR$[ $$ERROR_MEMBER_IN_GROUP                   ] = "ERROR_MEMBER_IN_GROUP"
	#OSERROR$[ $$ERROR_MEMBER_NOT_IN_GROUP               ] = "ERROR_MEMBER_NOT_IN_GROUP"
	#OSERROR$[ $$ERROR_LAST_ADMIN                        ] = "ERROR_LAST_ADMIN"
	#OSERROR$[ $$ERROR_WRONG_PASSWORD                    ] = "ERROR_WRONG_PASSWORD"
	#OSERROR$[ $$ERROR_ILL_FORMED_PASSWORD               ] = "ERROR_ILL_FORMED_PASSWORD"
	#OSERROR$[ $$ERROR_PASSWORD_RESTRICTION              ] = "ERROR_PASSWORD_RESTRICTION"
	#OSERROR$[ $$ERROR_LOGON_FAILURE                     ] = "ERROR_LOGON_FAILURE"
	#OSERROR$[ $$ERROR_ACCOUNT_RESTRICTION               ] = "ERROR_ACCOUNT_RESTRICTION"
	#OSERROR$[ $$ERROR_INVALID_LOGON_HOURS               ] = "ERROR_INVALID_LOGON_HOURS"
	#OSERROR$[ $$ERROR_INVALID_WORKSTATION               ] = "ERROR_INVALID_WORKSTATION"
	#OSERROR$[ $$ERROR_PASSWORD_EXPIRED                  ] = "ERROR_PASSWORD_EXPIRED"
	#OSERROR$[ $$ERROR_ACCOUNT_DISABLED                  ] = "ERROR_ACCOUNT_DISABLED"
	#OSERROR$[ $$ERROR_NONE_MAPPED                       ] = "ERROR_NONE_MAPPED"
	#OSERROR$[ $$ERROR_TOO_MANY_LUIDS_REQUESTED          ] = "ERROR_TOO_MANY_LUIDS_REQUESTED"
	#OSERROR$[ $$ERROR_LUIDS_EXHAUSTED                   ] = "ERROR_LUIDS_EXHAUSTED"
	#OSERROR$[ $$ERROR_INVALID_SUB_AUTHORITY             ] = "ERROR_INVALID_SUB_AUTHORITY"
	#OSERROR$[ $$ERROR_INVALID_ACL                       ] = "ERROR_INVALID_ACL"
	#OSERROR$[ $$ERROR_INVALID_SID                       ] = "ERROR_INVALID_SID"
	#OSERROR$[ $$ERROR_INVALID_SECURITY_DESCR            ] = "ERROR_INVALID_SECURITY_DESCR"
	#OSERROR$[ $$ERROR_BAD_INHERITANCE_ACL               ] = "ERROR_BAD_INHERITANCE_ACL"
	#OSERROR$[ $$ERROR_SERVER_DISABLED                   ] = "ERROR_SERVER_DISABLED"
	#OSERROR$[ $$ERROR_SERVER_NOT_DISABLED               ] = "ERROR_SERVER_NOT_DISABLED"
	#OSERROR$[ $$ERROR_INVALID_ID_AUTHORITY              ] = "ERROR_INVALID_ID_AUTHORITY"
	#OSERROR$[ $$ERROR_ALLOTTED_SPACE_EXCEEDED           ] = "ERROR_ALLOTTED_SPACE_EXCEEDED"
	#OSERROR$[ $$ERROR_INVALID_GROUP_ATTRIBUTES          ] = "ERROR_INVALID_GROUP_ATTRIBUTES"
	#OSERROR$[ $$ERROR_BAD_IMPERSONATION_LEVEL           ] = "ERROR_BAD_IMPERSONATION_LEVEL"
	#OSERROR$[ $$ERROR_CANT_OPEN_ANONYMOUS               ] = "ERROR_CANT_OPEN_ANONYMOUS"
	#OSERROR$[ $$ERROR_BAD_VALIDATION_CLASS              ] = "ERROR_BAD_VALIDATION_CLASS"
	#OSERROR$[ $$ERROR_BAD_TOKEN_TYPE                    ] = "ERROR_BAD_TOKEN_TYPE"
	#OSERROR$[ $$ERROR_NO_SECURITY_ON_OBJECT             ] = "ERROR_NO_SECURITY_ON_OBJECT"
	#OSERROR$[ $$ERROR_CANT_ACCESS_DOMAIN_INFO           ] = "ERROR_CANT_ACCESS_DOMAIN_INFO"
	#OSERROR$[ $$ERROR_INVALID_SERVER_STATE              ] = "ERROR_INVALID_SERVER_STATE"
	#OSERROR$[ $$ERROR_INVALID_DOMAIN_STATE              ] = "ERROR_INVALID_DOMAIN_STATE"
	#OSERROR$[ $$ERROR_INVALID_DOMAIN_ROLE               ] = "ERROR_INVALID_DOMAIN_ROLE"
	#OSERROR$[ $$ERROR_NO_SUCH_DOMAIN                    ] = "ERROR_NO_SUCH_DOMAIN"
	#OSERROR$[ $$ERROR_DOMAIN_EXISTS                     ] = "ERROR_DOMAIN_EXISTS"
	#OSERROR$[ $$ERROR_DOMAIN_LIMIT_EXCEEDED             ] = "ERROR_DOMAIN_LIMIT_EXCEEDED"
	#OSERROR$[ $$ERROR_INTERNAL_DB_CORRUPTION            ] = "ERROR_INTERNAL_DB_CORRUPTION"
	#OSERROR$[ $$ERROR_INTERNAL_ERROR                    ] = "ERROR_INTERNAL_ERROR"
	#OSERROR$[ $$ERROR_GENERIC_NOT_MAPPED                ] = "ERROR_GENERIC_NOT_MAPPED"
	#OSERROR$[ $$ERROR_BAD_DESCRIPTOR_FORMAT             ] = "ERROR_BAD_DESCRIPTOR_FORMAT"
	#OSERROR$[ $$ERROR_NOT_LOGON_PROCESS                 ] = "ERROR_NOT_LOGON_PROCESS"
	#OSERROR$[ $$ERROR_LOGON_SESSION_EXISTS              ] = "ERROR_LOGON_SESSION_EXISTS"
	#OSERROR$[ $$ERROR_NO_SUCH_PACKAGE                   ] = "ERROR_NO_SUCH_PACKAGE"
	#OSERROR$[ $$ERROR_BAD_LOGON_SESSION_STATE           ] = "ERROR_BAD_LOGON_SESSION_STATE"
	#OSERROR$[ $$ERROR_LOGON_SESSION_COLLISION           ] = "ERROR_LOGON_SESSION_COLLISION"
	#OSERROR$[ $$ERROR_INVALID_LOGON_TYPE                ] = "ERROR_INVALID_LOGON_TYPE"
	#OSERROR$[ $$ERROR_CANNOT_IMPERSONATE                ] = "ERROR_CANNOT_IMPERSONATE"
	#OSERROR$[ $$ERROR_RXACT_INVALID_STATE               ] = "ERROR_RXACT_INVALID_STATE"
	#OSERROR$[ $$ERROR_RXACT_COMMIT_FAILURE              ] = "ERROR_RXACT_COMMIT_FAILURE"
	#OSERROR$[ $$ERROR_SPECIAL_ACCOUNT                   ] = "ERROR_SPECIAL_ACCOUNT"
	#OSERROR$[ $$ERROR_SPECIAL_GROUP                     ] = "ERROR_SPECIAL_GROUP"
	#OSERROR$[ $$ERROR_SPECIAL_USER                      ] = "ERROR_SPECIAL_USER"
	#OSERROR$[ $$ERROR_MEMBERS_PRIMARY_GROUP             ] = "ERROR_MEMBERS_PRIMARY_GROUP"
	#OSERROR$[ $$ERROR_TOKEN_ALREADY_IN_USE              ] = "ERROR_TOKEN_ALREADY_IN_USE"
	#OSERROR$[ $$ERROR_NO_SUCH_ALIAS                     ] = "ERROR_NO_SUCH_ALIAS"
	#OSERROR$[ $$ERROR_MEMBER_NOT_IN_ALIAS               ] = "ERROR_MEMBER_NOT_IN_ALIAS"
	#OSERROR$[ $$ERROR_MEMBER_IN_ALIAS                   ] = "ERROR_MEMBER_IN_ALIAS"
	#OSERROR$[ $$ERROR_ALIAS_EXISTS                      ] = "ERROR_ALIAS_EXISTS"
	#OSERROR$[ $$ERROR_LOGON_NOT_GRANTED                 ] = "ERROR_LOGON_NOT_GRANTED"
	#OSERROR$[ $$ERROR_TOO_MANY_SECRETS                  ] = "ERROR_TOO_MANY_SECRETS"
	#OSERROR$[ $$ERROR_SECRET_TOO_LONG                   ] = "ERROR_SECRET_TOO_LONG"
	#OSERROR$[ $$ERROR_INTERNAL_DB_ERROR                 ] = "ERROR_INTERNAL_DB_ERROR"
	#OSERROR$[ $$ERROR_TOO_MANY_CONTEXT_IDS              ] = "ERROR_TOO_MANY_CONTEXT_IDS"
	#OSERROR$[ $$ERROR_LOGON_TYPE_NOT_GRANTED            ] = "ERROR_LOGON_TYPE_NOT_GRANTED"
	#OSERROR$[ $$ERROR_NT_CROSS_ENCRYPTION_REQUIRED      ] = "ERROR_NT_CROSS_ENCRYPTION_REQUIRED"
	#OSERROR$[ $$ERROR_NO_SUCH_MEMBER                    ] = "ERROR_NO_SUCH_MEMBER"
	#OSERROR$[ $$ERROR_INVALID_MEMBER                    ] = "ERROR_INVALID_MEMBER"
	#OSERROR$[ $$ERROR_TOO_MANY_SIDS                     ] = "ERROR_TOO_MANY_SIDS"
	#OSERROR$[ $$ERROR_LM_CROSS_ENCRYPTION_REQUIRED      ] = "ERROR_LM_CROSS_ENCRYPTION_REQUIRED"
	#OSERROR$[ $$ERROR_NO_INHERITANCE                    ] = "ERROR_NO_INHERITANCE"
	#OSERROR$[ $$ERROR_FILE_CORRUPT                      ] = "ERROR_FILE_CORRUPT"
	#OSERROR$[ $$ERROR_DISK_CORRUPT                      ] = "ERROR_DISK_CORRUPT"
	#OSERROR$[ $$ERROR_NO_USER_SESSION_KEY               ] = "ERROR_NO_USER_SESSION_KEY"
	#OSERROR$[ $$ERROR_INVALID_WINDOW_HANDLE             ] = "ERROR_INVALID_WINDOW_HANDLE"
	#OSERROR$[ $$ERROR_INVALID_MENU_HANDLE               ] = "ERROR_INVALID_MENU_HANDLE"
	#OSERROR$[ $$ERROR_INVALID_CURSOR_HANDLE             ] = "ERROR_INVALID_CURSOR_HANDLE"
	#OSERROR$[ $$ERROR_INVALID_ACCEL_HANDLE              ] = "ERROR_INVALID_ACCEL_HANDLE"
	#OSERROR$[ $$ERROR_INVALID_HOOK_HANDLE               ] = "ERROR_INVALID_HOOK_HANDLE"
	#OSERROR$[ $$ERROR_INVALID_DWP_HANDLE                ] = "ERROR_INVALID_DWP_HANDLE"
	#OSERROR$[ $$ERROR_TLW_WITH_WSCHILD                  ] = "ERROR_TLW_WITH_WSCHILD"
	#OSERROR$[ $$ERROR_CANNOT_FIND_WND_CLASS             ] = "ERROR_CANNOT_FIND_WND_CLASS"
	#OSERROR$[ $$ERROR_WINDOW_OF_OTHER_THREAD            ] = "ERROR_WINDOW_OF_OTHER_THREAD"
	#OSERROR$[ $$ERROR_HOTKEY_ALREADY_REGISTERED         ] = "ERROR_HOTKEY_ALREADY_REGISTERED"
	#OSERROR$[ $$ERROR_CLASS_ALREADY_EXISTS              ] = "ERROR_CLASS_ALREADY_EXISTS"
	#OSERROR$[ $$ERROR_CLASS_DOES_NOT_EXIST              ] = "ERROR_CLASS_DOES_NOT_EXIST"
	#OSERROR$[ $$ERROR_CLASS_HAS_WINDOWS                 ] = "ERROR_CLASS_HAS_WINDOWS"
	#OSERROR$[ $$ERROR_INVALID_INDEX                     ] = "ERROR_INVALID_INDEX"
	#OSERROR$[ $$ERROR_INVALID_ICON_HANDLE               ] = "ERROR_INVALID_ICON_HANDLE"
	#OSERROR$[ $$ERROR_PRIVATE_DIALOG_INDEX              ] = "ERROR_PRIVATE_DIALOG_INDEX"
	#OSERROR$[ $$ERROR_LISTBOX_ID_NOT_FOUND              ] = "ERROR_LISTBOX_ID_NOT_FOUND"
	#OSERROR$[ $$ERROR_NO_WILDCARD_CHARACTERS            ] = "ERROR_NO_WILDCARD_CHARACTERS"
	#OSERROR$[ $$ERROR_CLIPBOARD_NOT_OPEN                ] = "ERROR_CLIPBOARD_NOT_OPEN"
	#OSERROR$[ $$ERROR_HOTKEY_NOT_REGISTERED             ] = "ERROR_HOTKEY_NOT_REGISTERED"
	#OSERROR$[ $$ERROR_WINDOW_NOT_DIALOG                 ] = "ERROR_WINDOW_NOT_DIALOG"
	#OSERROR$[ $$ERROR_CONTROL_ID_NOT_FOUND              ] = "ERROR_CONTROL_ID_NOT_FOUND"
	#OSERROR$[ $$ERROR_INVALID_COMBOBOX_MESSAGE          ] = "ERROR_INVALID_COMBOBOX_MESSAGE"
	#OSERROR$[ $$ERROR_WINDOW_NOT_COMBOBOX               ] = "ERROR_WINDOW_NOT_COMBOBOX"
	#OSERROR$[ $$ERROR_INVALID_EDIT_HEIGHT               ] = "ERROR_INVALID_EDIT_HEIGHT"
	#OSERROR$[ $$ERROR_DC_NOT_FOUND                      ] = "ERROR_DC_NOT_FOUND"
	#OSERROR$[ $$ERROR_INVALID_HOOK_FILTER               ] = "ERROR_INVALID_HOOK_FILTER"
	#OSERROR$[ $$ERROR_INVALID_FILTER_PROC               ] = "ERROR_INVALID_FILTER_PROC"
	#OSERROR$[ $$ERROR_HOOK_NEEDS_HMOD                   ] = "ERROR_HOOK_NEEDS_HMOD"
	#OSERROR$[ $$ERROR_GLOBAL_ONLY_HOOK                  ] = "ERROR_GLOBAL_ONLY_HOOK"
	#OSERROR$[ $$ERROR_JOURNAL_HOOK_SET                  ] = "ERROR_JOURNAL_HOOK_SET"
	#OSERROR$[ $$ERROR_HOOK_NOT_INSTALLED                ] = "ERROR_HOOK_NOT_INSTALLED"
	#OSERROR$[ $$ERROR_INVALID_LB_MESSAGE                ] = "ERROR_INVALID_LB_MESSAGE"
	#OSERROR$[ $$ERROR_SETCOUNT_ON_BAD_LB                ] = "ERROR_SETCOUNT_ON_BAD_LB"
	#OSERROR$[ $$ERROR_LB_WITHOUT_TABSTOPS               ] = "ERROR_LB_WITHOUT_TABSTOPS"
	#OSERROR$[ $$ERROR_DESTROY_OBJECT_OF_OTHER_THREAD    ] = "ERROR_DESTROY_OBJECT_OF_OTHER_THREAD"
	#OSERROR$[ $$ERROR_CHILD_WINDOW_MENU                 ] = "ERROR_CHILD_WINDOW_MENU"
	#OSERROR$[ $$ERROR_NO_SYSTEM_MENU                    ] = "ERROR_NO_SYSTEM_MENU"
	#OSERROR$[ $$ERROR_INVALID_MSGBOX_STYLE              ] = "ERROR_INVALID_MSGBOX_STYLE"
	#OSERROR$[ $$ERROR_INVALID_SPI_VALUE                 ] = "ERROR_INVALID_SPI_VALUE"
	#OSERROR$[ $$ERROR_SCREEN_ALREADY_LOCKED             ] = "ERROR_SCREEN_ALREADY_LOCKED"
	#OSERROR$[ $$ERROR_HWNDS_HAVE_DIFF_PARENT            ] = "ERROR_HWNDS_HAVE_DIFF_PARENT"
	#OSERROR$[ $$ERROR_NOT_CHILD_WINDOW                  ] = "ERROR_NOT_CHILD_WINDOW"
	#OSERROR$[ $$ERROR_INVALID_GW_COMMAND                ] = "ERROR_INVALID_GW_COMMAND"
	#OSERROR$[ $$ERROR_INVALID_THREAD_ID                 ] = "ERROR_INVALID_THREAD_ID"
	#OSERROR$[ $$ERROR_NON_MDICHILD_WINDOW               ] = "ERROR_NON_MDICHILD_WINDOW"
	#OSERROR$[ $$ERROR_POPUP_ALREADY_ACTIVE              ] = "ERROR_POPUP_ALREADY_ACTIVE"
	#OSERROR$[ $$ERROR_NO_SCROLLBARS                     ] = "ERROR_NO_SCROLLBARS"
	#OSERROR$[ $$ERROR_INVALID_SCROLLBAR_RANGE           ] = "ERROR_INVALID_SCROLLBAR_RANGE"
	#OSERROR$[ $$ERROR_INVALID_SHOWWIN_COMMAND           ] = "ERROR_INVALID_SHOWWIN_COMMAND"
	#OSERROR$[ $$ERROR_EVENTLOG_FILE_CORRUPT             ] = "ERROR_EVENTLOG_FILE_CORRUPT"
	#OSERROR$[ $$ERROR_EVENTLOG_CANT_START               ] = "ERROR_EVENTLOG_CANT_START"
	#OSERROR$[ $$ERROR_LOG_FILE_FULL                     ] = "ERROR_LOG_FILE_FULL"
	#OSERROR$[ $$ERROR_EVENTLOG_FILE_CHANGED             ] = "ERROR_EVENTLOG_FILE_CHANGED"
	#OSERROR$[ $$ERROR_INVALID_USER_BUFFER               ] = "ERROR_INVALID_USER_BUFFER"
	#OSERROR$[ $$ERROR_UNRECOGNIZED_MEDIA                ] = "ERROR_UNRECOGNIZED_MEDIA"
	#OSERROR$[ $$ERROR_NO_TRUST_LSA_SECRET               ] = "ERROR_NO_TRUST_LSA_SECRET"
	#OSERROR$[ $$ERROR_NO_TRUST_SAM_ACCOUNT              ] = "ERROR_NO_TRUST_SAM_ACCOUNT"
	#OSERROR$[ $$ERROR_TRUSTED_DOMAIN_FAILURE            ] = "ERROR_TRUSTED_DOMAIN_FAILURE"
	#OSERROR$[ $$ERROR_TRUSTED_RELATIONSHIP_FAILURE      ] = "ERROR_TRUSTED_RELATIONSHIP_FAILURE"
	#OSERROR$[ $$ERROR_TRUST_FAILURE                     ] = "ERROR_TRUST_FAILURE"
	#OSERROR$[ $$ERROR_NETLOGON_NOT_STARTED              ] = "ERROR_NETLOGON_NOT_STARTED"
	#OSERROR$[ $$ERROR_ACCOUNT_EXPIRED                   ] = "ERROR_ACCOUNT_EXPIRED"
	#OSERROR$[ $$ERROR_REDIRECTOR_HAS_OPEN_HANDLES       ] = "ERROR_REDIRECTOR_HAS_OPEN_HANDLES"
	#OSERROR$[ $$ERROR_PRINTER_DRIVER_ALREADY_INSTALLED  ] = "ERROR_PRINTER_DRIVER_ALREADY_INSTALLED"
	#OSERROR$[ $$ERROR_UNKNOWN_PORT                      ] = "ERROR_UNKNOWN_PORT"
	#OSERROR$[ $$ERROR_UNKNOWN_PRINTER_DRIVER            ] = "ERROR_UNKNOWN_PRINTER_DRIVER"
	#OSERROR$[ $$ERROR_UNKNOWN_PRINTPROCESSOR            ] = "ERROR_UNKNOWN_PRINTPROCESSOR"
	#OSERROR$[ $$ERROR_INVALID_SEPARATOR_FILE            ] = "ERROR_INVALID_SEPARATOR_FILE"
	#OSERROR$[ $$ERROR_INVALID_PRIORITY                  ] = "ERROR_INVALID_PRIORITY"
	#OSERROR$[ $$ERROR_INVALID_PRINTER_NAME              ] = "ERROR_INVALID_PRINTER_NAME"
	#OSERROR$[ $$ERROR_PRINTER_ALREADY_EXISTS            ] = "ERROR_PRINTER_ALREADY_EXISTS"
	#OSERROR$[ $$ERROR_INVALID_PRINTER_COMMAND           ] = "ERROR_INVALID_PRINTER_COMMAND"
	#OSERROR$[ $$ERROR_INVALID_DATATYPE                  ] = "ERROR_INVALID_DATATYPE"
	#OSERROR$[ $$ERROR_INVALID_ENVIRONMENT               ] = "ERROR_INVALID_ENVIRONMENT"
	#OSERROR$[ $$ERROR_NOLOGON_INTERDOMAIN_TRUST_ACCOUNT ] = "ERROR_NOLOGON_INTERDOMAIN_TRUST_ACCOUNT"
	#OSERROR$[ $$ERROR_NOLOGON_WORKSTATION_TRUST_ACCOUNT ] = "ERROR_NOLOGON_WORKSTATION_TRUST_ACCOUNT"
	#OSERROR$[ $$ERROR_NOLOGON_SERVER_TRUST_ACCOUNT      ] = "ERROR_NOLOGON_SERVER_TRUST_ACCOUNT"
	#OSERROR$[ $$ERROR_DOMAIN_TRUST_INCONSISTENT         ] = "ERROR_DOMAIN_TRUST_INCONSISTENT"
	#OSERROR$[ $$ERROR_SERVER_HAS_OPEN_HANDLES           ] = "ERROR_SERVER_HAS_OPEN_HANDLES"
	#OSERROR$[ $$ERROR_RESOURCE_DATA_NOT_FOUND           ] = "ERROR_RESOURCE_DATA_NOT_FOUND"
	#OSERROR$[ $$ERROR_RESOURCE_TYPE_NOT_FOUND           ] = "ERROR_RESOURCE_TYPE_NOT_FOUND"
	#OSERROR$[ $$ERROR_RESOURCE_NAME_NOT_FOUND           ] = "ERROR_RESOURCE_NAME_NOT_FOUND"
	#OSERROR$[ $$ERROR_RESOURCE_LANG_NOT_FOUND           ] = "ERROR_RESOURCE_LANG_NOT_FOUND"
	#OSERROR$[ $$ERROR_NOT_ENOUGH_QUOTA                  ] = "ERROR_NOT_ENOUGH_QUOTA"
	#OSERROR$[ $$ERROR_INVALID_TIME                      ] = "ERROR_INVALID_TIME"
	#OSERROR$[ $$ERROR_INVALID_FORM_NAME                 ] = "ERROR_INVALID_FORM_NAME"
	#OSERROR$[ $$ERROR_INVALID_FORM_SIZE                 ] = "ERROR_INVALID_FORM_SIZE"
	#OSERROR$[ $$ERROR_ALREADY_WAITING                   ] = "ERROR_ALREADY_WAITING"
	#OSERROR$[ $$ERROR_PRINTER_DELETED                   ] = "ERROR_PRINTER_DELETED"
	#OSERROR$[ $$ERROR_INVALID_PRINTER_STATE             ] = "ERROR_INVALID_PRINTER_STATE"
	#OSERROR$[ $$ERROR_NO_BROWSER_SERVERS_FOUND          ] = "ERROR_NO_BROWSER_SERVERS_FOUND"
'
'
' ************************************************************
'
' nativeErrorNumber = #OSTOXERROR[operatingSystemErrorNumber]
'
' converts all operating system error numbers to native error numbers
' nativeErrorNumber = (($$ErrorObjectSystem << 8) OR $$ErrorNatureError)
' means there's no native error number for this system error number,
' so you'll have to settle for the system error number.
'
'
	upper = UBOUND (#OSTOXERROR[])
	FOR i = 0 TO upper
		#OSTOXERROR[i] = ($$ErrorObjectSystem << 8) OR $$ErrorNatureError
	NEXT i
'
	#OSTOXERROR[ $$ERROR_SUCCESS                           ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureNone
	#OSTOXERROR[ $$ERROR_INVALID_FUNCTION                  ] = ($$ErrorObjectFunction					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_FILE_NOT_FOUND                    ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ERROR_PATH_NOT_FOUND                    ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ERROR_TOO_MANY_OPEN_FILES               ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_ACCESS_DENIED                     ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$ERROR_INVALID_HANDLE                    ] = ($$ErrorObjectIdentity					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_ARENA_TRASHED                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_ENOUGH_MEMORY                 ] = ($$ErrorObjectMemory						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_INVALID_BLOCK                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_ENVIRONMENT                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$ERROR_BAD_FORMAT                        ] = ($$ErrorObjectProgram					<< 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ERROR_INVALID_ACCESS                    ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ERROR_INVALID_DATA                      ] = ($$ErrorObjectData							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_OUTOFMEMORY                       ] = ($$ErrorObjectMemory						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_INVALID_DRIVE                     ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_CURRENT_DIRECTORY                 ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_NOT_SAME_DEVICE                   ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$ERROR_NO_MORE_FILES                     ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_WRITE_PROTECT                     ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$ERROR_BAD_UNIT                          ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ERROR_NOT_READY                         ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_BAD_COMMAND                       ] = ($$ErrorObjectCommand					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_CRC                               ] = ($$ErrorObjectData							<< 8) OR $$ErrorNatureInvalidCheck
	#OSTOXERROR[ $$ERROR_BAD_LENGTH                        ] = ($$ErrorObjectCommand					<< 8) OR $$ErrorNatureInvalidSize
	#OSTOXERROR[ $$ERROR_SEEK                              ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ERROR_NOT_DOS_DISK                      ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidFormat
	#OSTOXERROR[ $$ERROR_SECTOR_NOT_FOUND                  ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ERROR_OUT_OF_PAPER                      ] = ($$ErrorObjectPrinter					<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_WRITE_FAULT                       ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidAccess
	#OSTOXERROR[ $$ERROR_READ_FAULT                        ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidAccess
	#OSTOXERROR[ $$ERROR_GEN_FAILURE                       ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureFailed
	#OSTOXERROR[ $$ERROR_SHARING_VIOLATION                 ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_LOCK_VIOLATION                    ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_WRONG_DISK                        ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_SHARING_BUFFER_EXCEEDED           ] = ($$ErrorObjectBuffer						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_HANDLE_EOF                        ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_HANDLE_DISK_FULL                  ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_NOT_SUPPORTED                     ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidCommand
	#OSTOXERROR[ $$ERROR_REM_NOT_LIST                      ] = ($$ErrorObjectComputer					<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_DUP_NAME                          ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureDuplicate
	#OSTOXERROR[ $$ERROR_BAD_NETPATH                       ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_NETWORK_BUSY                      ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_DEV_NOT_EXIST                     ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureNonexistent
	#OSTOXERROR[ $$ERROR_TOO_MANY_CMDS                     ] = ($$ErrorObjectCommand					<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_ADAP_HDW_ERR                      ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureMalfunction
	#OSTOXERROR[ $$ERROR_BAD_NET_RESP                      ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidReply
	#OSTOXERROR[ $$ERROR_UNEXP_NET_ERR                     ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureUnexpected
	#OSTOXERROR[ $$ERROR_BAD_REM_ADAP                      ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$ERROR_PRINTQ_FULL                       ] = ($$ErrorObjectBuffer						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_NO_SPOOL_SPACE                    ] = ($$ErrorObjectBuffer						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_PRINT_CANCELLED                   ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureTerminated
	#OSTOXERROR[ $$ERROR_NETNAME_DELETED                   ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_NETWORK_ACCESS_DENIED             ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$ERROR_BAD_DEV_TYPE                      ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidType
	#OSTOXERROR[ $$ERROR_BAD_NET_NAME                      ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_TOO_MANY_NAMES                    ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_TOO_MANY_SESS                     ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_SHARING_PAUSED                    ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_REQ_NOT_ACCEP                     ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_REDIR_PAUSED                      ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_FILE_EXISTS                       ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureDuplicate
	#OSTOXERROR[ $$ERROR_CANNOT_MAKE                       ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureDuplicate
	#OSTOXERROR[ $$ERROR_FAIL_I24                          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureNone
	#OSTOXERROR[ $$ERROR_OUT_OF_STRUCTURES                 ] = ($$ErrorObjectMemory						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_ALREADY_ASSIGNED                  ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureDuplicate
	#OSTOXERROR[ $$ERROR_INVALID_PASSWORD                  ] = ($$ErrorObjectArgument					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_PARAMETER                 ] = ($$ErrorObjectArgument					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_NET_WRITE_FAULT                   ] = ($$ErrorObjectNetwork					<< 8) OR $$ErrorNatureInvalidAccess
	#OSTOXERROR[ $$ERROR_NO_PROC_SLOTS                     ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_TOO_MANY_SEMAPHORES               ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_EXCL_SEM_ALREADY_OWNED            ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNaturePermission
	#OSTOXERROR[ $$ERROR_SEM_IS_SET                        ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_TOO_MANY_SEM_REQUESTS             ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_INVALID_AT_INTERRUPT_TIME         ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_SEM_OWNER_DIED                    ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureAbandoned
	#OSTOXERROR[ $$ERROR_SEM_USER_LIMIT                    ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_DISK_CHANGE                       ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureUnexpected
	#OSTOXERROR[ $$ERROR_DRIVE_LOCKED                      ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_BROKEN_PIPE                       ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureTerminated
	#OSTOXERROR[ $$ERROR_OPEN_FAILED                       ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_BUFFER_OVERFLOW                   ] = ($$ErrorObjectBuffer						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_DISK_FULL                         ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_NO_MORE_SEARCH_HANDLES            ] = ($$ErrorObjectIdentity					<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_INVALID_TARGET_HANDLE             ] = ($$ErrorObjectIdentity					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_CATEGORY                  ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureInvalidKind
	#OSTOXERROR[ $$ERROR_INVALID_VERIFY_SWITCH             ] = ($$ErrorObjectCommand					<< 8) OR $$ErrorNatureInvalidArgument
	#OSTOXERROR[ $$ERROR_BAD_DRIVER_LEVEL                  ] = ($$ErrorObjectCommand					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_CALL_NOT_IMPLEMENTED              ] = ($$ErrorObjectFunction					<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_SEM_TIMEOUT                       ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureTimeout
	#OSTOXERROR[ $$ERROR_INSUFFICIENT_BUFFER               ] = ($$ErrorObjectBuffer						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_INVALID_NAME                      ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_LEVEL                     ] = ($$ErrorObjectFunction					<< 8) OR $$ErrorNatureUnexpected
	#OSTOXERROR[ $$ERROR_NO_VOLUME_LABEL                   ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$ERROR_MOD_NOT_FOUND                     ] = ($$ErrorObjectProgram					<< 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$ERROR_PROC_NOT_FOUND                    ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$ERROR_WAIT_NO_CHILDREN                  ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureMissing
	#OSTOXERROR[ $$ERROR_CHILD_NOT_COMPLETE                ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureIncompatible
	#OSTOXERROR[ $$ERROR_DIRECT_ACCESS_HANDLE              ] = ($$ErrorObjectIdentity					<< 8) OR $$ErrorNatureInvalidType
	#OSTOXERROR[ $$ERROR_NEGATIVE_SEEK                     ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureInvalidArgument
	#OSTOXERROR[ $$ERROR_SEEK_ON_DEVICE                    ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_IS_JOIN_TARGET                    ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_IS_JOINED                         ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_IS_SUBSTED                        ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_NOT_JOINED                        ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_NOT_SUBSTED                       ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_JOIN_TO_JOIN                      ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_SUBST_TO_SUBST                    ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_JOIN_TO_SUBST                     ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_SUBST_TO_JOIN                     ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_BUSY_DRIVE                        ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_SAME_DRIVE                        ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_DIR_NOT_ROOT                      ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_DIR_NOT_EMPTY                     ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_IS_SUBST_PATH                     ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_IS_JOIN_PATH                      ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_PATH_BUSY                         ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_IS_SUBST_TARGET                   ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_SYSTEM_TRACE                      ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_INVALID_EVENT_COUNT               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_MUXWAITERS               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_INVALID_LIST_FORMAT               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_LABEL_TOO_LONG                    ] = ($$ErrorObjectDisk							<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_TOO_MANY_TCBS                     ] = ($$ErrorObjectThread						<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_SIGNAL_REFUSED                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DISCARDED                         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_LOCKED                        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_THREADID_ADDR                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_ARGUMENTS                     ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureInvalidArgument
	#OSTOXERROR[ $$ERROR_BAD_PATHNAME                      ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_SIGNAL_PENDING                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MAX_THRDS_REACHED                 ] = ($$ErrorObjectThread						<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_LOCK_FAILED                       ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureInvalidRequest
	#OSTOXERROR[ $$ERROR_BUSY                              ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_CANCEL_VIOLATION                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ATOMIC_LOCKS_NOT_SUPPORTED        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SEGMENT_NUMBER            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ORDINAL                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ALREADY_EXISTS                    ] = ($$ErrorObjectFile							<< 8) OR $$ErrorNatureDuplicate
	#OSTOXERROR[ $$ERROR_INVALID_FLAG_NUMBER               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SEM_NOT_FOUND                     ] = ($$ErrorObjectSemaphore				<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_INVALID_STARTING_CODESEG          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_STACKSEG                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_MODULETYPE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_EXE_SIGNATURE             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EXE_MARKED_INVALID                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_EXE_FORMAT                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ITERATED_DATA_EXCEEDS_64k         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_MINALLOCSIZE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DYNLINK_FROM_INVALID_RING         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_IOPL_NOT_ENABLED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SEGDPL                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_AUTODATASEG_EXCEEDS_64k           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RING2SEG_MUST_BE_MOVABLE          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RELOC_CHAIN_XEEDS_SEGLIM          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INFLOOP_IN_RELOC_CHAIN            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ENVVAR_NOT_FOUND                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SIGNAL_SENT                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FILENAME_EXCED_RANGE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RING2_STACK_IN_USE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_META_EXPANSION_TOO_LONG           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SIGNAL_NUMBER             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_THREAD_1_INACTIVE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOCKED                            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_MODULES                  ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureLimitExceeded
	#OSTOXERROR[ $$ERROR_NESTING_NOT_ALLOWED               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_PIPE                          ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PIPE_BUSY                         ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_NO_DATA                           ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PIPE_NOT_CONNECTED                ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_MORE_DATA                         ] = ($$ErrorObjectData							<< 8) OR $$ErrorNatureAvailable
	#OSTOXERROR[ $$ERROR_VC_DISCONNECTED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_EA_NAME                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EA_LIST_INCONSISTENT              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_MORE_ITEMS                     ] = ($$ErrorObjectData							<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_CANNOT_COPY                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DIRECTORY                         ] = ($$ErrorObjectDirectory				<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_EAS_DIDNT_FIT                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EA_FILE_CORRUPT                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EA_TABLE_FULL                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_EA_HANDLE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EAS_NOT_SUPPORTED                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_OWNER                         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_POSTS                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MR_MID_NOT_FOUND                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ADDRESS                   ] = ($$ErrorObjectMemory						<< 8) OR $$ErrorNatureInvalidAddress
	#OSTOXERROR[ $$ERROR_ARITHMETIC_OVERFLOW               ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureOverflow
	#OSTOXERROR[ $$ERROR_PIPE_CONNECTED                    ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureAvailable
	#OSTOXERROR[ $$ERROR_PIPE_LISTENING                    ] = ($$ErrorObjectPipe							<< 8) OR $$ErrorNatureAvailable
	#OSTOXERROR[ $$ERROR_EA_ACCESS_DENIED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_OPERATION_ABORTED                 ] = ($$ErrorObjectNone							<< 8) OR $$ErrorNatureTerminated
	#OSTOXERROR[ $$ERROR_IO_INCOMPLETE                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_IO_PENDING                        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOACCESS                          ] = ($$ErrorObjectMemory						<< 8) OR $$ErrorNatureInvalidAccess
	#OSTOXERROR[ $$ERROR_SWAPERROR                         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_STACK_OVERFLOW                    ] = ($$ErrorObjectStack						<< 8) OR $$ErrorNatureOverflow
	#OSTOXERROR[ $$ERROR_INVALID_MESSAGE                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CAN_NOT_COMPLETE                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_FLAGS                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNRECOGNIZED_VOLUME               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FILE_INVALID                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FULLSCREEN_MODE                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_TOKEN                          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BADDB                             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BADKEY                            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANTOPEN                          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANTREAD                          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANTWRITE                         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_REGISTRY_RECOVERED                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_REGISTRY_CORRUPT                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_REGISTRY_IO_FAILED                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_REGISTRY_FILE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_KEY_DELETED                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_LOG_SPACE                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_KEY_HAS_CHILDREN                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CHILD_MUST_BE_VOLATILE            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOTIFY_ENUM_DIR                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DEPENDENT_SERVICES_RUNNING        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SERVICE_CONTROL           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_REQUEST_TIMEOUT           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_NO_THREAD                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_DATABASE_LOCKED           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_ALREADY_RUNNING           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SERVICE_ACCOUNT           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_DISABLED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CIRCULAR_DEPENDENCY               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_DOES_NOT_EXIST            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_CANNOT_ACCEPT_CTRL        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_NOT_ACTIVE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FAILED_SERVICE_CONTROLLER_CONNECT ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EXCEPTION_IN_SERVICE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DATABASE_DOES_NOT_EXIST           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_SPECIFIC_ERROR            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PROCESS_ABORTED                   ] = ($$ErrorObjectProcess					<< 8) OR $$ErrorNatureTerminated
	#OSTOXERROR[ $$ERROR_SERVICE_DEPENDENCY_FAIL           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_LOGON_FAILED              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_START_HANG                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SERVICE_LOCK              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_MARKED_FOR_DELETE         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_EXISTS                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ALREADY_RUNNING_LKG               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_DEPENDENCY_DELETED        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BOOT_ALREADY_ACCEPTED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVICE_NEVER_STARTED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DUPLICATE_SERVICE_NAME            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_END_OF_MEDIA                      ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureExhausted
	#OSTOXERROR[ $$ERROR_FILEMARK_DETECTED                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BEGINNING_OF_MEDIA                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SETMARK_DETECTED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_DATA_DETECTED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PARTITION_FAILURE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_BLOCK_LENGTH              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DEVICE_NOT_PARTITIONED            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNABLE_TO_LOCK_MEDIA              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNABLE_TO_UNLOAD_MEDIA            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MEDIA_CHANGED                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BUS_RESET                         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_MEDIA_IN_DRIVE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_UNICODE_TRANSLATION            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DLL_INIT_FAILED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SHUTDOWN_IN_PROGRESS              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SHUTDOWN_IN_PROGRESS           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_IO_DEVICE                         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERIAL_NO_DEVICE                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_IRQ_BUSY                          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MORE_WRITES                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_COUNTER_TIMEOUT                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FLOPPY_ID_MARK_NOT_FOUND          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FLOPPY_WRONG_CYLINDER             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FLOPPY_UNKNOWN_ERROR              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FLOPPY_BAD_REGISTERS              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DISK_RECALIBRATE_FAILED           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DISK_OPERATION_FAILED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DISK_RESET_FAILED                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EOM_OVERFLOW                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_ENOUGH_SERVER_MEMORY          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_POSSIBLE_DEADLOCK                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MAPPED_ALIGNMENT                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_USERNAME                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_CONNECTED                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_OPEN_FILES                        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DEVICE_IN_USE                     ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureUnavailable
	#OSTOXERROR[ $$ERROR_BAD_DEVICE                        ] = ($$ErrorObjectDevice						<< 8) OR $$ErrorNatureInvalidName
	#OSTOXERROR[ $$ERROR_CONNECTION_UNAVAIL                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DEVICE_ALREADY_REMEMBERED         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_NET_OR_BAD_PATH                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_PROVIDER                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANNOT_OPEN_PROFILE               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_PROFILE                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_CONTAINER                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EXTENDED_ERROR                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_GROUPNAME                 ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_COMPUTERNAME              ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_EVENTNAME                 ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_DOMAINNAME                ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_SERVICENAME               ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_NETNAME                   ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_SHARENAME                 ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_PASSWORDNAME              ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_MESSAGENAME               ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_INVALID_MESSAGEDEST               ] = ($$ErrorObjectName							<< 8) OR $$ErrorNatureInvalid
	#OSTOXERROR[ $$ERROR_SESSION_CREDENTIAL_CONFLICT       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_REMOTE_SESSION_LIMIT_EXCEEDED     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DUP_DOMAINNAME                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_NETWORK                        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_ALL_ASSIGNED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SOME_NOT_MAPPED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_QUOTAS_FOR_ACCOUNT             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOCAL_USER_SESSION_KEY            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NULL_LM_PASSWORD                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNKNOWN_REVISION                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_REVISION_MISMATCH                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_OWNER                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_PRIMARY_GROUP             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_IMPERSONATION_TOKEN            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANT_DISABLE_MANDATORY            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_LOGON_SERVERS                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_LOGON_SESSION             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_PRIVILEGE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PRIVILEGE_NOT_HELD                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ACCOUNT_NAME              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_USER_EXISTS                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_USER                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_GROUP_EXISTS                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_GROUP                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MEMBER_IN_GROUP                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MEMBER_NOT_IN_GROUP               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LAST_ADMIN                        ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_WRONG_PASSWORD                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ILL_FORMED_PASSWORD               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PASSWORD_RESTRICTION              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOGON_FAILURE                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ACCOUNT_RESTRICTION               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_LOGON_HOURS               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_WORKSTATION               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PASSWORD_EXPIRED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ACCOUNT_DISABLED                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NONE_MAPPED                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_LUIDS_REQUESTED          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LUIDS_EXHAUSTED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SUB_AUTHORITY             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ACL                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SID                       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SECURITY_DESCR            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_INHERITANCE_ACL               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVER_DISABLED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVER_NOT_DISABLED               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ID_AUTHORITY              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ALLOTTED_SPACE_EXCEEDED           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_GROUP_ATTRIBUTES          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_IMPERSONATION_LEVEL           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANT_OPEN_ANONYMOUS               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_VALIDATION_CLASS              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_TOKEN_TYPE                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SECURITY_ON_OBJECT             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANT_ACCESS_DOMAIN_INFO           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SERVER_STATE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_DOMAIN_STATE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_DOMAIN_ROLE               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_DOMAIN                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DOMAIN_EXISTS                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DOMAIN_LIMIT_EXCEEDED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INTERNAL_DB_CORRUPTION            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INTERNAL_ERROR                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_GENERIC_NOT_MAPPED                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_DESCRIPTOR_FORMAT             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_LOGON_PROCESS                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOGON_SESSION_EXISTS              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_PACKAGE                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_BAD_LOGON_SESSION_STATE           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOGON_SESSION_COLLISION           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_LOGON_TYPE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANNOT_IMPERSONATE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RXACT_INVALID_STATE               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RXACT_COMMIT_FAILURE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SPECIAL_ACCOUNT                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SPECIAL_GROUP                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SPECIAL_USER                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MEMBERS_PRIMARY_GROUP             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOKEN_ALREADY_IN_USE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_ALIAS                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MEMBER_NOT_IN_ALIAS               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_MEMBER_IN_ALIAS                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ALIAS_EXISTS                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOGON_NOT_GRANTED                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_SECRETS                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SECRET_TOO_LONG                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INTERNAL_DB_ERROR                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_CONTEXT_IDS              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOGON_TYPE_NOT_GRANTED            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NT_CROSS_ENCRYPTION_REQUIRED      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SUCH_MEMBER                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_MEMBER                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TOO_MANY_SIDS                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LM_CROSS_ENCRYPTION_REQUIRED      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_INHERITANCE                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_FILE_CORRUPT                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DISK_CORRUPT                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_USER_SESSION_KEY               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_WINDOW_HANDLE             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_MENU_HANDLE               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_CURSOR_HANDLE             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ACCEL_HANDLE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_HOOK_HANDLE               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_DWP_HANDLE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TLW_WITH_WSCHILD                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CANNOT_FIND_WND_CLASS             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_WINDOW_OF_OTHER_THREAD            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_HOTKEY_ALREADY_REGISTERED         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CLASS_ALREADY_EXISTS              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CLASS_DOES_NOT_EXIST              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CLASS_HAS_WINDOWS                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_INDEX                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ICON_HANDLE               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PRIVATE_DIALOG_INDEX              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LISTBOX_ID_NOT_FOUND              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_WILDCARD_CHARACTERS            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CLIPBOARD_NOT_OPEN                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_HOTKEY_NOT_REGISTERED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_WINDOW_NOT_DIALOG                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CONTROL_ID_NOT_FOUND              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_COMBOBOX_MESSAGE          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_WINDOW_NOT_COMBOBOX               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_EDIT_HEIGHT               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DC_NOT_FOUND                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_HOOK_FILTER               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_FILTER_PROC               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_HOOK_NEEDS_HMOD                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_GLOBAL_ONLY_HOOK                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_JOURNAL_HOOK_SET                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_HOOK_NOT_INSTALLED                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_LB_MESSAGE                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SETCOUNT_ON_BAD_LB                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LB_WITHOUT_TABSTOPS               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DESTROY_OBJECT_OF_OTHER_THREAD    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_CHILD_WINDOW_MENU                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SYSTEM_MENU                    ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_MSGBOX_STYLE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SPI_VALUE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SCREEN_ALREADY_LOCKED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_HWNDS_HAVE_DIFF_PARENT            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_CHILD_WINDOW                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_GW_COMMAND                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_THREAD_ID                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NON_MDICHILD_WINDOW               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_POPUP_ALREADY_ACTIVE              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_SCROLLBARS                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SCROLLBAR_RANGE           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SHOWWIN_COMMAND           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EVENTLOG_FILE_CORRUPT             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EVENTLOG_CANT_START               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_LOG_FILE_FULL                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_EVENTLOG_FILE_CHANGED             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_USER_BUFFER               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNRECOGNIZED_MEDIA                ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_TRUST_LSA_SECRET               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_TRUST_SAM_ACCOUNT              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TRUSTED_DOMAIN_FAILURE            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TRUSTED_RELATIONSHIP_FAILURE      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_TRUST_FAILURE                     ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NETLOGON_NOT_STARTED              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ACCOUNT_EXPIRED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_REDIRECTOR_HAS_OPEN_HANDLES       ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PRINTER_DRIVER_ALREADY_INSTALLED  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNKNOWN_PORT                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNKNOWN_PRINTER_DRIVER            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_UNKNOWN_PRINTPROCESSOR            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_SEPARATOR_FILE            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_PRIORITY                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_PRINTER_NAME              ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PRINTER_ALREADY_EXISTS            ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_PRINTER_COMMAND           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_DATATYPE                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_ENVIRONMENT               ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOLOGON_INTERDOMAIN_TRUST_ACCOUNT ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOLOGON_WORKSTATION_TRUST_ACCOUNT ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOLOGON_SERVER_TRUST_ACCOUNT      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_DOMAIN_TRUST_INCONSISTENT         ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_SERVER_HAS_OPEN_HANDLES           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RESOURCE_DATA_NOT_FOUND           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RESOURCE_TYPE_NOT_FOUND           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RESOURCE_NAME_NOT_FOUND           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_RESOURCE_LANG_NOT_FOUND           ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NOT_ENOUGH_QUOTA                  ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_TIME                      ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_FORM_NAME                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_FORM_SIZE                 ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_ALREADY_WAITING                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_PRINTER_DELETED                   ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_INVALID_PRINTER_STATE             ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
	#OSTOXERROR[ $$ERROR_NO_BROWSER_SERVERS_FOUND          ] = ($$ErrorObjectSystem						<< 8) OR $$ErrorNatureError
'
	##WHOMASK = whomask
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
' #########################
' #####  XstTimer ()  #####
' #########################
'
FUNCTION  XstTimer (hwnd, message, timer, time)
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
	Xui ()
	InitGui ()
	CreateConsole ()
END FUNCTION
'
'
' #########################
' #####  XxxClose ()  #####
' #########################
'
'	Close file
'
'	In:				fileNumber		File number
'						$$ALL					(-1)  Close all files
'
'	Out:			none		(arg unchanged)
'
'	Return:		$$TRUE		error (##ERROR is set)
'						$$FALSE		no error
'
'	User can only close user files
'
FUNCTION  XxxClose (fileNumber)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
	SHARED  LOCK  fileLock[]
'
	IFZ fileInfo[] THEN
		IF (fileNumber != -1) THEN GOTO eeeBadFileNumber
		RETURN ($$FALSE)
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
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
			IF ##WHOMASK THEN											' User can only Close her own files
				IFZ fileInfo[fileNumber].whomask THEN DO NEXT
			END IF
			GOSUB CloseFileHandle
		NEXT fileNumber
		fileNumber = $$ALL
	ELSE
		IF InvalidFileNumber(fileNumber) THEN RETURN ($$FALSE)
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
		a = CloseHandle (fileHandle)
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IFZ a THEN
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
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	errno	= GetLastError ()
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
'
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
'	Close all user's open files
'
'	In:				none
'	Out:			none
'	Return:		$$TRUE		error (##ERROR is set)
'						$$FALSE		no error
'
'	Internal: for the environment to off user programs
'
FUNCTION  XxxCloseAllUser ()
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IFZ fileInfo[] THEN RETURN ($$FALSE)			' No files open
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
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
		a = CloseHandle (fileHandle)
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IFZ a THEN
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
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	errno	= GetLastError ()
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
'
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
'	Return TRUE if current file pointer is beyond the end of file
'
'	In:				fileNumber		File Number
'	Out:			none--arg unchanged
'	Return:		$$TRUE		file at EOF
'						$$FALSE		file not at EOF
'						$$TRUE		error (##ERROR is set)		**** this must be resolved
'
'	The return values of TRUE and -max are ambiguous if tested with
'		"IF Eof(fileNumber) THEN".  User should test explicitely.
'		(Note that action based on EOF is usually consistent with that for error.)
'
FUNCTION  XxxEof (fileNumber)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	c = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)	' get file position
	IF (c = -1) THEN GOTO SeekError
	s = SetFilePointer (fileHandle, 0, 0, $$FILE_END)			' get size of file
	IF (s = -1) THEN GOTO SeekError
	a = SetFilePointer (fileHandle, c, 0, $$FILE_BEGIN)		' restore file position
	IF (a = -1) THEN GOTO SeekError
'
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	IF (c >= s) THEN RETURN ($$TRUE) ELSE RETURN ($$FALSE)
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
	RETURN ($$TRUE)
END FUNCTION
'
'
' ##############################
' #####  XxxGetVersion ()  #####
' ##############################
'
FUNCTION  XxxGetVersion ()
	OSVERSIONINFO  info

	info.dwOSVersionInfoSize = SIZE(OSVERSIONINFO)

	GetVersionExA (&info)
'
'	PRINT "info.dwOSVersionInfoSize = "; HEX$(info.dwOSVersionInfoSize,8)
'	PRINT "info.dwMajorVersion      = "; HEX$(info.dwMajorVersion,8)
'	PRINT "info.dwMinorVersion      = "; HEX$(info.dwMinorVersion,8)
'	PRINT "info.dwBuildNumber       = "; HEX$(info.dwBuildNumber,8)
'	PRINT "info.dwPlatformId        = "; HEX$(info.dwPlatformId,8)
'	PRINT "info.szCSDVersion        = "; info.szCSDVersion
'
' is OS old-style win32s or a win32 (Windows95/Windows98/WindowsNT/Windows2000/etc)
'
	major = info.dwMajorVersion AND 0x00FF
	minor = info.dwMinorVersion AND 0x00FF
	platform = info.dwPlatformId AND 0x00FF
	version = (platform << 16) OR (minor << 8) OR major
	IF (platform == $$VER_PLATFORM_WIN32s) THEN version = -1		' win32s == -1
	RETURN version
END FUNCTION
'
'
' ###########################
' #####  XxxInfile$ ()  #####
' ###########################
'
'	RETURN	line$		File string
'					""			End of file (##ERROR = $$ErrorEndOfFile)
'					""			error (##ERROR is set on error)
'
FUNCTION  XxxInfile$ (fileNumber)
	AUTOX  bytesRead
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ("")
		IFZ fileInfo[] THEN RETURN ("")
		IFZ fileInfo[1].fileHandle THEN RETURN ("")		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN												' Console Grid
		consoleGrid = fileInfo[fileNumber].consoleGrid
		XuiSendMessage (consoleGrid, #Inline, 0, 0, 0, 0, 0, @text$)
		XxxCheckMessages ()
		RETURN (text$)
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	p = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)	' p = file pointer before
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	IF (p = -1) THEN GOTO SeekError
'
	a$			= NULL$ (530)
	bufAddr	= &a$
	length	= 0
	nl			= 0
'
	DO
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = ReadFile (fileHandle, bufAddr, 86, &bytesRead, 0)
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IFZ a THEN GOTO ReadError
		IFZ bytesRead THEN EXIT DO
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

		length		= length + bytesRead
		bytesLeft	= LEN(a$) - length
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

	IF nl THEN
		p = p + nl															' put file pointer after <nl>
	ELSE
		p = p + length													' put file pointer after last char
	END IF
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	a = SetFilePointer (fileHandle, p, 0, $$FILE_BEGIN)
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	IF (a = -1) THEN GOTO SeekError
	RETURN (a$)
'
'	Error
'
SeekError:
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN
'
ReadError:
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	IF (bytesRead = 0) THEN
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		s = SetFilePointer (fileHandle, 0, 0, $$FILE_END)		' get size of file
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IF (s = -1) THEN GOTO SeekError
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = SetFilePointer (fileHandle, p, 0, $$FILE_BEGIN)	' restore file position
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IF (a = -1) THEN GOTO SeekError
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
'	In:			prompt$		MUST NOT FREE prompt$ (%_inline_d.s must do so)
'	RETURN	line$			input string
'					""				error (##ERROR is set on error)
'
FUNCTION  XxxInline$ (prompt$)
	AUTOX  bytesRead
	SHARED  FILE  fileInfo[]
'
	entryWHOMASK = ##WHOMASK
	##WHOMASK = 0
	fileHandle = fileInfo[1].fileHandle
	consoleGrid = fileInfo[1].consoleGrid
	line$ = prompt$														' don't free prompt$
	XuiSendMessage (consoleGrid, #Inline, 0, 0, 0, 0, 0, @line$)
	##WHOMASK = entryWHOMASK
	IF ##WHOMASK THEN line$ = line$						' user WHOMASK
	XxxCheckMessages ()
	RETURN (line$)
'
' Outdated:
'
	PRINT  prompt$;
	a$			= NULL$(260)
	bufAddr	= &a$
	length	= 0

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT

nextRead:
	DO
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		a = ReadFile (fileHandle, bufAddr, 256, &bytesRead, 0)
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IFZ a THEN EXIT DO
		aAddr = &a$
		length		= length + (bytesRead - 1)		' don't include \n
		lastChar	= UBYTEAT (aAddr, length)
		IF (lastChar = '\n') THEN
			UBYTEAT (aAddr, length)	= 0					' null terminator on top of \n
			prevChar	= UBYTEAT (aAddr, length-1)
			IF (prevChar = 13) THEN
				DEC length
				UBYTEAT (aAddr, length) = 0				' null terminator over \r
			END IF
			XLONGAT (aAddr, -8) = length					' length into header
			a$ = LEFT$ (a$, length)								' trim to fit
			RETURN (a$)
		ELSE
			INC length														' keep last character
			a$			= a$ + NULL$ (260)
			bufAddr	= &a$ + length
		END IF
	LOOP
'
'	Error
'
	IFZ a THEN ##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureExhausted) : RETURN
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN
END FUNCTION
'
'
' #######################
' #####  XxxLof ()  #####
' #######################
'
'	RETURN	0...	length of file
'					-1		error (##ERROR is set on error)
'
'	Note: vi appends an "invisible" \n to end of file
'				Thus a vi edited file will have length = apparent length + 1
'				An "append" will start after this trailing \n.
'
FUNCTION  XxxLof (fileNumber)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
'
	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	c = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)		' get file pointer
	IF (c = -1) THEN GOTO SeekError
	s = SetFilePointer (fileHandle, 0, 0, $$FILE_END)				' get size of file
	IF (s = -1) THEN GOTO SeekError
	a = SetFilePointer (fileHandle, c, 0, $$FILE_BEGIN)			' restore file pointer
	IF (a = -1) THEN GOTO SeekError
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	RETURN (s)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  XxxOpen ()  #####
' ########################
'
'	Open a file, return a fileNumber
'
'	in			: filename$		May include absolute or relative path
'												MUST NOT FREE filename$ (%_open.s must do so)
'	out			: none				(args unaltered)
'	return	: 1...				File Number
'						-1					error (##ERROR is set)
'
'	$$RD			Open existing file for reading only.		Error if file doesn't exist.
'	$$WR			Open existing file for writing only.		Error if file doesn't exist.
'	$$RW			Open existing file for read/write.			Error if file doesn't exist.
'	$$WRNEW		Open new file for writing.  						If file exists, delete it first.
'	$$RWNEW		Open new file for read/write.						If file exists, delete it first.
'	$$NOSHARE Let no other processes access this file.
'	$$RDSHARE Let other processes read this file.
'	$$WRSHARE	Let other processes write this file.
'	$$RWSHARE	Let other processes read/write this file.
'
'	CON:<fileName$> is a console
'	fileNumber 0 is "CON:" - system console input
'	fileNumber 1 is "CON:" - system console output
'	fileNumber 2 is "CON:" - system console errors
'
FUNCTION  XxxOpen (filename$, mode)
	EXTERNAL  errno
	SHARED  FILE  fileInfo[]
'
	okay = $$TRUE
	consoleGrid = 0
	hideConsole = 0
	f$ = TRIM$(filename$)
'
	IF (LEFT$(f$, 4) = "CON:") THEN
		IF fileInfo[] THEN
			FOR fileNumber = 1 TO UBOUND(fileInfo[])
				IFZ fileInfo[fileNumber].fileHandle THEN DO NEXT
				IF (f$ = TRIM$(fileInfo[fileNumber].fileName)) THEN
					INC fileInfo[fileNumber].entries
					RETURN (fileNumber)
				END IF
			NEXT fileNumber
		END IF
		x = -1 : y = -1											' Anywhere is fine
		width = 512 : height = 128
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
		wt = $$WindowTypeNormal OR $$WindowTypeCloseMinimize
		XuiConsole (@consoleGrid, #CreateWindow, x, y, width, height, wt, 0)
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
'		XuiSendMessage (consoleGrid, #SetHintString, -1, 0, 0, 0, 0, @"source of program input >>>   a$ = INLINE$ (prompt$)\ndestination of program output >>>   PRINT a$")
		XuiSendMessage (consoleGrid, #SetGridProperties, -1, 0, 0, 0, 0, 0)
		fileHandle = -1						' Windows HANDLEs are never -1
	ELSE
		f$ = XstPathString$ (@f$)
		ntShare = (mode >> 4) AND 0x0003
		SELECT CASE (mode AND 0x0007)
			CASE $$RD			:	ntMode		= $$GENERIC_READ
											ntCreate	= $$OPEN_EXISTING
			CASE $$WR			:	ntMode		= $$GENERIC_WRITE
											ntCreate	= $$OPEN_ALWAYS
			CASE $$RW			:	ntMode		= $$GENERIC_READ | $$GENERIC_WRITE
											ntCreate	= $$OPEN_ALWAYS
			CASE $$WRNEW	:	ntMode		= $$GENERIC_WRITE
											ntCreate	= $$CREATE_ALWAYS
			CASE $$RWNEW	:	ntMode		= $$GENERIC_READ | $$GENERIC_WRITE
											ntCreate	= $$CREATE_ALWAYS
		END SELECT
'
		entryWHOMASK = ##WHOMASK
		entryLOCKOUT = ##LOCKOUT
'
		##WHOMASK = 0
		##LOCKOUT = $$TRUE
		fileHandle = CreateFileA (&f$, ntMode, ntShare, 0, ntCreate, $$FILE_ATTRIBUTE_NORMAL, 0)
		##WHOMASK = entryWHOMASK
		##LOCKOUT = entryLOCKOUT
		IF (fileHandle = -1) THEN okay = $$FALSE
	END IF
'
	IF okay THEN
		IFZ fileInfo[] THEN
			##WHOMASK = 0
			DIM fileInfo[15]
			##WHOMASK = entryWHOMASK
		END IF
		IF (f$ = "CON:") THEN
			fileNumber = 1
			IF consoleGrid THEN ##CONGRID = consoleGrid
		ELSE
			uFile = UBOUND(fileInfo[])
			FOR fileNumber = 3 TO uFile
				IFZ fileInfo[fileNumber].fileHandle THEN EXIT FOR		' Find an open slot
			NEXT fileNumber
			IF (fileNumber > uFile) THEN													' No room at the inn
				uFile = (uFile << 1) OR 3
				##WHOMASK = 0
				REDIM fileInfo[uFile]
				##WHOMASK = entryWHOMASK
			END IF
		END IF
		fileInfo[fileNumber].fileName = f$
		fileInfo[fileNumber].fileHandle = fileHandle
		fileInfo[fileNumber].whomask = entryWHOMASK
		fileInfo[fileNumber].consoleGrid = consoleGrid
		fileInfo[fileNumber].entries = 1
'
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
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	errno = GetLastError ()
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
'
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	RETURN ($$TRUE)
END FUNCTION
'
'
' #######################
' #####  XxxPof ()  #####
' #######################
'
'	RETURN	0...	current position
'					-1		error (##ERROR is set on error)
'
FUNCTION  XxxPof (fileNumber)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]

	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	a = SetFilePointer (fileHandle, 0, 0, $$FILE_CURRENT)
	IF (a = -1) THEN GOTO SeekError
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	RETURN (a)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	RETURN ($$TRUE)
END FUNCTION
'
'
' ########################
' #####  XxxQuit ()  #####
' ########################
'
'	User can't quit out of the Xit environment or debugger
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
	ExitProcess (status)
END FUNCTION
'
'
' ############################
' #####  XxxReadFile ()  #####
' ############################
'
'	In:				fileNumber		File Number
'						buffer
'						bytes					to be written
'						bytesRead
'						overlapped		NULL
'
'	Invalid on console grids
'
FUNCTION  XxxReadFile (fileNumber, buffer, bytes, bytesRead, overlapped)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	IFZ bytes THEN RETURN ($$TRUE)
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ($$FALSE)
		IFZ fileInfo[] THEN RETURN ($$FALSE)
		IFZ fileInfo[1].fileHandle THEN RETURN ($$FALSE)		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN											' Console Grid
		FOR i = 0 TO bytes - 1
			UBYTEAT(buffer,i) = 0
		NEXT i
		consoleGrid = fileInfo[fileNumber].consoleGrid
		XuiSendMessage (consoleGrid, #GetTextString, 0, 0, 0, 0, 0, @text$)
		lenText = LEN(text$)
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
		RETURN ($$FALSE)
	END IF
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	result = ReadFile (fileHandle, buffer, bytes, @bytesRead, overlapped)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	IFZ result THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
END FUNCTION
'
'
' ########################
' #####  XxxSeek ()  #####
' ########################
'
'	RETURN	0...	new position
'					-1		error (##ERROR is set on error)
'
FUNCTION  XxxSeek (fileNumber, position)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]

	IF InvalidFileNumber (fileNumber) THEN RETURN (-1)
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN RETURN (-1)			' Console Grid

	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	a = SetFilePointer (fileHandle, position, 0, $$FILE_BEGIN)
	IF (a = -1) THEN GOTO SeekError
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	RETURN (a)
'
'	Error
'
SeekError:
	errno = GetLastError ()
	XstSystemErrorToError (errno, @error)
	##ERROR = error
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
	RETURN ($$TRUE)
END FUNCTION
'
'
' #########################
' #####  XxxShell ()  #####
' #########################
'
'	command$	MUST NOT FREE command$ (%_shell.s must do so)
'
'	wait till process completes unless 1st character of command$ = ":"
' inherit socket and file handles unless 1st character of command$ = "-"
'
'
FUNCTION  XxxShell (command$)
	AUTOX  PROCESS_INFORMATION  processInfo
	AUTOX  STARTUPINFO  startupInfo
	AUTOX  status
	AUTOX  c$
'
	$PROCESS_ALL_ACCESS					= 0x001F0FFF
	$PROCESS_QUERY_INFORMATION	= 0x00000400
	$STILL_ACTIVE								= 0x00000103
'
	whomask = ##WHOMASK
	lockout = ##LOCKOUT
	##WHOMASK = $$FALSE
'
	c$ = TRIM$ (command$)										' !!! don't free command$ !!!
'
	IFZ c$ THEN
		##WHOMASK = whomask
		RETURN
	END IF
'
	inherit = 1
	waitTillProcessCompleted = $$TRUE
'
	IF (c${0} = '-') THEN
		inherit = 0
		c$ = MID$(c$,2)
		IFZ c$ THEN
			##WHOMASK = whomask
			RETURN
		END IF
	END IF
'
	IF (c${0} = ':') THEN
		waitTillProcessCompleted = $$FALSE
		c$ = MID$(c$,2)
		IFZ c$ THEN
			##WHOMASK = whomask
			RETURN
		END IF
	END IF
'
	IF (c${0} = '-') THEN
		inherit = 0
		c$ = MID$(c$,2)
		IFZ c$ THEN
			##WHOMASK = whomask
			RETURN
		END IF
	END IF
'
	startupInfo.cb					= SIZE(STARTUPINFO)
	startupInfo.dwFlags			= 1										' look at wShowWindow
	startupInfo.wShowWindow	= 4										' show process window
'
	##LOCKOUT = $$TRUE
	CreateProcessA (0, &c$, 0, 0, inherit, 0, 0, 0, &startupInfo, &processInfo)
'
' CreateProcess() creates an extra set of process/thread handles for
' the calling process.  New process will not die until all handles are
' closed.  Standard procedure is to close these handles immediately.
'
'	PRINT HEX$(processInfo.hProcess,8);; HEX$(processInfo.hThread,8);; HEX$(processInfo.dwProcessId,8);; HEX$(processInfo.dwThreadId,8)
'
	processID = processInfo.dwProcessId
	CloseHandle (processInfo.hProcess)
	CloseHandle (processInfo.hThread)
	##LOCKOUT = lockout
'
' For some unknown reason, cannot get process status using original
' process handle.  Must open a new handle.
'
	IF waitTillProcessCompleted THEN
		##LOCKOUT = $$TRUE
'		hProcess = OpenProcess ($PROCESS_QUERY_INFORMATION, 1, processInfo.dwProcessId)
		hProcess = OpenProcess ($PROCESS_ALL_ACCESS, 1, processInfo.dwProcessId)
		##LOCKOUT = lockout
		DO
			##LOCKOUT = $$TRUE
			Sleep (20)
			okay = GetExitCodeProcess (hProcess, &status)
			##LOCKOUT = lockout
'
'			XxxGetEbpEsp (@ebp, @esp)
'			PRINT "XxxShell() : "; ok, HEX$(hProcess), HEX$(&status, 8), HEX$(status), HEX$(ebp,8), HEX$(esp,8), HEX$(&c$,8)
'
			IFZ okay THEN EXIT DO
'
'			Don't wait.  Process SYSTEM messages only if called by USER program.
'
			XxxDispatchEvents ($$FALSE, whomask)
			IF ##SOFTBREAK THEN
'
' Prefer to terminate the new process, but TerminateProcess() is not
' recommended because it leaves DLLs hanging.  ExitProcess() only
' terminates the calling process ...
'
				EXIT DO
			END IF
		LOOP WHILE (status = $STILL_ACTIVE)
'
		##LOCKOUT = $$TRUE
		CloseHandle (hProcess)
		##LOCKOUT = lockout
		##WHOMASK = whomask
		RETURN (status)
	ELSE
		##WHOMASK = whomask
		RETURN (processID)
	END IF
END FUNCTION
'
'
' #########################
' #####  XxxStdio ()  #####
' #########################
'
FUNCTION XxxStdio (in, out, err)
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	in = GetStdHandle ($$NTIN)
	out = GetStdHandle ($$NTOUT)
	err = GetStdHandle ($$NTERR)
	##WHOMASK = entryWHOMASK
	##LOCKOUT = entryLOCKOUT
END FUNCTION
'
'
' #############################
' #####  XxxWriteFile ()  #####
' #############################
'
'	In:				fileNumber		File Number
'						buffer
'						bytes					to be written
'						bytesWritten
'						overlapped		NULL
'	Out:			none--arg unchanged
'
'	Valid on console grids for now
'	xlibs.s calls XxxWriteFile() for stdout
'
FUNCTION  XxxWriteFile (fileNumber, buffer, bytes, bytesWritten, overlapped)
	EXTERNAL errno
	SHARED  FILE  fileInfo[]
'
	entryWHOMASK = ##WHOMASK
	entryLOCKOUT = ##LOCKOUT
'
	IFZ bytes THEN RETURN ($$TRUE)
	IF InvalidFileNumber(fileNumber) THEN
		IF (fileNumber != 1) THEN RETURN ($$FALSE)
		IFZ fileInfo[] THEN RETURN ($$FALSE)
		IFZ fileInfo[1].fileHandle THEN RETURN ($$FALSE)		' not initialized
	END IF
	fileHandle = fileInfo[fileNumber].fileHandle
	IF (fileHandle = -1) THEN						' Console Grid
		consoleGrid = fileInfo[fileNumber].consoleGrid
		IF (fileNumber = 1) THEN ##WHOMASK = 0
		text$ = NULL$(bytes)
		FOR i = 0 TO bytes - 1
			text${i} = UBYTEAT(buffer, i)
		NEXT i
		XuiSendMessage (consoleGrid, #Print, 0, 0, 0, 0, 0, @text$)
		IF (fileNumber = 1) THEN ##WHOMASK = entryWHOMASK
		XxxCheckMessages ()
		RETURN ($$FALSE)
	END IF
'
	##WHOMASK = 0
	##LOCKOUT = $$TRUE
	result = WriteFile (fileHandle, buffer, bytes, @bytesWritten, overlapped)
	##LOCKOUT = entryLOCKOUT
	##WHOMASK = entryWHOMASK
'
	IFZ result THEN
		errno = GetLastError ()
		XstSystemErrorToError (errno, @error)
		##ERROR = error
		RETURN ($$TRUE)
	END IF
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
	XgrRegisterCursor (@"Arrow",			@#cursorArrow)
	XgrRegisterCursor (@"UpArrow",		@#cursorArrowN)
	XgrRegisterCursor (@"Arrow",			@#cursorArrowNW)
	XgrRegisterCursor (@"SizeNS",			@#cursorArrowsNS)
	XgrRegisterCursor (@"SizeWE",			@#cursorArrowsWE)
	XgrRegisterCursor (@"SizeNWSE",		@#cursorArrowsNWSE)
	XgrRegisterCursor (@"SizeNESW",		@#cursorArrowsNESW)
	XgrRegisterCursor (@"SizeAll",		@#cursorArrowsAll)
	XgrRegisterCursor (@"CrossHair",	@#cursorCrosshair)
	XgrRegisterCursor (@"Arrow",			@#cursorDefault)
	XgrRegisterCursor (@"Wait",				@#cursorHourglass)
	XgrRegisterCursor (@"Insert",			@#cursorInsert)
	XgrRegisterCursor (@"No",					@#cursorNo)
	XgrRegisterCursor (@"Arrow",			@#defaultCursor)
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
' ##############################
' #####  CreateConsole ()  #####
' ##############################
'
FUNCTION  CreateConsole ()
'
	whomask = ##WHOMASK
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
'
	IFZ noConsole THEN
		confile = XxxOpen ("CON:", $$RD)			' Enable Read
		DO
			XgrMessagesPending (@count)
			IFZ count THEN EXIT DO
			XgrProcessMessages (-1)
		LOOP
	END IF
'
	##WHOMASK = whomask
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
'	Discussion:  Must be entry WHOMASK
'
FUNCTION  InvalidFileNumber (fileNumber)
	SHARED  FILE  fileInfo[]

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

eeeBadFileNumber:
	##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidArgument)
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
	entryWhomask = ##WHOMASK
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
	##WHOMASK = entryWhomask
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
	entryWhomask = ##WHOMASK
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
	##WHOMASK = entryWhomask
END SUB
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

'* Retrieve the full path and filename of the executable
' @return	The full path and filename of the executable.
FUNCTION XstGetProgramFileName$()
	file$ = NULL$(256)
	ret = GetModuleFileNameA(0, &file$, 256)
	file$ = LEFT$(file$, ret)
	RETURN (file$)
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


END PROGRAM
