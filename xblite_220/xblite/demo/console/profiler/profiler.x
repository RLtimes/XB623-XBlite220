'
' ####################
' #####  PROLOG  #####
' ####################
'
' A profiler program using proflib.dll to 
' time each function in a program. This will
' only work with XBLite v1.42 or higher.
'
' This instrumented profiler uses a compiler 
' option -p switch which inserts code into the 
' profiled program. 

' The code consists of adding penter() and pexit()
' functions to each function. See proflib.x.
'
' When the program is run, these functions monitor
' the start and end times for each function.
'
' The profiled program is copied to the \profiler folder
' and renamed program_p.x. Thus, the original file
' is never modified.
'
PROGRAM "profiler"
VERSION "0.0001"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
	IMPORT  "xsx"				' Extended standard library
	IMPORT  "xio"				' Console input/ouput library
	IMPORT  "proflib"		' profiler library (required)
	
'	IMPORT  "xst_s.lib"
'	IMPORT  "xsx_s.lib"
'	IMPORT  "xio_s.lib"
'	IMPORT  "proflib_s.lib"
	
	IMPORT  "gdi32"
	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll
	IMPORT  "winmm"


TYPE PROFILEDATA
	STRING * 128 .function
	STRING * 8   .address
	XLONG        .hits
	DOUBLE       .totaltime
	GIANT        .totalcycles
END TYPE

TYPE EXITDATA
	STRING * 8 .address
	STRING * 8 .parent
	GIANT      .entryTime
	GIANT      .startTime
	GIANT      .endTime
	XLONG      .stackIndex
	XLONG      .pexit   ' $$TRUE if pexit line
END TYPE

TYPE BUFFER
	STRING * 512 .buffer
END TYPE

'
DECLARE FUNCTION Entry ()
DECLARE FUNCTION Profiler ()
DECLARE FUNCTION Build (@file$)
DECLARE FUNCTION Shell (command$, workDir$, outputMode)
DECLARE FUNCTION GetFileExtension (fileName$, @file$, @ext$)
DECLARE FUNCTION FileExist (file$)
DECLARE FUNCTION Run ()
DECLARE FUNCTION Clean ()
DECLARE FUNCTION ParseOutput ()
DECLARE FUNCTION ParseMapFile ()
DECLARE FUNCTION PrintOutputToScreen ()

 ' Shell() output modes
$$Default = 0
$$Console = -1
$$BUFSIZE = 0x1000
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

hStdOut = XioGetStdOut ()
XioSetConsoleBufferSize (hStdOut, 80, 2000)

	Proflib ()				' initialize proflib.dll
	Profiler ()				' run profiler
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
' #########################
' #####  Profiler ()  #####
' #########################
'
FUNCTION Profiler ()

	SHARED progName$, ext$, path$
	SHARED profilePath$
	SHARED compPath$
	
	XstGetCommandLineArguments (@argCount, @argv$[])

	PRINT
	IF argCount < 2 THEN
    PRINT "> Usage: profiler filename.x"
    RETURN ($$TRUE)
  END IF
	
	pfn$ = XstGetProgramFileName$()
	XstGetPathComponents (pfn$, @profilePath$, "", "", "", 0)	
	
	fn$ = argv$[1]
	XstGetPathComponents (fn$, @path$, @drive$, @dir$, @filename$, @attributes)	

	GetFileExtension (@filename$, @progName$, @ext$)
	IFZ ext$ THEN PRINT "Profiler error: bad file name. " : RETURN ($$TRUE)	

	SELECT CASE LCASE$(ext$)
		CASE "x", "xl", "xbl" : 
		CASE ELSE : 
			PRINT "> Not an XBLite file."
			RETURN ($$TRUE)
	END SELECT

' get path to xblite folder, then to xblite compiler	
	compPath$ = INLINE$ ("Enter path of XBLite directory (default = c:\\xblite) >")
	IFZ compPath$ THEN compPath$ = "c:\\xblite"
	compPath$ = TRIM$ (compPath$)

' validate directory exists
	XstGetFileAttributes (compPath$, @attr)
	IFZ attr & $$FileDirectory THEN 
		PRINT "> Directory path error."
		GOTO error
	END IF

	x = RINSTR (compPath$, "\\")
	IF LEN(compPath$) <> x THEN compPath$ = compPath$ + "\\"
	compPath$ = compPath$ + "bin\\"
	
	IF Build (fn$) THEN GOTO error
	IF ParseMapFile () THEN GOTO error
	IF Run () THEN GOTO error
	
'	PrintOutputToScreen ()
	ParseOutput ()

	Clean ()

	PRINT "> profiler.exe finished."
	RETURN
	
error:
	Clean ()
	PRINT "> Error occurred. Program finished."
	RETURN ($$TRUE)

END FUNCTION
'
' ###################
' #####  Build  #####
' ###################
'
' Build profiled program.
' IN: file$ is name of *.x file to build.
'
FUNCTION Build (@file$)

	SHARED progName$, ext$, path$
	SHARED profilePath$
	SHARED compPath$
	SHARED exePath$
	
	' make a copy of program, but add one line to make
	' sure it uses custom makefile xprofile.xxx
	' The makefile xprofile.xxx adds the library callmon.lib to libraries
	' and adds the \PROFILE switch to the linker
	IF XstLoadString (file$, @text$) THEN
		PRINT "Error Build: unable to load "; file$
		RETURN ($$TRUE)
	END IF
	text$ = "MAKEFILE \"profiler.xxx\"" + text$
	
	' save file with new name using the profiler.exe path
	file$ = profilePath$ + progName$ + "_p" + "." + ext$
	IF XstSaveString (@file$, @text$) THEN RETURN ($$TRUE)
	
	' set xblite variables PATH, LIB, INCLUDE, XBLDIR
	pos = INSTR (compPath$, "bin")
	IF pos THEN
		 a$ = LEFT$ (compPath$, pos - 1)
		lib$ = a$ + "lib"
		include$ = a$ + "include"
		xbldir$ = LEFT$ (compPath$, pos - 2)
	END IF
	' set PATH
	XstGetEnvironmentVariable ("PATH", @curPATH$)
	XstSetEnvironmentVariable ("PATH", compPath$ + ";" + curPath$)
	' set LIB
	XstGetEnvironmentVariable ("LIB", @curLIB$)
	XstSetEnvironmentVariable ("LIB", lib$ + ";" + curLIB$)
	' set INCLUDE
	XstGetEnvironmentVariable ("INCLUDE", @curINCLUDE$)
	XstSetEnvironmentVariable ("INCLUDE", include$ + ";" + curINCLUDE$)
	' set XBLDIR
  XstGetEnvironmentVariable ("XBLDIR", @curXBLDIR$)
  XstSetEnvironmentVariable ("XBLDIR", xbldir$)
	
	' compile file
	XstGetPathComponents (file$, @fp$, "", "", "", 0)
	c$ = compPath$ + "xblite -p -conoff -bat " + file$
	Shell (c$, fp$, 0)
	PRINT "> Finished compiling "; file$; "."

	' build file
	' be sure make file exists
	GetFileExtension (file$, @f$, @x$)
	makePath$ = f$ + "." + "mak"
	IF FileExist (makePath$) THEN RETURN ($$TRUE)
	
	XstGetPathComponents (makePath$, @mp$, "", "", "", 0)
	c$ = compPath$ + "nmake " + makePath$
	Shell (c$, mp$, 0)
	
		' restore environ variables
	XstSetEnvironmentVariable ("PATH", curPath$)
	XstSetEnvironmentVariable ("LIB", curLIB$)
	XstSetEnvironmentVariable ("INCLUDE", curINCLUDE$)
	XstSetEnvironmentVariable ("XBLDIR", curXBLDIR$)

	' did we build the executable file
	exePath$ = f$ + "." + "exe"
	IF FileExist (exePath$) THEN
		PRINT "> Error building "; exePath$; "."
		RETURN ($$TRUE)
	END IF
	
	PRINT "> Finished building  "; exePath$; "."
	
END FUNCTION
'
' ###################
' #####  Shell  #####
' ###################
' 
' PURPOSE	: Shell() is a replacement for the SHELL
' intrinsic function. Use only for commands
' that do not expect user input.
' Do not use to shell batch *.bat files.
' Shell() captures output from the shelled program.
' It also allows a working directory to be specified,
' and returns the exit code for the shelled program.
' 
' IN	: command$ - 	the command to be executed, including a path if necessary,
' and any switches or parameters required by the command.
' : workDir$ -  the working directory for the command$, if any. Can be null ("").
' : outputMode - determines how output is treated. If outputMode = $$Console (-1),
' then captured output is printed on the console as it is generated,
' as well as being stored in the output$ variable.
' If outputMode = $$Default (0), output is not printed.
' Any other value is interpreted as a window handle (hWnd),
' to which the output is sent using SetWindowTextA and UpdateWindow.

' OUT	: output$  -  the captured output generated when the command is executed,
' which would normally be sent to a DOS window.
' 
' Shell() function written by Ken Minogue - May 2002
' 
FUNCTION Shell (command$, workDir$, outputMode)

	PROCESS_INFORMATION procInfo
	STARTUPINFO startInfo
	SECURITY_ATTRIBUTES saP, saT, pa
	SHARED hStdoutRd, hStdoutWr, hChild

	SHARED BUFFER buff[]

	output$ = ""
	IFZ command$ THEN RETURN

	' allow handles to be inherited
	saT.inherit = 1
	saP.inherit = 1
	pa.inherit = 1
	saT.length = SIZE (SECURITY_ATTRIBUTES)
	saP.length = SIZE (SECURITY_ATTRIBUTES)
	pa.length = SIZE (SECURITY_ATTRIBUTES)
	saT.securityDescriptor = NULL
	saP.securityDescriptor = NULL
	pa.securityDescriptor = NULL

	' Create a pipe that will be used for the child process's STDOUT.
	' This returns two handles:
	' hStdoutRd is a handle to the read end of the pipe
	' hStdoutWr is a handle to the write end of the pipe
	IFZ CreatePipe (&hStdoutRd, &hStdoutWr, &pa, 0) THEN
		' PRINT "Pipe creation failed"
		RETURN ($$TRUE)
	END IF

	' Create the child process, directing STDOUT and STDERR to the pipe's write handle
	RtlZeroMemory (&startInfo, SIZE (STARTUPINFO))
	startInfo.cb = SIZE (STARTUPINFO)
	startInfo.dwFlags = $$STARTF_USESHOWWINDOW OR $$STARTF_USESTDHANDLES
	startInfo.wShowWindow = $$SW_HIDE		' don't show the DOS console window
	startInfo.hStdInput = GetStdHandle ($$STD_INPUT_HANDLE)
	startInfo.hStdOutput = hStdoutWr
	startInfo.hStdError = hStdoutWr
	IFZ CreateProcessA (NULL, &command$, &saP, &saT, 1, 0, 0, &workDir$, &startInfo, &procInfo) THEN
		' PRINT "Create process failed"
		GOSUB CloseHandles
		RETURN ($$TRUE)
	END IF

	' optional - wait for process to finish
'	res = WaitForSingleObject (procInfo.hProcess, $$INFINITE)

	' handle for child process, used to get exit code.
	hChild = procInfo.hProcess

	' The parent's write handle to the pipe must be closed,
	' or ReadFile() will never return FALSE.
	IFZ CloseHandle (hStdoutWr) THEN
		' PRINT "Close handle failed"
		hStdoutWr = 0
		GOSUB CloseHandles
		RETURN ($$TRUE)
	END IF
	hStdoutWr = 0

	' Read output from the child process. ReadFile() returns FALSE
	' when the child process closes the write handle to the pipe, or terminates.
	
	' captured output is copied to string buffer array buff[]

	DIM buff[511]
	i = 0

	DO
		ret = ReadFile (hStdoutRd, &buff[i].buffer, 512, &bytesRead, 0)
		IF (!ret || bytesRead = 0) THEN EXIT DO
		INC i
		IF (UBOUND(buff[]) >= i ) THEN REDIM buff[2*i]
	LOOP

	REDIM buff[i-1]
	
	' child process is finished.
	GetExitCodeProcess (hChild, &exitCode)
	GOSUB CloseHandles
	RETURN (exitCode)

SUB CloseHandles
	IF hStdoutRd THEN CloseHandle (hStdoutRd)
	IF hStdoutWr THEN CloseHandle (hStdoutWr)
	IF hChild THEN CloseHandle (hChild)
	IF procInfo.hThread THEN CloseHandle (procInfo.hThread)
	hStdoutRd = 0
	hStdoutWr = 0
	hChild = 0
END SUB

END FUNCTION
' 
' #################################
' #####  GetFileExtension ()  #####
' #################################
' 
' Get filename extension (without .) and
' filename without extension.
' 
FUNCTION GetFileExtension (fileName$, @file$, @ext$)

	ext$ = ""
	file$ = ""
	IFZ fileName$ THEN RETURN ($$TRUE)

	f$ = fileName$
	f$ = TRIM$ (f$)
	fPos = RINSTR (f$, ".")

	IF fPos THEN
		ext$ = RIGHT$ (f$, LEN (f$) - fPos)
		file$ = LEFT$ (f$, fPos - 1)
		RETURN
	END IF

	RETURN ($$TRUE)

END FUNCTION
' 
' ##########################
' #####  FileExist ()  #####
' ##########################
' 
' Return 0 on success, -1 on failure (file doesn't exist)
'
FUNCTION FileExist (file$)

	WIN32_FIND_DATA fd

	IF file$ THEN
		hFound = FindFirstFileA (&file$, &fd)
		IF hFound = $$INVALID_HANDLE_VALUE THEN RETURN ($$TRUE)
		FindClose (hFound)
		IF (fd.dwFileAttributes AND $$FILE_ATTRIBUTE_DIRECTORY) <> $$FILE_ATTRIBUTE_DIRECTORY AND (fd.dwFileAttributes AND $$FILE_ATTRIBUTE_TEMPORARY) <> $$FILE_ATTRIBUTE_TEMPORARY THEN
			RETURN 
		END IF
	END IF
	RETURN ($$TRUE)

END FUNCTION
'
' #################
' #####  Run  #####
' #################
'
' Run profiled program and capture output.
'
FUNCTION Run ()

	SHARED exePath$
'	SHARED PROFILEDATA pfd[]

	cl$ = INLINE$ ("Enter any command line switches >")
	cl$ = TRIM$(cl$)
	XstGetPathComponents (exePath$, @ep$, "", "", "", 0)
	c$ = exePath$ 
	IF cl$ THEN c$ = c$ + " " + cl$
	out$ = ""
	
	PRINT "> Executing "; exePath$
	Shell (c$, ep$, 0)
	
	PRINT "> Finished running "; exePath$; "."
	
	' commandline option to print out screen capture?
'	PRINT

END FUNCTION
'
' ###################
' #####  Clean  #####
' ###################
'
' Delete all created files.
'
FUNCTION Clean ()

	SHARED progName$, ext$, path$
	SHARED profilePath$
	
	filter$ = progName$ + "_p.*" 
	XstFindFiles (profilePath$, filter$, 0, @file$[])
	IFZ file$[] THEN RETURN
	
	upp = UBOUND (file$[])
	FOR i = 0 TO upp
		XstDeleteFile (file$[i])
	NEXT i

END FUNCTION
'
' #########################
' #####  ParseOutput  #####
' #########################
'
' Parse the captured data and total
' each function's elapsed time.
'
FUNCTION ParseOutput ()

	SHARED PROFILEDATA pfd[]
	SHARED BUFFER buff[]
	SHARED EXITDATA edata[]
	
	TICKS endTime, startTime, entryTime, tps, dif
	DOUBLE time
	
	$SP = " "

	IFZ buff[] THEN RETURN ($$TRUE)
	IFZ pfd[] THEN RETURN ($$TRUE)
	
	tps = GetFreq ()

' total the time spent in each function	
	upp = UBOUND (buff[])
	u   = UBOUND (pfd[])
	
	DIM edata[upp]
	DIM stackAddr$[512]
	
	FOR i = 0 TO upp
		index = 0 : done = 0
		word1$ = "" : word2$ = "" : word3$ = "" : word4$ = "" : word5$ = ""
		tmp$ = RTRIM$(buff[i].buffer)
		IFZ tmp$ THEN DO NEXT

		' get current stack index from penter() tab count
		stackCount = XstTally (@tmp$, "\t")
		upper = UBOUND (stackAddr$[])
		IF stackCount >= upper THEN REDIM stackAddr$[upper<<1]

		pos = INSTR (tmp$, "penter:")
		IF pos THEN 
			' set stack address for current stack index
			stackAddr$[stackCount] = MID$ (tmp$, pos+8)
		END IF
		
		pos = INSTR (tmp$, "pexit:")
		IFZ pos THEN DO NEXT
'		IF pos > 1 THEN tmp$ = MID$ (tmp$, pos)
		
	' get funcAddr, parentAddr, entryTime, startTime, endTime	
		
		word1$ = XstNextField$ (tmp$, @index, @done)
		IF !done THEN word2$ = XstNextField$ (tmp$, @index, @done)	' function address
		IF !done THEN word3$ = XstNextField$ (tmp$, @index, @done)	' entryTime
		IF !done THEN word4$ = XstNextField$ (tmp$, @index, @done)	' startTime
		IF !done THEN word5$ = XstNextField$ (tmp$, @index, @done)	' endTime
		
		endTime   = GIANT(word5$)
		startTime = GIANT(word4$)
		entryTime = GIANT(word3$)
		
		edata[i].address   = word2$
		IF stackCount-1 >= 0 THEN
			edata[i].parent  = stackAddr$[stackCount-1]
		END IF
		edata[i].entryTime = entryTime
		edata[i].startTime = startTime
		edata[i].endTime   = endTime
		edata[i].stackIndex = stackCount
		edata[i].pexit     = $$TRUE

'PRINT i, stackCount, edata[i].address;; edata[i].parent 
		
		dif = endTime - startTime
		time = DOUBLE(dif)/(DOUBLE(tps)/1000.0) 
		
		FOR j = 0 TO u
			IF pfd[j].address = word2$ THEN
				INC pfd[j].hits
				pfd[j].totaltime   = pfd[j].totaltime + time
				pfd[j].totalcycles = pfd[j].totalcycles + dif
				EXIT FOR
			END IF
		NEXT j
	NEXT i

	PRINT
	PRINT "Function Name        Address  Total Time (ms)      Total Ticks     Hits"
	PRINT "========================================================================"

	FOR i = 0 TO u
		IFZ pfd[i].hits THEN DO NEXT 
		ffn$ 		= FORMAT$ ("<<<<<<<<<<<<<<<<<<<<", pfd[i].function)
		faddr$ 	= FORMAT$ (">>>>>>>>",             pfd[i].address)
		ftt$ 		= FORMAT$ ("#######.#######",      pfd[i].totaltime)
		ftc$ 		= FORMAT$ ("################",     pfd[i].totalcycles)
		fhits$ 	= FORMAT$ ("########",             pfd[i].hits)
		PRINT ffn$; $SP; faddr$; $SP; ftt$; $SP; ftc$; $SP; fhits$ 
		   
'		PRINT pfd[i].function, pfd[i].address, pfd[i].totaltime, pfd[i].totalcycles, pfd[i].hits
	NEXT i
	PRINT

END FUNCTION
'
' ##########################
' #####  ParseMapFile  #####
' ##########################
'
' Build an array of function names and addresses
' from generated .map file (from /PROFILE switch).
'
FUNCTION ParseMapFile ()

	SHARED progName$, ext$, path$
	SHARED profilePath$
	
	SHARED PROFILEDATA pfd[]
	
	fmap$ = profilePath$ + progName$ + "_p.map" 
	
	IF FileExist (fmap$) THEN
		PRINT "> Cannot find "; fmap$; "."
		RETURN ($$TRUE)
	END IF
	
	XstLoadStringArray (fmap$, @text$[])
	
	IFZ text$[] THEN 
		PRINT "> Empty file: "; fmap$; "."
		RETURN ($$TRUE)
	END IF
	
	DIM pfd[256]
	count = -1
	
	upp = UBOUND(text$[])
	FOR i = 0 TO upp
		index = 0 : done = 0
		word1$ = "" : word2$ = "" : word3$ = ""
		tmp$ = TRIM$(text$[i])
		IFZ tmp$ THEN DO NEXT
		word1$ = XstNextField$ (tmp$, @index, @done)
		IF !done THEN word2$ = XstNextField$ (tmp$, @index, @done)
		IF !done THEN word3$ = XstNextField$ (tmp$, @index, @done)
		
		IF word1$ == "" || word2$ == ""  || word3$ = "" THEN DO NEXT
		IF word2${0} <> '_' THEN DO NEXT
		IF word2${1} == '_' THEN DO NEXT

		SELECT CASE word2$
			CASE "_WinMain", "_WinMain@16", "_main", "_Xit@4", "_XxxTerminate@0", "_XxxXstLoadLibrary@4", "_GetProcAddress@8", "_penter@0", "_pexit@0", "_XxxInline$@4" : 
			CASE ELSE :
				INC count
				up = UBOUND(pfd[])
				IF count > up THEN
					REDIM pfd[up<<1]
				END IF
				word2$ = RIGHT$ (word2$, LEN(word2$)-1)			' remove _ char
				pos = INSTR (word2$, "@")
				IF pos THEN word2$ = LEFT$(word2$, pos-1)		' remove chars after @
				pos = INSTR (word2$, ".")
				IF pos THEN word2$ = LEFT$(word2$, pos-1)   ' remove characters following .
					
				pfd[count].function = word2$
				pfd[count].address = UCASE$(word3$)
		END SELECT
	NEXT i
	
	REDIM pfd[count]

	PRINT
	PRINT "      Function Name                 Address"
	PRINT "============================================"
	FOR i = 0 TO count
		PRINT i, TAB(6), pfd[i].function, TAB(36), pfd[i].address
	NEXT i
	PRINT

END FUNCTION
'
' #################################
' #####  PrintOutputToScreen  #####
' #################################
'
'
'
FUNCTION PrintOutputToScreen ()

	SHARED BUFFER buff[]
	
	IFZ buff[] THEN RETURN
	
	upp = UBOUND (buff[])
	FOR i = 0 TO upp
		PRINT RTRIM$(buff[i].buffer)
	NEXT i

END FUNCTION

END PROGRAM

