'
' ####################
' #####  PROLOG  #####
' ####################
'
' A profiler library for xblite. To be used in conjunction with
' profiler.x and the compiler switch -p.
'
PROGRAM "proflib"
VERSION "0.0002"
CONSOLE
'
	IMPORT  "xst"				' Standard library : required by most programs
'	IMPORT  "xsx"				' Extended standard library
'	IMPORT  "xio"				' Console input/ouput library
'	IMPORT  "user32"		' user32.dll
	IMPORT  "kernel32"	' kernel32.dll
'	IMPORT  "shell32"		' shell32.dll
'	IMPORT  "msvcrt"		' msvcrt.dll
	IMPORT  "winmm"

EXPORT
TYPE TICKS = GIANT

TYPE CALLINFO
  XLONG .funcAddr    	' Function address
  XLONG .parentFrame 	' Parent stack frame address
  XLONG .origRetAddr 	' Function return address
  TICKS .entryTime  	' Time function was called
  TICKS .startTime  	' Time function started
  TICKS .endTime    	' Time function returned
END TYPE


DECLARE FUNCTION Proflib ()
DECLARE FUNCTION penter ()
DECLARE FUNCTION pexit ()
DECLARE FUNCTION TICKS GetTicks ()
DECLARE FUNCTION TICKS GetFreq ()
DECLARE FUNCTION LogEntry (funcAddr)
END EXPORT

'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Proflib ()

	STATIC init
	TICKS tps

	IFZ init THEN
		init = $$TRUE
		tps = GetFreq ()  ' initialize ticks per second
	END IF

END FUNCTION

FUNCTION penter ()

	SHARED stackIndex
	TICKS entryTime
	SHARED CALLINFO ci[]
	CALLINFO callinfo 
	STATIC init
	
	entryTime = GetTicks ()
	
	IFZ init THEN GOSUB Initialize
	
' get base frame pointer address
	addr = 0
ASM  mov  d[ebp-40], ebp

	IFZ addr THEN RETURN
	INC stackIndex
	upper = UBOUND (ci[])
	IF stackIndex >= upper THEN REDIM ci[upper<<1]

	funcAddr = XLONGAT(addr+4) - 5  				' get calling function's address

	ci[stackIndex].funcAddr    = funcAddr
'	ci[stackIndex].parentFrame = XLONGAT(addr)
	ci[stackIndex].entryTime   = entryTime
	
	LogEntry (funcAddr)											' log entry function
	
  ci[stackIndex].startTime 	= GetTicks () ' track approx. start time

SUB Initialize
	init = $$TRUE
	stackIndex = -1
	DIM ci[512]
END SUB
	

END FUNCTION

FUNCTION pexit ()

	SHARED stackIndex
	SHARED CALLINFO ci[] 
	STATIC TICKS totalSlack
	
	TICKS endTime, tps, dif
	
	endTime = GetTicks () 
	ci[stackIndex].endTime = endTime 
	
	IF stackIndex > 0 THEN
		indent$ = CHR$('\t', stackIndex)
	ELSE
		indent$ = ""
	END IF
'	PRINT indent$;
	
'	tps = GetFreq ()

	addr = ci[stackIndex].funcAddr
	addrParent = ci[stackIndex].parentFrame
	
'	dif = endTime - ci[stackIndex].startTime 
'	PRINT indent$; "pexit:  "; HEX$(addr, 8); " time:"; DOUBLE ((dif)/(DOUBLE(tps)/1000.0)); " ticks:"; dif 

' print pexit, funcAddr, entryTime, startTime, endTime	
	PRINT indent$; "pexit:  "; HEX$(addr, 8); " ";; ci[stackIndex].entryTime;; ci[stackIndex].startTime;; ci[stackIndex].endTime  
	
	DEC stackIndex

END FUNCTION

FUNCTION TICKS GetTicks ()

ASM		rdtsc												;.byte 	0x0F,0x31 	; binary Pentium rdtsc instruction
ASM		jmp			end.func4.proflib		; jump to end of function

END FUNCTION

FUNCTION TICKS GetFreq ()

	$SLEEP = 1000
	GIANT freq
  TICKS qpf1, qpf2, qc1, qc2, qpcTicks, qcTicks
  STATIC TICKS ticksPerSec
	LONGDOUBLE ratio
		
' get ticks per second
  IFZ ticksPerSec THEN
		timeBeginPeriod (1)
		QueryPerformanceFrequency (&freq)
		QueryPerformanceCounter (&qpf1)
		qc1 = GetTicks ()
		Sleep ($SLEEP)
		QueryPerformanceCounter (&qpf2)
		qc2 = GetTicks ()
		qpcTicks = qpf2 - qpf1
		qcTicks = qc2 - qc1
		ratio = LONGDOUBLE(qcTicks)/LONGDOUBLE(qpcTicks)
    ticksPerSec = ratio * LONGDOUBLE(freq)
		timeEndPeriod (1)
	END IF
	
  RETURN ticksPerSec

END FUNCTION

FUNCTION LogEntry (funcAddr)

	SHARED stackIndex

	IF stackIndex THEN
		indent$ = CHR$('\t', stackIndex)
	ELSE
		indent$ = ""
	END IF
'	PRINT indent$;

	PRINT indent$; "penter: "; HEX$(funcAddr, 8)

END FUNCTION

END PROGRAM