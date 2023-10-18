.text
;
; *******************
; *****  high0  *****
; *****  high1  *****
; *******************
;
.globl %_high0
%_high0:
not	eax             ; flip bits, then do high1
;;
.globl %_high1
%_high1:
mov	ecx, 32         ; ecx = 32 = bit tested
;;
highloop:
dec	ecx             ; ecx = bit to test
js	highdone          ; ecx = -1 means all bits tested
sll	eax,1           ; shift msb into C flag
jnc	short highloop  ; if C flag = 0, keep looking
;;
highdone:
mov	eax, ecx        ; eax = bit # of high 0 or high 1 bit
ret
