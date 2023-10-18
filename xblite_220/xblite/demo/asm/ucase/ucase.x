'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' A test program to use inline ASM to change
' text to uppercase using a Ucase$() function.
' This demo shows that strings can be modified
' and returned using inline ASM within a function.
'
PROGRAM	"ucase"
VERSION	"0.0003"	' modified 16 Oct 05 for goasm
CONSOLE
'
'	IMPORT	"xst"   ' Standard library : required by most programs
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  Ucase$ (text$)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION  Entry ()

	text$ = "ThIs Is a test StrInG"
	PRINT text$

	t$ = Ucase$ (text$)
	PRINT t$

	a$ = INLINE$ ("Press RETURN to QUIT >")

END FUNCTION
'
'
' #######################
' #####  Ucase$ ()  #####
' #######################
'
FUNCTION  Ucase$ (text$)

	x$ = text$										' string to modify and return

ASM		mov				esi,[ebp-0x18]		;	string address of 1st character
ASM		mov				eax,[ebp-0x18]		;	string address of 1st character
ASM		sub				eax,8							; string length at stringAddr - 0x08
ASM		mov				ebx,[eax]					; get string length

ASM   Next:
ASM		dec				ebx								; point to the next prior character
ASM		js		>		Exit							; jump if sign is negative ebx is < 0
ASM		mov				al,[ebx+esi]			; put the current character into al
ASM		cmp				al,'a'						; compare char to 'a'
ASM		jb				Next							; jump if below to Next
ASM		cmp				al,'z'					  ; compare char to 'z'
ASM		ja				Next							; jump if above to Next
ASM		sub				al,0x20					  ; convert to upper case
ASM		mov				[ebx+esi],al			; put al back into string
ASM		jmp				Next							; jump to Next

ASM   Exit:

	RETURN x$

END FUNCTION
END PROGRAM
