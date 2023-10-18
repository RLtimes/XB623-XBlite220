.code 
_XioClearEndOfLine@4: 
func2.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.6:  
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.6			;;; .....  
sub	esp,188			;;; i114a 
mov	esi,22			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody2.xio:  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_GetConsoleScreenBufferInfo@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0001.xio			;;; i195 
call	%s%Error%2			;;; i163  
else.0001.xio:  
end.if.0001.xio:  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+4]			;;; i313b  
mov	d[ebp-40],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+6]			;;; i313b  
push	eax			;;; i667a  
push	[ebp-40]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-32],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
mov	ebx,d[ebp-28]			;;; i665  
movzx	ebx,w[ebx+4]			;;; i313b  
sub	eax,ebx			;;; i784  
into				;;; i785  
mov	d[ebp-40],eax			;;; i670  
lea	eax,[ebp-44]			;;; i642 
push	eax			;;; i667a  
push	[ebp-32]			;;; i674a 
push	[ebp-40]			;;; i674a 
push	32			;;; i656a 
push	[ebp+8]			;;; i674a  
call	_FillConsoleOutputCharacterA@20			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0002.xio			;;; i195 
call	%s%Error%2			;;; i163  
else.0002.xio:  
end.if.0002.xio:  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+8]			;;; i313b  
mov	d[ebp-40],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
mov	ebx,d[ebp-28]			;;; i665  
movzx	ebx,w[ebx+4]			;;; i313b  
sub	eax,ebx			;;; i784  
into				;;; i785  
mov	d[ebp-52],eax			;;; i670  
lea	eax,[ebp-44]			;;; i642 
push	eax			;;; i667a  
push	[ebp-32]			;;; i674a 
push	[ebp-52]			;;; i674a 
push	[ebp-40]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_FillConsoleOutputAttribute@20			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.0003.xio			;;; i195 
call	%s%Error%2			;;; i163  
else.0003.xio:  
end.if.0003.xio:  
jmp	out.sub2.0.xio			;;; i262 
%s%Error%2: 
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
jmp	end.func2.xio			;;; i258  
end.sub2.0.xio: 
ret				;;; i127 
