'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of using Shell(), a replacement for
' the SHELL intrinsic function. Shell() can
' capture the standard output from the child
' process by calling CreatePipe. This allows
' Shell() to redirect the child's STDOUT so
' it can be read by Shell(). The shelled program's
' DOS console window is not displayed.
'
PROGRAM	"shell"
VERSION "0.0002"
CONSOLE

IMPORT  "xst"
IMPORT	"gdi32"
IMPORT	"user32"
IMPORT	"kernel32"


EXPORT
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Shell (command$, workDir$, output$, outputMode)

'output modes
$$Default =  0
$$Console = -1
END EXPORT

$$BUFSIZE 							= 0x1000
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'	Entry function must be present to make
' a proper DLL, even though it does nothing.
'
FUNCTION  Entry ()

	IF LIBRARY (0) THEN RETURN

' NOTE: make sure that shelltest.exe exists
' in the same directory as shell.exe while
' running shell.exe demo. Run shelltest.bat
' to create shelltest.exe.

	PRINT " ********************************* "
	PRINT " ***** Running shelltest.exe ***** "
	PRINT " ********************************* "
	PRINT

'	command$ = "notepad.exe"
  command$ = "shelltest.exe"
	workDir$ = ""
	outputMode = $$Console
	exitCode = Shell (command$, workDir$, @output$, outputMode)

	PRINT
	PRINT " ***** Shell finished ***** "
	PRINT "output$ = "; output$
	PRINT
	PRINT "exitCode = "; exitCode
	PRINT

	a$ = INLINE$ ("Press any key to quit >")

END FUNCTION
'
'
' ######################
' #####  Shell ()  #####
' ######################
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
'										and any switches or parameters required by the command.
' 		: workDir$ -  the working directory for the command$, if any. Can be null ("").
' 		: outputMode - determines how output is treated. If outputMode = $$Console (-1),
' 									then captured output is printed on the console as it is generated,
'										as well as being stored in the output$ variable.
'										If outputMode = $$Default (0), output is not printed.
'										Any other value is interpreted as a window handle (hWnd),
'										to which the output is sent using SetWindowTextA and UpdateWindow.

' OUT	: output$  -  the captured output generated when the command is executed,
'										which would normally be sent to a DOS window.
'
' Shell() function written by Ken Minogue - May 2002
'
FUNCTION  Shell (command$, workDir$, output$, outputMode)

	PROCESS_INFORMATION procInfo
	STARTUPINFO startInfo
	SECURITY_ATTRIBUTES saP, saT, pa
	SHARED hStdoutRd, hStdoutWr, hChild
	
	output$ = ""
	IFZ command$ THEN RETURN

' allow handles to be inherited
	saT.inherit = 1
  saP.inherit = 1
  pa.inherit = 1
  saT.length = SIZE(SECURITY_ATTRIBUTES)
  saP.length = SIZE(SECURITY_ATTRIBUTES)
  pa.length = SIZE(SECURITY_ATTRIBUTES)
  saT.securityDescriptor = NULL
  saP.securityDescriptor = NULL
  pa.securityDescriptor = NULL

' Create a pipe that will be used for the child process's STDOUT.
' This returns two handles:
' hStdoutRd is a handle to the read end of the pipe
' hStdoutWr is a handle to the write end of the pipe
	IFZ CreatePipe (&hStdoutRd, &hStdoutWr, &pa, 0) THEN
		PRINT "Pipe creation failed"
		RETURN ($$TRUE)
	END IF

' Create the child process, directing STDOUT and STDERR to the pipe's write handle
  RtlZeroMemory (&startInfo, SIZE (STARTUPINFO))
	startInfo.cb 					= SIZE (STARTUPINFO)
	startInfo.dwFlags 		= $$STARTF_USESHOWWINDOW OR $$STARTF_USESTDHANDLES
	startInfo.wShowWindow = $$SW_HIDE   		' don't show the DOS console window
	startInfo.hStdInput 	= GetStdHandle ($$STD_INPUT_HANDLE)
	startInfo.hStdOutput 	= hStdoutWr
	startInfo.hStdError 	= hStdoutWr
	IFZ CreateProcessA (NULL, &command$, &saP, &saT, 1, 0, 0, &workDir$, &startInfo, &procInfo) THEN
		PRINT "Create process failed"
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
		PRINT "Close handle failed"
		hStdoutWr = 0
		GOSUB CloseHandles
		RETURN ($$TRUE)
	END IF
	hStdoutWr = 0

' Read output from the child process. ReadFile() returns FALSE
' when the child process closes the write handle to the pipe, or terminates.
	DO
		chBuf$ = NULL$ ($$BUFSIZE)
		ret = ReadFile (hStdoutRd, &chBuf$, $$BUFSIZE, &bytesRead, 0)
		IF (!ret || (bytesRead == 0)) THEN EXIT DO
		buf$ = CSTRING$ (&chBuf$)
		output$ = output$ + buf$
		SELECT CASE outputMode
			CASE $$Default  :
			CASE $$Console	: PRINT buf$;
			CASE ELSE       :
				hWnd = outputMode
				IF IsWindow (hWnd) THEN
					SendMessageA (hWnd, $$WM_SETTEXT, 0, &output$)
					UpdateWindow (hWnd)
				END IF
		END SELECT
	LOOP

'child process is finished.
	GetExitCodeProcess (hChild, &exitCode)
	GOSUB CloseHandles
	RETURN (exitCode)

SUB CloseHandles
	IF hStdoutRd	THEN CloseHandle (hStdoutRd)
	IF hStdoutWr	THEN CloseHandle (hStdoutWr)
	IF hChild 		THEN CloseHandle (hChild)
	IF procInfo.hThread THEN CloseHandle (procInfo.hThread)
	hStdoutRd = 0
	hStdoutWr = 0
	hChild = 0
END SUB

END FUNCTION
END PROGRAM
