.text
; **********************************************************
; This one really needs to be broken into smaller objects!
; **********************************************************
;
; *********************************
; *****  %_cv.slong.to.sbyte  *****
; *****  %_cv.ulong.to.sbyte  *****
; *****  %_cv.xlong.to.sbyte  *****
; *********************************
;
; in:	arg0 = xlong
; out:	eax = equivalent sbyte
;
; destroys: nothing
;
.globl %_cv.slong.to.sbyte
%_cv.slong.to.sbyte:
.globl %_cv.ulong.to.sbyte
%_cv.ulong.to.sbyte:
.globl %_cv.xlong.to.sbyte
%_cv.xlong.to.sbyte:
movsx	eax,byte ptr [esp+4] 	;eax = converted sbyte
cmp	eax,[esp+4]							;any of those high-order bits changed?
je	short ret1								;no: sign-extension occurred w/o change of d
call	%_eeeOverflow						; Return from there
ret1:
ret
;
; *********************************
; *****  %_cv.slong.to.ubyte  *****
; *****  %_cv.ulong.to.ubyte  *****
; *****  %_cv.xlong.to.ubyte  *****
; *********************************
;
; in:	arg0 = xlong
; out:	eax = equivalent ubyte
;
; destroys: nothing
;
.globl %_cv.slong.to.ubyte
%_cv.slong.to.ubyte:
.globl %_cv.ulong.to.ubyte
%_cv.ulong.to.ubyte:
.globl %_cv.xlong.to.ubyte
%_cv.xlong.to.ubyte:
movzx	eax,byte ptr [esp+4] ;eax = converted ubyte
cmp	eax,[esp+4]	;any high-order bits changed?
je	short ret2	;no: conversion occurred w/o loss of data
call	%_eeeOverflow	; Return from there
ret2:
ret
;
; **********************************
; *****  %_cv.slong.to.sshort  *****
; *****  %_cv.ulong.to.sshort  *****
; *****  %_cv.xlong.to.sshort  *****
; **********************************
;
; in:	arg0 = xlong
; out:	eax = equivalent sshort
;
; destroys: nothing
;
.globl %_cv.slong.to.sshort
%_cv.slong.to.sshort:
.globl %_cv.ulong.to.sshort
%_cv.ulong.to.sshort:
.globl %_cv.xlong.to.sshort
%_cv.xlong.to.sshort:
movsx	eax,word ptr [esp+4] ;eax = converted sshort
cmp	eax,[esp+4]	;any high-order bits changed?
je	short ret3	;no: conversion occurred w/o loss of data
call	%_eeeOverflow	; Return from there
ret3:
ret
;
; **********************************
; *****  %_cv.slong.to.ushort  *****
; *****  %_cv.ulong.to.ushort  *****
; *****  %_cv.xlong.to.ushort  *****
; **********************************
;
; in:	arg0 = xlong
; out:	eax = equivalent ushort
;
; destroys: nothing
;
.globl %_cv.slong.to.ushort
%_cv.slong.to.ushort:
.globl %_cv.ulong.to.ushort
%_cv.ulong.to.ushort:
.globl %_cv.xlong.to.ushort
%_cv.xlong.to.ushort:
movzx	eax,word ptr [esp+4] 	;eax = converted ushort
cmp	eax,[esp+4]							;any high-order bits changed?
je	short ret4								;no: conversion occurred w/o loss of data
call	%_eeeOverflow						; Return from there
ret4:
ret
;
;
; *********************************
; *****  %_cv.slong.to.slong  *****
; *****  %_cv.slong.to.ulong  *****
; *****  %_cv.slong.to.xlong  *****
; *****  %_cv.slong.to.subaddr  ***
; *****  %_cv.slong.to.goaddr  ****
; *****  %_cv.slong.to.funcaddr  **
; *****  %_cv.ulong.to.slong  *****
; *****  %_cv.ulong.to.ulong  *****
; *****  %_cv.ulong.to.xlong  *****
; *****  %_cv.ulong.to.subaddr  ***
; *****  %_cv.ulong.to.goaddr  ****
; *****  %_cv.ulong.to.funcaddr  **
; *****  %_cv.xlong.to.slong  *****
; *****  %_cv.xlong.to.ulong  *****
; *****  %_cv.xlong.to.xlong  *****
; *****  %_cv.xlong.to.subaddr  ***
; *****  %_cv.xlong.to.goaddr  ****
; *****  %_cv.xlong.to.funcaddr  **
; *********************************
;
; in:	arg0 = xlong
; out:	eax = converted value, which is always the same as arg0
;
; destroys: nothing
;
.globl %_cv.slong.to.slong
%_cv.slong.to.slong:
.globl %_cv.slong.to.ulong
%_cv.slong.to.ulong:
.globl %_cv.slong.to.xlong
%_cv.slong.to.xlong:
.globl %_cv.slong.to.subaddr
%_cv.slong.to.subaddr:
.globl %_cv.slong.to.goaddr
%_cv.slong.to.goaddr:
.globl %_cv.slong.to.funcaddr
%_cv.slong.to.funcaddr:
.globl %_cv.ulong.to.slong
%_cv.ulong.to.slong:
.globl %_cv.ulong.to.ulong
%_cv.ulong.to.ulong:
.globl %_cv.ulong.to.xlong
%_cv.ulong.to.xlong:
.globl %_cv.ulong.to.subaddr
%_cv.ulong.to.subaddr:
.globl %_cv.ulong.to.goaddr
%_cv.ulong.to.goaddr:
.globl %_cv.ulong.to.funcaddr
%_cv.ulong.to.funcaddr:
.globl %_cv.xlong.to.slong
%_cv.xlong.to.slong:
.globl %_cv.xlong.to.ulong
%_cv.xlong.to.ulong:
.globl %_cv.xlong.to.xlong
%_cv.xlong.to.xlong:
.globl %_cv.xlong.to.subaddr
%_cv.xlong.to.subaddr:
.globl %_cv.xlong.to.goaddr
%_cv.xlong.to.goaddr:
.globl %_cv.xlong.to.funcaddr
%_cv.xlong.to.funcaddr:
mov	eax,[esp+4]
ret
;
; *********************************
; *****  %_cv.slong.to.giant  *****
; *****  %_cv.xlong.to.giant  *****
; *********************************
;
; in:	arg0 = xlong
; out:	edx:eax = equivalent giant
;
; destroys: nothing
;
.globl %_cv.slong.to.giant
%_cv.slong.to.giant:
.globl %_cv.xlong.to.giant
%_cv.xlong.to.giant:
mov	eax,[esp+4]
cdq
ret
;
; *********************************
; *****  %_cv.ulong.to.giant  *****
; *********************************
;
; in:	arg0 = ulong
; out:	edx:eax = equivalent giant
;
; destroys: nothing
;
.globl %_cv.ulong.to.giant
%_cv.ulong.to.giant:
mov	eax,[esp+4]
xor	edx,edx
ret
;
; **********************************
; *****  %_cv.slong.to.single  *****
; *****  %_cv.slong.to.double  *****
; *****  %_cv.slong.to.longdouble  *****
; *****  %_cv.xlong.to.single  *****
; *****  %_cv.xlong.to.double  *****
; *****  %_cv.xlong.to.longdouble  *****
; **********************************
;
; in:	arg0 = xlong
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
.globl %_cv.slong.to.single
%_cv.slong.to.single:
.globl %_cv.slong.to.double
%_cv.slong.to.double:
.globl %_cv.slong.to.longdouble
%_cv.slong.to.longdouble:
.globl %_cv.xlong.to.single
%_cv.xlong.to.single:
.globl %_cv.xlong.to.double
%_cv.xlong.to.double:
.globl %_cv.xlong.to.longdouble
%_cv.xlong.to.longdouble:
fild	[esp+4]
ret
;
; **********************************
; *****  %_cv.ulong.to.single  *****  xxxxxxxxxx
; *****  %_cv.ulong.to.double  *****
; *****  %_cv.ulong.to.longdouble  *****
; **********************************
;
; in:	arg0 = ulong
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
.globl %_cv.ulong.to.single
%_cv.ulong.to.single:
.globl %_cv.ulong.to.double
%_cv.ulong.to.double:
.globl %_cv.ulong.to.longdouble
%_cv.ulong.to.longdouble:
push	0
push	[esp+8]
fild	qword ptr [esp]
add	esp,8
ret
;
; *********************************
; *****  %_cv.giant.to.sbyte  *****
; *********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	eax = equivalent sbyte
;
; destroys: edx
;
.globl %_cv.giant.to.sbyte
%_cv.giant.to.sbyte:
movsx	eax,byte ptr [esp+4] 	;eax = converted lower eight bits
cmp	eax,[esp+4]							;no change in remaining bits of lsdword?
jne	short bad1							;there was a change: blow up
cdq													;sign-extend result into edx
cmp	edx,[esp+8]							;no change in bits of msdword
jne	short bad1							;there was a change: blow up
ret
;
bad1:
;	xor	eax,eax								;return a zero (is this a good idea?)
call	%_eeeOverflow						; Return from there
;
;
; *********************************
; *****  %_cv.giant.to.ubyte  *****
; *********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	eax = equivalent ubyte
;
; destroys: nothing
;
.globl %_cv.giant.to.ubyte
%_cv.giant.to.ubyte:
cmp	[esp+8],0	;high 32 better be all zero
jne	bad1		;nope: blow up
movzx	eax,byte ptr [esp+4] ;extract lowest eight bits from low 32
cmp	eax,[esp+4]	;remaining bits changed?
jne	bad1		;yes: data was lost in conversion
ret
;
; **********************************
; *****  %_cv.giant.to.sshort  *****
; **********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	eax = equivalent sshort
;
; destroys: edx
;
.globl %_cv.giant.to.sshort
%_cv.giant.to.sshort:
movsx	eax,word ptr [esp+4] ;sign-extend lowest 16 bits of low 32
cmp	eax,[esp+4]	;any of the remaining bits changed?
jne	bad1		;yes: data was lost in conversion
cdq			;sign-extend result into edx
cmp	edx,[esp+8]	;any bits changed in high 32?
jne	bad1		;yes: data was lost in conversion
ret
;
; **********************************
; *****  %_cv.giant.to.ushort  *****
; **********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	eax = equivalent ushort
;
; destroys: nothing
;
.globl %_cv.giant.to.ushort
%_cv.giant.to.ushort:
cmp	[esp+8],0	;high 32 bits had better be zero
jne	bad1		;nope: impossible to convert
movzx	eax,word ptr [esp+4] ;extract lowest 8 bits of low 32
cmp	eax,[esp+4]	;any of the remaining bits changed?
jne	bad1		;yes: data was lost in conversion
ret
;
; *********************************
; *****  %_cv.giant.to.slong  *****
; *****  %_cv.giant.to.xlong  *****
; *********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	eax = equivalent slong or xlong
;
; destroys: edx
;
.globl %_cv.giant.to.slong
%_cv.giant.to.slong:
.globl %_cv.giant.to.xlong
%_cv.giant.to.xlong:
mov	eax,[esp+4]	;get low 32 bits
cdq			;sign-extend result into edx
cmp	edx,[esp+8]	;high 32 bits the same?
jne	bad1		;no: data was lost in conversion
ret
;
; *********************************
; *****  %_cv.giant.to.ulong  *****
; *********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	eax = equivalent ulong
;
; destroys: nothing
;
.globl %_cv.giant.to.ulong
%_cv.giant.to.ulong:
cmp	[esp+8],0	;high 32 bits better all be zero
jne	bad1		;nope: impossible to convert
mov	eax,[esp+4]	;result is low 32 bits of giant
ret
;
; *********************************
; *****  %_cv.giant.to.giant  *****
; *********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	edx:eax = arg1:arg0
;
; destroys: nothing
;
.globl %_cv.giant.to.giant
%_cv.giant.to.giant:
mov	eax,[esp+4]	;eax = low 32 bits of giant
mov	edx,[esp+8]	;edx = high 32 bits of giant
ret
;
;
; **********************************
; *****  %_cv.giant.to.single  *****
; *****  %_cv.giant.to.double  *****
; *****  %_cv.giant.to.longdouble  *****
; **********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
.globl %_cv.giant.to.single
%_cv.giant.to.single:
.globl %_cv.giant.to.double
%_cv.giant.to.double:
.globl %_cv.giant.to.longdouble
%_cv.giant.to.longdouble:
fild	qword ptr [esp+4]
ret
;
;
; **********************************
; *****  %_cv.single.to.sbyte  *****
; **********************************
;
; in:	arg0 = single
; out:	eax = equivalent sbyte
;
; destroys: esi
;
.globl %_cv.single.to.sbyte
%_cv.single.to.sbyte:
fld	[esp+4]		;st(0) = input single
mov	esi,workdword	;shorten next three instructions
fistp	[esi]		;convert input single to an integer
fwait
movsx	eax,byte ptr [esi] ;sign-extend low eight bits
cmp	eax,[esi]	;any of the other bits changed?
jne	short bad2	;yes: data was lost in conversion
ret
bad2:
;	xor	eax,eax		;return a zero (is this a good idea?)
call	%_eeeOverflow	; Return from there
;
;
; **********************************
; *****  %_cv.single.to.ubyte  *****
; **********************************
;
; in:	arg0 = single
; out:	eax = equivalent ubyte
;
; destroys: esi
;
.globl %_cv.single.to.ubyte
%_cv.single.to.ubyte:
fld	[esp+4]		;st(0) = input single
mov	esi,workdword
fistp	[esi]		;convert input single to integer
fwait
movzx	eax,byte ptr [esi] ;extract lowest 8 bits
cmp	eax,[esi]	;no change in other bits?
jne	bad2		;other bits changed: error
ret
;
;
; ***********************************
; *****  %_cv.single.to.sshort  *****
; ***********************************
;
; in:	arg0 = single
; out:	eax = equivalent sshort
;
; destroys: esi
;
.globl %_cv.single.to.sshort
%_cv.single.to.sshort:
fld	[esp+4]		;st(0) = input single
mov	esi,workdword	;shorten next three instructions
fistp	[esi]		;convert input single to an integer
fwait
movsx	eax,word ptr [esi] ;sign-extend low 16 bits
cmp	eax,[esi]	;any of the other bits changed?
jne	short bad2	;yes: data was lost in conversion
ret
;
;
; ***********************************
; *****  %_cv.single.to.ushort  *****
; ***********************************
;
; in:	arg0 = single
; out:	eax = equivalent ushort
;
; destroys: esi
;
.globl %_cv.single.to.ushort
%_cv.single.to.ushort:
fld	[esp+4]		;st(0) = input single
mov	esi,workdword
fistp	[esi]		;convert input single to integer
fwait
movzx	eax,word ptr [esi] ;extract lowest 16 bits
cmp	eax,[esi]	;no change in other bits?
jne	bad2		;other bits changed: error
ret
;
;
; **********************************
; *****  %_cv.single.to.slong  *****
; *****  %_cv.single.to.xlong  *****
; **********************************
;
; in:	arg0 = single
; out:	eax = equivalent slong or xlong
;
; destroys: nothing
;
.globl %_cv.single.to.slong
%_cv.single.to.slong:
.globl %_cv.single.to.xlong
%_cv.single.to.xlong:
fld	[esp+4]		;st(0) = input single
fistp	[workdword]	;convert it to integer
fwait
mov	eax,[workdword]
ret			;no overflow possible (?)
;
;
; **********************************
; *****  %_cv.single.to.ulong  *****
; **********************************
;
; in:	arg0 = single
; out:	eax = equivalent ulong
;
; destroys: esi
;
.globl %_cv.single.to.ulong
%_cv.single.to.ulong:
fld	[esp+4]		;st(0) = input single
mov	esi,workdword
fistp	[esi]		;convert it to integer
fwait
mov	eax,[esi]
or	eax,eax		;it's not negative, is it?
js	bad2		;'fraid so
ret
;
;
; **********************************
; *****  %_cv.single.to.giant  *****
; **********************************
;
; in:	arg0 = single
; out:	edx:eax = equivalent giant
;
; destroys: nothing
;
.globl %_cv.single.to.giant
%_cv.single.to.giant:
fld	[esp+4]		;st(0) = input single
fistp	qword ptr [workqword] ;convert it to integer
fwait
mov	eax,[workqword]	;eax = low 32 bits of result
mov	edx,[workqword+4] ;edx = high 32 bits of result
ret
;
; ***************************************
; *****  %_cv.single.to.single      *****
; *****  %_cv.single.to.double      *****
; *****  %_cv.single.to.longdouble  *****
; ***************************************
;
; in:	arg0 = single
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
.globl %_cv.single.to.single
%_cv.single.to.single:
.globl %_cv.single.to.double
%_cv.single.to.double:
.globl %_cv.single.to.longdouble
%_cv.single.to.longdouble:
fld	[esp+4]		;st(0) = input single
ret
;
;
; **********************************
; *****  %_cv.double.to.sbyte  *****
; **********************************
;
; in:	arg1:arg0 = double
; out:	eax = equivalent sbyte
;
; destroys: esi
;
.globl %_cv.double.to.sbyte
%_cv.double.to.sbyte:
fld	qword ptr [esp+4] 		;st(0) = input double
mov	esi,workdword					;shorten next three instructions
fistp	[esi]								;convert input double to an integer
fwait
movsx	eax,byte ptr [esi] 	;sign-extend low eight bits
cmp	eax,[esi]							;any of the other bits changed?
jne	bad3									;yes: data was lost in conversion
ret
bad3:
;	xor	eax,eax							;return zero (is this a good idea?)
call	%_eeeOverflow					;Return from there
;
;
; **********************************
; *****  %_cv.double.to.ubyte  *****
; **********************************
;
; in:	arg1:arg0 = double
; out:	eax = equivalent ubyte
;
; destroys: esi
;
.globl %_cv.double.to.ubyte
%_cv.double.to.ubyte:
fld	qword ptr [esp+4] 		;st(0) = input double
mov	esi,workdword
fistp	[esi]								;convert input double to integer
fwait
movzx	eax,byte ptr [esi] 	;extract lowest 8 bits
cmp	eax,[esi]							;no change in other bits?
jne	bad3									;other bits changed: error
ret
;
;
; ***********************************
; *****  %_cv.double.to.sshort  *****
; ***********************************
;
; in:	arg1:arg0 = double
; out:	eax = equivalent sshort
;
; destroys: esi
;
.globl %_cv.double.to.sshort
%_cv.double.to.sshort:
fld	qword ptr [esp+4] 		;st(0) = input double
mov	esi,workdword					;shorten next three instructions
fistp	[esi]								;convert input double to an integer
fwait
movsx	eax,word ptr [esi] 	;sign-extend low 16 bits
cmp	eax,[esi]							;any of the other bits changed?
jne	bad3									;yes: data was lost in conversion
ret
;
;
; ***********************************
; *****  %_cv.double.to.ushort  *****
; ***********************************
;
; in:	arg1:arg0 = double
; out:	eax = equivalent ushort
;
; destroys: esi
;
.globl %_cv.double.to.ushort
%_cv.double.to.ushort:
fld	qword ptr [esp+4] 		;st(0) = input double
mov	esi,workdword
fistp	[esi]								;convert input double to integer
fwait
movzx	eax,word ptr [esi] 	;extract lowest 16 bits
cmp	eax,[esi]							;no change in other bits?
jne	bad3									;other bits changed: error
ret
;
;
; **********************************
; *****  %_cv.double.to.slong  *****
; *****  %_cv.double.to.xlong  *****
; **********************************
;
; in:	arg1:arg0 = double
; out:	eax = equivalent slong or xlong
;
; destroys: nothing
;
.globl %_cv.double.to.slong
%_cv.double.to.slong:
.globl %_cv.double.to.xlong
%_cv.double.to.xlong:
fld	qword ptr [esp+4] 	;st(0) = input double
fistp	[workdword]				;convert it to integer
fwait
mov	eax,[workdword]
ret											;no overflow possible (?)
;
;
; **********************************
; *****  %_cv.double.to.ulong  *****
; **********************************
;
; in:	arg1:arg0 = double
; out:	eax = equivalent ulong
;
; destroys: esi
;
.globl %_cv.double.to.ulong
%_cv.double.to.ulong:
fld	qword ptr [esp+4] 	;st(0) = input double
mov	esi,workdword
fistp	[esi]							;convert it to integer
fwait
mov	eax,[esi]
or	eax,eax								;it's not negative, is it?
js	bad3									;'fraid so
ret
;
;
; **********************************
; *****  %_cv.double.to.giant  *****
; **********************************
;
; in:	arg1:arg0 = double
; out:	edx:eax = equivalent giant
;
; destroys: nothing
;
.globl %_cv.double.to.giant
%_cv.double.to.giant:
fld	qword ptr [esp+4] 			;st(0) = input double
fistp	qword ptr [workqword] ;convert it to integer
fwait
mov	eax,[workqword]					;eax = low 32 bits of result
mov	edx,[workqword+4] 			;edx = high 32 bits of result
ret
;
;
; ***************************************
; *****  %_cv.double.to.single      *****
; *****  %_cv.double.to.double      *****
; *****  %_cv.double.to.longdouble  *****
; ***************************************
;
; in:	arg1:arg0 = double
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
.globl %_cv.double.to.single
%_cv.double.to.single:
.globl %_cv.double.to.double
%_cv.double.to.double:
.globl %_cv.double.to.longdouble
%_cv.double.to.longdouble:
fld	qword ptr [esp+4] 				;st(0) = input double
ret
;
;
; **************************************
; *****  %_cv.longdouble.to.sbyte  *****
; **************************************
;
; in:	arg1:arg0 = longdouble
; out:	eax = equivalent sbyte
;
; destroys: esi
;
.globl %_cv.longdouble.to.sbyte
%_cv.longdouble.to.sbyte:
fld	tword ptr [esp+4] 		;st(0) = input longdouble
mov	esi,workdword					;shorten next three instructions
fistp	[esi]								;convert input longdouble to an integer
fwait
movsx	eax,byte ptr [esi] 	;sign-extend low eight bits
cmp	eax,[esi]							;any of the other bits changed?
jne	bad3									;yes: data was lost in conversion
ret
;
;
; **************************************
; *****  %_cv.longdouble.to.ubyte  *****
; **************************************
;
; in:	arg1:arg0 = longdouble
; out:	eax = equivalent ubyte
;
; destroys: esi
;
.globl %_cv.longdouble.to.ubyte
%_cv.longdouble.to.ubyte:
fld	tword ptr [esp+4] 			;st(0) = input longdouble
mov	esi,workdword
fistp	[esi]									;convert input longdouble to integer
fwait
movzx	eax,byte ptr [esi] 		;extract lowest 8 bits
cmp	eax,[esi]								;no change in other bits?
jne	bad3										;other bits changed: error
ret
;
;
; ***************************************
; *****  %_cv.longdouble.to.sshort  *****
; ***************************************
;
; in:	arg1:arg0 = longdouble
; out:	eax = equivalent sshort
;
; destroys: esi
;
.globl %_cv.longdouble.to.sshort
%_cv.longdouble.to.sshort:
fld	tword ptr [esp+4] 		;st(0) = input longdouble
mov	esi,workdword					;shorten next three instructions
fistp	[esi]								;convert input longdouble to an integer
fwait
movsx	eax,word ptr [esi] 	;sign-extend low 16 bits
cmp	eax,[esi]							;any of the other bits changed?
jne	bad3									;yes: data was lost in conversion
ret
;
;
; ***************************************
; *****  %_cv.longdouble.to.ushort  *****
; ***************************************
;
; in:	arg1:arg0 = longdouble
; out:	eax = equivalent ushort
;
; destroys: esi
;
.globl %_cv.longdouble.to.ushort
%_cv.longdouble.to.ushort:
fld	tword ptr [esp+4] 		;st(0) = input longdouble
mov	esi,workdword
fistp	[esi]								;convert input longdouble to integer
fwait
movzx	eax,word ptr [esi] 	;extract lowest 16 bits
cmp	eax,[esi]							;no change in other bits?
jne	bad3									;other bits changed: error
ret
;
;
; **************************************
; *****  %_cv.longdouble.to.slong  *****
; *****  %_cv.longdouble.to.xlong  *****
; **************************************
;
; in:	arg1:arg0 = longdouble
; out:	eax = equivalent slong or xlong
;
; destroys: nothing
;
.globl %_cv.longdouble.to.slong
%_cv.longdouble.to.slong:
.globl %_cv.longdouble.to.xlong
%_cv.longdouble.to.xlong:
fld	tword ptr [esp+4] 	;st(0) = input longdouble
fistp	[workdword]				;convert it to integer
fwait
mov	eax,[workdword]
ret											;no overflow possible (?)
;
;
; **************************************
; *****  %_cv.longdouble.to.ulong  *****
; **************************************
;
; in:	arg1:arg0 = longdouble
; out:	eax = equivalent ulong
;
; destroys: esi
;
.globl %_cv.longdouble.to.ulong
%_cv.longdouble.to.ulong:
fld	tword ptr [esp+4] 			;st(0) = input double
mov	esi,workdword
fistp	[esi]									;convert it to integer
fwait
mov	eax,[esi]
or	eax,eax										;it's not negative, is it?
js	bad3											;'fraid so
ret
;
;
; **************************************
; *****  %_cv.longdouble.to.giant  *****
; **************************************
;
; in:	arg1:arg0 = longdouble
; out:	edx:eax = equivalent giant
;
; destroys: nothing
;
.globl %_cv.longdouble.to.giant
%_cv.longdouble.to.giant:
fld	tword ptr [esp+4] 			;st(0) = input double
fistp	qword ptr [workqword] ;convert it to integer
fwait
mov	eax,[workqword]					;eax = low 32 bits of result
mov	edx,[workqword+4] 			;edx = high 32 bits of result
ret
;
;
; *******************************************
; *****  %_cv.longdouble.to.single      *****
; *****  %_cv.longdouble.to.double      *****
; *****  %_cv.longdouble.to.longdouble  *****
; *******************************************
;
; in:	arg1:arg0 = longdouble
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
.globl %_cv.longdouble.to.single
%_cv.longdouble.to.single:
.globl %_cv.longdouble.to.double
%_cv.longdouble.to.double:
.globl %_cv.longdouble.to.longdouble
%_cv.longdouble.to.longdouble:
fld	tword ptr [esp+4] 			;st(0) = input double
ret
;
;
; **************************
; *****  ns.convert.x  *****  generic string-to-number conversion routine
; **************************  internal entry point
;
; in:	arg0 -> string to convert
;	ebx -> string to free on exit, if any
;	ecx -> table of pointers to conversion routines
; out:	result is in eax, edx:eax, or st(0), depending on its type
;
; destroys: eax, ebx, ecx, edx, esi, edi (except for registers that
;					  contain return values)
; local variables:
;	[ebp-4] -> string to free on exit, if any
;	[ebp-8] -> table of pointers to conversion routines
;
; The tables to the pointers to conversion routines are documented
; later in this source file.
;
ns.convert.x:
push	ebp		; ditto
mov	ebp,esp		; ditto
sub	esp,8		; room for two local variables
;
mov	[ebp-4],ebx	; save pointer to string to free on exit
mov	[ebp-8],ecx	; save pointer to table of conversion routines
;
push	0		; arg 6
push	0		; arg 5
push	0		; arg 4
push	0		; arg 3
push	0		; arg 2
push	[ebp+8]		; arg 1 = numeric string
;;
call	_XstStringToNumber@24	; convert string to some numeric type
mov	ebx,[esp-12]	; ebx = valueType
mov	ecx,[esp-8]	; ecx = lo 32 bits of value$$
mov	edx,[esp-4]	; edx = hi 32 bits of value$$
mov	esi,[ebp-4]	; esi -> string to free on exit, if any
call	%____free
;;
xor	eax,eax		; eax = index into pointer table for SLONG
cmp	ebx,6		; valueType == $$SLONG ???
je	short ns_nn_convert ; yes: convert it
inc	eax		; eax = index into pointer table for XLONG
cmp	ebx,8		; valueType == $$XLONG ???
je	short ns_nn_convert ; yes: convert it
;;
or	ebx,ebx		; valueType == 0 ???  (invalid number)
je	short ns_nn_zero ; yes: return zero as XLONG
;;
inc	eax		; eax = index into pointer table for GIANT
cmp	ebx,12		; valueType == $$GIANT ???
je	short ns_nn_convert ; yes: convert it
inc	eax		; eax = index into pointer table for SINGLE
cmp	ebx,13		; valueType == $$SINGLE ???
je	short ns_nn_convert ; yes: convert it
inc	eax		; eax = index into pointer table for DOUBLE
cmp	ebx,14		; valueType == $$DOUBLE ???
je	short ns_nn_convert ; yes: convert it
;
; error:  return 0		; something very screwy here
;
xor	ecx,ecx		; set value$$ to zero
xor	edx,edx
push	edx		; pass edx:ecx to numeric-to-numeric conversion
push	ecx		; routine
mov	ebx,[ebp-8]	; ebx -> table of pointers to conversion routines
call	[ebx+eax*4]	; call nn conversion routine
; result is now wherever it's supposed to be
mov	esp,ebp
pop	ebp
jmp	%_InvalidFunctionCall	; return directly from there
; LOOSE END
ns_nn_zero:
xor	ecx,ecx		;set value$$ to zero
xor	edx,edx
ns_nn_convert:
push	edx		;pass edx:ecx to numeric-to-numeric conversion	xxx del
push	ecx		; routine					xxx del
mov	ebx,[ebp-8]	;ebx -> table of pointers to conversion routines xx del
call	[ebx+eax*4]	;call nn conversion routine			xxx del
;result is now wherever it's supposed to be	xxx del
mov	esp,ebp		;						xxx del
pop	ebp		;						xxx del
ret			;						xxx del
;
;	jmp, not call, for error handling
;	arg1 = edx	;assumes arg1 is available!!!
;	arg0 = ecx
;	Presumes calling routine creates 64 byte stack
;	  (eg	sub	esp,64
;		call	%cv.string.to.xlong.s
;		add	esp,64)
;
mov	ebx,[ebp-8]	;ebx -> table of pointers to conversion routines xx add
mov	esp,ebp		;						xxx add
pop	ebp		;						xxx add
pop	esi		;save return address				xxx add
mov	[esp+4],edx	;pass edx:ecx to numeric-to-numeric conversion	xxx add
mov	[esp],ecx	; routine					xxx add
push	esi		;restore return address				xxx add
jmp	[ebx+eax*4]	;jmp to nn conversion routine			xxx add
;				;result is now wherever it's supposed to be	xxx add
;
; **************************************************
; *****  string-to-number conversion routines  *****
; **************************************************
;
; in:	arg0 -> string
; out:	result is in eax, edx:eax, or st(0), depending on its type
;
; destroys: eax, ebx, ecx, edx, esi, edi (except for registers that
;					  contain return values)
;
; All string-to-number conversion routines load up parameters for
; ns.convert.x and then branch to it.
;
.globl %_cv.string.to.sbyte.s
%_cv.string.to.sbyte.s:
mov	ebx,[esp+4]
mov	ecx,to_sbyte
jmp	ns.convert.x
;
.globl %_cv.string.to.sbyte.v
%_cv.string.to.sbyte.v:
xor	ebx,ebx
mov	ecx,to_sbyte
jmp	ns.convert.x
;
.globl %_cv.string.to.ubyte.s
%_cv.string.to.ubyte.s:
mov	ebx,[esp+4]
mov	ecx,to_ubyte
jmp	ns.convert.x
;
.globl %_cv.string.to.ubyte.v
%_cv.string.to.ubyte.v:
xor	ebx,ebx
mov	ecx,to_ubyte
jmp	ns.convert.x
;
.globl %_cv.string.to.sshort.s
%_cv.string.to.sshort.s:
mov	ebx,[esp+4]
mov	ecx,to_sshort
jmp	ns.convert.x
;
.globl %_cv.string.to.sshort.v
%_cv.string.to.sshort.v:
xor	ebx,ebx
mov	ecx,to_sshort
jmp	ns.convert.x
;
.globl %_cv.string.to.ushort.s
%_cv.string.to.ushort.s:
mov	ebx,[esp+4]
mov	ecx,to_ushort
jmp	ns.convert.x
;
.globl %_cv.string.to.ushort.v
%_cv.string.to.ushort.v:
xor	ebx,ebx
mov	ecx,to_ushort
jmp	ns.convert.x
;
.globl %_cv.string.to.slong.s
%_cv.string.to.slong.s:
mov	ebx,[esp+4]
mov	ecx,to_slong
jmp	ns.convert.x
;
.globl %_cv.string.to.slong.v
%_cv.string.to.slong.v:
xor	ebx,ebx
mov	ecx,to_slong
jmp	ns.convert.x
;
.globl %_cv.string.to.ulong.s
%_cv.string.to.ulong.s:
mov	ebx,[esp+4]
mov	ecx,to_ulong
jmp	ns.convert.x
;
.globl %_cv.string.to.ulong.v
%_cv.string.to.ulong.v:
xor	ebx,ebx
mov	ecx,to_ulong
jmp	ns.convert.x
;
.globl %_cv.string.to.xlong.s
%_cv.string.to.xlong.s:
mov	ebx,[esp+4]
mov	ecx,to_xlong
jmp	ns.convert.x
;
.globl %_cv.string.to.xlong.v
%_cv.string.to.xlong.v:
xor	ebx,ebx
mov	ecx,to_xlong
jmp	ns.convert.x
;
.globl %_cv.string.to.giant.s
%_cv.string.to.giant.s:
mov	ebx,[esp+4]
mov	ecx,to_giant
jmp	ns.convert.x
;
.globl %_cv.string.to.giant.v
%_cv.string.to.giant.v:
xor	ebx,ebx
mov	ecx,to_giant
jmp	ns.convert.x
;
.globl %_cv.string.to.single.s
%_cv.string.to.single.s:
mov	ebx,[esp+4]
mov	ecx,to_single
jmp	ns.convert.x
;
.globl %_cv.string.to.single.v
%_cv.string.to.single.v:
xor	ebx,ebx
mov	ecx,to_single
jmp	ns.convert.x
;
.globl %_cv.string.to.double.s
%_cv.string.to.double.s:
mov	ebx,[esp+4]
mov	ecx,to_double
jmp	ns.convert.x
;
.globl %_cv.string.to.double.v
%_cv.string.to.double.v:
xor	ebx,ebx
mov	ecx,to_double
jmp	ns.convert.x
;
;
.globl %_cv.string.to.longdouble.s
%_cv.string.to.longdouble.s:
mov	ebx,[esp+4]
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx					; save pointer to string to free on exit
push	0
push	0
push	0
push	0
push	0
push	0
push	[ebp+8]							; string
call	_XstStringToLongDouble@28
fld	tword ptr [esp-12]	; long double value
mov	esi,[ebp-4]					; esi -> string to free on exit, if any
call	%____free
mov	esp,ebp
pop	ebp
ret
;
;
.globl %_cv.string.to.longdouble.v
%_cv.string.to.longdouble.v:
xor	ebx,ebx
push	ebp
mov	ebp,esp
sub	esp,4
mov	[ebp-4],ebx					; save pointer to string to free on exit
push	0
push	0
push	0
push	0
push	0
push	0
push	[ebp+8]							; string
call	_XstStringToLongDouble@28
fld	tword ptr [esp-12]	; long double value
mov	esi,[ebp-4]					; esi -> string to free on exit, if any
call	%____free
mov	esp,ebp
pop	ebp
ret
;
;
; *******************************************************
; *****  TABLES OF POINTERS TO CONVERSION ROUTINES  *****
; *******************************************************
;
; Each table contains five pointers to conversion routines that convert a
; number to a single type T.  The five pointers, in the order in which
; they appear in each table, are to conversion routines to convert:
;
;	from SLONG to T
;	from XLONG to T
;	from GIANT to T
;	from SINGLE to T
;	from DOUBLE to T
;
.text
.align	8
to_sbyte:
.dword	%_cv.slong.to.sbyte
.dword	%_cv.xlong.to.sbyte
.dword	%_cv.giant.to.sbyte
.dword	%_cv.single.to.sbyte
.dword	%_cv.double.to.sbyte
to_ubyte:
.dword	%_cv.slong.to.ubyte
.dword	%_cv.xlong.to.ubyte
.dword	%_cv.giant.to.ubyte
.dword	%_cv.single.to.ubyte
.dword	%_cv.double.to.ubyte
to_sshort:
.dword	%_cv.slong.to.sshort
.dword	%_cv.xlong.to.sshort
.dword	%_cv.giant.to.sshort
.dword	%_cv.single.to.sshort
.dword	%_cv.double.to.sshort
to_ushort:
.dword	%_cv.slong.to.ushort
.dword	%_cv.xlong.to.ushort
.dword	%_cv.giant.to.ushort
.dword	%_cv.single.to.ushort
.dword	%_cv.double.to.ushort
to_slong:
.dword	%_cv.slong.to.slong
.dword	%_cv.xlong.to.slong
.dword	%_cv.giant.to.slong
.dword	%_cv.single.to.slong
.dword	%_cv.double.to.slong
to_ulong:
.dword	%_cv.slong.to.ulong
.dword	%_cv.xlong.to.ulong
.dword	%_cv.giant.to.ulong
.dword	%_cv.single.to.ulong
.dword	%_cv.double.to.ulong
to_xlong:
.dword	%_cv.slong.to.xlong
.dword	%_cv.xlong.to.xlong
.dword	%_cv.giant.to.xlong
.dword	%_cv.single.to.xlong
.dword	%_cv.double.to.xlong
to_giant:
.dword	%_cv.slong.to.giant
.dword	%_cv.xlong.to.giant
.dword	%_cv.giant.to.giant
.dword	%_cv.single.to.giant
.dword	%_cv.double.to.giant
to_single:
.dword	%_cv.slong.to.single
.dword	%_cv.xlong.to.single
.dword	%_cv.giant.to.single
.dword	%_cv.single.to.single
.dword	%_cv.double.to.single
to_double:
.dword	%_cv.slong.to.double
.dword	%_cv.xlong.to.double
.dword	%_cv.giant.to.double
.dword	%_cv.single.to.double
.dword	%_cv.double.to.double
;
;
;
.data
.align	8
workdword:
.dword	0xBADBEEF
;
.align	8
workqword:
.dword	0x98765432, 0xFEDCBA98
