.code 
_XioSetDefaultColors@4: 
func1D.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
funcBody1D.xio: 
push	7			;;; i656a  
push	[ebp+8]			;;; i674a  
call	func1A.xio			;;; i619  
jmp	end.func1D.xio			;;; i258 
xor	eax,eax			;;; i862  
end.XioSetDefaultColors.xio:  ;;; Function end label for Assembly Programmers.  
end.func1D.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
