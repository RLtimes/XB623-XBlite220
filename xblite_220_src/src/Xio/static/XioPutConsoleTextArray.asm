.code 
_XioPutConsoleTextArray@16: 
funcB.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.37: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.37			;;; ..... 
push	eax				;;; ......  
push	eax				;;; ......  
sub	esp,180			;;; i114a 
funcBodyB.xio:  
mov	eax,d[ebp+12]			;;; i665  
test	eax,eax			;;; i194 
jnz	>> else.000E.xio			;;; i195 
mov	eax,-1			;;; i659 
jmp	end.funcB.xio			;;; i258  
else.000E.xio:  
end.if.000E.xio:  
mov	eax,d[ebp+12]			;;; i665  
test	eax,eax			;;; i593 
jz	> A.32			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.32: 
dec	eax			;;; i596  
mov	d[ebp-24],eax			;;; i670  
mov	eax,0			;;; i659  
mov	d[ebp-28],eax			;;; i670  
mov	eax,d[ebp-24]			;;; i665  
mov	d[ebp-32],eax			;;; i670  
for.000F.xio: 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,d[ebp-32]			;;; i665  
cmp	eax,ebx			;;; i153  
jg	>> end.for.000F.xio			;;; i154 
push	[ebp+20]			;;; i674a 
push	[ebp+16]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-36],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
mov	edx,d[ebp+12]			;;; i665  
mov	eax,[edx+eax*4]			;;; i464  
mov	d[ebp-48],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
mov	edx,d[ebp+12]			;;; i665  
mov	eax,[edx+eax*4]			;;; i464  
test	eax,eax			;;; i586 
jz	> A.33			;;; i587  
mov	eax,d[eax-8]			;;; i589 
A.33: 
mov	d[ebp-56],eax			;;; i670  
lea	eax,[ebp-60]			;;; i642 
push	eax			;;; i667a  
push	[ebp-36]			;;; i674a 
push	[ebp-56]			;;; i674a 
push	[ebp-48]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_WriteConsoleOutputCharacterA@20			;;; i619  
mov	d[ebp-40],eax			;;; i670  
mov	eax,d[ebp-40]			;;; i665  
test	eax,eax			;;; i194 
jnz	>> else.0010.xio			;;; i195 
jmp	end.for.000F.xio			;;; i145 
else.0010.xio:  
end.if.0010.xio:  
inc	d[ebp+20]			;;; i84 
do.next.000F.xio: 
inc	d[ebp-28]			;;; i229  
jmp	for.000F.xio			;;; i231 
end.for.000F.xio: 
mov	eax,d[ebp-40]			;;; i665  
test	eax,eax			;;; i194 
jnz	>> else.0011.xio			;;; i195 
call	%s%Error%B			;;; i163  
else.0011.xio:  
end.if.0011.xio:  
jmp	out.subB.0.xio			;;; i262 
%s%Error%B: 
call	_GetLastError@0			;;; i619 
mov	d[ebp-68],eax			;;; i670  
push	[ebp-72]			;;; i674a 
push	[ebp-68]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-72],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-72]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-76],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.funcB.xio			;;; i258  
end.subB.0.xio: 
ret				;;; i127 
