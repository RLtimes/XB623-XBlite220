.code 
_XioCreateConsole@8:  
func15.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,2				;;; .. 
xor	eax,eax			;;; ... 
A.68: 
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.68			;;; ..... 
push	eax				;;; ......  
push	eax				;;; ......  
push	eax				;;; ......  
sub	esp,192			;;; i114a 
funcBody15.xio: 
data section 'globals$statics'  
align	4 
%15%entry.xio:	db 4 dup ? 
.code 
data section 'globals$shared' 
align	4 
%fCreateConsole.xio:	db 4 dup ? 
.code 
mov	eax,d[%15%entry.xio]			;;; i663a  
test	eax,eax			;;; i220 
jz	>> else.001E.xio			;;; i221  
sub	esp,64			;;; i487 
mov	eax,53			;;; i659 
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-24],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func15.xio			;;; i258 
else.001E.xio:  
end.if.001E.xio:  
call	_AllocConsole@0			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.001F.xio			;;; i195 
call	%s%Error%15			;;; i163 
else.001F.xio:  
end.if.001F.xio:  
mov	eax,-1			;;; i659 
mov	d[%15%entry.xio],eax			;;; i668 
mov	eax,-1			;;; i659 
mov	d[%fCreateConsole.xio],eax			;;; i668 
call	func7.xio			;;; i619 
mov	d[ebp-28],eax			;;; i670  
mov	eax,[ebp+8]			;;; i665  
test	eax,eax			;;; i188 
jz	> A.64			;;; i189  
mov	eax,d[eax-8]			;;; i190 
test	eax,eax			;;; i191 
jnz	>> else.0020.xio			;;; i192 
A.64: 
sub	esp,64			;;; i487 
mov	d[esp],256  
call	%_null.d			;;; i573  
add	esp,64			;;; i600 
lea	ebx,[ebp+8]			;;; i5  
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,d[ebp+8]			;;; i642 
mov	d[ebp-40],eax			;;; i670  
push	256			;;; i656a  
push	[ebp-40]			;;; i674a 
push	0			;;; i656a  
call	_GetModuleFileNameA@12			;;; i619  
mov	d[ebp-32],eax			;;; i670  
sub	esp,64			;;; i487 
mov	eax,[ebp+8]			;;; i665  
mov	d[esp],eax			;;; i887 
mov	eax,d[ebp-32]			;;; i665  
mov	d[esp+4],eax			;;; i887 
call	%_left.d.v			;;; i578  
add	esp,64			;;; i600 
lea	ebx,[ebp+8]			;;; i5  
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
sub	esp,64			;;; i487 
mov	eax,[ebp+8]			;;; i665  
mov	d[esp],eax			;;; i887 
mov	eax,addr @_string.0111.xio			;;; i663 
mov	d[esp+4],eax			;;; i887 
mov	d[esp+8],0			;;; i571 
call	%_rinstr.vv			;;; i572 
add	esp,64			;;; i600 
mov	d[ebp-44],eax			;;; i670  
mov	eax,d[ebp-44]			;;; i665  
test	eax,eax			;;; i220 
jz	>> else.0021.xio			;;; i221  
sub	esp,64			;;; i487 
mov	eax,[ebp+8]			;;; i665  
mov	d[esp],eax			;;; i887 
mov	eax,d[ebp+8]			;;; i665 
test	eax,eax			;;; i593 
jz	> A.65			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.65: 
mov	ebx,d[ebp-44]			;;; i665  
sub	eax,ebx			;;; i791  
mov	d[esp+4],eax			;;; i887 
call	%_right.d.v			;;; i578 
add	esp,64			;;; i600 
lea	ebx,[ebp+8]			;;; i5  
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
else.0021.xio:  
end.if.0021.xio:  
else.0020.xio:  
end.if.0020.xio:  
mov	eax,d[ebp+8]			;;; i642 
push	eax			;;; i667a  
call	_SetConsoleTitleA@4			;;; i619 
mov	eax,80			;;; i659 
mov	d[ebp-48],eax			;;; i670  
mov	eax,d[ebp+12]			;;; i665  
cmp	eax,25			;;; i684a  
jge	>> else.0022.xio			;;; i219 
mov	eax,25			;;; i659 
mov	d[ebp+12],eax			;;; i670  
else.0022.xio:  
end.if.0022.xio:  
push	[ebp+12]			;;; i674a 
push	[ebp-48]			;;; i674a 
call	_MAKELONG@8			;;; i619 
mov	d[ebp-52],eax			;;; i670  
push	[ebp-52]			;;; i674a 
push	[ebp-28]			;;; i674a 
call	_SetConsoleScreenBufferSize@8			;;; i619 
test	eax,eax			;;; i194 
jnz	>> else.0023.xio			;;; i195 
call	%s%Error%15			;;; i163 
else.0023.xio:  
end.if.0023.xio:  
push	[ebp-28]			;;; i674a 
call	_CloseHandle@4			;;; i619  
jmp	out.sub15.0.xio			;;; i262  
%s%Error%15:  
push	[ebp-28]			;;; i674a 
call	_CloseHandle@4			;;; i619  
call	_GetLastError@0			;;; i619 
mov	d[ebp-60],eax			;;; i670  
push	[ebp-64]			;;; i674a 
push	[ebp-60]			;;; i674a 
call	_XstSystemErrorToError@8			;;; i619  
mov	esi,d[esp-4]			;;; i877 
mov	d[ebp-64],esi			;;; i670  
sub	esp,64			;;; i487 
mov	eax,d[ebp-64]			;;; i665  
call	%_error  
add	esp,64			;;; i600 
mov	d[ebp-24],eax			;;; i670  
mov	eax,-1			;;; i659 
jmp	end.func15.xio			;;; i258 
end.sub15.0.xio:  
ret				;;; i127 
