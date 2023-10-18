.code 
_XioGetConsoleWindow@0: 
func16.xio: 
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
sub	esp,220			;;; i114a 
funcBody16.xio: 
sub	esp,64			;;; i487 
mov	d[esp],128  
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
jz	> A.69			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.69: 
push	eax			;;; i667a  
push	[ebp-32]			;;; i674a 
call	_GetConsoleTitleA@8			;;; i619 
sub	esp,64			;;; i487 
mov	eax,[ebp-24]			;;; i665 
mov	d[esp],eax			;;; i887 
call	%_csize.d.v			;;; i583 
add	esp,64			;;; i600 
lea	ebx,[ebp-24]			;;; i5 
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,d[ebp-24]			;;; i642  
push	eax			;;; i667a  
push	0			;;; i656a  
call	_FindWindowA@8			;;; i619  
mov	d[ebp-36],eax			;;; i670  
mov	eax,d[ebp-36]			;;; i665  
test	eax,eax			;;; i194 
jnz	>> else.0024.xio			;;; i195 
call	_GetForegroundWindow@0			;;; i619  
mov	d[ebp-36],eax			;;; i670  
else.0024.xio:  
end.if.0024.xio:  
mov	eax,d[ebp-36]			;;; i665  
test	eax,eax			;;; i194 
jnz	>> else.0025.xio			;;; i195 
mov	eax,-1			;;; i659 
jmp	end.func16.xio			;;; i258 
jmp	end.if.0025.xio			;;; i107  
else.0025.xio:  
mov	eax,d[ebp-36]			;;; i665  
jmp	end.func16.xio			;;; i258 
end.if.0025.xio:  
xor	eax,eax			;;; i862  
end.XioGetConsoleWindow.xio:  ;;; Function end label for Assembly Programmers.  
end.func16.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,[ebp-24]			;;; i665 
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
