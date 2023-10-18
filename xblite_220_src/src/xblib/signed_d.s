.text
;
; *********************************
; *****  %_signed.d.xlong     *****  SIGNED$ (xlong)
; *****  %_signed.d.slong     *****
; *****  %_signed.d.ulong     *****
; *****  %_signed.d.goaddr    *****
; *****  %_signed.d.subaddr   *****
; *****  %_signed.d.funcaddr  *****
; *********************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	plus sign is leading character if positive
;				hyphen is leading character if negative
;
; destroys: eax, ebx, ecx, edx, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_signed.d.ulong
%_signed.d.ulong:
mov	esi,[esp+4]				;esi = number to convert to string
push_plus_ulong_x:
push	'+'								;prefix must be plus since ulong must be
signed_call_ulong_x:		; positive
push	esi								;push number to convert
call	str.ulong.x
add	esp,8
ret
;
.globl %_signed.d.slong
%_signed.d.slong:
.globl %_signed.d.xlong
%_signed.d.xlong:
.globl %_signed.d.goaddr
%_signed.d.goaddr:
.globl %_signed.d.subaddr
%_signed.d.subaddr:
.globl %_signed.d.funcaddr
%_signed.d.funcaddr:
mov	esi,[esp+4]								;esi = number to convert to string
or	esi,esi											;is number positive?
jns	short push_plus_ulong_x 	;yes: prefix it with a plus sign
push	'-'												;no: prefix it with a hyphen
cmp	esi,0x80000000						;is number lowest possible negative number?
je	short signed_call_ulong_x 	;yes: don't negate it
neg	esi												;make it positive
jmp	short signed_call_ulong_x ;go convert it

