.text
;
.globl %_inline_d.s
%_inline_d.s:
mov	eax, [esp+4]	; ;;; eax -> prompt$
push	eax		; ;;;
call	_XxxInline$@4	; ;;;
mov	esi, [esp+4]	; ;;;
jmp	%____free	; ;;;
; ;;;
;
;
.globl %_inline_d.v
%_inline_d.v:
mov	eax, [esp+4]	; ;;; eax -> prompt$
push	eax		; ;;;
call	_XxxInline$@4	; ;;;
ret
