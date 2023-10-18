'
' ####################
' #####  PROLOG  #####
' ####################
'
' List all files in a directory.
'
PROGRAM "listfiles"
VERSION "0.0002"
CONSOLE
'
	IMPORT  "xst_s.lib"				' Standard library : required by most programs
	IMPORT  "xio_s.lib"				' Console input/ouput library
	IMPORT  "kernel32"				' kernel32.dll
	IMPORT  "msvcrt"					' msvcrt.dll

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION ListDir (dir$)
DECLARE FUNCTION GIANT CalcFileSize (ULONG high, ULONG low)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

	XioSetConsoleBufferSize (XioGetStdOut (), 0, 3200)
	initDir$ = "c:\\xblite"
	? "List of all files in " + initDir$
	ListDir (initDir$)
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION ListDir (dir$)

	WIN32_FIND_DATA fd
	STATIC count
	GIANT fs
	STATIC GIANT totalbytes
	
	IFZ dir$ THEN RETURN
	IF RIGHT$ (dir$, 1) = "\\" THEN dir$ = LEFT$(dir$, LEN(dir$)-1)
	s$ = dir$ + "\\*"
	h = FindFirstFileA (&s$, &fd)
  IF (h != $$INVALID_HANDLE_VALUE) THEN
		DO
			IF (strcmp (&".", &fd.cFileName) && strcmp (&"..", &fd.cFileName)) THEN
				IF (fd.dwFileAttributes & $$FILE_ATTRIBUTE_DIRECTORY) THEN
					s$ = dir$ + "\\" + fd.cFileName 
					? ">>>>> "; s$; " <<<<<"
					ListDir (s$)
				ELSE
					fs = CalcFileSize (fd.nFileSizeHigh, fd.nFileSizeLow)
					? dir$ + "\\" + fd.cFileName, " *** "; fs; " bytes ***"
					INC count
					totalbytes = totalbytes + fs
				END IF	
			END IF
		LOOP WHILE (FindNextFileA (h, &fd))
		FindClose (h) 
	END IF
	
	? count, "files found."; totalbytes; " total bytes."

END FUNCTION

FUNCTION GIANT CalcFileSize (ULONG high, ULONG low)

	$TWO32 = 4294967296
  RETURN (high * $TWO32 + low) 

END FUNCTION
END PROGRAM