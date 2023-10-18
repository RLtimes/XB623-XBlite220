.code 
_XioReadConsole@8:  
func18.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.80: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.80			;;; ..... 
sub	esp,188			;;; i114a 
funcBody18.xio: 
push	[ebp+8]			;;; i674a  
call	_FlushConsoleInputBuffer@4			;;; i619  
sub	esp,64			;;; i487 
mov	d[esp],8192 
call	%_null.d			;;; i573  
add	esp,64			;;; i600 
lea	ebx,[ebp-24]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,d[ebp-24]			;;; i642  
mov	d[ebp-32],eax			;;; i670  
mov	eax,d[ebp-24]			;;; i665  
test	eax,eax			;;; i593 
jz	> A.77			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.77: 
mov	d[ebp-40],eax			;;; i670  
lea	eax,[ebp-44]			;;; i642 
mov	d[ebp-52],eax			;;; i670  
push	0			;;; i656a  
push	[ebp-52]			;;; i674a 
push	[ebp-40]			;;; i674a 
push	[ebp-32]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_ReadFile@20			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.0027.xio			;;; i195 
call	%s%Error%18			;;; i163 
else.0027.xio:  
end.if.0027.xio:  
sub	esp,64			;;; i487 
mov	eax,[ebp-24]			;;; i665 
mov	d[esp],eax			;;; i887 
mov	d[esp+4],1  
mov	eax,d[ebp-44]			;;; i665  
sub	eax,2			;;; i791  
mov	d[esp+8],eax			;;; i887 
call	%_mid.d.v			;;; i580 
add	esp,64			;;; i600 
lea	ebx,[ebp+12]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
jmp	out.sub18.0.xio			;;; i262  
%s%Error%18:  
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
jmp	end.func18.xio			;;; i258 
end.sub18.0.xio:  
ret				;;; i127 
