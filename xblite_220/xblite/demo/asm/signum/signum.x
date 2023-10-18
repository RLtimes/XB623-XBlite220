
CONSOLE
IMPORT "kernel32"
DECLARE FUNCTION Entry ()
DECLARE FUNCTION signum1 (x)
DECLARE FUNCTION signum2 (x)

FUNCTION Entry ()

	PRINT "signum1:", signum1(1024), signum1(-356), signum1(0)
	PRINT "signum2:", signum2(1024), signum2(-356), signum2(0)
	PRINT "SGN    :", SGN(1024), SGN(-356), SGN(0)
	
	upp = 100000000

	x = 0
	start = GetTickCount()
	FOR i = 0 TO upp
		x = signum1(1024)
		x = signum1(-356)
		x = signum1(0)
	NEXT i
	ms = GetTickCount() - start
	PRINT "signum1:", ms 

	x = 0
	start = GetTickCount()	
	FOR i = 0 TO upp
		x = signum2(1024)
		x = signum2(-356)
		x = signum2(0)
	NEXT i
	ms = GetTickCount() - start
	PRINT "signum2:", ms 

	x = 0
	start = GetTickCount()	
	FOR i = 0 TO upp
		x = SGN(1024)
		x = SGN(-356)
		x = SGN(0)
	NEXT i
	ms = GetTickCount() - start
	PRINT "SGN    :", ms 
	
  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION

FUNCTION signum1 (x)

IF (x > 0) THEN
	RETURN 1
ELSE
	IF (x < 0) THEN RETURN -1
END IF

END FUNCTION

FUNCTION signum2 (x)

ASM		mov	eax,d[ebp+8]	
ASM		cdq 							; sign extends register eax into edx
ASM		neg eax
ASM		adc edx, edx			; add with carry
ASM		mov eax, edx
ASM		jmp end.signum2.signum

END FUNCTION
END PROGRAM