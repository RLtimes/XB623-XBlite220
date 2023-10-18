.code 
_XioSetCursorType@8:  
func10.xio: 
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
push	eax			;;; .. 
sub	esp,208			;;; i114a 
mov	esi,8			;;; i124a 
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody10.xio: 
mov	eax,d[ebp+12]			;;; i665  
mov	d[ebp-32],eax			;;; i670  
mov	eax,0			;;; i659  
mov	ebx,d[ebp-32]			;;; i665  
cmp	eax,ebx			;;; i684a 
jne	>> case.0019.0001.xio			;;; i71 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,10			;;; i659 
mov	d[eax],ebx			;;; i13b 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,0			;;; i659  
mov	d[eax+4],ebx			;;; i13b 
jmp	end.select.0019.xio			;;; i69 
case.0019.0001.xio: 
mov	eax,1			;;; i659  
mov	ebx,d[ebp-32]			;;; i665  
cmp	eax,ebx			;;; i684a 
jne	>> case.0019.0002.xio			;;; i71 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,99			;;; i659 
mov	d[eax],ebx			;;; i13b 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,-1			;;; i659 
mov	d[eax+4],ebx			;;; i13b 
jmp	end.select.0019.xio			;;; i69 
case.0019.0002.xio: 
mov	eax,2			;;; i659  
mov	ebx,d[ebp-32]			;;; i665  
cmp	eax,ebx			;;; i684a 
jne	>> case.0019.0003.xio			;;; i71 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,10			;;; i659 
mov	d[eax],ebx			;;; i13b 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,-1			;;; i659 
mov	d[eax+4],ebx			;;; i13b 
case.0019.0003.xio: 
end.select.0019.xio:  
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_SetConsoleCursorInfo@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.001A.xio			;;; i195 
call	%s%Error%10			;;; i163 
else.001A.xio:  
end.if.001A.xio:  
jmp	out.sub10.0.xio			;;; i262  
%s%Error%10:  
call	_GetLastError@0			;;; i619 
mov	d[ebp-40],eax			;;; i670  
push	[ebp-44]			;;; i674a 
push	[ebp-40]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-44],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-44]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-48],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func10.xio			;;; i258 
end.sub10.0.xio:  
ret				;;; i127 
