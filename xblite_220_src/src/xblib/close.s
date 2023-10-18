.text
; in:	arguments are on the stack
; out:	result is in eax
;
; destroys: ebx, ecx, edx, esi, edi
;
; Each I/O function calls an XBASIC function in xst.x to do the
; real work.  Some functions have two entry points, one for a
; string parameter on the stack and one for a string parameter
; in a variable.
;
; NOTE:  Wierd stack business necessary because the intrinsic
;        code makes a CDECL call, while the XBasic functions in
;        xst.x are STDCALL functions.
;
;
.globl %_close
%_close:
mov	eax, [esp+4]	; ;;;
push	eax		; ;;;
call	_XxxClose@4	; ;;;
ret
