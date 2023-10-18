.text
;
.globl %_seek
%_seek:
mov	eax, [esp+4]	; ;;; eax == file number
mov	ebx, [esp+8]	; ;;; ebx == file position
push	ebx		; ;;;
push	eax		; ;;;
call	_XxxSeek@8	; ;;;
ret			; ;;;
