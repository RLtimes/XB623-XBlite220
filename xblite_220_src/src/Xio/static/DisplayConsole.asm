.code 
DisplayConsole@4.xio: 
func1F.xio: 
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
funcBody1F.xio: 
call	func16.xio			;;; i619  
mov	d[ebp-24],eax			;;; i670  
mov	eax,d[ebp-24]			;;; i665  
test	eax,eax			;;; i220 
jz	>> else.003C.xio			;;; i221  
push	[ebp+8]			;;; i674a  
push	[ebp-24]			;;; i674a 
call	_ShowWindow@8			;;; i619 
jmp	end.if.003C.xio			;;; i107  
else.003C.xio:  
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
mov	d[ebp-36],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func1F.xio			;;; i258 
end.if.003C.xio:  
xor	eax,eax			;;; i862  
end.DisplayConsole.xio:  ;;; Function end label for Assembly Programmers. 
end.func1F.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
