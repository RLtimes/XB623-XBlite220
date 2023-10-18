.code 
_XioSetConsoleBufferSize@12:  
funcD.xio:  
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
funcBodyD.xio:  
mov	eax,d[ebp+12]			;;; i665  
cmp	eax,80			;;; i684a  
jge	>> else.0014.xio			;;; i219 
mov	eax,80			;;; i659 
mov	d[ebp+12],eax			;;; i670  
else.0014.xio:  
end.if.0014.xio:  
mov	eax,d[ebp+16]			;;; i665  
cmp	eax,25			;;; i684a  
jge	>> else.0015.xio			;;; i219 
mov	eax,25			;;; i659 
mov	d[ebp+16],eax			;;; i670  
else.0015.xio:  
end.if.0015.xio:  
push	[ebp+16]			;;; i674a 
push	[ebp+12]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-24],eax			;;; i670  
push	[ebp-24]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_SetConsoleScreenBufferSize@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0016.xio			;;; i195 
call	%s%Error%D			;;; i163  
else.0016.xio:  
end.if.0016.xio:  
jmp	out.subD.0.xio			;;; i262 
%s%Error%D: 
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
jmp	end.funcD.xio			;;; i258  
end.subD.0.xio: 
ret				;;; i127 
