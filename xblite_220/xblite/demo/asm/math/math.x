'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program demonstrates how the integer multiplication and division
' instructions work.
'
PROGRAM "math"
VERSION "0.0001"
CONSOLE

IMPORT  "msvcrt"			' import functions from msvcrt.dll
IMPORT  "asm_io.obj"  ' use functions in asm_io.asm

DECLARE FUNCTION Entry ()

FUNCTION Entry ()

ASM #include "asm_io.inc"

ASM .data
ASM ;
ASM ; Output strings
ASM ;
ASM prompt          db    "Enter a number: ", 0
ASM square_msg      db    "Square of input is ", 0
ASM cube_msg        db    "Cube of input is ", 0
ASM cube25_msg      db    "Cube of input times 25 is ", 0
ASM quot_msg        db    "Quotient of cube/100 is ", 0
ASM rem_msg         db    "Remainder of cube/100 is ", 0
ASM neg_msg         db    "The negation of the remainder is ", 0


ASM input   				dd 		0


ASM .code

ASM     mov     eax, addr prompt
ASM     call    print_string

ASM     call    read_int
ASM     mov     [input], eax

ASM     imul    eax               ; edx:eax = eax * eax
ASM     mov     ebx, eax          ; save answer in ebx
ASM     mov     eax, addr square_msg
ASM     call    print_string
ASM     mov     eax, ebx
ASM     call    print_int
ASM     call    print_nl

ASM     mov     ebx, eax
ASM     imul    ebx, [input]      ; ebx *= [input]
ASM     mov     eax, addr cube_msg
ASM     call    print_string
ASM     mov     eax, ebx
ASM     call    print_int
ASM     call    print_nl

ASM     imul    ecx, ebx, 25      ; ecx = ebx*25
ASM     mov     eax, addr cube25_msg
ASM     call    print_string
ASM	    mov     eax, ecx
ASM     call    print_int
ASM     call    print_nl

ASM     mov     eax, ebx
ASM     cdq                       ; initialize edx by sign extension
ASM     mov     ecx, 100          ; can't divide by immediate value
ASM     idiv    ecx               ; edx:eax / ecx
ASM     mov     ecx, eax          ; save quotient into ecx
ASM     mov     eax, addr quot_msg
ASM     call    print_string
ASM     mov     eax, ecx
ASM     call    print_int
ASM     call    print_nl
ASM     mov     eax, addr rem_msg
ASM     call    print_string
ASM     mov     eax, edx
ASM     call    print_int
ASM     call    print_nl
        
ASM     neg     edx               ; negate the remainder
ASM     mov     eax, addr neg_msg
ASM     call    print_string
ASM     mov     eax, edx
ASM     call    print_int
ASM     call    print_nl

  a$ = INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM