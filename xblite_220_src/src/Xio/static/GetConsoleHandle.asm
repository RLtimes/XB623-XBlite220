.code 
GetConsoleHandle@4.xio: 
func20.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,4				;;; .. 
xor	eax,eax			;;; ... 
A.108:  
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.108			;;; .....  
sub	esp,172			;;; i114a 
mov	esi,12			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody20.xio: 
mov	eax,12			;;; i584 
mov	ebx,d[ebp-28]			;;; i665  
mov	d[ebx],eax			;;; i13b 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,d[ebp-32]			;;; i665  
mov	d[eax+4],ebx			;;; i13b 
mov	eax,d[ebp-28]			;;; i665  
mov	ebx,-1			;;; i659 
mov	d[eax+8],ebx			;;; i13b 
mov	eax,d[ebp+8]			;;; i642 
mov	d[ebp-44],eax			;;; i670  
mov	eax,-2147483648			;;; i657  
or	eax,1073741824			;;; i763  
mov	d[ebp-52],eax			;;; i670  
mov	eax,1			;;; i659  
or	eax,2			;;; i763 
mov	d[ebp-60],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i642  
mov	d[ebp-68],eax			;;; i670  
push	0			;;; i656a  
push	0			;;; i656a  
push	3			;;; i656a  
push	[ebp-68]			;;; i674a 
push	[ebp-60]			;;; i674a 
push	[ebp-52]			;;; i674a 
push	[ebp-44]			;;; i674a 
call	_CreateFileA@28			;;; i619 
mov	d[ebp-36],eax			;;; i670  
mov	eax,d[ebp-36]			;;; i665  
cmp	eax,-1			;;; i684a  
jne	>> else.003D.xio			;;; i219 
call	%s%Error%20			;;; i163 
else.003D.xio:  
end.if.003D.xio:  
mov	eax,d[ebp-36]			;;; i665  
jmp	end.func20.xio			;;; i258 
jmp	out.sub20.0.xio			;;; i262  
%s%Error%20:  
call	_GetLastError@0			;;; i619 
mov	d[ebp-76],eax			;;; i670  
push	[ebp-80]			;;; i674a 
push	[ebp-76]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-80],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-80]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-84],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func20.xio			;;; i258 
end.sub20.0.xio:  
ret				;;; i127 
