.code 
_XioScrollBufferUp@8: 
funcC.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.40: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.40			;;; ..... 
sub	esp,188			;;; i114a 
mov	esi,36			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
lea	ecx,[esi+24]			;;; i125 
mov	d[ebp-32],ecx			;;; i670  
lea	edx,[esi+32]			;;; i125a  
mov	d[ebp-36],edx			;;; i670  
funcBodyC.xio:  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_GetConsoleScreenBufferInfo@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0012.xio			;;; i195 
call	%s%Error%C			;;; i163  
else.0012.xio:  
end.if.0012.xio:  
mov	eax,d[ebp-32]			;;; i665  
mov	ebx,d[ebp+12]			;;; i665  
mov	w[eax+2],bx			;;; i13b  
mov	eax,d[ebp-32]			;;; i665  
mov	ebx,0			;;; i659  
mov	w[eax],bx			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+2]			;;; i313b  
sub	eax,1			;;; i784  
into				;;; i785  
mov	ebx,d[ebp-32]			;;; i665  
mov	w[ebx+6],ax			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
sub	eax,1			;;; i784  
into				;;; i785  
mov	ebx,d[ebp-32]			;;; i665  
mov	w[ebx+4],ax			;;; i13b  
push	0			;;; i656a  
push	0			;;; i656a  
call	_MAKELONG@8			;;; i619 
mov	d[ebp-40],eax			;;; i670  
mov	eax,d[ebp-36]			;;; i665  
mov	ebx,32			;;; i659 
mov	b[eax],bl			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+8]			;;; i313b  
mov	ebx,d[ebp-36]			;;; i665  
mov	w[ebx+2],ax			;;; i13b  
mov	eax,d[ebp-32]			;;; i642  
mov	d[ebp-48],eax			;;; i670  
mov	eax,d[ebp-36]			;;; i642  
push	eax			;;; i667a  
push	[ebp-40]			;;; i674a 
push	[ebp-52]			;;; i674a 
push	[ebp-48]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_ScrollConsoleScreenBufferA@20			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.0013.xio			;;; i195 
call	%s%Error%C			;;; i163  
else.0013.xio:  
end.if.0013.xio:  
jmp	out.subC.0.xio			;;; i262 
%s%Error%C: 
call	_GetLastError@0			;;; i619 
mov	d[ebp-60],eax			;;; i670  
push	[ebp-64]			;;; i674a 
push	[ebp-60]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-64],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-64]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-68],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.funcC.xio			;;; i258  
end.subC.0.xio: 
ret				;;; i127 
