.text
;
.globl %_shell.s
%_shell.s:
mov	eax, [esp+4]	; ;;; eax -> shell command string
push	eax		; ;;;
call	_XxxShell@4	; ;;;
mov	esi, [esp+4]	; ;;;
push	eax		; ;;;
call	%____free	; ;;;
pop	eax		; ;;;
ret
;
;
.globl %_shell.v
%_shell.v:
mov	eax, [esp+4]	; ;;; eax -> shell command string
push	eax		; ;;;
call	_XxxShell@4	; ;;;
ret
