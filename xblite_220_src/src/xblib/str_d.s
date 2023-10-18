.text
;
; ******************************
; *****  %_str.d.xlong     *****  STR$(x)
; *****  %_str.d.slong     *****
; *****  %_str.d.ulong     *****
; *****  %_str.d.goaddr    *****
; *****  %_str.d.subaddr   *****
; *****  %_str.d.funcaddr  *****
; ******************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_str.d.ulong
%_str.d.ulong:
mov	esi,[esp+4]					;esi = number to convert to string
push_space_ulong_x:
push	' '									;prefix must be space since ulong must be
call_ulong_x:						; positive
push	esi									;push number to convert to string
call	str.ulong.x
add	esp,8
ret
;
.globl %_str.d.slong
%_str.d.slong:
.globl %_str.d.xlong
%_str.d.xlong:
.globl %_str.d.goaddr
%_str.d.goaddr:
.globl %_str.d.subaddr
%_str.d.subaddr:
.globl %_str.d.funcaddr
%_str.d.funcaddr:

mov	esi,[esp+4]					;esi = number to convert to string
or	esi,esi								;is number positive?
jns	short push_space_ulong_x ;yes: prefix it with a space
push	'-'									;no: prefix it with a hyphen
cmp	esi,0x80000000			;is number lowest possible negative number?
je	short call_ulong_x 		;yes: don't negate it
neg	esi									;make it positive
jmp	short call_ulong_x 	;go convert it
