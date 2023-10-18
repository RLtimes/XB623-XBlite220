.code 
_XioGetConsoleInfo@24:  
func4.xio:  
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
push	eax			;;; .. 
sub	esp,212			;;; i114a 
mov	esi,22			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody4.xio:  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_GetConsoleScreenBufferInfo@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0006.xio			;;; i195 
call	%s%Error%4			;;; i163  
else.0006.xio:  
end.if.0006.xio:  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
mov	d[ebp+12],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+2]			;;; i313b  
mov	d[ebp+16],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+4]			;;; i313b  
mov	d[ebp+20],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+6]			;;; i313b  
mov	d[ebp+24],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+8]			;;; i313b  
mov	d[ebp+28],eax			;;; i670  
jmp	out.sub4.0.xio			;;; i262 
%s%Error%4: 
call	_GetLastError@0			;;; i619 
mov	d[ebp-36],eax			;;; i670  
push	[ebp-40]			;;; i674a 
push	[ebp-36]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-40],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-40]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-44],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func4.xio			;;; i258  
end.sub4.0.xio: 
ret				;;; i127 
