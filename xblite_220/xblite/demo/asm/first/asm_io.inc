;	extern  read_int, print_int, print_string
;	extern	read_char, print_char, print_nl
;	extern  sub_dump_regs, sub_dump_mem, sub_dump_math, sub_dump_stack

dump_regs(%a) =  \
	push  %a \
	call  sub_dump_regs

; usage: dump_mem(label, start-address, # paragraphs)
dump_mem(%a,%b,%c) =     \
	push       %a    \
	push       addr %b    \
	push       %c    \
	call       sub_dump_mem

dump_math(%a) =    \
	push	 %a \
	call	 sub_dump_math

dump_stack(%a,%b,%c) =     \
	push	 %c        \
        push     %b        \
	push	 %a        \
        call     sub_dump_stack

