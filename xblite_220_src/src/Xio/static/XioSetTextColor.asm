.code 
_XioSetTextColor@8: 
func1C.xio: 
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
mov	esi,22			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody1C.xio: 
mov	eax,d[ebp-28]			;;; i642  
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_GetConsoleScreenBufferInfo@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.002D.xio			;;; i195 
call	%s%Error%1C			;;; i163 
else.002D.xio:  
end.if.002D.xio:  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+8]			;;; i313b  
and	eax,240			;;; i769  
mov	d[ebp-32],eax			;;; i670  
mov	eax,d[ebp-32]			;;; i665  
mov	ebx,d[ebp+12]			;;; i665  
or	eax,ebx			;;; i763 
push	eax			;;; i667a  
push	[ebp+8]			;;; i674a  
call	_SetConsoleTextAttribute@8			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.002E.xio			;;; i195 
call	%s%Error%1C			;;; i163 
else.002E.xio:  
end.if.002E.xio:  
jmp	out.sub1C.0.xio			;;; i262  
%s%Error%1C:  
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
jmp	end.func1C.xio			;;; i258 
end.sub1C.0.xio:  
ret				;;; i127 
