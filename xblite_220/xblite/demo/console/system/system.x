'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A demo of calling various system functions
' in the Xst/Xsx libraries:
' ---
' XstGetCommandLineArguments ()
' XstGetCPUName ()
' XstGetCurrentDirectory ()
' XstGetDateAndTime ()
' XstGetDrives ()
' XstGetEndian ()
' XstGetEndianName ()
' XstGetEnvironmentVariables ()
' XstGetExecutionPathArray ()
' XstGetOSName ()
' XstGetOSVersion ()
' XstGetProgramFileName$ ()
' XstGetSystemTime ()
'
PROGRAM	"system"
VERSION	"0.0002"
CONSOLE
'
	IMPORT  "xsx"
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"xio"		' Console IO library
'
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, w, 150)
	XioCloseStdHandle (hStdOut)

'  XstGetSystemTime (@msec)

  XstGetCommandLineArguments (@argc, @argv$[])
	PRINT "***** XstGetCommandLineArguments *****"
	PRINT "Argument Count : "; argc
	IF argc > 0 THEN
		FOR i = 0 TO argc-1
			PRINT "argv$["; STRING$(i); "]       : "; argv$[i]
		NEXT i
	END IF
	PRINT

	cpu = XstGetCPUName (@id$, @cpuFamily, @model, @intelBrandID)
	PRINT "***** XstGetCPUName *****"
	PRINT "CPU            : "; cpu
	PRINT "ID String      : "; id$
	PRINT "CPU Family     : "; cpuFamily
	PRINT "CPU Model      : "; model
	PRINT "Intel Brand ID : "; intelBrandID
	PRINT

	XstGetCurrentDirectory (@directory$)
	PRINT "***** XstGetCurrentDirectory *****"
	PRINT "Current Dir    : "; directory$
	PRINT

	XstGetDateAndTime (@year, @month, @day, @weekDay, @hour, @minute, @second, @nsec)
	PRINT "***** XstGetDateAndTime *****"
	PRINT "Year           : "; year
	PRINT "Month          : "; month
	PRINT "Day            : "; day
	PRINT "Week Day       : "; weekDay
	PRINT "Hour           : "; hour
	PRINT "Minute         : "; minute
	PRINT "Second         : "; second
	PRINT "Nanos          : "; nsec
	PRINT

	XstGetDrives (@drives, @drive$[], @driveType[], @driveType$[])
	PRINT "***** XstGetDrives *****"
	PRINT "Drive Count    : "; drives
	FOR i = 0 TO drives-1
		PRINT "drive$[" + STRING$(i) + "]      : "; drive$[i]; " : "; STRING$(driveType[i]); " : "; driveType$[i]
	NEXT i
	PRINT

	XstGetEndian (@endian$$)
	PRINT "***** XstGetEndian *****"
	PRINT "Endian         : "; HEXX$ (endian$$,16)
	PRINT

	XstGetEndianName (@endian$)
	PRINT "***** XstGetEndianName *****"
	PRINT "Endian Name    : "; endian$
	PRINT

	XstGetEnvironmentVariables (@envp, @envp$[])
	PRINT " ***** XstGetEnvironmentVariables *****"
	PRINT "Env Var Count  : "; envp
	FOR i = 0 TO envp - 1
		PRINT "envp$["; STRING$(i); "]       : "; envp$[i]
	NEXT i
	PRINT

	XstGetExecutionPathArray (@path$[])
	PRINT "***** XstGetExecutionPathArray *****"
 	FOR i = 0 TO UBOUND(path$[])
		PRINT "path$["; STRING$(i); "]       : "; path$[i]
	NEXT i
	PRINT

	XstGetOSName (@os$)
	PRINT "***** XstGetOSName *****"
	PRINT "OS Name        : "; os$
	PRINT

	XstGetOSVersion (@major, @minor, @platformId, @version$, @platform$)
	PRINT " ***** XstGetOSVersion *****"
	PRINT "Major          : "; major
	PRINT "Minor          : "; minor
	PRINT "ID             : "; platformId
	PRINT "Version        : "; version$
	PRINT "Platform       : "; platform$
	PRINT

  fn$ = XstGetProgramFileName$ ()
	PRINT " ***** XstGetProgramFileName$ *****"
	PRINT "Program Name   : "; fn$
	PRINT

  XstGetSystemTime (@msec)
	PRINT " ***** XstGetSystemTime *****"
	PRINT "System Time    :"; msec; " msec"
	PRINT

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
END PROGRAM
