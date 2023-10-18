.code 
_XioShowConsole@0:  
func14.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
funcBody14.xio: 
push	5			;;; i656a  
call	func1F.xio			;;; i619  
jmp	end.func14.xio			;;; i258 
xor	eax,eax			;;; i862  
end.XioShowConsole.xio:  ;;; Function end label for Assembly Programmers. 
end.func14.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
