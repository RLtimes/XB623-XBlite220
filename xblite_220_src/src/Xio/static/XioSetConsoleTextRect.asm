.code 
_XioSetConsoleTextRect@24:  
funcF.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,2				;;; .. 
xor	eax,eax			;;; ... 
A.50: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.50			;;; ..... 
push	eax				;;; ......  
push	eax				;;; ......  
push	eax				;;; ......  
sub	esp,192			;;; i114a 
mov	esi,8			;;; i124a 
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBodyF.xio:  
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,d[ebp+12]			;;; i665  
mov	w[eax],bx			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,d[ebp+16]			;;; i665  
mov	w[eax+2],bx			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,d[ebp+20]			;;; i665  
mov	w[eax+4],bx			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,d[ebp+24]			;;; i665  
mov	w[eax+6],bx			;;; i13b  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+4]			;;; i313b  
mov	ebx,d[ebp-28]			;;; i665  
movzx	ebx,w[ebx]			;;; i313b  
sub	eax,ebx			;;; i784  
into				;;; i785  
add	eax,1			;;; i770  
into				;;; i771  
mov	d[ebp-40],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+6]			;;; i313b  
mov	ebx,d[ebp-28]			;;; i665  
movzx	ebx,w[ebx+2]			;;; i313b  
sub	eax,ebx			;;; i784  
into				;;; i785  
add	eax,1			;;; i770  
into				;;; i771  
push	eax			;;; i667a  
push	[ebp-40]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-32],eax			;;; i670  
push	0			;;; i656a  
push	0			;;; i656a  
call	_MAKELONG@8			;;; i619 
mov	d[ebp-44],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+4]			;;; i313b  
mov	ebx,d[ebp-28]			;;; i665  
movzx	ebx,w[ebx]			;;; i313b  
sub	eax,ebx			;;; i784  
into				;;; i785  
add	eax,1			;;; i770  
into				;;; i771  
mov	ebx,d[ebp-28]			;;; i665  
movzx	ebx,w[ebx+6]			;;; i313b  
mov	d[ebp-40],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+2]			;;; i313b  
xchg	eax,ebx			;;; i783 
sub	eax,ebx			;;; i784  
into				;;; i785  
add	eax,1			;;; i770  
into				;;; i771  
mov	ebx,d[ebp-40]			;;; i665  
imul	eax,ebx			;;; i801 
jnc	> A.47			;;; i802 
call	%_eeeOverflow			;;; i803 
A.47: 
mov	d[ebp-48],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp-44]			;;; i674a 
push	[ebp-32]			;;; i674a 
push	[ebp+28]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_WriteConsoleOutputA@20			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0018.xio			;;; i195 
call	%s%Error%F			;;; i163  
else.0018.xio:  
end.if.0018.xio:  
jmp	out.subF.0.xio			;;; i262 
%s%Error%F: 
call	_GetLastError@0			;;; i619 
mov	d[ebp-56],eax			;;; i670  
push	[ebp-60]			;;; i674a 
push	[ebp-56]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-60],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-60]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-64],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.funcF.xio			;;; i258  
end.subF.0.xio: 
ret				;;; i127 
