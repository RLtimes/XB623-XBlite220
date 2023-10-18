' Revisions in v0.0349
' Changes (KPM)
'	- added PACKED keyword; find the relevant changes by doing a case-insensitive search for
'   "packed". Syntax: same as TYPE, except declaration begins with "PACKED typename".
'   Declaration ends as usual with "END TYPE".
' - changes in several functions to allow IMPORTing of lib and object files (search for
' 	"newimport")
' - in AssignAddress(), in the section dealing with SHARED variables, changed
'   "IF m_addr[s] THEN" to "IF m_addr$[s] THEN". This fixes the problem in which SHARED
'   variables are redefined every time they are encountered, instead of only the first time.
' - changed a line in AssignAddress() to fix a bug that caused errors when a composite-type
'   variable is declared EXTERNAL (search for "extcomp")
' - added line in Expresso() to avoid endless loop that can occur when a member of a
'   composite type is used incorrectly (search for "endless")
' changes by dts
' - modified XxxLibraryAPI to locate syslib.xxx in XstLoadStringArray
' - added MAKEFILE keyword
' - added CONSOLE keyword

' Revisions in v0.0350
' - Most intrinsic functions from xlib.s are now emitted directly to program code.
' 	 See EmitIntrinsics()
' - Startup code from xstart.o for executables is now emitted using EmitWinMain()
' - Some op code from xlib.s is now emitted using EmitOpAsm().
' - Code for FORMAT$ from xlib.s now linked using separate file xformat.o (see CheckState())
' - Fixed bug in Expresso when using C functions with varlist parameters ... and user defined types; eg, wsprintfA
' - xcowlite now expects runtime library to be called xbl.dll
' - xblite program files can now have extensions of .x, .xl, or .xbl

' Revisions in v0.0351
' - Removed .globl labels for emitted intrinsic functions

' Revisions in v0.0352
' - Added LONGDOUBLE type (16 bytes) plus support for LONGDOUBLE in intrinsic functions.
' - Added EmitDllMain() function to emit _DllMain code in DLL libraries.

' Revisions in v0.0353
' - Removed most code related to flag i486bin
' - Added code to trap errors in *.dec files, providing the DEC filename and linenumber.
' - Added new command line switches -mak, -rc, -bat to suppress generation of these files.
' - Added new command line switches -nowinmain, -nodllmain to suppress output of WinMain() or DllMain().

' Revisions in v0.0354
' - Added EXPLICIT statement (to be used in PROLOG only) which can be used only if all
'    variables are explicitly defined in type declaration statements like
'    XLONG i, j, k
'    Otherwise, an error will occur.
'    I have been told that an EXPLICIT statement is good for checking for mispelled variable names.

' Revisions in v0.0355
' - fixed bug in longdouble array assignment

' Revisions in v0.0356
' - fixed evaluation of TYPE(SUBADDR), LEN (STRING$ (y)), LEN ((b$)+(t$)), LEN ("abcd")
' - fixed bug in printing LONGDOUBLE value defined in UDT

' Revisions in v0.0400 (never released) - Greg Heller
' - Stripped out EmitIntrinsics and EmitOpAsm and moved the functions
'		 to an external library, currently called xblib.lib
' - Removed several "Emit" functions
' - General code cleanup
' - removed remaining code related to i486bin
' - removed all references to i486asm, which is the default

' Revisions in v0.0401 (never released) - Greg Heller
' - eliminated unused charsetBackslashByte[], charsetBackslashChar[], charsetPrintChar[]
'		 charsetSymbolFirst[], charsetSymbolFinal[]
'	- Changed EmitString to emit strings in GoAsm compatible format without backslashes
'		 (still works with spasm)

'	################################################################################
'	####  From version 0.0500 - GoAsm replaces Spasm as the target assembler.   ####
'	####              see http://www.godevtool.com/ for GoAsm                   ####
'	################################################################################

' Revisions in v0.0500 (GoAsm conversion) - Greg Heller
'	- Converted output format to Win/DOS format (CRLF) instead of Unix format (LF)
' - Eliminated InitEntry, XxxInitParse, and some other functions
' - Numerous changes to create a GoAsm file instead of Spasm, including:
'		.text		-> .code
'		.align	-> align
'		.bss		-> .data ?
'		.zero		-> dup
'		.byte		-> db
'		.word		-> dw
'		.dword	-> dd
'		ptr			-> (eliminated)
'		slr			-> shr
'		sll			-> shl
'		... plus others that I forgot to keep track of.

' Revisions in v0.0501 (never released) - Greg Heller
'	- Changed alignment of literal strings to 4 bytes (was 16), results in about 3% smaller exe
'		 I don't expect a performance impact - I think alignment of 4 bytes is more normal than 16.
'	- Moved literal strings from .data to .const, this could increase exe size by 500 bytes
'	- Changed output file to .asm and object files to .obj

' Revisions in v0.0502 (never released) - Greg Heller
'	- Reverted back to 16 byte alignment and null padding for literal strings.
' - Moved literal strings back into .code section.
' - Moved ValidFormat and XxxFormat$ functions back into xst (for FORMAT$ support),
'		 and eliminated now-redundant code that previously linked xformat.o
' - Changed BinStringToAsmString$ function to emit correct .asm code in hex for GoAsm.
'	- Eliminated unneeded assemblerBackslashAsm$[]
' - Emits line numbers in assembly code in the form of ; [line]
'	-	Eliminated EmitWinMain and EmitDllMain functions

' Revisions in v0.0503 (never released) - Greg Heller
'	- Changed all internal labels to have .programName appended.  This is a huge change, which
'		 should facilitate future growth possibilities by vitually eliminating duplicate symbol errors
'		 while creating and linking xblite libraries.  If it is properly implemented, all "internal"
'		 symbols are "mangled" this way, but no "external" symbols are, so external variables and
'		 exported functions are still visible to other libraries, exes, and dlls. If a LNK:4006
'		 warning is ever seen (other than for _malloc) then more work is needed.
' - Moved the custom xst DllMain from xlib.asm to be emitted directly from xcowlite.

' Revisions in v0.0504 (never released) - Greg Heller
'	- Major rework of FUNCTION prolog for optimization.

' Revisions in v0.0505 (never released) - Greg Heller
'	- Fixed the FUNCTION prolog, the previous version messed up the stack pointer.

' Revision in v0.0506 (released with xblite 2.00) - David Szafranski
' - added COMMENT keyword which can be used as a block with END COMMENT to
'    comment out a section of code

' Revisions in v0.0507 (never released) - Greg Heller
'	- ESI, EDI, and EBX are now POPped off of the stack upon function closure, rather than MOVed.
'		 It is believed that this results in slightly more efficient code, and will facilitate some
'		 optimizations later.
'	- Corrected a problem which caused the path of the source file to be included in the mangled
'		 label names in some circumstances ("path bug").
' - Insignificant labels are generated as private unscoped re-usable labels, in the form of
'		 "A." followed by a number in decimal format. (Do not change to HEX like other labels!)

' Revisions in v0.0508 (never released) - Greg Heller
'	- Fixed a minor error where the compiler sometimes emitted "addr addr" instead of "addr",
'		 this did not prevent assembling with GoAsm.
'	- Fixed (once again!) the "path bug", this time it hopefully is right.
' - Eliminated XxxSetProgramName () and XxxGetProgramName (), which were unused.

' Revisions in v0.0509 (released with xblite 2.01) - Greg Heller
'	- Corrected an error that changed ESP on function calls, causing undesired stack growth
'	- Reworked the function prolog to make it faster (eliminated REP STOSD in favor of PUSHes)
'	-	Eliminated the following unused "legacy" variables:
'		 checkattach, xpc, litStringAddr, pass1source, pass1tokens, inlevel, section, charV,
'		 makevalue$, utab, decFile$[]
' - Eliminated the following unused "legacy" functions:
'		 CodeLabelAbs (), CodeLabelDisp (), EmitLine (), GetArg (), InvalidExternalSymbol (),
'		 OpenOneAcc (),  RangeCheck (), RegOnly (), StripExtent (), StripSuffix (), Value (),
'		 XxxCompilePrep (), XxxDeleteFunction (), XxxDeparseFunction (), XxxEmitXProfilerCall (),
'		 XxxErrorInfo (), XxxFunctionName (), XxxGetAddressGivenLabel (), XxxGetFunctionVariables (),
'		 XxxGetLabelGivenAddress (), XxxGetPatchErrors (), XxxGetUserTypes (), XxxGetXerror$ (),
'		 XxxInitVariablesPass1 (), XxxPassFunctionArrays (), XxxPassTypeArrays (), XxxTheType (),
'		 XxxXntInitLibraries (), XxxXntFreeLibraries ()

'	######################################################################################
'	####  From version 0.0510 - xblite requires GoAsm 0.54.09+ to work properly 			####
'	####              see http://www.godevtool.com/ for GoAsm				                  ####
'	#### 		  (Thanks to Jeremy Gordon for his excellent support of GoAsm!)     			####
'	######################################################################################

' Revisions in v0.0510 (never released) - Greg Heller and David Szafranski
'	- Deleted unused functions XxxGetSymbolInfo () and XxxDeparser ()
'	-	Added a new xst function %_XxxXstInitialize () which allows xst_s static library to properly
'		 initialize in both dlls and exes, and adjusted the DllMain function to accomodate the above.
'	- Removed Hack#1, xblite now _requires_ GoAsm 0.54.09 (or above)
'	- Fixed a few bugs (created by me - GH) related to loading dll libraries
' - Moved literal strings into .const section, is supposed to perform better this way!
' - Tweaked the function prolog for hopefully better performance
' - Fixed a bug related to EXTERNAL variables, not 100% sure it is working correctly,
'		 sometimes you may see a LNK4006 error, but it seems to compile and work properly.
'	- Numerous changes made to properly handle the use of static libraries.

' Revisions in v0.0511 - Greg Heller
' - Corrected "caser" SELECT CASE bug.

' Revision v0.0512 - DTS
' - Removed references to COMMENT/END COMMENT block code; eg, fCommentOn, T_COMMENT etc.

' Revision v0.0513 - DTS
' - Corrected longdouble array assignment bugs, see i463b marker.
' - Added function symbols to ALL command, see p_all: in CheckState().
' - Added new intrinsics ROUND(), ROUNDNE() and CEIL() - search on these keywords for changes.
' - Added compiler switch -m4 for calling m4 macro preprocessor and code to implement include
'    file #line messages. See CompileFile().
' - Modified PrintError() to handle error lines from included files.
' - Added ShellEx() to work with calling m4.

' Revision v0.0514 - DTS
' - Changed inline assembly ? to ASM.

' Revision v0.0515 - DTS
' - Set ? as equivalent to PRINT statement.

' Revision v0.0516 - GH (never released)
'	-	Eliminated XxxInitAll () (merged into XxxBasic)
'	-	Eliminated InitProgram () (not needed)
'	- Eliminated XxxXBasicVersion$ () (replaced with VERSION$)
' - In function Epilog, replaced "mov esp,ebp" "pop ebp" with "leave" per AMD optimization manual.
'	- Alternated register useage (ecx and edx) in function-level allocation code to improve pipelining
'		 and to reduce excess code (see i125 and i125a markers).
'	- Converted many uses of "$$or" to "$$test", which is slightly more optimal.
'	- Implemented the line continuation character "_", see UnComment$() and changes in CompileFile().
' -	Reduced string padding from 16 bytes to 8 bytes, which reduces executable size by 1-2% for larger
'		 programs with strings.  The reduction is greatest on programs with many tiny strings.
'		 Per "How to optimize for the Pentium family of microprocessors", Copyright © 1996, 2000 by Agner Fog
'		 26.3 String instructions (all processors), "Always use the DWORD version if possible, and make
'		 sure that both source and destination are aligned by 8."  Therefore the 16 byte alignment is
'		 unnecessary and results in a "waste" of up to 8 bytes per string.
'	-	Corrected a problem where edx was zero'ed by the deallocation routines upon leaving functions,
'		 which resulted in edx return values (in GIANT functions) being messed up.  While corrrecting
'		 this, I took advantage of the fact that ebx is not destroyed by the deallocation routines,
'		 so now ebx is zero'ed first and used it to clear the memory locations. (see i422 - i424)  This
'		 does not mess up the normal use of ebx or preservation rules, as ebx is restored afterwards.
'	-	Corrected another bug with functions that return GIANT values, where the eax register was not
'		 zero'ed when there was no explicit return value (edx was done properly, but eax was missed.)
'		 See marker i860a for this minor change.

' Revision v0.0517 - GH
'	-	Corrected an error in assembly output where the line immediately before commented xblite source
'		 code in the .asm file output had only a "Line Feed" without a "Carriage Return", which skewed
'		 GoAsm's method of counting line numbers for error reporting, and greatly annoyed me.
'	- Changed most instances of program$ to programName$ to correct some internal inconsistencies.
' - Changed the name of the data section so that each compiled object will have a different name
'		 for it's .bss data section.  This corrects a hypothetical bug where calling the first function
'		 of a library could reset all variables in the program to zero.  (This bug has not exibited itself
'		 in a program - it is hypothetical but thought possible.)
'	- Fixed LNK4006 warnings when linking with static libraries, by renaming the "markers" for the start
'		 and end of the .bss section so that each object has a unique .bss name.  All libraries need to be
'		 compiled with this version or the warning may still be seen.  Please let me know if the warning
'		 exibits itself again. (See %_begin_external_data ... and %_end_external_data ...)
'	- Created a new error state, ERROR_PROGRAM_NAME_MISMATCH, which will give a "Program Name Mismatch"
'		 error when the file name and the PROGRAM statement do not match.
'			- When there are no EXPORTs in a program, the use of PROGRAM is optional.  This means that most
'				 executables do not need it, and most libraries do need it.  However, in order to maintain
'				 consistency, any time PROGRAM is used, it must be matched, or there will be an error.
' - Fixed error $$SYSCON when getting address of empty string, eg, addr = &"". See line 16246.  (DTS)

' ####################################################################################################
' ### Work-arounds for GoAsm-related issues that maybe can be "normalized" after GoAsm is changed. ###
' ### (to find these in the code, search for "HACK#1", "HACK#2", etc.)                             ###
' ###	-	HACK#1 - "!" suffix is changed internally to ".sgl", GoAsm seems to want to interpret      ###
' ###		it as a "NOT", this hack can remain or be corrected as desired if GoAsm changes            ###
' ####################################################################################################


' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Windows XBLite compiler

' xcowlite.x is the XBLite compiler function
' library. It has been modified to act as an
' external DLL and it is no longer
' dependant on Xui or Xgr libraries from XBasic.
' ---
' subject to GPL license - see COPYING
' MaxReason@MaxReason.com
' ---
' XBLite modifications by David Szafranski 2005
' david.szafranski@wanadoo.fr

PROGRAM	"xcowlite"

VERSION	"0.0517"			' modified 28 August 2006

CONSOLE

IMPORT	"xst"
IMPORT	"xsx"					' Xsx dynamic library
IMPORT	"xio"					' Xio dynamic library
IMPORT	"kernel32"
IMPORT	"gdi32.dec"
IMPORT	"user32"


EXPORT

TYPE FUNCARG
	XLONG			.token
	XLONG			.varType
	XLONG			.argType
	SBYTE			.stack
	SBYTE			.byRef
	UBYTE			.kind
	UBYTE			.res
END TYPE

' SECTION:		See GetExternalAddresses()

'TYPE SECTION
'	STRING*8	.name
'	XLONG			.virtualSize
'	XLONG			.virtualAddress
'	XLONG			.physicalSize
'	XLONG			.physicalAddress
'	XLONG			.reserved0
'	XLONG			.reserved1
'	XLONG			.reserved2
'	XLONG			.sectionFlags
'END TYPE

' SYMBOL:		See GetExternalAddresses()

'TYPE SYMBOL
'	STRING*8	.name
'	XLONG			.value
'	USHORT		.section
'	USHORT		.type
'	UBYTE			.class
'	UBYTE			.aux
'END TYPE

TYPE LINEINFO
	XLONG      .line
	STRING*128 .file
END TYPE

' ********************************
' *****  Compiler Functions  *****
' ********************************

DECLARE FUNCTION  Xnt ()
DECLARE FUNCTION  XxxXBasic ()
END EXPORT

DECLARE FUNCTION  AddLabel (label$, token, action)
DECLARE FUNCTION  AddSymbol (symbol$, token, funcNumber)
DECLARE FUNCTION  AlloToken (token)
DECLARE FUNCTION  AssemblerSymbol (symbol$)
DECLARE FUNCTION  AssignAddress (token)
DECLARE FUNCTION  AssignComposite (dreg, dtype, sreg, stype)
DECLARE FUNCTION  AtOps (xtype, opcode, mode, base, offset, sourceData)
DECLARE FUNCTION  BinStringToAsmString$ (rawString$)
DECLARE FUNCTION  CheckOneLine ()
DECLARE FUNCTION  CheckState (token)
DECLARE FUNCTION  CloneArrayXLONG (dest[], source[])
DECLARE FUNCTION  Code (op, mode, dreg, sreg, xreg, dtype, label$, remark$)
DECLARE FUNCTION  Compile ()
DECLARE FUNCTION  CompileFile (file$)
DECLARE FUNCTION  Component (com, varToken, base, off, theType, tok, length)
DECLARE FUNCTION  Composite (com, theType, theReg, theOffset, theLength)
DECLARE FUNCTION  Conv (rad, toType, ras, fromType)
DECLARE FUNCTION	CreateLabel$ 							()
DECLARE FUNCTION  Deallocate (ptr)
DECLARE FUNCTION  Deparse$ (prefix$)
DECLARE FUNCTION  EmitAsm (@line$)
DECLARE FUNCTION  EmitFunctionLabel (funcName$)
DECLARE FUNCTION  EmitLabel (labelName$)
DECLARE FUNCTION  EmitString (theLabel$, @theString$)
DECLARE FUNCTION  EmitUserLabel (labelToken)
DECLARE FUNCTION  Eval (rtype)
DECLARE FUNCTION  ExpressArray (oldOp, oldPrec, newData, newType, accArray, excess, theType, sourceReg)
DECLARE FUNCTION  Expresso (oldTest, oldOp, oldPrec, oldData, oldType)
DECLARE FUNCTION  FloatLoad (dreg, stoken, stype)
DECLARE FUNCTION  FloatStore (sreg, stoken, stype)
'DECLARE FUNCTION  GetExternalAddresses ()
DECLARE FUNCTION  GetFuncaddrInfo (token, eleElements, argInfo[], dataPtr)
DECLARE FUNCTION  GetSymbol$ (info)
DECLARE FUNCTION  GetTokenOrAddress (token, style, nextToken, dataType, nType, base, offset, length)
DECLARE FUNCTION  GetWords (source, dtype, w3, w2, w1, w0)
DECLARE FUNCTION  InitArrays ()
DECLARE FUNCTION  InitComplex ()
DECLARE FUNCTION  InitEnvVars ()
DECLARE FUNCTION  InitErrors ()
DECLARE FUNCTION  InitVariables ()
DECLARE FUNCTION  LastElement (token, lastPlace, excessComma)
DECLARE FUNCTION  Literal (xx)
DECLARE FUNCTION  LoadLitnum (dreg, dtype, source, stype)
DECLARE FUNCTION  MakeToken (keyword$, kind, dataType)
DECLARE FUNCTION  MinTypeFromDouble (value#)
DECLARE FUNCTION  MinTypeFromGiant (value$$)
DECLARE FUNCTION  Move (dest, dtype, source, stype)
DECLARE FUNCTION  NextToken ()
DECLARE FUNCTION  Op (rad, ras, theOp, rax, dtype, stype, otype, xtype)
DECLARE FUNCTION  OpenAccForType (theType)
DECLARE FUNCTION  OpenBothAccs ()
DECLARE FUNCTION  ParseChar ()
DECLARE FUNCTION  ParseLine (tok[])
DECLARE FUNCTION  ParseNumber ()
DECLARE FUNCTION  ParseOutError (token)
DECLARE FUNCTION  ParseOutToken (token)
DECLARE FUNCTION  ParseSymbol ()
DECLARE FUNCTION  ParseWhite ()
DECLARE FUNCTION  PeekToken ()
DECLARE FUNCTION  Pop (dreg, dtype)
DECLARE FUNCTION  PrintError (errNumber)
DECLARE FUNCTION  PrintTokens ()
DECLARE FUNCTION  Printoid ()
DECLARE FUNCTION  Push (sreg, stype)
DECLARE FUNCTION  PushFuncArg (FUNCARG arg)
DECLARE FUNCTION  Reg (token)
DECLARE FUNCTION  ReturnValue (rtype)
DECLARE FUNCTION  ScopeToken (token)
DECLARE FUNCTION  Shuffle (oreg, areg, atype, ptype, atoken, pkind, mode, argOffset)
DECLARE FUNCTION  StackIt (toType, theData, fromType, offset)
DECLARE FUNCTION  StatementExport (token)
DECLARE FUNCTION  StatementImport (token)
DECLARE FUNCTION  StatementMakefile (token)
DECLARE FUNCTION  StatementProgram (token)
DECLARE FUNCTION  StatementVersion (token)
DECLARE FUNCTION  StripNonSymbol (name$)
DECLARE FUNCTION  TestForKeyword (symbol$)
DECLARE FUNCTION  TheType (token)
DECLARE FUNCTION  Tok (symbol$, token, kind, raddr, value, value$)
DECLARE FUNCTION  TokenRestOfLine ()
DECLARE FUNCTION  TokensDefined ()
DECLARE FUNCTION  Top ()
DECLARE FUNCTION  Topax1 ()
DECLARE FUNCTION  Topax2 (topa, topb)
DECLARE FUNCTION  Topaccs (topa, topb)
DECLARE FUNCTION  Topx (tr, trx, nr, nrx)
DECLARE FUNCTION  TypeToken (token)
DECLARE FUNCTION  TypenameToken (token)
DECLARE FUNCTION  Uop (rad, theOp, rax, dtype, otype, xtype)
DECLARE FUNCTION  UpdateToken (token)
DECLARE FUNCTION  WriteDeclarationFile (string$)
DECLARE FUNCTION  WriteDefinitionFile (string$)
DECLARE FUNCTION  UnComment$ (line$, @comment$)

DECLARE FUNCTION  XxxCheckLine							(lineNumber, tok[])
DECLARE FUNCTION  XxxCloseCompileFiles			()
DECLARE FUNCTION  XxxCreateCompileFiles     ()
DECLARE FUNCTION  XxxLoadLibrary            (token)
DECLARE FUNCTION  XxxLibraryAPI             (libname$)
DECLARE FUNCTION  XxxParseLibrary           (token)
DECLARE FUNCTION  XxxParseSourceLine				(sourceLine$, tok[])
DECLARE FUNCTION  XxxUndeclaredFunction			(funcToken)

DECLARE FUNCTION  ShellEx                   (command$, workDir$, output$, outputMode)


' ******************************
' *****  SHARED VARIABLES  *****
' ******************************

	SHARED library
	SHARED freezeFlag
	SHARED bogusFunction
	SHARED freezeFunction
	SHARED checkBounds
	SHARED entryFunction
	SHARED maxFuncNumber
	SHARED errorCount

	SHARED pass0source
	SHARED pass0tokens
	SHARED pass2errors
	SHARED XERROR
	SHARED charPtr
	SHARED rawline$
	SHARED rawLength
	SHARED tokenPtr
	SHARED xit
	SHARED hfn$
	SHARED pass
	SHARED defaultType

	SHARED inPrint
	SHARED markLine
	SHARED tab_sym_ptr
	SHARED ulabel
	SHARED labelPtr
	SHARED pastSystemLabels
	SHARED pastSystemSymbols
	SHARED uFunc
	SHARED uType
	SHARED typePtr
	SHARED externalAddr
	SHARED sharename$
	SHARED tab_sys_ptr
	SHARED upatch
	SHARED patchPtr
	SHARED lineNumber
	SHARED ofile
	SHARED tokenCount
	SHARED backToken
	SHARED lastToken
	SHARED programTypeChunk
	SHARED functionTypeChunk
	SHARED ExceptionHandler

	SHARED cop[]
	SHARED tokens[]
	SHARED charpos[]
	SHARED stackData[]
	SHARED stackType[]
	SHARED alphaFirst[]
	SHARED alphaLast[]
	SHARED r_addr[]
	SHARED r_addr$[]
	SHARED m_reg[]
	SHARED m_addr[]
	SHARED m_addr$[]
	SHARED hash%[]
	SHARED tab_sym$[]
	SHARED tab_sym[]
	SHARED tabType[]
	SHARED tabArg[]
	SHARED labhash[]
	SHARED labaddr[]
	SHARED tab_lab[]
	SHARED tab_lab$[]
	SHARED funcFrameSize[]
	SHARED funcSymbol$[]
	SHARED funcLabel$[]
	SHARED funcToken[]
	SHARED funcScope[]
	SHARED funcType[]
	SHARED funcKind[]
	SHARED funcArgSize[]
	SHARED funcArg[]
	SHARED pastArgsAddr[]
	SHARED xargNum
	SHARED xargAddr[]
	SHARED xargName$[]
	SHARED autoAddr[]
	SHARED autoxAddr[]
	SHARED inargAddr[]
	SHARED defaultType[]
	SHARED tab_sys$[]
	SHARED tab_sys[]
	SHARED patchType[]
	SHARED patchAddr[]
	SHARED patchDest[]
	SHARED q_type_long[]

	SHARED typeName$[]					' "sbyte", "ubyte"...
	SHARED typeSize[]						' size in bytes
	SHARED typeSize$[]					' "1", "2", "4", "8", "16"...
	SHARED typeAlias[]					' normal type that user-type is alias for
	SHARED typeAlign[]					' alignment for this type
	SHARED typeSuffix$[]				' @  @@  %  %%  &  &&  ~  !  #  $$  $
	SHARED typeSymbol$[]				' SBYTE, UBYTE...  SCOMPLEX, DCOMPLEX, USERTYPE...
	SHARED typeToken[]					' T_TYPE token, low word = type #
	SHARED typeEleCount[]				' # of elements in this type
	SHARED typeEleSymbol$[]			' symbol for each n elements
	SHARED typeEleToken[]				' token for each n elements
	SHARED typeEleAddr[]				' offset address of each n elements
	SHARED typeEleSize[]				' size of each n elements ([]: typesize*(dim+1))
	SHARED typeEleType[]				' type of each n elements
	SHARED typeEleArg[]					' kind/type of funcaddr component arguments
	SHARED typeElePtr[]					' # indirection levels for each n elements
	SHARED typeEleVal[]					' init value of each n elements
	SHARED typeEleStringSize[]	' # bytes in fixed string for element n
	SHARED typeEleUBound[]			' Upper bound of 1D array for element n
	SHARED compositeNumber[]		' number of composite
	SHARED compositeToken[]			' token of composite
	SHARED compositeStart[]			' starting address of composite
	SHARED compositeNext[]			' next available address after composite
	SHARED minval#[]
	SHARED maxval#[]
	SHARED blanks[]
	SHARED charToken[]			' tokens for single characters where they exist
	SHARED subToken[]
	SHARED nestVar[]
	SHARED nestInfo[]
	SHARED nestStep[]
	SHARED nestLimit[]
	SHARED nestCount[]
	SHARED nestToken[]
	SHARED nestLevel[]
	SHARED SSHORT typeConvert[]
	SHARED typeHigher[]

' *****  Common "charset" Arrays  *****

	SHARED UBYTE charsetSymbolInner[]
	SHARED UBYTE charsetUpper[]
	SHARED UBYTE charsetLower[]
	SHARED UBYTE charsetNumeric[]
	SHARED UBYTE charsetUpperLower[]
	SHARED UBYTE charsetUpperNumeric[]
	SHARED UBYTE charsetLowerNumeric[]
	SHARED UBYTE charsetUpperLowerNumeric[]
	SHARED UBYTE charsetUpperToLower[]
	SHARED UBYTE charsetLowerToUpper[]
	SHARED UBYTE charsetVex[]
	SHARED UBYTE charsetHexUpper[]
	SHARED UBYTE charsetHexLower[]
	SHARED UBYTE charsetHexUpperLower[]
	SHARED UBYTE charsetHexUpperToLower[]
	SHARED UBYTE charsetHexLowerToUpper[]
	SHARED UBYTE charsetBackslash[]
	SHARED UBYTE charsetNormalChar[]
	SHARED UBYTE charsetSpaceTab[]
	SHARED UBYTE charsetSuffix[]
	SHARED	xerror$[]
	SHARED	uerror

' *****

	SHARED toms
	SHARED toes
	SHARED a0
	SHARED a1
	SHARED a0_type
	SHARED a1_type
	SHARED oos
	SHARED UBYTE oos[]

	SHARED header
	SHARED infunc
	SHARED got_declare
	SHARED got_function
	SHARED got_object_declaration
	SHARED got_executable
	SHARED got_expression
	SHARED end_program
	SHARED parse_got_function

	SHARED labelNumber

	SHARED insub
	SHARED insub$
	SHARED subCount
	SHARED nestLevel			' nestXXXX in DO and FOR
	SHARED nestCount
	SHARED compositeArg
	SHARED crvtoken

	SHARED ifLine
	SHARED caseCount
	SHARED func_number
	SHARED function_line
	SHARED declareAlloTypeLine
	SHARED declareFuncaddrLine
	SHARED funcaddrFuncNumber
	SHARED dim_array

	SHARED nullstring$
	SHARED nullstringer

	SHARED lastmax
	SHARED lastlabmax


' *****  KEYWORD TOKENS  *****

	SHARED T_ABS
	SHARED T_ALL
	SHARED T_AND
	SHARED T_ANY
	SHARED T_ASC
	SHARED T_ASM
	SHARED T_ATTACH
	SHARED T_AUTO
	SHARED T_AUTOX
	SHARED T_BIN_D
	SHARED T_BINB_D
	SHARED T_BITFIELD
	SHARED T_CASE
	SHARED T_CEIL
	SHARED T_CFUNCTION
	SHARED T_CHR_D
	SHARED T_CJUST_D
	SHARED T_CLOSE
	SHARED T_CLR
	SHARED T_CONSOLE
	SHARED T_CSIZE
	SHARED T_CSIZE_D
	SHARED T_CSTRING_D
	SHARED T_DEC
	SHARED T_DECLARE
	SHARED T_DEF
	SHARED T_DHIGH
	SHARED T_DIM
	SHARED T_DLOW
	SHARED T_DMAKE
	SHARED T_DO
	SHARED T_DOUBLE
	SHARED T_DOUBLEAT
	SHARED T_ELSE
	SHARED T_END
	SHARED T_ENDIF
	SHARED T_EOF
	SHARED T_EXIT
	SHARED T_EXPLICIT
	SHARED T_EXTERNAL
	SHARED T_EXTS
	SHARED T_EXTU
	SHARED T_FALSE
	SHARED T_FIX
	SHARED T_FOR
	SHARED T_FORMAT_D
	SHARED T_FUNCADDR
	SHARED T_FUNCADDRAT
	SHARED T_FUNCADDRESS
	SHARED T_FUNCTION
	SHARED T_GHIGH
	SHARED T_GIANT
	SHARED T_GIANTAT
	SHARED T_GLOW
	SHARED T_GMAKE
	SHARED T_GOADDR
	SHARED T_GOADDRAT
	SHARED T_GOADDRESS
	SHARED T_GOSUB
	SHARED T_GOTO
	SHARED T_HEX_D
	SHARED T_HEXX_D
	SHARED T_HIGH0
	SHARED T_HIGH1
	SHARED T_IF
	SHARED T_IFF
	SHARED T_IFT
	SHARED T_IFZ
	SHARED T_INC
	SHARED T_INCHR
	SHARED T_INCHRI
	SHARED T_INFILE_D
	SHARED T_INLINE_D
	SHARED T_INSTR
	SHARED T_INSTRI
	SHARED T_INT
	SHARED T_INTERNAL
	SHARED T_LCASE_D
	SHARED T_LCLIP_D
	SHARED T_LEFT_D
	SHARED T_LEN
	SHARED T_LJUST_D
	SHARED T_LOF
	SHARED T_LONGDOUBLE
	SHARED T_LONGDOUBLEAT
	SHARED T_LOOP
	SHARED T_LTRIM_D
	SHARED T_MAKE
	SHARED T_MAKEFILE
	SHARED T_MAX
	SHARED T_MID_D
	SHARED T_MIN
	SHARED T_MOD
	SHARED T_NEXT
	SHARED T_NOEXCPTION
'	SHARED T_NOINIT
	SHARED T_NOT
	SHARED T_NULL_D
	SHARED T_OCT_D
	SHARED T_OCTO_D
	SHARED T_OPEN
	SHARED T_OR
	SHARED T_PACKED
	SHARED T_POF
	SHARED T_PRINT
	SHARED T_PROGRAM
	SHARED T_QUIT
	SHARED T_RCLIP_D
	SHARED T_READ
	SHARED T_REDIM
	SHARED T_RETURN
	SHARED T_RIGHT_D
	SHARED T_RINCHR
	SHARED T_RINCHRI
	SHARED T_RINSTR
	SHARED T_RINSTRI
	SHARED T_RJUST_D
	SHARED T_ROTATEL
	SHARED T_ROTATER
	SHARED T_ROUND
	SHARED T_ROUNDNE
	SHARED T_RTRIM_D
	SHARED T_SBYTE
	SHARED T_SBYTEAT
	SHARED T_SEEK
	SHARED T_SELECT
	SHARED T_SET
	SHARED T_SGN
	SHARED T_SFUNCTION
	SHARED T_SHARED
	SHARED T_SHELL
	SHARED T_SIGN
	SHARED T_SIGNED_D
	SHARED T_SINGLE
	SHARED T_SINGLEAT
	SHARED T_SIZE
	SHARED T_SLONG
	SHARED T_SLONGAT
	SHARED T_SMAKE
	SHARED T_SPACE_D
	SHARED T_SSHORT
	SHARED T_SSHORTAT
	SHARED T_STATIC
	SHARED T_STEP
	SHARED T_STOP
	SHARED T_STR_D
	SHARED T_STRING
	SHARED T_STRING_D
	SHARED T_STUFF_D
	SHARED T_SUB
	SHARED T_SUBADDR
	SHARED T_SUBADDRAT
	SHARED T_SUBADDRESS
	SHARED T_SWAP
	SHARED T_TAB
	SHARED T_THEN
	SHARED T_TO
	SHARED T_TRIM_D
	SHARED T_TRUE
	SHARED T_TYPE
	SHARED T_UBOUND
	SHARED T_UBYTE
	SHARED T_UBYTEAT
	SHARED T_UCASE_D
	SHARED T_ULONG
	SHARED T_ULONGAT
	SHARED T_UNION
	SHARED T_UNTIL
	SHARED T_USHORT
	SHARED T_USHORTAT
	SHARED T_VOID
	SHARED T_WHILE
	SHARED T_WRITE
	SHARED T_XLONG
	SHARED T_XLONGAT
	SHARED T_XMAKE
	SHARED T_XOR

' characters and character combos

	SHARED T_LPAREN							'  (
	SHARED T_RPAREN							'  )
	SHARED T_LBRAK							'  [
	SHARED T_RBRAK							'  ]
	SHARED T_LBRACE							'  {
	SHARED T_RBRACE							'  }
	SHARED T_LBRACES						'  {{
	SHARED T_COMMA							'  ,
	SHARED T_SEMI								'  ;
	SHARED T_COLON							'  :
	SHARED T_REM								'
	SHARED T_RSHIFT							'  >>
	SHARED T_LSHIFT							'  <<
	SHARED T_DSHIFT							'  >>>  (sign extend signed types)
	SHARED T_USHIFT							'  <<<
	SHARED T_NOTBIT,  T_TILDA		'  ~
	SHARED T_ANDBIT							'  &
	SHARED T_XORBIT							'  ^
	SHARED T_ORBIT							'  |
	SHARED T_TESTL							'  !!
	SHARED T_NOTL								'  !
	SHARED T_ANDL								'  &&
	SHARED T_XORL								'  ^^
	SHARED T_ORL								'  ||
	SHARED T_CMP								'  ::
	SHARED T_EQL								'  ==
	SHARED T_EQ,  T_NNE					'  =     !<>
	SHARED T_NE,  T_NEQ					'  <>    !=
	SHARED T_LT,  T_NGE					'  <     !>=
	SHARED T_LE,  T_NGT					'  <=    !>
	SHARED T_GE,  T_NLT					'  >=    !<
	SHARED T_GT,  T_NLE					'  >     !<=
	SHARED T_SUBTRACT						'  -
	SHARED T_ADD								'  +
	SHARED T_IDIV								'  \
	SHARED T_MUL								'  *
	SHARED T_DIV								'  /
	SHARED T_REMAINDER					'  %
	SHARED T_POWER							'  **  (not ^, ^ is bitwise XOR)
	SHARED T_PLUS								'  +
	SHARED T_MINUS							'  -
	SHARED T_ADDR_OP						'  &
	SHARED T_HANDLE_OP					'  &&
	SHARED T_STORE_OP						'  (internal)
	SHARED T_ETC								'  ...
	SHARED T_PERCENT						'  %
	SHARED T_XMARK							'  !
	SHARED T_ATSIGN							'  @
	SHARED T_POUND							'  #
	SHARED T_DOLLAR							'  $
	SHARED T_DQUOTE							'  "
	SHARED T_DOT								'  .
	SHARED T_VBAR								'  |
	SHARED T_ULINE							'  _
	SHARED T_QMARK							'  ?
	SHARED T_TICK								'  `
	SHARED T_MARK								'  \x7F

	SHARED ERROR_AFTER_ELSE
	SHARED ERROR_BAD_CASE_ALL
	SHARED ERROR_BAD_GOSUB
	SHARED ERROR_BAD_GOTO
	SHARED ERROR_BAD_SYMBOL
	SHARED ERROR_BITSPEC
	SHARED ERROR_BYREF
	SHARED ERROR_BYVAL
	SHARED ERROR_COMPILER
	SHARED ERROR_COMPONENT
	SHARED ERROR_CROSSED_FUNCTIONS
	SHARED ERROR_DECLARE
	SHARED ERROR_DECLARE_FUNCS_FIRST
	SHARED ERROR_DUP_DECLARATION
	SHARED ERROR_DUP_DEFINITION
	SHARED ERROR_DUP_LABEL
	SHARED ERROR_DUP_TYPE
	SHARED ERROR_ELSE_IN_CASE_ALL
	SHARED ERROR_ENTRY_FUNCTION
	SHARED ERROR_EXPECT_ASSIGNMENT
	SHARED ERROR_EXPLICIT_VARIABLE
	SHARED ERROR_EXPRESSION_STACK
	SHARED ERROR_INTERNAL_EXTERNAL
	SHARED ERROR_KIND_MISMATCH
	SHARED ERROR_LITERAL
	SHARED ERROR_NEST
	SHARED ERROR_OUTSIDE_FUNCTIONS
	SHARED ERROR_OVERFLOW
	SHARED ERROR_REGADDR
	SHARED ERROR_RETYPED
	SHARED ERROR_SCOPE_MISMATCH
	SHARED ERROR_SHARENAME
	SHARED ERROR_SYNTAX
	SHARED ERROR_TOO_FEW_ARGS
	SHARED ERROR_TOO_LATE
	SHARED ERROR_TOO_MANY_ARGS
	SHARED ERROR_TYPE_MISMATCH
	SHARED ERROR_UNDECLARED
	SHARED ERROR_UNDEFINED
	SHARED ERROR_UNIMPLEMENTED
	SHARED ERROR_VOID
	SHARED ERROR_WITHIN_FUNCTION

EXPORT
' Compiler Constants

	$$VALUEABS					= 0				' addressing modes for Value ()
	$$VALUEDISP					= 1
	$$TEXTSECTION				= 0
	$$DATASECTION				= 1
	$$USERSECTION				= 2
	$$STACKSECTION			= 3
	$$XGET							= 0				' get token (also generic GET)
	$$XSET							= 1				' set token (also generic SET)
	$$XADD							= 1				' add token
	$$XNEW							= 2				' add token (override existing)
	$$GETADDR						= 0				' see Composite()
	$$GETHANDLE					= 1				' see Composite()
	$$GETDATAADDR				= 2				' see Composite()
	$$GETDATA						= 3				' see Composite()
	$$NORMAL_SYMBOL			= 0				' see GetSymbol()			normalSymbol
	$$LOCAL_CONSTANT		= 1				' see GetSymbol()			$LOCAL_CONSTANT
	$$GLOBAL_CONSTANT		= 2				' see GetSymbol()			$$GLOBAL_CONSTANT
	$$SHARED_VARIABLE		= 3				' see GetSymbol()			#SharedVariable
	$$EXTERNAL_VARIABLE	= 4				' see GetSymbol()			##ExternalVariable
	$$SOLO_POUND				= 5				' see GetSymbol()			solo #
	$$DUAL_POUND				= 6				' see GetSymbol()			dual ##
	$$COMPONENT					= 7				' see GetSymbol()			.component
	$$NONE							= 0				' not data kind
	$$VAR_TOKEN					= 1				' variable  (built-in or user-defined)
	$$ARRAY_TOKEN				= 2				' whole array of any type
	$$ARRAY_NODE				= 3				' array node of any type
	$$DATA_ADDR					= 4				' data address of any type

' r30 offsets for system variables:
'		replace with computed values as soon as available

	$$xerrorOffset      = 0x0180						' &($$XERROR) - r30
	$$walkbaseOffset    = 0x01B8
	$$walkoffsetOffset  = 0x01BC
	$$softBreakOffset   = 0x01C0

	$$BREAKPOINT   = 0x80000000		' Start token:  indicates BP at this line
	$$CURRENTEXE   = 0x40000000		'      "     :  marks current execution line


' *****  BITFIELD TOKENS  *****

	$$SPACE					= BITFIELD ( 3, 29)		' spaces following token symbol
	$$KIND					= BITFIELD ( 5, 24)		' kind of token
	$$ALLO					= BITFIELD ( 3, 21)		' allocation of data objects
	$$ARGS					= BITFIELD ( 3, 21)		' max # of args to intrinsics
	$$TYPE					= BITFIELD ( 5, 16)		' data type
	$$PREC					= BITFIELD ( 4, 16)		' precedence of operators
	$$NUMBER				= BITFIELD (16,  0)		' token #
	$$RAWTYPE				= BITFIELD ( 8, 16)		' type and allo field
	$$RAWALLO				= BITFIELD ( 8, 16)		' type and allo field
	$$BYTE0					= BITFIELD ( 8,  0)		' byte 0  (low byte)
	$$BYTE1					= BITFIELD ( 8,  8)		' byte 1
	$$BYTE2					= BITFIELD ( 8, 16)		' byte 2
	$$BYTE3					= BITFIELD ( 8, 24)		' byte 3  (high byte)
	$$WORD0					= BITFIELD (16,  0)		' word 0  (low word)
	$$WORD1					= BITFIELD (16, 16)		' word 1  (high word)
	$$CLEAR_BP_EXE	= BITFIELD (30, 0)		' clear BP/EXE from start token


' *****  PROTOTYPE TOKENS  *****

	$$T_SYMBOLS				= 0x00000000
	$$T_VARIABLES			= 0x01000000
	$$T_ARRAYS				= 0x02000000
	$$T_LITERALS			= 0x03000000
	$$T_CONSTANTS			= 0x04000000
	$$T_COMPOSITES		= 0x05000000
	$$T_LABELS				= 0x06000000
	$$T_FUNCTIONS			= 0x07000000
	$$T_ARRAY_SYMBOLS	= 0x08000000
	$$T_CHARCONS			= 0x0B000000
	$$T_SYSCONS				= 0x0C000000
	$$T_STATEMENTS		= 0x0D000000
	$$T_INTRINSICS		= 0x0E000000
	$$T_STATE_INTRIN	= 0x0F000000
	$$T_TYPES					= 0x10000000
	$$T_STARTS				= 0x11000000
	$$T_SEPARATORS		= 0x12000000
	$$T_TERMINATORS		= 0x13000000
	$$T_LPARENS				= 0x14000000
	$$T_RPARENS				= 0x15000000
	$$T_BINARY_OPS		= 0x16000000
	$$T_UNARY_OPS			= 0x17000000
	$$T_ADDR_OPS			= 0x18000000
	$$T_COMMENTS			= 0x19000000
	$$T_CHARACTERS		= 0x1A000000
	$$T_WHITES				= 0x1B000000


' *****  KIND TOKENS  *****

	$$KIND_SYMBOLS				= 0x00
	$$KIND_VARIABLES			= 0x01
	$$KIND_ARRAYS					= 0x02
	$$KIND_LITERALS				= 0x03
	$$KIND_CONSTANTS			= 0x04
'	$$KIND_COMPOSITES			= 0x05			' not used
	$$KIND_LABELS					= 0x06
	$$KIND_FUNCTIONS			= 0x07
	$$KIND_ARRAY_SYMBOLS	= 0x08
	$$KIND_CHARCONS				= 0x0B
	$$KIND_SYSCONS				= 0x0C
	$$KIND_STATEMENTS			= 0x0D
	$$KIND_INTRINSICS			= 0x0E
	$$KIND_STATE_INTRIN		= 0x0F

	$$KIND_STATEMENTS_INTRINSICS      = 0x0F		' long name duplicate

	$$KIND_TYPES					= 0x10
	$$KIND_STARTS					= 0x11
	$$KIND_SEPARATORS			= 0x12
	$$KIND_TERMINATORS		= 0x13
	$$KIND_LPARENS				= 0x14
	$$KIND_RPARENS				= 0x15
	$$KIND_BINARY_OPS			= 0x16
	$$KIND_UNARY_OPS			= 0x17
	$$KIND_ADDR_OPS				= 0x18
	$$KIND_COMMENTS				= 0x19
	$$KIND_CHARACTERS			= 0x1A
	$$KIND_WHITES					= 0x1B
	$$KIND_INLINEASM			= 0x1C


' *****  PRECEDENCE  *****

	$$PREC_NONE				= 0
	$$PREC_ORL				= 1:		$$PREC_LOR			= 1
	$$PREC_XORL				= 1:		$$PREC_LXOR			= 1
	$$PREC_ANDL				= 2
	$$PREC_EQ					= 3:		$$PREC_NNE			= 3:		$$PREC_EQL		= 3
	$$PREC_NE					= 3:		$$PREC_NEQ			= 3
	$$PREC_LT					= 4:		$$PREC_NGE			= 4
	$$PREC_LE					= 4:		$$PREC_NGT			= 4
	$$PREC_GE					= 4:		$$PREC_NLT			= 4
	$$PREC_GT					= 4:		$$PREC_NLE			= 4
	$$PREC_OR					= 5:		$$PREC_ORBIT		= 5
	$$PREC_XOR				= 5:		$$PREC_XORBIT		= 5
	$$PREC_AND				= 6:		$$PREC_ANDBIT		= 6
	$$PREC_SUBTRACT		= 7
	$$PREC_ADD				= 7
	$$PREC_MOD				= 8
	$$PREC_REMAINDER	= 8
	$$PREC_IDIV				= 8
	$$PREC_MUL				= 8
	$$PREC_DIV				= 8
	$$PREC_POWER			= 9
	$$PREC_RSHIFT			= 10
	$$PREC_LSHIFT			= 10
	$$PREC_DSHIFT			= 10
	$$PREC_USHIFT			= 10
	$$PREC_UNARY			= 11
	$$PREC_MINUS			= 11
	$$PREC_PLUS				= 11
	$$PREC_NOT				= 11:   $$PREC_NOTBIT  = 11:   $$PREC_TILDA   = 11
	$$PREC_TESTL			= 11
	$$PREC_NOTL				= 11
	$$PREC_ADDR_OP		= 11
	$$PREC_HANDLE_OP	= 11
	$$PREC_STORE_OP		= 11


' *****  OPERATOR CONVERSION TABLE NUMBERS  *****

	$$COP0      = 0x00
	$$COP1      = 0x10
	$$COP2      = 0x20
	$$COP3      = 0x30
	$$COP4      = 0x40
	$$COP5      = 0x50
	$$COP6      = 0x60
	$$COP7      = 0x70
	$$COP8      = 0x80
	$$COP9      = 0x90
	$$COPA      = 0xA0
	$$COPB			= 0xB0

	$$R0 = 0:    $$R8  =  8:    $$R16 = 16:    $$R24 = 24
	$$R1 = 1:    $$R9  =  9:    $$R17 = 17:    $$R25 = 25
	$$R2 = 2:    $$R10 = 10:    $$R18 = 18:    $$R26 = 26
	$$R3 = 3:    $$R11 = 11:    $$R19 = 19:    $$R27 = 27
	$$R4 = 4:    $$R12 = 12:    $$R20 = 20:    $$R28 = 28
	$$R5 = 5:    $$R13 = 13:    $$R21 = 21:    $$R29 = 29
	$$R6 = 6:    $$R14 = 14:    $$R22 = 22:    $$R30 = 30
	$$R7 = 7:    $$R15 = 15:    $$R23 = 23:    $$R31 = 31

	$$RA0							= $$R10
	$$RA1							= $$R12
	$$IMM16						= 32
	$$NEG16						= 33
	$$LITNUM					= 34
	$$CONNUM					= 35

	$$TYPE_ALLO				= 0xE0	' allocation TYPE_MASK
	$$TYPE_TYPE				= 0x1F	' data type  TYPE_MASK
	$$TYPE_DECLARED		= 0x80	' for functions, go_labels, sub_labels
	$$TYPE_DEFINED		= 0x40	' for functions, go_labels, sub_labels
	$$TYPE_INPUT			= 0x11

	$$MASK_ALLO				= 0xE00000
	$$MASK_DECDEF			= 0xC00000		' declared | defined mask
	$$MASK_DECLARED		= 0x800000		' declared in DECLARE, EXTERNAL, INTERNAL
	$$MASK_DEFINED		= 0x400000		' defined in FUNCTION block

	$$XFUNC						= 0x01				' Native function (see funcKind[])
	$$SFUNC						= 0x02				' System function (see funcKind[])
	$$CFUNC						= 0x03				' C function      (see funcKind[])

'	DECLARE FUNCTION STYLES

	$$FUNC_DECLARE		= 2
	$$FUNC_INTERNAL		= 1
	$$FUNC_EXTERNAL		= 0

	$$ARGS0						= 0x00
	$$ARGS1						= 0x20
	$$ARGS2						= 0x40
	$$ARGS3						= 0x60
	$$ARGS4						= 0x80

	$$MIN_SBYTE				= -128
	$$MAX_SBYTE				=  127
	$$MIN_UBYTE				= 0
	$$MAX_UBYTE				= 255
	$$MIN_SSHORT			= -32768
	$$MAX_SSHORT			= 32767
	$$MIN_USHORT			= 0
	$$MAX_USHORT			= 65535
	$$MIN_SLONG				= -2147483648
	$$MAX_SLONG				= 2147483647
	$$MIN_ULONG				= 0
	$$MAX_ULONG				= 4294967295$$
	$$MIN_XLONG				= $$MIN_SLONG
	$$MAX_XLONG				= $$MAX_ULONG
	$$MIN_GOADDR			= $$MIN_XLONG
	$$MAX_GOADDR			= $$MAX_XLONG
	$$MIN_SUBADDR			= $$MIN_XLONG
	$$MAX_SUBADDR			= $$MAX_XLONG
	$$MIN_FUNCADDR		= $$MIN_XLONG
	$$MAX_FUNCADDR		= $$MAX_XLONG
	$$MIN_SINGLE			= 0sFF7FFFFF
	$$MAX_SINGLE			= 0s7F7FFFFF
	$$MIN_DOUBLE			= 0dFFEFFFFFFFFFFFFF
	$$MAX_DOUBLE			= 0d7FEFFFFFFFFFFFFF
	$$MIN_GIANT				= 0x8000000000000000
	$$MAX_GIANT				= 0x7FFFFFFFFFFFFFFF
' $$MIN_LONGDOUBLE  =
' $$MAX_LONGDOUBLE  =
	$$outdisk					= 2
	$$errors					= 3
	$$infile					= 4
	$$termfile				= 0
	$$diskfile				= 1


' i486 register equivalences

	$$al		= $$R2
	$$dl		= $$R3
	$$bl		= $$R4
	$$cl		= $$R5
	$$ax		= $$R6
	$$dx		= $$R7
	$$bx		= $$R8
	$$cx		= $$R9
	$$eax		= $$R10
	$$edx		= $$R11
	$$ebx		= $$R12
	$$ecx		= $$R13
	$$esi		= $$R26
	$$edi		= $$R27
	$$ebp		= $$R31
	$$esp		= $$R1

	$$o0		= 0x0000
	$$o1		= 0x0001
	$$o2		= 0x0002
	$$o3		= 0x0003
	$$o4		= 0x0004
	$$o5		= 0x0005
	$$o6		= 0x0006
	$$o7		= 0x0007
	$$o8		= 0x0008
	$$o9		= 0x0009
	$$o10		= 0x000A
	$$o11		= 0x000B
	$$o12		= 0x000C
	$$o13		= 0x000D
	$$o14		= 0x000E
	$$o15		= 0x000F
	$$o16		= 0x0010
	$$o17		= 0x0011
	$$o18		= 0x0012
	$$o19		= 0x0013
	$$o20		= 0x0014
	$$o21		= 0x0015
	$$o22		= 0x0016
	$$o23		= 0x0017
	$$o24		= 0x0018
	$$o25		= 0x0019
	$$o26		= 0x001A
	$$o27		= 0x001B
	$$o28		= 0x001C
	$$o29		= 0x001D
	$$o30		= 0x001E
	$$o31		= 0x001F
	$$o32		= 0x0000

' 80486 machine instructions

	$$nope									= 0
	$$adc										= 1
	$$add										= 2
	$$and										= 3
	$$bsf										= 4
	$$bsr										= 5
	$$bt										= 6
	$$btc										= 7
	$$btr										= 8
	$$bts										= 9
	$$call									= 10
	$$cbw										= 11
	$$cdq										= 12
	$$clc										= 13
	$$cld										= 14
	$$cmc										= 15
	$$cmp										= 16
	$$cmpsb									= 17
	$$cmpsw									= 18
	$$cmpsd									= 19
	$$cwd										= 20
	$$cwde									= 21
	$$dec										= 22
	$$div										= 23
	$$f2xm1									= 24
	$$fabs									= 25
	$$fadd									= 26
	$$faddp									= 27
	$$fchs									= 28
	$$fclex									= 29
	$$fnclex								= 30
	$$fcom									= 31
	$$fcomp									= 32
	$$fcompp								= 33
	$$fcos									= 34
	$$fdecstp								= 35
	$$fdiv									= 36
	$$fdivp									= 37
	$$fdivr									= 38
	$$fdivrp								= 39
	$$fild									= 40
	$$fincstp								= 41
	$$fist									= 42
	$$fistp									= 43
	$$fld										= 44
	$$fldlg2								= 45
	$$fldln2								= 46
	$$fldl2e								= 47
	$$fldl2t								= 48
	$$fldpi									= 49
	$$fldz									= 50
	$$fld1									= 51
	$$fmul									= 52
	$$fmulp									= 53
	$$fnop									= 54
	$$fpatan								= 55
	$$fprem									= 56
	$$fprem1								= 57
	$$fptan									= 58
	$$frndint								= 59
	$$fscale								= 60
	$$fsin									= 61
	$$fsincos								= 62
	$$fsqrt									= 63
	$$fst										= 64
	$$fstp									= 65
	$$fstsw									= 66
	$$fnstsw								= 67
	$$fsub									= 68
	$$fsubp									= 69
	$$fsubr									= 70
	$$fsubrp								= 71
	$$ftst									= 72
	$$fucom									= 73
	$$fucomp								= 74
	$$fucompp								= 75
	$$fxam									= 76
	$$fxch									= 77
	$$fxtract								= 78
	$$fyl2x									= 79
	$$fyl2xp1								= 80
	$$f2xn1									= 81
	$$idiv									= 82
	$$imul									= 83
	$$inc										= 84
	$$int										= 85
	$$ja										= 86
	$$jae										= 87
	$$jbe										= 88
	$$jc										= 89
	$$jcxz									= 90
	$$jecxz									= 91
	$$je										= 92
	$$jg										= 93
	$$jge										= 94
	$$jl										= 95
	$$jle										= 96
	$$jna										= 97
	$$jnae									= 98
	$$jnb										= 99
	$$jnbe									= 100
	$$jnc										= 101
	$$jne										= 102
	$$jng										= 103
	$$jnge									= 104
	$$jnl										= 105
	$$jnle									= 106
	$$jno										= 107
	$$jnp										= 108
	$$jns										= 109
	$$jnz										= 110
	$$jo										= 111
	$$jp										= 112
	$$jpe										= 113
	$$jpo										= 114
	$$js										= 115
	$$jz										= 116
	$$jmp										= 117
	$$lahf									= 118
	$$ld										= 119
	$$lea										= 120
	$$lodsb									= 121
	$$lodsw									= 122
	$$lodsd									= 123
	$$loop									= 124
	$$loopz									= 125
	$$loopnz								= 126
	$$movsb									= 127
	$$movsw									= 128
	$$movsd									= 129
	$$mul										= 130
	$$neg										= 131
	$$nop										= 132
	$$not										= 133
	$$or										= 134
	$$pop										= 135
	$$popad									= 136
	$$popfd									= 137
	$$push									= 138
	$$pushad								= 139
	$$pushfd								= 140
	$$rcl										= 141
	$$rcr										= 142
	$$rol										= 143
	$$ror										= 144
	$$rep										= 145
	$$repz									= 146
	$$repnz									= 147
	$$ret										= 148
	$$sahf									= 149
	$$sal										= 150
	$$sar										= 151
	$$shl										= 152
	$$shr										= 153
	$$sbb										= 154
	$$scasb									= 155
	$$scasw									= 156
	$$scasd									= 157
	$$shld									= 158
	$$shrd									= 159
	$$st										= 160
	$$stc										= 161
	$$std										= 162
	$$stosb									= 163
	$$stosw									= 164
	$$stosd									= 165
	$$sub										= 166
	$$test									= 167
	$$xchg									= 168
	$$xor										= 169
	$$jb										= 170
	$$into									= 171
	$$mov										= 172
	$$movsx									= 173
	$$movzx									= 174
	$$zlast									= 175
	$$ufld									= 0x002C0000			' make = $$fld  << 16
	$$ufstp									= 0x00410000			' make = $$fstp << 16
	$$uld										= 0x00770000			' make = $$ld   << 16
	$$ulda									= 0x00780000			' make = $$lda  << 16
	$$ust										= 0x00A00000			' make = $$st   << 16

' 80486 addressing modes

	$$none									= 0
	$$abs										= 1
	$$rel										= 2
	$$reg										= 3
	$$imm										= 4
	$$r0										= 5
	$$ro										= 6
	$$rr										= 7
	$$rs										= 8
	$$regreg								= 9
	$$regimm								= 10
	$$regabs								= 11
	$$regr0									= 12
	$$regro									= 13
	$$regrr									= 14
	$$regrs									= 15
	$$absreg								= 16
	$$r0reg									= 17
	$$roreg									= 18
	$$rrreg									= 19
	$$rsreg									= 20
	$$absimm								= 21
	$$r0imm									= 22
	$$roimm									= 23
	$$rrimm									= 24
	$$rsimm									= 25
	$$regimm8								= 26		'special bogus addressing modes for
	$$absimm8								= 27		'bit-twiddling instructions in Code()
	$$r0imm8								= 28
	$$roimm8								= 29
	$$rrimm8								= 30
	$$rsimm8								= 31

END EXPORT

' ShellEx() output modes
$$Default = 0
$$Console = -1
$$BUFSIZE = 0x1000



' ####################
' #####  Xnt ()  #####  If running as the user program in the environment,
' ####################  the entry function should start running the program.

FUNCTION  Xnt ()
	AUTO hStdOut, w

'	a$ = "Max Reason"
'	a$ = "copyright 1988-2000"
'	a$ = "Windows XBasic compiler"
'	a$ = "maxreason@maxreason.com"
'	a$ = ""

'	addr = &Xnt ()
'	IF ((addr > ##UCODE) AND (addr < ##UCODEZ)) THEN XxxXBasic ()

	hStdOut = XioGetStdOut ()
	XioSetConsoleBufferSize (hStdOut, w, 1500)
	XioCloseStdHandle (hStdOut)


	IF LIBRARY(0) THEN RETURN

END FUNCTION


' ##########################
' #####  XxxXBasic ()  #####
' ##########################

FUNCTION  XxxXBasic ()

	SHARED	maxFuncNumber,  errorCount,  library
	SHARED	tab_sym_ptr,  labelPtr
	SHARED	lastmax,  lastlabmax
	SHARED	XERROR, ofile
	SHARED  fConsole

' *****  Initialize everything, then start the compiler  *****

' determine the directory containing all the xblite dirs/files
	IFT InitEnvVars () THEN QUIT(0)

' check to see if console needs to be displayed
	XstGetCommandLineArguments (@argc, @argv$[])
	IF (argc > 1)	THEN
		FOR i = 1 TO argc - 1
			arg$ = TRIM$(argv$[i])
			IFZ arg$ THEN EXIT FOR
			IF (arg${0} = '-') OR (arg${0} = '/') THEN
				SELECT CASE LCASE$(arg$)
					CASE "-conoff", "/conoff" : fConsole = $$TRUE
					CASE ELSE : arg$ = ""
				END SELECT
			ENDIF
		NEXT i
	ENDIF

	oldLibrary	= library
	library			= $$FALSE
	ofile 			= $$STDOUT
	InitArrays 		()
	InitErrors 		()
	InitVariables ()
	TokensDefined ()
	InitComplex 	()
	library			= oldLibrary

	c = Compile ()

	IFF c THEN
		IF XERROR THEN PrintError (XERROR)
		IF errorCount THEN PRINT "***** ERRORS = "; errorCount; " *****"
'		PRINT "tab_sym_ptr  = "; tab_sym_ptr
'		PRINT "labelPtr     = "; labelPtr
'		PRINT "lastmax      = "; lastmax
'		PRINT "lastlabmax   = "; lastlabmax
'		PRINT "maxFuncNum   = "; maxFuncNumber
	ENDIF

	IFZ fConsole THEN
		a$ = INLINE$ ("Press ENTER to exit >")
	ENDIF

	RETURN (errorCount)
END FUNCTION


' #########################
' #####  AddLabel ()  #####
' #########################

' action =	XGET (0):  Get label token if label has been defined.
'						XADD (1):  Add label token if label not defined (else error).
'						XNEW (2):  Add label token if label not defined this program.
'												(XNEW is for functions only at this time).

FUNCTION  AddLabel (label$, token, action)
	SHARED	tab_lab[],  tab_lab$[],  labhash[],  labaddr[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	labelPtr,  ulabel,  lastlabmax,  pastSystemLabels
	SHARED USHORT  hx[]

	IFZ label$ THEN PRINT "AddLabel(): Error: (label$ = empty string)" : RETURN
	labelLength	= LEN (label$)
	labhash			= 0
	x						= 0
	DO
		labhash = labhash + hx[label${x}]
		INC x
	LOOP WHILE (x < labelLength)
	labhash			= labhash AND 0x00FF
	last				= labhash[labhash, 0]
	ulabhash		= UBOUND(labhash[labhash, ])
	IF (last >= ulabhash) THEN
		ATTACH labhash[labhash, ] TO temp[]
		ulabhash	= ulabhash + (ulabhash >> 1) + 3
		REDIM temp[ulabhash]
		ATTACH temp[] TO labhash[labhash, ]
	ENDIF

'	there are labels with this hash in label symbol table

	IF last THEN
		found	= $$FALSE
		i			= last
		DO
			check  = labhash[labhash, i]
			IF (action = $$XNEW) THEN
				IF (check < pastSystemLabels) THEN EXIT DO
			ENDIF
			IF (labelLength = LEN (tab_lab$[check])) THEN
				IF (tab_lab$[check] = label$) THEN found = $$TRUE: EXIT DO
			ENDIF
			DEC i
		LOOP WHILE (i)
		IF action THEN
			IF found THEN
				RETURN (tab_lab[check])
			ELSE
				INC last
				labhash[labhash, 0]			= last
				labhash[labhash, last]	= labelPtr
				token = (token AND 0xFFFF0000) OR labelPtr
				IF (labelPtr >= ulabel) THEN
					ulabel = ulabel + ulabel + 1
					REDIM labaddr[ulabel]
					REDIM tab_lab[ulabel]
					REDIM tab_lab$[ulabel]
				ENDIF
				tab_lab[labelPtr]		= token
				tab_lab$[labelPtr]	= label$
				INC labelPtr
				RETURN (token)
			ENDIF
		ELSE
			IF found THEN RETURN (check) ELSE RETURN ($$FALSE)
		ENDIF
	ELSE

' there are no labels with this hash in label symbol table

		IF action THEN
			labhash[labhash, 0] = 1
			labhash[labhash, 1] = labelPtr
			token = (token AND 0xFFFF0000) OR labelPtr
			IF (labelPtr >= ulabel) THEN
				ulabel = ulabel + ulabel
				REDIM labaddr[ulabel]
				REDIM tab_lab[ulabel]
				REDIM tab_lab$[ulabel]
			ENDIF
			tab_lab[labelPtr]		= token
			tab_lab$[labelPtr]	= label$
			INC labelPtr
			RETURN (token)
		ENDIF
	ENDIF
	RETURN ($$FALSE)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  AddSymbol ()  #####
' ##########################

FUNCTION  AddSymbol (symbol$, tokoid, f_number)
	SHARED	maxFuncNumber
	SHARED	bogusFunction,  freezeFlag,  freezeFunction
	SHARED	hash%[]
	SHARED	funcSymbol$[],  funcLabel$[],  funcToken[]
	SHARED	funcScope[],  funcType[],  funcKind[],  funcArgSize[],  funcArg[]
	SHARED	defaultType[]
	SHARED	funcFrameSize[]
	SHARED	autoAddr[],  autoxAddr[],  inargAddr[]
	SHARED	compositeToken[], compositeNumber[]
	SHARED	compositeNext[], compositeStart[]
	SHARED	r_addr[],  r_addr$[],  m_reg[],  m_addr[], m_addr$[]
	SHARED	tabType[],  tab_sym$[],  tab_sym[],  tabArg[],  tokens[]
	SHARED	typeSize[],  typeSize$[],  typeAlias[],  typeAlign[]
	SHARED	typeSuffix$[],  typeSymbol$[],  typeToken[]
	SHARED	typeEleCount[],  typeEleSymbol$[],  typeEleToken[],  typeEleAddr[]
	SHARED	typeEleSize[],  typeEleType[],  typeEleArg[]
	SHARED	typeEleVal[],  typeElePtr[]
	SHARED	typeEleStringSize[],  typeEleUBound[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_EXTERNAL,  T_SHARED
	SHARED	T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED	func_number,  function_line
	SHARED	parse_got_function,  got_function,  hfn$
	SHARED	tab_sym_ptr,  typePtr,  uFunc,  uType
	SHARED	lastmax
	SHARED USHORT  hx[]

'	IFZ symbol$ THEN GOTO eeeCompiler

	scope = 0
	found = 0
	token = tokoid
	f_num = f_number
	kind = token{$$KIND}
	rtype = token{$$TYPE}
	slength = LEN (symbol$)
	spaces = token AND 0xE0000000
	token = token AND 0x1FFF0000
	k = tokens[1] AND 0x1FFFFFFF

' see if symbol has explicit scope prefix - # or ##
' see if first token on source line is a scope keyword
' see if first token on source line is a built-in data-type
' see if first token on source line is a user-defined data-type

	kk = k{$$KIND}
	typetoken = TypeToken(k)
	scopetoken = ScopeToken(k)
	IF typetoken THEN intypes = $$TRUE
	IF (kk = $$KIND_TYPES) THEN intypes = $$TRUE

	IF symbol$ THEN
		IF (symbol${0} == '#') THEN
			IF (symbol${1} == '#') THEN scope = $$EXTERNAL ELSE scope = $$SHARED
		ENDIF
	ENDIF

	IF (k = T_SHARED) THEN inshared = $$TRUE
	IF (k = T_EXTERNAL) THEN
		kk = tokens[2] AND 0x1FFFFFFF
		kkk = kk{$$KIND}
		IF (kkk = $$KIND_WHITES) THEN kk = tokens[3] AND 0x1FFFFFFF
		IF ((kk != T_FUNCTION) AND (kk != T_SFUNCTION) AND (kk != T_CFUNCTION)) THEN inshared = $$TRUE
	ENDIF

	SELECT CASE kind
		CASE $$KIND_FUNCTIONS
					GOTO add_function_symbol
		CASE $$KIND_TYPES
					GOTO add_type_symbol
		CASE $$KIND_VARIABLES
					IFZ got_function THEN
						IFZ (parse_got_function OR inshared OR intypes OR scope) THEN
							kind = $$KIND_SYMBOLS
							token	= (token AND 0xE0FFFFFF) + $$T_SYMBOLS
						ENDIF
					ENDIF
		CASE $$KIND_ARRAYS
					IFZ got_function THEN
						IFZ (parse_got_function OR inshared OR intypes OR scope) THEN
							kind	= $$KIND_ARRAY_SYMBOLS
							token	= (token AND 0xE0FFFFFF) + $$T_ARRAY_SYMBOLS
						ENDIF
					ENDIF
	END SELECT
	GOTO add_normal_symbol


' ******************************
' *****  FUNCTION SYMBOLS  *****
' ******************************

add_function_symbol:
	FOR x = 0 TO maxFuncNumber
		funcLength = LEN (funcSymbol$[x])
		IF (slength = funcLength) THEN
			IF (symbol$ = funcSymbol$[x]) THEN found = $$TRUE: EXIT FOR
		ENDIF
	NEXT x

	IF found THEN
		token = spaces OR funcToken[x]
	ELSE
		INC maxFuncNumber
		IF (maxFuncNumber >= uFunc) THEN
			uFunc = uFunc + 64
			REDIM compositeNumber[uFunc]
			REDIM compositeStart[uFunc, ]
			REDIM compositeToken[uFunc, ]
			REDIM compositeNext[uFunc, ]
			REDIM funcFrameSize[uFunc]
			REDIM defaultType[uFunc]
			REDIM funcSymbol$[uFunc]
			REDIM funcLabel$[uFunc]
			REDIM inargAddr[uFunc]
			REDIM autoxAddr[uFunc]
			REDIM	autoAddr[uFunc]
			REDIM funcToken[uFunc]
			REDIM funcScope[uFunc]
			REDIM funcKind[uFunc]
			REDIM funcType[uFunc]
			REDIM funcArgSize[uFunc]
			REDIM funcArg[uFunc, ]
			REDIM hash%[uFunc, ]
		ENDIF
		DIM temp%[255, ]
		ATTACH temp%[] TO hash%[maxFuncNumber, ]		' hash array for new function
		token												= token OR maxFuncNumber
		funcSymbol$[maxFuncNumber]	= symbol$
		funcToken[maxFuncNumber]		= token
		token = spaces OR token
	ENDIF

	IF function_line THEN
		parse_got_function = $$TRUE
		checkNumber = token{$$NUMBER}
		IF freezeFlag AND (checkNumber != freezeFunction) THEN
			bogusFunction = $$TRUE
			token = funcToken[freezeFunction]
		ELSE
			func_number = checkNumber
			hfn$ = HEX$(func_number)
		ENDIF
	ENDIF
	RETURN (token)


' **************************
' *****  TYPE SYMBOLS  *****
' **************************

add_type_symbol:
'	usymbol$ = UCASE$ (symbol$)
' FOR i = 1 TO typePtr
'		IF (usymbol$ = typeSymbol$[i]) THEN GOTO eeeDupType
'	NEXT i

	IF (typePtr >= uType) THEN
		uType = uType + 32
		REDIM	typeSize[uType]
		REDIM	typeSize$[uType]
		REDIM	typeAlias[uType]
		REDIM	typeAlign[uType]
		REDIM	typeToken[uType]
		REDIM	typeSuffix$[uType]
		REDIM	typeSymbol$[uType]
		REDIM	typeEleCount[uType]
		REDIM	typeEleSymbol$[uType,]
		REDIM	typeEleToken[uType,]
		REDIM typeEleAddr[uType,]
		REDIM	typeEleSize[uType,]
		REDIM typeEleType[uType,]
		REDIM typeEleArg[uType,]
		REDIM	typeEleVal[uType,]
		REDIM	typeElePtr[uType,]
		REDIM typeEleStringSize[uType,]
		REDIM typeEleUBound[uType,]
	ENDIF
	typeToken = $$T_TYPES + typePtr
	typeSymbol$[typePtr]	= symbol$
	typeToken[typePtr]		= typeToken
	INC typePtr
	RETURN (spaces + typeToken)


' ****************************
' *****  NORMAL SYMBOLS  *****
' ****************************

add_normal_symbol:
	SELECT CASE kind
		CASE $$KIND_SYMBOLS, $$KIND_ARRAY_SYMBOLS							: f_num = 0
		CASE $$KIND_LITERALS, $$KIND_SYSCONS, $$KIND_CHARCONS	: f_num = 0
	END SELECT

' 2000/12/30 - ??? maybe not necessary ???

	IF scope THEN
		token = token AND 0xFF1FFFFF
		token = token OR (scope << 21)
	ENDIF

	hash = 0
	FOR x = 0 TO slength - 1
		hash = hash + hx[symbol${x}]
	NEXT x
	hash = hash AND 0x00FF

' no symbol with this hash yet ???

	IFZ hash%[f_num, hash, ] THEN
		DIM temp%[7]
		temp%[0] = 1
		temp%[1] = tab_sym_ptr
		token = token OR tab_sym_ptr
		tab_sym[tab_sym_ptr] = token
		tabType[tab_sym_ptr] = rtype
		tab_sym$[tab_sym_ptr] = symbol$
		ATTACH temp%[] TO hash%[f_num, hash, ]
		INC tab_sym_ptr
		IF (tab_sym_ptr > UBOUND(tab_sym[])) THEN
			uTab = tab_sym_ptr + (tab_sym_ptr >> 2) OR 7
			REDIM r_addr[uTab]
			REDIM r_addr$[uTab]
			REDIM m_reg[uTab]
			REDIM m_addr[uTab]
			REDIM m_addr$[uTab]
			REDIM tab_sym$[uTab]
			REDIM tabType[uTab]
			REDIM tab_sym[uTab]
			REDIM tabArg[uTab, ]
		ENDIF
		RETURN (spaces OR token)
	ENDIF

' already a symbol with this hash

	ATTACH hash%[f_num, hash, ] TO temp%[]
	uhash = UBOUND(temp%[])
	last = temp%[0]
	IF (last = uhash) THEN
		uhash	= uhash + 8
		REDIM temp%[uhash]
	ENDIF

' Look for object in symbol table

	found = $$FALSE
	FOR hash_ptr = 1 TO last
		entry = temp%[hash_ptr]
		checks = tab_sym[entry]
		IF (kind != checks{$$KIND}) THEN DO NEXT
		IF (slength = LEN(tab_sym$[entry])) THEN
			IF (symbol$ = tab_sym$[entry]) THEN found = $$TRUE: EXIT FOR
		ENDIF
	NEXT hash_ptr

' if symbol was found, return its token, otherwise make a symbol table entry

	IF found THEN
		ATTACH temp%[] TO hash%[f_num, hash, ]
		token = tab_sym[entry]
	ELSE
		temp%[0] = last + 1
		temp%[hash_ptr] = tab_sym_ptr
		ATTACH temp%[] TO hash%[f_num, hash, ]
		token = token OR tab_sym_ptr
		tabType[tab_sym_ptr] = rtype
		tab_sym[tab_sym_ptr] = token
		tab_sym$[tab_sym_ptr] = symbol$
		INC tab_sym_ptr
		IF (tab_sym_ptr > UBOUND(tab_sym[])) THEN
			uTab = tab_sym_ptr + (tab_sym_ptr >> 2) OR 7
			REDIM r_addr[uTab]
			REDIM r_addr$[uTab]
			REDIM m_reg[uTab]
			REDIM m_addr[uTab]
			REDIM m_addr$[uTab]
			REDIM tab_sym$[uTab]
			REDIM tabType[uTab]
			REDIM tab_sym[uTab]
			REDIM tabArg[uTab, ]
		ENDIF
	ENDIF
	RETURN (spaces OR token)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  AlloToken ()  #####
' ##########################

FUNCTION  AlloToken (token)
	SHARED	T_AUTO,  T_AUTOX,  T_STATIC,  T_SHARED,  T_EXTERNAL

	SELECT CASE token
		CASE	T_AUTO, T_AUTOX, T_STATIC, T_SHARED, T_EXTERNAL:  RETURN (token)
	END SELECT
	RETURN (0)
END FUNCTION


' ################################
' #####  AssemblerSymbol ()  #####
' ################################

FUNCTION  AssemblerSymbol (symbol$)
	SHARED UBYTE	charsetSymbolInner[]

	IFZ symbol$ THEN GOTO eeeCompiler
	offset	= LEN(symbol$) - 1
	charz		= symbol${offset}
	IF charsetSymbolInner[charz] THEN RETURN
	IF (offset <= 0) THEN RETURN
	DEC offset
	chary		= symbol${offset}
	IF charsetSymbolInner[chary] THEN
		SELECT CASE charz
			CASE '@':		symbol$ = RCLIP$(symbol$, 1) + "%SBYTE"
			CASE '%':		symbol$ = RCLIP$(symbol$, 1) + "%SSHORT"
			CASE '&':		symbol$ = RCLIP$(symbol$, 1) + "%SLONG"
			CASE '~':		symbol$ = RCLIP$(symbol$, 1) + "%XLONG"
			CASE '!':		symbol$ = RCLIP$(symbol$, 1) + "%SINGLE"
			CASE '#':		symbol$ = RCLIP$(symbol$, 1) + "%DOUBLE"
			CASE ELSE:	GOTO eeeCompiler
		END SELECT
	ELSE
		SELECT CASE chary
			CASE '@':		symbol$ = RCLIP$(symbol$, 2) + "%UBYTE"
			CASE '%':		symbol$ = RCLIP$(symbol$, 2) + "%USHORT"
			CASE '&':		symbol$ = RCLIP$(symbol$, 2) + "%ULONG"
			CASE '$':		symbol$ = RCLIP$(symbol$, 2) + "%GIANT"
      CASE '#':		symbol$ = RCLIP$(symbol$, 2) + "%LONGDOUBLE"
			CASE ELSE:	GOTO eeeCompiler
		END SELECT
	ENDIF
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #############################
' #####  AssignAddress () #####
' #############################

FUNCTION  AssignAddress (token)
	SHARED	library
	SHARED	reg86$[],  reg86c$[]
	SHARED	autoAddr[],  autoxAddr[],  inargAddr[]
	SHARED	xargNum,  xargAddr[],  xargName$[]
	SHARED	r_addr[],  r_addr$[],  m_reg[],  m_addr[],  m_addr$[]
	SHARED	tabType[],  tab_sym[],  tab_sym$[],  labaddr[]
	SHARED	uType,  typeAlias[],  typeAlign[]
	SHARED	typeSize[],  typeSize$[],  typeSymbol$[],  typeToken[]
	SHARED	XERROR,  ERROR_BAD_CHARCON,  ERROR_BAD_SYMBOL,  ERROR_COMPILER
	SHARED	ERROR_DUP_DECLARATION,  ERROR_DUP_DEFINITION,  ERROR_SCOPE_MISMATCH
	SHARED	ERROR_TOO_MANY_ARGS,  ERROR_TYPE_MISMATCH,  ERROR_UNDEFINED
	SHARED	func_number,  hfn$,  sharename$,  xframe$
	SHARED	externalAddr, programName$
	SHARED	programTypeChunk,  functionTypeChunk
	SHARED	compositeNumber[],  compositeToken[]
	SHARED	compositeStart[],  compositeNext[]
	SHARED UBYTE	charsetSymbolInner[]
	SHARED UBYTE	charsetBackslash[]
	STATIC GOADDR makeAddrKind[]
	STATIC GOADDR makeAddrAllo[]

	IFZ makeAddrKind[] THEN GOSUB InitArrays
	d_allo = token{$$ALLO}
	kind = token{$$KIND}
	e = token{$$NUMBER}
	d_type = tabType[e]
	IFZ d_type THEN d_type = TheType (token)

' handle explicit #Shared and ##External scope

	a = d_allo																				' scope
	stealtype = 0																			' # : ##
	IF tab_sym$[e] THEN																' symbol$
		IF (tab_sym$[e]{0} = '#') THEN									' # 1st byte
			a = $$SHARED																	' #SharedVariable
			stealtype = $$TRUE
			IF (tab_sym$[e]{1} = '#') THEN a = $$EXTERNAL	' ##ExternalVariable
			IF d_allo THEN																' explicit scope in token
				IF (a != d_allo) THEN GOTO eeeScopeMismatch	' AUTOX #Shared, ##External
			ENDIF
		ENDIF
	ENDIF
	d_allo = a
	tk = tab_sym[e]									' token
	tk = tk AND NOT $$MASK_ALLO			' clear scope field
	tk = tk OR (a << 21)						' imbed scope in token
	tab_sym[e] = tk									' update token

	o_type = d_type
	alloType = d_type

	SELECT CASE d_allo
		CASE $$AUTO, $$AUTOX	: f_num = func_number
		CASE $$ARGUMENT				: f_num = func_number
														IF (d_type >= $$SCOMPLEX) THEN
															alloType = $$XLONG
'															d_type = $$XLONG
														ENDIF
		CASE ELSE:							f_num = 0
	END SELECT

	IF m_addr$[e] THEN
		IF (d_allo = $$ARGUMENT) THEN GOTO eeeDupDefinition		' same argument twice
		RETURN
	ENDIF

' special allocation size cases

	SELECT CASE kind
		CASE $$KIND_VARIABLES	: IF (d_type < $$SLONG) THEN d_type = $$SLONG : alloType = $$SLONG
		CASE $$KIND_ARRAYS		: alloType = $$XLONG
	END SELECT

' get allocation size and alignment values

	IF (alloType < $$SCOMPLEX) THEN
		osize			= typeSize[alloType]
		osize$		= typeSize$[alloType]
		asize			= typeAlign[alloType]
		IF (asize = 8) THEN asize = 4				' WindowsNT
		usize			= asize - 1
		amask			= -asize
		utype			= $$FALSE
	ELSE
		osize			= 4
		osize$		= "4"
		asize			= 4
		usize			= 3
		amask			= -4
		ccsize		= typeSize[alloType]
		align			= typeAlign[alloType]
		calign		= align - 1
		cmask			= -align
		utype			= $$TRUE
		onum			= compositeNumber[f_num]					' old composite number
		nnum			= onum + 1												' new composite number
		compositeNumber[f_num] = nnum								' ditto
		IFZ onum THEN																' 1st composite this function
			DIM ct[15]
			DIM cs[15]
			DIM cn[15]
			ATTACH ct[] TO compositeToken[f_num, ]
			ATTACH cs[] TO compositeStart[f_num, ]
			ATTACH cn[] TO compositeNext[f_num, ]
			compositeToken = $$T_VARIABLES + ($$XLONG << 16)
			IF f_num THEN scope = $$AUTOX ELSE scope = $$SHARED
			compositeToken = compositeToken OR (scope << 21)
			compositeToken = AddSymbol (@".composites", compositeToken, f_num)
			compositeToken = compositeToken OR (scope << 21)
			tab_sym[compositeToken{$$NUMBER}] = compositeToken
			compositeToken[f_num, 0] = compositeToken
			AssignAddress (compositeToken)
			IF XERROR THEN EXIT FUNCTION
		ENDIF
		IFZ nnum{4, 0} THEN													' if MOD 16, make more room
			unum		= onum + 16
			ATTACH compositeToken[f_num, ] TO ct[]
			ATTACH compositeStart[f_num, ] TO cs[]
			ATTACH compositeNext[f_num, ] TO cn[]
			REDIM ct[unum]
			REDIM cs[unum]
			REDIM cn[unum]
			ATTACH ct[] TO compositeToken[f_num,]
			ATTACH cs[] TO compositeStart[f_num,]
			ATTACH cn[] TO compositeNext[f_num,]
		ENDIF
		newStart	= compositeNext[f_num, onum]
		newStart	= (newStart + calign) AND cmask
		newNext		= newStart + ccsize
		compositeToken[f_num, nnum] = token
		compositeStart[f_num, nnum] = newStart
		compositeNext[f_num, nnum] = newNext
	ENDIF

' Dispatch on basis of kind to routine to assign address

	GOTO @makeAddrKind[kind]
	GOTO eeeCompiler


' *********************************************************************
' *****  Routines to assign addresses to different kinds of data  *****
' *********************************************************************

' *****************************
' *****  $$KIND_CHARCONS  *****
' *****************************

make_addr_charcon:
	charcon$		= tab_sym$[e]
	chartest		= charcon${1}
	IF (chartest = '\\') THEN
		chartest	= charcon${2}
		chartest	= charsetBackslash[chartest]
	ENDIF
	r_addr$			= HEXX$ (chartest, 4)
	r_addr[e]		= $$IMM16
	r_addr$[e]	= r_addr$
	m_addr$[e]	= r_addr$
	RETURN

' ******************************
' *****  $$KIND_CONSTANTS  *****
' ******************************

make_addr_constant:
	IF (d_type = $$STRING) THEN
		IF m_addr$[e] THEN PRINT "dupdec0": GOTO eeeDupDeclaration
		m_addr$[e] = "declared"
		RETURN
	ENDIF
	IF (d_allo != $$SHARED) THEN m_addr$[e] = "local": RETURN
	m_addr$[e] = "shared.local"
	symbol$ = tab_sym$[e]
	ts = AddSymbol (@symbol$, token, 0)
	IF XERROR THEN RETURN
	tse = ts{$$NUMBER}
	r_addr = r_addr[tse]
	IF r_addr THEN r_addr[e] = r_addr ELSE GOTO eeeUndefined
	token = token AND 0xFFFF0000
	token = token OR tse
	tab_sym[e] = token									' point local entry at shared entry
	RETURN

' *****************************
' *****  $$KIND_LITERALS  *****
' *****************************

make_addr_literal:
	IF (d_type = $$STRING) THEN
		m_addr$ = "addr @_string." + HEX$(e, 4) + "." + programName$
		m_addr$[e] = m_addr$
		RETURN
	ENDIF

	lit$		= tab_sym$[e]
	litLen	= LEN (lit$)
	lastOff	= litLen - 1
	nonAsm	= $$FALSE
	suffix	= $$FALSE
	DO UNTIL charsetSymbolInner [lit${lastOff}]						' strip type-suffix
		DEC lastOff
		test	= $$TRUE
	LOOP
	IF test THEN lit$ = LEFT$(lit$, lastOff+1)
	IF (litLen >= 2) THEN
		IF (lit${0} = '0') THEN
			IF ((lit${1} = 'b') OR (lit${1} = 'o')) THEN			' "0b..." or "0o..."
				nonAsm	= $$TRUE
			ENDIF
		ENDIF
	ENDIF

	SELECT CASE token{$$TYPE}
		CASE $$DOUBLE	: GOTO literalFLOAT
		CASE $$LONGDOUBLE : GOTO literalFLOAT
		CASE $$SINGLE	: GOTO literalFLOAT
		CASE $$GIANT	: GOTO literalGIANT
		CASE $$USHORT	: GOTO literalUSHORT
		CASE $$ULONG	: GOTO literalULONG
		CASE ELSE			: GOTO literalSLONG
	END SELECT

literalFLOAT:
	r_addr[e] = $$LITNUM
	IF nonAsm THEN PRINT "nonAsm": GOTO eeeCompiler
	r_addr$[e] = lit$
	m_addr$[e] = lit$
	RETURN

literalGIANT:
	r_addr[e] = $$LITNUM
	IF nonAsm THEN lit$ = HEXX$(GIANT(lit$), 8)
	r_addr$[e] = lit$
	m_addr$[e] = lit$
	RETURN

literalSLONG:
	value = XLONG (lit$)
	IF ((value < 0) AND (value >= -65535)) THEN
		r_addr[e] = $$NEG16
	ELSE
		r_addr[e] = $$LITNUM
	ENDIF
	IF nonAsm THEN lit$ = HEXX$(XLONG(lit$), 8)
	r_addr$[e] = lit$
	m_addr$[e] = lit$
	RETURN

literalUSHORT:
	r_addr[e] = $$IMM16
	IF nonAsm THEN lit$ = HEXX$(XLONG(lit$), 8)
	r_addr$[e] = lit$
	m_addr$[e] = lit$
	RETURN

literalULONG:
	r_addr[e] = $$LITNUM
	IF nonAsm THEN lit$ = HEXX$(ULONG(lit$), 8)
	r_addr$[e] = lit$
	m_addr$[e] = lit$
	RETURN


' **************************************************
' *****  $$KIND_VARIABLES  and  $$KIND_ARRAYS  *****
' **************************************************

make_addr_array:
make_addr_variable:
	GOTO @makeAddrAllo [d_allo]
	GOTO eeeCompiler


' ************************************************************************
' *****  FOR VARIABLES AND ARRAYS  ******  (and structures someday)  *****
' ************************************************************************
' *****  Routines to assign addresses to data of various allocation  *****
' ************************************************************************

' **********************
' *****  ARGUMENT  *****
' **********************

make_addr_argument:
	IF autoAddr[func_number] THEN PRINT "ass3": GOTO eeeCompiler
	x_addr			= inargAddr[func_number]
	IFZ x_addr THEN x_addr = 8								' low 2 words = return addr, entry ebp
	x_addr			= (x_addr + usize) AND amask
	m_addr$[e]	= "ebp+" + STRING (x_addr)
	m_addr[e]		= x_addr
	m_reg[e]		= $$ebp
	z_addr			= x_addr + osize
	inargAddr[func_number] = z_addr
	IF (z_addr > 72) THEN GOTO eeeTooManyArgs
	RETURN

' ****************************
' *****  AUTO and AUTOX  *****
' ****************************

make_addr_auto:
make_addr_autox:
	x_addr			= autoxAddr[func_number]
	IFZ x_addr THEN x_addr = 20
	x_addr			= ((x_addr + usize) AND amask) + osize
	m_reg[e]		= $$ebp
	m_addr[e]		= -x_addr
	m_addr$[e]	= "ebp" + STRING (-x_addr)
	IF utype THEN GOSUB AddToFunctionTypeChunk
	autoxAddr[func_number] = x_addr
	RETURN

' ********************
' *****  STATIC  *****
' ********************

make_addr_static:
	SELECT CASE kind
		CASE $$KIND_VARIABLES	: symbol$ = "%" + HEX$(func_number) + "%" + tab_sym$[e] + "." + programName$
		CASE $$KIND_ARRAYS		: symbol$ = "%%" + HEX$(func_number) + "%%" + tab_sym$[e] + "." + programName$
	END SELECT
	x_addr				= (externalAddr + usize) AND amask
	symLen				= LEN (symbol$)
	last					= symbol${symLen-1}
	IFZ charsetSymbolInner[last] THEN AssemblerSymbol (@symbol$)
	IF m_addr[e] THEN GOTO eeeCompiler
	tabType[e]		= o_type
	m_addr$[e]		= symbol$
	m_addr[e]			= x_addr
	externalAddr	= x_addr + osize
'	EmitAsm (@".data")
'	EmitAsm ("align	" + osize$)
'	EmitAsm (symbol$ + ":	db " + osize$ + " dup 0")
	EmitAsm (@"data section 'globals$statics'")
	EmitAsm ("align	" + osize$)
	EmitAsm (symbol$ + ":	db " + osize$ + " dup ?")
	EmitAsm (@".code")
	RETURN

' ********************
' *****  SHARED	 *****
' ********************

make_addr_shared:
	asymbol$ = tab_sym$[e]
	SELECT CASE kind
		CASE $$KIND_VARIABLES	: symbol$ = sharename$ + tab_sym$[e] + "." + programName$
		CASE $$KIND_ARRAYS		: symbol$ = sharename$ + "%%" + tab_sym$[e] + "." + programName$
	END SELECT

	symLen = LEN (symbol$)
	last = symbol${symLen-1}
	IFZ charsetSymbolInner[last] THEN AssemblerSymbol (@symbol$)

	IF m_addr[e] THEN GOTO eeeCompiler

	ta = AddSymbol (@asymbol$, token, 0)
	ts = AddSymbol (@symbol$, token, 0)
	s = ts{$$NUMBER}
	a = ta{$$NUMBER}
	aaa = tabType[a]
	aas = tabType[s]
	aao = o_type
	aad = d_type
	IF aaa THEN o_type = aaa

	tabType[e] = o_type
	symbol$ = "%" + symbol$

	IF m_addr$[s] THEN 'changed from m_addr[s]
		m_addr$[e] = symbol$
		m_addr[e] = m_addr[s]
		IF (tabType[s] != o_type) THEN GOTO eeeTypeMismatch
	ELSE
		x_addr = (externalAddr + usize) AND amask
		m_addr$[e] = symbol$
		m_addr$[s] = symbol$
		m_addr[e] = x_addr
		m_addr[s] = x_addr
		tabType[s] = o_type
		tabType[e] = o_type
		externalAddr = x_addr + osize
		IF utype THEN GOSUB AddToProgramTypeChunk
'		EmitAsm (@".data")
'		EmitAsm ("align	" + osize$)
'		EmitAsm (symbol$ + ":	db  " + osize$ + " dup 0")
		EmitAsm (@"data section 'globals$shared'")
		EmitAsm ("align	" + osize$)
		EmitAsm (symbol$ + ":	db " + osize$ + " dup ?")
		EmitAsm (@".code")
	ENDIF
	RETURN


' **********************
' *****  EXTERNAL  *****
' **********************

make_addr_external:
	IF (kind = $$KIND_ARRAYS) THEN array$ = "%"

	asymbol$ = sharename$ + tab_sym$[e]

	IFZ sharename$ THEN
		symbol$	= "_" + array$ + tab_sym$[e]
	ELSE
'		symbol$	= "_" + sharename$ + array$ + tab_sym$[e]
		symbol$	= "_" + tab_sym$[e]
	ENDIF

	symLen = LEN (symbol$)
	last = symbol${symLen-1}
	IFZ charsetSymbolInner[last] THEN AssemblerSymbol (@symbol$)
	ta = AddSymbol (@symbol$, token, 0)
	ts = AddSymbol (@symbol$, token, 0)
	s = ts{$$NUMBER}
	a = ta{$$NUMBER}
	aaa = tabType[a]
	aas = tabType[s]
	aao = o_type
	aad = d_type
	IF aaa THEN o_type = aaa		'extcomp

	IF tabType[s] THEN
		IF (tabType[s] != o_type) THEN GOTO eeeTypeMismatch
	ELSE
		tabType[s] = o_type
	ENDIF

	tabType[e] = o_type
	IF m_addr$[s] THEN
		m_addr$[e] = m_addr$[s]
		m_addr[e] = m_addr[s]
		m_reg[e] = m_reg[s]
	ELSE
		labelToken = AddLabel (@symbol$, $$T_LABELS, $$XADD)
		ln = labelToken{$$NUMBER}
		labaddr = labaddr[ln]
		IF labaddr THEN
			x_addr = labaddr
		ELSE
			x_addr = (externalAddr + usize) AND amask
'			labaddr[ln]	= x_addr
		ENDIF
		m_reg[s] = 0
		m_reg[e] = 0
		m_addr[s] = x_addr
		m_addr[e] = x_addr
		m_addr$ = symbol$
		m_addr$[e] = m_addr$
		m_addr$[s] = m_addr$
		externalAddr = x_addr + osize
		tabType[s] = tabType[e]
		IF utype THEN GOSUB AddToProgramTypeChunk
'		EmitAsm (@"DATA SECTION SHARED \"shr_data\"")	' I think this was not the correct way to do this - GH

'		EXTERNAL Variables must be declared in the .bss section so that they will be properly shared!
		EmitAsm (@"data section 'globals$externals'")
		EmitAsm (symbol$ + " db " + osize$ + " dup ?")
		EmitAsm (@".code")

	ENDIF
	RETURN


' *****  Add size of this user-type to accumulating chunk size needed

SUB AddToFunctionTypeChunk
	functionTypeChunk = functionTypeChunk + calign AND cmask
	functionTypeChunk = functionTypeChunk + ccsize
END SUB

SUB AddToProgramTypeChunk
	programTypeChunk = programTypeChunk + calign AND cmask
	programTypeChunk = programTypeChunk + ccsize
END SUB


' *****************************
' *****  SUB  InitArrays  *****
' *****************************

SUB InitArrays
	DIM makeAddrKind[31]
	makeAddrKind [ $$KIND_VARIABLES		] = GOADDRESS (make_addr_variable)
	makeAddrKind [ $$KIND_CONSTANTS		] = GOADDRESS (make_addr_constant)
	makeAddrKind [ $$KIND_SYSCONS			] = GOADDRESS (make_addr_constant)
	makeAddrKind [ $$KIND_LITERALS		] = GOADDRESS (make_addr_literal)
	makeAddrKind [ $$KIND_CHARCONS		] = GOADDRESS (make_addr_charcon)
	makeAddrKind [ $$KIND_ARRAYS			] = GOADDRESS (make_addr_array)
	makeAddrKind [ $$KIND_FUNCTIONS		] = GOADDRESS (make_addr_function)

	DIM makeAddrAllo[31]
	makeAddrAllo[ $$AUTO			] = GOADDRESS (make_addr_auto)
	makeAddrAllo[ $$AUTOX			] = GOADDRESS (make_addr_autox)
	makeAddrAllo[ $$STATIC		] = GOADDRESS (make_addr_static)
	makeAddrAllo[ $$SHARED		] = GOADDRESS (make_addr_shared)
	makeAddrAllo[ $$EXTERNAL	] = GOADDRESS (make_addr_external)
	makeAddrAllo[ $$ARGUMENT	] = GOADDRESS (make_addr_argument)
END SUB

make_addr_function:

	GOTO eeeCompiler
	EXIT FUNCTION


' ********************
' *****  ERRORS  *****
' ********************

eeeBadCharcon:
	XERROR = ERROR_BAD_CHARCON
	EXIT FUNCTION

eeeBadSymbol:
	XERROR = ERROR_BAD_SYMBOL
	EXIT FUNCTION

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeDupDeclaration:
	XERROR = ERROR_DUP_DECLARATION
	EXIT FUNCTION

eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	EXIT FUNCTION

eeeScopeMismatch:
	XERROR = ERROR_SCOPE_MISMATCH

eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION

eeeUndefined:
	XERROR = ERROR_UNDEFINED
	EXIT FUNCTION
END FUNCTION


' ################################
' #####  AssignComposite ()  #####
' ################################

FUNCTION  AssignComposite (d_reg, d_type, s_reg, s_type)
	SHARED	reg86$[],  reg86c$[]
	SHARED	typeSize[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH

	IF (d_type != s_type) THEN GOTO eeeTypeMismatch
	IFZ d_reg THEN PRINT "AssignComposite.0": GOTO eeeCompiler
	IFZ s_reg THEN PRINT "AssignComposite.1": GOTO eeeCompiler

	IF (d_reg != $$edi) THEN Move ($$edi, $$XLONG, d_reg, $$XLONG)
	IF (s_reg != $$esi) THEN Move ($$esi, $$XLONG, s_reg, $$XLONG)

	Code ($$mov, $$regimm, $$ecx, typeSize[d_type], 0, $$XLONG, @"", @"	;;; i1")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_AssignComposite", @"	;;; i2")
	EXIT FUNCTION

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' #####################
' #####  AtOps () #####
' #####################

FUNCTION  AtOps (xtype, opcode, mode, base, offset, source)
	SHARED	r_addr[],  m_addr$[],  r_addr$[],  typeSize[]
	SHARED	q_type_long[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_SYNTAX
	SHARED	ERROR_TOO_FEW_ARGS,  ERROR_TYPE_MISMATCH
	SHARED	T_COMMA,  T_LBRAK,  T_LPAREN,  T_RBRAK,  T_RPAREN
	SHARED	toes,  toms,  stackType[]
'
	stacked	= 0
	htoes		= toes
	float		= $$FALSE
	scale		= $$FALSE
	token		= NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	SELECT CASE xtype
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
					float = $$TRUE
					SELECT CASE opcode
						CASE $$ld:	opcode	= $$fld
						CASE $$st:	opcode	= $$fstp
					END SELECT
	END SELECT

' Get base address

	new_test = 0: new_op = 0: new_prec = 0: baseToken = 0: baseType = 0
	Expresso (@new_test, @new_op, @new_prec, @baseToken, @baseType)
	IF XERROR THEN EXIT FUNCTION
	IFF q_type_long[baseType] THEN GOTO eeeTypeMismatch
	SELECT CASE new_op
		CASE T_RPAREN:  shortForm = $$TRUE:		GOTO shortForm
		CASE T_COMMA:   shortForm = $$FALSE
		CASE ELSE:      GOTO eeeSyntax
	END SELECT

' form with base and offset

	token			= PeekToken ()
	IF (token = T_LBRAK) THEN
		scale		= $$TRUE
		token		= NextToken ()
	ENDIF

	new_test = 0: new_op = 0: new_prec = 0: offsetData = 0: offsetType = 0
	Expresso (@new_test, @new_op, @new_prec, @offsetData, @offsetType)
	IF XERROR THEN EXIT FUNCTION
	IFZ offsetType THEN GOTO eeeTooFewArgs
	IF scale THEN
		IF (new_op <> T_RBRAK) THEN GOTO eeeSyntax
		new_op	= NextToken ()
	ENDIF
	IF (new_op != T_RPAREN) THEN GOTO eeeSyntax
	IFF q_type_long[offsetType] THEN GOTO eeeTypeMismatch

	IF offsetData THEN
		IF r_addr[offsetData{$$NUMBER}] THEN
			offset		= XLONG (r_addr$[offsetData{$$NUMBER}])
			IF scale THEN
				scale		= $$FALSE
				offimm	= $$TRUE
				offset	= offset * typeSize[xtype]
			ELSE
				offimm	= $$TRUE
			ENDIF
		ELSE
			offimm		= $$FALSE
			offset		= $$edi
			Move (offset, $$XLONG, offsetData, $$XLONG)
		ENDIF
	ELSE
		offimm			= $$FALSE
		stacked			= stacked + 1
	ENDIF

shortForm:
	IF baseToken THEN
		base			= $$esi
		Move (base, $$XLONG, baseToken, $$XLONG)
	ELSE
		stacked		= stacked + 2
	ENDIF

	IF source THEN
		SELECT CASE stacked
			CASE 0:		source = Topax1 ()
			CASE 1:		Topax2 (@offset, @source)
			CASE 2:		Topax2 (@base, @source)
			CASE 3:		Topax2 (@offset, @base)
								Pop ($$esi, stackType[toms-1])
								source	= $$esi
								DEC toes
		END SELECT
	ELSE
		SELECT CASE stacked
			CASE 1:		offset	= Topax1 ()
			CASE 2:		base		= Topax1 ()
			CASE 3:		Topax2 (@offset, @base)
		END SELECT
	ENDIF

	IF shortForm THEN
		SELECT CASE opcode
			CASE $$ld:			mode	= $$regr0
			CASE $$st:			mode	= $$r0reg
			CASE $$fld:			mode	= $$r0
			CASE $$fstp:		mode	= $$r0
		END SELECT
	ELSE
		IF scale THEN
			IF offimm THEN
				PRINT "at0": GOTO eeeCompiler
			ELSE
				SELECT CASE opcode
					CASE $$ld:		mode	= $$regrs
					CASE $$st:		mode	= $$rsreg
					CASE $$fld:		mode	= $$rs
					CASE $$fstp:	mode	= $$rs
				END SELECT
			ENDIF
		ELSE
			IF offimm THEN
				SELECT CASE opcode
					CASE $$ld:		mode	= $$regro
					CASE $$st:		mode	= $$roreg
					CASE $$fld:		mode	=	$$ro
					CASE $$fstp:	mode	= $$ro
				END SELECT
			ELSE
				SELECT CASE opcode
					CASE $$ld:		mode	= $$regrr
					CASE $$st:		mode	= $$rrreg
					CASE $$fld:		mode	= $$rr
					CASE $$fstp:	mode	= $$rr
				END SELECT
			ENDIF
		ENDIF
	ENDIF
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION

eeeTooFewArgs:
	XERROR = ERROR_TOO_FEW_ARGS
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ######################################
' #####  BinStringToAsmString$ ()  #####
' ######################################

'	Convert all unprintable bytes in a string to hex.

FUNCTION  BinStringToAsmString$ (rawString$)

	SHARED UBYTE  charsetNormalChar[]

	length = LEN (rawString$)-1
	FOR i = 0 TO length
		rawChar = rawString${i}
		rawByte = charsetNormalChar[rawChar]
		IF rawByte THEN
			newString$ = newString$ + CHR$ (rawByte)
		ELSE
			newString$ = newString$ + "\"," + HEXX$ (rawChar,2) + ",\""
		ENDIF
	NEXT i

	newString$ = "\"" + newString$ +"\""

	' Clean up any extra commas or quotes.

	IF LEFT$ (newString$, 3) = "\"\"," THEN
		newString$ = LCLIP$ (newString$, 3)
	ENDIF

	XstReplace (@newString$,",\"\",",",",0)

	IF RIGHT$ (newString$, 3) = ",\"\"" THEN
		newString$ = RCLIP$ (newString$, 3)
	ENDIF

	RETURN (newString$)

END FUNCTION


' #############################
' #####  CheckOneLine ()  #####
' #############################

FUNCTION  CheckOneLine ()
	SHARED	library
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_DECLARE,  T_END,  T_EXPORT,  T_EXTERNAL,  T_INTERNAL,  T_ASM
	SHARED	T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED	tokens[]
	SHARED	ifLine,  lineNumber,  tokenPtr
	SHARED	export
	SHARED	got_function,  stopComment,  removeComment
	STATIC	testNumber

	ifLine			= 0
	tokenPtr		= 0
	token1			= NextToken ()	: tp1 = tokenPtr
	token2			= NextToken ()	: tp2 = tokenPtr
	tokenPtr		= tp1
	hold				= token1
	tokenCount	= tokens[0]{$$BYTE0}
	count				= tokenCount

	GOSUB CheckCompileLine
	IFZ compileLine THEN RETURN ($$T_STARTS)
	tokenCount = count
	tokenPtr = tp1
	token = hold

	DO
		token = CheckState (token)
		IF XERROR THEN EXIT DO
		kind = token{$$KIND}
	LOOP UNTIL ((kind = $$KIND_STARTS) OR (kind = $$KIND_COMMENTS))
	RETURN (token)


' *****  CheckCompileLine  *****

SUB CheckCompileLine
	compileLine = $$TRUE
	IF export THEN GOSUB Export

	IF token1 = T_ASM THEN GOSUB InlineAsm : compileLine = $$FALSE : EXIT SUB   ' check for inline assembly

	IF (tokenCount < 2) THEN compileLine = $$FALSE : EXIT SUB
	IF (token1{$$KIND} = $$KIND_COMMENTS) THEN compileLine = $$FALSE : EXIT SUB

	IFZ stopComment THEN
		IFZ removeComment THEN										' remove code line comment from asm
			deparse$ = Deparse$ ("")
			EmitAsm (";\r\n; [" + STRING (lineNumber) + "] " + LTRIM$(deparse$))		' emit source line as comment
		ENDIF
	ENDIF
END SUB

' ***** InlineAsm *****

SUB InlineAsm
	deparse$ = Deparse$("")									' re-create inline ASM
	deparse$ = TRIM$(MID$(deparse$, 4))			' remove first "ASM"
	EmitAsm (deparse$)
END SUB

' *****  Export  *****

SUB Export
	SELECT CASE token1
		CASE T_END			: IF (token2 = T_EXPORT) THEN
												compileLine = $$FALSE
												export = $$FALSE
												EXIT SUB
											ENDIF
											deparse$ = Deparse$ ("")
											WriteDeclarationFile (@deparse$)
		CASE T_EXPORT		: compileLine = $$FALSE
											EXIT SUB
		CASE T_DECLARE	: IF ((token2 = T_FUNCTION) OR (token2 = T_SFUNCTION) OR (token2 = T_CFUNCTION)) THEN
												deparse$ = Deparse$ ("")
												d = INSTR (deparse$, "DECLARE")
												deparse$ = LEFT$ (deparse$,d-1) + "EXTERNAL" + MID$ (deparse$, d+7)
												WriteDeclarationFile (@deparse$)
											ENDIF
		CASE T_EXTERNAL	: deparse$ = Deparse$ ("")
											WriteDeclarationFile (@deparse$)
		CASE T_INTERNAL	:	IF ((token2 = T_FUNCTION) OR (token2 = T_SFUNCTION) OR (token2 = T_CFUNCTION)) THEN
												' do not include INTERNAL xFUNCTION lines
											ENDIF
		CASE ELSE				: deparse$ = Deparse$ ("")
											WriteDeclarationFile (@deparse$)
	END SELECT
END SUB
END FUNCTION


' ###########################
' #####  CheckState ()  #####
' ###########################

FUNCTION  CheckState (token)
	SHARED	library
	SHARED	checkBounds,  errorCount,  entryFunction
	SHARED	maxFuncNumber
	SHARED SSHORT typeConvert[]
	SHARED UBYTE  charsetSymbolInner[]
	SHARED	libraryName$[],  libraryHandle[], libraryExt$[] 'newimport
	SHARED	reg86$[],  reg86c$[],  m_reg[],  m_addr[],  m_addr$[]
	SHARED	autoAddr[],  autoxAddr[],  inargAddr[],  defaultType[]
	SHARED	patchType[],  patchAddr[],  patchDest[]
	SHARED	xargNum,  xargAddr[],  xargName$[]
	SHARED	typeSize[],  typeSize$[],  typeAlias[],  typeAlign[]
	SHARED	typeSymbol$[],  typeToken[],  typeEleCount[]
	SHARED	typeEleSymbol$[],  typeEleToken[]
	SHARED	typeEleSize[],  typeEleType[],  typeEleArg[]
	SHARED	typeEleAddr[],  typeEleVal[],  typeElePtr[]
	SHARED	typeEleStringSize[],  typeEleUBound[]
	SHARED	funcFrameSize[]
	SHARED	funcSymbol$[],  funcLabel$[],  funcToken[]
	SHARED	funcScope[],  funcKind[],  funcType[],  funcArgSize[],  funcArg[]
	SHARED	pastArgsAddr[]
	SHARED	hash%[]
	SHARED	labelPtr
	SHARED	nestCount[],  nestInfo[],  nestLevel[],  nestLimit[]
	SHARED	nestStep[],  nestToken[],  nestVar[],  q_type_long[]
	SHARED	r_addr$[],  r_addr[],  subToken[]
	SHARED	tabArg[],  tabType[],  tab_sym$[],  tab_sym[]
	SHARED	tab_lab[],  tab_lab$[],  labaddr[]
	SHARED	compositeNumber[],  compositeToken[]
	SHARED	compositeStart[],  compositeNext[]
	SHARED	errSymbol$[],  errToken[],  errAddr[]
	SHARED	ERROR_AFTER_ELSE,  ERROR_BAD_CASE_ALL
	SHARED	ERROR_BAD_GOTO,  ERROR_BAD_GOSUB,  ERROR_BAD_SYMBOL
	SHARED	ERROR_COMPILER,  ERROR_COMPONENT,  ERROR_CROSSED_FUNCTIONS
	SHARED	ERROR_DECLARE,  ERROR_DECLARE_FUNCS_FIRST
	SHARED	ERROR_DUP_DECLARATION,  ERROR_DUP_DEFINITION,  ERROR_DUP_TYPE
	SHARED	ERROR_ELSE_IN_CASE_ALL,  ERROR_ENTRY_FUNCTION
	SHARED	ERROR_EXPECT_ASSIGNMENT,  ERROR_EXPRESSION_STACK, ERROR_EXPLICIT_VARIABLE
	SHARED	ERROR_INTERNAL_EXTERNAL
	SHARED	ERROR_KIND_MISMATCH
	SHARED	ERROR_NEED_EXCESS_COMMA,  ERROR_NEED_SUBSCRIPT
	SHARED	ERROR_NEST,  ERROR_NODE_DATA_MISMATCH
	SHARED	ERROR_OUTSIDE_FUNCTIONS,  ERROR_OVERFLOW
	SHARED  ERROR_PROGRAM_NOT_NAMED
	SHARED	ERROR_SCOPE_MISMATCH,  ERROR_SHARENAME,  ERROR_SYNTAX
	SHARED	ERROR_TOO_FEW_ARGS,  ERROR_TOO_LATE,  ERROR_TOO_MANY_ARGS
	SHARED	ERROR_TYPE_MISMATCH,  ERROR_UNDECLARED,  ERROR_UNDEFINED
	SHARED	ERROR_UNIMPLEMENTED,  ERROR_VOID,  ERROR_WITHIN_FUNCTION
	SHARED	T_ADD,  T_ADDR_OP,  T_ALL,  T_ANY
	SHARED	T_ATSIGN,  T_ATTACH,  T_AUTO,  T_AUTOX,  T_BITFIELD
	SHARED	T_CASE,  T_CFUNCTION,  T_CMP,  T_CLOSE,  T_COLON,  T_COMMA,  T_CONSOLE
	SHARED	T_DEC,  T_DECLARE,  T_DIM,  T_DIV
	SHARED	T_DO,  T_DOUBLE,  T_DOUBLEAT
	SHARED	T_ELSE,  T_END,  T_ENDIF,  T_EQ,  T_ETC
	SHARED	T_EXIT,  T_EXPLICIT,  T_EXPORT,  T_EXTERNAL
	SHARED	T_FALSE,  T_FOR,  T_FUNCADDR,  T_FUNCADDRAT,  T_FUNCTION
	SHARED	T_GIANT,  T_GIANTAT
	SHARED	T_GOADDR,  T_GOADDRAT,  T_GOSUB,  T_GOTO
	SHARED	T_HANDLE_OP,  T_IF,  T_IFF,  T_IFT,  T_IFZ,  T_IMPORT
	SHARED	T_INC,  T_INLINE_D,  T_INTERNAL
	SHARED	T_LBRACE,  T_LBRAK,  T_LIBRARY,  T_LOOP,  T_LPAREN,  T_MAKEFILE,  T_MUL,	T_NEXT
	SHARED	T_PACKED, T_POUND,  T_POWER,  T_PRINT,  T_PROGRAM,  T_QMARK,  T_QUIT
	SHARED	T_RBRACE,  T_RBRAK,  T_READ,  T_REDIM
	SHARED	T_REM,  T_RETURN,  T_RPAREN
	SHARED	T_SBYTE,  T_SBYTEAT,  T_SEEK,  T_SELECT
	SHARED	T_SEMI,  T_SFUNCTION,  T_SHARED,  T_SHELL
	SHARED	T_SINGLE,  T_SINGLEAT
	SHARED	T_SLONG,  T_SLONGAT,  T_SSHORT,  T_SSHORTAT
	SHARED	T_STATIC,  T_STEP,  T_STOP,  T_STORE_OP,  T_STRING,  T_SUB
	SHARED	T_SUBADDR,  T_SUBADDRAT,  T_SUBTRACT,  T_SWAP
	SHARED	T_THEN,  T_TO,  T_TRUE,  T_TYPE,  T_UNION
	SHARED	T_UBYTE,  T_UBYTEAT,  T_ULONG,  T_ULONGAT,  T_UNTIL
	SHARED	T_USHORT,  T_USHORTAT
	SHARED	T_VERSION,  T_VOID,  T_WHILE,  T_WRITE
	SHARED	T_XLONG,  T_XLONGAT,  T_XMARK
	SHARED	T_LONGDOUBLE, T_LONGDOUBLEAT
	SHARED	XERROR
	SHARED	a0,  a0_type,  a1,  a1_type,  caseCount
	SHARED	defaultType,  dim_array
	SHARED	elementType,  end_program
	SHARED	entryCheckBounds
	SHARED	export
	SHARED	fileName$, func_number
	SHARED	got_declare,  got_executable,  got_export,  got_function
	SHARED	got_import,  got_object_declaration,  got_program,  got_type
	SHARED	hfn$,  ifLine,  insub,  insub$
	SHARED	libraryDeclaration,  libraryFunctionLabel$
	SHARED	nestCount,  nestLevel,  nestError,  nullstringer
	SHARED	ofile,  oos
	SHARED	sharename$,  staticAddr,  subCount,  tab_sym_ptr
	SHARED	toes,  tokenPtr,  toms,  xit,  labelNumber
	SHARED	programTypeChunk,  functionTypeChunk
	SHARED	inTYPE,  inUNION,  typePtr,  compositeArg,  crvtoken,  comStk
	SHARED	UBYTE oos[]
	SHARED	pass2errors,  prologCode,  preExports,  programName$,  program$, FuncProgram$
	SHARED  fLogErrors, fConsole, removeComment
	STATIC  funcKind,  eleCount,  eleCountUNION,  addrUNION,  uEle
	STATIC  typeType,  typeNumber,  typeThisAddr,  typeNextAddr,  typeMaxAlign
	STATIC  first_static,  last_static
	STATIC  tsymbol$[]
	STATIC  ttoken[]
	STATIC  tsize[]
	STATIC  taddr[]
	STATIC  ttype[]
	STATIC	atype[]
	STATIC  tval[]
	STATIC  tptr[]
	STATIC  tss[]
	STATIC  tub[]
	STATIC	arg[]
	STATIC GOADDR  typeBeforeFunc[]
	STATIC GOADDR  kindBeforeFunc[]
	STATIC GOADDR  stateBeforeFunc[]
	STATIC GOADDR  kindAfterFunc[]
	STATIC GOADDR  stateAfterFunc[]
	STATIC bat, rcfile
	STATIC packed
	STATIC consoleStatement
	SHARED makefile$
	SHARED fMak, fRc, fBat         	' flags to suppress file generation
	SHARED fNoWinMain, fNoDllMain  	' flags to suppress generation of WinMain() or DllMain()
	SHARED fProfile                	' flag to emit "call _penter" and "call _pexit" in every function, used with proflib.dll
	SHARED explicitStatement			 	' flag for EXPLICIT keyword
	'	SHARED noinitStatement					' flag for NOINITIALIZE keyword
	SHARED fM4											' flag to use m4 macro preprocessor by using m4app.xxx template
	SHARED ebx_zeroed

' Initialize computed GOTO arrays on 1st entry to this function

	IFZ kindBeforeFunc[] THEN
		GOSUB TypeBeforeFunc		' dispatch based on types before 1st FUNCTION
		GOSUB KindBeforeFunc		' dispatch based on KIND before 1st FUNCTION
		GOSUB	StateBeforeFunc		' dispatch based on TOKEN # before 1st FUNCTION
		GOSUB KindAfterFunc			' dispatch based on KIND after 1st FUNCTION
		GOSUB StateAfterFunc		' dispatch based on TOKEN # after 1st FUNCTION
	ENDIF
	IF XERROR THEN EXIT FUNCTION

	comStk = 0
	kind = token{$$KIND}
	tt = token{$$NUMBER}

	SELECT CASE kind
		CASE $$KIND_STARTS, $$KIND_COMMENTS:		RETURN ($$T_STARTS)
	END SELECT
	IF got_function THEN GOTO past_declares
	IF typeNumber THEN GOTO p_intype

' ****************************************************
' *****  if 1st FUNCTION is not yet encountered  *****
' *****  dispatch based on kindBeforeFunc[kind]  *****
' ****************************************************

	pallo = 0											' no presumed allocation scope
	GOTO @kindBeforeFunc [kind]		' dispatch on basis of KIND of token
	GOTO eeeOutsideFunctions			' any other kind is an error before 1st func

' kindBeforeFunc[kind] may invoke one of the following...

b_types:				IF got_declare THEN GOTO p_types ELSE GOTO eeeDeclareFuncs
b_starts:				RETURN (token)
b_syscons:			GOTO assign_syscons
b_constants:		GOTO assign_constants
b_comments:			RETURN ($$T_STARTS)
b_terminators:	token = NextToken (): RETURN (token)
b_statements:		IF got_declare THEN GOTO @typeBeforeFunc[tt]	' data-type : presume SHARED scope
								GOTO @stateBeforeFunc[tt]		' statements before 1st function
								GOTO eeeOutsideFunctions		' if invalid before 1st function

' stateBeforeFunc[tt] may invoke one of the following...

b_all:					GOTO p_all
b_console:			GOTO p_console
b_explicit:     GOTO p_explicit
'b_noinit: 			GOTO p_noinit
b_shared:				IF got_declare THEN GOTO p_shared ELSE GOTO eeeDeclareFuncs
b_function:			funcKind = $$XFUNC					: GOTO p_xfunction
b_sfunction:		funcKind = $$SFUNC					: GOTO p_xfunction
b_cfunction:		funcKind = $$CFUNC					: GOTO p_xfunction
b_declare:			funcScope = $$FUNC_DECLARE	: GOTO p_declare_func
b_internal:			funcScope = $$FUNC_INTERNAL	: GOTO p_internal_func
b_external:			funcScope = $$FUNC_EXTERNAL
								check = PeekToken ()
								SELECT CASE check
									CASE T_FUNCTION		: GOTO p_external_func
									CASE T_SFUNCTION	: GOTO p_external_func
									CASE T_CFUNCTION	: GOTO p_external_func
								END SELECT
								IF got_declare THEN GOTO p_external ELSE GOTO eeeDeclareFuncs
b_packed:				packed = $$TRUE
								GOTO p_type
b_type:					GOTO p_type
b_union:				PRINT "eeeS1" : GOTO eeeSyntax
b_import:				token = StatementImport (token) 	: RETURN (token)
b_export:				token = StatementExport (token) 	: RETURN (token)
b_library:			token = StatementImport (token) 	: RETURN (token)
b_program:			token = StatementProgram (token)
								IF token = ERROR_PROGRAM_NAME_MISMATCH THEN
									GOTO eeeProgramNameMismatch
								ELSE
									RETURN (token)
								ENDIF
b_version:			token = StatementVersion (token) 	: RETURN (token)
b_makefile:			token = StatementMakefile (token)	: RETURN (token)
b_end:					token = NextToken ()
								IF (token != T_EXPORT) THEN GOTO eeeSyntax
								SELECT CASE token
									CASE T_EXPORT :
										IFZ export THEN GOTO eeeNest
										export = $$FALSE
										RETURN ($$T_STARTS)
								END SELECT

b_characters:		GOTO eeeSyntax


' ************************************
' If 1st FUNCTION has been encountered, dispatch based on kindAfterFunc[kind]
' ************************************

past_declares:
	GOTO @kindAfterFunc [kind]		' dispatch on basis of KIND of token
	GOTO eeeSyntax								' if invalid KIND when expecting statement

' kindAfterFunc[kind] may invoke one of the following...

a_variables:		GOTO assign_variables
a_arrays:				GOTO assign_array
a_constants:		GOTO assign_constants
a_functions:		GOTO p_func
a_labels:				GOTO p_label
a_starts:				RETURN (token)
a_comments:			RETURN (token)
a_whites:				token = NextToken (): RETURN (token)
a_terminators:	token = NextToken (): RETURN (token)
a_characters:
								SELECT CASE token
									CASE T_ATSIGN:	GOTO p_atsign
									CASE T_QMARK :  GOTO p_print
									CASE ELSE:			GOTO eeeSyntax
								END SELECT
a_types:				GOTO p_user_type
a_addr_ops:			GOTO p_addr_ops
a_intrinsics:		SELECT CASE token
									CASE T_CLOSE:			GOTO p_close
									CASE T_INLINE_D:	GOTO p_inline_d
									CASE T_QUIT:			GOTO p_quit
									CASE T_SEEK:			GOTO p_seek
									CASE T_SHELL:			GOTO p_shell
									CASE ELSE:				GOTO eeeSyntax
								END SELECT
a_statements:
a_state_intrin:	GOTO @stateAfterFunc [tt]
								GOTO eeeSyntax


' stateAfterFunc[tt] may invoke one of the following...

p_if:						ifc = $$FALSE				: GOTO p_ifx
p_ift:					ifc = $$FALSE				: GOTO p_ifx
p_ifz:					ifc = $$TRUE				: GOTO p_ifx
p_iff:					ifc = $$TRUE				: GOTO p_ifx
p_function:			funcKind = $$XFUNC	: GOTO p_xfunction
p_sfunction:		funcKind = $$SFUNC	: GOTO p_xfunction
p_cfunction:		funcKind = $$CFUNC	: GOTO p_xfunction


' *************************************
' *****  ASSIGNMENT TO CONSTANTS  *****
' *************************************

assign_syscons:
	IF got_function THEN GOTO eeeTooLate
	syscon = $$TRUE
	GOTO assign_constantx

assign_constants:
	IF (got_function = $$FALSE) THEN GOTO eeeOutsideFunctions
	IF got_executable THEN GOTO eeeTooLate
	syscon = $$FALSE

assign_constantx:
	ctoken			= token
	hold_place	= tokenPtr
	cc					= token{$$NUMBER}
	ctype				= token{$$TYPE}
	callo				= token{$$ALLO}
	IF r_addr$[cc] THEN GOTO eeeDupDefinition
	IF ctype AND (ctype <> $$STRING) THEN GOTO eeeTypeMismatch
	token = NextToken ()
	IF (token <> T_EQ) THEN GOTO eeeSyntax
	token = NextToken ()
	IF (token = T_BITFIELD) THEN
		token = NextToken ()
		IF (token != T_LPAREN) THEN GOTO eeeSyntax
		token = NextToken ()
		bitCheck = $$TRUE
		bitPass = $$FALSE
	ELSE
		bitCheck = $$FALSE
	ENDIF
	IF (ctype = $$STRING) THEN GOTO assign_to_string_constant

' now look at value to assign to constant

bitLoop:
	IF (token = T_SUBTRACT) THEN
		IF bitCheck THEN GOTO eeeSyntax
		token = NextToken ()
		nc = $$TRUE
	ELSE
		nc = $$FALSE
	ENDIF
	vv = token{$$NUMBER}
	IFZ m_addr$[vv] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
	vkind = token{$$KIND}
	SELECT CASE vkind
		CASE $$KIND_LITERALS, $$KIND_CONSTANTS, $$KIND_SYSCONS
		CASE $$KIND_CHARCONS
					vtype = $$USHORT
					IF nc THEN GOTO eeeSyntax
		CASE ELSE	: GOTO eeeSyntax
	END SELECT
	vtype = TheType (token)
	IF (vtype = $$STRING) THEN
		ctoken = ctoken OR 0x130000
		UpdateToken (ctoken)
		GOTO atscin
	ENDIF
	IFF r_addr$[vv] THEN GOTO eeeUndefined
	IF nc THEN vs$ = "-" + r_addr$[vv] ELSE vs$ = r_addr$[vv]

' ***** here is where value string is assigned to constant *****
' for LONGDOUBLE type, would need an ascii to longdouble function
' or modify DOUBLE() intrinsic for converting string to DOUBLE type
' so it can handle long double values.
' Then there is the problem that vs# is used to check neg values
' Would need to change vs# to a long double type

	IF (vtype = $$GIANT) THEN
		vs$$	= GIANT (vs$)
		vs#		= vs$$
	ELSE
		vs#		= DOUBLE (vs$)
	ENDIF
	IF nc THEN GOTO acx

acc:
	SELECT CASE vtype
		CASE $$SBYTE, $$SSHORT
			r_addr = $$NEG16:  ctype = vtype: GOTO acf
		CASE $$UBYTE, $$USHORT
			r_addr = $$IMM16:  ctype = vtype: GOTO acf
		CASE $$GIANT, $$SINGLE, $$DOUBLE, $$LONGDOUBLE
			r_addr = $$LITNUM: ctype = vtype: GOTO acf
	END SELECT

' negative value here
acx:
	SELECT CASE TRUE
		CASE ((vs# > 0) AND (vs# <= 65535))
				r_addr = $$IMM16:  ctype = $$USHORT
		CASE ((vs# >= -65535) AND (vs# < 0))
				r_addr = $$NEG16:  ctype = $$SLONG
		CASE ELSE
				r_addr = $$LITNUM
				IF (vtype = $$GIANT) THEN
					q_type = MinTypeFromGiant (vs$$)
					IF (q_type < $$GIANT) THEN
						ctype = q_type
					ELSE
						ctype = $$GIANT
					ENDIF
				ELSE
					ctype = vtype
				ENDIF
	END SELECT

' check for brace notation {}
acf:
	IF bitCheck THEN
		IF ((vs# < 0) OR (vs# > 31)) THEN GOTO eeeOverflow
		IF bitPass THEN
			bitOffset = vs#
			bitValue = (bitWidth << 5) + bitOffset
			vs$ = HEXX$(bitValue, 4)
			ctype = $$USHORT
		ELSE
			bitWidth = vs#
			bitPass = $$TRUE
			token = NextToken ()
			IF (token != T_COMMA) THEN GOTO eeeSyntax
			token = NextToken ()
			GOTO bitLoop
		ENDIF
	ENDIF
	r_addr[cc]	= r_addr
	r_addr$[cc]	= vs$				' assign vs$ value to r_addr$[]
	tabType[cc]	= ctype
	ctoken = (ctoken AND 0xFFE0FFFF) OR (ctype << 16)
	UpdateToken (ctoken)
	token = NextToken ()
	IF bitCheck THEN
		IF (token != T_RPAREN) THEN GOTO eeeSyntax
		token = NextToken ()
	ENDIF
	RETURN (token)

assign_to_string_constant:
	ctoken = ctoken AND NOT $$MASK_ALLO
	ctoken = ctoken OR ($$EXTERNAL << 21)
	tab_sym[cc] = ctoken
	vv = token{$$NUMBER}
	vkind = token{$$KIND}
	vtype = TheType (token)
	IF (vtype != $$STRING) THEN GOTO eeeTypeMismatch
atscin:
	SELECT CASE vkind
		CASE $$KIND_CONSTANTS, $$KIND_SYSCONS
				IFZ r_addr$[vv] THEN GOTO eeeUndefined
				IFZ m_addr$[vv] THEN GOTO eeeUndefined
				what$ = r_addr$[vv]
		CASE $$KIND_LITERALS
				IFZ m_addr$[vv] THEN AssignAddress (token)
				IF XERROR THEN EXIT FUNCTION
				what$ = tab_sym$[vv]
		CASE ELSE
				GOTO eeeSyntax
	END SELECT
	m_addr$[cc] = m_addr$[vv]
	m_addr[cc]  = m_addr[vv]
	m_reg[cc]   = m_reg[vv]
	r_addr$[cc] = what$
	tabType[cc] = vtype
	token = NextToken ()
	RETURN (token)


' ************************************
' *****  ASSIGNMENT TO VARIABLE  *****
' ************************************

assign_variables:
	got_executable = $$TRUE
	hold_place	= tokenPtr
	hold_token	= token
	old_data		= token
	old_type		= TheType (token)
	IF (old_type < $$SLONG) THEN old_type = $$SLONG

	ot = token
	oo = token{$$NUMBER}
	IFZ m_addr$[oo] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION

	old_type = TheType (token)			' xxxxx
	old_type = tabType[oo]					' xxxxx

	IFZ old_type THEN
		IF explicitStatement THEN GOTO eeeExplicit  ' zzz
		old_type = TheType (token)		' xxxxx
	ENDIF

	orego = r_addr[oo]
	token = NextToken ()
	IF (old_type < $$SLONG) THEN old_type = $$SLONG
	IF (old_type >= $$SCOMPLEX) THEN GOTO assign_composite

	SELECT CASE token
		CASE T_EQ				:	' fall through
		CASE T_LBRACE		: GOTO assignBraceString
		CASE ELSE				: GOTO eeeSyntax
	END SELECT

' evaluate the expression

in_ass:
	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	token = new_op
	IF new_data THEN
		IF (hold_token = new_data) THEN GOTO zover
		nn = new_data{$$NUMBER}
	ELSE
		nn = Top ()
	ENDIF
	IFZ nn THEN GOTO eeeTooFewArgs

' string assignment

asx:
	IF ((old_type != $$STRING) AND (new_type != $$STRING)) THEN GOTO nsa
	IF (old_type <> new_type) THEN tokenPtr = hold_place: GOTO eeeTypeMismatch
	IF (oo = nn) THEN DEC oos: GOTO zass

	IF (oos[oos] = 'v') THEN
		IF (nn = nullstringer) THEN
			Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
		ELSE
			Move ($$RA0, old_type, nn, new_type)
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"	;;; i3")
		ENDIF
		nn			= $$RA0
		toes		= 1
		a0			= toes
		a0_type = new_type
	ENDIF
	oos[oos] = 's'

	oo$		= tab_sym$[oo]
	m$		= m_addr$[oo]
	ma		= m_addr[oo]
	mr		= m_reg[oo]

	SELECT CASE nn
		CASE $$RA0:	acc = $$R10:  accx = $$R12
								a0 = 0: a0_type = 0
		CASE $$RA1:	acc = $$R12:  accx = $$R10
								a1 = 0: a1_type = 0
		CASE ELSE:	PRINT "xxx1": GOTO eeeCompiler
	END SELECT

	IFZ mr THEN
		Code ($$mov, $$regimm, accx, ma, 0, $$XLONG, "addr " + m$, @"	;;; i4")
	ELSE
		Code ($$lea, $$regro, accx, mr, ma, $$XLONG, @"", @"	;;; i5")
	ENDIF
	Code ($$ld, $$regr0, $$esi, accx, 0, $$XLONG, @"", @"	;;; i6a")
	Code ($$st, $$r0reg, acc, accx, 0, $$XLONG, @"", @"	;;; i6b")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i6c")
	DEC oos
	DEC toes
	GOTO zass


' *********************************************
' *****  ASSIGN TO COMPOSITE DESTINATION  *****
' *********************************************

'		subComposite == a composite expression including sub-element references
'   varComposite == a composite variable/array without sub-element references

'		Destination:  GETADDR invalid for varComposites/subComposites
'									GETHANDLE invalid for varComposites
'									GETHANDLE valid only for pointer sub-elements to allow
'											assigning address to pointer (tested in Composite() )

p_addr_ops:
	got_executable = $$TRUE

	IF (token != T_HANDLE_OP) THEN GOTO eeeSyntax
	token = NextToken ()
	kind = token{$$KIND}
	SELECT CASE kind
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
		CASE ELSE:  GOTO eeeSyntax
	END SELECT

	old_type = TheType (token)
	IF (old_type < $$SCOMPLEX) THEN GOTO eeeSyntax

	lastElement = LastElement (token, 0, 0)		' Handle invalid for varComposites
	IF XERROR THEN EXIT FUNCTION
	IF lastElement THEN GOTO eeeSyntax

	compositeHandle = $$TRUE
	hold_place = tokenPtr
	hold_token = token

	ot = token
	oo = token{$$NUMBER}
	IFZ m_addr$[oo] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION

	old_type = TheType (token)		' xxxxx
	old_type = tabType[oo]				' xxxxx

	IFZ old_type THEN old_type = TheType (token)		' xxxxx

	orego = r_addr[oo]
	token = NextToken ()

assign_composite:
	DO WHILE (token != T_EQ)													' skip past "=" (assignment)
		token = NextToken ()
	LOOP WHILE (token{$$KIND} != $$KIND_STARTS)
	IF (token != T_EQ) THEN GOTO eeeExpectAssignment
	s_test = 0: s_op = 0: s_prec = 0: s_data = 0: s_type = 0
	Expresso (@s_test, @s_op, @s_prec, @s_data, @s_type)
	IF XERROR THEN EXIT FUNCTION
	IFZ s_type THEN GOTO eeeTooFewArgs
	IF s_data THEN
		ss = r_addr[s_data{$$NUMBER}]
		sourceStacked = 0
	ELSE
		ss = Top ()
		sourceStacked = 1
	ENDIF

' *****  get address of destination  *****

	d_reg = hold_token
	term_ptr = tokenPtr
	tokenPtr = hold_place
	IF (d_reg{$$KIND} = $$KIND_ARRAYS) THEN		' a[] = ...  invalid
		check1 = NextToken ()
		check2 = NextToken ()
		tokenPtr = hold_place
		IF (check1 = T_LBRAK) THEN
			IF (check2 = T_RBRAK) THEN GOTO eeeSyntax
		ENDIF
	ENDIF
	IF compositeHandle THEN
		command	= $$GETHANDLE
	ELSE
		command	= $$GETDATAADDR
	ENDIF
	Composite (@command, @d_type, @d_reg, @d_offset, @d_length)
	IF XERROR THEN EXIT FUNCTION
	IF compositeHandle THEN
		d_type = $$XLONG
		compositeHandle = $$FALSE
	ENDIF
	token = NextToken ()
	IF (token != T_EQ) THEN GOTO eeeSyntax

' *******************************************
' *****  Assign composite to composite  *****
' *******************************************

	IF ((d_type >= $$SCOMPLEX) OR (s_type >= $$SCOMPLEX)) THEN
		IF (d_type != s_type) THEN GOTO eeeTypeMismatch
		IF s_data THEN
			Composite ($$GETDATA, @s_type, @s_data, 0, 0)
			s_data = 0
			sourceStacked = 1
			flipStack = $$TRUE
		ENDIF
		IF command THEN												' address of dest in tos
			IF sourceStacked THEN								' address of source in tos-1
				IF flipStack THEN
					Topax2 (@sr, @dr)						' remove dest and source from stack
				ELSE
					Topax2 (@dr, @sr)						' remove dest and source from stack
				ENDIF
				GOSUB GetCompositeDest						' ebx = address of dest
				Code ($$mov, $$regreg, $$esi, sr, 0, $$XLONG, @"", @"	;;; i7")
				sr = $$esi
			ELSE
				PRINT "assign_composite.1"
				GOTO eeeCompiler
			ENDIF
		ELSE
			dr = d_reg													' register with composite address
			GOSUB GetCompositeDest							' edi = address of dest
			IF sourceStacked THEN								' address of src in tos
				sr = Topax1 ()										' remove source from stack
				Code ($$mov, $$regreg, $$esi, sr, 0, $$XLONG, @"", @"	;;; i7a")
				sr = $$esi												' ditto
			ELSE
				PRINT "assign_composite.2"
				GOTO eeeCompiler
			ENDIF
		ENDIF
		AssignComposite (dr, d_type, sr, s_type)
		tokenPtr = term_ptr
		token = s_op
		GOTO zass
	ENDIF

' *********************************************************
' *****  Assign simple type to simple type component  *****
' *********************************************************

	IF command THEN
		IF sourceStacked THEN
			Topax2 (@dr, @sr)
		ELSE
			sr = OpenAccForType (s_type)
			Move (sr, s_type, s_data, s_type)
			Topax2 (@sr, @dr)
		ENDIF
	ELSE
		dr = d_reg
		IF sourceStacked THEN
			sr = Topax1 ()
		ELSE
			sr = OpenAccForType (s_type)
			Move (sr, s_type, s_data, s_type)
			Topax1 ()
		ENDIF
	ENDIF
	IF (d_type != s_type) THEN						' problem with s_type = GIANT ???
		SELECT CASE typeConvert[d_type, s_type] {{$$BYTE0}}
			CASE  0
			CASE -1
				GOTO eeeTypeMismatch
			CASE ELSE
				IFZ ((d_type <= $$XLONG) AND (s_type <= $$XLONG)) THEN
										Conv (sr, d_type, sr, s_type)		'  (GIANTS overwrite $$edi ???)
									ENDIF
		END SELECT
	ENDIF

	IF (d_type = $$STRING) THEN
		suf$ = "." + CHR$(oos[oos])
		DEC oos
		IFZ d_offset THEN
			IF (dr != $$edi) THEN
				Code ($$mov, $$regreg, $$edi, dr, 0, $$XLONG, @"", @"	;;; i9a")
			ENDIF
		ELSE
			Code ($$lea, $$regro, $$edi, dr, d_offset, $$XLONG, @"", @"	;;; i9b")
		ENDIF
		IF (sr != $$esi) THEN Code ($$mov, $$regreg, $$esi, sr, 0, $$XLONG, @"", @"	;;; i10")
		Code ($$mov, $$regimm, $$ecx, d_length, 0, $$XLONG, @"", @"	;;; i11")
		Code ($$call, $$rel, 0, 0, 0, 0, "%_assignCompositeStringlet" + suf$, @"	;;; i12")
	ELSE
		IF ((d_type = $$SINGLE) OR (d_type = $$DOUBLE) OR (d_type = $$LONGDOUBLE)) THEN
			Code ($$fstp, $$ro, sr, dr, d_offset, d_type, @"", @"	;;; i13a")
		ELSE
			Code ($$st, $$roreg, sr, dr, d_offset, d_type, @"", @"	;;; i13b")
		ENDIF
	ENDIF

	tokenPtr	= term_ptr
	token			= s_op
	a0_type		= 0
	a1_type		= 0
	GOTO zass

SUB GetCompositeDest
	IF d_offset OR (dr != $$edi) THEN
		IFZ d_offset THEN
			Code ($$mov, $$regreg, $$edi, dr, 0, $$XLONG, @"", @"	;;; i14a")
		ELSE
			Code ($$lea, $$regro, $$edi, dr, d_offset, $$XLONG, @"", @"	;;; i14b")
		ENDIF
		dr		= $$edi
	ENDIF
END SUB



' ***********************************
' *****  NON-STRING ASSIGNMENT  *****
' ***********************************

nsa:
	literal			= $$FALSE
	doneAssign	= $$FALSE
	IF ((old_type >= $$SCOMPLEX) OR (new_type >= $$SCOMPLEX)) THEN
		IF (old_type != new_type) THEN GOTO eeeTypeMismatch
	ENDIF
	SELECT CASE old_type
		CASE $$SINGLE:			oldFlop = $$TRUE:		ttype = $$XLONG
		CASE $$DOUBLE:			oldFlop = $$TRUE: 	ttype = $$GIANT
		CASE $$LONGDOUBLE:	oldFlop = $$TRUE:		ttype = $$LONGDOUBLE
		CASE ELSE:					oldFlop = $$FALSE:	ttype = old_type
	END SELECT
	SELECT CASE new_type
		CASE $$SINGLE:			newFlop = $$TRUE:		ftype = $$XLONG
		CASE $$DOUBLE:			newFlop = $$TRUE: 	ftype = $$GIANT
		CASE $$LONGDOUBLE: 	newFlop = $$TRUE:		ftype = $$LONGDOUBLE
		CASE ELSE:					newFlop = $$FALSE:	ftype = new_type
	END SELECT
	kind	= new_data{$$KIND}
	SELECT CASE kind
		CASE $$KIND_LITERALS, $$KIND_CONSTANTS, $$KIND_SYSCONS
					ftype		= new_type
					literal	= $$TRUE
	END SELECT

	IF oldFlop THEN
		IF newFlop THEN GOTO flopflop ELSE GOTO flopint
	ELSE
		IF newFlop THEN GOTO intflop ELSE GOTO intint
	ENDIF

flopflop:
	IF new_data THEN
		IF (ttype = ftype) THEN
			Move ($$RA0, ttype, new_data, ttype)
			Move (old_data, ttype, $$RA0, ttype)
			a0 = 0: a0_type = 0
		ELSE
			Move ($$RA0, new_type, new_data, new_type)
			Move (old_data, old_type, $$RA0, old_type)
			a0 = 0: a0_type = 0
		ENDIF
	ELSE
		Move (old_data, old_type, $$RA0, old_type)
		DEC toes
		a0			= 0
		a0_type	= 0
	ENDIF
	GOTO zover

flopint:
	IF new_data THEN
		IF literal THEN
			Move ($$RA0, new_type, new_data, new_type)
			Code ($$st, $$roreg, $$RA0, $$ebp, -8, new_type, @"", @"	;;; i15")
			Code ($$fild, $$ro, 0, $$ebp, -8, new_type, @"", @"	;;; i16")
			FloatStore ($$RA0, old_data, old_type)
		ELSE
			FloatLoad ($$RA0, new_data, new_type)
			FloatStore ($$RA0, old_data, old_type)
		ENDIF
		a0			= 0
		a0_type	= 0
	ELSE
		Code ($$st, $$roreg, $$RA0, $$ebp, -8, new_type, @"", @"	;;; i17")
		Code ($$fild, $$ro, 0, $$ebp, -8, new_type, @"", @"	;;; i18")
		Move (old_data, old_type, $$RA0, old_type)
		DEC toes
		a0			= 0
		a0_type	= 0
	ENDIF
	GOTO zover

intflop:
	IF new_data THEN
		FloatLoad ($$RA0, new_data, new_type)
		FloatStore ($$RA0, old_data, old_type)
		a0 = 0: a0_type = 0
	ELSE
		FloatStore ($$RA0, old_data, old_type)
		DEC toes
		a0			= 0
		a0_type	= 0
	ENDIF
	GOTO zover

intint:
	IF new_data THEN
		IF (old_type = new_type) THEN
			Move ($$RA0, new_type, new_data, new_type)
			Move (old_data, old_type, $$RA0, old_type)
			a0 = 0: a0_type = 0
		ELSE
			Move ($$RA0, new_type, new_data, new_type)
			Conv ($$RA0, old_type, $$RA0, new_type)
			Move (old_data, old_type, $$RA0, old_type)
			a0 = 0: a0_type = 0
		ENDIF
	ELSE
		IF (old_type = new_type) THEN
			Move (old_data, old_type, $$RA0, old_type)
		ELSE
			Conv ($$RA0, old_type, $$RA0, new_type)
			Move (old_data, old_type, $$RA0, old_type)
		ENDIF
		DEC toes
		a0			= 0
		a0_type	= 0
	ENDIF
	GOTO zover

zover:
	IF a0 AND (a0 = toes) THEN DEC toes: a0 = 0: a0_type = 0: GOTO zass
	IF a1 AND (a1 = toes) THEN DEC toes: a1 = 0: a1_type = 0: GOTO zass

zass:
	IF (toes OR toms OR a0 OR a1 OR a0_type OR a1_type) THEN
		GOTO eeeExpressionStack
	ENDIF
	RETURN (token)


' ****************************************
' *****  ASSIGNMENT TO BRACE STRING  *****
' ****************************************

assignBraceString:
	got_executable = $$TRUE
	old_type		= $$UBYTE
	hold_type		= $$UBYTE
	hold_place	= tokenPtr - 1
	reg_type		= $$XLONG

' skip past "=" to source expression

	DO
		check = NextToken ()
	LOOP UNTIL ((check = T_EQ) OR (check{$$KIND} = $$KIND_STARTS))
	IF (check <> T_EQ) THEN GOTO eeeExpectAssignment

' evaluate the source expression

	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IF (new_type > $$XLONG) THEN GOTO eeeTypeMismatch
	holdp = tokenPtr
	holdt = new_op
	token = new_op
	IF new_data THEN
		Move ($$RA0, $$XLONG, new_data, $$XLONG)
		ss			= $$RA0
		toes		= 1
		a0			= toes
		a0_type = new_type
		ss = new_data{$$NUMBER}
	ELSE
		ss = Top ()
		IFZ ss THEN GOTO eeeTooFewArgs
	ENDIF

' get address of destination string element

	new_op = T_ADDR_OP
	tokenPtr = hold_place - 1
	new_prec = $$PREC_ADDR_OP
	new_data = 0: new_type = 0: new_test = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IF (new_type > $$XLONG) THEN GOTO eeeTypeMismatch
	IF (new_op <> T_EQ) THEN GOTO eeeCompiler
	IF new_data THEN GOTO eeeCompiler
	nn = Top ()
	IFZ nn THEN GOTO eeeTooFewArgs

	SELECT CASE nn
		CASE $$RA0
					ss = $$RA1
					IFZ a1 THEN Pop ($$RA1, @stype)
					Code ($$st, $$r0reg, $$ebx, $$eax, 0, $$UBYTE, @"", @"	;;; i25")
		CASE $$RA1
					ss = $$RA0
					IFZ a0 THEN Pop ($$RA0, @stype)
					Code ($$st, $$r0reg, $$eax, $$ebx, 0, $$UBYTE, @"", @"	;;; i29")
		CASE ELSE
					GOTO eeeCompiler
	END SELECT

	IF XERROR THEN
		tokenPtr = hold_place
		EXIT FUNCTION
	ENDIF
	toes = toes - 2
	a0 = 0: a0_type = 0
	a1 = 0: a1_type = 0
	tokenPtr = holdp
	RETURN (holdt)



' *********************************
' *****  ASSIGNMENT TO ARRAY  *****
' *********************************

assign_array:
	got_executable = $$TRUE
	hold_type = TheType (token)
	hold_place = tokenPtr
	hold_token = token
	IF (hold_type < $$SLONG) THEN
		reg_type = $$SLONG
	ELSE
		reg_type = hold_type
	ENDIF

	oo = token{$$NUMBER}
	IFZ m_addr$[oo] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION

	hold_type = TheType (token)			' xxxxx
	hold_type = tabType[oo]					' xxxxx

	IFZ hold_type THEN hold_type = TheType (token)		' xxxxx

	IF (hold_type >= $$SCOMPLEX) THEN GOTO assign_composite

	DO
		check = NextToken ()
	LOOP UNTIL ((check = T_EQ) OR (check{$$KIND} = $$KIND_STARTS))
	IF (check <> T_EQ) THEN GOTO eeeExpectAssignment

' evaluate the source expression

	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	holdp = tokenPtr
	holdt = new_op
	token = new_op
	stype = new_type
	IF new_data THEN ss = new_data{$$NUMBER} ELSE ss = Top ()
	IFZ ss THEN GOTO eeeTooFewArgs

	IF (new_type = $$STRING) THEN
		Move ($$RA0, old_type, ss, new_type)
		IF (oos[oos] = 'v') THEN
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"	;;; i21")
			oos[oos] = 's'
		ENDIF
		ss = $$RA0
		toes = 1
		a0 = toes
		a0_type = new_type
	ELSE
		IFZ toes THEN
			Move ($$RA0, old_type, ss, new_type)
			ss = $$RA0
			toes = 1
			a0 = toes
			a0_type = new_type
		ENDIF
	ENDIF

' get address of destination array element

	IF (hold_type = $$STRING) THEN
		new_op = T_HANDLE_OP
	ELSE
		new_op = T_ADDR_OP
	ENDIF
	tokenPtr = hold_place - 1
	new_prec = $$PREC_ADDR_OP
	new_data = 0
	new_type = 0
	new_test = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IFZ toes THEN GOTO eeeSyntax
	IF (new_op <> T_EQ) THEN GOTO eeeCompiler
	IF (hold_type = $$STRING) AND (hold_type <> stype) THEN
		GOTO eeeTypeMismatch
	ENDIF
	IF new_data THEN nn = new_data{$$NUMBER} ELSE nn = Top ()
	IFZ nn THEN GOTO eeeTooFewArgs

	IF (nn = $$RA0) THEN
		ss = $$RA1
		IFZ a1 THEN Pop ($$RA1, @stype)

' if source was a literal, a conversion may not be necessary to range check

		IF (hold_type <> stype) THEN
			IF ((hold_type >= $$GIANT) OR (stype >= $$GIANT)) THEN
				Conv ($$RA1, hold_type, $$RA1, stype)
			ENDIF
		ENDIF

		IF (hold_type = $$STRING) THEN
			Code ($$ld, $$regr0, $$esi, $$eax, 0, $$XLONG, @"", @"	;;; i22")
			Code ($$st, $$r0reg, $$ebx, $$eax, 0, $$XLONG, @"", @"	;;; i23")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i24")
			DEC oos
		ELSE
			SELECT CASE hold_type
				CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
							Code ($$fstp, $$r0, 0, $$eax, 0, hold_type, @"", @"	;;; i25")
				CASE ELSE
							Code ($$st, $$r0reg, $$ebx, $$eax, 0, hold_type, @"", @"	;;; i25")
			END SELECT
		ENDIF
		GOTO aaax
	ENDIF

	IF (nn = $$RA1) THEN
		ss = $$RA0
		IFZ a0 THEN Pop ($$RA0, @stype)

' if source was a literal, a conversion may not be necessary to range check

		IF (hold_type <> stype) THEN
			IF ((hold_type >= $$GIANT) OR (stype >= $$GIANT)) THEN
				Conv ($$RA0, hold_type, $$RA0, stype)
			ENDIF
		ENDIF
		IF (hold_type = $$STRING) THEN
			Code ($$ld, $$regr0, $$esi, $$ebx, 0, $$XLONG, @"", @"	;;; i26")
			Code ($$st, $$r0reg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i27")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i28")
			DEC oos
		ELSE
			SELECT CASE hold_type
				CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
							Code ($$fstp, $$r0, 0, $$ebx, 0, hold_type, @"", @"	;;; i29")
				CASE ELSE
							Code ($$st, $$r0reg, $$eax, $$ebx, 0, hold_type, @"", @"	;;; i30")
			END SELECT
		ENDIF
		GOTO aaax
	ENDIF
	GOTO eeeCompiler
aaax:
	IF XERROR THEN
		tokenPtr = hold_place
		EXIT FUNCTION
	ENDIF
	toes = toes - 2
	a0 = 0: a0_type = 0
	a1 = 0: a1_type = 0
	tokenPtr = holdp
	RETURN (holdt)


' *****************************************************
' *****  typenameAT (base, [index]) = expression  *****
' *****************************************************

p_sbyteat:
p_ubyteat:
p_sshortat:
p_ushortat:
p_slongat:
p_ulongat:
p_xlongat:
p_goaddrat:
p_subaddrat:
p_funcaddrat:
p_giantat:
p_singleat:
p_doubleat:
p_longdoubleat:
	got_executable = $$TRUE
	hold_place = tokenPtr
	hold_type  = TheType (token)
	hold_toes  = toes
	hold_toms  = toms
	DO
		check = NextToken ()
	LOOP UNTIL ((check = T_EQ) OR (check{$$KIND} = $$KIND_STARTS))
	IF (check <> T_EQ) THEN GOTO eeeExpectAssignment
	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	holdp = tokenPtr
	holdt = new_op
	token = new_op
	stype = new_type
	IFZ stype THEN GOTO eeeTooFewArgs
	IF (stype >= $$STRING) THEN GOTO eeeTypeMismatch
	IF new_data THEN
		source	= OpenAccForType (stype)
		Move (source, stype, new_data, stype)
	ELSE
		source	= Top ()
	ENDIF
	opcode		= $$st
	tokenPtr	= hold_place
	AtOps (hold_type, @opcode, @mode, @base, @offset, @source)

' modified for array offset using LONGDOUBLE
	IF (hold_type = $$LONGDOUBLE) && ((mode = $$rs || mode = $$regrs)) THEN
		SELECT CASE mode
			CASE $$rs    :
				Code ($$mov, $$regreg, $$eax, $$edi, 0, $$XLONG, @"", @"	;;; i31a")
				EmitAsm (@"  imul  eax,eax,12    ;;; i31b")
				Code ($$mov, $$regreg, $$edi, $$eax, 0, $$XLONG, @"", @"	;;; i31c")
				Code (opcode, $$rr, source, base, offset, hold_type, @"", @"	;;; i31d")
			' the following case may need to be changed
			CASE $$regrs :
				Code (opcode, $$regrr, source, base, offset, hold_type, @"", @"	;;; i31e")
		END SELECT
	ELSE
		Code (opcode, mode, source, base, offset, hold_type, @"", @"	;;; i32")
	ENDIF

'	Code (opcode, mode, source, base, offset, hold_type, @"", @"	;;; i32")

	tokenPtr	= holdp
	RETURN (holdt)


' *************************
' *****  GOTO LABELS  *****
' *************************

p_label:
	got_executable = $$TRUE
	IF (tokenPtr <> 1) THEN GOTO eeeSyntax
	IF (token{$$TYPE} <> $$GOADDR) THEN GOTO eeeTypeMismatch
	EmitUserLabel (token)
	IF XERROR THEN EXIT FUNCTION
	token = NextToken ()
	RETURN (token)


' ******************************
' *****  EXECUTE FUNCTION  *****
' ******************************

p_func:
p_atsign:
	got_executable = $$TRUE
	DEC tokenPtr
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (toes <> 1) THEN GOTO eeeCompiler
	IF (result_type = $$STRING) THEN
		Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, @"", @"	;;; i33")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i34")
		DEC oos
	ENDIF
	toes = 0
	a0 = 0: a0_type = 0
	a1 = 0: a1_type = 0
	RETURN (token)



' **********************************
' **********  STATEMENTS  **********
' **********************************



' *****  AUTO, STATIC, SHARED, SHARED /sharename/, EXTERNAL  *****

p_types:
	pallo = $$SHARED		' in PROLOG, SHARED allocation is assumed

p_auto:
p_autox:
p_static:
p_shared:
p_external:
	IF got_executable THEN GOTO eeeTooLate
	IFZ got_function THEN
		IFZ got_object_declaration THEN
			IFZ prologCode THEN
				EmitAsm (@".code")
				SELECT CASE TRUE
					CASE library	:  Code ($$jmp, $$rel, 0, 0, 0, 0, "%_StartLibrary_" + programName$, @"	;;; i36")
					CASE ELSE			:  Code ($$jmp, $$rel, 0, 0, 0, 0, @"%_StartApplication", @"	;;; i37")
				END SELECT
				prologCode = $$TRUE
				EmitLabel ("PrologCode." + programName$)
				Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i38")
				Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, @"", @"	;;; i39")
				Code ($$sub, $$regimm, $$esp, 256, 0, $$XLONG, @"", @"	;;; i40")
			ENDIF
		ENDIF
	ENDIF
	got_object_declaration = $$TRUE
	gotAllo = $$TRUE
	sharename$ = ""

	IF pallo THEN
		allo = pallo
	ELSE
		allo = token{$$ALLO}
		token = NextToken ()
	ENDIF

	IF ((allo == $$SHARED) OR (allo == $$EXTERNAL)) THEN
		IF (token = T_DIV) THEN		' SHARED /sharename/
			token = NextToken ()
			kind = token{$$KIND}
			SELECT CASE kind
				CASE $$KIND_SYMBOLS, $$KIND_VARIABLES
							s$ = tab_sym$[token{$$NUMBER}]
							token = NextToken ()
							IF (token <> T_DIV) THEN GOTO eeeSharename
							sharename$ = "%" + s$ + "%" + programName$
							token = NextToken ()
				CASE ELSE
							GOTO eeeSharename
			END SELECT
		ENDIF
	ENDIF

	dataType = TypenameToken (@token)
	GOTO p_type_data


' *****  SBYTE, UBYTE, SSHORT, USHORT, SLONG, ULONG, XLONG
' *****  GOADDR, SUBADDR, FUNCADDR, SINGLE, DOUBLE, GIANT, STRING
' *****  USER-DEFINED-TYPES

p_sbyte:
p_ubyte:
p_sshort:
p_ushort:
p_slong:
p_ulong:
p_xlong:
p_goaddr:
p_subaddr:
p_funcaddr:
p_single:
p_double:
p_giant:
p_string:
p_longdouble:
p_user_type:
	IF got_executable THEN GOTO eeeTooLate
	got_object_declaration = $$TRUE
	dataType = TypenameToken (@token)
	sharename$ = ""

p_type_data:
	e = token{$$NUMBER}
	adt = dataType
	SELECT CASE adt
		CASE $$GOADDR, $$SUBADDR
			IF (allo = $$SHARED) THEN GOTO eeeScopeMismatch
			IF (allo = $$EXTERNAL) THEN GOTO eeeScopeMismatch
		CASE $$FUNCADDR
			DIM funcaddrArg[]
			term = GetFuncaddrInfo (@token, @eleElements, @funcaddrArg[], @dataPtr)
			kind = token{$$KIND}
			e = token{$$NUMBER}
			tdt = token{$$TYPE}
			IF (tdt AND (tdt != $$FUNCADDR)) THEN GOTO eeeTypeMismatch
			ATTACH funcaddrArg[] TO tabArg[e, ]
			token = token OR (allo << 21)
			tabType[e] = adt
			UpdateToken (token)
			AssignAddress (token)
			IF XERROR THEN EXIT FUNCTION
			array = $$FALSE
			SELECT CASE kind
				CASE $$KIND_VARIABLES
							IF eleElements THEN GOTO eeeCompiler
				CASE $$KIND_ARRAYS
							IF eleElements THEN
								IF func_number THEN PRINT "eeeS22" : GOTO eeeSyntax
								holdPtr = tokenPtr
								tokenPtr = dataPtr - 1
								dim_array = $$TRUE
								token = Eval (@result_type)
								dim_array = $$FALSE
								IF XERROR THEN EXIT FUNCTION
								tokenPtr = holdPtr
							ENDIF
			END SELECT
			RETURN (term)
	END SELECT

' Get scope and check for scope mismatches like:::    STATIC  #Bill, ##Fred

	a = allo																					' scope
	IF tab_sym$[e] THEN																' symbol$
		IF (tab_sym$[e]{0} = '#') THEN									' # 1st byte
			a = $$SHARED																	' #SharedVariable
			IF (tab_sym$[e]{1} = '#') THEN a = $$EXTERNAL	' ##ExternalVariable
			IF gotAllo THEN																' got explicit scope name
				IF (a != allo) THEN GOTO eeeScopeMismatch		' AUTOX #Shared, ##External
			ENDIF
		ENDIF
	ENDIF

	tdt = token{$$TYPE}																' type in token$, token$$
	kind = token{$$KIND}															' kind in token$, token$[]
	SELECT CASE kind
		CASE $$KIND_VARIABLES	:	arrayKind = $$FALSE
		CASE $$KIND_ARRAYS		: arrayKind	= $$TRUE
		CASE ELSE							: PRINT "eeeS23" : GOTO eeeSyntax
	END SELECT

	IF ((adt && tdt) AND (adt != tdt)) THEN GOTO eeeTypeMismatch
	IFZ adt THEN adt = tdt
	IF m_addr$[e] THEN GOTO eeeDupDeclaration

	token = token OR (a << 21)												' put scope into token
	tabType[e] = adt
	UpdateToken (token)
	AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION

	htp = tokenPtr - 1
	token = NextToken ()

' Dimension arrays with subscripts, skip brackets[]

	IF arrayKind THEN
		IF (token != T_LBRAK) THEN GOTO eeeCompiler
		token = NextToken ()
		IF (token = T_RBRAK) THEN
			token = NextToken ()
		ELSE
			tokenPtr = htp
			dim_array = $$TRUE
			token = Eval (@result_type)
			dim_array = $$FALSE
			IF XERROR THEN EXIT FUNCTION
		ENDIF
	ENDIF

	IF (token = T_COMMA) THEN
		token	= NextToken ()
		kind	= token{$$KIND}
		GOTO p_type_data
	ENDIF

	token = NextToken ()
	sharename$ = ""
	RETURN (token)


' *****  ALL  *****

p_all:
	got_executable = $$FALSE		' remove eventually  (debug convenience)
	check = PeekToken ()
	IF (check = T_ALL) THEN
		e = 0
		check = NextToken ()
	ELSE
		e = 36
	ENDIF
	PRINT "***** VARIABLE SYMBOLS *****"
	PRINT " ##  token    symbol                   r_addr$        m_addr$            type"
	DO
		symbol$ = tab_sym$[e]
		token	= tab_sym[e]
		kind	= token{$$KIND}
		SELECT CASE kind
			CASE $$KIND_ARRAYS, $$KIND_ARRAY_SYMBOLS
			symbol$ = symbol$ + "[]"
		END SELECT
		PRINT HEX$(e, 4);; HEX$(tab_sym[e], 8);; symbol$; TAB(39);; r_addr$[e]; TAB(54);; m_addr$[e]; TAB(73);; HEX$(tabType[e])
		INC e
	LOOP WHILE (e < tab_sym_ptr)

	PRINT
	PRINT "***** FUNCTION SYMBOLS *****"
	PRINT " ##  token    symbol"
	FOR i = 1 TO maxFuncNumber
	PRINT HEX$(i, 4);; HEX$(funcToken[i], 8);; funcSymbol$[i]
	NEXT i

	RETURN ($$T_STARTS)


' *****  CONSOLE  *****

p_console:
	consoleStatement = $$TRUE
	token	= NextToken ()
	RETURN (token)

' *****  EXPLICIT  *****

p_explicit:
	explicitStatement = $$TRUE
	token	= NextToken ()
	RETURN (token)

' *****  NOINIT  *****

'p_noinit:
'        noinitStatement = $$TRUE
'        token   = NextToken ()
'        RETURN (token)
' *****  ATTACH  *****  ATTACH fromArray[*] TO toArray[*]

p_attach:
	attachoid		= $$TRUE
	GOTO p_swapper


' *****  CASE  *****

p_case:
	got_executable = $$TRUE
	nestObject	= nestVar[nestLevel]						' token for test expression
	caseItem		= 0
	caseFloat		= $$FALSE
	caseString	= $$FALSE
	nestType		= nestObject{$$TYPE}						' test expression type
	SELECT CASE nestType
		CASE $$STRING:		 caseString	  = $$TRUE
		CASE $$SINGLE:		 caseFloat		= $$TRUE
		CASE $$DOUBLE:		 caseFloat		= $$TRUE
		CASE $$LONGDOUBLE: caseFloat    = $$TRUE
	END SELECT
	nestToken		= nestToken[nestLevel]
	nestKinds		= nestToken{$$RAWTYPE}					' ALL, TRUE, FALSE flags
	caseCount		= nestInfo[nestLevel]
	IF (caseCount = $$TRUE) THEN GOTO eeeAfterElse
	IF (nestKinds AND 0x80) THEN caseAll = $$TRUE ELSE caseAll = $$FALSE
	IF (nestKinds AND 0x60) THEN caseTFs = $$TRUE ELSE caseTFs = $$FALSE
	IF ((nestToken AND 0x1F00FFFF) <> T_SELECT) THEN PRINT "eeeS23" : GOTO eeeSyntax

' end of previous CASE block unless this is the 1st case block

	IF caseCount THEN
		IFF caseAll THEN
			d1$ = "end.select." + HEX$(nestCount[nestLevel], 4) + "." + programName$
			Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i69")
		ENDIF
		EmitLabel ("case." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(caseCount, 4) + "." + programName$)
	ENDIF

' *****  CASE ELSE
' *****  CASE ALL

	token = PeekToken ()
	SELECT CASE token
		CASE T_ELSE:	IF caseAll THEN GOTO eeeElseInCaseAll
									nestInfo[nestLevel] = $$TRUE
									token = NextToken ()
									token = NextToken ()
									RETURN (token)
		CASE T_ALL:		IFF caseAll THEN GOTO eeeBadCaseAll
									nestInfo[nestLevel] = $$TRUE
									token = NextToken ()
									token = NextToken ()
									RETURN (token)
	END SELECT

' *****  CASE <expression>  *****

	DO
		GOSUB Tester
		IF caseTFs THEN nestType = new_type
		SELECT CASE (nestKinds AND 0x60)			' 00 = <exp> : 40 = TRUE : 20 = FALSE
			CASE 0x40:	ifc = $$TRUE:  GOSUB SelectCaseTrue
			CASE 0x20:	ifc = $$FALSE: GOSUB SelectCaseFalse
			CASE 0x00:	ifc = $$FALSE: GOSUB SelectCaseExpression
			CASE ELSE:	PRINT "eeeS24" : GOTO eeeSyntax
		END SELECT
		toes = 0
		INC caseItem
		a0 = 0: a0_type = 0
		a1 = 0: a1_type = 0
	LOOP WHILE (new_op = T_COMMA)
	IF (caseItem > 1) THEN
		EmitLabel ("caser." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount,4) + "." + programName$)
	ENDIF
	INC caseCount
	nestInfo[nestLevel] = caseCount
	RETURN (new_op)


' *****  SELECT CASE TRUE  *****

SUB SelectCaseTrue
	IF (new_op = T_COMMA) THEN
		where$ = "caser." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount, 4) + "." + programName$
		GOSUB TestTrue
	ELSE
		where$ = "case." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount+1,4) + "." + programName$
		GOSUB TestFalse
	ENDIF
END SUB


' *****  SELECT CASE FALSE  *****

SUB SelectCaseFalse
	IF (new_op = T_COMMA) THEN
		where$ = "caser." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount, 4) + "." + programName$
		GOSUB TestFalse
	ELSE
		where$ = "case." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount+1,4) + "." + programName$
		GOSUB TestTrue
	ENDIF
END SUB


' *****  SELECT CASE <expression>  *****

SUB SelectCaseExpression
	IF (newType >= $$SCOMPLEX) THEN GOTO eeeTypeMismatch
	IF (nestType <> new_type) THEN
		SELECT CASE typeConvert[nestType, new_type] {{$$BYTE0}}
			CASE -1:		GOTO eeeTypeMismatch
			CASE  0:		' convert not required
			CASE ELSE:	Conv ($$eax, nestType, $$eax, new_type)
		END SELECT
	ENDIF
	IF XERROR THEN EXIT FUNCTION
	IF caseString THEN
		ooos			= oos[oos]
		oos[oos]	= 'v'
		INC oos
		oos[oos]	= ooos
		IF (acc != $$eax) THEN
			Move ($$eax, $$XLONG, acc, $$XLONG)				' added from xx8v  05/10/92
			acc			= $$eax
		ENDIF
	ENDIF
	IF caseFloat THEN expression = $$TRUE
	IFZ caseItem THEN expression = $$TRUE
	IF expression THEN
		Move ($$ebx, nestType, nestObject, nestType)
		expression = $$FALSE
	ENDIF
	Op ($$eax, $$ebx, T_EQ, $$eax, $$XLONG, nestType, nestType, nestType)
	IF (new_op = T_COMMA) THEN
		d1$ = "caser." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(caseCount, 4) + "." + programName$
		Code ($$je, $$rel, 0, 0, 0, 0, ">> " + d1$, @"	;;; i70")
	ELSE
		x1$ = "case." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(caseCount+1, 4) + "." + programName$
		Code ($$jne, $$rel, 0, 0, 0, 0, ">> " + x1$, @"	;;; i71")
	ENDIF
END SUB


' ***********************
' *****  NEXT CASE  *****
' ***********************

p_next_case:
	token				= NextToken ()									' token = possible "level" literal
	levelKind		= token{$$KIND}
	IF (levelKind = $$KIND_LITERALS) THEN
		ll = token{$$NUMBER}
		IFZ m_addr$[ll] THEN AssignAddress (token)
		IF XERROR THEN EXIT FUNCTION
		ll = token{$$NUMBER}
		exitLevels = XLONG (r_addr$[ll])
		skipLevels = $$TRUE
	ELSE
		skipLevels = $$FALSE
		exitLevels = 1
	ENDIF
	checkLevel = nestLevel
	checkToken = T_SELECT
	GOSUB NestWalk
	caseCount	= nestInfo[checkLevel]
	dx$				= "case." + HEX$(nestCount[checkLevel], 4) + "." + HEX$(caseCount, 4) + "." + programName$
	Code ($$jmp, $$rel, 0, 0, 0, 0, @dx$, @"	;;; i72")
	IF skipLevels THEN token = NextToken ()
	expression	= $$TRUE
	RETURN (token)

' ********************************************
' *****  CLOSE   (fileNumber)            *****
' *****  QUIT    (status)                *****
' *****  SEEK    (fileNumber, position)  *****
' *****  SHELL   (command$)              *****
' ********************************************

p_close:
p_quit:
p_seek:
p_shell:
	got_executable = $$TRUE
	DEC tokenPtr
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	DEC toes
	a0			= 0
	a1			= 0
	a0_type	= 0
	a1_type	= 0
	RETURN (token)


' *******************************
' *****  INLINE$ (prompt$)  *****  Allows INLINE$() to begin a line
' *******************************

p_inline_d:
	got_executable = $$TRUE
	DEC tokenPtr
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (oos[oos] = 's') THEN
		acc	= Top ()
		Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, @"", @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"")
	ENDIF
	DEC oos
	DEC toes
	a0			= 0
	a1			= 0
	a0_type	= 0
	a1_type	= 0
	RETURN (token)


' *****************
' *****  DEC  *****
' *****************
' *****  INC  *****
' *****************

p_dec:
	op86	= $$dec
	GOTO p_inc_dec
p_inc:
	op86	= $$inc
	GOTO p_inc_dec

p_inc_dec:
	holdPtr	= tokenPtr
	token		= NextToken ()
	tvart		= token{$$NUMBER}
	tkind		= token{$$KIND}
	SELECT CASE tkind
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
		CASE ELSE: PRINT "eeeS25" : GOTO eeeSyntax
	END SELECT
	IFZ m_addr$[tvart] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
	ttype		= TheType (token)
	IF (ttype = $$STRING) THEN GOTO eeeTypeMismatch
	IF (ttype < $$SCOMPLEX) THEN
		IF (tkind = $$KIND_ARRAYS) THEN GOTO p_inc_dec_array
	ENDIF
	IF (ttype < $$SBYTE) THEN GOTO eeeCompiler
	IF (ttype < $$SLONG) THEN ttype = $$SLONG

	IF (ttype < $$SCOMPLEX) THEN
		ctype		= $$FALSE
		mReg		= m_reg[tvart]
		mAddr		= m_addr[tvart]
		mAddr$	= m_addr$[tvart]
		treg		= r_addr[tvart]
	ELSE
		creg		= token
		ctype		= ttype
		command = $$GETDATAADDR
		Composite (command, @ttype, @creg, @offset, 0)
		IF XERROR THEN EXIT FUNCTION
		IF toes THEN xx = Topax1 ()
		SELECT CASE TRUE
			CASE (ttype < $$SBYTE):				GOTO eeeTypeMismatch
'			CASE (ttype > $$DOUBLE):			GOTO eeeTypeMismatch
			CASE (ttype > $$LONGDOUBLE):	GOTO eeeTypeMismatch
			CASE (ttype = $$GOADDR):			GOTO eeeTypeMismatch
			CASE (ttype = $$SUBADDR):			GOTO eeeTypeMismatch
			CASE (ttype = $$FUNCADDR):		GOTO eeeTypeMismatch
		END SELECT
		IFZ creg THEN
			Move ($$RA1, $$XLONG, token, $$XLONG)
			creg = $$RA1
		ENDIF
		IF (ttype < $$SLONG) THEN ttype = $$SLONG
		SELECT CASE ttype
			CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
			CASE ELSE
						Code ($$ld, $$regro, $$esi, creg, offset, ttype, @"", @"	;;; i73")
		END SELECT
		treg		= $$esi
		mReg		= creg
		mAddr		= offset
	ENDIF
	oreg		= treg
	oregx		= oreg + 1
	GOSUB IncOrDecValue
	token			= NextToken ()
	RETURN (token)

' INC or DEC array element

p_inc_dec_array:
	token			= NextToken ()
	IF (token != T_LBRAK) THEN GOTO eeeCompiler
	token			= NextToken ()
	IF (token = T_RBRAK) THEN PRINT "eeeS26" : GOTO eeeSyntax
	tokenPtr	= holdPtr
	new_test	= 0
	new_op = T_ADDR_OP: new_prec = $$PREC_ADDR_OP: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IF new_data THEN GOTO eeeCompiler
	IF (new_type != $$XLONG) THEN GOTO eeeCompiler
	creg			= Topax1 ()
	htype			= ttype
	oreg			= $$esi
	oregx			= $$edi
	ctype			= htype
	mReg			= creg
	mAddr			= 0
	offset		= 0
	GOSUB IncOrDecValue
	token			= NextToken ()
	RETURN (token)


' INC or DEC value in oreg
' IF ctype THEN store result at (creg + offset)
' ELSE store back in original variable "tvart"

SUB IncOrDecValue
	SELECT CASE ttype
		CASE $$SBYTE, $$SSHORT, $$SLONG
					IF mReg THEN
						Code (op86, $$ro, 0, mReg, mAddr, ttype, @"", @"	;;; i74")
						Code ($$into, $$none, 0, 0, 0, 0, @"", @"	;;; i75")
					ELSE
						Code (op86, $$abs, 0, 0, mAddr, ttype, @mAddr$, @"	;;; i76")
						Code ($$into, $$none, 0, 0, 0, 0, @"", @"	;;; i77")
					ENDIF
					ctype	= 0
					treg	= $$TRUE
		CASE $$UBYTE, $$USHORT, $$ULONG
					d1$ = CreateLabel$ ()
					IF mReg THEN
						Code (op86, $$ro, 0, mReg, mAddr, ttype, @"", @"	;;; i78")
						Code ($$jnc, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i79")
						Code ($$int, $$imm, 3, 0, 0, 0, @"", @"	;;; i80")
					ELSE
						Code (op86, $$abs, 0, 0, mAddr, ttype, @mAddr$, @"	;;; i81")
						Code ($$jnc, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i82")
						Code ($$int, $$imm, 3, 0, 0, 0, @"", @"	;;; i83")
					ENDIF
					EmitLabel (@d1$)
					ctype	= 0
					treg	= $$TRUE
		CASE $$XLONG
					IF mReg THEN
						Code (op86, $$ro, 0, mReg, mAddr, $$XLONG, @"", @"	;;; i84")
					ELSE
						Code (op86, $$abs, 0, 0, mAddr, $$XLONG, @mAddr$, @"	;;; i85")
					ENDIF
					ctype	= 0
					treg	= $$TRUE
		CASE $$GIANT
					IF creg <> $$eax THEN oreg = $$eax ELSE oreg = $$ebx
					oregx = oreg + 1
     			IF ctype THEN
      			Code ($$st, $$regro, oreg, creg, offset, ttype, @"", @"	;;; i85a")
     			ELSE
      			Move (oreg, ttype, tvart, ttype)
     			ENDIF
					SELECT CASE op86
						CASE $$inc:	Code ($$add, $$regimm, oreg, 1, 0, $$XLONG, @"", @"	;;; i86")
												Code ($$adc, $$regimm, oregx, 0, 0, $$XLONG, @"", @"	;;; i87")
												Code ($$into, $$none, 0, 0, 0, 0, @"", @"	;;; i88")
						CASE $$dec:	Code ($$sub, $$regimm, oreg, 1, 0, $$XLONG, @"", @"	;;; i89")
												Code ($$sbb, $$regimm, oregx, 0, 0, $$XLONG, @"", @"	;;; i90")
												Code ($$into, $$none, 0, 0, 0, 0, @"", @"	;;; i91")
					END SELECT
'					Move (token, ttype, $$eax, ttype)
					a0_type = 0
					a0 = 0
		CASE $$SINGLE
					IF mReg THEN
						Code ($$fld, $$ro, 0, mReg, mAddr, $$SINGLE, @"", @"	;;; i92")
					ELSE
						Code ($$fld, $$abs, 0, 0, mAddr, $$SINGLE, @"", @"	;;; i93")
					ENDIF
					Code ($$fld1, $$none, 0, 0, 0, 0, @"", @"	;;; i94")
					SELECT CASE op86
						CASE $$inc:	Code ($$fadd, $$none, 0, 0, 0, 0, @"", @"	;;; i95")
						CASE $$dec: Code ($$fsub, $$none, 0, 0, 0, 0, @"", @"	;;; i96")
						CASE ELSE:	PRINT "i47 bustoid": GOTO eeeCompiler
					END SELECT
		CASE $$DOUBLE
					IF mReg THEN
						Code ($$fld, $$ro, 0, mReg, mAddr, $$DOUBLE, @"", @"	;;; i97")
					ELSE
						Code ($$fld, $$abs, 0, 0, mAddr, $$DOUBLE, @"", @"	;;; i98")
					ENDIF
					Code ($$fld1, $$none, 0, 0, 0, 0, @"", @"	;;; i99")
					SELECT CASE op86
						CASE $$inc:	Code ($$fadd, $$none, 0, 0, 0, 0, @"", @"	;;; i100")
						CASE $$dec: Code ($$fsub, $$none, 0, 0, 0, 0, @"", @"	;;; i101")
						CASE ELSE:	PRINT "i51 bustoid": GOTO eeeCompiler
					END SELECT
		CASE $$LONGDOUBLE
					IF mReg THEN
						Code ($$fld, $$ro, 0, mReg, mAddr, $$LONGDOUBLE, @"", @"	;;; i97")
					ELSE
						Code ($$fld, $$abs, 0, 0, mAddr, $$LONGDOUBLE, @"", @"	;;; i98")
					ENDIF
					Code ($$fld1, $$none, 0, 0, 0, 0, @"", @"	;;; i99")
					SELECT CASE op86
						CASE $$inc:	Code ($$fadd, $$none, 0, 0, 0, 0, @"", @"	;;; i100")
						CASE $$dec: Code ($$fsub, $$none, 0, 0, 0, 0, @"", @"	;;; i101")
						CASE ELSE:	PRINT "i51 bustoid": GOTO eeeCompiler
					END SELECT
		CASE ELSE
					GOTO eeeTypeMismatch
	END SELECT
	IF ctype THEN
		SELECT CASE ttype
			CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
						Code ($$fstp, $$ro, 0, creg, offset, ttype, @"", @"	;;; 101a")
			CASE ELSE
						Code ($$st, $$roreg, oreg, creg, offset, ttype, @"", @"	;;; i102")
		END SELECT
	ELSE
		SELECT CASE ttype
			CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
						FloatStore ($$RA0, tvart, ttype)
			CASE ELSE
						IFZ treg THEN Move (tvart, ttype, oreg, ttype)
		END SELECT
	ENDIF
END SUB


' *****  EXTERNAL FUNCTION  *****
' *****  INTERNAL FUNCTION  *****
' *****  DECLARE  FUNCTION  *****

' DECLARE [c]FUNCTION [type.name] function.name ( [parameter.list] )

p_external_func:
p_internal_func:
p_declare_func:
	IF got_function THEN GOTO eeeDeclare
	IFZ got_declare THEN
		got_declare = $$TRUE
		ef$ = funcSymbol$[entryFunction]
		xit = (ef$ = "Xit")
	ENDIF

	token = NextToken ()
	SELECT CASE token
		CASE T_FUNCTION		: declareFuncKind = $$XFUNC
		CASE T_SFUNCTION	: declareFuncKind = $$SFUNC
		CASE T_CFUNCTION	: declareFuncKind = $$CFUNC
		CASE ELSE					: PRINT "eeeS27" : GOTO eeeSyntax
	END SELECT

	token = NextToken ()
	func_type = TypenameToken (@token)
	kind = token{$$KIND}
	IF (kind <> $$KIND_FUNCTIONS) THEN PRINT "eeeS28" : GOTO eeeSyntax
	IF token{$$ALLO} THEN PRINT "dupdec3": GOTO eeeDupDeclaration
	func_num = token{$$NUMBER}
	DIM tempArg[19]
	funcScope[func_num]			= funcScope
	IF ((func_num = entryFunction) AND (funcScope = $$FUNC_EXTERNAL)) THEN
		GOTO eeeEntryFunction
	ENDIF
	funcName$	= funcSymbol$[func_num]
	lastChar	= funcName${LEN(funcName$)-1}
	IFZ charsetSymbolInner[lastChar] THEN AssemblerSymbol (@funcName$)

	rt = token{$$TYPE}
	IF rt THEN
		IF func_type AND (rt <> func_type) THEN GOTO eeeTypeMismatch
		func_type = rt
	ENDIF
	IF (func_type < $$SLONG) THEN func_type = $$XLONG
	funcType[func_num] = func_type
	tempArg[0] = ($$KIND_VARIABLES << 24) + func_type
	function_token = token OR ($$TYPE_DECLARED << 16)
	IF (func_type >= $$SCOMPLEX) THEN func_type = 0
	funcKind[func_num] = declareFuncKind
	token = NextToken ()
	IF (token != T_LPAREN) THEN PRINT "eeeS29" : GOTO eeeSyntax

	arg = 0
	argNum = 1
	declare_arg_addr = 0
	token = PeekToken()
	IF (token = T_RPAREN) THEN token = NextToken(): GOTO p_dec_end_of_parameters

' *****  collect and log the parameter kinds and types  *****

p_dec_p_loop:
	DO
		token				= NextToken ()
		akind				= $$KIND_VARIABLES
		temp_type		= TypenameToken (@token)
		IF (token = T_ATSIGN) THEN token = NextToken ()			' ignore @ prefix
		SELECT CASE temp_type
			CASE $$ETC
						declare_arg_addr = 64						' allow 16 words of args on "..."
						IF (token != T_RPAREN) THEN PRINT "eeeS30" : GOTO eeeSyntax
						IF (declareFuncKind != $$CFUNC) THEN PRINT "eeeS31" : GOTO eeeSyntax
			CASE ELSE
						pkind = token{$$KIND}
						SELECT CASE pkind
							CASE $$KIND_STATEMENTS
										IF (token != T_ANY) THEN PRINT "eeeS32" : GOTO eeeSyntax
										token			= NextToken ()
										pkind			= token{$$KIND}
										temp_type	= $$ANY
										SELECT CASE TRUE
											CASE (pkind = $$KIND_ARRAY_SYMBOLS)
														akind			= $$KIND_ARRAYS
														tt				= NextToken ()
														IF (tt != T_LBRAK) THEN GOTO eeeSyntax
														tt				= NextToken ()
														IF (tt != T_RBRAK) THEN GOTO eeeSyntax
														GOSUB ValidateParameterSymbol
														token			= NextToken ()
											CASE (token = T_LBRAK)
														tt				= NextToken ()
														IF (tt != T_RBRAK) THEN GOTO eeeSyntax
														pkind			= $$KIND_ARRAY_SYMBOLS
														akind			= $$KIND_ARRAYS
														token			= NextToken ()
											CASE ((token = T_COMMA) OR (token = T_RPAREN))
														pkind			= $$KIND_SYMBOLS
														akind			= $$KIND_VARIABLES
											CASE ELSE
														GOTO eeeSyntax
										END SELECT
							CASE $$KIND_SYMBOLS
										akind = $$KIND_VARIABLES
										GOSUB ValidateParameterSymbol
										token = NextToken ()
							CASE $$KIND_ARRAY_SYMBOLS
										akind = $$KIND_ARRAYS
										tt		= NextToken ()
										IF (tt != T_LBRAK) THEN GOTO eeeSyntax
										tt		= NextToken ()
										IF (tt != T_RBRAK) THEN GOTO eeeSyntax
										GOSUB ValidateParameterSymbol
										token = NextToken ()
							CASE ELSE
										IF temp_type THEN
											SELECT CASE token
												CASE T_COMMA, T_RPAREN
													akind = $$KIND_VARIABLES
												CASE T_LBRAK
													token = NextToken ()
													IF (token != T_RBRAK) THEN GOTO eeeSyntax
													token = NextToken ()
													akind = $$KIND_ARRAYS
												CASE ELSE
													GOTO eeeSyntax
											END SELECT
										ENDIF
						END SELECT
		END SELECT

		tempArg[argNum]	= (akind << 24) + temp_type
		IF (akind = $$KIND_ARRAYS) THEN
			declare_arg_addr = declare_arg_addr + 4
		ELSE
			SELECT CASE temp_type
				CASE $$GIANT, $$DOUBLE
							declare_arg_addr = declare_arg_addr + 8
				CASE $$LONGDOUBLE
							declare_arg_addr = declare_arg_addr + 12
				CASE $$ETC
							' nop
				CASE ELSE
							declare_arg_addr = declare_arg_addr + 4
			END SELECT
		ENDIF
		INC arg
		INC argNum
	LOOP WHILE (token = T_COMMA)

' *****
' *****  all parameters collected  *****
' *****

p_dec_end_of_parameters:
	tempArg[0] = tempArg[0] + (arg << 16)
	funcArgSize[func_num] = declare_arg_addr
	ATTACH funcArg[func_num, ] TO temp[]: DIM temp[]
	ATTACH tempArg[] TO funcArg[func_num, ]
	IF (token != T_RPAREN) THEN GOTO eeeSyntax
	SELECT CASE declareFuncKind
		CASE $$XFUNC	: funcName$ = funcName$ + "@" + STRING(declare_arg_addr)
		CASE $$SFUNC	: funcName$ = funcName$ + "@" + STRING(declare_arg_addr)
		CASE $$CFUNC	:
	END SELECT
	SELECT CASE funcScope
		CASE $$FUNC_DECLARE
					IFF export THEN XstReplace (@funcName$, @"@", "." + programName$ + "@", 1)
					funcName$ = "_" + funcName$
					AddLabel (@funcName$, $$T_LABELS, $$XNEW)
		CASE $$FUNC_EXTERNAL
					funcName$ = "_" + funcName$
		CASE $$FUNC_INTERNAL
					funcName$ = funcName$ + "." + programName$
					AddLabel (@funcName$, $$T_LABELS, $$XNEW)
		CASE ELSE
					GOTO eeeCompiler
	END SELECT

	libraryFunctionLabel$ = funcName$
	funcLabel$[func_num] = funcName$
	funcToken[func_num] = function_token

	IF export THEN
		IF (funcScope = $$FUNC_DECLARE) THEN
			IFZ preExports THEN
				preExports = $$TRUE
				string$ = "EXPORTS  %_StartLibrary_" + programName$
				WriteDefinitionFile (@string$)
			ENDIF
			string$ = "EXPORTS  " + funcSymbol$[func_num]
			WriteDefinitionFile (@string$)
'			IF LEN (funcSymbol$[func_num]) > 3 THEN
'				IF LEFT$ (funcSymbol$[func_num],3) = "Xst" THEN
'					string$ = "EXPORTS  " + MID$ (funcSymbol$[func_num],4) + " = " + funcSymbol$[func_num]
'					WriteDefinitionFile (@string$)
'				ENDIF
'			ENDIF
		ENDIF
	ENDIF

	RETURN (NextToken())

' *****  subroutine for DECLARE  *****

SUB ValidateParameterSymbol
	token_type = token{$$TYPE}
	IF token_type THEN
		IF temp_type THEN
			IF (token_type <> temp_type) THEN GOTO eeeTypeMismatch
		ENDIF
		temp_type = token_type
	ELSE
		IFZ temp_type THEN temp_type = $$XLONG
	ENDIF
END SUB


' *****  DIM  *****

p_dim:
p_redim:
	got_executable = $$TRUE
	dim_array = token
p_dim_loop:
	token = NextToken ()
	kind = token{$$KIND}
	IF (kind <> $$KIND_ARRAYS) THEN dim_array = $$FALSE: GOTO eeeSyntax
	DEC tokenPtr
	token = Eval (@result_type)
	IF (token = T_COMMA) THEN GOTO p_dim_loop
	dim_array = $$FALSE
	RETURN (token)


' *****  DO  *****

p_do:
	got_executable = $$TRUE
	token = NextToken ()
	nothing = $$TRUE
	levelToken = PeekToken ()
	levelKind = levelToken{$$KIND}
	IF (levelKind = $$KIND_LITERALS) THEN
		ll = levelToken{$$NUMBER}
		IFZ m_addr$[ll] THEN AssignAddress (levelToken)
		IF XERROR THEN EXIT FUNCTION
		ll = levelToken{$$NUMBER}
		exitLevels = XLONG (r_addr$[ll])
		skipLevels = $$TRUE
	ELSE
		skipLevels = $$FALSE
		exitLevels = 1
	ENDIF

	SELECT CASE token
		CASE T_DO
					checkLevel = nestLevel
					checkToken = T_DO
					GOSUB NestWalk
					d1$ = "do." + HEX$(nestCount[checkLevel], 4) + "." + programName$
					Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i103")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_FOR
					checkLevel = nestLevel
					checkToken = T_FOR
					GOSUB NestWalk
					d1$ = "for." + HEX$(nestCount[checkLevel], 4) + "." + programName$
					Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i104")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_LOOP
					checkLevel = nestLevel
					checkToken = T_DO
					GOSUB NestWalk
					d1$ = "do.loop." + HEX$(nestCount[checkLevel], 4)  + "." + programName$
					Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i105")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_NEXT
					checkLevel = nestLevel
					checkToken = T_FOR
					GOSUB NestWalk
					d1$ = "do.next." + HEX$(nestCount[checkLevel], 4)  + "." + programName$
					Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i106")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_WHILE:  nothing = $$FALSE: ifc = $$FALSE
		CASE T_UNTIL:  nothing = $$FALSE: ifc = $$TRUE
	END SELECT
	INC nestCount
	INC nestLevel
	nestVar[nestLevel]		= 0
	nestInfo[nestLevel]		= 0
	nestToken[nestLevel]	= T_DO
	nestLevel[nestLevel]	= nestLevel
	nestCount[nestLevel]	= nestCount

	EmitLabel ("do." + HEX$(nestCount[nestLevel], 4)  + "." + programName$)

	IF nothing THEN RETURN (token)
	where$ = "end.do." + HEX$(nestCount[nestLevel], 4)  + "." + programName$
	GOSUB Tester
	IF ifc THEN
		GOSUB TestTrue
	ELSE
		GOSUB TestFalse
	ENDIF
	RETURN (token)


' *****  ELSE  *****

p_else:
	got_executable = $$TRUE
	IF (nestInfo[nestLevel]) THEN GOTO eeeNest
	IF (nestToken[nestLevel] <> T_IF) THEN GOTO eeeNest
	nestInfo[nestLevel] = $$TRUE
	d1$ = "end.if." + HEX$(nestCount[nestLevel], 4) + "." + programName$
	Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i107")
	EmitLabel ("else." + HEX$(nestCount[nestLevel], 4)  + "." + programName$)
	token = NextToken ()
	RETURN (token)


' *****  END  *****

' END, END FUNCTION, ENDIF, END PROGRAM, END SELECT, END SUB, END COMMENT

p_end:
	token = NextToken ()
	IF (token != T_EXPORT) THEN got_executable = $$TRUE
	SELECT CASE token
		CASE T_EXPORT												: GOTO p_end_export
		CASE T_FUNCTION											: GOTO p_end_function
		CASE T_IF														: GOTO p_end_if
		CASE T_PROGRAM											: GOTO p_end_program
		CASE T_SELECT												: GOTO p_end_select
		CASE T_SUB													: GOTO p_end_sub
		CASE $$T_STARTS, T_REM, T_COLON			: GOTO p_end_program
		CASE ELSE														: GOTO eeeSyntax
	END SELECT

'
' ************************
' *****  END EXPORT  *****
' ************************

p_end_export:
	export = $$FALSE
	RETURN ($$T_STARTS)


' **************************
' *****  END FUNCTION  *****
' **************************

p_end_function:
p_end_functions:
	got_object_declaration = $$FALSE
	got_executable = $$FALSE
	IF (insub OR nestLevel) THEN insub = 0 : nestLevel = 0 : GOTO eeeNest
	token = ReturnValue (@rt)
	IF XERROR THEN EXIT FUNCTION
	funcKind = funcKind[func_number]
	hfn$ = HEX$(func_number)

' Emit function EPILOG
	EmitAsm ("end." + funcSymbol$[func_number] + "." + programName$ + ":  ;;; Function end label for Assembly Programmers.")
	EmitLabel ("end.func" + hfn$ + "." + programName$)

' emit profiler function exit code
	IF fProfile THEN
		EmitAsm (@"  push  eax            ;;; i107a")
		EmitAsm (@"  call  _pexit@0       ;;; i107b")
		EmitAsm (@"  pop   eax            ;;; i107c")
	ENDIF


' Deallocate AUTO and AUTOX composite data

	IF compositeNumber[func_number] THEN
		Deallocate (compositeToken[func_number, 0])
	ENDIF

' Deallocate AUTO and AUTOX strings and arrays

	IF hash%[func_number, ] THEN
		FOR i = 0 TO 255
			IF hash%[func_number, i, ] THEN
				FOR j = 1 TO hash%[func_number, i, 0]
					k			= hash%[func_number, i, j]
					tk		= tab_sym[k]
					kind	= tk{$$KIND}
					ttype	= TheType (tk)
					tallo	= tk{$$ALLO}
					IF ((tallo = $$AUTO) OR (tallo = $$AUTOX)) THEN
						SELECT CASE kind
							CASE $$KIND_VARIABLES
								IF (ttype = $$STRING) THEN	Deallocate (tk)
							CASE $$KIND_ARRAYS:						Deallocate (tk)
						END SELECT
					ENDIF
				NEXT j
			ENDIF
		NEXT i
	ENDIF


' Compute base addresses of the areas on the stack frame

	inarg_base = (autoxAddr[func_number] + 15) AND 0xFFFFFFF0
	IF (inarg_base < 0x0100) THEN inarg_base = 0x0100
	funcFrameSize[func_number] = inarg_base
	first_auto		= inargAddr[func_number]
	after_auto		= autoAddr[func_number]
	first_reg			= (first_auto >> 2) + 2
	after_reg			= (after_auto >> 2) + 2
	restore_after	= after_reg + 4
	restore_addr	= 0x70
	restore_reg		= 14


' call "end_program" routine if done with entry function

	IFZ library THEN
		IF (func_number = entryFunction) THEN
			IFZ fProfile THEN    ' skip this call to end_program when doing profiling with proflib.dll
			  Code ($$call, $$rel, 0, 0, 0, 0, "end_program." + programName$, @"	;;; i108")
			ENDIF
		ENDIF
	ENDIF

	ebx_zeroed = $$FALSE

'	return to calling function, abandon frame

	' ######################################################################################
	' # The code below is a significant change from previous versions of xb or xblite.		 #
	'	# -	ESI, EDI, and EBX are restored by being POP'd instead of MOV'd.  In order to do  #
	'	# 	this there is an additional instruction, "lea esp,[ebp-20]", which sets up the   #
	'	#		stack pointer (ESP) for the subsequent pops.																		 #
	' ######################################################################################

	Code ($$lea, $$regro, $$esp, $$ebp, -20, $$XLONG, @"", @"		;;; i110")
	Code ($$pop, $$reg, $$ebx, 0, 0, $$XLONG, @"", @"		;;; restore ebx")
	Code ($$pop, $$reg, $$edi, 0, 0, $$XLONG, @"", @"		;;; restore edi")
	Code ($$pop, $$reg, $$esi, 0, 0, $$XLONG, @"", @"		;;; restore esi")
	EmitAsm ("	leave					;;; replaces \"mov esp,ebp\", \"pop ebp\"")

	funcArgSize = funcArgSize[func_number]
	IF funcArgSize THEN
		SELECT CASE funcKind
			CASE $$XFUNC	: Code ($$ret, $$imm, funcArgSize[func_number], 0, 0, 0, @"", @"	;;; i111a")
			CASE $$SFUNC	: Code ($$ret, $$imm, funcArgSize[func_number], 0, 0, 0, @"", @"	;;; i111b")
			CASE $$CFUNC	: Code ($$ret, $$none, 0, 0, 0, 0, @"", @"	;;; i111c")
		END SELECT
	ELSE
		Code ($$ret, $$none, 0, 0, 0, 0, @"", @"			;;; i111d")
	ENDIF
	EmitAsm (@";  *****")
	EmitAsm (";  *****  END FUNCTION  " + funcSymbol$[func_number] + " ()  *****")
	EmitAsm (@";  *****")


' **********************************
' *****  Emit function PROLOG  *****
' **********************************

	#emitasm = 2								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"

	EmitAsm (@";  *****")
	EmitAsm (";  *****  FUNCTION  " + funcSymbol$[func_number] + " ()  *****")
	EmitAsm (@";  *****")
	EmitLabel ("func" + hfn$ + "." + programName$)

	IF fProfile THEN EmitAsm (@"  call  _penter@0     ;;; i111g")

	d0$ = CreateLabel$ ()
	d1$ = CreateLabel$ ()
	Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i112")
	Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, @"", @";;; i113")
	Code ($$sub, $$regimm, $$esp, 8, 0, $$XLONG, @"", @"	;;; i114")			' ebp-4 and ebp-8 are reserved
	Code ($$push, $$reg, $$esi, 0, 0, $$XLONG, @"",	@"	;;; save esi")
	Code ($$push, $$reg, $$edi, 0, 0, $$XLONG, @"", @"	;;; save edi")
	Code ($$push, $$reg, $$ebx, 0, 0, $$XLONG, @"", @"	;;; save ebx")
	IF (func_number = entryFunction) THEN
		Code ($$call, $$rel, 0, 0, 0, 0, "%%%%initOnce." + programName$, @"")
	ENDIF

	' ######################################################################################
	' # This section is a huge change from previous versions of xb or xblite.							 #
	'	# - esi, edi, and ebx are PUSHed instead of MOVed.	  															 #
	'	# -	There is no longer a "one-size-fits-all" initialization routine.								 #
	'	# 	-	For small blocks, a series of pushes are encoded                               #
	'	# 	-	For medium - large blocks, a small loop is used to push 32 bytes at a time     #
	'	# 	-	For large - huge blocks, use MMX code to move 64 bytes at a time (not yet)		 #
	' ######################################################################################

	zeroz = -autoxAddr[func_number]
	IF zeroz THEN
		count	= ((-24 - zeroz) >>> 2) + 1												' with nothing at ebp-20
		IF (count < 0) THEN PRINT "count": GOTO eeeCompiler			' with nothing at ebp-20
		IF count THEN
			esp_displacement = inarg_base-20
'			IFF noinitStatement THEN
				EmitAsm (";")
				EmitAsm (";	#### Begin Local Initialization Code ####")
				d1$ = CreateLabel$ ()
				SELECT CASE TRUE
					CASE count = 1		' = 4 bytes
						Code ($$push, $$imm, 0, 0, 0, $$XLONG, @"",	@"	;;; .")
					CASE count = 2		' = 8 bytes
						Code ($$push, $$imm, 0, 0, 0, $$XLONG, @"",	@"	;;; .")
						Code ($$push, $$imm, 0, 0, 0, $$XLONG, @"",	@"	;;; ..")
					CASE count <= 8		' <= 32 bytes
						Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @";;; .")
						FOR i = 1 TO count
							Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"",	@"	;;; ..")
						NEXT i
					CASE count <= 16	' <= 64 bytes
						quads = count\4
						Code ($$mov, $$regimm, $$ecx, quads, 0, $$XLONG, @"", @"		;;; ..")
						Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; ...")
						EmitAsm (d1$ + ":")
						EmitAsm ("	push	eax, eax, eax, eax")
						Code ($$dec, $$reg, $$ecx, 0, 0, $$XLONG, @"", @"			;;; ....")
						Code ($$jnz, $$rel, 0, 0, 0, 0, " < " + d1$, @"	;;; .....")
						FOR i = 1 TO (count-quads*4)
							Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"",	@"		;;; ......")
						NEXT i
					CASE ELSE				' > 64 bytes
						octaves = count\4
						Code ($$mov, $$regimm, $$ecx, octaves, 0, $$XLONG, @"", @"		;;; ..")
						Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; ...")
						EmitAsm (d1$ + ":")
						EmitAsm ("	push	eax, eax, eax, eax")
						EmitAsm ("	push	eax, eax, eax, eax")
						Code ($$dec, $$reg, $$ecx, 0, 0, $$XLONG, @"", @"			;;; ....")
						Code ($$jnz, $$rel, 0, 0, 0, 0, " < " + d1$, @"	;;; .....")
						FOR i = 1 TO (count-octaves*8)
							Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"",	@"		;;; ......")
						NEXT i
				END SELECT
				EmitAsm (";	#### End Local Initialization Code ####")
				EmitAsm (";")
'			ELSE
'				count = 0
'				noinitStatement = $$FALSE
'			ENDIF
			IF count THEN
				EmitAsm (";	################################################################################")
				EmitAsm (";	### *** IMPORTANT *** - If hand-optimizing by eliminating the initialization ###")
				EmitAsm (";	### code above, the first 'sub esp,____' line below must be uncommented, and ###")
				EmitAsm (";	### the second must be either deleted or commented out.                      ###")
				EmitAsm (";	### !!! Failure to do so will cause the resultant program to crash !!!       ###")
				EmitAsm (";	################################################################################")
				EmitAsm (";")
				EmitAsm (";	sub esp," + STRING$(esp_displacement) + "			;;; uncomment this line for hand-optimization!")
			ENDIF
		ENDIF
	ENDIF
	esp_displacement = esp_displacement-(count*4)
	IF esp_displacement THEN
		Code ($$sub, $$regimm, $$esp, esp_displacement, 0, $$XLONG, @"", @"	;;; i114a")
		EmitAsm (";")
	ENDIF

' Assign addresses to AUTO and AUTOX composite handles

	cn = compositeNumber[func_number]
	IF cn THEN
		' It is ok for this code to use esi, as here it does not affect register variables
		totalSize = compositeNext[func_number, cn]
		Code ($$mov, $$regimm, $$esi, totalSize, 0, $$XLONG, @"", @"	;;; i124a")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____calloc", @"	;;; i124b")
		base = compositeToken[func_number, 0]
		Move (base, $$XLONG, $$esi, $$XLONG)
		FOR i = 1 TO cn
			compositeToken = compositeToken[func_number, i]
			compositeStart = compositeStart[func_number, i]
			' Alernate registers to improve pipelining - GH August 2006
			IF (i\2)*2 = i THEN
				Code ($$lea, $$regro, $$ecx, $$esi, compositeStart, $$XLONG, @"", @"	;;; i125")
				Move (compositeToken, $$XLONG, $$ecx, $$XLONG)
			ELSE
				Code ($$lea, $$regro, $$edx, $$esi, compositeStart, $$XLONG, @"", @"	;;; i125a")
				Move (compositeToken, $$XLONG, $$edx, $$XLONG)
			ENDIF
		NEXT i
	ENDIF

' if composite then save address where caller wants composite return value

	IF crvtoken THEN Move (crvtoken, $$XLONG, $$ebx, $$XLONG)

' branch to body of function

	#emitasm = 2								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"
	 							' flush everything in assembly language output buffer
	#emitasm = 0								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"

	IF (func_number = entryFunction) THEN
		EmitLabel ("%%%%initOnce." + programName$)
		d0$ = CreateLabel$ ()
		EmitAsm ("	cmp d[%%%entered." + programName$ + "],-1		;;; i117")
		EmitAsm ("	jne > " + d0$ + "	;;; i117a")
		EmitAsm ("	ret			;;; i117b")
		EmitLabel (d0$)
		Code ($$call, $$rel, 0, 0, 0, 0, "PrologCode." + programName$, @"	;;; i118a")
		EmitAsm ("	lea esi,%_begin_external_data_" + programName$)
		EmitAsm ("	lea edi,%_end_external_data_" + programName$)
		EmitAsm ("	call %_ZeroMemory")
		Code ($$call, $$rel, 0, 0, 0, 0, "InitSharedComposites." + programName$, @"	;;; i119")
    Code ($$mov, $$absimm, 0, -1, 0, $$XLONG, "%%%entered." + programName$, @"")
		Code ($$ret, $$none, 0, 0, 0, 0, @"", @"	;;; i120")

'		EmitAsm (@".data")
		EmitAsm ("data section '" + programName$ + "$internals'")
		EmitAsm (@"align	8")
		EmitLabel ("%%%entered." + programName$)
		EmitAsm (@"db 8 dup 0")
		EmitAsm (@".code")
	ENDIF

	ina_function	= $$FALSE
	funcKind			= $$FALSE
	funcType			= $$FALSE
	func_number		= $$FALSE
	hfn$					= ""

	IF xargNum THEN
		FOR i = 0 TO xargNum - 1
			EmitAsm ("def	" + xargName$[i] + "," + STRING$ (inarg_base + xargAddr[i]))
			xargName$[i]	= ""
			xargAddr[i]		= 0
		NEXT i
		xargNum = 0
	ENDIF
	RETURN (token)


' *****  ENDIF  *****

p_endif:
p_end_if:
	got_executable = $$TRUE
	IF (nestLevel < 0) THEN GOTO eeeNest
	IF (nestToken[nestLevel] != T_IF) THEN GOTO eeeNest
	IF (nestLevel[nestLevel] != nestLevel) THEN GOTO eeeNest
	IFZ nestInfo[nestLevel] THEN
		EmitLabel ("else." + HEX$(nestCount[nestLevel], 4)  + "." + programName$)
	ENDIF
	EmitLabel ("end.if." + HEX$(nestCount[nestLevel], 4) + "." + programName$)
	DEC nestLevel
	token = NextToken ()
	RETURN (token)


' *****  END SELECT *****

p_end_select:
	got_executable = $$TRUE
	stk = nestVar[nestLevel]
	sty = TheType (stk)
	itk = nestToken[nestLevel]
	ifc = nestInfo[nestLevel]
	isc = nestCount[nestLevel]

' the following line can't be: "IFF ifc THEN"  (need to test for -1)

	IF (ifc <> $$TRUE) THEN
		EmitLabel ("case." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(ifc, 4) + "." + programName$)
	ENDIF
	IF (nestLevel < 0) THEN nestLevel = 0 : GOTO eeeNest
	IF (nestLevel[nestLevel] <> nestLevel) THEN GOTO eeeNest
	IF ((itk AND 0x1F00FFFF) <> T_SELECT) THEN GOTO eeeNest
	EmitLabel ("end.select." + HEX$(nestCount[nestLevel], 4) + "." + programName$)
	DEC nestLevel
	token = NextToken ()
	RETURN (token)



' *****  END SUB  *****

p_end_sub:
	got_executable = $$TRUE
	stoken = subToken[subCount]
	IFF insub THEN GOTO eeeNest
	IF nestLevel THEN GOTO eeeNest
	EmitLabel ("end.sub" + hfn$ + "." + HEX$(subCount) + "." + programName$)
	Code ($$ret, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i127")
	EmitLabel ("out.sub" + hfn$ + "." + HEX$(subCount) + "." + programName$)
	insub$ = ""
	insub = $$FALSE
	INC subCount
	token = NextToken ()
	RETURN (token)


' *****  END PROGRAM  *****

p_end_program:
	got_executable = $$FALSE
	got_object_declaration = $$FALSE
	IF func_number THEN GOTO eeeWithinFunction
	IF nestLevel THEN nestLevel = 0: GOTO eeeNest

	EmitLabel ("end_program." + programName$)
	Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i128")
	Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, @"", @"	;;; i129")
	Code ($$sub, $$regimm, $$esp, 128, 0, $$XLONG, @"", @"	;;; i130")

' Deallocate composite data area

	IF compositeNumber[0] THEN
		tk	= compositeToken[0, 0]
		Move ($$esi, $$XLONG, tk, $$XLONG)
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i131")
	ENDIF

' Deallocate STATIC and SHARED strings and arrays

	FOR f = 1 TO maxFuncNumber
		IF hash%[f, ] THEN
			FOR h = 0 TO 255
				IF hash%[f, h, ] THEN
					FOR j = 1 TO hash%[f, h, 0]
						k			= hash%[f, h, j]
						tk		= tab_sym[k]
						kind	= tk{$$KIND}
						ttype	= TheType (tk)
						tallo	= tk{$$ALLO}
						IF ((tallo = $$STATIC) OR (tallo = $$SHARED)) THEN
							SELECT CASE kind
								CASE $$KIND_VARIABLES	: IF (ttype = $$STRING) THEN Deallocate (tk)
								CASE $$KIND_ARRAYS		:	Deallocate (tk)
							END SELECT
						ENDIF
					NEXT j
				ENDIF
			NEXT h
		ENDIF
	NEXT f


' return to invoking program or XBasic environment

	past_statics = (externalAddr + 0x0100) AND 0xFFFFFF00
	IFZ library THEN
		Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxTerminate@0", @"")
	ENDIF
	Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, @"", @"	;;; i132")
	Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i133")
	Code ($$ret, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i134")

' Assign addresses to EXTERNAL, SHARED, STATIC composite handles

	EmitLabel ("InitSharedComposites." + programName$)
	cn = compositeNumber[0]
	IF cn THEN
	' It is ok for this code to use esi, as here it does not affect register variables
		totalSize = compositeNext[0, cn]
		Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i135")
		Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, @"", @"	;;; i136")
		Code ($$sub, $$regimm, $$esp, 128, 0, $$XLONG, @"", @"	;;; i137")
		Code ($$mov, $$regimm, $$esi, totalSize, 0, $$XLONG, @"", @"	;;; i138")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____calloc", @"	;;; i139a")
		Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, @"", @"	;;; i139b")
		base = compositeToken[0, 0]
		Move (base, $$XLONG, $$eax, $$XLONG)
		FOR i = 1 TO cn
			compositeToken = compositeToken[0, i]
			compositeStart = compositeStart[0, i]

			' Alernate registers to improve pipelining - GH May 2006
			IF (i\2)*2 = i THEN
				Code ($$lea, $$regro, $$ecx, $$esi, compositeStart, $$XLONG, @"", @"	;;; i140")
				Move (compositeToken, $$XLONG, $$ecx, $$XLONG)
			ELSE
				Code ($$lea, $$regro, $$edx, $$esi, compositeStart, $$XLONG, @"", @"	;;; i140a")
				Move (compositeToken, $$XLONG, $$edx, $$XLONG)
			ENDIF

		NEXT i
		Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, @"", @"	;;; i141")
		Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i142")
	ENDIF
	Code ($$ret, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i143")

' Emit _WinMain code in executable programs
' or _DllMain code in DLL libraries
	IFF library THEN
	  IFF fNoWinMain THEN
			EmitAsm (@";")
			EmitAsm (@".code")
			EmitAsm (@"; ########################")
			EmitAsm (@"; #####  WinMain ()  #####")
			EmitAsm (@"; ########################")
			EmitAsm (@"align 8")
			EmitAsm (@"_main:												; C entry label")
			EmitAsm (@"_WinMain:											; Windows entry label")
			EmitAsm (@"_WinMain@16:									; Windows entry label")
			EmitAsm (@"	push ebp")
			EmitAsm (@"	mov ebp,esp")
			EmitAsm (@"	push addr %_StartApplication")
			EmitAsm (@"	call _Xit@4")
			EmitAsm (@"	call _XxxTerminate@0")
			EmitAsm (@"	mov esp,ebp")
			EmitAsm (@"	pop ebp")
			EmitAsm (@"	ret")
			EmitAsm (@";")
		ENDIF
	ELSE
		IF LCASE$ (programName$) = "xst" THEN
			EmitAsm (@";")
			EmitAsm (@".code")
			EmitAsm (@"; ########################")
			EmitAsm (@"; #####  DllMain ()  #####")
			EmitAsm (@"; ########################")
			EmitAsm (@"; New startup sequence for XBLite by Ken Minogue - 12/15/03")
			EmitAsm (@"; - The system loads xbl.dll, calls DllMain to initialize memory and xst.")
			EmitAsm (@"; - Xio() is called from Xst(), instead of Xit(), to ensure the console is")
			EmitAsm (@";   initialized regardless of how xbl.dll is loaded.")
			EmitAsm (@"; - The system calls WinMain, which pushes %_StartApplication and calls Xit().")
			EmitAsm (@"; - Xit() sets up the exception handler and calls the user application.")
			EmitAsm (@"; ********************************")
			EmitAsm (@"; DllMain is written slightly differently from my previous version, with three")
			EmitAsm (@"; goals in mind:")
			EmitAsm (@"; - to ensure that xbl.dll is always properly initialized when a process starts,")
			EmitAsm (@";   even if the process is an exe written in another language.  At present, if I")
			EmitAsm (@";   write an XBLite dll and call it from a C program, the program will crash as soon")
			EmitAsm (@";   as memory allocation is attempted - because _XxxMain is never called and xbl.dll")
			EmitAsm (@";   is never initialized.")
			EmitAsm (@"; - to initialize the FPU when a thread is started.")
			EmitAsm (@"; - to maintain compatibility with current XBLite executables.")
			EmitAsm (@"align 8")
			EmitAsm (@"%_XxxXstInitialize:")
			EmitAsm (@"	push 0")
			EmitAsm (@"	push 1								; simulate DLL_PROCESS_ATTACH")
			EmitAsm (@"	push 0")
			EmitAsm (@"	call noDllMain")
			EmitAsm (@"	ret")
			EmitAsm (@";")
			IFF fNoDllMain THEN EmitAsm (@"_DllMain@12:")
			EmitAsm (@"noDllMain:")
			EmitAsm (@"	push ebp")
			EmitAsm (@"	mov ebp,esp")
			EmitAsm (@"	mov eax,[ebp+12] 				; fdwReason")
			EmitAsm (@"	or eax,eax")
			EmitAsm (@"	jz > process_detach")
			EmitAsm (@"	dec eax")
			EmitAsm (@"	jz > process_attach")
			EmitAsm (@"	dec eax")
			EmitAsm (@"	jz > thread_attach")
			EmitAsm (@"	dec eax")
			EmitAsm (@"	jz > thread_detach")
			EmitAsm (@"	xor eax,eax     				; error - illegal argument")
			EmitAsm (@"	jmp exit_DllMain")
			EmitAsm (@"process_attach:")
			EmitAsm (@"	cmp d[%initialized],0		; is it already done?")
			EmitAsm (@"	jne > D.1")
			EmitAsm (@"	call initialize  				; initialize memory allocation")
			EmitAsm (@"	call _Xst@0     				; initialize xst arrays, and also Xio()")
			EmitAsm (@"thread_attach:						; initialize FPU, set precision to 64-bit")
			EmitAsm (@"	finit										; unmask divide-by-zero, overflow, and underflow FPU exceptions")
			EmitAsm (@"	sub esp,4")
			EmitAsm (@"	fstcw W[esp]")
			EmitAsm (@"	and D[esp],0xFFFFFFE3")
			EmitAsm (@"	fldcw W[esp]")
			EmitAsm (@"	add esp,4")
			EmitAsm (@"D.1:")
			EmitAsm (@"	mov eax,1     					; success")
			EmitAsm (@"process_detach:")
			EmitAsm (@"thread_detach:")
			EmitAsm (@"exit_DllMain:")
			EmitAsm (@"	mov esp,ebp")
			EmitAsm (@"	pop ebp")
			EmitAsm (@"	ret 12")
			EmitAsm (@";")
		ELSE
			IFF fNoDllMain THEN
				EmitAsm (@";")
				EmitAsm (@".code")
				EmitAsm (@"; ########################")
				EmitAsm (@"; #####  DllMain ()  #####")
				EmitAsm (@"; ########################")
				EmitAsm (@"align 8")
				EmitAsm (@"_DllMain@12:")
				EmitAsm (@"	mov eax,1     							; success")
				EmitAsm (@"	ret 12")
				EmitAsm (@";")
      ENDIF
    ENDIF
	ENDIF

	EmitAsm (@";;;  *****  DEFINE '.bss' SECTION LIMITS  *****")
	EmitAsm (@";")
	EmitAsm (@"align 8")
	EmitAsm ("data section '" + programName$ + "$aaaaa'")
	EmitAsm ("%_begin_external_data_" + programName$ + " dd ?")
	EmitAsm (@";")
	EmitAsm (@"align 8")
	EmitAsm ("data section '" + programName$ + "$zzzzz'")
	EmitAsm ("%_end_external_data_" + programName$ + " dd ?")
	EmitAsm (@";")
	EmitAsm (@";")

	EmitAsm (@";;;  *****  DEFINE LITERAL STRINGS  *****")

' NOTE:	Literal strings are compiled into READ-ONLY program memory !!!

	EmitAsm (@".const")
	EmitAsm (@"align 8")

	xx = 0
	hfn$ = "0"
	func_number = 0
	DO WHILE (xx < tab_sym_ptr)
		check = tab_sym[xx]
		ktest = check{$$KIND}
		ttest = check{$$TYPE}
		IF ((ktest = $$KIND_LITERALS) AND (ttest = $$STRING)) THEN
			lit$   = tab_sym$[xx]
			litlen = LEN (lit$) - 2
			inlit$ = MID$ (lit$, 2, litlen)
			label$ = "@_string." + HEX$(xx, 4) + "." + programName$
			EmitString (label$, @inlit$)
		ENDIF
		INC xx
	LOOP

' Do NOT add the programName$ entry here after the second parameter,
' it will cause Dll load failures!! - GH 22 Nov 2005
	EmitString ("@_string.StartLibrary." + programName$, @"%_StartLibrary_")

' Make sure all referenced GOTO and GOSUB labels were defined  (asm only)

  i = 0
	pass2errors = 0
	DIM errSymbol$[]
	DIM errToken[]
	DIM errAddr[]
	GOSUB PatchAsm
	IF pass2errors THEN
		REDIM errSymbol$[pass2errors-1]
		REDIM errToken[pass2errors-1]
		REDIM errAddr[pass2errors-1]
	ENDIF

' generate makefile to generate .EXE or .DLL

	libslot = 0 'newimport
	objslot = 0 'newimport
	fixlib = 0

	IF fMak THEN GOTO skip_makefile


	' check for custom template makefile
	IF makefile$ THEN
		IF RIGHT$ (LCASE$(makefile$), 3) = "xxx" THEN
			custom = $$TRUE
		ELSE
			custom = $$FALSE						' use default makefile
'			GOTO skip_makefile
		ENDIF
	ENDIF

	IF programName$ THEN
		SELECT CASE LCASE$(programName$)
			CASE "xlib", "xst"
			CASE ELSE		: fixlib = $$TRUE
		END SELECT
		IF fixlib THEN
			IF libraryName$[] THEN
				upper = UBOUND (libraryName$[])
				DIM lib$[upper], obj$[upper]              'newimport
				FOR i = 0 TO upper
					libname$ = TRIM$(libraryName$[i])
					libext$ = libraryExt$[i]                'newimport
					IF libext$ = "dll" THEN libext$ = "lib" 'newimport
					IF libname$ THEN
						SELECT CASE LCASE$(libname$)
							CASE "xlib", "xst"
								lib$[libslot] = "xbl.lib"
								INC libslot
							CASE ELSE
'newimport - start
									SELECT CASE libext$
										CASE "lib"
											lib$[libslot] = libname$ + "." + libext$
											INC libslot
										CASE "o", "obj"
											obj$[objslot] = libname$ + "." + libext$
											INC objslot
									END SELECT
'newimport - end
						END SELECT
					ENDIF
				NEXT i
			ENDIF

			IF custom THEN
				file$ = ##XBDir$ + $$PathSlash$ + "templates" + $$PathSlash$ + makefile$
			ELSE
				IF library THEN
					file$ = ##XBDir$ + $$PathSlash$ + "templates" + $$PathSlash$ + "xdll.xxx"
				ELSE
					file$ = ##XBDir$ + $$PathSlash$ + "templates" + $$PathSlash$ + "xapp.xxx"
				ENDIF
			ENDIF

			XstLoadStringArray (@file$, @file$[])

			app = $$FALSE
			libs = $$FALSE
			start = $$FALSE
			xblite = $$FALSE
			subsystem = $$FALSE

			IF file$[] THEN
				win95 = $$FALSE
				XstGetOSVersion (@major, @minor, 0, @"", @"")
				IF (major >= 4) THEN win95 = $$TRUE

				FOR i = 0 TO UBOUND (file$[])

					IFZ app THEN
						app = INSTR (file$[i], "APP")
						IF app THEN
							line$ = file$[i]
							equal = RINSTR (line$, "=")
							IF equal THEN
								file$[i] = LEFT$ (line$, equal) + " " + programName$
							ELSE
								app = $$FALSE			' didn't find "APP" and "="
							ENDIF
						ENDIF
					ENDIF

					IFZ start THEN
						start = INSTR (file$[i], "START")
						IF start THEN
							line$ = file$[i]
							equal = RINSTR (line$, "=")
							IF equal THEN
								IF win95 THEN file$[i] = LEFT$ (line$, equal) + " START /W"
							ELSE
								start = $$FALSE		' didn't find "START" and "="
							ENDIF
						ENDIF
					ENDIF

					IFZ subsystem THEN
						subsystem = INSTR (file$[i], "SUBSYSTEM")
						IF subsystem THEN
							line$ = file$[i]
							equal = RINSTR (line$, "=")
							IF equal THEN
								IF consoleStatement THEN
									IF win95 THEN file$[i] = LEFT$ (line$, equal) + " CONSOLE"
								ENDIF
							ELSE
								subsystem = $$FALSE		' didn't find "SUBSYSTEM" and "="
							ENDIF
						ENDIF
					ENDIF

					'###################################################################################################
					'# The logic of the following is to assure that the standard runtime is always linked, even if not #
					'# IMPORTed.  All programs require it anyway, so it might as well be linked automatically. If the  #
					'# dynamic dll (xst or xbl.dll) is not specified, it will default to a static one, under the       #
					'# assumption that this is what most programmers would want.                                       #
					'###################################################################################################

					IFZ libs THEN
						libs = INSTR (file$[i], "LIBS")
						IF libs THEN
							libs$ = file$[i]
							equal = RINSTR (libs$, "=")
							IF equal THEN
								IF libslot THEN          'newimport
									FOR j = 0 TO libslot-1 'newimport
										libs$ = libs$ + " " + lib$[j]
									NEXT j
									IFZ ((INSTRI (libs$,"xst_s.lib")) + (INSTRI (libs$,"xbl.lib"))) THEN
										file$[i] = libs$ + " xst_s.lib"
									ELSE
										file$[i] = libs$
									ENDIF
								ELSE
									file$[i] = libs$ + " xst_s.lib"
								ENDIF
							ELSE
								libs = $$FALSE			' didn't find "LIBS" and "="
							ENDIF
						ENDIF
					ENDIF

'newimport - start
					IFZ objs THEN
						objs = INSTR (file$[i], "OBJS")
						IF objs THEN
							objs$ = file$[i]
							equal = RINSTR (objs$, "=")
							IF equal THEN
								IF objslot THEN
									FOR j = 0 TO objslot-1
										objs$ = objs$ + " " + obj$[j]
									NEXT j
									file$[i] = objs$
								ENDIF
							ELSE
								objs = $$FALSE			' didn't find "OBJS" and "="
							ENDIF
						ENDIF
					ENDIF
'newimport - end

					IFZ xblite THEN
						xblite = INSTR (file$[i], "XBLITE")
						IF xblite THEN
							xblite$ = file$[i]
							equal = RINSTR (xblite$, "=")
							IF equal THEN
								SELECT CASE ALL TRUE
									CASE library 				: xblite$ = xblite$ + " " + "-lib"
									CASE fConsole 			: xblite$ = xblite$ + " " + "-conoff"
									CASE checkBounds 		: xblite$ = xblite$ + " " + "-bc"
									CASE removeComment 	: xblite$ = xblite$ + " " + "-rc"
									CASE fLogErrors 		: xblite$ = xblite$ + " " + "-log"
									CASE fM4            : xblite$ = xblite$ + " " + "-m4"
								END SELECT
								file$[i] = xblite$
							ELSE
								xblite = $$FALSE			' didn't find "XBLITE" and "="
							ENDIF
						ENDIF
					ENDIF

					IF app THEN
						IF libs THEN
							IF start THEN
								IF xblite THEN
									IF subsystem THEN
										ofile$ = fileName$ + ".mak"
										XstSaveStringArrayCRLF (@ofile$, @file$[])  ' save it each time
										EXIT FOR
									ENDIF
								ENDIF
							ENDIF
						ENDIF
					ENDIF
				NEXT i
			ENDIF
		ENDIF
	ENDIF

skip_makefile:

	XstDecomposePathname (fileName$, @path$, @"", @"", @"", @"")
	IF path$ THEN path$ = path$ + $$PathSlash$

' ***** Create a .bat file to automatically create .exe or .dll *****

	bat = $$FALSE
	IF fBat THEN bat = $$TRUE
	IFZ bat THEN
		bat = $$TRUE
		DIM bat$[5]
		bat$[0] = "@ECHO OFF"
		bat$[1] = "SET XBLDIR=" + ##XBDir$
		bat$[2] = "SET PATH="   + ##XBDir$ + $$PathSlash$ + "bin;%PATH%"
		bat$[3] = "SET LIB="    + ##XBDir$ + $$PathSlash$ + "lib"
		bat$[4] = "SET INCLUDE="+ ##XBDir$ + $$PathSlash$ + "include"
		bat$[5] = "nmake -f " + programName$ + ".mak" + " all clean"
		IF makefile$ THEN
			IFZ custom THEN
				bat$[5] = "nmake -f " + makefile$ + " all clean"
			ENDIF
		ENDIF
		fn$ = path$ + programName$ + ".bat"
		fileNum = OPEN (fn$, $$RD)
		IF (fileNum <= 0) THEN										' file .bat does not already exist
			XstSaveStringArrayCRLF (@fn$, @bat$[])
		ENDIF
		CLOSE (fileNum)
	ENDIF

' ***** Create a resource file *.rc from template resource xrc.xxx *****

	rcfile = $$FALSE
  IF fRc THEN rcfile = $$TRUE
	IFZ rcfile THEN
		rcfile = $$TRUE
		fn$ = path$ + programName$ + ".rc"
		fileNum = OPEN (fn$, $$RD)
		IF (fileNum <= 0) THEN										' file .rc does not already exist
			file$ = ##XBDir$ + $$PathSlash$ + "templates" + $$PathSlash$ + "xrc.xxx"
			XstLoadStringArray (@file$, @rc$[])			' load xrc.xxx template
			XstSaveStringArrayCRLF (@fn$, @rc$[])		' save .rc file in current directory
		ENDIF
		CLOSE (fileNum)
	ENDIF

	XxxCloseCompileFiles ()
	end_program = $$TRUE
	token = NextToken ()
	RETURN (token)

' *****  PatchAsm  *****

SUB PatchAsm
	DO WHILE (i <= labelPtr)
		token = tab_lab[i]
		laddr = labaddr[i]
		ltype = token{$$TYPE}
		SELECT CASE ltype
			CASE $$GOADDR, $$SUBADDR
				IFZ laddr THEN
					lab$	= MID$(tab_lab$[i], 4)
					name	= INSTR(lab$, "%") - 1
					lab$	= LEFT$(lab$, name)

					IFZ pass2errors THEN PRINT "*****  PATCH ERRORS  *****"
					IF ltype = $$GOADDR THEN
						type$ = "GOTO"
					ELSE
						type$ = "GOSUB"
					ENDIF

					PRINT type$ + " label <"; lab$; "> never defined"
					IFT fLogErrors THEN
						file$    = programName$ + ".log"
						message$ = ""
						message$ = message$ + lab$ + ","
						message$ = message$ + type$ + " label never defined" + ","
						message$ = message$ + STRING$(0) + ","
						message$ = message$ + STRING$(0)
						XstLog (message$, $$TRUE, file$)
					ENDIF

					INC pass2errors
				ENDIF
		END SELECT
		INC i
	LOOP

' Make sure all DECLARE functions and INTERNAL functions were defined.

	i = 0
	DO WHILE (i <= maxFuncNumber)
		token = funcToken[i]
		IF token THEN
			flocal = funcScope[i]
			IF flocal THEN															' INTERNAL or DECLARE
				IFZ (token AND $$MASK_DEFINED) THEN
					lab$ = funcSymbol$[i]
					laddr = 0
					IFZ pass2errors THEN PRINT "*****  PATCH ERRORS  *****"
					PRINT "Function <"; lab$; "()> declared but never defined."
					INC pass2errors
'					GOSUB AddPatchError
				ENDIF
			ENDIF
		ENDIF
		INC i
	LOOP
END SUB

' *****  Log Patch Errors  *****

SUB AddPatchError
	upper = UBOUND (errAddr[])
	IF (pass2errors > upper) THEN
		upper = upper + 64
		REDIM errSymbol$[upper]
		REDIM errToken[upper]
		REDIM errAddr[upper]
	ENDIF
	kind = p2{$$KIND}
	tnum = p2{$$NUMBER}
	SELECT CASE kind
		CASE $$KIND_LABELS
					ltype = token{$$TYPE}
					IF ((ltype = $$GOADDR) OR (ltype = $$SUBADDR)) THEN
						lab$ = MID$(lab$, 4)
						name = INSTR(lab$, "%") - 1
						lab$ = LEFT$(lab$, name)
					ENDIF
		CASE ELSE
					PRINT "CheckState(): Error: (patch token kind != label) : EXIT SUB"
	END SELECT
	errSymbol$[pass2errors] = lab$
	errToken[pass2errors] = token
	errAddr[pass2errors] = laddr
	INC pass2errors
END SUB


' *****  EXIT  *****  EXIT  { DO | FOR | FUNCTION | IF | SELECT | SUB }

p_exit:
	got_executable = $$TRUE
	token = NextToken ()
	levelToken = PeekToken ()
	levelKind = levelToken{$$KIND}
	IF (levelKind = $$KIND_LITERALS) THEN
		ll = levelToken{$$NUMBER}
		IFZ m_addr$[ll] THEN AssignAddress (levelToken)
		IF XERROR THEN EXIT FUNCTION
		ll = levelToken{$$NUMBER}
		exitLevels = XLONG (r_addr$[ll])
		skipLevels = $$TRUE
	ELSE
		skipLevels = $$FALSE
		exitLevels = 1
	ENDIF

	SELECT CASE token
		CASE T_DO
				checkLevel = nestLevel
				checkToken = T_DO
				GOSUB NestWalk
				d1$ = "end.do." + HEX$(nestCount[checkLevel], 4) + "." + programName$
				Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i144")
		CASE T_FOR
				checkLevel = nestLevel
				checkToken = T_FOR
				GOSUB NestWalk
				d1$ = "end.for." + HEX$(nestCount[checkLevel], 4) + "." + programName$
				Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i145")
		CASE T_FUNCTION
				IF (exitLevels != 1) THEN GOTO eeeSyntax
				GOTO p_return
		CASE T_IF
				checkLevel = nestLevel
				checkToken = T_IF
				GOSUB NestWalk
				d1$ = "end.if." + HEX$(nestCount[checkLevel], 4) + "." + programName$
				Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i146")
		CASE T_SELECT
				checkLevel = nestLevel
				checkToken = T_SELECT
				GOSUB NestWalk
				d1$ = "end.select." + HEX$(nestCount[checkLevel], 4) + "." + programName$
				Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i147")
		CASE T_SUB
				IFZ insub THEN GOTO eeeNest
				IF (exitLevels != 1) THEN GOTO eeeSyntax
				d1$ = "end.sub" + hfn$ + "." + HEX$(subCount) + "." + programName$
				Code ($$jmp, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i148")
		CASE ELSE
				GOTO eeeSyntax
	END SELECT
	IF skipLevels THEN token = NextToken ()
	token = NextToken ()
	RETURN (token)


'	*****
' *****  Walk down "nest-stack" to find nth checkToken (IF, DO, FOR, SELECT)
'	*****

SUB NestWalk
	checkLevel = nestLevel
	DO WHILE checkLevel
		nestToken = nestToken[checkLevel] AND 0x1F00FFFF
		IF (nestToken = checkToken) THEN
			DEC exitLevels
			IFZ exitLevels THEN EXIT DO
		ENDIF
		DEC checkLevel
	LOOP
	IFZ checkLevel THEN GOTO eeeNest
END SUB


' *****  FOR  *****

p_for:
	got_executable = $$TRUE
	INC nestCount
	INC nestLevel
	nestVar[nestLevel]		= 0
	nestInfo[nestLevel]		= 0
	nestStep[nestLevel]		= 0
	nestLimit[nestLevel]	= 0
	nestToken[nestLevel]	= token
	nestLevel[nestLevel]	= nestLevel
	nestCount[nestLevel]	= nestCount
	forToken	= NextToken ()
	kind			= forToken{$$KIND}
	forVar		= forToken{$$NUMBER}
	forType		= TheType (forToken)
	IF (kind <> $$KIND_VARIABLES) THEN GOTO eeeSyntax
	IF (forType < $$SLONG) THEN forType = $$SLONG
	IF (forType > $$LONGDOUBLE) THEN GOTO eeeTypeMismatch
	IFZ m_addr$[forVar] THEN AssignAddress (forToken)  ' <---- changed from m_addr[forVal] 10 Nov 2005 - is this correct?
	IF XERROR THEN EXIT FUNCTION
	forReg		= r_addr[forVar]
	nestVar[nestLevel] = forToken

	check = PeekToken ()
	IF (check <> T_EQ) THEN GOTO eeeSyntax
	token = CheckState (forToken)
	IF XERROR THEN EXIT FUNCTION
	IF (token <> T_TO) THEN GOTO eeeSyntax
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	xr = Top ()
	IFZ xr THEN GOTO eeeSyntax
	Conv (xr, forType, xr, result_type)
	flname$	= ".forlimit" + HEX$(func_number) + "." + HEX$(nestCount, 4)
	fltoken	= $$T_VARIABLES + (forType << 16)
	fltoken	= AddSymbol (@flname$, fltoken, func_number)
	fl			= fltoken{$$NUMBER}
	IF m_addr$[fl] THEN PRINT "xxx10": GOTO eeeCompiler
	AssignAddress (fltoken)
	IF XERROR THEN EXIT FUNCTION
	limReg	= r_addr[fl]
	Move (fltoken, forType, xr, forType)
	nestLimit[nestLevel] = fltoken
	SELECT CASE xr
		CASE $$RA0:   a0 = 0: a0_type = 0: DEC toes
		CASE $$RA1:   a1 = 0: a1_type = 0: DEC toes
	END SELECT
	stepType = forType
	IF (token = T_STEP) THEN
		token = Eval (@result_type)
		IF XERROR THEN EXIT FUNCTION
		acc = Top ()
		IFZ acc THEN GOTO eeeSyntax
		def_step = $$FALSE
' The step-type must be signed to allow for negative step-values.
		IF stepType == $$ULONG THEN	stepType = $$SLONG
		IF stepType == $$USHORT THEN stepType = $$SSHORT
		IF stepType == $$UBYTE THEN stepType = $$SBYTE
		Conv (acc, stepType, acc, result_type)
		fsname$ = ".forstep" + HEX$(func_number) + "." + HEX$(nestCount, 4)
		fstoken = $$T_VARIABLES + (forType << 16)
		fstoken = AddSymbol (@fsname$, fstoken, func_number)
		fs = fstoken{$$NUMBER}
		IF m_addr$[fs] THEN PRINT "xxx11": GOTO eeeCompiler
		AssignAddress (fstoken)
		IF XERROR THEN EXIT FUNCTION
		stepReg	= r_addr[fs]
		IF (stepReg >= $$IMM16) THEN stepReg = 0
		Move (fstoken, forType, acc, forType)
		nestStep[nestLevel] = fstoken
		SELECT CASE acc
			CASE $$RA0:   a0 = 0: a0_type = 0: DEC toes
			CASE $$RA1:   a1 = 0: a1_type = 0: DEC toes
		END SELECT
	ELSE
		def_step = $$TRUE
		nestStep[nestLevel] = 0
	ENDIF
	nestInfo[nestLevel] = def_step

' setup of FOR variables complete... now do "test at top" code

	EmitLabel ("for." + HEX$(nestCount[nestLevel], 4) + "." + programName$)
	endfor$ = "end.for." + HEX$(nestCount[nestLevel], 4) + "." + programName$
	Move ($$RA0, forType, forVar, forType)
	Move ($$RA1, forType, fltoken, forType)
	IF (forType = $$ULONG) THEN jmp486 = $$ja ELSE jmp486 = $$jg

' compare forVar with limit and branch based on SIGN of step value

	IFZ def_step THEN
		d1$ = CreateLabel$ ()
		SELECT CASE forType
			CASE $$DOUBLE:			fakeType = $$GIANT	: treg = $$edi
' Note: There is a problem using this code with LONGDOUBLE, it does
' not check the sign of the LONGDOUBLE step value so using negative
' values for step will fail. So it will be necessary to rewrite
' code to use SIGN or %_sign.longdouble on the step value
			CASE $$LONGDOUBLE:	fakeType = $$XLONG	: treg = $$edi
			CASE $$SINGLE:			fakeType = $$XLONG	: treg = $$esi
			CASE $$GIANT:				fakeType = $$GIANT	: treg = $$edi
			CASE ELSE:					fakeType = $$XLONG	: treg = $$esi
		END SELECT
		Move ($$esi, fakeType, fstoken, fakeType)
	ENDIF
	SELECT CASE forType
		CASE  $$DOUBLE, $$SINGLE, $$LONGDOUBLE
					IFZ def_step THEN
						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, @"", @"	;;; i148a")
						Code ($$jns, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i148b")
						Code ($$fxch, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i148c")
						EmitLabel (@d1$)
					ENDIF
					Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i148d")
					Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i148e")
					Code ($$sahf, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i148f")
					Code ($$jb, $$rel, 0, 0, 0, 0, ">> " + endfor$, @"	;;; i148g")
		CASE $$GIANT
					IFZ def_step THEN
						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, @"", @"	;;; i148h")
						Code ($$jns, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i148i")
						Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i148j")
						Code ($$xchg, $$regreg, $$edx, $$ecx, 0, $$XLONG, @"", @"	;;; i148k")
						EmitLabel (@d1$)
					ENDIF
					Code ($$cmp, $$regreg, $$edx, $$ecx, 0, $$XLONG, @"", @"	;;; i149")
					Code ($$jg, $$rel, 0, 0, 0, 0, "> " + endfor$, @"	;;; i150")
					d1$ = CreateLabel$ ()
					Code ($$jnz, $$rel, 0, 0, 0, 0, "> " + d1$, @"")
					Code ($$cmp, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i151")
					Code ($$ja, $$rel, 0, 0, 0, 0, ">> " + endfor$, @"	;;; i152")
					EmitLabel (@d1$)

'		$$ULONG is no longer a special case when negative step values are	allowed.

'		CASE $$ULONG
''					IFZ def_step THEN
''						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, @"", @"")
''						Code ($$jns, $$rel, 0, 0, 0, 0, ">> " + d1$, @"")
''						Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"")
''						EmitLabel (@d1$)
'					ENDIF
'					Code ($$cmp, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i153")
'					Code (jmp486, $$rel, 0, 0, 0, 0, ">> " + endfor$, @"	;;; i154")
		CASE ELSE
					IFZ def_step THEN
						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, @"", @"")
						Code ($$jns, $$rel, 0, 0, 0, 0, "> " + d1$, @"")
						Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"")
						EmitLabel (@d1$)
					ENDIF
					Code ($$cmp, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i153")
					Code (jmp486, $$rel, 0, 0, 0, 0, ">> " + endfor$, @"	;;; i154")
	END SELECT
	a0_type = 0
	a1_type = 0
	RETURN (token)


' *****  FUNCTION  *****

' [C|S]FUNCTION [type.name] function.name ( [argument.list] ) [default.type]

p_xfunction:
	IF ina_function THEN GOTO eeeWithinFunction
	functionTypeChunk = 0
	EmitAsm (@".code")
	IFZ got_function THEN
		IFZ prologCode THEN
			SELECT CASE TRUE
				CASE library	:  Code ($$jmp, $$rel, 0, 0, 0, 0, "%_StartLibrary_" + programName$, @"	;;; i156")
				CASE ELSE			:  Code ($$jmp, $$rel, 0, 0, 0, 0, @"%_StartApplication", @"	;;; i157")
			END SELECT
			prologCode = $$TRUE
			EmitLabel ("PrologCode." + programName$)
			Code ($$ret, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i158 ;;; end prolog code")
		ELSE
'			Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, @"", @"	;;; i159")		' end of PrologCode
'			Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i160")
			EmitAsm ("	leave	;;; i160a")
			Code ($$ret, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i161 ;;; end prolog code")
		ENDIF

	ENDIF
	insub = 0
	insub$ = ""
	subCount = 0
	nestLevel = 0
	nestError = $$FALSE
	got_function = $$TRUE
	token = NextToken ()
	tn = TypenameToken (@token)
	IFZ tn THEN tn = token{$$TYPE}
	IF (tn < $$SLONG) THEN tn = $$XLONG
	ft = TheType (token)
	IF (tn <> ft) THEN GOTO eeeTypeMismatch

	kind = token{$$KIND}
	IF (kind != $$KIND_FUNCTIONS) THEN GOTO eeeSyntax
	IFZ (token AND $$MASK_DECLARED) THEN GOTO eeeUndeclared
	IF (token AND $$MASK_DEFINED) THEN GOTO eeeDupDefinition
	ina_function	= token
	func_number		= token{$$NUMBER}
	funcScope			= funcScope[func_number]
	IF (funcKind != funcKind[func_number]) THEN GOTO eeeCrossedFunctions
	SELECT CASE funcScope
		CASE $$FUNC_DECLARE
		CASE $$FUNC_INTERNAL
		CASE $$FUNC_EXTERNAL:	GOTO eeeInternalExternal
		CASE ELSE:						PRINT "funcScope":	GOTO eeeCompiler
	END SELECT
	funcToken								= token OR $$MASK_DEFINED
	funcToken[func_number]	= funcToken
	autoxAddr[func_number]	= 0x00
	inargAddr[func_number]	= 0x00
	autoAddr[func_number]		= 0x00
	hfn$										= HEX$(func_number)
	f$											= "func" + hfn$ + "." + programName$
	compositeArg						= 0
	crvtoken								= 0

	IF (func_number = entryFunction) THEN
		SELECT CASE TRUE
			CASE library	: EmitLabel ("%_StartLibrary_" + programName$)
			CASE ELSE			: EmitLabel (@"%_StartApplication")
		END SELECT

' In case entry function takes arguments

'		IFZ xit THEN
			atsign = RINSTR(funcLabel$[func_number], "@")
			IF atsign THEN
				bytes = XLONG(MID$(funcLabel$[func_number],atsign+1))
				IF bytes THEN
					IF (bytes AND 0x0003) THEN GOTO eeeCompiler			' must be mod 4
					pushes = (bytes >> 2)
					Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; i162a")
					FOR i = 1 TO pushes
						Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i162b")
					NEXT i
				ENDIF
			ENDIF
'		ENDIF
		Code ($$call, $$rel, 0, 0, 0, 0, @f$, @"	;;; i162c")
		Code ($$ret, $$imm, 0, 0, 0, $$XLONG, @"", @"	;;; i162d")

	ENDIF

'	errorToken	= $$T_VARIABLES OR ($$AUTOX << 21)
'	errorToken	= AddSymbol (@"$XERROR", errorToken, func_number)
'	errorToken	= errorToken OR ($$AUTOX << 21)
'	AssignAddress (errorToken)

	IF (ft >= $$SCOMPLEX) THEN
		crvname$	= ".compositeReturnValue"
		crvtoken	= $$T_VARIABLES OR ($$AUTOX << 21)
		crvtoken	= AddSymbol (@crvname$, crvtoken, func_number)
		crvtoken	= crvtoken OR ($$AUTOX << 21)
		crvnum		= crvtoken{$$NUMBER}
		IF m_addr[crvnum] THEN PRINT "comRetVal": GOTO eeeCompiler
		tab_sym[crvnum] = crvtoken
		tabType[crvnum] = ft
		AssignAddress (crvtoken)
		IF XERROR THEN EXIT FUNCTION
	ENDIF

	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax

	arg_count			= 0
	argNum				= 1
	token					= PeekToken ()
	paramCount		= funcArg[func_number, 0] {$$BYTE2}
	IF (token = T_RPAREN) THEN
		token	= NextToken ()
		IF paramCount THEN GOTO eeeTooFewArgs
	ELSE
		anyArg		= $$FALSE
		anyOpen		= $$FALSE
		DO
			token = NextToken ()
			SELECT CASE token
				CASE T_ATSIGN:	token = NextToken ()	' ignore @ prefix
				CASE T_LPAREN:	IF anyOpen THEN GOTO eeeSyntax
												token = NextToken ()
												anyOpen = $$TRUE
			END SELECT
			temp_type = TypenameToken (@token)
			IF (temp_type = $$ETC) THEN GOTO eeeSyntax
			kind = token{$$KIND}
			SELECT CASE kind
				CASE $$KIND_VARIABLES
				CASE $$KIND_ARRAYS:			tt = NextToken ()
																IF (tt != T_LBRAK) THEN	GOTO eeeSyntax
																tt = NextToken ()
																IF (tt != T_RBRAK) THEN	GOTO eeeSyntax
				CASE ELSE:							GOTO eeeSyntax
			END SELECT
			tt = token{$$NUMBER}
			token_type	= token{$$TYPE}
			IF token_type THEN
				IF (temp_type AND (token_type <> temp_type)) THEN GOTO eeeTypeMismatch
				temp_type = token_type
			ELSE
				IFZ temp_type THEN temp_type = $$XLONG
			ENDIF
			token = token OR ($$ARGUMENT << 21)
			tabType[tt] = temp_type
			UpdateToken (token)
			IF (arg_count >= paramCount) THEN GOTO eeeTooManyArgs
			funcArg			= funcArg[func_number, argNum]
			p_type			= funcArg {$$WORD0}
			p_kind			= funcArg {$$KIND}
			IF (p_type = $$ANY) THEN
				SELECT CASE p_kind
					CASE $$KIND_ARRAYS
								IF (kind = $$KIND_VARIABLES) THEN GOTO eeeKindMismatch
					CASE $$KIND_VARIABLES
								IF (kind = $$KIND_VARIABLES) THEN
									IF ((temp_type = $$GIANT) OR (temp_type = $$DOUBLE) OR (temp_type = $$LONGDOUBLE)) THEN
'											IF (arg_count < (paramCount-1)) THEN GOTO eeeTypeMismatch
										GOTO eeeTypeMismatch
									ENDIF
								ENDIF
				END SELECT
				IF anyArg THEN
					tt					= token{$$NUMBER}
					m_addr$[tt]	= m_addr$[anyArgNum]
					r_addr$[tt]	= r_addr$[anyArgNum]
					m_addr[tt]	= m_addr[anyArgNum]
					r_addr[tt]	= r_addr[anyArgNum]
					m_reg[tt]		= m_reg[anyArgNum]
				ELSE
					AssignAddress (token)
					IF XERROR THEN EXIT FUNCTION
					anyArg			= tab_sym[token{$$NUMBER}]
					anyArgNum		= anyArg{$$NUMBER}
				ENDIF
				token				= NextToken ()
				IF anyOpen THEN
					IF (token != T_RPAREN) THEN DO LOOP
					token			= NextToken ()
				ENDIF
				anyOpen			= $$FALSE
				anyArg			= $$FALSE
				anyArgNum		= $$FALSE
				INC argNum
				INC arg_count
				DO LOOP
			ELSE
				IF anyOpen THEN GOTO eeeSyntax
				IF (kind != p_kind) THEN GOTO eeeKindMismatch
				IF (temp_type != p_type) THEN GOTO eeeTypeMismatch
			ENDIF
			INC argNum
			INC arg_count
			AssignAddress (token)
			IF XERROR THEN EXIT FUNCTION
			token = NextToken()
		LOOP WHILE (token = T_COMMA)
		IF (token != T_RPAREN) THEN GOTO eeeSyntax
	ENDIF
	IF (arg_count < paramCount) THEN GOTO eeeTooFewArgs

' check for optional default.type field

	token		= NextToken ()
	fdtype	= TypenameToken (@token)
	IFZ fdtype THEN fdtype = $$XLONG
	defaultType[func_number] = fdtype

' Put branch to function entry point instruction, then "funcBody" label

	EmitFunctionLabel (funcLabel$[func_number])

' #####  v0.0313  #####
' The following section of code was added so the beginning part of
' the function could be emitted here rather than after the function.

	#emitasm = 2								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"
	 							' flush all assembly language output from the asm buffer
	#emitasm = 1								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"

	EmitLabel ("funcBody" + HEX$(func_number) + "." + programName$)
	RETURN (token)

' *****  GOSUB  *****

p_gosub:
	got_executable = $$TRUE
	code_l  = $$call
	code_v  = $$call
	gsub		= $$TRUE
	GOTO p_gox


' ****  GOTO  *****

p_goto:
	got_executable = $$TRUE
	code_l  = $$jmp
	code_v  = $$jmp
	gsub		= $$FALSE

p_gox:
	computed = $$FALSE
	token = NextToken ()
	IF (token = T_ATSIGN) THEN computed = $$TRUE: token = NextToken ()
	go_type = TheType (token)
	tt		= token{$$NUMBER}
	kind	= token{$$KIND}
	SELECT CASE kind
		CASE $$KIND_LABELS:			GOTO p_goto_label
		CASE $$KIND_VARIABLES:  GOTO p_goto_expression
		CASE $$KIND_ARRAYS:     GOTO p_goto_expression
		CASE ELSE:              GOTO eeeTypeMismatch
	END SELECT


p_goto_label:
	IF computed THEN GOTO eeeTypeMismatch
	GOSUB CheckGoType
	tt$ = tab_lab$[tt]
	Code (code_l, $$rel, 0, 0, 0, 0, @tt$, @"	;;; i163")
	token = NextToken ()
	RETURN (token)

p_goto_expression:
	IFZ computed THEN GOTO eeeTypeMismatch
	DEC tokenPtr
	token = Eval (@go_type)
	IF XERROR THEN EXIT FUNCTION
	GOSUB CheckGoType
	acc = Topax1 ()
	IFZ acc THEN GOTO eeeSyntax
	d1$ = CreateLabel$ ()
	Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i164")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i165")
	Code (code_v, $$reg, acc, 0, 0, 0, @"", @"	;;; i166")
	EmitLabel (@d1$)
	RETURN (token)


SUB CheckGoType
	IF gsub THEN
		IF (go_type <> $$SUBADDR) THEN GOTO eeeBadGosub
	ELSE
		IF (go_type <> $$GOADDR) THEN GOTO eeeBadGoto
	ENDIF
END SUB

' *****  IF  and IFT  *****  IF TRUE  (non-zero)
' *****  IFF and IFZ  *****  IF FALSE   (zero)

p_ifx:
	got_executable = $$TRUE
	IF ifLine THEN GOTO eeeNest
	ifLine = $$TRUE
	INC nestCount
	INC nestLevel
	nestLevel[nestLevel] = nestLevel
	nestCount[nestLevel] = nestCount
	nestToken[nestLevel] = T_IF
	nestInfo[nestLevel] = 0
	where$ = "else." + HEX$(nestCount[nestLevel], 4) + "." + programName$
	GOSUB Tester
	IF ifc THEN
		GOSUB TestTrue
	ELSE
		GOSUB TestFalse
	ENDIF
p_if_q_then_part:
	SELECT CASE (token AND 0x1F00FFFF)
		CASE T_REM:             checkState = token:		RETURN (checkState)
		CASE $$T_STARTS:        checkState = token:		RETURN (checkState)
		CASE T_THEN, T_COMMA:   token = NextToken ():	GOTO p_if_q_then_part
		CASE T_SEMI, T_COLON:   token = NextToken ():	GOTO p_if_q_then_part
	END SELECT
p_if_then:
	token = CheckState (token)
	IF XERROR THEN EXIT FUNCTION
	kind = token{$$KIND}
	IF token = T_COLON THEN token = NextToken ():  GOTO p_if_then
	SELECT CASE kind
		CASE $$KIND_TERMINATORS:  GOTO p_end_if_line
		CASE $$KIND_COMMENTS:     GOTO p_end_if_line
		CASE $$KIND_STARTS:       GOTO p_end_if_line
	END SELECT
	SELECT CASE token
		CASE T_IF:                            GOTO eeeNest
		CASE T_END:   token = NextToken ():   GOTO p_q_end_if_line
		CASE ELSE:                            GOTO p_if_then
	END SELECT
p_q_end_if_line:
	IF (token <> T_IF) THEN GOTO eeeNest
p_end_if_line:
	IFZ nestInfo[nestLevel] THEN
		EmitLabel ("else." + HEX$(nestCount[nestLevel], 4) + "." + programName$)
	ENDIF
	EmitLabel ("end.if." + HEX$(nestCount[nestLevel], 4) + "." + programName$)
	nestInfo[nestLevel] = 0
	DEC nestLevel
	token = NextToken ()
	RETURN (token)


' *****  GENERIC test for true/false and branch to specified label  *****
'        Used by CASE, DO, IF, LOOP  (works on strings and null arrays)
'        NOTE:  True and False routines CANNOT be consolidated.  Don't try!

SUB Tester
	new_test = $$TRUE: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	nn = new_data{$$NUMBER}
	token = new_op
	rn = Reg (nn)
	IF new_data THEN
		SELECT CASE TRUE
			CASE (rn AND (rn < $$IMM16))
				mode		= $$regreg
				acc			= rn
				accx		= rn + 1
			CASE ELSE
				mode		= $$regreg
				acc			= $$eax
				accx		= $$edx
				Move ($$eax, new_type, new_data, new_type)
				a0			= 0
				a0_type	= 0
		END SELECT
	ELSE
		mode	= $$regreg
		acc		= Topax1 ()
		accx	= acc + 1
		IFZ acc THEN GOTO eeeSyntax
		IF (acc != $$eax) THEN PRINT "acc != eax": GOTO eeeCompiler
		expression = $$TRUE
	ENDIF
END SUB

' **************************
' *****  SUB TestTrue  *****  (Use after SUB Tester)
' **************************

SUB TestTrue
	SELECT CASE new_type
		CASE $$GIANT:		GOTO TrueGiant
		CASE $$DOUBLE:	GOTO TrueDouble
		CASE $$SINGLE:	GOTO TrueSingle
		CASE $$STRING:	GOTO TrueString
		CASE ELSE:			GOTO TrueOthers
	END SELECT

TrueGiant:
	Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, @"", @"	;;; i170")
	Code ($$or, $$regreg, $$esi, accx, 0, $$XLONG, @"", @"	;;; i171")
	Code ($$jnz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i172")
	EXIT SUB

TrueDouble:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, @"", @"")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i173")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i174")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i175")
	Code ($$jnz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i176")
	EXIT SUB

TrueSingle:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, @"", @"")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i173")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i178")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i179")
	Code ($$jnz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i180")
	EXIT SUB

TrueString:
	d1$ = CreateLabel$ ()
	IF (oos[oos] = 's') THEN
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i181")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i182")
		Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, @"", @"	;;; i183")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, @"", @"	;;; i184")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i185")
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i186")
		Code ($$jnz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i187")
	ELSE
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i188")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i189")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, @"", @"	;;; i190")
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i191")
		Code ($$jnz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i192")
	ENDIF
	EmitLabel (@d1$)
	DEC oos
	EXIT SUB

TrueOthers:
	IF new_test THEN
		GOSUB ConvCondBitTrue
		Code (jmp486, $$rel, 0, 0, 0, 0, @where$, @"	;;; i193")
	ELSE
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i194")
		Code ($$jnz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i195")
	ENDIF
END SUB

' ***************************
' *****  SUB TestFalse  *****  (Use after SUB Tester)
' ***************************

SUB TestFalse
	SELECT CASE new_type
		CASE $$GIANT:		GOTO FalseGiant
		CASE $$DOUBLE:	GOTO FalseDouble
		CASE $$SINGLE:	GOTO FalseSingle
		CASE $$STRING:	GOTO FalseString
		CASE ELSE:			GOTO FalseOthers
	END SELECT

FalseGiant:
	Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, @"" , @"	;;; i196")
	Code ($$or, $$regreg, $$esi, accx, 0, $$XLONG, @"", @"	;;; i197")
	Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i198")
	EXIT SUB

FalseDouble:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, @"", @"")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i173")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i200")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i201")
	Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i202")
	EXIT SUB

FalseSingle:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, @"", @"")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i173")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i204")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, @"", @"	;;; i205")
	Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i206")
	EXIT SUB

FalseString:
	IF (oos[oos] = 's') THEN
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"" , @"	;;; i207")
		Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i208")
		Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, @"", @"	;;; i209")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, @"", @"	;;; i210")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i211")
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i212")
		Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i213")
	ELSE
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"" , @"	;;; i214")
		Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i215")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, @"", @"	;;; i216")
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i217")
		Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i218")
	ENDIF
	DEC oos
	EXIT SUB

FalseOthers:
	IF new_test THEN
		GOSUB ConvCondBitFalse
		Code (jmp486, $$rel, 0, 0, 0, 0, @where$, @"	;;; i219")
	ELSE
		Code ($$test, $$regreg, acc, acc, 0, $$XLONG, @"", @"	;;; i220")
		Code ($$jz, $$rel, 0, 0, 0, 0, @where$, @"	;;; i221")
	ENDIF
END SUB


' *****  ConvCondBitTrue  *****

' Sets jmp486 to 80386 conditional jump opcode that corresponds to
' the 88000 condition bit in new_test being true.

SUB ConvCondBitTrue
	SELECT CASE new_test
		CASE 2:			jmp486 = $$je
		CASE 3: 		jmp486 = $$jne
		CASE 4:			jmp486 = $$jg
		CASE 5:			jmp486 = $$jle
		CASE 6:			jmp486 = $$jl
		CASE 7:			jmp486 = $$jge
		CASE 8:			jmp486 = $$ja
		CASE 9:			jmp486 = $$jbe
		CASE 10:		jmp486 = $$jb
		CASE 11:		jmp486 = $$jae
		CASE ELSE:	jmp486 = -1
	END SELECT
END SUB

' *****  ConvCondBitFalse  *****

' Sets jmp486$ to 80386 conditional jump mnemonic that corresponds to
' the 88000 condition bit in new_test being false.

SUB ConvCondBitFalse
	SELECT CASE new_test
		CASE 2:			jmp486 = $$jne
		CASE 3: 		jmp486 = $$je
		CASE 4:			jmp486 = $$jle
		CASE 5:			jmp486 = $$jg
		CASE 6:			jmp486 = $$jge
		CASE 7:			jmp486 = $$jl
		CASE 8:			jmp486 = $$jbe
		CASE 9:			jmp486 = $$ja
		CASE 10:		jmp486 = $$jae
		CASE 11:		jmp486 = $$jb
		CASE ELSE:	jmp486 = -1
	END SELECT
END SUB


' *****  LOOP  *****

p_loop:
	got_executable = $$TRUE
	IF (nestLevel < 0) THEN nestLevel = 0 : GOTO eeeNest
	IF (nestToken[nestLevel] <> T_DO) THEN GOTO eeeNest
	IF (nestLevel[nestLevel] <> nestLevel) THEN GOTO eeeNest
	token = NextToken ()
	EmitLabel ("do.loop." + HEX$(nestCount[nestLevel], 4)  + "." + programName$)
	IF (token = T_WHILE) THEN ifc = $$TRUE:  GOTO loopx
	IF (token = T_UNTIL) THEN ifc = $$FALSE: GOTO loopx
	Code ($$jmp, $$rel, 0, 0, 0, 0, "do." + HEX$(nestCount[nestLevel], 4)  + "." + programName$, @"	;;; i222")
	GOTO finish_loop
loopx:
	where$ = "do." + HEX$(nestCount[nestLevel], 4)  + "." + programName$
	GOSUB Tester
	IF ifc THEN
		GOSUB TestTrue
	ELSE
		GOSUB TestFalse
	ENDIF
finish_loop:
	EmitLabel ("end.do." + HEX$(nestCount[nestLevel], 4)  + "." + programName$)
	DEC nestLevel
	RETURN (token)


' *****  NEXT  *****

p_next:
	got_executable = $$TRUE
	check	= PeekToken ()
	IF (check = T_CASE) THEN token = NextToken (): GOTO p_next_case
	IF (nestLevel < 0) THEN nestLevel = 0 : GOTO eeeNest
	IF (nestToken[nestLevel] <> T_FOR) THEN GOTO eeeNest
	IF (nestLevel[nestLevel] <> nestLevel) THEN GOTO eeeNest
	token = NextToken ()
	kind	= token{$$KIND}
	IF (kind = $$KIND_VARIABLES) THEN
		IF (token <> nestVar[nestLevel]) THEN GOTO eeeNest
		token = NextToken ()
	ENDIF
	forToken	= nestVar[nestLevel]
	forType		= TheType (forToken)
	forStep		= nestStep[nestLevel]
	forLimit	= nestLimit[nestLevel]
	def_step	= nestInfo[nestLevel]
	IF (forType < $$SLONG) THEN forType = $$SLONG
	forVar		= forToken{$$NUMBER}
	forReg		= r_addr[forVar]
	nativeReg	= forReg
	stepVar		= forStep{$$NUMBER}
	stepReg		= r_addr[stepVar]
	EmitLabel ("do.next." + HEX$(nestCount[nestLevel], 4)  + "." + programName$)
	fortop$		= "for." + HEX$(nestCount[nestLevel], 4)  + "." + programName$
	d1$ = CreateLabel$ ()

	IF def_step THEN
		SELECT CASE forType
			CASE $$DOUBLE, $$SINGLE, $$LONGDOUBLE
						Move ($$eax, forType, forVar, forType)
						Code ($$fld1, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i223")
						Code ($$fadd, $$none, 0, 0, 0,  $$DOUBLE, @"", @"	;;; i224")
						Move (forVar, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"	;;; i225")
			CASE $$GIANT
						Move ($$eax, forType, forVar, forType)
						Code ($$add, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i226")
						Code ($$adc, $$regimm, $$edx, 0, 0, $$XLONG, @"", @"	;;; i227")
						Move (forVar, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, @fortop$, @"	;;; i228")
			CASE ELSE
						mReg	= m_reg[forVar]
						mAddr	= m_addr[forVar]
						IF mReg THEN
							Code ($$inc, $$ro, 0, mReg, mAddr, $$XLONG, @"", @"	;;; i229")
						ELSE
							Code ($$inc, $$abs, 0, 0, mAddr, $$XLONG, m_addr$[forVar], @"	;;; i230")
						ENDIF
						Code ($$jmp, $$rel, 0, 0, 0, 0, @fortop$, @"	;;; i231")
		END SELECT
	ELSE
		Move ($$eax, forType, forVar, forType)
		Move ($$ebx, forType, stepVar, forType)
		SELECT CASE forType
			CASE $$DOUBLE, $$SINGLE, $$LONGDOUBLE
						Code ($$fadd, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i232")
						Move (forToken, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, @fortop$, @"	;;; i233")
			CASE $$GIANT
						Code ($$add, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i234")
						Code ($$adc, $$regreg, $$edx, $$ecx, 0, $$XLONG, @"", @"	;;; i235")
						Move (forToken, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, @fortop$, @"	;;; i236")

'			Check for overflow is invalid when negative step-values are allowed!

'		CASE $$ULONG
'						Code ($$add, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i237a")
'						Code ($$jnc, $$rel, 0, 0, 0, 0, ">> " + d1$, @"	;;; i237b")
'						Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i237c")
'						EmitLabel (@d1$)
'						Move (forToken, forType, $$eax, forType)
'						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"	;;; i237d")
			CASE ELSE
						Code ($$add, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i238a")
						Move (forToken, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, @fortop$, @"	;;; i238b")
		END SELECT
	ENDIF
	a0 = 0:	a0_type = 0: a1 = 0: a1_type = 0
	EmitLabel ("end.for." + HEX$(nestCount[nestLevel], 4) + "." + programName$)
	DEC nestLevel
	RETURN (token)


' *****  PRINT  *****

p_print:
	got_executable = $$TRUE
	token = Printoid()
	RETURN (token)


' *****  READ  *****

p_read:
	got_executable = $$TRUE
	token = NextToken ()
	IF (token != T_LBRAK) THEN GOTO eeeSyntax				' READ [ifile], var
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (token != T_RBRAK) THEN GOTO eeeSyntax
	token = NextToken ()
	IF (token != T_COMMA) THEN GOTO eeeSyntax
	IFF q_type_long[result_type] THEN GOTO eeeTypeMismatch
	IFZ toes THEN GOTO eeeSyntax

	xx = Topax1 ()
	symbol$ = ".filenumber"
	ftoken = $$T_VARIABLES + ($$AUTOX << 21) + ($$XLONG << 16)
	ftoken = AddSymbol (@symbol$, ftoken, func_number)
	fnum = ftoken{$$NUMBER}
	IFZ m_addr$[fnum] THEN AssignAddress (ftoken)
	IF XERROR THEN EXIT FUNCTION
	Move (ftoken, $$XLONG, xx, $$XLONG)

' READ the variables

	DO
		rtoken	= PeekToken ()
		kind		= rtoken{$$KIND}
		rt			= rtoken{$$NUMBER}
		SELECT CASE kind
			CASE $$KIND_VARIABLES:	array = $$FALSE
			CASE $$KIND_ARRAYS:			array = $$TRUE
															token = NextToken ()
															token = NextToken ()
															IF (token != T_LBRAK) THEN GOTO eeeCompiler
															token = NextToken ()
															IF (token != T_RBRAK) THEN GOTO eeeSyntax
			CASE ELSE:							token = NextToken (): GOTO eeeKindMismatch
		END SELECT
		IFZ m_addr$[rt] THEN AssignAddress (rtoken)
		IF XERROR THEN EXIT FUNCTION
		rtype		= TheType (rtoken)
		IF (array OR (rtype < $$SCOMPLEX)) THEN
			IF (array OR (rtype = $$STRING)) THEN
				IF array THEN
					r$ = "%_ReadArray"
				ELSE
					r$ = "%_ReadString"
				ENDIF
				token			= NextToken ()
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i239")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i240")
				Move ($$eax, $$XLONG, rtoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, @"", @"	;;; i241")
				Code ($$call, $$rel, 0, 0, 0, 0, @r$, @"	;;; i242")
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i243")
			ELSE
				SELECT CASE rtype
					CASE $$SINGLE:	rtype = $$XLONG
					CASE $$DOUBLE:	rtype = $$GIANT
				END SELECT
				xsize		= typeSize[rtype]
				size$		= HEXX$(xsize, 4)
				token		= NextToken ()
				mReg		= m_reg[rt]
				mAddr		= m_addr[rt]
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i244")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i245a")
				Code ($$st, $$roreg, $$esp, $$esp, 4, $$XLONG, @"", @"	;;; i246")
				Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, @"", @"	;;; i247")
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_Read", @"	;;; i248")
				Code ($$ld, $$regro, $$eax, $$esp, 0, rtype, @"", @"	;;; i249a")
				IF (rtype < $$SLONG) THEN rtype = $$SLONG
				IF mReg THEN
					Code ($$st, $$roreg, $$eax, mReg, mAddr, rtype, @"", @"	;;; i249b")
				ELSE
					Code ($$st, $$absreg, $$eax, 0, mAddr, rtype, m_addr$[rt], @"	;;; i249c")
				ENDIF
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i250")
			ENDIF
		ELSE
			Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i251")
			Move ($$eax, $$XLONG, ftoken, $$XLONG)
			Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i252")
			ctype		= rtype
			creg		= NextToken ()
			Composite ($$GETDATAADDR, ctype, @creg, @offset, @xsize)
			IF XERROR THEN EXIT FUNCTION
			IF toes THEN Topax1 ()
			IFZ creg THEN PRINT "READcomposite": GOTO eeeCompiler
			IF offset THEN Code ($$add, $$regimm, creg, offset, 0, $$XLONG, @"", @"	;;; i253")
			Code ($$st, $$roreg, creg, $$esp, 4, $$XLONG, @"", @"	;;; i254")
			Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, @"", @"	;;; i255")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_Read", @"	;;; i256")
			Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i257")
		ENDIF
		a0_type	= 0
		token		= NextToken ()
	LOOP WHILE (token = T_COMMA)
	RETURN (token)


' *****  RETURN  *****

p_return:
	got_executable = $$TRUE
	token = ReturnValue (@rt)
	IF XERROR THEN EXIT FUNCTION
	Code ($$jmp, $$rel, 0, 0, 0, 0, "end.func" + HEX$(func_number) + "." + programName$, @"	;;; i258")
	RETURN (token)


' *****  SELECT  *****  SELECT CASE

p_select:
	got_executable = $$TRUE
	tf			= $$FALSE
	s_token	= token
	token		= NextToken ()
	IF (token <> T_CASE) THEN GOTO eeeSyntax

allx:
	stp			= tokenPtr
	token		= NextToken ()
	SELECT CASE token
		CASE T_ALL
					s_token			= s_token OR 0x800000
					GOTO allx
		CASE T_TRUE
					s_token			= s_token OR 0x400000
					token				= NextToken ()
					expression	= $$FALSE
					tf					= $$TRUE
		CASE T_FALSE
					s_token			= s_token OR 0x200000
					token				= NextToken ()
					expression	= $$FALSE
					tf					= $$TRUE
		CASE ELSE
					expression	= $$TRUE
					tokenPtr		= stp
	END SELECT
	INC nestCount
	INC nestLevel
	nestLevel[nestLevel] = nestLevel
	nestCount[nestLevel] = nestCount
	nestToken[nestLevel] = s_token
	nestInfo[nestLevel] = 0
	IF tf THEN new_type = $$XLONG: GOTO select_xx
	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	expression	= $$TRUE
	token				= new_op
	nn					= new_data{$$NUMBER}
	rn					= Reg (nn)
	IF new_data THEN
		IF rn AND (rn < $$IMM16) THEN
			acc = rn
		ELSE
			acc = $$eax
			Move ($$eax, new_type, new_data, new_type)
			a0			= 0
			a0_type = 0
		ENDIF
	ELSE
		acc = Topax1 ()
		IFZ acc THEN GOTO eeeSyntax
		IF (acc != $$eax) THEN PRINT "acc <> eax": GOTO eeeCompiler
	ENDIF
	IF (new_type = $$STRING) THEN
		s_token = s_token OR 0x100000
		nestToken[nestLevel] = s_token
		IF (oos[oos] = 'v') THEN
'			Move ($$RA0, new_type, new_data, new_type)
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0" , @"	;;; i259")
			acc			= $$RA0
			a0			= 0
			a0_type	= 0
		ENDIF
		DEC oos
	ENDIF

select_xx:
	IFF tf THEN
		sname$ = ".select" + HEX$(func_number) + "." + HEX$(nestCount, 4)
		stoken = $$T_VARIABLES OR (new_type << 16)
		stoken = AddSymbol (@sname$, stoken, func_number)
		ss = stoken{$$NUMBER}
		' Hack! It is possible that the symbol .selectXXX already exists (from
		' a previous incarnation of the function) with another type! In that case
		' AddSymbol returns that symbol, with the wrong type; so we have to correct
		' the type of the symbol!
		stoken = CLR(stoken, $$TYPE)
		stoken = stoken OR (new_type << 16)
		tab_sym[ss] = stoken
		tabType[ss] = new_type

		AssignAddress (stoken)
		IF XERROR THEN EXIT FUNCTION
		IF (new_type = $$STRING) THEN
			Move ($$esi, new_type, stoken, new_type)
			Move (stoken, new_type, acc, new_type)
			Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i260")
		ELSE
			Move (stoken, new_type, acc, new_type)
		ENDIF
		nestVar[nestLevel] = stoken
	ELSE
		nestVar[nestLevel] = new_type << 16
	ENDIF
	RETURN (token)


' *****  STOP  *****

p_stop:
	got_executable = $$TRUE
	Code ($$int, $$imm, 3, 0, 0, $$XLONG, @"", @"	;;; i261")
	checkState = NextToken ()
	RETURN (checkState)


' *****  SUB subname  *****

p_sub:
	got_executable = $$TRUE
	IF (insub OR nestLevel) THEN insub = 0 : nestLevel = 0 : GOTO eeeNest
	token = NextToken ()
	kind	= token{$$KIND}
	gtype	= token{$$TYPE}
	IF (kind <> $$KIND_LABELS) THEN GOTO eeeSyntax
	IF (gtype <> $$SUBADDR) THEN GOTO eeeTypeMismatch
	symbol$ = "out.sub" + hfn$ + "." + HEX$(subCount) + "." + programName$
	Code ($$jmp, $$rel, 0, 0, 0, 0, @symbol$, @"	;;; i262")
	EmitUserLabel (token)
	IF XERROR THEN EXIT FUNCTION
	insub  = $$TRUE
	sname$ = ".sub" + HEX$(func_number) + "." + HEX$(subCount, 4)
	stoken = $$T_VARIABLES OR ($$SUBADDR << 16)
	stoken = AddSymbol (@sname$, stoken, func_number)
	ss = stoken{$$NUMBER}
	IF m_addr$[ss] THEN PRINT "xxx15": GOTO eeeCompiler
	AssignAddress (stoken)
	IF XERROR THEN EXIT FUNCTION
	subToken[subCount] = stoken
	token = NextToken ()
	RETURN (token)


' *****  SWAP  *****

p_swap:
	attachoid		= $$FALSE
	GOTO p_swapper

p_swapper:
	dtoken = NextToken ()
	dholdPtr = tokenPtr
	IFZ GetTokenOrAddress (@dtoken, @dstyle, @termToken, @dtype, @dntype, @dbase, @doffset, @dlength) THEN PRINT "eeeS39" : GOTO eeeSyntax
	IFZ dstyle THEN tokenPtr = dholdPtr: PRINT "eeeS38" : GOTO eeeSyntax
	IF attachoid THEN
		IF (termToken != T_TO) THEN PRINT "eeeS37" : GOTO eeeSyntax
	ELSE
		IF (termToken != T_COMMA) THEN PRINT "eeeS36" : GOTO eeeSyntax
	ENDIF
	stoken = NextToken ()
	sholdPtr = tokenPtr
	IFZ GetTokenOrAddress (@stoken, @sstyle, @termToken, @stype, @sntype, @sbase, @soffset, @slength) THEN PRINT "eeeS35" : GOTO eeeSyntax
	IFZ sstyle THEN tokenPtr = sholdPtr: PRINT "eeeS34" : GOTO eeeSyntax

	SELECT CASE dtype
		CASE $$SINGLE	: dtype = $$XLONG
		CASE $$DOUBLE	: dtype = $$GIANT
	END SELECT

	SELECT CASE stype
		CASE $$SINGLE	: stype = $$XLONG
		CASE $$DOUBLE	: stype = $$GIANT
	END SELECT

	SELECT CASE dstyle
		CASE $$NONE					:	PRINT "eeeS33" : GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO varToken
		CASE $$ARRAY_TOKEN	:	GOTO arrayToken
		CASE $$ARRAY_NODE		:	GOTO arrayNode
		CASE $$DATA_ADDR		:	GOTO dataAddr
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT


' *****  dtoken = varToken  *****

varToken:
	IF attachoid THEN tokenPtr = dholdPtr: GOTO eeeSyntax
	SELECT CASE sstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO varTokenVarToken
		CASE $$ARRAY_TOKEN	:	GOTO eeeKindMismatch
		CASE $$ARRAY_NODE		:	GOTO eeeNodeDataMismatch
		CASE $$DATA_ADDR		:	GOTO varTokenDataAddr
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT

varTokenVarToken:
	IF (dtype < $$XLONG) THEN dtype = $$XLONG
	IF (stype < $$XLONG) THEN stype = $$XLONG
	IF (dtype != stype) THEN tokenPtr = sholdPtr: GOTO eeeTypeMismatch
	IF (dtype < $$SCOMPLEX) THEN
		Move ($$RA0, stype, stoken, stype)
		Move ($$RA1, dtype, dtoken, dtype)
		Move (dtoken, dtype, $$RA0, dtype)
		Move (stoken, stype, $$RA1, stype)
	ELSE
		Move ($$RA0, dtype, dtoken, dtype)
		Move ($$RA1, stype, stoken, stype)
		Code ($$push, $$imm, dlength, 0, 0, $$XLONG, @"", @"")
		Code ($$push, $$reg, $$RA1, 0, 0, $$XLONG, @"", @"")
		Code ($$push, $$reg, $$RA0, 0, 0, $$XLONG, @"", @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxSwapMemory@12", @"")
	ENDIF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)

varTokenDataAddr:
	sbase = Topax1 ()
	sdata = sbase + 1
	SELECT CASE sbase
		CASE $$RA0	: ddata = $$RA1
		CASE $$RA1	: ddata = $$RA0
		CASE ELSE		: GOTO eeeCompiler
	END SELECT
	IF (dtype != stype) THEN tokenPtr = sholdPtr: GOTO eeeTypeMismatch
	IF (dtype < $$SCOMPLEX) THEN
		SELECT CASE dtype
			CASE $$GIANT
						Move (ddata, dtype, dtoken, dtype)
						Code ($$ld, $$regro, $$R26, sbase, soffset, stype, @"", @"")
						Code ($$st, $$roreg, ddata, sbase, soffset, stype, @"", @"")
						Move (dtoken, dtype, $$R26, dtype)
			CASE ELSE
						Move (ddata, dtype, dtoken, dtype)
						Code ($$ld, $$regro, sdata, sbase, soffset, stype, @"", @"")
						Code ($$st, $$roreg, ddata, sbase, soffset, stype, @"", @"")
						Move (dtoken, dtype, sdata, dtype)
		END SELECT
	ELSE
    Code ($$push, $$imm, dlength, 0, 0, $$XLONG, @"", @"")
    Move (ddata, $$XLONG, dtoken, $$XLONG)
		Code ($$push, $$reg, ddata, 0, 0, $$XLONG, @"", @"")
    Code ($$lea, $$regro, sbase, sbase, soffset, stype, @"", @"")
		Code ($$push, $$reg, sbase, 0, 0, $$XLONG, @"", @"")
    Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxSwapMemory@12", @"")
	ENDIF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)


' *****  dtoken = arrayToken  *****

arrayToken:
	SELECT CASE sstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO eeeKindMismatch
		CASE $$ARRAY_TOKEN	:	GOTO arrayTokenArrayToken
		CASE $$ARRAY_NODE		:	GOTO arrayTokenArrayNode
		CASE $$DATA_ADDR		:	GOTO eeeNodeDataMismatch
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT

arrayTokenArrayToken:
	Move ($$RA0, $$XLONG, stoken, $$XLONG)
	IF attachoid THEN
		dx$ = CreateLabel$ ()
		Code ($$test, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + dx$, @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_NeedNullNode", @"")
		EmitLabel (@dx$)
	ENDIF
	Move (stoken, $$XLONG, dtoken, $$XLONG)
	Move (dtoken, $$XLONG, $$RA0, $$XLONG)
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)

arrayTokenArrayNode:
	Move ($$R26, $$XLONG, dtoken, $$XLONG)
	Code ($$ld, $$regro, $$R27, sbase, soffset, $$XLONG, @"", @"")
	IF attachoid THEN
		dx$ = CreateLabel$ ()
		Code ($$test, $$regreg, $$edi, $$edi, 0, $$XLONG, @"", @"")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + dx$, @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_NeedNullNode", @"")
		EmitLabel (@dx$)
	ENDIF
	Code ($$st, $$roreg, $$R26, sbase, soffset, $$XLONG, @"", @"")
	Move (dtoken, $$XLONG, $$R27, $$XLONG)
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)


' *****  dtoken = arrayNode  *****

arrayNode:
	SELECT CASE sstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO eeeKindMismatch
		CASE $$ARRAY_TOKEN	:	GOTO arrayNodeArrayToken
		CASE $$ARRAY_NODE		:	GOTO arrayNodeArrayNode
		CASE $$DATA_ADDR		:	GOTO eeeNodeDataMismatch
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT

arrayNodeArrayToken:
	Move ($$R26, $$XLONG, stoken, $$XLONG)
	Code ($$ld, $$regro, $$R27, dbase, doffset, $$XLONG, @"", @"")
	IF attachoid THEN
		dx$ = CreateLabel$ ()
		Code ($$test, $$regreg, $$esi, $$esi, 0, $$XLONG, @"", @"")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + dx$, @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_NeedNullNode", @"")
		EmitLabel (@dx$)
	ENDIF
	Code ($$st, $$roreg, $$R26, dbase, doffset, $$XLONG, @"", @"")
	Move (stoken, $$XLONG, $$R27, $$XLONG)
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)

arrayNodeArrayNode:
	Topax2 (@sbase, @dbase)
	Code ($$ld, $$regro, $$R26, sbase, soffset, $$XLONG, @"", @"")
	Code ($$ld, $$regro, $$R27, dbase, doffset, $$XLONG, @"", @"")
	IF attachoid THEN
		dx$ = CreateLabel$ ()
		Code ($$test, $$regreg, $$esi, $$esi, 0, $$XLONG, @"", @"")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + dx$, @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_NeedNullNode", @"")
		EmitLabel (@dx$)
	ENDIF
	Code ($$st, $$roreg, $$R26, dbase, doffset, $$XLONG, @"", @"")
	Code ($$st, $$roreg, $$R27, sbase, soffset, $$XLONG, @"", @"")
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)


' *****  dtoken = dataAddr  *****

dataAddr:
	IF (dtype != stype) THEN GOTO eeeTypeMismatch
	SELECT CASE sstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO dataAddrVarToken
		CASE $$ARRAY_TOKEN	:	GOTO eeeNodeDataMismatch
		CASE $$ARRAY_NODE		:	GOTO eeeNodeDataMismatch
		CASE $$DATA_ADDR		:	GOTO dataAddrDataAddr
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT

dataAddrVarToken:
	dbase = Topax1 ()
	dbasex = dbase + 1
	SELECT CASE dbase
		CASE $$RA0	: sdata = $$RA1 : sdatax = sdata + 1
		CASE $$RA1	: sdata = $$RA0 : sdatax = sdata + 1
		CASE ELSE		: GOTO eeeCompiler
	END SELECT
	IF (stype < $$SCOMPLEX) THEN
		SELECT CASE dtype
			CASE $$GIANT
						Move (sdata, stype, stoken, stype)
						Code ($$ld, $$regro, $$R26, dbase, doffset, dtype, @"", @"")
						Code ($$st, $$roreg, sdata, dbase, doffset, dtype, @"", @"")
						Move (stoken, stype, $$R26, stype)
			CASE ELSE
						Move (sdata, stype, stoken, stype)
						Code ($$ld, $$regro, sdatax, dbase, doffset, dtype, @"", @"")
						Code ($$st, $$roreg, sdata, dbase, doffset, dtype, @"", @"")
						Move (stoken, stype, sdatax, stype)
		END SELECT
	ELSE
    Code ($$push, $$imm, dlength, 0, 0, $$XLONG, @"", @"")
    Code ($$lea, $$regro, dbase, dbase, soffset, stype, @"", @"")
		Code ($$push, $$reg, dbase, 0, 0, $$XLONG, @"", @"")
    Move (dbase, $$XLONG, dtoken, $$XLONG)
		Code ($$push, $$reg, dbase, 0, 0, $$XLONG, @"", @"")
    Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxSwapMemory@12", @"")
	ENDIF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)

dataAddrDataAddr:
	Topax2(@sbase, @dbase)
	IF (stype < $$STRING) THEN
		SELECT CASE dtype
			CASE $$GIANT
						Code ($$lea, $$regro, $$R26, sbase, soffset, stype, @"", @"")
						Code ($$lea, $$regro, $$R27, dbase, doffset, dtype, @"", @"")
						Code ($$ld, $$regro, $$RA0, $$R26, 0, stype, @"", @"")
						Code ($$ld, $$regro, $$RA1, $$R27, 0, dtype, @"", @"")
						Code ($$st, $$roreg, $$RA0, $$R27, 0, dtype, @"", @"")
						Code ($$st, $$roreg, $$RA1, $$R26, 0, stype, @"", @"")
			CASE ELSE
						Code ($$ld, $$regro, sbase+1, sbase, soffset, stype, @"", @"")
						Code ($$ld, $$regro, dbase+1, dbase, doffset, dtype, @"", @"")
						Code ($$st, $$roreg, sbase+1, dbase, doffset, dtype, @"", @"")
						Code ($$st, $$roreg, dbase+1, sbase, soffset, stype, @"", @"")
		END SELECT
	ELSE
	IF (dlength != slength) THEN GOTO eeeTypeMismatch
    Code ($$push, $$imm, dlength, 0, 0, $$XLONG, @"", @"")
    Code ($$lea, $$regro, sbase, sbase, soffset, $$XLONG, @"", @"")
    Code ($$push, $$reg, sbase, 0, 0, $$XLONG, @"", @"")
    Code ($$lea, $$regro, dbase, dbase, doffset, $$XLONG, @"", @"")
    Code ($$push, $$reg, dbase, 0, 0, $$XLONG, @"", @"")
    Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxSwapMemory@12", @"")
	ENDIF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)


' *****  TYPE  *****  DECLARE USER-DEFINED TYPES
' *****  UNION  *****  DECLARE USER-DEFINED UNIONS

p_type:
	typeType = T_TYPE
	IF typeNumber THEN typeNumber = 0: PRINT "typeNumber0": GOTO eeeCompiler
	typeToken = NextToken ()
	typeKind = typeToken{$$KIND}
	typeNumber = typeToken{$$NUMBER}
	IF typeAlias[typeNumber] THEN typeNumber = 0: GOTO eeeDupType
	typeAlias[typeNumber] = typeNumber
	IF (typeKind != $$KIND_TYPES) THEN GOTO eeeSyntax
	IFZ typeNumber THEN PRINT "typeNumber1": GOTO eeeCompiler
	IF (typeToken != typeToken[typeNumber]) THEN PRINT "typoid": GOTO eeeCompiler
	token = NextToken ()

' *****  ALIAS TYPENAME SYNTAX  *****   TYPE typeName = typeName  (single line)

	IF (token = T_EQ) THEN
		token = NextToken ()
		atype = TypenameToken (@token)
		IFZ atype THEN GOTO eeeSyntax
		typeAlias[typeNumber] = atype
		typeAlign[typeNumber] = typeAlign[atype]
		typeNumber = 0
		RETURN ($$T_STARTS)
	ENDIF
	inTYPE = $$TRUE

' *****  TYPE DECLARATION SYNTAX  *****  (TYPE typeName...  END TYPE block)

	typeThisAddr = 0
	typeNextAddr = 0
	typeMaxAlign = 0
	typeMaxSize = 0
	eleCount = 0
	uEle = 3
	DIM tsymbol$[uEle]
	DIM ttoken[uEle]
	DIM tsize[uEle]
	DIM taddr[uEle]
	DIM ttype[uEle]
	DIM atype[uEle,]
	DIM tval[uEle]
	DIM tptr[uEle]
	DIM tss[uEle]
	DIM tub[uEle]
	got_type = $$TRUE
	RETURN ($$T_STARTS)


' *****  TYPE ELEMENT DECLARATIONS  *****

p_intype:
	SELECT CASE token
		CASE T_UNION	:	IFZ inTYPE THEN GOTO eeeSyntax
										IF inUNION THEN GOTO eeeNest
										eleCountUNION = eleCount
										addrUNION = typeNextAddr
										inUNION = $$TRUE
										RETURN ($$T_STARTS)
		CASE T_END		: GOTO p_end_type
	END SELECT
	eleStringSize = 0
	eleArrayUBound = 0
	fixedString = $$FALSE
	IF (token = T_STRING) THEN						' Fixed strings:  STRING*23  .s
		testToken = PeekToken ()
		IF (testToken{29,0} != T_MUL) THEN GOTO eeeSyntax
		testToken = NextToken ()					' point to *
		IF elePtr THEN GOTO eeeSyntax			' pointer to fixed string : invalid
		testToken = NextToken ()
		tt = testToken{$$NUMBER}
		SELECT CASE testToken{$$KIND}
			CASE $$KIND_LITERALS	:	eleSize = XLONG (tab_sym$[tt])
			CASE $$KIND_SYSCONS		:	eleSize = XLONG (r_addr$[tt])
			CASE ELSE							:	GOTO eeeSyntax
		END SELECT
		IFZ eleSize THEN PRINT "ccc0": GOTO eeeComponent
		eleStringSize = eleSize
		fixedString = $$TRUE
	ENDIF
	eleToken = token												' pass the type token
	eleType = TypenameToken (@eleToken)			' type; next token
	IFZ eleType THEN GOTO eeeSyntax

	dataPtr = tokenPtr
	IF arg[] THEN DIM arg[]
	IF (eleType = $$FUNCADDR) THEN
		GetFuncaddrInfo (@eleToken, @eleElements, @arg[], @dataPtr)
		IF (eleToken{$$KIND} = $$KIND_ARRAY_SYMBOLS) THEN
			IFZ eleElements THEN tokenPtr = dataPtr + 1: GOTO eeeNeedSubscript
			eleArrayUBound = eleElements - 1
			eleSize = eleElements * 4
			eleAlign = 4
		ELSE
			eleArrayUBound = 0
			eleSize = 4
			eleAlign = 4
		ENDIF
		GOSUB CheckElement
	ELSE
		GOSUB CheckElement
		SELECT CASE TRUE
      CASE packed       : eleAlign  = 1
			CASE fixedString	:	eleAlign	= 1
			CASE ELSE					:	eleAlign	= typeAlign[eleType]
		END SELECT
		IFF fixedString THEN eleSize = typeSize[eleType]
		IF (eleKind = $$KIND_ARRAY_SYMBOLS) THEN
			token = NextToken ()
			IF (token <> T_LBRAK) THEN GOTO eeeSyntax
			token = NextToken ()
			tt = token{$$NUMBER}
			SELECT CASE token{$$KIND}				' literals may not be in r_addr yet
				CASE $$KIND_LITERALS	:	arrayDim = XLONG (tab_sym$[tt])
				CASE $$KIND_SYSCONS		:	arrayDim = XLONG (r_addr$[tt])
				CASE ELSE							:	PRINT "ccc2": GOTO eeeComponent
			END SELECT
			token = NextToken ()
			IF (token <> T_RBRAK) THEN GOTO eeeSyntax		' 1-D arrays for now
			eleSize = eleSize * (arrayDim + 1)
			eleArrayUBound = arrayDim
		ENDIF
	ENDIF
	IFZ eleSize THEN GOTO eeeCompiler
	IFZ eleAlign THEN GOTO eeeCompiler
	IF (eleAlign > typeMaxAlign) THEN typeMaxAlign = eleAlign
	SELECT CASE TRUE
		CASE inUNION	:	typeThisAddr = (addrUNION + eleAlign - 1) AND -eleAlign
										IF ((typeThisAddr + eleSize) > typeNextAddr) THEN typeNextAddr = typeThisAddr + eleSize
		CASE inTYPE		:	typeThisAddr = (typeNextAddr + eleAlign - 1) AND -eleAlign
										typeNextAddr = typeThisAddr + eleSize
		CASE ELSE			:	PRINT "TypeUnion": GOTO eeeCompiler
	END SELECT
	IF (eleCount > uEle) THEN
		uEle = uEle + 4
		REDIM tsymbol$[uEle]
		REDIM ttoken[uEle]
		REDIM tsize[uEle]
		REDIM	taddr[uEle]
		REDIM ttype[uEle]
		REDIM atype[uEle,]
		REDIM	tval[uEle]
		REDIM tptr[uEle]
		REDIM tss[uEle]
		REDIM tub[uEle]
	ENDIF
	tsymbol$[eleCount] = eleName$
	ttoken[eleCount] = eleToken
	tsize[eleCount] = eleSize
	taddr[eleCount] = typeThisAddr
	ttype[eleCount] = eleType
	tval[eleCount] = 0
	tptr[eleCount] = elePtr
	tss[eleCount] = eleStringSize
	tub[eleCount] = eleArrayUBound
	ATTACH arg[] TO atype[eleCount, ]
	INC eleCount
	token = NextToken ()
	RETURN ($$T_STARTS)

' *****  END TYPE  *****  END UNION  *****

p_end_type:
	IFZ eleCount THEN GOTO eeeSyntax
	IFZ typeNumber THEN GOTO eeeSyntax
	IF inUNION THEN
		token = NextToken ()
		SELECT CASE token
			CASE T_UNION	:	GOSUB FixUnion	: RETURN ($$T_STARTS)
			CASE T_TYPE		: GOTO eeeSyntax
			CASE ELSE			:	GOTO eeeSyntax
		END SELECT
	ENDIF
	ATTACH tsymbol$[] TO typeEleSymbol$[typeNumber, ]
	ATTACH ttoken[] TO typeEleToken[typeNumber, ]
	ATTACH tsize[] TO typeEleSize[typeNumber, ]
	ATTACH taddr[] TO typeEleAddr[typeNumber, ]
	ATTACH ttype[] TO typeEleType[typeNumber, ]
	ATTACH atype[] TO typeEleArg[typeNumber, ]
	ATTACH tval[] TO typeEleVal[typeNumber, ]
	ATTACH tptr[] TO typeElePtr[typeNumber, ]
	ATTACH tss[] TO typeEleStringSize[typeNumber, ]
	ATTACH tub[] TO typeEleUBound[typeNumber, ]
	typeEleCount[typeNumber] = eleCount
	IFF packed THEN
		IF (typeMaxAlign <= 4) THEN
			typeMaxAlign = 4
			roundSize = 3
		ELSE
			typeMaxAlign = 8
			roundSize = 7
		ENDIF
		typeNextAddr = (typeNextAddr + roundSize) AND (NOT roundSize)
	ENDIF
	packed = $$FALSE
	typeAlign[typeNumber]	=	typeMaxAlign
	typeSize[typeNumber] = typeNextAddr
	token = NextToken ()
	inUNION = $$FALSE
	inTYPE = $$FALSE
	typeNumber = 0
	uEle = 0
	RETURN ($$T_STARTS)


' When the end of a UNION ... END UNION block is reached,
' all the components in the UNION need to be fixed up to
' align with the most restrictive component.

' *****  FixUnion  *****

SUB FixUnion
	inUNION = $$FALSE
	align = 0
	addr = 0
	size = 0

	FOR e = eleCountUNION TO eleCount-1
		eName$ = tsymbol$[e]
		eToken = ttoken[e]
		eSize = tsize[e]
		eAddr = taddr[e]
		eType = ttype[e]
		sSize = tss[e]
		aUpper = tub[e]
		tAlign = typeAlign[eType]
		tSize = typeSize[eType]
		IF (eSize > size) THEN size = eSize
		IF (eAddr > addr) THEN addr = eAddr
	NEXT e

	FOR e = eleCountUNION TO eleCount-1
		taddr[e] = addr
	NEXT e
	typeNextAddr = addr + size
END SUB

SUB CheckElement
	eleKind = eleToken{$$KIND}
	IF (eleKind != $$KIND_SYMBOLS) THEN
		IF (eleKind != $$KIND_ARRAY_SYMBOLS) THEN
      GOTO eeeComponent
    ENDIF
	ENDIF
	eleNumber = eleToken{$$NUMBER}
	eleName$ = tab_sym$[eleNumber]
	IF (eleName${0} != '.') THEN GOTO eeeSyntax		' name must begin with .
	IF eleCount THEN
		i = 0
		DO WHILE (i < eleCount)
			IF (eleName$ = tsymbol$[i]) THEN
				tokenPtr	= dataPtr
				GOTO eeeDupDefinition
			ENDIF
			INC i
		LOOP
	ENDIF
END SUB


' *****  WRITE *****

p_write:
	got_executable = $$TRUE
	token = NextToken ()
	IF (token != T_LBRAK) THEN GOTO eeeSyntax				' WRITE [ifile], var
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (token != T_RBRAK) THEN GOTO eeeSyntax
	token = NextToken ()
	IF (token != T_COMMA) THEN GOTO eeeSyntax

	IFF q_type_long[result_type] THEN GOTO eeeTypeMismatch
	IFZ toes THEN GOTO eeeSyntax
	symbol$ = ".filenumber"
	ftoken = $$T_VARIABLES + ($$AUTOX << 21) + ($$XLONG << 16)
	ftoken = AddSymbol (@symbol$, ftoken, func_number)
	fnum = ftoken{$$NUMBER}
	IFZ m_addr$[fnum] THEN AssignAddress (ftoken)
	IF XERROR THEN EXIT FUNCTION
	xx = Topax1 ()
	Move (ftoken, $$XLONG, xx, $$XLONG)

' WRITE the variables

	DO
		wtoken	= PeekToken ()
		kind		= wtoken{$$KIND}
		wt			= wtoken{$$NUMBER}
		SELECT CASE kind
			CASE $$KIND_VARIABLES:	array = $$FALSE
			CASE $$KIND_ARRAYS:			array = $$TRUE
															token = NextToken ()
															token = NextToken ()
															IF (token != T_LBRAK) THEN GOTO eeeCompiler
															token = NextToken ()
															IF (token != T_RBRAK) THEN GOTO eeeSyntax
			CASE ELSE:							token = NextToken (): GOTO eeeKindMismatch
		END SELECT
		IFZ m_addr$[wt] THEN AssignAddress (wtoken)
		IF XERROR THEN EXIT FUNCTION
		wtype		= TheType (wtoken)
		IF (array OR (wtype < $$SCOMPLEX)) THEN
			IF (array OR (wtype = $$STRING)) THEN
				IF array THEN
					w$ = "%_WriteArray"
				ELSE
					w$ = "%_WriteString"
				ENDIF
				token			= NextToken ()
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i271")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i272")
				Move ($$eax, $$XLONG, wtoken, $$XLONG)	' get file #
				Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, @"", @"	;;; i273")
				Code ($$call, $$rel, 0, 0, 0, 0, w$, @"	;;; i274")
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i275")
			ELSE
				SELECT CASE wtype
					CASE $$SINGLE:	wtype = $$XLONG
					CASE $$DOUBLE:	wtype = $$GIANT
				END SELECT
				xsize		= typeSize[wtype]
				size$		= HEXX$(xsize, 4)
				token		= NextToken ()
				wt			= token{$$NUMBER}
				mReg		= m_reg[wt]
				mAddr		= m_addr[wt]
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i276")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)	' get file #
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i277")
				IF mReg THEN
					Code ($$lea, $$regro, $$eax, mReg, mAddr, $$XLONG, @"", @"	;;; i278")
				ELSE
					Code ($$lea, $$regabs, $$eax, 0, mAddr, $$XLONG, m_addr$[wt], @"	;;; i279")
				ENDIF
				Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, @"", @"	;;; i280")
				Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, @"", @"	;;; i281")
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_Write", @"	;;; i282")
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i283")
			ENDIF
		ELSE
			Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i284")
			Move ($$eax, $$XLONG, ftoken, $$XLONG)	' get file #
			Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i285")
			ctype		= wtype
			rreg		= $$FALSE
			creg		= NextToken ()
			Composite ($$GETDATAADDR, ctype, @creg, @offset, @xsize)
			IF XERROR THEN EXIT FUNCTION
			IF toes THEN xx = Topax1 ()
			IFZ creg THEN PRINT "WRITEcomposite": GOTO eeeCompiler
			Code ($$lea, $$regro, $$eax, creg, offset, $$XLONG, @"", @"	;;; i286")
			Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, @"", @"	;;; i287")
			Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, @"", @"	;;; i288")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_Write", @"	;;; i289")
			Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i290")
		ENDIF
		a0_type	= 0
		token		= NextToken ()
	LOOP WHILE (token = T_COMMA)
	RETURN (token)



' *****************************************
' *****  LOAD kindBeforeFunc[] ARRAY  *****
' *****************************************

SUB KindBeforeFunc
	DIM kindBeforeFunc[31]
	kindBeforeFunc [ $$KIND_TYPES					] = GOADDRESS (b_types)
	kindBeforeFunc [ $$KIND_STARTS				] = GOADDRESS (b_starts)
	kindBeforeFunc [ $$KIND_SYSCONS				] = GOADDRESS (b_syscons)
	kindBeforeFunc [ $$KIND_COMMENTS			] = GOADDRESS (b_comments)
	kindBeforeFunc [ $$KIND_CONSTANTS			] = GOADDRESS (b_constants)
	kindBeforeFunc [ $$KIND_STATEMENTS		] = GOADDRESS (b_statements)
	kindBeforeFunc [ $$KIND_STATE_INTRIN	] = GOADDRESS (b_statements)
	kindBeforeFunc [ $$KIND_TERMINATORS		] = GOADDRESS (b_terminators)
	kindBeforeFunc [ $$KIND_CHARACTERS		] = GOADDRESS (b_characters)
END SUB

SUB TypeBeforeFunc
	DIM typeBeforeFunc[255]
	typeBeforeFunc[ T_SBYTE				AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_UBYTE				AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_SSHORT			AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_USHORT			AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_SLONG				AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_ULONG				AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_XLONG				AND 0x00FF ] = GOADDRESS (p_types)
'	typeBeforeFunc[ T_GOADDR			AND 0x00FF ] = GOADDRESS (p_types)
'	typeBeforeFunc[ T_SUBADDR			AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_FUNCADDR		AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_GIANT				AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_SINGLE			AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_DOUBLE			AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_SCOMPLEX		AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_DCOMPLEX		AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_STRING			AND 0x00FF ] = GOADDRESS (p_types)
	typeBeforeFunc[ T_LONGDOUBLE	AND 0x00FF ] = GOADDRESS (p_types)
END SUB

SUB StateBeforeFunc
	DIM stateBeforeFunc [255]
	stateBeforeFunc [ T_ALL					AND 0x00FF ] = GOADDRESS (b_all)
	stateBeforeFunc [ T_CFUNCTION		AND 0x00FF ] = GOADDRESS (b_cfunction)
	stateBeforeFunc [ T_CONSOLE   	AND 0x00FF ] = GOADDRESS (b_console)
	stateBeforeFunc [ T_EXPLICIT  	AND 0x00FF ] = GOADDRESS (b_explicit)
	stateBeforeFunc [ T_DECLARE			AND 0x00FF ] = GOADDRESS (b_declare)
	stateBeforeFunc [ T_END					AND 0x00FF ] = GOADDRESS (b_end)
	stateBeforeFunc [ T_EXPORT			AND 0x00FF ] = GOADDRESS (b_export)
	stateBeforeFunc [ T_EXTERNAL		AND 0x00FF ] = GOADDRESS (b_external)
	stateBeforeFunc [ T_FUNCTION		AND 0x00FF ] = GOADDRESS (b_function)
	stateBeforeFunc [ T_IMPORT			AND 0x00FF ] = GOADDRESS (b_import)
	stateBeforeFunc [ T_INTERNAL		AND 0x00FF ] = GOADDRESS (b_internal)
	stateBeforeFunc [ T_LIBRARY			AND 0x00FF ] = GOADDRESS (b_library)
	stateBeforeFunc [ T_MAKEFILE  	AND 0x00FF ] = GOADDRESS (b_makefile)
  stateBeforeFunc [ T_PACKED    	AND 0x00FF ] = GOADDRESS (b_packed)
	stateBeforeFunc [ T_PROGRAM			AND 0x00FF ] = GOADDRESS (b_program)
	stateBeforeFunc [ T_SFUNCTION 	AND 0x00FF ] = GOADDRESS (b_sfunction)
	stateBeforeFunc [ T_SHARED			AND 0x00FF ] = GOADDRESS (b_shared)
	stateBeforeFunc [ T_TYPE				AND 0x00FF ] = GOADDRESS (b_type)
	stateBeforeFunc [ T_UNION				AND 0x00FF ] = GOADDRESS (b_union)
	stateBeforeFunc [ T_VERSION			AND 0x00FF ] = GOADDRESS (b_version)
END SUB

SUB KindAfterFunc
	DIM kindAfterFunc[31]
	kindAfterFunc [ $$KIND_VARIABLES		] = GOADDRESS (a_variables)
	kindAfterFunc [ $$KIND_ARRAYS				] = GOADDRESS (a_arrays)
	kindAfterFunc [ $$KIND_CONSTANTS		] = GOADDRESS (a_constants)
	kindAfterFunc [ $$KIND_FUNCTIONS		] = GOADDRESS (a_functions)
	kindAfterFunc [ $$KIND_LABELS				] = GOADDRESS (a_labels)
	kindAfterFunc [ $$KIND_STARTS				] = GOADDRESS (a_starts)
	kindAfterFunc [ $$KIND_TYPES				] = GOADDRESS (a_types)
	kindAfterFunc [ $$KIND_ADDR_OPS			] = GOADDRESS (a_addr_ops)
	kindAfterFunc [ $$KIND_COMMENTS			] = GOADDRESS (a_comments)
	kindAfterFunc [ $$KIND_WHITES				] = GOADDRESS (a_whites)
	kindAfterFunc [ $$KIND_TERMINATORS	] = GOADDRESS (a_terminators)
	kindAfterFunc [ $$KIND_CHARACTERS		] = GOADDRESS (a_characters)
	kindAfterFunc [ $$KIND_STATEMENTS		] = GOADDRESS (a_statements)
	kindAfterFunc [ $$KIND_INTRINSICS		] = GOADDRESS (a_intrinsics)
	kindAfterFunc [ $$KIND_STATE_INTRIN	] = GOADDRESS (a_state_intrin)
END SUB

SUB StateAfterFunc
	DIM stateAfterFunc[255]
	stateAfterFunc	[	T_ALL					AND 0x00FF	] = GOADDRESS (p_all)
	stateAfterFunc	[	T_ATTACH			AND 0x00FF	] = GOADDRESS (p_attach)
	stateAfterFunc	[	T_AUTO				AND 0x00FF	] = GOADDRESS (p_auto)
	stateAfterFunc	[	T_AUTOX				AND 0x00FF	] = GOADDRESS (p_autox)
	stateAfterFunc	[	T_CASE				AND 0x00FF	] = GOADDRESS (p_case)
	stateAfterFunc	[	T_CFUNCTION		AND 0x00FF	] = GOADDRESS (p_cfunction)
	stateAfterFunc	[	T_DEC					AND 0x00FF	] = GOADDRESS (p_dec)
	stateAfterFunc	[	T_DECLARE			AND 0x00FF	] = GOADDRESS (p_declare_func)
	stateAfterFunc	[	T_DIM					AND 0x00FF	] = GOADDRESS (p_dim)
	stateAfterFunc	[	T_DO					AND 0x00FF	] = GOADDRESS (p_do)
	stateAfterFunc	[	T_DOUBLE			AND 0x00FF	] = GOADDRESS (p_double)
	stateAfterFunc	[	T_DOUBLEAT		AND 0x00FF	] = GOADDRESS (p_doubleat)
	stateAfterFunc	[	T_ELSE				AND 0x00FF	] = GOADDRESS (p_else)
	stateAfterFunc	[	T_END					AND 0x00FF	] = GOADDRESS (p_end)
	stateAfterFunc	[	T_ENDIF				AND 0x00FF	] = GOADDRESS (p_endif)
	stateAfterFunc	[	T_EXIT				AND 0x00FF	] = GOADDRESS (p_exit)
	stateAfterFunc	[	T_EXTERNAL		AND 0x00FF	] = GOADDRESS (p_external)
	stateAfterFunc	[	T_FOR					AND 0x00FF	] = GOADDRESS (p_for)
	stateAfterFunc	[	T_FUNCADDR		AND 0x00FF	] = GOADDRESS (p_funcaddr)
	stateAfterFunc	[	T_FUNCADDRAT	AND 0x00FF	] = GOADDRESS (p_funcaddrat)
	stateAfterFunc	[	T_FUNCTION		AND 0x00FF	] = GOADDRESS (p_function)
	stateAfterFunc	[	T_GIANT				AND 0x00FF	] = GOADDRESS (p_giant)
	stateAfterFunc	[	T_GIANTAT			AND 0x00FF	] = GOADDRESS (p_giantat)
	stateAfterFunc	[	T_GOADDR			AND 0x00FF	] = GOADDRESS (p_goaddr)
	stateAfterFunc	[	T_GOADDRAT		AND 0x00FF	] = GOADDRESS (p_goaddrat)
	stateAfterFunc	[	T_GOSUB				AND 0x00FF	] = GOADDRESS (p_gosub)
	stateAfterFunc	[	T_GOTO				AND 0x00FF	] = GOADDRESS (p_goto)
	stateAfterFunc	[	T_IF					AND 0x00FF	] = GOADDRESS (p_if)
	stateAfterFunc	[	T_IFF					AND 0x00FF	] = GOADDRESS (p_iff)
	stateAfterFunc	[	T_IFT					AND 0x00FF	] = GOADDRESS (p_ift)
	stateAfterFunc	[	T_IFZ					AND 0x00FF	] = GOADDRESS (p_ifz)
	stateAfterFunc	[	T_INC					AND 0x00FF	] = GOADDRESS (p_inc)
	stateAfterFunc	[	T_LOOP				AND 0x00FF	] = GOADDRESS (p_loop)
  stateAfterFunc  [ T_LONGDOUBLE  AND 0x00FF  ] = GOADDRESS (p_longdouble)
  stateAfterFunc  [ T_LONGDOUBLEAT  AND 0x00FF  ] = GOADDRESS (p_longdoubleat)
	stateAfterFunc	[	T_NEXT				AND 0x00FF	] = GOADDRESS (p_next)
'	stateAfterFunc 	[ T_NOINIT			AND 0x00FF 	] = GOADDRESS(b_noinit)
	stateAfterFunc	[	T_PRINT				AND 0x00FF	] = GOADDRESS (p_print)
	stateAfterFunc	[	T_READ				AND 0x00FF	] = GOADDRESS (p_read)
	stateAfterFunc	[	T_REDIM				AND 0x00FF	] = GOADDRESS (p_redim)
	stateAfterFunc	[	T_RETURN			AND 0x00FF	] = GOADDRESS (p_return)
	stateAfterFunc	[	T_SBYTE				AND 0x00FF	] = GOADDRESS (p_sbyte)
	stateAfterFunc	[	T_SBYTEAT			AND 0x00FF	] = GOADDRESS (p_sbyteat)
	stateAfterFunc	[	T_SELECT			AND 0x00FF	] = GOADDRESS (p_select)
	stateAfterFunc	[ T_SFUNCTION		AND 0x00FF	] = GOADDRESS (p_sfunction)
	stateAfterFunc	[	T_SHARED			AND 0x00FF	] = GOADDRESS (p_shared)
	stateAfterFunc	[	T_SINGLE			AND 0x00FF	] = GOADDRESS (p_single)
	stateAfterFunc	[	T_SINGLEAT		AND 0x00FF	] = GOADDRESS (p_singleat)
	stateAfterFunc	[	T_SLONG				AND 0x00FF	] = GOADDRESS (p_slong)
	stateAfterFunc	[	T_SLONGAT			AND 0x00FF	] = GOADDRESS (p_slongat)
	stateAfterFunc	[	T_SSHORT			AND 0x00FF	] = GOADDRESS (p_sshort)
	stateAfterFunc	[	T_SSHORTAT		AND 0x00FF	] = GOADDRESS (p_sshortat)
	stateAfterFunc	[	T_STATIC			AND 0x00FF	] = GOADDRESS (p_static)
	stateAfterFunc	[	T_STOP				AND 0x00FF	] = GOADDRESS (p_stop)
	stateAfterFunc	[	T_STRING			AND 0x00FF	] = GOADDRESS (p_string)
	stateAfterFunc	[	T_SUB					AND 0x00FF  ] = GOADDRESS (p_sub)
	stateAfterFunc	[	T_SUBADDR			AND 0x00FF	] = GOADDRESS (p_subaddr)
	stateAfterFunc	[	T_SUBADDRAT		AND 0x00FF	] = GOADDRESS (p_subaddrat)
	stateAfterFunc	[	T_SWAP				AND 0x00FF	] = GOADDRESS (p_swap)
	stateAfterFunc	[	T_UBYTE				AND 0x00FF	] = GOADDRESS (p_ubyte)
	stateAfterFunc	[	T_UBYTEAT			AND 0x00FF	] = GOADDRESS (p_ubyteat)
	stateAfterFunc	[	T_ULONG				AND 0x00FF	] = GOADDRESS (p_ulong)
	stateAfterFunc	[	T_ULONGAT			AND 0x00FF	] = GOADDRESS (p_ulongat)
	stateAfterFunc	[	T_USHORT			AND 0x00FF	] = GOADDRESS (p_ushort)
	stateAfterFunc	[	T_USHORTAT		AND 0x00FF	] = GOADDRESS (p_ushortat)
	stateAfterFunc	[	T_WRITE				AND 0x00FF	] = GOADDRESS (p_write)
	stateAfterFunc	[	T_XLONG				AND 0x00FF	] = GOADDRESS (p_xlong)
	stateAfterFunc	[	T_XLONGAT			AND 0x00FF	] = GOADDRESS (p_xlongat)
END SUB


' ********************
'	*****  ERRORS  *****
' ********************

eeeAfterElse:
	XERROR = ERROR_AFTER_ELSE
	EXIT FUNCTION

eeeBadCaseAll:
	XERROR = ERROR_BAD_CASE_ALL
	EXIT FUNCTION

eeeBadGosub:
	XERROR = ERROR_BAD_GOSUB
	EXIT FUNCTION

eeeBadGoto:
	XERROR = ERROR_BAD_GOTO
	EXIT FUNCTION

eeeBadSymbol:
	XERROR = ERROR_BAD_SYMBOL
	EXIT FUNCTION

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION

eeeCrossedFunctions:
	XERROR = ERROR_CROSSED_FUNCTIONS
	EXIT FUNCTION

eeeDeclare:
	XERROR = ERROR_DECLARE
	EXIT FUNCTION

eeeDeclareFuncs:
	XERROR = ERROR_DECLARE_FUNCS_FIRST
	EXIT FUNCTION

eeeDupDeclaration:
	XERROR = ERROR_DUP_DECLARATION
	EXIT FUNCTION

eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	EXIT FUNCTION

eeeDupType:
	XERROR = ERROR_DUP_TYPE
	EXIT FUNCTION

eeeElseInCaseAll:
	XERROR = ERROR_ELSE_IN_CASE_ALL
	EXIT FUNCTION

eeeEntryFunction:
	XERROR = ERROR_ENTRY_FUNCTION
	EXIT FUNCTION

eeeExpectAssignment:
	XERROR = ERROR_EXPECT_ASSIGNMENT
	EXIT FUNCTION

eeeExplicit:
	XERROR = ERROR_EXPLICIT_VARIABLE
	EXIT FUNCTION

eeeExpressionStack:
	XERROR = ERROR_EXPRESSION_STACK
	EXIT FUNCTION

eeeInternalExternal:
	XERROR = ERROR_INTERNAL_EXTERNAL
	EXIT FUNCTION

eeeKindMismatch:
	XERROR = ERROR_KIND_MISMATCH
	EXIT FUNCTION

eeeNeedExcessComma:
	XERROR = ERROR_NEED_EXCESS_COMMA
	EXIT FUNCTION

eeeNeedSubscript:
	XERROR = ERROR_NEED_SUBSCRIPT
	EXIT FUNCTION

eeeNest:
	nestLevel = 1
	IF nestError THEN RETURN ($$T_STARTS)
	nestError = $$TRUE
	XERROR = ERROR_NEST
	EXIT FUNCTION

eeeNodeDataMismatch:
	XERROR = ERROR_NODE_DATA_MISMATCH
	EXIT FUNCTION

eeeOutsideFunctions:
	XERROR = ERROR_OUTSIDE_FUNCTIONS
	EXIT FUNCTION

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeProgramNameMismatch:
	XERROR = ERROR_PROGRAM_NAME_MISMATCH
	EXIT FUNCTION

eeeScopeMismatch:
	XERROR = ERROR_SCOPE_MISMATCH
	EXIT FUNCTION

eeeSharename:
	XERROR = ERROR_SHARENAME
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION

eeeTooFewArgs:
	XERROR = ERROR_TOO_FEW_ARGS
	EXIT FUNCTION

eeeTooLate:
	XERROR = ERROR_TOO_LATE
	EXIT FUNCTION

eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION

eeeUndeclared:
	XERROR = ERROR_UNDECLARED
	EXIT FUNCTION

eeeUndefined:
	XERROR = ERROR_UNDEFINED
	EXIT FUNCTION

eeeUnimplemented:
	XERROR = ERROR_UNIMPLEMENTED
	EXIT FUNCTION

eeeWithinFunction:
	XERROR = ERROR_WITHIN_FUNCTION
	EXIT FUNCTION
END FUNCTION


' ################################
' #####  CloneArrayXLONG ()  #####
' ################################

FUNCTION  CloneArrayXLONG (dest[], source[])

	IFZ source[] THEN DIM dest[]: RETURN
	upper	= UBOUND (source[])
	DIM dest[upper]
	FOR i = 0 TO upper
		dest[i] = source[i]
	NEXT i
END FUNCTION


' #####################
' #####  Code ()  #####
' #####################

FUNCTION  Code (opcode, mode, dreg, sreg, xreg, dataType, label$, remark$)
	SHARED	reg86$[],  reg86c$[],  typeSize[],  typeSize$[]
	STATIC 	smallStoreReg[],  op$[],  fptr$[],  iptr$[]
	STATIC GOADDR  op[]
	STATIC SUBADDR  mode[],  modex[]

' ****************************************************************************
' Init is run only the first time to initialize the arrays - not a bad system,
' 	but I wonder why it is not done at compile-time instead of runtime? - GH
' ****************************************************************************
	IFZ op[] THEN GOSUB Init

	addr = xreg
	omode = mode
	dregx = dreg + 1
	sregx = sreg + 1
	xregx = xreg + 1
	addrx = addr + 4
	immByte = $$FALSE
	IFZ addr THEN
		SELECT CASE mode
			CASE $$ro:			mode = $$r0
			CASE $$regro:		mode = $$regr0
			CASE $$roreg:		mode = $$r0reg
			CASE $$roimm:		mode = $$r0imm
			CASE $$imm:			IF ((dreg >= -128) AND (dreg <= 127)) THEN immByte = $$TRUE
		END SELECT
	ENDIF
	GOSUB	EmitAsm
	RETURN


' ***** EmitAsm *****

SUB EmitAsm

	op$ = op$[opcode]
	ptrType = dataType
	IF (dataType >= $$SCOMPLEX) THEN ptrType = $$XLONG
	IF (op${1} = 'f') THEN
		ptr$ = fptr$[ptrType]
	ELSE
		ptr$ = iptr$[ptrType]
	ENDIF

	' A hack put in by GH
	SELECT CASE opcode
		CASE $$push, $$pop, $$lea
			ptr$ =""
	END SELECT

	revReg = $$FALSE
	twinGiant = $$FALSE
	SELECT CASE dataType
		CASE $$SBYTE
					SELECT CASE opcode
						CASE $$ld:	op$ = "	movsx	"
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000a": GOTO eeeCompiler
												dreg = dreg - 8		' make byte reg
					END SELECT
		CASE $$UBYTE
					SELECT CASE opcode
						CASE $$ld:	op$ = "	movzx	"
						CASE $$st:	IFZ smallStoreReg[dreg] THEN
													 PRINT "code000b": GOTO eeeCompiler
												ENDIF
												dreg = dreg - 8		' make byte reg
					END SELECT
		CASE $$SSHORT
					SELECT CASE opcode
						CASE $$ld:	op$ = "	movsx	"
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000c": GOTO eeeCompiler
												dreg = dreg - 4		' make short reg
					END SELECT
		CASE $$USHORT
					SELECT CASE opcode
						CASE $$ld:	op$ = "	movzx	"
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000d": GOTO eeeCompiler
												dreg = dreg - 4		' make short reg
					END SELECT
		CASE $$GIANT
					SELECT CASE opcode
						CASE $$ld
									IF ((mode = $$regrs) OR (mode = $$regrr)) THEN
										IF ((dreg = sreg) OR (dreg = xreg)) THEN
											IF ((sreg = $$edi) OR (xreg = $$edi)) THEN
												PRINT "80x86 atrosity"
											ENDIF
											greg = dreg
											dreg = $$esi
											GOSUB @modex[omode]		' by accessing second half 1st
											EmitAsm (op$ + oper$)
											dreg = greg
											ducked = $$TRUE
											EXIT SELECT
										ENDIF
									ENDIF
									IF (dreg = sreg) THEN
										GOSUB @modex[omode]
										EmitAsm (op$ + oper$)
									ELSE
										twinGiant = $$TRUE
									ENDIF
						CASE $$st, $$pop
									twinGiant = $$TRUE
						CASE $$push
									GOSUB @modex[omode]
									EmitAsm (op$ + oper$)
					END SELECT
	END SELECT
	GOSUB @mode[mode]
	IF remark$ THEN
		EmitAsm (op$ + oper$ + "		" + remark$)
	ELSE
		EmitAsm (op$ + oper$)
	ENDIF
	IF twinGiant THEN
		GOSUB @modex[omode]
		EmitAsm (op$ + oper$)
	ENDIF
	IF ducked THEN Code ($$mov, $$regreg, dreg+1, $$edi, 0, $$XLONG, @"", @"	;;; icode1")
END SUB

SUB None
	oper$ = ""
END SUB

SUB Rel
	IF opcode = $$jmp THEN
		oper$ = label$
	ELSE
		' Another hack by GH
		SELECT CASE TRUE
			CASE (LEFT$ (label$,8)) = "do.next."
				oper$ = ">> " + label$
			CASE (LEFT$ (label$,7)) = "end.do."
				oper$ = ">> " + label$
			CASE (LEFT$ (label$,8)) = "do.loop."
				oper$ = ">> " + label$
			CASE (LEFT$ (label$,5)) = "else."
				oper$ = ">> " + label$
			CASE (LEFT$ (label$,6)) = "caser."
				oper$ = ">> " + label$
			CASE (LEFT$ (label$,5)) = "case."
				oper$ = ">> " + label$
			CASE (LEFT$(label$,3)) = "do."
				oper$ = "< " + label$
			CASE ELSE
				oper$ = label$
		END SELECT
	ENDIF
END SUB

SUB Imm
	IF label$ THEN
		oper$ = label$
	ELSE
		oper$ = STRING (dreg)
	ENDIF
END SUB

SUB Reg
	oper$ = reg86$[dreg]
END SUB

SUB Abso
	oper$ = ptr$ + "[" + label$ + "]"
END SUB

SUB R0
	oper$ = ptr$ + "[" + reg86$[sreg] + "]"
END SUB

SUB Ro
	SELECT CASE opcode
		CASE $$inc, $$dec, $$fild, $$fstp, $$fld, $$fistp
			oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]"
		CASE ELSE
			oper$ = "[" + reg86$[sreg] + SIGNED$ (addr) + "]"
	END SELECT
END SUB

SUB Rr
	oper$ = ptr$ + "[" + reg86$[sreg] + " + " + reg86$[xreg] + "]"
END SUB

SUB Rs
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]"
END SUB

SUB RegReg
	oper$ = reg86c$[dreg] + reg86$[sreg]
END SUB

SUB RegImm
	IF label$ THEN
		oper$ = reg86c$[dreg] + label$
	ELSE
		oper$ = reg86c$[dreg] + STRING (sreg)
	ENDIF
END SUB

SUB RegAbs
	oper$ = reg86c$[dreg] + ptr$ + "[" + label$ + "]"
END SUB

SUB RegR0
	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + "]"
END SUB

SUB RegRo
	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]"
END SUB

SUB RegRr
	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]"
END SUB

SUB RegRs
	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]"
END SUB

SUB AbsReg
	oper$ = ptr$ + "[" + label$ + "]," + reg86$[dreg]
END SUB

SUB R0Reg
	oper$ = ptr$ + "[" + reg86$[sreg] + "]," + reg86$[dreg]
END SUB

SUB RoReg
	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$(addr) + "]," + reg86$[dreg]
END SUB

SUB RrReg
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]," + reg86$[dreg]
END SUB

SUB RsReg
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]," + reg86$[dreg]
END SUB

SUB AbsImm
	IF label$ THEN
		oper$ = ptr$ + "[" + label$ + "]," + STRING (sreg)		' what if "abs" and "imm" are labels ???
	ELSE
		oper$ = ptr$ + "[" + label$ + "]," + STRING (sreg)
	ENDIF
END SUB

SUB R0Imm
	IF label$ THEN
		oper$ = ptr$ + "[" + reg86$[sreg] + "]," + label$
	ELSE
		oper$ = ptr$ + "[" + reg86$[sreg] + "]," + STRING (dreg)
	ENDIF
END SUB

SUB RoImm
	IF label$ THEN
		oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]," + label$
	ELSE
		oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]," + STRING (dreg)
	ENDIF
END SUB

SUB RrImm
	IF label$ THEN
		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]," + label$
	ELSE
		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]," + STRING (dreg)
	ENDIF
END SUB

SUB RsImm
	IF label$ THEN
		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]," + label$
	ELSE
		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]," + STRING (dreg)
	ENDIF
END SUB


SUB XNone
	GOTO eeeCompiler
END SUB

SUB XRel
	GOTO eeeCompiler
END SUB

SUB XImm
	GOTO eeeCompiler
END SUB

SUB XReg
	oper$ = reg86$[dreg+1]
END SUB

SUB XAbso
	oper$ = ptr$ + "[" + label$ + "+4]"
END SUB

SUB XR0
	oper$ = ptr$ + "[" + reg86$[sreg] + "+4]"
END SUB

SUB XRo
	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addrx) + "]"
END SUB

SUB XRr
	oper$ = ptr$ + "[" + reg86$[sreg] + " + " + reg86$[xreg] + "+4]"
END SUB

SUB XRs
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "+4]"
END SUB

SUB XRegReg
	oper$ = reg86c$[dregx] + reg86$[sregx]
END SUB

SUB XRegImm
	oper$ = reg86c$[dregx] + "0"
END SUB

SUB XRegAbs
	oper$ = reg86c$[dregx] + ptr$ + "[" + label$ + "+4]"
END SUB

SUB XRegR0
	oper$ = reg86c$[dregx] + ptr$ + "[" + reg86$[sreg] + "+4]"
END SUB

SUB XRegRo
	oper$ = reg86c$[dregx] + ptr$ + "[" + reg86$[sreg] + SIGNED$ (addrx) + "]"
END SUB

SUB XRegRr
	oper$ = reg86c$[dreg+1] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "+4]"
END SUB

SUB XRegRs
	oper$ = reg86c$[dreg+1] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "+4]"
END SUB

SUB XAbsReg
	oper$ = ptr$ + "[" + label$ + "+4]," + reg86$[dregx]
END SUB

SUB XR0Reg
	oper$ = ptr$ + "[" + reg86$[sreg] + "+4]," + reg86$[dregx]
END SUB

SUB XRoReg
	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$(addrx) + "]," + reg86$[dregx]
END SUB

SUB XRrReg
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "+4]," + reg86$[dregx]
END SUB

SUB XRsReg
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[addr] + "*" + typeSize$[dataType] + "+4]," + reg86$[dreg+1]
END SUB

SUB XAbsImm
	oper$ = ptr$ + "[" + label$ + "+4],0"
END SUB

SUB XR0Imm
	oper$ = ptr$ + "[" + reg86$[sreg] + "+4],0"
END SUB

SUB XRoImm
	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addrx) + "],0"
END SUB

SUB XRrImm
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "+4],0"
END SUB

SUB XRsImm
	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "+4],0"
END SUB



' *******************************
' *****  Initialize Arrays  *****
' *******************************

SUB Init
	DIM op[255],		op$[255]
	DIM mode[31],		modex[31]
	DIM iptr$[31],	fptr$[31]
	DIM smallStoreReg[31]

	op$[$$nop]					= "	nop	"
	op$[$$adc]					= "	adc	"
	op$[$$add]					= "	add	"
	op$[$$and]					= "	and	"
	op$[$$bsf]					= "	bsf	"
	op$[$$bsr]					= "	bsr	"
	op$[$$bt]						= "	bt	"
	op$[$$btc]					= "	btc	"
	op$[$$btr]					= "	btr	"
	op$[$$bts]					= "	bts	"
	op$[$$call]					= "	call	"
	op$[$$cbw]					= "	cbw	"
	op$[$$cdq]					= "	cdq	"
	op$[$$clc]					= "	clc	"
	op$[$$cld]					= "	cld	"
	op$[$$cmc]					= "	cmc	"
	op$[$$cmp]					= "	cmp	"
	op$[$$cmpsb]				= "	cmpsb	"
	op$[$$cmpsw]				= "	cmpsw	"
	op$[$$cmpsd]				= "	cmpsd	"
	op$[$$cwd]					= "	cwd	"
	op$[$$cwde]					= "	cwde	"
	op$[$$dec]					= "	dec	"
	op$[$$div]					= "	div	"
	op$[$$f2xm1]				= "	f2xm1	"
	op$[$$fabs]					= "	fabs	"
	op$[$$fadd]					= "	fadd	"
	op$[$$faddp]				= "	faddp	"
	op$[$$fchs]					= "	fchs	"
	op$[$$fclex]				= "	fclex	"
	op$[$$fnclex]				= "	fnclex	"
	op$[$$fcom]					= "	fcom	"
	op$[$$fcomp]				= "	fcomp	"
	op$[$$fcompp]				= "	fcompp	"
	op$[$$fcos]					= "	fcos	"
	op$[$$fdecstp]			= "	fdecstp	"
	op$[$$fdiv]					= "	fdiv	"
	op$[$$fdivp]				= "	fdivp	"
	op$[$$fdivr]				= "	fdivr	"
	op$[$$fdivrp]				= "	fdivrp	"
	op$[$$fild]					= "	fild	"
	op$[$$fincstp]			= "	fincstp	"
	op$[$$fist]					= "	fist	"
	op$[$$fistp]				= "	fistp	"
	op$[$$fld]					= "	fld	"
	op$[$$fldlg2]				= "	fldlg2	"
	op$[$$fldln2]				= "	fldln2	"
	op$[$$fldl2e]				= "	fldl2e	"
	op$[$$fldl2t]				= "	fldl2t	"
	op$[$$fldpi]				= "	fldpi	"
	op$[$$fldz]					= "	fldz	"
	op$[$$fld1]					= "	fld1	"
	op$[$$fmul]					= "	fmul	"
	op$[$$fmulp]				= "	fmulp	"
	op$[$$fnop]					= "	fnop	"
	op$[$$fpatan]				= "	fpatan	"
	op$[$$fprem]				= "	fprem	"
	op$[$$fprem1]				= "	fprem1	"
	op$[$$fptan]				= "	fptan	"
	op$[$$frndint]			= "	frndint	"
	op$[$$fscale]				= "	fscale	"
	op$[$$fsin]					= "	fsin	"
	op$[$$fsincos]			= "	fsincos	"
	op$[$$fsqrt]				= "	fsqrt	"
	op$[$$fst]					= "	fst	"
	op$[$$fstp]					= "	fstp	"
	op$[$$fstsw]				= "	fstsw	"
	op$[$$fnstsw]				= "	fnstsw	"
	op$[$$fsub]					= "	fsub	"
	op$[$$fsubp]				= "	fsubp	"
	op$[$$fsubr]				= "	fsubr	"
	op$[$$fsubrp]				= "	fsubrp	"
	op$[$$ftst]					= "	ftst	"
	op$[$$fucom]				= "	fucom	"
	op$[$$fucomp]				= "	fucomp	"
	op$[$$fucompp]			= "	fucompp	"
	op$[$$fxam]					= "	fxam	"
	op$[$$fxch]					= "	fxch	"
	op$[$$fxtract]			= "	fxtract	"
	op$[$$fyl2x]				= "	fyl2x	"
	op$[$$fyl2xp1]			= "	fyl2xp1	"
	op$[$$f2xn1]				= "	f2xn1	"
	op$[$$idiv]					= "	idiv	"
	op$[$$imul]					= "	imul	"
	op$[$$inc]					= "	inc	"
	op$[$$int]					= "	int	"
	op$[$$into]					= "	into	"
	op$[$$ja]						= "	ja	"
	op$[$$jae]					= "	jae	"
	op$[$$jb]						= "	jb	"
	op$[$$jbe]					= "	jbe	"
	op$[$$jc]						= "	jc	"
	op$[$$jcxz]					= "	jcxz	"
	op$[$$jecxz]				= "	jecxz	"
	op$[$$je]						= "	je	"
	op$[$$jg]						= "	jg	"
	op$[$$jge]					= "	jge	"
	op$[$$jl]						= "	jl	"
	op$[$$jle]					= "	jle	"
	op$[$$jna]					= "	jna	"
	op$[$$jnae]					= "	jnae	"
	op$[$$jnb]					= "	jnb	"
	op$[$$jnbe]					= "	jnbe	"
	op$[$$jnc]					= "	jnc	"
	op$[$$jne]					= "	jne	"
	op$[$$jng]					= "	jng	"
	op$[$$jnge]					= "	jnge	"
	op$[$$jnl]					= "	jnl	"
	op$[$$jnle]					= "	jnle	"
	op$[$$jno]					= "	jno	"
	op$[$$jnp]					= "	jnp	"
	op$[$$jns]					= "	jns	"
	op$[$$jnz]					= "	jnz	"
	op$[$$jo]						= "	jo	"
	op$[$$jp]						= "	jp	"
	op$[$$jpe]					= "	jpe	"
	op$[$$jpo]					= "	jpo	"
	op$[$$js]						= "	js	"
	op$[$$jz]						= "	jz	"
	op$[$$jmp]					= "	jmp	"
	op$[$$lahf]					= "	lahf	"
	op$[$$ld]						= "	mov	"
	op$[$$lea]					= "	lea	"
	op$[$$lodsb]				= "	lodsb	"
	op$[$$lodsw]				= "	lodsw	"
	op$[$$lodsd]				= "	lodsd	"
	op$[$$loop]					= "	loop	"
	op$[$$loopz]				= "	loopz	"
	op$[$$loopnz]				= "	loopnz	"
	op$[$$mov]					= "	mov	"
	op$[$$movsb]				= "	movsb	"
	op$[$$movsw]				= "	movsw	"
	op$[$$movsd]				= "	movsd	"
	op$[$$mul]					= "	mul	"
	op$[$$neg]					= "	neg	"
	op$[$$nop]					= "	nop	"
	op$[$$not]					= "	not	"
	op$[$$or]						= "	or	"
	op$[$$pop]					= "	pop	"
	op$[$$popad]				= "	popad	"
	op$[$$popfd]				= "	popfd	"
	op$[$$push]					= "	push	"
	op$[$$pushad]				= "	pushad	"
	op$[$$pushfd]				= "	pushfd	"
	op$[$$rcl]					= "	rcl	"
	op$[$$rcr]					= "	rcr	"
	op$[$$rol]					= "	rol	"
	op$[$$ror]					= "	ror	"
	op$[$$rep]					= "	rep	"
	op$[$$repz]					= "	repz	"
	op$[$$repnz]				= "	repnz	"
	op$[$$ret]					= "	ret	"
	op$[$$sahf]					= "	sahf	"
	op$[$$sal]					= "	sal	"
	op$[$$sar]					= "	sar	"
	op$[$$shl]					= "	shl	"
	op$[$$shr]					= "	shr	"
	op$[$$sbb]					= "	sbb	"
	op$[$$scasb]				= "	scasb	"
	op$[$$scasw]				= "	scasw	"
	op$[$$scasd]				= "	scasd	"
	op$[$$shld]					= "	shld	"
	op$[$$shrd]					= "	shrd	"
	op$[$$st]						= "	mov	"
	op$[$$stc]					= "	stc	"
	op$[$$std]					= "	std	"
	op$[$$stosb]				= "	stosb	"
	op$[$$stosw]				= "	stosw	"
	op$[$$stosd]				= "	stosd	"
	op$[$$sub]					= "	sub	"
	op$[$$test]					= "	test	"
	op$[$$xchg]					= "	xchg	"
	op$[$$xor]					= "	xor	"
	mode[$$none]								= SUBADDRESS (None)
	mode[$$abs]									= SUBADDRESS (Abso)
	mode[$$rel]									= SUBADDRESS (Rel)
	mode[$$reg]									= SUBADDRESS (Reg)
	mode[$$imm]									= SUBADDRESS (Imm)
	mode[$$r0]									= SUBADDRESS (R0)
	mode[$$ro]									= SUBADDRESS (Ro)
	mode[$$rr]									= SUBADDRESS (Rr)
	mode[$$rs]									= SUBADDRESS (Rs)
	mode[$$regreg]							= SUBADDRESS (RegReg)
	mode[$$regimm]							= SUBADDRESS (RegImm)
	mode[$$regabs]							= SUBADDRESS (RegAbs)
	mode[$$regr0]								= SUBADDRESS (RegR0)
	mode[$$regro]								= SUBADDRESS (RegRo)
	mode[$$regrr]								= SUBADDRESS (RegRr)
	mode[$$regrs]								= SUBADDRESS (RegRs)
	mode[$$absreg]							= SUBADDRESS (AbsReg)
	mode[$$r0reg]								= SUBADDRESS (R0Reg)
	mode[$$roreg]								= SUBADDRESS (RoReg)
	mode[$$rrreg]								= SUBADDRESS (RrReg)
	mode[$$rsreg]								= SUBADDRESS (RsReg)
	mode[$$absimm]							= SUBADDRESS (AbsImm)
	mode[$$r0imm]								= SUBADDRESS (R0Imm)
	mode[$$roimm]								= SUBADDRESS (RoImm)
	mode[$$rrimm]								= SUBADDRESS (RrImm)
	mode[$$rsimm]								= SUBADDRESS (RsImm)

	modex[$$none]								= SUBADDRESS (XNone)
	modex[$$abs]								= SUBADDRESS (XAbso)
	modex[$$rel]								= SUBADDRESS (XRel)
	modex[$$reg]								= SUBADDRESS (XReg)
	modex[$$imm]								= SUBADDRESS (XImm)
	modex[$$r0]									= SUBADDRESS (XR0)
	modex[$$ro]									= SUBADDRESS (XRo)
	modex[$$rr]									= SUBADDRESS (XRr)
	modex[$$rs]									= SUBADDRESS (XRs)
	modex[$$regreg]							= SUBADDRESS (XRegReg)
	modex[$$regimm]							= SUBADDRESS (XRegImm)
	modex[$$regabs]							= SUBADDRESS (XRegAbs)
	modex[$$regr0]							= SUBADDRESS (XRegR0)
	modex[$$regro]							= SUBADDRESS (XRegRo)
	modex[$$regrr]							= SUBADDRESS (XRegRr)
	modex[$$regrs]							= SUBADDRESS (XRegRs)
	modex[$$absreg]							= SUBADDRESS (XAbsReg)
	modex[$$r0reg]							= SUBADDRESS (XR0Reg)
	modex[$$roreg]							= SUBADDRESS (XRoReg)
	modex[$$rrreg]							= SUBADDRESS (XRrReg)
	modex[$$rsreg]							= SUBADDRESS (XRsReg)
	modex[$$absimm]							= SUBADDRESS (XAbsImm)
	modex[$$r0imm]							= SUBADDRESS (XR0Imm)
	modex[$$roimm]							= SUBADDRESS (XRoImm)
	modex[$$rrimm]							= SUBADDRESS (XRrImm)
	modex[$$rsimm]							= SUBADDRESS (XRsImm)

	iptr$[$$ZERO]								= "d"
	iptr$[$$VOID]								= "d"
	iptr$[$$SBYTE]							= "b"
	iptr$[$$UBYTE]							= "b"
	iptr$[$$SSHORT]							= "w"
	iptr$[$$USHORT]							= "w"
	iptr$[$$SLONG]							= "d"
	iptr$[$$ULONG]							= "d"
	iptr$[$$XLONG]							= "d"
	iptr$[$$GOADDR]							= "d"
	iptr$[$$SUBADDR]						= "d"
	iptr$[$$FUNCADDR]						= "d"
	iptr$[$$GIANT]							= "d"
	iptr$[$$SINGLE]							= "d"
	iptr$[$$DOUBLE]							= "q"

	fptr$[$$ZERO]								= "d"
	fptr$[$$VOID]								= "d"
	fptr$[$$SBYTE]							= "b"
	fptr$[$$UBYTE]							= "b"
	fptr$[$$SSHORT]							= "w"
	fptr$[$$USHORT]							= "w"
	fptr$[$$SLONG]							= "d"
	fptr$[$$ULONG]							= "d"
	fptr$[$$XLONG]							= "d"
	fptr$[$$GOADDR]							= "d"
	fptr$[$$SUBADDR]						= "d"
	fptr$[$$FUNCADDR]						= "d"
	fptr$[$$GIANT]							= "q"
	fptr$[$$SINGLE]							= "d"
	fptr$[$$DOUBLE]							= "q"
	fptr$[$$LONGDOUBLE]					= "t"

	smallStoreReg[$$al]		= $$TRUE
	smallStoreReg[$$dl]		= $$TRUE
	smallStoreReg[$$bl]		= $$TRUE
	smallStoreReg[$$cl]		= $$TRUE
	smallStoreReg[$$ax]		= $$TRUE
	smallStoreReg[$$dx]		= $$TRUE
	smallStoreReg[$$bx]		= $$TRUE
	smallStoreReg[$$cx]		= $$TRUE
	smallStoreReg[$$eax]	= $$TRUE
	smallStoreReg[$$edx]	= $$TRUE
	smallStoreReg[$$ebx]	= $$TRUE
	smallStoreReg[$$ecx]	= $$TRUE

END SUB

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION



' ########################
' #####  Compile ()  #####
' ########################

FUNCTION  Compile ()
	SHARED  checkBounds,  library,  errorCount
	SHARED  tokens[]
	SHARED  T_COLON,  T_DECLARE,  T_END,  T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED  T_REM,  XERROR,  ERROR_TOO_LATE
	SHARED  pass0source,  pass0tokens
	SHARED  end_program,  got_declare
	SHARED  lineNumber,  rawLength,  rawline$
	SHARED  tokenCount,  tokenPtr,  func_number
	SHARED  toes,  toms,  a0,  a0_type,  a1,  a1_type,  oos
	SHARED  fileName$, programName$
	SHARED  entryCheckBounds
	SHARED  UBYTE  oos[]
	STATIC	xxpc
	SHARED  fLogErrors
	SHARED  removeComment, fConsole
	SHARED  fMak, fRc, fBat         ' suppress file generation
	SHARED  fNoWinMain, fNoDllMain  ' flags to suppress generation of WinMain() or DllMain()
	SHARED  fProfile                ' flag to insert "call __penter" code in every function
	SHARED  fM4
'
	XstGetCommandLineArguments (@argc, @argv$[])

	file$ = ""
	' The first argument is the exe name, so if one argument then there
	' were none so we send the "help" screen.
	IF argc = 1 THEN
	 argc = 2
	 DIM argv$[1]
	 argv$[1] = "-h"
	ENDIF

	args = argc - 1
	FOR i = 1 TO args
			arg$ = TRIM$(argv$[i])
			IFZ arg$ THEN EXIT FOR
			IF (arg${0} != '-') AND (arg${0} != '/') THEN
				file$ = arg$
			ELSE
				SELECT CASE LCASE$(arg$)
					CASE "-lib", "/lib" :
						library = $$TRUE
						PRINT "> Compiling as a function library (DLL)."

					CASE "-m4", "/m4" :
						fM4 = $$TRUE
						PRINT "> Calling m4 macro preprocessor."

					CASE "-bc", "/bc" :
						checkBounds = $$TRUE
						entryCheckBounds = $$TRUE
						PRINT "> Bounds checking on."

					CASE "-rc", "/rc"     : removeComment = $$TRUE
						PRINT "> Removing code comments from output ASM file."

					CASE "-log" , "/log"  :	fLogErrors = $$TRUE

					CASE "-mak", "/mak"   : fMak = $$TRUE
					CASE "-rcf", "/rcf"   : fRc = $$TRUE
					CASE "-bat", "/bat"   : fBat = $$TRUE

					CASE "-nowinmain", "/nowinmain" : fNoWinMain = $$TRUE
					CASE "-nodllmain", "/nodllmain" : fNoDllMain = $$TRUE

					' -p switch inserts 'call _penter' and call _pexit in every function
					' program must IMPORT "proflib" library
					CASE "-p", "/p" : fProfile = $$TRUE

					CASE "-user", "/user" : IFZ fConsole THEN GOTO userInput

					CASE "-version", "/version", "-ver", "/ver", "-v", "/v" :
						PRINT
						PRINT "Versions:"
					PRINT "  Compiler     "; VERSION$ (0)
						PRINT "  Libraries:"
						PRINT "    Xst        "; XstVersion$ ()
						PRINT "    Xsx        "; XsxVersion$ ()
						PRINT
						RETURN

					CASE "-?", "/?", "-help", "/help", "-h", "/h" :
						PRINT "XBLite for Windows (c) David Szafranski 2005"
						PRINT "Usage:  xblite [filename] [options]"
						PRINT
						PRINT "Options:"
						PRINT
						PRINT "   -lib        Compile as function library dll"
'						PRINT "   -conoff     Format error messages"
						PRINT "   -bc         Turn on bounds checking"
						PRINT "   -rc         Remove program code comments in output ASM"
						PRINT "   -log        Log errors to output file progname.log"
						PRINT "   -mak        Suppress output of .mak file"
						PRINT "   -rcf        Suppress output of .rc file"
						PRINT "   -bat        Suppress output of .bat file"
						PRINT "   -nowinmain  Suppress output of WinMain() function code"
						PRINT "   -nodllmain  Suppress output of DllMain() function code"
						PRINT "   -user       Compile user typed code"
						PRINT "   -version    Display versions of compiler components"
						PRINT "   -? -help    Display brief usage message"
						PRINT
						RETURN

					CASE "-conoff", "/conoff" : fConsole = $$TRUE

					CASE ELSE : PRINT "> Invalid argument ",arg$ : arg$ = ""
				END SELECT
			ENDIF
			arg$ = ""
		NEXT i

' *****  if there's a <file$> then compile it

compileFile:
	IF file$ THEN
		fileName$ = file$
		dot = RINSTR (fileName$, ".")
		IF dot THEN fileName$ = LEFT$ (fileName$,dot-1)
		programName$ = fileName$
		slash = RINSTR (programName$, $$PathSlash$)
		IF slash THEN
			programName$ = MID$ (programName$,slash+1)
		ELSE
			slash = RINSTR (programName$, "/")
			IF slash THEN programName$ = MID$ (programName$,slash+1)
		ENDIF
		XstGetSystemTime (@a)
		CompileFile (file$)
		XstGetSystemTime (@b)
		PRINT "> Done. Compiled file in"; b-a; " msec"
		RETURN $$FALSE
	ENDIF

	RETURN $$TRUE

' *****  compile user-typed input  *****

userInput:

	PRINT "\n*****  User Input Mode  *****"
	PRINT "Enter \".\" to start with a default function"

	DO
		PRINT "Press q to quit or enter line of code to compile"
		DO
			rawline$ = TRIM$(INLINE$(">"))
			rawLength = LEN(rawline$)
		LOOP UNTIL (rawLength)

		SELECT CASE rawLength
			CASE 1:			GOSUB CompileSwitchLine
			CASE ELSE:	'IF (rawline${0} = '.') THEN EXIT DO
									GOSUB CompileTypedLine
		END SELECT
		IF end_program THEN RETURN $$TRUE
	LOOP


' *****  ".filename"

'compileDotFile:
'	file$ = RTRIM$(MID$(rawline$, 2))
'	x = RINSTR(file$, ".")
'	IF x THEN file$ = LEFT$(file$, x - 1)
'	GOTO compileFile

' *****  Only one character was typed on the line
' *****  Note: only . and q are currently enabled

SUB CompileSwitchLine
	SELECT CASE rawline${0}

		CASE 'q':	RETURN ($$TRUE)

		CASE '.':	rawline$		= "DECLARE FUNCTION a (XLONG, XLONG)"
							rawLength		= LEN (rawline$)
							GOSUB CompileTypedLine
							rawline$		= "FUNCTION a (y, z)"
							rawLength		= LEN (rawline$)
							GOSUB CompileTypedLine
	END SELECT
END SUB



SUB CompileTypedLine
	xxpc = ##UCODE
	ParseLine (@tok[])
	IF pass0source THEN PRINT Deparse$ ("")
	IF pass0tokens THEN PrintTokens ()
	#immediatemode = $$TRUE
	CheckOneLine()
	#immediatemode = $$FALSE
	IF XERROR THEN
		IF PrintError (XERROR) THEN	EXIT FUNCTION
	ENDIF
	IF (toes OR toms OR a0 OR a0_type OR a1 OR a1_type OR oos OR oos[0]) THEN
		PRINT Deparse$ (">>> ")
		PRINT "exp stk error:  "; toes; toms; a0; a0_type; a1; a1_type; oos; oos[0]
		a0 = 0: a1 = 0: toes = 0: toms = 0: a0_type = 0: a1_type = 0: oos = 0: oos[0] = 0
	ENDIF
	PRINT
END SUB


eeeTooLate:
	XERROR = ERROR_TOO_LATE
	EXIT FUNCTION
END FUNCTION


' ############################
' #####  CompileFile ()  #####
' ############################

FUNCTION  CompileFile (file$)
	SHARED	library
	SHARED	ofile,  rawline$,  rawLength,  compile,  end_program
	SHARED	tokens[],  tokenCount,  lineNumber,  func_number
	SHARED	export
	SHARED	tokenPtr,  got_declare,  got_function
	SHARED  programName$,  asmFile$, xfile$
	SHARED	T_CFUNCTION,  T_DECLARE,  T_END,  T_EXPORT
	SHARED	T_FUNCTION,  T_IMPORT,  T_POUND,  T_PROGRAM
	SHARED	T_SFUNCTION
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	fConsole, fExitNow
	EXTERNAL ##ERROR
	SHARED  fM4
	SHARED  LINEINFO lineinfo[]
	SHARED  parse_got_function

'	AUTO skipped_lines

	ofile = 0
	asmFile$ = ""
	export = 0

	##ERROR = $$FALSE

	xfile$ = file$
	dot = RINSTR (file$, ".")
	IF dot THEN
		ext$ = MID$(file$, dot)
		file$ = LEFT$ (file$, dot-1)
	ELSE
		ext$ = ".x"
		xfile$ = xfile$ + ext$
	ENDIF
	SELECT CASE LCASE$(ext$)
		CASE ".x", ".xbl", ".xl":
		CASE ELSE:
			PRINT "> Invalid extention for source file - must be .x, .xbl, or .xl."
			RETURN
	END SELECT

	IFZ fileName$ THEN fileName$ = file$

	IFZ programName$ THEN
		programName$ = file$
		slash = RINSTR (programName$, $$PathSlash$)
		IF slash THEN
			programName$ = MID$ (programName$,slash+1)
		ELSE
			slash = RINSTR (programName$, "/")
			IF slash THEN programName$ = MID$ (programName$,slash+1)
		ENDIF
	ENDIF

'	IF (file$ != program$) THEN
'		IF (file$ != programName$) THEN
'			PRINT "CompileFile() : ??? program name problem ??? : <"; file$; "> <"; program$; "> <"; programName$; ">"
'		ENDIF
'	ENDIF

	IF fM4 THEN
		' run m4 macro preprocessor on file and capture output to source$
		' invoke m4 with synchronization lines and prefix built-in macros with "m4_"
		command$ = "m4 " + xfile$ + " -s -P"
		XstGetPathComponents (xfile$, @workDir$, "", "", "", 0)
		ShellEx (command$, workDir$, @source$, 0)
		fileSize = LEN(source$)
		IFZ fileSize THEN RETURN
	ELSE
		fileNum = OPEN (xfile$, $$RD)
		IF fileNum <= 0 THEN ##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
		IF (##ERROR OR (fileNum <= 0)) THEN PRINT ERROR$(##ERROR); ". Exiting.": RETURN

		fileSize = LOF (fileNum)					' fileSize = # of bytes in file$
		IFZ fileSize THEN RETURN					' nothing in source file
		source$ = NULL$ (fileSize)				' source$ = size of program
		READ [fileNum], source$						' source$ = entire program
		CLOSE (fileNum)										' close source file
	ENDIF

' Source program is in source$
' Now convert it to tokens

	upperLine = fileSize >> 3					' 1/8 size of source$
	DIM tokoid[upperLine, ]						' Create array for source$ program tokens
	sourceLine = 0
	off = 0

	DIM lineinfo[upperLine]

	IFZ fConsole THEN
		PRINT "\n> Compiling "; xfile$; "."
	ENDIF
'	PRINT "*****  PASS 0  *****"

	DO
		INC sourceLine

		' Get the source line, trim whitespace, and remove comments
		rline$ = RTRIM$(UnComment$ (XstNextLine$ (@source$, @off, @done), @comment$))

		' Handle the line continuation character
		IF (rline$) THEN
			endchar = LEN (rline$) - 1
			IF (rline$ {endchar} = '_') THEN
				prevchar = rline$ {endchar-1}
				IF (prevchar = ' ') || (prevchar = '\t') THEN		' is the previous character a whitespace?
					rline1$ = rline1$ + LEFT$ (rline$, endchar-1)	' trim the whitespace and the "_"
					rawline$ = "' " + rline$	+ comment$					' create a commented line
					GOSUB ParseIt																	' parse the commented line
					DO DO																					' go back for more
				ENDIF
			ENDIF
		ENDIF

		' Build the source string from the parts
		IF (rline1$) THEN
			rawline$ = rline1$ + rline$ + comment$
			rline1$ = ""
		ELSE
			rawline$ = rline$ + comment$
		ENDIF

		IF fM4 THEN    ' handle m4 macro preprocessor line synchonization messages (eg, #line 1 "file.x")
			IF INSTR(rawline$, "#line") = 1 THEN
				idx = 6
				line = XLONG (XstNextField$ (rawline$, @idx, @ok)) - 1		' get line number
				f$ = XstNextField$ (rawline$, @idx, @ok)									' get file name
				XstStripChars (@f$, "\"")																	' remove double quotes
				DEC sourceLine      																			' skip this line
				DO DO
			ELSE
				INC line
				lineinfo[sourceLine].line = line
				lineinfo[sourceLine].file = f$
			ENDIF
		ENDIF

		GOSUB ParseIt

	LOOP UNTIL done
	DEC sourceLine
'	PRINT "*****  PASS 1  *****"

' Create assembly language output file

	##ERROR = $$FALSE
	XxxCreateCompileFiles ()
	IF (ofile <= 0) THEN PRINT "> CompileFile() : error : (Could not open .asm file)" : GOTO eeeCompiler

	func_number = 0
	initFile$ = lineinfo[1].file				' save initial file
	lastFile$ = initFile$

	FOR lineNumber = 1 TO sourceLine
		ATTACH tokoid[lineNumber, ] TO tok[]
		IFZ tok[] THEN PRINT "tok[]": GOTO eeeCompiler
		tokenCount = tok[0]{$$BYTE0}
		FOR i = 0 TO tokenCount
			tokens[i] = tok[i]
		NEXT i
		tokenPtr = 0
		token1 = NextToken ()
		token2 = NextToken ()
		tokenPtr = 0
		holdCount = tokenCount
		tokens[i] = $$T_STARTS
		ATTACH tok[] TO tokoid[lineNumber, ]

		IF fM4 THEN
			f$ = lineinfo[lineNumber].file										' get current file for line
			IF f$ <> lastFile$ THEN
				lastFile$ = f$
				IF lineinfo[lineNumber].file = initFile$ THEN   ' restore settings to main program
					got_function = new_got_function
					parse_got_function = new_parse_got_function
					got_declare = new_got_declare
				ELSE																						' pretend include file is PROLOG
					got_function = 0
					parse_got_function = 0
					got_declare = 0
				ENDIF
			ENDIF
		ENDIF

		CheckOneLine ()

		IF fM4 THEN
			IF lineinfo[lineNumber].file = initFile$ THEN			' save new main program settings
				new_got_function = got_function
				new_parse_got_function = parse_got_function
				new_got_declare = got_declare
			ENDIF
		ENDIF

		IF XERROR THEN
			IF PrintError (XERROR) THEN RETURN
		ENDIF
' Add shared fExitNow exit flag here for getting out of compile loop
' This is needed for exiting from TYPE - END TYPE block errors
' in *.dec files
    IF fExitNow THEN RETURN
		IF end_program THEN RETURN
	NEXT lineNumber

' If program doesn't have an END PROGRAM then fake one (necessary)

	IFZ end_program THEN
		tokens[0]		= $$T_STARTS + 2
		tokens[1]		= T_END
		tokens[2]		= T_PROGRAM
		tokens[3]		= $$T_STARTS
		tokenCount	= 2
		CheckOneLine ()
	ENDIF
	IF (ofile > 2) THEN CLOSE (ofile)
	ofile = 0
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

SUB ParseIt

	rawLength = LEN (rawline$)
	ParseLine (@tok[])
	u = UBOUND (tok[])
	tok[u] = $$T_STARTS
	ATTACH tok[] TO tokoid[sourceLine, ]

	IF (sourceLine >= upperLine) THEN
		upperLine = upperLine + (upperLine >> 2)
		REDIM tokoid[upperLine, ]
		REDIM lineinfo[upperLine]
	ENDIF

END SUB

END FUNCTION


' ##########################
' #####  Component ()  #####
' ##########################

' returns element address (not data)

' varToken	= composite variable token
'						= 0 once variable loaded into accumulator
' regBase		= the accumulator holding the current base pointer
' offset		= holds a compiler internal byte offset

FUNCTION  Component (command, varToken, regBase, offset, theType, token, length)
	SHARED	checkBounds
	SHARED	reg86$[],  reg86c$[]
	SHARED	typeEleCount[],  typeEleToken[],  typeEleAddr[]
	SHARED	typeEleType[],  typeEleArg[],  typeEleSize[]
	SHARED	typeElePtr[],  typeEleStringSize[],  typeEleUBound[]
	SHARED  typeSize[]
	SHARED	tab_sym$[],  r_addr[],  r_addr$[],  q_type_long[]
	SHARED	tabType[]
	SHARED	dim_array,  tokenPtr
	SHARED	toes,  a0,  a0_type,  a1,  a1_type,  labelNumber
	SHARED	T_ADDR_OP,  T_COMMA,  T_LBRAK,  T_RBRAK
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_COMPONENT,  ERROR_OVERFLOW
	SHARED	ERROR_SYNTAX,  ERROR_TYPE_MISMATCH
	SHARED	preType,  componentNumber
	SHARED  UBYTE  shiftMulti[]

	inType	= theType
	preType	= theType
	typeEleCount = typeEleCount[inType]
	found = $$FALSE
	i = 0

	DO WHILE (i < typeEleCount)
		subToken = typeEleToken[inType, i]
		IF (subToken = token) THEN
			componentNumber = i
			found = $$TRUE
			EXIT DO
		ENDIF
		INC i
	LOOP

	IFZ found THEN GOTO eeeComponent

	haveData = $$FALSE						' OUTDATED...used with ptrs
	theType = typeEleType[inType, i]
	offset = offset + typeEleAddr[inType, i]					' offset to this element
	ptrs = typeElePtr[inType, i]											' is this a pointer?
	lastElement = LastElement (token, @lastPlace, @excessComma)
	IF XERROR THEN EXIT FUNCTION

'	Get the component length (.a[] gives the size of the entire 1D array)

	SELECT CASE TRUE
		CASE (token{$$KIND} = $$KIND_ARRAY_SYMBOLS)
			oldTokenPtr = tokenPtr
			oldToken = token
			token = NextToken ()
			IF (token != T_LBRAK) THEN PRINT "ccc4": GOTO eeeComponent
			token = NextToken ()
			IF (token = T_RBRAK) THEN
				IFF lastElement THEN GOTO eeeSyntax
				length = typeEleSize[inType, i]			' Get length of entire array
				RETURN															' offset unchanged (point to [0])
			ELSE
				tokenPtr = oldTokenPtr
				token = oldToken
				IF (theType = $$STRING) THEN
					length = typeEleStringSize[inType, i]
				ELSE
					length = typeSize[theType]
				ENDIF
			ENDIF
		CASE ELSE
			IF (theType = $$STRING) THEN
				length = typeEleStringSize[inType, i]
			ELSE
				length = typeSize[theType]
			ENDIF
	END SELECT

	IFZ ptrs THEN
		IF lastElement THEN											' HANDLE valid only for pointers
			IF (command = $$GETHANDLE) THEN GOTO eeeSyntax
		ENDIF
	ELSE
'		IF (offset > 65535) THEN GOTO eeeOverflow
		IF lastElement THEN
			IF (command = $$GETHANDLE) THEN
				theType = $$XLONG
				tokenPtr = lastPlace									' point to end of last composite
				RETURN																' offset points to handle
			ENDIF
		ENDIF

		IFZ varToken THEN									' base is in an accumulator already
			sreg = regBase
		ELSE
			regBase = OpenAccForType ($$XLONG)			' open regBase accumulator
			nn = varToken{$$NUMBER}
			sreg = r_addr[nn]
			IFZ sreg THEN														' data is in memory
				Move (regBase, $$XLONG, nn, $$XLONG)	' move data into acc
				sreg = regBase
			ENDIF
			varToken = 0
		ENDIF

'		BOUNDS CHECKING:  blow up if contents of sreg = 0
'			(Add when including pointers...)

		Code ($$ld, $$regro, regBase, sreg, offset, $$XLONG, @"", @"	;;; i293")
		offset = 0

'		BOUNDS CHECKING:  blow up if contents of regBase = 0
'			(Add when including pointers...)

		i = 2
		DO UNTIL (i > ptrs)
			Code ($$ld, $$regr0, regBase, regBase, 0, $$XLONG, @"", @"	;;; i294")
			INC i
		LOOP
	ENDIF
	IF (token{$$KIND} != $$KIND_ARRAY_SYMBOLS) THEN	RETURN	' element not array

'	Array:

	IF ptrs THEN														' points to std array
		IF dim_array THEN GOTO eeeSyntax			' Can't dim internal composite array
		new_data = $$T_ARRAYS + regBase				' Kludge up ARRAYS token
		IF lastElement THEN										' Tested above
			SELECT CASE command									' HANDLE returns above
				CASE $$GETADDR, $$GETDATAADDR
						old_op = T_ADDR_OP
						old_prec = $$PREC_ADDR_OP
				CASE ELSE
						old_op = 0
						old_prec = 0
'																					' haveData outdated...ptrs only
						haveData = $$TRUE							' ExpressArray returns data
			END SELECT
		ELSE
			IF excessComma THEN GOTO eeeSyntax
			old_op = 0
			old_prec = 0
		ENDIF
		accArray = 'v'
		ExpressArray (old_op, old_prec, @new_data, @new_type, accArray, 0, theType, 0)
		IF XERROR THEN EXIT FUNCTION
		IF lastElement THEN
			IF (command = $$GETDATAADDR) THEN						' returns composite type
				IF excessComma THEN theType = new_type		'		unless excessComma
			ELSE
				theType = new_type
			ENDIF
		ELSE
			IF (new_type < $$SCOMPLEX) THEN GOTO eeeSyntax
		ENDIF
		regBase = Top ()															' new regBase is toes
		IF new_data THEN															' null array
			IF (new_data{$$NUMBER} != regBase) THEN GOTO eeeCompiler
		ENDIF
		RETURN
	ENDIF

'	imbedded array

	IF (theType = $$STRING) THEN
		aSize = typeEleStringSize[inType, i]
	ELSE
		aSize = typeSize[theType]				' size of element in array (aligned)
	ENDIF
'	IF (aSize > 65535) THEN GOTO eeeOverflow
	token = NextToken ()
	IF (token <> T_LBRAK) THEN PRINT "ccc5": GOTO eeeComponent
	arrayUBound = typeEleUBound[inType, i]

' 	fixedArray [expression]

	token = 0: new_data = 0: new_type = 0
	Expresso (0, @token, 0, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IFF q_type_long[new_type] THEN GOTO eeeTypeMismatch
	IF (token != T_RBRAK) THEN PRINT "eee5": GOTO eeeComponent
	IF new_data THEN												' simple token (regBase same)
		GOSUB CheckForLiteral
		IF gotLiteral THEN RETURN
		nn = new_data{$$NUMBER}
		regTemp = r_addr[nn]
		IF regTemp THEN												' value is in a register
			regIndex = regTemp
			regOffset = $$esi
		ELSE																	' value in memory
			Move ($$esi, $$XLONG, nn, $$XLONG)
			regIndex = $$esi
			regOffset = regIndex
		ENDIF
	ELSE
		IF varToken THEN												' base not in acc yet
			regIndex = Top ()											' expression in acc
		ELSE
			IF (toes <= 1) THEN GOTO eeeSyntax		' expression and base in acc
			Topaccs (@regIndex, @regBase)
		ENDIF
		regOffset = regIndex
	ENDIF

	IFZ varToken THEN									' base is in an accumulator already
		sreg = regBase
	ELSE
		regBase = OpenAccForType ($$XLONG)		' open regBase accumulator
		nn = varToken{$$NUMBER}
		regTemp = r_addr[nn]
		IF regTemp THEN														' data is in a register
			sreg = regTemp
		ELSE
			Move (regBase, $$XLONG, nn, $$XLONG)	' move data into acc
			sreg = regBase
		ENDIF
		varToken = 0
	ENDIF

	IF new_data THEN							' simple, no expression on stack
		newRegBase = regBase				' use old regBase
	ELSE													' remove expression from stack
		newRegBase = $$eax					' combine TOS + TOS-1 into r10
		DEC toes										' Free r12
		a1 = 0
		a1_type = 0
		a0 = toes
		a0_type = $$XLONG
	ENDIF

'	Bounds Check

	IF checkBounds THEN
		d1$ = CreateLabel$ ()
		Code ($$mov, $$regimm, $$ecx, arrayUBound, 0, $$XLONG, @"", @"	;;; i295")
		Code ($$cmp, $$regreg, $$ecx, regIndex, 0, $$XLONG, @"", @"	;;; i296")
		Code ($$jge, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i297")
		Code ($$mov, $$regreg, $$ecx, sreg, 0, $$XLONG, @"", @"	;;; i298")
		Code ($$xor, $$regreg, regIndex, regIndex, 0, $$XLONG, @"", @"	;;; i299")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_OutOfBounds", @"	;;; i300")
		EmitLabel (@d1$)
	ENDIF

	IF (aSize = 1) THEN
		regOffset = regIndex										' skipit:  multiplier is 1
	ELSE
		IF (regOffset != regIndex) THEN
			Code ($$mov, $$regreg, regOffset, regIndex, 0, $$XLONG, @"", @"	;;; i301")
		ENDIF
		IF (aSize <= 1024) THEN ashift = shiftMulti [aSize]
		IF ashift THEN
			Code ($$shl, $$regimm, regOffset, ashift, 0, $$XLONG, @"", @"	;;; i302a")
		ELSE
			Code ($$imul, $$regimm, regOffset, aSize, 0, $$XLONG, @"", @"	;;; i302b")
		ENDIF
	ENDIF

	Code ($$lea, $$regrr, newRegBase, sreg, regOffset, $$XLONG, @"", @"	;;; i303")
	regBase = newRegBase			' updated base pointer
	RETURN

SUB CheckForLiteral
	gotLiteral = $$FALSE
	SELECT CASE new_data{$$KIND}
		CASE $$KIND_LITERALS
			tt = new_data{$$NUMBER}
			arrayIndex = XLONG (tab_sym$[tt])		' literals may not be in r_addr yet
			IF (arrayIndex > arrayUBound) THEN
				GOTO eeeOverflow
			ENDIF
			offset = offset + arrayIndex * aSize
			gotLiteral = $$TRUE
		CASE $$KIND_CONSTANTS, $$KIND_SYSCONS
			tt = new_data{$$NUMBER}
			arrayIndex = XLONG (r_addr$[tt])
			IF (arrayIndex > arrayUBound) THEN
				GOTO eeeOverflow
			ENDIF
			offset = offset + arrayIndex * aSize
			gotLiteral = $$TRUE
	END SELECT
END SUB

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  Composite ()  #####
' ##########################

' *****  INPUT  *****				*****  RETURN VALUES  *****

' command = $$GETADDR:			command		= # of items stacked  (in RAx)
'														theType		= XLONG
'														theReg		= token or reg containing base address
'														theOffset	= offset from base address to data
' command = $$GETHANDLE:		command		= # of items stacked  (in RAx)
'														theType		= XLONG
'														theReg		= token or reg containing base addr
'														theOffset	= offset from base address to array handle
' command = $$GETDATAADDR:	command		= # of items stacked  (in RAx)
'														theType		= type of final component
'														theReg		= token or reg containing base addr
'														theOffset	= offset from base address to data
' command = $$GETDATA:			command		= # of items stacked  (in RAx)
'														theType		= type of final component
'														theReg		= reg containing data (addr if composite)
'														theOffset	= 0

' Notes:
'		subComposite == a composite expression including sub-element references
'   varComposite == a composite variable/array without sub-element references

'		Destination:  GETADDR invalid for varComposites/subComposites
'									GETHANDLE invalid for varComposites
'									GETHANDLE valid only for pointer sub-elements (to allow
'											assigning address to pointer)
'		Source:				(Composite() not called for source addr_ops on varComposites)
'					  			GETADDR valid for subComposites
'						 			GETHANDLE valid for pointer sub-elements in subComposites

'		NOTE:  error generated if theOffset > 65535

FUNCTION  Composite (command, theType, theReg, theOffset, theLength)
	SHARED	XERROR,  ERROR_COMPONENT,  ERROR_COMPILER
	SHARED	ERROR_OVERFLOW,  ERROR_SYNTAX
	SHARED	T_ADDR_OP,  T_HANDLE_OP,  T_LBRAK,  T_RBRAK
	SHARED	r_addr[],  typeSize[],  reg86$[],  reg86c$[]
	SHARED	tab_sym$[],  r_addr$[]
	SHARED	toes,  a0,  a0_type,  a1,  a1_type
	SHARED	oos,  dim_array,  tokenPtr
	SHARED	preType
	SHARED UBYTE oos[]

	theLength		= 0
	IF theReg THEN
		varToken	= theReg
		theType		= TheType (theReg)
		inType		= theType
		top				= $$FALSE
	ELSE
		top				= Top ()
		IFZ top THEN PRINT "Composite.doofus0": GOTO eeeCompiler
		IFZ theType THEN PRINT "Composite.doofus1": GOTO eeeCompiler
		varToken	= $$T_VARIABLES OR (theType << 16) OR top
		inType		= theType
	ENDIF
	theOffset	= 0
	check			= PeekToken ()

	IF (varToken{$$KIND} = $$KIND_ARRAYS) THEN
		IF dim_array THEN GOTO eeeSyntax
		new_data	= varToken
		new_type	= theType
		accArray	= $$FALSE
		node			= $$FALSE

' new_op and new_prec added below

		SELECT CASE command
			CASE $$GETHANDLE:		new_op = T_HANDLE_OP:	new_prec = $$PREC_ADDR_OP
			CASE $$GETADDR:			new_op = T_ADDR_OP:		new_prec = $$PREC_ADDR_OP
			CASE $$GETDATAADDR:	new_op = T_ADDR_OP:		new_prec = $$PREC_ADDR_OP
			CASE $$GETDATA:			new_op = 0:						new_prec = 0
		END SELECT

		ExpressArray (@new_op, @new_prec, @new_data, @new_type, accArray, @node, theType, 0)
		IF XERROR THEN EXIT FUNCTION
		IF node THEN
			command		= 1
			preType		= 0
			theType		= $$XLONG
			theReg		= Top ()
			theOffset	= 0
			theLength	= 0
			RETURN
		ENDIF
		new_type	= theType
		check			= PeekToken ()
		checkKind	= check{$$KIND}
		SELECT CASE checkKind
			CASE $$KIND_SYMBOLS, $$KIND_ARRAY_SYMBOLS		' subComposite
				IF new_data THEN GOTO eeeSyntax						' null array invalid
				regBase		= Top ()												' new regBase is toes
				varToken	= 0
			CASE ELSE																		' varComposite
				SELECT CASE command
					CASE $$GETADDR, $$GETHANDLE:	GOTO eeeSyntax
				END SELECT
				IFZ new_data THEN													' not null array
					regBase		= Top ()											' new regBase is toes
					varToken	= 0
				ENDIF
		END SELECT
	ENDIF
	preType = theType

com_process:
	theLength = typeSize[theType]
	DO
		checkKind = check{$$KIND}
		SELECT CASE checkKind
			CASE $$KIND_SYMBOLS, $$KIND_ARRAY_SYMBOLS
					check				= NextToken ()
					component		= $$TRUE
					preType			= theType
					Component (command, @varToken, @regBase, @theOffset, @theType, check, @theLength)
					IF XERROR THEN EXIT FUNCTION
					check				= PeekToken ()
			CASE ELSE
					component		= $$FALSE
		END SELECT
	LOOP WHILE (component)
'	IF (theOffset > 65535) THEN GOTO eeeOverflow

' Make sure base address is in a register
'		Note:  haveData can only be true with pointers...

	IFZ varToken THEN							' base moved to regBase register (ptr or [x])
		theReg	= regBase														' theReg = base & destination
		SELECT CASE command													' address or data ???
			CASE $$GETDATA														' data requested
				command = 1															' one thing stacked
				IF haveData THEN
					IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
					RETURN																' ExpressArray got data
				ENDIF
			CASE ELSE																	' address requested
				command = 1															' one thing stacked
				IFZ theLength THEN theLength = typeSize[theType]		' ??? xx2m ???
				RETURN																	' address requested
		END SELECT
	ELSE													' base still in varToken (simple offset)
		uu = varToken{$$NUMBER}											' token # or reg #
		regBase = r_addr[uu]												' regBase = base address reg
		IF regBase THEN
			SELECT CASE command												' address or data ???
				CASE $$GETDATA													' data requested
					IF top THEN
						theReg	= top												' already stacked
					ELSE
						theReg	= OpenAccForType (theType)	' theReg = destination
					ENDIF
					command	= 1														' one thing stacked
					IF haveData THEN RETURN								' ExpressArray got data
				CASE ELSE																' address requested
					theReg	= regBase											' theReg = base address
					IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
					command	= 0														' nothing stacked
					RETURN																' theOffset
			END SELECT
		ELSE																				' base address not in reg
			theReg	= OpenAccForType ($$XLONG)				' theReg = destination
			Move (theReg, $$XLONG, varToken, $$XLONG)
			SELECT CASE command												' address of data ???
				CASE $$GETDATA													' data requested
					command	= 1														' one thing stacked
					regBase	= theReg											' regBase = base address
					IF haveData THEN
						IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
						RETURN															' ExpressArray got data
					ENDIF
				CASE ELSE																' address requested
					command	= 1														' one thing stacked
					IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
					RETURN
			END SELECT
		ENDIF
	ENDIF


' *******************************
' *****  WANT DATA ELEMENT  *****
' *******************************

' regBase		= base address register
' theOffset	= offset from base address to data
' theReg		= register to contain data
'	theType		= data type of the component (simple or composite)


' *****  SIMPLE TYPE  *****  copy fixed string into native string

	IF (theType < $$SCOMPLEX) THEN
		IF (theType = $$STRING) THEN
			Code ($$lea, $$regro, theReg, regBase, theOffset, $$XLONG, @"", @"	;;; i308")
			Code ($$mov, $$regreg, $$esi, theReg, 0, $$XLONG, @"", @"	;;; i309")
			Code ($$mov, $$regimm, $$edi, theLength, 0, $$XLONG, @"", @"	;;; i310")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_CompositeStringToString", @"	;;; i311")
			Code ($$mov, $$regreg, theReg, $$esi, 0, $$XLONG, @"", @"	;;; i312")
			INC oos
			oos[oos] = 's'
		ELSE
			IF ((theType = $$SINGLE) OR (theType = $$DOUBLE) OR (theType = $$LONGDOUBLE)) THEN
				Code ($$fld, $$ro, theReg, regBase, theOffset, theType, @"", @"	;;; i313a")
			ELSE
				Code ($$ld, $$regro, theReg, regBase, theOffset, theType, @"", @"	;;; i313b")
			ENDIF
		ENDIF
		IF (theType < $$SLONG) THEN theType = $$SLONG
		SELECT CASE theReg
			CASE $$RA0	:	a0_type = theType
			CASE $$RA1	: a1_type = theType
			CASE ELSE		:	PRINT "cdrx" : GOTO eeeCompiler
		END SELECT
		theOffset = 0
		RETURN
	ENDIF

' *****  COMPOSITE TYPE  *****

	IF (theReg = regBase) THEN
		IFZ theOffset THEN RETURN
	ENDIF
	Code ($$lea, $$regro, theReg, regBase, theOffset, $$XLONG, @"", @"	;;; i314")
	theOffset = 0
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
END FUNCTION


' #####################
' #####  Conv ()  #####
' #####################

FUNCTION  Conv (destin, to_type, source, from_type)
	SHARED	reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH
	SHARED	ERROR_UNIMPLEMENTED,  ERROR_VOID
	SHARED	a0_type,  a1_type,  labelNumber
	STATIC GOADDR  convToType[]
	STATIC GOADDR  convToType2[]
	STATIC GOADDR  convToType3[]
	STATIC GOADDR  convToType4[]
	STATIC GOADDR  convToType5[]
	STATIC GOADDR  convToType6[]
	STATIC GOADDR  convToType7[]
	STATIC GOADDR  convToType8[]
	STATIC GOADDR  convToType9[]
	STATIC GOADDR  convToTypea[]
	STATIC GOADDR  convToTypeb[]
	STATIC GOADDR  convToTypec[]
	STATIC GOADDR  convToTyped[]
	STATIC GOADDR  convToTypee[]
	STATIC GOADDR  convToTypef[]
	STATIC GOADDR  convToTypes[]

	IFZ convToType[] THEN
		GOSUB LoadConvToType
		GOSUB LoadConvToType2
		GOSUB LoadConvToType3
		GOSUB LoadConvToType4
		GOSUB LoadConvToType5
		GOSUB LoadConvToType6
		GOSUB LoadConvToType7
		GOSUB LoadConvToType8
		GOSUB LoadConvToType9
		GOSUB LoadConvToTypea
		GOSUB LoadConvToTypeb
		GOSUB LoadConvToTypec
		GOSUB LoadConvToTyped
		GOSUB LoadConvToTypee
		GOSUB LoadConvToTypef
		GOSUB LoadConvToTypes
	ENDIF

	tt = to_type
	ft = from_type
	IF (ft < $$SLONG) THEN ft = $$SLONG
	IFZ tt THEN tt = ft
	d_reg   = Reg (destin)
	d_regx  = d_reg + 1
	IFZ d_reg THEN PRINT "conv1": GOTO eeeCompiler
	IF (d_reg = $$RA0) THEN a0_type = tt
	IF (d_reg = $$RA1) THEN a1_type = tt

cs:
	s_reg   = Reg (source)
	s_regx  = s_reg + 1
	IFZ s_reg THEN PRINT "conv2": GOTO eeeCompiler
	IF (tt = ft) THEN
		IF (d_reg = s_reg) THEN RETURN
		Move (d_reg, tt, source, ft)
		EXIT FUNCTION
	ENDIF
	IF ((tt >= $$SCOMPLEX) OR (ft >= $$SCOMPLEX)) THEN GOTO eeeTypeMismatch

	IF Literal (s_reg) THEN
		IF ((ft = $$DOUBLE) OR (ft = $$GIANT)) THEN
			IF ((tt != $$DOUBLE) AND (tt != $$GIANT)) THEN
				Move ($$esi, ft, source, ft)
				s_reg   = $$esi
				s_regx  = $$edi
			ELSE
				Move (d_reg, ft, source, ft)
				s_reg   = d_reg
				s_regx  = d_regx
				s_reg$  = d_reg$
				s_regx$ = d_regx$
			ENDIF
		ELSE
			Move (d_reg, ft, source, ft)
			s_reg   = d_reg
			s_regx  = d_regx
			s_reg$  = d_reg$
			s_regx$ = d_regx$
		ENDIF
	ENDIF

' *****  Dispatch to routine to convert to type "tt"  *****

	GOTO @convToType[tt]
	PRINT "conv3"
	GOTO eeeCompiler


' **************************************************************
' *****  Emit code to convert from type "ft" to type "tt"  *****
' **************************************************************

' ********************************
' *****  to SBYTE from "tt"  *****
' ********************************

tt2:
	GOTO @convToType2[ft]
	PRINT "conv4"
	GOTO eeeCompiler


' *****  to SBYTE from SLONG  *****

tt2ft6:
tt2ft8:
	d1$ = CreateLabel$ ()
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i315")
	Code ($$sar, $$regimm, $$esi, 7, 0, $$XLONG, @"", @"	;;; i316")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i317")
	Code ($$not, $$reg, $$esi, 0, 0, $$XLONG, @"", @"	;;; i318")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i319")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i320")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to SBYTE from ULONG  *****

tt2ft7:
	d1$ = CreateLabel$ ()
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i321")
	Code ($$sar, $$regimm, $$esi, 7, 0, $$XLONG, @"", @"	;;; i322")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i323")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i324")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to SBYTE from SINGLE  *****

tt2ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i325")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i326")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt2ft6

' *****  to SBYTE from DOUBLE  *****

tt2ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i327")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i328")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt2ft6

' *****  to SBYTE from GIANT  *****

tt2fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	GOTO tt2ft6

' *****  to SBYTE from LONGDOUBLE  *****

tt2ftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i328a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i328b")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt2ft6


' ********************************
' *****  to UBYTE from "tt"  *****
' ********************************

tt3:
	GOTO @convToType3[ft]
	PRINT "conv5"
	GOTO eeeCompiler

' *****  to UBYTE from SLONG
' *****  to UBYTE from ULONG

tt3ft6:
tt3ft7:
tt3ft8:
	d1$ = CreateLabel$ ()
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i329")
	Code ($$sar, $$regimm, $$esi, 8, 0, $$XLONG, @"", @"	;;; i330")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i331")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i332")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to UBYTE from SINGLE  *****

tt3ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i333")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i334")
	ft		= $$SLONG
	s_reg	= d_reg
	GOTO tt3ft6

' *****  to UBYTE from DOUBLE  *****

tt3ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i335")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i336")
	ft		= $$SLONG
	s_reg	= d_reg
	GOTO tt3ft6

' *****  to UBYTE from GIANT  *****

tt3fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	s_reg$ = d_reg$
	GOTO tt3ft6

' *****  to UBYTE from LONGDOUBLE  *****

tt3ftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i336a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i336b")
	ft		= $$SLONG
	s_reg	= d_reg
	GOTO tt3ft6


' *********************************
' *****  to SSHORT from "tt"  *****
' *********************************

tt4:
	GOTO @convToType4[ft]
	PRINT "conv6"
	GOTO eeeCompiler

tt4ft6:
tt4ft8:
	d1$ = CreateLabel$ ()
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i337")
	Code ($$sar, $$regimm, $$esi, 15, 0, $$XLONG, @"", @"	;;; i338")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i339")
	Code ($$not, $$reg, $$esi, 0, 0, $$XLONG, @"", @"	;;; i340")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i341")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i342")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to SSHORT from ULONG  *****

tt4ft7:
	d1$ = CreateLabel$ ()
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i343")
	Code ($$sar, $$regimm, $$esi, 15, 0, $$XLONG, @"", @"	;;; i344")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i345")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i346")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to SSHORT from SINGLE  *****

tt4ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i347")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i348")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt4

' *****  to SSHORT from DOUBLE  *****

tt4ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i349")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i350")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt4

' *****  to SSHORT from GIANT  *****

tt4fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	GOTO tt4

' *****  to SSHORT from LONGDOUBLE  *****

tt4ftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i350a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i350b")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt4


' *********************************
' *****  to USHORT from "tt"  *****
' *********************************

tt5:
	GOTO @convToType5[ft]
	PRINT "conv7"
	GOTO eeeCompiler

' *****  to USHORT from SLONG  *****
' *****  to USHORT from ULONG  *****
' *****  to USHORT from XLONG  *****

tt5ft6:
tt5ft7:
tt5ft8:
	d1$ = CreateLabel$ ()
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i351")
	Code ($$sar, $$regimm, $$esi, 16, 0, $$XLONG, @"", @"	;;; i352")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i353")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i354")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN


' *****  to USHORT from SINGLE  *****

tt5ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i355")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i356")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt5

' *****  to USHORT from DOUBLE  *****

tt5ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i357")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i358")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt5

' *****  to USHORT from GIANT  *****

tt5fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	GOTO tt5

' *****  to USHORT from LONGDOUBLE  *****

tt5ftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i358a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i358b")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt5


' ********************************
' *****  to SLONG from "tt"  *****
' ********************************

tt6:
	GOTO @convToType6[ft]
	PRINT "conv8"
	GOTO eeeCompiler

' *****  to SLONG from SLONG  *****

tt6ft6:
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to SLONG from ULONG  *****

tt6ft7:
	d1$ = CreateLabel$ ()
	Code ($$or, $$regreg, s_reg, s_reg, 0, $$XLONG, @"", @"	;;; i359")
	Code ($$jns, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i360")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i361")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to SLONG from XLONG  *****

tt6ft8:
	Move(d_reg, ft, s_reg, ft)
	RETURN

' *****  to SLONG from SINGLE  *****

tt6ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i362")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i363")
	RETURN

' *****  to SLONG from DOUBLE  *****

tt6ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i364")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i365")
	RETURN

' *****  to SLONG from GIANT  *****

tt6fte:
	GOSUB cv_giant_to_slong
	RETURN

' *****  to SLONG from LONGDOUBLE  *****

tt6ftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i365a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i365b")
	RETURN


' ********************************
' *****  to ULONG from "tt"  *****
' ********************************

tt7:
	GOTO @convToType7[ft]
	PRINT "conv9"
	GOTO eeeCompiler

' *****  to ULONG from SLONG  *****

tt7ft6:
	d1$ = CreateLabel$ ()
	Code ($$or, $$regreg, s_reg, s_reg, 0, $$XLONG, @"", @"	;;; i366")
	Code ($$jns, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i367")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i368")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to ULONG from ULONG  *****
' *****  to ULONG from XLONG  *****

tt7ft7:
tt7ft8:
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to ULONG from SINGLE  *****

tt7ftc:
	d1$ = CreateLabel$ ()
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i369")
	Code ($$ld, $$regro, d_reg, $$ebp, -4, $$XLONG, @"", @"	;;; i370")
	Code ($$test, $$regreg, d_reg, d_reg, 0, $$XLONG, @"", @"	;;; i371")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i372")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i373")
	EmitLabel (@d1$)
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i374")
	RETURN

' *****  to ULONG from DOUBLE  *****

tt7ftd:
	d1$ = CreateLabel$ ()
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i375")
	Code ($$ld, $$regro, d_reg, $$ebp, -4, $$XLONG, @"", @"	;;; i376")
	Code ($$test, $$regreg, d_reg, d_reg, 0, $$XLONG, @"", @"	;;; i377")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i378")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i379")
	EmitLabel (@d1$)
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i380")
	RETURN

' *****  to ULONG from GIANT  *****

tt7fte:
	d1$ = CreateLabel$ ()
	Code ($$test, $$regreg, s_regx, s_regx, 0, $$XLONG, @"", @"	;;; i381")
	Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, @"", @"	;;; i382")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i383")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i384")
	EmitLabel (@d1$)
	RETURN

' *****  to ULONG from LONGDOUBLE  *****

tt7ftf:
	d1$ = CreateLabel$ ()
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i384a")
	Code ($$ld, $$regro, d_reg, $$ebp, -4, $$XLONG, @"", @"	;;; i3384b")
	Code ($$test, $$regreg, d_reg, d_reg, 0, $$XLONG, @"", @"	;;; i3384c")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i3384d")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i3384e")
	EmitLabel (@d1$)
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i3384f")
	RETURN


' ********************************
' *****  to XLONG from "tt"  *****
' ********************************

tt8:
	GOTO @convToType8[ft]
	PRINT "conv10"
	GOTO eeeCompiler

' *****  to XLONG from SLONG  *****
' *****  to XLONG from ULONG  *****
' *****  to XLONG from XLONG  *****
' *****  to XLONG from GOADDR  *****
' *****  to XLONG from SUBADDR  *****
' *****  to XLONG from FUNCADDR  *****

tt8ft6:
tt8ft7:
tt8ft8:
tt8ft9:
tt8fta:
tt8ftb:
	Move (d_reg, ft, s_reg, ft)
	RETURN

' *****  to XLONG from SINGLE  *****

tt8ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i385")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i386")
	RETURN

' *****  to XLONG from DOUBLE  *****

tt8ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i387")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i388")
	RETURN

' *****  to XLONG from GIANT  *****

tt8fte:
	GOSUB cv_giant_to_slong
	RETURN

' *****  to XLONG from LONGDOUBLE  *****

tt8ftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i388a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i388b")
	RETURN


' *********************************
' *****  to GOADDR from "tt"  *****
' *********************************

tt9:
	GOTO @convToType9[ft]
	PRINT "conv11"
	GOTO eeeCompiler

' *****  to GOADDR from XLONG  *****

tt9ft8:
	Move (d_reg, tt, s_reg, tt)
	RETURN

' *****  to GOADDR from GOADDR  *****

tt9ft9:
	Move (d_reg, tt, s_reg, tt)
	RETURN


' **********************************
' *****  to SUBADDR from "tt"  *****
' **********************************

tta:
	GOTO @convToTypea[ft]
	PRINT "conv12"
	GOTO eeeCompiler

' *****  to SUBADDR from XLONG  *****

ttaft8:
	Move (d_reg, tt, s_reg, tt)
	RETURN

' *****  to SUBADDR from SUBADDR  *****

ttafta:
	Move (d_reg, tt, s_reg, tt)
	RETURN


' ***********************************
' *****  to FUNCADDR from "tt"  *****
' ***********************************

ttb:
	GOTO @convToTypeb[ft]
	PRINT "conv13"
	GOTO eeeCompiler

' *****  to FUNCADDR from XLONG  *****

ttbft8:
	Move (d_reg, tt, s_reg, tt)
	RETURN

' *****  to FUNCADDR from FUNCADDR  *****

ttbftb:
	Move (d_reg, tt, s_reg, tt)
	RETURN


' *********************************
' *****  to SINGLE from "tt"  *****
' *********************************

ttc:
	GOTO @convToTypec[ft]
	PRINT "conv14"
	GOTO eeeCompiler

' *****  to SINGLE from SLONG  *****
' *****  to SINGLE from XLONG  *****

ttcft6:
ttcft8:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i389")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$SLONG, @"", @"	;;; i390")
	RETURN

' *****  to SINGLE from ULONG  *****

ttcft7:
	d1$ = CreateLabel$ ()
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i392")
	Code ($$st, $$roimm, 0, $$ebp, -4, $$XLONG, @"", @"	;;; i391")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i393")
	EmitLabel (@d1$)
	RETURN

' *****  to SINGLE from SINGLE  *****

ttcftc:
	Move (d_reg, tt, s_reg, tt)
	RETURN

' *****  to SINGLE from DOUBLE  *****

ttcftd:
	RETURN

' *****  to SINGLE from GIANT  *****

ttcfte:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i394")
	Code ($$st, $$roreg, s_regx, $$ebp, -4, $$XLONG, @"", @"	;;; i395")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i396")
	RETURN

' *****  to SINGLE from LONGDOUBLE  *****

ttcftf:
	RETURN


' *********************************
' *****  to DOUBLE from "tt"  *****
' *********************************

ttd:
	GOTO @convToTyped[ft]
	PRINT "conv15"
	GOTO eeeCompiler

' *****  to DOUBLE from SLONG  *****
' *****  to DOUBLE from XLONG  *****

ttdft6:
ttdft8:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i397")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$XLONG, @"", @"	;;; i398")
	RETURN

' *****  to DOUBLE from ULONG  *****

ttdft7:
	d1$ = CreateLabel$ ()
	Code ($$st, $$roimm, 0, $$ebp, -4, $$XLONG, @"", @"	;;; i399")
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i400")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i401")
	EmitLabel (@d1$)
	RETURN

' *****  to DOUBLE from SINGLE  *****

ttdftc:
	RETURN

' *****  to DOUBLE from DOUBLE  *****

ttdftd:
	RETURN

' *****  to DOUBLE from GIANT  *****

ttdfte:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i402")
	Code ($$st, $$roreg, s_regx, $$ebp, -4, $$XLONG, @"", @"	;;; i403")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i404")
	RETURN

' *****  to DOUBLE from LONGDOUBLE  *****
ttdftf:
	RETURN


' ********************************
' *****  to GIANT from "tt"  *****
' ********************************

tte:
	GOTO @convToTypee[ft]
	PRINT "conv16"
	GOTO eeeCompiler

' *****  to GIANT from SLONG  *****
' *****  to GIANT from XLONG  *****

tteft6:
tteft8:
	IF (d_reg != s_reg) THEN Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, @"", @"	;;; i405")
	IF (d_regx != s_reg) THEN Code ($$mov, $$regreg, d_regx, s_reg, 0, $$XLONG, @"", @"	;;; i406")
	Code ($$sar, $$regimm, d_regx, 31, 0, $$XLONG, @"", @"	;;; i407")
	RETURN

' *****  to GIANT from ULONG  *****

tteft7:
	IF (d_reg != s_reg) THEN Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, @"", @"	;;; i408")
	Code ($$xor, $$regreg, d_regx, d_regx, 0, $$XLONG, @"", @"	;;; i409")
	RETURN

' *****  to GIANT from SINGLE  *****

tteftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i410")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i411")
	Code ($$ld, $$regro, d_regx, $$ebp, -4, $$XLONG, @"", @"	;;; i412")
	RETURN

' *****  to GIANT from DOUBLE  *****

tteftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i412a")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i412b")
	Code ($$ld, $$regro, d_regx, $$ebp, -4, $$XLONG, @"", @"	;;; i412c")
	RETURN

'	*****  to GIANT from GIANT  *****

ttefte:
	IF (d_reg != s_reg) THEN Move (d_reg, $$GIANT, s_reg, $$GIANT)
	RETURN

' ***** to GIANT from LONGDOUBLE *****
tteftf:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i413")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i414")
	Code ($$ld, $$regro, d_regx, $$ebp, -4, $$XLONG, @"", @"	;;; i415")
	RETURN


' *********************************
' *****  to STRING from "tt"  *****
' *********************************

tts:
	GOTO @convToTypes[ft]
	PRINT "conv17"
	GOTO eeeCompiler

ttsfts:
	Move (d_reg, $$STRING, s_reg, $$STRING)
	RETURN


' *************************************
' *****  to LONGDOUBLE from "tt"  *****
' *************************************

ttf:
	GOTO @convToTypef[ft]
	PRINT "conv18"
	GOTO eeeCompiler

' *****  to LONGDOUBLE from SLONG  *****
' *****  to LONGDOUBLE from XLONG  *****

ttfft6:
ttfft8:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i415a")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$XLONG, @"", @"	;;; i415b")
	RETURN

' *****  to LONGDOUBLE from ULONG  *****

ttfft7:
	d1$ = CreateLabel$ ()
	Code ($$st, $$roimm, 0, $$ebp, -4, $$XLONG, @"", @"	;;; i415c")
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i415d")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i415e")
	EmitLabel (@d1$)
	RETURN

' *****  to LONGDOUBLE from SINGLE  *****

ttfftc:
	RETURN

' *****  to LONGDOUBLE from DOUBLE  *****

ttfftd:
	RETURN

' *****  to LONGDOUBLE from GIANT  *****

ttffte:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, @"", @"	;;; i415f")
	Code ($$st, $$roreg, s_regx, $$ebp, -4, $$XLONG, @"", @"	;;; i415g")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, @"", @"	;;; i415h")
	RETURN

' *****  to LONGDOUBLE from LONGDOUBLE  *****

ttfftf:
	RETURN


' *****************************************
' *****  TYPE CONVERSION SUBROUTINES  *****
' *****************************************

' *****  GIANT  to  SLONG  *****  subroutine used by several other conversions

SUB  cv_giant_to_slong
	d1$ = CreateLabel$ ()
	d2$ = CreateLabel$ ()
	IF (d_reg != s_reg) THEN Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, @"", @"	;;; i416")
	Code ($$or, $$regreg, s_reg, s_reg, 0, $$XLONG, @"", @"	;;; i417")
	Code ($$jns, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i418")
	Code ($$not, $$reg, s_regx, 0, 0, $$XLONG, @"", @"	;;; i419")
	EmitLabel (@d1$)
	Code ($$test, $$regreg, s_regx, s_regx, 0, $$XLONG, @"", @"	;;; i420")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i421a")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i421b")
	EmitLabel (@d2$)
END SUB



' *****************************************************
' *****  Load conversion from/to dispatch arrays  *****
' *****************************************************

SUB LoadConvToType
	DIM convToType[31]
	convToType [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType [ $$SBYTE		] = GOADDRESS (tt2)
	convToType [ $$UBYTE		] = GOADDRESS (tt3)
	convToType [ $$SSHORT		] = GOADDRESS (tt4)
	convToType [ $$USHORT		] = GOADDRESS (tt5)
	convToType [ $$SLONG		] = GOADDRESS (tt6)
	convToType [ $$ULONG		] = GOADDRESS (tt7)
	convToType [ $$XLONG		] = GOADDRESS (tt8)
	convToType [ $$GOADDR		] = GOADDRESS (tt9)
	convToType [ $$SUBADDR	] = GOADDRESS (tta)
	convToType [ $$FUNCADDR	] = GOADDRESS (ttb)
	convToType [ $$SINGLE		] = GOADDRESS (ttc)
	convToType [ $$DOUBLE		] = GOADDRESS (ttd)
	convToType [ $$GIANT		] = GOADDRESS (tte)
	convToType [$$LONGDOUBLE] = GOADDRESS (ttf)
	convToType [ $$STRING		] = GOADDRESS (tts)

END SUB

SUB LoadConvToType2
	DIM convToType2[31]
	convToType2 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType2 [ $$SLONG			] = GOADDRESS (tt2ft6)
	convToType2 [ $$ULONG			] = GOADDRESS (tt2ft7)
	convToType2 [ $$XLONG			] = GOADDRESS (tt2ft8)
	convToType2 [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType2 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType2 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType2 [ $$SINGLE		] = GOADDRESS (tt2ftc)
	convToType2 [ $$DOUBLE		] = GOADDRESS (tt2ftd)
	convToType2 [ $$GIANT			] = GOADDRESS (tt2fte)
	convToType2 [$$LONGDOUBLE ] = GOADDRESS (tt2ftf)
	convToType2 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType3
	DIM convToType3[31]
	convToType3 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType3 [ $$SLONG			] = GOADDRESS (tt3ft6)
	convToType3 [ $$ULONG			] = GOADDRESS (tt3ft7)
	convToType3 [ $$XLONG			] = GOADDRESS (tt3ft8)
	convToType3 [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType3 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType3 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType3 [ $$SINGLE		] = GOADDRESS (tt3ftc)
	convToType3 [ $$DOUBLE		] = GOADDRESS (tt3ftd)
	convToType3 [ $$GIANT			] = GOADDRESS (tt3fte)
	convToType3 [$$LONGDOUBLE ] = GOADDRESS (tt3ftf)
	convToType3 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType4
	DIM convToType4[31]
	convToType4 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType4 [ $$SLONG			] = GOADDRESS (tt4ft6)
	convToType4 [ $$ULONG			] = GOADDRESS (tt4ft7)
	convToType4 [ $$XLONG			] = GOADDRESS (tt4ft8)
	convToType4 [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType4 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType4 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType4 [ $$SINGLE		] = GOADDRESS (tt4ftc)
	convToType4 [ $$DOUBLE		] = GOADDRESS (tt4ftd)
	convToType4 [ $$GIANT			] = GOADDRESS (tt4fte)
	convToType4 [$$LONGDOUBLE ] = GOADDRESS (tt4ftf)
	convToType4 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType5
	DIM convToType5[31]
	convToType5 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType5 [ $$SLONG			] = GOADDRESS (tt5ft6)
	convToType5 [ $$ULONG			] = GOADDRESS (tt5ft7)
	convToType5 [ $$XLONG			] = GOADDRESS (tt5ft8)
	convToType5 [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType5 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType5 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType5 [ $$SINGLE		] = GOADDRESS (tt5ftc)
	convToType5 [ $$DOUBLE		] = GOADDRESS (tt5ftd)
	convToType5 [ $$GIANT			] = GOADDRESS (tt5fte)
	convToType5 [$$LONGDOUBLE ] = GOADDRESS (tt5ftf)
	convToType5 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType6
	DIM convToType6[31]
	convToType6 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType6 [ $$SLONG			] = GOADDRESS (tt6ft6)
	convToType6 [ $$ULONG			] = GOADDRESS (tt6ft7)
	convToType6 [ $$XLONG			] = GOADDRESS (tt6ft8)
	convToType6 [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType6 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType6 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType6 [ $$SINGLE		] = GOADDRESS (tt6ftc)
	convToType6 [ $$DOUBLE		] = GOADDRESS (tt6ftd)
	convToType6 [ $$GIANT			] = GOADDRESS (tt6fte)
	convToType6 [$$LONGDOUBLE ] = GOADDRESS (tt6ftf)
	convToType6 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType7
	DIM convToType7[31]
	convToType7 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType7 [ $$SLONG			] = GOADDRESS (tt7ft6)
	convToType7 [ $$ULONG			] = GOADDRESS (tt7ft7)
	convToType7 [ $$XLONG			] = GOADDRESS (tt7ft8)
	convToType7 [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType7 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType7 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType7 [ $$SINGLE		] = GOADDRESS (tt7ftc)
	convToType7 [ $$DOUBLE		] = GOADDRESS (tt7ftd)
	convToType7 [ $$GIANT			] = GOADDRESS (tt7fte)
	convToType7 [$$LONGDOUBLE ] = GOADDRESS (tt7ftf)
	convToType7 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType8
	DIM convToType8[31]
	convToType8 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType8 [ $$SLONG			] = GOADDRESS (tt8ft6)
	convToType8 [ $$ULONG			] = GOADDRESS (tt8ft7)
	convToType8 [ $$XLONG			] = GOADDRESS (tt8ft8)
	convToType8 [ $$GOADDR		] = GOADDRESS (tt8ft9)
	convToType8 [ $$SUBADDR		] = GOADDRESS (tt8fta)
	convToType8 [ $$FUNCADDR	] = GOADDRESS (tt8ftb)
	convToType8 [ $$SINGLE		] = GOADDRESS (tt8ftc)
	convToType8 [ $$DOUBLE		] = GOADDRESS (tt8ftd)
	convToType8 [ $$GIANT			] = GOADDRESS (tt8fte)
	convToType8 [$$LONGDOUBLE ] = GOADDRESS (tt8ftf)
	convToType8 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToType9
	DIM convToType9[31]
	convToType9 [ $$VOID			] = GOADDRESS (eeeVoid)
	convToType9 [ $$SLONG			] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$ULONG			] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$XLONG			] = GOADDRESS (tt9ft8)
	convToType9 [ $$GOADDR		] = GOADDRESS (tt9ft9)
	convToType9 [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$SINGLE		] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$DOUBLE		] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$GIANT			] = GOADDRESS (eeeTypeMismatch)
	convToType9 [$$LONGDOUBLE ] = GOADDRESS (eeeTypeMismatch)
	convToType9 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTypea
	DIM convToTypea[31]
	convToTypea [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTypea [ $$SLONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$ULONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$XLONG			] = GOADDRESS (ttaft8)
	convToTypea [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$SUBADDR		] = GOADDRESS (ttafta)
	convToTypea [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$SINGLE		] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$DOUBLE		] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$GIANT			] = GOADDRESS (eeeTypeMismatch)
	convToTypea [$$LONGDOUBLE ] = GOADDRESS (eeeTypeMismatch)
	convToTypea [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTypeb
	DIM convToTypeb[31]
	convToTypeb [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTypeb [ $$SLONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$ULONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$XLONG			] = GOADDRESS (ttbft8)
	convToTypeb [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$FUNCADDR	] = GOADDRESS (ttbftb)
	convToTypeb [ $$SINGLE		] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$DOUBLE		] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$GIANT			] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [$$LONGDOUBLE ] = GOADDRESS (eeeTypeMismatch)
	convToTypeb [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTypec
	DIM convToTypec[31]
	convToTypec [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTypec [ $$SLONG			] = GOADDRESS (ttcft6)
	convToTypec [ $$ULONG			] = GOADDRESS (ttcft7)
	convToTypec [ $$XLONG			] = GOADDRESS (ttcft8)
	convToTypec [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypec [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypec [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToTypec [ $$SINGLE		] = GOADDRESS (ttcftc)
	convToTypec [ $$DOUBLE		] = GOADDRESS (ttcftd)
	convToTypec [ $$GIANT			] = GOADDRESS (ttcfte)
	convToTypec [$$LONGDOUBLE ] = GOADDRESS (ttcftf)
	convToTypec [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTyped
	DIM convToTyped[31]
	convToTyped [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTyped [ $$SLONG			] = GOADDRESS (ttdft6)
	convToTyped [ $$ULONG			] = GOADDRESS (ttdft7)
	convToTyped [ $$XLONG			] = GOADDRESS (ttdft8)
	convToTyped [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTyped [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTyped [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToTyped [ $$SINGLE		] = GOADDRESS (ttdftc)
	convToTyped [ $$DOUBLE		] = GOADDRESS (ttdftd)
	convToTyped [ $$GIANT			] = GOADDRESS (ttdfte)
	convToTypec [$$LONGDOUBLE ] = GOADDRESS (ttdftf)
	convToTyped [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTypee
	DIM convToTypee[31]
	convToTypee [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTypee [ $$SLONG			] = GOADDRESS (tteft6)
	convToTypee [ $$ULONG			] = GOADDRESS (tteft7)
	convToTypee [ $$XLONG			] = GOADDRESS (tteft8)
	convToTypee [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypee [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypee [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToTypee [ $$SINGLE		] = GOADDRESS (tteftc)
	convToTypee [ $$DOUBLE		] = GOADDRESS (tteftd)
	convToTypee [ $$GIANT			] = GOADDRESS (ttefte)
	convToTypec [$$LONGDOUBLE ] = GOADDRESS (tteftf)
	convToTypee [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTypef
	DIM convToTypef[31]
	convToTypef [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTypef [ $$SLONG			] = GOADDRESS (ttfft6)
	convToTypef [ $$ULONG			] = GOADDRESS (ttfft7)
	convToTypef [ $$XLONG			] = GOADDRESS (ttfft8)
	convToTypef [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypef [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypef [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToTypef [ $$SINGLE		] = GOADDRESS (ttfftc)
	convToTypef [ $$DOUBLE		] = GOADDRESS (ttfftd)
	convToTypef [ $$GIANT			] = GOADDRESS (ttffte)
	convToTypec [$$LONGDOUBLE ] = GOADDRESS (ttfftf)
	convToTypef [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB

SUB LoadConvToTypes
	DIM convToTypes[31]
	convToTypes [ $$VOID			] = GOADDRESS (eeeVoid)
	convToTypes [ $$SLONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$ULONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$XLONG			] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$GOADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$SUBADDR		] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$FUNCADDR	] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$SINGLE		] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$DOUBLE		] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$GIANT			] = GOADDRESS (eeeTypeMismatch)
	convToTypes [$$LONGDOUBLE ] = GOADDRESS (eeeTypeMismatch)
	convToTypes [ $$STRING		] = GOADDRESS (ttsfts)
END SUB



'  *******************************
'  *****  CONVERSION ERRORS  *****
'  *******************************

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeTypeMismatch:
'PRINT "Conv() : eeeTypeMismatch"
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION

eeeVoid:
	XERROR = ERROR_VOID
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  Deallocate ()  #####
' ###########################

FUNCTION  Deallocate (token)
	SHARED	reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	m_addr[]
	SHARED	ebx_zeroed

	IFZ m_addr[token{$$NUMBER}] THEN RETURN
	otype	= TheType (token)
	kind	= token{$$KIND}

	IFF (ebx_zeroed) THEN
		Code ($$xor, $$regreg, $$ebx, $$ebx, 0, $$XLONG, @"", @"	;;; i422")
		ebx_zeroed = $$TRUE
	ENDIF

	SELECT CASE kind
		CASE $$KIND_VARIABLES, $$KIND_CONSTANTS
			Move ($$esi, otype, token, otype)
			Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i423")
		CASE $$KIND_ARRAYS
			Move ($$esi, $$XLONG, token, $$XLONG)
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_FreeArray", @"	;;; i424")
		CASE ELSE
			PRINT "dd1"
			GOTO eeeCompiler
	END SELECT
	Move (token, $$XLONG, $$ebx, $$XLONG)
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #########################
' #####  Deparse$ ()  #####
' #########################

' charpos[] = character position of tokens, 0 offset

FUNCTION  Deparse$ (prefix$)
	SHARED	charpos[],  tokens[]
	SHARED	funcSymbol$[],  tab_lab$[],  tab_sym$[],  tab_sys$[]
	SHARED	typeSymbol$[]
	SHARED	ERROR_COMPILER,  XERROR,  tokenCount,  tokenPtr
	STATIC SUBADDR  kindDeparse[]

	IFZ kindDeparse[] THEN GOSUB LoadKindDeparse

	tokenPtr		= -1
	charpos[0]	= 0
	deparsed$		= prefix$
	DO WHILE (tokenPtr < tokenCount)
		INC tokenPtr
		token		= tokens[tokenPtr]
		tt			= token{$$NUMBER}
		kind		= token{$$KIND}
		spaces	= token{{$$SPACE}}
		IF (spaces > 0) THEN
			whiteChar = 32			' spaces
		ELSE
			whiteChar = 9				' tabs
			spaces = -spaces
		ENDIF
		GOSUB @kindDeparse [kind]				' dispatch deparse based on kind of token
		IF (tokenPtr < 255) THEN charpos[tokenPtr + 1] = LEN(deparsed$)
	LOOP
	IF (tokenPtr < 254) THEN charpos[tokenPtr + 2] = 0
	RETURN (deparsed$)


' ****************************************************************
' *****  Subroutines to deparse different "kinds" of tokens  *****
' ****************************************************************

SUB SystemSymbols
	deparsed$ = deparsed$ + tab_sys$[tt] + CHR$(whiteChar, spaces)
END SUB

SUB UserSymbols
	deparsed$ = deparsed$ + tab_sym$[tt] + CHR$(whiteChar, spaces)
END SUB

SUB FunctionSymbols
	deparsed$ = deparsed$ + funcSymbol$[tt] + CHR$(whiteChar, spaces)
END SUB

SUB UserLabels
	s$ = MID$(tab_lab$[tt], 4)
	suffix = INSTR (s$, "%")
	s$ = LEFT$(s$, suffix - 1)
	IF (tokenPtr = 1) THEN s$ = s$ + ":"
	deparsed$ = deparsed$ + s$ + CHR$(whiteChar, spaces)
END SUB

SUB SystemStarts
	errorIndex = token {$$BYTE1}												' errno is BYTE1
	IF errorIndex THEN
		deparsed$ = deparsed$ + RIGHT$("000" + STRING(errorIndex), 3)
	ENDIF
	IF EXTS(token, 1, 30) THEN deparsed$ = deparsed$ + ">"	' $$CURRENTEXE
	IF (token < 0) THEN deparsed$ = deparsed$ + ":"					' $$BREAKPOINT
	spaces = token{{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			deparsed$ = deparsed$ + SPACE$(spaces)			' spaces
		ELSE
			deparsed$ = deparsed$ + CHR$ (9, -spaces)		' tabs
		ENDIF
	ENDIF
END SUB

SUB SystemWhites
	spaces = token{{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			deparsed$ = deparsed$ + SPACE$(spaces)			' spaces
		ELSE
			deparsed$ = deparsed$ + CHR$ (9, -spaces)		' tabs
	ENDIF
	ENDIF
END SUB

SUB SystemComments
	count = token {$$BYTE2}
	IF (count = 255) THEN
		INC tokenPtr
		count = tokens[tokenPtr]
	ENDIF
	deparsed$ = deparsed$ + "'"
	pw$ = NULL$(4)
	pa = &pw$
	x = 0
	DO WHILE (x < count)
		INC tokenPtr
		XLONGAT(pa) = tokens[tokenPtr]
		deparsed$ = deparsed$ + pw$
		XLONGAT(pa) = 0
		x	= x + 4
	LOOP
	deparsed$ = RTRIM$(deparsed$)
END SUB

SUB UserTypes
	deparsed$ = deparsed$ + typeSymbol$[tt] + CHR$ (whiteChar, spaces)
END SUB

SUB BogusToken
	PRINT "*****  DEPARSE:  BOGUS TOKEN  *****"
END SUB

SUB LoadKindDeparse
	DIM kindDeparse [31]
	FOR i = 0 TO 31
		kindDeparse [i] = SUBADDRESS (BogusToken)
	NEXT
	kindDeparse [ $$KIND_TERMINATORS		] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_STATE_INTRIN		] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_STATEMENTS			] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_INTRINSICS			] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_SEPARATORS			] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_CHARACTERS			] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_BINARY_OPS			] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_UNARY_OPS			] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_ADDR_OPS				] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_LPARENS				] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_RPARENS				] = SUBADDRESS (SystemSymbols)
	kindDeparse [ $$KIND_SYMBOLS				]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_ARRAY_SYMBOLS	]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_VARIABLES			]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_ARRAYS					]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_LITERALS				]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_CONSTANTS			]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_CHARCONS				] = SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_SYSCONS				]	= SUBADDRESS (UserSymbols)
	kindDeparse [ $$KIND_LABELS					]	= SUBADDRESS (UserLabels)
	kindDeparse [ $$KIND_TYPES					] = SUBADDRESS (UserTypes)
	kindDeparse [ $$KIND_STARTS					]	= SUBADDRESS (SystemStarts)
	kindDeparse [ $$KIND_WHITES					]	= SUBADDRESS (SystemWhites)
	kindDeparse [ $$KIND_COMMENTS				]	= SUBADDRESS (SystemComments)
	kindDeparse [ $$KIND_FUNCTIONS			]	= SUBADDRESS (FunctionSymbols)
	kindDeparse [ $$KIND_INLINEASM      ] = SUBADDRESS (SystemSymbols)
END SUB
END FUNCTION


' ########################
' #####  EmitAsm ()  #####
' ########################

FUNCTION  EmitAsm (line$)
	SHARED  ofile

' #emitasm = 0	' flush buffer
' #emitasm = 1	' buffer assembly
' #emitasm = 2	' emit this now - leave buffer intact

	emitasm = #emitasm
	IF #immediatemode THEN emitasm = 2
	SELECT CASE emitasm
		CASE 0	:	GOSUB FlushBuffer
		CASE 1	:	GOSUB BufferAssembly
		CASE 2	:	PRINT [ofile], line$; "\r"
	END SELECT
	RETURN


' *****  FlushBuffer  *****

SUB FlushBuffer
	IF #asm$[] THEN
		IF (#asmnext > 0) THEN
			FOR line = 0 TO #asmnext-1
				PRINT [ofile], #asm$[line]; "\r"
			NEXT line
		ENDIF
	ENDIF

	PRINT [ofile], line$; "\r"

	#asmupper = -1
	#asmnext = 0
	DIM #asm$[]
END SUB


' *****  BufferAssembly  *****

SUB BufferAssembly
	IFZ #asm$[] THEN
		#asmnext = 0
		#asmupper = 4095
		DIM #asm$[#asmupper]
	ENDIF

	IF (#asmnext > #asmupper) THEN
		#asmupper = #asmupper + 4096
		REDIM #asm$[#asmupper]
	ENDIF

	#asm$[#asmnext] = line$
	INC #asmnext
END SUB
END FUNCTION


' ##################################
' #####  EmitFunctionLabel ()  #####
' ##################################

FUNCTION  EmitFunctionLabel (label$)
	SHARED  labaddr[]
	SHARED  XERROR,  ERROR_DUP_LABEL
	SHARED  func_number

	token = AddLabel (@label$, $$T_LABELS, $$XNEW)
	IF XERROR THEN EXIT FUNCTION

	EmitAsm (label$ + ":")

	RETURN

eeeDupLabel:
	PRINT "Duplicate Label = "; label$
	XERROR = ERROR_DUP_LABEL
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  EmitLabel ()  #####
' ##########################

FUNCTION  EmitLabel (label$)
	SHARED  labaddr[]
	SHARED  XERROR,  ERROR_DUP_LABEL
	SHARED  func_number

	token = AddLabel (@label$, $$T_LABELS, $$XADD)
	IF XERROR THEN EXIT FUNCTION

	EmitAsm (label$ + ":")
	RETURN

eeeDupLabel:
	PRINT "Duplicate Label = "; label$
	XERROR = ERROR_DUP_LABEL
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  EmitString ()  #####
' ###########################

FUNCTION  EmitString (theLabel$, @theString$)
	SHARED	xit
	IF (INSTR(theString$, "\\")) THEN
		theString$ = XstBackStringToBinString$ (@theString$)
	ENDIF

	litlen			= LEN (theString$)
	asmString$	= BinStringToAsmString$ (@theString$)
	chunk				= (litlen + 32) AND 0xFFFFFFF0
	pad					= ((litlen + 16) AND 0xFFFFFFF0) - litlen
	IF pad > 8 THEN  	' reduce alignment and padding from 16 bytes to 8 bytes
		pad 	= pad - 8
		chunk = chunk - 8
	ENDIF
	EmitAsm (";")
	EmitAsm ("dd	" + STRING (chunk) + ",0, " + STRING (litlen) + ",0x80130001")
	EmitLabel (@theLabel$)

	IF (LEN (asmString$) <= 128) THEN
		EmitAsm ("db	" + asmString$)
	ELSE
		offset = 1
		DO
			length = 32
			IF (litlen < length) THEN length = litlen
			piece$ = MID$ (theString$, offset, length)
			asmString$ = BinStringToAsmString$ (@piece$)
			EmitAsm ("db	" + asmString$)
			litlen = litlen - length
			offset = offset + length
		LOOP WHILE litlen
	ENDIF
	EmitAsm ("db	" + STRING$(pad) + " dup 0")

END FUNCTION


' ##############################
' #####  EmitUserLabel ()  #####
' ##############################


' asm:  Emit user program (GOTO or GOSUB) label into ascii source .asm file.

' EmitUserLabel() is for user labels, not internal labels (see EmitLabel()).
' User Labels are GOTO labels and GOSUB labels (also function() labels ???).

FUNCTION  EmitUserLabel (labelToken)
	SHARED	labaddr[],  tab_lab$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_LABEL
	SHARED	func_number

  ltype	= labelToken{$$TYPE}
	tt		= labelToken{$$NUMBER}
	qpc		= labaddr[tt]
	IF qpc THEN GOTO eeeDupLabel
	labaddr[tt]		= $$TRUE
	tt$		= tab_lab$[tt]
	SELECT CASE ltype
	  CASE $$GOADDR, $$SUBADDR
			EmitAsm (tt$ + ":")
		CASE ELSE:		PRINT "eul1": GOTO eeeCompiler
	END SELECT

	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeDupLabel:
	XERROR = ERROR_DUP_LABEL
	EXIT FUNCTION
END FUNCTION


' #####################
' #####  Eval ()  #####
' #####################

FUNCTION  Eval (result_type)
	SHARED	reg86$[],  reg86c$[]
	SHARED	ERROR_COMPILER,  XERROR
	SHARED	a0,  a0_type,  a1,  a1_type,  oos,  toes
	SHARED UBYTE oos[]

	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	nn = new_data{$$NUMBER}
	IF new_data THEN
		INC toes
		SELECT CASE TRUE
			CASE (a0 = 0):  dd$ = "a0": a0 = toes: tr = $$RA0
			CASE (a1 = 0):  dd$ = "a1": a1 = toes: tr = $$RA1
			CASE (a1 > a0)
				Push ($$RA0, a0_type)
				dd$ = "a0": tr = $$RA0
				a0 = toes: a0_type = new_type
			CASE (a1 < a0)
				Push ($$RA1, a1_type)
				dd$ = "a1": tr = $$RA1
				a1 = toes: a1_type = new_type
			CASE ELSE:     PRINT "Eval()": GOTO eeeCompiler
		END SELECT
		Move (tr, new_type, nn, new_type)
	ELSE
		SELECT CASE toes
			CASE a0:  dd$ = "a0"
			CASE a1:  dd$ = "a1"
		END SELECT
	ENDIF
	IF ((new_type = $$STRING) AND (oos[oos] = 'v')) THEN
		Code ($$call, $$rel, 0, 0, 0, 0, "%_clone." + dd$, @"	;;; i429")
		oos[oos] = 'v'
	ENDIF
	result_type = new_type
	RETURN (new_op)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #############################
' #####  ExpressArray ()  #####
' #############################

FUNCTION  ExpressArray (old_op, old_prec, new_data, new_type, accArray, excess, theType, sourceReg)
	SHARED	checkBounds
	SHARED  m_addr[],  m_addr$[],  m_reg[]
	SHARED  r_addr[],  r_addr$[],  reg$[],  regc$[]
	SHARED  typeSize[]
	SHARED  ERROR_COMPILER,  ERROR_REGADDR,  ERROR_SYNTAX
	SHARED	ERROR_TOO_MANY_ARGS,  ERROR_TYPE_MISMATCH
	SHARED  T_ADDR_OP,  T_HANDLE_OP,  T_STORE_OP
	SHARED  T_COMMA,  T_LBRACE,  T_LBRAK,  T_RBRACE,  T_RBRAK,  T_REDIM
	SHARED  XERROR
	SHARED  a0,  a0_type,  a1,  a1_type
	SHARED  dim_array
	SHARED  labelNumber
	SHARED  oos
	SHARED  toes,  tokenPtr,  elementType,  falseToken
	SHARED UBYTE	oos[],  shiftMulti[]
	STATIC	opcode[],  opcode$[]


' *****  define local constants  *****

	$ld						= 0
	$st						= 1
	$addrOp				= 2
	$handleOp			= 3
	$immediate		= 0
	$scaled				= 1
	$unscaled			= 2
	$lowestDim		= 0
	$higherDim		= 1
	$excessComma	= 2
	$addr					= 2
	$handle				= 3
	$imm					= 0
	$sca					= 1
	$uns					= 2
	$lo						= 0
	$hi						= 1
	$ex						= 2
	$ro						= 6
	$rr						= 7
	$rs						= 8
	$regr0				= 12
	$regro				= 13
	$regrr				= 14
	$regrs				= 15
	$r0reg				= 17
	$roreg				= 18
	$rrreg				= 19
	$rsreg				= 20

	IFZ opcode[] THEN GOSUB InitArrays

	token	= new_data
	hd = token{$$NUMBER}
	IF (hd > $$CONNUM) THEN
		IFZ m_addr$[hd] THEN AssignAddress (token)
		IF XERROR THEN EXIT FUNCTION
	ENDIF

	args = 0
	kind = token{$$KIND}
	atoken = token
	SELECT CASE kind
		CASE $$KIND_ARRAYS
					IF theType THEN
						aType = theType
					ELSE
						aType = TheType (token)
					ENDIF
					xsize = typeSize[aType]
					composite = $$FALSE
					braceString = $$FALSE
					token = NextToken ()
					IF (token != T_LBRAK) THEN GOTO eeeSyntax
		CASE $$KIND_VARIABLES			' a${n} style access (byte from string)
					IF (new_type	!= $$STRING) THEN GOTO eeeCompiler
					aType			= $$UBYTE
					atoken		= $$T_ARRAYS OR (token AND 0x00E0FFFF) OR ($$UBYTE << 16)
					xsize			= 1
					token			= NextToken ()
					IF (token <> T_LBRACE) THEN GOTO eeeSyntax
					compositeType	= $$FALSE
					braceString		= $$TRUE
					IF dim_array THEN GOTO eeeSyntax
		CASE ELSE
					PRINT "expressArrayKind"
					GOTO eeeCompiler
	END SELECT

	IF (aType >= $$SCOMPLEX) THEN
		compositeType = $$TRUE
		eType = $$COMPOSITE
	ELSE
		eType = aType
	ENDIF
	excessComma				= $$FALSE
	IF dim_array THEN GOTO e_dim_array ELSE GOTO e_get_array


' *****************************
' *****  DIMENSION ARRAY  *****
' *****************************

e_dim_array:
	Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i430")
e_dim_array_loop:
	INC args
	temp_dim = dim_array: dim_array = $$FALSE
	new_op = Eval (@new_type)
	dim_array = temp_dim
	IF XERROR THEN EXIT FUNCTION
	SELECT CASE toes
		CASE 0:			Move ($$esi, $$XLONG, hd, $$XLONG)
								Code ($$call, $$rel, 0, 0, 0, 0, @"%_FreeArray", @"	;;; i431")
'								Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
								Move (atoken, $$XLONG, falseToken, $$XLONG)
								Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"")
								RETURN ($$TRUE)
		CASE a0:		Conv ($$RA0, $$XLONG, $$RA0, new_type)
								sreg = $$R10
		CASE a1:		Conv ($$RA1, $$XLONG, $$RA1, new_type)
								sreg = $$R12
		CASE ELSE:	GOTO eeeSyntax
	END SELECT
	Code ($$st, $$roreg, sreg, $$esp, (16+4*(args-1)), $$XLONG, @"", @"	;;; i432")
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	IF (new_op = T_COMMA) THEN
		check				= PeekToken ()
		IF (check != T_RBRAK) THEN GOTO e_dim_array_loop		' get next subscript
		new_op			= NextToken ()
		excessComma	= $$TRUE
		aType				= $$XLONG														' no lowest dimension
	ENDIF
	IF (new_op <> T_RBRAK) THEN GOTO eeeSyntax
	IF (args > 8) THEN GOTO eeeTooManyArgs

	IF (aType >= $$SCOMPLEX) THEN
		IF (hold_type > 0xFF) THEN aType = $$COMPOSITE
	ENDIF
	IF excessComma THEN
		info	= 0xE000 OR aType					' "higher dimension" bit = 1  (TRUE)
		aType	= $$XLONG									' "higher dimensions" are XLONG
		xsize	= typeSize[aType]					' xsize = 4  (size of XLONG)
	ELSE
		info	= 0xC000 OR aType					' "higher dimension" bit = 0  (FALSE)
	ENDIF

	IF (dim_array = T_REDIM) THEN
		routine$ = "%_RedimArray"
	ELSE
		routine$ = "%_DimArray"
	ENDIF
	Move ($$esi, $$XLONG, atoken, $$XLONG)
	Code ($$st, $$roreg, $$esi, $$esp, 0, $$XLONG, @"", @"	;;; i433")
	Code ($$st, $$roimm, args, $$esp, 4, $$XLONG, @"", @"	;;; i434")
	Code ($$st, $$roimm, (info << 16) + xsize, $$esp, 8, $$XLONG, @"", @"	;;; i435")
	Code ($$st, $$roimm, 0, $$esp, 12, $$XLONG, @"", @"	;;; i436")
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"	;;; i437")
	Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i438")
	Move (hd, $$XLONG, $$R10, $$XLONG)

dimend:
	excess	= excessComma
	RETURN ($$TRUE)						' done


' ******************************************
' *****  GET ARRAY ELEMENT OR ADDRESS  *****
' ******************************************

e_get_array:
	IF excess THEN
		SELECT CASE TRUE
			CASE (aType < $$SLONG):		aType = $$XLONG: xsize = 4
			CASE (aType = $$GIANT):		aType = $$XLONG: xsize = 4
			CASE (aType = $$DOUBLE):	aType = $$XLONG: xsize = 4
			CASE (aType = $$LONGDOUBLE):	aType = $$XLONG: xsize = 4
		END SELECT
	ENDIF
	SELECT CASE r_addr[hd]
		CASE 0, $$RA0, $$RA1:	regarray = $$FALSE
		CASE ELSE:						regarray = $$TRUE
	END SELECT
	old_op_kind	= old_op{$$KIND}
	old_op_hold	= old_op
	stringType	= $$FALSE
	IF (aType = $$STRING) THEN stringType = $$TRUE
	SELECT CASE old_op
		CASE T_ADDR_OP:			actionKind	= $addrOp:		oldKindAddrOp = $$TRUE
		CASE T_HANDLE_OP:   actionKind	= $handleOp:	oldKindAddrOp = $$TRUE
		CASE T_STORE_OP:		actionKind	= $st:				oldKindAddrOp = $$FALSE
												IF stringType THEN				oldKindAddrOp = $$TRUE
												IF compositeType THEN			oldKindAddrOp = $$TRUE
		CASE ELSE:          actionKind	= $ld:				oldKindAddrOp = $$FALSE
	END SELECT
	check = PeekToken ()
	IF braceString THEN
		IF (check = T_RBRACE) THEN GOTO eeeSyntax		' a${} not yet allowed
		GOTO not_null_array
	ELSE
		IF (check != T_RBRAK) THEN GOTO not_null_array
	ENDIF

a_null_array:
	null_array = $$TRUE
	trash = NextToken ()
	SELECT CASE actionKind
		CASE $addrOp:			old_op = 0: old_prec = 0:		GOTO addr_null_array
		CASE $handleOp:																GOTO handle_null_array
		CASE $st:																			GOTO eeeSyntax
		CASE ELSE:																		GOTO null_array
	END SELECT

null_array:
addr_null_array:
	new_data	= (atoken AND 0xFFFFFF) OR $$T_VARIABLES
	new_type	= $$XLONG
	excess		= $$FALSE
	RETURN ($$FALSE)								' GOTO express_op

' *****  &&array[]  *****

handle_null_array:
	IF r_addr[hd] THEN DEC tokenPtr: GOTO eeeRegAddr
	tacc = OpenAccForType ($$XLONG)
	m$   = m_addr$[hd]
	mReg	= m_reg[hd]
	mAddr	= m_addr[hd]
	IF mReg THEN
		Code ($$lea, $$regro, tacc, mReg, mAddr, $$XLONG, @"", @"	;;; i439")
	ELSE
		Code ($$mov, $$regimm, tacc, mAddr, 0, $$XLONG, @m$, @"	;;; i440")
	ENDIF
	new_data	= 0
	new_type	= $$XLONG
	excess		= $$FALSE
	RETURN ($$FALSE)								' GOTO express_op


' **************************************************
' *****  PROCESS ARRAY ARGUMENTS (subscripts)  *****
' **************************************************

not_null_array:
	doneArgs = $$FALSE
	DO
		test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
		Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
		IF XERROR THEN EXIT FUNCTION
		IF (new_type > $$XLONG) THEN DEC tokenPtr: GOTO eeeTypeMismatch
		new_type = $$XLONG
		stackString = $$FALSE
		fakeExcessComma = $$FALSE
'		aType = eType
		SELECT CASE new_op
			CASE T_RBRAK
						esize = xsize
						doneArgs = $$TRUE
						dimensionKind	= $lowestDim
						IF (aType = $$STRING) THEN
							IF (actionKind = $ld) THEN INC oos: oos[oos] = 'v'
							IF excess THEN
								fakeExcessComma = $$TRUE
								dimensionKind = $excessComma
								excessComma = $$TRUE
								aType = $$XLONG
							ENDIF
						ENDIF
						IF braceString THEN GOTO eeeSyntax
			CASE T_RBRACE
						esize = 1
						doneArgs = $$TRUE
						dimensionKind = $lowestDim
						IFZ braceString THEN GOTO eeeSyntax
						IF (accArray = 's') THEN stackString = $$TRUE
			CASE T_COMMA:
						IF braceString THEN GOTO eeeSyntax		' a${n,...} (later!)
						check = PeekToken ()
						IF (check = T_RBRAK) THEN
							doneArgs					= $$TRUE
							dimensionKind			= $excessComma
							new_op						= NextToken ()
							excessComma				= $$TRUE
							aType							= $$XLONG
						ELSE
							doneArgs					= $$FALSE
							dimensionKind			= $higherDim
						ENDIF
						esize								= 4
			CASE ELSE
						GOTO eeeSyntax
		END SELECT

' new_data is a variable or literal or constant (not evaluated expression)

		IF new_data THEN
			nn = new_data{$$NUMBER}

' array is in a register and this is leftmost dimension

			IF regarray THEN
				acc		= OpenAccForType ($$XLONG)
				dreg	= acc
				rr		= r_addr[nn]
				SELECT CASE TRUE
					CASE (rr AND (rr < $$IMM16))
						arsub				= r_addr[nn]
						araddr			= r_addr[hd]
						elementKind	= $scaled
						IF (eSize = 1) THEN elementKind = $unscaled
						IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
					CASE (rr AND (rr <= $$CONNUM))
						element			= XLONG (r_addr$[nn])
						offset			= element * esize
						IF (offset <= 65535) THEN
							offset$			= STRING(offset)
							arsub				= offset
							araddr			= r_addr[hd]
							element$		= STRING(element)
							elementKind	= $immediate
						ELSE
							Move (dreg, new_type, new_data, new_type)
							arsub				= dreg
							araddr			= r_addr[hd]
							elementKind	= $scaled
							IF (esize = 1) THEN elementKind = $unscaled
							IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
						ENDIF
					CASE ELSE
						Move (acc, new_type, new_data, new_type)
						arsub				= dreg
						araddr			= r_addr[hd]
						elementKind	= $scaled
						IF (esize = 1) THEN elementKind = $unscaled
						IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
				END SELECT
			ELSE

' array is not in a register, or not leftmost dimension

				IF (args OR accArray) THEN
					acc			= Top()
					dreg		= acc
					araddr	= dreg
					rr			= r_addr[nn]
					SELECT CASE TRUE
						CASE (rr AND (rr < $$IMM16))
							arsub				= r_addr[nn]
							elementKind	= $scaled
							IF (esize = 1) THEN elementKind = $unscaled
							IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
						CASE (rr AND (rr <= $$CONNUM))
							element			= XLONG (r_addr$[nn])
							offset			= element * esize
							IF (offset <= 65535) THEN
								offset$			= STRING(offset)
								arsub				= offset
								element$		= STRING(element)
								elementKind	= $immediate
							ELSE
								Move (acc + 1, new_type, nn, new_type)
								arsub				= acc + 1
								elementKind	= $scaled
								IF (esize = 1) THEN elementKind = $unscaled
								IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
							ENDIF
						CASE ELSE
							Move (acc + 1, new_type, nn, new_type)
							arsub				= acc + 1
							elementKind	= $scaled
							IF (esize = 1) THEN elementKind = $unscaled
							IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
					END SELECT
				ELSE
					acc		= OpenAccForType ($$XLONG)
					dreg	= acc
					rr		= r_addr[nn]
					SELECT CASE TRUE
						CASE (rr AND (rr < $$IMM16))
							Move (acc + 1, $$XLONG, atoken, $$XLONG)
							araddr			= acc + 1
							arsub				= r_addr[nn]
							elementKind	= $scaled
							IF (esize = 1) THEN elementKind = $unscaled
							IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
						CASE (rr AND (rr <= $$CONNUM))
							element			= XLONG (r_addr$[nn])
							offset			= element * esize
							IF (offset <= 65535) THEN
								Move (acc + 1, $$XLONG, atoken, $$XLONG)
								araddr			= acc + 1
								offset$			= STRING(offset)
								arsub				= offset
								element$		= STRING(element)
								elementKind	= $immediate
							ELSE
								Move (acc, new_type, new_data, new_type)
								Move (acc + 1, $$XLONG, atoken, $$XLONG)
								araddr			= acc + 1
								arsub				= dreg
								elementKind	= $scaled
								IF (esize = 1) THEN elementKind = $unscaled
								IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
							ENDIF
						CASE ELSE
							Move (acc, new_type, new_data, new_type)
							Move (acc + 1, $$XLONG, atoken, $$XLONG)
							araddr				= acc + 1
							arsub					= dreg
							elementKind		= $scaled
							IF (esize = 1) THEN elementKind = $unscaled
							IF (compositeType AND (dimensionKind = lowestDim)) THEN GOSUB AccessComposite
					END SELECT
				ENDIF
			ENDIF
		ELSE

' new_data is result of expression evaluation, not variable, literal, constant

			acc = Top()
			dreg = acc
			arsub = dreg
			IF regarray THEN
				araddr			= r_addr[hd]
				elementKind	= $scaled
				IF (esize = 1) THEN elementKind = $unscaled
				IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
			ELSE
				IF (args OR accArray) THEN
					SELECT CASE acc
						CASE $$RA0: IFZ a1 THEN Pop ($$RA1, $$XLONG)
												araddr	= $$RA1
						CASE $$RA1: IFZ a0 THEN Pop ($$RA0, $$XLONG)
												araddr	= $$RA0
						CASE ELSE:  PRINT "expressArray02": GOTO eeeCompiler
					END SELECT
					DEC toes
					dreg				= $$RA0
					elementKind	= $scaled
					IF (esize = 1) THEN elementKind = $unscaled
					a1 = 0: a1_type = 0: a0 = toes: a0_type = $$XLONG
					IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
				ELSE
					araddr = acc + 1
					elementKind	= $scaled
					IF (esize = 1) THEN elementKind = $unscaled
					Move (acc + 1, $$XLONG, atoken, $$XLONG)
					IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
				ENDIF
			ENDIF
		ENDIF

' if bounds checking is enabled, emit bounds checking code

		IF checkBounds THEN
			IF (dimensionKind != $lowestDim) THEN
				needHigherDim = $$TRUE
			ELSE
				needHigherDim = $$FALSE
			ENDIF
			IF fakeExcessComma THEN needHigherDim = NOT needHigherDim
			d0$ = CreateLabel$ ()
			d1$ = CreateLabel$ ()
			d2$ = CreateLabel$ ()
			d3$ = CreateLabel$ ()				' Not sure if this can be Annonymous or not
			Code ($$test, $$regreg, araddr, araddr, 0, $$XLONG, @"", @"	;;; i441")
			Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i442")
			Code ($$ld, $$regro, $$esi, araddr, -8, $$XLONG, @"", @"	;;; i443")
			Code ($$ld, $$regro, $$edi, araddr, -4, $$XLONG, @"", @"	;;; i444")
			IF needHigherDim THEN
				Code ($$test, $$regimm, $$edi, (1 << 29), 0, $$XLONG, @"", @"	;;; i445")
				Code ($$jnz, $$rel, 0, 0, 0, 0, "> " + d0$, @"	;;; i446")
				Code ($$mov, $$regreg, $$esi, araddr, 0, $$XLONG, @"", @"	;;; i447")
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_UnexpectedLowestDim", @"	;;; i448")
				Code ($$jmp, $$rel, 0, 0, 0, 0, ">> " + d3$, @"	;;; i449")
			ELSE
				Code ($$test, $$regimm, $$edi, (1 << 29), 0, $$XLONG, @"", @"	;;; i450")
				Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d0$, @"	;;; i451")
				Code ($$mov, $$regreg, $$esi, araddr, 0, $$XLONG, @"", @"	;;; i452")
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_UnexpectedHigherDim", @"	;;; i453")
				Code ($$jmp, $$rel, 0, 0, 0, 0, ">> " + d3$, @"	;;; i454")
			ENDIF
			EmitLabel (@d0$)
			IFZ braceString THEN
				Code ($$dec, $$reg, $$esi, 0, 0, $$XLONG, @"", @"")
			ENDIF
			SELECT CASE elementKind
				CASE $imm
							Code ($$cmp, $$regimm, $$esi, element, 0, $$XLONG, @"", @"	;;; i455")
				CASE $sca
							Code ($$cmp, $$regreg, $$esi, arsub, 0, $$XLONG, @"", @"	;;; i456")
				CASE $uns
							Code ($$and, $$regimm, $$edi, 0xFFFF, 0, $$XLONG, @"", @"	;;; i457")
							Code ($$imul, $$regreg, $$esi, $$edi, 0, $$XLONG, @"", @"	;;; i458")
							Code ($$cmp, $$regreg, $$esi, arsub, 0, $$XLONG, @"", @"	;;; i459")
			END SELECT
			Code ($$jae, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i460")
			EmitLabel (@d1$)
			Code ($$mov, $$regreg, $$ecx, araddr, 0, $$XLONG, @"", @"	;;; i461")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_OutOfBounds", @"	;;; i462")
			Code ($$jmp, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i463")
			EmitLabel (@d2$)
		ENDIF

		IF stackString THEN
			Code ($$mov, $$regreg, $$esi, araddr, 0, $$XLONG, @"", @"	;;; i463a")
		ENDIF

		code = opcode [dimensionKind, elementKind, actionKind, eType]
		mode = code AND 0x00FF
		code = code {$$WORD1}
		IFZ code THEN GOTO eeeSyntax
		IF dimensionKind THEN xType = $$XLONG ELSE xType = eType

' modified for array offset using LONGDOUBLE
		IF (xType = $$LONGDOUBLE) && ((mode = $$rs || mode = $$regrs)) THEN
			SELECT CASE mode
				CASE $$rs    : 'PRINT "case $$rs"
					IF arsub = $$eax THEN
						Code ($$push, $$reg, $$edx, 0, 0, $$XLONG, @"", @"	;;; i463b")
						Code ($$mov, $$imm, 0, 0, 0, $$XLONG, @" ebx,12", @"	;;; i463c")
						Code ($$mul, $$reg, $$ebx, 0, 0, $$XLONG, @"", @"	;;; i463d")
						Code ($$pop, $$reg, $$edx, 0, 0, $$XLONG, @"", @"	;;; i463e")
					ELSE
						Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i463f")
						Code ($$mov, $$imm, 0, 0, 0, $$XLONG, @" eax,12", @"	;;; i463g")
						Code ($$mul, $$reg, arsub, 0, 0, $$XLONG, @"", @"	;;; i463h")
						Code ($$mov, $$regreg, arsub, $$eax, 0, $$XLONG, @"", @"	;;; i463i")
						Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i463j")
					ENDIF
					Code (code, $$rr, dreg, araddr, arsub, xType, @"", @"	;;; i463k")
				CASE $$regrs : 'PRINT "case $$regrs"
					Code ($$push, $$reg, $$edx, 0, 0, $$XLONG, @"", @"  ;;; i463l")
					Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"  ;;; i463m")
					Code ($$mov, $$imm, 0, 0, 0, $$XLONG, @" eax,12", @"	;;; i463n")
					Code ($$mul, $$reg, arsub, 0, 0, $$XLONG, @"", @"	;;; i463o")
					Code ($$mov, $$regreg, arsub, $$eax, 0, $$XLONG, @"", @"	;;; i463p")
					Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, @"", @"  ;;; i463q")
					Code ($$pop, $$reg, $$edx, 0, 0, $$XLONG, @"", @"  ;;; i463r")
					Code (code, $$regrr, dreg, araddr, arsub, xType, @"", @"	;;; i463s")
			END SELECT
		ELSE
			Code (code, mode, dreg, araddr, arsub, xType, @"", @"	;;; i464")
		ENDIF

		IF checkBounds THEN EmitLabel (@d3$)
		regarray = $$FALSE
		INC args
	LOOP UNTIL (doneArgs)


' *****  DONE processing subscripts  *****

	IF stackString THEN
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"")
	ENDIF
	IF accArray THEN DEC oos
	acc = Top()
	elementType	= aType
	IF (aType < $$SLONG) THEN aType = $$SLONG
	IF oldKindAddrOp THEN aType = $$XLONG
	SELECT CASE acc
		CASE $$RA0:   a0_type = aType
		CASE $$RA1:   a1_type = aType
		CASE ELSE:    PRINT "expressArray03": GOTO eeeCompiler
	END SELECT
	excess			= excessComma
	new_type		= aType
	new_data		= 0
	RETURN ($$FALSE)

' *****  Access Composite Element in Array  *****

SUB AccessComposite
	IF (esize <= 1024) THEN eshift = shiftMulti [esize]
	IF eshift THEN
		Code ($$shl, $$regimm, arsub, eshift, 0, $$XLONG, @"", @"")
	ELSE
		Code ($$imul, $$regimm, arsub, esize, 0, $$XLONG, @"", @"	;;; i465")
	ENDIF
	elementKind	= $unscaled
END SUB



' ****************************
' *****  SUB InitArrays  *****
' ****************************

SUB InitArrays
	DIM opcode [2, 2, 3, 31]
	DIM opcode$[2, 2, 3, 31]


' ****************************************
' ****************************************
' *****  dimensionKind = $lowestDim  *****
' ****************************************
' ****************************************

' ***********************
' *****  immediate  *****  (offset = element * size)
' ***********************

	opcode [$lo, $imm, $ld, $$SBYTE]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$UBYTE]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$SSHORT]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$USHORT]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$SLONG]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$ULONG]				=	$$uld		+ $regro
	opcode [$lo, $imm, $ld, $$XLONG]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$GOADDR]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$SUBADDR]			= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$FUNCADDR]			= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$GIANT]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$SINGLE]				= $$ufld	+ $ro
	opcode [$lo, $imm, $ld, $$DOUBLE]				= $$ufld	+ $ro
	opcode [$lo, $imm, $ld, $$LONGDOUBLE]		= $$ufld	+ $ro
	opcode [$lo, $imm, $ld, $$STRING]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$COMPOSITE]		= $$ulda	+ $regro

	opcode [$lo, $imm, $st, $$SBYTE]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$UBYTE]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$SSHORT]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$USHORT]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$SLONG]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$ULONG]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$XLONG]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$GOADDR]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$SUBADDR]			= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$FUNCADDR]			= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$GIANT]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$SINGLE]				= $$ufstp	+ $ro
	opcode [$lo, $imm, $st, $$DOUBLE]				= $$ufstp	+ $ro
	opcode [$lo, $imm, $st, $$LONGDOUBLE]		= $$ufstp	+ $ro
	opcode [$lo, $imm, $st, $$STRING]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$COMPOSITE]		= $$ulda	+ $regro

	opcode [$lo, $imm, $addr, $$SBYTE]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$UBYTE]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$SSHORT]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$USHORT]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$SLONG]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$ULONG]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$XLONG]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$GOADDR]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$SUBADDR]		= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$FUNCADDR]		= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$GIANT]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$SINGLE]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$DOUBLE]			= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$LONGDOUBLE]	= $$ulda	+ $regro
	opcode [$lo, $imm, $addr, $$STRING]			= $$uld		+ $regro
	opcode [$lo, $imm, $addr, $$COMPOSITE]	= $$ulda	+ $regro

	opcode [$lo, $imm, $handle, $$STRING]		= $$ulda	+ $regro


' ********************
' *****  scaled  *****  (size = 1, 2, 4, 8 bytes)
' ********************

	opcode [$lo, $sca, $ld, $$SBYTE]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$UBYTE]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$SSHORT]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$USHORT]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$SLONG]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$ULONG]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$XLONG]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$GOADDR]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$SUBADDR]			= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$FUNCADDR]			= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$GIANT]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$SINGLE]				= $$ufld	+ $rs
	opcode [$lo, $sca, $ld, $$DOUBLE]				= $$ufld	+ $rs
	opcode [$lo, $sca, $ld, $$LONGDOUBLE]		= $$ufld	+ $rs
	opcode [$lo, $sca, $ld, $$STRING]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$COMPOSITE]		= $$uld		+ $regrs

	opcode [$lo, $sca, $st, $$SBYTE]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$UBYTE]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$SSHORT]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$USHORT]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$SLONG]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$ULONG]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$XLONG]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$GOADDR]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$SUBADDR]			= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$FUNCADDR]			= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$GIANT]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$SINGLE]				= $$ufstp	+ $rs
	opcode [$lo, $sca, $st, $$DOUBLE]				= $$ufstp	+ $rs
	opcode [$lo, $sca, $st, $$LONGDOUBLE]		= $$ufstp	+ $rs
	opcode [$lo, $sca, $st, $$STRING]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$COMPOSITE]		= $$ulda	+ $regrs

	opcode [$lo, $sca, $addr, $$SBYTE]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$UBYTE]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$SSHORT]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$USHORT]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$SLONG]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$ULONG]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$XLONG]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$GOADDR]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$SUBADDR]		= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$FUNCADDR]		= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$GIANT]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$SINGLE]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$DOUBLE]			= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$LONGDOUBLE]	= $$ulda	+ $regrs
	opcode [$lo, $sca, $addr, $$STRING]			= $$uld		+ $regrs
	opcode [$lo, $sca, $addr, $$COMPOSITE]	= $$ulda	+ $regrs

	opcode [$lo, $sca, $handle, $$STRING]		= $$ulda	+ $regrs


' **********************
' *****  unscaled  *****  (size not 1, 2, 4, 8 bytes)  *****
' **********************

	opcode [$lo, $uns, $ld, $$SBYTE]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$UBYTE]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$SSHORT]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$USHORT]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$SLONG]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$ULONG]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$XLONG]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$GOADDR]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$SUBADDR]			= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$FUNCADDR]			= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$GIANT]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$SINGLE]				= $$ufld	+ $rr
	opcode [$lo, $uns, $ld, $$DOUBLE]				= $$ufld	+ $rr
	opcode [$lo, $uns, $ld, $$LONGDOUBLE]		= $$ufld	+ $rr
	opcode [$lo, $uns, $ld, $$STRING]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$COMPOSITE]		= $$ulda	+ $regrr

	opcode [$lo, $uns, $st, $$SBYTE]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$UBYTE]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$SSHORT]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$USHORT]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$SLONG]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$ULONG]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$XLONG]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$GOADDR]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$SUBADDR]			= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$FUNCADDR]			= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$GIANT]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$SINGLE]				= $$ufstp	+ $rr
	opcode [$lo, $uns, $st, $$DOUBLE]				= $$ufstp	+ $rr
	opcode [$lo, $uns, $st, $$LONGDOUBLE]		= $$ufstp	+ $rr
	opcode [$lo, $uns, $st, $$STRING]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$COMPOSITE]		= $$ulda	+ $regrr

	opcode [$lo, $uns, $addr, $$SBYTE]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$UBYTE]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$SSHORT]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$USHORT]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$SLONG]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$ULONG]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$XLONG]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$GOADDR]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$SUBADDR]		= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$FUNCADDR]		= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$GIANT]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$SINGLE]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$DOUBLE]			= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$LONGDOUBLE]	= $$ulda	+ $regrr
	opcode [$lo, $uns, $addr, $$STRING]			= $$uld		+ $regrr
	opcode [$lo, $uns, $addr, $$COMPOSITE]	= $$ulda	+ $regrr

	opcode [$lo, $uns, $handle, $$STRING]		= $$ulda	+ $regrr


' ****************************************
' ****************************************
' *****  dimensionKind = $higherDim  *****
' ****************************************
' ****************************************

' ***********************
' *****  immediate  *****  (offset = ele * size)
' ***********************

	opcode [$hi, $imm, $ld, $$SBYTE]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$UBYTE]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$SSHORT]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$USHORT]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$SLONG]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$ULONG]				=	$$uld		+ $regro
	opcode [$hi, $imm, $ld, $$XLONG]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$GOADDR]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$SUBADDR]			= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$FUNCADDR]			= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$GIANT]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$SINGLE]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$DOUBLE]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$LONGDOUBLE]		= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$STRING]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$COMPOSITE]		= $$uld		+ $regro

	opcode [$hi, $imm, $st, $$SBYTE]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$UBYTE]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$SSHORT]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$USHORT]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$SLONG]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$ULONG]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$XLONG]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$GOADDR]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$SUBADDR]			= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$FUNCADDR]			= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$GIANT]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$SINGLE]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$DOUBLE]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$LONGDOUBLE]		= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$STRING]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$COMPOSITE]		= $$uld		+ $regro

	opcode [$hi, $imm, $addr, $$SBYTE]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$UBYTE]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$SSHORT]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$USHORT]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$SLONG]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$ULONG]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$XLONG]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$GOADDR]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$SUBADDR]		= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$FUNCADDR]		= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$GIANT]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$SINGLE]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$DOUBLE]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$LONGDOUBLE]	= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$STRING]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$COMPOSITE]	= $$uld		+ $regro

	opcode [$hi, $imm, $handle, $$STRING]		= $$uld		+ $regro


' ********************
' *****  scaled  *****  (size = 1, 2, 4, 8 bytes)
' ********************

	opcode [$hi, $sca, $ld, $$SBYTE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$UBYTE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$SSHORT]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$USHORT]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$SLONG]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$ULONG]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$XLONG]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$GOADDR]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$SUBADDR]			= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$FUNCADDR]			= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$GIANT]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$SINGLE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$DOUBLE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$LONGDOUBLE]		= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$STRING]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$COMPOSITE]		= $$uld		+ $regrs

	opcode [$hi, $sca, $st, $$SBYTE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$UBYTE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$SSHORT]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$USHORT]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$SLONG]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$ULONG]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$XLONG]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$GOADDR]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$SUBADDR]			= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$FUNCADDR]			= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$GIANT]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$SINGLE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$DOUBLE]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$LONGDOUBLE]		= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$STRING]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$COMPOSITE]		= $$uld		+ $regrs

	opcode [$hi, $sca, $addr, $$SBYTE]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$UBYTE]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$SSHORT]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$USHORT]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$SLONG]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$ULONG]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$XLONG]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$GOADDR]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$SUBADDR]		= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$FUNCADDR]		= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$GIANT]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$SINGLE]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$DOUBLE]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$LONGDOUBLE]	= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$STRING]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$COMPOSITE]	= $$uld		+ $regrs

	opcode [$hi, $sca, $handle, $$STRING]		= $$uld		+ $regrs


' **********************
' *****  unscaled  *****  (size not 1, 2, 4, 8 bytes)  *****
' **********************

	opcode [$hi, $uns, $ld, $$SBYTE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$UBYTE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$SSHORT]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$USHORT]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$SLONG]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$ULONG]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$XLONG]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$GOADDR]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$SUBADDR]			= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$FUNCADDR]			= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$GIANT]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$SINGLE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$DOUBLE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$LONGDOUBLE]		= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$STRING]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$COMPOSITE]		= $$uld		+ $regrr

	opcode [$hi, $uns, $st, $$SBYTE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$UBYTE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$SSHORT]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$USHORT]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$SLONG]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$ULONG]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$XLONG]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$GOADDR]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$SUBADDR]			= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$FUNCADDR]			= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$GIANT]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$SINGLE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$DOUBLE]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$LONGDOUBLE]		= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$STRING]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$COMPOSITE]		= $$uld		+ $regrr

	opcode [$hi, $uns, $addr, $$SBYTE]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$UBYTE]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$SSHORT]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$USHORT]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$SLONG]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$ULONG]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$XLONG]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$GOADDR]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$SUBADDR]		= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$FUNCADDR]		= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$GIANT]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$SINGLE]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$DOUBLE]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$LONGDOUBLE]	= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$STRING]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$COMPOSITE]	= $$uld		+ $regrr

	opcode [$hi, $uns, $handle, $$STRING]		= $$uld		+ $regrr


' ******************************************
' ******************************************
' *****  dimensionKind = $excessComma  *****
' ******************************************
' ******************************************

' ***********************
' *****  immediate  *****  (offset = ele * size)
' ***********************

	opcode [$ex, $imm, $ld, $$SBYTE]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$UBYTE]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$SSHORT]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$USHORT]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$SLONG]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$ULONG]				=	$$uld		+ $regro
	opcode [$ex, $imm, $ld, $$XLONG]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$GOADDR]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$SUBADDR]			= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$FUNCADDR]			= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$GIANT]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$SINGLE]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$DOUBLE]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$LONGDOUBLE]		= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$STRING]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$COMPOSITE]		= $$uld		+ $regro

	opcode [$ex, $imm, $st, $$SBYTE]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$UBYTE]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$SSHORT]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$USHORT]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$SLONG]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$ULONG]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$XLONG]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$GOADDR]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$SUBADDR]			= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$FUNCADDR]			= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$GIANT]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$SINGLE]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$DOUBLE]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$LONGDOUBLE]		= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$STRING]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$COMPOSITE]		= $$ust		+ $roreg

	opcode [$ex, $imm, $addr, $$SBYTE]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$UBYTE]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$SSHORT]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$USHORT]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$SLONG]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$ULONG]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$XLONG]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$GOADDR]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$SUBADDR]		= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$FUNCADDR]		= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$GIANT]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$SINGLE]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$DOUBLE]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$LONGDOUBLE]	= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$STRING]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$COMPOSITE]	= $$ulda	+ $regro


' ********************
' *****  scaled  *****  (size = 1, 2, 4, 8 bytes)
' ********************

	opcode [$ex, $sca, $ld, $$SBYTE]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$UBYTE]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$SSHORT]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$USHORT]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$SLONG]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$ULONG]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$XLONG]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$GOADDR]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$SUBADDR]			= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$FUNCADDR]			= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$GIANT]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$SINGLE]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$DOUBLE]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$LONGDOUBLE]		= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$STRING]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$COMPOSITE]		= $$uld		+ $regrs

	opcode [$ex, $sca, $st, $$SBYTE]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$UBYTE]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$SSHORT]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$USHORT]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$SLONG]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$ULONG]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$XLONG]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$GOADDR]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$SUBADDR]			= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$FUNCADDR]			= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$GIANT]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$SINGLE]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$DOUBLE]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$LONGDOUBLE]		= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$STRING]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$COMPOSITE]		= $$ust		+ $rsreg

	opcode [$ex, $sca, $addr, $$SBYTE]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$UBYTE]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$SSHORT]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$USHORT]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$SLONG]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$ULONG]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$XLONG]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$GOADDR]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$SUBADDR]		= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$FUNCADDR]		= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$GIANT]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$SINGLE]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$DOUBLE]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$LONGDOUBLE]	= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$STRING]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$COMPOSITE]	= $$ulda	+ $regrs


' **********************
' *****  unscaled  *****  (size not 1, 2, 4, 8 bytes)  *****
' **********************

	opcode [$ex, $uns, $ld, $$SBYTE]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$UBYTE]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$SSHORT]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$USHORT]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$SLONG]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$ULONG]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$XLONG]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$GOADDR]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$SUBADDR]			= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$FUNCADDR]			= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$GIANT]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$SINGLE]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$DOUBLE]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$LONGDOUBLE]		= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$STRING]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$COMPOSITE]		= $$uld		+ $regrr

	opcode [$ex, $uns, $st, $$SBYTE]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$UBYTE]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$SSHORT]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$USHORT]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$SLONG]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$ULONG]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$XLONG]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$GOADDR]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$SUBADDR]			= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$FUNCADDR]			= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$GIANT]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$SINGLE]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$DOUBLE]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$LONGDOUBLE]		= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$STRING]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$COMPOSITE]		= $$ust		+ $rrreg

	opcode [$ex, $uns, $addr, $$SBYTE]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$UBYTE]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$SSHORT]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$USHORT]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$SLONG]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$ULONG]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$XLONG]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$GOADDR]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$SUBADDR]		= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$FUNCADDR]		= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$GIANT]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$SINGLE]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$DOUBLE]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$LONGDOUBLE]	= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$STRING]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$COMPOSITE]	= $$ulda	+ $regrr
END SUB


' ********************
' *****  ERRORS  *****
' ********************

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeRegAddr:
	XERROR = ERROR_REGADDR
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION

eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' #########################
' #####  Expresso ()  #####
' #########################

FUNCTION  Expresso (old_test, old_op, old_prec, old_data, old_type)
	SHARED	checkBounds,  library, programName$
	SHARED SSHORT typeConvert[]
	SHARED	typeHigher[]
	SHARED	typeEleCount[],  typeEleSize[]
	SHARED	typeEleToken[],  typeEleType[],  typeEleArg[]
	SHARED	typeEleStringSize[],  typeEleUBound[]
	SHARED	cop[],  m_reg[],  m_addr[]
	SHARED	funcSymbol$[],  funcLabel$[],  funcToken[]
	SHARED	funcScope[],  funcKind[],  funcType[],  funcArgSize[],  funcArg[]
	SHARED	tabArg[],  tabType[]
	SHARED	m_addr$[],  q_type_long[],  q_type_long_or_addr[],  r_addr[],  r_addr$[]
	SHARED	tab_sym[],  tab_sym$[],  tab_lab$[],  reg86$[],  reg86c$[]
	SHARED	typeSize[],  typeSize$[],  typeName$[]
	SHARED	XERROR
	SHARED	ERROR_BITSPEC,  ERROR_BYREF,  ERROR_BYVAL,  ERROR_COMPILER
	SHARED	ERROR_COMPONENT,  ERROR_EXPLICIT_VARIABLE,  ERROR_KIND_MISMATCH,  ERROR_LITERAL
	SHARED	ERROR_NEED_EXCESS_COMMA,  ERROR_OVERFLOW,  ERROR_REGADDR
	SHARED	ERROR_SYNTAX,  ERROR_TOO_FEW_ARGS,  ERROR_TOO_MANY_ARGS
	SHARED	ERROR_TYPE_MISMATCH,  ERROR_UNDECLARED,  ERROR_UNDEFINED
	SHARED	ERROR_UNIMPLEMENTED
	SHARED	T_TESTL
	SHARED	T_NOT,      T_NOTL,       T_NOTBIT,     T_TILDA
	SHARED	T_AND,      T_ANDL,       T_ANDBIT
	SHARED	T_XOR,      T_XORL,       T_XORBIT
	SHARED	T_OR,       T_ORL,        T_ORBIT
	SHARED	T_ADDR_OP,  T_HANDLE_OP
	SHARED	T_EQ,   T_NE,   T_LT,   T_LE,   T_GE,   T_GT,   T_EQL
	SHARED	T_NEQ,  T_NNE,  T_NLT,  T_NLE,  T_NGE,  T_NGT
	SHARED	T_COLON,  T_COMMA,  T_SEMI
	SHARED	T_ABS,  T_ADD,  T_ASC,  T_ATSIGN,  T_BIN_D,  T_BINB_D,  T_BITFIELD
	SHARED	T_CEIL,  T_CHR_D,  T_CJUST_D,  T_CLOSE,  T_CLR,  T_CSIZE,  T_CSIZE_D
	SHARED	T_CSTRING_D,  T_CMP
	SHARED	T_DHIGH,  T_DLOW,  T_DMAKE,  T_DOUBLE,  T_DOUBLEAT
	SHARED	T_EOF,  T_ERROR,  T_ERROR_D,  T_EXTS,  T_EXTU
	SHARED  T_FIX,  T_FORMAT_D
	SHARED	T_FUNCADDR,  T_FUNCADDRAT,  T_FUNCADDRESS
	SHARED	T_GHIGH,  T_GIANT,  T_GIANTAT,  T_GLOW,  T_GMAKE
	SHARED	T_GOADDR,  T_GOADDRAT,  T_GOADDRESS
	SHARED	T_HEX_D,  T_HEXX_D,  T_HIGH0,  T_HIGH1
	SHARED	T_INCHR,  T_INCHRI,  T_INFILE_D,  T_INLINE_D
	SHARED	T_INSTR,  T_INSTRI,  T_INT
	SHARED	T_LBRACE,  T_LBRACES,  T_LBRAK,  T_LCASE_D,  T_LCLIP_D,  T_LEFT_D
	SHARED	T_LEN,  T_LIBRARY,  T_LJUST_D,  T_LOF,  T_LPAREN,  T_LTRIM_D
	SHARED	T_MAKE,  T_MAX,  T_MID_D,  T_MIN,  T_MINUS
	SHARED	T_NULL_D,  T_OCT_D,  T_OCTO_D,  T_OPEN
	SHARED	T_POF,  T_PLUS,  T_PROGRAM_D,  T_QUIT
	SHARED	T_RBRACE,  T_RBRAK,  T_RCLIP_D,  T_REDIM,  T_RIGHT_D
	SHARED	T_RINCHR,  T_RINCHRI,  T_RINSTR,  T_RINSTRI,  T_RJUST_D
	SHARED	T_ROTATEL,  T_ROTATER,  T_ROUND,  T_ROUNDNE,  T_RPAREN,  T_RTRIM_D
	SHARED	T_SBYTE,  T_SBYTEAT,  T_SEEK,  T_SET,  T_SGN,  T_SHELL
	SHARED	T_SIGN,  T_SIGNED_D,  T_SINGLE,  T_SINGLEAT,  T_SIZE
	SHARED	T_SLONG,  T_SLONGAT,  T_SMAKE,  T_SPACE_D
	SHARED	T_SSHORT,  T_SSHORTAT,  T_STR_D,  T_STRING,  T_STRING_D
	SHARED	T_STUFF_D,  T_SUBADDR,  T_SUBADDRAT,  T_SUBADDRESS
	SHARED	T_SUBTRACT,  T_TAB,  T_TRIM_D,  T_TYPE
	SHARED	T_UBOUND,  T_UBYTE,  T_UBYTEAT,  T_UCASE_D
	SHARED	T_ULONG,  T_ULONGAT,  T_USHORT,  T_USHORTAT
	SHARED	T_VERSION_D,  T_XLONG,  T_XLONGAT,  T_XMAKE
  SHARED  T_LONGDOUBLE, T_LONGDOUBLEAT
	SHARED	a0,  a0_type,  a1,  a1_type,  toes,  toms,  tokenPtr
	SHARED	got_expression,  infunc,  inPrint,  funcaddrFuncNumber
	SHARED	oos,  dim_array,  func_number,  nullstringer
	SHARED	preType,  componentNumber
	SHARED	programToken,  versionToken
	SHARED	labelNumber,  compositeArg
	SHARED  lineNumber
	SHARED	UBYTE  oos[]
	STATIC	argToken[]
	STATIC	GOADDR opKind[]
	STATIC	GOADDR dataKind[]
	STATIC	GOADDR intrinToken[]
	STATIC	GOADDR firstIntrinToken[]
	STATIC	SBYTE inlineToken[]
	AUTOX  FUNCARG  farg[]
	AUTOX  FUNCARG  farg
	AUTOX  UBYTE  argReg[]
	AUTOX  UBYTE  orgReg[]
'	SHARED USING_XXXFORMAT
	SHARED explicitStatement

	IFZ argToken[] THEN GOSUB InitArrays

	got_expression = $$FALSE
	args = 0
	DO
		token = NextToken()
		kind = token{$$KIND}
	LOOP WHILE (token = T_ADD)				' skip unary pluses

' ***********************************
' *****  EXPECTING DATA OBJECT  *****
' ***********************************

	GOTO @dataKind [kind]		' dispatch routine based upon kind of token
	old_test = 0						' unrecognized kinds aren't expression starters
	old_op = token
	old_prec = 0
	old_data = 0
	old_type = 0
	RETURN


' *****  Expecting data, got character  *****  @func() = invoke func()

express_character:
	IF (token == T_ATSIGN) THEN GOTO express_function
	GOTO eeeSyntax


' *****  Expecting data object, got simple kind of data object  *****
'        (variable, constant, literal, syscon, charcons)

express_var:
	got_expression = $$TRUE
	new_data = token
	bitCheck = $$FALSE
	check = PeekToken()
	nn = token{$$NUMBER}
	new_allo = token{$$ALLO}
	IFZ new_allo THEN
		symboloid$ = tab_sym$[nn]
		IF symboloid$ THEN
			IF (symboloid${0} == '#') THEN
				new_allo = $$SHARED
				IF (symboloid${1} == '#') THEN new_allo = $$EXTERNAL
			ENDIF
		ENDIF
	ENDIF
	new_type = token{$$TYPE}
	IFZ new_type THEN new_type = tabType[nn]

	IFZ new_type THEN
		IF ((new_allo == $$SHARED) OR (new_allo == $$EXTERNAL)) THEN
			symboloid$ = tab_sym$[nn]
			IF (symboloid${0} == '#') THEN
				IFZ m_addr$[nn] THEN AssignAddress (token)
				new_type = TheType (token)
			ENDIF
		ENDIF
	ENDIF

	IFZ new_type THEN
		IF explicitStatement THEN GOTO eeeExplicit		' zzz
		new_type = TheType (token)
	ENDIF

' *****  COMPOSITE DATA TYPE  *****

' The following skips getting the data for the composite if
' it's followed by a kind = symbol token.  This really isn't
' a very good way to do it.  Change Composite () so there's
' a way to get data if it's not a stand-alone composite for
' which the token is the necessary result needed here.

' Note:		It is necessary to get the TOKEN only in such
'					cases, or places for intermediate SCOMPLEX and
'					DCOMPLEX don't get made up and expressions can
'					generate bogus code...

express_component:
	IF (new_type >= $$SCOMPLEX) THEN
		ctest = PeekToken(){$$KIND}
		IF ((ctest = $$KIND_SYMBOLS) OR (ctest = $$KIND_ARRAY_SYMBOLS)) THEN
			Composite ($$GETDATA, @new_type, @new_data, 0, 0)
      IF XERROR THEN EXIT FUNCTION 'line missing in original -> endless loops for certain errors
			IF (new_type = $$STRING) THEN
				stackString = $$TRUE
				IFZ oos THEN PRINT "oos = 0": GOTO eeeCompiler
				accArray	= oos[oos]
				new_data	= Top ()
				token			= $$T_VARIABLES OR ($$STRING << 16) OR new_data
				new_data	= 0
			ELSE
				new_data	= 0
				token			= 0
				nn				= 0
			ENDIF
		ENDIF
		check 	= PeekToken ()
	ENDIF

	IF ((check == T_LBRACE) OR (check == T_LBRACES)) THEN
		SELECT CASE kind
			CASE $$KIND_VARIABLES, $$KIND_LITERALS, $$KIND_CONSTANTS, $$KIND_SYSCONS
			CASE ELSE:	GOTO eeeSyntax
		END SELECT
		SELECT CASE new_type
			CASE $$STRING
						GOTO express_array						' a${n} or a${n, m} form
			CASE $$GIANT, $$DOUBLE, $$LONGDOUBLE
						GOTO eeeTypeMismatch
			CASE ELSE
						bitCheck = check							' a{n}, a{{n}}, a{n,m}, a{{n,m}}
		END SELECT
	ENDIF

	IF (new_type == $$STRING) THEN
		IFZ stackString THEN INC oos: oos[oos] = 'v'
	ENDIF

	IFZ new_type THEN new_type = $$XLONG
	IF (new_type < $$SLONG) THEN new_type = $$SLONG

' The next 3 lines of code are replaced by the 5 lines that follow
' to prevent errors on lines like  p# = (a*1.0)/b  where a and b
' are ULONG variables.

'	IF ((old_type == $$ULONG) AND (kind == $$KIND_LITERALS)) THEN
'		new_type = $$ULONG
'	ENDIF

	IF (old_type == $$ULONG) THEN
' SVG 20010517 - removed empty IF statements
'		IF (new_type < $$SINGLE) THEN
'			IF (kind = $$KIND_LITERALS) THEN
'				new_type = $$ULONG
'			ENDIF
'		ENDIF
		IF ((new_type == $$SINGLE) OR (new_type == $$DOUBLE) OR (new_type == $$LONGDOUBLE)) THEN
			aaaaa = 11111
		ENDIF
	ENDIF

	IF (kind = $$KIND_CONSTANTS) OR (kind = $$KIND_SYSCONS) THEN
		IFZ r_addr$[nn] THEN GOTO eeeUndefined
	ENDIF

	IF new_data THEN
		IFZ m_addr$[nn] THEN AssignAddress (token)
		IF XERROR THEN EXIT FUNCTION
	ENDIF

	IF bitCheck THEN
		IF new_data THEN
			GOTO extract_bits_from_variable
		ELSE
			INC tokenPtr
			GOTO extract_bits_from_expression
		ENDIF
	ENDIF


' *************************************************
' *****  Got data, now expecting an operator  *****
' *************************************************

express_op:
	new_zip = $$FALSE									' new.zip TRUE if new.op is data kind
	token = NextToken ()							' expecting operator
	kind = token{$$KIND}							' kind should be operator

	GOTO @opKind [kind]								' dispatch based on kind.  Fall through on
	new_zip = $$TRUE								'   data kinds and other non-binary-ops
	new_op = token
	new_prec = 0
	GOTO exo

express_op_rem:
	token = $$T_STARTS								' got remark/comment token
	GOTO express_ops

express_op_lparen:
	IF ((token = T_LBRACE) OR (token = T_LBRACES)) THEN
		GOTO extract_bits_from_expression
	ENDIF
	old_test = new_test
	old_op = token										' got "(" when expecting an operator
	old_prec = 0
	old_data = new_data
	old_type = new_type
	RETURN

express_op_component:
	IF (new_type < $$SCOMPLEX) THEN GOTO eeeComponent
	DEC tokenPtr
	GOTO express_component


' ******************************************
' *****  Binary operator or separator  *****
' ******************************************

express_ops:
	new_op = token
	new_prec = new_op{$$PREC}
exo:
	IF XERROR THEN EXIT FUNCTION
	kind = new_op{$$KIND}

' *****  new_prec > old_prec  *****

	IF (new_prec > old_prec) THEN
		IF new_test THEN GOSUB ExtractBit
		Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
		IF new_test AND (old_test != -1) THEN GOSUB ExtractBit
		GOTO exo
	ENDIF

' *****  new_prec <= old_prec  *****

	IF (old_op{$$KIND} = $$KIND_ADDR_OPS) THEN
		old_test = 0
		old_op = new_op
		old_prec = new_prec
		old_data = 0
		old_type = $$XLONG
		RETURN
	ENDIF

	old_table = ((old_op >> 20) AND 0x0F)				' old.table = imbedded table #
	IF new_zip THEN
		new_table = 0															' new.op = some kind of data
	ELSE
		new_table = ((new_op >> 20) AND 0x0F)			' xxx.table = 0 if xxx.op = () []
	ENDIF

	IFZ (old_table OR new_table) THEN						' matching parentheses
		old_test = new_test
		old_op   = new_op
		old_prec = new_prec
		old_data = new_data
		old_type = new_type
		RETURN
	ENDIF

' STRINGS and SCOMPLEX / DCOMPLEX arithmetic

	SELECT CASE old_type
		CASE $$STRING
					IF (new_type != $$STRING) THEN GOTO eeeTypeMismatch
					SELECT CASE old_table
						CASE 2:			old_cop			= 0
												old_to_type = old_type	' string compares:  a$ op b$
												new_to_type = new_type	' op is =, <>, <, <=, etc...
												old_op_type = old_type
												result_type = $$XLONG
						CASE 5:			old_cop			= 0
												old_to_type = old_type	' string concatenate:  a$ + b$
												new_to_type = new_type
												old_op_type = old_type
												result_type = old_type
						CASE ELSE:	GOTO eeeTypeMismatch
					END SELECT
		CASE $$SCOMPLEX
					IF (new_type != $$SCOMPLEX) THEN GOTO eeeTypeMismatch
					SELECT CASE old_table
						CASE 2, 4, 5, 8, 9, 10
						CASE ELSE: GOTO eeeTypeMismatch
					END SELECT
					old_cop			= 0
					old_to_type = $$SCOMPLEX
					new_to_type = $$SCOMPLEX
					old_op_type = $$SCOMPLEX
					result_type = $$SCOMPLEX
					IF (old_table = 2) THEN result_type = $$XLONG
		CASE $$DCOMPLEX
					IF (new_type != $$DCOMPLEX) THEN GOTO eeeTypeMismatch
					SELECT CASE old_table
						CASE 2, 4, 5, 8, 9, 10
						CASE ELSE: GOTO eeeTypeMismatch
					END SELECT
					old_cop			= 0
					old_to_type = $$DCOMPLEX
					new_to_type = $$DCOMPLEX
					old_op_type = $$DCOMPLEX
					result_type = $$DCOMPLEX
					IF (old_table = 2) THEN result_type = $$XLONG
		CASE ELSE
					IF (old_type > $$DCOMPLEX) THEN GOTO eeeTypeMismatch
					IF (new_type > $$DCOMPLEX) THEN GOTO eeeTypeMismatch
					IF (new_type = $$STRING) THEN GOTO eeeTypeMismatch

					old_cop = cop[old_table, old_type, new_type]

					old_to_type = old_cop {$$BYTE3}
					new_to_type = old_cop {$$BYTE2}
					old_op_type = old_cop {$$BYTE1}
					result_type = old_cop {$$BYTE0}
	END SELECT

	IF (old_cop < 0) THEN DEC tokenPtr: PRINT "Expresso : typemismatcha" : GOTO eeeTypeMismatch

	st = old_type
	IF old_to_type THEN st = old_to_type
	xt = new_type
	IF new_to_type THEN xt = new_to_type
	ot = old_op_type
	rt = result_type

	oo = old_data{$$NUMBER}
	nn = new_data{$$NUMBER}
	ro = r_addr[oo]
	rn = r_addr[nn]

	SELECT CASE old_data{$$KIND}
		CASE $$KIND_LITERALS, $$KIND_CONSTANTS:		ro = 0
		CASE $$KIND_CHARCONS, $$KIND_SYSCONS:			ro = 0
	END SELECT

	accx = 0												' accx = 3 :  a1 full  . a0 full
	IF a0 THEN accx = accx + 1			' accx = 2 :  a1 full  . a0 empty
	IF a1 THEN accx = accx + 2			' accx = 1 :  a1 empty . a0 full
'                                 ' accx = 0 :  a1 empty . a0 empty



	IF (old_type < $$SLONG) THEN old_type = $$SLONG
	IF (new_type < $$SLONG) THEN new_type = $$SLONG
	SELECT CASE old_type
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE:	oldFlop = $$TRUE
		CASE ELSE:								oldFlop = $$FALSE
	END SELECT
	SELECT CASE new_type
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE:	newFlop = $$TRUE
		CASE ELSE:								newFlop = $$FALSE
	END SELECT
' SVG 20010517 - simplified following lines
	newToFlop = (oldFlop AND !newFlop)
	oldToFlop = (newFlop AND !oldFlop)

	SELECT CASE ot
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE:	i486flop = $$TRUE
		CASE ELSE:															i486flop = $$FALSE
	END SELECT


'   *****  UNARY operators first  *****

	IF (rn AND (rn < $$IMM16)) THEN GOTO eeeCompiler
	IF (old_op{$$KIND} = $$KIND_UNARY_OPS) THEN
		IF new_data THEN					' UOP var
			IFZ rn THEN
				GOTO uop_var_mem			' UOP var.mem
			ELSE
				GOTO uop_var_reg			' UOP var.reg
			ENDIF
		ELSE
			IF a0 AND (a0 = toes) THEN
				GOTO uop_stk_reg_a0		' UOP stk.reg.a0
			ENDIF
			IF a1 AND (a1 = toes) THEN
				GOTO uop_stk_reg_a1		' UOP stk.reg.a1
			ENDIF
			GOTO uop_stk_mem				' UOP stk.mem  (error)
		ENDIF
	ENDIF

'   *****  BINARY operators  *****

'   *****  var  OP  var  *****

	IF ro THEN GOTO eeeCompiler
	IF rn THEN
		IF (rn < $$IMM16) THEN GOTO eeeCompiler
		IF (rn > $$CONNUM) THEN GOTO eeeCompiler
	ENDIF
	IF (old_data <> 0) AND (new_data <> 0) THEN			' var OP var
		IFZ rn THEN
			GOTO var_mem_op_var_mem						' var.mem OP var.mem
		ELSE
			GOTO var_mem_op_var_reg						' var.mem OP var.reg
		ENDIF
	ENDIF

'   *****  var  OP  stk  *****

	IF ((old_data <> 0) AND (new_data = 0)) THEN			' var OP stk
		IFZ ro THEN
			IF a0 AND (a0 = toes) THEN
				GOTO var_mem_op_stk_reg_a0				' var.mem OP stk.reg.a0
			ENDIF
			IF a1 AND (a1 = toes) THEN
				GOTO var_mem_op_stk_reg_a1				' var.mem OP stk.reg.a1
			ENDIF
			GOTO var_mem_op_stk_mem							' var.mem OP stk.mem  (error)
		ENDIF
	ENDIF

'   *****  stk  OP  var  *****

	IF (old_data = 0) AND (new_data <> 0) THEN	' stk OP var
		IFZ rn THEN
			IF a0 AND (a0 = toes) THEN
				GOTO stk_reg_a0_op_var_mem				' stk.reg.a0 OP var.mem
			ENDIF
			IF a1 AND (a1 = toes) THEN
				GOTO stk_reg_a1_op_var_mem				' stk.reg.a1 OP var.mem
			ENDIF
			GOTO stk_mem_op_var_mem							' stk.mem OP var.mem  (error)
		ELSE
			IF a0 AND (a0 = toes) THEN
				GOTO stk_reg_a0_op_var_reg				' stk.reg.a0 OP var.reg
			ENDIF
			IF a1 AND (a1 = toes) THEN
				GOTO stk_reg_a1_op_var_reg				' stk.reg.a1 OP var.reg
			ENDIF
			GOTO stk_mem_op_var_reg							' stk.mem OP var.reg (error)
		ENDIF
	ENDIF

'   *****  stk  OP  stk  *****

	IF (old_data = 0) AND (new_data = 0) THEN		' stk OP stk
		IF a0 AND (a0 = toes) THEN
			IF a1 AND (a1 = toes - 1) THEN
				GOTO stk_reg_a1_op_stk_reg_a0			' stk.reg.a0 OP stk.reg.a1
			ELSE
				GOTO stk_mem_op_stk_reg_a0				' stk.mem OP stk.reg.a0
			ENDIF
		ENDIF
		IF a1 AND (a1 = toes) THEN
			IF a0 AND (a0 = toes - 1) THEN
				GOTO stk_reg_a0_op_stk_reg_a1			' stk.reg.a1 OP stk.reg.a0
			ELSE
				GOTO stk_mem_op_stk_reg_a1				' stk.mem OP stk.reg.a1
			ENDIF
		ENDIF
	ENDIF
	PRINT "expresso1": GOTO eeeCompiler

' ***********************************************
' *****  THE ROUTINES JUMPED TO FROM ABOVE  *****
' ***********************************************


' *************************************
' *****  UNARY OPERATOR ROUTINES  *****
' *************************************

uop_var_mem:
	IF (accx = 3) THEN GOTO uvma
	IF (accx = 2) THEN GOTO uvmb
	IF (accx = 1) THEN GOTO uvmc
	IF (accx = 0) THEN GOTO uvmb
	PRINT "expresso2": GOTO eeeCompiler

uvma:
	IF (a1 > a0) THEN GOTO uvm0
	IF (a1 < a0) THEN GOTO uvm1
	PRINT "expresso3": GOTO eeeCompiler

uvm0:   Push ($$RA0, a0_type)
uvmb:   Move ($$RA0, new_type, nn, new_type)
				Conv ($$RA0, new_to_type, $$RA0, new_type)
				Uop ($$RA0, @old_op, $$RA0, rt, ot, xt)
				INC toes
				a0 = toes
				GOTO done
uvm1:   Push ($$RA1, a1_type)
uvmc:   Move ($$RA1, new_type, nn, new_type)
				Conv ($$RA1, new_to_type, $$RA1, new_type)
				Uop ($$RA1, @old_op, $$RA1, rt, ot, xt)
				INC toes
				a1 = toes: a1_type = rt
				GOTO done



uop_var_reg:
	IFZ new_to_type THEN GOTO uvrx
uvrn:
	IF (accx = 3) THEN GOTO uvrna
	IF (accx = 2) THEN GOTO uvrnb
	IF (accx = 1) THEN GOTO uvrnc
	IF (accx = 0) THEN GOTO uvrnb
	PRINT "expresso4": GOTO eeeCompiler
uvrna:
	IF (a1 > a0) THEN GOTO uvrna0
	IF (a1 < a0) THEN GOTO uvrna1
	PRINT "expresso5": GOTO eeeCompiler
uvrna0: Push ($$RA0, a0_type)
uvrnb:  Conv ($$RA0, new_to_type, nn, new_type)
				Uop ($$RA0, @old_op, $$RA0, rt, ot, xt)
				INC toes
				a0 = toes
				a0_type = rt
				GOTO done
uvrna1: Push ($$RA1, a1_type)
uvrnc:  Conv ($$RA1, new_to_type, nn, new_type)
				Uop ($$RA1, @old_op, $$RA1, rt, ot, xt)
				INC toes
				a1 = toes
				a1_type = rt
				GOTO done
uvrx:
	IF (accx = 3) THEN GOTO uvrxa
	IF (accx = 2) THEN GOTO uvrxb
	IF (accx = 1) THEN GOTO uvrxc
	IF (accx = 0) THEN GOTO uvrxb
	PRINT "expresso6": GOTO eeeCompiler
uvrxa:
	IF (a1 > a0) THEN GOTO uvrxa0
	IF (a1 < a0) THEN GOTO uvrxa1
	PRINT "expresso7": GOTO eeeCompiler
uvrxa0: Push ($$RA0, a0_type)
uvrxb:  Move ($$RA0, xt, nn, xt)
				Uop ($$RA0, @old_op, $$RA0, rt, ot, xt)
				INC toes
				a0 = toes
				a0_type = rt
				GOTO done
uvrxa1: Push ($$RA1, a1_type)
uvrxc:	Move ($$RA1, xt, nn, xt)
			  Uop ($$RA1, @old_op, $$RA1, rt, ot, xt)
				INC toes
				a1 = toes
				a1_type = rt
				GOTO done



uop_stk_reg_a0:
				Conv ($$RA0, new_to_type, $$RA0, new_type)
				Uop ($$RA0, @old_op, $$RA0, rt, ot, xt)
				a0 = toes
				a0_type = rt
				GOTO done



uop_stk_reg_a1:
				Conv ($$RA1, new_to_type, $$RA1, new_type)
				Uop ($$RA1, @old_op, $$RA1, rt, ot, xt)
				a1 = toes
				a1_type = rt
				GOTO done



uop_stk_mem:
	PRINT "expresso8": GOTO eeeCompiler



' ****************************************
' *****  BINARY  OPERATOR  ROUTINES  *****
' ****************************************

var_mem_op_var_mem:
	IF (accx = 3) THEN GOTO fc
	IF (accx = 2) THEN GOTO f8x
	IF (accx = 1) THEN GOTO f4x
	IF (accx = 0) THEN GOTO fcx
	PRINT "expresso9": GOTO eeeCompiler
fc:
	IF (a1 > a0) THEN GOTO fca
	IF (a1 < a0) THEN GOTO fcb
	PRINT "expresso10": GOTO eeeCompiler
fca:	Push ($$RA0, a0_type)
f8x:	Push ($$RA1, a1_type)
fcx:	IF i486flop THEN
'				Move ($$RA0, old_type, oo, old_type)	' xnt0l
				FloatLoad ($$RA0, oo, old_type)				' xnt0l
			ELSE
				Move ($$RA0, old_type, oo, old_type)
				Conv ($$RA0, old_to_type, $$RA0, old_type)
			ENDIF
			IF i486flop THEN
'				Move ($$RA1, new_type, nn, new_type)	' xnt0l
				FloatLoad ($$RA1, nn, new_type)				' xnt0l
			ELSE
				Move ($$RA1, new_type, nn, new_type)
				Conv ($$RA1, new_to_type, $$RA1, new_type)
			ENDIF
			Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
			INC toes
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done
fcb:	Push ($$RA1, a1_type)
f4x:	Push ($$RA0, a0_type)
			GOTO fcx



var_mem_op_var_reg:
	IF (accx = 3) THEN GOTO ec
	IF (accx = 2) THEN GOTO e8
	IF (accx = 1) THEN GOTO e4
	IF (accx = 0) THEN GOTO e0
	PRINT "expresso11": GOTO eeeCompiler
ec:	IF (new_to_type OR (new_type = $$STRING)) THEN GOTO ecn ELSE GOTO ecx
e8:	IF (new_to_type OR (new_type = $$STRING)) THEN GOTO e8n ELSE GOTO e8x
e4:	IF (new_to_type OR (new_type = $$STRING)) THEN GOTO e4n ELSE GOTO e4x
e0:	IF (new_to_type OR (new_type = $$STRING)) THEN GOTO ecnx ELSE GOTO e8x
ecn:
	IF (a1 > a0) THEN GOTO ecna
	IF (a1 < a0) THEN GOTO ecnb
	PRINT "expresso12": GOTO eeeCompiler
ecna:	Push ($$RA0, a0_type)
e8n:	Push ($$RA1, a1_type)
ecnx:	Move ($$RA0, old_type, oo, old_type)
			Conv ($$RA0, old_to_type, $$RA0, old_type)
			Conv ($$RA1, new_to_type, nn, new_type)
			Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
			INC toes
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done
ecnb:	Push ($$RA1, a1_type)
e4n:	Push ($$RA0, a0_type)
			GOTO ecnx
ecx:
	IF (a1 > a0) THEN GOTO ecxa
	IF (a1 < a0) THEN GOTO ecxb
	PRINT "expresso13": GOTO eeeCompiler
ecxa:	Push ($$RA0, a0_type)
e8x:	Move ($$RA0, old_type, oo, old_type)
			Conv ($$RA0, old_to_type, $$RA0, old_type)
			Op ($$RA0, $$RA0, @old_op, nn, rt, st, ot, xt)
			INC toes
			a0 = toes
			a0_type = rt
			GOTO done
ecxb:	Push ($$RA1, a1_type)
e4x:	Move ($$RA1, old_type, oo, old_type)
			Conv ($$RA1, old_to_type, $$RA1, old_type)
			Op ($$RA1, $$RA1, @old_op, nn, rt, st, ot, xt)
			INC toes
			a1 = toes
			a1_type = rt
			GOTO done






var_mem_op_stk_reg_a0:
	IF (accx = 3) THEN GOTO cca
	IF (accx = 1) THEN GOTO c4
	PRINT "expresso26": GOTO eeeCompiler
cca:	Push ($$RA1, a1_type)
c4:		IF i486flop THEN
				Conv ($$RA0, new_to_type, $$RA0, new_type)
'				Move ($$RA1, old_type, oo, old_type)	' xnt0l
				FloatLoad ($$RA1, oo, old_type)				' xnt0l
			ELSE
				Conv ($$RA0, new_to_type, $$RA0, new_type)
				Move ($$RA1, old_type, oo, old_type)
				Conv ($$RA1, old_to_type, $$RA1, old_type)
			ENDIF
			Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done



var_mem_op_stk_reg_a1:
				IF (accx = 3) THEN GOTO ccb
				IF (accx = 2) THEN GOTO c8
				PRINT "expresso27": GOTO eeeCompiler
ccb:	Push ($$RA0, a0_type)
c8:		IF i486flop THEN
				FloatLoad ($$RA0, oo, old_type)				' xnt0l
				Conv ($$RA1, new_to_type, $$RA1, new_type)
'	SVG 20010517 - correction for new_type not a float
				IF !newToFlop THEN
					Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
				ELSE
					Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				ENDIF
			ELSE
				Move ($$RA0, old_type, oo, old_type)
				Conv ($$RA0, old_to_type, $$RA0, old_type)
				Conv ($$RA1, new_to_type, $$RA1, new_type)
				Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
			ENDIF
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done



var_mem_op_stk_mem:
	PRINT "expresso28": GOTO eeeCompiler



stk_reg_a0_op_var_mem:
	IF (accx = 3) THEN GOTO x3c0a
	IF (accx = 1) THEN GOTO x3c0b
	PRINT "expresso32": GOTO eeeCompiler
x3c0a:  Push ($$RA1, a1_type)
x3c0b:	IF i486flop THEN
					Conv ($$RA0, old_to_type, $$RA0, old_type)
'					Move ($$RA1, new_type, nn, new_type)	' xnt0l
					FloatLoad ($$RA1, nn, new_type)				' xnt0l
				ELSE
				  Move ($$RA1, new_type, nn, new_type)
					Conv ($$RA1, new_to_type, $$RA1, new_type)
					Conv ($$RA0, old_to_type, $$RA0, old_type)
				ENDIF
				Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done


stk_reg_a1_op_var_mem:
				IF accx = 3 THEN GOTO x3c1a
				IF accx = 2 THEN GOTO x3c1b
				PRINT "expresso33": GOTO eeeCompiler
x3c1a:  Push ($$RA0, a0_type)
x3c1b:	IF i486flop THEN
'					Move ($$RA0, new_type, nn, new_type)	' xnt0l
					FloatLoad ($$RA0, nn, new_type)				' xnt0l
				ELSE
				  Move ($$RA0, new_type, nn, new_type)
					Conv ($$RA0, new_to_type, $$RA0, new_type)
				ENDIF
				Conv ($$RA1, old_to_type, $$RA1, old_type)
'	SVG 20010517 - correction for case if old_type is a float
				IF oldFlop THEN
					Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				ELSE
					Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
				ENDIF
				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done



stk_mem_op_var_mem:
	PRINT "expresso34": GOTO eeeCompiler



stk_reg_a0_op_var_reg:
	cvcv = 0
	IF old_to_type THEN cvcv = cvcv + 2
	IF (new_to_type OR (new_type = $$STRING)) THEN cvcv = cvcv + 1
	IF (accx = 3) THEN GOTO x2ca
	IF (accx = 1) THEN GOTO x24a
	PRINT "expresso35": GOTO eeeCompiler
x2ca:
	IF (cvcv = 3) THEN GOTO x2cona
	IF (cvcv = 2) THEN GOTO x2coxa
	IF (cvcv = 1) THEN GOTO x2cona
	IF (cvcv = 0) THEN GOTO x2cxxa
	PRINT "expresso36": GOTO eeeCompiler
x24a:
	IF (cvcv = 3) THEN GOTO x24ona
	IF (cvcv = 2) THEN GOTO x2coxa
	IF (cvcv = 1) THEN GOTO x24ona
	IF (cvcv = 0) THEN GOTO x2cxxa
	PRINT "expresso37": GOTO eeeCompiler
x2cona: Push ($$RA1, a1_type)
x24ona: Conv ($$RA1, new_to_type, nn, new_type)
				Conv ($$RA0, old_to_type, $$RA0, old_type)
				Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done
x2coxa: Conv ($$RA0, old_to_type, $$RA0, old_type)
x2cxxa: Op ($$RA0, $$RA0, @old_op, nn, rt, st, ot, xt)
				a0 = toes
				GOTO done



stk_reg_a1_op_var_reg:
	cvcv = 0
	IF old_to_type THEN cvcv = cvcv + 2
	IF (new_to_type OR (new_type = $$STRING)) THEN cvcv = cvcv + 1
	IF (accx = 3) THEN GOTO x2cb
	IF (accx = 2) THEN GOTO x28b
	PRINT "expresso38": GOTO eeeCompiler
x2cb:
	IF (cvcv = 3) THEN GOTO x2conb
	IF (cvcv = 2) THEN GOTO x2coxb
	IF (cvcv = 1) THEN GOTO x2conb
	IF (cvcv = 0) THEN GOTO x2cxxb
	PRINT "expresso39": GOTO eeeCompiler
x28b:
	IF (cvcv = 3) THEN GOTO x28onb
	IF (cvcv = 2) THEN GOTO x2coxb
	IF (cvcv = 1) THEN GOTO x28onb
	IF (cvcv = 0) THEN GOTO x2cxxb
	PRINT "expresso40": GOTO eeeCompiler
x2conb: Push ($$RA0, a0_type)
x28onb: Conv ($$RA0, new_to_type, nn, new_type)
				Conv ($$RA1, old_to_type, $$RA1, old_type)
		'	SVG 20010517 - correction for case when old_type is a float
				IF newToFlop THEN
					Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				ELSE
					Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
				ENDIF

				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done
x2coxb: Conv ($$RA1, old_to_type, $$RA1, old_type)
x2cxxb: Op ($$RA1, $$RA1, @old_op, nn, rt, st, ot, xt)
				a1 = toes: a1_type = rt
				GOTO done



stk_mem_op_var_reg:
	PRINT "expresso41": GOTO eeeCompiler



stk_reg_a0_op_stk_reg_a1:
	Conv ($$RA0, old_to_type, $$RA0, old_type)
	Conv ($$RA1, new_to_type, $$RA1, new_type)
	IF oldToFlop THEN GOTO sr1osr0a								' SVG 20010517
sr0osr1a:
	Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
	DEC toes
	a1 = 0: a1_type = 0
	a0 = toes
	GOTO done



stk_reg_a1_op_stk_reg_a0:
	Conv ($$RA1, old_to_type, $$RA1, old_type)
	Conv ($$RA0, new_to_type, $$RA0, new_type)
	IF oldFlop THEN GOTO sr0osr1a									' SVG 20010517
sr1osr0a:
	Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
	DEC toes
	a1 = 0: a1_type = 0
	a0 = toes
	GOTO done



stk_mem_op_stk_reg_a0:
	IF (accx = 3) THEN PRINT "expresso42": GOTO eeeCompiler
	IF (accx = 0) THEN PRINT "expresso43": GOTO eeeCompiler
	Pop ($$RA1, old_type)
	Conv ($$RA1, old_to_type, $$RA1, old_type)
	Conv ($$RA0, new_to_type, $$RA0, new_type)
	IF oldFlop THEN GOTO smosr1a
smosr0a:
	Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
	DEC toes
	a1 = 0: a1_type = 0
	a0 = toes
	GOTO done


stk_mem_op_stk_reg_a1:
	Pop ($$RA0, old_type)
	Conv ($$RA0, old_to_type, $$RA0, old_type)
	Conv ($$RA1, new_to_type, $$RA1, new_type)
	IF oldFlop THEN GOTO smosr0a
smosr1a:
	Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
	DEC toes
	a1 = 0: a1_type = 0
	a0 = toes
	GOTO done


' *****  After code for unary and binary operators has been emitted  *****
' *****  if (old.op != 0), logical test op returned bit T/F, not XLONG T/F

done:
	old_test	= old_op
	old_op		= new_op
	old_prec	= new_prec
	old_data	= 0
	old_type	= result_type
	RETURN


' ************************************************
' *****  Convert "bit T/F" into "XLONG T/F"  *****  ????  CAN THIS HAPPEN  ????
' ************************************************

SUB ExtractBit
	acc  = Top ()
	IFZ acc THEN PRINT "expresso.bit.test": GOTO eeeCompiler
	d1$ = CreateLabel$ ()
	GOSUB ConvCondBitFalse
	Code ($$mov, $$regimm, acc, 0, 0, $$XLONG, @"", @"	;;; i466")
	Code (jmp486, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i467")
	Code ($$not, $$reg, acc, 0, 0, $$XLONG, @"", @"	;;; i468")
	EmitLabel (@d1$)
	new_test = 0
END SUB


' *****  ConvCondBitTrue  *****

' Sets jmp486$ to 80386 conditional jump mnemonic that corresponds to
' the 88000 condition bit in new_test being true.

SUB ConvCondBitTrue
	SELECT CASE new_test
		CASE 2:			jmp486 = $$je
		CASE 3: 		jmp486 = $$jne
		CASE 4:			jmp486 = $$jg
		CASE 5:			jmp486 = $$jle
		CASE 6:			jmp486 = $$jl
		CASE 7:			jmp486 = $$jge
		CASE 8:			jmp486 = $$ja
		CASE 9:			jmp486 = $$jbe
		CASE 10:		jmp486 = $$jb
		CASE 11:		jmp486 = $$jae
		CASE ELSE:	jmp486 = -1
	END SELECT
END SUB

' *****  ConvCondBitFalse  *****

' Sets jmp486$ to 80386 conditional jump mnemonic that corresponds to
' the 88000 condition bit in new_test being false.

SUB ConvCondBitFalse
	SELECT CASE new_test
		CASE 2:			jmp486 = $$jne
		CASE 3: 		jmp486 = $$je
		CASE 4:			jmp486 =	$$jle
		CASE 5:			jmp486 = $$jg
		CASE 6:			jmp486 = $$jge
		CASE 7:			jmp486 = $$jl
		CASE 8:			jmp486 = $$jbe
		CASE 9:			jmp486 = $$ja
		CASE 10:		jmp486 = $$jae
		CASE 11:		jmp486 = $$jb
		CASE ELSE:	jmp486 = -1
	END SELECT
END SUB



' *****  UNARY OPERATORS  *****

express_unary_op:
	new_op		= token
	new_prec	= new_op{$$PREC}
	new_data	= 0
	new_type	= 0
	test			= 0
	Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
	GOTO exo



' *****  ARRAYS  *****

express_array:
	got_expression = $$TRUE
	new_data = token
	nn = token{$$NUMBER}
	new_allo = token{$$ALLO}
	IFZ new_allo THEN
		symboloid$ = tab_sym$[nn]
		IF symboloid$ THEN
			IF (symboloid${0} == '#') THEN
				new_allo = $$SHARED
				IF (symboloid${1} == '#') THEN new_allo = $$EXTERNAL
			ENDIF
		ENDIF
	ENDIF
	new_type = token{$$TYPE}
	IFZ new_type THEN new_type = tabType[nn]
	IFZ new_type THEN
		IF ((new_allo == $$SHARED) OR (new_allo == $$EXTERNAL)) THEN
			symboloid$ = tab_sym$[nn]
			IF (symboloid${0} == '#') THEN
				IFZ m_addr$[nn] THEN AssignAddress (token)
				new_type = TheType (token)
			ENDIF
		ENDIF
	ENDIF

	IF (new_type >= $$SCOMPLEX) THEN								' composite
		lastElement = LastElement (new_data, 0, 0)		'	Drop through if varComposite
		IF XERROR THEN EXIT FUNCTION
		IFF lastElement THEN													' composite + elements
			IF dim_array THEN PRINT "ccc6": GOTO eeeComponent
			Composite ($$GETDATA, @new_type, @new_data, 0, 0)
			IF XERROR THEN EXIT FUNCTION
			new_op   = 0
			new_prec = 0
			new_data = 0																' GETDATA stacks data
			GOTO express_op
		ENDIF
	ENDIF

	dimDone = ExpressArray (@old_op, @old_prec, @new_data, @new_type, accArray, 0, 0, 0)
	accArray = $$FALSE
	IF XERROR THEN EXIT FUNCTION
	new_op = 0
	new_prec = 0
	IF dimDone THEN												' dimend return
		old_test = 0
		old_op = NextToken ()
		old_prec = 0
		old_data = 0
		old_type = 0
		RETURN
	ENDIF
	GOTO express_op


' *******************************
' *****  EXTRACT BIT FIELD  *****
' *******************************

extract_bits_from_expression:
	IF new_data THEN
		varToken	= new_data
		varType		= new_type
		bitVar		= $$TRUE
		GOTO extract_bits
	ENDIF

	IF (new_type != $$STRING) THEN
		acc				= Topax1 ()
		IFZ acc THEN GOTO eeeCompiler
		Code ($$push, $$reg, acc, 0, 0, $$XLONG, @"", @"	;;; i469")
	ENDIF
	DEC tokenPtr
	varToken	= 0
	varType		= new_type
	bitVar		= $$FALSE
	GOTO extract_bits

extract_bits_from_variable:
	got_expression = $$TRUE
	varToken	= token
	varType		= new_type
	bitVar		= $$TRUE

extract_bits:
	SELECT CASE varType
		CASE $$SINGLE, $$XLONG, $$ULONG, $$SLONG
		CASE $$USHORT, $$SSHORT, $$UBYTE, $$SBYTE
		CASE $$STRING
			IF bitVar THEN
				DEC tokenPtr
				accArray = $$FALSE
			ELSE
				accArray = oos[oos]
			ENDIF
			token = $$T_VARIABLES + ($$STRING << 16) + varToken
			GOTO express_array
		CASE ELSE: GOTO eeeTypeMismatch
	END SELECT
	bitArgs = 0
	token = NextToken ()
	openBrace = token

' get width field (width-offset field if only one argument)

	new_op = Eval (@widthType)
	IF XERROR THEN EXIT FUNCTION
	IFZ q_type_long[widthType] THEN GOTO eeeTypeMismatch
	INC bitArgs

' get offset field (if specified)

	SELECT CASE new_op
		CASE T_RBRACE
		CASE T_COMMA
			new_op = Eval (@offsetType)
			IF XERROR THEN EXIT FUNCTION
			IFZ q_type_long[offsetType] THEN GOTO eeeTypeMismatch
			IF (new_op != T_RBRACE) THEN GOTO eeeSyntax
			INC bitArgs
		CASE ELSE
			GOTO eeeSyntax
	END SELECT
	IF (openBrace = T_LBRACES) THEN
		new_op = NextToken ()
		IF (new_op != T_RBRACE) THEN GOTO eeeSyntax
	ENDIF

	IF (bitArgs < 2) THEN
		dacc = Top()
	ELSE
		Topaccs (@dacc, @daccx)
	ENDIF
	IF bitVar THEN
		Move ($$esi, $$XLONG, varToken, $$XLONG)
	ELSE
		Code ($$pop, $$reg, $$esi, 0, 0, $$XLONG, @"", @"	;;; i470")
	ENDIF

' get bitfield value in a register or immediate value

	SELECT CASE bitArgs
		CASE 1:			GOSUB OneBitArg
		CASE 2:			GOSUB TwoBitArgs
		CASE ELSE:	GOTO eeeCompiler
	END SELECT
  new_type = $$XLONG
  new_op   = 0
  new_data = 0
  new_prec = 0
  GOTO express_op



SUB OneBitArg
	IF (openBrace = T_LBRACE) THEN
		Code ($$mov, $$regreg, $$ecx, dacc, 0, $$XLONG, @"", @"	;;; i471")
		Code ($$shr, $$regreg, $$esi, $$cl, 0, $$XLONG, @"", @"	;;; i472")
		Code ($$mov, $$regimm, $$edi, -1, 0, $$XLONG, @"", @"	;;; i473")
		Code ($$shr, $$regimm, $$ecx, 5, 0, $$XLONG, @"", @"	;;; i474")
		Code ($$shl, $$regreg, $$edi, $$cl, 0, $$XLONG, @"", @"	;;; i475")
		Code ($$not, $$reg, $$edi, 0, 0, $$XLONG, @"", @"	;;; i476")
		Code ($$and, $$regreg, $$esi, $$edi, 0, $$XLONG, @"", @"	;;; i477")
		Code ($$mov, $$regreg, dacc, $$esi, 0, $$XLONG, @"", @"	;;; i478")
	ELSE
		Code ($$mov, $$regreg, $$edi, dacc, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, $$ecx, $$edi, 0, $$XLONG, @"", @"")
		Code ($$shr, $$regimm, $$ecx, 5, 0, $$XLONG, @"", @"")
		Code ($$and, $$regimm, $$edi, 31, 0, $$XLONG, @"", @"")
		Code ($$and, $$regimm, $$ecx, 31, 0, $$XLONG, @"", @"")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, @"", @"")
		Code ($$neg, $$reg, $$ecx, 0, 0, $$XLONG, @"", @"")
		Code ($$add, $$regimm, $$ecx, 32, 0, $$XLONG, @"", @"")
		Code ($$shl, $$regreg, $$esi, $$cl, 0, $$XLONG, @"", @"")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, @"", @"")
		Code ($$sar, $$regreg, $$esi, $$cl, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, dacc, $$esi, 0, $$XLONG, @"", @"")
	ENDIF
END SUB

SUB TwoBitArgs
	IF (openBrace = T_LBRACE) THEN
		Code ($$mov, $$regreg, $$ecx, dacc, 0, $$XLONG, @"", @"	;;; i479")
		Code ($$shr, $$regreg, $$esi, $$cl, 0, $$XLONG, @"", @"	;;; i480")
		Code ($$mov, $$regimm, $$edi, -1, 0, $$XLONG, @"", @"	;;; i481")
		Code ($$mov, $$regreg, $$ecx, daccx, 0, $$XLONG, @"", @"	;;; i482")
		Code ($$shl, $$regreg, $$edi, $$cl, 0, $$XLONG, @"", @"	;;; i483")
		Code ($$not, $$reg, $$edi, 0, 0, $$XLONG, @"", @"	;;; i484")
		Code ($$and, $$regreg, $$esi, $$edi, 0, $$XLONG, @"", @"	;;; i485")
		Code ($$mov, $$regreg, daccx, $$esi, 0, $$XLONG, @"", @"	;;; i486")
	ELSE
		Code ($$mov, $$regreg, $$ecx, daccx, 0, $$XLONG, @"", @"	;;; i479")
		Code ($$mov, $$regreg, $$edi, dacc, 0, $$XLONG, @"", @"")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, @"", @"")
		Code ($$neg, $$reg, $$ecx, 0, 0, $$XLONG, @"", @"")
		Code ($$add, $$regimm, $$ecx, 32, 0, $$XLONG, @"", @"")
		Code ($$shl, $$regreg, $$esi, $$cl, 0, $$XLONG, @"", @"")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, @"", @"")
		Code ($$sar, $$regreg, $$esi, $$cl, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, daccx, $$esi, 0, $$XLONG, @"", @"	;;; i486")
	ENDIF
	Topax1 ()
END SUB



' *********************************
' *****  INTRINSIC FUNCTIONS  *****
' *********************************

express_intrinsic:
	args				= 0
	arg_pos$		= ""
	hold_token	= token
	ii					= token AND 0x00FF
	hold_place	= tokenPtr
	hold_type		= token{$$TYPE}
	return_type = hold_type
	inline			= inlineToken[ii]
	rtype$			= typeName$[return_type]
	max_args		= token{$$ARGS}
	IF (return_type < $$SLONG) THEN return_type = $$SLONG


' *****  Dispatch to intrinsics that need early processing  *****

	GOTO @firstIntrinToken[ii]

intrinsic_normal:
	token			= NextToken ()
	IF (token != T_LPAREN) THEN GOTO eeeSyntax
	check			= PeekToken ()
	IF (check = T_RPAREN) THEN new_op = NextToken (): GOTO i_too_few_args
	firstpos	= tokenPtr
	argOff		= 0
	OpenBothAccs ()
	SELECT CASE hold_token
		CASE T_FORMAT_D		: frameSize = 16
		CASE ELSE					: frameSize = 64
	END SELECT
	Code ($$sub, $$regimm, $$esp, frameSize, 0, $$XLONG, @"", @"	;;; i487")

	DO
		arg_pos$ = arg_pos$ + CHR$(tokenPtr + 1)
		new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
		Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
		IF XERROR THEN EXIT FUNCTION
		INC args
		IF (new_type > $$STRING) THEN	i_bad_arg = args: GOTO i_bad_type
		IF (args > 2) THEN
			IF (new_type >= $$GIANT) THEN GOTO eeeTypeMismatch
		ENDIF
		argOut	= $$FALSE
		ntype		= new_type
		IF (ntype < $$SLONG) THEN ntype = $$SLONG
		IF (hold_token = T_FORMAT_D) THEN
			IF (args = 2) THEN
				Code ($$st, $$roimm, ntype, $$esp, argOff, $$XLONG, @"", @"")
				argOff = argOff + 4
			ENDIF
		ENDIF
		IF new_data THEN
			kind	= new_data{$$KIND}
			IF ((kind = $$KIND_CONSTANTS) OR (kind = $$KIND_SYSCONS) OR (kind = $$KIND_LITERALS)) THEN
				IFZ inline THEN
					SELECT CASE ntype
						CASE $$DOUBLE:	argOut	= $$TRUE
														ntype 	= $$GIANT
														v#			= DOUBLE(r_addr$[new_data{$$NUMBER}])
														hi			= DHIGH(v#)
														lo			= DLOW(v#)
														Code ($$st, $$roimm, lo, $$esp, argOff, $$XLONG, @"", @"")
														Code ($$st, $$roimm, hi, $$esp, argOff+4, $$XLONG, @"", @"")
						CASE $$SINGLE:	argOut	= $$TRUE
														ntype		= $$XLONG
														v				= XMAKE(SINGLE(r_addr$[new_data{$$NUMBER}]))
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, @"", @"")
						CASE $$GIANT:		argOut	= $$TRUE
														v$$			= GIANT(r_addr$[new_data{$$NUMBER}])
														hi			= GHIGH(v$$)
														lo			= GLOW(v$$)
														Code ($$st, $$roimm, lo, $$esp, argOff, $$XLONG, @"", @"")
														Code ($$st, $$roimm, hi, $$esp, argOff+4, $$XLONG, @"", @"")
						CASE $$XLONG:		argOut	= $$TRUE
														v				= XLONG(r_addr$[new_data{$$NUMBER}])
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, @"", @"")
						CASE $$ULONG:		argOut	= $$TRUE
														v				= ULONG(r_addr$[new_data{$$NUMBER}])
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, @"", @"")
						CASE $$SLONG:		argOut	= $$TRUE
														v				= SLONG(r_addr$[new_data{$$NUMBER}])
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, @"", @"")
						CASE ELSE:			acc			= OpenAccForType (ntype)
														Move (acc, ntype, new_data, ntype)
					END SELECT
				ELSE
					acc = OpenAccForType (ntype)
					SELECT CASE ntype
						CASE $$DOUBLE:	v#			= DOUBLE(r_addr$[new_data{$$NUMBER}])
														hi			= DHIGH(v#)
														lo			= DLOW(v#)
														Code ($$ld, $$regimm, acc, lo, 0, $$XLONG, @"", @"")
														Code ($$ld, $$regimm, acc+1, hi, 0, $$XLONG, @"", @"")
						CASE $$SINGLE:	argOut	= $$TRUE
														ntype		= $$XLONG
														v				= XMAKE(SINGLE(r_addr$[new_data{$$NUMBER}]))
														Code ($$ld, $$regimm, acc, v, 0, $$XLONG, @"", @"")
						CASE ELSE:			Move (acc, ntype, new_data, ntype)
					END SELECT
				ENDIF
			ELSE
				SELECT CASE ntype
					CASE $$SINGLE:	ntype = $$XLONG
					CASE $$DOUBLE:	ntype = $$GIANT
				END SELECT
				acc		= OpenAccForType (ntype)
				Move (acc, ntype, new_data, ntype)
			ENDIF
		ELSE
			acc		= Top ()
			SELECT CASE ntype
				CASE $$SINGLE:	Code ($$fstp, $$ro, 0, $$esp, argOff, $$SINGLE, @"", @"")
												argOut	= $$TRUE
												ntype		= $$XLONG
												IF inline THEN
													Code ($$ld, $$regro, acc, $$esp, argOff, $$XLONG, @"", @"")
												ELSE
													acc			= Topax1 ()
												ENDIF
				CASE $$DOUBLE:	Code ($$fstp, $$ro, 0, $$esp, argOff, $$DOUBLE, @"", @"")
												argOut	= $$TRUE
												ntype		= $$GIANT
												IF inline THEN
													Code ($$ld, $$regro, acc, $$esp, argOff, $$GIANT, @"", @"")
												ELSE
													acc			= Topax1 ()
												ENDIF
			END SELECT
		ENDIF

		IF (args > max_args) THEN DEC tokenPtr: GOTO eeeTooManyArgs
		IFZ (inline OR argOut) THEN StackIt (ntype, acc, ntype, argOff)
		SELECT CASE ntype
			CASE $$LONGDOUBLE				: argOff = argOff + 12
			CASE $$DOUBLE, $$GIANT	: argOff = argOff + 8
			CASE ELSE								: argOff = argOff + 4
		END SELECT
		SELECT CASE args
			CASE 1		: at1 = new_type	: nt1 = ntype
			CASE 2		: at2 = new_type	: nt2 = ntype
			CASE 3		: at3 = new_type	: nt3 = ntype
			CASE 4		: at4 = new_type	: nt4 = ntype
			CASE ELSE	: GOTO eeeTooManyArgs
		END SELECT
	LOOP WHILE (new_op = T_COMMA)
	IF (new_op = T_RBRAK) AND (hold_token = T_UBOUND) THEN new_op = NextToken ()
	IF (new_op <> T_RPAREN) THEN GOTO eeeSyntax

' got all the arguments

	arg_pos$ = arg_pos$ + CHR$(tokenPtr)
	IF (return_type = $$TYPE_INPUT) THEN return_type = at1
	IF inline THEN
		SELECT CASE args
			CASE 1:	acc = Topax1 ()
							IF (acc != $$eax) THEN
								Code ($$mov, $$regreg, $$eax, acc, 0, nt1, @"", @"	;;; i488")
							ENDIF
			CASE 2: Topax2 (@acc2, @acc1)
							IF (acc1 != $$eax) THEN
								SELECT CASE nt1
									CASE $$SLONG, $$ULONG, $$XLONG
												Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i489")
									CASE $$GIANT
												Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i489")
												Code ($$xchg, $$regreg, $$edx, $$ecx, 0, $$XLONG, @"", @"	;;; i490")
									CASE ELSE
												GOTO eeeTypeMismatch
								END SELECT
							ELSE
								IF (acc2 != $$ebx) THEN GOTO eeeCompiler
							ENDIF
		END SELECT
	ENDIF
	INC toes
	new_data	= 0
	a0				= toes
	a0_type		= return_type


' *****  Dispatch to the intrinsic functions

igotm:
	GOTO @intrinToken [ii]			' individual routines for intrinsics
	tokenPtr = hold_place				' fall through on bad/unimplemented tokens
	GOTO eeeUnimplemented

' ****************************************************************
' *****  typenameAT INTRINSICS  *****  DIRECT MEMORY ACCESS  *****
' ****************************************************************

' *****  SBYTEAT, UBYTEAT, SSHORTAT... DOUBLEAT  *****

i_atops:
	opcode = $$ld
	OpenBothAccs ()
	AtOps (hold_type, @opcode, @mode, @base, @offset, 0)
	IF XERROR THEN EXIT FUNCTION
	INC toes
	a0			= toes
	a0_type	= return_type
	Code (opcode, mode, $$eax, base, offset, hold_type, @"", @"	;;; i491")
	new_type = return_type
	GOTO express_op


' ****************************************
' *****  TYPE CONVERSION INTRINSICS  *****
' ****************************************

' *****  SBYTE, UBYTE, SSHORT, USHORT... DOUBLE, GIANT  *****

i_types:
	IF (new_op <> T_RPAREN) THEN GOTO eeeSyntax
	new_type	= hold_token{$$TYPE}
	SELECT CASE TRUE
		CASE (new_type = at1)
					SELECT CASE TRUE
						CASE (new_type <= $$GIANT)
									Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i491a")
						CASE (new_type == $$GIANT)
									Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i491b")
									Code ($$ld, $$regro, $$edx, $$esp, 4, $$XLONG, @"", @"	;;; i491c")
						CASE (new_type == $$SINGLE)
									Code ($$fld, $$ro, 0, $$esp, 0, $$SINGLE, @"", @"	;;; i491d")
						CASE (new_type == $$DOUBLE)
									Code ($$fld, $$ro, 0, $$esp, 0, $$DOUBLE, @"", @"	;;; i491e")
						CASE (new_type == $$LONGDOUBLE)
									Code ($$fld, $$ro, 0, $$esp, 0, $$LONGDOUBLE, @"", @"	;;; i491f")
						CASE (new_type == $$STRING)
									Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i491g")
									IF oos[oos] = 'v' THEN
										Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"	;;; i491h")
									ENDIF
									oos[oos] = 's'
						CASE ELSE
									PRINT "Expresso(): i_types: error: bad type" : GOTO eeeCompiler
					END SELECT
		CASE (new_type == $$STRING)
					SELECT CASE at1
						CASE $$SLONG, $$ULONG:	at1 = $$XLONG
					END SELECT
					Code ($$call, $$rel, 0, 0, 0, 0, "%_cv." + typeName$[at1] + ".to.string", @"	;;; i492")
					INC oos
					oos[oos] = 's'
		CASE (at1 == $$STRING)
					Code ($$call, $$rel, 0, 0, 0, 0, "%_cv.string.to." + typeName$[new_type] + "." + CHR$(oos[oos]), @"	;;; i492a")
					DEC oos
		CASE ELSE
					SELECT CASE at1
						CASE $$SLONG	: at1 = $$XLONG
					END SELECT
					Code ($$call, $$rel, 0, 0, 0, 0, "%_cv." + typeName$[at1] + ".to." + typeName$[new_type], @"	;;; i492b")
	END SELECT
	IF (new_type < $$SLONG) THEN new_type = $$SLONG
	GOTO intrinDone


' *****  CLOSE (x)  *****

i_close:	routine$ = "%_close":	GOTO ii_close
i_quit:		routine$ = "%_quit":	GOTO ii_quit
i_eof:		routine$ = "%_eof":		GOTO ii_eof
i_lof:		routine$ = "%_lof":		GOTO ii_lof
i_pof:		routine$ = "%_pof":		GOTO ii_pof

ii_close:
ii_quit:
ii_eof:
ii_lof:
ii_pof:
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IF sacc1 THEN tt1 = sacc1
'	SELECT CASE routine$
'		CASE "%_close"
'		CASE "%_quit"
'		CASE "%_eof"
'		CASE "%_lof"
'		CASE "%_pof"
'	END SELECT
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"")
	new_data = 0
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  OPEN (fileName$, mode)  *****

i_open:
	routine$ = "%_open." + CHR$ (oos[oos])
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"")
	new_data = 0
	new_type = $$XLONG
	DEC oos
	GOTO intrinDone
	GOTO express_op


' *****  SEEK (file, pos)  *****

i_seek:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_seek", @"")
	new_data = 0
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  SHELL (command$)  *****

i_shell:
	routine$ = "%_shell." + CHR$ (oos[oos])
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"")
	new_data = 0
	new_type = $$XLONG
	DEC oos
	GOTO intrinDone
	GOTO express_op


' *****  INFILE$ (fileNumber)  *****

i_infile_d:
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_infile_d", @"")
	INC oos
	oos[oos] = 's'
	new_data = 0
	new_type = $$STRING
	GOTO intrinDone
	GOTO express_op


' *****  INLINE$ (prompt$)  *****

i_inline_d:
	routine$ = "%_inline_d." + CHR$ (oos[oos])
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"")
	new_data = 0
	new_type = $$STRING
	oos[oos] = 's'
	GOTO intrinDone
	GOTO express_op


' ********************************************
' *****  NUMERIC = INTRINSIC (NUMERICS)  *****
' ********************************************

' *****  ABS (x)  *****

i_abs:
	IF (at1 > $$LONGDOUBLE) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, "%_abs." + typeName$[at1], @"	;;; i494")
	new_type	= at1
	GOTO intrinDone


' *****  BITFIELD (x&, y&)  *****

i_bitfield:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$and, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i497")
	Code ($$shl, $$regimm, $$eax, 5, 0, $$XLONG, @"", @"	;;; i498")
	Code ($$and, $$regimm, $$ebx, 31, 0, $$XLONG, @"", @"	;;; i499")
	Code ($$or, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i500")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  DHIGH (x#)  *****

i_dhigh:
	IF (at1 != $$DOUBLE) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  DLOW (x#)  *****

i_dlow:
	IF (at1 != $$DOUBLE) THEN i_bad_arg = 1: GOTO i_bad_type
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  DMAKE (x&, y&)  *****

i_dmake:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$st, $$roreg, $$ebx, $$ebp, -8, $$XLONG, @"", @"	;;; i505")
	Code ($$st, $$roreg, $$eax, $$ebp, -4, $$XLONG, @"", @"	;;; i506")
	Code ($$fld, $$ro, 0, $$ebp, -8, $$DOUBLE, @"", @"	;;; i507")
	new_type = $$DOUBLE
	GOTO intrinDone
	GOTO express_op


' *****  ERROR (e&)  *****  returns ##ERROR : IF (arg != -1) THEN ##ERROR = arg

i_error:
	IF (args < 1) THEN GOTO i_too_few_args
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_error", @"")
	new_type = $$XLONG
	GOTO intrinDone


' *****  GHIGH (x$$)  *****

i_ghigh:
	IF (at1 != $$GIANT) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"	;;; i508")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  GLOW (x$$)  *****

i_glow:
	IF (at1 != $$GIANT) THEN i_bad_arg = 1: GOTO i_bad_type
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  GMAKE (x&, y&)  *****

i_gmake:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$mov, $$regreg, $$edx, $$eax, 0, $$XLONG, @"", @"	;;; i509")
	Code ($$mov, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"	;;; i510")
	new_type	= $$GIANT
	GOTO intrinDone
	GOTO express_op


' *****  SMAKE (x&)  *****

i_smake:
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$st, $$roreg, $$eax, $$ebp, -8, $$XLONG, @"", @"")
	Code ($$fld, $$ro, 0, $$ebp, -8, $$SINGLE, @"", @"")
	new_type	= $$SINGLE
	GOTO intrinDone
	GOTO express_op


' *****  XMAKE (x!)  *****

i_xmake:
	IF (at1 != $$SINGLE) THEN i_bad_arg = 1: GOTO i_bad_type
	new_type	= $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  HIGH0 (x&)  *****
' *****  HIGH1 (x&)  *****

i_high0: routine$ = "%_high0" : groutine$ = "%_high0.giant" : GOTO ii_high0
i_high1: routine$ = "%_high1" : groutine$ = "%_high1.giant" : GOTO ii_high1

ii_high0:
ii_high1:
	SELECT CASE TRUE
		CASE (q_type_long_or_addr[at1])
					SELECT CASE routine$
						CASE "%_high0"
						CASE "%_high1"
					END SELECT
					Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i511a")
		CASE (at1 = $$GIANT)
					SELECT CASE routine$
						CASE "%_high0.giant"
						CASE "%_high1.giant"
					END SELECT
					Code ($$call, $$rel, 0, 0, 0, 0, @groutine$, @"	;;; i511b")
		CASE ELSE
					i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  LIBRARY (x)  *****

i_library:
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
	IF library THEN Code ($$not, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
	new_type = $$XLONG
	GOTO intrinDone


' *****  MIN (x, y)  *****
' *****  MAX (x, y)  *****

i_min:	routine$ = "%_MIN." + typeName$[at1]:	GOTO ii_minmax
i_max:	routine$ = "%_MAX." + typeName$[at1]:	GOTO ii_minmax

ii_minmax:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 > $$LONGDOUBLE) THEN i_bad_arg = 1:	GOTO i_bad_type
	IF (at2 > $$LONGDOUBLE) THEN i_bad_arg = 2:	GOTO i_bad_type
	IF typeConvert[at1,at2]{{$$BYTE0}} THEN i_bad_arg = 2:	GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"")
	new_type	= at1
	GOTO intrinDone


' *****  ROTATEL (x, y)  *****

i_rotatel:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$mov, $$regreg, $$ecx, $$ebx, 0, $$XLONG, @"", @"	;;; i537a")
	Code ($$rol, $$regreg, $$eax, $$cl, 0, $$XLONG, @"", @"	;;; i537b")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  ROTATER (x, y)  *****

i_rotater:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$mov, $$regreg, $$ecx, $$ebx, 0, $$XLONG, @"", @"	;;; i538a")
	Code ($$ror, $$regreg, $$eax, $$cl, 0, $$XLONG, @"", @"	;;; i538b")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  CLR  (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  SET  (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  EXTS (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  EXTU (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  MAKE (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****

i_clr:			iop$ = "%_clr":		GOTO ii_clr
i_set:			iop$ = "%_set":		GOTO ii_set
i_exts:			iop$ = "%_ext":		GOTO ii_exts
i_extu:			iop$ = "%_extu":	GOTO ii_extu
i_make:			iop$ = "%_make":	GOTO ii_make

ii_clr:
ii_set:
ii_exts:
ii_extu:
ii_make:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN
		IF (at1 <> $$SINGLE) THEN i_bad_arg = 1: GOTO i_bad_type
	ENDIF
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	IF (args = 2) THEN
		Code ($$call, $$rel, 0, 0, 0, 0, iop$ + ".2arg", @"	;;; i539")
	ELSE
		IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
		Code ($$call, $$rel, 0, 0, 0, 0, iop$ + ".3arg", @"	;;; i540")
	ENDIF
	new_type = $$XLONG
	GOTO intrinDone


' *****  INT (x)  *****
' *****  FIX (x)  *****
' *****  ROUND (x) ****
' *****  ROUNDNE (x) **
' *****  CEIL (x) *****

i_int:			routine$ = "%_int.":			GOTO ii_int
i_fix:			routine$ = "%_fix.":			GOTO ii_fix
i_round:		routine$ = "%_round.":		GOTO ii_round
i_roundne: 	routine$ = "%_roundne.":  GOTO ii_roundne
i_ceil: 		routine$ = "%_ceil.":   	GOTO ii_ceil

ii_int:
ii_fix:
ii_round:
ii_roundne:
ii_ceil:

	routine$ = routine$ + typeName$[at1]
	SELECT CASE at1
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
				Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i541")
		CASE $$SLONG, $$ULONG, $$XLONG
				Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"")
		CASE $$GIANT
				Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"")
				Code ($$ld, $$regro, $$edx, $$esp, 4, $$XLONG, @"", @"")
		CASE ELSE
				i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type	= at1
	GOTO intrinDone


' *****  SGN (x)  *****

i_sgn:
	SELECT CASE at1
		CASE $$ULONG
					d1$ = CreateLabel$ ()
					Code ($$test, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; i542")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i543")
					Code ($$mov, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i544")
					EmitLabel (@d1$)
		CASE $$SLONG, $$XLONG
					d1$ = CreateLabel$ ()
					Code ($$test, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; i545")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i546")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i547")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i548")
					EmitLabel (@d1$)
		CASE $$GIANT
					d1$ = CreateLabel$ ()
					Code ($$or, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"	;;; i549")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i550")
					Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"	;;; i551")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i552")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i553")
					EmitLabel (@d1$)
		CASE $$SINGLE
					d1$ = CreateLabel$ ()
					Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, @"", @"	;;; i554")
					Code ($$and, $$regimm, $$eax, 0x7FFFFFFF, 0, $$XLONG, @"", @"	;;; i554a")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i554b")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, @"", @"	;;; i554c")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i554d")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i554e")
					EmitLabel (@d1$)
		CASE $$DOUBLE
					d1$ = CreateLabel$ ()
					Code ($$mov, $$regreg, $$esi, $$edx, 0, $$XLONG, @"", @"	;;; i555")
					Code ($$and, $$regimm, $$edx, 0x7FFFFFFF, 0, $$XLONG, @"", @"	;;; i555a")
					Code ($$or, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"	;;; i555b")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i555c")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, @"", @"	;;; i555d")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i555e")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i555f")
					EmitLabel (@d1$)
		CASE $$LONGDOUBLE
					Code ($$sub, $$regimm, $$esp, 12, 0, $$XLONG, @"", @"	;;; i555g")
					Code ($$fstp, $$ro, 0, $$esp, 0, $$LONGDOUBLE, @"", @"	;;; i555h")
					routine$ = "%_sgn.longdouble"
					Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i555i")
		CASE ELSE
					i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type	= $$SLONG
	GOTO intrinDone
	GOTO express_op


' *****  SIGN (x)  *****

i_sign:
	SELECT CASE at1
		CASE $$ULONG
					Code ($$mov, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i557")
		CASE $$SLONG, $$XLONG
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i558")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i559")
		CASE $$GIANT
					Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"	;;; i560")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i561")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i562")
		CASE $$SINGLE
					d1$ = CreateLabel$ ()
					Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, @"", @"	;;; i563")
					Code ($$and, $$regimm, $$eax, 0x7FFFFFFF, 0, $$XLONG, @"", @"	;;; i563a")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i563b")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, @"", @"	;;; i563c")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i563d")
					EmitLabel (@d1$)
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i563e")
		CASE $$DOUBLE
					d1$ = CreateLabel$ ()
					Code ($$mov, $$regreg, $$esi, $$edx, 0, $$XLONG, @"", @"	;;; i564")
					Code ($$and, $$regimm, $$edx, 0x7FFFFFFF, 0, $$XLONG, @"", @"	;;; i564a")
					Code ($$or, $$regreg, $$eax, $$edx, 0, $$XLONG, @"", @"	;;; i564b")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i564c")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, @"", @"	;;; i564d")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, @"", @"	;;; i564e")
					EmitLabel (@d1$)
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, @"", @"	;;; i564f")
		CASE $$LONGDOUBLE
					Code ($$sub, $$regimm, $$esp, 12, 0, $$XLONG, @"", @"	;;; i564g")
					Code ($$fstp, $$ro, 0, $$esp, 0, $$LONGDOUBLE, @"", @"	;;; i564h")
					routine$ = "%_sign.longdouble"
					Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i564i")
		CASE ELSE
					i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type	= $$SLONG
	GOTO intrinDone
	GOTO express_op


' *****  TAB (x)  *****

i_tab:
	IFZ inPrint THEN GOTO eeeSyntax
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"	;;; i566")
	new_type	= $$XLONG
	GOTO intrinDone


' *********************************************
' *****  NUMERIC = INTRINSIC (STRING...)  *****
' *********************************************


' *****  ASC (x$, [i])  *****

i_asc:
	routine$ = "%_asc."
	IF (at1 <> $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (args = 1) THEN
		Code ($$mov, $$roimm, 1, $$esp, 4, $$XLONG, @"", @"	;;; i567")
	ELSE
		IFZ q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	ENDIF
	dest$			= routine$ + CHR$ (oos[oos])
	Code ($$call, $$rel, 0, 0, 0, 0, @dest$, @"	;;; i568")
	DEC oos
	new_type	= $$XLONG
	GOTO intrinDone


' *****  LEN (x$)  *****
' *****  SIZE (x$)  *****

i_len:
i_size:
	acc			= Top ()
	stackedString = $$FALSE
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (oos[oos] = 'v') THEN
		upper = $$FALSE
		GOSUB GetSizeOrUpperFromHeader
	ELSE
		d1$ = CreateLabel$ ()
		IF (acc != $$eax) THEN Code ($$mov, $$regreg, $$eax, acc, 0, $$XLONG, @"", @"	;;; i568a")
		Code ($$test, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; i568b")
		Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i568c")
		Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, @"", @"	;;; i568d")
		Code ($$ld, $$regro, $$eax, $$eax, -8, $$XLONG, @"", @"	;;; i568e")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i568f")
		EmitLabel (@d1$)
	ENDIF

doneSize:
	DEC oos
	new_type	= $$XLONG
	GOTO intrinDone
	GOTO express_op


' *****  CSIZE (x$)  *****

i_csize:
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, "%_csize." + CHR$ (oos[oos]), @"	;;; i569")
	DEC oos
	new_type	= $$XLONG
	GOTO intrinDone


' *****  INCHR   (x$, y$ [,z])  *****
' *****  INSTR   (x$, y$ [,z])  *****
' *****  INCHRI  (x$, y$ [,z])  *****		' case insensitive
' *****  INSTRI  (x$, y$ [,z])  *****		' case insensitive
' *****  RINCHR  (x$, y$ [,z])  *****		' reverse search
' *****  RINSTR  (x$, y$ [,z])  *****		' reverse search
' *****  RINCHRI (x$, y$ [,z])  *****		' reverse search, case insensitive
' *****  RINSTRI (x$, y$ [,z])  *****		' reverse search, case insensitive

i_inchr:		routine$ = "%_inchr.":		GOTO ii_inetc
i_instr:		routine$ = "%_instr.":		GOTO ii_inetc
i_inchri:		routine$ = "%_inchri.":		GOTO ii_inetc
i_instri:		routine$ = "%_instri.":		GOTO ii_inetc
i_rinchr:		routine$ = "%_rinchr.":		GOTO ii_inetc
i_rinstr:		routine$ = "%_rinstr.":		GOTO ii_inetc
i_rinchri:	routine$ = "%_rinchri.":	GOTO ii_inetc
i_rinstri:	routine$ = "%_rinstri.":	GOTO ii_inetc

ii_inetc:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	ab1 = at1{4,0}
	IF (at1 <> at2) THEN i_bad_arg = 2: GOTO i_bad_type
	IF (args = 2) THEN
		Code ($$st, $$roimm, 0, $$esp, 8, $$XLONG, @"", @"	;;; i571")
	ELSE
		IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, routine$ + CHR$(oos[oos-1]) + CHR$(oos[oos]), @"	;;; i572")
	oos = oos - 2
	new_type	= $$XLONG
	GOTO intrinDone


' ******************************************
' *****  STRING = INTRINSIC (NUMERIC)  *****
' ******************************************


' *****  ERROR$ (e)  *****  returns error string

i_error_d:
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_error.d", @"")
	INC oos
	oos[oos] = 's'
	new_type = $$STRING
	GOTO intrinDone


' *****  VERSION$ (e)  *****  returns VERSION statement string
' *****  PROGRAM$ (e)  *****  returns PROGRAM statement string

i_version_d:	getToken = versionToken : GOTO i_literal_string
i_program_d:	getToken = programToken : GOTO i_literal_string

i_literal_string:
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	IF getToken THEN
		Move ($$eax, $$XLONG, getToken, $$XLONG)
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"")
	ELSE
		Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
	ENDIF
	INC oos
	oos[oos] = 's'
	new_type = $$STRING
	GOTO intrinDone


' *****  NULL$ (x)  *****
' *****  SPACE$ (x)  *****
' *****  CSTRING$ (x)  *****

i_null_d:			routine$ = "%_null.d":		GOTO ii_null_d
i_space_d:		routine$ = "%_space.d":		GOTO ii_space_d
i_cstring_d:	routine$ = "%_cstring.d":	GOTO ii_cstring_d

ii_null_d:
ii_space_d:
ii_cstring_d:
	SELECT CASE at1
		CASE $$SLONG, $$ULONG, $$XLONG
				Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i573")
		CASE ELSE
				i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	INC oos
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone


' *****  BIN$  (x [,y])  *****
' *****  BINB$ (x [,y])  *****
' *****  HEX$  (x [,y])  *****
' *****  HEXX$ (x [,y])  *****
' *****  OCT$  (x [,y])  *****
' *****  OCTO$ (x [,y])  *****

i_bin_d:		groutine$ = "%_bin.d.giant":	routine$ = "%_bin.d":		GOTO ii_bin_d
i_binb_d:		groutine$ = "%_binb.d.giant":	routine$ = "%_binb.d":	GOTO ii_binb_d
i_hex_d:		groutine$ = "%_hex.d.giant":	routine$ = "%_hex.d":		GOTO ii_hex_d
i_hexx_d:		groutine$ = "%_hexx.d.giant":	routine$ = "%_hexx.d":	GOTO ii_hexx_d
i_oct_d:		groutine$ = "%_oct.d.giant":	routine$ = "%_oct.d":		GOTO ii_oct_d
i_octo_d:		groutine$ = "%_octo.d.giant":	routine$ = "%_octo.d":	GOTO ii_octo_d

ii_bin_d:
ii_binb_d:
ii_hex_d:
ii_hexx_d:
ii_oct_d:
ii_octo_d:
	IF (at1 = $$GIANT) THEN
		routine$ = groutine$
	ELSE
		IFF q_type_long_or_addr[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	ENDIF

	IF (args = 1) THEN
		Code ($$mov, $$roimm, 0, $$esp, argOff, $$XLONG, @"", @"")
	ELSE
		IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i574")
	INC oos
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone


' *****  CHR$ (x, [y])  *****

i_chr_d:
	IFZ q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IF (args = 1) THEN
		Code ($$st, $$roimm, 1, $$esp, 4, $$XLONG, @"", @"")
	ELSE
		IFZ q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_chr.d", @"	;;; i575")
	INC oos
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone


' **************************
' *****  SIGNED$	(x)  *****
' *****  STRING$	(x)  *****
' *****  STRING		(x)  *****
' *****  STR$			(x)  *****
' **************************

i_signed_d:
	IF (at1 = $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	routine$ = "%_signed.d." + typeName$[at1]
	GOTO istring

i_string_d:
i_string:
	IF (at1 = $$STRING) THEN GOTO i_string_string
	routine$ = "%_string." + typeName$[at1]
	GOTO istring

i_str_d:
	IF (at1 = $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	routine$ = "%_str.d." + typeName$[at1]
	GOTO istring

istring:
	SELECT CASE at1
		CASE $$SLONG, $$ULONG, $$XLONG
		CASE $$GIANT, $$SINGLE, $$DOUBLE, $$LONGDOUBLE
		CASE $$STRING
		CASE ELSE: i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	IF (at1 = $$STRING) THEN DEC oos
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i576")
	INC oos
	oos[oos] = 's'
	new_type = $$STRING
	GOTO intrinDone

i_string_string:
	Code ($$mov, $$regro, $$eax, $$esp, 0, $$XLONG, @"", @"")
	IF oos[oos] = 'v' THEN
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"")
		oos[oos] = 's'
	ENDIF
	new_type = $$STRING
	GOTO intrinDone

' ***************************************************
' *****  STRING = INTRINSIC (STRING [, XLONG])  *****
' ***************************************************


' ********************************************************
' *****  FORMAT$ (f$, argType, (arg$, arg$$, arg#))  *****
' ********************************************************

' last argument can be integer / float / string

i_format_d:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF ((at2 != $$GIANT) AND (at2 != $$DOUBLE)) THEN
		Code ($$st, $$roimm, 0, $$esp, 12, $$XLONG, @"", @"")
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxFormat$@16", @"")
	IF (at2 = $$STRING) THEN
		IF (oos[oos] = 's') THEN
			Code ($$ld, $$regro, $$esi, $$esp, -8, $$XLONG, @"", @"")
			Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"")
			oos[oos] = 0
			DEC oos
		ENDIF
	ENDIF
	IF (oos[oos] = 's') THEN
		Code ($$ld, $$regro, $$esi, $$esp, -16, $$XLONG, @"", @"")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"")
	ENDIF
	oos[oos] = 's'
	new_type = $$STRING
	GOTO express_op



' *******************************
' *****  LJUST$ (x$, y)  ********
' *****  CJUST$ (x$, y)  ********
' *****  RJUST$ (x$, y)  ********
' *****  LCLIP$ (x$ [, y])  *****  Default argument value = 1
' *****  RCLIP$ (x$ [, y])  *****
' *****  LEFT$  (x$ [, y])  *****
' *****  RIGHT$ (x$ [, y])  *****
' *******************************

i_ljust_d:	routine$ = "%_ljust.d.":	oa = $$FALSE:	GOTO ii_ljust_d
i_cjust_d:	routine$ = "%_cjust.d.":	oa = $$FALSE:	GOTO ii_cjust_d
i_rjust_d:	routine$ = "%_rjust.d.":	oa = $$FALSE:	GOTO ii_rjust_d
i_lclip_d:	routine$ = "%_lclip.d.":	oa = $$TRUE:	GOTO ii_lclip_d
i_rclip_d:	routine$ = "%_rclip.d.":	oa = $$TRUE:	GOTO ii_rclip_d
i_left_d:		routine$ = "%_left.d.":		oa = $$TRUE:	GOTO ii_left_d
i_right_d:	routine$ = "%_right.d.":	oa = $$TRUE:	GOTO ii_right_d

ii_ljust_d:
ii_cjust_d:
ii_rjust_d:
ii_lclip_d:
ii_rclip_d:
ii_left_d:
ii_right_d:
	IF (args < 1) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (args = 1) THEN
		IFZ oa THEN GOTO i_too_few_args
		Code ($$st, $$roimm, 1, $$esp, 4, $$XLONG, @"", @"	;;; i577")
	ELSE
		IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	ENDIF

	dest$ = routine$ + CHR$(oos[oos])
	Code ($$call, $$rel, 0, 0, 0, 0, @dest$, @"	;;; i578")
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone


' *******************************
' *****  MID$ (x$, y [,z])  *****  Default value of [,z] = infinity
' *******************************

i_mid_d:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (args = 2) THEN at3 = $$XLONG
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
	IF (args = 2) THEN Code ($$st, $$roimm, 0x7FFFFFFF, $$esp, 8, $$XLONG, @"", @"	;;; i579")
	Code ($$call, $$rel, 0, 0, 0, 0, "%_mid.d." + CHR$(oos[oos]), @"	;;; i580")
	oos[oos]	= 's'
	new_type	= $$STRING
	GOTO intrinDone


' *************************************
' *****  STUFF$ (s$, i$, y [,z])  *****
' *************************************

i_stuff_d:
	IF (args < 3) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (at1 <> at2) THEN i_bad_arg = 2: GOTO i_bad_type
	IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
	IF (args = 3) THEN
		Code ($$st, $$roimm, -1, $$esp, 12, $$XLONG, @"", @"	;;; i581")
	ELSE
		IFF q_type_long[at4] THEN i_bad_arg = 4: GOTO i_bad_type
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, "%_stuff.d." + CHR$(oos[oos-1]) + CHR$(oos[oos]), @"	;;; i582")
	DEC oos
	oos[oos]	= 's'
	new_type	= $$STRING
	GOTO intrinDone


' *****  TRIM$ (x$)  *****
' *****  LTRIM$ (x$)  *****
' *****  RTRIM$ (x$)  *****
' *****  LCASE$ (x$)  *****
' *****  UCASE$ (x$)  *****
' *****  CSIZE$ (x$)  *****

i_trim_d:			routine$ = "%_trim.d.":			GOTO ii_trim_d
i_ltrim_d:		routine$ = "%_ltrim.d.":		GOTO ii_ltrim_d
i_rtrim_d:		routine$ = "%_rtrim.d.":		GOTO ii_rtrim_d
i_lcase_d:		routine$ = "%_lcase.d.":		GOTO ii_lcase_d
i_ucase_d:		routine$ = "%_ucase.d.":		GOTO ii_ucase_d
i_csize_d:		routine$ = "%_csize.d.":		GOTO ii_csize_d

ii_ltrim_d:
ii_rtrim_d:
ii_trim_d:
ii_lcase_d:
ii_ucase_d:
ii_csize_d:
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, routine$ + CHR$(oos[oos]), @"	;;; i583")
	oos[oos]	= 's'
	new_type	= $$STRING
	GOTO intrinDone



' ***************************************
' *****  NUMERIC = INTRINSIC (???)  *****
' ***************************************


' *****  SIZE (typeName)  *****              built-in or user-defined
' *****  SIZE (simpleVariable)  *****
' *****  SIZE (stringVariable)  *****
' *****  SIZE (compositeVariable)  *****
' *****  SIZE (compositeVariable.componentName...)  *****
' *****  SIZE (arrayName [dimension, dimension, ...])  *****

' *****  TYPE (typeName)  *****              built-in or user-defined
' *****  TYPE (simpleVariable)  *****
' *****  TYPE (stringVariable)  *****
' *****  TYPE (compositeVariable)  *****
' *****  TYPE (compositeVariable.componentName...)  *****
' *****  TYPE (arrayName [dimension, dimension, ...])  *****

i_lenof:
i_sizeof:
	getSize		= $$TRUE
	getType		= $$FALSE
	GOTO i_sizeof_typeof

i_typeof:
	getSize		= $$FALSE
	getType		= $$TRUE
	GOTO i_sizeof_typeof

i_sizeof_typeof:
	hold					= tokenPtr
	token					= NextToken ()
	IF (token != T_LPAREN) THEN GOTO eeeSyntax
	holder				= tokenPtr
	argToken			= NextToken ()
	kind					= argToken{$$KIND}
	SELECT CASE kind
		CASE $$KIND_STATE_INTRIN
					SELECT CASE argToken
						CASE T_DOUBLE:		varType = $$DOUBLE
						CASE T_FUNCADDR:	varType = $$FUNCADDR
						CASE T_GIANT:			varType = $$GIANT
						CASE T_GOADDR:		varType = $$GOADDR
						CASE T_SUBADDR:   varType = $$SUBADDR
						CASE T_SBYTE:			varType = $$SBYTE
						CASE T_SINGLE:		varType = $$SINGLE
						CASE T_SLONG:			varType = $$SLONG
						CASE T_SSHORT:		varType = $$SSHORT
						CASE T_LONGDOUBLE: varType = $$LONGDOUBLE
						CASE T_STRING:
									IF getSize THEN GOTO eeeUndefined
									varType = $$STRING
									typeSize = 1
						CASE T_UBYTE:			varType = $$UBYTE
						CASE T_ULONG:			varType = $$ULONG
						CASE T_USHORT:		varType = $$USHORT
						CASE T_XLONG:			varType = $$XLONG
						CASE ELSE:		GOTO eeeKindMismatch
					END SELECT
					GOSUB SizeofTypeofTypesAndVariables
		CASE $$KIND_TYPES
					varType = argToken{$$NUMBER}
					GOSUB SizeofTypeofTypesAndVariables
		CASE $$KIND_VARIABLES, $$KIND_LITERALS:
					aat = argToken{$$NUMBER}
					IFZ m_addr$[aat] THEN AssignAddress (argToken)
					IF XERROR THEN EXIT FUNCTION
					varType = TheType (argToken)
					IF (varType = $$STRING) THEN
						check = PeekToken ()
						IF (check = T_RPAREN) THEN
							dacc	= OpenAccForType ($$XLONG)
							IF getType THEN
								Code ($$mov, $$regimm, dacc, $$STRING, 0, $$XLONG, @"", @"	;;; i583a")
							ELSE
								Move (dacc, $$XLONG, argToken, $$XLONG)
								upper = $$FALSE
								GOSUB GetSizeOrUpperFromHeader
							ENDIF
							token = NextToken ()
							EXIT SELECT
						ELSE
							tokenPtr = hold
							GOTO intrinsic_normal
						ENDIF
					ENDIF
					GOSUB SizeofTypeofTypesAndVariables
		CASE $$KIND_ARRAYS
					aat = argToken{$$NUMBER}
					IFZ m_addr$[aat] THEN AssignAddress (argToken)
					IF XERROR THEN EXIT FUNCTION
					varType = TheType (argToken)
'					IF (varType = $$STRING) THEN GOTO eeeTypeMismatch
					GOSUB SizeofTypeofArrays

		CASE $$KIND_INTRINSICS, $$KIND_LPARENS :
					tokenPtr = hold
					GOTO intrinsic_normal

		CASE ELSE
					GOTO eeeKindMismatch
	END SELECT
	IF (token != T_RPAREN) THEN GOTO eeeSyntax
	new_data	= 0
	new_type	= $$XLONG
	GOTO express_op

SUB SizeofTypeofTypesAndVariables
	DO WHILE (varType >= $$SCOMPLEX)
		check		= PeekToken ()
		inarray	= $$FALSE
		SELECT CASE check{$$KIND}
			CASE $$KIND_SYMBOLS
						IF array THEN GOTO eeeSyntax
						array		= $$FALSE														' .component
						token		= NextToken ()
			CASE $$KIND_ARRAY_SYMBOLS
						IF array THEN GOTO eeeSyntax
						array		= $$TRUE														' .component[]
						token		= NextToken ()
						test		= NextToken ()
						IF (test != T_LBRAK) THEN GOTO eeeSyntax
						test		= NextToken ()
						IF (test{$$KIND} = $$KIND_LITERALS) THEN
							test		= NextToken()
							array		= $$FALSE													' .component[0]
							inarray	= $$TRUE
						ENDIF
						IF (test != T_RBRAK) THEN GOTO eeeSyntax
			CASE ELSE:	EXIT DO
		END SELECT
		found			= $$FALSE
		component	= 0
		DO
			componentToken	= typeEleToken[varType, component]
			IF (token = componentToken) THEN
				oldType = varType
				IF array THEN
					elements	= typeEleUBound[varType, component] + 1
				ENDIF
				varType		= typeEleType[varType, component]
				IF (varType = $$STRING) THEN
					IF inarray THEN
						typeSize = typeEleStringSize[oldType, component]
					ELSE
						typeSize = typeEleSize[oldType, component]
					ENDIF
				ENDIF
				found			= $$TRUE
				EXIT DO
			ENDIF
			INC component
		LOOP WHILE (component <= typeEleCount[varType])
		IFZ found THEN GOTO eeeComponent
	LOOP
	IF (varType != $$STRING) THEN
		typeSize	= typeSize[varType]
		IF array THEN typeSize	= elements * typeSize
	ENDIF
	IF (typeSize <= 0) THEN PRINT "size0": GOTO eeeCompiler
	SELECT CASE TRUE
		CASE getSize:		value = typeSize
		CASE getType:		value = varType
	END SELECT
	dacc					= OpenAccForType ($$XLONG)
	Code ($$mov, $$regimm, dacc, value, 0, $$XLONG, @"", @"	;;; i584")
	token	= NextToken ()
END SUB

SUB SizeofTypeofArrays
	stringData	= $$FALSE
	arrayType		= TheType (argToken)
	token				= NextToken ()
	IF (token != T_LBRAK) THEN GOTO eeeSyntax
	token				= NextToken ()
	IF (token = T_RBRAK) THEN											' SIZE (a[])
		dacc			= OpenAccForType ($$XLONG)
		Move (dacc, $$XLONG, argToken, $$XLONG)
		token = NextToken ()
	ELSE
		tokenPtr	= holder
		new_type	= arrayType
		new_data	= NextToken ()
		new_op		= 0: new_prec = 0: excess = 0
		IF (argToken != new_data) THEN GOTO eeeCompiler
		ExpressArray (@new_op, @new_prec, @new_data, @new_type, 0, @excess, 0, 0)
		IF XERROR THEN EXIT FUNCTION
		IFZ excess THEN
			IF (new_type != $$STRING) THEN GOTO eeeNeedExcessComma
			stringData = $$TRUE
			DEC oos
		ENDIF
		token			= NextToken ()
		dacc			= Top ()
		new_op		= token
	ENDIF

' Get # of elements out of header and multiply times size of array type

	SELECT CASE TRUE
		CASE getSize
					d1$ = CreateLabel$ ()
					IF stringData THEN
						Code ($$test, $$regreg, dacc, dacc, 0, $$XLONG, @"", @"	;;; i586")
						Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i587")
						Code ($$ld, $$regro, dacc, dacc, -8, $$XLONG, @"", @"	;;; i589")
					ELSE
						Code ($$test, $$regreg, dacc, dacc, 0, $$XLONG, @"", @"	;;; i586")
						Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i587")
						Code ($$ld, $$regro, $$esi, dacc, -4, $$XLONG, @"", @"	;;; i588")
						Code ($$ld, $$regro, dacc, dacc, -8, $$XLONG, @"", @"	;;; i589")
						Code ($$and, $$regimm, $$esi, 0x0000FFFF, 0, $$XLONG, @"", @"	;;; i590")
						Code ($$imul, $$regreg, dacc, $$esi, 0, $$XLONG, @"", @"	;;; i591")
					ENDIF
					EmitLabel (@d1$)
		CASE getType
					d1$ = CreateLabel$ ()
					Code ($$test, $$regreg, dacc, dacc, 0, $$XLONG, @"", @"")
					Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"")
					Code ($$ld, $$regro, dacc, dacc, -2, $$UBYTE, @"", @"")
					EmitLabel (@d1$)
	END SELECT
END SUB


' *****  UBOUND (arrayName [])  *****
' *****  UBOUND (arrayName [dimension, dimension, ...])  *****

i_ubound:
	token		= NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	holder	= tokenPtr
	atoken	= NextToken ()
	kind		= atoken{$$KIND}
	SELECT CASE kind
		CASE $$KIND_ARRAYS, $$KIND_VARIABLES
		CASE ELSE:		GOTO eeeSyntax
	END SELECT
	IFZ m_addr$[atoken{$$NUMBER}] THEN AssignAddress (atoken)
	IF XERROR THEN EXIT FUNCTION
	atype		= TheType (atoken)
	IF (kind = $$KIND_VARIABLES) THEN
		IF (atype != $$STRING) THEN GOTO eeeKindMismatch
		dacc			= OpenAccForType ($$XLONG)
		Move (dacc, $$XLONG, atoken, $$XLONG)
		token		= NextToken ()
		new_op	= token
	ELSE
		token		= NextToken ()
		IF (token <> T_LBRAK) THEN GOTO eeeSyntax
		token		= NextToken ()
		IF (token = T_RBRAK) THEN															' UBOUND(a[]) case
			dacc			= OpenAccForType ($$XLONG)
			Move (dacc, $$XLONG, atoken, $$XLONG)
			token			= NextToken ()
			IF (token <> T_RPAREN) THEN GOTO eeeSyntax
		ELSE
			excess		= 0
			tokenPtr	= holder
			new_type	= atype
			new_data	= NextToken ()
			new_op		= 0
			new_prec	= 0
			IF (atoken != new_data) THEN GOTO eeeCompiler
			ExpressArray (@new_op, @new_prec, @new_data, @new_type, 0, @excess, 0, 0)
			IF XERROR THEN EXIT FUNCTION
			IFZ excess THEN
				IF (new_type != $$STRING) THEN GOTO eeeNeedExcessComma
				DEC oos
			ENDIF
			token			= NextToken ()
			IF (token != T_RPAREN) THEN GOTO eeeSyntax
			IF (arrayType = $$STRING) THEN DEC oos
			dacc			= Top ()
			new_op		= token
'			IF (dacc != $$eax) THEN
'				Code ($$mov, $$regreg, $$eax, dacc, 0, $$XLONG, @"", @"	;;; i592")
'			ENDIF
		ENDIF
	ENDIF
	upper = $$TRUE
	GOSUB GetSizeOrUpperFromHeader
	new_data	= 0
	new_type	= $$XLONG
	GOTO express_op

' Get size/ubound from string/array header

SUB GetSizeOrUpperFromHeader
	d1$ = CreateLabel$ ()
	Code ($$test, $$regreg, dacc, dacc, 0, $$XLONG, @"", @"	;;; i593")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i594")
	Code ($$ld, $$regro, dacc, dacc, -8, $$XLONG, @"", @"	;;; i595")
	EmitLabel (@d1$)
	IF upper THEN Code ($$dec, $$reg, dacc, 0, 0, $$XLONG, @"", @"	;;; i596")
END SUB


' *****  GOADDRESS (labelSymbol)  *****

i_goaddress:
	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token = NextToken ()
	kind	= token{$$KIND}
	stype = token{$$TYPE}
	IF (kind <> $$KIND_LABELS) THEN GOTO eeeSyntax
	IF (stype <> $$GOADDR) THEN GOTO eeeTypeMismatch
	dr	= OpenAccForType ($$GOADDR)

i_goaddr_of_reg:
	go_name$	= "addr " + tab_lab$[token{$$NUMBER}]
	Code ($$mov, $$regimm, dr, 0, 0, $$XLONG, @go_name$, @"	;;; i597")
	token			= NextToken ()
	IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	new_type	= $$GOADDR
	new_op		= token
	GOTO express_op


' *****  SUBADDRESS (SubName)  *****

i_subaddress:
	token	= NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token	= NextToken ()
	kind	= token{$$KIND}
	stype	= token{$$TYPE}
	IF (kind <> $$KIND_LABELS) THEN GOTO eeeSyntax
	IF (stype <> $$SUBADDR) THEN GOTO eeeTypeMismatch
	dr		= OpenAccForType ($$SUBADDR)

i_subaddr_of_reg:
	sub_name$ = "addr " + tab_lab$[token{$$NUMBER}]
	Code ($$mov, $$regimm, dr, 0, 0, $$XLONG, @sub_name$, @"	;;; i598")
	token			= NextToken ()
	IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	new_type	= $$SUBADDR
	new_op		= token
	GOTO express_op


' *****  FUNCADDRESS (FuncName())  *****

i_funcaddress:
	ifuncaddr	= $$TRUE
	token			= NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token			= NextToken ()
addrop_func:
	funcToken	= token
	kind = token{$$KIND}
	IF (kind <> $$KIND_FUNCTIONS) THEN GOTO eeeSyntax
	dr				= OpenAccForType ($$FUNCADDR)

i_funcaddr_of_reg:
	funcaddrFuncNumber = funcToken{$$NUMBER}
	funcaddrToken = funcToken[funcaddrFuncNumber]
	IFZ (funcaddrToken AND $$MASK_DECLARED) THEN
		funcaddrToken = XxxUndeclaredFunction (funcaddrToken)
		IFZ (funcaddrToken AND $$MASK_DECLARED) THEN GOTO eeeUndeclared
	ENDIF
	funcaddrScope	= funcScope[funcaddrFuncNumber]
	SELECT CASE funcaddrScope
		CASE $$FUNC_EXTERNAL, $$FUNC_DECLARE
					funcLabel$ = funcLabel$[funcaddrFuncNumber]
		CASE $$FUNC_INTERNAL
					funcLabel$ = "func" + HEX$(funcaddrFuncNumber) + "." + programName$
		CASE ELSE
					PRINT "funcScope": GOTO eeeCompiler
	END SELECT
	IF XERROR THEN EXIT FUNCTION
	Code ($$mov, $$regimm, dr, 0, 0, $$XLONG, "addr " + funcLabel$, @"	;;; i599")
	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token = NextToken ()
	IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	IF ifuncaddr THEN
		ifuncaddr = $$FALSE
		token		= NextToken ()
		IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	ENDIF
	new_data	= $$FALSE
	new_type	= $$FUNCADDR
	new_op		= token
	GOTO express_op


' *****  INTRINSIC SUPPORT  *****

intrinDone:
	Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i600")
	GOTO express_op

i_bad_type:
	tokenPtr = arg_pos${i_bad_arg-1}
  PRINT "Expresso : i_bad_type"
	GOTO eeeTypeMismatch

i_too_few_args:
	IF args THEN tokenPtr = arg_pos${args-1}
	GOTO eeeTooFewArgs



' *****************************************
' *****  FUNCTIONS  *****  FUNCTIONS  *****
' *****************************************

express_function:
	args = 0
	argBytes = 0
	fkind = token{$$KIND}
	hold_func_ptr = tokenPtr

	IF (token = T_ATSIGN) THEN
		hfp				= hold_func_ptr
		token			= NextToken ()
		vtype			= TheType (token)
		fkind			= token{$$KIND}
		hold_func_ptr = tokenPtr
		SELECT CASE fkind
			CASE $$KIND_VARIABLES, $$KIND_ARRAYS
			CASE ELSE:  GOTO eeeSyntax
		END SELECT
		tokenPtr	= hfp
		new_op		= Eval (@new_type)
		IF XERROR THEN EXIT FUNCTION
		fzip$ = CreateLabel$ ()
		IF (new_type != $$FUNCADDR) THEN GOTO eeeTypeMismatch
		IF (new_op != T_LPAREN) THEN GOTO eeeSyntax
		DEC tokenPtr
		DIM temp[]
		IF (vtype = $$FUNCADDR) THEN		' FUNCADDR variable/array
			fat			= token{$$NUMBER}
			IFZ tabArg[fat, ] THEN PRINT "@@@": GOTO eeeCompiler
			ATTACH tabArg[fat, ] TO temp[]
			CloneArrayXLONG (@parArg[], @temp[])
			ATTACH temp[] TO tabArg[fat, ]
		ELSE														' FUNCADDR .component
			ATTACH typeEleArg[preType, componentNumber, ] TO temp[]
			CloneArrayXLONG (@parArg[], @temp[])
			ATTACH temp[] TO typeEleArg[preType, componentNumber, ]
		ENDIF
	ENDIF

	old_infunc	= infunc
	hold_func		= token
	infunc			= token
	func_num		= token{$$NUMBER}
	SELECT CASE fkind
		CASE $$KIND_FUNCTIONS
					passError		= $$TRUE
					IF (funcScope[func_num] = $$FUNC_EXTERNAL) THEN
						IF (funcKind[func_num] = $$CFUNC) THEN passError = $$FALSE
					ENDIF
					IFZ funcArg[func_num, ] THEN
						token = XxxUndeclaredFunction (token)
						IFZ funcArg[func_num, ] THEN GOTO eeeUndeclared
						hold_func = token
					ENDIF
					callKind = funcKind[func_num]
					ATTACH funcArg[func_num, ] TO temp[]
					CloneArrayXLONG (@parArg[], @temp[])
					ATTACH temp[] TO funcArg[func_num, ]
					func_type		= parArg[0] {$$WORD0}
					total_args	= parArg[0] {$$BYTE2}
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
					func_type		= parArg[0] {$$WORD0}
					total_args	= parArg[0] {$$BYTE2}
					callKind		= parArg[0] >> 29
					IFZ callKind THEN callKind = $$XFUNC
		CASE ELSE
					PRINT "eeefuncaddr000":	GOTO eeeCompiler
	END SELECT
	DIM argArg[]
	CloneArrayXLONG (@argArg[], @parArg[])
	IF (func_type AND (func_type < $$SLONG)) THEN func_type = $$XLONG

	DIM argReg[31]
	DIM orgReg[31]
	etc = $$FALSE
	rctoken = $$FALSE
	IF (func_type >= $$SCOMPLEX) THEN
		rcname$	= ".compositeReturnAddr." + HEX$(compositeArg)
		INC compositeArg
		rctoken	= $$T_VARIABLES + ($$AUTOX << 21)
		rctoken	= AddSymbol (@rcname$, rctoken, func_number)
		rctoken	= rctoken OR ($$AUTOX << 21)
		rcnum		= rctoken{$$NUMBER}
		tab_sym[rcnum] = rctoken
		tabType[rcnum] = func_type
		IF m_addr[rcnum] THEN PRINT "comRetVal": GOTO eeeCompiler
		AssignAddress (rctoken)
		IF XERROR THEN EXIT FUNCTION
	ENDIF

	cfunc = $$FALSE
	hold_place = tokenPtr
	IF (fkind = $$KIND_FUNCTIONS) THEN
		IF (funcKind[func_num] = $$CFUNC) THEN
			cfunc = $$TRUE
			IF total_args THEN
				parArgs = parArg[0] {$$BYTE2}
				IF (parArg[parArgs] {$$WORD0} = $$ETC) THEN
					etc = $$TRUE
					DEC total_args
				ENDIF
			ENDIF
		ENDIF
		IFZ hold_func{$$ALLO} THEN
			hold_func = XxxUndeclaredFunction (hold_func)
			IFZ hold_func{$$ALLO} THEN GOTO eeeUndeclared
			callKind = funcKind[func_num]
		ENDIF
	ENDIF

	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax

' if FUNCADDR variable or array, test function address and skip if addr = 0

	SELECT CASE fkind
		CASE $$KIND_FUNCTIONS
					OpenBothAccs ()
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
					SELECT CASE TRUE
						CASE (a0 AND (a0 = toes))
									IF a1 THEN Push ($$RA1, a1_type)
						CASE (a1 AND (a1 = toes))
									IF a0 THEN Push ($$RA0, a0_type)
									Move ($$RA0, $$XLONG, $$RA1, $$XLONG)
									a1 = 0: a1_type = 0
						CASE ELSE
									PRINT "eeefuncaddr000a":	GOTO eeeCompiler
					END SELECT
					Code ($$xor, $$regreg, $$R11, $$R11, 0, $$XLONG, @"", @"	;;; i602")
					Code ($$test, $$regreg, $$R10, $$R10, 0, $$XLONG, @"", @"	;;; i603")
					Code ($$jz, $$rel, 0, 0, 0, 0, ">> " + fzip$, @"	;;; i604")
					Push ($$RA0, $$XLONG)
		CASE ELSE:		PRINT "eeefuncaddr001":	GOTO eeeCompiler
	END SELECT

' IF no arguments, skip argument processing

	check = PeekToken ()
	IF (check = T_RPAREN) THEN
		token		= NextToken ()
		noArgs	= $$TRUE
		new_op	= token
		GOTO PastArgs
	ENDIF
	noArgs		= $$FALSE

	IF (old_op = T_ADDR_OP) THEN DEC tokenPtr: GOTO eeeSyntax
	hold_rerun = tokenPtr

' ********************************
' *****  FUNCTION ARGUMENTS  *****
' ********************************

	args = 0
	argNum = 1
	refCount = 0
	argOffset = 0
	DIM farg[63]
	frame = $$FALSE
	skipit = $$FALSE
	fixArgs = $$FALSE
	IF (fkind = $$KIND_FUNCTIONS) THEN
		SELECT CASE callKind
			CASE $$XFUNC:	argSize = funcArgSize[func_num]
			CASE $$SFUNC:	argSize = funcArgSize[func_num]
			CASE $$CFUNC:	argSize = funcArgSize[func_num]
'										argSize = 64 : frame = $$TRUE
			CASE ELSE:		PRINT "callKind ="; callKind : GOTO eeeCompiler
		END SELECT
	ELSE
		argSize = 0
		IF total_args THEN
			FOR i = 1 TO total_args
				aaKind = argArg[i]{$$BYTE3}
				IF (aaKind = $$KIND_ARRAYS) THEN
					argSize = argSize + 4
				ELSE
					aaType = argArg[i]{$$WORD0}
					SELECT CASE aaType
						CASE $$GIANT, $$DOUBLE:		argSize = argSize + 8
						CASE $$LONGDOUBLE:				argSize = argSize + 12
						CASE ELSE:								argSize = argSize + 4
					END SELECT
				ENDIF
			NEXT i
		ENDIF
	ENDIF

' create frame if necessary  -  CFUNCTIONs

'	IF frame THEN Code ($$sub, $$regimm, $$esp, argSize, 0, $$XLONG, @"", @"	;;; i605")

	DO
		qref = PeekToken ()							'  "@" (BYREF) prefix on next argument ?
		IF (qref = T_ATSIGN) THEN
			INC refCount
			qref = $$TRUE
			trash = NextToken ()					' skip "@"
		ELSE
			qref = $$FALSE
		ENDIF

		ttoken		= PeekToken ()
		tkind			= ttoken{$$KIND}
		ttype			= TheType (ttoken)
		tt				= ttoken{$$NUMBER}
		refarray	= $$FALSE
		valarray	= $$FALSE
		stringLit	= $$FALSE
		IF qref THEN
			SELECT CASE tkind
				CASE $$KIND_VARIABLES
				CASE $$KIND_ARRAYS
							IFZ m_addr$[tt] THEN AssignAddress (ttoken)
							IF XERROR THEN EXIT FUNCTION
							token = NextToken ()
							token = NextToken ()
							IF (token <> T_LBRAK) THEN GOTO eeeSyntax
							token = NextToken ()
							IF (token <> T_RBRAK) THEN GOTO eeeSyntax
							refarray	= $$TRUE
							new_op		= NextToken ()
							new_prec	= new_op{$$PREC}
							new_data	= ttoken
							new_type	= TheType (ttoken)
							skipit		= $$TRUE
				CASE $$KIND_LITERALS, $$KIND_SYSCONS, $$KIND_CONSTANTS
							IF (ttype != $$STRING) THEN GOTO eeeByRef
							stringLit	= 0x20
				CASE ELSE
							GOTO eeeByRef
			END SELECT
			IF cfunc AND (args = 0) THEN GOTO eeeByRef
		ELSE
			SELECT CASE tkind
				CASE $$KIND_VARIABLES
				CASE $$KIND_CONSTANTS, $$KIND_SYSCONS
				CASE $$KIND_ARRAYS
							IFZ m_addr$[tt] THEN AssignAddress (ttoken)
							IF XERROR THEN EXIT FUNCTION
							htp				= tokenPtr
							check			= NextToken ()
							check			= NextToken ()
							IF (check <> T_LBRAK) THEN tokenPtr = htp + 1: GOTO eeeByVal
							check			= NextToken ()
							IF (check = T_RBRAK)  THEN tokenPtr = htp + 1: GOTO eeeByVal
							tokenPtr	= htp
							valarray	= $$TRUE
				CASE $$KIND_CHARCONS, $$KIND_LITERALS
				CASE $$KIND_ADDR_OPS
				CASE $$KIND_UNARY_OPS, $$KIND_BINARY_OPS
				CASE $$KIND_INTRINSICS, $$KIND_STATEMENTS_INTRINSICS
				CASE $$KIND_FUNCTIONS, $$KIND_LPARENS
				CASE ELSE:  INC tokenPtr:  GOTO eeeByVal
			END SELECT
		ENDIF

		IFZ skipit THEN
			test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
			Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
			IF XERROR THEN EXIT FUNCTION
			IFZ new_type THEN GOTO eeeTypeMismatch
			IF (new_type < $$SLONG) THEN new_type = $$SLONG
		ENDIF
		skipit				= $$FALSE
		IF (new_type = $$STRING) THEN
			string_type	= $$TRUE
		ELSE
			string_type	= $$FALSE
		ENDIF

		IFZ refarray THEN
			IF (new_type >= $$SCOMPLEX) THEN
				IF new_data THEN
					dacc = OpenAccForType (new_type)
					Move (dacc, $$XLONG, new_data, $$XLONG)
					new_data = 0
				ELSE
					dacc = Top ()
					IF (dacc != $$RA0) THEN PRINT "??? OK ???"
				ENDIF
				IF qref THEN
					qref			= $$FALSE
				ELSE
					cname$	= ".compositeArg." + HEX$(compositeArg)
					INC compositeArg
					ctoken	= $$T_VARIABLES OR ($$AUTOX << 21)
					ctoken	= AddSymbol (@cname$, ctoken, func_number)
					ctoken	= ctoken OR ($$AUTOX << 21)
					cnum		= ctoken{$$NUMBER}
					tab_sym[cnum] = ctoken
					tabType[cnum] = new_type
					IF m_addr[cnum] THEN PRINT "comArg1": GOTO eeeCompiler
					AssignAddress (ctoken)
					IF XERROR THEN EXIT FUNCTION
					csizer	= typeSize[new_type]
					Move ($$edi, $$XLONG, ctoken, $$XLONG)
					Move ($$esi, $$XLONG, dacc, $$XLONG)
					Code($$mov, $$regimm, $$ecx, csizer, 0,$$XLONG, @"", @"	;;; i606a")
					Code ($$mov, $$regreg, dacc, $$edi, 0, $$XLONG, @"", @"	;;; i606b")
					Code ($$call, $$rel, 0,0,0,0, @"%_assignComposite", @"	;;; i607")
				ENDIF
			ENDIF
		ENDIF

		SELECT CASE TRUE
			CASE etc:			IF (argNum > total_args) THEN
											parKindType			= parArg[argNum] AND 0xFFFF0000
											parArg[argNum]	= parKindType OR new_type
											argKindType			= argArg[argNum] AND 0xFFFF0000
											argArg[argNum]	= argKindType OR new_type
											to_type					= new_type
										ELSE
											to_type					= parArg[argNum]{$$WORD0}
										ENDIF
			CASE ELSE:		IF (argNum > total_args) THEN
											IF func_num THEN GOTO eeeTooManyArgs
										ENDIF
										to_type						= parArg[argNum]{$$WORD0}
										IF (to_type = $$ANY) THEN
											IF refarray THEN
												kind	= $$KIND_ARRAYS
											ELSE
												kind	= $$KIND_VARIABLES
												IF (parArg[argNum]{$$KIND} = $$KIND_ARRAYS) THEN GOTO eeeKindMismatch
											ENDIF
											parKindType			= parArg[argNum] AND 0x00FF0000
											parArg[argNum]	= parKindType OR (kind << 24) OR new_type
											argKindType			= argArg[argNum] AND 0x00FF0000
											argArg[argNum]	= argKindType OR (kind << 24) OR new_type
											to_type					= new_type
										ENDIF
		END SELECT

'	  Check for KIND MISMATCH, except etc...

		IF func_num OR (argNum > total_args) THEN
			pkind = parArg[argNum]{$$KIND}
			IF refarray THEN
				IF (pkind != $$KIND_ARRAYS) THEN
					tokenPtr = tokenPtr - 3
					GOTO eeeKindMismatch
				ENDIF
			ELSE
				IF (pkind = $$KIND_ARRAYS) THEN DEC tokenPtr: GOTO eeeKindMismatch
			ENDIF
		ENDIF
		IFZ refarray THEN
			IF (to_type < $$SLONG) THEN to_type = $$SLONG
		ENDIF
		argToken[argNum]	= new_data
		from_type = new_type
		IF (to_type != $$ANY) THEN
			IF ((to_type = $$STRING) XOR (from_type = $$STRING)) THEN GOTO eeeTypeMismatch
		ENDIF

' If type conversion is required to assign value back to original
' variable, then fixArgs stack handling method is necessary to avoid
' overwriting arguments on stack when calling conversion routines.

		IF (to_type != from_type) THEN
			IF (to_type >= $$SCOMPLEX) THEN GOTO eeeTypeMismatch
			IF (from_type >= $$SCOMPLEX) THEN GOTO eeeTypeMismatch
			conv = typeConvert[to_type, from_type] {{$$BYTE0}}
			SELECT CASE conv
				CASE -1		: GOTO eeeTypeMismatch
				CASE  0		: ' no conversion
				CASE ELSE	: IF qref THEN fixArgs = $$TRUE
										IF refarray THEN tokenPtr = tokenPtr - 3 : GOTO eeeTypeMismatch
			END SELECT
			IF refarray THEN
				t = q_type_long_or_addr[to_type]
				f = q_type_long_or_addr[from_type]
				IF t THEN
					IFZ f THEN tokenPtr = tokenPtr - 3 : GOTO eeeTypeMismatch
				ELSE
					IF f THEN tokenPtr = tokenPtr - 3 : GOTO eeeTypeMismatch
				ENDIF
			ENDIF
		ENDIF

' if argument hasn't been stacked, stack it.

		stack = $$FALSE
		IF new_data THEN
			kind = new_data{$$KIND}
			nn = new_data{$$NUMBER}
			orgReg[argNum] = r_addr[nn]
			argKindType = argArg[argNum] AND 0xFFFF0000
			argArg[argNum] = argKindType OR from_type
			IF (parArg[argNum]{$$KIND} = $$KIND_ARRAYS) THEN
				farg[args].token = new_data
				farg[args].varType = $$XLONG
				farg[args].argType = $$XLONG
				farg[args].stack = $$FALSE
				farg[args].byRef = $$TRUE
				farg[args].kind = kind
			ELSE
				IF (from_type = $$STRING) THEN
					IF (nn = nullstringer) THEN qref = $$TRUE
					IFZ qref THEN
						GOSUB PassString
						fixArgs = $$TRUE
						kind = $$KIND_VARIABLES
						IF (etc OR (argNum < total_args)) THEN
							Push ($$eax, $$XLONG)
							stack = $$TRUE
							new_data = 0
							nn = 0
						ELSE
							new_data = $$eax
						ENDIF
					ENDIF
					DEC oos
				ENDIF
				farg[args].token = new_data
				farg[args].varType = from_type
				farg[args].argType = to_type
				farg[args].stack = stack
				farg[args].byRef = qref
				farg[args].kind = kind
			ENDIF
			nn = 0
			new_data = 0
			ref_flags = 0					' variable
		ELSE
			nn = Top ()
			ref_flags	= 0x80			' expression
			IF qref THEN tokenPtr = tokenPtr - 3 : GOTO eeeByRef
			IF (from_type = $$STRING) THEN
				IF (oos[oos] = 'v') THEN GOSUB PassString
				fixArgs = $$TRUE
				DEC oos
			ENDIF
			IF (etc OR (argNum < total_args)) THEN
				Push (nn, from_type)
				stack = $$TRUE
				new_data = 0
				nn = 0
			ENDIF
			DEC toes
			a0 = 0 : a0_type = 0
			a1 = 0 : a1_type = 0
			farg[args].token = nn										' 0 means "pushed"
			farg[args].varType = from_type
			farg[args].argType = to_type
			farg[args].byRef = $$FALSE
			farg[args].stack = stack
			farg[args].kind = $$KIND_VARIABLES
		ENDIF
		IF XERROR THEN EXIT FUNCTION

'	 if arg had a "@" BYREF prefix, note this in arg_type$

		IF qref THEN ref_flags = ref_flags OR 0x40 OR stringLit		' by reference
		parArg[argNum] = parArg[argNum] OR (ref_flags << 24)

		SELECT CASE new_op
			CASE T_COMMA	: argLoop = $$TRUE
			CASE T_SEMI		: argLoop = $$TRUE
			CASE T_COLON	: argLoop = $$TRUE
			CASE T_RPAREN	: argLoop = $$FALSE
			CASE ELSE:			GOTO eeeSyntax
		END SELECT
		INC args
		INC argNum
	LOOP WHILE argLoop
	IF XERROR THEN EXIT FUNCTION


' *************************************
' *****  FUNCTION ARGS PROCESSED  *****
' *************************************

PastArgs:
	IF (args < total_args) THEN GOTO eeeTooFewArgs
	IF (args > total_args) THEN
		IF etc THEN total_args = args ELSE GOTO eeeTooManyArgs
	ENDIF

' *******************************************************
' *****  Push arguments onto stack in reverse order *****
' *******************************************************

	FOR arg = args-1 TO 0 STEP -1
		farg = farg[arg]
		PushFuncArg (@farg)
		IF XERROR THEN EXIT FUNCTION
		SELECT CASE farg.argType
			CASE $$GIANT, $$DOUBLE		: argOffset = argOffset + 8
			CASE $$LONGDOUBLE					: argOffset = orgOffset + 12
			CASE ELSE									: argOffset = argOffset + 4
		END SELECT
	NEXT arg

' ***************************
' *****  FUNCTION CALL  *****
' ***************************

call_func:
	SELECT CASE fkind
		CASE $$KIND_FUNCTIONS
					funcScope = funcScope[func_num]
					SELECT CASE funcScope
						CASE $$FUNC_EXTERNAL
									funcLabel$ = funcLabel$[func_num]
									IF XERROR THEN EXIT FUNCTION
						CASE $$FUNC_INTERNAL, $$FUNC_DECLARE
									funcLabel$ = "func" + HEX$(func_num) + "." + programName$
					END SELECT
					IF rctoken THEN
						Move ($$R12, $$XLONG, rctoken, $$XLONG)
						a1_type = 0
					ENDIF
					Code ($$call, $$rel, 0, 0, 0, 0, @funcLabel$, @"	;;; i619")
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
					IFZ toes THEN PRINT "eeefuncaddr002": GOTO eeeCompiler
					Pop ($$eax, $$XLONG)
					a0 = 0: a0_type = 0
					DEC toes
					Code ($$call, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i620")
		CASE ELSE
					GOTO eeeCompiler
	END SELECT

	IF (callKind != $$CFUNC) THEN
		IF fixArgs THEN
			Code ($$sub, $$regimm, $$esp, argSize, 0, $$XLONG, @"", @"	;;; xnt1i")
		ENDIF
	ENDIF

call_retval:
	INC toes
	a0 = toes
	a0_type = func_type
	GOSUB DoShuffle

functions_end:
	new_data	= 0
	new_type	= func_type
	infunc		= old_infunc
	IF fixArgs THEN callKind = $$CFUNC
	IF etc THEN argSize = argOffset
	IFZ noArgs THEN
		SELECT CASE callKind
			CASE $$XFUNC
			CASE $$SFUNC
			CASE $$CFUNC:	Code ($$add, $$regimm, $$esp, argSize, 0, $$XLONG, @"", @"	;;; i633")
		END SELECT
	ENDIF
	IF (fkind != $$KIND_FUNCTIONS) THEN EmitLabel (@fzip$)
	IF (func_type = $$STRING) THEN INC oos: oos[oos] = 's'
	IF func_type THEN
		IF (func_type < $$SLONG) THEN PRINT "expresso61": GOTO eeeCompiler
	ENDIF
	GOTO express_op

' pass strings by value:  clone, pass clone address, deallocate after return

SUB PassString
	IF (nn != $$RA0) THEN Move ($$RA0, $$XLONG, nn, $$XLONG)
	IF qref THEN PRINT "expresso60a": GOTO eeeCompiler
	IF (oos[oos] != 'v') THEN PRINT "expresso60b": GOTO eeeCompiler
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"	;;; i634")
	nn = $$RA0
END SUB


' Update variables passed by reference

SUB DoShuffle
	mode = 0
	offset = 0
	FOR arg_num = 1 TO total_args
		oreg			= orgReg[arg_num]
		areg			= argReg[arg_num]
		ptype			= parArg[arg_num] {$$WORD0}
		atype			= argArg[arg_num] {$$WORD0}
		pkind			= parArg[arg_num] {$$BYTE3}
		atoken		= argToken[arg_num]
		stringLit	= pkind{{1,5}}
		passByRef	= pkind{{1,6}}
		IFZ stringLit THEN
			IF (passByRef OR (ptype = $$STRING)) THEN
				IF fixArgs THEN
					Shuffle (areg, oreg, atype, ptype, atoken, pkind, mode, offset)
				ELSE
					Shuffle (areg, oreg, atype, ptype, atoken, pkind, mode, offset - argSize)
				ENDIF
			ENDIF
		ENDIF
		k = pkind AND 0x001F
		IF (k != $$KIND_ARRAYS) THEN k = $$KIND_VARIABLES
		SELECT CASE k
			CASE $$KIND_ARRAYS
						offset	= offset + 4
			CASE $$KIND_VARIABLES
						SELECT CASE ptype
							CASE $$GIANT, $$DOUBLE:		offset = offset + 8
							CASE $$LONGDOUBLE:				offset = offset + 12
							CASE ELSE:								offset = offset + 4
						END SELECT
		END SELECT
	NEXT arg_num
END SUB


' ******************************************************
' *****  BINARY OPERATOR WHEN WANTING DATA OBJECT  *****
' ******************************************************

' Binary ops are errors here...  could it be a unary op?

express_binary_op:
	SELECT CASE token
		CASE T_ADD:      token = T_PLUS
		CASE T_SUBTRACT: token = T_MINUS
		CASE T_ANDBIT:   token = T_ADDR_OP:    GOTO express_addr_op
		CASE T_ANDL:     token = T_HANDLE_OP:  GOTO express_addr_op
		CASE ELSE:       GOTO eeeSyntax
	END SELECT
	GOTO express_unary_op


' *****  LEFT PARENTHESES WHEN WANTING DATA ITEM  *****

express_lparen:
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	new_test = old_test: new_op = 0: new_data = 0: new_type = 0: new_prec = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IF (new_op <> T_RPAREN) THEN GOTO eeeSyntax
	new_op   = 0
	new_prec = 0
	GOTO express_op


' *****  RIGHT PARENTHESES  *****  Error or null expression... ()

express_rparen:
	IF got_expression THEN GOTO eeeSyntax
	old_test = 0
	old_op   = token
	old_data = 0
	RETURN


' *****  ADDRESS OPERATORS  *****  &, &&

express_addr_op:
	SELECT CASE  token
		CASE T_ADDR_OP:		addr_op    = $$TRUE
											handle_op  = $$FALSE
		CASE T_HANDLE_OP:	addr_op    = $$FALSE
											handle_op  = $$TRUE
		CASE  ELSE:				PRINT "expresso61a": GOTO eeeCompiler
	END SELECT
	stringAddr			= $$FALSE
	compositeAddr		= $$FALSE
	constantAddr		= $$FALSE
	register_string	= $$FALSE
	new_data				= NextToken ()
	kind						= new_data{$$KIND}
	new_type				= TheType(new_data)
	IF (new_type = $$STRING) THEN stringAddr = $$TRUE
	IF (new_type >= $$SCOMPLEX) THEN compositeAddr = $$TRUE
	SELECT CASE kind
		CASE $$KIND_VARIABLES
					IF handle_op THEN
						IFF (stringAddr OR compositeAddr) THEN GOTO eeeSyntax
					ENDIF
		CASE $$KIND_ARRAYS
					IF compositeAddr THEN EXIT SELECT
		CASE $$KIND_FUNCTIONS
					token = new_data
					GOTO addrop_func
		CASE $$KIND_ARRAYS
					GOTO addr_others
		CASE $$KIND_LITERALS
					IFZ stringAddr THEN GOTO eeeTypeMismatch
					IF handle_op THEN GOTO eeeLiteral
					constantAddr = $$TRUE
		CASE $$KIND_SYSCONS, $$KIND_CONSTANTS
					IFZ stringAddr THEN GOTO eeeKindMismatch
					IF handle_op THEN GOTO eeeLiteral
					constantAddr = $$TRUE
		CASE ELSE
					GOTO eeeKindMismatch
	END SELECT
	nn = new_data{$$NUMBER}
	got_expression = $$TRUE
	new_type = TheType (new_data)
	IF (new_type < $$SLONG) THEN new_type = $$SLONG
	IFF m_addr$[nn] THEN AssignAddress (new_data)
	IF XERROR THEN EXIT FUNCTION
	IF (new_type >= $$SCOMPLEX) THEN
		stringAddr = $$TRUE

'		subComposite == a composite expression including sub-element references
'   varComposite == a composite variable/array without sub-element references
'		Source:  			GETADDR valid for subComposites
'						 			GETHANDLE valid for pointer sub-elements in subComposites
'					( tested in Composite() )

		lastElement = LastElement (new_data, 0, 0)		'	Drop through if varComposite
		IF XERROR THEN EXIT FUNCTION
		IFF lastElement THEN													' composite + elements
			SELECT CASE TRUE
				CASE addr_op:			command = $$GETADDR
				CASE handle_op:		command = $$GETHANDLE
			END SELECT
			Composite (@command, @new_type, @new_data, @theOffset, 0)
			IF XERROR THEN EXIT FUNCTION
			sreg = new_data
			IFZ command THEN
				dreg = OpenAccForType ($$XLONG)
				Code ($$lea, $$regro, dreg, sreg, theOffset, $$XLONG, @"", @"	;;; i635")
			ELSE
				IF theOffset THEN
					dreg = sreg
					Code ($$lea, $$regro, dreg, sreg, theOffset, $$XLONG, @"", @"	;;; i636")
				ENDIF
			ENDIF
			new_op = 0
			new_prec = 0
			new_data = 0
			new_type = $$XLONG
			GOTO express_op
		ENDIF
	ENDIF

	n$		= tab_sym$[nn]
	m$		= m_addr$[nn]
	rn		= r_addr[nn]
	mReg	= m_reg[nn]
	mAddr	= m_addr[nn]

	IF (kind = $$KIND_ARRAYS) THEN GOTO addr_others

	IF (stringAddr AND addr_op) THEN
		aop486	= $$ld
	ELSE
		aop486	= $$lea
	ENDIF

	IF mReg THEN
		mode = $$regro
	ELSE
		IF constantAddr THEN
			mode = $$regimm
		ELSE
			mode = $$regabs
		ENDIF
	ENDIF

addr_var_x:
	accx = 0
	IF a0 THEN accx = accx + 1
	IF a1 THEN accx = accx + 2
	IF (accx = 3) THEN GOTO avma
	IF (accx = 2) THEN GOTO avmb
	IF (accx = 1) THEN GOTO avmc
	IF (accx = 0) THEN GOTO avmb
	PRINT "expresso62": GOTO eeeCompiler
avma:
	IF (a1 > a0) THEN GOTO avm0
	IF (a1 < a0) THEN GOTO avm1
	PRINT "expresso63": GOTO eeeCompiler
avm0:
	Push($$RA0, a0_type)
avmb:
	arc = $$R10
	INC toes
	a0 = toes: a0_type = $$XLONG
	GOTO avall
avm1:
	Push($$RA1, a1_type)
avmc:
	arc = $$R12
	INC toes
	a1 = toes: a1_type = $$XLONG
	GOTO avall
avall:
	IF m$ = "$$SYSCON" THEN m$ = "0"   ' case of &""
	Code (aop486, mode, arc, mReg, mAddr, $$XLONG, @m$, @"	;;; i642")
	new_op = 0
	new_prec = 0
	new_data = 0
	new_type = $$XLONG
	GOTO express_op

' address of objects other than variables

addr_others:
	DEC tokenPtr
	new_op = token
	new_prec = new_op{$$PREC}
	new_data = 0
	new_type = 0
	test = 0
	Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
	GOTO exo


' *****  TERMINATORS  *****

express_term:
	IF got_expression THEN GOTO eeeSyntax
	old_test = 0
	old_op   = token
	old_prec = 0
	old_data = new_data
	old_type = new_type
	RETURN


' ****************************
' *****  SUB InitArrays  *****
' ****************************

SUB InitArrays
	DIM argToken [63]
	DIM dataKind [31]
	dataKind [ $$KIND_VARIABLES			] = GOADDRESS (express_var)
	dataKind [ $$KIND_SYSCONS				] = GOADDRESS (express_var)
	dataKind [ $$KIND_CHARCONS			] = GOADDRESS (express_var)
	dataKind [ $$KIND_LITERALS			] = GOADDRESS (express_var)
	dataKind [ $$KIND_CONSTANTS			] = GOADDRESS (express_var)
	dataKind [ $$KIND_ARRAYS				] = GOADDRESS (express_array)
	dataKind [ $$KIND_FUNCTIONS			] = GOADDRESS (express_function)
	dataKind [ $$KIND_INTRINSICS		] = GOADDRESS (express_intrinsic)
	dataKind [ $$KIND_STATE_INTRIN	] = GOADDRESS (express_intrinsic)
	dataKind [ $$KIND_UNARY_OPS			] = GOADDRESS (express_unary_op)
	dataKind [ $$KIND_BINARY_OPS		] = GOADDRESS (express_binary_op)
	dataKind [ $$KIND_ADDR_OPS			] = GOADDRESS (express_addr_op)
	dataKind [ $$KIND_LPARENS				] = GOADDRESS (express_lparen)
	dataKind [ $$KIND_RPARENS				] = GOADDRESS (express_rparen)
	dataKind [ $$KIND_TERMINATORS		] = GOADDRESS (express_term)
	dataKind [ $$KIND_COMMENTS			] = GOADDRESS (express_term)
	dataKind [ $$KIND_STARTS				] = GOADDRESS (express_term)
	dataKind [ $$KIND_CHARACTERS		] = GOADDRESS (express_character)

	DIM opKind [31]
	opKind [ $$KIND_SYMBOLS				] = GOADDRESS (express_op_component)
	opKind [ $$KIND_ARRAY_SYMBOLS	] = GOADDRESS (express_op_component)
	opKind [ $$KIND_LPARENS				] = GOADDRESS (express_op_lparen)
	opKind [ $$KIND_COMMENTS			] = GOADDRESS (express_op_rem)
	opKind [ $$KIND_TERMINATORS		] = GOADDRESS (express_ops)
	opKind [ $$KIND_BINARY_OPS		] = GOADDRESS (express_ops)
	opKind [ $$KIND_SEPARATORS		] = GOADDRESS (express_ops)
	opKind [ $$KIND_STARTS				] = GOADDRESS (express_ops)

	DIM firstIntrinToken [255]
	firstIntrinToken [ T_LEN					AND 0x00FF ] = GOADDRESS (i_lenof)
	firstIntrinToken [ T_SIZE					AND 0x00FF ] = GOADDRESS (i_sizeof)
	firstIntrinToken [ T_TYPE					AND 0x00FF ] = GOADDRESS (i_typeof)
	firstIntrinToken [ T_UBOUND				AND 0x00FF ] = GOADDRESS (i_ubound)
	firstIntrinToken [ T_GOADDRESS		AND 0x00FF ] = GOADDRESS (i_goaddress)
	firstIntrinToken [ T_SUBADDRESS		AND 0x00FF ] = GOADDRESS (i_subaddress)
	firstIntrinToken [ T_FUNCADDRESS	AND 0x00FF ] = GOADDRESS (i_funcaddress)
	firstIntrinToken [ T_SBYTEAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_UBYTEAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_SSHORTAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_USHORTAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_SLONGAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_ULONGAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_XLONGAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_GOADDRAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_SUBADDRAT		AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_FUNCADDRAT		AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_GIANTAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_SINGLEAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_DOUBLEAT			AND 0x00FF ] = GOADDRESS (i_atops)
	firstIntrinToken [ T_LONGDOUBLEAT	AND 0x00FF ] = GOADDRESS (i_atops)

	DIM intrinToken [255]
	intrinToken [ T_ABS				AND 0x00FF ] = GOADDRESS (i_abs)
	intrinToken [ T_ASC				AND 0x00FF ] = GOADDRESS (i_asc)
	intrinToken [ T_BIN_D			AND 0x00FF ] = GOADDRESS (i_bin_d)
	intrinToken [ T_BINB_D		AND 0x00FF ] = GOADDRESS (i_binb_d)
	intrinToken [ T_BITFIELD	AND 0x00FF ] = GOADDRESS (i_bitfield)
	intrinToken [ T_CEIL  		AND 0x00FF ] = GOADDRESS (i_ceil)
	intrinToken [ T_CHR_D			AND 0x00FF ] = GOADDRESS (i_chr_d)
	intrinToken [ T_CJUST_D		AND 0x00FF ] = GOADDRESS (i_cjust_d)
	intrinToken [ T_CLOSE			AND 0x00FF ] = GOADDRESS (i_close)
	intrinToken [ T_CLR				AND 0x00FF ] = GOADDRESS (i_clr)
	intrinToken [ T_CSIZE			AND 0x00FF ] = GOADDRESS (i_csize)
	intrinToken [ T_CSIZE_D		AND 0x00FF ] = GOADDRESS (i_csize_d)
	intrinToken [ T_CSTRING_D	AND 0x00FF ] = GOADDRESS (i_cstring_d)
	intrinToken [ T_DHIGH			AND 0x00FF ] = GOADDRESS (i_dhigh)
	intrinToken [ T_DLOW			AND 0x00FF ] = GOADDRESS (i_dlow)
	intrinToken [ T_DMAKE			AND 0x00FF ] = GOADDRESS (i_dmake)
	intrinToken [ T_DOUBLE		AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_EOF				AND 0x00FF ] = GOADDRESS (i_eof)
	intrinToken [ T_ERROR			AND 0x00FF ] = GOADDRESS (i_error)
	intrinToken [ T_ERROR_D		AND 0x00FF ] = GOADDRESS (i_error_d)
	intrinToken [ T_EXTS			AND 0x00FF ] = GOADDRESS (i_exts)
	intrinToken [ T_EXTU			AND 0x00FF ] = GOADDRESS (i_extu)
	intrinToken [ T_FIX				AND 0x00FF ] = GOADDRESS (i_fix)
	intrinToken [ T_FORMAT_D	AND 0x00FF ] = GOADDRESS (i_format_d)
	intrinToken [ T_FUNCADDR	AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_GHIGH			AND 0x00FF ] = GOADDRESS (i_ghigh)
	intrinToken [ T_GIANT			AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_GLOW			AND 0x00FF ] = GOADDRESS (i_glow)
	intrinToken [ T_GMAKE			AND 0x00FF ] = GOADDRESS (i_gmake)
	intrinToken [ T_GOADDR		AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_HEX_D			AND 0x00FF ] = GOADDRESS (i_hex_d)
	intrinToken [ T_HEXX_D		AND 0x00FF ] = GOADDRESS (i_hexx_d)
	intrinToken [ T_HIGH0			AND 0x00FF ] = GOADDRESS (i_high0)
	intrinToken [ T_HIGH1			AND 0x00FF ] = GOADDRESS (i_high1)
	intrinToken [ T_INCHR			AND 0x00FF ] = GOADDRESS (i_inchr)
	intrinToken [ T_INCHRI		AND 0x00FF ] = GOADDRESS (i_inchri)
	intrinToken [ T_INFILE_D	AND 0x00FF ] = GOADDRESS (i_infile_d)
	intrinToken [ T_INLINE_D	AND 0x00FF ] = GOADDRESS (i_inline_d)
	intrinToken [ T_INSTR			AND 0x00FF ] = GOADDRESS (i_instr)
	intrinToken [ T_INSTRI		AND 0x00FF ] = GOADDRESS (i_instri)
	intrinToken [ T_INT				AND 0x00FF ] = GOADDRESS (i_int)
	intrinToken [ T_LCASE_D		AND 0x00FF ] = GOADDRESS (i_lcase_d)
	intrinToken [ T_LCLIP_D		AND 0x00FF ] = GOADDRESS (i_lclip_d)
	intrinToken [ T_LEFT_D		AND 0x00FF ] = GOADDRESS (i_left_d)
	intrinToken [ T_LEN				AND 0x00FF ] = GOADDRESS (i_len)
	intrinToken [ T_LIBRARY		AND 0x00FF ] = GOADDRESS (i_library)
	intrinToken [ T_LJUST_D		AND 0x00FF ] = GOADDRESS (i_ljust_d)
	intrinToken [ T_LOF				AND 0x00FF ] = GOADDRESS (i_lof)
	intrinToken [ T_LONGDOUBLE AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_LTRIM_D		AND 0x00FF ] = GOADDRESS (i_ltrim_d)
	intrinToken [ T_MAKE			AND 0x00FF ] = GOADDRESS (i_make)
	intrinToken [ T_MAX				AND 0x00FF ] = GOADDRESS (i_max)
	intrinToken [ T_MID_D			AND 0x00FF ] = GOADDRESS (i_mid_d)
	intrinToken [ T_MIN				AND 0x00FF ] = GOADDRESS (i_min)
	intrinToken [ T_NULL_D		AND 0x00FF ] = GOADDRESS (i_null_d)
	intrinToken [ T_OCT_D			AND 0x00FF ] = GOADDRESS (i_oct_d)
	intrinToken [ T_OCTO_D		AND 0x00FF ] = GOADDRESS (i_octo_d)
	intrinToken [ T_OPEN			AND 0x00FF ] = GOADDRESS (i_open)
	intrinToken [ T_POF				AND 0x00FF ] = GOADDRESS (i_pof)
	intrinToken [ T_PROGRAM_D	AND 0x00FF ] = GOADDRESS (i_program_d)
	intrinToken [	T_QUIT			AND 0x00FF ] = GOADDRESS (i_quit)
	intrinToken [ T_RCLIP_D		AND 0x00FF ] = GOADDRESS (i_rclip_d)
	intrinToken [ T_RIGHT_D		AND 0x00FF ] = GOADDRESS (i_right_d)
	intrinToken [ T_RINCHR		AND 0x00FF ] = GOADDRESS (i_rinchr)
	intrinToken [ T_RINCHRI		AND 0x00FF ] = GOADDRESS (i_rinchri)
	intrinToken [ T_RINSTR		AND 0x00FF ] = GOADDRESS (i_rinstr)
	intrinToken [ T_RINSTRI		AND 0x00FF ] = GOADDRESS (i_rinstri)
	intrinToken [ T_RJUST_D		AND 0x00FF ] = GOADDRESS (i_rjust_d)
	intrinToken [ T_ROTATEL		AND 0x00FF ] = GOADDRESS (i_rotatel)
	intrinToken [ T_ROTATER		AND 0x00FF ] = GOADDRESS (i_rotater)
	intrinToken [ T_ROUND 		AND 0x00FF ] = GOADDRESS (i_round)
	intrinToken [ T_ROUNDNE 	AND 0x00FF ] = GOADDRESS (i_roundne)
	intrinToken [ T_RTRIM_D		AND 0x00FF ] = GOADDRESS (i_rtrim_d)
	intrinToken [ T_SBYTE			AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_SEEK			AND 0x00FF ] = GOADDRESS (i_seek)
	intrinToken [ T_SET				AND 0x00FF ] = GOADDRESS (i_set)
	intrinToken [ T_SGN				AND 0x00FF ] = GOADDRESS (i_sgn)
	intrinToken [ T_SHELL			AND 0x00FF ] = GOADDRESS (i_shell)
	intrinToken [ T_SIZE			AND 0x00FF ] = GOADDRESS (i_size)
	intrinToken [ T_SIGN			AND 0x00FF ] = GOADDRESS (i_sign)
	intrinToken [ T_SIGNED_D	AND 0x00FF ] = GOADDRESS (i_signed_d)
	intrinToken [ T_SINGLE		AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_SPACE_D		AND 0x00FF ] = GOADDRESS (i_space_d)
	intrinToken [ T_SSHORT		AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_SLONG			AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_SMAKE			AND 0x00FF ] = GOADDRESS (i_smake)
	intrinToken [ T_STR_D			AND 0x00FF ] = GOADDRESS (i_str_d)
	intrinToken [ T_STRING		AND 0x00FF ] = GOADDRESS (i_string)
	intrinToken [ T_STRING_D	AND 0x00FF ] = GOADDRESS (i_string_d)
	intrinToken [ T_STUFF_D		AND 0x00FF ] = GOADDRESS (i_stuff_d)
	intrinToken [ T_SUBADDR		AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_TAB				AND 0x00FF ] = GOADDRESS (i_tab)
	intrinToken [ T_TRIM_D		AND 0x00FF ] = GOADDRESS (i_trim_d)
	intrinToken [ T_UBYTE			AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_UBOUND		AND 0x00FF ] = GOADDRESS (i_ubound)
	intrinToken [ T_UCASE_D		AND 0x00FF ] = GOADDRESS (i_ucase_d)
	intrinToken [ T_USHORT		AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_ULONG			AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_VERSION_D	AND 0x00FF ] = GOADDRESS (i_version_d)
	intrinToken [ T_XLONG			AND 0x00FF ] = GOADDRESS (i_types)
	intrinToken [ T_XMAKE			AND 0x00FF ] = GOADDRESS (i_xmake)

	DIM inlineToken[255]
	inlineToken [ T_BITFIELD	AND 0x00FF ] = $$TRUE
	inlineToken [ T_DHIGH			AND 0x00FF ] = $$TRUE
	inlineToken [ T_DLOW			AND 0x00FF ] = $$TRUE
	inlineToken [ T_DMAKE			AND 0x00FF ] = $$TRUE
	inlineToken [ T_ERROR			AND 0x00FF ] = $$TRUE
	inlineToken [ T_ERROR_D		AND 0x00FF ] = $$TRUE
	inlineToken [ T_GHIGH			AND 0x00FF ] = $$TRUE
	inlineToken [ T_GLOW			AND 0x00FF ] = $$TRUE
	inlineToken [ T_GMAKE			AND 0x00FF ] = $$TRUE
	inlineToken [ T_HIGH0			AND 0x00FF ] = $$TRUE
	inlineToken [ T_HIGH1			AND 0x00FF ] = $$TRUE
	inlineToken [ T_LEN				AND 0x00FF ] = $$TRUE
	inlineToken [ T_LIBRARY		AND 0x00FF ] = $$TRUE
	inlineToken [ T_ROTATEL		AND 0x00FF ] = $$TRUE
	inlineToken [ T_ROTATER		AND 0x00FF ] = $$TRUE
	inlineToken [ T_SGN				AND 0x00FF ] = $$TRUE
	inlineToken [ T_SIGN			AND 0x00FF ] = $$TRUE
	inlineToken [ T_SIZE			AND 0x00FF ] = $$TRUE
	inlineToken [ T_SMAKE			AND 0x00FF ] = $$TRUE
	inlineToken [ T_XMAKE			AND 0x00FF ] = $$TRUE
END SUB

' ********************
' *****  ERRORS  *****
' ********************

eeeBitSpec:
	XERROR = ERROR_BITSPEC
	EXIT FUNCTION

eeeByRef:
	XERROR = ERROR_BYREF
	EXIT FUNCTION

eeeByVal:
	XERROR = ERROR_BYVAL
	EXIT FUNCTION

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION

eeeExplicit:
	XERROR = ERROR_EXPLICIT_VARIABLE
	EXIT FUNCTION

eeeKindMismatch:
	XERROR = ERROR_KIND_MISMATCH
	EXIT FUNCTION

eeeLiteral:
	XERROR = ERROR_LITERAL
	EXIT FUNCTION

eeeNeedExcessComma:
	XERROR = ERROR_NEED_EXCESS_COMMA
	EXIT FUNCTION

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeRegAddr:
	XERROR = ERROR_REGADDR
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION

eeeTooFewArgs:
	XERROR = ERROR_TOO_FEW_ARGS
	EXIT FUNCTION

eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION

eeeUndeclared:
	XERROR = ERROR_UNDECLARED
	EXIT FUNCTION

eeeUndefined:
	XERROR = ERROR_UNDEFINED
	EXIT FUNCTION

eeeUnimplemented:
	XERROR = ERROR_UNIMPLEMENTED
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  FloatLoad ()  #####
' ##########################

FUNCTION  FloatLoad (dreg, stoken, stype)
	SHARED	tab_sym[],  m_reg[],  m_addr[],  m_addr$[],  labelNumber

	IF (stype < $$SLONG) THEN stype = $$SLONG
	SELECT CASE stype
		CASE $$SLONG	: op = $$fild
		CASE $$ULONG	: op = $$fild
		CASE $$XLONG	: op = $$fild
		CASE $$GIANT	: op = $$fild
		CASE $$SINGLE	: op = $$fld
		CASE $$DOUBLE	: op = $$fld
		CASE $$LONGDOUBLE : op = $$fld
		CASE ELSE			: PRINT "FloatLoad1": EXIT FUNCTION
	END SELECT

	ss			= stoken{$$NUMBER}
	stoken	= tab_sym[ss]
	mReg		= m_reg[ss]
	mAddr		= m_addr[ss]
	kind		= stoken{$$KIND}
	SELECT CASE kind
		CASE $$KIND_LITERALS,  $$KIND_CONSTANTS,  $$KIND_SYSCONS
					SELECT CASE stype
						CASE $$SINGLE			: LoadLitnum ($$RA0, $$SINGLE, stoken, stype)
						CASE $$LONGDOUBLE	: LoadLitnum ($$RA0, $$LONGDOUBLE, stoken, stype)
						CASE ELSE					: LoadLitnum ($$RA0, $$DOUBLE, stoken, stype)
					END SELECT
		CASE $$KIND_VARIABLES
					IF (stype != $$ULONG) THEN
						IF mReg THEN
							Code (op, $$ro, 0, mReg, mAddr, stype, @"", @"	;;; i643a")
						ELSE
							Code (op, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"	;;; i643b")
						ENDIF
					ELSE

' xxxxxxxxxx  :  error - gets negative result for large ULONG values (treats as an SLONG)
' that is the case since fild only excepts a source memory address of a signed 16-bit WORD
' integer, a signed 32-bit DWORD integer, or a signed 64-bit QWORD integer.


						d1$ = CreateLabel$ ()
						IF mReg THEN
							Code ($$push, $$imm, 0, 0, 0, $$XLONG, @"", @"	;;; i644a0")
							Code ($$push, $$ro, 0, mReg, mAddr, stype, @"", @"	;;; i644a1")
							Code ($$cmp, $$r0imm, 0, $$esp, 0, $$XLONG, @"", @"	;;; i644a2")
							Code ($$jle, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i644a3")
							Code ($$mov, $$roimm, -1, $$esp, 4, $$XLONG, @"", @"	;;; i644a4")
							EmitLabel (@d1$)
							Code (op, $$r0, 0, $$esp, 0, $$GIANT, @"", @"	;;; i644b")
'							Code (op, $$ro, 0, mReg, mAddr, stype, @"", @"	;;; i644b")
						ELSE
							Code ($$push, $$imm, 0, 0, 0, $$XLONG, @"", @"	;;; i644b0")
							Code ($$push, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"	;;; i644b1")
							Code ($$cmp, $$r0imm, 0, $$esp, 0, $$XLONG, @"", @"	;;; i644b2")
							Code ($$jle, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i644b3")
							Code ($$mov, $$roimm, -1, $$esp, 4, $$XLONG, @"", @"	;;; i644b4")
							EmitLabel (@d1$)
							Code (op, $$r0, 0, $$esp, 0, $$GIANT, @"", @"	;;; i644b")
'							Code (op, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"	;;; i644")
						ENDIF
					ENDIF
	END SELECT
END FUNCTION


' ###########################
' #####  FloatStore ()  #####
' ###########################

FUNCTION  FloatStore (sreg, stoken, stype)
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER

	SELECT CASE stype
		CASE $$SLONG:				op = $$fistp
		CASE $$ULONG:				op = $$fistp
		CASE $$XLONG:				op = $$fistp
		CASE $$GIANT:				op = $$fistp
		CASE $$SINGLE:			op = $$fstp
		CASE $$DOUBLE:			op = $$fstp
		CASE $$LONGDOUBLE: 	op = $$fstp
		CASE ELSE:			PRINT "FloatStore1": GOTO eeeCompiler
	END SELECT

	ss = stoken{$$NUMBER}
	mReg	= m_reg[ss]
	mAddr	= m_addr[ss]
	IF stype == $$ULONG THEN
		' This is a special case: the normal case will cause an overflow for
		' values larger than 0x7FFFFFFF. This special case allocates a temporary
		' 64 bit value on the stack, stores the float into that temporary variable
		' and uses the lower 32 bits.

		' Save eax (is needed later).
		' Note 1: theoretically mReg could be equal
		' to $$eax, in which case the following code fails. In reality this
		' can't be the case, because the eax can't be used in 'register/offset
		' addressing mode.
		' Note 2: Often eax will be saved/restored while it's value is not
		' needed. Unfortunately I (EP) don't (yet) know a way to find out when
		' it's save and when it's not save to destroy the contents of eax.
		Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i645a1")
		' Allocate a 64 bit value on the stack.
		Code ($$sub, $$regimm, $$esp, 8, 0, $$XLONG, @"", @"	;;; i645a1")
		' Store the float value into this 64 bit value
		Code ($$fistp, $$r0, 0, $$esp, 0, $$GIANT, @"", @"	;;; i645a2")
		' Load the low 32 bits of this 64 bit value into eax
		Code ($$ld, $$regr0, $$eax, $$esp, 0, $$ULONG, @"", @"	;;; i645a3")
		' Store eax at the destination
		IF mReg THEN
			Code ($$st, $$roreg, $$eax, mReg, mAddr, stype, @"", @"	;;; i645a4")
		ELSE
			Code ($$st, $$absreg, $$eax, 0, mAddr, stype, m_addr$[ss], @"	;;; i645a5")
		ENDIF
		' Free the 64 bit temporary.
		Code ($$add, $$regimm, $$esp, 8, 0, $$XLONG, @"", @"	;;; i645a7")
		' Restore $eax
		Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i645a1")
	ELSE
		IF mReg THEN
			Code (op, $$ro, 0, mReg, mAddr, stype, @"", @"	;;; i645")
		ELSE
			Code (op, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"	;;; i646")
		ENDIF
	ENDIF
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #####################################
' #####  GetExternalAddresses ()  #####
' #####################################

'FUNCTION  GetExternalAddresses ()
'	SHARED	labaddr[]
'	EXTERNAL ##ERROR

'	SECTION  sections,  sections[]
'	SYMBOL  symbols,  symbols[]

'	argc = -1
'	XstGetCommandLineArguments (@argc, @argv$[])

'	dll = $$FALSE												' default = .EXE, not .DLL
'	labelsIndex = 0
'	IF (argc > 1) THEN
'		FOR ii = 1 TO argc-1
'			IF (argv$[ii] = "-labels") THEN labelsIndex = ii : EXIT FOR
'		NEXT ii
'	ENDIF

'	' Retrieve the full filename/path of the runtime-library.
'	##HINSTANCEDLL = GetModuleHandleA (&"xbl.dll")
'	ifile$ = NULL$(256)
'	ret = GetModuleFileNameA(##HINSTANCEDLL, &ifile$, 256)
'	IF ret = 0 THEN
'		PRINT "> xbl.dll not found."
'		RETURN (0)
'	ENDIF
'	ifile$ = LEFT$(ifile$, ret)
'	ifile = OPEN (ifile$, $$RDSHARE)								' open "XBLite.dll"

'	IF (##ERROR OR (ifile <= 0)) THEN								' open error
'		##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
'		PRINT ifile$; " not found."
'		RETURN (0)
'	ENDIF

'	ilen = LOF (ifile)
'	IF (ilen < 65536) THEN
'		CLOSE (ifile)
'		##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
'		RETURN (0)
'	ENDIF

'	base$ = "_XxxMain"

'' got reasonable size file, so try to process it

'	SEEK (ifile, 128)

'	READ [ifile], signature
'	READ [ifile], machine%%							: machine = machine%%
'	READ [ifile], sectionCount%%				: sectionCount = sectionCount%%
'	READ [ifile], dateTime
'	READ [ifile], symbolTablePointer
'	READ [ifile], symbolCount
'	READ [ifile], optionalHeaderSize%%
'	READ [ifile], flags%%

'	flags = flags%%
'	optionalHeaderSize = optionalHeaderSize%%
'	optionalHeaderOffset = POF (ifile)
'	sectionHeadersOffset = optionalHeaderOffset + optionalHeaderSize

'' *****  OPTIONAL HEADER  *****

'	READ [ifile], magicNumber%%					: magicNumber = magicNumber%%
'	READ [ifile], linkerVersion%%				: linkerVersion = linkerVersion%%
'	READ [ifile], codeSize
'	READ [ifile], dataSize
'	READ [ifile], bssSize
'	READ [ifile], entryAddress
'	READ [ifile], codeAddress
'	READ [ifile], dataAddress

'	READ [ifile], imageBaseAddress
'	READ [ifile], sectionAlignment
'	READ [ifile], fileAlignment
'	READ [ifile], OSVersionMajor%%			: OSVersionMajor = OSVersionMajor%%
'	READ [ifile], OSVersionMinor%%			: OSVersionMinor = OSVersionMinor%%
'	READ [ifile], userVersionMajor%%		: userVersionMajor = userVersionMajor%%
'	READ [ifile], userVersionMinor%%		: userVersionMinor = userVersionMinor%%
'	READ [ifile], subsysVersionMajor%%	: subsysVersionMajor = subsysVersionMajor%%
'	READ [ifile], subsysVersionMinor%%	: subsysVersionMinor = subsysVersionMinor%%
'	READ [ifile], imageVersionMajor%%		: imageVersionMajor = imageVersionMajor%%
'	READ [ifile], imageVersionMinor%%		: imageVersionMinor = imageVersionMinor%%
'	READ [ifile], imageSize
'	READ [ifile], headersSize
'	READ [ifile], checksum
'	READ [ifile], subsystem%%						: subsystem = subsystem%%
'	READ [ifile], dllFlags%%						: dllFlags = dllFlags%%
'	READ [ifile], stackReserveSize
'	READ [ifile], stackCommitSize
'	READ [ifile], heapReserveSize
'	READ [ifile], heapCommitSize
'	READ [ifile], unknown2

'	READ [ifile], interesting
'	READ [ifile], exportDirectoryAddress
'	READ [ifile], exportDirectorySize
'	READ [ifile], importDirectoryAddress
'	READ [ifile], importDirectorySize
'	READ [ifile], resourceDirectoryAddress
'	READ [ifile], resourceDirectorySize
'	READ [ifile], exceptionDirectoryAddress
'	READ [ifile], exceptionDirectorySize
'	READ [ifile], securityDirectoryAddress
'	READ [ifile], securityDirectorySize
'	READ [ifile], baseRelocationDirectoryAddress
'	READ [ifile], baseRelocationDirectorySize
'	READ [ifile], debugDirectoryAddress
'	READ [ifile], debugDirectorySize
'	READ [ifile], descriptionDirectoryAddress
'	READ [ifile], descriptionDirectorySize
'	READ [ifile], specialDirectoryAddress
'	READ [ifile], specialDirectorySize

'	SEEK (ifile, sectionHeadersOffset)	' necessary for BetaNT

'	DIM sections[sectionCount]
'	i = 1
'	DO WHILE (i < sectionCount)
'		READ [ifile], sections
'		sections[i]	= sections
'		INC i
'	LOOP

'	stringBase		= symbolTablePointer + (symbolCount * 18)
'	SEEK (ifile, stringBase)
'	READ [ifile], stringsLength
'	stringsLength	= stringsLength - 4
'	strings$			= NULL$ (stringsLength)
'	stringsAddr		= &strings$
'	READ [ifile], strings$
'	i = 0
'	s = 1
'	SEEK (ifile, symbolTablePointer)
'	DO WHILE (i < symbolCount)
'		addr		= POF (ifile)
'		name$		= NULL$ (8)
'		READ [ifile], name$
'		IF name${0} THEN
'			name$		= TRIM$ (CSIZE$ (name$))
'		ELSE
'			aname		= &name$
'			offset	= XLONGAT (aname, 4)
'			name$		= TRIM$ (CSTRING$ (stringsAddr + offset - 4))
'		ENDIF
'		READ [ifile], value
'		READ [ifile], sectionNumber%%		: sectionNumber = sectionNumber%%
'		READ [ifile], symbolType%%			: symbolType = symbolType%%
'		READ [ifile], storageClass@@		: storageClass = storageClass@@
'		READ [ifile], auxEntries@@			: auxEntries = auxEntries@@
'		skipBase = $$FALSE
'		skip = $$FALSE

'		SELECT CASE name$
'			CASE ".code"	: IFZ textSection THEN textSection = sectionNumber : skip = $$TRUE
'			CASE ".data"	: IFZ dataSection THEN dataSection = sectionNumber : skip = $$TRUE
'			CASE ".bss"		: IFZ bssSection  THEN bssSection  = sectionNumber : skip = $$TRUE
'		END SELECT
'		FOR j = 1 TO auxEntries								' skip aux entries
'			addr		= POF (ifile)
'			addr		= addr + 18
'			SEEK (ifile, addr)
'			INC i
'		NEXT j
'		INC i
'		IFZ skip THEN
'			IFZ skipBase THEN
'				IF (name$ = base$) THEN
'					coffAddr	= imageBaseAddress + value
'					exeAddr = ##MAIN
'					delta			= exeAddr - coffAddr
'					skipBase = $$TRUE
'					EXIT DO
'				ENDIF
'			ENDIF
'		ENDIF
'	LOOP

'	i = 0
'	s = 1
'	DIM symbols[symbolCount]
'	SEEK (ifile, symbolTablePointer)
'	DO WHILE (i < symbolCount)
'		addr		= POF (ifile)
'		name$		= NULL$ (8)
'		READ [ifile], name$
'		IF name${0} THEN
'			name$		= TRIM$ (CSIZE$ (name$))
'		ELSE
'			aname		= &name$
'			offset	= XLONGAT (aname, 4)
'			name$		= TRIM$ (CSTRING$ (stringsAddr + offset - 4))
'		ENDIF
'		READ [ifile], value
'		READ [ifile], sectionNumber%%		: sectionNumber = sectionNumber%%
'		READ [ifile], symbolType%%			: symbolType = symbolType%%
'		READ [ifile], storageClass@@		: storageClass = storageClass@@
'		READ [ifile], auxEntries@@			: auxEntries = auxEntries@@
'		skip = $$FALSE
'		SELECT CASE name$
'			CASE ".code"	: IFZ textSection THEN textSection = sectionNumber : skip = $$TRUE
'			CASE ".data"	: IFZ dataSection THEN dataSection = sectionNumber : skip = $$TRUE
'			CASE ".bss"		: IFZ bssSection  THEN bssSection  = sectionNumber : skip = $$TRUE
'		END SELECT
'		FOR j = 1 TO auxEntries								' skip aux entries
'			addr		= POF (ifile)
'			addr		= addr + 18
'			SEEK (ifile, addr)
'			INC i
'		NEXT j
'		INC i
'		IFZ skip THEN
'			symtab = $$FALSE
'			SELECT CASE  sectionNumber
'				CASE textSection:		symtab = $$TRUE
'				CASE dataSection:		symtab = $$TRUE
'				CASE bssSection:		symtab = $$TRUE
'			END SELECT
'			IF (LEFT$(name$, 4) = "aaaa") THEN symtab = $$FALSE
'			IF (LEFT$(name$, 4) = "xxxx") THEN symtab = $$FALSE
'			IF (INSTR(name$, "%_StartApplication." + programName$)) THEN symtab = $$FALSE
'			IF symtab THEN
'				token = AddLabel (name$, $$T_LABELS, $$XADD)
'				labaddr[token{$$NUMBER}] = imageBaseAddress + value + delta
'				IF labelsIndex THEN
'					PRINT HEX$(token, 8), HEX$(imageBaseAddress + value + delta, 8), name$
'				ENDIF
'			ENDIF
'		ENDIF
'	LOOP
'	CLOSE (ifile)
'	RETURN (token{$$NUMBER}+1)
'END FUNCTION

' ################################
' #####  GetFuncaddrInfo ()  #####
' ################################

' SYNTAX:		FUNCADDR [xFUNCTION] [typename] funcaddrVariableOrArray ( [args] )

' enter:		token				= [typename] or funcaddrVariableOrArray token
' return:		returnVal		= terminating token
'						token				= funcaddrVariableOrArray token
'						eleElements	= # of elements in funcaddrArray[upperBound]
'													0 if funcaddrVariable or funcaddrArray[]
'						arg[]:				arg[0] = return kind, type, # args
'													arg[n] = argument kind and type
'						dataPtr			= tokenPtr at funcaddrVariable or funcaddrArray

FUNCTION  GetFuncaddrInfo (token, eleElements, arg[], dataPtr)
	SHARED  inTYPE,  tokenPtr,  tabArg[],  r_addr$[],  tab_sym$[]
	SHARED  T_ANY,  T_COMMA,  T_LBRAK,  T_RBRAK,  T_LPAREN,  T_RPAREN
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	SHARED  XERROR,  ERROR_COMPILER,  ERROR_COMPONENT
	SHARED  ERROR_DUP_DECLARATION,  ERROR_KIND_MISMATCH
	SHARED  ERROR_OVERFLOW,  ERROR_SYNTAX,  ERROR_TOO_MANY_ARGS

	DIM arg[19]
	argNumber		= 0
	eleElements	= 0

	SELECT CASE token
		CASE T_FUNCTION		: callKind = $$XFUNC
		CASE T_CFUNCTION	: callKind = $$CFUNC
		CASE T_SFUNCTION	: callKind = $$XFUNC
	END SELECT
	IF callKind THEN token = NextToken ()

	rtype				= TypenameToken (@token)
	IFZ rtype THEN rtype = $$XLONG
	arg[0]			= $$T_VARIABLES OR rtype OR (callKind << 29)
	kind				= token {$$KIND}
	dataPtr			= tokenPtr
	check				= NextToken ()

	IF inTYPE THEN
		SELECT CASE kind
			CASE $$KIND_SYMBOLS
						IF (check != T_LPAREN) THEN GOTO eeeSyntax
			CASE $$KIND_ARRAY_SYMBOLS
						IF (check != T_LBRAK) THEN GOTO eeeCompiler
						check		= NextToken ()
						IF (check != T_RBRAK) THEN
							SELECT CASE check{$$KIND}
								CASE $$KIND_LITERALS:		arrayDim = XLONG (tab_sym$[check{$$NUMBER}])
								CASE $$KIND_SYSCONS:		arrayDim = XLONG (r_addr$[check{$$NUMBER}])
								CASE ELSE:							PRINT "gfi": GOTO eeeComponent
							END SELECT
							IF ((arrayDim < 0) OR (arrayDim > 16383)) THEN GOTO eeeOverflow
							eleElements = arrayDim + 1
							check	= NextToken ()
							IF (check != T_RBRAK) THEN GOTO eeeSyntax
						ENDIF
						check	= NextToken ()
						IF (check != T_LPAREN) THEN GOTO eeeSyntax
			CASE ELSE
						GOTO eeeKindMismatch
		END SELECT
	ELSE
		SELECT CASE kind
			CASE $$KIND_VARIABLES
			CASE $$KIND_ARRAYS
						IF (check != T_LBRAK) THEN GOTO eeeSyntax
						check		= NextToken ()
						IF (check != T_RBRAK) THEN GOTO eeeSyntax
						check		= NextToken ()
						IF (check != T_LPAREN) THEN GOTO eeeSyntax
			CASE ELSE:		GOTO eeeKindMismatch
		END SELECT
		IF tabArg[token{$$NUMBER}, ] THEN PRINT "dupdec1": GOTO eeeDupDeclaration
	ENDIF

	DO
		check = NextToken ()
		IF (check = T_RPAREN) THEN EXIT DO
		argType		= TypenameToken (@check)
		IFZ argType THEN
			IF (check != T_ANY) THEN GOTO eeeSyntax
			check = NextToken ()
			argType	= $$ANY
		ENDIF
		IF (check = T_LBRAK) THEN
			check		= NextToken ()
			IF (check != T_RBRAK) THEN GOTO eeeSyntax
			check		= NextToken ()
			arg			= $$T_ARRAYS + argType
		ELSE
			arg			= $$T_VARIABLES + argType
		ENDIF
		INC argNumber
		arg[argNumber]	= arg
		IF (argNumber > 16) THEN GOTO eeeTooManyArgs
	LOOP WHILE (check = T_COMMA)
	arg[0]	= arg[0] OR (argNumber << 16)
	IF (check != T_RPAREN) THEN GOTO eeeSyntax
	check		= NextToken ()
	kind		= check{$$KIND}
	SELECT CASE kind
		CASE $$KIND_STARTS, $$KIND_COMMENTS
		CASE ELSE:	GOTO eeeSyntax
	END SELECT
	RETURN ($$T_STARTS)



eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeDupDeclaration:
	XERROR = ERROR_DUP_DECLARATION
	EXIT FUNCTION

eeeKindMismatch:
	XERROR = ERROR_KIND_MISMATCH
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION

eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  GetSymbol$ ()  #####
' ###########################

FUNCTION  GetSymbol$ (info)
	SHARED  charPtr,  rawLength,  rawline$
	SHARED	T_POUND
	SHARED UBYTE  charsetSymbolInner[]

	char_start = charPtr										' 1st character of symbol in rawline$
	charV = rawline${charPtr}
	SELECT CASE charV
		CASE '$':		INC charPtr
								info	= $$LOCAL_CONSTANT						' $LocalConstant
								charV = rawline${charPtr}
								IF (charV = '$') THEN
									INC charPtr
									info	= $$GLOBAL_CONSTANT					' $$SharedConstant
									charV = rawline${charPtr}
								ENDIF
		CASE '#':		INC charPtr
								info	= $$SHARED_VARIABLE						' #SharedVariable
								charV = rawline${charPtr}
								IF (charV = '#') THEN
									info	= $$EXTERNAL_VARIABLE				' ##ExternalVariable
									INC charPtr
									charV = rawline${charPtr}
								ENDIF
								IFZ charsetSymbolInner[charV] THEN
									SELECT CASE info
										CASE $$SHARED_VARIABLE		: info = $$SOLO_POUND : RETURN
										CASE $$EXTERNAL_VARIABLE	: info = $$DUAL_POUND : RETURN
									END SELECT
								ENDIF
		CASE '.':		INC charPtr
								info	= $$COMPONENT									' .component
								charV = rawline${charPtr}
		CASE ELSE:	info	= $$NORMAL_SYMBOL							' normalSymbol
	END SELECT

	DO WHILE (charsetSymbolInner[charV])	' TRUE while A-Z, a-z, 0-9, "_"
		INC charPtr
		charV = rawline${charPtr}
	LOOP
	y$ = MID$(rawline$, char_start+1, charPtr- char_start)
	RETURN (y$)
END FUNCTION


' ##################################
' #####  GetTokenOrAddress ()  #####
' ##################################

' Returns input token if it is:
'					simple-type token except string (style = $$VAR_TOKEN)
'					composite-type token w/o components (style = $$VAR_TOKEN)
'					any-type null array (style = $$ARRAY_TOKEN)
'					string variable (style = $$ARRAY_TOKEN)
' Returns address of data if:
'					any array with excess comma subscript (style = $$ARRAY_NODE)
'					composite-type token with components (style = $$DATA_ADDR)
'					composite-type array with components (style = $$DATA_ADDR)
'					composite-type array without components (style = $$DATA_ADDR)


FUNCTION  GetTokenOrAddress (token, style, nextToken, theType, ntype, base, offset, length)
	SHARED	tokenPtr
	SHARED	typeSize[],  m_addr$[]
	SHARED	T_ADDR_OP,  T_LBRAK,  T_RBRAK
	SHARED	XERROR,  ERROR_COMPILER

	base			= 0
	style			= 0
	offset		= 0
	length		= 0
	holdPtr		= tokenPtr
	kind			= token{$$KIND}
	SELECT CASE kind
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
		CASE ELSE:	token = 0: nextToken = NextToken (): style = 0: RETURN ($$FALSE)
	END SELECT
	IFZ m_addr$[token{$$NUMBER}] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
	theType		= TheType (token)
	ntype			= theType
	SELECT CASE kind
		CASE $$KIND_VARIABLES:	GOTO variables
		CASE $$KIND_ARRAYS:			GOTO arrays
	END SELECT
	GOTO eeeCompiler


' *****  VARIABLES  *****  SIMPLE-TYPE, COMPOSITE-TYPE

variables:
	SELECT CASE TRUE
		CASE (theType < $$STRING)
					style		= $$VAR_TOKEN
		CASE (theType = $$STRING)
					style		= $$ARRAY_TOKEN
		CASE (theType >= $$SCOMPLEX)
					node		= 0
					IF LastElement (token, 0, @node) THEN
						style		= $$VAR_TOKEN
						length	= typeSize [theType]
					ELSE
						base		= token
						IF node THEN GOTO eeeCompiler
						command	= $$GETDATAADDR
						Composite (command, @theType, @base, @offset, @length)
						IF XERROR THEN EXIT FUNCTION
						style		= $$DATA_ADDR
						token		= 0
					ENDIF
		CASE ELSE
					GOTO eeeCompiler
	END SELECT
	nextToken = NextToken ()
	RETURN ($$TRUE)



' *****  ARRAYS  *****  NULL, SIMPLE-TYPE, COMPOSITE-TYPE

arrays:
	t1		= NextToken ()
	t2		= NextToken ()
	IF (t1 != T_LBRAK) THEN GOTO eeeCompiler
	IF (t2 = T_RBRAK) THEN
		style				= $$ARRAY_TOKEN
		nextToken		= NextToken ()
		RETURN ($$TRUE)
	ENDIF
	tokenPtr = holdPtr
	SELECT CASE TRUE
		CASE (theType < $$SCOMPLEX):	GOTO simpleArrays
		CASE ELSE:										GOTO compositeArrays
	END SELECT
	GOTO eeeCompiler


' *****  SIMPLE ARRAYS  *****

simpleArrays:
	IF theType == $$STRING THEN node = $$TRUE
	holdType	= theType
	newOp = T_ADDR_OP: newPrec = $$PREC_ADDR_OP
	ExpressArray (@newOp, @newPrec, @token, @theType, 0, @node, 0, 0)
	IF XERROR THEN EXIT FUNCTION
	IF token THEN GOTO eeeCompiler
	style				= $$DATA_ADDR
	IF node THEN
		style = $$ARRAY_NODE
	ELSE
		theType	= holdType
	ENDIF
	length			= typeSize[theType]
	nextToken		= NextToken ()
	base				= Top ()
	RETURN ($$TRUE)


' *****  COMPOSITE ARRAYS  *****

compositeArrays:
	last		=	LastElement (token, 0, @node)
	IF node THEN GOTO simpleArrays
	command	= $$GETDATAADDR
	style		= $$DATA_ADDR
	base		= token
	node		= 0
	Composite (command, @theType, @base, @offset, @length)
	IF XERROR THEN EXIT FUNCTION
	nextToken = NextToken ()
	RETURN ($$TRUE)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #########################
' #####  GetWords ()  #####
' #########################

FUNCTION  GetWords (src, gtype, w3, w2, w1, w0)
	SHARED	r_addr$[],  tab_sym[]
	SHARED	XERROR,  ERROR_OVERFLOW,  ERROR_TYPE_MISMATCH

	gg			= src{$$NUMBER}
	gtoken	= tab_sym[gg]
	x$			= r_addr$[gg]
	IFZ x$ THEN w3 = 0: w2 = 0: w1 = 0: w0 = 0: RETURN
	IF (gtype < $$SLONG) THEN gtype = $$SLONG


' *****  Check for "0x...", "0s...", "0d..." formats  *****

'	char		= x${0}
'	upperChar	= UBOUND(x$)
'	IF ((char = '0') AND (upperChar > 1)) THEN
'		char	= x${1}
'		SELECT CASE char
'			CASE 'x': 				x$ = RIGHT$ ("000000000000000" + MID$(x$, 3), 16)
'												w3 = XLONG ("0x" + MID$(x$,  1, 4))
'												w2 = XLONG ("0x" + MID$(x$,  5, 4))
'												w1 = XLONG ("0x" + MID$(x$,  9, 4))
'												w0 = XLONG ("0x" + MID$(x$, 13, 4))
'												IF (gtype = $$SINGLE) THEN GOTO eeeTypeMismatch
'												IF (gtype = $$DOUBLE) THEN GOTO eeeTypeMismatch
'												RETURN
'			CASE 's':					x$ = RIGHT$ ("0000000" + MID$(x$, 3), 8)
'												w3 = 0
'												w2 = 0
'												w1 = XLONG ("0x" + MID$(x$, 1, 4))
'												w0 = XLONG ("0x" + MID$(x$, 5, 4))
'												SELECT CASE gtype
'													CASE $$SINGLE, $$XLONG
'													CASE ELSE:								GOTO eeeTypeMismatch
'												END SELECT
'												RETURN
'			CASE 'd':					x$ = RIGHT$ ("0000000000000000" + MID$(x$, 3), 16)
'												w3 = XLONG ("0x" + MID$(x$,  1, 4))
'												w2 = XLONG ("0x" + MID$(x$,  5, 4))
'												w1 = XLONG ("0x" + MID$(x$,  9, 4))
'												w0 = XLONG ("0x" + MID$(x$, 13, 4))
'												SELECT CASE gtype
'													CASE $$DOUBLE, $$GIANT
'													CASE ELSE:								GOTO eeeTypeMismatch
'												END SELECT
'												RETURN
'		END SELECT
'	ENDIF


' *****  Normal numeric formats  *****

	SELECT CASE gtype
		CASE $$SLONG	: x#	= DOUBLE (x$)
										x&	= x#
										w3	= 0
										w2	= 0
										w1	= x&{16, 16}
										w0	= x&{16,  0}
		CASE $$ULONG	: x#	= DOUBLE (x$)
										IF (x# < $$MIN_ULONG) THEN GOTO eeeOverflow
										IF (x# > $$MAX_ULONG) THEN GOTO eeeOverflow
										x&&	= x#
										w3	= 0
										w2	= 0
										w1	= x&&{16, 16}
										w0	= x&&{16,  0}
		CASE $$XLONG	: x#	= DOUBLE (x$)
										IF (x# < $$MIN_SLONG) THEN GOTO eeeOverflow
										IF (x# > $$MAX_ULONG) THEN GOTO eeeOverflow
										IF (x# > $$MAX_SLONG) THEN x# = x# - $$MAX_ULONG - 1
										x&	= x#
										w3	= 0
										w2	= 0
										w1	= x&{16, 16}
										w0	= x&{16,  0}
		CASE $$GIANT	: x$$	= GIANT (x$)
										w3	= GHIGH(x$$){16, 16}
										w2	= GHIGH(x$$){16,  0}
										w1	= GLOW (x$$){16, 16}
										w0	= GLOW (x$$){16,  0}
		CASE $$SINGLE	: x#	= DOUBLE (x$)
										x!	= x#
										w3	= 0
										w2	= 0
										w1	= x!{16, 16}
										w0	= x!{16,  0}
		CASE $$DOUBLE
										x#	= DOUBLE (x$)
										w3	= DHIGH(x#){16, 16}
										w2	= DHIGH(x#){16,  0}
										w1	= DLOW (x#){16, 16}
										w0	= DLOW (x#){16,  0}
		CASE ELSE:			GOTO eeeTypeMismatch
	END SELECT
	RETURN

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  InitArrays ()  #####
' ###########################

' Dimension all SHARED arrays, clearing the contents to zero.
' Define the contents of "information", "default", "charset" arrays.

FUNCTION  InitArrays ()
	SHARED	ulabel,  upatch,  typePtr
	SHARED	labelPtr,  tab_sym_ptr,  uFunc,  uType,  xargNum
	STATIC	reEntry
	SHARED	reg86$[31]
	SHARED	reg86c$[31]

' *****  DATA TYPE ARRAYS  *****

	SHARED	typeSymbol$[63]
	SHARED	typeSuffix$[63]
	SHARED	typeName$[63]
	SHARED	typeSize$[63]
	SHARED	typeAlias[63]
	SHARED	typeAlign[63]
	SHARED	typeToken[63]
	SHARED	typeSize[63]
	SHARED	typeEleCount[63]
	SHARED	typeEleSymbol$[63,]
	SHARED	typeEleToken[63,]
	SHARED	typeEleAddr[63,]
	SHARED	typeEleSize[63,]
	SHARED	typeEleType[63,]
	SHARED	typeEleArg[63,]
	SHARED	typeEleVal[63,]
	SHARED	typeElePtr[63,]
	SHARED	typeEleStringSize[63,]
	SHARED	typeEleUBound[63,]

' *****  MISCELLANEOUS ARRAYS  *****

	SHARED UBYTE oos[255]
	SHARED	xerror$[63]
	SHARED	tokens[4095]
	SHARED	charpos[255]
	SHARED	stackData[31]
	SHARED	stackType[31]
	SHARED	r_addr[9999]
	SHARED	r_addr$[9999]
	SHARED	m_reg[9999]
	SHARED	m_addr[9999]
	SHARED	m_addr$[9999]
	SHARED	tab_sym$[9999]
	SHARED	tabType[9999]
	SHARED	tab_sym[9999]
	SHARED	tabArg[9999, ]
	SHARED	labhash[255, 63]
	SHARED	labaddr[16383]
	SHARED	tab_lab[16383]
	SHARED	tab_lab$[16383]
	SHARED	xargAddr[15]
	SHARED	xargName$[15]

	SHARED	hash%[63, ]
	SHARED	funcToken[63]
	SHARED	funcSymbol$[63]
	SHARED	funcLabel$[63]
	SHARED	funcFrameSize[63]
	SHARED	funcScope[63]
	SHARED	funcKind[63]
	SHARED	funcType[63]
	SHARED	funcArgSize[63]
	SHARED	funcArg[63, ]
	SHARED	autoAddr[63]
	SHARED	autoxAddr[63]
	SHARED	inargAddr[63]
	SHARED	defaultType[63]
	SHARED	compositeNumber[63]
	SHARED	compositeStart[63, ]
	SHARED	compositeToken[63, ]
	SHARED	compositeNext[63, ]

	SHARED	patchType[8191]
	SHARED	patchAddr[8191]
	SHARED	patchDest[8191]
	SHARED	nestVar[63]
	SHARED	nestInfo[63]
	SHARED	nestStep[63]
	SHARED	nestLimit[63]
	SHARED	nestCount[63]
	SHARED	nestToken[63]
	SHARED	nestLevel[63]
	SHARED	subToken[255]
	SHARED USHORT hx[255]

	SHARED UBYTE shiftMulti[]
	SHARED UBYTE charsetSymbolInner[]
	SHARED UBYTE charsetSymbol[]
	SHARED UBYTE charsetUpper[]
	SHARED UBYTE charsetLower[]
	SHARED UBYTE charsetNumeric[]
	SHARED UBYTE charsetUpperLower[]
	SHARED UBYTE charsetUpperNumeric[]
	SHARED UBYTE charsetLowerNumeric[]
	SHARED UBYTE charsetUpperLowerNumeric[]
	SHARED UBYTE charsetUpperToLower[]
	SHARED UBYTE charsetLowerToUpper[]
	SHARED UBYTE charsetVex[]
	SHARED UBYTE charsetHexUpper[]
	SHARED UBYTE charsetHexLower[]
	SHARED UBYTE charsetHexUpperLower[]
	SHARED UBYTE charsetHexUpperToLower[]
	SHARED UBYTE charsetHexLowerToUpper[]
	SHARED UBYTE charsetBackslash[]
	SHARED UBYTE charsetNormalChar[]
	SHARED UBYTE charsetSpaceTab[]
	SHARED UBYTE charsetSuffix[]

	SHARED	alphaFirst[]
	SHARED	alphaLast[]
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED  libraryExt$[]		'newimport
	SHARED	tab_sys$[]
	SHARED	tab_sys[]
	SHARED	minval#[]
	SHARED	maxval#[]
	SHARED	blanks[]
	SHARED	cop[]

	SHARED	q_type_long[]
	SHARED	q_type_long_or_addr[]
	SHARED	typeHigher[]
	SHARED SSHORT typeConvert[]
	EXTERNAL ##ERROR

' ***************************************************
' *****  SET UP DATA TYPE ARRAYS AND VARIABLES  *****
' ***************************************************
' *****  Variables needed for Data Type Arrays  *****
' ***************************************************

	typePtr			= 34			' slot after DCOMPLEX
	uFunc				= 63			' room for 64 functions to start
	uType				= 63			' room for 64 types to start
	upatch			= 8191		' upper bound of patch arrays
	ulabel			= 16383		' upper bound of label arrays
	xargNum			= 0
	labelPtr		= 0
	tab_sym_ptr	= 0

	DIM libraryCode$[]		' waste the previous libraries
	DIM libraryName$[]
	DIM libraryHandle[]
	DIM libraryExt$[]     'newimport

	DIM temp%[255, ]
	ATTACH temp%[] TO hash%[0, ]


' ******************
' *****  hx[]  *****  (For better hash distribution)
' ******************

	hx[  0] = 0xF3C9:	hx[ 64] = 0x811D:	hx[128] = 0x199C:	hx[192] = 0xD0C8
	hx[  1] = 0xE034:	hx[ 65] = 0xC6E3:	hx[129] = 0x1299:	hx[193] = 0x3C07
	hx[  2] = 0xB37C:	hx[ 66] = 0xCA5D:	hx[130] = 0xA314:	hx[194] = 0xDDCA
	hx[  3] = 0x4E31:	hx[ 67] = 0x5AF2:	hx[131] = 0xEF45:	hx[195] = 0xB2C1
	hx[  4] = 0xC0DE:	hx[ 68] = 0xB2F3:	hx[132] = 0xEFC3:	hx[196] = 0x6A7C
	hx[  5] = 0x2487:	hx[ 69] = 0xCF28:	hx[133] = 0x8A2D:	hx[197] = 0x5E02
	hx[  6] = 0x98E2:	hx[ 70] = 0x4714:	hx[134] = 0x2553:	hx[198] = 0x4C8B
	hx[  7] = 0x557C:	hx[ 71] = 0x32B0:	hx[135] = 0x8CA6:	hx[199] = 0x6652
	hx[  8] = 0xA6CB:	hx[ 72] = 0x9A76:	hx[136] = 0x60B8:	hx[200] = 0x3C50
	hx[  9] = 0x410D:	hx[ 73] = 0xB2A4:	hx[137] = 0x2192:	hx[201] = 0x02B8
	hx[ 10] = 0x7767:	hx[ 74] = 0xDE9B:	hx[138] = 0xA15C:	hx[202] = 0x7B70
	hx[ 11] = 0x3861:	hx[ 75] = 0xE0E1:	hx[139] = 0xA527:	hx[203] = 0x118F
	hx[ 12] = 0x5517:	hx[ 76] = 0xA7C3:	hx[140] = 0x1FAC:	hx[204] = 0xEF65
	hx[ 13] = 0x0918:	hx[ 77] = 0x0E48:	hx[141] = 0xC554:	hx[205] = 0x3D6E
	hx[ 14] = 0xF3AF:	hx[ 78] = 0xFABE:	hx[142] = 0x5ECB:	hx[206] = 0xCAB2
	hx[ 15] = 0x2EAB:	hx[ 79] = 0xE351:	hx[143] = 0x7941:	hx[207] = 0x23F0
	hx[ 16] = 0x210D:	hx[ 80] = 0x4419:	hx[144] = 0x3EA2:	hx[208] = 0x927F
	hx[ 17] = 0xDF19:	hx[ 81] = 0x5AB4:	hx[145] = 0xE73D:	hx[209] = 0x1F12
	hx[ 18] = 0x2F0B:	hx[ 82] = 0xDDF9:	hx[146] = 0xDE62:	hx[210] = 0xEDCE
	hx[ 19] = 0x269A:	hx[ 83] = 0x513E:	hx[147] = 0x9FFA:	hx[211] = 0x0D52
	hx[ 20] = 0xE171:	hx[ 84] = 0x1BDF:	hx[148] = 0x0CE8:	hx[212] = 0x69B5
	hx[ 21] = 0x8D07:	hx[ 85] = 0xA0BC:	hx[149] = 0x8683:	hx[213] = 0x9DC4
	hx[ 22] = 0x0AF1:	hx[ 86] = 0xC2E5:	hx[150] = 0x481C:	hx[214] = 0x910F
	hx[ 23] = 0x4627:	hx[ 87] = 0x5917:	hx[151] = 0x80E4:	hx[215] = 0xEE6D
	hx[ 24] = 0x7C4B:	hx[ 88] = 0x0448:	hx[152] = 0xC43E:	hx[216] = 0xA0E7
	hx[ 25] = 0xA59A:	hx[ 89] = 0xE110:	hx[153] = 0x7830:	hx[217] = 0xF2ED
	hx[ 26] = 0x561F:	hx[ 90] = 0xA4C8:	hx[154] = 0x3952:	hx[218] = 0x6EA2
	hx[ 27] = 0x1F90:	hx[ 91] = 0x5BC6:	hx[155] = 0x2BBA:	hx[219] = 0xFEFC
	hx[ 28] = 0x9407:	hx[ 92] = 0x1250:	hx[156] = 0x476D:	hx[220] = 0x0A20
	hx[ 29] = 0xAAAA:	hx[ 93] = 0x3D09:	hx[157] = 0xF307:	hx[221] = 0xA568
	hx[ 30] = 0x404B:	hx[ 94] = 0xD230:	hx[158] = 0x5A6A:	hx[222] = 0xB90E
	hx[ 31] = 0xCCB2:	hx[ 95] = 0x19F1:	hx[159] = 0x232A:	hx[223] = 0xFA26
	hx[ 32] = 0xB6B8:	hx[ 96] = 0x28D0:	hx[160] = 0x36DA:	hx[224] = 0xFB8E
	hx[ 33] = 0x93E5:	hx[ 97] = 0x0FD7:	hx[161] = 0x1448:	hx[225] = 0x3091
	hx[ 34] = 0xCD83:	hx[ 98] = 0x79BD:	hx[162] = 0x016A:	hx[226] = 0x56A1
	hx[ 35] = 0x8392:	hx[ 99] = 0xE856:	hx[163] = 0xF0CC:	hx[227] = 0x184A
	hx[ 36] = 0x951B:	hx[100] = 0xDDDE:	hx[164] = 0x5328:	hx[228] = 0xDEC0
	hx[ 37] = 0x983F:	hx[101] = 0xBD28:	hx[165] = 0x8B83:	hx[229] = 0xC39F
	hx[ 38] = 0x1BB3:	hx[102] = 0xD9F7:	hx[166] = 0x1566:	hx[230] = 0xBED3
	hx[ 39] = 0x40A7:	hx[103] = 0xCBB9:	hx[167] = 0xB0D3:	hx[231] = 0x51F5
	hx[ 40] = 0x5D7E:	hx[104] = 0x9B85:	hx[168] = 0xCE2F:	hx[232] = 0xC0E9
	hx[ 41] = 0x65A1:	hx[105] = 0x82DC:	hx[169] = 0x30FA:	hx[233] = 0x617B
	hx[ 42] = 0x8576:	hx[106] = 0x67B0:	hx[170] = 0x49C6:	hx[234] = 0xF6E9
	hx[ 43] = 0xAC39:	hx[107] = 0x8720:	hx[171] = 0x94D9:	hx[235] = 0x9775
	hx[ 44] = 0xFE04:	hx[108] = 0x0CDF:	hx[172] = 0xE69B:	hx[236] = 0xD5A5
	hx[ 45] = 0x6C6F:	hx[109] = 0xA884:	hx[173] = 0x7B2C:	hx[237] = 0xF7D3
	hx[ 46] = 0x838F:	hx[110] = 0x238D:	hx[174] = 0x340B:	hx[238] = 0x2BD5
	hx[ 47] = 0xDA44:	hx[111] = 0xACED:	hx[175] = 0x2E46:	hx[239] = 0xBB3D
	hx[ 48] = 0x7B93:	hx[112] = 0x773B:	hx[176] = 0xFD83:	hx[240] = 0x1483
	hx[ 49] = 0x851E:	hx[113] = 0x84F1:	hx[177] = 0xB1A9:	hx[241] = 0x5906
	hx[ 50] = 0xD23F:	hx[114] = 0xB1A6:	hx[178] = 0x6F78:	hx[242] = 0x6D25
	hx[ 51] = 0x1F47:	hx[115] = 0x049F:	hx[179] = 0xF3FE:	hx[243] = 0x0BEE
	hx[ 52] = 0x7C74:	hx[116] = 0x8B30:	hx[180] = 0x387B:	hx[244] = 0xE76B
	hx[ 53] = 0xBF9D:	hx[117] = 0xB545:	hx[181] = 0xCCC2:	hx[245] = 0x6751
	hx[ 54] = 0x7646:	hx[118] = 0x48EC:	hx[182] = 0x762C:	hx[246] = 0x2A06
	hx[ 55] = 0xC9FF:	hx[119] = 0xF885:	hx[183] = 0x603E:	hx[247] = 0x49E3
	hx[ 56] = 0x7944:	hx[120] = 0x3985:	hx[184] = 0x02F9:	hx[248] = 0x9854
	hx[ 57] = 0x953D:	hx[121] = 0x3D6A:	hx[185] = 0x3F51:	hx[249] = 0x11F4
	hx[ 58] = 0xE666:	hx[122] = 0x6871:	hx[186] = 0x6C2E:	hx[250] = 0xA655
	hx[ 59] = 0xB2DA:	hx[123] = 0x2F08:	hx[187] = 0x0777:	hx[251] = 0x742F
	hx[ 60] = 0x743C:	hx[124] = 0x94DE:	hx[188] = 0xE456:	hx[252] = 0x8C19
	hx[ 61] = 0xDB99:	hx[125] = 0x4CA5:	hx[189] = 0x7AA0:	hx[253] = 0xB74A
	hx[ 62] = 0x48BB:	hx[126] = 0xD5EA:	hx[190] = 0x0766:	hx[254] = 0xD219
	hx[ 63] = 0xF794:	hx[127] = 0xAD4C:	hx[191] = 0x4882:	hx[255] = 0x63DD


' ***************************
' *****  typeSymbol$[]  *****
' ***************************

	typeSymbol$[$$ZERO]			= "NONE"
	typeSymbol$[$$VOID]			= "VOID"
	typeSymbol$[$$SBYTE]		= "SBYTE"
	typeSymbol$[$$UBYTE]		= "UBYTE"
	typeSymbol$[$$SSHORT]		= "SSHORT"
	typeSymbol$[$$USHORT]		= "USHORT"
	typeSymbol$[$$SLONG]		= "SLONG"
	typeSymbol$[$$ULONG]		= "ULONG"
	typeSymbol$[$$XLONG]		= "XLONG"
	typeSymbol$[$$GOADDR]		= "GOADDR"
	typeSymbol$[$$SUBADDR]	= "SUBADDR"
	typeSymbol$[$$FUNCADDR]	= "FUNCADDR"
	typeSymbol$[$$GIANT]		= "GIANT"
	typeSymbol$[$$SINGLE]		= "SINGLE"
	typeSymbol$[$$DOUBLE]		= "DOUBLE"
	typeSymbol$[$$ANY]			= "ANY"
	typeSymbol$[$$ETC]			= "ETC"
	typeSymbol$[$$STRING]		= "STRING"
  typeSymbol$[$$LONGDOUBLE] = "LONGDOUBLE"
	typeSymbol$[$$SCOMPLEX]	= "SCOMPLEX"
	typeSymbol$[$$DCOMPLEX]	= "DCOMPLEX"


' ***************************
' *****  typeSuffix$[]  *****
' ***************************

	typeSuffix$[$$ZERO]			= ""
	typeSuffix$[$$VOID]			= ""
	typeSuffix$[$$SBYTE]		= "@"
	typeSuffix$[$$UBYTE]		= "@@"
	typeSuffix$[$$SSHORT]		= "%"
	typeSuffix$[$$USHORT]		= "%%"
	typeSuffix$[$$SLONG]		= "&"
	typeSuffix$[$$ULONG]		= "&&"
	typeSuffix$[$$XLONG]		= "~"
	typeSuffix$[$$GIANT]		= "$$"
	typeSuffix$[$$SINGLE]		= "!"
	typeSuffix$[$$DOUBLE]		= "#"
	typeSuffix$[$$ANY]			= "[]"
	typeSuffix$[$$ETC]			= "..."
	typeSuffix$[$$STRING]		= "$"
	typeSuffix$[$$LONGDOUBLE] = "##"


' *************************
' *****  typeToken[]  *****
' *************************

	typeToken[$$SBYTE]			= $$T_TYPES	+ $$SBYTE
	typeToken[$$UBYTE]			= $$T_TYPES	+ $$UBYTE
	typeToken[$$SSHORT]			= $$T_TYPES	+ $$SSHORT
	typeToken[$$USHORT]			= $$T_TYPES	+ $$USHORT
	typeToken[$$SLONG]			= $$T_TYPES	+ $$SLONG
	typeToken[$$ULONG]			= $$T_TYPES	+ $$ULONG
	typeToken[$$XLONG]			= $$T_TYPES	+ $$XLONG
	typeToken[$$GOADDR]			= $$T_TYPES	+ $$GOADDR
	typeToken[$$SUBADDR]		= $$T_TYPES	+ $$SUBADDR
	typeToken[$$FUNCADDR]		= $$T_TYPES	+ $$FUNCADDR
	typeToken[$$GIANT]			= $$T_TYPES	+ $$GIANT
	typeToken[$$SINGLE]			= $$T_TYPES	+ $$SINGLE
	typeToken[$$DOUBLE]			= $$T_TYPES	+ $$DOUBLE
	typeToken[$$ANY]				= $$T_TYPES	+ $$ZERO
	typeToken[$$STRING]			= $$T_TYPES	+ $$STRING
  typeToken[$$LONGDOUBLE] = $$T_TYPES + $$LONGDOUBLE
	typeToken[$$SCOMPLEX]		= $$T_TYPES + $$SCOMPLEX
	typeToken[$$DCOMPLEX]		= $$T_TYPES + $$DCOMPLEX


' *************************
' *****  typeName$[]  *****
' *************************

	typeName$[$$ZERO]				= "none"
	typeName$[$$VOID]				= "void"
	typeName$[$$SBYTE]			= "sbyte"
	typeName$[$$UBYTE]			= "ubyte"
	typeName$[$$SSHORT]			= "sshort"
	typeName$[$$USHORT]			= "ushort"
	typeName$[$$SLONG]			= "slong"
	typeName$[$$ULONG]			= "ulong"
	typeName$[$$XLONG]			= "xlong"
	typeName$[$$GOADDR]			= "goaddr"
	typeName$[$$SUBADDR]		= "subaddr"
	typeName$[$$FUNCADDR]		= "funcaddr"
	typeName$[$$GIANT]			= "giant"
	typeName$[$$SINGLE]			= "single"
	typeName$[$$DOUBLE]			= "double"
	typeName$[$$ANY]				= "any"
	typeName$[$$ETC]				= "etc"
	typeName$[$$STRING]			= "string"
  typeName$[$$LONGDOUBLE] = "longdouble"
	typeName$[$$SCOMPLEX]		= "singleComplex"
	typeName$[$$DCOMPLEX]		= "doubleComplex"


' **************************************
' *****  typeSize[],  typeSize$[]  *****
' **************************************

	FOR i = 0 TO 63
		SELECT CASE i
			CASE $$SBYTE:			typeSize[i] =  1:		typeSize$[i] =  "1"
			CASE $$UBYTE:			typeSize[i] =  1:		typeSize$[i] =  "1"
			CASE $$SSHORT:		typeSize[i] =  2:		typeSize$[i] =  "2"
			CASE $$USHORT:		typeSize[i] =  2:		typeSize$[i] =  "2"
			CASE $$GIANT:			typeSize[i] =  8:		typeSize$[i] =  "8"
			CASE $$DOUBLE:		typeSize[i] =  8:		typeSize$[i] =  "8"
      CASE $$LONGDOUBLE:typeSize[i] = 12:   typeSize$[i] = "12"
			CASE $$SCOMPLEX:	typeSize[i] =  8:		typeSize$[i] =  "8"
			CASE $$DCOMPLEX:	typeSize[i] = 16:		typeSize$[i] = "16"
			CASE ELSE:				typeSize[i] =  4:		typeSize$[i] =  "4"
		END SELECT
	NEXT


' ****************************************
' *****  typeAlias[],  typeAlign[]  ******
' ****************************************

	FOR i = 0 TO 63
		SELECT CASE i
			CASE $$SBYTE:			typeAlias[i] = i:		typeAlign[i] = 1
			CASE $$UBYTE:			typeAlias[i] = i:		typeAlign[i] = 1
			CASE $$SSHORT:		typeAlias[i] = i:		typeAlign[i] = 2
			CASE $$USHORT:		typeAlias[i] = i:		typeAlign[i] = 2
			CASE $$SLONG:			typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$ULONG:			typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$XLONG:			typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$GOADDR:		typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$SUBADDR:		typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$FUNCADDR:	typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$GIANT:			typeAlias[i] = i:		typeAlign[i] = 8
			CASE $$SINGLE:		typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$DOUBLE:		typeAlias[i] = i:		typeAlign[i] = 8
			CASE $$LONGDOUBLE: typeAlias[i] = i:	typeAlign[i] = 4
			CASE $$STRING:		typeAlias[i] = i:		typeAlign[i] = 4
      CASE $$STRING:		typeAlias[i] = i:		typeAlign[i] = 8
			CASE $$SCOMPLEX:	typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$DCOMPLEX:	typeAlias[i] = i:		typeAlign[i] = 8
			CASE ELSE:				typeAlias[i] = 0:		typeAlign[i] = 0
		END SELECT
	NEXT

	reg86$[ 1] = "esp"
	reg86$[ 2] = "al"
	reg86$[ 3] = "dl"
	reg86$[ 4] = "bl"
	reg86$[ 5] = "cl"
	reg86$[ 6] = "ax"
	reg86$[ 7] = "dx"
	reg86$[ 8] = "bx"
	reg86$[ 9] = "cx"
	reg86$[10] = "eax"
	reg86$[11] = "edx"		' danger: register overload
	reg86$[12] = "ebx"
	reg86$[13] = "ecx"		' danger: register overload
	reg86$[26] = "esi"
	reg86$[27] = "edi"
	reg86$[28] = "ecx"		' danger: register overload
	reg86$[29] = "edx"		' danger: register overload
	reg86$[31] = "ebp"

	reg86c$[ 1]	= "esp,"
	reg86c$[ 2] = "al,"
	reg86c$[ 3] = "dl,"
	reg86c$[ 4] = "bl,"
	reg86c$[ 5] = "cl,"
	reg86c$[ 6] = "ax,"
	reg86c$[ 7] = "dx,"
	reg86c$[ 8] = "bx,"
	reg86c$[ 9] = "cx,"
	reg86c$[10] = "eax,"
	reg86c$[11] = "edx,"		' danger: register overload
	reg86c$[12] = "ebx,"
	reg86c$[13] = "ecx,"		' danger: register overload
	reg86c$[26] = "esi,"
	reg86c$[27] = "edi,"
	reg86c$[28] = "ecx,"		' danger: register overload
	reg86c$[29] = "edx,"		' danger: register overload
	reg86c$[31] = "ebp,"


' *****************************************************
' *****  DEFINE REGISTER ORIENTED ARRAY CONTENTS  *****
' *****************************************************

	r = 0
	DO WHILE (r < 32)
		r_addr[r]  = r												' r.addr[r]  = r
		INC r
	LOOP
	r_addr$[ 1] = "esp"
	r_addr$[ 2] = "al"
	r_addr$[ 3] = "dl"
	r_addr$[ 4] = "bl"
	r_addr$[ 5] = "cl"
	r_addr$[ 6] = "ax"
	r_addr$[ 7] = "dx"
	r_addr$[ 8] = "bx"
	r_addr$[ 9] = "cx"
	r_addr$[10] = "eax"
	r_addr$[11] = "edx"
	r_addr$[12] = "ebx"
	r_addr$[13] = "ecx"
	r_addr$[26] = "esi"
	r_addr$[27] = "edi"
	r_addr$[28] = "edx"
	r_addr$[29] = "ecx"


'  **************************************************************************
'  *****  DONE INITIALIZING ARRAYS THAT NEED INITIALIZATION EVERY TIME  *****
'  **************************************************************************

	IF reEntry THEN RETURN
	reEntry			= $$TRUE

' **************************************************************************
' *****  THE FOLLOWING ARRAYS NEED ONLY BE DIMENSIONED / DEFINED ONCE  *****
' **************************************************************************

	DIM shiftMulti[1040]
	DIM	charsetSymbolInner[255]
	DIM charsetSymbol[255]
	DIM	charsetUpper[255]
	DIM	charsetLower[255]
	DIM	charsetNumeric[255]
	DIM	charsetUpperLower[255]
	DIM	charsetUpperNumeric[255]
	DIM	charsetLowerNumeric[255]
	DIM	charsetUpperLowerNumeric[255]
	DIM	charsetUpperToLower[255]
	DIM	charsetLowerToUpper[255]
	DIM	charsetVex[255]
	DIM	charsetHexUpper[255]
	DIM	charsetHexLower[255]
	DIM	charsetHexUpperLower[255]
	DIM	charsetHexUpperToLower[255]
	DIM	charsetHexLowerToUpper[255]
	DIM	charsetBackslash[255]
	DIM	charsetNormalChar[255]
	DIM charsetSpaceTab[255]
	DIM charsetSuffix[255]
	DIM	alphaFirst[31]
	DIM	alphaLast[31]
	DIM	tab_sys$[255]
	DIM	tab_sys[255]
	DIM	minval#[63]
	DIM	maxval#[63]
	DIM	blanks[7]
	DIM	cop[11, 15, 15]
	DIM	q_type_long[63]
	DIM	q_type_long_or_addr[63]
	DIM	typeConvert[31, 31]
	DIM	typeHigher[31, 31]


' *************************************
' *****  DEFINE "charset" ARRAYS  *****
' *************************************

' **********************************
' *****  charsetSymbolInner[]  *****  A-Z  a-z  0-9  "_"  (others 0)
' **********************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetSymbolInner[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetSymbolInner[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetSymbolInner[i] = i
			CASE  (i  = '_'):										charsetSymbolInner[i] = i
			CASE ELSE:													charsetSymbolInner[i] = 0
		END SELECT
	NEXT i


' *****************************
' *****  charsetSymbol[]  *****  A-Z  a-z  0-9  "_"  (others 0)
' *****************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetSymbol[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetSymbol[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetSymbol[i] = i
			CASE  (i  = '_'):										charsetSymbol[i] = i
			CASE ELSE:													charsetSymbol[i] = 0
		END SELECT
	NEXT i


' ****************************
' *****  charsetUpper[]  *****  A-Z  (others 0)
' ****************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpper[i] = i
			CASE ELSE:													charsetUpper[i] = 0
		END SELECT
	NEXT i


' ****************************
' *****  charsetLower[]  *****  a-z  (others 0)
' ****************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'a') AND (i <= 'z')):   charsetLower[i] = i
			CASE ELSE:													charsetLower[i] = 0
		END SELECT
	NEXT i


' ******************************
' *****  charsetNumeric[]  *****  0-9  (others 0)
' ******************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetNumeric[i] = i
			CASE ELSE:													charsetNumeric[i] = 0
		END SELECT
	NEXT i


' *********************************
' *****  charsetUpperLower[]  *****  A-Z  a-z  (others 0)
' *********************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperLower[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):   charsetUpperLower[i] = i
			CASE ELSE:													charsetUpperLower[i] = 0
		END SELECT
	NEXT i


' ***********************************
' *****  charsetUpperNumeric[]  *****  A-Z  0-9  (others 0)
' ***********************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetUpperNumeric[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperNumeric[i] = i
			CASE ELSE:													charsetUpperNumeric[i] = 0
		END SELECT
	NEXT i


' ***********************************
' *****  charsetLowerNumeric[]  *****  a-z  0-9  (others 0)
' ***********************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetLowerNumeric[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetLowerNumeric[i] = i
			CASE ELSE:													charsetLowerNumeric[i] = 0
		END SELECT
	NEXT i


' ****************************************
' *****  charsetUpperLowerNumeric[]  *****  A-Z  a-z  0-9  (others 0)
' ****************************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetUpperLowerNumeric[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperLowerNumeric[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetUpperLowerNumeric[i] = i
			CASE ELSE:													charsetUpperLowerNumeric[i] = 0
		END SELECT
	NEXT i


' ***********************************
' *****  charsetUpperToLower[]  *****  A-Z  ==>>  a-z  (others unchanged)
' ***********************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperToLower[i] = i + 32
			CASE ELSE:													charsetUpperToLower[i] = i
		END SELECT
	NEXT i


' ***********************************
' *****  charsetLowerToUpper[]  *****  a-z  ==>>  A-Z  (others unchanged)
' ***********************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'a') AND (i <= 'z')):		charsetLowerToUpper[i] = i - 32
			CASE ELSE:													charsetLowerToUpper[i] = i
		END SELECT
	NEXT i


' **************************
' *****  charsetVex[]  *****  0-9  A-V  (others 0)
' **************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetVex[i] = i
			CASE ((i >= 'A') AND (i <= 'V')):   charsetVex[i] = i
			CASE ELSE:													charsetVex[i] = 0
		END SELECT
	NEXT i


' *******************************
' *****  charsetHexUpper[]  *****  0-9  A-F  (others 0)
' *******************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexUpper[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexUpper[i] = i
			CASE ELSE:													charsetHexUpper[i] = 0
		END SELECT
	NEXT i


' *******************************
' *****  charsetHexLower[]  *****  0-9  a-f  (others 0)
' *******************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexLower[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):   charsetHexLower[i] = i
			CASE ELSE:													charsetHexLower[i] = 0
		END SELECT
	NEXT i


' ************************************
' *****  charsetHexUpperLower[]  *****  0-9  A-F  a-f  (others 0)
' ************************************

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexUpperLower[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexUpperLower[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexUpperLower[i] = i
			CASE ELSE:													charsetHexUpperLower[i] = 0
		END SELECT
	NEXT i


' **************************************  0-9
' *****  charsetHexUpperToLower[]  *****  A-F  ==>>  a-f  (others 0)
' **************************************  a-f

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexUpperToLower[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexUpperToLower[i] = i + 32
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexUpperToLower[i] = i
			CASE ELSE:													charsetHexUpperToLower[i] = 0
		END SELECT
	NEXT i


' **************************************  0-9
' *****  charsetHexLowerToUpper[]  *****  a-f  ==>>  A-F  (others 0)
' **************************************  A-F

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexLowerToUpper[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexLowerToUpper[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexLowerToUpper[i] = i - 32
			CASE ELSE:													charsetHexLowerToUpper[i] = 0
		END SELECT
	NEXT i


' ********************************  \a  \b  \d  \f  \n  \r  \v  \\  \"  \z
' *****  charsetBackslash[]  *****  \0 - \V
' ********************************  (others unchanged)

' Convert character following a \ into the proper binary value
' For all characters without special binary values, return the character

	offset = 10 - 'A'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetBackslash[i] = i - '0'
			CASE ((i >= 'A') AND (i <= 'V')):		charsetBackslash[i] = i + offset
			CASE ELSE:													charsetBackslash[i] = i
		END SELECT
	NEXT i

	FOR i = 0 TO 255
		SELECT CASE i
			CASE '\\':	charsetBackslash[i] = 0x5C		' backslash
			CASE '"':		charsetBackslash[i] = 0x22		' double-quote
			CASE 'a':		charsetBackslash[i] = 0x07		' alarm (bell)
			CASE 'b':		charsetBackslash[i] = 0x08		' backspace
			CASE 'd':		charsetBackslash[i] = 0x7F		' delete
			CASE 'e':		charsetBackslash[i] = 0x1B		' escape
			CASE 'f':		charsetBackslash[i] = 0x0C		' form-feed
			CASE 'n':		charsetBackslash[i] = 0x0A		' newline
			CASE 'r':		charsetBackslash[i] = 0x0D		' return
			CASE 't':		charsetBackslash[i] = 0x09		' tab
			CASE 'v':		charsetBackslash[i] = 0x0B		' vertical-tab
			CASE 'z':		charsetBackslash[i] = 0xFF		' finale  (highest UBYTE)
		END SELECT
	NEXT i


' *********************************  0x00 - 0x1F  ===>>  0
' *****  charsetNormalChar[]  *****  0x7F - 0xFF  ===>>  0  (others unchanged)
' *********************************   \  and  "   ===>>  0

' Normal printable characters = the character, all others = 0
' NOTE:  tab, newline, etc... not considered normal printable characters
' NOTE:  backslash not considered normal printable character (need \\)
' NOTE:  double-quote not considered normal printable character (need \")

	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE (i <=  31):	charsetNormalChar[i] = 0
			CASE (i >= 127):	charsetNormalChar[i] = 0
			CASE (i = '\\'):	charsetNormalChar[i] = 0
			CASE (i = '"'):		charsetNormalChar[i] = 0
			CASE ELSE:				charsetNormalChar[i] = i
		END SELECT
	NEXT i


' *******************************
' *****  charsetSpaceTab[]  *****  only <space> and <tab> are true
' *******************************

	charsetSpaceTab[0x09]	= 0x09		' <tab>		= '\t
	charsetSpaceTab[0x20]	= 0x20		' <space>	= '


' *****************************
' *****  charsetSuffix[]  *****  valid type suffixes
' *****************************

	charsetSuffix['@']	= '@'
	charsetSuffix['%']	= '%'
	charsetSuffix['&']	= '&'
	charsetSuffix['~']	= '~'
	charsetSuffix['!']	= '!'
	charsetSuffix['#']	= '#'
	charsetSuffix['$']	= '$'


' ********************************************************
' *****  Define the contents of several more arrays  *****
' ********************************************************

	minval#[$$SBYTE]		= $$MIN_SBYTE
	minval#[$$UBYTE]		= $$MIN_UBYTE
	minval#[$$SSHORT]		= $$MIN_SSHORT
	minval#[$$USHORT]		= $$MIN_USHORT
	minval#[$$SLONG]		= $$MIN_SLONG
	minval#[$$ULONG]		= $$MIN_ULONG
	minval#[$$XLONG]		= $$MIN_XLONG
	minval#[$$GOADDR]		= $$MIN_XLONG
	minval#[$$SUBADDR]	= $$MIN_XLONG
	minval#[$$FUNCADDR]	= $$MIN_XLONG
	minval#[$$SINGLE]		= $$MIN_SINGLE
	minval#[$$DOUBLE]		= $$MIN_DOUBLE
	minval#[$$GIANT]		= $$MIN_GIANT

	maxval#[$$SBYTE]		= $$MAX_SBYTE
	maxval#[$$UBYTE]		= $$MAX_UBYTE
	maxval#[$$SSHORT]		= $$MAX_SSHORT
	maxval#[$$USHORT]		= $$MAX_USHORT
	maxval#[$$SLONG]		= $$MAX_SLONG
	maxval#[$$ULONG]		= $$MAX_ULONG
	maxval#[$$XLONG]		= $$MAX_XLONG
	maxval#[$$GOADDR]		= $$MAX_XLONG
	maxval#[$$SUBADDR]	= $$MAX_XLONG
	maxval#[$$FUNCADDR]	= $$MAX_XLONG
	maxval#[$$SINGLE]		= $$MAX_SINGLE
	maxval#[$$DOUBLE]		= $$MAX_DOUBLE
	maxval#[$$GIANT]		= $$MAX_GIANT

	blanks[0] = 0x00000000		' no spaces or tabs
	blanks[1] = 0x20000000		' 1 space
	blanks[2] = 0x40000000		' 2 spaces
	blanks[3] = 0x60000000		' 3 spaces
	blanks[4] = 0x80000000		' 4 tabs
	blanks[5] = 0xA0000000		' 3 tabs
	blanks[6] = 0xC0000000		' 2 tabs
	blanks[7] = 0xE0000000		' 1 tab


' *****  q_type_long[]  *****

	q_type_long [ $$SLONG ] = $$SLONG
	q_type_long [ $$ULONG ] = $$ULONG
	q_type_long [ $$XLONG ] = $$XLONG

	q_type_long_or_addr [ $$SLONG			] = $$SLONG
	q_type_long_or_addr [ $$ULONG			] = $$ULONG
	q_type_long_or_addr [ $$XLONG			] = $$XLONG
	q_type_long_or_addr [ $$GOADDR		] = $$GOADDR
	q_type_long_or_addr [ $$SUBADDR		] = $$SUBADDR
	q_type_long_or_addr [ $$FUNCADDR	] = $$FUNCADDR


' **************************
' *****  shiftMulti[]  *****  UBYTE array
' **************************

	shiftMulti [   2]		=  1
	shiftMulti [   4]		=  2
	shiftMulti [   8]		=  3
	shiftMulti [  16]		=  4
	shiftMulti [  32]		=  5
	shiftMulti [  64]		=  6
	shiftMulti [ 128]		=  7
	shiftMulti [ 256]		=  8
	shiftMulti [ 512]		=  9
	shiftMulti [1024]		= 10


' ***************************
' *****  typeConvert[]  *****  SSHORT array
' ***************************

' typeConvert[i,j] is used to find out whether a source operand of type "j"
' can be converted to type "i".  The contents of typeConvert[i,j] is the
' working result type of the conversion will be, which is type "i" unless
' type "i" is less than SLONG, in which case the working result type is SLONG.
' If conversion from type "j" to type "i" is invalid, then the contents of
' typeConvert[i,j] = 1.  If conversion is unnecessary, typeConvert[i,j] = 0.
' Otherwise typeConvert[i,j] = working result type

' NOTE:  Entries for error cases are not needed in the CASE statements since
'        unspecified entries becomes an error by "typeConvert[i,j] = terror".

	terror	= -1											' terror	= error flag = -1
	FOR i = 0 TO 31										' i				= type "i" = destination type
		FOR j = 0 TO 31									' j				= type "j" = source type
			IF (i <= $$SLONG) THEN r = ($$SLONG << 8) ELSE r = (i << 8)
			none	= r											' conversion not necessary
			same	= r											' conversion not necessary
			conv	= r	+ i									' conversion OK  (defined)
			typeConvert[i,j] = terror			' default = error
			SELECT CASE i
				CASE $$SBYTE
					SELECT CASE j
						CASE $$SBYTE:		typeConvert[i,j] = same			' same
						CASE $$UBYTE:		typeConvert[i,j] = conv			' j to i
						CASE $$SSHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:		typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:		typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:		typeConvert[i,j] = none			' r = i
						CASE $$GIANT:		typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:	typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:	typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:	typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$UBYTE
					SELECT CASE j
						CASE $$SBYTE:		typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:		typeConvert[i,j] = same			' same
						CASE $$SSHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:		typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:		typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:		typeConvert[i,j] = none			' r = i
						CASE $$GIANT:		typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:	typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:	typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:	typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$SSHORT
					SELECT CASE j
						CASE $$SBYTE:		typeConvert[i,j] = none			' r = i
						CASE $$UBYTE:		typeConvert[i,j] = none			' r = i
						CASE $$SSHORT:	typeConvert[i,j] = same			' same
						CASE $$USHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:		typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:		typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:		typeConvert[i,j] = none			' r = i
						CASE $$GIANT:		typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:	typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:	typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:	typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$USHORT
					SELECT CASE j
						CASE $$SBYTE:		typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:		typeConvert[i,j] = none			' r = i
						CASE $$SSHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:	typeConvert[i,j] = same			' same
						CASE $$SLONG:		typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:		typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:		typeConvert[i,j] = none			' r = i
						CASE $$GIANT:		typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:	typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:	typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:	typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$SLONG
					SELECT CASE j
						CASE $$SBYTE:		typeConvert[i,j] = none			' r = i
						CASE $$UBYTE:		typeConvert[i,j] = none			' r = i
						CASE $$SSHORT:	typeConvert[i,j] = none			' r = i
						CASE $$USHORT:	typeConvert[i,j] = none			' r = i
						CASE $$SLONG:		typeConvert[i,j] = same			' same
						CASE $$ULONG:		typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:		typeConvert[i,j] = none			' r = i
						CASE $$GIANT:		typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:	typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:	typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:	typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$ULONG
					SELECT CASE j
						CASE $$SBYTE:		typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:		typeConvert[i,j] = none			' r = i
						CASE $$SSHORT:	typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:	typeConvert[i,j] = none			' r = i
						CASE $$SLONG:		typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:		typeConvert[i,j] = same			' same
						CASE $$XLONG:		typeConvert[i,j] = none			' r = i
						CASE $$GIANT:		typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:	typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:	typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:	typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$XLONG
					SELECT CASE j
						CASE $$SBYTE:			typeConvert[i,j] = none			' r = i
						CASE $$UBYTE:			typeConvert[i,j] = none			' r = i
						CASE $$SSHORT:		typeConvert[i,j] = none			' r = i
						CASE $$USHORT:		typeConvert[i,j] = none			' r = i
						CASE $$SLONG:			typeConvert[i,j] = none			' r = i
						CASE $$ULONG:			typeConvert[i,j] = none			' r = i
						CASE $$XLONG:			typeConvert[i,j] = same			' same
						CASE $$GOADDR:		typeConvert[i,j] = none			' r = i
						CASE $$SUBADDR:		typeConvert[i,j] = none			' r = i
						CASE $$FUNCADDR:	typeConvert[i,j] = none			' r = i
						CASE $$GIANT:			typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:		typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:		typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:		typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$GOADDR
					SELECT CASE j
						CASE $$XLONG:			typeConvert[i,j] = none			' r = i
						CASE $$GOADDR:		typeConvert[i,j] = same			' same
					END SELECT
				CASE $$SUBADDR
					SELECT CASE j
						CASE $$XLONG:			typeConvert[i,j] = none			' r = i
						CASE $$SUBADDR:		typeConvert[i,j] = same			' same
					END SELECT
				CASE $$FUNCADDR
					SELECT CASE j
						CASE $$XLONG:			typeConvert[i,j] = none			' r = i
						CASE $$FUNCADDR:	typeConvert[i,j] = same			' same
					END SELECT
				CASE $$GIANT
					SELECT CASE j
						CASE $$SBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$SSHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:			typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$GIANT:			typeConvert[i,j] = same			' same
						CASE $$SINGLE:		typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:		typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:		typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$SINGLE
					SELECT CASE j
						CASE $$SBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$SSHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:			typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$GIANT:			typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:		typeConvert[i,j] = same			' same
						CASE $$DOUBLE:		typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:		typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$DOUBLE
					SELECT CASE j
						CASE $$SBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$SSHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:			typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$GIANT:			typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:		typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:		typeConvert[i,j] = same			' same
						CASE $$LONGDOUBLE:		typeConvert[i,j] = conv			' j to i
					END SELECT
				CASE $$LONGDOUBLE
					SELECT CASE j
						CASE $$SBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$UBYTE:			typeConvert[i,j] = conv			' j to i
						CASE $$SSHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$USHORT:		typeConvert[i,j] = conv			' j to i
						CASE $$SLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$ULONG:			typeConvert[i,j] = conv			' j to i
						CASE $$XLONG:			typeConvert[i,j] = conv			' j to i
						CASE $$GIANT:			typeConvert[i,j] = conv			' j to i
						CASE $$SINGLE:		typeConvert[i,j] = conv			' j to i
						CASE $$DOUBLE:		typeConvert[i,j] = conv			' j to i
						CASE $$LONGDOUBLE:		typeConvert[i,j] = same			' same
					END SELECT
				CASE $$STRING
					SELECT CASE j
						CASE $$STRING:		typeConvert[i,j] = same			' same
					END SELECT
		END SELECT
		NEXT j
	NEXT i


' **************************
' *****  typeHigher[]  *****
' **************************

' typeHigher[i,j] is used to find out which of two types must be converted
' to the type of the other to get to the "higher" type.  "i" and "j" are the
' data types of operand #1 and operand #2.  The contents of typeHigher[i,j]
' tells what type each operand must be converted to, the higher of the two
' types, plus the "working" result type (SLONG for SBYTE through SLONG).

' Each byte of the XLONG contents of typeHigher[i,j] contains information:

' LSB  Byte 0:  Data type to convert "j" to
'      Byte 1:  Data type to convert "i" to
'      Byte 2:  Higher type
' MSB  Byte 3:	Result type  (SLONG for Higher type = SBYTE to SLONG)

' typeHigher[i,j] = terror if type conversion is invalid.
' typeHigher[i,j] = inone  if "i" is higher type but conversion is unnecessary.
' typeHigher[i,j] = jnone  if "j" is higher type but conversion is unnecessary.
' typeHigher[i,j] = tsame  if "i" and "j" are the same type (no conversion).

' NOTE:  Entries for error cases are not needed in the CASE statements since
'        unspecified entries becomes an error by "typeHigher[i,j] = terror".

	terror	= -1											' error
	FOR i = 0 TO 31										' i			= 1st data type
		FOR j = 0 TO 31									' j			= 2nd data type
			IF ((i <= $$SLONG) AND (j <= $$SLONG)) THEN
				r	= $$SLONG << 24
			ELSE
				IF (i > j) THEN r = i << 24 ELSE r = j << 24
			ENDIF
			ihi		= r + i << 16 + i				' ihi		= i is "higher", convert j to i
			jhi		= r + j << 16 + j << 8	' jhi		= j is "higher", convert i to j
			inone	= r + i << 16						' inone	= i is "higher", no convert needed
			jnone	= r + j << 16						' jnone = j is "higher", no convert needed
			tsame	= r + i << 16						' tsame = i,j are same,  no convert needed
			typeHigher[i,j] = terror			' default = error
			SELECT CASE i
				CASE $$SBYTE
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = tsame		' same
						CASE $$UBYTE:			typeHigher[i,j] = jhi			' i to j
						CASE $$SSHORT:		typeHigher[i,j] = jnone		' jhi, no
						CASE $$USHORT:		typeHigher[i,j] = jhi			' i to j
						CASE $$SLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$ULONG:			typeHigher[i,j] = jhi			' i to j
						CASE $$XLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$UBYTE
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$UBYTE:			typeHigher[i,j] = tsame		' same
						CASE $$SSHORT:		typeHigher[i,j] = jnone		' jhi, no
						CASE $$USHORT:		typeHigher[i,j] = jnone		' jhi, no
						CASE $$SLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$ULONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$XLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$SSHORT
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$UBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$SSHORT:		typeHigher[i,j] = tsame		' same
						CASE $$USHORT:		typeHigher[i,j] = jhi			' i to j
						CASE $$SLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$ULONG:			typeHigher[i,j] = jhi			' i to j
						CASE $$XLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$USHORT
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$UBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$SSHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$USHORT:		typeHigher[i,j] = tsame		' same
						CASE $$SLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$ULONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$XLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$SLONG
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$UBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$SSHORT:		typeHigher[i,j] = inone		' ihi, no
						CASE $$USHORT:		typeHigher[i,j] = inone		' ihi, no
						CASE $$SLONG:			typeHigher[i,j] = tsame		' same
						CASE $$ULONG:			typeHigher[i,j] = jhi			' i to j
						CASE $$XLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$ULONG
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$UBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$SSHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$USHORT:		typeHigher[i,j] = inone		' ihi, no
						CASE $$SLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$ULONG:			typeHigher[i,j] = tsame		' same
						CASE $$XLONG:			typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$XLONG
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$UBYTE:			typeHigher[i,j] = inone		' ihi, no
						CASE $$SSHORT:		typeHigher[i,j] = inone		' ihi, no
						CASE $$USHORT:		typeHigher[i,j] = inone		' ihi, no
						CASE $$SLONG:			typeHigher[i,j] = inone		' ihi, no
						CASE $$ULONG:			typeHigher[i,j] = inone		' ihi, no
						CASE $$XLONG:			typeHigher[i,j] = tsame		' same
						CASE $$GOADDR:		typeHigher[i,j] = jnone		' jhi, no
						CASE $$SUBADDR:		typeHigher[i,j] = jnone		' jhi, no
						CASE $$FUNCADDR:	typeHigher[i,j] = jnone		' jhi, no
						CASE $$GIANT:			typeHigher[i,j] = jhi			' i to j
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$GOADDR
					SELECT CASE j
						CASE $$XLONG:			typeHigher[i,j] = inone		' jhi, no
						CASE $$GOADDR:		typeHigher[i,j] = tsame		' same
					END SELECT
				CASE $$SUBADDR
					SELECT CASE j
						CASE $$XLONG:			typeHigher[i,j] = inone		' jhi, no
						CASE $$SUBADDR:		typeHigher[i,j] = tsame		' same
					END SELECT
				CASE $$FUNCADDR
					SELECT CASE j
						CASE $$XLONG:			typeHigher[i,j] = inone		' jhi, no
						CASE $$FUNCADDR:	typeHigher[i,j] = tsame		' same
					END SELECT
				CASE $$GIANT
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$UBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$SSHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$USHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$SLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$ULONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$XLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$GIANT:			typeHigher[i,j] = tsame		' same
						CASE $$SINGLE:		typeHigher[i,j] = jhi			' i to j
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$SINGLE
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$UBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$SSHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$USHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$SLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$ULONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$XLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$GIANT:			typeHigher[i,j] = ihi			' j to i
						CASE $$SINGLE:		typeHigher[i,j] = tsame		' same
						CASE $$DOUBLE:		typeHigher[i,j] = jhi			' i to j
					END SELECT
				CASE $$DOUBLE
					SELECT CASE j
						CASE $$SBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$UBYTE:			typeHigher[i,j] = ihi			' j to i
						CASE $$SSHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$USHORT:		typeHigher[i,j] = ihi			' j to i
						CASE $$SLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$ULONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$XLONG:			typeHigher[i,j] = ihi			' j to i
						CASE $$GIANT:			typeHigher[i,j] = ihi			' j to i
						CASE $$SINGLE:		typeHigher[i,j] = ihi			' j to i
						CASE $$DOUBLE:		typeHigher[i,j] = tsame		' same
					END SELECT
				CASE $$STRING
					SELECT CASE j
						CASE $$STRING:		typeHigher[i,j] = tsame		' same
					END SELECT
				CASE $$LONGDOUBLE
					SELECT CASE j
						CASE $$LONGDOUBLE:typeHigher[i,j] = tsame		' same
					END SELECT
		END SELECT
		NEXT j
	NEXT i



' *************************************************
' *****  Load cop[] from diskfile "copx.bin"  *****
' *************************************************

	##ERROR = $$FALSE
	f$ = ##XBDir$ + $$PathSlash$ + "templates" + $$PathSlash$ + "copx.bin"
	copfile = OPEN (f$, $$RD)

	IF (##ERROR OR (copfile <= 0)) THEN
		PRINT "*****  FATAL ERROR  *****  file <"; f$; "> not found  *****"
	ELSE
		FOR x = 0 TO 11											' operator table # (operator class)
			FOR y = 0 TO 15										' operand 1 (left)
				FOR z = 0 TO 15									' operand 2 (right)
					READ [copfile], temp					' get operator control word
					cop[x, y, z] = temp						' put it in cop[]
				NEXT z
			NEXT y
		NEXT x
		CLOSE (copfile)
	ENDIF
END FUNCTION


' ############################
' #####  InitComplex ()  #####
' ############################

FUNCTION  InitComplex ()
	SHARED	typeEleSymbol$[]
	SHARED	typeEleToken[]
	SHARED	typeEleAddr[]
	SHARED	typeEleSize[]
	SHARED	typeEleType[]
	SHARED	typeEleVal[]
	SHARED	typeElePtr[]
	SHARED	typeEleStringSize[]
	SHARED	typeEleUBound[]
	SHARED	typeEleCount[]

' Create arrays to hold information on SCOMPLEX data type

	DIM  tempEleSymbol$[3]
	DIM  tempEleToken[3]
	DIM  tempEleAddr[3]
	DIM	 tempEleSize[3]
	DIM  tempEleType[3]
	DIM  tempEleVal[3]
	DIM  tempElePtr[3]
	DIM  tempEleStringSize[3]
	DIM  tempEleUBound[3]

' Attach arrays to type arrays at SCOMPLEX data type

	ATTACH tempEleSymbol$[] TO typeEleSymbol$[$$SCOMPLEX, ]
	ATTACH tempEleToken[] TO typeEleToken[$$SCOMPLEX, ]
	ATTACH tempEleAddr[] TO typeEleAddr[$$SCOMPLEX, ]
	ATTACH tempEleSize[] TO typeEleSize[$$SCOMPLEX, ]
	ATTACH tempEleType[] TO typeEleType[$$SCOMPLEX, ]
	ATTACH tempEleVal[] TO typeEleVal[$$SCOMPLEX, ]
	ATTACH tempElePtr[] TO typeElePtr[$$SCOMPLEX, ]
	ATTACH tempEleStringSize[] TO typeEleStringSize[$$SCOMPLEX, ]
	ATTACH tempEleUBound[] TO typeEleUBound[$$SCOMPLEX, ]

' Create arrays to hold information on DCOMPLEX data type

	DIM  tempEleSymbol$[3]
	DIM  tempEleToken[3]
	DIM  tempEleAddr[3]
	DIM	 tempEleSize[3]
	DIM  tempEleType[3]
	DIM  tempEleVal[3]
	DIM  tempElePtr[3]
	DIM  tempEleStringSize[3]
	DIM  tempEleUBound[3]

' Attach arrays to type arrays at DCOMPLEX data type

	ATTACH tempEleSymbol$[] TO typeEleSymbol$[$$DCOMPLEX, ]
	ATTACH tempEleToken[] TO typeEleToken[$$DCOMPLEX, ]
	ATTACH tempEleAddr[] TO typeEleAddr[$$DCOMPLEX, ]
	ATTACH tempEleSize[] TO typeEleSize[$$DCOMPLEX, ]
	ATTACH tempEleType[] TO typeEleType[$$DCOMPLEX, ]
	ATTACH tempEleVal[] TO typeEleVal[$$DCOMPLEX, ]
	ATTACH tempElePtr[] TO typeElePtr[$$DCOMPLEX, ]
	ATTACH tempEleStringSize[] TO typeEleStringSize[$$DCOMPLEX, ]
	ATTACH tempEleUBound[] TO typeEleUBound[$$DCOMPLEX, ]

' Fill in SCOMPLEX and DCOMPLEX data type arrays

	typeEleCount [$$SCOMPLEX]			= 2				' 2 elements; real/imaginary
	typeEleCount [$$DCOMPLEX]			= 2				' 2 elements; real/imaginary

	typeEleSymbol$ [$$SCOMPLEX, 0] = ".R"		' REAL
	typeEleSymbol$ [$$SCOMPLEX, 1] = ".I"		' IMAGINARY
	typeEleSymbol$ [$$DCOMPLEX, 0] = ".R"		' REAL
	typeEleSymbol$ [$$DCOMPLEX, 1] = ".I"		' IMAGINARY

	tokenR = AddSymbol (".R", $$T_SYMBOLS, 0)
	tokenI = AddSymbol (".I", $$T_SYMBOLS, 0)

	typeEleToken [$$SCOMPLEX, 0] 	= tokenR
	typeEleToken [$$SCOMPLEX, 1] 	= tokenI
	typeEleToken [$$DCOMPLEX, 0] 	= tokenR
	typeEleToken [$$DCOMPLEX, 1] 	= tokenI

	typeEleAddr [$$SCOMPLEX, 0]		=  0
	typeEleAddr [$$SCOMPLEX, 1]		=  4
	typeEleAddr [$$DCOMPLEX, 0]		=  0
	typeEleAddr [$$DCOMPLEX, 1]		=  8

	typeEleSize [$$SCOMPLEX, 0]		=  4
	typeEleSize [$$SCOMPLEX, 1]		=  4
	typeEleSize [$$DCOMPLEX, 0]		=  8
	typeEleSize [$$DCOMPLEX, 1]		=  8

	typeEleType [$$SCOMPLEX, 0]		=  $$SINGLE
	typeEleType [$$SCOMPLEX, 1]		=  $$SINGLE
	typeEleType [$$DCOMPLEX, 0]		=  $$DOUBLE
	typeEleType [$$DCOMPLEX, 1]		=  $$DOUBLE

	typeEleVal [$$SCOMPLEX, 0]		= 0
	typeEleVal [$$SCOMPLEX, 1]		= 0
	typeEleVal [$$DCOMPLEX, 0]		= 0
	typeEleVal [$$DCOMPLEX, 1]		= 0

	typeElePtr [$$SCOMPLEX, 0]		= 0
	typeElePtr [$$SCOMPLEX, 1]		= 0
	typeElePtr [$$DCOMPLEX, 0]		= 0
	typeElePtr [$$DCOMPLEX, 1]		= 0

	typeEleStringSize [$$SCOMPLEX, 0]		= 0
	typeEleStringSize [$$SCOMPLEX, 1]		= 0
	typeEleStringSize [$$DCOMPLEX, 0]		= 0
	typeEleStringSize [$$DCOMPLEX, 1]		= 0

	typeEleUBound [$$SCOMPLEX, 0]		= 0
	typeEleUBound [$$SCOMPLEX, 1]		= 0
	typeEleUBound [$$DCOMPLEX, 0]		= 0
	typeEleUBound [$$DCOMPLEX, 1]		= 0
END FUNCTION




' ############################
' #####  InitEnvVars ()  #####
' ############################

' Initialize Environment Variables

FUNCTION  InitEnvVars ()

' find/create/set the environment variable XBLDIR

	XstGetEnvironmentVariable (@"XBLDIR", @##XBDir$)

' If the environment variable XBLDIR is not set: try to get the XB LITE
' base-directory \xblite from the full filename/path of the executable.

	IFZ ##XBDir$ THEN
		prog$ = XstGetProgramFileName$ ()
		##XBDir$ = LEFT$(prog$, INSTRI(prog$, "xblite") + 5)
		XstSetEnvironmentVariable (@"XBLDIR", @##XBDir$)
	ENDIF

' Fallback to a system dependent default directory
	IFZ ##XBDir$ THEN
		##XBDir$ = "c:\\xblite"
		XstSetEnvironmentVariable (@"XBLDIR", @##XBDir$)
	ENDIF

' Check if the include directory is available. Otherwise it's probably an
' installation error -> exit with an error message.
	testFile$ = ##XBDir$ + $$PathSlash$ + "include"
	XstGetFileAttributes(testFile$, @xb0)
	IFZ xb0 THEN
		XstAbend(testFile$ + " not found : bad installation.")
		RETURN $$TRUE
	ENDIF

	RETURN $$FALSE

END FUNCTION


' ###########################
' #####  InitErrors ()  #####
' ###########################

FUNCTION  InitErrors ()
	SHARED ERROR_AFTER_ELSE
	SHARED ERROR_BAD_CASE_ALL
	SHARED ERROR_BAD_GOSUB
	SHARED ERROR_BAD_GOTO
	SHARED ERROR_BAD_SYMBOL
	SHARED ERROR_BITSPEC
	SHARED ERROR_BYREF
	SHARED ERROR_BYVAL
	SHARED ERROR_COMPILER
	SHARED ERROR_COMPONENT
	SHARED ERROR_CROSSED_FUNCTIONS
	SHARED ERROR_DECLARE
	SHARED ERROR_DECLARE_FUNCS_FIRST
	SHARED ERROR_DUP_DECLARATION
	SHARED ERROR_DUP_DEFINITION
	SHARED ERROR_DUP_LABEL
	SHARED ERROR_DUP_TYPE
	SHARED ERROR_ELSE_IN_CASE_ALL
	SHARED ERROR_ENTRY_FUNCTION
	SHARED ERROR_EXPECT_ASSIGNMENT
	SHARED ERROR_EXPLICIT_VARIABLE
	SHARED ERROR_EXPRESSION_STACK
	SHARED ERROR_FILE_NOT_FOUND
	SHARED ERROR_INTERNAL_EXTERNAL
	SHARED ERROR_KIND_MISMATCH
	SHARED ERROR_LITERAL
	SHARED ERROR_NEED_EXCESS_COMMA
	SHARED ERROR_NEED_SUBSCRIPT
	SHARED ERROR_NEST
	SHARED ERROR_NODE_DATA_MISMATCH
	SHARED ERROR_OPEN_FILE
	SHARED ERROR_OUTSIDE_FUNCTIONS
	SHARED ERROR_OVERFLOW
	SHARED ERROR_PROGRAM_NOT_NAMED
	SHARED ERROR_PROGRAM_NAME_MISMATCH
	SHARED ERROR_REGADDR
	SHARED ERROR_RETYPED
	SHARED ERROR_SCOPE_MISMATCH
	SHARED ERROR_SHARENAME
	SHARED ERROR_SYNTAX
	SHARED ERROR_TOO_FEW_ARGS
	SHARED ERROR_TOO_LATE
	SHARED ERROR_TOO_MANY_ARGS
	SHARED ERROR_TYPE_MISMATCH
	SHARED ERROR_UNDECLARED
	SHARED ERROR_UNDEFINED
	SHARED ERROR_UNIMPLEMENTED
	SHARED ERROR_VOID
	SHARED ERROR_WITHIN_FUNCTION
	SHARED uerror
	SHARED xerror$[]

	e = 1
	ERROR_AFTER_ELSE          	= e:  xerror$[e] = "After CASE ELSE":					INC e
	ERROR_BAD_CASE_ALL        	= e:  xerror$[e] = "Bad CASE ALL":						INC e
	ERROR_BAD_GOSUB           	= e:  xerror$[e] = "Bad GOSUB dest type":			INC e
	ERROR_BAD_GOTO            	= e:  xerror$[e] = "Bad GOTO dest type":			INC e
	ERROR_BAD_SYMBOL						= e:  xerror$[e] = "Bad Symbol":							INC e
	ERROR_BITSPEC								= e:	xerror$[e] = "Bad Bitfield Spec":				INC e
	ERROR_BYREF               	= e:  xerror$[e] = "Bad Pass By Reference":		INC e
	ERROR_BYVAL               	= e:  xerror$[e] = "Bad Pass By Value":				INC e
	ERROR_COMPILER            	= e:  xerror$[e] = "Compiler Error":					INC e
	ERROR_COMPONENT							= e:	xerror$[e] = "Component Error":					INC e
	ERROR_CROSSED_FUNCTIONS   	= e:  xerror$[e] = "Crossed Functions (X/C)":	INC e
	ERROR_DECLARE             	= e:  xerror$[e] = "DECLARE after SHARED":		INC e
	ERROR_DECLARE_FUNCS_FIRST		= e:  xerror$[e] = "DECLARE too late":				INC e
	ERROR_DUP_DECLARATION     	= e:  xerror$[e] = "Duplicate Declaration":		INC e
	ERROR_DUP_DEFINITION      	= e:  xerror$[e] = "Duplicate Definition":		INC e
	ERROR_DUP_LABEL           	= e:  xerror$[e] = "Duplicate Label":					INC e
	ERROR_DUP_TYPE							= e:	xerror$[e] = "Duplicate Type":					INC e
	ERROR_ELSE_IN_CASE_ALL    	= e:  xerror$[e] = "CASE ELSE in CASE ALL":		INC e
	ERROR_ENTRY_FUNCTION				= e:	xerror$[e] = "Entry Function Error":		INC e
	ERROR_EXPECT_ASSIGNMENT			= e:	xerror$[e] = "Expect Assignment":				INC e
	ERROR_EXPLICIT_VARIABLE   	= e:  xerror$[e] = "Not Explicitly Defined":  INC e
	ERROR_EXPRESSION_STACK    	= e:  xerror$[e] = "Expression Error":				INC e
	ERROR_FILE_NOT_FOUND				= e:	xerror$[e] = "File Not Found":					INC e
	ERROR_INTERNAL_EXTERNAL			= e:	xerror$[e] = "Internal / External":			INC e
	ERROR_KIND_MISMATCH       	= e:  xerror$[e] = "Kind Mismatch":						INC e
	ERROR_LITERAL             	= e:  xerror$[e] = "Literal Error":						INC e
	ERROR_NEED_EXCESS_COMMA			= e:	xerror$[e] = "Need Excess Comma":				INC e
	ERROR_NEED_SUBSCRIPT				= e:	xerror$[e] = "Need Subscript":					INC e
	ERROR_NEST                	= e:  xerror$[e] = "Nesting Error":						INC e
	ERROR_NODE_DATA_MISMATCH		= e:	xerror$[e] = "Node / Data Mismatch":		INC e
	ERROR_OPEN_FILE							= e:	xerror$[e] = "Open Error":							INC e
	ERROR_OUTSIDE_FUNCTIONS   	= e:  xerror$[e] = "Outside Functions Error":	INC e
	ERROR_OVERFLOW            	= e:  xerror$[e] = "Overflow Error":					INC e
	ERROR_PROGRAM_NOT_NAMED			= e:  xerror$[e] = "Program Not Named":				INC e
	ERROR_PROGRAM_NAME_MISMATCH	= e:  xerror$[e] = "Program Name Mismatch":		INC e
	ERROR_REGADDR             	= e:  xerror$[e] = "Register Address":				INC e
	ERROR_RETYPED             	= e:  xerror$[e] = "Duplicate Type Spec":			INC e
	ERROR_SCOPE_MISMATCH      	= e:  xerror$[e] = "Scope Mismatch":					INC e
	ERROR_SHARENAME           	= e:  xerror$[e] = "Sharename Error":					INC e
	ERROR_SYNTAX              	= e:  xerror$[e] = "Syntax Error":						INC e
	ERROR_TOO_FEW_ARGS        	= e:  xerror$[e] = "Too Few Arguments":				INC e
	ERROR_TOO_LATE            	= e:  xerror$[e] = "Too Late":								INC e
	ERROR_TOO_MANY_ARGS       	= e:  xerror$[e] = "Too Many Arguments":			INC e
	ERROR_TYPE_MISMATCH       	= e:  xerror$[e] = "Type Mismatch":						INC e
	ERROR_UNDECLARED          	= e:  xerror$[e] = "Undeclared":							INC e
	ERROR_UNDEFINED           	= e:  xerror$[e] = "Undefined":								INC e
	ERROR_UNIMPLEMENTED       	= e:  xerror$[e] = "Unimplemented":						INC e
	ERROR_VOID                	= e:  xerror$[e] = "Void Error":							INC e
	ERROR_WITHIN_FUNCTION     	= e:  xerror$[e] = "Within Function":					INC e
	uerror											= e - 1
END FUNCTION


' ##############################
' #####  InitVariables ()  #####
' ##############################

FUNCTION  InitVariables ()
	SHARED	entryFunction,  errorCount
	SHARED	defaultType[]
	SHARED	XERROR
	SHARED	charPtr,  defaultType
	SHARED	end_program,  func_number
	SHARED	got_declare,  got_executable,  got_export,  got_function
	SHARED	got_import,  got_object_declaration,  got_program,  got_type
	SHARED	hfn$,  ifLine,  infunc,  insub,  oos
	SHARED	labelNumber,  lineNumber
	SHARED	patchPtr,  labelPtr,  backToken,  lastToken,  nestCount,  nestLevel
	SHARED	subCount,  tokenPtr,  tab_sym_ptr
	SHARED	programTypeChunk,  functionTypeChunk
	SHARED	pastSystemLabels
	SHARED	nullstring$
	SHARED  version$
	SHARED	pass
	SHARED  prologCode, preExports, exportCount, importCount, declareCount
	SHARED  export$[], import$[], declare$[]
	SHARED  libraryCode$[], libraryName$[], libraryHandle[], libraryExt$[]  'newimport

	DIM export$[]
	DIM import$[]
	DIM declare$[]
	DIM libraryCode$[]
	DIM libraryName$[]
	DIM libraryHandle[]
	DIM libraryExt$[]     'newimport

	#emitasm			= 0			' pass through
	XERROR				= 0
	pass					= 0
	prologCode    = 0
	preExports		= 0
	exportCount		= 0
	importCount		= 0
	declareCount	= 0
	oos						= 0
	insub					= 0
	infunc				= 0
	ifLine				= 0
	charPtr				= 0
	subCount			= 0
	tokenPtr			= 0
	nestCount			= 0
	nestLevel			= 0
	backToken			= 0
	lastToken			= 0
	errorCount		= 0
	patchPtr			= 0
	lineNumber		= 0
	func_number		= 0
	labelNumber		= 0
	hfn$					= "0"
	labelPtr			= 0
	tab_sym_ptr		= 0
	got_declare		= $$FALSE
	got_export		= $$FALSE
	got_function	= $$FALSE
	got_import		= $$FALSE
	got_program		= $$FALSE
	got_type			= $$FALSE
	end_program		= $$FALSE
	defaultType		= $$XLONG
	nullstring$		= CHR$(34) + CHR$(34)
	version$			= ""

	entryFunction							= 1
	programTypeChunk					= 0
	functionTypeChunk					= 0
	got_executable						= $$FALSE
	got_object_declaration		= $$FALSE
	defaultType[func_number]	= defaultType
END FUNCTION



' ############################
' #####  LastElement ()  #####
' ############################

' Scans tokens ahead to determine if at last element in a composite

FUNCTION  LastElement (token, lastPlace, excessComma)
	SHARED	T_COMMA,  T_LBRAK,  T_RBRAK
	SHARED	tokenPtr

	excessComma	= $$FALSE
	hold_place	= tokenPtr
	SELECT CASE token{$$KIND}
		CASE $$KIND_ARRAYS, $$KIND_ARRAY_SYMBOLS
			token = NextToken ()												' skip [...]
			IF (token != T_LBRAK) THEN GOTO eeeSyntax
			hold_lbrak = tokenPtr
			brackCount = 1
			DO WHILE brackCount
				old_token = token
				token = NextToken ()
				SELECT CASE token
					CASE T_RBRAK:		DEC brackCount
					CASE T_LBRAK:		INC brackCount
				END SELECT
			LOOP UNTIL (token{$$KIND} = $$KIND_STARTS)
			IF brackCount THEN
				tokenPtr = hold_lbrak
				GOTO eeeSyntax
			ENDIF
			IF (old_token = T_COMMA) THEN
				lastPlace		= tokenPtr
				token				= NextToken ()
				tokenPtr		= hold_place
				excessComma = $$TRUE
				RETURN ($$TRUE)
			ENDIF
	END SELECT

	lastPlace		= tokenPtr								' point to end of current composite
	token				= NextToken ()						' is next token a composite?
	kind				= token{$$KIND}
	tokenPtr		= hold_place
	IF (kind = $$KIND_SYMBOLS) THEN RETURN ($$FALSE)
	IF (kind = $$KIND_ARRAY_SYMBOLS) THEN RETURN ($$FALSE)
	RETURN ($$TRUE)

eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
END FUNCTION


' ########################
' #####  Literal ()  #####
' ########################

FUNCTION  Literal (xx)
	SHARED	r_addr[]

	r = r_addr[xx{$$WORD0}]
	IF (r >= $$IMM16) AND (r <= $$CONNUM) THEN RETURN ($$TRUE)
	RETURN ($$FALSE)
END FUNCTION


' ###########################  dreg = 0 means push on CPU stack (esp stack)
' #####  LoadLitnum ()  #####
' ###########################

FUNCTION  LoadLitnum (dreg, dtype, source, stype)
	SHARED	reg86$[],  reg86c$[]
	SHARED	m_reg[],  m_addr[],  m_addr$[],  tab_sym[], r_addr$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	nullstringer
	LONGDOUBLE xld

	ss = source{$$NUMBER}
	st = tab_sym[ss]

	IF (ss = nullstringer) THEN
		IF dreg THEN
			Code ($$xor, $$regreg, dreg, dreg, 0, $$XLONG, @"", @"	;;; i646a")
		ELSE
			Move (dreg, $$XLONG, nullstringer, $$XLONG)
		ENDIF
		RETURN
	ENDIF

	IF (dtype = $$STRING) THEN
		IFZ dreg THEN
			Code ($$push, $$imm, m_addr[ss], 0, 0, $$XLONG, m_addr$[ss], @"	;;; i646b")
		ELSE
			Code ($$mov, $$regimm, dreg, 0, m_addr[ss], $$XLONG, m_addr$[ss], @"	;;; i647")
		ENDIF
		RETURN
	ENDIF

	IF dtype != $$LONGDOUBLE THEN
		GetWords (source, dtype, @w3, @w2, @w1, @w0)
		IF XERROR THEN EXIT FUNCTION
	ENDIF

	SELECT CASE dtype
		CASE $$GIANT
					IFZ dreg THEN
						Code ($$push, $$imm, (w3 << 16 + w2), 0, 0, $$XLONG, @"", @"	;;; i647a")
						Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, @"", @"	;;; i647b")
					ELSE
						Code ($$mov, $$regimm, dreg+1, (w3 << 16 + w2), 0, $$XLONG, @"", @"	;;; i648")
						Code ($$mov, $$regimm, dreg, (w1 << 16 + w0), 0, $$XLONG, @"", @"	;;; i649")
					ENDIF
		CASE $$DOUBLE
					Code ($$push, $$imm, (w3 << 16 + w2), 0, 0, $$XLONG, @"", @"	;;; i650")
					Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, @"", @"	;;; i651")
					IF dreg THEN
						Code ($$fld, $$ro, 0, $$esp, 0, $$DOUBLE, @"", @"	;;; i652")
						Code ($$add, $$regimm, $$esp, 8, 0, $$XLONG, @"", @"	;;; i653")
					ENDIF
		CASE $$LONGDOUBLE
					x$ = r_addr$[ss]
					IFZ x$ THEN GOTO eeeCompiler
					sType = XstStringToLongDouble (@x$, 0, @cPtr, @rt, @xld)
					IF sType != $$LONGDOUBLE THEN GOTO eeeCompiler
					addr = &xld
' create array of 6 sshort words
					w0 = USHORTAT (addr + 0)
					w1 = USHORTAT (addr + 2)
					w2 = USHORTAT (addr + 4)
					w3 = USHORTAT (addr + 6)
					w4 = USHORTAT (addr + 8)
					w5 = USHORTAT (addr + 10)
					Code ($$push, $$imm, (w5 << 16 + w4), 0, 0, $$XLONG, @"", @"	;;; i653b")
					Code ($$push, $$imm, (w3 << 16 + w2), 0, 0, $$XLONG, @"", @"	;;; i653c")
					Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, @"", @"	;;; i653d")
					IF dreg THEN
						Code ($$fld, $$ro, 0, $$esp, 0, $$LONGDOUBLE, @"", @"	;;; i653e")
						Code ($$add, $$regimm, $$esp, 12, 0, $$XLONG, @"", @"	;;; i653f")
					ENDIF
		CASE $$SINGLE
					Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, @"", @"	;;; i654")
					IF dreg THEN
						Code ($$fld, $$ro, 0, $$esp, 0, $$SINGLE, @"", @"	;;; i655")
						Code ($$add, $$regimm, $$esp, 4, 0, $$XLONG, @"", @"	;;; i656")
					ENDIF
		CASE ELSE
					IFZ dreg THEN
						Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, @"", @"	;;; i656a")
					ELSE
						Code ($$mov, $$regimm, dreg, (w1 << 16 + w0), 0, $$XLONG, @"", @"	;;; i657")
					ENDIF
	END SELECT
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  MakeToken ()  #####
' ##########################

FUNCTION  MakeToken (keyword$, kind, data_type)
	SHARED	tab_sys$[],  tab_sys[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	tab_sys_ptr

	SELECT CASE kind
		CASE $$KIND_VARIABLES																			: GOTO make_system
		CASE $$KIND_CONSTANTS, $$KIND_SYSCONS											: GOTO make_system
		CASE $$KIND_ARRAYS																				: GOTO make_system
		CASE $$KIND_STATEMENTS, $$KIND_INTRINSICS									: GOTO make_system
		CASE $$KIND_STATEMENTS_INTRINSICS													: GOTO make_system
		CASE $$KIND_SEPARATORS, $$KIND_TERMINATORS								: GOTO make_system
		CASE $$KIND_LPARENS, $$KIND_RPARENS												: GOTO make_system
		CASE $$KIND_UNARY_OPS, $$KIND_BINARY_OPS, $$KIND_ADDR_OPS	: GOTO make_system
		CASE $$KIND_CHARACTERS																		: GOTO make_system
		CASE $$KIND_COMMENTS, $$KIND_WHITES, $$KIND_STARTS				: GOTO make_comment
		CASE $$KIND_INLINEASM																			: GOTO make_system
		CASE ELSE																									: PRINT "mmm1": GOTO eeeCompiler
	END SELECT

make_system:
	the_token = (kind << 24) OR (data_type << 16) OR tab_sys_ptr
	upper = UBOUND(tab_sys$[])
	IF tab_sys_ptr > upper THEN
		REDIM tab_sys$[upper + 511]
		REDIM tab_sys[upper + 511]
	ENDIF
	tab_sys$[tab_sys_ptr] = keyword$
	tab_sys[tab_sys_ptr] = the_token
	INC tab_sys_ptr
	RETURN (the_token)

' make white.space token  (data.type = # of spaces, word0 = error #)
' make start token  (word0 = # of tokens generated for this line)
' make error token  (data.type = # of bytes in error text)

make_comment:
	the_token = kind << 24
	RETURN (the_token)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##################################
' #####  MinTypeFromDouble ()  #####
' ##################################

FUNCTION	MinTypeFromDouble (value#)
	IF (value# < 0) THEN value# = -value#
	minSingleExponent#	= 0s00800000
	maxSingleExponent#	= 0s7F000000
	IF (value# < minSingleExponent#) THEN RETURN ($$DOUBLE)
	IF (value# > maxSingleExponent#) THEN RETURN ($$DOUBLE)
	svalue! = value#
	dvalue# = svalue!
	IF (value# = dvalue#) THEN RETURN ($$SINGLE)
	RETURN ($$DOUBLE)
END FUNCTION


' #################################
' #####  MinTypeFromGiant ()  #####
' #################################

FUNCTION	MinTypeFromGiant (v$$)
	SELECT CASE TRUE
		CASE ((v$$ >= $$MIN_USHORT) AND (v$$ <= $$MAX_USHORT)):	rt = $$USHORT
		CASE ((v$$ >= $$MIN_SSHORT) AND (v$$ <= $$MAX_SSHORT)):	rt = $$SSHORT
		CASE ((v$$ >= $$MIN_SLONG)  AND (v$$ <= $$MAX_SLONG)):	rt = $$SLONG
		CASE ELSE:																							rt = $$GIANT
	END SELECT
	RETURN (rt)
END FUNCTION


' #####################  destin = 0 means push on CPU stack (esp stack)
' #####  Move ()  #####
' #####################

FUNCTION  Move (destin, d_type, source, s_type)
	SHARED	reg86$[],  reg86c$[]
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	r_addr[],  r_addr$[],  tab_sym[],  tab_sym$[]
	SHARED	typeSize[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH
	SHARED	a0_type,  a1_type,  charPtr,  nullstringer
	SHARED SSHORT typeConvert[]

	dext    = $$FALSE									' not EXTERNAL destination
	sext    = $$FALSE									' not EXTERNAL source
	dxarg		= $$FALSE									' not excess argument destination
	sxarg		= $$FALSE									' not excess argument source
	slits   = $$FALSE									' not "literal string"
	sdest   = destin AND 0xFFFF
	ssource = source AND 0xFFFF
	IF (sdest > $$CONNUM) THEN
		d		= tab_sym[sdest]
		k		= d{$$KIND}
		da	= d{$$ALLO}
		IF (da = $$EXTERNAL) THEN dext = $$TRUE
	ENDIF
	IF (ssource > $$CONNUM) THEN
		s  = tab_sym[ssource]
		k  = s{$$KIND}
		t  = TheType (s)
		sa = s{$$ALLO}
		SELECT CASE k
			CASE $$KIND_LITERALS, $$KIND_CONSTANTS, $$KIND_SYSCONS
						IF (t = $$STRING) THEN slits = $$TRUE
		END SELECT
		IF (sa = $$EXTERNAL) THEN sext = $$TRUE
	ENDIF
	IFZ d_type THEN d_type = s_type
	d_reg = 0
	s_reg = r_addr[ssource]
	IF destin THEN d_reg = r_addr[sdest]
	SELECT CASE d_type
		CASE $$SINGLE:	dfloat = $$TRUE
		CASE $$DOUBLE:	dfloat = $$TRUE
		CASE $$LONGDOUBLE : dfloat = $$TRUE
		CASE ELSE:			dfloat = $$FALSE
	END SELECT
	SELECT CASE s_type
		CASE $$SINGLE:	sfloat = $$TRUE
		CASE $$DOUBLE:	sfloat = $$TRUE
		CASE $$LONGDOUBLE : sfloat = $$TRUE
		CASE ELSE:			sfloat = $$FALSE
	END SELECT
	SELECT CASE d_type
		CASE $$GIANT
					dtwo		= $$TRUE
					d_regx	= d_reg + 1
		CASE $$STRING
					destString = $$TRUE
	END SELECT
	SELECT CASE s_type
		CASE $$GIANT
					stwo		= $$TRUE
					s_regx	= s_reg + 1
		CASE $$STRING
					sourceString = $$TRUE
	END SELECT
	IF (destString XOR sourceString) THEN PRINT "move0": GOTO eeeCompiler
	IFZ sourceString THEN
		IF ((d_type >= $$SCOMPLEX) OR (s_type >= $$SCOMPLEX)) THEN
			IF  (d_type != s_type) THEN GOTO eeeTypeMismatch
		ELSE
			IF (typeConvert[d_type, s_type] {{$$BYTE0}}) THEN
				PRINT "move1"
				GOTO eeeCompiler
			ENDIF
		ENDIF
	ENDIF
	IF (destin = source) THEN RETURN
	IF (d_type < $$SLONG) THEN d_type = $$SLONG
	IF (s_type < $$SLONG) THEN s_type = $$SLONG
	SELECT CASE d_reg
		CASE $$RA0:	a0_type = d_type
		CASE $$RA1:	a1_type = d_type
	END SELECT


' *************************************************************
' *****  Dispatch based on destination/source in reg/mem  *****
' *************************************************************

	IF d_reg THEN
		IF s_reg THEN GOTO drsr ELSE GOTO drsm
	ELSE
		IF s_reg THEN GOTO dmsr ELSE GOTO dmsm
	ENDIF


' ************************************************************
' *****  Destination in Register  :  Source in Register  *****
' ************************************************************

drsr:
	IF (s_reg = $$CONNUM) OR (s_reg = $$LITNUM) THEN
		LoadLitnum (d_reg, d_type, source, @s_type)
		RETURN
	ENDIF
	IF ((s_reg = $$IMM16) OR (s_reg = $$NEG16)) THEN
		IF ((s_type >= $$GIANT) AND (s_type != $$STRING)) THEN
			LoadLitnum (d_reg, d_type, source, @s_type)
		ELSE
			IF (ssource = nullstringer) THEN
				Code ($$xor, $$regreg, d_reg, d_reg, 0, $$XLONG, @"", @"	;;; i658")
			ELSE
				x_imm	= XLONG (r_addr$[ssource])
				Code ($$mov, $$regimm, d_reg, x_imm, 0, $$XLONG, @"", @"	;;; i659")
			ENDIF
		ENDIF
		RETURN
	ENDIF
	IFZ dfloat THEN
		Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, @"", @"	;;; i660")
		IF dtwo THEN
			Code ($$mov, $$regreg, d_regx, s_regx, 0, $$XLONG, @"", @"	;;; i661")
		ENDIF
	ENDIF
	RETURN


' **********************************************************
' *****  Destination in Register  :  Source in Memory  *****
' **********************************************************

drsm:
	IFZ source THEN
		GOTO eeeCompiler
	ENDIF
	mReg	= m_reg[ssource]
	mAddr	= m_addr[ssource]
	IFZ mReg THEN
		m$	= m_addr$[ssource]
		IF sfloat THEN
			Code ($$fld, $$abs, 0, 0, mAddr, s_type, @m$, @"	;;; i662")
		ELSE
			IF slits THEN
				Code ($$mov, $$regimm, d_reg, mAddr, 0, s_type, @m$, @"	;;; i663")
			ELSE
				Code ($$ld, $$regabs, d_reg, 0, mAddr, s_type, @m$, @"	;;; i663a")
			ENDIF
		ENDIF
	ELSE
		IF sfloat THEN
			Code ($$fld, $$ro, 0, mReg, mAddr, s_type, @"", @"	;;; i664")
		ELSE
			Code ($$ld, $$regro, d_reg, mReg, mAddr, s_type, @"", @"	;;; i665")
		ENDIF
	ENDIF
	RETURN


' **********************************************************
' *****  Destination in Memory  :  Source in Register  *****
' **********************************************************

dmsr:
	SELECT CASE s_reg
		CASE $$IMM16, $$NEG16
					IF ((s_type >= $$GIANT) AND (s_type != $$STRING)) THEN
						IFZ destin THEN
							LoadLitnum (0, d_type, source, s_type)					' push literal
							RETURN
						ELSE
							LoadLitnum ($$esi, d_type, source, s_type)
						ENDIF
					ELSE
						x_imm	= XLONG (r_addr$[ssource])
						IFZ destin THEN
							Code ($$push, $$imm, x_imm, 0, 0, $$XLONG, @"", @"	;;; i665a")		' push literal
							RETURN
						ELSE
							Code ($$mov, $$regimm, $$esi, x_imm, 0, $$XLONG, @"", @"	;;; i666")
						ENDIF
					ENDIF
					s_reg = $$esi
		CASE $$LITNUM, $$CONNUM
					IFZ destin THEN
						LoadLitnum (0, d_type, source, @s_type)		' push literal
						RETURN
					ELSE
						LoadLitnum ($$esi, d_type, source, @s_type)
					ENDIF
					s_reg = $$esi
	END SELECT

	mReg	= m_reg[sdest]
	mAddr	= m_addr[sdest]
	IFZ mReg THEN
		m$	= m_addr$[sdest]
		IF dfloat THEN
			IFZ destin THEN
				SELECT CASE d_type
					CASE $$SINGLE			: dsize = 4
					CASE $$DOUBLE			: dsize = 8
					CASE $$LONGDOUBLE	: dsize = 12
				END SELECT
				Code ($$sub, $$regimm, $$esp, dsize, 0, $$XLONG, @"", @"	;;; i666a")
				Code ($$fstp, $$ro, 0, $$esp, 0, d_type, @"", @"	;;; i666b")
				RETURN
			ELSE
				Code ($$fstp, $$abs, 0, 0, mAddr, d_type, @m$, @"	;;; i667")
			ENDIF
		ELSE
			IFZ destin THEN
				Code ($$push, $$reg, s_reg, 0, 0, d_type, @"", @"	;;; i667a")
				RETURN
			ELSE
				Code ($$st, $$absreg, s_reg, 0, mAddr, d_type, @m$, @"	;;; i668")
			ENDIF
		ENDIF
	ELSE
		IF dfloat THEN
			Code ($$fstp, $$ro, 0, mReg, mAddr, d_type, @"", @"	;;; i669")
		ELSE
			Code ($$st, $$roreg, s_reg, mReg, mAddr, d_type, @"", @"	;;; i670")
		ENDIF
	ENDIF
	RETURN


' ********************************************************
' *****  Destination in Memory  :  Source in Memory  *****
' ********************************************************

dmsm:
	mReg	= m_reg[ssource]
	mAddr	= m_addr[ssource]
	IFZ mReg THEN
		m$	= m_addr$[ssource]
		IF slits THEN
			IFZ destin THEN
				Code ($$push, $$imm, 0, 0, mAddr, $$XLONG, @m$, @"	;;; i670a")
				RETURN
			ELSE
				Code ($$ld, $$regabs, $$esi, 0, mAddr, $$XLONG, @m$, @"	;;; i671")
			ENDIF
		ELSE
			IF sfloat THEN
				Code ($$fld, $$abs, 0, 0, mAddr, s_type, @m$, @"	;;; i672")
			ELSE
				IFZ destin THEN
					Code ($$push, $$abs, 0, 0, mAddr, s_type, @m$, @"	;;; i672a")
					RETURN
				ELSE
					Code ($$ld, $$regabs, $$esi, 0, mAddr, s_type, @m$, @"	;;; i673")
				ENDIF
			ENDIF
		ENDIF
	ELSE
		IF sfloat THEN
			Code ($$fld, $$ro, 0, mReg, mAddr, s_type, @"", @"	;;; i674")
		ELSE
			IFZ destin THEN
				Code ($$push, $$ro, 0, mReg, mAddr, s_type, @"", @"	;;; i674a")
				RETURN
			ELSE
				Code ($$ld, $$regro, $$esi, mReg, mAddr, s_type, @"", @"	;;; i675")
			ENDIF
		ENDIF
	ENDIF

	mReg	= m_reg[sdest]
	mAddr	= m_addr[sdest]
	SELECT CASE d_type
		CASE $$SINGLE		: dsize = 4
		CASE $$DOUBLE		: dsize = 8
		CASE $$LONGDOUBLE : dsize = 12
	END SELECT
	IFZ mReg THEN
		m$	= m_addr$[sdest]
		IF dfloat THEN
			IFZ destin THEN
				Code ($$sub, $$regimm, $$esp, dsize, 0, $$XLONG, @"", @"	;;; i675a")
				Code ($$fstp, $$ro, 0, $$esp, 0, d_type, @"", @"	;;; i675b")
			ELSE
				Code ($$fstp, $$abs, 0, 0, mAddr, d_type, @m$, @"	;;; i676")
			ENDIF
		ELSE
			IFZ destin THEN PRINT "MoveYikes0"
			Code ($$st, $$absreg, $$esi, 0, mAddr, d_type, @m$, @"	;;; i677")
		ENDIF
	ELSE
		IF dfloat THEN
			IFZ destin THEN PRINT "MoveYikes1"
			Code ($$fstp, $$ro, 0, mReg, mAddr, d_type, @"", @"	;;; i678")
		ELSE
			IFZ destin THEN PRINT "MoveYikes2"
			Code ($$st, $$roreg, $$esi, mReg, mAddr, d_type, @"", @"	;;; i679")
		ENDIF
	ENDIF
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  NextToken ()  #####
' ##########################

FUNCTION  NextToken ()
	SHARED	m_addr$[]
	SHARED	funcToken[]
	SHARED	uType,  typeAlias[],  typeToken[],  typeSymbol$[]
	SHARED	tab_sym[],  tab_sym$[],  tokens[]
	SHARED	tokenCount,  tokenPtr
	STATIC GOADDR  kindDispatch[]

	IFZ kindDispatch[] THEN GOSUB LoadKindDispatch		' load dispatch table

skip_whities:
	INC tokenPtr
	IF (tokenPtr >= tokenCount) THEN RETURN ($$T_STARTS)
	token = tokens[tokenPtr] AND 0x1FFFFFFF
	tt = token AND 0x0000FFFF
	GOTO @kindDispatch [token{$$KIND}]
	RETURN (token)

from_tab_sym:
	RETURN (tab_sym[tt])

' from_variables added 08/12/93 to support adding a user-defined type with
' the same name as existing variables.  The variables need to be mapped into
' the type token.

from_variables:
	token = tab_sym[tt]
	IF (token{$$KIND} != $$KIND_VARIABLES) THEN	' mapped to non-variable kind ?
		tt = token AND 0x0000FFFF
		GOTO @kindDispatch [token{$$KIND}]				' dispatch by mapped kind
	ENDIF
	IFZ m_addr$[tt] THEN												' if no address
		symbol$ = tab_sym$[tt]
		FOR i = $$DCOMPLEX+1 TO uType
			IF (symbol$ = typeSymbol$[i]) THEN			' supports adding a type
				token = typeToken[i]									' after a variable of the
				tab_sym[tt] = token										'	same name exists... and
			ENDIF																	' to a type token (hopefully)
		NEXT i
	ENDIF
	IF (token{$$KIND} != $$KIND_VARIABLES) THEN	' mapped to non-variable kind ?
		tt = token AND 0x0000FFFF
		GOTO @kindDispatch [token{$$KIND}]				' dispatch by mapped kind
	ENDIF
	RETURN (token)

from_func_sym:
	RETURN (funcToken[tt])

them_comments:
	tokenPtr = tokenCount
	RETURN ($$T_STARTS)

from_types:
	ttt = typeAlias[tt]{$$NUMBER}
	IF ttt THEN tt = ttt
	RETURN (typeToken[tt])


SUB LoadKindDispatch
	DIM kindDispatch[31]
	kindDispatch [ $$KIND_SYMBOLS				] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_ARRAY_SYMBOLS	] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_VARIABLES			] = GOADDRESS (from_variables)
	kindDispatch [ $$KIND_ARRAYS				] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_SYSCONS				] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_LITERALS			] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_CONSTANTS			] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_FUNCTIONS			] = GOADDRESS (from_func_sym)
	kindDispatch [ $$KIND_COMMENTS			] = GOADDRESS (them_comments)
	kindDispatch [ $$KIND_WHITES				] = GOADDRESS (skip_whities)
	kindDispatch [ $$KIND_TYPES					] = GOADDRESS (from_types)
END SUB
END FUNCTION


' ###################
' #####  Op ()  #####
' ###################

FUNCTION  Op (d_reg, s_reg, the_op, rax, rt, st, ot, xt)
	SHARED	lineNumber
	SHARED	reg86$[],  reg86c$[]
	SHARED	q_type_long[],  q_type_long_or_addr[]
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	r_addr[],  r_addr$[],  tab_sym[],  tab_sys$[],  typeName$[]
	SHARED	ERROR_COMPILER,  ERROR_OVERFLOW,  ERROR_TYPE_MISMATCH
	SHARED	T_TESTL
	SHARED	T_NOT,      T_NOTL,       T_NOTBIT,     T_TILDA
	SHARED	T_AND,      T_ANDL,       T_ANDBIT
	SHARED	T_XOR,      T_XORL,       T_XORBIT
	SHARED	T_OR,       T_ORL,        T_ORBIT
	SHARED	T_ADDR_OP,  T_HANDLE_OP
	SHARED	T_EQ,   T_NE,   T_LT,   T_LE,   T_GE,   T_GT,   T_EQL
	SHARED	T_NEQ,  T_NNE,  T_NLT,  T_NLE,  T_NGE,  T_NGT
	SHARED	T_ADD,  T_CMP,  T_DIV,  T_DSHIFT,  T_IDIV
	SHARED	T_LSHIFT,  T_MOD,  T_MUL
	SHARED	T_POWER,  T_RSHIFT,  T_SUBTRACT,  T_USHIFT
	SHARED	XERROR
	SHARED	toes,  a0,  a0_type,  a1,  a1_type,  oos,  tokenPtr,  comStk
	SHARED	func_number,  labelNumber
	SHARED UBYTE oos[]
	STATIC GOADDR  opToken[]


	IFZ opToken[] THEN GOSUB LoadOpToken

' *****  Destination register

	SELECT CASE d_reg
		CASE $$RA0:	a0_type = rt
		CASE $$RA1:	a1_type = rt
	END SELECT
	d_regx = d_reg + 1

' *****  Source register 1

	ras = s_reg
	SELECT CASE s_reg
		CASE $$RA0, $$RA1
		CASE ELSE:	IF (the_op != T_CMP) THEN PRINT "op2": GOTO eeeCompiler
	END SELECT
	s_regx = s_reg + 1

' *****  Source register 2 or immediate value

	revOp = $$FALSE
	SELECT CASE rax
		CASE $$FALSE	: PRINT "op3a : GOTO eeeCompiler"
		CASE $$RA0		: x_reg = $$RA0	: x_regx = x_reg + 1	: mode = $$regreg
		CASE $$RA1		: x_reg = $$RA1	: x_regx = x_reg + 1	: mode = $$regreg
		CASE ELSE			: IF (d_reg != s_reg) THEN PRINT "op3b" : GOTO eeeCompiler
										SELECT CASE ot
											CASE $$GIANT
														SELECT CASE d_reg
															CASE $$RA0
																		IF a1 THEN Push ($$RA1, $$GIANT)		' PRINT "Op(): Error: (GIANT a1 != 0)" : GOTO eeeCompiler
																		x_reg = $$ebx
																		x_regx = $$ecx
																		mode = $$regreg
																		Move (x_reg, xt, rax, xt)
																		a1 = 0 : a1_type = 0
															CASE $$RA1
																		IF a0 THEN Push ($$RA0, $$GIANT)		' PRINT "Op(): Error: (GIANT a0 != 0)" : GOTO eeeCompiler
																		x_reg = $$eax
																		x_regx = $$edx
																		mode = $$regreg
																		Move (x_reg, xt, rax, xt)
															CASE ELSE
																		PRINT "Op(): Error: (Giant Op)"
																		GOTO eeeCompiler
														END SELECT
											CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
														Move ($$esi, xt, rax, xt)
											CASE ELSE
														xx			= rax{$$NUMBER}
														x_reg		= XLONG (r_addr$[xx])
														x_regx	= 0
														mode		= $$regimm
														ximm		= $$TRUE
														x_imm		= x_reg
										END SELECT
	END SELECT
	IF ((ot = $$SCOMPLEX) OR (ot = $$DCOMPLEX)) THEN
		SELECT CASE the_op
			CASE T_CMP,  T_EQ,  T_NE, T_NEQ, T_NNE, T_EQL
			CASE T_LT,   T_LE,  T_GE,  T_GT
			CASE T_NLT, T_NLE, T_NGE, T_NGT
			CASE ELSE
						csymbol1$	= ".complex1." + HEX$(comStk)
						csymbol0$	= ".complex0." + HEX$(comStk)
						ctoken		= $$T_VARIABLES + ($$AUTOX << 21) + ($$DOUBLE << 16)
						ctoken1		= AddSymbol (@csymbol1$, ctoken, func_number)
						ctoken0		= AddSymbol (@csymbol0$, ctoken, func_number)
						cnumber0	= ctoken0{$$NUMBER}
						cnumber1	= ctoken1{$$NUMBER}

						ctoken0		= ctoken0 OR ($$AUTOX << 21)
						ctoken1		= ctoken1 OR ($$AUTOX << 21)
						tab_sym[cnumber0] = ctoken0
						tab_sym[cnumber1] = ctoken1

						IFZ m_addr$[cnumber1] THEN
							AssignAddress (ctoken1)
							AssignAddress (ctoken0)
							IF XERROR THEN EXIT FUNCTION
						ENDIF
						cr0	= m_reg[cnumber0]
						cn0 = m_addr[cnumber0]
						Code ($$mov, $$regreg, $$edi, x_reg, 0, $$XLONG, @"", @"	;;; i680")
						Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, @"", @"	;;; i681")
						Code ($$lea, $$regro, $$eax, cr0, cn0, $$XLONG, @"", @"	;;; i682")
						IF (d_reg != $$RA0) THEN PRINT "complexOp": GOTO eeeCompiler
						INC comStk
		END SELECT
	ELSE
		IF ximm THEN
			IF (d_reg != s_reg) THEN GOTO eeeCompiler
		ELSE
			SELECT CASE TRUE
				CASE (d_reg = s_reg)
							IF (d_reg = x_reg) THEN GOTO eeeCompiler
				CASE (d_reg = x_reg)
							IF (d_reg = s_reg) THEN GOTO eeeCompiler
							SWAP s_reg, x_reg
							SWAP s_regx, x_regx
							revOp = NOT revOp
				CASE ELSE
							IF (the_op != T_CMP) THEN PRINT "opCity": GOTO eeeCompiler
			END SELECT
		ENDIF
	ENDIF
	orderCounts = $$FALSE


' *****  Execute routine appropriate to binary operator token  *****

	GOTO @opToken[the_op AND 0x00FF]
	PRINT "opdispatch"
	GOTO eeeCompiler

' *****************************************************************************
' *****  Destinations of preceeding computed dispatch on operator tokens  *****
' *****************************************************************************

op_logical_or:		GOTO logical_or
op_logical_xor:		GOTO logical_xor
op_logical_and:		GOTO logical_and
op_cmp:						IF (ot = $$GIANT) THEN GOTO op_test_EQ
									eqt = $$FALSE:	GOSUB rop: EXIT FUNCTION
op_test_EQ:				eqt = $$TRUE:		GOSUB rop: GOTO test_EQ
op_test_NE:				eqt = $$TRUE:		GOSUB rop: GOTO test_NE
op_test_LT:				eqt = $$FALSE:	GOSUB rop: GOTO test_LT
op_test_LE:				eqt = $$FALSE:	GOSUB rop: GOTO test_LE
op_test_GE:				eqt = $$FALSE:	GOSUB rop: GOTO test_GE
op_test_GT:				eqt = $$FALSE:	GOSUB rop: GOTO test_GT
op_orbit:					GOTO bitwise_or
op_xorbit:				GOTO bitwise_xor
op_andbit:				GOTO bitwise_and
op_add:						GOTO add
op_subtract:			GOTO subtract
op_integer_mod:		GOTO integer_modulus
op_integer_div:		GOTO integer_divide
op_multiply:			GOTO multiply
op_divide:				GOTO divide
op_power:					GOTO power
op_right_shift:		GOTO right_shift
op_left_shift:		GOTO left_shift
op_down_shift:		GOTO down_shift
op_up_shift:			GOTO up_shift


' ****************************************  Compares operands, leaves compare
' *****  Relational Operator Prolog  *****  flag bits in "d.reg".  The operator
' ****************************************	routines extract appropriate bits.

SUB rop
	op = $$cmp
	SELECT CASE TRUE
		CASE (ot < $$GIANT):		GOSUB CompareLong
		CASE (ot = $$GIANT):		GOSUB CompareGiant
		CASE (ot = $$SINGLE):		GOSUB CompareFloat
		CASE (ot = $$DOUBLE):		GOSUB CompareFloat
		CASE (ot = $$LONGDOUBLE):	GOSUB CompareFloat
		CASE (ot = $$STRING):		GOSUB CompareString
		CASE (ot = $$SCOMPLEX):	GOSUB CompareSCOMPLEX
		CASE (ot = $$DCOMPLEX):	GOSUB CompareDCOMPLEX
		CASE ELSE:							GOTO  eeeTypeMismatch
	END SELECT
END SUB

SUB CompareLong
	Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i684a")
END SUB


' Note GIANT routines completed in specific condition tests

SUB CompareGiant
	Code ($$cmp, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i685a")
END SUB

SUB CompareFloat
	Code ($$fcompp, 0, 0, 0, 0, $$DOUBLE, @"", @"	;;; i686b")
	IF a0 THEN Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i686c")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i686d")
	Code ($$sahf, 0, 0, 0, 0, $$XLONG, @"", @"	;;; i686e")
	IF a0 THEN Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, @"", @"	;;; i686f")
END SUB

SUB CompareString
	IFZ revOp THEN
		ooos$	= CHR$(oos[oos-1]) + CHR$(oos[oos])
		IF ((ras != $$RA0) OR (rax != $$RA1)) THEN GOTO eeeCompiler
	ELSE
		ooos$	= CHR$(oos[oos]) + CHR$(oos[oos-1])
		IF ((ras != $$RA1) OR (rax != $$RA0)) THEN GOTO eeeCompiler
	ENDIF
	d1$ = "%_string.compare." + ooos$
	Code ($$call, $$rel, 0, 0, 0, 0, @d1$, @"	;;; i690")
	oos = oos - 2
END SUB

SUB CompareSCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_compare.SCOMPLEX", @"	;;; i692")
END SUB

SUB CompareDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, $$XLONG, @"%_compare.DCOMPLEX", @"	;;; i694")
END SUB


' *********************
' *****  COMPARE  *****
' *********************

test_EQ:
	IF (ot = $$GIANT) THEN
		d1$ = CreateLabel$ ()
		Code ($$jne, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i695")
		Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i696")
		EmitLabel (@d1$)
		the_op = $$o2
	ELSE
		the_op = $$o2
	ENDIF
	RETURN

test_NE:
	IF (ot = $$GIANT) THEN
		d1$ = CreateLabel$ ()
		Code ($$jne, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i697")
		Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i698")
		EmitLabel (@d1$)
		the_op = $$o3
	ELSE
		the_op = $$o3
	ENDIF
	RETURN

test_LT:
	SELECT CASE ot
		CASE $$GIANT:
					d1$ = CreateLabel$ ()
					d2$ = CreateLabel$ ()
					d3$ = CreateLabel$ ()
					IF revOp THEN
						op1 = $$jg	: op2 = $$jbe
					ELSE
						op1 = $$jl	: op2 = $$jae
					ENDIF
					Code ($$je, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i700")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op1, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i701")
					Code ($$jmp, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i702")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i703")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op2, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i704")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i705")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o8 ELSE the_op = $$o10
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
					IF revOp THEN the_op = $$o10 ELSE the_op = $$o8
		CASE ELSE
					IF revOp THEN the_op = $$o4 ELSE the_op = $$o6
	END SELECT
	RETURN

test_LE:
	SELECT CASE ot
		CASE $$GIANT:
					d1$ = CreateLabel$ ()
					d2$ = CreateLabel$ ()
					d3$ = CreateLabel$ ()
					IF revOp THEN
						op1 = $$jge	: op2 = $$jb
					ELSE
						op1 = $$jle	: op2 = $$ja
					ENDIF
					Code ($$je, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i707")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op1, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i708")
					Code ($$jmp, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i709")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i710")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op2, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i711")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i712")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o11 ELSE the_op = $$o9
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
					IF revOp THEN the_op = $$o9 ELSE the_op = $$o11
		CASE ELSE
					IF revOp THEN the_op = $$o7 ELSE the_op = $$o5
	END SELECT
	RETURN

test_GE:
	SELECT CASE ot
		CASE $$GIANT:
					d1$ = CreateLabel$ ()
					d2$ = CreateLabel$ ()
					d3$ = CreateLabel$ ()
					IF revOp THEN
						op1 = $$jle	: op2 = $$ja
					ELSE
						op1 = $$jge	: op2 = $$jb
					ENDIF
					Code ($$je, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i714")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op1, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i715")
					Code ($$jmp, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i716")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i717")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op2, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i718")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i719")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o9 ELSE the_op = $$o11
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
					IF revOp THEN the_op = $$o11 ELSE the_op = $$o9
		CASE ELSE
					IF revOp THEN the_op = $$o5 ELSE the_op = $$o7
	END SELECT
	RETURN

test_GT:
	SELECT CASE ot
		CASE $$GIANT:
					d1$ = CreateLabel$ ()
					d2$ = CreateLabel$ ()
					d3$ = CreateLabel$ ()
					IF revOp THEN
						op1 = $$jl	: op2 = $$jae
					ELSE
						op1 = $$jg	: op2 = $$jbe
					ENDIF
					Code ($$je, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i721")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op1, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i722")
					Code ($$jmp, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i723")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i724")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, @"", @"")
					Code (op2, $$rel, 0, 0, 0, 0, "> " + d3$, @"	;;; i725")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i726")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o10 ELSE the_op = $$o8
		CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
					IF revOp THEN the_op = $$o8 ELSE the_op = $$o10
		CASE ELSE
					IF revOp THEN the_op = $$o6 ELSE the_op = $$o4
	END SELECT
	RETURN


' ************************
' *****  logical OR  *****
' ************************

logical_or:
	SELECT CASE ot
		CASE $$GIANT:	GOSUB Logical_OR_GIANT
		CASE ELSE:		GOSUB Logical_OR_LONG
	END SELECT
	the_op = 0
	RETURN

SUB Logical_OR_GIANT
	Code ($$or, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i727")
	Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i728")
	Code ($$or, mode, s_reg, x_regx, 0, $$XLONG, @"", @"	;;; i729")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, @"", @"	;;; i736")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, @"", @"	;;; i737")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, @"", @"	;;; i738")
END SUB

SUB Logical_OR_LONG
	Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i732")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, @"", @"	;;; i736")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, @"", @"	;;; i737")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, @"", @"	;;; i738")
END SUB


' *************************
' *****  logical XOR  *****
' *************************

logical_xor:
	SELECT CASE ot
		CASE $$GIANT:	GOSUB Logical_XOR_GIANT
		CASE ELSE:		GOSUB Logical_XOR_LONG
	END SELECT
	the_op = 0
	RETURN

SUB Logical_XOR_GIANT
	Code ($$or, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i735")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, @"", @"	;;; i736")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, @"", @"	;;; i737")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, @"", @"	;;; i738")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, @"", @"	;;; i739")
	Code ($$or, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i740")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, @"", @"	;;; i741")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, @"", @"	;;; i742")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, @"", @"	;;; i743")
	Code ($$xor, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i744")
END SUB

SUB Logical_XOR_LONG
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, @"", @"	;;; i745")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, @"", @"	;;; i746")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, @"", @"	;;; i747")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, @"", @"	;;; i748")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, @"", @"	;;; i749")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, @"", @"	;;; i750")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, @"", @"	;;; i751")
	Code ($$xor, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i752")
END SUB


' *************************
' *****  logical AND  *****
' *************************

logical_and:
	SELECT CASE ot
		CASE $$GIANT:	GOSUB Logical_AND_GIANT
		CASE ELSE:		GOSUB Logical_AND_LONG
	END SELECT
	the_op = 0
	RETURN

SUB Logical_AND_GIANT
	Code ($$or, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i735")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, @"", @"	;;; i736")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, @"", @"	;;; i737")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, @"", @"	;;; i738")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, @"", @"	;;; i739")
	Code ($$or, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i740")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, @"", @"	;;; i741")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, @"", @"	;;; i742")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, @"", @"	;;; i743")
	Code ($$and, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i744")
END SUB

SUB Logical_AND_LONG
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, @"", @"	;;; i745")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, @"", @"	;;; i746")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, @"", @"	;;; i747")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, @"", @"	;;; i748")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, @"", @"	;;; i749")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, @"", @"	;;; i750")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, @"", @"	;;; i751")
	Code ($$and, $$regreg, s_reg, s_regx, 0, $$XLONG, @"", @"	;;; i752")
END SUB


' ************************
' *****  bitwise OR  *****
' ************************

bitwise_or:
	SELECT CASE ot
		CASE $$GIANT
					Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i761")
					Code ($$or, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i762")
		CASE ELSE
					Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i763")
	END SELECT
	the_op = 0
	RETURN


' *************************
' *****  bitwise XOR  *****
' *************************

bitwise_xor:
	SELECT CASE ot
		CASE $$GIANT
					Code ($$xor, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i764")
					Code ($$xor, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i765")
		CASE ELSE
					Code ($$xor, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i766")
	END SELECT
	the_op = 0
	RETURN


' *************************
' *****  bitwise AND  *****
' *************************

bitwise_and:
	SELECT CASE ot
		CASE $$GIANT
					Code ($$and, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i767")
					Code ($$and, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i768")
		CASE ELSE
					Code ($$and, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i769")
	END SELECT
	the_op = 0
	RETURN


' **********************
' *****  ADDITION  *****
' **********************

add:
	op = $$add
	SELECT CASE ot
		CASE $$SLONG:			GOSUB AddSLONG
		CASE $$ULONG:			GOSUB AddULONG
		CASE $$XLONG:			GOSUB AddXLONG
		CASE $$GIANT:			GOSUB AddGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$LONGDOUBLE:	GOSUB type_stuff
		CASE $$STRING:		GOSUB Concatenate
		CASE $$SCOMPLEX:	GOSUB AddSCOMPLEX
		CASE $$DCOMPLEX:	GOSUB AddDCOMPLEX
		CASE ELSE:				GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN

SUB AddSLONG
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i770")
	Code ($$into, 0, 0, 0, 0, 0, @"", @"	;;; i771")
END SUB

SUB AddULONG
	d1$ = CreateLabel$ ()
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i772")
	Code ($$jnc, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i773")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i774")
	EmitLabel (@d1$)
END SUB

SUB AddXLONG
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i775")
END SUB

SUB AddGIANT
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i776")
	Code ($$adc, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i777")
	Code ($$into, 0, 0, 0, 0, 0, @"", @"	;;; i778")
END SUB

SUB AddSCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_add.SCOMPLEX", @"	;;; i779")
END SUB

SUB AddDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_add.DCOMPLEX", @"	;;; i780")
END SUB

SUB Concatenate
	IF (ot != $$STRING) THEN GOTO eeeTypeMismatch
	ooos$		= CHR$(oos[oos-1]) + CHR$(oos[oos])
	IF revOp THEN
		dx$	= "%_concat.ubyte.a0.eq.a1.plus.a0." + ooos$
	ELSE
		dx$	= "%_concat.ubyte.a0.eq.a0.plus.a1." + ooos$
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, dx$, @"	;;; i782")
	DEC oos
	oos[oos] = 's'
	the_op = 0
END SUB


' *************************
' *****  SUBTRACTION  *****
' *************************

subtract:
	op = $$sub
	SELECT CASE ot
		CASE $$SLONG:			GOSUB SubtractSLONG
		CASE $$ULONG:			GOSUB SubtractULONG
		CASE $$XLONG:			GOSUB SubtractXLONG
		CASE $$GIANT:			GOSUB SubtractGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$LONGDOUBLE: GOSUB type_stuff
		CASE $$SCOMPLEX:	GOSUB SubtractSCOMPLEX
		CASE $$DCOMPLEX:	GOSUB SubtractDCOMPLEX
		CASE ELSE:				GOTO  eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN

SUB SubtractSLONG
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i783")
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i784")
	Code ($$into, 0, 0, 0, 0, 0, @d1$, @"	;;; i785")
END SUB

SUB SubtractULONG
	d1$ = CreateLabel$ ()
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i786")
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i787")
	Code ($$jnc, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i788")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i789")
	EmitLabel (@d1$)
END SUB

SUB SubtractXLONG
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i790")
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i791")
END SUB

SUB SubtractGIANT
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i792")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i793")
	ENDIF
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i794")
	Code ($$sbb, mode, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i795")
	Code ($$into, 0, 0, 0, 0, 0, @"", @"	;;; i796")
END SUB

SUB SubtractSCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_sub.SCOMPLEX", @"	;;; i798")
END SUB

SUB SubtractDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_sub.DCOMPLEX", @"	;;; i800")
END SUB


' ****************************
' *****  MULTIPLICATION  *****
' ****************************

multiply:
	op = $$mul
	SELECT CASE ot
		CASE $$SLONG:			GOSUB MultiplySLONG
		CASE $$ULONG:			GOSUB MultiplyULONG
		CASE $$XLONG:			GOSUB MultiplyXLONG
		CASE $$GIANT:			GOSUB MultiplyGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$LONGDOUBLE:	GOSUB type_stuff
		CASE $$SCOMPLEX:	GOSUB MultiplySCOMPLEX
		CASE $$DCOMPLEX:	GOSUB MultiplyDCOMPLEX
		CASE ELSE:				GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN

SUB MultiplySLONG
	d1$ = CreateLabel$ ()
	Code ($$imul, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i801")
	Code ($$jnc, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i802")
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_eeeOverflow", @"	;;; i803")
	EmitLabel (@d1$)
END SUB

SUB MultiplyULONG
	Code ($$imul, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i804")
END SUB

SUB MultiplyXLONG
	Code ($$imul, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i805")
END SUB

SUB MultiplyGIANT
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_mul.GIANT", @"	;;; i806")
END SUB

SUB MultiplySCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_mul.SCOMPLEX", @"	;;; i807")
END SUB

SUB MultiplyDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_mul.DCOMPLEX", @"	;;; i808")
END SUB


' *********************************************
' *****  DIVISION  *****  FLOATING POINT  *****
' *********************************************

divide:
	op = $$div
	SELECT CASE ot
		CASE $$SLONG:			GOSUB DivideSLONG
		CASE $$ULONG:			GOSUB DivideULONG
		CASE $$XLONG:			GOSUB DivideSLONG
		CASE $$GIANT:			GOSUB DivideGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$LONGDOUBLE:	GOSUB type_stuff
		CASE $$SCOMPLEX:	GOSUB DivideSCOMPLEX
		CASE $$DCOMPLEX:	GOSUB DivideDCOMPLEX
		CASE ELSE:  			GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN

SUB DivideSLONG
	wierdOp = $$idiv
	GOSUB WierdOp
END SUB

SUB DivideULONG
	wierdOp = $$div
	GOSUB WierdOp
END SUB

SUB DivideGIANT
	IF (s_reg = $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i813a")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i813b")
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_div.GIANT", @"	;;; i815")
	IF (s_reg = $$RA1) THEN
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i814a")
		Code ($$mov, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i814b")
	ENDIF
END SUB

SUB DivideSCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_div.SCOMPLEX", @"	;;; i817")
END SUB

SUB DivideDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_div.DCOMPLEX", @"	;;; i819")
END SUB


' ****************************
' *****  INTEGER DIVIDE  *****
' ****************************

integer_divide:
	op = $$div
	SELECT CASE ot
		CASE $$SLONG:	GOSUB IntegerDivideSLONG
		CASE $$ULONG:	GOSUB IntegerDivideULONG
		CASE $$XLONG:	GOSUB IntegerDivideSLONG
		CASE $$GIANT:	GOSUB	IntegerDivideGIANT
		CASE ELSE:		GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN

SUB IntegerDivideSLONG
	wierdOp	= $$idiv
	GOSUB WierdOp
END SUB

SUB IntegerDivideULONG
	wierdOp = $$div
	GOSUB WierdOp
END SUB

SUB IntegerDivideGIANT
	IF (s_reg = $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i813a")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i813b")
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_div.GIANT", @"	;;; i815")
	IF (s_reg = $$RA1) THEN
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i814a")
		Code ($$mov, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i814b")
	ENDIF
END SUB



' *****************************
' *****  INTEGER MODULUS  *****  result = x - (x\y * y)
' *****************************

integer_modulus:
	orderCounts = $$TRUE
	SELECT CASE ot
		CASE $$SLONG:	GOSUB IntegerModulusSLONG
		CASE $$ULONG:	GOSUB IntegerModulusULONG
		CASE $$XLONG:	GOSUB IntegerModulusSLONG
		CASE $$GIANT:	GOSUB IntegerModulusGIANT
		CASE ELSE:		GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN

SUB IntegerModulusSLONG
	wierdOp = $$idiv
	GOSUB WierdOp
	Code ($$mov, $$regreg, s_reg, $$edx, 0, $$XLONG, @"", @"	;;; i828")
END SUB

SUB IntegerModulusULONG
	wierdOp = $$div
	GOSUB WierdOp
	Code ($$mov, $$regreg, s_reg, $$edx, 0, $$XLONG, @"", @"	;;; i830")
END SUB

SUB IntegerModulusGIANT
	IF (s_reg = $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i833a")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i833b")
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_mod.GIANT", @"	;;; i833c")
	IF (s_reg = $$RA1) THEN
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i833d")
		Code ($$mov, $$regreg, s_regx, x_regx, 0, $$XLONG, @"", @"	;;; i833e")
	ENDIF
END SUB



SUB WierdOp
	SELECT CASE mode
		CASE $$regreg:	mode = $$reg
		CASE $$regimm:	Code ($$mov, $$regimm, $$esi, x_reg, 0, $$XLONG, @"", @"")
										mode = $$reg
										x_reg = $$esi
		CASE ELSE:			PRINT "wierdOp": GOTO eeeCompiler
	END SELECT
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i822")
	IF (s_reg != $$eax) THEN
		Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, $$eax, s_reg, 0, $$XLONG, @"", @"")
		SELECT CASE wierdOp
			CASE	$$idiv:	Code ($$cdq, $$none, 0, 0, 0, $$XLONG, @"", @"")
			CASE	$$div:	Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, @"", @"")
		END SELECT
		Code (wierdOp, $$reg, x_reg, 0, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, s_reg, $$eax, 0, $$XLONG, @"", @"")
		Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
	ELSE
		SELECT CASE wierdOp
			CASE	$$idiv:	Code ($$cdq, $$none, 0, 0, 0, $$XLONG, @"", @"")
			CASE	$$div:	Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, @"", @"")
		END SELECT
		Code (wierdOp, $$reg, x_reg, 0, 0, $$XLONG, @"", @"")
	ENDIF
END SUB

' ****************************
' *****  RAISE TO POWER  *****  (x ** y) = raise "x" to the power "y"
' ****************************

power:
	IF (s_reg == $$RA1) AND ((ot != $$SINGLE) AND (ot != $$DOUBLE) AND (ot != $$LONGDOUBLE)) THEN revOp = NOT revOp
	IF revOp THEN
		dx$ = "%_rpower." + typeName$[ot]
	ELSE
		dx$ = "%_power." + typeName$[ot]
	ENDIF

	SELECT CASE ot
		CASE $$SLONG, $$ULONG, $$XLONG
			IF (mode == $$regimm) THEN
				IF revOp THEN
					Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
					Code ($$mov, $$regimm, $$eax, x_reg, 0, $$XLONG, @"", @"")
				ELSE
					Code ($$mov, $$regimm, $$ebx, x_reg, 0, $$XLONG, @"", @"")
				ENDIF
			ENDIF
		CASE $$GIANT, $$SINGLE, $$DOUBLE
		CASE  ELSE:		PRINT "op12a": GOTO eeeCompiler
	END SELECT
	Code ($$call, $$rel, 0, 0, 0, 0, @dx$, @"	;;; i834")
	IF (s_reg == $$RA1) THEN
		SELECT CASE ot
			CASE $$SINGLE, $$DOUBLE		' hopefully no problem - in coprocessor
			CASE $$GIANT							: Code ($$mov, $$regreg, $$ebx, $$eax, 0, $$XLONG, @"", @"")
																	Code ($$mov, $$regreg, $$ecx, $$edx, 0, $$XLONG, @"", @"")
			CASE ELSE									: Code ($$mov, $$regreg, $$ebx, $$eax, 0, $$XLONG, @"", @"")
		END SELECT
	ENDIF
	IF (mode == $$regimm) THEN
		IF revOp THEN
			Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
		ENDIF
	ENDIF
	the_op = 0
	RETURN


' *********************************
' *****  BITWISE SHIFT RIGHT  *****  RIGHT SHIFT  *****  carry in zeros
' *********************************

right_shift:
	IF (ot = $$GIANT) THEN routine$ = "%_rshift.giant": GOTO gshift
	shop = $$shr
	GOTO xshift


' ********************************
' *****  BITWISE SHIFT LEFT  *****  LEFT SHIFT  *****  carry in zeros
' ********************************

left_shift:
	IF (ot = $$GIANT) THEN routine$ = "%_lshift.giant": GOTO gshift
	shop = $$shl
	GOTO xshift


' *********************************
' *****  ARITHMETIC SHIFT UP  *****  UP SHIFT  *****  carry in zeros
' *********************************

up_shift:
	IF (ot = $$GIANT) THEN routine$ = "%_ushift.giant": GOTO gshift
	shop = $$sal
	GOTO xshift


' ***********************************
' *****  ARITHMETIC SHIFT DOWN  *****  DOWN SHIFT  *****  sign extend msb
' ***********************************

down_shift:
	IF (ot = $$GIANT) THEN routine$ = "%_dshift.giant": GOTO gshift
	shop = $$sar
	GOTO xshift



xshift:
	IF revOp THEN
		IF (mode = $$regimm) THEN PRINT "revOp": GOTO eeeCompiler
		Code ($$mov, $$regreg, $$ecx, s_reg, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, @"", @"")
		x_reg = $$cl
	ENDIF
	SELECT CASE mode
		CASE $$regimm
					Code (shop, mode, s_reg, x_reg, 0, $$XLONG, @"", @"	;;; i835")
		CASE $$regreg
					IF ((x_reg != $$ecx) AND (x_reg != $$cl)) THEN
						Code ($$mov, $$regreg, $$ecx, x_reg, 0, $$XLONG, @"", @"")
					ENDIF
					Code (shop, $$regreg, s_reg, $$cl, 0, $$XLONG, @"", @"")
		CASE ELSE
					GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN


' *************************************************************
' *****  GIANT upshift, downshift, leftshift, rightshift  *****
' *************************************************************

gshift:
	IF (s_reg = $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$mov, $$regreg, $$edx, $$ecx, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, $$ecx, $$eax, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, $$eax, $$ebx, 0, $$XLONG, @"", @"")
	ELSE
		Code ($$mov, mode, $$ecx, x_reg, 0, $$XLONG, @"", @"")
	ENDIF
	Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i839")
	IF (s_reg = $$RA1) THEN
		Code ($$mov, $$regreg, $$ebx, $$eax, 0, $$XLONG, @"", @"")
		Code ($$mov, $$regreg, $$ecx, $$edx, 0, $$XLONG, @"", @"")
	ENDIF
	the_op = 0
	RETURN


' Set up types of floating point result and two floating point operands

SUB type_stuff

	SELECT CASE op
		CASE $$add:	op486 = $$fadd
		CASE $$sub:	op486 = $$fsub:	IF revOp THEN op486 = $$fsubr
		CASE $$mul:	op486 = $$fmul
		CASE $$div: op486 = $$fdiv:	IF revOp THEN op486 = $$fdivr
		CASE ELSE:	PRINT "??? No such floating point operator ???"
	END SELECT
	IF ot = $$LONGDOUBLE THEN
		Code (op486, 0, 0, 0, 0, $$LONGDOUBLE, @"", @"	;;; i841")
	ELSE
		Code (op486, 0, 0, 0, 0, $$DOUBLE, @"", @"	;;; i841")
	ENDIF
END SUB




' ****************************************************************
' *****  Load opToken[] with addresses of operator routines  *****
' ****************************************************************

SUB LoadOpToken
	DIM opToken[255]
	opToken [ T_ORL				AND 0x00FF ] = GOADDRESS (op_logical_or)
	opToken [ T_XORL			AND 0x00FF ] = GOADDRESS (op_logical_xor)
	opToken [ T_ANDL			AND 0x00FF ] = GOADDRESS (op_logical_and)
	opToken [ T_CMP				AND 0x00FF ] = GOADDRESS (op_cmp)
	opToken [ T_EQL				AND 0x00FF ] = GOADDRESS (op_test_EQ)
	opToken [ T_EQ				AND 0x00FF ] = GOADDRESS (op_test_EQ)
	opToken [ T_NNE				AND 0x00FF ] = GOADDRESS (op_test_EQ)
	opToken [ T_NE				AND 0x00FF ] = GOADDRESS (op_test_NE)
	opToken [ T_NEQ				AND 0x00FF ] = GOADDRESS (op_test_NE)
	opToken [ T_LT				AND 0x00FF ] = GOADDRESS (op_test_LT)
	opToken [ T_NGE				AND 0x00FF ] = GOADDRESS (op_test_LT)
	opToken [ T_LE				AND 0x00FF ] = GOADDRESS (op_test_LE)
	opToken [ T_NGT				AND 0x00FF ] = GOADDRESS (op_test_LE)
	opToken [ T_GE				AND 0x00FF ] = GOADDRESS (op_test_GE)
	opToken [ T_NLT				AND 0x00FF ] = GOADDRESS (op_test_GE)
	opToken [ T_GT				AND 0x00FF ] = GOADDRESS (op_test_GT)
	opToken [ T_NLE				AND 0x00FF ] = GOADDRESS (op_test_GT)
	opToken [ T_OR				AND 0x00FF ] = GOADDRESS (op_orbit)
	opToken [ T_ORBIT			AND 0x00FF ] = GOADDRESS (op_orbit)
	opToken [ T_XOR				AND 0x00FF ] = GOADDRESS (op_xorbit)
	opToken [ T_XORBIT		AND 0x00FF ] = GOADDRESS (op_xorbit)
	opToken [ T_AND				AND 0x00FF ] = GOADDRESS (op_andbit)
	opToken [ T_ANDBIT		AND 0x00FF ] = GOADDRESS (op_andbit)
	opToken [ T_SUBTRACT	AND 0x00FF ] = GOADDRESS (op_subtract)
	opToken [ T_ADD				AND 0x00FF ] = GOADDRESS (op_add)
	opToken [ T_MOD				AND 0x00FF ] = GOADDRESS (op_integer_mod)
	opToken [ T_IDIV			AND 0x00FF ] = GOADDRESS (op_integer_div)
	opToken [ T_MUL				AND 0x00FF ] = GOADDRESS (op_multiply)
	opToken [ T_DIV				AND 0x00FF ] = GOADDRESS (op_divide)
	opToken [ T_POWER			AND 0x00FF ] = GOADDRESS (op_power)
	opToken [ T_RSHIFT		AND 0x00FF ] = GOADDRESS (op_right_shift)
	opToken [ T_LSHIFT		AND 0x00FF ] = GOADDRESS (op_left_shift)
	opToken [ T_DSHIFT		AND 0x00FF ] = GOADDRESS (op_down_shift)
	opToken [ T_USHIFT		AND 0x00FF ] = GOADDRESS (op_up_shift)
END SUB


' ************************************
' *****  BINARY OPERATOR ERRORS  *****
' ************************************

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ###############################
' #####  OpenAccForType ()  #####
' ###############################

FUNCTION  OpenAccForType (theType)
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  a0,  a0_type,  a1,  a1_type

	IFZ a0 THEN GOTO open0
	IFZ a1 THEN GOTO open1
	IF (a0 < a1) THEN Push ($$RA0, a0_type): GOTO open0
	IF (a0 > a1) THEN Push ($$RA1, a1_type): GOTO open1
	GOTO eeeCompiler

open0:	INC toes: a0 = toes: a0_type = theType: RETURN ($$RA0)
open1:	INC toes: a1 = toes: a1_type = theType: RETURN ($$RA1)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #############################
' #####  OpenBothAccs ()  #####
' #############################

FUNCTION  OpenBothAccs ()
	SHARED	a0,  a0_type,  a1,  a1_type,  toes

	IFZ toes THEN RETURN						' nothing on stack
	IFZ (a0 OR a1) THEN RETURN			' nothing in stack registers
	IF a0 AND (a0 < a1) THEN
		Push($$RA0, a0_type)
		a0 = 0: a0_type = 0
	ENDIF
	IF a1 THEN
		Push($$RA1, a1_type)
		a1 = 0: a1_type = 0
	ENDIF
	IF a0 THEN
		Push($$RA0, a0_type)
		a0 = 0: a0_type = 0
	ENDIF
	RETURN
END FUNCTION


' ##########################
' #####  ParseChar ()  #####
' ##########################

FUNCTION  ParseChar ()
	SHARED	tab_sym[],  tokens[],  charToken[]
	SHARED	charpos[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_TESTL
	SHARED	T_NOT,      T_NOTL,       T_NOTBIT,     T_TILDA
	SHARED	T_AND,      T_ANDL,       T_ANDBIT
	SHARED	T_XOR,      T_XORL,       T_XORBIT
	SHARED	T_OR,       T_ORL,        T_ORBIT
	SHARED	T_ADDR_OP,  T_HANDLE_OP
	SHARED	T_EQ,   T_NE,   T_LT,   T_LE,   T_GE,   T_GT,   T_EQL
	SHARED	T_NEQ,  T_NNE,  T_NLT,  T_NLE,  T_NGE,  T_NGT
	SHARED	T_ADD,  T_ATSIGN,  T_COLON,  T_COMMA
	SHARED	T_DIV,  T_DOLLAR,  T_DSHIFT
	SHARED	T_ETC,  T_IDIV
	SHARED	T_DOT,  T_LBRACE,  T_LBRACES,  T_LBRAK,  T_LPAREN,  T_LSHIFT
	SHARED	T_MARK,  T_MUL,  T_PERCENT,  T_POUND,  T_POWER,  T_QMARK
	SHARED	T_RBRACE,  T_RBRAK,  T_REM,  T_RPAREN,  T_RSHIFT
	SHARED	T_SEMI,  T_SUBTRACT,  T_TICK,  T_ULINE,  T_USHIFT,  T_XMARK
	SHARED	nullstring$,  nullstringer,  rawLength,  rawline$
	SHARED	func_number,  charPtr,  tokenPtr,  lastToken
	SHARED UBYTE  charsetNumeric[],  charsetUpperLower[],  charsetBackslash[]
	STATIC GOADDR parseChar[]

	IFZ parseChar[] THEN GOSUB LoadParseChar
	charV = rawline${charPtr}
	INC charPtr
	GOTO @parseChar [charV]					' GOTO routine to parse this character
	PRINT "ParseChar"								' there is no routine for invalid characters
	GOTO eeeCompiler								' so log an error message



pc_token:
	token = charToken[charV]				' get token for this character
	ParseOutToken (token)						' output token to token list
	RETURN (token)									' return token


' *************************************************************************
' *****  Parse characters that may be part of 1+ character sequences  *****
' *************************************************************************


' *****  !  *****  !   !!   !=   !<   !<=   !>=   !>

l_not_test:
	charV = rawline${charPtr}
	SELECT CASE	charV
		CASE '!':		token = T_TESTL
								INC charPtr
		CASE '=':		token = T_NEQ
								INC charPtr
		CASE '<':		INC charPtr
								charV = rawline${charPtr}
								IF (charV = '=') THEN
									token = T_NLE
									INC charPtr
								ELSE
									IF (charV = '>') THEN
										token = T_NNE
										INC charPtr
									ELSE
										token = T_NLT
									ENDIF
								ENDIF
		CASE '>':		INC charPtr
								charV = rawline${charPtr}
								IF (charV = '=') THEN
									token = T_NGE
									INC charPtr
								ELSE
									token = T_NGT
								ENDIF
		CASE ELSE:  token = T_NOTL
	END SELECT
	ParseOutToken (token)
	RETURN (token)


' *****  "  *****  Literal string  *****

double_quote:
	scans = charPtr				' 0 offset to character after opening double-quote
	start = charPtr				' 1 offset to opening double-quote
 	final = rawLength			' 0 offset to null-terminator
	IF (scans < final) THEN
		rawChar = rawline${scans}
		DO UNTIL (rawChar = '"')
			IF (rawChar = '\\') THEN
				INC scans
				rawChar = rawline${scans}
			ENDIF
			INC scans
			rawChar = rawline${scans}
		LOOP WHILE (scans < final)
	ENDIF
	IF (scans < final) THEN
		INC scans
		charPtr = scans		' terminated by "  (normal case)
	ELSE
		charPtr	= scans		' terminated by null, not "
		INC scans
	ENDIF
	lit$ = MID$(rawline$, start, (scans-start)) + "\""

'  The literal string is in lit$

	token = $$T_LITERALS + ($$EXTERNAL << 21) + ($$STRING << 16)
	IF (lit$ = nullstring$) THEN
		token = tab_sym[nullstringer]
	ELSE
		token = AddSymbol (@lit$, token, func_number)
	ENDIF
	ParseOutToken (token)
	RETURN (token)


' *****  &  *****  & = addr.op:  && = and.op:  && = handle.op

amper:
	charV = rawline${charPtr}
	IF (charV = '&') THEN
		INC charPtr
		charV = rawline${charPtr}
		token = T_ANDL								' && = logical AND or handle operator
	ELSE
		token = T_ANDBIT							' &  = bitwise AND or address operator
	ENDIF
	ParseOutToken (token)
	RETURN (token)


' *****  '  *****

remark:
	IFZ tokenPtr THEN GOTO sendRemark							' first token ' is a remark
	charV = rawline${charPtr}											' 1st byte of comment / charcon
	IFZ charV THEN																' nothing after ' character, so
		token = T_REM																'     ...it's an empty comment
		ParseOutToken (token)												' Add comment to token list
		RETURN (token)															' that's all folks
	ELSE																					' comment or charcon follows
		IF charV THEN charW = rawline${charPtr+1}		' 2nd byte of comment or charcon
		IF charW THEN charX = rawline${charPtr+2}		' 3rd byte of comment or charcon
		IF charX THEN charY = rawline${charPtr+3}		' 4th byte of comment or charcon
		SELECT CASE TRUE
			CASE ((charW = ''') AND (charV != '\\')):	 c = 3	'  '?'   charcon
			CASE ((charV = '\\') AND (charX = ''')) :	 c = 4	'  '\?'  charcon
			CASE ELSE:	GOTO sendRemark												'  comment, not charcon
		END SELECT
	ENDIF

' It's a charcon  ( '?'  ...or...  '\?' )

	clit$ = MID$(rawline$, charPtr, c)
	token = $$T_CHARCONS + ($$SHARED << 21) + ($$UBYTE << 16)
	token = AddSymbol (@clit$, token, func_number)
	charPtr = charPtr + c - 1
	ParseOutToken (token)
	RETURN (token)

sendRemark:
	length = (rawLength - charPtr)							' Length of comment in bytes
	IF (length < 255) THEN											' imbed length in token
		token = T_REM OR (length << 16)						' Build complete token
		INC tokenPtr															' move to next token
		tokens[tokenPtr] = token									' Add remark token to token list
	ELSE
		token = T_REM OR 0x00FF0000								' length = 255 means length in next 32-bit token
		INC tokenPtr															' move to next token
		tokens[tokenPtr] = token									' add remark token to token list
		INC tokenPtr															' move to next token
		tokens[tokenPtr] = length									' add remark length to token list
	ENDIF
	TokenRestOfLine ()													' Tokenize rest of comment
	RETURN (token)


' #####  *  #####  *   **

star:
	charV = rawline${charPtr}
	IF (charV = '*') THEN
		token = T_POWER
		INC charPtr
	ELSE
		token = T_MUL
	ENDIF
	ParseOutToken (token)
	RETURN (token)


' *****  .  *****   "..."  or  ".2345e3" (a number)  or  ".COMPONENTNAME"

dot:
	afterDot = rawline${charPtr}
	IF (afterDot = '.') THEN
		afterAfterDot = rawline${charPtr+1}
		IF (afterAfterDot = '.') THEN
			charPtr = charPtr + 2
			token = T_ETC
			ParseOutToken (token)
			RETURN (token)
		ELSE
			INC charPtr
			ParseOutToken (T_DOT)
			ParseOutToken (T_DOT)
			RETURN (T_DOT)
		ENDIF
	ELSE
		SELECT CASE TRUE
			CASE charsetNumeric[afterDot]
						DEC charPtr
						token = ParseNumber()
						RETURN (token)
			CASE charsetUpperLower[afterDot]
						DEC charPtr
						token = ParseSymbol()
						RETURN (token)
			CASE ELSE
						token = T_DOT
						ParseOutToken (token)
						RETURN (token)
			END SELECT
	ENDIF


' *****  <  *****   <   <>   <=   <<   <<<

less_than:
	charV = rawline${charPtr}													' char after "<"
	SELECT CASE charV
		CASE '>':		token = T_NE:			INC charPtr				' <>
		CASE '=':		token = T_LE:			INC charPtr				' <=
		CASE '<':		token = T_LSHIFT:	INC charPtr				' <<  (or <<< maybe)
								charV = rawline${charPtr}						' what's after "<<"
								IF (charV = '<') THEN								' another "<" ???
									token = T_USHIFT									' <<<
									INC charPtr												' past last "<"
								ENDIF
		CASE ELSE:	token = T_LT												' <
	END SELECT
	ParseOutToken (token)
	RETURN (token)


' *****  =  *****  =   ==

equals:
	charV = rawline${charPtr}
	IF (charV = '=') THEN
		token = T_EQL
		INC charPtr
	ELSE
		token = T_EQ
	ENDIF
	ParseOutToken (token)
	RETURN (token)


' *****  >  *****  ><   >=   >>   >>>

greater_than:
	charV = rawline${charPtr}
	SELECT CASE charV
		CASE '=':		token = T_GE:				INC charPtr					' >=
		CASE '<':		token = T_NE:				INC charPtr					' <>
		CASE '>':		token = T_RSHIFT:		INC charPtr					' >>
								charV = rawline${charPtr}
								IF (charV = '>') THEN
									token = T_DSHIFT											' >>>
									INC charPtr
								ENDIF
		CASE ELSE:	token = T_GT														' >
	END SELECT
	ParseOutToken (token)
	RETURN (token)


' *****  ?  *****

question:
	ParseOutToken (T_QMARK)											' just "?" character
	RETURN (T_QMARK)


' *****  ^  *****   ^   ^^

upper:
	charV = rawline${charPtr}
	IF (charV = '^') THEN
		token = T_XORL
		INC charPtr
	ELSE
		token = T_XORBIT
	ENDIF
	ParseOutToken (token)
	RETURN (token)


' *****  {  *****  {   {{

lbrace:
	charV = rawline${charPtr}
	IF (charV = '{') THEN
		token = T_LBRACES
		INC charPtr
	ELSE
		token = T_LBRACE
	ENDIF
	ParseOutToken (token)
	RETURN (token)


' *****  |  *****  |   ||

vbar:
	charV = rawline${charPtr}
	IF (charV = '|') THEN
		token = T_ORL
		INC charPtr
	ELSE
		token = T_ORBIT
	ENDIF
	ParseOutToken (token)
	RETURN (token)



' *****************************************************************************
' *****  Load parseChar[] with addresses of routines to parse characters  *****
' *****************************************************************************

SUB LoadParseChar
	DIM parseChar[255]
'																								'    00-32 handled elsewhere
	parseChar [  33 ] = GOADDRESS (l_not_test)		'  !  !!  !=  !<  !<=  !>=  !>
	parseChar [  34 ] = GOADDRESS (double_quote)	'  "
	parseChar [  35 ] = GOADDRESS (pc_token)			'  #  T_POUND
	parseChar [  36 ] = GOADDRESS (pc_token)			'  $  T_DOLLAR
	parseChar [  37 ] = GOADDRESS (pc_token)			'  %  T_PERCENT
	parseChar [  38 ] = GOADDRESS (amper)					'  &  &&
	parseChar [  39 ] = GOADDRESS (remark)				'
	parseChar [  40 ] = GOADDRESS (pc_token)			'  (  T_LPAREN
	parseChar [  41 ] = GOADDRESS (pc_token)			'  )  T_RPAREN
	parseChar [  42 ] = GOADDRESS (star)					'  *  **
	parseChar [  43 ] = GOADDRESS (pc_token)			'  +  T_ADD
	parseChar [  44 ] = GOADDRESS (pc_token)			'  ,  T_COMMA
	parseChar [  45 ] = GOADDRESS (pc_token)			'  -  T_SUBTRACT
	parseChar [  46 ] = GOADDRESS (dot)						'  .
	parseChar [  47 ] = GOADDRESS (pc_token)			'  /  T_DIVIDE
'																								'     48-57 handled elsewhere
	parseChar [  58 ] = GOADDRESS (pc_token)			'  :  T_COLON
	parseChar [  59 ] = GOADDRESS (pc_token)			'  ;  T_SEMI
	parseChar [  60 ] = GOADDRESS (less_than)			'  <  <=  <>
	parseChar [  61 ] = GOADDRESS (equals)				'  =  ==
	parseChar [  62 ] = GOADDRESS (greater_than)	'  >  >=
	parseChar [  63 ] = GOADDRESS (question)			'  ?  T_QMARK
	parseChar [  64 ] = GOADDRESS (pc_token)			'  @  T_ATSIGN
'																								'     65-90 handled elsewhere
	parseChar [  91 ] = GOADDRESS (pc_token)			'  [  T_LBRAK
	parseChar [  92 ] = GOADDRESS (pc_token)			'  \  T_IDIV
	parseChar [  93 ] = GOADDRESS (pc_token)			'  ]  T_RBRAK
	parseChar [  94 ] = GOADDRESS (upper)					'  ^  ^^
	parseChar [  95 ] = GOADDRESS (pc_token)			'  _  T_ULINE
	parseChar [  96 ] = GOADDRESS (pc_token)			'  `  T_TICK
'																								'     97-122 handled elsewhere
	parseChar [ 123 ] = GOADDRESS (lbrace)				'  {  {{
	parseChar [ 124 ] = GOADDRESS (vbar)					'  |
	parseChar [ 125 ] = GOADDRESS (pc_token)			'  }
	parseChar [ 126 ] = GOADDRESS (pc_token)			'  ~  T_TILDA
	parseChar [ 127 ] = GOADDRESS (pc_token)			'     T_MARK
'																								'     128-255 are trash
END SUB

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  ParseLine ()  #####
' ##########################

FUNCTION  ParseLine (tok[])
	SHARED	charpos[],  tokens[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_IMPORT,  T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED  T_ASM
	SHARED	function_line,  backToken,  lastToken,  tokenCount,  tokenPtr
	SHARED	declareAlloTypeLine,  declareFuncaddrLine
	SHARED	charPtr,  rawLength,  rawline$
	SHARED UBYTE	charsetNumeric[]
	STATIC FUNCADDR XLONG parseFirstChar[]()

	IFZ parseFirstChar[] THEN GOSUB LoadParseFirstChar
	charPtr = 0
	tokenPtr = 0
	backToken = 0
	XERROR = $$FALSE
	importLine = $$FALSE
	importToken = $$FALSE
	lastToken	= $$T_STARTS
	function_line = $$FALSE
	declareAlloTypeLine = $$FALSE
	declareFuncaddrLine = $$FALSE

	IFZ rawLength THEN												' empty source line
		charpos[tokenPtr] = 1
		tokens[tokenPtr] = $$T_STARTS
		GOTO doneLine
	ENDIF

	charV = rawline${charPtr}
	IF charsetNumeric[charV] THEN							' errorIndex on this line
		errorIndex = XLONG(LEFT$(rawline$, 3))
		IF (rawLength <= 3) THEN GOTO doneLine
		charPtr = 3
	ELSE
		errorIndex = 0
	ENDIF

'	IF (charV = '>') THEN											' current executable line
'		markLine = $$CURRENTEXE
'		INC charPtr
'		charV = rawline${charPtr}
'	ENDIF

'	IF (charV = ':') THEN											' breakpoint set on this line
'		markLine = markLine OR $$BREAKPOINT
'		INC charPtr
'		charV = rawline${charPtr}
'	ENDIF

	SELECT CASE charV												' check for leading spaces and tabs
		CASE ' '
					DO WHILE (charV = ' ')					' check for leading spaces  " "
						INC stsp
						INC charPtr
						charV = rawline${charPtr}
					LOOP
					IF (stsp > 127) THEN stsp = 127
					skip = stsp
		CASE '\t'
					DO WHILE (charV = '\t')					' check for leading tabs  "\t"
						INC tabs
						INC charPtr
						charV = rawline${charPtr}
					LOOP
					IF (tabs > 128) THEN tabs = 128
					skip = tabs << 1
					stsp = -tabs AND 0x00FF
	END SELECT
	charpos[tokenPtr] = skip + 1
	tokens[tokenPtr] = $$T_STARTS

' parse the line

	DO WHILE (charV)
		charpos[tokenPtr] = charPtr
		charV = rawline${charPtr}
		token = @parseFirstChar[charV]()								' token = 0 on trash

		IF token = T_ASM THEN														' inline ASM, tokenize rest of line as $$KIND_INLINEASM
			DO
				INC tokenPtr
				chr = rawline${charPtr}
				token	= MakeToken(CHR$(chr), $$KIND_INLINEASM, 0)	' make a token for each char in ASM line
				tokens[tokenPtr]	= token
				charpos[tokenPtr]	= charPtr
				INC charPtr
			LOOP WHILE (charPtr < rawLength)
		ENDIF

		IFZ token THEN INC charPtr											' skip trash
		IF importLine THEN
			IFZ importToken THEN
				IF (token{$$KIND} = $$KIND_LITERALS) THEN
					IF (token{$$TYPE} = $$STRING) THEN importToken = token
				ENDIF
			ENDIF
		ENDIF

		IF (tokenPtr = 1) THEN
			ctoken = token AND 0x1FFFFFFF
			IF ((ctoken = T_FUNCTION) OR (ctoken = T_SFUNCTION) OR (ctoken = T_CFUNCTION)) THEN
				function_line = $$TRUE
			ENDIF
			IF (ctoken = T_IMPORT) THEN importLine = $$TRUE
		ENDIF
		IF XERROR THEN markLine = 0: EXIT FUNCTION
	LOOP WHILE (charPtr < rawLength)



doneLine:
	INC tokenPtr
	charpos[tokenPtr] = 0
	tokens [tokenPtr] = $$T_STARTS
	tokenCount = tokenPtr AND 0x00FF
	tokens[0] = markLine OR $$T_STARTS OR (stsp << 16) OR (errorIndex << 8) OR tokenCount

	i = 0
	DIM tok[tokenCount]
	DO WHILE (i < tokenCount)
		tok[i] = tokens[i]
		INC i
	LOOP
	tok[i] = 0												' terminate with null token

	IF importLine THEN
		IF importToken THEN
			ATTACH tok[] TO hold[]				' hold IMPORT "libname" line tokens
			XxxParseLibrary (importToken)
			ATTACH hold[] TO tok[]
		ENDIF
	ENDIF
	RETURN


' *****************************************************************************
' *****  Load parseFirstChar[] with functions to parse based on 1st char  *****
' *****************************************************************************

SUB LoadParseFirstChar
	DIM parseFirstChar[255]
	FOR c = 0 TO 255
		SELECT CASE TRUE
			CASE (c >= 128)																					' trash
			CASE (c >= 123):	parseFirstChar[c] = &ParseChar ()			' char / operator
			CASE (c >=  97):	parseFirstChar[c] = &ParseSymbol()		' "a-z"
			CASE (c  =  95):	parseFirstChar[c] = &ParseSymbol()		' "_"
			CASE (c >=  91):	parseFirstChar[c] = &ParseChar ()			' char / operator
			CASE (c >=  65):	parseFirstChar[c] = &ParseSymbol()		' "A-Z"
			CASE (c >=  58):	parseFirstChar[c] = &ParseChar ()			' char / operator
			CASE (c >=  48):	parseFirstChar[c] = &ParseNumber()		' "0-9"
			CASE (c  =  36):	parseFirstChar[c] = &ParseSymbol()		' "$con" or "$$con
			CASE (c  =  35):	parseFirstChar[c] = &ParseSymbol()		' "#var" or "##var"
			CASE (c >=  33):	parseFirstChar[c] = &ParseChar ()			' char / operator
			CASE (c  =  32):	parseFirstChar[c] = &ParseWhite ()		' space chars
			CASE (c  =   9):	parseFirstChar[c] = &ParseWhite ()		' tab chars
			CASE (c  <   9):																				' trash
		END SELECT
	NEXT c
END SUB
END FUNCTION


' ############################
' #####  ParseNumber ()  #####
' ############################

FUNCTION  ParseNumber ()
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	ERROR_OVERFLOW,  ERROR_TYPE_MISMATCH
	SHARED	func_number,  charPtr,  rawLength,  rawline$
	SHARED UBYTE  charsetHexUpperLower[]
	SHARED UBYTE  charsetNumeric[]
	LONGDOUBLE valueLD

	startPtr	= charPtr
	specType	= XstStringToNumber (@rawline$, @startPtr, @charPtr, @rtype, @value$$)

	IF (specType = -1) && (rtype = $$DOUBLE) THEN
		sType = XstStringToLongDouble (@rawline$, startPtr, @cPtr, @rt, @valueLD)
		IF sType = $$LONGDOUBLE THEN
			rtype = $$LONGDOUBLE
			charPtr = cPtr
		ENDIF
	ENDIF

	suffixOne	= rawline${charPtr}
	IF suffixOne THEN suffixTwo	= rawline${charPtr+1}
	IF (specType < 0) THEN specType = 0

' see if number is followed by a type-suffix

	IFZ specType THEN
		SELECT CASE suffixOne
			CASE '@':		IF (suffixTwo = '@') THEN
										charPtr		= charPtr + 2
										specType	= $$USHORT
									ELSE
										charPtr		= charPtr + 1
										specType	= $$SLONG
									ENDIF
			CASE '%':		IF (suffixTwo = '%') THEN
										charPtr		= charPtr + 2
										specType	= $$USHORT
									ELSE
										charPtr		= charPtr + 1
										specType	= $$SLONG
									ENDIF
			CASE '&':		IF (suffixTwo = '&') THEN
										charPtr		= charPtr + 2
										specType	= $$ULONG
									ELSE
										charPtr		= charPtr + 1
										specType	= $$SLONG
									ENDIF
			CASE '$':		IF (suffixTwo = '$') THEN
										charPtr		= charPtr + 2
										specType	= $$GIANT
									ENDIF
			CASE '~':		charPtr			= charPtr + 1
									specType		= $$XLONG
			CASE '!':		charPtr			= charPtr + 1
									specType		= $$SINGLE
			CASE '#':		IF (suffixTwo = '#') THEN
										charPtr		= charPtr + 2
										specType	= $$LONGDOUBLE
									ELSE
										charPtr			= charPtr + 1
										specType		= $$DOUBLE
									ENDIF
		END SELECT
	ENDIF

	IFZ specType THEN
		IF rtype = $$LONGDOUBLE THEN
			specType = $$LONGDOUBLE
		ENDIF
	ENDIF

' if type not specified by anything yet, decide on basis of the value

	IFZ specType THEN
		vhi				= GHIGH (value$$)
		vlo				= GLOW  (value$$)
		value			= vlo
		SELECT CASE rtype
			CASE 0				: specType	= $$USHORT								'  zero
			CASE $$SLONG	: specType	= $$SLONG
											IF ((value >= 0) AND (value < 65536)) THEN specType = $$USHORT
			CASE $$XLONG	: specType	= $$XLONG									' "0x..."
											IF ((value >= 0) AND (value < 65536)) THEN specType = $$USHORT
			CASE $$SINGLE	: specType	= $$SINGLE								' "0s..."
			CASE $$GIANT	: specType	= MinTypeFromGiant (value$$)
			CASE $$DOUBLE	: value#		= DMAKE (vhi, vlo)
											specType	= MinTypeFromDouble (value#)
			CASE ELSE			: PRINT "ParseNumber (say what???)": GOTO eeeCompiler
		END SELECT
	ENDIF

	SELECT CASE specType
		CASE $$UBYTE:		specType = $$USHORT
		CASE $$SBYTE:		specType = $$SSHORT
	END SELECT

' add the literal number token to the token stream
getnumber:
	number$		= MID$(rawline$, startPtr+1, charPtr-startPtr)

	token	= $$T_LITERALS OR (specType << 16)
	token	= AddSymbol (@number$, token, func_number)
	ParseOutToken (token)
	RETURN (token)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##############################
' #####  ParseOutError ()  #####
' ##############################

FUNCTION  ParseOutError (token)
	SHARED	charpos[],  tokens[]
	SHARED	charPtr,  rawLength,  tokenCount,  tokenPtr

	charPtr		= 1
	tokenPtr	= 0
	hold			= tokenPtr
	l%				= rawLength
	charpos[tokenPtr] = 1
	IF (l% > 255) THEN l% = 255
	token = token + (0x10000 * l%)
	tokens[tokenPtr] = $$T_STARTS
	ParseOutToken (token)
	TokenRestOfLine ()
	ParseOutToken ($$T_STARTS)
	tokenCount = tokenPtr
	tokens[hold] = $$T_STARTS + tokenPtr
END FUNCTION


' ##############################
' #####  ParseOutToken ()  #####
' ##############################

FUNCTION  ParseOutToken (token)
	SHARED	blanks[],  charpos[],  tokens[]
	SHARED	charPtr,  backToken, lastToken,  tokenPtr,  rawline$
	SHARED	declareAlloTypeLine,  declareFuncaddrLine
	SHARED	T_FUNCADDR

' count and skip trailing spaces and tabs

	spaces = 0
	charV = rawline${charPtr}
	SELECT CASE charV
		CASE ' '
			DO WHILE (charV = ' ')		' space characters
				INC spaces
				INC charPtr
				charV = rawline${charPtr}
			LOOP
			blanks = spaces
			IF (blanks <= 3) THEN
				token = token OR blanks[blanks]				' 1 to 3 spaces
				excess = 0
			ELSE
				IF (blanks > 127) THEN blanks = 127		' 4+ spaces
				excess = $$T_WHITES + (blanks << 16)
			ENDIF
		CASE '\t'
			DO WHILE (charV = '\t')									' tab character
				INC tabs
				INC charPtr
				charV = rawline${charPtr}
			LOOP
			blanks = -tabs
			IF (blanks >= -4) THEN
				token = token OR (blanks << 29)				' 1 to 4 tabs
				excess = 0
			ELSE
				IF (blanks < -128) THEN blanks = -128	' 5+ tabs
				excess = $$T_WHITES + MAKE(blanks, 8, 16)
			ENDIF
		CASE ELSE
			blanks = 0
			excess = 0
	END SELECT

	backToken = lastToken
	lastToken = token AND 0x1FFFFFFF
	IFZ tokenPtr THEN
		declareFuncaddrLine = $$FALSE
		IF (AlloToken(lastToken) OR TypeToken(lastToken)) THEN
			declareAlloTypeLine = $$TRUE
		ELSE
			declareAlloTypeLine = $$FALSE
		ENDIF
	ENDIF
	IF declareAlloTypeLine THEN
		IF (lastToken = T_FUNCADDR) THEN declareFuncaddrLine = $$TRUE
	ENDIF

	INC tokenPtr
	tokens[tokenPtr]	= token
	charpos[tokenPtr]	= charPtr

'  If (>3) spaces or (>4) tabs, output whitespace token

	IF excess THEN
		INC tokenPtr
		tokens[tokenPtr]	= excess
		charpos[tokenPtr]	= charPtr
	ENDIF
	RETURN (token)
END FUNCTION


' ############################
' #####  ParseSymbol ()  #####
' ############################

FUNCTION  ParseSymbol ()
	SHARED	tokens[]
	SHARED	T_ATSIGN,  T_DOLLAR,  T_GOADDR,  T_GOSUB,  T_GOTO,  T_TYPE,  T_UNION
	SHARED	T_LPAREN,  T_PACKED, T_POUND,  T_SUB,  T_SUBADDR,  T_XMARK
	SHARED	T_GOADDRESS,  T_SUBADDRESS,  T_FUNCADDRESS
	SHARED	charPtr,  func_number,  backToken,  lastToken,  tokenPtr
	SHARED	declareAlloTypeLine,  declareFuncaddrLine,  typeLine
	SHARED	rawLength,  rawline$,  hfn$
	SHARED UBYTE charsetUpperLower[]
	SHARED UBYTE charsetUpperLowerNumeric[]
	SHARED UBYTE charsetSpaceTab[]

' Collect the symbol

	scope		= 0
	token		= 0
	symbol$	= GetSymbol$ (@info)
	charV = rawline${charPtr}

' See if symbol is a keyword

	SELECT CASE info
		CASE $$NORMAL_SYMBOL			: token = TestForKeyword (@symbol$)
		CASE $$LOCAL_CONSTANT			: token = TestForKeyword (@symbol$)			' $Constant
		CASE $$GLOBAL_CONSTANT		: token = TestForKeyword (@symbol$)			' $$Constant
		CASE $$EXTERNAL_VARIABLE	: scope = $$EXTERNAL										' ##Extern
		CASE $$SHARED_VARIABLE		: scope = $$SHARED											' #Shared
		CASE $$SOLO_POUND					: token = T_POUND												' solo #
		CASE $$DUAL_POUND					: ParseOutToken (T_POUND)								' dual ##
																token = T_POUND
		CASE $$COMPONENT					: ' not a keyword
		CASE ELSE									: PRINT "ParseSymbol.0": GOTO eeeCompiler
	END SELECT

	IFZ symbol$ THEN
		ParseOutToken (token)			' non-symbol
		RETURN (token)						' ERROR: no symbol
	ENDIF

	IF token THEN
		ParseOutToken (token)			' got token already
		RETURN (token)
	ENDIF

	char0 = symbol${0}					' 1st byte in symbol
	char1 = symbol${1}					' 2nd byte in symbol

' 1st and 2nd tokens on line need special attention

	SELECT CASE tokenPtr
		CASE 0	:	IF ((charV = ':') AND (LEN(symbol$) = charPtr)) THEN  	' label:
								symbol$ = "%g%" + symbol$ + "%" + hfn$
								token = $$T_LABELS OR ($$GOADDR << 16)
								token = AddLabel (@symbol$, token, $$XADD)
								IF XERROR THEN EXIT FUNCTION
								ParseOutToken (@token)
								INC charPtr
								RETURN (token)
							ENDIF
		CASE 1	:	IF ((lastToken = T_TYPE) OR (lastToken = T_UNION) OR (lastToken = T_PACKED)) THEN	' TYPE / UNION
								first = symbol${0}
								final	= rawline${charPtr-1}
								IF charsetUpperLower[first] THEN
									IF charsetUpperLowerNumeric[final] THEN
										token = AddSymbol (@symbol$, $$T_TYPES, 0)
										ParseOutToken (token)
										RETURN (token)
									ENDIF
								ENDIF
							ENDIF
	END SELECT

' Certain symbols are interpreted differently if following certain tokens

	SELECT CASE lastToken
		CASE T_GOTO																					' GOTO label
			symbol$ = "%g%" + symbol$ + "%" + hfn$
			token = AddLabel (@symbol$, $$T_LABELS OR ($$GOADDR << 16), $$XADD)
			IF XERROR THEN EXIT FUNCTION
			ParseOutToken (@token)
			RETURN (token)
		CASE T_GOSUB, T_SUB																	' SUB/GOSUB subname
			symbol$ = "%s%" + symbol$ + "%" + hfn$
			token = $$T_LABELS OR ($$SUBADDR << 16)
			token = AddLabel (@symbol$, $$T_LABELS OR ($$SUBADDR << 16), $$XADD)
			ParseOutToken (@token)
			RETURN (token)
		CASE T_LPAREN
			SELECT CASE backToken
				CASE T_GOADDRESS												' GOADDRESS (label)
					symbol$ = "%g%" + symbol$ + "%" + hfn$
					token = $$T_LABELS OR ($$GOADDR << 16)
					token = AddLabel (@symbol$, token, $$XADD)
					IF XERROR THEN EXIT FUNCTION
					ParseOutToken (@token)
					RETURN (token)
				CASE T_SUBADDRESS												' SUBADDRESS (subname)
					symbol$ = "%s%" + symbol$ + "%" + hfn$
					token = $$T_LABELS OR ($$SUBADDR << 16)
					token = AddLabel (@symbol$, token, $$XADD)
					IF XERROR THEN EXIT FUNCTION
					ParseOutToken (@token)
					RETURN (token)
			END SELECT
		CASE ELSE
	END SELECT

' Symbols that begin with certain characters require special attention

	IF (char0 = '.') THEN																	' .COMPONENT name
		sx = 0
		test_char = rawline${charPtr + sx}
		DO WHILE ((test_char = ' ') OR (test_char = '\t'))	' space or tab
			INC sx
			test_char = rawline${charPtr + sx}
		LOOP
		IF (test_char = '[') THEN
			token = $$T_ARRAY_SYMBOLS
		ELSE
			token = $$T_SYMBOLS
		ENDIF
		token = AddSymbol (@symbol$, token, 0)
		ParseOutToken (token)
		RETURN (token)
	ENDIF

' Check for $LocalConstants and $$SharedConstants

	symbolLength = LEN(symbol$)
	IF (char0 = '$') THEN
		charV = rawline${charPtr}
		IF (charV = '$') THEN
			symbol$ = symbol$ + CHR$(charV)											' string $$SYSCON$
			sysconType = ($$EXTERNAL << 5) + $$STRING
			locconType = ($$SHARED << 5) + $$STRING
			INC charPtr
		ENDIF
		IF (symbolLength = 1) THEN
			ParseOutToken (T_DOLLAR)														' symbol is "$"
			RETURN (T_DOLLAR)
		ENDIF
		IF (char1 = '$') THEN
			IF (symbolLength = 2) THEN
				ParseOutToken (T_DOLLAR)
				ParseOutToken (T_DOLLAR)													' symbol is "$$"
				RETURN (T_DOLLAR)
			ENDIF
			token = $$T_SYSCONS + (sysconType << 16)
			token = AddSymbol (@symbol$, token, func_number)		' $$SYSCONS
			ParseOutToken (token)
			RETURN (token)
		ELSE
'			IF (symbol$ = "$XERROR") THEN
'				token = $$T_VARIABLES OR ($$XLONG << 16)					' $XERROR
'			ELSE
				token = $$T_CONSTANTS + (locconType << 16)				' $LOCAL_CONSTANT
'			ENDIF
			token = AddSymbol (@symbol$, token, func_number)		' $CONSTANTS
			ParseOutToken (token)
			RETURN (token)
		ENDIF
	ENDIF

' Normal symbols can have type suffix characters

	IF (char0 = '#') THEN
		scope = $$SHARED
		IF (char1 = '#') THEN scope = $$EXTERNAL
	ENDIF

	SELECT CASE charV
		CASE '@'	:	symbol$ = symbol$ + "@"
								data_type = $$SBYTE
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '@') THEN
									symbol$ = symbol$ + "@"
									data_type = $$UBYTE
									INC charPtr
								ENDIF
		CASE '%'	:	symbol$ = symbol$ + "%"
								data_type = $$SSHORT
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '%') THEN
									symbol$ = symbol$ + "%"
									data_type = $$USHORT
									INC charPtr
								ENDIF
		CASE '&'	:	symbol$ = symbol$ + "&"
								data_type = $$SLONG
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '&') THEN
									symbol$ = symbol$ + "&"
									data_type = $$ULONG
									INC charPtr
								ENDIF
		CASE '~'	:	symbol$ = symbol$ + "~"
								data_type = $$XLONG
								INC charPtr
		CASE '!'	:	symbol$ = symbol$ + ".sgl"			' HACK#1 - Should be "!", but GoAsm chokes on this.
'		CASE '!'	:	symbol$ = symbol$ + "!"					' Restore this line after a bugfix of GoAsm is released.
								data_type = $$SINGLE
								INC charPtr
		CASE '#'	:	symbol$ = symbol$ + "#"
								data_type = $$DOUBLE
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '#') THEN
									symbol$ = symbol$ + "#"
									data_type = $$LONGDOUBLE
									INC charPtr
								ENDIF
		CASE '$'	:	symbol$ = symbol$ + "$"
								data_type = $$STRING
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '$') THEN
									symbol$ = symbol$ + "$"
									data_type = $$GIANT
									INC charPtr
								ENDIF
		CASE ELSE	:	data_type = 0
	END SELECT

' See what follows trailing spaces/tabs

pass_out:
	sx = 0
	test_char = rawline${charPtr + sx}
	DO WHILE (charsetSpaceTab[test_char])			' skip <spaces> and <tabs>
		INC sx
		test_char = rawline${charPtr + sx}
	LOOP

' See if this is an array or function symbol

	SELECT CASE test_char
		CASE '('	: IF scope THEN NEXT CASE
								IF (declareFuncaddrLine OR (lastToken = T_ATSIGN)) THEN
									token = $$T_VARIABLES OR (data_type << 16)
								ELSE
									token = $$T_FUNCTIONS OR (data_type << 16)
								ENDIF
		CASE '['	: token = $$T_ARRAYS OR (scope << 21) OR (data_type << 16)
		CASE ELSE	: token = $$T_VARIABLES OR (scope << 21) OR (data_type << 16)
	END SELECT

	token = AddSymbol (@symbol$, token, func_number)
	ParseOutToken (token)
	RETURN (token)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  ParseWhite ()  #####
' ###########################

FUNCTION  ParseWhite ()
	SHARED	charPtr,  rawline$
	SHARED	XERROR,  ERROR_COMPILER

	charV = rawline${charPtr}
	SELECT CASE charV
		CASE ' ':
			DO WHILE (charV = ' ')			' space character
				INC spaces
				INC charPtr
				charV = rawline${charPtr}
			LOOP
		CASE '\t':
			DO WHILE (charV = '\t')			' tab character
				INC tabs
				INC charPtr
				charV = rawline${charPtr}
			LOOP
			spaces = -tabs
		CASE ELSE
			PRINT "www"
			GOTO eeeCompiler
	END SELECT
	token = $$T_WHITES + MAKE(spaces, 8, 16)
	ParseOutToken (@token)
	RETURN (token)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ##########################
' #####  PeekToken ()  #####
' ##########################

FUNCTION  PeekToken ()
	SHARED	funcToken[],  typeAlias[],  typeToken[],  tab_sym[],  tokens[]
	SHARED	tokenCount,  tokenPtr
	STATIC GOADDR  kindDispatch[]

	IFZ kindDispatch[] THEN GOSUB LoadKindDispatch		' load dispatch table
	htp				= tokenPtr

skip_whities:
	INC tokenPtr
	IF (tokenPtr >= tokenCount) THEN RETURN ($$T_STARTS)
	token			= tokens[tokenPtr]{29,0}
	tt				= token{$$NUMBER}
	GOTO @kindDispatch [token{$$KIND}]
	tokenPtr	= htp
	RETURN (token)

from_tab_sym:
	tokenPtr	= htp
	RETURN (tab_sym[tt])

from_func_sym:
	tokenPtr	= htp
	RETURN (funcToken[tt])

them_comments:
	tokenPtr	= htp
	RETURN ($$T_STARTS)

from_types:
	tokenPtr	= htp
	ttt				= typeAlias[tt]{$$NUMBER}
	IF ttt THEN tt = ttt
	RETURN (typeToken[tt])


SUB LoadKindDispatch
	DIM kindDispatch[31]
	kindDispatch [ $$KIND_SYMBOLS				] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_ARRAY_SYMBOLS	] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_VARIABLES			] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_ARRAYS				] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_SYSCONS				] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_LITERALS			] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_CONSTANTS			] = GOADDRESS (from_tab_sym)
	kindDispatch [ $$KIND_FUNCTIONS			] = GOADDRESS (from_func_sym)
	kindDispatch [ $$KIND_COMMENTS			] = GOADDRESS (them_comments)
	kindDispatch [ $$KIND_WHITES				] = GOADDRESS (skip_whities)
	kindDispatch [ $$KIND_TYPES					] = GOADDRESS (from_types)
END SUB
END FUNCTION


' ####################
' #####  Pop ()  #####
' ####################

FUNCTION  Pop (d_reg, d_type)
	SHARED	stackData[],  stackType[]
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type,  func_number

	DEC toms
	IF (toms < 0) THEN PRINT "pop1": GOTO eeeCompiler
	IF (d_type < $$SLONG) THEN d_type = $$SLONG

	SELECT CASE d_reg
		CASE $$RA0:	a0_type = d_type
		CASE $$RA1:	a1_type = d_type
	END SELECT

	xdata = stackData[toms]
	xtype = stackType[toms]

	IF d_reg THEN
		IF ((d_type != $$SINGLE) AND (d_type != $$DOUBLE) AND (d_type != $$LONGDOUBLE)) THEN
			Move (d_reg, d_type, xdata, d_type)
		ENDIF
	ELSE
		IF ((d_type = $$SINGLE) | (d_type = $$DOUBLE) | (d_type = $$LONGDOUBLE)) THEN
			SELECT CASE d_type
				CASE $$SINGLE 		: dsize = 4
				CASE $$DOUBLE 		: dsize = 8
				CASE $$LONGDOUBLE : dsize = 12
			END SELECT
			Code ($$sub, $$regimm, $$esp, dsize, 0, $$XLONG, @"", @"")
			Code ($$fstp, $$ro, 0, $$esp, 0, d_type, @"", @"")
		ELSE
			Move (d_reg, d_type, xdata, d_type)
		ENDIF
	ENDIF
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  PrintError ()  #####
' ###########################

' Return TRUE if user requests Quit

FUNCTION  PrintError (err)
	SHARED	errorCount
	SHARED	xerror$[],  charpos[]
	SHARED	XERROR,  rawLength,  rawline$,  tokenPtr,  lineNumber,  uerror
	SHARED	a0,  a0_type,  a1,  a1_type,  toes,  toms,  oos
	SHARED UBYTE oos[]
	SHARED fLogErrors, fConsole
	SHARED programName$, xfile$
	SHARED fM4
	SHARED LINEINFO lineinfo[]

'PRINT "PrintError: err ="; err
'PRINT "XERROR          ="; XERROR
'PRINT "rawLength       ="; rawLength
'PRINT "rawline$        = "; rawline$
'PRINT "tokenPtr        ="; tokenPtr
'PRINT "lineNumber      ="; lineNumber
'PRINT "xfile$          = "; xfile$

	IF (err <= 0) THEN PRINT "PrintError ="; err: GOTO eeePrintError
  IF (err > uerror) THEN PRINT "PrintError ="; err: GOTO eeePrintError
  error_message$ = xerror$[err]
	tp = tokenPtr
	rawline$	= Deparse$(", ")
	rawLength	= LEN(rawline$)

'PRINT "error_message$="; error_message$
'PRINT "rawline$="; rawline$

	pointer		= charpos[tp]
	IF rawline$ THEN
		i = 0
		newPointer = -1
		lenRawline = LEN(rawline$)
		DO WHILE (i < lenRawline)
			INC newPointer
			rawChar = rawline${i}
			IF (rawChar = '\t') THEN
				IF (newPointer AND 1) THEN
					INC newPointer
					newRawline$ = newRawline$ + "  "				' two spaces
				ELSE
					newRawline$ = newRawline$ + " "					' one space
				ENDIF
			ELSE
				newRawline$ = newRawline$ + CHR$(rawChar)
			ENDIF
			IF (i <= pointer) THEN tokenPointer = newPointer
			INC i
		LOOP
	ENDIF

	IFZ fConsole THEN PRINT newRawline$

	INC tokenPointer
	IF (tokenPointer > 77) THEN
		pointer = 77
	ELSE
		pointer = tokenPointer
	ENDIF

	IFZ fConsole THEN
		IF (pointer > 2) THEN
			PRINT "; "; SPACE$(pointer - 3) + "|"
		ELSE
			PRINT "; |"
		ENDIF
	ENDIF

	message_length = LEN(error_message$)
	half_message_length = message_length >> 1
	start_message = pointer - half_message_length
	IF (pointer + half_message_length) > 77 THEN
		start_message = 77 - message_length
	ENDIF
	IF (start_message < 1) THEN start_message = 0

	IFZ fConsole THEN
		PRINT "; "; SPACE$(start_message) + error_message$
		IF fM4 THEN
			PRINT "; "; SPACE$(start_message) + "on line"; lineinfo[lineNumber].line
			PRINT "; "; SPACE$(start_message) + "in file "; lineinfo[lineNumber].file
		ELSE
			PRINT "; "; SPACE$(start_message) + "on line"; lineNumber
		ENDIF
	ENDIF

	ParseOutError (@token)
	INC errorCount

	IFZ fConsole THEN
		a$ = INLINE$("*****  Press RETURN to continue  (q to quit)  *****  ")
	ELSE
		a$ = ""
	ENDIF

' save error information to a log file
	IFT fLogErrors THEN
		file$ = programName$ + ".log"
		line$ = RIGHT$(newRawline$, LEN(newRawline$)-2)
		message$ = message$ + line$                 + ","
		message$ = message$ + error_message$        + ","
		IF fM4 THEN
			line = lineinfo[lineNumber].line
			message$ = message$ + STRING$(line)       + ","
		ELSE
			message$ = message$ + STRING$(lineNumber) + ","
		ENDIF
		message$ = message$ + STRING$(tokenPointer-2)
		IF fM4 THEN
			message$ = message$ + ","
			message$ = message$ + lineinfo[lineNumber].file
		ENDIF
		XstLog (message$, $$TRUE, file$)
	ENDIF

	IF fConsole THEN
		IF fM4 THEN
			f$ = lineinfo[lineNumber].file
			XstDecomposePathname (f$, @fpath$, "", "", "", "")
			IFZ fpath$ THEN
				XstDecomposePathname (xfile$, @fpath$, "", "", "", "")
			ENDIF
			f$ = fpath$ + f$
			msg$ = f$
			line = lineinfo[lineNumber].line
			msg$ = msg$ + "(" + STRING$(line) + "): "
			msg$ = msg$ + error_message$
			msg$ = msg$ + "(" + STRING$(tokenPointer-2) + ")"
		ELSE
			msg$ = xfile$
			msg$ = msg$ + "(" + STRING$(lineNumber) + "): "
			msg$ = msg$ + error_message$
			msg$ = msg$ + "(" + STRING$(tokenPointer-2) + ")"
		ENDIF
		PRINT msg$
 	ENDIF

	XERROR	= 0
	toes		= 0
	toms		= 0
	oos			= 0
	oos[0]	= 0
	a0			= 0
	a1			= 0
	a0_type	= 0
	a1_type	= 0
	IF a$ THEN
		a$ = TRIM$(LCASE$(a$))
		IF LEFT$(a$, 1) = "q" THEN RETURN ($$TRUE)
  ENDIF
	RETURN ($$FALSE)

eeePrintError:
	XERROR = 0
	EXIT FUNCTION
END FUNCTION


' ############################
' #####  PrintTokens ()  #####
' ############################

FUNCTION  PrintTokens ()
	SHARED	tokens[]

	IF tokens[] THEN
		FOR x = 0 TO tokens[0] AND 0x00FF
			PRINT HEX$(tokens[x], 8);;;
		NEXT x
		PRINT
	ENDIF
END FUNCTION


' #########################
' #####  Printoid ()  #####
' #########################

FUNCTION  Printoid ()
	SHARED	q_type_long[],  typeName$[],  m_addr$[],  reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_SYNTAX,  ERROR_TYPE_MISMATCH
	SHARED	T_ATSIGN,  T_COMMA,  T_LBRAK,  T_POUND,  T_RBRAK,  T_SEMI,  T_TAB
	SHARED	a0,  a0_type,  a1,  a1_type,  oos,  toes
	SHARED	inPrint,  tokenPtr
	SHARED UBYTE oos[]
	STATIC GOADDR printKind[]

	IFZ printKind[] THEN GOSUB LoadPrintKind

	zippo = $$FALSE
	inPrint = $$TRUE
	first_arg = $$TRUE
	free_after = $$TRUE
	add_newline = $$TRUE
	token = NextToken ()
	tkind = token{$$KIND}
	IF (token == T_LBRAK) THEN
		token = Eval (@result_type)
		IF (result_type > $$XLONG) THEN GOTO eeeTypeMismatch
		IFF q_type_long[result_type] THEN GOTO eeeTypeMismatch
		acc = Topax1 ()
		IFZ acc THEN GOTO eeeSyntax
		IF (token != T_RBRAK) THEN GOTO eeeSyntax
		token = NextToken ()														' token after "]"
		tkind = token{$$KIND}
		SELECT CASE tkind
			CASE $$KIND_STARTS			: zippo = $$TRUE
			CASE $$KIND_COMMENTS		: zippo = $$TRUE
			CASE $$KIND_TERMINATORS	: zippo = $$TRUE
			CASE $$KIND_SEPARATORS	: token = NextToken ()
																tkind = token{$$KIND}
																SELECT CASE tkind
																	CASE $$KIND_STARTS			: GOTO eeeSyntax
																	CASE $$KIND_COMMENTS		: GOTO eeeSyntax
																	CASE $$KIND_TERMINATORS	: GOTO eeeSyntax
																END SELECT
			CASE ELSE								: GOTO eeeSyntax
		END SELECT
		IF zippo THEN
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_PrintFileNewline", @"	;;; i842")
			RETURN (token)
		ENDIF
	ELSE
		symbol$ = ".filenumber"
		ftoken = $$T_VARIABLES + ($$AUTOX << 21) + ($$XLONG << 16)
		ftoken = AddSymbol (@symbol$, ftoken, func_number)
		fnum = ftoken{$$NUMBER}
		IFZ m_addr$[fnum] THEN AssignAddress (ftoken)
		IF XERROR THEN EXIT FUNCTION
		SELECT CASE tkind
			CASE $$KIND_STARTS			: zippo = $$TRUE
			CASE $$KIND_COMMENTS		: zippo = $$TRUE
			CASE $$KIND_TERMINATORS	: zippo = $$TRUE
		END SELECT
		IF zippo THEN
			Code ($$call, $$rel, 0, 0, 0, 0, @"%_PrintConsoleNewline", @"	;;; i843")
			RETURN (token)
		ENDIF
		Code ($$push, $$imm, 1, 0, 0, $$XLONG, @"", @"	;;; i844")
		noPush = $$TRUE
	ENDIF

	IFZ noPush THEN Code ($$push, $$reg, acc, 0, 0, $$XLONG, @"", @"	;;; i846")
	Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i845")



print_loopie:
	lastk	= kind
	kind	= token{$$KIND}
	GOTO @printKind [kind]						' dispatch based on kind
	PRINT "printkind"
	GOTO eeeSyntax


' *****  routines invoked through "GOTO @printKind [kind]" above  *****

print_character:
	IF (token = T_ATSIGN) THEN GOTO print_last_data
	GOTO eeeSyntax

' *****  append data expression to print string  *****

print_last_data:
	DEC tokenPtr
print_data:
	dtoken = token
	token = Eval (@new_type)
	IF XERROR THEN
		inPrint = $$FALSE
		EXIT FUNCTION
	ENDIF
	IF (new_type >= $$SCOMPLEX) THEN GOTO eeeTypeMismatch
	acc = Topx (@xreg, @xregx, @oreg, @oregx)

' if expression was TAB(value), do special TAB routine, otherwise concatenate

	IF (dtoken = T_TAB) THEN
		SELECT CASE acc
			CASE $$RA0
				a0_type = $$STRING
				IF first_arg THEN
					routine$ = "%_print.tab.first.a0"
				ELSE
					IF (oreg = 0) AND (toes = 2) THEN
						Pop ($$RA1, $$STRING)
						a1 = toes - 1
					ENDIF
					routine$ = "%_print.tab.a0.eq.a1.tab.a0"
				ENDIF
			CASE $$RA1
				a1_type = $$STRING
				IF first_arg THEN
					routine$ = "%_print.tab.first.a1"
				ELSE
					IF (oreg = 0) AND (toes = 2) THEN
						Pop ($$RA0, $$STRING)
						a0 = toes - 1
					ENDIF
					routine$ = "%_print.tab.a0.eq.a0.tab.a1"
				ENDIF
			CASE ELSE
				PRINT "prn0x": GOTO eeeCompiler
		END SELECT
		INC oos
		oos[oos] = 's'
		new_type = $$STRING
	ELSE
		SELECT CASE acc
			CASE $$RA0
				IF (oreg = 0) AND (toes = 2) THEN
					Pop ($$RA1, $$STRING)
					a1 = toes - 1
					oreg = $$RA1
				ENDIF
				routine$ = "%_concat.ubyte.a0.eq.a1.plus.a0.ss"
			CASE $$RA1
				IF (oreg = 0) AND (toes = 2) THEN
					Pop ($$RA0, $$STRING)
					a0 = toes - 1
					oreg = $$RA0
				ENDIF
				routine$ = "%_concat.ubyte.a0.eq.a0.plus.a1.ss"
			CASE ELSE
				PRINT "prn1": GOTO eeeCompiler
		END SELECT
	ENDIF

' I think there's a stack tangle problem below on complex expressions !!!

	IF (new_type != $$STRING) THEN
		IF oreg THEN Code ($$push, $$reg, oreg, 0, 0, $$XLONG, @"", @"")
		Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"")
		SELECT CASE new_type
			CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
						Code ($$fstp, $$ro, 0, $$esp, 0, new_type, @"", @"")
			CASE $$GIANT
						Code ($$st, $$roreg, xregx, $$esp, 4, $$XLONG, @"", @"	;;; i847")
						Code ($$st, $$roreg, xreg, $$esp, 0, $$XLONG, @"", @"	;;; i848")
			CASE ELSE
						Code ($$st, $$roreg, xreg, $$esp, 0, $$XLONG, @"", @"	;;; i848")
		END SELECT

		dest$ = "%_str.d." + typeName$[new_type AND 0x1F]

		Code ($$call, $$rel, 0, 0, 0, 0, @dest$, @"	;;; i849a")
		Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"	;;; i849b")
		IF (acc != $$eax) THEN
			Code ($$mov, $$regreg, acc, $$eax, 0, $$XLONG, @"", @"	;;; i849c")
		ENDIF
		IF oreg THEN
			Code ($$pop, $$reg, oreg, 0, 0, $$XLONG, @"", @"	;;; i849d")
		ENDIF
		INC oos
		oos[oos] = 's'
		a0_type = $$STRING
	ENDIF

	IF first_arg THEN
		IF (dtoken == T_TAB) THEN
			Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i851")
		ENDIF
	ELSE
		Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"	;;; i852")
		DEC toes
		a0 = toes
		a0_type = $$STRING
		a1 = 0
		a1_type = 0
		DEC oos
		oos[oos] = 's'
	ENDIF
	first_arg = $$FALSE
	add_newline = $$TRUE
	GOTO print_loopie

print_separator:
	oneSemi = $$FALSE
	SELECT CASE token
		CASE T_COMMA
			IF first_arg THEN
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_PrintFirstComma", @"	;;; i853")
				INC toes
				a0 = toes
				a0_type = $$STRING
				INC oos
				oos[oos] = 's'
			ELSE
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_PrintAppendComma", @"	;;; i854")
				a0 = toes
				a0_type = $$STRING
				oos[oos] = 's'
			ENDIF
		CASE T_SEMI
			semiCount = 0
			DO
				INC semiCount
				stp = tokenPtr
				token = NextToken ()
			LOOP WHILE (token = T_SEMI)
			tokenPtr = stp
			DEC semiCount
			IFZ semiCount THEN			' one semi-colon does nothing
				oneSemi = $$TRUE
				EXIT SELECT
			ENDIF
			semiCount$ = STRING(semiCount)
			IF first_arg THEN
				Code ($$mov, $$regimm, $$ebx, semiCount, 0, $$XLONG, @"", @"	;;; i855")
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_PrintFirstSpaces", @"	;;; i856")
				INC toes
				a0 = toes
				a0_type = $$STRING
				INC oos
				oos[oos] = 's'
			ELSE
				Code ($$mov, $$regimm, $$ebx, semiCount, 0, $$XLONG, @"", @"	;;; i857")
				Code ($$call, $$rel, 0, 0, 0, 0, @"%_PrintAppendSpaces", @"	;;; i858")
			ENDIF
	END SELECT
	IFZ oneSemi THEN first_arg = $$FALSE
	add_newline = $$FALSE
	token = NextToken ()
	GOTO print_loopie

print_line:
print_terminator:
	Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, @"", @"")
	IFZ first_arg THEN
		IF add_newline THEN
			p$ = "%_PrintWithNewlineThenFree"
		ELSE
			p$ = "%_PrintThenFree"
		ENDIF
		Code ($$call, $$rel, 0, 0, 0, 0, @p$, @"	;;; i859")
	ENDIF
	Code ($$add, $$regimm, $$esp, 4, 0, $$XLONG, @"", @"")
	inPrint = $$FALSE
	IFZ first_arg THEN DEC oos
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (token)


' ************************************************************************
' *****  Load printKind[] with routines to print various token kinds *****
' ************************************************************************

SUB LoadPrintKind
	DIM printKind[31]
	printKind [ $$KIND_STATE_INTRIN		] = GOADDRESS (print_last_data)
	printKind [ $$KIND_INTRINSICS			] = GOADDRESS (print_last_data)
	printKind [ $$KIND_BINARY_OPS			] = GOADDRESS (print_last_data)
	printKind [ $$KIND_UNARY_OPS			] = GOADDRESS (print_last_data)
	printKind [ $$KIND_VARIABLES			] = GOADDRESS (print_last_data)
	printKind [ $$KIND_CONSTANTS			] = GOADDRESS (print_last_data)
	printKind [ $$KIND_FUNCTIONS			] = GOADDRESS (print_last_data)
	printKind [ $$KIND_LITERALS				] = GOADDRESS (print_last_data)
	printKind [ $$KIND_CHARCONS				] = GOADDRESS (print_last_data)
	printKind [ $$KIND_LPARENS				] = GOADDRESS (print_last_data)
	printKind [ $$KIND_SYSCONS				] = GOADDRESS (print_last_data)
	printKind [ $$KIND_ARRAYS					] = GOADDRESS (print_last_data)
	printKind [ $$KIND_STARTS					] = GOADDRESS (print_terminator)
	printKind [ $$KIND_COMMENTS				] = GOADDRESS (print_terminator)
	printKind [ $$KIND_STATEMENTS			] = GOADDRESS (print_terminator)
	printKind [ $$KIND_TERMINATORS		] = GOADDRESS (print_terminator)
	printKind [ $$KIND_SEPARATORS			] = GOADDRESS (print_separator)
	printKind [ $$KIND_CHARACTERS			] = GOADDRESS (print_character)
END SUB

eeeCompiler:
	XERROR = ERROR_COMPILER
	inPrint = $$FALSE
	EXIT FUNCTION

eeeSyntax:
	XERROR = ERROR_SYNTAX
	inPrint = $$FALSE
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	inPrint = $$FALSE
	EXIT FUNCTION
END FUNCTION


' #####################
' #####  Push ()  #####
' #####################

FUNCTION  Push (sreg, stype)
	SHARED	tab_sym[],  m_reg[],  m_addr[],  m_addr$[]
	SHARED	stackData[],  stackType[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type
	SHARED	func_number,  hfn$

	s_reg = sreg
	s_type = stype
	IF (s_type < $$SLONG) THEN s_type = $$SLONG
	xname$ = ".xstk" + hfn$ + "." + HEX$(toms, 4)
	xtoken = $$T_VARIABLES + ($$AUTOX << 21) + ($$DOUBLE << 16)
	xtoken = AddSymbol (@xname$, xtoken, func_number)
	xtoken = xtoken OR ($$AUTOX << 21)
	xx = xtoken{$$NUMBER}
	tab_sym[xx] = xtoken
	IFZ m_addr$[xx] THEN AssignAddress (xtoken)
	IF XERROR THEN RETURN
	SELECT CASE s_reg
		CASE $$RA0:	a0 = 0: a0_type = 0
		CASE $$RA1:	a1 = 0: a1_type = 0
		CASE ELSE:	GOTO eeeCompiler
	END SELECT
	stackData[toms] = xtoken
	stackType[toms] = s_type
	INC toms
	IF ((stype = $$SINGLE) | (stype = $$DOUBLE) | (stype = $$LONGDOUBLE)) THEN RETURN
	Move (xtoken, s_type, s_reg, s_type)
	RETURN (xtoken)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ############################
' #####  PushFuncArg ()  #####
' ############################

FUNCTION  PushFuncArg (FUNCARG arg)
	SHARED	XERROR
	SHARED	ERROR_BYREF
	SHARED	ERROR_TYPE_MISMATCH
	SHARED	SSHORT  typeConvert[]

	token = arg.token
	stack = arg.stack
	argType = arg.argType
	varType = arg.varType
	tt = token AND 0x0000FFFF

	SELECT CASE arg.kind
		CASE $$KIND_ARRAYS
					IFZ arg.byRef THEN GOTO eeeByRef
					Move (0, $$XLONG, token, $$XLONG)
		CASE $$KIND_VARIABLES
					IF ((argType > 31) OR (varType > 31)) THEN
						IF (argType != varType) THEN PRINT "PushFuncArg() : typemismatch" : GOTO eeeTypeMismatch
						argType = $$XLONG
						varType = $$XLONG
					ENDIF
					conv = typeConvert[argType,varType] {{$$BYTE0}}
					SELECT CASE conv
						CASE -1		: PRINT "PushFuncArg() : typemismatch2" : GOTO eeeTypeMismatch
						CASE  0		:	IFZ token THEN
													Pop (0, varType)
												ELSE
													Move (0, varType, token, varType)
												ENDIF
						CASE ELSE	: IFZ token THEN
													Pop ($$eax, varType)
												ELSE
													Move ($$eax, varType, token, varType)
												ENDIF
												token = $$eax
												Conv ($$eax, argType, $$eax, varType)
												SELECT CASE argType
													CASE $$DOUBLE			: Code ($$sub, $$regimm, $$esp, 8, 0, $$XLONG, @"", @"	;;; i610")
																						: Code ($$fstp, $$ro, 0, $$esp, 0, $$DOUBLE, @"", @"	;;; i611")
													CASE $$LONGDOUBLE	: Code ($$sub, $$regimm, $$esp, 12, 0, $$XLONG, @"", @"	;;; i612")
																						: Code ($$fstp, $$ro, 0, $$esp, 0, $$LONGDOUBLE, @"", @"	;;; i613")
													CASE $$SINGLE			: Code ($$sub, $$regimm, $$esp, 4, 0, $$XLONG, @"", @"	;;; i614")
																						: Code ($$fstp, $$ro, 0, $$esp, 0, $$SINGLE, @"", @"	;;; i615")
													CASE ELSE					: Code ($$push, $$reg, $$eax, 0, 0, argType, @"", @"	;;; i616")
												END SELECT
					END SELECT
		CASE $$KIND_LITERALS, $$KIND_SYSCONS, $$KIND_CONSTANTS, $$KIND_CHARCONS
					LoadLitnum (0, argType, token, varType)
		CASE ELSE
					PRINT "PushFuncArg(): Error: " : GOTO eeeCompiler
	END SELECT
	RETURN

eeeByRef:
	XERROR = ERROR_BYREF
	EXIT FUNCTION

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION



' ####################
' #####  Reg ()  #####  Register, imm16, neg16, litnum, connum
' ####################

FUNCTION  Reg (xx)
	SHARED	r_addr[]

	IF (xx <= $$CONNUM) THEN RETURN (xx)
	RETURN (r_addr[xx{$$NUMBER}])
END FUNCTION



' ############################
' #####  ReturnValue ()  #####
' ############################

FUNCTION  ReturnValue (returnType)
	SHARED SSHORT typeConvert[]
	SHARED	reg86$[],  reg86c$[]
	SHARED	funcToken[],  r_addr[]
	SHARED	T_RETURN,  T_ELSE
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH,  ERROR_VOID
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type,  oos
	SHARED	func_number,  crvtoken,  typeSize[],  typeSize$[]
	SHARED UBYTE oos[]

	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	funcType = TheType (funcToken[func_number])
	IF (new_type AND (funcType = $$VOID)) THEN GOTO eeeVoid
	IF (funcType >= $$SCOMPLEX) THEN GOTO returnComposite
	IF new_type THEN																	' something returned
		IF new_data THEN																' a token
			nn	= new_data{$$NUMBER}											' nn = token #
			ro	= r_addr[nn]															' ro = register #
			rr	= ro																			' rr = ditto
			SELECT CASE typeConvert[funcType, new_type] {{$$BYTE0}}
				CASE -1:		GOTO eeeTypeMismatch													' error
				CASE  0:		Move ($$RA0, funcType, new_data, funcType)		' data to RA0
				CASE ELSE:	IF rr THEN
											Conv ($$RA0, funcType, new_data, new_type)	' convert
										ELSE
											Move ($$RA0, new_type, new_data, new_type)	' data to RA0
											Conv ($$RA0, funcType, $$RA0, new_type)			' convert
										ENDIF
			END SELECT
			IF (new_type = $$STRING) THEN						' if token is string-type
				SELECT CASE new_data{$$ALLO}								' ... and the allo is
					CASE $$AUTO, $$AUTOX:	GOSUB ClearString		' temp:  clear it
					CASE ELSE:						GOSUB CloneString		' other: clone it
				END SELECT
			ENDIF
		ELSE
			top = Topax1 ()																' where's the data ???
			Conv ($$RA0, funcType, top, new_type)					' put it in RA0
			IF (new_type = $$STRING) THEN									' if data is string-type
				IF (oos[oos] = 'v') THEN GOSUB CloneString	' uncloned: clone it
			ENDIF
		ENDIF
	ELSE																							' no return expression
		SELECT CASE funcType
			CASE $$GIANT
						Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, @"", @"	;;; i860")
						Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; i860a")
			CASE $$SINGLE, $$DOUBLE, $$LONGDOUBLE
						Code ($$fldz, 0, 0, 0, 0, $$DOUBLE, @"", @"	;;; i861")
			CASE ELSE
						Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"	;;; i862")
		END SELECT
	ENDIF
	returnType = funcType
	oos		= 0:	oos[0]	= 0
	toes	= 0:	toms		= 0
	a0		= 0:	a0_type	= 0
	a1		= 0:	a1_type	= 0
	RETURN (new_op)


' *****  return composite data type  *****

returnComposite:
	IFZ crvtoken THEN GOTO eeeCompiler
	ts = typeSize[funcType]
	IF new_type THEN
		Move ($$edi, $$XLONG, crvtoken, $$XLONG)
		IF new_data THEN
			Move ($$esi, $$XLONG, new_data, $$XLONG)
		ELSE
			top = Topax1 ()
			Move ($$esi, $$XLONG, top, $$XLONG)
		ENDIF
		Code ($$mov, $$regimm, $$ecx, ts, 0, $$XLONG, @"", @"	;;; i863")
		Code ($$mov, $$regreg, $$eax, $$edi, 0, $$XLONG, @"", @"	;;; i864")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_assignComposite", @"	;;; i864")
	ELSE
		Move ($$edi, $$XLONG, crvtoken, $$XLONG)
		Code ($$xor, $$regreg, $$esi, $$esi, 0, $$XLONG, @"", @"	;;; i865b")
		Code ($$mov, $$regimm, $$ecx, ts, 0, $$XLONG, @"", @"	;;; i866")
		Code ($$mov, $$regreg, $$eax, $$edi, 0, $$XLONG, @"", @"	;;; i865a")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%_assignComposite", @"	;;; i867")
	ENDIF
	oos		= 0:	oos[0]	= 0
	toes	= 0:	toms		= 0
	a0		= 0:	a0_type	= 0
	a1		= 0:	a1_type	= 0
	returnType = funcType
	RETURN (new_op)

' *****  supporting subroutines  *****

SUB ClearString
	IF ro THEN
		Code ($$xor, $$regreg, ro, ro, 0, $$XLONG, @"", @"	;;; i868")
	ELSE
		Code ($$xor, $$regreg, $$esi, $$esi, 0, $$XLONG, @"", @"	;;; i869")
		Move (new_data, $$XLONG, $$esi, $$XLONG)
	ENDIF
END SUB

SUB CloneString
	Code ($$call, $$rel, 0, 0, 0, 0, @"%_clone.a0", @"	;;; i870")
END SUB

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION

eeeVoid:
	XERROR = ERROR_VOID
	EXIT FUNCTION
END FUNCTION


' ###########################
' #####  ScopeToken ()  #####
' ###########################

FUNCTION  ScopeToken (token)
	SHARED	T_AUTO
	SHARED	T_AUTOX
	SHARED	T_STATIC
	SHARED	T_SHARED
	SHARED	T_EXTERNAL

	return = 0
	token = token AND 0x1FFFFFFF

	SELECT CASE (token AND 0x1FFFFFFF)
		CASE T_AUTO			: return = token
		CASE T_AUTOX		: return = token
		CASE T_STATIC		: return = token
		CASE T_SHARED		: return = token
		CASE T_EXTERNAL	: return = token
	END SELECT
	RETURN (return)

END FUNCTION


' ########################
' #####  Shuffle ()  #####
' ########################

FUNCTION  Shuffle (areg, oreg, atype, ptype, argToken, kind, mode, argOffset)
	SHARED SSHORT typeConvert[]
	SHARED	reg86$[],  reg86c$[]
	SHARED	typeSize[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH
	SHARED	tokenPtr
	SHARED  lineNumber
	SHARED	nullstringer

	IF (kind AND 0x40) THEN by_ref = $$TRUE
	kind = kind AND 0x001F
	aa = argToken AND 0x0000FFFF
	IF (ptype = $$STRING) THEN string_type = $$TRUE
	IF (kind = $$KIND_ARRAYS) THEN atype = $$XLONG : ptype = $$XLONG

	IFZ string_type THEN
		IFZ by_ref THEN RETURN
		GOTO numeric_shuffle
	ENDIF

' deallocate strings passed by value

string_shuffle:
	IFZ by_ref THEN
		Code ($$ld, $$regro, $$esi, $$esp, argOffset, $$XLONG, @"", @"	;;; i871")
		Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"	;;; i872")
		RETURN
	ENDIF

' update numeric and string variables passed by reference

numeric_shuffle:
	IFZ by_ref THEN RETURN
	IF (aa = nullstringer) THEN RETURN
	IF (atype >= $$SCOMPLEX) THEN RETURN
	x_convert	= typeConvert[ptype, atype] {{$$BYTE0}}

	SELECT CASE ptype
		CASE $$DOUBLE
					Code ($$fld, $$ro, 0, $$esp, argOffset, $$DOUBLE, @"", @"	;;; i873")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					ENDIF
					Move (argToken, atype, $$esi, atype)
		CASE $$LONGDOUBLE
					Code ($$fld, $$ro, 0, $$esp, argOffset, $$LONGDOUBLE, @"", @"	;;; i873a")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					ENDIF
					Move (argToken, atype, $$esi, atype)
		CASE $$SINGLE
					Code ($$fld, $$ro, 0, $$esp, argOffset, $$SINGLE, @"", @"	;;; i874")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					ENDIF
					Move (argToken, atype, $$esi, atype)
		CASE $$GIANT
					Code ($$ld, $$regro, $$esi, $$esp, argOffset, $$XLONG, @"", @"	;;; i875")
					Code ($$ld, $$regro, $$edi, $$esp, argOffset+4, $$XLONG, @"", @"	;;; i876")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					ENDIF
					Move (argToken, atype, $$esi, atype)
		CASE ELSE
					Code ($$ld, $$regro, $$esi, $$esp, argOffset, $$XLONG, @"", @"	;;; i877")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					ENDIF
					Move (argToken, atype, $$esi, atype)
	END SELECT
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ########################
' #####  StackIt ()  #####
' ########################

FUNCTION  StackIt (to_type, source, from_type, offset)
	SHARED	toes,  a0,  a0_type,  a1,  a1_type
	SHARED	r_addr[],  reg86$[],  typeSize[]
	SHARED	XERROR,  ERROR_COMPILER

	ss	= source{$$NUMBER}
	rr	= r_addr[ss]
	SELECT CASE rr
		CASE $$RA0:	source = $$RA0: ss = $$RA0
		CASE $$RA1:	source = $$RA1: ss = $$RA1
		CASE ELSE:	Move ($$RA0, from_type, source, from_type)
								source = $$RA0: ss = $$RA0
								INC	toes
	END SELECT
	IF (to_type != from_type) THEN
		Conv (source, to_type, source, from_type)
	ENDIF
	dsize			= typeSize[to_type]
	SELECT CASE to_type
		CASE $$DOUBLE
					Code ($$fstp, $$ro, 0, $$esp, offset, $$DOUBLE, @"", @"	;;; i883")
					offset = offset + 8
		CASE $$LONGDOUBLE
					Code ($$fstp, $$ro, 0, $$esp, offset, $$LONGDOUBLE, @"", @"	;;; i883a")
					offset = offset + 12
		CASE $$SINGLE
					Code ($$fstp, $$ro, 0, $$esp, offset, $$SINGLE, @"", @"	;;; i884")
					offset = offset + 4
		CASE $$GIANT
					Code ($$st, $$roreg, ss, $$esp, offset, $$XLONG, @"", @"	;;; i885")
					offset	= offset + 4
					Code ($$st, $$roreg, ss+1, $$esp, offset, $$XLONG, @"", @"	;;; i886")
					offset	= offset + 4
		CASE ELSE
					Code ($$st, $$roreg, ss, $$esp, offset, $$XLONG, @"", @"	;;; i887")
					offset	= offset + 4
	END SELECT
	DEC toes
	a0 = 0
	a0_type = 0
	RETURN

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ################################
' #####  StatementExport ()  #####
' ################################

FUNCTION  StatementExport (token)
	SHARED	library
	SHARED	export
	SHARED	got_program
	SHARED	got_export
	SHARED	T_EXPORT
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_NEST
	SHARED	ERROR_PROGRAM_NOT_NAMED,  ERROR_TOO_LATE
	SHARED	ERROR_PROGRAM_NAME_MISMATCH
	SHARED	program$, programName$

	IF export THEN GOTO eeeNest
	IF got_function THEN GOTO eeeTooLate
	IFZ got_program THEN GOTO eeeProgramNotNamed
	IF program$ != programName$ THEN GOTO eeeProgramNameMismatch
	IF (token != T_EXPORT) THEN GOTO eeeCompiler
	got_export = $$TRUE
	export = $$TRUE
	RETURN ($$T_STARTS)

eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)

eeeNest:
	XERROR = ERROR_NEST
	RETURN ($$T_STARTS)

eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)

eeeProgramNameMismatch:
	XERROR = ERROR_PROGRAM_NAME_MISMATCH
	RETURN ($$T_STARTS)

eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)

END FUNCTION


' ################################
' #####  StatementImport ()  #####
' ################################

FUNCTION  StatementImport (token)
	SHARED	T_IMPORT
	SHARED	T_LIBRARY
	SHARED	got_declare
	SHARED	a0, a0_type, a1, a1_type
	SHARED	got_import
	SHARED	m_addr$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_SYNTAX,  ERROR_TOO_LATE

	IF ((token != T_IMPORT) AND (token != T_LIBRARY)) THEN GOTO eeeCompiler
	IF got_declare THEN GOTO eeeTooLate
	token = NextToken ()

	SELECT CASE token{$$KIND}
		CASE $$KIND_LITERALS	:	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeSyntax
														IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
														IF XERROR THEN RETURN ($$T_STARTS)
														XxxLoadLibrary (token)
														got_import = $$TRUE
		CASE ELSE							: GOTO eeeSyntax
	END SELECT
	RETURN ($$T_STARTS)

eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)

eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)

eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)
END FUNCTION


' #################################
' #####  StatementProgram ()  #####
' #################################

FUNCTION  StatementProgram (token)
	SHARED	library
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_DEFINITION
	SHARED	ERROR_OPEN_FILE,  ERROR_PROGRAM_NOT_NAMED
	SHARED	ERROR_SYNTAX,  ERROR_TOO_LATE,  ERROR_TYPE_MISMATCH
	SHARED	ERROR_PROGRAM_NAME_MISMATCH
	SHARED	got_declare,  got_export,  got_function
	SHARED	got_import,  got_program,  got_type
	SHARED	programToken
	SHARED  program$, programName$
	SHARED	T_PROGRAM
	SHARED	tab_sym$[]
	SHARED	m_addr$[]

	IF got_program THEN GOTO eeeDupDefinition
	IF (token != T_PROGRAM) THEN GOTO eeeCompiler
	IF (got_declare OR got_export OR got_function OR got_import OR got_type) THEN GOTO eeeTooLate

	token = NextToken ()
	IF (token{$$KIND} != $$KIND_LITERALS) THEN GOTO eeeSyntax
	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeTypeMismatch
	IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
	IF XERROR THEN RETURN ($$T_STARTS)
	program$ = tab_sym$[token AND 0x0000FFFF]
	program$ = TRIM$(MID$(program$,2,LEN(program$)-2))
	StripNonSymbol (@program$)
	IFZ program$ THEN GOTO eeeProgramNotNamed
	got_program = $$TRUE
	programToken = token
	IF program$ != programName$ THEN GOTO eeeProgramNameMismatch
	RETURN ($$T_STARTS)

' *****  Errors  *****

eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)

eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	RETURN ($$T_STARTS)

eeeOpenFile:
	XERROR = ERROR_OPEN_FILE
	RETURN ($$T_STARTS)

eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)

eeeProgramNameMismatch:
	XERROR = ERROR_PROGRAM_NAME_MISMATCH
	RETURN (ERROR_PROGRAM_NAME_MISMATCH)

eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)

eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	RETURN ($$T_STARTS)
END FUNCTION


' #################################
' #####  StatementVersion ()  #####
' #################################

FUNCTION  StatementVersion (token)
	SHARED	library
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_DEFINITION
	SHARED	ERROR_SYNTAX,  ERROR_TOO_LATE,  ERROR_TYPE_MISMATCH
	SHARED	got_declare,  got_export,  got_function
	SHARED	got_import,  got_program,  got_type
	SHARED	versionToken
	SHARED	T_VERSION
	SHARED	version$
	SHARED	tab_sym$[]
	SHARED	m_addr$[]

	IF version$ THEN GOTO eeeDupDefinition
	IF (token != T_VERSION) THEN GOTO eeeCompiler
	IF (got_declare OR got_export OR got_function OR got_import OR got_type) THEN GOTO eeeTooLate

	token = NextToken ()
	IF (token{$$KIND} != $$KIND_LITERALS) THEN GOTO eeeSyntax
	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeTypeMismatch
	IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
	IF XERROR THEN RETURN ($$T_STARTS)
	version$ = tab_sym$[token AND 0x0000FFFF]
	version$ = TRIM$(MID$(version$,2,LEN(version$)-2))
	versionToken = token
	RETURN ($$T_STARTS)

' *****  Errors  *****

eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)

eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	RETURN ($$T_STARTS)

eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)

eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	RETURN ($$T_STARTS)
END FUNCTION



' ###############################
' #####  StripNonSymbol ()  #####
' ###############################

FUNCTION  StripNonSymbol (name$)
	SHARED  UBYTE  charsetUpperLower[]
	SHARED  UBYTE  charsetUpperLowerNumeric[]

	IFZ name$ THEN RETURN
	upper = UBOUND (name$)

	first = -1
	FOR i = 0 TO upper
		IF charsetUpperLower[name${i}] THEN first = i : EXIT FOR
	NEXT i
	IF (first < 0) THEN name$ = "" : RETURN

	final = -1
	FOR i = first TO upper
		IFZ charsetUpperLowerNumeric[name${i}] THEN final = i-1 : EXIT FOR
	NEXT i
	IF (final < 0) THEN final = upper

	IFZ first THEN
		IF (final = upper) THEN RETURN				' no change
		name$ = LEFT$ (name$, final-first+1)	' strip right hand excess
	ELSE
		d = 0
		FOR i = first TO final
			name${d} = name${i}
			INC d
		NEXT i
		name${d} = 0x00
		name$ = LEFT$ (name$, d)
	ENDIF
END FUNCTION


' ###############################
' #####  TestForKeyword ()  #####
' ###############################

FUNCTION  TestForKeyword (symbol$)
	SHARED	alphaFirst[],  alphaLast[],  tab_sym$[],  tab_sym[],  tab_sys$[]
	SHARED	tab_sys[],  typeSymbol$[],  typeToken[]
	SHARED	charPtr,  pastSystemSymbols,  rawLength,  rawline$,  typePtr
	SHARED UBYTE  charsetSuffix[]

	IFZ symbol$ THEN RETURN ($$FALSE)
	SELECT CASE symbol${0}
		CASE '$':		IF (symbol${1} != '$') THEN RETURN ($$FALSE)
								gotSystemSymbol = $$TRUE												' $$
								x$	= symbol$
								x		= 0
		CASE '#':		IF (symbol${1} != '#') THEN RETURN ($$FALSE)
								gotSystemSymbol = $$TRUE												' ##
								x$	= symbol$
								x		= 0
		CASE '_':		RETURN ($$FALSE)
		CASE ELSE:	gotSystemSymbol = $$FALSE
								x$	= symbol$
								x		= x${0} - 64
								IF (x > 26) THEN x = x - 32
	END SELECT

	first	= alphaFirst[x]
	last	= alphaLast[x]
	x			= first
	token = 0

	charV = rawline${charPtr}
	IF (charV = '$') THEN
		sys$	= x$ + "$"
		xtra	= $$TRUE
	ELSE
		sys$	= x$
	ENDIF
	symbolLength = LEN (sys$)


' *****  See if valid $$SystemConstant or ##SystemVariable

	IF gotSystemSymbol THEN
		token = 0
		x = 0
		DO
			IF (tab_sym$[x] = sys$) THEN
				token = tab_sym[x]
				IF xtra THEN INC charPtr
				EXIT DO
			ENDIF
			INC x
		LOOP WHILE (x < pastSystemSymbols)
		RETURN (token)
	ENDIF


' *****  See if KEYWORD  *****

	DO
		IF (tab_sys$[x] = sys$) THEN
			token = tab_sys[x]
			IF xtra THEN INC charPtr
			RETURN (token)
		ENDIF
		INC x
	LOOP WHILE (x <= last)


' *****  See if user defined TYPE name  *****

	IF charsetSuffix[charV] THEN RETURN ($$FALSE)
	typeNumber	= $$SCOMPLEX
	DO WHILE (typeNumber < typePtr)
		IF (typeSymbol$[typeNumber] = symbol$) THEN
			token = typeToken[typeNumber]
			RETURN (token)
		ENDIF
		INC typeNumber
	LOOP
	RETURN ($$FALSE)
END FUNCTION


' ########################
' #####  TheType ()  #####
' ########################

FUNCTION  TheType (token)
	SHARED	defaultType[],  tabType[],  funcType[],  typeAlias[],  m_addr$[],  tab_sym$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	defaultType,  func_number
	STATIC GOADDR typeKind[]

	IFZ typeKind[] THEN GOSUB LoadTypeKind

	qtype = token{$$TYPE}										' type field from token
	IF qtype THEN RETURN (qtype)						' type was in token
	tt = token{$$NUMBER}										' token number
	kind = token{$$KIND}										' kind of token
	scope = token{$$ALLO}										' scope of token
	GOTO @typeKind [kind]										' figure type for this kind
	RETURN																	' no type for other kinds


' *****  Routines to figure type for all valid kinds  *****

type_arrays:
type_variables:
	qtype = tabType[tt]									' type = tabType[tt]
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type

' !!! totally nukes compiler !!!

'	IFZ m_addr$[tt] THEN AssignAddress (token)

'	IF ((scope == $$SHARED) OR (scope == $$EXTERNAL)) THEN
'		symbol$ = tab_sym$[tt]
'		IF (symbol${0} == '#') THEN
'			check = token AND 0x1FFF0000
'			alias = AddSymbol (@symbol$, check, 0)
'			alias = alias AND 0x1FFFFFFF
'			IF alias THEN aa = alias AND 0x0000FFFF
'			qtype = tabType[aa]
'			IF qtype THEN RETURN (qtype)
'		ENDIF
'	ENDIF

	SELECT CASE scope
		CASE $$SHARED			: RETURN (defaultType)
		CASE $$EXTERNAL		: RETURN (defaultType)
		CASE ELSE					: RETURN (defaultType[func_number])
	END SELECT
	RETURN (defaultType)								' return system-wide default type

type_literals:
type_constants:
	qtype = tabType[tt]									' type = tabType[tt]
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
	qtype = defaultType[func_number]		' type = defaultType for this function
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
	RETURN (defaultType)								' return system-wide default type

type_functions:
	qtype = funcType[tt]								' get type from funcType[] array
	IF qtype THEN RETURN (qtype)				' return declared function type
	RETURN ($$XLONG)										' return default function type

type_syscons:
	qtype = tabType[tt]									' type = tabType[tt]
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
	GOTO eeeCompiler										' no type at all  (compiler error)

type_bitcons:
type_charcons:
	RETURN ($$USHORT)										' all charcons and bitcons are USHORT

type_types:
	RETURN (tt)													' type of TYPE token

SUB LoadTypeKind
	DIM typeKind[31]
	typeKind [ $$KIND_VARIABLES			] = GOADDRESS (type_variables)
	typeKind [ $$KIND_CONSTANTS			] = GOADDRESS (type_constants)
	typeKind [ $$KIND_FUNCTIONS			] = GOADDRESS (type_functions)
	typeKind [ $$KIND_LITERALS			] = GOADDRESS (type_literals)
	typeKind [ $$KIND_CHARCONS			] = GOADDRESS (type_charcons)
	typeKind [ $$KIND_SYSCONS				] = GOADDRESS (type_syscons)
	typeKind [ $$KIND_ARRAYS				] = GOADDRESS (type_arrays)
	typeKind [ $$KIND_TYPES					] = GOADDRESS (type_types)
END SUB

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ####################
' #####  Tok ()  #####
' ####################

FUNCTION  Tok (symbol$, token, kind, raddr, value, value$)
	SHARED	r_addr[],  r_addr$[],  m_addr$[]
	SHARED	XERROR

	IF (kind = $$KIND_SYSCONS) THEN
		token = AddSymbol (@symbol$, token, 0)
		IF XERROR THEN EXIT FUNCTION
		tn = token{$$NUMBER}
		r_addr[tn]	= raddr
		r_addr$[tn]	= value$
		m_addr$[tn]	= "$$SYSCON"
	ELSE
		token = AddSymbol (@symbol$, token, 0)
		IF XERROR THEN EXIT FUNCTION
		AssignAddress (token)
	ENDIF
	RETURN (token)
END FUNCTION


' ################################
' #####  TokenRestOfLine ()  #####
' ################################

FUNCTION  TokenRestOfLine ()
	SHARED	tokens[]
	SHARED	charPtr,  rawLength,  rawline$,  tokenPtr

	x$	= MID$(rawline$, charPtr + 1) + NULL$(4)
	finalOffset = LEN(x$) - 4
	xa	= &x$
	c		= 0
	DO WHILE (c < finalOffset)
		x		= XLONGAT (xa, c)
		c		= c + 4
		INC tokenPtr
		tokens[tokenPtr] = x
	LOOP
	charPtr = rawLength
END FUNCTION


' ##############################
' #####  TokensDefined ()  #####
' ##############################

FUNCTION  TokensDefined ()
	SHARED	checkBounds
	SHARED	alphaFirst[],  alphaLast[]
	SHARED	m_reg[],  m_addr[],  m_addr$[],  r_addr[],  r_addr$[]
	SHARED	tab_lab[],  tab_lab$[],  labaddr[]
	SHARED	charToken[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_TESTL
	SHARED	T_NOT,      T_NOTL,       T_NOTBIT,     T_TILDA
	SHARED	T_AND,      T_ANDL,       T_ANDBIT
	SHARED	T_XOR,      T_XORL,       T_XORBIT
	SHARED	T_OR,       T_ORL,        T_ORBIT
	SHARED	T_ADDR_OP,  T_HANDLE_OP,  T_STORE_OP
	SHARED	T_EQ,   T_NE,   T_LT,   T_LE,   T_GE,   T_GT,  T_EQL
	SHARED	T_NEQ,  T_NNE,  T_NLT,  T_NLE,  T_NGE,  T_NGT
	SHARED	T_ABS,  T_ADD,  T_ALL,  T_ANY,  T_ASC,  T_ASM,  T_ATSIGN
	SHARED	T_ATTACH,  T_AUTO,  T_AUTOX,  T_BIN_D,  T_BINB_D,  T_BITFIELD
	SHARED	T_CEIL,  T_CASE,  T_CFUNCTION,  T_CHR_D,  T_CJUST_D,  T_CLR,  T_CLOSE
	SHARED	T_CMP,  T_COLON,  T_COMMA,  T_CONSOLE,  T_CSIZE,  T_CSIZE_D,  T_CSTRING_D
	SHARED	T_DEC,  T_DECLARE,  T_DHIGH,  T_DIM
	SHARED	T_DIV,  T_DLOW,  T_DMAKE,  T_DO,  T_DOLLAR,  T_DOT
	SHARED	T_DOUBLE,  T_DOUBLEAT,  T_DQUOTE,  T_DSHIFT
	SHARED	T_ELSE,  T_END,  T_ENDIF,  T_EOF,  T_ERROR,  T_ERROR_D
	SHARED	T_ETC,  T_EXIT,  T_EXPLICIT,  T_EXPORT,  T_EXTERNAL,  T_EXTS,  T_EXTU
	SHARED	T_FALSE,  T_FIX,  T_FOR,  T_FORMAT_D
	SHARED	T_FUNCADDR,  T_FUNCADDRAT,  T_FUNCADDRESS
	SHARED	T_FUNCTION
	SHARED	T_GHIGH,  T_GIANT,  T_GIANTAT,  T_GLOW,  T_GMAKE
	SHARED	T_GOADDR,  T_GOADDRAT,  T_GOADDRESS
	SHARED	T_GOSUB,  T_GOTO
	SHARED	T_HEX_D,  T_HEXX_D,  T_HIGH0,  T_HIGH1
	SHARED	T_IDIV,  T_IF,  T_IFF,  T_IFT,  T_IFZ,  T_IMPORT
	SHARED	T_INFILE_D,  T_INLINE_D
	SHARED	T_INC,  T_INCHR,  T_INCHRI,  T_INSTR,  T_INSTRI,  T_INT,  T_INTERNAL
	SHARED	T_LBRACE,  T_LBRACES,  T_LBRAK,  T_LCASE_D,  T_LCLIP_D,  T_LEFT_D
	SHARED	T_LEN,  T_LIBRARY,  T_LJUST_D,  T_LOF,  T_LOOP
	SHARED	T_LPAREN,  T_LSHIFT,  T_LTRIM_D
	SHARED	T_MAKE,  T_MAKEFILE,  T_MARK,  T_MAX,  T_MID_D,  T_MIN,  T_MINUS,  T_MOD,  T_MUL
'	SHARED	T_NEXT,  T_NOINIT, T_NULL_D,  T_OCT_D,  T_OCTO_D,  T_OPEN
	SHARED	T_NEXT,  T_NULL_D,  T_OCT_D,  T_OCTO_D,  T_OPEN
	SHARED	T_PACKED, T_PERCENT,  T_PLUS,  T_POF,  T_POUND,  T_POWER
	SHARED	T_PRINT,  T_PROGRAM,  T_PROGRAM_D,  T_QMARK,  T_QUIT
	SHARED	T_RBRACE,  T_RBRAK,  T_RCLIP_D,  T_READ,  T_REDIM,  T_REM
	SHARED	T_REMAINDER,  T_RETURN,  T_RIGHT_D
	SHARED	T_RINCHR,  T_RINCHRI,  T_RINSTR,  T_RINSTRI,  T_RJUST_D
	SHARED	T_ROTATEL,  T_ROTATER,  T_ROUND,  T_ROUNDNE,  T_RPAREN,  T_RSHIFT,  T_RTRIM_D
	SHARED	T_SBYTE,  T_SBYTEAT,  T_SEEK,  T_SELECT,  T_SEMI,  T_SET
	SHARED	T_SFUNCTION,  T_SGN,  T_SHARED,  T_SHELL
	SHARED	T_SIGN,  T_SIGNED_D,  T_SINGLE,  T_SINGLEAT
	SHARED	T_SIZE,  T_SLONG,  T_SLONGAT,  T_SMAKE,  T_SPACE_D
	SHARED	T_SSHORT,  T_SSHORTAT,  T_STATIC,  T_STEP,  T_STOP
	SHARED	T_STR_D,  T_STRING,  T_STRING_D,  T_STUFF_D,  T_SUB
	SHARED	T_SUBADDR,  T_SUBADDRAT,  T_SUBADDRESS
	SHARED	T_SUBTRACT,  T_SWAP
	SHARED	T_TAB,  T_THEN,  T_TICK,  T_TO,  T_TRIM_D,  T_TRUE,  T_TYPE,  T_UNION
	SHARED	T_UBOUND,  T_UBYTE,  T_UBYTEAT,  T_UCASE_D,  T_ULINE
	SHARED	T_ULONG,  T_ULONGAT,  T_UNTIL,  T_USHIFT
	SHARED	T_USHORT,  T_USHORTAT
	SHARED	T_VERSION,  T_VERSION_D,  T_VOID,  T_WHILE,  T_WRITE
	SHARED	T_XLONG,  T_XLONGAT,  T_XMAKE,  T_XMARK
	SHARED  T_LONGDOUBLE, T_LONGDOUBLEAT
	SHARED	nullstringer
	SHARED	pastSystemLabels,  pastSystemSymbols
	SHARED	tab_sym_ptr,  tab_sys_ptr,  xit
	SHARED	falseToken
	SHARED	entryCheckBounds
	SHARED UBYTE	charsetUpper[],  charsetUpperLower[]
	STATIC  notFirstTime,  x$
	EXTERNAL ##ERROR


' Put $$IMM16, $$NEG16, $$LITNUM, $$CONNUM in symbol table as 32 - 35

	r_addr[$$IMM16] = $$IMM16
	r_addr[$$NEG16] = $$NEG16
	r_addr[$$LITNUM] = $$LITNUM
	r_addr[$$CONNUM] = $$CONNUM

	tab_sym_ptr = 36
	nullstringer = 36
	alphaFirst[0] = 1
	tempAddr = externalAddr

	XstGetCommandLineArguments (@argc, @argv$[])
	##ERROR = $$FALSE

	GOSUB DefineSystemConstants						' Define system constants

' Put labels and their addresses into label symbol table (from asm libraries).

'	##ERROR = $$FALSE
'	IFZ xit THEN
'		past = GetExternalAddresses ()
'		IF ##ERROR THEN
'			PRINT "> Can't load external addresses.  Don't compile into memory!"
'			pastSystemLabels = 1
'		ENDIF
'		pastSystemLabels = past
'	ENDIF
'	##ERROR = $$FALSE
	externalAddr = tempAddr

	GOSUB DefineSystemConstants						' Define system constants

' *****  Test Only  *****

'	PRINT "TokensDefined():  "; past; " labels extracted from COFF executable."
	IF (argc > 1) THEN
		IF (TRIM$(argv$[1]) = "-xlabs") THEN
'		test$ = argv$[1]
'		test$ = TRIM$(test$)
'		IF (test$ = "-xlabs") THEN
			PRINT															' Bug
			FOR i = 0 TO past
					PRINT HEX$(tab_lab[i],8), HEX$(labaddr[i],8), tab_lab$[i]
			NEXT i
		ENDIF
	ENDIF

' *****  End Test  *****

' *************************************************************
' *****  THE REST OF THIS FUNCTION IS EXECUTED ONLY ONCE  *****
' *************************************************************

' ************************************************************************
' *****  Define all system tokens:  keywords, operators, characters  *****
' ************************************************************************

	IF notFirstTime THEN RETURN
	notFirstTime = $$TRUE
	entryCheckBounds = checkBounds

	tab_sys_ptr = 0
	alphaLast[0] = tab_sys_ptr - 1
	alphaFirst[1] = tab_sys_ptr
	T_ABS = MakeToken(@"ABS", $$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_ALL = MakeToken(@"ALL", $$KIND_STATEMENTS, 0)
	T_AND = MakeToken(@"AND", $$KIND_BINARY_OPS, $$COP3  OR $$PREC_AND)
	T_ANY = MakeToken(@"ANY", $$KIND_STATEMENTS, $$ANY)
	T_ASC = MakeToken(@"ASC", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_ASM	= MakeToken(@"ASM",	$$KIND_STATEMENTS, 0)
	T_ATTACH = MakeToken(@"ATTACH", $$KIND_STATEMENTS, 0)
	T_AUTO = MakeToken(@"AUTO", $$KIND_STATEMENTS, $$AUTO << 5)
	T_AUTOX = MakeToken(@"AUTOX", $$KIND_STATEMENTS, $$AUTOX << 5)
	alphaLast[1] = tab_sys_ptr - 1
	alphaFirst[2] = tab_sys_ptr
	T_BIN_D = MakeToken(@"BIN$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_BINB_D = MakeToken(@"BINB$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_BITFIELD = MakeToken(@"BITFIELD", $$KIND_INTRINSICS, $$ARGS2 OR $$USHORT)
	alphaLast[2] = tab_sys_ptr - 1
	alphaFirst[3] = tab_sys_ptr
	T_CASE = MakeToken(@"CASE", $$KIND_STATEMENTS, 0)
	T_CEIL   		= MakeToken(@"CEIL", 			$$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_CFUNCTION = MakeToken(@"CFUNCTION", $$KIND_STATEMENTS, 0)
	T_CHR_D = MakeToken(@"CHR$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_CJUST_D = MakeToken(@"CJUST$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_CLOSE = MakeToken(@"CLOSE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_CLR = MakeToken(@"CLR", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_CONSOLE = MakeToken(@"CONSOLE", $$KIND_STATEMENTS, 0)
	T_CSIZE = MakeToken(@"CSIZE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_CSIZE_D = MakeToken(@"CSIZE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_CSTRING_D = MakeToken(@"CSTRING$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[3] = tab_sys_ptr - 1
	alphaFirst[4] = tab_sys_ptr
	T_DEC = MakeToken(@"DEC", $$KIND_STATEMENTS, 0)
	T_DECLARE = MakeToken(@"DECLARE", $$KIND_STATEMENTS, 0)
	T_DHIGH = MakeToken(@"DHIGH", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_DIM = MakeToken(@"DIM", $$KIND_STATEMENTS, 0)
	T_DLOW = MakeToken(@"DLOW", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_DMAKE = MakeToken(@"DMAKE", $$KIND_INTRINSICS, $$ARGS2 OR $$DOUBLE)
	T_DO = MakeToken(@"DO", $$KIND_STATEMENTS, 0)
	T_DOUBLE = MakeToken(@"DOUBLE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$DOUBLE)
	T_DOUBLEAT = MakeToken(@"DOUBLEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$DOUBLE)
	alphaLast[4] = tab_sys_ptr - 1
	alphaFirst[5] = tab_sys_ptr
	T_ELSE = MakeToken(@"ELSE",     $$KIND_STATEMENTS, 0)
	T_END = MakeToken(@"END",      $$KIND_STATEMENTS, 0)
	T_ENDIF = MakeToken(@"ENDIF",    $$KIND_STATEMENTS, 0)
	T_EOF = MakeToken(@"EOF", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_ERROR = MakeToken(@"ERROR", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_ERROR_D = MakeToken(@"ERROR$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_EXIT = MakeToken(@"EXIT",     $$KIND_STATEMENTS, 0)
	T_EXPLICIT = MakeToken(@"EXPLICIT", $$KIND_STATEMENTS, 0)
	T_EXPORT = MakeToken(@"EXPORT", $$KIND_STATEMENTS, 0)
	T_EXTERNAL = MakeToken(@"EXTERNAL", $$KIND_STATEMENTS, $$EXTERNAL << 5)
	T_EXTS = MakeToken(@"EXTS",    $$KIND_INTRINSICS, $$ARGS3 OR $$SLONG)
	T_EXTU = MakeToken(@"EXTU",    $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	alphaLast[5] = tab_sys_ptr - 1
	alphaFirst[6] = tab_sys_ptr
	T_FALSE = MakeToken(@"FALSE", $$KIND_STATEMENTS, 0)
	T_FIX = MakeToken(@"FIX", $$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_FOR = MakeToken(@"FOR", $$KIND_STATEMENTS, 0)
	T_FORMAT_D = MakeToken(@"FORMAT$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_FUNCADDR = MakeToken(@"FUNCADDR", $$KIND_STATE_INTRIN, $$ARGS1 OR $$FUNCADDR)
	T_FUNCADDRAT = MakeToken(@"FUNCADDRAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$FUNCADDR)
	T_FUNCADDRESS = MakeToken(@"FUNCADDRESS", $$KIND_INTRINSICS, $$ARGS1 OR $$FUNCADDR)
	T_FUNCTION = MakeToken(@"FUNCTION", $$KIND_STATEMENTS, 0)
	alphaLast[6] = tab_sys_ptr - 1
	alphaFirst[7] = tab_sys_ptr
	T_GHIGH = MakeToken(@"GHIGH", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_GIANT = MakeToken(@"GIANT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$GIANT)
	T_GIANTAT = MakeToken(@"GIANTAT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$GIANT)
	T_GLOW = MakeToken(@"GLOW", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_GMAKE = MakeToken(@"GMAKE", $$KIND_INTRINSICS, $$ARGS2 OR $$GIANT)
	T_GOADDR = MakeToken(@"GOADDR", $$KIND_STATE_INTRIN, $$ARGS1 OR $$GOADDR)
	T_GOADDRAT = MakeToken(@"GOADDRAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$GOADDR)
	T_GOADDRESS = MakeToken(@"GOADDRESS", $$KIND_INTRINSICS, $$ARGS1 OR $$GOADDR)
	T_GOSUB = MakeToken(@"GOSUB", $$KIND_STATEMENTS, 0)
	T_GOTO = MakeToken(@"GOTO", $$KIND_STATEMENTS, 0)
	alphaLast[7] = tab_sys_ptr - 1
	alphaFirst[8] = tab_sys_ptr
	T_HEX_D = MakeToken(@"HEX$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_HEXX_D = MakeToken(@"HEXX$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_HIGH0 = MakeToken(@"HIGH0", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_HIGH1 = MakeToken(@"HIGH1", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	alphaLast[8] = tab_sys_ptr - 1
	alphaFirst[9] = tab_sys_ptr
	T_IF = MakeToken(@"IF", $$KIND_STATEMENTS, 0)
	T_IFF = MakeToken(@"IFF", $$KIND_STATEMENTS, 0)
	T_IFT = MakeToken(@"IFT", $$KIND_STATEMENTS, 0)
	T_IFZ = MakeToken(@"IFZ", $$KIND_STATEMENTS, 0)
	T_IMPORT = MakeToken(@"IMPORT", $$KIND_STATEMENTS, 0)
	T_INC = MakeToken(@"INC", $$KIND_STATEMENTS, 0)
	T_INCHR = MakeToken(@"INCHR", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INCHRI = MakeToken(@"INCHRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INFILE_D = MakeToken(@"INFILE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_INLINE_D = MakeToken(@"INLINE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_INSTR = MakeToken(@"INSTR", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INSTRI = MakeToken(@"INSTRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INT = MakeToken(@"INT", $$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_INTERNAL = MakeToken(@"INTERNAL", $$KIND_STATEMENTS, 0)
	alphaLast[9] = tab_sys_ptr - 1
	alphaFirst[10] = 0
	alphaLast[10] = -1
	alphaFirst[11] = tab_sys_ptr
	alphaLast[11] = -1
	alphaFirst[12] = tab_sys_ptr
	T_LCASE_D = MakeToken(@"LCASE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_LCLIP_D = MakeToken(@"LCLIP$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_LEFT_D = MakeToken(@"LEFT$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_LEN = MakeToken(@"LEN", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_LIBRARY = MakeToken(@"LIBRARY", $$KIND_STATE_INTRIN, $$ARGS1 OR $$XLONG)
	T_LJUST_D = MakeToken(@"LJUST$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_LOF = MakeToken(@"LOF", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_LONGDOUBLE = MakeToken(@"LONGDOUBLE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$LONGDOUBLE)
	T_LONGDOUBLEAT = MakeToken(@"LONGDOUBLEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$LONGDOUBLE)
	T_LOOP = MakeToken(@"LOOP", $$KIND_STATEMENTS, 0)
	T_LTRIM_D = MakeToken(@"LTRIM$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[12] = tab_sys_ptr - 1
	alphaFirst[13] = tab_sys_ptr
	T_MAKE = MakeToken(@"MAKE", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_MAKEFILE = MakeToken(@"MAKEFILE", $$KIND_STATEMENTS, $$ARGS1 OR $$STRING)
	T_MAX = MakeToken(@"MAX", $$KIND_INTRINSICS, $$ARGS2 OR $$TYPE_INPUT)
	T_MID_D = MakeToken(@"MID$", $$KIND_INTRINSICS, $$ARGS3 OR $$STRING)
	T_MIN = MakeToken(@"MIN", $$KIND_INTRINSICS, $$ARGS2 OR $$TYPE_INPUT)
	T_MOD = MakeToken(@"MOD", $$KIND_BINARY_OPS, $$COP6 OR $$PREC_MOD)
	alphaLast[13] = tab_sys_ptr - 1
	alphaFirst[14] = tab_sys_ptr
	T_NEXT = MakeToken(@"NEXT", $$KIND_STATEMENTS, 0)
'	T_NOINIT = MakeToken("NOINIT", $$KIND_STATEMENTS, 0)
	T_NOT = MakeToken(@"NOT", $$KIND_UNARY_OPS, $$COPA OR $$PREC_NOT)
	T_NULL_D = MakeToken(@"NULL$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[14] = tab_sys_ptr - 1
	alphaFirst[15] = tab_sys_ptr
	T_OCT_D = MakeToken(@"OCT$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_OCTO_D = MakeToken(@"OCTO$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_OPEN = MakeToken(@"OPEN", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_OR = MakeToken(@"OR", $$KIND_BINARY_OPS, $$COP3 OR $$PREC_OR)
	alphaLast[15] = tab_sys_ptr - 1
	alphaFirst[16] = tab_sys_ptr
	T_PACKED = MakeToken(@"PACKED", $$KIND_STATEMENTS, 0)
	T_POF = MakeToken(@"POF", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_PRINT = MakeToken(@"PRINT",		$$KIND_STATEMENTS, 0)
	T_PROGRAM = MakeToken(@"PROGRAM",	$$KIND_STATEMENTS, 0)
	T_PROGRAM_D = MakeToken(@"PROGRAM$",	$$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[16] = tab_sys_ptr - 1
	alphaFirst[17] = tab_sys_ptr
	T_QUIT = MakeToken(@"QUIT", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	alphaLast[17] = tab_sys_ptr - 1
	alphaFirst[18] = tab_sys_ptr
	T_RCLIP_D = MakeToken(@"RCLIP$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_READ = MakeToken(@"READ",    $$KIND_STATEMENTS, 0)
	T_REDIM = MakeToken(@"REDIM",   $$KIND_STATEMENTS, 0)
	T_RETURN = MakeToken(@"RETURN",  $$KIND_STATEMENTS, 0)
	T_RIGHT_D = MakeToken(@"RIGHT$",  $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_RINCHR = MakeToken(@"RINCHR",  $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RINCHRI = MakeToken(@"RINCHRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RINSTR = MakeToken(@"RINSTR",  $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RINSTRI = MakeToken(@"RINSTRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RJUST_D = MakeToken(@"RJUST$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_ROTATEL = MakeToken(@"ROTATEL", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_ROTATER = MakeToken(@"ROTATER", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_ROUND   	= MakeToken(@"ROUND", 		$$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_ROUNDNE 	= MakeToken(@"ROUNDNE", 	$$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_RTRIM_D = MakeToken(@"RTRIM$",  $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[18] = tab_sys_ptr - 1
	alphaFirst[19] = tab_sys_ptr
	T_SBYTE = MakeToken(@"SBYTE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SBYTE)
	T_SBYTEAT = MakeToken(@"SBYTEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SBYTE)
	T_SEEK = MakeToken(@"SEEK", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_SELECT = MakeToken(@"SELECT", $$KIND_STATEMENTS, 0)
	T_SET = MakeToken(@"SET", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_SFUNCTION = MakeToken(@"SFUNCTION", $$KIND_STATEMENTS, 0)
	T_SGN = MakeToken(@"SGN", $$KIND_INTRINSICS, $$ARGS1 OR $$SLONG)
	T_SHARED = MakeToken(@"SHARED", $$KIND_STATEMENTS, $$SHARED << 5)
	T_SHELL = MakeToken(@"SHELL", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_SIGN = MakeToken(@"SIGN", $$KIND_INTRINSICS, $$ARGS1 OR $$SLONG)
	T_SIGNED_D = MakeToken(@"SIGNED$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_SINGLE = MakeToken(@"SINGLE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SINGLE)
	T_SINGLEAT = MakeToken(@"SINGLEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SINGLE)
	T_SIZE = MakeToken(@"SIZE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_SLONG = MakeToken(@"SLONG", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SLONG)
	T_SLONGAT = MakeToken(@"SLONGAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SLONG)
	T_SMAKE = MakeToken(@"SMAKE", $$KIND_INTRINSICS, $$ARGS1 OR $$SINGLE)
	T_SPACE_D = MakeToken(@"SPACE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_SSHORT = MakeToken(@"SSHORT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SSHORT)
	T_SSHORTAT = MakeToken(@"SSHORTAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SSHORT)
	T_STATIC = MakeToken(@"STATIC", $$KIND_STATEMENTS, $$STATIC << 5)
	T_STEP = MakeToken(@"STEP", $$KIND_STATEMENTS, 0)
	T_STOP = MakeToken(@"STOP", $$KIND_STATEMENTS, 0)
	T_STR_D = MakeToken(@"STR$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_STRING = MakeToken(@"STRING", $$KIND_STATE_INTRIN, $$ARGS1 OR $$STRING)
	T_STRING_D = MakeToken(@"STRING$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_STUFF_D = MakeToken(@"STUFF$", $$KIND_INTRINSICS, $$ARGS4 OR $$STRING)
	T_SUB = MakeToken(@"SUB", $$KIND_STATEMENTS, 0)
	T_SUBADDR = MakeToken(@"SUBADDR", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SUBADDR)
	T_SUBADDRAT = MakeToken(@"SUBADDRAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SUBADDR)
	T_SUBADDRESS = MakeToken(@"SUBADDRESS", $$KIND_INTRINSICS, $$ARGS1 OR $$SUBADDR)
	T_SWAP = MakeToken(@"SWAP", $$KIND_STATEMENTS, 0)
	alphaLast[19] = tab_sys_ptr - 1
	alphaFirst[20] = tab_sys_ptr
	T_TAB = MakeToken(@"TAB", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_THEN = MakeToken(@"THEN", $$KIND_STATEMENTS, 0)
	T_TO = MakeToken(@"TO", $$KIND_STATEMENTS, 0)
	T_TRIM_D = MakeToken(@"TRIM$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_TRUE = MakeToken(@"TRUE", $$KIND_STATEMENTS, 0)
	T_TYPE = MakeToken(@"TYPE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$XLONG)
	alphaLast[20] = tab_sys_ptr - 1
	alphaFirst[21] = tab_sys_ptr
	T_UBOUND = MakeToken(@"UBOUND", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_UBYTE = MakeToken(@"UBYTE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$UBYTE)
	T_UBYTEAT = MakeToken(@"UBYTEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$UBYTE)
	T_UCASE_D = MakeToken(@"UCASE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_ULONG = MakeToken(@"ULONG", $$KIND_STATE_INTRIN, $$ARGS1 OR $$ULONG)
	T_ULONGAT = MakeToken(@"ULONGAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$ULONG)
	T_UNION = MakeToken(@"UNION", $$KIND_STATEMENTS, 0)
	T_UNTIL = MakeToken(@"UNTIL", $$KIND_STATEMENTS, 0)
	T_USHORT = MakeToken(@"USHORT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$USHORT)
	T_USHORTAT = MakeToken(@"USHORTAT",	$$KIND_STATE_INTRIN, $$ARGS2 OR $$USHORT)
	alphaLast[21] = tab_sys_ptr - 1
	alphaFirst[22] = tab_sys_ptr
	T_VERSION = MakeToken(@"VERSION", $$KIND_STATEMENTS, 0)
	T_VERSION_D = MakeToken(@"VERSION$",	$$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_VOID = MakeToken(@"VOID", $$KIND_STATEMENTS, $$VOID)
	alphaLast[22] = tab_sys_ptr - 1
	alphaFirst[23] = tab_sys_ptr
	T_WHILE = MakeToken(@"WHILE", $$KIND_STATEMENTS, 0)
	T_WRITE = MakeToken(@"WRITE", $$KIND_STATEMENTS, 0)
	alphaLast[23] = tab_sys_ptr - 1
	alphaFirst[24] = tab_sys_ptr
	T_XLONG = MakeToken(@"XLONG", $$KIND_STATE_INTRIN, $$ARGS1 OR $$XLONG)
	T_XLONGAT = MakeToken(@"XLONGAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$XLONG)
	T_XMAKE = MakeToken(@"XMAKE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_XOR = MakeToken(@"XOR", $$KIND_BINARY_OPS, $$COP3 OR $$PREC_XOR)
	alphaLast[24] = tab_sys_ptr - 1
	alphaFirst[25] = 0
	alphaLast[25] = -1
	alphaFirst[26] = 0
	alphaLast[26] = -1
	alphaFirst[27] = tab_sys_ptr

' *****  Bitwise  *****

	T_TILDA			= MakeToken(@"~",    $$KIND_UNARY_OPS,  $$COPA OR $$PREC_TILDA)
	T_NOTBIT		= MakeToken(@"~",    $$KIND_UNARY_OPS,  $$COPA OR $$PREC_NOTBIT)
	T_ANDBIT		= MakeToken(@"&",    $$KIND_BINARY_OPS, $$COP3 OR $$PREC_ANDBIT)
	T_XORBIT		= MakeToken(@"^",    $$KIND_BINARY_OPS, $$COP3 OR $$PREC_XORBIT)
	T_ORBIT			= MakeToken(@"|",    $$KIND_BINARY_OPS, $$COP3 OR $$PREC_ORBIT)

' *****  Logical  *****

	T_TESTL			= MakeToken(@"!!",   $$KIND_UNARY_OPS,  $$COP9 OR $$PREC_TESTL)
	T_NOTL			= MakeToken(@"!",    $$KIND_UNARY_OPS,  $$COP9 OR $$PREC_NOTL)
	T_ANDL			= MakeToken(@"&&",   $$KIND_BINARY_OPS, $$COP1 OR $$PREC_ANDL)
	T_XORL			= MakeToken(@"^^",   $$KIND_BINARY_OPS, $$COP1 OR $$PREC_XORL)
	T_ORL				= MakeToken(@"||",   $$KIND_BINARY_OPS, $$COP1 OR $$PREC_ORL)

' *****  Comparison  *****

	T_EQL				= MakeToken(@"==",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_EQL)
	T_EQ				= MakeToken(@"=",    $$KIND_BINARY_OPS, $$COP2 OR $$PREC_EQ)
	T_LT				= MakeToken(@"<",    $$KIND_BINARY_OPS, $$COP2 OR $$PREC_LT)
	T_GT				= MakeToken(@">",    $$KIND_BINARY_OPS, $$COP2 OR $$PREC_GT)
	T_NE				= MakeToken(@"<>",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NE)
	T_LE				= MakeToken(@"<=",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_LE)
	T_GE				= MakeToken(@">=",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_GE)
	T_NEQ				= MakeToken(@"!=",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NEQ)
	T_NNE				= MakeToken(@"!<>",  $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NNE)
	T_NLT				= MakeToken(@"!<",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NLT)
	T_NGT				= MakeToken(@"!>",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NGT)
	T_NLE				= MakeToken(@"!<=",  $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NLE)
	T_NGE				= MakeToken(@"!>=",  $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NGE)

' *****  Shift  *****

	T_RSHIFT		= MakeToken(@">>",   $$KIND_BINARY_OPS, $$COP7 OR $$PREC_RSHIFT)
	T_LSHIFT		= MakeToken(@"<<",   $$KIND_BINARY_OPS, $$COP7 OR $$PREC_LSHIFT)
	T_DSHIFT		= MakeToken(@">>>",  $$KIND_BINARY_OPS, $$COP7 OR $$PREC_DSHIFT)
	T_USHIFT		= MakeToken(@"<<<",  $$KIND_BINARY_OPS, $$COP7 OR $$PREC_USHIFT)

' *****  Arithmetic  *****

	T_SUBTRACT	= MakeToken(@"-",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_SUBTRACT)
	T_ADD				= MakeToken(@"+",		$$KIND_BINARY_OPS, $$COP5 OR $$PREC_ADD)
	T_IDIV			= MakeToken(@"\\",		$$KIND_BINARY_OPS, $$COP6 OR $$PREC_IDIV)	' xx6n
	T_MUL				= MakeToken(@"*",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_MUL)
	T_DIV				= MakeToken(@"/",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_DIV)
	T_POWER			= MakeToken(@"**",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_POWER)
	T_PLUS			= MakeToken(@"+",		$$KIND_UNARY_OPS,  $$COP8 OR $$PREC_UNARY)
	T_MINUS			= MakeToken(@"-",		$$KIND_UNARY_OPS,  $$COP8 OR $$PREC_UNARY)

' *****  Address  *****

	T_ADDR_OP		= MakeToken(@"&",		$$KIND_ADDR_OPS,		$$COPB OR $$PREC_ADDR_OP)
	T_HANDLE_OP	= MakeToken(@"&&",		$$KIND_ADDR_OPS,		$$COPB OR $$PREC_HANDLE_OP)
	T_STORE_OP	= MakeToken(@"",			$$KIND_ADDR_OPS,		$$COPB OR $$PREC_STORE_OP)

' *****  Symbols  *****

	T_LPAREN		= MakeToken(@"(",    $$KIND_LPARENS,		0)
	T_RPAREN		= MakeToken(@")",    $$KIND_RPARENS,		0)
	T_COMMA			= MakeToken(@",",    $$KIND_SEPARATORS,	0)
	T_SEMI			= MakeToken(@";",    $$KIND_SEPARATORS,	0)
	T_COLON			= MakeToken(@":",    $$KIND_TERMINATORS,0)
	T_REM				= MakeToken(@"'",    $$KIND_COMMENTS,		0)
	T_PERCENT		= MakeToken(@"%",    $$KIND_CHARACTERS,	0)
	T_XMARK			= MakeToken(@"!",    $$KIND_CHARACTERS,	0)
	T_ATSIGN		= MakeToken(@"@",    $$KIND_CHARACTERS,	0)
	T_POUND			= MakeToken(@"#",    $$KIND_CHARACTERS,	0)
	T_DOLLAR		= MakeToken(@"$",    $$KIND_CHARACTERS,	0)
	T_DQUOTE		= MakeToken(@"\"",   $$KIND_CHARACTERS,	0)
	T_DOT				= MakeToken(@".",    $$KIND_CHARACTERS,	0)
	T_LBRAK			= MakeToken(@"[",    $$KIND_LPARENS,		0)
	T_RBRAK			= MakeToken(@"]",    $$KIND_RPARENS,		0)
	T_LBRACE		= MakeToken(@"{",    $$KIND_LPARENS,		0)
	T_RBRACE		= MakeToken(@"}",    $$KIND_RPARENS,		0)
	T_LBRACES		= MakeToken(@"{{",   $$KIND_LPARENS,		0)
	T_ULINE			= MakeToken(@"_",    $$KIND_CHARACTERS,	0)
	T_QMARK			= MakeToken(@"?",    $$KIND_CHARACTERS,	0)
	T_TICK			= MakeToken(@"`",    $$KIND_CHARACTERS,	0)
	T_MARK			= MakeToken(@"\x7F", $$KIND_CHARACTERS,	0)
	T_ETC				= MakeToken(@"...",  $$KIND_CHARACTERS,	$$ETC)
	T_CMP				= MakeToken(@"::",   $$KIND_BINARY_OPS,	$$COP2 OR $$PREC_EQ)

	alphaLast[27] = tab_sys_ptr - 1


' *****************************************************************************
' *****  Load array charToken[] with tokens that stand for one character  *****
' *****************************************************************************

	DIM charToken[255]
'																		' 00 - 32 don't have tokens
	charToken [  33 ] = T_NOTL
	charToken [  34 ] = T_DQUOTE
	charToken [  35 ] = T_POUND
	charToken [  36 ] = T_DOLLAR
	charToken [  37 ] = T_PERCENT
	charToken [  38 ] = T_ANDBIT
	charToken [  39 ] = T_REM
	charToken [  40 ] = T_LPAREN
	charToken [  41 ] = T_RPAREN
	charToken [  42 ] = T_MUL
	charToken [  43 ] = T_ADD
	charToken [  44 ] = T_COMMA
	charToken [  45 ] = T_SUBTRACT
	charToken [  46 ] = T_DOT
	charToken [  47 ] = T_DIV
'																		' 48 - 57 don't have tokens:  ("0" - "9")
	charToken [  58 ] = T_COLON
	charToken [  59 ] = T_SEMI
	charToken [  60 ] = T_LT
	charToken [  61 ] = T_EQ
	charToken [  62 ] = T_GT
	charToken [  63 ] = T_QMARK
	charToken [  64 ] = T_ATSIGN
'																		' 65 - 90 don't have tokens:  ("A" - "Z")
	charToken [  91 ] = T_LBRAK
	charToken [  92 ] = T_IDIV
	charToken [  93 ] = T_RBRAK
	charToken [  94 ] = T_XORBIT
	charToken [  95 ] = T_ULINE
	charToken [  96 ] = T_TICK
'																		' 97 - 122 don't have tokens:  ("a" - "z")
	charToken [ 123 ] = T_LBRACE
	charToken [ 124 ] = T_ORBIT
	charToken [ 125 ] = T_RBRACE
	charToken [ 126 ] = T_NOTBIT
	charToken [ 127 ] = T_MARK
	RETURN														' 128 - 255 don't have tokens


' *****  DefineSystemConstants  *****				' Don't change spaces in strings

SUB DefineSystemConstants
	t = Tok (@"\"\"",		0x0C730000, $$KIND_SYSCONS, $$IMM16,  0, "0")
	t = Tok (@"$$TRUE",	0x0C680000, $$KIND_SYSCONS, $$NEG16, -1, "-1")
	t = Tok (@"$$FALSE", 0x0C680000, $$KIND_SYSCONS, $$IMM16,  0, "0")
	falseToken = t

	tn = t{$$NUMBER}
	pastSystemSymbols = tn + 1
END SUB


' *****  ERRORS  *****

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ####################
' #####  Top ()  #####
' ####################

FUNCTION  Top ()
	SHARED	a0,  a1,  toes

	IF a0 AND (a0 = toes) THEN RETURN ($$R10)
	IF a1 AND (a1 = toes) THEN RETURN ($$R12)
	RETURN (0)
END FUNCTION


' #######################
' #####  Topax1 ()  #####
' #######################

FUNCTION  Topax1 ()
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type
	SHARED	stackType[]

	SELECT CASE TRUE
		CASE (a0 AND (a0 = toes))
			DEC toes: a0 = 0: a0_type = 0: RETURN ($$RA0)
		CASE (a1 AND (a1 = toes))
			DEC toes: a1 = 0: a1_type = 0: RETURN ($$RA1)
		CASE ELSE
			IFZ toes THEN GOTO eeeCompiler
			IFZ toms THEN GOTO eeeCompiler
			Pop ($$RA0, stackType[toms-1])
			a0 = 0:	a0_type = 0
			RETURN ($$RA0)
	END SELECT

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #######################
' #####  Topax2 ()  #####
' #######################

FUNCTION  Topax2 (topa, topb)
	SHARED	stackType[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toms,  toes,  a0,  a0_type,  a1,  a1_type

	IF (toes < 2) THEN GOTO eeeCompiler
	SELECT CASE TRUE
		CASE (a0 = toes)
					DEC toes: topa = $$R10: a0 = 0: a0_type = 0
					IFZ a1 THEN Pop ($$RA1, stackType[toms-1])
					DEC toes: topb = $$R12: a1 = 0: a1_type = 0
		CASE (a1 = toes)
					DEC toes: topa = $$R12: a1 = 0: a1_type = 0
					IFZ a0 THEN Pop ($$RA0, stackType[toms-1])
					DEC toes: topb = $$R10: a0 = 0: a0_type = 0
		CASE ELSE
					PRINT "Topax2": GOTO eeeCompiler
	END SELECT
	RETURN (topa)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' ########################
' #####  Topaccs ()  #####
' ########################

FUNCTION  Topaccs (topa, topb)
	SHARED	stackType[]
	SHARED	toms,  toes,  a0,  a0_type,  a1,  a1_type
	SHARED	XERROR,  ERROR_COMPILER

	SELECT CASE TRUE
		CASE (a0 AND (a0 = toes))
			topa = $$R10
			IF (toes > 1) THEN
				topb = $$R12
				IFZ a1 THEN
					IFZ toms THEN GOTO eeeCompiler
					Pop ($$RA1, stackType[toms-1])
					a1 = toes - 1
				ENDIF
			ELSE
				topb = 0
			ENDIF
			RETURN ($$R10)
		CASE (a1 AND (a1 = toes))
			topa = $$R12
			IF (toes > 1) THEN
				topb = $$R10
				IFZ a0 THEN
					IFZ toms THEN GOTO eeeCompiler
					Pop ($$RA0, stackType[toms-1])
					a0 = toes - 1
				ENDIF
			ELSE
				topb = 0
			ENDIF
			RETURN ($$R12)
		CASE ELSE
			topa = 0
			topb = 0
	END SELECT
	RETURN (topa)

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION


' #####################
' #####  Topx ()  #####
' #####################

FUNCTION  Topx (tr, trx, nr, nrx)
	SHARED	a0,  a1,  toes

	IFZ toes THEN
		tr = 0: trx = 0:
		nr = 0: nrx = 0
		RETURN (0)
	ENDIF
	IF (a0 AND (a0 = toes)) THEN
		tr = $$R10: trx = $$R11
		IF (a1 AND (a1 = toes - 1)) THEN
			nr = $$R12: nrx = $$R13
		ELSE
			nr = 0: nrx = 0
		ENDIF
		RETURN ($$R10)
	ENDIF
	IF (a1 AND (a1 = toes)) THEN
		tr = $$R12: trx = $$R13
		IF (a0 AND (a0 = toes - 1)) THEN
			nr = $$R10: nrx = $$R11
		ELSE
			nr = 0: nrx = 0
		ENDIF
		RETURN ($$R12)
	ENDIF
	RETURN (0)
END FUNCTION


' ##########################
' #####  TypeToken ()  #####
' ##########################

FUNCTION  TypeToken (token)
	SHARED	T_VOID,  T_SBYTE,  T_UBYTE,  T_SSHORT,  T_USHORT
	SHARED	T_SLONG,  T_ULONG,  T_XLONG,  T_GOADDR,  T_SUBADDR,  T_FUNCADDR
	SHARED	T_SINGLE,  T_DOUBLE,  T_GIANT,  T_STRING,  T_LONGDOUBLE

	return = 0
	token = token AND 0x1FFFFFFF

	SELECT CASE token
		CASE T_VOID					: return = token
		CASE T_SBYTE				: return = token
		CASE T_UBYTE				: return = token
		CASE T_SSHORT				: return = token
		CASE T_USHORT				: return = token
		CASE T_SLONG				: return = token
		CASE T_ULONG				: return = token
		CASE T_XLONG				: return = token
		CASE T_GOADDR				: return = token
		CASE T_SUBADDR			: return = token
		CASE T_FUNCADDR			: return = token
		CASE T_SINGLE				: return = token
		CASE T_DOUBLE				: return = token
		CASE T_GIANT				: return = token
		CASE T_STRING				: return = token
		CASE T_LONGDOUBLE		: return = token
	END SELECT
	RETURN (return)
END FUNCTION


' ##############################
' #####  TypenameToken ()  #####
' ##############################

FUNCTION  TypenameToken (token)
	SHARED	T_VOID,  T_ETC,  T_SBYTE,  T_UBYTE,  T_SSHORT,  T_USHORT
	SHARED	T_SLONG,  T_ULONG,  T_XLONG,  T_GOADDR,  T_SUBADDR,  T_FUNCADDR
	SHARED	T_GIANT,  T_SINGLE,  T_DOUBLE,  T_STRING,  T_LONGDOUBLE

	IF (token{$$KIND} = $$KIND_TYPES) THEN		' *****  USER DEFINED TYPE  *****
		dataType = token{$$NUMBER}
		token = NextToken ()
		RETURN (dataType)
	ENDIF
	SELECT CASE token
		CASE T_VOID, T_ETC,  T_SBYTE, T_UBYTE, T_SSHORT, T_USHORT
		CASE T_SLONG, T_ULONG, T_XLONG, T_GOADDR, T_SUBADDR, T_FUNCADDR
		CASE T_SINGLE, T_DOUBLE, T_GIANT, T_STRING, T_LONGDOUBLE
		CASE ELSE:		RETURN (0)
	END SELECT
	dataType = token{$$TYPE}
	token = NextToken ()
	RETURN (dataType)
END FUNCTION


' ####################
' #####  Uop ()  #####
' ####################

FUNCTION  Uop (rad, the_op, rax, d_type, o_type, x_type)
	SHARED	reg86$[],  reg86c$[]
	SHARED	r_addr$[]
	SHARED	T_TESTL
	SHARED	T_NOT,      T_NOTL,       T_NOTBIT,     T_TILDA
	SHARED	T_ADDR_OP,  T_HANDLE_OP,  T_STORE_OP
	SHARED	T_EQ,   T_NE,   T_LT,   T_LE,   T_GE,   T_GT,   T_EQL
	SHARED	T_NEQ,  T_NNE,  T_NLT,  T_NLE,  T_NGE,  T_NGT
	SHARED	T_MINUS,  T_PLUS
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_NEG_ULONG,  ERROR_TYPE_MISMATCH
	SHARED	a0_type,  a1_type,  tokenPtr,  labelNumber
	STATIC GOADDR opToken[]

	IFZ opToken[] THEN GOSUB LoadOpToken

	SELECT CASE rad
		CASE $$RA0:	d_reg = $$RA0:	a0_type = d_type
		CASE $$RA1:	d_reg = $$RA1:	a1_type = d_type
		CASE ELSE:	PRINT "uop1": GOTO eeeCompiler
	END SELECT
	d_regx = d_reg + 1

	SELECT CASE rax
		CASE $$RA0:	x_reg = $$RA0: IF (d_reg != x_reg) THEN GOTO eeeCompiler
		CASE $$RA1:	x_reg = $$RA1: IF (d_reg != x_reg) THEN GOTO eeeCompiler
		CASE ELSE:	GOTO eeeCompiler
	END SELECT
	x_regx = x_reg + 1


' ************************************************************
' *****  DISPATCH TO APPROPRIATE UNARY OPERATOR ROUTINE  *****
' ************************************************************

	GOTO @opToken [the_op AND 0x00FF]
	PRINT "uop dispatch"
	GOTO eeeCompiler


' *************************
' *****  LOGICAL NOT  *****
' *************************

unary_not:
	SELECT CASE o_type
		CASE $$SLONG:		GOSUB Logical_Not_LONG
		CASE $$ULONG:		GOSUB Logical_Not_LONG
		CASE $$XLONG:		GOSUB Logical_Not_LONG
		CASE $$GIANT:		GOSUB Logical_Not_GIANT
		CASE $$SINGLE:	GOSUB Logical_Not_DOUBLE
		CASE $$DOUBLE:	GOSUB Logical_Not_DOUBLE
		CASE $$LONGDOUBLE:	GOSUB Logical_Not_LONGDOUBLE
		CASE ELSE:			PRINT "uuu4a": GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN

SUB Logical_Not_LONG
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i888")
	Code ($$cmc, 0, 0, 0, 0, 0, @"", @"	;;; i889")
	Code ($$rcr, $$regimm, x_reg, 1, 0, $$XLONG, @"", @"	;;; i890")
	Code ($$sar, $$regimm, x_reg, 31, 0, $$XLONG, @"", @"	;;; i891")
END SUB

SUB Logical_Not_GIANT
	Code ($$or, $$regreg, x_reg, x_regx, 0, $$XLONG, @"", @"	;;; i892")
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i893")
	Code ($$cmc, 0, 0, 0, 0, 0, @"", @"	;;; i894")
	Code ($$rcr, $$regimm, x_reg, 1, 0, $$XLONG, @"", @"	;;; i895")
	Code ($$sar, $$regimm, x_reg, 31, 0, $$XLONG, @"", @"	;;; i896")
END SUB

SUB Logical_Not_DOUBLE
	d1$ = CreateLabel$ ()
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, @"", @"")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i173")
	Code ($$mov, $$regimm, d_reg, -1, 0, $$XLONG, @"", @"	;;; i898")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i899")
	Code ($$sahf, 0, 0, 0, 0, 0, @"", @"	;;; i900")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i901")
	Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i902")
	EmitLabel (@d1$)
END SUB

SUB Logical_Not_LONGDOUBLE
	d1$ = CreateLabel$ ()
	Code ($$fldz, $$none, 0, 0, 0, $$LONGDOUBLE, @"", @"	;;; i902a")
	Code ($$fcompp, $$none, 0, 0, 0, $$LONGDOUBLE, @"", @"	;;; i902b")
	Code ($$mov, $$regimm, d_reg, -1, 0, $$XLONG, @"", @"	;;; i902c")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i902d")
	Code ($$sahf, 0, 0, 0, 0, 0, @"", @"	;;; i902e")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i902f")
	Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i902g")
	EmitLabel (@d1$)
END SUB


' **************************
' *****  LOGICAL TEST  *****
' **************************

unary_test:
	SELECT CASE o_type
		CASE $$SLONG:		GOSUB Logical_Test_LONG
		CASE $$ULONG:		GOSUB Logical_Test_LONG
		CASE $$XLONG:		GOSUB Logical_Test_LONG
		CASE $$GIANT:		GOSUB Logical_Test_GIANT
		CASE $$SINGLE:	GOSUB Logical_Test_DOUBLE
		CASE $$DOUBLE:	GOSUB Logical_Test_DOUBLE
		CASE ELSE:			PRINT "uuu4b": GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN

SUB Logical_Test_LONG
	Code ($$neg, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i903")
	Code ($$rcr, $$regimm, d_reg, 1, 0, $$XLONG, @"", @"	;;; i904")
	Code ($$sar, $$regimm, d_reg, 31, 0, $$XLONG, @"", @"	;;; i905")
END SUB

SUB Logical_Test_GIANT
	Code ($$or, $$regreg, d_reg, x_regx, 0, $$XLONG, @"", @"	;;; i906")
	Code ($$neg, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i907")
	Code ($$rcr, $$regimm, d_reg, 1, 0, $$XLONG, @"", @"	;;; i908")
	Code ($$sar, $$regimm, d_reg, 31, 0, $$XLONG, @"", @"	;;; i909")
END SUB

SUB Logical_Test_DOUBLE
	d1$ = CreateLabel$ ()
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, @"", @"")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, @"", @"	;;; i173")
	Code ($$xor, $$regreg, d_reg, d_reg, 0, $$XLONG, @"", @"	;;; i911")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, @"", @"	;;; i912")
	Code ($$sahf, 0, 0, 0, 0, 0, @"", @"	;;; i913")
	Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"	;;; i914")
	Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, @"", @"	;;; i915")
	EmitLabel (@d1$)
END SUB


' ************************
' *****  UNARY PLUS  *****
' ************************

unary_plus:
	the_op = 0
	RETURN


' *************************
' *****  UNARY MINUS  *****
' *************************

unary_minus:
	SELECT CASE o_type
		CASE $$SLONG:		GOSUB Unary_Minus_SLONG
		CASE $$XLONG:		GOSUB Unary_Minus_XLONG
		CASE $$GIANT:		GOSUB Unary_Minus_GIANT
		CASE $$SINGLE:	GOSUB Unary_Minus_SINGLE
		CASE $$DOUBLE:	GOSUB Unary_Minus_DOUBLE
		CASE $$LONGDOUBLE:	GOSUB Unary_Minus_LONGDOUBLE
		CASE $$ULONG:		GOTO  eeeNegULONG
		CASE ELSE:			PRINT "uuu4":	GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN

SUB Unary_Minus_SLONG
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i916")
END SUB

SUB Unary_Minus_XLONG
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i917")
END SUB

SUB Unary_Minus_GIANT
	Code ($$neg, $$reg, x_regx, 0, 0, $$XLONG, @"", @"	;;; i918")
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i919")
	Code ($$sbb, $$regimm, x_regx, 0, 0, $$XLONG, @"", @"	;;; i920")
END SUB

SUB Unary_Minus_SINGLE
	Code ($$fchs, 0, 0, 0, 0, $$DOUBLE, @"", @"	;;; i921")
END SUB

SUB Unary_Minus_DOUBLE
	Code ($$fchs, 0, 0, 0, 0, $$DOUBLE, @"", @"	;;; i922")
END SUB

SUB Unary_Minus_LONGDOUBLE
	Code ($$fchs, 0, 0, 0, 0, $$LONGDOUBLE, @"", @"	;;; i922a")
END SUB

' *************************
' *****  BITWISE NOT  *****
' *************************

unary_notbit:
	SELECT CASE o_type
		CASE $$GIANT:		GOSUB Notbit_GIANT
		CASE $$SINGLE:	DEC tokenPtr: GOTO eeeTypeMismatch
		CASE $$DOUBLE:	DEC tokenPtr: GOTO eeeTypeMismatch
		CASE ELSE:			GOSUB Notbit_LONG
	END SELECT
	the_op = 0
	RETURN

SUB Notbit_LONG
	Code ($$not, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i923")
END SUB

SUB Notbit_GIANT
	Code ($$not, $$reg, x_reg, 0, 0, $$XLONG, @"", @"	;;; i924")
	Code ($$not, $$reg, x_regx, 0, 0, $$XLONG, @"", @"	;;; i925")
END SUB


' ************************************************
' *****  Load UNARY OPERATOR dispatch array  *****
' ************************************************

SUB LoadOpToken
	DIM opToken[255]
	opToken [ T_NOTL		AND 0x00FF ] = GOADDRESS (unary_not)
	opToken [ T_TESTL		AND 0x00FF ] = GOADDRESS (unary_test)
	opToken [ T_PLUS		AND 0x00FF ] = GOADDRESS (unary_plus)
	opToken [ T_MINUS		AND 0x00FF ] = GOADDRESS (unary_minus)
	opToken [ T_NOTBIT	AND 0x00FF ] = GOADDRESS (unary_notbit)
	opToken [ T_TILDA		AND 0x00FF ] = GOADDRESS (unary_notbit)
	opToken [ T_NOT			AND 0x00FF ] = GOADDRESS (unary_notbit)
END SUB


' **************************
' *****  UNARY ERRORS  *****
' **************************

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeNegULONG:
	XERROR = ERROR_NEG_ULONG
	EXIT FUNCTION

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION


' ############################
' #####  UpdateToken ()  #####
' ############################

FUNCTION  UpdateToken (token)
	SHARED	tab_sym[]

	x = token{$$NUMBER}
	tab_sym[x] = token
END FUNCTION



' ##################################
' #####  WriteDeclarationFile  #####
' ##################################

FUNCTION  WriteDeclarationFile (string$)
	SHARED  library
	SHARED  declareCount
	SHARED  declare$[]

	IFZ string$ THEN RETURN

' put string$ in declare$[] that will become "prog.dec" file

	upper = UBOUND (declare$[])
	IF (declareCount > upper) THEN
		upper = upper + 64
		REDIM declare$[upper]
	ENDIF

	declare$[declareCount] = string$
	INC declareCount

END FUNCTION


' #################################
' #####  WriteDefinitionFile  #####
' #################################

FUNCTION  WriteDefinitionFile (string$)
	SHARED  library
	SHARED  export$[]
	SHARED  import$[]
	SHARED  exportCount
	SHARED  importCount

	IFZ string$ THEN RETURN

	export = INSTR (string$, "EXPORT")
	IF (export = 1) THEN
		upper = UBOUND (export$[])
		IF (exportCount > upper) THEN
			upper = upper + 64
			REDIM export$[upper]
		ENDIF
		export$[exportCount] = string$
		INC exportCount
		RETURN
	ENDIF

	import = INSTR (string$, "IMPORT")
	IF (import = 1) THEN
		upper = UBOUND (import$[])
		IF (importCount > upper) THEN
			upper = upper + 64
			REDIM import$[upper]
		ENDIF
		import$[importCount] = string$
		INC importCount
		RETURN
	ENDIF

	PRINT "> WriteDefinitionFile() : error : string does not start with EXPORT or IMPORT : "; string$
END FUNCTION

' #############################
' #####  XxxCheckLine ()  #####
' #############################

FUNCTION  XxxCheckLine (lineNum, tok[])
	SHARED	XERROR,  tokenCount,  lineNumber,  tokens[]
	SHARED	pass2errors,  ERROR_UNDEFINED

	lineNumber = lineNum
	utok = UBOUND(tok[])
	FOR i = 0 TO utok
		token = tok[i]
		IFZ token THEN token = $$T_STARTS
		tokens[i] = token
	NEXT i
	tokens[i] = $$T_STARTS
	tokenCount = i AND 0x00FF
	CheckOneLine ()
	IF pass2errors THEN RETURN (ERROR_UNDEFINED)
	RETURN (XERROR)
END FUNCTION


' #####################################
' #####  XxxCloseCompileFiles ()  #####
' #####################################

FUNCTION  XxxCloseCompileFiles ()
	SHARED  library
	SHARED  ofile
	SHARED  asmFile$
	SHARED  version$
	SHARED  programName$
	SHARED  fileName$
	SHARED  export$[]
	SHARED  import$[]
	SHARED  declare$[]
	SHARED  exportCount
	SHARED  importCount
	SHARED  declareCount
	SHARED	export

	p$ = fileName$
	IFZ p$ THEN p$ = programName$
	IFZ p$ THEN p$ = "NoName"

' close the "prog.s" file

	IF (ofile > 2) THEN CLOSE (ofile)
	asmFile$ = ""
	ofile = 0

' save "prog.dec" file if declare$[] has contents

	IF declareCount THEN
		file$ = p$ + ".dec"
		REDIM declare$[declareCount]
		XstSaveStringArray (@file$, @declare$[])
	ENDIF
	DIM declare$[]
	declareCount = 0

' save "prog.def" file if export$[] or import$[] has contents

	IF (exportCount OR importCount) THEN
		IF library THEN
			prog$ = "LIBRARY  " + p$
		ELSE
			prog$ = "PROGRAM  " + p$
		ENDIF

		vers$ = version$
		IFZ vers$ THEN vers$ = "0.0000"
		vers$ = "VERSION  " + vers$

		upper = exportCount + importCount + 2
		DIM def$[upper]
		def$[0] = prog$
		def$[1] = vers$

		REDIM export$[exportCount-1]
		REDIM import$[importCount-1]
		XstQuickSort (@export$[], @n[], 0, exportCount-1, 0)
		XstQuickSort (@import$[], @n[], 0, importCount-1, 0)

		def = 2
		FOR i = 0 TO exportCount-1
			def$[def] = export$[i]
			INC def
		NEXT i

		FOR i = 0 TO importCount-1
			def$[def] = import$[i]
			INC def
		NEXT i

		file$ = p$ + ".def"
		XstSaveStringArray (@file$, @def$[])
	ENDIF

	export = 0
	exportCount = 0
	importCount = 0
	DIM export$[]
	DIM import$[]
END FUNCTION


' ######################################
' #####  XxxCreateCompileFiles ()  #####
' ######################################

FUNCTION  XxxCreateCompileFiles ()
	SHARED  ofile
	SHARED  asmFile$
	SHARED  programName$
	SHARED	fileName$
	SHARED	XERROR,  ERROR_OPEN_FILE,  ERROR_PROGRAM_NOT_NAMED

	IF (ofile > 0) THEN PRINT "b" : RETURN
	IFZ fileName$ THEN fileName$ = programName$
	IFZ fileName$ THEN GOTO eeeProgramNotNamed
	asmFile$ = fileName$ + ".asm"

	ofile = OPEN (asmFile$, $$WRNEW)
	IF (ofile < 0) THEN ofile = 0 : GOTO eeeOpenFile
	RETURN


' *****  Errors  *****

eeeOpenFile:
	XERROR = ERROR_OPEN_FILE
	RETURN ($$T_STARTS)

eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)
END FUNCTION


' ###############################
' #####  XxxLoadLibrary ()  #####
' ###############################

FUNCTION  XxxLoadLibrary (token)
	SHARED  library
	SHARED	a0,  a0_type,  a1,  a1_type
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED  libraryExt$[]	'newimport
	SHARED	programName$
	SHARED	prologCode
	SHARED	inTYPE,  labelNumber,  lineNumber,  parse_got_function
	SHARED	tab_sym$[],  tokens[],  tokenPtr,  tokenCount,  stopComment
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_FILE_NOT_FOUND
	FUNCADDR	addr ()
	SHARED  xfile$
	SHARED  fExitNow, fConsole
	EXTERNAL ##ERROR

	handle = 0
	##ERROR = $$FALSE

	libname$ = tab_sym$[token{$$NUMBER}]
	libname$ = TRIM$(MID$(libname$,2,LEN(libname$)-2))
	IFZ libname$ THEN PRINT "XxxLoadLibrary(): Error: (empty libname$)" : GOTO eeeCompiler

	dot = INSTR (libname$, ".")
'newimport - start
	IF dot THEN
		libext$ = LCASE$(MID$(libname$, dot+1))
		libname$ = LEFT$(libname$, dot-1)
	ENDIF
	IFZ libext$ THEN libext$ = "dll"
'newimport - end
	library$ = libname$ + ".dec"
	dllname$ = libname$ + ".dll"

	IF libraryName$[] THEN
		upper = UBOUND (libraryName$[])
		FOR i = 0 TO upper
			IF (libname$ = libraryName$[i]) THEN
				IF libraryHandle[i] THEN RETURN			' library already compiled
				IF libraryCode$[i,] THEN parsed = $$TRUE
				EXIT FOR
			ENDIF
		NEXT i
		libraryNumber = i
	ELSE
		libraryNumber = 0
	ENDIF

	IF parsed THEN
		SWAP lib$[], libraryCode$[i,]
	ELSE
		ifile = OPEN (library$, $$RD)
		IF (ifile <= 0) THEN
			' Retry in XBasic system directory.
			library$ = ##XBDir$ + "\\include\\" + libname$ + ".dec"
			ifile = OPEN (library$, $$RD)
		ENDIF
		IF (ifile <= 0) THEN PRINT library$; " not found." : GOTO eeeFileNotFound
		length = LOF (ifile)
		lib$ = NULL$ (length)
		READ [ifile], lib$
		CLOSE (ifile)
		XstStringToStringArray (@lib$, @lib$[])		' lib$[] = file "libname.DEC"
		IFZ lib$[] THEN PRINT library$; " is empty." : GOTO eeeFileNotFound
	ENDIF

	upperLib = UBOUND (lib$[])								' last line in file "libname.DEC"
	holdLine = lineNumber											' hold line number
	holdTokenPtr = tokenPtr										' hold current token pointer
	holdTokenCount = tokenCount								' hold current token count
	holdParseFunc = parse_got_function				' hold parse_got_function variable
	holdxfile$ = xfile$                       ' hold xfile$
	DIM bs[255] : SWAP bs[], tokens[]					' hold compiling line of tokens[]
	tokenPtr = 0															' pretend it's token 0
	tokenCount = 0														' pretend it's token 0
	lineNumber = 0														' pretend it's line 0
	parse_got_function = 0										' pretend it's PROLOG

					SELECT CASE LCASE$(libname$)
						CASE "xlib", "xst"
						CASE ELSE
									IFZ prologCode THEN
										EmitAsm (@".code")
										SELECT CASE TRUE
											CASE library	:  Code ($$jmp, $$rel, 0, 0, 0, 0, "%_StartLibrary_" + programName$, @"	;;; i36a")
											CASE ELSE			:  Code ($$jmp, $$rel, 0, 0, 0, 0, @"%_StartApplication", @"	;;; i37a")
										END SELECT
										prologCode = $$TRUE
										EmitLabel ("PrologCode." + programName$)
										Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, @"", @"	;;; i38")
										Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, @"", @"	;;; i39")
										Code ($$sub, $$regimm, $$esp, 256, 0, $$XLONG, @"", @"	;;; i40")

									ENDIF
									IF libext$ = "dll" THEN 'newimport
										Move ($$eax, $$XLONG, token, $$XLONG)
										Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
										Code ($$call, $$rel, 0, 0, 0, 0, @"_XxxXstLoadLibrary@4", @"")
										lib$ = tab_sym$[token AND 0x0000FFFF]
										IFZ (XxxLibraryAPI(@lib$)) THEN
											d1$ = CreateLabel$ ()
											d2$ = CreateLabel$ ()
											Code ($$test, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
											Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d2$, @"	;;; i40a")
											Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
											Code ($$mov, $$regimm, $$eax, 0, 0, $$XLONG, "addr @_string.StartLibrary." + programName$, @"")
											Move ($$ebx, $$XLONG, token, $$XLONG)
											Code ($$call, $$rel, 0, 0, 0, 0, @"%_concat.string.a0.eq.a0.plus.a1.vv", @"")
											Code ($$pop, $$reg, $$ebx, 0, 0, $$XLONG, @"", @"")
											Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
											Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, @"", @"")
											Code ($$push, $$reg, $$ebx, 0, 0, $$XLONG, @"", @"")
											Code ($$call, $$rel, 0, 0, 0, 0, @"_GetProcAddress@8", @"")
											Code ($$test, $$regreg, $$eax, $$eax, 0, $$XLONG, @"", @"")
											Code ($$jz, $$rel, 0, 0, 0, 0, "> " + d1$, @"")
											Code ($$call, $$reg, $$eax, 0, 0, 0, @"", @"")
											EmitLabel (@d1$)
											Code ($$pop, $$reg, $$esi, 0, 0, $$XLONG, @"", @"")
											Code ($$call, $$rel, 0, 0, 0, 0, @"%____free", @"")
											EmitLabel (@d2$)
										ENDIF
									ENDIF             'newimport
									a0 = 0 : a0_type = 0
									a1 = 0 : a1_type = 0
					END SELECT

	upper = UBOUND (libraryName$[])
	IF (libraryNumber > upper) THEN
		REDIM libraryCode$[libraryNumber, ]			' libname.DEC source code arrays
		REDIM libraryName$[libraryNumber]				' libname string array
		REDIM libraryHandle[libraryNumber]			' libname.DLL handle array
		REDIM libraryExt$[libraryNumber]				' newimport
		libraryExt$[libraryNumber] = libext$		' newimport
		libraryName$[libraryNumber] = libname$	' save libname string (no extent)
	ENDIF
	libraryHandle[libraryNumber] = handle			' save libname.DLL handle

	stopComment = $$TRUE											' don't emit asm for library comments
	i = 0
	DO
		line$ = TRIM$ (lib$[i])
		t = INSTR (line$, "TYPE")
    IF t != 1 THEN t = INSTR (line$, "PACKED")
		IF (t = 1) THEN GOSUB GetType : INC i : DO LOOP
		c = INSTR (line$, "$$")
		IF (c = 1) THEN GOSUB GetConstant : INC i : DO LOOP
		INC i
	LOOP WHILE (i <= upperLib)

	stopComment = $$FALSE
	lineNumber = holdLine											' restore line number
	tokenPtr = holdTokenPtr										' restore current token pointer
	tokenCount = holdTokenCount								' restore current token count
	parse_got_function = holdParseFunc				' restore parse_got_function variable
	xfile$ = holdxfile$                       ' restore xfile$
	SWAP bs[], tokens[] : DIM bs[]						' restore compiling line of tokens[]
	ATTACH lib$[] TO libraryCode$[libraryNumber, ]	' keep "libname.DEC" for future reference
	RETURN


' *****  GetType  *****

SUB GetType
	DO
		line$ = TRIM$(lib$[i])									' next source line string
		XxxParseSourceLine (line$, @tok[])			' type declaration line to tokens
		IF tok[] THEN	XxxCheckLine (0, @tok[])	' compile the tokens
' new 2005/04/14
' there seems to be no graceful way to
' recover from errors in a TYPE - END TYPE block in a DEC file
' so here we will just exit the program at this line
    IF XERROR THEN
      lineNumber = i + 1    ' set new error line number
      xfile$ = library$     ' set name of dec file
      fExitNow = $$TRUE     ' exit now
      IFZ fConsole THEN PRINT "Error : Syntax error in TYPE block, see: "; xfile$
      RETURN
    ENDIF

		IFZ inTYPE THEN EXIT DO									' processed END TYPE
'		IF XERROR THEN
'			IF PrintError (XERROR) THEN RETURN		' print error and count it
'		ENDIF
		INC i																		' next source line index
	LOOP WHILE (i < upperLib)
END SUB


' *****  GetConstant  *****

SUB GetConstant
	XxxParseSourceLine (line$, @tok[])
	IF tok[] THEN XxxCheckLine (0, @tok[])

' new 2005/04/14
' add error messages for DEC file constant errors
  IF XERROR THEN
    lineNumber = i + 1
    xfile$ = library$
    IF PrintError (XERROR) THEN RETURN
  ENDIF
END SUB


' *****  Errors  *****

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeFileNotFound:
	XERROR = ERROR_FILE_NOT_FOUND
	EXIT FUNCTION
END FUNCTION


' ##############################
' #####  XxxLibraryAPI ()  #####
' ##############################

FUNCTION  XxxLibraryAPI (lib$)
	STATIC	lib$[]

	IFZ lib$ THEN RETURN
	IFZ lib$[] THEN XstLoadStringArray (@"\\xblite\\templates\\syslib.xxx", @lib$[])
	IFZ lib$[] THEN RETURN

	upper = UBOUND (lib$)
	IF (lib${upper} = '"') THEN lib$ = RCLIP$(lib$,1)
	IF (lib${0} = '"') THEN lib$ = LCLIP$(lib$,1)

	FOR i = 0 TO UBOUND (lib$[])
		IF (lib$ = lib$[i]) THEN RETURN ($$TRUE)
	NEXT i
END FUNCTION


' ################################
' #####  XxxParseLibrary ()  #####
' ################################

' The TYPE statements in IMPORT libraries have to be parsed before
' the body of the main program because otherwise type names defined
' in IMPORT libraries are parsed into $$KIND_SYMBOLS tokens in the
' main program instead of the correct $$KIND_TYPES tokens.  This
' causes errors in the main program compilation because type names
' are treated as symbols, not types.

FUNCTION  XxxParseLibrary (token)
	SHARED  library
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED	libraryExt$[] 'newimport
	SHARED	prologCode
	SHARED	inTYPE,  labelNumber,  lineNumber,  parse_got_function
	SHARED	tab_sym$[],  tokens[],  tokenPtr,  tokenCount,  stopComment
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_FILE_NOT_FOUND
	EXTERNAL ##ERROR

	##ERROR = $$FALSE
	libname$ = tab_sym$[token{$$NUMBER}]
	libname$ = TRIM$(MID$(libname$,2,LEN(libname$)-2))

	IFZ libname$ THEN
		PRINT "XxxParseLibrary(): Error: (empty libname$)"
		GOTO eeeFileNotFound
	ENDIF

	dot = INSTR (libname$, ".")
'newimport - start
	IF dot THEN
		libext$ = LCASE$(MID$(libname$, dot+1))
		libname$ = LEFT$(libname$, dot-1)
	ENDIF
	IFZ libext$ THEN libext$ = "dll"
'newimport - end
	library$ = libname$ + ".dec"
	dllname$ = libname$ + ".dll"

	IF libraryName$[] THEN
		upper = UBOUND (libraryName$[])
		FOR i = 0 TO upper
			IF (libname$ = libraryName$[i]) THEN
				IF libraryCode$[i,] THEN RETURN				' library already parsed
				EXIT FOR
			ENDIF
		NEXT i
		libraryNumber = i
	ELSE
		libraryNumber = 0
	ENDIF

	ifile = OPEN (library$, $$RD)
	IF (ifile <= 0) THEN
		' Retry in XBasic system directory.
		library$ = ##XBDir$ + "\\include\\" + libname$ + ".dec"
		ifile = OPEN (library$, $$RD)
	ENDIF
	IF (ifile <= 0) THEN PRINT library$; " not found." : GOTO eeeFileNotFound
	length = LOF (ifile)
	lib$ = NULL$ (length)
	READ [ifile], lib$
	CLOSE (ifile)

	XstStringToStringArray (@lib$, @lib$[])		' lib$[] = file "libname.DEC"
	IFZ lib$[] THEN PRINT library$; " is empty." : GOTO eeeFileNotFound
	upperLib = UBOUND (lib$[])								' last line in file "libname.DEC"

	holdLine = lineNumber											' hold line number
	holdTokenPtr = tokenPtr										' hold current token pointer
	holdTokenCount = tokenCount								' hold current token count
	holdParseFunc = parse_got_function				' hold parse_got_function variable
	DIM bs[255] : SWAP bs[], tokens[]					' hold compiling line of tokens[]
	tokenPtr = 0															' pretend it's token 0
	tokenCount = 0														' pretend it's token 0
	lineNumber = 0														' pretend it's line 0
	parse_got_function = 0										' pretend it's PROLOG

	upper = UBOUND (libraryName$[])
	IF (libraryNumber > upper) THEN
		REDIM libraryCode$[libraryNumber, ]			' libname.DEC source code arrays
		REDIM libraryName$[libraryNumber]				' libname string array
		REDIM libraryHandle[libraryNumber]			' libname.DLL handle array
		REDIM libraryExt$[libraryNumber]				'newimport
		libraryExt$[libraryNumber] = libext$		'newimport
		libraryName$[libraryNumber] = libname$	' save libname string (no extent)
	ENDIF

	stopComment = $$TRUE											' don't emit asm for library comments
	i = 0
	DO
		line$ = TRIM$ (lib$[i])
		t = INSTR (line$, "TYPE")
    IF t != 1 THEN t = INSTR (line$, "PACKED")
		IF (t = 1) THEN XxxParseSourceLine (line$, @tok[])
		INC i
	LOOP WHILE (i <= upperLib)

	stopComment = $$FALSE
	lineNumber = holdLine											' restore line number
	tokenPtr = holdTokenPtr										' restore current token pointer
	tokenCount = holdTokenCount								' restore current token count
	parse_got_function = holdParseFunc				' restore parse_got_function variable
	SWAP bs[], tokens[] : DIM bs[]						' restore compiling line of tokens[]
	ATTACH lib$[] TO libraryCode$[libraryNumber, ]	' keep "libname.DEC" for pass 1
	RETURN


' *****  Errors  *****

eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION

eeeFileNotFound:
	XERROR = ERROR_FILE_NOT_FOUND
	EXIT FUNCTION
END FUNCTION


' ###################################
' #####  XxxParseSourceLine ()  #####
' ###################################

FUNCTION  XxxParseSourceLine (sourceLine$, tok[])
	SHARED	rawLength,  rawline$

	rawline$ = sourceLine$
	rawLength = LEN(rawline$)
	ParseLine (@tok[])
END FUNCTION



' ######################################
' #####  XxxUndeclaredFunction ()  #####
' ######################################

FUNCTION  XxxUndeclaredFunction (funcToken)
	SHARED	library
	SHARED	UBYTE  charsetSymbol[]
	SHARED	funcSymbol$[]
	SHARED	funcToken[]
	SHARED	labaddr[]
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED	libraryDeclaration
	SHARED	libraryFunctionLabel$
	SHARED	parse_got_function
	SHARED	got_function
	SHARED	func_number
	SHARED	lineNumber
	SHARED	tokenCount
	SHARED	tokenPtr
	SHARED	tokens[]
	SHARED	XERROR,  ERROR_DUP_LABEL,  ERROR_PROGRAM_NOT_NAMED

	match = $$FALSE														' funcName not found yet
	funcNumber = funcToken{$$NUMBER}					' function number
	funcSymbol$ = funcSymbol$[funcNumber]			' function symbol
	length = LEN(funcSymbol$)									' length of function symbol
	IFZ libraryCode$[] THEN RETURN						' no libraries
	IFZ libraryName$[] THEN RETURN						' ditto
	IFZ libraryHandle[] THEN RETURN						' ditto

	lastLibrary = UBOUND (libraryName$[])			' last library number
	FOR lib = 0 TO lastLibrary								' look through all libraries
		IFZ libraryCode$[lib,] THEN DO NEXT			' no libname.DEC source code
		libraryName$ = libraryName$[lib]				' get libname string
		IFZ libraryName$ THEN DO NEXT						' no libname string
		handle = libraryHandle[lib]							' get library handle
		ATTACH libraryCode$[lib,] TO library$[]	' get library source
		upperLine = UBOUND (library$[])					' last line in this library
		FOR i = 0 TO upperLine									' look through entire library
			n = INSTR(library$[i], funcSymbol$)		' match function name
			IFZ n THEN DO NEXT										' no match
			f = INSTR(library$[i], "FUNCTION")		' find FUNCTION keyword
			IFZ f THEN DO NEXT										' no match
			e = INSTR(library$[i], "EXTERNAL")		' find EXTERNAL keyword
			IFZ e THEN DO NEXT										' no match
			l = INSTR(library$[i], "(")						' find left parenthesis
			IFZ l THEN DO NEXT										' no match
			IF (e > f) THEN DO NEXT								' EXTERNAL before FUNCTION
			IF (f > n) THEN	DO NEXT								' FUNCTION before funcName
			IF (n > l) THEN	DO NEXT								' funcName before "("
			library$ = library$[i]								' library$ = library source line
			before = ASC(library$,n-1)						' byte before funcName
			after = ASC(library$,n+length)				' byte after funcName
			IF charsetSymbol[before] THEN DO NEXT	' funcName inside funcName
			IF charsetSymbol[after] THEN DO NEXT	' funcName inside funcName
			match = $$TRUE												' found desired function declaraction
			holdLine = lineNumber									' hold line number
			holdFunc = func_number								' hold current func number
			holdTokenPtr = tokenPtr								' hold current token pointer
			holdTokenCount = tokenCount						' hold current token count
			holdGotFunc = got_function						' hold got_function variable
			holdParseFunc = parse_got_function		' hold parse_got_function variable
			DIM bs[255] : SWAP bs[], tokens[]			' hold compiling line of tokens[]
			tokenPtr = 0													' pretend it's token 0
			tokenCount = 0												' pretend it's token 0
			lineNumber = 0												' pretend it's line 0
			func_number = 0												' pretend it's PROLOG
			got_function = 0											' pretend it's PROLOG
			parse_got_function = 0								' pretend it's PROLOG
			XxxParseSourceLine (library$, @tok[])	' library source line to tokens
			IF tok[] THEN													' collect new PROLOG tokens
				tokenPtr = 0												' pretend it's line start
				lineNumber = 0											' pretend it's line 0
				func_number = 0											' pretend it's PROLOG
				got_function = 0										' pretend it's PROLOG
				parse_got_function = 0							' pretend it's PROLOG
				libraryDeclaration = $$TRUE					' notify library declaration
				XxxCheckLine (0, @tok[])						' compile the tokens
				libraryDeclaration = $$FALSE				' cancel library declaration

				SELECT CASE LCASE$ (libraryName$)
					CASE "xlib", "xst"
								dll$ = "xbl"
					CASE ELSE
								dll$ = libraryName$
				END SELECT
				string$ = "IMPORTS  " + dll$ + "." + funcSymbol$
				WriteDefinitionFile (@string$)

				parse_got_function = holdParseFunc	' restore real parse_got_function
				got_function = holdGotFunc					' restore real got_function
				func_number = holdFunc							' restore real func number
				lineNumber = holdLine								' restore real line number
				tokenPtr = holdTokenPtr							' restore real token pointer
				tokenCount = holdTokenCount					' restore real token count
				SWAP bs[], tokens[] : DIM bs[]			' restore compiling line tokens[]
			ENDIF
			EXIT FOR															' done... got library declaration
		NEXT i																	' next source line in this library
		ATTACH library$[] TO libraryCode$[lib,]	' replace libname.DEC source
		IF XERROR THEN EXIT FUNCTION						' AddLabel error
		IF match THEN EXIT FOR									' found declaration - skip rest of libraries
	NEXT lib																	' next library

	token = funcToken[funcNumber]							' get updated func token
	RETURN (token)														' return updated func token


eeeDupLabel:
	XERROR = ERROR_DUP_LABEL
	RETURN ($$T_STARTS)

eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)
END FUNCTION



' ##################################
' #####  StatementMakefile ()  #####
' ##################################

FUNCTION  StatementMakefile (token)
	SHARED	library
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_DEFINITION
	SHARED	ERROR_SYNTAX,  ERROR_TOO_LATE,  ERROR_TYPE_MISMATCH
	SHARED	got_declare,  got_export,  got_function
	SHARED	got_import,  got_program,  got_type
	SHARED	makefileToken
	SHARED	T_MAKEFILE
	SHARED	makefile$
	SHARED	tab_sym$[]
	SHARED	m_addr$[]

	IF makefile$ THEN GOTO eeeDupDefinition
	IF (token != T_MAKEFILE) THEN GOTO eeeCompiler
'	IF (got_declare OR got_export OR got_function OR got_import OR got_type) THEN GOTO eeeTooLate
	IF (got_function) THEN GOTO eeeTooLate

	token = NextToken ()
	IF (token{$$KIND} != $$KIND_LITERALS) THEN GOTO eeeSyntax
	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeTypeMismatch
	IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
	IF XERROR THEN RETURN ($$T_STARTS)
	makefile$ = tab_sym$[token AND 0x0000FFFF]
	makefile$ = TRIM$(MID$(makefile$, 2, LEN(makefile$)-2))
	makefileToken = token
	RETURN ($$T_STARTS)

' *****  Errors  *****

eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)

eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	RETURN ($$T_STARTS)

eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)

eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)

eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	RETURN ($$T_STARTS)

END FUNCTION


' ##########################
' #####  CreateLabel$  #####
' ##########################

'	Creates an Unscoped reusable label

FUNCTION CreateLabel$ ()
	SHARED labelNumber

	INC labelNumber
	a$ = "A." + STRING$ (labelNumber)
	RETURN a$

END FUNCTION
'
' #####################
' #####  ShellEx  #####
' #####################
'
' PURPOSE	: ShellEx () is a replacement for the SHELL
' intrinsic function. Use only for commands
' that do not expect user input.
' Do not use to shell batch *.bat files.
' ShellEx() captures output from the shelled program.
' It also allows a working directory to be specified,
' and returns the exit code for the shelled program.
'
' IN	: command$ - 	the command to be executed, including a path if necessary,
' and any switches or parameters required by the command.
' : workDir$ -  the working directory for the command$, if any. Can be null ("").
' : outputMode - determines how output is treated. If outputMode = $$Console (-1),
' then captured output is printed on the console as it is generated,
' as well as being stored in the output$ variable.
' If outputMode = $$Default (0), output is not printed.
' Any other value is interpreted as a window handle (hWnd),
' to which the output is sent using SetWindowTextA and UpdateWindow.

' OUT	: output$  -  the captured output generated when the command is executed,
' which would normally be sent to a DOS window.
'
' ShellEx() function written by Ken Minogue - May 2002
'
FUNCTION ShellEx (command$, workDir$, output$, outputMode)

	PROCESS_INFORMATION procInfo
	STARTUPINFO startInfo
	SECURITY_ATTRIBUTES saP, saT, pa
	SHARED hStdoutRd, hStdoutWr, hChild

	output$ = ""
	IFZ command$ THEN RETURN

	' allow handles to be inherited
	saT.inherit = 1
	saP.inherit = 1
	pa.inherit = 1
	saT.length = SIZE (SECURITY_ATTRIBUTES)
	saP.length = SIZE (SECURITY_ATTRIBUTES)
	pa.length = SIZE (SECURITY_ATTRIBUTES)
	saT.securityDescriptor = NULL
	saP.securityDescriptor = NULL
	pa.securityDescriptor = NULL

	' Create a pipe that will be used for the child process's STDOUT.
	' This returns two handles:
	' hStdoutRd is a handle to the read end of the pipe
	' hStdoutWr is a handle to the write end of the pipe
	IFZ CreatePipe (&hStdoutRd, &hStdoutWr, &pa, 0) THEN
		' PRINT "Pipe creation failed"
		RETURN ($$TRUE)
	ENDIF

	' Create the child process, directing STDOUT and STDERR to the pipe's write handle
	RtlZeroMemory (&startInfo, SIZE (STARTUPINFO))
	startInfo.cb = SIZE (STARTUPINFO)
	startInfo.dwFlags = $$STARTF_USESHOWWINDOW OR $$STARTF_USESTDHANDLES
	startInfo.wShowWindow = $$SW_HIDE		' don't show the DOS console window
	startInfo.hStdInput = GetStdHandle ($$STD_INPUT_HANDLE)
	startInfo.hStdOutput = hStdoutWr
	startInfo.hStdError = hStdoutWr
	IFZ CreateProcessA (NULL, &command$, &saP, &saT, 1, 0, 0, &workDir$, &startInfo, &procInfo) THEN
		' PRINT "Create process failed"
		GOSUB CloseHandles
		RETURN ($$TRUE)
	ENDIF

	' optional - wait for process to finish
	' res = WaitForSingleObject (procInfo.hProcess, $$INFINITE)

	' handle for child process, used to get exit code.
	hChild = procInfo.hProcess

	' The parent's write handle to the pipe must be closed,
	' or ReadFile() will never return FALSE.
	IFZ CloseHandle (hStdoutWr) THEN
		' PRINT "Close handle failed"
		hStdoutWr = 0
		GOSUB CloseHandles
		RETURN ($$TRUE)
	ENDIF
	hStdoutWr = 0

	' Read output from the child process. ReadFile() returns FALSE
	' when the child process closes the write handle to the pipe, or terminates.
	DO
		chBuf$ = NULL$ ($$BUFSIZE)
		ret = ReadFile (hStdoutRd, &chBuf$, $$BUFSIZE, &bytesRead, 0)
		IF (!ret || (bytesRead == 0)) THEN EXIT DO
		buf$ = CSTRING$ (&chBuf$)
		output$ = output$ + buf$
		SELECT CASE outputMode
			CASE $$Default :
			CASE $$Console : PRINT buf$;
			CASE ELSE :
				hWnd = outputMode
				IF IsWindow (hWnd) THEN
					SendMessageA (hWnd, $$WM_SETTEXT, 0, &output$)
					UpdateWindow (hWnd)
				ENDIF
		END SELECT
	LOOP

	' child process is finished.
	GetExitCodeProcess (hChild, &exitCode)
	GOSUB CloseHandles
	RETURN (exitCode)

SUB CloseHandles
	IF hStdoutRd THEN CloseHandle (hStdoutRd)
	IF hStdoutWr THEN CloseHandle (hStdoutWr)
	IF hChild THEN CloseHandle (hChild)
	IF procInfo.hThread THEN CloseHandle (procInfo.hThread)
	hStdoutRd = 0
	hStdoutWr = 0
	hChild = 0
END SUB
END FUNCTION

' ###########################
' #####  UnComment$ ()  #####
' ###########################
'
' PURPOSE	: Remove commented part of line
' IN      : line$ - line of code to remove comment
' OUT     : comment$ - extracted comment string
'	RETURN	: Uncommented line of code
'
FUNCTION  UnComment$ (line$, @comment$)

  $STATE_DEFAULT = 0
  $STATE_COMMENT = 1
  $STATE_STRING = 2
  $STATE_CHAR = 3

  comment$ = ""

	IFZ line$ THEN
    RETURN ""
  ENDIF

  text$ = line$

  ' see if entire line is commented
  IF text${0} = ''' THEN
    comment$ = text$
    RETURN ""
  ENDIF

  chPrev = ' '
  upp = LEN(text$) - 1
  FOR i = 0 TO upp
  	statePrev = state
  	ch = text${i}
		chNext 	= ' '
		chNext2 = ' '
		chNext3 = ' '
		IF i+1 <= upp THEN chNext  = text${i+1}
		IF i+2 <= upp THEN chNext2 = text${i+2}
		IF i+3 <= upp THEN chNext3 = text${i+3}
    SELECT CASE state

    	CASE $STATE_DEFAULT
				SELECT CASE ch
					CASE '''
						IF (chNext2 = ''') || ((chNext = '\\') && (chNext3 = ''')) THEN
							state = $STATE_CHAR
						ELSE
							state = $STATE_COMMENT
							pos = i + 1
							EXIT FOR
						ENDIF
						startSeg = i
					CASE '\"'
						state = $STATE_STRING
						startSeg = i
				END SELECT

			CASE $STATE_CHAR
				IF ch = ''' THEN
					IF ((chNext = ''') && (chPrev = ''')) THEN
					ELSE
						state = $STATE_DEFAULT
						INC i
						ch = chNext
						chNext = ' '
						IF (i + 1 < upp) THEN chNext = text${i + 1}
						startSeg = i
					ENDIF
				ENDIF

			CASE $STATE_STRING
				SELECT CASE ch
					CASE '\\'
						IF (chNext = '\"') || (chNext = ''') || (chNext = '\\') THEN
							INC i
							ch = chNext
							chNext = ' '
							IF (i + 1 < upp) THEN chNext = text${i + 1}
						ENDIF
					CASE '\"'
						state = $STATE_DEFAULT
						INC i
						ch = chNext
						chNext = ' '
						IF (i + 1 < upp) THEN chNext = text${i + 1}
						startSeg = i
					END SELECT
			END SELECT

    chPrev = ch
  NEXT i

  IF pos THEN
    comment$ = MID$(text$, pos)
    RETURN (LEFT$(text$, pos-1))
  ENDIF

  ' no comment found
  RETURN (text$)

END FUNCTION
END PROGRAM
