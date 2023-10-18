.text
;
.globl %_open.s
%_open.s:
mov	eax, [esp+4]	; ;;; eax -> filename$
mov	ebx, [esp+8]	; ;;; ebx == open mode
push	ebx		; ;;;
push	eax		; ;;;
call	_XxxOpen@8	; ;;;
mov	esi, [esp+4]	; ;;;
jmp	%____free	; ;;;
;
;
.globl %_open.v
%_open.v:
mov	eax, [esp+4]	; ;;; eax -> filename$
mov	ebx, [esp+8]	; ;;; ebx == open mode
push	ebx		; ;;;
push	eax		; ;;;
call	_XxxOpen@8	; ;;;
ret			; ;;;
