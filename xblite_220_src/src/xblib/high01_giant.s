.text
;
; *************************
; *****  high0.giant  *****  eax = LS32
; *****  high1.giant  *****  edx = MS32
; *************************
;
.globl %_high0.giant
%_high0.giant:
not	eax                 ; flip LS bits, then do high1
not	edx                 ; flip MS bits, then do high1
;;
.globl %_high1.giant
%_high1.giant:
mov	ecx, 64             ; ecx = 64 = bit tested
;;
highgiantloop:
dec	ecx                 ; ecx = bit to test
js	short highgiantdone   ; ecx = -1 means all bits tested
sll	edx,1               ; edx = MS << 1
jc	short highgiantdone   ; found 1 bit
sll	eax,1               ; eax = LS << 1
jnc	short highgiantloop ; eax MSb was 0 - continue loop
or	edx,1                 ; carry bit from LS to MS
jmp	short highgiantloop	;
;;
highgiantdone:
mov	eax, ecx            ; eax = bit # of high 0 or high 1 bit
ret
