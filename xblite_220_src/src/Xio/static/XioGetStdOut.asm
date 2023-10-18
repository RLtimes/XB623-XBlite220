.code 
_XioGetStdOut@0:  
func7.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
funcBody7.xio:  
mov	eax,addr @_string.009F.xio			;;; i663 
call	%_clone.a0			;;; i634  
push	eax			;;; i667a  
call	func20.xio			;;; i619  
sub	esp,4			;;; xnt1i 
mov	esi,d[esp]			;;; i871 
call	%____free			;;; i872 
add	esp,4			;;; i633  
jmp	end.func7.xio			;;; i258  
xor	eax,eax			;;; i862  
end.XioGetStdOut.xio:  ;;; Function end label for Assembly Programmers. 
end.func7.xio:  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
