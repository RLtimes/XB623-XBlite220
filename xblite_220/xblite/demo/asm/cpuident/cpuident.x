'
'
' ####################
' #####  PROLOG  #####
' ####################
'
' ASM demo to show the use of CPUID
' instruction to determine the vender,
' family and model of the CPU currently
' installed.
'
PROGRAM	"cpuident"
VERSION	"0.0003"	' modified 16 Oct 05 for goasm
CONSOLE
'
	IMPORT	"xst"
	IMPORT  "kernel32"
	IMPORT  "xsx"
'
DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  WhatCPU (@id$, @cpuFamily, @model, @intelBrandID)
'
'
' ######################
' #####  Entry ()  #####
' ######################
'
'
FUNCTION  Entry ()

	PRINT " ***** CPU Identification *****"
	PRINT

'test original function
	PRINT " ***** WhatCPU() *****"
	cpu = WhatCPU (@id$, @cpuFamily, @model, @intelBrandID)
	PRINT "CPU            : "; cpu
	PRINT "ID String      : "; id$
	PRINT "CPU Family     : "; cpuFamily
	PRINT "CPU Model      : "; model
	PRINT "Intel Brand ID : "; intelBrandID
	PRINT
	
'test XstGetCPUName in Xsx library
	PRINT "***** XstGetCPUName() *****"
	id$ = ""
	cpuFamily  = 0
	model = 0
	intelBrandID = 0
	cpu = XstGetCPUName (@id$, @cpuFamily, @model, @intelBrandID)
	PRINT "CPU            : "; cpu
	PRINT "ID String      : "; id$
	PRINT "CPU Family     : "; cpuFamily
	PRINT "CPU Model      : "; model
	PRINT "Intel Brand ID : "; intelBrandID
	PRINT

	a$ = INLINE$ ("Press ENTER to exit >")

END FUNCTION
'
'
' ##########################
' #####  WhatCPU ()  #####
' ##########################

' for info on 32-bit CPU architecture, see
' http://www.sandpile.org/ia32/cpuid.htm

' When the input in EAX is 0, the cpuid instruction returns
' the maximum supported standard level in EAX, and the
' vendor ID string in EBX-EDX-ECX.
'==========================================
'  ID STRING        Vendor
' GenuineIntel  	Intel processor
' UMC UMC UMC  		UMC processor
' AuthenticAMD  	AMD processor
' CyrixInstead  	Cyrix processor
' NexGenDriven  	NexGen processor
' CentaurHauls  	Centaur processor
' RiseRiseRise  	Rise Technology processor
' GenuineTMx86  	Transmeta processor

' When the input to CPUID is 1, then EAX returns the
' processor type/family/stepping. EBX returns the
' brand ID.

' ***** EAX=xxxx_xxxxh *****

'  ***** the extended processor family is encoded in bits 27..20 *****
' 00h  Intel P4
' 01h  Intel McKinley (IA-64)

' ***** the extended processor model is encoded in bits 19..16 *****
' ***** the family is encoded in bits 11..8 *****
' 4		most 80486s
' 		AMD 5x86
' 		Cyrix 5x86
' 5 	Intel P5, P54C, P55C, P24T
' 		NexGen Nx586
' 		Cyrix M1
' 		AMD K5, K6
' 		Centaur C6, C2, C3
' 		Rise mP6
' 		Transmeta Crusoe TM3x00 and TM5x00
' 6 	Intel P6, P2, P3
' 		AMD K7
' 		Cyrix M2, VIA Cyrix III
' 7 	Intel Merced (IA-64) F refer to extended family

' ***** the model is encoded in bits 7..4 *****
' Intel  F
' 			refer to extended model
' Intel 80486
' 	0  i80486DX-25/33
' 	1  i80486DX-50
' 	2  i80486SX
' 	3  i80486DX2
' 	4  i80486SL
' 	5  i80486SX2
' 	7  i80486DX2WB
' 	8  i80486DX4
' 	9  i80486DX4WB
' UMC 80486
' 	1  U5D
' 	2  U5S
' AMD 80486
' 	3  80486DX2
' 	7  80486DX2WB
' 	8  80486DX4
' 	9  80486DX4WB
' 	E  5x86
' 	F  5x86WB
' Cyrix 5x86
' 	9  5x86
' Cyrix MediaGX
' 	4  GX, GXm
' Intel P5-core
' 	0  P5 A-step
' 	1  P5
' 	2  P54C
' 	3  P24T Overdrive
' 	4  P55C
' 	7  P54C
' 	8  P55C (0.25µm)
' NexGen Nx586
' 	0  Nx586 or Nx586FPU (only later ones)
' Cyrix M1
' 	2  6x86
' Cyrix M2
' 	0  6x86MX
' VIA Cyrix III
' 	5  Cyrix M2 core
' 	6  WinChip C5A core
' 	7  WinChip C5B core (if stepping = 0..7)
' 	7  WinChip C5C core (if stepping = 8..F)
' AMD K5
'		0  SSA5 (PR75, PR90, PR100)
' 	1  5k86 (PR120, PR133)
' 	2  5k86 (PR166)
' 	3  5k86 (PR200)
' AMD K6
' 	6  K6 (0.30 µm)
' 	7  K6 (0.25 µm)
' 	8  K6-2
' 	9  K6-III
' 	D  K6-2+ or K6-III+ (0.18 µm)
' Centaur
' 	4  C6
' 	8  C2
' 	9  C3
' Rise
' 	0  mP6 (0.25 µm)
' 	2  mP6 (0.18 µm)
' Transmeta
' 	4  Crusoe TM3x00 and TM5x00
' Intel P6-core
' 	0  P6 A-step
' 	1  P6
' 	3  P2 (0.28 µm)
' 	5  P2 (0.25 µm)
' 	6  P2 with on-die L2 cache
' 	7  P3 (0.25 µm)
' 	8  P3 (0.18 µm) with 256 KB on-die L2 cache
' 	A  P3 (0.18 µm) with 1 or 2 MB on-die L2 cache
' 	B  P3 (0.13 µm) with 256 or 512 KB on-die L2 cache
' AMD K7
' 	1  Athlon (0.25 µm)
' 	2  Athlon (0.18 µm)
' 	3  Duron (SF core)
' 	4  Athlon (TB core)
' 	6  Athlon (PM core)
' 	7  Duron (MG core)
' Intel P4-core
' 	0  P4 (0.18 µm)
' 	1  P4 (0.18 µm)
' 	2  P4 (0.13 µm)

' ***** the stepping is encoded in bits 3..0 *****
'
'  ***** EBX=aall_ccbbh *****

' the brand ID is encoded in bits 7..0.
' 00h  not supported
' 01h  0.18 µm Intel Celeron
' 02h  0.18 µm Intel Pentium III
' 03h  0.18 µm Intel Pentium III Xeon
' 03h  0.13 µm Intel Celeron
' 04h  0.13 µm Intel Pentium III
' 07h  0.13 µm Intel Celeron mobile
' 06h  0.13 µm Intel Pentium III mobile
' 08h  0.18 µm Intel Pentium 4
' 0Eh  0.18 µm Intel Pentium 4 Xeon
' 09h  0.13 µm Intel Pentium 4
' 0Ah  0.13 µm Intel Pentium 4
' 0Bh  0.13 µm Intel Pentium 4 Xeon

' WhatCPU () returns one of the following values:
' 386- if an 80386 microprocessor
' 486- if an 80486 or other post-386 CPU that does not have a CPUID instruction
' x86- CPU has CPUID instruction, could be 486, 586, 686...
' id$ - CPU String ID
' cpuFamily - CPU family name
' model - CPU model number
' intelBrandID - Intel Brand ID number

' Note: this asm code has only been tested on a Pentium 586 so I
' don't know if it works correctly on 386/486 CPUs.
' ASM code was borrowed from http://7gods.sk/coding_sysparm.html

FUNCTION  WhatCPU (@id$, @cpuFamily, @model, @intelBrandID)

	ULONG a, b, c, d, e, f
	a = 0
	b = 0
	c = 0
	d = 0
	e = 0
	f = 0
	ret = 0

' i386 code
ASM		mov 							ebx,386
ASM		pushfd
ASM		pop 							eax
ASM		mov 							ecx,eax
ASM		mov 							edx,eax
ASM		xor 							eax,0x40000 	; 386 wont change EFALGS bit 34
ASM		push 							eax
ASM		popfd
ASM		pushfd
ASM		pop 							eax
ASM		xor 							eax,ecx
ASM		je 				>				CPUexit

' i486 code
ASM		add 							ebx,100
ASM		mov 							eax,edx
ASM		mov 							ecx,eax
ASM		xor 							eax,0x200000 	; most 486 wont change EFALGS bit 37
ASM		push 							eax 					; (that is, wont support CPUID)
ASM		popfd
ASM		pushfd
ASM		pop 							eax
ASM		xor 							eax,ecx
ASM		je 				>				CPUexit

' pentium 586+ specific code
ASM		mov								eax,0					; set cpuid argument to 0
ASM		cpuid		  											; CPUID instruction

ASM		mov								[ebp-24],ebx 	; save ebx in a
ASM		mov								[ebp-28],edx 	; save edx in b
ASM		mov								[ebp-32],ecx 	; save ecx in c

ASM		mov								eax, 1				; set eax to 1
ASM		cpuid		  											; CPUID instruction

ASM		mov								[ebp-40],eax 	; save eax in e
ASM		mov								[ebp-44],ebx 	; save eax in f

ASM		mov								eax, 1				; set eax to 1
ASM		cpuid		  											; CPUID instruction

ASM		xor								ebx,ebx
ASM		mov								bl,ah					; put result into ebx
ASM		mov								eax,100				; set eax to 100
ASM		mul								ebx						; mult ebx by 100
ASM		add								eax,86				; add 86
ASM		mov								ebx,eax

ASM   CPUexit:
ASM		mov								[ebp-48],ebx	; move result into ret

' convert a, b, c into id$
	id$ = CHR$(a{8,0}) + CHR$(a{8,8}) + CHR$(a{8,16}) + CHR$(a{8,24})
	id$ = id$ + CHR$(b{8,0}) + CHR$(b{8,8}) + CHR$(b{8,16}) + CHR$(b{8,24})
	id$ = id$ + CHR$(c{8,0}) + CHR$(c{8,8}) + CHR$(c{8,16}) + CHR$(c{8,24})

' convert e into cpuFamily
	cpuFamily = e{4,8}

' convert e into model
	model = e{4,4}

' convert f into intelBrandID
	intelBrandID = f{8,0}

ASM		mov								eax,[ebp-48]	; move ret to EAX

ASM		jmp								end.WhatCPU.cpuident			; jump to end of function

END FUNCTION
END PROGRAM
