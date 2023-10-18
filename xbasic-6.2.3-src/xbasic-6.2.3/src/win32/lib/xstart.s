;
; ######################  Max Reason
; #####  xstart.s  #####  copyright 1988-2000
; ######################  Windows XBasic assembly standalone startup file
;
; PROGRAM "xstart.s"    ' Startup code for XBasic standalone programs
; VERSION "0.0005"      ' linked to standalone code to make standalone.exe
;
;
.text
.globl	_main			; C entry label
.globl	_WinMain		; Windows entry label
.globl	_WinMain@16		; Windows entry label ???
;
;
; ########################
; #####  WinMain ()  #####
; ########################
;
.align	8
;
_main:				; C entry label
_WinMain:			; Windows entry label
_WinMain@16:			; Windows entry label
push	ebp			; standard function entry
mov	ebp,esp			; standard function entry
push	0x00000000		; arg7 = reserved
push	0x00000000		; arg6 = reserved
push	%_StartApplication	; arg5 = %_StartApplication
push	_WinMain		; arg4 = &WinMain() == ##CODE
push	[ebp+20]		; arg3 = nCmdShow
push	[ebp+16]		; arg2 = lpszCmdLine
push	[ebp+12]		; arg1 = hPrevInstance
push	[ebp+8]			; arg0 = hInstance
call	_XxxMain		; XxxMain() is in xlib.s in xb.dll
mov	esp,ebp			; restore stack pointer
pop	ebp			; previous frame
ret				; done
;
