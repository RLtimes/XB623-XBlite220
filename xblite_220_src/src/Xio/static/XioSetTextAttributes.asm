.code 
_XioSetTextAttributes@8:  
func1A.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
xor	eax,eax		;;; .  
push	eax			;;; .. 
push	eax			;;; .. 
push	eax			;;; .. 
push	eax			;;; .. 
sub	esp,220			;;; i114a 
funcBody1A.xio: 
push	[ebp+12]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_SetConsoleTextAttribute@8			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.002A.xio			;;; i195 
call	%s%Error%1A			;;; i163 
else.002A.xio:  
end.if.002A.xio:  
jmp	out.sub1A.0.xio			;;; i262  
%s%Error%1A:  
call	_GetLastError@0			;;; i619 
mov	d[ebp-28],eax			;;; i670  
push	[ebp-32]			;;; i674a 
push	[ebp-28]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-32],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-32]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-36],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func1A.xio			;;; i258 
end.sub1A.0.xio:  
ret				;;; i127 
