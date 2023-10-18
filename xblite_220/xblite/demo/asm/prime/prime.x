'
' ####################
' #####  PROLOG  #####
' ####################
'
' This program calculates prime numbers
'
' Works like the following C program:
' #include <stdio.h>
'
'int main()
'{
'  unsigned guess;          /* current guess for prime      */
'  unsigned factor;         /* possible factor of guess     */
'  unsigned limit;          /* find primes up to this value */
'
'  printf("Find primes up to: ");
'  scanf("%u", &limit);
'
'  printf("2\n");    /* treat first two primes as special case */
'  printf("3\n");
'
'  guess = 5;        /* initial guess */
'  while ( guess <= limit ) {
'    /* look for a factor of guess */
'    factor = 3;
'    while ( factor*factor < guess && guess % factor != 0 )
'      factor += 2;
'    if ( guess % factor != 0 )
'      printf("%d\n", guess);
'    guess += 2;    /* only look at odd numbers */
'  }
'  return 0;
'}

PROGRAM "prime"
VERSION "0.0001"
CONSOLE

IMPORT  "msvcrt"			' import functions from msvcrt.dll
IMPORT  "asm_io.obj"  ' use functions in asm_io.asm

DECLARE FUNCTION Entry ()

FUNCTION Entry ()

ASM #include "asm_io.inc"

ASM .data
ASM Message         db      "Find primes up to: ", 0

ASM Limit           dd    0               ; find primes up to this limit
ASM Guess           dd    0               ; the current guess for prime
 

ASM .code

ASM         mov     eax,  addr Message
ASM         call    print_string
        
ASM         call    read_int             ; scanf("%u", & limit );
ASM         mov     [Limit], eax

ASM         mov     eax, 2               ; printf("2\n");
ASM         call    print_int
ASM         call    print_nl
ASM         mov     eax, 3               ; printf("3\n");
ASM         call    print_int
ASM         call    print_nl

ASM         mov     d[Guess], 5     		 ; Guess = 5;

ASM while_limit:                         ; while ( Guess <= Limit )
ASM         mov     eax,[Guess]
ASM         cmp     eax, [Limit]
ASM         jnbe    >end_while_limit      ; use jnbe since numbers are unsigned

ASM         mov     ebx, 3               ; ebx is factor = 3;
ASM while_factor:
ASM         mov     eax,ebx
ASM         mul     eax                  ; edx:eax = eax*eax
ASM         jo      >end_while_factor     ; if answer won't fit in eax alone
ASM         cmp     eax, [Guess]
ASM         jnb     >end_while_factor     ; if !(factor*factor < guess)
ASM         mov     eax,[Guess]
ASM         mov     edx,0
ASM         div     ebx                  ; edx = edx:eax % ebx
ASM         cmp     edx, 0
ASM         je      >end_while_factor     ; if !(guess % factor != 0)

ASM         add     ebx,2                ; factor += 2;
ASM         jmp     while_factor
ASM end_while_factor:
ASM         je      >end_if               ; if !(guess % factor != 0)
ASM         mov     eax,[Guess]          ; printf("%u\n")
ASM         call    print_int
ASM         call    print_nl
ASM end_if:
ASM         mov     eax,[Guess]
ASM         add     eax, 2
ASM         mov     [Guess], eax         ; guess += 2
ASM         jmp     while_limit
ASM end_while_limit:

  INLINE$ ("Press Enter to quit >")

END FUNCTION
END PROGRAM