;
; #######################################  Max Reason
; #####  Assembly Language Library  #####  copyright 1988-2000
; #######################################  Windows XBasic assembly language library
;
; subject to LGPL - see COPYING_LIB
;
; maxreason@maxreason.com
;
; for Windows XBasic
;
; PROGRAM "xlib"
; VERSION "0.017"
;
; revision November 2003
; Added _XstTry@12 and _XstGetExceptionInformation@8
; and other modifications to handle exceptions
; code by Ken Minogue
;
; revision September 2005 - GH
; - Converted to GoAsm
; - Deleted extraneous initialization code.
;
; revision April 2006 - GH
;	- went through all the code and deleted extraneous stuff
;	- optimized where possibilities were evident
;	- simplified memory allocation slightly
; - "cleaned up" code and comments
;
;
; Mostly assembly language source code for XBasic language intrinsics
; like ABS(), LEFT$(), MID$(), TRIM$(), etc.
;
; This file contains assembly language routines for several purposes, including:
;   1. Startup initialization - XxxMain is called by xinit.s or app at startup
;   2. Error handling - handle "jmp %eeeErrorName" in XBasic source programs
;   3. Dynamic memory management - malloc, calloc, recalloc, free, etc...
;   4. Array management - DimArray, RedimArray, FreeArray
;   5. Intrinsic functions - ABS(), BIN$(), CHR$(), etc...
;   6. General support routines, especially for program development environment

; To create the program development environment, this file is assembled into
; object file "xlib.o" which is linked to, and becomes part of, the program
; development environment - aka PDE.  The global variables in xlib.s are
; therefore in the PDE executable file, and are read in by the PDE when it
; starts up.  The addresses of all xlib.s routines are therefore available
; to the compiler and calls to xlib.s routines in user programs are resolved
; without difficulty.

; When standalone XBasic programs are created by WindowsNT tools, they
; are linked to "xlib.dll", a DLL version of xlib.  Program references
; to xlib.s routines are thus resolved by the Windows program loader.

; External variables are not shared in the same manner in both cases.
; External variables are shared by all programs linked into a single
; executable (.DLL or .EXE).  External variables in user programs are
; not shared with .DLL libraries.  So function libraries developed in
; the PDE should not contain external variables - at least not external
; variables meant to be shared by programs or other function libraries
; that use the .DLL as a .DLL.  External variables are only shared with
; programs linked into a single .EXE or .DLL.


; #######################
; #####  CONSTANTS  #####  assembly language constants for this file
; #######################

#define  PAGE_NOACCESS	  				0x00000001
#define  MEM_RESERVE	  					0x00002000
#define  PAGE_READWRITE   				0x00000004
#define  MEM_COMMIT	  						0x00001000

; #define  SECTION_QUERY	     	0x00000001
; #define  SECTION_MAP_WRITE   	0x00000002
; #define  SECTION_MAP_READ    	0x00000004
; #define  SECTION_MAP_EXECUTE 	0x00000008
; #define  SECTION_EXTEND_SIZE 	0x00000010

; #define  PAGE_READONLY	  		0x00000002
; #define  MEM_DECOMMIT	  			0x00004000
; #define  MEM_RELEASE	  			0x00008000
; #define  MEM_FREE	  					0x00010000
; #define  MEM_PRIVATE	  			0x00020000


; ******************************
; *****  SYSTEM EXTERNALS  *****  values persist on user task run/kill/run/kill...
; ******************************

DATA SECTION SHARED "shr_data"

	_##CODE0												dd ?	; Xit code page base (first page)
	_##CPU													dd ?	; ##CPU
	_##DYNO0												dd ?	; Dyno page base
	_##DYNO													dd ?	; Dyno headers start here
	_##DYNOX												dd ?	; Dyno headers end here
	_##DYNOZ												dd ?	; Dyno page ends here
	_##ERROR												dd ?	; ##ERROR	(XBASIC error number)
	_##LOCKOUT											dd ?	; ##LOCKOUT
	_##SIGNALACTIVE									dd ?	; ##SIGNALACTIVE	(Xit)
	_##OSEXCEPTION									dd ?	; ##OSEXCEPTION
	_##TABSAT												dd ?	; ##TABSAT	(tabs set every n columns)
	_##WHOMASK											dd ?	; ##WHOMASK	(allocation owner, info word)
	_##USERRUNNING									dd ?	; ##USERRUNNING
  _##GLOBAL0  										dd ?	; External block starts here
  _##GLOBAL   										dd ?	; External block after system
  _##GLOBALX  										dd ?	; External block next available
  _##GLOBALZ  										dd ?	; External block after
  _##ENTERED	  									dd ?  ; ##ENTERED
  _##HINSTANCEDLL 								dd ?  ; ##HINSTANCEDLL - hInstance of .dll
  _##UCODE    										dd ?	; User code starts here
	_##MAIN													dd ?
	_##XBDir$												dd ?


; ############################################
; ############################################
; #####  		CODE SECTION  							 #####
; ############################################
; ############################################


; ########################
; #####  XxxMain ()  #####
; ########################

; _XxxMain is not called from this code. A minimal _XxxMain is retained,
; however, for the sake of compatibility with previous EXEs.

.code
align	8
_XxxMain:
	; [ebp+28] = %_StartApplication
	invoke _Xit@4, [ebp+28]
	ret 32  												; remove 8 entry arguments and return to WinMain()


; ###########################
; #####  initialize ()  #####
; ###########################

initialize:
_initialize:

; allocate 256mb dynamic memory
	invoke _VirtualAlloc@16, 0, 0x10000000, MEM_RESERVE, PAGE_NOACCESS
	test	eax,eax										; did it fail?
	jnz	> allocOK										; 0 = failure
	ret															; Can't allocate memory, return with error

; dynamic memory successfully allocated above
; now we commit the first 8mb
allocOK:
	mov	[_##DYNO0],eax							; store the base of _##DYNO area
	mov	[_##DYNO],eax								; ditto
	invoke _VirtualAlloc@16, eax, 0x00800000, MEM_COMMIT, PAGE_READWRITE
	test	eax,eax										; did it fail?
	jnz	>	allocFinished							; 0 = failure
	ret															; Can't allocate memory, return with error

allocFinished:
	mov	eax,[_##DYNO0]							; base of _##DYNO area
	add	eax,0x00800000							; after _##DYNO area (8mb)
	mov	[_##DYNOZ],eax							; after committed area
	sub	eax,16											; eax = last header addr
	mov	[_##DYNOX],eax
	mov d[%initialized],-1        	; dynamic memory has been initialized


; Build low header and high header to allocate stretchy space.
; To start off, all of dynamic memory is in one big free block.
	mov	eax,[_##DYNO]								; eax -> first dyno header
	xor	ecx,ecx											; ready to zero some stuff later
	mov	[%pointers+0x40],eax				; first (and only) dyno block is a big one
	mov	ebx,[_##DYNOX]							; ebx -> last dyno header
	mov	edx,ebx											; edx -> last dyno header
	sub	ebx,eax											; ebx = size of the one block
	mov	[eax+0],ebx									; addr-uplink(first) = size(first)
	mov	[eax+4],ecx									; addr-downlink(first) = 0 (none)
	mov	[eax+8],ecx									; size-uplink(first) = 0 (none)
	mov	[eax+12],ecx								; size-downlink(first) = 0 (none)
	mov	[edx+0],ecx									; addr-uplink(last) = 0
	mov	[edx+4],ebx									; addr-downlink(last) = size(first)
	mov	[edx+8],ecx									; size-uplink(last) = 0 (none)
	mov	[edx+12],ecx								; size-uplink(last) = 0 (none)   11/04/93
	or	ebx,0x80000000							; mark allocated  11/04/93
	mov	[edx+4],ebx									; mark allocated  11/04/93

; allocation routines blow up unless there's a permanent allocated
; memory block at the bottom of the dyno memory area, so make one!
	mov	esi,16											; esi = 16 bytes
	call	%____calloc								; allocate 16 byte chunk
	mov eax,0x80130001							; info word = allocated string
	mov	[esi-4],eax									; save info word
	mov d[esi-8],14									; save length
	mov	edi,esi											; destination
	mov	esi,ADDR %pdeString					; source
	mov	ecx,14											; count
	rep movsb
	mov d[%initmemdone], -1        	; dynamic memory has been initialized
	mov d[_##TABSAT], 2							; Default tab setting is 2
	ret


; ############################
; #####  XxxTerminate@0  #####
; ############################

_XxxTerminate@0:
	push  eax
	push	-1
	push	0
	call	_XxxXstFreeLibrary@8			; free all libraries
	mov	eax,[_##DYNO0]
	mov	ebx,[_##DYNOZ]
	sub	ebx,eax
	push	0x4000
	push	ebx
	push	eax
	call	_VirtualFree@12						; free all DYNO memory
	call	_ExitProcess@4
	ret


; *********************
; *****  %_error  *****  errorNumber = ERROR (arg)
; *********************

%_error:
	mov	ebx,eax											; ebx = arg
	inc	ebx													; ebx = 0 if arg = -1
	jz	> getError									; get ##ERROR but don't update it
	xchg eax,[_##ERROR]							; eax = ##ERROR : ##ERROR = arg
	ret

getError:
	mov	eax,[_##ERROR]							; eax = ##ERROR : ##ERROR unchanged
	ret


; *******************************************************
; ********************  XstTry ()  **********************
; *******************************************************

; TYPE EXCEPTION_DATA
;  XLONG .code        '+00
;  XLONG .type        '+04
;  XLONG .address     '+08
;  XLONG .response    '+12
;  XLONG .info[14]    '+16
; END TYPE

; XstTry (SUBADDRESS(Try), SUBADDRESS(Catch), @exception)

;stack usage:
; [ebp-28] entry edi
; [ebp-24] entry esi
; [ebp-20] entry ebx
; [ebp-16] address of previous handler's EXCEPTION_REGISTRATION (+00)
; [ebp-12] address of catch handler													    (+04)
; [ebp-08] value of esp to restore stack if exception occurs	  (+08)
; [ebp-04] local ebp for _XstTry@12														  (+12)
; [ebp+00] entry ebp (for function calling XstTry())            (+16)
; [ebp+04] return address (for call to XstTry())

;the rest of the stack contains the arguments for XstTry():
; [ebp+08] address of user Try SUB                              (+24)
; [ebp+12] address of user Catch SUB                            (+28)
; [ebp+16] address of EXCEPTION_DATA variable                   (+32)

;This handler's EXCEPTION_REGISTRATION starts at ebp-16 and consists of the data from
; ebp-16 to ebp-04 inclusive.  Numbers in brackets are the offsets from the beginning
; of the EXCEPTION_REGISTRATION.  Although the XstTry() arguments are not part of the
; EXCEPTION_REGISTRATION, it is convenient to access them as offsets from the same location.

_XstTry@12:
	push ebp
	mov ebp,esp
																	; create EXCEPTION_REGISTRATION structure
	push ebp
	push 0													; space for esp
	push ADDR catch
	fs mov eax,[0] 									; points to EXCEPTION_REGISTRATION for previous handler
	push eax
																	; install new exception handler
	mov eax,esp
	fs mov [0],eax
																	; save registers
	push ebx
	push ecx
	push edx
	push esi
	push edi
																	; save esp - needed to restore stack if exception occurs
	mov [ebp-8],esp

	; restore stack frame for protected code (the Try SUB), and call it
	; warning! a modification of this section may require a change in the
	; re_try code (below) at the sub eax,.. instruction

	mov eax,[ebp+8]    							; protected code SUBADDRESS
	test eax,eax										; check for 0 address
	jz > end_try
	push ebp
	mov ebp,[ebp]      							; get ebp for stack frame in protected SUB
	call eax           							; call protected SUB
	pop ebp

;exit from XstTry()
end_try:
	call clear_FPU_exception
	mov eax,[ebp-16]    						; pointer to previous handler EXCEPTION_REGISTRATION
	fs mov [0],eax      						; restore previous handler
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	leave
	xor eax,eax
	ret 12

;if a floating-point exception has occurred, clear the FPU
clear_FPU_exception:
	cmp eax,0xC000008D
	jb > not_float_exception
	cmp eax,0xC0000093
	ja > not_float_exception
	sub esp,4
	fstcw w[esp] 										; save current FPU control word
	fclex														; clear exception
	finit														; reinitialize FPU
	fldcw w[esp]										; reload control word
	fwait
	add esp,4
not_float_exception:
	ret

; ###################
; #####  catch  #####
; ###################

;arguments supplied by system when an exception occurs
; [ebp+08] address of EXCEPTION_RECORD
; [ebp+12] address of EXCEPTION_REGISTRATION
; [ebp+16] address of CONTEXT

;After setting ebx to point to the EXCEPTION_REGISTRATION:
; [ebx+00] address of previous handler's EXCEPTION_REGISTRATION
; [ebx+04] address of catch handler
; [ebx+08] value of esp to restore stack if exception occurs
; [ebx+12] local ebp for _XstTry@12
; [ebx+16] entry ebp (for function calling XstTry())
; [ebx+20] return address (for call to XstTry())
; [ebx+24] address of user Try SUB
; [ebx+28] address of user Catch SUB
; [ebx+32] address of EXCEPTION_DATA variable

catch:
	push ebp
	mov ebp,esp											; local stack frame
	push ebx
	push esi
	push edi

	mov ebx,[ebp+12]								; ebx -> EXCEPTION_REGISTRATION

; ebx does not change throughout this routine, always points to EXCEPTION_REGISTRATION
; if any exception flags are set, do not process this exception

	mov esi,[ebp+8]   							; esi -> system EXCEPTION_RECORD
	mov eax,[esi+4]									; .ExceptionFlags
	test eax,eax
	jnz > pass_on
																	; save exception code
	mov eax,[esi]										; .ExceptionCode
	mov [_##OSEXCEPTION],eax
		 															; user-registered exception?
	test eax, 0x20000000   					; $$ExceptionCodeUser
	jnz > user_exception
																	; system exception, so convert to native exception code
	push 0
	push eax
	call _XstSystemExceptionToException@8
	mov eax,[esp-4]									; native exception code
user_exception:
	and eax,0x0FFFFFFF
	mov [_##EXCEPTION],eax

																	; copy exception code to EXCEPTION_DATA argument of XstTry()
	mov edi,[ebx+32]								; edi -> EXCEPTION_DATA argument
	mov [edi],eax										; copy code to EXCEPTION_DATA.code
																	; exception type (eg., $$ExceptionTypeError)
	mov eax,[_##OSEXCEPTION]
	and eax, 0xC0000000
	mov [edi+4],eax									; EXCEPTION_DATA.type
																	; copy address to EXCEPTION_DATA.address
	mov eax,[esi+12]								; .ExceptionAddress
	mov [edi+8],eax
																	; zero .info[] array
	add edi,16   										; edi -> EXCEPTION_DATA.info[]
	mov ecx,15  										; 15 dwords
	push edi
	call %_ZeroMem2
	pop edi
																	; copy EXCEPTION_RECORD.ExceptionInformation[] to EXCEPTION_DATA.info[]
	add esi,16											; esi -> EXCEPTION_RECORD.NumberParameters
	lodsd
	mov ecx,eax											; ecx contains number of valid dwords in .ExceptionInformation[]
	jecxz > no_info
	rep movsd

no_info:													; save ebp for use by XstGetExceptionInformation()
	mov [ex_info],ebp								; get address of user Catch SUB
	mov eax,[ebx+28]	 							; eax -> user catch SUB argument from XstTry()
	test eax,eax				 						; test for 0 address
	jz > no_catch_sub
																	; call user Catch
	push ebx
	push ebp
	mov ebp,[ebx+16]								; ebp for stack frame in user catch SUB
	call eax												; call user Catch SUB
	pop ebp
	pop ebx
no_catch_sub:
	mov d[ex_info],0   							; exception information valid only during Catch SUB

	;get response variable as set by user Catch SUB
	mov edi,[ebx+32]								; edi -> EXCEPTION_DATA argument
	mov eax,[edi+12]								; eax = EXCEPTION_DATA.response

;response can be:
;  0 => exit try block, continue execution after XstTry() (default response)
;  1 => continue search for a handler
; -1 => continue execution at point of exception
; -2 => continue execution at address specified in EXCEPTION_DATA.address
; any other response has the same effect as response = 1

	test eax,eax
	jz > abort_try
	jns > pass_on
	inc eax
	jz > continue_execution
	inc eax
	jz > re_try
	jmp pass_on

; modify CONTEXT to continue execution at retry address.
; Retry address must be a label within the Try SUB.
re_try:
	mov eax,[edi+8]     						; eax = EXCEPTION_DATA.address (set to retry address in Catch SUB)
	mov edi,[ebp+16]    						; edi -> system CONTEXT record
	mov edx,[edi+0xB8]  						; address of exception
	cmp eax,edx         						; compare new address to old address
	je > continue_execution
	mov [edi+0xB8],eax  						; CONTEXT.Eip
	mov eax,[ebx+8]     						; old esp as saved when handler was set up
	sub eax,8           						; esp after entry into Try SUB
	mov [edi+0xC4],eax  						; CONTEXT.Esp
	mov eax,[ebx+16]    						; ebp for function containing Try SUB
	mov [edi+0xB4],eax  						; CONTEXT.Ebp
	xor eax,eax         						; tell system to reload CONTEXT and continue execution
	jmp return_to_system

; continue execution at the point where the exception occurred.
; allowed only for information or warning exceptions.
continue_execution:
	mov esi,[ebp+8]     						; esi -> system EXCEPTION_RECORD
	mov eax,[esi]       						; .ExceptionCode
	and eax,0xC0000000
	cmp eax,0xC0000000  						; $$ExceptionCodeError
	je > pass_on
	xor eax,eax         						; tell system to reload CONTEXT and continue execution
	jmp return_to_system

; modify CONTEXT to continue execution by returning from XstTry()
abort_try:
	mov edi,[ebp+16]    						; edi -> system CONTEXT record
	mov eax,ADDR end_try						; execution will continue from end_try
	mov [edi+0xB8],eax  						; CONTEXT.Eip
	mov eax,[ebx+8]     						; old esp as saved when handler was set up
	mov [edi+0xC4],eax  						; CONTEXT.Esp
	mov eax,[ebx+12]    						; local ebp for _XstTry@12
	mov [edi+0xB4],eax  						; CONTEXT.Ebp
	xor eax,eax         						; tell system to reload CONTEXT and continue execution
	jmp return_to_system

pass_on:
	mov eax,1												; tell system to look for another handler
	return_to_system:
	leave
	ret															; do not pop arguments, C calling convention is used

; *******************************************************
; ****************  End of   XstTry ()  *****************
; *******************************************************

; *******************************************************
; ***********  XstGetExceptionInformation()  ************
; *******************************************************

; XstGetExceptionInformation (@exceptionRecord, @context)

.code
_XstGetExceptionInformation@8 FRAME exceptionRecord, context

	USES esi,edi,ebx,ecx

	; clear user EXCEPTION_RECORD (20 dwords)
	mov edi,[exceptionRecord]
	mov ecx,20
	call %_ZeroMem1

	; clear user CONTEXT (51 dwords)
	mov edi,[context]
	mov ecx,51
	call %_ZeroMem1

	; retrieve ebp for system structures
	mov ebx,[ex_info]
	test ebx,ebx
	jz > no_ex_info

	; copy system EXCEPTION_RECORD
	mov edi,[exceptionRecord]   		; user EXCEPTION_RECORD
	mov esi,[ebx+8]   							; system EXCEPTION_RECORD
	mov ecx,[esi+16]								; put .NumberParameters in ecx
	add ecx,20											; don't forget the first 5 dwords
	rep	movsd												; copy .ExceptionInformation[]

	; copy system CONTEXT
	mov edi,[context]  							; user CONTEXT
	mov esi,[ebx+16]  							; system CONTEXT
	mov ecx,51
	rep	movsd
	mov eax,-1											; indicates success

no_ex_info:
	ret
	ENDF

; *******************************************************
; *******  End of XstGetExceptionInformation () *********
; *******************************************************

; #################################
; #####  XxxGetExceptions ()  #####
; #################################

_XxxGetExceptions@8:
	mov	ebx,[_##OSEXCEPTION]
	mov	eax,[_##EXCEPTION]
	mov d[esp+4],eax
	mov d[esp+8],ebx
	ret	8


; #################################
; #####  XxxSetExceptions ()  #####
; #################################

_XxxSetExceptions@8:
	mov	eax,[esp+4]
	mov	ebx,[esp+8]
	mov	eax,[_##EXCEPTION]
	mov	ebx,[_##OSEXCEPTION]
	ret	8


; ******************************
; *****  SUPPORT ROUTINES  *****
; ******************************

; ##########################
; #####  %_ZeroMemory  #####
; ##########################

; optimized 24 November 2005, Greg Heller
; (should add MMX instructions for really big blocks someday)

%_ZeroMemory:
_XxxZeroMemory:
	mov	ecx,edi											; ecx = byte after last
	sub	ecx,esi											; ecx = # of bytes to zero
	jnb	> zmpos											; positive value

	xchg	esi,edi										; make esi < edi
	mov	ecx,edi											; ecx = byte after last
	sub	ecx,esi											; ecx = # of bytes to zero

zmpos:
	shr	ecx,2												; ecx = # of dwords to zero
	mov	edi,esi											; edi -> beginning of block to zero

	; On PPro, P2 and P3, REP MOVS and REP STOS can perform fast by moving an entire
	; cache line at a time. This happens only when the following conditions are met:
	; • both source and destination must be aligned by 8
	; • direction must be forward (direction flag cleared)
	; • the count (ECX) must be greater than or equal to 64
	; • the difference between EDI and ESI must be numerically greater than or equal to 32
	; • the memory type for both source and destination must be either write-back or writecombining
	; (you can normally assume this).
	; Under these conditions, the number of uops issued is approximately 215+2*ECX for REP
	; MOVSD and 185+1.5*ECX for REP STOSD, giving a speed of approximately 5 bytes per clock
	; cycle for both instructions, which is almost 3 times as fast as when the above conditions are
	; not met.

	; FROM How to optimize for the Pentium family of microprocessors
	; By Agner Fog, Ph.D.
	; Copyright © 1996 - 2004

%_ZeroMem0:												; This routine is used for large blocks
	xor	eax,eax											; ready to write some zeros
	cmp ecx,64											; is it more than 64 dwords? (per Agner Fog's rule above)
	jl > %_ZeroMem1									; if so go to the medium routine
	test edi,-7											;	is edi 8 byte aligned?
	jz >Z0													;	if so, jump to copy routine
	mov d[edi],eax									;	do one copy
	add edi,4												; realign edi
	dec	ecx													; set ecx to new value
Z0:																;	at this point edi is 8 byte aligned
	cld															; make sure it is going the right way
	rep stosd												; write them!
	ret															; go home again

%_ZeroMem1:												; This routine is used for medium-sized blocks
	cmp ecx,8												; is it less than 32 bytes
	jl > %_ZeroMem2									; if so go to the short routine
	push edx												; preserve edx
	push esi												; preserve esi

	mov edx,ecx											; save how many we will write
	shr ecx,3												; divide by 8
	xor	eax,eax											; ready to write some zeros
	mov esi,ecx											; calculate how many will be written in the big loop
	shl esi,3												; and multiply it by 8

Z1:
	mov [edi+ 0],eax								; write 32 bytes at a time
	mov [edi+ 4],eax								;
	mov [edi+ 8],eax								;
	mov [edi+12],eax								;
	mov [edi+16],eax								;
	mov [edi+20],eax								;
	mov [edi+24],eax								;
	mov [edi+28],eax								;
	add edi,32											; move the pointer
	dec ecx													; decrement the loop count
	jnz < Z1												; are we there yet?

	sub edx,esi											; subtract how many written already from how many needed
	pop esi													; restore esi, since we used it
	mov ecx,edx											; move the new count to ecx for the next loop
	pop edx													; restore edx, since we used it

%_ZeroMem2:												; This routine is used for small blocks
	jecxz	> zm_exit									; skip if no bytes to zero
	xor	eax,eax											; ready to write some zeros
Z2:
	mov [edi],eax										; write 1 dword at a time
	add edi,4												; move the pointer
	dec ecx													; decrement the loop count
	jnz < Z2

zm_exit:													; done, we're gone!
	ret

; operating system cannot allocate memory
%_eeeErrorNT:
	push [ _##EXCEPTION_MEMORY_ALLOCATION]
	jmp	%_RuntimeError

; usually due to attempt to allocate a block already allocated
%_eeeAllocation:
	push [_##EXCEPTION_MEMORY_ALLOCATION]
	jmp	%_RuntimeError

; various integer overflow errors (type conversion, etc)
%_eeeOverflow:
	push [_##EXCEPTION_INT_OVERFLOW]
	jmp	%_RuntimeError

; array index < 0 or > UBOUND()  (only if compiled with -bc switch)
%_OutOfBounds:
	push [_##EXCEPTION_OUT_OF_BOUNDS]
	jmp	%_RuntimeError

; attempt to ATTACH to non-null node
%_NeedNullNode:
	push [_##EXCEPTION_NODE_NOT_EMPTY]
	jmp	%_RuntimeError

; error in #dimensions (eg. DIM a[5]: a[3,2] = 25)  (only if compiled with -bc switch)
%_UnexpectedLowestDim:
	push [_##EXCEPTION_ARRAY_DIMENSION]
	jmp	%_RuntimeError

; error in #dimensions (eg. DIM a[5,5]: a[3] = 25)  (only if compiled with -bc switch)
%_UnexpectedHigherDim:
	push [_##EXCEPTION_ARRAY_DIMENSION]
	jmp	%_RuntimeError

%_InvalidFunctionCall:
	push [_##EXCEPTION_INVALID_ARGUMENT]
	jmp	%_RuntimeError

%_RuntimeError:
	call _XstCauseException@4
	ret

; ############################################
; ############################################
; #####  DATA  #####  DATA  #####  DATA  #####
; ############################################
; ############################################

.data
align	8
%dbase:
%pointers:
xxxPointers:
_XxxPointers:
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	;  16, 32, 48, 64  ... 240, 256
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	;  512, 1K, 2K, 4K, 8K, 16K, 32K, 64K,  128K, 256K, 512K, 1M, 2M, 4M, 8M, 16M
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	;  32M, 64M, 128M, 256M, 512M, 1G, 2G, 4G,  8G, 16G, 32G, 64G, 128G, 256G, 512G
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0	;  ...
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dd	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

%initialized 	dd 0
%initmemdone 	dd 0
ex_info				dd 0  							; holds ebp for accessing EXCEPTION_RECORD and CONTEXT

align	8
%pdeString db "XBLite xbl.dll"


; #################
; #####  END  #####
; #################
