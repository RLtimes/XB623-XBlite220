'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' Example of using FindDirs() function to
' search for directories.
'
PROGRAM	"finddirs"
VERSION	"0.0001"
CONSOLE
'
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT  "xsx"
	IMPORT  "kernel32"
'	IMPORT  "user32"
'	IMPORT  "gdi32"
'

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  FindDirs (dirStart$, recurse, @dir$[])
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' find directories

	startDir$ = "c:/xblite/"
	start = GetTickCount ()
	FindDirs (startDir$, $$TRUE, @dirs$[])
	end = GetTickCount () - start
	upp = UBOUND (dirs$[])

	PRINT upp+1; " directories found in "; startDir$; " in"; end; " msec"

' sort directories

	DIM order[]
	XstQuickSort (@dirs$[], @order[], 0, upp, $$SortIncreasing)

' list them

	FOR i = 0 TO upp
		PRINT dirs$[i]
	NEXT i

	a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
'
'
' #########################
' #####  FindDirs ()  #####
' #########################
'
' Find all directories within specified starting
' directory. If recurse is $$TRUE, then also find
' all subdirectories.
' IN  : dirStart$ - directory to begin search
'     : recurse - if $$TRUE, then find all subdirectories
' OUT : dir$[] - array of directories (unsorted - faster this way)
' NOTE: use XstQuickSort on dir$[] if sorted array is needed.
'
FUNCTION  FindDirs (dirStart$, recurse, @dir$[])

	FILEINFO  fileinfo[]

	path$ = XstPathString$ (@dirStart$)
	IFZ path$ THEN RETURN ($$TRUE)

	XstGetFileAttributes (@path$, @attribute)
	IFZ (attribute AND $$FileDirectory) THEN RETURN ($$TRUE)

	DIM new$[]
	udir = UBOUND (dir$[])

	pathend$ = RIGHT$ (path$, 1)
	attributeFilter = $$FileDirectory
	IF ((pathend$ != $$PathSlash$) AND (pathend$ != "/")) THEN path$ = path$ + $$PathSlash$

	XstGetFilesAndAttributes (path$ + "*", attributeFilter, @new$[], @fileinfo[])
	idir = udir + 1

' append names of matching directories to end of dir$[]

	IF new$[] THEN
		upper = UBOUND (new$[])
		DIM order[]
'		XstQuickSort (@new$[], @order[], 0, upper, $$SortIncreasing)
		udir = udir + upper + 1
		REDIM dir$[udir]
		FOR i = 0 TO upper
			IF new$[i] THEN
				dir$[idir] = path$ + new$[i]
				IF recurse THEN
					dir$ = dir$[idir]
					FindDirs (@dir$, recurse, @dir$[])
				END IF
				INC idir
			END IF
		NEXT i
	END IF

END FUNCTION
END PROGRAM
