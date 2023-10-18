DATA SECTION SHARED "shr_data"
	_errno db 4

; #################################
; #####  x# = y# ** z#  ###########
; #################################
; #####  x# = POWER (y#, z#)  #####
; #################################

.code
_Power@16:
_POWER@16:
push	ebp
mov	ebp,esp
sub	esp,24
push	ebx
fld	q[ebp+8]
fld	q[ebp+16]
fldz                   ; 0 y x
fucom	st1
fnstsw	ax
and	ah,68
xor	ah,64
jnz > power.nonzorch
fstp	st0
fstp	st0
fstp	st0
fld1
jmp 	power.done
power.nonzorch:
fucom	st2            ; 0 y x
fnstsw	ax
and	ah,68
xor	ah,64
jnz > power.3
fstp	st2
fcompp
fnstsw	ax
and	ah,69
cmp	ah,1
jz 	> power.15
fldz
jmp 	power.done
power.3:
fld1                  ; 1 0 y x
fucomp	st2         ; 0 y x
fnstsw	ax
and	ah,69
cmp	ah,64
jz 	> power.14
fcomp	st2           ; y x
fnstsw	ax
and	ah,69
jnz > power.7
fld	st0             ; y y x
fnstcw	w[ebp-2]
mov	ax, w[ebp-2]
mov	ah,12
mov	 w[ebp-4],ax
fldcw	w[ebp-4]
sub	esp,8
fistp	q[esp]
pop	edx
pop	ecx
fldcw	w[ebp-2]
mov	ebx,edx
and	ebx,1
push	ecx
push	edx
fild	q[esp]
add	esp,8             ; int(y) y x
fucomp	st1         ; y x
fnstsw	ax
and	ah,69
cmp	ah,64
jz 	> power.8
fstp	st0
fstp	st0
power.15:
mov	d[_errno],33				; EDOM : errno = \"domain error\"
mov	d[esp],0xFFFFFFFF
mov	d[esp+4],0x7FFFFFFF
fld	q[esp]		; $$PNAN = not a number
jmp 	power.done
power.8:
fxch	st1           ; x y
fchs
jmp > power.9
power.7:
fxch	st1           ; x y
xor	ebx,ebx
power.9:
fnstcw w[ebp-2]
mov	dx, w[ebp-2]
mov	 w[ebp-4],dx
mov	dx, w[ebp-2]
and	dh,243
or	dl,63
mov	 w[ebp-2],dx
fldcw	w[ebp-2]
fyl2x                ; y*log2(x)
fld st0
frndint
fxch
fsub st0, st1
f2xm1
fld1
fadd
fxch
fld1
fscale
fstp	st1
fmul
fldcw	w[ebp-4]
sub	esp,8
fst	q[esp]
call	isinf
test	eax,eax
jnz > power.11
call	isnan
test	eax,eax
jz 	> power.10
power.11:
mov	d[_errno],34		; ERANGE : errno = \"range error\"
power.10:
test	ebx,ebx
jz 	> power.done
fchs
jmp > power.done
power.14:
fstp	st0
fstp	st0
power.done:
mov	ebx,[ebp-28]
mov	esp,ebp
pop	ebp
ret	16
isnan:
xor	edx,edx
mov	ax, w[esp+10]
shr	ax,4
and	eax,0x000007FF
cmp	eax,0x000007FF
jnz	> iszero
test d[esp+8],0x000FFFFF
jnz	> isone
cmp	d[esp+4],0
jnz	> isone
iszero:
xor	eax,eax
ret
isone:
mov	eax,0x00000001
ret
isinf:
mov	eax,[esp+8]
and	eax,0x7FFFFFFF
cmp	eax,0x7FF00000
jnz	iszero
cmp	d[esp+4],0
jnz	iszero
mov	eax,0x00000001
cmp	b[esp+11], 0
jge	> isinf.done
mov	eax,0xFFFFFFFF
isinf.done:
ret
