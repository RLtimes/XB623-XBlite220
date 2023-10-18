#
#
# ####################  Max Reason
# #####  xlib.s  #####  copyright 1988-2000
# ####################  Linux XBasic assembly language
#
# subject to LGPL license - see COPYING_LIB
#
# maxresaon@maxreason.com
#
# for Linux XBasic
#
#
# PROGRAM "xlib"    ' fake PROGRAM statement - name this library
# VERSION "0.0110"  ' fake VERSION statement - keep version updated
#
#
# #######################################  Mostly assembly language source code
# #####  Assembly Language Library  #####  for XBasic language intrinsics like
# #######################################  ABS(), LEFT$(), MID$(), TRIM$(), etc
#
# This file contains assembly language routines for many purposes, including:
#   1. Startup initialization - XxxMain is called by xinit.s or app at startup
#   2. Error handling - handle "jmp %eeeErrorName" in XBasic source programs
#   3. Dynamic memory management - malloc, calloc, recalloc, free, etc...
#   4. Array management - DimArray, RedimArray, FreeArray
#   5. Intrinsic functions - ABS(), BIN$(), CHR$(), etc...
#   6. General support routines, especially for program development environment
#
# To create the program development environment, this file is assembled into
# object file "xlib.o" which is linked to, and becomes part of, the program
# development environment - aka PDE.  The global variables in xlib.s are
# therefore in the PDE executable file, and are read in by the PDE when it
# starts up.  The addresses of all xlib.s routines are therefore available
# to the compiler and calls to xlib.s routines in user programs are resolved
# without difficulty.
#
# External variables are not shared in the same manner in both cases.
# External variables are shared by all programs linked into a single
# executable (.DLL or .EXE).  External variables in the PDE and user
# programs are not shared with .DLL libraries.  So function libraries
# developed in the PDE should not contain external variables - at least
# not external variables meant to be shared by programs or other function
# libraries that use the .DLL as a .DLL.  External variables are only
# shared with programs linked into a single .EXE or .DLL.
#
#
#
#
# ############################################
# ############################################
# #####  DATA  #####  DATA  #####  DATA  #####  .data section
# ############################################
# ############################################
#
.data
.align	8
.globl	xxxPointers
#
_dbase:
_pointers:
xxxPointers:
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#  16, 32, 48, 64  ... 240, 256
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#  512, 1K, 2K, 4K, 8K, 16K, 32K, 64K,  128K, 256K, 512K, 1M, 2M, 4M, 8M, 16M
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#  32M, 64M, 128M, 256M, 512M, 1G, 2G, 4G,  8G, 16G, 32G, 64G, 128G, 256G, 512G
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#  ...
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
#
.align	8
_messageBuffer:
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#  for XxxCheckMessages()
#
.align	8
_noFreeTest:
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
#
# local to this file
#
.align	8
.globl	_argc
_argc:	.long	0
_argv:	.long	0
_envp:	.long	0
_envx:	.long	0
_arg4:	.long	0
_arg5:	.long	0
_arg6:	.long	0
_arg7:	.long	0
_arg8:	.long	0
_arg9:	.long	0
_arg10:	.long	0
_arg11:	.long	0
_arg12:	.long	0
_arg13:	.long	0
_arg14:	.long	0
_arg15:	.long	0
_temp0:	.long	0
_temp1:	.long	0
_temp2:	.long	0
_temp3:	.long	0
_temp4:	.long	0
_temp5:	.long	0
#
.align	8
debugFile:
.string	"win32s.bug"
.zero	8
#
.align	8
debugHandle:
.zero	8
#
.align	8
bytesWritten:
.zero	8
#
.align	8
Rmsg:				# Rmsg LEN (68) goes into above WriteFile
.string	"\__RuntimeError __TRAP = _d __ERROR = 0x_08X address = 0x_08X\n\0"
#
.align	8
txtBuffer:
whereBuffer:
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
.long	0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0	#
#
#
#
.align	8
workbyte:
.byte	0xAB
#
.align	8
workword:
.word	0xABCD
#
.align	8
workword2:
.word	0xEF01
#
.align	8
workdword:
.long	0xBADBEEF
#
.align	8
workqword:
.long	0x98765432, 0xFEDCBA98
#
.align	8
control_bits:		.word	0	#temporary FPU control bits
#
.align	8
orig_control_bits:	.word	0	#on-entry control bits
#
#
#
.data
.align	8
search_tab:			# lookup table for INCHR() and INCHRI()
.zero	256			# see INCHRI() header comment)
#
#
#
.data
.align	8
sn_save:			# temporary spot that's not on the stack
.long	0
#
.data
.align	8
oct_shift:			# currently selected shift table
.long	oct_lsd_64
#
.data
.align	8
oct_first:			# add this to first digit of octal string
.long	0, 0
#
.data
.align	8
.globl	debug
.globl	debug0
.globl	fdebug0
fdebug0:	.long	0,0,0,0
fdebug1:	.long	0,0,0,0
fdebug2:	.long	0,0,0,0
fdebug3:	.long	0,0,0,0
fdebug4:	.long	0,0,0,0
fdebug5:	.long	0,0,0,0
fdebug6:	.long	0,0,0,0
fdebug7:	.long	0,0,0,0
fdebug8:	.long	0,0,0,0
fdebug9:	.long	0,0,0,0
fdebugA:	.long	0,0,0,0
fdebugB:	.long	0,0,0,0
fdebugC:	.long	0,0,0,0
fdebugD:	.long	0,0,0,0
fdebugE:	.long	0,0,0,0
fdebugF:	.long	0,0,0,0
#
save_eax:	.long	0
save_ebx:	.long	0
save_ecx:	.long	0
save_edx:	.long	0
save_esi:	.long	0
save_edi:	.long	0
save_esp:	.long	0
save_ebp:	.long	0
debug:		.long	0
daddr:		.long	0
desp:		.long	0
debp:		.long	0
despaddr0:	.long	0
debpaddr0:	.long	0
despaddr4:	.long	0
debpaddr4:	.long	0
debug0:		.long	0
debug1:		.long	0
debug2:		.long	0
debug3:		.long	0
debug4:		.long	0
debug5:		.long	0
debug6:		.long	0
debug7:		.long	0
debug8:		.long	0
debug9:		.long	0
debugA:		.long	0
debugB:		.long	0
debugC:		.long	0
debugD:		.long	0
debugE:		.long	0
debugF:		.long	0
#
#
# ******************************
# ******************************
# *****  SYSTEM EXTERNALS  *****  persist on user task run/kill/run/kill...
# ******************************
# ******************************
#
.comm	__BEGIN,		4	# Beginning of externals
.comm	__XBASIC,		4	# ID label
.comm	__INEXIT,		4	# exit() in progress - no PRINTs
.comm	__CODE0,		4	# Xit code page base (first page)
.comm	__CODE,			4	# Xit code starts here
.comm	__CODEX,		4	# Xit code ends here (UNIX _etext)
.comm	__CODEZ,		4	# Xit code break address (last page)
.comm	__UCODE0,		4	# User code page base (first page)
.comm	__UCODE,		4	# User code starts here
.comm	__UCODEX,		4	# User code ends here
.comm	__UCODEZ,		4	# User code break address (last page)
.comm	__DATA0,		4	# Data page base (first page)
.comm	__DATA,			4	# Data starts
.comm	__DATAX,		4	# Data ends here
.comm	__DATAZ,		4	# Data page ends here (last page)
.comm	__BSS0,			4	# BSS page base (first page)
.comm	__BSS,			4	# BSS starts here
.comm	__BSSX,			4	# BSS ends here
.comm	__BSSZ,			4	# BSS page ends here (last page)
.comm	__DYNO0,		4	# Dyno page base
.comm	__DYNO,			4	# Dyno headers start here
.comm	__DYNOX,		4	# Dyno headers end here
.comm	__DYNOZ,		4	# Dyno page ends here
.comm	__UDYNO0,		4	# Dyno page base
.comm	__UDYNO,		4	# Dyno headers start here
.comm	__UDYNOX,		4	# Dyno headers end here
.comm	__UDYNOZ,		4	# Dyno page ends here
.comm	__STACK0,		4	# Stack page base (low page)
.comm	__STACK,		4	# Stack ???
.comm	__STACKX,		4	# Stack ???
.comm	__STACKZ,		4	# Stack entry page end (high page)
.comm	__GLOBAL0,		4	# External block starts here
.comm	__GLOBAL,		4	# External block after system
.comm	__GLOBALX,		4	# External block next available
.comm	__GLOBALZ,		4	# External block after
.comm	__ERROR,		4	# __ERROR	(XBasic error number)
.comm	__ARGC,			4	# __ARGC	(_ elements in __ARGV$[])
.comm	___ARGV$,		4	# __ARGV$[]	(argument strings)
.comm	___ENVP$,		4	# __ENVP$[]	(environment strings)
.comm	___OSERROR$,		4	# __OSERROR$[]	(operating-system error strings)
.comm	___ALARMREG,		4	# __ALARMREG[]	(alarm registers, Xit FRAMES)
.comm	___SYSREG,		4	# __SYSREG[]	(Xit machine registers)
.comm	___REG,			4	# __REG[]	(machine registers)
.comm	__LOCKOUT,		4	# __LOCKOUT	(within a system call)
.comm	__WAITING,		4	# __WAITING	(waiting in XNextEvent() for event)
.comm	__SLEEPING,		4	# __SLEEPING	(waiting for timer or other exception)
.comm	__USERWAITING,		4	# __USERWAITING	(waiting for ^Q to undo ^S)
.comm	__BREAKOUT,		4	# __BREAKOUT	(break out of event/message loop)
.comm	__EXCEPTION,		4	# __EXCEPTION
.comm	__OSEXCEPTION,		4	# __OSEXCEPTION
.comm	__SIGNALACTIVE,		4	# __SIGNALACTIVE	(Xit)
.comm	__WALKBASE,		4	# __WALKBASE
.comm	__XWALKBASE,		4	# __XWALKBASE
.comm	__WALKOFFSET,		4	# __WALKOFFSET
.comm	__XWALKOFFSET,		4	# __XWALKOFFSET
.comm	__TABSAT,		4	# __TABSAT	(tabs set every n columns)
.comm	__WHOMASK,		4	# __WHOMASK	(allocation owner, info word)
.comm	__SOFTBREAK,		4	# __SOFTBREAK		(all XBasic SYSTEMCALLs)
.comm	__USERRUNNING,		4	# __USERRUNNING
.comm	__BEGINALLOCODE,	4	# __BEGINALLOCODE	(XitMain(), xlib0.s)
.comm	__ENDALLOCODE,		4	# __ENDALLOCODE		(XitMain(), xliba.s)
.comm	__TRAPVECTOR,		4	# __TRAPVECTOR
.comm	__ENTERED,		4	# __ENTERED
.comm	__ALARMWALKER,		4	# __ALARMWALKER		(alarm walkoffset, Xit FRAMES)
.comm	__ALARMLOOP,		4	# __ALARMLOOP		(alarm loop addr, Xit FRAMES)
.comm	__ALARMTIME,		4	# __ALARMTIME		(alarm time interval)
.comm	__ALARMBUSY,		4	# __ALARMBUSY
.comm	__HINSTANCE,		4	# __HINSTANCE - hInstance active
.comm	__HINSTANCEDLL,		4	# __HINSTANCEDLL - hInstance of .dll
.comm	__HINSTANCEEXE,		4	# __HINSTANCEEXE - hInstance of .exe
.comm	__HINSTANCESTART,	4	# __HINSTANCESTART - hInstance at .exe startup
.comm	__STANDALONE,		4	# __STANDALONE
.comm	__CONGRID,		4	# __CONGRID
.comm	__START,		4	# __START
.comm	__MAIN,			4	# __MAIN
.comm	__APP,			4	# __APP
.comm	__CPU,			4	# __CPU
.comm	__DEBUG,		4	# __DEBUG
.comm	__BLOWBACK,		4	# __BLOWBACK
#
# the following memory area - 64KB at %%externals - holds shared
# and external variables of programs compiled into memory by the PDE.
#
# DON'T CHANGE SIZE OF "__externals" without looking through code for trouble
#
.comm	__externals,		65536	# room for about 16000 variables
.comm	__externalz,		16	# end of user shared/external area
.comm	errno,			4	# C / system error variable
#
#
# #######################
# #####  CONSTANTS  #####  assembly language constants for this file
# #######################
#
# the following $$ErrorObject and $$ErrorNature constants need
# to be kept in sync with the constants in the standard library.
#
$$ErrorObjectNone                  = 0x0000
$$ErrorObjectData                  = 0x0100
$$ErrorObjectDisk                  = 0x0200
$$ErrorObjectFile                  = 0x0300
$$ErrorObjectFont                  = 0x0400
$$ErrorObjectGrid                  = 0x0500
$$ErrorObjectIcon                  = 0x0600
$$ErrorObjectName                  = 0x0700
$$ErrorObjectNode                  = 0x0800
$$ErrorObjectPipe                  = 0x0900
$$ErrorObjectUser                  = 0x0A00
$$ErrorObjectArray                 = 0x0B00
$$ErrorObjectImage                 = 0x0C00
$$ErrorObjectMedia                 = 0x0D00
$$ErrorObjectQueue                 = 0x0E00
$$ErrorObjectStack                 = 0x0F00
$$ErrorObjectTimer                 = 0x1000
$$ErrorObjectBuffer                = 0x1100
$$ErrorObjectCursor                = 0x1200
$$ErrorObjectDevice                = 0x1300
$$ErrorObjectDriver                = 0x1400
$$ErrorObjectMemory                = 0x1500
$$ErrorObjectSocket                = 0x1600
$$ErrorObjectString                = 0x1700
$$ErrorObjectSystem                = 0x1800
$$ErrorObjectThread                = 0x1900
$$ErrorObjectWindow                = 0x1A00
$$ErrorObjectCommand               = 0x1B00
$$ErrorObjectDisplay               = 0x1C00
$$ErrorObjectLibrary               = 0x1D00
$$ErrorObjectMessage               = 0x1E00
$$ErrorObjectNetwork               = 0x1F00
$$ErrorObjectPrinter               = 0x2000
$$ErrorObjectProcess               = 0x2100
$$ErrorObjectProgram               = 0x2200
$$ErrorObjectArgument              = 0x2300
$$ErrorObjectComputer              = 0x2400
$$ErrorObjectFunction              = 0x2500
$$ErrorObjectIdentity              = 0x2600
$$ErrorObjectPassword              = 0x2700
$$ErrorObjectClipboard             = 0x2800
$$ErrorObjectDirectory             = 0x2900
$$ErrorObjectSemaphore             = 0x2A00
$$ErrorObjectStatement             = 0x2B00
$$ErrorObjectSystemRoutine         = 0x2C00
$$ErrorObjectSystemFunction        = 0x2D00
$$ErrorObjectSystemResource        = 0x2E00
$$ErrorObjectOperatingSystem       = 0x2F00
$$ErrorObjectIntegerLogicUnit      = 0x3000
$$ErrorObjectFloatingPointUnit     = 0x3100
#
$$ErrorNatureNone                  = 0x0000
$$ErrorNatureBusy                  = 0x0001
$$ErrorNatureFull                  = 0x0002
$$ErrorNatureError                 = 0x0003
$$ErrorNatureEmpty                 = 0x0004
$$ErrorNatureReset                 = 0x0005
$$ErrorNatureExists                = 0x0006
$$ErrorNatureFailed                = 0x0007
$$ErrorNatureHalted                = 0x0008
$$ErrorNatureExpired               = 0x0009
$$ErrorNatureInvalid               = 0x000A
$$ErrorNatureMissing               = 0x000B
$$ErrorNatureTimeout               = 0x000C
$$ErrorNatureTooMany               = 0x000D
$$ErrorNatureUnknown               = 0x000E
$$ErrorNatureBreakKey              = 0x000F
$$ErrorNatureDeadlock              = 0x0010
$$ErrorNatureDisabled              = 0x0011
$$ErrorNatureNotEmpty              = 0x0012
$$ErrorNatureObsolete              = 0x0013
$$ErrorNatureOverflow              = 0x0014
$$ErrorNatureTooLarge              = 0x0015
$$ErrorNatureTooSmall              = 0x0016
$$ErrorNatureAbandoned             = 0x0017
$$ErrorNatureAvailable             = 0x0018
$$ErrorNatureDuplicate             = 0x0019
$$ErrorNatureExhausted             = 0x001A
$$ErrorNaturePrivilege             = 0x001B
$$ErrorNatureUndefined             = 0x001C
$$ErrorNatureUnderflow             = 0x001D
$$ErrorNatureAllocation            = 0x001E
$$ErrorNatureBreakpoint            = 0x001F
$$ErrorNatureContention            = 0x0020
$$ErrorNaturePermission            = 0x0021
$$ErrorNatureTerminated            = 0x0022
$$ErrorNatureUndeclared            = 0x0023
$$ErrorNatureUnexpected            = 0x0024
$$ErrorNatureWouldBlock            = 0x0025
$$ErrorNatureInterrupted           = 0x0026
$$ErrorNatureMalfunction           = 0x0027
$$ErrorNatureNonexistent           = 0x0028
$$ErrorNatureUnavailable           = 0x0029
$$ErrorNatureUnspecified           = 0x002A
$$ErrorNatureDisconnected          = 0x002B
$$ErrorNatureDivideByZero          = 0x002C
$$ErrorNatureIncompatible          = 0x002D
$$ErrorNatureNotConnected          = 0x002E
$$ErrorNatureLimitExceeded         = 0x002F
$$ErrorNatureNotInitialized        = 0x0030
$$ErrorNatureHigherDimension       = 0x0031
$$ErrorNatureLowestDimension       = 0x0032
$$ErrorNatureCannotInitialize      = 0x0033
$$ErrorNatureInitializeFailed      = 0x0034
$$ErrorNatureAlreadyInitialized    = 0x0035
$$ErrorNatureInvalidAccess         = 0x0036
$$ErrorNatureInvalidAddress        = 0x0037
$$ErrorNatureInvalidAlignment      = 0x0038
$$ErrorNatureInvalidArgument       = 0x0039
$$ErrorNatureInvalidCheck          = 0x003A
$$ErrorNatureInvalidCoordinates    = 0x003B
$$ErrorNatureInvalidCommand        = 0x003C
$$ErrorNatureInvalidData           = 0x003D
$$ErrorNatureInvalidDimension      = 0x003E
$$ErrorNatureInvalidEntry          = 0x003F
$$ErrorNatureInvalidFormat         = 0x0040
$$ErrorNatureInvalidKind           = 0x0041
$$ErrorNatureInvalidIdentity       = 0x0042
$$ErrorNatureInvalidInstruction    = 0x0043
$$ErrorNatureInvalidLocation       = 0x0044
$$ErrorNatureInvalidMessage        = 0x0045
$$ErrorNatureInvalidName           = 0x0046
$$ErrorNatureInvalidNode           = 0x0047
$$ErrorNatureInvalidNumber         = 0x0048
$$ErrorNatureInvalidOperand        = 0x0049
$$ErrorNatureInvalidOperation      = 0x004A
$$ErrorNatureInvalidReply          = 0x004B
$$ErrorNatureInvalidRequest        = 0x004C
$$ErrorNatureInvalidResult         = 0x004D
$$ErrorNatureInvalidSelection      = 0x004E
$$ErrorNatureInvalidSignature      = 0x004F
$$ErrorNatureInvalidSize           = 0x0050
$$ErrorNatureInvalidType           = 0x0051
$$ErrorNatureInvalidValue          = 0x0052
$$ErrorNatureInvalidVersion        = 0x0053
$$ErrorNatureInvalidDistribution   = 0x0054
#
$$ErrorOperatingSystem             = 0x2E00
$$ErrorMemoryAllocation            = 0x151D
$$ErrorInvalidFunctionCall         = 0x2431
$$ErrorOverflow                    = 0x0013
$$ErrorOutOfBounds                 = 0x0B37
$$ErrorAttachNeedsNullNode         = 0x0B11
$$ErrorUnexpectedHigherDimension   = 0x0B2C
$$ErrorUnexpectedLowestDimension   = 0x0B2D
#
SECTION_QUERY                      = 0x00000001
SECTION_MAP_WRITE                  = 0x00000002
SECTION_MAP_READ                   = 0x00000004
SECTION_MAP_EXECUTE                = 0x00000008
SECTION_EXTEND_SIZE                = 0x00000010
#
PAGE_NOACCESS                      = 0x00000001
PAGE_READONLY                      = 0x00000002
PAGE_READWRITE                     = 0x00000004
MEM_COMMIT                         = 0x00001000
MEM_RESERVE                        = 0x00002000
MEM_DECOMMIT                       = 0x00004000
MEM_RELEASE                        = 0x00008000
MEM_FREE                           = 0x00010000
MEM_PRIVATE                        = 0x00020000
#
#
.text
#
# #######################
# #####  xitinit.s  #####  Initialization code and miscellaneous stuff
# #######################
#
.globl	XxxMain
.globl	XxxG_0
.globl	XxxGuessWho_0
.globl	XxxGetEbpEsp_8
.globl	XxxSetEbpEsp_8
.globl	XxxGetFrameAddr_0
.globl	XxxSetFrameAddr_4
.globl	XxxGetExceptions_8
.globl	XxxSetExceptions_8
.globl	XxxGetImplementation_4
.globl	XxxRuntimeError
.globl	XxxRuntimeError2
.globl	XxxStartApplication_0
.globl	XxxFPUstatus_0
.globl	XxxEBPandESP_0
.globl	XxxFCLEX_0
.globl	XxxFINIT_0
.globl	XxxFSTCW_0
.globl	XxxFSTSW_0
.globl	XxxFLDZ_0
.globl	XxxFLD1_0
.globl	XxxFLDPI_0
.globl	XxxFLDL2E_0
.globl	XxxFLDL2T_0
.globl	XxxFLDLG2_0
.globl	XxxFLDLN2_0
.globl	XxxF2XM1_8
.globl	XxxFABS_8
.globl	XxxFCHS_8
.globl	XxxFCOS_8
.globl	XxxFPATAN_16
.globl	XxxFPREM_16
.globl	XxxFPREM1_16
.globl	XxxFPTAN_16
.globl	XxxFRNDINT_8
.globl	XxxFSCALE_16
.globl	XxxFSIN_8
.globl	XxxFSINCOS_16
.globl	XxxFSQRT_8
.globl	XxxFXTRACT_16
.globl	XxxFYL2X_16
.globl	XxxFYL2XP1_16
.globl	XxxFETOX_8
.globl	XxxFTENTOX_8
.globl	XxxFYTOX_16
.globl	SIN_8
.globl	COS_8
.globl	TAN_8
.globl	ATAN_8
.globl	SQRT_8
.globl	EXP_8
.globl	EXPE_8
.globl	EXP2_8
.globl	EXP10_8
.globl	EXPX_16
.globl	POWER_16
.globl	__ZeroMemory
.globl	__eeeAllocation
.globl	__eeeIllegalFunctionCall
.globl	__eeeInternal
.globl	__eeeOverflow
.globl	__eeeErrorNT
.globl	__OutOfBounds
.globl	__NeedNullNode
.globl	__UnexpectedLowestDim
.globl	__UnexpectedHigherDim
.globl	__RuntimeError
#
#
# #####################
# #####  xlib0.s  #####  Memory-allocation routines
# #####################
#
.globl	malloc
.globl	_malloc
.globl	__malloc
.globl	Xmalloc
.globl	_____malloc
.globl	______malloc
.globl	realloc
.globl	_realloc
.globl	__realloc
.globl	Xrealloc
.globl	_____realloc
.globl	______realloc
.globl	cfree
.globl	_cfree
.globl	free
.globl	_free
.globl	__free
.globl	Xfree
.globl	_____free
.globl	______free
.globl	calloc
.globl	_calloc
.globl	__calloc
.globl	Xcalloc
.globl	_____calloc
.globl	______calloc
.globl	recalloc
.globl	_recalloc
.globl	__recalloc
.globl	Xrecalloc
.globl	_____recalloc
#.globl	%_____recalloc
.globl	__beginAlloCode
#
#
# #####################
# #####  xlib1.s  #####  Clone and concatenate routines
# #####################
#
.globl	__clone.a0
.globl	__clone.a1
#
.globl	__concat.ubyte.a0.eq.a0.plus.a1.vv
.globl	__concat.ubyte.a0.eq.a0.plus.a1.vs
.globl	__concat.ubyte.a0.eq.a0.plus.a1.sv
.globl	__concat.ubyte.a0.eq.a0.plus.a1.ss
.globl	__concat.ubyte.a0.eq.a1.plus.a0.vv
.globl	__concat.ubyte.a0.eq.a1.plus.a0.vs
.globl	__concat.ubyte.a0.eq.a1.plus.a0.sv
.globl	__concat.ubyte.a0.eq.a1.plus.a0.ss
#
# the following are alternate names for the above
#
.globl	__concat.string.a0.eq.a0.plus.a1.vv
.globl	__concat.string.a0.eq.a0.plus.a1.vs
.globl	__concat.string.a0.eq.a0.plus.a1.sv
.globl	__concat.string.a0.eq.a0.plus.a1.ss
.globl	__concat.string.a0.eq.a1.plus.a0.vv
.globl	__concat.string.a0.eq.a1.plus.a0.vs
.globl	__concat.string.a0.eq.a1.plus.a0.sv
.globl	__concat.string.a0.eq.a1.plus.a0.ss
#
#
# #####################
# #####  xliba.s  #####  Low-level array processing routines
# #####################
#
.globl	__DimArray
.globl	__FreeArray
.globl	__RedimArray
.globl	XxxSwapMemory_12
.globl	__assignComposite
.globl	__AssignComposite
.globl	__assignCompositeString.v	# fill extra bytes with 0x20
.globl	__assignCompositeString.s	# fill extra bytes with 0x20
.globl	__assignCompositeStringlet.v	# fill extra bytes with 0x00
.globl	__assignCompositeStringlet.s	# fill extra bytes with 0x00
.globl	__VarargArrays
.globl	__endAlloCode
#
#
# #####################
# #####  xlibp.s  #####  XstStringToNumber ()
# #####################
#
.globl	XstStringToNumber_24
#
#
# #####################
# #####  xlibs.s  #####  String and PRINT routines
# #####################
#
.globl	__space.string
.globl	__newline.string
#
.globl	__print.console.newline
.globl	__print.tab.a0.eq.a0.tab.a1
.globl	__print.tab.a0.eq.a1.tab.a0
.globl	__print.tab.a0.eq.a0.tab.a1.ss
.globl	__print.tab.a0.eq.a1.tab.a0.ss
.globl	__print.first.spaces.a0
.globl	__print.tab.first.a0
.globl	__print.tab.first.a1
#
.globl	__Print
.globl	__PrintConsoleNewline
.globl	__PrintFileNewline
.globl	__PrintThenFree
.globl	__PrintWithNewlineThenFree
.globl	__PrintAppendComma
.globl	__PrintFirstComma
.globl	__PrintAppendSpaces
#
.globl	__string.compare.vv
.globl	__string.compare.vs
.globl	__string.compare.sv
.globl	__string.compare.ss
#
.globl	XstFindMemoryMatch_20
.globl	__CompositeStringToString
.globl	__ByteMakeCopy
.globl	__Read
.globl	__Write
.globl	__ReadArray
.globl	__WriteArray
.globl	__ReadString
.globl	__WriteString
#
.globl	__close
.globl	__eof
.globl	__pof
.globl	__lof
.globl	__quit
.globl	__infile_d
.globl	__inline_d.s
.globl	__inline_d.v
.globl	__open.s
.globl	__open.v
.globl	__seek
.globl	__shell.s
.globl	__shell.v
#
#
# ######################
# #####  xlibnn.s  #####  numeric-to-numeric conversions and intrinsics
# ######################
#
.globl	__cv.slong.to.sbyte
.globl	__cv.slong.to.ubyte
.globl	__cv.slong.to.sshort
.globl	__cv.slong.to.ushort
.globl	__cv.slong.to.slong
.globl	__cv.slong.to.ulong
.globl	__cv.slong.to.xlong
.globl	__cv.slong.to.giant
.globl	__cv.slong.to.single
.globl	__cv.slong.to.double
#
.globl	__cv.ulong.to.sbyte
.globl	__cv.ulong.to.ubyte
.globl	__cv.ulong.to.sshort
.globl	__cv.ulong.to.ushort
.globl	__cv.ulong.to.slong
.globl	__cv.ulong.to.ulong
.globl	__cv.ulong.to.xlong
.globl	__cv.ulong.to.giant
.globl	__cv.ulong.to.single
.globl	__cv.ulong.to.double
#
.globl	__cv.xlong.to.sbyte
.globl	__cv.xlong.to.ubyte
.globl	__cv.xlong.to.sshort
.globl	__cv.xlong.to.ushort
.globl	__cv.xlong.to.slong
.globl	__cv.xlong.to.ulong
.globl	__cv.xlong.to.xlong
.globl	__cv.xlong.to.giant
.globl	__cv.xlong.to.single
.globl	__cv.xlong.to.double
#
.globl	__cv.giant.to.sbyte
.globl	__cv.giant.to.ubyte
.globl	__cv.giant.to.sshort
.globl	__cv.giant.to.ushort
.globl	__cv.giant.to.slong
.globl	__cv.giant.to.ulong
.globl	__cv.giant.to.xlong
.globl	__cv.giant.to.giant
.globl	__cv.giant.to.single
.globl	__cv.giant.to.double
#
.globl	__cv.single.to.sbyte
.globl	__cv.single.to.ubyte
.globl	__cv.single.to.sshort
.globl	__cv.single.to.ushort
.globl	__cv.single.to.slong
.globl	__cv.single.to.ulong
.globl	__cv.single.to.xlong
.globl	__cv.single.to.giant
.globl	__cv.single.to.single
.globl	__cv.single.to.double
#
.globl	__cv.double.to.sbyte
.globl	__cv.double.to.ubyte
.globl	__cv.double.to.sshort
.globl	__cv.double.to.ushort
.globl	__cv.double.to.slong
.globl	__cv.double.to.ulong
.globl	__cv.double.to.xlong
.globl	__cv.double.to.giant
.globl	__cv.double.to.single
.globl	__cv.double.to.double
#
.globl	__cv.giant.to.single
.globl	__cv.giant.to.double
.globl	__cv.single.to.giant
.globl	__cv.double.to.giant
#
.globl	__cv.xlong.to.subaddr
.globl	__cv.xlong.to.goaddr
.globl	__cv.xlong.to.funcaddr
#
.globl	__add.GIANT
.globl	__sub.GIANT
.globl	__mul.GIANT
.globl	__div.GIANT
.globl	__mod.GIANT
#
.globl	__lshift.giant
.globl	__ushift.giant
.globl	__rshift.giant
.globl	__dshift.giant
#
.globl	__high0
.globl	__high1
.globl	__high0.giant
.globl	__high1.giant
#
.globl	__abs.xlong
.globl	__abs.slong
.globl	__abs.ulong
.globl	__abs.giant
.globl	__abs.single
.globl	__abs.double
#
.globl	__sgn.xlong
.globl	__sgn.slong
.globl	__sgn.ulong
.globl	__sgn.giant
.globl	__sgn.single
.globl	__sgn.double
#
.globl	__sign.xlong
.globl	__sign.slong
.globl	__sign.ulong
.globl	__sign.giant
.globl	__sign.single
.globl	__sign.double
#
.globl	__int.single
.globl	__int.double
.globl	__fix.single
.globl	__fix.double
#
.globl	__MAX.slong
.globl	__MAX.ulong
.globl	__MAX.xlong
.globl	__MAX.single
.globl	__MAX.double
.globl	__MIN.slong
.globl	__MIN.ulong
.globl	__MIN.xlong
.globl	__MIN.single
.globl	__MIN.double
#
.globl	__add.SCOMPLEX
.globl	__sub.SCOMPLEX
.globl	__mul.SCOMPLEX
.globl	__div.SCOMPLEX
.globl	__add.DCOMPLEX
.globl	__sub.DCOMPLEX
.globl	__mul.DCOMPLEX
.globl	__div.DCOMPLEX
#
.globl	__power.slong
.globl	__rpower.slong
.globl	__power.ulong
.globl	__rpower.ulong
.globl	__power.xlong
.globl	__rpower.xlong
.globl	__power.giant
.globl	__rpower.giant
.globl	__power.single
.globl	__rpower.single
.globl	__power.double
.globl	__rpower.double
#
.globl	__extu.2arg
.globl	__extu.3arg
.globl	__ext.2arg
.globl	__ext.3arg
.globl	__set.2arg
.globl	__set.3arg
.globl	__clr.2arg
.globl	__clr.3arg
.globl	__make.2arg
.globl	__make.3arg
#
.globl	__error
#
#
# ######################
# #####  xlibns.s  #####  intrinsics that accept a string and return a number
# ######################
#
.globl	__len.v
.globl	__len.s
.globl	__size.v
.globl	__size.s
.globl	__csize.v
.globl	__csize.s
.globl	__asc.v
.globl	__asc.s
.globl	__inchr.vv
.globl	__inchr.sv
.globl	__inchr.vs
.globl	__inchr.ss
.globl	__inchri.vv
.globl	__inchri.sv
.globl	__inchri.vs
.globl	__inchri.ss
.globl	__rinchr.vv
.globl	__rinchr.sv
.globl	__rinchr.vs
.globl	__rinchr.ss
.globl	__rinchri.vv
.globl	__rinchri.sv
.globl	__rinchri.vs
.globl	__rinchri.ss
.globl	__instr.vv
.globl	__instr.sv
.globl	__instr.vs
.globl	__instr.ss
.globl	__instri.vv
.globl	__instri.sv
.globl	__instri.vs
.globl	__instri.ss
.globl	__rinstr.vv
.globl	__rinstr.sv
.globl	__rinstr.vs
.globl	__rinstr.ss
.globl	__rinstri.vv
.globl	__rinstri.sv
.globl	__rinstri.vs
.globl	__rinstri.ss
.globl	__cv.string.to.sbyte.v
.globl	__cv.string.to.sbyte.s
.globl	__cv.string.to.ubyte.v
.globl	__cv.string.to.ubyte.s
.globl	__cv.string.to.sshort.v
.globl	__cv.string.to.sshort.s
.globl	__cv.string.to.ushort.v
.globl	__cv.string.to.ushort.s
.globl	__cv.string.to.slong.v
.globl	__cv.string.to.slong.s
.globl	__cv.string.to.ulong.v
.globl	__cv.string.to.ulong.s
.globl	__cv.string.to.xlong.v
.globl	__cv.string.to.xlong.s
.globl	__cv.string.to.giant.v
.globl	__cv.string.to.giant.s
.globl	__cv.string.to.single.v
.globl	__cv.string.to.single.s
.globl	__cv.string.to.double.v
.globl	__cv.string.to.double.s
#
#
# ######################
# #####  xlibsn.s  #####  intrinsics that take numbers and return strings
# ######################
#
.globl	__chr.d
.globl	__bin.d
.globl	__binb.d
.globl	__bin.d.giant
.globl	__binb.d.giant
.globl	__hex.d
.globl	__hexx.d
.globl	__hex.d.giant
.globl	__hexx.d.giant
.globl	__oct.d
.globl	__octo.d
.globl	__oct.d.giant
.globl	__octo.d.giant
.globl	__null.d
.globl	__space.d
.globl	__cstring.d
.globl	__error.d
#
.globl	__signed.d.slong
.globl	__signed.d.ulong
.globl	__signed.d.xlong
.globl	__signed.d.goaddr
.globl	__signed.d.subaddr
.globl	__signed.d.funcaddr
.globl	__signed.d.giant
.globl	__signed.d.single			# LOOSE END: write in XBASIC
.globl	__signed.d.double			# LOOSE END: write in XBASIC
#
.globl	__str.d.slong
.globl	__str.d.ulong
.globl	__str.d.xlong
.globl	__str.d.goaddr
.globl	__str.d.subaddr
.globl	__str.d.funcaddr
.globl	__str.d.giant
.globl	__str.d.single				# LOOSE END: write in XBASIC
.globl	__str.d.double				# LOOSE END: write in XBASIC
#
.globl	__string.slong
.globl	__string.ulong
.globl	__string.xlong
.globl	__string.goaddr
.globl	__string.subaddr
.globl	__string.funcaddr
.globl	__string.giant
.globl	__string.single				# LOOSE END: write in XBASIC
.globl	__string.double				# LOOSE END: write in XBASIC
#
.globl	__string.d.slong
.globl	__string.d.ulong
.globl	__string.d.xlong
.globl	__string.d.goaddr
.globl	__string.d.subaddr
.globl	__string.d.funcaddr
.globl	__string.d.giant
.globl	__string.d.single			# LOOSE END: write in XBASIC
.globl	__string.d.double			# LOOSE END: write in XBASIC
#
#
# ######################
# #####  xlibss.s  #####  intrinsics that take strings and return strings
# ######################
#
.globl	__csize.d.v
.globl	__csize.d.s
#
.globl	__lcase.d.s
.globl	__lcase.d.v
.globl	__ucase.d.s
.globl	__ucase.d.v
#
.globl	__rjust.d.s
.globl	__rjust.d.v
.globl	__ljust.d.s
.globl	__ljust.d.v
.globl	__cjust.d.s
.globl	__cjust.d.v
#
.globl	__rclip.d.s
.globl	__rclip.d.v
.globl	__lclip.d.s
.globl	__lclip.d.v
#
.globl	__ltrim.d.v
.globl	__ltrim.d.s
.globl	__rtrim.d.v
.globl	__rtrim.d.s
.globl	__trim.d.v
.globl	__trim.d.s
#
.globl	__left.d.v
.globl	__left.d.s
.globl	__right.d.v
.globl	__right.d.s
.globl	__mid.d.v
.globl	__mid.d.s
#
.globl	__stuff.d.vv
.globl	__stuff.d.vs
.globl	__stuff.d.sv
.globl	__stuff.d.ss
#
.globl	__uctolc
.globl	__lctouc
#
#
#
#
# ############################################
# ############################################
# #####  CODE  #####  CODE  #####  CODE  #####
# ############################################
# ############################################
#
#
.text
.align	8
#
# #######################
# #####  xitinit.s  #####  Initialization routines
# #######################  Miscellaneous routines
#
#
# ########################  When any .EXE starts up, xstart.s passes
# #####  XxxMain ()  #####  8 important arguments here to XxxMain().
# ########################  The addresses below are after func entry.
#
# ebp + 36 = arg7 = 0x00000000 for PDE : &%_StartApplication for standalone
# ebp + 32 = arg6 = esp
# ebp + 28 = arg5 = ebp
# ebp + 24 = arg4 = ##CODE = &main() : in xx.s for PDE : in ustart.s for app
# ebp + 20 = arg3 = *envx[]
# ebp + 16 = arg2 = *envp[]
# ebp + 12 = arg1 = **argv[]
# ebp +  8 = arg0 = argc
#
XxxMain:
	pushl	%ebp	# standard function entry
	movl	%esp,%ebp	# standard function entry
	pushl	%ebx	# standard register saves
	pushl	%edi	# standard register saves
	pushl	%esi	# standard register saves
	movl	8(%ebp),%eax	# eax = argc
	movl	%eax,_argc	# store argc
	movl	12(%ebp),%eax	# eax = **argv[]
	movl	%eax,_argv	# store **argv[]
	movl	16(%ebp),%eax	# eax = *envp[]
	movl	%eax,_envp	# store *envp[]
	movl	20(%ebp),%eax	# eax = *envx[]		# ??? maybe ???
	movl	%eax,_envx	# store *envx[]
	movl	24(%ebp),%eax	# eax = &main()
	movl	%eax,_arg4	# store &main()
	movl	28(%ebp),%eax	# eax = &esp (entry)
	movl	%eax,_arg5	# store &esp (entry)
	movl	32(%ebp),%eax	# eax = &ebp (entry)
	movl	%eax,_arg6	# store &ebp (entry)
	movl	36(%ebp),%eax	# eax = 0x00000000 for PDE : &__StartApplication
	movl	%eax,_arg7	# store 0x00000000 for PDE : &__StartApplication
#;
	movl	__XBASIC,%eax	# eax = zero if initialization not done yet
	orl	%eax,%eax	# set flags
	jnz	initdone	# initialization done if __XBASIC != 0
	call	initmem	# allocate dyno memory, clear externals area
#;
#; *****  initialize fundamental system variables  *****
#;
initdone:
	movl	_argc,%eax	# eax = arg0 = argc
	movl	%eax,__ARGC	# __ARGC = arg0
#;
	movl	_arg4,%eax	#
	movl	%eax,__START	# __START = &WinMain()
	movl	$XxxMain,%eax	#
	movl	%eax,__MAIN	# __MAIN = &XxxMain()
	movl	_arg7,%eax	#
	movl	%eax,__APP	# __APP = 0x00000000 for PDE
#;				; ##APP = &%_StartApplication for standalone
#;
#; *****  initialize memory area constants  *****  (dyno area already done)
#;
	movl	_arg4,%eax	# WinMain is assumed to be lowest code address
	movl	%eax,__CODE	# __CODE = WinMain
	andl	$0xFFFFF000,%eax
	movl	%eax,__CODE0	# __CODE = WinMain & 0xFFFFF000
	movl	$_etext,%eax
	movl	%eax,__CODEX	# __CODEX = _etext
	addl	$0x1000,%eax
	andl	$0xFFFFF000,%eax	# __CODEZ = (_etext + 0x1000) & 0xFFFFF000
	movl	%eax,__CODEZ
	movl	$_dbase,%eax	# dbase is initialized memory base
	movl	%eax,__DATA	# __DATA = dbase
	andl	$0xFFFFF000,%eax
	movl	%eax,__DATA0	# __DATA0 = dbase & 0xFFFFF000
	movl	$_edata,%eax
	movl	%eax,__DATAX	# __DATAX = _edata
	addl	$0x0FFF,%eax
	andl	$0xFFFFF000,%eax
	movl	%eax,__DATAZ	# __DATAZ = (_edata + 0xFFF) & 0xFFFFF000
	movl	$__XBASIC,%eax	# assumed to be lowest bss address
	movl	%eax,__BSS	# __BSS = _ebss
	andl	$0xFFFFF000,%eax
	movl	%eax,__BSS0	# __BSS0 = _ebss & 0xFFFFF000
	movl	$_ebss,%eax
	movl	%eax,__BSSX	# __BSSX = _ebss
	addl	$0x0FFF,%eax
	andl	$0xFFFFF000,%eax
	movl	%eax,__BSSZ	# __BSSZ = (_ebss + 0x0FFF) + 0xFFFFF000
	movl	%esp,__STACK	# __STACK = esp
	leal	0x80(%esp),%eax
	movl	%esp,__STACKX	# __STACKX = esp + 0x80
	movl	%esp,%eax
	andl	$0xFFFFF000,%eax
	movl	%eax,__STACK0	# __STACK0 = esp & 0xFFFFF000
	leal	0x1000(%esp),%eax
	andl	$0xFFFFF000,%eax
	movl	%eax,__STACKZ	# __STACKZ = (esp + 0x1000) & 0xFFFFF000
#;
#; *****  miscellaneous initialization  *****
#;
	fnclex		# initialize math coprocessor
	xorl	%eax,%eax	# initialize system variables
	movl	$80386,__CPU	# __CPU = 80386
	movl	%eax,__ERROR	# __ERROR = 0
	movl	%eax,__WHOMASK	# __WHOMASK = 0
	movl	%eax,__SOFTBREAK	# __SOFTBREAK = 0
	movl	%eax,__USERRUNNING	# __USERRUNNING = 0
	movl	%eax,__SIGNALACTIVE	# __SIGNALACTIVE = 0
	movl	%eax,__LOCKOUT	# __LOCKOUT = 0
	movl	$__beginAlloCode,__BEGINALLOCODE	# init __BEGAINALLOCODE
	movl	$__endAlloCode,__ENDALLOCODE	# init __ENDALLOCODE
#;
	movl	$__externals,%eax	# get first address of user EXTERNAL area
	movl	%eax,%ebx		#
	addl	$65536,%ebx		# get  last address of user EXTERNAL area
	movl	%eax,__GLOBAL0	# first shared/external
	movl	%eax,__GLOBAL	# ditto
	movl	%eax,__GLOBALX	# ditto (increases during compile)
	movl	%ebx,__GLOBALZ	# last space for shared/external
	movl	$2,__TABSAT	# default tab setting is 2
	movl	$-1,__STANDALONE	# default is standalone code (not environment)
#;
#; *****  Create ##ARGV$[] array  *****
#;
	movl	__ARGC,%esi	# esi = __ARGC
	shll	$2,%esi		#esi = argc * 4 = _ of bytes in __ARGV$[]
	addl	$4,%esi		#room for null pointer as terminator marker
	call	_____calloc	# ntntnt  (found Ben error here and fixed)
	movl	%esi,___ARGV$	#save pointer to __ARGV$[] array
	movl	__WHOMASK,%eax	#eax = system/user int
	orl	$0x00080004,%eax	#info word = allocated array w/ 4 bytes per elem
	movl	%eax,-4(%esi)	#save __ARGV$[]'s info word
	movl	__ARGC,%ecx	# ecx = __ARGC
	movl	%ecx,-8(%esi)	#store number of elements of __ARGV$[]
	cld
	xorl	%ebx,%ebx	#ebx = argCounter = 0
#;
argv_loop:
	movl	_argv,%edx	#edx = entry **argv[]
	xorl	%eax,%eax	#prepare to search for null terminator
	movl	(%edx,%ebx,4),%edi	#edi = argv[argCounter]
	movl	%edi,%edx
	movl	$-1,%ecx	#search until find null or memory fault
	repnz
	scasb			#search for terminating null
	negl	%ecx		#ecx = strlen(argv[argCounter]), plus 1
#;			; for terminating null
	movl	%ecx,%esi	#esi = needed length
	call	_____calloc	#esi -> copy of argv[argCounter]
	movl	__WHOMASK,%eax	#eax = system/user int
	orl	$0x00130001,%eax	#info word = allocated string
	movl	%eax,-4(%esi)	#save string's info word
	leal	-2(%ecx),%eax	#eax = LEN(argv[argCounter])
	movl	%eax,-8(%esi)	#save length of string
	movl	%esi,%edi	#esi -> place to store copy of argv[argCounter]
	xchgl	%edx,%esi	#esi -> original, edx -> copy
	rep
	movsb			#copy argv[argCounter]
	movl	___ARGV$,%esi	#esi -> __ARGV$[] array
	movl	%edx,(%esi,%ebx,4)	#store pointer to copied string
	incl	%ebx		#bump argCounter
	cmpl	__ARGC,%ebx	#reached argc yet?
	jb	argv_loop	#nope: do another
#;
#; *****  Create ##ENVP$[] array  *****
#
	xorl	%esi,%esi	#esi = envCounter = 0
	movl	_envp,%eax	#eax = *envp[]
#;
envp_count_loop:
	movl	(%eax,%esi,4),%ebx	#ebx = envp[argCounter]
	orl	%ebx,%ebx	#null pointer?
	jz	envp_alloc	#yes: done counting
	incl	%esi		#bump argCounter
	jmp	envp_count_loop
#;
envp_alloc:
	movl	%esi,%ebx	#ebx = _ of environment variables
	shll	$3,%esi		#esi = 2 * space needed for array of pointers
	call	_____calloc	#esi -> __ENVP$[] array
	movl	%ebx,-8(%esi)	#store _ of elements
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x00080004,%eax	#eax = info word: alloc'ed array of 4-byte elems
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,___ENVP$
	xorl	%ebx,%ebx	#ebx = envCounter = 0
##
envp_loop:
	cmpl	-8(%esi),%ebx	#reached last environment variable?
	jz	envp_done	#yes
	movl	_envp,%edx	#edx = *envp[]
	xorl	%eax,%eax	#prepare to search for null terminator
	movl	(%edx,%ebx,4),%edi	#edi = envp[envCounter]
	movl	%edi,%edx
	movl	$-1,%ecx	#search until null or memory fault
##
	repnz
	scasb			#search for terminating null
	negl	%ecx		#ecx = LEN(envp[envCounter]), plus 1
##				# for terminating null
	movl	%ecx,%esi	#esi = needed length
	call	_____calloc	#esi -> place to put copy of env var
	movl	__WHOMASK,%eax	#eax = system/user int
	orl	$0x00130001,%eax	#info word = allocated string
	movl	%eax,-4(%esi)	#save string's info word
	leal	-2(%ecx),%eax	#eax = LEN(envp[envCounter])
	movl	%eax,-8(%esi)	#save length of string
	movl	%esi,%edi	#edi -> place to store copy of env var
	xchgl	%edx,%esi	#esi -> original, edx -> copy
	rep
	movsb		#copy envp[envCounter]
	movl	___ENVP$,%esi	#esi -> __ENVP$[] array
	movl	%edx,(%esi,%ebx,4)	#store pointer to copied string
	incl	%ebx	#bump envCounter
	jmp	envp_loop
envp_done:
#;
#;
#; ********************************************
#; *****  start debugger or user program  *****
#; ********************************************
#;
	pushl	_envp	# push entry argument 2 - envp
	pushl	_argv	# push entry argument 1 - argv
	pushl	_argc	# push entry argument 0 - argc
	call	XxxXit_12	# start debugger or user program
#;
#; *****  program execution complete : standard function exit code  *****
#;
	popl	%esi	# standard function exit
	popl	%edi	# ditto
	popl	%ebx	# ditto
	movl	%ebp,%esp	# ditto
	popl	%ebp	# ditto
	ret		# ditto
#
	call	exit	# alternate way to terminate program : eax = code
	ret		# exit() should never return
#
# machine visible copyright - this may not be removed
#
.align	8
.string "\n"
.string "Max Reason\n"
.string "copyright 1988-2000\n"
.string "Linux XBasic assembly language support\n"
.string "\n"
.string "\0"
.align	8
#
#
#
# *****  Clear out memory reserved for shared and external variables
# *****  Establish small dyno memory area for further expansion
#
.globl	initmem
initmem:
	pushl	%ebp	# standard function entry code
	movl	%esp,%ebp	# ditto
	pushl	%ebx	# ditto
	pushl	%edi	# ditto
	pushl	%esi	# ditto
#;
#
# all these have to be cleared individually because the stupid linkers
# people build today totally screw up the order of the addresses - the
# addresses of the following EXTERNAL variables are allocated all over
# the place, so for example, CODE0, CODE, CODEX, CODEZ are no where
# near each other.  Great, huh?  What a piece of "work"!
#
	xorl	%eax,%eax	# eax = 0
	movl	%eax,__BEGIN
	movl	%eax,__XBASIC
	movl	%eax,__INEXIT
	movl	%eax,__CODE0
	movl	%eax,__CODE
	movl	%eax,__CODEX
	movl	%eax,__CODEZ
	movl	%eax,__UCODE0
	movl	%eax,__UCODE
	movl	%eax,__UCODEX
	movl	%eax,__UCODEZ
	movl	%eax,__DATA0
	movl	%eax,__DATA
	movl	%eax,__DATAX
	movl	%eax,__DATAZ
	movl	%eax,__BSS0
	movl	%eax,__BSS
	movl	%eax,__BSSX
	movl	%eax,__BSSZ
	movl	%eax,__DYNO0
	movl	%eax,__DYNO
	movl	%eax,__DYNOX
	movl	%eax,__DYNOZ
	movl	%eax,__UDYNO0
	movl	%eax,__UDYNO
	movl	%eax,__UDYNOX
	movl	%eax,__UDYNOZ
	movl	%eax,__STACK0
	movl	%eax,__STACK
	movl	%eax,__STACKX
	movl	%eax,__STACKZ
	movl	%eax,__GLOBAL0
	movl	%eax,__GLOBAL
	movl	%eax,__GLOBALX
	movl	%eax,__GLOBALZ
	movl	%eax,__ERROR
	movl	%eax,__ARGC
	movl	%eax,___ARGV$
	movl	%eax,___ENVP$
	movl	%eax,___OSERROR$
	movl	%eax,___ALARMREG
	movl	%eax,___SYSREG
	movl	%eax,___REG
	movl	%eax,__LOCKOUT
	movl	%eax,__WAITING
	movl	%eax,__SLEEPING
	movl	%eax,__USERWAITING
	movl	%eax,__BREAKOUT
	movl	%eax,__EXCEPTION
	movl	%eax,__OSEXCEPTION
	movl	%eax,__SIGNALACTIVE
	movl	%eax,__WALKBASE
	movl	%eax,__XWALKBASE
	movl	%eax,__WALKOFFSET
	movl	%eax,__XWALKOFFSET
	movl	%eax,__TABSAT
	movl	%eax,__WHOMASK
	movl	%eax,__SOFTBREAK
	movl	%eax,__USERRUNNING
	movl	%eax,__BEGINALLOCODE
	movl	%eax,__ENDALLOCODE
	movl	%eax,__TRAPVECTOR
	movl	%eax,__ENTERED
	movl	%eax,__ALARMWALKER
	movl	%eax,__ALARMLOOP
	movl	%eax,__ALARMTIME
	movl	%eax,__ALARMBUSY
	movl	%eax,__HINSTANCE
	movl	%eax,__HINSTANCEDLL
	movl	%eax,__HINSTANCEEXE
	movl	%eax,__HINSTANCESTART
	movl	%eax,__STANDALONE
	movl	%eax,__CONGRID
	movl	%eax,__START
	movl	%eax,__MAIN
	movl	%eax,__APP
	movl	%eax,__CPU
	movl	%eax,__DEBUG
	movl	%eax,__BLOWBACK
#
#
#
	movl	$__externals,%esi	# beginning of shared/external memory
	movl	%esi,%edi		#
	addl	$65536,%edi		# end of shared/external memory
	call	__ZeroMemory		# clear shared/external variable memory
#;
#;
#; ###################################  Get space for first 4KB of ##DYNO
#; #####  Establish DYNO Memory  #####  memory and set up size pointer table
#; ###################################  and first and last memory block header.
#;
	pushl	$0		#
	call	sbrk		# returns current __BSSZ
	addl	$4,%esp		# remove arguments
#;
	addl	$0x00001100,%eax	# add 4KB page + 256 bytes for table
	andl	$0xFFFFF000,%eax	# round down to 4KB page boundary
	movl	%eax,__DYNO0	# establish base of DYNO area
	movl	%eax,__DYNO	# establish base of DYNO area
	addl	$0x00010000,%eax	# add 64K page for 64KB DYNO area
	movl	%eax,__DYNOZ	# ditto
	pushl	%eax	#
	pushl	%eax	#
	call	brk	# establish DYNO area
	addl	$4,%esp	# remove arguments
	popl	%eax	# recover requested __DYNOZ
	subl	$0x10,%eax	# __DYNOZ - 16 bytes for upper header
	movl	%eax,__DYNOX	# address of top DYNO header
#;
#; Dynamic memory successfully allocated
#;
#; Build low header and high header to allocate DYNO area.
#; To start off, all of dynamic memory is in one big free block.
#;
start_headers:
	movl	__DYNO,%eax	#eax -> first dyno header
	xorl	%ecx,%ecx	#ready to zero some stuff later
	movl	%eax,_pointers+0x40	#first (and only) dyno block is a big one
	movl	__DYNOX,%ebx	#ebx -> last dyno header
	movl	%ebx,%edx	#edx -> last dyno header
	subl	%eax,%ebx	#ebx = size of the one block
	movl	%ebx,0(%eax)	#addr-uplink(first) = size(first)
	movl	%ecx,4(%eax)	#addr-downlink(first) = 0 (none)
	movl	%ecx,8(%eax)	#size-uplink(first) = 0 (none)
	movl	%ecx,12(%eax)	#size-downlink(first) = 0 (none)
	movl	%ecx,0(%edx)	#addr-uplink(last) = 0
	movl	%ebx,4(%edx)	#addr-downlink(last) = size(first)
	movl	%ecx,8(%edx)	#size-uplink(last) = 0 (none)
	movl	%ecx,12(%edx)	#size-uplink(last) = 0 (none)
	orl	$0x80000000,%ebx	#mark allocated
	movl	%ebx,4(%edx)	#mark allocated
#;
#; mark initialization complete and return
#;
	movl	$-1,__XBASIC	# mark dyno memory initialization complete
	movl	$0,__INEXIT	# exit() not in progress
#;
	popl	%esi	# standard register restore
	popl	%edi	# standard register restore
	popl	%ebx	# standard register restore
	movl	%ebp,%esp	# standard function exit
	popl	%ebp	# standard function exit
	ret		# return to WinMain()
#
#
#
#
# #################################
# #####  XxxStartApplication  #####
# #################################
#
XxxStartApplication_0:
	movl	$0,__ENTERED	# not entered yet
	movl	__APP,%eax	# eax = application address
	orl	%eax,%eax	# address = 0 for PDE else &__StartApplication
	jnz	startStandalone	# if address != 0 : jump to standalone program
	jmp	__StartApplication	# jump to __StartApplication
	ret		# no application - return to caller
#
startStandalone:
	jmp	*%eax	# jump to __StartApplication
#
#
#
# ##################
# #####  XxxG  #####  calls ##UCODE (sets ##WHOMASK first)
# ##################
#
XxxG_0:
	movl	$0,__ENTERED	# application not entered
	movl	$0,__SOFTBREAK	# reset softBreak
	movl	$0x01000000,__WHOMASK	# we're in user country now
	call	*__UCODE	#
	movl	$0,__WHOMASK	# we're back in system country
	ret
#
#
# #########################
# #####  XxxGuessWho  #####  Returns ##WHOMASK
# #########################
#
XxxGuessWho_0:
	movl	__WHOMASK,%eax	# eax = __WHOMASK
	ret		# return __WHOMASK
#
#
# #############################
# #####  XxxGetEbpEsp ()  #####
# #############################
#
XxxGetEbpEsp_8:
	movl	%ebp,4(%esp)
	movl	%esp,8(%esp)
	ret	$8
#
#
# #############################
# #####  XxxSetEbpEsp ()  #####
# #############################
#
XxxSetEbpEsp_8:
	movl	4(%esp),%ebp
	movl	8(%esp),%esp
	ret	$8
#
#
# ################################
# #####  XxxGetFrameAddr ()  #####
# ################################
#
XxxGetFrameAddr_0:
	movl	%ebp,%eax
	ret
#
#
# ################################
# #####  XxxSetFrameAddr ()  #####
# ################################
#
XxxSetFrameAddr_4:
	movl	4(%esp),%ebp
	ret	$4
#
#
# #################################
# #####  XxxGetExceptions ()  #####
# #################################
#
XxxGetExceptions_8:
	movl	__OSEXCEPTION,%ebx
	movl	__EXCEPTION,%eax
	movl	%eax,4(%esp)
	movl	%ebx,8(%esp)
	ret	$8
#
#
# #################################
# #####  XxxSetExceptions ()  #####
# #################################
#
XxxSetExceptions_8:
	movl	4(%esp),%eax
	movl	8(%esp),%ebx
	movl	__EXCEPTION,%eax
	movl	__OSEXCEPTION,%ebx
	ret	$8
#
#
# #####################################
# #####  XxxGetImplementation ()  #####
# #####################################
#
XxxGetImplementation_4:
	pushl	%ebp		# standard function entry
	pushl	%ebx		# ditto
	pushl	%edi		# ditto
	pushl	%esi		# ditto
	movl	%esp,%ebp	# ditto
#
	movl	20(%ebp),%esi		# esi = argument string
	call	_____free		# free argument string
	movl	$implementation,%eax	# eax = &implementation$
	call	__clone.a0		# eax = copy of implementation$
	movl	%eax,20(%ebp)		# argument = copy
#
	movl	%ebp,%esp	# standard function exit
	popl	%esi		# ditto
	popl	%edi		# ditto
	popl	%ebx		# ditto
	popl	%ebp		# ditto
	ret	$4		# ditto
#
#
#
# ########################
# #####  XxxFCLEX_0  #####
# ########################
#
XxxFCLEX_0:
fnclex
xorl	%eax,%eax
ret
#
#
# ########################
# #####  XxxFINIT_0  #####
# ########################
#
XxxFINIT_0:
finit
xorl	%eax,%eax
ret
#
#
# ########################
# #####  XxxFSTCW_0  #####
# ########################
#
XxxFSTCW_0:
xorl	%eax,%eax
pushl	%eax
fstcw	(%esp)
popl	%eax
ret
#
#
# ########################
# #####  XxxFSTSW_0  #####
# ########################
#
XxxFSTSW_0:
xorl	%eax,%eax
pushl	%eax
fstsw	(%esp)
popl	%eax
ret
#
#
# #######################
# #####  XxxFLDZ_0  #####
# #######################
#
XxxFLDZ_0:
fldz
ret
#
#
# #######################
# #####  XxxFLD1_0  #####
# #######################
#
XxxFLD1_0:
fld1
ret
#
#
# ########################
# #####  XxxFLDPI_0  #####
# ########################
#
XxxFLDPI_0:
fldpi
ret
#
#
# #########################
# #####  XxxFLDL2E_0  #####
# #########################
#
XxxFLDL2E_0:
fldl2e
ret
#
#
# #########################
# #####  XxxFLDL2T_0  #####
# #########################
#
XxxFLDL2T_0:
fldl2t
ret
#
#
# #########################
# #####  XxxFLDLG2_0  #####
# #########################
#
XxxFLDLG2_0:
fldlg2
ret
#
#
# #########################
# #####  XxxFLDLN2_0  #####
# #########################
#
XxxFLDLN2_0:
fldln2
ret
#
#
# ########################
# #####  XxxF2XM1_8  #####
# ########################
#
XxxF2XM1_8:
fldl	4(%esp)
f2xm1
ret	$8
#
#
# #######################
# #####  XxxFABS_8  #####
# #######################
#
XxxFABS_8:
fldl	4(%esp)
fabs
ret	$8
#
#
# #######################
# #####  XxxFCHS_8  #####
# #######################
#
XxxFCHS_8:
fldl	4(%esp)
fchs
ret	$8
#
#
# #######################
# #####  XxxFCOS_8  #####
# #######################
#
COS_8:
XxxFCOS_8:
fldl	4(%esp)
fcos
ret	$8
#
#
# ####################
# #####  ATAN_8  #####
# ####################
#
ATAN_8:
fldl	4(%esp)
fld1
fpatan
ret	$8
#
#
# ##########################
# #####  XxxFPATAN_16  #####
# ##########################
#
XxxFPATAN_16:
fldl	4(%esp)
fldl	12(%esp)
fpatan
ret	$16
#
#
# #########################
# #####  XxxFPREM_16  #####
# #########################
#
XxxFPREM_16:
fldl	12(%esp)
fldl	4(%esp)
fprem
fstsw	%ax
sahf
jp	XxxFPREM_16
fxch
xorl	%eax,%eax
pushl	%eax
fstpl	(%esp)
add	$4,%esp
ret	$16
#
#
# ##########################
# #####  XxxFPREM1_16  #####
# ##########################
#
XxxFPREM1_16:
fldl	12(%esp)
fldl	4(%esp)
fprem1
fstsw	%ax
sahf
jp	XxxFPREM1_16
fxch
xorl	%eax,%eax
pushl	%eax
fstpl	(%esp)
add	$4,%esp
ret	$16
#
#
# #########################
# #####  XxxFPTAN_16  #####
# #########################
#
XxxFPTAN_16:
fldl	4(%esp)
fptan
fstpl	12(%esp)
ret	$16
#
#
# ###################
# #####  TAN_8  #####
# ###################
#
TAN_8:
fldl	4(%esp)
fptan
fwait
fstpl	-8(%esp)	# discard top argument (seems to always be a 1#)
# fxch			#
# fdivp			# why divide by 1# ???
ret	$8
#
#
# ##########################
# #####  XxxFRNDINT_8  #####
# ##########################
#
XxxFRNDINT_8:
fldl	4(%esp)
frndint
ret	$8
#
#
# ##########################
# #####  XxxFSCALE_16  #####
# ##########################
#
XxxFSCALE_16:
fldl	4(%esp)
fldl	12(%esp)
fscale
fxch
xorl	%eax,%eax
pushl	%eax
fstpl	(%esp)
add	$4,%esp
ret	$16
#
#
# #######################
# #####  XxxFSIN_8  #####
# #######################
#
SIN_8:
XxxFSIN_8:
fldl	4(%esp)
fsin
ret	$8
#
#
# ###########################
# #####  XxxFSINCOS_16  #####
# ###########################
#
XxxFSINCOS_16:
fldl	4(%esp)
fsincos
fstpl	12(%esp)
ret	$16
#
#
# ########################
# #####  XxxFSQRT_8  #####
# ########################
#
SQRT_8:
XxxFSQRT_8:
fldl	4(%esp)
fsqrt
ret	$8
#
#
# ###########################
# #####  XxxFXTRACT_16  #####
# ###########################
#
XxxFXTRACT_16:
fldl	4(%esp)
fxtract
fstpl	12(%esp)
ret	$16
#
#
# #########################
# #####  XxxFYL2X_16  #####
# #########################
#
XxxFYL2X_16:
fldl	4(%esp)
fldl	12(%esp)
fyl2x
ret	$16
#
#
# ###########################
# #####  XxxFYL2XP1_16  #####
# ###########################
#
XxxFYL2XP1_16:
fldl	4(%esp)
fldl	12(%esp)
fyl2xp1
ret	$16
#
#
# ####################
# #####  EXP ()  #####  e ** x#
# ####################
#
.text
EXP_8:
EXPE_8:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	fldl	8(%ebp)
	fldl2e
	fmulp	%st,%st(1)
	jmp	EXPDO
#
#
# #####################
# #####  EXP2 ()  #####  2 ** x#
# #####################
#
EXP2_8:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	fldl	8(%ebp)
	jmp	EXPDO
#
# ######################
# #####  EXP10 ()  #####  10 ** x#
# ######################
#
EXP10_8:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	fldl	8(%ebp)
	fldl2t
	fmulp	%st,%st(1)
	jmp	EXPDO
#
#
EXPDO:
	fstcw	-4(%ebp)
	fstcw	-8(%ebp)
	fwait
	andw	$0xf3ff,-4(%ebp)
	fldcw	-4(%ebp)
	fld	%st(0)
	frndint
	fldcw	-8(%ebp)
	fxch	%st(1)
	fsub	%st(1),%st
	f2xm1
	fwait
	fld1
	faddp	%st,%st(1)
	fscale
	fstp	%st(1)
	movl	%ebp,%esp
	popl	%ebp
	ret	$8
#
# #################################
# #####  x# = y# ** z#  ###########
# #################################
# #####  x# = POWER (y#, z#)  #####
# #################################
#
.text
.align 16
EXPX_16:
POWER_16:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$24,%esp
	pushl	%ebx
	fldl	8(%ebp)
	fldl	16(%ebp)
	fldz
	fucom	%st(1)
	fnstsw	%ax
	andb	$68,%ah
	xorb	$64,%ah
	jnz 	power.nonzorch
	fstp	%st(0)
	fstp	%st(0)
	fstp	%st(0)
	fld1
	jmp 	power.done
#
power.nonzorch:
	fucom	%st(2)
	fnstsw	%ax
	andb	$68,%ah
	xorb	$64,%ah
	jnz 	power.3
	fstp	%st(2)
	fcompp
	fnstsw	%ax
	andb	$69,%ah
	cmpb	$1,%ah
	jz 	power.15
	fldz
	jmp 	power.done
#
power.3:
	fld1
	fucomp	%st(2)
	fnstsw	%ax
	andb	$69,%ah
	cmpb	$64,%ah
	jz 	power.14
	fcomp	%st(2)
	fnstsw	%ax
	andb	$69,%ah
	jnz 	power.7
	fld	%st(0)
	fnstcw	-2(%ebp)
	movw	-2(%ebp),%ax
	movb	$12,%ah
	movw	%ax,-4(%ebp)
	fldcw	-4(%ebp)
	subl	$8,%esp
	fistpll	(%esp)
	popl	%edx
	popl	%ecx
	fldcw	-2(%ebp)
	movl	%edx,%ebx
	andl	$1,%ebx
	pushl	%ecx
	pushl	%edx
	fildll	(%esp)
	addl	$8,%esp
	fucomp	%st(1)
	fnstsw	%ax
	andb	$69,%ah
	cmpb	$64,%ah
	jz 	power.8
	fstp	%st(0)
	fstp	%st(0)
power.15:
	movl	$33,errno		# EDOM : errno = "domain error"
	movl	$0xFFFFFFFF,(%esp)
	movl	$0x7FFFFFFF,4(%esp)
	fldl	(%esp)			# $$PNAN = not a number
	jmp 	power.done
#
power.8:
	fxch	%st(1)
	fchs
	jmp 	power.9
#
power.7:
	fxch	%st(1)
	xorl	%ebx,%ebx
power.9:
	fnstcw	-2(%ebp)
	movw	-2(%ebp),%dx
	movw	%dx,-4(%ebp)
	movw	-2(%ebp),%dx
	andb	$243,%dh
	orb	$63,%dl
	movw	%dx,-2(%ebp)
	fldcw	-2(%ebp)
	fyl2x
	fld	%st(0)
	frndint
	fxch
	fsub %st(1),%st(0)
	f2xm1
	fld1
	faddp
	fxch
	fld1
	fscale
	fstp	%st(1)
	fmulp
	fldcw	-4(%ebp)
	subl	$8,%esp
	fstl	(%esp)
	call	isinf
	testl	%eax,%eax
	jnz 	power.11
	call	isnan
	testl	%eax,%eax
	jz 	power.10
power.11:
	movl	$34,errno		# ERANGE : errno = "range error"
power.10:
	testl	%ebx,%ebx
	jz 	power.done
	fchs
	jmp 	power.done
#
power.14:
	fstp	%st(0)
	fstp	%st(0)
##
power.done:
	movl	-28(%ebp),%ebx
	movl	%ebp,%esp
	popl	%ebp
	ret	$16
#
#
isnan:
	xorl	%edx,%edx
	movw	10(%esp),%ax
	shrw	$4,%ax
	andl	$0x000007FF,%eax
	cmpl	$0x000007FF,%eax
	jnz	iszero
	testl	$0x000FFFFF,8(%esp)
	jnz	isone
	cmp	$0,4(%esp)
	jnz	isone
iszero:
	xorl	%eax,%eax
	ret
#
isone:
	movl	$0x00000001,%eax
	ret
#
isinf:
	movl	8(%esp),%eax
	andl	$0x7FFFFFFF,%eax
	cmpl	$0x7FF00000,%eax
	jnz	iszero
	cmpl	$0,4(%esp)
	jnz	iszero
	movl	$0x00000001,%eax
	cmpb	$0,11(%esp)
	jge	isinf.done
	movl	$0xFFFFFFFF,%eax
isinf.done:
	ret
#
#
# ******************************
# *****  SUPPORT ROUTINES  *****
# ******************************
#
__ZeroMemory:
_XxxZeroMemory:
	movl	%edi,%ecx	# ecx = byte after last
	subl	%esi,%ecx	# ecx = _ of bytes to zero
	jnb	zmpos	# positive value
#;
	xchgl	%edi,%esi	# make esi < edi
	movl	%edi,%ecx	# ecx = byte after last
	subl	%esi,%ecx	# ecx = _ of bytes to zero
#;
zmpos:
	shrl	$2,%ecx	# ecx = _ of dwords to zero
	jecxz	zm_exit	# skip if no bytes to zero
	xorl	%eax,%eax	# ready to write some zeros
	movl	%esi,%edi	# edi -> beginning of block to zero
	cld		# make sure stosd moves up in memory
	rep
	stosl		# write 'em!
zm_exit:
	ret
#
# below is the old %_ZeroMemory
#
#%_ZeroMemory:
#mov	ecx,edi
#sub	ecx,esi		;ecx = # of bytes to zero
#slr	ecx,2		;ecx = # of dwords to zero
#jecxz	zm_exit		;skip if no bytes to zero
#xor	eax,eax		;ready to write some zeros
#mov	edi,esi		;edi -> beginning of block to zero
#cld			;make sure stosd moves up in memory
#rep
#stosd			;write 'em!
#zm_exit:
#ret
#
#
__eeeErrorNT:
	movl	$$$ErrorOperatingSystem,__ERROR
	movl	$errno,%eax
	negl	%eax	# __TRAPVECTOR = - (errorNumber)
	movl	%eax,__TRAPVECTOR
	jmp	errorReport
#
__eeeAllocation:
	movl	$$$ErrorMemoryAllocation,__ERROR
	jmp	__RuntimeError
#
__eeeIllegalFunctionCall:
	movl	$$$ErrorInvalidFunctionCall,__ERROR
	jmp	__RuntimeError
#
__eeeInternal:
	movl	$$$ErrorInvalidFunctionCall,__ERROR
	jmp	__RuntimeError
#
__eeeOverflow:
	movl	$$$ErrorOverflow,__ERROR
	jmp	__RuntimeError
#
__OutOfBounds:
	movl	$$$ErrorOutOfBounds,__ERROR
	jmp	__RuntimeError
#
__NeedNullNode:
	movl	$$$ErrorAttachNeedsNullNode,__ERROR
	jmp	__RuntimeError
#
__UnexpectedLowestDim:
	movl	$$$ErrorUnexpectedLowestDimension,__ERROR
	jmp	__RuntimeError
#
__UnexpectedHigherDim:
	movl	$$$ErrorUnexpectedHigherDimension,__ERROR
	jmp	__RuntimeError
#
#
#
#
# *****  RuntimeError  *****  ##ERROR is set CALLed
#
__RuntimeError:
	movl	$504,__TRAPVECTOR	# 504 = GeneralPurpose (XERROR)
errorReport:
XxxRuntimeError:
	int	$3	# breakpoint opcode
	ret
#
#
XxxRuntimeError2:
.word	0x0F0F			# Windows 3.1 uses 2-byte illegal instruction
	ret
#
#
# *****  Routines for debugging  ******
#
XxxFPUstatus_0:
	fnstsw	%ax
	ret
#
XxxEBPandESP_0:
	movl	%ebp,%eax
	movl	%esp,%edx
	ret
#
#
.text
.align	8
#
# #####################
# #####  xlib0.s  #####  Memory-allocation routines
# #####################
#
__beginAlloCode:	# mark beginning of uninterruptible code for xinit.s
	ret	$0
#
#
# ********************
# *****  calloc  ***** allocate and clear a chunk for n elements of m bytes
# ********************
#
# *****  calloc  *****  C entry point
#
#  in:  arg1 = size of each element
#	arg0 = number of elements
# out:	eax -> allocated block, or NULL if memory not available
#
# Also returns NULL if size of requested block is zero.
#
calloc:
_calloc:
__calloc:
	pushl	%ebp	# standard function entry
	movl	%esp,%ebp	# ditto
	pushl	%ebx	# ditto
	pushl	%edi	# ditto
	pushl	%esi	# ditto
#;
	xorl	%eax,%eax	# speed up following comparisons (I think)
	cmpl	%eax,8(%ebp)	# number of elements = 0?
	jz	ccalloc0	# then quit wasting my time
	cmpl	%eax,12(%ebp)	# same if element size is zero
	jz	ccalloc0
#;
	movl	12(%ebp),%esi
	imul	8(%ebp),%esi	# esi = _ of element * element size = total size
	call	______calloc	# esi -> new block's header, or NULL if none
	movl	%esi,%eax
#;
	orl	%eax,%eax
	jz	ccalloc0
	addl	$16,%eax
ccalloc0:
	popl	%esi	# standard function exit
	popl	%edi	# ditto
	popl	%ebx	# ditto
	movl	%ebp,%esp	# ditto
	popl	%ebp	# ditto
	ret		# ditto
#
#
# *****  calloc  *****  XBASIC entry point
#
#  in:  arg0 = total size of block to allocate
# out:	eax -> allocated block, or NULL if memory not available
#
# Also returns NULL if size of requested block is zero.
#
# Except for the fact that the XBASIC entry point for calloc takes
# only one parameter, the result of multiplying the C entry point's
# parameters together, this entry point is the same as the C
# entry point.
#
Xcalloc:
	pushl	%ebp
	movl	%esp,%ebp
	cmpl	$0,8(%ebp)	#size to allocate is zero?
	jz	xcalloc0	#then quit wasting my time
#
	pushl	%ebx
	pushl	%esi
	pushl	%edi
#
	movl	8(%ebp),%esi	#esi = size of block to allocate
	call	______calloc	#esi -> new block's header, or NULL if none
	movl	%esi,%eax
#
	popl	%edi
	popl	%esi
	popl	%ebx
	orl	%eax,%eax
	jz	xcalloc0
	addl	$16,%eax
xcalloc0:
	popl	%ebp
	ret
#
#
# *****  calloc  *****  internal entry point
#
# in:	esi = size of block to allocate
# out:	esi -> allocated block's data area, or zero if error
#
# destroys: edi
#
_____calloc:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	call	______calloc
	orl	%esi,%esi
	jz	icalloc0
	addl	$16,%esi
icalloc0:
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	ret
#
# *****  calloc  *****  CORE ROUTINE
#
#  in:  esi = size of block to allocate
# out:  esi -> allocated block's HEADER (not data)
#
# destroys: eax, ebx, ecx, edx, edi
#
______calloc:
	orl	%esi,%esi	#if zero-size block, return null pointer
	jz	calloc_exit
	call	______malloc	#esi->alloc'ed block's header
#
	orl	%esi,%esi	#error?
	jz	calloc_exit	#yep
#
	xorl	%eax,%eax	#prepare to write zeros
	movl	(%esi),%ecx	#ecx = size of block, including header
	subl	$16,%ecx	#ecx = size of block's data area
	leal	16(%esi),%edi	#edi -> block's data area
	shrl	$2,%ecx	#ecx = _ of dwords to zero (block size can
#				; only be a multiple of 16)
	cld		#make sure direction is right
	rep
	stosl		#fill with zeros
calloc_exit:
	ret
#
#
# ********************
# *****  malloc  *****  allocate a chunk of storage
# ********************
#
# *****  malloc  *****  C entry point  and  XBASIC entry point
#
#  in: arg0 = number of bytes to allocate
# out: eax -> allocated block, or NULL if none available
#
# returns zero if requested to allocate zero bytes
#
# *****  addr = malloc (bytes)  *****
#
malloc:
_malloc:
__malloc:
Xmalloc:
	pushl	%ebp	# standard function entry
	movl	%esp,%ebp	# ditto
	pushl	%ebx	# ditto
	pushl	%edi	# ditto
	pushl	%esi	# ditto
#;
	movl	8(%ebp),%esi	# esi = bytes to allocate
	orl	%esi,%esi	# trying to malloc zero bytes?
	jz	cmalloc0	# then quit wasting my time
#;
	movl	__DYNO,%eax	# eax = __DYNO : non-zero if established
	orl	%eax,%eax	#
	jnz	mallok	# __DYNO area already established
	call	initmem	# initialize memory areas and system variables
#;
mallok:
	movl	8(%ebp),%esi	# esi = bytes to allocate
	addl	$0x10,%esi	# try to fix Motif
	call	______malloc	# esi -> new block's header, or NULL if none
	movl	%esi,%eax
#;
	orl	%eax,%eax
	jz	cmalloc0
	addl	$16,%eax
#;
cmalloc0:
	popl	%esi	# standard function exit
	popl	%edi	# ditto
	popl	%ebx	# ditto
	movl	%ebp,%esp	# ditto
	popl	%ebp	# ditto
	ret		# ditto
#
#
# *****  malloc  *****  internal entry point
#
# in:	esi = size of block to allocate
# out:	esi -> data area of allocated block
#
# destroys: edi
#
# Returns null pointer if error.
#
_____malloc:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
#;
	call	______malloc
	orl	%esi,%esi	# error?
	je	_malloid	# yes error
	addl	$16,%esi	# no error: esi -> allocated block
#;
_malloid:
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	ret
#
#
# *****  malloc  *****  CORE ROUTINE
#
#  in: esi = size of block to allocate
# out: esi -> HEADER of allocated block (not data area)
#
# destroys: eax, ebx, ecx, edx, edi
#
# local variables:
#	-4	Size of block to allocate; original esi
#	-8	Total size of block to allocate, including header
#	-12	Address of big-enough chunk (when searching thru big-chunk list)
#	-16	Size of best-fitting big chunk found so far
#
______malloc:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	orl	%esi,%esi	#request for zero-length block?
	jz	malloc_exit	#if so, return null pointer
	movl	%esi,-4(%ebp)	#save requested size
#
# get pointer # for specified size
#
malloop:
	movl	%esi,%ebx
	decl	%ebx	#ebx = size - 1
	jns	non_zero_size	#skip if esi != 0
	incl	%ebx	#ebx = 0 (if size = 0)
non_zero_size:
	movl	%ebx,%esi
	shrl	$4,%esi	#esi = (size - 1) / 16 = pointer _
	movl	%esi,%edx
	shll	$4,%edx	#edx = size needed - 16
	addl	$0x20,%edx	#edx = total size needed, including header
	movl	%edx,-8(%ebp)	#save for later
	andl	$0xFFFFFF00,%ebx	#ebx = 0 if size <= 256
	jnz	big_chunk	#size is > 256# special large chunk required
#
# size <= 256
#
	movl	_pointers(,%esi,4),%ebx	#ebx -> 1st chunk this size
	orl	%ebx,%ebx	#any chunks this size?
	jz	not_exact	#nope
#
# CASE A: Found free chunk of desired size
#
	movl	8(%ebx),%eax	#eax -> size-upstream header
	movl	-4(%ebp),%ecx	#ecx = size requested
	movl	__WHOMASK,%edx	#edx = system/user bit in info word
	orl	$0x00000001,%edx	#one byte per element
	btsl	$31,4(%ebx)	#mark as allocated
	jnc	blockOk0	#previously allocated
#;
	call	__eeeAllocation	#block allocated
	xorl	%esi,%esi	#return null pointer
	ret		#never get here
#
blockOk0:
	movl	%ecx,8(%ebx)	#size of block = requested size
	movl	%edx,12(%ebx)	#write info word into header
	movl	%eax,_pointers(,%esi,4)	#update pointer to unlink this chunk
	orl	%eax,%eax	#size uplink = 0?
	jz	skip_zip	#yes -- no further chunks
	movl	$0,12(%eax)	#zero size downlink of next chunk
skip_zip:
	movl	%ebx,%esi	#return pointer to header of new block in esi
malloc_exit:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# no exact-size chunks are free
#
not_exact:
	movl	%esi,%ebx
	incl	%ebx	#ebx = next pointer _
not_yet:
	movl	_pointers(,%ebx,4),%eax	#eax = ptr to block of next higher size
	orl	%eax,%eax	#is there a pointer?
	jnz	got_chunk	#yes, go allocate it
	incl	%ebx	#nope, point to next size up
	cmpl	$16,%ebx	#are we past the end of the table?
	jbe	not_yet	#no, try next size up
#				;else fall through
#
# CASE B:  No free chunks of desired size or larger exist; get more memory
#
# compute new break address and uplink to new top header
#
none_big_enough:
	movl	__DYNOZ,%eax	# base of new pages to alloc
	addl	$0x00040000,%eax	# add 256KB
	pushl	%eax	# save new __DYNOZ
	pushl	%eax	# arg = new __DYNOZ
	call	brk	#
	addl	$4,%esp	# restore frame
	orl	%eax,%eax	# check for error
	jz	breaker.good	# no error
	popl	%eax	# eax = new __DYNOZ - 1MB higher
#
# error allocating another 256KB
#
	call	__eeeErrorNT	# process Win32 error
	ret		# better not get here !!!
#
# no error, got memory
#
breaker.good:
	popl	%eax	# eax = new __DYNOZ - 1MB higher
	movl	%eax,__DYNOZ	# update __DYNOZ - 1MB higher
	subl	$0x0010,%eax	# eax = new top header address
	movl	%eax,__DYNOX	# __DYNOX = ditto
	movl	$0,0(%eax)	# addr-uplink(new-top) = 0
	movl	$0x80040000,4(%eax)	# addr-downlink(new-top)=256KB
	movl	$0,8(%eax)	# size-uplink(new-top) = 0 (last header)
	movl	$0x0001,12(%eax)	# size-down(new-top)=bytes/ele
	movl	%eax,%esi	# esi = new top header address
	subl	$0x040000,%esi	# esi = old top header address
	movl	$0x040000,(%esi)	# addr-uplink(old-top) = 256KB
#
# free previous top header
#
	call	_____Hfree	#free old top header (probable merge)
	movl	-4(%ebp),%esi	#esi = original requested size
	jmp	malloop	#we have more memory now, so try again
#
# CASE C:  No free chunk of perfect size, but found larger free chunk
#
# entry:  eax = pointer contents = address of 1st chunk in this free list
#	  [ebp-8] = size needed, including header
#	  ebx = pointer # (pointer of size-list having chunk to use)
#
# unlink this header from size links
#
got_chunk:
	movl	8(%eax),%esi	#esi = size-uplink to size-upstream chunk
	movl	%esi,_pointers(,%ebx,4)	#point size pointer at size-upstream chunk
	orl	%esi,%esi	#if uplink = 0, then no size-upstream chunk
	jz	whole_or_part
	movl	$0,12(%esi)	#mark size-upstream header as new 1st chunk
#
# decide whether to use this entire free chunk, or only a lower portion
#
whole_or_part:
	movl	-4(%ebp),%edx	#edx = requested size
	movl	__WHOMASK,%esi	#esi = system/user bit in info word
	orl	$0x00000001,%esi	#esi = 1 byte per element
	btsl	$31,4(%eax)	#mark as allocated
	jnc	blockOk1	#previously allocated
#;
	call	__eeeAllocation	#block allocated
	xorl	%esi,%esi	#return null pointer
	ret
#
#
blockOk1:
	movl	%edx,8(%eax)	#header word2 = requested size
	movl	%esi,12(%eax)	#marker this header as in use
	movl	(%eax),%esi	#esi = size of chunk including header
	subl	-8(%ebp),%esi	#esi = size - needed size = new free size
	jns	duh4	#DEBUG
	call	__eeeAllocation	#block allocated
duh4:				#DEBUG
	cmpl	$0x20,%esi	#still room for header and 16-byte data block?
	jb	no_new	#nope, allocate entire chunk
#
# address link a new free header above the chunk being allocated
#
	movl	-8(%ebp),%edi	#edi = size needed (including header)
	leal	(%eax,%edi,1),%edx	#edx -> new free chunk
	movl	%esi,(%edx)	#put address up-link in new free chunk
	movl	%edi,4(%edx)	#put address down-link in new free chunk
	movl	%edi,(%eax)	#put address up-link in this chunk
	leal	(%edx,%esi,1),%edi	#edi -> header above new free chunk
	btsl	$31,%esi	#esi = addr-down-link + allocated bit
	movl	%esi,4(%edi)	#put address down-link in header above new free
	btrl	$31,%esi	#restore esi
#
# compute pointer # to size-link the new free header
#
	subl	$17,%esi	#esi = size of new free chunk's data area - 1
	movl	%esi,%edi
	shrl	$4,%esi	#esi = pointer _ for small chunk
	andl	$0xFFFFFF00,%edi	#edi = 0 if new free chunk size <= 256 bytes
	jz	small_chunk	#if edi = 0, a small chunk is adequate
	movl	$16,%esi	#esi = pointer _ for large chunk
#
# size-link new free block to pointer and next size up-link header
#
small_chunk:
	movl	_pointers(,%esi,4),%edi	#edi -> 1st header of this size
	movl	%edx,_pointers(,%esi,4)	#update size pointer to new free chunk
	movl	%edi,8(%edx)	#put size-uplink into new free header
	movl	$0,12(%edx)	#put size down-link into new free header
	orl	%edi,%edi	#if size-uplink = 0, no size-upstream
	jz	no_new
	movl	%edx,12(%edi)	#put size down-link into next up-link header
no_new:
	movl	%eax,%esi	#esi -> allocated header
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# malloc executes the following code when the required size > 256 bytes.
# It attempts to find a free chunk 1.125 to 1.375 times the minimum
# size by searching through the size-linked big chunks
#
# entry:  edx = required size, including header
#
big_chunk:
	movl	$0,-12(%ebp)	#no big-enough chunk found yet
	movl	$0,-16(%ebp)	#size of best-fitting chunk = 0
	movl	_pointers+0x40,%esi	#esi -> first big-chunk header
	movl	%edx,%ebx
	shrl	$3,%ebx	#ebx = 1/8 minimum chunk size
	movl	%edx,%ecx
	shrl	$2,%ecx	#ecx = 1/4 minimum chunk size
	addl	%ebx,%edx	#edx = 1.125 * mimimum chunk size
	leal	(%edx,%ecx,1),%ebx	#ebx = 1.375 * minimum chunk size
	andl	$0xFFFFFFF0,%edx	#edx = align16(new-min-chunk-size)
	andl	$0xFFFFFFF0,%ebx	#ebx = align16(new-max-chunk-size)
#
# edx = min-perfect-chunk-size   ebx = max-perfect-chunk-size
#
bcloop:
	orl	%esi,%esi
	jz	no_perfect_fit	#if esi null pointer, not perfect fit found
	movl	(%esi),%ecx	#ecx = address uplink = size of chunk
	cmpl	%edx,%ecx	#excess size (chunk size - needed size) > 0?
	jae	big_enough	#yes, chunk is big enough
	movl	8(%esi),%esi	#no, get next header upstream
	jmp	bcloop
#
# found big-enough chunk; use if in perfect range, else see if best so far
#
big_enough:
	cmpl	%ecx,%ebx	#max-perfect-size - this-chunk-size
	jae	perfect_fit	#chunk size is between max and min: perfect
	cmpl	$0,-12(%ebp)	#has a big-enough chunk already been found?
	jnz	pick_best_fit	#yes, see if new chunk better fit than old
#
# large enough chunk, but not perfect size
#
best_so_far:
	movl	%esi,-12(%ebp)	#save address of header of current chunk
	movl	%ecx,-16(%ebp)	#save size of current chunk
	movl	8(%esi),%esi	#esi -> next chunk upstream
	jmp	bcloop
#
# chunk is perfect size: unlink this chunk from size-links
# esi -> header
perfect_fit:
	movl	8(%esi),%edi	#edi -> size-upstream header
	movl	__WHOMASK,%ecx	#ecx = system/user bit in info word
	orl	$0x0001,%ecx	#one byte per element
	btsl	$31,4(%esi)	#mark as allocated
	jnc	blockOk2	#previously allocated
#;
	call	__eeeAllocation	#block allocated
	xorl	%esi,%esi	#return null pointer
	ret
#
#
blockOk2:
	movl	12(%esi),%eax	#eax -> size-downstream header
	orl	%edi,%edi	#is there a header size-upstream?
	jz	no_up	#nope
	movl	%ecx,12(%esi)	#mark this header allocated
	orl	%eax,%eax	#is there a header size-downstream?
	jz	no_down_yes_up	#nope
#
# valid header size-downstream, valid header size-upstream
#
yes_down_yes_up:
	movl	-4(%ebp),%ebx	#ebx = requested size
	movl	%edi,8(%eax)	#SD header -> SU header
	movl	%eax,12(%edi)	#SU header -> SD header
	movl	%ebx,8(%esi)	#this header word2 = requested size
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# no valid header size-downstream, valid header size_upstream
#
no_down_yes_up:
	movl	-4(%ebp),%eax	#eax = requested size
	movl	%edi,_pointers+0x40	#pointer -> size-upstream header
	movl	$0,12(%edi)	#mark size-upstream header as 1st in size-links
	movl	%eax,8(%esi)	#this header word2 = requested size
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# no valid header size-upstream
#
no_up:
	movl	%ecx,12(%esi)	#mark this header allocated
	orl	%eax,%eax	#is there a header size-downstream?
	jz	no_down_no_up	#nope
#
# valid header size-downstream, no valid header size_upstream
#
yes_down_no_up:
	movl	-4(%ebp),%ebx	#ebx = size requested
	movl	$0,8(%eax)	#downstream header is last in size-links
	movl	%ebx,8(%esi)	#this header word2 = requested size
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# no valid header size-downstream, no valid header size-upstream
#
no_down_no_up:
	movl	-4(%ebp),%eax	#eax = requested size
	movl	%edi,_pointers+0x40	#zero pointer (no big chunks left)
	movl	%eax,8(%esi)	#header word2 = requested size
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# chunk bigger than optimum; see if better fit (smaller) than previous best
#
pick_best_fit:
	cmpl	-16(%ebp),%ecx	#this-size - prev-best-size
	jb	best_so_far	#if this size < prev best, we have new best
	movl	8(%esi),%esi	#esi -> next size-upstream header
	jmp	bcloop
#
# no perfect big chunk exists; maybe no big-enough big chunks exist
#
no_perfect_fit:
	movl	-12(%ebp),%edi	#edi -> best big-enough chunk found
	orl	%edi,%edi	#was any chunk found at all?
	jz	none_big_enough	#nope
	movl	12(%edi),%ecx	#ecx -> size-downstream header
#
# a big-enough chunk was found, though none in perfect size range
#
	movl	8(%edi),%ebx	#ebx -> size-upstream header
	jecxz	first_biggie	#if ecx = 0, then found 1st in big-chunk list
#
# update size-links in size-downstream/upstream headers to unlink this chunk
# unlink this header
#
not_first_biggie:
	movl	%ebx,8(%ecx)	#link SD header to SU header
	orl	%ebx,%ebx	#if ebx = 0, no size-upstream chunks exist
	jz	no_upsize
	movl	%ecx,12(%ebx)	#link SU header to SD header
no_upsize:
	movl	__WHOMASK,%eax	#eax = system/user bit in info word
	orl	$0x0001,%eax	# one byte per element
	btsl	$31,4(%edi)	#mark as allocated
	jnc	blockOk3	#previously allocated
#;
	call	__eeeAllocation	#block allocated
	xorl	%esi,%esi	#return null pointer
	ret
#
blockOk3:
	movl	%ebx,8(%edi)	#size-uplink = 0
	movl	%eax,12(%edi)	#one byte per element
	jmp	chop_too_biggie	#break big chunk: allocate lower,
#
# best-fit chunk is 1st chunk:  update pointer and header to unlink it
#
first_biggie:
	movl	__WHOMASK,%eax	#eax = system/user bit in info word
	orl	$0x0001,%eax	#1 byte per element
	btsl	$31,4(%edi)	#mark as allocated
	jnc	blockOk4	#previously allocated
#;
	call	__eeeAllocation	#block allocated
	xorl	%esi,%esi	#return null pointer
	ret
#
#
blockOk4:
	movl	$0,8(%edi)	#size-uplink = 0
	movl	%eax,12(%edi)	#1 byte per element
	movl	%ebx,_pointers+0x40	#big-chunk pointer = size-upstream address
	orl	%ebx,%ebx	#is there a size-upstream block?
	jz	chop_too_biggie	#no, skip ahead to chopping routine
	movl	$0,12(%ebx)	#zero size-downlink of next chunk (new 1st)
#
# divide too-big chunk in two, allocate low part, free high part
#
# entry:  edx      = minimum perfect chunk size
#	  edi      -> this chunk
#	  ebp[-16] = size of this chunk
#
chop_too_biggie:
	leal	(%edi,%edx,1),%esi	#esi -> new free chunk
	movl	%edx,4(%esi)	#put address downlink in new free chunk
	movl	-16(%ebp),%eax	#eax = size of chunk to break up
	movl	%eax,%ebx	#save for later
	subl	%edx,%eax	#eax = size of new free chunk
	jns	duh5	#DEBUG
	call	__eeeAllocation	#block allocated
duh5:				#DEBUG
	movl	%eax,(%esi)	#put address up-link in new free chunk
	movl	%edx,(%edi)	#put address up-link in this chunk
	addl	%edi,%ebx	#ebx -> header above new free chunk
	btsl	$31,%eax	#eax = addr-down-link + allocated bit
	movl	%eax,4(%ebx)	#put address downlink in header above new free
	btrl	$31,%eax	#restore eax
#
# compute pointer # to size-link the new free header
#
	subl	$17,%eax	#eax = size of new free chunk - 1
	movl	%eax,%ecx
	shrl	$4,%eax	#eax = pointer _ for small chunk
	andl	$0xFFFFFF00,%ecx	#free chunk <= 256 bytes?
	jz	mini_chunk	#yes, a small chunk is adequate
	movl	$16,%eax	#eax = pointer _ for big chunk
#
# size-link new free block to pointer and next size up-link header
#
mini_chunk:
	movl	_pointers(,%eax,4),%ebx	#ebx -> first header of this size
	movl	%esi,_pointers(,%eax,4)	#update pointer to point to new free chunk
	movl	%ebx,8(%esi)	#put size-upstream address into new header
	movl	$0,12(%esi)	#zero size-downstream in new free header
	orl	%ebx,%ebx	#is there an upstream header?
	jz	up_nope	#nope
	movl	%esi,12(%ebx)	#put size-downlink into size-uplink header
up_nope:
	movl	-4(%ebp),%eax	#eax = requested size
	movl	%edi,%esi	#esi -> allocated header
	movl	%eax,8(%esi)	#header word2 = requested size
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# **********************
# *****  recalloc  *****  reallocate chunk at addr(a) for n bytes, zero excess
# **********************
#
# *****  recalloc  *****  C entry point  and  XBASIC entry point
#
#   in:	arg1 = new size
#	arg0 = current address of block to re-size
#  out:	eax -> new block, or NULL if none or error
#
# local variables:
#	[ebp-4] = old # of bytes in object
#	[ebp-8] = new # of bytes in object
#
recalloc:
_recalloc:
__recalloc:
Xrecalloc:
	pushl	%ebp	# standard function entry
	movl	%esp,%ebp	# ditto
	subl	$8,%esp	# ditto (local frame)
	pushl	%ebx	# ditto
	pushl	%edi	# ditto
	pushl	%esi	# ditto
#;
	movl	12(%ebp),%edi	# edi = new block size requested
	movl	8(%ebp),%esi	# esi -> DATA area of chunk to recalloc
	orl	%esi,%esi	# esi = 0 ?
	jz	rczip	# yes !!! just do a calloc !!!
#;
	orl	%edi,%edi	# edi = 0 ?
	jz	rcfree	# yes !!! just free old block !!!
#;
	subl	$0x10,%esi	# esi -> HEADER of chunk to recalloc
	movl	8(%esi),%ebx	# ebx = old _ of elements
#;
#; replace following two instructions with movzx eax,[esi+12] ???
#;
	movl	12(%esi),%eax	#eax = old info word
	andl	$0xFFFF,%eax	#eax = old _ of bytes per element
	imul	%eax,%ebx	#ebx = old _ of bytes in object
	movl	12(%ebp),%eax	#eax = new _ of bytes in object
	movl	%ebx,-4(%ebp)	#save old _ of bytes in object
	movl	%eax,-8(%ebp)	#save new _ of bytes in object
#;
	addl	$0x10,%esi	#esi -> DATA area of chunk to recalloc
	movl	%eax,%edi	#edi = new _ of bytes in object
	call	_____realloc	#re-size the chunk (preserving current data)
#
	orl	%esi,%esi	#couldn't allocate memory?
	jz	recalloc_error
	cmpl	$-1,%esi	#tried to recalloc a non-allocated block?
	jne	recalloc_ok
	xorl	%esi,%esi	#indicate error so that C can understand it
	jmp	recalloc_error
#
recalloc_ok:
	movl	-4(%ebp),%ebx	#restore old _ of bytes in object
	movl	-8(%ebp),%eax	#restore new _ of bytes in object
	call	zero.excess	#zero chunk after last active byte
#;
recalloc_error:
	movl	%esi,%eax	# eax = return value
rcexit:
	popl	%esi	# standard function exit
	popl	%edi	# ditto
	popl	%ebx	# ditto
	movl	%ebp,%esp	# ditto
	popl	%ebp	# ditto
	ret		# ditto
#
rczip:
	orl	%edi,%edi	# requested size = 0 ?
	jnz	rczipit	# no - go calloc
	xorl	%eax,%eax	# nothing to calloc or free, return zero
	jmp	rcexit	# done
rczipit:
	movl	%edi,%esi	# esi = size to calloc
	call	______calloc	# calloc a block
	cmpl	$-1,%esi	# esi = -1 = error ?
	jne	rcxok	# no - exit okay
	xorl	%esi,%esi	#
rcxok:
	movl	%esi,%eax	# eax = calloc block
	jmp	rcexit	# done
#
rcfree:
	call	______free	# free old block
	xorl	%eax,%eax	# eax = empty
	jmp	rcexit	# done
#
#
# *****  zero.excess  *****  zero chunk
#
#   in:	esi -> data area of realloc'ed chunk
#	ebx = old # of bytes in object
#	eax = new # of bytes in object
#  out:	esi -> data area of recalloc'ed chunk (same as on input)
#
# destroys: eax, ebx, ecx, edx, edi
#
zero.excess:
	orl	%esi,%esi	# new size = empty ???
	jz	zero.done	# yes - nothing to zero
#;
	cmpl	%eax,%ebx	#if old _ of bytes < new _ of bytes
	jae	zero.skip	#then use old
	movl	%ebx,%eax	#eax = old _ of bytes = _ to leave alone
#;
zero.skip:
	leal	(%esi,%eax,1),%edi	#edi -> where to start zeroing
	movl	-16(%esi),%ecx	#ecx = size of chunk including header
	subl	$0x10,%ecx	#ecx = size of chunk excluding header
	subl	%eax,%ecx	#ecx = size of chunk - _ to leave alone =
	jbe	zero.done	#if negative or none, no excess and no zeroing
	xorl	%eax,%eax	#ready to write some zeros
	cld		#make sure we write them in the right direction
#
q.zero.byte:
	testl	$1,%edi	#if bit 0 == 0 then no bytes to zero
	jz	q.zero.word
	stosb		#write a zero byte
	decl	%ecx	#ecx = _ of bytes left to zero
	jz	zero.done
q.zero.word:
	testl	$2,%edi	#if bit 1 == 0 then no words to zero
	jz	q.zero.dwords
	stosw		#write two zero bytes
	subl	$2,%ecx	#ecx = _ of bytes left to zero
	jz	zero.done
q.zero.dwords:
	shrl	$2,%ecx	#ecx = _ of dwords to zero
	jecxz	zero.done	#skip if nothing left to zero
	rep
	stosl		#write zeros, four bytes at a time
#
zero.done:
	ret
#
#
# **********************
# *****  recalloc  *****  reallocate chunk at addr(a) for n bytes, zero excess
# **********************
#
# *****  recalloc  *****  internal entry point
#
#   in:	esi -> data area of block to resize
#	edi = requested new number of bytes
#  out:	esi -> new block, NULL if esi was NULL on entry, or -1 if error
#
# destroys: edi
#
# local variables:
#	[ebp-4] = old # of bytes in object
#	[ebp-8] = new # of bytes in object
#
_____recalloc:
	orl	%esi,%esi	# null pointer?
	jz	rc_null	# yes: calloc instead
#;
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
#
	movl	-8(%esi),%ebx	#ebx = old _ of elements
#
# replace following two instructions with movzx eax,[esi+12] ???
#
	movl	-4(%esi),%eax	#eax = old info word
	andl	$0xFFFF,%eax	#eax = old _ of bytes per element
	imul	%eax,%ebx	#ebx = old _ of bytes in object
	movl	%ebx,-4(%ebp)	#save old _ of bytes in object
	movl	%edi,-8(%ebp)	#save new _ of bytes in object
#
	call	______realloc	#re-size the chunk (preserving current data)
	cmpl	$-1,%esi	#tried to recalloc a non-allocated block?
	je	rc_error	#yes: abort
#
	movl	-4(%ebp),%ebx	#restore old _ of bytes in object
	movl	-8(%ebp),%eax	#restore new _ of bytes in object
	call	zero.excess	#zero chunk after last active byte
#
rc_error:
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	movl	%ebp,%esp
	popl	%ebp
	ret
#
rc_null:
	movl	%edi,%esi	#esi = requested number of bytes
	call	_____calloc
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	ret
#
#
# *********************
# *****  realloc  *****  reallocate chunk at addr(a) for n bytes
# *********************
#
# *****  realloc  *****  C entry point  and  XBASIC entry point
#
#   in:	arg1 = new size
#	arg0 = current address of block to re-size
#  out:	eax -> new block, or NULL if none or error
#
# Stores new size into # of elements in header of new block.
#
realloc:
_realloc:
__realloc:
Xrealloc:
	pushl	%ebp	# standard function entry
	movl	%esp,%ebp	# ditto
	pushl	%ebx	# ditto
	pushl	%edi	# ditto
	pushl	%esi	# ditto
#
	movl	12(%ebp),%edi	# edi = new size
	movl	8(%ebp),%esi	# esi -> current block (data, not header)
	orl	%esi,%esi	# current block zero = empty ?
	jz	ramal	# yes - just malloc() new block
	orl	%edi,%edi	# new block request = zero ?
	jz	rafree	# yes - just free current block
	call	______realloc
	xorl	%eax,%eax	# eax = 0 (error return value)
	cmpl	$-1,%esi	# error ?
	je	__realloc_ret	# yes - return zero
	orl	%esi,%esi	# zero ?
	je	__realloc_ret	# yes - return zero
#;
	movl	12(%ebp),%eax	# eax = new size
	movl	%eax,-8(%esi)	# write new size into new block
	movl	%esi,%eax	# eax -> new block, or NULL if none
#;
__realloc_ret:
	popl	%esi	# standard function exit
	popl	%edi	# ditto
	popl	%ebx	# ditto
	movl	%ebp,%esp	# ditto
	popl	%ebp	# ditto
	ret		# ditto
#
ramal:
	xorl	%eax,%eax	# eax = 0 = default return value
	orl	%edi,%edi	# request size = 0 ?
	jz	__realloc_ret	# yes - just return
	movl	%edi,%esi	# esi = request size
	call	______malloc	# get block
	xorl	%eax,%eax	# eax = 0 = default return value
	cmpl	$-1,%esi	# error ?
	je	__realloc_ret	# yes
	orl	%esi,%esi	# error ?
	je	__realloc_ret	# yes
	addl	$16,%esi	# add size of DATA area
	movl	%esi,%eax	# eax = block address
	jmp	__realloc_ret	#
#
rafree:
	movl	%edi,%esi	# esi = block to free
	call	_____free	# free block
	xorl	%eax,%eax	# return 0
	jmp	__realloc_ret	# done
#
#
# *****  realloc  *****  CORE ROUTINE  *****
#
#  in:	esi = DATA address of chunk to reallocate
#	edi = requested new size of block
# out:	esi = new DATA address of block, or NULL if no memory, or -1 if
#	      attempted to re-allocate a non-allocated block
#
# %____realloc destroys: edi
# %_____realloc  destroys: eax, ebx, ecx, edx, edi
#
# Local variables:
#	[ebp-4] = header of chunk to reallocate
#	[ebp-8] = requested new size of block
#	[ebp-12] = register spill
#
# It is the caller's responsibility to fill in the info word and # of
# elements in the new block.
#
_____realloc:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	call	______realloc
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	ret
#
#
______realloc:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
#
	orl	%esi,%esi	# is current block empty ?
	jnz	renz	# no
#;
#; current block is empty, so realloc() is really just malloc()
#;
	orl	%edi,%edi	# is requested size zero ?
	jz	reexit	# current addr and request size both zero
	movl	%edi,%esi	# esi = block size wanted
	call	______malloc	# esi = block addr
	jmp	reexit	# done
#
renz:
	subl	$16,%esi	# esi -> header of block to re-size
	orl	%edi,%edi	# is requested size zero ?
	jz	refree	# yes: just free the block
#
# check for out-of-bounds request address
#
	cmpl	%esi,__DYNO	# addr(1st header) > addr(request)?
	ja	redisaster	# if so, it's a disastrous error
	cmpl	%esi,__DYNOX	# addr(last header) < addr(request)?
	jb	redisaster	# if so, it's another disastrous error
#
	movl	%esi,-4(%ebp)	# save pointer to header of block
	movl	%edi,-8(%ebp)	# save requested new size
	btl	$31,4(%esi)	# see if allocated
	jc	recheck	# yes: reallocate it
#				; no: fall through to error routine
redisaster:
	movl	$-1,%esi	# indicate that there was an error
reexit:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# also: re-enter here after freeing higher free block, if applicable
#
recheck:
	movl	%edi,%eax	#eax = requested new size
	decl	%eax	#eax = requested size - 1
	jns	not_null	#if requested size != 0, compute pointer _
	incl	%eax	#else set eax back to zero
not_null:
	movl	%eax,%edi	#edi = requested size - 1
	andl	$0xFFFFFFF0,%eax	#eax = data size needed - 16
	addl	$0x20,%eax	#eax = size needed including header
	movl	0(%esi),%ebx	#ebx = size of chunk now
	andl	$0xFFFFFF00,%edi	#edi = 0 if required chunk <= 256 bytes
	jnz	need_big_one	#separate algorithm for size > 256 bytes
	subl	%eax,%ebx	#ebx = excess size of current chunk
	jb	need_more	#if excess size < 0, need bigger chunk
#
# current chunk is too big or just right
#
	leal	(%esi,%eax,1),%ecx	#ecx = addr(excess part of this chunk)
	cmpl	$0x20,%ebx	#plus 32 bytes for another header/data?
	jae	current_too_big	#yes, so turn high portion into free area
#
# current chunk is perfect... leave it alone, return its address
#
perfectoid:
	addl	$16,%esi	#esi -> DATA area of reallocated chunk
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# current chunk is too big; make a new chunk (H) above and re-size this one (M)
#
current_too_big:
	movl	%eax,0(%esi)	#addr-uplink(M) = new-size(M)
	movl	%ebx,0(%ecx)	#addr-uplink(H) = size(H)
	btsl	$31,%eax	#mark H as allocated
	movl	%eax,4(%ecx)	#addr-downlink(H) = new-size(M)
	btrl	$31,%eax	#restore eax
	movl	__WHOMASK,%edi	#edi = system/user bit in info word
	orl	$0x0001,%edi	#edi = 1 byte per element
	movl	%edi,12(%ecx)	#create info word in H
	leal	(%ecx,%ebx,1),%edx	#edx -> XH
	movl	4(%edx),%esi	#esi = XH addr-down-link
	andl	$0x80000000,%esi	#remove all but alloc bit
	orl	%ebx,%esi	#esi = alloc bit OR size(H)
	movl	%esi,4(%edx)	#add-downlink(XH) = size(H)
	movl	%ecx,%esi	#esi -> new chunk
	call	_____Hfree	#free the new chunk (H) (possible merge with XH)
#
# after H is freed, return address of shrunk chunk
#
	movl	-4(%ebp),%esi	#esi -> shrunk chunk
	addl	$0x10,%esi	#esi -> DATA area of shrunk chunk
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# need a bigger chunk
# see if the next higher chunk is free and large enough
#  to provide sufficient room by merging with this chunk
#
need_more:
	movl	0(%esi),%ebx	#ebx = size of this chunk (M) now
	leal	(%ebx,%esi,1),%edi	#edi -> next higher chunk (H)
	movl	12(%edi),%ecx	#ecx = size-downlink(H)
	movl	0(%edi),%edx	#edx = size(H)
	btl	$31,4(%edi)	#if H is allocated, can't use H space
	jc	not_enough
#
# H is free; is it too small, just right, or too big to expand into?
#
	addl	%ebx,%edx	#edx = size(M) + size(H)
	cmpl	%eax,%edx	#is excess size of M+H less than zero?
	jb	not_enough	#yes: not enough space here
#
#note: previous instruction was bcnd.n in 88000 version; I'm translating
#it as if it were bcnd
#
# size(M+H) is at least enough to fill request; graft H onto top of M
# address-unlink H from M and XH (address link M <==> H)
#
#	mov	[ebp-12],eax	;spill eax for a moment
	leal	(%esi,%edx,1),%eax	#eax = addr(XH) = addr(M) + size(M+H)
	btsl	$31,%edx	#XH is allocated
	movl	%edx,4(%eax)	#addr-downlink(XH) = size(M+H)
	btrl	$31,%edx	#restore edx = size
	movl	%edx,0(%esi)	#addr-uplink(M) = size(M+H)
	movl	%eax,-12(%ebp)	#spill eax: [ebp-12] = addr(XH)
#
# H is now address-unlinked; size-unlink it now
#
	movl	8(%edi),%eax	#eax = size-uplink(H)
	orl	%ecx,%ecx	#is size-downlink(H) != 0?
	jne	down_not_ptr	#yes: H is not 1st chunk of its size
#
# size-downstream from H is the pointer, not another chunk
#
	movl	0(%edi),%ebx	#ebx = size(H)
	subl	$17,%ebx	#ebx = size(H) - 17  (size of data - 1)
	shrl	$4,%ebx	#ebx = (size-1) / 16 = pointer _
	cmpl	$16,%ebx	#pointer _ is beyond big-chunk pointer?
	jbe	small_guy	#no, ebx is ok
	movl	$16,%ebx	#ebx = big-chunk pointer _
small_guy:
	movl	-8(%ebp),%edi	#edi = original size request
	movl	%eax,_pointers(,%ebx,4)	#pointer = addr(SU(H))
	orl	%eax,%eax	#is there no SU(H)?
	jz	recheck	#nope: skip next instruction
	movl	%ecx,12(%eax)	#size-downlink(SU(H)) = addr(SD(H))
	jmp	recheck
#
down_not_ptr:
	movl	-8(%ebp),%edi	#edi = original size request
	movl	%eax,8(%ecx)	#size-uplink(SD(H)) = addr(SU(H))
	orl	%eax,%eax	#is there no SU(H)?
	jz	recheck	#nope: skip next instruction
	movl	%ecx,12(%eax)	#size-downlink(SU(H)) = addr(SD(H))
	jmp	recheck
#
# H is now address-linked and size-unlinked; branch back to recheck fit
#
# not enough space in M for reallocation; get a new block to allocate
#
not_enough:
	movl	-8(%ebp),%esi	#esi = original size request
	call	______malloc	#let malloc find a new block
#
# CORE malloc returns HEADER address of allocated chunk in esi
#
	movl	-4(%ebp),%edi	#edi = header address of original chunk
	movl	0(%edi),%ecx	#ecx = total size of original chunk
	movl	8(%edi),%edx	#edx = word2 from original chunk
	movl	12(%edi),%ebx	#ebx = word3 from original chunk
	movl	%edi,%eax	#eax = header address of original chunk
	movl	%esi,-4(%ebp)	#save new allocated address
	movl	%edx,8(%esi)	#new chunk's word2 = old chunk's word2
	movl	%ebx,12(%esi)	#new chunk's word3 = old chunk's word3
	subl	$0x10,%ecx	#start copy 16 words into it (i.e. skip header)
	xchgl	%edi,%esi	#esi -> original chunk# edi -> new chunk
	addl	$0x10,%esi	#esi -> original chunk's data area
	addl	$0x10,%edi	#edi -> new chunk's data area
	addl	$3,%ecx
	shrl	$2,%ecx	#divide size by 4 (_ of bytes in dword)
	cld		#make sure direction is right
	jecxz	recalloc_skip
	rep
	movsl		#copy original data area to new data area
recalloc_skip:
#
# original data has been moved to new destination; free original chunk
#
	movl	%eax,%esi	#esi = address of original chunk
	call	_____Hfree	#free original chunk
#
# original chunk is free; return address of new chunk containing original data
#
	movl	-4(%ebp),%esi	#esi -> header of new chunk
another_perfectoid:		#same as perfectoid# label allows short branch
	addl	$0x10,%esi	#esi -> data area of new chunk
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# need a big chunk to reallocate the chunk size requested
#
# esi = address of chunk to realloc
# ebx = chunk size now, including header (mod 16 size)
# eax = chunk size needed, including header (mod 16 size)
#
need_big_one:
	movl	%ebx,%edi
	subl	%eax,%edi	#edi = (size now - size needed) = excess size
	js	need_more	#if excess < 0 then need a bigger chunk
#previous instruction was bcnd.n; I'm translating it as if it were bcnd
	movl	%edi,%edx
	shll	$1,%edx	#edx = excess * 2
	cmpl	%eax,%edx	#is size-now < 1.5 times size-needed?
	jb	another_perfectoid	#yes: leave as is
#previous instruction was bcnd.n; I'm translating it as if it were bcnd
	movl	%eax,%edx
	shrl	$3,%edx	#edx = .125 * size needed
	addl	%edx,%eax	#eax = 1.125 * size needed (size to make it)
	andl	$0xFFFFFFF0,%eax	#eax = mod 16 size of reallocated chunk
	leal	(%esi,%eax,1),%ecx	#ecx = address of H chunk to create/free
	subl	%eax,%ebx	#ebx = excess size of existing = size(new H)
	jmp	current_too_big
#
refree:
	call	_____Hfree	# free chunk being realloc'ed tp zero size
	xorl	%esi,%esi	# return zero
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ******************
# *****  free  *****  frees a chunk of memory
# ******************
#
# *****  free  *****  C entry point  and  XBasic entry point
#
#  in: arg0 -> block to free
# out: random value in eax
#
cfree:
_cfree:
free:
_free:
__free:
Xfree:
	pushl	%ebp		# standard function entry
	movl	%esp,%ebp	# ditto
#	subl	$8,%esp		# ditto (local frame)
	pushl	$0		# replace above - zero 8 byte local frame
	pushl	$0		# replace above - zero 8 byte local frame
	pushl	%ebx		# ditto
	pushl	%edi		# ditto
	pushl	%esi		# ditto
	pushl	%eax		# extra
#;
	movl	8(%ebp),%eax	# eax = address to free
	orl	%eax,%eax	# eax = 0 ?
	jz	cfree0		# then don't try to free anything
	movl	%eax,%esi	# esi -> data block to free
	subl	$16,%esi	# esi -> its header
	movl	$-1,-4(%ebp)	# indicate ______free is being called from C
	call	______free
#;
cfree0:
	popl	%eax		# extra
	popl	%esi		# standard function exit
	popl	%edi		# ditto
	popl	%ebx		# ditto
	movl	%ebp,%esp	# ditto
	popl	%ebp		# ditto
	ret			# ditto
#
#
# ***********************
# *****  %____free  *****  internal entry point to %_____free
# ***********************
#
#  in: esi = data address of chunk to free
# out: esi = 0 if error or tried to free null pointer, != 0 if ok
#
# destroys: edi
#
# Allocates frame for %_____free and puts a zero at [ebp-4] to indicate
# that %_____free was not called (directly) from C.
#
_____free:
	orl	%esi,%esi	# trying to free null pointer?
	jz	fret		# yes: skip the free
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
#;
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
#;
	subl	$16,%esi
	movl	$0,-4(%ebp)
	call	______free
#;
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
#;
	movl	%ebp,%esp
	popl	%ebp
fret:
	ret
#
#
# ************************
# *****  %____Hfree  *****  internal entry point to %_____free
# ************************
#
#  in: esi = header address of chunk to free
# out: esi = 0 if error or tried to free null pointer, != 0 if ok
#
# destroys: eax, ebx, ecx, edx, edi
#
# Allocates frame for %_____free and puts a zero at [ebp-4] to indicate
# that %_____free was not called (directly) from C.
#
# %____Hfree is exactly the same as %____free except that on entry,
# esi -> the header of the block to free, not the block's data area.
#
_____Hfree:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
#;
	movl	$0,-4(%ebp)
	call	______free
#;
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *****  free  *****  CORE ROUTINE  *****
#
#  in: esi = header address of chunk to free
#      ebp -> top of 8-byte local frame, which must already have been allocated
#      [ebp-4] = -1 if called from C entry point, 0 if not
# out: esi = 0 if error or tried to free null pointer, != 0 if ok
#
# destroys: eax, ebx, ecx, edx, edi
#
# Local variables:
#	IMPORTANT: assumes that caller has already allocated 8-byte frame
#	-4	-1 if called from C entry point, 0 if not
#	-8	buffer for short error message to print
#
______free:
	movl	%ebx,save_ebx	# save %ebx for ELF
	orl	%esi,%esi	#null pointer?
	jz	free_exit	#if so, nothing to free
#
	movl	$'x',%ebx	#'x' error designator
	cmpl	%esi,__DYNO	#is addr(1st header) > addr(request)?
	ja	serious		#if so, it's a serious error
	movl	$'y',%ebx	#'y' error designator
	cmpl	%esi,__DYNOX	#is addr(last header) < addr(request)?
	jb	serious		#if so, it's a serious error
#
	movl	4(%esi),%eax	#eax = offset to L header
	orl	%eax,%eax	#eax = 0 if literal string
	jz	free_exit	#if literal string, don't free
	btrl	$31,%eax	#clear allocated bit
	movl	%eax,4(%esi)	#mark block free
	movl	$'z',%ebx	#'z' error designator
	jnc	serious		#block already free
#
# NOTE: I'm skipping the test code in the original (for now, anyway)
#
	movl	(%esi),%eax	#eax = offset to H header
	addl	%esi,%eax	#eax -> H header
	movl	4(%esi),%ecx	#ecx = offset to L header
	btrl	$31,%ecx	#assure positive offset
	negl	%ecx
	addl	%esi,%ecx	#ecx -> L header
	movl	12(%eax),%ebx	#ebx -> H's info word
	jmp	ok_to_free
#
# attempt to free an already free chunk reveals a serious allocation bug!
#
serious:
	cmpl	$0,-4(%ebp)	#non-zero if called from a C function
	jnz	Csucks	#if C function, go complain on stderr
	xorl	%esi,%esi	#return null pointer because of error
free_exit:
	ret
#
# report C functions trying to free garbage
#
# entry: ebx = 'x', 'y', or 'z', depending on where error was detected
#
Csucks:
	movl	%ebx,debug	# report where error occured
	movl	%esi,daddr	#
	movl	%esp,desp	#
	movl	%ebp,debp	#
	movl	4(%esp),%ebx	# %ebx = entry %eax
	movl	%ebx,save_eax	#
	movl	8(%esp),%ebx	# %ebx = entry %esi
	movl	%ebx,save_esi	#
	movl	12(%esp),%ebx	# %ebx = entry %edi
	movl	%ebx,save_edi	#
	movl	16(%esp),%ebx	# %ebx = entry %ebx
	movl	%ebx,save_ebx	#
	movl	0(%esp),%ebx	#
	movl	%ebx,despaddr0	#
	movl	0(%ebp),%ebp	#
	movl	%ebp,debpaddr0	#
	movl	4(%esp),%ebx	#
	movl	%ebx,despaddr4	#
	movl	4(%ebp),%ebp	#
	movl	%ebp,debpaddr4	#
	movl	0(%esi),%ebx	#
	movl	%ebx,debug0	#
	movl	4(%esi),%ebx	#
	movl	%ebx,debug1	#
	movl	8(%esi),%ebx	#
	movl	%ebx,debug2	#
	movl	12(%esi),%ebx	#
	movl	%ebx,debug3	#
	movl	16(%esi),%ebx	#
	movl	%ebx,debug4	#
	movl	24(%esi),%ebx	#
	movl	%ebx,debug5	#
	movl	28(%esi),%ebx	#
	movl	%ebx,debug6	#
#
	movl	save_ebx,%ebx	# restore %ebx for ELF
	call	__eeeAllocation	#block allocated
	xorl	%esi,%esi	#return null pointer because of error
	ret
#
# okay to free M chunk; merge with H and/or L chunks if they're free
#
# entry: eax -> H header
#	 ebx -> H's info word
#	 ecx -> L header
#
ok_to_free:
	movl	12(%ecx),%edx	#edx = L's info word
	orl	%ebx,%ebx	#is H info word = 0?
	btl	$31,4(%eax)	#is H allocated?
	jc	hi_not	#yes
#				;no: H info word (ebx) is really size-downlink
#
# H chunk is free; unlink it, and then check L chunk
#
	movl	8(%eax),%edi	#edi = size-uplink of H
	jz	down_pointer	#skip ahead if H's size-downlink null pointer
	movl	$0,8(%eax)	#size-uplink(H) = 0, i.e. mark unlinked
	movl	%edi,8(%ebx)	#size-uplink(SD(H)) -> SU(H)
	orl	%edi,%edi	#is SU(H) a null pointer?
	jz	q_lower	#yes, we have no size-uplink
	movl	%ebx,12(%edi)	#size-downlink(SU(H)) -> SD(H)
	jmp	q_lower	#see if lower is free
#
# the H chunk is 1st in size-links (unlink from pointer on downstream side)
#
down_pointer:
	movl	$0,8(%eax)	#size-uplink(H) = 0, i.e. mark unlinked
	movl	(%eax),%ebx	#ebx = size(H) = addr-uplink(H)
	subl	$17,%ebx	#ebx = size - 17 (data size - 1)
	shrl	$4,%ebx	#ebx = (size-1) / 16 = pointer _
	cmpl	$16,%ebx	#pointer _ is beyond big-chunk pointer?
	jbe	unlink_small	#no, ebx is ok
	movl	$16,%ebx	#ebx = big-chunk pointer _
unlink_small:
	movl	%edi,_pointers(,%ebx,4)	#pointer now -> SU(H)
	orl	%edi,%edi	#is SU(H) a null pointer?
	jz	q_lower	#skip if null pointer, i.e. no SU(H)
	movl	$0,12(%edi)	#mark SU(H) as 1st in size-links
#
q_lower:
	movl	12(%ecx),%edi	#edi = SD(L)
	btl	$31,4(%ecx)	#is L allocated?
	jc	hi_free_lo_not	#yes, so don't combine with M
#
# H is free, L is free: unlink L from size-links of chunks downstream
# and upstream from L
#
# ecx -> L		esi -> M		ebx = trash
# eax -> H		edx -> SD(L)		edi -> SU(L)
#
hi_free_lo_free:
	movl	12(%ecx),%edx	#edx -> SD(L)  [is this necessary?]
	movl	8(%ecx),%edi	#edi -> SU(L)  [is this necessary?]
	orl	%edx,%edx	#is SD(L) null pointer?  [is this necessary?]
	jz	pointer_down	#if no SD(L), L is first chunk its size
	movl	$0,8(%ecx)	#SU(L) = 0, i.e. unlinked
	movl	%edi,8(%edx)	#SU(SD(L)) -> SU(L)
	orl	%edi,%edi	#is SU(L) a null pointer?
	jz	do_addr	#if SU(L) is null, no SU(L)
	movl	%edx,12(%edi)	#SD(SU(L)) -> SD(L)
	jmp	do_addr
#
# the L chunk is 1st in size-links (unlink from pointer on downstream side)
#
pointer_down:
	movl	$0,8(%ecx)	#SU(L) = 0 (unlinked)
	movl	(%ecx),%ebx	#ebx = size(L) = addr-uplink(L)
	subl	$17,%ebx	#ebx = size - 17 = data size - 1
	shrl	$4,%ebx	#ebx = (size-1) / 16 = pointer _
	cmpl	$16,%ebx	#pointer _ is beyond big-chunk pointer?
	jbe	small_unlink	#no, ebx is ok
	movl	$16,%ebx	#ebx = big-chunk pointer _
small_unlink:
	movl	%edi,_pointers(,%ebx,4)	#pointer header past L to SU(L)
	orl	%edi,%edi	#is SU(L) a null pointer?
	jz	do_addr	#if so, there is no SU(L)
	movl	$0,12(%edi)	#mark SU(L) as 1st in size-links
#
# update address links in L and XH to abolish M and H (merge L, M, H into L)
#
do_addr:
	movl	(%eax),%edi	#edi = size(H)
	movl	%eax,%ebx
	subl	%ecx,%ebx	#ebx = addr(H) - addr(L) = size(L) + size(M)
	jns	duh1	#DEBUG
	call	__eeeAllocation	#block allocated
duh1:				#DEBUG
	addl	%edi,%ebx	#ebx = size(L) + size(M) + size(H)
	movl	%ebx,(%ecx)	#addr-uplink(L) = size(L) + size(M) + size(H)
	btsl	$31,%ebx	# XH is allocated
	movl	%ebx,4(%eax,%edi,1)	#addr-downlink(XH) = new-size(L)
	btrl	$31,%ebx	# ebx is down distance
#
# link new L into size-links
#
	movl	%ecx,%esi	#esi -> chunk to enter in size-links
	jmp	hi_not_lo_not
#
#
# the H chunk (above) is free; the L chunk (below) is not free
#
hi_free_lo_not:
	movl	$0,12(%esi)	#mark this header free
	movl	(%eax),%edi	#edi = size(H)
	movl	%eax,%ebx
	subl	%esi,%ebx	#ebx = addr(H) - addr(M) = size(M)
	jns	duh2	#DEBUG
#	int	3		;block allocated
	call	__eeeAllocation	#block allocated
duh2:				#DEBUG
	addl	%edi,%ebx	#ebx = size(M) + size(H)
	movl	%ebx,(%esi)	#addr-uplink(M) = size(M) + size(H)
#
# go link new L into size-links
#
	btsl	$31,%ebx	# XH is allocated
	movl	%ebx,4(%eax,%edi,1)	#addr-downlink(XH) = new-size(L)
	btrl	$31,%ebx	# ebx is down distance
	jmp	hi_not_lo_not	#addr-uplink and addr-downlink not free now
#
# the H chunk (above) is not free (check the L chunk)
#
hi_not:
	btl	$31,4(%ecx)	#is L header allocated?
	jc	hi_not_lo_not	#yes
#
# the H chunk is not free, the L chunk is free
# unlink L from size-links of chunks downstream and upstream from L
#
hi_not_lo_free:
	movl	$0,12(%esi)	#mark this header free
	movl	8(%ecx),%edi	#edi = SU(L)
	orl	%edx,%edx	#is SD(L) a null pointer?  [is this necessary?]
	jz	pointer_case	#yes, L is 1st chunk its size
	movl	%edi,8(%edx)	#SU(SD(L)) = SU(L)
	orl	%edi,%edi	#is SU(L) a null pointer?
	jz	addr_do	#yes, we have no SU(L)
	movl	%edx,12(%edi)	#SD(SU(L)) = SD(L)
	jmp	addr_do
#
# the L chunk is 1st in size-links (unlink from pointer on downstream side)
#
pointer_case:
	movl	(%ecx),%ebx	#ebx = size(L) = addr-uplink(L)
	subl	$17,%ebx
	shrl	$4,%ebx	#ebx = (size-1) / 16 = pointer _
	cmpl	$16,%ebx	#pointer _ is beyond big-chunk pointer?
	jbe	wimpy_unlink	#no, ebx is ok
	movl	$16,%ebx	#ebx = big-chunk pointer _
wimpy_unlink:
	movl	%edi,_pointers(,%ebx,4)	#point header past L to size-uplink(L)
	orl	%edi,%edi	#is SU(L) null pointer?
	jz	addr_do	#yes, we have no SU(L)
	movl	$0,12(%edi)	#mark SU(L) as 1st in size-links
#
# update address links in L to abolish M  (merge L, M, into L)
#
addr_do:
	movl	%eax,%edi
	subl	%ecx,%edi	#edi = addr(H) - addr(L) = new-size(L)
	jns	duh3	#DEBUG
	call	__eeeAllocation	#block allocated
duh3:				#DEBUG
	movl	%edi,(%ecx)	#addr-uplink(L) = new-size(L)
	btsl	$31,%edi	#mark H allocated
	movl	%edi,4(%eax)	#addr-downlink(H) = new-size(L)
	btrl	$31,%edi	#restore edi
	movl	%ecx,%esi	#esi -> L (prepare to put L in size-links)
#
# the H chunk is not free, the L chunk is not free
#
hi_not_lo_not:
	movl	$0,12(%esi)	#mark this header free
	movl	(%esi),%ebx	#ebx = size(M) = addr-uplink(M)
	subl	$17,%ebx
	shrl	$4,%ebx	#ebx = (size-1) / 16 = pointer _
	cmpl	$16,%ebx	#pointer _ is beyond big-chunk pointer?
	jbe	free_any	#no, ebx is ok
	movl	$16,%ebx	#ebx = big-chunk pointer _
free_any:
	movl	_pointers(,%ebx,4),%eax	#eax -> 1st header of this sie
	movl	%esi,_pointers(,%ebx,4)	#pointer -> this header
	movl	%eax,8(%esi)	#size-uplink(M) = size-uplink(pointer)
	orl	%eax,%eax	#was old pointer null?
	jz	no_upstream	#in that case, there's no upstream header
	movl	%esi,12(%eax)	#size-downlink(size-upstream) -> M
no_upstream:
	movl	$0,12(%esi)	#SD(M) = 0 (mark as 1st this size)
	ret
#
#
.text
#
# #####################
# #####  xlib1.s  #####  Clone and concatenate routines
# #####################
#
# ************************
# *****  %_clone.a0  *****  clones object pointed to by eax
# ************************
#
# in:	eax -> object to clone
# out:	eax -> cloned object
#
# Destroys: edx, esi, edi.
#
# Returns 0 in eax if eax was 0 on entry or if size of object to clone is 0.
#
# %_clone.a0 was called %_clone.object.return.addr.a0 in the 88000 version.
#
__clone.a0:
	orl	%eax,%eax	#were we passed a null pointer?
	jz	xret	#yes: get out of here
	pushl	%ebx	#must not trash ebx (accumulator 1)
	pushl	%ecx	#ecx is part of accumulator 1
#;
	movzwl	-4(%eax),%ebx	#ebx = _ of bytes per element
	movl	-8(%eax),%esi	#esi = _ of elements
	orl	%esi,%esi	# test esi for 0x00  (zero elements)
	jnz	ok.a0	# object not empty
	popl	%ecx	# restore ecx
	popl	%ebx	# restore ebx
	ret		# done
#
ok.a0:
	movl	%esi,%edx	#save _ of elements for later
	imul	%ebx,%esi	#esi = size of object to clone
	orl	%esi,%esi	#imul leaves ZF in a random state!
	jz	clone.a0.null	#if object is zero len, quit and return null ptr
#;
	pushl	%esi	#save _ of bytes for rep movsd, later
	incl	%esi	#add one to size, for terminator (is this
	pushl	%eax	# necessary?)
	pushl	%edx
	call	_____calloc	#esi -> data area of new block
	popl	%edx
	popl	%eax
	popl	%ecx	#ecx = _ of bytes for rep movsd
#;
	movl	-4(%eax),%ebx	#ebx = info word of original object
	btrl	$24,%ebx	#ebx
	orl	__WHOMASK,%ebx	#OR whomask into info word
#;
	movl	%ebx,-4(%esi)	#store (old_infoword | whomask) to new infoword
	movl	%edx,-8(%esi)	#store old _ of elements to new object's header
#;
	movl	%esi,%ebx	#save pointer to new block for later
	movl	%esi,%edi	#edi -> data area of new block
	movl	%eax,%esi	#esi -> data area of old block
	addl	$3,%ecx	#round _ of bytes to move up to next
#;			; four-word boundary
	shrl	$2,%ecx	#ecx = _ of dwords to move
	cld		#make sure direction is right
	rep
	movsl		#clone it!
#;
	movl	%ebx,%eax	#eax -> cloned object's data area
	popl	%ecx
	popl	%ebx
	ret
#
clone.a0.null:
	xorl	%eax,%eax	#return null pointer
	popl	%ebx
	popl	%ecx
#;
xret:
	ret
#
#
# ************************
# *****  %_clone.a1  *****  clones object pointed to by eax
# ************************
#
# in:	ebx -> object to clone
# out:	ebx -> cloned object
#
# Destroys: esi, edi.
#
# Returns 0 in ebx if ebx was 0 on entry or if size of object to clone is 0.
#
# %_clone.a1 is the same as %_clone.a0, except that its input and output
# values are in ebx, not eax.
#
# %_clone.a1 was called %_clone.object.return.addr.a1 in the 88000 version.
#
__clone.a1:
	pushl	%edx
	xchgl	%ebx,%eax
	call	__clone.a0
	xchgl	%ebx,%eax	#isn't this silly?
	popl	%edx
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a0.plus.a1.vv  ***** concatenates two permanent
# ********************************************** variables
#
# in:	eax -> first string
#	ebx -> second string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a0.plus.a1.vv:
__concat.string.a0.eq.a0.plus.a1.vv:
	pushl	%eax
	pushl	%ebx
	pushl	$0	#"vv" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a0.plus.a1.vs  ***** concatenates permanent and
# ********************************************** temporary variable
#
# in:	eax -> first string
#	ebx -> second string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a0.plus.a1.vs:
__concat.string.a0.eq.a0.plus.a1.vs:
	pushl	%eax
	pushl	%ebx
	pushl	$2	#"vs" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a0.plus.a1.sv  ***** concatenates temporary and
# ********************************************** permanent variable
#
# in:	eax -> first string
#	ebx -> second string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a0.plus.a1.sv:
__concat.string.a0.eq.a0.plus.a1.sv:
	pushl	%eax
	pushl	%ebx
	pushl	$4	#"sv" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a0.plus.a1.ss  ***** concatenates two temporary
# ********************************************** variables
#
# in:	eax -> first string
#	ebx -> second string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a0.plus.a1.ss:
__concat.string.a0.eq.a0.plus.a1.ss:
	pushl	%eax
	pushl	%ebx
	pushl	$6	#"ss" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a1.plus.a0.vv  ***** concatenates two permanent
# ********************************************** variables
#
# in:	eax -> second string
#	ebx -> first string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a1.plus.a0.vv:
__concat.string.a0.eq.a1.plus.a0.vv:
	pushl	%ebx
	pushl	%eax
	pushl	$0	#"vv" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a1.plus.a0.vs  ***** concatenates permanent and
# ********************************************** temporary variable
#
# in:	eax -> second string
#	ebx -> first string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a1.plus.a0.vs:
__concat.string.a0.eq.a1.plus.a0.vs:
	pushl	%ebx
	pushl	%eax
	pushl	$2	#"vs" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a1.plus.a0.sv  ***** concatenates temporary and
# ********************************************** permanent variable
#
# in:	eax -> second string
#	ebx -> first string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a1.plus.a0.sv:
__concat.string.a0.eq.a1.plus.a0.sv:
	pushl	%ebx
	pushl	%eax
	pushl	$4	#"sv" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# **********************************************
# *****  concat.ubyte.a0.eq.a1.plus.a0.ss  ***** concatenates two temporary
# ********************************************** variables
#
# in:	eax -> second string
#	ebx -> first string
# out:	eax -> first string + second string
#
# Destroys: ebx, ecx, edx, esi, edi.
#
__concat.ubyte.a0.eq.a1.plus.a0.ss:
__concat.string.a0.eq.a1.plus.a0.ss:
	pushl	%ebx
	pushl	%eax
	pushl	$6	#"ss" marker
	call	main.concat	#eax -> new string
	addl	$12,%esp
	ret
#
#
# *************************
# *****  main.concat  *****  main string concatenator
# *************************
#
# #######################################
# ###########  July 15, 1994  ###########
# #####  APPEARS TO HAVE A PROBLEM  #####
# #####  If a1 string has a header  #####
# #####  that has zero elements, a  #####
# #####  memory allocation problem  #####
# #####  occurs after concatenate!  #####
# #####  try: "gonzo$ = a0$ + a1$"  #####
# #######################################
# #######################################
#
#
# in:	arg2 -> string a0
# 	arg1 -> string a1
#	arg0 -> index corresponding to entry point (see chart below)
# out:	eax -> new string, consisting of string a1 appended to string a0
#
# Destroys: ebx, ecx, edx, esi, edi.
#
# Local variables:
#	[ebp-4] = size of a0
#	[ebp-8] = size of a1
#	[ebp-12] = index into jump table
#	[ebp-16] = return value
#	[ebp-20] = LEN(a0) + LEN(a1)   (not counting null terminator)
#
# The returned string is always allocated in dynamic memory.  The
# input strings are both assumed to have a # of bytes per element of 1,
# so that there's no need to perform a multiply to determine the size
# of a string.
#
# For efficiency, i.e. to prevent unnecessary string copying and realloc'ing,
# there are four entry points, each one's label having one of the following
# suffixes:
#
#     Suffix	Meaning					  Index
#	vv	a0 is a variable,   a1 is a variable	    0
#	vs	a0 is a variable,   a1 is on the stack	    2
#	sv	a0 is on the stack, a1 is a variable	    4
#	ss	a0 is on the stack, a1 is on the stack	    6
#
# The number in the "Index" column is the number that needs to be passed
# in edx to indicate which entry point the main concatenator was called
# from.
#
# "On the stack" means that the string is a temporary variable, which
# holds a value that will not be referenced after the current expression
# has been evaluated.  It is the responsibility of the main concatenator
# to free temporary variables that it is passed.  However, in some cases,
# e.g. when a temporary variable is concatenated with a null string, the
# most efficient action is to simply return the temporary variable
# without freeing it.
#
# There are seven possible results:
#
#	A  extended clone of a0 (a1 is copied onto end of clone of a0)
#	B  exact clone of a0
#	C  a1 (exact same pointer)
#	D  exact clone of a1
#	E  null
#	F  extension of a0 (a1 is copied onto end of a0)
#	G  a0 (exact same pointer)
#
# The following two tables list the conditions required for each result:
#
#	When a1 is non-null and a1's size > 0:
#
#	     a0 non-null and	a0 null or
#	     a0's size > 0	a0's size == 0
#	vv	    A		       D
#	vs	    A		       C
#	sv	    F		       D
#	ss	    F		       C
#
#	When a1 is null or a1's size == 0:
#
#	     a0 non-null and	a0 null or
#	     a0's size > 0	a0's size == 0
#	vv	    B		       E
#	vs	    B		       E
#	sv	    G		       E
#	ss	    G		       E
#
# The above two tables are encoded as jump addresses in concat_jump_table.
# Indexes into concat_jump_table are calculated according to the
# following formula, written in fake C:
#
#	a0null = (a0 == NULL || a0.size == 0);
#	a1null = (a1 == NULL || a1.size == 0);
#	jmp_index = (a1null * 8) + entry_index + a0null;
#
# The same number is also an index into concat_free_table, a jump table
# of addresses of routines to free strings appropriately.
#
main.concat:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$20,%esp
#
	movl	12(%ebp),%edi	#edi -> string a1
	cld
	orl	%edi,%edi	#is it a null pointer?
	jz	a1_is_null	#yes: don't look up its length
	movl	-8(%edi),%edi	#edi = length of string a1
	orl	%edi,%edi	#set ZF for coming SETZ instruction
#;
a1_is_null:
	movl	%edi,-8(%ebp)	#save length of string a1
	setz	%dl	#dl = "a1null" variable from header comment
	shlb	$3,%dl	#dl = "a1null * 8"
#
	movl	16(%ebp),%ecx	#ecx -> string a0
	orl	%ecx,%ecx	#is it a null pointer?
	jz	a0_is_null	#yes: don't look up its length
	movl	-8(%ecx),%ecx	#ecx = length of string a0
	orl	%ecx,%ecx	#set ZF for coming SETZ instruction
#;
a0_is_null:
	movl	%ecx,-4(%ebp)	#save length of string a0
	setz	%dh	#dh = "a0null" variable from header comment
#;
	addb	%dh,%dl	#dl = a0null + a1null * 4
	andl	$0xF,%edx	#edx = a0null + a1null * 4
	addl	8(%ebp),%edx	#edx = (a1null * 4) + entry_index + a0null
#;				; = index into jump tables
	movl	%edx,-12(%ebp)	#save index into jump tables
	cld		#make sure movs instructions go right way
#;
	jmp	*concat_jump_table(,%edx,4)	#concatenate them strings!
#
# ***** routines pointed to by elements of concat_jump_table
# 	on entry, edi = length of a1, ecx = length of a0
#
extend.clone.a0:
	addl	%ecx,%edi	#edi = LEN(a1) + LEN(a0)
	movl	%edi,-20(%ebp)	#save it
	movl	%edi,%esi	#esi = LEN(a1) + LEN(a0) = size of clone
	incl	%esi	#add one for null terminator
	call	______calloc	#esi -> header of new block, all else destroyed
	movl	16(%ebp),%ebx	#ebx -> string a0
	movl	-4(%ebx),%eax	#eax = a0's info word
	btrl	$24,%eax	#eax = info word with system/user bit cleared
	orl	__WHOMASK,%eax	#OR in system/user bit
	movl	%eax,12(%esi)	#clone's info word = a0's info word | $$whomask
	movl	-20(%ebp),%eax	#eax = LEN(a0) + LEN(a1)
	movl	%eax,8(%esi)	#clone's _ of elements = LEN(a0) + LEN(a1)
#;
	addl	$16,%esi	#esi -> new string
	movl	%esi,%edi	#edi -> new string
	movl	%edi,%eax	#save pointer to new string
	movl	16(%ebp),%esi	#esi -> string a0
	movl	-4(%ebp),%ecx	#ecx = LEN(a0)
#;			;edi is guaranteed to be on a 4-byte boundary
	addl	$3,%ecx	#round ecx up to next multiple of 4
	shrl	$2,%ecx	#ecx = _ of dwords to copy
	jecxz	ec0_copy_done
	rep
	movsl
#;
ec0_copy_done:
	movl	%eax,%edi	#edi -> first byte of new string
	jmp	concat.copy.a1
#
extend.a0:
	movl	16(%ebp),%esi	#esi -> string a0
	movl	-16(%esi),%edx	#edx = size of a0's chunk, including header
	subl	$16,%edx	#edx = size of a0's chunk, excluding header
	addl	%ecx,%edi	#edi = LEN(a1) + LEN(a0)
	movl	%edi,-20(%ebp)	#save LEN(a1) + LEN(a0)
	incl	%edi	#add one for null terminator
	cmpl	%edi,%edx	#will concatenated string fit in a0?
	jae	it_fits	#if chunk size >= size needed, then skip realloc
	call	_____realloc	#esi -> new block, all else destroyed
#;
it_fits:
	movl	-20(%ebp),%eax	#eax = LEN(a0) + LEN(a1)
	movl	%eax,-8(%esi)	#_ of elements = LEN(a0) + LEN(a1)
	movl	%esi,%eax	#save return value
	movl	%esi,%edi	#edi -> new block
#;
concat.copy.a1:
	addl	-4(%ebp),%edi	#edi -> byte after last byte in a0
	movl	12(%ebp),%esi	#esi -> first byte of string a1
	movl	-8(%ebp),%ecx	#ecx = _ of bytes in a1
#;
e0_byte_boundary:		#get rep movsd started on 4-byte boundary
	testl	$1,%edi	#if bit 0 = 0 then no initial bytes to copy
	jz	e0_word_boundary
	movsb		#copy first byte
	decl	%ecx	#ecx = _ of bytes left to copy
	jz	add_terminator
#;
e0_word_boundary:
	testl	$2,%edi	#if bit 1 = 0 then no initial words to copy
	jz	e0_dword_boundary
	movsw		#copy a word# now we're on dword boundary
	subl	$2,%ecx	#ecx = _ of bytes left to copy
	jz	add_terminator
#;
e0_dword_boundary:
	addl	$3,%ecx	#round ecx up to next dword boundary
	shrl	$2,%ecx	#ecx = _ of dwords to copy
	jecxz	add_terminator	#skip if no dwords to copy
	rep
	movsl		#copy a1 onto end of a0!
#;
add_terminator:
	movl	%eax,%edi	#edi -> new string
	addl	-20(%ebp),%edi	#edi -> one byte after last byte of new string
	movb	$0,(%edi)	#put null terminator at end of string
	jmp	ready.to.free	#eax still -> new string
#
#
return.null:
	movl	$0,-16(%ebp)	#return a null pointer
	jmp	ready.to.free
#
#
return.a0:
	movl	16(%ebp),%eax	#eax -> string a0
	jmp	ready.to.free	#return string a0
#
#
return.a1:
	movl	12(%ebp),%eax	#eax -> string a1
	jmp	ready.to.free	#return string a1
#
#
clone.a0:
	movl	16(%ebp),%eax	#eax -> string a0
	call	__clone.a0	#eax -> clone of a0
	jmp	ready.to.free	#return clone of a0
#
#
clone.a1:
	movl	12(%ebp),%eax	#eax -> string a1
	call	__clone.a0	#eax -> clone of a1
	jmp	ready.to.free	#return clone of a1
#
# ***** finished with routine from concat_jump_table
#	on entry: eax -> string to return
#
#
ready.to.free:
	movl	%eax,-16(%ebp)	#save return value
	movl	-12(%ebp),%edx	#edx = index into jump tables
	jmp	*concat_free_table(,%edx,4)	#free what needs to be freed
#
# ***** routines to free what needs to be freed
#
free.a0:
	movl	16(%ebp),%esi	#esi -> string a0
	call	_____free
	jmp	concat.done
#
#
free.a0.a1:
	movl	16(%ebp),%esi	#esi -> string a0
	call	_____free
#;
#; fall through
#;
free.a1:
	movl	12(%ebp),%esi	#esi -> string a1
	call	_____free
	jmp	concat.done
#
# ***** finished freeing
#
free.nothing:
concat.done:
	movl	-16(%ebp),%eax	#eax -> string to return
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# *****  jump table for concatenate routines  *****
#
.align	8
concat_jump_table:
#		    a1 has string
#	a0 has string		a0 has no string
.long	extend.clone.a0,	clone.a1	#vv
.long	extend.clone.a0,	return.a1	#vs
.long	extend.a0,		clone.a1	#sv
.long	extend.a0,		return.a1	#ss
#		   a1 has no string
#	a0 has string		a0 has no string
.long	clone.a0,		return.null	#vv
.long	clone.a0,		return.null	#vs
.long	return.a0,		return.null	#sv
.long	return.a0,		return.null	#ss
#;
concat_free_table:
#		    a1 has string
#	a0 has string		a0 has no string
.long	free.nothing,		free.nothing	#vv
.long	free.a1,		free.nothing	#vs
.long	free.nothing,		free.nothing	#sv
.long	free.a1,		free.nothing	#ss
#		   a1 has no string
#	a0 has string		a0 has no string
.long	free.nothing,		free.nothing	#vv
.long	free.a1,		free.a1		#vs
.long	free.nothing,		free.a0		#sv
.long	free.a1,		free.a0.a1	#ss
#
#
.text
#
# #####################
# #####  xliba.s  #####  Low-level array processing
# #####################
#
# ************************
# *****  %_DimArray  *****  dimensions an array
# ************************  (recursive to handle multi-dimensional arrays)
#
# in:	arg11 = upper bound of eighth dimension
#	arg10 = upper bound of seventh dimension
#	arg9 = upper bound of sixth dimension
#	arg8 = upper bound of fifth dimension
#	arg7 = upper bound of fourth dimension
#	arg6 = upper bound of third dimension
#	arg5 = upper bound of second dimension
#	arg4 = upper bound of first dimension		[ebp+24]
#	arg3 unused
#	arg2 = word 3 of header (info word)		[ebp+16]
#	arg1 = # of dimensions (maximum allowed: 8)	[ebp+12]
#	arg0 -> array address (i.e. [arg0] -> array)	[ebp+8]
# out:
#	eax -> highest-dimension array (to be stored in handle)
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] = dim.number, i.e. current dimension
#	[ebp-8] = # of elements in current dimension
#
#  array headers look like this:
#
#	word3 = info.word = info.byte + data.type.byte + bytes.per.element.word
#	word2 = upper.bound of this dimension
#	word1 = address downlink  (MSb = 1 if chunk allocated (new 01-June-93)
#	word0 = address uplink
#
#  info word bits:
#	bit 31 = NO LONGER USED (the next line is obsolete)
#	bit 31 = ALLOCATED  	(must always = 1 on allocated chunks)
#       bit 30 = ARRAY BIT  	(1 = array, 0 = string)
#	bit 29 = NON-LOW-DIM	(1 = non-lowest-dimension, 0 = lowest dimension)
#	bit 28 =
#	bit 27 =
#	bit 26 =
#	bit 25 =
#	bit 24 = INFOMASK       (1 = USER array, 0 = SYSTEM array)
#
#
#  FUNCTION XLONG DimArray ()
#    IF addr(this.array) THEN FreeArray (this.array)
#    INC dim.number
#    upper.bound = dim.<dim.number>
#    IF lowest.dim (ie dim.number >= dim.count) THEN
#      header.addr = calloc (size.this.dim)
#      IF ERROR THEN RETURN ERROR
#      word3 = info.word (info, data.type, bytes.per.element)
#      word2 = upper.bound
#      DEC dim.number
#      RETURN header.addr
#    ELSE
#      this.array.addr = calloc (size.this.dim)
#      IF ERROR THEN RETURN ERROR
#      word3 = info.word + not.lowest.dim
#      word2 = upper.bound
#      FOR element = 0 to upper.bound
#        next.array.addr = DimArray (dim.number + 1)
#        this.array.data.addr [element] = next.array.addr
#        IF ERROR THEN RETURN ERROR
#      NEXT element
#      DEC dim.number
#      RETURN this.array.addr
#    ENDIF
#  END FUNCTION
#
__DimArray:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
#;
	movl	__WHOMASK,%eax	#eax holds system/user bit
	orl	%eax,16(%ebp)	#OR system/user bit into info word
	movl	8(%ebp),%esi	#esi -> base address of array
	orl	%esi,%esi	#null pointer?
	jz	DimArray	#yes: don't bother to free it
	call	__FreeArray	#no: free existing array first
DimArray:
	movl	$0,-4(%ebp)	#dim.number starts at zero
	call	dim.dim	#do the dimensioning
#;
	movl	%esi,%eax	#eax -> base address of array
	movl	%ebp,%esp
	popl	%ebp
	ret
#;
# ***** recursive entry point  (does not modify ebp or allocate local frame)
#	in:	[ebp-4] = dim.number = last dimension that was dimensioned
#	out:	esi -> base address of dimensioned array
#	destroys: eax, ebx, ecx, edx, edi, [ebp-8]
#
dim.dim:
	incl	-4(%ebp)	#next dim.number
	movl	-4(%ebp),%ebx	#ebx = dim.number, i.e. current dimension
	movl	20(%ebp,%ebx,4),%eax	#eax = upper.bound for current dimension
	xorl	%esi,%esi	#prepare to return null pointer if necessary
	addl	$1,%eax	#eax = _ of elements in current dim
	movl	%eax,-8(%ebp)	#save it
	jle	dim.dim.exit	#if negative upper bound (illegal), then
	cmpl	12(%ebp),%ebx	#is current dim < total _ of dims?
	jl	not.lowest.dim	#yes: not yet on lowest dim
#;
#; create lowest-dimension array
#;
lowest.dim:
	movl	%eax,%esi	#esi = _ of elements in current dimension
	movzwl	16(%ebp),%eax	#eax = _ of bytes per element
	imul	%eax,%esi	#esi = total _ of bytes in array
	call	______calloc	#allocate and zero array
	orl	%esi,%esi	#error?
	jz	dim.dim.exit	#yep (88000 version jumps to dim.dim.exit)
	movl	16(%ebp),%eax	#eax = info word
	movl	%eax,12(%esi)	#put info word in array's header
	movl	-8(%ebp),%eax	#eax = _ of elements in lowest dimension
	movl	%eax,8(%esi)	#put _ of elements in array's header
	addl	$16,%esi	#esi -> data area of array
	jmp	dim.dim.exit
#
# create non-lowest-dimension array
#	in: eax = # of elements in current dimension
#
not.lowest.dim:
	leal	(,%eax,4),%esi	#esi = _ elems in current dim * 4 = _ of bytes
	call	______calloc	#allocate and zero array
	orl	%esi,%esi	#error?
	jz	dim.dim.exit	#yep (88000 version jumps to dim.dim.exit)
#;
	movl	16(%ebp),%eax	#eax = info word
	movw	$4,%ax	#bytes per element = 4
	orl	$0x20000000,%eax	#not.lowest.dim = TRUE  (in info word)
	movl	%eax,12(%esi)	#put info word in array's header
	movl	-8(%ebp),%eax	#eax = _ of elements in current dimension
	movl	%eax,8(%esi)	#put _ of elements in array header
#;
	leal	16(%esi),%ebx	#ebx -> array's data area
	xorl	%ecx,%ecx	#ecx = current element number
	movl	%eax,%edx	#edx = _ of elements in current dimension
#;
dim.loop:
	pushl	%ebx	#watch out for those recursive functions!
	pushl	%ecx
	pushl	%edx
	call	dim.dim	#allocate array for current element
	popl	%edx	# esi -> its base address
	popl	%ecx
	popl	%ebx
	orl	%esi,%esi	#error?
	jz	dim.dim.exit	#yep
	movl	%esi,(%ebx,%ecx,4)	#store pointer for current element
	incl	%ecx	#current element number++
	cmpl	%edx,%ecx	#current element = _ of elements?
	jne	dim.loop	#no: keep going
	movl	%ebx,%esi	#esi -> base address of just-allocated array
#;
dim.dim.exit:
	decl	-4(%ebp)	#dim.number--
	ret		#esi -> base address of just-allocated array
#
#
# *************************
# *****  %_FreeArray  *****  frees an array
# *************************  (recursive to handle multi-dimensional arrays)
#
# in:	esi -> base address of array to free
#
# out:	esi < 0 iff error, 0 if ok
#
# destroys: ebx, ecx, edi  (must not destroy "eax/edx" return values)
#
# local variables:
#	[ebp-4]	= current element
#	[ebp-8] -> array to free
#
#  FUNCTION XLONG FreeArray (array.address)
#    lowest.dim = (non.lowest.dim bit in info word = 0)
#    IF (lowest.dim AND type.numeric) OR (this.is.a.string...not.an.array) THEN
#      ERROR = free ( this.array.header.addr )
#      RETURN ERROR
#    ELSE
#      FOR element = 0 to upper.bound
#        ERROR = FreeArray ( this.array.data [element] )
#        IF ERROR THEN RETURN ERROR
#      NEXT element
#      ERROR = free ( this.array.header.addr )
#      RETURN ERROR
#    END IF
#  END FUNCTION
#
__FreeArray:
#	push	eax		; save eax  (return value from function)
#	push	edx		; save edx  (ditto if GIANT or DOUBLE)
	pushl	%ebp
	movl	%esp,%ebp
	pushl	%eax	# save eax  (return value from function)
	pushl	%edx	# save edx  (ditto if GIANT or DOUBLE)
	subl	$8,%esp
	orl	%esi,%esi	#is array free already?
	jz	a.free.exit	#yes
	movl	-4(%esi),%eax	#eax = info word
	testl	$0x40000000,%eax	#test bit 30: array/string bit
	jz	ok.to.free.this	#if it's a string, free it
	testl	$0x20000000,%eax	#test bit 29: no-low-dim bit
	jnz	not.lowest.free	#if not lowest dim, free its elements
#	and	eax,0x001F0000	;eax = just data-type field from info word
	andl	$0x00FF0000,%eax	#eax = just data-type field from info word
	cmpl	$0x00130000,%eax	#is object of string.type?
	je	not.lowest.free	#yes: free strings first (?)
#
# lowest.dim and numeric, or string... so free it
#
ok.to.free.this:
	call	_____free	#free the object
	orl	%esi,%esi	#error?
	jz	a.free.bad
a.free.ok:
	xorl	%esi,%esi	#esi = 0 to indicate success
a.free.exit:
	movl	%ebp,%esp
	movl	-4(%ebp),%eax	#
	movl	-8(%ebp),%edx	#
	popl	%ebp
#	pop	edx		; restore original edx
#	pop	eax		; restore original eax
	ret
#
not.lowest.free:
	xorl	%edx,%edx	#current element number = 0
	movl	%edx,-12(%ebp)	#save current element number
	movl	%esi,-16(%ebp)	#save pointer to first element of array
#
a.free.loop:
	movl	(%esi,%edx,4),%esi	#esi -> chunk to free
	orl	%esi,%esi	#null element?
	jz	a.free.null	#yes: go to next element
	call	__FreeArray	#no: free it and all its sub-arrays (and so on)
#
	cmpl	$-1,%esi	# error ?
	je	a.free.exit	# yes: return without freeing the rest
#
a.free.null:
	movl	-16(%ebp),%esi	#esi -> first element of array to free
	incl	-12(%ebp)	#current element number++
	movl	-12(%ebp),%edx	#edx = current element number
	cmpl	-8(%esi),%edx	#current element number >= number of elements?
	jb	a.free.loop	#no: free next element
	call	_____free	#free current array
	orl	%esi,%esi	#error?
	jnz	a.free.ok	#no: say so and return
a.free.bad:			#esi assumed to be zero on entry
	decl	%esi	#esi is now < 0 to indicate error
	movl	%ebp,%esp
	movl	-4(%ebp),%eax	#
	movl	-8(%ebp),%edx	#
	popl	%ebp
#	pop	edx		; restore original edx
#	pop	eax		; restore original eax
	ret
#
#
#
#  ****************************
#  *****  %_RedimArray    *****  redimensions an array
#  ****************************  contents are not altered!
#
# in:	arg11 = upper bound of eighth dimension
#	arg10 = upper bound of seventh dimension
#	arg9 = upper bound of sixth dimension
#	arg8 = upper bound of fifth dimension
#	arg7 = upper bound of fourth dimension
#	arg6 = upper bound of third dimension
#	arg5 = upper bound of second dimension
#	arg4 = upper bound of first dimension		[ebp+24]
#	arg3 unused
#	arg2 = word 3 of header (info word)		[ebp+16]
#	arg1 = # of dimensions (maximum allowed: 8)	[ebp+12]
#	arg0 -> array address (i.e. [arg0] -> array)	[ebp+8]
# out:
#	eax -> highest-dimension array (to be stored in handle)
#	       or < 0 if error
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] = dim.number, i.e. current dimension
#	[ebp-8] = new # of elements in current dimension
#
# FUNCTION XLONG RedimArray (arrayAddress)
#   dimNumber = 0
#   RedimArraySmaller (arrayAddress)
#   dimNumber = 0
#   RedimArrayLarger (arrayAddress)
# END FUNCTION
#
# FUNCTION XLONG RedimArraySmaller (arrayAddress)
#   INC dimNumber
#   newLowestDim = (dimNumber >= dimCount)
#   IF newLowestDim THEN
#     IFZ oldLowestDim (from info word) THEN RETURN (error.node.data.mismatch)
#     IF (newType != oldType) THEN RETURN (error.type.mismatch)
#     IF (newUpperBound < oldUpperBound) THEN
#       IF oldStringType (from info word) THEN
#         FOR element = newUpperBound+1 TO oldUpperBound
#           error = free (arrayAddress [element])            ' free string
#           IF error THEN DEC dimNumber: RETURN (error)      ' error in free
#         NEXT element
#       END IF
#       arrayAddress [element] = recalloc (arrayAddress [element], newSize)
#       update info word with new # of elements
#     END IF
#   ELSE
#     IF oldLowestDim (from info word) THEN RETURN (error.dim.data.mismatch)
#     FOR element = 0 TO oldUpperBound
#       IF (element <= newUpperBound) THEN                   ' in old and new
#         newAddr = RedimArraySmaller ( thisArrayData [element] )
#         IF (newAddr < 0) THEN DEC dimNumber: RETURN (newAddr)  (return error)
#         thisArrayData [element] = newAddr
#       ELSE
#         error = FreeArray ( thisArrayData [element] )
#         thisArrayData [element] = 0
#         IF error THEN DEC dimNumber: RETURN (error)
#       END IF
#     NEXT element
#     DEC dimNumber
#     RETURN (thisArrayBaseAddr)
#   END IF
# END FUNCTION
#
# FUNCTION XLONG RedimArrayLarger (arrayAddress)
#   INC dimNumber
#   newUpperBound = dim.[dim.number]
#   newLowestDim = (dimNumber >= dimCount)
#   IF newLowestDim THEN
#     IFZ oldLowestDim THEN RETURN (error.node.data.mismatch)
#     IF (oldType != newType) THEN RETURN (error.type.mismatch)
#     dataAddr = recalloc (size.this.dim)        ' newUpperBound * bytesPerEle
#     IF (dataAddr < 0) THEN DEC dimNumber: RETURN (dataAddr)   ' error
#     update word2/word3 with newUpperBound      '
#     RETURN (dataAddr)
#   ELSE
#     arrayAddr = recalloc (size.this.dimension) ' newUpperBound * bytesPerEle
#     IF (arrayAddr < 0) THEN RETURN (arrayAddr) ' error
#     update word2/word3 with newUpperBound      '
#     FOR element = 0 to new.upper.bound
#       IF this.array.data.base.addr [element] THEN
#         arrayAddr = redim_array_larger (this.array.data.addr [element])
#       ELSE
#         IF (element <= oldUpperBound) THEN DEC dimNumber: RETURN (error)
#         arrayAddr = DimArray (this.array.data.base.addr [element])
#       ENDIF
#       IF (arrayAddr < 0) THEN DEC dimNumber: RETURN (arrayAddr)   ' error
#       thisArray [element] = arrayAddr
#     NEXT element
#     DEC dimNumber
#     RETURN (arrayAddr)
#   ENDIF
# END FUNCTION
#
__RedimArray:
	cmpl	$0,4(%esp)	#null array?
	je	__DimArray	#yes: if never dimensioned, same as DIM
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	movl	$0,-4(%ebp)	#dim.number = 0
	movl	8(%ebp),%esi	#esi = base address of array
	call	redim.array.smaller
	cmpl	$-1,%esi	# error ?
	je	redim_exit	# yes: return without freeing the rest
#
	movl	$0,-4(%ebp)	# dim.number = 0
	call	redim.array.larger
#
redim_exit:
	movl	%esi,%eax	# eax -> new array
	movl	%ebp,%esp
	popl	%ebp
	ret
#
# ***** recursive entry point  (does not modify ebp or allocate local frame)
#	redimensions all arrays that are being changed to smaller dimensions
#	in:	[ebp-4] = dim.number = last dimension redim'ed
#		esi -> array to redimension
#	out:	esi -> redimensioned array (may be different than on entry)
#
redim.array.smaller:
	orl	%esi,%esi	#null array?
	jz	redim.null	#yes: don't redimension it smaller
	incl	-4(%ebp)	#INC dimNumber
	movl	-4(%ebp),%ebx	#ebx = dim.number = current dimension
	movl	-4(%esi),%eax	#eax = info word of array
	movl	-8(%esi),%edx	#edx = old _ of elements
	decl	%edx	#edx = old upper bound
#;
	cmpl	12(%ebp),%ebx	#at new lowest dimension?
	jne	rs.not.lowest.dim	#no: at an array of pointers to arrays
rs.lowest.dim:			#yes: at an array of actual data
	movl	%eax,%edi	#save old info word
	xorl	16(%ebp),%eax	#bit 29 of eax = 1 iff not-lowest-dim bit of
	testl	$0x20000000,%eax	#changed number of dims?
	jnz	redim.changed.dims	#yes: error: new _ of dims
#
# I have no check for a type mismatch (??? who and why ???)
#
	movl	20(%ebp,%ebx,4),%ecx	#ecx = new upper bound for current dimension
	movl	%ecx,-8(%ebp)	#save it
	cmpl	%edx,%ecx	#new upper bound less than old upper bound?
	jge	rs.recalloc	#no: there's nothing to free
#;
	movl	-4(%esi),%eax	#eax = info word
	andl	$0x00FF0000,%eax	#eax = just data-type field from info word
	cmpl	$0x00130000,%eax	#is array of string type?
	je	rs.free.strings	#yes: free them extraneous strings
#;
	testl	$0x20000000,%edi	#lowest dim contains arrays?
	jz	rs.recalloc	#no: there's nothing to free
rs.free.strings:
	incl	%ecx	#ecx = current element = newUpperBound + 1
rs.free.string.loop:
	pushl	%esi
	pushl	%ecx
	pushl	%edx
	movl	(%esi,%ecx,4),%esi	#esi -> array[elem]   (i.e. current string)
	call	_____free	#free current element
	popl	%edx
	popl	%ecx
	movl	%esi,%eax	#eax = result from _____free
	popl	%esi
	cmpl	$-1,%eax	# error ?
	je	redim.malloc.error	# yes: return without more free
	incl	%ecx	# INC current element
	cmpl	%edx,%ecx	# past old upper bound?
	jbe	rs.free.string.loop	#no: free another string
#
rs.recalloc:
	movl	-8(%ebp),%edi	# edi = new upper bound
	incl	%edi	# edi = new _ of elements in current dimension
	movzwl	-4(%esi),%eax	#eax = _ of bytes per element
	imul	%eax,%edi	# edi = _ of bytes required for new array
#
	call	_____recalloc	# esi -> resized array
	orl	%esi,%esi	# esi = 0 = recalloc to empty string/array
	jz	rs.done	# yes
	cmpl	$-1,%esi	# error ?
	je	redim.malloc.error	# yes: return without more free
#
	movl	-8(%ebp),%eax	# eax = new upper bound of current dimension
	incl	%eax	# eax = new _ of elements
	movl	%eax,-8(%esi)	# store it in header of array
	jmp	rs.done
#
rs.not.lowest.dim:		# we're at an array of pointers to arrays
	testl	$0x20000000,%eax	# at old lowest dimension or original array?
	jz	redim.changed.dims	#yes: error: new _ of dims
	xorl	%ecx,%ecx	# ecx = current elem = 0
	movl	20(%ebp,%ebx,4),%ebx	# ebx = new upper bound for current dimension
rs.shrink.loop:
	cmpl	%ebx,%ecx	# current elem <= new upper bound?
	ja	rs.free.array	# no: free current element
	movl	%esi,%edi	# edi -> current array
	movl	(%esi,%ecx,4),%esi	# esi = current element
	pushl	%edi
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	call	redim.array.smaller	#esi = new current element
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%edi	# edi -> current array
	cmpl	$-1,%esi	# error ?
	je	rs.done	# yes: return without freeing the rest
	movl	%esi,(%edi,%ecx,4)	#store new current element
	movl	%edi,%esi
	jmp	rs.shrink.loop.end
#
#
rs.free.array:			#current elem is beyond new dim: free it
	pushl	%esi
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	movl	(%esi,%ecx,4),%esi	#esi = current element
	call	__FreeArray
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax	# eax -> current array
	movl	$0,(%eax,%ecx,4)	# zero current elem (unnecessary, I think)
	cmpl	$-1,%esi	#
	je	rs.done	#
	movl	%eax,%esi	# esi -> current array
rs.shrink.loop.end:
	incl	%ecx	# INC elem
	cmpl	%edx,%ecx	# past old upper bound?
	jbe	rs.shrink.loop	# no: keep going
	jmp	rs.done	# yes: all done
#
# the following four entry points are called from both redim.array.smaller
# and redim.array.larger
#
redim.malloc.error:		#recalloc or free got an error
redim.changed.dims:		#attempted to change _ of dims
redim.ragged:			#discovered ragged array
	movl	$-1,%esi	#esi < 0 to indicate error
rs.done:
rl.done:
	decl	-4(%ebp)	#DEC dimNumber
redim.null:			#tried to redim null sub-array (esi assumed 0)
	ret		#end of redim.array.smaller
#
#
# ***** recursive entry point  (does not modify ebp or allocate local frame)
#	redimensions all arrays that are being changed to larger dimensions
#	in:	[ebp-4] = dim.number = last dimension redim'ed
#		esi -> array to redimension
#	out:	esi -> redimensioned array (may be different than on entry)
#
redim.array.larger:
	incl	-4(%ebp)	#INC dimNumber
	movl	-4(%ebp),%ebx	#ebx = dimNumber
	cmpl	12(%ebp),%ebx	#at new lowest dim?
	movl	20(%ebp,%ebx,4),%ebx	#ebx = new upper bound
	jb	rl.not.lowest.dim	#no: we're at an array of pointers
#;
rl.lowest.dim:				#yes: we're at some real data
	orl	%ebx,%ebx	#ebx < 0 means put empty array here	# 95/03/03
	js	rl.done	#done					# 95/03/03
	pushl	%ebx
	movzwl	-4(%esi),%edi	#edi = old _ of bytes per element
	incl	%ebx	#ebx = new _ of elements
	imul	%ebx,%edi	#edi = bytes required by new array
	call	_____recalloc	#esi -> resized array
	popl	%ebx
	cmpl	$-1,%esi
	je	redim.malloc.error
	incl	%ebx	#ebx = new _ of elements
	movl	%ebx,-8(%esi)	#store new _ of elements
	jmp	rl.done	#all done
#
rl.not.lowest.dim:		#we're at an array of pointers to arrays
	orl	%ebx,%ebx	#ebx < 0 means put empty array here		# 95/03/03
	jns	rl.nroll	#done this dim					# 95/03/03
	xorl	%esi,%esi	#empty node					# 95/03/03
	jmp	rl.done	#no alloc					# 95/03/03
#
rl.nroll:
	pushl	%ebx
	movzwl	-4(%esi),%edi	#edi = old _ of bytes per element
	incl	%ebx	#ebx = new _ of elements
	imul	%ebx,%edi	#edi = bytes required by new array
	call	_____recalloc	#esi -> resized array
	popl	%ebx
	cmpl	$-1,%esi
	je	redim.malloc.error
	incl	%ebx	#ebx = new _ of elements
	movl	%ebx,-8(%esi)	#store new _ of elements
	decl	%ebx	#ebx = new upper bound
#;
rl.empty:									# 95/03/03
	xorl	%ecx,%ecx	#ecx = current element _ = 0
	movl	%esi,%edi	#edi -> current array
rl.redim.loop:
	pushl	%ebx
	pushl	%ecx
	pushl	%edi
	movl	(%edi,%ecx,4),%esi	#esi = current element
	orl	%esi,%esi	#empty pointer?
	jz	rl.dim.array	#yes: replace it with a new (empty) array
	call	redim.array.larger	#esi -> new element
	jmp	rl.redim.loop.end
#
#
rl.dim.array:
	call	dim.dim	#esi -> new element
#;
rl.redim.loop.end:
	popl	%edi
	popl	%ecx
	popl	%ebx
	cmpl	$-1,%esi
	je	rl.done
#;
	movl	%esi,(%edi,%ecx,4)	# store pointer to new array
#;
	incl	%ecx		# INC current element number
	cmpl	%ebx,%ecx	# past new upper bound?
	jbe	rl.redim.loop	# no: keep going
	movl	%edi,%esi	# esi -> array again
	decl	-4(%ebp)	# DEC dimNumber
	ret
#
#
# ##############################
# #####  XxxSwapMemory ()  #####
# ##############################
#
XxxSwapMemory_12:
	pushl	%ebp		# standard function entry
	movl	%esp,%ebp	# ditto
	pushl	%esi		# ditto
	pushl	%edi		# ditto
	pushl	%ebx		# ditto
	mov	16(%ebp),%esi	# esi = length
	call	_____malloc	# allocate intermediate memory
	push	%esi		# esi = addrx = intermediate memory
	mov	%esi,%edi	# edi = addrx = destination
	mov	8(%ebp),%esi	# esi = addr1 = source
	mov	16(%ebp),%ecx	# ecx = length
	call	__assignComposite
	mov	8(%ebp),%edi	# edi = addr1 = destination
	mov	12(%ebp),%esi	# esi = addr2 = source
	mov	16(%ebp),%ecx	# ecx = length
	call	__assignComposite
	mov	12(%ebp),%edi	# edi = addr2 = destination
	pop	%esi		# esi = addrx = source
	mov	16(%ebp),%ecx	# ecx = length
	call	__assignComposite
	pop	%ebx		# standard function exit
	pop	%edi		# ditto
	pop	%esi		# ditto
	mov	%ebp,%esp	# ditto
	pop	%ebp		# ditto
	ret	$12		# ditto (remove arguments - STDCALL)
#
#
# *******************************
# *****  %_AssignComposite  *****  copies a composite
# *******************************
#
# in:	esi -> source address
#	edi -> destination address
#	ecx = number of bytes to copy
#
# out:	nothing
#
# destroys: ebx, ecx, edx, esi, edi  (must not destroy eax)
#
# Guaranteed to not copy any extra bytes in addition to the number
# of bytes requested.  If destination address is null, does nothing.
# If source address is null, zeros destination.
#
__AssignComposite:
__assignComposite:
assignComposite:
	pushl	%eax		# save eax  (ntntnt)
	cld
	orl	%edi,%edi	#null destination?
	jz	ac_done		#yes: nothing to do
	orl	%esi,%esi	#null source?
	jz	ac_zero		#yes: zero destination
#
	movl	%esi,%eax	#eax = source address
	orl	%edi,%eax	#ready for alignment check
	testl	$1,%eax		#copy one byte at a time?
	jnz	copy_bytes	#yes
	testl	$2,%eax		#copy one word at a time?
	jnz	copy_words	#yes
#
copy_dwords:			#copy a dword at a time
	movl	%ecx,%ebx	#save _ of bytes to copy
	shrl	$2,%ecx		#ecx = _ of dwords to copy
	rep
	movsl			#copy them!
	testl	$2,%ebx		#an odd word left to copy?
	jz	dw_odd_byte	#no
	movsw			#yes: copy it
dw_odd_byte:
	testl	$1,%ebx		#an odd byte left to copy?
	jz	ac_done		#no
copy_odd_byte:
	movsb			#yes: copy it
ac_done:
	popl	%eax		# restore entry eax (ntntnt)
	ret
#
#
copy_words:			#copy a word at a time
	movl	%ecx,%ebx	#save _ of bytes to copy
	shrl	$1,%ecx		#ecx = _ of words to copy
	rep
	movsw			#copy them!
	testl	$1,%ebx		#an odd byte left to copy?
	jnz	copy_odd_byte	#yes: copy it
	popl	%eax		# restore eax (ntntnt)
	ret			#no: all done
#
#
copy_bytes:			#copy a byte at a time
	rep
	movsb			#copy them!
	popl	%eax		# restore eax (ntntnt)
	ret
#
#
ac_zero:			#zero destination
	xorl	%eax,%eax	#eax = 0, the better to clear memory with
	movl	%esi,%ebx	#ebx = source address
	orl	%edi,%ebx	#ready for alignment check
	testl	$1,%ebx		#zero one byte at a time?
	jnz	zero_bytes	#yes
	testl	$2,%ebx		#zero one word at a time?
	jnz	zero_words	#yes
#;
zero_dwords:			#zero a dword at a time
	movl	%ecx,%edx	#save number of bytes to zero
	shrl	$2,%ecx		#ecx = _ of dwords to zero
	rep
	stosl			#zero them!
	testl	$2,%edx		#an odd word left over?
	jz	zd_odd_byte	#no
	stosw			#yes: zero it
zd_odd_byte:
	testl	$1,%edx		#an odd byte left over?
	jz	zc_done		#no: all done
zero_odd_byte:
	stosb			#yes: zero it
zc_done:
	popl	%eax		# restore eax (ntntnt)
	ret
#
#
zero_words:			#zero a word at a time
	movl	%ecx,%edx	#save number of bytes to zero
	shrl	$1,%ecx		#ecx = _ of words to zero
	rep
	stosw			#zero them!
	testl	$1,%edx		#an odd byte left over
	jnz	zero_odd_byte	#yes: zero it
	popl	%eax		# restore eax (ntntnt)
	ret			#no: all done
#
#
zero_bytes:			#zero a byte at a time
	rep
	stosb			#zero them!
	popl	%eax		# restore eax (ntntnt)
	ret			#bd, bd, bdea, that's all, folks!
#
#
#
# *************************************
# *****  Assign Composite String  *****  fill extra bytes with 0x20
# *************************************
#
# edi = destination address	(address of Fixed String in composite)
# esi = source address		(address of Elastic String)
# ecx = number of bytes in composite string
#
# fixed strings do NOT have an extra 0x00 terminator byte
# source must be 0x00 terminated
#
__assignCompositeString.v:
	movl	$0,%edx		# don't free source string after
	jmp	acs_start	#
#
__assignCompositeString.s:
	movl	%esi,%edx	# free source string after
#;
acs_start:
	pushl	%eax		# save eax (ntntnt)
	pushl	%ebp		# framewalk support
	movl	%esp,%ebp	# framewalk support
	subl	$64,%esp	# create local frame (workspace)
#
	movl	%edx,(%esp)	# save string to free after
	orl	%edi,%edi	#
	jz	acs_done	# if destination address = 0, do nothing
	cmpl	$0,%ecx		#
	jbe	acs_done	# if destination length <= 0, do nothing
#;
#;
	xorl	%ebx,%ebx	# ebx = byte offset = 0 to start
	orl	%esi,%esi	#
	jz	acs_pad		# if source = "", just pad with spaces
	movl	-8(%esi),%edx	# edx = source length
	orl	%edx,%edx	#
	jz	acs_pad		# if source = "", just pad with spaces
#;
#;
acs_copy:
	movb	(%esi,%ebx,1),%al	# read from source
	decl	%edx		# edx = one less source byte left
	movb	%al,(%edi,%ebx,1)	# write to destination
	decl	%ecx		# one less byte to copy
	incl	%ebx		# offset to next byte
	orl	%ecx,%ecx	#
	jz	acs_done	# destination filled
	orl	%edx,%edx	#
	jnz	acs_copy	# if source not depleated, copy next byte
#;
#;
acs_pad:
	movl	$0x20,%eax	# eax = space character (padding)
	movb	%al,(%edi,%ebx,1)	# write space to destination
	incl	%ebx		# offset to next byte
	decl	%ecx		# one less byte to write
	jnz	acs_pad		# write more until count = 0
#;
#;
acs_done:
	movl	(%esp),%esi	# string to free
	orl	%esi,%esi	#
	jnz	asc_zip		# none to free
	call	_____free	# free string
#;
asc_zip:
	movl	%ebp,%esp	#
	popl	%ebp		#
	popl	%eax		# restore eax (ntntnt)
	ret			# return to caller
#
#
# *************************************
# *****  Assign Composite String  *****  fill extra bytes with 0x00
# *************************************
#
# edi = destination address	(address of Fixed String in composite)
# esi = source address		(address of Elastic String)
# ecx = number of bytes in composite string
#
# fixed strings do NOT have an extra 0x00 terminator byte
# source must be 0x00 terminated
#
__assignCompositeStringlet.v:
	movl	$0,%edx		# don't free source string after
	jmp	zacs_start	#
#
__assignCompositeStringlet.s:
	movl	%esi,%edx	# free source string after
#;
zacs_start:
	pushl	%eax		# save eax (ntntnt)
	pushl	%ebp		# framewalk support
	movl	%esp,%ebp	# framewalk support
	subl	$64,%esp	# create local frame (workspace)
#
	movl	%edx,(%esp)	# save string to free after
	orl	%edi,%edi	#
	jz	zacs_done	# if destination address = 0, do nothing
	cmpl	$0,%ecx		#
	jbe	zacs_done	# if destination length <= 0, do nothing
#;
#;
	xorl	%ebx,%ebx	# ebx = byte offset = 0 to start
	orl	%esi,%esi	#
	jz	zacs_pad	# if source = "", just pad with spaces
	movl	-8(%esi),%edx	# edx = source length
	orl	%edx,%edx	#
	jz	zacs_pad	# if source = "", just pad with spaces
#;
#;
zacs_copy:
	movb	(%esi,%ebx,1),%al	# read from source
	decl	%edx		# edx = one less source byte left
	movb	%al,(%edi,%ebx,1)	# write to destination
	decl	%ecx		# one less byte to copy
	incl	%ebx		# offset to next byte
	orl	%ecx,%ecx	#
	jz	zacs_done	# destination filled
	orl	%edx,%edx	#
	jnz	zacs_copy	# if source not depleated, copy next byte
#;
#;
zacs_pad:
	xorl	%eax,%eax	# eax = 0x00 = pad byte
	movb	%al,(%edi,%ebx,1)	# write space to destination
	incl	%ebx		# offset to next byte
	decl	%ecx		# one less byte to write
	jnz	zacs_pad	# write more until count = 0
#;
#;
zacs_done:
	movl	(%esp),%esi	# string to free
	orl	%esi,%esi	#
	jnz	zasc_zip	# none to free
	call	_____free	# free string
#;
zasc_zip:
	movl	%ebp,%esp	#
	popl	%ebp	#
	popl	%eax	# restore eax (ntntnt)
	ret		# return to caller
#
#
#
#
# ****************************
# *****  %_VarargArrays  *****
# ****************************
#
# Create three arrays for "Vararg" functions... Func (???)
#   1.  argTypes[]	64 element XLONG array
#   2.  argStrings$[]	64 element STRING array
#   3.  argNumbers$$[]	64 element GIANT array
#
__VarargArrays:
	ret
#subu	r31,r31,0x0080		; create frame
#st	r1,r31,0x006C		; save return address
#or	r28,r0,1
#or.u	r29,r0,0xC008
#or	r29,r29,0x0004
#st.d	r28,r31,0x0010
#or	r26,r0,64
#st	r26,r31,0x0020
#or	r26,r0,0
#bsr	%_DimArray
#st	r26,r31,0x0040
#or	r28,r0,1
#or.u	r29,r0,0xC013
#or	r29,r29,0x0004
#st.d	r28,r31,0x0010
#or	r26,r0,64
#st	r26,r31,0x0020
#or	r26,r0,0
#bsr	%_DimArray
#st	r26,r31,0x0044
#or	r28,r0,1
#or.u	r29,r0,0xC00C
#or	r29,r29,0x0008
#st.d	r28,r31,0x0010
#or	r26,r0,64
#st	r26,r31,0x0020
#or	r26,r0,0
#bsr	%_DimArray
#or	r28,r0,r26		; r28 = argNumber$$[]
#ld	r1,r31,0x006C		; restore return address
#ld.d	r26,r31,0x0040		; r26/r27 = argType[], argString$[]
#jmp.n	r1			; return
#addu	r31,r31,0x0080		; restore frame
#
#
#
__endAlloCode:
.long	0, 0, 0, 0, 0, 0, 0, 0
.long	0, 0, 0, 0, 0, 0, 0, 0
#
#
.text
#
# #####################
# #####  xlibp.s  #####  XstStringToNumber ()
# #####################
#
# *******************************
# *****  XstStringToNumber  *****
# *******************************
#
# XstStringToNumber (text$, startOffset, afterOffset, valueType, value$$)
#
# in:	arg4 = ignored
#	arg3 = ignored
#	arg2 = ignored
#	arg1 = (zero-biased) start offset into text$
#	arg0 -> text$, string from which to parse a number
# out:	eax = "explicit" type (see below)
#	arg4 = SINGLE, DOUBLE, or GIANT value of number parsed [ebp+24]:[ebp+28]
#	arg3 = valueType (see below)				[ebp+20]
#	arg2 = (zero-biased) offset into text$ of character	[ebp+16]
#	       after last character from text$ that was part
#	       of parsed number
#	arg1 = unchanged					[ebp+12]
#	arg0 = unchanged					[ebp+8]
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] = hi (most significant) 32 bits of integer result
#	[ebp-8] = lo (least significant) 32 bits of integer result
#	[ebp-12] = current state (see "state table" at end of this file)
#	[ebp-16] = number of digits received so far
#	[ebp-20] = hi 32 bits of double result
#	[ebp-24] = lo 32 bits of double result / single result
#	[ebp-28] = sign of result (0 = positive, -1 = negative)
#	[ebp-32] = exponent
#	[ebp-36] = return value
#	[ebp-40] = current character
#	[ebp-44] = 0 if nothing in st(0), 1 if result in st(0)
#	[ebp-48] = number of digits after decimal point received so far
#	[ebp-52] = number of exponent digits
#	[ebp-56] = sign of exponent (0 = positive, -1 = negative)
#	[ebp-60] = minimum number of digits for number to be legal
#	[ebp-64] = minimum number of digits for exponent to be legal
#
# Characters <= space (0x20) and > 0x80 at the beginning of text$ (actually,
# starting at text${startOffset}) are skipped.
#
# On exit, the return value (eax) is set according to the following rules:
#
#	1. If number starts with "0s", then return value = $$SINGLE.
#
#	2. If number starts with "0d", then return value = $$DOUBLE.
#
#	3. If number is invalid or there was no number, then return value = -1.
#
#	4. Otherwise, return value = 0.
#
# On exit, arg3 (valueType) is set according to the following rules:
#
#	1. If return value == $$SINGLE or return value == $$DOUBLE,
#	   valueType = return value.
#
#	2. If the number was floating-point, valueType = $$DOUBLE.
#
#	3. If number was integer and could not fit in an SLONG,
#	   valueType = $$GIANT.
#
#	4. If there was no number, valueType = 0.
#
#	5. Otherwise, valueType = $$XLONG.
#
# The number stored in arg4 on exit has the type indicated by valueType (arg3).
#
# Number formats:  ("n" = decimal digit; "h" = hexadecimal digit; "O" =
# octal digit; "B" = binary digit; "+" = plus or minus)
#
#	Format			Type of result
#	------			--------------
#	nnnnn			integer
#	nnnnn.			floating-point
#	nnnnn.e+nn		floating-point
#	nnnnn.d+nn		floating-point
#	0xhhhhhh		integer
#	0oOOOOOO		integer
#	0bBBBBBB		integer
#	0shhhhhhhh		single-precision floating-point
#	0dhhhhhhhhhhhhhhhh	double-precision floating-point
#
# Complete documentation on the formats in which numbers are represented
# in strings is in the XBasic Language Description.
#
# See STATE TABLE, near end of file, for outline of algorithm.
#
XstStringToNumber_24:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$80,%esp
#;
	xorl	%eax,%eax	#ready to initialize some variables
	movl	%eax,-4(%ebp)
	movl	%eax,-8(%ebp)	#integer result = 0
	movl	$ST_START,-12(%ebp)	#current state = ST_START
	movl	%eax,-16(%ebp)	#number of digits received so far = 0
	movl	%eax,-20(%ebp)
	movl	%eax,-24(%ebp)	#floating-point result = 0
	movl	%eax,-28(%ebp)	#sign of result = positive
	movl	%eax,-32(%ebp)	#exponent = 0
	movl	$8,20(%ebp)	#valueType = $$XLONG
	movl	%eax,-36(%ebp)	#return value = 0
	movl	%eax,-44(%ebp)	#there's nothing in st(0) yet
	movl	%eax,-48(%ebp)	#_ digits after decimal point = 0
	movl	%eax,-52(%ebp)	#_ of exponent digits = 0
	movl	%eax,-56(%ebp)	#sign of exponent = positive
	movl	%eax,-60(%ebp)	#minimum number of digits for number to be
	movl	%eax,-64(%ebp)	#no exponent is necessary
	movl	%eax,-68(%ebp)	#forcetype = 0 = none
#;
	movl	12(%ebp),%ecx	#ecx = startOffset
	movl	%ecx,16(%ebp)	#afterOffset = startOffset
#;
	movl	8(%ebp),%esi	#esi -> text$
	orl	%esi,%esi	#null pointer?
	jz	done	#yes: nothing to do
#;
main_loop_top:			#assuming: esi -> text$, ecx = afterOffset
	cmpl	-8(%esi),%ecx	#past end of text$?
	jae	done	#yes: no characters left to parse
#;
	movzbl	(%esi,%ecx,1),%eax	#eax = current character
	movl	-12(%ebp),%ebx	#ebx -> first structure for current state
#;
struct_loop_top:
	cmpl	0(%ebx),%eax	#eax >= lower bound?
	jb	try_next_struct	#no: no match
	cmpl	4(%ebx),%eax	#eax <= upper bound?
	ja	try_next_struct	#no: no match
	movl	%eax,-40(%ebp)	#save current character
	movl	12(%ebx),%edx	#eax = next state
	movl	%edx,-12(%ebp)	#new current state
	jmp	*8(%ebx)	#go to action routine for current structure
#
try_next_struct:
	addl	$16,%ebx	#ebx -> next structure for current state
	jmp	struct_loop_top
#
next_char:
	movl	8(%ebp),%esi	#esi -> text$
	movl	16(%ebp),%ecx	#ecx = afterOffset -> current char
	incl	%ecx	#bump character pointer
	movl	%ecx,16(%ebp)	#save it
	jmp	main_loop_top
#
done_inc:			#done, but bump afterOffset before exiting
	incl	16(%ebp)	#bump afterOffset
#;
done:
	cmpl	$0,-16(%ebp)	#received any digits at all?
	jz	no_number	#nope: error return
#;
#; if floating-point number and had exponent, adjust number for exponent
#;
	cmpl	$0,-44(%ebp)	#result is in st(0)?
	je	make_arg4	#no: all done
	cmpl	$0,-52(%ebp)	#at least one exponent digit?
	je	exponent_done	#no: no need to adjust for exponent
#;
	movl	-32(%ebp),%edx	#edx = exponent
	cmpl	$0,-56(%ebp)	#sign of exponent is negative?
	je	exponent_adjust	#no
	negl	%edx	#yes: now edx really = exponent
#;
exponent_adjust:
	addl	$308,%edx	#exponent table begins at -308
	fldl	__pwr_10_table(,%edx,8)	#load exponent multiplier
	fmulp		#multiply result by exponent multiplier
	fwait
#;
exponent_done:
	cmpl	$0,-28(%ebp)	#sign is negative?
	je	store_float_result	#no
	fchs		#yes: make result negative
store_float_result:
	fstpl	-24(%ebp)	#store result
#;
make_arg4:
	movl	20(%ebp),%eax	#eax = valueType
	cmpl	$13,%eax	#$$SINGLE?
	je	make_single	#yes: go do it
	cmpl	$14,%eax	#$$DOUBLE?
	je	make_double	#yes: go do it
#;
#; result is an integer
#;
	movl	-4(%ebp),%edx	# edx = hi 32 bits of result
	movl	-8(%ebp),%eax	# eax = lo 32 bits of result
#;
	orl	%edx,%edx	# anything in hi 32 bits?
	jnz	integer_giant	# yes, so result is GIANT
#;
	movl	-68(%ebp),%ecx	# eax = force type
	cmpl	$12,%ecx	# GIANT ???
#
###	jne	hd_32		# no, so xlong may work
	je	integer_giant	# yes
#
	cmpl	$8,%ecx		# valueType == XLONG ???
	movl	$8,20(%ebp)	# yes, XLONG
	je	integer_xlong	# XLONG
#
	orl	%eax,%eax	# sign bit in low 32 bits?
	js	integer_giant	# yes, so result is GIANT
#;
hd_32:
	movl	$6,20(%ebp)	#valueType = $$SLONG
#
integer_xlong:
	cmpl	$0,-28(%ebp)	#sign is positive?
	je	xlong_sign_ok	#yes
	negl	%eax		#no: negate result
#;
xlong_sign_ok:
	movl	%eax,24(%ebp)	#store result to lo 32 bits of arg4
	movl	$0,28(%ebp)	#hi 32 bits of arg4 = 0
	jmp	validity_check
#
integer_giant:
	movl	$12,20(%ebp)	#valueType = $$GIANT
	cmpl	$0,-28(%ebp)	#sign is positive?
	je	giant_sign_ok	#yes
	notl	%edx	#no: negate result
	negl	%eax
	sbbl	$-1,%edx
giant_sign_ok:
	movl	%eax,24(%ebp)	#store lo 32 bits of result
	movl	%edx,28(%ebp)	#store hi 32 bits of result
	jmp	validity_check
#
make_single:
	movl	-24(%ebp),%eax	#eax = result
	movl	%eax,24(%ebp)	#store result into arg4
	movl	$0,28(%ebp)	#clear high 32 bits of arg4
	jmp	validity_check
#
make_double:
	fwait
	movl	-24(%ebp),%eax	#eax = lo 32 bits of result
	movl	%eax,24(%ebp)	#store lo 32 bits of result into arg4
	movl	-20(%ebp),%eax	#eax = hi 32 bits of result
	movl	%eax,28(%ebp)	#store hi 32 bits of result into arg4
#;
validity_check:
	movl	-36(%ebp),%eax	#eax = return value
	movl	-60(%ebp),%ebx	#ebx = minimum number of digits to be legal
	cmpl	-16(%ebp),%ebx	#received enough digits?
	ja	invalidate_number	#no
#;
	movl	-64(%ebp),%ebx	#ebx = minimum number of digits in exponent
	cmpl	-52(%ebp),%ebx	#received enough digits in exponent?
	ja	invalidate_number	#no
#;
stn_exit:
	movl	%ebp,%esp
	popl	%ebp
	ret	$24	# ###
#
#
no_number:
	xorl	%eax,%eax	#ready to write some zeros
	movl	%eax,20(%ebp)	#valueType = 0, to indicate that no number
	movl	%eax,24(%ebp)	#set result to 0, too
	movl	%eax,28(%ebp)
	decl	%eax	#return value = -1
	movl	%ebp,%esp
	popl	%ebp
	ret	$24	# ###
#
#
invalidate_number:
	movl	$-1,%eax	#return value = -1 to indicate invalid number
	jmp	stn_exit
#
#
stn_abort:
	movl	$-1,-36(%ebp)	#mark that current number is invalid
	jmp	done
#
# *****************************
# *****  ACTION ROUTINES  *****  routines pointed to in state table,
# *****************************  except for next_char
#
# in:	eax = current character
#
# All action routines jump to either next_char or done on completion.
#
add_dec_digit:			#multiply current integer result by 10
	movl	-4(%ebp),%edx	#edx = hi 32 bits of integer
	cmpl	$0x10000000,%edx	#number getting too big to fit in integer?
	ja	too_big_for_int	#yes
	movl	-8(%ebp),%eax	#eax = lo 32 bits of integer
#;
	shll	$1,%eax
	rcl	$1,%edx	#edx:eax = integer * 2
	movl	%eax,%ebx
	movl	%edx,%ecx	#ecx:ebx = integer * 2
	shldl	$2,%eax,%edx
	shll	$2,%eax	#edx:eax = integer * 8
	addl	%ebx,%eax
	adcl	%ecx,%edx	#edx:eax = integer*8 + integer*2 = integer*10
#;
	movl	-40(%ebp),%ebx	#ebx = current character
	subl	$'0',%ebx	#ebx = current digit
	addl	%ebx,%eax	#add in current digit
	adcl	$0,%edx	#propagate carry bit
#;
	movl	%edx,-4(%ebp)	#save hi 32 bits of integer
	movl	%eax,-8(%ebp)	#save lo 32 bits of integer
	incl	-16(%ebp)	#bump digit counter
	jmp	next_char
#
#
too_big_for_int:
	fildll	-8(%ebp)	#st(0) = integer built so far
	movl	$14,20(%ebp)	#valueType = $$DOUBLE
	movl	$1,-44(%ebp)	#mark that result is in st(0)
	movl	$ST_IN_FLOAT,-12(%ebp)	#switch to floating-point state
#;
#; fall through
#;
add_float_digit:		#add a digit to floating-point number
	fimull	ten	#old result *= 10
	subl	$'0',-40(%ebp)	#current character = current digit
	fiaddl	-40(%ebp)	#add current digit into result
	incl	-16(%ebp)	#bump digit counter
	jmp	next_char
#
#
sign_negative:			#set sign to negative
	movl	$-1,-28(%ebp)
	jmp	next_char
#
#
type_double:			#set type to $$DOUBLE
	fildll	-8(%ebp)	#convert current integer to floating-point
	movl	$14,20(%ebp)	#valueType = $$DOUBLE
	movl	$1,-44(%ebp)	#mark that result is in st(0)
	jmp	next_char
#
#
begin_simage:			#set type to $$SINGLE and accumulate
	movl	$13,20(%ebp)	#valueType = $$SINGLE
	movl	$13,-36(%ebp)	#return value = $$SINGLE
	movl	$0,-16(%ebp)	#digit count = 0
	movl	$8,-60(%ebp)	#minimum number of digits to be legal = 8
	jmp	next_char
#
#
begin_dimage:			#set type to $$DOUBLE and accumulate
	movl	$14,20(%ebp)	#valueType = $$DOUBLE
	movl	$14,-36(%ebp)	#return value = $$DOUBLE
	movl	$0,-16(%ebp)	#digit count = 0
	movl	$16,-60(%ebp)	#minimum number of digits to be legal = 16
	jmp	next_char
#
#
add_hex_digit:			#multiply current integer by 16 and add
	movl	-8(%ebp),%ebx	#ebx = lo 32 bits of current integer
	movl	-4(%ebp),%ecx	#ecx = hi 32 bits of current integer
	shldl	$4,%ebx,%ecx
	shll	$4,%ebx	#ebx:ecx = integer * 16
	movzbl	__lctouc(%eax),%eax	#convert current char to upper case
	subl	$'0',%eax	#eax = current digit
	cmpl	$9,%eax	#was it A,B,C,D,E, or F?
	jbe	hd_add	#no: eax really is current digit
	subl	$7,%eax	#now eax really is current digit
#;
hd_add:				#eax = current digit
	orl	%eax,%ebx	#add in current digit
	movl	%ebx,-8(%ebp)	#save lo 32 bits of integer
	movl	%ecx,-4(%ebp)	#save hi 32 bits of integer
	movl	-16(%ebp),%eax	#eax = number of digits read so far
	incl	%eax	#bump digit counter
	movl	%eax,-16(%ebp)	#save digit counter
	cmpl	$9,%eax	#digits beyond XLONG ???
	jnz	hd_long	#not yet
	movl	$12,-68(%ebp)	#yes, so force hex _ to GIANT
#;
hd_long:
	cmpl	$16,%eax	#reached last (16th) possible hex digit?
	jae	no_more_digits	#yes: don't read any more
	jmp	next_char
#
#
add_bin_digit:			#multiply current integer by 2 and add
	movl	-8(%ebp),%ebx	#ebx = lo 32 bits of current integer
	movl	-4(%ebp),%ecx	#ecx = hi 32 bits of current integer
	shll	$1,%ebx
	rcl	$1,%ecx	#ecx:ebx = integer * 2
	subl	$'0',%eax	#eax = current digit
	orl	%eax,%ebx	#add in current digit
	movl	%ebx,-8(%ebp)	#save lo 32 bits of integer
	movl	%ecx,-4(%ebp)	#save hi 32 bits of integer
	movl	-16(%ebp),%eax	#eax = number of digits read so far
	incl	%eax	#bump digit counter
	movl	%eax,-16(%ebp)	#save digit counter
	cmpl	$64,%eax	#reached last (64th) possible binary digit?
	jae	no_more_digits	#yes: don't read any more
	jmp	next_char
#
#
add_oct_digit:			#multiply current integer by 8 and add
	movl	-8(%ebp),%ebx	#ebx = lo 32 bits of current integer
	movl	-4(%ebp),%ecx	#ecx = hi 32 bits of current integer
	shldl	$3,%ebx,%ecx
	shll	$3,%ebx	#ecx:ebx = integer * 8
	subl	$'0',%eax	#eax = current digit
	orl	%eax,%ebx	#add in current digit
	movl	%ebx,-8(%ebp)	#save lo 32 bits of integer
	movl	%ecx,-4(%ebp)	#save hi 32 bits of integer
	movl	-16(%ebp),%eax	#eax = number of digits read so far
	incl	%eax	#bump digit counter
	movl	%eax,-16(%ebp)	#save digit counter
	cmpl	$22,%eax	#reached last (22nd) possible octal digit?
	jae	no_more_digits	#yes: don't read any more
	jmp	next_char
#
#
add_simage_digit:		#append current hex digit to SINGLE result
	movzbl	__lctouc(%eax),%eax	#convert current char to upper case
	subl	$'0',%eax	#eax = current digit
	cmpl	$9,%eax	#was it A,B,C,D,E, or F?
	jbe	simage_hd_ok	#no: eax really is current digit
	subl	$7,%eax	#now eax really is current digit
#;
simage_hd_ok:
	movl	-16(%ebp),%ecx	#ecx = number of digits read so far
	shll	$28,%eax	#move digit up to very top of eax
	movl	%ecx,%ebx	#save number of digits read so far
	shll	$2,%ecx	#ecx = number of digits * 4 = _ of bits to shift
	shrl	%cl,%eax	#move digit to correct position in eax
	orl	%eax,-24(%ebp)	#add in digit to SINGLE result
#;
	incl	%ebx	#bump digit counter
	movl	%ebx,-16(%ebp)	#save digit counter
	cmpl	$8,%ebx	#reached last (8th) possible hex digit?
	jae	no_more_digits	#yes: don't read any more
	jmp	next_char
#
#
add_dimage_digit:		#append current hex digit to DOUBLE result
	movzbl	__lctouc(%eax),%eax	#convert current char to upper case
	subl	$'0',%eax	#eax = current digit
	cmpl	$9,%eax	#was it A,B,C,D,E, or F?
	jbe	dimage_hd_ok	#no: eax really is current digit
	subl	$7,%eax	#now eax really is current digit
#;
dimage_hd_ok:
	movl	-16(%ebp),%ecx	#ecx = number of digits read so far
	shll	$28,%eax	#move digit up to very top of eax
	movl	%ecx,%ebx	#save number of digits read so far
	shll	$2,%ecx	#ecx = number of digits * 4 = _ of bits to shift
	shrl	%cl,%eax	#move digit to correct position in eax
	cmpl	$8,%ebx	#digit is in second word?
	jae	dimage_loword	#yes
#;
dimage_hiword:
	orl	%eax,-20(%ebp)	#move digit into DOUBLE result
	jmp	dimage_done
#
#
dimage_loword:
	orl	%eax,-24(%ebp)	#move digit into DOUBLE result
#;
dimage_done:
	incl	%ebx	#bump digit counter
	movl	%ebx,-16(%ebp)	#save digit counter
	cmpl	$16,%ebx	#reached last (16th) possible hex digit?
	jae	no_more_digits	#yes: don't read any more
	jmp	next_char
#
#
no_more_digits:			#set state so that if a hex digit comes
	movl	$ST_NUMERIC_BAD,-12(%ebp)
	jmp	next_char
#
#
add_after_point:		#add a digit after the decimal point
	movl	-48(%ebp),%edx	#edx = _ of digits after dec point rec'd so far
	cmpl	$308,%edx	#if 308 or more, digit is of no significance,
	ja	next_char	# so throw it away
#;
	subl	$'0',-40(%ebp)	#convert current character to current digit
	fildl	-40(%ebp)	#st(0) = current digit, st(1) = n
	incl	%edx	#bump digit-after-dec-point counter
	movl	%edx,-48(%ebp)	#save it for next time
	negl	%edx	#edx = offset relative to 10^0
	fldl	__pwr_10_to_0(,%edx,8)	#load multiplier for current digit
	fmulp		#st(0) = digit * 10^-position
	faddp		#st(0) = new n
	incl	-16(%ebp)	#bump digit counter
	jmp	next_char
#
#
add_exp_digit:			#add a digit to the exponent
	movl	-32(%ebp),%ebx	#ebx = current exponent
	subl	$'0',%eax	#eax = current digit
	imul	$10,%ebx,%ebx	#current exponent *= 10
	addl	%eax,%ebx	#add in current digit
	cmpl	$308,%ebx	#exponent greater than can be represented?
	ja	stn_abort	#yes: entire number is invalid
	movl	%ebx,-32(%ebp)	#save new current exponent
	incl	-52(%ebp)	#bump counter of exponent digits
	jmp	next_char
#
#
exp_negative:			#make exponent negative
	movl	$-1,-56(%ebp)	#sign = negative
#;
#; fall through
#;
need_exponent:			#mark that we must have an exponent, or
	movl	$1,-64(%ebp)	# number is invalid
	jmp	next_char
#
#
bump_digit_count:		#just bump digit counter, and ignore
	incl	-16(%ebp)	# current digit
	jmp	next_char
#
#
clear_digit_count:		# set digit counter back to zero
	movl	$8,-68(%ebp)	# 0x and 0o and 0b produce XLONG or GIANT
	movl	$0,-16(%ebp)
	jmp	next_char
#
#
#
# ##################
# #####  DATA  #####  XstStringToNumber()
# ##################
#
.text
.align	8
ten:	.long	10		#a place in memory guaranteed to contain 10
#
# *************************
# *****  STATE TABLE  *****
# *************************
#
# Each "state" of the parser has a list of structures, each of which
# contains four dwords:
#
#	0	lower bound of range for current character
#	1	upper bound of range for current character
#	2	location to jump to if current character is in range
#		specified by dwords 0 and 1
#	3	state to change to if current character is in range
#		specified by dwords 0 and 1
#
# The last such structure in each state's list has a lower bound of
# 0x00 and an upper bound of 0xFF, so that it catches all possible
# characters.  Each time a new character is retrieved from text$,
# XstStringToNumber checks it against each structure in turn, starting
# with the structure pointed to by the "current state" variable,
# until one is found that matches the current character.  XstStringToNumber
# then jumps to the location given in dword 2, and changes the "current
# state" variable to the value in dword 3.
#
.text
.align	8
ST_START:			#parser starts in this state
.long	'0', '0'
.long	bump_digit_count
.long	ST_GOT_LEAD_ZERO
.long	'1', '9'
.long	add_dec_digit
.long	ST_IN_INT
.long	'+', '+'
.long	next_char
.long	ST_IN_INT
.long	'-', '-'
.long	sign_negative
.long	ST_IN_INT
.long	'.', '.'
.long	type_double
.long	ST_AFTER_DEC_POINT
.long	1, 0x20		#ignore leading whitespace
.long	next_char
.long	ST_START
.long	0x80, 0xFF	#ignore leading chars with high bit set
.long	next_char
.long	ST_START
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_GOT_LEAD_ZERO:
.long	'0', '9'
.long	add_dec_digit
.long	ST_IN_INT
.long	'.', '.'
.long	type_double
.long	ST_AFTER_DEC_POINT
.long	'x', 'x'
.long	clear_digit_count
.long	ST_IN_HEX
.long	'o', 'o'
.long	clear_digit_count
.long	ST_IN_OCT
.long	'b', 'b'
.long	clear_digit_count
.long	ST_IN_BIN
.long	's', 's'
.long	begin_simage
.long	ST_IN_SIMAGE
.long	'd', 'd'
.long	begin_dimage
.long	ST_IN_DIMAGE
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_INT:			#inside an integer or the part of a floating-
.long	'0', '9'	# point number that is to the left of the
.long	add_dec_digit	# decimal point
.long	ST_IN_INT
.long	'.', '.'
.long	type_double
.long	ST_AFTER_DEC_POINT
.long	'd', 'd'
.long	type_double
.long	ST_START_EXP
.long	'e', 'e'	#"nnnne+nn" is converted into double-
.long	type_double	# precision floating-point, even though
.long	ST_START_EXP	# the "e" is supposed to mean "single-precision"
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_FLOAT:			#inside a floating-point number and haven't
.long	'0', '9'	# reached the decimal point yet# the only way
.long	add_float_digit	# to get to this state is for add_dec_digit
.long	ST_IN_FLOAT	# to force the state variable to point to it
.long	'.', '.'	# large to hold in a GIANT
.long	next_char
.long	ST_AFTER_DEC_POINT
.long	'd', 'd'
.long	next_char
.long	ST_START_EXP
.long	'e', 'e'
.long	next_char
.long	ST_START_EXP
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_HEX:
.long	'0', '9'
.long	add_hex_digit
.long	ST_IN_HEX
.long	'A', 'F'
.long	add_hex_digit
.long	ST_IN_HEX
.long	'a', 'f'
.long	add_hex_digit
.long	ST_IN_HEX
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_OCT:
.long	'0', '7'
.long	add_oct_digit
.long	ST_IN_OCT
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_BIN:
.long	'0', '1'
.long	add_bin_digit
.long	ST_IN_BIN
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_SIMAGE:
.long	'0', '9'
.long	add_simage_digit
.long	ST_IN_SIMAGE
.long	'A', 'F'
.long	add_simage_digit
.long	ST_IN_SIMAGE
.long	'a', 'f'
.long	add_simage_digit
.long	ST_IN_SIMAGE
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_DIMAGE:
.long	'0', '9'
.long	add_dimage_digit
.long	ST_IN_DIMAGE
.long	'A', 'F'
.long	add_dimage_digit
.long	ST_IN_DIMAGE
.long	'a', 'f'
.long	add_dimage_digit
.long	ST_IN_DIMAGE
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_AFTER_DEC_POINT:
.long	'0', '9'
.long	add_after_point
.long	ST_AFTER_DEC_POINT
.long	'd', 'd'
.long	next_char
.long	ST_START_EXP
.long	'e', 'e'
.long	next_char
.long	ST_START_EXP
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_START_EXP:
.long	'0', '9'
.long	add_exp_digit
.long	ST_IN_EXP
.long	'+', '+'
.long	need_exponent
.long	ST_IN_EXP
.long	'-', '-'
.long	exp_negative
.long	ST_IN_EXP
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_IN_EXP:
.long	'0', '9'
.long	add_exp_digit
.long	ST_IN_EXP
.long	0x00, 0xFF
.long	done
.long	ST_START
ST_NUMERIC_BAD:			#reached end of 0s or 0d number# if next
.long	'0', '9'	# digit is numeric, then number is too long.
.long	stn_abort	# The only way to reach this state is to
.long	ST_START	# be forced into it by add_simage_digit
.long	'a', 'f'
.long	stn_abort
.long	ST_START
.long	'A', 'F'
.long	stn_abort
.long	ST_START
.long	0x00, 0xFF
.long	done
.long	ST_START
#
#
# ***************************
# *****  POWERS OF TEN  *****
# ***************************
#
# First element of table is 10^-308; last element is 10^308.  All
# elements are in double precision.
#
.text
.align	8
__pwr_10_table:
.long	0x7819E8D3, 0x000730D6, 0x2C40C60E, 0x0031FA18
.long	0x3750F792, 0x0066789E, 0xC5253576, 0x009C16C5
.long	0x9B374169, 0x00D18E3B, 0x820511C3, 0x0105F1CA
.long	0x22865634, 0x013B6E3D, 0x3593F5E0, 0x017124E6
.long	0xC2F8F358, 0x01A56E1F, 0xB3B7302D, 0x01DAC9A7
.long	0xD0527E1D, 0x0210BE08, 0x04671DA4, 0x0244ED8B
.long	0xC580E50D, 0x027A28ED, 0x9B708F28, 0x02B05994
.long	0xC24CB2F2, 0x02E46FF9, 0x32DFDFAE, 0x03198BF8
.long	0x3F97D799, 0x034FEEF6, 0xE7BEE6C0, 0x0383F559
.long	0x61AEA070, 0x03B8F2B0, 0x7A1A488B, 0x03EF2F5C
.long	0xCC506D57, 0x04237D99, 0x3F6488AD, 0x04585D00
.long	0x4F3DAAD8, 0x048E7440, 0x31868AC7, 0x04C308A8
.long	0x3DE82D79, 0x04F7CAD2, 0xCD6238D8, 0x052DBD86
.long	0x405D6387, 0x05629674, 0x5074BC69, 0x05973C11
.long	0xA491EB82, 0x05CD0B15, 0x86DB3332, 0x060226ED
.long	0xE891FFFF, 0x0636B0A8, 0x22B67FFE, 0x066C5CD3
.long	0xF5B20FFE, 0x06A1BA03, 0xF31E93FE, 0x06D62884
.long	0x2FE638FD, 0x070BB2A6, 0xDDEFE39E, 0x07414FA7
.long	0xD56BDC85, 0x0775A391, 0x4AC6D3A7, 0x07AB0C76
.long	0xEEBC4448, 0x07E0E7C9, 0x6A6B555A, 0x081521BC
.long	0x85062AB1, 0x084A6A2B, 0x3323DAAF, 0x0880825B
.long	0xFFECD15A, 0x08B4A2F1, 0x7FE805B1, 0x08E9CBAE
.long	0x0FF1038F, 0x09201F4D, 0x53ED4473, 0x09542720
.long	0x68E89590, 0x098930E8, 0x8322BAF4, 0x09BF7D22
.long	0x91F5B4D9, 0x09F3AE35, 0xF673220F, 0x0A2899C2
.long	0xB40FEA93, 0x0A5EC033, 0x5089F29C, 0x0A933820
.long	0x64AC6F43, 0x0AC80628, 0x7DD78B14, 0x0AFE07B2
.long	0x8EA6B6EC, 0x0B32C4CF, 0x725064A7, 0x0B677603
.long	0x4EE47DD1, 0x0B9D5384, 0xB14ECEA3, 0x0BD25432
.long	0x5DA2824B, 0x0C06E93F, 0x350B22DE, 0x0C3CA38F
.long	0x8126F5CA, 0x0C71E639, 0xE170B33D, 0x0CA65FC7
.long	0xD9CCE00D, 0x0CDBF7B9, 0x28200C08, 0x0D117AD4
.long	0x32280F0A, 0x0D45D989, 0x7EB212CC, 0x0D7B4FEB
.long	0x2F2F4BBF, 0x0DB111F3, 0xFAFB1EAF, 0x0DE5566F
.long	0xF9B9E65B, 0x0E1AAC0B, 0x7C142FF9, 0x0E50AB87
.long	0x5B193BF8, 0x0E84D669, 0xB1DF8AF5, 0x0EBA0C03
.long	0x4F2BB6DA, 0x0EF04782, 0xE2F6A490, 0x0F245962
.long	0x9BB44DB4, 0x0F596FBB, 0x82A16122, 0x0F8FCBAA
.long	0x91A4DCB5, 0x0FC3DF4A, 0x360E13E2, 0x0FF8D71D
.long	0x839198DA, 0x102F0CE4, 0xD23AFF88, 0x1063680E
.long	0x86C9BF6A, 0x10984212, 0x287C2F45, 0x10CE5297
.long	0x794D9D8B, 0x1102F39E, 0x17A104EE, 0x1137B086
.long	0x9D894628, 0x116D9CA7, 0xC275CBD9, 0x11A281E8
.long	0xF3133ECF, 0x11D72262, 0xAFD80E83, 0x120CEAFB
.long	0x4DE70912, 0x124212DD, 0xA160CB56, 0x12769794
.long	0xC9B8FE2C, 0x12AC3D79, 0x1E139EDB, 0x12E1A66C
.long	0x25988692, 0x13161007, 0xEEFEA836, 0x134B9408
.long	0x955F2922, 0x13813C85, 0xFAB6F36B, 0x13B58BA6
.long	0xB964B045, 0x13EAEE90, 0x73DEEE2C, 0x1420D51A
.long	0x10D6A9B6, 0x14550A61, 0x550C5424, 0x148A4CF9
.long	0xD527B496, 0x14C0701B, 0xCA71A1BC, 0x14F48C22
.long	0x7D0E0A2A, 0x1529AF2B, 0x2E28C65A, 0x15600D7B
.long	0xF9B2F7F1, 0x159410D9, 0x781FB5ED, 0x15C91510
.long	0x9627A369, 0x15FF5A54, 0xDDD8C622, 0x16339874
.long	0x154EF7AA, 0x16687E92, 0x9AA2B594, 0x169E9E36
.long	0x20A5B17D, 0x16D322E2, 0xA8CF1DDC, 0x1707EB9A
.long	0x5302E553, 0x173DE681, 0xD3E1CF54, 0x1772B010
.long	0x08DA4328, 0x17A75C15, 0x4B10D3F2, 0x17DD331A
.long	0x6EEA8477, 0x18123FF0, 0x8AA52594, 0x1846CFEC
.long	0xAD4E6EFA, 0x187C83E7, 0xCC51055C, 0x18B1D270
.long	0xFF6546B3, 0x18E6470C, 0x3F3E9860, 0x191BD8D0
.long	0x27871F3C, 0x19516782, 0xB168E70A, 0x1985C162
.long	0x5DC320CD, 0x19BB31BB, 0x1A99F480, 0x19F0FF15
.long	0x614071A1, 0x1A253EDA, 0xF9908E09, 0x1A5A8E90
.long	0x9BFA58C6, 0x1A90991A, 0x42F8EEF7, 0x1AC4BF61
.long	0x93B72AB5, 0x1AF9EF39, 0xFC527AB1, 0x1B303583
.long	0xFB67195E, 0x1B6442E4, 0x3A40DFB5, 0x1B99539E
.long	0xC8D117A2, 0x1BCFA885, 0x9D82AEC5, 0x1C03C953
.long	0x84E35A77, 0x1C38BBA8, 0xA61C3115, 0x1C6EEA92
.long	0xA7D19EAD, 0x1CA3529B, 0x91C60658, 0x1CD82742
.long	0x363787EF, 0x1D0E3113, 0x01E2B4F5, 0x1D42DEAC
.long	0x025B6232, 0x1D779657, 0xC2F23ABE, 0x1DAD7BEC
.long	0xF9D764B7, 0x1DE26D73, 0xF84D3DE4, 0x1E1708D0
.long	0x36608D5D, 0x1E4CCB05, 0x41FC585A, 0x1E81FEE3
.long	0x127B6E71, 0x1EB67E9C, 0x171A4A0D, 0x1EEC1E43
.long	0xEE706E48, 0x1F2192E9, 0x6A0C89DA, 0x1F55F7A4
.long	0x848FAC50, 0x1F8B758D, 0x72D9CBB3, 0x1FC12978
.long	0x8F903E9F, 0x1FF573D6, 0x33744E46, 0x202AD0CC
.long	0xA028B0EC, 0x2060C27F, 0x8832DD28, 0x2094F31F
.long	0x6A3F9471, 0x20CA2FE7, 0xA267BCC6, 0x21005DF0
.long	0xCB01ABF8, 0x2134756C, 0xFDC216F5, 0x216992C7
.long	0xFD329CB3, 0x219FF779, 0x3E3FA1F0, 0x21D3FAAC
.long	0x4DCF8A6D, 0x2208F957, 0x21436D08, 0x223F37AD
.long	0x34CA2425, 0x227382CC, 0x41FCAD2E, 0x22A8637F
.long	0x127BD87A, 0x22DE7C5F, 0x6B8D674D, 0x23130DBB
.long	0x4670C120, 0x2347D12A, 0xD80CF167, 0x237DC574
.long	0x070816E1, 0x23B29B69, 0x48CA1C99, 0x23E74243
.long	0x1AFCA3BE, 0x241D12D4, 0x90DDE657, 0x24522BC4
.long	0xB5155FED, 0x2486B6B5, 0x225AB7E8, 0x24BC6463
.long	0xF578B2F1, 0x24F1BEBD, 0x72D6DFAE, 0x25262E6D
.long	0xCF8C9799, 0x255BBA08, 0x81B7DEBF, 0x25915445
.long	0xE225D66F, 0x25C5A956, 0x9AAF4C0B, 0x25FB13AC
.long	0xE0AD8F87, 0x2630EC4B, 0xD8D8F368, 0x2665275E
.long	0x8F0F3042, 0x269A7136, 0x19697E29, 0x26D086C2
.long	0x9FC3DDB4, 0x2704A872, 0x47B4D521, 0x2739D28F
.long	0x8CD10535, 0x27702399, 0xF0054682, 0x27A42C7F
.long	0xEC069822, 0x27D9379F, 0xE7083E2C, 0x280F8587
.long	0xF06526DB, 0x2843B374, 0x2C7E7091, 0x2878A052
.long	0xB79E0CB5, 0x28AEC866, 0x32C2C7F1, 0x28E33D40
.long	0x3F7379ED, 0x29180C90, 0x4F505869, 0x294E0FB4
.long	0xB1923742, 0x2982C9D0, 0xDDF6C512, 0x29B77C44
.long	0x15747656, 0x29ED5B56, 0xCD68C9F6, 0x2A225915
.long	0x40C2FC73, 0x2A56EF5B, 0x10F3BB91, 0x2A8CAB32
.long	0x4A98553A, 0x2AC1EAFF, 0x1D3E6A89, 0x2AF665BF
.long	0xE48E052B, 0x2B2BFF2E, 0x4ED8C33B, 0x2B617F7D
.long	0xA28EF40A, 0x2B95DF5C, 0xCB32B10C, 0x2BCB5733
.long	0x5EFFAEA7, 0x2C011680, 0x76BF9A51, 0x2C355C20
.long	0x946F80E6, 0x2C6AB328, 0x5CC5B090, 0x2CA0AFF9
.long	0xB3F71CB4, 0x2CD4DBF7, 0xA0F4E3E2, 0x2D0A12F5
.long	0x84990E6D, 0x2D404BD9, 0xE5BF5208, 0x2D745ECF
.long	0xDF2F268A, 0x2DA97683, 0xD6FAF02D, 0x2DDFD424
.long	0x065CD61D, 0x2E13E497, 0xC7F40BA4, 0x2E48DDBC
.long	0xF9F10E8D, 0x2E7F152B, 0x7C36A919, 0x2EB36D3B
.long	0x5B44535F, 0x2EE8488A, 0xF2156837, 0x2F1E5AAC
.long	0x174D6123, 0x2F52F8AC, 0x1D20B96B, 0x2F87B6D7
.long	0xE468E7C5, 0x2FBDA48C, 0x0EC190DC, 0x2FF286D8
.long	0x1271F513, 0x3027288E, 0x970E7257, 0x305CF2B1
.long	0xFE690777, 0x309217AE, 0xBE034954, 0x30C69D9A
.long	0x6D841BA9, 0x30FC4501, 0xE472914A, 0x3131AB20
.long	0x1D8F359D, 0x316615E9, 0x64F30304, 0x319B9B63
.long	0x1F17E1E2, 0x31D1411E, 0xA6DDDA5B, 0x32059165
.long	0x109550F1, 0x323AF5BF, 0x6A5D5296, 0x3270D997
.long	0x44F4A73C, 0x32A50FFD, 0x9631D10B, 0x32DA53FC
.long	0xDDDF22A7, 0x3310747D, 0x5556EB51, 0x3344919D
.long	0xAAACA625, 0x3379B604, 0xEAABE7D8, 0x33B011C2
.long	0xA556E1CD, 0x33E41633, 0x8EAC9A41, 0x34191BC0
.long	0xB257C0D1, 0x344F62B0, 0x6F76D882, 0x34839DAE
.long	0x0B548EA3, 0x34B8851A, 0x8E29B24D, 0x34EEA660
.long	0x58DA0F70, 0x352327FC, 0x6F10934C, 0x3557F1FB
.long	0x4AD4B81E, 0x358DEE7A, 0x6EC4F313, 0x35C2B50C
.long	0x8A762FD8, 0x35F7624F, 0x6D13BBCE, 0x362D3AE3
.long	0x242C5561, 0x366244CE, 0xAD376ABA, 0x3696D601
.long	0x18854568, 0x36CC8B82, 0x4F534B61, 0x3701D731
.long	0xA3281E39, 0x37364CFD, 0x0BF225C8, 0x376BE03D
.long	0x2777579D, 0x37A16C26, 0xB1552D85, 0x37D5C72F
.long	0x9DAA78E6, 0x380B38FB, 0x428A8B8F, 0x3841039D
.long	0x932D2E73, 0x38754484, 0xB7F87A0F, 0x38AA95A5
.long	0x92FB4C4A, 0x38E09D87, 0x77BA1F5C, 0x3914C4E9
.long	0xD5A8A734, 0x3949F623, 0x65896880, 0x398039D6
.long	0xFEEBC2A0, 0x39B4484B, 0xFEA6B348, 0x39E95A5E
.long	0xBE50601A, 0x3A1FB0F6, 0x36F23C10, 0x3A53CE9A
.long	0xC4AECB15, 0x3A88C240, 0xF5DA7DDA, 0x3ABEF2D0
.long	0x99A88EA8, 0x3AF357C2, 0x4012B252, 0x3B282DB3
.long	0x10175EE6, 0x3B5E3920, 0x0A0E9B4F, 0x3B92E3B4
.long	0x0C924223, 0x3BC79CA1, 0x4FB6D2AC, 0x3BFD83C9
.long	0xD1D243AC, 0x3C32725D, 0x4646D497, 0x3C670EF5
.long	0x97D889BC, 0x3C9CD2B2, 0x9EE75616, 0x3CD203AF
.long	0x86A12B9B, 0x3D06849B, 0x68497682, 0x3D3C25C2
.long	0x812DEA11, 0x3D719799, 0xE1796495, 0x3DA5FD7F
.long	0xD9D7BDBB, 0x3DDB7CDF, 0xE826D695, 0x3E112E0B
.long	0xE2308C3A, 0x3E45798E, 0x9ABCAF48, 0x3E7AD7F2
.long	0xA0B5ED8D, 0x3EB0C6F7, 0x88E368F1, 0x3EE4F8B5
.long	0xEB1C432D, 0x3F1A36E2, 0xD2F1A9FC, 0x3F50624D
.long	0x47AE147B, 0x3F847AE1, 0x9999999A, 0x3FB99999
__pwr_10_to_0:
.long	0x00000000, 0x3FF00000, 0x00000000, 0x40240000
.long	0x00000000, 0x40590000, 0x00000000, 0x408F4000
.long	0x00000000, 0x40C38800, 0x00000000, 0x40F86A00
.long	0x00000000, 0x412E8480, 0x00000000, 0x416312D0
.long	0x00000000, 0x4197D784, 0x00000000, 0x41CDCD65
.long	0x20000000, 0x4202A05F, 0xE8000000, 0x42374876
.long	0xA2000000, 0x426D1A94, 0xE5400000, 0x42A2309C
.long	0x1E900000, 0x42D6BCC4, 0x26340000, 0x430C6BF5
.long	0x37E08000, 0x4341C379, 0x85D8A000, 0x43763457
.long	0x674EC800, 0x43ABC16D, 0x60913D00, 0x43E158E4
.long	0x78B58C40, 0x4415AF1D, 0xD6E2EF50, 0x444B1AE4
.long	0x064DD592, 0x4480F0CF, 0xC7E14AF6, 0x44B52D02
.long	0x79D99DB4, 0x44EA7843, 0x2C280290, 0x45208B2A
.long	0xB7320334, 0x4554ADF4, 0xE4FE8401, 0x4589D971
.long	0x2F1F1281, 0x45C027E7, 0xFAE6D721, 0x45F431E0
.long	0x39A08CE9, 0x46293E59, 0x8808B023, 0x465F8DEF
.long	0xB5056E16, 0x4693B8B5, 0x2246C99C, 0x46C8A6E3
.long	0xEAD87C03, 0x46FED09B, 0x72C74D82, 0x47334261
.long	0xCF7920E2, 0x476812F9, 0x4357691A, 0x479E17B8
.long	0x2A16A1B0, 0x47D2CED3, 0xF49C4A1C, 0x48078287
.long	0xF1C35CA3, 0x483D6329, 0x371A19E6, 0x48725DFA
.long	0xC4E0A060, 0x48A6F578, 0xF618C878, 0x48DCB2D6
.long	0x59CF7D4B, 0x4911EFC6, 0xF0435C9E, 0x49466BB7
.long	0xEC5433C6, 0x497C06A5, 0xB3B4A05C, 0x49B18427
.long	0xA0A1C873, 0x49E5E531, 0x08CA3A90, 0x4A1B5E7E
.long	0xC57E649A, 0x4A511B0E, 0x76DDFDC0, 0x4A8561D2
.long	0x14957D30, 0x4ABABA47, 0x6CDD6E3E, 0x4AF0B46C
.long	0x8814C9CE, 0x4B24E187, 0x6A19FC42, 0x4B5A19E9
.long	0xE2503DA9, 0x4B905031, 0x5AE44D13, 0x4BC4643E
.long	0xF19D6058, 0x4BF97D4D, 0x6E04B86E, 0x4C2FDCA1
.long	0xE4C2F345, 0x4C63E9E4, 0x1DF3B016, 0x4C98E45E
.long	0xA5709C1C, 0x4CCF1D75, 0x87666192, 0x4D037269
.long	0xE93FF9F6, 0x4D384F03, 0xE38FF874, 0x4D6E62C4
.long	0x0E39FB48, 0x4DA2FDBB, 0xD1C87A1A, 0x4DD7BD29
.long	0x463A98A0, 0x4E0DAC74, 0xABE49F64, 0x4E428BC8
.long	0xD6DDC73D, 0x4E772EBA, 0x8C95390C, 0x4EACFA69
.long	0xF7DD43A8, 0x4EE21C81, 0x75D49492, 0x4F16A3A2
.long	0x1349B9B6, 0x4F4C4C8B, 0xEC0E1412, 0x4F81AFD6
.long	0xA7119916, 0x4FB61BCC, 0xD0D5FF5C, 0x4FEBA2BF
.long	0xE285BF9A, 0x502145B7, 0xDB272F80, 0x50559725
.long	0x51F0FB60, 0x508AFCEF, 0x93369D1C, 0x50C0DE15
.long	0xF8044463, 0x50F5159A, 0xB605557C, 0x512A5B01
.long	0x11C3556E, 0x516078E1, 0x56342ACA, 0x51949719
.long	0xABC1357C, 0x51C9BCDF, 0xCB58C16E, 0x5200160B
.long	0xBE2EF1CA, 0x52341B8E, 0x6DBAAE3C, 0x52692272
.long	0x092959CB, 0x529F6B0F, 0x65B9D81F, 0x52D3A2E9
.long	0xBF284E27, 0x53088BA3, 0xAEF261B1, 0x533EAE8C
.long	0xED577D0F, 0x53732D17, 0xE8AD5C53, 0x53A7F85D
.long	0x62D8B368, 0x53DDF675, 0x5DC77021, 0x5412BA09
.long	0xB5394C29, 0x5447688B, 0xA2879F33, 0x547D42AE
.long	0x2594C380, 0x54B249AD, 0x6EF9F460, 0x54E6DC18
.long	0x8AB87178, 0x551C931E, 0x16B346EB, 0x5551DBF3
.long	0xDC6018A6, 0x558652EF, 0xD3781ED0, 0x55BBE7AB
.long	0x642B1342, 0x55F170CB, 0x3D35D812, 0x5625CCFE
.long	0xCC834E16, 0x565B403D, 0x9FD210CE, 0x56910826
.long	0x47C69502, 0x56C54A30, 0x59B83A42, 0x56FA9CBC
.long	0xB8132469, 0x5730A1F5, 0x2617ED83, 0x5764CA73
.long	0xEF9DE8E4, 0x5799FD0F, 0xF5C2B18E, 0x57D03E29
.long	0x73335DF2, 0x58044DB4, 0x9000356E, 0x58396121
.long	0xF40042CA, 0x586FB969, 0x388029BE, 0x58A3D3E2
.long	0xC6A0342E, 0x58D8C8DA, 0x7848413A, 0x590EFB11
.long	0xEB2D28C4, 0x59435CEA, 0xA5F872F5, 0x59783425
.long	0x0F768FB2, 0x59AE412F, 0x69AA19CF, 0x59E2E8BD
.long	0xC414A043, 0x5A17A2EC, 0xF519C854, 0x5A4D8BA7
.long	0xF9301D34, 0x5A827748, 0x377C2481, 0x5AB7151B
.long	0x055B2DA1, 0x5AECDA62, 0x4358FC85, 0x5B22087D
.long	0x942F3BA6, 0x5B568A9C, 0xB93B0A90, 0x5B8C2D43
.long	0x53C4E69A, 0x5BC19C4A, 0xE8B62040, 0x5BF6035C
.long	0x22E3A850, 0x5C2B8434, 0x95CE4932, 0x5C6132A0
.long	0xBB41DB7E, 0x5C957F48, 0xEA12525E, 0x5CCADF1A
.long	0xD24B737B, 0x5D00CB70, 0x06DE505A, 0x5D34FE4D
.long	0x4895E470, 0x5D6A3DE0, 0x2D5DAEC6, 0x5DA066AC
.long	0x38B51A78, 0x5DD48057, 0x06E26116, 0x5E09A06D
.long	0x244D7CAE, 0x5E400444, 0x2D60DBDA, 0x5E740555
.long	0x78B912D0, 0x5EA906AA, 0x16E75784, 0x5EDF4855
.long	0x2E5096B2, 0x5F138D35, 0x79E4BC5E, 0x5F487082
.long	0x185DEB76, 0x5F7E8CA3, 0xEF3AB32A, 0x5FB317E5
.long	0x6B095FF4, 0x5FE7DDDF, 0x45CBB7F1, 0x601DD557
.long	0x8B9F52F7, 0x6052A556, 0x2E8727B5, 0x60874EAC
.long	0x3A28F1A2, 0x60BD2257, 0x84599705, 0x60F23576
.long	0x256FFCC6, 0x6126C2D4, 0x2ECBFBF8, 0x615C7389
.long	0xBD3F7D7B, 0x6191C835, 0x2C8F5CDA, 0x61C63A43
.long	0xF7B33410, 0x61FBC8D3, 0x7AD0008A, 0x62315D84
.long	0x998400AC, 0x6265B4E5, 0xFFE500D7, 0x629B221E
.long	0x5FEF2086, 0x62D0F553, 0x37EAE8A8, 0x630532A8
.long	0x45E5A2D2, 0x633A7F52, 0x6BAF85C3, 0x63708F93
.long	0x469B6734, 0x63A4B378, 0x58424101, 0x63D9E056
.long	0xF72968A1, 0x64102C35, 0x74F3C2C9, 0x64443743
.long	0x5230B37B, 0x64794514, 0x66BCE05A, 0x64AF9659
.long	0xE0360C38, 0x64E3BDF7, 0xD8438F46, 0x6518AD75
.long	0x4E547318, 0x654ED8D3, 0x10F4C7EF, 0x65834784
.long	0x1531F9EB, 0x65B81965, 0x5A7E7866, 0x65EE1FBE
.long	0xF88F0B40, 0x6622D3D6, 0xB6B2CE10, 0x665788CC
.long	0xE45F8194, 0x668D6AFF, 0xEEBBB0FC, 0x66C262DF
.long	0xEA6A9D3B, 0x66F6FB97, 0xE505448A, 0x672CBA7D
.long	0xAF234AD6, 0x6761F48E, 0x5AEC1D8C, 0x679671B2
.long	0xF1A724EF, 0x67CC0E1E, 0x57087715, 0x680188D3
.long	0x2CCA94DA, 0x6835EB08, 0x37FD3A10, 0x686B65CA
.long	0x62FE444A, 0x68A11F9E, 0xFBBDD55C, 0x68D56785
.long	0x7AAD4AB3, 0x690AC167, 0xACAC4EB0, 0x6940B8E0
.long	0xD7D7625C, 0x6974E718, 0x0DCD3AF3, 0x69AA20DF
.long	0x68A044D8, 0x69E0548B, 0x42C8560E, 0x6A1469AE
.long	0xD37A6B92, 0x6A498419, 0x48590676, 0x6A7FE520
.long	0x2D37A40A, 0x6AB3EF34, 0x38858D0C, 0x6AE8EB01
.long	0x86A6F04F, 0x6B1F25C1, 0xF4285631, 0x6B537798
.long	0x31326BBD, 0x6B88557F, 0xFD7F06AC, 0x6BBE6ADE
.long	0x5E6F642C, 0x6BF302CB, 0x360B3D37, 0x6C27C37E
.long	0xC38E0C85, 0x6C5DB45D, 0x9A38C7D3, 0x6C9290BA
.long	0x40C6F9C8, 0x6CC734E9, 0x90F8B83A, 0x6CFD0223
.long	0x3A9B7324, 0x6D322156, 0xC9424FED, 0x6D66A9AB
.long	0xBB92E3E8, 0x6D9C5416, 0x353BCE71, 0x6DD1B48E
.long	0xC28AC20D, 0x6E0621B1, 0x332D7290, 0x6E3BAA1E
.long	0xDFFC679A, 0x6E714A52, 0x97FB8180, 0x6EA59CE7
.long	0x7DFA61E0, 0x6EDB0421, 0xEEBC7D2C, 0x6F10E294
.long	0x2A6B9C77, 0x6F451B3A, 0xB5068395, 0x6F7A6208
.long	0x7124123D, 0x6FB07D45, 0xCD6D16CC, 0x6FE49C96
.long	0x80C85C7F, 0x7019C3BC, 0xD07D39CF, 0x70501A55
.long	0x449C8843, 0x708420EB, 0x15C3AA54, 0x70B92926
.long	0x9B3494E9, 0x70EF736F, 0xC100DD12, 0x7123A825
.long	0x31411456, 0x7158922F, 0xFD91596C, 0x718EB6BA
.long	0xDE7AD7E4, 0x71C33234, 0x16198DDD, 0x71F7FEC2
.long	0x9B9FF154, 0x722DFE72, 0xA143F6D4, 0x7262BF07
.long	0x8994F489, 0x72976EC9, 0xEBFA31AB, 0x72CD4A7B
.long	0x737C5F0B, 0x73024E8D, 0xD05B76CE, 0x7336E230
.long	0x04725482, 0x736C9ABD, 0x22C774D1, 0x73A1E0B6
.long	0xAB795205, 0x73D658E3, 0x9657A686, 0x740BEF1C
.long	0xDDF6C814, 0x74417571, 0x55747A19, 0x7475D2CE
.long	0xEAD1989F, 0x74AB4781, 0x32C2FF63, 0x74E10CB1
.long	0x7F73BF3C, 0x75154FDD, 0xDF50AF0B, 0x754AA3D4
.long	0x0B926D67, 0x7580A665, 0x4E7708C1, 0x75B4CFFE
.long	0xE214CAF1, 0x75EA03FD, 0xAD4CFED7, 0x7620427E
.long	0x58A03E8D, 0x7654531E, 0xEEC84E30, 0x768967E5
.long	0x6A7A61BC, 0x76BFC1DF, 0xA28C7D16, 0x76F3D92B
.long	0x8B2F9C5C, 0x7728CF76, 0x2DFB8373, 0x775F0354
.long	0x9CBD3228, 0x77936214, 0xC3EC7EB2, 0x77C83A99
.long	0x34E79E5E, 0x77FE4940, 0x2110C2FB, 0x7832EDC8
.long	0x2954F3BA, 0x7867A93A, 0xB3AA30A8, 0x789D9388
.long	0x704A5E69, 0x78D27C35, 0xCC5CF603, 0x79071B42
.long	0x7F743384, 0x793CE213, 0x2FA8A032, 0x79720D4C
.long	0x3B92C83E, 0x79A6909F, 0x0A777A4E, 0x79DC34C7
.long	0x668AAC71, 0x7A11A0FC, 0x802D578D, 0x7A46093B
.long	0x6038AD70, 0x7A7B8B8A, 0x7C236C66, 0x7AB13736
.long	0x1B2C4780, 0x7AE58504, 0x21F75960, 0x7B1AE645
.long	0x353A97DC, 0x7B50CFEB, 0x02893DD3, 0x7B8503E6
.long	0x832B8D48, 0x7BBA44DF, 0xB1FB384D, 0x7BF06B0B
.long	0x9E7A0660, 0x7C2485CE, 0x461887F8, 0x7C59A742
.long	0x6BCF54FB, 0x7C900889, 0xC6C32A3A, 0x7CC40AAB
.long	0xB873F4C8, 0x7CF90D56, 0x6690F1FA, 0x7D2F50AC
.long	0xC01A973C, 0x7D63926B, 0xB0213D0B, 0x7D987706
.long	0x5C298C4E, 0x7DCE94C8, 0x3999F7B1, 0x7E031CFD
.long	0x8800759D, 0x7E37E43C, 0xAA009304, 0x7E6DDD4B
.long	0x4A405BE2, 0x7EA2AA4F, 0x1CD072DA, 0x7ED754E3
.long	0xE4048F90, 0x7F0D2A1B, 0x6E82D9BA, 0x7F423A51
.long	0xCA239028, 0x7F76C8E5, 0x3CAC7432, 0x7FAC7B1F
.long	0x85EBC89F, 0x7FE1CCF3
#
#
.text
#
# #####################
# #####  xlibs.s  #####  String and PRINT routines
# #####################
#
# ************************
# *****  main.print  *****  main print routine - internal entry point
# ************************
#
# in:	arg1 -> string to print
#	arg0 = file number
# out:	nothing
#
# Destroys: eax, ebx, ecx, edx, esi, edi.
#
main.print:
mainPrint:
	pushl	%ebp
	movl	%esp,%ebp
#;
print_again:
	movl	12(%ebp),%eax	# eax -> string to print
	orl	%eax,%eax	# null pointer?
	jz	print_null	# yes: do nothing
	pushl	$0	#
	pushl	%esp	#
	pushl	-8(%eax)	# push "nbytes" parameter
	pushl	%eax	# push "buf" parameter
	movl	8(%ebp),%eax	# eax = fileNumber
	cmpl	$2,%eax	# is it stdin, stdout, stderr
	jg	prtfile	# no
	movl	$1,%eax	# eax = stdout fileNumber
prtfile:
	pushl	%eax	# push fileNumber
	call	XxxWriteFile_20	#
#	add	esp,20		;
#;
	orl	%eax,%eax	# error?  (eax < 0 if error)
	jmp	print_good	# ntntnt  (add error checking)
#
#
	jns	print_good	#no: exit
#	cmp	[errno],4		;yes: EINTR?
	jne	print_crash	#no: it was a real error
	cmpl	$0,__SOFTBREAK	#was it a soft break?
	jne	print_again	#no: it was just some blowhard signal
	jmp	print_again
print_crash:
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# Return directly from there
#
#
print_good:
print_null:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***********************************
# *****  %_PrintConsoleNewline  *****  prints a newline to stdout
# ***********************************
#
# in:	nothing
# out:	nothing
#
# Destroys: eax, ebx, ecx, edx, esi, edi.
#
__PrintConsoleNewline:
__print.console.newline:
	pushl	$__newline.string	#push string to print
	pushl	$1	#push stdout
	call	main.print
	addl	$8,%esp
	ret
#
#
# ********************************
# *****  %_PrintFileNewline  *****  prints a newline to a file
# ********************************
#
# in:	arg0 = file number
# out:	nothing
#
# destroys: eax, ebx, ecx, edx, esi, edi
#
__PrintFileNewline:
#	mov	eax,[esp+4]	;eax = file number
#
# 5/5/93:  compiler doesn't push file number
#
	pushl	$__newline.string	#push string to print
	pushl	%eax	#push file number
	call	main.print
	addl	$8,%esp
	ret
#
#
# *********************
# *****  %_Print  *****  prints a string
# *********************
#
# in:	eax -> string to print
#	arg0 = file number
# out:	nothing
#
# Destroys: eax, ebx, ecx, edx, esi, edi.
#
# Frees string pointed to by eax before exiting.
#
__Print:
	pushl	%ebp
	movl	%esp,%ebp
	pushl	%eax	# push pointer to string to print
	movl	8(%ebp),%eax	# eax = file number
	cmpl	$2,%eax	# see if STDIN, STDOUT, STDERR
	jl	fpr	# nope, so it's a file print
	movl	$1,%eax	# eax = stdout
fpr:
	pushl	%eax	#push file number
	call	main.print	#print the string
	addl	$8,%esp
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *****************************
# *****  %_PrintThenFree  *****  prints a string, then frees it
# *****************************
#
# in:	eax -> string to print
#	arg0 = file number
# out:	nothing
#
# Destroys: eax, ebx, ecx, edx, esi, edi.
#
# Local variables:
#	[ebp-4] -> string to print (on-entry eax)
#
# Frees string pointed to by eax before exiting.
#
__PrintThenFree:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%eax,-4(%ebp)	#save pointer
	pushl	%eax	#push pointer to string to print
	pushl	8(%ebp)	#push file number
	call	main.print	#print the string
	addl	$8,%esp
	movl	-4(%ebp),%esi	#esi -> string to free
	call	_____free	#free printed string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# **************************************
# ***** %_PrintWithNewlineThenFree *****
# **************************************
#
# in:	eax -> string to print, followed by newline
#	arg0 = file number
# out:	nothing
#
# Destroys: eax, ebx, ecx, edx, esi, edi.
#
# Local variables:
#	[ebp-4] -> string to print (on-entry eax)
#
# Frees string pointed to by eax before exiting.
#
__PrintWithNewlineThenFree:
	orl	%eax,%eax	# null pointer?
	jnz	pwntfa	# no
	movl	4(%esp),%eax	# eax = file number
	jmp	__PrintFileNewline
#
pwntfa:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%eax,-4(%ebp)	#save pointer
#;
ptfn_again:
	movl	-4(%ebp),%eax	#eax -> string to print
	movl	-8(%eax),%ebx	#ebx = length of string
	movb	$'\n',(%eax,%ebx,1)	#replace null terminator with newline
	incl	%ebx	#ebx = length of string including newline
	pushl	$0	#
	pushl	%esp	#
	pushl	%ebx	# push "nbytes" parameter
	pushl	%eax	# push "buf" parameter
	movl	8(%ebp),%eax	# eax = fileNumber
	cmpl	$2,%eax	# is it stdin, stdout, stderr
	jg	prtfilex	# no
	movl	$1,%eax	# eax = stdout fileNumber
prtfilex:
	pushl	%eax	# push fileNumber
	call	XxxWriteFile_20	#
#	add	esp,20		;
#;
	orl	%eax,%eax	# was there an error?  (eax < 0 if error)
	jmp	ptfn_good	# (add error checking)
#
	jns	ptfn_good	#no: free the string and exit
#	cmp	[errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	ptfn_crash	#no: it was a real error
	cmpl	$0,__SOFTBREAK	#was it a soft break?
	jne	ptfn_again	#no: it was just some blowhard signal
#	tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	ptfn_again
ptfn_crash:
	movl	-4(%ebp),%eax	#eax -> original string
	movl	-8(%eax),%ebx	#ebx = length of string
	movb	$0,(%eax,%ebx,1)	#restore null terminator
	movl	-4(%ebp),%esi	#esi -> string to free
	call	_____free	#free printed string
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# Return directly from there
#
ptfn_good:
	movl	-4(%ebp),%esi	#esi -> string to free
	call	_____free	#free printed string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *******************************
# *****  %_PrintFirstComma  *****  creates string with spaces for first tab stop
# *******************************
#
# in:	nothing
# out:	eax -> string with [##TABSAT] spaces in it
#
# destroys: ebx, ecx, edx, esi, edi
#
__PrintFirstComma:
	movl	__TABSAT,%esi	#esi = _ of spaces to create
	cld
	addl	$64,%esi	#get more than necessary (caller will almost
	call	______calloc	#esi -> header of new string
	addl	$16,%esi	#esi -> new string
	movl	%esi,%edi	#edi -> new string
	movl	__TABSAT,%ecx	#ecx = _ of spaces to create
	jecxz	pfc.no.stosb	#no tab stops?
	movb	$' ',%al	#ready to write some spaces
	rep
	stosb		#write them spaces!
#;
pfc.no.stosb:
	movb	$0,(%edi)	#write terminating null
	subl	%esi,%edi	#edi = length of string
	movl	%edi,-8(%esi)	#store length of new string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = new info word: allocated ubyte.string
	movl	%eax,-4(%esi)	#store new info word
	movl	%esi,%eax	#eax = return value = addr of new string
	ret
#
#
# ********************************
# *****  %_PrintAppendComma  *****  appends enough spaces to reach next tab stop
# ********************************
#
# in:	eax -> string to append to
# out:	eax -> string with spaces appended to it
#
# destroys: ebx, ecx, edx, esi, edi
#
__PrintAppendComma:
	orl	%eax,%eax	#appending to null string?
	jz	__PrintFirstComma	#yes: use simpler subroutine
	movl	%eax,%esi	#esi -> original string (safe from upcoming DIV)
	movl	-8(%eax),%eax	#eax = size of current string
	movl	__TABSAT,%ecx	#there's a tab stop every ecx columns
	cld
	xorl	%edx,%edx	#clear high-order bits of dividend
	divw	%cx	#edx = LEN(string) MOD [__TABSAT]
	subl	%edx,%ecx	#ecx = _ of spaces to add to get to next tab
	movl	-8(%esi),%eax	#eax = length of original string
	leal	(%eax,%ecx,1),%edi	#edi = length needed
	incl	%edi	#one more for terminating null
	movl	-16(%esi),%edx	#edx = length of string's chunk including header
	subl	$16,%edx	#edx = length of string's chunk excluding header
	cmpl	%edi,%edx	#chunk big enough to hold expanded string?
	jae	pac.big.enough	#yes: skip realloc
	pushl	%eax
	pushl	%ecx
	pushl	%edx
	call	_____realloc	#esi -> string with enough space to hold new
	popl	%edx	# spaces# all other registers destroyed
	popl	%ecx
	popl	%eax
#;
#;	mov	[ebp-4],esi	;save new pointer to string
#;
pac.big.enough:
	leal	(%esi,%eax,1),%edi	#edi -> char after last char of original string
	movb	$' ',%al	#ready to write some spaces
	jecxz	pac.skip.stosb	#ecx should be != 0, but just in case...
	rep
	stosb		#append them spaces!
#;
pac.skip.stosb:
	movb	$0,(%edi)	#append null terminator
	subl	%esi,%edi	#edi = length of new string
	movl	%edi,-8(%esi)	#store length of new string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = new info word: allocated ubyte.string
	movl	%eax,-4(%esi)	#store new info word
	movl	%esi,%eax	#eax = return value = addr of new string
	ret
#
#
# *****************************************
# *****  %_print.tab.a0.eq.a0.tab.a1  *****  appends spaces to reach desired
# *****************************************  tab stop
#
# in:	eax -> string to append spaces to
#	ebx = one more than desired length of string
# out:	eax -> new string
#
# destroys: ebx, ecx, edx, esi, edi
#
# String pointed to by eax is assumed to be in dynamic memory; it may
# be realloc'ed.
#
__print.tab.a0.eq.a0.tab.a1:
__print.tab.a0.eq.a0.tab.a1.ss:
	cld
	leal	-1(%ebx),%ecx	#ecx = desired length of string
	orl	%ecx,%ecx	#desired length <= 0?
	jbe	pt_abort	#yes: do nothing
	orl	%eax,%eax	#null string?
	jnz	pt001	#no: it's our job
	movl	%ebx,%eax	#yes: pass it off on specialized routine
	jmp	__print.tab.first.a0
#
pt001:
	movl	-8(%eax),%edi	#edi = length of existing string
	cmpl	%ecx,%edi	#string is too long or already right length?
	jae	pt_abort	#yes: nothing to do
#;
	movl	-16(%eax),%edx	#edx = length of string's chunk including header
	subl	$16,%edx	#edx = length of string's chunk excluding header
	cmpl	%ebx,%edx	#is chunk already big enough to hold new string?
	jae	pt_append	#yes: no reallocation necessary
#;
	movl	%eax,%esi	#esi -> existing string
	leal	64(%ebx),%edi	#edi = new length plus 64, since string will
	pushl	%ebx	# probably be appended to
	call	_____realloc	#make room for spaces we're about to append
	popl	%ebx	#esi -> new string
	movl	%esi,%eax	#eax -> new string
	movl	-8(%eax),%edi	#edi = length of existing string
	leal	-1(%ebx),%ecx	#ecx = desired length of string
#;
pt_append:
	movl	%ecx,-8(%eax)	#store new length of string
	subl	%edi,%ecx	#ecx = number of spaces to append
	leal	(%eax,%edi,1),%edi	#edi -> char after last char of existing string
	jecxz	pt_no_stosb	#just in case...
	movl	%eax,%esi	#save pointer to result string
	movb	$' ',%al	#ready to write some spaces
	rep
	stosb		#append spaces!
	movl	%esi,%eax	#eax -> result string
pt_no_stosb:
	movb	$0,(%edi)	#append null terminator
#;
pt_abort:
	ret
#
#
# *****************************************
# *****  %_print.tab.a0.eq.a1.tab.a0  *****  appends spaces to reach desired
# *****************************************  tab stop
#
# in:	eax = one more than desired length of string
# 	ebx -> string to append spaces to
# out:	eax -> new string
#
# destroys: ebx, ecx, edx, esi, edi
#
# String pointed to by ebx is assumed to be in dynamic memory; it may
# be realloc'ed.
#
__print.tab.a0.eq.a1.tab.a0:
__print.tab.a0.eq.a1.tab.a0.ss:
	xchgl	%ebx,%eax
	jmp	__print.tab.a0.eq.a0.tab.a1
#
#
# **********************************
# *****  %_print.tab.first.a0  *****  creates a string containing a given number
# **********************************  of spaces
#
# in:	eax = one more than number of spaces to create
# out:	eax -> created string
#
# destroys: edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.  Returns null pointer if caller asks for zero or
# fewer spaces.
#
__print.tab.first.a0:
	leal	-1(%eax),%esi	#esi = _ of spaces to create
	orl	%esi,%esi	#zero or less?
	jbe	ptf_null	#yes: return null string
	pushl	%ebx	#must not destroy a1
	pushl	%ecx
	pushl	%eax
	addl	$64,%esi	#get 64 bytes more than required, since string
	call	_____calloc	#esi -> new string
	popl	%ebx	#ebx = requested tab stop
	movl	__WHOMASK,%eax	#ebx = system/user bit
	orl	$0x80130001,%eax	#indicate: allocated string
	movl	%eax,-4(%esi)	#store new string's info word
	movl	%esi,%edi	#edi -> new string
	leal	-1(%ebx),%ecx	#ecx = _ of spaces to create
	movl	%ecx,-8(%esi)	#store length of new string
	cld
	movb	$' ',%al	#ready to write spaces
	rep
	stosb		#write them spaces!
	movb	$0,(%edi)	#null terminator at end of string
	movl	%esi,%eax	#eax -> new string
	popl	%ecx	#restore a1
	popl	%ebx
	ret
#
ptf_null:
	xorl	%eax,%eax	#return null pointer
	ret
#
#
# **********************************
# *****  %_print.tab.first.a1  *****  creates a string containing a given number
# **********************************  of spaces
#
# in:	ebx = one more than number of spaces to create
# out:	ebx -> created string
#
# destroys: ecx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.  Returns null pointer if caller asks for zero or
# fewer spaces.
#
__print.tab.first.a1:
	xchgl	%ebx,%eax
	xchgl	%ecx,%edx
	call	__print.tab.first.a0
	xchgl	%ebx,%eax
	xchgl	%ecx,%edx
	ret
#
#
# *************************************
# *****  %_print.first.spaces.a0  *****  creates a string containing a given
# *************************************  number of spaces
#
# in:	eax = desired number of spaces
# out:	eax -> string containing spaces
#
# destroys: edx, esi, esi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.  Returns null pointer if caller asks for zero or
# fewer spaces.
#
__print.first.spaces.a0:
	incl	%eax	#eax = tab stop after making spaces
	jmp	__print.tab.first.a0
#
#
# **************************************
# *****  %_print.append.spaces.a0  *****  appends a given number of spaces
# **************************************  to a string
#
# in:	eax -> string to append spaces to
#	ebx = # of spaces to append
# out:	eax -> new string
#
# destroys: ebx, ecx, edx, esi, edi
#
# String pointed to by eax is assumed to be in dynamic memory; it may
# be realloc'ed.
#
__print.append.spaces.a0:
__PrintAppendSpaces:
	orl	%eax,%eax	#null pointer?
	jz	print_append_null	#yes: create new string
	movl	-8(%eax),%ecx	#ecx = current length of string
	leal	1(%ebx,%ecx,1),%ebx	#ebx = position after last char after
	jmp	__print.tab.a0.eq.a0.tab.a1
print_append_null:
	leal	1(%ebx),%eax	#eax = one more than desired number of spaces
	jmp	__print.tab.first.a0
#
#
# ********************
# *****  %_Read  *****  READ #n, v
# ********************
#
# in:	arg2 = number of bytes to read
#	arg1 -> where to put them
#	arg0 = file number
# out:	nothing
#
# destroys: eax, ebx, ecx, edx, esi, edi
#
__Read:
	pushl	%ebp
	movl	%esp,%ebp
#;
read_again:
#	push	[ebp+16]		; old UNIX
#	push	[ebp+12]		; old UNIX
#	push	[ebp+8]			; old UNIX
	subl	$20,%esp	#
	movl	8(%ebp),%eax	#
	movl	%eax,0(%esp)	# fileNumber
	movl	12(%ebp),%eax	#
	movl	%eax,4(%esp)	# bufferAddr
	movl	16(%ebp),%eax	#
	movl	%eax,8(%esp)	# bufferSize
	leal	12(%esp),%eax	#
	movl	%eax,12(%esp)	# bytesRead
	xorl	%eax,%eax	#
	movl	%eax,16(%esp)	# 0
	call	XxxReadFile_20	#
#	add	esp,20			;
#;
	orl	%eax,%eax	#was there an error?  (eax < 0 if error)
	jmp	read_good	# ntntnt  (add error checking)
#
	jns	read_good	#no: done
#	cmp	[errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	read_crash	#no: it was a real error
	cmpl	$0,__SOFTBREAK	#was it a soft break?
	jne	read_again	#no: it was just some blowhard signal
#	tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	read_again
read_crash:
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# Return directly from there
#
read_good:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_ReadArray  *****  READ #n, v[]   and   READ #n, v$
# *************************
#
# in:	arg1 -> array or string to read
#	arg0 = file number
# out:	nothing
#
# destroys: eax, ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] = number of bytes to read
#
__ReadArray:
__ReadString:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	12(%ebp),%eax	#ebx -> array or string to read
	movl	%eax,%ebx	#
	orl	%eax,%eax	# empty string ?
	jz	readarray_good	# yes
#
	movl	-4(%ebx),%eax
	testl	$0x20000000,%eax	#is array nodal?
	jnz	readarray_nodal
	andl	$0x40FF0000,%eax
	xorl	$0x40130000,%eax	#is it a string array?
	jnz	readarray_not_string	#handle string array same as a node
readarray_nodal:
	movl	-8(%ebx),%ecx		#number of elements
	subl	$16,%esp
readarray_loop:
	movl	%ecx,8(%esp)		#save element counter
	movl	%ebx,12(%esp)		#save array node
	movl	(%ebx),%ebx		#address of subarray or string
	movl	%ebx,4(%esp)
	movl	8(%ebp),%eax
	movl	%eax,(%esp)		#file number
	call	__ReadArray
	movl	12(%esp),%ebx
	movl	8(%esp),%ecx
	addl	$4,%ebx			#increment node
	loop	readarray_loop
	jmp	readarray_good
readarray_not_string:
#
	movzwl	-4(%ebx),%eax	#eax = _ of bytes per element
	movl	-8(%ebx),%ecx	#ecx = _ of elements
	mull	%ecx	#eax = _ of bytes to read
	movl	%eax,-4(%ebp)	#save it where "read" syscall can't get to it
#;
readarray_again:
	subl	$20,%esp	#
	movl	8(%ebp),%eax	#
	movl	%eax,0(%esp)	# fileNumber
	movl	12(%ebp),%eax	#
	movl	%eax,4(%esp)	# bufferAddr
	movl	-4(%ebp),%eax	#
	movl	%eax,8(%esp)	# bufferSize
	leal	12(%esp),%eax	#
	movl	%eax,12(%esp)	# bytesRead
	xorl	%eax,%eax	#
	movl	%eax,16(%esp)	# 0
	call	XxxReadFile_20	#
#	add	esp,20			;
#
#
	orl	%eax,%eax	#was there an error?  (eax < 0 if error)
	jmp	readarray_good	# ntntnt  (add error checking)
	jns	readarray_good	#no: done
#	cmp	[errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	readarray_crash	#no: it was a real error
	cmpl	$0,__SOFTBREAK	#was it a soft break?
	jne	readarray_again	#no: it was just some blowhard signal
#	tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	readarray_again
#
readarray_crash:
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# Return directly from there
#
readarray_good:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *********************
# *****  %_Write  *****  WRITE #n, v
# *********************
#
# in:	arg2 = number of bytes to write
#	arg1 -> bytes to write
#	arg0 = file number
# out:	nothing
#
# destroys: eax, ebx, ecx, edx, esi, edi
#
__Write:
	pushl	%ebp
	movl	%esp,%ebp
#;
write_again:
#	push	[ebp+16]		; old UNIX
#	push	[ebp+12]		; old UNIX
#	push	[ebp+8]			; old UNIX
#	call	write			; old UNIX
#	add	esp,12			; old UNIX
#
	subl	$20,%esp	#
	movl	8(%ebp),%eax	#
	movl	%eax,0(%esp)	# fileNumber
	movl	12(%ebp),%eax	#
	movl	%eax,4(%esp)	# bufferAddr
	movl	16(%ebp),%eax	#
	movl	%eax,8(%esp)	# bufferSize
	leal	12(%esp),%eax	#
	movl	%eax,12(%esp)	# bytesRead
	xorl	%eax,%eax	#
	movl	%eax,16(%esp)	# 0
	call	XxxWriteFile_20	#
#	add	esp,20			;
#
#
	orl	%eax,%eax	#was there an error?  (eax < 0 if error)
	jmp	write_good	# ntntnt  (add error checking)
	jns	write_good	#no: done
#	cmp	[errno],4	;yes: was it EINTR?  i.e. was there a signal?
	jne	write_crash	#no: it was a real error
	cmpl	$0,__SOFTBREAK	#was it a soft break?
	jne	write_again	#no: it was just some blowhard signal
#	tb0	0,r0,509	;SOFTBREAK: LOOSE END
	jmp	write_again
write_crash:
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# Return directly from there
#
write_good:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***************************
# *****  %_WriteArray   *****  WRITE #n, v[]
# *****  %_WriteString  *****  WRITE #n, v$
# ***************************
#
# in:	arg1 -> array or string to write
#	arg0 = file number
# out:	nothing
#
# destroys: eax, ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] = number of bytes to write
#
__WriteArray:
__WriteString:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	12(%ebp),%ebx	#ebx -> array or string to write
#
	orl	%ebx,%ebx	# empty array?	# 20000210
	jz	writearray_good	# yes, ignore	# 20000210
#
	movl	-4(%ebx),%eax
	testl	$0x20000000,%eax	#is array nodal?
	jnz	writearray_nodal
	andl	$0x40FF0000,%eax
	xorl	$0x40130000,%eax	#is it a string array?
	jnz	writearray_not_string	#handle string array same as node
writearray_nodal:
	movl	-8(%ebx),%ecx 		#number of elements
	subl	$16,%esp
writearray_loop:
	movl	%ecx,8(%esp)		#save element counter
	movl	%ebx,12(%esp)		#save array node
	movl	(%ebx),%ebx		#address of subarray or string
	movl	%ebx,4(%esp)
	movl	8(%ebp),%eax
	movl	%eax,(%esp) 		#file number
	call	__WriteArray
	movl	12(%esp),%ebx
	movl	8(%esp),%ecx
	addl	$4,%ebx		#increment node
	loop	writearray_loop
	jmp	writearray_good
writearray_not_string:
#
	movzwl	-4(%ebx),%eax	#eax = _ of bytes per element
	movl	-8(%ebx),%ecx	#ecx = _ of elements
	mull	%ecx		#eax = _ of bytes to write
	movl	%eax,-4(%ebp)	#save it where "write" syscall can't get to it
#
writearray_again:
#	push	[ebp-4]			# old UNIX
#	push	[ebp+12]		# old UNIX
#	push	[ebp+8]			# old UNIX
#	call	write			# old UNIX
#	add	esp,12			# old UNIX
#
	subl	$20,%esp	#
	movl	8(%ebp),%eax	#
	movl	%eax,0(%esp)	# fileNumber
	movl	12(%ebp),%eax	#
	movl	%eax,4(%esp)	# bufferAddr
#	mov	eax, [ebp+16]	# WRONG!!!
	movl	-4(%ebp),%eax	#
	movl	%eax,8(%esp)	# bufferSize
	leal	12(%esp),%eax	#
	movl	%eax,12(%esp)	# bytesRead
	xorl	%eax,%eax	#
	movl	%eax,16(%esp)	# 0
	call	XxxWriteFile_20	#
#	add	esp,20			;
#;
	orl	%eax,%eax	# was there an error?  (eax < 0 if error)
	jmp	writearray_good	# (add error checking)
#
	jns	writearray_good	# no: done
#	cmp	[errno],4		; yes: was it EINTR?  i.e. was there a signal?
	jne	writearray_crash	# no: it was a real error
	cmpl	$0,__SOFTBREAK	# was it a soft break?
	jne	writearray_again	# no: it was just some blowhard signal
#	tb0	0,r0,509		; SOFTBREAK: LOOSE END
	jmp	writearray_again
#
writearray_crash:
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# Return directly from there
#
writearray_good:
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *********************************
# *****  %_string.compare.vv  *****  string comparisons
# *****  %_string.compare.vs  *****
# *****  %_string.compare.sv  *****
# *****  %_string.compare.ss  *****
# *********************************
#
# in:	eax -> string1
#	ebx -> string2
# out:	flags set as if a "cmp *eax,*ebx" instruction had been executed,
#	so that the unsigned conditional jump instructions will make
#       sense if executed immediately upon return from the string
#	comparison routine
#
# destroys: ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string1, if it needs to be freed on exit
#	[ebp-8] -> string2, if it needs to be freed on exit
#	[ebp-12] holds the flags to be returned
#
__string.compare.vv:
	xorl	%esi,%esi	#don't free string1 on exit
	xorl	%edi,%edi	#don't free string2 on exit
	jmp	string.compare.x
#
#
__string.compare.vs:
	xorl	%esi,%esi	#don't free string1 on exit
	movl	%ebx,%edi	#must free string2 on exit
	jmp	string.compare.x
#
#
__string.compare.sv:
	movl	%eax,%esi	#must free string1 on exit
	xorl	%edi,%edi	#don't free string2 on exit
	jmp	string.compare.x
#
#
__string.compare.ss:
	movl	%eax,%esi	#must free string1 on exit
	movl	%ebx,%edi	#must free string2 on exit
#;
#; fall through
#;
string.compare.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%esi,-4(%ebp)	#save ptr to first string to free on exit
	movl	%edi,-8(%ebp)	#save ptr to second string to free on exit
	orl	%eax,%eax	#string1 is a null pointer?
	jz	string1_null	#yes: special processing
	orl	%ebx,%ebx	#string2 is a null pointer?
	jz	string2_null	#yes: special processing
#;
	movl	-8(%eax),%ecx	#ecx = LEN(string1)
	cmpl	-8(%ebx),%ecx	#LEN(string1) > LEN(string2)?
	jb	sc_compare	#no: ecx = LEN(shortest string)
	movl	-8(%ebx),%ecx	#ecx = LEN(string2) = LEN(shortest string)
#;
sc_compare:
	movl	%eax,%esi	#esi -> string1
	movl	%ebx,%edi	#edi -> string2
	rep
	cmpsb		#compare them strings!
	je	sc_compare_lengths	#if equal, longer string is "greater"
#;
sc_done:
	lahf		#result flags to AH
	movl	%eax,-12(%ebp)	#save result flags
	movl	-4(%ebp),%esi	#esi -> first string to free on exit
	call	_____free
	movl	-8(%ebp),%esi	#esi -> second string to free on exit
	call	_____free
#;
	movl	-12(%ebp),%eax	#AH = result flags
	sahf		#put result flags back into flag register
	movl	%ebp,%esp
	popl	%ebp
	ret
#
string1_null:			# string1 is a null pointer
	cmpl	%ebx,%eax	# string2 a null pointer too?
	je	sc_done	# yes
	movl	-8(%ebx),%ebx	# ebx = length of string2
	cmpl	%ebx,%eax	# both empty?
	jmp	sc_done	# comparison tells all
#
string2_null:
	cmpl	%eax,%ebx	# string2 is a null pointer
	je	sc_done	# string1 a null pointer too?
	movl	-8(%eax),%eax	# eax = length of string1
	cmpl	%eax,%ebx	# both empty?
	jmp	sc_done	# comparison tells all
#
sc_compare_lengths:
	movl	-8(%eax),%ecx	#ecx = LEN(string1)
	cmpl	-8(%ebx),%ecx	#compare with LEN(string2),
	jmp	sc_done	# yielding result flags
#
#
# ######################################
# #####  XstFindMemoryMatch_20 ()  #####
# ######################################
#
#
#
# XstFindMemoryMatch (addrBufferStart, addrBufferPast, addrString, minMatch, maxMatch)
#
# input
# arg1   = addr of buffer to search - first byte
# arg2   = addr of buffer to search - byte past end
# arg3   = addr of string to search for - first byte
# arg4   = minimum number of bytes that must match
# arg5   = maximum number of bytes that may match (length of match string)
#
# output
# arg1   = addr of buffer to search - first byte that matched
# arg2   = unchanged
# arg3   = unchanged
# arg4   = # of characters that matched
# arg5   = unchanged
# return = addr of buffer to search - first byte that matched
#
# arg1   = ebp +  8
# arg2   = ebp + 12
# arg3   = ebp + 16
# arg4   = ebp + 20
# arg5   = ebp + 24
#
XstFindMemoryMatch_20:
pushl	%ebp		# standard function entry
movl	%esp,%ebp		# ditto
subl	$16,%esp		# 16 byte frame - local variables
##
pushl	%esi		# save esi
pushl	%edi		# save edi
pushl	%ebx		# save ebx
pushl	%ecx		# save ecx
##
movl	8(%ebp),%edi	# edi = addr of first byte of search buffer
movl	12(%ebp),%edx	# edx = addr of byte past end of search buffer
movl	16(%ebp),%esi	# ebx = addr of 1st byte of match buffer
movl	20(%ebp),%ebx	# esi = minimum # of bytes that must match
movl	24(%ebp),%eax	# eax = maximum # of bytes that may match
##
orl	%edi,%edi		# buffer address = 0 ???
jz	fsnomatch		# start address = 0 is error or empty string
##
orl	%edx,%edx		# past address = 0 ???
jz	fsnomatch		# past address = 0 is an error
##
orl	%esi,%esi		# match buffer address = 0 ???
jz	fsnomatch		# match buffer address = 0 is error or empty
##
orl	%ebx,%ebx		# min # of bytes that must match = 0 ???
jz	fsnomatch		# min # of bytes = 0 is error
##
orl	%eax,%eax		# max # of bytes that can match
jle	fsnomatch		# max # of bytes <= 0 is error
##
movl	%edx,%ecx		# ecx = addr past last byte of buffer to search
subl	%edi,%ecx		# ecx = overall size of buffer to search
jbe	fsnomatch		# search zero or negative number of bytes ???
##
subl	%ebx,%ecx		# ecx = maximum number of bytes to search
jb	fsnomatch		# search through a negative number of bytes ???
incl	%ecx		# ecx = number of bytes to search
## mov	%ecx,-4(%ebp)	# [ebp-4] = save number of bytes to search
##
movzbl	(%esi),%eax	# 1st byte of string to match
##
##
##
## eax = byte to match
## edi = addr of buffer to search
## ecx = how many bytes to search through
## edx = addr of byte past end of buffer to search through
##
xfsloop:
cld			# search forward through memory
repne			# repeat until byte in buffer = byte in eax
scasb			# search for match with byte in eax
##
jne	fsnomatch		# no match to byte in eax
##
pushl	%eax		# save 1st search byte
pushl	%ecx		# save number of bytes left to search through
pushl	%esi		# save addr of 1st byte of match string
pushl	%edi		# save addr of byte after match
##
## found 1st byte of match, now see how many subsequent bytes match
##
decl	%edi		# edi = addr of 1st byte in buffer of match
movl	%edx,%ecx		# ecx = addr of byte past end of search buffer
subl	%edi,%ecx		# ecx = # of bytes in buffer after match byte
##
movl	24(%ebp),%eax	# eax = max # of bytes to match
cmpl	%ecx,%eax		# eax < ecx ???
jae	xfscmp		# no, ecx is okay
movl	%eax,%ecx		# ecx is now okay = max # of bytes to match
##
xfscmp:
xorl	%eax,%eax		# z flag = true = 1
repe			# repeat until bytes don't match
cmpsb			# see how many bytes match (at least 1)
##
jnz	xfsmm		# found mismatch
incl	%esi		# make compatible with mismatch case
incl	%edi		# make compatible with mismatch case
##
xfsmm:
movl	%edi,%eax		# eax = addr of byte past match
subl	(%esp),%eax	# eax = # of bytes that match - 1
## incl	%eax		# eax = # of bytes that match
cmpl	%ebx,%eax		# was # of bytes that matched >= required ???
jae	xfsm		# yes, so we have a match
##
## match was too short - continue search where it left off
##
popl	%edi		# edi = addr of byte after match
popl	%esi		# esi = addr of 1st byte of match string
popl	%ecx		# ecx = # of bytes left to search through
popl	%eax		# eax = byte to search for - 1st byte in match string
jmp	xfsloop		# continue search for long enough match
#
# found a sufficiently long match - eax = match length = return value
#
xfsm:
popl	%edi		# edi = addr of 1st byte of match + 1
decl	%edi		# edi = addr of 1st byte of match
addl	$12,%esp		# remove pushed values esi,ecx,eax from stack
movl	%edi,8(%ebp)	# arg1 = addr of 1st byte of match in buffer
movl	%eax,20(%ebp)	# arg4 = match length
##
## restore registers
##
xfs_done:
popl	%ecx		# restore ecx
popl	%ebx		# restore ebx
popl	%edi		# restore edi
popl	%esi		# restore esi
##
movl	%ebp,%esp		# restore stack pointer
popl	%ebp		# restore frame pointer
ret	$20		# remove 20 bytes of arguments - STDCALL
#
fsnomatch:
xorl	%eax,%eax		# eax = 0 = no match
jmp	xfs_done		#
#
#
#
# ***************************************
# *****  __CompositeStringToString  *****
# ***************************************
#
# The result string is a conventional string.  The length
# of the result string is the length of the composite string
# up to the first 0x00 byte, or the whole composite string
# if it contains no 0x00 byte.
#
# edi = length in bytes
# esi = source address
#
__CompositeStringToString:
pushl	%eax
pushl	%edx
pushl	%ebx
pushl	%ecx
pushl	%edi		# save composite string length
pushl	%esi		# save address of composite string
movl	%edi,%edx	# edx = length of composite string
movl	%edi,%ecx	# ecx = length of composite string
movl	%esi,%edi	# edi = addr of composite string
##
xorl	%eax,%eax	# eax = 0 = byte to search for
cld			# search forward
repne			# repeat while not equal
scasb			# find 0x00 byte in composite string
##
movl	%edx,%esi	# esi = length of composite string
jnz	nozmatch	# no 0x00 byte in composite string
decl	%edi		# edi = address of 0x00 byte
subl	(%esp),%edi	# edi = addr of 0x00 - addr of composite string
movl	%edi,%esi	# esi = length of composite string before 0x00
jz	ccsempty	# return empty string
##
nozmatch:
pushl	%esi		# save length of string
incl	%esi		# make room for 0x00 terminator
call	_____calloc	# allocate space for result string
##
movl	$0x80130001,%eax	# word3 of header for strings
movl	%eax,-4(%esi)	# word3 of header = 1 byte string
##
popl	%ecx		# ecx = length of string
movl	%ecx,-8(%esi)	# word2 of header = # of bytes in string
##
movl	%esi,%edi	# edi = address of destination string
popl	%esi		# esi = address of composite string
pushl	%edi		# save address of destination string
##
cld			# forward move
rep			# repeat/move ecx bytes
movsb			# move composite string to destination string
##
ccsdone:
popl	%esi		# esi = address of destination string
popl	%edi		# edi = entry edi
popl	%ecx		# ecx = entry ecx
popl	%ebx		# ebx = entry ebx
popl	%edx		# edx = entry edx
popl	%eax		# eax = entry eax
ret			#
#
ccsempty:
popl	%esi		# esi = address of composite string (useless)
popl	%edi		# edi = entry edi
popl	%ecx		# ecx = entry ecx
popl	%ebx		# ebx = entry ebx
popl	%edx		# edx = entry edx
popl	%eax		# eax = entry eax
xorl	%esi,%esi	# esi = result = 0x00000000 = empty string
ret			#
#
#
#
# edi = length in bytes
# esi = source address
#
__ByteMakeCopy:
	pushl	%eax
	pushl	%edx
	pushl	%ebx
	pushl	%ecx
	pushl	%edi
	pushl	%esi
	movl	%edi,%esi
	incl	%esi
	call	_____calloc
#
	movl	-8(%esi),%eax
	decl	%eax
	movl	%eax,-8(%esi)
#
	movl	%esi,%edi
	popl	%esi
	popl	%ecx
	pushl	%edi
	cld
	rep
	movsb
	popl	%esi
	popl	%ecx
	popl	%ebx
	popl	%edx
	popl	%eax
	ret
#
#
# *****************************************
# *****  Miscellaneous I/O Functions  *****
# *****************************************
#
# in:	arguments are on the stack
# out:	result is in eax
#
# destroys: ebx, ecx, edx, esi, edi
#
# Each I/O function calls an XBASIC function in xst.x to do the
# real work.  Some functions have two entry points, one for a
# string parameter on the stack and one for a string parameter
# in a variable.
#
#
# ***********************************************************************
# *****  NOTE:  Can't push more than one argument in the following  *****
# *****         routines because the stack is altered by the first  *****
# ***********************************************************************
#
__close:
	pushl	4(%esp)	#
	call	XxxClose_4	#
	ret		#
#
#
__eof:
	pushl	4(%esp)	#
	call	XxxEof_4	#
	ret		#
#
#
__lof:
	pushl	4(%esp)	#
	call	XxxLof_4	#
	ret		#
#
#
__pof:
	pushl	4(%esp)	#
	call	XxxPof_4	#
	ret		#
#
#
__quit:
	pushl	4(%esp)	#
	call	XxxQuit_4	#
	ret		#
#
#
__infile_d:
	pushl	4(%esp)	#
	call	XxxInfile$_4	#
	ret		#
#
#
__inline_d.s:
	pushl	4(%esp)	# push &prompt$
	call	XxxInline$_4	#
	movl	4(%esp),%esi	#
	jmp	_____free	#
#
#
__inline_d.v:
	pushl	4(%esp)	# push &prompt$
	call	XxxInline$_4	#
	ret		#
#
#
__open.s:
	movl	4(%esp),%eax	# eax -> filename$
	movl	8(%esp),%ebx	# ebx == open mode
	pushl	%ebx	# push open mode
	pushl	%eax	# push &filename$
	call	XxxOpen_8	#
	movl	4(%esp),%esi	#
	jmp	_____free	#
#
#
__open.v:
	movl	4(%esp),%eax	# eax -> filename$
	movl	8(%esp),%ebx	# ebx == open mode
	pushl	%ebx	#
	pushl	%eax	#
	call	XxxOpen_8	#
	ret		#
#
#
__seek:
	movl	4(%esp),%eax	# eax == file number
	movl	8(%esp),%ebx	# ebx == file position
	pushl	%ebx	#
	pushl	%eax	#
	call	XxxSeek_8	#
	ret		#
#
#
__shell.s:
	pushl	4(%esp)	#
	call	XxxShell_4	#
	movl	4(%esp),%esi	#
	jmp	_____free	#
#
#
__shell.v:
	pushl	4(%esp)	#
	call	XxxShell_4	#
	ret		#
#
#
# ##################
# #####  DATA  #####  xlibs.s
# ##################
#
#
#
.align	8
.long	0x20,	0x0,	0x1,	0x80130001
__space.string:
.byte	' '
.zero	15
#
.align	8
.long	0x20,	0x0,	0x1,	0x80130001
__newline.string:
.byte	'\n'
.zero	15
#
.align	8
.long	0x20,	0x0,	0x0E,	0x80130001
implementation:
.string	"unix elf linux"
.zero	2
#
#
#
.text
#
# ######################
# #####  xlibnn.s  #####  numeric-to-numeric conversions and intrinsics
# ######################
#
# *********************************
# *****  %_cv.slong.to.sbyte  *****
# *****  %_cv.ulong.to.sbyte  *****
# *****  %_cv.xlong.to.sbyte  *****
# *********************************
#
# in:	arg0 = xlong
# out:	eax = equivalent sbyte
#
# destroys: nothing
#
__cv.slong.to.sbyte:
__cv.ulong.to.sbyte:
__cv.xlong.to.sbyte:
	movsbl	4(%esp),%eax	#eax = converted sbyte
	cmpl	4(%esp),%eax	#any of those high-order bits changed?
	je	ret1	#no: sign-extension occurred w/o change of data
	jmp	__eeeOverflow	# Return from there
ret1:
	ret
#
# *********************************
# *****  %_cv.slong.to.ubyte  *****
# *****  %_cv.ulong.to.ubyte  *****
# *****  %_cv.xlong.to.ubyte  *****
# *********************************
#
# in:	arg0 = xlong
# out:	eax = equivalent ubyte
#
# destroys: nothing
#
__cv.slong.to.ubyte:
__cv.ulong.to.ubyte:
__cv.xlong.to.ubyte:
	movzbl	4(%esp),%eax	#eax = converted ubyte
	cmpl	4(%esp),%eax	#any high-order bits changed?
	je	ret2	#no: conversion occurred w/o loss of data
	jmp	__eeeOverflow	# Return from there
ret2:
	ret
#
# **********************************
# *****  %_cv.slong.to.sshort  *****
# *****  %_cv.ulong.to.sshort  *****
# *****  %_cv.xlong.to.sshort  *****
# **********************************
#
# in:	arg0 = xlong
# out:	eax = equivalent sshort
#
# destroys: nothing
#
__cv.slong.to.sshort:
__cv.ulong.to.sshort:
__cv.xlong.to.sshort:
	movswl	4(%esp),%eax	#eax = converted sshort
	cmpl	4(%esp),%eax	#any high-order bits changed?
	je	ret3	#no: conversion occurred w/o loss of data
	jmp	__eeeOverflow	# Return from there
ret3:
	ret
#
# **********************************
# *****  %_cv.slong.to.ushort  *****
# *****  %_cv.ulong.to.ushort  *****
# *****  %_cv.xlong.to.ushort  *****
# **********************************
#
# in:	arg0 = xlong
# out:	eax = equivalent ushort
#
# destroys: nothing
#
__cv.slong.to.ushort:
__cv.ulong.to.ushort:
__cv.xlong.to.ushort:
	movzwl	4(%esp),%eax	#eax = converted ushort
	cmpl	4(%esp),%eax	#any high-order bits changed?
	je	ret4	#no: conversion occurred w/o loss of data
	jmp	__eeeOverflow	# Return from there
ret4:
	ret
#
#
# *********************************
# *****  %_cv.slong.to.slong  *****
# *****  %_cv.slong.to.ulong  *****
# *****  %_cv.slong.to.xlong  *****
# *****  %_cv.slong.to.subaddr  ***
# *****  %_cv.slong.to.goaddr  ****
# *****  %_cv.slong.to.funcaddr  **
# *****  %_cv.ulong.to.slong  *****
# *****  %_cv.ulong.to.ulong  *****
# *****  %_cv.ulong.to.xlong  *****
# *****  %_cv.ulong.to.subaddr  ***
# *****  %_cv.ulong.to.goaddr  ****
# *****  %_cv.ulong.to.funcaddr  **
# *****  %_cv.xlong.to.slong  *****
# *****  %_cv.xlong.to.ulong  *****
# *****  %_cv.xlong.to.xlong  *****
# *****  %_cv.xlong.to.subaddr  ***
# *****  %_cv.xlong.to.goaddr  ****
# *****  %_cv.xlong.to.funcaddr  **
# *********************************
#
# in:	arg0 = xlong
# out:	eax = converted value, which is always the same as arg0
#
# destroys: nothing
#
__cv.slong.to.slong:
__cv.slong.to.ulong:
__cv.slong.to.xlong:
__cv.slong.to.subaddr:
__cv.slong.to.goaddr:
__cv.slong.to.funcaddr:
__cv.ulong.to.slong:
__cv.ulong.to.ulong:
__cv.ulong.to.xlong:
__cv.ulong.to.subaddr:
__cv.ulong.to.goaddr:
__cv.ulong.to.funcaddr:
__cv.xlong.to.slong:
__cv.xlong.to.ulong:
__cv.xlong.to.xlong:
__cv.xlong.to.subaddr:
__cv.xlong.to.goaddr:
__cv.xlong.to.funcaddr:
	movl	4(%esp),%eax
	ret
#
# *********************************
# *****  %_cv.slong.to.giant  *****
# *****  %_cv.xlong.to.giant  *****
# *********************************
#
# in:	arg0 = xlong
# out:	edx:eax = equivalent giant
#
# destroys: nothing
#
__cv.slong.to.giant:
__cv.xlong.to.giant:
	movl	4(%esp),%eax
	cdq
	ret
#
# *********************************
# *****  %_cv.ulong.to.giant  *****
# *********************************
#
# in:	arg0 = ulong
# out:	edx:eax = equivalent giant
#
# destroys: nothing
#
__cv.ulong.to.giant:
	movl	4(%esp),%eax
	xor	%edx,%edx
	ret
#
# **********************************
# *****  %_cv.slong.to.single  *****
# *****  %_cv.slong.to.double  *****
# *****  %_cv.xlong.to.single  *****
# *****  %_cv.xlong.to.double  *****
# **********************************
#
# in:	arg0 = xlong
# out:	st(0) = equivalent floating-point number
#
# destroys: nothing
#
__cv.slong.to.single:
__cv.xlong.to.single:
__cv.slong.to.double:
__cv.xlong.to.double:
	fildl	4(%esp)
	ret
#
# **********************************
# *****  %_cv.ulong.to.single  *****  xxxxxxxxxx
# *****  %_cv.ulong.to.double  *****
# **********************************
#
# in:	arg0 = ulong
# out:	st(0) = equivalent floating-point number
#
# destroys: nothing
#
__cv.ulong.to.single:
__cv.ulong.to.double:
	pushl	$0		# push  0
	pushl	8(%esp)		# push  [esp+8]
	fildll	0(%esp)		# fild  qword ptr [esp]
	addl	$8,%esp		# add   esp,8
	ret			# ret
#
# *********************************
# *****  %_cv.giant.to.sbyte  *****
# *********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	eax = equivalent sbyte
#
# destroys: edx
#
__cv.giant.to.sbyte:
	movsbl	4(%esp),%eax	#eax = converted lower eight bits
	cmpl	4(%esp),%eax	#no change in remaining bits of lsdword?
	jne	bad1	#there was a change: blow up
	cdq		#sign-extend result into edx
	cmpl	8(%esp),%edx	#no change in bits of msdword
	jne	bad1	#there was a change: blow up
	ret
#
bad1:
#	xor	eax,eax		;return a zero (is this a good idea?)
	jmp	__eeeOverflow	# Return from there
#
#
# *********************************
# *****  %_cv.giant.to.ubyte  *****
# *********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	eax = equivalent ubyte
#
# destroys: nothing
#
__cv.giant.to.ubyte:
	cmpl	$0,8(%esp)	#high 32 better be all zero
	jne	bad1	#nope: blow up
	movzbl	4(%esp),%eax	#extract lowest eight bits from low 32
	cmpl	4(%esp),%eax	#remaining bits changed?
	jne	bad1	#yes: data was lost in conversion
	ret
#
# **********************************
# *****  %_cv.giant.to.sshort  *****
# **********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	eax = equivalent sshort
#
# destroys: edx
#
__cv.giant.to.sshort:
	movswl	4(%esp),%eax	#sign-extend lowest 16 bits of low 32
	cmpl	4(%esp),%eax	#any of the remaining bits changed?
	jne	bad1	#yes: data was lost in conversion
	cdq		#sign-extend result into edx
	cmpl	8(%esp),%edx	#any bits changed in high 32?
	jne	bad1	#yes: data was lost in conversion
	ret
#
# **********************************
# *****  %_cv.giant.to.ushort  *****
# **********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	eax = equivalent ushort
#
# destroys: nothing
#
__cv.giant.to.ushort:
	cmpl	$0,8(%esp)	#high 32 bits had better be zero
	jne	bad1	#nope: impossible to convert
	movzwl	4(%esp),%eax	#extract lowest 8 bits of low 32
	cmpl	4(%esp),%eax	#any of the remaining bits changed?
	jne	bad1	#yes: data was lost in conversion
	ret
#
# *********************************
# *****  %_cv.giant.to.slong  *****
# *****  %_cv.giant.to.xlong  *****
# *********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	eax = equivalent slong or xlong
#
# destroys: edx
#
__cv.giant.to.slong:
__cv.giant.to.xlong:
	movl	4(%esp),%eax	#get low 32 bits
	cdq		#sign-extend result into edx
	cmpl	8(%esp),%edx	#high 32 bits the same?
	jne	bad1	#no: data was lost in conversion
	ret
#
# *********************************
# *****  %_cv.giant.to.ulong  *****
# *********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	eax = equivalent ulong
#
# destroys: nothing
#
__cv.giant.to.ulong:
	cmpl	$0,8(%esp)	#high 32 bits better all be zero
	jne	bad1	#nope: impossible to convert
	movl	4(%esp),%eax	#result is low 32 bits of giant
	ret
#
# *********************************
# *****  %_cv.giant.to.giant  *****
# *********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	edx:eax = arg1:arg0
#
# destroys: nothing
#
__cv.giant.to.giant:
	movl	4(%esp),%eax	#eax = low 32 bits of giant
	movl	8(%esp),%edx	#edx = high 32 bits of giant
	ret
#
#
# **********************************
# *****  %_cv.giant.to.single  *****
# *****  %_cv.giant.to.double  *****
# **********************************
#
# in:	arg1 = high 32 bits of giant
#	arg0 = low 32 bits of giant
# out:	st(0) = equivalent floating-point number
#
# destroys: nothing
#
__cv.giant.to.single:
__cv.giant.to.double:
	fildll	4(%esp)
	ret
#
#
# **********************************
# *****  %_cv.single.to.sbyte  *****
# **********************************
#
# in:	arg0 = single
# out:	eax = equivalent sbyte
#
# destroys: esi
#
__cv.single.to.sbyte:
	flds	4(%esp)	#st(0) = input single
	movl	$workdword,%esi	#shorten next three instructions
	fistpl	(%esi)	#convert input single to an integer
	fwait
	movsbl	(%esi),%eax	#sign-extend low eight bits
	cmpl	(%esi),%eax	#any of the other bits changed?
	jne	bad2	#yes: data was lost in conversion
	ret
bad2:
#	xor	eax,eax		;return a zero (is this a good idea?)
	jmp	__eeeOverflow	# Return from there
#
#
# **********************************
# *****  %_cv.single.to.ubyte  *****
# **********************************
#
# in:	arg0 = single
# out:	eax = equivalent ubyte
#
# destroys: esi
#
__cv.single.to.ubyte:
	flds	4(%esp)	#st(0) = input single
	movl	$workdword,%esi
	fistpl	(%esi)	#convert input single to integer
	fwait
	movzbl	(%esi),%eax	#extract lowest 8 bits
	cmpl	(%esi),%eax	#no change in other bits?
	jne	bad2	#other bits changed: error
	ret
#
#
# ***********************************
# *****  %_cv.single.to.sshort  *****
# ***********************************
#
# in:	arg0 = single
# out:	eax = equivalent sshort
#
# destroys: esi
#
__cv.single.to.sshort:
	flds	4(%esp)	#st(0) = input single
	movl	$workdword,%esi	#shorten next three instructions
	fistpl	(%esi)	#convert input single to an integer
	fwait
	movswl	(%esi),%eax	#sign-extend low 16 bits
	cmpl	(%esi),%eax	#any of the other bits changed?
	jne	bad2	#yes: data was lost in conversion
	ret
#
#
# ***********************************
# *****  %_cv.single.to.ushort  *****
# ***********************************
#
# in:	arg0 = single
# out:	eax = equivalent ushort
#
# destroys: esi
#
__cv.single.to.ushort:
	flds	4(%esp)	#st(0) = input single
	movl	$workdword,%esi
	fistpl	(%esi)	#convert input single to integer
	fwait
	movzwl	(%esi),%eax	#extract lowest 16 bits
	cmpl	(%esi),%eax	#no change in other bits?
	jne	bad2	#other bits changed: error
	ret
#
#
# **********************************
# *****  %_cv.single.to.slong  *****
# *****  %_cv.single.to.xlong  *****
# **********************************
#
# in:	arg0 = single
# out:	eax = equivalent slong or xlong
#
# destroys: nothing
#
__cv.single.to.slong:
__cv.single.to.xlong:
	flds	4(%esp)	#st(0) = input single
	fistpl	workdword	#convert it to integer
	fwait
	movl	workdword,%eax
	ret		#no overflow possible (?)
#
#
# **********************************
# *****  %_cv.single.to.ulong  *****
# **********************************
#
# in:	arg0 = single
# out:	eax = equivalent ulong
#
# destroys: esi
#
__cv.single.to.ulong:
	flds	4(%esp)	#st(0) = input single
	movl	$workdword,%esi
	fistpl	(%esi)	#convert it to integer
	fwait
	movl	(%esi),%eax
	orl	%eax,%eax	#it's not negative, is it?
	js	bad2	#'fraid so
	ret
#
#
# **********************************
# *****  %_cv.single.to.giant  *****
# **********************************
#
# in:	arg0 = single
# out:	edx:eax = equivalent giant
#
# destroys: nothing
#
__cv.single.to.giant:
	flds	4(%esp)	#st(0) = input single
	fistpll	workqword	#convert it to integer
	fwait
	movl	workqword,%eax	#eax = low 32 bits of result
	movl	workqword+4,%edx	#edx = high 32 bits of result
	ret
#
# ***********************************
# *****  %_cv.single.to.single  *****
# *****  %_cv.single.to.double  *****
# ***********************************
#
# in:	arg0 = single
# out:	st(0) = equivalent floating-point number
#
# destroys: nothing
#
__cv.single.to.single:
__cv.single.to.double:
	flds	4(%esp)	#st(0) = input single
	ret
#
#
# **********************************
# *****  %_cv.double.to.sbyte  *****
# **********************************
#
# in:	arg1:arg0 = double
# out:	eax = equivalent sbyte
#
# destroys: esi
#
__cv.double.to.sbyte:
	fldl	4(%esp)	#st(0) = input double
	movl	$workdword,%esi	#shorten next three instructions
	fistpl	(%esi)	#convert input double to an integer
	fwait
	movsbl	(%esi),%eax	#sign-extend low eight bits
	cmpl	(%esi),%eax	#any of the other bits changed?
	jne	bad3	#yes: data was lost in conversion
	ret
bad3:
#	xor	eax,eax		;return zero (is this a good idea?)
	jmp	__eeeOverflow	# Return from there
#
#
# **********************************
# *****  %_cv.double.to.ubyte  *****
# **********************************
#
# in:	arg1:arg0 = double
# out:	eax = equivalent ubyte
#
# destroys: esi
#
__cv.double.to.ubyte:
	fldl	4(%esp)	#st(0) = input double
	movl	$workdword,%esi
	fistpl	(%esi)	#convert input double to integer
	fwait
	movzbl	(%esi),%eax	#extract lowest 8 bits
	cmpl	(%esi),%eax	#no change in other bits?
	jne	bad3	#other bits changed: error
	ret
#
#
# ***********************************
# *****  %_cv.double.to.sshort  *****
# ***********************************
#
# in:	arg1:arg0 = double
# out:	eax = equivalent sshort
#
# destroys: esi
#
__cv.double.to.sshort:
	fldl	4(%esp)	#st(0) = input double
	movl	$workdword,%esi	#shorten next three instructions
	fistpl	(%esi)	#convert input double to an integer
	fwait
	movswl	(%esi),%eax	#sign-extend low 16 bits
	cmpl	(%esi),%eax	#any of the other bits changed?
	jne	bad3	#yes: data was lost in conversion
	ret
#
#
# ***********************************
# *****  %_cv.double.to.ushort  *****
# ***********************************
#
# in:	arg1:arg0 = double
# out:	eax = equivalent ushort
#
# destroys: esi
#
__cv.double.to.ushort:
	fldl	4(%esp)	#st(0) = input double
	movl	$workdword,%esi
	fistpl	(%esi)	#convert input double to integer
	fwait
	movzwl	(%esi),%eax	#extract lowest 16 bits
	cmpl	(%esi),%eax	#no change in other bits?
	jne	bad3	#other bits changed: error
	ret
#
#
# **********************************
# *****  %_cv.double.to.slong  *****
# *****  %_cv.double.to.xlong  *****
# **********************************
#
# in:	arg1:arg0 = double
# out:	eax = equivalent slong or xlong
#
# destroys: nothing
#
__cv.double.to.slong:
__cv.double.to.xlong:
	fldl	4(%esp)	#st(0) = input double
	fistpl	workdword	#convert it to integer
	fwait
	movl	workdword,%eax
	ret		#no overflow possible (?)
#
#
# **********************************
# *****  %_cv.double.to.ulong  *****
# **********************************
#
# in:	arg1:arg0 = double
# out:	eax = equivalent ulong
#
# destroys: esi
#
__cv.double.to.ulong:
	fldl	4(%esp)	#st(0) = input double
	movl	$workdword,%esi
	fistpl	(%esi)	#convert it to integer
	fwait
	movl	(%esi),%eax
	orl	%eax,%eax	#it's not negative, is it?
	js	bad3	#'fraid so
	ret
#
#
# **********************************
# *****  %_cv.double.to.giant  *****
# **********************************
#
# in:	arg1:arg0 = double
# out:	edx:eax = equivalent giant
#
# destroys: nothing
#
__cv.double.to.giant:
	fldl	4(%esp)	#st(0) = input double
	fistpll	workqword	#convert it to integer
	fwait
	movl	workqword,%eax	#eax = low 32 bits of result
	movl	workqword+4,%edx	#edx = high 32 bits of result
	ret
#
#
# ***********************************
# *****  %_cv.double.to.single  *****
# *****  %_cv.double.to.double  *****
# ***********************************
#
# in:	arg1:arg0 = double
# out:	st(0) = equivalent floating-point number
#
# destroys: nothing
#
__cv.double.to.single:
__cv.double.to.double:
	fldl	4(%esp)	#st(0) = input double
	ret
#
#
#
# *************************
# *****  %_add.GIANT  *****
# *************************
#
# in:	arg3:arg2 = right operand
#	arg1:arg0 = left operand
# out:	edx:eax = result
#
# destroys: nothing
#
__add.GIANT:
	movl	4(%esp),%eax
	movl	8(%esp),%edx
	addl	12(%esp),%eax
	adcl	16(%esp),%edx
	into
	ret
#
# *************************
# *****  %_sub.GIANT  *****
# *************************
#
# in:	arg3:arg2 = right operand
#	arg1:arg0 = left operand
# out:	edx:eax = result
#
# destroys: nothing
#
__sub.GIANT:
	movl	4(%esp),%eax
	movl	8(%esp),%edx
	subl	12(%esp),%eax
	sbbl	16(%esp),%edx
	into
	ret
#
#
# *************************
# *****  %_mul.GIANT  *****
# *************************
#
# in:	edx:eax = left operand
#	ecx:ebx = right operand
# out:	edx:eax = result
#
# destroys: nothing
#
# local variables:
#	[ebp-4]:[ebp-8] = left operand, result
#	[ebp-12]:[ebp-16] = right operand
#	[ebp-18] = saved FPU control word
#	[ebp-20] = new FPU control word
#
__mul.GIANT:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$20,%esp
	movl	%eax,-8(%ebp)	#put operands in memory so coprocessor
	movl	%edx,-4(%ebp)	# can access them
	movl	%ebx,-16(%ebp)
	movl	%ecx,-12(%ebp)

	# Save FPU control word
	fstcw	-18(%ebp)

	# Set FPU precision to 64 bits
	fstcw	-20(%ebp)
	orw	$0x0300, -20(%ebp)
	fldcw	-20(%ebp)

	fildll	-8(%ebp)
	fildll	-16(%ebp)
	fmulp
	fistpll	-8(%ebp)
	
	# Restore FPU control word
	fldcw	-18(%ebp)

	fwait
	movl	-8(%ebp),%eax
	movl	-4(%ebp),%edx
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_div.GIANT  *****
# *************************
#
# in:	edx:eax = left operand
#	ecx:ebx = right operand
# out:	edx:eax = result
#
# destroys: ebx
#
# local variables:
#	[ebp-4]:[ebp-8] = left operand, result
#	[ebp-12]:[ebp-16] = right operand
#	[ebp-20] = coprocessor control word set for truncation
#	[ebp-24] = on-entry control word
#
__div.GIANT:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$24,%esp
	movl	%eax,-8(%ebp)	#put operands in memory so coprocessor
	movl	%edx,-4(%ebp)	# can access them
	movl	%ebx,-16(%ebp)
	movl	%ecx,-12(%ebp)

	# Save FPU control word
	fstcw	-24(%ebp)

	# Set FPU precision to 64 bits
	# Set FPU rounding to truncate
	fstcw	-20(%ebp)
	orw	$0x0F00, -20(%ebp)
	fldcw	-20(%ebp)

	fildll	-8(%ebp)
	fildll	-16(%ebp)
	fwait
	fdivrp

	fistpll	-8(%ebp)
	fwait
	movl	-8(%ebp),%eax
	movl	-4(%ebp),%edx
	fldcw	-24(%ebp)	#back to old rounding mode
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_mod.GIANT  *****
# *************************
#
# in:	edx:eax = left operand
#	ecx:ebx = right operand
# out:	edx:eax = result
#
# destroys: ebx
#
# local variables:
#	[ebp-4]:[ebp-8] = left operand, result
#	[ebp-12]:[ebp-16] = right operand
#	[ebp-20] = coprocessor control word set for truncation
#	[ebp-24] = on-entry control word
#
__mod.GIANT:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$24,%esp
	movl	%eax,-8(%ebp)	# put operands in memory so coprocessor
	movl	%edx,-4(%ebp)	# can access them
	movl	%ebx,-16(%ebp)
	movl	%ecx,-12(%ebp)

	# Save FPU control word
	fstcw	-24(%ebp)

	# Set FPU precision to 64 bits
	# Set FPU rounding to truncate
	fstcw	-20(%ebp)
	orw	$0x0F00, -20(%ebp)
	fldcw	-20(%ebp)

	fildll	-8(%ebp)	#  l
	fabs
	fildll	-16(%ebp)	#  r            l
	fabs
	fld	%st(0)		#  r            r            l
	fwait
	fdivr	%st(2),%st	#  l/r          r            l

	frndint			#int(l/r)       r            l
	fmulp			#b*int(r/l)     l
	fsubrp			#l-(b*int(r/l))
	cmpl	$0,-4(%ebp)	#numerator less than zero?
	jnl	mod_giant_skip	#no
	fchs			#yes: make remainder negative
mod_giant_skip:
	fistpll	-8(%ebp)
	fwait
	movl	-8(%ebp),%eax
	movl	-4(%ebp),%edx
	fldcw	-24(%ebp)	#back to old rounding mode
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ****************************
# *****  %_lshift.giant  *****  logical left shift giant
# *****  %_ushift.giant  *****  arithmetic left shift giant
# ****************************
#
# in:	edx:eax = source operand
#	ecx = number of bits to shift
# out:	edx:eax = result
#
# destroys: nothing
#
__lshift.giant:			#left logical and arithmetic shifts are the same
__ushift.giant:
	cmpl	$0,%ecx	#shifting zero or fewer bits?
	jle	shift_ret	#yes: result = input
	cmpl	$64,%ecx	#shifting 64 or more bits?
	jge	shift_ret	#yes: result = input
	cmpb	$32,%cl
	je	glshift32	#shifting exactly 32 bits
	ja	glshift33	#shifting more than 32 bits
	shldl	%cl,%eax,%edx
	shll	%cl,%eax
	ret
glshift32:			#shift left exactly 32 bits
	movl	%eax,%edx	#copy least significant half to most signif.
	xorl	%eax,%eax	#clear least significant half
	ret
glshift33:			#shift left more than 32 bits
	movl	%eax,%edx	#copy least significant half to most signif.
	xorl	%eax,%eax	#clear least significant half
	shll	%cl,%edx	#shift (cl - 32) bits
shift_ret:
	ret
#
#
# ****************************
# *****  %_rshift.giant  *****  logical right shift giant
# ****************************
#
# in:	edx:eax = source operand
#	ecx = number of bits to shift
# out:	edx:eax = result
#
# destroys: nothing
#
__rshift.giant:
	cmpl	$0,%ecx	#shifting zero or fewer bits?
	jle	shift_ret	#yes: result = input
	cmpl	$64,%ecx	#shifting 64 or more bits?
	jge	shift_ret	#yes: result = input
	cmpb	$32,%cl
	je	grshift32	#shifting exactly 32 bits
	ja	grshift33	#shifting more than 32 bits
	shrdl	%cl,%edx,%eax
	shrl	%cl,%edx
	ret
grshift32:			#shift right exactly 32 bits
	movl	%edx,%eax	#copy most significant half to least signif.
	xorl	%edx,%edx	#clear most significant half
	ret
grshift33:			#shift right more than 32 bits
	movl	%edx,%eax	#copy most significant half to least signif.
	xorl	%edx,%edx	#clear most significant half
	shrl	%cl,%eax	#shift (cl - 32) bits
	ret
#
#
# ****************************
# *****  %_dshift.giant  *****  arithmetic right shift giant
# ****************************
#
# in:	edx:eax = source operand
#	ecx = number of bits to shift
# out:	edx:eax = result
#
# destroys: nothing
#
__dshift.giant:
	cmpl	$0,%ecx	#shifting zero or fewer bits?
	jle	shift_ret	#yes: result = input
	cmpl	$64,%ecx	#shifting 64 or more bits?
	jge	shift_ret	#yes: result = input
	cmpb	$32,%cl
	je	gdshift32	#shifting exactly 32 bits
	ja	gdshift33	#shifting more than 32 bits
	shrdl	%cl,%edx,%eax
	sarl	%cl,%edx
	ret
gdshift32:			#shifting exactly 32 bits
	movl	%edx,%eax	#copy most significant half to least signif.
	sarl	$31,%edx	#copy sign bit all over most significant half
	ret
gdshift33:			#shifting more than 32 bits
	movl	%edx,%eax	#copy most significant half to least signif.
	sarl	$31,%edx	#copy sign bit all over most significant half
	sarl	%cl,%eax	#shift right (cl - 32) bits
	ret
#
#
# *******************
# *****  high0  *****
# *****  high1  *****
# *******************
#
__high0:
	notl	%eax	# flip bits, then do high1
#;
__high1:
	movl	$32,%ecx	# ecx = 32 = bit tested
#;
highloop:
	decl	%ecx	# ecx = bit to test
	js	highdone	# ecx = -1 means all bits tested
	shll	$1,%eax	# shift msb into C flag
	jnc	highloop	# if C flag = 0, keep looking
#;
highdone:
	movl	%ecx,%eax	# eax = bit _ of high 0 or high 1 bit
	ret
#
#
# *************************
# *****  high0.giant  *****  eax = LS32
# *****  high1.giant  *****  edx = MS32
# *************************
#
__high0.giant:
	notl	%eax	# flip LS bits, then do high1
	notl	%edx	# flip MS bits, then do high1
#;
__high1.giant:
	movl	$64,%ecx	# ecx = 64 = bit tested
#;
highgiantloop:
	decl	%ecx	# ecx = bit to test
	js	highgiantdone	# ecx = -1 means all bits tested
	shll	$1,%edx	# edx = MS << 1
	jc	highgiantdone	# found 1 bit
	shll	$1,%eax	# eax = LS << 1
	jnc	highgiantloop	# eax MSb was 0 - continue loop
	orl	$1,%edx	# carry bit from LS to MS
	jmp	highgiantloop	#
#;
highgiantdone:
	movl	%ecx,%eax	# eax = bit _ of high 0 or high 1 bit
	ret
#
#
#
# *************************
# *****  %_abs.slong  *****  ABS(x)
# *****  %_abs.xlong  *****
# *************************
#
# in:	arg0 = source number
# out:	eax = absolute value of source number
#
# destroys: nothing
#
# Generates overflow trap if source number is 0x80000000.
#
__abs.slong:
__abs.xlong:
	movl	4(%esp),%eax	#eax = source number
	orl	%eax,%eax	#less than zero?
	jns	abs_ret	#no: it's already its own absolute value
	cmpl	$0x80000000,%eax	#cannot represent as positive signed number?
	je	gen_overflow	#cannot: so generate an overflow
	negl	%eax	#eax = ABS(source number)
abs_ret:
	ret
gen_overflow:
#	xor	eax,eax		;return zero
	jmp	__eeeOverflow	# Return from there
#
#
# *************************
# *****  %_abs.ulong  *****  ABS(x)
# *************************
#
# in:	arg0 = source number
# out:	eax = source number
#
# destroys: nothing
#
__abs.ulong:
	movl	4(%esp),%eax
	ret
#
#
# *************************
# *****  %_abs.giant  *****  ABS(giant)
# *************************
#
# in:	arg1:arg0 = source number
# out:	edx:eax = absolute value of source number
#
# destroys: nothing
#
# Generates an overflow trap if source number is 0x8000000000000000.
#
__abs.giant:
	movl	8(%esp),%edx	#edx = ms half of source number
	movl	4(%esp),%eax	#eax = ls half of source number
	orl	%edx,%edx	#greater than or equal to zero?
	jns	gabs_ret	#yes: source number is its own absolute value
	cmpl	$0x80000000,%edx	#make sure |edx:eax| can be represented as
	jne	gabs_negate	# a signed 64-bit positive number
	orl	%eax,%eax
	jz	gen_overflow
gabs_negate:
	notl	%edx	#negate edx:eax
	negl	%eax
	sbbl	$-1,%edx
gabs_ret:
	ret
#
#
# **************************
# *****  %_abs.single  *****  ABS(single)
# **************************
#
# in:	arg0 = source number
# out:	st(0) = absolute value of source number
#
# destroys: nothing
#
__abs.single:
	flds	4(%esp)
	fabs
	ret
#
#
# **************************
# *****  %_abs.double  *****  ABS(double)
# **************************
#
# in:	arg1:arg0 = source number
# out:	st(0) = absolute value of source number
#
# destroys: nothing
#
__abs.double:
	fldl	4(%esp)
	fabs
	ret
#
#
# **************************
# *****  %_int.single  *****  INT(single)
# **************************
#
# in:	arg0 = source number
# out:	st(0) = INT(source number) = largest integer less than or equal
#				     to source number
#
# destroys: ebx
#
__int.single:
	flds	4(%esp)
	jmp	int.x
#
#
# **************************
# *****  %_int.double  *****  INT(double)
# **************************
#
# in:	arg1:arg0 = source number
# out:	st(0) = INT(source number) = largest integer less than or equal
#				     to source number
# destroys: ebx
#
__int.double:
	fldl	4(%esp)
int.x:
	fnstcw	orig_control_bits
	fwait
	movw	orig_control_bits,%bx
	andw	$0xF3FF,%bx	#mask out rounding-control bits
	orw	$0x0400,%bx	#set rounding mode to: "round down"
	movw	%bx,control_bits	#why have one CPU when two will do?
	fldcw	control_bits
	frndint		#INT() the God-damned number, finally!
	fldcw	orig_control_bits
	ret
#
#
# **************************
# *****  %_fix.single  *****  FIX(single)
# **************************
#
# in:	arg0 = source number
# out:	st(0) = source number truncated
#
# destroys: ebx
#
__fix.single:
	flds	4(%esp)
	jmp	fix.x
#
# **************************
# *****  %_fix.double  *****  FIX(double)
# **************************
#
# in:	arg1:arg0 = source number
# out:	st(0) = source number truncated
#
# destroys: ebx
#
__fix.double:
	fldl	4(%esp)
fix.x:
	fnstcw	orig_control_bits
	fwait
	movw	orig_control_bits,%bx
	orw	$0x0C00,%bx	#set rounding mode to: "truncate"
	movw	%bx,control_bits	#why have one CPU when two will do?
	fldcw	control_bits
	frndint		#FIX() the God-damned number, finally!
	fldcw	orig_control_bits
	ret
#
#
# *************************
# *****  %_sgn.slong  *****  SGN(x)
# *****  %_sgn.xlong  *****
# *************************
#
# in:	arg0 = source number
# out:	eax = 1 if source number > 0
#	      0 if source number = 0
#	     -1 if source number < 0
#
# destroys: nothing
#
__sgn.slong:
__sgn.xlong:
	movl	4(%esp),%eax	#eax = source number
	sarl	$31,%eax	#copy sign bit all over result
	cmpl	$0,4(%esp)	#source number is greater than zero?
	jle	sgn_ret	#no: result = eax
	incl	%eax	#yes: result = 1
sgn_ret:
	ret
#
#
# *************************
# *****  %_sgn.ulong  *****  SGN(x)
# *************************
#
# in:	arg0 = source number
# out:	eax = 1 if source number > 0
#	      0 if source number = 0
#
# destroys: nothing
#
__sgn.ulong:
	movl	4(%esp),%eax	#eax = source number
	orl	%eax,%eax	#source number is zero?
	jz	sgnu_ret	#yes: nothing to do
	movl	$1,%eax	#no: result = 1
sgnu_ret:
	ret
#
#
# *************************
# *****  %_sgn.giant  *****  SGN(giant)
# *************************
#
# in:	arg1:arg0 = source number
# out:	edx:eax = 1 if source number > 0
#	          0 if source number = 0
#	         -1 if source number < 0
#
# destroys: nothing
#
__sgn.giant:
	movl	4(%esp),%eax	#eax = ls half of source number
	movl	8(%esp),%edx	#edx = ms half of source number
	cmpl	$0,%edx
	jz	sgng_ms_zero	#ms half of source number is zero
	jg	sgng_one	#> 0# set result to 1
	orl	$-1,%edx	#set result to -1
	movl	%edx,%eax
sgng_ret:
	ret
sgng_ms_zero:
	cmpl	$0,%eax
	jz	sgng_ret	#source number is zero# so is result
	movl	$1,%eax	#> 0# result is 1
	ret
sgng_one:
	xorl	%edx,%edx	#set result to 1
	movl	$1,%eax
	ret
#
#
# **************************
# *****  %_sgn.single  *****  SGN(single)
# **************************
#
# in:	arg0 = source number
# out:	st(0) = 1 if source number > 0
#	        0 if source number = 0
#	       -1 if source number < 0
#
# destroys: eax
#
__sgn.single:
	flds	4(%esp)
	jmp	sgn.x
#
#
# **************************
# *****  %_sgn.double  *****  SGN(double)
# **************************
#
# in:	arg1:arg0 = source number
# out:	st(0) = 1 if source number > 0
#	        0 if source number = 0
#	       -1 if source number < 0
#
# destroys: eax
#
__sgn.double:
	fldl	4(%esp)
sgn.x:
	ftst		# "ftst" seems to cause trouble
	.byte	0x9b,0xdf,0xe0
	sahf
	jz	sgnx_ret	#source number = 0: result = source operand
	fstp	%st(0)	#throw away source number
	fld1		#assume result = 1 until proven otherwise
	ja	sgnx_ret	#source number > 0: result = 1
	fchs		#source number < 0: result = -1
sgnx_ret:
	ret
#
#
# **************************
# *****  %_sign.xlong  *****  SIGN(x)
# *****  %_sign.slong  *****
# **************************
#
# in:	arg0 = source number
# out:	eax = 1 if source number >= 0
#	     -1 if source number < 0
#
# destroys: nothing
#
__sign.xlong:
__sign.slong:
	movl	4(%esp),%eax	#eax = source number
	sarl	$31,%eax	#copy sign bit all over source number
	jnz	sign_ret	#if -1, done
	incl	%eax	#if 0, set to 1
sign_ret:
	ret
#
#
# **************************
# *****  %_sign.ulong  *****  SIGN(x)
# **************************
#
# in:	arg0 = source number
# out:	eax = 1
#
# destroys: nothing
#
__sign.ulong:
	movl	$1,%eax
	ret
#
#
# **************************
# *****  %_sign.giant  *****  SIGN(giant)
# **************************
#
# in:	arg1:arg0 = source number
# out:	edx:eax = 1 if source number >= 0
#	         -1 if source number < 0
#
# destroys: nothing
#
__sign.giant:
	movl	8(%esp),%edx	#edx = ms half of source number
	sarl	$31,%edx	#copy sign bit all over edx
	movl	%edx,%eax	#copy sign bit all over eax
	jnz	signg_ret	#if -1, done
	incl	%eax	#if 0, result is 1
signg_ret:
	ret
#
#
# ***************************
# *****  %_sign.single  *****  SIGN(single)
# ***************************
#
# in:	arg0 = source number
# out:	st(0) = 1 if source number >= 0
#	       -1 if source number < 0
#
# destroys: eax
#
__sign.single:
	flds	4(%esp)
	jmp	sign.x
#
#
# ***************************
# *****  %_sign.double  *****
# ***************************
#
# in:	arg1:arg0 = source number
# out:	st(0) = 1 if source number >= 0
#	       -1 if source number < 0
#
# destroys: eax
#
__sign.double:
	fldl	4(%esp)
sign.x:
	ftst		# "ftst" seems to cause trouble
	.byte	0x9b,0xdf,0xe0
	sahf
	fstp	%st(0)	#throw away source number
	fld1		#result is 1 until proven otherwise
	jae	signx_ret	#source >= 0: result = 1
	fchs		#source < 0: result = -1
signx_ret:
	ret
#
#
# *************************
# *****  %_MAX.slong  *****
# *****  %_MAX.xlong  *****
# *************************
#
__MAX.slong:
__MAX.xlong:
	movl	4(%esp),%eax	# 1st arg
	movl	8(%esp),%ebx	# 2nd arg
	cmpl	%ebx,%eax	# 1st : 2nd
	jge	_done0	# 1st > 2nd
	movl	%ebx,%eax	# 2nd > 1st
_done0:
	ret
#
#
# *************************
# *****  %_MAX.ulong  *****
# *************************
#
__MAX.ulong:
	movl	4(%esp),%eax	# 1st arg
	movl	8(%esp),%ebx	# 2nd arg
	cmpl	%ebx,%eax	# 1st : 2nd
	ja	_done1	# 1st > 2nd
	movl	%ebx,%eax	# 2nd > 1st
_done1:
	ret
#
#
# **************************
# *****  %_MAX.single  *****
# **************************
#
__MAX.single:
	flds	4(%esp)	# 1st arg
	flds	8(%esp)	# 2nd arg
	fcompp		# 1st : 2nd
	.byte	0x9b,0xdf,0xe0	# get flags in ax
	sahf		# put flags in cc
	ja	_s2nd	# 2nd arg is larger
#;
_s1st:
	flds	4(%esp)	# 1st arg
	ret
#
_s2nd:
	flds	8(%esp)	# 2nd arg
	ret
#
#
# **************************
# *****  %_MAX.double  *****
# **************************
#
__MAX.double:
	fldl	4(%esp)	# 1st arg
	fldl	12(%esp)	# 2nd arg
	fcompp		# 1st : 2nd
	.byte	0x9b,0xdf,0xe0	# get flags in ax
	sahf		# put flags in cc
	ja	_d2nd	# 2nd arg is larger
#;
_d1st:
	fldl	4(%esp)	# 1st arg
	ret
#
_d2nd:
	fldl	12(%esp)	# 2nd arg
	ret
#
#
#
# *************************
# *****  %_MIN.slong  *****
# *****  %_MIN.xlong  *****
# *************************
#
__MIN.slong:
__MIN.xlong:
	movl	4(%esp),%eax	# 1st arg
	movl	8(%esp),%ebx	# 2nd arg
	cmpl	%ebx,%eax	# 1st : 2nd
	jle	_done2	# 1st > 2nd
	movl	%ebx,%eax	# 2nd > 1st
_done2:
	ret
#
#
# *************************
# *****  %_MIN.ulong  *****
# *************************
#
__MIN.ulong:
	movl	4(%esp),%eax	# 1st arg
	movl	8(%esp),%ebx	# 2nd arg
	cmpl	%ebx,%eax	# 1st : 2nd
	jb	_done3	# 1st > 2nd
	movl	%ebx,%eax	# 2nd > 1st
_done3:
	ret
#
#
# **************************
# *****  %_MIN.single  *****
# **************************
#
__MIN.single:
	flds	4(%esp)	# 1st arg
	flds	8(%esp)	# 2nd arg
	fcompp		# 1st : 2nd
	.byte	0x9b,0xdf,0xe0	# get flags in ax
	sahf		# put flags in cc
	jb	_ss2nd	# 2nd arg is larger
#;
_ss1st:
	flds	4(%esp)	# 1st arg
	ret
#
_ss2nd:
	flds	8(%esp)	# 2nd arg
	ret
#
#
# **************************
# *****  %_MIN.double  *****
# **************************
#
__MIN.double:
	fldl	4(%esp)	# 1st arg
	fldl	12(%esp)	# 2nd arg
	fcompp		# 1st : 2nd
	.byte	0x9b,0xdf,0xe0	# get flags in ax
	sahf		# put flags in cc
	jb	_dd2nd	# 2nd arg is larger
#;
_dd1st:
	fldl	4(%esp)	# 1st arg
	ret
#
_dd2nd:
	fldl	12(%esp)	# 2nd arg
	ret
#
#
#
# ****************************
# *****  %_add.SCOMPLEX  *****  z3 = z1 + z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
# Re(z3) = Re(z1) + Re(z2)
# Im(z3) = Im(z1) + Im(z2)
#
__add.SCOMPLEX:
	flds	(%esi)	#add real components
	flds	(%edi)
	faddp
	fstpl	(%eax)
	flds	4(%esi)	#add imaginary components (but really add them)
	flds	4(%edi)
	faddp
	fstpl	4(%eax)
	ret
#
#
# ****************************
# *****  %_add.DCOMPLEX  *****  z3 = z1 + z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
# Re(z3) = Re(z1) + Re(z2)
# Im(z3) = Im(z1) + Im(z2)
#
__add.DCOMPLEX:
	fldl	(%esi)	#add real components
	fldl	(%edi)
	faddp
	fstpl	(%eax)
	fldl	8(%esi)	#add imaginary components
	fldl	8(%edi)
	faddp
	fstpl	8(%eax)
	ret
#
#
# ****************************
# *****  %_sub.SCOMPLEX  *****  z3 = z1 - z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
# Re(z3) = Re(z1) - Re(z2)
# Im(z3) = Im(z1) - Im(z2)
#
__sub.SCOMPLEX:
	flds	(%esi)	#subtract real components
	flds	(%edi)
	fsubrp
	fstpl	(%eax)
	flds	4(%esi)	#subtract imaginary components
	flds	4(%edi)
	fsubrp
	fstpl	4(%eax)
	ret
#
#
# ****************************
# *****  %_sub.DCOMPLEX  *****  z3 = z1 - z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
# Re(z3) = Re(z1) - Re(z2)
# Im(z3) = Im(z1) - Im(z2)
#
__sub.DCOMPLEX:
	fldl	(%esi)	#subtract real components
	fldl	(%edi)
	fsubrp
	fstpl	(%eax)
	fldl	8(%esi)	#subtract imaginary components
	fldl	8(%edi)
	fsubrp
	fstpl	8(%eax)
	ret
#
#
# ****************************
# *****  %_mul.SCOMPLEX  *****  z3 = z1 * z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
# Re(z3) = Re(z1) * Re(z2) - Im(z1) * Im(z2)
# Im(z3) = Re(z1) * Im(z2) + Im(z1) * Re(z2)
#
__mul.SCOMPLEX:
	flds	(%esi)	#calculate real part of product
	flds	(%edi)
	fmulp
	flds	4(%esi)
	flds	4(%edi)
	fmulp
	fsubrp
	fstpl	(%eax)
	flds	(%esi)	#calculate imaginary part of product
	flds	4(%edi)
	fmulp
	flds	4(%esi)
	flds	(%edi)
	fmulp
	faddp
	fstpl	4(%eax)
	ret
#
#
# ****************************
# *****  %_mul.DCOMPLEX  *****  z3 = z1 * z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
# Re(z3) = Re(z1) * Re(z2) - Im(z1) * Im(z2)
# Im(z3) = Re(z1) * Im(z2) + Im(z1) * Re(z2)
#
__mul.DCOMPLEX:
	fldl	(%esi)	#calculate real part of product
	fldl	(%edi)
	fmulp
	fldl	8(%esi)
	fldl	8(%edi)
	fmulp
	fsubrp
	fstpl	(%eax)
	fldl	(%esi)	#calculate imaginary part of product
	fldl	8(%edi)
	fmulp
	fldl	8(%esi)
	fldl	(%edi)
	fmulp
	faddp
	fstpl	8(%eax)
	ret
#
#
# ****************************
# *****  %_div.SCOMPLEX  *****  z3 = z1 / z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
#	   Re(z1) * Re(z2) + Im(z1) * Im(z2)
# Re(z3) = ---------------------------------
#	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
#
#	   Im(z1) * Re(z2) - Im(z2) * Re(z1)
# Im(z3) = ---------------------------------
#	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
#
__div.SCOMPLEX:
	flds	(%esi)	#calculate real part of quotient
	flds	(%edi)
	fmulp
	flds	4(%esi)
	flds	4(%edi)
	fmulp
	faddp		#st(0) = numerator
	flds	(%edi)
	fld	%st(0)
	fmulp
	flds	4(%edi)
	fld	%st(0)
	fmulp
	faddp		#st(0) = denominator, st(1) = numerator
	fst	%st(2)	#save denominator for later
	fdivrp
	fstpl	(%eax)	#store real part of quotient
	flds	4(%esi)	#calculate imaginary part of quotient
	flds	(%edi)
	fmulp
	flds	4(%edi)
	flds	(%esi)
	fmulp
	fsubrp		#st(0) = numerator, st(1) = denominator
	fdivp
	fstpl	4(%eax)	#store imaginary part of quotient
	ret
#
#
# ****************************
# *****  %_div.DCOMPLEX  *****  z3 = z1 / z2
# ****************************
#
# in:	eax -> z3 (result)
#	esi -> z1
#	edi -> z2
# out:	eax -> z3 (result)
#
# destroys: nothing
#
#	   Re(z1) * Re(z2) + Im(z1) * Im(z2)
# Re(z3) = ---------------------------------
#	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
#
#	   Im(z1) * Re(z2) - Im(z2) * Re(z1)
# Im(z3) = ---------------------------------
#	   Re(z2) * Re(z2) + Im(z2) * Im(z2)
#
__div.DCOMPLEX:
	fldl	(%esi)	#calculate real part of quotient
	fldl	(%edi)
	fmulp
	fldl	8(%esi)
	fldl	8(%edi)
	fmulp
	faddp		#st(0) = numerator
	fldl	(%edi)
	fld	%st(0)
	fmulp
	fldl	8(%edi)
	fld	%st(0)
	fmulp
	faddp		#st(0) = denominator, st(1) = numerator
	fst	%st(2)	#save denominator for later
	fdivrp
	fstpl	(%eax)	#store real part of quotient
	fldl	8(%esi)	#calculate imaginary part of quotient
	fldl	(%edi)
	fmulp
	fldl	8(%edi)
	fldl	(%esi)
	fmulp
	fsubrp		#st(0) = numerator, st(1) = denominator
	fdivp
	fstpl	8(%eax)	#store imaginary part of quotient
	ret
#
#
# **********************************
# *****  **  (POWER operator)  *****
# **********************************
#
__power.slong:
__power.xlong:
	pushl	$0
	pushl	%eax	# x
	pushl	$0
	pushl	%ebx	# y
	fildl	0(%esp)	# FPU = x
	fildl	8(%esp)	# FPU = y
	fstpl	0(%esp)	# arg1 = x_
	fstpl	8(%esp)	# arg2 = y_
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp	#
	fistpl	0(%esp)	# a
	popl	%eax	# eax = a  (result)
	popl	%edx	# edx = garbage  (clean up stack)
	ret
#
__rpower.slong:
__rpower.xlong:
	pushl	$0
	pushl	%ebx	# x
	pushl	$0
	pushl	%eax	# y
	fildl	0(%esp)	# FPU = x
	fildl	8(%esp)	# FPU = y
	fstpl	0(%esp)	# arg1 = x_
	fstpl	8(%esp)	# arg2 = y_
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp	#
	fistpl	0(%esp)	# a
	popl	%eax	# eax = a  (result)
	popl	%edx	# edx = garbage  (clean up stack)
	ret
#
#
#
__power.ulong:
	pushl	$0
	pushl	%eax
	pushl	$0
	pushl	%ebx
	fildll	0(%esp)	# FPU = y
	fildll	8(%esp)	# FPU = x
	fstpl	0(%esp)	# arg1 = x_
	fstpl	8(%esp)	# arg2 = y_
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp	#
	fistpll	0(%esp)	# a$$
	popl	%eax	# eax = LSW of a$$
	popl	%edx	# edx = MSW of a$$
	orl	%edx,%edx	# is MSW = 0 ???
	jnz	power.overflow	# if not, result is too large for ULONG
	ret
#
__rpower.ulong:
	pushl	$0
	pushl	%ebx
	pushl	$0
	pushl	%eax
	fildll	0(%esp)	# FPU = y
	fildll	8(%esp)	# FPU = x
	fstpl	0(%esp)	# arg1 = x_
	fstpl	8(%esp)	# arg2 = y_
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp	#
	fistpll	0(%esp)	# a$$
	popl	%eax	# eax = LSW of a$$
	popl	%edx	# edx = MSW of a$$
	orl	%edx,%edx	# is MSW = 0 ???
	jnz	power.overflow	# if not, result is too large for ULONG
	ret
#
#
#
__power.giant:
	pushl	%edx
	pushl	%eax
	pushl	%ecx
	pushl	%ebx
	fildll	0(%esp)	# FPU = y
	fildll	8(%esp)	# FPU = x
	fstpl	0(%esp)	# arg1 = x_
	fstpl	8(%esp)	# arg2 = y_
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp	#
	fistpll	0(%esp)	# a$$
	popl	%eax	# eax = LSW of a$$
	popl	%edx	# edx = MSW of a$$
	ret
#
__rpower.giant:
	pushl	%ecx
	pushl	%ebx
	pushl	%edx
	pushl	%eax
	fildll	0(%esp)	# FPU = y
	fildll	8(%esp)	# FPU = x
	fstpl	0(%esp)	# arg1 = x_
	fstpl	8(%esp)	# arg2 = y_
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp	#
	fistpll	0(%esp)	# a$$
	popl	%eax	# eax = LSW of a$$
	popl	%edx	# edx = MSW of a$$
	ret
#
#
#
__power.single:
	subl	$16,%esp	#
	fstpl	8(%esp)		#
	fstpl	0(%esp)		#
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp		#
	fstl	0(%esp)		# a!
	popl	%eax		# eax = a!
	popl	%edx		# garbage  (clean stack)
	ret
#
__rpower.single:
	subl	$16,%esp	#
	fstpl	0(%esp)		#
	fstpl	8(%esp)		#
	call	POWER_16	# math library function  a_ = POWER (x_, y_)
	subl	$8,%esp		#
	fstl	0(%esp)		# a!
	popl	%eax		# eax = a!
	popl	%edx		# garbage  (clean stack)
	ret
#
#
#
__power.double:
	subl	$16,%esp	#
	fstpl	8(%esp)	#
	fstpl	0(%esp)	#
	call	POWER_16	# math library function  a# = POWER (x#, y#)
	subl	$8,%esp	#
	fstl	0(%esp)	# a#
	popl	%eax	# eax = LSW of a#
	popl	%edx	# edx = MSW of a#
	ret
#
__rpower.double:
	subl	$16,%esp	#
	fstpl	0(%esp)	#
	fstpl	8(%esp)	#
	call	POWER_16	# math library function  a# = POWER (x#, y#)
	subl	$8,%esp	#
	fstl	0(%esp)	# a#
	popl	%eax	# eax = LSW of a#
	popl	%edx	# edx = MSW of a#
	ret
#
#
power.overflow:
	jmp	__eeeOverflow	# no, so result is too large for ULONG
	ret
#
#
#
# *************************
# *****  %_extu.2arg  *****  EXTU(v, bitfield)
# *************************
#
# in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
#	arg0 = value from which to extract bit field
# out:	eax = bitfield extracted from arg0, zero-extended
#
# destroys: ebx, ecx, edx, esi, edi
#
.align	16
__extu.2arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ebx	#ebx = width:offset
	movl	%ebx,%ecx	#ecx = offset with extra bits on top
	shrl	$5,%ebx	#shift width into low 5 bits of ebx
	shrl	%cl,%eax	#shift bitfield to right (low) end of eax
	andl	$31,%ebx	#only want low 5 bits of width
	andl	width_table(,%ebx,4),%eax	#screen out all but width bits
	ret
#
#
# *************************
# *****  %_extu.3arg  *****  EXTU(v, width, offset)
# *************************
#
# in:	arg2 = offset of bitfield
#	arg1 = width of bitfield
#	arg0 = value from which to extract bitfield
#
# out:	eax = bitfield extract from arg0, zero-extended
#
# destroys: ebx, ecx, edx, esi, edi
#
__extu.3arg:
	movl	4(%esp),%eax	#eax = value from which to extract bitfield
	movl	8(%esp),%ebx	#ebx = width
	movl	12(%esp),%ecx	#ecx = offset
	shrl	%cl,%eax	#shift bitfield to right (low) end of eax
	andl	$31,%ebx	#only want low 5 bits of width
	andl	width_table(,%ebx,4),%eax	#screen out all but width bits
	ret
#
#
# ************************
# *****  %_ext.2arg  *****  EXTS(v, bitfield)
# ************************
#
# in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
#	arg0 = value from which to extract bit field
# out:	eax = bitfield extracted from arg0, sign-extended
#
# destroys: ebx, ecx, edx, esi, edi
#
__ext.2arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ebx	#ebx = width:offset
	movl	%ebx,%ecx
	shrl	$5,%ecx	#ecx = width with extra bits on top
	andl	$31,%ecx	#only want low 5 bits of width
	andl	$31,%ebx	#only want low 5 bits of offset
	addl	%ebx,%ecx	#ecx = width + offset
	negl	%ecx
	addl	$32,%ecx	#ecx = 32 - (width + offset)
	shll	%cl,%eax	#shift bit field to top of eax
	addl	%ebx,%ecx	#ecx = 32 - width
	sarl	%cl,%eax	#shift back to bottom of eax, sign-extending
	ret
#
#
# ************************
# *****  %_ext.3arg  *****  EXTS(v, width, offset)
# ************************
#
# in:	arg2 = offset of bitfield
#	arg1 = width of bitfield
#	arg0 = value from which to extract bitfield
#
# out:	eax = bitfield extract from arg0, sign-extended
#
# destroys: ebx, ecx, edx, esi, edi
#
__ext.3arg:
	movl	4(%esp),%eax	#eax = value from which to extract bitfield
	movl	8(%esp),%ecx	#ecx = width
	movl	12(%esp),%ebx	#ebx = offset
	andl	$31,%ecx	#no silly widths
	andl	$31,%ebx	#no silly offsets
	addl	%ebx,%ecx	#ecx = width + offset
	negl	%ecx
	addl	$32,%ecx	#ecx = 32 - (width + offset)
	shll	%cl,%eax	#shift bit field to top of eax
	addl	%ebx,%ecx	#ecx = 32 - width
	sarl	%cl,%eax	#shift back to bottom of eax, sign-extending
	ret
#
#
# ************************
# *****  %_clr.2arg  *****  CLR(v, bitfield)
# ************************
#
# in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
#	arg0 = value from which to extract bit field
# out:	eax = arg0 with specified bitfield cleared
#
# destroys: ebx, ecx, edx, esi, edi
#
__clr.2arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ebx	#ebx = width:offset
	movl	%ebx,%ecx	#ecx = offset with extra bits on top
	shrl	$5,%ecx	#shift width into low 5 bits of ecx
	decl	%ecx	#translate 0 to 32, leave shift count in ecx
	andl	$31,%ecx	#only low bits of width
	andl	$31,%ebx	#only low bits of offset
	movl	$0x80000000,%edx	#get a bit to copy
	sarl	%cl,%edx	#copy it width times
	addl	%ebx,%ecx	#ecx = width + offset
	negl	%ecx
	addl	$31,%ecx	#ecx = 32 - (width + offset)
	shrl	%cl,%edx	#move block of 1's into position for mask
	notl	%edx	#edx = mask: 0's where bitfield is
	andl	%edx,%eax	#clear the bitfield
	ret
#
#
# ************************
# *****  %_clr.3arg  *****  CLR(v, width, offset)
# ************************
#
# in:	arg2 = offset of bitfield
#	arg1 = width of bitfield
#	arg0 = value from which to extract bitfield
# out:	eax = arg0 with specified bitfield cleared
#
# destroys: ebx, ecx, edx, esi, edi
#
__clr.3arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ecx	#ecx = width
	movl	12(%esp),%ebx	#ebx = offset
	decl	%ecx	#translate 0 to 32, leave shift count in ecx
	andl	$31,%ecx	#only low bits of width
	andl	$31,%ebx	#only low bits of offset
	movl	$0x80000000,%edx	#get a bit to copy
	sarl	%cl,%edx	#copy it (width-1) times
	addl	%ebx,%ecx	#ecx = width + offset
	negl	%ecx
	addl	$31,%ecx	#ecx = 32 - (width + offset)
	shrl	%cl,%edx	#move block of 1's into position for mask
	notl	%edx	#edx = mask: 0's where bitfield is
	andl	%edx,%eax	#clear the bitfield
	ret
#
#
# ************************
# *****  %_set.2arg  *****  SET(v, bitfield)
# ************************
#
# in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
#	arg0 = value from which to extract bit field
# out:	eax = arg0 with specified bitfield set
#
# destroys: ebx, ecx, edx, esi, edi
#
__set.2arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ebx	#ebx = width:offset
	movl	%ebx,%ecx	#ecx = offset with extra bits on top
	shrl	$5,%ecx	#shift width into low 5 bits of ecx
	decl	%ecx	#translate 0 to 32, leave shift count in ecx
	andl	$31,%ecx	#only low bits of width
	andl	$31,%ebx	#only low bits of offset
	movl	$0x80000000,%edx	#get a bit to copy
	sarl	%cl,%edx	#copy it width times
	addl	%ebx,%ecx	#ecx = width + offset - 1
	negl	%ecx
	addl	$31,%ecx	#ecx = 32 - (width + offset)
	shrl	%cl,%edx	#move block of 1's into position for mask
	orl	%edx,%eax	#set the bitfield
	ret
#
#
# ************************
# *****  %_set.3arg  *****  SET(v, width, offset)
# ************************
#
# in:	arg2 = offset of bitfield
#	arg1 = width of bitfield
#	arg0 = value from which to extract bitfield
# out:	eax = arg0 with specified bitfield set
#
# destroys: ebx, ecx, edx, esi, edi
#
__set.3arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ecx	#ecx = width
	movl	12(%esp),%ebx	#ebx = offset
	decl	%ecx	#translate 0 to 32, leave shift count in ecx
	andl	$31,%ecx	#only low bits of width
	andl	$31,%ebx	#only low bits of offset
	movl	$0x80000000,%edx	#get a bit to copy
	sarl	%cl,%edx	#copy it (width-1) times
	addl	%ebx,%ecx	#ecx = width + offset - 1
	negl	%ecx
	addl	$31,%ecx	#ecx = 32 - (width + offset)
	shrl	%cl,%edx	#move block of 1's into position for mask
	orl	%edx,%eax	#set the bitfield
	ret
#
#
# *************************
# *****  %_make.2arg  *****  MAKE(v, bitfield)
# *************************
#
# in:	arg1 = bits specification: offset in lowest 5 bits, width in next 5
#	arg0 = value from which to extract bit field
# out:	eax = arg0 with specified bitfield set
#
# destroys: ebx, ecx, edx, esi, edi
#
__make.2arg:
	movl	4(%esp),%eax	#eax = value from which to extract bit field
	movl	8(%esp),%ebx	#ebx = width:offset
	movl	%ebx,%ecx	#ecx = offset with extra bits on top
	shrl	$5,%ebx	#ebx = width with extra bits on top
	andl	$31,%ebx	#want only low 5 bits of width
	andl	width_table(,%ebx,4),%eax	#cut off all but width bits
	shll	%cl,%eax	#shift up to offset position
	ret
#
#
# *************************
# *****  %_make.3arg  *****  MAKE(v, width, offset)
# *************************
#
# in:	arg2 = offset of bitfield
#	arg1 = width of bitfield
#	arg0 = value from which to extract bitfield
# out:	eax = arg0 with specified bitfield set
#
# destroys: ebx, ecx, edx, esi, edi
#
__make.3arg:
	movl	4(%esp),%eax	#eax = value from which to extract bitfield
	movl	8(%esp),%ebx	#ebx = width
	movl	12(%esp),%ecx	#ecx = offset
	andl	$31,%ebx	#want only low 5 bits of width
	andl	width_table(,%ebx,4),%eax	#cut off all but width bits
	shll	%cl,%eax	#shift up to offset position
	ret
#
#
# *********************
# *****  %_error  *****  errorNumber = ERROR (arg)
# *********************
#
__error:
	movl	%eax,%ebx	# ebx = arg
	incl	%ebx	# ebx = 0 if arg = -1
	jz	getError	# get __ERROR but don't update it
	xchgl	__ERROR,%eax	# eax = __ERROR : __ERROR = arg
	ret
#
getError:
	movl	__ERROR,%eax	# eax = __ERROR : __ERROR unchanged
	ret
#
#
#
# ##################
# #####  DATA  #####  xlibnn.s
# ##################
#
#
# *****  Width Table  *****
#
.text
.align	8
width_table:
.long	0b11111111111111111111111111111111
.long	0b00000000000000000000000000000001
.long	0b00000000000000000000000000000011
.long	0b00000000000000000000000000000111
.long	0b00000000000000000000000000001111
.long	0b00000000000000000000000000011111
.long	0b00000000000000000000000000111111
.long	0b00000000000000000000000001111111
.long	0b00000000000000000000000011111111
.long	0b00000000000000000000000111111111
.long	0b00000000000000000000001111111111
.long	0b00000000000000000000011111111111
.long	0b00000000000000000000111111111111
.long	0b00000000000000000001111111111111
.long	0b00000000000000000011111111111111
.long	0b00000000000000000111111111111111
.long	0b00000000000000001111111111111111
.long	0b00000000000000011111111111111111
.long	0b00000000000000111111111111111111
.long	0b00000000000001111111111111111111
.long	0b00000000000011111111111111111111
.long	0b00000000000111111111111111111111
.long	0b00000000001111111111111111111111
.long	0b00000000011111111111111111111111
.long	0b00000000111111111111111111111111
.long	0b00000001111111111111111111111111
.long	0b00000011111111111111111111111111
.long	0b00000111111111111111111111111111
.long	0b00001111111111111111111111111111
.long	0b00011111111111111111111111111111
.long	0b00111111111111111111111111111111
.long	0b01111111111111111111111111111111
#
#
#
.text
#
# ######################
# #####  xlibns.s  #####  intrinsics that accept a string and return a number
# ######################
#
# **********************
# *****  %_len.v   *****  LEN(x$)
# *****  %_len.s   *****
# *****  %_size.v  *****  SIZE(x$)
# *****  %_size.s  *****
# **********************
#
# in:	arg0 -> string to return the length of
# out:	eax = length of string
#
# destroys: ebx, ecx, edx, esi, edi
#
# LEN(x$) and SIZE(x$) are the same function.
#
__len.v:
__size.v:
	xorl	%esi,%esi	#no string to free on exit
	jmp	len.x
#
__len.s:
__size.s:
	movl	4(%esp),%esi	#esi -> string to free on exit
#;
#; fall through
#;
len.x:
	xorl	%eax,%eax	#assume length is zero until proven otherwise
	movl	4(%esp),%edi	#edi -> string to find the length of
	orl	%edi,%edi	#null pointer?
	jz	len_exit	#yes: nothing to do
	movl	-8(%edi),%eax	#eax = length of string
	call	_____free	#free source string if called from .s entry
#;				; point
len_exit:
	ret
#
#
# ***********************
# *****  %_csize.v  *****  CSIZE(x$)
# *****  %_csize.s  *****
# ***********************
#
# in:	arg0 -> source string
# out:	eax = number of characters in source string up to but not including
#	      the first null
#
# destroys: ebx, ecx, edx, esi, edi
#
__csize.v:
	xorl	%esi,%esi	#nothing to free on exit
	jmp	csize.x
#
__csize.s:
	movl	4(%esp),%esi	#free source string on exit
#;
#; fall through
#;
csize.x:
	movl	4(%esp),%eax	#eax -> source string
	orl	%eax,%eax	#null pointer?
	jz	csize_exit	#yes: nothing to do
	movl	%eax,%edi	#edi -> source string
	movl	$-1,%ecx	#search until we find a null or cause a
	xorl	%eax,%eax	#search for a null
	cld		#make sure we're going in the right direction
	repne
	scasb		#edi -> terminating null
	notl	%ecx	#ecx = length + 1
	leal	-1(%ecx),%eax	#eax = length not counting terminator null
	call	_____free	#free source string if called from .s entry
csize_exit:
	ret
#
#
# *********************
# *****  %_asc.v  *****  ASC(x$, y)
# *****  %_asc.s  *****
# *********************
#
# in:	arg1 = index into x$ (one-biased)
#	arg0 -> source string
# out:	eax = ASCII value of character in x$ at position y
#
# destroys: ebx, ecx, edx, esi, edi
#
# If y < 1 or y > LEN(x$), generates "illegal function call" error and
# returns zero.
#
__asc.v:
	xorl	%esi,%esi	#nothing to free on exit
	jmp	asc.x
#
__asc.s:
	movl	4(%esp),%esi	#free source string on exit
#;
#; fall through
#;
asc.x:
	movl	4(%esp),%eax	#eax -> source string
	orl	%eax,%eax	#null pointer?
	jz	asc_IFC	#yes: error
	movl	8(%esp),%ebx	#ebx = index into source string (one-biased)
	cmpl	-8(%eax),%ebx	#greater than length of string?
	ja	asc_IFC	#yes: error
	decl	%ebx	#ebx = offset into source string
	js	asc_IFC	#if before beginning of string, error
	movzbl	(%eax,%ebx,1),%eax	#eax = ASC(x$,y)
	jmp	_____free	#free source string (esi) if called from .s
asc_IFC:
	xorl	%eax,%eax	#return a zero if there was an error
	call	_____free	#free source string (esi) if called from .s
	jmp	__eeeIllegalFunctionCall	# Return directly from there
#
#
# ************************
# *****  %_inchr.vv  *****  INCHR(x$, y$, z)
# *****  %_inchr.vs  *****
# *****  %_inchr.sv  *****
# *****  %_inchr.ss  *****
# ************************
#
# in:	arg2 = start position in x$ at which to begin search (one-biased)
#	arg1 -> y$: string containing set of characters to search for
#	arg0 -> x$: string in which to search
# out:	eax = index (one-biased) of first char in y$ that was found in
#	      x$, or 0 if none were found
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#
# INCHR()'s search is case-sensitive.  A start position of 0 is treated
# the same as a start position of 1.  If the start position is greater
# than LEN(x$), INCHR() returns 0.
#
# INCHR() builds a lookup table at search_tab, a 256-byte table in which
# each byte corresponds to one ASCII code.  All elements of the table
# are zero except those corresponding to characters in y$.
#
# INCHR() never generates a run-time error.
#
__inchr.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	inchr.x
#
__inchr.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	inchr.x
#
__inchr.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	inchr.x
#
__inchr.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
inchr.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	inchr_done	#yes: can't find anything in null string
	movl	-8(%edi),%edx	#edx = LEN(x$)
	orl	%edx,%edx	#length is zero?
	jz	inchr_done	#yes: can't find anything in zero-length string
	cmpl	16(%ebp),%edx	#length is less than start position?
	jb	inchr_done	#yes: can't find anything off right end of x$
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	inchr_done	#yes: null string can't contain matches
	movl	-8(%esi),%ecx	#ecx = LEN(y$)
	orl	%ecx,%ecx	#length is zero?
	jz	inchr_done	#yes: zero-length string can't contain matches
# build table at search_tab
	movl	$search_tab,%ebx	#ebx -> base of search table
	xorl	%eax,%eax	#zero upper 24 bits of index into search_tab
inchr_table_build_loop:
	lodsb		#get next char from y$ into al
	movb	$1,(%ebx,%eax,1)	#mark char's element in table
	decl	%ecx	#bump character counter
	jnz	inchr_table_build_loop	#next character
# search x$ for any chars with non-zero element in search_tab
	movl	%edi,%esi	#esi -> x$
	movl	16(%ebp),%edi	#edi = start position (one-biased)
	orl	%edi,%edi	#start position is zero?
	jz	inchr_skip1	#yes: start at first position
	decl	%edi	#edi = start offset
inchr_skip1:
	subl	%edi,%edx	#edx = number of chars to check
	addl	%edi,%esi	#esi -> first character to check
inchr_search_loop:
	incl	%edi	#bump position counter
	lodsb		#get next char from x$ into al
	xlat		#look up al's element in search_tab
	orb	%al,%al	#al != 0 iff al was in y$
	jnz	inchr_found	#if char is in y$, done
	decl	%edx	#bump character counter
	jnz	inchr_search_loop
# re-zero table at search_tab (so next call to INCHR() works)
inchr_rezero:
	movl	12(%ebp),%esi	#esi -> y$
	movl	-8(%esi),%ecx	#ecx = number of chars in y$
inchr_table_zero_loop:
	lodsb		#get next char from y$ into al
	movb	$0,(%ebx,%eax,1)	#zero char's element in table
	decl	%ecx	#bump character counter
	jnz	inchr_table_zero_loop
# free stack strings and exit
inchr_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs ro be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
inchr_found:
	movl	%edi,-12(%ebp)	#return value is current character position
	jmp	inchr_rezero
#
#
# *************************
# *****  %_inchri.vv  *****  INCHRI(x$, y$, z)
# *****  %_inchri.vs  *****
# *****  %_inchri.sv  *****
# *****  %_inchri.ss  *****
# *************************
#
# in:	arg2 = start position in x$ at which to begin search (one-biased)
#	arg1 -> y$: string containing set of characters to search for
#	arg0 -> x$: string in which to search
# out:	eax = index (one-biased) of first char in y$ that was found in
#	      x$, or 0 if none were found
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#
# INCHRI()'s search is case-insensitive.  A start position of 0 is treated
# the same as a start position of 1.  If the start position is greater
# than LEN(x$), INCHRI() returns 0.
#
# INCHRI() builds a lookup table at search_tab, a 256-byte table in which
# each byte corresponds to one ASCII code.  All elements of the table
# are zero except those corresponding to upper- and lower-case versions
# of characters in y$.
#
# INCHRI() never generates a run-time error.
#
__inchri.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	inchri.x
#
__inchri.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	inchri.x
#
__inchri.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	inchri.x
#
__inchri.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
inchri.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	inchri_done	#yes: can't find anything in null string
	movl	-8(%edi),%edx	#edx = LEN(x$)
	orl	%edx,%edx	#length is zero?
	jz	inchri_done	#yes: can't find anything in 0-length string
	cmpl	16(%ebp),%edx	#length is less than start position?
	jb	inchr_done	#yes: can't find anything off right end of x$
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	inchri_done	#yes: null string can't contain matches
	movl	-8(%esi),%ecx	#ecx = LEN(y$)
	orl	%ecx,%ecx	#length is zero?
	jz	inchri_done	#yes: zero-length string can't contain matches
#
# build table at search_tab
#
	movl	$search_tab,%edx	#edx -> base of search table
	movl	$__uctolc,%ebx	#ebx -> base of upper-to-lower conv. table
	movl	$__lctouc,%edi	#edi -> base of lower-to-upper conv. table
	xorl	%eax,%eax	#zero upper 24 bits of index into search_tab
inchri_table_build_loop:
	lodsb		#get next char from y$ into al
	xlat		#convert char to lower case
	movb	$1,(%edx,%eax,1)	#mark char's element in table
	movb	(%edi,%eax,1),%al	#convert char to upper case
	movb	$1,(%edx,%eax,1)	#mark char's element in table
	decl	%ecx	#bump character counter
	jnz	inchri_table_build_loop	#next character
#
# search x$ for any chars with non-zero element in search_tab
#
	movl	8(%ebp),%esi	#esi -> x$
	movl	16(%ebp),%edi	#edi = start position (one-biased)
	orl	%edi,%edi	#start position is zero?
	jz	inchri_skip1	#yes: start at first position
	decl	%edi	#edi = start offset
inchri_skip1:
	movl	-8(%esi),%edx	#edx = number of chars in x$
	subl	%edi,%edx	#edx = number of chars to check
	addl	%edi,%esi	#esi -> first character to check
	movl	$search_tab,%ebx	#ebx -> base of y$ lookup table
#
inchri_search_loop:
	incl	%edi	#bump position counter
	lodsb		#get next char from x$ into al
	xlat		#look up al's element in search_tab
	orb	%al,%al	#al != 0 iff al was in y$
	jnz	inchri_found	#if char is in y$, done
	decl	%edx	#bump character counter
	jnz	inchri_search_loop
#
# re-zero table at search_tab (so next call to INCHR() works)
#
inchri_rezero:
	movl	12(%ebp),%esi	#esi -> y$
	movl	$search_tab,%edx	#edx -> base of search table
	movl	$__lctouc,%edi	#edi -> base of lower-to-upper conv. table
	movl	$__uctolc,%ebx	#ebx -> base of upper-to-lower conv. table
	movl	-8(%esi),%ecx	#ecx = number of chars in y$
inchri_table_zero_loop:
	lodsb		#get next char from y$ into al
	xlat		#convert char to lower case
	movb	$0,(%edx,%eax,1)	#zero char's element in table
	movb	(%edi,%eax,1),%al	#convert char to upper case
	movb	$0,(%edx,%eax,1)	#zero char's element in table
	decl	%ecx	#bump character counter
	jnz	inchri_table_zero_loop
# free stack strings and exit
inchri_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs ro be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
inchri_found:
	movl	%edi,-12(%ebp)	#return value is current character position
	jmp	inchri_rezero
#
#
# *************************
# *****  %_rinchr.vv  *****  RINCHR(x$, y$, z)
# *****  %_rinchr.sv  *****
# *****  %_rinchr.vs  *****
# *****  %_rinchr.ss  *****
# *************************
#
# in:	arg2 = start position (one-biased) in x$ at which to begin search
#	arg1 -> y$: string containing set of characters to search for
#	arg0 -> x$: string in which to search
# out:	eax = position in x$
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#
# RINCHR()'s search is case-sensitive, and proceeds backwards in x$ from
# the start position.  A start position of zero is equivalent to a
# start position of LEN(x$).  A start position greater than LEN(x$)
# is equivalent to a start position of LEN(x$).
#
# RINCHR() builds a lookup table at search_tab, a 256-byte table in which
# each byte corresponds to one ASCII code.  All elements of the table
# are zero except those corresponding to characters in y$.
#
# RINCHR() never generates a run-time error.
#
__rinchr.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinchr.x
#
__rinchr.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	rinchr.x
#
__rinchr.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinchr.x
#
__rinchr.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
rinchr.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	rinchr_done	#yes: can't find anything in null string
	movl	-8(%edi),%edx	#edx = LEN(x$)
	orl	%edx,%edx	#length is zero?
	jz	rinchr_done	#yes: can't find anything in 0-length string
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	rinchr_done	#yes: null string can't contain matches
	movl	-8(%esi),%ecx	#ecx = LEN(y$)
	orl	%ecx,%ecx	#length is zero?
	jz	rinchr_done	#yes: zero-length string can't contain matches
#
# build table at search_tab
#
	movl	$search_tab,%ebx	#ebx -> base of search table
	xorl	%eax,%eax	#zero upper 24 bits of index into search_tab
rinchr_table_build_loop:
	lodsb		#get next char from y$ into al
	movb	$1,(%ebx,%eax,1)	#mark char's element in table
	decl	%ecx	#bump character counter
	jnz	rinchr_table_build_loop	#next character
#
# search x$ for any chars with non-zero element in search_tab
#
	movl	16(%ebp),%esi	#esi = start position (one-biased)
	orl	%esi,%esi	#start position is zero?
	jz	rinchr_skip1	#yes: set start position to end of string
	cmpl	%edx,%esi	#start position is greater than LEN(x$)?
	jna	rinchr_skip2	#no: start position is ok
rinchr_skip1:
	movl	%edx,%esi	#start position is at end of string
rinchr_skip2:
	decl	%esi	#esi = start offset
rinchr_search_loop:
	movb	(%edi,%esi,1),%al	#get next char from x$ into al
	xlat		#look up al's element in search_tab
	orb	%al,%al	#al != 0 iff al was in y$
	jnz	rinchr_found	#if char is in y$, done
	decl	%esi	#bump character counter
	jns	rinchr_search_loop
#
# re-zero table at search_tab (so next call to INCHR() works)
#
rinchr_rezero:
	movl	12(%ebp),%esi	#esi -> y$
	movl	-8(%esi),%ecx	#ecx = number of chars in y$
rinchr_table_zero_loop:
	lodsb		#get next char from y$ into al
	movb	$0,(%ebx,%eax,1)	#zero char's element in table
	decl	%ecx	#bump character counter
	jnz	rinchr_table_zero_loop
# free stack strings and exit
rinchr_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs ro be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
rinchr_found:
	incl	%esi	#esi = current char position (one-biased)
	movl	%esi,-12(%ebp)	#return value is current character position
	jmp	rinchr_rezero
#
#
# **************************
# *****  %_rinchri.vv  *****  RINCHRI(x$, y$, z)
# *****  %_rinchri.sv  *****
# *****  %_rinchri.vs  *****
# *****  %_rinchri.ss  *****
# **************************
#
# in:	arg2 = start position (one-biased) in x$ at which to begin search
#	arg1 -> y$: string containing set of characters to search for
#	arg0 -> x$: string in which to search
# out:	eax = position in x$
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#
# RINCHRI()'s search is case-insensitive, and proceeds backwards in x$ from
# the start position.  A start position of zero is treated the same as a
# start position of LEN(x$).  A start position greater than LEN(x$)
# is equivalent to a start position of LEN(x$).
#
# RINCHRI() builds a lookup table at search_tab, a 256-byte table in which
# each byte corresponds to one ASCII code.  All elements of the table
# are zero except those corresponding to upper- and lower-case versions
# of characters in y$.
#
# RINCHRI() never generates a run-time error.
#
__rinchri.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinchri.x
#
__rinchri.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	rinchri.x
#
__rinchri.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinchri.x
#
__rinchri.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
rinchri.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	rinchri_done	#yes: can't find anything in null string
	movl	-8(%edi),%edx	#edx = LEN(x$)
	orl	%edx,%edx	#length is zero?
	jz	rinchri_done	#yes: can't find anything in 0-length string
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	rinchri_done	#yes: null string can't contain matches
	movl	-8(%esi),%ecx	#ecx = LEN(y$)
	orl	%ecx,%ecx	#length is zero?
	jz	rinchri_done	#yes: 0-length string can't contain matches
#
# build table at search_tab
#
	movl	$search_tab,%edx	#edx -> base of search table
	movl	$__uctolc,%ebx	#ebx -> base of upper-to-lower conv. table
	movl	$__lctouc,%edi	#edi -> base of lower-to-upper conv. table
	xorl	%eax,%eax	#zero upper 24 bits of index into search_tab
rinchri_table_build_loop:
	lodsb		#get next char from y$ into al
	xlat		#convert char to lower case
	movb	$1,(%edx,%eax,1)	#mark char's element in table
	movb	(%edi,%eax,1),%al	#convert char to upper case
	movb	$1,(%edx,%eax,1)	#mark char's element in table
	decl	%ecx	#bump character counter
	jnz	rinchri_table_build_loop	#next character
#
# search x$ for any chars with non-zero element in search_tab
#
	movl	16(%ebp),%esi	#esi = start position (one-biased)
	movl	8(%ebp),%edi	#edi -> x$
	movl	-8(%edi),%edx	#edx = LEN(x$)
	orl	%esi,%esi	#start position is zero?
	jz	rinchri_skip1	#yes: set start position to end of string
	cmpl	%edx,%esi	#start position is greater than LEN(x$)?
	jna	rinchri_skip2	#no: start position is ok
rinchri_skip1:
	movl	%edx,%esi	#start position is at end of string
rinchri_skip2:
	decl	%esi	#esi = start offset
	movl	$search_tab,%ebx	#ebx -> base of y$ lookup table
rinchri_search_loop:
	movb	(%edi,%esi,1),%al	#get next char from x$ into al
	xlat		#look up al's element in search_tab
	orb	%al,%al	#al != 0 iff al was in y$
	jnz	rinchri_found	#if char is in y$, done
	decl	%esi	#bump character counter
	jns	rinchri_search_loop
#
# re-zero table at search_tab (so next call to INCHR() works)
#
rinchri_rezero:
	movl	12(%ebp),%esi	#esi -> y$
	movl	$search_tab,%edx	#edx -> base of search table
	movl	$__lctouc,%edi	#edi -> base of lower-to-upper conv. table
	movl	$__uctolc,%ebx	#ebx -> base of upper-to-lower conv. table
	movl	-8(%esi),%ecx	#ecx = number of chars in y$
rinchri_table_zero_loop:
	lodsb		#get next char from y$ into al
	xlat		#convert char to lower case
	movb	$0,(%edx,%eax,1)	#zero char's element in table
	movb	(%edi,%eax,1),%al	#convert char to upper case
	movb	$0,(%edx,%eax,1)	#zero char's element in table
	decl	%ecx	#bump character counter
	jnz	rinchri_table_zero_loop
# free stack strings and exit
rinchri_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs ro be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
rinchri_found:
	incl	%esi	#esi = current char position (one-biased)
	movl	%esi,-12(%ebp)	#return value is current character position
	jmp	rinchri_rezero
#
#
# ************************
# *****  %_instr.vv  *****  INSTR(x$, y$, z)
# *****  %_instr.vs  *****
# *****  %_instr.sv  *****
# *****  %_instr.ss  *****
# ************************
#
# in:	arg2 = start position in x$ at which to begin search (one-biased)
#	arg1 -> y$: substring to search for
#	arg0 -> x$: string in which to search
# out:	eax = index (one-biased) of first char in y$ that was found in
#	      x$, or 0 if none were found
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#
# INSTR()'s search is case-sensitive.  A start position of 0 is treated
# the same as a start position of 1.  If the start position is greater
# than LEN(x$), INSTR() returns 0.  If y$ is null or zero-length, INSTR()
# returns 0.
#
# INSTR() never generates a run-time error.
#
__instr.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	instr.x
#
__instr.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	instr.x
#
__instr.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	instr.x
#
__instr.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
instr.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	instr_done	#yes: can't find anything in null string
	movl	-8(%edi),%ecx	#ecx = LEN(x$)
	jecxz	instr_done	#same with zero-length string
	movl	16(%ebp),%eax	#eax = start position
	cmpl	%ecx,%eax	#start position greater than length?
	ja	instr_done	#yes: can't find anything beyond end of string
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	instr_done	#yes: can't find a null string
	movl	-8(%esi),%edx	#edx = LEN(y$)
	orl	%edx,%edx	#zero length?
	jz	instr_done	#yes: can't find a zero-length string
	cmpl	%ecx,%edx	#LEN(y$) > LEN(x$)?
	ja	instr_done	#yes: can't find bigger string in smaller
# set up variables for loop
	decl	%eax	#eax = start offset
	jns	instr_skip1	#wait!
	incl	%eax	#if start position was zero, start search
instr_skip1:			# at beginning of string
	subl	%edx,%ecx	#ecx = LEN(x$) - LEN(y$) = last position
	movl	%ecx,%ebx	#ebx = last position to check
	movl	%edi,%edx	#edx -> x$
# loop through x$, comparing with y$ at each position until match is found
instr_loop:
	cmpl	%ebx,%eax	#past last position to check?
	ja	instr_done	#yes: no match
	leal	(%edx,%eax,1),%esi	#esi -> current position in x$
	movl	12(%ebp),%edi	#edi -> y$
	movl	-8(%edi),%ecx	#ecx = LEN(y$)
	repz
	cmpsb		#compare y$ with substring of x$
	jz	instr_found	#got a match
	incl	%eax	#bump current-position counter
	jmp	instr_loop
# free stack strings and exit
instr_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs to be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
instr_found:
	incl	%eax	#convert zero-biased position to one-biased
	movl	%eax,-12(%ebp)	#save return value
	jmp	instr_done
#
#
# *************************
# *****  %_instri.vv  *****  INSTRI(x$, y$, z)
# *****  %_instri.vs  *****
# *****  %_instri.sv  *****
# *****  %_instri.ss  *****
# *************************
#
# in:	arg2 = start position in x$ at which to begin search (one-biased)
#	arg1 -> y$: substring to search for
#	arg0 -> x$: string in which to search
# out:	eax = index (one-biased) of first char in y$ that was found in
#	      x$, or 0 if none were found
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#	[ebp-16] = current offset in x$
#	[ebp-20] = last offset in x$ at which there's any point in starting
#		   a comparison with y$
#
# INSTRI()'s search is case-insensitive.  A start position of 0 is treated
# the same as a start position of 1.  If the start position is greater
# than LEN(x$), INSTRI() returns 0.  If y$ is null or zero-length, INSTRI()
# returns 0.
#
# INSTRI() never generates a run-time error.
#
__instri.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	instri.x
#
__instri.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	instri.x
#
__instri.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	instri.x
#
__instri.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
instri.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$20,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	instri_done	#yes: can't find anything in null string
	movl	-8(%edi),%ecx	#ecx = LEN(x$)
	jecxz	instri_done	#same with zero-length string
	movl	16(%ebp),%eax	#eax = start position
	cmpl	%ecx,%eax	#start position greater than length?
	ja	instri_done	#yes: can't find anything beyond end of string
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	instri_done	#yes: can't find a null string
	movl	-8(%esi),%edx	#edx = LEN(y$)
	orl	%edx,%edx	#zero length?
	jz	instri_done	#yes: can't find a zero-length string
	cmpl	%ecx,%edx	#LEN(y$) > LEN(x$)?
	ja	instri_done	#yes: can't find bigger string in smaller
# set up variables for loop
	decl	%eax	#eax = start offset
	jns	instri_skip1	#wait!
	incl	%eax	#if start position was zero, start search
instri_skip1:			# at beginning of string
	movl	%eax,-16(%ebp)	#set current position variable to start offset
	subl	%edx,%ecx	#ecx = LEN(x$) - LEN(y$) = last position
	movl	%ecx,-20(%ebp)	#[ebp-20] = last position to check
	movl	%edi,%edx	#edx -> x$
	movl	$__lctouc,%ebx	#ebx -> lower- to upper-case conversion table
# loop through x$, comparing with y$ at each position until match is found
instri_loop:
	cmpl	-20(%ebp),%eax	#past last position to check?
	ja	instri_done	#yes: no match
	leal	(%edx,%eax,1),%esi	#esi -> current position in x$
	movl	12(%ebp),%edi	#edi -> y$
	movl	-8(%edi),%ecx	#ecx = LEN(y$)
instri_inner_loop:
	lodsb		#al = char from x$
	xlat		#convert char from x$ to upper case
	xchgb	%al,%ah	#upper-cased char from x$ to ah
	movb	(%edi),%al	#al = char from y$
	xlat		#convert char from y$ to upper case
	cmpb	%al,%ah	#upper-cased chars from x$ and y$ identical?
	jne	instri_nomatch	#no: try comparing at next char in x$
	incl	%edi	#bump pointer into y$
	decl	%ecx	#bump character counter
	jnz	instri_inner_loop	#test against next char in y$, if there
	jmp	instri_found	#there isn't one: we have a match
instri_nomatch:
	movl	-16(%ebp),%eax
	incl	%eax	#bump current-position counter
	movl	%eax,-16(%ebp)
	jmp	instri_loop
# free stack strings and exit
instri_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs to be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
instri_found:
	movl	-16(%ebp),%eax	#eax = current offset in x$
	incl	%eax	#convert zero-biased position to one-biased
	movl	%eax,-12(%ebp)	#save return value
	jmp	instri_done
#
#
# *************************
# *****  %_rinstr.vv  *****  RINSTR(x$, y$, z)
# *****  %_rinstr.vs  *****
# *****  %_rinstr.sv  *****
# *****  %_rinstr.ss  *****
# *************************
#
# in:	arg2 = start position in x$ at which to begin search (one-biased)
#	arg1 -> y$: substring to search for
#	arg0 -> x$: string in which to search
# out:	eax = index (one-biased) of first char in y$ that was found in
#	      x$, or 0 if none were found
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#
# RINSTR()'s search is case-sensitive.  A start position of 0 is treated
# the same as a start position of 1.  A start position greater
# than LEN(x$) is the same as LEN(x$).  If y$ is null or zero-length, RINSTR()
# returns 0.
#
# RINSTR() never generates a run-time error.
#
__rinstr.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinstr.x
#
__rinstr.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	rinstr.x
#
__rinstr.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinstr.x
#
__rinstr.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
rinstr.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	rinstr_done	#yes: can't find anything in null string
	movl	-8(%edi),%ecx	#ecx = LEN(x$)
	jecxz	rinstr_done	#same with zero-length string
	movl	16(%ebp),%eax	#eax = start position
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	rinstr_done	#yes: can't find a null string
	movl	-8(%esi),%edx	#edx = LEN(y$)
	orl	%edx,%edx	#zero length?
	jz	rinstr_done	#yes: can't find a zero-length string
	cmpl	%ecx,%edx	#LEN(y$) > LEN(x$)?
	ja	rinstr_done	#yes: can't find bigger string in smaller
# set up variables for loop
	subl	%edx,%ecx	#end of string = LEN(x$) - LEN(y$)# must not
	incl	%ecx	#make ecx one-biased
	orl	%eax,%eax	#start offset is zero?
	jz	rinstr_skip2	#yes: default to end of string
	cmpl	%ecx,%eax	#start offset is beyond end of string?
	jna	rinstr_skip1	#no: start offset is ok
rinstr_skip2:
	movl	%ecx,%eax	#eax = LEN(x$): start search at end of string
rinstr_skip1:
	movl	%edi,%edx	#edx -> x$
	movl	%esi,%ebx	#ebx -> y$
# loop through x$, comparing with y$ at each position until match is found
rinstr_loop:
	decl	%eax	#bump position counter
	js	rinstr_done	#no match if past beginning of string
	leal	(%edx,%eax,1),%esi	#esi -> current position in x$
	movl	%ebx,%edi	#edi -> y$
	movl	-8(%edi),%ecx	#ecx = LEN(y$)
	repz
	cmpsb		#compare y$ with substring of x$
	jz	rinstr_found	#got a match
	jmp	rinstr_loop
# free stack strings and exit
rinstr_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs to be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
rinstr_found:
	incl	%eax	#convert zero-biased position to one-biased
	movl	%eax,-12(%ebp)	#save return value
	jmp	rinstr_done
#
#
# **************************
# *****  %_rinstri.vv  *****  RINSTRI(x$, y$, z)
# *****  %_rinstri.vs  *****
# *****  %_rinstri.sv  *****
# *****  %_rinstri.ss  *****
# **************************
#
# in:	arg2 = start position in x$ at which to begin search (one-biased)
#	arg1 -> y$: substring to search for
#	arg0 -> x$: string in which to search
# out:	eax = index (one-biased) of first char in y$ that was found in
#	      x$, or 0 if none were found
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> x$ if x$ needs to be freed on exit; else null pointer
#	[ebp-8] -> y$ if y$ needs to be freed on exit; else null pointer
#	[ebp-12] = return value
#	[ebp-16] = current offset in x$
#
# RINSTRI()'s search is case-insensitive.  A start position of 0 is treated
# the same as a start position of LEN(x$).  A start position greater
# than LEN(x$)is the same as LEN(x$).  If y$ is null or zero-length, RINSTRI()
# returns 0.
#
# RINSTRI() never generates a run-time error.
#
__rinstri.vv:
	xorl	%ebx,%ebx	#don't free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinstri.x
#
__rinstri.vs:
	xorl	%ebx,%ebx	#don't free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
	jmp	rinstri.x
#
__rinstri.sv:
	movl	4(%esp),%ebx	#free x$ on exit
	xorl	%ecx,%ecx	#don't free y$ on exit
	jmp	rinstri.x
#
__rinstri.ss:
	movl	4(%esp),%ebx	#free x$ on exit
	movl	8(%esp),%ecx	#free y$ on exit
#;
#; fall through
#;
rinstri.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$16,%esp
	movl	%ebx,-4(%ebp)	#save ptr to 1st string to free on exit
	cld
	movl	%ecx,-8(%ebp)	#save ptr to 2nd string to free on exit
	movl	$0,-12(%ebp)	#return value is zero until proven otherwise
# rule out cases that don't require searching
	movl	8(%ebp),%edi	#edi -> x$
	orl	%edi,%edi	#null pointer?
	jz	rinstri_done	#yes: can't find anything in null string
	movl	-8(%edi),%ecx	#ecx = LEN(x$)
	jecxz	rinstri_done	#same with zero-length string
	movl	16(%ebp),%eax	#eax = start position
	movl	12(%ebp),%esi	#esi -> y$
	orl	%esi,%esi	#null pointer?
	jz	rinstri_done	#yes: can't find a null string
	movl	-8(%esi),%edx	#edx = LEN(y$)
	orl	%edx,%edx	#zero length?
	jz	rinstri_done	#yes: can't find a zero-length string
	cmpl	%ecx,%edx	#LEN(y$) > LEN(x$)?
	ja	rinstri_done	#yes: can't find bigger string in smaller
# set up variables for loop
	subl	%edx,%ecx	#end of string = LEN(x$) - LEN(y$)# must not
	incl	%ecx	#make ecx one-biased
	orl	%eax,%eax	#start position is zero?
	jz	rinstri_skip2	#yes: default to end of string
	cmpl	%ecx,%eax	#start offset is beyond end of string?
	jna	rinstri_skip1	#no: start offset is ok
rinstri_skip2:
	movl	%ecx,%eax	#eax = LEN(x$): start search at end of string
rinstri_skip1:
	movl	%edi,%edx	#edx -> x$
	movl	$__lctouc,%ebx	#ebx -> lower- to upper-case conversion table
# loop through x$, comparing with y$ at each position until match is found
	decl	%eax	#past beginning of string?
	movl	%eax,-16(%ebp)	#store current position into memory variable
rinstri_loop:
	js	rinstri_done	#yes: no match
	leal	(%edx,%eax,1),%esi	#esi -> current position in x$
	movl	12(%ebp),%edi	#edi -> y$
	movl	-8(%edi),%ecx	#ecx = LEN(y$)
rinstri_inner_loop:
	lodsb		#al = char from x$
	xlat		#convert char from x$ to upper case
	movb	%al,%ah	#ah = upper-cased char from x$
	movb	(%edi),%al	#al = char from y$
	xlat		#convert char from y$ to upper case
	cmpb	%al,%ah	#upper-cased chars from x$ and y$ identical?
	jne	rinstri_nomatch	#no: try comparing at next char in x$
	incl	%edi	#bump pointer into y$
	decl	%ecx	#bump character counter
	jnz	rinstri_inner_loop	#test against next char in y$, if there
	jmp	rinstri_found	#there isn't one: we have a match
rinstri_nomatch:
	movl	-16(%ebp),%eax
	decl	%eax	#bump current-position counter
	movl	%eax,-16(%ebp)	#flags are tested at top of loop
	jmp	rinstri_loop
# free stack strings and exit
rinstri_done:
	movl	-4(%ebp),%esi	#esi -> x$ if x$ needs to be freed
	call	_____free
	movl	-8(%ebp),%esi	#esi -> y$ if y$ needs to be freed
	call	_____free
	movl	-12(%ebp),%eax	#eax = return value
	movl	%ebp,%esp
	popl	%ebp
	ret
rinstri_found:
	movl	-16(%ebp),%eax	#eax = current offset in x$
	incl	%eax	#convert zero-biased position to one-biased
	movl	%eax,-12(%ebp)	#save return value
	jmp	rinstri_done
#
#
# **************************
# *****  ns.convert.x  *****  generic string-to-number conversion routine
# **************************  internal entry point
#
# in:	arg0 -> string to convert
#	ebx -> string to free on exit, if any
#	ecx -> table of pointers to conversion routines
# out:	result is in eax, edx:eax, or st(0), depending on its type
#
# destroys: eax, ebx, ecx, edx, esi, edi (except for registers that
#					  contain return values)
# local variables:
#	[ebp-4] -> string to free on exit, if any
#	[ebp-8] -> table of pointers to conversion routines
#
# The tables to the pointers to conversion routines are documented
# later in this source file.
#
ns.convert.x:
	pushl	%ebp		# standard function entry
	movl	%esp,%ebp	#
	subl	$8,%esp		# create frame for 2 local variables
#
	movl	%ebx,-4(%ebp)	# save pointer to string to free on exit
	movl	%ecx,-8(%ebp)	# save pointer to table of conversion routines
#
	pushl	$0		# arg 6
	pushl	$0		# arg 5
	pushl	$0		# arg 4
	pushl	$0		# arg 3
	pushl	$0		# arg 2
	pushl	8(%ebp)		# arg 1 = numeric string address
#
	call	XstStringToNumber_24	# convert string to some type of number
#
	movl	-12(%esp),%ebx	# ebx = value type
	movl	-8(%esp),%ecx	# ecx = low 32-bits of value$$
	movl	-4(%esp),%edx	# edx = high 32-bits of value$$
#
	movl	-4(%ebp),%esi	# esi = string to free on exit if any
	call	_____free	# free numeric string if ".s" suffix
#
	xorl	%eax,%eax	# eax = index into pointer table for SLONG
	cmpl	$6,%ebx		# valueType == $$SLONG ???
	je	ns_nn_convert	# yes: convert it
#
	incl	%eax		# eax = index into pointer table for XLONG
	cmpl	$8,%ebx		# valueType == $$XLONG ???
	je	ns_nn_convert	# yes: convert it
#
	orl	%ebx,%ebx	# valueType == 0 ???  (invalid number)
	je	ns_nn_zero	# yes: return zero as XLONG
#
	incl	%eax		# eax = index into pointer table for GIANT
	cmpl	$12,%ebx	# valueType == $$GIANT ???
	je	ns_nn_convert	# yes: convert it
#
	incl	%eax		# eax = index into pointer table for SINGLE
	cmpl	$13,%ebx	# valueType == $$SINGLE ???
	je	ns_nn_convert	# yes: convert it
#
	incl	%eax		# eax = index into pointer table for DOUBLE
	cmpl	$14,%ebx	# valueType == $$DOUBLE ???
	je	ns_nn_convert	# yes: convert it
#
# error : return 0		# something very screwy here
#
	xorl	%ecx,%ecx	# set value$$ to zero
	xorl	%edx,%edx
	pushl	%edx		# pass edx:ecx to numeric-to-numeric conversion
	pushl	%ecx		# routine
	movl	-8(%ebp),%ebx	# ebx -> table of ptrs to conversion routines
	call	*(%ebx,%eax,4)	# call nn conversion routine
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeInternal	# return directly from there
#
ns_nn_zero:
	xorl	%ecx,%ecx	# set value$$ to zero
	xorl	%edx,%edx
ns_nn_convert:
	pushl	%edx		# pass edx:ecx to numeric-to-numeric conversion
	pushl	%ecx		#
	movl	-8(%ebp),%ebx	# ebx -> table of ptrs to conversion routines
	call	*(%ebx,%eax,4)	# call nn conversion routine
	movl	%ebp,%esp	#
	popl	%ebp		#
	ret			#
#
#	jmp, not call, for error handling
#	arg1 = edx	;assumes arg1 is available!!!
#	arg0 = ecx
#	Presumes calling routine creates 64 byte stack
#	  (eg	sub	esp,64
#		call	%cv.string.to.xlong.s
#		add	esp,64)
#
	movl	-8(%ebp),%ebx	# ebx -> table of pointers to conversion routines
	movl	%ebp,%esp	#
	popl	%ebp		#
	popl	%esi		# save return address
	movl	%edx,4(%esp)	# pass edx:ecx to numeric-to-numeric conversion
	movl	%ecx,(%esp)	# routine
	pushl	%esi		# restore return address
	jmp	*(%ebx,%eax,4)	# jmp to nn conversion routine
#				# result is now wherever it's supposed to be
#
# **************************************************
# *****  string-to-number conversion routines  *****
# **************************************************
#
# in:	arg0 -> string
# out:	result is in eax, edx:eax, or st(0), depending on its type
#
# destroys: eax, ebx, ecx, edx, esi, edi (except for registers that
#					  contain return values)
#
# All string-to-number conversion routines load up parameters for
# ns.convert.x and then branch to it.
#
__cv.string.to.sbyte.s:
	movl	4(%esp),%ebx
	movl	$to_sbyte,%ecx
	jmp	ns.convert.x
#
__cv.string.to.sbyte.v:
	xorl	%ebx,%ebx
	movl	$to_sbyte,%ecx
	jmp	ns.convert.x
#
__cv.string.to.ubyte.s:
	movl	4(%esp),%ebx
	movl	$to_ubyte,%ecx
	jmp	ns.convert.x
#
__cv.string.to.ubyte.v:
	xorl	%ebx,%ebx
	movl	$to_ubyte,%ecx
	jmp	ns.convert.x
#
__cv.string.to.sshort.s:
	movl	4(%esp),%ebx
	movl	$to_sshort,%ecx
	jmp	ns.convert.x
#
__cv.string.to.sshort.v:
	xorl	%ebx,%ebx
	movl	$to_sshort,%ecx
	jmp	ns.convert.x
#
__cv.string.to.ushort.s:
	movl	4(%esp),%ebx
	movl	$to_ushort,%ecx
	jmp	ns.convert.x
#
__cv.string.to.ushort.v:
	xorl	%ebx,%ebx
	movl	$to_ushort,%ecx
	jmp	ns.convert.x
#
__cv.string.to.slong.s:
	movl	4(%esp),%ebx
	movl	$to_slong,%ecx
	jmp	ns.convert.x
#
__cv.string.to.slong.v:
	xorl	%ebx,%ebx
	movl	$to_slong,%ecx
	jmp	ns.convert.x
#
__cv.string.to.ulong.s:
	movl	4(%esp),%ebx
	movl	$to_ulong,%ecx
	jmp	ns.convert.x
#
__cv.string.to.ulong.v:
	xorl	%ebx,%ebx
	movl	$to_ulong,%ecx
	jmp	ns.convert.x
#
__cv.string.to.xlong.s:
	movl	4(%esp),%ebx
	movl	$to_xlong,%ecx
	jmp	ns.convert.x
#
__cv.string.to.xlong.v:
	xorl	%ebx,%ebx
	movl	$to_xlong,%ecx
	jmp	ns.convert.x
#
__cv.string.to.giant.s:
	movl	4(%esp),%ebx
	movl	$to_giant,%ecx
	jmp	ns.convert.x
#
__cv.string.to.giant.v:
	xorl	%ebx,%ebx
	movl	$to_giant,%ecx
	jmp	ns.convert.x
#
__cv.string.to.single.s:
	movl	4(%esp),%ebx
	movl	$to_single,%ecx
	jmp	ns.convert.x
#
__cv.string.to.single.v:
	xorl	%ebx,%ebx
	movl	$to_single,%ecx
	jmp	ns.convert.x
#
__cv.string.to.double.s:
	movl	4(%esp),%ebx
	movl	$to_double,%ecx
	jmp	ns.convert.x
#
__cv.string.to.double.v:
	xorl	%ebx,%ebx
	movl	$to_double,%ecx
	jmp	ns.convert.x
#
#
# *******************************************************
# *****  TABLES OF POINTERS TO CONVERSION ROUTINES  *****
# *******************************************************
#
# Each table contains four pointers to conversion routines that convert a
# number to a single type T.  The four pointers, in the order in which
# they appear in each table, are to conversion routines to convert:
#
#	from SLONG to T
#	from XLONG to T
#	from GIANT to T
#	from SINGLE to T
#	from DOUBLE to T
#
.text
.align	8
to_sbyte:
.long	__cv.slong.to.sbyte
.long	__cv.xlong.to.sbyte
.long	__cv.giant.to.sbyte
.long	__cv.single.to.sbyte
.long	__cv.double.to.sbyte
to_ubyte:
.long	__cv.slong.to.ubyte
.long	__cv.xlong.to.ubyte
.long	__cv.giant.to.ubyte
.long	__cv.single.to.ubyte
.long	__cv.double.to.ubyte
to_sshort:
.long	__cv.slong.to.sshort
.long	__cv.xlong.to.sshort
.long	__cv.giant.to.sshort
.long	__cv.single.to.sshort
.long	__cv.double.to.sshort
to_ushort:
.long	__cv.slong.to.ushort
.long	__cv.xlong.to.ushort
.long	__cv.giant.to.ushort
.long	__cv.single.to.ushort
.long	__cv.double.to.ushort
to_slong:
.long	__cv.slong.to.slong
.long	__cv.xlong.to.slong
.long	__cv.giant.to.slong
.long	__cv.single.to.slong
.long	__cv.double.to.slong
to_ulong:
.long	__cv.slong.to.ulong
.long	__cv.xlong.to.ulong
.long	__cv.giant.to.ulong
.long	__cv.single.to.ulong
.long	__cv.double.to.ulong
to_xlong:
.long	__cv.slong.to.xlong
.long	__cv.xlong.to.xlong
.long	__cv.giant.to.xlong
.long	__cv.single.to.xlong
.long	__cv.double.to.xlong
to_giant:
.long	__cv.slong.to.giant
.long	__cv.xlong.to.giant
.long	__cv.giant.to.giant
.long	__cv.single.to.giant
.long	__cv.double.to.giant
to_single:
.long	__cv.slong.to.single
.long	__cv.xlong.to.single
.long	__cv.giant.to.single
.long	__cv.single.to.single
.long	__cv.double.to.single
to_double:
.long	__cv.slong.to.double
.long	__cv.xlong.to.double
.long	__cv.giant.to.double
.long	__cv.single.to.double
.long	__cv.double.to.double
#
#
#
.text
#
# ######################
# #####  xlibsn.s  #####  intrinsics that take numbers and return strings
# ######################
#
# ***********************
# *****  %_space.d  *****  SPACE$(x)
# ***********************
#
# in:	arg0 = number of spaces
# out:	eax -> string containing requested number of spaces
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__space.d:
	pushl	%ebp
	movl	%esp,%ebp
	pushl	8(%ebp)	#push number of spaces requested
	pushl	$' '	#push space character
	call	__chr.d	#eax -> result string
	addl	$8,%esp
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *********************
# *****  %_chr.d  *****  CHR$(x, y)
# *********************
#
# in:	arg1 = number of times to duplicate it
#	arg0 = ASCII code to duplicate
# out:	eax -> generated string
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__chr.d:
	pushl	%ebp
	movl	%esp,%ebp
	movl	12(%ebp),%esi	#esi = _ of times to duplicate char
	orl	%esi,%esi	#set flags
	jz	chr_null	#if zero, just return null pointer
	js	chr_IFC	#if less than zero, generate an error
	movl	8(%ebp),%ebx	#ebx = char to duplicate
	testl	$0xFFFFFF00,%ebx	#greater than 255?
	jnz	chr_IFC	#yes: generate error
	incl	%esi	#esi = _ of chars needed to hold string,
	call	_____calloc	#esi -> result string
	movl	12(%ebp),%ecx	#ecx = _ of times to duplicate it
	movl	%esi,%edi	#edi -> result string
	movl	%ecx,-8(%esi)	#store length of string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = system/user bit OR allocated-string info
	movl	%eax,-4(%esi)	#store info word
	cld
	movb	8(%ebp),%al	#al = char to duplicate
	rep
	stosb		#write them character!
	movl	%esi,%eax	#eax -> result string
	movl	%ebp,%esp
	popl	%ebp
	ret
chr_IFC:
	xorl	%eax,%eax	#return null pointer
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeIllegalFunctionCall	# Return from there
chr_null:
	xorl	%eax,%eax	#return null pointer
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# **********************
# *****  %_null.d  *****  NULL$(x)
# **********************
#
# in:	arg0 = number of nulls to put in result string
# out:	eax -> string containing requested number of nulls
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__null.d:
	pushl	%ebp
	movl	%esp,%ebp
	movl	8(%ebp),%esi	#esi = _ of times to duplicate char
	orl	%esi,%esi	#set flags
	jz	chr_null	#if zero, just return null pointer
	js	chr_IFC	#if less than zero, generate an error
	incl	%esi	#one more for null terminator, ha ha
	call	_____calloc	#esi -> result string
	movl	8(%ebp),%eax	#eax = requested number of nulls
	movl	%eax,-8(%esi)	#write length of result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = system/user bit OR allocated-string info
	movl	%eax,-4(%esi)	#write info word
	movl	%esi,%eax	#eax -> result string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_cstring.d  *****  CSTRING$(x$)
# *************************
#
# in:	arg0 -> string with no header info
# out:	eax -> copy of same string, with header info
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] = length of source string
#
# Result string's length is the number of non-null characters in the source
# string up to the first null.  Characters in the source string beyond the
# first null are not copied to the result string.
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__cstring.d:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
#
	movl	8(%ebp),%edi	#edi -> C string
	orl	%edi,%edi	#null pointer?
	jz	cstring_null	#yes: return null pointer
#
	movzbl	(%edi),%eax	#first byte = 0x00 ???
	orl	%eax,%eax	# test eax for zero
	jz	cstring_null	# first byte = 0x00 = empty string
#
	movl	$-1,%ecx	#search until we find zero byte or cause memory fault
	xorl	%eax,%eax	#search for a zero byte
	cld			#make sure we're going in the right direction
	repne
	scasb			#edi -> terminating null
#
	notl	%ecx		#ecx = length + 1
	movl	%ecx,-4(%ebp)	#save it
	movl	%ecx,%esi	#esi = length + 1 = size of copy
	call	_____calloc	#esi -> result string, w/ enough space for copy
#
	movl	-4(%ebp),%ecx	#ecx = length + 1
	leal	-1(%ecx),%ebx	#ebx = length not including terminating null
	movl	%ebx,-8(%esi)	#store length
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = system/user bit OR allocated-string info
	movl	%eax,-4(%esi)	#write info word
#
	movl	%esi,%eax	#eax -> result string
	movl	8(%ebp),%esi	#esi -> source string
	movl	%eax,%edi	#edi -> result string
	rep
	movsb		#copy source string to result string
#
	movl	%ebp,%esp
	popl	%ebp
	ret
#
cstring_null:
	xorl	%eax,%eax	#return null pointer
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***********************
# *****  %_error.d  *****  error$ = ERROR$(errorNumber)
# ***********************
#
__error.d:
	pushl	$0	# arg = error$ (by reference)
	pushl	%eax	# arg = error (error number)
	call	XstErrorNumberToName_8	# error number to name
	movl	-4(%esp),%eax	# error$
	ret
#
#
# ******************************
# *****  %_str.d.xlong     *****  STR$(x)
# *****  %_str.d.slong     *****
# *****  %_str.d.ulong     *****
# *****  %_str.d.goaddr    *****
# *****  %_str.d.subaddr   *****
# *****  %_str.d.funcaddr  *****
# ******************************
#
# in:	arg0 = number to convert to string
# out:	eax -> result string:	space is leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__str.d.ulong:
	movl	4(%esp),%esi	#esi = number to convert to string
push_space_ulong_x:
	pushl	$' '	#prefix must be space since ulong must be
call_ulong_x:			# positive
	pushl	%esi	#push number to convert to string
	call	str.ulong.x
	addl	$8,%esp
	ret
#
__str.d.slong:
__str.d.xlong:
__str.d.goaddr:
__str.d.subaddr:
__str.d.funcaddr:
	movl	4(%esp),%esi	#esi = number to convert to string
	orl	%esi,%esi	#is number positive?
	jns	push_space_ulong_x	#yes: prefix it with a space
	pushl	$'-'	#no: prefix it with a hyphen
	cmpl	$0x80000000,%esi	#is number lowest possible negative number?
	je	call_ulong_x	#yes: don't negate it
	negl	%esi	#make it positive
	jmp	call_ulong_x	#go convert it
#
#
# ****************************************************
# *****  %_string.xlong     %_string.d.xlong     *****
# *****  %_string.slong     %_string.d.slong     *****  STRING()  and  STRING$()
# *****  %_string.ulong     %_string.d.ulong     *****
# *****  %_string.goaddr    %_string.d.goaddr    *****
# *****  %_string.subaddr   %_string.d.subaddr   *****
# *****  %_string.funcaddr  %_string.d.funcaddr  *****
# ****************************************************
#
# in:	arg0 = number to convert to string
# out:	eax -> result string:	no leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__string.ulong:
__string.d.ulong:
	movl	4(%esp),%esi	#esi = number to convert to string
push_null_ulong_x:
	pushl	$0	#prefix must be null since ulong must be
string_call_ulong_x:		# positive
	pushl	%esi	#push number to convert
	call	str.ulong.x
	addl	$8,%esp
	ret
#
__string.slong:
__string.xlong:
__string.goaddr:
__string.subaddr:
__string.funcaddr:
__string.d.slong:
__string.d.xlong:
__string.d.goaddr:
__string.d.subaddr:
__string.d.funcaddr:
	movl	4(%esp),%esi	#esi = number to convert to string
	orl	%esi,%esi	#is number positive?
	jns	push_null_ulong_x	#yes: no prefix
	pushl	$'-'	#no: prefix it with a hyphen
	cmpl	$0x80000000,%esi	#is number lowest possible negative number?
	je	string_call_ulong_x	#yes: don't negate it
	negl	%esi	#make it positive
	jmp	string_call_ulong_x	#go convert it
#
#
# *********************************
# *****  %_signed.d.xlong     *****  SIGNED$ (xlong)
# *****  %_signed.d.slong     *****
# *****  %_signed.d.ulong     *****
# *****  %_signed.d.goaddr    *****
# *****  %_signed.d.subaddr   *****
# *****  %_signed.d.funcaddr  *****
# *********************************
#
# in:	arg0 = number to convert to string
# out:	eax -> result string:	plus sign is leading character if positive
#				hyphen is leading character if negative
#
# destroys: eax, ebx, ecx, edx, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__signed.d.ulong:
	movl	4(%esp),%esi	#esi = number to convert to string
push_plus_ulong_x:
	pushl	$'+'	#prefix must be plus since ulong must be
signed_call_ulong_x:		# positive
	pushl	%esi	#push number to convert
	call	str.ulong.x
	addl	$8,%esp
	ret
#
__signed.d.slong:
__signed.d.xlong:
__signed.d.goaddr:
__signed.d.subaddr:
__signed.d.funcaddr:
	movl	4(%esp),%esi	#esi = number to convert to string
	orl	%esi,%esi	#is number positive?
	jns	push_plus_ulong_x	#yes: prefix it with a plus sign
	pushl	$'-'	#no: prefix it with a hyphen
	cmpl	$0x80000000,%esi	#is number lowest possible negative number?
	je	signed_call_ulong_x	#yes: don't negate it
	negl	%esi	#make it positive
	jmp	signed_call_ulong_x	#go convert it
#
#
# *************************
# *****  str.ulong.x  *****  converts a positive number to a string
# *************************  internal common entry point
#
# in:	arg1 = prefix character, or 0 if no prefix
#	arg0 = number to convert to string
# out:	eax -> result string (prefix character is prepended to result string)
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> result string
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
str.ulong.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	$15,%esi	#get room for at least 15 bytes to hold result
	call	______calloc	#esi -> header of result string
	addl	$16,%esi	#esi -> result string
	movl	%esi,-4(%ebp)	#save it
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#info word indicates: allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	12(%ebp),%eax	#eax = prefix character
	orl	%eax,%eax	#a null?
	jz	ulong_no_prefix	#yes: don't prepend a prefix
	movb	%al,(%esi)	#no: store it
	incl	%esi	#esi -> character after prefix character
ulong_no_prefix:
	movl	8(%ebp),%eax	#eax = number to convert
	orl	%eax,%eax	#just converting a zero?
	jz	ulong_zero	#yes: skip time-consuming loop
	xorl	%ebx,%ebx	#ebx = offset into ulong_table = 0
	xorl	%edi,%edi	#edi = _ of digits generated so far = 0
	movl	ulong_table(,%ebx,4),%ecx	#ecx = current positional value
	movl	%eax,%edx	#edx = what's left of current number =
ulong_digit_loop:
	cmpl	%ecx,%eax	#zero at this digit?
	jb	ulong_zero_digit	#yes: skip division
	xorl	%edx,%edx	#clear upper 32 bits of dividend
	divl	%ecx	#eax = digit, edx = remainder = what's left
ulong_write_digit:
	addb	$'0',%al	#convert digit to ASCII
	movb	%al,(%esi,%edi,1)	#write current digit
	incl	%edi	#increment number of digits generated so far
ulong_next_digit:
	incl	%ebx	#increment offset into ulong_table
	movl	%edx,%eax	#eax = what's left of number
	movl	ulong_table(,%ebx,4),%ecx	#ecx = current positional value
	orl	%ecx,%ecx	#reached end of table (last digit)?
	jnz	ulong_digit_loop	#no: do another digit
ulong_done:
	movb	$0,(%esi,%edi,1)	#add null terminator
	movl	-4(%ebp),%eax	#eax -> start of result string
	leal	(%esi,%edi,1),%ebx	#ebx -> null terminator
	subl	%eax,%ebx	#ebx = true length of string
	movl	%ebx,-8(%eax)	#store length of result string
	movl	%ebp,%esp
	popl	%ebp
	ret
ulong_zero_digit:
	orl	%edi,%edi	#is current digit a leading zero?
	jz	ulong_next_digit	#yes: skip it
	xorl	%eax,%eax	#force current digit to zero
	jmp	ulong_write_digit
ulong_zero:			#result string is "0"
	movb	$'0',(%esi)	#store the zero digit
	movl	$1,%edi	#edi = length of string, not counting prefix
	jmp	ulong_done
#
#
# **********************
# *****  %_binb.d  *****  converts a ULONG to its binary representation
# **********************  and prepends "0b" to it
#
# in:	arg1 = minimum number of digits
#	arg0 = value to convert
# out:	eax -> string containing binary digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__binb.d:
	pushl	%ebp
	leal	-4(%esp),%ebp
	subl	$16,%esp
	movl	$0x6230,-8(%ebp)	#tell cvt32 to prepend "0b"
	movl	$bin.dword,-12(%ebp)	#convert into binary digits
	call	cvt32	#eax -> result string
	cmpl	$2,-8(%eax)	#length = 2?  I.e. string is nothing but "0b"?
	jne	binb_d_done	#no: done
	movb	$'0',2(%eax)	#append "0"
	movl	$3,-8(%eax)	#length = 3
binb_d_done:
	leal	4(%ebp),%esp
	popl	%ebp
	ret
#
#
# *********************
# *****  %_bin.d  *****  converts a ULONG to its binary representation
# *********************
#
# in:	arg1 = minimum number of digits
#	arg0 = value to convert
# out:	eax -> string containing binary digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__bin.d:
	pushl	%ebp
	leal	-4(%esp),%ebp
	subl	$16,%esp
	movl	$0,-8(%ebp)	#tell cvt32 to not prepend anything
	movl	$bin.dword,-12(%ebp)	#convert into binary digits
	call	cvt32	#eax -> result string
	cmpl	$0,-8(%eax)	#zero-length string?
	jnz	bin_d_done	#no: done
	movb	$'0',(%eax)	#create a "0" string
	movl	$1,-8(%eax)	#length is 1
bin_d_done:
	leal	4(%ebp),%esp
	popl	%ebp
	ret
#
#
# **********************
# *****  %_octo.d  *****  converts a ULONG to its octal representation
# **********************  and prepends "0o" to it
#
# in:	arg1 = minimum number of digits
#	arg0 = value to convert
# out:	eax -> string containing octal digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__octo.d:
	pushl	%ebp
	leal	-4(%esp),%ebp
	subl	$16,%esp
	movl	$0x6F30,-8(%ebp)	#tell cvt32 to prepend "0o"
	movl	$oct.dword,-12(%ebp)	#convert into octal digits
	movl	$oct_lsd_64,oct_shift	#we're only converting one dword
	movl	$0,oct_first	#no extra bit to OR into first digit
	call	cvt32	#eax -> result string
	cmpl	$2,-8(%eax)	#length = 2?  I.e. string is nothing but "0o"?
	jne	octo_d_done	#no: done
	movb	$'0',2(%eax)	#append "0"
	movl	$3,-8(%eax)	#length = 3
octo_d_done:
	leal	4(%ebp),%esp
	popl	%ebp
	ret
#
#
# *********************
# *****  %_oct.d  *****  converts a ULONG to its octal representation
# *********************
#
# in:	arg1 = minimum number of digits
#	arg0 = value to convert
# out:	eax -> string containing octal digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__oct.d:
	pushl	%ebp
	leal	-4(%esp),%ebp
	subl	$16,%esp
	movl	$0,-8(%ebp)	#tell cvt32 to not prepend anything
	movl	$oct.dword,-12(%ebp)	#convert into octal digits
	movl	$oct_lsd_64,oct_shift	#we're only converting one dword
	movl	$0,oct_first	#no extra bit to OR into first digit
	call	cvt32	#eax -> result string
	cmpl	$0,-8(%eax)	#zero-length string?
	jnz	oct_d_done	#no: done
	movb	$'0',(%eax)	#create a "0" string
	movl	$1,-8(%eax)	#length is 1
oct_d_done:
	leal	4(%ebp),%esp
	popl	%ebp
	ret
#
#
# **********************
# *****  %_hexx.d  *****  converts a ULONG to its hexadecimal representation
# **********************  and prepends "0x" to it
#
# in:	arg1 = minimum number of digits
#	arg0 = value to convert
# out:	eax -> string containing hex digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__hexx.d:
	pushl	%ebp
	leal	-4(%esp),%ebp
	subl	$16,%esp
	movl	$0x7830,-8(%ebp)	#tell cvt32 to prepend "0x"
	movl	$hex.dword,-12(%ebp)	#convert into hex digits
	call	cvt32	#eax -> result string
	cmpl	$2,-8(%eax)	#length = 2?  I.e. string is nothing but "0x"?
	jne	hexx_d_done	#no: done
	movb	$'0',2(%eax)	#append "0"
	movl	$3,-8(%eax)	#length = 3
hexx_d_done:
	leal	4(%ebp),%esp
	popl	%ebp
	ret
#
#
# *********************
# *****  %_hex.d  *****  converts a ULONG to its hexadecimal representation
# *********************
#
# in:	arg1 = minimum number of digits
#	arg0 = value to convert
# out:	eax -> string containing hex digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__hex.d:
	pushl	%ebp
	leal	-4(%esp),%ebp
	subl	$16,%esp
	movl	$0,-8(%ebp)	#tell cvt32 to not prepend anything
	movl	$hex.dword,-12(%ebp)	#convert into hex digits
	call	cvt32	#eax -> result string
	cmpl	$0,-8(%eax)	#zero-length string?
	jnz	hex_d_done	#no: done
	movb	$'0',(%eax)	#create a "0" string
	movl	$1,-8(%eax)	#length is 1
hex_d_done:
	leal	4(%ebp),%esp
	popl	%ebp
	ret
#
# *******************
# *****  cvt32  *****  converts a ULONG to hex, binary, or octal
# *******************  internal common entry point
#
# in:	arg2 = minimum number of digits
#	arg1 = number to convert
#	arg0 is ignored
#	[ebp-8] = two-byte string to prepend: 0x7830 = "0x"
#					      0x6F30 = "0o"
#					      0x6230 = "0b"
#					      0      = prepend nothing
#	[ebp-12] -> subroutine to call to generate digits (hex.dword,
#		    bin.dword, or oct.dword)
#
# out:	eax -> string containing ASCII representation of number
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to return
#	[ebp-8] = two-byte string to prepend or zero to prepend nothing
#	[ebp-12] -> subroutine to call to generate digits (hex.dword,
#		    bin.dword, or oct.dword)
#
# IMPORTANT: cvt32 assumes that its local stack frame has already been
# set up, but it frees the stack frame itself before exiting.  This permits
# cvt32's caller to set up [ebp-8] on entry, and then to simply jump
# to cvt32 rather than call, ax the local frame, and return.
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
# If value to convert is zero, nothing (except the prepended string)
# will be stored in the result string: i.e. no "0" will be written.
#
cvt32:
	movl	$70,%esi	#get 70 bytes for string (more than necessary)
	call	_____calloc	#esi -> string that will contain result
	movl	%esi,-4(%ebp)	#save it
	movl	__WHOMASK,%eax	#eax = system/user bit
	cld
	orl	$0x80130001,%eax	#info word indicates: allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,%edi	#edi -> result string
	movl	-8(%ebp),%eax	#eax = string to prepend
	orl	%eax,%eax	#nothing to prepend?
	jz	cvt32_convert	#yes
	stosw		#no: write prefix at beginning of string
cvt32_convert:
	movl	12(%ebp),%edx	#edx = value to convert
	movl	16(%ebp),%esi	#esi = minimum number of digits to output
	call	*-12(%ebp)	#generate ASCII representation of edx
cvt32_exit:
	movl	-4(%ebp),%eax	#eax -> result string
	subl	%eax,%edi	#edi = length of result string
	movl	%edi,-8(%eax)	#store length of result string
	ret
#
# ***********************
# *****  hex.dword  *****  converts a dword to hexadecimal representation
# ***********************  internal entry point
#
# in:	esi = minimum number of digits to output
#	edx = value to output
#	edi -> output buffer
# out:	edi -> char after last char output by hex.dword
#
# destroys: eax, ebx, ecx, edx, esi
#
# Output buffer is assumed to have enough space to hold all digits generated.
# Output string will contain more than esi characters if edx cannot
# be represented in esi characters.  If minimum number of digits is zero
# and the value to output is zero, no output will be generated.  No
# terminating null is appended to the output string.
#
hex.dword:
	movl	$hex_digits,%ebx	#ebx -> table of ASCII characters
	movl	$8,%ecx	#ecx = current digit
	cld
hd_loop_top:
	xorl	%eax,%eax
	shldl	$4,%edx,%eax	#shift next digit into al
	shll	$4,%edx	#shld should have done this
	cmpl	%esi,%ecx	#into range of mandatory digits? (i.e. print
	jbe	hd_output	#yes: print current char
	orb	%al,%al	#a non-zero digit before mandatory digits?
	jz	hd_loop_end	#no: skip this digit
	movl	$127,%esi	#yes: force all digits from here to print
hd_output:
	xlat		#al = ASCII representation of digit
	stosb		#put digit into buffer
hd_loop_end:
	decl	%ecx	#bump digit counter
	jnz	hd_loop_top	#keep going if haven't reached last digit
	ret
#
#
# ***********************
# *****  bin.dword  *****  converts a dword to binary representation
# ***********************  internal entry point
#
# in:	esi = minimum number of digits to output
#	edx = value to output
#	edi -> output buffer
# out:	edi -> char after last char output by bin.dword
#
# destroys: eax, ebx, ecx, edx, esi
#
# Output buffer is assumed to have enough space to hold all digits generated.
# Output string will contain more than esi characters if edx cannot
# be represented in esi characters.  If minimum number of digits is zero
# and the value to output is zero, no output will be generated.  No
# terminating null is appended to the output string.
#
bin.dword:
	movl	$hex_digits,%ebx	#ebx -> table of ASCII characters
	movl	$32,%ecx	#ecx = current digit = 32
	cld
bd_loop_top:
	xorl	%eax,%eax
	shll	$1,%edx	#move next digit (next bit, that is) into CF
	rcl	$1,%eax	#eax contains next digit
	cmpl	%esi,%ecx	#into range of mandatory digits? (i.e. print
	jbe	bd_output	#yes: print current char
	orb	%al,%al	#a non-zero digit before mandatory digits?
	jz	bd_loop_end	#no: skip this digit
	movl	$127,%esi	#yes: force all digits from here to print
bd_output:
	xlat		#al = ASCII representation of digit
	stosb		#put digit into buffer
bd_loop_end:
	decl	%ecx	#bump digit counter
	jnz	bd_loop_top	#keep going if haven't reached last digit
	ret
#
#
# ***********************
# *****  oct.dword  *****  converts a dword to octal representation
# ***********************  internal entry point
#
# in:	esi = minimum number of digits to output
#	edx = value to output
#	edi -> output buffer
#	[oct_shift] -> table of shift values
#	[oct_first] = value to add to first digit
# out:	edi -> char after last char output by oct.dword
#	[oct_first] = value of last digit, if last digit's shift value was 1
#	need some way to indicate that msd was non-zero
#
# destroys: eax, ebx, ecx, edx, esi
#
# local variables:
#	[ebp-4] = current digit (counts down)
#	[ebp-8] = current digit (counts up)
#
# Output buffer is assumed to have enough space to hold all digits generated.
# Output string will contain more than esi characters if edx cannot
# be represented in esi characters.  If minimum number of digits is zero
# and the value to output is zero, no output will be generated.  No
# terminating null is appended to the output string.
#
# On entry, [oct_shift] must point to either oct_msd_64 or oct_lsd_64
# according to whether oct.dword is being called on the most significant
# or least significant dword of a 64-bit number.  [oct_first] must
# equal zero when printing the msdw of a 64-bit number, and the value of
# the last bit of the msdw when printing the lsd.  On exit, when printing
# an msd, oct.dword sets [oct_first] to the value of the last bit, and
# does not generate a digit for this bit.  Oh, the complications of
# printing octal numbers...
#
oct.dword:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	movl	$hex_digits,%ebx	#ebx -> table of ASCII characters
	movl	$11,-4(%ebp)	#current digit (counting down) = 11
	cld
	xorl	%ecx,%ecx	#ecx = current digit (counting up) = 0
	movl	%ecx,-8(%ebp)	#save it
od_loop_top:
	movl	oct_shift,%eax	#eax -> shift table
	movb	(%eax,%ecx,1),%cl	#cl = _ of bits to shift for next digit
	orb	%cl,%cl	#zero?
	jz	od_exit	#yes: we're done
	xorl	%eax,%eax
	shldl	%cl,%edx,%eax	#shift bits for next digit into eax
	shll	%cl,%edx	#remove same bits from edx
	cmpb	$1,%cl	#shifted only one bit?
	jne	od_not_odd_bit	#no: it's a normal digit
	cmpl	$0,-8(%ebp)	#first digit?
	jne	od_odd_bit	#no: it's that irritating bit at the end
od_not_odd_bit:
	cmpl	$0,-8(%ebp)	#first digit?
	jne	od_not_first_digit
	orl	oct_first,%eax	#yes: OR in last bit from previous dword
od_not_first_digit:
	cmpl	%esi,-4(%ebp)	#into range of mandatory digits? (i.e. print
	jbe	od_output	#yes: print current char
	orb	%al,%al	#a non-zero digit before mandatory digits?
	jz	od_loop_end	#no: skip this digit
	movl	$127,%esi	#yes: force all digits from here to print
od_output:
	xlat		#al = ASCII representation of digit
	stosb		#put digit into buffer
od_loop_end:
	decl	-4(%ebp)	#bump falling digit counter
	incl	-8(%ebp)	#bump rising digit counter
	movl	-8(%ebp),%ecx	#ecx = rising digit counter
	jmp	od_loop_top	#go convert next digit, if any
od_exit:
	movl	$0,oct_first	#no extra bit for next time if we got here
	movl	%ebp,%esp
	popl	%ebp
	ret
od_odd_bit:			# of a 64-bit number
	shll	$2,%eax	#shift bit to where it attaches to next
	movl	%eax,oct_first	#save bit for next time
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***************************
# *****  %_hex.d.giant  *****  converts a giant to hexadecimal string
# ***************************
#
# in:	arg2 = minimum number of digits
#	arg1 = most significant dword of number to convert
#	arg0 = least significant dword of number to convert
# out:	eax -> string containing hex digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__hex.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$0,-8(%ebp)	#tell cvt32 to not prepend anything
	movl	$hex.dword,-12(%ebp)	#convert into hex digits
	movl	16(%ebp),%eax	#eax = requested number of digits
	movl	%eax,sn_save	#save eax someplace safe
	movl	$0,16(%ebp)	#print nothing if asked for <= 8 digits
	cmpl	$8,%eax	#requested more than 8 digits?
	jbe	hexg_msdword	#no: no change
	subl	$8,%eax	#yes: indicate _ of digits in ms dword
	movl	%eax,16(%ebp)
hexg_msdword:
	call	cvt32	#convert most significant dword
	movl	-8(%eax),%ebx	#ebx = length of string so far
	leal	(%eax,%ebx,1),%edi	#edi -> where to place second dword's digits
	movl	sn_save,%esi	#esi = minimum number of digits
	movl	8(%ebp),%edx	#edx = least significant dword
	movl	%eax,sn_save	#save eax someplace safe
	orl	%ebx,%ebx	#anything written to string?
	jz	hexg_lsdword	#no: skip
	movl	$127,%esi	#yes: do not suppress leading zeros
hexg_lsdword:
	call	hex.dword	#append second dword's hex digits to first's
	movl	sn_save,%eax	#eax -> result string
	subl	%eax,%edi	#edi = total length of string
	jnz	hexg_done	#if length is non-zero, done
	movl	$'0',(%eax)	#generate a "0" string
	incl	%edi	#length = 1
hexg_done:
	movl	%edi,-8(%eax)	#write length of string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ****************************
# *****  %_hexx.d.giant  *****  converts a giant to hexadecimal string
# ****************************  and prepend "0x"
#
# in:	arg2 = minimum number of digits
#	arg1 = most significant dword of number to convert
#	arg0 = least significant dword of number to convert
# out:	eax -> string containing hex digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__hexx.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$0x7830,-8(%ebp)	#tell cvt32 to prepend "0x"
	movl	$hex.dword,-12(%ebp)	#convert into hex digits
	movl	16(%ebp),%eax	#eax = requested number of digits
	movl	%eax,sn_save	#save eax someplace safe
	movl	$0,16(%ebp)	#print nothing if asked for <= 8 digits
	cmpl	$8,%eax	#requested more than 8 digits?
	jbe	hexxg_msdword	#no: no change
	subl	$8,%eax	#yes: indicate _ of digits in ms dword
	movl	%eax,16(%ebp)
hexxg_msdword:
	call	cvt32	#convert most significant dword
	movl	-8(%eax),%ebx	#ebx = length of string so far
	leal	(%eax,%ebx,1),%edi	#edi -> where to place second dword's digits
	movl	sn_save,%esi	#esi = minimum number of digits
	movl	8(%ebp),%edx	#edx = least significant dword
	movl	%eax,sn_save	#save eax someplace safe
	cmpl	$2,%ebx	#any digits written to string?
	jz	hexxg_lsdword	#no: skip
	movl	$127,%esi	#yes: do not suppress leading zeros
hexxg_lsdword:
	call	hex.dword	#append second dword's hex digits to first's
	movl	sn_save,%eax	#eax -> result string
	subl	%eax,%edi	#edi = total length of string
	cmpl	$2,%edi	#any digits written to string?
	jnz	hexxg_done	#if length is non-zero, done
	movl	$'0',2(%eax)	#generate a "0" string
	incl	%edi	#length = 3
hexxg_done:
	movl	%edi,-8(%eax)	#write length of string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***************************
# *****  %_bin.d.giant  *****  converts a giant to binary string
# ***************************
#
# in:	arg2 = minimum number of digits
#	arg1 = most significant dword of number to convert
#	arg0 = least significant dword of number to convert
# out:	eax -> string containing binary digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__bin.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$0,-8(%ebp)	#tell cvt32 to not prepend anything
	movl	$bin.dword,-12(%ebp)	#convert into binary digits
	movl	16(%ebp),%eax	#eax = requested number of digits
	movl	%eax,sn_save	#save eax someplace safe
	movl	$0,16(%ebp)	#print nothing if asked for <= 32 digits
	cmpl	$32,%eax	#requested more than 32 digits?
	jbe	bing_msdword	#no: no change
	subl	$32,%eax	#yes: indicate _ of digits in ms dword
	movl	%eax,16(%ebp)
bing_msdword:
	call	cvt32	#convert most significant dword
	movl	-8(%eax),%ebx	#ebx = length of string so far
	leal	(%eax,%ebx,1),%edi	#edi -> where to place second dword's digits
	movl	sn_save,%esi	#esi = minimum number of digits
	movl	8(%ebp),%edx	#edx = least significant dword
	movl	%eax,sn_save	#save eax someplace safe
	orl	%ebx,%ebx	#anything written to string?
	jz	bing_lsdword	#no: skip
	movl	$127,%esi	#yes: do not suppress leading zeros
bing_lsdword:
	call	bin.dword	#append second dword's binary digits to first's
	movl	sn_save,%eax	#eax -> result string
	subl	%eax,%edi	#edi = total length of string
	jnz	bing_done	#if length is non-zero, done
	movl	$'0',(%eax)	#generate a "0" string
	incl	%edi	#length = 1
bing_done:
	movl	%edi,-8(%eax)	#write length of string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ****************************
# *****  %_binb.d.giant  *****  converts a giant to binary string
# ****************************  and prepend "0x"
#
# in:	arg2 = minimum number of digits
#	arg1 = most significant dword of number to convert
#	arg0 = least significant dword of number to convert
# out:	eax -> string containing binary digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__binb.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$0x6230,-8(%ebp)	#tell cvt32 to prepend "0b"
	movl	$bin.dword,-12(%ebp)	#convert into binary digits
	movl	16(%ebp),%eax	#eax = requested number of digits
	movl	%eax,sn_save	#save eax someplace safe
	movl	$0,16(%ebp)	#print nothing if asked for <= 32 digits
	cmpl	$32,%eax	#requested more than 32 digits?
	jbe	binbg_msdword	#no: no change
	subl	$32,%eax	#yes: indicate _ of digits in ms dword
	movl	%eax,16(%ebp)
binbg_msdword:
	call	cvt32	#convert most significant dword
	movl	-8(%eax),%ebx	#ebx = length of string so far
	leal	(%eax,%ebx,1),%edi	#edi -> where to place second dword's digits
	movl	sn_save,%esi	#esi = minimum number of digits
	movl	8(%ebp),%edx	#edx = least significant dword
	movl	%eax,sn_save	#save eax someplace safe
	cmpl	$2,%ebx	#any digits written to string?
	jz	binbg_lsdword	#no: skip
	movl	$127,%esi	#yes: do not suppress leading zeros
binbg_lsdword:
	call	bin.dword	#append second dword's binary digits to first's
	movl	sn_save,%eax	#eax -> result string
	subl	%eax,%edi	#edi = total length of string
	cmpl	$2,%edi	#any digits written to string?
	jnz	binbg_done	#if length is non-zero, done
	movl	$'0',2(%eax)	#generate a "0" string
	incl	%edi	#length = 3
binbg_done:
	movl	%edi,-8(%eax)	#write length of string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***************************
# *****  %_oct.d.giant  *****  converts a giant to octal string
# ***************************
#
# in:	arg2 = minimum number of digits
#	arg1 = most significant dword of number to convert
#	arg0 = least significant dword of number to convert
# out:	eax -> string containing octal digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__oct.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$0,oct_first	#no carry-over bit in first dword
	movl	$oct_msd_64,oct_shift	#shift table for ms dword
	movl	$0,-8(%ebp)	#tell cvt32 to not prepend anything
	movl	$oct.dword,-12(%ebp)	#convert into octal digits
	movl	16(%ebp),%eax	#eax = requested number of digits
	movl	%eax,sn_save	#save eax someplace safe
	movl	$0,16(%ebp)	#print nothing if asked for <= 11 digits
	cmpl	$11,%eax	#requested more than 11 digits?
	jbe	octg_msdword	#no: no change
	subl	$11,%eax	#yes: indicate _ of digits in ms dword
	movl	%eax,16(%ebp)
octg_msdword:
	call	cvt32	#convert most significant dword
	movl	-8(%eax),%ebx	#ebx = length of string so far
	leal	(%eax,%ebx,1),%edi	#edi -> where to place second dword's digits
	movl	sn_save,%esi	#esi = minimum number of digits
	movl	8(%ebp),%edx	#edx = least significant dword
	movl	%eax,sn_save	#save eax someplace safe
	orl	%ebx,%ebx	#anything written to string?
	jz	octg_lsdword	#no: skip
	movl	$127,%esi	#yes: do not suppress leading zeros
octg_lsdword:
	movl	$oct_lsd_64,oct_shift	#shift table for ls dword
	call	oct.dword	#append second dword's octal digits to first's
	movl	sn_save,%eax	#eax -> result string
	subl	%eax,%edi	#edi = total length of string
	jnz	octg_done	#if length is non-zero, done
	movl	$'0',(%eax)	#generate a "0" string
	incl	%edi	#length = 1
octg_done:
	movl	%edi,-8(%eax)	#write length of string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ****************************
# *****  %_octo.d.giant  *****  converts a giant to octal string
# ****************************  and prepend "0x"
#
# in:	arg2 = minimum number of digits
#	arg1 = most significant dword of number to convert
#	arg0 = least significant dword of number to convert
# out:	eax -> string containing octal digits
#
# destroys: ebx, ecx, edx, esi, edi
#
__octo.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$0,oct_first	#no carry-over bit in first dword
	movl	$oct_msd_64,oct_shift	#shift table for ms dword
	movl	$0x6F30,-8(%ebp)	#tell cvt32 to prepend "0o"
	movl	$oct.dword,-12(%ebp)	#convert into oct digits
	movl	16(%ebp),%eax	#eax = requested number of digits
	movl	%eax,sn_save	#save eax someplace safe
	movl	$0,16(%ebp)	#print nothing if asked for <= 11 digits
	cmpl	$11,%eax	#requested more than 11 digits?
	jbe	octog_msdword	#no: no change
	subl	$11,%eax	#yes: indicate _ of digits in ms dword
	movl	%eax,16(%ebp)
octog_msdword:
	call	cvt32	#convert most significant dword
	movl	-8(%eax),%ebx	#ebx = length of string so far
	leal	(%eax,%ebx,1),%edi	#edi -> where to place second dword's digits
	movl	sn_save,%esi	#esi = minimum number of digits
	movl	8(%ebp),%edx	#edx = least significant dword
	movl	%eax,sn_save	#save eax someplace safe
	cmpl	$2,%ebx	#any digits written to string?
	jz	octog_lsdword	#no: skip
	movl	$127,%esi	#yes: do not suppress leading zeros
octog_lsdword:
	movl	$oct_lsd_64,oct_shift	#shift table for ls dword
	call	oct.dword	#append second dword's octal digits to first's
	movl	sn_save,%eax	#eax -> result string
	subl	%eax,%edi	#edi = total length of string
	cmpl	$2,%edi	#any digits written to string?
	jnz	octog_done	#if length is non-zero, done
	movl	$'0',2(%eax)	#generate a "0" string
	incl	%edi	#length = 3
octog_done:
	movl	%edi,-8(%eax)	#write length of string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***************************
# *****  %_str.d.giant  *****  STR$(giant)
# ***************************
#
# in:	arg1:arg0 = number to convert to string
# out:	eax -> result string:	space is leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__str.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	movl	$'-',%eax	#prefix with hyphen if negative
	movl	12(%ebp),%ebx	#ebx = most significant dword
	orl	%ebx,%ebx	#negative?
	js	str_giant_cvt	#yes: leave prefix character alone
	movl	$' ',%eax	#prefix with space if positive or zero
str_giant_cvt:
	pushl	%eax	#push prefix character
	pushl	%ebx	#push most significant dword
	pushl	8(%ebp)	#push least significant dword
	call	giant.decimal	#convert to decimal string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ****************************
# *****  %_string.giant  *****  STRING(giant)  and  STRING$(giant)
# ****************************
#
# in:	arg1:arg0 = number to convert to string
# out:	eax -> result string:	no leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__string.giant:
__string.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	movl	$'-',%eax	#prefix with hyphen if negative
	movl	12(%ebp),%ebx	#ebx = most significant dword
	orl	%ebx,%ebx	#negative?
	js	string_giant_cvt	#yes: leave prefix character alone
	subl	$'-',%eax	#prefix with nothing if positive or zero
string_giant_cvt:
	pushl	%eax	#push prefix character
	pushl	%ebx	#push most significant dword
	pushl	8(%ebp)	#push least significant dword
	call	giant.decimal	#convert to decimal string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ******************************
# *****  %_signed.d.giant  *****  SIGNED$(giant)
# ******************************
#
# in:	arg1:arg0 = number to convert to string
# out:	eax -> result string:	plus sign is leading character if positive
#				hyphen is leading character if negative
#
# destroys: eax, ebx, ecx, edx, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__signed.d.giant:
	pushl	%ebp
	movl	%esp,%ebp
	movl	$'-',%eax	#prefix with hyphen if negative
	movl	12(%ebp),%ebx	#ebx = most significant dword
	orl	%ebx,%ebx	#negative?
	js	signed_giant_cvt	#yes: leave prefix character alone
	movl	$'+',%eax	#prefix with plus sign if positive or zero
signed_giant_cvt:
	pushl	%eax	#push prefix character
	pushl	%ebx	#push most significant dword
	pushl	8(%ebp)	#push least significant dword
	call	giant.decimal	#convert to decimal string
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***************************
# *****  giant.decimal  *****  converts positive GIANT to decimal string
# ***************************
#
# in:	arg2 = prefix character, or 0 if no prefix
#	arg1:arg0 = number to convert to string
# out:	eax -> result string (prefix character is prepended to result string)
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> result string
#	[ebp-8] = pointer to next char in result string
#	[ebp-12] = leading-zero flag: != 0 if at least one digit has been
#		   printed
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
giant.decimal:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	$30,%esi	#get room for at least 30 bytes to hold result
	call	______calloc	#esi -> header of result string
	addl	$16,%esi	#esi -> result string
	movl	%esi,-4(%ebp)	#save it
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#info word indicates: allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,%edi	#edi -> result string
	movl	16(%ebp),%eax	#eax = prefix character
	orl	%eax,%eax	#a null?
	jz	gd_make_abs	#yes: don't prepend a prefix
	stosb		#no: store it
gd_make_abs:			#make absolute-value copy of number to convert
	movl	12(%ebp),%edx	#edx = ms dword of number to convert
	movl	8(%ebp),%eax	#eax = ls dword of number to convert
	orl	%edx,%edx	#negative?
	jns	gd_not_negative	#no: don't negate it
	orl	%eax,%eax	#but don't negate 0x8000000000000000
	jnz	gd_negate
	cmpl	$0x80000000,%edx
	je	gd_not_negative
gd_negate:
	notl	%edx
	negl	%eax
	sbbl	$-1,%edx	#edx:eax = ABS(original number)
gd_not_negative:
	orl	%edx,%edx	#ms dword is zero?
	jnz	gd_ms_not_zero	#no: have to do some honest work
	cmpl	%edx,%eax	#yes: is ls half zero, too?
	jz	gd_zero	#yes: just make a "0" string
gd_ls_not_zero:
	bsrl	%eax,%ecx	#find highest one bit in ls half of giant
	jmp	gd_go
gd_ms_not_zero:
	bsrl	%edx,%ecx	#find highest one bit in ms half of giant
	addl	$32,%ecx	#eax is index into gd_start_digits
gd_go:
	movl	$0,-12(%ebp)	#clear leading-zero flag (ecx from now on)
	movzbl	gd_start_digits(%ecx),%ecx	#ecx = index into gd_table
	leal	gd_table(,%ecx,8),%esi	#esi -> 1st power of ten
	movl	%edi,-8(%ebp)	#save pointer to next char in result string
gd_digit_loop:
	xorl	%edi,%edi	#current digit = 0
	movl	(%esi),%ebx
	movl	4(%esi),%ecx	#ecx:ebx = current power of ten
gd_subtract_loop:
	cmpl	%ecx,%edx	#compare most significant halves: n - p10
	jb	gd_got_digit	#n < p10: current digit is correct
	ja	gd_next_subtract	#n > p10: keep subtracting
	cmpl	%ebx,%eax	#compare least significant halves: n - p10
	jb	gd_got_digit	#n < 10: current digit is correct
gd_next_subtract:
	subl	%ebx,%eax
	sbbl	%ecx,%edx	#n -= p10
	incl	%edi	#bump digit counter
	jmp	gd_subtract_loop
gd_got_digit:
	orl	%edi,%edi	#digit is zero?
	jnz	gd_output_digit	#no: output it unconditionally
	cmpl	$0,-12(%ebp)	#has anything been output yet?
	jz	gd_next_digit	#no: this is a leading zero, so skip it
gd_output_digit:
	movl	-8(%ebp),%ebx	#ebx -> next char of result string
	leal	'0'(%edi),%ecx	#convert digit to ASCII
	movb	%cl,(%ebx)	#write digit to result string
	incl	%ebx	#bump pointer into result string
	movl	%ebx,-8(%ebp)	#save pointer into result string
	movl	$1,-12(%ebp)	#mark that at least one digit has been output
gd_next_digit:
	subl	$8,%esi	#esi -> next lower power of ten
	cmpl	$gd_table,%esi	#backed up past beginning of table?
	jae	gd_digit_loop	#no: do next digit
	movl	%ebx,%edi	#edi -> next char in result string
gd_done:
	xorb	%al,%al
	stosb		#append null terminator
	movl	-4(%ebp),%eax	#eax -> result string
	subl	%eax,%edi	#edi = LEN(result string) + 1
	decl	%edi	#edi = LEN(result string)
	movl	%edi,-8(%eax)	#store length of result string
	movl	%ebp,%esp
	popl	%ebp
	ret
gd_zero:			#just generate "0" string
	movb	$'0',%al
	stosb		#write '0' after prefix
	jmp	gd_done
#
#
# ****************************
# *****  %_str.d.double  *****  STR$(x)
# ****************************
#
# in:	arg1:arg0 = number to convert to string
# out:	eax -> result string:	space is leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__str.d.double:
	fldl	4(%esp)	#get number to convert to string
	fxam		#test against zero
	.byte	0x9b,0xdf,0xe0	#C1 bit = sign bit
	testb	$2,%ah	#copy C1 bit to zero bit (inverted)
	fabs		#float.string expects a positive number
	movl	$'-',%eax	#preload with leading minus sign
	jnz	str_double_prefix	#if negative, minus sign is correct
	movl	$' ',%eax	#nope, number needs leading space
str_double_prefix:
	pushl	%eax	#push leading character
	pushl	$'d'	#push exponent letter
	pushl	$15	#push maximum number of digits
	call	float.string	#eax -> result string
	addl	$12,%esp
	ret
#
#
# ****************************
# *****  %_str.d.single  *****  STR$(x)
# ****************************
#
# in:	arg0 = number to convert to string
# out:	eax -> result string:	space is leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__str.d.single:
	flds	4(%esp)	#get number to convert to string
	fxam		#test against zero
	.byte	0x9b,0xdf,0xe0	#C1 bit = sign bit
	testb	$2,%ah	#copy C1 bit to zero bit (inverted)
	fabs		#float.string expects a positive number
	movl	$'-',%eax	#preload with leading minus sign
	jnz	str_single_prefix	#if negative, minus sign is correct
	movl	$' ',%eax	#nope, number needs leading space
str_single_prefix:
	pushl	%eax	#push leading character
	pushl	$'e'	#push exponent letter
	pushl	$7	#push maximum number of digits
	call	float.string	#eax -> result string
	addl	$12,%esp
	ret
#
#
# *******************************
# *****  %_string.d.double  *****  STRING(x)
# *******************************
#
# in:	arg1:arg0 = number to convert to string
# out:	eax -> result string:	no leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__string.double:
__string.d.double:
	fldl	4(%esp)	#get number to convert to string
	fxam		#test against zero
	.byte	0x9b,0xdf,0xe0	#C1 bit = sign bit
	testb	$2,%ah	#copy C1 bit to zero bit (inverted)
	fabs		#float.string expects a positive number
	movl	$'-',%eax	#preload with leading minus sign
	jnz	string_double_prefix	#if negative, minus sign is correct
	xorl	%eax,%eax	#nope, number gets no leading char
string_double_prefix:
	pushl	%eax	#push leading character
	pushl	$'d'	#push exponent letter
	pushl	$15	#push maximum number of digits
	call	float.string	#eax -> result string
	addl	$12,%esp
	ret
#
#
# *******************************
# *****  %_string.d.single  *****  STR$(x)
# *******************************
#
# in:	arg0 = number to convert to string
# out:	eax -> result string:	no leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__string.single:
__string.d.single:
	flds	4(%esp)	#get number to convert to string
	fxam		#test against zero
	.byte	0x9b,0xdf,0xe0	#C1 bit = sign bit
	testb	$2,%ah	#copy C1 bit to zero bit (inverted)
	fabs		#float.string expects a positive number
	movl	$'-',%eax	#preload with leading minus sign
	jnz	string_single_prefix	#if negative, minus sign is correct
	xorl	%eax,%eax	#nope, number gets no leading char
string_single_prefix:
	pushl	%eax	#push leading character
	pushl	$'e'	#push exponent letter
	pushl	$7	#push maximum number of digits
	call	float.string	#eax -> result string
	addl	$12,%esp
	ret
#
#
# *******************************
# *****  %_signed.d.double  *****  STR$(x)
# *******************************
#
# in:	arg1:arg0 = number to convert to string
# out:	eax -> result string:	plus sign is leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__signed.d.double:
	fldl	4(%esp)	#get number to convert to string
	fxam		#test against zero
	.byte	0x9b,0xdf,0xe0	#C1 bit = sign bit
	testb	$2,%ah	#copy C1 bit to zero bit (inverted)
	fabs		#float.string expects a positive number
	movl	$'-',%eax	#preload with leading minus sign
	jnz	signed_double_prefix	#if negative, minus sign is correct
	movl	$'+',%eax	#nope, number needs leading plus sign
signed_double_prefix:
	pushl	%eax	#push leading character
	pushl	$'d'	#push exponent letter
	pushl	$15	#push maximum number of digits
	call	float.string	#eax -> result string
	addl	$12,%esp
	ret
#
#
# *******************************
# *****  %_signed.d.single  *****  STR$(x)
# *******************************
#
# in:	arg0 = number to convert to string
# out:	eax -> result string:	plus sign is leading character if positive
#				hyphen is leading character if negative
#
# destroys: ebx, ecx, edx, esi, edi
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
__signed.d.single:
	flds	4(%esp)	#get number to convert to string
	fxam		#test against zero
	.byte	0x9b,0xdf,0xe0	#C1 bit = sign bit
	testb	$2,%ah	#copy C1 bit to zero bit (inverted)
	fabs		#float.string expects a positive number
	movl	$'-',%eax	#preload with leading minus sign
	jnz	signed_single_prefix	#if negative, minus sign is correct
	movl	$'+',%eax	#nope, number needs leading plus sign
signed_single_prefix:
	pushl	%eax	#push leading character
	pushl	$'e'	#push exponent letter
	pushl	$7	#push maximum number of digits
	call	float.string	#eax -> result string
	addl	$12,%esp
	ret
#
#
# **************************
# *****  float.string  *****  creates decimal representation of st(0)
# **************************
#
# in:	st(0) = number to convert to string; MUST BE POSITIVE!
#	arg2 = prefix character, or 0 if no prefix character
#	arg1 = letter for exponent of scientific notation necessary
#	arg0 = maximum number of digits
# out:	eax -> result string (prefix character is prepended to result string)
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> result string
#	[ebp-8]:[ebp-12] input number (double precision)
#	[ebp-16] = current digit
#	[ebp-20] = flag: do zeros get printed? (are we past leading zeros?)
#	[ebp-24] = exponent to print at end (if scientific notation)
#	[ebp-28] = FPU control-word buffer
#	[ebp-32] = on-entry FPU control word
#
# Result string is dynamically allocated; freeing it is the caller's
# responsibility.
#
# Result string is in scientific notation if:
#
#	number > 100000, or
#	number < 0.00001
#
float.string:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$32,%esp
	movl	$30,%esi	#get room for at least 30 bytes to hold result
	call	______calloc	#esi -> header of result string
	addl	$16,%esi	#esi -> result string
	movl	%esi,-4(%ebp)	#save it
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#info word indicates: allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,%edi	# edi=esi  (max added fix for STRING$(+value) 05/15/93)
	movl	16(%ebp),%eax	#eax = prefix character
	orl	%eax,%eax	#a null?
	jz	float_prefix_done	#yes: don't prepend a prefix
	movb	%al,(%esi)	#no: store it
	leal	1(%esi),%edi	#edi -> character after prefix character
float_prefix_done:
	fnstcw	-28(%ebp)	#get current control word
	movw	-28(%ebp),%bx	#bx = control word
	movw	%bx,-32(%ebp)	#save original control word
	orw	$0x0C00,%bx	#set rounding mode to: truncate
	movw	%bx,-28(%ebp)	#[ebp-28] = new control word
	fldcw	-28(%ebp)	#truncation is on
	fxam		#what sort of number is st(0)?
	.byte	0x9b,0xdf,0xe0
	andb	$0b01000101,%ah	#mask out all but C3, C2, and C0
	movzb	%ah,%ebx	#build index into jump table in ebx
	shrb	$5,%ah	#shift C3 bit in between C2 and C0
	orb	%ah,%bl	#copy C3 bit into ebx
	andl	$0b111,%ebx	#just the lower three bits now
	jmp	*fxam_table(,%ebx,4)	#go to float_normal, float_zero,
#
float_normal:			#we have ourselves a non-zero number to print
	fstl	-12(%ebp)	#put input number into memory...
	movl	$0,-20(%ebp)	#mark that leading zeros don't get printed
	xorl	%edx,%edx	#clear digit counter
	fwait
	movl	-8(%ebp),%ebx	#...so we can
	shrl	$20,%ebx	#extract its exponent
	imul	$0x4CC,%ebx	#multiply exponent by .3 of 0x1000
	shrl	$12,%ebx	#div by 0x1000: ebx = exponent * 0.3
	addl	$3,%ebx	#ebx = index into __pwr_10_table
	fcoml	hundred_thousand
	.byte	0x9b,0xdf,0xe0	#greater than or equal to 100000 requires
	sahf			# scientific notation
	jae	float_scientific
	fcoml	hundred_thousandth
	.byte	0x9b,0xdf,0xe0	#less than .00001 requires
	sahf			# scientific notation
	jb	float_scientific
	movl	$0,-24(%ebp)	#do not output trailing exponent

	movl	$0, %eax	# number not normalized.
	cmpl	$307,%ebx	#is 1 > number > 0?
	ja	float_normalized	#no: it's okay already
	movl	$307,%ebx	#yes: start output at tenths digit
float_normalized:
	movl	%ebx,%esi
	subl	8(%ebp),%esi	#esi -> pwr of 10 of (non-)digit to right of
	jns	float_round
	xorl	%esi,%esi	#if before beginning of table, point to 10^-308
	jmp	float_round_done
float_round:
	fldl	__pwr_10_table(,%esi,8)
	fldl	ffive
	fmulp		#multiply digit past last possible digit by 5
	faddp		#round off number to maximum possible digits
	incl	%esi	#esi -> pwr of 10 of last possible digit

	cmpl	$0,%eax		# Skip 'colon' fix if number is not normalized.
	je	float_round_done

	fcoml	__pwr_10_to_0+8	# compare to 10#
	fstsw	%ax
	sahf
	jb	float_round_done	# jump if number is still less than 10#
	fdivl	__pwr_10_to_0+8	# divide normalized number by 10#
	incl	-24(%ebp)	# inc exponent
float_round_done:
fl_normal_loop:
	cmpl	$307,%ebx	#just crossed over into decimal land?
	jne	fl_digit	#nope
	movb	$'.',%al	#yep: output decimal point
	stosb
	movl	$1,-20(%ebp)	#mark that zeros now get printed
fl_digit:
	fld	%st(0)		#save current number to st(1)
	fdivl	__pwr_10_table(,%ebx,8)	#div by current power of ten
	frndint			#truncate to get current digit
	fistl	-16(%ebp)	#write current digit to memory, and hold
	fwait
	movb	-16(%ebp),%al	#al = current digit
	orb	%al,%al		#a zero?
	jnz	fl_normal_digit	#no: output it unconditionally
	cmpl	$0,-20(%ebp)	#are we past leading zeros?
	jz	fl_normal_digit_done	#no: move on to next digit
fl_normal_digit:
	addb	$'0',%al	#convert digit to ASCII
	stosb			#append it to result string
	incl	%edx		#bump digit counter
	movl	$1,-20(%ebp)	#mark that we're past leading zeros
fl_normal_digit_done:
	fmull	__pwr_10_table(,%ebx,8)	#digit * power of ten
	fwait		#DEBUG
	fwait		#DEBUG
	fwait		#DEBUG
	fsubrp		#st(0) = what's left
	fwait		#DEBUG
	fwait		#DEBUG
	fwait		#DEBUG
	fldl	__pwr_10_table(,%esi,8)	#value of least significant
	fcomp	%st(1)		#anything other than trailing zeros left
	.byte	0x9b,0xdf,0xe0	# to print?
	sahf
	ja	fl_normal_zero	#no: print trailing zeros
	decl	%ebx		#bump current power of ten
	cmpl	8(%ebp),%edx	#reached maximum number of digits?
	jae	float_exponent	#yes
	jmp	fl_normal_loop
fl_normal_zero:			#number is down to zero (or close enough)
	cmpl	$308,%ebx	#any trailing zeros to print?
	jbe	float_exponent	#no
	movb	$'0',(%edi)	#yes: print one
	incl	%edi
	decl	%ebx	#next power of ten
	jmp	fl_normal_zero
float_scientific:		#print a number with an exponent at the end
fl_find_1st_digit_loop:
	fcoml	__pwr_10_table(,%ebx,8)	#number is >=
	.byte	0x9b,0xdf,0xe0	# current power of ten?
	sahf
	jae	fl_got_first_digit
	decl	%ebx	#next lower power of ten
	cmpl	$-308,%ebx	#past end of table?
	jl	float_zero	#yes: it's zero for all practical purposes
	jmp	fl_find_1st_digit_loop
fl_got_first_digit:
	leal	-308(%ebx),%ecx	#ecx = exponent to append to number
	movl	%ecx,-24(%ebp)	#save it
	negl	%ecx	#ecx = offset relative to __pwr_10_to_0 of
	fmull	__pwr_10_to_0(,%ecx,8)	#normalize number
	fwait		#DEBUG
	fwait		#DEBUG
	fwait		#DEBUG
	movl	$-1,%eax	# numbers is normalized.
	movl	$308,%ebx	#ebx = offset for 10^0
	jmp	float_normalized	#output the number# it should now be in
float_exponent:			#just finished printing mantissa
	movl	-24(%ebp),%ecx	#ecx = exponent
	orl	%ecx,%ecx	#need to print any exponent at all?
	jz	float_done	#nope
	movb	12(%ebp),%al	#al = exponent letter ('e' or 'd')
	stosb			#append it to result string
	movb	$'+',%al	#pre-load with plus sign
	jns	fl_exp_sign	#yes: plus sign is correct
	movb	$'-',%al	#no: minus sign for negative exponent
	negl	%ecx		#and now force exponent positive
fl_exp_sign:
	stosb			#append sign to result string
	movl	%ecx,%eax	#eax = exponent
	movl	$100,%ecx
	cmpl	%ecx,%eax	#exponent has three digits?
	jb	fl_exp_two_digits	#no: maybe it has two digits
	xorl	%edx,%edx	#clear high 32 bits of numerator
	idiv	%ecx	#eax = _ of hundreds, edx = what's left
	addl	$'0',%eax	#convert to ASCII
	stosb			#append hundreds digit to result string
	movl	%edx,%eax	#eax = what's left of exponent
	movl	$10,%ecx
	jmp	fl_exp_tens_digit
#
fl_exp_two_digits:
	movl	$10,%ecx
	cmpl	%ecx,%eax	#exponent has two digits?
	jb	fl_exp_last_digit	#no: only one digit
#;
fl_exp_tens_digit:
	xorl	%edx,%edx	#clear high 32 bits of numerator
	idiv	%ecx	#eax = _ of tens, edx = units
	addl	$'0',%eax	#convert to ASCII
	stosb		#append tens digit to result string
	movl	%edx,%eax	#eax = units
fl_exp_last_digit:
	addl	$'0',%eax	#convert to ASCII
	stosb		#append units digit to result string
	jmp	float_done
#
float_nan:
	movb	$'N',%al	#just send "NAN" to result string
	stosb
	movb	$'A',%al
	stosb
	movb	$'N',%al
	stosb
	jmp	float_done
#
float_infinity:
	movb	$'i',%al	#just send "inf" to result string
	stosb
	movb	$'n',%al
	stosb
	movb	$'f',%al
	stosb
	jmp	float_done
#
float_zero:			#just send "0" to result string
	movb	$'0',%al
	stosb
#;
#; fall through
#;
float_done:			#assumes edi -> char after last char of result
	fstp	%st(0)	#pop input number# clear FPU stack
	movl	%edi,%esi	#esi also -> char after last char
	movl	-4(%ebp),%eax	#eax -> result string
	subl	%eax,%esi	#esi = LEN(result string)
	movl	%esi,-8(%eax)	#save string length
	movb	$0,(%edi)	#write terminating null
	fldcw	-32(%ebp)	#restore on-entry rounding mode
	movl	%ebp,%esp
	popl	%ebp
	ret		#return with eax -> result string
#
#
#
.align	8
ulong_table:			#table of values for each decimal digit
.long	1000000000	# read by str.ulong.x
.long	100000000
.long	10000000
.long	1000000
.long	100000
.long	10000
.long	1000
.long	100
.long	10
.long	1
.long	0		#zero indicates end of list
#
.align	8
hex_digits:			#table of digits read by hex.dword and bin.dword
.string	"0123456789ABCDEF"
#
.text
.align	8
gd_start_digits:	#indexes into gd_table according to the position
.byte	0		# bit 00: highest possible MSD for 0x00000001 LSW
.byte	0		# bit 01: highest possible MSD for 0x00000003 LSW
.byte	0		# bit 02: highest possible MSD for 0x00000007 LSW
.byte	1		# bit 03: highest possible MSD for 0x0000000F LSW
.byte	1		# bit 04: highest possible MSD for 0x0000001F LSW
.byte	1		# bit 05: highest possible MSD for 0x0000003F LSW
.byte	2		# bit 06: highest possible MSD for 0x0000007F LSW
.byte	2		# bit 07: highest possible MSD for 0x000000FF LSW
.byte	2		# bit 08: highest possible MSD for 0x000001FF LSW
.byte	3		# bit 09: highest possible MSD for 0x000003FF LSW
.byte	3		# bit 10: highest possible MSD for 0x000007FF LSW
.byte	3		# bit 11: highest possible MSD for 0x00000FFF LSW
.byte	3		# bit 12: highest possible MSD for 0x00001FFF LSW
.byte	4		# bit 13: highest possible MSD for 0x00003FFF LSW
.byte	4		# bit 14: highest possible MSD for 0x00007FFF LSW
.byte	4		# bit 15: highest possible MSD for 0x0000FFFF LSW
.byte	5		# bit 16: highest possible MSD for 0x0001FFFF LSW
.byte	5		# bit 17: highest possible MSD for 0x0003FFFF LSW
.byte	5		# bit 18: highest possible MSD for 0x0007FFFF LSW
.byte	6		# bit 19: highest possible MSD for 0x000FFFFF LSW
.byte	6		# bit 20: highest possible MSD for 0x001FFFFF LSW
.byte	6		# bit 21: highest possible MSD for 0x003FFFFF LSW
.byte	6		# bit 22: highest possible MSD for 0x007FFFFF LSW
.byte	7		# bit 23: highest possible MSD for 0x00FFFFFF LSW
.byte	7		# bit 24: highest possible MSD for 0x01FFFFFF LSW
.byte	7		# bit 25: highest possible MSD for 0x03FFFFFF LSW
.byte	8		# bit 26: highest possible MSD for 0x07FFFFFF LSW
.byte	8		# bit 27: highest possible MSD for 0x0FFFFFFF LSW
.byte	8		# bit 28: highest possible MSD for 0x1FFFFFFF LSW
.byte	9		# bit 29: highest possible MSD for 0x3FFFFFFF LSW
.byte	9		# bit 30: highest possible MSD for 0x7FFFFFFF LSW
.byte	9		# bit 31: highest possible MSD for 0xFFFFFFFF LSW
.byte	9		# bit 32: highest possible MSD for 0x00000001 MSW
.byte	10		# bit 33: highest possible MSD for 0x00000003 MSW
.byte	10		# bit 34: highest possible MSD for 0x00000007 MSW
.byte	10		# bit 35: highest possible MSD for 0x0000000F MSW
.byte	11		# bit 36: highest possible MSD for 0x0000001F MSW
.byte	11		# bit 37: highest possible MSD for 0x0000003F MSW
.byte	11		# bit 38: highest possible MSD for 0x0000007F MSW
.byte	12		# bit 39: highest possible MSD for 0x000000FF MSW
.byte	12		# bit 40: highest possible MSD for 0x000001FF MSW
.byte	12		# bit 41: highest possible MSD for 0x000003FF MSW
.byte	12		# bit 42: highest possible MSD for 0x000007FF MSW
.byte	13		# bit 43: highest possible MSD for 0x00000FFF MSW
.byte	13		# bit 44: highest possible MSD for 0x00001FFF MSW
.byte	13		# bit 45: highest possible MSD for 0x00003FFF MSW
.byte	14		# bit 46: highest possible MSD for 0x00007FFF MSW
.byte	14		# bit 47: highest possible MSD for 0x0000FFFF MSW
.byte	14		# bit 48: highest possible MSD for 0x0001FFFF MSW
.byte	15		# bit 49: highest possible MSD for 0x0003FFFF MSW
.byte	15		# bit 50: highest possible MSD for 0x0007FFFF MSW
.byte	15		# bit 51: highest possible MSD for 0x000FFFFF MSW
.byte	15		# bit 52: highest possible MSD for 0x001FFFFF MSW
.byte	16		# bit 53: highest possible MSD for 0x003FFFFF MSW
.byte	16		# bit 54: highest possible MSD for 0x007FFFFF MSW
.byte	16		# bit 55: highest possible MSD for 0x00FFFFFF MSW
.byte	17		# bit 56: highest possible MSD for 0x01FFFFFF MSW
.byte	17		# bit 57: highest possible MSD for 0x03FFFFFF MSW
.byte	17		# bit 58: highest possible MSD for 0x07FFFFFF MSW
.byte	18		# bit 59: highest possible MSD for 0x0FFFFFFF MSW
.byte	18		# bit 60: highest possible MSD for 0x1FFFFFFF MSW
.byte	18		# bit 61: highest possible MSD for 0x3FFFFFFF MSW
.byte	18		# bit 62: highest possible MSD for 0x7FFFFFFF MSW
.byte	19		# bit 63: highest possible MSD for 0xFFFFFFFF MSW
#
.align	8
gd_table:			# 64-bit powers of ten
.long	0x00000001, 0x00000000  #                          1	 1 digit
.long	0x0000000A, 0x00000000  #                         10	 2 digits
.long	0x00000064, 0x00000000  #                        100	 3 digits
.long	0x000003E8, 0x00000000  #                      1,000	 4 digits
.long	0x00002710, 0x00000000  #                     10,000	 5 digits
.long	0x000186A0, 0x00000000  #                    100,000	 6 digits
.long	0x000F4240, 0x00000000  #                  1,000,000	 7 digits
.long	0x00989680, 0x00000000  #                 10,000,000	 8 digits
.long	0x05F5E100, 0x00000000  #                100,000,000	 9 digits
.long	0x3B9ACA00, 0x00000000  #              1,000,000,000	10 digits
.long	0x540BE400, 0x00000002  #             10,000,000,000	11 digits
.long	0x4876E800, 0x00000017  #            100,000,000,000	12 digits
.long	0xD4A51000, 0x000000E8  #          1,000,000,000,000	13 digits
.long	0x4E72A000, 0x00000918  #         10,000,000,000,000	14 digits
.long	0x107A4000, 0x00005AF3  #        100,000,000,000,000	15 digits
.long	0xA4C68000, 0x00038D7E  #      1,000,000,000,000,000	16 digits
.long	0x6FC10000, 0x002386F2  #     10,000,000,000,000,000	17 digits
.long	0x5D8A0000, 0x01634578  #    100,000,000,000,000,000	18 digits
.long	0xA7640000, 0x0DE0B6B3  #  1,000,000,000,000,000,000	19 digits
.long	0x89E80000, 0x8AC72304  # 10,000,000,000,000,000,000	20 digits
#
.align	8
oct_msd_64:		#table of shift values for most significant dword
	.byte	1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 0
#
.align	8
oct_lsd_64:		#table of shift values for least significant dword
	.byte	2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0
#
.align	8
hundred_thousand:
.long	0x0, 0x40F86A00
#
hundred_thousandth:
.long	0x88E368F1, 0x3EE4F8B5
#
ften:	.long	0x0, 0x40240000
#
ffive:	.long	0x0, 0x40140000
#
.align	8
fxam_table:		#jump table for values of C2, C3, C0 bits of FPU
.long	float_nan	#C2 = 0   C3 = 0   C0 = 0
.long	float_nan	#     0        0        1
.long	float_zero	#     0        1        0
.long	float_nan	#     0        1        1
.long	float_normal	#     1        0        0
.long	float_infinity	#     1        0        1
.long	float_normal	#     1        1        0
.long	float_nan	#     1        1        1
#
#
#
.text
#
# ######################
# #####  xlibss.s  #####  intrinsics that take strings and return strings
# ######################
#
# *************************
# *****  %_csize.d.v  *****  CSIZE$(x$)
# *****  %_csize.d.s  *****
# *************************
#
# in:	arg0 -> source string
# out:	eax -> copy of source string, truncated at first null
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit
#
__csize.d.v:
	xorl	%ebx,%ebx	#nothing to free on exit
	jmp	csize.d.x
#
__csize.d.s:
	movl	4(%esp),%ebx	#ebx -> string to free on exit
#;
#; fall through
#;
csize.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit
	cld
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#null pointer?
	jz	csize_null	#yes: nothing to do
	movl	-8(%esi),%esi	#esi = length of source string
	incl	%esi	#one more for terminating null
	call	_____calloc	#allocate space for copy
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,%edi	#edi -> result string
	movl	%edi,%ebx	#save it
	movl	8(%ebp),%esi	#esi -> source string
	xorl	%edx,%edx	#edx = length counter = 0
csize_loop:
	lodsb		#al = next character
	orb	%al,%al	#found the null?
	jz	csize_done	#yes: nothing left to copy
	stosb		#no: write character to result string
	incl	%edx	#bump length counter
	jmp	csize_loop
csize_done:
	movl	%edx,-8(%ebx)	#store length of result string
	pushl	%ebx	#save pointer to result string
	movl	-4(%ebp),%esi	#esi -> string to free on exit
	call	_____free	#free it
	popl	%eax	#eax -> result string
	movl	%ebp,%esp
	popl	%ebp
	ret
csize_null:			#create a string with nothing but a null in it
	incl	%esi	#esi = bytes needed for string = 1
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	$0,-8(%esi)	#store length
	movl	%esi,%eax	# be nothing to free
	movl	%ebp,%esp	#eax -> result string
	popl	%ebp
	ret
#
#
# *************************
# *****  %_lcase.d.s  *****  LCASE$(x$) and UCASE$(x$)
# *****  %_lcase.d.v  *****
# *****  %_ucase.d.s  *****
# *****  %_ucase.d.v  *****
# *************************
#
# in:	arg0 - > string to convert
# out:	eax -> converted string
#
# destroys: ebx, ecx, edx, esi, edi
#
# .s routines convert string at arg0
# .v routines create a new string.
#
__lcase.d.s:
	movl	$__uctolc,%ebx	#ebx -> table to convert to lower case
	jmp	xcase.d.s	#branch to common routine
#
__ucase.d.s:
	movl	$__lctouc,%ebx	#ebx -> table to convert to upper case
xcase.d.s:
	movl	4(%esp),%esi	#esi -> string to convert
	cld
	orl	%esi,%esi	#null pointer?
	jz	xcase_ret	#yes: nothing to do
	movl	-8(%esi),%ecx	#ecx = length of input string
	movl	%esi,%edi	#edi -> input string, which is also output string
xcase_d_s_loop:
	jecxz	xcase_ret	#quit loop if reached last character
	lodsb		#get next char
	xlat		#convert char
	stosb		#store it
	decl	%ecx	#bump character counter
	jmp	xcase_d_s_loop	#do next character
xcase_ret:
	movl	4(%esp),%eax
	ret
#
#
__lcase.d.v:
	movl	$__uctolc,%ebx	#ebx -> table to convert upper to lower
	jmp	xcase.d.v	#branch to common routine
#
__ucase.d.v:
	movl	$__lctouc,%ebx	#ebx -> table to convert to upper case
#;
#; fall through
#;
xcase.d.v:
	movl	4(%esp),%esi	#esi -> string to convert
	orl	%esi,%esi	#null pointer?
	jz	xcase_ret	#yes: nothing to do
	pushl	%ebx	#save pointer to translation table
	movl	-8(%esi),%esi	#esi = length of result string
	incl	%esi	#add one for null terminator
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	popl	%ebx	#ebx -> translation table
	movl	%esi,%edi	#edi -> result string
	movl	%esi,%edx	#save pointer so we can return it later
	movl	4(%esp),%esi	#esi -> source string
	movl	-8(%esi),%ecx	#ecx = length of source string
	movl	%ecx,-8(%edi)	#store length into result string
xcase_d_v_loop:
	jecxz	xcase_d_v_ret	#exit loop if all characters have been copied
	lodsb		#fetch character from source string
	xlat		#convert its case
	stosb		#store character to result string
	decl	%ecx	#bump character counter
	jmp	xcase_d_v_loop	#do next character
xcase_d_v_ret:
	movb	$0,(%edi)	#write null terminator
	movl	%edx,%eax	#eax -> result string
	ret
#
#
# *************************
# *****  %_rjust.d.v  *****  RJUST$(x$, y)
# *****  %_rjust.d.s  *****
# *************************
#
# in:	arg1 = desired width of result string
#	arg0 -> string to right-justify
# out:	eax -> copy of source string, padded with space on left so that it's
#	       arg1 characters long
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, or null to not free anything
#
__rjust.d.v:
	xorl	%ebx,%ebx	#don't free anything on exit
	jmp	rjust.d.x
#
__rjust.d.s:
	movl	4(%esp),%ebx	#ebx -> string to free on exit (arg0)
#;
#; fall through
#;
rjust.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#store pointer to string to free on exit
	cld
	movl	12(%ebp),%esi	#esi = desired length of string
	orl	%esi,%esi	#zero or less??
	jbe	rjust_null	#yes: return null string
	incl	%esi	#add one to length for null terminator
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	12(%ebp),%ecx	#ecx = desired length of string
	movl	%ecx,-8(%esi)	#store length
	movl	%esi,%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> source string
	movl	%edi,%edx	#save pointer to result string in edx
	xorl	%ebx,%ebx	#ebx = length of source string if it's null
	orl	%esi,%esi	#source string is null pointer?
	jz	rjust_not_null	#yes: ebx is correct
	movl	-8(%esi),%ebx	#ebx = length of source string
rjust_not_null:
	cmpl	%ebx,%ecx	#desired length no more than current length?
	jbe	rjust_copy_orig	#yes: just copy part of original string
	subl	%ebx,%ecx	#ecx = number of spaces to prepend to string
	movb	$' ',%al	#ready to write some spaces
	rep
	stosb		#write them spaces!
	movl	%ebx,%ecx	#ecx = length of original string
rjust_copy_orig:
	rep
	movsb		#copy original string
	movb	$0,(%edi)	#write null terminator
	movl	%edx,%eax	#eax -> result string
rjust_ret:
	pushl	%eax	#save result
	movl	-4(%ebp),%esi	#esi -> string to free
	call	_____free
	popl	%eax	#eax -> result
	movl	%ebp,%esp
	popl	%ebp
	ret
cjust_null:
ljust_null:
rjust_null:
	xorl	%eax,%eax	#return null string
	jmp	rjust_ret
#
#
# *************************
# *****  %_ljust.d.v  *****  LJUST$(x$, y)
# *****  %_ljust.d.s  *****
# *************************
#
# in:	arg1 = desired length
#	arg0 -> string to left-justify
# out:	eax -> copy of source string, padded with space on right so that it's
#	       arg1 characters long
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, or null to not free anything
#
__ljust.d.v:
	xorl	%ebx,%ebx	#don't free anything on exit
	jmp	ljust.d.x
#
__ljust.d.s:
	movl	4(%esp),%ebx	#ebx -> string to free on exit
#;
#; fall through
#;
ljust.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit
	cld
	movl	12(%ebp),%esi	#esi = desired length of string
	orl	%esi,%esi	#zero or less??
	jbe	ljust_null	#yes: return null string
	incl	%esi	#add one to length for null terminator
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	12(%ebp),%ebx	#ebx = desired length of string
	movl	%ebx,-8(%esi)	#store length
	movl	%esi,%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> source string
	movl	%edi,%edx	#save pointer to result string in edx
	orl	%esi,%esi	#source string is null pointer?
	jz	ljust_spaces	#yes: create nothing but spaces
	movl	-8(%esi),%ecx	#ecx = length of source string
ljust_not_null:
	xorl	%eax,%eax	#eax = 0 to flag need to append spaces
	cmpl	%ecx,%ebx	#desired length greater than current length?
	ja	ljust_copy	#no: skip
	movl	%ebx,%ecx	#copy only desired-length characters
	incl	%eax	#eax != 0 to indicate no need to append spaces
ljust_copy:
	rep
	movsb		#copy source string to result string
	orl	%eax,%eax	#need to append spaces?
	jnz	ljust_done	#nope
	movl	8(%ebp),%esi	#esi -> source string
	subl	-8(%esi),%ebx	#ebx = desired - current = _ of spaces to add
ljust_spaces:
	movl	%ebx,%ecx	#counter register = _ of spaces to add
	movb	$' ',%al	#ready to write spaces
	rep
	stosb		#write them spaces!
ljust_done:
	movb	$0,(%edi)	#append null terminator
	pushl	%edx	#save pointer to result string
	movl	-4(%ebp),%esi	#esi -> string to free, if any
	call	_____free
	popl	%eax	#return result pointer in eax
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_cjust.d.v  *****
# *****  %_cjust.d.s  *****
# *************************
#
# in:	arg1 = desired length
#	arg0 -> string to center
# out:	eax -> centered version of string at arg0
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, or null if nothing to free
#	[ebp-8] -> result string
#
__cjust.d.v:
	xorl	%ebx,%ebx	#no string to free on exit
	jmp	cjust.d.x
#
__cjust.d.s:
	movl	4(%esp),%ebx	#ebx -> string to free on exit (arg0)
#;
#; fall through
#;
cjust.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit
	cld
	movl	12(%ebp),%esi	#esi = desired length of string
	orl	%esi,%esi	#zero or less??
	jbe	cjust_null	#yes: return null string
	incl	%esi	#add one to length for null terminator
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	12(%ebp),%ecx	#ecx = desired length of string
	movl	%ecx,-8(%esi)	#store length
	movl	%esi,%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> source string
	movl	%edi,-8(%ebp)	#save pointer to result string
	xorl	%ebx,%ebx	#ebx = length of source string if it's null
	orl	%esi,%esi	#source string is null pointer?
	jz	cjust_not_null	#yes: ebx is correct
	movl	-8(%esi),%ebx	#ebx = length of source string
cjust_not_null:
	cmpl	%ebx,%ecx	#desired length no more than original length?
	jbe	cjust_copy_only	#yes: pad no spaces on either side
	movl	%ecx,%edx	#save desired length in edx
	subl	%ebx,%ecx	#ecx = desired length - original length
	shrl	$1,%ecx	#ecx = _ of spaces to add on left
	leal	(%ecx,%ebx,1),%eax	#eax = left spaces + original length
	subl	%eax,%edx	#edx = _ of spaces to add on right
	movb	$' ',%al	#ready to write some spaces
	rep
	stosb		#store spaces on left side of string
	movl	%ebx,%ecx	#ecx = length of original string
	rep
	movsb		#copy original string
	movl	%edx,%ecx	#ecx = _ of spaces to add on right
	rep
	stosb		#store spaces on right side of string
cjust_exit:
	movb	$0,(%edi)	#write null terminator
	movl	-4(%ebp),%esi	#ebx -> string to free, if any
	call	_____free
	movl	-8(%ebp),%eax	#eax -> result string
	movl	%ebp,%esp
	popl	%ebp
	ret
cjust_copy_only:
	rep
	movsb		#copy source string to result string
	jmp	cjust_exit
#
#
# *************************
# *****  %_lclip.d.v  *****  LCLIP$(x$, y)
# *****  %_lclip.d.s  *****
# *************************
#
# in:	arg1 = number of characters to clip from left of string
#	arg0 -> source string
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> source string if .s, null if .v
#	[ebp-8] -> result string
#
__lclip.d.v:
	xorl	%ebx,%ebx	#must create new string
	jmp	lclip.d.x
#
__lclip.d.s:
	movl	4(%esp),%ebx	#ebx -> source string# modify it in place
#;
#; fall through
#;
lclip.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	movl	%ebx,-4(%ebp)	#store null or pointer to source string
	cld
	movl	8(%ebp),%edi	#edi -> source string
	orl	%edi,%edi	#source string is null pointer?
	jz	lclip_null	#yes: just return null pointer
	movl	-8(%edi),%ecx	#ecx = current length of string
	movl	%edi,%esi	#esi -> source string
	movl	12(%ebp),%edx	#edx = _ of bytes to clip
	orl	%edx,%edx	#fewer than zero bytes?
	js	lclip_IFC	#yes: get angry
	subl	%edx,%ecx	#clipping more (or same _) chars than in string?
	jbe	lclip_null	#yes: just return null pointer
	orl	%ebx,%ebx	#do we have to create a new string?
	jnz	lclip_copy	#no: skip creation of new string
	leal	1(%ecx),%esi	#esi = length of result string (+1 for null)
	call	_____calloc	#create result string# esi -> it
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> original string
	movl	-8(%esi),%ecx	#ecx = original length
	movl	12(%ebp),%edx	#edx = _ of bytes to clip
	subl	%edx,%ecx	#ecx = _ of bytes to copy from original string
lclip_copy:
	movl	%ecx,-8(%edi)	#store length of result string
	addl	%edx,%esi	#esi -> where in source string to begin copy
	movl	%edi,%eax	#eax -> result string
	rep
	movsb		#copy right side of source string
	movb	$0,(%edi)	#write null terminator
	movl	%ebp,%esp
	popl	%ebp
	ret
#
mid_IFC:
rclip_IFC:
lclip_IFC:
right_IFC:
stuff_IFC:
	movl	-4(%ebp),%esi	#esi -> string to free, if any
	call	_____free
	xorl	%eax,%eax	#return null pointer
	movl	%ebp,%esp
	popl	%ebp
	jmp	__eeeIllegalFunctionCall	# Return directly from there
#
mid_null:
ltrim_null:
rtrim_null:
lclip_null:
rclip_null:
	movl	-4(%ebp),%esi	#esi -> string to free, if any
	call	_____free
	xorl	%eax,%eax	#return null pointer
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_rclip.d.v  *****  RCLIP$(x$, y)
# *****  %_rclip.d.s  *****
# *************************
#
# in:	arg1 = number of characters to clip off right side of string
#	arg0 -> source string
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, or null if none
#
__rclip.d.v:
	xorl	%ebx,%ebx	#no string to free on exit
	jmp	rclip.d.x
#
__rclip.d.s:
	movl	4(%esp),%ebx	#ebx -> source string# modify it in place
#;
#; fall through
#;
rclip.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit, if any
	cld
	movl	8(%ebp),%eax	#eax -> source string
	orl	%eax,%eax	#null pointer?
	jz	rclip_null	#yes: return null string
	movl	-8(%eax),%ecx	#ecx = length of source string
	movl	12(%ebp),%edx	#edx = _ of chars to clip
	orl	%edx,%edx	#fewer than zero bytes?
	js	rclip_IFC	#yes: get angry
	subl	%edx,%ecx	#ecx = new length of source string
	jbe	rclip_null	#return null if clipping everything
	orl	%ebx,%ebx	#do we have to create a copy?
	jnz	rclip_nocopy	#no: just write a null and change the length
	pushl	%ecx
	leal	1(%ecx),%esi	#esi = length of copy (+ 1 for null terminator)
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	popl	%ecx
	movl	%ecx,-8(%esi)	#store length
	movl	%esi,%edi	#edi -> result string
	movl	%esi,%eax	#save it in order to return it
	movl	8(%ebp),%esi	#esi -> source string
	rep
	movsb		#copy left part of source string
	movb	$0,(%edi)	#write null terminator
	movl	%ebp,%esp
	popl	%ebp
	ret
rclip_nocopy:
	movb	$0,(%eax,%ecx,1)	#write null terminator
	movl	%ecx,-8(%eax)	#write length
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_ltrim.d.v  *****  LTRIM$(x$)
# *****  %_ltrim.d.s  *****
# *************************
#
# in:	arg0 -> source string
# out:	eax -> string trimmed of all leading spaces and unprintable
#	       characters (i.e. bytes <= 0x20 and >= 0x7F)
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, if any
#
__ltrim.d.v:
	xorl	%ebx,%ebx	#must create copy to hold result
	jmp	ltrim.d.x
#
__ltrim.d.s:
	movl	4(%esp),%ebx	#store result on top of source string
#;
#; fall through
#;
ltrim.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit, if any
	cld
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#null pointer?
	jz	ltrim_null	#yes: outta here
	movl	-8(%esi),%ecx	#ecx = length of source string
	incl	%ecx	#prepare for loop (cancel out initial DEC ECX)
	decl	%esi	#cancel out initial INC ESI
ltrim_loop:			#decide where in source string to begin copying
	decl	%ecx	#ecx = number of chars left in source string
	jz	ltrim_null	#if none left, return null pointer
	incl	%esi
	movb	(%esi),%al	#al = next character from string
	cmpb	$' ',%al	#space or less?
	jbe	ltrim_loop	#yes: skip this character
	cmpb	$0x7F,%al	#DEL or has high bit set?
	jae	ltrim_loop	#yes: skip this character
ltrim_loop_done:
	orl	%ebx,%ebx	#do we have to make a new string to hold result?
	jnz	ltrim_just_copy	#no: skip straight to copy routine
	pushl	%esi
	pushl	%ecx
	leal	1(%ecx),%esi	#esi = length of result (+1 for null terminator)
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	popl	%ecx	#ecx = new length
	movl	%esi,%edi	#edi -> result string
	popl	%esi	#esi -> first non-trimmed char in source string
ltrim_copy:
	movl	%ecx,-8(%edi)	#store length of result string
	movl	%edi,%eax	#eax -> result string
	rep
	movsb		#copy non-trimmed section
	movb	$0,(%edi)	#write null terminator
	movl	%ebp,%esp
	popl	%ebp
	ret
ltrim_just_copy:		#no need to allocate new string
	movl	8(%ebp),%edi	#edi -> source string, which is also result str
	cmpl	%edi,%esi	#nothing is being trimmed?
	jne	ltrim_copy	#no: go move non-trimmed part on top of trimmed
	movl	%esi,%eax	#yes, nothing is being trimmed: nothing to do
	movl	%ebp,%esp	#return result in eax
	popl	%ebp
	ret
#
#
# *************************
# *****  %_rtrim.d.v  *****  RTRIM$(x$)
# *****  %_rtrim.d.s  *****
# *************************
#
# in:	arg0 -> source string
# out:	eax -> string trimmed of all trailing spaces and unprintable
#	       characters (i.e. bytes <= 0x20 and >= 0x7F)
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, if any
#	[ebp-8] -> length of result string
#
__rtrim.d.v:
	xorl	%ebx,%ebx	#must create new string to hold result
	jmp	rtrim.d.x
#
__rtrim.d.s:
	movl	4(%esp),%ebx	#free source string if we free anything
#;
#; fall through		; and store result on top of source
#;
rtrim.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$8,%esp
	movl	%ebx,-4(%ebp)	#save string to free on exit, if any
	cld
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#a null pointer?
	jz	rtrim_null	#yes: return null pointer
	movl	-8(%esi),%ecx	#ecx = length of source string
	leal	(%esi,%ecx,1),%edi	#edi -> char after last char in source string
	incl	%ecx	#cancel out DEC ECX at beginning of loop
rtrim_loop:			#start at end of string and work backwards,
	decl	%edi	#bump pointer into source string
	decl	%ecx	#ecx = length of result string
	jz	rtrim_null	#if nothing left, return null pointer
	movb	(%edi),%al	#al = next character
	cmpb	$' ',%al	#space or less?
	jbe	rtrim_loop	#yes: keep looping
	cmpb	$0x7F,%al	#DEL or above?
	jae	rtrim_loop
	incl	%edi	#edi -> first char to trim
	movl	8(%ebp),%eax	#eax -> result string, if no copy
	orl	%ebx,%ebx	#do we need to create a copy?
	jnz	rtrim_terminator	#no: just stick in null terminator
	movl	%ecx,-8(%ebp)	#save length of result string
	movl	%ecx,%esi	#esi = length of result string
	incl	%esi	#plus one for null terminator
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	-8(%ebp),%ecx	#ecx = length of result string
	movl	%esi,%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> source string
	movl	%edi,%eax	#eax -> result string (save it)
	rep
	movsb		#copy source string up to trimmed section
	movl	-8(%ebp),%ecx	#ecx = length of result string
rtrim_terminator:
	movl	%ecx,-8(%eax)	#store length of result string
	movb	$0,(%edi)	#write null terminator
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ************************
# *****  %_trim.d.v  *****  TRIM$(x$)
# *****  %_trim.d.s  *****
# ************************
#
# in:	arg0 -> string to trim of leading and trailing chars <= 0x20 and >= 0x7F
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, if any
#
__trim.d.v:
	xorl	%ebx,%ebx	#must create new string to hold result
	jmp	trim.d.x
#
__trim.d.s:
	movl	4(%esp),%ebx	#store result on top of source string
#;
#; fall through
#;
trim.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#save string to free on exit, if any
	cld
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#a null pointer?
	jz	trim_null	#yes: return null pointer
	movl	%esi,%edi	#save pointer to source string
	xorl	%ebx,%ebx	#ebx = start position for MID$ = 0
	movl	-8(%esi),%ecx	#ecx = length of source string
trim_left_loop:
	jecxz	trim_null	#entire string is trimmed away: return null
	incl	%ebx	#bump start position
	decl	%ecx	#bump length counter
	lodsb		#get next character
	cmpb	$' ',%al	#space or lower?
	jbe	trim_left_loop	#yes: trim it
	cmpb	$0x7F,%al	#DEL or higher?
	jae	trim_left_loop	#yes: trim it
	decl	%esi	#esi -> first non-trimmed character
	movl	-8(%edi),%eax	#eax = original length of string
	addl	%eax,%edi	#edi -> char after last char in string
trim_right_loop:		#in this loop, we start at the end of the
	decl	%edi	#edi -> next character
	movb	(%edi),%al	#al = next character
	cmpb	$' ',%al	#space or lower?
	jbe	trim_right_loop	#yes: trim it
	cmpb	$0x7F,%al	#DEL or higher?
	jae	trim_right_loop	#yes: trim it
	incl	%edi
	subl	%esi,%edi	#edi = length of result string
	pushl	%edi	#push length of substring
	pushl	%ebx	#push start position
	pushl	8(%ebp)	#push pointer to source string
	movl	-4(%ebp),%ebx	#ebx indicates whether source is trashable
	call	mid.d.x	#let MID$ do all the work
	addl	$12,%esp
	movl	%ebp,%esp
	popl	%ebp
	ret
trim_null:
right_null:
left_null:
stuff_null:
	movl	-4(%ebp),%esi	#esi -> string to free, if any
	call	_____free
	xorl	%eax,%eax	#return null pointer
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ************************
# *****  %_left.d.v  *****  LEFT$(x$,y)
# *****  %_left.d.s  *****
# ************************
#
# in:	arg1 = number of characters to peel off left
#	arg0 -> source string
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, di
#
# local variables:
#	[ebp-4] -> string to free on exit, if any
#
__left.d.v:
	xorl	%ebx,%ebx	#must create new string to hold result
	jmp	left.d.x
#
__left.d.s:
	movl	4(%esp),%ebx	#put result on top of source string
#;
#; fall through
#;
left.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#save string to free on exit, if any
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#null pointer?
	jz	left_null	#yes: return null pointer
	movl	12(%ebp),%ecx	#ecx = _ of chars to peel off
	jecxz	left_null	#nothing to do if no chars requested
	pushl	%ecx	#push number of chars requested
	pushl	$1	#push start position (always at left of string)
	pushl	%esi	#push pointer to source string
	call	mid.d.x	#let MID$ do all the work
	addl	$12,%esp
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# *************************
# *****  %_right.d.v  *****  RIGHT$(x$,y)
# *****  %_right.s.s  *****
# *************************
#
# in:	arg1 = # of characters to peel off of right
#	arg0 -> source string
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, if any
#
__right.d.v:
	xorl	%ebx,%ebx	#must create new string to hold result
	jmp	right.d.x
#
__right.d.s:
	movl	4(%esp),%ebx	#put result on top of source string
#;
#; fall through
#;
right.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$4,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit, if any
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#a null pointer?
	jz	right_null	#yes: return null pointer
	movl	-8(%esi),%ecx	#ecx = length of source string
	jecxz	right_null	#if nothing in string, return null pointer
	movl	12(%ebp),%edx	#edx = requested number of characters
	orl	%edx,%edx
	jz	right_null	#if zero requested, return null pointer
	jb	right_IFC	#if less than zero, get angry
	pushl	%edx	#push number of chars requested
	subl	%edx,%ecx	#ecx = LEN(x$) - _ chars requested = start pos
	ja	right_skip	#if start pos is in string, then no problem
	xorl	%ecx,%ecx	#otherwise force start pos to first char
right_skip:
	incl	%ecx	#make start pos one-biased
	pushl	%ecx	#pass start pos to MID$
	pushl	%esi	#push source string
	call	mid.d.x	#get MID$ to do all the work
	addl	$12,%esp
	movl	%ebp,%esp
	popl	%ebp
	ret
#
#
# ***********************
# *****  %_mid.d.v  *****  MID$(x$,y,z)
# *****  %_mid.d.s  *****
# ***********************
#
# in:	arg2 = number of characters to put in result string
#	arg1 = start position at which to begin copying (first position is "1")
#	arg0 -> source string
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> string to free on exit, if any
#	[ebp-8] -> result string
#	[ebp-12] = min(LEN(source$) - startoffset + 1, substring_len)
#		 = length of result string
#
__mid.d.v:
	xorl	%ebx,%ebx	#create a new string to hold result
	jmp	mid.d.x
#
__mid.d.s:
	movl	4(%esp),%ebx	#store result string on top of source string
#;
#; fall through
#;
mid.d.x:			#general entry point for various string-reducers
	pushl	%ebp	# requires that ebx be set as if MID$ were
	movl	%esp,%ebp	# called from one of the above two entry points
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit, if any
	cld
	movl	8(%ebp),%esi	#esi -> source string
	orl	%esi,%esi	#null pointer?
	jz	mid_null	#yes: return null pointer
	movl	-8(%esi),%edx	#edx = length of source string
	orl	%edx,%edx	#zero?
	jz	mid_null	#yes: can't take much of a substring from that
	movl	12(%ebp),%eax	#eax = start position (one-biased)
	decl	%eax	#eax = true start position
	js	mid_IFC	#less than zero is error
	movl	16(%ebp),%ecx	#ecx = length of substring
	orl	%ecx,%ecx
	jz	mid_null	#if zero, return null pointer
	jb	mid_IFC	#if less than zero, error
	cmpl	%edx,%eax	#start position >= length?
	jae	mid_null	#yes: return null pointer
	movl	%edx,%ebx	#ebx = source len
	subl	%eax,%ebx	#ebx = source len - start pos
	cmpl	%ebx,%ecx	#substring len greater than possible?
	jbe	mid_skip2	#no: ecx already contains true length of result
	movl	%ebx,%ecx	#shorten ecx to true length of result
mid_skip2:
	movl	%ecx,-12(%ebp)	#save length of result
	cmpl	$0,-4(%ebp)	#can we trash the source string?
	jz	mid_no_trash	#no: have to make a copy
	movl	%esi,%edi	#yes: point destination at source
	jmp	mid_go	#now finally get started
mid_no_trash:			#destination is new string
	leal	1(%ecx),%esi	#esi = result length (+1 for null terminator)
	call	_____calloc	#esi -> result string# all others trashed
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%esi,%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> source string
	movl	12(%ebp),%eax	#eax = start position
	decl	%eax	#eax = true start position
	movl	-12(%ebp),%ecx	#ecx = length of substring
# eax = start position (zero-biased), known to be >= 0
# ecx = length of substring, known to be > 0 and known not to go off the end
#	of the source string
# esi -> source string
# edi -> result string
mid_go:
	movl	%edi,-8(%ebp)	#save pointer to result string
	orl	%eax,%eax	#start position is start of source string?
	jnz	mid_start_nonzero	#no: will have to move the substring
	cmpl	$0,-4(%ebp)	#we're trashing the source string?
	jnz	mid_write_terminator	#yes: just write null into it
mid_copy:
	rep
	movsb		#copy source string to destination
mid_write_terminator:
	movl	-8(%ebp),%eax	#eax -> result string
	movl	-12(%ebp),%ecx	#ecx = length of substring = length of result
	movl	%ecx,-8(%eax)	#write length of result string
	movb	$0,(%eax,%ecx,1)	#write null terminator
	movl	%ebp,%esp
	popl	%ebp
	ret
mid_start_nonzero:
	addl	%eax,%esi	#esi -> first character in source to copy
	jmp	mid_copy
#
#
# **************************
# *****  %_stuff.d.vv  *****  STUFF$(x$,y$,i,j)
# *****  %_stuff.d.vs  *****
# *****  %_stuff.d.sv  *****
# *****  %_stuff.d.ss  *****
# **************************
#
# in:	arg3 = # of chars to copy from y$
#	arg2 = start position (one-biased) in x$ at which to start copying
#	arg1 -> y$
#	arg0 -> x$
# out:	eax -> result string
#
# destroys: ebx, ecx, edx, esi, edi
#
# local variables:
#	[ebp-4] -> y$ if .vs or .ss routine (if need to free y$ on exit)
#	[ebp-8] -> result string
#	[ebp-12] = start offset (i.e. zero-biased start position)
#
# Creation of result string happens in three phases, after all checking
# for errors and null pointers is done:
#
#    1.  Copy MIN(LEN(x$), start_offset) chars from x$ to result.
#
#    2.  Copy MIN(j, LEN(y$), LEN(x$) - start_offset) chars from y$ to result.
#
#    3.  Copy remaining chars from x$ to result, so result has same length
#	 as x$.
#
__stuff.d.vv:
	xorl	%ebx,%ebx	#indicate no need to free y$ on exit
	orl	$1,%eax	#eax != 0 to indicate x$ cannot be trashed
	jmp	stuff.d.x
#
__stuff.d.vs:
	movl	8(%esp),%ebx	#ebx -> y$# must free y$ on exit
	orl	$1,%eax	#eax != 0 to indicate x$ cannot be trashed
	jmp	stuff.d.x
#
__stuff.d.sv:
	xorl	%ebx,%ebx	#indicate no need to free y$ on exit
	xorl	%eax,%eax	#eax == 0 to indicate result goes over x$
	jmp	stuff.d.x
#
__stuff.d.ss:
	movl	8(%esp),%ebx	#ebx -> y$# must free y$ on exit
	xorl	%eax,%eax	#eax == 0 to indicate result goes over x$
#;
#; fall through
#;
stuff.d.x:
	pushl	%ebp
	movl	%esp,%ebp
	subl	$12,%esp
	movl	%ebx,-4(%ebp)	#save pointer to string to free on exit
	cld
	movl	8(%ebp),%edi	#edi -> x$ (string to stuff into)
	orl	%edi,%edi	#null pointer?
	jz	stuff_null	#yes: return null pointer and free y$ if nec.
	movl	-8(%edi),%ecx	#ecx = LEN(x$)
	movl	16(%ebp),%edx	#edx = start position (one-biased)
	decl	%edx	#edx = start offset (i.e. zero-biased start pos)
	js	stuff_IFC	#starting before first char is absurd
	movl	%edx,-12(%ebp)	#save start offset
	movl	%edi,-8(%ebp)	#[ebp-8] -> result string if x$ is trashable
	orl	%eax,%eax	#can we trash x$?
	jz	stuff_begin	#yes: skip code to create new string
	leal	1(%ecx),%esi	#esi = LEN(x$) + 1 for null terminator
	call	_____calloc	#esi -> result string
	movl	__WHOMASK,%eax	#eax = system/user bit
	orl	$0x80130001,%eax	#eax = info word for allocated string
	movl	%eax,-4(%esi)	#store info word
	movl	%ecx,-8(%esi)	#store length
	movl	%esi,-8(%ebp)	#[ebp-8] -> result string
stuff_begin:
	movl	12(%ebp),%esi	#esi -> y$ (string to copy from)
	orl	%esi,%esi	#y$ is null pointer?
	jz	stuff_just_copy	#yes: result is same as x$
	movl	-8(%ebp),%edi	#edi -> result string
	movl	-8(%edi),%edx	#edx = length of result string ( = LEN(x$) )
	movl	-12(%ebp),%ebx	#ebx = start offset
	movl	%edx,%ecx	#ecx = LEN(x$)
	xorl	%edx,%edx	#edx = MAX(LEN(x$) - start offset, 0) if
	cmpl	%ebx,%ecx	#LEN(x$) < start offset?
	jb	stuff_skip1	#yes: copy only LEN(x$) chars in phase 1
	movl	%ecx,%edx
	subl	%ebx,%edx	#edx = LEN(x$) - start offset
	movl	%ebx,%ecx	#no: copy up to the start offset
stuff_skip1:
	movl	-8(%esi),%eax	#eax = LEN(y$)
	cmpl	%eax,20(%ebp)	#j < LEN(y$)?
	ja	stuff_skip2	#no: eax = LEN(y$) = MIN(j, LEN(y$))
	movl	20(%ebp),%eax	#eax = j = MIN(j, LEN(y$))
stuff_skip2:
	cmpl	%eax,%edx	#LEN(x$) - start offset < MIN(j, LEN(y$))?
	ja	stuff_skip3	#no: eax = _ of chars to copy in phase 2
	movl	%edx,%eax	#eax = LEN(x$) - start offset
stuff_skip3:
	leal	(%ecx,%eax,1),%ebx	#ebx = _ of chars to copy in phases 1 and 2
	movl	-8(%edi),%edx	#edx = length of result string
	subl	%ecx,%edx	#...minus _ of chars to copy in phase 1
	movl	8(%ebp),%esi	#esi -> x$
	rep
	movsb		#copy chars for phase 1
	movl	%eax,%ecx	#ecx = _ of chars to copy in phase 2
	subl	%eax,%edx	#edx = _ of chars to copy in phase 3
	movl	12(%ebp),%esi	#esi -> y$
	rep
	movsb		#copy chars for phase 2
	movl	%edx,%ecx	#ecx = _ of chars to copy in phase 3
	movl	8(%ebp),%esi	#esi -> x$
	addl	%ebx,%esi	#esi -> 1st char to copy for phase 3
	rep
	movsb		#copy chars for phase 3
	movb	$0,(%edi)	#write null terminator
stuff_exit:
	movl	-4(%ebp),%esi	#esi = string to free on exit, if any
	call	_____free
	movl	-8(%ebp),%eax	#eax -> result string
	movl	%ebp,%esp
	popl	%ebp
	ret
stuff_just_copy:		#result will be exactly the same as x$
	movl	-8(%ebp),%edi	#edi -> result string
	movl	8(%ebp),%esi	#esi -> x$
	cmpl	%esi,%edi	#result string is x$?
	je	stuff_exit	#yes: then copy is already made
	movl	-8(%esi),%ecx	#ecx = LEN(x$)
	rep
	movsb		#copy x$ to result string
	movb	$0,(%edi)	#write null terminator
	jmp	stuff_exit
#
#
# *******************************************************
# *****  TABLE TO CONVERT LOWER CASE TO UPPER CASE  *****
# *******************************************************
#
.text
.align	8
__lctouc:
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
#
# *******************************************************
# *****  TABLE TO CONVERT UPPER CASE TO LOWER CASE  *****
# *******************************************************
#
.text
.align	8
__uctolc:
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
#
#
#
# #################
# #####  END  #####  xlibasm.s
# #################
#
