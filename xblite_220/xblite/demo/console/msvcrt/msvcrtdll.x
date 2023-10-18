'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' C function library msvcrt.dll examples.
'
PROGRAM	"msvcrtdll"
VERSION	"0.0002"
CONSOLE
'
	IMPORT  "xsx"		' Extended Standard library
	IMPORT	"xst"   ' Standard library : required by most programs
	IMPORT	"xio"
	IMPORT  "msvcrt"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  TestStringFunctions ()
DECLARE CFUNCTION  compare (value1Addr, value2Addr)
DECLARE FUNCTION  TestStdLibFunctions ()
DECLARE FUNCTION  TestMathFunctions ()
DECLARE FUNCTION  TestTimeFunctions ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	SHARED hStdOut

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 250)

	TestMathFunctions ()
	TestStdLibFunctions ()
	TestStringFunctions ()
	TestTimeFunctions ()

	a$ = INLINE$ ("Press RETURN to QUIT >")
	XioCloseStdHandle (hStdOut)

END FUNCTION
'
'
' ####################################
' #####  TestStringFunctions ()  #####
' ####################################
'
FUNCTION  TestStringFunctions ()

	SHARED hStdOut

' test some string functions
' string.h

	XioClearConsole (hStdOut)

' strlen ()
	PRINT "HELLO strlen () ="; strlen(&"HELLO")

' strcpy ()
	string1$ = "Copy THIS!"
	string2$ = NULL$(strlen(&string1$))
	strcpy(&string2$, &string1$)
	PRINT string2$

' strcmp ()
	a$ = "aaabbb"
	b$ = "bbbccc"
	c$ = "aaabbb"
	x = strcmp(&a$, &b$)
	y = strcmp(&b$, &c$)
	z = strcmp(&a$, &c$)
	PRINT x, y, z

' strcat (), strncat ()
	b$ = " thing to say"
	a$ = "What a strange" + NULL$(strlen(&b$))		' pad a$ with enough space to handle appending b$
	strcat(&a$, &b$)
	PRINT a$
	b$ = " thing to say"
	a$ = "What a strange" + NULL$(6)							' pad a$ with enough space to handle appending 6 chars
	strncat(&a$, &b$, 6)
	PRINT a$

' strchr (), strrchr ()
	a$ = "stranger"
	addr1 = strchr(&a$, ASC("r"))
	PRINT addr1, UBYTEAT(addr1), CHR$(UBYTEAT(addr1))
	addr2 = strrchr(&a$, ASC("r"))
	PRINT addr2, UBYTEAT(addr2), CHR$(UBYTEAT(addr2))

' strstr (), strpbrk ()
	a$ = "hello"
	b$ = "lo"
	c$ = "aeiou"
	addr = strstr(&a$, &b$)
	PRINT addr, UBYTEAT(addr), CHR$(UBYTEAT(addr)), CSTRING$(addr)
	addr = strpbrk(&a$, &c$)
	PRINT addr, UBYTEAT(addr), CHR$(UBYTEAT(addr)), CSTRING$(addr)

' strtok ()														' strtok basically substitutes a NULL char for each b$ it finds in a$
	a$ = "Get back to work right now"		' string to parse
	b$ = " "														' string used to split a$
	tok = strtok(&a$, &b$)							' strtok returns address of first char in first token
	IF tok THEN PRINT tok, UBYTEAT(tok), CHR$(UBYTEAT(tok)), a$, "token="; CSTRING$(tok)
	DO UNTIL tok = 0
		tok = strtok(0, &b$)							' subsequent calls to strtok with a$ = NULL return address of first char of subsequent tokens
		IF tok THEN PRINT tok, UBYTEAT(tok), CHR$(UBYTEAT(tok)), a$, "token="; CSTRING$(tok)
	LOOP

	DO UNTIL done
		token$ = XstNextCLine$ (&a$, @index, @done)	'extract marked tokens from a$
		PRINT token$, index, done
	LOOP

'_strset ()
'fill a string with character
	string$ = SPACE$(20)
	char = ASC("x")
	_strset(&string$, char)
	PRINT string$

'_strupr ()
'convert string to uppercase
	_strupr (&string$)
	PRINT string$

'_strrev ()
'reverse a string
	string$ = "abcdefghijk"
	_strrev (&string$)
	PRINT string$

'_strnset ()
'fill a string with a char to a given length
	_strnset (&string$, ASC("9"), 5)
	PRINT string$

	a$ = INLINE$ ("Press any key to continue >")

END FUNCTION
'
'
' ########################
' #####  compare ()  #####
' ########################
'
CFUNCTION  compare (value1Addr, value2Addr)

	x = XLONGAT(value1Addr)
	y =	XLONGAT(value2Addr)

	SELECT CASE TRUE
		CASE x < y: RETURN -1
		CASE x = y: RETURN 0
		CASE x > y: RETURN 1
	END SELECT

END FUNCTION
'
'
' ####################################
' #####  TestStdLibFunctions ()  #####
' ####################################
'
FUNCTION  TestStdLibFunctions ()

	STAT stat
	SHARED hStdOut

	XioClearConsole (hStdOut)

'test msvcrt.dll functions (stdlib.h)

'test random number generators
'srand() and rand()
	PRINT " ***** rand () *****"
	srand (123245)
	FOR i = 0 TO 9
		x# = rand()
		PRINT "rand="; x#, " uni="; x#/32767.0
	NEXT i
	PRINT

'string conversion

	str1$ = "-100"
	str2$ = "55.444"
	str3$ = "      1234"
	str4$ = "123four"
	str5$ = "invalid123"
	str6$ = "1234567890"
	str7$ = "0xFFFF"

	i = atoi(&str1$)			' i = -100
	f# = atof(&str2$)			' f# = 55.44
	j = atoi(&str3$)			' j = 1234
	k = atoi(&str4$)			' k = 123
	l = atoi(&str5$)			' l = 0
	m = atol(&str6$)			' m = 1234567890
	n = strtol(&str7$, $$NULL, 16)	'n = 65535 strtol () converts a string to a long integer, here hex to decimal
	PRINT i, f#, j, k, l, m, n

'convert floating point number into a string
' _ecvt ()
	value# = -123.456789		' number to convert to string
	ndigits = 6							' number of significant digits, converted number is rounded to ndigits of precision
													' sign - returns sign of number (0 = positive, 1 = negative)
													' dec  - returns position of the decimal point, relative to the start of the string of digits
	str = _ecvt (value#, ndigits, &dec, &sign)
	num$ = CSTRING$(str)
	PRINT value#, num$, dec, sign

'gcvt ()
'convert a floating-point number into a string
	number$ = NULL$(80)
	_gcvt (123.456789, 5, &number$)
	PRINT CSIZE$(number$)

' The _ultoa() function converts the unsigned binary
' integer value into the equivalent string in base
' radix notation, storing the result in the character
' array pointed to by buffer. A null character is
' appended to the result. The size of buffer must be
' at least 33 bytes when converting values in base 2.

	FOR base = 2 TO 16 STEP 2
		integer$ = NULL$(33)
		_ultoa (7654321, &integer$, base)
		PRINT base, CSIZE$(integer$)
	NEXT base

'_fullpath ()
' return the full pathname of a file
	path$ = NULL$(256)
	file$ = "xblite.exe"
	_fullpath (&path$, &file$, SIZE(path$))
	path$ = CSIZE$(path$)
	PRINT "fullpath: "; path$

'_splitpath ()
' split a pathname into node, directory, file name, and extension

	root$  = NULL$(256)
	dir$   = NULL$(256)
	fname$ = NULL$(256)
	ext$   = NULL$(256)
	_splitpath (&path$, &root$, &dir$, &fname$, &ext$)
	PRINT "root    : "; CSIZE$(root$)
	PRINT "dir     : "; CSIZE$(dir$)
	PRINT "fname   : "; CSIZE$(fname$)
	PRINT "ext     : "; CSIZE$(ext$)

'_getcwd ()
'get current working directory
	cwdir$ = NULL$(256)
	_getcwd (&cwdir$, 256)
	PRINT "current working directory: "; CSIZE$(cwdir$)

'_stat ()
'get information on a file or directory
	file$ = "c:\\xblite\\demo\\console\\msvcrt\\msvcrtdll.x"
	ret = _stat (&file$, &stat)
	PRINT "_stat () ret ="; ret
	PRINT "st_dev   ="; stat.st_dev
	PRINT "st_ino   ="; stat.st_ino
	PRINT "st_mode  ="; stat.st_mode
	PRINT "st_nlink ="; stat.st_nlink
	PRINT "st_uid   ="; stat.st_uid
	PRINT "st_gid   ="; stat.st_gid
	PRINT "st_rdev  ="; stat.st_rdev
	PRINT "st_size  ="; stat.st_size
	PRINT "st_atime ="; stat.st_atime
	PRINT "st_mtime ="; stat.st_mtime
	PRINT "st_ctime ="; stat.st_ctime

	mtimeAddr = ctime (&stat.st_mtime)				' get string pointer to modified time stamp
	mtimeStamp$ = CSTRING$(mtimeAddr)
	PRINT "Modified time : "; mtimeStamp$

'sorting
	DIM array[99]
	upper = UBOUND (array[])
	srand (12123)
	FOR i = 0 TO upper
		array[i] = rand()
	NEXT i
'
	qsort (&array[0], upper+1, 4, &compare())
	PRINT
	PRINT "***** qsort *****"
	FOR i = 0 TO upper
		PRINT array[i]
	NEXT i

	a$ = INLINE$ ("Press any key to continue >")

END FUNCTION
'
'
' ##################################
' #####  TestMathFunctions ()  #####
' ##################################
'
FUNCTION  TestMathFunctions ()

	SHARED hStdOut

' test msvcrt.dll functions (math.h)

LDIV_T min_sec

XioClearConsole (hStdOut)

PRINT _hypot (3.0, 4.0)
PRINT cos(0)
PRINT sin($$M_PI/2.0)
PRINT tan($$M_PI/4.0)
PRINT sqrt (144)
PRINT fabs (-1.23456)
PRINT exp (1.0)
PRINT ceil (5.5555)
PRINT floor (5.555)
PRINT fmod (5, 2)
PRINT labs (-456789)
PRINT pow (2, 32)
PRINT ldexp (5.0, 4)	'x * 2^y
PRINT log (100)
PRINT log10 (100)

'ldiv () does not seem to work correctly
'	min_sec = ldiv (130, 60)
'	PRINT "minutes:"; min_sec.quot
'	PRINT "seconds:"; min_sec.rem

a$ = INLINE$ ("Press any key to continue >")

END FUNCTION
'
'
' ##################################
' #####  TestTimeFunctions ()  #####
' ##################################
'
FUNCTION  TestTimeFunctions ()

'test time functions (time.h)

	SHARED hStdOut
	TIMEB timeb
	TM tmbuf, gmbuf

	XioClearConsole (hStdOut)

'time ()
'determine the current calendar time

	time_of_day = time (0)
	PRINT "seconds since 00:00:00 GMT, Jan. 1, 1970:"; time_of_day

'ctime ()
' convert calender time to local time
' ctime () convert a time in seconds, since 00:00:00 January 1, 1970
' to an ASCII string in the form generated by the asctime () function.

	tsAddr = ctime (&time_of_day)				' get string pointer to timestamp
	timeStamp$ = CSTRING$(tsAddr)
	PRINT timeStamp$

'localtime ()
'convert calendar time to local time

	tmbufAddr = localtime (&time_of_day)		' convert time_of_day into struct TM tmbuf
	PRINT "tmbufAddr="; tmbufAddr, "size of tmbuf="; SIZE(tmbuf)
	memcpy (&tmbuf, tmbufAddr, SIZE(tmbuf))	' copy TM struct from mem to tmbuf
	PRINT "seconds:"; tmbuf.tm_sec
	PRINT "minutes:"; tmbuf.tm_min
	PRINT "hour   :"; tmbuf.tm_hour
	PRINT "day    :"; tmbuf.tm_mday
	PRINT "month  :"; tmbuf.tm_mon
	PRINT "year   :"; tmbuf.tm_year
	PRINT "weekday:"; tmbuf.tm_wday
	PRINT "yearday:"; tmbuf.tm_yday
	PRINT "isdst  :"; tmbuf.tm_isdst

'asctime ()
'convert time information to a string
'this string has the form shown in the following example:
' Sat Mar 21 15:58:27 1987\n\0

	tsPtr = asctime (&tmbuf)								' convert TM tmbuf struct to 26 char time stamp string
	PRINT CSTRING$(tsPtr)

'gmtime ()
'convert time_of_day to greenwich mean time or universal time
'this does not take into effect any daylight savings time

	gmbufAddr = gmtime (&time_of_day)				' convert time_of_day into struct TM gmbuf
	memcpy (&gmbuf, gmbufAddr, SIZE(gmbuf))	' copy TM struct from mem to gmbuf
	gmstPtr = asctime (&gmbuf)							' convert gmbuf into gmt timestamp
	gmtimeStamp$ = CSTRING$(gmstPtr)				' get timestamp string from address
	gmtimeStamp$ = LEFT$(gmtimeStamp$, LEN(gmtimeStamp$)-1) + " GMT"	' remove CR and add GMT
	PRINT gmtimeStamp$

'strftime ()
'format a string time/date
	date$ = NULL$(100)
	strftime (&date$, LEN(date$), &"Today is %A %B %d, %Y at %I:%M:%S %p.", &tmbuf)
	PRINT CSIZE$(date$)

'_ftime ()
'get the current time store it in a TIMEB struct
	_ftime(&timeb)												' fill timeb struct with current local time
	PRINT "timeb Adrr :"; &tm
	PRINT "timeb size :"; SIZE(tb)
	PRINT "time       :"; timeb.time			' current calender time
	PRINT "millisec   :"; timeb.millitm		' plus millisecs
	PRINT "timezone   :"; timeb.timezone	' number of minutes behind GMT
	PRINT "dstflag    :"; timeb.dstflag		' daylight savings time flag (0 = not currently applied, 1 = currently applied)

'print a timestamp from timeb.time
	tsAddr = ctime (&timeb.time)					' get string pointer to timestamp
	timeStamp$ = CSTRING$(tsAddr)
	PRINT timeStamp$

'_strtime ()
'copy the current time into a string in format HH:MM:SS
	time$ = NULL$(9)
	_strtime (&time$)
	PRINT CSIZE$(time$)

'_strdate ()
'copy the current date into a string in format MM/DD/YY
	date$ = NULL$(9)
	_strdate (&date$)
	PRINT CSIZE$(date$)

'clock ()
' Determines the CPU time (in 10-millisecond units) used
' since the beginning of the process
' The value returned by the clock function must be
' divided by the value of the $$CLK_TCK to obtain
' the time in seconds.

	PRINT "CPU time used:"; clock()/$$CLK_TCK ; " seconds"

	a$ = INLINE$ ("Press any key to continue >")

END FUNCTION
END PROGRAM
