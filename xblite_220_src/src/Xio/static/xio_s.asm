.code 
jmp	%_StartLibrary_xio			;;; i36a 
PrologCode.xio: 
push	ebp			;;; i38  
mov	ebp,esp			;;; i39 
sub	esp,256			;;; i40 
mov	eax,addr @_string.002D.xio			;;; i663 
push	eax  
call	_XxxXstLoadLibrary@4 
mov	eax,addr @_string.002E.xio			;;; i663 
push	eax  
call	_XxxXstLoadLibrary@4 
.code 
leave	;;; i160a 
ret				;;; i161 ;;; end prolog code 
%_StartLibrary_xio: 
call	func1.xio			;;; i162c  
ret	0			;;; i162d 
_Xio@0: 
func1.xio:  
push	ebp			;;; i112 
mov	ebp,esp		;;; i113 
sub	esp,8			;;; i114  
push	esi			;;; save esi 
push	edi			;;; save edi 
push	ebx			;;; save ebx 
call	%%%%initOnce.xio 
funcBody1.xio:  
xor	eax,eax			;;; i862  
end.Xio.xio:  ;;; Function end label for Assembly Programmers.  
end.func1.xio:  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
%%%%initOnce.xio: 
cmp d[%%%entered.xio],-1		;;; i117  
jne > A.3	;;; i117a 
ret			;;; i117b 
A.3:  
call	PrologCode.xio			;;; i118a 
lea esi,%_begin_external_data_xio 
lea edi,%_end_external_data_xio 
call %_ZeroMemory 
call	InitSharedComposites.xio			;;; i119  
mov	d[%%%entered.xio],-1  
ret				;;; i120 
data section 'xio$internals'  
align	8 
%%%entered.xio: 
db 8 dup 0  
.code 
out.sub2.0.xio: 
xor	eax,eax			;;; i862  
end.XioClearEndOfLine.xio:  ;;; Function end label for Assembly Programmers.  
end.func2.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
out.sub3.0.xio: 
xor	eax,eax			;;; i862  
end.XioDeleteLine.xio:  ;;; Function end label for Assembly Programmers.  
end.func3.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
out.sub4.0.xio: 
xor	eax,eax			;;; i862  
end.XioGetConsoleInfo.xio:  ;;; Function end label for Assembly Programmers.  
end.func4.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	24			;;; i111a  
out.sub5.0.xio: 
xor	eax,eax			;;; i862  
end.XioGetConsoleTextRect.xio:  ;;; Function end label for Assembly Programmers.  
end.func5.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	24			;;; i111a  
out.sub9.0.xio: 
xor	eax,eax			;;; i862  
end.XioInsertLine.xio:  ;;; Function end label for Assembly Programmers.  
end.func9.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
out.subA.0.xio: 
xor	eax,eax			;;; i862  
end.XioPutConsoleText.xio:  ;;; Function end label for Assembly Programmers.  
end.funcA.xio:  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	16			;;; i111a  
out.subB.0.xio: 
xor	eax,eax			;;; i862  
end.XioPutConsoleTextArray.xio:  ;;; Function end label for Assembly Programmers. 
end.funcB.xio:  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	16			;;; i111a  
out.subC.0.xio: 
xor	eax,eax			;;; i862  
end.XioScrollBufferUp.xio:  ;;; Function end label for Assembly Programmers.  
end.funcC.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.subD.0.xio: 
xor	eax,eax			;;; i862  
end.XioSetConsoleBufferSize.xio:  ;;; Function end label for Assembly Programmers.  
end.funcD.xio:  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	12			;;; i111a  
out.subE.0.xio: 
xor	eax,eax			;;; i862  
end.XioSetConsoleCursorPos.xio:  ;;; Function end label for Assembly Programmers. 
end.funcE.xio:  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	12			;;; i111a  
out.subF.0.xio: 
xor	eax,eax			;;; i862  
end.XioSetConsoleTextRect.xio:  ;;; Function end label for Assembly Programmers.  
end.funcF.xio:  
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	24			;;; i111a  
out.sub10.0.xio:  
xor	eax,eax			;;; i862  
end.XioSetCursorType.xio:  ;;; Function end label for Assembly Programmers. 
end.func10.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub11.0.xio:  
xor	eax,eax			;;; i862  
end.XioCloseStdHandle.xio:  ;;; Function end label for Assembly Programmers.  
end.func11.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
out.sub12.0.xio:  
xor	eax,eax			;;; i862  
end.XioClearConsole.xio:  ;;; Function end label for Assembly Programmers.  
end.func12.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
out.sub15.0.xio:  
xor	eax,eax			;;; i862  
end.XioCreateConsole.xio:  ;;; Function end label for Assembly Programmers. 
end.func15.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub17.0.xio:  
xor	eax,eax			;;; i862  
end.XioWriteConsole.xio:  ;;; Function end label for Assembly Programmers.  
end.func17.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub18.0.xio:  
xor	eax,eax			;;; i862  
end.XioReadConsole.xio:  ;;; Function end label for Assembly Programmers. 
end.func18.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,[ebp-24]			;;; i665 
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub1A.0.xio:  
xor	eax,eax			;;; i862  
end.XioSetTextAttributes.xio:  ;;; Function end label for Assembly Programmers. 
end.func1A.xio: 
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub1B.0.xio:  
xor	eax,eax			;;; i862  
end.XioSetTextBackColor.xio:  ;;; Function end label for Assembly Programmers.  
end.func1B.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub1C.0.xio:  
xor	eax,eax			;;; i862  
end.XioSetTextColor.xio:  ;;; Function end label for Assembly Programmers.  
end.func1C.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	8			;;; i111a 
out.sub1E.0.xio:  
xor	eax,eax			;;; i862  
end.XioInkey.xio:  ;;; Function end label for Assembly Programmers. 
end.func1E.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret						;;; i111d  
out.sub20.0.xio:  
xor	eax,eax			;;; i862  
end.GetConsoleHandle.xio:  ;;; Function end label for Assembly Programmers. 
end.func20.xio: 
xor	ebx,ebx			;;; i422  
mov	esi,d[ebp-24]			;;; i665  
call	%____free			;;; i423 
mov	d[ebp-24],ebx			;;; i670  
lea	esp,[ebp-20]				;;; i110  
pop	ebx				;;; restore ebx  
pop	edi				;;; restore edi  
pop	esi				;;; restore esi  
leave					;;; replaces "mov esp,ebp", "pop ebp" 
ret	4			;;; i111a 
end_program.xio:  
push	ebp			;;; i128 
mov	ebp,esp			;;; i129  
sub	esp,128			;;; i130  
xor	ebx,ebx			;;; i422  
mov	esi,[%1E%u$.xio]			;;; i663a  
call	%____free			;;; i423 
mov	d[%1E%u$.xio],ebx			;;; i668  
mov	esi,[%1E%l$.xio]			;;; i663a  
call	%____free			;;; i423 
mov	d[%1E%l$.xio],ebx			;;; i668  
mov	esp,ebp			;;; i132  
pop	ebp			;;; i133  
ret				;;; i134 
InitSharedComposites.xio: 
ret				;;; i143 
align 8 
data section 'xio$aaaaa'  
%_begin_external_data_xio dd ?  
align 8 
data section 'xio$zzzzz'  
%_end_external_data_xio dd ?  
.const  
align 8 
dd	24,0, 3,0x80130001 
@_string.0029.xio:  
db	"xio"  
db	5 dup 0  
dd	24,0, 6,0x80130001 
@_string.002A.xio:  
db	"0.0003" 
db	2 dup 0  
dd	24,0, 3,0x80130001 
@_string.002B.xio:  
db	"xst"  
db	5 dup 0  
dd	32,0, 9,0x80130001 
@_string.002C.xio:  
db	"gdi32.dec"  
db	7 dup 0  
dd	24,0, 6,0x80130001 
@_string.002D.xio:  
db	"user32" 
db	2 dup 0  
dd	32,0, 8,0x80130001 
@_string.002E.xio:  
db	"kernel32" 
db	8 dup 0  
dd	24,0, 6,0x80130001 
@_string.009E.xio:  
db	"CONIN$" 
db	2 dup 0  
dd	24,0, 7,0x80130001 
@_string.009F.xio:  
db	"CONOUT$"  
db	1 dup 0  
dd	24,0, 1,0x80130001 
@_string.0111.xio:  
db	0x5C 
db	7 dup 0  
dd	64,0, 43,0x80130001  
@_string.015E.xio:  
db	"~!@#$%^&*()_+|{}:",0x22,"<>?`1234567890-=",0x5C,"[];',./",0x00  
db	5 dup 0  
dd	64,0, 43,0x80130001  
@_string.015F.xio:  
db	"`1234567890-=",0x5C,"[];',./~!@#$%^&*()_+|{}:",0x22,"<>?",0x00  
db	5 dup 0  
dd	24,0, 1,0x80130001 
@_string.0183.xio:  
db	";"  
db	7 dup 0  
dd	24,0, 4,0x80130001 
@_string.0B43.xio:  
db	"edit" 
db	4 dup 0  
dd	24,0, 6,0x80130001 
@_string.0BA0.xio:  
db	"button" 
db	2 dup 0  
dd	24,0, 6,0x80130001 
@_string.0BE4.xio:  
db	"static" 
db	2 dup 0  
dd	24,0, 7,0x80130001 
@_string.0C48.xio:  
db	"listbox"  
db	1 dup 0  
dd	32,0, 8,0x80130001 
@_string.0CB3.xio:  
db	"combobox" 
db	8 dup 0  
dd	32,0, 9,0x80130001 
@_string.0D06.xio:  
db	"scrollbar"  
db	7 dup 0  
dd	32,0, 9,0x80130001 
@_string.0DCB.xio:  
db	"mdiclient"  
db	7 dup 0  
dd	32,0, 15,0x80130001  
@_string.StartLibrary.xio:  
db	"%_StartLibrary_"  
db	1 dup 0  
