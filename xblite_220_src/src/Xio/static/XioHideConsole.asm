.code 
_XioHideConsole@0:  
func13.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
funcBody13.xio: 
push	0			;;; i656a  
call	func1F.xio			;;; i619  
jmp	end.func13.xio			;;; i258 
xor	eax,eax			;;; i862  
end.XioHideConsole.xio:  ;;; Function end label for Assembly Programmers. 
end.func13.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
