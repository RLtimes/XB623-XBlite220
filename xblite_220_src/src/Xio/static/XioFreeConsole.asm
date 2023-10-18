.code 
_XioFreeConsole@0:  
func19.xio: 
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
sub	esp,224			;;; i114a 
funcBody19.xio: 
mov	eax,d[%fCreateConsole.xio]			;;; i663a  
test	eax,eax			;;; i194 
jnz	>> else.0028.xio			;;; i195 
sub	esp,64			;;; i487 
mov	eax,48			;;; i659 
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-24],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func19.xio			;;; i258 
else.0028.xio:  
end.if.0028.xio:  
call	_FreeConsole@0			;;; i619  
test	eax,eax			;;; i194 
jnz	>> else.0029.xio			;;; i195 
call	_GetLastError@0			;;; i619 
mov	d[ebp-28],eax			;;; i670  
push	[ebp-32]			;;; i674a 
push	[ebp-28]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-32],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-32]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-24],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func19.xio			;;; i258 
else.0029.xio:  
end.if.0029.xio:  
xor	eax,eax			;;; i862  
end.XioFreeConsole.xio:  ;;; Function end label for Assembly Programmers. 
end.func19.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
