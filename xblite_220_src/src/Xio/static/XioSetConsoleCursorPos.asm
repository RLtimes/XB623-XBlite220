.code 
_XioSetConsoleCursorPos@12: 
funcE.xio:  
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
push	eax			;;; .. 
sub	esp,216			;;; i114a 
funcBodyE.xio:  
push	[ebp+16]			;;; i674a 
push	[ebp+12]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-24],eax			;;; i670  
push	[ebp-24]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_SetConsoleCursorPosition@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0017.xio			;;; i195 
call	%s%Error%E			;;; i163  
else.0017.xio:  
end.if.0017.xio:  
jmp	out.subE.0.xio			;;; i262 
%s%Error%E: 
call	_GetLastError@0			;;; i619 
mov	d[ebp-32],eax			;;; i670  
push	[ebp-36]			;;; i674a 
push	[ebp-32]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-36],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-36]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-40],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.funcE.xio			;;; i258  
end.subE.0.xio: 
ret				;;; i127 
