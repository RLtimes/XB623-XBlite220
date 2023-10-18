.text
;
; ***********************
; *****  %_csize.v  *****  CSIZE(x$)
; *****  %_csize.s  *****
; ***********************
;
; in:	arg0 -> source string
; out:	eax = number of characters in source string up to but not includin
;	      the first null
;
; destroys: ebx, ecx, edx, esi, edi
;
.globl %_csize.v
%_csize.v:
xor	esi,esi             ;nothing to free on exit
jmp	short csize.x
;
.globl %_csize.s
%_csize.s:
mov	esi,[esp+4]         ;free source string on exit
;;
;                        ;fall through
;;
csize.x:
mov	eax,[esp+4]         ;eax -> source string
or	eax,eax               ;null pointer?
jz	short csize_exit      ;yes: nothing to do
mov	edi,eax             ;edi -> source string
mov	ecx,-1              ;search until we find a null or cause a
;                        ;memory fault
xor	eax,eax             ;search for a null
cld                      ;make sure we're going in the right direction
repne
scasb                    ;edi -> terminating null
not	ecx                 ;ecx = length + 1
lea	eax,[ecx-1]         ;eax = length not counting terminator null
call	%____free           ;free source string if called from .s entry
; point
csize_exit:
ret
