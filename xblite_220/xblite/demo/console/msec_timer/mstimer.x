'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' This test program looks at various timing
' functions to determine the smallest difference
' of time that the function can detect. This is
' helpful to know if you want to set up an
' accurate timer with a known tolerance.
'
' Function                 Win98SE       Win2k SP4
' ---------------------------------------------------
' XstGetDateAndTime       55      msec   15.63   msec
' clock                   55      msec   15.62   msec
'	XstGetSystemTime         5      msec   15.62   msec
' GetTickCount             5      msec   15.63   msec
' timeGetTime              1      msec    1      msec
' QueryPerformanceCounter  0.003  msec    0.0017 msec
'
PROGRAM	"mstimer"
VERSION	"0.0003"
CONSOLE
'
	IMPORT	"xsx"
	IMPORT	"xst"
	IMPORT	"xio"
	IMPORT	"gdi32"
	IMPORT	"user32"
	IMPORT  "kernel32"
	IMPORT	"winmm"
	IMPORT  "msvcrt"
'
DECLARE FUNCTION  Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

FUNCADDR RDTSC(GIANT)

' set type for variables used in QueryPerformanceCounter()

'	LARGE_INTEGER qpcStart, qpcFinish, qpcFrequency
	GIANT qpcStart, qpcFinish, qpcFrequency
	DOUBLE duration[]

' add some rows to console buffer
	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, 0, 100)
	XioCloseStdHandle (hStdOut)

'test each function nCount times
	nCount = 100
	
'test timeBeginPeriod() function to see what happens
'this may alter timing values under win2k, winxp
	timeBeginPeriod (1)

	DIM duration[nCount-1]
	upper = UBOUND(duration[])

' ***** Do test on XstGetDateAndTime() *****

	FOR i = 0 TO upper
		XstGetDateAndTime (0, 0, 0, 0, 0, 0, 0, @nanos)
		start = nanos/1.0d+6
		DO
			XstGetDateAndTime (0, 0, 0, 0, 0, 0, 0, @nanos)
			msec = nanos/1.0d+6
			duration = msec - start
			IF duration > 1 THEN
				duration[i] = duration
 				EXIT DO
			ELSE
				IF duration < 0 THEN
					duration = duration + 1000
					IF duration > 1 THEN
						duration[i] = duration
						EXIT DO
					END IF
				END IF
			END IF
		LOOP
	NEXT i

	PRINT "###########################################"
	PRINT "##### XstGetDateAndTime Function Test #####"
	PRINT "###########################################"
	PRINT
	sum# = 0
	FOR i = 0 TO upper
		sum# = sum# + duration[i]
	NEXT i
	avg# = sum#/100.0
	PRINT "... Average:"; avg#; " msec"
	PRINT

' ***** Do test on XstGetSystemTime() *****

	FOR i = 0 TO upper
		XstGetSystemTime (@start)
		DO
			XstGetSystemTime (@finish)
		LOOP WHILE finish < start + 1
		XstGetSystemTime (@msec)
		duration[i] = finish - start
	NEXT i

	PRINT "##########################################"
	PRINT "##### XstGetSystemTime Function Test #####"
	PRINT "##########################################"
	PRINT
	sum# = 0
	FOR i = 0 TO upper
		sum# = sum# + duration[i]
	NEXT i
	avg# = sum#/100.0
	PRINT "... Average:"; avg#; " msec"
	PRINT

' ***** Do test on GetTickCount() in kernel32.dll *****

	FOR i = 0 TO upper
		start = GetTickCount()
		DO
		LOOP WHILE GetTickCount() < start + 1
		finish = GetTickCount()
		duration[i] = finish - start
	NEXT i

	PRINT
	PRINT "######################################"
	PRINT "##### GetTickCount Function Test #####"
	PRINT "######################################"
	PRINT
	sum# = 0
	FOR i = 0 TO upper
		sum# = sum# + duration[i]
	NEXT i
	avg# = sum#/100.0
	PRINT "... Average:"; avg#; " msec"
	PRINT

' ***** Do test on timeGetTime() in winmm.dll *****

	IFZ timeBeginPeriod(1) THEN

		FOR i = 0 TO upper
			start = timeGetTime()
			DO
			LOOP WHILE timeGetTime() < start + 1
			finish = timeGetTime()
			duration[i] = finish - start
		NEXT i
		ret = timeEndPeriod(1)
	END IF

	PRINT
	PRINT "#####################################"
	PRINT "##### timeGetTime Function Test #####"
	PRINT "#####################################"
	PRINT
	sum# = 0
	FOR i = 0 TO upper
		sum# = sum# + duration[i]
	NEXT i
	avg# = sum#/100.0
	PRINT "... Average:"; avg#; " msec"
	PRINT

' ***** Do test on QueryPerformanceCounter() in kernel32.dll *****

	QueryPerformanceFrequency(&qpcFrequency)
'	ticksPerSec = qpcFrequency.low
	ticksPerSec = qpcFrequency
	PRINT "QueryPerformanceFrequency: ticksPerSec = "; ticksPerSec
'calculate number of ticks in .001 msec
	ticks = ticksPerSec * 0.000001

	FOR i = 0 TO upper
		QueryPerformanceCounter(&qpcStart)
		DO
			QueryPerformanceCounter(&qpcFinish)
'		LOOP WHILE qpcFinish.low < qpcStart.low + ticks
		LOOP WHILE qpcFinish < qpcStart + ticks
'		dTicks = qpcFinish.low - qpcStart.low
		dTicks = qpcFinish - qpcStart
		dsec#   = dTicks/DOUBLE(ticksPerSec)
		dmsec#  = dsec# * 1000.0
		duration[i] = dmsec#
	NEXT i

	PRINT
	PRINT "#################################################"
	PRINT "##### QueryPerformanceCounter Function Test #####"
	PRINT "#################################################"
	PRINT
	sum# = 0
	FOR i = 0 TO upper
		sum# = sum# + duration[i]
	NEXT i
	avg# = sum#/100.0
	PRINT "... Average:"; avg#; " msec"
	PRINT

' ***** Do test on clock () *****
' found in msvcrt.dll
' clock () determines the CPU time
' (in 10-millisecond units) used
' since the beginning of the process
' The value returned by the clock function
' must be divided by the value of the
' $$CLK_TCK to obtain the time in seconds.

	FOR i = 0 TO upper
		start = clock ()
		DO
		LOOP WHILE clock () < start + 1
		finish = clock ()
		duration[i] = (finish - start)/DOUBLE ($$CLK_TCK) * 1000.0
	NEXT i

	PRINT "##################################"
	PRINT "##### clock () Function Test #####"
	PRINT "##################################"
	PRINT
	sum# = 0
	FOR i = 0 TO upper
		sum# = sum# + duration[i]
	NEXT i
	avg# = sum#/100.0
	PRINT "... Average:"; avg#; " msec"
	PRINT
	
	timeEndPeriod(1)

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
END PROGRAM
