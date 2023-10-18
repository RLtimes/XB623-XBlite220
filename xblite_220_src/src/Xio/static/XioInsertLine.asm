.code 
_XioInsertLine@4: 
func9.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.26: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.26			;;; ..... 
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
funcBody9.xio:  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_GetConsoleScreenBufferInfo@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.000A.xio			;;; i195 
call	%s%Error%9			;;; i163  
else.000A.xio:  
end.if.000A.xio:  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+6]			;;; i313b  
mov	ebx,d[ebp-32]			;;; i665  
mov	w[ebx+2],ax			;;; i13b  
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
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+6]			;;; i313b  
add	eax,1			;;; i770  
into				;;; i771  
push	eax			;;; i667a  
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
jnz	>> else.000B.xio			;;; i195 
call	%s%Error%9			;;; i163  
else.000B.xio:  
end.if.000B.xio:  
jmp	out.sub9.0.xio			;;; i262 
%s%Error%9: 
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
jmp	end.func9.xio			;;; i258  
end.sub9.0.xio: 
ret				;;; i127 
