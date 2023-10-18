.code 
_XioWriteConsole@8: 
func17.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,2				;;; .. 
xor	eax,eax			;;; ... 
A.76: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.76			;;; ..... 
push	eax				;;; ......  
push	eax				;;; ......  
push	eax				;;; ......  
sub	esp,192			;;; i114a 
funcBody17.xio: 
mov	eax,d[ebp+12]			;;; i642  
mov	d[ebp-28],eax			;;; i670  
mov	eax,d[ebp+12]			;;; i665  
test	eax,eax			;;; i593 
jz	> A.73			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.73: 
mov	d[ebp-36],eax			;;; i670  
lea	eax,[ebp-40]			;;; i642 
mov	d[ebp-48],eax			;;; i670  
push	0			;;; i656a  
push	[ebp-48]			;;; i674a 
push	[ebp-36]			;;; i674a 
push	[ebp-28]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_WriteFile@20			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0026.xio			;;; i195 
call	%s%Error%17			;;; i163 
else.0026.xio:  
end.if.0026.xio:  
jmp	out.sub17.0.xio			;;; i262  
%s%Error%17:  
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
jmp	end.func17.xio			;;; i258 
end.sub17.0.xio:  
ret				;;; i127 
