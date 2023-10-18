'
'
' ####################  Max Reason
' #####  PROLOG  #####  copyright 1988-2000
' ####################  Linux XBasic compiler
'
' subject to GPL license - see COPYING
'
' maxreason@maxreason.com
'
' for Linux XBasic
'
'
PROGRAM	"xcol"
VERSION	"0.0211"
'
IMPORT	"xst"
IMPORT	"xgr"
IMPORT	"elf32"
IMPORT	"kernel32"
'
' #####  IMPORTANT  #####
'
' To run and debug this program in the XBasic development environment,
' you must first replace all occurences of "/xxx/" with the upper-case
' equivalent, and when you rebuild a new XBasic executable, you must
' replace all occurences of "/XXX/" with the lower-case equivalent.
' Otherwise total disaster will strike!
'
' ##########################################################
'
' OBJECT contains all information about an object except parallel arrays
' symbol$[], string$[], label$[] hold symbol, literal, and label strings.
' OBJECT is defined below, but is unimplemented in the code so far !!!
'
TYPE OBJECT
	XLONG			.id							' redundant object #
	XLONG			.alias					' id # of master copy of object (master instance of shared objects)
	XLONG			.kind						' variable, array, function, statement, operator...
	XLONG			.sharename			' ditto
	XLONG			.section				' code, data, bss...
	XLONG			.program				' program number  (0 = system/environment)
	XLONG			.function				' function number (0 = shared/external)
	XLONG			.register				' allocation register or base register
	XLONG			.address				' memory address or offset
	XLONG			.addressMode		' addressing mode
	XLONG			.type						' data type  (system defined or user defined)
	XLONG			.visibleType		' data type specified by suffix  (a%, a#, a$)
	XLONG			.scope					' scope  (AUTO, AUTOX, STATIC, SHARED, EXTERNAL)
	XLONG			.visibleScope		' scope specified by prefix... #Shared, ##External
	XLONG			.hash						'	hash value  (sum of hash[char] for all char)
	XLONG			.hashRaw				' hash value  (sum of all characters)
	XLONG			.xlongValue			' SBYTE, UBYTE, SSHORT, USHORT, SLONG, ULONG, XLONG
	GIANT			.giantValue			' GIANT
	SINGLE		.singleValue		' SINGLE
	DOUBLE		.doubleValue		' DOUBLE
	XLONG			.whomask				' system/user  (keep system objects across programs)
	XLONG			.name4					' 1st four characters in name (quick test)
	GIANT			.name8					' 1st eight characters in name (quick test)
	XLONG			.flags					' misc flags (declared, referenced, system, etc)
	XLONG			.res27
	XLONG			.res28
	XLONG			.res29
	XLONG			.res30
	XLONG			.res31
END TYPE
'
TYPE FUNCARG
	XLONG			.token
	XLONG			.varType
	XLONG			.argType
	SBYTE			.stack
	SBYTE			.byRef
	UBYTE			.kind
	UBYTE			.res
END TYPE
'
'
' OPCODE86 : 80486 opcode
'
TYPE OPCODE86
	UBYTE			.nbytes		' number of bytes in opcode
	UBYTE			.byte1		' first byte
	UBYTE			.byte2		' second byte
	UBYTE			.param		' special (usually "reg" from mod-reg-rm) for assembling
	GOADDR		.optype		' address in Code() to assemble opcode of this type
END TYPE
'
'
' ********************************
' *****  Compiler Functions  *****
' ********************************
'
DECLARE FUNCTION  Xnt ()
DECLARE FUNCTION  XxxXBasic ()
'
INTERNAL FUNCTION  AddLabel (label$, token, action)
INTERNAL FUNCTION  AddSymbol (symbol$, token, funcNumber)
INTERNAL FUNCTION  AlloToken (token)
INTERNAL FUNCTION  AssemblerSymbol (symbol$)
INTERNAL FUNCTION  AssignAddress (token)
INTERNAL FUNCTION  AssignComposite (dreg, dtype, sreg, stype)
INTERNAL FUNCTION  AtOps (xtype, opcode, mode, base, offset, sourceData)
INTERNAL FUNCTION  BinStringToAsmString$ (rawString$)
INTERNAL FUNCTION  CheckOneLine ()
INTERNAL FUNCTION  CheckState (token)
INTERNAL FUNCTION  CloneArrayXLONG (dest[], source[])
INTERNAL FUNCTION  Code (op, mode, dreg, sreg, xreg, dtype, label$, remark$)
INTERNAL FUNCTION  CodeLabelAbs (label$, offset)
INTERNAL FUNCTION  CodeLabelDisp (label$)
INTERNAL FUNCTION  Compile ()
INTERNAL FUNCTION  CompileFile (file$)
INTERNAL FUNCTION  Component (com, varToken, base, off, theType, tok, length)
INTERNAL FUNCTION  Composite (com, theType, theReg, theOffset, theLength)
INTERNAL FUNCTION  Conv (rad, toType, ras, fromType)
INTERNAL FUNCTION  Deallocate (ptr)
INTERNAL FUNCTION  EmitAsm (@line$)
INTERNAL FUNCTION  Deparse$ (prefix$)
INTERNAL FUNCTION  EmitData ()
INTERNAL FUNCTION  EmitFunctionLabel (funcName$)
INTERNAL FUNCTION  EmitLabel (labelName$)
INTERNAL FUNCTION  EmitLine (lineNum)
INTERNAL FUNCTION  EmitNull (comment$)
INTERNAL FUNCTION  EmitString (theLabel$, theString$)
INTERNAL FUNCTION  EmitText ()
INTERNAL FUNCTION  EmitUserLabel (labelToken)
INTERNAL FUNCTION  Eval (rtype)
INTERNAL FUNCTION  ExpressArray (oldOp, oldPrec, newData, newType, accArray, excess, theType, sourceReg)
INTERNAL FUNCTION  Expresso (oldTest, oldOp, oldPrec, oldData, oldType)
INTERNAL FUNCTION  FloatLoad (dreg, stoken, stype)
INTERNAL FUNCTION  FloatStore (sreg, stoken, stype)
INTERNAL FUNCTION  FunctionCallPrep ()
INTERNAL FUNCTION  FunctionCallPost ()
INTERNAL FUNCTION  GetArg (dreg, dtype, source)
INTERNAL FUNCTION  GetExternalAddresses ()
INTERNAL FUNCTION  GetFuncaddrInfo (token, eleElements, argInfo[], dataPtr)
INTERNAL FUNCTION  GetSubPath (sub$, file$, path$[])
INTERNAL FUNCTION  GetSymbol$ (info)
INTERNAL FUNCTION  GetTokenOrAddress (token, style, nextToken, dataType, nType, base, offset, length)
INTERNAL FUNCTION  GetWords (source, dtype, w3, w2, w1, w0)
INTERNAL FUNCTION  InitArrays ()
INTERNAL FUNCTION  InitComplex ()
INTERNAL FUNCTION  InitEntry ()
INTERNAL FUNCTION  InitErrors ()
INTERNAL FUNCTION  InitOptions ()
INTERNAL FUNCTION  InitProgram ()
INTERNAL FUNCTION  InitVariables ()
INTERNAL FUNCTION  InvalidExternalSymbol (symbol$)
INTERNAL FUNCTION  LastElement (token, lastPlace, excessComma)
INTERNAL FUNCTION  Literal (xx)
INTERNAL FUNCTION  LoadLitnum (dreg, dtype, source, stype)
INTERNAL FUNCTION  MakeToken (keyword$, kind, dataType)
INTERNAL FUNCTION  MinTypeFromDouble (value#)
INTERNAL FUNCTION  MinTypeFromGiant (value$$)
INTERNAL FUNCTION  Move (dest, dtype, source, stype)
INTERNAL FUNCTION  NextToken ()
INTERNAL FUNCTION  Op (rad, ras, theOp, rax, dtype, stype, otype, xtype)
INTERNAL FUNCTION  OpenAccForType (theType)
INTERNAL FUNCTION  OpenBothAccs ()
INTERNAL FUNCTION  OpenOneAcc ()
INTERNAL FUNCTION  ParseChar ()
INTERNAL FUNCTION  ParseLine (tok[])
INTERNAL FUNCTION  ParseNumber ()
INTERNAL FUNCTION  ParseOutError (token)
INTERNAL FUNCTION  ParseOutToken (token)
INTERNAL FUNCTION  ParseSymbol ()
INTERNAL FUNCTION  ParseWhite ()
INTERNAL FUNCTION  PeekToken ()
INTERNAL FUNCTION  Pop (dreg, dtype)
INTERNAL FUNCTION  PrintError (errNumber)
INTERNAL FUNCTION  PrintTokens ()
INTERNAL FUNCTION  Printoid ()
INTERNAL FUNCTION  Push (sreg, stype)
INTERNAL FUNCTION  PushFuncArg (FUNCARG arg)
INTERNAL FUNCTION  RangeCheck  (ctype, symbol$)
INTERNAL FUNCTION  Reg (token)
INTERNAL FUNCTION  RegOnly (token)
INTERNAL FUNCTION  ReturnValue (rtype)
INTERNAL FUNCTION  ScopeToken (token)
INTERNAL FUNCTION  Shuffle (oreg, areg, atype, ptype, atoken, pkind, mode, argOffset)
INTERNAL FUNCTION  StackIt (toType, theData, fromType, offset)
INTERNAL FUNCTION  StatementExport (token)
INTERNAL FUNCTION  StatementImport (token)
INTERNAL FUNCTION  StatementProgram (token)
INTERNAL FUNCTION  StatementVersion (token)
INTERNAL FUNCTION  StripExtent (filename$)
INTERNAL FUNCTION  StripNonSymbol (name$)
INTERNAL FUNCTION  StripSuffix$ (symbol$)
INTERNAL FUNCTION  TestForKeyword (symbol$)
INTERNAL FUNCTION  TheType (token)
INTERNAL FUNCTION  Tok (symbol$, token, kind, raddr, value, value$)
INTERNAL FUNCTION  TokenRestOfLine ()
INTERNAL FUNCTION  TokensDefined ()
INTERNAL FUNCTION  Top ()
INTERNAL FUNCTION  Topax1 ()
INTERNAL FUNCTION  Topax2 (topa, topb)
INTERNAL FUNCTION  Topaccs (topa, topb)
INTERNAL FUNCTION  Topx (tr, trx, nr, nrx)
INTERNAL FUNCTION  TypeToken (token)
INTERNAL FUNCTION  TypenameToken (token)
INTERNAL FUNCTION  Uop (rad, theOp, rax, dtype, otype, xtype)
INTERNAL FUNCTION  UpdateToken (token)
INTERNAL FUNCTION  Value (label$, addrmode)
INTERNAL FUNCTION  WriteDeclarationFile (string$)
INTERNAL FUNCTION  WriteDefinitionFile (string$)
'
DECLARE FUNCTION  XxxXBasicVersion$					()
DECLARE FUNCTION  XxxCheckLine							(lineNumber, tok[])
DECLARE FUNCTION  XxxCloseCompileFiles			()
DECLARE FUNCTION  XxxCompilePrep						()
DECLARE FUNCTION  XxxCreateCompileFiles			()
DECLARE FUNCTION  XxxDeleteFunction					(funcNumber)
DECLARE FUNCTION  XxxDeparseFunction				(func$, func[], lastLine, flags)
DECLARE FUNCTION  XxxDeparser								(tok[], deparsed$)
DECLARE FUNCTION  XxxEmitXProfilerCall			(funcNumber, lineNumber)
DECLARE FUNCTION  XxxErrorInfo							(xerror, rawPtr, srcPtr, srcLine$)
DECLARE FUNCTION  XxxFunctionName						(command, funcName$, funcToken)
DECLARE FUNCTION  XxxGetAddressGivenLabel		(label$)
DECLARE FUNCTION  XxxGetFunctionVariables		(funcNumber, kinds[], tok[], symbol$[], reg[], addr[])
DECLARE FUNCTION  XxxGetLabelGivenAddress 	(addr, labels$[])
DECLARE FUNCTION  XxxGetPatchErrors					(symbol$[], token[], addr[])
DECLARE FUNCTION  XxxGetProgramName					(@name$)
DECLARE FUNCTION  XxxGetSymbolInfo					(tokNumber, token, theType, symbol$, reg, addr)
DECLARE FUNCTION  XxxGetUserTypes						(varTypes$[])
DECLARE FUNCTION  XxxGetXerror$							(xerror)
DECLARE FUNCTION  XxxInitAll								()
DECLARE FUNCTION  XxxInitParse							()
DECLARE FUNCTION  XxxInitVariablesPass1			()
DECLARE FUNCTION  XxxLibraryAPI							(libname$)
DECLARE FUNCTION  XxxLoadLibrary						(token)
DECLARE FUNCTION  XxxParseSourceLine				(sourceLine$, tok[])
DECLARE FUNCTION  XxxPassFunctionArrays			(command, symbol$[], token[], scope[])
DECLARE FUNCTION  XxxParseLibrary						(token)
DECLARE FUNCTION  XxxPassTypeArrays					(command, pSize[], pSize$[], pAlias[], pAlign[], pSymbol$[], pToken[], pEleCount[], pEleSymbol$[], pEleToken[], pEleAddr[], pEleSize[], pEleType[], pEleStringSize[], pEleUBound[])
DECLARE FUNCTION  XxxSetProgramName					(name$)
DECLARE FUNCTION  XxxTheType								(token, funcNumber)
DECLARE FUNCTION  XxxUndeclaredFunction			(funcToken)
DECLARE FUNCTION  XxxXntBlowback						()
DECLARE FUNCTION  XxxXntFreeLibraries				()
'
' xdis functions
'
EXTERNAL FUNCTION  XxxDisassemble$					(addr, bytes)
'
' xst functions
'
EXTERNAL FUNCTION  XxxXstLoadLibrary				(libname$)
'
'
' ********************************
' *****  EXTERNAL VARIABLES  *****  Also referenced by "xit.x"
' ********************************
'
	EXTERNAL /xxx/	i486asm
	EXTERNAL /xxx/	i486bin
	EXTERNAL /xxx/	library
	EXTERNAL /xxx/	freezeFlag
	EXTERNAL /xxx/	bogusFunction
	EXTERNAL /xxx/	freezeFunction
	EXTERNAL /xxx/	checkattach
	EXTERNAL /xxx/	checkBounds
	EXTERNAL /xxx/	entryFunction
	EXTERNAL /xxx/	maxFuncNumber
	EXTERNAL /xxx/	xpc
	EXTERNAL /xxx/	errorCount
	EXTERNAL /xxx/	litStringAddr
'
'
' ******************************
' *****  SHARED VARIABLES  *****
' ******************************
'
	SHARED pass0source
	SHARED pass0tokens
	SHARED pass1source
	SHARED pass1tokens
	SHARED pass2errors
	SHARED XERROR
	SHARED charPtr
	SHARED rawline$
	SHARED rawLength
	SHARED tokenPtr
	SHARED xit
	SHARED hfn$
	SHARED pass
	SHARED inlevel
	SHARED section
	SHARED charV
	SHARED makevalue$
	SHARED defaultType
'
	SHARED inPrint
	SHARED markLine
	SHARED tab_sym_ptr
	SHARED utab
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
'
	SHARED decFile$[]
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
'
' *****  Common "charset" Arrays  *****
'
	SHARED assemblerBackslashAsm$[]
	SHARED UBYTE charsetSymbolFirst[]
	SHARED UBYTE charsetSymbolInner[]
	SHARED UBYTE charsetSymbolFinal[]
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
	SHARED UBYTE charsetBackslashByte[]
	SHARED UBYTE charsetBackslashChar[]
	SHARED UBYTE charsetNormalChar[]
	SHARED UBYTE charsetPrintChar[]
	SHARED UBYTE charsetSpaceTab[]
	SHARED UBYTE charsetSuffix[]
	SHARED	xerror$[]
	SHARED	uerror
'
' *****
'
	SHARED toms
	SHARED toes
	SHARED a0
	SHARED a1
	SHARED a0_type
	SHARED a1_type
	SHARED oos
	SHARED UBYTE oos[]
'
	SHARED header
	SHARED infunc
	SHARED got_declare
	SHARED got_function
	SHARED got_object_declaration
	SHARED got_executable
	SHARED got_expression
	SHARED end_program
	SHARED parse_got_function
'
	SHARED labelNumber
'
	SHARED insub
	SHARED insub$
	SHARED subCount
	SHARED nestLevel			' nestXXXX used by DO and FOR
	SHARED nestCount
	SHARED compositeArg
	SHARED crvtoken
'
	SHARED ifLine
	SHARED caseCount
	SHARED func_number
	SHARED function_line
	SHARED declareAlloTypeLine
	SHARED declareFuncaddrLine
	SHARED funcaddrFuncNumber
	SHARED dim_array
'
	SHARED nullstring$
	SHARED nullstringer
'
	SHARED lastmax
	SHARED lastlabmax
'
'
' *****  KEYWORD TOKENS  *****
'
	SHARED T_ABS
	SHARED T_ALL
	SHARED T_AND
	SHARED T_ANY
	SHARED T_ASC
	SHARED T_ATTACH
	SHARED T_AUTO
	SHARED T_AUTOX
	SHARED T_BIN_D
	SHARED T_BINB_D
	SHARED T_BITFIELD
	SHARED T_CASE
	SHARED T_CFUNCTION
	SHARED T_CHR_D
	SHARED T_CJUST_D
	SHARED T_CLOSE
	SHARED T_CLR
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
	SHARED T_LOOP
	SHARED T_LTRIM_D
	SHARED T_MAKE
	SHARED T_MAX
	SHARED T_MID_D
	SHARED T_MIN
	SHARED T_MOD
	SHARED T_NEXT
	SHARED T_NOT
	SHARED T_NULL_D
	SHARED T_OCT_D
	SHARED T_OCTO_D
	SHARED T_OPEN
	SHARED T_OR
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
'
' characters and character combos
'
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
	SHARED T_REM								'  '
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
'
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
'
' Compiler Constants
'
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
'
' r30 offsets for system variables:
'		replace with computed values as soon as available
'
	$$xerrorOffset			= 0x0180						' &($$XERROR) - r30
	$$walkbaseOffset		= 0x01B8
	$$walkoffsetOffset	= 0x01BC
	$$softBreakOffset		= 0x01C0
'
	$$BREAKPOINT   = 0x80000000		' Start token:  indicates BP at this line
	$$CURRENTEXE   = 0x40000000		'      "     :  marks current execution line
'
'
' *****  BITFIELD TOKENS  *****
'
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
'
'
' *****  PROTOTYPE TOKENS  *****
'
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
'
'
' *****  KIND TOKENS  *****
'
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
'
	$$KIND_STATEMENTS_INTRINSICS	= 0x0F		' long name duplicate
'
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
'
'
' *****  PRECEDENCE  *****
'
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
'
'
' *****  OPERATOR CONVERSION TABLE NUMBERS  *****
'
	$$COP0	= 0x00
	$$COP1	= 0x10
	$$COP2	= 0x20
	$$COP3	= 0x30
	$$COP4	= 0x40
	$$COP5	= 0x50
	$$COP6	= 0x60
	$$COP7	= 0x70
	$$COP8	= 0x80
	$$COP9	= 0x90
	$$COPA	= 0xA0
	$$COPB	= 0xB0
'
	$$R0 = 0:    $$R8  =  8:    $$R16 = 16:    $$R24 = 24
	$$R1 = 1:    $$R9  =  9:    $$R17 = 17:    $$R25 = 25
	$$R2 = 2:    $$R10 = 10:    $$R18 = 18:    $$R26 = 26
	$$R3 = 3:    $$R11 = 11:    $$R19 = 19:    $$R27 = 27
	$$R4 = 4:    $$R12 = 12:    $$R20 = 20:    $$R28 = 28
	$$R5 = 5:    $$R13 = 13:    $$R21 = 21:    $$R29 = 29
	$$R6 = 6:    $$R14 = 14:    $$R22 = 22:    $$R30 = 30
	$$R7 = 7:    $$R15 = 15:    $$R23 = 23:    $$R31 = 31
'
	$$RA0							= $$R10
	$$RA1							= $$R12
	$$IMM16						= 32
	$$NEG16						= 33
	$$LITNUM					= 34
	$$CONNUM					= 35
'
	$$TYPE_ALLO				= 0xE0	' allocation TYPE_MASK
	$$TYPE_TYPE				= 0x1F	' data type  TYPE_MASK
	$$TYPE_DECLARED		= 0x80	' for functions, go_labels, sub_labels
	$$TYPE_DEFINED		= 0x40	' for functions, go_labels, sub_labels
	$$TYPE_INPUT			= 0x11
'
	$$MASK_ALLO				= 0xE00000
	$$MASK_DECDEF			= 0xC00000		' declared | defined mask
	$$MASK_DECLARED		= 0x800000		' declared in DECLARE, EXTERNAL, INTERNAL
	$$MASK_DEFINED		= 0x400000		' defined in FUNCTION block
'
	$$XFUNC						= 0x01				' Native function (see funcKind[])
	$$SFUNC						= 0x02				' System function (see funcKind[])
	$$CFUNC						= 0x03				' C function      (see funcKind[])
'
'	DECLARE FUNCTION STYLES
'
	$$FUNC_DECLARE		= 2
	$$FUNC_INTERNAL		= 1
	$$FUNC_EXTERNAL		= 0
'
	$$ARGS0						= 0x00
	$$ARGS1						= 0x20
	$$ARGS2						= 0x40
	$$ARGS3						= 0x60
	$$ARGS4						= 0x80
'
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
	$$outdisk					= 2
	$$errors					= 3
	$$infile					= 4
	$$termfile				= 0
	$$diskfile				= 1
'
'
' i486 register equivalences
'
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
'
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
'
' 80486 machine instructions
'
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
	$$sll										= 152
	$$slr										= 153
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
'
' 80486 addressing modes
'
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
	$$regimm8								= 26		' special bogus addressing modes for
	$$absimm8								= 27		' bit-twiddling instructions in Code()
	$$r0imm8								= 28
	$$roimm8								= 29
	$$rrimm8								= 30
	$$rsimm8								= 31
'
'
' ####################
' #####  Xnt ()  #####  If running as the user program in the environment,
' ####################  the entry function should start running the program.
'
FUNCTION  Xnt ()
'
	a$ = "Max Reason"
	a$ = "copyright 1988-2000"
	a$ = "Linux XBasic compiler"
	a$ = "maxreason@maxreason.com"
	a$ = ""
'
	addr = &Xnt ()
	IF ((addr > ##UCODE) AND (addr < ##UCODEZ)) THEN XxxXBasic ()
END FUNCTION
'
'
' ##########################
' #####  XxxXBasic ()  #####
' ##########################
'
FUNCTION  XxxXBasic ()
	EXTERNAL /xxx/	maxFuncNumber,  errorCount,  library,  i486bin,  i486asm
	SHARED	tab_sym_ptr,  labelPtr
	SHARED	lastmax,  lastlabmax
	SHARED	XERROR
'
' *****  Initialize everything, then start the compiler  *****
'
	oldLibrary	= library
	library			= $$FALSE
	i486bin			= $$FALSE
	i486asm			= $$FALSE
	XxxInitAll ()
	InitOptions ()
	library			= oldLibrary
	c = Compile ()
	IFF c THEN
		IF XERROR THEN PrintError (XERROR)
		PRINT "*****  ERRORS: "; errorCount
'		PRINT "tab_sym_ptr  = "; tab_sym_ptr
'		PRINT "labelPtr     = "; labelPtr
'		PRINT "lastmax      = "; lastmax
'		PRINT "lastlabmax   = "; lastlabmax
'		PRINT "maxFuncNum   = "; maxFuncNumber
	END IF
	RETURN (errorCount)
END FUNCTION
'
'
' #########################
' #####  AddLabel ()  #####
' #########################
'
' action =	XGET (0):  Get label token if label has been defined.
'						XADD (1):  Add label token if label not defined (else error).
'						XNEW (2):  Add label token if label not defined this program.
'												(XNEW is for functions only at this time).
'
FUNCTION  AddLabel (label$, token, action)
	SHARED	tab_lab[],  tab_lab$[],  labhash[],  labaddr[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	labelPtr,  ulabel,  lastlabmax,  pastSystemLabels
	SHARED USHORT  hx[]
'
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
	END IF
'
'	there are labels with this hash in label symbol table
'
	IF last THEN
		found	= $$FALSE
		i			= last
		DO
			check  = labhash[labhash, i]
			IF (action = $$XNEW) THEN
				IF (check < pastSystemLabels) THEN EXIT DO
			END IF
			IF (labelLength = LEN (tab_lab$[check])) THEN
				IF (tab_lab$[check] = label$) THEN found = $$TRUE: EXIT DO
			END IF
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
'					PRINT "ulabel increased from"; ulabel; " to"; ulabel + ulabel + 1
					ulabel = ulabel + ulabel + 1
					REDIM labaddr[ulabel]
					REDIM tab_lab[ulabel]
					REDIM tab_lab$[ulabel]
				END IF
				tab_lab[labelPtr]		= token
				tab_lab$[labelPtr]	= label$
				INC labelPtr
				RETURN (token)
			END IF
		ELSE
			IF found THEN RETURN (check) ELSE RETURN ($$FALSE)
		END IF
	ELSE
'
' there are no labels with this hash in label symbol table
'
		IF action THEN
			labhash[labhash, 0] = 1
			labhash[labhash, 1] = labelPtr
			token = (token AND 0xFFFF0000) OR labelPtr
			IF (labelPtr >= ulabel) THEN
'				PRINT "ulabel increased from"; ulabel; " to"; ulabel + ulabel + 1
				ulabel = ulabel + ulabel
				REDIM labaddr[ulabel]
				REDIM tab_lab[ulabel]
				REDIM tab_lab$[ulabel]
			END IF
			tab_lab[labelPtr]		= token
			tab_lab$[labelPtr]	= label$
			INC labelPtr
			RETURN (token)
		END IF
	END IF
	RETURN ($$FALSE)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  AddSymbol ()  #####
' ##########################
'
FUNCTION  AddSymbol (symbol$, tokoid, f_number)
	EXTERNAL /xxx/	maxFuncNumber
	EXTERNAL /xxx/	bogusFunction,  freezeFlag,  freezeFunction
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
	SHARED	lastmax,  tokenPtr
	SHARED USHORT  hx[]
	SHARED	pass
'
'	IFZ symbol$ THEN GOTO eeeCompiler
'
	scope		= 0
	found		= 0
	token		= tokoid
	f_num		= f_number
	kind		= token{$$KIND}
	rtype		= token{$$TYPE}
	slength	= LEN (symbol$)
	spaces	= token AND 0xE0000000
	token		= token AND 0x1FFF0000
	k				= tokens[1] AND 0x1FFFFFFF
'
' see if symbol has explicit scope prefix - # or ##
' see if first token on source line is a scope keyword
' see if first token on source line is a built-in data-type
' see if first token on source line is a user-defined data-type
'
	kk = k{$$KIND}
	typetoken = TypeToken(k)
	scopetoken = ScopeToken(k)
	IF typetoken THEN intypes = $$TRUE
	IF (kk = $$KIND_TYPES) THEN intypes = $$TRUE
'
	IF symbol$ THEN
		IF (symbol${0} == '#') THEN
			IF (symbol${1} == '#') THEN scope = $$EXTERNAL ELSE scope = $$SHARED
		END IF
	END IF
'
' catch scope mismatches during compilation
'
'	IF scope THEN
'		IF scopetoken THEN
'			IF (scope != scopetoken) THEN PRINT "scope mismatch"
'		END IF
'	END IF
'
'
	IF (k = T_SHARED) THEN inshared = $$TRUE
'
	IF (k = T_EXTERNAL) THEN
		kk			= tokens[2] AND 0x1FFFFFFF
		kkk			= kk{$$KIND}
		IF (kkk = $$KIND_WHITES) THEN kk = tokens[3] AND 0x1FFFFFFF
		IF (kk != T_FUNCTION) THEN
			IF (kk != T_SFUNCTION) THEN
				IF (kk != T_CFUNCTION) THEN inshared = $$TRUE
			END IF
		END IF
	END IF
'
	SELECT CASE kind
		CASE $$KIND_FUNCTIONS
					GOTO add_function_symbol
		CASE $$KIND_TYPES
					GOTO add_type_symbol
		CASE $$KIND_VARIABLES
					IFZ got_function THEN
						IFZ (parse_got_function OR inshared OR intypes OR scope) THEN
							kind	= $$KIND_SYMBOLS
							token	= (token AND 0xE0FFFFFF) + $$T_SYMBOLS
						END IF
					END IF
		CASE $$KIND_ARRAYS
					IFZ got_function THEN
						IFZ (parse_got_function OR inshared OR intypes OR scope) THEN
							kind	= $$KIND_ARRAY_SYMBOLS
							token	= (token AND 0xE0FFFFFF) + $$T_ARRAY_SYMBOLS
						END IF
					END IF
	END SELECT
	GOTO add_normal_symbol
'
'
' ******************************
' *****  FUNCTION SYMBOLS  *****
' ******************************
'
add_function_symbol:
	FOR x = 0 TO maxFuncNumber
		funcLength = LEN (funcSymbol$[x])
		IF (slength = funcLength) THEN
			IF (symbol$ = funcSymbol$[x]) THEN found = $$TRUE: EXIT FOR
		END IF
	NEXT x
'
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
		END IF
		DIM temp%[255, ]
		ATTACH temp%[] TO hash%[maxFuncNumber, ]		' hash array for new function
		token												= token OR maxFuncNumber
		funcSymbol$[maxFuncNumber]	= symbol$
		funcToken[maxFuncNumber]		= token
		token = spaces OR token
	END IF
'
	IF function_line THEN
		parse_got_function = $$TRUE
		checkNumber = token{$$NUMBER}
		IF freezeFlag AND (checkNumber != freezeFunction) THEN
			bogusFunction = $$TRUE
			token = funcToken[freezeFunction]
		ELSE
			func_number = checkNumber
			hfn$ = HEX$(func_number)
		END IF
	END IF
	RETURN (token)
'
'
' **************************
' *****  TYPE SYMBOLS  *****
' **************************
'
add_type_symbol:
'	usymbol$ = UCASE$ (symbol$)
' FOR i = 1 TO typePtr
'		IF (usymbol$ = typeSymbol$[i]) THEN GOTO eeeDupType
'	NEXT i
'
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
	END IF
	typeToken = $$T_TYPES + typePtr
	typeSymbol$[typePtr]	= symbol$
	typeToken[typePtr]		= typeToken
	INC typePtr
	RETURN (spaces + typeToken)
'
'
' ****************************
' *****  NORMAL SYMBOLS  *****
' ****************************
'
add_normal_symbol:
	SELECT CASE kind
		CASE $$KIND_SYMBOLS, $$KIND_ARRAY_SYMBOLS:							f_num = 0
		CASE $$KIND_LITERALS, $$KIND_SYSCONS, $$KIND_CHARCONS:	f_num = 0
	END SELECT
'
' 2000/12/30 - ??? maybe not necessary ???
'
	IF scope THEN
		token = token AND 0xFF1FFFFF
		token = token OR (scope << 21)
	END IF
'
	hash = 0
	FOR x = 0 TO slength - 1
		hash = hash + hx[symbol${x}]
	NEXT x
	hash = hash AND 0x00FF
'
' no symbol with this hash yet ???
'
	IFZ hash%[f_num, hash, ] THEN
		DIM temp%[7]
		temp%[0]							= 1
		temp%[1]							= tab_sym_ptr
		token									= token OR tab_sym_ptr
		tab_sym[tab_sym_ptr]	= token
		tabType[tab_sym_ptr]	= rtype
		tab_sym$[tab_sym_ptr]	= symbol$
		ATTACH temp%[] TO hash%[f_num, hash, ]
		INC tab_sym_ptr
		IF (tab_sym_ptr > UBOUND(tab_sym[])) THEN
			uTab = tab_sym_ptr + (tab_sym_ptr >> 2) OR 7
'			PRINT "uTab0: "; UBOUND(tab_sym[]); " -> "; uTab
			REDIM r_addr[uTab]
			REDIM r_addr$[uTab]
			REDIM m_reg[uTab]
			REDIM m_addr[uTab]
			REDIM m_addr$[uTab]
			REDIM tab_sym$[uTab]
			REDIM tabType[uTab]
			REDIM tab_sym[uTab]
			REDIM tabArg[uTab, ]
		END IF
		RETURN (spaces OR token)
	END IF
'
' already a symbol with this hash
'
	ATTACH hash%[f_num, hash, ] TO temp%[]
	uhash		= UBOUND(temp%[])
	last		= temp%[0]
	IF (last = uhash) THEN
		uhash	= uhash + 8
		REDIM temp%[uhash]
	END IF
'
' Look for object in symbol table
'
	found				= $$FALSE
	FOR hash_ptr = 1 TO last
		entry			= temp%[hash_ptr]
		checks		= tab_sym[entry]
		IF (kind != checks{$$KIND}) THEN DO NEXT
		IF (slength = LEN(tab_sym$[entry])) THEN
			IF (symbol$ = tab_sym$[entry]) THEN found = $$TRUE: EXIT FOR
		END IF
	NEXT hash_ptr
'
' if symbol was found, return its token, otherwise make a symbol table entry
'
	IF found THEN
		ATTACH temp%[] TO hash%[f_num, hash, ]
		token = tab_sym[entry]
	ELSE
		temp%[0]							= last + 1
		temp%[hash_ptr]				= tab_sym_ptr
		ATTACH temp%[] TO hash%[f_num, hash, ]
		token									= token OR tab_sym_ptr
		tabType[tab_sym_ptr]	= rtype
		tab_sym[tab_sym_ptr]	= token
		tab_sym$[tab_sym_ptr]	= symbol$
		INC tab_sym_ptr
		IF (tab_sym_ptr > UBOUND(tab_sym[])) THEN
			uTab = tab_sym_ptr + (tab_sym_ptr >> 2) OR 7
'			PRINT "uTab1: "; UBOUND(tab_sym[]); " -> "; uTab
			REDIM r_addr[uTab]
			REDIM r_addr$[uTab]
			REDIM m_reg[uTab]
			REDIM m_addr[uTab]
			REDIM m_addr$[uTab]
			REDIM tab_sym$[uTab]
			REDIM tabType[uTab]
			REDIM tab_sym[uTab]
			REDIM tabArg[uTab, ]
		END IF
	END IF
	RETURN (spaces OR token)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  AlloToken ()  #####
' ##########################
'
FUNCTION  AlloToken (token)
	SHARED	T_AUTO,  T_AUTOX,  T_STATIC,  T_SHARED,  T_EXTERNAL
'
	SELECT CASE token
		CASE	T_AUTO, T_AUTOX, T_STATIC, T_SHARED, T_EXTERNAL:  RETURN (token)
	END SELECT
	RETURN (0)
END FUNCTION
'
'
' ################################
' #####  AssemblerSymbol ()  #####
' ################################
'
FUNCTION  AssemblerSymbol (symbol$)
	SHARED UBYTE	charsetSymbolInner[]
'
	IFZ symbol$ THEN GOTO eeeCompiler
	offset = LEN(symbol$) - 1
	charz = symbol${offset}
	IF charsetSymbolInner[charz] THEN RETURN
	IF (offset <= 0) THEN RETURN
	DEC offset
	chary = symbol${offset}
	IF charsetSymbolInner[chary] THEN
		SELECT CASE charz
			CASE '@':		symbol$ = RCLIP$(symbol$, 1) + "_SBYTE"
			CASE '%':		symbol$ = RCLIP$(symbol$, 1) + "_SSHORT"
			CASE '&':		symbol$ = RCLIP$(symbol$, 1) + "_SLONG"
			CASE '~':		symbol$ = RCLIP$(symbol$, 1) + "_XLONG"
			CASE '!':		symbol$ = RCLIP$(symbol$, 1) + "_SINGLE"
			CASE '#':		symbol$ = RCLIP$(symbol$, 1) + "_DOUBLE"
			CASE ELSE:	GOTO eeeCompiler
		END SELECT
	ELSE
		SELECT CASE chary
			CASE '@':		symbol$ = RCLIP$(symbol$, 2) + "_UBYTE"
			CASE '%':		symbol$ = RCLIP$(symbol$, 2) + "_USHORT"
			CASE '&':		symbol$ = RCLIP$(symbol$, 2) + "_ULONG"
			CASE '$':		symbol$ = RCLIP$(symbol$, 2) + "_GIANT"
			CASE ELSE:	GOTO eeeCompiler
		END SELECT
	END IF
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #############################
' #####  AssignAddress () #####
' #############################
'
FUNCTION  AssignAddress (token)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc,  library
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
	SHARED	section,  externalAddr
	SHARED	programTypeChunk,  functionTypeChunk
	SHARED	compositeNumber[],  compositeToken[]
	SHARED	compositeStart[],  compositeNext[]
	SHARED UBYTE	charsetSymbolInner[]
	SHARED UBYTE	charsetBackslash[]
	STATIC GOADDR makeAddrKind[]
	STATIC GOADDR makeAddrAllo[]
'
	IFZ makeAddrKind[] THEN GOSUB InitArrays
	d_allo = token{$$ALLO}
	kind = token{$$KIND}
	e = token{$$NUMBER}
	d_type = tabType[e]
	IFZ d_type THEN d_type = TheType (token)
'
' handle explicit #Shared and ##External scope
'
	a = d_allo																				' scope
	stealtype = 0																			' # : ##
	IF tab_sym$[e] THEN																' symbol$
		IF (tab_sym$[e]{0} = '#') THEN									' # 1st byte
			a = $$SHARED																	' #SharedVariable
			stealtype = $$TRUE														'
			IF (tab_sym$[e]{1} = '#') THEN a = $$EXTERNAL	' ##ExternalVariable
			IF d_allo THEN																' explicit scope in token
				IF (a != d_allo) THEN GOTO eeeScopeMismatch	' AUTOX #Shared, ##External
			END IF
		END IF
	END IF
	d_allo = a
	tk = tab_sym[e]									' token
	tk = tk AND NOT $$MASK_ALLO			' clear scope field
	tk = tk OR (a << 21)						' imbed scope in token
	tab_sym[e] = tk									' update token
'
	o_type = d_type
	alloType = d_type
'
	SELECT CASE d_allo
		CASE $$AUTO, $$AUTOX	: f_num = func_number
		CASE $$ARGUMENT				: f_num = func_number
														IF (d_type >= $$SCOMPLEX) THEN
															alloType = $$XLONG
															d_type = $$XLONG
														END IF
		CASE ELSE							: f_num = 0
	END SELECT
'
	IF m_addr$[e] THEN
		IF (d_allo = $$ARGUMENT) THEN GOTO eeeDupDefinition		' same argument twice
		RETURN
	END IF
'
' special allocation size cases
'
	SELECT CASE kind
		CASE $$KIND_VARIABLES	: IF (d_type < $$SLONG) THEN d_type = $$SLONG : alloType = $$SLONG
		CASE $$KIND_ARRAYS		: alloType = $$XLONG
	END SELECT
'
' get allocation size and alignment values
'
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
		END IF
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
		END IF
		newStart	= compositeNext[f_num, onum]
		newStart	= (newStart + calign) AND cmask
		newNext		= newStart + ccsize
		compositeToken[f_num, nnum] = token
		compositeStart[f_num, nnum] = newStart
		compositeNext[f_num, nnum] = newNext
	END IF
'
' Dispatch on basis of kind to routine to assign address
'
	GOTO @makeAddrKind[kind]
	PRINT "token   = "; HEXX$(token, 8)
	PRINT "ass1"
	GOTO eeeCompiler
'
'
' *********************************************************************
' *****  Routines to assign addresses to different kinds of data  *****
' *********************************************************************
'
' *****************************
' *****  $$KIND_CHARCONS  *****
' *****************************
'
make_addr_charcon:
	charcon$		= tab_sym$[e]
	chartest		= charcon${1}
	IF (chartest = '\\') THEN
		chartest	= charcon${2}
		chartest	= charsetBackslash[chartest]
	END IF
	r_addr$			= HEXX$ (chartest, 4)
	r_addr[e]		= $$IMM16
	r_addr$[e]	= r_addr$
	m_addr$[e]	= r_addr$
	RETURN
'
' ******************************
' *****  $$KIND_CONSTANTS  *****
' ******************************
'
make_addr_constant:
	IF (d_type = $$STRING) THEN
		IF m_addr$[e] THEN PRINT "dupdec0": GOTO eeeDupDeclaration
		m_addr$[e] = "declared"
		RETURN
	END IF
	IF (d_allo != $$SHARED) THEN m_addr$[e] = "local": RETURN
	m_addr$[e]	= "shared.local"
	symbol$			= tab_sym$[e]
	ts = AddSymbol (@symbol$, token, 0)
	IF XERROR THEN RETURN
	tse			= ts{$$NUMBER}
	r_addr	= r_addr[tse]
	IF r_addr THEN r_addr[e] = r_addr ELSE GOTO eeeUndefined
	token = token AND 0xFFFF0000
	token = token OR tse
	tab_sym[e] = token									' point local entry at shared entry
	RETURN
'
' *****************************
' *****  $$KIND_LITERALS  *****
' *****************************
'
make_addr_literal:
	IF (d_type = $$STRING) THEN
		m_addr$				= "__string." + HEX$(e, 4)
		m_addr$[e]		= m_addr$
		RETURN
	END IF
'
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
			END IF
		END IF
	END IF
'
	SELECT CASE token{$$TYPE}
		CASE $$DOUBLE:	GOTO literalFLOAT
		CASE $$SINGLE:	GOTO literalFLOAT
		CASE $$GIANT:		GOTO literalGIANT
		CASE $$USHORT:	GOTO literalUSHORT
		CASE $$ULONG:		GOTO literalULONG
		CASE ELSE:			GOTO literalSLONG
	END SELECT
'
literalFLOAT:
	r_addr[e]		= $$LITNUM
	IF nonAsm THEN PRINT "nonAsm": GOTO eeeCompiler
	r_addr$[e]	= lit$
	m_addr$[e]	= lit$
	RETURN
'
literalGIANT:
	r_addr[e]		= $$LITNUM
	IF nonAsm THEN lit$ = HEXX$(GIANT(lit$), 8)
	r_addr$[e]	= lit$
	m_addr$[e]	= lit$
	RETURN
'
literalSLONG:
	value				= XLONG (lit$)
	IF ((value < 0) AND (value >= -65535)) THEN
		r_addr[e]	= $$NEG16
	ELSE
		r_addr[e]	= $$LITNUM
	END IF
	IF nonAsm THEN lit$ = HEXX$(XLONG(lit$), 8)
	r_addr$[e]	= lit$
	m_addr$[e]	= lit$
	RETURN
'
literalUSHORT:
	r_addr[e]		= $$IMM16
	IF nonAsm THEN lit$ = HEXX$(XLONG(lit$), 8)
	r_addr$[e]	= lit$
	m_addr$[e]	= lit$
	RETURN
'
literalULONG:
	r_addr[e]	= $$LITNUM
	IF nonAsm THEN lit$ = HEXX$(ULONG(lit$), 8)
	r_addr$[e]	= lit$
	m_addr$[e]	= lit$
	RETURN
'
' **************************************************
' *****  $$KIND_VARIABLES  and  $$KIND_ARRAYS  *****
' **************************************************
'
make_addr_array:
make_addr_variable:
	GOTO @makeAddrAllo [d_allo]
	PRINT "ass2"
	GOTO eeeCompiler
'
'
' ************************************************************************
' *****  FOR VARIABLES AND ARRAYS  ******  (and structures someday)  *****
' ************************************************************************
' *****  Routines to assign addresses to data of various allocation  *****
' ************************************************************************
'
' **********************
' *****  ARGUMENT  *****
' **********************
'
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
'
' ****************************
' *****  AUTO and AUTOX  *****
' ****************************
'
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
'
' ********************
' *****  STATIC  *****
' ********************
'
make_addr_static:
	IF (externalAddr < ##GLOBAL0) THEN externalAddr = ##GLOBAL0
	IF (externalAddr > ##GLOBALZ) THEN externalAddr = ##GLOBAL0
	SELECT CASE kind
		CASE $$KIND_VARIABLES	:	symbol$ = "_" + HEX$(func_number) + "_" + tab_sym$[e]		' unspas way
		CASE $$KIND_ARRAYS		:	symbol$ = "__" + HEX$(func_number) + "__" + tab_sym$[e]	' unspas way
'		CASE $$KIND_VARIABLES	:	symbol$ = "." + HEX$(func_number) + "." + tab_sym$[e]		' post unspas
'		CASE $$KIND_ARRAYS		:	symbol$ = "." + HEX$(func_number) + ".." + tab_sym$[e]	' post unspas
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
	SELECT CASE TRUE
		CASE i486bin
		CASE i486asm:	EmitData ()
									EmitNull (".align	" + osize$)
									EmitNull (symbol$ + ":	.zero  " + osize$)
									EmitText ()
	END SELECT
	RETURN
'
' ********************
' *****  SHARED	 *****
' ********************
'
make_addr_shared:
	IF (externalAddr < ##GLOBAL0) THEN externalAddr = ##GLOBAL0
	IF (externalAddr >= ##GLOBALZ) THEN externalAddr = ##GLOBAL0
'
	asymbol$ = tab_sym$[e]
	symbol$ = tab_sym$[e]
'
	IFZ symbol$ THEN PRINT "empty symbol a" : GOTO eeeCompiler
	IF (symbol${0} = '#') THEN symbol${0} = '_'														' unspas compatible
'
	SELECT CASE kind
		CASE $$KIND_VARIABLES	: symbol$ = sharename$ + symbol$
		CASE $$KIND_ARRAYS		: symbol$ = sharename$ + "__" + symbol$				' unspas compatible
'		CASE $$KIND_ARRAYS		: symbol$ = sharename$ + "." + symbol$				' post unspas method
	END SELECT
'
	symLen				= LEN (symbol$)
	last					= symbol${symLen-1}
	IFZ charsetSymbolInner[last] THEN AssemblerSymbol (@symbol$)
'
	IF m_addr[e] THEN GOTO eeeCompiler
'
	ta = AddSymbol (@asymbol$, token, 0)
	ts = AddSymbol (@symbol$, token, 0)
	s = ts{$$NUMBER}
	a = ta{$$NUMBER}
	aaa = tabType[a]
	aas = tabType[s]
	aao = o_type
	aad = d_type
	IF aaa THEN o_type = aaa
'
	tabType[e] = o_type
	symbol$ = "_" + symbol$
'
	IF m_addr[s] THEN
		m_addr$[e]	= symbol$
		m_addr[e]		= m_addr[s]
		IF (tabType[s] != o_type) THEN GOTO eeeTypeMismatch
	ELSE
		x_addr	= (externalAddr + usize) AND amask
		m_addr$[e]		= symbol$
		m_addr$[s]		= symbol$
		m_addr[e]			= x_addr
		m_addr[s]			= x_addr
		tabType[s]		= o_type
		tabType[e]		= o_type
		externalAddr	= x_addr + osize
		IF utype THEN GOSUB AddToProgramTypeChunk
		SELECT CASE TRUE
			CASE i486bin
			CASE i486asm:	EmitData ()
										EmitNull (".align	" + osize$)
										EmitNull (symbol$ + ":	.zero  " + osize$)
										EmitText ()
		END SELECT
	END IF
	RETURN
'
'
' **********************
' *****  EXTERNAL  *****
' **********************
'
make_addr_external:
	IF (externalAddr < ##GLOBAL0) THEN externalAddr = ##GLOBAL0
	IF (externalAddr >= ##GLOBALZ) THEN externalAddr = ##GLOBAL0
	IF (kind = $$KIND_ARRAYS) THEN array$ = "_"
'
	asymbol$ = sharename$ + tab_sym$[e]
	symbol$ = tab_sym$[e]
'
	IFZ symbol$ THEN PRINT "empty symbol b" : GOTO eeeCompiler
	IF (symbol${0} = '#') THEN symbol${0} = '_'														' unspas compatible
	IF (symbol${1} = '#') THEN symbol${1} = '_'														' unspas compatible
'
	IFZ sharename$ THEN
		symbol$ = array$ + symbol$
	ELSE
		symbol$ = sharename$ + array$ + symbol$
	END IF
'
	symLen = LEN (symbol$)
	last = symbol${symLen-1}
	IFZ charsetSymbolInner[last] THEN AssemblerSymbol (@symbol$)
	ta = AddSymbol (@asymbol$, token, 0)
	ts = AddSymbol (@symbol$, token, 0)
	s = ts{$$NUMBER}
	a = ta{$$NUMBER}
	aaa = tabType[a]
	aas = tabType[s]
	aao = o_type
	aad = d_type
	o_type = aaa
'
	IF tabType[s] THEN
		IF (tabType[s] != o_type) THEN GOTO eeeTypeMismatch
	ELSE
		tabType[s]			= o_type
	END IF
'
	tabType[e]				= o_type
'
	IF i486bin THEN
		exaddr					= XxxGetAddressGivenLabel (symbol$)
		IF exaddr THEN
			m_addr$[s]		= symbol$
			m_addr$[e]		= symbol$
			m_addr[s]			= exaddr
			m_addr[e]			= exaddr
			RETURN
		END IF
	END IF
'
	IF m_addr$[s] THEN
		m_addr$[e]		= m_addr$[s]
		m_addr[e]			= m_addr[s]
		m_reg[e]			= m_reg[s]
	ELSE
		labelToken		= AddLabel (@symbol$, $$T_LABELS, $$XADD)
		ln						= labelToken{$$NUMBER}
		labaddr				= labaddr[ln]
		IF labaddr THEN
			x_addr = labaddr
		ELSE
			x_addr			= (externalAddr + usize) AND amask
'			labaddr[ln]	= x_addr
		END IF
		m_reg[s]			= 0
		m_reg[e]			= 0
		m_addr[s]			= x_addr
		m_addr[e]			= x_addr
		m_addr$				= symbol$
		m_addr$[e]		= m_addr$
		m_addr$[s]		= m_addr$
		externalAddr	= x_addr + osize
		tabType[s]		= tabType[e]
		IF utype THEN GOSUB AddToProgramTypeChunk
		SELECT CASE TRUE
			CASE i486bin: IF (##GLOBAL >= ##GLOBALZ) THEN GOTO eeeCompiler
										IFZ labaddr THEN
											##GLOBAL		= x_addr
											##GLOBALX		= x_addr
										END IF
			CASE i486asm:	EmitData ()
										EmitNull (".comm	" + symbol$ + ",  " + osize$ + "")
										EmitText ()
		END SELECT
	END IF
	RETURN
'
'
' *****  Add size of this user-type to accumulating chunk size needed
'
SUB AddToFunctionTypeChunk
	functionTypeChunk = functionTypeChunk + calign AND cmask
	functionTypeChunk = functionTypeChunk + ccsize
END SUB
'
SUB AddToProgramTypeChunk
	programTypeChunk = programTypeChunk + calign AND cmask
	programTypeChunk = programTypeChunk + ccsize
END SUB
'
'
' *****************************
' *****  SUB  InitArrays  *****
' *****************************
'
SUB InitArrays
	DIM makeAddrKind[31]
	makeAddrKind [ $$KIND_VARIABLES		] = GOADDRESS (make_addr_variable)
	makeAddrKind [ $$KIND_CONSTANTS		] = GOADDRESS (make_addr_constant)
	makeAddrKind [ $$KIND_SYSCONS			] = GOADDRESS (make_addr_constant)
	makeAddrKind [ $$KIND_LITERALS		] = GOADDRESS (make_addr_literal)
	makeAddrKind [ $$KIND_CHARCONS		] = GOADDRESS (make_addr_charcon)
	makeAddrKind [ $$KIND_ARRAYS			] = GOADDRESS (make_addr_array)
	makeAddrKind [ $$KIND_FUNCTIONS		] = GOADDRESS (make_addr_function)
'
	DIM makeAddrAllo[31]
	makeAddrAllo[ $$AUTO			] = GOADDRESS (make_addr_auto)
	makeAddrAllo[ $$AUTOX			] = GOADDRESS (make_addr_autox)
	makeAddrAllo[ $$STATIC		] = GOADDRESS (make_addr_static)
	makeAddrAllo[ $$SHARED		] = GOADDRESS (make_addr_shared)
	makeAddrAllo[ $$EXTERNAL	] = GOADDRESS (make_addr_external)
	makeAddrAllo[ $$ARGUMENT	] = GOADDRESS (make_addr_argument)
END SUB
'
make_addr_function:
	PRINT "ass4"
	GOTO eeeCompiler
	EXIT FUNCTION
'
'
' ********************
' *****  ERRORS  *****
' ********************
'
eeeBadCharcon:
	XERROR = ERROR_BAD_CHARCON
	EXIT FUNCTION
'
eeeBadSymbol:
	XERROR = ERROR_BAD_SYMBOL
	EXIT FUNCTION
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeDupDeclaration:
	XERROR = ERROR_DUP_DECLARATION
	EXIT FUNCTION
'
eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	EXIT FUNCTION
'
eeeScopeMismatch:
	XERROR = ERROR_SCOPE_MISMATCH
'
eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
'
eeeUndefined:
	XERROR = ERROR_UNDEFINED
	EXIT FUNCTION
END FUNCTION
'
'
' ################################
' #####  AssignComposite ()  #####
' ################################
'
FUNCTION  AssignComposite (d_reg, d_type, s_reg, s_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	reg86$[],  reg86c$[]
	SHARED	typeSize[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH
'
	IF (d_type != s_type) THEN GOTO eeeTypeMismatch
	IFZ d_reg THEN PRINT "AssignComposite.0": GOTO eeeCompiler
	IFZ s_reg THEN PRINT "AssignComposite.1": GOTO eeeCompiler
'
	IF (d_reg != $$edi) THEN Move ($$edi, $$XLONG, d_reg, $$XLONG)
	IF (s_reg != $$esi) THEN Move ($$esi, $$XLONG, s_reg, $$XLONG)
'
	Code ($$mov, $$regimm, $$ecx, typeSize[d_type], 0, $$XLONG, "", @"### 0")
	Code ($$call, $$rel, 0, 0, 0, 0, "__AssignComposite", @"### 1")
	EXIT FUNCTION
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' #####################
' #####  AtOps () #####
' #####################
'
FUNCTION  AtOps (xtype, opcode, mode, base, offset, source)
	SHARED	r_addr[],  m_addr$[],  r_addr$[],  typeSize[]
	SHARED	q_type_long[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_SYNTAX
	SHARED	ERROR_TOO_FEW_ARGS,  ERROR_TYPE_MISMATCH
	SHARED	T_COMMA,  T_LBRAK,  T_LPAREN,  T_RBRAK,  T_RPAREN
	SHARED	toes,  toms,  tokenPtr,  stackType
'
	stacked	= 0
	htoes		= toes
	float		= $$FALSE
	scale		= $$FALSE
	token		= NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	SELECT CASE xtype
		CASE $$SINGLE, $$DOUBLE
					float = $$TRUE
					SELECT CASE opcode
						CASE $$ld:	opcode	= $$fld
						CASE $$st:	opcode	= $$fstp
					END SELECT
	END SELECT
'
' Get base address
'
	new_test = 0: new_op = 0: new_prec = 0: baseToken = 0: baseType = 0
	Expresso (@new_test, @new_op, @new_prec, @baseToken, @baseType)
	IF XERROR THEN EXIT FUNCTION
	IFF q_type_long[baseType] THEN GOTO eeeTypeMismatch
	SELECT CASE new_op
		CASE T_RPAREN	: shortForm = $$TRUE:		GOTO shortForm
		CASE T_COMMA	: shortForm = $$FALSE
		CASE ELSE			: GOTO eeeSyntax
	END SELECT
'
' form with base and offset
'
	token			= PeekToken ()
	IF (token = T_LBRAK) THEN
		scale		= $$TRUE
		token		= NextToken ()
	END IF
'
	new_test = 0: new_op = 0: new_prec = 0: offsetData = 0: offsetType = 0
	Expresso (@new_test, @new_op, @new_prec, @offsetData, @offsetType)
	IF XERROR THEN EXIT FUNCTION
	IFZ offsetType THEN GOTO eeeTooFewArgs
	IF scale THEN
		IF (new_op <> T_RBRAK) THEN GOTO eeeSyntax
		new_op	= NextToken ()
	END IF
	IF (new_op != T_RPAREN) THEN GOTO eeeSyntax
	IFF q_type_long[offsetType] THEN GOTO eeeTypeMismatch
'
	IF offsetData THEN
		IF r_addr[offsetData{$$NUMBER}] THEN
			offset		= XLONG (r_addr$[offsetData{$$NUMBER}])
			IF scale THEN
				scale		= $$FALSE
				offimm	= $$TRUE
				offset	= offset * typeSize[xtype]
			ELSE
				offimm	= $$TRUE
			END IF
		ELSE
			offimm		= $$FALSE
			offset		= $$edi
			Move (offset, $$XLONG, offsetData, $$XLONG)
		END IF
	ELSE
		offimm			= $$FALSE
		stacked			= stacked + 1
	END IF
'
shortForm:
	IF baseToken THEN
		base			= $$esi
		Move (base, $$XLONG, baseToken, $$XLONG)
	ELSE
		stacked		= stacked + 2
	END IF
'
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
	END IF
'
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
			END IF
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
			END IF
		END IF
	END IF
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
'
eeeTooFewArgs:
	XERROR = ERROR_TOO_FEW_ARGS
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ######################################
' #####  BinStringToAsmString$ ()  #####
' ######################################
'
' Convert string with unprintable bytes (0x00 - 0x1F and 0x80 - 0xFF) into
' a string with all unprintable bytes converted into assembler compatible
' backslash sequences.
'
' NOTE:  0x22 converted to \"
' NOTE:  0x5C converted to \\
' NOTE:  0x00 - 0x06 converted to \OOO form
' NOTE:  0x07 - 0x0D converted to \a  \b  \t  \n  \v  \f  \r
' NOTE:  0x0E - 0x1F converted to \OOO form
' NOTE:  0x7F - 0xFF converted to \OOO form
'
FUNCTION  BinStringToAsmString$ (rawString$)
	SHARED UBYTE  charsetNormalChar[]
	SHARED UBYTE  charsetBackslashChar[]
	SHARED assemblerBackslashAsm$[]
'
	FOR i = 1 TO LEN (rawString$)
		rawChar = ASC (rawString$, i)
		rawByte = charsetNormalChar[rawChar]
		IF rawByte THEN
			newString$ = newString$ + CHR$ (rawByte)
		ELSE
			rawByte = charsetBackslashChar[rawChar]
			IF rawByte THEN
				newString$ = newString$ + "\\" + CHR$ (rawByte)							' \.
			ELSE
				newString$ = newString$ + assemblerBackslashAsm$[rawChar]		'\ooo
			END IF
		END IF
	NEXT i
	RETURN (newString$)
END FUNCTION
'
'
' #############################
' #####  CheckOneLine ()  #####
' #############################
'
FUNCTION  CheckOneLine ()
	EXTERNAL /xxx/	i486asm,  i486bin,  library
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_DECLARE,  T_END,  T_EXPORT,  T_EXTERNAL,  T_INTERNAL
	SHARED	T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED	tokens[],  charpos[]
	SHARED	ifLine,  lineNumber,  tokenPtr
	SHARED	export
	SHARED	got_function,  stopComment
	STATIC	testNumber
'
	ifLine			= 0
	tokenPtr		= 0
	token1			= NextToken ()	: tp1 = tokenPtr
	token2			= NextToken ()	: tp2 = tokenPtr
	tokenPtr		= tp1
	hold				= token1
	tokenCount	= tokens[0]{$$BYTE0}
	count				= tokenCount
'
	GOSUB CheckCompileLine
	IFZ compileLine THEN RETURN ($$T_STARTS)
	tokenCount = count
	tokenPtr = tp1
	token = hold
'
	DO
		token = CheckState (token)
		IF XERROR THEN EXIT DO
		kind = token{$$KIND}
	LOOP UNTIL ((kind = $$KIND_STARTS) OR (kind = $$KIND_COMMENTS))
	RETURN (token)
'
'
' *****  CheckCompileLine  *****
'
SUB CheckCompileLine
	compileLine = $$TRUE
	IF export THEN GOSUB Export
	IF (tokenCount < 2) THEN compileLine = $$FALSE : EXIT SUB
	IF (token1{$$KIND} = $$KIND_COMMENTS) THEN compileLine = $$FALSE : EXIT SUB
'
	IF i486asm THEN
		IFZ stopComment THEN
			deparse$ = Deparse$ ("")
			EmitNull ("#\n# " + LTRIM$(deparse$))		' emit source line as comment
		END IF
	END IF
END SUB
'
' *****  Export  *****
'
SUB Export
	SELECT CASE token1
		CASE T_END			: IF (token2 = T_EXPORT) THEN
												compileLine = $$FALSE
												export = $$FALSE
												EXIT SUB
											END IF
											deparse$ = Deparse$ ("")
											WriteDeclarationFile (@deparse$)
		CASE T_EXPORT		: compileLine = $$FALSE
											EXIT SUB
		CASE T_DECLARE	: IF ((token2 = T_FUNCTION) OR (token2 = T_SFUNCTION) OR (token2 = T_CFUNCTION)) THEN
												deparse$ = Deparse$ ("")
												d = INSTR (deparse$, "DECLARE")
												deparse$ = LEFT$ (deparse$,d-1) + "EXTERNAL" + MID$ (deparse$, d+7)
												WriteDeclarationFile (@deparse$)
											END IF
		CASE T_EXTERNAL	: deparse$ = Deparse$ ("")
											WriteDeclarationFile (@deparse$)
		CASE T_INTERNAL	:	IF ((token2 = T_FUNCTION) OR (token2 = T_SFUNCTION) OR (token2 = T_CFUNCTION)) THEN
												' do not include INTERNAL xFUNCTION lines
											END IF
		CASE ELSE				: deparse$ = Deparse$ ("")
											WriteDeclarationFile (@deparse$)
	END SELECT
END SUB
END FUNCTION
'
'
' ###########################
' #####  CheckState ()  #####
' ###########################
'
FUNCTION  CheckState (token)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc,  library
	EXTERNAL /xxx/	checkBounds,  errorCount,  entryFunction
	EXTERNAL /xxx/	litStringAddr,  maxFuncNumber
	SHARED SSHORT typeConvert[]
	SHARED UBYTE  charsetSymbolInner[]
	SHARED	libraryName$[],  libraryHandle[]
	SHARED	reg86$[],  reg86c$[],  m_reg[],  m_addr[],  m_addr$[]
	SHARED	autoAddr[],  autoxAddr[],  inargAddr[],  defaultType[]
	SHARED	patchType[],  patchAddr[],  patchDest[]
	SHARED	xargNum,  xargAddr[],  xargName$[]
	SHARED	stackType[]
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
	SHARED	ERROR_EXPECT_ASSIGNMENT,  ERROR_EXPRESSION_STACK
	SHARED	ERROR_INTERNAL_EXTERNAL
	SHARED	ERROR_KIND_MISMATCH
	SHARED	ERROR_NEED_EXCESS_COMMA,  ERROR_NEED_SUBSCRIPT
	SHARED	ERROR_NEST,  ERROR_NODE_DATA_MISMATCH
	SHARED	ERROR_OUTSIDE_FUNCTIONS,  ERROR_OVERFLOW,  ERROR_PROGRAM_NOT_NAMED
	SHARED	ERROR_SCOPE_MISMATCH,  ERROR_SHARENAME,  ERROR_SYNTAX
	SHARED	ERROR_TOO_FEW_ARGS,  ERROR_TOO_LATE,  ERROR_TOO_MANY_ARGS
	SHARED	ERROR_TYPE_MISMATCH,  ERROR_UNDECLARED,  ERROR_UNDEFINED
	SHARED	ERROR_UNIMPLEMENTED,  ERROR_VOID,  ERROR_WITHIN_FUNCTION
	SHARED	T_ADD,  T_ADDR_OP,  T_ALL,  T_ANY
	SHARED	T_ATSIGN,  T_ATTACH,  T_AUTO,  T_AUTOX,  T_BITFIELD
	SHARED	T_CASE,  T_CFUNCTION,  T_CMP,  T_CLOSE,  T_COLON,  T_COMMA
	SHARED	T_DEC,  T_DECLARE,  T_DIM,  T_DIV
	SHARED	T_DO,  T_DOUBLE,  T_DOUBLEAT
	SHARED	T_ELSE,  T_END,  T_ENDIF,  T_EQ,  T_ETC
	SHARED	T_EXIT,  T_EXPORT,  T_EXTERNAL
	SHARED	T_FALSE,  T_FOR,  T_FUNCADDR,  T_FUNCADDRAT,  T_FUNCTION
	SHARED	T_GIANT,  T_GIANTAT
	SHARED	T_GOADDR,  T_GOADDRAT,  T_GOSUB,  T_GOTO
	SHARED	T_HANDLE_OP,  T_IF,  T_IFF,  T_IFT,  T_IFZ,  T_IMPORT
	SHARED	T_INC,  T_INLINE_D,  T_INTERNAL
	SHARED	T_LBRACE,  T_LBRAK,  T_LIBRARY,  T_LOOP,  T_LPAREN,  T_MUL,  T_NEXT
	SHARED	T_POUND,  T_POWER,  T_PRINT,  T_PROGRAM,  T_QUIT
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
	SHARED	XERROR
	SHARED	a0,  a0_type,  a1,  a1_type,  caseCount
	SHARED	defaultType,  dim_array
	SHARED	elementType,  end_program
	SHARED	entryCheckBounds
	SHARED	export
	SHARED	func_number
	SHARED	got_declare,  got_executable,  got_export,  got_function
	SHARED	got_import,  got_object_declaration,  got_program,  got_type
	SHARED	hfn$,  ifLine,  insub,  insub$
	SHARED	libraryDeclaration,  libraryFunctionLabel$
	SHARED	nestCount,  nestLevel,  nestError,  nullstringer
	SHARED	ofile,  oos,  patchPtr
	SHARED	section,  sharename$,  staticAddr,  subCount,  tab_sym_ptr
	SHARED	toes,  tokenPtr,  toms,  xit,  labelNumber
	SHARED	programTypeChunk,  functionTypeChunk
	SHARED	inTYPE,  inUNION,  typePtr,  compositeArg,  crvtoken,  comStk
	SHARED	UBYTE oos[]
	SHARED	pass2errors,  prologCode,  preExports,  program$,  programName$,  programPath$
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
'
' Initialize computed GOTO arrays on 1st entry to this function
'
	IFZ kindBeforeFunc[] THEN
		GOSUB TypeBeforeFunc		' dispatch based on types before 1st FUNCTION
		GOSUB KindBeforeFunc		' dispatch based on KIND before 1st FUNCTION
		GOSUB	StateBeforeFunc		' dispatch based on TOKEN # before 1st FUNCTION
		GOSUB KindAfterFunc			' dispatch based on KIND after 1st FUNCTION
		GOSUB StateAfterFunc		' dispatch based on TOKEN # after 1st FUNCTION
	END IF
	IF XERROR THEN EXIT FUNCTION
'
	comStk = 0
	kind = token{$$KIND}
	tt = token{$$NUMBER}
'
	SELECT CASE kind
		CASE $$KIND_STARTS, $$KIND_COMMENTS:		RETURN ($$T_STARTS)
	END SELECT
'
	IF got_function THEN GOTO past_declares
	IF typeNumber THEN GOTO p_intype
'
' ****************************************************
' *****  if 1st FUNCTION is not yet encountered  *****
' *****  dispatch based on kindBeforeFunc[kind]  *****
' ****************************************************
'
	pallo = 0
	GOTO @kindBeforeFunc [kind]		' dispatch on basis of KIND of token
	GOTO eeeOutsideFunctions			' any other kind is an error before 1st func
'
' kindBeforeFunc[kind] may invoke one of the following...
'
b_types:				IF got_declare THEN GOTO p_types ELSE GOTO eeeDeclareFuncs
b_starts:				RETURN (token)
b_syscons:			GOTO assign_syscons
b_constants:		GOTO assign_constants
b_comments:			RETURN ($$T_STARTS)
b_terminators:	token = NextToken (): RETURN (token)
b_statements:		IF got_declare THEN GOTO @typeBeforeFunc[tt]	' data-type : presume SHARED scope
								GOTO @stateBeforeFunc[tt]		' statements before 1st function
								GOTO eeeOutsideFunctions		' if invalid before 1st function
'
' stateBeforeFunc[tt] may invoke one of the following...
'
b_all:					GOTO p_all
b_shared:				IF got_declare THEN GOTO p_shared ELSE GOTO eeeDeclareFuncs
b_function:			funcKind = $$XFUNC:						GOTO p_xfunction
b_sfunction:		funcKind = $$SFUNC:						GOTO p_xfunction
b_cfunction:		funcKind = $$CFUNC:						GOTO p_xfunction
b_declare:			funcScope = $$FUNC_DECLARE:		GOTO p_declare_func
b_internal:			funcScope = $$FUNC_INTERNAL:	GOTO p_internal_func
b_external:			funcScope = $$FUNC_EXTERNAL
								check = PeekToken ()
								SELECT CASE check
									CASE T_FUNCTION:			GOTO p_external_func
									CASE T_SFUNCTION:			GOTO p_external_func
									CASE T_CFUNCTION:			GOTO p_external_func
								END SELECT
								IF got_declare THEN GOTO p_external ELSE GOTO eeeDeclareFuncs
b_type:					GOTO p_type
b_union:				GOTO eeeSyntax
b_import:				token = StatementImport (token) : RETURN (token)
b_export:				token = StatementExport (token) : RETURN (token)
b_library:			token = StatementImport (token) : RETURN (token)
b_program:			token = StatementProgram (token) : RETURN (token)
b_version:			token = StatementVersion (token) : RETURN (token)
b_end:					token = NextToken ()
								IF (token != T_EXPORT) THEN GOTO eeeSyntax
								IFZ export THEN GOTO eeeNest
								export = $$FALSE
								RETURN ($$T_STARTS)
'
'
' ************************************
' If 1st FUNCTION has been encountered, dispatch based on kindAfterFunc[kind]
' ************************************
'
past_declares:
	GOTO @kindAfterFunc [kind]		' dispatch on basis of KIND of token
	GOTO eeeSyntax								' if invalid KIND when expecting statement
'
' kindAfterFunc[kind] may invoke one of the following...
'
a_variables:		GOTO assign_variables
a_arrays:				GOTO assign_array
a_constants:		GOTO assign_constants
a_functions:		GOTO p_func
a_labels:				GOTO p_label
a_starts:				RETURN (token)
a_comments:			RETURN (token)
a_whites:				token = NextToken (): RETURN (token)
a_terminators:	token = NextToken (): RETURN (token)
a_characters:		SELECT CASE token
									CASE T_ATSIGN:	GOTO p_atsign
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
'
'
' stateAfterFunc[tt] may invoke one of the following...
'
p_if:						ifc = $$FALSE:					GOTO p_ifx
p_ift:					ifc = $$FALSE:					GOTO p_ifx
p_ifz:					ifc = $$TRUE:						GOTO p_ifx
p_iff:					ifc = $$TRUE:						GOTO p_ifx
p_function:			funcKind = $$XFUNC:			GOTO p_xfunction
p_sfunction:		funcKind = $$SFUNC:			GOTO p_xfunction
p_cfunction:		funcKind = $$CFUNC:			GOTO p_xfunction
'
'
' *************************************
' *****  ASSIGNMENT TO CONSTANTS  *****
' *************************************
'
assign_syscons:
	IF got_function THEN GOTO eeeTooLate
	syscon = $$TRUE
	GOTO assign_constantx
'
assign_constants:
	IF (got_function = $$FALSE) THEN GOTO eeeOutsideFunctions
	IF got_executable THEN GOTO eeeTooLate
	syscon = $$FALSE
'
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
	END IF
	IF (ctype = $$STRING) THEN GOTO assign_to_string_constant
'
' now look at value to assign to constant
'
bitLoop:
	IF (token = T_SUBTRACT) THEN
		IF bitCheck THEN GOTO eeeSyntax
		token = NextToken ()
		nc = $$TRUE
	ELSE
		nc = $$FALSE
	END IF
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
	END IF
	IFF r_addr$[vv] THEN GOTO eeeUndefined
	IF nc THEN vs$ = "-" + r_addr$[vv] ELSE vs$ = r_addr$[vv]
	IF (vtype = $$GIANT) THEN
		vs$$	= GIANT (vs$)
		vs#		= vs$$
	ELSE
		vs#		= DOUBLE (vs$)
	END IF
	IF nc THEN GOTO acx
'
acc:
	SELECT CASE vtype
		CASE $$SBYTE, $$SSHORT
			r_addr = $$NEG16:  ctype = vtype: GOTO acf
		CASE $$UBYTE, $$USHORT
			r_addr = $$IMM16:  ctype = vtype: GOTO acf
		CASE $$GIANT, $$SINGLE, $$DOUBLE
			r_addr = $$LITNUM: ctype = vtype: GOTO acf
	END SELECT
'
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
					END IF
				ELSE
					ctype = vtype
				END IF
	END SELECT
'
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
		END IF
	END IF
	r_addr[cc]	= r_addr
	r_addr$[cc]	= vs$
	tabType[cc]	= ctype
	ctoken = (ctoken AND 0xFFE0FFFF) OR (ctype << 16)
	UpdateToken (ctoken)
	token = NextToken ()
	IF bitCheck THEN
		IF (token != T_RPAREN) THEN GOTO eeeSyntax
		token = NextToken ()
	END IF
	RETURN (token)
'
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
'
'
' ************************************
' *****  ASSIGNMENT TO VARIABLE  *****
' ************************************
'
assign_variables:
	got_executable = $$TRUE
	hold_place	= tokenPtr
	hold_token	= token
	old_data		= token
	old_type		= TheType (token)
	IF (old_type < $$SLONG) THEN old_type = $$SLONG
'
	ot = token
	oo = token{$$NUMBER}
	IFZ m_addr$[oo] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
'
	old_type = TheType (token)			' xxxxx
	old_type = tabType[oo]					' xxxxx
'
	IFZ old_type THEN old_type = TheType (token)		' xxxxx
'
	orego = r_addr[oo]
	token = NextToken ()
	IF (old_type < $$SLONG) THEN old_type = $$SLONG
	IF (old_type >= $$SCOMPLEX) THEN GOTO assign_composite
'
	SELECT CASE token
		CASE T_EQ			: ' fall through
		CASE T_LBRACE	: GOTO assignBraceString
		CASE ELSE			: GOTO eeeSyntax
	END SELECT
'
' evaluate the expression
'
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
	END IF
	IFZ nn THEN GOTO eeeTooFewArgs
'
' string assignment
'
asx:
	IF ((old_type != $$STRING) AND (new_type != $$STRING)) THEN GOTO nsa
	IF (old_type <> new_type) THEN tokenPtr = hold_place: GOTO eeeTypeMismatch
	IF (oo = nn) THEN DEC oos: GOTO zass
'
	IF (oos[oos] = 'v') THEN
		IF (nn = nullstringer) THEN
			Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 2")
		ELSE
			Move ($$RA0, old_type, nn, new_type)
			Code ($$call, $$rel, 0, 0, 0, 0, "__clone.a0", @"### 3")
		END IF
		nn			= $$RA0
		toes		= 1
		a0			= toes
		a0_type = new_type
	END IF
	oos[oos] = 's'
'
	oo$		= tab_sym$[oo]
	m$		= m_addr$[oo]
	ma		= m_addr[oo]
	mr		= m_reg[oo]
'
	SELECT CASE nn
		CASE $$RA0:	acc = $$R10:  accx = $$R12
								a0 = 0: a0_type = 0
		CASE $$RA1:	acc = $$R12:  accx = $$R10
								a1 = 0: a1_type = 0
		CASE ELSE:	PRINT "xxx1": GOTO eeeCompiler
	END SELECT
'
	IFZ mr THEN
		Code ($$mov, $$regimm, accx, ma, 0, $$XLONG, m$, @"### 4")
	ELSE
		Code ($$lea, $$regro, accx, mr, ma, $$XLONG, "", @"### 5")
	END IF
	Code ($$ld, $$regr0, $$esi, accx, 0, $$XLONG, "", @"### 6")
	Code ($$st, $$r0reg, acc, accx, 0, $$XLONG, "", @"### 7")
	Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 8")
	DEC oos
	DEC toes
	GOTO zass
'
'
' *********************************************
' *****  ASSIGN TO COMPOSITE DESTINATION  *****
' *********************************************
'
'		subComposite == a composite expression including sub-element references
'   varComposite == a composite variable/array without sub-element references
'
'		Destination:  GETADDR invalid for varComposites/subComposites
'									GETHANDLE invalid for varComposites
'									GETHANDLE valid only for pointer sub-elements to allow
'											assigning address to pointer (tested in Composite() )
'
p_addr_ops:
	got_executable = $$TRUE
'
	IF (token != T_HANDLE_OP) THEN GOTO eeeSyntax
	token = NextToken ()
	kind = token{$$KIND}
	SELECT CASE kind
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
		CASE ELSE:  GOTO eeeSyntax
	END SELECT
'
	old_type		= TheType (token)
	IF (old_type < $$SCOMPLEX) THEN GOTO eeeSyntax
'
	lastElement = LastElement (token, 0, 0)		' Handle invalid for varComposites
	IF XERROR THEN EXIT FUNCTION
	IF lastElement THEN GOTO eeeSyntax
'
	compositeHandle = $$TRUE
	hold_place	= tokenPtr
	hold_token	= token
'
	ot = token
	oo = token{$$NUMBER}
	IFZ m_addr$[oo] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
'
	old_type = TheType (token)		' xxxxx
	old_type = tabType[oo]				' xxxxx
'
	IFZ old_type THEN old_type = TheType (token)		' xxxxx
'
	orego = r_addr[oo]
	token = NextToken ()
'
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
	END IF
'
' *****  get address of destination  *****
'
	d_reg = hold_token
	term_ptr = tokenPtr
	tokenPtr = hold_place
	IF (d_reg{$$KIND} = $$KIND_ARRAYS) THEN		' a[] = ...  invalid
		check1 = NextToken ()
		check2 = NextToken ()
		tokenPtr = hold_place
		IF (check1 = T_LBRAK) THEN
			IF (check2 = T_RBRAK) THEN GOTO eeeSyntax
		END IF
	END IF
	IF compositeHandle THEN
		command	= $$GETHANDLE
	ELSE
		command	= $$GETDATAADDR
	END IF
	Composite (@command, @d_type, @d_reg, @d_offset, @d_length)
	IF XERROR THEN EXIT FUNCTION
	IF compositeHandle THEN
		d_type = $$XLONG
		compositeHandle = $$FALSE
	END IF
	token = NextToken ()
	IF (token != T_EQ) THEN GOTO eeeSyntax
'
' *******************************************
' *****  Assign composite to composite  *****
' *******************************************
'
	IF ((d_type >= $$SCOMPLEX) OR (s_type >= $$SCOMPLEX)) THEN
		IF (d_type != s_type) THEN GOTO eeeTypeMismatch
		IF s_data THEN
			Composite ($$GETDATA, @s_type, @s_data, 0, 0)
			s_data = 0
			sourceStacked = 1
			flipStack = $$TRUE
'			PRINT "assign_composite.0": GOTO eeeCompiler
		END IF
		IF command THEN												' address of dest in tos
			IF sourceStacked THEN								' address of source in tos-1
				IF flipStack THEN
					Topax2 (@sr, @dr)						' remove dest and source from stack
				ELSE
					Topax2 (@dr, @sr)						' remove dest and source from stack
				END IF
				GOSUB GetCompositeDest						' edi = address of dest
				Code ($$mov, $$regreg, $$esi, sr, 0, $$XLONG, "", @"### 9")
				sr = $$esi
			ELSE
				PRINT "assign_composite.1"
				GOTO eeeCompiler
			END IF
		ELSE
			dr		= d_reg												' register with composite address
			GOSUB GetCompositeDest							' edi = address of dest
			IF sourceStacked THEN								' address of src in tos
				sr = Topax1 ()										' remove source from stack
				Code ($$mov, $$regreg, $$esi, sr, 0, $$XLONG, "", @"### 10")
				sr		= $$esi											' ditto
			ELSE
				PRINT "assign_composite.2"
				GOTO eeeCompiler
			END IF
		END IF
		AssignComposite (dr, d_type, sr, s_type)
		tokenPtr = term_ptr
		token = s_op
		GOTO zass
	END IF
'
' *********************************************************
' *****  Assign simple type to simple type component  *****
' *********************************************************
'
	IF command THEN
		IF sourceStacked THEN
			Topax2 (@dr, @sr)
		ELSE
			sr = OpenAccForType (s_type)
			Move (sr, s_type, s_data, s_type)
			Topax2 (@sr, @dr)
		END IF
	ELSE
		dr		= d_reg
		IF sourceStacked THEN
			sr = Topax1 ()
		ELSE
			sr = OpenAccForType (s_type)
			Move (sr, s_type, s_data, s_type)
			Topax1 ()
		END IF
	END IF
	IF (d_type != s_type) THEN						' problem with s_type = GIANT ???
		SELECT CASE typeConvert[d_type, s_type] {{$$BYTE0}}
			CASE  0
			CASE -1:		GOTO eeeTypeMismatch
			CASE ELSE:	IFZ ((d_type <= $$XLONG) AND (s_type <= $$XLONG)) THEN
										Conv (sr, d_type, sr, s_type)		'  (GIANTS overwrite $$edi ???)
									END IF
		END SELECT
	END IF
	IF (d_type = $$STRING) THEN
		suf$ = "." + CHR$(oos[oos])
		DEC oos
		IFZ d_offset THEN
			IF (dr != $$edi) THEN
				Code ($$mov, $$regreg, $$edi, dr, 0, $$XLONG, "", @"### 11")
			END IF
		ELSE
			Code ($$lea, $$regro, $$edi, dr, d_offset, $$XLONG, "", @"### 12")
		END IF
		IF (sr != $$esi) THEN Code ($$mov, $$regreg, $$esi, sr, 0, $$XLONG, "", @"### 13")
		Code ($$mov, $$regimm, $$ecx, d_length, 0, $$XLONG, "", @"### 14")
'		Code ($$call, $$rel, 0, 0, 0, 0, "__assignCompositeString" + suf$, @"### 15")
		Code ($$call, $$rel, 0, 0, 0, 0, "__assignCompositeStringlet" + suf$, @"### 15")
	ELSE
		IF ((d_type = $$SINGLE) OR (d_type = $$DOUBLE)) THEN
			Code ($$fstp, $$ro, sr, dr, d_offset, d_type, "", @"### 16")
		ELSE
			Code ($$st, $$roreg, sr, dr, d_offset, d_type, "", @"### 17")
		END IF
	END IF
	tokenPtr	= term_ptr
	token			= s_op
	a0_type		= 0
	a1_type		= 0
	GOTO zass
'
SUB GetCompositeDest
	IF d_offset OR (dr != $$edi) THEN
		IFZ d_offset THEN
			Code ($$mov, $$regreg, $$edi, dr, 0, $$XLONG, "", @"### 18")
		ELSE
			Code ($$lea, $$regro, $$edi, dr, d_offset, $$XLONG, "", @"### 19")
		END IF
		dr		= $$edi
	END IF
END SUB
'
'
'
' ***********************************
' *****  NON-STRING ASSIGNMENT  *****
' ***********************************
'
nsa:
	literal			= $$FALSE
	doneAssign	= $$FALSE
	IF ((old_type >= $$SCOMPLEX) OR (new_type >= $$SCOMPLEX)) THEN
		IF (old_type != new_type) THEN GOTO eeeTypeMismatch
	END IF
	SELECT CASE old_type
		CASE $$SINGLE:	oldFlop = $$TRUE:		ttype = $$XLONG
		CASE $$DOUBLE:	oldFlop = $$TRUE: 	ttype = $$GIANT
		CASE ELSE:			oldFlop = $$FALSE:	ttype = old_type
	END SELECT
	SELECT CASE new_type
		CASE $$SINGLE:	newFlop = $$TRUE:		ftype = $$XLONG
		CASE $$DOUBLE:	newFlop = $$TRUE: 	ftype = $$GIANT
		CASE ELSE:			newFlop = $$FALSE:	ftype = new_type
	END SELECT
	kind	= new_data{$$KIND}
	SELECT CASE kind
		CASE $$KIND_LITERALS, $$KIND_CONSTANTS, $$KIND_SYSCONS
					ftype		= new_type
					literal	= $$TRUE
	END SELECT
'
	IF oldFlop THEN
		IF newFlop THEN GOTO flopflop ELSE GOTO flopint
	ELSE
		IF newFlop THEN GOTO intflop ELSE GOTO intint
	END IF
'
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
		END IF
	ELSE
		Move (old_data, old_type, $$RA0, old_type)
		DEC toes
		a0			= 0
		a0_type	= 0
	END IF
	GOTO zover
'
flopint:
	IF new_data THEN
		IF literal THEN
			Move ($$RA0, new_type, new_data, new_type)
			Code ($$st, $$roreg, $$RA0, $$ebp, -8, new_type, "", "### 20")
			Code ($$fild, $$ro, 0, $$ebp, -8, new_type, "", "### 21")
			FloatStore ($$RA0, old_data, old_type)
		ELSE
			FloatLoad ($$RA0, new_data, new_type)
			FloatStore ($$RA0, old_data, old_type)
		END IF
		a0			= 0
		a0_type	= 0
	ELSE
		Code ($$st, $$roreg, $$RA0, $$ebp, -8, new_type, "", "### 22")
		Code ($$fild, $$ro, 0, $$ebp, -8, new_type, "", "### 23")
		Move (old_data, old_type, $$RA0, old_type)
		DEC toes
		a0			= 0
		a0_type	= 0
	END IF
	GOTO zover
'
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
	END IF
	GOTO zover
'
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
		END IF
	ELSE
		IF (old_type = new_type) THEN
			Move (old_data, old_type, $$RA0, old_type)
		ELSE
			Conv ($$RA0, old_type, $$RA0, new_type)
			Move (old_data, old_type, $$RA0, old_type)
		END IF
		DEC toes
		a0			= 0
		a0_type	= 0
	END IF
	GOTO zover

zover:
	IF a0 AND (a0 = toes) THEN DEC toes: a0 = 0: a0_type = 0: GOTO zass
	IF a1 AND (a1 = toes) THEN DEC toes: a1 = 0: a1_type = 0: GOTO zass
'
zass:
	IF (toes OR toms OR a0 OR a1 OR a0_type OR a1_type) THEN
		GOTO eeeExpressionStack
	END IF
	RETURN (token)
'
'
' ****************************************
' *****  ASSIGNMENT TO BRACE STRING  *****
' ****************************************
'
assignBraceString:
	got_executable = $$TRUE
	old_type		= $$UBYTE
	hold_type		= $$UBYTE
	hold_place	= tokenPtr - 1
	reg_type		= $$XLONG
'
' skip past "=" to source expression
'
	DO
		check = NextToken ()
	LOOP UNTIL ((check = T_EQ) OR (check{$$KIND} = $$KIND_STARTS))
	IF (check <> T_EQ) THEN GOTO eeeExpectAssignment
'
' evaluate the source expression
'
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
	END IF
'
' get address of destination string element
'
	new_op = T_ADDR_OP
	tokenPtr = hold_place - 1
	new_prec = $$PREC_ADDR_OP
	new_data = 0: new_type = 0: new_test = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IF (new_type > $$XLONG) THEN GOTO eeeTypeMismatch
	IF (new_op <> T_EQ) THEN PRINT "xxx3a": GOTO eeeCompiler
	IF new_data THEN PRINT "xxx3b": GOTO eeeCompiler
	nn = Top ()
	IFZ nn THEN GOTO eeeTooFewArgs
'
	SELECT CASE nn
		CASE $$RA0
					ss = $$RA1
					IFZ a1 THEN Pop ($$RA1, @stype)
					Code ($$st, $$r0reg, $$ebx, $$eax, 0, $$UBYTE, "", @"### 24")
		CASE $$RA1
					ss = $$RA0
					IFZ a0 THEN Pop ($$RA0, @stype)
					Code ($$st, $$r0reg, $$eax, $$ebx, 0, $$UBYTE, "", @"### 25")
		CASE ELSE
					PRINT "xxx4"
					GOTO eeeCompiler
	END SELECT
'
	IF XERROR THEN
		tokenPtr = hold_place
		EXIT FUNCTION
	END IF
	toes = toes - 2
	a0 = 0: a0_type = 0
	a1 = 0: a1_type = 0
	tokenPtr = holdp
	RETURN (holdt)
'
'
'
' *********************************
' *****  ASSIGNMENT TO ARRAY  *****
' *********************************
'
assign_array:
	got_executable = $$TRUE
	hold_type  = TheType (token)
	hold_place = tokenPtr
	hold_token = token
	IF (hold_type < $$SLONG) THEN
		reg_type = $$SLONG
	ELSE
		reg_type = hold_type
	END IF
'
	oo = token{$$NUMBER}
	IFZ m_addr$[oo] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
'
	hold_type = TheType (token)			' xxxxx
	hold_type = tabType[oo]					' xxxxx
'
	IFZ hold_type THEN hold_type = TheType (token)		' xxxxx
'
	IF (hold_type >= $$SCOMPLEX) THEN GOTO assign_composite
'
	DO
		check = NextToken ()
	LOOP UNTIL ((check = T_EQ) OR (check{$$KIND} = $$KIND_STARTS))
	IF (check <> T_EQ) THEN GOTO eeeExpectAssignment
'
' evaluate the source expression
'
	new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	holdp = tokenPtr
	holdt = new_op
	token = new_op
	stype = new_type
	IF new_data THEN ss = new_data{$$NUMBER} ELSE ss = Top ()
	IFZ ss THEN GOTO eeeTooFewArgs
'
	IF (new_type = $$STRING) THEN
		Move ($$RA0, old_type, ss, new_type)
		IF (oos[oos] = 'v') THEN
			Code ($$call, $$rel, 0, 0, 0, 0, "__clone.a0", @"### 26")
			oos[oos] = 's'
		END IF
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
		END IF
	END IF
'
' get address of destination array element
'
	IF (hold_type = $$STRING) THEN
		new_op = T_HANDLE_OP
	ELSE
		new_op = T_ADDR_OP
	END IF
	tokenPtr = hold_place - 1
	new_prec = $$PREC_ADDR_OP
	new_data = 0
	new_type = 0
	new_test = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IFZ toes THEN GOTO eeeSyntax
	IF (new_op <> T_EQ) THEN PRINT "xxx3": GOTO eeeCompiler
	IF (hold_type = $$STRING) AND (hold_type <> stype) THEN
		GOTO eeeTypeMismatch
	END IF
	IF new_data THEN nn = new_data{$$NUMBER} ELSE nn = Top ()
	IFZ nn THEN GOTO eeeTooFewArgs
'
	IF (nn = $$RA0) THEN
		ss = $$RA1
		IFZ a1 THEN Pop ($$RA1, @stype)
'
' if source was a literal, a conversion may not be necessary to range check
'
		IF (hold_type <> stype) THEN
			IF ((hold_type >= $$GIANT) OR (stype >= $$GIANT)) THEN
				Conv ($$RA1, hold_type, $$RA1, stype)
			END IF
		END IF
'
		IF (hold_type = $$STRING) THEN
			Code ($$ld, $$regr0, $$esi, $$eax, 0, $$XLONG, "", @"### 27")
			Code ($$st, $$r0reg, $$ebx, $$eax, 0, $$XLONG, "", @"### 28")
			Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 29")
			DEC oos
		ELSE
			SELECT CASE hold_type
				CASE $$SINGLE, $$DOUBLE
							Code ($$fstp, $$r0, 0, $$eax, 0, hold_type, "", @"### 30")
				CASE ELSE
							Code ($$st, $$r0reg, $$ebx, $$eax, 0, hold_type, "", @"### 31")
			END SELECT
		END IF
		GOTO aaax
	END IF
'
	IF (nn = $$RA1) THEN
		ss = $$RA0
		IFZ a0 THEN Pop ($$RA0, @stype)
'
' if source was a literal, a conversion may not be necessary to range check
'
		IF (hold_type <> stype) THEN
			IF ((hold_type >= $$GIANT) OR (stype >= $$GIANT)) THEN
				Conv ($$RA0, hold_type, $$RA0, stype)
			END IF
		END IF
		IF (hold_type == $$STRING) THEN
			Code ($$ld, $$regr0, $$esi, $$ebx, 0, $$XLONG, "", @"### 32")
			Code ($$st, $$r0reg, $$eax, $$ebx, 0, $$XLONG, "", @"### 33")
			Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 34")
			DEC oos
		ELSE
			SELECT CASE hold_type
				CASE $$SINGLE, $$DOUBLE
							Code ($$fstp, $$r0, 0, $$ebx, 0, hold_type, "", @"### 35")
				CASE ELSE
							Code ($$st, $$r0reg, $$eax, $$ebx, 0, hold_type, "", @"### 36")
			END SELECT
		END IF
		GOTO aaax
	END IF
	PRINT "xxx4"
	GOTO eeeCompiler
aaax:
	IF XERROR THEN
		tokenPtr = hold_place
		EXIT FUNCTION
	END IF
	toes = toes - 2
	a0 = 0: a0_type = 0
	a1 = 0: a1_type = 0
	tokenPtr = holdp
	RETURN (holdt)
'
'
' *****************************************************
' *****  typenameAT (base, [index]) = expression  *****
' *****************************************************
'
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
	END IF
	opcode		= $$st
	tokenPtr	= hold_place
	AtOps (hold_type, @opcode, @mode, @base, @offset, @source)
	Code (opcode, mode, source, base, offset, hold_type, "", "### 37")
	tokenPtr	= holdp
	RETURN (holdt)
'
'
' *************************
' *****  GOTO LABELS  *****
' *************************
'
p_label:
	got_executable = $$TRUE
	IF (tokenPtr <> 1) THEN GOTO eeeSyntax
	IF (token{$$TYPE} <> $$GOADDR) THEN GOTO eeeTypeMismatch
	EmitUserLabel (token)
	IF XERROR THEN EXIT FUNCTION
'	IF i486bin THEN Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages$0", @"### 38")		' gas ?
	IF i486bin THEN Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages_0", @"### 38")		' unspas
	token = NextToken ()
	RETURN (token)
'
'
' ******************************
' *****  EXECUTE FUNCTION  *****
' ******************************
'
p_func:
p_atsign:
	got_executable = $$TRUE
	DEC tokenPtr
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (toes <> 1) THEN PRINT "xxx6":  GOTO eeeCompiler
	IF (result_type = $$STRING) THEN
		Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, "", @"### 39")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 40")
		DEC oos
	END IF
	toes = 0
	a0 = 0: a0_type = 0
	a1 = 0: a1_type = 0
	RETURN (token)
'
'
'
' **********************************
' **********  STATEMENTS  **********
' **********************************
'
'
' *****  AUTO, STATIC, SHARED, SHARED /sharename/, EXTERNAL, EXTERNAL /sharename/  *****
'
p_types:
	pallo = $$SHARED		' in PROLOG, SHARED allocation is assumed
'
p_auto:
p_autox:
p_static:
p_shared:
p_external:
	IF got_executable THEN GOTO eeeTooLate
	IFZ program$ THEN program$ = programName$
	IFZ got_function THEN
		IFZ got_object_declaration THEN
			IFZ prologCode THEN
				EmitText()
				SELECT CASE TRUE
					CASE library	:  Code ($$jmp, $$rel, 0, 0, 0, 0, "__StartLibrary_" + program$, "### 41")
					CASE ELSE			:  Code ($$jmp, $$rel, 0, 0, 0, 0, @"__StartApplication", "### 42")
				END SELECT
				prologCode = $$TRUE
				EmitLabel ("PrologCode")
				Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 43")
				Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, "", @"### 44")
				Code ($$sub, $$regimm, $$esp, 256, 0, $$XLONG, "", @"### 45")
				IF i486asm THEN EmitNull (@"#")
			END IF
		END IF
	END IF
'
	got_object_declaration = $$TRUE
	gotAllo = $$TRUE
	sharename$ = ""
'
	IF pallo THEN
		allo = pallo
	ELSE
		allo = token{$$ALLO}
		token = NextToken ()
	END IF
'
	IF ((allo = $$SHARED) OR (allo = $$EXTERNAL)) THEN
		IF (token = T_DIV) THEN														' SHARED /sharename/ or EXTERNAL /sharename/
			token = NextToken ()
			kind = token{$$KIND}
			SELECT CASE kind
				CASE $$KIND_SYMBOLS, $$KIND_VARIABLES
							s$		= tab_sym$[token{$$NUMBER}]
							token = NextToken ()
							IF (token <> T_DIV) THEN GOTO eeeSharename
'							sharename$ = "." + s$ + "$"											' gas ?
							sharename$ = "_" + s$ + "_"											' unspas
							token = NextToken ()
				CASE ELSE
							GOTO eeeSharename
			END SELECT
		END IF
	END IF
	dataType = TypenameToken (@token)
	GOTO p_type_data
'
'
' *****  SBYTE, UBYTE, SSHORT, USHORT, SLONG, ULONG, XLONG
' *****  GOADDR, SUBADDR, FUNCADDR, SINGLE, DOUBLE, GIANT, STRING
' *****  USER-DEFINED-TYPES
'
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
p_user_type:
	IF got_executable THEN GOTO eeeTooLate
	got_object_declaration = $$TRUE
	dataType = TypenameToken (@token)
	sharename$ = ""
'
p_type_data:
	e			= token{$$NUMBER}
	adt		= dataType
	SELECT CASE adt
		CASE $$GOADDR, $$SUBADDR
			IF (allo = $$SHARED) THEN GOTO eeeScopeMismatch
			IF (allo = $$EXTERNAL) THEN GOTO eeeScopeMismatch
		CASE $$FUNCADDR
			DIM funcaddrArg[]
			term		= GetFuncaddrInfo (@token, @eleElements, @funcaddrArg[], @dataPtr)
			kind		= token{$$KIND}
			e				= token{$$NUMBER}
			tdt			= token{$$TYPE}
			IF (tdt AND (tdt != $$FUNCADDR)) THEN GOTO eeeTypeMismatch
			ATTACH funcaddrArg[] TO tabArg[e, ]
			token = token OR (allo << 21)
			tabType[e]	= adt
			UpdateToken (token)
			AssignAddress (token)
			IF XERROR THEN EXIT FUNCTION
			array = $$FALSE
			SELECT CASE kind
				CASE $$KIND_VARIABLES
							IF eleElements THEN GOTO eeeCompiler
				CASE $$KIND_ARRAYS
							IF eleElements THEN
								IF func_number THEN GOTO eeeSyntax
								holdPtr		= tokenPtr
								tokenPtr	= dataPtr - 1
								dim_array	= $$TRUE
								token			= Eval (@result_type)
								dim_array	= $$FALSE
								IF XERROR THEN EXIT FUNCTION
								tokenPtr	= holdPtr
							END IF
			END SELECT
			RETURN (term)
	END SELECT
'
' Get scope and check for scope mismatches like:::    STATIC  #Bill, ##Fred
'
	a = allo																					' scope
	IF tab_sym$[e] THEN																' symbol$
		IF (tab_sym$[e]{0} = '#') THEN									' # 1st byte
			a = $$SHARED																	' #SharedVariable
			IF (tab_sym$[e]{1} = '#') THEN a = $$EXTERNAL	' ##ExternalVariable
			IF gotAllo THEN																' got explicit scope name
				IF (a != allo) THEN GOTO eeeScopeMismatch		' AUTOX #Shared, ##External
			END IF
		END IF
	END IF
'
	tdt		= token{$$TYPE}															' type in token$, token$$
	kind	= token{$$KIND}															' kind in token$, token$[]
	SELECT CASE kind
		CASE $$KIND_VARIABLES:	arrayKind = $$FALSE
		CASE $$KIND_ARRAYS:			arrayKind	= $$TRUE
		CASE ELSE:							GOTO eeeSyntax
	END SELECT
	IF ((adt && tdt) AND (adt != tdt)) THEN GOTO eeeTypeMismatch
	IFZ adt THEN adt = tdt
	IF m_addr$[e] THEN GOTO eeeDupDeclaration
'
	token				= token OR (a << 21)									' put scope into token
	tabType[e]	= adt
	UpdateToken (token)
	AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
'
	htp			= tokenPtr - 1
	token		= NextToken ()
'
' Dimension arrays with subscripts, skip brackets[]
'
	IF arrayKind THEN
		IF (token != T_LBRAK) THEN GOTO eeeCompiler
		token				= NextToken ()
		IF (token = T_RBRAK) THEN
			token			= NextToken ()
		ELSE
			tokenPtr	= htp
			dim_array	= $$TRUE
			token			= Eval (@result_type)
			dim_array = $$FALSE
			IF XERROR THEN EXIT FUNCTION
		END IF
	END IF
'
	IF (token = T_COMMA) THEN
		token	= NextToken ()
		kind	= token{$$KIND}
		GOTO p_type_data
	END IF
'
	token		= NextToken ()
	sharename$ = ""
	RETURN (token)
'
'
' *****  ALL  *****
'
p_all:
	got_executable = $$FALSE					' remove eventually  (debug convenience)
	check = PeekToken ()
	IF (check = T_ALL) THEN
		e = 0
		check = NextToken ()
	ELSE
		e = 36
	END IF
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
	RETURN ($$T_STARTS)
'
'
' *****  ATTACH  *****  ATTACH fromArray[*] TO toArray[*]
'
p_attach:
	attachoid		= $$TRUE
	GOTO p_swapper
'
'
' *****  CASE  *****
'
p_case:
	got_executable = $$TRUE
	nestObject	= nestVar[nestLevel]						' token for test expression
	caseItem		= 0
	caseFloat		= $$FALSE
	caseString	= $$FALSE
	nestType		= nestObject{$$TYPE}						' test expression type
	SELECT CASE nestType
		CASE $$STRING:		caseString	= $$TRUE
		CASE $$SINGLE:		caseFloat		= $$TRUE
		CASE $$DOUBLE:		caseFloat		= $$TRUE
	END SELECT
	nestToken		= nestToken[nestLevel]
	nestKinds		= nestToken{$$RAWTYPE}					' ALL, TRUE, FALSE flags
	caseCount		= nestInfo[nestLevel]
	IF (caseCount = $$TRUE) THEN GOTO eeeAfterElse
	IF (nestKinds AND 0x80) THEN caseAll = $$TRUE ELSE caseAll = $$FALSE
	IF (nestKinds AND 0x60) THEN caseTFs = $$TRUE ELSE caseTFs = $$FALSE
	IF ((nestToken AND 0x1F00FFFF) <> T_SELECT) THEN GOTO eeeSyntax
'
' end of previous CASE block unless this is the 1st case block
'
	IF caseCount THEN
		IFF caseAll THEN
			d1$ = "end.select." + HEX$(nestCount[nestLevel], 4)
			Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 46")
		END IF
		EmitLabel ("case." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount, 4))
	END IF
'
' *****  CASE ELSE
' *****  CASE ALL
'
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
'
' *****  CASE <expression>  *****
'
	DO
		GOSUB Tester
		IF caseTFs THEN nestType = new_type
		SELECT CASE (nestKinds AND 0x60)			' 00 = <exp> : 40 = TRUE : 20 = FALSE
			CASE 0x40:	ifc = $$TRUE:  GOSUB SelectCaseTrue
			CASE 0x20:	ifc = $$FALSE: GOSUB SelectCaseFalse
			CASE 0x00:	ifc = $$FALSE: GOSUB SelectCaseExpression
			CASE ELSE:	GOTO eeeSyntax
		END SELECT
		toes = 0
		INC caseItem
		a0 = 0: a0_type = 0
		a1 = 0: a1_type = 0
	LOOP WHILE (new_op = T_COMMA)
	IF (caseItem > 1) THEN
		EmitLabel ("caser." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount,4))
	END IF
	INC caseCount
	nestInfo[nestLevel] = caseCount
	RETURN (new_op)
'
'
' *****  SELECT CASE TRUE  *****
'
SUB SelectCaseTrue
	IF (new_op = T_COMMA) THEN
		where$ = "caser." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount, 4)
		GOSUB TestTrue
	ELSE
		where$ = "case." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount+1,4)
		GOSUB TestFalse
	END IF
END SUB
'
'
' *****  SELECT CASE FALSE  *****
'
SUB SelectCaseFalse
	IF (new_op = T_COMMA) THEN
		where$ = "caser." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount, 4)
		GOSUB TestFalse
	ELSE
		where$ = "case." + HEX$(nestCount[nestLevel], 4) +"."+ HEX$(caseCount+1,4)
		GOSUB TestTrue
	END IF
END SUB
'
'
' *****  SELECT CASE <expression>  *****
'
SUB SelectCaseExpression
	IF (newType >= $$SCOMPLEX) THEN GOTO eeeTypeMismatch
	IF (nestType <> new_type) THEN
		SELECT CASE typeConvert[nestType, new_type] {{$$BYTE0}}
			CASE -1:		GOTO eeeTypeMismatch
			CASE  0:		' convert not required
			CASE ELSE:	Conv ($$eax, nestType, $$eax, new_type)
		END SELECT
	END IF
	IF XERROR THEN EXIT FUNCTION
	IF caseString THEN
		ooos			= oos[oos]
		oos[oos]	= 'v'
		INC oos
		oos[oos]	= ooos
		IF (acc != $$eax) THEN
			Move ($$eax, $$XLONG, acc, $$XLONG)				' added from xx8v  05/10/92
			acc			= $$eax
		END IF
	END IF
	IF caseFloat THEN expression = $$TRUE
	IFZ caseItem THEN expression = $$TRUE
	IF expression THEN
		Move ($$ebx, nestType, nestObject, nestType)
		expression = $$FALSE
	END IF
	Op ($$eax, $$ebx, T_EQ, $$eax, $$XLONG, nestType, nestType, nestType)
	IF (new_op = T_COMMA) THEN
		d1$ = "caser." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(caseCount, 4)
		Code ($$je, $$rel, 0, 0, 0, 0, d1$, @"### 47")
	ELSE
		x1$ = "case." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(caseCount+1, 4)
		Code ($$jne, $$rel, 0, 0, 0, 0, x1$, @"### 48")
	END IF
END SUB
'
'
' ***********************
' *****  NEXT CASE  *****
' ***********************
'
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
	END IF
	checkLevel = nestLevel
	checkToken = T_SELECT
	GOSUB NestWalk
	caseCount	= nestInfo[checkLevel]
	dx$				= "case." + HEX$(nestCount[checkLevel], 4) +"."+ HEX$(caseCount, 4)
	Code ($$jmp, $$rel, 0, 0, 0, 0, dx$, @"### 49")
	IF skipLevels THEN token = NextToken ()
	expression	= $$TRUE
	RETURN (token)
'
' ********************************************
' *****  CLOSE   (fileNumber)            *****
' *****  QUIT    (status)                *****
' *****  SEEK    (fileNumber, position)  *****
' *****  SHELL   (command$)              *****
' ********************************************
'
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
'
'
' *******************************
' *****  INLINE$ (prompt$)  *****  Allows INLINE$() to begin a line
' *******************************
'
p_inline_d:
	got_executable = $$TRUE
	DEC tokenPtr
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (oos[oos] = 's') THEN
		acc	= Top ()
		Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, "", "### 50")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", "### 51")
	END IF
	DEC oos
	DEC toes
	a0			= 0
	a1			= 0
	a0_type	= 0
	a1_type	= 0
	RETURN (token)
'
'
' *****************
' *****  DEC  *****
' *****************
' *****  INC  *****
' *****************
'
p_dec:
	op86	= $$dec
	GOTO p_inc_dec
p_inc:
	op86	= $$inc
	GOTO p_inc_dec
'
p_inc_dec:
	holdPtr	= tokenPtr
	token		= NextToken ()
	tvart		= token{$$NUMBER}
	tkind		= token{$$KIND}
	SELECT CASE tkind
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
		CASE ELSE:		GOTO eeeSyntax
	END SELECT
	IFZ m_addr$[tvart] THEN AssignAddress (token)
	IF XERROR THEN EXIT FUNCTION
	ttype		= TheType (token)
	IF (ttype = $$STRING) THEN GOTO eeeTypeMismatch
	IF (ttype < $$SCOMPLEX) THEN
		IF (tkind = $$KIND_ARRAYS) THEN GOTO p_inc_dec_array
	END IF
	IF (ttype < $$SBYTE) THEN GOTO eeeCompiler
	IF (ttype < $$SLONG) THEN ttype = $$SLONG
'
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
			CASE (ttype < $$SBYTE):			GOTO eeeTypeMismatch
			CASE (ttype > $$DOUBLE):		GOTO eeeTypeMismatch
			CASE (ttype = $$GOADDR):		GOTO eeeTypeMismatch
			CASE (ttype = $$SUBADDR):		GOTO eeeTypeMismatch
			CASE (ttype = $$FUNCADDR):	GOTO eeeTypeMismatch
		END SELECT
		IFZ creg THEN
			Move ($$RA1, $$XLONG, token, $$XLONG)
			creg = $$RA1
		END IF
		IF (ttype < $$SLONG) THEN ttype = $$SLONG
		SELECT CASE ttype
			CASE $$SINGLE, $$DOUBLE
			CASE ELSE
						Code ($$ld, $$regro, $$esi, creg, offset, ttype, "", @"### 52")
		END SELECT
		treg		= $$esi
		mReg		= creg
		mAddr		= offset
	END IF
	oreg		= treg
	oregx		= oreg + 1
	GOSUB IncOrDecValue
	token			= NextToken ()
	RETURN (token)
'
' INC or DEC array element
'
p_inc_dec_array:
	token			= NextToken ()
	IF (token != T_LBRAK) THEN GOTO eeeCompiler
	token			= NextToken ()
	IF (token = T_RBRAK) THEN GOTO eeeSyntax
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
'
'
' INC or DEC value in oreg
' IF ctype THEN store result at (creg + offset)
' ELSE store back in original variable "tvart"
'
SUB IncOrDecValue
	SELECT CASE ttype
		CASE $$SBYTE, $$SSHORT, $$SLONG
					IF mReg THEN
						Code (op86, $$ro, 0, mReg, mAddr, ttype, "", @"### 53")
						Code ($$into, $$none, 0, 0, 0, 0, "", @"### 54")
					ELSE
						Code (op86, $$abs, 0, 0, mAddr, ttype, mAddr$, @"### 55")
						Code ($$into, $$none, 0, 0, 0, 0, "", @"### 56")
					END IF
					ctype	= 0
					treg	= $$TRUE
		CASE $$UBYTE, $$USHORT, $$ULONG
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					IF mReg THEN
						Code (op86, $$ro, 0, mReg, mAddr, ttype, "", @"### 57")
						Code ($$jnc, $$rel, 0, 0, 0, 0, d1$, @"### 58")
						Code ($$int, $$imm, 3, 0, 0, 0, "", @"### 59")
					ELSE
						Code (op86, $$abs, 0, 0, mAddr, ttype, mAddr$, @"### 60")
						Code ($$jnc, $$rel, 0, 0, 0, 0, d1$, @"### 61")
						Code ($$int, $$imm, 3, 0, 0, 0, "", @"### 62")
					END IF
					EmitLabel (@d1$)
					ctype	= 0
					treg	= $$TRUE
		CASE $$XLONG
					IF mReg THEN
						Code (op86, $$ro, 0, mReg, mAddr, $$XLONG, "", @"### 63")
					ELSE
						Code (op86, $$abs, 0, 0, mAddr, $$XLONG, mAddr$, @"### 64")
					END IF
					ctype	= 0
					treg	= $$TRUE
		CASE $$GIANT
					oreg = $$eax
					oregx = oreg + 1
					Move ($$eax, ttype, token, ttype)
					SELECT CASE op86
						CASE $$inc:	Code ($$add, $$regimm, oreg, 1, 0, $$XLONG, "", @"### 65")
												Code ($$adc, $$regimm, oregx, 0, 0, $$XLONG, "", @"### 66")
												Code ($$into, $$none, 0, 0, 0, 0, "", @"### 67")
						CASE $$dec:	Code ($$sub, $$regimm, oreg, 1, 0, $$XLONG, "", @"### 68")
												Code ($$sbb, $$regimm, oregx, 0, 0, $$XLONG, "", @"### 69")
												Code ($$into, $$none, 0, 0, 0, 0, "", @"### 70")
					END SELECT
					Move (token, ttype, $$eax, ttype)
					treg = $$TRUE
					a0_type = 0
					a0 = 0
		CASE $$SINGLE
					IF mReg THEN
						Code ($$fld, $$ro, 0, mReg, mAddr, $$SINGLE, "", @"### 71")
					ELSE
						Code ($$fld, $$abs, 0, 0, mAddr, $$SINGLE, "", @"### 72")
					END IF
					Code ($$fld1, $$none, 0, 0, 0, 0, "", @"### 73")
					SELECT CASE op86
						CASE $$inc:	Code ($$fadd, $$none, 0, 0, 0, 0, "", @"### 74")
						CASE $$dec: Code ($$fsub, $$none, 0, 0, 0, 0, "", @"### 75")
						CASE ELSE:	PRINT "i47 bustoid": GOTO eeeCompiler
					END SELECT
		CASE $$DOUBLE
					IF mReg THEN
						Code ($$fld, $$ro, 0, mReg, mAddr, $$DOUBLE, "", @"### 76")
					ELSE
						Code ($$fld, $$abs, 0, 0, mAddr, $$DOUBLE, "", @"### 77")
					END IF
					Code ($$fld1, $$none, 0, 0, 0, 0, "", @"### 78")
					SELECT CASE op86
						CASE $$inc:	Code ($$fadd, $$none, 0, 0, 0, 0, "", @"### 79")
						CASE $$dec: Code ($$fsub, $$none, 0, 0, 0, 0, "", @"### 80")
						CASE ELSE:	PRINT "i51 bustoid": GOTO eeeCompiler
					END SELECT
		CASE ELSE
					GOTO eeeTypeMismatch
	END SELECT
	IF ctype THEN
		SELECT CASE ttype
			CASE $$SINGLE, $$DOUBLE
						Code ($$fstp, $$ro, 0, creg, offset, ttype, "", "### 81")
			CASE ELSE
						Code ($$st, $$roreg, oreg, creg, offset, ttype, "", @"### 82")
		END SELECT
	ELSE
		SELECT CASE ttype
			CASE $$SINGLE, $$DOUBLE
						FloatStore ($$RA0, tvart, ttype)
			CASE ELSE
						IFZ treg THEN Move (tvart, ttype, oreg, ttype)
		END SELECT
	END IF
END SUB
'
'
' *****  EXTERNAL FUNCTION  *****
' *****  INTERNAL FUNCTION  *****
' *****  DECLARE  FUNCTION  *****
'
' DECLARE [C|S]FUNCTION [type.name] function.name ( [parameter.list] )
'
p_external_func:
p_internal_func:
p_declare_func:
	IF got_function THEN GOTO eeeDeclare
	IFZ program$ THEN program$ = programName$
	IFZ got_declare THEN
		got_declare = $$TRUE
		IF i486asm THEN
			EmitData ()
			EmitNull (@".align	8")
			EmitLabel (@"___firstStatic")
			EmitLabel (@"___entered")
			EmitNull (@".zero  8")
			EmitNull (@"#")
		END IF
		EmitText ()
		ef$ = funcSymbol$[entryFunction]
		xit = (ef$ = "Xit")
	END IF
'
	token = NextToken ()
	SELECT CASE token
		CASE T_FUNCTION		: declareFuncKind = $$XFUNC
'		CASE T_SFUNCTION	: declareFuncKind = $$XFUNC		' Windows
		CASE T_SFUNCTION	: declareFuncKind = $$CFUNC		' SCO + Linux
		CASE T_CFUNCTION	: declareFuncKind = $$CFUNC
		CASE ELSE					: GOTO eeeSyntax
	END SELECT
'
	token = NextToken ()
	func_type = TypenameToken (@token)
	kind = token{$$KIND}
	IF (kind <> $$KIND_FUNCTIONS) THEN GOTO eeeSyntax
	IF token{$$ALLO} THEN PRINT "dupdec3": GOTO eeeDupDeclaration
	func_num = token{$$NUMBER}
	DIM tempArg[19]
	funcScope[func_num] = funcScope
	IF ((func_num = entryFunction) AND (funcScope = $$FUNC_EXTERNAL)) THEN
		GOTO eeeEntryFunction
	END IF
	funcName$	= funcSymbol$[func_num]
	lastChar	= funcName${LEN(funcName$)-1}
	IFZ charsetSymbolInner[lastChar] THEN AssemblerSymbol (@funcName$)
'
	rt = token{$$TYPE}
	IF rt THEN
		IF func_type AND (rt <> func_type) THEN GOTO eeeTypeMismatch
		func_type = rt
	END IF
	IF (func_type < $$SLONG) THEN func_type = $$XLONG
	funcType[func_num] = func_type
	tempArg[0] = ($$KIND_VARIABLES << 24) + func_type
	function_token = token OR ($$TYPE_DECLARED << 16)
	IF (func_type >= $$SCOMPLEX) THEN func_type = 0
	funcKind[func_num] = declareFuncKind
	token = NextToken ()
	IF (token != T_LPAREN) THEN GOTO eeeSyntax
'
	arg								= 0
	argNum						= 1
	declare_arg_addr	= 0
	token = PeekToken()
	IF (token = T_RPAREN) THEN token = NextToken(): GOTO p_dec_end_of_parameters
'
' *****  collect and log the parameter kinds and types  *****
'
p_dec_p_loop:
	DO
		token				= NextToken ()
		akind				= $$KIND_VARIABLES
		temp_type		= TypenameToken (@token)
		IF (token = T_ATSIGN) THEN token = NextToken ()			' ignore @ prefix
		SELECT CASE temp_type
			CASE $$ETC
						declare_arg_addr = 64						' allow 16 words of args on "..."
						IF (token != T_RPAREN) THEN GOTO eeeSyntax
						IF (declareFuncKind != $$CFUNC) THEN GOTO eeeSyntax
			CASE ELSE
						pkind = token{$$KIND}
						SELECT CASE pkind
							CASE $$KIND_STATEMENTS
										IF (token != T_ANY) THEN GOTO eeeSyntax
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
										END IF
						END SELECT
		END SELECT
'
		tempArg[argNum]	= (akind << 24) + temp_type
		IF (akind = $$KIND_ARRAYS) THEN
			declare_arg_addr = declare_arg_addr + 4
		ELSE
			SELECT CASE temp_type
				CASE $$GIANT, $$DOUBLE
							declare_arg_addr = declare_arg_addr + 8
				CASE $$ETC
							' nop
				CASE ELSE
							declare_arg_addr = declare_arg_addr + 4
			END SELECT
		END IF
		INC arg
		INC argNum
	LOOP WHILE (token = T_COMMA)
'
' *****
' *****  all parameters collected  *****
' *****
'
p_dec_end_of_parameters:
	tempArg[0] = tempArg[0] + (arg << 16)
	funcArgSize[func_num] = declare_arg_addr
	ATTACH funcArg[func_num, ] TO temp[]: DIM temp[]
	ATTACH tempArg[] TO funcArg[func_num, ]
	IF (token != T_RPAREN) THEN GOTO eeeSyntax
	SELECT CASE declareFuncKind
		CASE $$XFUNC:	funcName$ = funcName$ + "_" + STRING(declare_arg_addr)
		CASE $$SFUNC:	PRINT "$$SFUNC.a" : GOTO eeeCompiler
'		CASE $$CFUNC:
	END SELECT
	SELECT CASE funcScope
		CASE $$FUNC_DECLARE
					funcName$ = funcName$						' SCO add
'					funcName$ = "_" + funcName$			' SCO del from NT
					IF i486asm THEN EmitNull (".globl	" + funcName$)
					AddLabel (@funcName$, $$T_LABELS, $$XNEW)
		CASE $$FUNC_EXTERNAL
					funcName$ = funcName$						' SCO add
'					funcName$ = "_" + funcName$			' SCO del from NT
					IF i486asm THEN EmitNull (".globl	" + funcName$)
		CASE $$FUNC_INTERNAL
					AddLabel (@funcName$, $$T_LABELS, $$XNEW)
		CASE ELSE
					GOTO eeeCompiler
	END SELECT
'
'	IF i486asm THEN
'		IFZ libraryDeclaration THEN Code ($$jmp, $$rel, 0, 0, 0, 0, @funcName$, "### 83")
'	END IF
'
	libraryFunctionLabel$ = funcName$
	funcLabel$[func_num] = funcName$
	funcToken[func_num] = function_token
'
	IF i486asm THEN
		IF export THEN
			IF (funcScope = $$FUNC_DECLARE) THEN
				IFZ preExports THEN
					preExports = $$TRUE
					string$ = "EXPORTS  ____blowback_" + program$
					WriteDefinitionFile (@string$)
					string$ = "EXPORTS  __StartLibrary_" + program$
					WriteDefinitionFile (@string$)
				END IF
				string$ = "EXPORTS  " + funcSymbol$[func_num]
				WriteDefinitionFile (@string$)
			END IF
		END IF
	END IF
'
	RETURN (NextToken())
'
' *****  subroutine for DECLARE  *****
'
SUB ValidateParameterSymbol
	token_type = token{$$TYPE}
	IF token_type THEN
		IF temp_type THEN
			IF (token_type <> temp_type) THEN GOTO eeeTypeMismatch
		END IF
		temp_type = token_type
	ELSE
		IFZ temp_type THEN temp_type = $$XLONG
	END IF
END SUB
'
'
' *****  DIM  *****
'
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
'
'
' *****  DO  *****
'
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
	END IF
'
	SELECT CASE token
		CASE T_DO
					checkLevel = nestLevel
					checkToken = T_DO
					GOSUB NestWalk
					d1$ = "do." + HEX$(nestCount[checkLevel], 4)
					Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 84")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_FOR
					checkLevel = nestLevel
					checkToken = T_FOR
					GOSUB NestWalk
					d1$ = "for." + HEX$(nestCount[checkLevel], 4)
					Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 85")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_LOOP
					checkLevel = nestLevel
					checkToken = T_DO
					GOSUB NestWalk
					d1$ = "do.loop." + HEX$(nestCount[checkLevel], 4)
					Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 86")
					IF skipLevels THEN token = NextToken ()
					token = NextToken ()
					RETURN (token)
		CASE T_NEXT
					checkLevel = nestLevel
					checkToken = T_FOR
					GOSUB NestWalk
					d1$ = "do.next." + HEX$(nestCount[checkLevel], 4)
					Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 87")
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
	IF i486bin THEN
		dbname$ = ".dobreak" + HEX$(func_number) + "." + HEX$(nestCount,4)
		dbtoken = $$T_VARIABLES + ($$XLONG << 16)
		dbtoken = AddSymbol (@dbname$, dbtoken, func_number)
		db = dbtoken{$$NUMBER}
		IF m_addr$[db] THEN PRINT ".dobreak": GOTO eeeCompiler
		AssignAddress (dbtoken)
		IF XERROR THEN EXIT FUNCTION
		Code ($$mov, $$regimm, $$eax, 0, 0, $$XLONG, "", "### 88")
		Move (dbtoken, $$XLONG, $$eax, $$XLONG)
	END IF
	EmitLabel ("do." + HEX$(nestCount[nestLevel], 4))
	IF i486bin THEN
		INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
		Move ($$eax, $$XLONG, dbtoken, $$XLONG)
		Code ($$inc, $$reg, $$eax, 0, 0, $$XLONG, "", "### 89")
		Move (dbtoken, $$XLONG, $$eax, $$XLONG)
		Code ($$and, $$regimm, $$eax, 0x000000ff, 0, $$XLONG, "", "### 90")
		Code ($$jnz, $$rel, 0, 0, 0, 0, @d1$, "### 91")
'		Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages$0", "### 92")				' gas ?
		Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages_0", "### 92")				' unspas
		EmitLabel (@d1$)
	END IF
	IF nothing THEN RETURN (token)
	where$ = "end.do." + HEX$(nestCount[nestLevel], 4)
	GOSUB Tester
	IF ifc THEN
		GOSUB TestTrue
	ELSE
		GOSUB TestFalse
	END IF
	RETURN (token)
'
'
' *****  ELSE  *****
'
p_else:
	got_executable = $$TRUE
	IF (nestInfo[nestLevel]) THEN GOTO eeeNest
	IF (nestToken[nestLevel] <> T_IF) THEN GOTO eeeNest
	nestInfo[nestLevel] = $$TRUE
	d1$ = "end.if." + HEX$(nestCount[nestLevel], 4)
	Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 93")
	EmitLabel ("else." + HEX$(nestCount[nestLevel], 4))
	token = NextToken ()
	RETURN (token)
'
'
' *****  END  *****
'
' END, END FUNCTION, END IF, END PROGRAM, END SELECT, END SUB
'
p_end:
	token = NextToken ()
	IF (token != T_EXPORT) THEN got_executable = $$TRUE
	SELECT CASE token
		CASE T_EXPORT										: GOTO p_end_export
		CASE T_FUNCTION									: GOTO p_end_function
		CASE T_IF												: GOTO p_end_if
		CASE T_PROGRAM									: GOTO p_end_program
		CASE T_SELECT										: GOTO p_end_select
		CASE T_SUB											: GOTO p_end_sub
		CASE $$T_STARTS, T_REM, T_COLON	: GOTO p_end_program
		CASE ELSE												: GOTO eeeSyntax
	END SELECT
'
'
' ************************
' *****  END EXPORT  *****
' ************************
'
p_end_export:
	export = $$FALSE
	RETURN ($$T_STARTS)
'
'
' **************************
' *****  END FUNCTION  *****
' **************************
'
p_end_function:
p_end_functions:
	got_executable = $$FALSE
	got_object_declaration = $$FALSE
	IF (insub OR nestLevel) THEN insub = 0 : nestLevel = 0 : GOTO eeeNest
	token = ReturnValue (@rt)
	IF XERROR THEN EXIT FUNCTION
	funcKind = funcKind[func_number]
	hfn$ = HEX$(func_number)
'
' Emit function EPILOG
'
	IF i486asm THEN EmitNull (@"#;")
	EmitLabel ("end.func" + hfn$)
'
' Deallocate AUTO and AUTOX composite data
'
	IF compositeNumber[func_number] THEN
		Deallocate (compositeToken[func_number, 0])
	END IF
'
' Deallocate AUTO and AUTOX strings and arrays
'
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
					END IF
				NEXT j
			END IF
		NEXT i
	END IF
'
'
' Compute base addresses of the areas on the stack frame
'
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
'
'
' call "end_program" routine if done with entry function
'
	IFZ library THEN
		IF (func_number = entryFunction) THEN
			IF i486asm THEN EmitNull (@"#;")
			Code ($$call, $$rel, 0, 0, 0, 0, "end_program", @"### 94")
		END IF
	END IF
'
'	return to calling function, abandon frame
'
' ****************************
' *****  IMPORTANT NOTE  *****
' ****************************
'
' Don't try to restore esi, edi, ebx with "pop" instructions.
' That may work in C, but it doesn't work here because esp may
' not be where necessary - as when a function is exited from
' within a subroutine.
'
	Code ($$mov, $$regro, $$esi, $$ebp, -12, $$XLONG, "", @"### 95")
	Code ($$mov, $$regro, $$edi, $$ebp, -16, $$XLONG, "", @"### 96")
	Code ($$mov, $$regro, $$ebx, $$ebp, -20, $$XLONG, "", @"### 97")
	Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, "", @"### 98")
	Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 99")
	funcArgSize = funcArgSize[func_number]
	IF funcArgSize THEN
		SELECT CASE funcKind
			CASE $$XFUNC	: Code ($$ret, $$imm, funcArgSize, 0, 0, 0, "", @"### 100")
			CASE $$SFUNC	: PRINT "$$SFUNC.b" : GOTO eeeCompiler
			CASE $$CFUNC	: Code ($$ret, $$none, 0, 0, 0, 0, "", @"### 101")
		END SELECT
	ELSE
		Code ($$ret, $$none, 0, 0, 0, 0, "", @"### 102")
	END IF
'
'
' **********************************
' *****  Emit function PROLOG  *****
' **********************************
'
	#emitasm = 2
'
	IF i486asm THEN
		EmitNull (@"#  *****")
		EmitNull ("#  *****  FUNCTION  " + funcSymbol$[func_number] + " ()  *****")
		EmitNull (@"#  *****")
	END IF
'
	EmitLabel ("func" + hfn$)
'	IF i486bin THEN Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages$0", @"### 103")		' gas ?
	IF i486bin THEN Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages_0", @"### 103")		' unspas
	INC labelNumber : d0$ = "_" + HEX$(labelNumber, 4)
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 104")
	Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, "", @"### 105")
	Code ($$sub, $$regimm, $$esp, inarg_base, 0, $$XLONG, "", @"### 106")
	Code ($$mov, $$roreg, $$esi, $$ebp, -12, $$XLONG, "", @"### 107")
	Code ($$mov, $$roreg, $$edi, $$ebp, -16, $$XLONG, "", @"### 108")
	Code ($$mov, $$roreg, $$ebx, $$ebp, -20, $$XLONG, "", @"### 109")
	IF (func_number = entryFunction) THEN Code ($$call, $$rel, 0, 0, 0, 0, @"____initOnce", "### 110")
'
	zeroz = -autoxAddr[func_number]
	IF zeroz THEN
'		count	= ((-20 - zeroz) >>> 2) + 1												' with $XERROR at ebp-20
		count	= ((-24 - zeroz) >>> 2) + 1												' with nothing at ebp-20
'		IF (count <= 0) THEN PRINT "count": GOTO eeeCompiler		' with $XERROR at ebp-20
		IF (count < 0) THEN PRINT "count": GOTO eeeCompiler			' with nothing at ebp-20
		IF count THEN
			Code ($$cld, $$none, 0, 0, 0, 0, "", @"### 111")
			Code ($$lea, $$regro, $$edi, $$ebp, zeroz, $$XLONG, "", @"### 112")
			Code ($$mov, $$regimm, $$ecx, count, 0, $$XLONG, "", @"### 113")
			Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", @"### 114")
			Code ($$rep, $$none, 0, 0, 0, 0, "", @"### 115")
			Code ($$stosd, $$none, 0, 0, 0, 0, "", @"### 116")
		END IF
	END IF
'
' Assign addresses to AUTO and AUTOX composite handles
'
	cn = compositeNumber[func_number]
	IF cn THEN
		totalSize = compositeNext[func_number, cn]
		Code ($$mov, $$regimm, $$esi, totalSize, 0, $$XLONG, "", @"### 117")
		Code ($$call, $$rel, 0, 0, 0, 0, @"_____calloc", @"### 118")
		base = compositeToken[func_number, 0]
		Move (base, $$XLONG, $$esi, $$XLONG)
		FOR i = 1 TO cn
			compositeToken = compositeToken[func_number, i]
			compositeStart = compositeStart[func_number, i]
			Code ($$lea, $$regro, $$edi, $$esi, compositeStart, $$XLONG, "", @"### 119")
			Move (compositeToken, $$XLONG, $$edi, $$XLONG)
		NEXT i
	END IF
'
' if composite then save address where caller wants composite return value
'
	IF crvtoken THEN Move (crvtoken, $$XLONG, $$R12, $$XLONG)
'
' branch to body of function
'
	IF i486bin THEN Code ($$jmp, $$rel, 0, 0, 0, 0, "funcBody" + hfn$, @"### 120")		' v0.0201
'
	#emitasm = 2								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"
	EmitAsm (@";")							' flush everything in assembly language output buffer
	#emitasm = 0								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"
'
	IF (func_number = entryFunction) THEN
		SELECT CASE TRUE
			CASE i486asm
						EmitNull (@"#")
						EmitNull (@"#")
						EmitLabel (@"____initOnce")
						Code ($$mov, $$regabs, $$eax, 0, 0, $$XLONG, @"___entered", "### 121")
						Code ($$or,  $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 122")
						Code ($$jnz, $$rel, 0, 0, 0, 0, @"____initOnceDone", "### 123")
						Code ($$mov, $$regimm, $$esi, 0, 0, $$XLONG, @"___firstStatic", @"### 124")
						Code ($$mov, $$regimm, $$edi, 0, 0, $$XLONG, @"___lastStatic", @"### 125")
			CASE i486bin
						EmitLabel (@"____initOnce")
						Code ($$mov, $$regabs, $$eax, 0, &##ENTERED, $$XLONG, "", "### 126")
						Code ($$or,  $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 127")
						Code ($$jnz, $$rel, 0, 0, 0, 0, @"____initOnceDone", "### 128")
						Code ($$mov, $$regimm, $$esi, ##GLOBAL0, 0, $$XLONG, "", "### 129")
						Code ($$mov, $$regimm, $$edi, ##GLOBALZ, 0, $$XLONG, "", "### 130")
		END SELECT
'
		Code ($$call, $$rel, 0, 0, 0, 0, @"__ZeroMemory", @"### 131")
		Code ($$call, $$rel, 0, 0, 0, 0, @"PrologCode", @"### 132")
		Code ($$call, $$rel, 0, 0, 0, 0, @"InitSharedComposites", @"### 133")
'
		SELECT CASE TRUE
			CASE i486asm	: Code ($$mov, $$absimm, 0, -1, 0, $$XLONG, @"___entered", "### 134")
			CASE i486bin	: Code ($$mov, $$absimm, 0, -1, &##ENTERED, $$XLONG, "", "### 135")
		END SELECT
'
		EmitLabel (@"____initOnceDone")
		Code ($$ret, $$none, 0, 0, 0, 0, "", @"### 136")
'
		IF i486asm THEN
			EmitNull (@"#\n#")
			EmitNull (".globl	____blowback_" + program$)
			EmitLabel ("____blowback_" + program$)
			Code ($$mov, $$absimm, 0, 0, 0, $$XLONG, @"___entered", "### 137")
			Code ($$ret, $$none, 0, 0, 0, 0, "", "### 138")
		END IF
	END IF
'
	ina_function	= $$FALSE
	funcKind			= $$FALSE
	funcType			= $$FALSE
	func_number		= $$FALSE
	hfn$					= ""
'
	IF xargNum THEN
		FOR i = 0 TO xargNum - 1
			IF i486asm THEN
				EmitNull ("def	" + xargName$[i] + "," + STRING$ (inarg_base + xargAddr[i]))
				xargName$[i]	= ""
				xargAddr[i]		= 0
			END IF
		NEXT i
		xargNum = 0
	END IF
	RETURN (token)
'
'
' *****  END IF  *****
'
p_endif:
p_end_if:
	got_executable = $$TRUE
	IF (nestLevel < 0) THEN GOTO eeeNest
	IF (nestToken[nestLevel] != T_IF) THEN GOTO eeeNest
	IF (nestLevel[nestLevel] != nestLevel) THEN GOTO eeeNest
	IFZ nestInfo[nestLevel] THEN
		EmitLabel ("else." + HEX$(nestCount[nestLevel], 4))
	END IF
	EmitLabel ("end.if." + HEX$(nestCount[nestLevel], 4))
	DEC nestLevel
	token = NextToken ()
	RETURN (token)
'
'
' *****  END SELECT *****
'
p_end_select:
	got_executable = $$TRUE
	stk = nestVar[nestLevel]
	sty = TheType (stk)
	itk = nestToken[nestLevel]
	ifc = nestInfo[nestLevel]
	isc = nestCount[nestLevel]
'
' the following line can't be: "IFF ifc THEN"  (need to test for -1)
'
	IF (ifc <> $$TRUE) THEN
		EmitLabel ("case." + HEX$(nestCount[nestLevel], 4) + "." + HEX$(ifc, 4))
	END IF
	IF (nestLevel < 0) THEN nestLevel = 0 : GOTO eeeNest
	IF (nestLevel[nestLevel] <> nestLevel) THEN GOTO eeeNest
	IF ((itk AND 0x1F00FFFF) <> T_SELECT) THEN GOTO eeeNest
	EmitLabel ("end.select." + HEX$(nestCount[nestLevel], 4))
	DEC nestLevel
	token = NextToken ()
	RETURN (token)
'
'
'
' *****  END SUB  *****
'
p_end_sub:
	got_executable = $$TRUE
	stoken = subToken[subCount]
	IFF insub THEN GOTO eeeNest
	IF nestLevel THEN GOTO eeeNest
	EmitLabel ("end.sub" + hfn$ + "." + HEX$(subCount))
	Code ($$ret, $$none, 0, 0, 0, $$XLONG, "", @"### 139")
	EmitLabel ("out.sub" + hfn$ + "." + HEX$(subCount))
	insub$ = ""
	insub = $$FALSE
	INC subCount
	token = NextToken ()
	RETURN (token)
'
'
' *****  END PROGRAM  *****
'
p_end_program:
	got_executable = $$FALSE
	got_object_declaration = $$FALSE
	IF func_number THEN GOTO eeeWithinFunction
	IF nestLevel THEN nestLevel = 0: GOTO eeeNest
	IFZ program$ THEN program$ = programName$
	IFZ programName$ THEN programName$ = program$
'
	EmitLabel (@"end_program")
	IF i486asm THEN
		EmitData ()
		EmitNull (@".zero	8")
		EmitLabel ("___lastStatic")
		EmitNull (".zero	8")
		EmitText ()
	END IF
	Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 140")
	Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, "", @"### 141")
	Code ($$sub, $$regimm, $$esp, 128, 0, $$XLONG, "", @"### 142")
	IF i486asm THEN EmitNull (@"#;")
'
' deallocate composite data area
'
	IF compositeNumber[0] THEN
		tk	= compositeToken[0, 0]
		Move ($$esi, $$XLONG, tk, $$XLONG)
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 143")
	END IF
'
' deallocate STATIC and SHARED strings and arrays
'
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
						END IF
					NEXT j
				END IF
			NEXT h
		END IF
	NEXT f
'
' return to invoking program or XBasic environment
'
	past_statics = (externalAddr + 0x0100) AND 0xFFFFFF00
	IF i486asm THEN EmitNull (@"#;")
'
' from Windows version - may need when DLLs are supported
'
'	IF i486asm THEN
'		EmitNull (@"#;")
'		IFZ library THEN
'			EmitNull (@".globl	_XxxTerminate$0")																' gas ?
'			EmitNull (@".globl	_XxxTerminate_0")																' unspas
'			Code ($$call, $$rel, 0, 0, 0, 0, @"XxxTerminate$0", @"### 144")			' gas ?
'			Code ($$call, $$rel, 0, 0, 0, 0, @"XxxTerminate_0", @"### 144")			' unspas
'		END IF
'		EmitNull (@"#;")
'	END IF
'
	Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, "", @"### 145")
	Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 146")
	Code ($$ret, $$none, 0, 0, 0, $$XLONG, "", @"### 147")
'
' assign addresses to EXTERNAL, SHARED, STATIC composite handles
'
	IF i486asm THEN
		EmitNull (@"#;")
		EmitNull (@"#;")
	END IF
	EmitLabel ("InitSharedComposites")
	cn = compositeNumber[0]
	IF cn THEN
		totalSize = compositeNext[0, cn]
		Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 148")
		Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, "", @"### 149")
		Code ($$sub, $$regimm, $$esp, 128, 0, $$XLONG, "", @"### 150")
		Code ($$mov, $$regimm, $$esi, totalSize, 0, $$XLONG, "", @"### 151")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____calloc", @"### 152")
		Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, "", @"### 153")
		base = compositeToken[0, 0]
		Move (base, $$XLONG, $$eax, $$XLONG)
		FOR i = 1 TO cn
			compositeToken = compositeToken[0, i]
			compositeStart = compositeStart[0, i]
			Code ($$lea, $$regro, $$edi, $$eax, compositeStart, $$XLONG, "", @"### 154")
			Move (compositeToken, $$XLONG, $$edi, $$XLONG)
		NEXT i
		Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, "", @"### 155")
		Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 156")
	END IF
	Code ($$ret, $$none, 0, 0, 0, $$XLONG, "", @"### 157")
'
	IF i486asm THEN
		EmitNull (@"#;")
		EmitNull (@"#;")
		EmitNull (@"#;  *****  DEFINE LITERAL STRINGS  *****")
		EmitNull (@"#;")
	END IF
'
' NOTE:	Literal strings are compiled into READ-ONLY program memory !!!
'
	EmitText()
	EmitNull (".align	8")
	IF i486bin THEN litStringAddr = xpc
'
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
			label$ = "__string." + HEX$(xx, 4)
			EmitString (label$, inlit$)
		END IF
		INC xx
	LOOP
'
	EmitString (@"__string.Entry", @"Entry")
	EmitString (@"__string.StartLibrary", @"__StartLibrary_")
'
' Make sure all referenced GOTO and GOSUB labels were defined  (asm only)
'
  i = 0
	pass2errors = 0
	DIM errSymbol$[]
	DIM errToken[]
	DIM errAddr[]
	IF i486asm THEN GOSUB PatchAsm
	IF i486bin THEN GOSUB PatchBin
	IF pass2errors THEN
		REDIM errSymbol$[pass2errors-1]
		REDIM errToken[pass2errors-1]
		REDIM errAddr[pass2errors-1]
	END IF
'
' generate makefile to generate .EXE or .DLL
'
	slot = 0
	fixlib = 0
	IF i486asm THEN
		IF program$ THEN
			SELECT CASE LCASE$ (program$)
				CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
				CASE ELSE		: fixlib = $$TRUE
			END SELECT
			IF fixlib THEN
				IF libraryName$[] THEN
					upper = UBOUND (libraryName$[])
					DIM lib$[upper]
					FOR i = 0 TO upper
						libname$ = TRIM$ (libraryName$[i])
						IF libname$ THEN
							SELECT CASE LCASE$ (libname$)
								CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
								CASE ELSE		: lib$[slot] = libname$ + ".o"
															INC slot
							END SELECT
						END IF
					NEXT i
				END IF
'
				attr = 0
				GetSubPath (@"xxx", "", @path$[])
				IF library THEN
					XstFindFile (@"xdll.xxx", @path$[], @file$, @attr)
				ELSE
					XstFindFile (@"xapp.xxx", @path$[], @file$, @attr)
				END IF
'
				XstLoadStringArray (@file$, @file$[])
'
				app = $$FALSE
				libs = $$FALSE
				IF file$[] THEN
					FOR i = 0 TO UBOUND (file$[])
						IFZ app THEN
							app = INSTR (file$[i], "APP")
							IF app THEN
								line$ = file$[i]
								equal = RINSTR (line$, "=")
								IF equal THEN file$[i] = LEFT$ (line$, equal) + " " + programName$
							END IF
						END IF
						IFZ libs THEN
							libs = INSTR (file$[i], "LIBS")
							IF libs THEN
								libs$ = file$[i]
								equal = RINSTR (libs$, "=")
								IF equal THEN
									IF slot THEN
										FOR j = 0 TO slot-1
											libs$ = libs$ + " " + lib$[j]
										NEXT j
										file$[i] = libs$
									END IF
								END IF
							END IF
						END IF
						IF app THEN
							IF libs THEN
								mak$ = programPath$
								IF (RIGHT$(mak$,2) = ".x") THEN mak$ = RCLIP$(mak$,2)
								IF mak$ THEN
									ofile$ = mak$ + ".mak"
									XstSaveStringArray (@ofile$, @file$[])
								END IF
								EXIT FOR
							END IF
						END IF
					NEXT i
				END IF
			END IF
		END IF
	END IF
'
	XxxCloseCompileFiles ()
	end_program = $$TRUE
	token = NextToken ()
	RETURN (token)
'
' *****  PatchAsm  *****
'
SUB PatchAsm
	DO WHILE (i <= labelPtr)
		token = tab_lab[i]
		laddr = labaddr[i]
		ltype = token{$$TYPE}
		SELECT CASE ltype
			CASE $$GOADDR, $$SUBADDR
				IFZ laddr THEN
					lab$	= MID$ (tab_lab$[i], 4)
'					name	= RINSTR (lab$, ".") - 1						' gas ?
					name	= RINSTR (lab$, "_") - 1						' unspas
					lab$	= LEFT$ (lab$, name)
					IFZ pass2errors THEN PRINT "*****  PATCH ERRORS  *****"
					PRINT "GOTO label <"; lab$; "> never defined."
					INC pass2errors
				END IF
		END SELECT
		INC i
	LOOP
'
' Make sure all DECLARE functions and INTERNAL functions were defined.
'
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
				END IF
			END IF
		END IF
		INC i
	LOOP
END SUB
'
' *****  PatchBin  *****
'
SUB PatchBin
	FOR i = 0 TO patchPtr - 1
		p0 = patchType[i]					' VALUELOW, VALUEHIGH, OFFSETSHORT, OFFSETLONG, XARGOFFSET
		p1 = patchAddr[i]					' Address to patch
		p2 = patchDest[i]					' Token of destination label (func# for XARGOFFSET)
		pp = p2{$$NUMBER}					' Token #: destination label
		kind = p2{$$KIND}					' Token kind
		SELECT CASE kind
			CASE $$KIND_LABELS
				p3 = labaddr[pp]			' Address of destination
				IFZ p3 THEN
					lab$ = tab_lab$[pp]
					token = p2
					laddr = p1
					GOSUB AddPatchError
					DO NEXT
				END IF
			CASE $$KIND_VARIABLES, $$KIND_ARRAYS
				p3 = external_base + external_offset
				external_offset = external_offset + 8
		END SELECT
		SELECT CASE p0
			CASE $$VALUEABS
				absOffset = UBYTEAT(p1) OR (UBYTEAT(p1, 1) << 8) OR (UBYTEAT(p1, 2) << 16) OR (UBYTEAT(p1, 3) << 24)
				IF absOffset THEN PRINT "CheckState() : absOffset != 0"
				addr = p3 + absOffset
				UBYTEAT (p1) = addr AND 0xFF
				UBYTEAT (p1, 1) = (addr AND 0xFF00) >> 8
				UBYTEAT (p1, 2) = (addr AND 0xFF0000) >> 16
				UBYTEAT (p1, 3) = (addr AND 0xFF000000) >> 24
			CASE $$VALUEDISP
				addr = p3 - (p1 + 4)
				UBYTEAT (p1) = addr AND 0xFF
				UBYTEAT (p1, 1) = (addr AND 0xFF00) >> 8
				UBYTEAT (p1, 2) = (addr AND 0xFF0000) >> 16
				UBYTEAT (p1, 3) = (addr AND 0xFF000000) >> 24
			CASE ELSE
				PRINT "patch error"
				GOTO eeeCompiler
		END SELECT
	NEXT i
'
' Check for never defined functions
'
	i = 0
	DO WHILE (i <= maxFuncNumber)
		token = funcToken[i]
		IF token THEN
			flocal = funcScope[i]
			IF flocal THEN															' INTERNAL or DECLARE
				IFZ (token AND $$MASK_DEFINED) THEN
					lab$ = funcSymbol$[i]
					laddr = 0
					GOSUB AddPatchError
				END IF
			END IF
		END IF
		INC i
	LOOP
END SUB
'
' *****  Log Patch Errors  *****
'
SUB AddPatchError
	upper = UBOUND (errAddr[])
	IF (pass2errors > upper) THEN
		upper = upper + 64
		REDIM errSymbol$[upper]
		REDIM errToken[upper]
		REDIM errAddr[upper]
	END IF
	kind = p2{$$KIND}
	tnum = p2{$$NUMBER}
	SELECT CASE kind
		CASE $$KIND_LABELS
					ltype = token{$$TYPE}
					IF ((ltype = $$GOADDR) OR (ltype = $$SUBADDR)) THEN
						lab$ = MID$ (lab$, 4)
'						name = RINSTR (lab$, ".") - 1						' gas ?
						name = RINSTR (lab$, "_") - 1						' unspas
						lab$ = LEFT$ (lab$, name)
					END IF
		CASE ELSE
					PRINT "CheckState(): Error: (patch token kind != label) : EXIT SUB"
	END SELECT
'	PRINT HEX$(token,8);; HEX$(laddr,8);; lab$
	errSymbol$[pass2errors] = lab$
	errToken[pass2errors] = token
	errAddr[pass2errors] = laddr
	INC pass2errors
END SUB
'
'
' *****  EXIT  *****  EXIT  { DO | FOR | FUNCTION | IF | SELECT | SUB }
'
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
	END IF
'
	SELECT CASE token
		CASE T_DO
				checkLevel = nestLevel
				checkToken = T_DO
				GOSUB NestWalk
				d1$ = "end.do." + HEX$(nestCount[checkLevel], 4)
				Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 158")
		CASE T_FOR
				checkLevel = nestLevel
				checkToken = T_FOR
				GOSUB NestWalk
				d1$ = "end.for." + HEX$(nestCount[checkLevel], 4)
				Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 159")
		CASE T_FUNCTION
				IF (exitLevels != 1) THEN GOTO eeeSyntax
				GOTO p_return
		CASE T_IF
				checkLevel = nestLevel
				checkToken = T_IF
				GOSUB NestWalk
				d1$ = "end.if." + HEX$(nestCount[checkLevel], 4)
				Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 160")
		CASE T_SELECT
				checkLevel = nestLevel
				checkToken = T_SELECT
				GOSUB NestWalk
				d1$ = "end.select." + HEX$(nestCount[checkLevel], 4)
				Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 161")
		CASE T_SUB
				IFZ insub THEN GOTO eeeNest
				IF (exitLevels != 1) THEN GOTO eeeSyntax
				d1$ = "end.sub" + hfn$ + "." + HEX$(subCount)
				Code ($$jmp, $$rel, 0, 0, 0, 0, d1$, @"### 162")
		CASE ELSE
				GOTO eeeSyntax
	END SELECT
	IF skipLevels THEN token = NextToken ()
	token = NextToken ()
	RETURN (token)
'
'
'	*****
' *****  Walk down "nest-stack" to find nth checkToken (IF, DO, FOR, SELECT)
'	*****
'
SUB NestWalk
	checkLevel = nestLevel
	DO WHILE checkLevel
		nestToken = nestToken[checkLevel] AND 0x1F00FFFF
		IF (nestToken = checkToken) THEN
			DEC exitLevels
			IFZ exitLevels THEN EXIT DO
		END IF
		DEC checkLevel
	LOOP
	IFZ checkLevel THEN GOTO eeeNest
END SUB
'
'
' *****  FOR  *****
'
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
	IF (forType > $$DOUBLE) THEN GOTO eeeTypeMismatch
	IFZ m_addr[forVar] THEN AssignAddress (forToken)
	IF XERROR THEN EXIT FUNCTION
	forReg		= r_addr[forVar]
	nestVar[nestLevel] = forToken
'
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
	END IF
	nestInfo[nestLevel] = def_step
	IF i486bin THEN
		dbname$ = ".forbreak" + HEX$(func_number) + "." + HEX$(nestCount,4)
		dbtoken = $$T_VARIABLES + ($$XLONG << 16)
		dbtoken = AddSymbol (@dbname$, dbtoken, func_number)
		db = dbtoken{$$NUMBER}
		IF m_addr$[db] THEN PRINT ".forbreak": GOTO eeeCompiler
		AssignAddress (dbtoken)
		IF XERROR THEN EXIT FUNCTION
		Code ($$mov, $$regimm, $$eax, 0, 0, $$XLONG, "", "### 163")
		Move (dbtoken, $$XLONG, $$eax, $$XLONG)
	END IF
'
' setup of FOR variables complete... now do "test at top" code
'
	EmitLabel ("for." + HEX$(nestCount[nestLevel], 4))
	endfor$ = "end.for." + HEX$(nestCount[nestLevel], 4)
	Move ($$RA0, forType, forVar, forType)
	Move ($$RA1, forType, fltoken, forType)
	IF (forType = $$ULONG) THEN jmp486 = $$ja ELSE jmp486 = $$jg
'
' compare forVar with limit and branch based on SIGN of step value
'
	IFZ def_step THEN
		INC labelNumber : d1$ = "_" + HEX$(labelNumber,4)
		SELECT CASE forType
			CASE $$DOUBLE:	fakeType = $$GIANT	: treg = $$edi
			CASE $$SINGLE:	fakeType = $$XLONG	: treg = $$esi
			CASE $$GIANT:		fakeType = $$GIANT	: treg = $$edi
			CASE ELSE:			fakeType = $$XLONG	: treg = $$esi
		END SELECT
		Move ($$esi, fakeType, fstoken, fakeType)
	END IF
	SELECT CASE forType
		CASE  $$DOUBLE, $$SINGLE
					IFZ def_step THEN
						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, "", "### 164")
						Code ($$jns, $$rel, 0, 0, 0, 0, @d1$, "### 165")
						Code ($$fxch, $$none, 0, 0, 0, $$DOUBLE, "", "### 166")
						EmitLabel (@d1$)
					END IF
					Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", "### 167")
					Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", "### 168")
					Code ($$sahf, $$none, 0, 0, 0, $$XLONG, "", "### 169")
					Code ($$jb, $$rel, 0, 0, 0, 0, endfor$, "### 170")
		CASE $$GIANT
					IFZ def_step THEN
						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, "", "### 171")
						Code ($$jns, $$rel, 0, 0, 0, 0, @d1$, "### 172")
						Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", "### 173")
						Code ($$xchg, $$regreg, $$edx, $$ecx, 0, $$XLONG, "", "### 174")
						EmitLabel (@d1$)
					END IF
					Code ($$cmp, $$regreg, $$edx, $$ecx, 0, $$XLONG, "", @"### 175")
					Code ($$jg, $$rel, 0, 0, 0, 0, endfor$, @"### 176")
					INC labelNumber: d1$ = "%" + HEX$(labelNumber,4)
					Code ($$jnz, $$rel, 0, 0, 0, 0, d1$, "")
					Code ($$cmp, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 177")
					Code ($$ja, $$rel, 0, 0, 0, 0, endfor$, @"### 178")
					EmitLabel (@d1$)
'
'		$$ULONG is no longer a special case when negative step values are	allowed.
'
'		CASE $$ULONG
''					IFZ def_step THEN
''						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, "", "### 179a")
''						Code ($$jns, $$rel, 0, 0, 0, 0, @d1$, "### 179b")
''						Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", "### 179c")
''						EmitLabel (@d1$)
''					END IF
'					Code ($$cmp, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 179d")
'					Code (jmp486, $$rel, 0, 0, 0, 0, endfor$, @"### 179e")
		CASE ELSE
					IFZ def_step THEN
						Code ($$or, $$regreg, treg, treg, 0, $$XLONG, "", "### 180a")
						Code ($$jns, $$rel, 0, 0, 0, 0, @d1$, "### 180b")
						Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", "### 180c")
						EmitLabel (@d1$)
					END IF
					Code ($$cmp, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 180d")
					Code (jmp486, $$rel, 0, 0, 0, 0, endfor$, @"### 180e")
	END SELECT
	a0_type = 0
	a1_type = 0
	IF i486bin THEN
		INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
		Move ($$eax, $$XLONG, dbtoken, $$XLONG)
		Code ($$inc, $$reg, $$eax, 0, 0, $$XLONG, "", "### 184")
		Move (dbtoken, $$XLONG, $$eax, $$XLONG)
		Code ($$and, $$regimm, $$eax, 0x000000ff, 0, $$XLONG, "", "### 185")
		Code ($$jnz, $$rel, 0, 0, 0, 0, @d1$, "### 186")
'		Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages$0", "### 187")			' gas ?
		Code ($$call, $$rel, 0, 0, 0, 0, @"XxxCheckMessages_0", "### 187")			' unspas
		EmitLabel (@d1$)
		a0_type = 0
		a1_type = 0
	END IF
	RETURN (token)
'
'
' *****  FUNCTION  *****
'
' [C|S]FUNCTION [type.name] function.name ( [argument.list] ) [default.type]
'
p_xfunction:
	IF ina_function THEN GOTO eeeWithinFunction
	IFZ program$ THEN program$ = programName$
	functionTypeChunk = 0
	EmitText()
'
	SELECT CASE funcKind
		CASE $$XFUNC	: funcKind = $$XFUNC
'		CASE $$SFUNC	: funcKind = $$XFUNC		' Windows
		CASE $$SFUNC	: funcKind = $$CFUNC		' SCO + Linux
		CASE $$CFUNC	: funcKind = $$CFUNC
		CASE ELSE			: PRINT "$$xFUNC" : GOTO eeeCompiler
	END SELECT
'
	IFZ got_function THEN
		IFZ prologCode THEN
			EmitText()
			SELECT CASE TRUE
				CASE library	:  Code ($$jmp, $$rel, 0, 0, 0, 0, "__StartLibrary_" + program$, "### 188")
				CASE ELSE			:  Code ($$jmp, $$rel, 0, 0, 0, 0, @"__StartApplication", "### 189")
			END SELECT
			prologCode = $$TRUE
			EmitLabel ("PrologCode")
			Code ($$ret, $$none, 0, 0, 0, $$XLONG, "", @"### 190")
		ELSE
			Code ($$mov, $$regreg, $$esp, $$ebp, 0, $$XLONG, "", @"### 191")		' end of PrologCode
			Code ($$pop, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 192")
			Code ($$ret, $$none, 0, 0, 0, $$XLONG, "", @"### 193")
		END IF
		IF i486asm THEN EmitNull ("#")
	END IF
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
'
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
	f$											= "func" + hfn$
	compositeArg						= 0
	crvtoken								= 0
'
	IF (func_number = entryFunction) THEN
		SELECT CASE TRUE
			CASE library	: EmitNull  (".globl	__StartLibrary_" + program$)
											EmitLabel ("__StartLibrary_" + program$)
			CASE ELSE			: EmitNull  (@".globl	__StartApplication")
											EmitLabel (@"__StartApplication")
		END SELECT
'
' In case entry function takes arguments
'
'		IFZ xit THEN
			atsign = RINSTR (funcLabel$[func_number], "_")
			IF atsign THEN
				size$ = MID$ (funcLabel$[func_number],atsign+1)
				IF size$ THEN
					after = size${0}
					IF (after >= '0') THEN
						IF (after <= '9') THEN
							bytes = XLONG(size$)
							byte$ = STRING$(bytes)
							IF (size$ = byte$) THEN
								IF bytes THEN
									IF (bytes AND 0x0003) THEN GOTO eeeCompiler			' must be mod 4
									pushes = (bytes >> 2)
									Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", @"### 194")
									FOR i = 1 TO pushes
										Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 195")
									NEXT i
								END IF
							END IF
						END IF
					END IF
				END IF
			END IF
'		END IF
		Code ($$call, $$rel, 0, 0, 0, 0, @f$, @"### 196")
		Code ($$ret, $$imm, 0, 0, 0, $$XLONG, "", @"### 197")
		IF i486asm THEN EmitNull (@"#")
	END IF
'
'	errorToken	= $$T_VARIABLES OR ($$AUTOX << 21)
'	errorToken	= AddSymbol (@"$XERROR", errorToken, func_number)
'	errorToken	= errorToken OR ($$AUTOX << 21)
'	AssignAddress (errorToken)
'
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
	END IF
'
	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
'
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
			END IF
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
									IF ((temp_type = $$GIANT) OR (temp_type = $$DOUBLE)) THEN
'											IF (arg_count < (paramCount-1)) THEN GOTO eeeTypeMismatch
										GOTO eeeTypeMismatch
									END IF
								END IF
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
				END IF
				token				= NextToken ()
				IF anyOpen THEN
					IF (token != T_RPAREN) THEN DO LOOP
					token			= NextToken ()
				END IF
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
			END IF
			INC argNum
			INC arg_count
			AssignAddress (token)
			IF XERROR THEN EXIT FUNCTION
			token = NextToken()
		LOOP WHILE (token = T_COMMA)
		IF (token != T_RPAREN) THEN GOTO eeeSyntax
	END IF
	IF (arg_count < paramCount) THEN GOTO eeeTooFewArgs
'
' check for optional default.type field
'
	token		= NextToken ()
	fdtype	= TypenameToken (@token)
	IFZ fdtype THEN fdtype = $$XLONG
	defaultType[func_number] = fdtype
'
' Put branch to function entry point instruction, then "funcBody" label
'
	EmitFunctionLabel (funcLabel$[func_number])
'
'	Code ($$jmp, $$rel, 0, 0, 0, 0, f$, @"### 198")		' prior to v0.0201
'
' #####  v0.0201  #####
' The following section of code was added so the beginning part of
' the function could be emitted here rather than after the function.
'
	#emitasm = 2								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"
	EmitAsm (@";")							' flush all assembly language output from the asm buffer
	#emitasm = 1								' 0 = "emit-this-now" : 1 = "buffer-this" : 2 = "flush-buffer"
'
	IF i486bin THEN Code ($$jmp, $$rel, 0, 0, 0, 0, f$, @"### i198")			' v0.0201
'
	EmitLabel ("funcBody" + HEX$(func_number))
	RETURN (token)
'
'
' *****  GOSUB  *****
'
p_gosub:
	got_executable = $$TRUE
	code_l  = $$call
	code_v  = $$call
	gsub		= $$TRUE
	GOTO p_gox
'
'
' ****  GOTO  *****
'
p_goto:
	got_executable = $$TRUE
	code_l  = $$jmp
	code_v  = $$jmp
	gsub		= $$FALSE
'
p_gox:
	computed = $$FALSE
	token = NextToken ()
	IF (token = T_ATSIGN) THEN computed = $$TRUE: token = NextToken ()
	go_type = TheType (token)
	tt		= token{$$NUMBER}
	kind	= token{$$KIND}
	SELECT CASE kind
		CASE $$KIND_LABELS		: GOTO p_goto_label
		CASE $$KIND_VARIABLES	: GOTO p_goto_expression
		CASE $$KIND_ARRAYS		: GOTO p_goto_expression
		CASE ELSE							: GOTO eeeTypeMismatch
	END SELECT
'
'
p_goto_label:
	IF computed THEN GOTO eeeTypeMismatch
	GOSUB CheckGoType
	tt$ = tab_lab$[tt]
	Code (code_l, $$rel, 0, 0, 0, 0, tt$, @"### 199")
	token = NextToken ()
	RETURN (token)
'
p_goto_expression:
	IFZ computed THEN GOTO eeeTypeMismatch
	DEC tokenPtr
	token = Eval (@go_type)
	IF XERROR THEN EXIT FUNCTION
	GOSUB CheckGoType
	acc = Topax1 ()
	IFZ acc THEN GOTO eeeSyntax
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 200")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 201")
	Code (code_v, $$reg, acc, 0, 0, 0, "", @"### 202")
	EmitLabel (@d1$)
	RETURN (token)
'
'
SUB CheckGoType
	IF gsub THEN
		IF (go_type <> $$SUBADDR) THEN GOTO eeeBadGosub
	ELSE
		IF (go_type <> $$GOADDR) THEN GOTO eeeBadGoto
	END IF
END SUB
'
' *****  IF  and IFT  *****  IF TRUE  (non-zero)
' *****  IFF and IFZ  *****  IF FALSE   (zero)
'
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
	where$ = "else." + HEX$(nestCount[nestLevel], 4)
	GOSUB Tester
	IF ifc THEN
		GOSUB TestTrue
	ELSE
		GOSUB TestFalse
	END IF
p_if_q_then_part:
	SELECT CASE (token AND 0x1F00FFFF)
		CASE T_REM						: checkState = token		: RETURN (checkState)
		CASE $$T_STARTS				: checkState = token		: RETURN (checkState)
		CASE T_THEN, T_COMMA	: token = NextToken ()	: GOTO p_if_q_then_part
		CASE T_SEMI, T_COLON	: token = NextToken ()	: GOTO p_if_q_then_part
	END SELECT
p_if_then:
	token = CheckState (token)
	IF XERROR THEN EXIT FUNCTION
	kind = token{$$KIND}
	IF token = T_COLON THEN token = NextToken ():  GOTO p_if_then
	SELECT CASE kind
		CASE $$KIND_TERMINATORS	: GOTO p_end_if_line
		CASE $$KIND_COMMENTS		: GOTO p_end_if_line
		CASE $$KIND_STARTS			: GOTO p_end_if_line
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
		EmitLabel ("else." + HEX$(nestCount[nestLevel], 4))
	END IF
	EmitLabel ("end.if." + HEX$(nestCount[nestLevel], 4))
	nestInfo[nestLevel] = 0
	DEC nestLevel
	token = NextToken ()
	RETURN (token)
'
'
' *****  GENERIC test for true/false and branch to specified label  *****
'        Used by CASE, DO, IF, LOOP  (works on strings and null arrays)
'        NOTE:  True and False routines CANNOT be consolidated.  Don't try!
'
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
	END IF
END SUB
'
' **************************
' *****  SUB TestTrue  *****  (Use after SUB Tester)
' **************************
'
SUB TestTrue
	SELECT CASE new_type
		CASE $$GIANT:		GOTO TrueGiant
		CASE $$DOUBLE:	GOTO TrueDouble
		CASE $$SINGLE:	GOTO TrueSingle
		CASE $$STRING:	GOTO TrueString
		CASE ELSE:			GOTO TrueOthers
	END SELECT
'
TrueGiant:
	Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, "", @"### 203")
	Code ($$or, $$regreg, $$esi, accx, 0, $$XLONG, "", @"### 204")
	Code ($$jnz, $$rel, 0, 0, 0, 0, where$, @"### 205")
	EXIT SUB
'
TrueDouble:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, "", "### 206")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", @"### 207")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 208")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, "", @"### 209")
	Code ($$jnz, $$rel, 0, 0, 0, 0, where$, @"### 210")
	EXIT SUB
'
TrueSingle:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, "", "### 211")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", @"### 212")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 213")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, "", @"### 214")
	Code ($$jnz, $$rel, 0, 0, 0, 0, where$, @"### 215")
	EXIT SUB
'
TrueString:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	IF (oos[oos] = 's') THEN
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 216")
		Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 217")
		Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, "", @"### 218")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, "", @"### 219")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 220")
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 221")
		Code ($$jnz, $$rel, 0, 0, 0, 0, where$, @"### 222")
	ELSE
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 223")
		Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 224")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, "", @"### 225")
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 226")
		Code ($$jnz, $$rel, 0, 0, 0, 0, where$, @"### 227")
	END IF
	EmitLabel (@d1$)
	DEC oos
	EXIT SUB
'
TrueOthers:
	IF new_test THEN
		GOSUB ConvCondBitTrue
		Code (jmp486, $$rel, 0, 0, 0, 0, where$, @"### 228")
	ELSE
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 229")
		Code ($$jnz, $$rel, 0, 0, 0, 0, where$, @"### 230")
	END IF
END SUB
'
' ***************************
' *****  SUB TestFalse  *****  (Use after SUB Tester)
' ***************************
'
SUB TestFalse
	SELECT CASE new_type
		CASE $$GIANT:		GOTO FalseGiant
		CASE $$DOUBLE:	GOTO FalseDouble
		CASE $$SINGLE:	GOTO FalseSingle
		CASE $$STRING:	GOTO FalseString
		CASE ELSE:			GOTO FalseOthers
	END SELECT
'
FalseGiant:
	Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, "" , @"### 231")
	Code ($$or, $$regreg, $$esi, accx, 0, $$XLONG, "", @"### 232")
	Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 233")
	EXIT SUB
'
FalseDouble:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, "", "### 234")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", @"### 235")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 236")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, "", @"### 237")
	Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 238")
	EXIT SUB
'
FalseSingle:
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, "", "### 239")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", @"### 240")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 241")
	Code ($$sahf, $$none, 0, 0, 0, $$XLONG, "", @"### 242")
	Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 243")
	EXIT SUB
'
FalseString:
	IF (oos[oos] = 's') THEN
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "" , @"### 244")
		Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 245")
		Code ($$mov, $$regreg, $$esi, acc, 0, $$XLONG, "", @"### 246")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, "", @"### 247")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 248")
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 249")
		Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 250")
	ELSE
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "" , @"### 251")
		Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 252")
		Code ($$ld, $$regro, acc, acc, -8, $$XLONG, "", @"### 253")
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 254")
		Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 255")
	END IF
	DEC oos
	EXIT SUB
'
FalseOthers:
	IF new_test THEN
		GOSUB ConvCondBitFalse
		Code (jmp486, $$rel, 0, 0, 0, 0, where$, @"### 256")
	ELSE
		Code ($$or, $$regreg, acc, acc, 0, $$XLONG, "", @"### 257")
		Code ($$jz, $$rel, 0, 0, 0, 0, where$, @"### 258")
	END IF
END SUB
'
'
' *****  ConvCondBitTrue  *****
'
' Sets jmp486 to 80386 conditional jump opcode that corresponds to
' the 88000 condition bit in new_test being true.
'
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
'
' *****  ConvCondBitFalse  *****
'
' Sets jmp486$ to 80386 conditional jump mnemonic that corresponds to
' the 88000 condition bit in new_test being false.
'
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
'
'
' *****  LOOP  *****
'
p_loop:
	got_executable = $$TRUE
	IF (nestLevel < 0) THEN nestLevel = 0 : GOTO eeeNest
	IF (nestToken[nestLevel] <> T_DO) THEN GOTO eeeNest
	IF (nestLevel[nestLevel] <> nestLevel) THEN GOTO eeeNest
	token = NextToken ()
	EmitLabel ("do.loop." + HEX$(nestCount[nestLevel], 4))
	IF (token = T_WHILE) THEN ifc = $$TRUE:  GOTO loopx
	IF (token = T_UNTIL) THEN ifc = $$FALSE: GOTO loopx
	Code ($$jmp, $$rel, 0, 0, 0, 0, "do." + HEX$(nestCount[nestLevel], 4), @"### 259")
	GOTO finish_loop
loopx:
	where$ = "do." + HEX$(nestCount[nestLevel], 4)
	GOSUB Tester
	IF ifc THEN
		GOSUB TestTrue
	ELSE
		GOSUB TestFalse
	END IF
finish_loop:
	EmitLabel ("end.do." + HEX$(nestCount[nestLevel], 4))
	DEC nestLevel
	RETURN (token)
'
'
' *****  NEXT  *****
'
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
	END IF
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
	EmitLabel ("do.next." + HEX$(nestCount[nestLevel], 4))
	fortop$		= "for." + HEX$(nestCount[nestLevel], 4)
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
'
	IF def_step THEN
		SELECT CASE forType
			CASE $$DOUBLE, $$SINGLE
						Move ($$eax, forType, forVar, forType)
						Code ($$fld1, $$none, 0, 0, 0, $$DOUBLE, "", @"### 260")
						Code ($$fadd, $$none, 0, 0, 0,  $$DOUBLE, "", @"### 261")
						Move (forVar, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 262")
			CASE $$GIANT
						Move ($$eax, forType, forVar, forType)
						Code ($$add, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 263")
						Code ($$adc, $$regimm, $$edx, 0, 0, $$XLONG, "", @"### 264")
						Move (forVar, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 265")
			CASE ELSE
						mReg	= m_reg[forVar]
						mAddr	= m_addr[forVar]
						IF mReg THEN
							Code ($$inc, $$ro, 0, mReg, mAddr, $$XLONG, "", @"### 266")
						ELSE
							Code ($$inc, $$abs, 0, 0, mAddr, $$XLONG, m_addr$[forVar], @"### 267")
						END IF
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 268")
		END SELECT
	ELSE
		Move ($$eax, forType, forVar, forType)
		Move ($$ebx, forType, stepVar, forType)
		SELECT CASE forType
			CASE $$DOUBLE, $$SINGLE
						Code ($$fadd, $$none, 0, 0, 0, $$DOUBLE, "", @"### 269")
						Move (forToken, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 270")
			CASE $$GIANT
						Code ($$add, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 271")
						Code ($$adc, $$regreg, $$edx, $$ecx, 0, $$XLONG, "", @"### 272")
						Move (forToken, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 273")
'
'			Check for overflow is invalid when negative step-values are allowed!
'
'			CASE $$ULONG
'						Code ($$add, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 274a")
'						Code ($$jnc, $$rel, 0, 0, 0, 0, @d1$, @"### 274b")
'						Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 274c")
'						EmitLabel (@d1$)
'						Move (forToken, forType, $$eax, forType)
'						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 275")
			CASE ELSE
						Code ($$add, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 275a")
						Move (forToken, forType, $$eax, forType)
						Code ($$jmp, $$rel, 0, 0, 0, 0, fortop$, @"### 275b")
		END SELECT
	END IF
	a0 = 0:	a0_type = 0: a1 = 0: a1_type = 0
	EmitLabel ("end.for." + HEX$(nestCount[nestLevel], 4))
	DEC nestLevel
	RETURN (token)
'
'
' *****  PRINT  *****
'
p_print:
	got_executable = $$TRUE
	token = Printoid()
	RETURN (token)
'
'
' *****  READ  *****
'
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
'
	xx = Topax1 ()
	symbol$ = ".filenumber"
	ftoken = $$T_VARIABLES + ($$AUTOX << 21) + ($$XLONG << 16)
	ftoken = AddSymbol (@symbol$, ftoken, func_number)
	fnum = ftoken{$$NUMBER}
	IFZ m_addr$[fnum] THEN AssignAddress (ftoken)
	IF XERROR THEN EXIT FUNCTION
	Move (ftoken, $$XLONG, xx, $$XLONG)
'
' READ the variables
'
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
					r$ = "__ReadArray"
'					IF (rtype = $$STRING) THEN GOTO eeeTypeMismatch
				ELSE
					r$ = "__ReadString"
				END IF
				token			= NextToken ()
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 276")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, "", @"### 277")
				Move ($$eax, $$XLONG, rtoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, "", @"### 278")
				Code ($$call, $$rel, 0, 0, 0, 0, r$, @"### 279")
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 280")
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
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 281")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, "", @"### 282")
				Code ($$st, $$roreg, $$esp, $$esp, 4, $$XLONG, "", @"### 283")
				Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, "", @"### 284")
				Code ($$call, $$rel, 0, 0, 0, 0, "__Read", @"### 285")
				Code ($$ld, $$regro, $$eax, $$esp, 0, rtype, "", @"### 286")
				IF (rtype < $$SLONG) THEN rtype = $$SLONG
				IF mReg THEN
					Code ($$st, $$roreg, $$eax, mReg, mAddr, rtype, "", @"### 287")
				ELSE
					Code ($$st, $$absreg, $$eax, 0, mAddr, rtype, m_addr$[rt], @"### 288")
				END IF
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 289")
			END IF
		ELSE
			Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 290")
			Move ($$eax, $$XLONG, ftoken, $$XLONG)
			Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, "", @"### 291")
			ctype		= rtype
			creg		= NextToken ()
			Composite ($$GETDATAADDR, ctype, @creg, @offset, @xsize)
			IF XERROR THEN EXIT FUNCTION
			IF toes THEN Topax1 ()
			IFZ creg THEN PRINT "READcomposite": GOTO eeeCompiler
			IF offset THEN Code ($$add, $$regimm, creg, offset, 0, $$XLONG, "", @"### 292")
			Code ($$st, $$roreg, creg, $$esp, 4, $$XLONG, "", @"### 293")
			Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, "", @"### 294")
			Code ($$call, $$rel, 0, 0, 0, 0, "__Read", @"### 295")
			Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 296")
		END IF
		a0_type	= 0
		token		= NextToken ()
	LOOP WHILE (token = T_COMMA)
	RETURN (token)
'
'
' *****  RETURN  *****
'
p_return:
	got_executable = $$TRUE
	token = ReturnValue (@rt)
	IF XERROR THEN EXIT FUNCTION
	Code ($$jmp, $$rel, 0, 0, 0, 0, "end.func" + HEX$(func_number), @"### 297")
	RETURN (token)
'
'
' *****  SELECT  *****  SELECT CASE
'
p_select:
	got_executable = $$TRUE
	tf			= $$FALSE
	s_token	= token
	token		= NextToken ()
	IF (token <> T_CASE) THEN GOTO eeeSyntax
'
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
		END IF
	ELSE
		acc = Topax1 ()
		IFZ acc THEN GOTO eeeSyntax
		IF (acc != $$eax) THEN PRINT "acc <> eax": GOTO eeeCompiler
	END IF
	IF (new_type = $$STRING) THEN
		s_token = s_token OR 0x100000
		nestToken[nestLevel] = s_token
		IF (oos[oos] = 'v') THEN
'			Move ($$RA0, new_type, new_data, new_type)
			Code ($$call, $$rel, 0, 0, 0, 0, "__clone.a0" , @"### 298")
			acc			= $$RA0
			a0			= 0
			a0_type	= 0
		END IF
		DEC oos
	END IF
'
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
			Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 299")
		ELSE
			Move (stoken, new_type, acc, new_type)
		END IF
		nestVar[nestLevel] = stoken
	ELSE
		nestVar[nestLevel] = new_type << 16
	END IF
	RETURN (token)
'
'
' *****  STOP  *****
'
p_stop:
	got_executable = $$TRUE
	Code ($$int, $$imm, 3, 0, 0, $$XLONG, "", @"### 300")
	checkState = NextToken ()
	RETURN (checkState)
'
'
' *****  SUB subname  *****
'
p_sub:
	got_executable = $$TRUE
	IF (insub OR nestLevel) THEN insub = 0 : nestLevel = 0 : GOTO eeeNest
	token = NextToken ()
	kind	= token{$$KIND}
	gtype	= token{$$TYPE}
	IF (kind <> $$KIND_LABELS) THEN GOTO eeeSyntax
	IF (gtype <> $$SUBADDR) THEN GOTO eeeTypeMismatch
	symbol$ = "out.sub" + hfn$ + "." + HEX$(subCount)
	Code ($$jmp, $$rel, 0, 0, 0, 0, symbol$, @"### 301")
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
'
'
' *****  SWAP  *****
'
p_swap:
	attachoid		= $$FALSE
	GOTO p_swapper
'
p_swapper:
	dtoken = NextToken ()
	dholdPtr = tokenPtr
	IFZ GetTokenOrAddress (@dtoken, @dstyle, @termToken, @dtype, @dntype, @dbase, @doffset, @dlength) THEN GOTO eeeSyntax
	IFZ dstyle THEN tokenPtr = dholdPtr: GOTO eeeSyntax
	IF attachoid THEN
		IF (termToken != T_TO) THEN GOTO eeeSyntax
	ELSE
		IF (termToken != T_COMMA) THEN GOTO eeeSyntax
	END IF
	stoken = NextToken ()
	sholdPtr = tokenPtr
	IFZ GetTokenOrAddress (@stoken, @sstyle, @termToken, @stype, @sntype, @sbase, @soffset, @slength) THEN GOTO eeeSyntax
	IFZ sstyle THEN tokenPtr = sholdPtr: GOTO eeeSyntax
'
	SELECT CASE dtype
		CASE $$SINGLE	: dtype = $$XLONG
		CASE $$DOUBLE	: dtype = $$GIANT
	END SELECT
'
	SELECT CASE stype
		CASE $$SINGLE	: stype = $$XLONG
		CASE $$DOUBLE	: stype = $$GIANT
	END SELECT
'
	SELECT CASE dstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO varToken
		CASE $$ARRAY_TOKEN	:	GOTO arrayToken
		CASE $$ARRAY_NODE		:	GOTO arrayNode
		CASE $$DATA_ADDR		:	GOTO dataAddr
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT
'
'
' *****  dtoken = varToken  *****
'
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
'
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
		Code ($$push, $$imm, dlength, 0, 0, $$XLONG, "", "### 302")
		Code ($$push, $$reg, $$RA1, 0, 0, $$XLONG, "", "### 303")
		Code ($$push, $$reg, $$RA0, 0, 0, $$XLONG, "", "### 304")
'		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory$12", "### 305")			' gas ?
		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory_12", "### 305")			' unspas
	END IF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
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
						Code ($$ld, $$regro, $$R26, sbase, soffset, stype, "", "### 306")
						Code ($$st, $$roreg, ddata, sbase, soffset, stype, "", "### 307")
						Move (dtoken, dtype, $$R26, dtype)
			CASE ELSE
						Move (ddata, dtype, dtoken, dtype)
						Code ($$ld, $$regro, sdata, sbase, soffset, stype, "", "### 308")
						Code ($$st, $$roreg, ddata, sbase, soffset, stype, "", "### 309")
						Move (dtoken, dtype, sdata, dtype)
		END SELECT
	ELSE
		Code ($$push, $$imm, dlength, 0, 0, $$XLONG, "", "### 310")
		Move (ddata, $$XLONG, dtoken, $$XLONG)
		Code ($$push, $$reg, ddata, 0, 0, $$XLONG, "", "### 311")
		Code ($$lea, $$regro, sbase, sbase, soffset, stype, "", "### 312")
		Code ($$push, $$reg, sbase, 0, 0, $$XLONG, "", "### 313")
'		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory$12", "### 314")				' gas ?
		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory_12", "### 314")				' unspas
	END IF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
'
' *****  dtoken = arrayToken  *****
'
arrayToken:
	SELECT CASE sstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO eeeKindMismatch
		CASE $$ARRAY_TOKEN	:	GOTO arrayTokenArrayToken
		CASE $$ARRAY_NODE		:	GOTO arrayTokenArrayNode
		CASE $$DATA_ADDR		:	GOTO eeeNodeDataMismatch
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT
'
arrayTokenArrayToken:
	Move ($$RA0, $$XLONG, stoken, $$XLONG)
	IF attachoid THEN
		INC labelNumber : dx$ = "_" + HEX$(labelNumber, 4)
		Code ($$or, $$regreg, $$RA0, $$RA0, 0, $$XLONG, "", "### 315")
		Code ($$jz, $$rel, 0, 0, 0, 0, @dx$, "### 316")
		Code ($$call, $$rel, 0, 0, 0, 0, "__NeedNullNode", "### 317")
		EmitLabel (@dx$)
	END IF
	Move (stoken, $$XLONG, dtoken, $$XLONG)
	Move (dtoken, $$XLONG, $$RA0, $$XLONG)
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
arrayTokenArrayNode:
	Move ($$R26, $$XLONG, dtoken, $$XLONG)
	Code ($$ld, $$regro, $$R27, sbase, soffset, $$XLONG, "", "### 318")
	IF attachoid THEN
		INC labelNumber : dx$ = "_" + HEX$(labelNumber, 4)
		Code ($$or, $$regreg, $$R27, $$R27, 0, $$XLONG, "", "### 319")
		Code ($$jz, $$rel, 0, 0, 0, 0, @dx$, "### 320")
		Code ($$call, $$rel, 0, 0, 0, 0, "__NeedNullNode", "### 321")
		EmitLabel (@dx$)
	END IF
	Code ($$st, $$roreg, $$R26, sbase, soffset, $$XLONG, "", "### 322")
	Move (dtoken, $$XLONG, $$R27, $$XLONG)
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
'
' *****  dtoken = arrayNode  *****
'
arrayNode:
	SELECT CASE sstyle
		CASE $$NONE					:	GOTO eeeSyntax
		CASE $$VAR_TOKEN		:	GOTO eeeKindMismatch
		CASE $$ARRAY_TOKEN	:	GOTO arrayNodeArrayToken
		CASE $$ARRAY_NODE		:	GOTO arrayNodeArrayNode
		CASE $$DATA_ADDR		:	GOTO eeeNodeDataMismatch
		CASE ELSE						:	GOTO eeeCompiler
	END SELECT
'
arrayNodeArrayToken:
	Move ($$R26, $$XLONG, stoken, $$XLONG)
	Code ($$ld, $$regro, $$R27, dbase, doffset, $$XLONG, "", "### 323")
	IF attachoid THEN
		INC labelNumber : dx$ = "_" + HEX$(labelNumber, 4)
		Code ($$or, $$regreg, $$R26, $$R26, 0, $$XLONG, "", "### 324")
		Code ($$jz, $$rel, 0, 0, 0, 0, @dx$, "### 325")
		Code ($$call, $$rel, 0, 0, 0, 0, "__NeedNullNode", "### 326")
		EmitLabel (@dx$)
	END IF
	Code ($$st, $$roreg, $$R26, dbase, doffset, $$XLONG, "", "### 327")
	Move (stoken, $$XLONG, $$R27, $$XLONG)
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
arrayNodeArrayNode:
	Topax2 (@sbase, @dbase)
	Code ($$ld, $$regro, $$R26, sbase, soffset, $$XLONG, "", "### 328")
	Code ($$ld, $$regro, $$R27, dbase, doffset, $$XLONG, "", "### 329")
	IF attachoid THEN
		INC labelNumber : dx$ = "_" + HEX$(labelNumber, 4)
		Code ($$or, $$regreg, $$R26, $$R26, 0, $$XLONG, "", "### 330")
		Code ($$jz, $$rel, 0, 0, 0, 0, @dx$, "### 331")
		Code ($$call, $$rel, 0, 0, 0, 0, "__NeedNullNode", "### 332")
		EmitLabel (@dx$)
	END IF
	Code ($$st, $$roreg, $$R26, dbase, doffset, $$XLONG, "", "### 333")
	Code ($$st, $$roreg, $$R27, sbase, soffset, $$XLONG, "", "### 334")
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
'
' *****  dtoken = dataAddr  *****
'
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
'
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
						Code ($$ld, $$regro, $$R26, dbase, doffset, dtype, "", "### 335")
						Code ($$st, $$roreg, sdata, dbase, doffset, dtype, "", "### 336")
						Move (stoken, stype, $$R26, stype)
			CASE ELSE
						Move (sdata, stype, stoken, stype)
						Code ($$ld, $$regro, sdatax, dbase, doffset, dtype, "", "### 337")
						Code ($$st, $$roreg, sdata, dbase, doffset, dtype, "", "### 338")
						Move (stoken, stype, sdatax, stype)
		END SELECT
	ELSE
		Code ($$push, $$imm, dlength, 0, 0, $$XLONG, "", "### 339")
		Code ($$lea, $$regro, dbase, dbase, soffset, stype, "", "### 340")
		Code ($$push, $$reg, dbase, 0, 0, $$XLONG, "", "### 341")
		Move (dbase, $$XLONG, dtoken, $$XLONG)
		Code ($$push, $$reg, dbase, 0, 0, $$XLONG, "", "### 342")
'		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory$12", "### 343")				' gas ?
		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory_12", "### 343")				' unspas
	END IF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
dataAddrDataAddr:
	Topax2(@sbase, @dbase)
	IF (stype < $$STRING) THEN
		SELECT CASE dtype
			CASE $$GIANT
						Code ($$lea, $$regro, $$R26, sbase, soffset, stype, "", "### 344")
						Code ($$lea, $$regro, $$R27, dbase, doffset, dtype, "", "### 345")
						Code ($$ld, $$regro, $$RA0, $$R26, 0, stype, "", "### 346")
						Code ($$ld, $$regro, $$RA1, $$R27, 0, dtype, "", "### 347")
						Code ($$st, $$roreg, $$RA0, $$R27, 0, dtype, "", "### 348")
						Code ($$st, $$roreg, $$RA1, $$R26, 0, stype, "", "### 349")
			CASE ELSE
						Code ($$ld, $$regro, sbase+1, sbase, soffset, stype, "", "### 350")
						Code ($$ld, $$regro, dbase+1, dbase, doffset, dtype, "", "### 351")
						Code ($$st, $$roreg, sbase+1, dbase, doffset, dtype, "", "### 352")
						Code ($$st, $$roreg, dbase+1, sbase, soffset, stype, "", "### 353")
		END SELECT
	ELSE
		IF (dlength != slength) THEN GOTO eeeTypeMismatch
		Code ($$push, $$imm, dlength, 0, 0, $$XLONG, "", "### 354")
		Code ($$lea, $$regro, sbase, sbase, soffset, $$XLONG, "", "### 355")
		Code ($$push, $$reg, sbase, 0, 0, $$XLONG, "", "### 356")
		Code ($$lea, $$regro, dbase, dbase, doffset, $$XLONG, "", "### 357")
		Code ($$push, $$reg, dbase, 0, 0, $$XLONG, "", "### 358")
'		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory$12", "### 359")				' gas ?
		Code ($$call, $$rel, 0, 0, 0, 0, "XxxSwapMemory_12", "### 359")				' unspas
	END IF
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (termToken)
'
'
' *****  TYPE  *****  DECLARE USER-DEFINED TYPES
'
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
'
' *****  ALIAS TYPENAME SYNTAX  *****   TYPE typeName = typeName  (single line)
'
	IF (token = T_EQ) THEN
		token = NextToken ()
		atype = TypenameToken (@token)
		IFZ atype THEN GOTO eeeSyntax
		typeAlias[typeNumber] = atype
		typeAlign[typeNumber] = typeAlign[atype]
		typeNumber = 0
		RETURN ($$T_STARTS)
	END IF
	inTYPE = $$TRUE
'
' *****  TYPE DECLARATION SYNTAX  *****  (TYPE typeName...  END TYPE block)
'
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
'
'
' *****  TYPE ELEMENT DECLARATIONS  *****
' *****  UNION ELEMENT DECLARATIONS  *****
'
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
	END IF
	eleToken = token												' pass the type token
	eleType = TypenameToken (@eleToken)			' type; next token
	IFZ eleType THEN GOTO eeeSyntax
'
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
		END IF
		GOSUB CheckElement
	ELSE
		GOSUB CheckElement
		SELECT CASE TRUE
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
		END IF
	END IF
	IFZ eleSize THEN PRINT "eleSize = 0": GOTO eeeCompiler
	IFZ eleAlign THEN PRINT "eleAlign = 0": GOTO eeeCompiler
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
	END IF
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
'	PRINT eleCount;; eleName$;; HEX$(eleToken,8);; eleSize;; typeThisAddr;; typeNextAddr;; eleType;; elePtr;; eleStringSize;; eleArrayUBound
	INC eleCount
	token = NextToken ()
	RETURN ($$T_STARTS)
'
' *****  END TYPE  *****  END UNION  *****
'
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
	END IF
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
	IF (typeMaxAlign <= 4) THEN
		typeMaxAlign = 4
		roundSize = 3
	ELSE
		typeMaxAlign = 8
		roundSize = 7
	END IF
	typeNextAddr = (typeNextAddr + roundSize) AND (NOT roundSize)
	typeAlign[typeNumber]	=	typeMaxAlign
	typeSize[typeNumber] = typeNextAddr
	token = NextToken ()
	inUNION = $$FALSE
	inTYPE = $$FALSE
	typeNumber = 0
	uEle = 0
	RETURN ($$T_STARTS)
'
'
' When the end of a UNION ... END UNION block is reached,
' all the components in the UNION need to be fixed up to
' align with the most restrictive component.
'
' *****  FixUnion  *****
'
SUB FixUnion
	inUNION = $$FALSE
	align = 0
	addr = 0
	size = 0
'
	FOR e = eleCountUNION TO eleCount-1
		eName$ = tsymbol$[e]
		eToken = ttoken[e]
		eSize = tsize[e]
		eAddr = taddr[e]
		eType = ttype[e]
'		value = tval[e]
'		ePtr = tptr[e]
		sSize = tss[e]
		aUpper = tub[e]
		tAlign = typeAlign[eType]
		tSize = typeSize[eType]
'		PRINT eName$; eSize; eAddr; eType; sSize; aUpper; tAlign; tSize
		IF (eSize > size) THEN size = eSize
		IF (eAddr > addr) THEN addr = eAddr
	NEXT e
'
	FOR e = eleCountUNION TO eleCount-1
		taddr[e] = addr
	NEXT e
	typeNextAddr = addr + size
END SUB
'
SUB CheckElement
	eleKind = eleToken{$$KIND}
	IF (eleKind != $$KIND_SYMBOLS) THEN
		IF (eleKind != $$KIND_ARRAY_SYMBOLS) THEN PRINT "ccc1": GOTO eeeComponent
	END IF
	eleNumber = eleToken{$$NUMBER}
	eleName$ = tab_sym$[eleNumber]
	IF (eleName${0} != '.') THEN GOTO eeeSyntax		' name must begin with .
	IF eleCount THEN
		i = 0
		DO WHILE (i < eleCount)
			IF (eleName$ = tsymbol$[i]) THEN
				tokenPtr	= dataPtr
				GOTO eeeDupDefinition
			END IF
			INC i
		LOOP
	END IF
END SUB
'
'
' *****  WRITE *****
'
p_write:
	got_executable = $$TRUE
	token = NextToken ()
	IF (token != T_LBRAK) THEN GOTO eeeSyntax				' WRITE [ifile], var
	token = Eval (@result_type)
	IF XERROR THEN EXIT FUNCTION
	IF (token != T_RBRAK) THEN GOTO eeeSyntax
	token = NextToken ()
	IF (token != T_COMMA) THEN GOTO eeeSyntax
'
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
'
' WRITE the variables
'
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
					w$ = "__WriteArray"
'					IF (wtype = $$STRING) THEN GOTO eeeTypeMismatch
				ELSE
					w$ = "__WriteString"
				END IF
				token			= NextToken ()
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 360")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, "", @"### 361")
				Move ($$eax, $$XLONG, wtoken, $$XLONG)	' get file #
				Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, "", @"### 362")
				Code ($$call, $$rel, 0, 0, 0, 0, w$, @"### 363")
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 364")
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
				Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 365")
				Move ($$eax, $$XLONG, ftoken, $$XLONG)	' get file #
				Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, "", @"### 366")
				IF mReg THEN
					Code ($$lea, $$regro, $$eax, mReg, mAddr, $$XLONG, "", @"### 367")
				ELSE
					Code ($$lea, $$regabs, $$eax, 0, mAddr, $$XLONG, m_addr$[wt], @"### 368")
				END IF
				Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, "", @"### 369")
				Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, "", @"### 370")
				Code ($$call, $$rel, 0, 0, 0, 0, "__Write", @"### 371")
				Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 372")
			END IF
		ELSE
			Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 373")
			Move ($$eax, $$XLONG, ftoken, $$XLONG)	' get file #
			Code ($$st, $$roreg, $$eax, $$esp, 0, $$XLONG, "", @"### 374")
			ctype		= wtype
			rreg		= $$FALSE
			creg		= NextToken ()
			Composite ($$GETDATAADDR, ctype, @creg, @offset, @xsize)
			IF XERROR THEN EXIT FUNCTION
			IF toes THEN xx = Topax1 ()
			IFZ creg THEN PRINT "WRITEcomposite": GOTO eeeCompiler
			Code ($$lea, $$regro, $$eax, creg, offset, $$XLONG, "", @"### 375")
			Code ($$st, $$roreg, $$eax, $$esp, 4, $$XLONG, "", @"### 376")
			Code ($$st, $$roimm, xsize, $$esp, 8, $$XLONG, "", @"### 377")
			Code ($$call, $$rel, 0, 0, 0, 0, "__Write", @"### 378")
			Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 379")
		END IF
		a0_type	= 0
		token		= NextToken ()
	LOOP WHILE (token = T_COMMA)
	RETURN (token)
'
'
'
' *****************************************
' *****  LOAD kindBeforeFunc[] ARRAY  *****
' *****************************************
'
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
END SUB
'
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
END SUB
'
SUB StateBeforeFunc
	DIM stateBeforeFunc [255]
	stateBeforeFunc [ T_ALL				AND 0x00FF ] = GOADDRESS (b_all)
	stateBeforeFunc [ T_CFUNCTION	AND 0x00FF ] = GOADDRESS (b_cfunction)
	stateBeforeFunc [ T_DECLARE		AND 0x00FF ] = GOADDRESS (b_declare)
	stateBeforeFunc [ T_END				AND 0x00FF ] = GOADDRESS (b_end)
	stateBeforeFunc [ T_EXPORT		AND 0x00FF ] = GOADDRESS (b_export)
	stateBeforeFunc [ T_EXTERNAL	AND 0x00FF ] = GOADDRESS (b_external)
	stateBeforeFunc [ T_FUNCTION	AND 0x00FF ] = GOADDRESS (b_function)
	stateBeforeFunc [ T_IMPORT		AND 0x00FF ] = GOADDRESS (b_import)
	stateBeforeFunc [ T_INTERNAL	AND 0x00FF ] = GOADDRESS (b_internal)
	stateBeforeFunc [ T_LIBRARY		AND 0x00FF ] = GOADDRESS (b_library)
	stateBeforeFunc [ T_PROGRAM		AND 0x00FF ] = GOADDRESS (b_program)
	stateBeforeFunc [ T_SFUNCTION AND 0x00FF ] = GOADDRESS (b_sfunction)
	stateBeforeFunc [ T_SHARED		AND 0x00FF ] = GOADDRESS (b_shared)
	stateBeforeFunc [ T_TYPE			AND 0x00FF ] = GOADDRESS (b_type)
	stateBeforeFunc [ T_UNION			AND 0x00FF ] = GOADDRESS (b_union)
	stateBeforeFunc [ T_VERSION		AND 0x00FF ] = GOADDRESS (b_version)
END SUB
'
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
'
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
	stateAfterFunc	[	T_NEXT				AND 0x00FF	] = GOADDRESS (p_next)
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
'
'
' ********************
'	*****  ERRORS  *****
' ********************
'
eeeAfterElse:
	XERROR = ERROR_AFTER_ELSE
	EXIT FUNCTION
'
eeeBadCaseAll:
	XERROR = ERROR_BAD_CASE_ALL
	EXIT FUNCTION
eeeBadGosub:
	XERROR = ERROR_BAD_GOSUB
	EXIT FUNCTION
'
eeeBadGoto:
	XERROR = ERROR_BAD_GOTO
	EXIT FUNCTION
'
eeeBadSymbol:
	XERROR = ERROR_BAD_SYMBOL
	EXIT FUNCTION
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION
'
eeeCrossedFunctions:
	XERROR = ERROR_CROSSED_FUNCTIONS
	EXIT FUNCTION
'
eeeDeclare:
	XERROR = ERROR_DECLARE
	EXIT FUNCTION
'
eeeDeclareFuncs:
	XERROR = ERROR_DECLARE_FUNCS_FIRST
	EXIT FUNCTION
'
eeeDupDeclaration:
	XERROR = ERROR_DUP_DECLARATION
	EXIT FUNCTION
'
eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	EXIT FUNCTION
'
eeeDupType:
	XERROR = ERROR_DUP_TYPE
	EXIT FUNCTION
'
eeeElseInCaseAll:
	XERROR = ERROR_ELSE_IN_CASE_ALL
	EXIT FUNCTION
'
eeeEntryFunction:
	XERROR = ERROR_ENTRY_FUNCTION
	EXIT FUNCTION
'
eeeExpectAssignment:
	XERROR = ERROR_EXPECT_ASSIGNMENT
	EXIT FUNCTION
'
eeeExpressionStack:
	XERROR = ERROR_EXPRESSION_STACK
	EXIT FUNCTION
'
eeeInternalExternal:
	XERROR = ERROR_INTERNAL_EXTERNAL
	EXIT FUNCTION
'
eeeKindMismatch:
	XERROR = ERROR_KIND_MISMATCH
	EXIT FUNCTION
'
eeeNeedExcessComma:
	XERROR = ERROR_NEED_EXCESS_COMMA
	EXIT FUNCTION
'
eeeNeedSubscript:
	XERROR = ERROR_NEED_SUBSCRIPT
	EXIT FUNCTION
'
eeeNest:
	nestLevel = 1
	IF nestError THEN RETURN ($$T_STARTS)
	nestError = $$TRUE
	XERROR = ERROR_NEST
	EXIT FUNCTION
'
eeeNodeDataMismatch:
	XERROR = ERROR_NODE_DATA_MISMATCH
	EXIT FUNCTION
'
eeeOutsideFunctions:
	XERROR = ERROR_OUTSIDE_FUNCTIONS
	EXIT FUNCTION
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	EXIT FUNCTION
'
eeeScopeMismatch:
	XERROR = ERROR_SCOPE_MISMATCH
	EXIT FUNCTION
'
eeeSharename:
	XERROR = ERROR_SHARENAME
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
'
eeeTooFewArgs:
	XERROR = ERROR_TOO_FEW_ARGS
	EXIT FUNCTION
'
eeeTooLate:
	XERROR = ERROR_TOO_LATE
	EXIT FUNCTION
'
eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
'
eeeUndeclared:
	XERROR = ERROR_UNDECLARED
	EXIT FUNCTION
'
eeeUndefined:
	XERROR = ERROR_UNDEFINED
	EXIT FUNCTION
'
eeeUnimplemented:
	XERROR = ERROR_UNIMPLEMENTED
	EXIT FUNCTION
'
eeeWithinFunction:
	XERROR = ERROR_WITHIN_FUNCTION
	EXIT FUNCTION
END FUNCTION
'
'
' ################################
' #####  CloneArrayXLONG ()  #####
' ################################
'
FUNCTION  CloneArrayXLONG (dest[], source[])

	IFZ source[] THEN DIM dest[]: RETURN
	upper	= UBOUND (source[])
	DIM dest[upper]
	FOR i = 0 TO upper
		dest[i] = source[i]
	NEXT i
END FUNCTION
'
'
' #####################
' #####  Code ()  #####
' #####################
'
FUNCTION  Code (opcode, mode, dreg, sreg, xreg, dataType, label$, remark$)
	EXTERNAL /xxx/	xpc, i486asm, i486bin
	SHARED ofile
	SHARED	reg86$[],  reg86c$[],  typeSize[],  typeSize$[]
	STATIC 	smallStoreReg[],  op$[],  fptr$[],  iptr$[]
	STATIC XLONG amodeXlate[]	'translate "mode" to "amode"
	STATIC XLONG twidModeXlate[] 'translate modes for bit-twiddle instructions
	STATIC XLONG regcode[]		'3-bit register codes
	STATIC XLONG scalef[]			'2-bit codes for scale factors (in s-i-b byte)
	STATIC GOADDR  op[]
	STATIC SUBADDR  mode[],  modex[]
	STATIC GOADDR eamake[]		'GOADDRs to assemble mod-reg-rm bytes and s-i-b bytes;
														' one per "mode" ($$regreg, $$regr0, etc.)
	STATIC GOADDR eamake4[]		'same as the GOADDRs in eamake[], except addressing modes
														' have an offset of 4 added to them and data-register numbers
														' are incremented (to access the most significant half
														' of a GIANT)
	STATIC OPCODE86 op86[]		'data required to assemble an instruction:
														'1st dimension is "opcode" ($$add, $$adc, etc.)
														'2nd dimension is "amode" ($am_regea, $am_eareg, etc.)
	OPCODE86 op86							'element from op86[] for current instruction
	XLONG	amode								'one of the $am_ constants: addressing-mode
														'category to which "mode" belongs
	XLONG mrm_mode						'"mode" field of mod-reg-rm byte
	XLONG mrm_reg							'"reg" field of mod-reg-rm byte
	XLONG mrm_rm							'"r/m" field of mod-reg-rm byte
'
	$am_regea = 0			'indexes into 2nd dimension of op86[]
	$am_eareg = 1			'each $am_ constant corresponds to one opcode of
	$am_ea = 2				' one instruction.  (most instructions on the 80x86
	$am_rel = 3				' have a different opcode for each addressing mode)
	$am_none = 4
	$am_eaimm = 5
	$am_max = 5
	$modemax = 32
'
'
'
	IFZ op[] THEN GOSUB Init
'
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
	END IF
	SELECT CASE TRUE
		CASE i486bin: GOSUB	EmitBin
		CASE i486asm:	GOSUB	EmitAsm
	END SELECT
	RETURN
'
SUB EmitBin
	revReg = $$FALSE
	twinGiant = $$FALSE
	SELECT CASE dataType
		CASE $$SBYTE
					SELECT CASE opcode
						CASE $$ld:	opcode = $$movsx
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000a": GOTO eeeCompiler
												dreg = dreg - 8		' make byte reg
					END SELECT
		CASE $$UBYTE
					SELECT CASE opcode
						CASE $$ld:	opcode = $$movzx
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000b": GOTO eeeCompiler
												dreg = dreg - 8		' make byte reg
					END SELECT
		CASE $$SSHORT
					SELECT CASE opcode
						CASE $$ld:	opcode = $$movsx
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000c": GOTO eeeCompiler
												dreg = dreg - 4		' make short reg
					END SELECT
		CASE $$USHORT
					SELECT CASE opcode
						CASE $$ld:	opcode = $$movzx
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000d": GOTO eeeCompiler
												dreg = dreg - 4		' make short reg
					END SELECT
		CASE $$GIANT
					SELECT CASE opcode
						CASE $$ld
									IF ((mode = $$regrs) OR (mode = $$regrr)) THEN
										IF ((dreg = sreg) OR (dreg = xreg)) THEN
											IF ((sreg = $$edi) OR (xreg = $$edi)) THEN
												PRINT "couldn't get edi": GOTO eeeCompiler
											END IF
											greg = dreg
											dreg = $$esi				'destination will be edi, not esi
											plus4 = $$TRUE
											GOSUB EmitInstruction		'access second half first
											plus4 = $$FALSE
											dreg = greg
											ducked = $$TRUE
											EXIT SELECT
										END IF
									END IF
									IF (dreg = sreg) THEN
										plus4 = $$TRUE
										GOSUB EmitInstruction
										plus4 = $$FALSE
									ELSE
										twinGiant = $$TRUE
									END IF
						CASE $$st, $$pop
									twinGiant = $$TRUE
						CASE $$push
									plus4 = $$TRUE
									GOSUB EmitInstruction
									plus4 = $$FALSE
					END SELECT
	END SELECT
	GOSUB EmitInstruction
	IF twinGiant THEN
		plus4 = $$TRUE
		GOSUB EmitInstruction
		plus4 = $$FALSE
	END IF
	IF ducked THEN Code ($$mov, $$regreg, dreg+1, $$edi, 0, $$XLONG, "", "### 380")
END SUB

SUB EmitInstruction
	amode = amodeXlate[mode]
	op86 = op86[opcode, amode]
	dataSize = typeSize[dataType]

	GOTO @op86.optype

' ***** "optype" labels: one for each class of opcodes that are assembled the same way *****

BNorm:				'"normal" instructions, if indeed there are such things on the 80x86
								'a "normal" instructions is treated as follows:
								'		the last byte of its opcode is decremented if its operand is byte-sized
								'		prefixed with 0x66 if operand is word-sized
								'		followed by ea, as generated by MakeEa
								'		"reg" field of mod-reg-rm is dreg
	IF plus4
		mrm_reg = regcode[dreg + 1]
	ELSE
		mrm_reg = regcode[dreg]
	END IF
BRegop_entry:
	IF (dataSize = 2) THEN
		UBYTEAT(xpc) = 0x66
		INC xpc
	END IF
	IF (op86.nbytes = 2) THEN
		UBYTEAT(xpc) = op86.byte1
		INC xpc
		opcodebyte = op86.byte2
	ELSE
		opcodebyte = op86.byte1
	END IF
	IF (dataSize = 1) THEN
		UBYTEAT(xpc) = opcodebyte - 1
	ELSE
		UBYTEAT(xpc) = opcodebyte
	END IF
	INC xpc
	GOTO MakeEa

BRegop:				'an instruction with part of its opcode in the "reg" field of the mod-reg-rm
								'identical to a BNorm except for the setting of the "reg" field
	mrm_reg = op86.param
	GOTO BRegop_entry

BWord:				'a word-only instruction (PUSH and POP)
								'identical to BRegop except byte-sized operands are illegal
	mrm_reg = op86.param
	IF (dataSize < 2) THEN GOTO BErr
	GOTO BRegop_entry

BTwid:				'bit-twiddling instructions
								'identical to a BNorm except "xxxreg" addressing modes are changed
								'to just "xxx" and "reg" field is part of opcode and "imm"s
								'are changed to "imm8"
	mode = twidModeXlate[mode]
	mrm_reg = op86.param
	GOTO BRegop_entry

BLea:					'the LEA instruction and any others like it
								'identical to a BNorm except dataSize is ignored
	IF plus4
		mrm_reg = regcode[dreg + 1]
	ELSE
		mrm_reg = regcode[dreg]
	END IF
	IF (op86.nbytes = 2) THEN
		UBYTEAT(xpc) = op86.byte1
		INC xpc
		opcodebyte = op86.byte2
	ELSE
		opcodebyte = op86.byte1
	END IF
	UBYTEAT(xpc) = opcodebyte
	INC xpc
	GOTO MakeEa

BNone:				'instructions with no operands
								'just spit out opcode bytes, don't go to MakeEa, don't do nuffin'
	IF (op86.nbytes = 1) THEN
		UBYTEAT(xpc) = op86.byte1
		INC xpc
	ELSE
		UBYTEAT(xpc) = op86.byte1
		UBYTEAT(xpc, 1) = op86.byte2
		xpc = xpc + 2
	END IF
	EXIT SUB

BRel:					'relative branches
								'instruction consists of opcode byte(s) followed by 32-bit displacement
	IF (op86.nbytes = 1) THEN
		UBYTEAT(xpc) = op86.byte1
		INC xpc
	ELSE
		UBYTEAT(xpc) = op86.byte1
		UBYTEAT(xpc, 1) = op86.byte2
		xpc = xpc + 2
	END IF
	CodeLabelDisp(label$)
	EXIT SUB
'
' instructions with 32-bit immediate operand only (except push imm8)
' instruction consists of opcode byte(s) followed by dreg or label$
'
BImm:
	IFZ label$ THEN
		IF immByte THEN
			IF (opcode = $$push) THEN
				UBYTEAT(xpc) = op86.byte1 OR 2			' push immSBYTE
				INC xpc
				UBYTEAT(xpc) = dreg AND 0x00FF
				INC xpc
				EXIT SUB
			END IF
		END IF
	END IF
'
	IF (op86.nbytes = 1) THEN
		UBYTEAT(xpc) = op86.byte1
		INC xpc
	ELSE
		UBYTEAT(xpc) = op86.byte1
		UBYTEAT(xpc, 1) = op86.byte2
		xpc = xpc + 2
	END IF
	IF label$ THEN
		CodeLabelAbs(label$, 0)
	ELSE
		UBYTEAT(xpc)		= dreg AND 0xFF
		UBYTEAT(xpc, 1)	= (dreg AND 0xFF00) >> 8
		UBYTEAT(xpc, 2)	= (dreg AND 0xFF0000) >> 16
		UBYTEAT(xpc, 3)	= (dreg AND 0xFF000000) >> 24
		xpc = xpc + 4
	END IF
	EXIT SUB
'
' the INT instruction
' special opcode for INT 3; otherwise single-byte immmediate operand
'
BInt:
	IF (dreg = 3) THEN
		UBYTEAT(xpc) = 0xCC
		INC xpc
		EXIT SUB
	ELSE
		UBYTEAT(xpc) = 0xCD
		UBYTEAT(xpc, 1) = dreg
		xpc = xpc + 2
		EXIT SUB
	END IF

BErr:
	PRINT "invalid instruction/addressing-mode combination"
	GOTO eeeCompiler
'
BRetImm:
	UBYTEAT(xpc) = 0xC2					: INC xpc
	UBYTEAT(xpc) = dreg					: INC xpc
	UBYTEAT(xpc) = dreg >> 8		: INC xpc
	EXIT SUB
'
BMovx:				'MOVSX and MOVZX
								'identical to BNorm except:
								'		32-bit operand size is an error (not checked)
								'		no change in opcode for 16-bit operands
	mrm_reg = regcode[dreg]
	IF (op86.nbytes = 2) THEN
		UBYTEAT(xpc) = op86.byte1
		INC xpc
		opcodebyte = op86.byte2
	ELSE
		opcodebyte = op86.byte1
	END IF
	IF (dataSize = 1) THEN
		UBYTEAT(xpc) = opcodebyte - 1
	ELSE
		UBYTEAT(xpc) = opcodebyte
	END IF
	INC xpc
	GOTO MakeEa

BImul:			'the IMUL instruction with regimm addressing mode
						'generates three-operand IMUL instruction with source and
						' destination registers the same
						'only legal dataSizes are 2 and 4
	IF ((dataSize <> 2) AND (dataSize <> 4)) THEN GOTO BErr
	UBYTEAT(xpc) = 0x69
	INC xpc
	mrm_reg = regcode[dreg]
	GOTO MakeEa

BFstsw:			'FSTSW AX
	UBYTEAT(xpc) = 0xDF
	UBYTEAT(xpc, 1) = 0xE0
	xpc = xpc + 2
	EXIT SUB

BFld:				'FLD: 32-bit and 64-bit memory operands only
						'does not check if dataSize is invalid
						'does not check if operand is a register
	mrm_reg = 0
BFst_entry:
BFstp_entry:
	IF (dataSize = 4) THEN
		UBYTEAT(xpc) = 0xD9
	ELSE	'else dataSize is assumed to be 8
		UBYTEAT(xpc) = 0xDD
	END IF
	INC xpc
	GOTO MakeEa

BFild:			'FILD: 16-bit, 32-bit, and 64-bit memory operands only
						'does not check if dataSize is invalid
						'does not check if operand is a register
	SELECT CASE dataSize
		CASE 2
			UBYTEAT(xpc) = 0xDF
			mrm_reg = 0
		CASE 4
			UBYTEAT(xpc) = 0xDB
			mrm_reg = 0
		CASE ELSE 'else dataSize is assumed to be 8
			UBYTEAT(xpc) = 0xDF
			mrm_reg = 5
	END SELECT
	INC xpc
	GOTO MakeEa

BFst:				'FST: 32-bit or 64-bit memory operands only
						'does not check if dataSize is invalid
						'does not check if operand is a register
	mrm_reg = 2
	GOTO BFst_entry

BFist:			'FIST: 16-bit and 32-bit memory operands only
						'does not check if dataSize is invalid
						'does not check if operand is a register
	mrm_reg = 2
	IF (dataSize = 2) THEN
		UBYTEAT(xpc) = 0xDF
	ELSE 'else dataSize is assumed to be 4
		UBYTEAT(xpc) = 0xDB
	END IF
	INC xpc
	GOTO MakeEa

BFistp:			'FISTP: 16-bit, 32-bit, and 64-bit memory operands only
						'does not check if dataSize is invalid
						'does not check if operand is a register
	SELECT CASE dataSize
		CASE 2
			UBYTEAT(xpc) = 0xDF
			mrm_reg = 3
		CASE 4
			UBYTEAT(xpc) = 0xDB
			mrm_reg = 3
		CASE ELSE	'else dataSize is assumed to be 8
			UBYTEAT(xpc) = 0xDF
			mrm_reg = 7
	END SELECT
	INC xpc
	GOTO MakeEa

BFstp:			'FSTP: 32-bit or 64-bit memory operands only
						'does not check if dataSize is invalid
						'does not check if operand is a register
	mrm_reg = 3
	GOTO BFstp_entry

' ***** MakeEa: assembles mod-reg-rm and s-i-b bytes, assuming mrm_reg has already
'								been set.  opcode byte(s) are assumed to already have been written.
'								also writes immediate operand, if any, following ea.

MakeEa:
	mrm_reg = mrm_reg << 3
	IFZ plus4 THEN
		GOTO @eamake[mode]
	ELSE
		GOTO @eamake4[mode]
	END IF
	PRINT "MakeEa: illegal addressing mode": GOTO eeeCompiler

EM_none:
	EXIT SUB

EM_abs:
EM_regabs:
EM_absreg:
	UBYTEAT(xpc) = mrm_reg OR 0b00000101
	INC xpc
	IFZ addr THEN
		CodeLabelAbs(label$, 0)
	ELSE
		UBYTEAT(xpc)		= (addr AND 0xFF)
		UBYTEAT(xpc, 1)	= (addr AND 0xFF00) >> 8
		UBYTEAT(xpc, 2)	= (addr AND 0xFF0000) >> 16
		UBYTEAT(xpc, 3)	= (addr AND 0xFF000000) >> 24
		xpc = xpc + 4
	END IF
	EXIT SUB

EM_rel:
	CodeLabelDisp(label$)
	EXIT SUB

EM_reg:
	UBYTEAT(xpc) = mrm_reg OR 0b11000000 OR regcode[dreg]
	INC xpc
	EXIT SUB

EM_imm:
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		immval = dreg
		GOSUB EmitImm
		EXIT SUB
	END IF
'
'
EM_r0:
EM_regr0:
EM_r0reg:
	SELECT CASE TRUE
		CASE sreg = $$esp:
			UBYTEAT(xpc) = mrm_reg OR 0b100		'have to make a s-i-b for [esp]
			UBYTEAT(xpc, 1) = 0x24
			xpc = xpc + 2
		CASE sreg = $$ebp										'have to make [ebp+0x00] for [ebp]
			UBYTEAT(xpc) = mrm_reg OR 0b01000101
			UBYTEAT(xpc, 1) = 0x00
			xpc = xpc + 2
		CASE ELSE:
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg]
			INC xpc
	END SELECT
	EXIT SUB
'
'
EM_ro:
EM_regro:
EM_roreg:
	IF ((addr >= -128) AND (addr < +127)) THEN shorty = $$TRUE ELSE shorty = $$FALSE
	IF (sreg = $$esp) THEN									'have to make a s-i-b byte for [esp]
		IF shorty THEN
			UBYTEAT(xpc) = mrm_reg OR 0b01000100
		ELSE
			UBYTEAT(xpc) = mrm_reg OR 0b10000100
		END IF
		UBYTEAT(xpc, 1) = 0x24
		xpc = xpc + 2
	ELSE
		IF shorty THEN
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg] OR 0b01000000
		ELSE
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg] OR 0b10000000
		END IF
		INC xpc
	END IF
	UBYTEAT(xpc)	= addr AND 0xFF								: INC xpc
	IF shorty THEN EXIT SUB
	UBYTEAT(xpc)	= (addr AND 0xFF00) >> 8			: INC xpc
	UBYTEAT(xpc)	= (addr AND 0xFF0000) >> 16		: INC xpc
	UBYTEAT(xpc)	= (addr AND 0xFF000000) >> 24	: INC xpc
	EXIT SUB

EM_rr:							'warning: this will generate incorrect code for [ebp+esp] and [esp+ebp]
EM_regrr:
EM_rrreg:
	UBYTEAT(xpc) = mrm_reg OR 0b100
	IF (addr = $$esp) THEN
		SWAP addr, sreg
	END IF
	UBYTEAT(xpc, 1) = (regcode[addr] << 3) OR regcode[sreg]
	xpc = xpc + 2
	EXIT SUB

EM_rs:							'assumes that dataSize is valid: 1, 2, 4, or 8
										'assumes that scaled register is not esp (should be a safe assumption)
EM_regrs:
EM_rsreg:
	IF (sreg = $$ebp) THEN
		UBYTEAT(xpc) = mrm_reg OR 0b01000100
		UBYTEAT(xpc, 1) = scalef[dataSize] OR 0b00000101 OR (regcode[xreg] << 3)
		UBYTEAT(xpc, 2) = 0
		xpc = xpc + 3
		EXIT SUB
	ELSE
		UBYTEAT(xpc) = mrm_reg OR 0b100
		UBYTEAT(xpc, 1) = scalef[dataSize] OR (regcode[xreg] << 3) OR regcode[sreg]
		xpc = xpc + 2
		EXIT SUB
	END IF

EM_regreg:					'ea is source operand
	UBYTEAT(xpc) = 0b11000000 OR mrm_reg OR regcode[sreg]
	INC xpc
	EXIT SUB

EM_regimm:
	UBYTEAT(xpc) = 0b11000000 OR mrm_reg OR regcode[dreg]
	INC xpc
	IF sreg THEN
		immval = sreg
		GOSUB EmitImm
		EXIT SUB
	END IF
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		immval = 0
		GOSUB EmitImm
		EXIT SUB
	END IF
	EXIT SUB
'
' sreg contains "imm"
' addr contains "abs" - else check label$
' what if imm and abs are both labels ???
'
EM_absimm:
	UBYTEAT(xpc) = mrm_reg OR 0b00000101
	INC xpc
	IFZ addr THEN
		CodeLabelAbs(label$, 0)
	ELSE
		UBYTEAT(xpc)		= addr AND 0xFF
		UBYTEAT(xpc, 1)	= (addr AND 0xFF00) >> 8
		UBYTEAT(xpc, 2)	= (addr AND 0xFF0000) >> 16
		UBYTEAT(xpc, 3)	= (addr AND 0xFF000000) >> 24
		xpc = xpc + 4
	END IF
	immval = sreg
	GOSUB EmitImm
	EXIT SUB
'
EM_r0imm:
	SELECT CASE TRUE
		CASE sreg = $$esp:
			UBYTEAT(xpc) = mrm_reg OR 0b100		' have to make a s-i-b for [esp]
			UBYTEAT(xpc, 1) = 0x24
			xpc = xpc + 2
		CASE sreg = $$ebp										' have to make [ebp+0x00] for [ebp]
			UBYTEAT(xpc) = mrm_reg OR 0b01000101
			UBYTEAT(xpc, 1) = 0x00
			xpc = xpc + 2
		CASE ELSE
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg]
			INC xpc
	END SELECT
	IF dreg THEN
		immval = dreg
		GOSUB EmitImm
		EXIT SUB
	END IF
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		immval = 0
		GOSUB EmitImm
		EXIT SUB
	END IF
	EXIT SUB

EM_roimm:													'dreg or label$ contains "imm"
	IF (sreg = $$esp) THEN									'have to make a s-i-b byte for [esp]
		UBYTEAT(xpc) = mrm_reg OR 0b10000100
		UBYTEAT(xpc, 1) = 0x24
		xpc = xpc + 2
	ELSE
		UBYTEAT(xpc) = mrm_reg OR regcode[sreg] OR 0b10000000
		INC xpc
	END IF
	UBYTEAT(xpc)		= addr AND 0xFF
	UBYTEAT(xpc, 1)	= (addr AND 0xFF00) >> 8
	UBYTEAT(xpc, 2)	= (addr AND 0xFF0000) >> 16
	UBYTEAT(xpc, 3)	= (addr AND 0xFF000000) >> 24
	xpc = xpc + 4
	IF dreg THEN
		immval = dreg
		GOSUB EmitImm
		EXIT SUB
	END IF
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		immval = 0
		GOSUB EmitImm
		EXIT SUB
	END IF
	EXIT SUB

EM_rrimm:							'warning: this will generate incorrect code for [ebp+esp] and [esp+ebp]
											'dreg or label$ contains "imm"
	UBYTEAT(xpc) = mrm_reg OR 0b100
	IF (addr = $$esp) THEN
		SWAP addr, sreg
	END IF
	UBYTEAT(xpc, 1) = regcode[addr] OR regcode[sreg]
	xpc = xpc + 2
	IF dreg THEN
		immval = dreg
		GOSUB EmitImm
		EXIT SUB
	END IF
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		immval = 0
		GOSUB EmitImm
		EXIT SUB
	END IF
	EXIT SUB

EM_rsimm:						'assumes that dataSize is valid: 1, 2, 4, or 8
										'assumes that scaled register is not esp (should be a safe assumption)
										'dreg or label$ contains "imm"
	IF (sreg = $$ebp) THEN
		UBYTEAT(xpc) = mrm_reg OR 0b01000100
		UBYTEAT(xpc, 1) = scalef[dataSize] OR 0b00000101 OR (regcode[xreg] << 3)
		UBYTEAT(xpc, 2) = 0
		xpc = xpc + 3
	ELSE
		UBYTEAT(xpc) = mrm_reg OR 0b100
		UBYTEAT(xpc, 1) = scalef[dataSize] OR (regcode[xreg] << 3) OR regcode[sreg]
		xpc = xpc + 2
	END IF
	IF dreg THEN
		immval = dreg
		GOSUB EmitImm
		EXIT SUB
	END IF
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		immval = 0
		GOSUB EmitImm
		EXIT SUB
	END IF
	EXIT SUB

EM_regimm8:			'immediate operand is shift width: always one byte
	UBYTEAT(xpc) = 0b11000000 OR mrm_reg OR regcode[dreg]
	UBYTEAT(xpc, 1) = sreg
	xpc = xpc + 2
	EXIT SUB

EM_absimm8:				'sreg contains shift width
	UBYTEAT(xpc) = mrm_reg OR 0b00000101
	INC xpc
	CodeLabelAbs(label$, 0)
	UBYTEAT(xpc) = sreg
	INC xpc
	EXIT SUB

EM_r0imm8:		'dreg contains shift width
	SELECT CASE TRUE
		CASE sreg = $$esp:
			UBYTEAT(xpc) = mrm_reg OR 0b100		'have to make a s-i-b for [esp]
			UBYTEAT(xpc, 1) = 0x24
			xpc = xpc + 2
		CASE sreg = $$ebp											'have to make [ebp+0x00] for [ebp]
			UBYTEAT(xpc) = mrm_reg OR 0b01000101
			UBYTEAT(xpc, 1) = 0x00
			xpc = xpc + 2
		CASE ELSE
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg]
			INC xpc
	END SELECT
	UBYTEAT(xpc) = dreg
	INC xpc
	EXIT SUB

EM_roimm8:													'dreg contains shift width
	IF (sreg = $$esp) THEN									'have to make a s-i-b byte for [esp]
		UBYTEAT(xpc) = mrm_reg OR 0b10000100
		UBYTEAT(xpc, 1) = 0x24
		xpc = xpc + 2
	ELSE
		UBYTEAT(xpc) = mrm_reg OR regcode[sreg] OR 0b10000000
		INC xpc
	END IF
	UBYTEAT(xpc)		= addr AND 0xFF
	UBYTEAT(xpc, 1)	= (addr AND 0xFF00) >> 8
	UBYTEAT(xpc, 2)	= (addr AND 0xFF0000) >> 16
	UBYTEAT(xpc, 3)	= (addr AND 0xFF000000) >> 24
	UBYTEAT(xpc, 4)	= dreg
	xpc = xpc + 5
	EXIT SUB

EM_rrimm8:							'warning: this will generate incorrect code for [ebp+esp] and [esp+ebp]
											'dreg contains shift width
	UBYTEAT(xpc) = mrm_reg OR 0b100
	IF (addr = $$esp) THEN
		SWAP addr, sreg
	END IF
	UBYTEAT(xpc, 1) = regcode[addr] OR regcode[sreg]
	UBYTEAT(xpc, 2) = dreg
	xpc = xpc + 3
	EXIT SUB

EM_rsimm8:					' assumes that dataSize is valid: 1, 2, 4, or 8
										' assumes that scaled register is not esp (should be a safe assumption)
										' dreg contains shift width
	IF (sreg = $$ebp) THEN
		UBYTEAT(xpc) 		= mrm_reg OR 0b01000100
		UBYTEAT(xpc, 1) = scalef[dataSize] OR 0b00000101 OR (regcode[xreg] << 3)
		UBYTEAT(xpc, 2) = 0
		xpc = xpc + 3
	ELSE
		UBYTEAT(xpc) = mrm_reg OR 0b100
		UBYTEAT(xpc, 1) = scalef[dataSize] OR (regcode[xreg] << 3) OR regcode[sreg]
		xpc = xpc + 2
	END IF
	UBYTEAT(xpc) = dreg
	INC xpc
	EXIT SUB

EM4_none:
EM4_rel:
EM4_imm:
EM4_abs:
EM4_r0:
EM4_rr:
EM4_rs:
EM4_absimm:
EM4_r0imm:
EM4_roimm:
EM4_rrimm:
EM4_rsimm:
	GOTO BErr
'
'
EM4_reg:
	UBYTEAT(xpc) = mrm_reg OR 0b11000000 OR regcode[dreg+1]
	INC xpc
	EXIT SUB
'
'
EM4_regabs:
EM4_absreg:
	UBYTEAT(xpc) = mrm_reg OR 0b00000101
	INC xpc
	IFZ addr THEN PRINT "Max lies": GOTO eeeCompiler
	addr = addr + 4
	UBYTEAT(xpc)		= addr AND 0xFF
	UBYTEAT(xpc, 1)	= (addr AND 0xFF00) >> 8
	UBYTEAT(xpc, 2)	= (addr AND 0xFF0000) >> 16
	UBYTEAT(xpc, 3)	= (addr AND 0xFF000000) >> 24
	xpc = xpc + 4
	EXIT SUB

EM4_regr0:
EM4_r0reg:
	addr = 0
	'fall through

EM4_ro:
EM4_regro:
EM4_roreg:
	addr4 = addr + 4
	shorty = $$FALSE
	IF ((addr4 >= -128) AND (addr4 < +127)) THEN shorty = $$TRUE
	IF (sreg = $$esp) THEN									'have to make a s-i-b byte for [esp]
		IF shorty THEN
			UBYTEAT(xpc) = mrm_reg OR 0b01000100
		ELSE
			UBYTEAT(xpc) = mrm_reg OR 0b10000100
		END IF
		UBYTEAT(xpc, 1) = 0x24
		xpc = xpc + 2
	ELSE
		IF shorty THEN
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg] OR 0b01000000
		ELSE
			UBYTEAT(xpc) = mrm_reg OR regcode[sreg] OR 0b10000000
		END IF
		INC xpc
	END IF
	UBYTEAT(xpc)		= addr4 AND 0xFF							: INC xpc
	IF shorty THEN EXIT SUB
	UBYTEAT(xpc)	= (addr4 AND 0xFF00) >> 8				: INC xpc
	UBYTEAT(xpc)	= (addr4 AND 0xFF0000) >> 16		: INC xpc
	UBYTEAT(xpc)	= (addr4 AND 0xFF000000) >> 24	: INC xpc
	EXIT SUB
'
'
EM4_regrr:						'warning: this will generate incorrect code for [ebp+esp] and [esp+ebp]
EM4_rrreg:
	UBYTEAT(xpc) = mrm_reg OR 0b01000100
	IF (addr = $$esp) THEN
		SWAP addr, sreg
	END IF
	UBYTEAT(xpc, 1) = (regcode[addr] << 3) OR regcode[sreg]
	UBYTEAT(xpc, 2) = 4
	xpc = xpc + 3
	EXIT SUB

										'assumes that dataSize is valid: 1, 2, 4, or 8
										'assumes that scaled register is not esp (should be a safe assumption)
EM4_regrs:
EM4_rsreg:
	UBYTEAT(xpc) = mrm_reg OR 0b01000100
	UBYTEAT(xpc, 1) = scalef[dataSize] OR regcode[sreg] OR (regcode[xreg] << 3)
	UBYTEAT(xpc, 2) = 4
	xpc = xpc + 3
	EXIT SUB

EM4_regreg:					'ea is source operand
	UBYTEAT(xpc) = 0b11000000 OR mrm_reg OR regcode[sreg + 1]
	INC xpc
	EXIT SUB

EM4_regimm:
	UBYTEAT(xpc) = 0b11000000 OR mrm_reg OR regcode[dreg + 1]
	INC xpc
	IF label$ THEN
		CodeLabelAbs(label$, 0)
		EXIT SUB
	ELSE
		UBYTEAT(xpc)		= sreg AND 0xFF
		UBYTEAT(xpc, 1)	= (sreg AND 0xFF00) >> 8
		UBYTEAT(xpc, 2)	= (sreg AND 0xFF0000) >> 16
		UBYTEAT(xpc, 3)	= (sreg AND 0xFF000000) >> 24
		xpc = xpc + 4
		EXIT SUB
	END IF
	EXIT SUB
END SUB
'
'
'
SUB EmitImm			'immval = number to emit
								'generates 1, 2, or 4 bytes, depending on dataSize
								'does not check if dataSize is valid
	SELECT CASE dataSize
		CASE 1:		UBYTEAT(xpc)		= immval AND 0xFF
							INC xpc
		CASE 2:		UBYTEAT(xpc)		= immval AND 0xFF
							UBYTEAT(xpc, 1)	= (immval AND 0xFF00) >> 8
							xpc = xpc + 2
		CASE 4:		UBYTEAT(xpc)		= immval AND 0xFF
							UBYTEAT(xpc, 1)	= (immval AND 0xFF00) >> 8
							UBYTEAT(xpc, 2)	= (immval AND 0xFF0000) >> 16
							UBYTEAT(xpc, 3)	= (immval AND 0xFF000000) >> 24
							xpc = xpc + 4
	END SELECT
END SUB
'
SUB EmitAsm
'	IF (opcode = $$lea) THEN
'		PRINT Deparse$ (">>>")
'	 dataType = $$XLONG
'	END IF
	op$ = op$[opcode]
	ptrType = dataType
	IF (dataType >= $$SCOMPLEX) THEN ptrType = $$XLONG
	IF (op${1} = 'f') THEN
'		ptr$ = fptr$[ptrType]					' spasm
		ptr$ = ""											' gas ?
	ELSE
'		ptr$ = iptr$[ptrType]					' spasm
		ptr$ = ""											' gas ?
	END IF
	revReg = $$FALSE
	twinGiant = $$FALSE
	SELECT CASE dataType
		CASE $$SBYTE
					SELECT CASE opcode
						CASE $$ld:	op$ = "	movsbl	"			' gas
'						CASE $$ld:	op$ = "	movsx	"				' spasm
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000a": GOTO eeeCompiler
												op$ = "	movb	"				' gas
												dreg = dreg - 8				' make byte reg
					END SELECT
		CASE $$UBYTE
					SELECT CASE opcode
						CASE $$ld:	op$ = "	movzbl	"			' gas
'						CASE $$ld:	op$ = "	movzx	"				' spasm
						CASE $$st:	IFZ smallStoreReg[dreg] THEN PRINT "code000b": GOTO eeeCompiler
												op$ = "	movb	"				' gas
												dreg = dreg - 8				' make byte reg
					END SELECT
		CASE $$SSHORT
					SELECT CASE opcode
'						CASE $$ld			:	op$ = "	movsx	"			' spasm
						CASE $$ld			:	op$ = "	movswl	"		' gas
						CASE $$st			:	IFZ smallStoreReg[dreg] THEN PRINT "code000c": GOTO eeeCompiler
														op$ = "	movw	"			' gas
														dreg = dreg - 4			' make short reg
						CASE $$fild		:	op$ = "	fildw	"			' gas
						CASE $$fist		:	op$ = "	fistw	"			' gas
						CASE $$fistp	:	op$ = "	fistpw	"		' gas
					END SELECT
		CASE $$USHORT
					SELECT CASE opcode
						CASE $$ld			:	op$ = "	movzwl	"		' gas
'						CASE $$ld			:	op$ = "	movzx	"			' spasm
						CASE $$st			:	IFZ smallStoreReg[dreg] THEN PRINT "code000d": GOTO eeeCompiler
														op$ = "	movw	"			' gas
														dreg = dreg - 4			' make short reg
						CASE $$fild		:	op$ = "	fildw	"			' gas
						CASE $$fist		:	op$ = "	fistw	"			' gas
						CASE $$fistp	:	op$ = "	fistpw	"		' gas
					END SELECT
		CASE $$SLONG, $$ULONG, $$XLONG							' new to gas
					SELECT CASE opcode
						CASE $$fild		:	op$ = "	fildl	"			' gas
						CASE $$fist		:	op$ = "	fistl	"			' gas
						CASE $$fistp	:	op$ = "	fistpl	"		' gas
					END SELECT
		CASE $$GIANT
					SELECT CASE opcode
						CASE $$ld
									IF ((mode = $$regrs) OR (mode = $$regrr)) THEN
										IF ((dreg = sreg) OR (dreg = xreg)) THEN
											IF ((sreg = $$edi) OR (xreg = $$edi)) THEN
												PRINT "80x86 atrosity"
											END IF
											greg = dreg
											dreg = $$esi
											GOSUB @modex[omode]		' by accessing second half 1st
'											PRINT [ofile], (op$ + oper$)
											EmitAsm (op$ + oper$)
											dreg = greg
											ducked = $$TRUE
											EXIT SELECT
										END IF
									END IF
									IF (dreg = sreg) THEN
										GOSUB @modex[omode]
'										PRINT [ofile], (op$ + oper$)
										EmitAsm (op$ + oper$)
									ELSE
										twinGiant = $$TRUE
									END IF
						CASE $$st, $$pop
									twinGiant = $$TRUE
						CASE $$push
									GOSUB @modex[omode]
'									PRINT [ofile], (op$ + oper$)
									EmitAsm (op$ + oper$)
						CASE $$fild		:	op$ = "	fildll	"		' gas
						CASE $$fist		:	op$ = "	fistll	"		' gas
						CASE $$fistp	:	op$ = "	fistpll	"		' gas
					END SELECT
		CASE $$SINGLE																' new to gas
					SELECT CASE opcode
						CASE $$fld		:	op$ = "	flds	"			' gas
						CASE $$fst		:	op$ = "	fsts	"			' gas
						CASE $$fstp		:	op$ = "	fstps	"			' gas
					END SELECT
		CASE $$DOUBLE																' new to gas
					SELECT CASE opcode
						CASE $$fld		:	op$ = "	fldl	"			' gas
						CASE $$fst		:	op$ = "	fstl	"			' gas
						CASE $$fstp		:	op$ = "	fstpl	"			' gas
					END SELECT
	END SELECT
	GOSUB @mode[mode]
	IF remark$ THEN
		IFZ oper$ THEN
'			PRINT [ofile], (op$ + remark$)
			EmitAsm (op$ + "\t\t" + remark$)
		ELSE
'			PRINT [ofile], (op$ + oper$ + "	" + remark$)
			EmitAsm (op$ + oper$ + "\t\t" + remark$)
		END IF
	ELSE
		PRINT [ofile], (op$ + oper$)
	END IF
	IF twinGiant THEN
		GOSUB @modex[omode]
'		PRINT [ofile], (op$ + oper$)
		EmitAsm (op$ + oper$)
	END IF
	IF ducked THEN Code ($$mov, $$regreg, dreg+1, $$edi, 0, $$XLONG, "", "### 381")
END SUB
'
SUB None
	oper$ = ""																					' spasm and gas
END SUB
'
SUB Rel
	oper$ = label$																			' spasm and gas ?
END SUB
'
SUB Imm
	IF label$ THEN
'		oper$ = label$																		' spasm
		oper$ = "$" + label$															' gas
	ELSE
'		oper$ = STRING (dreg)															' spasm
		oper$ = "$" + STRING$(dreg)												' gas
	END IF
END SUB
'
SUB Reg
	IF ((opcode == $$call) OR (opcode == $$jmp)) THEN
		oper$ = "*" + reg86$[dreg]												' gas ?
	ELSE
		oper$ = reg86$[dreg]															' spasm and gas ?
	END IF
END SUB
'
SUB Abso
'	oper$ = ptr$ + "[" + label$ + "]"										' spasm
	oper$ = ptr$ + label$																' gas ?
END SUB
'
SUB R0
'	oper$ = ptr$ + "[" + reg86$[sreg] + "]"							' spasm
	oper$ = ptr$ + "(" + reg86$[sreg] + ")"							' gas ?
END SUB
'
SUB Ro
'	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]"		' spasm
	oper$ = ptr$ + STRING$ (addr) + "(" + reg86$[sreg] + ")"		' gas ?
END SUB
'
SUB Rr
'	oper$ = ptr$ + "[" + reg86$[sreg] + " + " + reg86$[xreg] + "]"		' spasm
	oper$ = ptr$ + "(" + reg86c$[sreg] + reg86$[xreg] + ",1)"					' gas ?
END SUB
'
SUB Rs
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]"	' spasm
	oper$ = ptr$ + "(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")"						' gas ?
END SUB
'
SUB RegReg
'	oper$ = reg86c$[dreg] + reg86$[sreg]												' spasm
	oper$ = reg86c$[sreg] + reg86$[dreg]												' gas
END SUB
'
SUB RegImm
	IF label$ THEN
'		oper$ = reg86c$[dreg] + label$														' spasm
		oper$ = "$" + label$ + "," + reg86$[dreg]									' gas
	ELSE
'		oper$ = reg86c$[dreg] + STRING$ (sreg)										' spasm
		oper$ = "$" + STRING$(sreg) + "," + reg86$[dreg]					' gas ?
	END IF
END SUB
'
SUB RegAbs
'	oper$ = reg86c$[dreg] + ptr$ + "[" + label$ + "]"						' spasm
	oper$ = label$ + "," + ptr$ + reg86$[dreg]									' gas ?
END SUB
'
SUB RegR0
'	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + "]"			' spasm
	oper$ = ptr$ + "(" + reg86$[sreg] + ")," + reg86$[dreg]			' gas ?
END SUB
'
SUB RegRo
'	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]"				' spasm
	oper$ = ptr$ + STRING$(addr) + "(" + reg86$[sreg] + ")," +  reg86$[dreg]				' gas ?
END SUB
'
SUB RegRr
'	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]"		' spasm
	oper$ = ptr$ + "(" + reg86c$[sreg] + reg86$[xreg] + ",1)," + reg86$[dreg]			' gas ?
END SUB
'
SUB RegRs
'	oper$ = reg86c$[dreg] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]"		' spasm
	oper$ = ptr$ + "(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")," + reg86$[dreg]							' gas ?
END SUB
'
SUB AbsReg
'	oper$ = ptr$ + "[" + label$ + "]," + reg86$[dreg]																' spasm
	oper$ = reg86c$[dreg] + ptr$ + label$																						' gas ?
END SUB
'
SUB R0Reg
'	oper$ = ptr$ + "[" + reg86$[sreg] + "]," + reg86$[dreg]													' spasm
	oper$ = reg86c$[dreg] + ptr$ + "(" + reg86$[sreg] + ")"													' gas ?
END SUB
'
SUB RoReg
'	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$(addr) + "]," + reg86$[dreg]					' spasm
	oper$ = reg86c$[dreg] + ptr$ + STRING$(addr) + "(" + reg86$[sreg] + ")"					' gas ?
END SUB
'
SUB RrReg
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]," + reg86$[dreg]		' spasm
	oper$ = reg86c$[dreg] + ptr$ + "(" + reg86c$[sreg] + reg86$[xreg] + ",1)"				' gas ?
END SUB
'
SUB RsReg
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]," + reg86$[dreg]		' spasm
	oper$ = reg86c$[dreg] + ptr$ + "(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")"							' gas ?
END SUB
'
SUB AbsImm																								' what if "abs" and "imm" are labels ???
	IF label$ THEN
'		oper$ = ptr$ + "[" + label$ + "]," + STRING (sreg)														' spasm
		oper$ = "$" + STRING$(sreg) + "," + ptr$ + label$															' gas ?
	ELSE
'		oper$ = ptr$ + "[" + label$ + "]," + STRING (sreg)														' spasm
		oper$ = "$" + STRING$(sreg) + "," + ptr$ + label$															' gas ?
	END IF
END SUB
'
SUB R0Imm
	IF label$ THEN
'		oper$ = ptr$ + "[" + reg86$[sreg] + "]," + label$															' spasm
		oper$ = "$" + label$ + "," + ptr$ + "(" + reg86$[sreg] + ")"									' gas ?
	ELSE
'		oper$ = ptr$ + "[" + reg86$[sreg] + "]," + STRING (dreg)											' spasm
		oper$ = "$" + STRING$(dreg) + "," + ptr$ + "(" + reg86$[sreg] + ")"						' gas ?
	END IF
END SUB
'
SUB RoImm
	IF label$ THEN
'		oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]," + label$											' spasm
		oper$ = "$" + label$ + "," + ptr$ + STRING$ (addr) + "(" + reg86$[sreg] + ")"						' gas ?
	ELSE
'		oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addr) + "]," + STRING (dreg)								' spasm
		oper$ = "$" + STRING$(dreg) + "," + ptr$ + STRING$(addr) + "(" + reg86$[sreg] + ")"			' gas ?
	END IF
END SUB
'
SUB RrImm
	IF label$ THEN
'		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]," + label$									' spasm
		oper$ = "$" + label$ + "," + ptr$ + "(" + reg86c$[sreg] + reg86$[xreg] + ",1)"					' gas ?
	ELSE
'		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "]," + STRING (dreg)						' spasm
		oper$ = "$" + STRING$(dreg) + "," + ptr$ + "(" + reg86c$[sreg] + reg86$[xreg] + ",1)"		' gas ?
	END IF
END SUB
'
SUB RsImm
	IF label$ THEN
'		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]," + label$					' spasm
		oper$ = "$" + label$ + "," + ptr$ + "(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")"					' gas ?
	ELSE
'		oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "]," + STRING (dreg)		' spasm
		oper$ = "$" + STRING$(dreg) + "," + ptr$ + "(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")"	' gas ?
	END IF
END SUB
'
'
'
SUB XNone
	GOTO eeeCompiler
END SUB
'
SUB XRel
	GOTO eeeCompiler
END SUB
'
SUB XImm
	GOTO eeeCompiler
END SUB
'
SUB XReg
	oper$ = reg86$[dreg+1]																								' spasm and gas ?
END SUB
'
SUB XAbso
'	oper$ = ptr$ + "[" + label$ + "+4]"																		' spasm
	oper$ = ptr$ + label$ + "+4"																					' gas ?
END SUB
'
SUB XR0
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+4]"															' spasm
	oper$ = ptr$ + "4(" + reg86$[sreg]																		' gas ?
END SUB
'
SUB XRo
'	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addrx) + "]"							' spasm
	oper$ = ptr$ + STRING$(addrx) + "(" + reg86$[sreg] + ")"							' gas ?
END SUB
'
SUB XRr
'	oper$ = ptr$ + "[" + reg86$[sreg] + " + " + reg86$[xreg] + "+4]"			' spasm
	oper$ = ptr$ + "(" + reg86c$[sreg] + + reg86c$[xreg] + "+4]"					' gas ?
END SUB
'
SUB XRs
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "+4]"		' spasm
	oper$ = ptr$ + "4(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")"							' gas ?
END SUB
'
SUB XRegReg
'	oper$ = reg86c$[dregx] + reg86$[sregx]																' spasm
	oper$ = reg86c$[sregx] + reg86$[dregx]																' gas ?
END SUB
'
SUB XRegImm
'	oper$ = reg86c$[dregx] + "0"																					' spasm
	oper$ = "$0," + reg86$[dregx]																					' gas ?
END SUB
'
SUB XRegAbs
'	oper$ = reg86c$[dregx] + ptr$ + "[" + label$ + "+4]"									' spasm
	oper$ = ptr$ + label$ + "+4," + reg86$[dregx]													' gas ?
END SUB
'
SUB XRegR0
'	oper$ = reg86c$[dregx] + ptr$ + "[" + reg86$[sreg] + "+4]"						' spasm
	oper$ = ptr$ + "4(" + reg86$[sreg] + ")," + reg86$[dregx] 						' gas ?
END SUB
'
SUB XRegRo
'	oper$ = reg86c$[dregx] + ptr$ + "[" + reg86$[sreg] + SIGNED$ (addrx) + "]"					' spasm
	oper$ = ptr$ + STRING$(addrx) + "(" + reg86$[sreg] + ")," + reg86$[dregx]						' gas ?
END SUB
'
SUB XRegRr
'	oper$ = reg86c$[dreg+1] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "+4]"		' spasm
	oper$ = ptr$ + "4(" + reg86c$[sreg] + reg86$[xreg] + ")," + reg86$[dreg+1]					' gas ?
END SUB
'
SUB XRegRs
'	oper$ = reg86c$[dreg+1] + ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "+4]"		' spasm
	oper$ = ptr$ + "4(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")," + reg86$[dreg+1]	 						' gas ?
END SUB
'
SUB XAbsReg
'	oper$ = ptr$ + "[" + label$ + "+4]," + reg86$[dregx]															' spasm
	oper$ = reg86c$[dregx] + ptr$ + label$ + "+4"																			' gas ?
END SUB
'
SUB XR0Reg
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+4]," + reg86$[dregx]												' spasm
	oper$ = reg86c$[dregx] + ptr$ + "4(" + reg86$[sreg] + ")"													' gas ?
END SUB
'
SUB XRoReg
'	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$(addrx) + "]," + reg86$[dregx]					' spasm
	oper$ = reg86c$[dregx] + ptr$ + STRING$(addrx) + "(" + reg86$[sreg] + ")"					' gas ?
END SUB
'
SUB XRrReg
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "+4]," + reg86$[dregx]		' spasm
	oper$ = reg86c$[dregx] + ptr$ + "4(" + reg86c$[sreg] + reg86$[xreg] + ")"					' gas ?
END SUB
'
SUB XRsReg
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[addr] + "*" + typeSize$[dataType] + "+4]," + reg86$[dreg+1]		' spasm
	oper$ = reg86c$[dreg+1] + ptr$ + "4(" + reg86c$[sreg] + reg86c$[addr] + typeSize$[dataType] + ")"								' gas ?
END SUB
'
SUB XAbsImm
'	oper$ = ptr$ + "[" + label$ + "+4],0"																	' spasm
	oper$ = "$0," + ptr$ + label$ + "+4"																	' gas ?
END SUB
'
SUB XR0Imm
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+4],0"														' spasm
	oper$ = "$0," + ptr$ + "4(" + reg86$[sreg] + ")"											' gas ?
END SUB
'
SUB XRoImm
'	oper$ = ptr$ + "[" + reg86$[sreg] + SIGNED$ (addrx) + "],0"						' spasm
	oper$ = "$0," + ptr$ + STRING$(addrx) + "(" + reg86$[sreg] + ")"			' gas ?
END SUB
'
SUB XRrImm
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "+4],0"			' spasm
	oper$ = "$0," + ptr$ + "4(" + reg86c$[sreg] + reg86$[xreg] + ",1)"		' gas ?
END SUB
'
SUB XRsImm
'	oper$ = ptr$ + "[" + reg86$[sreg] + "+" + reg86$[xreg] + "*" + typeSize$[dataType] + "+4],0"		' spasm
	oper$ = "$0," + ptr$ + "4(" + reg86c$[sreg] + reg86c$[xreg] + typeSize$[dataType] + ")"					' gas ?
END SUB

'
'
' *******************************
' *****  Initialize Arrays  *****
' *******************************
'
SUB Init
	DIM op[255],		op$[255]
	DIM mode[31],		modex[31]
	DIM iptr$[31],	fptr$[31]
	DIM smallStoreReg[31]
	DIM amodeXlate[$modemax], twidModeXlate[$modemax]
	DIM regcode[31]
	DIM eamake[31], eamake4[31]
	DIM scalef[8]
	DIM op86[$$zlast, $am_max]
'
	amodeXlate[$$none] = $am_none
	amodeXlate[$$rel] = $am_rel
	amodeXlate[$$imm] = $am_rel
	amodeXlate[$$reg] = $am_ea
	amodeXlate[$$abs] = $am_ea
	amodeXlate[$$r0] = $am_ea
	amodeXlate[$$ro] = $am_ea
	amodeXlate[$$rr] = $am_ea
	amodeXlate[$$rs] = $am_ea
	amodeXlate[$$regreg] = $am_regea
	amodeXlate[$$regimm] = $am_eaimm
	amodeXlate[$$regabs] = $am_regea
	amodeXlate[$$regr0] = $am_regea
	amodeXlate[$$regro] = $am_regea
	amodeXlate[$$regrr] = $am_regea
	amodeXlate[$$regrs] = $am_regea
	amodeXlate[$$absreg] = $am_eareg
	amodeXlate[$$r0reg] = $am_eareg
	amodeXlate[$$roreg] = $am_eareg
	amodeXlate[$$rrreg] = $am_eareg
	amodeXlate[$$rsreg] = $am_eareg
	amodeXlate[$$absimm] = $am_eaimm
	amodeXlate[$$r0imm] = $am_eaimm
	amodeXlate[$$roimm] = $am_eaimm
	amodeXlate[$$rrimm] = $am_eaimm
	amodeXlate[$$rsimm] = $am_eaimm
'
	twidModeXlate[$$none] = $$none
	twidModeXlate[$$rel] = $$rel
	twidModeXlate[$$imm] = $$imm
	twidModeXlate[$$reg] = $$reg
	twidModeXlate[$$abs] = $$abs
	twidModeXlate[$$r0] = $$r0
	twidModeXlate[$$ro] = $$ro
	twidModeXlate[$$rr] = $$rr
	twidModeXlate[$$rs] = $$rs
	twidModeXlate[$$regreg] = $$reg
	twidModeXlate[$$regimm] = $$regimm8
	twidModeXlate[$$regabs] = $$regabs
	twidModeXlate[$$regr0] = $$regr0
	twidModeXlate[$$regro] = $$regro
	twidModeXlate[$$regrr] = $$regrr
	twidModeXlate[$$regrs] = $$regrs
	twidModeXlate[$$absreg] = $$reg
	twidModeXlate[$$r0reg] = $$reg
	twidModeXlate[$$roreg] = $$reg
	twidModeXlate[$$rrreg] = $$reg
	twidModeXlate[$$rsreg] = $$reg
	twidModeXlate[$$absimm] = $$absimm8
	twidModeXlate[$$r0imm] = $$r0imm8
	twidModeXlate[$$roimm] = $$roimm8
	twidModeXlate[$$rrimm] = $$rrimm8
	twidModeXlate[$$rsimm] = $$rsimm8
'
	eamake[$$none] = GOADDRESS(EM_none)
	eamake[$$abs] = GOADDRESS(EM_abs)
	eamake[$$rel] = GOADDRESS(EM_rel)
	eamake[$$reg] = GOADDRESS(EM_reg)
	eamake[$$imm] = GOADDRESS(EM_imm)
	eamake[$$r0] = GOADDRESS(EM_r0)
	eamake[$$ro] = GOADDRESS(EM_ro)
	eamake[$$rr] = GOADDRESS(EM_rr)
	eamake[$$rs] = GOADDRESS(EM_rs)
	eamake[$$regreg] = GOADDRESS(EM_regreg)
	eamake[$$regimm] = GOADDRESS(EM_regimm)
	eamake[$$regabs] = GOADDRESS(EM_regabs)
	eamake[$$regr0] = GOADDRESS(EM_regr0)
	eamake[$$regro] = GOADDRESS(EM_regro)
	eamake[$$regrr] = GOADDRESS(EM_regrr)
	eamake[$$regrs] = GOADDRESS(EM_regrs)
	eamake[$$absreg] = GOADDRESS(EM_absreg)
	eamake[$$r0reg] = GOADDRESS(EM_r0reg)
	eamake[$$roreg] = GOADDRESS(EM_roreg)
	eamake[$$rrreg] = GOADDRESS(EM_rrreg)
	eamake[$$rsreg] = GOADDRESS(EM_rsreg)
	eamake[$$absimm] = GOADDRESS(EM_absimm)
	eamake[$$r0imm] = GOADDRESS(EM_r0imm)
	eamake[$$roimm] = GOADDRESS(EM_roimm)
	eamake[$$rrimm] = GOADDRESS(EM_rrimm)
	eamake[$$rsimm] = GOADDRESS(EM_rsimm)
	eamake[$$regimm8] = GOADDRESS(EM_regimm8)
	eamake[$$absimm8] = GOADDRESS(EM_absimm8)
	eamake[$$r0imm8] = GOADDRESS(EM_r0imm8)
	eamake[$$roimm8] = GOADDRESS(EM_roimm8)
	eamake[$$rrimm8] = GOADDRESS(EM_rrimm8)
	eamake[$$rsimm8] = GOADDRESS(EM_rsimm8)
'
	eamake4[$$none] = GOADDRESS(EM4_none)
	eamake4[$$abs] = GOADDRESS(EM4_abs)
	eamake4[$$rel] = GOADDRESS(EM4_rel)
	eamake4[$$reg] = GOADDRESS(EM4_reg)
	eamake4[$$imm] = GOADDRESS(EM4_imm)
	eamake4[$$r0] = GOADDRESS(EM4_r0)
	eamake4[$$ro] = GOADDRESS(EM4_ro)
	eamake4[$$rr] = GOADDRESS(EM4_rr)
	eamake4[$$rs] = GOADDRESS(EM4_rs)
	eamake4[$$regreg] = GOADDRESS(EM4_regreg)
	eamake4[$$regimm] = GOADDRESS(EM4_regimm)
	eamake4[$$regabs] = GOADDRESS(EM4_regabs)
	eamake4[$$regr0] = GOADDRESS(EM4_regr0)
	eamake4[$$regro] = GOADDRESS(EM4_regro)
	eamake4[$$regrr] = GOADDRESS(EM4_regrr)
	eamake4[$$regrs] = GOADDRESS(EM4_regrs)
	eamake4[$$absreg] = GOADDRESS(EM4_absreg)
	eamake4[$$r0reg] = GOADDRESS(EM4_r0reg)
	eamake4[$$roreg] = GOADDRESS(EM4_roreg)
	eamake4[$$rrreg] = GOADDRESS(EM4_rrreg)
	eamake4[$$rsreg] = GOADDRESS(EM4_rsreg)
	eamake4[$$absimm] = GOADDRESS(EM4_absimm)
	eamake4[$$r0imm] = GOADDRESS(EM4_r0imm)
	eamake4[$$roimm] = GOADDRESS(EM4_roimm)
	eamake4[$$rrimm] = GOADDRESS(EM4_rrimm)
	eamake4[$$rsimm] = GOADDRESS(EM4_rsimm)
'
	regcode[ 1] = 4		'esp
	regcode[ 2] = 0		'al
	regcode[ 3] = 2		'dl
	regcode[ 4] = 3		'bl
	regcode[ 5] = 1		'cl
	regcode[ 6] = 0		'ax
	regcode[ 7] = 2		'dx
	regcode[ 8] = 3		'bx
	regcode[ 9] = 1		'cx
	regcode[10] = 0		'eax
	regcode[11] = 2		'edx
	regcode[12] = 3		'ebx
	regcode[13] = 1		'ecx
	regcode[26] = 6		'esi
	regcode[27] = 7		'edi
	regcode[28] = 1		'ecx
	regcode[29] = 2		'edx
	regcode[31] = 5		'ebp
'
	scalef[1] = 0
	scalef[2] = 1 << 6
	scalef[3] = 1 << 6		' bogus value: should never be accessed
	scalef[4] = 2 << 6
	scalef[5] = 1 << 6		' bogus value: should never be accessed
	scalef[6] = 1 << 6		' bogus value: should never be accessed
	scalef[7] = 1 << 6		' bogus value: should never be accessed
	scalef[8] = 3 << 6
'
' the following are the spasm opcode strings - followed by Linux aka gas opcode strings
'
'	op$[$$nop]					= "	nop	"
'	op$[$$adc]					= "	adc	"
'	op$[$$add]					= "	add	"
'	op$[$$and]					= "	and	"
'	op$[$$bsf]					= "	bsf	"
'	op$[$$bsr]					= "	bsr	"
'	op$[$$bt]						= "	bt	"
'	op$[$$btc]					= "	btc	"
'	op$[$$btr]					= "	btr	"
'	op$[$$bts]					= "	bts	"
'	op$[$$call]					= "	call	"
'	op$[$$cbw]					= "	cbw	"
'	op$[$$cdq]					= "	cdq	"
'	op$[$$clc]					= "	clc	"
'	op$[$$cld]					= "	cld	"
'	op$[$$cmc]					= "	cmc	"
'	op$[$$cmp]					= "	cmp	"
'	op$[$$cmpsb]				= "	cmpsb	"
'	op$[$$cmpsw]				= "	cmpsw	"
'	op$[$$cmpsd]				= "	cmpsd	"
'	op$[$$cwd]					= "	cwd	"
'	op$[$$cwde]					= "	cwde	"
'	op$[$$dec]					= "	dec	"
'	op$[$$div]					= "	div	"
'	op$[$$f2xm1]				= "	f2xm1	"
'	op$[$$fabs]					= "	fabs	"
'	op$[$$fadd]					= "	fadd	"
'	op$[$$faddp]				= "	faddp	"
'	op$[$$fchs]					= "	fchs	"
'	op$[$$fclex]				= "	fclex	"
'	op$[$$fnclex]				= "	fnclex	"
'	op$[$$fcom]					= "	fcom	"
'	op$[$$fcomp]				= "	fcomp	"
'	op$[$$fcompp]				= "	fcompp	"
'	op$[$$fcos]					= "	fcos	"
'	op$[$$fdecstp]			= "	fdecstp	"
'	op$[$$fdiv]					= "	fdiv	"
'	op$[$$fdivp]				= "	fdivp	"
'	op$[$$fdivr]				= "	fdivr	"
'	op$[$$fdivrp]				= "	fdivrp	"
'	op$[$$fild]					= "	fild	"
'	op$[$$fincstp]			= "	fincstp	"
'	op$[$$fist]					= "	fist	"
'	op$[$$fistp]				= "	fistp	"
'	op$[$$fld]					= "	fld	"
'	op$[$$fldlg2]				= "	fldlg2	"
'	op$[$$fldln2]				= "	fldln2	"
'	op$[$$fldl2e]				= "	fldl2e	"
'	op$[$$fldl2t]				= "	fldl2t	"
'	op$[$$fldpi]				= "	fldpi	"
'	op$[$$fldz]					= "	fldz	"
'	op$[$$fld1]					= "	fld1	"
'	op$[$$fmul]					= "	fmul	"
'	op$[$$fmulp]				= "	fmulp	"
'	op$[$$fnop]					= "	fnop	"
'	op$[$$fpatan]				= "	fpatan	"
'	op$[$$fprem]				= "	fprem	"
'	op$[$$fprem1]				= "	fprem1	"
'	op$[$$fptan]				= "	fptan	"
'	op$[$$frndint]			= "	frndint	"
'	op$[$$fscale]				= "	fscale	"
'	op$[$$fsin]					= "	fsin	"
'	op$[$$fsincos]			= "	fsincos	"
'	op$[$$fsqrt]				= "	fsqrt	"
'	op$[$$fst]					= "	fst	"
'	op$[$$fstp]					= "	fstp	"
'	op$[$$fstsw]				= "	fstsw	"
'	op$[$$fnstsw]				= "	fnstsw	"
'	op$[$$fsub]					= "	fsub	"
'	op$[$$fsubp]				= "	fsubp	"
'	op$[$$fsubr]				= "	fsubr	"
'	op$[$$fsubrp]				= "	fsubrp	"
'	op$[$$ftst]					= "	ftst	"
'	op$[$$fucom]				= "	fucom	"
'	op$[$$fucomp]				= "	fucomp	"
'	op$[$$fucompp]			= "	fucompp	"
'	op$[$$fxam]					= "	fxam	"
'	op$[$$fxch]					= "	fxch	"
'	op$[$$fxtract]			= "	fxtract	"
'	op$[$$fyl2x]				= "	fyl2x	"
'	op$[$$fyl2xp1]			= "	fyl2xp1	"
'	op$[$$f2xn1]				= "	f2xn1	"
'	op$[$$idiv]					= "	idiv	"
'	op$[$$imul]					= "	imul	"
'	op$[$$inc]					= "	inc	"
'	op$[$$int]					= "	int	"
'	op$[$$into]					= "	into	"
'	op$[$$ja]						= "	ja	"
'	op$[$$jae]					= "	jae	"
'	op$[$$jb]						= "	jb	"
'	op$[$$jbe]					= "	jbe	"
'	op$[$$jc]						= "	jc	"
'	op$[$$jcxz]					= "	jcxz	"
'	op$[$$jecxz]				= "	jecxz	"
'	op$[$$je]						= "	je	"
'	op$[$$jg]						= "	jg	"
'	op$[$$jge]					= "	jge	"
'	op$[$$jl]						= "	jl	"
'	op$[$$jle]					= "	jle	"
'	op$[$$jna]					= "	jna	"
'	op$[$$jnae]					= "	jnae	"
'	op$[$$jnb]					= "	jnb	"
'	op$[$$jnbe]					= "	jnbe	"
'	op$[$$jnc]					= "	jnc	"
'	op$[$$jne]					= "	jne	"
'	op$[$$jng]					= "	jng	"
'	op$[$$jnge]					= "	jnge	"
'	op$[$$jnl]					= "	jnl	"
'	op$[$$jnle]					= "	jnle	"
'	op$[$$jno]					= "	jno	"
'	op$[$$jnp]					= "	jnp	"
'	op$[$$jns]					= "	jns	"
'	op$[$$jnz]					= "	jnz	"
'	op$[$$jo]						= "	jo	"
'	op$[$$jp]						= "	jp	"
'	op$[$$jpe]					= "	jpe	"
'	op$[$$jpo]					= "	jpo	"
'	op$[$$js]						= "	js	"
'	op$[$$jz]						= "	jz	"
'	op$[$$jmp]					= "	jmp	"
'	op$[$$lahf]					= "	lahf	"
'	op$[$$ld]						= "	mov	"
'	op$[$$lea]					= "	lea	"
'	op$[$$lodsb]				= "	lodsb	"
'	op$[$$lodsw]				= "	lodsw	"
'	op$[$$lodsd]				= "	lodsd	"
'	op$[$$loop]					= "	loop	"
'	op$[$$loopz]				= "	loopz	"
'	op$[$$loopnz]				= "	loopnz	"
'	op$[$$mov]					= "	mov	"
'	op$[$$movsb]				= "	movsb	"
'	op$[$$movsw]				= "	movsw	"
'	op$[$$movsd]				= "	movsd	"
'	op$[$$mul]					= "	mul	"
'	op$[$$neg]					= "	neg	"
'	op$[$$nop]					= "	nop	"
'	op$[$$not]					= "	not	"
'	op$[$$or]						= "	or	"
'	op$[$$pop]					= "	pop	"
'	op$[$$popad]				= "	popad	"
'	op$[$$popfd]				= "	popfd	"
'	op$[$$push]					= "	push	"
'	op$[$$pushad]				= "	pushad	"
'	op$[$$pushfd]				= "	pushfd	"
'	op$[$$rcl]					= "	rcl	"
'	op$[$$rcr]					= "	rcr	"
'	op$[$$rol]					= "	rol	"
'	op$[$$ror]					= "	ror	"
'	op$[$$rep]					= "	rep	"
'	op$[$$repz]					= "	repz	"
'	op$[$$repnz]				= "	repnz	"
'	op$[$$ret]					= "	ret	"
'	op$[$$sahf]					= "	sahf	"
'	op$[$$sal]					= "	sal	"
'	op$[$$sar]					= "	sar	"
'	op$[$$sll]					= "	sll	"
'	op$[$$slr]					= "	slr	"
'	op$[$$sbb]					= "	sbb	"
'	op$[$$scasb]				= "	scasb	"
'	op$[$$scasw]				= "	scasw	"
'	op$[$$scasd]				= "	scasd	"
'	op$[$$shld]					= "	shld	"
'	op$[$$shrd]					= "	shrd	"
'	op$[$$st]						= "	mov	"
'	op$[$$stc]					= "	stc	"
'	op$[$$std]					= "	std	"
'	op$[$$stosb]				= "	stosb	"
'	op$[$$stosw]				= "	stosw	"
'	op$[$$stosd]				= "	stosd	"
'	op$[$$sub]					= "	sub	"
'	op$[$$test]					= "	test	"
'	op$[$$xchg]					= "	xchg	"
'	op$[$$xor]					= "	xor	"
'
	op$[$$nop]					= "	nop	"				' nop			=
	op$[$$adc]					= "	adcl	"			' adc
	op$[$$add]					= "	addl	"			' add
	op$[$$and]					= "	andl	"			' and
	op$[$$bsf]					= "	bsfl	"			' bsf				x
	op$[$$bsr]					= "	bsrl	"			' bsr
	op$[$$bt]						= "	btl	"				' bt
	op$[$$btc]					= "	btcl	"			' btc				x
	op$[$$btr]					= "	btrl	"			' btr
	op$[$$bts]					= "	btsl	"			' bts
	op$[$$call]					= "	call	"			' call		=	x
	op$[$$cbw]					= "	cbw	"				' cbw				x
	op$[$$cdq]					= "	cdq	"				' cdq			=
	op$[$$clc]					= "	clc	"				' clc			=
	op$[$$cld]					= "	cld	"				' cld			=
	op$[$$cmc]					= "	cmc	"				' cmc			=
	op$[$$cmp]					= "	cmpl	"			' cmp
	op$[$$cmpsb]				= "	cmpsb	"			' cmpsb		=
	op$[$$cmpsw]				= "	cmpsw	"			'	cmpsw			x
	op$[$$cmpsd]				= "	cmpsd	"			'	cmpsd			x
	op$[$$cwd]					= "	cwd	"				' cwd			=	x
	op$[$$cwde]					= "	cwde	"			' cwde		=	x
	op$[$$dec]					= "	decl	"			' dec
	op$[$$div]					= "	divl	"			' div
	op$[$$f2xm1]				= "	f2xm1	"			' f2xm1			x
	op$[$$fabs]					= "	fabs	"			' fabs		=
	op$[$$fadd]					= "	faddp	"			' fadd				!
	op$[$$faddp]				= "	faddp	"			' faddp		=
	op$[$$fchs]					= "	fchs	"			' fchs		=
	op$[$$fclex]				= "	fclex	"			' fclex		=	x
	op$[$$fnclex]				= "	fnclex	"		' fnclex	=
	op$[$$fcom]					= "	fcoms	"			' fcom
	op$[$$fcomp]				= "	fcomp	"			' fcomp		=
	op$[$$fcompp]				= "	fcompp	"		' fcompp	=
	op$[$$fcos]					= "	fcos	"			' fcos		=	x
	op$[$$fdecstp]			= "	fdecstp	"		'	fdecstp	= x
	op$[$$fdiv]					= "	fdivrp	"		' fdivrp			!
	op$[$$fdivp]				= "	fdivrp	"		' fdivrp		x !
	op$[$$fdivr]				= "	fdivp	"			' fdivp				!
	op$[$$fdivrp]				= "	fdivp	"			' fdivp			x	!
	op$[$$fild]					= "	fild	"			' fild		=		!
	op$[$$fincstp]			= "	fincstp	"		' fincstp	=	x
'	op$[$$fimul]				= " fimull	"		' fimul				!  !!! in unspas but not xnt.x !!!
	op$[$$fist]					= "	fist	"			' fist		=		!
	op$[$$fistp]				= "	fistp	"			' fistp		=		!
	op$[$$fld]					= "	fld	"				' fld			=		!
	op$[$$fldlg2]				= "	fldlg2	"		' fldlg2	=	x
	op$[$$fldln2]				= "	fldln2	"		' fldln2	=	x
	op$[$$fldl2e]				= "	fldl2e	"		' fldl2e	=	x
	op$[$$fldl2t]				= "	fldl2t	"		' fldl2t	=	x
	op$[$$fldpi]				= "	fldpi	"			' fldpi		=	x
	op$[$$fldz]					= "	fldz	"			' fldz		=	x
	op$[$$fld1]					= "	fld1	"			' fld1		=
	op$[$$fmul]					= "	fmulp	"			' fmul				!
	op$[$$fmulp]				= "	fmulp	"			' fmulp		=
	op$[$$fnop]					= "	fnop	"			' fnop		=
	op$[$$fpatan]				= "	fpatan	"		' fpatan	=	x
	op$[$$fprem]				= "	fprem	"			' fprem		=	x
	op$[$$fprem1]				= "	fprem1	"		' fprem1	=	x
	op$[$$fptan]				= "	fptan	"			' fptan		=	x
	op$[$$frndint]			= "	frndint	"		' frndint	=
	op$[$$fscale]				= "	fscale	"		' fscale	=	x
	op$[$$fsin]					= "	fsin	"			' fsin		=	x
	op$[$$fsincos]			= "	fsincos	"		' fsincos	=	x
	op$[$$fsqrt]				= "	fsqrt	"			' fsqrt		=	x
	op$[$$fst]					= "	fst	"				' fst			=		!
	op$[$$fstp]					= "	fstp	"			' fstp		=		!
	op$[$$fstsw]				= "	fstsw	"			' fstsw		=				!!! fas assembles as fnstsw
	op$[$$fnstsw]				= "	fnstsw	"		' fnstsw	=
	op$[$$fsub]					= "	fsubrp	"		' fsub				!
	op$[$$fsubp]				= "	fsubrp	"		' fsubp				!
	op$[$$fsubr]				= "	fsubp	"			' fsubr				!
	op$[$$fsubrp]				= "	fsubp	"			' fsubrp			!
	op$[$$ftst]					= "	ftst	"			' ftst		=
	op$[$$fucom]				= "	fucom	"			' fucom		=	x
	op$[$$fucomp]				= "	fucomp	"		' fucomp	=	x
	op$[$$fucompp]			= "	fucompp	"		' fucompp	=	x
'	op$[$$fwait]				= "	fwait	"			' fwait		=		!		!!! in unspas but not xnt.x !!!
	op$[$$fxam]					= "	fxam	"			' fxam		=
	op$[$$fxch]					= "	fxch	"			' fxch		=	x
	op$[$$fxtract]			= "	fxtract	"		' fxtract	=	x
	op$[$$fyl2x]				= "	fyl2x	"			' fyl2x		=	x
	op$[$$fyl2xp1]			= "	fyl2xp1	"		' fyl2xp1	=	x
	op$[$$f2xn1]				= "	f2xn1	"			' f2xn1		=	x
	op$[$$idiv]					= "	idiv	"			' idiv		=
	op$[$$imul]					= "	imul	"			' imul		=
	op$[$$inc]					= "	incl	"			' inc
	op$[$$int]					= "	int	"				' int			=
	op$[$$into]					= "	into	"			' into		=
	op$[$$ja]						= "	ja	"				' ja			=	x
	op$[$$jae]					= "	jae	"				' jae			=	x
	op$[$$jb]						= "	jb	"				' jb			=	x
	op$[$$jbe]					= "	jbe	"				' jbe			=	x
	op$[$$jc]						= "	jc	"				' jc			=	x
	op$[$$jcxz]					= "	jcxz	"			' jcxz		=	x
	op$[$$jecxz]				= "	jecxz	"			' jecxz		=	x
	op$[$$je]						= "	je	"				' je			=	x
	op$[$$jg]						= "	jg	"				' jg			=	x
	op$[$$jge]					= "	jge	"				' jge			=	x
	op$[$$jl]						= "	jl	"				' jl			=	x
	op$[$$jle]					= "	jle	"				' jle			=	x
	op$[$$jna]					= "	jna	"				' jna			=	x
	op$[$$jnae]					= "	jnae	"			' jnae		=	x
	op$[$$jnb]					= "	jnb	"				' jnb			=	x
	op$[$$jnbe]					= "	jnbe	"			' jnbe		=	x
	op$[$$jnc]					= "	jnc	"				' jnc			=	x
	op$[$$jne]					= "	jne	"				' jne			=	x
	op$[$$jng]					= "	jng	"				' jng			=	x
	op$[$$jnge]					= "	jnge	"			' jnge		=	x
	op$[$$jnl]					= "	jnl	"				' jnl			=	x
	op$[$$jnle]					= "	jnle	"			' jnle		=	x
	op$[$$jno]					= "	jno	"				' jno			=	x
	op$[$$jnp]					= "	jnp	"				' jnp			=	x
	op$[$$jns]					= "	jns	"				' jns			=	x
	op$[$$jnz]					= "	jnz	"				' jnz			=	x
	op$[$$jo]						= "	jo	"				' jo			=	x
	op$[$$jp]						= "	jp	"				' jp			=	x
	op$[$$jpe]					= "	jpe	"				' jpe			=	x
	op$[$$jpo]					= "	jpo	"				' jpo			=	x
	op$[$$js]						= "	js	"				' js			=	x
	op$[$$jz]						= "	jz	"				' jz			=	x
	op$[$$jmp]					= "	jmp	"				' jmp			=	x
	op$[$$lahf]					= "	lahf	"			' lahf		=
	op$[$$ld]						= "	movl	"			' mov
	op$[$$lea]					= "	leal	"			' lea
	op$[$$lodsb]				= "	lodsb	"			' lodsb		=	x
	op$[$$lodsw]				= "	lodsw	"			' lodsw		=	x
	op$[$$lodsd]				= "	lodsd	"			' lodsd		=	x
	op$[$$loop]					= "	loop	"			' loop		=	x
	op$[$$loopz]				= "	loopz	"			' loopz		=	x
	op$[$$loopnz]				= "	loopnz	"		' loopnz	=	x
	op$[$$mov]					= "	movl	"			' mov
	op$[$$movsb]				= "	movsb	"			' movsb		=
	op$[$$movsw]				= "	movsw	"			' movsw		=
	op$[$$movsd]				= "	movsl	"			' movsd
	op$[$$mul]					= "	mull	"			' mul
	op$[$$neg]					= "	negl	"			' neg
	op$[$$nop]					= "	nop	"				' nop			=
	op$[$$not]					= "	notl	"			' not
	op$[$$or]						= "	orl	"				' or
	op$[$$pop]					= "	popl	"			' pop
	op$[$$popad]				= "	popad	"			' popad		=	x
	op$[$$popfd]				= "	popfd	"			' popfd		=	x
	op$[$$push]					= "	pushl	"			' push
	op$[$$pushad]				= "	pushad	"		' pushad	=	x
	op$[$$pushfd]				= "	pushfd	"		' pushfd	=	x
	op$[$$rcl]					= "	rcll	"			' rcl				x
	op$[$$rcr]					= "	rcrl	"			' rcr				x
	op$[$$rol]					= "	roll	"			' rol				x
	op$[$$ror]					= "	rorl	"			' ror				x
	op$[$$rep]					= "	rep	"				' rep			=	x
	op$[$$repz]					= "	repz	"			' repz		=	x
	op$[$$repnz]				= "	repnz	"			' repnz		=	x
	op$[$$ret]					= "	ret	"				' ret			=	x
	op$[$$sahf]					= "	sahf	"			' sahf		=
	op$[$$sal]					= "	sall	"			' sal
	op$[$$sar]					= "	sarl	"			' sar
	op$[$$sll]					= "	shll	"			' sll
	op$[$$slr]					= "	shrl	"			' slr
	op$[$$sbb]					= "	sbbl	"			' sbb
	op$[$$scasb]				= "	scasb	"			' scasb		=
	op$[$$scasw]				= "	scasw	"			' scasw		=	x
	op$[$$scasd]				= "	scasd	"			' scasd		=	x
	op$[$$shld]					= "	shldl	"			' shld
	op$[$$shrd]					= "	shrdl	"			' shrd
	op$[$$st]						= "	movl	"			' mov
	op$[$$stc]					= "	stc	"				' stc			=	x
	op$[$$std]					= "	std	"				' std			=	x
	op$[$$stosb]				= "	stosb	"			' stosb		=
	op$[$$stosw]				= "	stosw	"			' stosw		=
	op$[$$stosd]				= "	stosl	"			' stosd
	op$[$$sub]					= "	subl	"			' sub
	op$[$$test]					= "	testl	"			' test
	op$[$$xchg]					= "	xchgl	"			' xchg
'	op$[$$xlat]					= " xlat	"			' xlatb				!		!!! in unspas but not xnt.x !!!
	op$[$$xor]					= "	xorl	"			' xor
'
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
'
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
'
	iptr$[$$ZERO]								= ""
	iptr$[$$VOID]								= ""
	iptr$[$$SBYTE]							= "byte ptr "
	iptr$[$$UBYTE]							= "byte ptr "
	iptr$[$$SSHORT]							= "word ptr "
	iptr$[$$USHORT]							= "word ptr "
	iptr$[$$SLONG]							= ""
	iptr$[$$ULONG]							= ""
	iptr$[$$XLONG]							= ""
	iptr$[$$GOADDR]							= ""
	iptr$[$$SUBADDR]						= ""
	iptr$[$$FUNCADDR]						= ""
	iptr$[$$GIANT]							= ""
	iptr$[$$SINGLE]							= "dword ptr "
	iptr$[$$DOUBLE]							= "qword ptr "
	fptr$[$$ZERO]								= ""
	fptr$[$$VOID]								= ""
	fptr$[$$SBYTE]							= "byte ptr "
	fptr$[$$UBYTE]							= "byte ptr "
	fptr$[$$SSHORT]							= "word ptr "
	fptr$[$$USHORT]							= "word ptr "
	fptr$[$$SLONG]							= ""
	fptr$[$$ULONG]							= ""
	fptr$[$$XLONG]							= ""
	fptr$[$$GOADDR]							= ""
	fptr$[$$SUBADDR]						= ""
	fptr$[$$FUNCADDR]						= ""
	fptr$[$$GIANT]							= "qword ptr "
	fptr$[$$SINGLE]							= "dword ptr "
	fptr$[$$DOUBLE]							= "qword ptr "
'
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
'
	op86[$$adc, $am_regea].nbytes = 1
	op86[$$adc, $am_regea].byte1 = 0x13
	op86[$$adc, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$adc, $am_eareg].nbytes = 1
	op86[$$adc, $am_eareg].byte1 = 0x11
	op86[$$adc, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$adc, $am_ea].optype = GOADDRESS(BErr)
	op86[$$adc, $am_eaimm].nbytes = 1
	op86[$$adc, $am_eaimm].byte1 = 0x81
	op86[$$adc, $am_eaimm].param = 2
	op86[$$adc, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$adc, $am_rel].optype = GOADDRESS(BErr)
	op86[$$adc, $am_none].optype = GOADDRESS(BErr)
	op86[$$add, $am_regea].nbytes = 1
	op86[$$add, $am_regea].byte1 = 0x03
	op86[$$add, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$add, $am_eareg].nbytes = 1
	op86[$$add, $am_eareg].byte1 = 0x01
	op86[$$add, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$add, $am_ea].optype = GOADDRESS(BErr)
	op86[$$add, $am_eaimm].nbytes = 1
	op86[$$add, $am_eaimm].byte1 = 0x81
	op86[$$add, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$add, $am_rel].optype = GOADDRESS(BErr)
	op86[$$add, $am_none].optype = GOADDRESS(BErr)
	op86[$$and, $am_regea].nbytes = 1
	op86[$$and, $am_regea].byte1 = 0x23
	op86[$$and, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$and, $am_eareg].nbytes = 1
	op86[$$and, $am_eareg].byte1 = 0x21
	op86[$$and, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$and, $am_ea].optype = GOADDRESS(BErr)
	op86[$$and, $am_eaimm].nbytes = 1
	op86[$$and, $am_eaimm].byte1 = 0x81
	op86[$$and, $am_eaimm].param = 4
	op86[$$and, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$and, $am_rel].optype = GOADDRESS(BErr)
	op86[$$and, $am_none].optype = GOADDRESS(BErr)
	op86[$$cmp, $am_regea].nbytes = 1
	op86[$$cmp, $am_regea].byte1 = 0x3B
	op86[$$cmp, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$cmp, $am_eareg].nbytes = 1
	op86[$$cmp, $am_eareg].byte1 = 0x39
	op86[$$cmp, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$cmp, $am_ea].optype = GOADDRESS(BErr)
	op86[$$cmp, $am_eaimm].nbytes = 1
	op86[$$cmp, $am_eaimm].byte1 = 0x81
	op86[$$cmp, $am_eaimm].param = 7
	op86[$$cmp, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$cmp, $am_rel].optype = GOADDRESS(BErr)
	op86[$$cmp, $am_none].optype = GOADDRESS(BErr)
	op86[$$or, $am_regea].nbytes = 1
	op86[$$or, $am_regea].byte1 = 0x0B
	op86[$$or, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$or, $am_eareg].nbytes = 1
	op86[$$or, $am_eareg].byte1 = 0x09
	op86[$$or, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$or, $am_ea].optype = GOADDRESS(BErr)
	op86[$$or, $am_eaimm].nbytes = 1
	op86[$$or, $am_eaimm].byte1 = 0x81
	op86[$$or, $am_eaimm].param = 1
	op86[$$or, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$or, $am_rel].optype = GOADDRESS(BErr)
	op86[$$or, $am_none].optype = GOADDRESS(BErr)
	op86[$$sbb, $am_regea].nbytes = 1
	op86[$$sbb, $am_regea].byte1 = 0x1B
	op86[$$sbb, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$sbb, $am_eareg].nbytes = 1
	op86[$$sbb, $am_eareg].byte1 = 0x19
	op86[$$sbb, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$sbb, $am_ea].optype = GOADDRESS(BErr)
	op86[$$sbb, $am_eaimm].nbytes = 1
	op86[$$sbb, $am_eaimm].byte1 = 0x81
	op86[$$sbb, $am_eaimm].param = 3
	op86[$$sbb, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$sbb, $am_rel].optype = GOADDRESS(BErr)
	op86[$$sbb, $am_none].optype = GOADDRESS(BErr)
	op86[$$sub, $am_regea].nbytes = 1
	op86[$$sub, $am_regea].byte1 = 0x2B
	op86[$$sub, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$sub, $am_eareg].nbytes = 1
	op86[$$sub, $am_eareg].byte1 = 0x29
	op86[$$sub, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$sub, $am_ea].optype = GOADDRESS(BErr)
	op86[$$sub, $am_eaimm].nbytes = 1
	op86[$$sub, $am_eaimm].byte1 = 0x81
	op86[$$sub, $am_eaimm].param = 5
	op86[$$sub, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$sub, $am_rel].optype = GOADDRESS(BErr)
	op86[$$sub, $am_none].optype = GOADDRESS(BErr)
	op86[$$xor, $am_regea].nbytes = 1
	op86[$$xor, $am_regea].byte1 = 0x33
	op86[$$xor, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$xor, $am_eareg].nbytes = 1
	op86[$$xor, $am_eareg].byte1 = 0x31
	op86[$$xor, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$xor, $am_ea].optype = GOADDRESS(BErr)
	op86[$$xor, $am_eaimm].nbytes = 1
	op86[$$xor, $am_eaimm].byte1 = 0x81
	op86[$$xor, $am_eaimm].param = 6
	op86[$$xor, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$xor, $am_rel].optype = GOADDRESS(BErr)
	op86[$$xor, $am_none].optype = GOADDRESS(BErr)
	op86[$$mov, $am_regea].nbytes = 1
	op86[$$mov, $am_regea].byte1 = 0x8B
	op86[$$mov, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$mov, $am_eareg].nbytes = 1
	op86[$$mov, $am_eareg].byte1 = 0x89
	op86[$$mov, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$mov, $am_ea].optype = GOADDRESS(BErr)
	op86[$$mov, $am_eaimm].nbytes = 1
	op86[$$mov, $am_eaimm].byte1 = 0xC7
	op86[$$mov, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$mov, $am_rel].optype = GOADDRESS(BErr)
	op86[$$mov, $am_none].optype = GOADDRESS(BErr)
	op86[$$ld, $am_regea].nbytes = 1
	op86[$$ld, $am_regea].byte1 = 0x8B
	op86[$$ld, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$ld, $am_eareg].nbytes = 1
	op86[$$ld, $am_eareg].byte1 = 0x89
	op86[$$ld, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$ld, $am_ea].optype = GOADDRESS(BErr)
	op86[$$ld, $am_eaimm].nbytes = 1
	op86[$$ld, $am_eaimm].byte1 = 0xC7
	op86[$$ld, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$ld, $am_rel].optype = GOADDRESS(BErr)
	op86[$$ld, $am_none].optype = GOADDRESS(BErr)
	op86[$$st, $am_regea].nbytes = 1
	op86[$$st, $am_regea].byte1 = 0x8B
	op86[$$st, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$st, $am_eareg].nbytes = 1
	op86[$$st, $am_eareg].byte1 = 0x89
	op86[$$st, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$st, $am_ea].optype = GOADDRESS(BErr)
	op86[$$st, $am_eaimm].nbytes = 1
	op86[$$st, $am_eaimm].byte1 = 0xC7
	op86[$$st, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$st, $am_rel].optype = GOADDRESS(BErr)
	op86[$$st, $am_none].optype = GOADDRESS(BErr)
	op86[$$test, $am_regea].nbytes = 1
	op86[$$test, $am_regea].byte1 = 0x85
	op86[$$test, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$test, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$test, $am_ea].optype = GOADDRESS(BErr)
	op86[$$test, $am_eaimm].nbytes = 1
	op86[$$test, $am_eaimm].byte1 = 0xF7
	op86[$$test, $am_eaimm].optype = GOADDRESS(BRegop)
	op86[$$test, $am_rel].optype = GOADDRESS(BErr)
	op86[$$test, $am_none].optype = GOADDRESS(BErr)
	op86[$$imul, $am_regea].nbytes = 2
	op86[$$imul, $am_regea].byte1 = 0x0F
	op86[$$imul, $am_regea].byte2 = 0xAF
	op86[$$imul, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$imul, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$imul, $am_ea].nbytes = 1
	op86[$$imul, $am_ea].byte1 = 0xF7
	op86[$$imul, $am_ea].param = 5
	op86[$$imul, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$imul, $am_eaimm].nbytes = 1
	op86[$$imul, $am_eaimm].byte1 = 0x69
	op86[$$imul, $am_eaimm].optype = GOADDRESS(BImul)
	op86[$$imul, $am_rel].optype = GOADDRESS(BErr)
	op86[$$imul, $am_none].optype = GOADDRESS(BErr)
	op86[$$idiv, $am_regea].optype = GOADDRESS(BErr)
	op86[$$idiv, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$idiv, $am_ea].nbytes = 1
	op86[$$idiv, $am_ea].byte1 = 0xF7
	op86[$$idiv, $am_ea].param = 7
	op86[$$idiv, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$idiv, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$idiv, $am_rel].optype = GOADDRESS(BErr)
	op86[$$idiv, $am_none].optype = GOADDRESS(BErr)
	op86[$$div, $am_regea].optype = GOADDRESS(BErr)
	op86[$$div, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$div, $am_ea].nbytes = 1
	op86[$$div, $am_ea].byte1 = 0xF7
	op86[$$div, $am_ea].param = 6
	op86[$$div, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$div, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$div, $am_rel].optype = GOADDRESS(BErr)
	op86[$$div, $am_none].optype = GOADDRESS(BErr)
	op86[$$mul, $am_regea].optype = GOADDRESS(BErr)
	op86[$$mul, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$mul, $am_ea].nbytes = 1
	op86[$$mul, $am_ea].byte1 = 0xF7
	op86[$$mul, $am_ea].param = 4
	op86[$$mul, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$mul, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$mul, $am_rel].optype = GOADDRESS(BErr)
	op86[$$mul, $am_none].optype = GOADDRESS(BErr)
	op86[$$not, $am_regea].optype = GOADDRESS(BErr)
	op86[$$not, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$not, $am_ea].nbytes = 1
	op86[$$not, $am_ea].byte1 = 0xF7
	op86[$$not, $am_ea].param = 2
	op86[$$not, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$not, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$not, $am_rel].optype = GOADDRESS(BErr)
	op86[$$not, $am_none].optype = GOADDRESS(BErr)
	op86[$$neg, $am_regea].optype = GOADDRESS(BErr)
	op86[$$neg, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$neg, $am_ea].nbytes = 1
	op86[$$neg, $am_ea].byte1 = 0xF7
	op86[$$neg, $am_ea].param = 3
	op86[$$neg, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$neg, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$neg, $am_rel].optype = GOADDRESS(BErr)
	op86[$$neg, $am_none].optype = GOADDRESS(BErr)
	op86[$$movsx, $am_regea].nbytes = 2
	op86[$$movsx, $am_regea].byte1 = 0x0F
	op86[$$movsx, $am_regea].byte2 = 0xBF
	op86[$$movsx, $am_regea].optype = GOADDRESS(BMovx)
	op86[$$movsx, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$movsx, $am_ea].optype = GOADDRESS(BErr)
	op86[$$movsx, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$movsx, $am_rel].optype = GOADDRESS(BErr)
	op86[$$movsx, $am_none].optype = GOADDRESS(BErr)
	op86[$$movzx, $am_regea].nbytes = 2
	op86[$$movzx, $am_regea].byte1 = 0x0F
	op86[$$movzx, $am_regea].byte2 = 0xB7
	op86[$$movzx, $am_regea].optype = GOADDRESS(BMovx)
	op86[$$movzx, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$movzx, $am_ea].optype = GOADDRESS(BErr)
	op86[$$movzx, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$movzx, $am_rel].optype = GOADDRESS(BErr)
	op86[$$movzx, $am_none].optype = GOADDRESS(BErr)
	op86[$$fstsw, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fstsw, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fstsw, $am_ea].nbytes = 2
	op86[$$fstsw, $am_ea].byte1 = 0xDF
	op86[$$fstsw, $am_ea].byte2 = 0xE0
	op86[$$fstsw, $am_ea].optype = GOADDRESS(BFstsw)
	op86[$$fstsw, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fstsw, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fstsw, $am_none].optype = GOADDRESS(BErr)
	op86[$$fld, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fld, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fld, $am_ea].optype = GOADDRESS(BFld)
	op86[$$fld, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fld, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fld, $am_none].optype = GOADDRESS(BErr)
	op86[$$fild, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fild, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fild, $am_ea].optype = GOADDRESS(BFild)
	op86[$$fild, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fild, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fild, $am_none].optype = GOADDRESS(BErr)
	op86[$$fst, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fst, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fst, $am_ea].optype = GOADDRESS(BFst)
	op86[$$fst, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fst, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fst, $am_none].optype = GOADDRESS(BErr)
	op86[$$fist, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fist, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fist, $am_ea].optype = GOADDRESS(BFist)
	op86[$$fist, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fist, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fist, $am_none].optype = GOADDRESS(BErr)
	op86[$$fstp, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fstp, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fstp, $am_ea].optype = GOADDRESS(BFstp)
	op86[$$fstp, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fstp, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fstp, $am_none].optype = GOADDRESS(BErr)
	op86[$$fistp, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fistp, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fistp, $am_ea].optype = GOADDRESS(BFistp)
	op86[$$fistp, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fistp, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fistp, $am_none].optype = GOADDRESS(BErr)
	op86[$$push, $am_regea].optype = GOADDRESS(BErr)
	op86[$$push, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$push, $am_ea].nbytes = 1
	op86[$$push, $am_ea].byte1 = 0xFF
	op86[$$push, $am_ea].param = 6
	op86[$$push, $am_ea].optype = GOADDRESS(BWord)
	op86[$$push, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$push, $am_rel].nbytes = 1
	op86[$$push, $am_rel].byte1 = 0x68
	op86[$$push, $am_rel].optype = GOADDRESS(BImm)
	op86[$$push, $am_none].optype = GOADDRESS(BErr)
	op86[$$pop, $am_regea].optype = GOADDRESS(BErr)
	op86[$$pop, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$pop, $am_ea].nbytes = 1
	op86[$$pop, $am_ea].byte1 = 0x8F
	op86[$$pop, $am_ea].optype = GOADDRESS(BWord)
	op86[$$pop, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$pop, $am_rel].optype = GOADDRESS(BErr)
	op86[$$pop, $am_none].optype = GOADDRESS(BErr)
	op86[$$inc, $am_regea].optype = GOADDRESS(BErr)
	op86[$$inc, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$inc, $am_ea].nbytes = 1
	op86[$$inc, $am_ea].byte1 = 0xFF
	op86[$$inc, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$inc, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$inc, $am_rel].optype = GOADDRESS(BErr)
	op86[$$inc, $am_none].optype = GOADDRESS(BErr)
	op86[$$dec, $am_regea].optype = GOADDRESS(BErr)
	op86[$$dec, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$dec, $am_ea].nbytes = 1
	op86[$$dec, $am_ea].byte1 = 0xFF
	op86[$$dec, $am_ea].param = 1
	op86[$$dec, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$dec, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$dec, $am_rel].optype = GOADDRESS(BErr)
	op86[$$dec, $am_none].optype = GOADDRESS(BErr)
	op86[$$xchg, $am_regea].nbytes = 1
	op86[$$xchg, $am_regea].byte1 = 0x87
	op86[$$xchg, $am_regea].optype = GOADDRESS(BNorm)
	op86[$$xchg, $am_eareg].nbytes = 1
	op86[$$xchg, $am_eareg].byte1 = 0x87
	op86[$$xchg, $am_eareg].optype = GOADDRESS(BNorm)
	op86[$$xchg, $am_ea].optype = GOADDRESS(BErr)
	op86[$$xchg, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$xchg, $am_rel].optype = GOADDRESS(BErr)
	op86[$$xchg, $am_none].optype = GOADDRESS(BErr)
	op86[$$lea, $am_regea].nbytes = 1
	op86[$$lea, $am_regea].byte1 = 0x8D
	op86[$$lea, $am_regea].optype = GOADDRESS(BLea)
	op86[$$lea, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$lea, $am_ea].optype = GOADDRESS(BErr)
	op86[$$lea, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$lea, $am_rel].optype = GOADDRESS(BErr)
	op86[$$lea, $am_none].optype = GOADDRESS(BErr)
	op86[$$jmp, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jmp, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jmp, $am_ea].nbytes = 1
	op86[$$jmp, $am_ea].byte1 = 0xFF
	op86[$$jmp, $am_ea].param = 4
	op86[$$jmp, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$jmp, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jmp, $am_rel].nbytes = 1
	op86[$$jmp, $am_rel].byte1 = 0xE9
	op86[$$jmp, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jmp, $am_none].optype = GOADDRESS(BErr)
	op86[$$call, $am_regea].optype = GOADDRESS(BErr)
	op86[$$call, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$call, $am_ea].nbytes = 1
	op86[$$call, $am_ea].byte1 = 0xFF
	op86[$$call, $am_ea].param = 2
	op86[$$call, $am_ea].optype = GOADDRESS(BRegop)
	op86[$$call, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$call, $am_rel].nbytes = 1
	op86[$$call, $am_rel].byte1 = 0xE8
	op86[$$call, $am_rel].optype = GOADDRESS(BRel)
	op86[$$call, $am_none].optype = GOADDRESS(BErr)
	op86[$$rol, $am_regea].nbytes = 1
	op86[$$rol, $am_regea].byte1 = 0xD3
	op86[$$rol, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$rol, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$rol, $am_ea].nbytes = 1
	op86[$$rol, $am_ea].byte1 = 0xD3
	op86[$$rol, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$rol, $am_eaimm].nbytes = 1
	op86[$$rol, $am_eaimm].byte1 = 0xC1
	op86[$$rol, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$rol, $am_rel].optype = GOADDRESS(BErr)
	op86[$$rol, $am_none].optype = GOADDRESS(BErr)
	op86[$$ror, $am_regea].nbytes = 1
	op86[$$ror, $am_regea].byte1 = 0xD3
	op86[$$ror, $am_regea].param = 1
	op86[$$ror, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$ror, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$ror, $am_ea].nbytes = 1
	op86[$$ror, $am_ea].byte1 = 0xD3
	op86[$$ror, $am_ea].param = 1
	op86[$$ror, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$ror, $am_eaimm].nbytes = 1
	op86[$$ror, $am_eaimm].byte1 = 0xC1
	op86[$$ror, $am_eaimm].param = 1
	op86[$$ror, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$ror, $am_rel].optype = GOADDRESS(BErr)
	op86[$$ror, $am_none].optype = GOADDRESS(BErr)
	op86[$$rcl, $am_regea].nbytes = 1
	op86[$$rcl, $am_regea].byte1 = 0xD3
	op86[$$rcl, $am_regea].param = 2
	op86[$$rcl, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$rcl, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$rcl, $am_ea].nbytes = 1
	op86[$$rcl, $am_ea].byte1 = 0xD3
	op86[$$rcl, $am_ea].param = 2
	op86[$$rcl, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$rcl, $am_eaimm].nbytes = 1
	op86[$$rcl, $am_eaimm].byte1 = 0xC1
	op86[$$rcl, $am_eaimm].param = 2
	op86[$$rcl, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$rcl, $am_rel].optype = GOADDRESS(BErr)
	op86[$$rcl, $am_none].optype = GOADDRESS(BErr)
	op86[$$rcr, $am_regea].nbytes = 1
	op86[$$rcr, $am_regea].byte1 = 0xD3
	op86[$$rcr, $am_regea].param = 3
	op86[$$rcr, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$rcr, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$rcr, $am_ea].nbytes = 1
	op86[$$rcr, $am_ea].byte1 = 0xD3
	op86[$$rcr, $am_ea].param = 3
	op86[$$rcr, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$rcr, $am_eaimm].nbytes = 1
	op86[$$rcr, $am_eaimm].byte1 = 0xC1
	op86[$$rcr, $am_eaimm].param = 3
	op86[$$rcr, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$rcr, $am_rel].optype = GOADDRESS(BErr)
	op86[$$rcr, $am_none].optype = GOADDRESS(BErr)
	op86[$$sll, $am_regea].nbytes = 1
	op86[$$sll, $am_regea].byte1 = 0xD3
	op86[$$sll, $am_regea].param = 4
	op86[$$sll, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$sll, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$sll, $am_ea].nbytes = 1
	op86[$$sll, $am_ea].byte1 = 0xD3
	op86[$$sll, $am_ea].param = 4
	op86[$$sll, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$sll, $am_eaimm].nbytes = 1
	op86[$$sll, $am_eaimm].byte1 = 0xC1
	op86[$$sll, $am_eaimm].param = 4
	op86[$$sll, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$sll, $am_rel].optype = GOADDRESS(BErr)
	op86[$$sll, $am_none].optype = GOADDRESS(BErr)
	op86[$$slr, $am_regea].nbytes = 1
	op86[$$slr, $am_regea].byte1 = 0xD3
	op86[$$slr, $am_regea].param = 5
	op86[$$slr, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$slr, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$slr, $am_ea].nbytes = 1
	op86[$$slr, $am_ea].byte1 = 0xD3
	op86[$$slr, $am_ea].param = 5
	op86[$$slr, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$slr, $am_eaimm].nbytes = 1
	op86[$$slr, $am_eaimm].byte1 = 0xC1
	op86[$$slr, $am_eaimm].param = 5
	op86[$$slr, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$slr, $am_rel].optype = GOADDRESS(BErr)
	op86[$$slr, $am_none].optype = GOADDRESS(BErr)
	op86[$$sar, $am_regea].nbytes = 1
	op86[$$sar, $am_regea].byte1 = 0xD3
	op86[$$sar, $am_regea].param = 7
	op86[$$sar, $am_regea].optype = GOADDRESS(BTwid)
	op86[$$sar, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$sar, $am_ea].nbytes = 1
	op86[$$sar, $am_ea].byte1 = 0xD3
	op86[$$sar, $am_ea].param = 7
	op86[$$sar, $am_ea].optype = GOADDRESS(BTwid)
	op86[$$sar, $am_eaimm].nbytes = 1
	op86[$$sar, $am_eaimm].byte1 = 0xC1
	op86[$$sar, $am_eaimm].param = 7
	op86[$$sar, $am_eaimm].optype = GOADDRESS(BTwid)
	op86[$$sar, $am_rel].optype = GOADDRESS(BErr)
	op86[$$sar, $am_none].optype = GOADDRESS(BErr)
	op86[$$rep, $am_regea].optype = GOADDRESS(BErr)
	op86[$$rep, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$rep, $am_ea].optype = GOADDRESS(BErr)
	op86[$$rep, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$rep, $am_rel].optype = GOADDRESS(BErr)
	op86[$$rep, $am_none].nbytes = 1
	op86[$$rep, $am_none].byte1 = 0xF3
	op86[$$rep, $am_none].optype = GOADDRESS(BNone)
	op86[$$repz, $am_regea].optype = GOADDRESS(BErr)
	op86[$$repz, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$repz, $am_ea].optype = GOADDRESS(BErr)
	op86[$$repz, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$repz, $am_rel].optype = GOADDRESS(BErr)
	op86[$$repz, $am_none].nbytes = 1
	op86[$$repz, $am_none].byte1 = 0xF3
	op86[$$repz, $am_none].optype = GOADDRESS(BNone)
	op86[$$repnz, $am_regea].optype = GOADDRESS(BErr)
	op86[$$repnz, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$repnz, $am_ea].optype = GOADDRESS(BErr)
	op86[$$repnz, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$repnz, $am_rel].optype = GOADDRESS(BErr)
	op86[$$repnz, $am_none].nbytes = 1
	op86[$$repnz, $am_none].byte1 = 0xF2
	op86[$$repnz, $am_none].optype = GOADDRESS(BNone)
	op86[$$stosb, $am_regea].optype = GOADDRESS(BErr)
	op86[$$stosb, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$stosb, $am_ea].optype = GOADDRESS(BErr)
	op86[$$stosb, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$stosb, $am_rel].optype = GOADDRESS(BErr)
	op86[$$stosb, $am_none].nbytes = 1
	op86[$$stosb, $am_none].byte1 = 0xAA
	op86[$$stosb, $am_none].optype = GOADDRESS(BNone)
	op86[$$stosw, $am_regea].optype = GOADDRESS(BErr)
	op86[$$stosw, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$stosw, $am_ea].optype = GOADDRESS(BErr)
	op86[$$stosw, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$stosw, $am_rel].optype = GOADDRESS(BErr)
	op86[$$stosw, $am_none].nbytes = 2
	op86[$$stosw, $am_none].byte1 = 0x66
	op86[$$stosw, $am_none].byte2 = 0xAB
	op86[$$stosw, $am_none].optype = GOADDRESS(BNone)
	op86[$$stosd, $am_regea].optype = GOADDRESS(BErr)
	op86[$$stosd, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$stosd, $am_ea].optype = GOADDRESS(BErr)
	op86[$$stosd, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$stosd, $am_rel].optype = GOADDRESS(BErr)
	op86[$$stosd, $am_none].nbytes = 1
	op86[$$stosd, $am_none].byte1 = 0xAB
	op86[$$stosd, $am_none].optype = GOADDRESS(BNone)
	op86[$$sahf, $am_regea].optype = GOADDRESS(BErr)
	op86[$$sahf, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$sahf, $am_ea].optype = GOADDRESS(BErr)
	op86[$$sahf, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$sahf, $am_rel].optype = GOADDRESS(BErr)
	op86[$$sahf, $am_none].nbytes = 1
	op86[$$sahf, $am_none].byte1 = 0x9E
	op86[$$sahf, $am_none].optype = GOADDRESS(BNone)
	op86[$$cdq, $am_regea].optype = GOADDRESS(BErr)
	op86[$$cdq, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$cdq, $am_ea].optype = GOADDRESS(BErr)
	op86[$$cdq, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$cdq, $am_rel].optype = GOADDRESS(BErr)
	op86[$$cdq, $am_none].nbytes = 1
	op86[$$cdq, $am_none].byte1 = 0x99
	op86[$$cdq, $am_none].optype = GOADDRESS(BNone)
	op86[$$cld, $am_regea].optype = GOADDRESS(BErr)
	op86[$$cld, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$cld, $am_ea].optype = GOADDRESS(BErr)
	op86[$$cld, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$cld, $am_rel].optype = GOADDRESS(BErr)
	op86[$$cld, $am_none].nbytes = 1
	op86[$$cld, $am_none].byte1 = 0xFC
	op86[$$cld, $am_none].optype = GOADDRESS(BNone)
	op86[$$std, $am_regea].optype = GOADDRESS(BErr)
	op86[$$std, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$std, $am_ea].optype = GOADDRESS(BErr)
	op86[$$std, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$std, $am_rel].optype = GOADDRESS(BErr)
	op86[$$std, $am_none].nbytes = 1
	op86[$$std, $am_none].byte1 = 0xFD
	op86[$$std, $am_none].optype = GOADDRESS(BNone)
	op86[$$clc, $am_regea].optype = GOADDRESS(BErr)
	op86[$$clc, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$clc, $am_ea].optype = GOADDRESS(BErr)
	op86[$$clc, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$clc, $am_rel].optype = GOADDRESS(BErr)
	op86[$$clc, $am_none].nbytes = 1
	op86[$$clc, $am_none].byte1 = 0xF8
	op86[$$clc, $am_none].optype = GOADDRESS(BNone)
	op86[$$stc, $am_regea].optype = GOADDRESS(BErr)
	op86[$$stc, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$stc, $am_ea].optype = GOADDRESS(BErr)
	op86[$$stc, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$stc, $am_rel].optype = GOADDRESS(BErr)
	op86[$$stc, $am_none].nbytes = 1
	op86[$$stc, $am_none].byte1 = 0xF9
	op86[$$stc, $am_none].optype = GOADDRESS(BNone)
	op86[$$cmc, $am_regea].optype = GOADDRESS(BErr)
	op86[$$cmc, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$cmc, $am_ea].optype = GOADDRESS(BErr)
	op86[$$cmc, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$cmc, $am_rel].optype = GOADDRESS(BErr)
	op86[$$cmc, $am_none].nbytes = 1
	op86[$$cmc, $am_none].byte1 = 0xF5
	op86[$$cmc, $am_none].optype = GOADDRESS(BNone)
	op86[$$ret, $am_regea].optype = GOADDRESS(BErr)
	op86[$$ret, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$ret, $am_ea].optype = GOADDRESS(BErr)
	op86[$$ret, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$ret, $am_rel].optype = GOADDRESS(BRetImm)
	op86[$$ret, $am_none].nbytes = 1
	op86[$$ret, $am_none].byte1 = 0xC3
	op86[$$ret, $am_none].optype = GOADDRESS(BNone)
	op86[$$into, $am_regea].optype = GOADDRESS(BErr)
	op86[$$into, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$into, $am_ea].optype = GOADDRESS(BErr)
	op86[$$into, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$into, $am_rel].optype = GOADDRESS(BErr)
	op86[$$into, $am_none].nbytes = 1
	op86[$$into, $am_none].byte1 = 0xCE
	op86[$$into, $am_none].optype = GOADDRESS(BNone)
	op86[$$int, $am_regea].optype = GOADDRESS(BErr)
	op86[$$int, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$int, $am_ea].optype = GOADDRESS(BErr)
	op86[$$int, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$int, $am_rel].optype = GOADDRESS(BInt)
	op86[$$int, $am_none].optype = GOADDRESS(BErr)
	op86[$$fcompp, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fcompp, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fcompp, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fcompp, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fcompp, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fcompp, $am_none].nbytes = 2
	op86[$$fcompp, $am_none].byte1 = 0xDE
	op86[$$fcompp, $am_none].byte2 = 0xD9
	op86[$$fcompp, $am_none].optype = GOADDRESS(BNone)
	op86[$$fchs, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fchs, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fchs, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fchs, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fchs, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fchs, $am_none].nbytes = 2
	op86[$$fchs, $am_none].byte1 = 0xD9
	op86[$$fchs, $am_none].byte2 = 0xE0
	op86[$$fchs, $am_none].optype = GOADDRESS(BNone)
	op86[$$fabs, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fabs, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fabs, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fabs, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fabs, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fabs, $am_none].nbytes = 2
	op86[$$fabs, $am_none].byte1 = 0xD9
	op86[$$fabs, $am_none].byte2 = 0xE1
	op86[$$fabs, $am_none].optype = GOADDRESS(BNone)
	op86[$$ftst, $am_regea].optype = GOADDRESS(BErr)
	op86[$$ftst, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$ftst, $am_ea].optype = GOADDRESS(BErr)
	op86[$$ftst, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$ftst, $am_rel].optype = GOADDRESS(BErr)
	op86[$$ftst, $am_none].nbytes = 2
	op86[$$ftst, $am_none].byte1 = 0xD9
	op86[$$ftst, $am_none].byte2 = 0xE4
	op86[$$ftst, $am_none].optype = GOADDRESS(BNone)
	op86[$$fxam, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fxam, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fxam, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fxam, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fxam, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fxam, $am_none].nbytes = 2
	op86[$$fxam, $am_none].byte1 = 0xD9
	op86[$$fxam, $am_none].byte2 = 0xE5
	op86[$$fxam, $am_none].optype = GOADDRESS(BNone)
	op86[$$fld1, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fld1, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fld1, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fld1, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fld1, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fld1, $am_none].nbytes = 2
	op86[$$fld1, $am_none].byte1 = 0xD9
	op86[$$fld1, $am_none].byte2 = 0xE8
	op86[$$fld1, $am_none].optype = GOADDRESS(BNone)
	op86[$$fldpi, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fldpi, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fldpi, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fldpi, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fldpi, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fldpi, $am_none].nbytes = 2
	op86[$$fldpi, $am_none].byte1 = 0xD9
	op86[$$fldpi, $am_none].byte2 = 0xEB
	op86[$$fldpi, $am_none].optype = GOADDRESS(BNone)
	op86[$$fldz, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fldz, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fldz, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fldz, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fldz, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fldz, $am_none].nbytes = 2
	op86[$$fldz, $am_none].byte1 = 0xD9
	op86[$$fldz, $am_none].byte2 = 0xEE
	op86[$$fldz, $am_none].optype = GOADDRESS(BNone)
	op86[$$fadd, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fadd, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fadd, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fadd, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fadd, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fadd, $am_none].nbytes = 2
	op86[$$fadd, $am_none].byte1 = 0xDE
	op86[$$fadd, $am_none].byte2 = 0xC1
	op86[$$fadd, $am_none].optype = GOADDRESS(BNone)
	op86[$$fmul, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fmul, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fmul, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fmul, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fmul, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fmul, $am_none].nbytes = 2
	op86[$$fmul, $am_none].byte1 = 0xDE
	op86[$$fmul, $am_none].byte2 = 0xC9
	op86[$$fmul, $am_none].optype = GOADDRESS(BNone)
	op86[$$fsub, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fsub, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fsub, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fsub, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fsub, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fsub, $am_none].nbytes = 2
	op86[$$fsub, $am_none].byte1 = 0xDE
	op86[$$fsub, $am_none].byte2 = 0xE9
	op86[$$fsub, $am_none].optype = GOADDRESS(BNone)
	op86[$$fsubr, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fsubr, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fsubr, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fsubr, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fsubr, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fsubr, $am_none].nbytes = 2
	op86[$$fsubr, $am_none].byte1 = 0xDE
	op86[$$fsubr, $am_none].byte2 = 0xE1
	op86[$$fsubr, $am_none].optype = GOADDRESS(BNone)
	op86[$$fdiv, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fdiv, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fdiv, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fdiv, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fdiv, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fdiv, $am_none].nbytes = 2
	op86[$$fdiv, $am_none].byte1 = 0xDE
	op86[$$fdiv, $am_none].byte2 = 0xF9
	op86[$$fdiv, $am_none].optype = GOADDRESS(BNone)
	op86[$$fdivr, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fdivr, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fdivr, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fdivr, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fdivr, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fdivr, $am_none].nbytes = 2
	op86[$$fdivr, $am_none].byte1 = 0xDE
	op86[$$fdivr, $am_none].byte2 = 0xF1
	op86[$$fdivr, $am_none].optype = GOADDRESS(BNone)
	op86[$$fxch, $am_regea].optype = GOADDRESS(BErr)
	op86[$$fxch, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$fxch, $am_ea].optype = GOADDRESS(BErr)
	op86[$$fxch, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$fxch, $am_rel].optype = GOADDRESS(BErr)
	op86[$$fxch, $am_none].nbytes = 2
	op86[$$fxch, $am_none].byte1 = 0xD9
	op86[$$fxch, $am_none].byte2 = 0xC9
	op86[$$fxch, $am_none].optype = GOADDRESS(BNone)
	op86[$$ja, $am_regea].optype = GOADDRESS(BErr)
	op86[$$ja, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$ja, $am_ea].optype = GOADDRESS(BErr)
	op86[$$ja, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$ja, $am_rel].nbytes = 2
	op86[$$ja, $am_rel].byte1 = 0x0F
	op86[$$ja, $am_rel].byte2 = 0x87
	op86[$$ja, $am_rel].optype = GOADDRESS(BRel)
	op86[$$ja, $am_none].optype = GOADDRESS(BErr)
	op86[$$jae, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jae, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jae, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jae, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jae, $am_rel].nbytes = 2
	op86[$$jae, $am_rel].byte1 = 0x0F
	op86[$$jae, $am_rel].byte2 = 0x83
	op86[$$jae, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jae, $am_none].optype = GOADDRESS(BErr)
	op86[$$jb, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jb, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jb, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jb, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jb, $am_rel].nbytes = 2
	op86[$$jb, $am_rel].byte1 = 0x0F
	op86[$$jb, $am_rel].byte2 = 0x82
	op86[$$jb, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jb, $am_none].optype = GOADDRESS(BErr)
	op86[$$jbe, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jbe, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jbe, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jbe, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jbe, $am_rel].nbytes = 2
	op86[$$jbe, $am_rel].byte1 = 0x0F
	op86[$$jbe, $am_rel].byte2 = 0x86
	op86[$$jbe, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jbe, $am_none].optype = GOADDRESS(BErr)
	op86[$$jc, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jc, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jc, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jc, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jc, $am_rel].nbytes = 2
	op86[$$jc, $am_rel].byte1 = 0x0F
	op86[$$jc, $am_rel].byte2 = 0x82
	op86[$$jc, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jc, $am_none].optype = GOADDRESS(BErr)
	op86[$$je, $am_regea].optype = GOADDRESS(BErr)
	op86[$$je, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$je, $am_ea].optype = GOADDRESS(BErr)
	op86[$$je, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$je, $am_rel].nbytes = 2
	op86[$$je, $am_rel].byte1 = 0x0F
	op86[$$je, $am_rel].byte2 = 0x84
	op86[$$je, $am_rel].optype = GOADDRESS(BRel)
	op86[$$je, $am_none].optype = GOADDRESS(BErr)
	op86[$$jg, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jg, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jg, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jg, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jg, $am_rel].nbytes = 2
	op86[$$jg, $am_rel].byte1 = 0x0F
	op86[$$jg, $am_rel].byte2 = 0x8F
	op86[$$jg, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jg, $am_none].optype = GOADDRESS(BErr)
	op86[$$jge, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jge, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jge, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jge, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jge, $am_rel].nbytes = 2
	op86[$$jge, $am_rel].byte1 = 0x0F
	op86[$$jge, $am_rel].byte2 = 0x8D
	op86[$$jge, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jge, $am_none].optype = GOADDRESS(BErr)
	op86[$$jl, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jl, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jl, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jl, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jl, $am_rel].nbytes = 2
	op86[$$jl, $am_rel].byte1 = 0x0F
	op86[$$jl, $am_rel].byte2 = 0x8C
	op86[$$jl, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jl, $am_none].optype = GOADDRESS(BErr)
	op86[$$jle, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jle, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jle, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jle, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jle, $am_rel].nbytes = 2
	op86[$$jle, $am_rel].byte1 = 0x0F
	op86[$$jle, $am_rel].byte2 = 0x8E
	op86[$$jle, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jle, $am_none].optype = GOADDRESS(BErr)
	op86[$$jna, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jna, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jna, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jna, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jna, $am_rel].nbytes = 2
	op86[$$jna, $am_rel].byte1 = 0x0F
	op86[$$jna, $am_rel].byte2 = 0x86
	op86[$$jna, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jna, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnae, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnae, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnae, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnae, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnae, $am_rel].nbytes = 2
	op86[$$jnae, $am_rel].byte1 = 0x0F
	op86[$$jnae, $am_rel].byte2 = 0x82
	op86[$$jnae, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnae, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnb, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnb, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnb, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnb, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnb, $am_rel].nbytes = 2
	op86[$$jnb, $am_rel].byte1 = 0x0F
	op86[$$jnb, $am_rel].byte2 = 0x83
	op86[$$jnb, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnb, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnbe, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnbe, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnbe, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnbe, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnbe, $am_rel].nbytes = 2
	op86[$$jnbe, $am_rel].byte1 = 0x0F
	op86[$$jnbe, $am_rel].byte2 = 0x87
	op86[$$jnbe, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnbe, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnc, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnc, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnc, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnc, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnc, $am_rel].nbytes = 2
	op86[$$jnc, $am_rel].byte1 = 0x0F
	op86[$$jnc, $am_rel].byte2 = 0x83
	op86[$$jnc, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnc, $am_none].optype = GOADDRESS(BErr)
	op86[$$jne, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jne, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jne, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jne, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jne, $am_rel].nbytes = 2
	op86[$$jne, $am_rel].byte1 = 0x0F
	op86[$$jne, $am_rel].byte2 = 0x85
	op86[$$jne, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jne, $am_none].optype = GOADDRESS(BErr)
	op86[$$jng, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jng, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jng, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jng, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jng, $am_rel].nbytes = 2
	op86[$$jng, $am_rel].byte1 = 0x0F
	op86[$$jng, $am_rel].byte2 = 0x8E
	op86[$$jng, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jng, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnge, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnge, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnge, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnge, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnge, $am_rel].nbytes = 2
	op86[$$jnge, $am_rel].byte1 = 0x0F
	op86[$$jnge, $am_rel].byte2 = 0x8C
	op86[$$jnge, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnge, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnl, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnl, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnl, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnl, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnl, $am_rel].nbytes = 2
	op86[$$jnl, $am_rel].byte1 = 0x0F
	op86[$$jnl, $am_rel].byte2 = 0x8D
	op86[$$jnl, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnl, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnle, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnle, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnle, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnle, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnle, $am_rel].nbytes = 2
	op86[$$jnle, $am_rel].byte1 = 0x0F
	op86[$$jnle, $am_rel].byte2 = 0x8F
	op86[$$jnle, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnle, $am_none].optype = GOADDRESS(BErr)
	op86[$$jno, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jno, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jno, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jno, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jno, $am_rel].nbytes = 2
	op86[$$jno, $am_rel].byte1 = 0x0F
	op86[$$jno, $am_rel].byte2 = 0x81
	op86[$$jno, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jno, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnp, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnp, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnp, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnp, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnp, $am_rel].nbytes = 2
	op86[$$jnp, $am_rel].byte1 = 0x0F
	op86[$$jnp, $am_rel].byte2 = 0x8B
	op86[$$jnp, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnp, $am_none].optype = GOADDRESS(BErr)
	op86[$$jns, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jns, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jns, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jns, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jns, $am_rel].nbytes = 2
	op86[$$jns, $am_rel].byte1 = 0x0F
	op86[$$jns, $am_rel].byte2 = 0x89
	op86[$$jns, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jns, $am_none].optype = GOADDRESS(BErr)
	op86[$$jnz, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jnz, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jnz, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jnz, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jnz, $am_rel].nbytes = 2
	op86[$$jnz, $am_rel].byte1 = 0x0F
	op86[$$jnz, $am_rel].byte2 = 0x85
	op86[$$jnz, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jnz, $am_none].optype = GOADDRESS(BErr)
	op86[$$jo, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jo, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jo, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jo, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jo, $am_rel].nbytes = 2
	op86[$$jo, $am_rel].byte1 = 0x0F
	op86[$$jo, $am_rel].byte2 = 0x80
	op86[$$jo, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jo, $am_none].optype = GOADDRESS(BErr)
	op86[$$jp, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jp, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jp, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jp, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jp, $am_rel].nbytes = 2
	op86[$$jp, $am_rel].byte1 = 0x0F
	op86[$$jp, $am_rel].byte2 = 0x8A
	op86[$$jp, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jp, $am_none].optype = GOADDRESS(BErr)
	op86[$$jpe, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jpe, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jpe, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jpe, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jpe, $am_rel].nbytes = 2
	op86[$$jpe, $am_rel].byte1 = 0x0F
	op86[$$jpe, $am_rel].byte2 = 0x8A
	op86[$$jpe, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jpe, $am_none].optype = GOADDRESS(BErr)
	op86[$$jpo, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jpo, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jpo, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jpo, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jpo, $am_rel].nbytes = 2
	op86[$$jpo, $am_rel].byte1 = 0x0F
	op86[$$jpo, $am_rel].byte2 = 0x8B
	op86[$$jpo, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jpo, $am_none].optype = GOADDRESS(BErr)
	op86[$$js, $am_regea].optype = GOADDRESS(BErr)
	op86[$$js, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$js, $am_ea].optype = GOADDRESS(BErr)
	op86[$$js, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$js, $am_rel].nbytes = 2
	op86[$$js, $am_rel].byte1 = 0x0F
	op86[$$js, $am_rel].byte2 = 0x88
	op86[$$js, $am_rel].optype = GOADDRESS(BRel)
	op86[$$js, $am_none].optype = GOADDRESS(BErr)
	op86[$$jz, $am_regea].optype = GOADDRESS(BErr)
	op86[$$jz, $am_eareg].optype = GOADDRESS(BErr)
	op86[$$jz, $am_ea].optype = GOADDRESS(BErr)
	op86[$$jz, $am_eaimm].optype = GOADDRESS(BErr)
	op86[$$jz, $am_rel].nbytes = 2
	op86[$$jz, $am_rel].byte1 = 0x0F
	op86[$$jz, $am_rel].byte2 = 0x84
	op86[$$jz, $am_rel].optype = GOADDRESS(BRel)
	op86[$$jz, $am_none].optype = GOADDRESS(BErr)

END SUB
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
'
' ############################
' #####  CodeLabelAbs()  #####  emits a absolute value of a label (four bytes)
' ############################
'

FUNCTION  CodeLabelAbs(label$, offset)
	EXTERNAL /xxx/	xpc
	XLONG addr
'
	addr = Value(label$, $$VALUEABS) + offset
	UBYTEAT(xpc) = addr AND 0xFF
	UBYTEAT(xpc, 1) = (addr AND 0xFF00) >> 8
	UBYTEAT(xpc, 2) = (addr AND 0xFF0000) >> 16
	UBYTEAT(xpc, 3) = (addr AND 0xFF000000) >> 24
	xpc = xpc + 4
END FUNCTION
'
'
'
' #############################  emits a displacement to a label
' #####  CodeLabelDisp()  #####  relative to the byte after the
' #############################  four-byte displacement
'
FUNCTION  CodeLabelDisp(label$)
	EXTERNAL /xxx/	xpc
	XLONG addr
'
	addr = Value(label$, $$VALUEDISP)
	IF addr THEN addr = addr - (xpc + 4)
	UBYTEAT(xpc) = addr AND 0xFF
	UBYTEAT(xpc, 1) = (addr AND 0xFF00) >> 8
	UBYTEAT(xpc, 2) = (addr AND 0xFF0000) >> 16
	UBYTEAT(xpc, 3) = (addr AND 0xFF000000) >> 24
	xpc = xpc + 4
END FUNCTION
'
'
' ########################
' #####  Compile ()  #####
' ########################
'
FUNCTION  Compile ()
	EXTERNAL /xxx/	i486bin,  i486asm,  xpc
	EXTERNAL /xxx/	checkBounds,  library,  errorCount
	SHARED  tokens[]
	SHARED  T_COLON,  T_DECLARE,  T_END,  T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED	T_PROGRAM,  T_REM,  XERROR,  ERROR_TOO_LATE
	SHARED  pass0source,  pass0tokens,  pass1source,  pass1tokens
	SHARED  end_program,  got_declare
	SHARED  lineNumber,  ofile,  pass,  rawLength,  rawline$
	SHARED  section,  tokenCount,  tokenPtr,  func_number
	SHARED  toes,  toms,  a0,  a0_type,  a1,  a1_type,  oos
	SHARED  program$,  programName$,  programPath$
	SHARED  entryCheckBounds
	SHARED  UBYTE  oos[]
	SHARED  UBYTE  charsetPath[]
	STATIC	xxpc
'
	XstGetCommandLineArguments (@argc, @argv$[])
'
	IF (argc > 1)	THEN
		FOR i = 1 TO argc - 1
			file$ = TRIM$(argv$[i])
			IFZ file$ THEN EXIT FOR
			IF (file${0} != '-') THEN EXIT FOR
			file$ = ""
		NEXT i
	END IF
'
'
' *****  if there's a <file$> then compile it
'
compileFile:
	IF file$ THEN
		CompileFile (@file$)
		compile = $$FALSE
		RETURN
	END IF
'
'
' *****  compile user-typed input  *****
'
	PRINT "\n#####  .file  #####\n"
'
	DO
		DO
			rawline$ = TRIM$(INLINE$(""))
			rawLength = LEN(rawline$)
		LOOP UNTIL (rawLength)
'
		SELECT CASE rawLength
			CASE 1:			switch = rawline${0}
									GOSUB CompileSwitch
			CASE ELSE:	IF (rawline${0} = '.') THEN EXIT DO
									GOSUB CompileTypedLine
		END SELECT
		IF end_program THEN RETURN
	LOOP
'
'
' *****  ".filename"
'
compileDotFile:
	dash = INSTR(rawline$,"-")
	IF dash THEN
		switch$ = TRIM$(MID$(rawline$,dash+1))
		rawline$ = TRIM$(LEFT$(rawline$,dash-1))
		upper = UBOUND (switch$)
		FOR i = 0 TO upper
			s = switch${i}
			IF (((s >= 'A') AND (s <= 'Z')) OR ((s >= 'a') AND (s <= 'z'))) THEN
				switch = s
				GOSUB CompileSwitch
			END IF
		NEXT i
	END IF
	file$ = TRIM$(MID$(rawline$, 2))
	upper = UBOUND (file$)
	FOR i = 0 TO upper
		char = file${i}
		IFZ charsetPath[char] THEN EXIT FOR
	NEXT i
	IF (i <= upper) THEN file$ = LEFT$(file$, i)
	GOTO compileFile
'
'
'
' *****  Only one character was typed on the line
'
SUB CompileSwitch
	SELECT CASE switch
		CASE 'a':	i486asm = $$TRUE: i486bin = $$FALSE: PRINT "i486asm"
		CASE 'b':	xpc = ##UCODE
							IFZ xpc THEN
								PRINT "i486bin unavailable : ##UCODE = 0"
							ELSE
								PRINT "i486bin at ##UCODE = "; HEX$(##UCODE,8)
								i486bin = $$TRUE: i486asm = $$FALSE
							END IF
							xxpc = xpc
		CASE 'B':	i486bin = $$TRUE : i486asm = $$FALSE
							xpc = ##DATAZ - 0x1000
							PRINT "i486bin at ##DATAZ - 0x1000 : !!! VERY DANGEROUS !!!"
							xxpc = xpc
		CASE 'C':	checkBounds = $$FALSE:	PRINT "bounds checking off"
							entryCheckBounds = $$FALSE
		CASE 'c':	checkBounds = $$TRUE:		PRINT "bounds checking on"
							entryCheckBounds = $$TRUE
		CASE 'l':	IF got_declare THEN GOTO eeeTooLate
							library = $$TRUE:				PRINT "compile as function library"
		CASE 'L':	IF got_declare THEN GOTO eeeTooLate
							library = $$FALSE:			PRINT "compile as application"
		CASE 'q':	RETURN ($$TRUE)
		CASE 'x':	PRINT XxxDisassemble$ (xxpc, xpc - xxpc)
		CASE 'S':	pass0source = $$TRUE
		CASE 's':	pass0source = $$FALSE
		CASE 'T':	pass0tokens = $$TRUE
		CASE 't':	pass0tokens = $$FALSE
		CASE 'U':	pass1source = $$TRUE
		CASE 'u':	pass1source = $$FALSE
		CASE 'V':	pass1tokens = $$TRUE
		CASE 'v':	pass1tokens = $$FALSE
		CASE '.':	rawline$		= "DECLARE FUNCTION a (XLONG, XLONG)"
							rawLength		= LEN (rawline$)
							GOSUB CompileTypedLine
							rawline$		= "FUNCTION a (y, z)"
							rawLength		= LEN (rawline$)
							GOSUB CompileTypedLine
	END SELECT
END SUB
'
'
'
SUB CompileTypedLine
	xxpc = xpc
	ParseLine (@tok[])
	IF pass0source THEN PRINT Deparse$ ("")
	IF pass0tokens THEN PrintTokens ()
	#immediatemode = $$TRUE
	CheckOneLine()
	#immediatemode = $$FALSE
	IF XERROR THEN
		IF PrintError (XERROR) THEN EXIT FUNCTION
	END IF
	IF (toes OR toms OR a0 OR a0_type OR a1 OR a1_type OR oos OR oos[0]) THEN
		PRINT Deparse$ (">>> ")
		PRINT "exp stk error:  "; toes; toms; a0; a0_type; a1; a1_type; oos; oos[0]
		a0 = 0: a1 = 0: toes = 0: toms = 0: a0_type = 0: a1_type = 0: oos = 0: oos[0] = 0
	END IF
	PRINT
END SUB
'
eeeTooLate:
	XERROR = ERROR_TOO_LATE
	EXIT FUNCTION
END FUNCTION
'
'
' ############################
' #####  CompileFile ()  #####
' ############################
'
FUNCTION  CompileFile (file$)
	EXTERNAL /xxx/	i486asm,  i486bin,  library
	SHARED	ofile,  rawline$,  rawLength,  compile,  end_program
	SHARED	tokens[],  tokenCount,  lineNumber,  func_number
	SHARED	export
	SHARED	tokenPtr,  got_declare,  got_function
	SHARED  program$,  programName$,  programPath$,  asmFile$
	SHARED	T_CFUNCTION,  T_DECLARE,  T_END,  T_EXPORT
	SHARED	T_FUNCTION,  T_IMPORT,  T_POUND,  T_PROGRAM
	SHARED	T_SFUNCTION
	SHARED	XERROR,  ERROR_COMPILER
'
	ofile = 0
	export = 0
	asmFile$ = ""
	##ERROR = $$FALSE
'
' find source file
'
	XstDecomposePathname (@file$, @path$, @parent$, @filename$, @programName$, @extent$)
	IF (extent$ != ".x") THEN filename$ = programName$ + ".x" : extent$ = ".x"
	GetSubPath (@"app", @programName$, @path$[])
	XstFindFile (@file$, @path$[], @xfile$, @attr)
	IF xfile$ THEN XxxSetProgramName (@xfile$)
'
' open source file
'
	fileNum = OPEN (xfile$, $$RD)
	IF (fileNum <= 0) THEN
		PRINT "error : can't open "; xfile$; " : "; ERROR$(##ERROR);;;; "terminating..."
		RETURN
	END IF
'
' read source file
'
	fileSize = LOF (fileNum)					' fileSize = # of bytes in file$
	IFZ fileSize THEN RETURN					' nothing in source file
	source$ = NULL$ (fileSize)				' source$ = size of program
	READ [fileNum], source$						' source$ = entire program
	CLOSE (fileNum)										' close source file
'
' Source program is in source$
' Now convert it to tokens
'
	upperLine = fileSize >> 3					' 1/8 size of source$
	DIM tokoid[upperLine, ]						' Create array for source$ program tokens
	sourceLine = 0
	off = 0
'
	PRINT "\n#####  "; xfile$; "  #####"
'	PRINT "*****  PASS 0  *****"
'
	DO
		INC sourceLine
		IFZ (sourceLine AND 0x3F) THEN XgrProcessMessages (-2)
		rawline$ = XstNextLine$ (@source$, @off, @done)
		rawLength = LEN (rawline$)
		ParseLine (@tok[])
		u = UBOUND (tok[])
		tok[u] = $$T_STARTS
		ATTACH tok[] TO tokoid[sourceLine, ]
		IF (sourceLine >= upperLine) THEN
			upperLine = upperLine + (upperLine >> 2)
			REDIM tokoid[upperLine, ]
		END IF
	LOOP UNTIL done
	DEC sourceLine
'	PRINT "*****  PASS 1  *****"
'
' Create assembly language output file
'
	##ERROR = $$FALSE
	XxxCreateCompileFiles ()
	IF (##ERROR OR (ofile <= 0)) THEN PRINT "CompileFile() : error : (Could not open .s file)" : GOTO eeeCompiler
'
	func_number = 0
	FOR lineNumber = 1 TO sourceLine
		IFZ (lineNumber AND 0x3F) THEN XgrProcessMessages (-2)
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
		CheckOneLine ()
		IF XERROR THEN
			IF PrintError (XERROR) THEN RETURN
		END IF
		IF end_program THEN RETURN
	NEXT lineNumber
'
' If program doesn't have an END PROGRAM then fake one (necessary)
'
	IFZ end_program THEN
		tokens[0]		= $$T_STARTS + 2
		tokens[1]		= T_END
		tokens[2]		= T_PROGRAM
		tokens[3]		= $$T_STARTS
		tokenCount	= 2
		CheckOneLine ()
	END IF
	IF (ofile > 2) THEN CLOSE (ofile)
	ofile = 0
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  Component ()  #####
' ##########################
'
' returns element address (not data)
'
' varToken	= composite variable token
'						= 0 once variable loaded into accumulator
' regBase		= the accumulator holding the current base pointer
' offset		= holds a compiler internal byte offset
'
FUNCTION  Component (command, varToken, regBase, offset, theType, token, length)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc,  checkBounds
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
	SHARED UBYTE  shiftMulti[]
'
	inType	= theType
	preType	= theType
	typeEleCount = typeEleCount[inType]
	found = $$FALSE
	i = 0
'
	DO WHILE (i < typeEleCount)
		subToken = typeEleToken[inType, i]
		IF (subToken = token) THEN
			componentNumber = i
			found = $$TRUE
			EXIT DO
		END IF
		INC i
	LOOP
	IFZ found THEN GOTO eeeComponent
'
	haveData = $$FALSE						' OUTDATED...used with ptrs
	theType = typeEleType[inType, i]
	offset = offset + typeEleAddr[inType, i]					' offset to this element
	ptrs = typeElePtr[inType, i]											' is this a pointer?
	lastElement = LastElement (token, @lastPlace, @excessComma)
	IF XERROR THEN EXIT FUNCTION
'
'	Get the component length (.a[] gives the size of the entire 1D array)
'
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
				END IF
			END IF
		CASE ELSE
			IF (theType = $$STRING) THEN
				length = typeEleStringSize[inType, i]
			ELSE
				length = typeSize[theType]
			END IF
	END SELECT
'
	IFZ ptrs THEN
		IF lastElement THEN											' HANDLE valid only for pointers
			IF (command = $$GETHANDLE) THEN GOTO eeeSyntax
		END IF
	ELSE
'		IF (offset > 65535) THEN GOTO eeeOverflow
		IF lastElement THEN
			IF (command = $$GETHANDLE) THEN
				theType = $$XLONG
				tokenPtr = lastPlace									' point to end of last composite
				RETURN																' offset points to handle
			END IF
		END IF
'
		IFZ varToken THEN									' base is in an accumulator already
			sreg = regBase
		ELSE
			regBase = OpenAccForType ($$XLONG)			' open regBase accumulator
			nn = varToken{$$NUMBER}
			sreg = r_addr[nn]
			IFZ sreg THEN														' data is in memory
				Move (regBase, $$XLONG, nn, $$XLONG)	' move data into acc
				sreg = regBase
			END IF
			varToken = 0
		END IF
'
'		BOUNDS CHECKING:  blow up if contents of sreg = 0
'			(Add when including pointers...)
'
		Code ($$ld, $$regro, regBase, sreg, offset, $$XLONG, "", @"### 382")
		offset = 0
'
'		BOUNDS CHECKING:  blow up if contents of regBase = 0
'			(Add when including pointers...)
'
		i = 2
		DO UNTIL (i > ptrs)
			Code ($$ld, $$regr0, regBase, regBase, 0, $$XLONG, "", @"### 383")
			INC i
		LOOP
	END IF
	IF (token{$$KIND} != $$KIND_ARRAY_SYMBOLS) THEN	RETURN	' element not array
'
'	Array:
'
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
		END IF
		accArray = 'v'
		ExpressArray (old_op, old_prec, @new_data, @new_type, accArray, 0, theType, 0)
		IF XERROR THEN EXIT FUNCTION
		IF lastElement THEN
			IF (command = $$GETDATAADDR) THEN						' returns composite type
				IF excessComma THEN theType = new_type		'		unless excessComma
			ELSE
				theType = new_type
			END IF
		ELSE
			IF (new_type < $$SCOMPLEX) THEN GOTO eeeSyntax
		END IF
		regBase = Top ()															' new regBase is toes
		IF new_data THEN															' null array
			IF (new_data{$$NUMBER} != regBase) THEN GOTO eeeCompiler
		END IF
		RETURN
	END IF
'
'	imbedded array
'
	IF (theType = $$STRING) THEN
		aSize = typeEleStringSize[inType, i]
	ELSE
		aSize = typeSize[theType]				' size of element in array (aligned)
	END IF
'	IF (aSize > 65535) THEN GOTO eeeOverflow
	token = NextToken ()
	IF (token <> T_LBRAK) THEN PRINT "ccc5": GOTO eeeComponent
	arrayUBound = typeEleUBound[inType, i]
'
' 	fixedArray [expression]
'
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
		END IF
	ELSE
		IF varToken THEN												' base not in acc yet
			regIndex = Top ()											' expression in acc
		ELSE
			IF (toes <= 1) THEN GOTO eeeSyntax		' expression and base in acc
			Topaccs (@regIndex, @regBase)
		END IF
		regOffset = regIndex
	END IF
'
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
		END IF
		varToken = 0
	END IF
'
	IF new_data THEN							' simple, no expression on stack
		newRegBase = regBase				' use old regBase
	ELSE													' remove expression from stack
		newRegBase = $$eax					' combine TOS + TOS-1 into r10
		DEC toes										' Free r12
		a1 = 0
		a1_type = 0
		a0 = toes
		a0_type = $$XLONG
	END IF
'
'	Bounds Check
'
	IF checkBounds THEN
		INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
		Code ($$mov, $$regimm, $$ecx, arrayUBound, 0, $$XLONG, "", @"### 384")
		Code ($$cmp, $$regreg, $$ecx, regIndex, 0, $$XLONG, "", @"### 385")
		Code ($$jge, $$rel, 0, 0, 0, 0, d1$, @"### 386")
		Code ($$mov, $$regreg, $$ecx, sreg, 0, $$XLONG, "", @"### 387")
		Code ($$xor, $$regreg, regIndex, regIndex, 0, $$XLONG, "", @"### 388")
		Code ($$call, $$rel, 0, 0, 0, 0, "__OutOfBounds", @"### 389")
		EmitLabel (@d1$)
	END IF
'
	IF (aSize = 1) THEN
		regOffset = regIndex										' skipit:  multiplier is 1
	ELSE
		IF (regOffset != regIndex) THEN
			Code ($$mov, $$regreg, regOffset, regIndex, 0, $$XLONG, "", @"### 390")
		END IF
		IF (aSize <= 1024) THEN ashift = shiftMulti [aSize]
		IF ashift THEN
			Code ($$sll, $$regimm, regOffset, ashift, 0, $$XLONG, "", @"### 391")
		ELSE
			Code ($$imul, $$regimm, regOffset, aSize, 0, $$XLONG, "", @"### 392")
		END IF
	END IF
'
	Code ($$lea, $$regrr, newRegBase, sreg, regOffset, $$XLONG, "", @"### 393")
	regBase = newRegBase			' updated base pointer
	RETURN
'
SUB CheckForLiteral
	gotLiteral = $$FALSE
	SELECT CASE new_data{$$KIND}
		CASE $$KIND_LITERALS
			tt = new_data{$$NUMBER}
			arrayIndex = XLONG (tab_sym$[tt])		' literals may not be in r_addr yet
			IF (arrayIndex > arrayUBound) THEN
				GOTO eeeOverflow
			END IF
			offset = offset + arrayIndex * aSize
			gotLiteral = $$TRUE
		CASE $$KIND_CONSTANTS, $$KIND_SYSCONS
			tt = new_data{$$NUMBER}
			arrayIndex = XLONG (r_addr$[tt])
			IF (arrayIndex > arrayUBound) THEN
				GOTO eeeOverflow
			END IF
			offset = offset + arrayIndex * aSize
			gotLiteral = $$TRUE
	END SELECT
END SUB
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  Composite ()  #####
' ##########################
'
' *****  INPUT  *****				*****  RETURN VALUES  *****
'
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
'
' Notes:
'		subComposite == a composite expression including sub-element references
'   varComposite == a composite variable/array without sub-element references
'
'		Destination:  GETADDR invalid for varComposites/subComposites
'									GETHANDLE invalid for varComposites
'									GETHANDLE valid only for pointer sub-elements (to allow
'											assigning address to pointer)
'		Source:				(Composite() not called for source addr_ops on varComposites)
'					  			GETADDR valid for subComposites
'						 			GETHANDLE valid for pointer sub-elements in subComposites
'
'		NOTE:  error generated if theOffset > 65535
'
FUNCTION  Composite (command, theType, theReg, theOffset, theLength)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	XERROR,  ERROR_COMPONENT,  ERROR_COMPILER
	SHARED	ERROR_OVERFLOW,  ERROR_SYNTAX
	SHARED	T_ADDR_OP,  T_HANDLE_OP,  T_LBRAK,  T_RBRAK
	SHARED	r_addr[],  typeSize[],  reg86$[],  reg86c$[]
	SHARED	tab_sym$[],  r_addr$[]
	SHARED	toes,  a0,  a0_type,  a1,  a1_type
	SHARED	oos,  dim_array,  tokenPtr
	SHARED	preType
	SHARED UBYTE oos[]
'
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
	END IF
	theOffset	= 0
	check			= PeekToken ()
'
	IF (varToken{$$KIND} = $$KIND_ARRAYS) THEN
		IF dim_array THEN GOTO eeeSyntax
		new_data	= varToken
		new_type	= theType
		accArray	= $$FALSE
		node			= $$FALSE
'
' new_op and new_prec added below
'
		SELECT CASE command
			CASE $$GETHANDLE:		new_op = T_HANDLE_OP:	new_prec = $$PREC_ADDR_OP
			CASE $$GETADDR:			new_op = T_ADDR_OP:		new_prec = $$PREC_ADDR_OP
			CASE $$GETDATAADDR:	new_op = T_ADDR_OP:		new_prec = $$PREC_ADDR_OP
			CASE $$GETDATA:			new_op = 0:						new_prec = 0
		END SELECT
'
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
		END IF
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
				END IF
		END SELECT
	END IF
	preType = theType
'
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
'
' Make sure base address is in a register
'		Note:  haveData can only be true with pointers...
'
	IFZ varToken THEN							' base moved to regBase register (ptr or [x])
		theReg	= regBase														' theReg = base & destination
		SELECT CASE command													' address or data ???
			CASE $$GETDATA														' data requested
				command = 1															' one thing stacked
				IF haveData THEN												'
					IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
					RETURN																' ExpressArray got data
				END IF
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
					END IF
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
					IF haveData THEN											'
						IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
						RETURN															' ExpressArray got data
					END IF																'
				CASE ELSE																' address requested
					command	= 1														' one thing stacked
					IFZ theLength THEN theLength = typeSize[theType]	' ??? xx2m ???
					RETURN
			END SELECT
		END IF
	END IF
'
'
' *******************************
' *****  WANT DATA ELEMENT  *****
' *******************************
'
' regBase		= base address register
' theOffset	= offset from base address to data
' theReg		= register to contain data
'	theType		= data type of the component (simple or composite)
'
'
' *****  SIMPLE TYPE  *****  copy fixed string into native string
'
	IF (theType < $$SCOMPLEX) THEN
		IF (theType = $$STRING) THEN
			Code ($$lea, $$regro, theReg, regBase, theOffset, $$XLONG, "", @"### 394")
			Code ($$mov, $$regreg, $$esi, theReg, 0, $$XLONG, "", @"### 395")
			Code ($$mov, $$regimm, $$edi, theLength, 0, $$XLONG, "", @"### 396")
'			Code ($$call, $$rel, 0, 0, 0, 0, "__ByteMakeCopy", @"### 397")
			Code ($$call, $$rel, 0, 0, 0, 0, "__CompositeStringToString", @"### 397")
			Code ($$mov, $$regreg, theReg, $$esi, 0, $$XLONG, "", @"### 398")
			INC oos
			oos[oos] = 's'
		ELSE
			IF ((theType = $$SINGLE) OR (theType = $$DOUBLE)) THEN
				Code ($$fld, $$ro, theReg, regBase, theOffset, theType, "", @"### 399")
			ELSE
				Code ($$ld, $$regro, theReg, regBase, theOffset, theType, "", @"### 400")
			END IF
		END IF
		IF (theType < $$SLONG) THEN theType = $$SLONG
		SELECT CASE theReg
			CASE $$RA0	:	a0_type = theType
			CASE $$RA1	: a1_type = theType
			CASE ELSE		:	PRINT "cdrx" : GOTO eeeCompiler
		END SELECT
		theOffset = 0
		RETURN
	END IF
'
' *****  COMPOSITE TYPE  *****
'
	IF (theReg = regBase) THEN
		IFZ theOffset THEN RETURN
	END IF
	Code ($$lea, $$regro, theReg, regBase, theOffset, $$XLONG, "", @"### 401")
	theOffset = 0
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
END FUNCTION
'
'
' #####################
' #####  Conv ()  #####
' #####################
'
FUNCTION  Conv (destin, to_type, source, from_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
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
	STATIC GOADDR  convToTypes[]
'
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
		GOSUB LoadConvToTypes
	END IF
'
	tt = to_type
	ft = from_type
	IF (ft < $$SLONG) THEN ft = $$SLONG
	IFZ tt THEN tt = ft
	d_reg   = Reg (destin)
	d_regx  = d_reg + 1
	IFZ d_reg THEN PRINT "conv1": GOTO eeeCompiler
	IF (d_reg = $$RA0) THEN a0_type = tt
	IF (d_reg = $$RA1) THEN a1_type = tt
'
cs:
	s_reg   = Reg (source)
	s_regx  = s_reg + 1
	IFZ s_reg THEN PRINT "conv2": GOTO eeeCompiler
	IF (tt = ft) THEN
		IF (d_reg = s_reg) THEN RETURN
		Move (d_reg, tt, source, ft)
		EXIT FUNCTION
	END IF
	IF ((tt >= $$SCOMPLEX) OR (ft >= $$SCOMPLEX)) THEN GOTO eeeTypeMismatch
'
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
			END IF
		ELSE
			Move (d_reg, ft, source, ft)
			s_reg   = d_reg
			s_regx  = d_regx
			s_reg$  = d_reg$
			s_regx$ = d_regx$
		END IF
	END IF
'
' *****  Dispatch to routine to convert to type "tt"  *****
'
	GOTO @convToType[tt]
	PRINT "conv3"
	GOTO eeeCompiler
'
'
' **************************************************************
' *****  Emit code to convert from type "ft" to type "tt"  *****
' **************************************************************
'
' ********************************
' *****  to SBYTE from "tt"  *****
' ********************************
'
tt2:
	GOTO @convToType2[ft]
	PRINT "conv4"
	GOTO eeeCompiler
'
'
' *****  to SBYTE from SLONG  *****
'
tt2ft6:
tt2ft8:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 402")
	Code ($$sar, $$regimm, $$esi, 7, 0, $$XLONG, "", @"### 403")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 404")
	Code ($$not, $$reg, $$esi, 0, 0, $$XLONG, "", @"### 405")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 406")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 407")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SBYTE from ULONG  *****
'
tt2ft7:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 408")
	Code ($$sar, $$regimm, $$esi, 7, 0, $$XLONG, "", @"### 409")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 410")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 411")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SBYTE from SINGLE  *****
'
tt2ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 412")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 413")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt2ft6
'
' *****  to SBYTE from DOUBLE  *****
'
tt2ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 414")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 415")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt2ft6
'
' *****  to SBYTE from GIANT  *****
'
tt2fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	GOTO tt2ft6
'
'
' ********************************
' *****  to UBYTE from "tt"  *****
' ********************************
'
tt3:
	GOTO @convToType3[ft]
	PRINT "conv5"
	GOTO eeeCompiler
'
' *****  to UBYTE from SLONG
' *****  to UBYTE from ULONG
'
tt3ft6:
tt3ft7:
tt3ft8:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 416")
	Code ($$sar, $$regimm, $$esi, 8, 0, $$XLONG, "", @"### 417")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 418")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 419")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to UBYTE from SINGLE  *****
'
tt3ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 420")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 421")
	ft		= $$SLONG
	s_reg	= d_reg
	GOTO tt3ft6
'
' *****  to UBYTE from DOUBLE  *****
'
tt3ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 422")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 423")
	ft		= $$SLONG
	s_reg	= d_reg
	GOTO tt3ft6
'
' *****  to UBYTE from GIANT  *****
'
tt3fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	s_reg$ = d_reg$
	GOTO tt3ft6
'
'
' *********************************
' *****  to SSHORT from "tt"  *****
' *********************************
'
tt4:
	GOTO @convToType4[ft]
	PRINT "conv6"
	GOTO eeeCompiler
'
tt4ft6:
tt4ft8:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 424")
	Code ($$sar, $$regimm, $$esi, 15, 0, $$XLONG, "", @"### 425")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 426")
	Code ($$not, $$reg, $$esi, 0, 0, $$XLONG, "", @"### 427")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 428")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 429")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SSHORT from ULONG  *****
'
tt4ft7:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 430")
	Code ($$sar, $$regimm, $$esi, 15, 0, $$XLONG, "", @"### 431")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 432")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 433")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SSHORT from SINGLE  *****
'
tt4ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 434")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 435")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt4
'
' *****  to SSHORT from DOUBLE  *****
'
tt4ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 436")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 437")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt4
'
' *****  to SSHORT from GIANT  *****
'
tt4fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	GOTO tt4
'
'
' *********************************
' *****  to USHORT from "tt"  *****
' *********************************
'
tt5:
	GOTO @convToType5[ft]
	PRINT "conv7"
	GOTO eeeCompiler
'
' *****  to USHORT from SLONG  *****
' *****  to USHORT from ULONG  *****
' *****  to USHORT from XLONG  *****
'
tt5ft6:
tt5ft7:
tt5ft8:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 438")
	Code ($$sar, $$regimm, $$esi, 16, 0, $$XLONG, "", @"### 439")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 440")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 441")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
'
' *****  to USHORT from SINGLE  *****
'
tt5ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 442")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 443")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt5
'
' *****  to USHORT from DOUBLE  *****
'
tt5ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 444")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 445")
	ft = $$SLONG
	s_reg = d_reg
	GOTO tt5
'
' *****  to USHORT from GIANT  *****
'
tt5fte:
	GOSUB cv_giant_to_slong
	ft = $$SLONG
	s_reg  = d_reg
	GOTO tt5
'
'
' ********************************
' *****  to SLONG from "tt"  *****
' ********************************
'
tt6:
	GOTO @convToType6[ft]
	PRINT "conv8"
	GOTO eeeCompiler
'
' *****  to SLONG from SLONG  *****
'
tt6ft6:
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SLONG from ULONG  *****
'
tt6ft7:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$or, $$regreg, s_reg, s_reg, 0, $$XLONG, "", @"### 446")
	Code ($$jns, $$rel, 0, 0, 0, 0, d1$, @"### 447")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 448")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SLONG from XLONG  *****
'
tt6ft8:
	Move(d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to SLONG from SINGLE  *****
'
tt6ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 449")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 450")
	RETURN
'
' *****  to SLONG from DOUBLE  *****
'
tt6ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 451")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 452")
	RETURN
'
' *****  to SLONG from GIANT  *****
'
tt6fte:
	GOSUB cv_giant_to_slong
	RETURN
'
'
' ********************************
' *****  to ULONG from "tt"  *****
' ********************************
'
tt7:
	GOTO @convToType7[ft]
	PRINT "conv9"
	GOTO eeeCompiler
'
' *****  to ULONG from SLONG  *****
'
tt7ft6:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$or, $$regreg, s_reg, s_reg, 0, $$XLONG, "", @"### 453")
	Code ($$jns, $$rel, 0, 0, 0, 0, d1$, @"### 454")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 455")
	EmitLabel (@d1$)
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to ULONG from ULONG  *****
' *****  to ULONG from XLONG  *****
'
tt7ft7:
tt7ft8:
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to ULONG from SINGLE  *****
'
tt7ftc:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 456")
	Code ($$ld, $$regro, d_reg, $$ebp, -4, $$XLONG, "", @"### 457")
	Code ($$or, $$regreg, d_reg, d_reg, 0, $$XLONG, "", @"### 458")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 459")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 460")
	EmitLabel (@d1$)
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 461")
	RETURN
'
' *****  to ULONG from DOUBLE  *****
'
tt7ftd:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 462")
	Code ($$ld, $$regro, d_reg, $$ebp, -4, $$XLONG, "", @"### 463")
	Code ($$or, $$regreg, d_reg, d_reg, 0, $$XLONG, "", @"### 464")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 465")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 466")
	EmitLabel (@d1$)
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 467")
	RETURN
'
' *****  to ULONG from GIANT  *****
'
tt7fte:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$or, $$regreg, s_regx, s_regx, 0, $$XLONG, "", @"### 468")
	Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, "", @"### 469")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 470")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 471")
	EmitLabel (@d1$)
	RETURN
'
'
' ********************************
' *****  to XLONG from "tt"  *****
' ********************************
'
tt8:
	GOTO @convToType8[ft]
	PRINT "conv10"
	GOTO eeeCompiler
'
' *****  to XLONG from SLONG  *****
' *****  to XLONG from ULONG  *****
' *****  to XLONG from XLONG  *****
' *****  to XLONG from GOADDR  *****
' *****  to XLONG from SUBADDR  *****
' *****  to XLONG from FUNCADDR  *****
'
tt8ft6:
tt8ft7:
tt8ft8:
tt8ft9:
tt8fta:
tt8ftb:
	Move (d_reg, ft, s_reg, ft)
	RETURN
'
' *****  to XLONG from SINGLE  *****
'
tt8ftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 472")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 473")
	RETURN
'
' *****  to XLONG from DOUBLE  *****
'
tt8ftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 474")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 475")
	RETURN
'
' *****  to XLONG from GIANT  *****
'
tt8fte:
	GOSUB cv_giant_to_slong
	RETURN
'
'
' *********************************
' *****  to GOADDR from "tt"  *****
' *********************************
'
tt9:
	GOTO @convToType9[ft]
	PRINT "conv11"
	GOTO eeeCompiler
'
' *****  to GOADDR from XLONG  *****
'
tt9ft8:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
' *****  to GOADDR from GOADDR  *****
'
tt9ft9:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
'
' **********************************
' *****  to SUBADDR from "tt"  *****
' **********************************
'
tta:
	GOTO @convToTypea[ft]
	PRINT "conv12"
	GOTO eeeCompiler
'
' *****  to SUBADDR from XLONG  *****
'
ttaft8:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
' *****  to SUBADDR from SUBADDR  *****
'
ttafta:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
'
' ***********************************
' *****  to FUNCADDR from "tt"  *****
' ***********************************
'
ttb:
	GOTO @convToTypeb[ft]
	PRINT "conv13"
	GOTO eeeCompiler
'
' *****  to FUNCADDR from XLONG  *****
'
ttbft8:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
' *****  to FUNCADDR from FUNCADDR  *****
'
ttbftb:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
'
' *********************************
' *****  to SINGLE from "tt"  *****
' *********************************
'
ttc:
	GOTO @convToTypec[ft]
	PRINT "conv14"
	GOTO eeeCompiler
'
' *****  to SINGLE from SLONG  *****
' *****  to SINGLE from XLONG  *****
'
ttcft6:
ttcft8:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, "", @"### 476")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$SLONG, "", @"### 477")
	RETURN
'
' *****  to SINGLE from ULONG  *****
'
ttcft7:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, "", @"### 478")
	Code ($$st, $$roimm, 0, $$ebp, -4, $$XLONG, "", @"### 479")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 480")
	EmitLabel (@d1$)
	RETURN
'
'	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
'	Code ($$st, $$roimm, 0, $$ebp, -8, $$XLONG, "", @"### 478")
'	Code ($$st, $$roreg, s_reg, $$ebp, -4, $$XLONG, "", @"### 479")
'	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 480")
'	EmitLabel (@d1$)
'	RETURN
'
' *****  to SINGLE from SINGLE  *****
'
ttcftc:
	Move (d_reg, tt, s_reg, tt)
	RETURN
'
' *****  to SINGLE from DOUBLE  *****
'
ttcftd:
	RETURN
'
' *****  to SINGLE from GIANT  *****
'
ttcfte:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, "", @"### 481")
	Code ($$st, $$roreg, s_regx, $$ebp, -4, $$XLONG, "", @"### 482")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 483")
	RETURN
'
'
' *********************************
' *****  to DOUBLE from "tt"  *****
' *********************************
'
ttd:
	GOTO @convToTyped[ft]
	PRINT "conv15"
	GOTO eeeCompiler
'
' *****  to DOUBLE from SLONG  *****
' *****  to DOUBLE from XLONG  *****
'
ttdft6:
ttdft8:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, "", @"### 484")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$XLONG, "", @"### 485")
	RETURN
'
' *****  to DOUBLE from ULONG  *****
'
ttdft7:
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$st, $$roimm, 0, $$ebp, -4, $$XLONG, "", @"### 486")
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, "", @"### 487")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 488")
	EmitLabel (@d1$)
	RETURN
'
' *****  to DOUBLE from SINGLE  *****
'
ttdftc:
	RETURN
'
' *****  to DOUBLE from DOUBLE  *****
'
ttdftd:
	RETURN
'
' *****  to DOUBLE from GIANT  *****
'
ttdfte:
	Code ($$st, $$roreg, s_reg, $$ebp, -8, $$XLONG, "", @"### 489")
	Code ($$st, $$roreg, s_regx, $$ebp, -4, $$XLONG, "", @"### 490")
	Code ($$fild, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 491")
	RETURN
'
'
' ********************************
' *****  to GIANT from "tt"  *****
' ********************************
'
tte:
	GOTO @convToTypee[ft]
	PRINT "conv16"
	GOTO eeeCompiler
'
' *****  to GIANT from SLONG  *****
' *****  to GIANT from XLONG  *****
'
tteft6:
tteft8:
	IF (d_reg != s_reg) THEN Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, "", @"### 492")
	IF (d_regx != s_reg) THEN Code ($$mov, $$regreg, d_regx, s_reg, 0, $$XLONG, "", @"### 493")
	Code ($$sar, $$regimm, d_regx, 31, 0, $$XLONG, "", @"### 494")
	RETURN
'
' *****  to GIANT from ULONG  *****
'
tteft7:
	IF (d_reg != s_reg) THEN Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, "", @"### 495")
	Code ($$xor, $$regreg, d_regx, d_regx, 0, $$XLONG, "", @"### 496")
	RETURN
'
' *****  to GIANT from SINGLE  *****
'
tteftc:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 497")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 498")
	Code ($$ld, $$regro, d_regx, $$ebp, -4, $$XLONG, "", @"### 499")
	RETURN
'
' *****  to GIANT from DOUBLE  *****
'
tteftd:
	Code ($$fistp, $$ro, 0, $$ebp, -8, $$GIANT, "", @"### 500")
	Code ($$ld, $$regro, d_reg, $$ebp, -8, $$XLONG, "", @"### 501")
	Code ($$ld, $$regro, d_regx, $$ebp, -4, $$XLONG, "", @"### 502")
	RETURN
'
'	*****  to GIANT from GIANT  *****
'
ttefte:
	IF (d_reg != s_reg) THEN Move (d_reg, $$GIANT, s_reg, $$GIANT)
	RETURN
'
'
' *********************************
' *****  to STRING from "tt"  *****
' *********************************
'
tts:
	GOTO @convToTypes[ft]
	PRINT "conv17"
	GOTO eeeCompiler
'
ttsfts:
	Move (d_reg, $$STRING, s_reg, $$STRING)
	RETURN
'
'
' *****************************************
' *****  TYPE CONVERSION SUBROUTINES  *****
' *****************************************
'
' *****  GIANT  to  SLONG  *****  subroutine used by several other conversions
'
SUB  cv_giant_to_slong
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
	IF (d_reg != s_reg) THEN Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, "", "### i416")
	Code ($$or, $$regreg, s_reg, s_reg, 0, $$XLONG, "", @"### i417")
	Code ($$jns, $$rel, 0, 0, 0, 0, @d1$, @"### i418")
	Code ($$not, $$reg, s_regx, 0, 0, $$XLONG, "", @"### i419")
	EmitLabel (@d1$)
	Code ($$or, $$regreg, s_regx, s_regx, 0, $$XLONG, "", @"### i420")
	Code ($$jz, $$rel, 0, 0, 0, 0, @d2$, @"### i421a")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### i421b")
	EmitLabel (@d2$)
END SUB
'
'
'
' *****************************************************
' *****  Load conversion from/to dispatch arrays  *****
' *****************************************************
'
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
	convToType [ $$STRING		] = GOADDRESS (tts)
END SUB
'
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
	convToType2 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType3 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType4 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType5 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType6 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType7 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType8 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToType9 [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToTypea [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToTypeb [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToTypec [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToTyped [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToTypee [ $$STRING		] = GOADDRESS (eeeTypeMismatch)
END SUB
'
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
	convToTypes [ $$STRING		] = GOADDRESS (ttsfts)
END SUB
'
'
'
'  *******************************
'  *****  CONVERSION ERRORS  *****
'  *******************************
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
'
eeeVoid:
	XERROR = ERROR_VOID
	EXIT FUNCTION
END FUNCTION
'
'
' ###########################
' #####  Deallocate ()  #####
' ###########################
'
FUNCTION  Deallocate (token)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	m_addr[]
'
	IFZ m_addr[token{$$NUMBER}] THEN RETURN
	otype	= TheType (token)
	kind	= token{$$KIND}
	SELECT CASE kind
		CASE $$KIND_VARIABLES, $$KIND_CONSTANTS
			Move ($$esi, otype, token, otype)
			Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 509")
			Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, "", @"### 510")
			Move (token, $$XLONG, $$edx, $$XLONG)
		CASE $$KIND_ARRAYS
			Move ($$esi, $$XLONG, token, $$XLONG)
			Code ($$call, $$rel, 0, 0, 0, 0, "__FreeArray", @"### 511")
			Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, "", @"### 512")
			Move (token, $$XLONG, $$edx, $$XLONG)
		CASE ELSE
			PRINT "dd1"
			GOTO eeeCompiler
	END SELECT
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ########################
' #####  EmitAsm ()  #####
' ########################
'
FUNCTION  EmitAsm (line$)
	EXTERNAL /xxx/  i486asm, i486bin
	SHARED	ofile
'
' #emitasm = 0	' flush buffer
' #emitasm = 1	' buffer assembly
' #emitasm = 2	' emit this now - leave buffer intact
'
	IF i486asm THEN
		emitasm = #emitasm
		IF #immediatemode THEN emitasm = 2
		SELECT CASE emitasm
			CASE 0	:	GOSUB FlushBuffer
			CASE 1	:	GOSUB BufferAssembly
			CASE 2	:	PRINT [ofile], line$
		END SELECT
	END IF
	RETURN
'
'
' *****  FlushBuffer  *****
'
SUB FlushBuffer
	IF #asm$[] THEN
		IF (#asmnext > 0) THEN
			FOR line = 0 TO #asmnext-1
				PRINT [ofile], #asm$[line]
			NEXT line
		END IF
	END IF
'
	PRINT [ofile], line$
'
	#asmupper = -1
	#asmnext = 0
	DIM #asm$[]
END SUB
'
'
' *****  BufferAssembly  *****
'
SUB BufferAssembly
	IFZ #asm$[] THEN
		#asmnext = 0
		#asmupper = 4095
		DIM #asm$[#asmupper]
	END IF
'
	IF (#asmnext > #asmupper) THEN
		#asmupper = #asmupper + 4096
		REDIM #asm$[#asmupper]
	END IF
'
	#asm$[#asmnext] = line$
	INC #asmnext
END SUB
END FUNCTION
'
'
' #########################
' #####  Deparse$ ()  #####
' #########################
'
' charpos[] = character position of tokens, 0 offset
'
FUNCTION  Deparse$ (prefix$)
	SHARED	charpos[],  tokens[]
	SHARED	funcSymbol$[],  tab_lab$[],  tab_sym$[],  tab_sys$[]
	SHARED	typeSymbol$[]
	SHARED	ERROR_COMPILER,  XERROR,  tokenCount,  tokenPtr
	STATIC SUBADDR  kindDeparse[]
'
	IFZ kindDeparse[] THEN GOSUB LoadKindDeparse
'
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
		END IF
		GOSUB @kindDeparse [kind]				' dispatch deparse based on kind of token
		IF (tokenPtr < 255) THEN charpos[tokenPtr + 1] = LEN(deparsed$)
	LOOP
	IF (tokenPtr < 254) THEN charpos[tokenPtr + 2] = 0
	RETURN (deparsed$)
'
'
' ****************************************************************
' *****  Subroutines to deparse different "kinds" of tokens  *****
' ****************************************************************
'
SUB SystemSymbols
	deparsed$ = deparsed$ + tab_sys$[tt] + CHR$ (whiteChar, spaces)
END SUB
'
SUB UserSymbols
	deparsed$ = deparsed$ + tab_sym$[tt] + CHR$ (whiteChar, spaces)
END SUB
'
SUB FunctionSymbols
	deparsed$ = deparsed$ + funcSymbol$[tt] + CHR$ (whiteChar, spaces)
END SUB
'
SUB UserLabels
	s$ = MID$ (tab_lab$[tt], 4)
'	suffix = RINSTR (s$, ".")										' gas ?
	suffix = RINSTR (s$, "_")										' unspas
	s$ = LEFT$ (s$, suffix - 1)
	IF (tokenPtr = 1) THEN s$ = s$ + ":"
	deparsed$ = deparsed$ + s$ + CHR$ (whiteChar, spaces)
END SUB
'
SUB SystemStarts
	errorIndex = token {$$BYTE1}												' errno is BYTE1
	IF errorIndex THEN
		deparsed$ = deparsed$ + RIGHT$ ("000" + STRING(errorIndex), 3)
	END IF
	IF EXTS(token, 1, 30) THEN deparsed$ = deparsed$ + ">"	' $$CURRENTEXE
	IF (token < 0) THEN deparsed$ = deparsed$ + ":"					' $$BREAKPOINT
	spaces = token{{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			deparsed$ = deparsed$ + SPACE$ (spaces)			' spaces
		ELSE
			deparsed$ = deparsed$ + CHR$ (9, -spaces)		' tabs
		END IF
	END IF
END SUB
'
SUB SystemWhites
	spaces = token{{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			deparsed$ = deparsed$ + SPACE$(spaces)				' spaces
		ELSE
			deparsed$ = deparsed$ + CHR$ (9, -spaces)		' tabs
	END IF
	END IF
END SUB
'
SUB SystemComments
	count = token {$$BYTE2}
	IF (count = 255) THEN
		INC tokenPtr
		count = tokens[tokenPtr]
	END IF
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
'
SUB UserTypes
	deparsed$ = deparsed$ + typeSymbol$[tt] + CHR$ (whiteChar, spaces)
END SUB
'
SUB BogusToken
	PRINT "*****  DEPARSE:  BOGUS TOKEN  *****"
END SUB
'
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
END SUB
END FUNCTION
'
'
' #########################
' #####  EmitData ()  #####
' #########################
'
FUNCTION  EmitData()
	EXTERNAL /xxx/  i486asm, i486bin
	SHARED	ofile
'
	IF i486asm THEN
'		PRINT [ofile], ".data"
		EmitAsm (".data")
	END IF
END FUNCTION
'
'
' ##################################
' #####  EmitFunctionLabel ()  #####
' ##################################
'
FUNCTION  EmitFunctionLabel (label$)
	EXTERNAL /xxx/  i486asm,  i486bin,  xpc
	SHARED	ofile
	SHARED  labaddr[]
	SHARED  XERROR,  ERROR_DUP_LABEL
	SHARED  func_number
'
	token = AddLabel (@label$, $$T_LABELS, $$XNEW)
	IF XERROR THEN EXIT FUNCTION
	SELECT CASE TRUE
		CASE i486bin	: IF XERROR THEN EXIT FUNCTION
										tt = token{$$NUMBER}
										qpc = labaddr[tt]
										IF qpc THEN GOTO eeeDupLabel
										labaddr[tt] = xpc
		CASE i486asm	:	' PRINT [ofile], label$ + ":"
										EmitAsm (label$ + ":")
	END SELECT
	RETURN
'
eeeDupLabel:
	PRINT "Duplicate Label = "; label$
	XERROR = ERROR_DUP_LABEL
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  EmitLabel ()  #####
' ##########################
'
FUNCTION  EmitLabel (label$)
	EXTERNAL /xxx/	i486bin,  i486asm,  xpc
	SHARED  ofile
	SHARED  labaddr[]
	SHARED  XERROR,  ERROR_DUP_LABEL
	SHARED  func_number
'
	token = AddLabel (@label$, $$T_LABELS, $$XADD)
	IF XERROR THEN EXIT FUNCTION
	SELECT CASE TRUE
		CASE i486bin	: IF XERROR THEN EXIT FUNCTION
										tt = token{$$NUMBER}
										qpc = labaddr[tt]
										IF qpc THEN GOTO eeeDupLabel
										labaddr[tt] = xpc
		CASE i486asm	: ' PRINT [ofile], label$ + ":"
										EmitAsm (label$ + ":")
	END SELECT
	RETURN
'
eeeDupLabel:
	PRINT "Duplicate Label = "; label$
	XERROR = ERROR_DUP_LABEL
	EXIT FUNCTION
END FUNCTION
'
'
' #########################
' #####  EmitLine ()  #####
' #########################
'
' Put address of line number in line address array and emit a line number
' symbol into the source text.
'
FUNCTION  EmitLine (lnum)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc,  library
	SHARED	ofile,  xit,  XERROR
	STATIC  linefile		'DEBUG
'
	SELECT CASE TRUE
		CASE i486bin:		'	GOSUB EmitLineBin			'DEBUG
		CASE i486asm:			GOSUB EmitLineAsm
	END SELECT
	RETURN
'
SUB EmitLineAsm
	SELECT CASE TRUE
		CASE xit			: label$ = "aaaa" + STRING$ (lnum)
		CASE library	: label$ = "llll" + STRING$ (lnum)
		CASE ELSE			: label$ = "xxxx" + STRING$ (lnum)
	END SELECT
'
	IF label$ THEN
'		PRINT [ofile], label$ + ":"
'		PRINT [ofile], ".globl	" + label$
		EmitAsm (label$ + ":")
		EmitAsm (".globl	" + label$)
	END IF
END SUB
'
SUB EmitLineBin																						' DEBUG
	IFZ linefile THEN																				' DEBUG
		linefile = OPEN ("lines", $$WRNEW)										' DEBUG
		PRINT "linefile = " linefile "    XERROR = " XERROR		' DEBUG
	END IF																									' DEBUG
	PRINT [linefile], lnum; ": "; HEXX$(xpc, 8)							' DEBUG
END SUB																										' DEBUG
END FUNCTION
'
'
' #########################
' #####  EmitNull ()  #####
' #########################
'
FUNCTION  EmitNull (nullAsm$)
	EXTERNAL /xxx/	i486bin, i486asm
	SHARED  ofile
'
	IF i486asm THEN
'		PRINT [ofile], nullAsm$
		EmitAsm (nullAsm$)
	END IF
END FUNCTION
'
'
' ###########################
' #####  EmitString ()  #####
' ###########################
'
FUNCTION  EmitString (theLabel$, theString$)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	xit
'
	IF (INSTR(theString$, "\\")) THEN
		theString$ = XstBackStringToBinString$ (@theString$)
	END IF
'
	SELECT CASE TRUE
		CASE i486bin
			xpc = (xpc + 16) & 0xFFFFFFF0
			litlen = LEN(theString$)
			litall = (litlen + 16) & 0xFFFFFFF0
			litpad = litall - litlen
			litall$ = theString$ + NULL$(litpad)
			aaa = &litall$
			chunk = litall + 16
			XLONGAT(xpc) = chunk			: xpc = xpc + 4		' size of chunk
			XLONGAT(xpc) = 0					: xpc = xpc + 4		' unknown backlink
			XLONGAT(xpc) = litlen			: xpc = xpc + 4		' length of string
			XLONGAT(xpc) = 0x80130001	: xpc = xpc + 4		' info word
			IFZ xit THEN EmitLabel (@theLabel$)
			i = 0
			DO WHILE i < litall
				XLONGAT(xpc) = XLONGAT(aaa)
				xpc = xpc + 4
				aaa = aaa + 4
				i = i + 4
			LOOP
		CASE i486asm								' different in SCO vs Linux because of assembler differences
			litlen = LEN (theString$)
			asmString$ = BinStringToAsmString$ (@theString$)
			asmlen			= LEN (asmString$)
			pad					= ((litlen + 16) AND 0xFFFFFFF0) - litlen
			chunk				= (litlen + 32) AND 0xFFFFFFF0
'			e$					= ".dword	" + STRING (chunk) + ", 0, " + STRING (litlen)			' spasm
			e$					= ".long	" + STRING (chunk) + ", 0, " + STRING (litlen)			' gas ?
			EmitNull (e$ + ", 0x80130001")
			EmitLabel (@theLabel$)
'			IF (asmlen <= 128) THEN
'				EmitNull (".byte	\"" + asmString$ + "\"")															' spasm
				EmitNull (".string	\"" + asmString$ + "\"")														' gas ?
'			ELSE
'				offset = 1
'				DO
'					length = 32
'					IF (litlen < length) THEN length = litlen
'					piece$ = MID$ (theString$, offset, length)
'					asmString$ = BinStringToAsmString$ (@piece$)
'					EmitNull (".byte	\"" + asmString$ + "\"")														' spasm
'					EmitNull (".string	\"" + asmString$ + "\"")													' gas ?
'					litlen = litlen - length
'					offset = offset + length
'				LOOP WHILE litlen
'			END IF
'
' asshole Linux assembler puts a 0x00 after every ".string" string,
' which is a MAJOR pain in the butt.
'
' First of all it means you can't emit strings in several lines because
' the frigging 0x00 bytes get into the string and the last bytes in the
' strings are not included because the 0x00 bytes are part of the length.
' Second, the pad value is bad so it has to be adjusted below.
'
			DEC pad
			IF pad THEN EmitNull (".zero	" + STRING$(pad))
	END SELECT
END FUNCTION
'
'
' #########################
' #####  EmitText ()  #####
' #########################
'
FUNCTION  EmitText()
	EXTERNAL /xxx/  i486bin, i486asm
	SHARED	ofile
'
	IF i486asm THEN
'		PRINT [ofile], ".text"
		EmitAsm (".text")
	END IF
END FUNCTION
'
'
' ##############################
' #####  EmitUserLabel ()  #####
' ##############################
'
' bin:  Put address of the label in labaddr[tt] where tt is the label
' token number.  The address is the current value of "xpc".  If labaddr[tt]
' has a value already, the label is a duplicate, which is an error.
'
' asm:  Emit user program (GOTO or GOSUB) label into ascii source .s file.
'
' EmitUserLabel() is for user labels, not internal labels (see EmitLabel()).
' User Labels are GOTO labels and GOSUB labels (also function() labels ???).
'
FUNCTION  EmitUserLabel (labelToken)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	labaddr[],  tab_lab$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_LABEL
	SHARED	ofile,  func_number
'
	SELECT CASE TRUE
		CASE i486bin: ltype	= labelToken{$$TYPE}
									SELECT CASE ltype
										CASE $$GOADDR, $$SUBADDR
										CASE ELSE:		PRINT "eul0": GOTO eeeCompiler
									END SELECT
									tt		= labelToken{$$NUMBER}
									qpc		= labaddr[tt]
									IF qpc THEN GOTO eeeDupLabel
									labaddr[tt]	= xpc
		CASE i486asm: ltype	= labelToken{$$TYPE}
									tt		= labelToken{$$NUMBER}
									qpc		= labaddr[tt]
									IF qpc THEN GOTO eeeDupLabel
									labaddr[tt]		= $$TRUE
									tt$		= tab_lab$[tt]
									SELECT CASE ltype
										CASE $$GOADDR, $$SUBADDR	: ' PRINT [ofile], tt$ + ":"
																								EmitAsm (tt$ + ":")
										CASE ELSE									: PRINT "eul1": GOTO eeeCompiler
									END SELECT
	END SELECT
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeDupLabel:
	PRINT "Duplicate Label = "; a$
	XERROR = ERROR_DUP_LABEL
	EXIT FUNCTION
END FUNCTION
'
'
' #####################
' #####  Eval ()  #####
' #####################
'
FUNCTION  Eval (result_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	reg86$[],  reg86c$[]
	SHARED	ERROR_COMPILER,  XERROR
	SHARED	a0,  a0_type,  a1,  a1_type,  oos,  toes
	SHARED UBYTE oos[]
'
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
	END IF
	IF ((new_type = $$STRING) AND (oos[oos] = 'v')) THEN
		Code ($$call, $$rel, 0, 0, 0, 0, "__clone." + dd$, @"### 513")
		oos[oos] = 'v'
	END IF
	result_type = new_type
	RETURN (new_op)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #############################
' #####  ExpressArray ()  #####
' #############################
'
FUNCTION  ExpressArray (old_op, old_prec, new_data, new_type, accArray, excess, theType, sourceReg)
	EXTERNAL /xxx/	i486asm,  i486bin,  checkBounds,  xpc
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
'
'
' *****  define local constants  *****
'
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
'
	IFZ opcode[] THEN GOSUB InitArrays
'
	token	= new_data
	hd		= token{$$NUMBER}
	IF (hd > $$CONNUM) THEN
		IFZ m_addr$[hd] THEN AssignAddress (token)
		IF XERROR THEN EXIT FUNCTION
	END IF
'
	args				= 0
	kind				= token{$$KIND}
	atoken			= token
	SELECT CASE kind
		CASE $$KIND_ARRAYS
					IF theType THEN
						aType			= theType
					ELSE
						aType			= TheType (token)
					END IF
					xsize				= typeSize[aType]
					composite		= $$FALSE
					braceString	= $$FALSE
					token				= NextToken ()
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
		eType					= $$COMPOSITE
	ELSE
		eType					= aType
	END IF
	excessComma				= $$FALSE
	IF dim_array THEN GOTO e_dim_array ELSE GOTO e_get_array
'
'
' *****************************
' *****  DIMENSION ARRAY  *****
' *****************************
'
e_dim_array:
	Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 514")
e_dim_array_loop:
	INC args
	temp_dim = dim_array: dim_array = $$FALSE
	new_op = Eval (@new_type)
	dim_array = temp_dim
	IF XERROR THEN EXIT FUNCTION
	SELECT CASE toes
		CASE 0:			Move ($$esi, $$XLONG, hd, $$XLONG)
								Code ($$call, $$rel, 0, 0, 0, 0, "__FreeArray", @"### 515")
'								Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 516")
								Move (atoken, $$XLONG, falseToken, $$XLONG)
								Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", "### 517")
								RETURN ($$TRUE)
		CASE a0:		Conv ($$RA0, $$XLONG, $$RA0, new_type)
								sreg = $$R10
		CASE a1:		Conv ($$RA1, $$XLONG, $$RA1, new_type)
								sreg = $$R12
		CASE ELSE:	GOTO eeeSyntax
	END SELECT
	Code ($$st, $$roreg, sreg, $$esp, (16+4*(args-1)), $$XLONG, "", @"### 518")
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	IF (new_op = T_COMMA) THEN
		check				= PeekToken ()
		IF (check != T_RBRAK) THEN GOTO e_dim_array_loop		' get next subscript
		new_op			= NextToken ()
		excessComma	= $$TRUE
		aType				= $$XLONG														' no lowest dimension
	END IF
	IF (new_op <> T_RBRAK) THEN GOTO eeeSyntax
	IF (args > 8) THEN GOTO eeeTooManyArgs
'
	IF (aType >= $$SCOMPLEX) THEN
		IF (hold_type > 0xFF) THEN aType = $$COMPOSITE
	END IF
	IF excessComma THEN
		info	= 0xE000 OR aType					' "higher dimension" bit = 1  (TRUE)
		aType	= $$XLONG									' "higher dimensions" are XLONG
		xsize	= typeSize[aType]					' xsize = 4  (size of XLONG)
	ELSE
		info	= 0xC000 OR aType					' "higher dimension" bit = 0  (FALSE)
	END IF
'
	IF (dim_array = T_REDIM) THEN
		routine$ = "__RedimArray"
	ELSE
		routine$ = "__DimArray"
	END IF
	Move ($$esi, $$XLONG, atoken, $$XLONG)
	Code ($$st, $$roreg, $$esi, $$esp, 0, $$XLONG, "", @"### 519")
	Code ($$st, $$roimm, args, $$esp, 4, $$XLONG, "", @"### 520")
	Code ($$st, $$roimm, (info << 16) + xsize, $$esp, 8, $$XLONG, "", @"### 521")
	Code ($$st, $$roimm, 0, $$esp, 12, $$XLONG, "", @"### 522")
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 523")
	Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 524")
	Move (hd, $$XLONG, $$R10, $$XLONG)
'
dimend:
	excess	= excessComma
	RETURN ($$TRUE)						' done
'
'
' ******************************************
' *****  GET ARRAY ELEMENT OR ADDRESS  *****
' ******************************************
'
e_get_array:
	IF excess THEN
		SELECT CASE TRUE
			CASE (aType < $$SLONG):		aType = $$XLONG: xsize = 4
			CASE (aType = $$GIANT):		aType = $$XLONG: xsize = 4
			CASE (aType = $$DOUBLE):	aType = $$XLONG: xsize = 4
		END SELECT
	END IF
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
	END IF
'
a_null_array:
	null_array = $$TRUE
	trash = NextToken ()
	SELECT CASE actionKind
		CASE $addrOp:			old_op = 0: old_prec = 0:		GOTO addr_null_array
		CASE $handleOp:																GOTO handle_null_array
		CASE $st:																			GOTO eeeSyntax
		CASE ELSE:																		GOTO null_array
	END SELECT
'
null_array:
addr_null_array:
	new_data	= (atoken AND 0xFFFFFF) OR $$T_VARIABLES
	new_type	= $$XLONG
	excess		= $$FALSE
	RETURN ($$FALSE)								' GOTO express_op
'
' *****  &&array[]  *****
'
handle_null_array:
	IF r_addr[hd] THEN DEC tokenPtr: GOTO eeeRegAddr
	tacc = OpenAccForType ($$XLONG)
	m$   = m_addr$[hd]
	mReg	= m_reg[hd]
	mAddr	= m_addr[hd]
	IF mReg THEN
		Code ($$lea, $$regro, tacc, mReg, mAddr, $$XLONG, "", @"### 525")
	ELSE
		Code ($$mov, $$regimm, tacc, mAddr, 0, $$XLONG, m$, @"### 526")
	END IF
	new_data	= 0
	new_type	= $$XLONG
	excess		= $$FALSE
	RETURN ($$FALSE)								' GOTO express_op
'
'
' **************************************************
' *****  PROCESS ARRAY ARGUMENTS (subscripts)  *****
' **************************************************
'
not_null_array:
	doneArgs = $$FALSE
	DO
		test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
		Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
		IF XERROR THEN EXIT FUNCTION
		IF (new_type > $$XLONG) THEN DEC tokenPtr: GOTO eeeTypeMismatch
		new_type				= $$XLONG
		stackString			= $$FALSE
		fakeExcessComma	= $$FALSE
'		aType						= eType
		SELECT CASE new_op
			CASE T_RBRAK
						esize = xsize
						doneArgs = $$TRUE
						dimensionKind = $lowestDim
						IF (aType = $$STRING) THEN
							IF (actionKind = $ld) THEN INC oos: oos[oos] = 'v'
							IF excess THEN
								fakeExcessComma = $$TRUE
								dimensionKind = $excessComma
								excessComma = $$TRUE
								aType = $$XLONG
							END IF
						END IF
						IF braceString THEN GOTO eeeSyntax
			CASE T_RBRACE
						esize = 1
						doneArgs = $$TRUE
						dimensionKind	= $lowestDim
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
						END IF
						esize								= 4
			CASE ELSE
						GOTO eeeSyntax
		END SELECT
'
' new_data is a variable or literal or constant (not evaluated expression)
'
		IF new_data THEN
			nn = new_data{$$NUMBER}
'
' array is in a register and this is leftmost dimension
'
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
						END IF
					CASE ELSE
						Move (acc, new_type, new_data, new_type)
						arsub				= dreg
						araddr			= r_addr[hd]
						elementKind	= $scaled
						IF (esize = 1) THEN elementKind = $unscaled
						IF (compositeType AND (dimensionKind = $lowestDim)) THEN GOSUB AccessComposite
				END SELECT
			ELSE
'
' array is not in a register, or not leftmost dimension
'
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
							END IF
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
							END IF
						CASE ELSE
							Move (acc, new_type, new_data, new_type)
							Move (acc + 1, $$XLONG, atoken, $$XLONG)
							araddr				= acc + 1
							arsub					= dreg
							elementKind		= $scaled
							IF (esize = 1) THEN elementKind = $unscaled
							IF (compositeType AND (dimensionKind = lowestDim)) THEN GOSUB AccessComposite
					END SELECT
				END IF
			END IF
		ELSE
'
' new_data is result of expression evaluation, not variable, literal, constant
'
			acc		= Top()
			dreg	= acc
			arsub	= dreg
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
				END IF
			END IF
		END IF
'
' if bounds checking is enabled, emit bounds checking code
'
		IF checkBounds THEN
			IF (dimensionKind != $lowestDim) THEN
				needHigherDim = $$TRUE
			ELSE
				needHigherDim = $$FALSE
			END IF
			IF fakeExcessComma THEN needHigherDim = NOT needHigherDim
			INC labelNumber : d0$ = "_" + HEX$(labelNumber, 4)
			INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
			INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
			INC labelNumber : d3$ = "_" + HEX$(labelNumber, 4)
			Code ($$or, $$regreg, araddr, araddr, 0, $$XLONG, "", @"### 527")
			Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 528")
			Code ($$ld, $$regro, $$esi, araddr, -8, $$XLONG, "", @"### 529")
			Code ($$ld, $$regro, $$edi, araddr, -4, $$XLONG, "", @"### 530")
			IF needHigherDim THEN
				Code ($$test, $$regimm, $$edi, (1 << 29), 0, $$XLONG, "", @"### 531")
				Code ($$jnz, $$rel, 0, 0, 0, 0, d0$, @"### 532")
				Code ($$mov, $$regreg, $$esi, araddr, 0, $$XLONG, "", @"### 533")
				Code ($$call, $$rel, 0, 0, 0, 0, "__UnexpectedLowestDim", @"### 534")
				Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 535")
			ELSE
				Code ($$test, $$regimm, $$edi, (1 << 29), 0, $$XLONG, "", @"### 536")
				Code ($$jz, $$rel, 0, 0, 0, 0, d0$, @"### 537")
				Code ($$mov, $$regreg, $$esi, araddr, 0, $$XLONG, "", @"### 538")
				Code ($$call, $$rel, 0, 0, 0, 0, "__UnexpectedHigherDim", @"### 539")
				Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 540")
			END IF
			EmitLabel (@d0$)
			IFZ braceString THEN
				Code ($$dec, $$reg, $$esi, 0, 0, $$XLONG, "", "### 541")
			END IF
			SELECT CASE elementKind
				CASE $imm
							Code ($$cmp, $$regimm, $$esi, element, 0, $$XLONG, "", @"### 542")
				CASE $sca
							Code ($$cmp, $$regreg, $$esi, arsub, 0, $$XLONG, "", @"### 543")
				CASE $uns
							Code ($$and, $$regimm, $$edi, 0xFFFF, 0, $$XLONG, "", @"### 544")
							Code ($$imul, $$regreg, $$esi, $$edi, 0, $$XLONG, "", @"### 545")
							Code ($$cmp, $$regreg, $$esi, arsub, 0, $$XLONG, "", @"### 546")
			END SELECT
			Code ($$jae, $$rel, 0, 0, 0, 0, d2$, @"### 547")
			EmitLabel (@d1$)
			Code ($$mov, $$regreg, $$ecx, araddr, 0, $$XLONG, "", @"### 548")
			Code ($$call, $$rel, 0, 0, 0, 0, "__OutOfBounds", @"### 549")
			Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 550")
			EmitLabel (@d2$)
		END IF
'
		IF stackString THEN
			Code ($$mov, $$regreg, $$esi, araddr, 0, $$XLONG, "", "### 551")
		END IF
		code	= opcode [dimensionKind, elementKind, actionKind, eType]
		mode	= code AND 0x00FF
		code	= code {$$WORD1}
		IFZ code THEN GOTO eeeSyntax
		IF dimensionKind THEN xType = $$XLONG ELSE xType = eType
		Code (code, mode, dreg, araddr, arsub, xType, "", @"### 552")
		IF checkBounds THEN EmitLabel (@d3$)
		regarray = $$FALSE
		INC args
	LOOP UNTIL (doneArgs)
'
'
' *****  DONE processing subscripts  *****
'
	IF stackString THEN
		Code ($$call, $$rel, 0, 0, 0, 0, @"_____free", "### 553")
	END IF
	IF accArray THEN DEC oos
	acc = Top()
	SELECT CASE acc
		CASE $$RA0	: a0_type = aType
		CASE $$RA1	: a1_type = aType
		CASE ELSE		: PRINT "expressArray03": GOTO eeeCompiler
	END SELECT
	elementType	= aType
	IF (aType < $$SLONG) THEN aType = $$SLONG
	IF oldKindAddrOp THEN aType = $$XLONG
	excess			= excessComma
	new_type		= aType
	new_data		= 0
	RETURN ($$FALSE)
'
' *****  Access Composite Element in Array  *****
'
SUB AccessComposite
	IF (esize <= 1024) THEN eshift = shiftMulti [esize]
	IF eshift THEN
		Code ($$sll, $$regimm, arsub, eshift, 0, $$XLONG, "", "### 554")
	ELSE
		Code ($$imul, $$regimm, arsub, esize, 0, $$XLONG, "", @"### 555")
	END IF
	elementKind	= $unscaled
END SUB
'
'
'
' ****************************
' *****  SUB InitArrays  *****
' ****************************
'
SUB InitArrays
	DIM opcode [2, 2, 3, 31]
	DIM opcode$[2, 2, 3, 31]
'
'
' ****************************************
' ****************************************
' *****  dimensionKind = $lowestDim  *****
' ****************************************
' ****************************************
'
' ***********************
' *****  immediate  *****  (offset = element * size)
' ***********************
'
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
	opcode [$lo, $imm, $ld, $$STRING]				= $$uld		+ $regro
	opcode [$lo, $imm, $ld, $$COMPOSITE]		= $$ulda	+ $regro
'
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
	opcode [$lo, $imm, $st, $$STRING]				= $$ust		+ $roreg
	opcode [$lo, $imm, $st, $$COMPOSITE]		= $$ulda	+ $regro
'
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
	opcode [$lo, $imm, $addr, $$STRING]			= $$uld		+ $regro
	opcode [$lo, $imm, $addr, $$COMPOSITE]	= $$ulda	+ $regro
'
	opcode [$lo, $imm, $handle, $$STRING]		= $$ulda	+ $regro
'
'
' ********************
' *****  scaled  *****  (size = 1, 2, 4, 8 bytes)
' ********************
'
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
	opcode [$lo, $sca, $ld, $$STRING]				= $$uld		+ $regrs
	opcode [$lo, $sca, $ld, $$COMPOSITE]		= $$uld		+ $regrs
'
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
	opcode [$lo, $sca, $st, $$STRING]				= $$ust		+ $rsreg
	opcode [$lo, $sca, $st, $$COMPOSITE]		= $$ulda	+ $regrs
'
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
	opcode [$lo, $sca, $addr, $$STRING]			= $$uld		+ $regrs
	opcode [$lo, $sca, $addr, $$COMPOSITE]	= $$ulda	+ $regrs
'
	opcode [$lo, $sca, $handle, $$STRING]		= $$ulda	+ $regrs
'
'
' **********************
' *****  unscaled  *****  (size not 1, 2, 4, 8 bytes)  *****
' **********************
'
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
	opcode [$lo, $uns, $ld, $$STRING]				= $$uld		+ $regrr
	opcode [$lo, $uns, $ld, $$COMPOSITE]		= $$ulda	+ $regrr
'
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
	opcode [$lo, $uns, $st, $$STRING]				= $$ust		+ $rrreg
	opcode [$lo, $uns, $st, $$COMPOSITE]		= $$ulda	+ $regrr
'
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
	opcode [$lo, $uns, $addr, $$STRING]			= $$uld		+ $regrr
	opcode [$lo, $uns, $addr, $$COMPOSITE]	= $$ulda	+ $regrr
'
	opcode [$lo, $uns, $handle, $$STRING]		= $$ulda	+ $regrr
'
'
' ****************************************
' ****************************************
' *****  dimensionKind = $higherDim  *****
' ****************************************
' ****************************************
'
' ***********************
' *****  immediate  *****  (offset = ele * size)
' ***********************
'
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
	opcode [$hi, $imm, $ld, $$STRING]				= $$uld		+ $regro
	opcode [$hi, $imm, $ld, $$COMPOSITE]		= $$uld		+ $regro
'
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
	opcode [$hi, $imm, $st, $$STRING]				= $$uld		+ $regro
	opcode [$hi, $imm, $st, $$COMPOSITE]		= $$uld		+ $regro
'
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
	opcode [$hi, $imm, $addr, $$STRING]			= $$uld		+ $regro
	opcode [$hi, $imm, $addr, $$COMPOSITE]	= $$uld		+ $regro
'
	opcode [$hi, $imm, $handle, $$STRING]		= $$uld		+ $regro
'
'
' ********************
' *****  scaled  *****  (size = 1, 2, 4, 8 bytes)
' ********************
'
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
	opcode [$hi, $sca, $ld, $$STRING]				= $$uld		+ $regrs
	opcode [$hi, $sca, $ld, $$COMPOSITE]		= $$uld		+ $regrs
'
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
	opcode [$hi, $sca, $st, $$STRING]				= $$uld		+ $regrs
	opcode [$hi, $sca, $st, $$COMPOSITE]		= $$uld		+ $regrs
'
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
	opcode [$hi, $sca, $addr, $$STRING]			= $$uld		+ $regrs
	opcode [$hi, $sca, $addr, $$COMPOSITE]	= $$uld		+ $regrs
'
	opcode [$hi, $sca, $handle, $$STRING]		= $$uld		+ $regrs
'
'
' **********************
' *****  unscaled  *****  (size not 1, 2, 4, 8 bytes)  *****
' **********************
'
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
	opcode [$hi, $uns, $ld, $$STRING]				= $$uld		+ $regrr
	opcode [$hi, $uns, $ld, $$COMPOSITE]		= $$uld		+ $regrr
'
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
	opcode [$hi, $uns, $st, $$STRING]				= $$uld		+ $regrr
	opcode [$hi, $uns, $st, $$COMPOSITE]		= $$uld		+ $regrr
'
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
	opcode [$hi, $uns, $addr, $$STRING]			= $$uld		+ $regrr
	opcode [$hi, $uns, $addr, $$COMPOSITE]	= $$uld		+ $regrr
'
	opcode [$hi, $uns, $handle, $$STRING]		= $$uld		+ $regrr
'
'
' ******************************************
' ******************************************
' *****  dimensionKind = $excessComma  *****
' ******************************************
' ******************************************
'
' ***********************
' *****  immediate  *****  (offset = ele * size)
' ***********************
'
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
	opcode [$ex, $imm, $ld, $$STRING]				= $$uld		+ $regro
	opcode [$ex, $imm, $ld, $$COMPOSITE]		= $$uld		+ $regro
'
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
	opcode [$ex, $imm, $st, $$STRING]				= $$ust		+ $roreg
	opcode [$ex, $imm, $st, $$COMPOSITE]		= $$ust		+ $roreg
'
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
	opcode [$ex, $imm, $addr, $$STRING]			= $$ulda	+ $regro
	opcode [$ex, $imm, $addr, $$COMPOSITE]	= $$ulda	+ $regro
'
'
' ********************
' *****  scaled  *****  (size = 1, 2, 4, 8 bytes)
' ********************
'
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
	opcode [$ex, $sca, $ld, $$STRING]				= $$uld		+ $regrs
	opcode [$ex, $sca, $ld, $$COMPOSITE]		= $$uld		+ $regrs
'
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
	opcode [$ex, $sca, $st, $$STRING]				= $$ust		+ $rsreg
	opcode [$ex, $sca, $st, $$COMPOSITE]		= $$ust		+ $rsreg
'
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
	opcode [$ex, $sca, $addr, $$STRING]			= $$ulda	+ $regrs
	opcode [$ex, $sca, $addr, $$COMPOSITE]	= $$ulda	+ $regrs
'
'
' **********************
' *****  unscaled  *****  (size not 1, 2, 4, 8 bytes)  *****
' **********************
'
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
	opcode [$ex, $uns, $ld, $$STRING]				= $$uld		+ $regrr
	opcode [$ex, $uns, $ld, $$COMPOSITE]		= $$uld		+ $regrr
'
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
	opcode [$ex, $uns, $st, $$STRING]				= $$ust		+ $rrreg
	opcode [$ex, $uns, $st, $$COMPOSITE]		= $$ust		+ $rrreg
'
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
	opcode [$ex, $uns, $addr, $$STRING]			= $$ulda	+ $regrr
	opcode [$ex, $uns, $addr, $$COMPOSITE]	= $$ulda	+ $regrr
END SUB
'
'
' ********************
' *****  ERRORS  *****
' ********************
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeRegAddr:
	XERROR = ERROR_REGADDR
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
'
eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' #########################
' #####  Expresso ()  #####
' #########################
'
FUNCTION  Expresso (old_test, old_op, old_prec, old_data, old_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  checkBounds,  library,  xpc
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
	SHARED	typeSize[],  typeSize$[],  typeName$[],  stackData[],  stackType[]
	SHARED	XERROR
	SHARED	ERROR_BITSPEC,  ERROR_BYREF,  ERROR_BYVAL,  ERROR_COMPILER
	SHARED	ERROR_COMPONENT,  ERROR_KIND_MISMATCH,  ERROR_LITERAL
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
	SHARED	T_CHR_D,  T_CJUST_D,  T_CLOSE,  T_CLR,  T_CSIZE,  T_CSIZE_D
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
	SHARED	T_ROTATEL,  T_ROTATER,  T_RPAREN,  T_RTRIM_D
	SHARED	T_SBYTE,  T_SBYTEAT,  T_SEEK,  T_SET,  T_SGN,  T_SHELL
	SHARED	T_SIGN,  T_SIGNED_D,  T_SINGLE,  T_SINGLEAT,  T_SIZE
	SHARED	T_SLONG,  T_SLONGAT,  T_SMAKE,  T_SPACE_D
	SHARED	T_SSHORT,  T_SSHORTAT,  T_STR_D,  T_STRING,  T_STRING_D
	SHARED	T_STUFF_D,  T_SUBADDR,  T_SUBADDRAT,  T_SUBADDRESS
	SHARED	T_SUBTRACT,  T_TAB,  T_TRIM_D,  T_TYPE
	SHARED	T_UBOUND,  T_UBYTE,  T_UBYTEAT,  T_UCASE_D
	SHARED	T_ULONG,  T_ULONGAT,  T_USHORT,  T_USHORTAT
	SHARED	T_VERSION_D,  T_XLONG,  T_XLONGAT,  T_XMAKE
	SHARED	a0,  a0_type,  a1,  a1_type,  toes,  toms,  tokenPtr
	SHARED	got_expression,  infunc,  inPrint,  funcaddrFuncNumber
	SHARED	oos,  dim_array,  func_number,  nullstringer
	SHARED	preType,  componentNumber
	SHARED	programToken,  versionToken
	SHARED	labelNumber,  compositeArg
	SHARED  lineNumber,  pass
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
'
	IFZ argToken[] THEN GOSUB InitArrays
'
	got_expression = $$FALSE
	args			=	0
	DO
		token		= NextToken ()
		kind		= token{$$KIND}
	LOOP WHILE (token = T_ADD)				' skip unary pluses
'
' ***********************************
' *****  EXPECTING DATA OBJECT  *****
' ***********************************
'
	GOTO @dataKind [kind]		' dispatch routine based upon kind of token
	old_test	= 0						' unrecognized kinds aren't expression starters
	old_op		= token
	old_prec	= 0
	old_data	= 0
	old_type	= 0
	RETURN
'
'
' *****  Expecting data, got character  *****  @func() = invoke func()
'
express_character:
	IF (token == T_ATSIGN) THEN GOTO express_function
	GOTO eeeSyntax
'
'
' *****  Expecting data object, got simple kind of data object  *****
'        (variable, constant, literal, syscon, charcons)
'
express_var:
	got_expression = $$TRUE
	new_data = token
	bitCheck = $$FALSE
	check = PeekToken ()
'	new_type = TheType (token)
	nn = token{$$NUMBER}
	new_allo = token{$$ALLO}
'
	IFZ new_allo THEN
		symboloid$ = tab_sym$[nn]
		IF symboloid$ THEN
			IF (symboloid${0} == '#') THEN
				new_allo = $$SHARED
				IF (symboloid${1} == '#') THEN new_allo = $$EXTERNAL
			END IF
		END IF
	END IF
	new_type = token{$$TYPE}
	IFZ new_type THEN new_type = tabType[nn]
	IFZ new_type THEN
		IF ((new_allo == $$SHARED) OR (new_allo == $$EXTERNAL)) THEN
			symboloid$ = tab_sym$[nn]
			IF (symboloid${0} == '#') THEN
				IFZ m_addr$[nn] THEN AssignAddress (token)
				new_type = TheType (token)
			END IF
		END IF
	END IF
'
	IFZ new_type THEN new_type = TheType (token)
'
' *****  COMPOSITE DATA TYPE  *****
'
' The following skips getting the data for the composite if
' it's followed by a kind = symbol token.  This really isn't
' a very good way to do it.  Change Composite () so there's
' a way to get data if it's not a stand-alone composite for
' which the token is the necessary result needed here.
'
' Note:		It is necessary to get the TOKEN only in such
'					cases, or places for intermediate SCOMPLEX and
'					DCOMPLEX don't get made up and expressions can
'					generate bogus code...
'
express_component:
	IF (new_type >= $$SCOMPLEX) THEN
		ctest		= PeekToken(){$$KIND}
		IF ((ctest = $$KIND_SYMBOLS) OR (ctest = $$KIND_ARRAY_SYMBOLS)) THEN
			Composite ($$GETDATA, @new_type, @new_data, 0, 0)
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
			END IF
		END IF
		check 	= PeekToken ()
	END IF
'
	IF ((check == T_LBRACE) OR (check == T_LBRACES)) THEN
		SELECT CASE kind
			CASE $$KIND_VARIABLES, $$KIND_LITERALS, $$KIND_CONSTANTS, $$KIND_SYSCONS
			CASE ELSE:	GOTO eeeSyntax
		END SELECT
		SELECT CASE new_type
			CASE $$STRING
						GOTO express_array						' a${n} or a${n, m} form
			CASE $$GIANT, $$DOUBLE
						GOTO eeeTypeMismatch
			CASE ELSE
						bitCheck = check							' a{n}, a{{n}}, a{n,m}, a{{n,m}}
		END SELECT
	END IF
'
	IF (new_type == $$STRING) THEN
		IFZ stackString THEN INC oos: oos[oos] = 'v'
	END IF
'
	IF (new_type < $$SLONG) THEN new_type = $$SLONG
'
' The next 3 lines of code are replaced by the 5 lines that follow
' to prevent errors on lines like  p# = (a*1.0)/b  where a and b
' are ULONG variables.
'
'	IF ((old_type == $$ULONG) AND (kind == $$KIND_LITERALS)) THEN
'		new_type = $$ULONG
'	END IF
'
	IF (old_type == $$ULONG) THEN
'	SVG 20010517 - removed empty IF statements
'		IF (new_type < $$SINGLE) THEN
'			IF (kind = $$KIND_LITERALS) THEN
'				new_type = $$ULONG
'			END IF
'		END IF
		IF ((new_type == $$SINGLE) OR (new_type == $$DOUBLE)) THEN
			aaaaa = 11111
		END IF
	END IF
'
	IF (kind = $$KIND_CONSTANTS) OR (kind = $$KIND_SYSCONS) THEN
		IFZ r_addr$[nn] THEN GOTO eeeUndefined
	END IF
'
	IF new_data THEN
		IFZ m_addr$[nn] THEN AssignAddress (token)
		IF XERROR THEN EXIT FUNCTION
	END IF
'
	IF bitCheck THEN
		IF new_data THEN
			GOTO extract_bits_from_variable
		ELSE
			INC tokenPtr
			GOTO extract_bits_from_expression
		END IF
	END IF
'
'
' *************************************************
' *****  Got data, now expecting an operator  *****
' *************************************************
'
express_op:
	new_zip = $$FALSE									' new.zip TRUE if new.op is data kind
	token = NextToken ()							' expecting operator
	kind = token{$$KIND}							' kind should be operator
'
	GOTO @opKind [kind]								' dispatch based on kind.  Fall through on
	new_zip		= $$TRUE								'   data kinds and other non-binary-ops
	new_op		= token
	new_prec	= 0
	GOTO exo
'
express_op_rem:
	token = $$T_STARTS								' got remark/comment token
	GOTO express_ops
'
express_op_lparen:
	IF ((token = T_LBRACE) OR (token = T_LBRACES)) THEN
		GOTO extract_bits_from_expression
	END IF
	old_test  = new_test
	old_op		= token									' got "(" when expecting an operator
	old_prec	= 0
	old_data	= new_data
	old_type	= new_type
	RETURN
'
express_op_component:
	IF (new_type < $$SCOMPLEX) THEN GOTO eeeComponent
	DEC tokenPtr
	GOTO express_component
'
'
' ******************************************
' *****  Binary operator or separator  *****
' ******************************************
'
express_ops:
	new_op		= token
	new_prec	= new_op{$$PREC}
exo:
	IF XERROR THEN EXIT FUNCTION
	kind = new_op{$$KIND}
'
' *****  new_prec > old_prec  *****
'
	IF (new_prec > old_prec) THEN
		IF new_test THEN GOSUB ExtractBit
		Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
		IF new_test AND (old_test != -1) THEN GOSUB ExtractBit
		GOTO exo
	END IF
'
' *****  new_prec <= old_prec  *****
'
	IF (old_op{$$KIND} = $$KIND_ADDR_OPS) THEN
		old_test = 0
		old_op   = new_op
		old_prec = new_prec
		old_data = 0
		old_type = $$XLONG
		RETURN
	END IF
'
	old_table = ((old_op >> 20) AND 0x0F)				' old.table = imbedded table #
	IF new_zip THEN
		new_table = 0															' new.op = some kind of data
	ELSE
		new_table = ((new_op >> 20) AND 0x0F)			' xxx.table = 0 if xxx.op = () []
	END IF
'
	IFZ (old_table OR new_table) THEN						' matching parentheses
		old_test = new_test
		old_op   = new_op
		old_prec = new_prec
		old_data = new_data
		old_type = new_type
		RETURN
	END IF
'
' STRINGS and SCOMPLEX / DCOMPLEX arithmetic
'
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
					IF (new_type > $$DCOMPLEX) THEN GOTO eeeTypeMismatch
					IF (old_type > $$DCOMPLEX) THEN GOTO eeeTypeMismatch
					IF (new_type = $$STRING) THEN GOTO eeeTypeMismatch
					old_cop = cop[old_table, old_type, new_type]
					old_to_type = old_cop {$$BYTE3}
					new_to_type = old_cop {$$BYTE2}
					old_op_type = old_cop {$$BYTE1}
					result_type = old_cop {$$BYTE0}
	END SELECT
	IF (old_cop < 0) THEN DEC tokenPtr: GOTO eeeTypeMismatch
'
	st = old_type
	IF old_to_type THEN st = old_to_type
	xt = new_type
	IF new_to_type THEN xt = new_to_type
	ot = old_op_type
	rt = result_type
'
	oo = old_data{$$NUMBER}
	nn = new_data{$$NUMBER}
	ro = r_addr[oo]
	rn = r_addr[nn]
'
	SELECT CASE old_data{$$KIND}
		CASE $$KIND_LITERALS, $$KIND_CONSTANTS:		ro = 0
		CASE $$KIND_CHARCONS, $$KIND_SYSCONS:			ro = 0
	END SELECT
'
	accx = 0												' accx = 3 :  a1 full  . a0 full
	IF a0 THEN accx = accx + 1			' accx = 2 :  a1 full  . a0 empty
	IF a1 THEN accx = accx + 2			' accx = 1 :  a1 empty . a0 full
'                                 ' accx = 0 :  a1 empty . a0 empty
'
'
'
	IF (old_type < $$SLONG) THEN old_type = $$SLONG
	IF (new_type < $$SLONG) THEN new_type = $$SLONG
	SELECT CASE old_type
		CASE $$SINGLE, $$DOUBLE:	oldFlop = $$TRUE
		CASE ELSE:								oldFlop = $$FALSE
	END SELECT
	SELECT CASE new_type
		CASE $$SINGLE, $$DOUBLE:	newFlop = $$TRUE
		CASE ELSE:								newFlop = $$FALSE
	END SELECT
' SVG 20010517 - simplified following lines
	newToFlop = (oldFlop AND !newFlop)
	oldToFlop = (newFlop AND !oldFlop)
'
	SELECT CASE ot
		CASE $$SINGLE, $$DOUBLE:	i486flop = $$TRUE
		CASE ELSE:								i486flop = $$FALSE
	END SELECT
'
'
'   *****  UNARY operators first  *****
'
	IF (rn AND (rn < $$IMM16)) THEN GOTO eeeCompiler
	IF (old_op{$$KIND} = $$KIND_UNARY_OPS) THEN
		IF new_data THEN					' UOP var
			IFZ rn THEN
				GOTO uop_var_mem			' UOP var.mem
			ELSE
				GOTO uop_var_reg			' UOP var.reg
			END IF
		ELSE
			IF a0 AND (a0 = toes) THEN
				GOTO uop_stk_reg_a0		' UOP stk.reg.a0
			END IF
			IF a1 AND (a1 = toes) THEN
				GOTO uop_stk_reg_a1		' UOP stk.reg.a1
			END IF
			GOTO uop_stk_mem				' UOP stk.mem  (error)
		END IF
	END IF
'
'   *****  BINARY operators  *****
'
'   *****  var  OP  var  *****
'
	IF ro THEN GOTO eeeCompiler
	IF rn THEN
		IF (rn < $$IMM16) THEN GOTO eeeCompiler
		IF (rn > $$CONNUM) THEN GOTO eeeCompiler
	END IF
	IF (old_data <> 0) AND (new_data <> 0) THEN			' var OP var
		IFZ rn THEN
			GOTO var_mem_op_var_mem						' var.mem OP var.mem
		ELSE
			GOTO var_mem_op_var_reg						' var.mem OP var.reg
		END IF
	END IF
'
'   *****  var  OP  stk  *****
'
	IF ((old_data <> 0) AND (new_data = 0)) THEN			' var OP stk
		IFZ ro THEN
			IF a0 AND (a0 = toes) THEN
				GOTO var_mem_op_stk_reg_a0				' var.mem OP stk.reg.a0
			END IF
			IF a1 AND (a1 = toes) THEN
				GOTO var_mem_op_stk_reg_a1				' var.mem OP stk.reg.a1
			END IF
			GOTO var_mem_op_stk_mem							' var.mem OP stk.mem  (error)
		END IF
	END IF
'
'   *****  stk  OP  var  *****
'
	IF (old_data = 0) AND (new_data <> 0) THEN	' stk OP var
		IFZ rn THEN
			IF a0 AND (a0 = toes) THEN
				GOTO stk_reg_a0_op_var_mem				' stk.reg.a0 OP var.mem
			END IF
			IF a1 AND (a1 = toes) THEN
				GOTO stk_reg_a1_op_var_mem				' stk.reg.a1 OP var.mem
			END IF
			GOTO stk_mem_op_var_mem							' stk.mem OP var.mem  (error)
		ELSE
			IF a0 AND (a0 = toes) THEN
				GOTO stk_reg_a0_op_var_reg				' stk.reg.a0 OP var.reg
			END IF
			IF a1 AND (a1 = toes) THEN
				GOTO stk_reg_a1_op_var_reg				' stk.reg.a1 OP var.reg
			END IF
			GOTO stk_mem_op_var_reg							' stk.mem OP var.reg (error)
		END IF
	END IF
'
'   *****  stk  OP  stk  *****
'
	IF (old_data = 0) AND (new_data = 0) THEN		' stk OP stk
		IF a0 AND (a0 = toes) THEN
			IF a1 AND (a1 = toes - 1) THEN
				GOTO stk_reg_a1_op_stk_reg_a0			' stk.reg.a0 OP stk.reg.a1
			ELSE
				GOTO stk_mem_op_stk_reg_a0				' stk.mem OP stk.reg.a0
			END IF
		END IF
		IF a1 AND (a1 = toes) THEN
			IF a0 AND (a0 = toes - 1) THEN
				GOTO stk_reg_a0_op_stk_reg_a1			' stk.reg.a1 OP stk.reg.a0
			ELSE
				GOTO stk_mem_op_stk_reg_a1				' stk.mem OP stk.reg.a1
			END IF
		END IF
	END IF
	PRINT "expresso1": GOTO eeeCompiler
'
' ***********************************************
' *****  THE ROUTINES JUMPED TO FROM ABOVE  *****
' ***********************************************
'
'
' *************************************
' *****  UNARY OPERATOR ROUTINES  *****
' *************************************
'
uop_var_mem:
	IF (accx = 3) THEN GOTO uvma
	IF (accx = 2) THEN GOTO uvmb
	IF (accx = 1) THEN GOTO uvmc
	IF (accx = 0) THEN GOTO uvmb
	PRINT "expresso2": GOTO eeeCompiler
'
uvma:
	IF (a1 > a0) THEN GOTO uvm0
	IF (a1 < a0) THEN GOTO uvm1
	PRINT "expresso3": GOTO eeeCompiler
'
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
'
'
'
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
'
'
'
uop_stk_reg_a0:
				Conv ($$RA0, new_to_type, $$RA0, new_type)
				Uop ($$RA0, @old_op, $$RA0, rt, ot, xt)
				a0 = toes
				a0_type = rt
				GOTO done
'
'
'
uop_stk_reg_a1:
				Conv ($$RA1, new_to_type, $$RA1, new_type)
				Uop ($$RA1, @old_op, $$RA1, rt, ot, xt)
				a1 = toes
				a1_type = rt
				GOTO done
'
'
'
uop_stk_mem:
	PRINT "expresso8": GOTO eeeCompiler
'
'
'
' ****************************************
' *****  BINARY  OPERATOR  ROUTINES  *****
' ****************************************
'
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
			END IF
			IF i486flop THEN
'				Move ($$RA1, new_type, nn, new_type)	' xnt0l
				FloatLoad ($$RA1, nn, new_type)				' xnt0l
			ELSE
				Move ($$RA1, new_type, nn, new_type)
				Conv ($$RA1, new_to_type, $$RA1, new_type)
			END IF
			Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
			INC toes
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done
fcb:	Push ($$RA1, a1_type)
f4x:	Push ($$RA0, a0_type)
			GOTO fcx
'
'
'
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
'
'
'
'
'
'
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
			END IF
			Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done
'
'
'
var_mem_op_stk_reg_a1:
'				PRINT "var_mem_op_stk_reg_a1:  trouble ???"
				IF (accx == 3) THEN GOTO ccb
				IF (accx == 2) THEN GOTO c8
				PRINT "expresso27": GOTO eeeCompiler
ccb:	Push ($$RA0, a0_type)
c8:		IF i486flop THEN
'				Move ($$RA0, old_type, oo, old_type)
				FloatLoad ($$RA0, oo, old_type)
				Conv ($$RA1, new_to_type, $$RA1, new_type)
'	SVG 20010517 - correction for new_type not a float
				IF !newToFlop THEN
					Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
				ELSE
					Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				END IF
			ELSE
				Move ($$RA0, old_type, oo, old_type)
				Conv ($$RA0, old_to_type, $$RA0, old_type)
				Conv ($$RA1, new_to_type, $$RA1, new_type)
				Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
			END IF
			a1 = 0: a1_type = 0
			a0 = toes
			GOTO done
'
'
'
var_mem_op_stk_mem:
	PRINT "expresso28": GOTO eeeCompiler
'
'
'
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
				END IF
				Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done
'
'
stk_reg_a1_op_var_mem:
'				PRINT "stk_reg_a1_op_var_mem:  trouble ???"
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
				END IF
				Conv ($$RA1, old_to_type, $$RA1, old_type)
'	SVG 20010517 - correction for case if old_type is a float
				IF oldFlop THEN
					Op ($$RA0, $$RA0, @old_op, $$RA1, rt, st, ot, xt)
				ELSE
					Op ($$RA0, $$RA1, @old_op, $$RA0, rt, st, ot, xt)
				END IF
				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done
'
'
'
stk_mem_op_var_mem:
	PRINT "expresso34": GOTO eeeCompiler
'
'
'
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
'
'
'
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
				END IF
				a1 = 0: a1_type = 0
				a0 = toes
				GOTO done
x2coxb: Conv ($$RA1, old_to_type, $$RA1, old_type)
x2cxxb: Op ($$RA1, $$RA1, @old_op, nn, rt, st, ot, xt)
				a1 = toes: a1_type = rt
				GOTO done
'
'
'
stk_mem_op_var_reg:
	PRINT "expresso41": GOTO eeeCompiler
'
'
'
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
'
'
'
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
'
'
'
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
'
'
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
'
'
' *****  After code for unary and binary operators has been emitted  *****
' *****  if (old.op != 0), logical test op returned bit T/F, not XLONG T/F
'
done:
	old_test	= old_op
	old_op		= new_op
	old_prec	= new_prec
	old_data	= 0
	old_type	= result_type
	RETURN
'
'
' ************************************************
' *****  Convert "bit T/F" into "XLONG T/F"  *****  ????  CAN THIS HAPPEN  ????
' ************************************************
'
SUB ExtractBit
	acc  = Top ()
	IFZ acc THEN PRINT "expresso.bit.test": GOTO eeeCompiler
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	GOSUB ConvCondBitFalse
	Code ($$mov, $$regimm, acc, 0, 0, $$XLONG, "", @"### 556")
	Code (jmp486, $$rel, 0, 0, 0, 0, d1$, @"### 557")
	Code ($$not, $$reg, acc, 0, 0, $$XLONG, "", @"### 558")
	EmitLabel (@d1$)
	new_test = 0
END SUB
'
'
' *****  ConvCondBitTrue  *****
'
' Sets jmp486$ to 80386 conditional jump mnemonic that corresponds to
' the 88000 condition bit in new_test being true.
'
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
'
' *****  ConvCondBitFalse  *****
'
' Sets jmp486$ to 80386 conditional jump mnemonic that corresponds to
' the 88000 condition bit in new_test being false.
'
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
'
'
'
' *****  UNARY OPERATORS  *****
'
express_unary_op:
	new_op		= token
	new_prec	= new_op{$$PREC}
	new_data	= 0
	new_type	= 0
	test			= 0
	Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
	GOTO exo
'
'
'
' *****  ARRAYS  *****
'
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
			END IF
		END IF
	END IF
	new_type = token{$$TYPE}
	IFZ new_type THEN new_type = tabType[nn]
	IFZ new_type THEN
		IF ((new_allo == $$SHARED) OR (new_allo == $$EXTERNAL)) THEN
			symboloid$ = tab_sym$[nn]
			IF (symboloid${0} == '#') THEN
				IFZ m_addr$[nn] THEN AssignAddress (token)
				new_type = TheType (token)
			END IF
		END IF
	END IF
'
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
		END IF
	END IF
'
	dimDone			= ExpressArray (@old_op, @old_prec, @new_data, @new_type, accArray, 0, 0, 0)
	accArray		= $$FALSE
	IF XERROR THEN EXIT FUNCTION
	new_op			= 0
	new_prec		= 0
	IF dimDone THEN												' dimend return
		old_test	= 0
		old_op		= NextToken ()
		old_prec	= 0
		old_data	= 0
		old_type	= 0
		RETURN
	END IF
	GOTO express_op
'
'
' *******************************
' *****  EXTRACT BIT FIELD  *****
' *******************************
'
extract_bits_from_expression:
	IF new_data THEN
		varToken	= new_data
		varType		= new_type
		bitVar		= $$TRUE
		GOTO extract_bits
	END IF
'
	IF (new_type != $$STRING) THEN
		acc				= Topax1 ()
		IFZ acc THEN GOTO eeeCompiler
		Code ($$push, $$reg, acc, 0, 0, $$XLONG, "", @"### 559")
	END IF
	DEC tokenPtr
	varToken	= 0
	varType		= new_type
	bitVar		= $$FALSE
	GOTO extract_bits
'
extract_bits_from_variable:
	got_expression = $$TRUE
	varToken	= token
	varType		= new_type
	bitVar		= $$TRUE
'
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
			END IF
			token = $$T_VARIABLES + ($$STRING << 16) + varToken
			GOTO express_array
		CASE ELSE:	GOTO eeeTypeMismatch
	END SELECT
	bitArgs = 0
	token = NextToken ()
	openBrace = token
'
' get width field (width-offset field if only one argument)
'
	new_op = Eval (@widthType)
	IF XERROR THEN EXIT FUNCTION
	IFZ q_type_long[widthType] THEN GOTO eeeTypeMismatch
	INC bitArgs
'
' get offset field (if specified)
'
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
	END IF
'
	IF (bitArgs < 2) THEN
		dacc = Top()
	ELSE
		Topaccs (@dacc, @daccx)
	END IF
	IF bitVar THEN
		Move ($$esi, $$XLONG, varToken, $$XLONG)
	ELSE
		Code ($$pop, $$reg, $$esi, 0, 0, $$XLONG, "", @"### 560")
	END IF
'
' get bitfield value in a register or immediate value
'
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
'
'
'
SUB OneBitArg
	IF (openBrace = T_LBRACE) THEN
		Code ($$mov, $$regreg, $$ecx, dacc, 0, $$XLONG, "", @"### 561")
		Code ($$slr, $$regreg, $$esi, $$cl, 0, $$XLONG, "", @"### 562")
		Code ($$mov, $$regimm, $$edi, -1, 0, $$XLONG, "", @"### 563")
		Code ($$slr, $$regimm, $$ecx, 5, 0, $$XLONG, "", @"### 564")
		Code ($$sll, $$regreg, $$edi, $$cl, 0, $$XLONG, "", @"### 565")
		Code ($$not, $$reg, $$edi, 0, 0, $$XLONG, "", @"### 566")
		Code ($$and, $$regreg, $$esi, $$edi, 0, $$XLONG, "", @"### 567")
		Code ($$mov, $$regreg, dacc, $$esi, 0, $$XLONG, "", @"### 568")
	ELSE
		Code ($$mov, $$regreg, $$edi, dacc, 0, $$XLONG, "", "### 569")
		Code ($$mov, $$regreg, $$ecx, $$edi, 0, $$XLONG, "", "### 570")
		Code ($$slr, $$regimm, $$ecx, 5, 0, $$XLONG, "", "### 571")
		Code ($$and, $$regimm, $$edi, 31, 0, $$XLONG, "", "### 572")
		Code ($$and, $$regimm, $$ecx, 31, 0, $$XLONG, "", "### 573")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, "", "### 574")
		Code ($$neg, $$reg, $$ecx, 0, 0, $$XLONG, "", "### 575")
		Code ($$add, $$regimm, $$ecx, 32, 0, $$XLONG, "", "### 576")
		Code ($$sll, $$regreg, $$esi, $$cl, 0, $$XLONG, "", "### 577")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, "", "### 578")
		Code ($$sar, $$regreg, $$esi, $$cl, 0, $$XLONG, "", "### 579")
		Code ($$mov, $$regreg, dacc, $$esi, 0, $$XLONG, "", "### 580")
	END IF
END SUB
'
SUB TwoBitArgs
	IF (openBrace = T_LBRACE) THEN
		Code ($$mov, $$regreg, $$ecx, dacc, 0, $$XLONG, "", @"### 581")
		Code ($$slr, $$regreg, $$esi, $$cl, 0, $$XLONG, "", @"### 582")
		Code ($$mov, $$regimm, $$edi, -1, 0, $$XLONG, "", @"### 583")
		Code ($$mov, $$regreg, $$ecx, daccx, 0, $$XLONG, "", @"### 584")
		Code ($$sll, $$regreg, $$edi, $$cl, 0, $$XLONG, "", @"### 585")
		Code ($$not, $$reg, $$edi, 0, 0, $$XLONG, "", @"### 586")
		Code ($$and, $$regreg, $$esi, $$edi, 0, $$XLONG, "", @"### 587")
		Code ($$mov, $$regreg, daccx, $$esi, 0, $$XLONG, "", @"### 588")
	ELSE
		Code ($$mov, $$regreg, $$ecx, daccx, 0, $$XLONG, "", @"### 589")
		Code ($$mov, $$regreg, $$edi, dacc, 0, $$XLONG, "", "### 590")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, "", "### 591")
		Code ($$neg, $$reg, $$ecx, 0, 0, $$XLONG, "", "### 592")
		Code ($$add, $$regimm, $$ecx, 32, 0, $$XLONG, "", "### 593")
		Code ($$sll, $$regreg, $$esi, $$cl, 0, $$XLONG, "", "### 594")
		Code ($$add, $$regreg, $$ecx, $$edi, 0, $$XLONG, "", "### 595")
		Code ($$sar, $$regreg, $$esi, $$cl, 0, $$XLONG, "", "### 596")
		Code ($$mov, $$regreg, daccx, $$esi, 0, $$XLONG, "", @"### 597")
	END IF
	Topax1 ()
END SUB
'
'
'
' *********************************
' *****  INTRINSIC FUNCTIONS  *****
' *********************************
'
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
'
'
' *****  Dispatch to intrinsics that need early processing  *****
'
	GOTO @firstIntrinToken[ii]
'
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
	Code ($$sub, $$regimm, $$esp, frameSize, 0, $$XLONG, "", @"### 598")
'
	DO
		arg_pos$ = arg_pos$ + CHR$(tokenPtr + 1)
		new_test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
		Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
		IF XERROR THEN EXIT FUNCTION
		INC args
		IF (new_type > $$STRING) THEN	i_bad_arg = args: GOTO i_bad_type
		IF (args > 2) THEN
			IF (new_type >= $$GIANT) THEN GOTO eeeTypeMismatch
		END IF
		argOut	= $$FALSE
		ntype		= new_type
		IF (ntype < $$SLONG) THEN ntype = $$SLONG
		IF (hold_token = T_FORMAT_D) THEN
			IF (args = 2) THEN
				Code ($$st, $$roimm, ntype, $$esp, argOff, $$XLONG, "", "### 599")
				argOff = argOff + 4
			END IF
		END IF
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
														Code ($$st, $$roimm, lo, $$esp, argOff, $$XLONG, "", "### 600")
														Code ($$st, $$roimm, hi, $$esp, argOff+4, $$XLONG, "", "### 601")
						CASE $$SINGLE:	argOut	= $$TRUE
														ntype		= $$XLONG
														v				= XMAKE(SINGLE(r_addr$[new_data{$$NUMBER}]))
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, "", "### 602")
						CASE $$GIANT:		argOut	= $$TRUE
														v$$			= GIANT(r_addr$[new_data{$$NUMBER}])
														hi			= GHIGH(v$$)
														lo			= GLOW(v$$)
														Code ($$st, $$roimm, lo, $$esp, argOff, $$XLONG, "", "### 603")
														Code ($$st, $$roimm, hi, $$esp, argOff+4, $$XLONG, "", "### 604")
						CASE $$XLONG:		argOut	= $$TRUE
														v				= XLONG(r_addr$[new_data{$$NUMBER}])
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, "", "### 605")
						CASE $$ULONG:		argOut	= $$TRUE
														v				= ULONG(r_addr$[new_data{$$NUMBER}])
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, "", "### 606")
						CASE $$SLONG:		argOut	= $$TRUE
														v				= SLONG(r_addr$[new_data{$$NUMBER}])
														Code ($$st, $$roimm, v, $$esp, argOff, $$XLONG, "", "### 607")
						CASE ELSE:			acc			= OpenAccForType (ntype)
														Move (acc, ntype, new_data, ntype)
					END SELECT
				ELSE
					acc = OpenAccForType (ntype)
					SELECT CASE ntype
						CASE $$DOUBLE:	v#			= DOUBLE(r_addr$[new_data{$$NUMBER}])
														hi			= DHIGH(v#)
														lo			= DLOW(v#)
														Code ($$ld, $$regimm, acc, lo, 0, $$XLONG, "", "### 608")
														Code ($$ld, $$regimm, acc+1, hi, 0, $$XLONG, "", "### 609")
						CASE $$SINGLE:	argOut	= $$TRUE
														ntype		= $$XLONG
														v				= XMAKE(SINGLE(r_addr$[new_data{$$NUMBER}]))
														Code ($$ld, $$regimm, acc, v, 0, $$XLONG, "", "### 610")
						CASE ELSE:			Move (acc, ntype, new_data, ntype)
					END SELECT
				END IF
			ELSE
				SELECT CASE ntype
					CASE $$SINGLE:	ntype = $$XLONG
					CASE $$DOUBLE:	ntype = $$GIANT
				END SELECT
				acc		= OpenAccForType (ntype)
				Move (acc, ntype, new_data, ntype)
			END IF
		ELSE
			acc		= Top ()
			SELECT CASE ntype
				CASE $$SINGLE:	Code ($$fstp, $$ro, 0, $$esp, argOff, $$SINGLE, "", "### 611")
												argOut	= $$TRUE
												ntype		= $$XLONG
												IF inline THEN
													Code ($$ld, $$regro, acc, $$esp, argOff, $$XLONG, "", "### 612")
												ELSE
													acc			= Topax1 ()
												END IF
				CASE $$DOUBLE:	Code ($$fstp, $$ro, 0, $$esp, argOff, $$DOUBLE, "", "### 613")
												argOut	= $$TRUE
												ntype		= $$GIANT
												IF inline THEN
													Code ($$ld, $$regro, acc, $$esp, argOff, $$GIANT, "", "### 614")
												ELSE
													acc			= Topax1 ()
												END IF
			END SELECT
		END IF
'
		IF (args > max_args) THEN DEC tokenPtr: GOTO eeeTooManyArgs
		IFZ (inline OR argOut) THEN StackIt (ntype, acc, ntype, argOff)
		SELECT CASE ntype
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
'
' got all the arguments
'
	arg_pos$ = arg_pos$ + CHR$(tokenPtr)
	IF (return_type = $$TYPE_INPUT) THEN return_type = at1
	IF inline THEN
		SELECT CASE args
			CASE 1:	acc = Topax1 ()
							IF (acc != $$eax) THEN
								Code ($$mov, $$regreg, $$eax, acc, 0, nt1, "", @"### 615")
							END IF
			CASE 2: Topax2 (@acc2, @acc1)
							IF (acc1 != $$eax) THEN
								SELECT CASE nt1
									CASE $$SLONG, $$ULONG, $$XLONG
												Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 616")
									CASE $$GIANT
												Code ($$xchg, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 617")
												Code ($$xchg, $$regreg, $$edx, $$ecx, 0, $$XLONG, "", @"### 618")
									CASE ELSE
												GOTO eeeTypeMismatch
								END SELECT
							ELSE
								IF (acc2 != $$ebx) THEN GOTO eeeCompiler
							END IF
		END SELECT
	END IF
	INC toes
	new_data	= 0
	a0				= toes
	a0_type		= return_type
'
'
' *****  Dispatch to the intrinsic functions
'
igotm:
	GOTO @intrinToken [ii]			' individual routines for intrinsics
	tokenPtr = hold_place				' fall through on bad/unimplemented tokens
	GOTO eeeUnimplemented
'
' ****************************************************************
' *****  typenameAT INTRINSICS  *****  DIRECT MEMORY ACCESS  *****
' ****************************************************************
'
' *****  SBYTEAT, UBYTEAT, SSHORTAT... DOUBLEAT  *****
'
i_atops:
	opcode = $$ld
	OpenBothAccs ()
	AtOps (hold_type, @opcode, @mode, @base, @offset, 0)
	IF XERROR THEN EXIT FUNCTION
	INC toes
	a0			= toes
	a0_type	= return_type
	Code (opcode, mode, $$eax, base, offset, hold_type, "", @"### 619")
	new_type = return_type
	GOTO express_op
'
'
' ****************************************
' *****  TYPE CONVERSION INTRINSICS  *****
' ****************************************
'
' *****  SBYTE, UBYTE, SSHORT, USHORT... DOUBLE, GIANT  *****
'
i_types:
	IF (new_op <> T_RPAREN) THEN GOTO eeeSyntax
	new_type = hold_token{$$TYPE}
	SELECT CASE TRUE
		CASE (new_type == at1)
					SELECT CASE TRUE
						CASE (new_type <= $$GIANT)
									Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, "", "### 620")
						CASE (new_type == $$GIANT)
									Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, "", "### 621")
									Code ($$ld, $$regro, $$edx, $$esp, 4, $$XLONG, "", "### 622")
						CASE (new_type == $$SINGLE)
									Code ($$fld, $$ro, 0, $$esp, 0, $$SINGLE, "", "### 623")
						CASE (new_type == $$DOUBLE)
									Code ($$fld, $$ro, 0, $$esp, 0, $$DOUBLE, "", "### 624")
						CASE (new_type == $$STRING)
									Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, "", "### 625")
									IF oos[oos] = 'v' THEN
										Code ($$call, $$rel, 0, 0, 0, 0, @"__clone.a0", "### 626")
									END IF
									oos[oos] = 's'
						CASE ELSE
									PRINT "Expresso(): i_types: error: bad type" : GOTO eeeCompiler
					END SELECT
		CASE (new_type == $$STRING)
					SELECT CASE at1
						CASE $$SLONG, $$ULONG:	at1 = $$XLONG
					END SELECT
					Code ($$call, $$rel, 0, 0, 0, 0, "__cv." + typeName$[at1] + ".to.string", @"### 627")
					INC oos
					oos[oos] = 's'
		CASE (at1 == $$STRING)
					Code ($$call, $$rel, 0, 0, 0, 0, "__cv.string.to." + typeName$[new_type] + "." + CHR$(oos[oos]), @"### 628")
					DEC oos
		CASE ELSE
					SELECT CASE at1
						CASE $$SLONG	: at1 = $$XLONG
					END SELECT
					Code ($$call, $$rel, 0, 0, 0, 0, "__cv." + typeName$[at1] + ".to." + typeName$[new_type], "### 629")
	END SELECT
	IF (new_type < $$SLONG) THEN new_type = $$SLONG
	GOTO intrinDone
'
'
' *****  CLOSE (x)  *****
'
i_close:	routine$ = "__close":	GOTO ii_close
i_quit:		routine$ = "__quit":	GOTO ii_quit
i_eof:		routine$ = "__eof":		GOTO ii_eof
i_lof:		routine$ = "__lof":		GOTO ii_lof
i_pof:		routine$ = "__pof":		GOTO ii_pof

ii_close:
ii_quit:
ii_eof:
ii_lof:
ii_pof:
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IF sacc1 THEN tt1 = sacc1
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, "### 630")
	new_data = 0
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  OPEN (fileName$, mode)  *****
'
i_open:
	routine$ = "__open." + CHR$ (oos[oos])
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, "### 631")
	new_data = 0
	new_type = $$XLONG
	DEC oos
	GOTO intrinDone
	GOTO express_op
'
'
' *****  SEEK (file, pos)  *****
'
i_seek:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, "__seek", "### 632")
	new_data = 0
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  SHELL (command$)  *****
'
i_shell:
	routine$ = "__shell." + CHR$ (oos[oos])
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, "### 633")
	new_data = 0
	new_type = $$XLONG
	DEC oos
	GOTO intrinDone
	GOTO express_op
'
'
' *****  INFILE$ (fileNumber)  *****
'
i_infile_d:
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, "__infile_d", "### 634")
	INC oos
	oos[oos] = 's'
	new_data = 0
	new_type = $$STRING
	GOTO intrinDone
	GOTO express_op
'
'
' *****  INLINE$ (prompt$)  *****
'
i_inline_d:
	routine$ = "__inline_d." + CHR$ (oos[oos])
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, "### 635")
	new_data = 0
	new_type = $$STRING
	oos[oos] = 's'
	GOTO intrinDone
	GOTO express_op
'
'
' ********************************************
' *****  NUMERIC = INTRINSIC (NUMERICS)  *****
' ********************************************
'
' *****  ABS (x)  *****
'
i_abs:
	IF (at1 > $$DOUBLE) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, "__abs." + typeName$[at1], @"### 636")
	new_type	= at1
	GOTO intrinDone
'
'
' *****  BITFIELD (x&, y&)  *****
'
i_bitfield:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$and, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 637")
	Code ($$sll, $$regimm, $$eax, 5, 0, $$XLONG, "", @"### 638")
	Code ($$and, $$regimm, $$ebx, 31, 0, $$XLONG, "", @"### 639")
	Code ($$or, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 640")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  DHIGH (x#)  *****
'
i_dhigh:
	IF (at1 != $$DOUBLE) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, "", "### 641")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  DLOW (x#)  *****
'
i_dlow:
	IF (at1 != $$DOUBLE) THEN i_bad_arg = 1: GOTO i_bad_type
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  DMAKE (x&, y&)  *****
'
i_dmake:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$st, $$roreg, $$ebx, $$ebp, -8, $$XLONG, "", @"### 642")
	Code ($$st, $$roreg, $$eax, $$ebp, -4, $$XLONG, "", @"### 643")
	Code ($$fld, $$ro, 0, $$ebp, -8, $$DOUBLE, "", @"### 644")
	new_type = $$DOUBLE
	GOTO intrinDone
	GOTO express_op
'
'
' *****  ERROR (e&)  *****  returns ##ERROR : IF (arg != -1) THEN ##ERROR = arg
'
i_error:
	IF (args < 1) THEN GOTO i_too_few_args
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @"__error", "### 645")
	new_type = $$XLONG
	GOTO intrinDone
'
'
' *****  GHIGH (x$$)  *****
'
i_ghigh:
	IF (at1 != $$GIANT) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, "", @"### 646")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  GLOW (x$$)  *****
'
i_glow:
	IF (at1 != $$GIANT) THEN i_bad_arg = 1: GOTO i_bad_type
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  GMAKE (x&, y&)  *****
'
i_gmake:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$mov, $$regreg, $$edx, $$eax, 0, $$XLONG, "", @"### 647")
	Code ($$mov, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", @"### 648")
	new_type	= $$GIANT
	GOTO intrinDone
	GOTO express_op
'
'
' *****  SMAKE (x&)  *****
'
i_smake:
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$st, $$roreg, $$eax, $$ebp, -8, $$XLONG, "", "### 649")
	Code ($$fld, $$ro, 0, $$ebp, -8, $$SINGLE, "", "### 650")
	new_type	= $$SINGLE
	GOTO intrinDone
	GOTO express_op
'
'
' *****  XMAKE (x!)  *****
'
i_xmake:
	IF (at1 != $$SINGLE) THEN i_bad_arg = 1: GOTO i_bad_type
	new_type	= $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  HIGH0 (x&)  *****
' *****  HIGH1 (x&)  *****
'
i_high0: routine$ = "__high0" : groutine$ = "__high0.giant" : GOTO ii_high0
i_high1: routine$ = "__high1" : groutine$ = "__high1.giant" : GOTO ii_high1
'
ii_high0:
ii_high1:
	SELECT CASE TRUE
		CASE (q_type_long_or_addr[at1])
					Code ($$call, $$rel, 0, 0, 0, 0, @routine$, @"### 651")
		CASE (at1 = $$GIANT)
					Code ($$call, $$rel, 0, 0, 0, 0, @groutine$, @"### 652")
		CASE ELSE
					i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  LIBRARY (x)  *****
'
i_library:
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 653")
	IF library THEN Code ($$not, $$reg, $$eax, 0, 0, $$XLONG, "", "### 654")
	new_type = $$XLONG
	GOTO intrinDone
'
'
' *****  MIN (x, y)  *****
' *****  MAX (x, y)  *****
'
i_min:	routine$ = "__MIN." + typeName$[at1]:	GOTO ii_minmax
i_max:	routine$ = "__MAX." + typeName$[at1]:	GOTO ii_minmax
'
ii_minmax:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 > $$DOUBLE) THEN i_bad_arg = 1:									GOTO i_bad_type
	IF (at2 > $$DOUBLE) THEN i_bad_arg = 2:									GOTO i_bad_type
	IF typeConvert[at1,at2]{{$$BYTE0}} THEN i_bad_arg = 2:	GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, "### 655")
	new_type	= at1
	GOTO intrinDone
'
'
' *****  ROTATEL (x, y)  *****
'
i_rotatel:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$mov, $$regreg, $$ecx, $$ebx, 0, $$XLONG, "", @"### 656a")
	Code ($$rol, $$regreg, $$eax, $$cl, 0, $$XLONG, "", @"### 656b")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  ROTATER (x, y)  *****
'
i_rotater:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	Code ($$mov, $$regreg, $$ecx, $$ebx, 0, $$XLONG, "", @"### 656c")
	Code ($$ror, $$regreg, $$eax, $$cl, 0, $$XLONG, "", @"### 656d")
	new_type = $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  CLR  (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  SET  (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  EXTS (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  EXTU (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
' *****  MAKE (x&, y&, [z&])   1st arg may be LONG or SINGLE  *****
'
i_clr:			iop$ = "__clr":		GOTO ii_clr
i_set:			iop$ = "__set":		GOTO ii_set
i_exts:			iop$ = "__ext":		GOTO ii_exts
i_extu:			iop$ = "__extu":	GOTO ii_extu
i_make:			iop$ = "__make":	GOTO ii_make
'
ii_clr:
ii_set:
ii_exts:
ii_extu:
ii_make:
	IF (args < 2) THEN GOTO i_too_few_args
	IFF q_type_long[at1] THEN
		IF (at1 <> $$SINGLE) THEN i_bad_arg = 1: GOTO i_bad_type
	END IF
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	IF (args = 2) THEN
		Code ($$call, $$rel, 0, 0, 0, 0, iop$ + ".2arg", @"### 658")
	ELSE
		IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
		Code ($$call, $$rel, 0, 0, 0, 0, iop$ + ".3arg", @"### 659")
	END IF
	new_type = $$XLONG
	GOTO intrinDone
'
'
' *****  INT (x)  *****
' *****  FIX (x)  *****
'
i_int:	routine$ = "__int.":		GOTO ii_int
i_fix:	routine$ = "__fix.":		GOTO ii_fix
'
ii_int:
ii_fix:
	routine$ = routine$ + typeName$[at1]
	SELECT CASE at1
		CASE $$SINGLE, $$DOUBLE
				Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 660")
		CASE $$SLONG, $$ULONG, $$XLONG
				Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, "", "### 661")
		CASE $$GIANT
				Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, "", "### 662")
				Code ($$ld, $$regro, $$edx, $$esp, 4, $$XLONG, "", "### 663")
		CASE ELSE
				i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type	= at1
	GOTO intrinDone
'
'
' *****  SGN (x)  *****
'
i_sgn:
	SELECT CASE at1
		CASE $$ULONG
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$or, $$regreg, $$eax, $$eax, 0, $$XLONG,"", @"### 664")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 665")
					Code ($$mov, $$regimm, $$eax, 1, 0, $$XLONG,"", @"### 666")
					EmitLabel (@d1$)
		CASE $$SLONG, $$XLONG
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$or, $$regreg, $$eax, $$eax, 0, $$XLONG, "", @"### 667")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 668")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 669")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 670")
					EmitLabel (@d1$)
		CASE $$GIANT
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$or, $$regreg, $$eax, $$edx, 0, $$XLONG, "", @"### 671")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 672")
					Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, "", @"### 673")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 674")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 675")
					EmitLabel (@d1$)
		CASE $$SINGLE
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, "", "### 676")
					Code ($$and, $$regimm, $$eax, 0x7FFFFFFF, 0, $$XLONG, "", "### 677")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, "### 678")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, "", "### 679")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 680")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 681")
					EmitLabel (@d1$)
		CASE $$DOUBLE
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$mov, $$regreg, $$esi, $$edx, 0, $$XLONG, "", "### 682")
					Code ($$and, $$regimm, $$edx, 0x7FFFFFFF, 0, $$XLONG, "", "### 683")
					Code ($$or, $$regreg, $$eax, $$edx, 0, $$XLONG, "", "### 684")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, "### 685")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, "", "### 686")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 687")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 688")
					EmitLabel (@d1$)
		CASE ELSE
					i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type	= $$SLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  SIGN (x)  *****
'
i_sign:
	SELECT CASE at1
		CASE $$ULONG
					Code ($$mov, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 689")
		CASE $$SLONG, $$XLONG
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 690")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 691")
		CASE $$GIANT
					Code ($$mov, $$regreg, $$eax, $$edx, 0, $$XLONG, "", "### 692")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 693")
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 694")
		CASE $$SINGLE
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, "", "### 695")
					Code ($$and, $$regimm, $$eax, 0x7FFFFFFF, 0, $$XLONG, "", "### 696")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, "### 697")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, "", "### 698")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 699")
					EmitLabel (@d1$)
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 700")
		CASE $$DOUBLE
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$mov, $$regreg, $$esi, $$edx, 0, $$XLONG, "", "### 701")
					Code ($$and, $$regimm, $$edx, 0x7FFFFFFF, 0, $$XLONG, "", "### 702")
					Code ($$or, $$regreg, $$eax, $$edx, 0, $$XLONG, "", "### 703")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, "### 704")
					Code ($$mov, $$regreg, $$eax, $$esi, 0, $$XLONG, "", "### 705")
					Code ($$sar, $$regimm, $$eax, 31, 0, $$XLONG, "", @"### 706")
					EmitLabel (@d1$)
					Code ($$or, $$regimm, $$eax, 1, 0, $$XLONG, "", @"### 707")
		CASE ELSE
					i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	new_type	= $$SLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  TAB (x)  *****
'
i_tab:
	IFZ inPrint THEN GOTO eeeSyntax
	IFF q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$ld, $$regro, $$eax, $$esp, 0, $$XLONG, "", @"### 708")
	new_type	= $$XLONG
	GOTO intrinDone
'
'
' *********************************************
' *****  NUMERIC = INTRINSIC (STRING...)  *****
' *********************************************
'
'
' *****  ASC (x$, [i])  *****
'
i_asc:
	routine$ = "__asc."
	IF (at1 <> $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (args = 1) THEN
		Code ($$mov, $$roimm, 1, $$esp, 4, $$XLONG, "", @"### 709")
	ELSE
		IFZ q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	END IF
	dest$			= routine$ + CHR$ (oos[oos])
	Code ($$call, $$rel, 0, 0, 0, 0, dest$, @"### 710")
	DEC oos
	new_type	= $$XLONG
	GOTO intrinDone
'
'
' *****  LEN (x$)  *****
' *****  SIZE (x$)  *****
'
i_len:
i_size:
	acc			= Top ()
	stackedString = $$FALSE
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (oos[oos] = 'v') THEN
		upper = $$FALSE
		GOSUB GetSizeOrUpperFromHeader
	ELSE
		INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
		IF (acc != $$eax) THEN Code ($$mov, $$regreg, $$eax, acc, 0, $$XLONG, "", "### 711")
		Code ($$or, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 712")
		Code ($$jz, $$rel, 0, 0, 0, 0, d1$, "### 713")
		Code ($$mov, $$regreg, $$esi, $$eax, 0, $$XLONG, "", "### 714")
		Code ($$ld, $$regro, $$eax, $$eax, -8, $$XLONG, "", "### 715")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", "### 716")
		EmitLabel (@d1$)
	END IF
'
doneSize:
	DEC oos
	new_type	= $$XLONG
	GOTO intrinDone
	GOTO express_op
'
'
' *****  CSIZE (x$)  *****
'
i_csize:
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, "__csize." + CHR$ (oos[oos]), @"### 717")
	DEC oos
	new_type	= $$XLONG
	GOTO intrinDone
'
'
' *****  INCHR   (x$, y$ [,z])  *****		'
' *****  INSTR   (x$, y$ [,z])  *****		'
' *****  INCHRI  (x$, y$ [,z])  *****		' case insensitive
' *****  INSTRI  (x$, y$ [,z])  *****		' case insensitive
' *****  RINCHR  (x$, y$ [,z])  *****		' reverse search
' *****  RINSTR  (x$, y$ [,z])  *****		' reverse search
' *****  RINCHRI (x$, y$ [,z])  *****		' reverse search, case insensitive
' *****  RINSTRI (x$, y$ [,z])  *****		' reverse search, case insensitive
'
i_inchr:		routine$ = "__inchr.":		GOTO ii_inetc
i_instr:		routine$ = "__instr.":		GOTO ii_inetc
i_inchri:		routine$ = "__inchri.":		GOTO ii_inetc
i_instri:		routine$ = "__instri.":		GOTO ii_inetc
i_rinchr:		routine$ = "__rinchr.":		GOTO ii_inetc
i_rinstr:		routine$ = "__rinstr.":		GOTO ii_inetc
i_rinchri:	routine$ = "__rinchri.":	GOTO ii_inetc
i_rinstri:	routine$ = "__rinstri.":	GOTO ii_inetc
'
ii_inetc:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	ab1 = at1{4,0}
	IF (at1 <> at2) THEN i_bad_arg = 2: GOTO i_bad_type
	IF (args = 2) THEN
		Code ($$st, $$roimm, 0, $$esp, 8, $$XLONG, "", @"### 718")
	ELSE
		IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, routine$ + CHR$(oos[oos-1]) + CHR$(oos[oos]), @"### 719")
	oos = oos - 2
	new_type	= $$XLONG
	GOTO intrinDone
'
'
' ******************************************
' *****  STRING = INTRINSIC (NUMERIC)  *****
' ******************************************
'
'
' *****  ERROR$ (e)  *****  returns error string
'
i_error_d:
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, @"__error.d", "### 720")
	INC oos
	oos[oos] = 's'
	new_type = $$STRING
	GOTO intrinDone
'
'
' *****  VERSION$ (e)  *****  returns VERSION statement string
' *****  PROGRAM$ (e)  *****  returns PROGRAM statement string
'
i_version_d:	getToken = versionToken : GOTO i_literal_string
i_program_d:	getToken = programToken : GOTO i_literal_string
'
i_literal_string:
	IFZ q_type_long[at1] THEN i_bad_arg = 1 : GOTO i_bad_type
	IF getToken THEN
		Move ($$eax, $$XLONG, getToken, $$XLONG)
		Code ($$call, $$rel, 0, 0, 0, 0, @"__clone.a0", "### 721")
	ELSE
		Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 722")
	END IF
	INC oos
	oos[oos] = 's'
	new_type = $$STRING
	GOTO intrinDone
'
'
' *****  NULL$ (x)  *****
' *****  SPACE$ (x)  *****
' *****  CSTRING$ (x)  *****
'
i_null_d:			routine$ = "__null.d":		GOTO ii_null_d
i_space_d:		routine$ = "__space.d":		GOTO ii_space_d
i_cstring_d:	routine$ = "__cstring.d":	GOTO ii_cstring_d
'
ii_null_d:
ii_space_d:
ii_cstring_d:
	SELECT CASE at1
		CASE $$SLONG, $$ULONG, $$XLONG
				Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 723")
		CASE ELSE
				i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	INC oos
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
' *****  BIN$  (x [,y])  *****
' *****  BINB$ (x [,y])  *****
' *****  HEX$  (x [,y])  *****
' *****  HEXX$ (x [,y])  *****
' *****  OCT$  (x [,y])  *****
' *****  OCTO$ (x [,y])  *****
'
i_bin_d:		groutine$ = "__bin.d.giant":	routine$ = "__bin.d":		GOTO ii_bin_d
i_binb_d:		groutine$ = "__binb.d.giant":	routine$ = "__binb.d":	GOTO ii_binb_d
i_hex_d:		groutine$ = "__hex.d.giant":	routine$ = "__hex.d":		GOTO ii_hex_d
i_hexx_d:		groutine$ = "__hexx.d.giant":	routine$ = "__hexx.d":	GOTO ii_hexx_d
i_oct_d:		groutine$ = "__oct.d.giant":	routine$ = "__oct.d":		GOTO ii_oct_d
i_octo_d:		groutine$ = "__octo.d.giant":	routine$ = "__octo.d":	GOTO ii_octo_d
'
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
	END IF
	IF (args = 1) THEN
		Code ($$mov, $$roimm, 0, $$esp, argOff, $$XLONG, "", "### 724")
	ELSE
		IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 725")
	INC oos
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
' *****  CHR$ (x, [y])  *****
'
i_chr_d:
	IFZ q_type_long[at1] THEN i_bad_arg = 1: GOTO i_bad_type
	IF (args = 1) THEN
		Code ($$st, $$roimm, 1, $$esp, 4, $$XLONG, "", "### 726")
	ELSE
		IFZ q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, "__chr.d", @"### 727")
	INC oos
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
' **************************
' *****  SIGNED$	(x)  *****
' *****  STRING$	(x)  *****
' *****  STRING		(x)  *****
' *****  STR$			(x)  *****
' **************************
'
i_signed_d:
	IF (at1 = $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	routine$ = "__signed.d." + typeName$[at1]
	GOTO istring
'
i_string_d:
i_string:
	IF (at1 = $$STRING) THEN GOTO i_string_string
	routine$ = "__string." + typeName$[at1]
	GOTO istring
'
i_str_d:
	IF (at1 = $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	routine$ = "__str.d." + typeName$[at1]
	GOTO istring
'
istring:
	SELECT CASE at1
		CASE $$SLONG, $$ULONG, $$XLONG
		CASE $$GIANT, $$SINGLE, $$DOUBLE
		CASE $$STRING
		CASE ELSE: i_bad_arg = 1: GOTO i_bad_type
	END SELECT
	IF (at1 = $$STRING) THEN DEC oos
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 728")
	INC oos
	oos[oos] = 's'
	new_type = $$STRING
	GOTO intrinDone
'
i_string_string:
	Code ($$mov, $$regro, $$eax, $$esp, 0, $$XLONG, "", "### 729")
	IF oos[oos] = 'v' THEN
		Code ($$call, $$rel, 0, 0, 0, 0, @"__clone.a0", "### 730")
		oos[oos] = 's'
	END IF
	new_type = $$STRING
	GOTO intrinDone
'
' ***************************************************
' *****  STRING = INTRINSIC (STRING [, XLONG])  *****
' ***************************************************
'
'
' ********************************************************
' *****  FORMAT$ (f$, argType, (arg$, arg$$, arg#))  *****
' ********************************************************
'
' last argument can be integer / float / string
'
i_format_d:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF ((at2 != $$GIANT) AND (at2 != $$DOUBLE)) THEN
		Code ($$st, $$roimm, 0, $$esp, 12, $$XLONG, "", "### 731")
	END IF
'	Code ($$call, $$rel, 0, 0, 0, 0, "XxxFormat$$16", "### 732")				' gas ?
	Code ($$call, $$rel, 0, 0, 0, 0, "XxxFormat$_16", "### 732")				' unspas
	IF (at2 = $$STRING) THEN
		IF (oos[oos] = 's') THEN
			Code ($$ld, $$regro, $$esi, $$esp, -8, $$XLONG, "", "### 733")
			Code ($$call, $$rel, 0, 0, 0, 0, @"_____free", "### 734")
			oos[oos] = 0
			DEC oos
		END IF
	END IF
	IF (oos[oos] = 's') THEN
		Code ($$ld, $$regro, $$esi, $$esp, -16, $$XLONG, "", "### 735")
		Code ($$call, $$rel, 0, 0, 0, 0, @"_____free", "### 736")
	END IF
	oos[oos] = 's'
	new_type = $$STRING
	GOTO express_op
'
'
'
' *******************************
' *****  LJUST$ (x$, y)  ********
' *****  CJUST$ (x$, y)  ********
' *****  RJUST$ (x$, y)  ********
' *****  LCLIP$ (x$ [, y])  *****  Default argument value = 1
' *****  RCLIP$ (x$ [, y])  *****
' *****  LEFT$  (x$ [, y])  *****
' *****  RIGHT$ (x$ [, y])  *****
' *******************************
'
i_ljust_d:	routine$ = "__ljust.d.":	oa = $$FALSE:	GOTO ii_ljust_d
i_cjust_d:	routine$ = "__cjust.d.":	oa = $$FALSE:	GOTO ii_cjust_d
i_rjust_d:	routine$ = "__rjust.d.":	oa = $$FALSE:	GOTO ii_rjust_d
i_lclip_d:	routine$ = "__lclip.d.":	oa = $$TRUE:	GOTO ii_lclip_d
i_rclip_d:	routine$ = "__rclip.d.":	oa = $$TRUE:	GOTO ii_rclip_d
i_left_d:		routine$ = "__left.d.":		oa = $$TRUE:	GOTO ii_left_d
i_right_d:	routine$ = "__right.d.":	oa = $$TRUE:	GOTO ii_right_d
'
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
		Code ($$st, $$roimm, 1, $$esp, 4, $$XLONG, "", @"### 737")
	ELSE
		IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	END IF
	dest$ = routine$ + CHR$(oos[oos])
	Code ($$call, $$rel, 0, 0, 0, 0, dest$, @"### 738")
	oos[oos] = 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
' *******************************
' *****  MID$ (x$, y [,z])  *****  Default value of [,z] = infinity
' *******************************
'
i_mid_d:
	IF (args < 2) THEN GOTO i_too_few_args
	IF (args = 2) THEN at3 = $$XLONG
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IFF q_type_long[at2] THEN i_bad_arg = 2: GOTO i_bad_type
	IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
	IF (args = 2) THEN Code ($$st, $$roimm, 0x7FFFFFFF, $$esp, 8, $$XLONG, "", @"### 739")
	Code ($$call, $$rel, 0, 0, 0, 0, "__mid.d." + CHR$(oos[oos]), @"### 740")
	oos[oos]	= 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
' *************************************
' *****  STUFF$ (s$, i$, y [,z])  *****
' *************************************
'
i_stuff_d:
	IF (args < 3) THEN GOTO i_too_few_args
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	IF (at1 <> at2) THEN i_bad_arg = 2: GOTO i_bad_type
	IFF q_type_long[at3] THEN i_bad_arg = 3: GOTO i_bad_type
	IF (args = 3) THEN
		Code ($$st, $$roimm, -1, $$esp, 12, $$XLONG,"", @"### 741")
	ELSE
		IFF q_type_long[at4] THEN i_bad_arg = 4: GOTO i_bad_type
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, "__stuff.d." + CHR$(oos[oos-1]) + CHR$(oos[oos]), @"### 742")
	DEC oos
	oos[oos]	= 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
' *****  TRIM$ (x$)  *****
' *****  LTRIM$ (x$)  *****
' *****  RTRIM$ (x$)  *****
' *****  LCASE$ (x$)  *****
' *****  UCASE$ (x$)  *****
' *****  CSIZE$ (x$)  *****
'
i_trim_d:			routine$ = "__trim.d.":			GOTO ii_trim_d
i_ltrim_d:		routine$ = "__ltrim.d.":		GOTO ii_ltrim_d
i_rtrim_d:		routine$ = "__rtrim.d.":		GOTO ii_rtrim_d
i_lcase_d:		routine$ = "__lcase.d.":		GOTO ii_lcase_d
i_ucase_d:		routine$ = "__ucase.d.":		GOTO ii_ucase_d
i_csize_d:		routine$ = "__csize.d.":		GOTO ii_csize_d
'
ii_ltrim_d:
ii_rtrim_d:
ii_trim_d:
ii_lcase_d:
ii_ucase_d:
ii_csize_d:
	IF (at1 != $$STRING) THEN i_bad_arg = 1: GOTO i_bad_type
	Code ($$call, $$rel, 0, 0, 0, 0, routine$ + CHR$(oos[oos]), @"### 743")
	oos[oos]	= 's'
	new_type	= $$STRING
	GOTO intrinDone
'
'
'
' ***************************************
' *****  NUMERIC = INTRINSIC (???)  *****
' ***************************************
'
'
' *****  SIZE (typeName)  *****              built-in or user-defined
' *****  SIZE (simpleVariable)  *****
' *****  SIZE (stringVariable)  *****
' *****  SIZE (compositeVariable)  *****
' *****  SIZE (compositeVariable.componentName...)  *****
' *****  SIZE (arrayName [dimension, dimension, ...])  *****
'
' *****  TYPE (typeName)  *****              built-in or user-defined
' *****  TYPE (simpleVariable)  *****
' *****  TYPE (stringVariable)  *****
' *****  TYPE (compositeVariable)  *****
' *****  TYPE (compositeVariable.componentName...)  *****
' *****  TYPE (arrayName [dimension, dimension, ...])  *****
'
i_lenof:
i_sizeof:
	getSize		= $$TRUE
	getType		= $$FALSE
	GOTO i_sizeof_typeof
'
i_typeof:
	getSize		= $$FALSE
	getType		= $$TRUE
	GOTO i_sizeof_typeof
'
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
						CASE T_GOADDR:		vartype = $$GOADDR
						CASE T_SBYTE:			varType = $$SBYTE
						CASE T_SINGLE:		varType = $$SINGLE
						CASE T_SLONG:			varType = $$SLONG
						CASE T_SSHORT:		varType = $$SSHORT
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
		CASE $$KIND_VARIABLES
					aat = argToken{$$NUMBER}
					IFZ m_addr$[aat] THEN AssignAddress (argToken)
					IF XERROR THEN EXIT FUNCTION
					varType = TheType (argToken)
					IF (varType = $$STRING) THEN
						check = PeekToken ()
						IF (check = T_RPAREN) THEN
							dacc	= OpenAccForType ($$XLONG)
							IF getType THEN
								Code ($$mov, $$regimm, dacc, $$STRING, 0, $$XLONG, "", "### 744")
							ELSE
								Move (dacc, $$XLONG, argToken, $$XLONG)
								upper = $$FALSE
								GOSUB GetSizeOrUpperFromHeader
							END IF
							token = NextToken ()
							EXIT SELECT
						ELSE
							tokenPtr = hold
							GOTO intrinsic_normal
						END IF
					END IF
					GOSUB SizeofTypeofTypesAndVariables
		CASE $$KIND_ARRAYS
					aat = argToken{$$NUMBER}
					IFZ m_addr$[aat] THEN AssignAddress (argToken)
					IF XERROR THEN EXIT FUNCTION
					varType = TheType (argToken)
'					IF (varType = $$STRING) THEN GOTO eeeTypeMismatch
					GOSUB SizeofTypeofArrays
		CASE ELSE
					GOTO eeeKindMismatch
	END SELECT
	IF (token != T_RPAREN) THEN GOTO eeeSyntax
	new_data	= 0
	new_type	= $$XLONG
	GOTO express_op
'
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
						END IF
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
				END IF
				varType		= typeEleType[varType, component]
				IF (varType = $$STRING) THEN
					IF inarray THEN
						typeSize = typeEleStringSize[oldType, component]
					ELSE
						typeSize = typeEleSize[oldType, component]
					END IF
				END IF
				found			= $$TRUE
				EXIT DO
			END IF
			INC component
		LOOP WHILE (component <= typeEleCount[varType])
		IFZ found THEN GOTO eeeComponent
	LOOP
	IF (varType != $$STRING) THEN
		typeSize	= typeSize[varType]
		IF array THEN typeSize	= elements * typeSize
	END IF
	IF (typeSize <= 0) THEN PRINT "size0": GOTO eeeCompiler
'	IF (typeSize >= 65535) THEN PRINT "size1": GOTO eeeCompiler
	SELECT CASE TRUE
		CASE getSize:		value = typeSize
		CASE getType:		value = varType
	END SELECT
	dacc					= OpenAccForType ($$XLONG)
	Code ($$mov, $$regimm, dacc, value, 0, $$XLONG, "", @"### 745")
	token	= NextToken ()
END SUB
'
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
		END IF
		token			= NextToken ()
		dacc			= Top ()
		new_op		= token
	END IF
'
' Get # of elements out of header and multiply times size of array type
'
	SELECT CASE TRUE
		CASE getSize
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					IF stringData THEN
						Code ($$or, $$regreg, dacc, dacc, 0, $$XLONG, "", @"### 746")
						Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 747")
						Code ($$ld, $$regro, dacc, dacc, -8, $$XLONG, "", @"### 748")
					ELSE
						Code ($$or, $$regreg, dacc, dacc, 0, $$XLONG, "", @"### 749")
						Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 750")
						Code ($$ld, $$regro, $$esi, dacc, -4, $$XLONG, "", @"### 751")
						Code ($$ld, $$regro, dacc, dacc, -8, $$XLONG, "", @"### 752")
						Code ($$and, $$regimm, $$esi, 0x0000FFFF, 0, $$XLONG, "", @"### 753")
						Code ($$imul, $$regreg, dacc, $$esi, 0, $$XLONG, "", @"### 754")
					END IF
					EmitLabel (@d1$)
		CASE getType
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					Code ($$or, $$regreg, dacc, dacc, 0, $$XLONG, "", "### 755")
					Code ($$jz, $$rel, 0, 0, 0, 0, d1$, "### 756")
					Code ($$ld, $$regro, dacc, dacc, -2, $$UBYTE, "", "### 757")
					EmitLabel (@d1$)
	END SELECT
END SUB
'
'
' *****  UBOUND (arrayName [])  *****
' *****  UBOUND (arrayName [dimension, dimension, ...])  *****
'
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
			END IF
			token			= NextToken ()
			IF (token != T_RPAREN) THEN GOTO eeeSyntax
			IF (arrayType = $$STRING) THEN DEC oos
			dacc			= Top ()
			new_op		= token
'			IF (dacc != $$eax) THEN
'				Code ($$mov, $$regreg, $$eax, dacc, 0, $$XLONG,"", @"### 758")
'			END IF
		END IF
	END IF
	upper = $$TRUE
	GOSUB GetSizeOrUpperFromHeader
	new_data	= 0
	new_type	= $$XLONG
	GOTO express_op
'
' Get size/ubound from string/array header
'
SUB GetSizeOrUpperFromHeader
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$or, $$regreg, dacc, dacc, 0, $$XLONG, "", @"### 759")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 760")
	Code ($$ld, $$regro, dacc, dacc, -8, $$XLONG, "", @"### 761")
	EmitLabel (@d1$)
	IF upper THEN Code ($$dec, $$reg, dacc, 0, 0, $$XLONG, "", @"### 762")
END SUB
'
'
' *****  GOADDRESS (labelSymbol)  *****
'
i_goaddress:
	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token = NextToken ()
	kind	= token{$$KIND}
	stype = token{$$TYPE}
	IF (kind <> $$KIND_LABELS) THEN GOTO eeeSyntax
	IF (stype <> $$GOADDR) THEN GOTO eeeTypeMismatch
	dr	= OpenAccForType ($$GOADDR)
'
i_goaddr_of_reg:
	go_name$	= tab_lab$[token{$$NUMBER}]
	Code ($$mov, $$regimm, dr, 0, 0, $$XLONG, go_name$, @"### 763")
	token			= NextToken ()
	IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	new_type	= $$GOADDR
	new_op		= token
	GOTO express_op
'
'
' *****  SUBADDRESS (SubName)  *****
'
i_subaddress:
	token	= NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token	= NextToken ()
	kind	= token{$$KIND}
	stype	= token{$$TYPE}
	IF (kind <> $$KIND_LABELS) THEN GOTO eeeSyntax
	IF (stype <> $$SUBADDR) THEN GOTO eeeTypeMismatch
	dr		= OpenAccForType ($$SUBADDR)
'
i_subaddr_of_reg:
	sub_name$ = tab_lab$[token{$$NUMBER}]
	Code ($$mov, $$regimm, dr, 0, 0, $$XLONG, sub_name$, @"### 764")
	token			= NextToken ()
	IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	new_type	= $$SUBADDR
	new_op		= token
	GOTO express_op
'
'
' *****  FUNCADDRESS (FuncName())  *****
'
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
'
i_funcaddr_of_reg:
	funcaddrFuncNumber = funcToken{$$NUMBER}
	funcaddrToken = funcToken[funcaddrFuncNumber]
	IFZ (funcaddrToken AND $$MASK_DECLARED) THEN
		funcaddrToken = XxxUndeclaredFunction (funcaddrToken)
		IFZ (funcaddrToken AND $$MASK_DECLARED) THEN GOTO eeeUndeclared
	END IF
	funcaddrScope	= funcScope[funcaddrFuncNumber]
	SELECT CASE funcaddrScope
		CASE $$FUNC_EXTERNAL, $$FUNC_DECLARE
					funcLabel$ = funcLabel$[funcaddrFuncNumber]
		CASE $$FUNC_INTERNAL
					funcLabel$ = "func" + HEX$(funcaddrFuncNumber)
		CASE ELSE
					PRINT "funcScope": GOTO eeeCompiler
	END SELECT
	IF XERROR THEN EXIT FUNCTION
	Code ($$mov, $$regimm, dr, 0, 0, $$XLONG, @funcLabel$, @"### 765")
	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	token = NextToken ()
	IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	IF ifuncaddr THEN
		ifuncaddr = $$FALSE
		token		= NextToken ()
		IF (token <> T_RPAREN) THEN GOTO eeeSyntax
	END IF
	new_data	= $$FALSE
	new_type	= $$FUNCADDR
	new_op		= token
	GOTO express_op
'
'
' *****  INTRINSIC SUPPORT  *****
'
intrinDone:
	Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 766")
	GOTO express_op
'
i_bad_type:
	tokenPtr = arg_pos${i_bad_arg-1}
	GOTO eeeTypeMismatch
'
i_too_few_args:
	IF args THEN tokenPtr = arg_pos${args-1}
	GOTO eeeTooFewArgs
'
'
'
' *****************************************
' *****  FUNCTIONS  *****  FUNCTIONS  *****
' *****************************************
'
express_function:
	args = 0
	argBytes = 0
	fkind = token{$$KIND}
	hold_func_ptr = tokenPtr
'
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
		INC labelNumber : fzip$ = "_" + HEX$(labelNumber, 4)
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
		END IF
	END IF
'
	old_infunc	= infunc
	hold_func		= token
	infunc			= token
	func_num		= token{$$NUMBER}
	SELECT CASE fkind
		CASE $$KIND_FUNCTIONS
					passError		= $$TRUE
					IF (funcScope[func_num] = $$FUNC_EXTERNAL) THEN
						IF (funcKind[func_num] = $$CFUNC) THEN passError = $$FALSE
					END IF
					IFZ funcArg[func_num, ] THEN
						token = XxxUndeclaredFunction (token)
						IFZ funcArg[func_num, ] THEN GOTO eeeUndeclared
						hold_func = token
					END IF
					callKind = funcKind[func_num]
					ATTACH funcArg[func_num, ] TO temp[]
					CloneArrayXLONG (@parArg[], @temp[])
					ATTACH temp[] TO funcArg[func_num, ]
					func_type		= parArg[0] {$$WORD0}
					total_args	= parArg[0] {$$BYTE2}
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
					func_type		= parArg[0] {$$WORD0}
					total_args	= parArg[0] {$$BYTE2}
'					callKind		= $$XFUNC													' xxxxxxxxxx
					callKind		= parArg[0] >> 29									' xxxxxxxxxx
					IFZ callKind THEN callKind = $$XFUNC					' xxxxxxxxxx
		CASE ELSE
					PRINT "eeefuncaddr000":	GOTO eeeCompiler
	END SELECT
	DIM argArg[]
	CloneArrayXLONG (@argArg[], @parArg[])
	IF (func_type AND (func_type < $$SLONG)) THEN func_type = $$XLONG
'
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
	END IF
'
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
				END IF
			END IF
		END IF
		IFZ hold_func{$$ALLO} THEN
			hold_func = XxxUndeclaredFunction (hold_func)
			IFZ hold_func{$$ALLO} THEN GOTO eeeUndeclared
			callKind = funcKind[func_num]
		END IF
	END IF
'
	token = NextToken ()
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
'
' if FUNCADDR variable or array, test function address and skip if addr = 0
'
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
					Code ($$xor, $$regreg, $$R11, $$R11, 0, $$XLONG,"", @"### 767")
					Code ($$or, $$regreg, $$R10, $$R10, 0, $$XLONG,"", @"### 768")
					Code ($$jz, $$rel, 0, 0, 0, 0, fzip$, @"### 769")
					Push ($$RA0, $$XLONG)
		CASE ELSE:		PRINT "eeefuncaddr001":	GOTO eeeCompiler
	END SELECT
'
' IF no arguments, skip argument processing
'
	check = PeekToken ()
	IF (check = T_RPAREN) THEN
		token		= NextToken ()
		noArgs	= $$TRUE
		new_op	= token
		GOTO PastArgs
	END IF
	noArgs		= $$FALSE
'
	IF (old_op = T_ADDR_OP) THEN DEC tokenPtr: GOTO eeeSyntax
	hold_rerun = tokenPtr
'
' ********************************
' *****  FUNCTION ARGUMENTS  *****
' ********************************
'
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
			CASE $$SFUNC:	PRINT "$$SFUNC.c" : GOTO eeeCompiler
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
						CASE ELSE:								argSize = argSize + 4
					END SELECT
				END IF
			NEXT i
		END IF
	END IF
'
' create frame if necessary  -  CFUNCTIONs
'
'	IF frame THEN Code ($$sub, $$regimm, $$esp, argSize, 0, $$XLONG, "", @"### 770")
'
	DO
		qref = PeekToken ()							'  "@" (BYREF) prefix on next argument ?
		IF (qref = T_ATSIGN) THEN
			INC refCount
			qref = $$TRUE
			trash = NextToken ()					' skip "@"
		ELSE
			qref = $$FALSE
		END IF
'
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
		END IF
'
		IFZ skipit THEN
			test = 0: new_op = 0: new_prec = 0: new_data = 0: new_type = 0
			Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
			IF XERROR THEN EXIT FUNCTION
			IFZ new_type THEN GOTO eeeTypeMismatch
			IF (new_type < $$SLONG) THEN new_type = $$SLONG
		END IF
		skipit				= $$FALSE
		IF (new_type = $$STRING) THEN
			string_type	= $$TRUE
		ELSE
			string_type	= $$FALSE
		END IF
'
		IFZ refarray THEN
			IF (new_type >= $$SCOMPLEX) THEN
				IF new_data THEN
					dacc = OpenAccForType (new_type)
					Move (dacc, $$XLONG, new_data, $$XLONG)
					new_data = 0
				ELSE
					dacc = Top ()
					IF (dacc != $$RA0) THEN PRINT "??? OK ???"
				END IF
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
					Code ($$mov, $$regimm, $$ecx, csizer, 0,$$XLONG,"", @"### 771")
					Code ($$mov, $$regreg, dacc, $$edi, 0, $$XLONG, "", @"### 772")
					Code ($$call, $$rel, 0,0,0,0,"__assignComposite", @"### 773")
				END IF
			END IF
		END IF
'
		SELECT CASE TRUE
			CASE etc:			IF (argNum > total_args) THEN
											parKindType			= parArg[argNum] AND 0xFFFF0000
											parArg[argNum]	= parKindType OR new_type
											argKindType			= argArg[argNum] AND 0xFFFF0000
											argArg[argNum]	= argKindType OR new_type
											to_type					= new_type
										ELSE
											to_type					= parArg[argNum]{$$WORD0}
										END IF
			CASE ELSE:		IF (argNum > total_args) THEN
											IF func_num THEN GOTO eeeTooManyArgs
										END IF
										to_type						= parArg[argNum]{$$WORD0}
										IF (to_type = $$ANY) THEN
											IF refarray THEN
												kind	= $$KIND_ARRAYS
											ELSE
												kind	= $$KIND_VARIABLES
												IF (parArg[argNum]{$$KIND} = $$KIND_ARRAYS) THEN GOTO eeeKindMismatch
											END IF
											parKindType			= parArg[argNum] AND 0x00FF0000
											parArg[argNum]	= parKindType OR (kind << 24) OR new_type
											argKindType			= argArg[argNum] AND 0x00FF0000
											argArg[argNum]	= argKindType OR (kind << 24) OR new_type
											to_type					= new_type
										END IF
		END SELECT
'
'	  Check for KIND MISMATCH, except etc...
'
		IF func_num OR (argNum > total_args) THEN
			pkind = parArg[argNum]{$$KIND}
			IF refarray THEN
				IF (pkind != $$KIND_ARRAYS) THEN
					tokenPtr = tokenPtr - 3
					GOTO eeeKindMismatch
				END IF
			ELSE
				IF (pkind = $$KIND_ARRAYS) THEN DEC tokenPtr: GOTO eeeKindMismatch
			END IF
		END IF
		IFZ refarray THEN
			IF (to_type < $$SLONG) THEN to_type = $$SLONG
		END IF
		argToken[argNum]	= new_data
		from_type = new_type
		IF (to_type != $$ANY) THEN
			IF ((to_type = $$STRING) XOR (from_type = $$STRING)) THEN
				GOTO eeeTypeMismatch
			END IF
		END IF
'
' If type conversion is required to assign value back to original
' variable, then fixArgs stack handling method is necessary to avoid
' overwriting arguments on stack when calling conversion routines.
'
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
				END IF
			END IF
		END IF
'
' if argument hasn't been stacked, stack it.
'
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
						IF (argNum < total_args) THEN
							Push ($$eax, $$XLONG)
							stack = $$TRUE
							new_data = 0
							nn = 0
						ELSE
							new_data = $$eax
						END IF
					END IF
					DEC oos
				END IF
				farg[args].token = new_data
				farg[args].varType = from_type
				farg[args].argType = to_type
				farg[args].stack = stack
				farg[args].byRef = qref
				farg[args].kind = kind
			END IF
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
			END IF
			IF (argNum < total_args) THEN
				Push (nn, from_type)
				stack = $$TRUE
				new_data = 0
				nn = 0
			END IF
			DEC toes
			a0 = 0 : a0_type = 0
			a1 = 0 : a1_type = 0
			farg[args].token = nn										' 0 means "pushed"
			farg[args].varType = from_type
			farg[args].argType = to_type
			farg[args].byRef = $$FALSE
			farg[args].stack = stack
			farg[args].kind = $$KIND_VARIABLES
		END IF
		IF XERROR THEN EXIT FUNCTION
'
'	 if arg had a "@" BYREF prefix, note this in arg_type$
'
		IF qref THEN ref_flags = ref_flags OR 0x40 OR stringLit		' by reference
		parArg[argNum] = parArg[argNum] OR (ref_flags << 24)
'
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
'
'
' *************************************
' *****  FUNCTION ARGS PROCESSED  *****
' *************************************
'
PastArgs:
	IF (args < total_args) THEN GOTO eeeTooFewArgs
	IF (args > total_args) THEN
		IF etc THEN total_args = args ELSE GOTO eeeTooManyArgs
	END IF
'
' *******************************************************
' *****  Push arguments onto stack in reverse order *****
' *******************************************************
'
	FOR arg = args-1 TO 0 STEP -1
		farg = farg[arg]
		PushFuncArg (@farg)
		IF XERROR THEN EXIT FUNCTION
		SELECT CASE farg.argType
			CASE $$GIANT, $$DOUBLE		: argOffset = argOffset + 8
			CASE ELSE									: argOffset = argOffset + 4
		END SELECT
	NEXT arg
'
' ***************************
' *****  FUNCTION CALL  *****
' ***************************
'
call_func:
	SELECT CASE fkind
		CASE $$KIND_FUNCTIONS
					funcScope = funcScope[func_num]
					SELECT CASE funcScope
						CASE $$FUNC_EXTERNAL
									funcLabel$ = funcLabel$[func_num]
									IF XERROR THEN EXIT FUNCTION
						CASE $$FUNC_INTERNAL, $$FUNC_DECLARE
									funcLabel$ = "func" + HEX$(func_num)
					END SELECT
					IF rctoken THEN
						Move ($$R12, $$XLONG, rctoken, $$XLONG)
						a1_type = 0
					END IF
					Code ($$call, $$rel, 0, 0, 0, 0, funcLabel$, @"### 774")
		CASE $$KIND_VARIABLES, $$KIND_ARRAYS
					IFZ toes THEN PRINT "eeefuncaddr002": GOTO eeeCompiler
					Pop ($$eax, $$XLONG)
					a0 = 0: a0_type = 0
					DEC toes
					Code ($$call, $$reg, $$eax, 0, 0, $$XLONG, "", @"### 775")
		CASE ELSE
					GOTO eeeCompiler
	END SELECT
'
	IF (callKind != $$CFUNC) THEN
		IF fixArgs THEN
			Code ($$sub, $$regimm, $$esp, argSize, 0, $$XLONG, "", @"### 776")
		END IF
	END IF
'
call_retval:
	INC toes
	a0 = toes
	a0_type = func_type
	GOSUB DoShuffle
'
functions_end:
	new_data	= 0
	new_type	= func_type
	infunc		= old_infunc
	IF fixArgs THEN callKind = $$CFUNC
	IF etc THEN argSize = argOffset
	IFZ noArgs THEN
		SELECT CASE callKind
			CASE $$XFUNC
			CASE $$SFUNC: PRINT "$$SFUNC.d" : GOTO eeeCompiler
			CASE $$CFUNC:	Code ($$add, $$regimm, $$esp, argSize, 0, $$XLONG, "", @"### 777")
		END SELECT
	END IF
	IF (fkind != $$KIND_FUNCTIONS) THEN EmitLabel (@fzip$)
	IF (func_type = $$STRING) THEN INC oos: oos[oos] = 's'
	IF func_type THEN
		IF (func_type < $$SLONG) THEN PRINT "expresso61": GOTO eeeCompiler
	END IF
	GOTO express_op
'
' pass strings by value:  clone, pass clone address, deallocate after return
'
SUB PassString
	IF (nn != $$RA0) THEN Move ($$RA0, $$XLONG, nn, $$XLONG)
	IF qref THEN PRINT "expresso60a": GOTO eeeCompiler
	IF (oos[oos] != 'v') THEN PRINT "expresso60b": GOTO eeeCompiler
	Code ($$call, $$rel, 0, 0, 0, 0, "__clone.a0", @"### 778")
	nn = $$RA0
END SUB
'
'
' Update variables passed by reference
'
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
				END IF
			END IF
		END IF
		k = pkind AND 0x001F
		IF (k != $$KIND_ARRAYS) THEN k = $$KIND_VARIABLES
		SELECT CASE k
			CASE $$KIND_ARRAYS
						offset	= offset + 4
			CASE $$KIND_VARIABLES
						SELECT CASE ptype
							CASE $$GIANT, $$DOUBLE:		offset = offset + 8
							CASE ELSE:								offset = offset + 4
						END SELECT
		END SELECT
	NEXT arg_num
END SUB
'
'
' ******************************************************
' *****  BINARY OPERATOR WHEN WANTING DATA OBJECT  *****
' ******************************************************
'
' Binary ops are errors here...  could it be a unary op?
'
express_binary_op:
	SELECT CASE token
		CASE T_ADD:      token = T_PLUS
		CASE T_SUBTRACT: token = T_MINUS
		CASE T_ANDBIT:   token = T_ADDR_OP:    GOTO express_addr_op
		CASE T_ANDL:     token = T_HANDLE_OP:  GOTO express_addr_op
		CASE ELSE:       GOTO eeeSyntax
	END SELECT
	GOTO express_unary_op
'
'
' *****  LEFT PARENTHESES WHEN WANTING DATA ITEM  *****
'
express_lparen:
	IF (token <> T_LPAREN) THEN GOTO eeeSyntax
	new_test = old_test: new_op = 0: new_data = 0: new_type = 0: new_prec = 0
	Expresso (@new_test, @new_op, @new_prec, @new_data, @new_type)
	IF XERROR THEN EXIT FUNCTION
	IF (new_op <> T_RPAREN) THEN GOTO eeeSyntax
	new_op   = 0
	new_prec = 0
	GOTO express_op
'
'
' *****  RIGHT PARENTHESES  *****  Error or null expression... ()
'
express_rparen:
	IF got_expression THEN GOTO eeeSyntax
	old_test = 0
	old_op   = token
	old_data = 0
	RETURN
'
'
' *****  ADDRESS OPERATORS  *****  &, &&
'
express_addr_op:
	SELECT CASE  token
		CASE T_ADDR_OP		: addr_op		= $$TRUE
												handle_op	= $$FALSE
		CASE T_HANDLE_OP	: addr_op		= $$FALSE
												handle_op	= $$TRUE
		CASE ELSE					: PRINT "expresso61a": GOTO eeeCompiler
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
					END IF
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
'
'		subComposite == a composite expression including sub-element references
'   varComposite == a composite variable/array without sub-element references
'		Source:  			GETADDR valid for subComposites
'						 			GETHANDLE valid for pointer sub-elements in subComposites
'					( tested in Composite() )
'
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
				Code ($$lea, $$regro, dreg, sreg, theOffset, $$XLONG, "", @"### 779")
			ELSE
				IF theOffset THEN
					dreg = sreg
					Code ($$lea, $$regro, dreg, sreg, theOffset, $$XLONG, "", @"### 780")
				END IF
			END IF
			new_op = 0
			new_prec = 0
			new_data = 0
			new_type = $$XLONG
			GOTO express_op
		END IF
	END IF
'
	n$		= tab_sym$[nn]
	m$		= m_addr$[nn]
	rn		= r_addr[nn]
	mReg	= m_reg[nn]
	mAddr	= m_addr[nn]
'
	IF (kind = $$KIND_ARRAYS) THEN GOTO addr_others
'
	IF (stringAddr AND addr_op) THEN
		aop486	= $$ld
	ELSE
		aop486	= $$lea
	END IF
'
	IF mReg THEN
		mode = $$regro
	ELSE
		IF constantAddr THEN
			mode = $$regimm
		ELSE
			mode = $$regabs
		END IF
	END IF
'
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
	Code (aop486, mode, arc, mReg, mAddr, $$XLONG, @m$ , @"### 781")
	new_op = 0
	new_prec = 0
	new_data = 0
	new_type = $$XLONG
	GOTO express_op
'
' address of objects other than variables
'
addr_others:
	DEC tokenPtr
	new_op = token
	new_prec = new_op{$$PREC}
	new_data = 0
	new_type = 0
	test = 0
	Expresso (@test, @new_op, @new_prec, @new_data, @new_type)
	GOTO exo
'
'
' *****  TERMINATORS  *****
'
express_term:
	IF got_expression THEN GOTO eeeSyntax
	old_test = 0
	old_op   = token
	old_prec = 0
	old_data = new_data
	old_type = new_type
	RETURN
'
'
' ****************************
' *****  SUB InitArrays  *****
' ****************************
'
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
'
	DIM opKind [31]
	opKind [ $$KIND_SYMBOLS				] = GOADDRESS (express_op_component)
	opKind [ $$KIND_ARRAY_SYMBOLS	] = GOADDRESS (express_op_component)
	opKind [ $$KIND_LPARENS				] = GOADDRESS (express_op_lparen)
	opKind [ $$KIND_COMMENTS			] = GOADDRESS (express_op_rem)
	opKind [ $$KIND_TERMINATORS		] = GOADDRESS (express_ops)
	opKind [ $$KIND_BINARY_OPS		] = GOADDRESS (express_ops)
	opKind [ $$KIND_SEPARATORS		] = GOADDRESS (express_ops)
	opKind [ $$KIND_STARTS				] = GOADDRESS (express_ops)
'
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
'
	DIM intrinToken [255]
	intrinToken [ T_ABS				AND 0x00FF ] = GOADDRESS (i_abs)
	intrinToken [ T_ASC				AND 0x00FF ] = GOADDRESS (i_asc)
	intrinToken [ T_BIN_D			AND 0x00FF ] = GOADDRESS (i_bin_d)
	intrinToken [ T_BINB_D		AND 0x00FF ] = GOADDRESS (i_binb_d)
	intrinToken [ T_BITFIELD	AND 0x00FF ] = GOADDRESS (i_bitfield)
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
'
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
'
' ********************
' *****  ERRORS  *****
' ********************
'
eeeBitSpec:
	XERROR = ERROR_BITSPEC
	EXIT FUNCTION
'
eeeByRef:
	XERROR = ERROR_BYREF
	EXIT FUNCTION
'
eeeByVal:
	XERROR = ERROR_BYVAL
	EXIT FUNCTION
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION
'
eeeKindMismatch:
	XERROR = ERROR_KIND_MISMATCH
	EXIT FUNCTION
'
eeeLiteral:
	XERROR = ERROR_LITERAL
	EXIT FUNCTION
'
eeeNeedExcessComma:
	XERROR = ERROR_NEED_EXCESS_COMMA
	EXIT FUNCTION
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeRegAddr:
	XERROR = ERROR_REGADDR
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
'
eeeTooFewArgs:
	XERROR = ERROR_TOO_FEW_ARGS
	EXIT FUNCTION
'
eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
'
eeeUndeclared:
	XERROR = ERROR_UNDECLARED
	EXIT FUNCTION
'
eeeUndefined:
	XERROR = ERROR_UNDEFINED
	EXIT FUNCTION
'
eeeUnimplemented:
	XERROR = ERROR_UNIMPLEMENTED
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  FloatLoad ()  #####
' ##########################
'
FUNCTION  FloatLoad (dreg, stoken, stype)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	tab_sym[],  m_reg[],  m_addr[],  m_addr$[],  labelNumber
'
	IF (stype < $$SLONG) THEN stype = $$SLONG
	SELECT CASE stype
		CASE $$SLONG	: op = $$fild
		CASE $$ULONG	: op = $$fild
		CASE $$XLONG	: op = $$fild
		CASE $$GIANT	: op = $$fild
		CASE $$SINGLE	: op = $$fld
		CASE $$DOUBLE	: op = $$fld
		CASE ELSE			: PRINT "FloatLoad1": EXIT FUNCTION
	END SELECT
'
	ss			= stoken{$$NUMBER}
	stoken	= tab_sym[ss]
	mReg		= m_reg[ss]
	mAddr		= m_addr[ss]
	kind		= stoken{$$KIND}
	SELECT CASE kind
		CASE $$KIND_LITERALS,  $$KIND_CONSTANTS,  $$KIND_SYSCONS
					SELECT CASE stype
						CASE $$SINGLE:	LoadLitnum ($$RA0, $$SINGLE, stoken, stype)
						CASE ELSE:			LoadLitnum ($$RA0, $$DOUBLE, stoken, stype)
					END SELECT
		CASE $$KIND_VARIABLES
					IF (stype != $$ULONG) THEN
						IF mReg THEN
							Code (op, $$ro, 0, mReg, mAddr, stype, "", @"### 782a")
						ELSE
							Code (op, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"### 782b")
						END IF
					ELSE
'
' xxxxxxxxxx  :  error - gets negative result for large ULONG values (treats as an SLONG)
'
						INC labelNumber: d1$ = "%" + HEX$(labelNumber, 4)
						IF mReg THEN
							Code ($$push, $$imm, 0, 0, 0, $$XLONG, "", @"### 782c")
							Code ($$push, $$ro, 0, mReg, mAddr, stype, "", @"### 782d")
							Code ($$cmp, $$r0imm, 0, $$esp, 0, $$XLONG, "", @"### 782e")
							Code ($$jle, $$rel, 0, 0, 0, 0, @d1$, @"### 782f")
							Code ($$mov, $$roimm, -1, $$esp, 4, $$XLONG, "", @"### 782g")
							EmitLabel (@d1$)
							Code (op, $$r0, 0, $$esp, 0, $$GIANT, "", @"### 782h")
'							Code (op, $$ro, 0, mReg, mAddr, stype, "", @"### 782i")
						ELSE
							Code ($$push, $$imm, 0, 0, 0, $$XLONG, "", @"### 782j")
							Code ($$push, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"### 782k")
							Code ($$cmp, $$r0imm, 0, $$esp, 0, $$XLONG, "", @"### 782l")
							Code ($$jle, $$rel, 0, 0, 0, 0, @d1$, @"### 782m")
							Code ($$mov, $$roimm, -1, $$esp, 4, $$XLONG, "", @"### 782n")
							EmitLabel (@d1$)
							Code (op, $$r0, 0, $$esp, 0, $$GIANT, "", @"### 782o")
'							Code (op, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"### 782p")
						END IF
					END IF
	END SELECT
END FUNCTION
'
'
' ###########################
' #####  FloatStore ()  #####
' ###########################
'
FUNCTION  FloatStore (sreg, stoken, stype)
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER
'
	SELECT CASE stype
		CASE $$SLONG:		op = $$fistp
		CASE $$ULONG:		op = $$fistp
		CASE $$XLONG:		op = $$fistp
		CASE $$GIANT:		op = $$fistp
		CASE $$SINGLE:	op = $$fstp
		CASE $$DOUBLE:	op = $$fstp
		CASE ELSE:			PRINT "FloatStore1": GOTO eeeCompiler
	END SELECT
'
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
		' can't be the case, because the eax can't be used in 'register/offset'
		' addressing mode.
		' Note 2: Often eax will be saved/restored while it's value is not
		' needed. Unfortunately I (EP) don't (yet) know a way to find out when
		' it's save and when it's not save to destroy the contents of eax.
		Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", @"### i645a1")
		' Allocate a 64 bit value on the stack.
		Code ($$sub, $$regimm, $$esp, 8, 0, $$XLONG, "", @"### i645a1")
		' Store the float value into this 64 bit value
		Code ($$fistp, $$r0, 0, $$esp, 0, $$GIANT, "", @"### i645a2")
		' Load the low 32 bits of this 64 bit value into eax
		Code ($$ld, $$regr0, $$eax, $$esp, 0, $$ULONG, "", @"### i645a3")
		' Store eax at the destination
		IF mReg THEN
			Code ($$st, $$roreg, $$eax, mReg, mAddr, stype, "", @"### i645a4")
		ELSE
			Code ($$st, $$absreg, $$eax, 0, mAddr, stype, m_addr$[ss], @"### i645a5")
		END IF
		' Free the 64 bit temporary.
		Code ($$add, $$regimm, $$esp, 8, 0, $$XLONG, "", @"### i645a7")
		' Restore $eax
		Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, "", @"### i645a1")
	ELSE
		IF mReg THEN
			Code (op, $$ro, 0, mReg, mAddr, stype, "", @"### 784")
		ELSE
			Code (op, $$abs, 0, 0, mAddr, stype, m_addr$[ss], @"### 785")
		END IF
	END IF
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #################################
' #####  FunctionCallPrep ()  #####
' #################################
'
FUNCTION  FunctionCallPrep ()
'
' not needed for i486
'
END FUNCTION
'
'
' #################################
' #####  FunctionCallPost ()  #####
' #################################
'
FUNCTION  FunctionCallPost ()
'
' not needed for i486
'
END FUNCTION
'
'
' #######################
' #####  GetArg ()  #####
' #######################
'
FUNCTION  GetArg (a_reg, a_type, source)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	a0,  a0_type,  a1,  a1_type
'
	IF (source = $$RA0) THEN a0 = 0: a0_type = 0
	IF (source = $$RA1) THEN a1 = 0: a1_type = 0
'
' *****  POTENTIAL PROBLEM with a.reg = 0 or source = 0  ???
'
	IF (a_reg <= $$R9) THEN
		IF (source < $$IMM16) THEN GOTO sreg_to_areg ELSE GOTO smem_to_areg
	ELSE
		IF (source < $$IMM16) THEN GOTO sreg_to_amem ELSE GOTO smem_to_amem
	END IF
	PRINT "ggg1": GOTO eeeCompiler
'
sreg_to_areg:
	Move (a_reg, a_type, source, a_type)
	RETURN (0)
'
smem_to_areg:
	Move (a_reg, a_type, source, a_type)
	RETURN (0)
'
sreg_to_amem:
	IF (a_reg < $$R9) THEN
		a_mem = (a_reg + 2) * 4
	ELSE
		a_mem	= (a_reg - 2) * 4
	END IF
	a_mem$	= ",r31," + HEXX$(a_mem, 4)
	s_reg		= source
	EmitNull ("# GetArg() : who knows?")
	RETURN
'
smem_to_amem:
	IF (a_reg < $$R9) THEN
		a_mem = (a_reg + 2) * 4
	ELSE
		a_mem	= (a_reg - 2) * 4
	END IF
	a_mem$ = ",r31," + HEXX$(a_mem, 4)
	Move ($$esi, a_type, source, a_type)
	EmitNull ("# GetArg() : who knows?")
	RETURN
'
eeeCompiler:
	XERROR =  ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #####################################
' #####  GetExternalAddresses ()  #####  linux ELF version
' #####################################
'
FUNCTION  GetExternalAddresses ()
	SHARED	ERROR_COMPILER
	SHARED	labaddr[]
	Elf32_Ehdr  elf
	Elf32_Shdr  sec,  sec[]
	Elf32_Phdr	pro,  pro[]
	Elf32_Sym  sym,  sym[]
'
' argc = -1 makes sure original arguments are returned,
' not those from any XstSetCommandLineArguments() calls.
'
	argc = -1
	XstGetCommandLineArguments (@argc, @argv$[])
'
	labels = $$FALSE
	##ERROR = $$FALSE
	ifile$ = TRIM$(argv$[0])										' 1st command line arg is name
	IF (argc > 1) THEN
		FOR ii = 1 TO argc
			IF (argv$[ii] = "-labels") THEN labels = ii : EXIT FOR
		NEXT ii
	END IF
'
	IFZ ifile$ THEN
		##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureInvalidData)
		RETURN ($$FALSE)
	END IF
'
' find the path to the executable
'
	file$ = ifile$
	left$ = LEFT$ (file$, 2)
	IF file$ THEN
		IF (file${0} == '.') THEN
			IF (file${1} == '/') THEN
				XstGetCurrentDirectory (@dir$)
				IF (RIGHT$(dir$,1) != "/") THEN dir$ = dir$ + "/"
				file$ = dir$ + MID$ (file$, 3)											' ./xb becomes /usr/xb/xb
			END IF
		END IF
	END IF
	XstGetExecutionPathArray (@path$[])								' returns all directories in $PATH
	XstFindFile (@file$, @path$[], @ifile$, @attr)		' returns full path to ifile$
	XstLoadString (@ifile$, @text$)										' load the executable
'
'	PRINT "<"; file$; "> <"; ifile$; ">"
'
	##ERROR = $$FALSE
	ifile = OPEN (ifile$, $$RD)												' open xb
	IF (ifile <= 0) THEN															' bad file number
		##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
		PRINT ifile$; " not found"
		RETURN ($$FALSE)
	END IF
'
	ilen = LOF (ifile)
	IF (ilen < 65536) THEN
		CLOSE (ifile)
		##ERROR = (($$ErrorObjectFile << 8) OR $$ErrorNatureNonexistent)
		PRINT ifile$; " too small to be PDE : "; ilen
		RETURN ($$FALSE)
	END IF
'
' read in ELF header
'
	READ [ifile], elf														' ELF header
'
'	PRINT
'	PRINT "#####  ELF HEADER  #####"
'	PRINT
'	PRINT " elf.e_ident[]    =      ";
'
'	FOR i = 0 TO 15
'		PRINT "  "; HEX$(elf.e_ident[i],2);
'	NEXT i
'
	nonelf = $$FALSE
	SELECT CASE TRUE
		CASE (elf.e_ident[0] != 0x7F)		: nonelf = $$TRUE
		CASE (elf.e_ident[1] != 'E')		: nonelf = $$TRUE
		CASE (elf.e_ident[2] != 'L')		: nonelf = $$TRUE
		CASE (elf.e_ident[3] != 'F')		: nonelf = $$TRUE
	END SELECT
'
	IF nonelf THEN PRINT "not an ELF file, can't get external symbols"
'
' print ELF header
'
'	PRINT
'	PRINT "  elf.e_type       =     "; HEX$(elf.e_type,4);      "  object file type"
'	PRINT "  elf.e_machine    =     "; HEX$(elf.e_machine,4);   "  machine aka CPU"
'	PRINT "  elf.e_version    = "; HEX$(elf.e_version,8);       "  object file version"
'	PRINT "  elf.e_entry      = "; HEX$(elf.e_entry,8);         "  entry address"
'	PRINT "  elf.e_phoff      = "; HEX$(elf.e_phoff,8);         "  program header table file offset"
'	PRINT "  elf.e_shoff      = "; HEX$(elf.e_shoff,8);         "  section header table file offset"
'	PRINT "  elf.e_flags      = "; HEX$(elf.e_flags,8);         "  processor specific flags"
'	PRINT "  elf.e_ehsize     =     "; HEX$(elf.e_ehsize,4);    "  this elf header size"
'	PRINT "  elf.e_phentsize  =     "; HEX$(elf.e_phentsize,4); "  size of each program header"
'	PRINT "  elf.e_phnum      =     "; HEX$(elf.e_phnum,4);     "  number of program headers"
'	PRINT "  elf.e_shentsize  =     "; HEX$(elf.e_shentsize,4); "  size of each section header"
'	PRINT "  elf.e_shnum      =     "; HEX$(elf.e_shnum,4);     "  number of section headers"
'	PRINT "  elf.e_shstrndx   =     "; HEX$(elf.e_shstrndx,4);  "  section name string table - element in section header array"
'
'
' collect program headers
'
'	PRINT
'	PRINT
'	PRINT "#####  PROGRAM HEADERS  #####"
'	PRINT
'
	IF elf.e_phnum THEN													' if there are program headers
		DIM pro[elf.e_phnum-1]										' make an array to hold them
		FOR i = 0 TO elf.e_phnum - 1							' for all program headers
			READ [ifile], pro												' read program header
			pro[i] = pro														' save in array
'			PRINT "  pro.p_type       = "; HEX$(pro.p_type,8);          "  program segment type"
'			PRINT "  pro.p_offset     = "; HEX$(pro.p_offset,8);        "  file offset of 1st byte of segment"
'			PRINT "  pro.p_vaddr      = "; HEX$(pro.p_vaddr,8);         "  virtual address of 1st bype of segment"
'			PRINT "  pro.p_paddr      = "; HEX$(pro.p_paddr,8);         "  physical address of 1st byte of segment"
'			PRINT "  pro.p_filesz     = "; HEX$(pro.p_filesz,8);        "  size of file image of this segment"
'			PRINT "  pro.p_memsz      = "; HEX$(pro.p_memsz,8);         "  size of memory image of this segment"
'			PRINT "  pro.p_flags      = "; HEX$(pro.p_flags,8);         "  segment specific flags"
'			PRINT "  pro.p_align      = "; HEX$(pro.p_align,8);         "  segment alignment"
'			PRINT
		NEXT i																		' next header
	END IF
'
'
' move file pointer to section headers
'
	SEEK (ifile, elf.e_shoff)
'
'
' collect section headers
'
'	PRINT
'	PRINT "#####  SECTION HEADERS  #####"
'	PRINT
'
	IF elf.e_shnum THEN													' if there are section headers
		DIM sec[elf.e_shnum-1]										' make an array to hold them
		FOR i = 0 TO elf.e_shnum - 1							' for all section headers
			READ [ifile], sec												' read section header
			sec[i] = sec														' save in array
		NEXT i
'
		shstrndx = elf.e_shstrndx
		strsec = sec[shstrndx].sh_offset
'
'		PRINT HEX$(shstrndx,8); " = section header # that refers to section name string table"
'		PRINT HEX$(strsec,8); " = offset to beginning of section name string table"
'		PRINT
'
		FOR i = 0 TO elf.e_shnum - 1							' for all section headers
			sec = sec[i]
			stroff = strsec + sec.sh_name
			IF (sec.sh_type = 2) THEN
				symndx = i
				symoff = sec.sh_offset
				symafter = symoff + sec.sh_size
				symcount = sec.sh_size \ sec.sh_entsize
				symstroff =  sec[sec.sh_link].sh_offset
			END IF
'			PRINT " "; LJUST$(CSTRING$(&text$ + stroff),20); "SECTION HEADER # "; HEX$(i,8);; i
'			PRINT "  sec.sh_name      = "; HEX$(sec.sh_name,8);         "  section name index into section header string table section"
'			PRINT "  sec.sh_type      = "; HEX$(sec.sh_type,8);         "  section type"
'			PRINT "  sec.sh_flags     = "; HEX$(sec.sh_flags,8);        "  miscellaneous flags"
'			PRINT "  sec.sh_addr      = "; HEX$(sec.sh_addr,8);         "  address of section in memory image of process"
'			PRINT "  sec.sh_offset    = "; HEX$(sec.sh_offset,8);       "  file offset of 1st byte of this section"
'			PRINT "  sec.sh_size      = "; HEX$(sec.sh_size,8);         "  size of this section"
'			PRINT "  sec.sh_link      = "; HEX$(sec.sh_link,8);         "  section header table index link"
'			PRINT "  sec.sh_info      = "; HEX$(sec.sh_info,8);         "  extra information - section type specific"
'			PRINT "  sec.sh_addralign = "; HEX$(sec.sh_addralign,8);    "  section address alignment requirements"
'			PRINT "  sec.sh_entsize   = "; HEX$(sec.sh_entsize,8);      "  size of each entry in section for sections with fixed size entries"
'			PRINT
		NEXT i
	END IF
'
' symndx is the entry in sec[] of the symbol table header
' symoff is the file offset of the symbol table headers
' symstroff is the file offset of the symbol table strings
'
'	PRINT HEX$(symndx,8)
'	PRINT HEX$(symoff,8)
'	PRINT HEX$(symafter,8)
'	PRINT HEX$(symcount,8)
'	PRINT HEX$(symstroff,8)
'
'
'	PRINT "#####  TEST dlopen() and dlclose()   #####"
'
'	handle = dlopen (0, 0)
'	PRINT "#####  handle = "; HEX$(handle,8); "  0,0"
'	IFZ handle THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'
'	addr = dlsym (handle, &"Xst_0")
'	PRINT "#####    addr = "; HEX$(addr,8); "  Xst_0"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"XstSleep_4")
'	PRINT "#####    addr = "; HEX$(addr,8); "  XstSleep_4"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"Xgr_0")
'	PRINT "#####    addr = "; HEX$(addr,8); "  Xgr_0"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"XgrSendMessage_32")
'	PRINT "#####    addr = "; HEX$(addr,8); "  XgrSendMessage_32"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"XuiSendMessage_32")
'	PRINT "#####    addr = "; HEX$(addr,8); "  XuiSendMessage_32"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"dlopen")
'	PRINT "#####    addr = "; HEX$(addr,8); "  dlopen"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"dlclose")
'	PRINT "#####    addr = "; HEX$(addr,8); "  dlclose"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"open")
'	PRINT "#####    addr = "; HEX$(addr,8); "  open"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"write")
'	PRINT "#####    addr = "; HEX$(addr,8); "  write"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"lseek")
'	PRINT "#####    addr = "; HEX$(addr,8); "  lseek"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"rmdir")
'	PRINT "#####    addr = "; HEX$(addr,8); "  rmdir"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"_xstat")
'	PRINT "#####    addr = "; HEX$(addr,8); "  _xstat"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"XxxMain")
'	PRINT "#####    addr = "; HEX$(addr,8); "  XxxMain"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"XxxG_0")
'	PRINT "#####    addr = "; HEX$(addr,8); "  XxxG_0"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"main")
'	PRINT "#####    addr = "; HEX$(addr,8); "  main"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"WinMain")
'	PRINT "#####    addr = "; HEX$(addr,8); "  WinMain"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'	addr = dlsym (handle, &"WinMain_16")
'	PRINT "#####    addr = "; HEX$(addr,8); "  WinMain_16"
'	IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'
' can't close the handle that belongs to the executable
'
'		error = dlclose (handle)
'		PRINT "#####   error = "; HEX$(error,8)
'		IF error THEN error = dlerror () : PRINT "#####   error = "; CSTRING$(error)
'
'
' *****  Update compiler symbol table from ELF symbol table data  *****
'
'	PRINT
'	PRINT "#####  SYMBOL TABLE  #####"
'	PRINT
'
	IF symndx THEN
		SEEK (ifile, symoff)
		DIM sym[symcount-1]
		FOR i = 0 TO symcount-1
			READ [ifile], sym
			sym[i] = sym
			IFZ sym.st_name THEN DO NEXT										' no symbols string
			IFZ (sym.st_info AND 0x0030) THEN DO NEXT				' skip local symbols
			addr = &text$ + symstroff + sym.st_name
			symbol$ = CSTRING$(addr)
			IF (symbol$ = "__StartApplication") THEN DO NEXT
'
' see if dlopen(), dlsym() give same address
'
'			addr = dlsym (handle, &symbol$)
'			PRINT "#####    addr = "; HEX$(addr,8); "  "; symbol$
'			IFZ addr THEN error = dlerror () : PRINT "#####  error = "; CSTRING$(error)
'
' strip invalid trash-suffix put there by ??????????
'
			atat = INSTR (symbol$, "@@")
			IF atat THEN symbol$ = LEFT$ (symbol$, atat-1)
'
' add symbol$ in label symbol table
'
			token = AddLabel (symbol$, $$T_LABELS, $$XADD)
			labaddr[token{$$NUMBER}] = sym.st_value
			IF labels THEN PRINT HEX$(token, 8), HEX$(sym.st_value, 8), symbol$
'			PRINT "#####    addr = "; HEX$(addr,8);; HEX$(sym.st_value,8);; HEX$(token,8);; symbol$
'
'			length = LEN(symbol$)
'			IF (length < 26) THEN pad$ = SPACE$(26-length) ELSE pad$ = ""
'			PRINT " \""; symbol$; "\"  "; pad$; HEX$(i,8);; i
'			PRINT "  sym.st_name      = "; HEX$(sym.st_name,8);          "  index into symbol string table"
'			PRINT "  sym.st_value     = "; HEX$(sym.st_value,8);         "  value of symbol - value, address, etc"
'			PRINT "  sym.st_size      = "; HEX$(sym.st_size,8);          "  size of object referred to by symbol"
'			PRINT "  sym.st_info      = "; HEX$(sym.st_info,8);          "  symbol type and binding information"
'			PRINT "  sym.st_other     = "; HEX$(sym.st_other,8);         "  reserved"
'			PRINT "  sym.st_shndx     = "; HEX$(sym.st_shndx,8);         "  associated section header table index"
'			PRINT
		NEXT i
	END IF
'
	text$ = ""
	CLOSE (ifile)
	RETURN (token{$$NUMBER}+1)
END FUNCTION
'
'
' ################################
' #####  GetFuncaddrInfo ()  #####
' ################################
'
' SYNTAX:		FUNCADDR [xFUNCTION] [typename] funcaddrVariableOrArray ( [args] )
'
' enter:		token				= [typename] or funcaddrVariableOrArray token
' return:		returnVal		= terminating token
'						token				= funcaddrVariableOrArray token
'						eleElements	= # of elements in funcaddrArray[upperBound]
'													0 if funcaddrVariable or funcaddrArray[]
'						arg[]:				arg[0] = return kind, type, # args
'													arg[n] = argument kind and type
'						dataPtr			= tokenPtr at funcaddrVariable or funcaddrArray
'
FUNCTION  GetFuncaddrInfo (token, eleElements, arg[], dataPtr)
	SHARED	inTYPE,  tokenPtr,  tabArg[],  r_addr$[],  tab_sym$[]
	SHARED	T_ANY,  T_COMMA,  T_LBRAK,  T_RBRAK,  T_LPAREN,  T_RPAREN
	SHARED  T_FUNCTION,  T_CFUNCTION,  T_SFUNCTION
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_COMPONENT
	SHARED	ERROR_DUP_DECLARATION,  ERROR_KIND_MISMATCH
	SHARED	ERROR_OVERFLOW,  ERROR_SYNTAX,  ERROR_TOO_MANY_ARGS
'
	DIM arg[19]
	argNumber		= 0
	eleElements	= 0
'
' the following supports the second token in "FUNCADDR [xFUNCTION] DOUBLE cos (DOUBLE)"
'
	SELECT CASE token
		CASE T_FUNCTION		: callKind = $$XFUNC
		CASE T_CFUNCTION	: callKind = $$CFUNC
		CASE T_SFUNCTION	: callKind = $$CFUNC
	END SELECT
	IF callKind THEN token = NextToken ()				' remove xFUNCTION token
'
	rtype				= TypenameToken (@token)
	IFZ rtype THEN rtype = $$XLONG
	arg[0]			= $$T_VARIABLES OR rtype OR (callKind << 29)
	kind				= token {$$KIND}
	dataPtr			= tokenPtr
	check				= NextToken ()
'
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
						END IF
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
	END IF
'
	DO
		check = NextToken ()
		IF (check = T_RPAREN) THEN EXIT DO
		argType		= TypenameToken (@check)
		IFZ argType THEN
			IF (check != T_ANY) THEN GOTO eeeSyntax
			check = NextToken ()
			argType	= $$ANY
		END IF
'		PRINT "GetFuncaddrInfo(): argType = "; argType
		IF (check = T_LBRAK) THEN
			check		= NextToken ()
			IF (check != T_RBRAK) THEN GOTO eeeSyntax
			check		= NextToken ()
			arg			= $$T_ARRAYS + argType
		ELSE
			arg			= $$T_VARIABLES + argType
		END IF
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
'
'
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeComponent:
	XERROR = ERROR_COMPONENT
	EXIT FUNCTION
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeDupDeclaration:
	XERROR = ERROR_DUP_DECLARATION
	EXIT FUNCTION
'
eeeKindMismatch:
	XERROR = ERROR_KIND_MISMATCH
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
'
eeeTooManyArgs:
	XERROR = ERROR_TOO_MANY_ARGS
	EXIT FUNCTION
END FUNCTION
'
'
' ########################
' #####  GetSubPath  #####
' ########################
'
FUNCTION  GetSubPath (sub$, file$, path$[])
'
	n$ = ""
	dir$ = ""
	IF file$ THEN n$ = $$PathSlash$ + file$
	IF sub$ THEN dir$ = $$PathSlash$ + sub$
'
	SELECT CASE sub$
		CASE "app"	: GOSUB App
		CASE "bak"	: GOSUB Normal
		CASE "bin"	: GOSUB Normal
		CASE "doc"	: GOSUB Normal
		CASE "hlp"
			DIM path$[0]
			path$[ 0] = ##XBDir$ + "/help"								' "/usr/xb/help"
		CASE "lib"	: GOSUB Normal
		CASE "run"	: GOSUB Normal
		CASE "win"	: GOSUB Normal
		CASE "xxx"
			DIM path$[0]
			path$[ 0] = ##XBDir$ + "/templates"						' "/usr/xb/templates"
		CASE ELSE		: GOSUB Normal
	END SELECT
	RETURN
'
' *****  App  *****
'
SUB App
	DIM path$[19]
	path$[ 0] = "."																' "."
	path$[ 1] = "./xb"														' "./xb"
	path$[ 2] = "./xb" + n$												' "./xb/n"
	path$[ 3] = "./xb" + dir$											' "./xb/app"
	path$[ 4] = "./xb" + dir$ + n$								' "./xb/app/n"
	path$[ 5] = "$(HOME)"													' "/u/user"
	path$[ 6] = "$(HOME)" + "/xb"									' "/u/user/xb"
	path$[ 7] = "$(HOME)" + "/xb" + n$						' "/u/user/xb/n"
	path$[ 8] = "$(HOME)" + "/xb" + dir$					' "/u/user/xb/app"
	path$[ 9] = "$(HOME)" + "/xb" + dir$ + n$			' "/u/user/xb/app/n"
	path$[10] = "/usr"														' "/usr/"
	path$[11] = "/usr/xb"													' "/usr/xb"
	path$[12] = "/usr/xb" + n$										' "/usr/xb/n"
	path$[13] = "/usr/xb" + dir$									' "/usr/xb/app"
	path$[14] = "/usr/xb" + dir$ + n$							' "/usr/xb/app/n"
	path$[15] = "/xb"															' "/xb"
	path$[16] = "/xb" + n$												' "/xb/n"
	path$[17] = "/xb" + dir$											' "/xb/app"
	path$[18] = "/xb" + dir$ + n$									' "/xb/app/n"
	path$[19] = ""																' current directory
END SUB
'
' *****  Normal  *****
'
SUB Normal
	DIM path$[7]
	path$[ 0] = "."																' "."
	path$[ 1] = "." + dir$												' "./xxx"
	path$[ 2] = "./xb" + dir$											' "./xb/xxx"
	path$[ 3] = "$(HOME)" + dir$									' "/u/user/xxx"
	path$[ 4] = "$(HOME)" + "/xb" + dir$					' "/u/user/xb/xxx"
	path$[ 5] = "/usr/xb" + dir$									' "/usr/xb/xxx"
	path$[ 6] = "/usr" + dir$											' "/usr/xxx"
	path$[ 7] = "/xb" + dir$											' "/xb/xxx"
END SUB
END FUNCTION
'
'
' ###########################
' #####  GetSymbol$ ()  #####
' ###########################
'
FUNCTION  GetSymbol$ (info)
	SHARED  charPtr,  rawLength,  rawline$
	SHARED	T_POUND
	SHARED UBYTE  charsetSymbolInner[]
	SHARED UBYTE  charsetSymbolFirst[]

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
								END IF
		CASE '#':		INC charPtr
								info	= $$SHARED_VARIABLE						' #SharedVariable
								charV = rawline${charPtr}
								IF (charV = '#') THEN
									info	= $$EXTERNAL_VARIABLE				' ##ExternalVariable
									INC charPtr
									charV = rawline${charPtr}
								END IF
								IFZ charsetSymbolInner[charV] THEN
									SELECT CASE info
										CASE $$SHARED_VARIABLE		: info = $$SOLO_POUND : RETURN
										CASE $$EXTERNAL_VARIABLE	: info = $$DUAL_POUND : RETURN
									END SELECT
								END IF
		CASE '.':		INC charPtr
								info	= $$COMPONENT									' .component
								charV = rawline${charPtr}
		CASE ELSE:	info	= $$NORMAL_SYMBOL							' normalSymbol
	END SELECT
'
	DO WHILE (charsetSymbolInner[charV])	' TRUE while A-Z, a-z, 0-9, "_"
		INC charPtr
		charV = rawline${charPtr}
	LOOP
	y$ = MID$ (rawline$, char_start+1, charPtr-char_start)
	RETURN (y$)
END FUNCTION
'
'
' ##################################
' #####  GetTokenOrAddress ()  #####
' ##################################
'
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
'
'
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
'
'
' *****  VARIABLES  *****  SIMPLE-TYPE, COMPOSITE-TYPE
'
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
					END IF
		CASE ELSE
					GOTO eeeCompiler
	END SELECT
	nextToken = NextToken ()
	RETURN ($$TRUE)
'
'
'
' *****  ARRAYS  *****  NULL, SIMPLE-TYPE, COMPOSITE-TYPE
'
arrays:
	t1		= NextToken ()
	t2		= NextToken ()
	IF (t1 != T_LBRAK) THEN GOTO eeeCompiler
	IF (t2 = T_RBRAK) THEN
		style				= $$ARRAY_TOKEN
		nextToken		= NextToken ()
		RETURN ($$TRUE)
	END IF
	tokenPtr = holdPtr
	SELECT CASE TRUE
		CASE (theType < $$SCOMPLEX):	GOTO simpleArrays
		CASE ELSE:										GOTO compositeArrays
	END SELECT
	GOTO eeeCompiler
'
'
' *****  SIMPLE ARRAYS  *****
'
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
	END IF
	length			= typeSize[theType]
	nextToken		= NextToken ()
	base				= Top ()
	RETURN ($$TRUE)
'
'
' *****  COMPOSITE ARRAYS  *****
'
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
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #########################
' #####  GetWords ()  #####
' #########################
'
FUNCTION  GetWords (src, gtype, w3, w2, w1, w0)
	SHARED	r_addr$[],  tab_sym[]
	SHARED	XERROR,  ERROR_OVERFLOW,  ERROR_TYPE_MISMATCH
'
	gg			= src{$$NUMBER}
	gtoken	= tab_sym[gg]
	x$			= r_addr$[gg]
	IFZ x$ THEN w3 = 0: w2 = 0: w1 = 0: w0 = 0: RETURN
	IF (gtype < $$SLONG) THEN gtype = $$SLONG
'
'
' *****  Check for "0x...", "0s...", "0d..." formats  *****
'
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
'	END IF
'
'
' *****  Normal numeric formats  *****
'
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
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ###########################
' #####  InitArrays ()  #####
' ###########################
'
' Dimension all SHARED arrays, clearing the contents to zero.
' Define the contents of "information", "default", "charset" arrays.
'
FUNCTION  InitArrays ()
	STATIC	reEntry
	SHARED	ulabel,  upatch,  typePtr
	SHARED	labelPtr,  tab_sym_ptr,  uFunc,  uType,  xargNum
	SHARED	reg86$[31]
	SHARED	reg86c$[31]
'
' *****  DATA TYPE ARRAYS  *****
'
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
'
' *****  MISCELLANEOUS ARRAYS  *****
'
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
'
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
'
	SHARED assemblerBackslashAsm$[]
	SHARED UBYTE shiftMulti[]
	SHARED UBYTE charsetSymbolFirst[]
	SHARED UBYTE charsetSymbolInner[]
	SHARED UBYTE charsetSymbolFinal[]
	SHARED UBYTE charsetSymbol[]
	SHARED UBYTE charsetPath[]
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
	SHARED UBYTE charsetBackslashByte[]
	SHARED UBYTE charsetBackslashChar[]
	SHARED UBYTE charsetNormalChar[]
	SHARED UBYTE charsetPrintChar[]
	SHARED UBYTE charsetSpaceTab[]
	SHARED UBYTE charsetSuffix[]
'
	SHARED	alphaFirst[]
	SHARED	alphaLast[]
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED	tab_sys$[]
	SHARED	tab_sys[]
	SHARED	minval#[]
	SHARED	maxval#[]
	SHARED	blanks[]
	SHARED	cop[]
'
	SHARED	q_type_long[]
	SHARED	q_type_long_or_addr[]
	SHARED	typeHigher[]
	SHARED SSHORT typeConvert[]
'
' ***************************************************
' *****  SET UP DATA TYPE ARRAYS AND VARIABLES  *****
' ***************************************************
' *****  Variables needed for Data Type Arrays  *****
' ***************************************************
'
	typePtr			= 34			' slot after DCOMPLEX
	uFunc				= 63			' room for 64 functions to start
	uType				= 63			' room for 64 types to start
	upatch			= 8191		' upper bound of patch arrays
	ulabel			= 16383		' upper bound of label arrays
	xargNum			= 0
	labelPtr		= 0
	tab_sym_ptr	= 0
'
	DIM libraryCode$[]		' waste the previous libraries
	DIM libraryName$[]		'
	DIM libraryHandle[]		'
'
	DIM temp%[255, ]
	ATTACH temp%[] TO hash%[0, ]
'
'
' ******************
' *****  hx[]  *****  (For better hash distribution)
' ******************
'
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
'
'
' ***************************
' *****  typeSymbol$[]  *****
' ***************************
'
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
	typeSymbol$[$$SCOMPLEX]	= "SCOMPLEX"
	typeSymbol$[$$DCOMPLEX]	= "DCOMPLEX"
'
'
' ***************************
' *****  typeSuffix$[]  *****
' ***************************
'
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
'
'
' *************************
' *****  typeToken[]  *****
' *************************
'
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
	typeToken[$$SCOMPLEX]		= $$T_TYPES + $$SCOMPLEX
	typeToken[$$DCOMPLEX]		= $$T_TYPES + $$DCOMPLEX
'
'
' *************************
' *****  typeName$[]  *****
' *************************
'
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
	typeName$[$$SCOMPLEX]		= "singleComplex"
	typeName$[$$DCOMPLEX]		= "doubleComplex"
'
'
' **************************************
' *****  typeSize[],  typeSize$[]  *****
' **************************************
'
	FOR i = 0 TO 63
		SELECT CASE i
			CASE $$SBYTE:			typeSize[i] =  1:		typeSize$[i] =  "1"
			CASE $$UBYTE:			typeSize[i] =  1:		typeSize$[i] =  "1"
			CASE $$SSHORT:		typeSize[i] =  2:		typeSize$[i] =  "2"
			CASE $$USHORT:		typeSize[i] =  2:		typeSize$[i] =  "2"
			CASE $$GIANT:			typeSize[i] =  8:		typeSize$[i] =  "8"
			CASE $$DOUBLE:		typeSize[i] =  8:		typeSize$[i] =  "8"
			CASE $$SCOMPLEX:	typeSize[i] =  8:		typeSize$[i] =  "8"
			CASE $$DCOMPLEX:	typeSize[i] = 16:		typeSize$[i] = "16"
			CASE ELSE:				typeSize[i] =  4:		typeSize$[i] =  "4"
		END SELECT
	NEXT
'
'
' ****************************************
' *****  typeAlias[],  typeAlign[]  ******
' ****************************************
'
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
			CASE $$STRING:		typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$SCOMPLEX:	typeAlias[i] = i:		typeAlign[i] = 4
			CASE $$DCOMPLEX:	typeAlias[i] = i:		typeAlign[i] = 8
			CASE ELSE:				typeAlias[i] = 0:		typeAlign[i] = 0
		END SELECT
	NEXT
'
	reg86$[ 1] = "%esp"			' esp
	reg86$[ 2] = "%al"			' al
	reg86$[ 3] = "%dl"			' dl
	reg86$[ 4] = "%bl"			' bl
	reg86$[ 5] = "%cl"			' cl
	reg86$[ 6] = "%ax"			' ax
	reg86$[ 7] = "%dx"			' dx
	reg86$[ 8] = "%bx"			' bx
	reg86$[ 9] = "%cx"			' cx
	reg86$[10] = "%eax"			' eax
	reg86$[11] = "%edx"			' edx			danger: register overload
	reg86$[12] = "%ebx"			' ebx
	reg86$[13] = "%ecx"			' ecx			danger: register overload
	reg86$[26] = "%esi"			' esi
	reg86$[27] = "%edi"			' edi
	reg86$[28] = "%ecx"			' ecx			danger: register overload
	reg86$[29] = "%edx"			' edx			danger: register overload
	reg86$[31] = "%ebp"			' ebp
'
	reg86c$[ 1]	= "%esp,"		' esp,
	reg86c$[ 2] = "%al,"		' al,
	reg86c$[ 3] = "%dl,"		' dl,
	reg86c$[ 4] = "%bl,"		' bl,
	reg86c$[ 5] = "%cl,"		' cl,
	reg86c$[ 6] = "%ax,"		' ax,
	reg86c$[ 7] = "%dx,"		' dx,
	reg86c$[ 8] = "%bx,"		' bx,
	reg86c$[ 9] = "%cx,"		' cx,
	reg86c$[10] = "%eax,"		' eax,
	reg86c$[11] = "%edx,"		' edx,		danger: register overload
	reg86c$[12] = "%ebx,"		' ebx,
	reg86c$[13] = "%ecx,"		' ecx,		danger: register overload
	reg86c$[26] = "%esi,"		' esi,
	reg86c$[27] = "%edi,"		' edi,
	reg86c$[28] = "%ecx,"		' ecx,		danger: register overload
	reg86c$[29] = "%edx,"		' edx,		danger: register overload
	reg86c$[31] = "%ebp,"		' ebp,
'
'
' *****************************************************
' *****  DEFINE REGISTER ORIENTED ARRAY CONTENTS  *****
' *****************************************************
'
	r = 0
	DO WHILE (r < 32)
		r_addr[r]  = r												' r.addr[r]  = r
		INC r
	LOOP
	r_addr$[ 1] = "%esp"		' esp
	r_addr$[ 2] = "%al"			' al
	r_addr$[ 3] = "%dl"			' dl
	r_addr$[ 4] = "%bl"			' bl
	r_addr$[ 5] = "%cl"			' cl
	r_addr$[ 6] = "%ax"			' ax
	r_addr$[ 7] = "%dx"			' dx
	r_addr$[ 8] = "%bx"			' bx
	r_addr$[ 9] = "%cx"			' cx
	r_addr$[10] = "%eax"		' eax
	r_addr$[11] = "%edx"		' edx
	r_addr$[12] = "%ebx"		' ebx
	r_addr$[13] = "%ecx"		' ecx
	r_addr$[26] = "%esi"		' esi
	r_addr$[27] = "%edi"		' edi
	r_addr$[28] = "%edx"		' edx
	r_addr$[29] = "%ecx"		' ecx
'
'
'  **************************************************************************
'  *****  DONE INITIALIZING ARRAYS THAT NEED INITIALIZATION EVERY TIME  *****
'  **************************************************************************
'
	IF reEntry THEN RETURN
	reEntry			= $$TRUE
'
' **************************************************************************
' *****  THE FOLLOWING ARRAYS NEED ONLY BE DIMENSIONED / DEFINED ONCE  *****
' **************************************************************************
'
	DIM shiftMulti[1040]
	DIM assemblerBackslashAsm$[255]
	DIM	charsetSymbolFirst[255]
	DIM	charsetSymbolInner[255]
	DIM	charsetSymbolFinal[255]
	DIM charsetSymbol[255]
	DIM	charsetPath[255]
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
	DIM	charsetBackslashByte[255]
	DIM	charsetBackslashChar[255]
	DIM	charsetNormalChar[255]
	DIM	charsetPrintChar[255]
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
'
'
' **************************************
' *****  assemblerBackslashAsm$[]  *****
' **************************************
'
	FOR i = 0 TO 255
		o$	= "\\" + CHR$(0x30 + i{3,6}) + CHR$(0x30 + i{3,3}) + CHR$(0x30 + i{3,0})
		assemblerBackslashAsm$[i] = o$
	NEXT i
'
'
' *************************************
' *****  DEFINE "charset" ARRAYS  *****
' *************************************
'
'
' **********************************
' *****  charsetSymbolFirst[]  *****  A-Z  a-z  (others 0)
' **********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):   charsetSymbolFirst[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):   charsetSymbolFirst[i] = i
			CASE  (i  = '_'):										charsetSymbolFirst[i] = i
			CASE ELSE:													charsetSymbolFirst[i] = 0
		END SELECT
	NEXT i
'
'
' **********************************
' *****  charsetSymbolInner[]  *****  A-Z  a-z  0-9  "_"  (others 0)
' **********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetSymbolInner[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetSymbolInner[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetSymbolInner[i] = i
			CASE  (i  = '_'):										charsetSymbolInner[i] = i
			CASE ELSE:													charsetSymbolInner[i] = 0
		END SELECT
	NEXT i
'
'
' **********************************
' *****  charsetSymbolFinal[]  *****  A-Z  a-z  0-9  "_"  (others 0)
' **********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetSymbolFinal[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetSymbolFinal[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetSymbolFinal[i] = i
			CASE  (i  = '_'):										charsetSymbolFinal[i] = i
			CASE ELSE:													charsetSymbolFinal[i] = 0
		END SELECT
	NEXT i
'
'
' *****************************
' *****  charsetSymbol[]  *****  A-Z  a-z  0-9  "_"  (others 0)
' *****************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetSymbol[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetSymbol[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetSymbol[i] = i
			CASE  (i  = '_'):										charsetSymbol[i] = i
			CASE ELSE:													charsetSymbol[i] = 0
		END SELECT
	NEXT i
'
'
' ***************************
' *****  charsetPath[]  *****  most characters except whitespace and ; :
' ***************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9'))	: charsetPath[i] = i
			CASE ((i >= 'A') AND (i <= 'Z'))	: charsetPath[i] = i
			CASE ((i >= 'a') AND (i <= 'z'))	: charsetPath[i] = i
			CASE  (i  = '.')									: charsetPath[i] = i
			CASE  (i  = '-')									: charsetPath[i] = i
			CASE  (i  = '_')									: charsetPath[i] = i
			CASE  (i  = '@')									: charsetPath[i] = i
			CASE  (i  = '#')									: charsetPath[i] = i
			CASE  (i  = '$')									: charsetPath[i] = i
			CASE  (i  = '%')									: charsetPath[i] = i
			CASE  (i  = '^')									: charsetPath[i] = i
			CASE  (i  = '&')									: charsetPath[i] = i
			CASE  (i  = '*')									: charsetPath[i] = i
			CASE  (i  = '/')									: charsetPath[i] = i
			CASE  (i  = '(')									: charsetPath[i] = i
			CASE  (i  = ')')									: charsetPath[i] = i
			CASE  (i  = '[')									: charsetPath[i] = i
			CASE  (i  = ']')									: charsetPath[i] = i
			CASE  (i  = '{')									: charsetPath[i] = i
			CASE  (i  = '}')									: charsetPath[i] = i
			CASE  (i  = '\\')									: charsetPath[i] = i
			CASE ELSE:													charsetPath[i] = 0
		END SELECT
	NEXT i
'
'
' ****************************
' *****  charsetUpper[]  *****  A-Z  (others 0)
' ****************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpper[i] = i
			CASE ELSE:													charsetUpper[i] = 0
		END SELECT
	NEXT i
'
'
' ****************************
' *****  charsetLower[]  *****  a-z  (others 0)
' ****************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'a') AND (i <= 'z')):   charsetLower[i] = i
			CASE ELSE:													charsetLower[i] = 0
		END SELECT
	NEXT i
'
'
' ******************************
' *****  charsetNumeric[]  *****  0-9  (others 0)
' ******************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetNumeric[i] = i
			CASE ELSE:													charsetNumeric[i] = 0
		END SELECT
	NEXT i
'
'
' *********************************
' *****  charsetUpperLower[]  *****  A-Z  a-z  (others 0)
' *********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperLower[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):   charsetUpperLower[i] = i
			CASE ELSE:													charsetUpperLower[i] = 0
		END SELECT
	NEXT i
'
'
' ***********************************
' *****  charsetUpperNumeric[]  *****  A-Z  0-9  (others 0)
' ***********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetUpperNumeric[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperNumeric[i] = i
			CASE ELSE:													charsetUpperNumeric[i] = 0
		END SELECT
	NEXT i
'
'
' ***********************************
' *****  charsetLowerNumeric[]  *****  a-z  0-9  (others 0)
' ***********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetLowerNumeric[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetLowerNumeric[i] = i
			CASE ELSE:													charsetLowerNumeric[i] = 0
		END SELECT
	NEXT i
'
'
' ****************************************
' *****  charsetUpperLowerNumeric[]  *****  A-Z  a-z  0-9  (others 0)
' ****************************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetUpperLowerNumeric[i] = i
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperLowerNumeric[i] = i
			CASE ((i >= 'a') AND (i <= 'z')):		charsetUpperLowerNumeric[i] = i
			CASE ELSE:													charsetUpperLowerNumeric[i] = 0
		END SELECT
	NEXT i
'
'
' ***********************************
' *****  charsetUpperToLower[]  *****  A-Z  ==>>  a-z  (others unchanged)
' ***********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'A') AND (i <= 'Z')):		charsetUpperToLower[i] = i + 32
			CASE ELSE:													charsetUpperToLower[i] = i
		END SELECT
	NEXT i
'
'
' ***********************************
' *****  charsetLowerToUpper[]  *****  a-z  ==>>  A-Z  (others unchanged)
' ***********************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= 'a') AND (i <= 'z')):		charsetLowerToUpper[i] = i - 32
			CASE ELSE:													charsetLowerToUpper[i] = i
		END SELECT
	NEXT i
'
'
' **************************
' *****  charsetVex[]  *****  0-9  A-V  (others 0)
' **************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetVex[i] = i
			CASE ((i >= 'A') AND (i <= 'V')):   charsetVex[i] = i
			CASE ELSE:													charsetVex[i] = 0
		END SELECT
	NEXT i
'
'
' *******************************
' *****  charsetHexUpper[]  *****  0-9  A-F  (others 0)
' *******************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexUpper[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexUpper[i] = i
			CASE ELSE:													charsetHexUpper[i] = 0
		END SELECT
	NEXT i
'
'
' *******************************
' *****  charsetHexLower[]  *****  0-9  a-f  (others 0)
' *******************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexLower[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):   charsetHexLower[i] = i
			CASE ELSE:													charsetHexLower[i] = 0
		END SELECT
	NEXT i
'
'
' ************************************
' *****  charsetHexUpperLower[]  *****  0-9  A-F  a-f  (others 0)
' ************************************
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexUpperLower[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexUpperLower[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexUpperLower[i] = i
			CASE ELSE:													charsetHexUpperLower[i] = 0
		END SELECT
	NEXT i
'
'
' **************************************  0-9
' *****  charsetHexUpperToLower[]  *****  A-F  ==>>  a-f  (others 0)
' **************************************  a-f
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexUpperToLower[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexUpperToLower[i] = i + 32
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexUpperToLower[i] = i
			CASE ELSE:													charsetHexUpperToLower[i] = 0
		END SELECT
	NEXT i
'
'
' **************************************  0-9
' *****  charsetHexLowerToUpper[]  *****  a-f  ==>>  A-F  (others 0)
' **************************************  A-F
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetHexLowerToUpper[i] = i
			CASE ((i >= 'A') AND (i <= 'F')):		charsetHexLowerToUpper[i] = i
			CASE ((i >= 'a') AND (i <= 'f')):		charsetHexLowerToUpper[i] = i - 32
			CASE ELSE:													charsetHexLowerToUpper[i] = 0
		END SELECT
	NEXT i
'
'
' ********************************  \a  \b  \d  \f  \n  \r  \v  \\  \"  \z
' *****  charsetBackslash[]  *****  \0 - \V
' ********************************  (others unchanged)
'
' Convert character following a \ into the proper binary value
' For all characters without special binary values, return the character
'
	offset = 10 - 'A'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE ((i >= '0') AND (i <= '9')):		charsetBackslash[i] = i - '0'
			CASE ((i >= 'A') AND (i <= 'V')):		charsetBackslash[i] = i + offset
			CASE ELSE:													charsetBackslash[i] = i
		END SELECT
	NEXT i
'
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
'
'
' ************************************  \a  \b  \d  \e  \f  \n  \r  \t  \v
' *****  charsetBackslashByte[]  *****  \\  \"
' ************************************
'
' Return printable character intended to follow \ backslash character for
' SIMPLE (only simple) 1 character backslash codes, as understood by dumb
' assemblers, for example.  Otherwise, return zero.
'
	FOR i = 0 TO 255
		SELECT CASE i
			CASE 0x5C:	charsetBackslashByte[i] = '\\'	' backslash
			CASE 0x22:	charsetBackslashByte[i] = '"'		' double-quote
			CASE 0x07:	charsetBackslashByte[i] = 'a'		' alarm (bell)
			CASE 0x08:	charsetBackslashByte[i] = 'b'		' backspace
			CASE 0x7F:	charsetBackslashByte[i] = 'd'		' delete
			CASE 0x1B:	charsetBackslashByte[i] = 'e'		' escape
			CASE 0x0C:	charsetBackslashByte[i] = 'f'		' form-feed
			CASE 0x0A:	charsetBackslashByte[i] = 'n'		' newline
			CASE 0x0D:	charsetBackslashByte[i] = 'r'		' return
			CASE 0x09:	charsetBackslashByte[i] = 't'		' tab
			CASE 0x0B:	charsetBackslashByte[i] = 'v'		' vertical-tab
			CASE 0x00:	charsetBackslashByte[i] = '0'		' null
			CASE ELSE:	charsetBackslashByte[i] = 0			' non-simple backslash
		END SELECT
	NEXT i
'
'
' ************************************  \a  \b  \d  \e  \f  \n  \r  \t  \v
' *****  charsetBackslashChar[]  *****  \\  \"
' ************************************
'
' Return printable character intended to follow \ backslash character
' Return bytes that are normal, printable, non-backslash characters
'
	FOR i = 0 TO 255
		SELECT CASE i
			CASE 0x5C:	charsetBackslashChar[i] = '\\'	' backslash
			CASE 0x22:	charsetBackslashChar[i] = '"'		' double-quote
			CASE 0x07:	charsetBackslashChar[i] = 'a'		' alarm (bell)
			CASE 0x08:	charsetBackslashChar[i] = 'b'		' backspace
			CASE 0x7F:	charsetBackslashChar[i] = 'd'		' delete
			CASE 0x1B:	charsetBackslashChar[i] = 'e'		' escape
			CASE 0x0C:	charsetBackslashChar[i] = 'f'		' form-feed
			CASE 0x0A:	charsetBackslashChar[i] = 'n'		' newline
			CASE 0x0D:	charsetBackslashChar[i] = 'r'		' return
			CASE 0x09:	charsetBackslashChar[i] = 't'		' tab
			CASE 0x0B:	charsetBackslashChar[i] = 'v'		' vertical-tab
			CASE ELSE:	charsetBackslashChar[i] = 0			' not a backslash char
		END SELECT
	NEXT i
'
'
' *********************************  0x00 - 0x1F  ===>>  0
' *****  charsetNormalChar[]  *****  0x7F - 0xFF  ===>>  0  (others unchanged)
' *********************************   \  and  "   ===>>  0
'
' Normal printable characters = the character, all others = 0
' NOTE:  tab, newline, etc... not considered normal printable characters
' NOTE:  backslash not considered normal printable character (need \\)
' NOTE:  double-quote not considered normal printable character (need \")
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE (i <=  31):	charsetNormalChar[i] = 0
			CASE (i >= 127):	charsetNormalChar[i] = 0
			CASE (i = '\\'):	charsetNormalChar[i] = 0
			CASE (i = '"'):		charsetNormalChar[i] = 0
			CASE ELSE:				charsetNormalChar[i] = i
		END SELECT
	NEXT i
'
'
' ********************************  0x00 - 0x1F  ===>>  0
' *****  charsetPrintChar[]  *****  0x7F - 0xFF  ===>>  0
' ********************************  (others unchanged)
'
' Printable characters = the character, all others = 0
' NOTE:  tab, newline, etc... not considered normal printable characters
' NOTE:  backslash is a printable character
' NOTE:  double-quote is a printable character
'
	FOR i = 0 TO 255
		SELECT CASE TRUE
			CASE (i <=  31):	charsetPrintChar[i] = 0
			CASE (i >= 127):	charsetPrintChar[i] = 0
			CASE ELSE:				charsetPrintChar[i] = i
		END SELECT
	NEXT i
'
'
' *******************************
' *****  charsetSpaceTab[]  *****  only <space> and <tab> are true
' *******************************
'
	charsetSpaceTab[0x09]	= 0x09		' <tab>		= '\t'
	charsetSpaceTab[0x20]	= 0x20		' <space>	= ' '
'
'
' *****************************
' *****  charsetSuffix[]  *****  valid type suffixes
' *****************************
'
	charsetSuffix['@']	= '@'
	charsetSuffix['%']	= '%'
	charsetSuffix['&']	= '&'
	charsetSuffix['~']	= '~'
	charsetSuffix['!']	= '!'
	charsetSuffix['#']	= '#'
	charsetSuffix['$']	= '$'
'
'
' ********************************************************
' *****  Define the contents of several more arrays  *****
' ********************************************************
'
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
'
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
'
	blanks[0] = 0x00000000		' no spaces or tabs
	blanks[1] = 0x20000000		' 1 space
	blanks[2] = 0x40000000		' 2 spaces
	blanks[3] = 0x60000000		' 3 spaces
	blanks[4] = 0x80000000		' 4 tabs
	blanks[5] = 0xA0000000		' 3 tabs
	blanks[6] = 0xC0000000		' 2 tabs
	blanks[7] = 0xE0000000		' 1 tab
'
'
' *****  q_type_long[]  *****
'
	q_type_long [ $$SLONG ] = $$SLONG
	q_type_long [ $$ULONG ] = $$ULONG
	q_type_long [ $$XLONG ] = $$XLONG
'
	q_type_long_or_addr [ $$SLONG			] = $$SLONG
	q_type_long_or_addr [ $$ULONG			] = $$ULONG
	q_type_long_or_addr [ $$XLONG			] = $$XLONG
	q_type_long_or_addr [ $$GOADDR		] = $$GOADDR
	q_type_long_or_addr [ $$SUBADDR		] = $$SUBADDR
	q_type_long_or_addr [ $$FUNCADDR	] = $$FUNCADDR
'
'
' **************************
' *****  shiftMulti[]  *****  UBYTE array
' **************************
'
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
'
'
' ***************************
' *****  typeConvert[]  *****  SSHORT array
' ***************************
'
' typeConvert[i,j] is used to find out whether a source operand of type "j"
' can be converted to type "i".  The contents of typeConvert[i,j] is the
' working result type of the conversion will be, which is type "i" unless
' type "i" is less than SLONG, in which case the working result type is SLONG.
' If conversion from type "j" to type "i" is invalid, then the contents of
' typeConvert[i,j] = 1.  If conversion is unnecessary, typeConvert[i,j] = 0.
' Otherwise typeConvert[i,j] = working result type
'
' NOTE:  Entries for error cases are not needed in the CASE statements since
'        unspecified entries becomes an error by "typeConvert[i,j] = terror".
'
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
					END SELECT
				CASE $$STRING
					SELECT CASE j
						CASE $$STRING:		typeConvert[i,j] = same			' same
					END SELECT
		END SELECT
		NEXT j
	NEXT i
'
'
' **************************
' *****  typeHigher[]  *****
' **************************
'
' typeHigher[i,j] is used to find out which of two types must be converted
' to the type of the other to get to the "higher" type.  "i" and "j" are the
' data types of operand #1 and operand #2.  The contents of typeHigher[i,j]
' tells what type each operand must be converted to, the higher of the two
' types, plus the "working" result type (SLONG for SBYTE through SLONG).
'
' Each byte of the XLONG contents of typeHigher[i,j] contains information:
'
' LSB  Byte 0:  Data type to convert "j" to
'      Byte 1:  Data type to convert "i" to
'      Byte 2:  Higher type
' MSB  Byte 3:	Result type  (SLONG for Higher type = SBYTE to SLONG)
'
' typeHigher[i,j] = terror if type conversion is invalid.
' typeHigher[i,j] = inone  if "i" is higher type but conversion is unnecessary.
' typeHigher[i,j] = jnone  if "j" is higher type but conversion is unnecessary.
' typeHigher[i,j] = tsame  if "i" and "j" are the same type (no conversion).
'
' NOTE:  Entries for error cases are not needed in the CASE statements since
'        unspecified entries becomes an error by "typeHigher[i,j] = terror".
'
	terror	= -1											' error
	FOR i = 0 TO 31										' i			= 1st data type
		FOR j = 0 TO 31									' j			= 2nd data type
			IF ((i <= $$SLONG) AND (j <= $$SLONG)) THEN
				r	= $$SLONG << 24
			ELSE
				IF (i > j) THEN r = i << 24 ELSE r = j << 24
			END IF
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
		END SELECT
		NEXT j
	NEXT i
'
'
' *************************************************
' *****  Load cop[] from diskfile "copx.xxx"  *****
' *************************************************
'
	##ERROR = $$FALSE
	GetSubPath (@"xxx", "", @path$[])
	XstFindFile (@"copx.bin", @path$[], @f$, @attr)
	copfile = OPEN (f$, $$RD)
	IF (copfile <= 0) THEN
		f$ = "./xxx/copx.bin"
		copfile = OPEN (f$, $$RD)
		IF (copfile <= 0) THEN
			f$ = "$HOME/xb/xxx/copx.bin"
			copfile = OPEN (f$, $$RD)
			IF (copfile <= 0) THEN
				f$ = "/usr/xb/xxx/copx.bin"
				copfile = OPEN (f$, $$RD)
				IF (copfile <= 0) THEN
					f$ = "/xb/xxx/copx.bin"
					copfile = OPEN (f$, $$RD)
					IF (copfile <= 0) THEN
						PRINT "*****  FATAL ERROR  *****  file <copx.bin> not found  *****"
						RETURN
					END IF
				END IF
			END IF
		END IF
	END IF
'
	FOR x = 0 TO 11											' operator table # (operator class)
		FOR y = 0 TO 15										' operand 1 (left)
			FOR z = 0 TO 15									' operand 2 (right)
				READ [copfile], temp					' get operator control word
				cop[x, y, z] = temp						' put it in cop[]
			NEXT z
		NEXT y
	NEXT x
	CLOSE (copfile)
END FUNCTION
'
'
' ############################
' #####  InitComplex ()  #####
' ############################
'
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
'
' Create arrays to hold information on SCOMPLEX data type
'
	DIM  tempEleSymbol$[3]
	DIM  tempEleToken[3]
	DIM  tempEleAddr[3]
	DIM	 tempEleSize[3]
	DIM  tempEleType[3]
	DIM  tempEleVal[3]
	DIM  tempElePtr[3]
	DIM  tempEleStringSize[3]
	DIM  tempEleUBound[3]
'
' Attach arrays to type arrays at SCOMPLEX data type
'
	ATTACH tempEleSymbol$[] TO typeEleSymbol$[$$SCOMPLEX, ]
	ATTACH tempEleToken[] TO typeEleToken[$$SCOMPLEX, ]
	ATTACH tempEleAddr[] TO typeEleAddr[$$SCOMPLEX, ]
	ATTACH tempEleSize[] TO typeEleSize[$$SCOMPLEX, ]
	ATTACH tempEleType[] TO typeEleType[$$SCOMPLEX, ]
	ATTACH tempEleVal[] TO typeEleVal[$$SCOMPLEX, ]
	ATTACH tempElePtr[] TO typeElePtr[$$SCOMPLEX, ]
	ATTACH tempEleStringSize[] TO typeEleStringSize[$$SCOMPLEX, ]
	ATTACH tempEleUBound[] TO typeEleUBound[$$SCOMPLEX, ]
'
' Create arrays to hold information on DCOMPLEX data type
'
	DIM  tempEleSymbol$[3]
	DIM  tempEleToken[3]
	DIM  tempEleAddr[3]
	DIM	 tempEleSize[3]
	DIM  tempEleType[3]
	DIM  tempEleVal[3]
	DIM  tempElePtr[3]
	DIM  tempEleStringSize[3]
	DIM  tempEleUBound[3]
'
' Attach arrays to type arrays at DCOMPLEX data type
'
	ATTACH tempEleSymbol$[] TO typeEleSymbol$[$$DCOMPLEX, ]
	ATTACH tempEleToken[] TO typeEleToken[$$DCOMPLEX, ]
	ATTACH tempEleAddr[] TO typeEleAddr[$$DCOMPLEX, ]
	ATTACH tempEleSize[] TO typeEleSize[$$DCOMPLEX, ]
	ATTACH tempEleType[] TO typeEleType[$$DCOMPLEX, ]
	ATTACH tempEleVal[] TO typeEleVal[$$DCOMPLEX, ]
	ATTACH tempElePtr[] TO typeElePtr[$$DCOMPLEX, ]
	ATTACH tempEleStringSize[] TO typeEleStringSize[$$DCOMPLEX, ]
	ATTACH tempEleUBound[] TO typeEleUBound[$$DCOMPLEX, ]
'
' Fill in SCOMPLEX and DCOMPLEX data type arrays
'
	typeEleCount [$$SCOMPLEX]			= 2				' 2 elements; real/imaginary
	typeEleCount [$$DCOMPLEX]			= 2				' 2 elements; real/imaginary
'
	typeEleSymbol$ [$$SCOMPLEX, 0] = ".R"		' REAL
	typeEleSymbol$ [$$SCOMPLEX, 1] = ".I"		' IMAGINARY
	typeEleSymbol$ [$$DCOMPLEX, 0] = ".R"		' REAL
	typeEleSymbol$ [$$DCOMPLEX, 1] = ".I"		' IMAGINARY
'
	tokenR = AddSymbol (".R", $$T_SYMBOLS, 0)
	tokenI = AddSymbol (".I", $$T_SYMBOLS, 0)
'
	typeEleToken [$$SCOMPLEX, 0] 	= tokenR
	typeEleToken [$$SCOMPLEX, 1] 	= tokenI
	typeEleToken [$$DCOMPLEX, 0] 	= tokenR
	typeEleToken [$$DCOMPLEX, 1] 	= tokenI
'
	typeEleAddr [$$SCOMPLEX, 0]		=  0
	typeEleAddr [$$SCOMPLEX, 1]		=  4
	typeEleAddr [$$DCOMPLEX, 0]		=  0
	typeEleAddr [$$DCOMPLEX, 1]		=  8
'
	typeEleSize [$$SCOMPLEX, 0]		=  4
	typeEleSize [$$SCOMPLEX, 1]		=  4
	typeEleSize [$$DCOMPLEX, 0]		=  8
	typeEleSize [$$DCOMPLEX, 1]		=  8
'
	typeEleType [$$SCOMPLEX, 0]		=  $$SINGLE
	typeEleType [$$SCOMPLEX, 1]		=  $$SINGLE
	typeEleType [$$DCOMPLEX, 0]		=  $$DOUBLE
	typeEleType [$$DCOMPLEX, 1]		=  $$DOUBLE
'
	typeEleVal [$$SCOMPLEX, 0]		= 0
	typeEleVal [$$SCOMPLEX, 1]		= 0
	typeEleVal [$$DCOMPLEX, 0]		= 0
	typeEleVal [$$DCOMPLEX, 1]		= 0
'
	typeElePtr [$$SCOMPLEX, 0]		= 0
	typeElePtr [$$SCOMPLEX, 1]		= 0
	typeElePtr [$$DCOMPLEX, 0]		= 0
	typeElePtr [$$DCOMPLEX, 1]		= 0
'
	typeEleStringSize [$$SCOMPLEX, 0]		= 0
	typeEleStringSize [$$SCOMPLEX, 1]		= 0
	typeEleStringSize [$$DCOMPLEX, 0]		= 0
	typeEleStringSize [$$DCOMPLEX, 1]		= 0
'
	typeEleUBound [$$SCOMPLEX, 0]		= 0
	typeEleUBound [$$SCOMPLEX, 1]		= 0
	typeEleUBound [$$DCOMPLEX, 0]		= 0
	typeEleUBound [$$DCOMPLEX, 1]		= 0
END FUNCTION
'
'
' #######################
' #####  InitEntry  #####
' #######################
'
FUNCTION  InitEntry ()
	SHARED	ofile
'
	ofile			= $$STDOUT
	##GLOBAL	= ##GLOBAL0
	##GLOBALX	= ##GLOBAL0
END FUNCTION
'
'
' ###########################
' #####  InitErrors ()  #####
' ###########################
'
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
'
	e = 1
	ERROR_AFTER_ELSE          = e:  xerror$[e] = "After CASE ELSE":					INC e
	ERROR_BAD_CASE_ALL        = e:  xerror$[e] = "Bad CASE ALL":						INC e
	ERROR_BAD_GOSUB           = e:  xerror$[e] = "Bad GOSUB dest type":			INC e
	ERROR_BAD_GOTO            = e:  xerror$[e] = "Bad GOTO dest type":			INC e
	ERROR_BAD_SYMBOL					= e:  xerror$[e] = "Bad Symbol":							INC e
	ERROR_BITSPEC							= e:	xerror$[e] = "Bad Bitfield Spec":				INC e
	ERROR_BYREF               = e:  xerror$[e] = "Bad Pass By Reference":		INC e
	ERROR_BYVAL               = e:  xerror$[e] = "Bad Pass By Value":				INC e
	ERROR_COMPILER            = e:  xerror$[e] = "Compiler Error":					INC e
	ERROR_COMPONENT						= e:	xerror$[e] = "Component Error":					INC e
	ERROR_CROSSED_FUNCTIONS   = e:  xerror$[e] = "Crossed Functions (X/C)":	INC e
	ERROR_DECLARE             = e:  xerror$[e] = "DECLARE after SHARED":		INC e
	ERROR_DECLARE_FUNCS_FIRST	= e:  xerror$[e] = "DECLARE too late":				INC e
	ERROR_DUP_DECLARATION     = e:  xerror$[e] = "Duplicate Declaration":		INC e
	ERROR_DUP_DEFINITION      = e:  xerror$[e] = "Duplicate Definition":		INC e
	ERROR_DUP_LABEL           = e:  xerror$[e] = "Duplicate Label":					INC e
	ERROR_DUP_TYPE						= e:	xerror$[e] = "Duplicate Type":					INC e
	ERROR_ELSE_IN_CASE_ALL    = e:  xerror$[e] = "CASE ELSE in CASE ALL":		INC e
	ERROR_ENTRY_FUNCTION			= e:	xerror$[e] = "Entry Function Error":		INC e
	ERROR_EXPECT_ASSIGNMENT		= e:	xerror$[e] = "Expect Assignment":				INC e
	ERROR_EXPRESSION_STACK    = e:  xerror$[e] = "Expression Error":				INC e
	ERROR_FILE_NOT_FOUND			= e:	xerror$[e] = "File Not Found":					INC e
	ERROR_INTERNAL_EXTERNAL		= e:	xerror$[e] = "Internal / External":			INC e
	ERROR_KIND_MISMATCH       = e:  xerror$[e] = "Kind Mismatch":						INC e
	ERROR_LITERAL             = e:  xerror$[e] = "Literal Error":						INC e
	ERROR_NEED_EXCESS_COMMA		= e:	xerror$[e] = "Need Excess Comma":				INC e
	ERROR_NEED_SUBSCRIPT			= e:	xerror$[e] = "Need Subscript":					INC e
	ERROR_NEST                = e:  xerror$[e] = "Nesting Error":						INC e
	ERROR_NODE_DATA_MISMATCH	= e:	xerror$[e] = "Node / Data Mismatch":		INC e
	ERROR_OPEN_FILE						= e:	xerror$[e] = "Open Error":							INC e
	ERROR_OUTSIDE_FUNCTIONS   = e:  xerror$[e] = "Outside Functions Error":	INC e
	ERROR_OVERFLOW            = e:  xerror$[e] = "Overflow Error":					INC e
	ERROR_PROGRAM_NOT_NAMED		= e:  xerror$[e] = "Program Not Named":				INC e
	ERROR_REGADDR             = e:  xerror$[e] = "Register Address":				INC e
	ERROR_RETYPED             = e:  xerror$[e] = "Duplicate Type Spec":			INC e
	ERROR_SCOPE_MISMATCH      = e:  xerror$[e] = "Scope Mismatch":					INC e
	ERROR_SHARENAME           = e:  xerror$[e] = "Sharename Error":					INC e
	ERROR_SYNTAX              = e:  xerror$[e] = "Syntax Error":						INC e
	ERROR_TOO_FEW_ARGS        = e:  xerror$[e] = "Too Few Arguments":				INC e
	ERROR_TOO_LATE            = e:  xerror$[e] = "Too Late":								INC e
	ERROR_TOO_MANY_ARGS       = e:  xerror$[e] = "Too Many Arguments":			INC e
	ERROR_TYPE_MISMATCH       = e:  xerror$[e] = "Type Mismatch":						INC e
	ERROR_UNDECLARED          = e:  xerror$[e] = "Undeclared":							INC e
	ERROR_UNDEFINED           = e:  xerror$[e] = "Undefined":								INC e
	ERROR_UNIMPLEMENTED       = e:  xerror$[e] = "Unimplemented":						INC e
	ERROR_VOID                = e:  xerror$[e] = "Void Error":							INC e
	ERROR_WITHIN_FUNCTION     = e:  xerror$[e] = "Within Function":					INC e
	uerror										= e - 1
END FUNCTION
'
'
' ############################
' #####  InitOptions ()  #####
' ############################
'
FUNCTION  InitOptions()
	EXTERNAL /xxx/	i486asm,  i486bin
	i486asm				= $$TRUE
	i486bin				= $$FALSE
END FUNCTION
'
'
' ############################
' #####  InitProgram ()  #####
' ############################
'
FUNCTION  InitProgram()
	EXTERNAL /xxx/	maxFuncNumber
	SHARED	func_number
'
	maxFuncNumber = 0
	func_number = 0
END FUNCTION
'
'
' ##############################
' #####  InitVariables ()  #####
' ##############################
'
FUNCTION  InitVariables ()
	EXTERNAL /xxx/	entryFunction,  xpc,  errorCount
	SHARED	defaultType[]
	SHARED	XERROR
	SHARED	charPtr,  defaultType
	SHARED	end_program,  func_number
	SHARED	got_declare,  got_executable,  got_export,  got_function
	SHARED	got_import,  got_object_declaration,  got_program,  got_type
	SHARED	hfn$,  ifLine,  infunc,  inlevel,  insub,  oos
	SHARED	labelNumber,  lineNumber
	SHARED	patchPtr,  labelPtr,  backToken,  lastToken,  nestCount,  nestLevel
	SHARED	section,  subCount,  tokenPtr,  tab_sym_ptr
	SHARED	programTypeChunk,  functionTypeChunk
	SHARED	pastSystemLabels,  pastSystemSymbols
	SHARED	nullstring$
	SHARED	pass
'
	#emitasm			= 0
	pass					= 0
	XERROR				= 0
	oos						= 0
	insub					= 0
	infunc				= 0
	inlevel				= 0
	ifLine				= 0
	charPtr				= 0
	subCount			= 0
	tokenPtr			= 0
	nestCount			= 0
	nestLevel			= 0
	backToken			= 0
	lastToken			= 0
	xpc						= ##UCODE
	##GLOBAL			= ##GLOBAL0
	##GLOBALX			= ##GLOBAL0
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
	section				= $$TEXTSECTION
	nullstring$		= CHR$(34) + CHR$(34)
'
	entryFunction							= 1
	programTypeChunk					= 0
	functionTypeChunk					= 0
	got_executable						= $$FALSE
	got_object_declaration		= $$FALSE
	defaultType[func_number]	= defaultType
END FUNCTION
'
' ######################################
' #####  InvalidExternalSymbol ()  #####
' ######################################
'
FUNCTION  InvalidExternalSymbol (x$)
	SHARED	XERROR,  ERROR_COMPILER
	SHARED UBYTE  charsetSymbolInner[]
'
	IFZ x$ THEN GOTO eeeCompiler
	testOffset	= LEN(x$) - 1
	testChar		= x${testOffset}
	IF charsetSymbolInner[testChar] THEN RETURN ($$FALSE)
	IF (testChar	= '$') THEN
		IFZ testOffset THEN GOTO eeeCompiler
		DEC testOffset
		testChar		= x${testOffset}
		IF charsetSymbolInner[testChar] THEN RETURN ($$FALSE)
	END IF
	RETURN ($$TRUE)
'
eeeCompiler:
	XERROR	= ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ############################
' #####  LastElement ()  #####
' ############################
'
' Scans tokens ahead to determine if at last element in a composite
'
FUNCTION  LastElement (token, lastPlace, excessComma)
	SHARED	T_COMMA,  T_LBRAK,  T_RBRAK
	SHARED	tokenPtr
'
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
			END IF
			IF (old_token = T_COMMA) THEN
				lastPlace		= tokenPtr
				token				= NextToken ()
				tokenPtr		= hold_place
				excessComma = $$TRUE
				RETURN ($$TRUE)
			END IF
	END SELECT
'
	lastPlace		= tokenPtr								' point to end of current composite
	token				= NextToken ()						' is next token a composite?
	kind				= token{$$KIND}
	tokenPtr		= hold_place
	IF (kind = $$KIND_SYMBOLS) THEN RETURN ($$FALSE)
	IF (kind = $$KIND_ARRAY_SYMBOLS) THEN RETURN ($$FALSE)
	RETURN ($$TRUE)
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	EXIT FUNCTION
END FUNCTION
'
'
' ########################
' #####  Literal ()  #####
' ########################
'
FUNCTION  Literal (xx)
	SHARED	r_addr[]
'
	r = r_addr[xx{$$WORD0}]
	IF (r >= $$IMM16) AND (r <= $$CONNUM) THEN RETURN ($$TRUE)
	RETURN ($$FALSE)
END FUNCTION
'
'
' ###########################  dreg = 0 means push on CPU stack (esp stack)
' #####  LoadLitnum ()  #####
' ###########################
'
FUNCTION  LoadLitnum (dreg, dtype, source, stype)
	EXTERNAL /xxx/	xpc
	SHARED	reg86$[],  reg86c$[]
	SHARED	m_reg[],  m_addr[],  m_addr$[],  tab_sym[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	nullstringer
'
	ss = source{$$NUMBER}
	st = tab_sym[ss]
'
	IF (ss = nullstringer) THEN
		IF dreg THEN
			Code ($$xor, $$regreg, dreg, dreg, 0, $$XLONG, "", "### 786")
		ELSE
			Move (dreg, $$XLONG, nullstringer, $$XLONG)
		END IF
		RETURN
	END IF
'
	IF (dtype = $$STRING) THEN
		IFZ dreg THEN
			Code ($$push, $$imm, m_addr[ss], 0, 0, $$XLONG, m_addr$[ss], "### 787")
		ELSE
			PRINT "LoadLitnum(): Slits"
			Code ($$mov, $$regimm, dreg, 0, m_addr[ss], $$XLONG, m_addr$[ss], @"### 788")
		END IF
		RETURN
	END IF
'
	GetWords (source, dtype, @w3, @w2, @w1, @w0)
	IF XERROR THEN EXIT FUNCTION
'
	SELECT CASE dtype
		CASE $$GIANT
					IFZ dreg THEN
						Code ($$push, $$imm, (w3 << 16 + w2), 0, 0, $$XLONG, "", "### 789")
						Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, "", "### 790")
					ELSE
						Code ($$mov, $$regimm, dreg+1, (w3 << 16 + w2), 0, $$XLONG, "", @"### 791")
						Code ($$mov, $$regimm, dreg, (w1 << 16 + w0), 0, $$XLONG, "", @"### 792")
					END IF
		CASE $$DOUBLE
					Code ($$push, $$imm, (w3 << 16 + w2), 0, 0, $$XLONG, "", @"### 793")
					Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, "", @"### 794")
					IF dreg THEN
						Code ($$fld, $$ro, 0, $$esp, 0, $$DOUBLE, "", @"### 795")
						Code ($$add, $$regimm, $$esp, 8, 0, $$XLONG, "", @"### 796")
					END IF
		CASE $$SINGLE
					Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, "", @"### 797")
					IF dreg THEN
						Code ($$fld, $$ro, 0, $$esp, 0, $$SINGLE, "", @"### 798")
						Code ($$add, $$regimm, $$esp, 4, 0, $$XLONG, "", @"### 799")
					END IF
		CASE ELSE
					IFZ dreg THEN
						Code ($$push, $$imm, (w1 << 16 + w0), 0, 0, $$XLONG, "", "### 800")
					ELSE
						Code ($$mov, $$regimm, dreg, (w1 << 16 + w0), 0, $$XLONG, "", @"### 801")
					END IF
	END SELECT
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  MakeToken ()  #####
' ##########################
'
FUNCTION  MakeToken (keyword$, kind, data_type)
	SHARED	tab_sys$[],  tab_sys[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	tab_sys_ptr
'
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
		CASE ELSE																									: PRINT "mmm1": GOTO eeeCompiler
	END SELECT
'
make_system:
	the_token = (kind << 24) OR (data_type << 16) OR tab_sys_ptr
	tab_sys$[tab_sys_ptr] = keyword$
	tab_sys[tab_sys_ptr] = the_token
	INC tab_sys_ptr
	RETURN (the_token)
'
' make white.space token  (data.type = # of spaces, word0 = error #)
' make start token  (word0 = # of tokens generated for this line)
' make error token  (data.type = # of bytes in error text)
'
make_comment:
	the_token = kind << 24
	RETURN (the_token)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##################################
' #####  MinTypeFromDouble ()  #####
' ##################################
'
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
'
'
' #################################
' #####  MinTypeFromGiant ()  #####
' #################################
'
FUNCTION	MinTypeFromGiant (v$$)
	SELECT CASE TRUE
		CASE ((v$$ >= $$MIN_USHORT) AND (v$$ <= $$MAX_USHORT)):	rt = $$USHORT
		CASE ((v$$ >= $$MIN_SSHORT) AND (v$$ <= $$MAX_SSHORT)):	rt = $$SSHORT
		CASE ((v$$ >= $$MIN_SLONG)  AND (v$$ <= $$MAX_SLONG)):	rt = $$SLONG
		CASE ELSE:																							rt = $$GIANT
	END SELECT
	RETURN (rt)
END FUNCTION
'
'
' #####################  destin = 0 means push on CPU stack (esp stack)
' #####  Move ()  #####
' #####################
'
FUNCTION  Move (destin, d_type, source, s_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	reg86$[],  reg86c$[]
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	r_addr[],  r_addr$[],  tab_sym[],  tab_sym$[]
	SHARED	typeSize[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH
	SHARED	a0_type,  a1_type,  charPtr,  nullstringer
	SHARED SSHORT typeConvert[]
'
	dext		= $$FALSE									' not EXTERNAL destination
	sext		= $$FALSE									' not EXTERNAL source
	dxarg		= $$FALSE									' not excess argument destination
	sxarg		= $$FALSE									' not excess argument source
	slits		= $$FALSE									' not "literal string"
	sdest		= destin AND 0xFFFF
	ssource	= source AND 0xFFFF
	IF (sdest > $$CONNUM) THEN
		d		= tab_sym[sdest]
		k		= d{$$KIND}
		da	= d{$$ALLO}
		IF (da = $$EXTERNAL) THEN dext = $$TRUE
	END IF
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
	END IF
	IFZ d_type THEN d_type = s_type
	d_reg = 0
	s_reg = r_addr[ssource]
	IF destin THEN d_reg = r_addr[sdest]
	SELECT CASE d_type
		CASE $$SINGLE:	dfloat = $$TRUE
		CASE $$DOUBLE:	dfloat = $$TRUE
		CASE ELSE:			dfloat = $$FALSE
	END SELECT
	SELECT CASE s_type
		CASE $$SINGLE:	sfloat = $$TRUE
		CASE $$DOUBLE:	sfloat = $$TRUE
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
			END IF
		END IF
	END IF
	IF (destin = source) THEN RETURN
	IF (d_type < $$SLONG) THEN d_type = $$SLONG
	IF (s_type < $$SLONG) THEN s_type = $$SLONG
	SELECT CASE d_reg
		CASE $$RA0:	a0_type = d_type
		CASE $$RA1:	a1_type = d_type
	END SELECT
'
'
' *************************************************************
' *****  Dispatch based on destination/source in reg/mem  *****
' *************************************************************
'
	IF d_reg THEN
		IF s_reg THEN GOTO drsr ELSE GOTO drsm
	ELSE
		IF s_reg THEN GOTO dmsr ELSE GOTO dmsm
	END IF
'
'
' ************************************************************
' *****  Destination in Register  :  Source in Register  *****
' ************************************************************
'
drsr:
	IF (s_reg = $$CONNUM) OR (s_reg = $$LITNUM) THEN
		LoadLitnum (d_reg, d_type, source, @s_type)
		RETURN
	END IF
	IF ((s_reg = $$IMM16) OR (s_reg = $$NEG16)) THEN
		IF ((s_type >= $$GIANT) AND (s_type != $$STRING)) THEN
			LoadLitnum (d_reg, d_type, source, @s_type)
		ELSE
			IF (ssource = nullstringer) THEN
				Code ($$xor, $$regreg, d_reg, d_reg, 0, $$XLONG, "", "### 802")
			ELSE
				x_imm	= XLONG (r_addr$[ssource])
				Code ($$mov, $$regimm, d_reg, x_imm, 0, $$XLONG, "", @"### 803")
			END IF
		END IF
		RETURN
	END IF
	IFZ dfloat THEN
		Code ($$mov, $$regreg, d_reg, s_reg, 0, $$XLONG, "", @"### 804")
		IF dtwo THEN
			Code ($$mov, $$regreg, d_regx, s_regx, 0, $$XLONG, "", @"### 805")
		END IF
	END IF
	RETURN
'
'
' **********************************************************
' *****  Destination in Register  :  Source in Memory  *****
' **********************************************************
'
drsm:
	IFZ source THEN
		PRINT "source=0"'
		GOTO eeeCompiler
	END IF
	mReg	= m_reg[ssource]
	mAddr	= m_addr[ssource]
	IFZ mReg THEN
		m$	= m_addr$[ssource]
		IF sfloat THEN
			Code ($$fld, $$abs, 0, 0, mAddr, s_type, @m$, @"### 806")
		ELSE
			IF slits THEN
				Code ($$mov, $$regimm, d_reg, mAddr, 0, s_type, @m$, @"### 807")
			ELSE
				Code ($$ld, $$regabs, d_reg, 0, mAddr, s_type, @m$, @"### 808")
			END IF
		END IF
	ELSE
		IF sfloat THEN
			Code ($$fld, $$ro, 0, mReg, mAddr, s_type, "", @"### 809")
		ELSE
			Code ($$ld, $$regro, d_reg, mReg, mAddr, s_type, "", @"### 810")
		END IF
	END IF
	RETURN
'
'
' **********************************************************
' *****  Destination in Memory  :  Source in Register  *****
' **********************************************************
'
dmsr:
	SELECT CASE s_reg
		CASE $$IMM16, $$NEG16
					IF ((s_type >= $$GIANT) AND (s_type != $$STRING)) THEN
						IFZ destin THEN
							LoadLitnum (0, d_type, source, s_type)					' push literal
							RETURN
						ELSE
							LoadLitnum ($$esi, d_type, source, s_type)
						END IF
					ELSE
						x_imm	= XLONG (r_addr$[ssource])
						IFZ destin THEN
							Code ($$push, $$imm, x_imm, 0, 0, $$XLONG, "", "### 811")		' push literal
							RETURN
						ELSE
							Code ($$mov, $$regimm, $$esi, x_imm, 0, $$XLONG, "", @"### 812")
						END IF
					END IF
					s_reg = $$esi
		CASE $$LITNUM, $$CONNUM
					IFZ destin THEN
						LoadLitnum (0, d_type, source, @s_type)		' push literal
						RETURN
					ELSE
						LoadLitnum ($$esi, d_type, source, @s_type)
					END IF
					s_reg = $$esi
	END SELECT
	mReg	= m_reg[sdest]
	mAddr	= m_addr[sdest]
	IFZ mReg THEN
		m$	= m_addr$[sdest]
		IF dfloat THEN
			IFZ destin THEN
				SELECT CASE d_type
					CASE $$SINGLE		: dsize = 4
					CASE $$DOUBLE		: dsize = 8
				END SELECT
				Code ($$sub, $$regimm, $$esp, dsize, 0, $$XLONG, "", "### 813")
				Code ($$fstp, $$ro, 0, $$esp, 0, d_type, "", "### 814")
				RETURN
			ELSE
				Code ($$fstp, $$abs, 0, 0, mAddr, d_type, @m$, @"### 815")
			END IF
		ELSE
			IFZ destin THEN
				Code ($$push, $$reg, s_reg, 0, 0, d_type, "", "### 816")
				RETURN
			ELSE
				Code ($$st, $$absreg, s_reg, 0, mAddr, d_type, @m$, @"### 817")
			END IF
		END IF
	ELSE
		IF dfloat THEN
			Code ($$fstp, $$ro, 0, mReg, mAddr, d_type, "", @"### 818")
		ELSE
			Code ($$st, $$roreg, s_reg, mReg, mAddr, d_type, "", @"### 819")
		END IF
	END IF
	RETURN
'
'
' ********************************************************
' *****  Destination in Memory  :  Source in Memory  *****
' ********************************************************
'
dmsm:
	mReg	= m_reg[ssource]
	mAddr	= m_addr[ssource]
	IFZ mReg THEN
		m$	= m_addr$[ssource]
		IF slits THEN
			IFZ destin THEN
				Code ($$push, $$imm, 0, 0, mAddr, $$XLONG, @m$, "### 820")
				RETURN
			ELSE
				Code ($$ld, $$regabs, $$esi, 0, mAddr, $$XLONG, @m$, @"### 821")
			END IF
		ELSE
			IF sfloat THEN
				Code ($$fld, $$abs, 0, 0, mAddr, s_type, @m$, @"### 822")
			ELSE
				IFZ destin THEN
					Code ($$push, $$abs, 0, 0, mAddr, s_type, @m$, "### 823")
					RETURN
				ELSE
					Code ($$ld, $$regabs, $$esi, 0, mAddr, s_type, @m$, @"### 824")
				END IF
			END IF
		END IF
	ELSE
		IF sfloat THEN
			Code ($$fld, $$ro, 0, mReg, mAddr, s_type, "", @"### 825")
		ELSE
			IFZ destin THEN
				Code ($$push, $$ro, 0, mReg, mAddr, s_type, "", "### 826")
				RETURN
			ELSE
				Code ($$ld, $$regro, $$esi, mReg, mAddr, s_type, "", @"### 827")
			END IF
		END IF
	END IF
'
	mReg	= m_reg[sdest]
	mAddr	= m_addr[sdest]
	SELECT CASE d_type
		CASE $$SINGLE		: dsize = 4
		CASE $$DOUBLE		: dsize = 8
	END SELECT
	IFZ mReg THEN
		m$	= m_addr$[sdest]
		IF dfloat THEN
			IFZ destin THEN
				Code ($$sub, $$regimm, $$esp, dsize, 0, $$XLONG, "", "### 828")
				Code ($$fstp, $$ro, 0, $$esp, 0, d_type, "", "### 829")
			ELSE
				Code ($$fstp, $$abs, 0, 0, mAddr, d_type, @m$, @"### 830")
			END IF
		ELSE
			IFZ destin THEN PRINT "MoveYikes0"
			Code ($$st, $$absreg, $$esi, 0, mAddr, d_type, @m$, @"### 831")
		END IF
	ELSE
		IF dfloat THEN
			IFZ destin THEN PRINT "MoveYikes1"
			Code ($$fstp, $$ro, 0, mReg, mAddr, d_type, "", @"### 832")
		ELSE
			IFZ destin THEN PRINT "MoveYikes2"
			Code ($$st, $$roreg, $$esi, mReg, mAddr, d_type, "", @"### 833")
		END IF
	END IF
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  NextToken ()  #####
' ##########################
'
FUNCTION  NextToken ()
	SHARED	m_addr$[]
	SHARED	funcToken[]
	SHARED	uType,  typeAlias[],  typeToken[],  typeSymbol$[]
	SHARED	tab_sym[],  tab_sym$[],  tokens[]
	SHARED	tokenCount,  tokenPtr
	STATIC GOADDR  kindDispatch[]
'
	IFZ kindDispatch[] THEN GOSUB LoadKindDispatch		' load dispatch table
'
skip_whities:
	INC tokenPtr
	IF (tokenPtr >= tokenCount) THEN RETURN ($$T_STARTS)
	token = tokens[tokenPtr] AND 0x1FFFFFFF
	tt		= token AND 0x0000FFFF
	GOTO @kindDispatch [token{$$KIND}]
	RETURN (token)
'
from_tab_sym:
	RETURN (tab_sym[tt])
'
' from_variables added 08/12/93 to support adding a user-defined type with
' the same name as existing variables.  The variables need to be mapped into
' the type token.
'
from_variables:
	token = tab_sym[tt]
	IF (token{$$KIND} != $$KIND_VARIABLES) THEN	' mapped to non-variable kind ?
		tt = token AND 0x0000FFFF
		GOTO @kindDispatch [token{$$KIND}]				' dispatch by mapped kind
	END IF
	IFZ m_addr$[tt] THEN												' if no address
		symbol$ = tab_sym$[tt]										'
		FOR i = $$DCOMPLEX+1 TO uType							'
			IF (symbol$ = typeSymbol$[i]) THEN			' supports adding a type
				token = typeToken[i]									' after a variable of the
				tab_sym[tt] = token										'	same name exists... and
			END IF																	' to a type token (hopefully)
		NEXT i																		'
	END IF
	IF (token{$$KIND} != $$KIND_VARIABLES) THEN	' mapped to non-variable kind ?
		tt = token AND 0x0000FFFF
		GOTO @kindDispatch [token{$$KIND}]				' dispatch by mapped kind
	END IF
	RETURN (token)
'
from_func_sym:
	RETURN (funcToken[tt])
'
them_comments:
	tokenPtr = tokenCount
	RETURN ($$T_STARTS)
'
from_types:
	ttt		= typeAlias[tt]{$$NUMBER}
	IF ttt THEN tt = ttt
	RETURN (typeToken[tt])
'
'
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
'
'
' ###################
' #####  Op ()  #####
' ###################
'
FUNCTION  Op (d_reg, s_reg, the_op, rax, rt, st, ot, xt)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
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
'
	IFZ opToken[] THEN GOSUB LoadOpToken
'
' *****  Destination register
'
	SELECT CASE d_reg
		CASE $$RA0:	a0_type = rt
		CASE $$RA1:	a1_type = rt
	END SELECT
	d_regx = d_reg + 1
'
' *****  Source register 1
'
	ras = s_reg
	SELECT CASE s_reg
		CASE $$RA0, $$RA1
		CASE ELSE:	IF (the_op != T_CMP) THEN PRINT "op2": GOTO eeeCompiler
	END SELECT
	s_regx = s_reg + 1
'
' *****  Source register 2 or immediate value
'
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
											CASE $$SINGLE, $$DOUBLE
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
'
						ctoken0		= ctoken0 OR ($$AUTOX << 21)
						ctoken1		= ctoken1 OR ($$AUTOX << 21)
						tab_sym[cnumber0] = ctoken0
						tab_sym[cnumber1] = ctoken1

						IFZ m_addr$[cnumber1] THEN
							AssignAddress (ctoken1)
							AssignAddress (ctoken0)
							IF XERROR THEN EXIT FUNCTION
						END IF
						cr0	= m_reg[cnumber0]
						cn0 = m_addr[cnumber0]
						Code ($$mov, $$regreg, $$edi, x_reg, 0, $$XLONG, "", @"### 834")
						Code ($$mov, $$regreg, $$esi, s_reg, 0, $$XLONG, "", @"### 835")
						Code ($$lea, $$regro, $$eax, cr0, cn0, $$XLONG, "", @"### 836")
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
		END IF
	END IF
	orderCounts = $$FALSE
'
'
' *****  Execute routine appropriate to binary operator token  *****
'
	GOTO @opToken[the_op AND 0x00FF]
	PRINT "opdispatch"
	GOTO eeeCompiler
'
' *****************************************************************************
' *****  Destinations of preceeding computed dispatch on operator tokens  *****
' *****************************************************************************
'
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
'
'
' ****************************************  Compares operands, leaves compare
' *****  Relational Operator Prolog  *****  flag bits in "d.reg".  The operator
' ****************************************	routines extract appropriate bits.
'
SUB rop
	op = $$cmp
	SELECT CASE TRUE
		CASE (ot < $$GIANT):		GOSUB CompareLong
		CASE (ot = $$GIANT):		GOSUB CompareGiant
		CASE (ot = $$SINGLE):		GOSUB CompareFloat
		CASE (ot = $$DOUBLE):		GOSUB CompareFloat
		CASE (ot = $$STRING):		GOSUB CompareString
		CASE (ot = $$SCOMPLEX):	GOSUB CompareSCOMPLEX
		CASE (ot = $$DCOMPLEX):	GOSUB CompareDCOMPLEX
		CASE ELSE:							GOTO  eeeTypeMismatch
	END SELECT
END SUB
'
SUB CompareLong
	Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 837")
END SUB
'
'
' Note GIANT routines completed in specific condition tests
'
SUB CompareGiant
	Code ($$cmp, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 838")
END SUB
'
SUB CompareFloat
	Code ($$fcompp, 0, 0, 0, 0, $$DOUBLE, "", @"### 839")
	IF a0 THEN Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", @"### 840")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 841")
	Code ($$sahf, 0, 0, 0, 0, $$XLONG, "", @"### 842")
	IF a0 THEN Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, "", @"### 843")
END SUB
'
SUB CompareString
	IFZ revOp THEN
		ooos$	= CHR$(oos[oos-1]) + CHR$(oos[oos])
		IF ((ras != $$RA0) OR (rax != $$RA1)) THEN GOTO eeeCompiler
	ELSE
		ooos$	= CHR$(oos[oos]) + CHR$(oos[oos-1])
		IF ((ras != $$RA1) OR (rax != $$RA0)) THEN GOTO eeeCompiler
	END IF
	d1$ = "__string.compare." + ooos$
	Code ($$call, $$rel, 0, 0, 0, 0, @d1$, @"### 844")
	oos = oos - 2
END SUB
'
SUB CompareSCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, "__compare.SCOMPLEX", @"### 845")
END SUB
'
SUB CompareDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, $$XLONG,"__compare.DCOMPLEX", @"### 846")
END SUB
'
'
' *********************
' *****  COMPARE  *****
' *********************
'
test_EQ:
	IF (ot = $$GIANT) THEN
		INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
		Code ($$jne, $$rel, 0, 0, 0, 0, d1$, @"### 847")
		Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 848")
		EmitLabel (@d1$)
		the_op = $$o2
	ELSE
		the_op = $$o2
	END IF
	RETURN
'
test_NE:
	IF (ot = $$GIANT) THEN
		INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
		Code ($$jne, $$rel, 0, 0, 0, 0, d1$, @"### 849")
		Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 850")
		EmitLabel (@d1$)
		the_op = $$o3
	ELSE
		the_op = $$o3
	END IF
	RETURN
'
test_LT:
	SELECT CASE ot
		CASE $$GIANT:
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d3$ = "_" + HEX$(labelNumber, 4)
					IF revOp THEN
						op1 = $$jg	: op2 = $$jbe
					ELSE
						op1 = $$jl	: op2 = $$jae
					END IF
					Code ($$je, $$rel, 0, 0, 0, 0, d1$, @"### 851")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 852")
					Code (op1, $$rel, 0, 0, 0, 0, d2$, @"### 853")
					Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 854")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 855")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 856")
					Code (op2, $$rel, 0, 0, 0, 0, d3$, @"### 857")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 858")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o8 ELSE the_op = $$o10
		CASE $$SINGLE, $$DOUBLE
					IF revOp THEN the_op = $$o10 ELSE the_op = $$o8
		CASE ELSE
					IF revOp THEN the_op = $$o4 ELSE the_op = $$o6
	END SELECT
	RETURN
'
test_LE:
	SELECT CASE ot
		CASE $$GIANT:
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d3$ = "_" + HEX$(labelNumber, 4)
					IF revOp THEN
						op1 = $$jge	: op2 = $$jb
					ELSE
						op1 = $$jle	: op2 = $$ja
					END IF
					Code ($$je, $$rel, 0, 0, 0, 0, d1$, @"### 859")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 860")
					Code (op1, $$rel, 0, 0, 0, 0, d2$, @"### 861")
					Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 862")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 863")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 864")
					Code (op2, $$rel, 0, 0, 0, 0, d3$, @"### 865")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 866")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o11 ELSE the_op = $$o9
		CASE $$SINGLE, $$DOUBLE
					IF revOp THEN the_op = $$o9 ELSE the_op = $$o11
		CASE ELSE
					IF revOp THEN the_op = $$o7 ELSE the_op = $$o5
	END SELECT
	RETURN
'
test_GE:
	SELECT CASE ot
		CASE $$GIANT:
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d3$ = "_" + HEX$(labelNumber, 4)
					IF revOp THEN
						op1 = $$jle	: op2 = $$ja
					ELSE
						op1 = $$jge	: op2 = $$jb
					END IF
					Code ($$je, $$rel, 0, 0, 0, 0, d1$, @"### 867")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 868")
					Code (op1, $$rel, 0, 0, 0, 0, d2$, @"### 869")
					Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 870")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 871")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 872")
					Code (op2, $$rel, 0, 0, 0, 0, d3$, @"### 873")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 874")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o9 ELSE the_op = $$o11
		CASE $$SINGLE, $$DOUBLE
					IF revOp THEN the_op = $$o11 ELSE the_op = $$o9
		CASE ELSE
					IF revOp THEN the_op = $$o5 ELSE the_op = $$o7
	END SELECT
	RETURN
'
test_GT:
	SELECT CASE ot
		CASE $$GIANT:
					INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
					INC labelNumber : d3$ = "_" + HEX$(labelNumber, 4)
					IF revOp THEN
						op1 = $$jl	: op2 = $$jae
					ELSE
						op1 = $$jg	: op2 = $$jbe
					END IF
					Code ($$je, $$rel, 0, 0, 0, 0, d1$, @"### 875")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 876")
					Code (op1, $$rel, 0, 0, 0, 0, d2$, @"### 877")
					Code ($$jmp, $$rel, 0, 0, 0, 0, d3$, @"### 878")
					EmitLabel (@d1$)
					Code ($$cmp, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 879")
					Code ($$mov, $$regimm, d_reg, 0, 0, $$XLONG, "", "### 880")
					Code (op2, $$rel, 0, 0, 0, 0, d3$, @"### 881")
					EmitLabel (@d2$)
					Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 882")
					EmitLabel (@d3$)
					the_op = 0
		CASE $$ULONG, $$STRING
					IF revOp THEN the_op = $$o10 ELSE the_op = $$o8
		CASE $$SINGLE, $$DOUBLE
					IF revOp THEN the_op = $$o8 ELSE the_op = $$o10
		CASE ELSE
					IF revOp THEN the_op = $$o6 ELSE the_op = $$o4
	END SELECT
	RETURN
'
'
' ************************
' *****  logical OR  *****
' ************************
'
logical_or:
	SELECT CASE ot
		CASE $$GIANT:	GOSUB Logical_OR_GIANT
		CASE ELSE:		GOSUB Logical_OR_LONG
	END SELECT
	the_op = 0
	RETURN
'
SUB Logical_OR_GIANT
	Code ($$or, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 883")
	Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 884")
	Code ($$or, mode, s_reg, x_regx, 0, $$XLONG, "", @"### 885")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, "", @"### 886")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, "", @"### 887")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, "", @"### 888")
END SUB
'
SUB Logical_OR_LONG
	Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 889")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, "", @"### 890")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, "", @"### 891")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, "", @"### 892")
END SUB
'
'
' *************************
' *****  logical XOR  *****
' *************************
'
logical_xor:
	SELECT CASE ot
		CASE $$GIANT:	GOSUB Logical_XOR_GIANT
		CASE ELSE:		GOSUB Logical_XOR_LONG
	END SELECT
	the_op = 0
	RETURN
'
SUB Logical_XOR_GIANT
	Code ($$or, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 893")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, "", @"### 894")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, "", @"### 895")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, "", @"### 896")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, "", @"### 897")
	Code ($$or, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 898")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, "", @"### 899")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, "", @"### 900")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, "", @"### 901")
	Code ($$xor, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 902")
END SUB
'
SUB Logical_XOR_LONG
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, "", @"### 903")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, "", @"### 904")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, "", @"### 905")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, "", @"### 906")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, "", @"### 907")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, "", @"### 908")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, "", @"### 909")
	Code ($$xor, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 910")
END SUB
'
'
' *************************
' *****  logical AND  *****
' *************************
'
logical_and:
	SELECT CASE ot
		CASE $$GIANT:	GOSUB Logical_AND_GIANT
		CASE ELSE:		GOSUB Logical_AND_LONG
	END SELECT
	the_op = 0
	RETURN
'
SUB Logical_AND_GIANT
	Code ($$or, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 911")
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, "", @"### 912")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, "", @"### 913")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, "", @"### 914")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, "", @"### 915")
	Code ($$or, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 916")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, "", @"### 917")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, "", @"### 918")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, "", @"### 919")
	Code ($$and, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 920")
END SUB
'
SUB Logical_AND_LONG
	Code ($$neg, $$reg, s_reg, 0, 0, $$XLONG, "", @"### 921")
	Code ($$rcr, $$regimm, s_reg, 1, 0, $$XLONG, "", @"### 922")
	Code ($$sar, $$regimm, s_reg, 31, 0, $$XLONG, "", @"### 923")
	Code ($$mov, mode, s_regx, x_reg, 0, $$XLONG, "", @"### 924")
	Code ($$neg, $$reg, s_regx, 0, 0, $$XLONG, "", @"### 925")
	Code ($$rcr, $$regimm, s_regx, 1, 0, $$XLONG, "", @"### 926")
	Code ($$sar, $$regimm, s_regx, 31, 0, $$XLONG, "", @"### 927")
	Code ($$and, $$regreg, s_reg, s_regx, 0, $$XLONG, "", @"### 928")
END SUB
'
'
' ************************
' *****  bitwise OR  *****
' ************************
'
bitwise_or:
	SELECT CASE ot
		CASE $$GIANT
					Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 929")
					Code ($$or, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 930")
		CASE ELSE
					Code ($$or, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 931")
	END SELECT
	the_op = 0
	RETURN
'
'
' *************************
' *****  bitwise XOR  *****
' *************************
'
bitwise_xor:
	SELECT CASE ot
		CASE $$GIANT
					Code ($$xor, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 932")
					Code ($$xor, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 933")
		CASE ELSE
					Code ($$xor, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 934")
	END SELECT
	the_op = 0
	RETURN
'
'
' *************************
' *****  bitwise AND  *****
' *************************
'
bitwise_and:
	SELECT CASE ot
		CASE $$GIANT
					Code ($$and, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 935")
					Code ($$and, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 936")
		CASE ELSE
					Code ($$and, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 937")
	END SELECT
	the_op = 0
	RETURN
'
'
' **********************
' *****  ADDITION  *****
' **********************
'
add:
	op = $$add
	SELECT CASE ot
		CASE $$SLONG:			GOSUB AddSLONG
		CASE $$ULONG:			GOSUB AddULONG
		CASE $$XLONG:			GOSUB AddXLONG
		CASE $$GIANT:			GOSUB AddGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$STRING:		GOSUB Concatenate
		CASE $$SCOMPLEX:	GOSUB AddSCOMPLEX
		CASE $$DCOMPLEX:	GOSUB AddDCOMPLEX
		CASE ELSE:				GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN
'
SUB AddSLONG
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 938")
	Code ($$into, 0, 0, 0, 0, 0, "", @"### 939")
END SUB
'
SUB AddULONG
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 940")
	Code ($$jnc, $$rel, 0, 0, 0, 0, d1$, @"### 941")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 942")
	EmitLabel (@d1$)
END SUB
'
SUB AddXLONG
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 943")
END SUB
'
SUB AddGIANT
	Code ($$add, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 944")
	Code ($$adc, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 945")
	Code ($$into, 0, 0, 0, 0, 0, "", @"### 946")
END SUB
'
SUB AddSCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, "__add.SCOMPLEX", @"### 947")
END SUB
'
SUB AddDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, "__add.DCOMPLEX", @"### 948")
END SUB
'
SUB Concatenate
	IF (ot != $$STRING) THEN GOTO eeeTypeMismatch
	ooos$		= CHR$(oos[oos-1]) + CHR$(oos[oos])
	IF revOp THEN
		dx$	= "__concat.ubyte.a0.eq.a1.plus.a0." + ooos$
	ELSE
		dx$	= "__concat.ubyte.a0.eq.a0.plus.a1." + ooos$
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, dx$, @"### 949")
	DEC oos
	oos[oos] = 's'
	the_op = 0
END SUB
'
'
' *************************
' *****  SUBTRACTION  *****
' *************************
'
subtract:
	op = $$sub
	SELECT CASE ot
		CASE $$SLONG:			GOSUB SubtractSLONG
		CASE $$ULONG:			GOSUB SubtractULONG
		CASE $$XLONG:			GOSUB SubtractXLONG
		CASE $$GIANT:			GOSUB SubtractGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$SCOMPLEX:	GOSUB SubtractSCOMPLEX
		CASE $$DCOMPLEX:	GOSUB SubtractDCOMPLEX
		CASE ELSE:				GOTO  eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN
'
SUB SubtractSLONG
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 950")
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 951")
	Code ($$into, 0, 0, 0, 0, 0, d1$, @"### 952")
END SUB
'
SUB SubtractULONG
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 953")
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 954")
	Code ($$jnc, $$rel, 0, 0, 0, 0, d1$, @"### 955")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 956")
	EmitLabel (@d1$)
END SUB
'
SUB SubtractXLONG
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 957")
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 958")
END SUB
'
SUB SubtractGIANT
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 959")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 960")
	END IF
	Code ($$sub, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 961")
	Code ($$sbb, mode, s_regx, x_regx, 0, $$XLONG, "", @"### 962")
	Code ($$into, 0, 0, 0, 0, 0, "", @"### 963")
END SUB
'
SUB SubtractSCOMPLEX
'	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 964")
	Code ($$call, $$rel, 0, 0, 0, 0, "__sub.SCOMPLEX", @"### 965")
END SUB
'
SUB SubtractDCOMPLEX
'	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 966")
	Code ($$call, $$rel, 0, 0, 0, 0, "__sub.DCOMPLEX", @"### 967")
END SUB
'
'
' ****************************
' *****  MULTIPLICATION  *****
' ****************************
'
multiply:
	op = $$mul
	SELECT CASE ot
		CASE $$SLONG:			GOSUB MultiplySLONG
		CASE $$ULONG:			GOSUB MultiplyULONG
		CASE $$XLONG:			GOSUB MultiplyXLONG
		CASE $$GIANT:			GOSUB MultiplyGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$SCOMPLEX:	GOSUB MultiplySCOMPLEX
		CASE $$DCOMPLEX:	GOSUB MultiplyDCOMPLEX
		CASE ELSE:				GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN
'
SUB MultiplySLONG
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$imul, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 968")
	Code ($$jnc, $$rel, 0, 0, 0, 0, d1$, @"### 969")
	Code ($$call, $$rel, 0, 0, 0, 0, "__eeeOverflow", @"### 970")
	EmitLabel (@d1$)
END SUB
'
SUB MultiplyULONG
	Code ($$imul, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 971")
END SUB
'
SUB MultiplyXLONG
	Code ($$imul, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 972")
END SUB
'
SUB MultiplyGIANT
	Code ($$call, $$rel, 0, 0, 0, 0, "__mul.GIANT", @"### 973")
END SUB
'
SUB MultiplySCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, "__mul.SCOMPLEX", @"### 974")
END SUB
'
SUB MultiplyDCOMPLEX
	Code ($$call, $$rel, 0, 0, 0, 0, "__mul.DCOMPLEX", @"### 975")
END SUB
'
'
' *********************************************
' *****  DIVISION  *****  FLOATING POINT  *****
' *********************************************
'
divide:
	op = $$div
	SELECT CASE ot
		CASE $$SLONG:			GOSUB DivideSLONG
		CASE $$ULONG:			GOSUB DivideULONG
		CASE $$XLONG:			GOSUB DivideSLONG
		CASE $$GIANT:			GOSUB DivideGIANT
		CASE $$SINGLE:		GOSUB type_stuff
		CASE $$DOUBLE:		GOSUB type_stuff
		CASE $$SCOMPLEX:	GOSUB DivideSCOMPLEX
		CASE $$DCOMPLEX:	GOSUB DivideDCOMPLEX
		CASE ELSE:  			GOTO eeeTypeMismatch
	END SELECT
	the_op = 0
	RETURN
'
SUB DivideSLONG
	wierdOp = $$idiv
	GOSUB WierdOp
END SUB
'
SUB DivideULONG
	wierdOp = $$div
	GOSUB WierdOp
END SUB
'
SUB DivideGIANT
	IF (s_reg == $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 976")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 977")
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, "__div.GIANT", @"### 978")
	IF (s_reg == $$RA1) THEN
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 979")
		Code ($$mov, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 980")
	END IF
END SUB
'
SUB DivideSCOMPLEX
'	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 981")
	Code ($$call, $$rel, 0, 0, 0, 0, "__div.SCOMPLEX", @"### 982")
END SUB
'
SUB DivideDCOMPLEX
'	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 983")
	Code ($$call, $$rel, 0, 0, 0, 0, "__div.DCOMPLEX", @"### 984")
END SUB
'
'
' ****************************
' *****  INTEGER DIVIDE  *****
' ****************************
'
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
'
SUB IntegerDivideSLONG
	wierdOp	= $$idiv
	GOSUB WierdOp
END SUB
'
SUB IntegerDivideULONG
	wierdOp = $$div
	GOSUB WierdOp
END SUB
'
SUB IntegerDivideGIANT
	IF (s_reg == $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 985")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 986")
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, "__div.GIANT", @"### 987")
	IF (s_reg == $$RA1) THEN
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 988")
		Code ($$mov, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 989")
	END IF
END SUB
'
'
'
' *****************************
' *****  INTEGER MODULUS  *****  result = x - (x\y * y)
' *****************************
'
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
'
SUB IntegerModulusSLONG
	wierdOp = $$idiv
	GOSUB WierdOp
	Code ($$mov, $$regreg, s_reg, $$edx, 0, $$XLONG, "", @"### 990")
END SUB
'
SUB IntegerModulusULONG
	wierdOp = $$div
	GOSUB WierdOp
	Code ($$mov, $$regreg, s_reg, $$edx, 0, $$XLONG, "", @"### 991")
END SUB
'
SUB IntegerModulusGIANT
	IF (s_reg == $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 992")
		Code ($$xchg, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 993")
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, "__mod.GIANT", @"### 994")
	IF (s_reg == $$RA1) THEN
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 995")
		Code ($$mov, $$regreg, s_regx, x_regx, 0, $$XLONG, "", @"### 996")
	END IF
END SUB
'
'
'
SUB WierdOp
	SELECT CASE mode
		CASE $$regreg:	mode = $$reg
		CASE $$regimm:	Code ($$mov, $$regimm, $$esi, x_reg, 0, $$XLONG, "", "### 997")
										mode = $$reg
										x_reg = $$esi
		CASE ELSE:			PRINT "wierdOp": GOTO eeeCompiler
	END SELECT
	IF revOp THEN Code ($$xchg, $$regreg, s_reg, x_reg, 0, $$XLONG, "", @"### 998")
	IF (s_reg != $$eax) THEN
		Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 999")
		Code ($$mov, $$regreg, $$eax, s_reg, 0, $$XLONG, "", "### 1000")
		SELECT CASE wierdOp
			CASE	$$idiv:	Code ($$cdq, $$none, 0, 0, 0, $$XLONG, "", "### 1001")
			CASE	$$div:	Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, "", "### 1002")
		END SELECT
		Code (wierdOp, $$reg, x_reg, 0, 0, $$XLONG, "", "### 1003")
		Code ($$mov, $$regreg, s_reg, $$eax, 0, $$XLONG, "", "### 1004")
		Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, "", "### 1005")
	ELSE
		SELECT CASE wierdOp
			CASE	$$idiv:	Code ($$cdq, $$none, 0, 0, 0, $$XLONG, "", "### 1006")
			CASE	$$div:	Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, "", "### 1007")
		END SELECT
		Code (wierdOp, $$reg, x_reg, 0, 0, $$XLONG, "", "### 1008")
	END IF
END SUB
'
' ****************************
' *****  RAISE TO POWER  *****  (x ** y) = raise "x" to the power "y"
' ****************************
'
power:
	IF (s_reg = $$RA1) AND ((ot != $$SINGLE) AND (ot != $$DOUBLE)) THEN revOp = NOT revOp
	IF revOp THEN
		dx$ = "__rpower." + typeName$[ot]
	ELSE
		dx$ = "__power." + typeName$[ot]
	END IF
	SELECT CASE ot
		CASE $$SLONG, $$ULONG, $$XLONG
			IF (mode == $$regimm) THEN
				IF revOp THEN
					Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 1009a")
					Code ($$mov, $$regimm, $$eax, x_reg, 0, $$XLONG, "", "### 1009b")
				ELSE
					Code ($$mov, $$regimm, $$ebx, x_reg, 0, $$XLONG, "", "### 1009c")
				END IF
			END IF
		CASE $$GIANT, $$SINGLE, $$DOUBLE
		CASE  ELSE:		PRINT "op12a": GOTO eeeCompiler
	END SELECT
	Code ($$call, $$rel, 0, 0, 0, 0, dx$, @"### 1009d")
	IF (s_reg = $$RA1) THEN
		SELECT CASE ot
			CASE $$SINGLE, $$DOUBLE		' hopefully no problem - in coprocessor
			CASE $$GIANT							: Code ($$mov, $$regreg, $$ebx, $$eax, 0, $$XLONG, "", "### 1010")
																: Code ($$mov, $$regreg, $$ecx, $$edx, 0, $$XLONG, "", "### 1011")
			CASE ELSE									: Code ($$mov, $$regreg, $$ebx, $$eax, 0, $$XLONG, "", "### 1012")
		END SELECT
	END IF
	IF mode = $$regimm THEN
		IF revOp THEN
			Code ($$pop, $$reg, $$eax, 0, 0, $$XLONG, "", "")
		END IF
	END IF
	the_op = 0
	RETURN
'
'
' *********************************
' *****  BITWISE SHIFT RIGHT  *****  RIGHT SHIFT  *****  carry in zeros
' *********************************
'
right_shift:
	IF (ot = $$GIANT) THEN routine$ = "__rshift.giant": GOTO gshift
	shop = $$slr
	GOTO xshift
'
'
' ********************************
' *****  BITWISE SHIFT LEFT  *****  LEFT SHIFT  *****  carry in zeros
' ********************************
'
left_shift:
	IF (ot = $$GIANT) THEN routine$ = "__lshift.giant": GOTO gshift
	shop = $$sll
	GOTO xshift
'
'
' *********************************
' *****  ARITHMETIC SHIFT UP  *****  UP SHIFT  *****  carry in zeros
' *********************************
'
up_shift:
	IF (ot = $$GIANT) THEN routine$ = "__ushift.giant": GOTO gshift
	shop = $$sal
	GOTO xshift
'
'
' ***********************************
' *****  ARITHMETIC SHIFT DOWN  *****  DOWN SHIFT  *****  sign extend msb
' ***********************************
'
down_shift:
	IF (ot = $$GIANT) THEN routine$ = "__dshift.giant": GOTO gshift
	shop = $$sar
	GOTO xshift
'
'
'
xshift:
	IF revOp THEN
		IF (mode = $$regimm) THEN PRINT "revOp": GOTO eeeCompiler
		Code ($$mov, $$regreg, $$ecx, s_reg, 0, $$XLONG, "", "### 1013")
		Code ($$mov, $$regreg, s_reg, x_reg, 0, $$XLONG, "", "### 1014")
		x_reg = $$cl
	END IF
	SELECT CASE mode
		CASE $$regimm
					Code (shop, mode, s_reg, x_reg, 0, $$XLONG, "", @"### 1015")
		CASE $$regreg
					IF ((x_reg != $$ecx) AND (x_reg != $$cl)) THEN
						Code ($$mov, $$regreg, $$ecx, x_reg, 0, $$XLONG, "", "### 1016")
					END IF
					Code (shop, $$regreg, s_reg, $$cl, 0, $$XLONG, "", "### 1017")
		CASE ELSE
					GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN
'
'
' *************************************************************
' *****  GIANT upshift, downshift, leftshift, rightshift  *****
' *************************************************************
'
gshift:
	IF (s_reg = $$RA1) THEN revOp = NOT revOp
	IF revOp THEN
		Code ($$mov, $$regreg, $$edx, $$ecx, 0, $$XLONG, "", "### 1018")
		Code ($$mov, $$regreg, $$ecx, $$eax, 0, $$XLONG, "", "### 1019")
		Code ($$mov, $$regreg, $$eax, $$ebx, 0, $$XLONG, "", "### 1020")
	ELSE
		Code ($$mov, mode, $$ecx, x_reg, 0, $$XLONG, "", "### 1021")
	END IF
	Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 1022")
	IF (s_reg = $$RA1) THEN
		Code ($$mov, $$regreg, $$ebx, $$eax, 0, $$XLONG, "", "### 1023")
		Code ($$mov, $$regreg, $$ecx, $$edx, 0, $$XLONG, "", "### 1024")
	END IF
	the_op = 0
	RETURN
'
'
' Set up types of floating point result and two floating point operands
'
SUB type_stuff
	SELECT CASE op
		CASE $$add:	op486 = $$fadd
		CASE $$sub:	op486 = $$fsub:	IF revOp THEN op486 = $$fsubr
		CASE $$mul:	op486 = $$fmul
		CASE $$div: op486 = $$fdiv:	IF revOp THEN op486 = $$fdivr
		CASE ELSE:	PRINT "??? No such floating point operator ???"
	END SELECT
	Code (op486, 0, 0, 0, 0, $$DOUBLE, "", @"### 1025")
END SUB
'
'
'
'
' ****************************************************************
' *****  Load opToken[] with addresses of operator routines  *****
' ****************************************************************
'
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
'
'
' ************************************
' *****  BINARY OPERATOR ERRORS  *****
' ************************************
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeOverflow:
	XERROR = ERROR_OVERFLOW
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ###############################
' #####  OpenAccForType ()  #####
' ###############################
'
FUNCTION  OpenAccForType (theType)
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  a0,  a0_type,  a1,  a1_type
'
	IFZ a0 THEN GOTO open0
	IFZ a1 THEN GOTO open1
	IF (a0 < a1) THEN Push ($$RA0, a0_type): GOTO open0
	IF (a0 > a1) THEN Push ($$RA1, a1_type): GOTO open1
	GOTO eeeCompiler
'
open0:	INC toes: a0 = toes: a0_type = theType: RETURN ($$RA0)
open1:	INC toes: a1 = toes: a1_type = theType: RETURN ($$RA1)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #############################
' #####  OpenBothAccs ()  #####
' #############################
'
FUNCTION  OpenBothAccs ()
	SHARED	a0,  a0_type,  a1,  a1_type,  toes
'
	IFZ toes THEN RETURN						' nothing on stack
	IFZ (a0 OR a1) THEN RETURN			' nothing in stack registers
	IF a0 AND (a0 < a1) THEN
		Push($$RA0, a0_type)
		a0 = 0: a0_type = 0
	END IF
	IF a1 THEN
		Push($$RA1, a1_type)
		a1 = 0: a1_type = 0
	END IF
	IF a0 THEN
		Push($$RA0, a0_type)
		a0 = 0: a0_type = 0
	END IF
	RETURN
END FUNCTION
'
'
' ###########################
' #####  OpenOneAcc ()  #####
' ###########################
'
FUNCTION  OpenOneAcc ()
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	a0,  a0_type,  a1,  a1_type
'
	IFZ a0 THEN RETURN ($$RA0)
	IFZ a1 THEN RETURN ($$RA1)
	IF (a0 < a1) THEN
		Push($$RA0, a0_type)
		RETURN ($$RA0)
	END IF
	IF (a0 > a1) THEN
		Push($$RA1, a1_type)
		RETURN ($$RA1)
	END IF
	PRINT "open1"
	GOTO eeeCompiler
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  ParseChar ()  #####
' ##########################
'
FUNCTION  ParseChar ()
	SHARED	tab_sym[],  tokens[],  charToken[]
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
'
	IFZ parseChar[] THEN GOSUB LoadParseChar
	charV = rawline${charPtr}
	INC charPtr
	GOTO @parseChar [charV]					' GOTO routine to parse this character
	PRINT "ParseChar"								' there is no routine for invalid characters
	GOTO eeeCompiler								' so log an error message
'
'
'
pc_token:
	token = charToken[charV]				' get token for this character
	ParseOutToken (token)						' output token to token list
	RETURN (token)									' return token
'
'
' *************************************************************************
' *****  Parse characters that may be part of 1+ character sequences  *****
' *************************************************************************
'
'
' *****  !  *****  !   !!   !=   !<   !<=   !>=   !>
'
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
									END IF
								END IF
		CASE '>':		INC charPtr
								charV = rawline${charPtr}
								IF (charV = '=') THEN
									token = T_NGE
									INC charPtr
								ELSE
									token = T_NGT
								END IF
		CASE ELSE:  token = T_NOTL
	END SELECT
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  "  *****  Literal string  *****
'
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
			END IF
			INC scans
			rawChar = rawline${scans}
		LOOP WHILE (scans < final)
	END IF
	IF (scans < final) THEN
		INC scans
		charPtr = scans		' terminated by "  (normal case)
	ELSE
		charPtr	= scans		' terminated by null, not "
		INC scans
	END IF
	lit$ = MID$(rawline$, start, (scans-start)) + "\""
'
'  The literal string is in lit$
'
	token = $$T_LITERALS + ($$EXTERNAL << 21) + ($$STRING << 16)
	IF (lit$ = nullstring$) THEN
		token = tab_sym[nullstringer]
	ELSE
		token = AddSymbol (@lit$, token, func_number)
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  &  *****  & = addr.op:  && = and.op:  && = handle.op
'
amper:
	charV = rawline${charPtr}
	IF (charV = '&') THEN
		INC charPtr
		charV = rawline${charPtr}
		token = T_ANDL								' && = logical AND or handle operator
	ELSE
		token = T_ANDBIT							' &  = bitwise AND or address operator
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  '  *****
'
remark:
	IFZ tokenPtr THEN GOTO sendRemark							' first token ' is a remark
	charV = rawline${charPtr}											' 1st byte of comment / charcon
	IFZ charV THEN																' nothing after ' character, so
		token = T_REM																'     ...it's an empty comment
		ParseOutToken (token)												' Add comment to token list
		RETURN (token)															' that's all folks
	ELSE																					' comment or charcon follows '
		IF charV THEN charW = rawline${charPtr+1}		' 2nd byte of comment or charcon
		IF charW THEN charX = rawline${charPtr+2}		' 3rd byte of comment or charcon
		IF charX THEN charY = rawline${charPtr+3}		' 4th byte of comment or charcon
		SELECT CASE TRUE
			CASE (charW = '''):	 c = 3												'   '?'   charcon
			CASE ((charV = '\\') AND (charX = ''')):	c = 4		'   '\?'  charcon
			CASE ELSE:	GOTO sendRemark												' comment, not charcon
		END SELECT
	END IF
'
' It's a charcon  ( '?'  ...or...  '\?' )
'
	clit$ = MID$(rawline$, charPtr, c)
	token = $$T_CHARCONS + ($$SHARED << 21) + ($$UBYTE << 16)
	token = AddSymbol (@clit$, token, func_number)
	charPtr = charPtr + c - 1
	ParseOutToken (token)
	RETURN (token)
'
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
	END IF
	TokenRestOfLine ()													' Tokenize rest of comment
	RETURN (token)
'
'
' #####  *  #####  *   **
'
star:
	charV = rawline${charPtr}
	IF (charV = '*') THEN
		token = T_POWER
		INC charPtr
	ELSE
		token = T_MUL
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  .  *****   "..."  or  ".2345e3" (a number)  or  ".COMPONENTNAME"
'
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
		END IF
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
	END IF
'
'
' *****  <  *****   <   <>   <=   <<   <<<
'
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
								END IF
		CASE ELSE:	token = T_LT												' <
	END SELECT
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  =  *****  =   ==
'
equals:
	charV = rawline${charPtr}
	IF (charV = '=') THEN
		token = T_EQL
		INC charPtr
	ELSE
		token = T_EQ
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  >  *****  ><   >=   >>   >>>
'
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
								END IF
		CASE ELSE:	token = T_GT														' >
	END SELECT
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  ?  *****   "???"  or  just a simple "?" character
'
question:
	ParseOutToken (T_QMARK)
	RETURN (T_QMARK)
'
'
' *****  ^  *****   ^   ^^
'
upper:
	charV = rawline${charPtr}
	IF (charV = '^') THEN
		token = T_XORL
		INC charPtr
	ELSE
		token = T_XORBIT
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  {  *****  {   {{
'
lbrace:
	charV = rawline${charPtr}
	IF (charV = '{') THEN
		token = T_LBRACES
		INC charPtr
	ELSE
		token = T_LBRACE
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
' *****  |  *****  |   ||
'
vbar:
	charV = rawline${charPtr}
	IF (charV = '|') THEN
		token = T_ORL
		INC charPtr
	ELSE
		token = T_ORBIT
	END IF
	ParseOutToken (token)
	RETURN (token)
'
'
'
' *****************************************************************************
' *****  Load parseChar[] with addresses of routines to parse characters  *****
' *****************************************************************************
'
SUB LoadParseChar
	DIM parseChar[255]
'																								'    00-32 handled elsewhere
	parseChar [  33 ] = GOADDRESS (l_not_test)		'  !  !!  !=  !<  !<=  !>=  !>
	parseChar [  34 ] = GOADDRESS (double_quote)	'  "
	parseChar [  35 ] = GOADDRESS (pc_token)			'  #  T_POUND
	parseChar [  36 ] = GOADDRESS (pc_token)			'  $  T_DOLLAR
	parseChar [  37 ] = GOADDRESS (pc_token)			'  %  T_PERCENT
	parseChar [  38 ] = GOADDRESS (amper)					'  &  &&
	parseChar [  39 ] = GOADDRESS (remark)				'  '
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
	parseChar [  63 ] = GOADDRESS (pc_token)			'  ?  T_QMARK
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
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  ParseLine ()  #####
' ##########################
'
FUNCTION  ParseLine (tok[])
	SHARED	charpos[],  tokens[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	T_IMPORT,  T_FUNCTION,  T_SFUNCTION,  T_CFUNCTION
	SHARED	function_line,  backToken,  lastToken,  tokenCount,  tokenPtr
	SHARED	declareAlloTypeLine,  declareFuncaddrLine
	SHARED	charPtr,  rawLength,  rawline$
	SHARED UBYTE	charsetNumeric[]
	STATIC FUNCADDR XLONG parseFirstChar[]()
'
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
'
	IFZ rawLength THEN												' empty source line
		charpos[tokenPtr] = 1
		tokens[tokenPtr] = $$T_STARTS
		GOTO doneLine
	END IF
'
	charV = rawline${charPtr}
	IF charsetNumeric[charV] THEN							' errorIndex on this line
		errorIndex = XLONG(LEFT$(rawline$, 3))
		IF (rawLength <= 3) THEN GOTO doneLine
		charPtr = 3
	ELSE
		errorIndex = 0
	END IF
'
	IF (charV = '>') THEN											' current executable line
		markLine = $$CURRENTEXE
		INC charPtr
		charV = rawline${charPtr}
	END IF
'
	IF (charV = ':') THEN											' breakpoint set on this line
		markLine = markLine OR $$BREAKPOINT
		INC charPtr
		charV = rawline${charPtr}
	END IF
'
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
'
' parse the line
'
	DO WHILE (charV)
		charpos[tokenPtr] = charPtr
		charV = rawline${charPtr}
		token = @parseFirstChar[charV]()								' token = 0 on trash
'
		IFZ token THEN INC charPtr											' skip trash
		IF importLine THEN
			IFZ importToken THEN
				IF (token{$$KIND} = $$KIND_LITERALS) THEN
					IF (token{$$TYPE} = $$STRING) THEN importToken = token
				END IF
			END IF
		END IF
'
		IF (tokenPtr = 1) THEN
			ctoken = token AND 0x1FFFFFFF
			IF ((ctoken = T_FUNCTION) OR (ctoken = T_SFUNCTION) OR (ctoken = T_CFUNCTION)) THEN
				function_line = $$TRUE
			END IF
			IF (ctoken = T_IMPORT) THEN importLine = $$TRUE
		END IF
		IF XERROR THEN markLine = 0: EXIT FUNCTION
	LOOP WHILE (charPtr < rawLength)
'
'
'
doneLine:
	INC tokenPtr
	charpos[tokenPtr] = 0
	tokens [tokenPtr] = $$T_STARTS
	tokenCount = tokenPtr AND 0x00FF
	tokens[0] = markLine OR $$T_STARTS OR (stsp << 16) OR (errorIndex << 8) OR tokenCount
'
	i = 0
	DIM tok[tokenCount]
	DO WHILE (i < tokenCount)
		tok[i] = tokens[i]
		INC i
	LOOP
	tok[i] = 0												' terminate with null token
'
	IF importLine THEN
		IF importToken THEN
			ATTACH tok[] TO hold[]				' hold IMPORT "libname" line tokens
			XxxParseLibrary (importToken)
			ATTACH hold[] TO tok[]
		END IF
	END IF
	RETURN
'
'
' *****************************************************************************
' *****  Load parseFirstChar[] with functions to parse based on 1st char  *****
' *****************************************************************************
'
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
'
'
' ############################
' #####  ParseNumber ()  #####
' ############################
'
FUNCTION  ParseNumber ()
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	ERROR_OVERFLOW,  ERROR_TYPE_MISMATCH
	SHARED	func_number,  charPtr,  rawLength,  rawline$
	SHARED UBYTE  charsetHexUpperLower[]
	SHARED UBYTE  charsetNumeric[]

	startPtr	= charPtr
	specType	= XstStringToNumber (@rawline$, @startPtr, @charPtr, @rtype, @value$$)
	vhi				= GHIGH (value$$)
	vlo				= GLOW  (value$$)
	value			= vlo
	suffixOne	= rawline${charPtr}
	IF suffixOne THEN suffixTwo	= rawline${charPtr+1}
	IF (specType < 0) THEN specType = 0
'
' see if number is followed by a type-suffix
'
	IFZ specType THEN
		SELECT CASE suffixOne
			CASE '@':		IF (suffixTwo = '@') THEN
										charPtr		= charPtr + 2
										specType	= $$USHORT
									ELSE
										charPtr		= charPtr + 1
										specType	= $$SLONG
									END IF
			CASE '%':		IF (suffixTwo = '%') THEN
										charPtr		= charPtr + 2
										specType	= $$USHORT
									ELSE
										charPtr		= charPtr + 1
										specType	= $$SLONG
									END IF
			CASE '&':		IF (suffixTwo = '&') THEN
										charPtr		= charPtr + 2
										specType	= $$ULONG
									ELSE
										charPtr		= charPtr + 1
										specType	= $$SLONG
									END IF
			CASE '$':		IF (suffixTwo = '$') THEN
										charPtr		= charPtr + 2
										specType	= $$GIANT
									END IF
			CASE '~':		charPtr			= charPtr + 1
									specType		= $$XLONG
			CASE '!':		charPtr			= charPtr + 1
									specType		= $$SINGLE
			CASE '#':		charPtr			= charPtr + 1
									specType		= $$DOUBLE
		END SELECT
	END IF
	number$		= MID$(rawline$, startPtr+1, charPtr-startPtr)
'
' if type not specified by anything yet, decide on basis of the value
'
	IFZ specType THEN
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
	END IF
'
	SELECT CASE specType
		CASE $$UBYTE	: specType = $$USHORT
		CASE $$SBYTE	: specType = $$SSHORT
	END SELECT
'
' add the literal number token to the token stream
'
	token	= $$T_LITERALS OR (specType << 16)
	token	= AddSymbol (@number$, token, func_number)
	ParseOutToken (token)
	RETURN (token)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##############################
' #####  ParseOutError ()  #####
' ##############################
'
FUNCTION  ParseOutError (token)
	SHARED	charpos[],  tokens[]
	SHARED	charPtr,  rawLength,  tokenCount,  tokenPtr
'
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
'
'
' ##############################
' #####  ParseOutToken ()  #####
' ##############################
'
FUNCTION  ParseOutToken (token)
	SHARED	blanks[],  charpos[],  tokens[]
	SHARED	charPtr,  backToken, lastToken,  tokenPtr,  rawline$
	SHARED	declareAlloTypeLine,  declareFuncaddrLine
	SHARED	T_FUNCADDR
'
' count and skip trailing spaces and tabs
'
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
			END IF
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
			END IF
		CASE ELSE
			blanks = 0
			excess = 0
	END SELECT
'
	backToken = lastToken
	lastToken = token AND 0x1FFFFFFF
	IFZ tokenPtr THEN
		declareFuncaddrLine = $$FALSE
		IF (AlloToken(lastToken) OR TypeToken(lastToken)) THEN
			declareAlloTypeLine = $$TRUE
		ELSE
			declareAlloTypeLine = $$FALSE
		END IF
	END IF
	IF declareAlloTypeLine THEN
		IF (lastToken = T_FUNCADDR) THEN declareFuncaddrLine = $$TRUE
	END IF
'
	INC tokenPtr
	tokens[tokenPtr]	= token
	charpos[tokenPtr]	= charPtr
'
'  If (>3) spaces or (>4) tabs, output whitespace token
'
	IF excess THEN
		INC tokenPtr
		tokens[tokenPtr]	= excess
		charpos[tokenPtr]	= charPtr
	END IF
	RETURN (token)
END FUNCTION
'
'
' ############################
' #####  ParseSymbol ()  #####
' ############################
'
FUNCTION  ParseSymbol ()
	SHARED	tokens[]
	SHARED	T_ATSIGN,  T_DOLLAR,  T_GOADDR,  T_GOSUB,  T_GOTO,  T_IMPORT
	SHARED	T_LPAREN,  T_POUND,  T_SUB,  T_SUBADDR,  T_TYPE,  T_UNION
	SHARED	T_GOADDRESS,  T_SUBADDRESS,  T_FUNCADDRESS
	SHARED	T_XMARK
	SHARED	charPtr,  func_number,  backToken,  lastToken,  tokenPtr
	SHARED	declareAlloTypeLine,  declareFuncaddrLine,  typeLine
	SHARED	rawLength,  rawline$,  hfn$
	SHARED UBYTE charsetUpperLower[]
	SHARED UBYTE charsetUpperLowerNumeric[]
	SHARED UBYTE charsetSpaceTab[]
'
' Collect the symbol
'
	scope		= 0
	token		= 0
	symbol$	= GetSymbol$ (@info)
	charV = rawline${charPtr}
'
' See if symbol is a keyword
'
	SELECT CASE info
		CASE $$NORMAL_SYMBOL			:	token = TestForKeyword (@symbol$)
		CASE $$LOCAL_CONSTANT			:	token = TestForKeyword (@symbol$)			' $Constant
		CASE $$GLOBAL_CONSTANT		:	token = TestForKeyword (@symbol$)			' $$Constant
		CASE $$EXTERNAL_VARIABLE	:	scope = $$EXTERNAL										' ##Extern
		CASE $$SHARED_VARIABLE		:	scope = $$SHARED											' #Shared
		CASE $$SOLO_POUND					:	token = T_POUND												' solo #
		CASE $$DUAL_POUND					:	ParseOutToken (T_POUND)								' dual ##
																token = T_POUND
		CASE $$COMPONENT					:		' not a keyword
		CASE ELSE									:	PRINT "ParseSymbol.0": GOTO eeeCompiler
	END SELECT
'
	IFZ symbol$ THEN
		ParseOutToken (token)			' non-symbol
		RETURN (token)						' ERROR: no symbol
	END IF
'
	IF token THEN
		ParseOutToken (token)			' got token already
		RETURN (token)
	END IF
'
	char0 = symbol${0}					' 1st byte in symbol
	char1 = symbol${1}					' 2nd byte in symbol
'
' 1st and 2nd tokens on line need special attention
'
	SELECT CASE tokenPtr
		CASE 0	:	IF ((charV = ':') AND (LEN(symbol$) = charPtr)) THEN  	' label:
'								symbol$ = ".g." + symbol$ + "." + hfn$								' gas ?
								symbol$ = "_g_" + symbol$ + "_" + hfn$								' unspas
								token = $$T_LABELS OR ($$GOADDR << 16)
								token = AddLabel (@symbol$, token, $$XADD)
								IF XERROR THEN EXIT FUNCTION
								ParseOutToken (@token)
								INC charPtr
								RETURN (token)
							END IF
		CASE 1	:	IF (lastToken = T_TYPE) THEN											' TYPE typename
								first = symbol${0}
								final	= rawline${charPtr-1}
								IF charsetUpperLower[first] THEN
									IF charsetUpperLowerNumeric[final] THEN
										token = AddSymbol (@symbol$, $$T_TYPES, 0)
										ParseOutToken (token)
										RETURN (token)
									END IF
								END IF
							END IF
							IF (lastToken = T_IMPORT) THEN
								PRINT "Hello IMPORT"
							END IF
	END SELECT
'
' Certain symbols are interpreted differently if following certain tokens
'
	SELECT CASE lastToken
		CASE T_GOTO																					' GOTO label
'			symbol$ = ".g." + symbol$ + "." + hfn$						' gas ?
			symbol$ = "_g_" + symbol$ + "_" + hfn$
			token = AddLabel (@symbol$, $$T_LABELS OR ($$GOADDR << 16), $$XADD)
			IF XERROR THEN EXIT FUNCTION
			ParseOutToken (@token)
			RETURN (token)
		CASE T_GOSUB, T_SUB																	' SUB/GOSUB subname
'			symbol$ = ".s." + symbol$ + "." + hfn$						' gas ?
			symbol$ = "_s_" + symbol$ + "_" + hfn$						' unspas
			token = $$T_LABELS OR ($$SUBADDR << 16)
			token = AddLabel (@symbol$, $$T_LABELS OR ($$SUBADDR << 16), $$XADD)
			ParseOutToken (@token)
			RETURN (token)
		CASE T_LPAREN
			SELECT CASE backToken
				CASE T_GOADDRESS																' GOADDRESS (label)
'					symbol$ = ".g." + symbol$ + "." + hfn$				' gas ?
					symbol$ = "_g_" + symbol$ + "_" + hfn$				' unspas
					token = $$T_LABELS OR ($$GOADDR << 16)
					token = AddLabel (@symbol$, token, $$XADD)
					IF XERROR THEN EXIT FUNCTION
					ParseOutToken (@token)
					RETURN (token)
				CASE T_SUBADDRESS																' SUBADDRESS (subname)
'					symbol$ = ".s." + symbol$ + "." + hfn$				' gas ?
					symbol$ = "_s_" + symbol$ + "_" + hfn$				' unspas
					token = $$T_LABELS OR ($$SUBADDR << 16)
					token = AddLabel (@symbol$, token, $$XADD)
					IF XERROR THEN EXIT FUNCTION
					ParseOutToken (@token)
					RETURN (token)
			END SELECT
		CASE ELSE
	END SELECT
'
' Symbols that begin with certain characters require special attention
'
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
		END IF
		token = AddSymbol (@symbol$, token, 0)
		ParseOutToken (token)
		RETURN (token)
	END IF
'
' Check for $LocalConstants and $$SharedConstants
'
	symbolLength = LEN(symbol$)
	IF (char0 = '$') THEN
		charV = rawline${charPtr}
		IF (charV = '$') THEN
			symbol$ = symbol$ + CHR$(charV)											' string $$SYSCON$
			sysconType = ($$EXTERNAL << 5) + $$STRING
			locconType = ($$SHARED << 5) + $$STRING
			INC charPtr
		END IF
		IF (symbolLength = 1) THEN
			ParseOutToken (T_DOLLAR)														' symbol is "$"
			RETURN (T_DOLLAR)
		END IF
		IF (char1 = '$') THEN
			IF (symbolLength = 2) THEN
				ParseOutToken (T_DOLLAR)
				ParseOutToken (T_DOLLAR)													' symbol is "$$"
				RETURN (T_DOLLAR)
			END IF
			token = $$T_SYSCONS + (sysconType << 16)
			token = AddSymbol (@symbol$, token, func_number)		' $$SYSCONS
			ParseOutToken (token)
			RETURN (token)
		ELSE
'			IF (symbol$ = "$XERROR") THEN
'				token = $$T_VARIABLES OR ($$XLONG << 16)					' $XERROR
'			ELSE
				token = $$T_CONSTANTS + (locconType << 16)				' $LOCAL_CONSTANT
'			END IF
			token = AddSymbol (@symbol$, token, func_number)		' $CONSTANTS
			ParseOutToken (token)
			RETURN (token)
		END IF
	END IF
'
' Normal symbols can have type suffix characters
'
	IF (char0 = '#') THEN
		scope = $$SHARED
		IF (char1 = '#') THEN scope = $$EXTERNAL
	END IF
	SELECT CASE charV
		CASE '@'	:	symbol$ = symbol$ + "@"
								data_type = $$SBYTE
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '@') THEN
									symbol$ = symbol$ + "@"
									data_type = $$UBYTE
									INC charPtr
								END IF
		CASE '%'	:	symbol$ = symbol$ + "%"
								data_type = $$SSHORT
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '%') THEN
									symbol$ = symbol$ + "%"
									data_type = $$USHORT
									INC charPtr
								END IF
		CASE '&'	:	symbol$ = symbol$ + "&"
								data_type = $$SLONG
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '&') THEN
									symbol$ = symbol$ + "&"
									data_type = $$ULONG
									INC charPtr
								END IF
		CASE '~'	:	symbol$ = symbol$ + "~"
								data_type = $$XLONG
								INC charPtr
		CASE '!'	:	symbol$ = symbol$ + "!"
								data_type = $$SINGLE
								INC charPtr
		CASE '#'	:	symbol$ = symbol$ + "#"
								data_type = $$DOUBLE
								INC charPtr
		CASE '$'	:	symbol$ = symbol$ + "$"
								data_type = $$STRING
								INC charPtr
								charV = rawline${charPtr}
								IF (charV = '$') THEN
									symbol$ = symbol$ + "$"
									data_type = $$GIANT
									INC charPtr
								END IF
		CASE ELSE	:	data_type = 0
	END SELECT
'
' See what follows trailing spaces/tabs
'
pass_out:
	sx = 0
	test_char = rawline${charPtr + sx}
	DO WHILE (charsetSpaceTab[test_char])			' skip <spaces> and <tabs>
		INC sx
		test_char = rawline${charPtr + sx}
	LOOP
'
' See if this is an array or function symbol
'
	SELECT CASE test_char
		CASE '(':		IF scope THEN NEXT CASE
								IF (declareFuncaddrLine OR (lastToken = T_ATSIGN)) THEN
									token = $$T_VARIABLES OR (data_type << 16)
								ELSE
									token = $$T_FUNCTIONS OR (data_type << 16)
								END IF
		CASE '[':		token = $$T_ARRAYS OR (scope << 21) OR (data_type << 16)
		CASE ELSE:	token = $$T_VARIABLES OR (scope << 21) OR (data_type << 16)
	END SELECT
	token = AddSymbol (@symbol$, token, func_number)
	ParseOutToken (token)
	RETURN (token)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ###########################
' #####  ParseWhite ()  #####
' ###########################
'
FUNCTION  ParseWhite ()
	SHARED	charPtr,  rawline$
	SHARED	XERROR,  ERROR_COMPILER
'
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
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##########################
' #####  PeekToken ()  #####
' ##########################
'
FUNCTION  PeekToken ()
	SHARED	funcToken[],  typeAlias[],  typeToken[],  tab_sym[],  tokens[]
	SHARED	tokenCount,  tokenPtr
	STATIC GOADDR  kindDispatch[]
'
	IFZ kindDispatch[] THEN GOSUB LoadKindDispatch		' load dispatch table
	htp				= tokenPtr
'
skip_whities:
	INC tokenPtr
	IF (tokenPtr >= tokenCount) THEN RETURN ($$T_STARTS)
	token			= tokens[tokenPtr]{29,0}
	tt				= token{$$NUMBER}
	GOTO @kindDispatch [token{$$KIND}]
	tokenPtr	= htp
	RETURN (token)
'
from_tab_sym:
	tokenPtr	= htp
	RETURN (tab_sym[tt])
'
from_func_sym:
	tokenPtr	= htp
	RETURN (funcToken[tt])
'
them_comments:
	tokenPtr	= htp
	RETURN ($$T_STARTS)
'
from_types:
	tokenPtr	= htp
	ttt				= typeAlias[tt]{$$NUMBER}
	IF ttt THEN tt = ttt
	RETURN (typeToken[tt])
'
'
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
'
'
' ####################
' #####  Pop ()  #####
' ####################
'
FUNCTION  Pop (d_reg, d_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	stackData[],  stackType[]
	SHARED	m_reg[],  m_addr[],  m_addr$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type,  func_number
'
	DEC toms
	IF (toms < 0) THEN PRINT "pop1": GOTO eeeCompiler
	IF (d_type < $$SLONG) THEN d_type = $$SLONG
'
	SELECT CASE d_reg
		CASE $$RA0:	a0_type = d_type
		CASE $$RA1:	a1_type = d_type
	END SELECT
'
	xdata = stackData[toms]
	xtype = stackType[toms]
'
	IF d_reg THEN
		IF ((d_type != $$SINGLE) AND (d_type != $$DOUBLE)) THEN
			Move (d_reg, d_type, xdata, d_type)
		END IF
	ELSE
		IF ((d_type = $$SINGLE) | (d_type = $$DOUBLE)) THEN
			IF d_type = $$SINGLE THEN
				dsize = 4
			ELSE
				dsize = 8
			END IF
			Code ($$sub, $$regimm, $$esp, dsize, 0, $$XLONG, "", "### 1026")
			Code ($$fstp, $$ro, 0, $$esp, 0, d_type, "", "### 1027")
		ELSE
			Move (d_reg, d_type, xdata, d_type)
		END IF
	END IF
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ###########################
' #####  PrintError ()  #####
' ###########################
'
' Return TRUE if user requests Quit
'
FUNCTION  PrintError (err)
	EXTERNAL /xxx/	errorCount
	SHARED	xerror$[],  charpos[]
	SHARED	XERROR,  rawLength,  rawline$,  tokenPtr,  lineNumber,  uerror
	SHARED	a0,  a0_type,  a1,  a1_type,  toes,  toms,  oos
	SHARED UBYTE oos[]
'
	IF (err <= 0) THEN PRINT "PrintError ="; err: GOTO eeePrintError
  IF (err > uerror) THEN PRINT "PrintError ="; err: GOTO eeePrintError
  error_message$ = xerror$[err]
	tp = tokenPtr
	rawline$	= Deparse$("; ")
	rawLength	= LEN(rawline$)
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
				END IF
			ELSE
				newRawline$ = newRawline$ + CHR$(rawChar)
			END IF
			IF (i <= pointer) THEN tokenPointer = newPointer
			INC i
		LOOP
	END IF
	PRINT newRawline$
	INC tokenPointer
	IF (tokenPointer > 77) THEN
		pointer = 77
	ELSE
		pointer = tokenPointer
	END IF
	IF (pointer > 2) THEN
		PRINT "; "; SPACE$(pointer - 3) + "|"
	ELSE
		PRINT "; |"
	END IF
'
	message_length = LEN(error_message$)
	half_message_length = message_length >> 1
	start_message = pointer - half_message_length
	IF (pointer + half_message_length) > 77 THEN
		start_message = 77 - message_length
	END IF
	IF (start_message < 1) THEN start_message = 0
'
	PRINT "; "; SPACE$(start_message) + error_message$
	PRINT "; "; SPACE$(start_message) + "on line"; lineNumber
	ParseOutError (@token)
	INC errorCount
	a$ = INLINE$ ("*****  Press RETURN to continue  (q to quit)  *****")
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
  END IF
	RETURN ($$FALSE)
'
eeePrintError:
	XERROR = 0
	EXIT FUNCTION
END FUNCTION
'
'
' ############################
' #####  PrintTokens ()  #####
' ############################
'
FUNCTION  PrintTokens ()
	SHARED	tokens[]

	IF tokens[] THEN
		FOR x = 0 TO tokens[0] AND 0x00FF
			PRINT HEX$(tokens[x], 8);;;
		NEXT x
		PRINT
	END IF
END FUNCTION
'
'
' #########################
' #####  Printoid ()  #####
' #########################
'
FUNCTION  Printoid ()
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED	q_type_long[],  typeName$[],  m_addr$[],  reg86$[],  reg86c$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_SYNTAX,  ERROR_TYPE_MISMATCH
	SHARED	T_ATSIGN,  T_COMMA,  T_LBRAK,  T_POUND,  T_RBRAK,  T_SEMI,  T_TAB
	SHARED	a0,  a0_type,  a1,  a1_type,  oos,  toes
	SHARED	inPrint,  tokenPtr
	SHARED UBYTE oos[]
	STATIC GOADDR printKind[]

	IFZ printKind[] THEN GOSUB LoadPrintKind
'
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
		IF (token != T_RBRAK) THEN GOTO eeeSyntax				' PRINT [ofile]
		token = NextToken ()														' token after "]"
		tkind = token{$$KIND}
		SELECT CASE tkind
			CASE $$KIND_STARTS			: zippo = $$TRUE
			CASE $$KIND_COMMENTS		: zippo = $$TRUE
			CASE $$KIND_TERMINATORS	: zippo = $$TRUE
			CASE $$KIND_SEPARATORS	: token = NextToken ()
																tkind = token{$$KIND}
																SELECT CASE tkind
																	CASE $$KIND_STARTS:				GOTO eeeSyntax
																	CASE $$KIND_COMMENTS:			GOTO eeeSyntax
																	CASE $$KIND_TERMINATORS:	GOTO eeeSyntax
																END SELECT
			CASE ELSE								: GOTO eeeSyntax
		END SELECT
		IF zippo THEN
			Code ($$call, $$rel, 0, 0, 0, 0, "__PrintFileNewline", @"### 1028")
			RETURN (token)
		END IF
	ELSE
		symbol$ = ".filenumber"
		ftoken = $$T_VARIABLES + ($$AUTOX << 21) + ($$XLONG << 16)
		ftoken = AddSymbol (@symbol$, ftoken, func_number)
		fnum = ftoken{$$NUMBER}
		IFZ m_addr$[fnum] THEN AssignAddress (ftoken)
		IF XERROR THEN EXIT FUNCTION
		SELECT CASE tkind
			CASE $$KIND_STARTS:				zippo = $$TRUE
			CASE $$KIND_COMMENTS:			zippo = $$TRUE
			CASE $$KIND_TERMINATORS:	zippo = $$TRUE
		END SELECT
		IF zippo THEN
			Code ($$call, $$rel, 0, 0, 0, 0, "__PrintConsoleNewline", @"### 1029")
			RETURN (token)
		END IF
		Code ($$push, $$imm, 1, 0, 0, $$XLONG, "", @"### 1030")
		noPush = $$TRUE
	END IF
'
	IFZ noPush THEN Code ($$push, $$reg, acc, 0, 0, $$XLONG, "", @"### 1031")
	Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 1032")
'
'
'
print_loopie:
	lastk	= kind
	kind	= token{$$KIND}
	GOTO @printKind [kind]						' dispatch based on kind
	PRINT "printkind"
	GOTO eeeSyntax
'
'
' *****  routines invoked through "GOTO @printKind [kind]" above  *****
'
print_character:
	IF (token = T_ATSIGN) THEN GOTO print_last_data
	GOTO eeeSyntax
'
' *****  append data expression to print string  *****
'
print_last_data:
	DEC tokenPtr
print_data:
	dtoken = token
	token = Eval (@new_type)
	IF XERROR THEN
		inPrint = $$FALSE
		EXIT FUNCTION
	END IF
	IF (new_type >= $$SCOMPLEX) THEN GOTO eeeTypeMismatch
	acc = Topx (@xreg, @xregx, @oreg, @oregx)
'
' if expression was TAB(value), do special TAB routine, otherwise concatenate
'
	IF (dtoken = T_TAB) THEN
		SELECT CASE acc
			CASE $$RA0
				a0_type = $$STRING
				IF first_arg THEN
					routine$ = "__print.tab.first.a0"
				ELSE
					IF (oreg = 0) AND (toes = 2) THEN
						Pop ($$RA1, $$STRING)
						a1 = toes - 1
					END IF
					routine$ = "__print.tab.a0.eq.a1.tab.a0"
				END IF
			CASE $$RA1
				a1_type = $$STRING
				IF first_arg THEN
					routine$ = "__print.tab.first.a1"
				ELSE
					IF (oreg = 0) AND (toes = 2) THEN
						Pop ($$RA0, $$STRING)
						a0 = toes - 1
					END IF
					routine$ = "__print.tab.a0.eq.a0.tab.a1"
				END IF
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
				END IF
				routine$ = "__concat.ubyte.a0.eq.a1.plus.a0.ss"
			CASE $$RA1
				IF (oreg = 0) AND (toes = 2) THEN
					Pop ($$RA0, $$STRING)
					a0 = toes - 1
					oreg = $$RA0
				END IF
				routine$ = "__concat.ubyte.a0.eq.a0.plus.a1.ss"
			CASE ELSE
				PRINT "prn1": GOTO eeeCompiler
		END SELECT
	END IF
'
' I think there's a stack tangle problem below on complex expressions !!!
'
	IF (new_type != $$STRING) THEN
		IF oreg THEN Code ($$push, $$reg, oreg, 0, 0, $$XLONG, "", "### 1033")
		Code ($$sub, $$regimm, $$esp, 64, 0, $$XLONG, "", "### 1034")
		SELECT CASE new_type
			CASE $$SINGLE, $$DOUBLE
						Code ($$fstp, $$ro, 0, $$esp, 0, new_type, "", "### 1035")
			CASE $$GIANT
						Code ($$st, $$roreg, xregx, $$esp, 4, $$XLONG, "", @"### 1036")
						Code ($$st, $$roreg, xreg, $$esp, 0, $$XLONG, "", @"### 1037")
			CASE ELSE
						Code ($$st, $$roreg, xreg, $$esp, 0, $$XLONG, "", @"### 1038")
		END SELECT
		dest$ = "__str.d." + typeName$[new_type AND 0x1F]
		Code ($$call, $$rel, 0, 0, 0, 0, dest$, @"### 1039")
		Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", @"### 1040")
		IF (acc != $$eax) THEN
			Code ($$mov, $$regreg, acc, $$eax, 0, $$XLONG, "", "### 1041")
		END IF
		IF oreg THEN
			Code ($$pop, $$reg, oreg, 0, 0, $$XLONG, "", @"### 1042")
		END IF
		INC oos
		oos[oos] = 's'
		a0_type = $$STRING
	END IF
'
	IF first_arg THEN
		IF (dtoken == T_TAB) THEN
			Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 1043")
		END IF
	ELSE
		Code ($$call, $$rel, 0, 0, 0, 0, routine$, @"### 1044")
		DEC toes
		a0 = toes
		a0_type = $$STRING
		a1 = 0
		a1_type = 0
		DEC oos
		oos[oos] = 's'
	END IF
	first_arg = $$FALSE
	add_newline = $$TRUE
	GOTO print_loopie
'
print_separator:
	oneSemi = $$FALSE
	SELECT CASE token
		CASE T_COMMA
			IF first_arg THEN
				Code ($$call, $$rel, 0, 0, 0, 0, "__PrintFirstComma", @"### 1045")
				INC toes
				a0 = toes
				a0_type = $$STRING
				INC oos
				oos[oos] = 's'
			ELSE
				Code ($$call, $$rel, 0, 0, 0, 0, "__PrintAppendComma", @"### 1046")
				a0 = toes
				a0_type = $$STRING
				oos[oos] = 's'
			END IF
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
			END IF
			semiCount$ = STRING(semiCount)
			IF first_arg THEN
				Code ($$mov, $$regimm, $$ebx, semiCount, 0, $$XLONG, "", @"### 1047")
				Code ($$call, $$rel, 0, 0, 0, 0, "__PrintFirstSpaces", @"### 1048")
				INC toes
				a0 = toes
				a0_type = $$STRING
				INC oos
				oos[oos] = 's'
			ELSE
				Code ($$mov, $$regimm, $$ebx, semiCount, 0, $$XLONG, "", @"### 1049")
				Code ($$call, $$rel, 0, 0, 0, 0, "__PrintAppendSpaces", @"### 1050")
			END IF
	END SELECT
	IFZ oneSemi THEN first_arg = $$FALSE
	add_newline = $$FALSE
	token = NextToken ()
	GOTO print_loopie
'
print_line:
print_terminator:
	Code ($$add, $$regimm, $$esp, 64, 0, $$XLONG, "", "### 1051")
	IFZ first_arg THEN
		IF add_newline THEN
			p$ = "__PrintWithNewlineThenFree"
		ELSE
			p$ = "__PrintThenFree"
		END IF
		Code ($$call, $$rel, 0, 0, 0, 0, p$, @"### 1052")
	END IF
	Code ($$add, $$regimm, $$esp, 4, 0, $$XLONG, "", "### 1053")
	inPrint = $$FALSE
	IFZ first_arg THEN DEC oos
	toes = 0: a0 = 0: a0_type = 0: a1 = 0: a1_type = 0
	RETURN (token)
'
'
' ************************************************************************
' *****  Load printKind[] with routines to print various token kinds *****
' ************************************************************************
'
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
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	inPrint = $$FALSE
	EXIT FUNCTION
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	inPrint = $$FALSE
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	inPrint = $$FALSE
	EXIT FUNCTION
END FUNCTION
'
'
' #####################
' #####  Push ()  #####
' #####################
'
FUNCTION  Push (sreg, stype)
	SHARED	tab_sym[],  m_reg[],  m_addr[],  m_addr$[]
	SHARED	stackData[],  stackType[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type
	SHARED	func_number,  hfn$
'
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
	IF ((stype = $$SINGLE) | (stype = $$DOUBLE)) THEN RETURN
	Move (xtoken, s_type, s_reg, s_type)
	RETURN (xtoken)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ############################
' #####  PushFuncArg ()  #####
' ############################
'
FUNCTION  PushFuncArg (FUNCARG arg)
	SHARED	XERROR
	SHARED	ERROR_BYREF
	SHARED	ERROR_TYPE_MISMATCH
	SHARED	SSHORT  typeConvert[]
'
	token = arg.token
	stack = arg.stack
	argType = arg.argType
	varType = arg.varType
	tt = token AND 0x0000FFFF
'
	SELECT CASE arg.kind
		CASE $$KIND_ARRAYS
					IFZ arg.byRef THEN GOTO eeeByRef
					Move (0, $$XLONG, token, $$XLONG)
		CASE $$KIND_VARIABLES
					IF ((argType > 31) OR (varType > 31)) THEN
						IF (argType != varType) THEN GOTO eeeTypeMismatch
						argType = $$XLONG
						varType = $$XLONG
					END IF
					conv = typeConvert[argType,varType] {{$$BYTE0}}
					SELECT CASE conv
						CASE -1		: GOTO eeeTypeMismatch
						CASE  0		:	IFZ token THEN
													Pop (0, varType)
												ELSE
													Move (0, varType, token, varType)
												END IF
						CASE ELSE	: IFZ token THEN
													Pop ($$eax, varType)
												ELSE
													Move ($$eax, varType, token, varType)
												END IF
												token = $$eax
												Conv ($$eax, argType, $$eax, varType)
												SELECT CASE argType
													CASE $$DOUBLE		: Code ($$sub, $$regimm, $$esp, 8, 0, $$XLONG, "", "### 1054")
																					: Code ($$fstp, $$ro, 0, $$esp, 0, $$DOUBLE, "", "### 1055")
													CASE $$SINGLE		: Code ($$sub, $$regimm, $$esp, 4, 0, $$XLONG, "", "### 1056")
																					: Code ($$fstp, $$ro, 0, $$esp, 0, $$SINGLE, "", "### 1057")
													CASE ELSE				: Code ($$push, $$reg, $$eax, 0, 0, argType, "", "### 1058")
												END SELECT
					END SELECT
		CASE $$KIND_LITERALS, $$KIND_SYSCONS, $$KIND_CONSTANTS, $$KIND_CHARCONS
					LoadLitnum (0, argType, token, varType)
		CASE ELSE
					PRINT "PushFuncArg(): Error: " : GOTO eeeCompiler
	END SELECT
	RETURN
'
eeeByRef:
	XERROR = ERROR_BYREF
	EXIT FUNCTION
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ###########################
' #####  RangeCheck ()  #####
' ###########################
'
FUNCTION  RangeCheck (ctype, symbol$)
	SHARED	maxval#[],  minval#[]
'
	x# = DOUBLE (symbol$)
	IF (ctype = $$DOUBLE) THEN RETURN ($$TRUE)
	IF (x# < minval#[ctype]) OR (x# > maxval#[ctype]) THEN RETURN ($$TRUE)
	RETURN ($$FALSE)
END FUNCTION
'
'
' ####################
' #####  Reg ()  #####  Register, imm16, neg16, litnum, connum
' ####################
'
FUNCTION  Reg (xx)
	SHARED	r_addr[]
'
	IF (xx <= $$CONNUM) THEN RETURN (xx)
	RETURN (r_addr[xx{$$NUMBER}])
END FUNCTION
'
'
' ########################
' #####  RegOnly ()  #####  Register Only  (not imm16, neg16, litnum, connum)
' ########################
'
FUNCTION  RegOnly (xx)
	SHARED	r_addr[]
'
	IF (xx < $$IMM16) THEN RETURN (xx)
	RETURN (r_addr[xx{$$NUMBER}])
END FUNCTION
'
'
' ############################
' #####  ReturnValue ()  #####
' ############################
'
FUNCTION  ReturnValue (returnType)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED SSHORT typeConvert[]
	SHARED	reg86$[],  reg86c$[]
	SHARED	funcToken[],  r_addr[]
	SHARED	T_RETURN,  T_ELSE
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH,  ERROR_VOID
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type,  oos
	SHARED	func_number,  crvtoken,  typeSize[],  typeSize$[]
	SHARED UBYTE oos[]
'
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
										END IF
			END SELECT
			IF (new_type = $$STRING) THEN						' if token is string-type
				SELECT CASE new_data{$$ALLO}								' ... and the allo is
					CASE $$AUTO, $$AUTOX:	GOSUB ClearString		' temp:  clear it
					CASE ELSE:						GOSUB CloneString		' other: clone it
				END SELECT
			END IF
		ELSE
			top = Topax1 ()																' where's the data ???
			Conv ($$RA0, funcType, top, new_type)					' put it in RA0
			IF (new_type = $$STRING) THEN									' if data is string-type
				IF (oos[oos] = 'v') THEN GOSUB CloneString	' uncloned: clone it
			END IF
		END IF
	ELSE																							' no return expression
		SELECT CASE funcType
			CASE $$GIANT
						Code ($$xor, $$regreg, $$edx, $$edx, 0, $$XLONG, "", @"### 1059")
			CASE $$SINGLE, $$DOUBLE
						Code ($$fldz, 0, 0, 0, 0, $$DOUBLE, "", @"### 1060")
			CASE ELSE
						Code ($$xor, $$regreg, $$eax, $$eax, 0, $$XLONG, "", @"### 1061")
		END SELECT
	END IF
	returnType = funcType
	oos		= 0:	oos[0]	= 0
	toes	= 0:	toms		= 0
	a0		= 0:	a0_type	= 0
	a1		= 0:	a1_type	= 0
	RETURN (new_op)
'
'
' *****  return composite data type  *****
'
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
		END IF
		Code ($$mov, $$regimm, $$ecx, ts, 0, $$XLONG, "", @"### 1062")
		Code ($$mov, $$regreg, $$eax, $$edi, 0, $$XLONG, "", @"### 1063")
		Code ($$call, $$rel, 0, 0, 0, 0, "__assignComposite", @"### 1064")
	ELSE
		Move ($$edi, $$XLONG, crvtoken, $$XLONG)
		Code ($$xor, $$regreg, $$esi, $$esi, 0, $$XLONG, "", @"### 1065")
		Code ($$mov, $$regimm, $$ecx, ts, 0, $$XLONG, "", @"### 1066")
		Code ($$mov, $$regreg, $$eax, $$edi, 0, $$XLONG, "", @"### 1067")
		Code ($$call, $$rel, 0, 0, 0, 0, "__assignComposite", @"### 1068")
	END IF
	oos		= 0:	oos[0]	= 0
	toes	= 0:	toms		= 0
	a0		= 0:	a0_type	= 0
	a1		= 0:	a1_type	= 0
	returnType = funcType
	RETURN (new_op)
'
' *****  supporting subroutines  *****
'
SUB ClearString
	IF ro THEN
		Code ($$xor, $$regreg, ro, ro, 0, $$XLONG, "", @"### 1069")
	ELSE
		Code ($$xor, $$regreg, $$esi, $$esi, 0, $$XLONG, "", @"### 1070")
		Move (new_data, $$XLONG, $$esi, $$XLONG)
	END IF
END SUB
'
SUB CloneString
	Code ($$call, $$rel, 0, 0, 0, 0, "__clone.a0", @"### 1071")
END SUB
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
'
eeeVoid:
	XERROR = ERROR_VOID
	EXIT FUNCTION
END FUNCTION
'
'
' ###########################
' #####  ScopeToken ()  #####
' ###########################
'
FUNCTION  ScopeToken (token)
	SHARED	T_AUTO
	SHARED	T_AUTOX
	SHARED	T_STATIC
	SHARED	T_SHARED
	SHARED	T_EXTERNAL

	return = 0
	token = token AND 0x1FFFFFFF
'
	SELECT CASE (token AND 0x1FFFFFFF)
		CASE T_AUTO			: return = token
		CASE T_AUTOX		: return = token
		CASE T_STATIC		: return = token
		CASE T_SHARED		: return = token
		CASE T_EXTERNAL	: return = token
	END SELECT
	RETURN (return)
'
END FUNCTION
'
'
' ########################
' #####  Shuffle ()  #####
' ########################
'
FUNCTION  Shuffle (areg, oreg, atype, ptype, argToken, kind, mode, argOffset)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
	SHARED SSHORT typeConvert[]
	SHARED	reg86$[],  reg86c$[]
	SHARED	typeSize[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_TYPE_MISMATCH
	SHARED	tokenPtr
	SHARED	nullstringer
'
	IF (kind AND 0x40) THEN by_ref = $$TRUE
	kind = kind AND 0x001F
	aa = argToken AND 0x0000FFFF
	IF (ptype = $$STRING) THEN string_type = $$TRUE
	IF (kind = $$KIND_ARRAYS) THEN atype = $$XLONG : ptype = $$XLONG
'
	IFZ string_type THEN
		IFZ by_ref THEN RETURN
		GOTO numeric_shuffle
	END IF
'
' deallocate strings passed by value
'
string_shuffle:
	IFZ by_ref THEN
		Code ($$ld, $$regro, $$esi, $$esp, argOffset, $$XLONG,"", @"### 1072")
		Code ($$call, $$rel, 0, 0, 0, 0, "_____free", @"### 1073")
		RETURN
	END IF
'
' update numeric and string variables passed by reference
'
numeric_shuffle:
	IFZ by_ref THEN RETURN
	IF (aa = nullstringer) THEN RETURN
	IF (atype >= $$SCOMPLEX) THEN RETURN
	x_convert	= typeConvert[ptype, atype] {{$$BYTE0}}
'
	SELECT CASE ptype
		CASE $$DOUBLE
					Code ($$fld, $$ro, 0, $$esp, argOffset, $$DOUBLE, "", @"### 1074")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					END IF
					Move (argToken, atype, $$esi, atype)
		CASE $$SINGLE
					Code ($$fld, $$ro, 0, $$esp, argOffset, $$SINGLE, "", @"### 1075")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					END IF
					Move (argToken, atype, $$esi, atype)
		CASE $$GIANT
					Code ($$ld, $$regro, $$esi, $$esp, argOffset, $$XLONG, "", @"### 1076")
					Code ($$ld, $$regro, $$edi, $$esp, argOffset+4, $$XLONG, "", @"### 1077")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					END IF
					Move (argToken, atype, $$esi, atype)
		CASE ELSE
					Code ($$ld, $$regro, $$esi, $$esp, argOffset, $$XLONG, "", @"### 1078")
					IF x_convert THEN
						Conv ($$esi, atype, $$esi, ptype)
					END IF
					Move (argToken, atype, $$esi, atype)
	END SELECT
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ########################
' #####  StackIt ()  #####
' ########################
'
FUNCTION  StackIt (to_type, source, from_type, offset)
	EXTERNAL /xxx/	i486bin,  i486asm
	SHARED	toes,  a0,  a0_type,  a1,  a1_type
	SHARED	r_addr[],  reg86$[],  typeSize[]
	SHARED	XERROR,  ERROR_COMPILER
'
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
	END IF
	dsize			= typeSize[to_type]
	SELECT CASE to_type
		CASE $$DOUBLE
					Code ($$fstp, $$ro, 0, $$esp, offset, $$DOUBLE, "", @"### 1079")
					offset = offset + 8
		CASE $$SINGLE
					Code ($$fstp, $$ro, 0, $$esp, offset, $$SINGLE, "", @"### 1080")
					offset = offset + 4
		CASE $$GIANT
					Code ($$st, $$roreg, ss, $$esp, offset, $$XLONG, "", @"### 1081")
					offset	= offset + 4
					Code ($$st, $$roreg, ss+1, $$esp, offset, $$XLONG, "", @"### 1082")
					offset	= offset + 4
		CASE ELSE
					Code ($$st, $$roreg, ss, $$esp, offset, $$XLONG, "", @"### 1083")
					offset	= offset + 4
	END SELECT
	DEC toes
	a0 = 0
	a0_type = 0
	RETURN
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ################################
' #####  StatementExport ()  #####
' ################################
'
FUNCTION  StatementExport (token)
	EXTERNAL /xxx/	i486asm,  i486bin,  library
	SHARED	export
	SHARED	got_program
	SHARED	got_export
	SHARED	T_EXPORT
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_NEST
	SHARED	ERROR_PROGRAM_NOT_NAMED,  ERROR_TOO_LATE
'
	IF export THEN GOTO eeeNest
	IF got_function THEN GOTO eeeTooLate
	IFZ got_program THEN GOTO eeeProgramNotNamed
	IF (token != T_EXPORT) THEN GOTO eeeCompiler
	got_export = $$TRUE
	export = $$TRUE
	RETURN ($$T_STARTS)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)
'
eeeNest:
	XERROR = ERROR_NEST
	RETURN ($$T_STARTS)
'
eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)
'
eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' ################################
' #####  StatementImport ()  #####
' ################################
'
FUNCTION  StatementImport (token)
	SHARED	T_IMPORT
	SHARED	T_LIBRARY
	SHARED	got_declare
	SHARED	a0, a0_type, a1, a1_type
	SHARED	got_import
	SHARED	m_addr$[]
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_SYNTAX,  ERROR_TOO_LATE
'
	IF ((token != T_IMPORT) AND (token != T_LIBRARY)) THEN GOTO eeeCompiler
	IF got_declare THEN GOTO eeeTooLate
	token = NextToken ()
'
	SELECT CASE token{$$KIND}
		CASE $$KIND_LITERALS	:	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeSyntax
														IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
														IF XERROR THEN RETURN ($$T_STARTS)
														XxxLoadLibrary (token)
														got_import = $$TRUE
		CASE ELSE							: GOTO eeeSyntax
	END SELECT
	RETURN ($$T_STARTS)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)
'
eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' #################################
' #####  StatementProgram ()  #####
' #################################
'
FUNCTION  StatementProgram (token)
	EXTERNAL /xxx/	i486asm,  i486bin,  library
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_DEFINITION
	SHARED	ERROR_OPEN_FILE,  ERROR_PROGRAM_NOT_NAMED
	SHARED	ERROR_SYNTAX,  ERROR_TOO_LATE,  ERROR_TYPE_MISMATCH
	SHARED	got_declare,  got_export,  got_function
	SHARED	got_import,  got_program,  got_type
	SHARED	programToken
	SHARED	programName$
	SHARED  program$
	SHARED	T_PROGRAM
	SHARED	tab_sym$[]
	SHARED	m_addr$[]
'
	IF got_program THEN GOTO eeeDupDefinition
	IF (token != T_PROGRAM) THEN GOTO eeeCompiler
	IF (got_declare OR got_export OR got_function OR got_import OR got_type) THEN GOTO eeeTooLate
'
	token = NextToken ()
	IF (token{$$KIND} != $$KIND_LITERALS) THEN GOTO eeeSyntax
	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeTypeMismatch
	IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
	IF XERROR THEN RETURN ($$T_STARTS)
	program$ = tab_sym$[token AND 0x0000FFFF]
	program$ = TRIM$(MID$(program$,2,LEN(program$)-2))		' remove "quotes"
	StripNonSymbol (@program$)
	IFZ program$ THEN program$ = programName$
	IFZ program$ THEN GOTO eeeProgramNotNamed
	got_program = $$TRUE
	programToken = token
	RETURN ($$T_STARTS)
'
' *****  Errors  *****
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)
'
eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	RETURN ($$T_STARTS)
'
eeeOpenFile:
	XERROR = ERROR_OPEN_FILE
	RETURN ($$T_STARTS)
'
eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)
'
eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' #################################
' #####  StatementVersion ()  #####
' #################################
'
FUNCTION  StatementVersion (token)
	EXTERNAL /xxx/	i486asm,  i486bin,  library
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_DUP_DEFINITION
	SHARED	ERROR_SYNTAX,  ERROR_TOO_LATE,  ERROR_TYPE_MISMATCH
	SHARED	got_declare,  got_export,  got_function
	SHARED	got_import,  got_program,  got_type
	SHARED	versionToken
	SHARED	T_VERSION
	SHARED	version$
	SHARED	tab_sym$[]
	SHARED	m_addr$[]
'
	IF version$ THEN GOTO eeeDupDefinition
	IF (token != T_VERSION) THEN GOTO eeeCompiler
	IF (got_declare OR got_export OR got_function OR got_import OR got_type) THEN GOTO eeeTooLate
'
	token = NextToken ()
	IF (token{$$KIND} != $$KIND_LITERALS) THEN GOTO eeeSyntax
	IF (token{$$TYPE} != $$STRING) THEN GOTO eeeTypeMismatch
	IFZ m_addr$[token AND 0x0000FFFF] THEN AssignAddress (token)
	IF XERROR THEN RETURN ($$T_STARTS)
	version$ = tab_sym$[token AND 0x0000FFFF]
	version$ = TRIM$(MID$(version$,2,LEN(version$)-2))
	versionToken = token
	RETURN ($$T_STARTS)
'
' *****  Errors  *****
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	RETURN ($$T_STARTS)
'
eeeDupDefinition:
	XERROR = ERROR_DUP_DEFINITION
	RETURN ($$T_STARTS)
'
eeeSyntax:
	XERROR = ERROR_SYNTAX
	RETURN ($$T_STARTS)
'
eeeTooLate:
	XERROR = ERROR_TOO_LATE
	RETURN ($$T_STARTS)
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' ############################
' #####  StripExtent ()  #####
' ############################
'
FUNCTION  StripExtent (filename$)
'
	dot = RINSTR (filename$, ".")
	IF dot THEN filename$ = TRIM$(LEFT$(filename$, dot-1))
END FUNCTION
'
'
' ###############################
' #####  StripNonSymbol ()  #####
' ###############################
'
FUNCTION  StripNonSymbol (name$)
	SHARED  UBYTE  charsetUpperLower[]
	SHARED  UBYTE  charsetUpperLowerNumeric[]
'
	IFZ name$ THEN RETURN
	upper = UBOUND (name$)
'
	first = -1
	FOR i = 0 TO upper
		IF charsetUpperLower[name${i}] THEN first = i : EXIT FOR
	NEXT i
	IF (first < 0) THEN name$ = "" : RETURN
'
	final = -1
	FOR i = first TO upper
		IFZ charsetUpperLowerNumeric[name${i}] THEN final = i-1 : EXIT FOR
	NEXT i
	IF (final < 0) THEN final = upper
'
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
	END IF
END FUNCTION
'
'
' #############################
' #####  StripSuffix$ ()  #####
' #############################
'
FUNCTION  StripSuffix$ (x$)
	SHARED UBYTE  charsetSymbolInner[]
'
	d = LEN(x$)
	IFZ d THEN RETURN
	DO
		DEC d
		check  = x${d}
	LOOP UNTIL (charsetSymbolInner[check])
	RETURN (LEFT$(x$, d+1))
END FUNCTION
'
'
' ###############################
' #####  TestForKeyword ()  #####
' ###############################
'
FUNCTION  TestForKeyword (symbol$)
	SHARED	alphaFirst[],  alphaLast[],  tab_sym$[],  tab_sym[],  tab_sys$[]
	SHARED	tab_sys[],  typeSymbol$[],  typeToken[]
	SHARED	charPtr,  pastSystemSymbols,  rawLength,  rawline$,  typePtr
	SHARED UBYTE  charsetSuffix[]
'
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
'
	first	= alphaFirst[x]
	last	= alphaLast[x]
	x			= first
	token = 0
'
	charV = rawline${charPtr}
	IF (charV = '$') THEN
		sys$	= x$ + "$"
		xtra	= $$TRUE
	ELSE
		sys$	= x$
	END IF
	symbolLength = LEN (sys$)
'
'
' *****  See if valid $$SystemConstant or ##SystemVariable
'
	IF gotSystemSymbol THEN
		token = 0
		x = 0
		DO
			IF (tab_sym$[x] = sys$) THEN
				token = tab_sym[x]
				IF xtra THEN INC charPtr
				EXIT DO
			END IF
			INC x
		LOOP WHILE (x < pastSystemSymbols)
		RETURN (token)
	END IF
'
'
' *****  See if KEYWORD  *****
'
	DO
		IF (tab_sys$[x] = sys$) THEN
			token = tab_sys[x]
			IF xtra THEN INC charPtr
			RETURN (token)
		END IF
		INC x
	LOOP WHILE (x <= last)
'
'
' *****  See if user defined TYPE name  *****
'
	IF charsetSuffix[charV] THEN RETURN ($$FALSE)
	typeNumber	= $$SCOMPLEX
	DO WHILE (typeNumber < typePtr)
		IF (typeSymbol$[typeNumber] = symbol$) THEN
			token = typeToken[typeNumber]
			RETURN (token)
		END IF
		INC typeNumber
	LOOP
	RETURN ($$FALSE)
END FUNCTION
'
'
' ########################
' #####  TheType ()  #####
' ########################
'
FUNCTION  TheType (token)
	SHARED	defaultType[],  tabType[],  funcType[],  typeAlias[],  m_addr$[],  tab_sym$[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	defaultType,  func_number
	STATIC GOADDR typeKind[]
'
	IFZ typeKind[] THEN GOSUB LoadTypeKind
'
	qtype = token{$$TYPE}										' type field from token
	IF qtype THEN RETURN (qtype)						' type was in token
	tt = token{$$NUMBER}										' token number
	kind = token{$$KIND}										' kind of token
	scope = token{$$ALLO}										' scope of token
	GOTO @typeKind [kind]										' figure type for this kind
	RETURN																	' no type for other kinds
'
'
' *****  Routines to figure type for all valid kinds  *****
'
type_arrays:
type_variables:
	qtype = tabType[tt]									' type = tabType[tt]
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
'
	SELECT CASE scope
		CASE $$SHARED			: RETURN (defaultType)
		CASE $$EXTERNAL		: RETURN (defaultType)
		CASE ELSE					: RETURN (defaultType[func_number])
	END SELECT
	RETURN (defaultType)								' return system-wide default type
'
type_literals:
type_constants:
	qtype = tabType[tt]									' type = tabType[tt]
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
	qtype = defaultType[func_number]		' type = defaultType for this function
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
	RETURN (defaultType)								' return system-wide default type
'
type_functions:
	qtype = funcType[tt]								' get type from funcType[] array
	IF qtype THEN RETURN (qtype)				' return declared function type
	RETURN ($$XLONG)										' return default function type
'
type_syscons:
	qtype = tabType[tt]									' type = tabType[tt]
	IF qtype THEN RETURN (qtype)				' if (type != 0), return type
	GOTO eeeCompiler										' no type at all  (compiler error)
'
type_bitcons:
type_charcons:
	RETURN ($$USHORT)										' all charcons and bitcons are USHORT
'
type_types:
	RETURN (tt)													' type of TYPE token
'
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
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ####################
' #####  Tok ()  #####
' ####################
'
FUNCTION  Tok (symbol$, token, kind, raddr, value, value$)
	SHARED	r_addr[],  r_addr$[],  m_addr$[]
	SHARED	XERROR
'
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
	END IF
	RETURN (token)
END FUNCTION
'
'
' ################################
' #####  TokenRestOfLine ()  #####
' ################################
'
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
'
'
' ##############################
' #####  TokensDefined ()  #####
' ##############################
'
FUNCTION  TokensDefined ()
	EXTERNAL /xxx/	i486asm,  i486bin,  checkBounds
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
	SHARED	T_ABS,  T_ADD,  T_ALL,  T_ANY,  T_ASC,  T_ATSIGN
	SHARED	T_ATTACH,  T_AUTO,  T_AUTOX,  T_BIN_D,  T_BINB_D,  T_BITFIELD
	SHARED	T_CASE,  T_CFUNCTION,  T_CHR_D,  T_CJUST_D,  T_CLR,  T_CLOSE
	SHARED	T_CMP,  T_COLON,  T_COMMA,  T_CSIZE,  T_CSIZE_D,  T_CSTRING_D
	SHARED	T_DEC,  T_DECLARE,  T_DHIGH,  T_DIM
	SHARED	T_DIV,  T_DLOW,  T_DMAKE,  T_DO,  T_DOLLAR,  T_DOT
	SHARED	T_DOUBLE,  T_DOUBLEAT,  T_DQUOTE,  T_DSHIFT
	SHARED	T_ELSE,  T_END,  T_ENDIF,  T_EOF,  T_ERROR,  T_ERROR_D
	SHARED	T_ETC,  T_EXIT,  T_EXPORT,  T_EXTERNAL,  T_EXTS,  T_EXTU
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
	SHARED	T_MAKE,  T_MARK,  T_MAX,  T_MID_D,  T_MIN,  T_MINUS,  T_MOD,  T_MUL
	SHARED	T_NEXT,  T_NULL_D,  T_OCT_D,  T_OCTO_D,  T_OPEN
	SHARED	T_PERCENT,  T_PLUS,  T_POF,  T_POUND,  T_POWER
	SHARED	T_PRINT,  T_PROGRAM,  T_PROGRAM_D,  T_QMARK,  T_QUIT
	SHARED	T_RBRACE,  T_RBRAK,  T_RCLIP_D,  T_READ,  T_REDIM,  T_REM
	SHARED	T_REMAINDER,  T_RETURN,  T_RIGHT_D
	SHARED	T_RINCHR,  T_RINCHRI,  T_RINSTR,  T_RINSTRI,  T_RJUST_D
	SHARED	T_ROTATEL,  T_ROTATER,  T_RPAREN,  T_RSHIFT,  T_RTRIM_D
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
	SHARED	nullstringer
	SHARED	pastSystemLabels,  pastSystemSymbols
	SHARED	tab_sym_ptr,  tab_sys_ptr,  xit
	SHARED	falseToken
	SHARED	entryCheckBounds
	SHARED UBYTE	charsetUpper[],  charsetUpperLower[]
	STATIC  notFirstTime,  x$
'
'
' Put $$IMM16, $$NEG16, $$LITNUM, $$CONNUM in symbol table as 32 - 35
'
	r_addr[$$IMM16] = $$IMM16
	r_addr[$$NEG16] = $$NEG16
	r_addr[$$LITNUM] = $$LITNUM
	r_addr[$$CONNUM] = $$CONNUM
'
	tab_sym_ptr			= 36
	nullstringer		= 36
	alphaFirst[0]		= 1
	tempAddr				= externalAddr
	externalAddr		= ##GLOBAL0
'
' Put labels and their addresses into label symbol table (from asm libraries).
'
	##ERROR = $$FALSE
	IFZ xit THEN
		past = GetExternalAddresses ()
		IF ##ERROR THEN
			XstErrorNumberToName (##ERROR, @error$)
			PRINT "Error # : name = "; HEXX$(##ERROR,4); " : "; error$
			PRINT "Can't load external addresses.  Don't compile into memory!"
			pastSystemLabels = 1
		END IF
		pastSystemLabels = past
	END IF
	##ERROR = $$FALSE
	externalAddr = tempAddr
'
	saveBin = i486bin
	i486bin = $$TRUE
	GOSUB DefineSystemConstants						' Define system constants
	i486bin = saveBin
'
' *****  Test Only  *****
'
'	PRINT "TokensDefined():  "; past; " labels extracted from COFF executable."
'
	XstGetCommandLineArguments (@argc, @argv$[])
	IF (argc > 1) THEN
		IF (TRIM$(argv$[1]) = "-xlabs") THEN
'		test$ = argv$[1]
'		test$ = TRIM$(test$)
'		IF (test$ = "-xlabs") THEN
			PRINT															' Bug
			FOR i = 0 TO past
					PRINT HEX$(tab_lab[i],8), HEX$(labaddr[i],8), tab_lab$[i]
			NEXT i
		END IF
	END IF
'
' *****  End Test  *****
'
' *************************************************************
' *****  THE REST OF THIS FUNCTION IS EXECUTED ONLY ONCE  *****
' *************************************************************
'
' ************************************************************************
' *****  Define all system tokens:  keywords, operators, characters  *****
' ************************************************************************
'
	IF notFirstTime THEN RETURN
	notFirstTime = $$TRUE
	entryCheckBounds = checkBounds
'
	tab_sys_ptr = 0
	alphaLast[0] = tab_sys_ptr - 1
	alphaFirst[1] = tab_sys_ptr
	T_ABS = MakeToken("ABS", $$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_ALL = MakeToken("ALL", $$KIND_STATEMENTS, 0)
	T_AND = MakeToken("AND", $$KIND_BINARY_OPS, $$COP3  OR $$PREC_AND)
	T_ANY = MakeToken("ANY", $$KIND_STATEMENTS, $$ANY)
	T_ASC = MakeToken("ASC", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_ATTACH = MakeToken("ATTACH", $$KIND_STATEMENTS, 0)
	T_AUTO = MakeToken("AUTO", $$KIND_STATEMENTS, $$AUTO << 5)
	T_AUTOX = MakeToken("AUTOX", $$KIND_STATEMENTS, $$AUTOX << 5)
	alphaLast[1] = tab_sys_ptr - 1
	alphaFirst[2] = tab_sys_ptr
	T_BIN_D = MakeToken("BIN$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_BINB_D = MakeToken("BINB$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_BITFIELD = MakeToken("BITFIELD", $$KIND_INTRINSICS, $$ARGS2 OR $$USHORT)
	alphaLast[2] = tab_sys_ptr - 1
	alphaFirst[3] = tab_sys_ptr
	T_CASE = MakeToken("CASE", $$KIND_STATEMENTS, 0)
	T_CFUNCTION = MakeToken("CFUNCTION", $$KIND_STATEMENTS, 0)
	T_CHR_D = MakeToken("CHR$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_CJUST_D = MakeToken("CJUST$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_CLOSE = MakeToken("CLOSE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_CLR = MakeToken("CLR", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_CSIZE = MakeToken("CSIZE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_CSIZE_D = MakeToken("CSIZE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_CSTRING_D = MakeToken("CSTRING$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[3] = tab_sys_ptr - 1
	alphaFirst[4] = tab_sys_ptr
	T_DEC = MakeToken("DEC", $$KIND_STATEMENTS, 0)
	T_DECLARE = MakeToken("DECLARE", $$KIND_STATEMENTS, 0)
	T_DHIGH = MakeToken("DHIGH", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_DIM = MakeToken("DIM", $$KIND_STATEMENTS, 0)
	T_DLOW = MakeToken("DLOW", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_DMAKE = MakeToken("DMAKE", $$KIND_INTRINSICS, $$ARGS2 OR $$DOUBLE)
	T_DO = MakeToken("DO", $$KIND_STATEMENTS, 0)
	T_DOUBLE = MakeToken("DOUBLE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$DOUBLE)
	T_DOUBLEAT = MakeToken("DOUBLEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$DOUBLE)
	alphaLast[4] = tab_sys_ptr - 1
	alphaFirst[5] = tab_sys_ptr
	T_ELSE = MakeToken("ELSE",     $$KIND_STATEMENTS, 0)
	T_END = MakeToken("END",      $$KIND_STATEMENTS, 0)
	T_ENDIF = MakeToken("ENDIF",    $$KIND_STATEMENTS, 0)
	T_EOF = MakeToken("EOF", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_ERROR = MakeToken("ERROR", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_ERROR_D = MakeToken("ERROR$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_EXIT = MakeToken("EXIT",     $$KIND_STATEMENTS, 0)
	T_EXPORT = MakeToken("EXPORT", $$KIND_STATEMENTS, 0)
	T_EXTERNAL = MakeToken("EXTERNAL", $$KIND_STATEMENTS, $$EXTERNAL << 5)
	T_EXTS = MakeToken("EXTS",    $$KIND_INTRINSICS, $$ARGS3 OR $$SLONG)
	T_EXTU = MakeToken("EXTU",    $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	alphaLast[5] = tab_sys_ptr - 1
	alphaFirst[6] = tab_sys_ptr
	T_FALSE = MakeToken("FALSE", $$KIND_STATEMENTS, 0)
	T_FIX = MakeToken("FIX", $$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_FOR = MakeToken("FOR", $$KIND_STATEMENTS, 0)
	T_FORMAT_D = MakeToken("FORMAT$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_FUNCADDR = MakeToken("FUNCADDR", $$KIND_STATE_INTRIN, $$ARGS1 OR $$FUNCADDR)
	T_FUNCADDRAT = MakeToken("FUNCADDRAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$FUNCADDR)
	T_FUNCADDRESS = MakeToken("FUNCADDRESS", $$KIND_INTRINSICS, $$ARGS1 OR $$FUNCADDR)
	T_FUNCTION = MakeToken("FUNCTION", $$KIND_STATEMENTS, 0)
	alphaLast[6] = tab_sys_ptr - 1
	alphaFirst[7] = tab_sys_ptr
	T_GHIGH = MakeToken("GHIGH", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_GIANT = MakeToken("GIANT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$GIANT)
	T_GIANTAT = MakeToken("GIANTAT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$GIANT)
	T_GLOW = MakeToken("GLOW", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_GMAKE = MakeToken("GMAKE", $$KIND_INTRINSICS, $$ARGS2 OR $$GIANT)
	T_GOADDR = MakeToken("GOADDR", $$KIND_STATE_INTRIN, $$ARGS1 OR $$GOADDR)
	T_GOADDRAT = MakeToken("GOADDRAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$GOADDR)
	T_GOADDRESS = MakeToken("GOADDRESS", $$KIND_INTRINSICS, $$ARGS1 OR $$GOADDR)
	T_GOSUB = MakeToken("GOSUB", $$KIND_STATEMENTS, 0)
	T_GOTO = MakeToken("GOTO", $$KIND_STATEMENTS, 0)
	alphaLast[7] = tab_sys_ptr - 1
	alphaFirst[8] = tab_sys_ptr
	T_HEX_D = MakeToken("HEX$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_HEXX_D = MakeToken("HEXX$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_HIGH0 = MakeToken("HIGH0", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_HIGH1 = MakeToken("HIGH1", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	alphaLast[8] = tab_sys_ptr - 1
	alphaFirst[9] = tab_sys_ptr
	T_IF = MakeToken("IF", $$KIND_STATEMENTS, 0)
	T_IFF = MakeToken("IFF", $$KIND_STATEMENTS, 0)
	T_IFT = MakeToken("IFT", $$KIND_STATEMENTS, 0)
	T_IFZ = MakeToken("IFZ", $$KIND_STATEMENTS, 0)
	T_IMPORT = MakeToken("IMPORT", $$KIND_STATEMENTS, 0)
	T_INC = MakeToken("INC", $$KIND_STATEMENTS, 0)
	T_INCHR = MakeToken("INCHR", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INCHRI = MakeToken("INCHRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INFILE_D = MakeToken("INFILE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_INLINE_D = MakeToken("INLINE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_INSTR = MakeToken("INSTR", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INSTRI = MakeToken("INSTRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_INT = MakeToken("INT", $$KIND_INTRINSICS, $$ARGS1 OR $$TYPE_INPUT)
	T_INTERNAL = MakeToken("INTERNAL", $$KIND_STATEMENTS, 0)
	alphaLast[9] = tab_sys_ptr - 1
	alphaFirst[10] = 0
	alphaLast[10] = -1
	alphaFirst[11] = tab_sys_ptr
	alphaLast[11] = -1
	alphaFirst[12] = tab_sys_ptr
	T_LCASE_D = MakeToken("LCASE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_LCLIP_D = MakeToken("LCLIP$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_LEFT_D = MakeToken("LEFT$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_LEN = MakeToken("LEN", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_LIBRARY = MakeToken("LIBRARY", $$KIND_STATE_INTRIN, $$ARGS1 OR $$XLONG)
	T_LJUST_D = MakeToken("LJUST$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_LOF = MakeToken("LOF", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_LOOP = MakeToken("LOOP", $$KIND_STATEMENTS, 0)
	T_LTRIM_D = MakeToken("LTRIM$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[12] = tab_sys_ptr - 1
	alphaFirst[13] = tab_sys_ptr
	T_MAKE = MakeToken("MAKE", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_MAX = MakeToken("MAX", $$KIND_INTRINSICS, $$ARGS2 OR $$TYPE_INPUT)
	T_MID_D = MakeToken("MID$", $$KIND_INTRINSICS, $$ARGS3 OR $$STRING)
	T_MIN = MakeToken("MIN", $$KIND_INTRINSICS, $$ARGS2 OR $$TYPE_INPUT)
	T_MOD = MakeToken("MOD", $$KIND_BINARY_OPS, $$COP6 OR $$PREC_MOD)
	alphaLast[13] = tab_sys_ptr - 1
	alphaFirst[14] = tab_sys_ptr
	T_NEXT = MakeToken("NEXT", $$KIND_STATEMENTS, 0)
	T_NOT = MakeToken("NOT", $$KIND_UNARY_OPS, $$COPA OR $$PREC_NOT)
	T_NULL_D = MakeToken("NULL$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[14] = tab_sys_ptr - 1
	alphaFirst[15] = tab_sys_ptr
	T_OCT_D = MakeToken("OCT$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_OCTO_D = MakeToken("OCTO$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_OPEN = MakeToken("OPEN", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_OR = MakeToken("OR", $$KIND_BINARY_OPS, $$COP3 OR $$PREC_OR)
	alphaLast[15] = tab_sys_ptr - 1
	alphaFirst[16] = tab_sys_ptr
	T_POF = MakeToken("POF", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_PRINT = MakeToken("PRINT",		$$KIND_STATEMENTS, 0)
	T_PROGRAM = MakeToken("PROGRAM",	$$KIND_STATEMENTS, 0)
	T_PROGRAM_D = MakeToken("PROGRAM$",	$$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[16] = tab_sys_ptr - 1
	alphaFirst[17] = tab_sys_ptr
	T_QUIT = MakeToken("QUIT", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	alphaLast[17] = tab_sys_ptr - 1
	alphaFirst[18] = tab_sys_ptr
	T_RCLIP_D = MakeToken("RCLIP$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_READ = MakeToken("READ",    $$KIND_STATEMENTS, 0)
	T_REDIM = MakeToken("REDIM",   $$KIND_STATEMENTS, 0)
	T_RETURN = MakeToken("RETURN",  $$KIND_STATEMENTS, 0)
	T_RIGHT_D = MakeToken("RIGHT$",  $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_RINCHR = MakeToken("RINCHR",  $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RINCHRI = MakeToken("RINCHRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RINSTR = MakeToken("RINSTR",  $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RINSTRI = MakeToken("RINSTRI", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_RJUST_D = MakeToken("RJUST$", $$KIND_INTRINSICS, $$ARGS2 OR $$STRING)
	T_ROTATEL = MakeToken("ROTATEL", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_ROTATER = MakeToken("ROTATER", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_RTRIM_D = MakeToken("RTRIM$",  $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	alphaLast[18] = tab_sys_ptr - 1
	alphaFirst[19] = tab_sys_ptr
	T_SBYTE = MakeToken("SBYTE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SBYTE)
	T_SBYTEAT = MakeToken("SBYTEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SBYTE)
	T_SEEK = MakeToken("SEEK", $$KIND_INTRINSICS, $$ARGS2 OR $$XLONG)
	T_SELECT = MakeToken("SELECT", $$KIND_STATEMENTS, 0)
	T_SET = MakeToken("SET", $$KIND_INTRINSICS, $$ARGS3 OR $$XLONG)
	T_SFUNCTION = MakeToken("SFUNCTION", $$KIND_STATEMENTS, 0)
	T_SGN = MakeToken("SGN", $$KIND_INTRINSICS, $$ARGS1 OR $$SLONG)
	T_SHARED = MakeToken("SHARED", $$KIND_STATEMENTS, $$SHARED << 5)
	T_SHELL = MakeToken("SHELL", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_SIGN = MakeToken("SIGN", $$KIND_INTRINSICS, $$ARGS1 OR $$SLONG)
	T_SIGNED_D = MakeToken("SIGNED$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_SINGLE = MakeToken("SINGLE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SINGLE)
	T_SINGLEAT = MakeToken("SINGLEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SINGLE)
	T_SIZE = MakeToken("SIZE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_SLONG = MakeToken("SLONG", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SLONG)
	T_SLONGAT = MakeToken("SLONGAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SLONG)
	T_SMAKE = MakeToken("SMAKE", $$KIND_INTRINSICS, $$ARGS1 OR $$SINGLE)
	T_SPACE_D = MakeToken("SPACE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_SSHORT = MakeToken("SSHORT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SSHORT)
	T_SSHORTAT = MakeToken("SSHORTAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SSHORT)
	T_STATIC = MakeToken("STATIC", $$KIND_STATEMENTS, $$STATIC << 5)
	T_STEP = MakeToken("STEP", $$KIND_STATEMENTS, 0)
	T_STOP = MakeToken("STOP", $$KIND_STATEMENTS, 0)
	T_STR_D = MakeToken("STR$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_STRING = MakeToken("STRING", $$KIND_STATE_INTRIN, $$ARGS1 OR $$STRING)
	T_STRING_D = MakeToken("STRING$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_STUFF_D = MakeToken("STUFF$", $$KIND_INTRINSICS, $$ARGS4 OR $$STRING)
	T_SUB = MakeToken("SUB", $$KIND_STATEMENTS, 0)
	T_SUBADDR = MakeToken("SUBADDR", $$KIND_STATE_INTRIN, $$ARGS1 OR $$SUBADDR)
	T_SUBADDRAT = MakeToken("SUBADDRAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$SUBADDR)
	T_SUBADDRESS = MakeToken("SUBADDRESS", $$KIND_INTRINSICS, $$ARGS1 OR $$SUBADDR)
	T_SWAP = MakeToken("SWAP", $$KIND_STATEMENTS, 0)
	alphaLast[19] = tab_sys_ptr - 1
	alphaFirst[20] = tab_sys_ptr
	T_TAB = MakeToken("TAB", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_THEN = MakeToken("THEN", $$KIND_STATEMENTS, 0)
	T_TO = MakeToken("TO", $$KIND_STATEMENTS, 0)
	T_TRIM_D = MakeToken("TRIM$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_TRUE = MakeToken("TRUE", $$KIND_STATEMENTS, 0)
	T_TYPE = MakeToken("TYPE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$XLONG)
	alphaLast[20] = tab_sys_ptr - 1
	alphaFirst[21] = tab_sys_ptr
	T_UBOUND = MakeToken("UBOUND", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_UBYTE = MakeToken("UBYTE", $$KIND_STATE_INTRIN, $$ARGS1 OR $$UBYTE)
	T_UBYTEAT = MakeToken("UBYTEAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$UBYTE)
	T_UCASE_D = MakeToken("UCASE$", $$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_ULONG = MakeToken("ULONG", $$KIND_STATE_INTRIN, $$ARGS1 OR $$ULONG)
	T_ULONGAT = MakeToken("ULONGAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$ULONG)
	T_UNION = MakeToken("UNION", $$KIND_STATEMENTS, 0)
	T_UNTIL = MakeToken("UNTIL", $$KIND_STATEMENTS, 0)
	T_USHORT = MakeToken("USHORT", $$KIND_STATE_INTRIN, $$ARGS1 OR $$USHORT)
	T_USHORTAT = MakeToken("USHORTAT",	$$KIND_STATE_INTRIN, $$ARGS2 OR $$USHORT)
	alphaLast[21] = tab_sys_ptr - 1
	alphaFirst[22] = tab_sys_ptr
	T_VERSION = MakeToken("VERSION", $$KIND_STATEMENTS, 0)
	T_VERSION_D = MakeToken("VERSION$",	$$KIND_INTRINSICS, $$ARGS1 OR $$STRING)
	T_VOID = MakeToken("VOID", $$KIND_STATEMENTS, $$VOID)
	alphaLast[22] = tab_sys_ptr - 1
	alphaFirst[23] = tab_sys_ptr
	T_WHILE = MakeToken("WHILE", $$KIND_STATEMENTS, 0)
	T_WRITE = MakeToken("WRITE", $$KIND_STATEMENTS, 0)
	alphaLast[23] = tab_sys_ptr - 1
	alphaFirst[24] = tab_sys_ptr
	T_XLONG = MakeToken("XLONG", $$KIND_STATE_INTRIN, $$ARGS1 OR $$XLONG)
	T_XLONGAT = MakeToken("XLONGAT", $$KIND_STATE_INTRIN, $$ARGS2 OR $$XLONG)
	T_XMAKE = MakeToken("XMAKE", $$KIND_INTRINSICS, $$ARGS1 OR $$XLONG)
	T_XOR = MakeToken("XOR", $$KIND_BINARY_OPS, $$COP3 OR $$PREC_XOR)
	alphaLast[24] = tab_sys_ptr - 1
	alphaFirst[25] = 0
	alphaLast[25] = -1
	alphaFirst[26] = 0
	alphaLast[26] = -1
	alphaFirst[27] = tab_sys_ptr
'
' *****  Bitwise  *****
'
	T_TILDA			= MakeToken("~",    $$KIND_UNARY_OPS,  $$COPA OR $$PREC_TILDA)
	T_NOTBIT		= MakeToken("~",    $$KIND_UNARY_OPS,  $$COPA OR $$PREC_NOTBIT)
	T_ANDBIT		= MakeToken("&",    $$KIND_BINARY_OPS, $$COP3 OR $$PREC_ANDBIT)
	T_XORBIT		= MakeToken("^",    $$KIND_BINARY_OPS, $$COP3 OR $$PREC_XORBIT)
	T_ORBIT			= MakeToken("|",    $$KIND_BINARY_OPS, $$COP3 OR $$PREC_ORBIT)
'
' *****  Logical  *****
'
	T_TESTL			= MakeToken("!!",   $$KIND_UNARY_OPS,  $$COP9 OR $$PREC_TESTL)
	T_NOTL			= MakeToken("!",    $$KIND_UNARY_OPS,  $$COP9 OR $$PREC_NOTL)
	T_ANDL			= MakeToken("&&",   $$KIND_BINARY_OPS, $$COP1 OR $$PREC_ANDL)
	T_XORL			= MakeToken("^^",   $$KIND_BINARY_OPS, $$COP1 OR $$PREC_XORL)
	T_ORL				= MakeToken("||",   $$KIND_BINARY_OPS, $$COP1 OR $$PREC_ORL)
'
' *****  Comparison  *****
'
	T_EQL				= MakeToken("==",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_EQL)
	T_EQ				= MakeToken("=",    $$KIND_BINARY_OPS, $$COP2 OR $$PREC_EQ)
	T_LT				= MakeToken("<",    $$KIND_BINARY_OPS, $$COP2 OR $$PREC_LT)
	T_GT				= MakeToken(">",    $$KIND_BINARY_OPS, $$COP2 OR $$PREC_GT)
	T_NE				= MakeToken("<>",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NE)
	T_LE				= MakeToken("<=",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_LE)
	T_GE				= MakeToken(">=",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_GE)
	T_NEQ				= MakeToken("!=",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NEQ)
	T_NNE				= MakeToken("!<>",  $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NNE)
	T_NLT				= MakeToken("!<",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NLT)
	T_NGT				= MakeToken("!>",   $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NGT)
	T_NLE				= MakeToken("!<=",  $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NLE)
	T_NGE				= MakeToken("!>=",  $$KIND_BINARY_OPS, $$COP2 OR $$PREC_NGE)
'
' *****  Shift  *****
'
	T_RSHIFT		= MakeToken(">>",   $$KIND_BINARY_OPS, $$COP7 OR $$PREC_RSHIFT)
	T_LSHIFT		= MakeToken("<<",   $$KIND_BINARY_OPS, $$COP7 OR $$PREC_LSHIFT)
	T_DSHIFT		= MakeToken(">>>",  $$KIND_BINARY_OPS, $$COP7 OR $$PREC_DSHIFT)
	T_USHIFT		= MakeToken("<<<",  $$KIND_BINARY_OPS, $$COP7 OR $$PREC_USHIFT)
'
' *****  Arithmetic  *****
'
	T_SUBTRACT	= MakeToken("-",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_SUBTRACT)
	T_ADD				= MakeToken("+",		$$KIND_BINARY_OPS, $$COP5 OR $$PREC_ADD)
	T_IDIV			= MakeToken("\\",		$$KIND_BINARY_OPS, $$COP6 OR $$PREC_IDIV)	' xx6n
	T_MUL				= MakeToken("*",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_MUL)
	T_DIV				= MakeToken("/",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_DIV)
	T_POWER			= MakeToken("**",		$$KIND_BINARY_OPS, $$COP4 OR $$PREC_POWER)
	T_PLUS			= MakeToken("+",		$$KIND_UNARY_OPS,  $$COP8 OR $$PREC_UNARY)
	T_MINUS			= MakeToken("-",		$$KIND_UNARY_OPS,  $$COP8 OR $$PREC_UNARY)
'
' *****  Address  *****
'
	T_ADDR_OP		= MakeToken("&",		$$KIND_ADDR_OPS,		$$COPB OR $$PREC_ADDR_OP)
	T_HANDLE_OP	= MakeToken("&&",		$$KIND_ADDR_OPS,		$$COPB OR $$PREC_HANDLE_OP)
	T_STORE_OP	= MakeToken("",			$$KIND_ADDR_OPS,		$$COPB OR $$PREC_STORE_OP)
'
' *****  Symbols  *****
'
	T_LPAREN		= MakeToken("(",    $$KIND_LPARENS,			0)
	T_RPAREN		= MakeToken(")",    $$KIND_RPARENS,			0)
	T_COMMA			= MakeToken(",",    $$KIND_SEPARATORS,	0)
	T_SEMI			= MakeToken(";",    $$KIND_SEPARATORS,	0)
	T_COLON			= MakeToken(":",    $$KIND_TERMINATORS,	0)
	T_REM				= MakeToken("'",    $$KIND_COMMENTS,		0)
	T_PERCENT		= MakeToken("%",    $$KIND_CHARACTERS,	0)
	T_XMARK			= MakeToken("!",    $$KIND_CHARACTERS,	0)
	T_ATSIGN		= MakeToken("@",    $$KIND_CHARACTERS,	0)
	T_POUND			= MakeToken("#",    $$KIND_CHARACTERS,	0)
	T_DOLLAR		= MakeToken("$",    $$KIND_CHARACTERS,	0)
	T_DQUOTE		= MakeToken("\"",   $$KIND_CHARACTERS,	0)
	T_DOT				= MakeToken(".",    $$KIND_CHARACTERS,	0)
	T_LBRAK			= MakeToken("[",    $$KIND_LPARENS,			0)
	T_RBRAK			= MakeToken("]",    $$KIND_RPARENS,			0)
	T_LBRACE		= MakeToken("{",    $$KIND_LPARENS,			0)
	T_RBRACE		= MakeToken("}",    $$KIND_RPARENS,			0)
	T_LBRACES		= MakeToken("{{",   $$KIND_LPARENS,			0)
	T_ULINE			= MakeToken("_",    $$KIND_CHARACTERS,	0)
	T_QMARK			= MakeToken("?",    $$KIND_CHARACTERS,	0)
	T_TICK			= MakeToken("`",    $$KIND_CHARACTERS,	0)
	T_MARK			= MakeToken("\x7F", $$KIND_CHARACTERS,	0)
	T_ETC				= MakeToken("...",  $$KIND_CHARACTERS,	$$ETC)
	T_CMP				= MakeToken("::",   $$KIND_BINARY_OPS,	$$COP2 OR $$PREC_EQ)
	alphaLast[27] = tab_sys_ptr - 1
'
'
' *****************************************************************************
' *****  Load array charToken[] with tokens that stand for one character  *****
' *****************************************************************************
'
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
'
'
' *****  DefineSystemConstants  *****				' Don't change spaces in strings
'
SUB DefineSystemConstants
	t = Tok ("\"\"",		0x0C730000, $$KIND_SYSCONS, $$IMM16,  0, "0")
	t = Tok ("$$TRUE",	0x0C680000, $$KIND_SYSCONS, $$NEG16, -1, "-1")
	t = Tok ("$$FALSE", 0x0C680000, $$KIND_SYSCONS, $$IMM16,  0, "0")
	falseToken = t
'
	tn = t{$$NUMBER}
	pastSystemSymbols = tn + 1
END SUB
'
'
' *****  ERRORS  *****
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ####################
' #####  Top ()  #####
' ####################
'
FUNCTION  Top ()
	SHARED	a0,  a1,  toes
'
	IF a0 AND (a0 = toes) THEN RETURN ($$R10)
	IF a1 AND (a1 = toes) THEN RETURN ($$R12)
	RETURN (0)
END FUNCTION
'
'
' #######################
' #####  Topax1 ()  #####
' #######################
'
FUNCTION  Topax1 ()
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toes,  toms,  a0,  a0_type,  a1,  a1_type
	SHARED	stackType[]
'
	SELECT CASE TRUE
		CASE (a0 AND (a0 = toes))
			DEC toes: a0 = 0: a0_type = 0: RETURN ($$R10)
		CASE (a1 AND (a1 = toes))
			DEC toes: a1 = 0: a1_type = 0: RETURN ($$R12)
		CASE ELSE
			IFZ toes THEN PRINT "Topax1a": GOTO eeeCompiler
			IFZ toms THEN PRINT "Topax1b": GOTO eeeCompiler
			Pop ($$RA0, stackType[toms-1])
			a0 = 0:	a0_type = 0
			RETURN ($$RA0)
	END SELECT
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #######################
' #####  Topax2 ()  #####
' #######################
'
FUNCTION  Topax2 (topa, topb)
	SHARED	stackType[]
	SHARED	XERROR,  ERROR_COMPILER
	SHARED	toms,  toes,  a0,  a0_type,  a1,  a1_type
'
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
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ########################
' #####  Topaccs ()  #####
' ########################
'
FUNCTION  Topaccs (topa, topb)
	SHARED	stackType[]
	SHARED	toms,  toes,  a0,  a0_type,  a1,  a1_type
	SHARED	XERROR,  ERROR_COMPILER
'
	SELECT CASE TRUE
		CASE (a0 AND (a0 = toes))
			topa = $$R10
			IF (toes > 1) THEN
				topb = $$R12
				IFZ a1 THEN
					IFZ toms THEN GOTO eeeCompiler
					Pop ($$RA1, stackType[toms-1])
					a1 = toes - 1
				END IF
			ELSE
				topb = 0
			END IF
			RETURN ($$R10)
		CASE (a1 AND (a1 = toes))
			topa = $$R12
			IF (toes > 1) THEN
				topb = $$R10
				IFZ a0 THEN
					IFZ toms THEN GOTO eeeCompiler
					Pop ($$RA0, stackType[toms-1])
					a0 = toes - 1
				END IF
			ELSE
				topb = 0
			END IF
			RETURN ($$R12)
		CASE ELSE
			topa = 0
			topb = 0
	END SELECT
	RETURN (topa)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' #####################
' #####  Topx ()  #####
' #####################
'
FUNCTION  Topx (tr, trx, nr, nrx)
	SHARED	a0,  a1,  toes
'
	IFZ toes THEN
		tr = 0: trx = 0:
		nr = 0: nrx = 0
		RETURN (0)
	END IF
	IF (a0 AND (a0 = toes)) THEN
		tr = $$R10: trx = $$R11
		IF (a1 AND (a1 = toes - 1)) THEN
			nr = $$R12: nrx = $$R13
		ELSE
			nr = 0: nrx = 0
		END IF
		RETURN ($$R10)
	END IF
	IF (a1 AND (a1 = toes)) THEN
		tr = $$R12: trx = $$R13
		IF (a0 AND (a0 = toes - 1)) THEN
			nr = $$R10: nrx = $$R11
		ELSE
			nr = 0: nrx = 0
		END IF
		RETURN ($$R12)
	END IF
	RETURN (0)
END FUNCTION
'
'
' ##########################
' #####  TypeToken ()  #####
' ##########################
'
FUNCTION  TypeToken (token)
	SHARED	T_VOID,  T_SBYTE,  T_UBYTE,  T_SSHORT,  T_USHORT
	SHARED	T_SLONG,  T_ULONG,  T_XLONG,  T_GOADDR,  T_SUBADDR,  T_FUNCADDR
	SHARED	T_SINGLE,  T_DOUBLE,  T_GIANT,  T_STRING
'
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
	END SELECT
	RETURN (return)
END FUNCTION
'
'
' ##############################
' #####  TypenameToken ()  #####
' ##############################
'
FUNCTION  TypenameToken (token)
	SHARED	T_VOID,  T_ETC,  T_SBYTE,  T_UBYTE,  T_SSHORT,  T_USHORT
	SHARED	T_SLONG,  T_ULONG,  T_XLONG,  T_GOADDR,  T_SUBADDR,  T_FUNCADDR
	SHARED	T_GIANT,  T_SINGLE,  T_DOUBLE,  T_STRING
'
	IF (token{$$KIND} = $$KIND_TYPES) THEN		' *****  USER DEFINED TYPE  *****
		dataType = token{$$NUMBER}
		token = NextToken ()
		RETURN (dataType)
	END IF
	SELECT CASE token
		CASE T_VOID, T_ETC,  T_SBYTE, T_UBYTE, T_SSHORT, T_USHORT
		CASE T_SLONG, T_ULONG, T_XLONG, T_GOADDR, T_SUBADDR, T_FUNCADDR
		CASE T_SINGLE, T_DOUBLE, T_GIANT, T_STRING
		CASE ELSE:		RETURN (0)
	END SELECT
	dataType = token{$$TYPE}
	token = NextToken ()
	RETURN (dataType)
END FUNCTION
'
'
' ####################
' #####  Uop ()  #####
' ####################
'
FUNCTION  Uop (rad, the_op, rax, d_type, o_type, x_type)
	EXTERNAL /xxx/	i486asm,  i486bin,  xpc
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
'
	IFZ opToken[] THEN GOSUB LoadOpToken
'
	SELECT CASE rad
		CASE $$RA0:	d_reg = $$RA0:	a0_type = d_type
		CASE $$RA1:	d_reg = $$RA1:	a1_type = d_type
		CASE ELSE:	PRINT "uop1": GOTO eeeCompiler
	END SELECT
	d_regx = d_reg + 1
'
	SELECT CASE rax
		CASE $$RA0:	x_reg = $$RA0: IF (d_reg != x_reg) THEN GOTO eeeCompiler
		CASE $$RA1:	x_reg = $$RA1: IF (d_reg != x_reg) THEN GOTO eeeCompiler
		CASE ELSE:	GOTO eeeCompiler
	END SELECT
	x_regx = x_reg + 1
'
'
' ************************************************************
' *****  DISPATCH TO APPROPRIATE UNARY OPERATOR ROUTINE  *****
' ************************************************************
'
	GOTO @opToken [the_op AND 0x00FF]
	PRINT "uop dispatch"
	GOTO eeeCompiler
'
'
' *************************
' *****  LOGICAL NOT  *****
' *************************
'
unary_not:
	SELECT CASE o_type
		CASE $$SLONG:		GOSUB Logical_Not_LONG
		CASE $$ULONG:		GOSUB Logical_Not_LONG
		CASE $$XLONG:		GOSUB Logical_Not_LONG
		CASE $$GIANT:		GOSUB Logical_Not_GIANT
		CASE $$SINGLE:	GOSUB Logical_Not_DOUBLE
		CASE $$DOUBLE:	GOSUB Logical_Not_DOUBLE
		CASE ELSE:			PRINT "uuu4a": GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN
'
SUB Logical_Not_LONG
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1084")
	Code ($$cmc, 0, 0, 0, 0, 0, "", @"### 1085")
	Code ($$rcr, $$regimm, x_reg, 1, 0, $$XLONG, "", @"### 1086")
	Code ($$sar, $$regimm, x_reg, 31, 0, $$XLONG, "", @"### 1087")
END SUB
'
SUB Logical_Not_GIANT
	Code ($$or, $$regreg, x_reg, x_regx, 0, $$XLONG, "", @"### 1088")
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1089")
	Code ($$cmc, 0, 0, 0, 0, 0, "", @"### 1090")
	Code ($$rcr, $$regimm, x_reg, 1, 0, $$XLONG, "", @"### 1091")
	Code ($$sar, $$regimm, x_reg, 31, 0, $$XLONG, "", @"### 1092")
END SUB
'
SUB Logical_Not_DOUBLE
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, "", "### 1093")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", @"### 1094")
	Code ($$mov, $$regimm, d_reg, -1, 0, $$XLONG, "", @"### 1095")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 1096")
	Code ($$sahf, 0, 0, 0, 0, 0, "", @"### 1097")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 1098")
	Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 1099")
	EmitLabel (@d1$)
END SUB
'
'
' **************************
' *****  LOGICAL TEST  *****
' **************************
'
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
'
SUB Logical_Test_LONG
	Code ($$neg, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 1100")
	Code ($$rcr, $$regimm, d_reg, 1, 0, $$XLONG, "", @"### 1101")
	Code ($$sar, $$regimm, d_reg, 31, 0, $$XLONG, "", @"### 1102")
END SUB
'
SUB Logical_Test_GIANT
	Code ($$or, $$regreg, d_reg, x_regx, 0, $$XLONG, "", @"### 1103")
	Code ($$neg, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 1104")
	Code ($$rcr, $$regimm, d_reg, 1, 0, $$XLONG, "", @"### 1105")
	Code ($$sar, $$regimm, d_reg, 31, 0, $$XLONG, "", @"### 1106")
END SUB
'
SUB Logical_Test_DOUBLE
	INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
	Code ($$fldz, $$none, 0, 0, 0, $$DOUBLE, "", "### 1107")
	Code ($$fcompp, $$none, 0, 0, 0, $$DOUBLE, "", @"### 1108")
	Code ($$xor, $$regreg, d_reg, d_reg, 0, $$XLONG, "", @"### 1109")
	Code ($$fstsw, $$reg, $$ax, 0, 0, $$XLONG, "", @"### 1110")
	Code ($$sahf, 0, 0, 0, 0, 0, "", @"### 1111")
	Code ($$jz, $$rel, 0, 0, 0, 0, d1$, @"### 1112")
	Code ($$not, $$reg, d_reg, 0, 0, $$XLONG, "", @"### 1113")
	EmitLabel (@d1$)
END SUB
'
'
' ************************
' *****  UNARY PLUS  *****
' ************************
'
unary_plus:
	the_op = 0
	RETURN
'
'
' *************************
' *****  UNARY MINUS  *****
' *************************
'
unary_minus:
	SELECT CASE o_type
		CASE $$SLONG:		GOSUB Unary_Minus_SLONG
		CASE $$XLONG:		GOSUB Unary_Minus_XLONG
		CASE $$GIANT:		GOSUB Unary_Minus_GIANT
		CASE $$SINGLE:	GOSUB Unary_Minus_SINGLE
		CASE $$DOUBLE:	GOSUB Unary_Minus_DOUBLE
		CASE $$ULONG:		GOTO  eeeNegULONG
		CASE ELSE:			PRINT "uuu4":	GOTO eeeCompiler
	END SELECT
	the_op = 0
	RETURN
'
SUB Unary_Minus_SLONG
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1114")
END SUB
'
SUB Unary_Minus_XLONG
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1115")
END SUB
'
SUB Unary_Minus_GIANT
	Code ($$neg, $$reg, x_regx, 0, 0, $$XLONG, "", @"### 1116")
	Code ($$neg, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1117")
	Code ($$sbb, $$regimm, x_regx, 0, 0, $$XLONG, "", @"### 1118")
END SUB
'
SUB Unary_Minus_SINGLE
	Code ($$fchs, 0, 0, 0, 0, $$DOUBLE, "", @"### 1119")
END SUB
'
SUB Unary_Minus_DOUBLE
	Code ($$fchs, 0, 0, 0, 0, $$DOUBLE, "", @"### 1120")
END SUB
'
'
' *************************
' *****  BITWISE NOT  *****
' *************************
'
unary_notbit:
	SELECT CASE o_type
		CASE $$GIANT:		GOSUB Notbit_GIANT
		CASE $$SINGLE:	DEC tokenPtr: GOTO eeeTypeMismatch
		CASE $$DOUBLE:	DEC tokenPtr: GOTO eeeTypeMismatch
		CASE ELSE:			GOSUB Notbit_LONG
	END SELECT
	the_op = 0
	RETURN
'
SUB Notbit_LONG
	Code ($$not, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1121")
END SUB
'
SUB Notbit_GIANT
	Code ($$not, $$reg, x_reg, 0, 0, $$XLONG, "", @"### 1122")
	Code ($$not, $$reg, x_regx, 0, 0, $$XLONG, "", @"### 1123")
END SUB
'
'
' ************************************************
' *****  Load UNARY OPERATOR dispatch array  *****
' ************************************************
'
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
'
'
' **************************
' *****  UNARY ERRORS  *****
' **************************
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeNegULONG:
	XERROR = ERROR_NEG_ULONG
	EXIT FUNCTION
'
eeeTypeMismatch:
	XERROR = ERROR_TYPE_MISMATCH
	EXIT FUNCTION
END FUNCTION
'
'
' ############################
' #####  UpdateToken ()  #####
' ############################
'
FUNCTION  UpdateToken (token)
	SHARED	tab_sym[]
'
	x = token{$$NUMBER}
	tab_sym[x] = token
END FUNCTION
'
'
' ######################
' #####  Value ()  #####
' ######################
'
' Value() returns the address of the specified label$.  If the address of
' the specified label$ has not been defined, a zero is returned and the
' patch table arrays are updated to have the current xpc location updated
' with the label$ address on the final pass.  When Value() is called, xpc
' must point to the location in memory where the address is to be stored,
' not the location of the first byte of the instruction that it's a part of.
'
' addrmode is $$VALUEABS or $$VALUEDISP, according to whether the number
' to be stored in memory is the absolute value of label$ or a relative offset
' (displacement) from label$.
'
FUNCTION  Value (label$, addrmode)
	EXTERNAL /xxx/  xpc
	SHARED	labaddr[],  patchType[],  patchAddr[],  patchDest[]
	SHARED	XERROR,  ERROR_COMPILER,  patchPtr,  upatch
'
	IFF label$ THEN
		PRINT "Null label$ sent to Value()": GOTO eeeCompiler
	END IF
	token = AddLabel (@label$, $$T_LABELS, $$XADD)
	IF XERROR THEN EXIT FUNCTION
	IF token THEN
		tt = token AND 0x0000FFFF
		vv = labaddr[tt]
		IF vv THEN
			value = vv
		ELSE
			IF (patchPtr >= upatch) THEN
				upatch = upatch + upatch
				REDIM patchType[upatch]
				REDIM patchAddr[upatch]
				REDIM patchDest[upatch]
			END IF
			patchType[patchPtr] = addrmode
			patchAddr[patchPtr] = xpc
			patchDest[patchPtr] = token
			INC patchPtr
			value = 0
		END IF
	ELSE
		PRINT "v"
		GOTO eeeCompiler
	END IF
	RETURN (value)
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ##################################
' #####  WriteDeclarationFile  #####
' ##################################
'
FUNCTION  WriteDeclarationFile (string$)
	EXTERNAL  /xxx/  i486asm,  i486bin,  library
	SHARED  declareCount
	SHARED  declare$[]
'
	IFZ i486asm THEN RETURN
	IFZ string$ THEN RETURN
'
' put string$ in declare$[] that will become "prog.dec" file
'
	upper = UBOUND (declare$[])
	IF (declareCount > upper) THEN
		upper = upper + 64
		REDIM declare$[upper]
	END IF
'
	declare$[declareCount] = string$
	INC declareCount
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' #################################
' #####  WriteDefinitionFile  #####
' #################################
'
FUNCTION  WriteDefinitionFile (string$)
	EXTERNAL  /xxx/  i486asm,  i486bin,  library
	SHARED  export$[]
	SHARED  import$[]
	SHARED  exportCount
	SHARED  importCount
'
	IFZ i486asm THEN RETURN
	IFZ string$ THEN RETURN
'
	export = INSTR (string$, "EXPORT")
	IF (export = 1) THEN
		upper = UBOUND (export$[])
		IF (exportCount > upper) THEN
			upper = upper + 64
			REDIM export$[upper]
		END IF
		export$[exportCount] = string$
		INC exportCount
		RETURN
	END IF
'
	import = INSTR (string$, "IMPORT")
	IF (import = 1) THEN
		upper = UBOUND (import$[])
		IF (importCount > upper) THEN
			upper = upper + 64
			REDIM import$[upper]
		END IF
		import$[importCount] = string$
		INC importCount
		RETURN
	END IF
'
	PRINT "WriteDefinitionFile() : error : string does not start with EXPORT or IMPORT : "; string$
END FUNCTION
'
'
' ##################################
' #####  XxxXBasicVersion$ ()  #####
' ##################################
'
FUNCTION  XxxXBasicVersion$ ()
	version$ = VERSION$ (0)
	RETURN (version$)
END FUNCTION
'
'
' #############################
' #####  XxxCheckLine ()  #####
' #############################
'
FUNCTION  XxxCheckLine (lineNum, tok[])
	SHARED	XERROR,  tokenCount,  lineNumber,  tokens[]
	SHARED	pass2errors,  ERROR_UNDEFINED
'
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
'
'
' #####################################
' #####  XxxCloseCompileFiles ()  #####
' #####################################
'
FUNCTION  XxxCloseCompileFiles ()
	EXTERNAL  /xxx/  i486asm,  i486bin,  library
	SHARED  ofile
	SHARED  asmFile$
	SHARED  version$
	SHARED  program$
	SHARED  programName$
	SHARED  programPath$
	SHARED  export$[]
	SHARED  import$[]
	SHARED  declare$[]
	SHARED  exportCount
	SHARED  importCount
	SHARED  declareCount
	SHARED	export
'
	p$ = programPath$																		' has path and filename
	IF (RIGHT$(p$,2) = ".x") THEN p$ = RCLIP$(p$,2)			' remove ".x" suffix
	IFZ p$ THEN p$ = program$
	IFZ p$ THEN p$ = "NoName"
'
' close the "prog.s" file
'
	IF (ofile > 2) THEN CLOSE (ofile)
	asmFile$ = ""
	ofile = 0
'
' save "prog.dec" file if declare$[] has contents
'
	IF declareCount THEN
		file$ = p$ + ".dec"
		REDIM declare$[declareCount]
		XstSaveStringArray (@file$, @declare$[])
	END IF
	DIM declare$[]
	declareCount = 0
'
' save "prog.def" file if export$[] or import$[] has contents
'
	IF (exportCount OR importCount) THEN
		IF library THEN
			prog$ = "LIBRARY  " + p$
		ELSE
			prog$ = "PROGRAM  " + p$
		END IF
'
		vers$ = version$
		IFZ vers$ THEN vers$ = "0.0000"
		vers$ = "VERSION  " + vers$
'
		upper = exportCount + importCount + 2
		DIM def$[upper]
		def$[0] = prog$
		def$[1] = vers$
'
		REDIM export$[exportCount-1]
		REDIM import$[importCount-1]
		XstQuickSort (@export$[], @n[], 0, exportCount-1, 0)
		XstQuickSort (@import$[], @n[], 0, importCount-1, 0)
'
		def = 2
		FOR i = 0 TO exportCount-1
			def$[def] = export$[i]
			INC def
		NEXT i
'
		FOR i = 0 TO importCount-1
			def$[def] = import$[i]
			INC def
		NEXT i
'
		file$ = p$ + ".def"
		XstSaveStringArray (@file$, @def$[])
	END IF
'
	export = 0
	exportCount = 0
	importCount = 0
	DIM export$[]
	DIM import$[]
END FUNCTION
'
'
' ###############################
' #####  XxxCompilePrep ()  #####
' ###############################
'
FUNCTION  XxxCompilePrep ()
	EXTERNAL /xxx/	maxFuncNumber
	SHARED	funcToken[],  funcKind[],  labaddr[],  tab_sym[],  tab_sym$[]
	SHARED	r_addr[],  r_addr$[],  m_reg[],  m_addr[],  m_addr$[]
	SHARED	tabType[],  patchType[],  patchAddr[],  patchDest[]
	SHARED	tabArg[]
	SHARED	pastSystemLabels,  pastSystemSymbols,  oos
	SHARED	tab_sym_ptr,  upatch,  ulabel,  typePtr,  uFunc, uType
	SHARED	compositeNumber[]
	SHARED	compositeToken[]
	SHARED	compositeStart[]
	SHARED	compositeNext[]
	SHARED	typeSize$[]
	SHARED	typeAlias[]
	SHARED	typeAlign[]
	SHARED	typeSize[]
	SHARED	typeEleCount[]
	SHARED	typeEleSymbol$[]
	SHARED	typeEleToken[]
	SHARED	typeEleAddr[]
	SHARED	typeEleSize[]
	SHARED	typeEleType[]
	SHARED	typeEleArg[]
	SHARED	typeEleVal[]
	SHARED	typeElePtr[]
	SHARED	typeEleStringSize[]
	SHARED	typeEleUBound[]
	SHARED	hash%[]
'
	oos = 0
	DIM compositeNumber[uFunc]
	DIM compositeToken[uFunc, ]
	DIM compositeStart[uFunc, ]
	DIM compositeNext[uFunc, ]
'
'
' *****  Clear type information for types > DCOMPLEX  (all user-types)
'
	i = $$DCOMPLEX + 1
	DO WHILE (i <= uType)
		typeSize$[i]		= ""
		typeAlias[i]		=  0
		typeAlign[i]		=  0
		typeSize[i]			=  0
		typeEleCount[i]	=  0
		ATTACH typeEleSymbol$[i, ] TO temp$[]:		DIM temp$[]
		ATTACH typeEleToken[i, ] TO temp[]:				DIM temp[]
		ATTACH typeEleAddr[i, ] TO temp[]:				DIM temp[]
		ATTACH typeEleSize[i, ] TO temp[]:				DIM	temp[]
		ATTACH typeEleType[i, ] TO temp[]:				DIM temp[]
		ATTACH typeEleArg[i, ] TO temp[]:					DIM temp[]
		ATTACH typeEleVal[i, ] TO temp[]:					DIM temp[]
		ATTACH typeElePtr[i, ] TO temp[]:					DIM temp[]
		ATTACH typeEleStringSize[i, ] TO temp[]:	DIM temp[]
		ATTACH typeEleUBound[i, ] TO temp[]:			DIM temp[]
		INC i
	LOOP
'
' *****  Clear CFUNCTION, DECLARED, DEFINED bits in all function tokens
'
	i = 1
	DO
		funcToken[i]	= funcToken[i] AND NOT $$MASK_ALLO
		funcKind[i]		= $$FALSE
		INC i
	LOOP WHILE (i <= maxFuncNumber)
'
' *****  Clear all label addresses
'
	i = pastSystemLabels
	DO
		labaddr[i]	= 0
		INC i
	LOOP WHILE (i <= ulabel)
'
' *****  Clear variable allocation addresses, allo/type fields, etc...
'
	utoken = tab_sym_ptr
	i = pastSystemSymbols
	DO
		r_addr[i]			= 0
		r_addr$[i]		= ""
		m_reg[i]			= 0
		m_addr[i]			= 0
		m_addr$[i]		= ""
		tabType[i]		= 0
		token					= tab_sym[i]
		kind					= token{$$KIND}
		ATTACH tabArg[i, ] TO temp[]: DIM temp[]
		SELECT CASE kind
			CASE $$KIND_VARIABLES, $$KIND_ARRAYS
'
' 2000/12/30
'
						IF tab_sym$[i] THEN
							IF (tab_sym$[i]{0} != '#') THEN tab_sym[i] = CLR (token, $$ALLO)
						END IF
			CASE $$KIND_SYSCONS, $$KIND_CONSTANTS
						tab_sym[i]	= CLR (token, $$TYPE)
		END SELECT
		INC i
	LOOP WHILE (i <= utoken)
'
' *****  Clear patch arrays
'
	i = 0
	DO
		patchType[i] = 0
		patchAddr[i] = 0
		patchDest[i] = 0
		INC i
	LOOP WHILE (i <= upatch)
END FUNCTION
'
'
' ######################################
' #####  XxxCreateCompileFiles ()  #####
' ######################################
'
FUNCTION  XxxCreateCompileFiles ()
	EXTERNAL  /xxx/  i486asm,  i486bin
	SHARED  ofile
	SHARED  asmFile$
	SHARED	programName$
	SHARED  programPath$
	SHARED	XERROR,  ERROR_OPEN_FILE,  ERROR_PROGRAM_NOT_NAMED
'
	IFZ i486asm THEN PRINT "a" : RETURN
	IF (ofile > 0) THEN PRINT "b" : RETURN
	IFZ programName$ THEN GOTO eeeProgramNotNamed
	IFZ programPath$ THEN GOTO eeeProgramNotNamed
	IF (RIGHT$(programPath$,2) != ".x") THEN GOTO eeeProgramNotNamed
'
	pathname$ = programPath$
	XstDecomposePathname (@pathname$, @oldpath$, @parent$, @filename$, @file$, @extent$)
	oldfile$ = oldpath$ + $$PathSlash$ + filename$			' original full path filename$
	XstGetFileAttributes (@oldfile$, @attr)							' original filename attributes
	GOSUB OldWay																				' puts stuff in source file directory
'
'	GOSUB NewWay																				' creates project directory
'	GOSUB Backup																				' backup source file
'
' open assembly file
'
	programPath$ = newpath$ + $$PathSlash$ + filename$
	asmFile$ = newpath$ + $$PathSlash$ + file$ + ".s"
	ofile = OPEN (asmFile$, $$WRNEW)
	IF (ofile < 0) THEN ofile = 0 : GOTO eeeOpenFile
	RETURN
'
'
' *****  OldWay  *****
'
SUB OldWay
	newpath$ = oldpath$
END SUB
'
'
' *****  NewWay  *****
'
SUB NewWay
	IF (parent$ = file$) THEN														' prog.x file is in a project directory
		newpath$ = oldpath$																' so newpath$ = oldpath$
		oldfile$ = newpath$ + $$PathSlash$ + filename$		' and oldfile$ = oldpath$ + filename$
		newfile$ = newpath$ + $$PathSlash$ + filename$		' and newfile$ = oldpath$ + filename$
	ELSE																								' prog.x file not in a project directory
		newpath$ = oldpath$ + $$PathSlash$ + file$				' newpath$ is project directory name
		XstGetFileAttributes (@newpath$, @pattr)					' does newpath$ exist?  if so what is it?
		IFZ (pattr AND $$FileDirectory) THEN							' no newpath$ directory
			XstMakeDirectory (@newpath$)										' so create newpath$ directory
			XstGetFileAttributes (@newpath$, @pattr)				' make sure newpath$ now exists
			IFZ (pattr AND $$FileDirectory) THEN						' didn't create newpath$ directory
				XstGetFileAttributes (@oldpath$, @pattr)			' make sure current path$ is a directory
				newpath$ = oldpath$														' give up - settle for current path$
			END IF
		END IF
'
' newpath$ better be a directory at this point else resort to current directory
'
		IFZ (pattr AND $$FileDirectory) THEN							' if newpath$ is a directory
			XstGetCurrentDirectory (@newpath$)							' newpath$ = current directory
			XstGetFileAttributes (@newpath$, @pattr)				' make sure newpath$ exists
		END IF
	END IF
END SUB
'
'
' *****  Backup  *****  backup previous newfile$ or make copy of oldfile$
'
SUB Backup
	newfile$ = newpath$ + $$PathSlash$ + filename$		' newfile$ is filename in newpath$
	XstGetFileAttributes (@newfile$, @fattr)					' does newfile$ exist?
	IFZ fattr THEN																		' newfile$ does not exist in project directory
		IF attr THEN																		' if oldfile$ exists
			XstCopyFile (@oldfile$, @newfile$)						' create newfile$
		END IF
	END IF
'
	XstGetFileAttributes (@newfile$, @fattr)					' does newfile$ exist?
	IFZ fattr THEN																		'
		IF attr THEN
			XstCopyFile (oldfile$, newfile$)							' make backup copy of oldfile
		END IF
	ELSE																							' backup existing newfile$
		checkfile$ = newfile$ + "??"										' look for all backups of newfile$
		XstGetFiles (@checkfile$, @file$[])							' get names of previous versions
		IFZ file$[] THEN																' if no previous versions exist
			backfile$ = newfile$ + "00"										' start backup filenames at ".x00"
		ELSE
			upper = UBOUND (file$[])											' upper bound of previous versions array
			XstQuickSort (@file$[], @n[], 0, upper, 0)		' in alphabetical order
			backfile$ = newpath$ + $$PathSlash$ + file$[upper]	' get previous backup filename
			IF (RIGHT$(backfile$,2) = ".x") THEN					' no backups filenames yet
				backfile$ = backfile$ + "00"								' start backup filenames at ".x00"
			ELSE
				u = UBOUND (backfile$)											' offset to last character in backfile$
				z = backfile${u}														' last character in backfile$ version
				y = backfile${u-1}													' last-1 character in backfile$ version
				x = backfile${u-2}													' last-2 character in backfile$ version
				d = backfile${u-3}													' last-3 character in backfile$ version
				IF (x != 'x') THEN PRINT "x yipes, stripes"	' last-2 must be an 'x' character !!!
				IF (d != '.') THEN PRINT ". yipes, stripes"	' last-3 must be a '.' character !!!
				SELECT CASE z
					CASE '9'	: z = 'A'
					CASE 'Z'	: z = '0'
					CASE ELSE	: INC z
				END SELECT
				IF (z = '0') THEN
					SELECT CASE y
						CASE '9'	: y = 'A'
						CASE 'Z'	: y = '0'
						CASE ELSE	: INC y
					END SELECT
					IF (y = '0') THEN
						SELECT CASE x
							CASE 'x'	: x = 'y'
							CASE ELSE	: PRINT "version overflow - readjust version numbers"
						END SELECT
					END IF
				END IF
				backfile${u} = z
				backfile${u-1} = y
				backfile${u-2} = x
				IF (x != 'x') THEN PRINT "DANGER : out of new backup version #s : "; backfile$
			END IF
		END IF
		XstCopyFile (@newfile$, @backfile$)							' back up previous newfile$
	END IF
'
' now that newfile$ is backed up, copy oldfile$ to newfile$
'
	IF attr THEN
		IF (oldfile$ != newfile$) THEN									'
			XstCopyFile (@oldfile$, newfile$)
		END IF
	END IF
END SUB
'
'
' *****  Errors  *****
'
eeeOpenFile:
	XERROR = ERROR_OPEN_FILE
	RETURN ($$T_STARTS)
'
eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' ##################################
' #####  XxxDeleteFunction ()  #####
' ##################################
'
FUNCTION  XxxDeleteFunction (funcNumber)
	SHARED	funcLabel$[],  funcToken[],  funcKind[],  funcType[],  funcScope[]
	SHARED	funcArg[]
'
	funcKind[funcNumber]			= 0
	funcType[funcNumber]			= 0
	funcScope[funcNumber]			= 0
	funcLabel$[funcNumber]		= ""
	funcToken[funcNumber]			= CLR (funcToken[funcNumber], $$ALLO)
	ATTACH funcArg[funcNumber, ] TO temp[]
	DIM temp[]
END FUNCTION
'
'
' ###################################
' #####  XxxDeparseFunction ()  #####
' ###################################
'
FUNCTION  XxxDeparseFunction (func$, func[], lastLine, flags)
	SHARED	funcSymbol$[],  tab_lab$[],  tab_sym$[],  tab_sys$[]
	SHARED	typeSymbol$[]
	SHARED	XERROR,  ERROR_COMPILER
	STATIC SUBADDR kindDeparse[]

	IFZ kindDeparse[] THEN GOSUB LoadKindDeparse
	IFZ func[] THEN func$ = "": RETURN
	IF (lastLine > UBOUND(func[])) THEN PRINT "DeFunc.0": GOTO eeeCompiler
'
	tokens = 0
	FOR funcLine = 0 TO lastLine
		tokens = tokens + UBOUND(func[funcLine,]) + 1
	NEXT funcLine
	funcSize	= tokens * 8 + 256					' about twice the average size needed
	IF (funcSize < 511) THEN funcSize = 511		' minimum size = 511 characters
	funcTerm = funcSize - 256
	func$ = NULL$(funcSize)								' make room to deparse function string
	funcBase = &func$											' build deparsed function string here
	offset = 0														' cumulative offset into func$
'
	FOR funcLine = 0 TO lastLine					' deparse all lines in function
		ATTACH func[funcLine, ] TO tok[]		' get tokens for this line
		IFZ tok[] THEN											' no tokens for this line
			GOSUB AppendNewline								' append newline (blank line)
			DO NEXT														' do next line of tokens
		END IF
		IF (flags AND 0x01) THEN						' clearBP_EXE
			startToken = tok[0]								' strip BP/EXE/errno from token line
			tok[0] = startToken AND 0x3FFF00FF
		END IF
		uToken	= UBOUND(tok[])							' upper bound of this line of tokens
		count		= 0													' start with 0th token
		DO WHILE (count <= uToken)					' deparse through last token
			token		= tok[count]							' get the next token
			tt			= token{$$NUMBER}					' get the token number
			kind		= token{$$KIND}						' get the token kind
			spaces	= token{{$$SPACE}}				' get the space field
			IFZ token THEN EXIT DO						' end of line
			IF (count AND (kind = $$KIND_STARTS)) THEN EXIT DO	' START tokens stop
			IF (spaces >= 0) THEN
				whiteChar = 32									' spaces (not tabs)
			ELSE
				whiteChar = 9										' tabs (not spaces)
				spaces = -spaces
			END IF
			IF (offset >= funcTerm) THEN			' need more space in function string
				expand = funcSize								' double function string size
				GOSUB ExpandFuncString
			END IF
			done		= $$FALSE									' not done this line of tokens yet
			GOSUB @kindDeparse [kind]					' deparse this kind of token
			INC count													' next token on this line
		LOOP UNTIL done
		IF (flags AND 0x01) THEN tok[0] = startToken	' clearBP_EXE : restore startToken
		ATTACH tok[] TO func[funcLine, ]		' replace line of tokens in func[]
		GOSUB AppendNewline
	NEXT funcLine
	funcLength	= offset									' funcLength
	funcHead		= &func$ - 16							' address of function string header
	XLONGAT (funcHead, [2]) = offset			' set final function string length
	RETURN (funcLength)										' return length of function string
'
'
' *****  ExpandFuncString  *****
'
SUB ExpandFuncString
	funcSize = funcSize + expand					' new maximum string size
	funcTerm = funcSize - 256							' new maximum starting point
	func$ = func$ + NULL$ (expand)				' add to function string size
	funcBase = &func$											' new address of function string
END SUB
'
'
' ****************************************************************
' *****  Subroutines to deparse different "kinds" of tokens  *****
' ****************************************************************
'
SUB SystemSymbols
	sourceAddr	= &tab_sys$[tt]
	GOSUB AppendString
	GOSUB AppendSpace
END SUB
'
SUB UserSymbols
	sourceAddr	= &tab_sym$[tt]
	GOSUB AppendString
	GOSUB AppendSpace
END SUB
'
SUB FunctionSymbols
	sourceAddr	= &funcSymbol$[tt]
	GOSUB AppendString
	GOSUB AppendSpace
END SUB
'
SUB UserLabels
	s$ = MID$(tab_lab$[tt], 4)
'	suffix = RINSTR (s$, ".")								' gas ?
	suffix = RINSTR (s$, "_")								' unspas
	s$ = LEFT$(s$, suffix - 1)
	IF (count = 1) THEN s$ = s$ + ":"
	sourceAddr	= &s$
	GOSUB AppendString
	GOSUB AppendSpace
END SUB
'
SUB SystemStarts
	errorIndex = token {$$BYTE1}										' errno is BYTE1
	IF errorIndex THEN
		errno$ = RIGHT$("000" + STRING(errorIndex), 3)
		sourceAddr = &errno$: GOSUB AppendString
	END IF
	IF EXTS(token, 1, 30) THEN sourceAddr = &">": GOSUB AppendString
	IF (token < 0) THEN sourceAddr = &":": GOSUB AppendString
	spaces = token {{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			whiteChar	= 32
		ELSE
			whiteChar	= 9
			spaces		= -spaces
		END IF
		GOSUB AppendSpace
	END IF
END SUB
'
SUB SystemWhites
	spaces = token {{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			whiteChar	= 32
		ELSE
			whiteChar	= 9
			spaces		= -spaces
		END IF
		GOSUB AppendSpace
	END IF
END SUB
'
SUB SystemComments
	charCount		= token {$$BYTE2}					' number of bytes following '
	sourceAddr	= &"'"										' address of '
	GOSUB AppendString										' append ' to function string
	IFZ charCount THEN EXIT SUB						' nothing following the '
	INC	count															' 1st token of comment text
'
	IF (charCount = 255) THEN							' charCount = 255 means ...
		charCount = tok[count]							' charCount in next 32-bit token
		INC count														' point to next token
	END IF																'
	commentAddr	= &tok[count]							' address of comment text
'
	IF (funcSize <= (offset + charCount + 16)) THEN
		expand = offset + charCount + 256
		GOSUB ExpandFuncString
	END IF
'
	FOR x = 0 TO charCount-1							' for every comment character
		n	= UBYTEAT (commentAddr)						' n = next comment character
		UBYTEAT (funcBase, offset) = n			' append character to function string
		INC commentAddr											' INC offset into comment tokens
		INC offset													' INC offset into function string
	NEXT																	' next comment character
	done = $$TRUE													' done deparsing this line
END SUB
'
SUB UserTypes
	sourceAddr	= &typeSymbol$[tt]
	GOSUB AppendString
	GOSUB AppendSpace
END SUB
'
SUB BogusToken
	PRINT "*****  DEPARSE:  BOGUS TOKEN  *****"
END SUB
'
SUB AppendString												' sourceAddr = addr of string to append
	IFZ sourceAddr THEN EXIT SUB					' null string (shouldn't happen ???)
	shead		= sourceAddr - 0x0010					' address of source string header
	scount	= XLONGAT (shead, [2])				' number of bytes to append
	IFZ scount THEN EXIT SUB							' zero length string
'
	IF (funcSize <= (offset + scount + 16)) THEN
		expand = offset + scount + 256
		GOSUB ExpandFuncString
	END IF
'
	FOR i = 0 TO scount-1									' for every character in source
		schar		= UBYTEAT (sourceAddr)			' get source character
		UBYTEAT (funcBase, offset) = schar	' append character to function string
		INC sourceAddr											' INC offset past source character
		INC offset													' INC offset past function character
	NEXT i
END SUB
'
SUB AppendSpace
	IFZ spaces THEN EXIT SUB									' no white spaces to append
	FOR i = 1 TO spaces
		UBYTEAT (funcBase, offset) = whiteChar	' append white character
		INC offset
	NEXT i
END SUB
'
SUB AppendNewline
	IF (flags AND 0x02) THEN
		UBYTEAT (funcBase, offset) = '\r'				' CRLF for WindowsNT and Win32s
		INC offset															' enable these lines for Windows
	END IF
	UBYTEAT (funcBase, offset) = '\n'
	INC offset
END SUB
'
SUB LoadKindDeparse
	DIM kindDeparse [31]
	FOR i = 0 TO 31
		kindDeparse [i] = SUBADDRESS (BogusToken)
	NEXT i
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
END SUB
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
END FUNCTION
'
'
' ############################
' #####  XxxDeparser ()  #####
' ############################
'
FUNCTION  XxxDeparser (tok[], deparsed$)
	SHARED	funcSymbol$[],  tab_lab$[],  tab_sym$[],  tab_sys$[]
	SHARED	typeSymbol$[]
	SHARED	XERROR,  ERROR_COMPILER
	STATIC SUBADDR kindDeparse[]

	IFZ kindDeparse[] THEN GOSUB LoadKindDeparse
'
	deparsed$	= ""
	topToken	= UBOUND(tok[])
	IFZ topToken THEN INC topToken				' Always do start token
	DO WHILE (tokPtr < topToken)
		token		= tok[tokPtr]
		tt			= token{$$NUMBER}
		kind		= token{$$KIND}
		spaces	= token{{$$SPACE}}
		IF (spaces >= 0) THEN
			whiteChar = 32			' spaces
		ELSE
			whiteChar = 9				' tabs
			spaces = -spaces
		END IF
		GOSUB @kindDeparse [kind]	' dispatch deparse based on kind of token
		INC tokPtr
	LOOP
	RETURN
'
'
' ****************************************************************
' *****  Subroutines to deparse different "kinds" of tokens  *****
' ****************************************************************
'
SUB SystemSymbols
	deparsed$ = deparsed$ + tab_sys$[tt] + CHR$(whiteChar, spaces)
END SUB
'
SUB UserSymbols
	deparsed$ = deparsed$ + tab_sym$[tt] + CHR$(whiteChar, spaces)
END SUB
'
SUB FunctionSymbols
	deparsed$ = deparsed$ + funcSymbol$[tt] + CHR$(whiteChar, spaces)
END SUB
'
SUB UserLabels
	s$ = MID$(tab_lab$[tt], 4)
'	suffix = RINSTR (s$, ".")								' gas ?
	suffix = RINSTR (s$, "_")								' unspas
	s$ = LEFT$(s$, suffix - 1)
	IF (tokPtr = 1) THEN s$ = s$ + ":"
	deparsed$ = deparsed$ + s$ + CHR$(whiteChar, spaces)
END SUB
'
SUB SystemStarts
	errorIndex = token {$$BYTE1}													' errno is BYTE1
	IF errorIndex THEN
		deparsed$ = deparsed$ + RIGHT$("000" + STRING(errorIndex), 3)
	END IF
	IF token{1,30} THEN deparsed$ = deparsed$ + ">"		' $$CURRENTEXE
	IF (token < 0) THEN deparsed$ = deparsed$ + ":"			' $$BREAKPOINT
	spaces = token{{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			deparsed$ = deparsed$ + SPACE$(spaces)				' spaces
		ELSE
			deparsed$ = deparsed$ + CHR$(9, -spaces)		' tabs
		END IF
	END IF
END SUB
'
SUB SystemWhites
	spaces = token {{$$BYTE2}}
	IF spaces THEN
		IF (spaces > 0) THEN
			deparsed$ = deparsed$ + SPACE$(spaces)				' spaces
		ELSE
			deparsed$ = deparsed$ + CHR$(9, -spaces)		' tabs
		END IF
	END IF
END SUB
'
SUB SystemComments
	count  = token {$$BYTE2}
	IF (count = 255) THEN
		INC tokPtr
		count = tok[tokPtr]
	END IF
	deparsed$ = deparsed$ + "'"
	pw$ = NULL$(4)
	o = &pw$
	x = 1
	DO UNTIL (x > count)
		INC tokPtr
		token = tok[tokPtr]
		XLONGAT (o) = token
		deparsed$ = deparsed$ + pw$
		x = x + 4
	LOOP
	deparsed$ = RTRIM$(deparsed$)
END SUB
'
SUB UserTypes
	deparsed$ = deparsed$ + typeSymbol$[tt] + CHR$(whiteChar, spaces)
END SUB
'
SUB BogusToken
	PRINT "*****  DEPARSE:  BOGUS TOKEN  *****"
END SUB
'
SUB LoadKindDeparse
	DIM kindDeparse [31]
	FOR i = 0 TO 31
		kindDeparse [i] = SUBADDRESS (BogusToken)
	NEXT i
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
END SUB
END FUNCTION
'
'
' #####################################
' #####  XxxEmitXProfilerCall ()  #####
' #####################################
'
FUNCTION  XxxEmitXProfilerCall (func, line)
	Code ($$push, $$imm, line, 0, 0, $$XLONG, "", @"### 1124")
	Code ($$push, $$imm, func, 0, 0, $$XLONG, "", @"### 1125")
'	Code ($$call, $$rel, 0, 0, 0, 0, "XxxXProfilerLog$8", @"### 1126")			' gas ?
	Code ($$call, $$rel, 0, 0, 0, 0, "XxxXProfilerLog_8", @"### 1126")			' unspas
END FUNCTION
'
'
' #############################
' #####  XxxErrorInfo ()  #####
' #############################
'
'	Return error information for XIT:
'		- rawPtr = insertion pointer offset to error in RAW source line
'		- srcPtr = pointer offset to error for source line (1 = first character)
'		- srcLine = Deparsed (tab --> 2 spaces) source line
'
FUNCTION  XxxErrorInfo (err, rawPtr, srcPtr, srcLine$)
	SHARED  charpos[]
	SHARED  XERROR,  rawLength,  rawline$,  tokenPtr,  uerror
	SHARED  a0,  a0_type,  a1,  a1_type,  toes,  toms,  oos
	SHARED UBYTE oos[]
'
	IF (err <= 0) THEN PRINT "XxxErrorInfo ="; err: GOTO eeeErrorInfo
  IF (err > uerror) THEN PRINT "XxxErrorInfo ="; err: GOTO eeeErrorInfo
	rawPtr = 0
	srcPtr = 0
	srcLine$ = ""
	tp = tokenPtr
	rawline$ = Deparse$("")
	IF TRIM$(rawline$) THEN
		rawPtr = charpos[tp]									' location of error, offset 0
		i = 0
		srcPtr = -1
		rawLength = LEN(rawline$)
		DO WHILE (i < rawLength)
			INC srcPtr
			IF (rawline${i} = '\t') THEN 				' tabs (at 2) --> spaces
				IF (srcPtr AND 1) THEN						'   odd:  add 2 spaces
					INC srcPtr
					srcLine$ = srcLine$ + "  "
				ELSE
					srcLine$ = srcLine$ + " "
				END IF
			ELSE
				srcLine$ = srcLine$ + CHR$(rawline${i})
			END IF
			IF (i <= rawPtr) THEN tokenPointer = srcPtr
			INC i
		LOOP
	END IF
'
'	Trim leading spaces from srcLine$
'
	srcPtr = tokenPointer										' point to error position
	lenFatSrc = LEN(srcLine$)
	srcLine$ = LTRIM$(srcLine$)
	lenSrc = LEN(srcLine$)
	srcPtr = srcPtr - (lenFatSrc - lenSrc)
	IF (srcPtr < 0) THEN srcPtr = 0
	INC srcPtr
	ParseOutError (@token)
	XERROR	= 0
	toes		= 0
	toms		= 0
	oos			= 0
	oos[0]	= 0
	a0			= 0
	a1			= 0
	a0_type	= 0
	a1_type	= 0
	RETURN
'
eeeErrorInfo:
	XERROR = 0
	EXIT FUNCTION
END FUNCTION
'
'
' ################################
' #####  XxxFunctionName ()  #####
' ################################
'
FUNCTION	XxxFunctionName (command, funcName$, funcToken)
	SHARED	funcSymbol$[]
'
	theFuncNumber	= funcToken{$$NUMBER}
	ufunc = UBOUND(funcSymbol$[])
	SELECT CASE command
		CASE $$XGET:		SELECT CASE TRUE
											CASE ((theFuncNumber > 0) AND (theFuncNumber <= ufunc))
													funcName$ = funcSymbol$[theFuncNumber]
											CASE (theFuncNumber = 0)
													funcName$ = "PROLOG"
											CASE ELSE
													funcName$ = ""
										END SELECT
		CASE $$XSET:		IF ((theFuncNumber > 0) AND (theFuncNumber <= ufunc)) THEN
											IF funcSymbol$[theFuncNumber] THEN
												funcSymbol$[theFuncNumber] = funcName$
											END IF
										END IF
		CASE ELSE:			PRINT "Bogus command to XxxFunctionName$() = "; command
	END SELECT
END FUNCTION
'
'
' ########################################
' #####  XxxGetAddressGivenLabel ()  #####
' ########################################
'
FUNCTION  XxxGetAddressGivenLabel (label$)
	SHARED	labaddr[],  tab_lab$[]
	SHARED	labelPtr
'
	IFZ label$ THEN RETURN (0)
	FOR i = 0 TO labelPtr
		IF (tab_lab$[i] = label$) THEN RETURN (labaddr[i])
	NEXT i
'
'	No match
'		append "$##" (where ## is a decimal number) to STDCALL function names.
'		IF label${0} = "_", try to find a match with "$##" stripped from tab_lab$
'
	length = LEN(label$)													' label length = offset to "$" in STDCALL symbol
'	IF (label${0} != '_') THEN RETURN (0)					' SCO del from NT
	FOR i = 0 TO labelPtr
		IFZ tab_lab$[i] THEN DO NEXT
'		IF (tab_lab$[i]{0} != '_') THEN DO NEXT			' SCO del from NT
'		iat = RINSTR (tab_lab$[i], "@")							' SCO and Windows
		iat = RINSTR (tab_lab$[i], "_")							' Linux
		IF (iat != (length+1)) THEN DO NEXT					' no "_" at appropriate location in label symbol
		upper = UBOUND(tab_lab$[i])									' last offset in label symbol
		IF (upper <= length) THEN DO NEXT						' label symbol not long enough to have $ + digit
		one = INSTR(tab_lab$[i], label$)						' do symbol and label start the same?
		IF (one != 1) THEN DO NEXT									' nope
		IF (LEFT$(tab_lab$[i],iat-1) = label$) THEN	' symbol left of $ is the same as label$
			ok = $$TRUE																' found label symbol = default
			FOR o = length+1 TO upper									' for all characters after the $
				byte = tab_lab$[i]{o}										' get digit following the $
				IF (byte < '0') THEN ok = 0 : EXIT FOR	' not decimal digit after $
				IF (byte > '9') THEN ok = 0 : EXIT FOR	' ditto
			NEXT o
			IF ok THEN RETURN (labaddr[i])						' found symbol + $## that matches label$
		END IF
	NEXT i
END FUNCTION
'
'
' ########################################
' #####  XxxGetFunctionVariables ()  #####
' ########################################
'
'  Fill token, symbol, location arrays for function # funcNumber.
'			- match only kinds[], toss internal symbols starting with ".",
'       like .for.limit.0001, etc.
'  Return number of variables
'
FUNCTION  XxxGetFunctionVariables (funcNumber, kinds[], tok[], symbol$[], reg[], addr[])
	SHARED  hash%[],  tab_sym[],  tab_sym$[],  m_reg[],  m_addr[]
	SHARED  labaddr[]

	IFZ kinds[] THEN RETURN (0)
	numKinds = UBOUND(kinds[])

	uhash = UBOUND(hash%[])
	IF ((funcNumber < 0) OR (funcNumber > uhash)) THEN RETURN (0)
	IFZ hash%[funcNumber, ] THEN RETURN (0)

	utok		= 15
	DIM tok[utok]
	DIM reg[utok]
	DIM addr[utok]
	DIM symbol$[utok]
	index		= -1

	i = 0
	ATTACH hash%[funcNumber, ] TO func%[]
	DO UNTIL (i > 255)
		IFZ func%[i, ] THEN INC i: DO DO
		ATTACH func%[i, ] TO vars%[]
		numVars		= vars%[0]
		IFZ numVars THEN
			ATTACH vars%[] TO func%[i, ]
			INC i
			DO DO
		END IF
		IF ((numVars + index) > utok) THEN
			utok	= utok + numVars
			utok	= utok + (utok >> 1)
			REDIM tok[utok]
			REDIM symbol$[utok]
			REDIM reg[utok]
			REDIM addr[utok]
		END IF
		j = 1
		DO UNTIL (j > numVars)
			symbolPtr	= vars%[j]
			token			= tab_sym[symbolPtr]
			tk				= token{$$KIND}
			k					= 0
			DO UNTIL (k > numKinds)
				IF (tk = kinds[k]) THEN EXIT DO
				INC k
			LOOP
			IF (k > numKinds) THEN
				INC j
				DO DO
			END IF
			symbol$ = tab_sym$[symbolPtr]
			IF (tk = $$KIND_VARIABLES) THEN
				IF (symbol${0} = '.') THEN
					INC j
					DO DO
				END IF
			END IF
			IFZ m_reg[symbolPtr] THEN
				IFZ m_addr[symbolPtr] THEN
					INC j													' not currently being used in program
					DO DO
				END IF
			END IF
			INC index													' add it in...
			tok[index] = token
			IF (tk = $$KIND_ARRAYS) THEN
				symbol$[index] = symbol$ + "[]"
			ELSE
				symbol$[index] = symbol$
			END IF
			reg[index]	= m_reg[symbolPtr]
			addr[index]	= m_addr[symbolPtr]
			INC j
		LOOP
		ATTACH vars%[] TO func%[i, ]
		INC i
	LOOP
	ATTACH func%[] TO hash%[funcNumber, ]
	IF (index < 0) THEN
		DIM tok[]
		DIM symbol$[]
		DIM reg[]
		DIM addr[]
		RETURN (0)
	ELSE
		REDIM tok[index]
		REDIM symbol$[index]
		REDIM reg[index]
		REDIM addr[index]
		RETURN (index + 1)
	END IF
END FUNCTION
'
'
' ########################################
' #####  XxxGetLabelGivenAddress ()  #####
' ########################################
'
FUNCTION  XxxGetLabelGivenAddress (address, labels$[])
	SHARED	labaddr[],  tab_lab$[]
	SHARED	labelPtr
'
	DIM labels$[]
	IFZ labaddr[] THEN XxxInitAll ()			' load function labels
	IFZ labaddr[] THEN RETURN ($$FALSE)		' labels unavailable - give up
'
	i = 0
	entry = 0
	DIM labels$[7]
'
	DO WHILE (i <= labelPtr)
		IF (address = labaddr[i]) THEN
			labels$[entry] = tab_lab$[i]
			INC entry
			IF (entry >= 8) THEN EXIT DO
		END IF
	INC i
	LOOP
	RETURN (entry)
END FUNCTION
'
'
' ##################################
' #####  XxxGetPatchErrors ()  #####
' ##################################
'
FUNCTION  XxxGetPatchErrors (symbol$[], token[], addr[])
	SHARED	errSymbol$[],  errToken[],  errAddr[]
'
	DIM symbol$[]
	DIM token[]
	DIM addr[]
	IFZ errAddr[] THEN RETURN (0)

	count = UBOUND (errAddr[]) + 1
	SWAP symbol$[], errSymbol$[]
	SWAP token[], errToken[]
	SWAP addr[], errAddr[]
	RETURN (count)
END FUNCTION
'
'
' ##################################
' #####  XxxGetProgramName ()  #####
' ##################################
'
FUNCTION  XxxGetProgramName (name$)
	SHARED  programName$
	SHARED  program$
'
	name$ = programName$
	IFZ name$ THEN name$ = program$
END FUNCTION
'
'
' #################################
' #####  XxxGetSymbolInfo ()  #####
' #################################
'
'  Input:	tokNumber
' Output:	token, type, symbol$, reg, addr
'
FUNCTION  XxxGetSymbolInfo (tokNumber, token, theType, symbol$, reg, addr)
	SHARED	tab_sym[],  tab_sym$[],  m_reg[],  m_addr[],  labaddr[]

	token		= tab_sym[tokNumber]
	theType	= TheType (token)
	symbol$	= tab_sym$[tokNumber]
	reg			= m_reg[tokNumber]
	addr		= m_addr[tokNumber]
END FUNCTION
'
'
' ################################
' #####  XxxGetUserTypes ()  #####
' ################################
'
'	Used by Xit to fill in current composite type names  (type 0x22 and up)
'
FUNCTION  XxxGetUserTypes (varTypes$[])
	SHARED	typeSymbol$[],  uType
'
	IF (uType < 0x22) THEN RETURN						' No user composites
	FOR lastType = uType TO 0x22 STEP -1
		IF typeSymbol$[lastType] THEN EXIT FOR
	NEXT lastType
	IF (lastType < 0x22) THEN RETURN				' No user composites
	IF (lastType != UBOUND(varTypes$[])) THEN
		REDIM varTypes$[lastType]
	END IF
	FOR i = 0x22 TO lastType
		varTypes$[i] = typeSymbol$[i]
	NEXT i
END FUNCTION
'
'
' ##############################
' #####  XxxGetXerror$ ()  #####
' ##############################
'
FUNCTION  XxxGetXerror$ (err)
	SHARED  xerror$[]
	SHARED  uerror
'
	IF ((err <= 0) OR (err > uerror)) THEN
		RETURN ("Unknown error number:  " + STRING(err))
	END IF
	RETURN (xerror$[err])
END FUNCTION
'
'
' ###########################
' #####  XxxInitAll ()  #####
' ###########################
'
FUNCTION  XxxInitAll ()
	InitArrays ()
	InitEntry ()
	InitErrors ()
	XxxInitParse ()
	InitProgram ()
	InitVariables ()
	TokensDefined ()
	InitComplex ()
END FUNCTION
'
'
' #############################
' #####  XxxInitParse ()  #####
' #############################
'
FUNCTION  XxxInitParse ()
	SHARED	got_function,  parse_got_function,  func_number
	got_function				= $$FALSE
	parse_got_function	= $$FALSE
	func_number					= 0
END FUNCTION
'
'
' ######################################
' #####  XxxInitVariablesPass1 ()  #####
' ######################################
'
FUNCTION  XxxInitVariablesPass1 ()
	EXTERNAL /xxx/	xpc,  errorCount
	SHARED  export$[]
	SHARED  import$[]
	SHARED  declare$[]
	SHARED  exportCount
	SHARED  importCount
	SHARED  declareCount
	SHARED	defaultType[]
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED	XERROR
	SHARED	charPtr,  defaultType
	SHARED	end_program,  func_number
	SHARED	got_declare,  got_executable,  got_export,  got_function
	SHARED	got_import,  got_object_declaration,  got_program,  got_type
	SHARED  ofile
	SHARED	export
	SHARED	version$
	SHARED  program$
	SHARED  programName$
	SHARED  programPath$
	SHARED	hfn$,  ifLine,  infunc,  inlevel,  insub,  oos
	SHARED	labelNumber,  lineNumber,  prologCode,  preExports
	SHARED	patchPtr,  backToken,  lastToken,  nestCount,  nestLevel
	SHARED	section,  subCount,  tokenPtr
	SHARED	externalAddr,  pass,  pass2errors
	SHARED	programToken,  versionToken
	SHARED	stopComment
'
	DIM export$[]
	DIM import$[]
	DIM declare$[]
	DIM libraryCode$[]
	DIM libraryName$[]
	DIM libraryHandle[]
'
	XERROR					= 0
	pass						= 1
	pass2errors			= 0
	prologCode			= 0
	preExports			= 0
	exportCount			= 0
	importCount			= 0
	declareCount		= 0
	oos							= 0
	insub						= 0
	infunc					= 0
	inlevel					= 0
	ifLine					= 0
	charPtr					= 0
	subCount				= 0
	tokenPtr				= 0
	nestCount				= 0
	nestLevel				= 0
	backToken				= 0
	lastToken				= 0
	programToken		= 0
	versionToken		= 0
	stopComment			= 0
	xpc							= ##UCODE
	##GLOBAL				= ##GLOBAL0
	##GLOBALX				= ##GLOBAL0
	externalAddr		= ##GLOBAL0
	errorCount			= 0
	patchPtr				= 0
	lineNumber			= 0
	func_number			= 0
	labelNumber			= 0
	version$				= ""
	program$				= ""
	programName$		= ""
	programPath$		= ""
	asmFile$				= ""
	hfn$						= "0"
	defaultType			= $$XLONG
	section					= $$TEXTSECTION
'
	IF (ofile > 2) THEN CLOSE (ofile)
	ofile = 0
'
	export										= $$FALSE
	got_declare								= $$FALSE
	got_export								= $$FALSE
	got_executable						= $$FALSE
	got_function							= $$FALSE
	got_import								= $$FALSE
	got_object_declaration		= $$FALSE
	got_program								= $$FALSE
	got_type									= $$FALSE
	end_program								= $$FALSE
	defaultType[func_number]	= defaultType
END FUNCTION
'
'
' ##############################
' #####  XxxLibraryAPI ()  #####
' ##############################
'
FUNCTION  XxxLibraryAPI (lib$)
	STATIC	lib$[]
'
	IFZ lib$ THEN RETURN
	IFZ lib$[] THEN XstLoadStringArray (@"\\xb\\xxx\\syslib.xxx", @lib$[])
	IFZ lib$[] THEN RETURN
'
	upper = UBOUND (lib$)
	IF (lib${upper} = '"') THEN lib$ = RCLIP$(lib$,1)
	IF (lib${0} = '"') THEN lib$ = LCLIP$(lib$,1)
'
	FOR i = 0 TO UBOUND (lib$[])
		IF (lib$ = lib$[i]) THEN RETURN ($$TRUE)
	NEXT i
END FUNCTION
'
'
' ###############################
' #####  XxxLoadLibrary ()  #####
' ###############################
'
FUNCTION  XxxLoadLibrary (token)
	EXTERNAL /xxx/  i486asm,  i486bin,  library,  xpc
	SHARED	a0,  a0_type,  a1,  a1_type
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED	programName$
	SHARED  program$
	SHARED	prologCode
	SHARED	inTYPE,  labelNumber,  lineNumber,  parse_got_function
	SHARED	tab_sym$[],  tokens[],  tokenPtr,  tokenCount,  stopComment
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_FILE_NOT_FOUND
	FUNCADDR	addr ()
'
	handle = 0
	##ERROR = $$FALSE
	IFZ program$ THEN program$ = programName$
	IFZ programName$ THEN programName$ = program$
'
	libname$ = tab_sym$[token{$$NUMBER}]
	libname$ = TRIM$(MID$(libname$,2,LEN(libname$)-2))
	IFZ libname$ THEN PRINT "XxxLoadLibrary(): Error: (empty libname$)" : GOTO eeeCompiler
'
	dot = INSTR (libname$, ".")
	IF dot THEN libname$ = LEFT$(libname$, dot-1)
	library$ = libname$ + ".dec"
	dllname$ = libname$ + ".dll"
'
	IF libraryName$[] THEN
		upper = UBOUND (libraryName$[])
		FOR i = 0 TO upper
			IF (libname$ = libraryName$[i]) THEN
				IF libraryHandle[i] THEN RETURN			' library already compiled
				IF libraryCode$[i,] THEN parsed = $$TRUE
				EXIT FOR
			END IF
		NEXT i
		libraryNumber = i
	ELSE
		libraryNumber = 0
	END IF
'
	IF parsed THEN
		SWAP lib$[], libraryCode$[i,]
	ELSE
		ifile = OPEN (library$, $$RD)
		IF (ifile <= 0) THEN
			' Retry in XBasic system directory.
			library$ = ##XBDir$ + "/include/" + libname$ + ".dec"
			ifile = OPEN (library$, $$RD)
		END IF
		IF (ifile <= 0) THEN PRINT library$; " not found" : GOTO eeeFileNotFound
		length = LOF (ifile)
		lib$ = NULL$ (length)
		READ [ifile], lib$
		CLOSE (ifile)
		XstStringToStringArray (@lib$, @lib$[])		' lib$[] = file "libname.DEC"
		IFZ lib$[] THEN PRINT library$; " is empty" : GOTO eeeFileNotFound
	END IF
'
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
'
'
' NOTE : The following code is different in the Windows version.
' NOTE : Modify the following to make Linux version support true DLLs.
'
	SELECT CASE TRUE
		CASE i486asm
					SELECT CASE LCASE$(libname$)
						CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
						CASE ELSE
									INC labelNumber : d1$ = "_" + HEX$(labelNumber, 4)
									INC labelNumber : d2$ = "_" + HEX$(labelNumber, 4)
									IFZ prologCode THEN
										EmitText ()
										SELECT CASE TRUE
											CASE library	:  Code ($$jmp, $$rel, 0, 0, 0, 0, "__StartLibrary_" + program$, "### 1127")
											CASE ELSE			:  Code ($$jmp, $$rel, 0, 0, 0, 0, @"__StartApplication", "### 1128")
										END SELECT
										prologCode = $$TRUE
										EmitLabel ("PrologCode")
										Code ($$push, $$reg, $$ebp, 0, 0, $$XLONG, "", @"### 1129")
										Code ($$mov, $$regreg, $$ebp, $$esp, 0, $$XLONG, "", @"### 1130")
										Code ($$sub, $$regimm, $$esp, 256, 0, $$XLONG, "", @"### 1131")
										EmitNull (@"#")
									END IF
									Move ($$eax, $$XLONG, token, $$XLONG)
									Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 1132")
'									Code ($$call, $$rel, 0, 0, 0, 0, @"LoadLibraryA$4", "### 1133")			' gas ?
									Code ($$call, $$rel, 0, 0, 0, 0, @"LoadLibraryA_4", "### 1133")			' unspas
									Code ($$or, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 1134")
									Code ($$jz, $$rel, 0, 0, 0, 0, @d2$, "### 1135")
									Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 1136")
									Code ($$mov, $$regimm, $$eax, 0, 0, $$XLONG, @"__string.StartLibrary", "### 1137")
									Move ($$ebx, $$XLONG, token, $$XLONG)
									Code ($$call, $$rel, 0, 0, 0, 0, @"__concat.string.a0.eq.a0.plus.a1.vv", "### 1138")
									Code ($$pop, $$reg, $$ebx, 0, 0, $$XLONG, "", "### 1139")
									Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 1140")
									Code ($$push, $$reg, $$eax, 0, 0, $$XLONG, "", "### 1141")
									Code ($$push, $$reg, $$ebx, 0, 0, $$XLONG, "", "### 1142")
'									Code ($$call, $$rel, 0, 0, 0, 0, @"GetProcAddress$8", "### 1143")		' gas ?
									Code ($$call, $$rel, 0, 0, 0, 0, @"GetProcAddress_8", "### 1143")		' unspas
									Code ($$or, $$regreg, $$eax, $$eax, 0, $$XLONG, "", "### 1144")
									Code ($$jz, $$rel, 0, 0, 0, 0, @d1$, "### 1145")
									Code ($$call, $$reg, $$eax, 0, 0, 0, "", "### 1146")
									EmitLabel (@d1$)
									Code ($$pop, $$reg, $$esi, 0, 0, $$XLONG, "", "### 1147")
									Code ($$call, $$rel, 0, 0, 0, 0, @"_____free", "### 1148")
									EmitLabel (@d2$)
									EmitNull (@"#")
									a0 = 0 : a0_type = 0
									a1 = 0 : a1_type = 0
					END SELECT
		CASE i486bin
					SELECT CASE LCASE$(libname$)
						CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
						CASE ELSE
									handle = LoadLibraryA (&dllname$)		' libname.DLL handle
									IF handle THEN
'										PRINT "Got library <"; dllname$; "> ... handle = "; HEX$ (handle, 8)
'
										startLibrary$ = "__StartLibrary_" + libname$
										addr = GetProcAddress (handle, &startLibrary$)
										@addr ()
'										PRINT startLibrary$; " = "; HEX$ (addr,8)
									END IF
					END SELECT
	END SELECT
'
	upper = UBOUND (libraryName$[])
	IF (libraryNumber > upper) THEN
		REDIM libraryCode$[libraryNumber, ]			' libname.DEC source code arrays
		REDIM libraryName$[libraryNumber]				' libname string array
		REDIM libraryHandle[libraryNumber]			' libname.DLL handle array
		libraryName$[libraryNumber] = libname$	' save libname string (no extent)
	END IF
	libraryHandle[libraryNumber] = handle			' save libname.DLL handle
'
	stopComment = $$TRUE											' don't emit asm for library comments
	i = 0
	DO
		line$ = TRIM$ (lib$[i])
		t = INSTR (line$, "TYPE")
		IF (t = 1) THEN GOSUB GetType : INC i : DO LOOP
		c = INSTR (line$, "$$")
		IF (c = 1) THEN GOSUB GetConstant : INC i : DO LOOP
		INC i
	LOOP WHILE (i <= upperLib)
'
	stopComment = $$FALSE
	lineNumber = holdLine											' restore line number
	tokenPtr = holdTokenPtr										' restore current token pointer
	tokenCount = holdTokenCount								' restore current token count
	parse_got_function = holdParseFunc				' restore parse_got_function variable
	SWAP bs[], tokens[] : DIM bs[]						' restore compiling line of tokens[]
	ATTACH lib$[] TO libraryCode$[libraryNumber, ]	' keep "libname.DEC" for future reference
	RETURN
'
'
' *****  GetType  *****
'
SUB GetType
	DO
		line$ = TRIM$(lib$[i])									' next source line string
		XxxParseSourceLine (line$, @tok[])			' type declaration line to tokens
		IF tok[] THEN	XxxCheckLine (0, @tok[])	' compile the tokens
		IFZ inTYPE THEN EXIT DO									' processed END TYPE
		IF XERROR THEN
			IF PrintError (XERROR) THEN RETURN		' print error and count it
		END IF
		INC i																		' next source line index
	LOOP WHILE (i < upperLib)
END SUB
'
'
' *****  GetConstant  *****
'
SUB GetConstant
	XxxParseSourceLine (line$, @tok[])
	IF tok[] THEN XxxCheckLine (0, @tok[])
END SUB
'
'
' *****  Errors  *****
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeFileNotFound:
	XERROR = ERROR_FILE_NOT_FOUND
	EXIT FUNCTION
END FUNCTION
'
'
' ###################################
' #####  XxxParseSourceLine ()  #####
' ###################################
'
FUNCTION  XxxParseSourceLine (sourceLine$, tok[])
	SHARED	rawLength,  rawline$
'
	rawline$ = sourceLine$
	rawLength = LEN(rawline$)
	ParseLine (@tok[])
END FUNCTION
'
'
' ######################################
' #####  XxxPassFunctionArrays ()  #####
' ######################################
'
FUNCTION  XxxPassFunctionArrays (command, symbol$[], token[], scope[])
	SHARED	funcSymbol$[],  funcToken[],  funcScope[],  funcType[]
'
	SELECT CASE command
		CASE $$XGET:	ATTACH funcSymbol$[] TO symbol$[]
									ATTACH funcToken[] TO token[]
									ATTACH funcScope[] TO scope[]
									RETURN (0)
		CASE $$XSET:	ATTACH symbol$[] TO funcSymbol$[]
									ATTACH token[] TO funcToken[]
									ATTACH scope[] TO funcScope[]
									RETURN (0)
		CASE	ELSE:		RETURN (-1)
	END SELECT
END FUNCTION
'
'
' ################################
' #####  XxxParseLibrary ()  #####
' ################################
'
' The TYPE statements in IMPORT libraries have to be parsed before
' the body of the main program because otherwise type names defined
' in IMPORT libraries are parsed into $$KIND_SYMBOLS tokens in the
' main program instead of the correct $$KIND_TYPES tokens.  This
' causes errors in the main program compilation because type names
' are treated as symbols, not types.
'
FUNCTION  XxxParseLibrary (token)
	EXTERNAL /xxx/  i486asm,  i486bin,  library,  xpc
	SHARED	libraryCode$[]
	SHARED	libraryName$[]
	SHARED	libraryHandle[]
	SHARED	prologCode
	SHARED	inTYPE,  labelNumber,  lineNumber,  parse_got_function
	SHARED	tab_sym$[],  tokens[],  tokenPtr,  tokenCount,  stopComment
	SHARED	XERROR,  ERROR_COMPILER,  ERROR_FILE_NOT_FOUND
'
	##ERROR = $$FALSE
	libname$ = tab_sym$[token{$$NUMBER}]
	libname$ = TRIM$(MID$(libname$,2,LEN(libname$)-2))
'
	IFZ libname$ THEN
		PRINT "XxxParseLibrary(): Error: (empty libname$)"
		GOTO eeeFileNotFound
	END IF
'
	dot = INSTR (libname$, ".")
	IF dot THEN libname$ = LEFT$(libname$, dot-1)
	library$ = libname$ + ".dec"
	dllname$ = libname$ + ".dll"
'
	IF libraryName$[] THEN
		upper = UBOUND (libraryName$[])
		FOR i = 0 TO upper
			IF (libname$ = libraryName$[i]) THEN
				IF libraryCode$[i,] THEN RETURN				' library already parsed
				EXIT FOR
			END IF
		NEXT i
		libraryNumber = i
	ELSE
		libraryNumber = 0
	END IF
'
	ifile = OPEN (library$, $$RD)
	IF (ifile <= 0) THEN
		' Retry in XBasic system directory.
		library$ = ##XBDir$ + "/include/" + libname$ + ".dec"
		ifile = OPEN (library$, $$RD)
	END IF
	IF (ifile <= 0) THEN PRINT library$; " not found" : GOTO eeeFileNotFound
	length = LOF (ifile)
	lib$ = NULL$ (length)
	READ [ifile], lib$
	CLOSE (ifile)
'
	XstStringToStringArray (@lib$, @lib$[])		' lib$[] = file "libname.DEC"
	IFZ lib$[] THEN PRINT library$; " is empty" : GOTO eeeFileNotFound
	upperLib = UBOUND (lib$[])								' last line in file "libname.DEC"
'
	holdLine = lineNumber											' hold line number
	holdTokenPtr = tokenPtr										' hold current token pointer
	holdTokenCount = tokenCount								' hold current token count
	holdParseFunc = parse_got_function				' hold parse_got_function variable
	DIM bs[255] : SWAP bs[], tokens[]					' hold compiling line of tokens[]
	tokenPtr = 0															' pretend it's token 0
	tokenCount = 0														' pretend it's token 0
	lineNumber = 0														' pretend it's line 0
	parse_got_function = 0										' pretend it's PROLOG
'
	upper = UBOUND (libraryName$[])
	IF (libraryNumber > upper) THEN
		REDIM libraryCode$[libraryNumber, ]			' libname.DEC source code arrays
		REDIM libraryName$[libraryNumber]				' libname string array
		REDIM libraryHandle[libraryNumber]			' libname.DLL handle array
		libraryName$[libraryNumber] = libname$	' save libname string (no extent)
	END IF
'
	stopComment = $$TRUE											' don't emit asm for library comments
	i = 0
	DO
		line$ = TRIM$ (lib$[i])
		t = INSTR (line$, "TYPE")
		IF (t = 1) THEN XxxParseSourceLine (line$, @tok[])
		INC i
	LOOP WHILE (i <= upperLib)
'
	stopComment = $$FALSE
	lineNumber = holdLine											' restore line number
	tokenPtr = holdTokenPtr										' restore current token pointer
	tokenCount = holdTokenCount								' restore current token count
	parse_got_function = holdParseFunc				' restore parse_got_function variable
	SWAP bs[], tokens[] : DIM bs[]						' restore compiling line of tokens[]
	ATTACH lib$[] TO libraryCode$[libraryNumber, ]	' keep "libname.DEC" for pass 1
	RETURN
'
'
' *****  Errors  *****
'
eeeCompiler:
	XERROR = ERROR_COMPILER
	EXIT FUNCTION
'
eeeFileNotFound:
	XERROR = ERROR_FILE_NOT_FOUND
	EXIT FUNCTION
END FUNCTION
'
'
' ##################################
' #####  XxxPassTypeArrays ()  #####
' ##################################
'
'	Used by Xit to display composite information in Variables box
'
FUNCTION  XxxPassTypeArrays (command, pSize[], pSize$[], pAlias[], pAlign[], pSymbol$[], pToken[], pEleCount[], pEleSymbol$[], pEleToken[], pEleAddr[], pEleSize[], pEleType[], pEleStringSize[], pEleUBound[])
	SHARED typeSize[]						' size in bytes
	SHARED typeSize$[]					' "1", "2", "4", "8", "16"...
	SHARED typeAlias[]					' normal type that user-type is alias for
	SHARED typeAlign[]					' alignment for this type
	SHARED typeSymbol$[]				' SBYTE, UBYTE...  SCOMPLEX, DCOMPLEX, USERTYPE...
	SHARED typeToken[]					' T_TYPE token, low word = type #
	SHARED typeEleCount[]				' # of elements in this type
	SHARED typeEleSymbol$[]			' symbol for each n elements
	SHARED typeEleToken[]				' token for each n elements
	SHARED typeEleAddr[]				' offset address of each n elements
	SHARED typeEleSize[]				' size of each n elements ([]: typesize*(dim+1))
	SHARED typeEleType[]				' type of each n elements
	SHARED typeEleStringSize[]	' # bytes in fixed string for element n
	SHARED typeEleUBound[]			' Upper bound of 1D array for element n
'
	SELECT CASE command
		CASE $$XGET:	ATTACH typeSize[]						TO pSize[]
									ATTACH typeSize$[]					TO pSize$[]
									ATTACH typeAlias[]					TO pAlias[]
									ATTACH typeAlign[]					TO pAlign[]
									ATTACH typeSymbol$[]				TO pSymbol$[]
									ATTACH typeToken[]					TO pToken[]
									ATTACH typeEleCount[]				TO pEleCount[]
									ATTACH typeEleSymbol$[]			TO pEleSymbol$[]
									ATTACH typeEleToken[]				TO pEleToken[]
									ATTACH typeEleAddr[]				TO pEleAddr[]
									ATTACH typeEleSize[]				TO pEleSize[]
									ATTACH typeEleType[]				TO pEleType[]
									ATTACH typeEleStringSize[]	TO pEleStringSize[]
									ATTACH typeEleUBound[]			TO pEleUBound[]
									RETURN (0)
		CASE $$XSET:	ATTACH pSize[]							TO typeSize[]
									ATTACH pSize$[]							TO typeSize$[]
									ATTACH pAlias[]							TO typeAlias[]
									ATTACH pAlign[]							TO typeAlign[]
									ATTACH pSymbol$[]						TO typeSymbol$[]
									ATTACH pToken[]							TO typeToken[]
									ATTACH pEleCount[]					TO typeEleCount[]
									ATTACH pEleSymbol$[]				TO typeEleSymbol$[]
									ATTACH pEleToken[]					TO typeEleToken[]
									ATTACH pEleAddr[]						TO typeEleAddr[]
									ATTACH pEleSize[]						TO typeEleSize[]
									ATTACH pEleType[]						TO typeEleType[]
									ATTACH pEleStringSize[]			TO typeEleStringSize[]
									ATTACH pEleUBound[]					TO typeEleUBound[]
									RETURN (0)
		CASE	ELSE:		RETURN (-1)
	END SELECT
END FUNCTION
'
'
' ##################################
' #####  XxxSetProgramName ()  #####
' ##################################
'
FUNCTION  XxxSetProgramName (name$)
	SHARED  programName$
	SHARED  programPath$
'
	pathname$ = name$
	XstDecomposePathname (@pathname$, @path$, @parent$, @filename$, @file$, @extent$)
	IFZ filename$ THEN RETURN
	IF (extent$ != ".x") THEN
		filename$ = file$ + ".x"
		extent$ = ".x"
	END IF
	programName$ = file$
	programPath$ = path$ + $$PathSlash$ + filename$
END FUNCTION
'
'
' ###########################
' #####  XxxTheType ()  #####
' ###########################
'
FUNCTION  XxxTheType (token, funcNumber)
	SHARED	func_number

	save_func_number	= func_number
	func_number				= funcNumber
	tt								= TheType (token)
	func_number				= save_func_number
	RETURN (tt)
END FUNCTION
'
'
' ######################################
' #####  XxxUndeclaredFunction ()  #####
' ######################################
'
FUNCTION  XxxUndeclaredFunction (funcToken)
	EXTERNAL /xxx/	i486asm,  i486bin,  library,  xpc
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
'
	match = $$FALSE														' funcName not found yet
	funcNumber = funcToken{$$NUMBER}					' function number
	funcSymbol$ = funcSymbol$[funcNumber]			' function symbol
	length = LEN(funcSymbol$)									' length of function symbol
	IFZ libraryCode$[] THEN RETURN						' no libraries
	IFZ libraryName$[] THEN RETURN						' ditto
	IFZ libraryHandle[] THEN RETURN						' ditto
'
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
				SELECT CASE TRUE
					CASE i486asm
'								SELECT CASE LCASE$(libraryName$)
'									CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
'												dll$ = "xb"
'									CASE ELSE
'												dll$ = libraryName$
'								END SELECT
								string$ = "IMPORTS  " + libraryName$ + "." + funcSymbol$
								WriteDefinitionFile (@string$)
					CASE i486bin
								IF handle THEN							' libname.DLL exists
									tok = AddLabel (@libraryFunctionLabel$, $$T_LABELS, $$XNEW)
									IF XERROR THEN PRINT libraryFunctionLabel$
									IF XERROR THEN EXIT FOR
									tt = tok{$$NUMBER}
									IF labaddr[tt] THEN GOTO eeeDupLabel
									addr = GetProcAddress (handle, &funcSymbol$)
									IF addr THEN labaddr[tt] = addr
'									PRINT libraryName$[lib], funcSymbol$, libraryFunctionLabel$, HEX$(addr,8)
								END IF
				END SELECT
				parse_got_function = holdParseFunc	' restore real parse_got_function
				got_function = holdGotFunc					' restore real got_function
				func_number = holdFunc							' restore real func number
				lineNumber = holdLine								' restore real line number
				tokenPtr = holdTokenPtr							' restore real token pointer
				tokenCount = holdTokenCount					' restore real token count
				SWAP bs[], tokens[] : DIM bs[]			' restore compiling line tokens[]
			END IF																'
			EXIT FOR															' done... got library declaration
		NEXT i																	' next source line in this library
		ATTACH library$[] TO libraryCode$[lib,]	' replace libname.DEC source
		IF XERROR THEN EXIT FUNCTION						' AddLabel error
		IF match THEN EXIT FOR									' found declaration - skip rest of libraries
	NEXT lib																	' next library
'
	token = funcToken[funcNumber]							' get updated func token
	RETURN (token)														' return updated func token
'
'
eeeDupLabel:
	XERROR = ERROR_DUP_LABEL
	RETURN ($$T_STARTS)
'
eeeProgramNotNamed:
	XERROR = ERROR_PROGRAM_NOT_NAMED
	RETURN ($$T_STARTS)
END FUNCTION
'
'
' ###############################
' #####  XxxXntBlowback ()  #####
' ###############################
'
FUNCTION  XxxXntBlowback ()
	SHARED	libraryHandle[]
	SHARED	libraryName$[]
	SHARED	libraryCode$[]
	FUNCADDR	addr ()
'
' Must enable the Windows code below to make true DLLs work.
'
	upper = UBOUND (libraryCode$[])
	FOR i = 0 TO upper
		IF libraryCode$[i,] THEN
			libname$ = libraryName$[i]
			IF libname$ THEN
				SELECT CASE LCASE$(libname$)
					CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
					CASE ELSE
								handle = libraryHandle[i]
								IF handle THEN
									blowback$ = "Blowback"
'									IFZ XxxLibraryAPI (libname$)
										addr = GetProcAddress (handle, &blowback$)
'										PRINT blowback$; " = "; HEX$ (addr,8)
										@addr ()
'
										blowback$ = "____blowback_" + libname$
										addr = GetProcAddress (handle, &blowback$)
'										PRINT blowback$; " = "; HEX$ (addr,8)
										@addr ()
'									END IF
								END IF
				END SELECT
			END IF
		END IF
	NEXT i
	##ENTERED = $$FALSE
END FUNCTION
'
'
' ####################################
' #####  XxxXntFreeLibraries ()  #####
' ####################################
'
FUNCTION  XxxXntFreeLibraries ()
	SHARED	libraryHandle[]
	SHARED	libraryName$[]
	SHARED	libraryCode$[]
	FUNCADDR	addr ()
'
	upper = UBOUND (libraryCode$[])
	FOR i = 0 TO upper
		IF libraryCode$[i,] THEN
			libname$ = libraryName$[i]
			IF libname$ THEN
				SELECT CASE LCASE$(libname$)
					CASE "xlib", "xdis", "xst", "xin", "xma", "xcm", "xit", "xcol", "xgr", "xui", "gdi32", "kernel32", "user32"
					CASE ELSE
								handle = libraryHandle[i]
								IF handle THEN
									free = FreeLibrary (handle)
									PRINT "FreeLibrary ("; HEX$(handle,8); " = "; free
									ATTACH libraryCode$[i,] TO temp$[]
									libraryHandle[i] = 0
									libraryName$[i] = ""
									DIM temp$[]
								END IF
				END SELECT
			END IF
		END IF
	NEXT i
	DIM libraryCode$[]
	DIM libraryName$[]
	DIM libraryHandle[]
END FUNCTION
END PROGRAM
