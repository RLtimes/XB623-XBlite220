.text
;
; *********************
; *****  %_asc.v  *****  ASC(x$, y)
; *****  %_asc.s  *****
; *********************
;
; in:	arg1 = index into x$ (one-biased)
;	    arg0 -> source string
; out:	eax = ASCII value of character in x$ at position y
;
; destroys: ebx, ecx, edx, esi, edi
;
; If y < 1 or y > LEN(x$), generates \"illegal function call\" error and
; returns zero.
;
.globl %_asc.v
%_asc.v:
	xor	esi,esi		             ;nothing to free on exit
	jmp	short asc.x
;
.globl %_asc.s
%_asc.s:
	mov	esi,[esp+4]	           ;free source string on exit
;;
;                           ;fall through
;;
asc.x:
	mov	eax,[esp+4]	           ;eax -> source string
	or	eax,eax		             ;null pointer?
	jz	short asc_IFC	         ;yes: error
	mov	ebx,[esp+8]	           ;ebx = index into source string (one-biased)
	cmp	ebx,[eax-8]	           ;greater than length of string?
	ja	short asc_IFC	         ;yes: error
	dec	ebx		                 ;ebx = offset into source string
	js	short asc_IFC	         ;if before beginning of string, error
	movzx	eax,byte ptr [eax+ebx] ;eax = ASC(x$,y)
	jmp	%____free	             ;free source string (esi) if called from .s
				                     ;entry point, and return value in eax
asc_IFC:
	xor	eax,eax		             ;return a zero if there was an error
	call	%____free	           ;free source string (esi) if called from .s
				                     ;entry point
	call	%_InvalidFunctionCall	 ;Return directly from there
                            ;(assumes esi is not destroyed)

