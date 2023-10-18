.code 
_XioClearConsole@4: 
func12.xio: 
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
sub	esp,216			;;; i114a 
funcBody12.xio: 
push	0			;;; i656a  
push	[ebp+8]			;;; i674a  
call	_SetConsoleCursorPosition@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.001C.xio			;;; i195 
call	%s%Error%12			;;; i163 
else.001C.xio:  
end.if.001C.xio:  
lea	eax,[ebp-24]			;;; i642 
push	eax			;;; i667a  
push	0			;;; i656a  
push	16777215			;;; i656a 
push	32			;;; i656a 
push	[ebp+8]			;;; i674a  
call	_FillConsoleOutputCharacterA@20			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.001D.xio			;;; i195 
call	%s%Error%12			;;; i163 
else.001D.xio:  
end.if.001D.xio:  
jmp	out.sub12.0.xio			;;; i262  
%s%Error%12:  
call	_GetLastError@0			;;; i619 
mov	d[ebp-32],eax			;;; i670  
push	[ebp-36]			;;; i674a 
push	[ebp-32]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-36],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-36]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-40],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func12.xio			;;; i258 
end.sub12.0.xio:  
ret				;;; i127 
