.text
;
; ****************************************************
; *****  %_string.xlong     %_string.d.xlong     *****
; *****  %_string.slong     %_string.d.slong     *****  STRING()  and  STRING$()
; *****  %_string.ulong     %_string.d.ulong     *****
; *****  %_string.goaddr    %_string.d.goaddr    *****
; *****  %_string.subaddr   %_string.d.subaddr   *****
; *****  %_string.funcaddr  %_string.d.funcaddr  *****
; ****************************************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
.globl %_string.ulong
%_string.ulong:
.globl %_string.d.ulong
%_string.d.ulong:
mov	esi,[esp+4]					;esi = number to convert to string
push_null_ulong_x:
;push 0
push	'\0'								  ;prefix must be null since ulong must be
string_call_ulong_x:			; positive
push	esi									;push number to convert
call	str.ulong.x
add	esp,8
ret
;
.globl %_string.slong
%_string.slong:
.globl %_string.xlong
%_string.xlong:
.globl %_string.goaddr
%_string.goaddr:
.globl %_string.subaddr
%_string.subaddr:
.globl %_string.funcaddr
%_string.funcaddr:
.globl %_string.d.slong
%_string.d.slong:
.globl %_string.d.xlong
%_string.d.xlong:
.globl %_string.d.goaddr
%_string.d.goaddr:
.globl %_string.d.subaddr
%_string.d.subaddr:
.globl %_string.d.funcaddr
%_string.d.funcaddr:
mov	esi,[esp+4]								;esi = number to convert to string
or	esi,esi											;is number positive?
jns	short push_null_ulong_x 	;yes: no prefix
push	'-'												;no: prefix it with a hyphen
cmp	esi,0x80000000						;is number lowest possible negative number?
je	short string_call_ulong_x 	;yes: don't negate it
neg	esi												;make it positive
jmp	short string_call_ulong_x ;go convert it
