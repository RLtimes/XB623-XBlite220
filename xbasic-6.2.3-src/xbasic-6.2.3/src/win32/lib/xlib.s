;
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
;
; PROGRAM "xlib"	' fake PROGRAM statement - name this library
; VERSION "0.0110"	' fake VERSION statement - keep version updated
;
; Mostly assembly language source code for XBasic language intrinsics
; like ABS(), LEFT$(), MID$(), TRIM$(), etc.
;
;
; This file contains assembly language routines for several purposes, including:
;   1. Startup initialization - XxxMain is called by xinit.s or app at startup
;   2. Error handling - handle "jmp %eeeErrorName" in XBasic source programs
;   3. Dynamic memory management - malloc, calloc, recalloc, free, etc...
;   4. Array management - DimArray, RedimArray, FreeArray
;   5. Intrinsic functions - ABS(), BIN$(), CHR$(), etc...
;   6. General support routines, especially for program development environment
;
; To create the program development environment, this file is assembled into
; object file "xlib.o" which is linked to, and becomes part of, the program
; development environment - aka PDE.  The global variables in xlib.s are
; therefore in the PDE executable file, and are read in by the PDE when it
; starts up.  The addresses of all xlib.s routines are therefore available
; to the compiler and calls to xlib.s routines in user programs are resolved
; without difficulty.
;
; When standalone XBasic programs are created by WindowsNT tools, they
; are linked to "xlib.dll", a DLL version of xlib.  Program references
; to xlib.s routines are thus resolved by the Windows program loader.
;
; External variables are not shared in the same manner in both cases.
; External variables are shared by all programs linked into a single
; executable (.DLL or .EXE).  External variables in user programs are
; not shared with .DLL libraries.  So function libraries developed in
; the PDE should not contain external variables - at least not external
; variables meant to be shared by programs or other function libraries
; that use the .DLL as a .DLL.  External variables are only shared with
; programs linked into a single .EXE or .DLL.
;
;
; ******************************
; *****  SYSTEM EXTERNALS  *****  values persist on user task run/kill/run/kill...
; ******************************
;
.comm	_##CODE0,		4	; Xit code page base (first page)
.comm	_##CODE,		4	; Xit code starts here
.comm	_##CODEX,		4	; Xit code ends here (UNIX _etext)
.comm	_##CODEZ,		4	; Xit code break address (last page)
.comm	_##UCODE0,		4	; User code page base (first page)
.comm	_##UCODE,		4	; User code starts here
.comm	_##UCODEX,		4	; User code ends here
.comm	_##UCODEZ,		4	; User code break address (last page)
.comm	_##DATA0,		4	; Data page base (first page)
.comm	_##DATA,		4	; Data starts
.comm	_##DATAX,		4	; Data ends here
.comm	_##DATAZ,		4	; Data page ends here (last page)
.comm	_##BSS0,		4	; BSS page base (first page)
.comm	_##BSS,			4	; BSS starts here
.comm	_##BSSX,		4	; BSS ends here
.comm	_##BSSZ,		4	; BSS page ends here (last page)
.comm	_##DYNO0,		4	; Dyno page base
.comm	_##DYNO,		4	; Dyno headers start here
.comm	_##DYNOX,		4	; Dyno headers end here
.comm	_##DYNOZ,		4	; Dyno page ends here
.comm	_##UDYNO0,		4	; Dyno page base
.comm	_##UDYNO,		4	; Dyno headers start here
.comm	_##UDYNOX,		4	; Dyno headers end here
.comm	_##UDYNOZ,		4	; Dyno page ends here
.comm	_##STACK0,		4	; Stack page base (low page)
.comm	_##STACK,		4	; Stack ???
.comm	_##STACKX,		4	; Stack ???
.comm	_##STACKZ,		4	; Stack entry page end (high page)
.comm	_##GLOBAL0,		4	; External block starts here
.comm	_##GLOBAL,		4	; External block after system
.comm	_##GLOBALX,		4	; External block next available
.comm	_##GLOBALZ,		4	; External block after
.comm	_##ARGC,		4	; ##ARGC	(# elements in ##ARGV$[])
.comm	_%##ARGV$,		4	; ##ARGV$[]	(argument strings)
.comm	_%##ENVP$,		4	; ##ENVP$[]	(environment strings)
.comm	_##ERROR,		4	; ##ERROR	(XBASIC error number)
.comm	_%##EXCEPTION,		4	; ##EXCEPTION	(XBASIC exception number)
.comm	_%##OSERROR$,		4	; ##OSERROR$[]	(operating-system error strings)
.comm	_%##SYSTEM,		4	; ##SYSTEM[]	(XBASIC system array)
.comm	_%##USER,		4	; ##USER[]	(XBASIC user array)
.comm	_%##SYSREG,		4	; ##SYSREG[]	(Xit machine registers)
.comm	_%##REG,		4	; ##REG[]	(machine registers)
.comm	_%##XCODE,		4	; ##XCODE[]	(user code in shared memory)
.comm	_##TABSAT,		4	; ##TABSAT	(tabs set every n columns)
.comm	_##WHOMASK,		4	; ##WHOMASK	(allocation owner, info word)
.comm	_##WALKBASE,		4	; ##WALKBASE	(88k: must change compiler if these
.comm	_##XWALKBASE,		4	; ##XWALKBASE	  are moved from 1A0/1A4/1A8)
.comm	_##WALKOFFSET,		4	; ##WALKOFFSET
.comm	_##XWALKOFFSET,		4	; ##XWALKOFFSET
.comm	_##SOFTBREAK,		4	; ##SOFTBREAK		(all XBasic SYSTEMCALLs)
.comm	_##USERRUNNING,		4	; ##USERRUNNING
.comm	_##SIGNALACTIVE,	4	; ##SIGNALACTIVE	(Xit)
.comm	_##BEGINALLOCODE,	4	; ##BEGINALLOCODE	(XitMain(), xlib0.s)
.comm	_##ENDALLOCODE,		4	; ##ENDALLOCODE		(XitMain(), xliba.s)
.comm	_%##ALARMREG,		4	; ##ALARMREG[]		(alarm registers, Xit FRAMES)
.comm	_##ALARMWALKER,		4	; ##ALARMWALKER		(alarm walkoffset, Xit FRAMES)
.comm	_##ALARMLOOP,		4	; ##ALARMLOOP		(alarm loop addr, Xit FRAMES)
.comm	_##ALARMTIME,		4	; ##ALARMTIME		(alarm time interval)
.comm	_##ALARMBUSY,		4	; ##ALARMBUSY
.comm	_##LOCKOUT,		4	; ##LOCKOUT
.comm	_##STANDALONE,		4	; ##STANDALONE
.comm	_##CPU,			4	; ##CPU
.comm	_##WIN32S,		4	; ##WIN32S
.comm	_##HINSTANCE,		4	; ##HINSTANCE - hInstance active
.comm	_##HINSTANCEDLL,	4	; ##HINSTANCEDLL - hInstance of .dll
.comm	_##HINSTANCEEXE,	4	; ##HINSTANCEEXE - hInstance of .exe
.comm	_##HINSTANCESTART,	4	; ##HINSTANCESTART - hInstance at .exe startup
.comm	_##USERWAITING,		4	; ##USERWAITING
.comm	_##TRAPVECTOR,		4	; ##TRAPVECTOR
.comm	_##ENTERED,		4	; ##ENTERED
.comm	_##START,		4	; ##START
.comm	_##MAIN,		4	; ##MAIN
.comm	_##APP,			4	; ##APP
.comm	_##WHERE,		4	; ##WHERE
.comm	_##CONGRID,		4	; ##CONGRID
.comm	_##EXCEPTION,		4	; ##EXCEPTION
.comm	_##OSEXCEPTION,		4	; ##OSEXCEPTION
.comm	_##BLOWBACK,		4	; ##BLOWBACK
.comm	_##EXTRA0,		4	; ##EXTRA0
.comm	_##EXTRA1,		4	; ##EXTRA1
.comm	_##EXTRA2,		4	; ##EXTRA2
.comm	_##EXTRA3,		4	; ##EXTRA3
.comm	_##EXTRA4,		4	; ##EXTRA4
;
.comm	_XxxExternala,		16	;
;
.comm	_XxxExternals,		65536	; holds external and shared variables
					; of programs compiled into memory by
					; the program development environment.
.comm	_XxxExternalz,		16	;
.comm	_errno,						4		;
;
;
;
; #######################
; #####  CONSTANTS  #####  assembly language constants for this file
; #######################
;
.def	SECTION_QUERY,		0x00000001
.def	SECTION_MAP_WRITE,	0x00000002
.def	SECTION_MAP_READ,	0x00000004
.def	SECTION_MAP_EXECUTE,	0x00000008
.def	SECTION_EXTEND_SIZE,	0x00000010
;
.def	PAGE_NOACCESS,		0x00000001
.def	PAGE_READONLY,		0x00000002
.def	PAGE_READWRITE,		0x00000004
.def	MEM_COMMIT,		0x00001000
.def	MEM_RESERVE,		0x00002000
.def	MEM_DECOMMIT,		0x00004000
.def	MEM_RELEASE,		0x00008000
.def	MEM_FREE,		0x00010000
.def	MEM_PRIVATE,		0x00020000
;
;
.text
;
; #######################
; #####  xitinit.s  #####  Initialization code and miscellaneous stuff
; #######################
;
.globl	_XxxMain
.globl	_XxxG@0
.globl	_XxxGuessWho@0
.globl	_XxxGetEbpEsp@8
.globl	_XxxSetEbpEsp@8
.globl	_XxxGetFrameAddr@0
.globl	_XxxSetFrameAddr@4
.globl	_XxxGetExceptions@8
.globl	_XxxSetExceptions@8
.globl	_XxxGetFPEnvironment@4
.globl	_XxxClearFPException@0
.globl	_XxxCheckMessages@0
.globl	_XxxRuntimeError
.globl	_XxxRuntimeError2
.globl	_XxxStartApplication@0
.globl	_XxxFPUstatus@0
.globl	_XxxEBPandESP@0
.globl	_XxxTerminate@0
.globl	_XxxFCLEX@0
.globl	_XxxFINIT@0
.globl	_XxxFSTCW@0
.globl	_XxxFSTSW@0
.globl	_XxxFLDZ@0
.globl	_XxxFLD1@0
.globl	_XxxFLDPI@0
.globl	_XxxFLDL2E@0
.globl	_XxxFLDL2T@0
.globl	_XxxFLDLG2@0
.globl	_XxxFLDLN2@0
.globl	_XxxF2XM1@8
.globl	_XxxFABS@8
.globl	_XxxFCHS@8
.globl	_XxxFCOS@8
.globl	_XxxFPATAN@16
.globl	_XxxFPREM@16
.globl	_XxxFPREM1@16
.globl	_XxxFPTAN@16
.globl	_XxxFRNDINT@8
.globl	_XxxFSCALE@16
.globl	_XxxFSIN@8
.globl	_XxxFSINCOS@16
.globl	_XxxFSQRT@8
.globl	_XxxFXTRACT@16
.globl	_XxxFYL2X@16
.globl	_XxxFYL2XP1@16
.globl	_SIN@8
.globl	_COS@8
.globl	_TAN@8
.globl	_ATAN@8
.globl	_SQRT@8
.globl	_EXP@8
.globl	_EXPE@8
.globl	_EXP2@8
.globl	_EXP10@8
.globl	_EXPX@16
.globl	_POWER@16
.globl	%_ZeroMemory
.globl	%_eeeErrorNT
.globl	%_eeeAllocation
.globl	%_eeeOverflow
.globl	%_OutOfBounds
.globl	%_NeedNullNode
.globl	%_UnexpectedLowestDim
.globl	%_UnexpectedHigherDim
.globl	_XxxZeroMemory
.globl	_initialize
;
;
; #####################
; #####  xlib0.s  #####  Memory-allocation routines
; #####################
;
.globl	_malloc
.globl	__malloc
.globl	___malloc
.globl	_Xmalloc
.globl	%____malloc
.globl	%_____malloc
.globl	_realloc
.globl	__realloc
.globl	___realloc
.globl	_Xrealloc
.globl	%____realloc
.globl	%_____realloc
.globl	_free
.globl	__free
.globl	___free
.globl	_Xfree
.globl	%____free
.globl	%_____free
.globl	_calloc
.globl	__calloc
.globl	___calloc
.globl	_Xcalloc
.globl	%____calloc
.globl	%_____calloc
.globl	_recalloc
.globl	__recalloc
.globl	___recalloc
.globl	_Xrecalloc
.globl	%____recalloc
;.globl	%_____recalloc
.globl	%_beginAlloCode
;
;
; #####################
; #####  xlib1.s  #####  Clone and concatenate routines
; #####################
;
.globl	%_clone.a0
.globl	%_clone.a1
;
.globl	%_concat.ubyte.a0.eq.a0.plus.a1.vv
.globl	%_concat.ubyte.a0.eq.a0.plus.a1.vs
.globl	%_concat.ubyte.a0.eq.a0.plus.a1.sv
.globl	%_concat.ubyte.a0.eq.a0.plus.a1.ss
.globl	%_concat.ubyte.a0.eq.a1.plus.a0.vv
.globl	%_concat.ubyte.a0.eq.a1.plus.a0.vs
.globl	%_concat.ubyte.a0.eq.a1.plus.a0.sv
.globl	%_concat.ubyte.a0.eq.a1.plus.a0.ss
;
; the following are alternate names for the above
;
.globl	%_concat.string.a0.eq.a0.plus.a1.vv
.globl	%_concat.string.a0.eq.a0.plus.a1.vs
.globl	%_concat.string.a0.eq.a0.plus.a1.sv
.globl	%_concat.string.a0.eq.a0.plus.a1.ss
.globl	%_concat.string.a0.eq.a1.plus.a0.vv
.globl	%_concat.string.a0.eq.a1.plus.a0.vs
.globl	%_concat.string.a0.eq.a1.plus.a0.sv
.globl	%_concat.string.a0.eq.a1.plus.a0.ss
;
;
; #####################
; #####  xliba.s  #####  Low-level array processing routines
; #####################
;
.globl	%_DimArray
.globl	%_FreeArray
.globl	%_RedimArray
.globl	_XxxSwapMemory@12
.globl	%_assignComposite
.globl	%_AssignComposite
.globl	%_assignCompositeString.v	; fill extra bytes with 0x20
.globl	%_assignCompositeString.s	; fill extra bytes with 0x20
.globl	%_assignCompositeStringlet.v	; 0x00 byte is terminator
.globl	%_assignCompositeStringlet.s	; 0x00 byte is terminator
.globl	%_VarargArrays
.globl	%_endAlloCode
;
;
; #####################
; #####  xlibp.s  #####  XstStringToNumber ()
; #####################
;
.globl	_XstStringToNumber@24
;
;
; #####################
; #####  xlibs.s  #####  String and PRINT routines
; #####################
;
.globl	%_space.string
.globl	%_newline.string
;
.globl	%_print.console.newline
.globl	%_print.tab.a0.eq.a0.tab.a1
.globl	%_print.tab.a0.eq.a1.tab.a0
.globl	%_print.tab.a0.eq.a0.tab.a1.ss
.globl	%_print.tab.a0.eq.a1.tab.a0.ss
.globl	%_print.first.spaces.a0
.globl	%_print.tab.first.a0
.globl	%_print.tab.first.a1
;
.globl	%_Print
.globl	%_PrintConsoleNewline
.globl	%_PrintFileNewline
.globl	%_PrintThenFree
.globl	%_PrintWithNewlineThenFree
.globl	%_PrintAppendComma
.globl	%_PrintFirstComma
.globl	%_PrintAppendSpaces
;
.globl	%_string.compare.vv
.globl	%_string.compare.vs
.globl	%_string.compare.sv
.globl	%_string.compare.ss
;
.globl	_XstFindMemoryMatch@20
.globl	%_CompositeStringToString
.globl	%_ByteMakeCopy
.globl	%_Read
.globl	%_Write
.globl	%_ReadArray
.globl	%_WriteArray
.globl	%_ReadString
.globl	%_WriteString
;
.globl	%_close
.globl	%_eof
.globl	%_pof
.globl	%_lof
.globl	%_quit
.globl	%_infile_d
.globl	%_inline_d.s
.globl	%_inline_d.v
.globl	%_open.s
.globl	%_open.v
.globl	%_seek
.globl	%_shell.s
.globl	%_shell.v
;
;
; ######################
; #####  xlibnn.s  #####  numeric-to-numeric conversions and intrinsics
; ######################
;
.globl	%_cv.slong.to.sbyte
.globl	%_cv.slong.to.ubyte
.globl	%_cv.slong.to.sshort
.globl	%_cv.slong.to.ushort
.globl	%_cv.slong.to.slong
.globl	%_cv.slong.to.ulong
.globl	%_cv.slong.to.xlong
.globl	%_cv.slong.to.giant
.globl	%_cv.slong.to.single
.globl	%_cv.slong.to.double
;
.globl	%_cv.ulong.to.sbyte
.globl	%_cv.ulong.to.ubyte
.globl	%_cv.ulong.to.sshort
.globl	%_cv.ulong.to.ushort
.globl	%_cv.ulong.to.slong
.globl	%_cv.ulong.to.ulong
.globl	%_cv.ulong.to.xlong
.globl	%_cv.ulong.to.giant
.globl	%_cv.ulong.to.single
.globl	%_cv.ulong.to.double
;
.globl	%_cv.xlong.to.sbyte
.globl	%_cv.xlong.to.ubyte
.globl	%_cv.xlong.to.sshort
.globl	%_cv.xlong.to.ushort
.globl	%_cv.xlong.to.slong
.globl	%_cv.xlong.to.ulong
.globl	%_cv.xlong.to.xlong
.globl	%_cv.xlong.to.giant
.globl	%_cv.xlong.to.single
.globl	%_cv.xlong.to.double
;
.globl	%_cv.giant.to.sbyte
.globl	%_cv.giant.to.ubyte
.globl	%_cv.giant.to.sshort
.globl	%_cv.giant.to.ushort
.globl	%_cv.giant.to.slong
.globl	%_cv.giant.to.ulong
.globl	%_cv.giant.to.xlong
.globl	%_cv.giant.to.giant
.globl	%_cv.giant.to.single
.globl	%_cv.giant.to.double
;
.globl	%_cv.single.to.sbyte
.globl	%_cv.single.to.ubyte
.globl	%_cv.single.to.sshort
.globl	%_cv.single.to.ushort
.globl	%_cv.single.to.slong
.globl	%_cv.single.to.ulong
.globl	%_cv.single.to.xlong
.globl	%_cv.single.to.giant
.globl	%_cv.single.to.single
.globl	%_cv.single.to.double
;
.globl	%_cv.double.to.sbyte
.globl	%_cv.double.to.ubyte
.globl	%_cv.double.to.sshort
.globl	%_cv.double.to.ushort
.globl	%_cv.double.to.slong
.globl	%_cv.double.to.ulong
.globl	%_cv.double.to.xlong
.globl	%_cv.double.to.giant
.globl	%_cv.double.to.single
.globl	%_cv.double.to.double
;
.globl	%_cv.giant.to.single
.globl	%_cv.giant.to.double
.globl	%_cv.single.to.giant
.globl	%_cv.double.to.giant
;
.globl	%_cv.xlong.to.subaddr
.globl	%_cv.xlong.to.goaddr
.globl	%_cv.xlong.to.funcaddr
;
.globl	%_add.GIANT
.globl	%_sub.GIANT
.globl	%_mul.GIANT
.globl	%_div.GIANT
.globl	%_mod.GIANT
;
.globl	%_lshift.giant
.globl	%_ushift.giant
.globl	%_rshift.giant
.globl	%_dshift.giant
;
.globl	%_high0
.globl	%_high1
.globl	%_high0.giant
.globl	%_high1.giant
;
.globl	%_abs.xlong
.globl	%_abs.slong
.globl	%_abs.ulong
.globl	%_abs.giant
.globl	%_abs.single
.globl	%_abs.double
;
.globl	%_sgn.xlong
.globl	%_sgn.slong
.globl	%_sgn.ulong
.globl	%_sgn.giant
.globl	%_sgn.single
.globl	%_sgn.double
;
.globl	%_sign.xlong
.globl	%_sign.slong
.globl	%_sign.ulong
.globl	%_sign.giant
.globl	%_sign.single
.globl	%_sign.double
;
.globl	%_int.single
.globl	%_int.double
.globl	%_fix.single
.globl	%_fix.double
;
.globl	%_MAX.slong
.globl	%_MAX.ulong
.globl	%_MAX.xlong
.globl	%_MAX.single
.globl	%_MAX.double
.globl	%_MIN.slong
.globl	%_MIN.ulong
.globl	%_MIN.xlong
.globl	%_MIN.single
.globl	%_MIN.double
;
.globl	%_add.SCOMPLEX
.globl	%_sub.SCOMPLEX
.globl	%_mul.SCOMPLEX
.globl	%_div.SCOMPLEX
.globl	%_add.DCOMPLEX
.globl	%_sub.DCOMPLEX
.globl	%_mul.DCOMPLEX
.globl	%_div.DCOMPLEX
;
.globl	%_power.slong
.globl	%_rpower.slong
.globl	%_power.ulong
.globl	%_rpower.ulong
.globl	%_power.xlong
.globl	%_rpower.xlong
.globl	%_power.giant
.globl	%_rpower.giant
.globl	%_power.single
.globl	%_rpower.single
.globl	%_power.double
.globl	%_rpower.double
;
.globl	%_extu.2arg
.globl	%_extu.3arg
.globl	%_ext.2arg
.globl	%_ext.3arg
.globl	%_set.2arg
.globl	%_set.3arg
.globl	%_clr.2arg
.globl	%_clr.3arg
.globl	%_make.2arg
.globl	%_make.3arg
;
.globl	%_error
;
;
; ######################
; #####  xlibns.s  #####  intrinsics that accept a string and return a number
; ######################
;
.globl	%_len.v
.globl	%_len.s
.globl	%_size.v
.globl	%_size.s

.globl	%_csize.v
.globl	%_csize.s

.globl	%_asc.v
.globl	%_asc.s

.globl	%_inchr.vv
.globl	%_inchr.sv
.globl	%_inchr.vs
.globl	%_inchr.ss
.globl	%_inchri.vv
.globl	%_inchri.sv
.globl	%_inchri.vs
.globl	%_inchri.ss

.globl	%_rinchr.vv
.globl	%_rinchr.sv
.globl	%_rinchr.vs
.globl	%_rinchr.ss
.globl	%_rinchri.vv
.globl	%_rinchri.sv
.globl	%_rinchri.vs
.globl	%_rinchri.ss

.globl	%_instr.vv
.globl	%_instr.sv
.globl	%_instr.vs
.globl	%_instr.ss
.globl	%_instri.vv
.globl	%_instri.sv
.globl	%_instri.vs
.globl	%_instri.ss

.globl	%_rinstr.vv
.globl	%_rinstr.sv
.globl	%_rinstr.vs
.globl	%_rinstr.ss
.globl	%_rinstri.vv
.globl	%_rinstri.sv
.globl	%_rinstri.vs
.globl	%_rinstri.ss

.globl	%_cv.string.to.sbyte.v
.globl	%_cv.string.to.sbyte.s
.globl	%_cv.string.to.ubyte.v
.globl	%_cv.string.to.ubyte.s
.globl	%_cv.string.to.sshort.v
.globl	%_cv.string.to.sshort.s
.globl	%_cv.string.to.ushort.v
.globl	%_cv.string.to.ushort.s
.globl	%_cv.string.to.slong.v
.globl	%_cv.string.to.slong.s
.globl	%_cv.string.to.ulong.v
.globl	%_cv.string.to.ulong.s
.globl	%_cv.string.to.xlong.v
.globl	%_cv.string.to.xlong.s
.globl	%_cv.string.to.giant.v
.globl	%_cv.string.to.giant.s
.globl	%_cv.string.to.single.v
.globl	%_cv.string.to.single.s
.globl	%_cv.string.to.double.v
.globl	%_cv.string.to.double.s
;
;
; ######################
; #####  xlibsn.s  #####  intrinsics that take numbers and return strings
; ######################
;
.globl	%_chr.d
.globl	%_bin.d
.globl	%_binb.d
.globl	%_bin.d.giant
.globl	%_binb.d.giant
.globl	%_hex.d
.globl	%_hexx.d
.globl	%_hex.d.giant
.globl	%_hexx.d.giant
.globl	%_oct.d
.globl	%_octo.d
.globl	%_oct.d.giant
.globl	%_octo.d.giant
.globl	%_null.d
.globl	%_space.d
.globl	%_cstring.d
.globl	%_error.d
;
.globl	%_signed.d.slong
.globl	%_signed.d.ulong
.globl	%_signed.d.xlong
.globl	%_signed.d.goaddr
.globl	%_signed.d.subaddr
.globl	%_signed.d.funcaddr
.globl	%_signed.d.giant
.globl	%_signed.d.single			; LOOSE END: write in XBASIC
.globl	%_signed.d.double			; LOOSE END: write in XBASIC
;
.globl	%_str.d.slong
.globl	%_str.d.ulong
.globl	%_str.d.xlong
.globl	%_str.d.goaddr
.globl	%_str.d.subaddr
.globl	%_str.d.funcaddr
.globl	%_str.d.giant
.globl	%_str.d.single				; LOOSE END: write in XBASIC
.globl	%_str.d.double				; LOOSE END: write in XBASIC
;
.globl	%_string.slong
.globl	%_string.ulong
.globl	%_string.xlong
.globl	%_string.goaddr
.globl	%_string.subaddr
.globl	%_string.funcaddr
.globl	%_string.giant
.globl	%_string.single				; LOOSE END: write in XBASIC
.globl	%_string.double				; LOOSE END: write in XBASIC
;
.globl	%_string.d.slong
.globl	%_string.d.ulong
.globl	%_string.d.xlong
.globl	%_string.d.goaddr
.globl	%_string.d.subaddr
.globl	%_string.d.funcaddr
.globl	%_string.d.giant
.globl	%_string.d.single			; LOOSE END: write in XBASIC
.globl	%_string.d.double			; LOOSE END: write in XBASIC
;
;
; ######################
; #####  xlibss.s  #####  intrinsics that take strings and return strings
; ######################
;
.globl	%_csize.d.v
.globl	%_csize.d.s
;
.globl	%_lcase.d.s
.globl	%_lcase.d.v
.globl	%_ucase.d.s
.globl	%_ucase.d.v
;
.globl	%_rjust.d.s
.globl	%_rjust.d.v
.globl	%_ljust.d.s
.globl	%_ljust.d.v
.globl	%_cjust.d.s
.globl	%_cjust.d.v
;
.globl	%_rclip.d.s
.globl	%_rclip.d.v
.globl	%_lclip.d.s
.globl	%_lclip.d.v
;
.globl	%_ltrim.d.v
.globl	%_ltrim.d.s
.globl	%_rtrim.d.v
.globl	%_rtrim.d.s
.globl	%_trim.d.v
.globl	%_trim.d.s
;
.globl	%_left.d.v
.globl	%_left.d.s
.globl	%_right.d.v
.globl	%_right.d.s
.globl	%_mid.d.v
.globl	%_mid.d.s
;
.globl	%_stuff.d.vv
.globl	%_stuff.d.vs
.globl	%_stuff.d.sv
.globl	%_stuff.d.ss
;
.globl	%_uctolc
.globl	%_lctouc
;
;
;
;
; ############################################
; ############################################
; #####  CODE  #####  CODE  #####  CODE  #####
; ############################################
; ############################################
;
;
.text
.align	8
;
; #######################
; #####  xitinit.s  #####  Initialization routines
; #######################  Miscellaneous routines
;
;
; ########################  When .EXEs start up, xstart.s passes
; #####  XxxMain ()  #####  important arguments here to XxxMain().
; ########################  Offsets are after first two opcodes.
;
; ebp + 36 = arg7 = reserved
; ebp + 32 = arg6 = reserved
; ebp + 28 = arg5 = 0x00000000 for PDE : &%_StartApplication for standalone
; ebp + 24 = arg4 = &WinMain()
; ebp + 20 = arg3 = nCmdShow
; ebp + 16 = arg2 = lpszCmdLine
; ebp + 12 = arg1 = hPrevInstance
; ebp +  8 = arg0 = hInstance
;
_XxxMain:
push	ebp			; standard function entry
mov	ebp, esp		; standard function entry
mov	eax, [ebp+8]		; eax = hInstance
mov	[%arg0], eax		; store hInstance
mov	eax, [ebp+12]		; eax = hPrevInstance
mov	[%arg1], eax		; store hPrevInstance
mov	eax, [ebp+16]		; eax = lpszCmdLine    !!! invalid !!!
mov	[%arg2], eax		; store lpszCmdLine    !!! invalid !!!
mov	eax, [ebp+20]		; eax = nCmdShow
mov	[%arg3], eax		; store nCmdShow
mov	eax, [ebp+24]		; eax = &WinMain()
mov	[%arg4], eax		; store &WinMain()
mov	eax, [ebp+28]		; eax = 0x00000000 for PDE : &%_StartApplication
mov	[%arg5], eax		; store 0x00000000 for PDE : &%_StartApplication
mov	eax, [ebp+32]		; eax = arg6 : reserved
mov	[%arg6], eax		; store arg6 : reserved
mov	eax, [ebp+36]		; eax = arg7 : reserved
mov	[%arg7], eax		; store arg7 : reserved
;;
;; test : find out where various memory locations are (look with ntsd)
;;
mov	eax, _##CODE0
mov	eax, _##CODE
mov	eax, _##CODEX
mov	eax, _##CODEZ
mov	eax, _##UCODE0
mov	eax, _##UCODE
mov	eax, _##UCODEX
mov	eax, _##UCODEZ
mov	eax, _##DATA0
mov	eax, _##DATA
mov	eax, _##DATAX
mov	eax, _##DATAZ
mov	eax, _##EXTRA0
mov	eax, _##EXTRA1
mov	eax, _##EXTRA2
mov	eax, _##EXTRA3
mov	eax, _##EXTRA4
mov	eax, %dbase
mov	eax, %etext
mov	eax, %edata
mov	eax, %ebss
mov	edi, _XxxExternala
mov	edi, _XxxExternals
mov	edi, _XxxExternalz
;;
mov	esi, _##CODE0
mov	edi, _##EXTRA4
mov	esi, _XxxExternals
mov	edi, _XxxExternalz
mov	esi, _XxxMain
mov	edi, _XxxEndText
mov	esi, _XxxEndData
mov	edi, _XxxEndBss
;;
;; end of test code
;;
;; Clear memory and set up initialize memory allocation if not yet done.
;; May already be done if malloc() was called by linked in startup code.
;;
mov	esi,[%initoid]		; esi = ##MAIN ???
cmp	esi,_XxxMain		; ##MAIN = &XxxMain() ???
jz	zinited			; yes, memory already initialized
call	initialize		; initialize memory allocation
zinited:
;;
;; initialize fundamental system variables
;;
mov	eax, [%arg0]		;
mov	[_##HINSTANCE], eax	; ##HINSTANCE = hInstance
mov	[_##HINSTANCESTART], eax	; ditto
;;
mov	eax, [%arg4]		;
mov	[_##START], eax		; ##START = &WinMain()
mov	eax, _XxxMain		;
mov	[_##MAIN], eax		; ##MAIN = &XxxMain()
mov	eax, [%arg5]		;
mov	[_##APP], eax		; ##APP = 0x00000000 for PDE
;;				; ##APP = &%_StartApplication for standalone
;;
;; initialize memory area constants
;;
mov	eax,[%arg4]		; _WinMain is lowest code address in .exe
mov	[_##CODE],eax		; _##CODE = _WinMain
and	eax,0xFFFFF000
mov	[_##CODE0],eax		; _##CODE = _WinMain & 0xFFFFF000
mov	eax,%etext
mov	[_##CODEX],eax		; _##CODEX = %etext
add	eax,0x1000
and	eax,0xFFFFF000		; _##CODEZ = (%etext + 0x1000) & 0xFFFFF000
mov	[_##CODEZ],eax
mov	eax,%ebss		; ebss is assumed to be lowest data address (NT!!!)
mov	[_##BSS],eax		; _##BSS = %ebss
and	eax,0xFFFFF000
mov	[_##BSS0],eax		; _##BSS0 = %ebss & 0xFFFFF000
mov	eax,%dbase
mov	[_##BSSX],eax		; _##BSSX = %dbase
add	eax,0xFFF
and	eax,0xFFFFF000
mov	[_##BSSZ],eax		; _##BSSZ = (%dbase + 0xFFF) + 0xFFFFF000
mov	eax,%dbase		; dbase is above bss in NT
mov	[_##DATA],eax		; _##DATA = dbase
and	eax,0xFFFFF000
mov	[_##DATA0],eax		; _##DATA0 = dbase & 0xFFFFF000
mov	eax,%edata
mov	[_##DATAX],eax		; _##DATAX = %edata
lea	ebx,[eax+0xFFF]
and	ebx,0xFFFFF000
mov	[_##DATAZ],ebx		; _##DATAZ = (%edata + 0xFFF) & 0xFFFFF000
mov	[_##STACK],esp		; _##STACK = esp
lea	eax,[esp+0x80]
mov	[_##STACKX],esp		; _##STACKX = esp + 0x80
mov	eax,esp
and	eax,0xFFFFF000
mov	[_##STACK0],eax		; _##STACK0 = esp & 0xFFFFF000
lea	eax,[esp+0x1000]
and	eax,0xFFFFF000
mov	[_##STACKZ],eax		; _##STACKZ = (esp + 0x1000) & 0xFFFFF000
;;
;; mov	[_##WHERE], 0x0003	; note where
;; call	_XxxWriteWin32s@0	; write where # to "win32s.bug"
;;
;; initialize math coprocessor
;;
fnclex
call	_XxxEnableFPExceptions@0
;;
;; need to initialize standard library before any IMPORT statements
;; are executed because they would call XxxXstLoadLibrary() and the
;; name of loaded libraries would be lost because of Xst() startup.
;;
call	_Xst@0				; initialize standard library
;;
;; start exception handler
;;
push	0				; push entry argument 2
push	0				; push entry argument 1
push	0				; push entry argument 0
call	_XxxStartExceptionHandler@12	; call xexcept.c
;;
;;
;; *****  program execution complete
;;
mov	esp, ebp	; standard function exit
pop	ebp		; standard function exit
ret	32		; remove 8 entry arguments and return to WinMain()
;
; *****  alternate way to terminate is call exit() in C standard library
;
call	_exit
ret			;exit() should never return
;
;
;
;
; ###########################
; #####  initialize ()  #####
; ###########################
;
; The following initialization function used to be inline, but
; starting with WindowsNT 3.5 the startup code calls malloc()
; before WinMain() or XxxMain() is ever called.  malloc() isn't
; ready for this and the PDE therefore bombs in malloc().
;
; To solve this problem, malloc() now checks _##MAIN for &XxxMain().
; If malloc() finds _##MAIN != &XxxMain() then malloc() calls
; this initialization routine before trying to allocate memory.
;
initialize:
_initialize:
push	ebp
mov	ebp,esp
;;
;; zero shared/external memory
;;
mov	esi, _##CODE0		; esi = shared/external memory - start
mov	edi, _XxxExternalz	; edi = shared/external memory - end
call	%_ZeroMemory		; clear shared/external variable memory
;;
;; establish ##WIN32S (internal use)
;;
;; NOTE: ##WIN32S is true for Win32s/Windows95/Windows98 and false for WindowsNT
;; This wackiness is caused by the fact only Windows 3.1 and WindowsNT existed
;; when the following was written.  Duhhhhh for the idiots at McSoft again.
;; Tried to modify this to call XxxGetVersion(), but that nukes because the stupid
;; McSoft GetVersionEx() function requires memory allocation, which cannot yet be
;; performed since we are calling this function here partly to decide how to
;; setup memory allocation (different in Windows vs WindowsNT).  Sigh...
;;
mov	[_##WIN32S], 0		; 0 = WindowsNT
call	_GetVersion@0
bt	eax,31			; bit 31 = 0 for WindowsNT, or 1 for Windows/Win32s
jnc	short alloc
mov	[_##WIN32S], -1		; -1 = Win32s / Windows3.1
alloc:
;;
;; get space for first 4MB of dynamic memory and set up table and 1st header
;;
sub	esp, 16			; create arg frame
;;
;;mov	[esp+ 0], 0x04000000	; base address of _##DYNO area - old base
;;mov	[esp+ 4], 0x04000000	; reserve 64MB - old limit
;;
mov	[esp+ 0], 0x20000000	; base address of _##DYNO area
mov	[esp+ 4], 0x10000000	; reserve 256MB
mov	[esp+ 8], 0x2000	; MEM_RESERVE
mov	[esp+12], 0x0001	; PAGE_NOACCESS
call	_VirtualAlloc@16	; allocate memory
or	eax,eax			; 3.1 fails wrt base address
jnz	allocOK
;;
;; Win32s address space is 0x80000000+
;;
mov	eax,%edata		; Put DYNO at even address above DATA
lea	eax,[eax+0x10000000]	;
and	eax,0xF0000000		;
sub	esp, 16			; create arg frame
mov	[esp+ 0], eax		; base address of _##DYNO area
mov	[esp+ 4], 0xC00000	; reserve 12MB	' works
mov	[esp+ 4], 0x1000000	; reserve 16MB	' try on 1995 Feb 19
mov	[esp+ 8], 0x2000	; MEM_RESERVE
mov	[esp+12], 0x0001	; PAGE_NOACCESS
call	_VirtualAlloc@16	; allocate memory
or	eax,eax			; 3.1 fails wrt base address
jnz	allocOK
;;
;; mov	[_##WHERE], 0x0007	; note where
;; call	_XxxWriteWin32s@0	; write where # to "win32s.bug"
;;
;; let VirtualAlloc determine DYNO base address
;;
sub	esp, 16			; create arg frame
mov	[esp+ 0], 0		; base address--you decide
mov	[esp+ 4], 0xC00000	; reserve 12MB
mov	[esp+ 8], 0x2000	; MEM_RESERVE
mov	[esp+12], 0x0001	; PAGE_NOACCESS
call	_VirtualAlloc@16	; allocate memory
or	eax,eax			; eax = 0 ???
jnz	allocOK			; eax = 0 for failure
ret				; *** BOOM ***  Can't allocate memory
;
; dynamic memory successfully allocated
;
allocOK:
mov	[_##DYNO0], eax		; base of _##DYNO area
mov	[_##DYNO], eax		; ditto
sub	esp, 16			; create arg frame
mov	eax, [_##DYNO0]		; address of _##DYNO0
mov	[esp+ 0], eax		; address of _##DYNO0
mov	[esp+ 4], 0x400000	; commit 4MB
mov	[esp+ 8], 0x1000	; MEM_COMMIT
mov	[esp+12], 0x0004	; PAGE_READWRITE
call	_VirtualAlloc@16	; allocate memory
;;
mov	eax, [_##DYNO0]		; base of _##DYNO area
add	eax, 0x400000		; after _##DYNO area
mov	[_##DYNOZ], eax		; after committed area
sub	eax, 16			; eax = last header addr
mov	[_##DYNOX], eax		;
;;
;; Build low header and high header to allocate stretchy space.
;; To start off, all of dynamic memory is in one big free block.
;;
start_headers:
mov	eax, [_##DYNO]		;eax -> first dyno header
xor	ecx, ecx		;ready to zero some stuff later
mov	[%pointers+0x40], eax	;first (and only) dyno block is a big one
mov	ebx, [_##DYNOX]		;ebx -> last dyno header
mov	edx, ebx		;edx -> last dyno header
sub	ebx, eax		;ebx = size of the one block
mov	[eax+0], ebx		;addr-uplink(first) = size(first)
mov	[eax+4], ecx		;addr-downlink(first) = 0 (none)
mov	[eax+8], ecx		;size-uplink(first) = 0 (none)
mov	[eax+12], ecx		;size-downlink(first) = 0 (none)
mov	[edx+0], ecx		;addr-uplink(last) = 0
mov	[edx+4], ebx		;addr-downlink(last) = size(first)
mov	[edx+8], ecx		;size-uplink(last) = 0 (none)
mov	[edx+12], ecx		;size-uplink(last) = 0 (none)  xxx add 11/04/93
;; mov	[edx+12], 0x80000000	;size-downlink(last) = "allocated"  xxx axe 11/04/93
or	ebx,0x80000000		;mark allocated xxx add 11/04/93
mov	[edx+4], ebx		;mark allocated xxx add 11/04/93
;;
;; allocation routines blow up unless there's a permanent allocated
;; memory block at the bottom of the dyno memory area, so make one!
;;
mov	esi,16			; esi = 16 bytes
call	%____calloc		; allocate 16 byte chunk
mov	eax,[_##WHOMASK]	; eax = system/user int
or	eax,0x80130001		; info word = allocated string
mov	[esi-4],eax		; save info word
mov	[esi-8],14		; save length
;;
mov	edi,esi			; destination
mov	esi,%pdeString		; source
mov	ecx,14			; count
cld				; up
rep				; repeat
movsb				; move bytes
;;
;; miscellaneous initialization
;;
xor	eax,eax			; Initialize system variables
mov	[_##CPU],80386
mov	[_##ERROR],eax
mov	[_##WHOMASK],eax
mov	[_##SOFTBREAK],eax
mov	[_##EXCEPTION],eax
mov	[_##OSEXCEPTION],eax
mov	[_##USERRUNNING],eax
mov	[_##SIGNALACTIVE],eax
mov	[_##LOCKOUT],eax
mov	[_##BEGINALLOCODE],%_beginAlloCode
mov	[_##ENDALLOCODE],%_endAlloCode
;;
;; mov	[_##WHERE], 0x000B	; note where
;; call	_XxxWriteWin32s@0	; write where # to "win32s.bug"
;;
;; Skipped some stuff under mem.areas here
;;
mov	eax,_XxxExternals	; first address of user shared/external variables
mov	ebx,eax			; ditto
add	ebx,65536		; final address of user shared/external variables
;;
mov	[_##GLOBAL0], eax	; XxxExternals = first
mov	[_##GLOBAL], eax	; XxxExternals = first
mov	[_##GLOBALX], eax	; XxxExternals = first
mov	[_##GLOBALZ], ebx	; XxxExternalz = final  (max shared/external addr)
mov	[_##TABSAT], 2		; Default tab setting is 2
mov	[_##STANDALONE], -1	; Default is standalone code (not environment)
;;
;; need the following line to note memory initialization is complete
;;
mov	[%initoid], _XxxMain	; %initoid = &XxxMain()
mov	esp, ebp		; standard function exit
pop	ebp			; standard function exit
ret
;
;
; #################################
; #####  XxxStartApplication  #####
; #################################
;
_XxxStartApplication@0:
mov	[_##ENTERED], 0		; not entered yet
mov	eax, [_##APP]		; eax = application address
or	eax, eax		; address = 0 for PDE else &%_StartApplication
jnz	startStandalone		; if address != 0 : jump to standalone program
;jmp	%_StartApplication	; jump to %_StartApplication
ret				; no application - return to caller
;
startStandalone:
jmp	eax			; jump to %_StartApplication
;
;
; ############################
; #####  XxxTerminate@0  #####
; ############################
;
_XxxTerminate@0:
push	-1
push	0
call	_XxxXstFreeLibrary@8	; free all libraries
;;
mov	eax,[_##DYNO0]
mov	ebx,[_##DYNOZ]
sub	ebx,eax
push	0x4000
push	ebx
push	eax
call	_VirtualFree@12		; free all DYNO memory
push	0
call	_ExitProcess@4
ret
;
;
; ########################
; #####  XxxFCLEX@0  #####
; ########################
;
_XxxFCLEX@0:
fnclex
xor	eax,eax
ret
;
;
; ########################
; #####  XxxFINIT@0  #####
; ########################
;
_XxxFINIT@0:
finit
xor	eax,eax
ret
;
;
; ########################
; #####  XxxFSTCW@0  #####
; ########################
;
_XxxFSTCW@0:
xor	eax,eax
push	eax
fstcw	[esp]
pop	eax
ret
;
;
; ########################
; #####  XxxFSTSW@0  #####
; ########################
;
_XxxFSTSW@0:
xor	eax,eax
push	eax
fstsw	[esp]
pop	eax
ret
;
;
; #######################
; #####  XxxFLDZ@0  #####
; #######################
;
_XxxFLDZ@0:
fldz
ret
;
;
; #######################
; #####  XxxFLD1@0  #####
; #######################
;
_XxxFLD1@0:
fld1
ret
;
;
; ########################
; #####  XxxFLDPI@0  #####
; ########################
;
_XxxFLDPI@0:
fldpi
ret
;
;
; #########################
; #####  XxxFLDL2E@0  #####
; #########################
;
_XxxFLDL2E@0:
fldl2e
ret
;
;
; #########################
; #####  XxxFLDL2T@0  #####
; #########################
;
_XxxFLDL2T@0:
fldl2t
ret
;
;
; #########################
; #####  XxxFLDLG2@0  #####
; #########################
;
_XxxFLDLG2@0:
fldlg2
ret
;
;
; #########################
; #####  XxxFLDLN2@0  #####
; #########################
;
_XxxFLDLN2@0:
fldln2
ret
;
;
; ########################
; #####  XxxF2XM1@8  #####
; ########################
;
_XxxF2XM1@8:
fld	qword ptr [esp+4]
f2xm1
ret	8
;
;
; #######################
; #####  XxxFABS@8  #####
; #######################
;
_XxxFABS@8:
fld	qword ptr [esp+4]
fabs
ret	8
;
;
; #######################
; #####  XxxFCHS@8  #####
; #######################
;
_XxxFCHS@8:
fld	qword ptr [esp+4]
fchs
ret	8
;
;
; #######################
; #####  XxxFCOS@8  #####
; #######################
;
_COS@8:
_XxxFCOS@8:
fld	qword ptr [esp+4]
fcos
ret	8
;
;
; ####################
; #####  ATAN@8  #####
; ####################
;
_ATAN@8:
fld	qword ptr [esp+4]
fld1
fpatan
ret	8
;
;
; ##########################
; #####  XxxFPATAN@16  #####
; ##########################
;
_XxxFPATAN@16:
fld	qword ptr [esp+4]
fld	qword ptr [esp+12]
fpatan
ret	16
;
;
; #########################
; #####  XxxFPREM@16  #####
; #########################
;
_XxxFPREM@16:
fld	qword ptr [esp+12]
fld	qword ptr [esp+4]
fprem
fstsw	ax
sahf
jp	short _XxxFPREM@16
fxch
xor	eax,eax
push	eax
fstp	qword ptr [esp]
add	esp,4
ret	16
;
;
; ##########################
; #####  XxxFPREM1@16  #####
; ##########################
;
_XxxFPREM1@16:
fld	qword ptr [esp+12]
fld	qword ptr [esp+4]
fprem1
fstsw	ax
sahf
jp	short _XxxFPREM1@16
fxch
xor	eax,eax
push	eax
fstp	qword ptr [esp]
add	esp,4
ret	16
;
;
; #########################
; #####  XxxFPTAN@16  #####
; #########################
;
_XxxFPTAN@16:
fld	qword ptr [esp+4]
fptan
fstp	qword ptr [esp+12]
ret	16
;
;
; ###################
; #####  TAN@8  #####
; ###################
;
_TAN@8:
fld	qword ptr [esp+4]
fptan
fstp	qword ptr [esp-8]
ret	8
;
;
; ##########################
; #####  XxxFRNDINT@8  #####
; ##########################
;
_XxxFRNDINT@8:
fld	qword ptr [esp+4]
frndint
ret	8
;
;
; ##########################
; #####  XxxFSCALE@16  #####
; ##########################
;
_XxxFSCALE@16:
fld	qword ptr [esp+4]
fld	qword ptr [esp+12]
fscale
fxch
xor	eax,eax
push	eax
fstp	qword ptr [esp]
add	esp,4
ret	16
;
;
; #######################
; #####  XxxFSIN@8  #####
; #######################
;
_SIN@8:
_XxxFSIN@8:
fld	qword ptr [esp+4]
fsin
ret	8
;
;
; ###########################
; #####  XxxFSINCOS@16  #####
; ###########################
;
_XxxFSINCOS@16:
fld	qword ptr [esp+4]
fsincos
fstp	qword ptr [esp+12]
ret	16
;
;
; ########################
; #####  XxxFSQRT@8  #####
; ########################
;
_SQRT@8:
_XxxFSQRT@8:
fld	qword ptr [esp+4]
fsqrt
ret	8
;
;
; ###########################
; #####  XxxFXTRACT@16  #####
; ###########################
;
_XxxFXTRACT@16:
fld	qword ptr [esp+4]
fxtract
fstp	qword ptr [esp+12]
ret	16
;
;
; #########################
; #####  XxxFYL2X@16  #####
; #########################
;
_XxxFYL2X@16:
fld	qword ptr [esp+4]
fld	qword ptr [esp+12]
fyl2x
ret	16
;
;
; ###########################
; #####  XxxFYL2XP1@16  #####
; ###########################
;
_XxxFYL2XP1@16:
fld	qword ptr [esp+4]
fld	qword ptr [esp+12]
fyl2xp1
ret	16
;
;
; ####################
; #####  EXP ()  #####  e ** x#
; ####################
;
.text
_EXP@8:
_EXPE@8:
push	ebp
mov	ebp,esp
sub	esp,8
fld	qword ptr [ebp+8]
fldl2e
fmulp
jmp	short expdo
;
;
; #####################
; #####  EXP2 ()  #####  2 ** x#
; #####################
;
_EXP2@8:
push	ebp
mov	ebp,esp
sub	esp,8
fld	qword ptr [ebp+8]
jmp	short expdo
;
; ######################
; #####  EXP10 ()  #####  10 ** x#
; ######################
;
_EXP10@8:
push	ebp
mov	ebp,esp
sub	esp,8
fld	qword ptr [ebp+8]
fldl2t
fmulp
jmp	short expdo
;
;
expdo:
fstcw	[ebp-4]
fstcw	[ebp-8]
fwait
and	word ptr [ebp-4],0xF3FF
fldcw	[ebp-4]
fld	st(0)
frndint
fldcw	[ebp-8]
fxch	st(1)
fsub	st(0),st(1)
f2xm1
fwait
fld1
faddp	st(1),st(0)
fscale
fstp	st(1)
mov	esp,ebp
pop	ebp
ret	8
;
; #################################
; #####  x# = y# ** z#  ###########
; #################################
; #####  x# = POWER (y#, z#)  #####
; #################################
;
.text
_EXPX@16:
_POWER@16:
push	ebp
mov	ebp,esp
sub	esp,24
push	ebx
fld	qword ptr [ebp+8]
fld	qword ptr [ebp+16]
fldz                   ; 0 y x
fucom	st(1)
fnstsw	ax
and	ah,68
xor	ah,64
jnz 	short power.nonzorch
fstp	st(0)
fstp	st(0)
fstp	st(0)
fld1
jmp 	power.done
;
power.nonzorch:
fucom	st(2)            ; 0 y x
fnstsw	ax
and	ah,68
xor	ah,64
jnz 	short power.3
fstp	st(2)
fcompp
fnstsw	ax
and	ah,69
cmp	ah,1
jz 	short power.15
fldz
jmp 	power.done
;
power.3:
fld1                  ; 1 0 y x
fucomp	st(2)         ; 0 y x
fnstsw	ax
and	ah,69
cmp	ah,64
jz 	power.14
fcomp	st(2)           ; y x
fnstsw	ax
and	ah,69
jnz 	short power.7
fld	st(0)             ; y y x
fnstcw	[ebp-2]
mov	ax,word ptr [ebp-2]
mov	ah,12
mov	word ptr [ebp-4],ax
fldcw	[ebp-4]
sub	esp,8
fistp	qword ptr [esp]
pop	edx
pop	ecx
fldcw	[ebp-2]
mov	ebx,edx
and	ebx,1
push	ecx
push	edx
fild	qword ptr [esp]
add	esp,8             ; int(y) y x
fucomp	st(1)         ; y x
fnstsw	ax
and	ah,69
cmp	ah,64
jz 	short power.8
fstp	st(0)
fstp	st(0)
;;
power.15:
mov	[_errno],33				; EDOM : errno = "domain error"
mov	[esp],0xFFFFFFFF
mov	[esp+4],0x7FFFFFFF
fld	qword ptr [esp]		; $$PNAN = not a number
jmp 	power.done
;
;
power.8:
fxch	st(1)           ; x y
fchs
jmp 	short power.9
;
;
power.7:
fxch	st(1)           ; x y
xor	ebx,ebx
;;
power.9:
fnstcw	[ebp-2]
mov	dx, word ptr [ebp-2]
mov	word ptr [ebp-4],dx
mov	dx, word ptr [ebp-2]
and	dh,243
or	dl,63
mov	word ptr [ebp-2],dx
fldcw	[ebp-2]
fyl2x                ; y*log2(x)
fld st(0)
frndint
fxch
fsub st(0), st(1)
f2xm1
fld1
fadd
fxch
fld1
fscale
fstp	st(1)
fmul
fldcw	[ebp-4]
sub	esp,8
fst	qword ptr [esp]
call	isinf
test	eax,eax
jnz 	short power.11
call	isnan
test	eax,eax
jz 	short power.10
;;
power.11:
mov	[_errno],34		; ERANGE : errno = "range error"
;;
power.10:
test	ebx,ebx
jz 	short power.done
fchs
jmp 	short power.done
;
;
power.14:
fstp	st(0)
fstp	st(0)
;;
power.done:
mov	ebx,[ebp-28]
mov	esp,ebp
pop	ebp
ret	16
;
;
isnan:
xor	edx,edx
mov	ax, word ptr [esp+10]
slr	ax,4
and	eax,0x000007FF
cmp	eax,0x000007FF
jnz	short iszero
test	[esp+8],0x000FFFFF
jnz	short isone
cmp	[esp+4],0
jnz	short isone
;;
iszero:
xor	eax,eax
ret
;
;
isone:
mov	eax,0x00000001
ret
;
;
isinf:
mov	eax,[esp+8]
and	eax,0x7FFFFFFF
cmp	eax,0x7FF00000
jnz	short iszero
cmp	[esp+4],0
jnz	short iszero
mov	eax,0x00000001
cmp	byte ptr [esp+11], 0
jge	short isinf.done
mov	eax,0xFFFFFFFF
isinf.done:
ret
;
;
;
; ##################
; #####  XxxG  #####  calls _##UCODE (sets _##WHOMASK first)
; ##################
;
_XxxG@0:
mov	[_##ENTERED],0		; application not entered
mov	[_##SOFTBREAK],0	; reset softBreak
mov	[_##WHOMASK],0x01000000	; we're in user country now
call	[_##UCODE]
mov	[_##WHOMASK],0		; we're back in system country
ret
;
;
; #########################
; #####  XxxGuessWho  #####  Returns ##WHOMASK
; #########################
;
_XxxGuessWho@0:
mov	eax,[_##WHOMASK]	; eax = ##WHOMASK
ret										; return ##WHOMASK
;
;
; #############################
; #####  XxxGetEbpEsp ()  #####
; #############################
;
_XxxGetEbpEsp@8:
mov	[esp+4],ebp
mov	[esp+8],esp
ret	8
;
;
; #############################
; #####  XxxSetEbpEsp ()  #####
; #############################
;
_XxxSetEbpEsp@8:
mov	ebp,[esp+4]
mov	esp,[esp+8]
ret	8
;
;
; ################################
; #####  XxxGetFrameAddr ()  #####
; ################################
;
_XxxGetFrameAddr@0:
mov	eax,ebp
ret
;
;
; ################################
; #####  XxxSetFrameAddr ()  #####
; ################################
;
_XxxSetFrameAddr@4:
mov	ebp,[esp+4]
ret	4
;
;
; #################################
; #####  XxxGetExceptions ()  #####
; #################################
;
_XxxGetExceptions@8:
mov	ebx,[_##OSEXCEPTION]
mov	eax,[_##EXCEPTION]
mov	[esp+4],eax
mov	[esp+8],ebx
ret	8
;
;
; #################################
; #####  XxxSetExceptions ()  #####
; #################################
;
_XxxSetExceptions@8:
mov	eax,[esp+4]
mov	ebx,[esp+8]
mov	eax,[_##EXCEPTION]
mov	ebx,[_##OSEXCEPTION]
ret	8
;
;
; ####################################
; #####  XxxGetFPEnvironment ()  #####
; ####################################
;
;   In:  arg0  address of 7-word buffer for current FP environment
;   Uses:	esi
;   Return:	eax = 0
;
_XxxGetFPEnvironment@4:
mov	esi,[esp+4]			; get buffer address
or	esi,esi
jz	gfDone
fnstenv	[esi]				; resets control word
fldenv	[esi]				; restore control word
gfDone:
xor	eax,eax
ret	4
;
;
; ####################################
; #####  XxxClearFPException ()  #####
; ####################################
;
;   In:		none
;   Return:	eax = _controlfp() return value
;
_XxxClearFPException@0:
fnclex					; Clear FP exceptions
fninit
call	_XxxEnableFPExceptions@0
ret
;
;
; ######################################
; #####  XxxEnableFPExceptions ()  #####
; ######################################
;
; set fp exception mask:  ZERODIVIDE|OVERFLOW|UNDERFLOW
; DENORMAL|INVALID|INEXACT not active
; controlfp() does not allow DENORMAL
;
_XxxEnableFPExceptions@0:
mov	eax,0x0000000E			; ZERODIVIDE|OVERFLOW|UNDERFLOW
push	eax
xor	eax,eax
push	eax
push	eax
call	__controlfp			; _controlfp(0,0)
add	esp,8
and	eax,0xFFFFFFF1
push	eax
call	__controlfp			; _controlfp(new, mask)
add	esp,8
ret
;
;
; #################################
; #####  XxxCheckMessages ()  #####
; #################################
;
_XxxCheckMessages@0:
push	0			; PeekMessageA (@messageBuffer, 0, 0, 0, 0)
push	0			;   (don't remove message)
push	0
push	0
push	%messageBuffer
call	_PeekMessageA@20
or	eax,eax
jnz	short	pending
ret
pending:
;push	-1							; processSystem messages
push	[_##WHOMASK]		; processSystem messages if in user mode
push	0			; don't wait
call	_XxxDispatchEvents@8
ret
;
;
; ******************************
; *****  SUPPORT ROUTINES  *****
; ******************************
;
%_ZeroMemory:
_XxxZeroMemory:
mov	ecx,edi		; ecx = byte after last
sub	ecx,esi		; ecx = # of bytes to zero
jnb	zmpos		; positive value
;;
xchg	esi,edi		; make esi < edi
mov	ecx,edi		; ecx = byte after last
sub	ecx,esi		; ecx = # of bytes to zero
;;
zmpos:
slr	ecx,2		; ecx = # of dwords to zero
jecxz	zm_exit		; skip if no bytes to zero
xor	eax,eax		; ready to write some zeros
mov	edi,esi		; edi -> beginning of block to zero
cld			; make sure stosd moves up in memory
rep
stosd			; write 'em!
zm_exit:
ret
;
;
;
%_eeeErrorNT:
call	_GetLastError@0		; eax = Win32 error number
mov	[_##EXTRA0],eax		;
neg	eax			; eax = -errorNumber
push	0
push	%%OperatingSystemError
jmp	%_RuntimeError
;
%_eeeAllocation:
push	0
push	%%MemoryAllocation
jmp	%_RuntimeError
;
%_eeeOverflow:
push	0
push	%%Overflow
jmp	%_RuntimeError
;
%_OutOfBounds:
push	0
push	%%ArrayInvalidAccess
jmp	%_RuntimeError
;
%_NeedNullNode:
push	0
push	%%NodeNotEmpty
jmp	%_RuntimeError
;
%_UnexpectedLowestDim:
push	0
push	%%ArrayLowestDimension
jmp	%_RuntimeError
;
%_UnexpectedHigherDim:
push	0
push	%%ArrayHigherDimension
jmp	%_RuntimeError
;
%_InvalidFunctionCall:
push	0
push	%%FunctionInvalidArgument
jmp	%_RuntimeError
;
;
; *****  RuntimeError  *****  enter after pushing 0x00, &error$
;
%_RuntimeError:
call	_XstErrorNameToNumber@8	; error name to number
mov	esi, [esp-4]		; esi = error number
mov	[_##ERROR], esi		; ##ERROR = error number
mov	[_##TRAPVECTOR],504	; 504 = GeneralPurpose (XERROR)
;
;
errorReport:
; *****  DEBUG  *****
;	mov	eax,[esp]	; save return address for message
;	pushad
;	push	eax		; show error message
;	push	[_##ERROR]
;	push	[_##TRAPVECTOR]
;	push	Rmsg
;	push	txtBuffer
;	call	_sprintf
;	add	esp,20
;	call	WriteTxtBuffer
;	popad
;
; *****  DEBUG  *****
;
pushad
mov	eax, [_##WIN32S]
or	eax, eax
popad
jnz	_XxxRuntimeError2
;;
_XxxRuntimeError:		; required for frames
int	3			; breakpoint instruction
ret
;
;
_XxxRuntimeError2:		; required for frames
.word	0x0F0F			; 2-byte invalid instruction
ret
;
;
; error strings for XstErrorNameToNumber()
;
.align 	8
.dword	0x00000030, 0x00000000, 0x00000011, 0x00130001
%%MemoryAllocation:
.byte	"Memory Allocation"
.zero	15
;
.align 	8
.dword	0x00000020, 0x00000000, 0x00000008, 0x00130001
%%Overflow:
.byte	"Overflow"
.zero	8
;
.align 	8
.dword	0x00000030, 0x00000000, 0x00000013, 0x00130001
%%ArrayInvalidAccess:
.byte	"Array InvalidAccess"
.zero	13
;
.align 	8
.dword	0x00000020, 0x00000000, 0x0000000D, 0x00130001
%%NodeNotEmpty:
.byte	"Node NotEmpty"
.zero	3
;
.align 	8
.dword	0x00000030, 0x00000000, 0x00000015, 0x00130001
%%ArrayLowestDimension:
.byte	"Array LowestDimension"
.zero	11
;
.align 	8
.dword	0x00000030, 0x00000000, 0x00000015, 0x00130001
%%ArrayHigherDimension:
.byte	"Array HigherDimension"
.zero	11
;
.align 	8
.dword	0x00000030, 0x00000000, 0x00000015, 0x00130001
%%OperatingSystemError:
.byte	"OperatingSystem Error"
.zero	11
;
.align 	8
.dword	0x00000030, 0x00000000, 0x00000018, 0x00130001
%%FunctionInvalidArgument:
.byte	"Function InvalidArgument"
.zero	8
;
;
;
; *****  Routines for debugging  ******
;
_XxxFPUstatus@0:
fnstsw	ax
ret
;
_XxxEBPandESP@0:
mov	eax,ebp
mov	edx,esp
ret
;
;
;
; *****  DEBUG  *****
;
WriteTxtBuffer:
mov	eax, [debugHandle]	; fileHandle
or	eax, eax
jnz	write
call	OpenWin32s
;;
write:
xor	eax, eax
push	eax			; overLapped (FALSE)
mov	eax, bytesWritten	; bytesWRITTEN (return value)
push	eax
push	txtBuffer		; LEN(txtBuffer)
call	_strlen
add	esp, 4
push	eax
mov	eax, txtBuffer		; txtBuffer addr
push	eax
mov	eax, [debugHandle]	; fileHandle
push	eax
call	_WriteFile@20
ret
;
;
;
; fileHandle = CreateFileA (&"win32s.bug", 0x40000000, 0, 0, 2, 0x00000080, 0);
;
OpenWin32s:
xor	eax, eax
push	eax
mov	eax, 0x80
push	eax
mov	eax, 2
push	eax
xor	eax, eax
push	eax
push	eax
mov	eax, 0x40000000
push	eax
mov	eax, debugFile
push	eax
call	_CreateFileA@28
mov	[debugHandle], eax
ret
;
.globl	_XxxWriteWin32s@0
_XxxWriteWin32s@0:
push	eax
push	ebx
push	ecx
push	edx
push	esi
push	edi
push	0			; arg4 = 0 means not an overlapped write
push	bytesWritten		; arg3 = &bytesWritten - value returned here
push	4			; arg2 = # of bytes to write
push	_##WHERE		; arg1 = &whereBuffer
push	[debugHandle]		; arg0 = debug file handle
call	_WriteFile@20		; write XLONG where value to "win32s.bug"
pop	edi
pop	esi
pop	edx
pop	ecx
pop	ebx
pop	eax
ret
;
;
;
;
.text
.align	8
;
; #####################
; #####  xlib0.s  #####  Memory-allocation routines
; #####################
;
%_beginAlloCode:	; mark beginning of uninterruptible code for xinit.s
ret	0
;
;
; ********************
; *****  calloc  ***** allocate and clear a chunk for n elements of m bytes
; ********************
;
; *****  calloc  *****  C entry point
;
;  in:  arg1 = size of each element
;	arg0 = number of elements
; out:	eax -> allocated block, or NULL if memory not available
;
; Also returns NULL if size of requested block is zero.
;
calloc:
_calloc:
__calloc:
	push	ebp
	mov	ebp,esp
	xor	eax,eax		;speed up following comparisons (I think)
	cmp	[ebp+8],eax	;number of elements = 0?
	jz	short ccalloc0	;then quit wasting my time
	cmp	[ebp+12],eax	;same if element size is zero
	jz	short ccalloc0

	push	ebx
	push	esi
	push	edi

	mov	esi,[ebp+12]
	imul	esi,[ebp+8]	;esi = # of element * element size = total size
	call	%_____calloc	;esi -> new block's header, or NULL if none
	mov	eax,esi

	pop	edi
	pop	esi
	pop	ebx
	or	eax,eax
	jz	short ccalloc0
	add	eax,16
ccalloc0:
	pop	ebp
	ret
;
;
; *****  calloc  *****  XBASIC entry point
;
;  in:  arg0 = total size of block to allocate
; out:	eax -> allocated block, or NULL if memory not available
;
; Also returns NULL if size of requested block is zero.
;
; Except for the fact that the XBASIC entry point for calloc takes
; only one parameter, the result of multiplying the C entry point's
; parameters together, this entry point is the same as the C
; entry point.
;
_Xcalloc:
___calloc:
	push	ebp
	mov	ebp,esp
	cmp	[ebp+8],0	;size to allocate is zero?
	jz	short xcalloc0	;then quit wasting my time
;
	push	ebx
	push	esi
	push	edi
;
	mov	esi,[ebp+8]	;esi = size of block to allocate
	call	%_____calloc	;esi -> new block's header, or NULL if none
	mov	eax,esi
;
	pop	edi
	pop	esi
	pop	ebx
	or	eax,eax
	jz	short xcalloc0
	add	eax,16
xcalloc0:
	pop	ebp
	ret
;
;
; *****  calloc  *****  internal entry point
;
; in:	esi = size of block to allocate
; out:	esi -> allocated block's data area, or zero if error
;
; destroys: edi
;
%____calloc:
	push	eax
	push	ebx
	push	ecx
	push	edx
	call	%_____calloc
	or	esi,esi
	jz	short icalloc0
	add	esi,16
icalloc0:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
;
; *****  calloc  *****  CORE ROUTINE
;
;  in:  esi = size of block to allocate
; out:  esi -> allocated block's HEADER (not data)
;
; destroys: eax, ebx, ecx, edx, edi
;
%_____calloc:
	or	esi,esi		;if zero-size block, return null pointer
	jz	short calloc_exit
	call	%_____malloc	;esi->alloc'ed block's header
;
	or	esi,esi		;error?
	jz	short calloc_exit ;yep
;
	xor	eax,eax		;prepare to write zeros
	mov	ecx,[esi]	;ecx = size of block, including header
	sub	ecx,16		;ecx = size of block's data area
	lea	edi,[esi+16]	;edi -> block's data area
	slr	ecx,2		;ecx = # of dwords to zero (block size can
;				; only be a multiple of 16)
	cld			;make sure direction is right
	rep
	stosd			;fill with zeros
calloc_exit:
	ret
;
;
; ********************
; *****  malloc  *****  allocate a chunk of storage
; ********************
;
; *****  malloc  *****  C entry point  and  XBASIC entry point
;
;  in: arg0 = number of bytes to allocate
; out: eax -> allocated block, or NULL if none available
;
; Also returns NULL if requested to allocate zero bytes.
;
malloc:
_malloc:
__malloc:
_Xmalloc:
___malloc:
	push	ebp
	mov	ebp,esp
	cmp	[ebp+8],0	;trying to malloc zero bytes?
	jz	short cmalloc0	;then quit wasting my time
	push	ebx
	push	esi
	push	edi
;;
	mov	esi,[_##MAIN]	; esi = ##MAIN
	cmp	esi,_XxxMain	; ##MAIN = &XxxMain() ???
	jz	minited		; yes - memory allocation initialized
	call	initialize	; no - initialize memory allocation
minited:
;;
	mov	esi,[ebp+8]
	call	%_____malloc	;esi -> new block's header, or NULL if none
	mov	eax,esi
	pop	edi
	pop	esi
	pop	ebx
	or	eax,eax
	jz	short cmalloc0
	add	eax,16
cmalloc0:
	pop	ebp
	ret
;
;
; *****  malloc  *****  internal entry point
;
; in:	esi = size of block to allocate
; out:	esi -> data area of allocated block
;
; destroys: edi
;
; Returns null pointer if error.
;
%____malloc:
	push	eax
	push	ebx
	push	ecx
	push	edx

	call	%_____malloc
	or	esi,esi		;error?
	jbe	short ____malloc_ok ;yes
	add	esi,16		;no: esi -> data area of allocated block
____malloc_ok:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
;
;
; *****  malloc  *****  CORE ROUTINE
;
;  in: esi = size of block to allocate
; out: esi -> HEADER of allocated block (not data area)
;
; destroys: eax, ebx, ecx, edx, edi
;
; local variables:
;	-4	Size of block to allocate; original esi
;	-8	Total size of block to allocate, including header
;	-12	Address of big-enough chunk (when searching thru big-chunk list)
;	-16	Size of best-fitting big chunk found so far
;
%_____malloc:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	or	esi,esi		;request for zero-length block?
	jz	short malloc_exit ;if so, return null pointer
	mov	[ebp-4],esi	;save requested size
;
; get pointer # for specified size
;
malloop:
	mov	ebx,esi
	dec	ebx		;ebx = size - 1
;	jnc	short non_zero_size ;skip if esi != 0		xxx del
	jns	short non_zero_size ;skip if esi != 0		xxx add
	inc	ebx		;ebx = 0 (if size = 0)
non_zero_size:
	mov	esi,ebx
	slr	esi,4		;esi = (size - 1) / 16 = pointer #
	mov	edx,esi
	sll	edx,4		;edx = size needed - 16
	add	edx,0x20	;edx = total size needed, including header
	mov	[ebp-8],edx	;save for later
	and	ebx,0xFFFFFF00	;ebx = 0 if size <= 256
	jnz	big_chunk	;size is > 256; special large chunk required
;
; size <= 256
;
	mov	ebx,[%pointers+esi*4] ;ebx -> 1st chunk this size
	or	ebx,ebx		;any chunks this size?
	jz	short not_exact	;nope
;
; CASE A: Found free chunk of desired size
;
	mov	eax,[ebx+8]	;eax -> size-upstream header
	mov	ecx,[ebp-4]	;ecx = size requested
	mov	edx,[_##WHOMASK] ;edx = system/user bit in info word
; or	edx,0x80000001	;mark as allocated	' xxx del
or	edx,0x00000001	;one byte per element	' xxx add
bts	[ebx+4],31	;mark as allocated	' xxx add
jnc	short blockOk0	;previously allocated	' xxx add
;;
call	%_eeeAllocation	;block allocated	; xxx add
xor	esi,esi		;return null pointer	; xxx add
ret			;never get here		; xxx add
;						; xxx add
blockOk0:					; xxx add
	mov	[ebx+8],ecx	;size of block = requested size
	mov	[ebx+12],edx	;write info word into header
	mov	[%pointers+esi*4],eax ;update pointer to unlink this chunk
	or	eax,eax		;size uplink = 0?
	jz	short skip_zip	;yes -- no further chunks
	mov	dword ptr [eax+12],0 ;zero size downlink of next chunk

skip_zip:
	mov	esi,ebx		;return pointer to header of new block in esi
malloc_exit:
	mov	esp,ebp
	pop	ebp
	ret
;
; no exact-size chunks are free
;
not_exact:
	mov	ebx,esi
	inc	ebx		;ebx = next pointer #
not_yet:
	mov	eax,[%pointers+ebx*4] ;eax = ptr to block of next higher size
	or	eax,eax		;is there a pointer?
	jnz	got_chunk	;yes, go allocate it
	inc	ebx		;nope, point to next size up
	cmp	ebx,16		;are we past the end of the table?
	jbe	short not_yet	;no, try next size up
;				;else fall through
;
; CASE B:  No free chunks of desired size or larger exist; get more memory
;
; compute new break address and uplink to new top header
;
none_big_enough:
	sub	esp, 16			; ;;; create frame		ntntnt
	mov	eax, [_##DYNOZ]		; base of new pages to alloc	ntntnt
	mov	[esp+ 0], eax		; arg1 = base of new area	ntntnt
	mov	[esp+ 4], 0x100000	; arg2 = 1MB (new area size)	ntntnt
	mov	[esp+ 8], 0x1000	; arg3 = MEM_COMMIT		ntntnt
	mov	[esp+12], 0x0004	; arg4 = PAGE_READWRITE		ntntnt
	call	_VirtualAlloc@16	; ;;; extend dyno area by 1MB	ntntnt
;;;	add	esp, 64			; restore frame			ntntnt
	or	eax, eax		; error check			ntntnt
	jnz	short breaker.good	; no, proceed			ntntnt
;
; error allocating another 1MB
;
	call	%_eeeErrorNT		; process Win32 error		ntntnt
	ret				; better not get here !!!	ntntnt
;
; no error, got memory
;
breaker.good:
	add	eax, 0x100000		; eax = address after top (add 1MB)
	mov	[_##DYNOZ], eax		; ##DYNOZ = ditto
	sub	eax, 0x0010		; eax = new top header address
	mov	[_##DYNOX], eax		; ##DYNOX = ditto
	mov	dword ptr [eax+0], 0	; addr-uplink(new-top) = 0
; mov	[eax+4], 0x100000	; addr-downlink(new-top)=1MB	; xxx del
mov	[eax+4], 0x80100000	; addr-downlink(new-top)=1MB	; xxx add
	mov	dword ptr [eax+8], 0	; size-uplink(new-top) = 0 (last header)
; mov	[eax+12], 0x80000001	; size-down(new-top)=alloc	; xxx del
mov	[eax+12], 0x0001	; size-down(new-top)=bytes/ele	; xxx add
	mov	esi, eax		; esi = new top header address
	sub	esi, 0x100000		; esi = old top header address
	mov	[esi], 0x100000		; addr-uplink(old-top) = 1MB
;
; free previous top header
;
	call	%____Hfree		;free old top header (probable merge)
	mov	esi,[ebp-4]		;esi = original requested size
	jmp	malloop			;we have more memory now, so try again
;
; CASE C:  No free chunk of perfect size, but found larger free chunk
;
; entry:  eax = pointer contents = address of 1st chunk in this free list
;	  [ebp-8] = size needed, including header
;	  ebx = pointer # (pointer of size-list having chunk to use)
;
; unlink this header from size links
;
got_chunk:
	mov	esi,[eax+8]		;esi = size-uplink to size-upstream chunk
	mov	[%pointers+ebx*4],esi	;point size pointer at size-upstream chunk
	or	esi,esi			;if uplink = 0, then no size-upstream chunk
	jz	short whole_or_part
	mov	dword ptr [esi+12],0	;mark size-upstream header as new 1st chunk
;
; decide whether to use this entire free chunk, or only a lower portion
;
whole_or_part:
	mov	edx,[ebp-4]	;edx = requested size
	mov	esi,[_##WHOMASK] ;esi = system/user bit in info word
; or	esi,0x80000001	;esi = "allocated" marker	; xxx del
or	esi,0x00000001	;esi = 1 byte per element	; xxx add
bts	[eax+4],31	;mark as allocated		; xxx add
jnc	short blockOk1	;previously allocated		; xxx add
;;
call	%_eeeAllocation	;block allocated		; xxx add
xor	esi,esi		;return null pointer		; xxx add
ret							; xxx add
;							; xxx add
blockOk1:						; xxx add
	mov	[eax+8],edx	;header word2 = requested size
	mov	[eax+12],esi	;marker this header as in use
	mov	esi,[eax]	;esi = size of chunk including header
	sub	esi,[ebp-8]	;esi = size - needed size = new free size
	jns	short duh4	;DEBUG
;	int	3		;block allocated	; xxx del
	call	%_eeeAllocation	;block allocated	; xxx add
duh4:				;DEBUG
	cmp	esi,0x20	;still room for header and 16-byte data block?
	jb	short no_new	;nope, allocate entire chunk
;
; address link a new free header above the chunk being allocated
;
	mov	edi,[ebp-8]	;edi = size needed (including header)
	lea	edx,[eax+edi]	;edx -> new free chunk
	mov	[edx],esi	;put address up-link in new free chunk
	mov	[edx+4],edi	;put address down-link in new free chunk
	mov	[eax],edi	;put address up-link in this chunk
	lea	edi,[edx+esi]	;edi -> header above new free chunk
bts	esi,31		;esi = addr-down-link + allocated bit	; xxx add
	mov	[edi+4],esi	;put address down-link in header above new free
btr	esi,31		;restore esi				; xxx add
;
; compute pointer # to size-link the new free header
;
	sub	esi,17		;esi = size of new free chunk's data area - 1
	mov	edi,esi
	slr	esi,4		;esi = pointer # for small chunk
	and	edi,0xFFFFFF00	;edi = 0 if new free chunk size <= 256 bytes
	jz	short small_chunk ;if edi = 0, a small chunk is adequate
	mov	esi,16		;esi = pointer # for large chunk
;
; size-link new free block to pointer and next size up-link header
;
small_chunk:
	mov	edi,[%pointers+esi*4] ;edi -> 1st header of this size
	mov	[%pointers+esi*4],edx ;update size pointer to new free chunk
	mov	[edx+8],edi	;put size-uplink into new free header
	mov	dword ptr [edx+12],0 ;put size down-link into new free header
	or	edi,edi		;if size-uplink = 0, no size-upstream
	jz	short no_new
	mov	[edi+12],edx	;put size down-link into next up-link header
no_new:
	mov	esi,eax		;esi -> allocated header
	mov	esp,ebp
	pop	ebp
	ret
;
; malloc executes the following code when the required size > 256 bytes.
; It attempts to find a free chunk 1.125 to 1.375 times the minimum
; size by searching through the size-linked big chunks
;
; entry:  edx = required size, including header
;
big_chunk:
	mov	[ebp-12],0	;no big-enough chunk found yet
	mov	[ebp-16],0	;size of best-fitting chunk = 0
	mov	esi,[%pointers+0x40] ;esi -> first big-chunk header
	mov	ebx,edx
	slr	ebx,3		;ebx = 1/8 minimum chunk size
	mov	ecx,edx
	slr	ecx,2		;ecx = 1/4 minimum chunk size
	add	edx,ebx		;edx = 1.125 * mimimum chunk size
	lea	ebx,[edx+ecx]	;ebx = 1.375 * minimum chunk size
	and	edx,0xFFFFFFF0	;edx = align16(new-min-chunk-size)
	and	ebx,0xFFFFFFF0	;ebx = align16(new-max-chunk-size)
;
; edx = min-perfect-chunk-size   ebx = max-perfect-chunk-size
;
bcloop:
	or	esi,esi
	jz	no_perfect_fit	;if esi null pointer, not perfect fit found
	mov	ecx,[esi]	;ecx = address uplink = size of chunk
	cmp	ecx,edx		;excess size (chunk size - needed size) > 0?
	jae	short big_enough ;yes, chunk is big enough
	mov	esi,[esi+8]	;no, get next header upstream
	jmp	bcloop
;
; found big-enough chunk; use if in perfect range, else see if best so far
;
big_enough:
	cmp	ebx,ecx		;max-perfect-size - this-chunk-size
	jae	short perfect_fit ;chunk size is between max and min: perfect
	cmp	dword ptr [ebp-12],0 ;has a big-enough chunk already been found?
	jnz	pick_best_fit ;yes, see if new chunk better fit than old
;
; large enough chunk, but not perfect size
;
best_so_far:
	mov	[ebp-12],esi	;save address of header of current chunk
	mov	[ebp-16],ecx	;save size of current chunk
	mov	esi,[esi+8]	;esi -> next chunk upstream
	jmp	bcloop
;
; chunk is perfect size: unlink this chunk from size-links
; esi -> header

perfect_fit:
	mov	edi,[esi+8]	;edi -> size-upstream header
	mov	ecx,[_##WHOMASK]	;ecx = system/user bit in info word
; or	ecx,0x80000001	;ecx = "allocated"	; xxx add
or	ecx,0x0001	;one byte per element	; xxx add
bts	[esi+4],31	;mark as allocated	; xxx add
jnc	short blockOk2	;previously allocated	; xxx add
;;
call	%_eeeAllocation	;block allocated	; xxx add
xor	esi,esi		;return null pointer	; xxx add
ret						; xxx add
;						; xxx add
blockOk2:					; xxx add
	mov	eax,[esi+12]	;eax -> size-downstream header
	or	edi,edi		;is there a header size-upstream?
	jz	short no_up	;nope
	mov	[esi+12],ecx	;mark this header allocated
	or	eax,eax		;is there a header size-downstream?
	jz	short no_down_yes_up ;nope
;
; valid header size-downstream, valid header size-upstream
;
yes_down_yes_up:
	mov	ebx,[ebp-4]	;ebx = requested size
	mov	[eax+8],edi	;SD header -> SU header
	mov	[edi+12],eax	;SU header -> SD header
	mov	[esi+8],ebx	;this header word2 = requested size
	mov	esp,ebp
	pop	ebp
	ret
;
; no valid header size-downstream, valid header size_upstream
;
no_down_yes_up:
	mov	eax,[ebp-4]	;eax = requested size
	mov	[%pointers+0x40],edi ;pointer -> size-upstream header
	mov	dword ptr [edi+12],0 ;mark size-upstream header as 1st in size-links
	mov	[esi+8],eax	;this header word2 = requested size
	mov	esp,ebp
	pop	ebp
	ret
;
; no valid header size-upstream
;
no_up:
	mov	[esi+12],ecx	;mark this header allocated
	or	eax,eax		;is there a header size-downstream?
	jz	short no_down_no_up ;nope
;
; valid header size-downstream, no valid header size_upstream
;
yes_down_no_up:
	mov	ebx,[ebp-4]	;ebx = size requested
	mov	dword ptr [eax+8],0 ;downstream header is last in size-links
	mov	[esi+8],ebx	;this header word2 = requested size
	mov	esp,ebp
	pop	ebp
	ret
;
; no valid header size-downstream, no valid header size-upstream
;
no_down_no_up:
	mov	eax,[ebp-4]	;eax = requested size
	mov	[%pointers+0x40],edi ;zero pointer (no big chunks left)
	mov	[esi+8],eax	;header word2 = requested size
	mov	esp,ebp
	pop	ebp
	ret
;
; chunk bigger than optimum; see if better fit (smaller) than previous best
;
pick_best_fit:
	cmp	ecx,[ebp-16]	;this-size - prev-best-size
	jb	best_so_far 	;if this size < prev best, we have new best
	mov	esi,[esi+8]	;esi -> next size-upstream header
	jmp	bcloop
;
; no perfect big chunk exists; maybe no big-enough big chunks exist
;
no_perfect_fit:
	mov	edi,[ebp-12]	;edi -> best big-enough chunk found
	or	edi,edi		;was any chunk found at all?
	jz	none_big_enough ;nope
	mov	ecx,[edi+12]	;ecx -> size-downstream header
;
; a big-enough chunk was found, though none in perfect size range
;
	mov	ebx,[edi+8]	;ebx -> size-upstream header
	jecxz	short first_biggie ;if ecx = 0, then found 1st in big-chunk list
;
; update size-links in size-downstream/upstream headers to unlink this chunk
; unlink this header
;
not_first_biggie:
	mov	[ecx+8],ebx	;link SD header to SU header
	or	ebx,ebx		;if ebx = 0, no size-upstream chunks exist
	jz	short no_upsize
	mov	[ebx+12],ecx	;link SU header to SD header
no_upsize:
	mov	eax,[_##WHOMASK]	;eax = system/user bit in info word
; or	eax,0x80000001	;eax = "allocated"	; xxx del
or	eax,0x0001	; one byte per element	; xxx add
bts	[edi+4],31	;mark as allocated	; xxx add
jnc	short blockOk3	;previously allocated	; xxx add
;;
call	%_eeeAllocation	;block allocated	; xxx add
xor	esi,esi		;return null pointer	; xxx add
ret						; xxx add
;						; xxx add
blockOk3:					; xxx add
	mov	[edi+8],ebx	;size-uplink = 0
; mov	[edi+12],eax	;mark chunk allocated	; xxx del
mov	[edi+12],eax	;one byte per element	; xxx add
	jmp	short chop_too_biggie ;break big chunk: allocate lower,
				      ; free higher
;
; best-fit chunk is 1st chunk:  update pointer and header to unlink it
;
first_biggie:
	mov	eax,[_##WHOMASK]	;eax = system/user bit in info word
; or	eax,0x80000001	;eax = "allocated"	; xxx del
or	eax,0x0001	;1 byte per element	; xxx add
bts	[edi+4],31	;mark as allocated	; xxx add
jnc	short blockOk4	;previously allocated	; xxx add
;;
call	%_eeeAllocation	;block allocated	; xxx add
xor	esi,esi		;return null pointer	; xxx add
ret						; xxx add
;						; xxx add
blockOk4:					; xxx add
	mov	[edi+8],0	;size-uplink = 0
; mov	[edi+12],eax	;mark chunk allocated	; xxx del
mov	[edi+12],eax	;1 byte per element	; xxx add
	mov	[%pointers+0x40],ebx ;big-chunk pointer = size-upstream address
	or	ebx,ebx		;is there a size-upstream block?
	jz	short chop_too_biggie ;no, skip ahead to chopping routine
	mov	[ebx+12],0	;zero size-downlink of next chunk (new 1st)
;
; divide too-big chunk in two, allocate low part, free high part
;
; entry:  edx      = minimum perfect chunk size
;	  edi      -> this chunk
;	  ebp[-16] = size of this chunk
;
chop_too_biggie:
	lea	esi,[edi+edx]	;esi -> new free chunk
	mov	[esi+4],edx	;put address downlink in new free chunk
	mov	eax,[ebp-16]	;eax = size of chunk to break up
	mov	ebx,eax		;save for later
	sub	eax,edx		;eax = size of new free chunk
	jns	short duh5	;DEBUG
;	int	3		;block allocated	; xxx del
	call	%_eeeAllocation	;block allocated	; xxx add
duh5:				;DEBUG
	mov	[esi],eax	;put address up-link in new free chunk
	mov	[edi],edx	;put address up-link in this chunk
	add	ebx,edi		;ebx -> header above new free chunk
bts	eax,31		;eax = addr-down-link + allocated bit	; xxx add
	mov	[ebx+4],eax	;put address downlink in header above new free
btr	eax,31		;restore eax				; xxx add
;
; compute pointer # to size-link the new free header
;
	sub	eax,17		;eax = size of new free chunk - 1
	mov	ecx,eax
	slr	eax,4		;eax = pointer # for small chunk
	and	ecx,0xFFFFFF00	;free chunk <= 256 bytes?
	jz	short mini_chunk ;yes, a small chunk is adequate
	mov	eax,16		;eax = pointer # for big chunk
;
; size-link new free block to pointer and next size up-link header
;
mini_chunk:
	mov	ebx,[%pointers+eax*4] ;ebx -> first header of this size
	mov	[%pointers+eax*4],esi ;update pointer to point to new free chunk
	mov	[esi+8],ebx	;put size-upstream address into new header
	mov	[esi+12],0	;zero size-downstream in new free header
	or	ebx,ebx		;is there an upstream header?
	jz	short up_nope	;nope
	mov	[ebx+12],esi	;put size-downlink into size-uplink header
up_nope:
	mov	eax,[ebp-4]	;eax = requested size
	mov	esi,edi		;esi -> allocated header
	mov	[esi+8],eax	;header word2 = requested size
	mov	esp,ebp
	pop	ebp
	ret
;
;
; **********************
; *****  recalloc  *****  reallocate chunk at addr(a) for n bytes, zero excess
; **********************
;
; *****  recalloc  *****  C entry point  and  XBASIC entry point
;
;   in:	arg1 = new size
;	arg0 = current address of block to re-size
;  out:	eax -> new block, or NULL if none or error
;
; local variables:
;	[ebp-4] = old # of bytes in object
;	[ebp-8] = new # of bytes in object
;
recalloc:
_recalloc:
__recalloc:
_Xrecalloc:
___recalloc:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	push	ebx
	push	esi
	push	edi

	mov	esi,[ebp+8]	;esi -> DATA area of chunk to recalloc
	sub	esi,0x10	;esi -> HEADER of chunk to recalloc
	mov	ebx,[esi+8]	;ebx = old # of elements
;replace following two instructions with movzx eax,[esi+12]?
	mov	eax,[esi+12]	;eax = old info word
	and	eax,0xFFFF	;eax = old # of bytes per element
	imul	ebx,eax		;ebx = old # of bytes in object
	mov	eax,[ebp+12]	;eax = new # of bytes in object
	mov	[ebp-4],ebx	;save old # of bytes in object
	mov	[ebp-8],eax	;save new # of bytes in object
;
	add	esi,0x10	;esi -> DATA area of chunk to recalloc
	mov	edi,eax		;edi = new # of bytes in object
	call	%____realloc	;re-size the chunk (preserving current data)
;
	or	esi,esi		;couldn't allocate memory?
	jz	short recalloc_error
	cmp	esi,-1		;tried to recalloc a non-allocated block?
	jne	short recalloc_ok
	xor	esi,esi		;indicate error so that C can understand it
	jmp	short recalloc_error
;
recalloc_ok:
	mov	ebx,[ebp-4]	;restore old # of bytes in object
	mov	eax,[ebp-8]	;restore new # of bytes in object
	call	zero.excess	;zero chunk after last active byte
recalloc_error:
	mov	eax,esi
	pop	edi
	pop	esi
	pop	ebx
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *****  zero.excess  *****  zero chunk
;
;   in:	esi -> data area of realloc'ed chunk
;	ebx = old # of bytes in object
;	eax = new # of bytes in object
;  out:	esi -> data area of recalloc'ed chunk (same as on input)
;
; destroys: eax, ebx, ecx, edx, edi
;
zero.excess:
	or	esi,esi		; new size = empty ???
	jz	zero.done	; yes - nothing to zero
;
	cmp	ebx,eax		;if old # of bytes < new # of bytes
	jae	short zero.skip	;then use old
	mov	eax,ebx		;eax = old # of bytes = # to leave alone
;
zero.skip:
	lea	edi,[esi+eax]	;edi -> where to start zeroing
	mov	ecx,[esi-16]	;ecx = size of chunk including header
	sub	ecx,0x10	;ecx = size of chunk excluding header
	sub	ecx,eax		;ecx = size of chunk - # to leave alone =
				; # of bytes to zero
	jbe	short zero.done	;if negative or none, no excess and no zeroing
	xor	eax,eax		;ready to write some zeros
	cld			;make sure we write them in the right direction
;
q.zero.byte:
	test	edi,1		;if bit 0 == 0 then no bytes to zero
	jz	short q.zero.word
	stosb			;write a zero byte
	dec	ecx		;ecx = # of bytes left to zero
	jz	short zero.done
q.zero.word:
	test	edi,2		;if bit 1 == 0 then no words to zero
	jz	short q.zero.dwords
	stosw			;write two zero bytes
	sub	ecx,2		;ecx = # of bytes left to zero
	jz	short zero.done
q.zero.dwords:
	slr	ecx,2		;ecx = # of dwords to zero
	jecxz	zero.done	;skip if nothing left to zero
	rep
	stosd			;write zeros, four bytes at a time
;
zero.done:
	ret
;
;
; **********************
; *****  recalloc  *****  reallocate chunk at addr(a) for n bytes, zero excess
; **********************
;
; *****  recalloc  *****  internal entry point
;
;   in:	esi -> data area of block to resize
;	edi = requested new number of bytes
;  out:	esi -> new block, NULL if esi was NULL on entry, or -1 if error
;
; destroys: edi
;
; local variables:
;	[ebp-4] = old # of bytes in object
;	[ebp-8] = new # of bytes in object
;
%____recalloc:
	or	esi,esi		; null pointer?
	jz	short rc_null	; yes: calloc instead

	push	ebp
	mov	ebp,esp
	sub	esp,8
	push	eax
	push	ebx
	push	ecx
	push	edx
;
	mov	ebx,[esi-8]	;ebx = old # of elements
;
; replace following two instructions with movzx eax,[esi+12] ???
;
	mov	eax,[esi-4]	;eax = old info word
	and	eax,0xFFFF	;eax = old # of bytes per element
	imul	ebx,eax		;ebx = old # of bytes in object
	mov	[ebp-4],ebx	;save old # of bytes in object
	mov	[ebp-8],edi	;save new # of bytes in object
;
	call	%_____realloc	;re-size the chunk (preserving current data)
	cmp	esi,-1		;tried to recalloc a non-allocated block?
	je	short rc_error	;yes: abort
;
	mov	ebx,[ebp-4]	;restore old # of bytes in object
	mov	eax,[ebp-8]	;restore new # of bytes in object
	call	zero.excess	;zero chunk after last active byte
;
rc_error:
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	mov	esp,ebp
	pop	ebp
	ret
;
rc_null:
	mov	esi,edi		;esi = requested number of bytes
	call	%____calloc
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
;
;
; *********************
; *****  realloc  *****  reallocate chunk at addr(a) for n bytes
; *********************
;
; *****  realloc  *****  C entry point  and  XBASIC entry point
;
;   in:	arg1 = new size
;	arg0 = current address of block to re-size
;  out:	eax -> new block, or NULL if none or error
;
; Stores new size into # of elements in header of new block.
;
realloc:
_realloc:
__realloc:
_Xrealloc:
___realloc:
	push	ebp
	mov	ebp,esp
	push	ebx
	push	esi
	push	edi
;
	mov	esi,[ebp+8]	;esi -> current block (data, not header)
	mov	edi,[ebp+12]	;edi = new size
	call	%_____realloc
	mov	eax,[ebp+12]	;eax = new size
	mov	[esi-8],eax	;write new size into new block
	mov	eax,esi		;eax -> new block, or NULL if none
;
	pop	edi
	pop	esi
	pop	ebx
;
	cmp	eax,-1		;was there an error?
	jne	short _realloc_ret ;no: just return normally
	xor	eax,eax		;yes: change return value to NULL
_realloc_ret:
	pop	ebp
	ret
;
;
; *****  realloc  *****  CORE ROUTINE  *****
;
;  in:	esi = DATA address of chunk to reallocate
;	edi = requested new size of block
; out:	esi = new DATA address of block, or NULL if no memory, or -1 if
;	      attempted to re-allocate a non-allocated block
;
; %____realloc destroys: edi
; %_____realloc  destroys: eax, ebx, ecx, edx, edi
;
; Local variables:
;	[ebp-4] = header of chunk to reallocate
;	[ebp-8] = requested new size of block
;	[ebp-12] = register spill
;
; It is the caller's responsibility to fill in the info word and # of
; elements in the new block.
;
%____realloc:
	push	eax
	push	ebx
	push	ecx
	push	edx
	call	%_____realloc
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	ret
;
;
%_____realloc:
	push	ebp
	mov	ebp,esp
	sub	esp,12
;
	sub	esi,16		;esi -> header of block to re-size
	or	edi,edi		;is requested size 0?
	jz	refree		;yes: just free the block
;
; check for out-of-bounds request address
;
	cmp	[_##DYNO],esi	;addr(1st header) > addr(request)?
	ja	short redisaster ;if so, it's a disastrous error
	cmp	[_##DYNOX],esi	;addr(last header) < addr(request)?
	jb	short redisaster ;if so, it's another disastrous error
;
; mov	eax,[esi+12]	;eax = negative if allocated	; xxx del
	mov	[ebp-4],esi	;save pointer to header of block
	mov	[ebp-8],edi	;save requested new size
; or	eax,eax		;is block allocated?		; xxx del
; js	short recheck	;yes: reallocate it		; xxx del
bt	[esi+4],31	;see if allocated		; xxx add
jc	short recheck	;yes: reallocate it		; xxx add
;				;no: fall through to error routine
redisaster:
	mov	esi,-1		;indicate that there was an error
	mov	esp,ebp
	pop	ebp
	ret
;
; also: re-enter here after freeing higher free block, if applicable
;
recheck:
	mov	eax,edi		;eax = requested new size
	dec	eax		;eax = requested size - 1
	jns	short not_null	;if requested size != 0, compute pointer #
	inc	eax		;else set eax back to zero
not_null:
	mov	edi,eax		;edi = requested size - 1
	and	eax,0xFFFFFFF0	;eax = data size needed - 16
	add	eax,0x20	;eax = size needed including header
	mov	ebx,[esi+0]	;ebx = size of chunk now
	and	edi,0xFFFFFF00	;edi = 0 if required chunk <= 256 bytes
	jnz	need_big_one	;separate algorithm for size > 256 bytes
	sub	ebx,eax		;ebx = excess size of current chunk
	jb	short need_more	;if excess size < 0, need bigger chunk
;
; current chunk is too big or just right
;
	lea	ecx,[esi+eax]	;ecx = addr(excess part of this chunk)
	cmp	ebx,0x20	;plus 32 bytes for another header/data?
	jae	short current_too_big ;yes, so turn high portion into free area
;
; current chunk is perfect... leave it alone, return its address
;
perfectoid:
	add	esi,16		;esi -> DATA area of reallocated chunk
	mov	esp,ebp
	pop	ebp
	ret
;
; current chunk is too big; make a new chunk (H) above and re-size this one (M)
;
current_too_big:
	mov	[esi+0],eax	;addr-uplink(M) = new-size(M)
	mov	[ecx+0],ebx	;addr-uplink(H) = size(H)
bts	eax,31		;mark H as allocated		; xxx add
	mov	[ecx+4],eax	;addr-downlink(H) = new-size(M)
btr	eax,31		;restore eax			; xxx add
	mov	edi,[_##WHOMASK]	;edi = system/user bit in info word
; or	edi,0x80000001	;edi = allocated marker		; xxx del
; mov	[ecx+12],edi	;write allocated marker to H	; xxx del
or	edi,0x0001	;edi = 1 byte per element	; xxx add
mov	[ecx+12],edi	;create info word in H		; xxx add
	lea	edx,[ecx+ebx]	;edx -> XH
mov	esi,[edx+4]	;esi = XH addr-down-link	; xxx add
and	esi,0x80000000	;remove all but alloc bit	; xxx add
or	esi,ebx		;esi = alloc bit OR size(H)	; xxx add
mov	[edx+4],esi	;add-downlink(XH) = size(H)	; xxx add
; mov	[edx+4],ebx	;addr-downlink(XH) = size(H)	; xxx del
	mov	esi,ecx		;esi -> new chunk
	call	%____Hfree	;free the new chunk (H) (possible merge with XH)
;
; after H is freed, return address of shrunk chunk
;
	mov	esi,[ebp-4]	;esi -> shrunk chunk
	add	esi,0x10	;esi -> DATA area of shrunk chunk
	mov	esp,ebp
	pop	ebp
	ret
;
; need a bigger chunk
; see if the next higher chunk is free and large enough
;  to provide sufficient room by merging with this chunk
;
need_more:
	mov	ebx,[esi+0]	;ebx = size of this chunk (M) now
	lea	edi,[ebx+esi]	;edi -> next higher chunk (H)
	mov	ecx,[edi+12]	;ecx = size-downlink(H)
	mov	edx,[edi+0]	;edx = size(H)
bt	[edi+4],31	;if H is allocated, can't use H space	; xxx add
jc	short not_enough
; or	ecx,ecx		;if ecx is "allocated", can't use H	; xxx del
; js	short not_enough					; xxx del
;
; H is free; is it too small, just right, or too big to expand into?
;
	add	edx,ebx		;edx = size(M) + size(H)
	cmp	edx,eax		;is excess size of M+H less than zero?
	jb	short not_enough ;yes: not enough space here
;
;note: previous instruction was bcnd.n in 88000 version; I'm translating
;it as if it were bcnd
;
; size(M+H) is at least enough to fill request; graft H onto top of M
; address-unlink H from M and XH (address link M <==> H)
;
;	mov	[ebp-12],eax	;spill eax for a moment
	lea	eax,[esi+edx]	;eax = addr(XH) = addr(M) + size(M+H)
bts	edx,31		;XH is allocated		; xxx add
	mov	[eax+4],edx	;addr-downlink(XH) = size(M+H)
btr	edx,31		;restore edx = size		; xxx add
	mov	[esi+0],edx	;addr-uplink(M) = size(M+H)
	mov	[ebp-12],eax	;spill eax: [ebp-12] = addr(XH)
;
; H is now address-unlinked; size-unlink it now
;
	mov	eax,[edi+8]	;eax = size-uplink(H)
	or	ecx,ecx		;is size-downlink(H) != 0?
	jne	short down_not_ptr ;yes: H is not 1st chunk of its size
;
; size-downstream from H is the pointer, not another chunk
;
	mov	ebx,[edi+0]	;ebx = size(H)
	sub	ebx,17		;ebx = size(H) - 17  (size of data - 1)
	slr	ebx,4		;ebx = (size-1) / 16 = pointer #
	cmp	ebx,16		;pointer # is beyond big-chunk pointer?
	jbe	short small_guy	;no, ebx is ok
	mov	ebx,16		;ebx = big-chunk pointer #
small_guy:
	mov	edi,[ebp-8]	;edi = original size request
	mov	[%pointers+ebx*4],eax ;pointer = addr(SU(H))
	or	eax,eax		;is there no SU(H)?
	jz	recheck		;nope: skip next instruction
	mov	[eax+12],ecx	;size-downlink(SU(H)) = addr(SD(H))
	jmp	recheck
;
down_not_ptr:
	mov	edi,[ebp-8]	;edi = original size request
	mov	[ecx+8],eax	;size-uplink(SD(H)) = addr(SU(H))
	or	eax,eax		;is there no SU(H)?
	jz	recheck		;nope: skip next instruction
	mov	[eax+12],ecx	;size-downlink(SU(H)) = addr(SD(H))
	jmp	recheck
;
; H is now address-linked and size-unlinked; branch back to recheck fit
;
; not enough space in M for reallocation; get a new block to allocate
;
not_enough:
	mov	esi,[ebp-8]	;esi = original size request
	call	%_____malloc	;let malloc find a new block
;
; CORE malloc returns HEADER address of allocated chunk in esi
;
	mov	edi,[ebp-4]	;edi = header address of original chunk
	mov	ecx,[edi+0]	;ecx = total size of original chunk
	mov	edx,[edi+8]	;edx = word2 from original chunk
	mov	ebx,[edi+12]	;ebx = word3 from original chunk
	mov	eax,edi		;eax = header address of original chunk
	mov	[ebp-4],esi	;save new allocated address
	mov	[esi+8],edx	;new chunk's word2 = old chunk's word2
	mov	[esi+12],ebx	;new chunk's word3 = old chunk's word3

	sub	ecx,0x10	;start copy 16 words into it (i.e. skip header)
	xchg	esi,edi		;esi -> original chunk; edi -> new chunk
	add	esi,0x10	;esi -> original chunk's data area
	add	edi,0x10	;edi -> new chunk's data area
	add	ecx,3
	slr	ecx,2		;divide size by 4 (# of bytes in dword)
	cld			;make sure direction is right
	jecxz	short recalloc_skip
	rep
	movsd			;copy original data area to new data area
recalloc_skip:
;
; original data has been moved to new destination; free original chunk
;
	mov	esi,eax		;esi = address of original chunk
	call	%____Hfree	;free original chunk
;
; original chunk is free; return address of new chunk containing original data
;
	mov	esi,[ebp-4]	;esi -> header of new chunk
another_perfectoid:		;same as perfectoid; label allows short branch
	add	esi,0x10	;esi -> data area of new chunk
	mov	esp,ebp
	pop	ebp
	ret
;
; need a big chunk to reallocate the chunk size requested
;
; esi = address of chunk to realloc
; ebx = chunk size now, including header (mod 16 size)
; eax = chunk size needed, including header (mod 16 size)
;
need_big_one:
	mov	edi,ebx
	sub	edi,eax		;edi = (size now - size needed) = excess size
	js	need_more	;if excess < 0 then need a bigger chunk
;previous instruction was bcnd.n; I'm translating it as if it were bcnd
	mov	edx,edi
	sll	edx,1		;edx = excess * 2
	cmp	edx,eax		;is size-now < 1.5 times size-needed?
	jb	short another_perfectoid ;yes: leave as is
;previous instruction was bcnd.n; I'm translating it as if it were bcnd
	mov	edx,eax
	slr	edx,3		;edx = .125 * size needed
	add	eax,edx		;eax = 1.125 * size needed (size to make it)
	and	eax,0xFFFFFFF0	;eax = mod 16 size of reallocated chunk
	lea	ecx,[esi+eax]	;ecx = address of H chunk to create/free
	sub	ebx,eax		;ebx = excess size of existing = size(new H)
	jmp	current_too_big
;
refree:
	call	%____Hfree	;free chunk being realloc'ed tp zero size
	xor	esi,esi		;return zero
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ******************
; *****  free  *****  frees a chunk of memory
; ******************
;
; *****  free  *****  C entry point  and  XBASIC entry point
;
;  in: arg0 -> block to free
; out: random value in eax
;
free:
_free:
__free:
_Xfree:
___free:
	push	ebp
	mov	ebp,esp
	sub	esp,8		;allocate frame for core routine
;
	cmp	[ebp+8],0	;we were given a null pointer?
	jz	short cfree0	;then don't try to free anything
	push	ebx
	push	esi
	push	edi
	mov	esi,[ebp+8]	;esi -> data block to free
	sub	esi,16		;esi -> its header
	mov	[ebp-4],-1	;indicate that %_____free is being called from C
	call	%_____free
	pop	edi
	pop	esi
	pop	ebx
cfree0:
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***********************
; *****  %____free  *****  internal entry point to %_____free
; ***********************
;
;  in: esi = data address of chunk to free
; out: esi = 0 if error or tried to free null pointer, != 0 if ok
;
; destroys: edi
;
; Allocates frame for %_____free and puts a zero at [ebp-4] to indicate
; that %_____free was not called (directly) from C.
;
%____free:
	or	esi,esi		;trying to free null pointer?
	jz	short fret	;yes: skip the free
	push	ebp
	mov	ebp,esp
	sub	esp,8

	push	eax
	push	ebx
	push	ecx
	push	edx

	sub	esi,16
	mov	[ebp-4],0
	call	%_____free

	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp,ebp
	pop	ebp
fret:
	ret
;
;
; ************************
; *****  %____Hfree  *****  internal entry point to %_____free
; ************************
;
;  in: esi = header address of chunk to free
; out: esi = 0 if error or tried to free null pointer, != 0 if ok
;
; destroys: eax, ebx, ecx, edx, edi
;
; Allocates frame for %_____free and puts a zero at [ebp-4] to indicate
; that %_____free was not called (directly) from C.
;
; %____Hfree is exactly the same as %____free except that on entry,
; esi -> the header of the block to free, not the block's data area.
;
%____Hfree:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov	[ebp-4],0
	call	%_____free

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *****  free  *****  CORE ROUTINE  *****
;
;  in: esi = header address of chunk to free
;      ebp -> top of 8-byte local frame, which must already have been allocated
;      [ebp-4] = -1 if called from C entry point, 0 if not
; out: esi = 0 if error or tried to free null pointer, != 0 if ok
;
; destroys: eax, ebx, ecx, edx, edi
;
; Local variables:
;	IMPORTANT: assumes that caller has already allocated 8-byte frame
;	-4	-1 if called from C entry point, 0 if not
;	-8	buffer for short error message to print
;
%_____free:
	or	esi,esi		;null pointer?
	jz	short free_exit	;if so, nothing to free
	mov	eax,[esi+4]	;eax = offset to L header	; 05/01/93
	or	eax,eax		;eax = 0 if literal string	; 05/01/93
	jz	short free_exit	;if literal string, don't free	; 05/01/93
btr	eax,31		;clear allocated bit			; xxx add
mov	[esi+4],eax	;mark block free			; xxx add
jnc	short serious	;block already free			; xxx add
;
; NOTE: I'm skipping the test code in the original (for now, anyway)
;
	mov	ebx,'x'
	cmp	[_##DYNO],esi	;is addr(1st header) > addr(request)?
	ja	short serious	;if so, it's a serious error
	inc	ebx		;ebx = 'y'
	cmp	[_##DYNOX],esi	;is addr(last header) < addr(request)?
	jb	short serious	;if so, it's a serious error
;
	mov	eax,[esi]	;eax = offset to H header
	add	eax,esi		;eax -> H header
	mov	ecx,[esi+4]	;ecx = offset to L header
	btr	ecx,31		;assure positive offset		; xxx add
	neg	ecx
	add	ecx,esi		;ecx -> L header
;	jns	short duh6	;DEBUG
;	call	%_eeeAllocation	;block allocated		; xxx add
;duh6:				;DEBUG
	inc	ebx		;ebx = 'z'
; mov	edx,[esi+12]	;edx = info word			; xxx del
; or	edx,edx		;block already free?			; xxx del
; jns	short serious	;it's already free: serious error	; xxx del
	mov	ebx,[eax+12]	;ebx -> H's info word
	jmp	short ok_to_free
;
; attempt to free an already free chunk reveals a serious allocation bug!
;
serious:
	cmp	dword ptr [ebp-4],0 ;non-zero if called from a C function
	jnz	short Csucks	;if C function, go complain on stderr
;	mov	dword ptr [_##XERRADDR],0 ;_##XERRADDR = return address
;				; (zero until we figure out what to do with
;				; this)
;	mov	dword ptr [_##XERRINFO],esi ;_##XERRINFO = address of already-
;				; free chunk
;	call	%_eeeAllocation	;block allocated	; xxx add
	xor	esi,esi		;return null pointer because of error
free_exit:
	ret
;
; report C functions trying to free garbage
;
; entry: ebx = 'x', 'y', or 'z', depending on where error was detected
;
Csucks:
;	lea	eax,[ebp-8]	;eax -> output buffer
;	mov	[eax],bl	;put 'x', 'y', or 'z' in buffer
;	push	0		; ntntnt
;	push	esp		; ntntnt
;	push	1		; number of bytes to write
;	push	eax		; pointer to buffer
;	push	1		; file descriptor for stdout (stderr someday)
;	call	_XxxWriteFile@20	; ;;; ntntnt
;	call	_write		; print the 'x', 'y', or 'z'
;;;	add	esp,20		; ntntnt
;
	call	%_eeeAllocation	;block allocated	; xxx add
	xor	esi,esi		;return null pointer because of error
	ret
;
; okay to free M chunk; merge with H and/or L chunks if they're free
;
; entry: eax -> H header
;	 ebx -> H's info word
;	 ecx -> L header
;
ok_to_free:
	mov	edx,[ecx+12]	;edx = L's info word
; or	ebx,ebx		;is H allocated?	; xxx del
; js	hi_not		;yes			; xxx del
or	ebx,ebx		;is H info word = 0?	; xxx add  (necessary !!!)
bt	[eax+4],31	;is H allocated?	; xxx add
jc	hi_not		;yes
;			;no: H info word (ebx) is really size-downlink
;
; H chunk is free; unlink it, and then check L chunk
;
	mov	edi,[eax+8]	;edi = size-uplink of H
	jz	short down_pointer ;skip ahead if H's size-downlink null pointer
	mov	dword ptr [eax+8],0 ;size-uplink(H) = 0, i.e. mark unlinked
	mov	[ebx+8],edi	;size-uplink(SD(H)) -> SU(H)
	or	edi,edi		;is SU(H) a null pointer?
	jz	short q_lower	;yes, we have no size-uplink
	mov	[edi+12],ebx	;size-downlink(SU(H)) -> SD(H)
	jmp	short q_lower	;see if lower is free
;
; the H chunk is 1st in size-links (unlink from pointer on downstream side)
;
down_pointer:
	mov	dword ptr [eax+8],0 ;size-uplink(H) = 0, i.e. mark unlinked
	mov	ebx,[eax]	;ebx = size(H) = addr-uplink(H)
	sub	ebx,17		;ebx = size - 17 (data size - 1)
	slr	ebx,4		;ebx = (size-1) / 16 = pointer #
	cmp	ebx,16		;pointer # is beyond big-chunk pointer?
	jbe	short unlink_small ;no, ebx is ok
	mov	ebx,16		;ebx = big-chunk pointer #
unlink_small:
	mov	[%pointers+ebx*4],edi ;pointer now -> SU(H)
	or	edi,edi		;is SU(H) a null pointer?
	jz	short q_lower	;skip if null pointer, i.e. no SU(H)
	mov	dword ptr [edi+12],0 ;mark SU(H) as 1st in size-links
;
q_lower:
	mov	edi,[ecx+12]	;edi = SD(L)
; or	edx,edx		;is L allocated?			; xxx del
; js	short hi_free_lo_not ;yes, so don't combine it with M	; xxx del
bt	[ecx+4],31	;is L allocated?			; xxx add
jc	short hi_free_lo_not	;yes, so don't combine with M	; xxx add
;
; H is free, L is free: unlink L from size-links of chunks downstream
; and upstream from L
;
; ecx -> L		esi -> M		ebx = trash
; eax -> H		edx -> SD(L)		edi -> SU(L)
;
hi_free_lo_free:
	mov	edx,[ecx+12]	;edx -> SD(L)  [is this necessary?]
	mov	edi,[ecx+8]	;edi -> SU(L)  [is this necessary?]
	or	edx,edx		;is SD(L) null pointer?  [is this necessary?]
	jz	short pointer_down ;if no SD(L), L is first chunk its size
	mov	dword ptr [ecx+8],0 ;SU(L) = 0, i.e. unlinked
	mov	[edx+8],edi	;SU(SD(L)) -> SU(L)
	or	edi,edi		;is SU(L) a null pointer?
	jz	short do_addr	;if SU(L) is null, no SU(L)
	mov	[edi+12],edx	;SD(SU(L)) -> SD(L)
	jmp	short do_addr
;
; the L chunk is 1st in size-links (unlink from pointer on downstream side)
;
pointer_down:
	mov	dword ptr [ecx+8],0 ;SU(L) = 0 (unlinked)
	mov	ebx,[ecx]	;ebx = size(L) = addr-uplink(L)
	sub	ebx,17		;ebx = size - 17 = data size - 1
	slr	ebx,4		;ebx = (size-1) / 16 = pointer #
	cmp	ebx,16		;pointer # is beyond big-chunk pointer?
	jbe	short small_unlink ;no, ebx is ok
	mov	ebx,16		;ebx = big-chunk pointer #
small_unlink:
	mov	[%pointers+ebx*4],edi ;pointer header past L to SU(L)
	or	edi,edi		;is SU(L) a null pointer?
	jz	short do_addr	;if so, there is no SU(L)
	mov	[edi+12],0	;mark SU(L) as 1st in size-links
;
; update address links in L and XH to abolish M and H (merge L, M, H into L)
;
do_addr:
	mov	edi,[eax]	;edi = size(H)
	mov	ebx,eax
	sub	ebx,ecx		;ebx = addr(H) - addr(L) = size(L) + size(M)
	jns	short duh1	;DEBUG
;	int	3		;block allocated	; xxx del
	call	%_eeeAllocation	;block allocated	; xxx add
duh1:				;DEBUG
	add	ebx,edi		;ebx = size(L) + size(M) + size(H)
	mov	[ecx],ebx	;addr-uplink(L) = size(L) + size(M) + size(H)
bts	ebx,31		; XH is allocated	; xxx add
	mov	[eax+edi+4],ebx	;addr-downlink(XH) = new-size(L)
btr	ebx,31		; ebx is down distance	; xxx add
;
; link new L into size-links
;
	mov	esi,ecx		;esi -> chunk to enter in size-links
;	jmp	short hi_not_lo_not	; xxx del
	jmp	hi_not_lo_not		; xxx add
;
;
; the H chunk (above) is free; the L chunk (below) is not free
;

hi_free_lo_not:
	mov	dword ptr [esi+12],0 ;mark this header free
	mov	edi,[eax]	;edi = size(H)
	mov	ebx,eax
	sub	ebx,esi		;ebx = addr(H) - addr(M) = size(M)
	jns	short duh2	;DEBUG
;	int	3		;block allocated	; xxx del
	call	%_eeeAllocation	;block allocated	; xxx add
duh2:				;DEBUG
	add	ebx,edi		;ebx = size(M) + size(H)
	mov	[esi],ebx	;addr-uplink(M) = size(M) + size(H)
;
; go link new L into size-links
;
bts	ebx,31		; XH is allocated	; xxx add
	mov	[eax+edi+4],ebx	;addr-downlink(XH) = new-size(L)
btr	ebx,31		; ebx is down distance	; xxx add
	jmp	short hi_not_lo_not ;addr-uplink and addr-downlink not free now
;
; the H chunk (above) is not free (check the L chunk)
;
hi_not:
; or	edx,edx			;is L header allocated?	; xxx del
; js	short hi_not_lo_not	;yes			; xxx del
bt	[ecx+4],31		;is L header allocated?	; xxx add
jc	short hi_not_lo_not	;yes			; xxx add
;
; the H chunk is not free, the L chunk is free
; unlink L from size-links of chunks downstream and upstream from L
;
hi_not_lo_free:
	mov	dword ptr [esi+12],0 ;mark this header free
	mov	edi,[ecx+8]	;edi = SU(L)
	or	edx,edx		;is SD(L) a null pointer?  [is this necessary?]
	jz	short pointer_case ;yes, L is 1st chunk its size
	mov	[edx+8],edi	;SU(SD(L)) = SU(L)
	or	edi,edi		;is SU(L) a null pointer?
	jz	short addr_do	;yes, we have no SU(L)
	mov	[edi+12],edx	;SD(SU(L)) = SD(L)
	jmp	short addr_do
;
; the L chunk is 1st in size-links (unlink from pointer on downstream side)
;
pointer_case:
	mov	ebx,[ecx]	;ebx = size(L) = addr-uplink(L)
	sub	ebx,17
	slr	ebx,4		;ebx = (size-1) / 16 = pointer #
	cmp	ebx,16		;pointer # is beyond big-chunk pointer?
	jbe	short wimpy_unlink ;no, ebx is ok
	mov	ebx,16		;ebx = big-chunk pointer #
wimpy_unlink:
	mov	[%pointers+ebx*4],edi ;point header past L to size-uplink(L)
	or	edi,edi		;is SU(L) null pointer?
	jz	short addr_do	;yes, we have no SU(L)
	mov	dword ptr [edi+12],0 ;mark SU(L) as 1st in size-links
;
; update address links in L to abolish M  (merge L, M, into L)
;
addr_do:
	mov	edi,eax
	sub	edi,ecx		;edi = addr(H) - addr(L) = new-size(L)
	jns	short duh3	;DEBUG
;	int	3		;block allocated	; xxx del
	call	%_eeeAllocation	;block allocated	; xxx add
duh3:				;DEBUG
	mov	[ecx],edi	;addr-uplink(L) = new-size(L)
bts	edi,31			;mark H allocated	; xxx add
	mov	[eax+4],edi	;addr-downlink(H) = new-size(L)
btr	edi,31			;restore edi		; xxx add
	mov	esi,ecx		;esi -> L (prepare to put L in size-links)
;
; the H chunk is not free, the L chunk is not free
;
hi_not_lo_not:
	mov	dword ptr [esi+12],0 ;mark this header free
	mov	ebx,[esi]	;ebx = size(M) = addr-uplink(M)
	sub	ebx,17
	slr	ebx,4		;ebx = (size-1) / 16 = pointer #
	cmp	ebx,16		;pointer # is beyond big-chunk pointer?
	jbe	short free_any	;no, ebx is ok
	mov	ebx,16		;ebx = big-chunk pointer #
free_any:
	mov	eax,[%pointers+ebx*4] ;eax -> 1st header of this sie
	mov	[%pointers+ebx*4],esi ;pointer -> this header
	mov	[esi+8],eax	;size-uplink(M) = size-uplink(pointer)
	or	eax,eax		;was old pointer null?
	jz	short no_upstream ;in that case, there's no upstream header
	mov	[eax+12],esi	;size-downlink(size-upstream) -> M
no_upstream:
	mov	dword ptr [esi+12],0 ;SD(M) = 0 (mark as 1st this size)
	ret
;
;
.text
;
; #####################
; #####  xlib1.s  #####  Clone and concatenate routines
; #####################
;
; ************************
; *****  %_clone.a0  *****  clones object pointed to by eax
; ************************
;
; in:	eax -> object to clone
; out:	eax -> cloned object
;
; Destroys: edx, esi, edi.
;
; Returns 0 in eax if eax was 0 on entry or if size of object to clone is 0.
;
; %_clone.a0 was called %_clone.object.return.addr.a0 in the 88000 version.
;
%_clone.a0:
or	eax,eax		;were we passed a null pointer?
jz	short xret	;yes: get out of here
push	ebx		;must not trash ebx (accumulator 1)
push	ecx		;ecx is part of accumulator 1
;;
movzx	ebx,word ptr [eax-4] ;ebx = # of bytes per element
mov	esi,[eax-8]	;esi = # of elements
or	esi,esi		; test esi for 0x00  (zero elements)
jnz	ok.a0		; object not empty
pop	ecx		; restore ecx
pop	ebx		; restore ebx
ret			; done
;
ok.a0:
mov	edx,esi		;save # of elements for later
imul	esi,ebx		;esi = size of object to clone
or	esi,esi		;imul leaves ZF in a random state!
jz	clone.a0.null	;if object is zero len, quit and return null ptr
;;
push	esi		;save # of bytes for rep movsd, later
inc	esi		;add one to size, for terminator (is this
push	eax		; necessary?)
push	edx
call	%____calloc	;esi -> data area of new block
pop	edx
pop	eax
pop	ecx		;ecx = # of bytes for rep movsd
;;
mov	ebx,[eax-4]	;ebx = info word of original object
btr	ebx,24		;ebx
or	ebx,[_##WHOMASK]	;OR whomask into info word
;;
mov	[esi-4],ebx	;store (old_infoword | whomask) to new infoword
mov	[esi-8],edx	;store old # of elements to new object's header
;;
mov	ebx,esi		;save pointer to new block for later
mov	edi,esi		;edi -> data area of new block
mov	esi,eax		;esi -> data area of old block
add	ecx,3		;round # of bytes to move up to next
;;			; four-word boundary
slr	ecx,2		;ecx = # of dwords to move
cld			;make sure direction is right
rep
movsd			;clone it!
;;
mov	eax,ebx		;eax -> cloned object's data area
pop	ecx
pop	ebx
ret
;
clone.a0.null:
xor	eax,eax		;return null pointer
pop	ebx
pop	ecx
;;
xret:
ret
;
;
; ************************
; *****  %_clone.a1  *****  clones object pointed to by eax
; ************************
;
; in:	ebx -> object to clone
; out:	ebx -> cloned object
;
; Destroys: esi, edi.
;
; Returns 0 in ebx if ebx was 0 on entry or if size of object to clone is 0.
;
; %_clone.a1 is the same as %_clone.a0, except that its input and output
; values are in ebx, not eax.
;
; %_clone.a1 was called %_clone.object.return.addr.a1 in the 88000 version.
;
%_clone.a1:
push	edx
xchg	eax,ebx
call	%_clone.a0
xchg	eax,ebx		;isn't this silly?
pop	edx
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.vv  ***** concatenates two permanent
; ********************************************** variables
;
; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a0.plus.a1.vv:
%_concat.string.a0.eq.a0.plus.a1.vv:
push	eax
push	ebx
push	0		;"vv" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.vs  ***** concatenates permanent and
; ********************************************** temporary variable
;
; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a0.plus.a1.vs:
%_concat.string.a0.eq.a0.plus.a1.vs:
push	eax
push	ebx
push	2		;"vs" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.sv  ***** concatenates temporary and
; ********************************************** permanent variable
;
; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a0.plus.a1.sv:
%_concat.string.a0.eq.a0.plus.a1.sv:
push	eax
push	ebx
push	4		;"sv" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a0.plus.a1.ss  ***** concatenates two temporary
; ********************************************** variables
;
; in:	eax -> first string
;	ebx -> second string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a0.plus.a1.ss:
%_concat.string.a0.eq.a0.plus.a1.ss:
push	eax
push	ebx
push	6		;"ss" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.vv  ***** concatenates two permanent
; ********************************************** variables
;
; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a1.plus.a0.vv:
%_concat.string.a0.eq.a1.plus.a0.vv:
push	ebx
push	eax
push	0		;"vv" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.vs  ***** concatenates permanent and
; ********************************************** temporary variable
;
; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a1.plus.a0.vs:
%_concat.string.a0.eq.a1.plus.a0.vs:
push	ebx
push	eax
push	2		;"vs" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.sv  ***** concatenates temporary and
; ********************************************** permanent variable
;
; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a1.plus.a0.sv:
%_concat.string.a0.eq.a1.plus.a0.sv:
push	ebx
push	eax
push	4		;"sv" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; **********************************************
; *****  concat.ubyte.a0.eq.a1.plus.a0.ss  ***** concatenates two temporary
; ********************************************** variables
;
; in:	eax -> second string
;	ebx -> first string
; out:	eax -> first string + second string
;
; Destroys: ebx, ecx, edx, esi, edi.
;
%_concat.ubyte.a0.eq.a1.plus.a0.ss:
%_concat.string.a0.eq.a1.plus.a0.ss:
push	ebx
push	eax
push	6		;"ss" marker
call	main.concat	;eax -> new string
add	esp,12
ret
;
;
; *************************
; *****  main.concat  *****  main string concatenator
; *************************
;
; #######################################
; ###########  July 15, 1994  ###########
; #####  APPEARS TO HAVE A PROBLEM  #####
; #####  If a1 string has a header  #####
; #####  that has zero elements, a  #####
; #####  memory allocation problem  #####
; #####  occurs after concatenate!  #####
; #####  try: "gonzo$ = a0$ + a1$"  #####
; #######################################
; #######################################
;
;
; in:	arg2 -> string a0
; 	arg1 -> string a1
;	arg0 -> index corresponding to entry point (see chart below)
; out:	eax -> new string, consisting of string a1 appended to string a0
;
; Destroys: ebx, ecx, edx, esi, edi.
;
; Local variables:
;	[ebp-4] = size of a0
;	[ebp-8] = size of a1
;	[ebp-12] = index into jump table
;	[ebp-16] = return value
;	[ebp-20] = LEN(a0) + LEN(a1)   (not counting null terminator)
;
; The returned string is always allocated in dynamic memory.  The
; input strings are both assumed to have a # of bytes per element of 1,
; so that there's no need to perform a multiply to determine the size
; of a string.
;
; For efficiency, i.e. to prevent unnecessary string copying and realloc'ing,
; there are four entry points, each one's label having one of the following
; suffixes:
;
;     Suffix	Meaning					  Index
;	vv	a0 is a variable,   a1 is a variable	    0
;	vs	a0 is a variable,   a1 is on the stack	    2
;	sv	a0 is on the stack, a1 is a variable	    4
;	ss	a0 is on the stack, a1 is on the stack	    6
;
; The number in the "Index" column is the number that needs to be passed
; in edx to indicate which entry point the main concatenator was called
; from.
;
; "On the stack" means that the string is a temporary variable, which
; holds a value that will not be referenced after the current expression
; has been evaluated.  It is the responsibility of the main concatenator
; to free temporary variables that it is passed.  However, in some cases,
; e.g. when a temporary variable is concatenated with a null string, the
; most efficient action is to simply return the temporary variable
; without freeing it.
;
; There are seven possible results:
;
;	A  extended clone of a0 (a1 is copied onto end of clone of a0)
;	B  exact clone of a0
;	C  a1 (exact same pointer)
;	D  exact clone of a1
;	E  null
;	F  extension of a0 (a1 is copied onto end of a0)
;	G  a0 (exact same pointer)
;
; The following two tables list the conditions required for each result:
;
;	When a1 is non-null and a1's size > 0:
;
;	     a0 non-null and	a0 null or
;	     a0's size > 0	a0's size == 0
;	vv	    A		       D
;	vs	    A		       C
;	sv	    F		       D
;	ss	    F		       C
;
;	When a1 is null or a1's size == 0:
;
;	     a0 non-null and	a0 null or
;	     a0's size > 0	a0's size == 0
;	vv	    B		       E
;	vs	    B		       E
;	sv	    G		       E
;	ss	    G		       E
;
; The above two tables are encoded as jump addresses in concat_jump_table.
; Indexes into concat_jump_table are calculated according to the
; following formula, written in fake C:
;
;	a0null = (a0 == NULL || a0.size == 0);
;	a1null = (a1 == NULL || a1.size == 0);
;	jmp_index = (a1null * 8) + entry_index + a0null;
;
; The same number is also an index into concat_free_table, a jump table
; of addresses of routines to free strings appropriately.
;
main.concat:
push	ebp
mov	ebp,esp
sub	esp,20
;
mov	edi,[ebp+12]	;edi -> string a1
cld
or	edi,edi		;is it a null pointer?
jz	short a1_is_null ;yes: don't look up its length
mov	edi,[edi-8]	;edi = length of string a1
or	edi,edi		;set ZF for coming SETZ instruction
;;
a1_is_null:
mov	[ebp-8],edi	;save length of string a1
setz	dl		;dl = "a1null" variable from header comment
sll	dl,3		;dl = "a1null * 8"
;
mov	ecx,[ebp+16]	;ecx -> string a0
or	ecx,ecx		;is it a null pointer?
jz	short a0_is_null ;yes: don't look up its length
mov	ecx,[ecx-8]	;ecx = length of string a0
or	ecx,ecx		;set ZF for coming SETZ instruction
;;
a0_is_null:
mov	[ebp-4],ecx	;save length of string a0
setz	dh		;dh = "a0null" variable from header comment
;;
add	dl,dh		;dl = a0null + a1null * 4
and	edx,0xF		;edx = a0null + a1null * 4
add	edx,[ebp+8]	;edx = (a1null * 4) + entry_index + a0null
;;				; = index into jump tables
mov	[ebp-12],edx	;save index into jump tables
cld			;make sure movs instructions go right way
;;
jmp	[concat_jump_table + edx * 4] ;concatenate them strings!
;
; ***** routines pointed to by elements of concat_jump_table
; 	on entry, edi = length of a1, ecx = length of a0
;
extend.clone.a0:
add	edi,ecx		;edi = LEN(a1) + LEN(a0)
mov	[ebp-20],edi	;save it
mov	esi,edi		;esi = LEN(a1) + LEN(a0) = size of clone
inc	esi		;add one for null terminator
call	%_____malloc	;esi -> header of new block, all else destroyed
mov	ebx,[ebp+16]	;ebx -> string a0
mov	eax,[ebx-4]	;eax = a0's info word
btr	eax,24		;eax = info word with system/user bit cleared
or	eax,[_##WHOMASK]	;OR in system/user bit
mov	[esi+12],eax	;clone's info word = a0's info word | $$whomask
mov	eax,[ebp-20]	;eax = LEN(a0) + LEN(a1)
mov	[esi+8],eax	;clone's # of elements = LEN(a0) + LEN(a1)
;;
add	esi,16		;esi -> new string
mov	edi,esi		;edi -> new string
mov	eax,edi		;save pointer to new string
mov	esi,[ebp+16]	;esi -> string a0
mov	ecx,[ebp-4]	;ecx = LEN(a0)
;;			;edi is guaranteed to be on a 4-byte boundary
add	ecx,3		;round ecx up to next multiple of 4
slr	ecx,2		;ecx = # of dwords to copy
jecxz	short ec0_copy_done
rep
movsd
;;
ec0_copy_done:
mov	edi,eax		;edi -> first byte of new string
jmp	short concat.copy.a1
;
extend.a0:
mov	esi,[ebp+16]	;esi -> string a0
mov	edx,[esi-16]	;edx = size of a0's chunk, including header
sub	edx,16		;edx = size of a0's chunk, excluding header
add	edi,ecx		;edi = LEN(a1) + LEN(a0)
mov	[ebp-20],edi	;save LEN(a1) + LEN(a0)
inc	edi		;add one for null terminator
cmp	edx,edi		;will concatenated string fit in a0?
jae	short it_fits	;if chunk size >= size needed, then skip realloc
call	%____realloc	;esi -> new block, all else destroyed
;;
it_fits:
mov	eax,[ebp-20]	;eax = LEN(a0) + LEN(a1)
mov	[esi-8],eax	;# of elements = LEN(a0) + LEN(a1)
mov	eax,esi		;save return value
mov	edi,esi		;edi -> new block
;;
concat.copy.a1:
add	edi,[ebp-4]	;edi -> byte after last byte in a0
mov	esi,[ebp+12]	;esi -> first byte of string a1
mov	ecx,[ebp-8]	;ecx = # of bytes in a1
;;
e0_byte_boundary:		;get rep movsd started on 4-byte boundary
test	edi,1		;if bit 0 = 0 then no initial bytes to copy
jz	short e0_word_boundary
movsb			;copy first byte
dec	ecx		;ecx = # of bytes left to copy
jz	short add_terminator
;;
e0_word_boundary:
test	edi,2		;if bit 1 = 0 then no initial words to copy
jz	short e0_dword_boundary
movsw			;copy a word; now we're on dword boundary
sub	ecx,2		;ecx = # of bytes left to copy
jz	short add_terminator
;;
e0_dword_boundary:
add	ecx,3		;round ecx up to next dword boundary
slr	ecx,2		;ecx = # of dwords to copy
jecxz	add_terminator	;skip if no dwords to copy
rep
movsd			;copy a1 onto end of a0!
;;
add_terminator:
mov	edi,eax		;edi -> new string
add	edi,[ebp-20]	;edi -> one byte after last byte of new string
mov	byte ptr [edi],0 ;put null terminator at end of string
jmp	short ready.to.free ;eax still -> new string
;
;
return.null:
mov	[ebp-16],0	;return a null pointer
jmp	short ready.to.free
;
;
return.a0:
mov	eax,[ebp+16]	;eax -> string a0
jmp	short ready.to.free	;return string a0
;
;
return.a1:
mov	eax,[ebp+12]	;eax -> string a1
jmp	short ready.to.free	;return string a1
;
;
clone.a0:
mov	eax,[ebp+16]	;eax -> string a0
call	%_clone.a0	;eax -> clone of a0
jmp	short ready.to.free	;return clone of a0
;
;
clone.a1:
mov	eax,[ebp+12]	;eax -> string a1
call	%_clone.a0	;eax -> clone of a1
jmp	short ready.to.free	;return clone of a1
;
; ***** finished with routine from concat_jump_table
;	on entry: eax -> string to return
;
;
ready.to.free:
mov	[ebp-16],eax	;save return value
mov	edx,[ebp-12]	;edx = index into jump tables
jmp	[concat_free_table + edx * 4] ;free what needs to be freed
;
; ***** routines to free what needs to be freed
;
free.a0:
mov	esi,[ebp+16]	;esi -> string a0
call	%____free
jmp	short concat.done
;
;
free.a0.a1:
mov	esi,[ebp+16]	;esi -> string a0
call	%____free
;;
;; fall through
;;
free.a1:
mov	esi,[ebp+12]	;esi -> string a1
call	%____free
jmp	short concat.done
;
; ***** finished freeing
;
free.nothing:
concat.done:
mov	eax,[ebp-16]	;eax -> string to return
mov	esp,ebp
pop	ebp
ret
;
; *****  jump table for concatenate routines  *****
;
.align	8
concat_jump_table:
;		    a1 has string
;	a0 has string		a0 has no string
.dword	extend.clone.a0,	clone.a1	;vv
.dword	extend.clone.a0,	return.a1	;vs
.dword	extend.a0,		clone.a1	;sv
.dword	extend.a0,		return.a1	;ss
;		   a1 has no string
;	a0 has string		a0 has no string
.dword	clone.a0,		return.null	;vv
.dword	clone.a0,		return.null	;vs
.dword	return.a0,		return.null	;sv
.dword	return.a0,		return.null	;ss
;;
concat_free_table:
;		    a1 has string
;	a0 has string		a0 has no string
.dword	free.nothing,		free.nothing	;vv
.dword	free.a1,		free.nothing	;vs
.dword	free.nothing,		free.nothing	;sv
.dword	free.a1,		free.nothing	;ss
;		   a1 has no string
;	a0 has string		a0 has no string
.dword	free.nothing,		free.nothing	;vv
.dword	free.a1,		free.a1		;vs
.dword	free.nothing,		free.a0		;sv
.dword	free.a1,		free.a0.a1	;ss
;
;
.text
;
; #####################
; #####  xliba.s  #####  Low-level array processing
; #####################
;
; ************************
; *****  %_DimArray  *****  dimensions an array
; ************************  (recursive to handle multi-dimensional arrays)
;
; in:	arg11 = upper bound of eighth dimension
;	arg10 = upper bound of seventh dimension
;	arg9 = upper bound of sixth dimension
;	arg8 = upper bound of fifth dimension
;	arg7 = upper bound of fourth dimension
;	arg6 = upper bound of third dimension
;	arg5 = upper bound of second dimension
;	arg4 = upper bound of first dimension		[ebp+24]
;	arg3 unused
;	arg2 = word 3 of header (info word)		[ebp+16]
;	arg1 = # of dimensions (maximum allowed: 8)	[ebp+12]
;	arg0 -> array address (i.e. [arg0] -> array)	[ebp+8]
; out:
;	eax -> highest-dimension array (to be stored in handle)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = dim.number, i.e. current dimension
;	[ebp-8] = # of elements in current dimension
;
;  array headers look like this:
;
;	word3 = info.word = info.byte + data.type.byte + bytes.per.element.word
;	word2 = upper.bound of this dimension
;	word1 = address downlink  (MSb = 1 if chunk allocated (new 01-June-93)
;	word0 = address uplink
;
;  info word bits:
;	bit 31 = NO LONGER USED (the next line is obsolete)
;	bit 31 = ALLOCATED  	(must always = 1 on allocated chunks)
;       bit 30 = ARRAY BIT  	(1 = array, 0 = string)
;	bit 29 = NON-LOW-DIM	(1 = non-lowest-dimension, 0 = lowest dimension)
;	bit 28 =
;	bit 27 =
;	bit 26 =
;	bit 25 =
;	bit 24 = INFOMASK       (1 = USER array, 0 = SYSTEM array)
;
;
;  FUNCTION XLONG DimArray ()
;    IF addr(this.array) THEN FreeArray (this.array)
;    INC dim.number
;    upper.bound = dim.<dim.number>
;    IF lowest.dim (ie dim.number >= dim.count) THEN
;      header.addr = calloc (size.this.dim)
;      IF ERROR THEN RETURN ERROR
;      word3 = info.word (info, data.type, bytes.per.element)
;      word2 = upper.bound
;      DEC dim.number
;      RETURN header.addr
;    ELSE
;      this.array.addr = calloc (size.this.dim)
;      IF ERROR THEN RETURN ERROR
;      word3 = info.word + not.lowest.dim
;      word2 = upper.bound
;      FOR element = 0 to upper.bound
;        next.array.addr = DimArray (dim.number + 1)
;        this.array.data.addr [element] = next.array.addr
;        IF ERROR THEN RETURN ERROR
;      NEXT element
;      DEC dim.number
;      RETURN this.array.addr
;    ENDIF
;  END FUNCTION
;
%_DimArray:
	push	ebp
	mov	ebp,esp
	sub	esp,8
;;
	mov	eax,[_##WHOMASK]	;eax holds system/user bit
	or	[ebp+16],eax	;OR system/user bit into info word
	mov	esi,[ebp+8]	;esi -> base address of array
	or	esi,esi		;null pointer?
	jz	short DimArray	;yes: don't bother to free it
	call	%_FreeArray	;no: free existing array first
DimArray:
	mov	[ebp-4],0	;dim.number starts at zero
	call	dim.dim		;do the dimensioning
;;
	mov	eax,esi		;eax -> base address of array
	mov	esp,ebp
	pop	ebp
	ret
;;
; ***** recursive entry point  (does not modify ebp or allocate local frame)
;	in:	[ebp-4] = dim.number = last dimension that was dimensioned
;	out:	esi -> base address of dimensioned array
;	destroys: eax, ebx, ecx, edx, edi, [ebp-8]
;
dim.dim:
	inc	[ebp-4]		;next dim.number
	mov	ebx,[ebp-4]	;ebx = dim.number, i.e. current dimension
	mov	eax,[ebp+20+ebx*4] ;eax = upper.bound for current dimension
	xor	esi,esi		;prepare to return null pointer if necessary
	add	eax,1		;eax = # of elements in current dim
	mov	[ebp-8],eax	;save it
	jle	short dim.dim.exit ;if negative upper bound (illegal), then
				   ; return null array (a zero)
	cmp	ebx,[ebp+12]	;is current dim < total # of dims?
	jl	short not.lowest.dim ;yes: not yet on lowest dim
;;
;; create lowest-dimension array
;;
lowest.dim:
	mov	esi,eax		;esi = # of elements in current dimension
	movzx	eax,word ptr [ebp+16] ;eax = # of bytes per element
	imul	esi,eax		;esi = total # of bytes in array
	call	%_____calloc	;allocate and zero array
				;esi -> array's header
	or	esi,esi		;error?
	jz	short dim.dim.exit ;yep (88000 version jumps to dim.dim.exit)

	mov	eax,[ebp+16]	;eax = info word
	mov	[esi+12],eax	;put info word in array's header
	mov	eax,[ebp-8]	;eax = # of elements in lowest dimension
	mov	[esi+8],eax	;put # of elements in array's header
	add	esi,16		;esi -> data area of array
	jmp	short dim.dim.exit
;
; create non-lowest-dimension array
;	in: eax = # of elements in current dimension
;
not.lowest.dim:
	lea	esi,[eax*4]	;esi = # elems in current dim * 4 = # of bytes
	call	%_____calloc	;allocate and zero array
				;esi -> array's header
	or	esi,esi		;error?
	jz	short dim.dim.exit ;yep (88000 version jumps to dim.dim.exit)
;;
	mov	eax,[ebp+16]	;eax = info word
	mov	ax,4		;bytes per element = 4
	or	eax,0x20000000	;not.lowest.dim = TRUE  (in info word)
	mov	[esi+12],eax	;put info word in array's header
	mov	eax,[ebp-8]	;eax = # of elements in current dimension
	mov	[esi+8],eax	;put # of elements in array header
;;
	lea	ebx,[esi+16]	;ebx -> array's data area
	xor	ecx,ecx		;ecx = current element number
	mov	edx,eax		;edx = # of elements in current dimension
;;
dim.loop:
	push	ebx		;watch out for those recursive functions!
	push	ecx
	push	edx
	call	dim.dim		;allocate array for current element
	pop	edx		; esi -> its base address
	pop	ecx
	pop	ebx

	or	esi,esi		;error?
	jz	short dim.dim.exit ;yep
	mov	[ebx+ecx*4],esi	;store pointer for current element
	inc	ecx		;current element number++
	cmp	ecx,edx		;current element = # of elements?
	jne	dim.loop	;no: keep going
				;yes: fall through
	mov	esi,ebx		;esi -> base address of just-allocated array
;;
dim.dim.exit:
	dec	[ebp-4]		;dim.number--
	ret			;esi -> base address of just-allocated array
;
;
;
;
; *************************
; *****  %_FreeArray  *****  frees an array
; *************************  (recursive to handle multi-dimensional arrays)
;
; in:	esi -> base address of array to free
;
; out:	esi < 0 iff error, 0 if ok
;
; destroys: ebx, ecx, edi  (must not destroy "eax/edx" return values)
;
; local variables:
;	[ebp-4]	= current element
;	[ebp-8] -> array to free
;
;  FUNCTION XLONG FreeArray (array.address)
;    lowest.dim = (non.lowest.dim bit in info word = 0)
;    IF (lowest.dim AND type.numeric) OR (this.is.a.string...not.an.array) THEN
;      ERROR = free ( this.array.header.addr )
;      RETURN ERROR
;    ELSE
;      FOR element = 0 to upper.bound
;        ERROR = FreeArray ( this.array.data [element] )
;        IF ERROR THEN RETURN ERROR
;      NEXT element
;      ERROR = free ( this.array.header.addr )
;      RETURN ERROR
;    END IF
;  END FUNCTION
;
%_FreeArray:
;	push	eax		; save eax  (return value from function)
;	push	edx		; save edx  (ditto if GIANT or DOUBLE)
	push	ebp
	mov	ebp,esp
	push	eax		; save eax  (return value from function)
	push	edx		; save edx  (ditto if GIANT or DOUBLE)
	sub	esp,8

	or	esi,esi		;is array free already?
	jz	short a.free.exit ;yes

	mov	eax,[esi-4]	;eax = info word
	test	eax,0x40000000	;test bit 30: array/string bit
	jz	short ok.to.free.this ;if it's a string, free it
	test	eax,0x20000000	;test bit 29: no-low-dim bit
	jnz	short not.lowest.free ;if not lowest dim, free its elements
;	and	eax,0x001F0000	;eax = just data-type field from info word
	and	eax,0x00FF0000	;eax = just data-type field from info word
	cmp	eax,0x00130000	;is object of string.type?
	je	short not.lowest.free ;yes: free strings first (?)
;
; lowest.dim and numeric, or string... so free it
;
ok.to.free.this:
	call	%____free	;free the object
	or	esi,esi		;error?
	jz	short a.free.bad
a.free.ok:
	xor	esi,esi		;esi = 0 to indicate success
a.free.exit:
	mov	esp,ebp
	mov	eax,[ebp-4]	;
	mov	edx,[ebp-8]	;
	pop	ebp
;	pop	edx		; restore original edx
;	pop	eax		; restore original eax
	ret
;
not.lowest.free:
	xor	edx,edx		;current element number = 0
	mov	[ebp-12],edx	;save current element number
	mov	[ebp-16],esi	;save pointer to first element of array
;
a.free.loop:
	;or	esi,esi		;null array?
	;jz	short free.free.exit ;yes: just exit (???)
	mov	esi,[esi+edx*4]	;esi -> chunk to free
	or	esi,esi		;null element?
	jz	short a.free.null ;yes: go to next element
	call	%_FreeArray	;no: free it and all its sub-arrays (and so on)
;
	cmp	esi,-1		; error ?				; xxx
	je	short a.free.exit ; yes: return without freeing the rest	; xxx
;
a.free.null:
	mov	esi,[ebp-16]	;esi -> first element of array to free
	inc	[ebp-12]	;current element number++
	mov	edx,[ebp-12]	;edx = current element number
	cmp	edx,[esi-8]	;current element number >= number of elements?
	jb	a.free.loop	;no: free next element
				;yes: free current array
	call	%____free	;free current array
	or	esi,esi		;error?
	jnz	a.free.ok	;no: say so and return
				;yes: fall through and indicate error
a.free.bad:			;esi assumed to be zero on entry
	dec	esi		;esi is now < 0 to indicate error
	mov	esp,ebp
	mov	eax,[ebp-4]	;
	mov	edx,[ebp-8]	;
	pop	ebp
;	pop	edx		; restore original edx
;	pop	eax		; restore original eax
	ret
;
;
;
;  ****************************
;  *****  %_RedimArray    *****  redimensions an array
;  ****************************  contents are not altered!
;
; in:	arg11 = upper bound of eighth dimension
;	arg10 = upper bound of seventh dimension
;	arg9 = upper bound of sixth dimension
;	arg8 = upper bound of fifth dimension
;	arg7 = upper bound of fourth dimension
;	arg6 = upper bound of third dimension
;	arg5 = upper bound of second dimension
;	arg4 = upper bound of first dimension		[ebp+24]
;	arg3 unused
;	arg2 = word 3 of header (info word)		[ebp+16]
;	arg1 = # of dimensions (maximum allowed: 8)	[ebp+12]
;	arg0 -> array address (i.e. [arg0] -> array)	[ebp+8]
; out:
;	eax -> highest-dimension array (to be stored in handle)
;	       or < 0 if error
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = dim.number, i.e. current dimension
;	[ebp-8] = new # of elements in current dimension
;
; FUNCTION XLONG RedimArray (arrayAddress)
;   dimNumber = 0
;   RedimArraySmaller (arrayAddress)
;   dimNumber = 0
;   RedimArrayLarger (arrayAddress)
; END FUNCTION
;
; FUNCTION XLONG RedimArraySmaller (arrayAddress)
;   INC dimNumber
;   newLowestDim = (dimNumber >= dimCount)
;   IF newLowestDim THEN
;     IFZ oldLowestDim (from info word) THEN RETURN (error.node.data.mismatch)
;     IF (newType != oldType) THEN RETURN (error.type.mismatch)
;     IF (newUpperBound < oldUpperBound) THEN
;       IF oldStringType (from info word) THEN
;         FOR element = newUpperBound+1 TO oldUpperBound
;           error = free (arrayAddress [element])            ' free string
;           IF error THEN DEC dimNumber: RETURN (error)      ' error in free
;         NEXT element
;       END IF
;       arrayAddress [element] = recalloc (arrayAddress [element], newSize)
;       update info word with new # of elements
;     END IF
;   ELSE
;     IF oldLowestDim (from info word) THEN RETURN (error.dim.data.mismatch)
;     FOR element = 0 TO oldUpperBound
;       IF (element <= newUpperBound) THEN                   ' in old and new
;         newAddr = RedimArraySmaller ( thisArrayData [element] )
;         IF (newAddr < 0) THEN DEC dimNumber: RETURN (newAddr)  (return error)
;         thisArrayData [element] = newAddr
;       ELSE
;         error = FreeArray ( thisArrayData [element] )
;         thisArrayData [element] = 0
;         IF error THEN DEC dimNumber: RETURN (error)
;       END IF
;     NEXT element
;     DEC dimNumber
;     RETURN (thisArrayBaseAddr)
;   END IF
; END FUNCTION
;
; FUNCTION XLONG RedimArrayLarger (arrayAddress)
;   INC dimNumber
;   newUpperBound = dim.[dim.number]
;   newLowestDim = (dimNumber >= dimCount)
;   IF newLowestDim THEN
;     IFZ oldLowestDim THEN RETURN (error.node.data.mismatch)
;     IF (oldType != newType) THEN RETURN (error.type.mismatch)
;     dataAddr = recalloc (size.this.dim)        ' newUpperBound * bytesPerEle
;     IF (dataAddr < 0) THEN DEC dimNumber: RETURN (dataAddr)   ' error
;     update word2/word3 with newUpperBound      '
;     RETURN (dataAddr)
;   ELSE
;     arrayAddr = recalloc (size.this.dimension) ' newUpperBound * bytesPerEle
;     IF (arrayAddr < 0) THEN RETURN (arrayAddr) ' error
;     update word2/word3 with newUpperBound      '
;     FOR element = 0 to new.upper.bound
;       IF this.array.data.base.addr [element] THEN
;         arrayAddr = redim_array_larger (this.array.data.addr [element])
;       ELSE
;         IF (element <= oldUpperBound) THEN DEC dimNumber: RETURN (error)
;         arrayAddr = DimArray (this.array.data.base.addr [element])
;       ENDIF
;       IF (arrayAddr < 0) THEN DEC dimNumber: RETURN (arrayAddr)   ' error
;       thisArray [element] = arrayAddr
;     NEXT element
;     DEC dimNumber
;     RETURN (arrayAddr)
;   ENDIF
; END FUNCTION
;
%_RedimArray:
	cmp	[esp+4],0	;null array?
	je	%_DimArray	;yes: if never dimensioned, same as DIM

	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov	[ebp-4],0	;dim.number = 0
	mov	esi,[ebp+8]	;esi = base address of array
	call	redim.array.smaller
	cmp	esi,-1			; error ?				; xxx
	je	short redim_exit	; yes: return without freeing the rest	; xxx
;
	mov	[ebp-4],0		; dim.number = 0
	call	redim.array.larger
;
redim_exit:
	mov	eax,esi			; eax -> new array
	mov	esp,ebp
	pop	ebp
	ret
;
; ***** recursive entry point  (does not modify ebp or allocate local frame)
;	redimensions all arrays that are being changed to smaller dimensions
;	in:	[ebp-4] = dim.number = last dimension redim'ed
;		esi -> array to redimension
;	out:	esi -> redimensioned array (may be different than on entry)
;
redim.array.smaller:
	or	esi,esi		;null array?
	jz	redim.null	;yes: don't redimension it smaller

	inc	[ebp-4]		;INC dimNumber
	mov	ebx,[ebp-4]	;ebx = dim.number = current dimension
	mov	eax,[esi-4]	;eax = info word of array
	mov	edx,[esi-8]	;edx = old # of elements
	dec	edx		;edx = old upper bound
;;
	cmp	ebx,[ebp+12]	;at new lowest dimension?
	jne	short rs.not.lowest.dim ;no: at an array of pointers to arrays
rs.lowest.dim:			;yes: at an array of actual data
	mov	edi,eax		;save old info word
	xor	eax,[ebp+16]	;bit 29 of eax = 1 iff not-lowest-dim bit of
				; new array is different than not-lowest-dim
				; bit at current dimension in old array
	test	eax,0x20000000	;changed number of dims?
	jnz	redim.changed.dims ;yes: error: new # of dims
;
; I have no check for a type mismatch (??? who and why ???)
;
	mov	ecx,[ebp+20+ebx*4] ;ecx = new upper bound for current dimension
	mov	[ebp-8],ecx	;save it
	cmp	ecx,edx		;new upper bound less than old upper bound?
	jge	short rs.recalloc ;no: there's nothing to free	' 06/18/93 xxx add
;;
	mov	eax,[esi-4]	;eax = info word
;	and	eax,0x001F0000	;eax = just data-type field from info word
	and	eax,0x00FF0000	;eax = just data-type field from info word
	cmp	eax,0x00130000	;is array of string type?
	je	short rs.free.strings ;yes: free them extraneous strings
;;
	test	edi,0x20000000	;lowest dim contains arrays?
	jz	short rs.recalloc ;no: there's nothing to free

rs.free.strings:
	inc	ecx		;ecx = current element = newUpperBound + 1
rs.free.string.loop:
	push	esi
	push	ecx
	push	edx
	mov	esi,[esi+ecx*4]	;esi -> array[elem]   (i.e. current string)
	call	%____free	;free current element
	pop	edx
	pop	ecx
	mov	eax,esi		;eax = result from %____free
	pop	esi
	cmp	eax,-1				; error ?				; xxx
	je	short redim.malloc.error	; yes: return without more free	; xxx

	inc	ecx		; INC current element
	cmp	ecx,edx		; past old upper bound?
	jbe	rs.free.string.loop ;no: free another string
;
rs.recalloc:
	mov	edi,[ebp-8]	; edi = new upper bound
	inc	edi		; edi = new # of elements in current dimension
	movzx	eax,word ptr [esi-4] ;eax = # of bytes per element
	imul	edi,eax		; edi = # of bytes required for new array
;
	call	%____recalloc	; esi -> resized array
	or	esi,esi		; esi = 0 = recalloc to empty string/array ???	; add 95/03/03
	jz	short rs.done	; yes						; add 95/03/03
	cmp	esi,-1				; error ?			; xxx
	je	short redim.malloc.error	; yes: return without more free	; xxx
;
	mov	eax,[ebp-8]	; eax = new upper bound of current dimension
	inc	eax		; eax = new # of elements
	mov	[esi-8],eax	; store it in header of array
	jmp	short rs.done
;
rs.not.lowest.dim:		; we're at an array of pointers to arrays
	test	eax,0x20000000	; at old lowest dimension or original array?
	jz	short redim.changed.dims ;yes: error: new # of dims

	xor	ecx,ecx		; ecx = current elem = 0
	mov	ebx,[ebp+20+ebx*4] ; ebx = new upper bound for current dimension
rs.shrink.loop:
	cmp	ecx,ebx		; current elem <= new upper bound?
	ja	short rs.free.array ; no: free current element
				    ; yes: redim current element
	mov	edi,esi		; edi -> current array
	mov	esi,[esi+ecx*4]	; esi = current element
	push	edi
	push	ebx
	push	ecx
	push	edx
	call	redim.array.smaller ;esi = new current element
	pop	edx
	pop	ecx
	pop	ebx
	pop	edi		; edi -> current array
	cmp	esi,-1		; error ?				; xxx
	je	short rs.done	; yes: return without freeing the rest	; xxx

	mov	[edi+ecx*4],esi	;store new current element
	mov	esi,edi
	jmp	short rs.shrink.loop.end
;
;
rs.free.array:			;current elem is beyond new dim: free it
	push	esi
	push	ebx
	push	ecx
	push	edx
	mov	esi,[esi+ecx*4]	;esi = current element
	call	%_FreeArray
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax		; eax -> current array
	mov	[eax+ecx*4],0	; zero current elem (unnecessary, I think)
	cmp	esi,-1		; xxx
	je	short rs.done	; xxx
	mov	esi,eax		; esi -> current array

rs.shrink.loop.end:
	inc	ecx		; INC elem
	cmp	ecx,edx		; past old upper bound?
	jbe	rs.shrink.loop	; no: keep going
	jmp	short rs.done	; yes: all done
;
; the following four entry points are called from both redim.array.smaller
; and redim.array.larger
;
redim.malloc.error:		;recalloc or free got an error
redim.changed.dims:		;attempted to change # of dims
redim.ragged:			;discovered ragged array
	;call appropriate run-time error routine?
	mov	esi,-1		;esi < 0 to indicate error
rs.done:
rl.done:
	dec	[ebp-4]		;DEC dimNumber
redim.null:			;tried to redim null sub-array (esi assumed 0)
	ret			;end of redim.array.smaller
;
;
; ***** recursive entry point  (does not modify ebp or allocate local frame)
;	redimensions all arrays that are being changed to larger dimensions
;	in:	[ebp-4] = dim.number = last dimension redim'ed
;		esi -> array to redimension
;	out:	esi -> redimensioned array (may be different than on entry)
;
redim.array.larger:
	inc	[ebp-4]		;INC dimNumber
	mov	ebx,[ebp-4]	;ebx = dimNumber
	cmp	ebx,[ebp+12]	;at new lowest dim?
	mov	ebx,[ebp+20+ebx*4] ;ebx = new upper bound
	jb	short rl.not.lowest.dim ;no: we're at an array of pointers
;;
rl.lowest.dim:				;yes: we're at some real data
	or	ebx,ebx		;ebx < 0 means want empty array here	; 95/03/03
	js	short rl.done	;so can't be larger - done		; 95/03/03
	push	ebx
	movzx	edi,word ptr [esi-4] ;edi = old # of bytes per element
	inc	ebx		;ebx = new # of elements
	imul	edi,ebx		;edi = bytes required by new array
	call	%____recalloc	;esi -> resized array
	pop	ebx
	cmp	esi,-1				; xxx
	je	short redim.malloc.error	; xxx
	inc	ebx		;ebx = new # of elements
	mov	[esi-8],ebx	;store new # of elements
	jmp	short rl.done	;all done
;
rl.not.lowest.dim:		;we're at an array of pointers to arrays
	or	ebx,ebx		;ebx < 0 means want empty array here	; 95/03/03
	js	short rl.done	;so can't be larger - done		; 95/03/03
	push	ebx
	movzx	edi,word ptr [esi-4] ;edi = old # of bytes per element
	inc	ebx		;ebx = new # of elements
	imul	edi,ebx		;edi = bytes required by new array
	call	%____recalloc	;esi -> resized array
	pop	ebx
	cmp	esi,-1				; xxx
	je	short redim.malloc.error	; xxx
	inc	ebx		;ebx = new # of elements
	mov	[esi-8],ebx	;store new # of elements
	dec	ebx		;ebx = new upper bound

	xor	ecx,ecx		;ecx = current element # = 0
	mov	edi,esi		;edi -> current array
rl.redim.loop:
	push	ebx
	push	ecx
	push	edi
	mov	esi,[edi+ecx*4]	;esi = current element
	or	esi,esi		;null pointer?
	jz	rl.dim.array	;yes: replace it with a new (empty) array
				;no: recurse through it
	call	redim.array.larger ;esi -> new element
	jmp	short rl.redim.loop.end
;
;
rl.dim.array:
	call	dim.dim		;esi -> new element
;;
rl.redim.loop.end:
	pop	edi
	pop	ecx
	pop	ebx
	cmp	esi,-1		; xxx
	je	rl.done		; xxx
;;
	mov	[edi+ecx*4],esi	; store pointer to new array
;;
	inc	ecx		; INC current element number
	cmp	ecx,ebx		; past new upper bound?
	jbe	rl.redim.loop	; no: keep going

	mov	esi,edi		; esi -> array again
	dec	[ebp-4]		; DEC dimNumber
	ret
;
;
; ##############################
; #####  XxxSwapMemory ()  #####
; ##############################
;
_XxxSwapMemory@12:
	push	ebp		; standard function entry
	mov	ebp,esp		; ditto
	push	esi		; ditto
	push	edi		; ditto
	push	ebx		; ditto
	mov	esi,[ebp+16]	; esi = length
	call	%____malloc	; allocate intermediate memory
	push	esi		; esi = addrx = intermediate memory
	mov	edi,esi		; edi = addrx = destination
	mov	esi,[ebp+8]	; esi = addr1 = source
	mov	ecx,[ebp+16]	; ecx = length
	call	%_assignComposite
	mov	edi,[ebp+8]	; edi = addr1 = destination
	mov	esi,[ebp+12]	; esi = addr2 = source
	mov	ecx,[ebp+16]	; ecx = length
	call	%_assignComposite
	mov	edi,[ebp+12]	; edi = addr2 = destination
	pop	esi		; esi = addrx = source
	mov	ecx,[ebp+16]	; ecx = length
	call	%_assignComposite
	pop	ebx		; standard function exit
	pop	edi		; ditto
	pop	esi		; ditto
	mov	esp,ebp		; ditto
	pop	ebp		; ditto
	ret	12		; ditto (remove arguments - STDCALL)
;
;
; *******************************
; *****  %_AssignComposite  *****  copies a composite
; *******************************
;
; in:	esi -> source address
;	edi -> destination address
;	ecx = number of bytes to copy
;
; out:	nothing
;
; destroys: ebx, ecx, edx, esi, edi  (must not destroy eax)
;
; Guaranteed to not copy any extra bytes in addition to the number
; of bytes requested.  If destination address is null, does nothing.
; If source address is null, zeros destination.
;
%_AssignComposite:
%_assignComposite:
assignComposite:
	push	eax		; save eax  (ntntnt)
	cld
	or	edi,edi		;null destination?
	jz	short ac_done	;yes: nothing to do
	or	esi,esi		;null source?
	jz	short ac_zero	;yes: zero destination
;
	mov	eax,esi		;eax = source address
	or	eax,edi		;ready for alignment check
	test	eax,1		;copy one byte at a time?
	jnz	short copy_bytes ;yes
	test	eax,2		;copy one word at a time?
	jnz	short copy_words ;yes
;
copy_dwords:			;copy a dword at a time
	mov	ebx,ecx		;save # of bytes to copy
	slr	ecx,2		;ecx = # of dwords to copy
	rep
	movsd			;copy them!
	test	ebx,2		;an odd word left to copy?
	jz	short dw_odd_byte ;no
	movsw			;yes: copy it
dw_odd_byte:
	test	ebx,1		;an odd byte left to copy?
	jz	short ac_done	;no
copy_odd_byte:
	movsb			;yes: copy it
ac_done:
	pop	eax		; restore entry eax (ntntnt)
	ret
;
;
copy_words:			;copy a word at a time
	mov	ebx,ecx		;save # of bytes to copy
	slr	ecx,1		;ecx = # of words to copy
	rep
	movsw			;copy them!
	test	ebx,1		;an odd byte left to copy?
	jnz	copy_odd_byte	;yes: copy it
	pop	eax		; restore eax (ntntnt)
	ret			;no: all done
;
;
copy_bytes:			;copy a byte at a time
	rep
	movsb			;copy them!
	pop	eax		; restore eax (ntntnt)
	ret
;
;
ac_zero:			;zero destination
	xor	eax,eax		;eax = 0, the better to clear memory with
	mov	ebx,esi		;ebx = source address
	or	ebx,edi		;ready for alignment check
	test	ebx,1		;zero one byte at a time?
	jnz	short zero_bytes ;yes
	test	ebx,2		;zero one word at a time?
	jnz	short zero_words ;yes
;;
zero_dwords:			;zero a dword at a time
	mov	edx,ecx		;save number of bytes to zero
	slr	ecx,2		;ecx = # of dwords to zero
	rep
	stosd			;zero them!
	test	edx,2		;an odd word left over?
	jz	short zd_odd_byte ;no
	stosw			;yes: zero it
zd_odd_byte:
	test	edx,1		;an odd byte left over?
	jz	short zc_done	;no: all done
zero_odd_byte:
	stosb			;yes: zero it
zc_done:
	pop	eax		; restore eax (ntntnt)
	ret
;
;
zero_words:			;zero a word at a time
	mov	edx,ecx		;save number of bytes to zero
	slr	ecx,1		;ecx = # of words to zero
	rep
	stosw			;zero them!
	test	edx,1		;an odd byte left over
	jnz	zero_odd_byte	;yes: zero it
	pop	eax		; restore eax (ntntnt)
	ret			;no: all done
;
;
zero_bytes:			;zero a byte at a time
	rep
	stosb			;zero them!
	pop	eax		; restore eax (ntntnt)
	ret			;bd, bd, bdea, that's all, folks!
;
;
;
; *************************************
; *****  Assign Composite String  *****  fills extra bytes with 0x20
; *************************************
;
; edi = destination address	(address of Fixed String in composite)
; esi = source address		(address of Elastic String)
; ecx = number of bytes in composite string
;
; fixed strings do NOT have an extra 0x00 byte
; source must be 0x00 terminated
;
%_assignCompositeString.v:
mov	edx, 0			; don't free source string after
jmp	short acs_start		;
;
%_assignCompositeString.s:
mov	edx, esi		; free source string after
;;
acs_start:
push	eax			; save eax (ntntnt)
push	ebp			; framewalk support
mov	ebp, esp		; framewalk support
sub	esp, 64			; create local frame (workspace)
;
mov	[esp], edx		; save string to free after
or	edi, edi		;
jz	short acs_done		; if destination address = 0, do nothing
cmp	ecx, 0			;
jbe	short acs_done		; if destination length <= 0, do nothing
;;
;;
xor	ebx, ebx		; ebx = byte offset = 0 to start
or	esi, esi		;
jz	short acs_pad		; if source = "", just pad with spaces
mov	edx, [esi-8]		; edx = source length
or	edx, edx		;
jz	short acs_pad		; if source = "", just pad with spaces
;;
;;
acs_copy:
mov	al, [esi+ebx]		; read from source
dec	edx			; edx = one less source byte left
mov	[edi+ebx], al		; write to destination
dec	ecx			; one less byte to copy
inc	ebx			; offset to next byte
or	ecx, ecx		;
jz	acs_done		; destination filled
or	edx, edx		;
jnz	short acs_copy		; if source not depleated, copy next byte
;;
;;
acs_pad:
mov	eax, 0x20		; eax = space character (padding)
mov	[edi+ebx], al		; write space to destination
inc	ebx			; offset to next byte
dec	ecx			; one less byte to write
jnz	short acs_pad		; write more until count = 0
;;
;;
acs_done:
mov	esi, [esp]		; string to free
or	esi, esi		;
jnz	short asc_zip		; none to free
call	%____free		; free string
;;
asc_zip:
mov	esp, ebp		;
pop	ebp			;
pop	eax			; restore eax (ntntnt)
ret				; return to caller
;
;
;
; *************************************
; *****  Assign Composite String  *****  fills extra bytes with 0x00
; *************************************
;
; edi = destination address	(address of Fixed String in composite)
; esi = source address		(address of Elastic String)
; ecx = number of bytes in fixed string
;
; fixed Strings do NOT have an extra NULL byte
; source must be NULL terminated
;
%_assignCompositeStringlet.v:
mov	edx, 0			; don't free source string after
jmp	short zacs_start	;
;
%_assignCompositeStringlet.s:
mov	edx, esi		; free source string after
;;
zacs_start:
push	eax			; save eax (ntntnt)
push	ebp			; framewalk support
mov	ebp, esp		; framewalk support
sub	esp, 64			; create local frame (workspace)
;
mov	[esp], edx		; save string to free after
or	edi, edi		;
jz	short zacs_done		; if destination address = 0, do nothing
cmp	ecx, 0			;
jbe	short zacs_done		; if destination length <= 0, do nothing
;;
;;
xor	ebx, ebx		; ebx = byte offset = 0 to start
or	esi, esi		;
jz	short zacs_pad		; if source = "", just pad with spaces
mov	edx, [esi-8]		; edx = source length
or	edx, edx		;
jz	short zacs_pad		; if source = "", just pad with spaces
;;
;;
zacs_copy:
mov	al, [esi+ebx]		; read from source
dec	edx			; edx = one less source byte left
mov	[edi+ebx], al		; write to destination
dec	ecx			; one less byte to copy
inc	ebx			; offset to next byte
or	ecx, ecx		;
jz	short zacs_done		; destination filled
or	edx, edx		;
jnz	short zacs_copy		; if source not depleated, copy next byte
;;
;;
zacs_pad:
xor	eax,eax			; eax = 0x00 byte (padding)
mov	[edi+ebx], al		; write space to destination
inc	ebx			; offset to next byte
dec	ecx			; one less byte to write
jnz	short zacs_pad		; write more until count = 0
;;
;;
zacs_done:
mov	esi, [esp]		; string to free
or	esi, esi		;
jnz	short zasc_zip		; none to free
call	%____free		; free string
;;
zasc_zip:
mov	esp, ebp		;
pop	ebp			;
pop	eax			; restore eax (ntntnt)
ret				; return to caller
;
;
;
;
; ****************************
; *****  %_VarargArrays  *****
; ****************************
;
; Create three arrays for "Vararg" functions... Func (???)
;   1.  argTypes[]	64 element XLONG array
;   2.  argStrings$[]	64 element STRING array
;   3.  argNumbers$$[]	64 element GIANT array
;
%_VarargArrays:
ret
;subu	r31,r31,0x0080		; create frame
;st	r1,r31,0x006C		; save return address
;or	r28,r0,1
;or.u	r29,r0,0xC008
;or	r29,r29,0x0004
;st.d	r28,r31,0x0010
;or	r26,r0,64
;st	r26,r31,0x0020
;or	r26,r0,0
;bsr	%_DimArray
;st	r26,r31,0x0040
;or	r28,r0,1
;or.u	r29,r0,0xC013
;or	r29,r29,0x0004
;st.d	r28,r31,0x0010
;or	r26,r0,64
;st	r26,r31,0x0020
;or	r26,r0,0
;bsr	%_DimArray
;st	r26,r31,0x0044
;or	r28,r0,1
;or.u	r29,r0,0xC00C
;or	r29,r29,0x0008
;st.d	r28,r31,0x0010
;or	r26,r0,64
;st	r26,r31,0x0020
;or	r26,r0,0
;bsr	%_DimArray
;or	r28,r0,r26		; r28 = argNumber$$[]
;ld	r1,r31,0x006C		; restore return address
;ld.d	r26,r31,0x0040		; r26/r27 = argType[], argString$[]
;jmp.n	r1			; return
;addu	r31,r31,0x0080		; restore frame
;
;
;
%_endAlloCode:
.dword	0, 0, 0, 0, 0, 0, 0, 0
.dword	0, 0, 0, 0, 0, 0, 0, 0
;
;
.text
;
; #####################
; #####  xlibp.s  #####  XstStringToNumber ()
; #####################
;
; *******************************
; *****  XstStringToNumber  *****
; *******************************
;
; XstStringToNumber (text$, startOffset, afterOffset, valueType, value$$)
;
; in:	arg4 = ignored
;	arg3 = ignored
;	arg2 = ignored
;	arg1 = (zero-biased) start offset into text$
;	arg0 -> text$, string from which to parse a number
; out:	eax = "explicit" type (see below)
;	arg4 = SINGLE, DOUBLE, or GIANT value of number parsed [ebp+24]:[ebp+28]
;	arg3 = valueType (see below)				[ebp+20]
;	arg2 = (zero-biased) offset into text$ of character	[ebp+16]
;	       after last character from text$ that was part
;	       of parsed number
;	arg1 = unchanged					[ebp+12]
;	arg0 = unchanged					[ebp+8]
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = hi (most significant) 32 bits of integer result
;	[ebp-8] = lo (least significant) 32 bits of integer result
;	[ebp-12] = current state (see "state table" at end of this file)
;	[ebp-16] = number of digits received so far
;	[ebp-20] = hi 32 bits of double result
;	[ebp-24] = lo 32 bits of double result / single result
;	[ebp-28] = sign of result (0 = positive, -1 = negative)
;	[ebp-32] = exponent
;	[ebp-36] = return value
;	[ebp-40] = current character
;	[ebp-44] = 0 if nothing in st(0), 1 if result in st(0)
;	[ebp-48] = number of digits after decimal point received so far
;	[ebp-52] = number of exponent digits
;	[ebp-56] = sign of exponent (0 = positive, -1 = negative)
;	[ebp-60] = minimum number of digits for number to be legal
;	[ebp-64] = minimum number of digits for exponent to be legal
;	[ebp-68] = force type (for example: > 8 hex digits = giant)
;
; Characters <= space (0x20) and > 0x80 at the beginning of text$ (actually,
; starting at text${startOffset}) are skipped.
;
; On exit, the return value (eax) is set according to the following rules:
;
;	1. If number starts with "0s", then return value = $$SINGLE.
;
;	2. If number starts with "0d", then return value = $$DOUBLE.
;
;	3. If number is invalid or there was no number, then return value = -1.
;
;	4. Otherwise, return value = 0.
;
; On exit, arg3 (valueType) is set according to the following rules:
;
;	1. If return value == $$SINGLE or return value == $$DOUBLE,
;	   valueType = return value.
;
;	2. If the number was floating-point, valueType = $$DOUBLE.
;
;	3. If number was integer and could not fit in an SLONG,
;	   valueType = $$GIANT.
;
;	4. If there was no number, valueType = 0.
;
;	5. Otherwise, valueType = $$XLONG.
;
; The number stored in arg4 on exit has the type indicated by valueType (arg3).
;
; Number formats:  ("n" = decimal digit; "h" = hexadecimal digit; "O" =
; octal digit; "B" = binary digit; "+" = plus or minus)
;
;	Format			Type of result
;	------			--------------
;	nnnnn			integer
;	nnnnn.			floating-point
;	nnnnn.e+nn		floating-point
;	nnnnn.d+nn		floating-point
;	0xhhhhhh		integer
;	0oOOOOOO		integer
;	0bBBBBBB		integer
;	0shhhhhhhh		single-precision floating-point
;	0dhhhhhhhhhhhhhhhh	double-precision floating-point
;
; Complete documentation on the formats in which numbers are represented
; in strings is in the XBasic Language Description.
;
; See STATE TABLE, near end of file, for outline of algorithm.
;
_XstStringToNumber@24:
	push	ebp
	mov	ebp,esp
	sub	esp,80
;;
	xor	eax,eax		;ready to initialize some variables
	mov	[ebp-4],eax
	mov	[ebp-8],eax	;integer result = 0
	mov	[ebp-12],ST_START ;current state = ST_START
	mov	[ebp-16],eax	;number of digits received so far = 0
	mov	[ebp-20],eax
	mov	[ebp-24],eax	;floating-point result = 0
	mov	[ebp-28],eax	;sign of result = positive
	mov	[ebp-32],eax	;exponent = 0
	mov	[ebp+20],8	;valueType = $$XLONG
	mov	[ebp-36],eax	;return value = 0
	mov	[ebp-44],eax	;there's nothing in st(0) yet
	mov	[ebp-48],eax	;# digits after decimal point = 0
	mov	[ebp-52],eax	;# of exponent digits = 0
	mov	[ebp-56],eax	;sign of exponent = positive
	mov	[ebp-60],eax	;minimum number of digits for number to be
				; legal = 0
	mov	[ebp-64],eax	;no exponent is necessary
	mov	[ebp-68],eax	;forcetype = 0 = none
;;
	mov	ecx,[ebp+12]	;ecx = startOffset
	mov	[ebp+16],ecx	;afterOffset = startOffset
;;
	mov	esi,[ebp+8]	;esi -> text$
	or	esi,esi		;null pointer?
	jz	short done	;yes: nothing to do
;;
main_loop_top:			;assuming: esi -> text$, ecx = afterOffset
	cmp	ecx,[esi-8]	;past end of text$?
	jae	short done	;yes: no characters left to parse
;;
	movzx	eax,byte ptr [esi+ecx] ;eax = current character
	mov	ebx,[ebp-12]	;ebx -> first structure for current state
;;
struct_loop_top:
	cmp	eax,[ebx+0]	;eax >= lower bound?
	jb	short try_next_struct ;no: no match
	cmp	eax,[ebx+4]	;eax <= upper bound?
	ja	short try_next_struct ;no: no match
;;
	mov	[ebp-40],eax	;save current character
	mov	edx,[ebx+12]	;eax = next state
	mov	[ebp-12],edx	;new current state
	jmp	[ebx+8]		;go to action routine for current structure
;
try_next_struct:
	add	ebx,16		;ebx -> next structure for current state
	jmp	struct_loop_top
;
next_char:
	mov	esi,[ebp+8]	;esi -> text$
	mov	ecx,[ebp+16]	;ecx = afterOffset -> current char
	inc	ecx		;bump character pointer
	mov	[ebp+16],ecx	;save it
	jmp	main_loop_top
;
done_inc:			;done, but bump afterOffset before exiting
	inc	[ebp+16]	;bump afterOffset
;;
done:
	cmp	[ebp-16],0	;received any digits at all?
	jz	no_number	;nope: error return
;;
;; if floating-point number and had exponent, adjust number for exponent
;;
	cmp	[ebp-44],0	;result is in st(0)?
	je	short make_arg4	;no: all done
	cmp	[ebp-52],0	;at least one exponent digit?
	je	short exponent_done ;no: no need to adjust for exponent
;;
	mov	edx,[ebp-32]	;edx = exponent
	cmp	[ebp-56],0	;sign of exponent is negative?
	je	short exponent_adjust ;no
	neg	edx		;yes: now edx really = exponent
;;
exponent_adjust:
	add	edx,308		;exponent table begins at -308
	fld	qword ptr [%_pwr_10_table + edx*8] ;load exponent multiplier
	fmul			;multiply result by exponent multiplier
	fwait
;;
exponent_done:
	cmp	[ebp-28],0	;sign is negative?
	je	short store_float_result ;no
	fchs			;yes: make result negative
store_float_result:
	fstp	qword ptr [ebp-24] ;store result
;;
make_arg4:
	mov	eax,[ebp+20]	;eax = valueType
	cmp	eax,13		;$$SINGLE?
	je	short make_single ;yes: go do it
	cmp	eax,14		;$$DOUBLE?
	je	short make_double ;yes: go do it
;;
;; result is an integer
;;
	mov	edx,[ebp-4]		; edx = hi 32 bits of result
	mov	eax,[ebp-8]		; eax = lo 32 bits of result
;;
	or	edx,edx			; anything in hi 32 bits?
	jnz	short integer_giant 	; yes, so result is GIANT
;;
	mov	ecx,[ebp-68]		; eax = force type
	cmp	ecx,12			; GIANT ???
	je	short integer_giant	; yes
;;
	cmp	ecx,8			; valueType == XLONG ???
	mov	[ebp+20],8		; valueType = XLONG
	je	short integer_xlong	; yes
;;
	or	eax,eax			; sign bit in low 32 bits?
	js	short integer_giant 	; yes, so result is GIANT
;;
hd_32:
	mov	[ebp+20],6	;valueType = $$SLONG
;;
integer_xlong:
	cmp	[ebp-28],0	;sign is positive?
	je	short xlong_sign_ok ;yes
	neg	eax		;no: negate result
;;
xlong_sign_ok:
	mov	[ebp+24],eax	;store result to lo 32 bits of arg4
	mov	[ebp+28],0	;hi 32 bits of arg4 = 0
	jmp	short validity_check
;
integer_giant:
	mov	[ebp+20],12	;valueType = $$GIANT
	cmp	[ebp-28],0	;sign is positive?
	je	short giant_sign_ok ;yes
	not	edx		;no: negate result
	neg	eax
	sbb	edx,-1
giant_sign_ok:
	mov	[ebp+24],eax	;store lo 32 bits of result
	mov	[ebp+28],edx	;store hi 32 bits of result
	jmp	short validity_check
;
make_single:
	mov	eax,[ebp-24]	;eax = result
	mov	[ebp+24],eax	;store result into arg4
	mov	[ebp+28],0	;clear high 32 bits of arg4
	jmp	short validity_check
;
make_double:
	fwait
	mov	eax,[ebp-24]	;eax = lo 32 bits of result
	mov	[ebp+24],eax	;store lo 32 bits of result into arg4
	mov	eax,[ebp-20]	;eax = hi 32 bits of result
	mov	[ebp+28],eax	;store hi 32 bits of result into arg4
;;
validity_check:
	mov	eax,[ebp-36]	;eax = return value
	mov	ebx,[ebp-60]	;ebx = minimum number of digits to be legal
	cmp	ebx,[ebp-16]	;received enough digits?
	ja	short invalidate_number ;no
;;
	mov	ebx,[ebp-64]	;ebx = minimum number of digits in exponent
	cmp	ebx,[ebp-52]	;received enough digits in exponent?
	ja	short invalidate_number ;no
;;
stn_exit:
	mov	esp,ebp
	pop	ebp
	ret	24		; ;;;
;
;
no_number:
	xor	eax,eax		;ready to write some zeros
	mov	[ebp+20],eax	;valueType = 0, to indicate that no number
				; was found
	mov	[ebp+24],eax	;set result to 0, too
	mov	[ebp+28],eax
	dec	eax		;return value = -1
	mov	esp,ebp
	pop	ebp
	ret	24		; ;;;
;
;
invalidate_number:
	mov	eax,-1		;return value = -1 to indicate invalid number
	jmp	stn_exit
;
;
stn_abort:
	mov	[ebp-36],-1	;mark that current number is invalid
	jmp	done
;
; *****************************
; *****  ACTION ROUTINES  *****  routines pointed to in state table,
; *****************************  except for next_char
;
; in:	eax = current character
;
; All action routines jump to either next_char or done on completion.
;
add_dec_digit:			;multiply current integer result by 10
				; and add current digit in
	mov	edx,[ebp-4]	;edx = hi 32 bits of integer
	cmp	edx,0x10000000	;number getting too big to fit in integer?
	ja	short too_big_for_int ;yes
	mov	eax,[ebp-8]	;eax = lo 32 bits of integer
;;
	sll	eax,1
	rcl	edx,1		;edx:eax = integer * 2
	mov	ebx,eax
	mov	ecx,edx		;ecx:ebx = integer * 2
	shld	edx,eax,2
	sll	eax,2		;edx:eax = integer * 8
	add	eax,ebx
	adc	edx,ecx		;edx:eax = integer*8 + integer*2 = integer*10
;;
	mov	ebx,[ebp-40]	;ebx = current character
	sub	ebx,'0'		;ebx = current digit
	add	eax,ebx		;add in current digit
	adc	edx,0		;propagate carry bit
;;
	mov	[ebp-4],edx	;save hi 32 bits of integer
	mov	[ebp-8],eax	;save lo 32 bits of integer
	inc	[ebp-16]	;bump digit counter
	jmp	next_char
;
;
too_big_for_int:
	fild	qword ptr [ebp-8] ;st(0) = integer built so far
	mov	[ebp+20],14	;valueType = $$DOUBLE
	mov	[ebp-44],1	;mark that result is in st(0)
	mov	[ebp-12],ST_IN_FLOAT ;switch to floating-point state
;;
;; fall through
;;
add_float_digit:		;add a digit to floating-point number
				; before decimal point
	fimul	dword ptr [ten]	;old result *= 10
	sub	[ebp-40],'0'	;current character = current digit
	fiadd	dword ptr [ebp-40] ;add current digit into result
	inc	[ebp-16]	;bump digit counter
	jmp	next_char
;
;
sign_negative:			;set sign to negative
	mov	[ebp-28],-1
	jmp	next_char
;
;
type_double:			;set type to $$DOUBLE
				;once a floating-point number has been
				; detected, its running value is kept in
				; st(0), until the decimal point is found
	fild	qword ptr [ebp-8] ;convert current integer to floating-point
	mov	[ebp+20],14	;valueType = $$DOUBLE
	mov	[ebp-44],1	;mark that result is in st(0)
	jmp	next_char
;
;
begin_simage:			;set type to $$SINGLE and accumulate
				; result in [ebp-20]
	mov	[ebp+20],13	;valueType = $$SINGLE
	mov	[ebp-36],13	;return value = $$SINGLE
	mov	[ebp-16],0	;digit count = 0
	mov	[ebp-60],8	;minimum number of digits to be legal = 8
	jmp	next_char
;
;
begin_dimage:			;set type to $$DOUBLE and accumulate
				; result in [ebp-20]:[ebp-24]
	mov	[ebp+20],14	;valueType = $$DOUBLE
	mov	[ebp-36],14	;return value = $$DOUBLE
	mov	[ebp-16],0	;digit count = 0
	mov	[ebp-60],16	;minimum number of digits to be legal = 16
	jmp	next_char
;
;
add_hex_digit:			;multiply current integer by 16 and add
				; in current digit
	mov	ebx,[ebp-8]	;ebx = lo 32 bits of current integer
	mov	ecx,[ebp-4]	;ecx = hi 32 bits of current integer
	shld	ecx,ebx,4
	sll	ebx,4		;ebx:ecx = integer * 16

	movzx	eax,byte ptr [%_lctouc+eax] ;convert current char to upper case
	sub	eax,'0'		;eax = current digit
	cmp	eax,9		;was it A,B,C,D,E, or F?
	jbe	short hd_add	;no: eax really is current digit
	sub	eax,7		;now eax really is current digit
;;
hd_add:				;eax = current digit
	or	ebx,eax		;add in current digit
	mov	[ebp-8],ebx	;save lo 32 bits of integer
	mov	[ebp-4],ecx	;save hi 32 bits of integer

	mov	eax,[ebp-16]	;eax = number of digits read so far
	inc	eax		;bump digit counter
	mov	[ebp-16],eax	;save digit counter
	cmp	eax,9		;digits beyond XLONG ???
	jnz	short hd_long	;not yet
	mov	[ebp-68],12	;yes, so force hex # to GIANT
;;
hd_long:
	cmp	eax,16		;reached last (16th) possible hex digit?
	jae	no_more_digits	;yes: don't read any more
	jmp	next_char
;
;
add_bin_digit:			;multiply current integer by 2 and add
				; in current digit
	mov	ebx,[ebp-8]	;ebx = lo 32 bits of current integer
	mov	ecx,[ebp-4]	;ecx = hi 32 bits of current integer
	sll	ebx,1
	rcl	ecx,1		;ecx:ebx = integer * 2

	sub	eax,'0'		;eax = current digit
	or	ebx,eax		;add in current digit
	mov	[ebp-8],ebx	;save lo 32 bits of integer
	mov	[ebp-4],ecx	;save hi 32 bits of integer

	mov	eax,[ebp-16]	;eax = number of digits read so far
	inc	eax		;bump digit counter
	mov	[ebp-16],eax	;save digit counter
	cmp	eax,64		;reached last (64th) possible binary digit?
	jae	no_more_digits	;yes: don't read any more
	jmp	next_char
;
;
add_oct_digit:			;multiply current integer by 8 and add
				; in current digit
	mov	ebx,[ebp-8]	;ebx = lo 32 bits of current integer
	mov	ecx,[ebp-4]	;ecx = hi 32 bits of current integer
	shld	ecx,ebx,3
	sll	ebx,3		;ecx:ebx = integer * 8

	sub	eax,'0'		;eax = current digit
	or	ebx,eax		;add in current digit
	mov	[ebp-8],ebx	;save lo 32 bits of integer
	mov	[ebp-4],ecx	;save hi 32 bits of integer

	mov	eax,[ebp-16]	;eax = number of digits read so far
	inc	eax		;bump digit counter
	mov	[ebp-16],eax	;save digit counter
	cmp	eax,22		;reached last (22nd) possible octal digit?
	jae	no_more_digits	;yes: don't read any more
	jmp	next_char
;
;
add_simage_digit:		;append current hex digit to SINGLE result
	movzx	eax,byte ptr [%_lctouc+eax] ;convert current char to upper case
	sub	eax,'0'		;eax = current digit
	cmp	eax,9		;was it A,B,C,D,E, or F?
	jbe	short simage_hd_ok ;no: eax really is current digit
	sub	eax,7		;now eax really is current digit
;;
simage_hd_ok:
	mov	ecx,[ebp-16]	;ecx = number of digits read so far
	sll	eax,28		;move digit up to very top of eax
	mov	ebx,ecx		;save number of digits read so far
	sll	ecx,2		;ecx = number of digits * 4 = # of bits to shift
	slr	eax,cl		;move digit to correct position in eax
	or	[ebp-24],eax	;add in digit to SINGLE result
;;
	inc	ebx		;bump digit counter
	mov	[ebp-16],ebx	;save digit counter
	cmp	ebx,8		;reached last (8th) possible hex digit?
	jae	short no_more_digits ;yes: don't read any more
	jmp	next_char
;
;
add_dimage_digit:		;append current hex digit to DOUBLE result
	movzx	eax,byte ptr [%_lctouc+eax] ;convert current char to upper case
	sub	eax,'0'		;eax = current digit
	cmp	eax,9		;was it A,B,C,D,E, or F?
	jbe	short dimage_hd_ok ;no: eax really is current digit
	sub	eax,7		;now eax really is current digit
;;
dimage_hd_ok:
	mov	ecx,[ebp-16]	;ecx = number of digits read so far
	sll	eax,28		;move digit up to very top of eax
	mov	ebx,ecx		;save number of digits read so far
	sll	ecx,2		;ecx = number of digits * 4 = # of bits to shift
	slr	eax,cl		;move digit to correct position in eax
	cmp	ebx,8		;digit is in second word?
	jae	short dimage_loword ;yes
;;
dimage_hiword:
	or	[ebp-20],eax	;move digit into DOUBLE result
	jmp	short dimage_done
;
;
dimage_loword:
	or	[ebp-24],eax	;move digit into DOUBLE result
;;
dimage_done:
	inc	ebx		;bump digit counter
	mov	[ebp-16],ebx	;save digit counter
	cmp	ebx,16		;reached last (16th) possible hex digit?
	jae	short no_more_digits ;yes: don't read any more
	jmp	next_char
;
;
no_more_digits:			; set state so that if a hex digit comes
				; next, the number is considered invalid
	mov	[ebp-12],ST_NUMERIC_BAD
	jmp	next_char
;
;
add_after_point:		;add a digit after the decimal point
	mov	edx,[ebp-48]	;edx = # of digits after dec point rec'd so far
	cmp	edx,308		;if 308 or more, digit is of no significance,
	ja	next_char	; so throw it away
;;
	sub	[ebp-40],'0'	;convert current character to current digit
	fild	dword ptr [ebp-40] ;st(0) = current digit, st(1) = n
	inc	edx		;bump digit-after-dec-point counter
	mov	[ebp-48],edx	;save it for next time
	neg	edx		;edx = offset relative to 10^0
	fld	qword [%_pwr_10_to_0 + edx*8] ;load multiplier for current digit
	fmul			;st(0) = digit * 10^-position
	fadd			;st(0) = new n
	inc	[ebp-16]	;bump digit counter
	jmp	next_char
;
;
add_exp_digit:			;add a digit to the exponent
	mov	ebx,[ebp-32]	;ebx = current exponent
	sub	eax,'0'		;eax = current digit
	imul	ebx,ebx,10	;current exponent *= 10
	add	ebx,eax		;add in current digit

	cmp	ebx,308		;exponent greater than can be represented?
	ja	stn_abort	;yes: entire number is invalid

	mov	[ebp-32],ebx	;save new current exponent
	inc	[ebp-52]	;bump counter of exponent digits
	jmp	next_char
;
;
exp_negative:			; make exponent negative
	mov	[ebp-56],-1	; sign = negative
;;
;; fall through
;;
need_exponent:			; mark that we must have an exponent, or
	mov	[ebp-64],1	; number is invalid
	jmp	next_char
;
;
bump_digit_count:		; just bump digit counter, and ignore
	inc	[ebp-16]	; current digit
	jmp	next_char
;
;
clear_digit_count:		; set digit counter back to zero
	mov	[ebp-68],8	; 0x and 0o and 0b produce XLONG or GIANT
	mov	[ebp-16],0
	jmp	next_char
;
;
;
; ##################
; #####  DATA  #####  XstStringToNumber()
; ##################
;
.text
.align	8
ten:	.dword	10		;a place in memory guaranteed to contain 10
;
; *************************
; *****  STATE TABLE  *****
; *************************
;
; Each "state" of the parser has a list of structures, each of which
; contains four dwords:
;
;	0	lower bound of range for current character
;	1	upper bound of range for current character
;	2	location to jump to if current character is in range
;		specified by dwords 0 and 1
;	3	state to change to if current character is in range
;		specified by dwords 0 and 1
;
; The last such structure in each state's list has a lower bound of
; 0x00 and an upper bound of 0xFF, so that it catches all possible
; characters.  Each time a new character is retrieved from text$,
; XstStringToNumber checks it against each structure in turn, starting
; with the structure pointed to by the "current state" variable,
; until one is found that matches the current character.  XstStringToNumber
; then jumps to the location given in dword 2, and changes the "current
; state" variable to the value in dword 3.
;
.text
.align	8
ST_START:			;parser starts in this state
	.dword	'0', '0'
	.dword	bump_digit_count
	.dword	ST_GOT_LEAD_ZERO

	.dword	'1', '9'
	.dword	add_dec_digit
	.dword	ST_IN_INT

	.dword	'+', '+'
	.dword	next_char
	.dword	ST_IN_INT

	.dword	'-', '-'
	.dword	sign_negative
	.dword	ST_IN_INT

	.dword	'.', '.'
	.dword	type_double
	.dword	ST_AFTER_DEC_POINT

	.dword	1, 0x20		;ignore leading whitespace
	.dword	next_char
	.dword	ST_START

	.dword	0x80, 0xFF	;ignore leading chars with high bit set
	.dword	next_char
	.dword	ST_START

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_GOT_LEAD_ZERO:
	.dword	'0', '9'
	.dword	add_dec_digit
	.dword	ST_IN_INT

	.dword	'.', '.'
	.dword	type_double
	.dword	ST_AFTER_DEC_POINT

	.dword	'x', 'x'
	.dword	clear_digit_count
	.dword	ST_IN_HEX

	.dword	'o', 'o'
	.dword	clear_digit_count
	.dword	ST_IN_OCT

	.dword	'b', 'b'
	.dword	clear_digit_count
	.dword	ST_IN_BIN

	.dword	's', 's'
	.dword	begin_simage
	.dword	ST_IN_SIMAGE

	.dword	'd', 'd'
	.dword	begin_dimage
	.dword	ST_IN_DIMAGE

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_INT:			;inside an integer or the part of a floating-
	.dword	'0', '9'	; point number that is to the left of the
	.dword	add_dec_digit	; decimal point
	.dword	ST_IN_INT

	.dword	'.', '.'
	.dword	type_double
	.dword	ST_AFTER_DEC_POINT

	.dword	'd', 'd'
	.dword	type_double
	.dword	ST_START_EXP

	.dword	'e', 'e'	;"nnnne+nn" is converted into double-
	.dword	type_double	; precision floating-point, even though
	.dword	ST_START_EXP	; the "e" is supposed to mean "single-precision"

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_FLOAT:			;inside a floating-point number and haven't
	.dword	'0', '9'	; reached the decimal point yet; the only way
	.dword	add_float_digit	; to get to this state is for add_dec_digit
	.dword	ST_IN_FLOAT	; to force the state variable to point to it
				; when the current integer result gets too
	.dword	'.', '.'	; large to hold in a GIANT
	.dword	next_char
	.dword	ST_AFTER_DEC_POINT

	.dword	'd', 'd'
	.dword	next_char
	.dword	ST_START_EXP

	.dword	'e', 'e'
	.dword	next_char
	.dword	ST_START_EXP

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_HEX:
	.dword	'0', '9'
	.dword	add_hex_digit
	.dword	ST_IN_HEX

	.dword	'A', 'F'
	.dword	add_hex_digit
	.dword	ST_IN_HEX

	.dword	'a', 'f'
	.dword	add_hex_digit
	.dword	ST_IN_HEX

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_OCT:
	.dword	'0', '7'
	.dword	add_oct_digit
	.dword	ST_IN_OCT

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_BIN:
	.dword	'0', '1'
	.dword	add_bin_digit
	.dword	ST_IN_BIN

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_SIMAGE:
	.dword	'0', '9'
	.dword	add_simage_digit
	.dword	ST_IN_SIMAGE

	.dword	'A', 'F'
	.dword	add_simage_digit
	.dword	ST_IN_SIMAGE

	.dword	'a', 'f'
	.dword	add_simage_digit
	.dword	ST_IN_SIMAGE

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_DIMAGE:
	.dword	'0', '9'
	.dword	add_dimage_digit
	.dword	ST_IN_DIMAGE

	.dword	'A', 'F'
	.dword	add_dimage_digit
	.dword	ST_IN_DIMAGE

	.dword	'a', 'f'
	.dword	add_dimage_digit
	.dword	ST_IN_DIMAGE

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_AFTER_DEC_POINT:
	.dword	'0', '9'
	.dword	add_after_point
	.dword	ST_AFTER_DEC_POINT

	.dword	'd', 'd'
	.dword	next_char
	.dword	ST_START_EXP

	.dword	'e', 'e'
	.dword	next_char
	.dword	ST_START_EXP

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_START_EXP:
	.dword	'0', '9'
	.dword	add_exp_digit
	.dword	ST_IN_EXP

	.dword	'+', '+'
	.dword	need_exponent
	.dword	ST_IN_EXP

	.dword	'-', '-'
	.dword	exp_negative
	.dword	ST_IN_EXP

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_IN_EXP:
	.dword	'0', '9'
	.dword	add_exp_digit
	.dword	ST_IN_EXP

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START

ST_NUMERIC_BAD:			;reached end of 0s or 0d number; if next
	.dword	'0', '9'	; digit is numeric, then number is too long.
	.dword	stn_abort	; The only way to reach this state is to
	.dword	ST_START	; be forced into it by add_simage_digit
				; or add_dimage_digit
	.dword	'a', 'f'
	.dword	stn_abort
	.dword	ST_START

	.dword	'A', 'F'
	.dword	stn_abort
	.dword	ST_START

	.dword	0x00, 0xFF
	.dword	done
	.dword	ST_START
;
;
; ***************************
; *****  POWERS OF TEN  *****
; ***************************
;
; First element of table is 10^-308; last element is 10^308.  All
; elements are in double precision.
;
.text
.align	8
%_pwr_10_table:
	.dword	0x7819E8D3, 0x000730D6, 0x2C40C60E, 0x0031FA18
	.dword	0x3750F792, 0x0066789E, 0xC5253576, 0x009C16C5
	.dword	0x9B374169, 0x00D18E3B, 0x820511C3, 0x0105F1CA
	.dword	0x22865634, 0x013B6E3D, 0x3593F5E0, 0x017124E6
	.dword	0xC2F8F358, 0x01A56E1F, 0xB3B7302D, 0x01DAC9A7
	.dword	0xD0527E1D, 0x0210BE08, 0x04671DA4, 0x0244ED8B
	.dword	0xC580E50D, 0x027A28ED, 0x9B708F28, 0x02B05994
	.dword	0xC24CB2F2, 0x02E46FF9, 0x32DFDFAE, 0x03198BF8
	.dword	0x3F97D799, 0x034FEEF6, 0xE7BEE6C0, 0x0383F559
	.dword	0x61AEA070, 0x03B8F2B0, 0x7A1A488B, 0x03EF2F5C
	.dword	0xCC506D57, 0x04237D99, 0x3F6488AD, 0x04585D00
	.dword	0x4F3DAAD8, 0x048E7440, 0x31868AC7, 0x04C308A8
	.dword	0x3DE82D79, 0x04F7CAD2, 0xCD6238D8, 0x052DBD86
	.dword	0x405D6387, 0x05629674, 0x5074BC69, 0x05973C11
	.dword	0xA491EB82, 0x05CD0B15, 0x86DB3332, 0x060226ED
	.dword	0xE891FFFF, 0x0636B0A8, 0x22B67FFE, 0x066C5CD3
	.dword	0xF5B20FFE, 0x06A1BA03, 0xF31E93FE, 0x06D62884
	.dword	0x2FE638FD, 0x070BB2A6, 0xDDEFE39E, 0x07414FA7
	.dword	0xD56BDC85, 0x0775A391, 0x4AC6D3A7, 0x07AB0C76
	.dword	0xEEBC4448, 0x07E0E7C9, 0x6A6B555A, 0x081521BC
	.dword	0x85062AB1, 0x084A6A2B, 0x3323DAAF, 0x0880825B
	.dword	0xFFECD15A, 0x08B4A2F1, 0x7FE805B1, 0x08E9CBAE
	.dword	0x0FF1038F, 0x09201F4D, 0x53ED4473, 0x09542720
	.dword	0x68E89590, 0x098930E8, 0x8322BAF4, 0x09BF7D22
	.dword	0x91F5B4D9, 0x09F3AE35, 0xF673220F, 0x0A2899C2
	.dword	0xB40FEA93, 0x0A5EC033, 0x5089F29C, 0x0A933820
	.dword	0x64AC6F43, 0x0AC80628, 0x7DD78B14, 0x0AFE07B2
	.dword	0x8EA6B6EC, 0x0B32C4CF, 0x725064A7, 0x0B677603
	.dword	0x4EE47DD1, 0x0B9D5384, 0xB14ECEA3, 0x0BD25432
	.dword	0x5DA2824B, 0x0C06E93F, 0x350B22DE, 0x0C3CA38F
	.dword	0x8126F5CA, 0x0C71E639, 0xE170B33D, 0x0CA65FC7
	.dword	0xD9CCE00D, 0x0CDBF7B9, 0x28200C08, 0x0D117AD4
	.dword	0x32280F0A, 0x0D45D989, 0x7EB212CC, 0x0D7B4FEB
	.dword	0x2F2F4BBF, 0x0DB111F3, 0xFAFB1EAF, 0x0DE5566F
	.dword	0xF9B9E65B, 0x0E1AAC0B, 0x7C142FF9, 0x0E50AB87
	.dword	0x5B193BF8, 0x0E84D669, 0xB1DF8AF5, 0x0EBA0C03
	.dword	0x4F2BB6DA, 0x0EF04782, 0xE2F6A490, 0x0F245962
	.dword	0x9BB44DB4, 0x0F596FBB, 0x82A16122, 0x0F8FCBAA
	.dword	0x91A4DCB5, 0x0FC3DF4A, 0x360E13E2, 0x0FF8D71D
	.dword	0x839198DA, 0x102F0CE4, 0xD23AFF88, 0x1063680E
	.dword	0x86C9BF6A, 0x10984212, 0x287C2F45, 0x10CE5297
	.dword	0x794D9D8B, 0x1102F39E, 0x17A104EE, 0x1137B086
	.dword	0x9D894628, 0x116D9CA7, 0xC275CBD9, 0x11A281E8
	.dword	0xF3133ECF, 0x11D72262, 0xAFD80E83, 0x120CEAFB
	.dword	0x4DE70912, 0x124212DD, 0xA160CB56, 0x12769794
	.dword	0xC9B8FE2C, 0x12AC3D79, 0x1E139EDB, 0x12E1A66C
	.dword	0x25988692, 0x13161007, 0xEEFEA836, 0x134B9408
	.dword	0x955F2922, 0x13813C85, 0xFAB6F36B, 0x13B58BA6
	.dword	0xB964B045, 0x13EAEE90, 0x73DEEE2C, 0x1420D51A
	.dword	0x10D6A9B6, 0x14550A61, 0x550C5424, 0x148A4CF9
	.dword	0xD527B496, 0x14C0701B, 0xCA71A1BC, 0x14F48C22
	.dword	0x7D0E0A2A, 0x1529AF2B, 0x2E28C65A, 0x15600D7B
	.dword	0xF9B2F7F1, 0x159410D9, 0x781FB5ED, 0x15C91510
	.dword	0x9627A369, 0x15FF5A54, 0xDDD8C622, 0x16339874
	.dword	0x154EF7AA, 0x16687E92, 0x9AA2B594, 0x169E9E36
	.dword	0x20A5B17D, 0x16D322E2, 0xA8CF1DDC, 0x1707EB9A
	.dword	0x5302E553, 0x173DE681, 0xD3E1CF54, 0x1772B010
	.dword	0x08DA4328, 0x17A75C15, 0x4B10D3F2, 0x17DD331A
	.dword	0x6EEA8477, 0x18123FF0, 0x8AA52594, 0x1846CFEC
	.dword	0xAD4E6EFA, 0x187C83E7, 0xCC51055C, 0x18B1D270
	.dword	0xFF6546B3, 0x18E6470C, 0x3F3E9860, 0x191BD8D0
	.dword	0x27871F3C, 0x19516782, 0xB168E70A, 0x1985C162
	.dword	0x5DC320CD, 0x19BB31BB, 0x1A99F480, 0x19F0FF15
	.dword	0x614071A1, 0x1A253EDA, 0xF9908E09, 0x1A5A8E90
	.dword	0x9BFA58C6, 0x1A90991A, 0x42F8EEF7, 0x1AC4BF61
	.dword	0x93B72AB5, 0x1AF9EF39, 0xFC527AB1, 0x1B303583
	.dword	0xFB67195E, 0x1B6442E4, 0x3A40DFB5, 0x1B99539E
	.dword	0xC8D117A2, 0x1BCFA885, 0x9D82AEC5, 0x1C03C953
	.dword	0x84E35A77, 0x1C38BBA8, 0xA61C3115, 0x1C6EEA92
	.dword	0xA7D19EAD, 0x1CA3529B, 0x91C60658, 0x1CD82742
	.dword	0x363787EF, 0x1D0E3113, 0x01E2B4F5, 0x1D42DEAC
	.dword	0x025B6232, 0x1D779657, 0xC2F23ABE, 0x1DAD7BEC
	.dword	0xF9D764B7, 0x1DE26D73, 0xF84D3DE4, 0x1E1708D0
	.dword	0x36608D5D, 0x1E4CCB05, 0x41FC585A, 0x1E81FEE3
	.dword	0x127B6E71, 0x1EB67E9C, 0x171A4A0D, 0x1EEC1E43
	.dword	0xEE706E48, 0x1F2192E9, 0x6A0C89DA, 0x1F55F7A4
	.dword	0x848FAC50, 0x1F8B758D, 0x72D9CBB3, 0x1FC12978
	.dword	0x8F903E9F, 0x1FF573D6, 0x33744E46, 0x202AD0CC
	.dword	0xA028B0EC, 0x2060C27F, 0x8832DD28, 0x2094F31F
	.dword	0x6A3F9471, 0x20CA2FE7, 0xA267BCC6, 0x21005DF0
	.dword	0xCB01ABF8, 0x2134756C, 0xFDC216F5, 0x216992C7
	.dword	0xFD329CB3, 0x219FF779, 0x3E3FA1F0, 0x21D3FAAC
	.dword	0x4DCF8A6D, 0x2208F957, 0x21436D08, 0x223F37AD
	.dword	0x34CA2425, 0x227382CC, 0x41FCAD2E, 0x22A8637F
	.dword	0x127BD87A, 0x22DE7C5F, 0x6B8D674D, 0x23130DBB
	.dword	0x4670C120, 0x2347D12A, 0xD80CF167, 0x237DC574
	.dword	0x070816E1, 0x23B29B69, 0x48CA1C99, 0x23E74243
	.dword	0x1AFCA3BE, 0x241D12D4, 0x90DDE657, 0x24522BC4
	.dword	0xB5155FED, 0x2486B6B5, 0x225AB7E8, 0x24BC6463
	.dword	0xF578B2F1, 0x24F1BEBD, 0x72D6DFAE, 0x25262E6D
	.dword	0xCF8C9799, 0x255BBA08, 0x81B7DEBF, 0x25915445
	.dword	0xE225D66F, 0x25C5A956, 0x9AAF4C0B, 0x25FB13AC
	.dword	0xE0AD8F87, 0x2630EC4B, 0xD8D8F368, 0x2665275E
	.dword	0x8F0F3042, 0x269A7136, 0x19697E29, 0x26D086C2
	.dword	0x9FC3DDB4, 0x2704A872, 0x47B4D521, 0x2739D28F
	.dword	0x8CD10535, 0x27702399, 0xF0054682, 0x27A42C7F
	.dword	0xEC069822, 0x27D9379F, 0xE7083E2C, 0x280F8587
	.dword	0xF06526DB, 0x2843B374, 0x2C7E7091, 0x2878A052
	.dword	0xB79E0CB5, 0x28AEC866, 0x32C2C7F1, 0x28E33D40
	.dword	0x3F7379ED, 0x29180C90, 0x4F505869, 0x294E0FB4
	.dword	0xB1923742, 0x2982C9D0, 0xDDF6C512, 0x29B77C44
	.dword	0x15747656, 0x29ED5B56, 0xCD68C9F6, 0x2A225915
	.dword	0x40C2FC73, 0x2A56EF5B, 0x10F3BB91, 0x2A8CAB32
	.dword	0x4A98553A, 0x2AC1EAFF, 0x1D3E6A89, 0x2AF665BF
	.dword	0xE48E052B, 0x2B2BFF2E, 0x4ED8C33B, 0x2B617F7D
	.dword	0xA28EF40A, 0x2B95DF5C, 0xCB32B10C, 0x2BCB5733
	.dword	0x5EFFAEA7, 0x2C011680, 0x76BF9A51, 0x2C355C20
	.dword	0x946F80E6, 0x2C6AB328, 0x5CC5B090, 0x2CA0AFF9
	.dword	0xB3F71CB4, 0x2CD4DBF7, 0xA0F4E3E2, 0x2D0A12F5
	.dword	0x84990E6D, 0x2D404BD9, 0xE5BF5208, 0x2D745ECF
	.dword	0xDF2F268A, 0x2DA97683, 0xD6FAF02D, 0x2DDFD424
	.dword	0x065CD61D, 0x2E13E497, 0xC7F40BA4, 0x2E48DDBC
	.dword	0xF9F10E8D, 0x2E7F152B, 0x7C36A919, 0x2EB36D3B
	.dword	0x5B44535F, 0x2EE8488A, 0xF2156837, 0x2F1E5AAC
	.dword	0x174D6123, 0x2F52F8AC, 0x1D20B96B, 0x2F87B6D7
	.dword	0xE468E7C5, 0x2FBDA48C, 0x0EC190DC, 0x2FF286D8
	.dword	0x1271F513, 0x3027288E, 0x970E7257, 0x305CF2B1
	.dword	0xFE690777, 0x309217AE, 0xBE034954, 0x30C69D9A
	.dword	0x6D841BA9, 0x30FC4501, 0xE472914A, 0x3131AB20
	.dword	0x1D8F359D, 0x316615E9, 0x64F30304, 0x319B9B63
	.dword	0x1F17E1E2, 0x31D1411E, 0xA6DDDA5B, 0x32059165
	.dword	0x109550F1, 0x323AF5BF, 0x6A5D5296, 0x3270D997
	.dword	0x44F4A73C, 0x32A50FFD, 0x9631D10B, 0x32DA53FC
	.dword	0xDDDF22A7, 0x3310747D, 0x5556EB51, 0x3344919D
	.dword	0xAAACA625, 0x3379B604, 0xEAABE7D8, 0x33B011C2
	.dword	0xA556E1CD, 0x33E41633, 0x8EAC9A41, 0x34191BC0
	.dword	0xB257C0D1, 0x344F62B0, 0x6F76D882, 0x34839DAE
	.dword	0x0B548EA3, 0x34B8851A, 0x8E29B24D, 0x34EEA660
	.dword	0x58DA0F70, 0x352327FC, 0x6F10934C, 0x3557F1FB
	.dword	0x4AD4B81E, 0x358DEE7A, 0x6EC4F313, 0x35C2B50C
	.dword	0x8A762FD8, 0x35F7624F, 0x6D13BBCE, 0x362D3AE3
	.dword	0x242C5561, 0x366244CE, 0xAD376ABA, 0x3696D601
	.dword	0x18854568, 0x36CC8B82, 0x4F534B61, 0x3701D731
	.dword	0xA3281E39, 0x37364CFD, 0x0BF225C8, 0x376BE03D
	.dword	0x2777579D, 0x37A16C26, 0xB1552D85, 0x37D5C72F
	.dword	0x9DAA78E6, 0x380B38FB, 0x428A8B8F, 0x3841039D
	.dword	0x932D2E73, 0x38754484, 0xB7F87A0F, 0x38AA95A5
	.dword	0x92FB4C4A, 0x38E09D87, 0x77BA1F5C, 0x3914C4E9
	.dword	0xD5A8A734, 0x3949F623, 0x65896880, 0x398039D6
	.dword	0xFEEBC2A0, 0x39B4484B, 0xFEA6B348, 0x39E95A5E
	.dword	0xBE50601A, 0x3A1FB0F6, 0x36F23C10, 0x3A53CE9A
	.dword	0xC4AECB15, 0x3A88C240, 0xF5DA7DDA, 0x3ABEF2D0
	.dword	0x99A88EA8, 0x3AF357C2, 0x4012B252, 0x3B282DB3
	.dword	0x10175EE6, 0x3B5E3920, 0x0A0E9B4F, 0x3B92E3B4
	.dword	0x0C924223, 0x3BC79CA1, 0x4FB6D2AC, 0x3BFD83C9
	.dword	0xD1D243AC, 0x3C32725D, 0x4646D497, 0x3C670EF5
	.dword	0x97D889BC, 0x3C9CD2B2, 0x9EE75616, 0x3CD203AF
	.dword	0x86A12B9B, 0x3D06849B, 0x68497682, 0x3D3C25C2
	.dword	0x812DEA11, 0x3D719799, 0xE1796495, 0x3DA5FD7F
	.dword	0xD9D7BDBB, 0x3DDB7CDF, 0xE826D695, 0x3E112E0B
	.dword	0xE2308C3A, 0x3E45798E, 0x9ABCAF48, 0x3E7AD7F2
	.dword	0xA0B5ED8D, 0x3EB0C6F7, 0x88E368F1, 0x3EE4F8B5
	.dword	0xEB1C432D, 0x3F1A36E2, 0xD2F1A9FC, 0x3F50624D
	.dword	0x47AE147B, 0x3F847AE1, 0x9999999A, 0x3FB99999
%_pwr_10_to_0:
	.dword	0x00000000, 0x3FF00000, 0x00000000, 0x40240000
	.dword	0x00000000, 0x40590000, 0x00000000, 0x408F4000
	.dword	0x00000000, 0x40C38800, 0x00000000, 0x40F86A00
	.dword	0x00000000, 0x412E8480, 0x00000000, 0x416312D0
	.dword	0x00000000, 0x4197D784, 0x00000000, 0x41CDCD65
	.dword	0x20000000, 0x4202A05F, 0xE8000000, 0x42374876
	.dword	0xA2000000, 0x426D1A94, 0xE5400000, 0x42A2309C
	.dword	0x1E900000, 0x42D6BCC4, 0x26340000, 0x430C6BF5
	.dword	0x37E08000, 0x4341C379, 0x85D8A000, 0x43763457
	.dword	0x674EC800, 0x43ABC16D, 0x60913D00, 0x43E158E4
	.dword	0x78B58C40, 0x4415AF1D, 0xD6E2EF50, 0x444B1AE4
	.dword	0x064DD592, 0x4480F0CF, 0xC7E14AF6, 0x44B52D02
	.dword	0x79D99DB4, 0x44EA7843, 0x2C280290, 0x45208B2A
	.dword	0xB7320334, 0x4554ADF4, 0xE4FE8401, 0x4589D971
	.dword	0x2F1F1281, 0x45C027E7, 0xFAE6D721, 0x45F431E0
	.dword	0x39A08CE9, 0x46293E59, 0x8808B023, 0x465F8DEF
	.dword	0xB5056E16, 0x4693B8B5, 0x2246C99C, 0x46C8A6E3
	.dword	0xEAD87C03, 0x46FED09B, 0x72C74D82, 0x47334261
	.dword	0xCF7920E2, 0x476812F9, 0x4357691A, 0x479E17B8
	.dword	0x2A16A1B0, 0x47D2CED3, 0xF49C4A1C, 0x48078287
	.dword	0xF1C35CA3, 0x483D6329, 0x371A19E6, 0x48725DFA
	.dword	0xC4E0A060, 0x48A6F578, 0xF618C878, 0x48DCB2D6
	.dword	0x59CF7D4B, 0x4911EFC6, 0xF0435C9E, 0x49466BB7
	.dword	0xEC5433C6, 0x497C06A5, 0xB3B4A05C, 0x49B18427
	.dword	0xA0A1C873, 0x49E5E531, 0x08CA3A90, 0x4A1B5E7E
	.dword	0xC57E649A, 0x4A511B0E, 0x76DDFDC0, 0x4A8561D2
	.dword	0x14957D30, 0x4ABABA47, 0x6CDD6E3E, 0x4AF0B46C
	.dword	0x8814C9CE, 0x4B24E187, 0x6A19FC42, 0x4B5A19E9
	.dword	0xE2503DA9, 0x4B905031, 0x5AE44D13, 0x4BC4643E
	.dword	0xF19D6058, 0x4BF97D4D, 0x6E04B86E, 0x4C2FDCA1
	.dword	0xE4C2F345, 0x4C63E9E4, 0x1DF3B016, 0x4C98E45E
	.dword	0xA5709C1C, 0x4CCF1D75, 0x87666192, 0x4D037269
	.dword	0xE93FF9F6, 0x4D384F03, 0xE38FF874, 0x4D6E62C4
	.dword	0x0E39FB48, 0x4DA2FDBB, 0xD1C87A1A, 0x4DD7BD29
	.dword	0x463A98A0, 0x4E0DAC74, 0xABE49F64, 0x4E428BC8
	.dword	0xD6DDC73D, 0x4E772EBA, 0x8C95390C, 0x4EACFA69
	.dword	0xF7DD43A8, 0x4EE21C81, 0x75D49492, 0x4F16A3A2
	.dword	0x1349B9B6, 0x4F4C4C8B, 0xEC0E1412, 0x4F81AFD6
	.dword	0xA7119916, 0x4FB61BCC, 0xD0D5FF5C, 0x4FEBA2BF
	.dword	0xE285BF9A, 0x502145B7, 0xDB272F80, 0x50559725
	.dword	0x51F0FB60, 0x508AFCEF, 0x93369D1C, 0x50C0DE15
	.dword	0xF8044463, 0x50F5159A, 0xB605557C, 0x512A5B01
	.dword	0x11C3556E, 0x516078E1, 0x56342ACA, 0x51949719
	.dword	0xABC1357C, 0x51C9BCDF, 0xCB58C16E, 0x5200160B
	.dword	0xBE2EF1CA, 0x52341B8E, 0x6DBAAE3C, 0x52692272
	.dword	0x092959CB, 0x529F6B0F, 0x65B9D81F, 0x52D3A2E9
	.dword	0xBF284E27, 0x53088BA3, 0xAEF261B1, 0x533EAE8C
	.dword	0xED577D0F, 0x53732D17, 0xE8AD5C53, 0x53A7F85D
	.dword	0x62D8B368, 0x53DDF675, 0x5DC77021, 0x5412BA09
	.dword	0xB5394C29, 0x5447688B, 0xA2879F33, 0x547D42AE
	.dword	0x2594C380, 0x54B249AD, 0x6EF9F460, 0x54E6DC18
	.dword	0x8AB87178, 0x551C931E, 0x16B346EB, 0x5551DBF3
	.dword	0xDC6018A6, 0x558652EF, 0xD3781ED0, 0x55BBE7AB
	.dword	0x642B1342, 0x55F170CB, 0x3D35D812, 0x5625CCFE
	.dword	0xCC834E16, 0x565B403D, 0x9FD210CE, 0x56910826
	.dword	0x47C69502, 0x56C54A30, 0x59B83A42, 0x56FA9CBC
	.dword	0xB8132469, 0x5730A1F5, 0x2617ED83, 0x5764CA73
	.dword	0xEF9DE8E4, 0x5799FD0F, 0xF5C2B18E, 0x57D03E29
	.dword	0x73335DF2, 0x58044DB4, 0x9000356E, 0x58396121
	.dword	0xF40042CA, 0x586FB969, 0x388029BE, 0x58A3D3E2
	.dword	0xC6A0342E, 0x58D8C8DA, 0x7848413A, 0x590EFB11
	.dword	0xEB2D28C4, 0x59435CEA, 0xA5F872F5, 0x59783425
	.dword	0x0F768FB2, 0x59AE412F, 0x69AA19CF, 0x59E2E8BD
	.dword	0xC414A043, 0x5A17A2EC, 0xF519C854, 0x5A4D8BA7
	.dword	0xF9301D34, 0x5A827748, 0x377C2481, 0x5AB7151B
	.dword	0x055B2DA1, 0x5AECDA62, 0x4358FC85, 0x5B22087D
	.dword	0x942F3BA6, 0x5B568A9C, 0xB93B0A90, 0x5B8C2D43
	.dword	0x53C4E69A, 0x5BC19C4A, 0xE8B62040, 0x5BF6035C
	.dword	0x22E3A850, 0x5C2B8434, 0x95CE4932, 0x5C6132A0
	.dword	0xBB41DB7E, 0x5C957F48, 0xEA12525E, 0x5CCADF1A
	.dword	0xD24B737B, 0x5D00CB70, 0x06DE505A, 0x5D34FE4D
	.dword	0x4895E470, 0x5D6A3DE0, 0x2D5DAEC6, 0x5DA066AC
	.dword	0x38B51A78, 0x5DD48057, 0x06E26116, 0x5E09A06D
	.dword	0x244D7CAE, 0x5E400444, 0x2D60DBDA, 0x5E740555
	.dword	0x78B912D0, 0x5EA906AA, 0x16E75784, 0x5EDF4855
	.dword	0x2E5096B2, 0x5F138D35, 0x79E4BC5E, 0x5F487082
	.dword	0x185DEB76, 0x5F7E8CA3, 0xEF3AB32A, 0x5FB317E5
	.dword	0x6B095FF4, 0x5FE7DDDF, 0x45CBB7F1, 0x601DD557
	.dword	0x8B9F52F7, 0x6052A556, 0x2E8727B5, 0x60874EAC
	.dword	0x3A28F1A2, 0x60BD2257, 0x84599705, 0x60F23576
	.dword	0x256FFCC6, 0x6126C2D4, 0x2ECBFBF8, 0x615C7389
	.dword	0xBD3F7D7B, 0x6191C835, 0x2C8F5CDA, 0x61C63A43
	.dword	0xF7B33410, 0x61FBC8D3, 0x7AD0008A, 0x62315D84
	.dword	0x998400AC, 0x6265B4E5, 0xFFE500D7, 0x629B221E
	.dword	0x5FEF2086, 0x62D0F553, 0x37EAE8A8, 0x630532A8
	.dword	0x45E5A2D2, 0x633A7F52, 0x6BAF85C3, 0x63708F93
	.dword	0x469B6734, 0x63A4B378, 0x58424101, 0x63D9E056
	.dword	0xF72968A1, 0x64102C35, 0x74F3C2C9, 0x64443743
	.dword	0x5230B37B, 0x64794514, 0x66BCE05A, 0x64AF9659
	.dword	0xE0360C38, 0x64E3BDF7, 0xD8438F46, 0x6518AD75
	.dword	0x4E547318, 0x654ED8D3, 0x10F4C7EF, 0x65834784
	.dword	0x1531F9EB, 0x65B81965, 0x5A7E7866, 0x65EE1FBE
	.dword	0xF88F0B40, 0x6622D3D6, 0xB6B2CE10, 0x665788CC
	.dword	0xE45F8194, 0x668D6AFF, 0xEEBBB0FC, 0x66C262DF
	.dword	0xEA6A9D3B, 0x66F6FB97, 0xE505448A, 0x672CBA7D
	.dword	0xAF234AD6, 0x6761F48E, 0x5AEC1D8C, 0x679671B2
	.dword	0xF1A724EF, 0x67CC0E1E, 0x57087715, 0x680188D3
	.dword	0x2CCA94DA, 0x6835EB08, 0x37FD3A10, 0x686B65CA
	.dword	0x62FE444A, 0x68A11F9E, 0xFBBDD55C, 0x68D56785
	.dword	0x7AAD4AB3, 0x690AC167, 0xACAC4EB0, 0x6940B8E0
	.dword	0xD7D7625C, 0x6974E718, 0x0DCD3AF3, 0x69AA20DF
	.dword	0x68A044D8, 0x69E0548B, 0x42C8560E, 0x6A1469AE
	.dword	0xD37A6B92, 0x6A498419, 0x48590676, 0x6A7FE520
	.dword	0x2D37A40A, 0x6AB3EF34, 0x38858D0C, 0x6AE8EB01
	.dword	0x86A6F04F, 0x6B1F25C1, 0xF4285631, 0x6B537798
	.dword	0x31326BBD, 0x6B88557F, 0xFD7F06AC, 0x6BBE6ADE
	.dword	0x5E6F642C, 0x6BF302CB, 0x360B3D37, 0x6C27C37E
	.dword	0xC38E0C85, 0x6C5DB45D, 0x9A38C7D3, 0x6C9290BA
	.dword	0x40C6F9C8, 0x6CC734E9, 0x90F8B83A, 0x6CFD0223
	.dword	0x3A9B7324, 0x6D322156, 0xC9424FED, 0x6D66A9AB
	.dword	0xBB92E3E8, 0x6D9C5416, 0x353BCE71, 0x6DD1B48E
	.dword	0xC28AC20D, 0x6E0621B1, 0x332D7290, 0x6E3BAA1E
	.dword	0xDFFC679A, 0x6E714A52, 0x97FB8180, 0x6EA59CE7
	.dword	0x7DFA61E0, 0x6EDB0421, 0xEEBC7D2C, 0x6F10E294
	.dword	0x2A6B9C77, 0x6F451B3A, 0xB5068395, 0x6F7A6208
	.dword	0x7124123D, 0x6FB07D45, 0xCD6D16CC, 0x6FE49C96
	.dword	0x80C85C7F, 0x7019C3BC, 0xD07D39CF, 0x70501A55
	.dword	0x449C8843, 0x708420EB, 0x15C3AA54, 0x70B92926
	.dword	0x9B3494E9, 0x70EF736F, 0xC100DD12, 0x7123A825
	.dword	0x31411456, 0x7158922F, 0xFD91596C, 0x718EB6BA
	.dword	0xDE7AD7E4, 0x71C33234, 0x16198DDD, 0x71F7FEC2
	.dword	0x9B9FF154, 0x722DFE72, 0xA143F6D4, 0x7262BF07
	.dword	0x8994F489, 0x72976EC9, 0xEBFA31AB, 0x72CD4A7B
	.dword	0x737C5F0B, 0x73024E8D, 0xD05B76CE, 0x7336E230
	.dword	0x04725482, 0x736C9ABD, 0x22C774D1, 0x73A1E0B6
	.dword	0xAB795205, 0x73D658E3, 0x9657A686, 0x740BEF1C
	.dword	0xDDF6C814, 0x74417571, 0x55747A19, 0x7475D2CE
	.dword	0xEAD1989F, 0x74AB4781, 0x32C2FF63, 0x74E10CB1
	.dword	0x7F73BF3C, 0x75154FDD, 0xDF50AF0B, 0x754AA3D4
	.dword	0x0B926D67, 0x7580A665, 0x4E7708C1, 0x75B4CFFE
	.dword	0xE214CAF1, 0x75EA03FD, 0xAD4CFED7, 0x7620427E
	.dword	0x58A03E8D, 0x7654531E, 0xEEC84E30, 0x768967E5
	.dword	0x6A7A61BC, 0x76BFC1DF, 0xA28C7D16, 0x76F3D92B
	.dword	0x8B2F9C5C, 0x7728CF76, 0x2DFB8373, 0x775F0354
	.dword	0x9CBD3228, 0x77936214, 0xC3EC7EB2, 0x77C83A99
	.dword	0x34E79E5E, 0x77FE4940, 0x2110C2FB, 0x7832EDC8
	.dword	0x2954F3BA, 0x7867A93A, 0xB3AA30A8, 0x789D9388
	.dword	0x704A5E69, 0x78D27C35, 0xCC5CF603, 0x79071B42
	.dword	0x7F743384, 0x793CE213, 0x2FA8A032, 0x79720D4C
	.dword	0x3B92C83E, 0x79A6909F, 0x0A777A4E, 0x79DC34C7
	.dword	0x668AAC71, 0x7A11A0FC, 0x802D578D, 0x7A46093B
	.dword	0x6038AD70, 0x7A7B8B8A, 0x7C236C66, 0x7AB13736
	.dword	0x1B2C4780, 0x7AE58504, 0x21F75960, 0x7B1AE645
	.dword	0x353A97DC, 0x7B50CFEB, 0x02893DD3, 0x7B8503E6
	.dword	0x832B8D48, 0x7BBA44DF, 0xB1FB384D, 0x7BF06B0B
	.dword	0x9E7A0660, 0x7C2485CE, 0x461887F8, 0x7C59A742
	.dword	0x6BCF54FB, 0x7C900889, 0xC6C32A3A, 0x7CC40AAB
	.dword	0xB873F4C8, 0x7CF90D56, 0x6690F1FA, 0x7D2F50AC
	.dword	0xC01A973C, 0x7D63926B, 0xB0213D0B, 0x7D987706
	.dword	0x5C298C4E, 0x7DCE94C8, 0x3999F7B1, 0x7E031CFD
	.dword	0x8800759D, 0x7E37E43C, 0xAA009304, 0x7E6DDD4B
	.dword	0x4A405BE2, 0x7EA2AA4F, 0x1CD072DA, 0x7ED754E3
	.dword	0xE4048F90, 0x7F0D2A1B, 0x6E82D9BA, 0x7F423A51
	.dword	0xCA239028, 0x7F76C8E5, 0x3CAC7432, 0x7FAC7B1F
	.dword	0x85EBC89F, 0x7FE1CCF3
;
;
.text
;
; #####################
; #####  xlibs.s  #####  String and PRINT routines
; #####################
;
; ************************
; *****  main.print  *****  main print routine - internal entry point
; ************************
;
; in:	arg1 -> string to print
;	arg0 = file number
; out:	nothing
;
; Destroys: eax, ebx, ecx, edx, esi, edi.
;
main.print:
mainPrint:
	push	ebp
	mov	ebp,esp
;;
print_again:
	mov	eax,[ebp+12]	;eax -> string to print
	or	eax,eax		;null pointer?
	jz	print_null	;yes: do nothing
	push	0		; ntntnt
	push	esp		; ntntnt
	push	[eax-8]		; ntntnt  push "nbytes" parameter
	push	eax		; ntntnt  push "buf" parameter
	mov	eax, [ebp+8]	; ntntnt  eax = fileNumber
	cmp	eax, 2		; ntntnt  is it stdin, stdout, stderr
	jg	prtfile		; ntntnt  no
	mov	eax, 1		; ntntnt  eax = stdout fileNumber
prtfile:
	push	eax		; ntntnt  push fileNumber
	call	_XxxWriteFile@20	; ntntnt ;;;
;;;	add	esp,20		; ntntnt
;;
	or	eax,eax			; error?  (eax < 0 if error)
	jmp	short print_good	; ntntnt  (add error checking)
;
;
	jns	short print_good 	;no: exit
;	cmp	[_errno],4		;yes: EINTR?
	jne	short print_crash 	;no: it was a real error
	cmp	[_##SOFTBREAK],0	;was it a soft break?
	jne	print_again		;no: it was just some blowhard signal
	;tb0	0,r0,509		;SOFTBREAK: LOOSE END
	jmp	print_again
print_crash:
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
;
print_good:
print_null:
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***********************************
; *****  %_PrintConsoleNewline  *****  prints a newline to stdout
; ***********************************
;
; in:	nothing
; out:	nothing
;
; Destroys: eax, ebx, ecx, edx, esi, edi.
;
%_PrintConsoleNewline:
%_print.console.newline:
	push	%_newline.string	;push string to print
	push	1			;push stdout
	call	main.print
	add	esp,8
	ret
;
;
; ********************************
; *****  %_PrintFileNewline  *****  prints a newline to a file
; ********************************
;
; in:	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
%_PrintFileNewline:
;	mov	eax,[esp+4]	;eax = file number
;
; 5/5/93:  compiler doesn't push file number
;
	push	%_newline.string ;push string to print
	push	eax		;push file number
	call	main.print
	add	esp,8
	ret
;
;
; *********************
; *****  %_Print  *****  prints a string
; *********************
;
; in:	eax -> string to print
;	arg0 = file number
; out:	nothing
;
; Destroys: eax, ebx, ecx, edx, esi, edi.
;
; Frees string pointed to by eax before exiting.
;
%_Print:
	push	ebp
	mov	ebp,esp

	push	eax		; push pointer to string to print
	mov	eax, [ebp+8]	; eax = file number
	cmp	eax, 2		; see if STDIN, STDOUT, STDERR
	jl	fpr		; nope, so it's a file print
	mov	eax, 1		; eax = stdout
fpr:
	push	eax		;push file number
	call	main.print	;print the string
	add	esp,8
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *****************************
; *****  %_PrintThenFree  *****  prints a string, then frees it
; *****************************
;
; in:	eax -> string to print
;	arg0 = file number
; out:	nothing
;
; Destroys: eax, ebx, ecx, edx, esi, edi.
;
; Local variables:
;	[ebp-4] -> string to print (on-entry eax)
;
; Frees string pointed to by eax before exiting.
;
%_PrintThenFree:
	push	ebp
	mov	ebp,esp
	sub	esp,4
	mov	[ebp-4],eax	;save pointer
	push	eax		;push pointer to string to print
	push	[ebp+8]		;push file number
	call	main.print	;print the string
	add	esp,8
	mov	esi,[ebp-4]	;esi -> string to free
	call	%____free	;free printed string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; **************************************
; ***** %_PrintWithNewlineThenFree *****
; **************************************
;
; in:	eax -> string to print, followed by newline
;	arg0 = file number
; out:	nothing
;
; Destroys: eax, ebx, ecx, edx, esi, edi.
;
; Local variables:
;	[ebp-4] -> string to print (on-entry eax)
;
; Frees string pointed to by eax before exiting.
;
%_PrintWithNewlineThenFree:
	or	eax,eax		; null pointer?
	jnz	pwntfa		; no
	mov	eax,[esp+4]	; eax = file number
	jmp	%_PrintFileNewline
;
pwntfa:
	push	ebp
	mov	ebp,esp
	sub	esp,4
	mov	[ebp-4],eax	;save pointer
;;
ptfn_again:
	mov	eax,[ebp-4]	;eax -> string to print
	mov	ebx,[eax-8]	;ebx = length of string
	mov	byte ptr [eax+ebx],'\n' ;replace null terminator with newline
	inc	ebx		;ebx = length of string including newline
	push	0		; ntntnt
	push	esp		; ntntnt
	push	ebx		; ntntnt  push "nbytes" parameter
	push	eax		; ntntnt  push "buf" parameter
	mov	eax, [ebp+8]	; ntntnt  eax = fileNumber
	cmp	eax, 2		; ntntnt  is it stdin, stdout, stderr
	jg	prtfilex	; ntntnt  no
	mov	eax, 1		; ntntnt  eax = stdout fileNumber
prtfilex:
	push	eax		; ntntnt  push fileNumber
	call	_XxxWriteFile@20	; ntntnt ;;;
;;;	add	esp,20		; ntntnt
	or	eax,eax		; was there an error?  (eax < 0 if error)
	jmp	short ptfn_good	; ntntnt  (add error checking)
;
	jns	short ptfn_good ;no: free the string and exit
;	cmp	[_errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	short ptfn_crash ;no: it was a real error
	cmp	[_##SOFTBREAK],0	;was it a soft break?
	jne	ptfn_again	;no: it was just some blowhard signal
	;tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	ptfn_again
ptfn_crash:
	mov	eax,[ebp-4]	;eax -> original string
	mov	ebx,[eax-8]	;ebx = length of string
	mov	byte ptr [eax+ebx],0 ;restore null terminator
	mov	esi,[ebp-4]	;esi -> string to free
	call	%____free	;free printed string
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
ptfn_good:
	mov	esi,[ebp-4]	;esi -> string to free
	call	%____free	;free printed string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *******************************
; *****  %_PrintFirstComma  *****  creates string with spaces for first tab stop
; *******************************
;
; in:	nothing
; out:	eax -> string with [_##TABSAT] spaces in it
;
; destroys: ebx, ecx, edx, esi, edi
;
%_PrintFirstComma:
	mov	esi,[_##TABSAT]	;esi = # of spaces to create
	cld
	add	esi,64		;get more than necessary (caller will almost
				; certainly append to this string)
	call	%_____calloc	;esi -> header of new string
	add	esi,16		;esi -> new string

	mov	edi,esi		;edi -> new string
	mov	ecx,[_##TABSAT]	;ecx = # of spaces to create
	jecxz	short pfc.no.stosb ;no tab stops?
	mov	al,' '		;ready to write some spaces
	rep
	stosb			;write them spaces!
;;
pfc.no.stosb:
	mov	byte ptr [edi],0 ;write terminating null
	sub	edi,esi		;edi = length of string
	mov	[esi-8],edi	;store length of new string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = new info word: allocated ubyte.string
	mov	[esi-4],eax	;store new info word

	mov	eax,esi		;eax = return value = addr of new string
	ret
;
;
; ********************************
; *****  %_PrintAppendComma  *****  appends enough spaces to reach next tab stop
; ********************************
;
; in:	eax -> string to append to
; out:	eax -> string with spaces appended to it
;
; destroys: ebx, ecx, edx, esi, edi
;
%_PrintAppendComma:
	or	eax,eax		;appending to null string?
	jz	%_PrintFirstComma ;yes: use simpler subroutine

	mov	esi,eax		;esi -> original string (safe from upcoming DIV)
	mov	eax,[eax-8]	;eax = size of current string
	mov	ecx,[_##TABSAT]	;there's a tab stop every ecx columns
	cld
	xor	edx,edx		;clear high-order bits of dividend
	div	cx		;edx = LEN(string) MOD [##TABSAT]
	sub	ecx,edx		;ecx = # of spaces to add to get to next tab

	mov	eax,[esi-8]	;eax = length of original string
	lea	edi,[eax+ecx]	;edi = length needed
	inc	edi		;one more for terminating null
	mov	edx,[esi-16]	;edx = length of string's chunk including header
	sub	edx,16		;edx = length of string's chunk excluding header
	cmp	edx,edi		;chunk big enough to hold expanded string?
	jae	short pac.big.enough ;yes: skip realloc

	push	eax
	push	ecx
	push	edx
	call	%____realloc	;esi -> string with enough space to hold new
	pop	edx		; spaces; all other registers destroyed
	pop	ecx
	pop	eax
;;
;;	mov	[ebp-4],esi	;save new pointer to string
;;
pac.big.enough:
	lea	edi,[esi+eax]	;edi -> char after last char of original string
	mov	al,' '		;ready to write some spaces
	jecxz	short pac.skip.stosb ;ecx should be != 0, but just in case...
	rep
	stosb			;append them spaces!
;;
pac.skip.stosb:
	mov	byte ptr [edi],0 ;append null terminator
	sub	edi,esi		;edi = length of new string
	mov	[esi-8],edi	;store length of new string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = new info word: allocated ubyte.string
	mov	[esi-4],eax	;store new info word
	mov	eax,esi		;eax = return value = addr of new string
	ret
;
;
; *****************************************
; *****  %_print.tab.a0.eq.a0.tab.a1  *****  appends spaces to reach desired
; *****************************************  tab stop
;
; in:	eax -> string to append spaces to
;	ebx = one more than desired length of string
; out:	eax -> new string
;
; destroys: ebx, ecx, edx, esi, edi
;
; String pointed to by eax is assumed to be in dynamic memory; it may
; be realloc'ed.
;
%_print.tab.a0.eq.a0.tab.a1:
%_print.tab.a0.eq.a0.tab.a1.ss:
	cld
	lea	ecx,[ebx-1]	;ecx = desired length of string
	or	ecx,ecx		;desired length <= 0?
	jbe	short pt_abort	;yes: do nothing
	or	eax,eax		;null string?
	jnz	short pt001	;no: it's our job
	mov	eax,ebx		;yes: pass it off on specialized routine
	jmp	%_print.tab.first.a0
;
pt001:
	mov	edi,[eax-8]	;edi = length of existing string
	cmp	edi,ecx		;string is too long or already right length?
	jae	short pt_abort	;yes: nothing to do
;;
	mov	edx,[eax-16]	;edx = length of string's chunk including header
	sub	edx,16		;edx = length of string's chunk excluding header
	cmp	edx,ebx		;is chunk already big enough to hold new string?
	jae	short pt_append	;yes: no reallocation necessary
;;
	mov	esi,eax		;esi -> existing string
	lea	edi,[ebx+64]	;edi = new length plus 64, since string will
	push	ebx		; probably be appended to
	call	%____realloc	;make room for spaces we're about to append
	pop	ebx		;esi -> new string
	mov	eax,esi		;eax -> new string
	mov	edi,[eax-8]	;edi = length of existing string
	lea	ecx,[ebx-1]	;ecx = desired length of string
;;
pt_append:
	mov	[eax-8],ecx	;store new length of string
	sub	ecx,edi		;ecx = number of spaces to append
	lea	edi,[eax+edi]	;edi -> char after last char of existing string
	jecxz	pt_no_stosb	;just in case...
	mov	esi,eax		;save pointer to result string
	mov	al,' '		;ready to write some spaces
	rep
	stosb			;append spaces!
	mov	eax,esi		;eax -> result string
pt_no_stosb:
	mov	byte ptr [edi],0 ;append null terminator
;;
pt_abort:
	ret
;
;
; *****************************************
; *****  %_print.tab.a0.eq.a1.tab.a0  *****  appends spaces to reach desired
; *****************************************  tab stop
;
; in:	eax = one more than desired length of string
; 	ebx -> string to append spaces to
; out:	eax -> new string
;
; destroys: ebx, ecx, edx, esi, edi
;
; String pointed to by ebx is assumed to be in dynamic memory; it may
; be realloc'ed.
;
%_print.tab.a0.eq.a1.tab.a0:
%_print.tab.a0.eq.a1.tab.a0.ss:
	xchg	eax,ebx
	jmp	%_print.tab.a0.eq.a0.tab.a1
;
;
; **********************************
; *****  %_print.tab.first.a0  *****  creates a string containing a given number
; **********************************  of spaces
;
; in:	eax = one more than number of spaces to create
; out:	eax -> created string
;
; destroys: edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.  Returns null pointer if caller asks for zero or
; fewer spaces.
;
%_print.tab.first.a0:
	lea	esi,[eax-1]	;esi = # of spaces to create
	or	esi,esi		;zero or less?
	jbe	short ptf_null	;yes: return null string

	push	ebx		;must not destroy a1
	push	ecx

	push	eax
	add	esi,64		;get 64 bytes more than required, since string
				; will probably be appended to
	call	%____calloc	;esi -> new string
	pop	ebx		;ebx = requested tab stop

	mov	eax,[_##WHOMASK]	;ebx = system/user bit
	or	eax,0x80130001	;indicate: allocated string
	mov	[esi-4],eax	;store new string's info word

	mov	edi,esi		;edi -> new string
	lea	ecx,[ebx-1]	;ecx = # of spaces to create
	mov	[esi-8],ecx	;store length of new string
	cld
	mov	al,' '		;ready to write spaces
	rep
	stosb			;write them spaces!
	mov	byte ptr [edi],0 ;null terminator at end of string
	mov	eax,esi		;eax -> new string
	pop	ecx		;restore a1
	pop	ebx
	ret
;
ptf_null:
	xor	eax,eax		;return null pointer
	ret
;
;
; **********************************
; *****  %_print.tab.first.a1  *****  creates a string containing a given number
; **********************************  of spaces
;
; in:	ebx = one more than number of spaces to create
; out:	ebx -> created string
;
; destroys: ecx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.  Returns null pointer if caller asks for zero or
; fewer spaces.
;
%_print.tab.first.a1:
	xchg	eax,ebx
	xchg	edx,ecx
	call	%_print.tab.first.a0
	xchg	eax,ebx
	xchg	edx,ecx
	ret
;
;
; *************************************
; *****  %_print.first.spaces.a0  *****  creates a string containing a given
; *************************************  number of spaces
;
; in:	eax = desired number of spaces
; out:	eax -> string containing spaces
;
; destroys: edx, esi, esi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.  Returns null pointer if caller asks for zero or
; fewer spaces.
;
%_print.first.spaces.a0:
	inc	eax		;eax = tab stop after making spaces
	jmp	%_print.tab.first.a0
;
;
; **************************************
; *****  %_print.append.spaces.a0  *****  appends a given number of spaces
; **************************************  to a string
;
; in:	eax -> string to append spaces to
;	ebx = # of spaces to append
; out:	eax -> new string
;
; destroys: ebx, ecx, edx, esi, edi
;
; String pointed to by eax is assumed to be in dynamic memory; it may
; be realloc'ed.
;
%_print.append.spaces.a0:
%_PrintAppendSpaces:
	or	eax,eax		;null pointer?
	jz	short print_append_null ;yes: create new string

	mov	ecx,[eax-8]	;ecx = current length of string
	lea	ebx,[ebx+ecx+1]	;ebx = position after last char after
				; appending spaces
	jmp	%_print.tab.a0.eq.a0.tab.a1

print_append_null:
	lea	eax,[ebx+1]	;eax = one more than desired number of spaces
	jmp	%_print.tab.first.a0
;
;
; ********************
; *****  %_Read  *****  READ #n, v
; ********************
;
; in:	arg2 = number of bytes to read
;	arg1 -> where to put them
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
%_Read:
	push	ebp
	mov	ebp,esp
;;
read_again:
;	push	[ebp+16]		; old UNIX
;	push	[ebp+12]		; old UNIX
;	push	[ebp+8]			; old UNIX
	sub	esp, 20			; ntntnt ;;;
	mov	eax, [ebp+ 8]		; ntntnt
	mov	[esp+ 0], eax		; ntntnt  fileNumber
	mov	eax, [ebp+12]		; ntntnt
	mov	[esp+ 4], eax		; ntntnt  bufferAddr
	mov	eax, [ebp+16]		; ntntnt
	mov	[esp+ 8], eax		; ntntnt  bufferSize
	lea	eax, [esp+12]		; ntntnt
	mov	[esp+12], eax		; ntntnt  bytesRead
	xor	eax, eax		; ntntnt
	mov	[esp+16], eax		; ntntnt  0
	call	_XxxReadFile@20		; ntntnt ;;;
;;;	add	esp,64			; ntntnt
;;
	or	eax,eax		;was there an error?  (eax < 0 if error)
	jmp	short read_good	; ntntnt  (add error checking)
;
	jns	short read_good ;no: done
;	cmp	[_errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	short read_crash ;no: it was a real error
	cmp	[_##SOFTBREAK],0	;was it a soft break?
	jne	read_again	;no: it was just some blowhard signal
	;tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	read_again
read_crash:
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
read_good:
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_ReadArray  *****  READ #n, v[]   and   READ #n, v$
; *************************
;
; in:	arg1 -> array or string to read
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = number of bytes to read
;
%_ReadArray:
%_ReadString:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	eax,[ebp+12]	;ebx -> array or string to read
	mov	ebx,eax		;
	or	eax,eax		; empty string ?
	jz	readarray_good	; yes
;
	mov	eax, [ebx-4]
	test	eax, 0x20000000		;is array nodal?
	jnz	readarray_nodal
	and	eax, 0x40FF0000 
	xor	eax, 0x40130000		;is it a string array?
	jnz	readarray_not_string	;handle string array same as a node
readarray_nodal:
	mov	ecx, [ebx-8]		;number of elements
	sub	esp, 16
readarray_loop:
	mov	[esp+8], ecx		;save element counter
	mov	[esp+12], ebx		;save array node
	mov	ebx, [ebx]		;address of subarray or string
	mov	[esp+4], ebx
	mov	eax, [ebp+8]
	mov	[esp], eax		;file number
	call	%_ReadArray
	mov	ebx, [esp+12]
	mov	ecx, [esp+8]
	add	ebx,4			;increment node
	loop	readarray_loop
	jmp	readarray_good
readarray_not_string:
;
	movzx	eax,word ptr [ebx-4] ;eax = # of bytes per element
	mov	ecx,[ebx-8]	;ecx = # of elements
	mul	ecx		;eax = # of bytes to read
	mov	[ebp-4],eax	;save it where "read" syscall can't get to it
;;
readarray_again:
	sub	esp, 20			; ntntnt ;;;
	mov	eax, [ebp+ 8]		; ntntnt
	mov	[esp+ 0], eax		; ntntnt  fileNumber
	mov	eax, [ebp+12]		; ntntnt
	mov	[esp+ 4], eax		; ntntnt  bufferAddr
	mov	eax, [ebp-4]		; ntntnt
	mov	[esp+ 8], eax		; ntntnt  bufferSize
	lea	eax, [esp+12]		; ntntnt
	mov	[esp+12], eax		; ntntnt  bytesRead
	xor	eax, eax		; ntntnt
	mov	[esp+16], eax		; ntntnt  0
	call	_XxxReadFile@20		; ntntnt ;;;
;;;	add	esp,64			; ntntnt
;
;
	or	eax,eax		;was there an error?  (eax < 0 if error)
	jmp	short readarray_good	; ntntnt  (add error checking)

	jns	short readarray_good ;no: done
;	cmp	[_errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	short readarray_crash ;no: it was a real error
	cmp	[_##SOFTBREAK],0	;was it a soft break?
	jne	readarray_again	;no: it was just some blowhard signal
	;tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	readarray_again
;
readarray_crash:
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
readarray_good:
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *********************
; *****  %_Write  *****  WRITE #n, v
; *********************
;
; in:	arg2 = number of bytes to write
;	arg1 -> bytes to write
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
%_Write:
	push	ebp
	mov	ebp,esp
;;
write_again:
;	push	[ebp+16]		; old UNIX
;	push	[ebp+12]		; old UNIX
;	push	[ebp+8]			; old UNIX
;	call	_write			; old UNIX
;	add	esp,12			; old UNIX
;
	sub	esp, 20			; ntntnt ;;;
	mov	eax, [ebp+ 8]		; ntntnt
	mov	[esp+ 0], eax		; ntntnt  fileNumber
	mov	eax, [ebp+12]		; ntntnt
	mov	[esp+ 4], eax		; ntntnt  bufferAddr
	mov	eax, [ebp+16]		; ntntnt
	mov	[esp+ 8], eax		; ntntnt  bufferSize
	lea	eax, [esp+12]		; ntntnt
	mov	[esp+12], eax		; ntntnt  bytesRead
	xor	eax, eax		; ntntnt
	mov	[esp+16], eax		; ntntnt  0
	call	_XxxWriteFile@20	; ntntnt ;;;
;;;	add	esp,64			; ntntnt
;
;
	or	eax,eax		;was there an error?  (eax < 0 if error)
	jmp	short write_good	; ntntnt  (add error checking)

	jns	short write_good ;no: done
;	cmp	[_errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	short write_crash ;no: it was a real error
	cmp	[_##SOFTBREAK],0	;was it a soft break?
	jne	write_again	;no: it was just some blowhard signal
	;tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	write_again
write_crash:
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
write_good:
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***************************
; *****  %_WriteArray   *****  WRITE #n, v[]
; *****  %_WriteString  *****  WRITE #n, v$
; ***************************
;
; in:	arg1 -> array or string to write
;	arg0 = file number
; out:	nothing
;
; destroys: eax, ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = number of bytes to write
;
%_WriteArray:
%_WriteString:
	push	ebp
	mov	ebp,esp
	sub	esp,4
;
	mov	ebx,[ebp+12]		;ebx -> array or string to write
	or	ebx,ebx			;empty array?
	jz	writearray_good	;yes, ignore
;
	mov	eax, [ebx-4]
	test	eax, 0x20000000		;is array nodal?
	jnz	writearray_nodal
	and	eax, 0x40FF0000
	xor	eax, 0x40130000		;is it a string array?
	jnz	writearray_not_string	;handle string array same as node
writearray_nodal:
	mov	ecx, [ebx-8]		;number of elements
	sub	esp, 16
writearray_loop:
	mov	[esp+8], ecx		;save element counter
	mov	[esp+12], ebx		;save array node
	mov	ebx, [ebx]		;address of subarray or string
	mov	[esp+4], ebx
	mov	eax, [ebp+8]
	mov	[esp], eax		;file number
	call	%_WriteArray
	mov	ebx, [esp+12]
	mov	ecx, [esp+8]
	add	ebx,4			;increment node
	loop	writearray_loop
	jmp	writearray_good
writearray_not_string:
;
	movzx	eax,word ptr [ebx-4]	;eax = # of bytes per element
	mov	ecx,[ebx-8]		;ecx = # of elements
	mul	ecx			;eax = # of bytes to write
	mov	[ebp-4],eax		;save it where "write" syscall can't get to it
;;
writearray_again:
;	push	[ebp-4]			; old UNIX
;	push	[ebp+12]		; old UNIX
;	push	[ebp+8]			; old UNIX
;	call	_write			; old UNIX
;	add	esp,12			; old UNIX
;
	sub	esp, 20			; ntntnt ;;;
	mov	eax, [ebp+ 8]		; ntntnt
	mov	[esp+ 0], eax		; ntntnt  fileNumber
	mov	eax, [ebp+12]		; ntntnt
	mov	[esp+ 4], eax		; ntntnt  bufferAddr
;	mov	eax, [ebp+16]		; ntntnt  WRONG!!!
	mov	eax, [ebp-4]		; ntntnt
	mov	[esp+ 8], eax		; ntntnt  bufferSize
	lea	eax, [esp+12]		; ntntnt
	mov	[esp+12], eax		; ntntnt  bytesRead
	xor	eax, eax		; ntntnt
	mov	[esp+16], eax		; ntntnt  0
	call	_XxxWriteFile@20		; ntntnt ;;;
;;;	add	esp,64			; ntntnt
;;
	or	eax,eax		;was there an error?  (eax < 0 if error)
	jmp	short writearray_good	; ntntnt  (add error checking)
;
	jns	short writearray_good ;no: done
;	cmp	[_errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	short writearray_crash ;no: it was a real error
	cmp	[_##SOFTBREAK],0	;was it a soft break?
	jne	writearray_again ;no: it was just some blowhard signal
	;tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	writearray_again
writearray_crash:
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
writearray_good:
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *********************************
; *****  %_string.compare.vv  *****  string comparisons
; *****  %_string.compare.vs  *****
; *****  %_string.compare.sv  *****
; *****  %_string.compare.ss  *****
; *********************************
;
; in:	eax -> string1
;	ebx -> string2
; out:	flags set as if a "cmp *eax,*ebx" instruction had been executed,
;	so that the unsigned conditional jump instructions will make
;       sense if executed immediately upon return from the string
;	comparison routine
;
; destroys: ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string1, if it needs to be freed on exit
;	[ebp-8] -> string2, if it needs to be freed on exit
;	[ebp-12] holds the flags to be returned
;
%_string.compare.vv:
	xor	esi,esi		;don't free string1 on exit
	xor	edi,edi		;don't free string2 on exit
	jmp	short string.compare.x
;
;
%_string.compare.vs:
	xor	esi,esi		;don't free string1 on exit
	mov	edi,ebx		;must free string2 on exit
	jmp	short string.compare.x
;
;
%_string.compare.sv:
	mov	esi,eax		;must free string1 on exit
	xor	edi,edi		;don't free string2 on exit
	jmp	short string.compare.x
;
;
%_string.compare.ss:
	mov	esi,eax		;must free string1 on exit
	mov	edi,ebx		;must free string2 on exit
;;
;; fall through
;;
string.compare.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12
	mov	[ebp-4],esi	;save ptr to first string to free on exit
	mov	[ebp-8],edi	;save ptr to second string to free on exit
	or	eax,eax		;string1 is a null pointer?
	jz	short string1_null ;yes: special processing
	or	ebx,ebx		;string2 is a null pointer?
	jz	short string2_null ;yes: special processing
;;
	mov	ecx,[eax-8]	;ecx = LEN(string1)
	cmp	ecx,[ebx-8]	;LEN(string1) > LEN(string2)?
	jb	short sc_compare ;no: ecx = LEN(shortest string)
	mov	ecx,[ebx-8]	;ecx = LEN(string2) = LEN(shortest string)
;;
sc_compare:
	mov	esi,eax		;esi -> string1
	mov	edi,ebx		;edi -> string2
	rep
	cmpsb			;compare them strings!
	je	short sc_compare_lengths ;if equal, longer string is "greater"
				;otherwise, flags after rep cmpsb are
				; the result flags
;;
sc_done:
	lahf			;result flags to AH
	mov	[ebp-12],eax	;save result flags
	mov	esi,[ebp-4]	;esi -> first string to free on exit
	call	%____free
	mov	esi,[ebp-8]	;esi -> second string to free on exit
	call	%____free
;;
	mov	eax,[ebp-12]	;AH = result flags
	sahf			;put result flags back into flag register
	mov	esp,ebp
	pop	ebp
	ret
;
string1_null:			; string1 is a null pointer
	cmp	eax,ebx		; string2 a null pointer too?
	je	sc_done		; yes
	mov	ebx,[ebx-8]	; ebx = length of string2
	cmp	eax,ebx		; both empty?
	jmp	sc_done		; comparison tells all
;
string2_null:
	cmp	ebx,eax		; string2 is a null pointer
	je	sc_done		; string1 a null pointer too?
	mov	eax,[eax-8]	; eax = length of string1
	cmp	ebx,eax		; both empty?
	jmp	sc_done		; comparison tells all
;
sc_compare_lengths:
	mov	ecx,[eax-8]	;ecx = LEN (string1)
	cmp	ecx,[ebx-8]	;compare with LEN (string2),
	jmp	sc_done		; yielding result flags
;
;
;
; XstFindMemoryMatch (addrBufferStart, addrBufferPast, addrString, minMatch)
;
; input
; arg1   = addr of buffer to search - first byte
; arg2   = addr of buffer to search - byte past end
; arg3   = addr of string to search for - first byte
; arg4   = minimum number of bytes that must match
; arg5   = maximum number of bytes that may match (length of match string)
;
; output
; arg1   = addr of buffer to search - first byte that matched
; arg2   = unchanged
; arg3   = unchanged
; arg4   = # of characters that matched
; arg5   = unchanged
; return = addr of buffer to search - first byte that matched
;
; arg1   = ebp +  8
; arg2   = ebp + 12
; arg3   = ebp + 16
; arg4   = ebp + 20
; arg5   = ebp + 24
;
_XstFindMemoryMatch@20:
push	ebp		; standard function entry
mov	ebp,esp		; ditto
sub	esp,16		; 16 byte frame - local variables
;;
push	esi		; save esi
push	edi		; save edi
push	ebx		; save ebx
push	ecx		; save ecx
;;
mov	edi,[ebp+8]	; edi = addr of first byte of search buffer
mov	edx,[ebp+12]	; edx = addr of byte past end of search buffer
mov	esi,[ebp+16]	; ebx = addr of 1st byte of match buffer
mov	ebx,[ebp+20]	; esi = minimum # of bytes that must match
mov	eax,[ebp+24]	; eax = maximum # of bytes that may match
;;
or	edi,edi		; buffer address = 0 ???
jz	short fsnomatch	; start address = 0 is error or empty string
;;
or	edx,edx		; past address = 0 ???
jz	short fsnomatch	; past address = 0 is an error
;;
or	esi,esi		; match buffer address = 0 ???
jz	short fsnomatch	; match buffer address = 0 is error or empty
;;
or	ebx,ebx		; min # of bytes that must match = 0 ???
jz	short fsnomatch	; min # of bytes = 0 is error
;;
or	eax,eax		; max # of bytes that can match
jle	short fsnomatch	; max # of bytes <= 0 is error
;;
mov	ecx,edx		; ecx = addr past last byte of buffer to search
sub	ecx,edi		; ecx = overall size of buffer to search
jbe	short fsnomatch	; search zero or negative number of bytes ???
;;
sub	ecx,ebx		; ecx = maximum number of bytes to search
jb	short fsnomatch	; search through a negative number of bytes ???
inc	ecx		; ecx = number of bytes to search
;; mov	[ebp-4],ecx	; [ebp-4] = save number of bytes to search
;;
movzx	eax, byte ptr [esi]	; 1st byte of string to match
;;
;; eax = byte to match
;; edi = addr of buffer to search
;; ecx = how many bytes to search through
;; edx = addr of byte past end of buffer to search through
;;
xfsloop:		;
cld			; search forward through memory
repne			; repeat until byte in buffer = byte in eax
scasb			; search for match with byte in eax
;;
jne	short fsnomatch	; no match to byte in eax
;;
push	eax		; save 1st search byte
push	ecx		; save number of bytes left to search through
push	esi		; save addr of 1st byte of match string
push	edi		; save addr of byte after match
;;
;; found 1st byte of match, now see how many subsequent bytes match
;;
dec	edi		; edi = addr of 1st byte in buffer of match
mov	ecx,edx		; ecx = addr of byte past end of search buffer
sub	ecx,edi		; ecx = # of bytes in buffer after match byte
;;
mov	eax,[ebp+24]	; eax = max # of bytes to match
cmp	eax,ecx		; eax < ecx ???
jae	xfscmp		; no, ecx is okay
mov	ecx,eax		; ecx is now okay = max # of bytes to match
;;
xfscmp:
xor	eax,eax		; z flag = true = 1
repe			; repeat until bytes don't match
cmpsb			; see how many bytes match (at least 1)
;;
jnz	short xfsmm	; found mismatch
inc	esi		; make compatible with mismatch case
inc	edi		; make compatible with mismatch case
;;
xfsmm:
mov	eax,edi		; eax = addr of byte past match
sub	eax,[esp]	; eax = # of bytes that match - 1
;; inc	eax		; eax = # of bytes that match
cmp	eax,ebx		; was # of bytes that matched >= required ???
jae	short xfsm	; yes, so we have a match
;;
;; match was too short - continue search where it left off
;;
pop	edi		; edi = addr of byte after match
pop	esi		; esi = addr of 1st byte of match string
pop	ecx		; ecx = # of bytes left to search through
pop	eax		; eax = byte to search for - 1st byte in match string
jmp	short xfsloop	; continue search for long enough match
;
; found a sufficiently long match - eax = match length = return value
;
xfsm:
pop	edi		; edi = addr of 1st byte of match + 1
dec	edi		; edi = addr of 1st byte of match
add	esp,12		; remove pushed values esi,ecx,eax from stack
mov	[ebp+8],edi	; arg1 = addr of 1st byte of match in buffer
mov	[ebp+20],eax	; arg4 = match length
;;
;; restore registers
;;
xfs_done:
pop	ecx		; restore ecx
pop	ebx		; restore ebx
pop	edi		; restore edi
pop	esi		; restore esi
;;
mov	esp,ebp		; restore stack pointer
pop	ebp		; restore frame pointer
ret	20		; remove 20 bytes of arguments - STDCALL
;
fsnomatch:
xor	eax,eax		; eax = 0 = no match
jmp	short xfs_done	;
;
;
;
; ***************************************
; *****  %_CompositeStringToString  *****
; ***************************************
;
; The result string is a conventional string.  The length
; of the result string is the length of the composite string
; up to the first 0x00 byte, or the whole composite string
; if it contains no 0x00 byte.
;
; edi = length in bytes
; esi = source address
;
%_CompositeStringToString:
push	eax
push	edx
push	ebx
push	ecx
push	edi		; save composite string length
push	esi		; save address of composite string
mov	edx,edi		; edx = length of composite string
mov	ecx,edi		; ecx = length of composite string
mov	edi,esi		; edi = addr of composite string
xor	eax,eax		; eax = 0 = byte to search for
;;
cld			; search forward
repne			; repeat while not equal
scasb			; find 0x00 byte in composite string
;;
mov	esi,edx		; esi = length of composite string
jnz	short nozmatch	; no 0x00 byte in composite string
dec	edi		; edi = address of 0x00 byte
sub	edi,[esp]	; edi = addr of 0x00 - addr of composite string
mov	esi,edi		; esi = length of composite string before 0x00
jz	short ccsempty	; return empty string
;;
nozmatch:
push	esi		; save length of string
inc	esi		; make room for 0x00 terminator
call	%____calloc	; allocate space for result string
;;
mov	eax,0x80130001	; word3 of header for strings
mov	[esi-4],eax	; word3 of header = 1 byte string
;;
pop	ecx		; ecx = length of string
mov	[esi-8],ecx	; word2 of header = # of bytes in string
;;
mov	edi,esi		; edi = address of destination string
pop	esi		; esi = address of composite string
push	edi		; save address of destination string
;;
cld			; forward move
rep			; repeat/move ecx bytes
movsb			; move composite string to destination string
;;
ccsdone:
pop	esi		; esi = address of destination string
pop	edi		; edi = entry edi
pop	ecx		; ecx = entry ecx
pop	ebx		; ebx = entry ebx
pop	edx		; edx = entry edx
pop	eax		; eax = entry eax
ret			;
;
ccsempty:
pop	esi		; esi = address of composite string (useless)
pop	edi		; edi = entry edi
pop	ecx		; ecx = entry ecx
pop	ebx		; ebx = entry ebx
pop	edx		; edx = entry edx
pop	eax		; eax = entry eax
xor	esi,esi		; esi = result = 0x00000000 = empty string
ret			;
;
;
;
; edi = length in bytes
; esi = source address
;
%_ByteMakeCopy:
push	eax
push	edx
push	ebx
push	ecx
push	edi
push	esi
mov	esi,edi
inc	esi		; 951121
call	%____calloc
;;
mov	eax,[esi-8]	; 951121
dec	eax		; 951121
mov	[esi-8],eax	; 951121
;;
mov	edi,esi
pop	esi
pop	ecx
push	edi
cld
rep
movsb
pop	esi
pop	ecx
pop	ebx
pop	edx
pop	eax
ret
;
;
; *****************************************
; *****  Miscellaneous I/O Functions  *****
; *****************************************
;
; in:	arguments are on the stack
; out:	result is in eax
;
; destroys: ebx, ecx, edx, esi, edi
;
; Each I/O function calls an XBASIC function in xst.x to do the
; real work.  Some functions have two entry points, one for a
; string parameter on the stack and one for a string parameter
; in a variable.
;
; NOTE:  Wierd stack business necessary because the intrinsic
;        code makes a CDECL call, while the XBasic functions in
;        xst.x are STDCALL functions.
;
;
%_close:
	mov	eax, [esp+4]	; ;;;
	push	eax		; ;;;
	call	_XxxClose@4	; ;;;
	ret			; ;;;
;
;
%_eof:
	mov	eax, [esp+4]	; ;;;
	push	eax		; ;;;
	call	_XxxEof@4	; ;;;
	ret			; ;;;
;
;
%_lof:
	mov	eax, [esp+4]	; ;;;
	push	eax		; ;;;
	call	_XxxLof@4	; ;;;
	ret			; ;;;
;
;
%_pof:
	mov	eax, [esp+4]	; ;;;
	push	eax		; ;;;
	call	_XxxPof@4	; ;;;
	ret			; ;;;
;
;
%_quit:
	mov	eax, [esp+4]	; ;;;
	push	eax		; ;;;
	call	_XxxQuit@4	; ;;;
	ret			; ;;;
;
;
%_infile_d:
	mov	eax, [esp+4]	; ;;;
	push	eax		; ;;;
	call	_XxxInfile$@4	; ;;;
	ret			; ;;;
;
;
%_inline_d.s:
	mov	eax, [esp+4]	; ;;; eax -> prompt$
	push	eax		; ;;;
	call	_XxxInline$@4	; ;;;
	mov	esi, [esp+4]	; ;;;
	jmp	%____free	; ;;;
				; ;;;
;
;
%_inline_d.v:
	mov	eax, [esp+4]	; ;;; eax -> prompt$
	push	eax		; ;;;
	call	_XxxInline$@4	; ;;;
	ret			; ;;;
;
;
%_open.s:
	mov	eax, [esp+4]	; ;;; eax -> filename$
	mov	ebx, [esp+8]	; ;;; ebx == open mode
	push	ebx		; ;;;
	push	eax		; ;;;
	call	_XxxOpen@8	; ;;;
	mov	esi, [esp+4]	; ;;;
	jmp	%____free	; ;;;
;
;
%_open.v:
	mov	eax, [esp+4]	; ;;; eax -> filename$
	mov	ebx, [esp+8]	; ;;; ebx == open mode
	push	ebx		; ;;;
	push	eax		; ;;;
	call	_XxxOpen@8	; ;;;
	ret			; ;;;
;
;
%_seek:
	mov	eax, [esp+4]	; ;;; eax == file number
	mov	ebx, [esp+8]	; ;;; ebx == file position
	push	ebx		; ;;;
	push	eax		; ;;;
	call	_XxxSeek@8	; ;;;
	ret			; ;;;
;
;
%_shell.s:
	mov	eax, [esp+4]	; ;;; eax -> shell command string
	push	eax		; ;;;
	call	_XxxShell@4	; ;;;
	mov	esi, [esp+4]	; ;;;
	push	eax		; ;;;
	call	%____free	; ;;;
	pop	eax		; ;;;
	ret
;
;
%_shell.v:
	mov	eax, [esp+4]	; ;;; eax -> shell command string
	push	eax		; ;;;
	call	_XxxShell@4	; ;;;
	ret			; ;;;
;
;
; ##################
; #####  DATA  #####  xlibs.s
; ##################
;
;
;
.align	8
.dword	0x20,	0x0,	0x1,	0x80130001
%_space.string:
.byte	' '
.zero	15

.align	8
.dword	0x20,	0x0,	0x1,	0x80130001
%_newline.string:
.byte	'\n'
.zero	15
;
;
.text
;
; ######################
; #####  xlibnn.s  #####  numeric-to-numeric conversions and intrinsics
; ######################
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
%_cv.slong.to.sbyte:
%_cv.ulong.to.sbyte:
%_cv.xlong.to.sbyte:
	movsx	eax,byte ptr [esp+4] ;eax = converted sbyte
	cmp	eax,[esp+4]	;any of those high-order bits changed?
	je	short ret1	;no: sign-extension occurred w/o change of data
	jmp	%_eeeOverflow	; Return from there
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
%_cv.slong.to.ubyte:
%_cv.ulong.to.ubyte:
%_cv.xlong.to.ubyte:
	movzx	eax,byte ptr [esp+4] ;eax = converted ubyte
	cmp	eax,[esp+4]	;any high-order bits changed?
	je	short ret2	;no: conversion occurred w/o loss of data
	jmp	%_eeeOverflow	; Return from there
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
%_cv.slong.to.sshort:
%_cv.ulong.to.sshort:
%_cv.xlong.to.sshort:
	movsx	eax,word ptr [esp+4] ;eax = converted sshort
	cmp	eax,[esp+4]	;any high-order bits changed?
	je	short ret3	;no: conversion occurred w/o loss of data
	jmp	%_eeeOverflow	; Return from there
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
%_cv.slong.to.ushort:
%_cv.ulong.to.ushort:
%_cv.xlong.to.ushort:
	movzx	eax,word ptr [esp+4] ;eax = converted ushort
	cmp	eax,[esp+4]	;any high-order bits changed?
	je	short ret4	;no: conversion occurred w/o loss of data
	jmp	%_eeeOverflow	; Return from there
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
%_cv.slong.to.slong:
%_cv.slong.to.ulong:
%_cv.slong.to.xlong:
%_cv.slong.to.subaddr:
%_cv.slong.to.goaddr:
%_cv.slong.to.funcaddr:
%_cv.ulong.to.slong:
%_cv.ulong.to.ulong:
%_cv.ulong.to.xlong:
%_cv.ulong.to.subaddr:
%_cv.ulong.to.goaddr:
%_cv.ulong.to.funcaddr:
%_cv.xlong.to.slong:
%_cv.xlong.to.ulong:
%_cv.xlong.to.xlong:
%_cv.xlong.to.subaddr:
%_cv.xlong.to.goaddr:
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
%_cv.slong.to.giant:
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
%_cv.ulong.to.giant:
	mov	eax,[esp+4]
	xor	edx,edx
	ret
;
; **********************************
; *****  %_cv.slong.to.single  *****
; *****  %_cv.slong.to.double  *****
; *****  %_cv.xlong.to.single  *****
; *****  %_cv.xlong.to.double  *****
; **********************************
;
; in:	arg0 = xlong
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
%_cv.slong.to.single:
%_cv.slong.to.double:
%_cv.xlong.to.single:
%_cv.xlong.to.double:
	fild	[esp+4]
	ret
;
; **********************************
; *****  %_cv.ulong.to.single  *****  xxxxxxxxxx
; *****  %_cv.ulong.to.double  *****
; **********************************
;
; in:	arg0 = ulong
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
%_cv.ulong.to.single:
%_cv.ulong.to.double:
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
%_cv.giant.to.sbyte:
	movsx	eax,byte ptr [esp+4] ;eax = converted lower eight bits
	cmp	eax,[esp+4]	;no change in remaining bits of lsdword?
	jne	short bad1	;there was a change: blow up
	cdq			;sign-extend result into edx
	cmp	edx,[esp+8]	;no change in bits of msdword
	jne	short bad1	;there was a change: blow up
	ret
;
bad1:
;	xor	eax,eax		;return a zero (is this a good idea?)
	jmp	%_eeeOverflow	; Return from there
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
%_cv.giant.to.slong:
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
%_cv.giant.to.giant:
	mov	eax,[esp+4]	;eax = low 32 bits of giant
	mov	edx,[esp+8]	;edx = high 32 bits of giant
	ret
;
;
; **********************************
; *****  %_cv.giant.to.single  *****
; *****  %_cv.giant.to.double  *****
; **********************************
;
; in:	arg1 = high 32 bits of giant
;	arg0 = low 32 bits of giant
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
%_cv.giant.to.single:
%_cv.giant.to.double:
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
	jmp	%_eeeOverflow	; Return from there
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
%_cv.single.to.slong:
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
%_cv.single.to.giant:
	fld	[esp+4]		;st(0) = input single
	fistp	qword ptr [workqword] ;convert it to integer
	fwait
	mov	eax,[workqword]	;eax = low 32 bits of result
	mov	edx,[workqword+4] ;edx = high 32 bits of result
	ret
;
; ***********************************
; *****  %_cv.single.to.single  *****
; *****  %_cv.single.to.double  *****
; ***********************************
;
; in:	arg0 = single
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
%_cv.single.to.single:
%_cv.single.to.double:
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
%_cv.double.to.sbyte:
	fld	qword ptr [esp+4] ;st(0) = input double
	mov	esi,workdword	;shorten next three instructions
	fistp	[esi]		;convert input double to an integer
	fwait
	movsx	eax,byte ptr [esi] ;sign-extend low eight bits
	cmp	eax,[esi]	;any of the other bits changed?
	jne	short bad3	;yes: data was lost in conversion
	ret
bad3:
;	xor	eax,eax		;return zero (is this a good idea?)
	jmp	%_eeeOverflow	; Return from there
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
%_cv.double.to.ubyte:
	fld	qword ptr [esp+4] ;st(0) = input double
	mov	esi,workdword
	fistp	[esi]		;convert input double to integer
	fwait
	movzx	eax,byte ptr [esi] ;extract lowest 8 bits
	cmp	eax,[esi]	;no change in other bits?
	jne	bad3		;other bits changed: error
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
%_cv.double.to.sshort:
	fld	qword ptr [esp+4] ;st(0) = input double
	mov	esi,workdword	;shorten next three instructions
	fistp	[esi]		;convert input double to an integer
	fwait
	movsx	eax,word ptr [esi] ;sign-extend low 16 bits
	cmp	eax,[esi]	;any of the other bits changed?
	jne	short bad3	;yes: data was lost in conversion
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
%_cv.double.to.ushort:
	fld	qword ptr [esp+4] ;st(0) = input double
	mov	esi,workdword
	fistp	[esi]		;convert input double to integer
	fwait
	movzx	eax,word ptr [esi] ;extract lowest 16 bits
	cmp	eax,[esi]	;no change in other bits?
	jne	bad3		;other bits changed: error
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
%_cv.double.to.slong:
%_cv.double.to.xlong:
	fld	qword ptr [esp+4] ;st(0) = input double
	fistp	[workdword]	;convert it to integer
	fwait
	mov	eax,[workdword]
	ret			;no overflow possible (?)
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
%_cv.double.to.ulong:
	fld	qword ptr [esp+4] ;st(0) = input double
	mov	esi,workdword
	fistp	[esi]		;convert it to integer
	fwait
	mov	eax,[esi]
	or	eax,eax		;it's not negative, is it?
	js	bad3		;'fraid so
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
%_cv.double.to.giant:
	fld	qword ptr [esp+4] ;st(0) = input double
	fistp	qword ptr [workqword] ;convert it to integer
	fwait
	mov	eax,[workqword]	;eax = low 32 bits of result
	mov	edx,[workqword+4] ;edx = high 32 bits of result
	ret
;
;
; ***********************************
; *****  %_cv.double.to.single  *****
; *****  %_cv.double.to.double  *****
; ***********************************
;
; in:	arg1:arg0 = double
; out:	st(0) = equivalent floating-point number
;
; destroys: nothing
;
%_cv.double.to.single:
%_cv.double.to.double:
	fld	qword ptr [esp+4] ;st(0) = input double
	ret
;
;
;
; *************************
; *****  %_add.GIANT  *****
; *************************
;
; in:	arg3:arg2 = right operand
;	arg1:arg0 = left operand
; out:	edx:eax = result
;
; destroys: nothing
;
%_add.GIANT:
	mov	eax,[esp+4]
	mov	edx,[esp+8]
	add	eax,[esp+12]
	adc	edx,[esp+16]
	into
	ret
;
; *************************
; *****  %_sub.GIANT  *****
; *************************
;
; in:	arg3:arg2 = right operand
;	arg1:arg0 = left operand
; out:	edx:eax = result
;
; destroys: nothing
;
%_sub.GIANT:
	mov	eax,[esp+4]
	mov	edx,[esp+8]
	sub	eax,[esp+12]
	sbb	edx,[esp+16]
	into
	ret
;
;
; *************************
; *****  %_mul.GIANT  *****
; *************************
;
; in:	edx:eax = left operand
;	ecx:ebx = right operand
; out:	edx:eax = result
;
; destroys: nothing
;
; local variables:
;	[ebp-4]:[ebp-8] = left operand, result
;	[ebp-12]:[ebp-16] = right operand
;	[ebp-18] = saved FPU control word
;	[ebp-20] = new FPU control word
;
%_mul.GIANT:
	push	ebp
	mov	ebp,esp
	sub	esp,20

	mov	[ebp-8],eax	;put operands in memory so coprocessor
	mov	[ebp-4],edx	; can access them
	mov	[ebp-16],ebx
	mov	[ebp-12],ecx
	
	; Save FPU control word
	fstcw	word ptr [ebp-18]
	
	; Set FPU precision to 64 bits
	fstcw	word ptr [ebp-20]
	or	word ptr [ebp-20], 0x0300
	fldcw	word ptr [ebp-20]

	fild	qword ptr [ebp-8]
	fild	qword ptr [ebp-16]
	fmul
	fistp	qword ptr [ebp-8]

	; Restore FPU control word
	fldcw	word ptr [ebp-18]

	fwait

	mov	eax,[ebp-8]
	mov	edx,[ebp-4]

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_div.GIANT  *****
; *************************
;
; in:	edx:eax = left operand
;	ecx:ebx = right operand
; out:	edx:eax = result
;
; destroys: ebx
;
; local variables:
;	[ebp-4]:[ebp-8] = left operand, result
;	[ebp-12]:[ebp-16] = right operand
;	[ebp-20] = coprocessor control word set for truncation
;	[ebp-24] = on-entry control word
;
%_div.GIANT:
	push	ebp
	mov	ebp,esp
	sub	esp,24

	mov	[ebp-8],eax	;put operands in memory so coprocessor
	mov	[ebp-4],edx	; can access them
	mov	[ebp-16],ebx
	mov	[ebp-12],ecx

	; save FPU control word
	fstcw	word ptr [ebp-24]

	; Set FPU precision to 64 bits
	; Set FPU rounding to truncate
	fstcw	word ptr [ebp-20]
	or	word ptr [ebp-20], 0x0F00
	fldcw	word ptr [ebp-20]

	fild	qword ptr [ebp-8]
	fild	qword ptr [ebp-16]
	fwait
	fdiv

	fistp	qword ptr [ebp-8]
	fwait
	mov	eax,[ebp-8]
	mov	edx,[ebp-4]
	fldcw	word ptr [ebp-24] ;back to old rounding mode

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_mod.GIANT  *****
; *************************
;
; in:	edx:eax = left operand
;	ecx:ebx = right operand
; out:	edx:eax = result
;
; destroys: ebx
;
; local variables:
;	[ebp-4]:[ebp-8] = left operand, result
;	[ebp-12]:[ebp-16] = right operand
;	[ebp-20] = coprocessor control word set for truncation
;	[ebp-24] = on-entry control word
;
%_mod.GIANT:
	push	ebp
	mov	ebp,esp
	sub	esp,24

	mov	[ebp-8],eax	;put operands in memory so coprocessor
	mov	[ebp-4],edx	; can access them
	mov	[ebp-16],ebx
	mov	[ebp-12],ecx

	; save FPU control word
	fstcw	word ptr [ebp-24]

	; Set FPU precision to 64 bits
	; Set FPU rounding to truncate
	fstcw	word ptr [ebp-20]
	or	word ptr [ebp-20], 0x0F00
	fldcw	word ptr [ebp-20]

					;coprocessor stack:
					;st(0)        st(1)        st(2)
	fild	qword ptr [ebp-8]	;  l
	fabs
	fild	qword ptr [ebp-16]	;  r            l
	fabs
	fld	st(0)			;  r            r            l
	fwait
	fdivr	st,st(2)		;  l/r          r            l

	frndint				;int(l/r)       r            l
	fmul				;b*int(r/l)     l
	fsub				;l-(b*int(r/l))

	cmp	[ebp-4],0	;numerator less than zero?
	jnl	short mod_giant_skip ;no
	fchs			     ;yes: make remainder negative
mod_giant_skip:
	fistp	qword ptr [ebp-8]
	fwait
	mov	eax,[ebp-8]
	mov	edx,[ebp-4]
	fldcw	word ptr [ebp-24] ;back to old rounding mode

	mov	esp,ebp
	pop	ebp
	ret
;
;
; ****************************
; *****  %_lshift.giant  *****  logical left shift giant
; *****  %_ushift.giant  *****  arithmetic left shift giant
; ****************************
;
; in:	edx:eax = source operand
;	ecx = number of bits to shift
; out:	edx:eax = result
;
; destroys: nothing
;
%_lshift.giant:			;left logical and arithmetic shifts are the same
%_ushift.giant:
	cmp	ecx,0		;shifting zero or fewer bits?
	jle	short shift_ret	;yes: result = input
	cmp	ecx,64		;shifting 64 or more bits?
	jge	short shift_ret	;yes: result = input

	cmp	cl,32
	je	short glshift32	;shifting exactly 32 bits
	ja	short glshift33	;shifting more than 32 bits
				;shifting less than 32 bits
	shld	edx,eax,cl
	sll	eax,cl
	ret

glshift32:			;shift left exactly 32 bits
	mov	edx,eax		;copy least significant half to most signif.
	xor	eax,eax		;clear least significant half
	ret

glshift33:			;shift left more than 32 bits
	mov	edx,eax		;copy least significant half to most signif.
	xor	eax,eax		;clear least significant half
	sll	edx,cl		;shift (cl - 32) bits
shift_ret:
	ret
;
;
; ****************************
; *****  %_rshift.giant  *****  logical right shift giant
; ****************************
;
; in:	edx:eax = source operand
;	ecx = number of bits to shift
; out:	edx:eax = result
;
; destroys: nothing
;
%_rshift.giant:
	cmp	ecx,0		;shifting zero or fewer bits?
	jle	short shift_ret	;yes: result = input
	cmp	ecx,64		;shifting 64 or more bits?
	jge	short shift_ret	;yes: result = input

	cmp	cl,32
	je	short grshift32	;shifting exactly 32 bits
	ja	short grshift33	;shifting more than 32 bits
				;shifting less than 32 bits
	shrd	eax,edx,cl
	slr	edx,cl
	ret

grshift32:			;shift right exactly 32 bits
	mov	eax,edx		;copy most significant half to least signif.
	xor	edx,edx		;clear most significant half
	ret

grshift33:			;shift right more than 32 bits
	mov	eax,edx		;copy most significant half to least signif.
	xor	edx,edx		;clear most significant half
	slr	eax,cl		;shift (cl - 32) bits
	ret
;
;
; ****************************
; *****  %_dshift.giant  *****  arithmetic right shift giant
; ****************************
;
; in:	edx:eax = source operand
;	ecx = number of bits to shift
; out:	edx:eax = result
;
; destroys: nothing
;
%_dshift.giant:
	cmp	ecx,0		;shifting zero or fewer bits?
	jle	short shift_ret	;yes: result = input
	cmp	ecx,64		;shifting 64 or more bits?
	jge	short shift_ret	;yes: result = input

	cmp	cl,32
	je	short gdshift32	;shifting exactly 32 bits
	ja	short gdshift33	;shifting more than 32 bits
				;shifting less than 32 bits
	shrd	eax,edx,cl
	sar	edx,cl
	ret

gdshift32:			;shifting exactly 32 bits
	mov	eax,edx		;copy most significant half to least signif.
	sar	edx,31		;copy sign bit all over most significant half
	ret

gdshift33:			;shifting more than 32 bits
	mov	eax,edx		;copy most significant half to least signif.
	sar	edx,31		;copy sign bit all over most significant half
	sar	eax,cl		;shift right (cl - 32) bits
	ret
;
;
; *******************
; *****  high0  *****
; *****  high1  *****
; *******************
;
%_high0:
not	eax			; flip bits, then do high1
;;
%_high1:
mov	ecx, 32			; ecx = 32 = bit tested
;;
highloop:
dec	ecx			; ecx = bit to test
js	highdone		; ecx = -1 means all bits tested
sll	eax,1			; shift msb into C flag
jnc	short highloop		; if C flag = 0, keep looking
;;
highdone:
mov	eax, ecx		; eax = bit # of high 0 or high 1 bit
ret
;
;
; *************************
; *****  high0.giant  *****  eax = LS32
; *****  high1.giant  *****  edx = MS32
; *************************
;
%_high0.giant:
not	eax			; flip LS bits, then do high1
not	edx			; flip MS bits, then do high1
;;
%_high1.giant:
mov	ecx, 64			; ecx = 64 = bit tested
;;
highgiantloop:
dec	ecx			; ecx = bit to test
js	short highgiantdone	; ecx = -1 means all bits tested
sll	edx,1			; edx = MS << 1
jc	short highgiantdone	; found 1 bit
sll	eax,1			; eax = LS << 1
jnc	short highgiantloop	; eax MSb was 0 - continue loop
or	edx,1			; carry bit from LS to MS
jmp	short highgiantloop	;
;;
highgiantdone:
mov	eax, ecx		; eax = bit # of high 0 or high 1 bit
ret
;
;
;
;
;
;
; *************************
; *****  %_abs.slong  *****  ABS(x)
; *****  %_abs.xlong  *****
; *************************
;
; in:	arg0 = source number
; out:	eax = absolute value of source number
;
; destroys: nothing
;
; Generates overflow trap if source number is 0x80000000.
;
%_abs.slong:
%_abs.xlong:
	mov	eax,[esp+4]	;eax = source number
	or	eax,eax		;less than zero?
	jns	short abs_ret	;no: it's already its own absolute value
	cmp	eax,0x80000000	;cannot represent as positive signed number?
	je	short gen_overflow ;cannot: so generate an overflow
	neg	eax		;eax = ABS(source number)
abs_ret:
	ret

gen_overflow:
;	xor	eax,eax		;return zero
	jmp	%_eeeOverflow	; Return from there
;
;
; *************************
; *****  %_abs.ulong  *****  ABS(x)
; *************************
;
; in:	arg0 = source number
; out:	eax = source number
;
; destroys: nothing
;
%_abs.ulong:
	mov	eax,[esp+4]
	ret
;
;
; *************************
; *****  %_abs.giant  *****  ABS(giant)
; *************************
;
; in:	arg1:arg0 = source number
; out:	edx:eax = absolute value of source number
;
; destroys: nothing
;
; Generates an overflow trap if source number is 0x8000000000000000.
;
%_abs.giant:
	mov	edx,[esp+8]	;edx = ms half of source number
	mov	eax,[esp+4]	;eax = ls half of source number
	or	edx,edx		;greater than or equal to zero?
	jns	short gabs_ret	;yes: source number is its own absolute value

	cmp	edx,0x80000000	;make sure |edx:eax| can be represented as
	jne	short gabs_negate ; a signed 64-bit positive number
	or	eax,eax
	jz	gen_overflow

gabs_negate:
	not	edx		;negate edx:eax
	neg	eax
	sbb	edx,-1

gabs_ret:
	ret
;
;
; **************************
; *****  %_abs.single  *****  ABS(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = absolute value of source number
;
; destroys: nothing
;
%_abs.single:
	fld	dword ptr [esp+4]
	fabs
	ret
;
;
; **************************
; *****  %_abs.double  *****  ABS(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = absolute value of source number
;
; destroys: nothing
;
%_abs.double:
	fld	qword ptr [esp+4]
	fabs
	ret
;
;
; **************************
; *****  %_int.single  *****  INT(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = INT(source number) = largest integer less than or equal
;				     to source number
;
; destroys: ebx
;
%_int.single:
	fld	dword ptr [esp+4]
	jmp	short int.x
;
;
; **************************
; *****  %_int.double  *****  INT(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = INT(source number) = largest integer less than or equal
;				     to source number
; destroys: ebx
;
%_int.double:
	fld	qword ptr [esp+4]

int.x:
	fnstcw	[orig_control_bits]
	fwait
	mov	bx,[orig_control_bits]
	and	bx,0xF3FF	;mask out rounding-control bits
	or	bx,0x0400	;set rounding mode to: "round down"
	mov	[control_bits],bx ;why have one CPU when two will do?
	fldcw	[control_bits]
	frndint			;INT() the God-damned number, finally!
	fldcw	[orig_control_bits]
	ret
;
;
; **************************
; *****  %_fix.single  *****  FIX(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = source number truncated
;
; destroys: ebx
;
%_fix.single:
	fld	dword ptr [esp+4]
	jmp	short fix.x
;
; **************************
; *****  %_fix.double  *****  FIX(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = source number truncated
;
; destroys: ebx
;
%_fix.double:
	fld	qword ptr [esp+4]

fix.x:
	fnstcw	[orig_control_bits]
	fwait
	mov	bx,[orig_control_bits]
	or	bx,0x0C00	;set rounding mode to: "truncate"
	mov	[control_bits],bx ;why have one CPU when two will do?
	fldcw	[control_bits]
	frndint			;FIX() the God-damned number, finally!
	fldcw	[orig_control_bits]
	ret
;
;
; *************************
; *****  %_sgn.slong  *****  SGN(x)
; *****  %_sgn.xlong  *****
; *************************
;
; in:	arg0 = source number
; out:	eax = 1 if source number > 0
;	      0 if source number = 0
;	     -1 if source number < 0
;
; destroys: nothing
;
%_sgn.slong:
%_sgn.xlong:
	mov	eax,[esp+4]	;eax = source number
	sar	eax,31		;copy sign bit all over result
	cmp	[esp+4],0	;source number is greater than zero?
	jle	short sgn_ret	;no: result = eax
	inc	eax		;yes: result = 1
sgn_ret:
	ret
;
;
; *************************
; *****  %_sgn.ulong  *****  SGN(x)
; *************************
;
; in:	arg0 = source number
; out:	eax = 1 if source number > 0
;	      0 if source number = 0
;
; destroys: nothing
;
%_sgn.ulong:
	mov	eax,[esp+4]	;eax = source number
	or	eax,eax		;source number is zero?
	jz	short sgnu_ret	;yes: nothing to do
	mov	eax,1		;no: result = 1
sgnu_ret:
	ret
;
;
; *************************
; *****  %_sgn.giant  *****  SGN(giant)
; *************************
;
; in:	arg1:arg0 = source number
; out:	edx:eax = 1 if source number > 0
;	          0 if source number = 0
;	         -1 if source number < 0
;
; destroys: nothing
;
%_sgn.giant:
	mov	eax,[esp+4]	;eax = ls half of source number
	mov	edx,[esp+8]	;edx = ms half of source number
	cmp	edx,0
	jz	short sgng_ms_zero ;ms half of source number is zero
	jg	short sgng_one	;> 0; set result to 1

	or	edx,-1		;set result to -1
	mov	eax,edx
sgng_ret:
	ret

sgng_ms_zero:
	cmp	eax,0
	jz	sgng_ret	;source number is zero; so is result
	mov	eax,1		;> 0; result is 1
	ret

sgng_one:
	xor	edx,edx		;set result to 1
	mov	eax,1
	ret
;
;
; **************************
; *****  %_sgn.single  *****  SGN(single)
; **************************
;
; in:	arg0 = source number
; out:	st(0) = 1 if source number > 0
;	        0 if source number = 0
;	       -1 if source number < 0
;
; destroys: eax
;
%_sgn.single:
	fld	dword ptr [esp+4]
	jmp	short sgn.x
;
;
; **************************
; *****  %_sgn.double  *****  SGN(double)
; **************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = 1 if source number > 0
;	        0 if source number = 0
;	       -1 if source number < 0
;
; destroys: eax
;
%_sgn.double:
	fld	qword ptr [esp+4]

sgn.x:
	ftst				; "ftst" seems to cause trouble
	fstsw	ax
	sahf
	jz	short sgnx_ret	;source number = 0: result = source operand
	fstp	st(0)		;throw away source number
	fld1			;assume result = 1 until proven otherwise
	ja	short sgnx_ret	;source number > 0: result = 1
	fchs			;source number < 0: result = -1
sgnx_ret:
	ret
;
;
; **************************
; *****  %_sign.xlong  *****  SIGN(x)
; *****  %_sign.slong  *****
; **************************
;
; in:	arg0 = source number
; out:	eax = 1 if source number >= 0
;	     -1 if source number < 0
;
; destroys: nothing
;
%_sign.xlong:
%_sign.slong:
	mov	eax,[esp+4]	;eax = source number
	sar	eax,31		;copy sign bit all over source number
	jnz	short sign_ret	;if -1, done
	inc	eax		;if 0, set to 1
sign_ret:
	ret
;
;
; **************************
; *****  %_sign.ulong  *****  SIGN(x)
; **************************
;
; in:	arg0 = source number
; out:	eax = 1
;
; destroys: nothing
;
%_sign.ulong:
	mov	eax,1
	ret
;
;
; **************************
; *****  %_sign.giant  *****  SIGN(giant)
; **************************
;
; in:	arg1:arg0 = source number
; out:	edx:eax = 1 if source number >= 0
;	         -1 if source number < 0
;
; destroys: nothing
;
%_sign.giant:
	mov	edx,[esp+8]	;edx = ms half of source number
	sar	edx,31		;copy sign bit all over edx
	mov	eax,edx		;copy sign bit all over eax
	jnz	short signg_ret	;if -1, done
	inc	eax		;if 0, result is 1
signg_ret:
	ret
;
;
; ***************************
; *****  %_sign.single  *****  SIGN(single)
; ***************************
;
; in:	arg0 = source number
; out:	st(0) = 1 if source number >= 0
;	       -1 if source number < 0
;
; destroys: eax
;
%_sign.single:
	fld	dword ptr [esp+4]
	jmp	short sign.x
;
;
; ***************************
; *****  %_sign.double  *****
; ***************************
;
; in:	arg1:arg0 = source number
; out:	st(0) = 1 if source number >= 0
;	       -1 if source number < 0
;
; destroys: eax
;
%_sign.double:
	fld	qword ptr [esp+4]

sign.x:
	ftst				; "ftst" seems to cause trouble
	fstsw	ax
	sahf
	fstp	st(0)		;throw away source number
	fld1			;result is 1 until proven otherwise
	jae	short signx_ret	;source >= 0: result = 1
	fchs			;source < 0: result = -1
signx_ret:
	ret
;
;
; *************************
; *****  %_MAX.slong  *****
; *****  %_MAX.xlong  *****
; *************************
;
%_MAX.slong:
%_MAX.xlong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx		; 1st : 2nd
jge	short %done0		; 1st > 2nd
mov	eax, ebx		; 2nd > 1st
%done0:
ret
;
;
; *************************
; *****  %_MAX.ulong  *****
; *************************
;
%_MAX.ulong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx		; 1st : 2nd
ja	short %done1		; 1st > 2nd
mov	eax, ebx		; 2nd > 1st
%done1:
ret
;
;
; **************************
; *****  %_MAX.single  *****
; **************************
;
%_MAX.single:
fld	dword ptr [esp+4]	; 1st arg
fld	dword ptr [esp+8]	; 2nd arg
fcompp				; 1st : 2nd
fstsw	ax			; get flags in ax
sahf				; put flags in cc
ja	short %s2nd		; 2nd arg is larger
;;
%s1st:
fld	dword ptr [esp+4]	; 1st arg
ret
;
%s2nd:
fld	dword ptr [esp+8]	; 2nd arg
ret
;
;
; **************************
; *****  %_MAX.double  *****
; **************************
;
%_MAX.double:
fld	qword ptr [esp+4]	; 1st arg
fld	qword ptr [esp+12]	; 2nd arg
fcompp				; 1st : 2nd
fstsw	ax			; get flags in ax
sahf				; put flags in cc
ja	short %d2nd		; 2nd arg is larger
;;
%d1st:
fld	qword ptr [esp+4]	; 1st arg
ret
;
%d2nd:
fld	qword ptr [esp+12]	; 2nd arg
ret
;
;
;
; *************************
; *****  %_MIN.slong  *****
; *****  %_MIN.xlong  *****
; *************************
;
%_MIN.slong:
%_MIN.xlong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx		; 1st : 2nd
jle	short %done2		; 1st > 2nd
mov	eax, ebx		; 2nd > 1st
%done2:
ret
;
;
; *************************
; *****  %_MIN.ulong  *****
; *************************
;
%_MIN.ulong:
mov	eax, [esp+4]		; 1st arg
mov	ebx, [esp+8]		; 2nd arg
cmp	eax, ebx		; 1st : 2nd
jb	short %done3		; 1st > 2nd
mov	eax, ebx		; 2nd > 1st
%done3:
ret
;
;
; **************************
; *****  %_MIN.single  *****
; **************************
;
%_MIN.single:
fld	dword ptr [esp+4]	; 1st arg
fld	dword ptr [esp+8]	; 2nd arg
fcompp				; 1st : 2nd
fstsw	ax			; get flags in ax
sahf				; put flags in cc
jb	short %ss2nd		; 2nd arg is larger
;;
%ss1st:
fld	dword ptr [esp+4]	; 1st arg
ret
;
%ss2nd:
fld	dword ptr [esp+8]	; 2nd arg
ret
;
;
; **************************
; *****  %_MIN.double  *****
; **************************
;
%_MIN.double:
fld	qword ptr [esp+4]	; 1st arg
fld	qword ptr [esp+12]	; 2nd arg
fcompp				; 1st : 2nd
fstsw	ax			; get flags in ax
sahf				; put flags in cc
jb	short %dd2nd		; 2nd arg is larger
;;
%dd1st:
fld	qword ptr [esp+4]	; 1st arg
ret
;
%dd2nd:
fld	qword ptr [esp+12]	; 2nd arg
ret
;
;
;
; ****************************
; *****  %_add.SCOMPLEX  *****  z3 = z1 + z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) + Re(z2)
; Im(z3) = Im(z1) + Im(z2)
;
%_add.SCOMPLEX:
	fld	dword ptr [esi]	;add real components
	fld	dword ptr [edi]
	fadd
	fstp	dword ptr [eax]

	fld	dword ptr [esi+4] ;add imaginary components (but really add them)
	fld	dword ptr [edi+4]
	fadd
	fstp	dword ptr [eax+4]
	ret
;
;
; ****************************
; *****  %_add.DCOMPLEX  *****  z3 = z1 + z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) + Re(z2)
; Im(z3) = Im(z1) + Im(z2)
;
%_add.DCOMPLEX:
	fld	qword ptr [esi]	;add real components
	fld	qword ptr [edi]
	fadd
	fstp	qword ptr [eax]

	fld	qword ptr [esi+8] ;add imaginary components
	fld	qword ptr [edi+8]
	fadd
	fstp	qword ptr [eax+8]
	ret
;
;
; ****************************
; *****  %_sub.SCOMPLEX  *****  z3 = z1 - z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) - Re(z2)
; Im(z3) = Im(z1) - Im(z2)
;
%_sub.SCOMPLEX:
	fld	dword ptr [esi] ;subtract real components
	fld	dword ptr [edi]
	fsub
	fstp	dword ptr [eax]

	fld	dword ptr [esi+4] ;subtract imaginary components
	fld	dword ptr [edi+4]
	fsub
	fstp	dword ptr [eax+4]
	ret
;
;
; ****************************
; *****  %_sub.DCOMPLEX  *****  z3 = z1 - z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) - Re(z2)
; Im(z3) = Im(z1) - Im(z2)
;
%_sub.DCOMPLEX:
	fld	qword ptr [esi] ;subtract real components
	fld	qword ptr [edi]
	fsub
	fstp	qword ptr [eax]

	fld	qword ptr [esi+8] ;subtract imaginary components
	fld	qword ptr [edi+8]
	fsub
	fstp	qword ptr [eax+8]
	ret
;
;
; ****************************
; *****  %_mul.SCOMPLEX  *****  z3 = z1 * z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) * Re(z2) - Im(z1) * Im(z2)
; Im(z3) = Re(z1) * Im(z2) + Im(z1) * Re(z2)
;
%_mul.SCOMPLEX:
	fld	dword ptr [esi]	;calculate real part of product
	fld	dword ptr [edi]
	fmul
	fld	dword ptr [esi+4]
	fld	dword ptr [edi+4]
	fmul
	fsub
	fstp	dword ptr [eax]

	fld	dword ptr [esi]	;calculate imaginary part of product
	fld	dword ptr [edi+4]
	fmul
	fld	dword ptr [esi+4]
	fld	dword ptr [edi]
	fmul
	fadd
	fstp	dword ptr [eax+4]
	ret
;
;
; ****************************
; *****  %_mul.DCOMPLEX  *****  z3 = z1 * z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
; Re(z3) = Re(z1) * Re(z2) - Im(z1) * Im(z2)
; Im(z3) = Re(z1) * Im(z2) + Im(z1) * Re(z2)
;
%_mul.DCOMPLEX:
	fld	qword ptr [esi]	;calculate real part of product
	fld	qword ptr [edi]
	fmul
	fld	qword ptr [esi+8]
	fld	qword ptr [edi+8]
	fmul
	fsub
	fstp	qword ptr [eax]

	fld	qword ptr [esi]	;calculate imaginary part of product
	fld	qword ptr [edi+8]
	fmul
	fld	qword ptr [esi+8]
	fld	qword ptr [edi]
	fmul
	fadd
	fstp	qword ptr [eax+8]
	ret
;
;
; ****************************
; *****  %_div.SCOMPLEX  *****  z3 = z1 / z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
;	   Re(z1) * Re(z2) + Im(z1) * Im(z2)
; Re(z3) = ---------------------------------
;	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
;
;	   Im(z1) * Re(z2) - Im(z2) * Re(z1)
; Im(z3) = ---------------------------------
;	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
;
%_div.SCOMPLEX:
	fld	dword ptr [esi]	;calculate real part of quotient
	fld	dword ptr [edi]
	fmul
	fld	dword ptr [esi+4]
	fld	dword ptr [edi+4]
	fmul
	fadd			;st(0) = numerator

	fld	dword ptr [edi]
	fld	st(0)
	fmul
	fld	dword ptr [edi+4]
	fld	st(0)
	fmul
	fadd			;st(0) = denominator, st(1) = numerator
	fst	st(2)		;save denominator for later

	fdiv
	fstp	dword ptr [eax]	;store real part of quotient

	fld	dword ptr [esi+4] ;calculate imaginary part of quotient
	fld	dword ptr [edi]
	fmul
	fld	dword ptr [edi+4]
	fld	dword ptr [esi]
	fmul
	fsub			;st(0) = numerator, st(1) = denominator

	fdivr
	fstp	dword ptr [eax+4] ;store imaginary part of quotient
	ret
;
;
; ****************************
; *****  %_div.DCOMPLEX  *****  z3 = z1 / z2
; ****************************
;
; in:	eax -> z3 (result)
;	esi -> z1
;	edi -> z2
; out:	eax -> z3 (result)
;
; destroys: nothing
;
;	   Re(z1) * Re(z2) + Im(z1) * Im(z2)
; Re(z3) = ---------------------------------
;	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
;
;	   Im(z1) * Re(z2) - Im(z2) * Re(z1)
; Im(z3) = ---------------------------------
;	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
;
%_div.DCOMPLEX:
	fld	qword ptr [esi]	;calculate real part of quotient
	fld	qword ptr [edi]
	fmul
	fld	qword ptr [esi+8]
	fld	qword ptr [edi+8]
	fmul
	fadd			;st(0) = numerator

	fld	qword ptr [edi]
	fld	st(0)
	fmul
	fld	qword ptr [edi+8]
	fld	st(0)
	fmul
	fadd			;st(0) = denominator, st(1) = numerator
	fst	st(2)		;save denominator for later

	fdiv
	fstp	qword ptr [eax]	;store real part of quotient

	fld	qword ptr [esi+8] ;calculate imaginary part of quotient
	fld	qword ptr [edi]
	fmul
	fld	qword ptr [edi+8]
	fld	qword ptr [esi]
	fmul
	fsub			;st(0) = numerator, st(1) = denominator

	fdivr
	fstp	qword ptr [eax+8] ;store imaginary part of quotient
	ret
;
;
; **********************************
; *****  **  (POWER operator)  *****
; **********************************
;
%_power.slong:
%_power.xlong:
push	0
push	eax			; x
push	0
push	ebx			; y
fild	dword ptr [esp+0]	; FPU = x
fild	dword ptr [esp+8]	; FPU = y
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	dword ptr [esp+0]	; a
pop	eax			; eax = a  (result)
pop	edx			; edx = garbage  (clean up stack)
ret
;
;
;
%_rpower.slong:
%_rpower.xlong:
push	0
push	ebx			; y
push	0
push	eax			; x
fild	dword ptr [esp+0]	; FPU = x
fild	dword ptr [esp+8]	; FPU = y
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	dword ptr [esp+0]	; a
pop	eax			; eax = a  (result)
pop	edx			; edx = garbage  (clean up stack)
ret
;
;
;
%_power.ulong:
push	0
push	eax
push	0
push	ebx
fild	qword ptr [esp+0]	; FPU = y
fild	qword ptr [esp+8]	; FPU = x
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	qword ptr [esp+0]	; a$$
pop	eax			; eax = LSW of a$$
pop	edx			; edx = MSW of a$$
or	edx,edx			; is MSW = 0 ???
jnz	power.overflow		; if not, result is too large for ULONG
ret
;
;
;
%_rpower.ulong:
push	0
push	ebx
push	0
push	eax
fild	qword ptr [esp+0]	; FPU = y
fild	qword ptr [esp+8]	; FPU = x
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	qword ptr [esp+0]	; a$$
pop	eax			; eax = LSW of a$$
pop	edx			; edx = MSW of a$$
or	edx,edx			; is MSW = 0 ???
jnz	power.overflow		; if not, result is too large for ULONG
ret
;
;
;
%_power.giant:
push	edx
push	eax
push	ecx
push	ebx
fild	qword ptr [esp+0]	; FPU = y
fild	qword ptr [esp+8]	; FPU = x
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	qword ptr [esp+0]	; a$$
pop	eax			; eax = LSW of a$$
pop	edx			; edx = MSW of a$$
ret
;
;
;
%_rpower.giant:
push	ecx
push	ebx
push	edx
push	eax
fild	qword ptr [esp+0]	; FPU = y
fild	qword ptr [esp+8]	; FPU = x
fstp	qword ptr [esp+0]	; arg1 = x#
fstp	qword ptr [esp+8]	; arg2 = y#
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fistp	qword ptr [esp+0]	; a$$
pop	eax			; eax = LSW of a$$
pop	edx			; edx = MSW of a$$
ret
;
;
;
%_power.single:
sub	esp,16			;
fstp	qword ptr [esp+8]	;
fstp	qword ptr [esp+0]	;
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fst	dword ptr [esp+0]	; a!
pop	eax			; eax = a!
pop	edx			; garbage  (clean stack)
ret
;
;
;
%_rpower.single:
sub	esp,16			;
fstp	qword ptr [esp+0]	;
fstp	qword ptr [esp+8]	;
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fst	dword ptr [esp+0]	; a!
pop	eax			; eax = a!
pop	edx			; garbage  (clean stack)
ret
;
;
;
%_power.double:
sub	esp,16			;
fstp	qword ptr [esp+8]	;
fstp	qword ptr [esp+0]	;
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fst	qword ptr [esp+0]	; a#
pop	eax			; eax = LSW of a#
pop	edx			; edx = MSW of a#
ret
;
;
;
%_rpower.double:
sub	esp,16			;
fstp	qword ptr [esp+0]	;
fstp	qword ptr [esp+8]	;
call	_POWER@16		; math library function  a# = POWER (x#, y#)
sub	esp,8			;
fst	qword ptr [esp+0]	; a#
pop	eax			; eax = LSW of a#
pop	edx			; edx = MSW of a#
ret
;
;
power.overflow:
jmp	%_eeeOverflow		; no, so result is too large for ULONG
ret
;
;
;
;
;
;
; *************************
; *****  %_extu.2arg  *****  EXTU(v, bitfield)
; *************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = bitfield extracted from arg0, zero-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
%_extu.2arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ebx,[esp+8]	;ebx = width:offset
	mov	ecx,ebx		;ecx = offset with extra bits on top
	slr	ebx,5		;shift width into low 5 bits of ebx

	slr	eax,cl		;shift bitfield to right (low) end of eax
	and	ebx,31		;only want low 5 bits of width
	and	eax,[width_table + ebx*4] ;screen out all but width bits

	ret
;
;
; *************************
; *****  %_extu.3arg  *****  EXTU(v, width, offset)
; *************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
;
; out:	eax = bitfield extract from arg0, zero-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
%_extu.3arg:
	mov	eax,[esp+4]	;eax = value from which to extract bitfield
	mov	ebx,[esp+8]	;ebx = width
	mov	ecx,[esp+12]	;ecx = offset

	slr	eax,cl		;shift bitfield to right (low) end of eax
	and	ebx,31		;only want low 5 bits of width
	and	eax,[width_table + ebx*4] ;screen out all but width bits

	ret
;
;
; ************************
; *****  %_ext.2arg  *****  EXTS(v, bitfield)
; ************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = bitfield extracted from arg0, sign-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
%_ext.2arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ebx,[esp+8]	;ebx = width:offset
	mov	ecx,ebx
	slr	ecx,5		;ecx = width with extra bits on top
	and	ecx,31		;only want low 5 bits of width
	and	ebx,31		;only want low 5 bits of offset

	add	ecx,ebx		;ecx = width + offset
	neg	ecx
	add	ecx,32		;ecx = 32 - (width + offset)
	sll	eax,cl		;shift bit field to top of eax
	add	ecx,ebx		;ecx = 32 - width
	sar	eax,cl		;shift back to bottom of eax, sign-extending
				; along the way
	ret
;
;
; ************************
; *****  %_ext.3arg  *****  EXTS(v, width, offset)
; ************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
;
; out:	eax = bitfield extract from arg0, sign-extended
;
; destroys: ebx, ecx, edx, esi, edi
;
%_ext.3arg:
	mov	eax,[esp+4]	;eax = value from which to extract bitfield
	mov	ecx,[esp+8]	;ecx = width
	mov	ebx,[esp+12]	;ebx = offset
	and	ecx,31		;no silly widths
	and	ebx,31		;no silly offsets

	add	ecx,ebx		;ecx = width + offset
	neg	ecx
	add	ecx,32		;ecx = 32 - (width + offset)
	sll	eax,cl		;shift bit field to top of eax
	add	ecx,ebx		;ecx = 32 - width
	sar	eax,cl		;shift back to bottom of eax, sign-extending
				; along the way
	ret
;
;
; ************************
; *****  %_clr.2arg  *****  CLR(v, bitfield)
; ************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = arg0 with specified bitfield cleared
;
; destroys: ebx, ecx, edx, esi, edi
;
%_clr.2arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ebx,[esp+8]	;ebx = width:offset
	mov	ecx,ebx		;ecx = offset with extra bits on top
	slr	ecx,5		;shift width into low 5 bits of ecx
	dec	ecx		;translate 0 to 32, leave shift count in ecx
	and	ecx,31		;only low bits of width
	and	ebx,31		;only low bits of offset

	mov	edx,0x80000000	;get a bit to copy
	sar	edx,cl		;copy it width times
	add	ecx,ebx		;ecx = width + offset
	neg	ecx
	add	ecx,31		;ecx = 32 - (width + offset)
	slr	edx,cl		;move block of 1's into position for mask
	not	edx		;edx = mask: 0's where bitfield is
	and	eax,edx		;clear the bitfield

	ret
;
;
; ************************
; *****  %_clr.3arg  *****  CLR(v, width, offset)
; ************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
; out:	eax = arg0 with specified bitfield cleared
;
; destroys: ebx, ecx, edx, esi, edi
;
%_clr.3arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ecx,[esp+8]	;ecx = width
	mov	ebx,[esp+12]	;ebx = offset
	dec	ecx		;translate 0 to 32, leave shift count in ecx
	and	ecx,31		;only low bits of width
	and	ebx,31		;only low bits of offset

	mov	edx,0x80000000	;get a bit to copy
	sar	edx,cl		;copy it (width-1) times
	add	ecx,ebx		;ecx = width + offset
	neg	ecx
	add	ecx,31		;ecx = 32 - (width + offset)
	slr	edx,cl		;move block of 1's into position for mask
	not	edx		;edx = mask: 0's where bitfield is
	and	eax,edx		;clear the bitfield

	ret
;
;
; ************************
; *****  %_set.2arg  *****  SET(v, bitfield)
; ************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
%_set.2arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ebx,[esp+8]	;ebx = width:offset
	mov	ecx,ebx		;ecx = offset with extra bits on top
	slr	ecx,5		;shift width into low 5 bits of ecx
	dec	ecx		;translate 0 to 32, leave shift count in ecx
	and	ecx,31		;only low bits of width
	and	ebx,31		;only low bits of offset

	mov	edx,0x80000000	;get a bit to copy
	sar	edx,cl		;copy it width times
	add	ecx,ebx		;ecx = width + offset - 1
	neg	ecx
	add	ecx,31		;ecx = 32 - (width + offset)
	slr	edx,cl		;move block of 1's into position for mask
	or	eax,edx		;set the bitfield

	ret
;
;
; ************************
; *****  %_set.3arg  *****  SET(v, width, offset)
; ************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
%_set.3arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ecx,[esp+8]	;ecx = width
	mov	ebx,[esp+12]	;ebx = offset
	dec	ecx		;translate 0 to 32, leave shift count in ecx
	and	ecx,31		;only low bits of width
	and	ebx,31		;only low bits of offset

	mov	edx,0x80000000	;get a bit to copy
	sar	edx,cl		;copy it (width-1) times
	add	ecx,ebx		;ecx = width + offset - 1
	neg	ecx
	add	ecx,31		;ecx = 32 - (width + offset)
	slr	edx,cl		;move block of 1's into position for mask
	or	eax,edx		;set the bitfield

	ret
;
;
; *************************
; *****  %_make.2arg  *****  MAKE(v, bitfield)
; *************************
;
; in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
;	arg0 = value from which to extract bit field
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
%_make.2arg:
	mov	eax,[esp+4]	;eax = value from which to extract bit field
	mov	ebx,[esp+8]	;ebx = width:offset
	mov	ecx,ebx		;ecx = offset with extra bits on top
	slr	ebx,5		;ebx = width with extra bits on top

	and	ebx,31		;want only low 5 bits of width
	and	eax,[width_table + ebx*4] ;cut off all but width bits
	sll	eax,cl		;shift up to offset position

	ret
;
;
; *************************
; *****  %_make.3arg  *****  MAKE(v, width, offset)
; *************************
;
; in:	arg2 = offset of bitfield
;	arg1 = width of bitfield
;	arg0 = value from which to extract bitfield
; out:	eax = arg0 with specified bitfield set
;
; destroys: ebx, ecx, edx, esi, edi
;
%_make.3arg:
	mov	eax,[esp+4]	;eax = value from which to extract bitfield
	mov	ebx,[esp+8]	;ebx = width
	mov	ecx,[esp+12]	;ecx = offset

	and	ebx,31		;want only low 5 bits of width
	and	eax,[width_table + ebx*4] ;cut off all but width bits
	sll	eax,cl		;shift up to offset position

	ret
;
;
; *********************
; *****  %_error  *****  errorNumber = ERROR (arg)
; *********************
;
%_error:
	mov	ebx, eax	; ebx = arg
	inc	ebx		; ebx = 0 if arg = -1
	jz	getError	; get ##ERROR but don't update it
	xchg	eax,[_##ERROR]	; eax = ##ERROR : ##ERROR = arg
	ret
;
getError:
	mov	eax,[_##ERROR]	; eax = ##ERROR : ##ERROR unchanged
	ret
;
;
;
; ##################
; #####  DATA  #####  xlibnn.s
; ##################
;
;
; *****  Width Table  *****
;
.text
.align	8
width_table:
	.dword	0b11111111111111111111111111111111
	.dword	0b00000000000000000000000000000001
	.dword	0b00000000000000000000000000000011
	.dword	0b00000000000000000000000000000111
	.dword	0b00000000000000000000000000001111
	.dword	0b00000000000000000000000000011111
	.dword	0b00000000000000000000000000111111
	.dword	0b00000000000000000000000001111111
	.dword	0b00000000000000000000000011111111
	.dword	0b00000000000000000000000111111111
	.dword	0b00000000000000000000001111111111
	.dword	0b00000000000000000000011111111111
	.dword	0b00000000000000000000111111111111
	.dword	0b00000000000000000001111111111111
	.dword	0b00000000000000000011111111111111
	.dword	0b00000000000000000111111111111111
	.dword	0b00000000000000001111111111111111
	.dword	0b00000000000000011111111111111111
	.dword	0b00000000000000111111111111111111
	.dword	0b00000000000001111111111111111111
	.dword	0b00000000000011111111111111111111
	.dword	0b00000000000111111111111111111111
	.dword	0b00000000001111111111111111111111
	.dword	0b00000000011111111111111111111111
	.dword	0b00000000111111111111111111111111
	.dword	0b00000001111111111111111111111111
	.dword	0b00000011111111111111111111111111
	.dword	0b00000111111111111111111111111111
	.dword	0b00001111111111111111111111111111
	.dword	0b00011111111111111111111111111111
	.dword	0b00111111111111111111111111111111
	.dword	0b01111111111111111111111111111111
;
;
;
.text
;
; ######################
; #####  xlibns.s  #####  intrinsics that accept a string and return a number
; ######################
;
; **********************
; *****  %_len.v   *****  LEN(x$)
; *****  %_len.s   *****
; *****  %_size.v  *****  SIZE(x$)
; *****  %_size.s  *****
; **********************
;
; in:	arg0 -> string to return the length of
; out:	eax = length of string
;
; destroys: ebx, ecx, edx, esi, edi
;
; LEN(x$) and SIZE(x$) are the same function.
;
%_len.v:
%_size.v:
	xor	esi,esi		;no string to free on exit
	jmp	short len.x
;
%_len.s:
%_size.s:
	mov	esi,[esp+4]	;esi -> string to free on exit
;;
;; fall through
;;
len.x:
	xor	eax,eax		;assume length is zero until proven otherwise
	mov	edi,[esp+4]	;edi -> string to find the length of
	or	edi,edi		;null pointer?
	jz	short len_exit	;yes: nothing to do
	mov	eax,[edi-8]	;eax = length of string
	call	%____free	;free source string if called from .s entry
;;				; point
len_exit:
	ret
;
;
; ***********************
; *****  %_csize.v  *****  CSIZE(x$)
; *****  %_csize.s  *****
; ***********************
;
; in:	arg0 -> source string
; out:	eax = number of characters in source string up to but not including
;	      the first null
;
; destroys: ebx, ecx, edx, esi, edi
;
%_csize.v:
	xor	esi,esi		;nothing to free on exit
	jmp	short csize.x
;
%_csize.s:
	mov	esi,[esp+4]	;free source string on exit
;;
;; fall through
;;
csize.x:
	mov	eax,[esp+4]	;eax -> source string
	or	eax,eax		;null pointer?
	jz	short csize_exit ;yes: nothing to do

	mov	edi,eax		;edi -> source string
	mov	ecx,-1		;search until we find a null or cause a
				; memory fault
	xor	eax,eax		;search for a null
	cld			;make sure we're going in the right direction
	repne
	scasb			;edi -> terminating null
	not	ecx		;ecx = length + 1
	lea	eax,[ecx-1]	;eax = length not counting terminator null

	call	%____free	;free source string if called from .s entry
				; point
csize_exit:
	ret
;
;
; *********************
; *****  %_asc.v  *****  ASC(x$, y)
; *****  %_asc.s  *****
; *********************
;
; in:	arg1 = index into x$ (one-biased)
;	arg0 -> source string
; out:	eax = ASCII value of character in x$ at position y
;
; destroys: ebx, ecx, edx, esi, edi
;
; If y < 1 or y > LEN(x$), generates "illegal function call" error and
; returns zero.
;
%_asc.v:
	xor	esi,esi		;nothing to free on exit
	jmp	short asc.x
;
%_asc.s:
	mov	esi,[esp+4]	;free source string on exit
;;
;; fall through
;;
asc.x:
	mov	eax,[esp+4]	;eax -> source string
	or	eax,eax		;null pointer?
	jz	short asc_IFC	;yes: error

	mov	ebx,[esp+8]	;ebx = index into source string (one-biased)
	cmp	ebx,[eax-8]	;greater than length of string?
	ja	short asc_IFC	;yes: error
	dec	ebx		;ebx = offset into source string
	js	short asc_IFC	;if before beginning of string, error
	movzx	eax,byte ptr [eax+ebx] ;eax = ASC(x$,y)
	jmp	%____free	;free source string (esi) if called from .s
				; entry point, and return value in eax
asc_IFC:
	xor	eax,eax		;return a zero if there was an error
	call	%____free	;free source string (esi) if called from .s
				; entry point
	jmp	%_InvalidFunctionCall	; Return directly from there
						; (assumes esi is not destroyed)

;
;
; ************************
; *****  %_inchr.vv  *****  INCHR(x$, y$, z)
; *****  %_inchr.vs  *****
; *****  %_inchr.sv  *****
; *****  %_inchr.ss  *****
; ************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: string containing set of characters to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; INCHR()'s search is case-sensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INCHR() returns 0.
;
; INCHR() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to characters in y$.
;
; INCHR() never generates a run-time error.
;
%_inchr.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short inchr.x
;
%_inchr.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short inchr.x
;
%_inchr.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short inchr.x
;
%_inchr.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
inchr.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	short inchr_done ;yes: can't find anything in null string
	mov	edx,[edi-8]	;edx = LEN(x$)
	or	edx,edx		;length is zero?
	jz	short inchr_done ;yes: can't find anything in zero-length string
	cmp	edx,[ebp+16]	;length is less than start position?
	jb	short inchr_done ;yes: can't find anything off right end of x$

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short inchr_done ;yes: null string can't contain matches
	mov	ecx,[esi-8]	;ecx = LEN(y$)
	or	ecx,ecx		;length is zero?
	jz	short inchr_done ;yes: zero-length string can't contain matches

; build table at search_tab

	mov	ebx,search_tab	;ebx -> base of search table
	xor	eax,eax		;zero upper 24 bits of index into search_tab
inchr_table_build_loop:
	lodsb			;get next char from y$ into al
	mov	byte ptr [ebx+eax],1 ;mark char's element in table
	dec	ecx		;bump character counter
	jnz	inchr_table_build_loop ;next character

; search x$ for any chars with non-zero element in search_tab

	mov	esi,edi		;esi -> x$
	mov	edi,[ebp+16]	;edi = start position (one-biased)
	or	edi,edi		;start position is zero?
	jz	short inchr_skip1 ;yes: start at first position
	dec	edi		;edi = start offset
inchr_skip1:
	sub	edx,edi		;edx = number of chars to check
	add	esi,edi		;esi -> first character to check

inchr_search_loop:
	inc	edi		;bump position counter
	lodsb			;get next char from x$ into al
	xlatb			;look up al's element in search_tab
	or	al,al		;al != 0 iff al was in y$
	jnz	short inchr_found ;if char is in y$, done
	dec	edx		;bump character counter
	jnz	inchr_search_loop

; re-zero table at search_tab (so next call to INCHR() works)

inchr_rezero:
	mov	esi,[ebp+12]	;esi -> y$
	mov	ecx,[esi-8]	;ecx = number of chars in y$
inchr_table_zero_loop:
	lodsb			;get next char from y$ into al
	mov	byte ptr [ebx+eax],0 ;zero char's element in table
	dec	ecx		;bump character counter
	jnz	inchr_table_zero_loop

; free stack strings and exit

inchr_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs ro be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

inchr_found:
	mov	[ebp-12],edi	;return value is current character position
	jmp	inchr_rezero
;
;
; *************************
; *****  %_inchri.vv  *****  INCHRI(x$, y$, z)
; *****  %_inchri.vs  *****
; *****  %_inchri.sv  *****
; *****  %_inchri.ss  *****
; *************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: string containing set of characters to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; INCHRI()'s search is case-insensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INCHRI() returns 0.
;
; INCHRI() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to upper- and lower-case versions
; of characters in y$.
;
; INCHRI() never generates a run-time error.
;
%_inchri.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short inchri.x
;
%_inchri.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short inchri.x
;
%_inchri.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short inchri.x
;
%_inchri.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
inchri.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	inchri_done	;yes: can't find anything in null string
	mov	edx,[edi-8]	;edx = LEN(x$)
	or	edx,edx		;length is zero?
	jz	inchri_done ;yes: can't find anything in 0-length string
	cmp	edx,[ebp+16]	;length is less than start position?
	jb	short inchr_done ;yes: can't find anything off right end of x$

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short inchri_done ;yes: null string can't contain matches
	mov	ecx,[esi-8]	;ecx = LEN(y$)
	or	ecx,ecx		;length is zero?
	jz	short inchri_done ;yes: zero-length string can't contain matches
;
; build table at search_tab
;
	mov	edx,search_tab	;edx -> base of search table
	mov	ebx,%_uctolc	;ebx -> base of upper-to-lower conv. table
	mov	edi,%_lctouc	;edi -> base of lower-to-upper conv. table
	xor	eax,eax		;zero upper 24 bits of index into search_tab
inchri_table_build_loop:
	lodsb			;get next char from y$ into al
	xlatb			;convert char to lower case
	mov	byte ptr [edx+eax],1 ;mark char's element in table
	mov	al,[edi+eax]	;convert char to upper case
	mov	byte ptr [edx+eax],1 ;mark char's element in table
	dec	ecx		;bump character counter
	jnz	inchri_table_build_loop ;next character
;
; search x$ for any chars with non-zero element in search_tab
;
	mov	esi,[ebp+8]	;esi -> x$
	mov	edi,[ebp+16]	;edi = start position (one-biased)
	or	edi,edi		;start position is zero?
	jz	short inchri_skip1 ;yes: start at first position
	dec	edi		;edi = start offset
inchri_skip1:
	mov	edx,[esi-8]	;edx = number of chars in x$
	sub	edx,edi		;edx = number of chars to check
	add	esi,edi		;esi -> first character to check
	mov	ebx,search_tab	;ebx -> base of y$ lookup table
;
inchri_search_loop:
	inc	edi		;bump position counter
	lodsb			;get next char from x$ into al
	xlatb			;look up al's element in search_tab
	or	al,al		;al != 0 iff al was in y$
	jnz	short inchri_found ;if char is in y$, done
	dec	edx		;bump character counter
	jnz	inchri_search_loop
;
; re-zero table at search_tab (so next call to INCHR() works)
;
inchri_rezero:
	mov	esi,[ebp+12]	;esi -> y$
	mov	edx,search_tab	;edx -> base of search table
	mov	edi,%_lctouc	;edi -> base of lower-to-upper conv. table
	mov	ebx,%_uctolc	;ebx -> base of upper-to-lower conv. table
	mov	ecx,[esi-8]	;ecx = number of chars in y$
inchri_table_zero_loop:
	lodsb			;get next char from y$ into al
	xlatb			;convert char to lower case
	mov	byte ptr [edx+eax],0 ;zero char's element in table
	mov	al,[edi+eax]	;convert char to upper case
	mov	byte ptr [edx+eax],0 ;zero char's element in table
	dec	ecx		;bump character counter
	jnz	inchri_table_zero_loop

; free stack strings and exit

inchri_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs ro be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

inchri_found:
	mov	[ebp-12],edi	;return value is current character position
	jmp	inchri_rezero
;
;
; *************************
; *****  %_rinchr.vv  *****  RINCHR(x$, y$, z)
; *****  %_rinchr.sv  *****
; *****  %_rinchr.vs  *****
; *****  %_rinchr.ss  *****
; *************************
;
; in:	arg2 = start position (one-biased) in x$ at which to begin search
;	arg1 -> y$: string containing set of characters to search for
;	arg0 -> x$: string in which to search
; out:	eax = position in x$
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; RINCHR()'s search is case-sensitive, and proceeds backwards in x$ from
; the start position.  A start position of zero is equivalent to a
; start position of LEN(x$).  A start position greater than LEN(x$)
; is equivalent to a start position of LEN(x$).
;
; RINCHR() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to characters in y$.
;
; RINCHR() never generates a run-time error.
;
%_rinchr.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinchr.x
;
%_rinchr.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short rinchr.x
;
%_rinchr.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinchr.x
;
%_rinchr.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
rinchr.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	short rinchr_done ;yes: can't find anything in null string
	mov	edx,[edi-8]	;edx = LEN(x$)
	or	edx,edx		;length is zero?
	jz	short rinchr_done ;yes: can't find anything in 0-length string

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short rinchr_done ;yes: null string can't contain matches
	mov	ecx,[esi-8]	;ecx = LEN(y$)
	or	ecx,ecx		;length is zero?
	jz	short rinchr_done ;yes: zero-length string can't contain matches
;
; build table at search_tab
;
	mov	ebx,search_tab	;ebx -> base of search table
	xor	eax,eax		;zero upper 24 bits of index into search_tab
rinchr_table_build_loop:
	lodsb			;get next char from y$ into al
	mov	byte ptr [ebx+eax],1 ;mark char's element in table
	dec	ecx		;bump character counter
	jnz	rinchr_table_build_loop ;next character
;
; search x$ for any chars with non-zero element in search_tab
;
	mov	esi,[ebp+16]	;esi = start position (one-biased)
	or	esi,esi		;start position is zero?
	jz	short rinchr_skip1 ;yes: set start position to end of string
	cmp	esi,edx		;start position is greater than LEN(x$)?
	jna	short rinchr_skip2 ;no: start position is ok
rinchr_skip1:
	mov	esi,edx		;start position is at end of string
rinchr_skip2:
	dec	esi		;esi = start offset

rinchr_search_loop:
	mov	al,[edi+esi]	;get next char from x$ into al
	xlatb			;look up al's element in search_tab
	or	al,al		;al != 0 iff al was in y$
	jnz	short rinchr_found ;if char is in y$, done
	dec	esi		;bump character counter
	jns	rinchr_search_loop
;
; re-zero table at search_tab (so next call to INCHR() works)
;
rinchr_rezero:
	mov	esi,[ebp+12]	;esi -> y$
	mov	ecx,[esi-8]	;ecx = number of chars in y$
rinchr_table_zero_loop:
	lodsb			;get next char from y$ into al
	mov	byte ptr [ebx+eax],0 ;zero char's element in table
	dec	ecx		;bump character counter
	jnz	rinchr_table_zero_loop

; free stack strings and exit

rinchr_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs ro be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

rinchr_found:
	inc	esi		;esi = current char position (one-biased)
	mov	[ebp-12],esi	;return value is current character position
	jmp	rinchr_rezero
;
;
; **************************
; *****  %_rinchri.vv  *****  RINCHRI(x$, y$, z)
; *****  %_rinchri.sv  *****
; *****  %_rinchri.vs  *****
; *****  %_rinchri.ss  *****
; **************************
;
; in:	arg2 = start position (one-biased) in x$ at which to begin search
;	arg1 -> y$: string containing set of characters to search for
;	arg0 -> x$: string in which to search
; out:	eax = position in x$
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; RINCHRI()'s search is case-insensitive, and proceeds backwards in x$ from
; the start position.  A start position of zero is treated the same as a
; start position of LEN(x$).  A start position greater than LEN(x$)
; is equivalent to a start position of LEN(x$).
;
; RINCHRI() builds a lookup table at search_tab, a 256-byte table in which
; each byte corresponds to one ASCII code.  All elements of the table
; are zero except those corresponding to upper- and lower-case versions
; of characters in y$.
;
; RINCHRI() never generates a run-time error.
;
%_rinchri.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinchri.x
;
%_rinchri.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short rinchri.x
;
%_rinchri.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinchri.x
;
%_rinchri.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
rinchri.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	rinchri_done	;yes: can't find anything in null string
	mov	edx,[edi-8]	;edx = LEN(x$)
	or	edx,edx		;length is zero?
	jz	rinchri_done	;yes: can't find anything in 0-length string

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short rinchri_done ;yes: null string can't contain matches
	mov	ecx,[esi-8]	;ecx = LEN(y$)
	or	ecx,ecx		;length is zero?
	jz	short rinchri_done ;yes: 0-length string can't contain matches
;
; build table at search_tab
;
	mov	edx,search_tab	;edx -> base of search table
	mov	ebx,%_uctolc	;ebx -> base of upper-to-lower conv. table
	mov	edi,%_lctouc	;edi -> base of lower-to-upper conv. table
	xor	eax,eax		;zero upper 24 bits of index into search_tab
rinchri_table_build_loop:
	lodsb			;get next char from y$ into al
	xlatb			;convert char to lower case
	mov	byte ptr [edx+eax],1 ;mark char's element in table
	mov	al,[edi+eax]	;convert char to upper case
	mov	byte ptr [edx+eax],1 ;mark char's element in table
	dec	ecx		;bump character counter
	jnz	rinchri_table_build_loop ;next character
;
; search x$ for any chars with non-zero element in search_tab
;
	mov	esi,[ebp+16]	;esi = start position (one-biased)
	mov	edi,[ebp+8]	;edi -> x$
	mov	edx,[edi-8]	;edx = LEN(x$)
	or	esi,esi		;start position is zero?
	jz	short rinchri_skip1 ;yes: set start position to end of string
	cmp	esi,edx		;start position is greater than LEN(x$)?
	jna	short rinchri_skip2 ;no: start position is ok
rinchri_skip1:
	mov	esi,edx		;start position is at end of string
rinchri_skip2:
	dec	esi		;esi = start offset
	mov	ebx,search_tab	;ebx -> base of y$ lookup table

rinchri_search_loop:
	mov	al,[edi+esi]	;get next char from x$ into al
	xlatb			;look up al's element in search_tab
	or	al,al		;al != 0 iff al was in y$
	jnz	short rinchri_found ;if char is in y$, done
	dec	esi		;bump character counter
	jns	rinchri_search_loop
;
; re-zero table at search_tab (so next call to INCHR() works)
;
rinchri_rezero:
	mov	esi,[ebp+12]	;esi -> y$
	mov	edx,search_tab	;edx -> base of search table
	mov	edi,%_lctouc	;edi -> base of lower-to-upper conv. table
	mov	ebx,%_uctolc	;ebx -> base of upper-to-lower conv. table
	mov	ecx,[esi-8]	;ecx = number of chars in y$
rinchri_table_zero_loop:
	lodsb			;get next char from y$ into al
	xlatb			;convert char to lower case
	mov	byte ptr [edx+eax],0 ;zero char's element in table
	mov	al,[edi+eax]	;convert char to upper case
	mov	byte ptr [edx+eax],0 ;zero char's element in table
	dec	ecx		;bump character counter
	jnz	rinchri_table_zero_loop

; free stack strings and exit

rinchri_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs ro be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

rinchri_found:
	inc	esi		;esi = current char position (one-biased)
	mov	[ebp-12],esi	;return value is current character position
	jmp	rinchri_rezero
;
;
; ************************
; *****  %_instr.vv  *****  INSTR(x$, y$, z)
; *****  %_instr.vs  *****
; *****  %_instr.sv  *****
; *****  %_instr.ss  *****
; ************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: substring to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; INSTR()'s search is case-sensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INSTR() returns 0.  If y$ is null or zero-length, INSTR()
; returns 0.
;
; INSTR() never generates a run-time error.
;
%_instr.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short instr.x
;
%_instr.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short instr.x
;
%_instr.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short instr.x
;
%_instr.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
instr.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12
;;
	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	short instr_done ;yes: can't find anything in null string
	mov	ecx,[edi-8]	;ecx = LEN(x$)
	jecxz	short instr_done ;same with zero-length string
	mov	eax,[ebp+16]	;eax = start position
	cmp	eax,ecx		;start position greater than length?
	ja	short instr_done ;yes: can't find anything beyond end of string
;;
	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short instr_done ;yes: can't find a null string
	mov	edx,[esi-8]	;edx = LEN(y$)
	or	edx,edx		;zero length?
	jz	short instr_done ;yes: can't find a zero-length string
	cmp	edx,ecx		;LEN(y$) > LEN(x$)?
	ja	short instr_done ;yes: can't find bigger string in smaller

; set up variables for loop

	dec	eax		;eax = start offset
	jns	instr_skip1	;wait!
	inc	eax		;if start position was zero, start search
instr_skip1:			; at beginning of string

	sub	ecx,edx		;ecx = LEN(x$) - LEN(y$) = last position
				; in x$ at which there's any point in starting
				; a comparison
	mov	ebx,ecx		;ebx = last position to check
	mov	edx,edi		;edx -> x$

; loop through x$, comparing with y$ at each position until match is found

instr_loop:
	cmp	eax,ebx		;past last position to check?
	ja	instr_done	;yes: no match

	lea	esi,[edx+eax]	;esi -> current position in x$
	mov	edi,[ebp+12]	;edi -> y$
	mov	ecx,[edi-8]	;ecx = LEN(y$)
	repz
	cmpsb			;compare y$ with substring of x$
	jz	short instr_found ;got a match

	inc	eax		;bump current-position counter
	jmp	instr_loop

; free stack strings and exit

instr_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs to be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

instr_found:
	inc	eax		;convert zero-biased position to one-biased
	mov	[ebp-12],eax	;save return value
	jmp	instr_done
;
;
; *************************
; *****  %_instri.vv  *****  INSTRI(x$, y$, z)
; *****  %_instri.vs  *****
; *****  %_instri.sv  *****
; *****  %_instri.ss  *****
; *************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: substring to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;	[ebp-16] = current offset in x$
;	[ebp-20] = last offset in x$ at which there's any point in starting
;		   a comparison with y$
;
; INSTRI()'s search is case-insensitive.  A start position of 0 is treated
; the same as a start position of 1.  If the start position is greater
; than LEN(x$), INSTRI() returns 0.  If y$ is null or zero-length, INSTRI()
; returns 0.
;
; INSTRI() never generates a run-time error.
;
%_instri.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short instri.x
;
%_instri.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short instri.x
;
%_instri.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short instri.x
;
%_instri.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
instri.x:
	push	ebp
	mov	ebp,esp
	sub	esp,20

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	short instri_done ;yes: can't find anything in null string
	mov	ecx,[edi-8]	;ecx = LEN(x$)
	jecxz	short instri_done ;same with zero-length string
	mov	eax,[ebp+16]	;eax = start position
	cmp	eax,ecx		;start position greater than length?
	ja	short instri_done ;yes: can't find anything beyond end of string

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short instri_done ;yes: can't find a null string
	mov	edx,[esi-8]	;edx = LEN(y$)
	or	edx,edx		;zero length?
	jz	short instri_done ;yes: can't find a zero-length string
	cmp	edx,ecx		;LEN(y$) > LEN(x$)?
	ja	short instri_done ;yes: can't find bigger string in smaller

; set up variables for loop

	dec	eax		;eax = start offset
	jns	instri_skip1	;wait!
	inc	eax		;if start position was zero, start search
instri_skip1:			; at beginning of string
	mov	[ebp-16],eax	;set current position variable to start offset

	sub	ecx,edx		;ecx = LEN(x$) - LEN(y$) = last position
				; in x$ at which there's any point in starting
				; a comparison
	mov	[ebp-20],ecx	;[ebp-20] = last position to check
	mov	edx,edi		;edx -> x$
	mov	ebx,%_lctouc	;ebx -> lower- to upper-case conversion table

; loop through x$, comparing with y$ at each position until match is found

instri_loop:
	cmp	eax,[ebp-20]	;past last position to check?
	ja	instri_done	;yes: no match

	lea	esi,[edx+eax]	;esi -> current position in x$
	mov	edi,[ebp+12]	;edi -> y$
	mov	ecx,[edi-8]	;ecx = LEN(y$)

instri_inner_loop:
	lodsb			;al = char from x$
	xlatb			;convert char from x$ to upper case
	xchg	ah,al		;upper-cased char from x$ to ah
	mov	al,[edi]	;al = char from y$
	xlatb			;convert char from y$ to upper case
	cmp	ah,al		;upper-cased chars from x$ and y$ identical?
	jne	short instri_nomatch ;no: try comparing at next char in x$

	inc	edi		;bump pointer into y$
	dec	ecx		;bump character counter
	jnz	instri_inner_loop ;test against next char in y$, if there
				  ; is one
	jmp	short instri_found ;there isn't one: we have a match

instri_nomatch:
	mov	eax,[ebp-16]
	inc	eax		;bump current-position counter
	mov	[ebp-16],eax
	jmp	instri_loop

; free stack strings and exit

instri_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs to be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

instri_found:
	mov	eax,[ebp-16]	;eax = current offset in x$
	inc	eax		;convert zero-biased position to one-biased
	mov	[ebp-12],eax	;save return value
	jmp	instri_done
;
;
; *************************
; *****  %_rinstr.vv  *****  RINSTR(x$, y$, z)
; *****  %_rinstr.vs  *****
; *****  %_rinstr.sv  *****
; *****  %_rinstr.ss  *****
; *************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: substring to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;
; RINSTR()'s search is case-sensitive.  A start position of 0 is treated
; the same as a start position of 1.  A start position greater
; than LEN(x$) is the same as LEN(x$).  If y$ is null or zero-length, RINSTR()
; returns 0.
;
; RINSTR() never generates a run-time error.
;
%_rinstr.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinstr.x
;
%_rinstr.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short rinstr.x
;
%_rinstr.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinstr.x
;
%_rinstr.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
rinstr.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	short rinstr_done ;yes: can't find anything in null string
	mov	ecx,[edi-8]	;ecx = LEN(x$)
	jecxz	short rinstr_done ;same with zero-length string
	mov	eax,[ebp+16]	;eax = start position

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short rinstr_done ;yes: can't find a null string
	mov	edx,[esi-8]	;edx = LEN(y$)
	or	edx,edx		;zero length?
	jz	short rinstr_done ;yes: can't find a zero-length string
	cmp	edx,ecx		;LEN(y$) > LEN(x$)?
	ja	short rinstr_done ;yes: can't find bigger string in smaller

; set up variables for loop

	sub	ecx,edx		;end of string = LEN(x$) - LEN(y$); must not
				; start a comparison beyond this point in x$
	inc	ecx		;make ecx one-biased

	or	eax,eax		;start offset is zero?
	jz	rinstr_skip2	;yes: default to end of string
	cmp	eax,ecx		;start offset is beyond end of string?
	jna	rinstr_skip1	;no: start offset is ok
rinstr_skip2:
	mov	eax,ecx		;eax = LEN(x$): start search at end of string
rinstr_skip1:
	mov	edx,edi		;edx -> x$
	mov	ebx,esi		;ebx -> y$

; loop through x$, comparing with y$ at each position until match is found

rinstr_loop:
	dec	eax		;bump position counter
	js	rinstr_done	;no match if past beginning of string

	lea	esi,[edx+eax]	;esi -> current position in x$
	mov	edi,ebx		;edi -> y$
	mov	ecx,[edi-8]	;ecx = LEN(y$)
	repz
	cmpsb			;compare y$ with substring of x$
	jz	short rinstr_found ;got a match

	jmp	rinstr_loop

; free stack strings and exit

rinstr_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs to be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

rinstr_found:
	inc	eax		;convert zero-biased position to one-biased
	mov	[ebp-12],eax	;save return value
	jmp	rinstr_done
;
;
; **************************
; *****  %_rinstri.vv  *****  RINSTRI(x$, y$, z)
; *****  %_rinstri.vs  *****
; *****  %_rinstri.sv  *****
; *****  %_rinstri.ss  *****
; **************************
;
; in:	arg2 = start position in x$ at which to begin search (one-biased)
;	arg1 -> y$: substring to search for
;	arg0 -> x$: string in which to search
; out:	eax = index (one-biased) of first char in y$ that was found in
;	      x$, or 0 if none were found
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
;	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
;	[ebp-12] = return value
;	[ebp-16] = current offset in x$
;
; RINSTRI()'s search is case-insensitive.  A start position of 0 is treated
; the same as a start position of LEN(x$).  A start position greater
; than LEN(x$)is the same as LEN(x$).  If y$ is null or zero-length, RINSTRI()
; returns 0.
;
; RINSTRI() never generates a run-time error.
;
%_rinstri.vv:
	xor	ebx,ebx		;don't free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinstri.x
;
%_rinstri.vs:
	xor	ebx,ebx		;don't free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
	jmp	short rinstri.x
;
%_rinstri.sv:
	mov	ebx,[esp+4]	;free x$ on exit
	xor	ecx,ecx		;don't free y$ on exit
	jmp	short rinstri.x
;
%_rinstri.ss:
	mov	ebx,[esp+4]	;free x$ on exit
	mov	ecx,[esp+8]	;free y$ on exit
;;
;; fall through
;;
rinstri.x:
	push	ebp
	mov	ebp,esp
	sub	esp,16

	mov	[ebp-4],ebx	;save ptr to 1st string to free on exit
	cld
	mov	[ebp-8],ecx	;save ptr to 2nd string to free on exit
	mov	[ebp-12],0	;return value is zero until proven otherwise

; rule out cases that don't require searching

	mov	edi,[ebp+8]	;edi -> x$
	or	edi,edi		;null pointer?
	jz	short rinstri_done ;yes: can't find anything in null string
	mov	ecx,[edi-8]	;ecx = LEN(x$)
	jecxz	short rinstri_done ;same with zero-length string
	mov	eax,[ebp+16]	;eax = start position

	mov	esi,[ebp+12]	;esi -> y$
	or	esi,esi		;null pointer?
	jz	short rinstri_done ;yes: can't find a null string
	mov	edx,[esi-8]	;edx = LEN(y$)
	or	edx,edx		;zero length?
	jz	short rinstri_done ;yes: can't find a zero-length string
	cmp	edx,ecx		;LEN(y$) > LEN(x$)?
	ja	short rinstri_done ;yes: can't find bigger string in smaller

; set up variables for loop

	sub	ecx,edx		;end of string = LEN(x$) - LEN(y$); must not
				; start a comparison beyond this point in x$
	inc	ecx		;make ecx one-biased

	or	eax,eax		;start position is zero?
	jz	rinstri_skip2	;yes: default to end of string
	cmp	eax,ecx		;start offset is beyond end of string?
	jna	rinstri_skip1	;no: start offset is ok
rinstri_skip2:
	mov	eax,ecx		;eax = LEN(x$): start search at end of string
rinstri_skip1:

	mov	edx,edi		;edx -> x$
	mov	ebx,%_lctouc	;ebx -> lower- to upper-case conversion table

; loop through x$, comparing with y$ at each position until match is found

	dec	eax		;past beginning of string?
	mov	[ebp-16],eax	;store current position into memory variable
rinstri_loop:
	js	rinstri_done	;yes: no match

	lea	esi,[edx+eax]	;esi -> current position in x$
	mov	edi,[ebp+12]	;edi -> y$
	mov	ecx,[edi-8]	;ecx = LEN(y$)

rinstri_inner_loop:
	lodsb			;al = char from x$
	xlatb			;convert char from x$ to upper case
	mov	ah,al		;ah = upper-cased char from x$
	mov	al,[edi]	;al = char from y$
	xlatb			;convert char from y$ to upper case
	cmp	ah,al		;upper-cased chars from x$ and y$ identical?
	jne	short rinstri_nomatch ;no: try comparing at next char in x$

	inc	edi		;bump pointer into y$
	dec	ecx		;bump character counter
	jnz	rinstri_inner_loop ;test against next char in y$, if there
				  ; is one
	jmp	short rinstri_found ;there isn't one: we have a match

rinstri_nomatch:
	mov	eax,[ebp-16]
	dec	eax		;bump current-position counter
	mov	[ebp-16],eax	;flags are tested at top of loop
	jmp	rinstri_loop

; free stack strings and exit

rinstri_done:
	mov	esi,[ebp-4]	;esi -> x$ if x$ needs to be freed
	call	%____free
	mov	esi,[ebp-8]	;esi -> y$ if y$ needs to be freed
	call	%____free

	mov	eax,[ebp-12]	;eax = return value
	mov	esp,ebp
	pop	ebp
	ret

rinstri_found:
	mov	eax,[ebp-16]	;eax = current offset in x$
	inc	eax		;convert zero-biased position to one-biased
	mov	[ebp-12],eax	;save return value
	jmp	rinstri_done
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
%_cv.string.to.sbyte.s:
	mov	ebx,[esp+4]
	mov	ecx,to_sbyte
	jmp	ns.convert.x
;
%_cv.string.to.sbyte.v:
	xor	ebx,ebx
	mov	ecx,to_sbyte
	jmp	ns.convert.x
;
%_cv.string.to.ubyte.s:
	mov	ebx,[esp+4]
	mov	ecx,to_ubyte
	jmp	ns.convert.x
;
%_cv.string.to.ubyte.v:
	xor	ebx,ebx
	mov	ecx,to_ubyte
	jmp	ns.convert.x
;
%_cv.string.to.sshort.s:
	mov	ebx,[esp+4]
	mov	ecx,to_sshort
	jmp	ns.convert.x
;
%_cv.string.to.sshort.v:
	xor	ebx,ebx
	mov	ecx,to_sshort
	jmp	ns.convert.x
;
%_cv.string.to.ushort.s:
	mov	ebx,[esp+4]
	mov	ecx,to_ushort
	jmp	ns.convert.x
;
%_cv.string.to.ushort.v:
	xor	ebx,ebx
	mov	ecx,to_ushort
	jmp	ns.convert.x
;
%_cv.string.to.slong.s:
	mov	ebx,[esp+4]
	mov	ecx,to_slong
	jmp	ns.convert.x
;
%_cv.string.to.slong.v:
	xor	ebx,ebx
	mov	ecx,to_slong
	jmp	ns.convert.x
;
%_cv.string.to.ulong.s:
	mov	ebx,[esp+4]
	mov	ecx,to_ulong
	jmp	ns.convert.x
;
%_cv.string.to.ulong.v:
	xor	ebx,ebx
	mov	ecx,to_ulong
	jmp	ns.convert.x
;
%_cv.string.to.xlong.s:
	mov	ebx,[esp+4]
	mov	ecx,to_xlong
	jmp	ns.convert.x
;
%_cv.string.to.xlong.v:
	xor	ebx,ebx
	mov	ecx,to_xlong
	jmp	ns.convert.x
;
%_cv.string.to.giant.s:
	mov	ebx,[esp+4]
	mov	ecx,to_giant
	jmp	ns.convert.x
;
%_cv.string.to.giant.v:
	xor	ebx,ebx
	mov	ecx,to_giant
	jmp	ns.convert.x
;
%_cv.string.to.single.s:
	mov	ebx,[esp+4]
	mov	ecx,to_single
	jmp	ns.convert.x
;
%_cv.string.to.single.v:
	xor	ebx,ebx
	mov	ecx,to_single
	jmp	ns.convert.x
;
%_cv.string.to.double.s:
	mov	ebx,[esp+4]
	mov	ecx,to_double
	jmp	ns.convert.x
;
%_cv.string.to.double.v:
	xor	ebx,ebx
	mov	ecx,to_double
	jmp	ns.convert.x
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
.text
;
; ######################
; #####  xlibsn.s  #####  intrinsics that take numbers and return strings
; ######################
;
; ***********************
; *****  %_space.d  *****  SPACE$(x)
; ***********************
;
; in:	arg0 = number of spaces
; out:	eax -> string containing requested number of spaces
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_space.d:
	push	ebp
	mov	ebp,esp

	push	[ebp+8]		;push number of spaces requested
	push	' '		;push space character
	call	%_chr.d		;eax -> result string
	add	esp,8

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *********************
; *****  %_chr.d  *****  CHR$(x, y)
; *********************
;
; in:	arg1 = number of times to duplicate it
;	arg0 = ASCII code to duplicate
; out:	eax -> generated string
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_chr.d:
	push	ebp
	mov	ebp,esp

	mov	esi,[ebp+12]	;esi = # of times to duplicate char
	or	esi,esi		;set flags
	jz	short chr_null	;if zero, just return null pointer
	js	short chr_IFC	;if less than zero, generate an error

	mov	ebx,[ebp+8]	;ebx = char to duplicate
	test	ebx,0xFFFFFF00	;greater than 255?
	jnz	short chr_IFC	;yes: generate error

	inc	esi		;esi = # of chars needed to hold string,
				; including null terminator
	call	%____calloc	;esi -> result string

	mov	ecx,[ebp+12]	;ecx = # of times to duplicate it
	mov	edi,esi		;edi -> result string
	mov	[esi-8],ecx	;store length of string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = system/user bit OR allocated-string info
	mov	[esi-4],eax	;store info word
	cld
	mov	al,[ebp+8]	;al = char to duplicate
	rep
	stosb			;write them character!
	mov	eax,esi		;eax -> result string
	mov	esp,ebp
	pop	ebp
	ret

chr_IFC:
	xor	eax,eax		;return null pointer
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return from there

chr_null:
	xor	eax,eax		;return null pointer
	mov	esp,ebp
	pop	ebp
	ret
;
;
; **********************
; *****  %_null.d  *****  NULL$(x)
; **********************
;
; in:	arg0 = number of nulls to put in result string
; out:	eax -> string containing requested number of nulls
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_null.d:
	push	ebp
	mov	ebp,esp

	mov	esi,[ebp+8]	;esi = # of times to duplicate char
	or	esi,esi		;set flags
	jz	short chr_null	;if zero, just return null pointer
	js	short chr_IFC	;if less than zero, generate an error

	inc	esi		;one more for null terminator, ha ha
	call	%____calloc	;esi -> result string

	mov	eax,[ebp+8]	;eax = requested number of nulls
	mov	[esi-8],eax	;write length of result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = system/user bit OR allocated-string info
	mov	[esi-4],eax	;write info word

	mov	eax,esi		;eax -> result string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_cstring.d  *****  CSTRING$(x$)
; *************************
;
; in:	arg0 -> string with no header info
; out:	eax -> copy of same string, with header info
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] = length of source string
;
; Result string's length is the number of non-null characters in the source
; string up to the first null.  Characters in the source string beyond the
; first null are not copied to the result string.
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_cstring.d:
	push	ebp
	mov	ebp,esp
	sub	esp,4
;
	mov	edi,[ebp+8]	;edi -> C string
	or	edi,edi		;null pointer?
	jz	short cstring_null ;yes: return null pointer
;
	movzx	eax, byte ptr [edi]	;first byte = 0x00 ???
	or	eax,eax		; test eax for zero
	jz	short cstring_null	; first byte = 0x00 = empty string
;
	mov	ecx,-1		;search until we find zero byte or cause memory fault
	xor	eax,eax		;search for a zero byte
	cld			;make sure we're going in the right direction
	repne
	scasb			;edi -> terminating null
;
	not	ecx		;ecx = length + 1
	mov	[ebp-4],ecx	;save it
	mov	esi,ecx		;esi = length + 1 = size of copy
	call	%____calloc	;esi -> result string, w/ enough space for copy
;
	mov	ecx,[ebp-4]	;ecx = length + 1
	lea	ebx,[ecx-1]	;ebx = length not including terminating null
	mov	[esi-8],ebx	;store length
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = system/user bit OR allocated-string info
	mov	[esi-4],eax	;write info word
;
	mov	eax,esi		;eax -> result string
	mov	esi,[ebp+8]	;esi -> source string
	mov	edi,eax		;edi -> result string
	rep
	movsb			;copy source string to result string
;
	mov	esp,ebp
	pop	ebp
	ret
;
cstring_null:
	xor	eax,eax		;return null pointer
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***********************
; *****  %_error.d  *****  error$ = ERROR$(errorNumber)
; ***********************
;
%_error.d:
	push	0			; arg = error$ (by reference)
	push	eax			; arg = error (error number)
	call	_XstErrorNumberToName@8	; error number to name
	mov	eax,[esp-4]		; error$
	ret
;
;
; ******************************
; *****  %_str.d.xlong     *****  STR$(x)
; *****  %_str.d.slong     *****
; *****  %_str.d.ulong     *****
; *****  %_str.d.goaddr    *****
; *****  %_str.d.subaddr   *****
; *****  %_str.d.funcaddr  *****
; ******************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_str.d.ulong:
	mov	esi,[esp+4]	;esi = number to convert to string
push_space_ulong_x:
	push	' '		;prefix must be space since ulong must be
call_ulong_x:			; positive
	push	esi		;push number to convert to string
	call	str.ulong.x
	add	esp,8
	ret
;
%_str.d.slong:
%_str.d.xlong:
%_str.d.goaddr:
%_str.d.subaddr:
%_str.d.funcaddr:
	mov	esi,[esp+4]	;esi = number to convert to string
	or	esi,esi		;is number positive?
	jns	short push_space_ulong_x ;yes: prefix it with a space
	push	'-'		;no: prefix it with a hyphen
	cmp	esi,0x80000000	;is number lowest possible negative number?
	je	short call_ulong_x ;yes: don't negate it
	neg	esi		;make it positive
	jmp	short call_ulong_x ;go convert it
;
;
; ****************************************************
; *****  %_string.xlong     %_string.d.xlong     *****
; *****  %_string.slong     %_string.d.slong     *****  STRING()  and  STRING$()
; *****  %_string.ulong     %_string.d.ulong     *****
; *****  %_string.goaddr    %_string.d.goaddr    *****
; *****  %_string.subaddr   %_string.d.subaddr   *****
; *****  %_string.funcaddr  %_string.d.funcaddr  *****
; ****************************************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_string.ulong:
%_string.d.ulong:
	mov	esi,[esp+4]	;esi = number to convert to string
push_null_ulong_x:
	push	'\0'		;prefix must be null since ulong must be
string_call_ulong_x:		; positive
	push	esi		;push number to convert
	call	str.ulong.x
	add	esp,8
	ret
;
%_string.slong:
%_string.xlong:
%_string.goaddr:
%_string.subaddr:
%_string.funcaddr:
%_string.d.slong:
%_string.d.xlong:
%_string.d.goaddr:
%_string.d.subaddr:
%_string.d.funcaddr:
	mov	esi,[esp+4]	;esi = number to convert to string
	or	esi,esi		;is number positive?
	jns	short push_null_ulong_x ;yes: no prefix
	push	'-'		;no: prefix it with a hyphen
	cmp	esi,0x80000000	;is number lowest possible negative number?
	je	short string_call_ulong_x ;yes: don't negate it
	neg	esi		;make it positive
	jmp	short string_call_ulong_x ;go convert it
;
;
; *********************************
; *****  %_signed.d.xlong     *****  SIGNED$ (xlong)
; *****  %_signed.d.slong     *****
; *****  %_signed.d.ulong     *****
; *****  %_signed.d.goaddr    *****
; *****  %_signed.d.subaddr   *****
; *****  %_signed.d.funcaddr  *****
; *********************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	plus sign is leading character if positive
;				hyphen is leading character if negative
;
; destroys: eax, ebx, ecx, edx, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_signed.d.ulong:
	mov	esi,[esp+4]	;esi = number to convert to string
push_plus_ulong_x:
	push	'+'		;prefix must be plus since ulong must be
signed_call_ulong_x:		; positive
	push	esi		;push number to convert
	call	str.ulong.x
	add	esp,8
	ret
;
%_signed.d.slong:
%_signed.d.xlong:
%_signed.d.goaddr:
%_signed.d.subaddr:
%_signed.d.funcaddr:
	mov	esi,[esp+4]	;esi = number to convert to string
	or	esi,esi		;is number positive?
	jns	short push_plus_ulong_x ;yes: prefix it with a plus sign
	push	'-'		;no: prefix it with a hyphen
	cmp	esi,0x80000000	;is number lowest possible negative number?
	je	short signed_call_ulong_x ;yes: don't negate it
	neg	esi		;make it positive
	jmp	short signed_call_ulong_x ;go convert it
;
;
; *************************
; *****  str.ulong.x  *****  converts a positive number to a string
; *************************  internal common entry point
;
; in:	arg1 = prefix character, or 0 if no prefix
;	arg0 = number to convert to string
; out:	eax -> result string (prefix character is prepended to result string)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> result string
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
str.ulong.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	esi,15		;get room for at least 15 bytes to hold result
	call	%_____calloc	;esi -> header of result string
	add	esi,16		;esi -> result string
	mov	[ebp-4],esi	;save it
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;info word indicates: allocated string
	mov	[esi-4],eax	;store info word

	mov	eax,[ebp+12]	;eax = prefix character
	or	eax,eax		;a null?
	jz	short ulong_no_prefix ;yes: don't prepend a prefix
	mov	[esi],al	;no: store it
	inc	esi		;esi -> character after prefix character

ulong_no_prefix:
	mov	eax,[ebp+8]	;eax = number to convert
	or	eax,eax		;just converting a zero?
	jz	short ulong_zero ;yes: skip time-consuming loop
	xor	ebx,ebx		;ebx = offset into ulong_table = 0
	xor	edi,edi		;edi = # of digits generated so far = 0
	mov	ecx,[ulong_table+ebx*4] ;ecx = current positional value
	mov	edx,eax		;edx = what's left of current number =
				; current number if first digit is a zero
ulong_digit_loop:
	cmp	eax,ecx		;zero at this digit?
	jb	short ulong_zero_digit ;yes: skip division
	xor	edx,edx		;clear upper 32 bits of dividend
	div	ecx		;eax = digit, edx = remainder = what's left
				; of current number
ulong_write_digit:
	add	al,'0'		;convert digit to ASCII
	mov	[esi+edi],al	;write current digit
	inc	edi		;increment number of digits generated so far

ulong_next_digit:
	inc	ebx		;increment offset into ulong_table
	mov	eax,edx		;eax = what's left of number
	mov	ecx,[ulong_table+ebx*4] ;ecx = current positional value
	or	ecx,ecx		;reached end of table (last digit)?
	jnz	ulong_digit_loop ;no: do another digit

ulong_done:
	mov	byte ptr [esi+edi],0 ;add null terminator
	mov	eax,[ebp-4]	;eax -> start of result string
	lea	ebx,[esi+edi]	;ebx -> null terminator
	sub	ebx,eax		;ebx = true length of string
	mov	[eax-8],ebx	;store length of result string

	mov	esp,ebp
	pop	ebp
	ret

ulong_zero_digit:
	or	edi,edi		;is current digit a leading zero?
	jz	ulong_next_digit ;yes: skip it
	xor	eax,eax		;force current digit to zero
	jmp	ulong_write_digit

ulong_zero:			;result string is "0"
	mov	byte ptr [esi],'0' ;store the zero digit
	mov	edi,1		;edi = length of string, not counting prefix
	jmp	ulong_done
;
;
; **********************
; *****  %_binb.d  *****  converts a ULONG to its binary representation
; **********************  and prepends "0b" to it
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_binb.d:
	push	ebp
	lea	ebp,[esp-4]
	sub	esp,16

	mov	[ebp-8],0x6230	;tell cvt32 to prepend "0b"
	mov	[ebp-12],bin.dword ;convert into binary digits
	call	cvt32		;eax -> result string

	cmp	[eax-8],2	;length = 2?  I.e. string is nothing but "0b"?
	jne	short binb_d_done ;no: done
	mov	byte ptr [eax+2],'0' ;append "0"
	mov	[eax-8],3	;length = 3

binb_d_done:
	lea	esp,[ebp+4]
	pop	ebp
	ret
;
;
; *********************
; *****  %_bin.d  *****  converts a ULONG to its binary representation
; *********************
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_bin.d:
	push	ebp
	lea	ebp,[esp-4]
	sub	esp,16

	mov	[ebp-8],0	;tell cvt32 to not prepend anything
	mov	[ebp-12],bin.dword ;convert into binary digits
	call	cvt32		;eax -> result string

	cmp	[eax-8],0	;zero-length string?
	jnz	short bin_d_done ;no: done
	mov	byte ptr [eax],'0' ;create a "0" string
	mov	[eax-8],1	;length is 1

bin_d_done:
	lea	esp,[ebp+4]
	pop	ebp
	ret
;
;
; **********************
; *****  %_octo.d  *****  converts a ULONG to its octal representation
; **********************  and prepends "0o" to it
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing octal digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_octo.d:
	push	ebp
	lea	ebp,[esp-4]
	sub	esp,16

	mov	[ebp-8],0x6F30	;tell cvt32 to prepend "0o"
	mov	[ebp-12],oct.dword ;convert into octal digits
	mov	[oct_shift],oct_lsd_64 ;we're only converting one dword
	mov	[oct_first],0	;no extra bit to OR into first digit
	call	cvt32		;eax -> result string

	cmp	[eax-8],2	;length = 2?  I.e. string is nothing but "0o"?
	jne	short octo_d_done ;no: done
	mov	byte ptr [eax+2],'0' ;append "0"
	mov	[eax-8],3	;length = 3

octo_d_done:
	lea	esp,[ebp+4]
	pop	ebp
	ret
;
;
; *********************
; *****  %_oct.d  *****  converts a ULONG to its octal representation
; *********************
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing octal digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_oct.d:
	push	ebp
	lea	ebp,[esp-4]
	sub	esp,16

	mov	[ebp-8],0	;tell cvt32 to not prepend anything
	mov	[ebp-12],oct.dword ;convert into octal digits
	mov	[oct_shift],oct_lsd_64 ;we're only converting one dword
	mov	[oct_first],0	;no extra bit to OR into first digit
	call	cvt32		;eax -> result string

	cmp	[eax-8],0	;zero-length string?
	jnz	short oct_d_done ;no: done
	mov	byte ptr [eax],'0' ;create a "0" string
	mov	[eax-8],1	;length is 1

oct_d_done:
	lea	esp,[ebp+4]
	pop	ebp
	ret
;
;
; **********************
; *****  %_hexx.d  *****  converts a ULONG to its hexadecimal representation
; **********************  and prepends "0x" to it
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing hex digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_hexx.d:
	push	ebp
	lea	ebp,[esp-4]
	sub	esp,16

	mov	[ebp-8],0x7830	;tell cvt32 to prepend "0x"
	mov	[ebp-12],hex.dword ;convert into hex digits
	call	cvt32		;eax -> result string

	cmp	[eax-8],2	;length = 2?  I.e. string is nothing but "0x"?
	jne	short hexx_d_done ;no: done
	mov	byte ptr [eax+2],'0' ;append "0"
	mov	[eax-8],3	;length = 3

hexx_d_done:
	lea	esp,[ebp+4]
	pop	ebp
	ret
;
;
; *********************
; *****  %_hex.d  *****  converts a ULONG to its hexadecimal representation
; *********************
;
; in:	arg1 = minimum number of digits
;	arg0 = value to convert
; out:	eax -> string containing hex digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_hex.d:
	push	ebp
	lea	ebp,[esp-4]
	sub	esp,16

	mov	[ebp-8],0	;tell cvt32 to not prepend anything
	mov	[ebp-12],hex.dword ;convert into hex digits
	call	cvt32		;eax -> result string

	cmp	[eax-8],0	;zero-length string?
	jnz	short hex_d_done ;no: done
	mov	byte ptr [eax],'0' ;create a "0" string
	mov	[eax-8],1	;length is 1

hex_d_done:
	lea	esp,[ebp+4]
	pop	ebp
	ret
;
; *******************
; *****  cvt32  *****  converts a ULONG to hex, binary, or octal
; *******************  internal common entry point
;
; in:	arg2 = minimum number of digits
;	arg1 = number to convert
;	arg0 is ignored
;	[ebp-8] = two-byte string to prepend: 0x7830 = "0x"
;					      0x6F30 = "0o"
;					      0x6230 = "0b"
;					      0      = prepend nothing
;	[ebp-12] -> subroutine to call to generate digits (hex.dword,
;		    bin.dword, or oct.dword)
;
; out:	eax -> string containing ASCII representation of number
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to return
;	[ebp-8] = two-byte string to prepend or zero to prepend nothing
;	[ebp-12] -> subroutine to call to generate digits (hex.dword,
;		    bin.dword, or oct.dword)
;
; IMPORTANT: cvt32 assumes that its local stack frame has already been
; set up, but it frees the stack frame itself before exiting.  This permits
; cvt32's caller to set up [ebp-8] on entry, and then to simply jump
; to cvt32 rather than call, ax the local frame, and return.
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
; If value to convert is zero, nothing (except the prepended string)
; will be stored in the result string: i.e. no "0" will be written.
;
cvt32:
	mov	esi,70		;get 70 bytes for string (more than necessary)
	call	%____calloc	;esi -> string that will contain result
	mov	[ebp-4],esi	;save it
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	cld
	or	eax,0x80130001	;info word indicates: allocated string
	mov	[esi-4],eax	;store info word

	mov	edi,esi		;edi -> result string
	mov	eax,[ebp-8]	;eax = string to prepend
	or	eax,eax		;nothing to prepend?
	jz	short cvt32_convert ;yes
	stosw			;no: write prefix at beginning of string

cvt32_convert:
	mov	edx,[ebp+12]	;edx = value to convert
	mov	esi,[ebp+16]	;esi = minimum number of digits to output
	call	[ebp-12]	;generate ASCII representation of edx
				;edi -> char after last char
cvt32_exit:
	mov	eax,[ebp-4]	;eax -> result string
	sub	edi,eax		;edi = length of result string
	mov	[eax-8],edi	;store length of result string
	ret
;
; ***********************
; *****  hex.dword  *****  converts a dword to hexadecimal representation
; ***********************  internal entry point
;
; in:	esi = minimum number of digits to output
;	edx = value to output
;	edi -> output buffer
; out:	edi -> char after last char output by hex.dword
;
; destroys: eax, ebx, ecx, edx, esi
;
; Output buffer is assumed to have enough space to hold all digits generated.
; Output string will contain more than esi characters if edx cannot
; be represented in esi characters.  If minimum number of digits is zero
; and the value to output is zero, no output will be generated.  No
; terminating null is appended to the output string.
;
hex.dword:
	mov	ebx,hex_digits	;ebx -> table of ASCII characters
	mov	ecx,8		;ecx = current digit
	cld
hd_loop_top:
	xor	eax,eax
	shld	eax,edx,4	;shift next digit into al
	sll	edx,4		;shld should have done this
	cmp	ecx,esi		;into range of mandatory digits? (i.e. print
				; even if zero?)
	jbe	short hd_output	;yes: print current char
	or	al,al		;a non-zero digit before mandatory digits?
	jz	short hd_loop_end ;no: skip this digit
	mov	esi,127		;yes: force all digits from here to print
hd_output:
	xlatb			;al = ASCII representation of digit
	stosb			;put digit into buffer
hd_loop_end:
	dec	ecx		;bump digit counter
	jnz	hd_loop_top	;keep going if haven't reached last digit
	ret
;
;
; ***********************
; *****  bin.dword  *****  converts a dword to binary representation
; ***********************  internal entry point
;
; in:	esi = minimum number of digits to output
;	edx = value to output
;	edi -> output buffer
; out:	edi -> char after last char output by bin.dword
;
; destroys: eax, ebx, ecx, edx, esi
;
; Output buffer is assumed to have enough space to hold all digits generated.
; Output string will contain more than esi characters if edx cannot
; be represented in esi characters.  If minimum number of digits is zero
; and the value to output is zero, no output will be generated.  No
; terminating null is appended to the output string.
;
bin.dword:
	mov	ebx,hex_digits	;ebx -> table of ASCII characters
	mov	ecx,32		;ecx = current digit = 32
	cld
bd_loop_top:
	xor	eax,eax
	sll	edx,1		;move next digit (next bit, that is) into CF
	rcl	eax,1		;eax contains next digit
	cmp	ecx,esi		;into range of mandatory digits? (i.e. print
				; even if zero?)
	jbe	short bd_output	;yes: print current char
	or	al,al		;a non-zero digit before mandatory digits?
	jz	short bd_loop_end ;no: skip this digit
	mov	esi,127		;yes: force all digits from here to print
bd_output:
	xlatb			;al = ASCII representation of digit
	stosb			;put digit into buffer
bd_loop_end:
	dec	ecx		;bump digit counter
	jnz	bd_loop_top	;keep going if haven't reached last digit
	ret
;
;
; ***********************
; *****  oct.dword  *****  converts a dword to octal representation
; ***********************  internal entry point
;
; in:	esi = minimum number of digits to output
;	edx = value to output
;	edi -> output buffer
;	[oct_shift] -> table of shift values
;	[oct_first] = value to add to first digit
; out:	edi -> char after last char output by oct.dword
;	[oct_first] = value of last digit, if last digit's shift value was 1
;	need some way to indicate that msd was non-zero
;
; destroys: eax, ebx, ecx, edx, esi
;
; local variables:
;	[ebp-4] = current digit (counts down)
;	[ebp-8] = current digit (counts up)
;
; Output buffer is assumed to have enough space to hold all digits generated.
; Output string will contain more than esi characters if edx cannot
; be represented in esi characters.  If minimum number of digits is zero
; and the value to output is zero, no output will be generated.  No
; terminating null is appended to the output string.
;
; On entry, [oct_shift] must point to either oct_msd_64 or oct_lsd_64
; according to whether oct.dword is being called on the most significant
; or least significant dword of a 64-bit number.  [oct_first] must
; equal zero when printing the msdw of a 64-bit number, and the value of
; the last bit of the msdw when printing the lsd.  On exit, when printing
; an msd, oct.dword sets [oct_first] to the value of the last bit, and
; does not generate a digit for this bit.  Oh, the complications of
; printing octal numbers...
;
oct.dword:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov	ebx,hex_digits	;ebx -> table of ASCII characters
	mov	[ebp-4],11	;current digit (counting down) = 11
	cld
	xor	ecx,ecx		;ecx = current digit (counting up) = 0
	mov	[ebp-8],ecx	;save it
od_loop_top:
	mov	eax,[oct_shift]	;eax -> shift table
	mov	cl,[eax+ecx]	;cl = # of bits to shift for next digit
	or	cl,cl		;zero?
	jz	od_exit		;yes: we're done

	xor	eax,eax
	shld	eax,edx,cl	;shift bits for next digit into eax
	sll	edx,cl		;remove same bits from edx

	cmp	cl,1		;shifted only one bit?
	jne	short od_not_odd_bit ;no: it's a normal digit
	cmp	[ebp-8],0	;first digit?
	jne	short od_odd_bit ;no: it's that irritating bit at the end
				 ; of the first dword of a qword
od_not_odd_bit:
	cmp	[ebp-8],0	;first digit?
	jne	short od_not_first_digit
	or	eax,[oct_first]	;yes: OR in last bit from previous dword

od_not_first_digit:
	cmp	[ebp-4],esi	;into range of mandatory digits? (i.e. print
				; even if zero?)
	jbe	short od_output	;yes: print current char
	or	al,al		;a non-zero digit before mandatory digits?
	jz	short od_loop_end ;no: skip this digit
	mov	esi,127		;yes: force all digits from here to print
od_output:
	xlatb			;al = ASCII representation of digit
	stosb			;put digit into buffer
od_loop_end:
	dec	[ebp-4]		;bump falling digit counter
	inc	[ebp-8]		;bump rising digit counter
	mov	ecx,[ebp-8]	;ecx = rising digit counter
	jmp	short od_loop_top ;go convert next digit, if any

od_exit:
	mov	[oct_first],0	;no extra bit for next time if we got here
	mov	esp,ebp
	pop	ebp
	ret
				;we're on irritating last bit of 1st dword
od_odd_bit:			; of a 64-bit number
	sll	eax,2		;shift bit to where it attaches to next
				; 3-bit group
	mov	[oct_first],eax	;save bit for next time
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***************************
; *****  %_hex.d.giant  *****  converts a giant to hexadecimal string
; ***************************
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing hex digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_hex.d.giant:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-8],0	;tell cvt32 to not prepend anything
	mov	[ebp-12],hex.dword ;convert into hex digits
	mov	eax,[ebp+16]	;eax = requested number of digits
	mov	[sn_save],eax	;save eax someplace safe
	mov	[ebp+16],0	;print nothing if asked for <= 8 digits
	cmp	eax,8		;requested more than 8 digits?
	jbe	short hexg_msdword ;no: no change
	sub	eax,8		;yes: indicate # of digits in ms dword
	mov	[ebp+16],eax
hexg_msdword:
	call	cvt32		;convert most significant dword
				;eax -> result string
	mov	ebx,[eax-8]	;ebx = length of string so far
	lea	edi,[eax+ebx]	;edi -> where to place second dword's digits
	mov	esi,[sn_save]	;esi = minimum number of digits
	mov	edx,[ebp+8]	;edx = least significant dword
	mov	[sn_save],eax	;save eax someplace safe
	or	ebx,ebx		;anything written to string?
	jz	hexg_lsdword ;no: skip
	mov	esi,127		;yes: do not suppress leading zeros

hexg_lsdword:
	call	hex.dword	;append second dword's hex digits to first's
	mov	eax,[sn_save]	;eax -> result string
	sub	edi,eax		;edi = total length of string
	jnz	hexg_done	;if length is non-zero, done
	mov	[eax],'0'	;generate a "0" string
	inc	edi		;length = 1

hexg_done:
	mov	[eax-8],edi	;write length of string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ****************************
; *****  %_hexx.d.giant  *****  converts a giant to hexadecimal string
; ****************************  and prepend "0x"
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing hex digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_hexx.d.giant:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-8],0x7830	;tell cvt32 to prepend "0x"
	mov	[ebp-12],hex.dword ;convert into hex digits
	mov	eax,[ebp+16]	;eax = requested number of digits
	mov	[sn_save],eax	;save eax someplace safe
	mov	[ebp+16],0	;print nothing if asked for <= 8 digits
	cmp	eax,8		;requested more than 8 digits?
	jbe	short hexxg_msdword ;no: no change
	sub	eax,8		;yes: indicate # of digits in ms dword
	mov	[ebp+16],eax
hexxg_msdword:
	call	cvt32		;convert most significant dword
				;eax -> result string
	mov	ebx,[eax-8]	;ebx = length of string so far
	lea	edi,[eax+ebx]	;edi -> where to place second dword's digits
	mov	esi,[sn_save]	;esi = minimum number of digits
	mov	edx,[ebp+8]	;edx = least significant dword
	mov	[sn_save],eax	;save eax someplace safe
	cmp	ebx,2		;any digits written to string?
	jz	hexxg_lsdword ;no: skip
	mov	esi,127		;yes: do not suppress leading zeros

hexxg_lsdword:
	call	hex.dword	;append second dword's hex digits to first's
	mov	eax,[sn_save]	;eax -> result string
	sub	edi,eax		;edi = total length of string
	cmp	edi,2		;any digits written to string?
	jnz	hexxg_done 	;if length is non-zero, done
	mov	[eax+2],'0'	;generate a "0" string
	inc	edi		;length = 3

hexxg_done:
	mov	[eax-8],edi	;write length of string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***************************
; *****  %_bin.d.giant  *****  converts a giant to binary string
; ***************************
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_bin.d.giant:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-8],0	;tell cvt32 to not prepend anything
	mov	[ebp-12],bin.dword ;convert into binary digits
	mov	eax,[ebp+16]	;eax = requested number of digits
	mov	[sn_save],eax	;save eax someplace safe
	mov	[ebp+16],0	;print nothing if asked for <= 32 digits
	cmp	eax,32		;requested more than 32 digits?
	jbe	short bing_msdword ;no: no change
	sub	eax,32		;yes: indicate # of digits in ms dword
	mov	[ebp+16],eax
bing_msdword:
	call	cvt32		;convert most significant dword
				;eax -> result string
	mov	ebx,[eax-8]	;ebx = length of string so far
	lea	edi,[eax+ebx]	;edi -> where to place second dword's digits
	mov	esi,[sn_save]	;esi = minimum number of digits
	mov	edx,[ebp+8]	;edx = least significant dword
	mov	[sn_save],eax	;save eax someplace safe
	or	ebx,ebx		;anything written to string?
	jz	bing_lsdword ;no: skip
	mov	esi,127		;yes: do not suppress leading zeros

bing_lsdword:
	call	bin.dword	;append second dword's binary digits to first's
	mov	eax,[sn_save]	;eax -> result string
	sub	edi,eax		;edi = total length of string
	jnz	bing_done	;if length is non-zero, done
	mov	[eax],'0'	;generate a "0" string
	inc	edi		;length = 1

bing_done:
	mov	[eax-8],edi	;write length of string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ****************************
; *****  %_binb.d.giant  *****  converts a giant to binary string
; ****************************  and prepend "0x"
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing binary digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_binb.d.giant:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-8],0x6230	;tell cvt32 to prepend "0b"
	mov	[ebp-12],bin.dword ;convert into binary digits
	mov	eax,[ebp+16]	;eax = requested number of digits
	mov	[sn_save],eax	;save eax someplace safe
	mov	[ebp+16],0	;print nothing if asked for <= 32 digits
	cmp	eax,32		;requested more than 32 digits?
	jbe	short binbg_msdword ;no: no change
	sub	eax,32		;yes: indicate # of digits in ms dword
	mov	[ebp+16],eax
binbg_msdword:
	call	cvt32		;convert most significant dword
				;eax -> result string
	mov	ebx,[eax-8]	;ebx = length of string so far
	lea	edi,[eax+ebx]	;edi -> where to place second dword's digits
	mov	esi,[sn_save]	;esi = minimum number of digits
	mov	edx,[ebp+8]	;edx = least significant dword
	mov	[sn_save],eax	;save eax someplace safe
	cmp	ebx,2		;any digits written to string?
	jz	binbg_lsdword ;no: skip
	mov	esi,127		;yes: do not suppress leading zeros

binbg_lsdword:
	call	bin.dword	;append second dword's binary digits to first's
	mov	eax,[sn_save]	;eax -> result string
	sub	edi,eax		;edi = total length of string
	cmp	edi,2		;any digits written to string?
	jnz	binbg_done 	;if length is non-zero, done
	mov	[eax+2],'0'	;generate a "0" string
	inc	edi		;length = 3

binbg_done:
	mov	[eax-8],edi	;write length of string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***************************
; *****  %_oct.d.giant  *****  converts a giant to octal string
; ***************************
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing octal digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_oct.d.giant:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[oct_first],0	;no carry-over bit in first dword
	mov	[oct_shift],oct_msd_64 ;shift table for ms dword
	mov	[ebp-8],0	;tell cvt32 to not prepend anything
	mov	[ebp-12],oct.dword ;convert into octal digits
	mov	eax,[ebp+16]	;eax = requested number of digits
	mov	[sn_save],eax	;save eax someplace safe
	mov	[ebp+16],0	;print nothing if asked for <= 11 digits
	cmp	eax,11		;requested more than 11 digits?
	jbe	short octg_msdword ;no: no change
	sub	eax,11		;yes: indicate # of digits in ms dword
	mov	[ebp+16],eax
octg_msdword:
	call	cvt32		;convert most significant dword
				;eax -> result string
	mov	ebx,[eax-8]	;ebx = length of string so far
	lea	edi,[eax+ebx]	;edi -> where to place second dword's digits
	mov	esi,[sn_save]	;esi = minimum number of digits
	mov	edx,[ebp+8]	;edx = least significant dword
	mov	[sn_save],eax	;save eax someplace safe
	or	ebx,ebx		;anything written to string?
	jz	octg_lsdword ;no: skip
	mov	esi,127		;yes: do not suppress leading zeros

octg_lsdword:
	mov	[oct_shift],oct_lsd_64 ;shift table for ls dword
	call	oct.dword	;append second dword's octal digits to first's
	mov	eax,[sn_save]	;eax -> result string
	sub	edi,eax		;edi = total length of string
	jnz	octg_done	;if length is non-zero, done
	mov	[eax],'0'	;generate a "0" string
	inc	edi		;length = 1

octg_done:
	mov	[eax-8],edi	;write length of string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ****************************
; *****  %_octo.d.giant  *****  converts a giant to octal string
; ****************************  and prepend "0x"
;
; in:	arg2 = minimum number of digits
;	arg1 = most significant dword of number to convert
;	arg0 = least significant dword of number to convert
; out:	eax -> string containing octal digits
;
; destroys: ebx, ecx, edx, esi, edi
;
%_octo.d.giant:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[oct_first],0	;no carry-over bit in first dword
	mov	[oct_shift],oct_msd_64 ;shift table for ms dword
	mov	[ebp-8],0x6F30	;tell cvt32 to prepend "0o"
	mov	[ebp-12],oct.dword ;convert into oct digits
	mov	eax,[ebp+16]	;eax = requested number of digits
	mov	[sn_save],eax	;save eax someplace safe
	mov	[ebp+16],0	;print nothing if asked for <= 11 digits
	cmp	eax,11		;requested more than 11 digits?
	jbe	short octog_msdword ;no: no change
	sub	eax,11		;yes: indicate # of digits in ms dword
	mov	[ebp+16],eax
octog_msdword:
	call	cvt32		;convert most significant dword
				;eax -> result string
	mov	ebx,[eax-8]	;ebx = length of string so far
	lea	edi,[eax+ebx]	;edi -> where to place second dword's digits
	mov	esi,[sn_save]	;esi = minimum number of digits
	mov	edx,[ebp+8]	;edx = least significant dword
	mov	[sn_save],eax	;save eax someplace safe
	cmp	ebx,2		;any digits written to string?
	jz	octog_lsdword ;no: skip
	mov	esi,127		;yes: do not suppress leading zeros

octog_lsdword:
	mov	[oct_shift],oct_lsd_64 ;shift table for ls dword
	call	oct.dword	;append second dword's octal digits to first's
	mov	eax,[sn_save]	;eax -> result string
	sub	edi,eax		;edi = total length of string
	cmp	edi,2		;any digits written to string?
	jnz	octog_done 	;if length is non-zero, done
	mov	[eax+2],'0'	;generate a "0" string
	inc	edi		;length = 3

octog_done:
	mov	[eax-8],edi	;write length of string
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***************************
; *****  %_str.d.giant  *****  STR$(giant)
; ***************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_str.d.giant:
	push	ebp
	mov	ebp,esp

	mov	eax,'-'		;prefix with hyphen if negative
	mov	ebx,[ebp+12]	;ebx = most significant dword
	or	ebx,ebx		;negative?
	js	short str_giant_cvt ;yes: leave prefix character alone
	mov	eax,' '		;prefix with space if positive or zero

str_giant_cvt:
	push	eax		;push prefix character
	push	ebx		;push most significant dword
	push	[ebp+8]		;push least significant dword
	call	giant.decimal	;convert to decimal string

	mov	esp,ebp
	pop	ebp
	ret
;
;
; ****************************
; *****  %_string.giant  *****  STRING(giant)  and  STRING$(giant)
; ****************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_string.giant:
%_string.d.giant:
	push	ebp
	mov	ebp,esp

	mov	eax,'-'		;prefix with hyphen if negative
	mov	ebx,[ebp+12]	;ebx = most significant dword
	or	ebx,ebx		;negative?
	js	short string_giant_cvt ;yes: leave prefix character alone
	sub	eax,'-'		;prefix with nothing if positive or zero

string_giant_cvt:
	push	eax		;push prefix character
	push	ebx		;push most significant dword
	push	[ebp+8]		;push least significant dword
	call	giant.decimal	;convert to decimal string

	mov	esp,ebp
	pop	ebp
	ret
;
;
; ******************************
; *****  %_signed.d.giant  *****  SIGNED$(giant)
; ******************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	plus sign is leading character if positive
;				hyphen is leading character if negative
;
; destroys: eax, ebx, ecx, edx, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_signed.d.giant:
	push	ebp
	mov	ebp,esp

	mov	eax,'-'		;prefix with hyphen if negative
	mov	ebx,[ebp+12]	;ebx = most significant dword
	or	ebx,ebx		;negative?
	js	short signed_giant_cvt ;yes: leave prefix character alone
	mov	eax,'+'		;prefix with plus sign if positive or zero

signed_giant_cvt:
	push	eax		;push prefix character
	push	ebx		;push most significant dword
	push	[ebp+8]		;push least significant dword
	call	giant.decimal	;convert to decimal string

	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***************************
; *****  giant.decimal  *****  converts positive GIANT to decimal string
; ***************************
;
; in:	arg2 = prefix character, or 0 if no prefix
;	arg1:arg0 = number to convert to string
; out:	eax -> result string (prefix character is prepended to result string)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> result string
;	[ebp-8] = pointer to next char in result string
;	[ebp-12] = leading-zero flag: != 0 if at least one digit has been
;		   printed
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
giant.decimal:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	esi,30		;get room for at least 30 bytes to hold result
	call	%_____calloc	;esi -> header of result string
	add	esi,16		;esi -> result string
	mov	[ebp-4],esi	;save it
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;info word indicates: allocated string
	mov	[esi-4],eax	;store info word

	mov	edi,esi		;edi -> result string
	mov	eax,[ebp+16]	;eax = prefix character
	or	eax,eax		;a null?
	jz	short gd_make_abs ;yes: don't prepend a prefix
	stosb			;no: store it

gd_make_abs:			;make absolute-value copy of number to convert
	mov	edx,[ebp+12]	;edx = ms dword of number to convert
	mov	eax,[ebp+8]	;eax = ls dword of number to convert
	or	edx,edx		;negative?
	jns	short gd_not_negative ;no: don't negate it
	or	eax,eax		;but don't negate 0x8000000000000000
	jnz	short gd_negate
	cmp	edx,0x80000000
	je	gd_not_negative
gd_negate:
	not	edx
	neg	eax
	sbb	edx,-1		;edx:eax = ABS(original number)

gd_not_negative:
	or	edx,edx		;ms dword is zero?
	jnz	short gd_ms_not_zero ;no: have to do some honest work
	cmp	eax,edx		;yes: is ls half zero, too?
	jz	gd_zero		;yes: just make a "0" string

gd_ls_not_zero:
	bsr	ecx,eax		;find highest one bit in ls half of giant
	jmp	short gd_go

gd_ms_not_zero:
	bsr	ecx,edx		;find highest one bit in ms half of giant
	add	ecx,32		;eax is index into gd_start_digits

gd_go:
	mov	[ebp-12],0	;clear leading-zero flag (ecx from now on)
	movzx	ecx,byte ptr [gd_start_digits+ecx] ;ecx = index into gd_table
					   ; of 1st power of ten to divide by
	lea	esi,[gd_table+ecx*8] ;esi -> 1st power of ten
	mov	[ebp-8],edi	;save pointer to next char in result string

gd_digit_loop:
	xor	edi,edi		;current digit = 0
	mov	ebx,[esi]
	mov	ecx,[esi+4]	;ecx:ebx = current power of ten

				;in the following comments, n = what's
				; left of the current number to convert,
				; and p10 = the current power of ten
gd_subtract_loop:
	cmp	edx,ecx		;compare most significant halves: n - p10
	jb	short gd_got_digit ;n < p10: current digit is correct
	ja	short gd_next_subtract ;n > p10: keep subtracting
	cmp	eax,ebx		;compare least significant halves: n - p10
	jb	short gd_got_digit ;n < 10: current digit is correct

gd_next_subtract:
	sub	eax,ebx
	sbb	edx,ecx		;n -= p10
	inc	edi		;bump digit counter
	jmp	gd_subtract_loop

gd_got_digit:
	or	edi,edi		;digit is zero?
	jnz	short gd_output_digit ;no: output it unconditionally
	cmp	[ebp-12],0	;has anything been output yet?
	jz	short gd_next_digit ;no: this is a leading zero, so skip it

gd_output_digit:
	mov	ebx,[ebp-8]	;ebx -> next char of result string
	lea	ecx,[edi+'0']	;convert digit to ASCII
	mov	[ebx],cl	;write digit to result string
	inc	ebx		;bump pointer into result string
	mov	[ebp-8],ebx	;save pointer into result string
	mov	[ebp-12],1	;mark that at least one digit has been output

gd_next_digit:
	sub	esi,8		;esi -> next lower power of ten
	cmp	esi,gd_table	;backed up past beginning of table?
	jae	gd_digit_loop	;no: do next digit

	mov	edi,ebx		;edi -> next char in result string
gd_done:
	xor	al,al
	stosb			;append null terminator
	mov	eax,[ebp-4]	;eax -> result string
	sub	edi,eax		;edi = LEN(result string) + 1
	dec	edi		;edi = LEN(result string)
	mov	[eax-8],edi	;store length of result string

	mov	esp,ebp
	pop	ebp
	ret

gd_zero:			;just generate "0" string
	mov	al,'0'
	stosb			;write '0' after prefix
	jmp	gd_done
;
;
; ****************************
; *****  %_str.d.double  *****  STR$(x)
; ****************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_str.d.double:
	fld	qword ptr [esp+4] ;get number to convert to string
	fxam			;test against zero
	fstsw	ax		;C1 bit = sign bit
	test	ah,2		;copy C1 bit to zero bit (inverted)

	fabs			;float.string expects a positive number
	mov	eax,'-'		;preload with leading minus sign
	jnz	short str_double_prefix ;if negative, minus sign is correct
	mov	eax,' '		;nope, number needs leading space
str_double_prefix:
	push	eax		;push leading character
	push	'd'		;push exponent letter
	push	15		;push maximum number of digits
	call	float.string	;eax -> result string
	add	esp,12
	ret
;
;
; ****************************
; *****  %_str.d.single  *****  STR$(x)
; ****************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	space is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_str.d.single:
	fld	dword ptr [esp+4] ;get number to convert to string
	fxam			;test against zero
	fstsw	ax		;C1 bit = sign bit
	test	ah,2		;copy C1 bit to zero bit (inverted)

	fabs			;float.string expects a positive number
	mov	eax,'-'		;preload with leading minus sign
	jnz	short str_single_prefix ;if negative, minus sign is correct
	mov	eax,' '		;nope, number needs leading space
str_single_prefix:
	push	eax		;push leading character
	push	'e'		;push exponent letter
	push	7		;push maximum number of digits
	call	float.string	;eax -> result string
	add	esp,12
	ret
;
;
; *******************************
; *****  %_string.d.double  *****  STRING(x)
; *******************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_string.double:
%_string.d.double:
	fld	qword ptr [esp+4] ;get number to convert to string
	fxam			;test against zero
	fstsw	ax		;C1 bit = sign bit
	test	ah,2		;copy C1 bit to zero bit (inverted)

	fabs			;float.string expects a positive number
	mov	eax,'-'		;preload with leading minus sign
	jnz	short string_double_prefix ;if negative, minus sign is correct
	xor	eax,eax		;nope, number gets no leading char
string_double_prefix:
	push	eax		;push leading character
	push	'd'		;push exponent letter
	push	15		;push maximum number of digits
	call	float.string	;eax -> result string
	add	esp,12
	ret
;
;
; *******************************
; *****  %_string.d.single  *****  STR$(x)
; *******************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	no leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_string.single:
%_string.d.single:
	fld	dword ptr [esp+4] ;get number to convert to string
	fxam			;test against zero
	fstsw	ax		;C1 bit = sign bit
	test	ah,2		;copy C1 bit to zero bit (inverted)

	fabs			;float.string expects a positive number
	mov	eax,'-'		;preload with leading minus sign
	jnz	short string_single_prefix ;if negative, minus sign is correct
	xor	eax,eax		;nope, number gets no leading char
string_single_prefix:
	push	eax		;push leading character
	push	'e'		;push exponent letter
	push	7		;push maximum number of digits
	call	float.string	;eax -> result string
	add	esp,12
	ret
;
;
; *******************************
; *****  %_signed.d.double  *****  STR$(x)
; *******************************
;
; in:	arg1:arg0 = number to convert to string
; out:	eax -> result string:	plus sign is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_signed.d.double:
	fld	qword ptr [esp+4] ;get number to convert to string
	fxam			;test against zero
	fstsw	ax		;C1 bit = sign bit
	test	ah,2		;copy C1 bit to zero bit (inverted)

	fabs			;float.string expects a positive number
	mov	eax,'-'		;preload with leading minus sign
	jnz	short signed_double_prefix ;if negative, minus sign is correct
	mov	eax,'+'		;nope, number needs leading plus sign
signed_double_prefix:
	push	eax		;push leading character
	push	'd'		;push exponent letter
	push	15		;push maximum number of digits
	call	float.string	;eax -> result string
	add	esp,12
	ret
;
;
; *******************************
; *****  %_signed.d.single  *****  STR$(x)
; *******************************
;
; in:	arg0 = number to convert to string
; out:	eax -> result string:	plus sign is leading character if positive
;				hyphen is leading character if negative
;
; destroys: ebx, ecx, edx, esi, edi
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
%_signed.d.single:
	fld	dword ptr [esp+4] ;get number to convert to string
	fxam			;test against zero
	fstsw	ax		;C1 bit = sign bit
	test	ah,2		;copy C1 bit to zero bit (inverted)

	fabs			;float.string expects a positive number
	mov	eax,'-'		;preload with leading minus sign
	jnz	short signed_single_prefix ;if negative, minus sign is correct
	mov	eax,'+'		;nope, number needs leading plus sign
signed_single_prefix:
	push	eax		;push leading character
	push	'e'		;push exponent letter
	push	7		;push maximum number of digits
	call	float.string	;eax -> result string
	add	esp,12
	ret
;
;
; **************************
; *****  float.string  *****  creates decimal representation of st(0)
; **************************
;
; in:	st(0) = number to convert to string; MUST BE POSITIVE!
;	arg2 = prefix character, or 0 if no prefix character
;	arg1 = letter for exponent of scientific notation necessary
;	arg0 = maximum number of digits
; out:	eax -> result string (prefix character is prepended to result string)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> result string
;	[ebp-8]:[ebp-12] input number (double precision)
;	[ebp-16] = current digit
;	[ebp-20] = flag: do zeros get printed? (are we past leading zeros?)
;	[ebp-24] = exponent to print at end (if scientific notation)
;	[ebp-28] = FPU control-word buffer
;	[ebp-32] = on-entry FPU control word
;
; Result string is dynamically allocated; freeing it is the caller's
; responsibility.
;
; Result string is in scientific notation if:
;
;	number > 100000, or
;	number < 0.00001
;
float.string:
	push	ebp
	mov	ebp,esp
	sub	esp,32

	mov	esi,30		;get room for at least 30 bytes to hold result
	call	%_____calloc	;esi -> header of result string
	add	esi,16		;esi -> result string
	mov	[ebp-4],esi	;save it
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;info word indicates: allocated string
	mov	[esi-4],eax	;store info word

	mov	edi,esi		; edi=esi  (max added fix for STRING$(+value) 05/15/93)
	mov	eax,[ebp+16]	;eax = prefix character
	or	eax,eax		;a null?
	jz	short float_prefix_done ;yes: don't prepend a prefix
	mov	[esi],al	;no: store it
	lea	edi,[esi+1]	;edi -> character after prefix character

float_prefix_done:
	fnstcw	word ptr [ebp-28] ;get current control word
	mov	bx,[ebp-28]	;bx = control word
	mov	[ebp-32],bx	;save original control word
	or	bx,0x0C00	;set rounding mode to: truncate
	mov	[ebp-28],bx	;[ebp-28] = new control word
	fldcw	word ptr [ebp-28] ;truncation is on

	fxam			;what sort of number is st(0)?
	fstsw	ax
	and	ah,0b01000101	;mask out all but C3, C2, and C0
	movzx	ebx,ah		;build index into jump table in ebx
	slr	ah,5		;shift C3 bit in between C2 and C0
	or	bl,ah		;copy C3 bit into ebx
	and	ebx,0b111	;just the lower three bits now
	jmp	[fxam_table + ebx*4] ;go to float_normal, float_zero,
				     ; float_nan, or float_infinity, as
				     ; appropriate
;
float_normal:			;we have ourselves a non-zero number to print
	fst	qword ptr [ebp-12] ;put input number into memory...
	mov	[ebp-20],0	;mark that leading zeros don't get printed
	xor	edx,edx		;clear digit counter
	fwait
	mov	ebx,[ebp-8]	;...so we can
	slr	ebx,20		;extract its exponent
	imul	ebx,0x4D1	;multiply exponent by .301 of 0x1000
	slr	ebx,12		;div by 0x1000: ebx = exponent * 0.301
	add	ebx,1		;ebx = index into %_pwr_10_table

	fcom	qword ptr [hundred_thousand]
	fstsw	ax		;greater than or equal to 100000 requires
	sahf			; scientific notation
	jae	float_scientific

	fcom	qword ptr [hundred_thousandth]
	fstsw	ax		;less than .00001 requires
	sahf			; scientific notation
	jb	float_scientific

	mov	[ebp-24],0	;do not output trailing exponent

	mov	eax,0		; number not normalized.
	;if number < 1, make exponent 307
	cmp	ebx,307		;is 1 > number > 0?
	ja	short float_normalized ;no: it's okay already
	mov	ebx,307		;yes: start output at tenths digit

float_normalized:
	mov	esi,ebx
	sub	esi,[ebp+8]	;esi -> pwr of 10 of (non-)digit to right of
									; least significant possible digit
	jns	short float_round
	xor	esi,esi		;if before beginning of table, point to 10^-308
	jmp	short float_round_done

float_round:
	fld	qword ptr [%_pwr_10_table + esi*8]
	fld	qword ptr [ffive]
	fmul			;multiply digit past last possible digit by 5
	fadd			;round off number to maximum possible digits
	inc	esi		;esi -> pwr of 10 of last possible digit

	cmp	eax,0		; Skip 'colon' fix if number is not normalized.
	je	float_round_done

	fcom	qword ptr [%_pwr_10_to_0 + 8] ;compare to 10#
	fstsw	ax
	sahf
	jb	float_round_done	;jump if number is still less than 10#
	fdiv	qword ptr [%_pwr_10_to_0 + 8] ;divide normalized number by 10#
	inc	[ebp-24]	;inc exponent
float_round_done:

fl_normal_loop:
	cmp	ebx,307		;just crossed over into decimal land?
	jne	short fl_digit	;nope
	mov	al,'.'		;yep: output decimal point
	stosb
	mov	[ebp-20],1	;mark that zeros now get printed

fl_digit:
	fld	st(0)		;save current number to st(1)
	fdiv	qword ptr [%_pwr_10_table + ebx*8] ;div by current power of ten
	frndint			;truncate to get current digit
	fist	dword ptr [ebp-16] ;write current digit to memory, and hold
				   ; in st(0)
	fwait
	mov	al,[ebp-16]	;al = current digit
	or	al,al		;a zero?
	jnz	short fl_normal_digit ;no: output it unconditionally
	cmp	[ebp-20],0	;are we past leading zeros?
	jz	short fl_normal_digit_done ;no: move on to next digit

fl_normal_digit:
	add	al,'0'		;convert digit to ASCII
	stosb			;append it to result string
	inc	edx		;bump digit counter
	mov	[ebp-20],1	;mark that we're past leading zeros

fl_normal_digit_done:
	fmul	qword ptr [%_pwr_10_table + ebx*8] ;digit * power of ten
	fst	qword ptr [fdebug]	;DEBUG
	fwait			;DEBUG
	fwait			;DEBUG
	fwait			;DEBUG
	fsubp			;st(0) = what's left
	fst	qword ptr [fdebug]	;DEBUG
	fwait			;DEBUG
	fwait			;DEBUG
	fwait			;DEBUG

	fld	qword ptr [%_pwr_10_table + esi*8] ;value of least significant
						   ; possible digit
	fcomp			;anything other than trailing zeros left
	fstsw	ax		; to print?
	sahf
	ja	short fl_normal_zero	;no: print trailing zeros

	dec	ebx		;bump current power of ten
	cmp	edx,[ebp+8]	;reached maximum number of digits?
	jae	short float_exponent ;yes
	jmp	fl_normal_loop

fl_normal_zero:			;number is down to zero (or close enough)
	cmp	ebx,308		;any trailing zeros to print?
	jbe	short float_exponent ;no
	mov	byte ptr [edi],'0' ;yes: print one
	inc	edi
	dec	ebx		;next power of ten
	jmp	fl_normal_zero

float_scientific:		;print a number with an exponent at the end
fl_find_1st_digit_loop:
	fcom	qword ptr [%_pwr_10_table + ebx*8] ;number is >=
	fstsw	ax				   ; current power of ten?
	sahf
	jae	short fl_got_first_digit

	dec	ebx		;next lower power of ten
	cmp	ebx,-308	;past end of table?
	jl	float_zero	;yes: it's zero for all practical purposes
	jmp	fl_find_1st_digit_loop

fl_got_first_digit:
	lea	ecx,[ebx-308]	;ecx = exponent to append to number
	mov	[ebp-24],ecx	;save it

	neg	ecx		;ecx = offset relative to %_pwr_10_to_0 of
				; negative of original exponent
	fmul	qword ptr [%_pwr_10_to_0 + ecx*8] ;normalize number
				; (i.e. put number in terms of 10^0)
	fst	qword ptr [fdebug]	;DEBUG
	fwait			;DEBUG
	fwait			;DEBUG
	fwait			;DEBUG
	mov	ebx,308		;ebx = offset for 10^0
	mov	eax,-1		; numbers is normalized.
	jmp	float_normalized ;output the number; it should now be in
				 ; range 1 <= number < 10

float_exponent:			;just finished printing mantissa
	mov	ecx,[ebp-24]	;ecx = exponent
	or	ecx,ecx		;need to print any exponent at all?
	jz	short float_done ;nope

	mov	al,[ebp+12]	;al = exponent letter ('e' or 'd')
	stosb			;append it to result string

	mov	al,'+'		;pre-load with plus sign
				;flags are still set from "or ecx,ecx"
	jns	short fl_exp_sign ;yes: plus sign is correct
	mov	al,'-'		;no: minus sign for negative exponent
	neg	ecx		;and now force exponent positive

fl_exp_sign:
	stosb			;append sign to result string
	mov	eax,ecx		;eax = exponent
	mov	ecx,100
	cmp	eax,ecx		;exponent has three digits?
	jb	short fl_exp_two_digits ;no: maybe it has two digits

	xor	edx,edx		;clear high 32 bits of numerator
	idiv	ecx		;eax = # of hundreds, edx = what's left
	add	eax,'0'		;convert to ASCII
	stosb			;append hundreds digit to result string

	mov	eax,edx		;eax = what's left of exponent
	mov	ecx,10
	jmp	short fl_exp_tens_digit
;
fl_exp_two_digits:
	mov	ecx,10
	cmp	eax,ecx		;exponent has two digits?
	jb	short fl_exp_last_digit ;no: only one digit
;;
fl_exp_tens_digit:
	xor	edx,edx		;clear high 32 bits of numerator
	idiv	ecx		;eax = # of tens, edx = units
	add	eax,'0'		;convert to ASCII
	stosb			;append tens digit to result string
	mov	eax,edx		;eax = units

fl_exp_last_digit:
	add	eax,'0'		;convert to ASCII
	stosb			;append units digit to result string
	jmp	float_done
;
float_nan:
	mov	al,'N'		;just send "NAN" to result string
	stosb
	mov	al,'A'
	stosb
	mov	al,'N'
	stosb
	jmp	short float_done
;
float_infinity:
	mov	al,'i'		;just send "inf" to result string
	stosb
	mov	al,'n'
	stosb
	mov	al,'f'
	stosb
	jmp	short float_done
;
float_zero:			;just send "0" to result string
	mov	al,'0'
	stosb
;;
;; fall through
;;
float_done:			;assumes edi -> char after last char of result
	fstp	st(0)		;pop input number; clear FPU stack
	mov	esi,edi		;esi also -> char after last char
	mov	eax,[ebp-4]	;eax -> result string
	sub	esi,eax		;esi = LEN(result string)
	mov	[eax-8],esi	;save string length
	mov	byte ptr [edi],0 ;write terminating null

	fldcw	word ptr [ebp-32] ;restore on-entry rounding mode
	mov	esp,ebp
	pop	ebp
	ret			;return with eax -> result string
;
;
;
.align	8
ulong_table:			;table of values for each decimal digit
	.dword	1000000000	; read by str.ulong.x
	.dword	100000000
	.dword	10000000
	.dword	1000000
	.dword	100000
	.dword	10000
	.dword	1000
	.dword	100
	.dword	10
	.dword	1
	.dword	0		;zero indicates end of list
;
.align	8
hex_digits:			;table of digits read by hex.dword and bin.dword
	.byte	"0123456789ABCDEF"
;
.text
.align	8
gd_start_digits:	;indexes into gd_table according to the position
			;of the first one bit in the 64-bit number to
			;convert to a decimal string
.byte	0		; bit 00: highest possible MSD for 0x00000001 LSW
.byte	0		; bit 01: highest possible MSD for 0x00000003 LSW
.byte	0		; bit 02: highest possible MSD for 0x00000007 LSW
.byte	1		; bit 03: highest possible MSD for 0x0000000F LSW
.byte	1		; bit 04: highest possible MSD for 0x0000001F LSW
.byte	1		; bit 05: highest possible MSD for 0x0000003F LSW
.byte	2		; bit 06: highest possible MSD for 0x0000007F LSW
.byte	2		; bit 07: highest possible MSD for 0x000000FF LSW
.byte	2		; bit 08: highest possible MSD for 0x000001FF LSW
.byte	3		; bit 09: highest possible MSD for 0x000003FF LSW
.byte	3		; bit 10: highest possible MSD for 0x000007FF LSW
.byte	3		; bit 11: highest possible MSD for 0x00000FFF LSW
.byte	3		; bit 12: highest possible MSD for 0x00001FFF LSW
.byte	4		; bit 13: highest possible MSD for 0x00003FFF LSW
.byte	4		; bit 14: highest possible MSD for 0x00007FFF LSW
.byte	4		; bit 15: highest possible MSD for 0x0000FFFF LSW
.byte	5		; bit 16: highest possible MSD for 0x0001FFFF LSW
.byte	5		; bit 17: highest possible MSD for 0x0003FFFF LSW
.byte	5		; bit 18: highest possible MSD for 0x0007FFFF LSW
.byte	6		; bit 19: highest possible MSD for 0x000FFFFF LSW
.byte	6		; bit 20: highest possible MSD for 0x001FFFFF LSW
.byte	6		; bit 21: highest possible MSD for 0x003FFFFF LSW
.byte	6		; bit 22: highest possible MSD for 0x007FFFFF LSW
.byte	7		; bit 23: highest possible MSD for 0x00FFFFFF LSW
.byte	7		; bit 24: highest possible MSD for 0x01FFFFFF LSW
.byte	7		; bit 25: highest possible MSD for 0x03FFFFFF LSW
.byte	8		; bit 26: highest possible MSD for 0x07FFFFFF LSW
.byte	8		; bit 27: highest possible MSD for 0x0FFFFFFF LSW
.byte	8		; bit 28: highest possible MSD for 0x1FFFFFFF LSW
.byte	9		; bit 29: highest possible MSD for 0x3FFFFFFF LSW
.byte	9		; bit 30: highest possible MSD for 0x7FFFFFFF LSW
.byte	9		; bit 31: highest possible MSD for 0xFFFFFFFF LSW

.byte	9		; bit 32: highest possible MSD for 0x00000001 MSW
.byte	10		; bit 33: highest possible MSD for 0x00000003 MSW
.byte	10		; bit 34: highest possible MSD for 0x00000007 MSW
.byte	10		; bit 35: highest possible MSD for 0x0000000F MSW
.byte	11		; bit 36: highest possible MSD for 0x0000001F MSW
.byte	11		; bit 37: highest possible MSD for 0x0000003F MSW
.byte	11		; bit 38: highest possible MSD for 0x0000007F MSW
.byte	12		; bit 39: highest possible MSD for 0x000000FF MSW
.byte	12		; bit 40: highest possible MSD for 0x000001FF MSW
.byte	12		; bit 41: highest possible MSD for 0x000003FF MSW
.byte	12		; bit 42: highest possible MSD for 0x000007FF MSW
.byte	13		; bit 43: highest possible MSD for 0x00000FFF MSW
.byte	13		; bit 44: highest possible MSD for 0x00001FFF MSW
.byte	13		; bit 45: highest possible MSD for 0x00003FFF MSW
.byte	14		; bit 46: highest possible MSD for 0x00007FFF MSW
.byte	14		; bit 47: highest possible MSD for 0x0000FFFF MSW
.byte	14		; bit 48: highest possible MSD for 0x0001FFFF MSW
.byte	15		; bit 49: highest possible MSD for 0x0003FFFF MSW
.byte	15		; bit 50: highest possible MSD for 0x0007FFFF MSW
.byte	15		; bit 51: highest possible MSD for 0x000FFFFF MSW
.byte	15		; bit 52: highest possible MSD for 0x001FFFFF MSW
.byte	16		; bit 53: highest possible MSD for 0x003FFFFF MSW
.byte	16		; bit 54: highest possible MSD for 0x007FFFFF MSW
.byte	16		; bit 55: highest possible MSD for 0x00FFFFFF MSW
.byte	17		; bit 56: highest possible MSD for 0x01FFFFFF MSW
.byte	17		; bit 57: highest possible MSD for 0x03FFFFFF MSW
.byte	17		; bit 58: highest possible MSD for 0x07FFFFFF MSW
.byte	18		; bit 59: highest possible MSD for 0x0FFFFFFF MSW
.byte	18		; bit 60: highest possible MSD for 0x1FFFFFFF MSW
.byte	18		; bit 61: highest possible MSD for 0x3FFFFFFF MSW
.byte	18		; bit 62: highest possible MSD for 0x7FFFFFFF MSW
.byte	19		; bit 63: highest possible MSD for 0xFFFFFFFF MSW
;
.align	8
gd_table:			; 64-bit powers of ten
.dword	0x00000001, 0x00000000  ;                          1	 1 digit
.dword	0x0000000A, 0x00000000  ;                         10	 2 digits
.dword	0x00000064, 0x00000000  ;                        100	 3 digits
.dword	0x000003E8, 0x00000000  ;                      1,000	 4 digits
.dword	0x00002710, 0x00000000  ;                     10,000	 5 digits
.dword	0x000186A0, 0x00000000  ;                    100,000	 6 digits
.dword	0x000F4240, 0x00000000  ;                  1,000,000	 7 digits
.dword	0x00989680, 0x00000000  ;                 10,000,000	 8 digits
.dword	0x05F5E100, 0x00000000  ;                100,000,000	 9 digits
.dword	0x3B9ACA00, 0x00000000  ;              1,000,000,000	10 digits
.dword	0x540BE400, 0x00000002  ;             10,000,000,000	11 digits
.dword	0x4876E800, 0x00000017  ;            100,000,000,000	12 digits
.dword	0xD4A51000, 0x000000E8  ;          1,000,000,000,000	13 digits
.dword	0x4E72A000, 0x00000918  ;         10,000,000,000,000	14 digits
.dword	0x107A4000, 0x00005AF3  ;        100,000,000,000,000	15 digits
.dword	0xA4C68000, 0x00038D7E  ;      1,000,000,000,000,000	16 digits
.dword	0x6FC10000, 0x002386F2  ;     10,000,000,000,000,000	17 digits
.dword	0x5D8A0000, 0x01634578  ;    100,000,000,000,000,000	18 digits
.dword	0xA7640000, 0x0DE0B6B3  ;  1,000,000,000,000,000,000	19 digits
.dword	0x89E80000, 0x8AC72304  ; 10,000,000,000,000,000,000	20 digits
;
.align	8
oct_msd_64:		;table of shift values for most significant dword
			;of a 64-bit number; zero indicates end of list
	.byte	1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 0
;
.align	8
oct_lsd_64:		;table of shift values for least significant dword
	.byte	2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0
;
.align	8
hundred_thousand:
	.dword	0x0, 0x40F86A00
;
hundred_thousandth:
	.dword	0x88E368F1, 0x3EE4F8B5
;
ften:	.dword	0x0, 0x40240000
;
ffive:	.dword	0x0, 0x40140000
;
.align	8
fxam_table:		;jump table for values of C2, C3, C0 bits of FPU
			; after FXAM
	.dword	float_nan	;C2 = 0   C3 = 0   C0 = 0
	.dword	float_nan	;     0        0        1
	.dword	float_zero	;     0        1        0
	.dword	float_nan	;     0        1        1
	.dword	float_normal	;     1        0        0
	.dword	float_infinity	;     1        0        1
	.dword	float_normal	;     1        1        0
	.dword	float_nan	;     1        1        1
;
;
;
.text
;
; ######################
; #####  xlibss.s  #####  intrinsics that take strings and return strings
; ######################
;
; *************************
; *****  %_csize.d.v  *****  CSIZE$(x$)
; *****  %_csize.d.s  *****
; *************************
;
; in:	arg0 -> source string
; out:	eax -> copy of source string, truncated at first null
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit
;
%_csize.d.v:
	xor	ebx,ebx		;nothing to free on exit
	jmp	short csize.d.x
;
%_csize.d.s:
	mov	ebx,[esp+4]	;ebx -> string to free on exit
;;
;; fall through
;;
csize.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;save pointer to string to free on exit
	cld
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;null pointer?
	jz	short csize_null ;yes: nothing to do

	mov	esi,[esi-8]	;esi = length of source string
	inc	esi		;one more for terminating null
	call	%____calloc	;allocate space for copy
				;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word

	mov	edi,esi		;edi -> result string
	mov	ebx,edi		;save it
	mov	esi,[ebp+8]	;esi -> source string
	xor	edx,edx		;edx = length counter = 0

csize_loop:
	lodsb			;al = next character
	or	al,al		;found the null?
	jz	short csize_done ;yes: nothing left to copy
	stosb			;no: write character to result string
	inc	edx		;bump length counter
	jmp	csize_loop

csize_done:
	mov	[ebx-8],edx	;store length of result string
	push	ebx		;save pointer to result string
	mov	esi,[ebp-4]	;esi -> string to free on exit
	call	%____free	;free it
	pop	eax		;eax -> result string

	mov	esp,ebp
	pop	ebp
	ret

csize_null:			;create a string with nothing but a null in it
	inc	esi		;esi = bytes needed for string = 1
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	mov	[esi-8],0	;store length
				;we got passed a null pointer, so there can
	mov	eax,esi		; be nothing to free
	mov	esp,ebp		;eax -> result string
	pop	ebp
	ret
;
;
; *************************
; *****  %_lcase.d.s  *****  LCASE$(x$) and UCASE$(x$)
; *****  %_lcase.d.v  *****
; *****  %_ucase.d.s  *****
; *****  %_ucase.d.v  *****
; *************************
;
; in:	arg0 - > string to convert
; out:	eax -> converted string
;
; destroys: ebx, ecx, edx, esi, edi
;
; .s routines convert string at arg0
; .v routines create a new string.
;
%_lcase.d.s:
	mov	ebx,%_uctolc	;ebx -> table to convert to lower case
	jmp	short xcase.d.s	;branch to common routine
;
%_ucase.d.s:
	mov	ebx,%_lctouc	;ebx -> table to convert to upper case
	;fall through

xcase.d.s:
	mov	esi,[esp+4]	;esi -> string to convert
	cld
	or	esi,esi		;null pointer?
	jz	short xcase_ret	;yes: nothing to do

	mov	ecx,[esi-8]	;ecx = length of input string
	mov	edi,esi        ;edi -> input string, which is also output string

xcase_d_s_loop:
	jecxz	xcase_ret	;quit loop if reached last character
	lodsb			;get next char
	xlatb			;convert char
	stosb			;store it
	dec	ecx		;bump character counter
	jmp	xcase_d_s_loop	;do next character

xcase_ret:
	mov	eax,[esp+4]
	ret
;
;
%_lcase.d.v:
	mov	ebx,%_uctolc	;ebx -> table to convert upper to lower
	jmp	short xcase.d.v	;branch to common routine
;
%_ucase.d.v:
	mov	ebx,%_lctouc	;ebx -> table to convert to upper case
;;
;; fall through
;;
xcase.d.v:
	mov	esi,[esp+4]	;esi -> string to convert
	or	esi,esi		;null pointer?
	jz	short xcase_ret	;yes: nothing to do

	push	ebx		;save pointer to translation table
	mov	esi,[esi-8]	;esi = length of result string
	inc	esi		;add one for null terminator
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word

	pop	ebx		;ebx -> translation table
	mov	edi,esi		;edi -> result string
	mov	edx,esi		;save pointer so we can return it later
	mov	esi,[esp+4]	;esi -> source string
	mov	ecx,[esi-8]	;ecx = length of source string
	mov	[edi-8],ecx	;store length into result string

xcase_d_v_loop:
	jecxz	xcase_d_v_ret	;exit loop if all characters have been copied
	lodsb			;fetch character from source string
	xlatb			;convert its case
	stosb			;store character to result string
	dec	ecx		;bump character counter
	jmp	xcase_d_v_loop	;do next character

xcase_d_v_ret:
	mov	byte ptr [edi],0 ;write null terminator
	mov	eax,edx		;eax -> result string
	ret
;
;
; *************************
; *****  %_rjust.d.v  *****  RJUST$(x$, y)
; *****  %_rjust.d.s  *****
; *************************
;
; in:	arg1 = desired width of result string
;	arg0 -> string to right-justify
; out:	eax -> copy of source string, padded with space on left so that it's
;	       arg1 characters long
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null to not free anything
;
%_rjust.d.v:
	xor	ebx,ebx		;don't free anything on exit
	jmp	short rjust.d.x
;
%_rjust.d.s:
	mov	ebx,[esp+4]	;ebx -> string to free on exit (arg0)
;;
;; fall through
;;
rjust.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;store pointer to string to free on exit
	cld
	mov	esi,[ebp+12]	;esi = desired length of string
	or	esi,esi		;zero or less??
	jbe	short rjust_null ;yes: return null string

	inc	esi		;add one to length for null terminator
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	mov	ecx,[ebp+12]	;ecx = desired length of string
	mov	[esi-8],ecx	;store length

	mov	edi,esi		;edi -> result string
	mov	esi,[ebp+8]	;esi -> source string
	mov	edx,edi		;save pointer to result string in edx
	xor	ebx,ebx		;ebx = length of source string if it's null
	or	esi,esi		;source string is null pointer?
	jz	short rjust_not_null ;yes: ebx is correct
	mov	ebx,[esi-8]	;ebx = length of source string
rjust_not_null:
	cmp	ecx,ebx		;desired length no more than current length?
	jbe	short rjust_copy_orig ;yes: just copy part of original string

	sub	ecx,ebx		;ecx = number of spaces to prepend to string
	mov	al,' '		;ready to write some spaces
	rep
	stosb			;write them spaces!

	mov	ecx,ebx		;ecx = length of original string
rjust_copy_orig:
	rep
	movsb			;copy original string
	mov	byte ptr [edi],0 ;write null terminator

	mov	eax,edx		;eax -> result string
rjust_ret:
	push	eax		;save result
	mov	esi,[ebp-4]	;esi -> string to free
	call	%____free
	pop	eax		;eax -> result
	mov	esp,ebp
	pop	ebp
	ret

cjust_null:
ljust_null:
rjust_null:
	xor	eax,eax		;return null string
	jmp	rjust_ret
;
;
; *************************
; *****  %_ljust.d.v  *****  LJUST$(x$, y)
; *****  %_ljust.d.s  *****
; *************************
;
; in:	arg1 = desired length
;	arg0 -> string to left-justify
; out:	eax -> copy of source string, padded with space on right so that it's
;	       arg1 characters long
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null to not free anything
;
%_ljust.d.v:
	xor	ebx,ebx		;don't free anything on exit
	jmp	short ljust.d.x
;
%_ljust.d.s:
	mov	ebx,[esp+4]	;ebx -> string to free on exit
;;
;; fall through
;;
ljust.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;save pointer to string to free on exit
	cld
	mov	esi,[ebp+12]	;esi = desired length of string
	or	esi,esi		;zero or less??
	jbe	short ljust_null ;yes: return null string

	inc	esi		;add one to length for null terminator
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	mov	ebx,[ebp+12]	;ebx = desired length of string
	mov	[esi-8],ebx	;store length

	mov	edi,esi		;edi -> result string
	mov	esi,[ebp+8]	;esi -> source string
	mov	edx,edi		;save pointer to result string in edx
	or	esi,esi		;source string is null pointer?
	jz	short ljust_spaces ;yes: create nothing but spaces
	mov	ecx,[esi-8]	;ecx = length of source string
ljust_not_null:
	xor	eax,eax		;eax = 0 to flag need to append spaces
	cmp	ebx,ecx		;desired length greater than current length?
	ja	short ljust_copy ;no: skip
	mov	ecx,ebx		;copy only desired-length characters
	inc	eax		;eax != 0 to indicate no need to append spaces

ljust_copy:
	rep
	movsb			;copy source string to result string

	or	eax,eax		;need to append spaces?
	jnz	short ljust_done ;nope
	mov	esi,[ebp+8]	;esi -> source string
	sub	ebx,[esi-8]	;ebx = desired - current = # of spaces to add
ljust_spaces:
	mov	ecx,ebx		;counter register = # of spaces to add
	mov	al,' '		;ready to write spaces
	rep
	stosb			;write them spaces!

ljust_done:
	mov	byte ptr [edi],0 ;append null terminator
	push	edx		;save pointer to result string
	mov	esi,[ebp-4]	;esi -> string to free, if any
	call	%____free
	pop	eax		;return result pointer in eax

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_cjust.d.v  *****
; *****  %_cjust.d.s  *****
; *************************
;
; in:	arg1 = desired length
;	arg0 -> string to center
; out:	eax -> centered version of string at arg0
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null if nothing to free
;	[ebp-8] -> result string
;
%_cjust.d.v:
	xor	ebx,ebx		;no string to free on exit
	jmp	short cjust.d.x
;
%_cjust.d.s:
	mov	ebx,[esp+4]	;ebx -> string to free on exit (arg0)
;;
;; fall through
;;
cjust.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov	[ebp-4],ebx	;save pointer to string to free on exit
	cld
	mov	esi,[ebp+12]	;esi = desired length of string
	or	esi,esi		;zero or less??
	jbe	cjust_null	;yes: return null string

	inc	esi		;add one to length for null terminator
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	mov	ecx,[ebp+12]	;ecx = desired length of string
	mov	[esi-8],ecx	;store length

	mov	edi,esi		;edi -> result string
	mov	esi,[ebp+8]	;esi -> source string
	mov	[ebp-8],edi	;save pointer to result string
	xor	ebx,ebx		;ebx = length of source string if it's null
	or	esi,esi		;source string is null pointer?
	jz	short cjust_not_null ;yes: ebx is correct
	mov	ebx,[esi-8]	;ebx = length of source string
cjust_not_null:
	cmp	ecx,ebx		;desired length no more than original length?
	jbe	short cjust_copy_only ;yes: pad no spaces on either side

	mov	edx,ecx		;save desired length in edx
	sub	ecx,ebx		;ecx = desired length - original length
	slr	ecx,1		;ecx = # of spaces to add on left
	lea	eax,[ecx+ebx]	;eax = left spaces + original length
	sub	edx,eax		;edx = # of spaces to add on right

	mov	al,' '		;ready to write some spaces
	rep
	stosb			;store spaces on left side of string

	mov	ecx,ebx		;ecx = length of original string
	rep
	movsb			;copy original string

	mov	ecx,edx		;ecx = # of spaces to add on right
	rep
	stosb			;store spaces on right side of string

cjust_exit:
	mov	byte ptr [edi],0 ;write null terminator
	mov	esi,[ebp-4]	;ebx -> string to free, if any
	call	%____free

	mov	eax,[ebp-8]	;eax -> result string
	mov	esp,ebp
	pop	ebp
	ret

cjust_copy_only:
	rep
	movsb			;copy source string to result string
	jmp	short cjust_exit
;
;
; *************************
; *****  %_lclip.d.v  *****  LCLIP$(x$, y)
; *****  %_lclip.d.s  *****
; *************************
;
; in:	arg1 = number of characters to clip from left of string
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> source string if .s, null if .v
;	[ebp-8] -> result string
;
%_lclip.d.v:
	xor	ebx,ebx		;must create new string
	jmp	short lclip.d.x
;
%_lclip.d.s:
	mov	ebx,[esp+4]	;ebx -> source string; modify it in place
;;
;; fall through
;;
lclip.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov	[ebp-4],ebx	;store null or pointer to source string
	cld
	mov	edi,[ebp+8]	;edi -> source string
	or	edi,edi		;source string is null pointer?
	jz	short lclip_null ;yes: just return null pointer
	mov	ecx,[edi-8]	;ecx = current length of string
	mov	esi,edi		;esi -> source string
	mov	edx,[ebp+12]	;edx = # of bytes to clip
	or	edx,edx		;fewer than zero bytes?
	js	short lclip_IFC	;yes: get angry

	sub	ecx,edx		;clipping more (or same #) chars than in string?
				; (ecx = number of chars to copy from string)
	jbe	short lclip_null ;yes: just return null pointer

	or	ebx,ebx		;do we have to create a new string?
	jnz	short lclip_copy ;no: skip creation of new string

	lea	esi,[ecx+1]	;esi = length of result string (+1 for null)
	call	%____calloc	;create result string; esi -> it
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word

	mov	edi,esi		;edi -> result string
	mov	esi,[ebp+8]	;esi -> original string
	mov	ecx,[esi-8]	;ecx = original length
	mov	edx,[ebp+12]	;edx = # of bytes to clip
	sub	ecx,edx		;ecx = # of bytes to copy from original string

lclip_copy:
	mov	[edi-8],ecx	;store length of result string
	add	esi,edx		;esi -> where in source string to begin copy
	mov	eax,edi		;eax -> result string
	rep
	movsb			;copy right side of source string
	mov	byte ptr [edi],0 ;write null terminator

	mov	esp,ebp
	pop	ebp
	ret
;
mid_IFC:
rclip_IFC:
lclip_IFC:
right_IFC:
stuff_IFC:
	mov	esi,[ebp-4]	;esi -> string to free, if any
	call	%____free
	xor	eax,eax		;return null pointer
	mov	esp,ebp
	pop	ebp
	jmp	%_InvalidFunctionCall	; Return directly from there
;
mid_null:
ltrim_null:
rtrim_null:
lclip_null:
rclip_null:
	mov	esi,[ebp-4]	;esi -> string to free, if any
	call	%____free
	xor	eax,eax		;return null pointer
	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_rclip.d.v  *****  RCLIP$(x$, y)
; *****  %_rclip.d.s  *****
; *************************
;
; in:	arg1 = number of characters to clip off right side of string
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, or null if none
;
%_rclip.d.v:
	xor	ebx,ebx		;no string to free on exit
	jmp	short rclip.d.x
;
%_rclip.d.s:
	mov	ebx,[esp+4]	;ebx -> source string; modify it in place
;;
;; fall through
;;
rclip.d.x:
	push	ebp
	mov	ebp,esp

	mov	[ebp-4],ebx	;save pointer to string to free on exit, if any
	cld
	mov	eax,[ebp+8]	;eax -> source string
	or	eax,eax		;null pointer?
	jz	rclip_null	;yes: return null string
	mov	ecx,[eax-8]	;ecx = length of source string
	mov	edx,[ebp+12]	;edx = # of chars to clip
	or	edx,edx		;fewer than zero bytes?
	js	rclip_IFC	;yes: get angry
	sub	ecx,edx		;ecx = new length of source string
	jbe	rclip_null	;return null if clipping everything

	or	ebx,ebx		;do we have to create a copy?
	jnz	rclip_nocopy	;no: just write a null and change the length

	push	ecx
	lea	esi,[ecx+1]	;esi = length of copy (+ 1 for null terminator)
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	pop	ecx
	mov	[esi-8],ecx	;store length

	mov	edi,esi		;edi -> result string
	mov	eax,esi		;save it in order to return it
	mov	esi,[ebp+8]	;esi -> source string
	rep
	movsb			;copy left part of source string

	mov	byte ptr [edi],0 ;write null terminator
	mov	esp,ebp
	pop	ebp
	ret

rclip_nocopy:
	mov	byte ptr [eax+ecx],0 ;write null terminator
	mov	[eax-8],ecx	;write length

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_ltrim.d.v  *****  LTRIM$(x$)
; *****  %_ltrim.d.s  *****
; *************************
;
; in:	arg0 -> source string
; out:	eax -> string trimmed of all leading spaces and unprintable
;	       characters (i.e. bytes <= 0x20 and >= 0x7F)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
%_ltrim.d.v:
	xor	ebx,ebx		;must create copy to hold result
	jmp	short ltrim.d.x
;
%_ltrim.d.s:
	mov	ebx,[esp+4]	;store result on top of source string
;;
;; fall through
;;
ltrim.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;save pointer to string to free on exit, if any
	cld
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;null pointer?
	jz	ltrim_null	;yes: outta here

	mov	ecx,[esi-8]	;ecx = length of source string
	inc	ecx		;prepare for loop (cancel out initial DEC ECX)
	dec	esi		;cancel out initial INC ESI

ltrim_loop:			;decide where in source string to begin copying
	dec	ecx		;ecx = number of chars left in source string
	jz	ltrim_null	;if none left, return null pointer
	inc	esi
	mov	al,[esi]	;al = next character from string
	cmp	al,' '		;space or less?
	jbe	ltrim_loop	;yes: skip this character
	cmp	al,0x7F		;DEL or has high bit set?
	jae	ltrim_loop	;yes: skip this character
				;no: exit loop
ltrim_loop_done:
	or	ebx,ebx		;do we have to make a new string to hold result?
	jnz	short ltrim_just_copy ;no: skip straight to copy routine
	push	esi
	push	ecx
	lea	esi,[ecx+1]	;esi = length of result (+1 for null terminator)
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	pop	ecx		;ecx = new length
	mov	edi,esi		;edi -> result string
	pop	esi		;esi -> first non-trimmed char in source string

ltrim_copy:
	mov	[edi-8],ecx	;store length of result string
	mov	eax,edi		;eax -> result string
	rep
	movsb			;copy non-trimmed section
	mov	byte ptr [edi],0 ;write null terminator

	mov	esp,ebp
	pop	ebp
	ret

ltrim_just_copy:		;no need to allocate new string
	mov	edi,[ebp+8]	;edi -> source string, which is also result str
	cmp	esi,edi		;nothing is being trimmed?
	jne	ltrim_copy	;no: go move non-trimmed part on top of trimmed
				; part
	mov	eax,esi		;yes, nothing is being trimmed: nothing to do
	mov	esp,ebp		;return result in eax
	pop	ebp
	ret
;
;
; *************************
; *****  %_rtrim.d.v  *****  RTRIM$(x$)
; *****  %_rtrim.d.s  *****
; *************************
;
; in:	arg0 -> source string
; out:	eax -> string trimmed of all trailing spaces and unprintable
;	       characters (i.e. bytes <= 0x20 and >= 0x7F)
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;	[ebp-8] -> length of result string
;
%_rtrim.d.v:
	xor	ebx,ebx		;must create new string to hold result
	jmp	short rtrim.d.x
;
%_rtrim.d.s:
	mov	ebx,[esp+4]	;free source string if we free anything
;;
;; fall through		; and store result on top of source
;;
rtrim.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,8

	mov	[ebp-4],ebx	;save string to free on exit, if any
	cld
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;a null pointer?
	jz	rtrim_null	;yes: return null pointer

	mov	ecx,[esi-8]	;ecx = length of source string
	lea	edi,[esi+ecx]	;edi -> char after last char in source string
	inc	ecx		;cancel out DEC ECX at beginning of loop

rtrim_loop:			;start at end of string and work backwards,
				; searching for first non-trimmable char;
	dec	edi		;bump pointer into source string
	dec	ecx		;ecx = length of result string
	jz	rtrim_null	;if nothing left, return null pointer
	mov	al,[edi]	;al = next character
	cmp	al,' '		;space or less?
	jbe	rtrim_loop	;yes: keep looping
	cmp	al,0x7F		;DEL or above?
	jae	rtrim_loop
				;ecx = length of result string
				;edi -> last char before trimmable chars
	inc	edi		;edi -> first char to trim
	mov	eax,[ebp+8]	;eax -> result string, if no copy
	or	ebx,ebx		;do we need to create a copy?
	jnz	short rtrim_terminator ;no: just stick in null terminator

	mov	[ebp-8],ecx	;save length of result string
	mov	esi,ecx		;esi = length of result string
	inc	esi		;plus one for null terminator
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word

	mov	ecx,[ebp-8]	;ecx = length of result string
	mov	edi,esi		;edi -> result string
	mov	esi,[ebp+8]	;esi -> source string
	mov	eax,edi		;eax -> result string (save it)
	rep
	movsb			;copy source string up to trimmed section

	mov	ecx,[ebp-8]	;ecx = length of result string
rtrim_terminator:
	mov	[eax-8],ecx	;store length of result string
	mov	byte ptr [edi],0 ;write null terminator
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ************************
; *****  %_trim.d.v  *****  TRIM$(x$)
; *****  %_trim.d.s  *****
; ************************
;
; in:	arg0 -> string to trim of leading and trailing chars <= 0x20 and >= 0x7F
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
%_trim.d.v:
	xor	ebx,ebx		;must create new string to hold result
	jmp	short trim.d.x
;
%_trim.d.s:
	mov	ebx,[esp+4]	;store result on top of source string
;;
;; fall through
;;
trim.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;save string to free on exit, if any
	cld
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;a null pointer?
	jz	trim_null	;yes: return null pointer

	mov	edi,esi		;save pointer to source string
	xor	ebx,ebx		;ebx = start position for MID$ = 0
	mov	ecx,[esi-8]	;ecx = length of source string

trim_left_loop:
	jecxz	trim_null	;entire string is trimmed away: return null
	inc	ebx		;bump start position
	dec	ecx		;bump length counter
	lodsb			;get next character
	cmp	al,' '		;space or lower?
	jbe	trim_left_loop	;yes: trim it
	cmp	al,0x7F		;DEL or higher?
	jae	trim_left_loop	;yes: trim it

	dec	esi		;esi -> first non-trimmed character
	mov	eax,[edi-8]	;eax = original length of string
	add	edi,eax		;edi -> char after last char in string

trim_right_loop:		;in this loop, we start at the end of the
				; string and search backwards for a
				; non-trimmable character
	dec	edi		;edi -> next character
	mov	al,[edi]	;al = next character
	cmp	al,' '		;space or lower?
	jbe	trim_right_loop	;yes: trim it
	cmp	al,0x7F		;DEL or higher?
	jae	trim_right_loop	;yes: trim it

				;if fell through, edi -> last non-trimmed char
	inc	edi
	sub	edi,esi		;edi = length of result string

	push	edi		;push length of substring
	push	ebx		;push start position
	push	[ebp+8]		;push pointer to source string
	mov	ebx,[ebp-4]	;ebx indicates whether source is trashable
	call	mid.d.x		;let MID$ do all the work
	add	esp,12

	mov	esp,ebp
	pop	ebp
	ret

trim_null:
right_null:
left_null:
stuff_null:
	mov	esi,[ebp-4]	;esi -> string to free, if any
	call	%____free
	xor	eax,eax		;return null pointer
	mov	esp,ebp
	pop	ebp
	ret
;
;
; ************************
; *****  %_left.d.v  *****  LEFT$(x$,y)
; *****  %_left.d.s  *****
; ************************
;
; in:	arg1 = number of characters to peel off left
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, di
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
%_left.d.v:
	xor	ebx,ebx		;must create new string to hold result
	jmp	short left.d.x
;
%_left.d.s:
	mov	ebx,[esp+4]	;put result on top of source string
;;
;; fall through
;;
left.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;save string to free on exit, if any
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;null pointer?
	jz	left_null	;yes: return null pointer

	mov	ecx,[ebp+12]	;ecx = # of chars to peel off
	jecxz	left_null	;nothing to do if no chars requested

	push	ecx		;push number of chars requested
	push	1		;push start position (always at left of string)
	push	esi		;push pointer to source string
	call	mid.d.x		;let MID$ do all the work
	add	esp,12

	mov	esp,ebp
	pop	ebp
	ret
;
;
; *************************
; *****  %_right.d.v  *****  RIGHT$(x$,y)
; *****  %_right.s.s  *****
; *************************
;
; in:	arg1 = # of characters to peel off of right
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;
%_right.d.v:
	xor	ebx,ebx		;must create new string to hold result
	jmp	short right.d.x
;
%_right.d.s:
	mov	ebx,[esp+4]	;put result on top of source string
;;
;; fall through
;;
right.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,4

	mov	[ebp-4],ebx	;save pointer to string to free on exit, if any
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;a null pointer?
	jz	right_null	;yes: return null pointer

	mov	ecx,[esi-8]	;ecx = length of source string
	jecxz	right_null	;if nothing in string, return null pointer

	mov	edx,[ebp+12]	;edx = requested number of characters
	or	edx,edx
	jz	right_null	;if zero requested, return null pointer
	jb	right_IFC	;if less than zero, get angry

	push	edx		;push number of chars requested
	sub	ecx,edx		;ecx = LEN(x$) - # chars requested = start pos
	ja	short right_skip ;if start pos is in string, then no problem
	xor	ecx,ecx		;otherwise force start pos to first char
right_skip:
	inc	ecx		;make start pos one-biased
	push	ecx		;pass start pos to MID$
	push	esi		;push source string
	call	mid.d.x		;get MID$ to do all the work
	add	esp,12

	mov	esp,ebp
	pop	ebp
	ret
;
;
; ***********************
; *****  %_mid.d.v  *****  MID$(x$,y,z)
; *****  %_mid.d.s  *****
; ***********************
;
; in:	arg2 = number of characters to put in result string
;	arg1 = start position at which to begin copying (first position is "1")
;	arg0 -> source string
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> string to free on exit, if any
;	[ebp-8] -> result string
;	[ebp-12] = min(LEN(source$) - startoffset + 1, substring_len)
;		 = length of result string
;
%_mid.d.v:
	xor	ebx,ebx		;create a new string to hold result
	jmp	short mid.d.x
;
%_mid.d.s:
	mov	ebx,[esp+4]	;store result string on top of source string
;;
;; fall through
;;
mid.d.x:			;general entry point for various string-reducers
	push	ebp		; requires that ebx be set as if MID$ were
	mov	ebp,esp		; called from one of the above two entry points
	sub	esp,12

	mov	[ebp-4],ebx	;save pointer to string to free on exit, if any
	cld
	mov	esi,[ebp+8]	;esi -> source string
	or	esi,esi		;null pointer?
	jz	mid_null	;yes: return null pointer
	mov	edx,[esi-8]	;edx = length of source string
	or	edx,edx		;zero?
	jz	mid_null	;yes: can't take much of a substring from that
	mov	eax,[ebp+12]	;eax = start position (one-biased)
	dec	eax		;eax = true start position
	js	mid_IFC		;less than zero is error
	mov	ecx,[ebp+16]	;ecx = length of substring
	or	ecx,ecx
	jz	mid_null	;if zero, return null pointer
	jb	mid_IFC		;if less than zero, error
	cmp	eax,edx		;start position >= length?
	jae	mid_null	;yes: return null pointer

	mov	ebx,edx		;ebx = source len
	sub	ebx,eax		;ebx = source len - start pos
	cmp	ecx,ebx		;substring len greater than possible?
	jbe	short mid_skip2	;no: ecx already contains true length of result
	mov	ecx,ebx		;shorten ecx to true length of result

mid_skip2:
	mov	[ebp-12],ecx	;save length of result
	cmp	[ebp-4],0	;can we trash the source string?
	jz	short mid_no_trash ;no: have to make a copy
	mov	edi,esi		;yes: point destination at source
	jmp	short mid_go	;now finally get started

mid_no_trash:			;destination is new string
	lea	esi,[ecx+1]	;esi = result length (+1 for null terminator)
	call	%____calloc	;esi -> result string; all others trashed
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word

	mov	edi,esi		;edi -> result string
	mov	esi,[ebp+8]	;esi -> source string
	mov	eax,[ebp+12]	;eax = start position
	dec	eax		;eax = true start position
	mov	ecx,[ebp-12]	;ecx = length of substring

; eax = start position (zero-biased), known to be >= 0
; ecx = length of substring, known to be > 0 and known not to go off the end
;	of the source string
; esi -> source string
; edi -> result string

mid_go:
	mov	[ebp-8],edi	;save pointer to result string
	or	eax,eax		;start position is start of source string?
	jnz	short mid_start_nonzero ;no: will have to move the substring

	cmp	[ebp-4],0	;we're trashing the source string?
	jnz	short mid_write_terminator ;yes: just write null into it

mid_copy:
	rep
	movsb			;copy source string to destination

mid_write_terminator:
	mov	eax,[ebp-8]	;eax -> result string
	mov	ecx,[ebp-12]	;ecx = length of substring = length of result
	mov	[eax-8],ecx	;write length of result string
	mov	byte ptr [eax+ecx],0 ;write null terminator

	mov	esp,ebp
	pop	ebp
	ret

mid_start_nonzero:
	add	esi,eax		;esi -> first character in source to copy
	jmp	mid_copy
;
;
; **************************
; *****  %_stuff.d.vv  *****  STUFF$(x$,y$,i,j)
; *****  %_stuff.d.vs  *****
; *****  %_stuff.d.sv  *****
; *****  %_stuff.d.ss  *****
; **************************
;
; in:	arg3 = # of chars to copy from y$
;	arg2 = start position (one-biased) in x$ at which to start copying
;	arg1 -> y$
;	arg0 -> x$
; out:	eax -> result string
;
; destroys: ebx, ecx, edx, esi, edi
;
; local variables:
;	[ebp-4] -> y$ if .vs or .ss routine (if need to free y$ on exit)
;	[ebp-8] -> result string
;	[ebp-12] = start offset (i.e. zero-biased start position)
;
; Creation of result string happens in three phases, after all checking
; for errors and null pointers is done:
;
;    1.  Copy MIN(LEN(x$), start_offset) chars from x$ to result.
;
;    2.  Copy MIN(j, LEN(y$), LEN(x$) - start_offset) chars from y$ to result.
;
;    3.  Copy remaining chars from x$ to result, so result has same length
;	 as x$.
;
%_stuff.d.vv:
	xor	ebx,ebx		;indicate no need to free y$ on exit
	or	eax,1		;eax != 0 to indicate x$ cannot be trashed
	jmp	short stuff.d.x
;
%_stuff.d.vs:
	mov	ebx,[esp+8]	;ebx -> y$; must free y$ on exit
	or	eax,1		;eax != 0 to indicate x$ cannot be trashed
	jmp	short stuff.d.x
;
%_stuff.d.sv:
	xor	ebx,ebx		;indicate no need to free y$ on exit
	xor	eax,eax		;eax == 0 to indicate result goes over x$
	jmp	short stuff.d.x
;
%_stuff.d.ss:
	mov	ebx,[esp+8]	;ebx -> y$; must free y$ on exit
	xor	eax,eax		;eax == 0 to indicate result goes over x$
;;
;; fall through
;;
stuff.d.x:
	push	ebp
	mov	ebp,esp
	sub	esp,12

	mov	[ebp-4],ebx	;save pointer to string to free on exit
	cld
	mov	edi,[ebp+8]	;edi -> x$ (string to stuff into)
	or	edi,edi		;null pointer?
	jz	stuff_null	;yes: return null pointer and free y$ if nec.
	mov	ecx,[edi-8]	;ecx = LEN(x$)

	mov	edx,[ebp+16]	;edx = start position (one-biased)
	dec	edx		;edx = start offset (i.e. zero-biased start pos)
	js	stuff_IFC	;starting before first char is absurd
	mov	[ebp-12],edx	;save start offset

	mov	[ebp-8],edi	;[ebp-8] -> result string if x$ is trashable
	or	eax,eax		;can we trash x$?
	jz	short stuff_begin ;yes: skip code to create new string
	lea	esi,[ecx+1]	;esi = LEN(x$) + 1 for null terminator
	call	%____calloc	;esi -> result string
	mov	eax,[_##WHOMASK]	;eax = system/user bit
	or	eax,0x80130001	;eax = info word for allocated string
	mov	[esi-4],eax	;store info word
	mov	[esi-8],ecx	;store length
	mov	[ebp-8],esi	;[ebp-8] -> result string

stuff_begin:
	mov	esi,[ebp+12]	;esi -> y$ (string to copy from)
	or	esi,esi		;y$ is null pointer?
	jz	short stuff_just_copy ;yes: result is same as x$

	mov	edi,[ebp-8]	;edi -> result string
	mov	edx,[edi-8]	;edx = length of result string ( = LEN(x$) )
	mov	ebx,[ebp-12]	;ebx = start offset

	mov	ecx,edx		;ecx = LEN(x$)
	xor	edx,edx		;edx = MAX(LEN(x$) - start offset, 0) if
				; LEN(x$) - start offset < 0
	cmp	ecx,ebx		;LEN(x$) < start offset?
	jb	short stuff_skip1 ;yes: copy only LEN(x$) chars in phase 1
	mov	edx,ecx
	sub	edx,ebx		;edx = LEN(x$) - start offset
	mov	ecx,ebx		;no: copy up to the start offset

stuff_skip1:
	mov	eax,[esi-8]	;eax = LEN(y$)
	cmp	[ebp+20],eax	;j < LEN(y$)?
	ja	short stuff_skip2 ;no: eax = LEN(y$) = MIN(j, LEN(y$))
	mov	eax,[ebp+20]	;eax = j = MIN(j, LEN(y$))

stuff_skip2:
	cmp	edx,eax		;LEN(x$) - start offset < MIN(j, LEN(y$))?
	ja	short stuff_skip3 ;no: eax = # of chars to copy in phase 2
	mov	eax,edx		;eax = LEN(x$) - start offset

stuff_skip3:
	lea	ebx,[ecx+eax]	;ebx = # of chars to copy in phases 1 and 2

	mov	edx,[edi-8]	;edx = length of result string
	sub	edx,ecx		;...minus # of chars to copy in phase 1
	mov	esi,[ebp+8]	;esi -> x$
	rep
	movsb			;copy chars for phase 1

	mov	ecx,eax		;ecx = # of chars to copy in phase 2
	sub	edx,eax		;edx = # of chars to copy in phase 3
	mov	esi,[ebp+12]	;esi -> y$
	rep
	movsb			;copy chars for phase 2

	mov	ecx,edx		;ecx = # of chars to copy in phase 3
	mov	esi,[ebp+8]	;esi -> x$
	add	esi,ebx		;esi -> 1st char to copy for phase 3
	rep
	movsb			;copy chars for phase 3

	mov	byte ptr [edi],0 ;write null terminator

stuff_exit:
	mov	esi,[ebp-4]	;esi = string to free on exit, if any
	call	%____free
	mov	eax,[ebp-8]	;eax -> result string
	mov	esp,ebp
	pop	ebp
	ret

stuff_just_copy:		;result will be exactly the same as x$
	mov	edi,[ebp-8]	;edi -> result string
	mov	esi,[ebp+8]	;esi -> x$
	cmp	edi,esi		;result string is x$?
	je	stuff_exit	;yes: then copy is already made

	mov	ecx,[esi-8]	;ecx = LEN(x$)
	rep
	movsb			;copy x$ to result string
	mov	byte ptr [edi],0 ;write null terminator
	jmp	stuff_exit
;
;
;
.text
.byte	"XBasic Assembly Library\n"
.byte	"Coral Reef Development, Ltd."
.byte	"Copyright 1988-1995"
;
; *******************************************************
; *****  TABLE TO CONVERT LOWER CASE TO UPPER CASE  *****
; *******************************************************
;
.text
.align	8
%_lctouc:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
	.byte	0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
	.byte	0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
	.byte	0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27
	.byte	0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F
	.byte	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
	.byte	0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F
	.byte	0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47
	.byte	0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F
	.byte	0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57
	.byte	0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F
	.byte	0x60, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47
	.byte	0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F
	.byte	0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57
	.byte	0x58, 0x59, 0x5A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F
	.byte	0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87
	.byte	0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F
	.byte	0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97
	.byte	0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F
	.byte	0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7
	.byte	0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF
	.byte	0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7
	.byte	0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF
	.byte	0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7
	.byte	0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF
	.byte	0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7
	.byte	0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF
	.byte	0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7
	.byte	0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF
	.byte	0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7
	.byte	0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
;
; *******************************************************
; *****  TABLE TO CONVERT UPPER CASE TO LOWER CASE  *****
; *******************************************************
;
.text
.align	8
%_uctolc:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
	.byte	0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
	.byte	0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
	.byte	0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27
	.byte	0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F
	.byte	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
	.byte	0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F
	.byte	0x40, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67
	.byte	0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F
	.byte	0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77
	.byte	0x78, 0x79, 0x7A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F
	.byte	0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67
	.byte	0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F
	.byte	0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77
	.byte	0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F
	.byte	0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87
	.byte	0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F
	.byte	0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97
	.byte	0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F
	.byte	0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7
	.byte	0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF
	.byte	0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7
	.byte	0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF
	.byte	0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7
	.byte	0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF
	.byte	0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7
	.byte	0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF
	.byte	0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7
	.byte	0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF
	.byte	0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7
	.byte	0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
;
;
;
;
;
; ############################################
; ############################################
; #####  DATA  #####  DATA  #####  DATA  #####  .data section
; ############################################
; ############################################
;
.data
.align	8
.globl	xxxPointers
.globl	_XxxPointers
;
; #####################
; #####  xitinit  #####
; #####################
;
%dbase:
%pointers:
xxxPointers:
_XxxPointers:
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;  16, 32, 48, 64  ... 240, 256
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;  512, 1K, 2K, 4K, 8K, 16K, 32K, 64K,  128K, 256K, 512K, 1M, 2M, 4M, 8M, 16M
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;  32M, 64M, 128M, 256M, 512M, 1G, 2G, 4G,  8G, 16G, 32G, 64G, 128G, 256G, 512G
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;  ...
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
;
.align	8
%initoid:
.dword	0, 0, 0, 0, 0, 0, 0, 0
;
.align	8
%messageBuffer:
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;  for XxxCheckMessages()
;
.align	8
%pdeString:
.byte "XBasic v6.0002"
;
.align	8
%noFreeTest:
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
;
; local to this file
;
.align	8
%arg0:	.dword	0
%arg1:	.dword	0
%arg2:	.dword	0
%arg3:	.dword	0
%arg4:	.dword	0
%arg5:	.dword	0
%arg6:	.dword	0
%arg7:	.dword	0
%arg8:	.dword	0
%arg9:	.dword	0
%temp0:	.dword	0
%temp1:	.dword	0
%temp2:	.dword	0
%temp3:	.dword	0
%temp4:	.dword	0
%temp5:	.dword	0
;
.align	8
debugFile:
.byte	"win32s.bug"
.zero	8
;
.align	8
debugHandle:
.zero	8
;
.align	8
bytesWritten:
.zero	8
;
.align	8
Rmsg:				; Rmsg LEN (68) goes into above WriteFile
.byte	"\%_RuntimeError ##TRAP = %d ##ERROR = 0x%08X address = 0x%08X\n\0"
;
.align	8
txtBuffer:
whereBuffer:
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
.dword	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	;
;
;
;
; ####################
; #####  xlibnn  #####
; ####################
;
.align	8
workbyte:
.byte	0xAB
;
.align	8
workword:
.word	0xABCD
;
.align	8
workword2:
.word	0xEF01
;
.align	8
workdword:
.dword	0xBADBEEF
;
.align	8
workqword:
.dword	0x98765432, 0xFEDCBA98
;
.align	8
control_bits:		.word	0	;temporary FPU control bits
;
.align	8
orig_control_bits:	.word	0	;on-entry control bits
;
;
; ####################
; #####  xlibns  #####
; ####################
;
.data
.align	8
search_tab:			; lookup table for INCHR() and INCHRI()
.zero	256			; see INCHRI() header comment)
;
;
; ####################
; #####  xlibsn  #####
; ####################
;
.data
.align	8
sn_save:			; temporary spot that's not on the stack
	.dword	0
;
.data
.align	8
oct_shift:			; currently selected shift table
	.dword	oct_lsd_64
;
.data
.align	8
oct_first:			; add this to first digit of octal string
	.dword	0
;
.data
.align	8
fdebug:	.dword	0,0,0,0		; DEBUG (often ends up with status word to check floating stack pointer
;
;
;
; #################
; #####  END  #####  xlibasm.s
; #################
;
