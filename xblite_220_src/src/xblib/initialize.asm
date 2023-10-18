code section
align	8

; ###########################
; #####  initialize ()  #####
; ###########################

initialize:
_initialize:
push	ebp
mov	ebp,esp

; establish ##WIN32S (internal use)

; NOTE: ##WIN32S is true for Win32s/Windows95/Windows98 and false for WindowsNT
; This wackiness is caused by the fact only Windows 3.1 and WindowsNT existed
; when the following was written.  Duhhhhh for the idiots at McSoft again.
; Tried to modify this to call XxxGetVersion(), but that nukes because the stupid
; McSoft GetVersionEx() function requires memory allocation, which cannot yet be
; performed since we are calling this function here partly to decide how to
; setup memory allocation (different in Windows vs WindowsNT).  Sigh...

mov D[_##WIN32S], 0								; 0 = WindowsNT
call	_GetVersion@0
bt	eax,31												; bit 31 = 0 for WindowsNT, or 1 for Windows/Win32s
jnc	> alloc
mov	D[_##WIN32S], -1							; -1 = Win32s / Windows3.1
alloc:

; get space for first 4MB of dynamic memory and set up table and 1st header

sub	esp, 16												; create arg frame
mov D[esp+ 0], 0x20000000					; base address of _##DYNO area
mov D[esp+ 4], 0x20000000					; reserve 512MB
mov D[esp+ 8], 0x2000							; MEM_RESERVE
mov D[esp+12], 0x0001							; PAGE_NOACCESS
call	_VirtualAlloc@16						; allocate memory
or	eax,eax												; 3.1 fails wrt base address
jnz	> allocOK

; Win32s address space is 0x80000000+

mov	eax,ADDR %edata								; Put DYNO at even address above DATA
lea	eax,[eax+0x10000000]
and	eax,0xF0000000
sub	esp, 16												; create arg frame
mov D[esp+ 0], eax								; base address of _##DYNO area
mov D[esp+ 4], 0xC00000						; reserve 12MB	' works
mov D[esp+ 4], 0x1000000					; reserve 16MB	' try on 1995 Feb 19
mov D[esp+ 8], 0x2000							; MEM_RESERVE
mov D[esp+12], 0x0001							; PAGE_NOACCESS
call	_VirtualAlloc@16						; allocate memory
or	eax,eax												; 3.1 fails wrt base address
jnz	> allocOK

; let VirtualAlloc determine DYNO base address

sub	esp, 16												; create arg frame
mov D[esp+ 0], 0									; base address--you decide
mov D[esp+ 4], 0xC00000						; reserve 12MB
mov D[esp+ 8], 0x2000							; MEM_RESERVE
mov D[esp+12], 0x0001							; PAGE_NOACCESS
call	_VirtualAlloc@16						; allocate memory
or	eax,eax												; eax = 0 ???
jnz	> allocOK											; eax = 0 for failure
ret																; *** BOOM ***  Can't allocate memory

; dynamic memory successfully allocated

allocOK:
mov	[_##DYNO0], eax								; base of _##DYNO area
mov	[_##DYNO], eax								; ditto
sub	esp, 16												; create arg frame
mov	eax, [_##DYNO0]								; address of _##DYNO0
mov D[esp+ 0], eax								; address of _##DYNO0
mov D[esp+ 4], 0x400000						; commit 4MB
mov D[esp+ 8], 0x1000							; MEM_COMMIT
mov D[esp+12], 0x0004							; PAGE_READWRITE
call	_VirtualAlloc@16						; allocate memory

mov	eax, [_##DYNO0]								; base of _##DYNO area
add	eax, 0x400000									; after _##DYNO area
mov	[_##DYNOZ], eax								; after committed area
sub	eax, 16												; eax = last header addr
mov	[_##DYNOX], eax

mov D[%initialized], -1        		; dynamic memory has been initialized


; Build low header and high header to allocate stretchy space.
; To start off, all of dynamic memory is in one big free block.

start_headers:
mov	eax, [_##DYNO]								; eax -> first dyno header
xor	ecx, ecx											; ready to zero some stuff later
mov	[%pointers+0x40], eax					; first (and only) dyno block is a big one
mov	ebx, [_##DYNOX]								; ebx -> last dyno header
mov	edx, ebx											; edx -> last dyno header
sub	ebx, eax											; ebx = size of the one block
mov	[eax+0], ebx									; addr-uplink(first) = size(first)
mov	[eax+4], ecx									; addr-downlink(first) = 0 (none)
mov	[eax+8], ecx									; size-uplink(first) = 0 (none)
mov	[eax+12], ecx									; size-downlink(first) = 0 (none)
mov	[edx+0], ecx									; addr-uplink(last) = 0
mov	[edx+4], ebx									; addr-downlink(last) = size(first)
mov	[edx+8], ecx									; size-uplink(last) = 0 (none)
mov	[edx+12], ecx									; size-uplink(last) = 0 (none)  xxx add 11/04/93
or	ebx,0x80000000								; mark allocated xxx add 11/04/93
mov	[edx+4], ebx									; mark allocated xxx add 11/04/93

; allocation routines blow up unless there's a permanent allocated
; memory block at the bottom of the dyno memory area, so make one!

mov	esi,16												; esi = 16 bytes
call	%____calloc									; allocate 16 byte chunk
mov	eax,0													; eax = system/user int
or	eax,0x80130001								; info word = allocated string
mov	[esi-4],eax										; save info word
mov D	[esi-8],14									; save length

mov	edi,esi												; destination
mov	esi,ADDR %pdeString						; source
mov	ecx,14												; count
cld																; up
rep																; repeat
movsb															; move bytes

mov D[%initmemdone], -1        		; dynamic memory has been initialized
mov D	[_##TABSAT], 2							; Default tab setting is 2

mov	esp, ebp											; standard function exit
pop	ebp														; standard function exit
ret

