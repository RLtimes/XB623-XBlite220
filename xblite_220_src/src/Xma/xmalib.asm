

; ###########################################  Max Reason
; #####  Xma Assembly Language Library  #####  copyright 1988-2000
; ###########################################  Windows XBasic assembly language library

; subject to LGPL - see COPYING_LIB

; maxreason@maxreason.com

; for Windows XBasic


; PROGRAM "xmalib"	' fake PROGRAM statement - name this library
; VERSION "0.0002"	' fake VERSION statement - keep version updated

; assembly language source code for Xma math functions
; called by Xma library

; Converted to GoAsm 21 October 2005 GH


; DATA SECTION SHARED "shr_data"
;  _##SOFTBREAK			dd 0		; ##SOFTBREAK		(all XBasic SYSTEMCALLs)
;  _errno						dd 0


.code
; ########################
; #####  XxxFSTCW@0  #####
; ########################

_XxxFSTCW@0:
	xor	eax,eax
	push	eax
	fstcw	w[esp]
	pop	eax
	ret


; ########################
; #####  XxxFSTSW@0  #####
; ########################

_XxxFSTSW@0:
	xor	eax,eax
	push	eax
	fstsw	w[esp]
	pop	eax
	ret


; #######################
; #####  XxxFLDZ@0  #####
; #######################

_XxxFLDZ@0:
	fldz
	ret


; #######################
; #####  XxxFLD1@0  #####
; #######################

_XxxFLD1@0:
	fld1
	ret


; ########################
; #####  XxxFLDPI@0  #####
; ########################

_XxxFLDPI@0:
	fldpi
	ret


; #########################
; #####  XxxFLDL2E@0  #####
; #########################

_XxxFLDL2E@0:
	fldl2e
	ret


; #########################
; #####  XxxFLDL2T@0  #####
; #########################

_XxxFLDL2T@0:
	fldl2t
	ret


; #########################
; #####  XxxFLDLG2@0  #####
; #########################

_XxxFLDLG2@0:
	fldlg2
	ret


; #########################
; #####  XxxFLDLN2@0  #####
; #########################

_XxxFLDLN2@0:
	fldln2
	ret


; ########################
; #####  XxxF2XM1@8  #####
; ########################

_XxxF2XM1@8:
	fld	q[esp+4]
	f2xm1
	ret	8


; #######################
; #####  XxxFABS@8  #####
; #######################

_XxxFABS@8:
	fld	q[esp+4]
	fabs
	ret	8


; #######################
; #####  XxxFCHS@8  #####
; #######################

_XxxFCHS@8:
	fld	q[esp+4]
	fchs
	ret	8


; #######################
; #####  XxxFCOS@8  #####
; #######################

_Cos@8:
_XxxFCOS@8:
	fld	q[esp+4]
	fcos
	ret	8

; ####################
; #####  ATAN@8  #####
; ####################

_Atan@8:
	fld	q[esp+4]
	fld1
	fpatan
	ret	8


; ##########################
; #####  XxxFPATAN@16  #####
; ##########################

_XxxFPATAN@16:
	fld	q[esp+4]
	fld	q[esp+12]
	fpatan
	ret	16


; #########################
; #####  XxxFPREM@16  #####
; #########################

_XxxFPREM@16:
	fld	q[esp+12]										;	y
	fld	q[esp+4]										;	x

xxxFPREM.0:
	fprem														; st0 <- x - INT_0(x/y) * y
	fnstsw	ax											; is C2 in FPU SW set
	and	ax, 0x0400									;
	jnz	< xxxFPREM.0								; jump if it is
	ret	16


; ##########################
; #####  XxxFPREM1@16  #####
; ##########################

_XxxFPREM1@16:
	fld	q[esp+12]										; y
	fld	q[esp+4]										; x

xxxFPREM1.0:                                                ; #########################
	fprem1													; st0 <- x - INT(x/y) * y ; #####  XxxFPTAN@16  #####
	fnstsw	ax											; is C2 in FPU SW set     ; #########################
	and	ax, 0x0400									; _XxxFPTAN@16:
	jnz	< xxxFPREM1.0								; jump if it is	fld	q[esp+4]
	ret	16


; #########################
; #####  XxxFPTAN@16  #####
; #########################

_XxxFPTAN@16:
	fld	q[esp+4]
	fptan
	fstp	q[esp+12]
	ret	16


; ###################
; #####  TAN@8  #####
; ###################

_Tan@8:
	fld	q[esp+4]
	fptan
	fstp	q[esp-8]
	ret	8


; ##########################
; #####  XxxFRNDINT@8  #####
; ##########################

_XxxFRNDINT@8:
	fld	q[esp+4]
	frndint
	ret	8


; ##########################
; #####  XxxFSCALE@16  #####
; ##########################

_XxxFSCALE@16:
	fld	q[esp+4]
	fld	q[esp+12]
	fscale
	fxch
	xor	eax,eax
	push	eax
	fstp	q[esp]
	add	esp,4
	ret	16


; #######################
; #####  XxxFSIN@8  #####
; #######################

_Sin@8:
_XxxFSIN@8:
	fld	q[esp+4]
	fsin
	ret	8


; ###########################
; #####  XxxFSINCOS@16  #####
; ###########################

_XxxFSINCOS@16:
	fld	q[esp+4]
	fsincos
	fstp	q[esp+12]
	ret	16


; ########################
; #####  XxxFSQRT@8  #####
; ########################

_Sqrt@8:
_XxxFSQRT@8:
	fld	q[esp+4]
	fsqrt
	ret	8


; ###########################
; #####  XxxFXTRACT@16  #####
; ###########################

_XxxFXTRACT@16:
	fld	q[esp+4]
	fxtract
	fstp	q[esp+12]
	ret	16


; #########################
; #####  XxxFYL2X@16  #####
; #########################

_XxxFYL2X@16:
	fld	q[esp+4]
	fld	q[esp+12]
	fyl2x
	ret	16


; ###########################
; #####  XxxFYL2XP1@16  #####
; ###########################

_XxxFYL2XP1@16:
	fld	q[esp+4]
	fld	q[esp+12]
	fyl2xp1
	ret	16


; ####################
; #####  EXP ()  #####  e ** x#
; ####################

.code
_Exp@8:
	push	ebp
	mov	ebp,esp
	sub	esp,8
	fld	q[ebp+8]
	fldl2e
	fmulp
	jmp	 expdo


; #####################
; #####  EXP2 ()  #####  2 ** x#
; #####################

_Exp2@8:
	push	ebp
	mov	ebp,esp
	sub	esp,8
	fld	q[ebp+8]
	jmp	 expdo

; ######################
; #####  EXP10 ()  #####  10 ** x#
; ######################

_Exp10@8:
	push	ebp
	mov	ebp,esp
	sub	esp,8
	fld	q[ebp+8]
	fldl2t
	fmulp
;	jmp	 expdo

expdo:
	fstcw	w[ebp-4]
	fstcw	w[ebp-8]
	fwait
	and	w[ebp-4],0xF3FF
	fldcw	w[ebp-4]
	fld	st0
	frndint
	fldcw	w[ebp-8]
	fxch	st1
	fsub	st0,st1
	f2xm1
	fwait
	fld1
	faddp	st1,st0
	fscale
	fstp	st1
	mov	esp,ebp
	pop	ebp
	ret	8


; The following code is not needed, as it is duplicated in power@16.asm
; in the xblib.lib library

; ; #################################
; ; #####  x# = y# ** z#  ###########
; ; #################################
; ; #####  x# = POWER (y#, z#)  #####
; ; #################################

; .code
; _Power@16:
; push	ebp
; mov	ebp,esp
; sub	esp,24
; push	ebx
; fld	q[ebp+8]
; fld	q[ebp+16]
; fldz                   ; 0 y x
; fucom	st1
; fnstsw	ax
; and	ah,68
; xor	ah,64
; jnz >	 power.nonzorch
; fstp	st0
; fstp	st0
; fstp	st0
; fld1
; jmp 	power.done

; power.nonzorch:
; fucom	st2            ; 0 y x
; fnstsw	ax
; and	ah,68
; xor	ah,64
; jnz >	 power.3
; fstp	st2
; fcompp
; fnstsw	ax
; and	ah,69
; cmp	ah,1
; jz > power.15
; fldz
; jmp 	power.done

; power.3:
; fld1                  ; 1 0 y x
; fucomp	st2         ; 0 y x
; fnstsw	ax
; and	ah,69
; cmp	ah,64
; jz >	power.14
; fcomp	st2           ; y x
; fnstsw	ax
; and	ah,69
; jnz > power.7
; fld	st0             ; y y x
; fnstcw	w[ebp-2]
; mov	ax,w[ebp-2]
; mov	ah,12
; mov	w[ebp-4],ax
; fldcw	w[ebp-4]
; sub	esp,8
; fistp	q[esp]
; pop	edx
; pop	ecx
; fldcw	w[ebp-2]
; mov	ebx,edx
; and	ebx,1
; push	ecx
; push	edx
; fild	q[esp]
; add	esp,8             ; int(y) y x
; fucomp	st1         ; y x
; fnstsw	ax
; and	ah,69
; cmp	ah,64
; jz >	 power.8
; fstp	st0
; fstp	st0
; ;
; power.15:
; mov	d[_errno],33				; EDOM : errno = "domain error"
; mov	d[esp],0xFFFFFFFF
; mov	d[esp+4],0x7FFFFFFF
; fld	q[esp]		; $$PNAN = not a number
; jmp 	power.done


; power.8:
; fxch	st1           ; x y
; fchs
; jmp 	 power.9


; power.7:
; fxch	st1           ; x y
; xor	ebx,ebx
; ;
; power.9:
; fnstcw	w[ebp-2]
; mov	dx, w[ebp-2]
; mov	w[ebp-4],dx
; mov	dx, w[ebp-2]
; and	dh,243
; or	dl,63
; mov	w[ebp-2],dx
; fldcw	w[ebp-2]
; fyl2x                ; y*log2(x)
; fld st0
; frndint
; fxch
; fsub st0, st1
; f2xm1
; fld1
; fadd
; fxch
; fld1
; fscale
; fstp	st1
; fmul
; fldcw	w[ebp-4]
; sub	esp,8
; fst	q[esp]
; call	isinf
; test	eax,eax
; jnz > power.11
; call	isnan
; test	eax,eax
; jz > power.10
; ;
; power.11:
; mov	d[_errno],34		; ERANGE : errno = "range error"
; ;
; power.10:
; test	ebx,ebx
; jz > power.done
; fchs
; jmp 	 power.done


; power.14:
; fstp	st0
; fstp	st0
; ;
; power.done:
; mov	ebx,[ebp-28]
; mov	esp,ebp
; pop	ebp
; ret	16


; isnan:
; xor	edx,edx
; mov	ax, w[esp+10]
; shr	ax,4
; and	eax,0x000007FF
; cmp	eax,0x000007FF
; jnz	> iszero
; test d[esp+8],0x000FFFFF
; jnz	> isone
; cmp	d[esp+4],0
; jnz	> isone
; ;
; iszero:
; xor	eax,eax
; ret


; isone:
; mov	eax,0x00000001
; ret


; isinf:
; mov	eax,[esp+8]
; and	eax,0x7FFFFFFF
; cmp	eax,0x7FF00000
; jnz	 iszero
; cmp	d[esp+4],0
; jnz	 iszero
; mov	eax,0x00000001
; cmp	b[esp+11], 0
; jge	> isinf.done
; mov	eax,0xFFFFFFFF
; isinf.done:
; ret


