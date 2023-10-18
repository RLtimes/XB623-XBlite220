'
' ####################
' #####  PROLOG  #####
' ####################
'
' First assembly program. This program asks for two integers as
' input and prints out their sum.
'
PROGRAM "first"
VERSION "0.0001"
CONSOLE

IMPORT  "msvcrt"			' import functions from msvcrt.dll
IMPORT  "asm_io.obj"  ' use functions in asm_io.asm

DECLARE FUNCTION Entry ()
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
FUNCTION Entry ()

ASM #include "asm_io.inc"		; use macros by including file
ASM ;
ASM ; initialized data is put in the .data segment
ASM ;
ASM .data
ASM ;
ASM ; These labels refer to strings used for output
ASM ;
ASM prompt1 db "Enter a number: ", 0 				; don’t forget null terminator
ASM prompt2 db "Enter another number: ", 0
ASM outmsg1 db "You entered ", 0
ASM outmsg2 db " and ", 0
ASM outmsg3 db ", the sum of these is ", 0
ASM exitmsg db "Press Enter to quit", 0
ASM ;
ASM ; uninitialized data 
ASM ;
ASM ; These labels refer to double words used to store the inputs
ASM ;
ASM input1 dd 0
ASM input2 dd 0
ASM ;
ASM ; code is put in the .code
ASM ;
ASM .code

ASM mov eax, addr prompt1 ; print out prompt
ASM call print_string

ASM call read_int 				; read integer
ASM mov [input1], eax 		; store into input1

ASM mov eax, addr prompt2 ; print out prompt
ASM call print_string

ASM call read_int 				; read integer
ASM mov [input2], eax 		; store into input2

ASM mov eax, [input1] 		; eax = dword at input1
ASM add eax, [input2] 		; eax += dword at input2
ASM mov ebx, eax 					; ebx = eax

ASM dump_regs(1) 						; print out register values macro
ASM dump_mem(2, outmsg1, 1) ; print out memory macro
ASM ;
ASM ; next print out result message as series of steps
ASM ;
ASM mov eax, addr outmsg1
ASM call print_string 		; print out first message
ASM mov eax, [input1]
ASM call print_int 				; print out input1
ASM mov eax, addr outmsg2
ASM call print_string 		; print out second message
ASM mov eax, [input2]
ASM call print_int 				; print out input2
ASM mov eax, addr outmsg3
ASM call print_string 		; print out third message
ASM mov eax, ebx
ASM call print_int 				; print out sum (ebx)
ASM call print_nl 				; print new-line

  INLINE$ ("Press Enter to quit")

END FUNCTION
END PROGRAM