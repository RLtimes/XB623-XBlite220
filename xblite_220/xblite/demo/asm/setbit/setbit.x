'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A test program to use inline ASM in a SetBit() function.
'
PROGRAM	"setbit"
VERSION	"0.0003"	' modified 16 Oct 05 for goasm
CONSOLE

'	IMPORT	"xst"   ' Standard library : required by most programs

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  SetBit (bit, x)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

' set any bit in x to 1
'	x = x | (1 << bit)

	PRINT " ***** SetBit() *****"
	x = 0
	FOR bit = 0 TO 31
		y = SetBit (bit, x)
		fm1$ = "############"
		fm2$ = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		PRINT FORMAT$(fm1$, y), FORMAT$(fm2$, BIN$(y))
	NEXT bit

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
'
'
' #######################
' #####  SetBit ()  #####
' #######################
'
FUNCTION  SetBit (bit, x)

ASM		mov				ecx,[ebp+0x08]				; bit must go here for or
ASM		mov				ebx,[ebp+0x0C]				; put x into ebx
ASM		mov				eax,0x01							; put 1 into eax
ASM		shl				eax,cl								; shift arith left bit times = 2^bit
ASM		or				eax,ebx								; inclusive OR x with result
ASM		jmp				end.SetBit.setbit			; jump to end of function
END FUNCTION
END PROGRAM
