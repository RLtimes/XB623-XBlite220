'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' ASM demo to show the use of RDTSC
' (Read Time Stamp Counter) instruction.
' This instruction is only available on
' Pentium CPUs.
'
PROGRAM	"timestamp"
VERSION	"0.0003"	' modified 16 Oct 05 for goasm
CONSOLE

'	IMPORT	"xst"
'	IMPORT  "xsx"
	IMPORT	"xst_s.lib"
	IMPORT  "xsx_s.lib"
	IMPORT  "kernel32"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  GIANT TimeStamp ()
DECLARE FUNCTION  GIANT GetCPUFreq ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()
	XLONG ms
	STATIC GIANT time1, time2, deltaT, freq
	DOUBLE speed, mHz

  cpu = XstGetCPUName(@id$, @cpuFamily, @model, @intelBrandID)
	PRINT id$, cpuFamily, model, intelBrandID
	PRINT
  IF cpu <= 486 THEN
    PRINT "Not a Pentium CPU"
    PRINT
    GOTO end
  END IF

	PRINT " ***** Clock speed (frequency) checking program *****"
	PRINT

	fm$ = "####.##"


	PRINT " ***** Call GetCPUFreq () *****"
	PRINT
	freq = GetCPUFreq ()
	mHz = freq * 1d-6
	PRINT "Clock speed = "; FORMAT$(fm$, mHz); " mHz"
	PRINT


	PRINT " ***** Use TimeStamp () to get clock speed *****"
	PRINT
	FOR sec = 1 TO 6
		ms = sec * 1000
		time1 = TimeStamp ()						' call RDTSC TimeStamp() function
		Sleep (ms)
		time2 = TimeStamp ()						' call RDTSC TimeStamp() function
		deltaT = time2 - time1
		speed = deltaT / DOUBLE(sec) * 1d-6
		PRINT "Run time = "; sec; " sec  :  Clock speed = "; FORMAT$(fm$, speed); " mHz"
	NEXT sec

end:
	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
'
'
' ##########################
' #####  TimeStamp ()  #####
' ##########################

' RDTSC - Read Time Stamp Counter - returns the number
' of clock cycles since the CPU was powered up or reset
' RDTSC is a two byte instruction - 0F 31 - and it returns
' a 64-bit count in EDX:EAX.
' The RDTSC instruction is only available on Pentium processors.
' For more info :
' http://cedar.intel.com/software/idap/media/pdf/rdtscpm1.pdf

' How the Time-Stamp Counter Works

' Beginning with the Pentium® processor, Intel processors allow
' the programmer to access a time-stamp counter. The time-stamp
' counter keeps an accurate count of every cycle that occurs on
' the processor. The Intel time-stamp counter is a 64-bit MSR
' (model specific register) that is incremented every clock cycle.
' On reset, the time-stamp counter is set to zero.

' To access this counter, programmers can use the RDTSC
' (read time-stamp counter) instruction. This instruction
' loads the high-order 32 bits of the register into EDX,
' and the low-order 32 bits into EAX.

' Remember that the time-stamp counter measures "cycles" and
' not "time". For example, two hundred million cycles on a
' 200 MHz processor is equivalent to one second of real time,
' while the same number of cycles on a 400 MHz processor is
' only one-half second of real time. Thus, comparing cycle
' counts only makes sense on processors of the same speed.
' To compare processors of different speeds, the cycle counts
' should be converted into time units,

' where:

' # seconds = # cycles / frequency

' Note: frequency is given in Hz, where: 1,000,000 Hz = 1 MHz
'
FUNCTION  GIANT TimeStamp ()

ASM					rdtsc 											; Read time-stamp counter into EDX:EAX
ASM					jmp					end.func2.timestamp				; jump to end of function

END FUNCTION
'
'
' ###########################
' #####  GetCPUFreq ()  #####
' ###########################
'
FUNCTION  GIANT GetCPUFreq ()

	GIANT time0, time1
	
	time0 = 0
	time1 = 0
	
	time0 = TimeStamp ()
	Sleep (1000)
	time1 = TimeStamp ()
	
	RETURN time1 - time0

'ASM					xor					eax,eax
'ASM					cpuid												; Processor identification information
'ASM					rdtsc 											; Read time-stamp counter into EDX:EAX
'ASM					mov					d[ebp-28],eax
'ASM					mov					d[ebp-24],edx
'ASM					push				1000						; msec arg1 = 1000
'ASM					call				_Sleep@4				; sleep 1000 ms
'ASM					rdtsc 											; Read time-stamp counter into EDX:EAX
'ASM					sub					eax,d[ebp-28]		; find difference between two counts
'ASM					sub					edx,d[ebp-24]
'ASM					jmp					end.func3.timestamp		; jump to end of function

END FUNCTION
END PROGRAM
