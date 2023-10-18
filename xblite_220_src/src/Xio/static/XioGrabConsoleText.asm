.code 
_XioGrabConsoleText@8:  
func8.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.23: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.23			;;; ..... 
push	eax				;;; ......  
sub	esp,184			;;; i114a 
mov	esi,22			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody8.xio:  
xor	eax,eax 
lea	ebx,[ebp+12]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_GetConsoleScreenBufferInfo@8			;;; i619 
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+6]			;;; i313b  
mov	ebx,1			;;; i659  
add	eax,ebx			;;; i770  
into				;;; i771  
mov	d[ebp-32],eax			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
mov	d[esp],eax			;;; i887 
call	%_null.d			;;; i573  
add	esp,64			;;; i600 
lea	ebx,[ebp-36]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,0			;;; i659  
mov	d[ebp-40],eax			;;; i670  
push	[ebp-40]			;;; i674a 
push	0			;;; i656a  
call	_MAKELONG@8			;;; i619 
mov	d[ebp-44],eax			;;; i670  
do.0008.xio:  
mov	eax,d[ebp-32]			;;; i665  
test	eax,eax			;;; i220 
jz	>> end.do.0008.xio			;;; i221  
mov	eax,d[ebp-36]			;;; i642  
mov	d[ebp-52],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
mov	d[ebp-60],eax			;;; i670  
lea	eax,[ebp-64]			;;; i642 
push	eax			;;; i667a  
push	[ebp-44]			;;; i674a 
push	[ebp-60]			;;; i674a 
push	[ebp-52]			;;; i674a 
push	[ebp+8]			;;; i674a  
call	_ReadConsoleOutputCharacterA@20			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0009.xio			;;; i195 
call	_GetLastError@0			;;; i619 
mov	d[ebp-68],eax			;;; i670  
push	[ebp-72]			;;; i674a 
push	[ebp-68]			;;; i674a 
call	_XstSystemErrorNumberToName@8			;;; i619 
mov	esi,d[esp-4]			;;; i877 
mov	[ebp-72],esi			;;; i670 
xor	eax,eax 
lea	ebx,[ebp+12]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,-1			;;; i659 
jmp	end.func8.xio			;;; i258  
else.0009.xio:  
end.if.0009.xio:  
sub	esp,64			;;; i487 
mov	eax,[ebp-36]			;;; i665 
mov	d[esp],eax			;;; i887 
mov	eax,d[ebp-64]			;;; i665  
mov	d[esp+4],eax			;;; i887 
call	%_left.d.v			;;; i578  
add	esp,64			;;; i600 
mov	ebx,[ebp+12]			;;; i665 
call	%_concat.ubyte.a0.eq.a1.plus.a0.vs			;;; i782  
lea	ebx,[ebp+12]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
inc	d[ebp-40]			;;; i84 
push	[ebp-40]			;;; i674a 
push	0			;;; i656a  
call	_MAKELONG@8			;;; i619 
mov	d[ebp-44],eax			;;; i670  
dec	d[ebp-32]			;;; i84 
do.loop.0008.xio: 
jmp	do.0008.xio			;;; i222  
end.do.0008.xio:  
xor	eax,eax			;;; i862  
end.XioGrabConsoleText.xio:  ;;; Function end label for Assembly Programmers. 
end.func8.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
mov	esi,[ebp-72]			;;; i665 
call	%____free			;;; i423 
mov	d[ebp-72],ebx			;;; i670  
mov	esi,[ebp-36]			;;; i665 
call	%____free			;;; i423 
mov	d[ebp-36],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
