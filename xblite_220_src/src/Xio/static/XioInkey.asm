.code 
_XioInkey@0:  
func1E.xio: 
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
mov	ecx,3				;;; .. 
xor	eax,eax			;;; ... 
A.102:  
push	eax, eax, eax, eax 
dec	ecx					;;; ....  
jnz	 < A.102			;;; .....  
push	eax				;;; ......  
sub	esp,184			;;; i114a 
mov	esi,20			;;; i124a  
call	%____calloc			;;; i124b  
mov	d[ebp-24],esi			;;; i670  
lea	edx,[esi]			;;; i125a 
mov	d[ebp-28],edx			;;; i670  
funcBody1E.xio: 
data section 'globals$statics'  
align	4 
%1E%u$.xio:	db 4 dup ?  
.code 
data section 'globals$statics'  
align	4 
%1E%l$.xio:	db 4 dup ?  
.code 
data section 'globals$statics'  
align	4 
%1E%entry.xio:	db 4 dup ? 
.code 
data section 'globals$statics'  
align	4 
%1E%hStdIn.xio:	db 4 dup ?  
.code 
data section 'globals$statics'  
align	4 
%1E%upper.xio:	db 4 dup ? 
.code 
mov	eax,d[%1E%entry.xio]			;;; i663a  
test	eax,eax			;;; i194 
jnz	>> else.002F.xio			;;; i195 
call	%s%Initialize%1E			;;; i163  
else.002F.xio:  
end.if.002F.xio:  
lea	eax,[ebp-32]			;;; i642 
push	eax			;;; i667a  
push	[%1E%hStdIn.xio]			;;; i672a 
call	_GetConsoleMode@8			;;; i619 
mov	eax,2			;;; i659  
not	eax			;;; i923  
mov	ebx,d[ebp-32]			;;; i665  
and	eax,ebx			;;; i769  
mov	ebx,4			;;; i659  
not	ebx			;;; i923  
and	eax,ebx			;;; i769  
push	eax			;;; i667a  
push	[%1E%hStdIn.xio]			;;; i672a 
call	_SetConsoleMode@8			;;; i619 
mov	eax,d[ebp-28]			;;; i642  
mov	d[ebp-40],eax			;;; i670  
lea	eax,[ebp-44]			;;; i642 
push	eax			;;; i667a  
push	1			;;; i656a  
push	[ebp-40]			;;; i674a 
push	[%1E%hStdIn.xio]			;;; i672a 
call	_PeekConsoleInputA@16			;;; i619 
mov	eax,d[ebp-44]			;;; i665  
test	eax,eax			;;; i220 
jz	>> else.0030.xio			;;; i221  
mov	eax,d[ebp-28]			;;; i642  
mov	d[ebp-40],eax			;;; i670  
lea	eax,[ebp-44]			;;; i642 
push	eax			;;; i667a  
push	1			;;; i656a  
push	[ebp-40]			;;; i674a 
push	[%1E%hStdIn.xio]			;;; i672a 
call	_ReadConsoleInputA@16			;;; i619 
push	[ebp-32]			;;; i674a 
push	[%1E%hStdIn.xio]			;;; i672a 
call	_SetConsoleMode@8			;;; i619 
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax]			;;; i313b  
cmp	eax,1			;;; i684a 
mov	eax,0			;;; i466  
jne	> A.95			;;; i467 
not	eax			;;; i468  
A.95: 
mov	ebx,d[ebp-44]			;;; i665  
neg	eax			;;; i745  
rcr	eax,1			;;; i746  
sar	eax,31			;;; i747 
mov	edx,ebx			;;; i748  
neg	edx			;;; i749  
rcr	edx,1			;;; i750  
sar	edx,31			;;; i751 
and	eax,edx			;;; i752  
mov	ebx,d[ebp-28]			;;; i665  
mov	ebx,d[ebx+4]			;;; i313b  
neg	eax			;;; i745  
rcr	eax,1			;;; i746  
sar	eax,31			;;; i747 
mov	edx,ebx			;;; i748  
neg	edx			;;; i749  
rcr	edx,1			;;; i750  
sar	edx,31			;;; i751 
and	eax,edx			;;; i752  
test	eax,eax			;;; i220 
jz	>> else.0031.xio			;;; i221  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+10]			;;; i313b 
mov	d[ebp-48],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,w[eax+12]			;;; i313b 
mov	d[ebp-52],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
movzx	eax,b[eax+14]			;;; i313b 
mov	d[ebp-56],eax			;;; i670  
mov	eax,d[ebp-28]			;;; i665  
mov	eax,d[eax+16]			;;; i313b 
mov	d[ebp-60],eax			;;; i670  
mov	eax,d[ebp-56]			;;; i665  
neg	eax			;;; i888  
cmc				;;; i889 
rcr	eax,1			;;; i890  
sar	eax,31			;;; i891 
mov	ebx,d[ebp-52]			;;; i665  
cmp	ebx,58			;;; i684a  
mov	ebx,0			;;; i466  
jle	> A.96			;;; i467 
not	ebx			;;; i468  
A.96: 
neg	eax			;;; i745  
rcr	eax,1			;;; i746  
sar	eax,31			;;; i747 
mov	edx,ebx			;;; i748  
neg	edx			;;; i749  
rcr	edx,1			;;; i750  
sar	edx,31			;;; i751 
and	eax,edx			;;; i752  
test	eax,eax			;;; i220 
jz	>> else.0032.xio			;;; i221  
mov	eax,d[ebp-60]			;;; i665  
and	eax,3			;;; i769  
test	eax,eax			;;; i220 
jz	>> else.0033.xio			;;; i221  
mov	eax,1000			;;; i659 
mov	ebx,d[ebp-52]			;;; i665  
add	eax,ebx			;;; i775  
mov	ebx,1			;;; i659  
neg	ebx			;;; i916  
imul	eax,ebx			;;; i805 
jmp	end.func1E.xio			;;; i258 
else.0033.xio:  
end.if.0033.xio:  
mov	eax,d[ebp-60]			;;; i665  
and	eax,12			;;; i769 
test	eax,eax			;;; i220 
jz	>> else.0034.xio			;;; i221  
mov	eax,2000			;;; i659 
mov	ebx,d[ebp-52]			;;; i665  
add	eax,ebx			;;; i775  
mov	ebx,1			;;; i659  
neg	ebx			;;; i916  
imul	eax,ebx			;;; i805 
jmp	end.func1E.xio			;;; i258 
else.0034.xio:  
end.if.0034.xio:  
mov	eax,1			;;; i659  
neg	eax			;;; i916  
mov	ebx,d[ebp-52]			;;; i665  
imul	eax,ebx			;;; i805 
jmp	end.func1E.xio			;;; i258 
else.0032.xio:  
end.if.0032.xio:  
mov	eax,d[ebp-60]			;;; i665  
and	eax,3			;;; i769  
mov	ebx,d[ebp-56]			;;; i665  
neg	eax			;;; i745  
rcr	eax,1			;;; i746  
sar	eax,31			;;; i747 
mov	edx,ebx			;;; i748  
neg	edx			;;; i749  
rcr	edx,1			;;; i750  
sar	edx,31			;;; i751 
and	eax,edx			;;; i752  
test	eax,eax			;;; i220 
jz	>> else.0035.xio			;;; i221  
mov	eax,d[ebp-48]			;;; i665  
add	eax,1000			;;; i775 
jmp	end.func1E.xio			;;; i258 
else.0035.xio:  
end.if.0035.xio:  
mov	eax,d[ebp-52]			;;; i665  
cmp	eax,15			;;; i684a  
mov	eax,0			;;; i466  
jne	> A.97			;;; i467 
not	eax			;;; i468  
A.97: 
mov	ebx,d[ebp-60]			;;; i665  
and	ebx,16			;;; i769 
neg	eax			;;; i745  
rcr	eax,1			;;; i746  
sar	eax,31			;;; i747 
mov	edx,ebx			;;; i748  
neg	edx			;;; i749  
rcr	edx,1			;;; i750  
sar	edx,31			;;; i751 
and	eax,edx			;;; i752  
test	eax,eax			;;; i220 
jz	>> else.0036.xio			;;; i221  
mov	eax,15			;;; i659 
jmp	end.func1E.xio			;;; i258 
else.0036.xio:  
end.if.0036.xio:  
mov	eax,d[ebp-48]			;;; i665  
cmp	eax,27			;;; i684a  
jne	>> else.0037.xio			;;; i219 
mov	eax,27			;;; i659 
jmp	end.func1E.xio			;;; i258 
else.0037.xio:  
end.if.0037.xio:  
mov	eax,d[ebp-60]			;;; i665  
and	eax,128			;;; i769  
mov	ebx,d[ebp-56]			;;; i665  
neg	eax			;;; i745  
rcr	eax,1			;;; i746  
sar	eax,31			;;; i747 
mov	edx,ebx			;;; i748  
neg	edx			;;; i749  
rcr	edx,1			;;; i750  
sar	edx,31			;;; i751 
and	eax,edx			;;; i752  
test	eax,eax			;;; i220 
jz	>> else.0038.xio			;;; i221  
mov	eax,0			;;; i659  
mov	d[ebp-64],eax			;;; i670  
mov	eax,d[%1E%upper.xio]			;;; i663a  
mov	d[ebp-68],eax			;;; i670  
for.0039.xio: 
mov	eax,d[ebp-64]			;;; i665  
mov	ebx,d[ebp-68]			;;; i665  
cmp	eax,ebx			;;; i153  
jg	>> end.for.0039.xio			;;; i154 
mov	eax,d[ebp-64]			;;; i665  
mov	edx,d[%1E%u$.xio]			;;; i663a 
movzx	eax,b[edx+eax]			;;; i464 
mov	ebx,d[ebp-56]			;;; i665  
cmp	eax,ebx			;;; i684a 
jne	>> else.003A.xio			;;; i219 
mov	eax,d[ebp-64]			;;; i665  
mov	edx,d[%1E%l$.xio]			;;; i663a 
movzx	eax,b[edx+eax]			;;; i464 
mov	d[ebp-56],eax			;;; i670  
mov	eax,d[ebp-56]			;;; i665  
jmp	end.func1E.xio			;;; i258 
else.003A.xio:  
end.if.003A.xio:  
do.next.0039.xio: 
inc	d[ebp-64]			;;; i229  
jmp	for.0039.xio			;;; i231 
end.for.0039.xio: 
else.0038.xio:  
end.if.0038.xio:  
mov	eax,d[ebp-56]			;;; i665  
test	eax,eax			;;; i220 
jz	>> else.003B.xio			;;; i221  
mov	eax,d[ebp-56]			;;; i665  
jmp	end.func1E.xio			;;; i258 
else.003B.xio:  
end.if.003B.xio:  
else.0031.xio:  
end.if.0031.xio:  
else.0030.xio:  
end.if.0030.xio:  
push	[ebp-32]			;;; i674a 
push	[%1E%hStdIn.xio]			;;; i672a 
call	_SetConsoleMode@8			;;; i619 
xor	eax,eax			;;; i862  
jmp	end.func1E.xio			;;; i258 
jmp	out.sub1E.0.xio			;;; i262  
%s%Initialize%1E: 
mov	eax,-1			;;; i659 
mov	d[%1E%entry.xio],eax			;;; i668 
push	-10			;;; i656a  
call	_GetStdHandle@4			;;; i619 
mov	d[%1E%hStdIn.xio],eax			;;; i668  
mov	eax,addr @_string.015E.xio			;;; i663 
call	%_clone.a0			;;; i3  
mov	ebx,addr %1E%u$.xio			;;; i4  
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,addr @_string.015F.xio			;;; i663 
call	%_clone.a0			;;; i3  
mov	ebx,addr %1E%l$.xio			;;; i4  
mov	esi,d[ebx]			;;; i6a  
mov	d[ebx],eax			;;; i6b  
call	%____free			;;; i6c  
mov	eax,d[%1E%u$.xio]			;;; i663a 
test	eax,eax			;;; i593 
jz	> A.99			;;; i594  
mov	eax,d[eax-8]			;;; i595 
A.99: 
sub	eax,1			;;; i791  
mov	d[%1E%upper.xio],eax			;;; i668 
end.sub1E.0.xio:  
ret				;;; i127 
