.code 
_XioPutConsoleText@16:  
funcA.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,2				;;; .. 
xor	eax,eax			;;; ... 
A.31: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.31			;;; ..... 
push	eax				;;; ......  
push	eax				;;; ......  
sub	esp,196			;;; i114a 
funcBodyA.xio:  
mov	eax,[ebp+12]			;;; i665 
test	eax,eax			;;; i188 
jz	> A.27			;;; i189  
mov	eax,d[eax-8]			;;; i190 
test	eax,eax			;;; i191 
jnz	>> else.000C.xio			;;; i192 
A.27: 
mov	eax,-1			;;; i659 
jmp	end.funcA.xio			;;; i258  
else.000C.xio:  
end.if.000C.xio:  
push	[ebp+20]			;;; i674a 
push	[ebp+16]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-24],eax			;;; i670  
mov	eax,d[ebp+12]			;;; i642  
mov	d[ebp-32],eax			;;; i670  
mov	eax,d[ebp+12]			;;; i665  
test	eax,eax			;;; i593 
jz	> A.28			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.28: 
mov	d[ebp-40],eax			;;; i670  
lea	eax,[ebp-44]			;;; i642 
push	eax			;;; i667a  
push	[ebp-24]			;;; i674a 
push	[ebp-40]			;;; i674a 
push	[ebp-32]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_WriteConsoleOutputCharacterA@20			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.000D.xio			;;; i195 
call	%s%Error%A			;;; i163  
else.000D.xio:  
end.if.000D.xio:  
jmp	out.subA.0.xio			;;; i262 
%s%Error%A: 
call	_GetLastError@0			;;; i619 
mov	d[ebp-52],eax			;;; i670  
push	[ebp-56]			;;; i674a 
push	[ebp-52]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-56],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-56]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-60],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.funcA.xio			;;; i258  
end.subA.0.xio: 
ret				;;; i127 
